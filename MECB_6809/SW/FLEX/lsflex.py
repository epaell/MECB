#!/usr/bin/env python

import numpy as np
import sys

# Remove control characters from byte array and return as string
def byte2str(b):
    s = ""
    for v in b:
        if (v < 0x20) or (v > 0x80):
            continue
        s += chr(v)
    return s


# FLEX disk layout for a 40 track floppy with 20 sectors on each track
#TRACK 00 SECTOR 01 --- Boot sector
#TRACK 00 SECTOR 02 --- Boot sector
#TRACK 00 SECTOR 03 --- System Information Record (SIR)
#TRACK 00 SECTOR 04 --- Not used
#TRACK 00 SECTOR 05 --- Start of directory
# .
# .
#TRACK 00 SECTOR 20 --- End of directory
#TRACK 00 SECTOR >20 -- For formats with more than 20 sectors per track these are unused in track 0
#TRACK 01 SECTOR 01 --- Start of file data
# .
# .
#TRACK 39 SECTOR 20 --- End of file data (last sector on disk)

# SIR
#  16 byte --- Unused
#  11 byte --- Volume label
#   2 byte --- Volume number
#   1 byte --- First free track
#   1 byte --- First free sector
#   1 byte --- Last free track
#   1 byte --- Last free sector
#   2 byte --- Number of free sectors
#   1 byte --- Date month
#   1 byte --- Date day
#   1 byte --- Date year
#   1 byte --- End track
#   1 byte --- End sector

# sectors have 256 bytes; for most sectors, first 4 bytes specify:
#   1 byte --- Next track
#   1 byte --- Next sector
#   2 byte --- Sequence number
# 252 byte --- data

class FLEX_disk:
    def __init__(self, path):
#        print(f"Reading {path}")
        fin = open(path, "rb")
        self.raw_data = fin.read()
        fin.close()

#        print(f"disk size={len(self.raw_data)}")
        self.nsectors = (len(self.raw_data) >> 8)
#        print(f"nsectors={self.nsectors}")
        self.read_map()
        self.get_SIR()
        self.get_DIR()

    # Read the disk sector linkages and deduce the number of tracks and sectors
    def read_map(self):
        # Disk map [TRACK, SECTOR, 0] = Next track
        # Disk map [TRACK, SECTOR, 1] = Next sector
        # Disk map [TRACK, SECTOR, 2] = Sector sequence number
        # Disk map [TRACK, SECTOR, 3] = Type (-1 = undef, 0 = empty, 1 = data)
        self.map = np.zeros((self.nsectors, 4), dtype=np.int32)
        self.map = self.map - 1
        max_track = 0
        max_sector = -1
        min_track = 40
        min_sector = 40
        for sector in range(21, self.nsectors):
            dofs = 256 * sector
            next_track = self.raw_data[dofs]
            next_sector = self.raw_data[dofs+1]
            sector_seq = (self.raw_data[dofs+2] << 8) + self.raw_data[dofs+3]
            if sector == 36:
                print(sector, next_track, next_sector, sector_seq)
            if sector == 37:
                print(sector, next_track, next_sector, sector_seq)
            if next_track == 0:
                continue
            self.map[sector,0] = next_track
            self.map[sector,1] = next_sector
            self.map[sector,2] = sector_seq
            if next_sector > max_sector:
                max_sector = next_sector
            if next_sector < min_sector:
                min_sector = next_sector
            if next_track > max_track:
                max_track = next_track
            if next_track < min_track:
                min_track = next_track

        self.ntracks = max_track + 1
        self.sectors_per_track = max_sector
        # Reshape with respect to the deduced number of tracks and sectors per track
        self.map = self.map.reshape((self.ntracks, self.sectors_per_track, 4))

    def consistency_check(self):
        # Follow the empty sector links
        cft = self.sir["first_free_track"]
        cfs = self.sir["first_free_sector"]
        nempty = 0
        warn = False
        while cft != -1:
            nempty += 1
            lsn = self.LSN(cft, cfs)
            if self.map[cft, cfs-1, 3] != -1:
                print("WARNING: Empty sector re-referenced")
                return False
            self.map[cft, cfs-1, 3] = 0
            nft = self.map[cft, cfs-1, 0]
            nfs = self.map[cft, cfs-1, 1]
            cft = nft
            cfs = nfs
        if nempty != self.sir["free_sectors"]:
            print(f"WARNING: Inconsistent number of free sectors {nempty} vs {self.sir["free_sectors"]}")
            warn = True
            return False
        # Check file sector links
        for de in self.dir_entries:
            if len(de['file_name']) == 0:
                continue
            print(f"Checking {de['file_name']}.{de['file_ext']}")
            cft = de["start_track"]
            cfs = de["start_sector"]
            nsectors = 0
            sequence = 0
            if de['random_flag'] == 2:
                # TODO: Random files have two sectors with sequence = 0 before actual data starts
                for loop in range(2):
                    nsectors += 1
                    if self.map[cft, cfs-1, 3] != -1:
                        print("WARNING: Sector re-referenced")
                        warn = True
                        return False
                    self.map[cft, cfs-1, 3] = 1
                    nft = self.map[cft, cfs-1, 0]
                    nfs = self.map[cft, cfs-1, 1]
                    cft = nft
                    cfs = nfs
            while cft != -1:
                nsectors += 1
                sequence += 1
#                lsn = self.LSN(cft, cfs)
                if self.map[cft, cfs-1, 3] != -1:
                    print("WARNING: Sector re-referenced")
                    warn = True
                    return False
                self.map[cft, cfs-1, 3] = 1
                nft = self.map[cft, cfs-1, 0]
                nfs = self.map[cft, cfs-1, 1]
                if (nft != -1):
                     if self.map[cft, cfs-1, 2] != sequence:
                         print(f"WARNING: Invalid sequence number. Found {self.map[cft, cfs-1, 2]} expected {sequence} [t{cft:02d} s{cfs:02d}]")
                         warn = True
                cft = nft
                cfs = nfs
            if nsectors != de["total_sectors"]:
                print(f"Inconsistent number of sectors {nsectors} vs {de["total_sectors"]}")
                warn = True
                return False
        if warn:
            return False
        return True
            
    # Convert the track and sector number to a linear sector number
    def LSN(self, track, sector):
        return track * self.sectors_per_track + (sector - 1)

    # Read the System Information Record
    def get_SIR(self):
        # SIR is in track 0, sector 3
        offset = self.LSN(0, 3) * 256
        self.sir = {}
        self.sir["volume"] = byte2str(self.raw_data[offset+16:offset+27])
        self.sir["volume_number"] = (self.raw_data[offset+27] << 8) + self.raw_data[offset+28]
        self.sir["first_free_track"] = self.raw_data[offset+29]
        self.sir["first_free_sector"] = self.raw_data[offset+30]
        self.sir["last_free_track"] = self.raw_data[offset+31]
        self.sir["last_free_sector"] = self.raw_data[offset+32]
        self.sir["free_sectors"] = (self.raw_data[offset+33] << 8) + self.raw_data[offset+34]
        self.sir["month"] = self.raw_data[offset+35]
        self.sir["day"] = self.raw_data[offset+36]
        self.sir["year"] = self.raw_data[offset+37]
        # this is also number of tracks (0 based)
        self.sir["end_track"] = self.raw_data[offset+38]
        # this is also sectors per track (1 based):
        self.sir["end_sector"] = self.raw_data[offset+39]

    # Dump the System Information Record in a readable format
    def dump_sir(self):
        print("Volume label     %s" %(self.sir["volume"]))
        print("Volume number    %04d" %(self.sir["volume_number"]))
        print("Free area        t%02d s%02d - t%02d s%02d" %(self.sir['first_free_track'],self.sir['first_free_sector'],self.sir['last_free_track'],self.sir['last_free_sector']))
        print("Free sectors     %d" %(self.sir['free_sectors']))
        print("End sector       t%02d s%02d" %(self.sir['end_track'],self.sir['end_sector']))
        print("Creation date    %02d-%02d-%02d" %(self.sir['year'], self.sir['month'], self.sir['day']))

    # Read the directory entry at the current offset
    def get_DIR_entry(self, sector, offset):
        dofs = self.LSN(0, sector) * 256 + offset
        dir_entry = {}
        dir_entry['file_name'] = byte2str(self.raw_data[dofs:dofs+8])
        dir_entry['file_ext'] = byte2str(self.raw_data[dofs+8:dofs+11])
        dir_entry['start_track'] = self.raw_data[dofs+13]
        dir_entry['start_sector'] = self.raw_data[dofs+14]
        dir_entry['end_track'] = self.raw_data[dofs+15]
        dir_entry['end_sector'] = self.raw_data[dofs+16]
        dir_entry["total_sectors"] = (self.raw_data[dofs+17] << 8) + self.raw_data[dofs+18]
        dir_entry["random_flag"] = self.raw_data[dofs+19]
        dir_entry["month"] = self.raw_data[dofs+21]
        dir_entry["day"] = self.raw_data[dofs+22]
        dir_entry["year"] = self.raw_data[dofs+23]
        offset += 24
        if offset > 255:
            offset = 16
            sector += 1
        return dir_entry, sector, offset
    
    # get the directory entries
    def get_DIR(self):
        # DIR starts in track 0, sector 5 and goes up to track 0, sector 20
        self.dir_entries = []
    
        sector = 5
        offset = 16
        while sector < 21:
            de, sector, offset = self.get_DIR_entry(sector, offset)
            if len(de['file_name']) == 0:
                break
            self.dir_entries.append(de)
        return
    
    # List all files in the directory
    def dir(self):
        self.dump_sir()
        print("")
        print("%-12s   %-9s %-7s    %-4s    %-8s   %-4s" %("NAME", "START", "END", "SIZE", "DATE", "FLAG"))
        for de in self.dir_entries:
            if len(de['file_name']) == 0:
                continue
            fname = "%s.%s" %(de['file_name'], de['file_ext'])
            fname = fname.replace('\x00', '')
            print("%-12s   t%02d s%02d - t%02d s%02d    %4d    %02d-%02d-%02d   %02d" %(fname, de['start_track'], de['start_sector'], de['end_track'], de['end_sector'], de['total_sectors'], de['year'], de['month'], de['day'], de['random_flag']))

    # Dump the raw contents of the specified sector
    def dump(self, track, sector):
        offset = self.LSN(track, sector) * 256
        print(f"Track={track}  Sector={sector}  LSN={self.LSN(track, sector)}")
        print("         00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F ==== ASCII =====")
        for row in range(16):
            cstr = []
            astr = ""
            for col in range(16):
                d = self.raw_data[offset + row*16 + col]
                cstr.append("%02X" %(d))
                if (d > 0x1f) and (d < 0x80):
                    astr += chr(d)
                else:
                    astr += "."
            print("0x%04X : %s %s" %(row * 16, " ".join(cstr), astr))


#disk = FLEX_disk("diag6809.dsk")
#disk = FLEX_disk("source.dsk")
#disk = FLEX_disk("games.dsk")
#disk = FLEX_disk("6809BOOT.DSK")
disk = FLEX_disk(sys.argv[1])

if disk.ntracks * disk.sectors_per_track != disk.nsectors:
    print("Sector/Track mapping inconsistent")
print(f"{disk.ntracks} tracks with {disk.sectors_per_track} sectors = {disk.nsectors} total sectors")
disk.dir()
ok = disk.consistency_check()
if ok == False:
    print("Warnings issued")

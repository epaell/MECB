#!/usr/bin/env python
import os
import sys
import glob
from datetime import datetime, timezone

for version in ["1.1", "1.2", "1.3"]:
    image = f"CPM{version.replace(".","")}.IMG"

    now = datetime.now().astimezone()
    date = now.strftime("%a %d %b %Y %H:%M:%S %Z")

    # Diskdef
    partitions=1
    partition=0
    sectorSize = 128
    sectorsPerTrack = 32
    tracks = 1024

    format = "4mb-hd"

    partitionSize = sectorSize * sectorsPerTrack * tracks
    diskSize = partitionSize * partitions
    print(f"Partition size: {partitionSize} bytes")
    print(f"Disk size: {diskSize} bytes")

    print(f"Formatting a {partitions} partition image -> {image}")
    os.system(f"mkfs.cpm -f 4mb-hd {image}")
    os.system(f"truncate -s 4M {image}")
    os.system(f"cpmcp -T raw -f {format}-{partition} {image} cpm68k_{version}/ALL/* 0:")
    os.system(f"mv {image} {image.replace('IMG', 'CPM')}")
#for n in range(partitions):
#   label = f"Partition: {n}\x0aCreated:   {date}\x0a\x1a"
#   flabel = open("label.txt", "wt")
#   flabel.write(label)
#   flabel.close()
#   print(f"{n} {image}")
#   os.system(f"cpmcp -T raw -f {format} {image} label.txt 0:")
#   flist = glob.glob("D1/*")
#   files = " ".join(flist)
#   os.system(f"cpmcp -T raw -t -f {format} {image} {files} 0:")
   
#cpmls -f 4mb-hd cpm13.img 0:
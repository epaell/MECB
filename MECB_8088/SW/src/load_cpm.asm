; In monitor:
; BS 0041
; CR CS 0041
; L
; G 2500
;
; Loading of CPM.H86 binary data
; Code segment usage:
; 0x0000-0040
; 0x008B-07FC
; 0x0A30-0A3E
; 0x0A40-0A4E
; 0x0A80-0AF6
; 0x0B00-21F8
; Data segment usage:
; 0x0800-0814
; 0x0930-0938
; 0x093A-09F1
; 0x09F6-09F9
; 0x0A00-0A17
; 0x0A50-0A5D
; 0x0A60-0A6C
; 0x2200-220B
; 0x22D4-236A
; 0x2393-23C5
; 0x2494-249E
; 0x24A0-24BC
; 0x24C8-24C8
; 0x24E0-24E1
; 0x24FA-24FA
;
; CPM.SYS differs in first four bytes and has E92A03E9 instead of 00001896
; It also has it's own BIOS appended at the end starting at 2500h

         cpu   8086
;
%include 'src/mecb.inc'
%include 'src/libfujinet.inc'
;
%macro   dumpc 1
         push  ax
         mov   al,%1
         call  outch1
         pop   ax
%endmacro
;
;%define     DEBUG
CCP_SIZE    equ   0b00h    ; length of CCP part of CP/M - 2.75K CCP
BDOSINT     equ   224      ; reserved BDOS software interrupt "call"
BDOS_SIZE   equ   1d00h    ; length of BDOS for this use - 7.25K BDOS
SYSSEG      equ   410h/16  ; System segment for CP/M-86 (BS=0041h)
DISK_COUNT  equ   8
DPH_LEN     equ   dpHdr1-dpHdr0
;
ccp         equ   0
warm_ccp    equ   ccp+6
bdos        equ   0b00h
bdosvec     equ   bdos+6
;
            org   2500h
;
section     .text
;
; CBIOS operating address - starts at 2500h, fixed function vectors.
; Function vectors are 3 byte jumps, and cannot be relocated or altered.
;
bios:       jmp   near init             ; 00 +00h Cold boot: sign-on, initialize all I/O devices
            jmp   near wboot             ; 01 +03h Warm boot: flush any unwritten disk records
            jmp   near constat           ; 02 +06h Console status (of input character ready)
            jmp   near conin             ; 03 +09h Console input character
            jmp   near conout            ; 04 +0Ch Console output character
            jmp   near listout           ; 05 +0Fh List output character
            jmp   near auxout            ; 06 +12h Auxilary (formerly Punch) output character
            jmp   near auxin             ; 07 +15h Auxilary (formerly Reader) input character
            jmp   near home              ; 08 +18h Set track to zero after flushing host buffer
            jmp   near seldsk            ; 09 +1Bh Select drive unit, determine disk type
            jmp   near settrk            ; 10 +1Eh Set track number
            jmp   near setsec            ; 11 +21h Set sector number
            jmp   near setdma            ; 12 +24h Set Direct Memory Address
            jmp   near read              ; 13 +27h Read record (sector) from disk
            jmp   near write             ; 14 +2Ah Write record into sector buffer or onto disk
            jmp   near listst            ; 15 +2Dh List status (output transmission ready)
            jmp   near sectrn            ; 16 +30h Translate logical to physical sector number
            jmp   near setxad            ; 17 +33h Set extended address to segment value
            jmp   near getmrt            ; 18 +36h Return base address of the memory region table
            jmp   near getiob            ; 19 +39h Get value of local I/O BYTE (and IOCNTL)
            jmp   near setiob            ; 20 +3Ch Set value of local I/O BYTE (direction control)
J_CPM:      jmp   SYSSEG:0h         ;    +3Fh Long Jump to re-establish CP/M, MP/M operation
;            db    0eah              ; long jump
;            dw    0,SYSSEG          ; to base of segment automatically at cold start
;
;-------------------------------
; Warm boot routine.
wboot:
%ifdef DEBUG
            push  si
            mov   si,str_func01
            call  print
            pop   si
            call  dump_reg
%endif
            call  home              ; ensure write buffer flush
            jmp   warm_ccp          ; return to CP/M skipping the autovector

%ifdef DEBUG
;
; trap for bdos call to debug what is being called
;
bdostrap:
            push  si
            push  cx
            push  ax
            mov   si,sbdostrap      ; print message
            call  print
            mov   al,cl
            call  out2h
            mov   al,'h'
            call  outch1
            mov   al,' '
            call  outch1
            mov   si,bdostable
            mov   ah,0
            mov   al,cl
            shl   ax,1
            shl   ax,1
            shl   ax,1
            add   si,ax
            call  print
            mov   si,sp
            mov   ax,[si+6]
            call  out4h
            mov   al,' '
            call  outch1
            mov   ax,[si+8]
            call  out4h
            mov   al,' '
            call  outch1
            mov   ax,[si+10]
            call  out4h
            mov   al,' '
            call  outch1
            mov   ax,[si+12]
            call  out4h
            call  pcrlf
            pop   ax
            pop   cx
            pop   si
            call  dump_reg          ; dump registers
            jmp   0041h:bdosvec     ; continue on by calling the actual bdos service

sbdostrap:  db    CR,LF,"BDOS int e0h cl=",EOT
bdostable   db    'MSYRST ',EOT ; cl = 00h = 00
            db    'MCONIN ',EOT ; cl = 01h = 01
            db    'CONOUT ',EOT ; cl = 02h = 02
            db    'MREDER ',EOT ; cl = 03h = 03
            db    'VPUNCH ',EOT ; cl = 04h = 04
            db    'BLIST  ',EOT ; cl = 05h = 05
            db    'MDCNIO ',EOT ; cl = 06h = 06
            db    'MGTIOB ',EOT ; cl = 07h = 07
            db    'MSTIOB ',EOT ; cl = 08h = 08
            db    'MBUFPR ',EOT ; cl = 09h = 09
            db    'MRDCBF ',EOT ; cl = 0ah = 10
            db    'MCONST ',EOT ; cl = 0bh = 11
            db    'MRTVNO ',EOT ; cl = 0ch = 12
            db    'MRSDSY ',EOT ; cl = 0dh = 13
            db    'MSELDK ',EOT ; cl = 0eh = 14
            db    'MOPEN  ',EOT ; cl = 0fh = 15
            db    'MCLOSE ',EOT ; cl = 10h = 16
            db    'MSRCHF ',EOT ; cl = 11h = 17
            db    'MSRCHN ',EOT ; cl = 12h = 18
            db    'MDELET ',EOT ; cl = 13h = 19
            db    'MREADS ',EOT ; cl = 14h = 20
            db    'MWRITS ',EOT ; cl = 15h = 21
            db    'MMAKE  ',EOT ; cl = 16h = 22
            db    'MRENAM ',EOT ; cl = 17h = 23
            db    'MRTLIV ',EOT ; cl = 18h = 24
            db    'MRTCDK ',EOT ; cl = 19h = 25
            db    'MSTDMO ',EOT ; cl = 1ah = 26
            db    'MGTALM ',EOT ; cl = 1bh = 27
            db    'MWPDSK ',EOT ; cl = 1ch = 28
            db    'MGTROV ',EOT ; cl = 1dh = 29
            db    'MSTFAT ',EOT ; cl = 1eh = 30
            db    'MGDPBA ',EOT ; cl = 1fh = 31
            db    'MSTUCD ',EOT ; cl = 20h = 32
            db    'MREADR ',EOT ; cl = 21h = 33
            db    'MWRITR ',EOT ; cl = 22h = 34
            db    'MCMPFS ',EOT ; cl = 23h = 35
            db    'MSTRRC ',EOT ; cl = 24h = 36
            db    'MRSTDV ',EOT ; cl = 25h = 37
            db    'NOPROC ',EOT ; cl = 26h = 38
            db    'NOPROC ',EOT ; cl = 27h = 39
            db    'MWRITZ ',EOT ; cl = 28h = 40
            db    'NOPROC ',EOT ; cl = 29h = 41
            db    'NOPROC ',EOT ; cl = 2ah = 42
            db    'NOPROC ',EOT ; cl = 2bh = 43
            db    'NOPROC ',EOT ; cl = 2ch = 44
            db    'NOPROC ',EOT ; cl = 2dh = 45
            db    'NOPROC ',EOT ; cl = 2eh = 46
            db    'MCHAIN ',EOT ; cl = 2fh = 47
            db    'MFLUSH ',EOT ; cl = 30h = 48
            db    'MGTSAD ',EOT ; cl = 31h = 49
            db    'MDBIOS ',EOT ; cl = 32h = 50
            db    'MSTDMS ',EOT ; cl = 33h = 51
            db    'MGTDMS ',EOT ; cl = 34h = 52
            db    'MGTMXM ',EOT ; cl = 35h = 53
            db    'MGTAMX ',EOT ; cl = 36h = 54
            db    'MALMEM ',EOT ; cl = 37h = 55
            db    'MALAME ',EOT ; cl = 38h = 56
            db    'MFRMEM ',EOT ; cl = 39h = 57
            db    'MFRALM ',EOT ; cl = 3ah = 58
            db    'MLOADP ',EOT ; cl = 3bh = 59
%endif

;
;  CONSOLE STATUS INPUT ROUTINE:
;
; Exit:  AL = 0 (zero), means no character currently ready to read.
;        AL = FFh (255), means character currently ready to read.
; IOBYTE selects device to use as follows:
; 0 = TTY:,	1 = CRT:,	2 = BAT:,	3 = UC1:
;    USER 6	    xxx		    xxx		   USER 7
; -----	If CRT, secondary select done using IOCNTL byte:
; 0 = USER 0,	1 = SysSup 1,	2 = IF1P0,	3 = Custom.
; -----	If BAT, secondary select done using READER of IOBYTE:
; 0 = USER 0	1 = USER 1,	2 = USER 2,	3 = USER 3
;
constat:
%ifdef DEBUGX
            push  si
            mov   si,str_func02
            call  print
            pop   si
            call  dump_reg
%endif
            in    al,ACIA1_STATUS   ; Read the ACIA status
            and   al,01h
            jz    .1
            or    al,0ffh           ; Yes, character available
.1:         ret

;  CONSOLE DATA INPUT ROUTINE:
;
; Read the next character into the AL register, clearing
; the high order bit.  If no character currently ready to
; read then wait for a character to arrive before returning.
;
; IOBYTE selects device to use as follows:
; 0 = TTY:,	1 = CRT:,	2 = BAT:,	3 = UC1:
;    USER 6	    xxx		    xxx		   USER 7
;-----	If CRT, secondary select done using IOCNTL byte:
; 0 = USER 0,	1 = SysSup 1,	2 = IF1P0,	3 = Custom.
;-----	If BAT, secondary select done using READER of IOBYTE:
; 0 = USER 0	1 = USER 1,	2 = USER 2,	3 = USER 3
;
; Exit:  al = Character read from terminal.
;
conin:
%ifdef DEBUGX
            push  si
            mov   si,str_func03
            call  print
            pop   si
            call  dump_reg
%endif
.1:
            call  constat
            jz    .1
            in    al,ACIA1_DATA
            and   al,7fh
            ret
            
;  CONSOLE DATA OUTPUT ROUTINE:
;
; Send a character to the console.  If the console is not ready
; to output a character, wait until it is, then do transmission.
;
; IOBYTE selects device to use as follows:
; 0 = TTY:,	1 = CRT:,	2 = BAT:,	3 = UC1:
;    USER 6	    xxx		    xxx		   USER 7
;-----	If CRT, secondary select done using IOCNTL byte:
; 0 = USER 0,	1 = SysSup 1,	2 = IF1-P0,	3 = Custom.
;-----	If BAT, secondary select done using PUNCH of IOBYTE:
; 0 = USER 0	1 = USER 1,	2 = USER 2,	3 = USER 3
;
; Entry: cl = ASCII character to output to console.
;
conout:
%ifdef DEBUG
            push  si
            mov   si,str_func04
            call  print
            pop   si
            call  dump_reg
%endif
            push  ax
.1:
            in    al,ACIA1_STATUS
            and   al,02h
            jz    .1
            mov   al,cl
            out   ACIA1_DATA,al
            pop   ax
            ret
            
;  OUTPUT CHARACTER TO LIST LOGICAL DEVICE:
;
; Send a character to the list device.  If the list device is not
; ready to receive a character wait until the device is ready.
;
; IOBYTE selects device to use as follows:
; 0 = TTY:,	1 = CRT:,	2 = LPT:,	3 = UL1:
;    USER 6	    xxx		    xxx		   USER 5.
;-----	If CRT, secondary select done using IOCNTL byte:
; 0 = USER 0,	1 = SysSup 1,	2 = IF1-P0,	3 = Custom.
;-----	If LPT, secondary select done using IOCNTL byte:
; 0 = USER 4	1 = IF1-P1,	2,3 = Custom.
;
; Entry: CL = ASCII character to be output.
;
listout:
%ifdef DEBUG
            push  si
            mov   si,str_func05
            call  print
            pop   si
            call  dump_reg
%endif
            ret
            
;
;  AUXILARY LOGICAL DEVICE CHARACTER OUTPUT ROUTINE:
;
; Send a character (8 bits) to the selected auxilary (formerly Punch) device.
;
; IOBYTE selects device to use as follows:
; 0 = TTY:,	1 = PTP:,	2 = UP1:,	3 = UP2:
;    USER 6	   USER 1	   USER 2	   USER 3
;
; Entry:  cl = ASCII character or byte to output.
;
auxout:
%ifdef DEBUG
            push  si
            mov   si,str_func06
            call  print
            pop   si
            call  dump_reg
%endif
            ret
            
;
;  AUXILARY LOGICAL DEVICE DATA INPUT ROUTINE:
;
; Read the next character from the currently assigned auxilary character input
; (formerly Reader) device into the "AL" register, no parity bit is stripped.
;
; IOBYTE selects device to use as follows:
; 0 = TTY:,	1 = PTP:,	2 = UP1:,	3 = UP2:
;    USER 6	   USER 1	   USER 2	   USER 3
;
;Exit:   al = Character read from the auxilary input device.
;
auxin:
%ifdef DEBUG
            push  si
            mov   si,str_func07
            call  print
            pop   si
            call  dump_reg
%endif
            ret
            
;
;	HOME ROUTINE:
;
; Return disk to home.  This routine sets the track number to zero.
; The current host disk buffer is flushed to the disk, and made inactive.
;
home:
%ifdef DEBUG
            push  si
            mov   si,str08
            call  print
            pop   si
            call  pcrlf
%endif

            push  ax
            xor   ax,ax
            mov   [selTrack],ax
            pop   ax
            ret
;
%ifdef DEBUG
str08:      db 'HOME:',CR,LF,EOT
%endif

;
;	SELECT DISK DRIVE:
;
; Select the disk drive for subsequent disk transfers and return the
; appropriate DPB address.   This routine diverges from the normal CP/M
; implementation of just saving the disk selection value until the
; transfer is performed.  This divergence is required because floppy
; disks are a removable media and come in more than on format.  This
; routine determines the correct format and initializes the DPH with
; the appropriate values in agreement with the format type.
;
;Entry:  cl = Disk selection value.
;        dx and 1       = 0, ==> Must determine disk type,
;        else	         = 1, ==> Drive type has been determined.
;
;Exit:   bx = 0,  If drive not selectable,
;        bx =     DPH address if drive is selectable, and is initialized for the
;                 appropriate floppy disk format if DX = 0,
;                 else the DPH pointed to contains data about the last disk accessed.
;
seldsk:
%ifdef DEBUG
            push  si
            push  ax
            mov   si,str09
            call  print
            mov   ax,cx
            call  out4h
            mov   si,strdx
            call  print
            mov   ax,dx
            call  out4h
            pop   ax
            pop   si
%endif

            mov   bx,0              ; prepare for invalid disk
            mov   ch,0              ; clear upper byte
            and   cl,15             ; clean up in case upper bits are dirty
            cmp   cl,DISK_COUNT     ; is it a valid disk
            ja    .2                ; if not, exit
            mov   [selDrive],cl     ; save the selected disk
            mov   bx,cx             ; bx = drive number
            mov   cl,4
            shl   bx,cl             ; bx *= 16 (offset into DPH for that drive)
            mov   cx,dpHdr0
            add   bx,cx             ; bx points to the DPH
.2:

%ifdef DEBUG
            push  si
            push  ax
            mov   si,strbx
            call  print
            mov   ax,bx
            call  out4h
            pop   ax
            pop   si
            call  pcrlf
%endif
            ret
;
%ifdef DEBUG
str09:      db    'SELDSK: CX=',EOT
strbx:      db    ' BX=',EOT
strdx:      db    ' DX=',EOT
%endif

;
;  SET TRACK ROUTINE:
;
; Set track number.  The track number is saved for later use during
; a disk transfer operation.
;
;Entry:  cx = Track number.
;
settrk:
%ifdef DEBUG
            push  si
            mov   si,str10
            call  print
            pop   si
            push  ax
            mov   ax,cx
            call  out4h
            pop   ax
            call  pcrlf
%endif
            mov   [selTrack],cx      ; Sector to seek
            ret
;
%ifdef DEBUG
str10:      db    'SETTRK: ',EOT
%endif

;
;  SET SECTOR ROUTINE:
;
; Set the sector for later use in the disk transfer.  No
; actual disk operations are perfomed.
;
;Entry:  cx = sector number (sometimes "CH" contains an invalid number
;        if less than 256 sectors used for selected drive).
;
setsec:
%ifdef DEBUG
            push  si
            mov   si,str11
            call  print
            pop   si
            push  ax
            mov   ax,cx
            call  out4h
            pop   ax
            call  pcrlf
%endif
            xor   ch,ch
            mov   [selSector],cl      ; Sector to seek
            ret

%ifdef DEBUG
str11:      db    'SETSEC: ',EOT
%endif

;
;  SET DIRECT MEMORY ACCESS (Lower 2 bytes):
;
; Set Direct Memory Address (DMA) for subsequent disk read or
; write routines.  This is the place the actual requested 128
; byte record (CP/M 1.4 sector) goes.
;
;Entry:  cx = Disk memory address.
;
setdma:
%ifdef DEBUG
            push  si
            mov   si,str12
            call  print
            pop   si
            push  ax
            mov   ax,cx
            call  out4h
            pop   ax
            call  pcrlf
%endif

            mov   [dma],cx
            ret

%ifdef DEBUG
str12:      db    'SETDMA: ',EOT
%endif

;
;  READ SECTOR ROUTINE:
;
; Read a CP/M 128 byte sector (also known as a "record").
;
; Exit:  AL = 0, Z flag set for successful read operation.
;        AL = non-zero value if unsuccessful read operation.
;
read:

%ifdef DEBUG
            push  si
            mov   si,str13
            call  print
            pop   si
            push  ax
            mov   al,[selDrive]
            call  out2h
            mov   al,':'
            call  outch1
            mov   ax,[selTrack]
            call  out4h
            mov   al,':'
            call  outch1
            mov   ax,[selSector]
            call  out4h
            mov   al,'>'
            call  outch1
            mov   ax,[dmaseg]
            call  out4h
            mov   al,':'
            call  outch1
            mov   ax,[dma]
            call  out4h
            pop   ax
%endif

            push  si
            push  bx
            push  cx
            mov   si,fujinet_dcb          ; point to the DCB
            mov   ax,[dma]                ; set up where to store the sector
            mov   [SI+DCB_RX_BUFFER],ax
            mov   [SI+DCB_TX_BUFFER],ax
            mov   ax,[dmaseg]
            mov   [SI+DCB_RX_BUFFERSEG],ax
            mov   [SI+DCB_TX_BUFFERSEG],ax
            mov   bx,[selTrack]
            xor   cx,cx
            mov   cl,5
            shl   bx,cl                   ; Track * 32 Sec/Track (should really read this from disk tables)
            add   bx,[selSector]          ; Add the sector
            mov   ah,[selDrive]           ; Set up the drive
;
%ifdef DEBUG
            push  ax
            mov   al,'='
            call  outch1
            mov   ax,bx
            call  out4h
            pop   ax
%endif
            
            call  fujinet_disk_read       ; Read the disk

%ifdef DEBUG
            push  ax
            mov   al,' '
            call  outch1
            mov   al,'R'
            call  outch1
            mov   al,'='
            call  outch1
            pop   ax
            call  out2h
            call  pcrlf
%endif
            
            pop   cx
            pop   bx
            pop   si
            and   ax,0ffh                 ; Mask off any garbage
            ret
;
%ifdef DEBUG
str13:      db    'READ: ',EOT
%endif

;
;  WRITE SECTOR ROUTINE:
;
; Write the selected 128 byte CP/M sector.
;
;Entry:  CL = 0, write to a previously allocated block.
;        CL = 1, write to the directory.
;        CL = 2, write to the first sector of unallocated data block.
;
;Exit:   AL = 0, Z-flag set for successful write operation.
;        AL = non-zero value if unsucessful write operation.
;
write:      
%ifdef DEBUG
            push  si
            mov   si,str_func14
            call  print
            pop   si
            call  dump_reg
%endif

            push  si
            push  bx
            push  cx
            mov   si,fujinet_dcb          ; point to the DCB
            mov   ax,[dma]                ; set up where to store the sector
            mov   [SI+DCB_RX_BUFFER],ax
            mov   [SI+DCB_TX_BUFFER],ax
            mov   ax,[dmaseg]
            mov   [SI+DCB_RX_BUFFERSEG],ax
            mov   [SI+DCB_TX_BUFFERSEG],ax

            mov   bx,[selTrack]
            xor   cx,cx
            mov   cl,5
            shl   bx,cl                   ; Track * 32 Sec/Track (should really read this from disk tables)
            add   bx,[selSector]          ; Add the sector
            mov   ah,[selDrive]           ; Set up the drive
            call  fujinet_disk_write
            and   al,0ffh                 ; Mask off any garbage
            pop   cx
            pop   bx
            pop   si
            and   ax,0ffh                 ; Mask off any garbage
            ret
            
listst:
%ifdef DEBUG
            push  si
            mov   si,str_func15
            call  print
            pop   si
            call  dump_reg
%endif
            ret
            
;
;	SECTOR TRANSLATION ROUTINE:
;
; Translate sector number from logical to physical.
;
;Entry:  dx = 0, then no translation required,
; else:  dx = translation table address and
;        cx = sector number to translate.
;
;Exit:	BX = translated sector number (this will always be less than 256 in
;	     this CBIOS due to some anomalies in the way the "BH" register
;	     is handled by some programs or perhaps CP/M as well).
sectrn:     
%ifdef DEBUG
            push  si
            mov   si,str16
            call  print
            pop   si
            push  ax
            mov   ax,cx
            call  out4h
            mov   al,'+'
            call  outch1
            mov   ax,dx
            call  out4h
            pop   ax
            call  pcrlf
%endif

            mov   bx,cx          ; put sector offset in "BX" to translate
;            or    dx,dx          ; see if translation table address is zero
;            jz    .1             ; done if so
;            add   bx,dx          ; add sector offset to table base
;            mov   bl,[bx]        ; get sector translated into "BL"
            mov   bh,0           ; zero upper byte of sector number
.1:         ret
;
%ifdef DEBUG
str16:      db    'SETTRN: ',EOT
%endif

;
;  SET DIRECT MEMORY ACCESS SEGMENT ( of 24 bit address):
;
; Set extended bank address of DMA as above, but contains the "segment"
; offset to use to construct the full 24 bit address from.
;
;Entry:  cx = Segment for extended bank address byte.
;
setxad:
%ifdef DEBUG
            push  si
            mov   si,str17
            call  print
            pop   si
            push  ax
            mov   ax,cx
            call  out4h
            pop   ax
            call  pcrlf
%endif

            mov   [dmaseg],cx
            ret
;
%ifdef DEBUG
str17:      db    'SETXAD: ',EOT
%endif

;
; Get memory segmentation table vector.
;
getmrt:     
%ifdef DEBUG
            push  si
            mov   si,str_func18
            call  print
            pop   si
            call  dump_reg
%endif

            mov   bx,memtbl         ; get base address in "BX"
            ret
;            
getiob:
%ifdef DEBUG
            push  si
            mov   si,str_func19
            call  print
            pop   si
            call  dump_reg
%endif

            ret
            
setiob:
%ifdef DEBUG
            push  si
            mov   si,str_func20
            call  print
            pop   si
            call  dump_reg
%endif

            ret
;
; Unhandled interrupt handler.
;
itrap:      cli                     ; clear all interrupt sources
            call  dump_reg
            call  print
            pop   ax                ; take IP off the stack
            call  out4h
            mov   si,stcs
            call  print
            pop   ax                ; take CS off the stack
            call  out4h
            mov   si,stfr
            call  print
            pop   ax                ; take FR off the stack
            call  out4h
            call  pcrlf
            
            mov   ax,cs             ; get code segment
            mov   ds,ax             ; fix Data Segment to current
            mov   si,trapmsg        ; trapped unhandled interrupt
            call  print             ; print message
            jmp   monitor
;
stip:       db    'IP=',EOT
stcs:       db    ' CS=',EOT
stfr:       db    ' FR=',EOT
;
;************************************************
;*	COLD BOOT INITIALIZATION ROUTINES	*
;************************************************
;
init:       xor   ax,ax                      ; clear ax
            mov   ds,ax                      ; set segment to 0 to access interrupt vectors
            mov   es,ax                      ; 

            cld                              ; clear direction flag
            mov   si,ax
            mov   word ds:[si],itrap         ; set up int 0h to itrap
            mov   ax,SYSSEG
            mov   word ds:[si+2],ax
            mov   di,4
            mov   si,0
            mov   cx,510
            rep   movsw
            
            mov   si,(4*BDOSINT)             ; set up the BDOS vector
%ifdef DEBUG
            mov   word ds:[si],bdostrap
%else
            mov   word ds:[si],bdosvec
%endif
            mov   ax,SYSSEG
            mov   word ds:[si+2],ax
;
            mov   ds,ax                      ; copy across CCP and BDOS into system segment area
;            call  move_system               ; assume CPM is already in memory
            mov   si,signon                  ; show outside world that we're alive
            call  print		                  ; output banner
;
            mov   si,fujinet_dcb             ; Point to the DCB
            mov   di,boot_path
            mov   ax,ds
            mov   [sI+DCB_TX_BUFFERSEG],ax
            mov   [si+DCB_TX_BUFFER],di
            mov   ah,0                       ; Set the first slot to point at the CPM boot disk
            call  fujinet_set_device_fullpath
            cmp   al,FUJINET_RC_OK           ; Check if OK
            jz    .1                         ; If so, attempt mount
            mov   si,strPathFail
            call  print
            jmp   0f000h:0c000h
;
.1:         mov   si,fujinet_dcb
            call  fujinet_mount_all          ; Mount the host slot
            cmp   al,FUJINET_RC_OK           ; Check if OK
            jz    .2                         ; if OK, continue
            mov   si,strMountFail
            call  print
            jmp   0f000h:0c000h
;
.2:         xor   ax,ax
;            jmp   monitor
            mov   cx,ax                      ; user/drive=0
            mov   dx,cs
            mov   ds,dx
            mov   es,dx
            mov   ss,dx
            mov   bp,dx
            mov   [dmaseg],dx
            mov   sp,istack
            jmp   ccp
;
INIT_SS     equ     07000h
INIT_SP     equ     0FFF0h
;
monitor:    cli
            mov   ax, INIT_SS                ; set up the stack
            mov   ss, ax
            mov   sp, INIT_SP                ; Set the stack pointer (SP) to the top of the stack
            mov   ax, INIT_SS                ; Set up segment where monitor variables are kept
            mov   ds, ax                     ; Move the address from AX to DS
            jmp   0f000h:0c107h
;
; Interrupt vector table goes from 00000h-003ffh (256 * 4 bytes)
;
move_system: 
            push  ds
            mov   ax,SYSSEG                  ; start cpm/bios just above interrupt vectors
            mov   es,ax
            mov   ax,0f000h                  ; segment where CPM is stored
            mov   ds,ax
            mov   si,08000h                  ; start location for CPM
            mov   di,00000h                  ; destination location for CPM
            mov   cx,2500h
            rep   movsb                      ; copy CPM to its final location
;
            mov   di,0                       ; overwrite the jump locations at the start of bios
            mov   ax,SYSSEG
            mov   ds,ax
            mov   si,patch
            mov   cx,9
            rep   movsb
;
            pop   ds
            ret
;
; Not sure why these are missing from the start of the original CPM binary data
;
patch       db    0E9h, 2Ah, 03h
            db    0E9h, 21h, 03h
            db    0E9h, 02h, 03h
;
%include 'src/libfujinet.asm'
%include 'src/libfujicmd.asm'
%include 'src/libfujierr.asm'
%include 'src/acia_io.asm'
;
;  INITIALIZED VARIABLES / CONSTANTS
;
;  -------------------------+-------------------
;  MRT:  | Count  | (byte) << MEMORY REGION TABLE STRUCTURE >>
;  -------------------------+-------------------
;   0:   | Base Region Para | Length Paragraph |
;  -------------------------+-------------------
;   1:   | Base Region Para | Length Paragraph |
;  -------------------------+-------------------
;  . . . (word)               (word)
;  -------------------------+-------------------
;   n:   | Base Region Para | Length Paragraph |
;  -------------------------+-------------------
;
memtbl      db    1                          ; number of memory regions allocated
; bios starts at 2500 and is 1800h long - so ends before $4000
; Should be able to have memory start at 0000:4000 i.e. above BIOS and allocation tables
; Length = 80000h available - 8000h for BIOS and 10000h at top for monitor = 68000h or 6800h paragraphs
            dw    1000h,6000h                ; paragraph 0 start, length in paragraphs
;
trapmsg:    db    CR,LF,'Unhandled interrupt',CR,LF,EOT
signon      db    CR,LF,LF,LF
mecb        db    'Digicool MECB '
            db    'CP/M-86 version 1.1'      ; CP/M for 8086 CPU
            db    CR,LF,LF,EOT
strMountFail: db  "Mount failed",CR,LF,0
strPathFail: db   "Failed to set path to boot disk",CR,LF,0
;
str_func01:  db    "BIOS: 01",EOT
str_func02:  db    "BIOS: 02",EOT
str_func03:  db    "BIOS: 03",EOT
str_func04:  db    "BIOS: 04",EOT
str_func05:  db    "BIOS: 05",EOT
str_func06:  db    "BIOS: 06",EOT
str_func07:  db    "BIOS: 07",EOT
str_func14:  db    "BIOS: 14",EOT
str_func15:  db    "BIOS: 15",EOT
str_func16:  db    "BIOS: 16",EOT
str_func17:  db    "BIOS: 17",EOT
str_func18:  db    "BIOS: 18",EOT
str_func19:  db    "BIOS: 19",EOT
str_func20:  db    "BIOS: 20",EOT
boot_path:   db    "/CPM86/CPM11.CPM",EOT
;
;
dma         dw     0          ; dma
dmaseg      dw     0          ; dma segment
selTrack    dw     0          ; track set by settrk
selSector   dw     0          ; sector set by setsec
selDrive    db     0FFh       ; drive set by seldsk
            db     0          ; dummy
;
;-----------------------------------------------------------------------------------------------------
; disk parameter headers
;-----------------------------------------------------------------------------------------------------
;
dpHdr0      dw     0          ; No translation
            dw     0          ; scratchpad 1
            dw     0          ; scratchpad 2
            dw     0          ; scratchpad 3
            dw     dirBuffer  ; ptr to directory buffer
            dw     dpb0       ; ptr to boot disk parameter block
            dw     0          ; ptr to check vector
            dw     allocV0    ; ptr to allocation vector
;
dpHdr1      dw     0          ; No translation
            dw     0          ; scratchpad 1
            dw     0          ; scratchpad 2
            dw     0          ; scratchpad 3
            dw     dirBuffer  ; ptr to directory buffer
            dw     dpb0       ; ptr to disk parameter block
            dw     0          ; ptr to check vector
            dw     allocV1    ; ptr to allocation vector
;
dpHdr2      dw     0          ; No translation
            dw     0          ; scratchpad 1
            dw     0          ; scratchpad 2
            dw     0          ; scratchpad 3
            dw     dirBuffer  ; ptr to directory buffer
            dw     dpb0       ; ptr to disk parameter block
            dw     0          ; ptr to check vector
            dw     allocV2    ; ptr to allocation vector
;
dpHdr3      dw     0          ; No translation
            dw     0          ; scratchpad 1
            dw     0          ; scratchpad 2
            dw     0          ; scratchpad 3
            dw     dirBuffer  ; ptr to directory buffer
            dw     dpb0       ; ptr to disk parameter block
            dw     0          ; ptr to check vector
            dw     allocV3    ; ptr to allocation vector
;
dpHdr4      dw     0          ; No translation
            dw     0          ; scratchpad 1
            dw     0          ; scratchpad 2
            dw     0          ; scratchpad 3
            dw     dirBuffer  ; ptr to directory buffer
            dw     dpb0       ; ptr to disk parameter block
            dw     0          ; ptr to check vector
            dw     allocV4    ; ptr to allocation vector
;
dpHdr5      dw     0          ; No translation
            dw     0          ; scratchpad 1
            dw     0          ; scratchpad 2
            dw     0          ; scratchpad 3
            dw     dirBuffer  ; ptr to directory buffer
            dw     dpb0       ; ptr to disk parameter block
            dw     0          ; ptr to check vector
            dw     allocV5    ; ptr to allocation vector
;
dpHdr6      dw     0          ; No translation
            dw     0          ; scratchpad 1
            dw     0          ; scratchpad 2
            dw     0          ; scratchpad 3
            dw     dirBuffer  ; ptr to directory buffer
            dw     dpb0       ; ptr to disk parameter block
            dw     0          ; ptr to check vector
            dw     allocV6    ; ptr to allocation vector
;
dpHdr7      dw     0          ; No translation
            dw     0          ; scratchpad 1
            dw     0          ; scratchpad 2
            dw     0          ; scratchpad 3
            dw     dirBuffer  ; ptr to directory buffer
            dw     dpb0       ; ptr to disk parameter block
            dw     0          ; ptr to check vector
            dw     allocV7    ; ptr to allocation vector
;
; Data Allocation Block Size (BLS) as determined by BSH and BLM
; BLS   BSH  BLM
; 1024    3    7
; 2048    4   15
; 4096    5   31
; 8192    6   63
; 16384   7  127
;
; for BLS=2048 need BSH=04h; BLM=0fh
;
; Maximum EXM values
;
; BLS    DSM<256  DSM>255
; 1024      0        N/A
; 2048      1         0
; 4096      3         1
; 8192      7         3
; 16384     15        7
;
; for BLS=2048 and DSM=2047; EXM = 0
;
; BLS * (DSM+1) = total storage space on drive in bytes
; 2048 * 2048 = 4,194,304 bytes (4 MB)
;
; DRM = directory entries - 1
;
; AL0 and AL1 form a 16-bit bit mask
; - each bit reserves a data block for a number of directory entries
;   i.e. up to 16 blocks. Each directory entry occupies 32 bytes
;
; BLS and number of directory entries
;
; BLS    Directory entires
; 1024      32 times # bits
; 2048      64 times # bits
; 4096     128 times # bits
; 8192     256 times # bits
; 16384    512 times # bits
;
; for DRM=255 (256 entries), and BLS=2048 there are 64 directory entries per block
; so require 4 reserved blocks (256 / 64) = 8192 bytes = 64 sectors = 2 track. So 4 high order bits of AL0 are set.
;
dpb0        dw     32         ; SPT - sectors per track
            db     04h        ; BSH - the data allocation block shift factor, determined by the data block allocation size
            db     0fh        ; BLM - the block mask which is determined by the data block allocation size
            db     0          ; EXM - the extent mask, determined by the data block allocation size and the number of disk blocks
            dw     2047       ; DSM - determines the stotal storage capacity of the disk drive
            dw     0ffh       ; DRM - detmines the total number of directory entries which can be stored on this drive
            db     0f0h       ; AL0 - dir blk bit map, first byte - determines reserved directory blocks
            db     00h        ; AL1 - dir blk bit map, second byte - determines reserved directory blocks
            dw     0          ; CKS - the size of the directory check vector = 256 / 4
            dw     0          ; OFF - the number of reserved tacks at the beginning of the (logical) disk
;
section  .bss
;
fujinet_dcb resb   DCB_SIZE
dirBuffer   resb   128        ; directory buffer
;
cks0        resb   64
cks1        resb   64
cks2        resb   64
cks3        resb   64
cks4        resb   64
cks5        resb   64
cks6        resb   64
cks7        resb   64
;
; ALV size = (DSM/8)+1 = 2048/8
allocV0     resb   256       ; allocation vector
allocV1     resb   256       ; allocation vector
allocV2     resb   256       ; allocation vector
allocV3     resb   256       ; allocation vector
allocV4     resb   256       ; allocation vector
allocV5     resb   256       ; allocation vector
allocV6     resb   256       ; allocation vector
allocV7     resb   256       ; allocation vector
;
stack       resb   256
istack:

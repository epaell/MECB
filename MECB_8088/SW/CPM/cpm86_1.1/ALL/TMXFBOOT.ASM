; LAST UPDATED:		14 FEB 84
; REASON FOR UPDATE: Redone to boot up CP/M 86 or MP/M 8-16 w/ a CPU 8085/88
;                                                                       llo
;  	Reorganized structure of BOOT and BIOS routines so that
;		a portion of the cold boot initialization takes place in the
;		boot loader.  This facilitates modification of Input/Output
;		initialization by placing the most common tables in a smaller
;		program and at fixed locations.				aep
;
; PROGRAM NAME:		xxxFBOOT.ASM, where "xxx" identifies the relationship
;		of the revision level to it's corresponding BIOS source.
;
; PURPOSE:	Floppy Disk (either 8 inch or 5 1/4 inch drives) boot loader
;		for CP/M or MP/M.
;
;	==========================	Copyright 1982, CompuPro Corporation,
;	||			||	A Godbout Company
;	||  FLOPPY BOOT LOADER	||	Hayward, CA 94545
;	||			||
;	==========================
;
;	This product is a copyright program product of CompuPro and is
;	supplied for use with the CompuPro Disk controllers.
FALSE	EQU	0
TRUE 	EQU  not FALSE
;
; ACTIVE CONSTANTS:
BOOT8X	EQU	TRUE	;True to boot off of an 8" disk
BOOT5X	EQU	not BOOT8X ;True to boot from a 5.25" disk
;
STEPR8	EQU	3	;Drive step rate in milliseconds
ULOAD8	EQU	240	;Drive Head unload time
HDLT8	EQU	35	;Drive Head load time
;
STEPR5	EQU	3	;Drive step rate in milliseconds
ULOAD5	EQU	240	;Drive Head unload time
HDLT5	EQU	15	;Drive Head load time
;
SRT8	EQU	16-STEPR8 ;15 count max allowed
HUT8	EQU	ULOAD8/16
;
SRT5	EQU	(33-STEPR5)/2 ;15 count max allowed
HUT5	EQU	ULOAD5/16
;
; EQUATEÄ CONSTANTS
;
SWAPP	EQU	0FDH	;CPU 8085/88 swap port (memory manager)
;
FD8PORT	EQU	0C0H	;8 inch floppy disk controller base port  
FD5PORT	EQU	0CCH	;5.25 inch floppy disk controller base port  
FDCS	EQU	0	;Status register offset
FDCD	EQU	1	;Data register offset
FDMA	EQU	2	;DMA address offset (when written)
INTS	EQU	2	;Status register offset (when read)
FDON	EQU	3	;Motor on/off control port
;
FD$EOC	EQU	1000$0000B
;
XFER	EQU	400H	;Transfer point for the 8088
I$JMPL	EQU	0EAH 	;Long jump for 8086
WAIT85	EQU	0F940H	;Location where the 8085 should wait in CP/M 8-18 $ MP/M 8-16
IN85	EQU	0DBH	;8085 input instruction
;
LDRBIOS	EQU	1200H	;Offset into loader for BIOS
BOOTSW	EQU	40H
;
;
    if BOOT5X		;If 5 1/4 inch drive used during cold boot 
FDPORT	EQU	FD5PORT	;Normal controller port is 5 1/4 inch
FDXPORT	EQU	FD8PORT	;Auxiliary controller port is 8 inch
    endif
    if BOOT8X
FDPORT	EQU	FD8PORT	;Defaults to using 8 inch controller to boot
FDXPORT	EQU	FD5PORT	;Auxiliary controller port is 5 1/4 inch
    endif
;
; PROGRAM:
	ORG	100h		;Base address of bootstrap load
;
;********************************************************
;*	CHARACTER INPUT / OUTPUT INITIALIZATION		*
;********************************************************
;
;Entry:	C = Board switches from ROM (0 .. 3)
;
START:	LXI	SP,100h		;Initialize top of stack
	MOV	A,C		;Save board options (boot switch selected)
	STA	BOOTSW		;In CBIOS reserved area at low memory
;
;************************************************
;*	BOOTSTRAP LOAD FROM FLOPPY DISK		*
;************************************************
;
; Load Specify Command for boot controller (usually 8 inch) floppy drives.
SPECIFY:LXI	H,SPEC		;Start of specification table
	MVI	B,3		;3 Byte length in "B"
	CALL	PUTDATA		;Put specification in boot controller
;
;
; The drive is already known to be positioned on track 0 (done to load this
; routine), and therefore a seek is not necessary.  The routine will loop on
; error back to this point.
;
RETRY:	LXI	H,DATA		;DMA data pointer
	CALL	READ$DISK	;Read in LOADER group header (sector 26)
	JNZ	RETRY		;Loop on error to re-issue command
	PUSH	H		;Save FDC command DMA pointer
	MVI	A,I$JMPL	;Put 8086 long jump into transfer point
	STA	XFER		;Save JUMP instruction in memory
	LXI	H,LDRBIOS	;Get offset into loader of bios
	SHLD	XFER+1		;Save offset in transfer point
	LHLD	BUF+3		;Get loader segment
	SHLD	XFER+3		;Save new segment in transfer point
	LXI	B,LDRBIOS/16	;Get BIOS offset in paragraphs
	DAD	B		;Add BIOS start paragraph to LOADER segment
	MOV  A,L ! ANI 0FH 	;Isolate lowest nibble of load address
	RAR ! RAR ! RAR ! RAR	;Multiply lowest nibble * 16 to get paragraph
	STA	LDRDMA+2	;Save lowest nibble in read command	
	MOV	A,H ! ANI 0F0H	;
	RAR ! RAR ! RAR ! RAR	;Multiply highest nibble * 16 to get paragraph
	STA	LDRDMA+0	;Save highest nibble in read command
	DAD H   !   DAD H 
	DAD H   !   DAD H 	;* 4
	MOV	A,H		;Get middle byte
	STA	LDRDMA+1	;Save middle byte in read command
	POP	H		;Recover Command DMA pointer
	CALL	READ$DISK	;Read the loader bios directly into its load address
	JNZ	RETRY
	CALL	READ$DISK	;Re-read sector 2 into the 8088's highest RAM
	JNZ	RETRY		;Loop on error to re-issue both read commands
	LXI	H,(SWAPP * 256) + IN85 ;Put "IN" instruction and memory manager port
	SHLD	WAIT85		;At 8085's wait point
	JMP	WAIT85		;And go wait there
;
;****************************************************************
;*	LOAD DMA REGISTERS AND EXECUTE FLOPPY READ COMMAND	*
;****************************************************************
;
READ$DISK:  ; Output beginning DMA address.
	MVI	B,3		;3 Bytes of DMA data
ADDR:	MOV	A,M		;Get byte of extended address
	OUT	FDPORT+FDMA	;Send to DMA port of DISK 1
	INX	H		;Next byte to xfer
	DCR	B		;Bump count
	JNZ	ADDR		;Loop until all 3 bytes loaded
;
; Read the remainder of track 0 in as the CBIOS to execute the cold boot.
	MVI	B,9		;Load "B" with command length (9 Bytes)
	CALL	PUTDATA		;Wait until controller ready to accept data
READ1:	IN	FDPORT+INTS	;See if interrupt active (command complete)
	ORA	A
	JP	READ1		;Loop until so
	CALL	GETDATA		;Get a result status byte from controller
	XRI	40h		;Test for "abnormal ending" status bit only
	MOV	E,A		;Put result in "E"
	CALL	GETDATA		;Get second result status byte from controller
	XRI	FD$EOC		;Flip status of "End Of Cylinder" bit
	MOV	D,A		;Put result in "D"
	MVI	B,7-2		;Count of remaining status bytes (ignored)
READ2:	CALL	GETDATA		;Get next result status byte from controller
	DCR	B		;Bump remaining count
	JNZ	READ2		;Wait until all done
	MOV A,E!  ORA D		;Combine the two significant status bytes
	RET			;Return with zero if successful read operation
;
;
; Routine to load controller with command and data bytes.
PUTDATA:IN	FDPORT+FDCS	;Get controller status
	ORA	A
	JP	PUTDATA		;Wait until controller ready for another byte
	MOV	A,M		;load command byte
	OUT 	FDPORT+FDCD	; to controller
	INX	H		;Point to next byte to load
	DCR	B		;Bump command load count
	JNZ	PUTDATA		;Loop if more bytes to load
	RET			;Return if all data loaded in controller
;
; Routine to get a command result status byte from controller.
GETDATA:IN	FDPORT+FDCS	;See if ready to read status
	ORA	A
	JP	GETDATA		;Wait if not
	IN	FDPORT+FDCD	;Get resulting status of read operation
	RET
;
;************************************************
;*	FIXED STORAGE FOR DISK SPECIFICATIONS	*
;************************************************
;
SPEC:	;	FLOPPY Specification sequences (loaded only once).
    if BOOT5X
	DB  03		;5 1/4 inch drive specifications
	DB  (SRT5 SHL 4) + HUT5
	DB  HDLT5 SHL 1
    endif
    if BOOT8X	
	DB	03		;8 inch drive specifications
	DB	(SRT8 SHL 4) + HUT8
	DB	HDLT8 SHL 1
    endif
;
;************************************************
;*	FIXED STORAGE FOR DISK READ OPERATIONS	*
;************************************************
;
; Function data for controller to boot.
DATA:	DB	0		;Extended Address
ENTRY:	DB	BUF shr 8	;Base address of CBIOS
	DB	BUF and 0FFH
READ:	DB	06		;Read sector(s) command for 8272 controller
	DB	0		;Head select, Drive select = 0
	DB	0		;Cylinder #0
	DB	0		;Head #0
	DB	25		;Starting Record (sector
	DB	0		;"N" parameter (128 byte sectors)
	DB	25		;Read just one sector
	DB	7		;GPL (Gap length)
	DB	128		;DTL (Data length)
;
LDRDMA	DB	0,52H,0		;3 bytes of the DMA to setup for 8088
	DB	6		;Read sector(s) command for 8272 controller
	DB	0		;Head select, Drive select = 0
	DB	0		;Cylinder #0
	DB	0		;Head #0
	DB	5		;Starting Record (sector)
	DB	0		;"N" parameter (128 byte sectors)
	DB	24		;Read entire LDRBIOS
	DB	7		;GPL (Gap length)
	DB	128		;DTL (Data length)
;
;
; Re-read this sector into the memory at 0FFF80h to place the 8088 code for
; a long jump back to 400h, the default run address of the GO86 prom.
;
READ88:	DB	00Fh,0FFh,080h	;3 bytes of the DMA to setup for 8088
	DB	6		;Read sector(s) command for 8272 controller
	DB	0		;Head select, Drive select = 0
	DB	0		;Cylinder #0
	DB	0		;Head #0
	DB	2		;Starting Record (sector)
	DB	0		;"N" parameter (128 byte sectors)
	DB	2		;Read just a single sector
	DB	7		;GPL (Gap length)
	DB	128		;DTL (Data length)
;
	PAGE
;************************************************
;*	STORAGE "LONG JUMP" FOR 8088		*
;************************************************
	ORG	1F0h		;Place in the last 16 bytes of last sector
	DB	0EAh		;Long jump instruction
	DW	0400h,0000h	;Segment at 0 hex, offset 400h (000400h)
	DB	90h,90h,90h	;Fill out remainder with 8088 NOP instructions
;
BUF	DS	128		;Buffer to read the group header into
FILL	DS	380H-FILL-1	;Fill out for LOADER image	
	DB	0
	END

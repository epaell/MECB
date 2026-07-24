         include  "mecb.inc"
         include  "tutor.inc"
         include  "libfujinet.inc"
         include  "library_rom.inc"

;
cpm_cold    equ      $015000
_ccp        equ      $0150BC
;
DISK_COUNT  equ      4
DPH_LEN     equ      26
;
;-----------------------------------------------------------------------------

            org      $01B000
;
_init       move.w   #$2700,sr
            move.l   #strInit,a0          ; Write a message to indicate start-up.
            jsr      print
;
            move.l   #fujinet_dcb,a0
            jsr      fujinet_mount_all    ; Mount the host slot
            cmp.b    #FUJINET_RC_OK,d0    ; Check if OK
            beq      _init2               ; if not, report error
            move.l   #strMountFail,a0
            jsr      print
_init2
            move.l   #traphndl,VEC_TRAP3  ; Set TRAP #3 handler
            clr.l    d0                   ; Log on disk A, user 0
            rts
;
            org      $01B040
;
            move.l   #$80000,a7           ; set up the stack pointer outside of the CPM area
            move.l   #$15000,a1
            move.l   #1,d0                ; CPM v1.1
            jsr      mv_cpm15000bin       ; copy CPM binary to right location
            jmp      cpm_cold             ; start up CPM

traphndl    cmp.w    #23,d0
            bcc      trapng
            lsl.w    #2,d0
            move.l   biosbase(pc,d0.w),a0 
            jsr      (a0) 
trapng      rte
;
            align    4
;
biosbase    dc.l     _init          ; _init        ; Function 0
            dc.l     warmBoot       ; warmBoot     ; Function 1
            dc.l     conStatus      ; conStatus    ; Function 2
            dc.l     conIn          ; conIn        ; Function 3
            dc.l     conOut         ; conOut       ; Function 4
            dc.l     listOut        ; listOut      ; Function 5
            dc.l     auxOut         ; auxOut       ; Function 6
            dc.l     auxIn          ; auxIn        ; Function 7
            dc.l     diskHome       ; diskHome     ; Function 8
            dc.l     selDisk        ; selDisk      ; Function 9
            dc.l     setTrack       ; setTrack     ; Function 10
            dc.l     setSector      ; setSector    ; Function 11
            dc.l     setDMA         ; setDMA       ; Function 12
            dc.l     read           ; read         ; Function 13
            dc.l     write          ; write        ; Function 14
            dc.l     listStatus     ; listStatus   ; Function 15
            dc.l     secTranslate   ; secTranslate ; Function 16
            dc.l     undefined      ; undefined    ; Function 17
            dc.l     getMemTable    ; getMemTable  ; Function 18
            dc.l     getIOByte      ; getIOByte    ; Function 19
            dc.l     setIOByte      ; setIOByte    ; Function 20
            dc.l     flush          ; flush        ; Function 21
            dc.l     setHandlers    ; setHandlers  ; Function 22

;--------------------------------------------------------------------------------
; Function 1: Warm boot.
;--------------------------------------------------------------------------------
warmBoot    jmp      _ccp

;--------------------------------------------------------------------------------
; Function 2: Console status.
; Is character available? Yes D0 = 1, No D0 = 0
;--------------------------------------------------------------------------------
conStatus   btst.b   #0,ACIA1           ; Read the ACIA status
            beq.s    conStatus1
            move.l   #1,d0              ; Yes, character available
            rts
conStatus1  clr.l    d0                 ; No character availble
            rts

;--------------------------------------------------------------------------------
; Function 3: Read console character
; Wait until a character is available, return in D0
;--------------------------------------------------------------------------------
conIn       bsr      conStatus 
            beq      conIn 
            move.b   ACIA1_DATA,d0 
            and.l    #$7f,d0 
            rts

;--------------------------------------------------------------------------------
; Function 4: Write console character
; Write the character in D1 to the console
;--------------------------------------------------------------------------------
conOut      btst.b   #1,ACIA1             ; Check if transmit register empty
            beq.s    conOut               ; loop back if not empty
            move.b   d1,ACIA1_DATA        ; store in transmit register
            rts

;--------------------------------------------------------------------------------
; Function 5: List character output - Not implemented
;--------------------------------------------------------------------------------
listOut     move.l   a0,-(a7)
            move.l   #str_func5,a0
            jsr      print
            move.l   (a7),a0
            rts

;--------------------------------------------------------------------------------
; Function 6: Auxillary output - Not implemented
;--------------------------------------------------------------------------------
auxOut      move.l   a0,-(a7)
            move.l   #str_func6,a0
            jsr      print
            move.l   (a7),a0
            rts

;--------------------------------------------------------------------------------
; Function 7: Auxillary input - Not implemented
;--------------------------------------------------------------------------------
auxIn       move.l   a0,-(a7)
            move.l   #str_func7,a0
            jsr      print
            move.l   (a7),a0
            rts

;--------------------------------------------------------------------------------
; Function 8: Home disk
;--------------------------------------------------------------------------------
diskHome    clr.w    selTrack 
            rts

;--------------------------------------------------------------------------------
; Function 9: Select disk given by register D1.B
;--------------------------------------------------------------------------------
selDisk     move.l   #0,d0
            and.l    #15,d1            ; clean up in case upper bits are dirty
            cmp.b    #DISK_COUNT,d1
            bpl      sd1
            move.b   d1,selDrive 
            move.b   selDrive,d0 
            mulu.w   #DPH_LEN,d0 
            add.l    #dpHdr0,d0 
sd1         rts

;--------------------------------------------------------------------------------
; Function 10: Set track
;--------------------------------------------------------------------------------
setTrack    move.w   d1,selTrack 
            rts

;--------------------------------------------------------------------------------
; Function 11: Set sector
;--------------------------------------------------------------------------------
setSector   move.w   d1,selSector 
            rts

;--------------------------------------------------------------------------------
; Function 12: Set DMA address
;--------------------------------------------------------------------------------
setDMA      move.l   d1,dma
            rts
;
;--------------------------------------------------------------------------------
; Function 13: Read sector
; Read one sector from requested disk, track, sector to dma address
; Return in D0 00 if ok, else non-zero
;--------------------------------------------------------------------------------
read        movem.l  d1/a0,-(a7)     ; save registers
            move.l   #fujinet_dcb,a0 ; point to the DCB
            move.l   #0,d0
            move.w   selTrack,d0     ;
            lsl.l    #5,d0           ; Track * 32 Sec/Track (should really read this from disk tables)
            add.w    selSector,d0    ; Add the sector
            move.b   selDrive,d1     ; Set up the drive
            move.l   dma,DCB_RX_BUFFER(a0)   ; set up where to store the sector
            move.l   dma,DCB_TX_BUFFER(a0)  ; Set up receive and transmit buffers
            jsr      fujinet_disk_read          ; Read the disk
            and.l    #$ff,d0         ; Mask off any garbage
            movem.l  (a7)+,d1/a0     ; restore registers
            rts

;--------------------------------------------------------------------------------
; Function 14: Write sector
; Write one sector to requested disk, track, sector from dma address
; %D1.W: 0 = Normal write
;        1 = write to a directory sector
;        2 = write to first sector of new block
; Return 0 in %D0 if ok, else non-zero
;--------------------------------------------------------------------------------
write       movem.l  d1/a0,-(a7)
            move.l   #fujinet_dcb,a0 ; point to the DCB
            move.l   #0,d0
            move.w   selTrack,d0     ;
            lsl.l    #5,d0           ; Track * 32 Sec/Track (should really read this from disk tables)
            add.w    selSector,d0    ; Add the sector
            move.b   selDrive,d1     ; Set up the drive
            move.l   dma,DCB_RX_BUFFER(a0)   ; set up where to store the sector
            move.l   dma,DCB_TX_BUFFER(a0)  ; Set up receive and transmit buffers
            jsr      fujinet_disk_write          ; Write to the disk
            and.l    #$ff,d0         ; Mask off any garbage
            movem.l  (a7)+,d1/a0
            rts

;--------------------------------------------------------------------------------
; Function 15: List status
;--------------------------------------------------------------------------------
listStatus  movem.l  a0,-(a7)
            move.l   #str_func15,a0
            jsr      print
            movem.l  (a7)+,a0
            move.b   #255,d0 
            rts

;--------------------------------------------------------------------------------
; Function 16: Sector translate
; Translate sector in d1 with translate table pointed to by d2
;--------------------------------------------------------------------------------
secTranslate:
            move.w   d1,d0 
            rts

;--------------------------------------------------------------------------------
; Function 17: Undefined
;--------------------------------------------------------------------------------
undefined   movem.l  a0,-(a7)
            move.l   #str_func17,a0
            jsr      print
            movem.l  (a7)+,a0
            rts

;--------------------------------------------------------------------------------
; Function 18: Get address of memory regions table
;--------------------------------------------------------------------------------
getMemTable move.l   #memTable,d0 
            rts

;--------------------------------------------------------------------------------
; Function 19: Get IO byte
;--------------------------------------------------------------------------------
getIOByte   movem.l  a0,-(a7)
            move.l   #str_func19,a0
            jsr      print
            movem.l  (a7)+,a0
            rts

;--------------------------------------------------------------------------------
; Function 20: Set IO byte
;--------------------------------------------------------------------------------
setIOByte   movem.l  a0,-(a7)
            move.l   #str_func20,a0
            jsr      print
            movem.l  (a7)+,a0
            rts

;--------------------------------------------------------------------------------
; Function 21: Flush buffers
;--------------------------------------------------------------------------------
flush       clr.l    d0 
            rts

;--------------------------------------------------------------------------------
; Function 22: Set exception handlers
;--------------------------------------------------------------------------------
setHandlers and.l    #$FF,d1        ; do only for exceptions 0 - 255
            lsl.w    #2,d1          ; multiply exception number by 4
            move.l   d1,a0 
            move.l   (a0),d0 
            move.l   d2,(a0) 
noset       rts
;
            align    4
;
dma         dc.l     0
selTrack    dc.w     0           ; track requested by setTrack
selSector   dc.w     0
selDrive    dc.b     $FF         ; drive requested by selDisk
            dc.b     0           ; dummy
;
            align    4
;
fujinet_dcb ds.b     DCB_SIZE
;
            align    4
;
memTable    dc.w     1           ; 1 Memory region - TPA only
tpaStart    dc.l     $00020000   ; Default: Start of the Transient Program Area
tpaSize     dc.l     $00060000   ; Default: Size of the Transient Program Area

;-----------------------------------------------------------------------------------------------------
; disk parameter headers
;-----------------------------------------------------------------------------------------------------
            align    4
;
dpHdr0      dc.l     0           ; No translation
            dc.w     0           ; scratchpad 1
            dc.w     0           ; scratchpad 2
            dc.w     0           ; scratchpad 3
            dc.l     dirBuffer   ; ptr to directory buffer
            dc.l     dpb0        ; ptr to boot disk parameter block
            dc.l     0           ; ptr to check vector
            dc.l     allocV0     ; ptr to allocation vector
;
dpHdr1      dc.l     0           ; No translation
            dc.w     0           ; scratchpad 1
            dc.w     0           ; scratchpad 2
            dc.w     0           ; scratchpad 3
            dc.l     dirBuffer   ; ptr to directory buffer
            dc.l     dpb0        ; ptr to disk parameter block
            dc.l     0           ; ptr to check vector
            dc.l     allocV1     ; ptr to allocation vector
;
dpHdr2      dc.l     0           ; No translation
            dc.w     0           ; scratchpad 1
            dc.w     0           ; scratchpad 2
            dc.w     0           ; scratchpad 3
            dc.l     dirBuffer   ; ptr to directory buffer
            dc.l     dpb0        ; ptr to disk parameter block
            dc.l     0           ; ptr to check vector
            dc.l     allocV2     ; ptr to allocation vector
;
dpHdr3      dc.l     0           ; No translation
            dc.w     0           ; scratchpad 1
            dc.w     0           ; scratchpad 2
            dc.w     0           ; scratchpad 3
            dc.l     dirBuffer   ; ptr to directory buffer
            dc.l     dpb0        ; ptr to disk parameter block
            dc.l     0           ; ptr to check vector
            dc.l     allocV3     ; ptr to allocation vector
;
dpHdr4      dc.l     0           ; No translation
            dc.w     0           ; scratchpad 1
            dc.w     0           ; scratchpad 2
            dc.w     0           ; scratchpad 3
            dc.l     dirBuffer   ; ptr to directory buffer
            dc.l     dpb0        ; ptr to disk parameter block
            dc.l     0           ; ptr to check vector
            dc.l     allocV4     ; ptr to allocation vector
;
dpHdr5      dc.l     0           ; No translation
            dc.w     0           ; scratchpad 1
            dc.w     0           ; scratchpad 2
            dc.w     0           ; scratchpad 3
            dc.l     dirBuffer   ; ptr to directory buffer
            dc.l     dpb0        ; ptr to disk parameter block
            dc.l     0           ; ptr to check vector
            dc.l     allocV5     ; ptr to allocation vector
;
dpHdr6      dc.l     0           ; No translation
            dc.w     0           ; scratchpad 1
            dc.w     0           ; scratchpad 2
            dc.w     0           ; scratchpad 3
            dc.l     dirBuffer   ; ptr to directory buffer
            dc.l     dpb0        ; ptr to disk parameter block
            dc.l     0           ; ptr to check vector
            dc.l     allocV6     ; ptr to allocation vector
;
dpHdr7      dc.l     0           ; No translation
            dc.w     0           ; scratchpad 1
            dc.w     0           ; scratchpad 2
            dc.w     0           ; scratchpad 3
            dc.l     dirBuffer   ; ptr to directory buffer
            dc.l     dpb0        ; ptr to disk parameter block
            dc.l     0           ; ptr to check vector
            dc.l     allocV7     ; ptr to allocation vector
;
dpb0        dc.w     32          ; sectors per track
            dc.b     $04         ; block shift
            dc.b     $0F         ; block mask
            dc.b     0           ; extent mask
            dc.b     0           ; dummy fill
            dc.w     2047        ; disk size
            dc.w     $00FF       ; directory entires
            dc.w     0           ; directory mask
            dc.w     0           ; directory check size
            dc.w     0           ; track offset

dirBuffer   ds.b     128         ; directory buffer

allocV0     ds.b     2048        ; allocation vector
allocV1     ds.b     2048        ; allocation vector
allocV2     ds.b     2048        ; allocation vector
allocV3     ds.b     2048        ; allocation vector
allocV4     ds.b     2048        ; allocation vector
allocV5     ds.b     2048        ; allocation vector
allocV6     ds.b     2048        ; allocation vector
allocV7     ds.b     2048        ; allocation vector
;
strInit:    dc.b    "CP/M-68K Digicool MECB 68008 BIOS V0.1",CR,LF,0
strMountFail: dc.b   "Mount failed",CR,LF,0
;
;str_func0:  dc.b     "BIOS init",CR,LF,EOT
;str_func1:  dc.b     "BIOS warm boot",CR,LF,EOT
;str_func2:  dc.b     "Console status",CR,LF,EOT
;str_func3:  dc.b     "Read console character",CR,LF,EOT
;str_func4:  dc.b     "Write console character",CR,LF,EOT
str_func5:  dc.b     "List character output",CR,LF,EOT
str_func6:  dc.b     "Auxiliary output",CR,LF,EOT
str_func7:  dc.b     "Auxiliary input",CR,LF,EOT
;str_func8:  dc.b     "Home",CR,LF,EOT
;str_func9:  dc.b     "Select disk drive=$",EOT
;str_func10: dc.b     "Set track number=$",EOT
;str_func11: dc.b     "Set sector number=$",EOT
;str_func12: dc.b     "Set DMA address=$",EOT
;str_func13: dc.b     "Read sector",CR,LF,EOT
;str_func14: dc.b     "Write sector",CR,LF,EOT
str_func15: dc.b     "Return list status",CR,LF,EOT
;str_func16: dc.b     "Sector translate",CR,LF,EOT
str_func17: dc.b     "Undefined",CR,LF,EOT
;str_func18: dc.b     "Get region table address",CR,LF,EOT
str_func19: dc.b     "Get I/O byte",CR,LF,EOT
str_func20: dc.b     "Set I/O byte",CR,LF,EOT
;str_func21: dc.b     "Flush buffers",CR,LF,EOT
;str_func22: dc.b     "Set exception handler address for $",EOT
;
            end
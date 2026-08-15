********************************************************************
* rbmecbfn - Digicool MECB Fujinet driver
*
* This driver works with the MECB FujiNet card
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2017/05/08  Boisy G. Pitre
* Started.

                    nam       rbmecbfn
                    ttl       DriveWire RBF driver

NUMRETRIES          equ       8

                    ifp1
                    use       defsfile
                    endc

NumDrvs             set       4

tylg                set       Drivr+Objct
atrv                set       ReEnt+rev
rev                 set       $01
edition             set       1

                    mod       eom,name,tylg,atrv,start,size

                    rmb       DRVBEG+(DRVMEM*NumDrvs)
v$dcb_block         rmb       14
v$tlsn              rmb       2
v$tpd               rmb       2
size                equ       .

                    fcb       DIR.+SHARE.+PEXEC.+PREAD.+PWRIT.+EXEC.+UPDAT.

name                fcs       /rbmecbfn/
                    fcb       edition

start               bra       Init
                    nop
                    lbra      Read
                    lbra      Write
                    lbra      GetStat
                    lbra      SetStat

* Term
*
* Entry:
*    U  = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
Term
                    clrb
                    rts

* Init
*
* Entry:
*    Y  = address of device descriptor
*    U  = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
Init
                    pshs      a
                    ldb       #NumDrvs
                    stb       V.NDRV,u
                    leax      DRVBEG,u
                    lda       #$FF
Init2               sta       DD.TOT,x            ; invalidate drive tables
                    sta       DD.TOT+1,x
                    sta       DD.TOT+2,x
                    leax      DRVMEM,x
                    decb
                    bne       Init2

                    clrb
                    puls      a,pc

* Read
*
* Entry:
*    B  = MSB of LSN
*    X  = LSB of LSN
*    Y  = address of path descriptor
*    U  = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
Read
                    stx       v$tlsn,u                ; save the lower part of the LSN
                    sty       v$tpd,u
                    tstb                              ; Fujinet doesn't support 24-bit sector numbers
                    beq       Read1
                    ldx       v$tlsn,u                ; restore the lower part of the LSN
                    ldb       #E$Unit                 ; report an error if MSB of LSN is not 0
                    lbra      ReadErr
;
Read1
                    leax      v$dcb_block,u           ; point to the DCB
                    ldb       <PD.DRV,y               ; get drive number
                    cmpb      #NumDrvs                ; Check selected drive against what is available
                    blo       Read2                   ; If selected drive is available continue
                    ldx       v$tlsn,u                ; restore the LSN
                    ldb       #E$Unit                 ; Otherwise report an error
                    lbra      ReadErr
                    
; Read the sector from the specified drive
Read2               addb      #RC2014_DEVICEID_DISK+1 ; convert drive number to FujiNet device
                    stb       DCB_DEVICE,x            ; Save in DCB
                    ldd       PD.BUF,y                ; Get a pointer to the buffer
                    std       DCB_RX_BUFFER,x         ; Save in the DCB
                    ldd       v$tlsn,u                ; Get the sector number
                    sta       DCB_AUX2,x              ; Save the lower word of the sector number (only 16-bit supported)
                    stb       DCB_AUX1,x
                    pshs      d                       ; save the sector number so it can be restored
                    ldd       #DISK_SECTOR_SIZE       ; Set the sector size (256 bytes)
                    std       DCB_RX_BUFFER_LEN,x
                    ldd       #0                      ; Reset transmit buffer
                    std       DCB_TX_BUFFER_LEN,x
                    ldd       #FUJINET_TIMEOUT
                    std       DCB_TIMEOUT,x
                    lda       #DEVICE_READ            ; read from disk device
                    sta       DCB_COMMAND,x
                    jsr       [S.FNexec]              ; Use the in-ROM routine (rel.asm)
                    puls      x                       ; Restore the sector number
                    cmpa      #FUJINET_RC_OK          ; Check if OK
                    beq       Read3                   ; If OK, continue
                    ldb       #E$Read                 ; Otherwise report an error
                    bra       ReadErr
;
Read3               cmpx      #$0000                  ; LSN 0?
                    bne       ReadOK                  ; branch if not
* At this point we have read LSN0
                    leax      DRVBEG,u                ; point to start of drive table
                    ldb       <PD.DRV,y               ; get drive number
NextDrv             beq       CopyLSN0                ; branch if terminal count
                    leax      <DRVMEM,x               ; else move to next drive table entry
                    decb                              ; decrement counter
                    bra       NextDrv                 ; and continue
CopyLSN0            ldb       #DD.SIZ                 ; get size to copy
                    ldy       PD.BUF,y                ; point to buffer
CpyLSNLp            lda       ,y+                     ; get byte from buffer
                    sta       ,x+                     ; and save in drive table
                    decb
                    bne       CpyLSNLp
ReadOk              ldx       v$tlsn,u                ; restore the lower part of the LSN
                    ldy       v$tpd,u                 ; restore the path descriptor pointer
                    clrb
                    
                    andcc     #^Carry                 ; return with no error
                    rts

ReadErr             orcc      #Carry                  ; return an error
                    rts


* Write
*
* Entry:
*    B  = MSB of LSN
*    X  = LSB of LSN
*    Y  = address of path descriptor
*    U  = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
Write
                    stx       v$tlsn,u                ; save the lower part of the LSN
                    sty       v$tpd,u
                    tstb
                    bne       WriteErr
                    ldb       PD.DRV,y
                    cmpb      #NumDrvs
                    blo       WriteSect
WriteErr
                    ldx       v$tlsn,u                ; restore the LSN
                    comb                              ; set Carry
                    ldb       #E$Unit
                    rts

WriteSect           andcc     #^Carry
                    pshs      cc,y,u
                    leax      v$dcb_block,u           ; point to the DCB
                    addb      #RC2014_DEVICEID_DISK+1 ; convert drive number to FujiNet device
                    stb       DCB_DEVICE,x            ; Save in DCB
                    ldd       PD.BUF,y                ; Get a pointer to the buffer
                    std       DCB_TX_BUFFER,x         ; Save in the DCB
                    ldd       v$tlsn,u                ; Get the sector number
                    sta       DCB_AUX2,x              ; Save the lower word of the sector number (only 16-bit supported)
                    stb       DCB_AUX1,x
                    pshs      d                       ; save the sector number so it can be restored
                    ldd       #DISK_SECTOR_SIZE       ; Set the sector size (256 bytes)
                    std       DCB_TX_BUFFER_LEN,x
                    ldd       #0                      ; Reset transmit buffer
                    std       DCB_RX_BUFFER_LEN,x
                    ldd       #FUJINET_TIMEOUT
                    std       DCB_TIMEOUT,x
                    lda       #DEVICE_WRITE           ; write to disk device
                    sta       DCB_COMMAND,x
                    jsr       [S.FNexec]              ; Use the in-ROM routine (rel.asm)
                    puls      x                       ; Restore the sector number
                    cmpa      #FUJINET_RC_OK          ; Check if OK
                    beq       WriteEx                 ; If OK, continue
;                    sta       dno,u
;                    lda       #2
;                    sta       dssz,u
;                    clra
;                    std       dscthi,u
;                    stx       dsctlo,u
;                    lda       #PC_WRITE_LONG      load A with WRITE opcode
;                    sta       dcmd,u
;                    ldy       #7
;                    leax      dcmd,u
;
;                    ifgt      LEVEL-1
;                    ldu       <D.DWSubAddr
;                    else
;                    ldu       >D.DWSubAddr
;                    endc
;                    orcc      #IntMasks
;                    jsr       6,u
; Write 256 bytes of sector data
;                    ldx       1,s                 get path descriptor ptr
;                    ldx       PD.BUF,x            get buffer pointer into X
;                    ldy       #$0100
;                    jsr       6,u
;
;                    ldx       1,s                 get path descriptor ptr
;                    leax      resp,x
;                    ldy       #1
;                    jsr       3,u
;                    lda       ,x
;                    cmpa      #RACK
;                    beq       WriteEx

* read error byte but ignore
;                    ldy       #1
;                    jsr       3,u

WriteEr1            puls      cc,y,u
                    ldx       v$tlsn,u                ; restore the LSN
                    orcc      #Carry
                    ldb       #E$Write
                    rts
WriteEx
                    puls      cc,y,u,pc

* SetStat
*
* Entry:
*    R$B = function code
*    Y   = address of path descriptor
*    U   = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
SetStat
* Size optimization


* GetStat
*
* Entry:
*    R$B = function code
*    Y   = address of path descriptor
*    U   = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
GetStat
                    rts

                    emod
eom                 equ       *
                    end

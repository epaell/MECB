********************************************************************
* Boot - Digicool MECB Fujinet Boot module
* Provides HWInit, HWTerm, HWRead which are called by code in
* "use"d boot_common.asm
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*          2017/05/01  Darren Atkinson
*          2026/07/12  Emil Lenc
* Created.

                    nam       Boot
                    ttl       Digicool MECB FN Boot module

                    ifp1
                    use       defsfile
                    endc

                    org       0
* Default Boot is from drive 0
BootDr              set       0

* Alternate Boot is from drive 1
                    ifeq      DNum-1
BootDr              set       1
                    endc

* Common booter-required defines
LSN24BIT            equ       1
FLOPPY              equ       0
;
; v$dcb_block:
;     byte device
;     byte command
;     byte aux1
;     byte aux2
;     word TX buffer ptr
;     word TX length
;     word RX buffer ptr
;     word RX length
;     word timeout (mS)
;
v$dcb_block         rmb       14                      ; the DCB block used for low-level Fujinet commands

* NOTE: these are U-stack offsets, not DP
seglist             rmb       2                       ; pointer to segment list
blockloc            rmb       2                       ; pointer to memory requested
blockimg            rmb       2                       ; duplicate of the above
bootsize            rmb       2                       ; size in bytes
LSN0Ptr             rmb       2                       ; In memory LSN0 pointer
size                equ       .


tylg                set       Systm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       1

                    mod       eom,name,tylg,atrv,start,size

name                fcs       /Boot/
                    fcb       edition


*--------------------------------------------------------------------------
* HWInit - Initialize the device
*
*    Entry:
*       Y  = hardware address
*
*    Exit:
*       Carry Clear = OK, Set = Error
*       B  = error (Carry Set)
*
HWInit
;
                    ldb       #0
                    leax      v$dcb_block,u
                    lda       #RC2014_DEVICEID_FUJINET
                    sta       DCB_DEVICE,x
                    lda       #FUJICMD_MOUNT_ALL      ; Set up DCB for mount all hosts command
                    sta       DCB_COMMAND,x
                    ldd       #0
                    std       DCB_AUX1,x              ; Clear aux1/2
                    std       DCB_RX_BUFFER_LEN,x     ; Receive length=0
                    std       DCB_TX_BUFFER_LEN,x     ; Transmit length=0
                    ldd       #FUJINET_TIMEOUT        ; Set time-out
                    std       DCB_TIMEOUT,x
                    jsr       [S.FNexec]              ; Use the in-ROM routine (rel.asm)
                    cmpa      #FUJINET_RC_OK          ; Check if OK
                    beq       HWTerm                  ; yes, return
                    orcc      #$01                    ; Otherwise set carry
                    rts

*--------------------------------------------------------------------------
* HWTerm - Terminate the device
*
*    Entry:
*       Y  = hardware address
*
*    Exit:
*       Carry Clear = OK, Set = Error
*       B = error (Carry Set)
*
HWTerm              clrb                              ; no error
                    rts

***************************************************************************
                    use       boot_common.asm
***************************************************************************

*
* HWRead - Read a 256 byte sector from the device
*
*    Entry:
*       Y  = hardware address
*       B  = bits 23-16 of LSN
*       X  = bits 15-0  of LSN
*       blockloc,u = where to load the 256 byte sector
*
*    Exit:
*       Carry Clear = OK, Set = Error
*
HWRead              ldy       blockloc,u
                    pshs      x
                    leax      v$dcb_block,u
                    sty       DCB_RX_BUFFER,x         ; Point the receive buffer to where the data needs to go
                    puls      d
                    sta       DCB_AUX2,x              ; Save the lower word of the sector number (only 16-bit supported)
                    stb       DCB_AUX1,x
                    ldd       #DISK_SECTOR_SIZE       ; Set the sector size (256 bytes)
                    std       DCB_RX_BUFFER_LEN,x
                    ldd       #0                      ; Reset transmit buffer
                    std       DCB_TX_BUFFER_LEN,x
                    ldd       #FUJINET_TIMEOUT
                    std       DCB_TIMEOUT,x
                    ldb       #1                      ; boot off drive in slot 2
                    addb      #RC2014_DEVICEID_DISK   ; working with a disk device
                    stb       DCB_DEVICE,x
                    lda       #DEVICE_READ            ; read from disk device
                    sta       DCB_COMMAND,x
                    jsr       [S.FNexec]              ; Use the in-ROM routine (rel.asm)
;
                    pshs      a
                    lda       #'.
                    jsr       [S.CharOut]
                    puls      a
                    ldx       blockloc,u
                    cmpa      #FUJINET_RC_OK          ; Check if OK
                    lbeq      HWTerm                  ; yes, return
                    ldb       #E$Read
                    orcc      #$01                    ; Otherwise set carry
                    rts

                    page

Address             fdb       $0000

                    emod
eom                 equ       *
EOMSize             equ       *-Address

                    end

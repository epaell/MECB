********************************************************************
* Clock2 - Fujinet RTC Driver
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2026/07/17  Emil Lenc
* Created.

                    nam       Clock2
                    ttl       Fujinet RTC Driver

                    ifp1
                    use       defsfile
                    endc

tylg                set       Sbrtn+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       1


                    mod       eom,name,tylg,atrv,JmpTable,size

v$dcb_block         rmb       14
size                equ       .

name                fcs       "Clock2"
                    fcb       edition

* Three Entry Points:
*   - Init
*   - GetTime
*   - SetTIme
JmpTable
                    bra       Init                    ; RTC Init (doesn't do anything)
                    nop
                    bra       GetTime                 ; RTC Get Time (fetches network time)
                    nop
                    bra       SetTime                 ; RTC Set Time (doesn't do anything)
                    nop

Init
SetTime             rts                               ; these routines return back to caller

GetTime
                    pshs      x,d,u
                    leas      -DCB_SIZE,s
                    leax      0,s                     ; get pointer to DCB block
                    lda       #RC2014_DEVICEID_FUJINET
                    sta       DCB_DEVICE,x            ; set the device
                    lda       #FUJICMD_GET_TIME       ; set up DCB for get_time command
                    sta       DCB_COMMAND,x
                    ldd       #0
                    std       DCB_AUX1,x              ; clear aux1/2
                    std       DCB_TX_BUFFER_LEN,x     ; TX length=0
                    std       DCB_TX_BUFFER,x         ; No TX buffer
                    ldb       #TIME_LEN
                    std       DCB_RX_BUFFER_LEN,x     ; RX length=length of time structure
                    ldd       #FUJINET_TIMEOUT        ; set time-out
                    std       DCB_TIMEOUT,x
                    leas      -TIME_LEN,s             ; make space for the time structure
                    sts       DCB_RX_BUFFER,x         ; set the RX buffer to the time structure
                    jsr       [S.FNexec]              ; call the in-ROM routine (rel.asm)
                    cmpa      #FUJINET_RC_OK          ; check if OK
                    beq       GetTime2                ; yes, store results
                    orcc      #$01                    ; otherwise set carry
                    bra       GetExit                 ; return
GetTime2
                    ldx       #$0000                  ; point to zero page
                    lda       FN_TIME_YEARL,s         ; get the year from the receive buffer
                    adda      #100
                    sta       D.Year,x                ; Update the OS year
                    lda       FN_TIME_MONTH,s         ; get the month from the receive buffer
                    sta       D.Month,x               ; Update the OS month
                    lda       FN_TIME_MDAY,s          ; get the month day from the receive buffer
                    sta       D.Day,x                 ; Update the OS day
                    lda       FN_TIME_HOUR,s          ; get the hour from the receive buffer
                    sta       D.Hour,x                ; Update the OS hour
                    lda       FN_TIME_MIN,s           ; get the minute from the receive buffer
                    sta       D.Min,x                 ; Update the OS minute
                    sta       IOPORTBase              ; epaell - write minutes to IO port for diagnostics
                    lda       FN_TIME_SEC,s           ; get the second from the receive buffer
                    sta       D.Sec,x                 ; Update the OS second
                    andcc     #$fe                    ; clear carry

GetExit             leas      TIME_LEN+DCB_SIZE,s     ; remove temporary storage off stack
                    puls      x,d,u,pc                ; restore registers and return

;
; debug routine to dump all registers to console
;
;dump_all_reg        pshs      d
;
;                    pshs      d
;                    lda       #'D
;                    jsr       [S.CharOut]
;                    lda       #'=
;                    jsr       [S.CharOut]
;                    puls      d
;                    jsr       [S.Hex4Out]
;                    lda       #$20
;                    jsr       [S.CharOut]
;
;                    lda       #'X
;                    jsr       [S.CharOut]
;                    lda       #'=
;                    jsr       [S.CharOut]
;                    tfr       x,d
;                    jsr       [S.Hex4Out]
;                    lda       #$20
;                    jsr       [S.CharOut]
;
;                    lda       #'Y
;                    jsr       [S.CharOut]
;                    lda       #'=
;                    jsr       [S.CharOut]
;                    tfr       y,d
;                    jsr       [S.Hex4Out]
;                    lda       #$20
;                    jsr       [S.CharOut]
;
;                    lda       #'S
;                    jsr       [S.CharOut]
;                    lda       #'=
;                    jsr       [S.CharOut]
;                    tfr       s,d
;                    jsr       [S.Hex4Out]
;                    lda       #$20
;                    jsr       [S.CharOut]
;
;                    lda       #'U
;                    jsr       [S.CharOut]
;                    lda       #'=
;                    jsr       [S.CharOut]
;                    tfr       u,d
;                    jsr       [S.Hex4Out]
;                    lda       #$20
;                    jsr       [S.CharOut]
;
;                    lda       #$0d
;                    jsr       [S.CharOut]
;                    lda       #$0a
;                    jsr       [S.CharOut]
;                    puls      d,pc
                    

                    emod
eom                 equ       *
                    end

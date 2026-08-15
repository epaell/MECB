********************************************************************
* fnio - Fujinet I/O Low Level Subroutine Module
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2017/05/09  Boisy G. Pitre
* Started.
*
                    nam       fnio
                    ttl       Fujinet I/O Low Level Subroutine Module

                    ifp1
                    use       defsfile
                    endc

tylg                set       Sbrtn+Objct
atrv                set       ReEnt+rev
rev                 set       $01

                    mod       eom,name,tylg,atrv,start,0

name                fcs       /fnio/

* FN subroutine entry table
start               bra       Init
                    nop
                    bra       FNExec
                    nop

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
                    clrb                          clear Carry
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
* Initialize the serial device
Init
;
                    pshs      d,x
                    puls      d,x,pc

                    page
;*****************************************************
; Entry: X = address of bytes to write
;        Y = byte count
;
; All registers preserved.
;
; Execute FujiNet Command
;
;
FNExec              pshs      b,x,y,u             ;save data
                    puls      b,x,y,u,pc

                    emod
eom                 equ       *
                    end

               cpu      68008
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; IO base port
IO_BASE        equ      $3C0000

SID            equ      IO_BASE+$A0
;
            include  "tutor.inc"

            org      $4000
;
            move.l   #$8000,sp         ; set up stack pointer 
            move.l   #OUT1CR,d7        ; Write message to indicate test starting
            move.l   #M_TSTART,a5
            move.l   #M_TEND,a6
            trap     #14
;
; Play a tone through channel 1
;
            move.b   #15,SID+24        ; Set SID Mode Volume
            move.b   #97,SID+5         ; Set SID Channel 1 Attack/Decay
            move.b   #200,SID+6        ; Set SID Channel 1 Sustain/Release
            move.b   #17,SID+4         ; Set SID Channel 1 Control Register
            move.b   #$25,SID
            move.b   #$11,SID+1
;
; return to tutor monitor
;
            move.b   #TUTOR,d7
            trap     #14
;
M_TSTART    dc.b     "Starting SID test"
M_TEND
            align    2
;
            end
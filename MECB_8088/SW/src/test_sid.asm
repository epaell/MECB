%include    'src/mecb.inc'
;
; int 09h: return control to monitor
;
%macro monitor 0
            call  flush
            int   09h
%endmacro
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; IO base port
;
            org      USERPROG_ORG
;
            mov   ax,8000
            mov   sp,ax                ; set up stack pointer 
            mov   si,M_TSTART          ; Write message to indicate test starting
            call  print
;
; Play a tone through channel 1
;
; C1# (0245h) E1 (02B3h) G1 (0336h) (A1#?)Bb (039bh) C2# (048b) E2 (0567)
            mov   bl,010h              ; $10 triangle and gate off
            mov   bh,SID_CTRL1
            call  write_sid1
            call  write_sid2
            mov   bl,010h              ; $10 triangle and gate off
            mov   bh,SID_CTRL2
            call  write_sid1
            call  write_sid2
            mov   bl,010h              ; $10 triangle and gate off
            mov   bh,SID_CTRL3
            call  write_sid1
            call  write_sid2


            mov   bl,15                ; $0f 3OFF,HP=BP=LP=0 Vol=$0f
            mov   bh,SID_MODVOL
            call  write_sid1
            call  write_sid2
            mov   bl,0bbh              ; $61 ATK=$06 (68 mS) DEC=$01 (24 mS)
            mov   bh,SID_ATDEC1
            call  write_sid1
            call  write_sid2
            mov   bl,0bbh              ; $61 ATK=$06 (68 mS) DEC=$01 (24 mS)
            mov   bh,SID_ATDEC2
            call  write_sid1
            call  write_sid2
            mov   bl,0bbh              ; $61 ATK=$06 (68 mS) DEC=$01 (24 mS)
            mov   bh,SID_ATDEC3
            call  write_sid1
            call  write_sid2
            mov   bl,009h              ; $c8 SUS=$C REL=$08
            mov   bh,SID_SUREL1
            call  write_sid1
            call  write_sid2
            mov   bl,009h              ; $c8 SUS=$C REL=$08
            mov   bh,SID_SUREL2
            call  write_sid1
            call  write_sid2
            mov   bl,009h              ; $c8 SUS=$C REL=$08
            mov   bh,SID_SUREL3
            call  write_sid1
            call  write_sid2
            mov   bl,21h                ; $11 triangle and gate
            mov   bh,SID_CTRL1
            call  write_sid1
            call  write_sid2
            mov   bl,21h                ; $11 triangle and gate
            mov   bh,SID_CTRL2
            call  write_sid1
            call  write_sid2
            mov   bl,21h                ; $11 triangle and gate
            mov   bh,SID_CTRL3
            call  write_sid1
            call  write_sid2
; C1# (0245h) E1 (02B3h) G1 (0336h) (A1#?)Bb (039bh) C2# (048b) E2 (0567)
            mov   bl,015h
            mov   bh,SID_FREQLO1       ; C3#
            call  write_sid1
            mov   bl,09h
            mov   bh,SID_FREQHI1
            call  write_sid1
;
            mov   bl,0cdh
            mov   bh,SID_FREQLO2       ; E3
            call  write_sid1
            mov   bl,0ah
            mov   bh,SID_FREQHI2
            call  write_sid1
;
            mov   bl,008h
            mov   bh,SID_FREQLO3       ; G3
            call  write_sid1
            mov   bl,0ch
            mov   bh,SID_FREQHI3
            call  write_sid1

            mov   bl,046h
            mov   bh,SID_FREQLO1       ; A3#
            call  write_sid2
            mov   bl,0fh
            mov   bh,SID_FREQHI1
            call  write_sid2

            mov   bl,025h
            mov   bh,SID_FREQLO2       ; C4#
            call  write_sid2
            mov   bl,11h
            mov   bh,SID_FREQHI2
            call  write_sid2

            mov   bl,9ah
            mov   bh,SID_FREQLO3       ; E4
            call  write_sid2
            mov   bl,15h
            mov   bh,SID_FREQHI3
            call  write_sid2

;
; return to tutor monitor
;
            monitor
;
; write to SID1
;  bl - SID data
;  bh - SID register
;
write_sid1  mov   al,bl
            out   SID_DATA,al          ; Set up data
            mov   al,bh                ; set up the address (chip select high)
            or    al,0c0h
            out   SID_ADDR,al
            and   al,0bfh              ; Enable chip select on SID1
            out   SID_ADDR,al
            or    al,0c0h
            out   SID_ADDR,al
            ret
; write to SID2
;  bl - SID data
;  bh - SID register
;
write_sid2  mov   al,bl
            out   SID_DATA,al          ; Set up data
            mov   al,bh                ; set up the address (chip select high)
            or    al,0c0h
            out   SID_ADDR,al
            and   al,07fh              ; Enable chip select on SID2
            out   SID_ADDR,al
            or    al,0c0h
            out   SID_ADDR,al
            ret
;
M_TSTART    db    CR,LF,"Starting SID test",EOT
;
%include    'src/acia_io.asm'
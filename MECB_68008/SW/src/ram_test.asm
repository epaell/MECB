               cpu      68008
;
               include  "mecb.inc"
               include  "tutor.inc"
               include  "library_rom.inc"
               include  "vdp.inc"
;
CR             equ      $0d
LF             equ      $0a
;
RAM_START      equ      $00004800
NDOTS          equ      $40
;
               org      $4000
;
start          move.b   #OUTPUT,d7
               move.l   #msg_start,a5
               move.l   #_msg_start,a6
               trap     #14
;
; Fill VRAM with random values
;
               move.b   #OUTPUT,d7
               move.l   #msg_write,a5
               move.l   #_msg_write,a6
               trap     #14
;
               move.l   #rand_seed,a0        ; Reset the random seed
               move.l   #$12345678,(a0)
               move.l   #RAM_START,a1        ; Point of location to start test at
               move.l   #NDOTS,d4            ; Number of 1024-byte blocks before output a new line
fill           jsr      random               ; d0 = random number
               move.b   d0,(a1)+             ; Store in RAM
               move.l   a1,d0
               and.w    #$3ff,d0
               bne      fill2
               move.b   #'.',d0              ; Write a '.' every 1024 bytes
               move.b   #OUTCH,d7
               move.l   a0,-(a7)             ; Save a0
               trap     #14
               sub.l    #1,d4
               bne      fill3
;
               move.b   #OUTPUT,d7
               move.l   #msg_crlf,a5
               move.l   #_msg_crlf,a6
               trap     #14
;
               move.l   #NDOTS,d4            ; reset the dot counter
fill3          move.l   (a7)+,a0             ; Restore a0

fill2          cmp.l    #RAM_END+1,a1        ; Check for end of RAM
               bne      fill                 ; If not reached, continue
;
               move.b   #OUTPUT,d7
               move.l   #msg_crlf,a5
               move.l   #_msg_crlf,a6
               trap     #14
;
               move.b   #OUTPUT,d7
               move.l   #msg_read,a5
               move.l   #_msg_read,a6
               trap     #14
;
               move.l   #rand_seed,a0        ; Reset the random seed
               move.l   #$12345678,(a0)      ; Reset the random seed
               move.l   #RAM_START,a1
               move.l   #NDOTS,d4            ; Number of 1024-byte blocks before output a new line
check          jsr      random               ; d0 = random number
               move.b   (a1)+,d1
               cmp.b    d0,d1
               bne      bad
               move.l   a1,d0
               and.w    #$3ff,d0
               bne      check2
               move.b   #'.',d0
               move.b   #OUTCH,d7
               move.l   a0,-(a7)             ; Save a0
               trap     #14
               sub.l    #1,d4
               bne      check3
;
               move.b   #OUTPUT,d7
               move.l   #msg_crlf,a5
               move.l   #_msg_crlf,a6
               trap     #14
;
               move.l   #NDOTS,d4
check3         move.l   (a7)+,a0             ; Restore a0
  
check2         cmp.l    #RAM_END+1,a1          ; Check for end of RAM
               bne      check                ; If not reached, continue
               move.b   #OUTPUT,d7
               move.l   #msg_good,a5
               move.l   #_msg_good,a6
               trap     #14
               bra      exit
;
bad            move.b   d1,d0
               move.l   #BUFFER,a6           ; Write out the byte
               move.b   #PNT2HX,d7
               trap     #14
               move.b   #OUT1CR,d7           ; Write to terminal
               move.l   #BUFFER,a5
               trap     #14

               move.b   #OUTPUT,d7           ; VRAM check failed
               move.l   #msg_bad,a5
               move.l   #_msg_bad,a6
               trap     #14
               move.l   d3,d0                ; Convert address to ASCII
               move.l   #BUFFER,a6
               move.b   #PNT8HX,d7
               trap     #14
               move.b   #OUT1CR,d7           ; Write to terminal
               move.l   #BUFFER,a5
               trap     #14
;
exit           move.b   #TUTOR,d7
               trap     #14
;
rand_seed      ds.l     1
;
BUFFER         ds.b     32                   ; Buffer for holding hex values
;
msg_crlf       dc.b     CR,LF
_msg_crlf      equ      *
msg_start      dc.b     'MECB 68008 Memory Test',CR,LF
_msg_start     equ      *
msg_write      dc.b     'Writing to RAM',CR,LF
_msg_write     equ      *
msg_read       dc.b     'Reading from RAM',CR,LF
_msg_read      equ      *
msg_good       dc.b     CR,LF,'RAM check successful',CR,LF
_msg_good      equ      *
msg_bad        dc.b     CR,LF,'RAM check failed at 0x'
_msg_bad       equ      *
msg_end        equ      *
;

         include  "src/mecb.asm"
;
         org      $4000
;
; endless loop reading each byte from ROM
;
start    move.l   #ROM_BASE,a0
         move.l   #ROM_END-ROM_BASE,d0
loop     move.b   (a0)+,d1
         sub.l    #1,d0
         bne      loop
         bra      start
;
         end
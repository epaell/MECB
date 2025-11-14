;--------------------------------------------------------------
;
;  FUNCTION Random: INTEGER;
;
;  returns a signed 16 bit number, and updates unsigned 32 bit randSeed.
;
;  recursion is randSeed := (randSeed * 16807) MOD 2147483647.
;
;  See paper by Linus Schrage, A More Portable Fortran Random Number Generator
;  ACM Trans Math Software Vol 5, No. 2, June 1979, Pages 132-138.
;
;  a0 - points to randSeed
;  Clobbers: d0-d2
;  Return 16 signed random number in d0
;
;
;  Get low 16 bits of seed and form low product
;  xalo := A * LowWord(seed)
;
random    move       #16807,d0               ; Get A = 7^5
          move       d0,d2                   ; Get A = 7^5
          mulu       2(a0),d0                ; Calculate low products = xalo
;
;  Form 31 highest bits of low product
;  fhi:=HiWord(seed) * ORD4(a) + HiWord(xalo);
;
          move.l     d0,d1                   ; Copy xalo
          clr.w      d1
          swap       d1                      ; Get HiWord(xalo) as a long
          mulu       (a0),d2                 ; Multiply by HiWord(seed)
          add.l      d1,d2                   ; Add LEFTLO = FHI
;
;  Get overflow past 31st bit of full product
;  k:=fhi DIV 32768;
;
          move.l     d2,d1                   ; Copy FHI
          add.l      d1,d1                   ; Calculate 2 times FHI
          clr.w      d1
          swap       d1                      ; Calculate FHI shifted right 15 for K
;
;  Assemble all the parts and pre-subtract P
;  seed:=((BitAnd(XALO,$0000FFFF) - P) + BitAnd(fhi,$00007FFF) * b16) + K;
;
          and.l      #$0000FFFF,d0           ; Get low word xalo
          sub.l      #$7FFFFFFF,d0           ; Subtract P = 2^31-1
          and.l      #$00007FFF,d2           ; BitAnd(fhi,$00007FFF)
          swap       d2                      ; Times 64K
          add.l      d1,d2                   ; Plus K
          add.l      d2,d0                   ; Calc total
;
;  If seed < 0 then seed:=seed+p;
;
          bpl.s      random2
          add.l      #$7FFFFFFF,d0
random2   move.l     d0,(a0)                 ; Update seed
          cmp.w      #$8000,d0               ; Is Number -32768 ?
          bne.s      random3                 ; No, continue
          clr        d0                      ; Yes, return zero instead
random3   ext.l      d0                      ; signed word is the result
          rts

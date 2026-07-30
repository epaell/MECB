               include  "mecb.inc"
               include  "tutor.inc"
;
TRUNDEF        equ      $0
;
               org      USERPROG_ORG
;
install:       move.l   #RAM_END+1,a7
               move.l   #trap8,a0            ; Install the trap handler
               move.l   a0,VEC_TRAP8
               move.w   #1,d5
               trap     #8
               move.w   #TUTOR,d7
               trap     #14


;
; trap 8 handler for library functions
; On entry:
;     d5.w = library function to call
; On exit:
;     d5 changed
;
trap8:
               move.l   d5,-(a7)             ; save d5
               cmp.w    #((trapend-trapbase)>>2),d5
               bcc      traperr              ; exit if function is outside of those available
               lsl.w    #2,d5                ; convert to offset
               move.l   a0,-(a7)
               move.l   trapbase(pc,d5.w),a0 ; get the function address
               cmp.l    #0,a0                ; check if it is available
               beq      traperr              ; if not, return
               move.l   #trapret,-(a7)       ; where to return to after trap function called
               move.l   a0,-(a7)             ; trap function address
               move.l   8(a7),a0             ; restore a0 before call
               rts                           ; this "returns" to the function call
trapret:       add.l    #8,a7                ; restore stack
               move.w   sr,(a7)              ; update the SR
trapexit:      rte                           ; return
;
; handler for undefined function
traperr:
               move.l   (a7),d5              ; restore the function number
               move.l   a0,(a7)              ; save a0 in its place
               move.l   d0,-(a7)             ; save d0
               move.l   #st_trap_error,a0    ; print the error message
               jsr      print
               move.l   d5,d0
               jsr      out4h                ; write the erroneous function code
               jsr      pcrlf
               move.l   (a7)+,d0             ; restore d0
               move.l   (a7)+,a0             ; restore a0
               rte                           ; return
;
trapbase:
               dc.l     GETLVER     ; F#0000 return firmware libary version in d0.l
               dc.l     OUTLVER     ; F#0001 print firmare libary version
trapend:
;
               include  "aciaio.asm"
               align    2
               include  "libver.asm"
;
st_trap_error: dc.b     'ERROR: Undefined trap #8 call initiated: #$',EOT
;
               end
               
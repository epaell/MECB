ACIAS       equ   $08
ACIAD       equ   ACIAS+1

ACIA_RESET  equ   $03
ACIA_CTRL   equ   $51

STACK       equ   $FF

CR          equ   $0D
LF          equ   $0A
EOT         equ   $00

IO_BASE        equ      $D000                  ; I/O Base address
IO1_BASE       equ      IO_BASE              ; First Motorola I/O Card
IO2_BASE       equ      IO_BASE+$20          ; Second Motorol I/O Card
ACIA1          equ      IO1_BASE+$08 ; Location of ACIA
ACIA1_STATUS   equ      ACIA1        ; Status
ACIA1_CONTROL  equ      ACIA1        ; Control
ACIA1_DATA     equ      ACIA1+1      ; Data
;
SID         equ   $D400           ; Base address
SIDFLO1     equ   SID
SIDFHI1     equ   SID+1
SIDPWLO1    equ   SID+2
SIDPWHI1    equ   SID+3
SIDCR1      equ   SID+4
SIDAD1      equ   SID+5
SIDSR1      equ   SID+6

SIDFLO2     equ   SID+7
SIDFHI2     equ   SID+8
SIDPWLO2    equ   SID+9
SIDPWHI2    equ   SID+10
SIDCR2      equ   SID+11
SIDAD2      equ   SID+12
SIDSR2      equ   SID+13

SIDFLO3     equ   SID+14
SIDFHI3     equ   SID+15
SIDPWLO3    equ   SID+16
SIDPWHI3    equ   SID+17
SIDCR3      equ   SID+18
SIDAD3      equ   SID+19
SIDSR3      equ   SID+20

SIDFCLO1    equ   SID+21
SIDFCHI1    equ   SID+22
SIDRF       equ   SID+23
SIDMV       equ   SID+24
;
            org   $0000
;
src         ds.b  2
dest        ds.b  2
;
            org   $FD00
;
init:       sei                     ; prevent interrupts
            cld                     ; clear decimal mode flag
            ldx   #STACK            ; set up stack pointer
            txs

            lda   #ACIA_RESET
            sta   ACIA1_CONTROL
            lda   #ACIA_CTRL
            sta   ACIA1_CONTROL     ; Initialise ACIA
;
            lda   #'*'
            jsr   outch
;
            lda   #$80    ;set our source memory address to copy from (LSB)
            sta   src
            lda   #$E0    ;set our source memory address to copy from (MSB)
            sta   src+1
            lda   #$80    ;set our destination memory to copy to (LSB)
            sta   dest
            lda   #$0F    ;set our destination memory to copy to (MSB)
            sta   dest+1
            ldy   #$00    ;reset x and y for our loop
            ldx   #$00

loop:
            lda   (src),y     ; indirect index source memory address, starting at $00
            sta   (dest),y    ; indirect index dest memory address, starting at $00
            inc   src         ; increment low order source memory address byte by 1
            inc   dest        ; increment low order dest memory address byte by 1
            bne   loop        ; loop until our dest goes over 255

            inc   src+1       ; increment high order source memory address, starting at $80
            inc   dest+1      ; increment high order dest memory address, starting at $60
            lda   dest+1      ; load high order mem address into a
            cmp   #$30        ; compare with the last address we want to write
            bne   loop        ; if we're not there yet, loop
;
            lda   #'I'
            jsr   outch
;
            lda   #$00        ; which piece to play (only one anyway)
            jsr   $1000
;
forever:    lda   #'P'
            ldy   #65
delay2      ldx   #00
delay       dex
            bne   delay
            dey
            bne   delay2
            jsr   outch
;
            jsr   $1003
;
            jmp   forever
;
; Play a tone through channel 1
;            lda   #15               ; Set SID Mode Volume
;            sta   SID+24
;            lda   #97               ; Set SID Channel 1 Attack/Decay
;            sta   SID+5
;            lda   #200              ; Set SID Channel 1 Sustain/Release
;            sta   SID+6
;            lda   #17               ; Set SID Channel 1 Control Register
;            sta   SID+4
;            lda   #$25
;            sta   SID
;            lda   #$11
;            sta   SID+1
;
;loop:       jmp   loop
;
;
outch:      pha
outch1:     lda   ACIA1_STATUS
            and   #$02              ; Set Zero flag if still transmitting character       
            beq   outch1            ; Loop until flag signals ready
            pla
            sta   ACIA1_DATA        ; Output the character
            rts
;
str_cp1:    db    CR,LF,'Copying sidplay to 0xd000',CR,LF,EOT
;
            org   $fffa
;
            dc.w  init
            dc.w  init
;            dc.w  init
;
end

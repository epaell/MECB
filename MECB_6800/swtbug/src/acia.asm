*    VERSION 1.00

ACIA     EQU   $8008
         ORG   $E000

START    LDAA  #3                ; ACIA master reset
         STAA  ACIA
         LDAA  #$51
         STAA  ACIA
;
; OUTPUT MESSAGE TO TERMINAL.
WRITE    LDX   #MESSAGE
FETSTA   LDAA  ACIA              ; Fetch port status
         BITA  #2                ; Check if ready to transmit
         BEQ   FETSTA            ; If not ready loop back
         LDAA  0,X               ; get a character from the message
         BEQ   DELAY             ; if end of message delay until next message
         STAA  ACIA+1            ; transmit the character
         INX
         BRA   FETSTA            ; Write next character
;
DELAY    LDX   #$0000            ; Delay for a while before writing another message
DELAY1   DEX
         BNE   DELAY1
         BRA   WRITE

MESSAGE  dc.b  "MECB 6800 is running",$0d,$0a,$00
         ORG   $FFF8
         dc.w  START          IRQ VECTOR
         dc.w  START          SOFTWARE INTERRUPT
         dc.w  START          NMI VECTOR
         dc.w  START          RESTART VECTOR

         END


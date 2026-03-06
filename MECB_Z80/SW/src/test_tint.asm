            include 'src/mecb.inc'
; 
CR          equ   $0D
LF          equ   $0A
EOT         equ   $00
;
TIMER_VAL   equ   $f000                ; timer 1 count setting
TIMER_SETH  equ   $01                  ; Preset all timers a=$01, b=$42 CRX6=1 (interrupt); CRX1=1 (enable clock)
TIMER_SETL  equ   $42                  ; Preset all timers a=$01, b=$42 CRX6=1 (interrupt); CRX1=1 (enable clock)

            org   $C000
;
init:       ld    hl,str_start         ; Write message
            call  print
;
            ld    a,$07                ; Set up the interrupt vector to point to the PTM ISR
            ld    de,ptm_isr           
            ld    c,$09
            rst   $30
            im    1                    ; Set interrupt mode 1
            call  ptm_init             ; Initialise the timer
            ld    hl,(tick)            ; get the current tick count
            ei                         ; Enable interrupts
loop:       ld    a,(tick)
            cp    l                    ; check if LSB of tick has changed
            jr    nz,updated           ; if so, handle it
            ld    a,(tick+1)
            cp    h                    ; check if MSB has changed
            jr    z,loop               ; if not, keep looping
updated:    ld    hl,(tick)            ; get the updated tick and output it
            call  outHLhex             ; Write the current tick value
            call  pcrlf
            jr    loop                 ; Loop and allow interrupts to occur
;
; Initialise the PTM
;
ptm_init:
            push  af
            push  bc
            ld    bc,TIMER_VAL
            ld    a,b
            out   (PTM1_T1MSB),a       ; Write MSB first
            ld    a,c
            out   (PTM1_T1LSB),a

            ld    a,TIMER_SETH         ; Preset all timers : CRX6=1 (interrupt); CRX1=1 (enable clock)
            out   (PTM1_CR2),a         ; Write to CR2
            ld    a,TIMER_SETL
            out   (PTM1_CR13),a
            xor   a,a
            out   (PTM1_CR2),a 

            ld    (tick),a             ; Reset the tick counter
            ld    (tick+1),a           ; Reset the tick counter
            in    a,(PTM1_SR)          ; Read the interrupt flag from the status register
            ld    a,$40
            out   (PTM1_CR13),a        ; enable interrupt and start timer
            pop   bc
            pop   af
            ret
;
; Interrupt handler for PTM
;
ptm_isr:    push  af
            push  bc
            in    a,(PTM1_SR)        ; Read the interrupt flag from the status register
            in    a,(PTM1_T1MSB)     ; Clear the timer interrupt flag
            in    a,(PTM1_T1LSB)     ; Clear the timer interrupt flag
            in    a,(PTM1_SR)        ; Read the interrupt flag from the status register
            in    a,(PTM1_T2MSB)     ; Clear the timer interrupt flag
            in    a,(PTM1_T2LSB)     ; Clear the timer interrupt flag
            in    a,(PTM1_SR)        ; Read the interrupt flag from the status register
            in    a,(PTM1_T3MSB)     ; Clear the timer interrupt flag
            in    a,(PTM1_T3LSB)     ; Clear the timer interrupt flag
            ld    bc,(tick)
            inc   bc
            ld    (tick),bc
            pop   bc
            pop   af
            ei
            reti

;
;------------------------------------------------------------------------------
print:      push  af
            push  hl
print1:     in    a,(ACIA1_STATUS)  ; Status byte       
            bit   1,a               ; Set Zero flag if still transmitting character       
            jr    z,print1          ; Loop until flag signals ready
            ld    a,(hl)            ; Get character
            or    a                 ; Is it $00 ?
            jr    z,print_end       ; If so, move on to basic memory check

            out   (ACIA1_DATA),a    ; Output the character
            inc   hl                ; Next Character
            jr    print1            ; Continue until $00
print_end:  pop   hl
            pop   af
            ret
;
pcrlf       push  af
            ld    a,CR
            call  outch
            ld    a,LF
            call  outch
            pop   af
            ret
;
outch:      push  af
outch1:     in    a,(ACIA1_STATUS)
            bit   1,a               ; Set Zero flag if still transmitting character       
            jr    z,outch1          ; Loop until flag signals ready
            pop   af
            out   (ACIA1_DATA),a    ; Output the character
            ret
;
; Outputs HL as 4-digit hex to Port 1
outHLhex:   push  af
            push  bc
            ld    c,h               ; Load high byte (H) into C
            call  outhex8           ; Convert and output high byte
            ld    c,l               ; Load low byte (L) into C
            call  outhex8           ; Convert and output low byte
            pop   bc
            pop   af
            ret

; Subroutine: Output 8-bit hex value in C
outhex8:    push  af
            ld    a,c               ; High nibble
            rra                     ; Shift right 4 times
            rra
            rra
            rra
            call  ConvNibble        ; Convert and output high nibble
            ld    a,c               ; Low nibble
            call  ConvNibble
            pop   af
            ret

ConvNibble: and   $0F               ; Mask out top 4 bits
            add   a,$90             ; Trick to convert 0-15 to ASCII '0'-'9', 'A'-'F'
            daa
            adc   a,$40
            daa
            call  outch
            ret
;
str_start:  db    CR,LF,'Testing timer interrupts',CR,LF,CR,LF,EOT
;
tick:       ds.w  1
;
end

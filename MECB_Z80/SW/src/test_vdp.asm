            include 'src/mecb.inc'
;
; ASCII control characters
BS          equ     $08               ; backspace
CR          equ     $0D               ; carraige return
LF          equ     $0A               ; form feed
ESC         equ     $1B               ; escape
SPACE       equ     $20               ; space
EOT         equ     $00               ; End of Text
;
            org   $C000
;
init:       ld    hl,str_start
            call  print
            call  setgmode7                  ; Set graphics mode 7 (8-bit colour 256 x 192)
;
clear:      ld    h,$80
loop:       ld    c,h
            call  outhex8
            call  fill
            inc   h
            call  pcrlf
            jr    loop

fill:       push  bc
            push  de
            push  af
;
            ld    bc,$2d00                   ; Set VRAM bank (VRAM, not Expansion RAM)
            call  vdp_write_reg
            ld    bc,$0e00                   ; Set VRAM write address to $00000
            call  vdp_write_reg
            ld    a,$00
            out   (VDP_REG),a
            ld    a,$40
            out   (VDP_REG),a
;
            ld    bc,$0000                   ; 256 * 192 pixels
fill2:      ld    a,h
            out   (VDP_VRAM),a
            dec   bc
            ld    a,b
            or    c
            jr    nz,fill2
            pop   af
            pop   de
            pop   bc
            ret
;
setgmode7:
            push  bc
            ld    bc,$000E             ; R0 - Graphics Mode 7 (0E)
            call  vdp_write_reg
            ld    bc,$0140             ; R1 - Graphics Mode 7, Display Area Enabled (40)
            call  vdp_write_reg
            ld    bc,$080A             ; R8 - 64K DRAM chips
            call  vdp_write_reg
            ld    bc,$0982             ; R9 - Non-interlaced NTSC LN=1 for 212 dots high
            call  vdp_write_reg
;            ld    bc,$0706             ; R7 - White Text / Black Backdrop
;            call  vdp_write_reg
            ld    bc,$021F             ; R2 - Name table start address = $0000 A16=0
            call  vdp_write_reg
;            ld    bc,$0140             ; R1 - Text Mode, 8x8 Sprites, 16KB VRAM, Display Area Enabled
;            call  vdp_write_reg
            pop   bc
            ret
;
; Function:	Write a data byte into a specified VDP register
; Parameters:  c - Data Byte
;              b - Register number
; Returns:     -
; Destroys:    -
vdp_write_reg:
            push     af
            ld       a,c
            out      (VDP_REG),a     ; Store data byte
            ld       a,b
            and      $3F
            or       $80
            out      (VDP_REG),a     ; Store masked register number
            pop      af
            ret
;
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
str_start:  db    CR,LF,'Setting up VDP',CR,LF,CR,LF,EOT
;
seed1_0     ds.w  1
seed1_1     ds.w  1
seed2_0     ds.w  1
seed2_1     ds.w  1
;
;Inputs:
;   (seed1_0) holds the lower 16 bits of the first seed
;   (seed1_1) holds the upper 16 bits of the first seed
;   (seed2_0) holds the lower 16 bits of the second seed
;   (seed2_1) holds the upper 16 bits of the second seed
;   **NOTE: seed2 must be non-zero
;Outputs:
;   HL is the result
;   BC,DE can be used as lower quality values, but are not independent of HL.
;Destroys:
;   AF
;Tested and passes all CAcert tests
;Uses a very simple 32-bit LCG and 32-bit LFSR
;it has a period of 18,446,744,069,414,584,320
;roughly 18.4 quintillion.
;LFSR taps: 0,2,6,7  = 11000101
rand32:
            push  bc
            push  de
            ld    hl,(seed1_0)
            ld    de,(seed1_1)
            ld    b,h
            ld    c,l
            add   hl,hl \ rl e \ rl d
            add   hl,hl \ rl e \ rl d
            inc   l
            add   hl,bc
            ld    (seed1_0),hl
            ld    hl,(seed1_1)
            adc   hl,de
            ld    (seed1_1),hl
            ex    de,hl
            ld    hl,(seed2_0)
            ld    bc,(seed2_1)
            add   hl,hl \ rl c \ rl b
            ld    (seed2_1),bc
            sbc   a,a
            and   $c5
            xor   l
            ld    l,a
            ld    (seed2_0),hl
            ex    de,hl
            add   hl,bc
            pop   de
            pop   bc
            ret
;
end

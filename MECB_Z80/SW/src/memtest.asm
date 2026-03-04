; Simple memory test program for the Z80
; It runs in bank 2 set to page $20 $(8000-$BFFF).
; The memory test is run in bank 3 ($C000-$FFFF) by switching the page in that bank
; Each page is filled with a sequence of random numbers
; it then reads through the written pages to ensure that the random sequence is still present.
; If paging fails or there is a memory error the program will report an error.
; A "." is output for each 16 KB page written or checked.
;------------------------------------------------------------------------------
; The MECB Z80 has a full memory set-up as:
; 0x00000-0x7FFFF - ROM
; 0x80000-0xFFFFF - RAM
; Both of which are partitioned into 32 x 16 KB pages
; i.e.
; 0x00000-0x03FFF ROM Page 00 
; 0x04000-0x07FFF ROM Page 01
; 0x08000-0x0BFFF ROM Page 02
; 0x0C000-0x0FFFF ROM Page 03
; 0x10000-0x13FFF ROM Page 04
; 0x14000-0x17FFF ROM Page 05
; 0x18000-0x1BFFF ROM Page 06
; 0x1C000-0x1FFFF ROM Page 07
; 0x20000-0x23FFF ROM Page 08
; 0x24000-0x27FFF ROM Page 09
; 0x28000-0x2BFFF ROM Page 0A
; 0x2C000-0x2FFFF ROM Page 0B
; 0x30000-0x33FFF ROM Page 0C
; 0x34000-0x37FFF ROM Page 0D
; 0x38000-0x3BFFF ROM Page 0E
; 0x3C000-0x3FFFF ROM Page 0F
; 0x40000-0x43FFF ROM Page 10
; 0x44000-0x47FFF ROM Page 11
; 0x48000-0x4BFFF ROM Page 12
; 0x4C000-0x4FFFF ROM Page 13
; 0x50000-0x53FFF ROM Page 14
; 0x54000-0x57FFF ROM Page 15
; 0x58000-0x5BFFF ROM Page 16
; 0x5C000-0x5FFFF ROM Page 17
; 0x60000-0x63FFF ROM Page 18
; 0x64000-0x67FFF ROM Page 19
; 0x68000-0x6BFFF ROM Page 1A
; 0x6C000-0x6FFFF ROM Page 1B
; 0x70000-0x73FFF ROM Page 1C
; 0x74000-0x77FFF ROM Page 1D
; 0x78000-0x7BFFF ROM Page 1E
; 0x7C000-0x7FFFF ROM Page 1F
; 0x80000-0x83FFF RAM Page 20 
; 0x84000-0x87FFF RAM Page 21
; 0x88000-0x8BFFF RAM Page 22
; 0x8C000-0x8FFFF RAM Page 23
; 0x90000-0x93FFF RAM Page 24
; 0x94000-0x97FFF RAM Page 25
; 0x98000-0x9BFFF RAM Page 26
; 0x9C000-0x9FFFF RAM Page 27
; 0xA0000-0xA3FFF RAM Page 28
; 0xA4000-0xA7FFF RAM Page 29
; 0xA8000-0xABFFF RAM Page 2A
; 0xAC000-0xAFFFF RAM Page 2B
; 0xB0000-0xB3FFF RAM Page 2C
; 0xB4000-0xB7FFF RAM Page 2D
; 0xB8000-0xBBFFF RAM Page 2E
; 0xBC000-0xBFFFF RAM Page 2F
; 0xC0000-0xC3FFF RAM Page 30
; 0xC4000-0xC7FFF RAM Page 31
; 0xC8000-0xCBFFF RAM Page 32
; 0xCC000-0xCFFFF RAM Page 33
; 0xD0000-0xD3FFF RAM Page 34
; 0xD4000-0xD7FFF RAM Page 35
; 0xD8000-0xDBFFF RAM Page 36
; 0xDC000-0xDFFFF RAM Page 37
; 0xE0000-0xE3FFF RAM Page 38
; 0xE4000-0xE7FFF RAM Page 39
; 0xE8000-0xEBFFF RAM Page 3A
; 0xEC000-0xEFFFF RAM Page 3B
; 0xF0000-0xF3FFF RAM Page 3C
; 0xF4000-0xF7FFF RAM Page 3D
; 0xF8000-0xFBFFF RAM Page 3E
; 0xFC000-0xFFFFF RAM Page 3F
; 
ACIAS       equ   $08
ACIAD       equ   ACIAS+1
;
PAGE_WR     equ   $78
PAGE_EN     equ   $7C
ACIA_RESET  equ   $03
ACIA_CTRL   equ   $51
;
CR          equ   $0D
LF          equ   $0A
EOT         equ   $00
;
START_PAGE  equ   $22
END_PAGE    equ   $3f
;
            org   $C000
;
            jp    init            ; Initialize Hardware and go

; On start-up the paging is disabled and the first page of ROM is repeated across all pages
; So the first initialisation step is to switch in more of the memory in the upper banks.
;
init:       ld    hl,str_hello      ; Write message
            call  print
;
            ld    hl,str_fill       ; Write message
            call  print
;
            call  init_seed         ; Reset the seed
            ld    a,START_PAGE      ; Start with page 1
            ld    (page),a
fill0:      ld    hl,str_wr
            call  print
            ld    c,a
            call  outhex8
            call  set_page          ; Set upper memory to current page            
            ld    de,$8000          ; Point to location to fill
            ld    bc,$2000          ; Number of words to test
fill1:      call  rand32            ; get a 16-bit random number in hl
            ex    de,hl             ; de = random; hl = memory ptr
            ld    (hl),e            ; Store random number in memory
            inc   hl
            ld    (hl),d            ; Store random number in memory
            ex    de,hl
            inc   de
            dec   bc
            ld    a,b
            or    c
            jr    nz,fill1          ; Fill memory until end of page reached
            ld    a,(page)
            cp    a,END_PAGE
            jr    z,read            ; If last page filled, read back data
            add   a,1
            ld    (page),a          ; Save page
            jr    fill0
;
read        ld    hl,str_wrd
            call  print
;
            call  init_seed
            ld    a,START_PAGE      ; Reset page
            ld    (page),a
read0:      ld    hl,str_rd
            call  print
            ld    c,a
            call  outhex8
            call  set_page          ; Set upper memory to current page
            ld    de,$8000         ; Point to the upper RAM
            ld    bc,$2000          ; Number of words to test
read1:      call  rand32            ; get a 16-bit random number in hl
            ex    de,hl
            ld    a,e
            cp    a,(hl)            ; Check if random number is the same as previously stored
            jr    nz,bad_mem
            ld    a,d
            inc   hl
            cp    a,(hl)            ; Check if random number is the same as previously stored
            jr    nz,bad_mem
            ex    de,hl
            inc   de
            dec   bc
            ld    a,b
            or    c
            jr    nz,read1          ; Fill memory until end of page reached
            ld    a,(page)
            cp    a,END_PAGE
            jr    z,good_mem        ; If last page read, memory is good
            add   a,1
            ld    (page),a          ; Save page
            jr    read0
;
good_mem:   ld    hl,str_rdd
            call  print
            ld    hl,str_good       ; Write message to indicate success
            call  print
            jr    done
;
bad_mem:    ld    hl,str_bad        ; Write message to indicate failure
            call  print
done        call  reset_page        ; Return paging to original state
            ret                     ; Return to monitor
;
;
init_seed:  ld    hl,12345
            ld    (seed1_0),hl
            ld    hl,6789
            ld    (seed1_1),hl
            ld    hl,9876
            ld    (seed2_0),hl
            ld    hl,54321
            ld    (seed2_1),hl
            ret
;
;------------------------------------------------------------------------------
print:      push  af
            push  hl
print1:     in    a,(ACIAS)         ; Status byte       
            bit   1,a               ; Set Zero flag if still transmitting character       
            jr    z,print1          ; Loop until flag signals ready
            ld    a,(hl)            ; Get character
            or    a                 ; Is it $00 ?
            jr    z,print_end       ; If so, move on to basic memory check

            out   (ACIAD),a         ; Output the character
            inc   hl                ; Next Character
            jr    print1            ; Continue until $00
print_end:  pop   hl
            pop   af
            ret
;
set_page:   ld    a,(page)
            out   (PAGE_WR+2),a
            ret
;
reset_page: ld    a,$00
            out   (PAGE_WR),a
            ld    a,$01
            out   (PAGE_WR+1),a
            ld    a,$20
            out   (PAGE_WR+2),a
            ld    a,$21
            out   (PAGE_WR+3),a
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
outch1:     in    a,(ACIAS)
            bit   1,a               ; Set Zero flag if still transmitting character       
            jr    z,outch1          ; Loop until flag signals ready
            pop   af
            out   (ACIAD),a         ; Output the character
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

str_hello:  dc.b  "Hello Z80 World!",CR,LF,0
str_fill:   dc.b  "=== Paged memory test ===",CR,LF,0
str_wr:     dc.b  CR,"Writing to page: $",0
str_wrd:    dc.b  CR,"Data written to all pages",CR,LF,0
str_rd:     dc.b  CR,"Reading from page: $",0
str_rdd:    dc.b  CR,"Data read from all pages ",CR,LF,0
str_bad:    dc.b  CR,LF,"Memory test failed!",CR,LF,0
str_good:   dc.b  CR,LF,"Memory test succeeded!",CR,LF,0
;
seed1_0     ds.w   1
seed1_1     ds.w   1
seed2_0     ds.w   1
seed2_1     ds.w   1
stack       ds.w   1
page        ds.b   1
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
            and   %11000101
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

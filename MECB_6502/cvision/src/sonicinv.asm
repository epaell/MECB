     ifd COMBINED
;
            org $3000
;
; SMON IQR
;
IRQ_LO      equ $0314        ; Vector: Hardware IRQ Interrupt Address Lo
IRQ_HI      equ $0315        ; Vector: Hardware IRQ Interrupt Address Hi
start       ldx #<IRQ_VEC        ; Set up IRQ vector in SMON
            stx IRQ_LO
            ldx #>IRQ_VEC
            stx IRQ_HI
            jmp reset
;
            org $4000
;
    else
VDP_RD_VRAM equ $2000
VDP_RD_REG  equ $2001
VDP_WR_VRAM equ $3000
VDP_WR_REG  equ $3001
;
; BIOS locations
;
lf808       equ $f808
lfa00       equ $fa00
lfce6       equ $fce6
lfd4d       equ $fd4d
lfd86       equ $fd86
lfdc4       equ $fdc4
lfdc8       equ $fdc8
lfdd9       equ $fdd9
lfdec       equ $fdec
lfe1f       equ $fe1f
lfe3c       equ $fe3c
lfe54       equ $fe54
lfe77       equ $fe77
lfe83       equ $fe83
lfead       equ $fead
lff58       equ $ff58
vdp_write_ram equ   $fd82
;
            org $B000
;
    endif
;
PIA_REGA    equ $1000       ; data reg A
PIA_DDRA    equ $1000       ; data dir reg A
PIA_CTLA    equ $1001       ; control reg A
PIA_REGB    equ $1002       ; data reg B
PIA_DDRB    equ $1002       ; data dir reg B
PIA_CTLB    equ $1003       ; control reg B
;
;
;
lb000       dc.b $c0,$00,$00,$2f,$00 ; Write $2f00 x $00 to $0000 - clear display
            dc.b $c2,$80,$80,$00,$fa ; Write $0080 x $fa to $0080
            dc.b $c0,$00,$40,$00,$e5 ; Write $0040 x $e5 to $0000
            dc.b $c1,$80,$28,$00,$e5 ; Write $0028 x $e5 to $0180
            dc.b $c3,$90,$08,$00,$0e ; Write $0008 x $0e to $0390
            dc.b $c3,$00,$40,$00,$f0 ; Write $0040 x $f0 to $0300
            dc.b $d7,$00,$0c,$00,$08 ; Write $000C x $08 to $1700
            dc.b $d7,$20,$08,$00,$ff ; Write $0008 x $ff to $1720 - 
            dc.b $00                 ; End
;
; $c0 register (vram)
; $00 = write to $0000
; $00 = LSB count
; $2f = MSB count
; $00 = value
rom_pstart  beq lb038

lb02b       jsr lb947               ; Program begins here
            jsr lb934               ; This is where thing go unwell.
            inc $c1
            inc $c8
            jmp lb040

lb038       jsr lb947
            jsr lb900
            inc $e0
lb040       cli
            jmp lb040

lb044       lda #$03
            and $0d
            beq lb04c
            lda #$20
lb04c       tay
            jsr lb26a               ; Start drawing display
            lda $0d
            and #$03
            beq lb06d
            pha
            jsr lb7e6
            lda #$03
            sta $6c
            pla
            cmp #$02
            bpl lb0a6
            jsr lb7bc
            lda #$90
            jsr vdp_write_ram
            bne lb0a6
lb06d       jsr lb93f
            jsr lb7a3
            lda #$20
            ldx #$c3                ; Set VRAM write to 00 0011 0010 0000 = $0320
            jsr lfe1f
            jmp lb25c
;
lb07d       lda $3b
            beq lb09a
            and #$0f
            cmp #$08
            bpl lb092
            lda $83
            cmp #$e4
            beq lb09a
            inc $83
            jmp lb09a

lb092       lda $83
            cmp #$10
            beq lb09a
            dec $83
lb09a       lda $83
            sta $30
            lda $8d
            bne lb0a6
            lda $f2
            bne lb0a7
lb0a6       rts

lb0a7       lda $84
            ldx #$c3
            jsr lfe1f
            lda #$a0
            sta $86
            jsr vdp_write_ram
            lda $83
            adc #$02
            sta $87
            jsr vdp_write_ram
            sta $3e
            and #$07
            sta $85
            lda #$06
            jsr vdp_write_ram
            lda #$0f
            jsr vdp_write_ram
            inc $8d
            jsr lbb0a
            rts

lb0d4       lda $84
            ldx #$c3
            jsr lfe1f
            lda $8d
            cmp #$01
            bne lb13d
            lda $86
            bmi lb103
            cmp #$10
            bpl lb103
            lda $f3
            adc #$fd
            cmp $87
            bpl lb103
            adc #$17
            cmp $87
            bmi lb103
            inc $8f
            lda #$10
            jsr lb1f9
lb0fe       ldx #$00
            jmp lb258

lb103       dec $86
            dec $86
            dec $86
            dec $86
            beq lb0fe
            lda $86
            jsr vdp_write_ram
            lda $84
            ldx #$83
            jsr lfe1f
            jsr lbaa9
            sta $05
            nop
            nop
            jsr lbaa9
            sta $04
            jsr lfdec
            jsr lbb6b
            jsr lbaa9
            sta $3f
            bpl lb13e
            lda #$06
            sta $4d
            jsr lb1d0
            cpx #$09
            bmi lb1af
lb13d       rts

lb13e       tax
            lda $32
            lsr
            bcs lb13d
            txa
            and #$0f
            cmp #$02
            bmi lb13d
            cmp #$08
            bmi lb15b
            cmp #$0a
            bmi lb16f
            ldx $85
            cpx #$04
            bmi lb13d
            bpl lb16f
lb15b       cmp #$04
            bpl lb16a
            ldx $85
            cpx #$05
            bpl lb1b1
            dec $04
            jsr lb1b2
lb16a       dec $04
            jsr lb1b2
lb16f       lda $85
            eor #$ff
            adc $87
            sta $87
            lda $3f
            and #$10
            beq lb18e
            lda $86
            adc #$f8
            sta $86
            lda $04
            clc
            adc #$e0
            bcs lb18c
            dec $05
lb18c       sta $04
lb18e       jsr lb1b9
            lda $04
            clc
            adc #$20
            bcc lb19a
            inc $05
lb19a       sta $04
            jsr lb1b9
            lsr
            lsr
            lsr
            lsr
            lsr
            tax
            inx
            txa
            jsr lb1f9
            jsr lbafb
            dec $4f
lb1af       inc $8d
lb1b1       rts

lb1b2       lda $87
            adc #$f8
            sta $87
            rts

lb1b9       jsr lbb6b
            jsr lbaa9
            and #$f0
            pha
            jsr lbb71
            pla
            jsr vdp_write_ram
            jsr vdp_write_ram
            jsr vdp_write_ram
            rts

lb1d0       ldx #$00
            lda $3f
            and #$df
lb1d6       cmp lb31a,x
            beq lb1e1
            inx
            cpx #$09
            bne lb1d6
            rts

lb1e1       cpx #$03
            bpl lb1e9
            lda $4d
            bne lb1eb
lb1e9       lda #$06
lb1eb       sta $4c
            jsr lbb71
            clc
            lda $4c
            adc $3f
            jsr vdp_write_ram
            rts

lb1f9       sed
            clc
            adc $89
            tax
            bcc lb206
            lda $8a
            adc #$00
            sta $8a
lb206       stx $89
            cld
            rts
;
lb20a       lda $8d
            cmp #$02
            bmi lb22c
            lda $40
            and #$01
            bne lb22c
            lda $84
            ldx #$c3
            jsr lfe1f
            ldx #$00
            lda $86
            adc #$f8
            sta $70
            lda $87
            sta $71
            jsr lb22d
lb22c       rts

lb22d       ldy $8d,x
            lda lb959,y
            cmp #$fe
            beq lb258
            cmp #$ff
            beq lb267
            adc $70
            jsr vdp_write_ram
            lda lb96c,y
            adc $71
            jsr vdp_write_ram
            lda lb97f,y
            jsr vdp_write_ram
            lda lb992,y
            jsr vdp_write_ram
            inc $8d,x
            jmp lb22d

lb258       lda #$00
            sta $8d,x
lb25c       ldx #$0f
            lda #$f0
lb260       jsr vdp_write_ram
            dex
            bpl lb260
            rts


lb267       inc $8d,x
            rts


lb26a       lda #$c0   
            ldx #$c2            ; Set up write to VRAM 000010 1100 0000 = $02C0
            jsr lfe1f
            ldx #$00
lb273       lda lb353,y         ; copy values from lb353+y to VRAM
            jsr vdp_write_ram
            iny
            inx
            cpx #$20            ; Write 0x20 bytes
            bne lb273
            rts                 ; returnm

lb280       lda #$80
            ldx #$c3
            jsr lfe1f
            ldx #$00
lb289       lda lb323,x
            ldy $3c
            beq lb292
            lda #$10
lb292       jsr vdp_write_ram
            inx
            cpx #$10
            bne lb289
            rts

lb29b       lda #$2d
            sta $4f
            lda #$00
            sta $32
            lda #$01
            sta $40
            ldx #$09
lb2a9       sta $d0,x
            dex
            bpl lb2a9
            lda $3a
            clc
            adc #$20
            cmp #$a0
            bne lb2b9
            lda #$40
lb2b9       sta $3a
            sta $41
            sta $79
            ldx #$c0
            jsr lfe1f
            lda #$00
            sta $42
            sta $7a
            ldy #$08
            jsr lb2d3
            ldy #$02
            lda #$00
lb2d3       sta $70
            ldx #$00
lb2d7       lda lb333,x
            clc
            adc $70
            jsr vdp_write_ram
            inx
            cpx #$20
            bne lb2d7
            dey
            beq lb2ef
            lda $70
            clc
            adc #$10
            bne lb2d3

lb2ef       rts
;
            dc.b $a7,$a1,$ad,$a5,$80,$80,$af,$b6,$a5,$b2

lb2fa       dc.b $a0,$28,$00,$01,$a8,$28,$01,$01
            dc.b $a0,$c8,$00,$0d,$a8,$c8,$01,$0d
            dc.b $08,$00,$03,$06,$08,$08,$04,$06
            dc.b $08,$10,$05,$06,$00,$08,$02,$0a
;
lb31a       dc.b $d0,$d1,$d2,$d3,$d4,$d5,$d6,$d7,$d8
;
lb323       dc.b $d0,$d0,$d0,$d0,$70,$70,$70,$70
            dc.b $c0,$c0,$c0,$c0,$a0,$a0,$a0,$a0
;
lb333       dc.b $00,$00,$00,$08,$04,$00,$08,$04
            dc.b $00,$08,$04,$00,$08,$04,$00,$08
            dc.b $04,$00,$08,$04,$00,$08,$04,$00
            dc.b $08,$04,$00,$08,$04,$00,$00,$00
;
lb353       dc.b $80,$80,$80,$bf,$bf,$bf,$80,$90
            dc.b $90,$90,$90,$90,$80,$80,$a8,$a9
            dc.b $80,$b3,$a3,$af,$b2,$a5,$80,$80
            dc.b $80,$80,$80,$90,$80,$80,$80,$80
;
            dc.b $80,$80,$80,$bf,$bf,$bf,$80,$80
            dc.b $80,$80,$80,$80,$80,$80,$80,$80
            dc.b $80,$80,$80,$ff,$ff,$ff,$80,$90
            dc.b $90,$90,$90,$90,$80,$80,$80,$80
;
lb393       dc.b $01,$05,$0b,$00,$0b,$07,$01,$00
;
lb39b       lda $4f
            cmp #$08
            bmi lb3ac
            cmp #$10
            bmi lb3af
            lda $40
            lsr
            lsr
            bcc lb3af
            rts

lb3ac       jsr lb3af
lb3af       lda $79
            sta $04
            lda $7a
            sta $05
            lda $31
            bmi lb3c1
            jsr lb488
            jmp lb3c4

lb3c1       jsr lb48c
lb3c4       lda $37
            bne lb3d0
            ldx $32
            lda #$00
            sta $d0,x
            beq lb3dc
lb3d0       lda $79
            sta $75
            lda $7a
            sta $76
            lda $32
            sta $90
lb3dc       inc $32
            ldx $32
            cpx #$0a
            beq lb3f4
            lda $79
            clc
            adc #$20
            bne lb3ed
            inc $7a

lb3ed       sta $79
            ldy $d0,x
            beq lb3dc
            rts

lb3f4       lda $38
            bne lb400
            inc $91
            bne lb400
            jsr lb29b
            rts

lb400       lda #$00
            sta $38
            sta $32
            lda $33
            beq lb417
            lda $31
            eor #$fe
            sta $31
            lda #$00
            sta $33
            jsr lb514
lb417       lda $41
            sta $79
            lda $42
            sta $7a
lb41f       rts
;
lb420       lda $8e
            bne lb47d
            lda $40
            and #$02
            bne lb41f
            jsr lb07d
            ldy $80
            iny
            jsr lb437
lb433       iny
            iny
            iny
            iny
;
lb437       tya
            ldx #$c3
            jsr lfe1f
            lda $30
            jsr vdp_write_ram
            rts
;
lb443       lda $8f
            bne lb47d
            lda $f3
            cmp #$ec
            bne lb454
            inc $e1
            bne lb47e
            jsr lb7f8

lb454       ldy #$41
            lda $f3
            sta $30
            jsr lb437
            lda $f3
            clc
            adc #$08
            sta $30
            jsr lb433
            lda $f3
            clc
            adc #$10
            sta $30
            jsr lb433
            lda $f3
            clc
            adc #$08
            sta $30
            jsr lb433
            inc $f3
lb47d       rts

lb47e       lda #$40
            ldx #$c3
            jsr lfe1f
            jmp lb25c

lb488       ldx #$00
            beq lb495
lb48c       ldx #$04
            lda $04
            clc
            adc #$1f
            sta $04
lb495       ldy #$04
lb497       lda lb393,x
            sta $0070,y
            inx
            dey
            bne lb497
            lda #$00
            sta $37
            tay
            sta $3d
lb4a8       jsr lbb6b
            nop
            nop
            jsr lbaa9
            sta $3f
            and #$f0
            sta $36
            lda $3d
            beq lb4c3
            lda $74
            ora $36
            sta $3f
            jmp lb4e3

lb4c3       lda $3f
            bmi lb504
            and #$0f
            beq lb4cf
            cmp $72
            bne lb4d8
lb4cf       lda $71
            ora $36
            sta $3f
            jmp lb4e3

lb4d8       lda $3f
            clc
            adc $31
            sta $3f
            inc $37
            inc $38
lb4e3       jsr lbb71
            lda $3f
            jsr vdp_write_ram
            lda $31
            bmi lb4f4
            inc $04
            jmp lb4f6

lb4f4       dec $04
lb4f6       lda #$00
            sta $3d
            lda $3f
            and #$0f
            cmp $73
            bne lb504
            inc $3d
lb504       iny
            cpy #$20
            bne lb4a8
            lda $3f
            bmi lb513
            and #$0f
            beq lb513
            inc $33
lb513       rts

lb514       lda $4f
            cmp #$06
            bmi lb520
            lda $39
            cmp #$03
            bmi lb58e
lb520       lda $76
            cmp #$02
            bne lb531
            lda $75
            cmp #$40
            bne lb531
            inc $58
            inc $68
            rts

lb531       lda $76
            sta $71
            lda $75
            clc
            adc #$1f
            bcc lb53e
            inc $71
lb53e       sta $70
            inc $90
            lda #$20
            sta $72
lb546       lda $70
            sta $04
            lda $71
            sta $05
            jsr lbb6b
            ldx VDP_RD_VRAM 
            lda $04
            clc
            adc #$20
            bcc lb55d
            inc $05
lb55d       sta $04
            jsr lbb71
            stx VDP_WR_VRAM 
            dec $72
            bne lb571
            lda #$20
            sta $72
            dec $90
            bmi lb57f
lb571       lda $70
            clc
            adc #$ff
            bcs lb57a
            dec $71
lb57a       sta $70
            jmp lb546

lb57f       lda #$01
            sta $39
            lda $41
            clc
            adc #$20
            bne lb58c
            inc $42
lb58c       sta $41
lb58e       rts
;
lb58f       ldx $4e
            inx
            cpx #$05
            bne lb599
            rts
;
lb597       ldx #$00
lb599       stx $4e
            lda $7b,x
            beq lb58f
            txa
            clc
            adc #$1b
            asl
            asl
            sta $04
            pha
            lda #$03
            sta $05
            pha
            jsr lbb6b
            ldy VDP_RD_VRAM 
            sty $05
            bpl lb5fc
            cpy #$b0
            bpl lb608
            cpy #$a8
            bpl lb5e0
            cpy #$90
            bmi lb5fc
            jsr lbaa9
            sta $04
            jsr lfdec
            jsr lbb6b
            jsr lbaa9
            sta $3f
            lda #$03
            sta $4d
            jsr lb1d0
            cpx #$09
            bmi lb608
            bpl lb5fc
lb5e0       lda $8e
            bne lb5fc
            ldx VDP_RD_VRAM 
            inx
            txa
            cmp $83
            bmi lb5fc
            sta $70
            lda $83
            clc
            adc #$07
            cmp $70
            bmi lb5fc
            inc $8e
            bne lb608
lb5fc       iny
            iny
            lda $0d
            and #$08
            beq lb610
            iny
            iny
            bne lb610
lb608       ldx $4e
            ldy #$00
            sty $7b,x
            dec $77
lb610       pla
            sta $05
            pla
            sta $04
            jsr lbb71
            nop
            sty VDP_WR_VRAM 
            jmp lb58f
;
lb620       lda $4f
            cmp #$04
            bmi lb62c
            lda $40
            and #$07
            bne lb664
lb62c       lda $77
            cmp #$05
            beq lb664
            lda #$03
            sta $70
            lda $02
            and #$38
            adc $83
            lsr
            lsr
            lsr
            sta $3e

lb641       clc
            adc #$60
            sta $04
            lda #$12
            sta $71
            lda #$02
            sta $05

lb64e       jsr lbb6b
            jsr lbaa9
            bmi lb665
            and #$0f
            sta $73
            beq lb665
            cmp #$04
            bmi lb664
            cmp #$08
            bmi lb68d
lb664       rts

lb665       dec $71
            beq lb677
            lda $04
            clc
            adc #$e0
            bcs lb672
            dec $05
lb672       sta $04
            jmp lb64e

lb677       dec $70
            beq lb664
            lda $31
            clc
            adc $3e
            bmi lb664
            cmp #$20
            bpl lb664
            sta $3e
            lda $31
            jmp lb641

lb68d       ldx #$04
lb68f       lda $7b,x
            beq lb698
            dex
            bmi lb6c6
            bpl lb68f
lb698       inc $7b,x
            jsr lfdd9
            txa
            clc
            adc #$1b
            asl
            asl
            ldx #$c3
            jsr lfe1f
            lda $05
            jsr vdp_write_ram
            lda $04
            lsr $73
            ldx $73
            clc
            adc lb953,x
            jsr vdp_write_ram
            lda #$07
            jsr vdp_write_ram
            lda #$09
            jsr vdp_write_ram
            inc $77
lb6c6       rts

lb6c7       lda $8e
            beq lb6c6
            lda $40
            and #$03
            bne lb6c6
            jsr lbafb
            lda $80
            ldx #$c3
            jsr lfe1f
            lda #$a0
            sta $70
            lda $83
            sta $71
            ldx #$01
            jsr lb22d
            lda $8e
            bne lb6c6
            lda #$20
            sta $e2
            lda $8c
            beq lb706
            dec $8c
            lda $80
            beq lb700
            jsr lb833
            jmp lb7e6

lb700       jsr lb82c
            jmp lb7d5

lb706       inc $88
            lda $84
            ldx #$c3
            jsr lfe1f
            lda #$f0
            jsr vdp_write_ram
lb714       rts

lb715       lda $8f
            beq lb714
            jsr lbafb
            lda #$40
            ldx #$c3
            jsr lfe1f
            lda #$00
            sta $70
            lda $f3
            sta $71
            ldx #$02
            jsr lb22d
            lda $8f
            bne lb714
            lda #$ec
            sta $f3
            rts

lb739       ldx #$00
lb73b       lda $50,x
            sta $80,x
            inx
            cpx #$0f
            bne lb73b
            lda #$00
            sta $80
            lda #$10
            sta $84
            lda $11
            sta $3b
            lda $16
            and #$0f
            sta $f2
            rts
;
lb757       ldx #$00
lb759       lda $60,x
            sta $80,x
            inx
            cpx #$0f
            bne lb759
            lda #$20
            sta $80
            lda #$30
            sta $84
            lda $13
            sta $3b
            lda $17
            and #$0f
            sta $f2
            rts

lb775       ldy #$00
            beq lb77b
lb779       ldy #$10
lb77b       ldx #$00
lb77d       lda $80,x
            sta $0050,y
            iny
            inx
            cpx #$10
            bne lb77d
            rts
;
lb789       lda #$00
            sta $3c
            lda $0d
            and #$04
            beq lb79d
            ldx $40
            cpx #$10
            beq lb7a0
            cpx #$40
            beq lb79e
lb79d       rts

lb79e       inc $3c
lb7a0       jmp lb280
;
lb7a3       lda $fa,x
            sta $71
            lda $f6,x
            sta $70
            jmp lb7b6

lb7ae       lda $6a
            sta $71
            lda $69
            sta $70
lb7b6       lda #$d7
            ldx #$c2
            bne lb7c8
lb7bc       lda $5a
            sta $71
            lda $59
            sta $70
            lda #$c7
            ldx #$c2
lb7c8       jsr lfe1f
            lda $71
            jsr lfead
            lda $70
            jmp lfead

lb7d5       lda #$28
            sta $53
            sta $83
            lda #$00
            sta VDP_WR_REG
            tay
            ldx #$08
            jmp lb805

lb7e6       lda #$c8
            sta $63
            sta $83
            lda #$20
            sta VDP_WR_REG
            ldy #$08
            ldx #$08
            jmp lb805

lb7f8       lda #$00
            sta $f3
            lda #$40
            sta VDP_WR_REG
            ldy #$10
            ldx #$10
lb805       lda #$43
            sta VDP_WR_REG
lb80a       lda lb2fa,y
            jsr vdp_write_ram
            iny
            dex
            bne lb80a
            rts
;
lb815       sed
            lda $59
            clc
            adc $69
            sta $69
            lda $6a
            adc #$00
            sta $6a
            cld
            lda #$00
            sta $59
            jsr lb7ae
            rts
;
lb82c       lda #$c0
            sta $04
            jmp lb837

lb833       lda #$d0
            sta $04
lb837       lda #$02
            sta $05
lb83b       jsr lbb6b
            jsr lbaa9
            cmp #$bf
            beq lb84e
            cmp #$ff
            beq lb84e
            inc $04
            jmp lb83b

lb84e       jsr lbb71
            lda #$80
            jsr vdp_write_ram
            rts

lb857       jsr lfe54
            lda $0d
            and #$03
            bne lb87c
            jsr lb93f
            lda $5a
            cmp $fa,x
            bmi lb8a5
            bne lb871
            lda $59
            cmp $f6,x
            bmi lb8a5
lb871       lda $59
            sta $f6,x
            lda $5a
            sta $fa,x
            jmp lb8a5

lb87c       cmp #$03
            bne lb8a5
            lda $f0
            beq lb89b
            lda $f4
            sta $59
            lda $f5
            sta $5a
            jsr lb7bc
            lda #$90
            jsr vdp_write_ram
            lda #$00
            sta $f0
            jmp lb8a5


lb89b       lda $69
            sta $f4
            lda $6a
            sta $f5
            inc $f0
lb8a5       lda #$88
            ldx #$c2
            jsr lfe1f
            ldx #$01
lb8ae       lda lb2ef,x
            jsr vdp_write_ram
            inx
            cpx #$0b
            bne lb8ae
            inc $49
            jmp lb9da
;
lb8be       ldy #$11
            lda $48
            cmp #$70
            beq lb8d1
            bpl lb8d9
            tya
            ldx #$07
            jsr lfe1f
            inc $48
            rti

lb8d1       ldx #$e0
            inc $48
            jsr lfce6
lb8d8       rti

lb8d9       lda $c1
            beq lb8e4
            inc $c2
            bne lb8d8
            jmp lb02b

lb8e4       lda $15
            bne lb8f8
            lda $14
            ora $12
            bpl lb8d8

lb8ee       sei
            jsr lb947
            jsr lb934
            jmp lb040
;
lb8f8       sei
            lda #$00
            sta $0d
            jmp lb038

lb900       jsr lfd86       ; clear display?
            lda #$11
            ldx #$07
            jsr lfe1f
            lda #$00
            ldx #$d4
            jsr lfe3c
            jsr lfd4d
            jsr lbab0
            lda #$20
            sta $3a
            jsr lb29b
            jsr lb280
            inc $31
            lda #$03
            sta $5c
            jsr lb7d5
            lda #$e0
            ldx #$01
            jsr lfe1f
            jmp lb044

lb934       jsr lb900
            jsr lfe54
            ldx #$e3
            jmp lfce6
;
lb93f       lda #$0c
            and $0d
            lsr
            lsr
            tax
            rts

lb947       ldx #$ef
            lda #$00
lb94b       sta $00,x
            dex
            cpx #$0f
            bne lb94b
            rts

lb953       dc.b $f8,$fc,$00,$04,$08,$0c

lb959       dc.b $ff,$ff,$ff,$00,$00,$08,$08,$ff
            dc.b $00,$00,$08,$08,$ff,$00,$00,$08
            dc.b $08,$ff,$fe
;
lb96c       dc.b $ff,$ff,$ff,$00,$08,$00,$08,$ff
            dc.b $00,$08,$00,$08,$ff,$00,$08,$00
            dc.b $08,$ff,$fe
;
lb97f       dc.b $ff,$ff,$ff,$08,$0a,$07,$0b,$ff
lb980       dc.b $0c,$0e,$0d,$0f,$ff,$10,$12,$11
lb988       dc.b $13,$ff,$fe
;
lb992       dc.b $ff,$ff,$ff,$08,$08,$08,$08,$ff
            dc.b $08,$08,$08,$08,$ff,$08,$08,$08
            dc.b $08,$ff,$fe
;
lb9a5       lda VDP_RD_REG
            jsr lfa00
            jsr lbb18
            jsr lff58
            inc $40
            lda $e0
            beq lb9c7
            jsr lfe83
            jsr lb044
            lda $12
            ora $14
            bpl lb9c6
            jmp lb8ee
lb9c6       rti

lb9c7       lda $40
            bne lb9cd
            inc $39
lb9cd       lda $49
            beq lb9d4
            jmp lb8be
lb9d4       lda $e2
            beq lb9e8
            dec $e2
lb9da       lda $32
            ror
            bcc lb9e7
            jsr lb39b
            inc $40
            rti

lb9e5       inc $91
lb9e7       rti

lb9e8       jsr lb39b
            lda $91
            beq lb9e5
            jsr lb789
            jsr lb443
            jsr lb715
            lda $c1
            beq lba10
            lda $c8
            ldy $53
            cpy #$e4
            beq lba08
            cpy #$10
            bne lba0c
lba08       eor #$0d
            sta $c8
lba0c       sta $11
            sta $16
lba10       lda $0d
            and #$03
            sta $f1
            beq lba37
            jsr lb757
            jsr lb0d4
            jsr lb20a
            lda $68
            bne lba34
            jsr lba9f
            lda $58
            bne lba31
            lda $40
            ror
            bcc lba34
lba31       jsr lb597
lba34       jsr lb779
lba37       jsr lb739
            jsr lb0d4
            jsr lb20a
            lda $58
            bne lba57
            jsr lba9f
            lda $f1
            beq lba54
            lda $68
            bne lba54
            lda $40
            ror
            bcs lba57

lba54       jsr lb597

lba57       jsr lb775
            lda $f1
            bne lba64
            jsr lb7bc
            jmp lba86

lba64       dec $f1
            bne lba71
            jsr lb7bc
            jsr lb7ae
            jmp lba82

lba71       dec $f1
            bne lba7b
            jsr lb815
            jmp lba82

lba7b       dec $f1
            bne lba82
            jsr lb815
lba82       lda $68
            beq lba9e
lba86       lda $58
            beq lba9e
            jsr lb0d4
            jsr lb20a
            jsr lb715
            lda $8f
            bne lba86
            lda $8d
            bne lba86
            jmp lb857
lba9e       rti

lba9f       jsr lb420
            jsr lb6c7
            jsr lb620
            rts

lbaa9       lda VDP_RD_VRAM 
            jsr lbaaf
lbaaf       rts

lbab0       lda #<lbb80
            sta $c3
            lda #>lbb80
            sta $c4                         ; lbb80 ROMREF
            lda #$10
            sta $05
lbabc       lda #$10
            sta $04
            jsr lfdc8
            lda #$05
            sta $c6
lbac7       lda #$01
            sta $c5
lbacb       ldy #$00
            ldx #$04
lbacf       jsr lbb65
            dex
            bne lbacf
lbad5       lda ($c3),y
            jsr vdp_write_ram
            iny
            cpy #$04
            bne lbad5
            dec $c5
            beq lbacb
            lda $c3
            clc
            adc #$04
            sta $c3
            bne lbaee
            inc $c4
lbaee       cmp #$d0
            beq lbafa
            dec $c6
            bne lbac7
            inc $05
            bne lbabc
lbafa       rts

lbafb       lda #$f0
            jsr lfe77
            lda #$e5
            jsr lfe77
            lda #$6f
            sta $cc
            rts
;
lbb0a       lda #$b0
            jsr lfe77
            lda #$03
            sta $ca
            lda #$a0
            sta $cb
            rts
;
lbb18       lda $cb
            beq lbb3b
            jsr lfe77
            tax
            lda $ca
            jsr lfe77
            txa
            clc
            adc #$08
            sta $cb
            cmp #$b0
            bne lbb3b
            inc $ca
            lda $ca
            cmp #$0d
            beq lbb4c
            lda #$a0
            sta $cb


lbb3b       lda $cc
            beq lbb4b
            bmi lbb57
            inc $cc
            lda #$f0
            sta $cd
            lda #$10
            sta $ce


lbb4b       rts


lbb4c       lda #$bf
            jsr lfe77
            lda #$00
            sta $cb
            beq lbb3b


lbb57       lda $cd
            jsr lfe77
            inc $cd
            bne lbb4b
            lda #$00
            sta $cc
            rts


lbb65       sty VDP_WR_VRAM 
            jmp lbb74


lbb6b       jsr lfdc4
            jmp lbb74


lbb71       jsr lfdc8


lbb74       jsr lbb77


lbb77       nop
            rts
;
lbb79       dc.b $ff,$00,$00,$ff,$ff,$00,$00
lbb80       dc.b $00,$00,$c0,$f0,$c0,$f0,$fc,$8f
            dc.b $3c,$ff,$ff,$18,$03,$0f,$3f,$f1
            dc.b $00,$00,$03,$0f,$00,$c0,$f0,$30
            dc.b $30,$3c,$8f,$c3,$c3,$c3,$18,$3c
            dc.b $0c,$3c,$f1,$c3,$00,$03,$0f,$0c
            dc.b $40,$40,$60,$60,$04,$24,$26,$f6
            dc.b $00,$42,$42,$ff,$20,$24,$64,$6f
            dc.b $02,$02,$06,$06,$c0,$e0,$f0,$30
            dc.b $8c,$de,$ff,$e3,$18,$bd,$ff,$7f
            dc.b $31,$7b,$ff,$c7,$03,$07,$0f,$0c
;
lbbd0       dc.b $d0,$90,$50,$70,$30,$f0,$f0,$f0
            dc.b $c0,$80,$00,$70,$30,$f0,$f0,$00
            dc.b $c0,$f0,$f0,$c7,$e3,$ff,$ff,$f0
            dc.b $7c,$1f,$0f,$c7,$e3,$ff,$ff,$ff
            dc.b $7c,$38,$30,$3c,$7e,$ff,$ff,$ff
            dc.b $e7,$c3,$c3,$3c,$7e,$ff,$ff,$ff
            dc.b $e7,$81,$00,$e3,$c7,$ff,$ff,$0f
            dc.b $3e,$f8,$f0,$e3,$c7,$ff,$ff,$ff
            dc.b $3e,$1c,$0c,$0e,$0c,$0f,$0f,$0f
            dc.b $03,$01,$00,$0e,$0c,$0f,$0f,$00
            dc.b $03,$0f,$0f,$d1,$90,$50,$30,$f0
            dc.b $70,$60,$e0,$c0,$80,$00,$30,$f0
            dc.b $70,$60,$c0,$80,$f0,$70,$f3,$ff
            dc.b $c7,$c6,$fc,$f8,$9f,$87,$f3,$ff
            dc.b $c7,$c6,$fe,$fc,$b8,$b0,$ff,$ff
            dc.b $3c,$3c,$ff,$ff,$db,$db,$ff,$ff
            dc.b $3c,$3c,$ff,$ff,$99,$18,$cf,$ff
            dc.b $e3,$63,$3f,$1f,$f9,$e1,$cf,$ff
            dc.b $e3,$63,$7f,$3f,$1d,$0d,$0c,$0f
            dc.b $0e,$06,$07,$03,$01,$00,$0c,$0f
            dc.b $0e,$06,$03,$01,$0f,$0e,$d2,$90
            dc.b $50,$f0,$f0,$70,$30,$00,$c0,$f0
            dc.b $f0,$f0,$f0,$70,$30,$00,$c0,$f0
            dc.b $f0,$ff,$8f,$c7,$e3,$ff,$7c,$38
            dc.b $30,$ff,$8f,$c7,$e3,$f0,$7c,$1f
            dc.b $0f,$ff,$18,$3c,$7e,$ff,$e7,$81
            dc.b $00,$ff,$18,$3c,$7e,$ff,$e7,$c3
            dc.b $c3,$ff,$f1,$e3,$c7,$ff,$3e,$1c
            dc.b $0c,$ff,$f1,$e3,$c7,$0f,$3e,$f8
            dc.b $f0,$0f,$0f,$0e,$0c,$00,$03,$0f
            dc.b $0f,$0f,$0f,$0e,$0c,$0f,$03,$01
            dc.b $00,$d3,$90,$50,$70,$f0,$e0,$c0
            dc.b $80,$c0,$80,$00,$70,$f0,$e0,$c0
            dc.b $80,$c0,$f0,$30,$c7,$8f,$fe,$fc
            dc.b $f8,$9c,$0f,$03,$c7,$8f,$fe,$fc
            dc.b $f8,$9c,$38,$30,$3c,$18,$ff,$ff
            dc.b $ff,$99,$c3,$c3,$3c,$18,$ff,$ff
            dc.b $ff,$99,$00,$00,$e3,$f1,$7f,$3f
            dc.b $1f,$39,$f0,$c0,$e3,$f1,$7f,$3f
            dc.b $1f,$39,$1c,$0c,$0e,$0f,$07,$03
            dc.b $01,$03,$01,$00,$0e,$0f,$07,$03
            dc.b $01,$03,$0f,$0c,$d5,$f8,$18,$08
            dc.b $08,$1c,$1c,$1c,$7f,$49,$49,$00
            dc.b $54,$00,$14,$00,$50,$00,$54,$00
            dc.b $50,$00,$54,$00,$14,$00,$00,$d6
            dc.b $40,$10,$00,$40,$00,$00,$00,$00
            dc.b $00,$00,$00,$45,$00,$51,$00,$55
            dc.b $00,$54,$d6,$80,$48,$e7,$e7,$ff
            dc.b $7f,$3f,$1c,$0c,$0f,$39,$39,$ff
            dc.b $ff,$ff,$c6,$c6,$ff,$ce,$ce,$fe
            dc.b $fc,$f8,$70,$60,$e0,$07,$07,$0f
            dc.b $0f,$3f,$1c,$0c,$0f,$00,$00,$0c
            dc.b $ff,$ff,$c6,$c6,$ff,$80,$80,$c0
            dc.b $f0,$f8,$70,$60,$e0,$e7,$e7,$ff
            dc.b $7f,$03,$00,$00,$00,$39,$39,$ff
            dc.b $ff,$c0,$80,$80,$81,$dc,$dc,$fc
            dc.b $f8,$f0,$10,$00,$00,$d7,$0c,$14
            dc.b $1c,$3e,$3e,$7f,$00,$00,$00,$01
            dc.b $03,$0f,$3f,$ff,$00,$00,$00,$80
            dc.b $c0,$f0,$fc,$ff,$d7,$40,$30,$80
            dc.b $c0,$e0,$f0,$f8,$fc,$fc,$fc,$fc
            dc.b $fc,$fc,$fc,$fc,$fc,$fc,$fc,$fc
            dc.b $fc,$fc,$fc,$fc,$fc,$f0,$c0,$01
            dc.b $03,$07,$0f,$1f,$3f,$3f,$3f,$3f
            dc.b $3f,$3f,$3f,$3f,$3f,$3f,$3f,$3f
            dc.b $3f,$3f,$3f,$3f,$3f,$0f,$03,$d7
            dc.b $80,$48,$0f,$0f,$1f,$1f,$3f,$3f
            dc.b $7f,$7f,$ff,$ff,$ff,$c7,$83,$01
            dc.b $01,$01,$e0,$e0,$f0,$f0,$f8,$f8
            dc.b $fc,$fc,$00,$00,$10,$1f,$3f,$3f
            dc.b $7f,$7f,$01,$01,$01,$07,$c3,$81
            dc.b $01,$01,$00,$00,$00,$00,$f8,$f8
            dc.b $fc,$fc,$0f,$0f,$1f,$1f,$20,$00
            dc.b $40,$40,$ff,$ff,$ff,$01,$00,$00
            dc.b $00,$00,$e0,$e0,$f0,$f0,$c0,$c0
            dc.b $80,$00,$d7,$f8,$08,$08,$08,$1c
            dc.b $1c,$1c,$7f,$49,$49,$c1,$cf,$b1
            dc.b $e1,$e5,$eb,$c9,$c0,$eb,$c0,$c0
            dc.b $e5,$e5,$e5,$e5,$e5,$e5,$e5,$e5
            dc.b $e5,$e5,$e5,$e5,$c9,$c1,$e8,$e5
            dc.b $e5,$e5,$e5,$e5,$e5,$e5,$e5,$c1
            dc.b $c9,$c0,$ec,$c9,$c1,$ec,$c9,$e4
            dc.b $e5,$e5,$e5,$e5,$e5,$e5,$e5,$e5
            dc.b $e5,$c9,$c0,$e8,$c0,$c1,$e9,$e5
            dc.b $e5,$e5,$e2,$e3,$c9,$c1,$e8,$c9
            dc.b $c9,$c0,$ec,$c0,$e4,$ec,$c9,$c0
            dc.b $eb,$c9,$c1,$c0,$e5,$e5,$e5,$e5
            dc.b $e5,$c9,$c0,$e9,$c9,$c0,$c9,$c1
            dc.b $c0,$e8,$c9,$c0,$c9,$c0,$e9,$e4
            dc.b $c1,$e4,$ec,$c9,$c0,$c9,$c0,$e4
            dc.b $ec,$c0,$c9,$e4,$e5,$eb,$c9,$c0
            dc.b $e5,$e4,$e4,$ea,$c1,$d0,$d1,$d2
            dc.b $c1,$ea,$c1,$e4,$c1,$e4,$ea,$d0
            dc.b $d1,$d2,$ed,$c1,$e4,$e4,$c1,$c1
            dc.b $ed,$d0,$d1,$d2,$eb,$c1,$e4,$c1
            dc.b $e5,$f9,$f9,$f9,$f9,$f0,$f1,$f2
            dc.b $f9,$f9,$f9,$f9,$f9,$f9,$f9,$f0
            dc.b $f1,$f2,$f9,$f9,$f9,$f9,$f9,$f9
            dc.b $f9,$f0,$f1,$f2,$f9,$f9,$f9,$f9
            dc.b $f9,$c8,$00,$a0,$18,$18,$18,$18
            dc.b $18,$18,$18,$3c,$3c,$3c,$3c,$3c
            dc.b $ff,$99,$99,$99,$18,$18,$18,$18
lbf00       dc.b $18
lbf01       dc.b $18
lbf02       dc.b $18
lbf03       dc.b $3c,$00,$00
lbf06       dc.b $01,$03
            dc.b $aa,$aa,$07,$03,$7e,$7e,$ff,$ff
            dc.b $aa,$aa,$ff,$ff,$00,$00,$80,$c0
            dc.b $ab,$ab,$e0,$c0,$40,$40,$00,$00
            dc.b $00,$00,$00,$00,$c0,$c0,$c0,$c0
            dc.b $00,$00,$00,$00,$20,$00,$08,$00
            dc.b $26,$8d,$1b,$12,$1d,$46,$0c,$07
            dc.b $10,$01,$40,$00,$00,$20,$04,$80
            dc.b $10,$00,$e4,$50,$b1,$e0,$c8,$80
            dc.b $22,$00,$08,$80,$20,$01,$8c,$1e
            dc.b $3b,$22,$32,$10,$68,$40,$54,$62
            dc.b $31,$1f,$03,$04,$02,$10,$00,$c4
            dc.b $60,$30,$58,$10,$12,$a8,$58,$31
            dc.b $e0,$04,$10,$02,$60,$60,$08,$00
            dc.b $04,$00,$31,$34,$00,$00,$02,$00
            dc.b $18,$18,$00,$00,$06,$06,$10,$80
            dc.b $0c,$2c,$00,$00,$80,$10,$00,$46
            dc.b $06,$00,$30,$30,$c3,$98,$08,$64
            dc.b $f4,$d4,$d4,$40,$e0,$de,$de,$00
            dc.b $39,$f9,$00,$00,$b8,$f8,$00,$00
            dc.b $b8,$f8,$00,$00,$b8,$f8,$15,$fd
            dc.b $07,$21,$0b,$d3,$22,$0b,$ab,$b9
            dc.b $c0,$13,$c0,$1f,$0b,$d3,$07,$14
            dc.b $15,$d5,$05,$21,$0b,$9b,$22,$0b
            dc.b $ab,$b9,$c0,$13,$00,$1f,$0b,$d3
            dc.b $07,$13,$23,$13,$22,$0b,$ff,$07
            dc.b $13,$23,$d5,$33,$3b,$9d,$07,$10
            dc.b $22,$08,$10,$20,$06,$07,$07,$14
            dc.b $98,$bf,$1f,$b8,$bf,$27
lbfe6       dc.b $00
lbfe7       dc.b $14
lbfe8       dc.w rom_pstart
lbfea       dc.b $00,$00
lbfec       dc.b $90
lbfed       dc.b $10
lbfee       dc.b $a8
lbfef       dc.b $c2
;
; VDP register initialisation
; register 1 = $a0 = 1010 0000 = 16K and IE
; register 2 = $00 Name Table Base Address = $00 * $400               = $0000
; register 3 = $0e Color Table Base Address = $0E * $40               = $0380
; register 4 = $02 Pattern Generator Base Address = $02 * $800        = $1000
; register 5 = $06 Sprite Attribute Table Base Addrress = $06 * $80   = $0300
; register 6 = $01 Sprite Pattern generator base address = $01 * $800 = $0800
; register 7 = $11 Text color1=$01; Text color2=$01
lbff0       dc.b $00,$a0,$00,$0e,$02,$06,$01,$11
;
lbff8       dc.w lbbd0
lbffa       dc.w lb000
lbffc       dc.w lf808
lbffe       dc.w lb9a5
;
;
    ifd COMBINED
            org $5800
;
    else
VDP_RD_VRAM equ $2000
VDP_RD_REG  equ $2001
VDP_WR_VRAM equ $3000
VDP_WR_REG  equ $3001
;
PIA_REGA    equ $1000       ; data reg A
PIA_DDRA    equ $1000       ; data dir reg A
PIA_CTLA    equ $1001       ; control reg A
PIA_REGB    equ $1002       ; data reg B
PIA_DDRB    equ $1002       ; data dir reg B
PIA_CTLB    equ $1003       ; control reg B
;
; ROM locations
lbf00       equ $bf00
lbf01       equ $bf01
lbf02       equ $bf02
lbf03       equ $bf03
lbfe6       equ $bfe6
lbfe7       equ $bfe7
lbfe8       equ $bfe8
lbfea       equ $bfea
lbfeb       equ $bfeb
lbfec       equ $bfec
lbfed       equ $bfed
lbfee       equ $bfee
lbfef       equ $bfef
lbff0       equ $bff0
lbff8       equ $bff8
lbff9       equ $bff9
lbffa       equ $bffa
lbffb       equ $bffb
lbffc       equ $bffc
lbffe       equ $bffe

            org $F800
    endif
    
lf800       dc.b $00,$00,$00,$00,$00,$00,$00,$00
;
lf808       beq lf848
            lda #$D1
            pha
            ldx #$05
lb80f       lda lf856,x             ; Get register value to write
            jsr lfe1f               ; Set the VDP register
            dex
            bpl lb80f
            lda #$61
            ldx #$F8
            jsr lfd53
            pla
lf820       jsr vdp_write_ram
            lda #$F1
            ldx #$07
            jsr lfe1f
            lda #$00
            ldx #$d8
            jsr lfe1f
            ldy #$1f
            lda #$f1
lf835       jsr vdp_write_ram
            dey
            bpl lf835
lf83b       jsr lfd33
            bne lf83b
            dey
            bne lf83b
            jsr lf84b
            nop
            nop
lf848       jmp (lbfe8)
lf84b       ldx #$07
lf84d       lda lbff0,X
            jsr lfe1f
            dex
            bpl lf84d
lf856       rts
;
;   VDP register 1   2   3   4   5
lf857       dc.b $c0,$04,$60,$00,$10
; register 1 = $C0 - 16K RAM and enable display
; register 2 = $04 - Name table base address = $04
; register 3 = $60 - Color table base ddress = $60
; register 4 = $00 - Pattern generator base address = $00
; register 5 = $10 - Sprite attribute table base address = $10
;
lf85c       ldx #$ff
            jmp lfd9e
;
lf861       dc.b $c8,$00,$01,$d0,$d1,$2f,$06
lf868       dc.b $db,$dc,$c0,$c0,$c0,$ff,$d1,$4c
lf870       dc.b $08,$dd,$de,$df,$e0,$fb,$fc,$fd
lf878       dc.b $fe,$d2,$18,$04,$da,$d1,$d9,$d8
;
; Character definitions
;
; 0
lf880       dc.b $00,$3c,$62,$66,$6a,$72,$62,$3c
; 1
lf888       dc.b $00,$18,$38,$18,$18,$18,$18,$3c
; 2
lf890       dc.b $00,$3c,$62,$02,$06,$18,$60,$7e
; 3
lf898       dc.b $00,$3c,$46,$06,$0c,$06,$46,$3c
; 4
lf8a0       dc.b $00,$0c,$1c,$34,$64,$7e,$04,$04
; 5
lf8a8       dc.b $00,$7e,$60,$7c,$02,$02,$62,$3c
; 6
lf8b0       dc.b $00,$1e,$30,$60,$7c,$62,$62,$3c
; 7
lf8b8       dc.b $00,$7e,$06,$0c,$18,$30,$30,$30
; 8
lf8c0       dc.b $00,$3c,$62,$62,$3c,$62,$62,$3c
; 9
lf8c8       dc.b $00,$3c,$62,$62,$3e,$02,$04,$78
; (c)
lf8d0       dc.b $00,$1c,$22,$5d,$51,$5d,$22,$1c
; Part of "creativision" logo
; top-left part of "V"
lf8d8       dc.b $00,$00,$00,$00,$00,$00,$18,$04
; top-right part of "V"
lf8e0       dc.b $00,$00,$00,$00,$00,$00,$0c,$10
; "creati" and left part of "V"
lf8e8       dc.b $39,$42,$82,$82,$82,$42,$3c,$00
lf8f0       dc.b $c7,$28,$28,$c6,$48,$28,$37,$00
lf8f8       dc.b $27,$51,$51,$89,$b9,$89,$05,$00
;
lf900       dc.b $d4,$14,$12,$12,$12,$12,$11,$01
; A
lf908       dc.b $00,$18,$34,$62,$62,$7e,$62,$62
; B
lf910       dc.b $00,$7c,$62,$62,$7c,$62,$62,$7c
; C
lf918       dc.b $00,$3c,$62,$60,$60,$60,$62,$3c
; D
lf920       dc.b $00,$78,$64,$62,$62,$62,$64,$78
; E
lf928       dc.b $00,$3e,$60,$60,$7c,$60,$60,$3e
; F
lf930       dc.b $00,$3e,$60,$60,$6c,$60,$60,$60
; G
lf938       dc.b $00,$3c,$62,$60,$66,$62,$62,$3e
; H
lf940       dc.b $00,$62,$62,$62,$7e,$62,$62,$62
; I
lf948       dc.b $00,$3c,$18,$18,$18,$18,$18,$3c
; J
lf950       dc.b $00,$3c,$18,$18,$18,$18,$58,$30
; K
lf958       dc.b $00,$62,$64,$68,$70,$68,$64,$62
; L
lf960       dc.b $00,$60,$60,$60,$60,$60,$70,$3e
; M
lf968       dc.b $00,$62,$76,$6a,$6a,$62,$62,$62
; N
lf970       dc.b $00,$62,$72,$72,$6a,$66,$66,$62
; O
lf978       dc.b $00,$3c,$62,$62,$62,$62,$62,$3c
; P
lf980       dc.b $00,$7c,$62,$62,$62,$7c,$60,$60
; Q
lf988       dc.b $00,$3c,$62,$62,$62,$6a,$64,$3a
; R
lf990       dc.b $00,$7c,$62,$62,$7c,$68,$64,$62
; S
lf998       dc.b $00,$3e,$60,$60,$3c,$02,$02,$7c
; T
lf9a0       dc.b $00,$7e,$18,$18,$18,$18,$18,$18
; U
lf9a8       dc.b $00,$62,$62,$62,$62,$62,$62,$3c
; V
lf9b0       dc.b $00,$62,$62,$62,$62,$34,$34,$18
; W
lf9b8       dc.b $00,$62,$62,$62,$6a,$6a,$76,$62
; X
lf9c0       dc.b $00,$62,$62,$34,$08,$34,$62,$62
; Y
lf9c8       dc.b $00,$62,$62,$62,$34,$18,$18,$18
; Z
lf9d0       dc.b $00,$7e,$06,$0c,$18,$30,$60,$7e
; right part of "V" and "ision" part of logo
lf9d8       dc.b $14,$15,$25,$24,$24,$24,$45,$c0
lf9e0       dc.b $f4,$04,$05,$e5,$15,$14,$e4,$00
lf9e8       dc.b $70,$89,$05,$05,$05,$89,$72,$00
lf9f0       dc.b $84,$48,$48,$28,$28,$28,$10,$00
; TM
lf9f8       dc.b $00,$00,$00,$00,$f1,$5b,$55,$51
;
lfa00       lda #$00
            sta PIA_CTLA
            sta PIA_CTLB
            sta PIA_DDRB        ; Set direction register for B (all inputs)
            lda #$0f
            sta PIA_DDRA        ; Set direction register for A (B0-B3 outputs; B4-B7 inputs)
            lda #$04            ; Select output register for both ports
            sta PIA_CTLA
            sta PIA_CTLB
            lda #$f7
            ldx #$03

lfa1c
            sta PIA_REGA        ; B0-B2 set; B3 reset
            pha
            lda PIA_REGB        ; read register B
            eor #$ff
            sta $18,x
            pla
            sec
            ror
            dex
            bpl lfa1c
            sta PIA_REGA        
            jsr lfe67
            ldx #$03


lfa35
            txa
            asl
            and #$02
            tay
            lda lfbaa,y
            sta $00
            lda lfbab,y
            sta $01
            ldy lfbae,x
            lda $18,x
            asl
            beq lfa5e


lfa4c
            cmp ($00),y
            beq lfa55
            dey
            bpl lfa4c
            bmi lfa60


lfa55
            tya
            ora #$80
            ldy $11,x
            beq lfa5e
            eor #$c0


lfa5e
            sta $11,x


lfa60
            dex
            bpl lfa35
            lda #$00
            sta $10
            sta $1d
            ldx #$03


lfa6b
            lda $18,x
            asl
            rol $15
            and #$ff
            beq lfa78
            stx $1e
            inc $1d


lfa78
            dex
            bpl lfa6b
            lda $15
            lsr
            lsr
            lsr
            lsr
            eor #$0f
            and $15
            jsr lfb49
            lda $15
            jsr lfb49
            ldy #$01
            ldx #$05
            lda #$04


lfa93
            bit $15
            beq lfa9b
            stx $1e
            inc $1d


lfa9b
            asl
            dex
            dey
            bpl lfa93
            lda $1d
            bne lfaa7
            sta $1c
            rts


lfaa7
            lda $1c
            cmp #$02
            bcs lfab0
            inc $1c
            rts


lfab0
            beq lfab3
            rts


lfab3
            inc $1c
            dec $1d
            beq lfaba
            rts


lfaba
            lda $1e
            asl
            tax
            lda lfac8,x
            pha
            lda lfac7,x
            pha
            rts

lfac7       dc.b $d3
lfac8       dc.b $fa,$e8,$fa,$ee,$fa,$fb,$fa,$02
lfad0       dc.b $fb,$10,$fb,$ea,$a5,$18,$0a,$c9
lfad8       dc.b $18,$d0,$0c,$a2,$b1,$a9,$02,$24
lfae0       dc.b $15,$f0,$02,$a2,$a1,$86,$10,$60
lfae8       dc.b $ea,$a5,$19,$0a,$d0,$28,$ea,$a5
lfaf0       dc.b $1a,$0a,$c9,$18,$d0,$04,$a2,$a0
lfaf8       dc.b $86,$10,$60,$ea,$a5,$1b,$38,$2a
lfb00       dc.b $d0,$14,$ea,$a2,$ad,$a9,$02,$24
lfb08       dc.b $15,$f0,$02,$a2,$bd,$86,$10,$60
lfb10       dc.b $ea,$a2,$88,$86,$10,$60,$a2,$30
lfb18       dc.b $49,$fe,$dd,$79,$fb,$f0,$04,$ca
lfb20       dc.b $10,$f8,$60,$8a,$29,$0f,$85,$10
lfb28       dc.b $8a,$a2,$06,$dd,$56,$fb,$b0,$03
lfb30       dc.b $ca,$10,$f8,$8a,$0a,$0a,$85,$1d
lfb38       dc.b $a5,$15,$29,$03,$49,$03,$05,$1d
lfb40       dc.b $aa,$bd,$5d,$fb,$05,$10,$85,$10
lfb48       dc.b $60
;
lfb49       lsr
            rol $16
            lsr
            rol $16
            lsr
            rol $17
            lsr
            rol $17
            rts


lfb56       dc.b $00, $01, $0c, $10, $20, $2d, $30, $c0
            dc.b $c0, $b0, $b0, $a0, $a0, $b0, $b0, $b0
            dc.b $b0, $a0, $a0, $80, $c0, $80, $c0, $90
            dc.b $d0, $90, $d0, $80, $80, $80, $80, $95
            dc.b $95, $95, $95, $db, $00, $9e, $3e, $ae
            dc.b $6e, $5e, $f3, $7b, $bb, $eb, $cf, $af
            dc.b $00, $3f, $9f, $00, $dc, $f2, $ba, $7c
            dc.b $d6, $f8, $f4, $77, $7d, $b7, $d7, $e7
            dc.b $6f, $5f, $bd, $dd, $ce, $b6, $bc, $76
            dc.b $f9, $7a, $e6, $da, $f5, $ea, $00, $00
            dc.b $ed, $00, $00, $ec

lfbaa       dc.b $b2
lfbab       dc.b $fb, $c2, $fb

lfbae       dc.b $0f, $13, $0f, $13, $84, $04, $06, $0e
            dc.b $0a, $08, $88, $98, $90, $10, $30, $70
            dc.b $60, $40, $c0, $c4, $14, $22, $30, $60
            dc.b $24, $42, $18, $c0, $44, $82, $28, $50
            dc.b $84, $06, $48, $90, $0c, $0a, $88, $a0
            dc.b $a9, $d5
;
lfbd8       ldy #$fc
            sta $04
            sty $05
            php
            sei
            lda lbf00,x
            sta $00
            lda lbf01,x
;
lfbe8       sta $01
            ldy lbf02,x
            lda ($00),y
            sta $0e
            lda #$00
            sta $06
            sta $07
            sta $08
            jsr lfe54
lfbfc       lda $0e
            sta $09
lfc00       sbc #$01
            bcs lfc00
            dec $09
            bpl lfc00
            lda #$02
            sta $0a
lfc0c       ldx $0a
            txa
            jsr lfd3f
            ora #$80
            sta $0b
            dec $06,x
            bpl lfc51
            dey
            cpy #$ff
            beq lfc74
            lda ($00),y
            and #$07
            tax
            lda lfc79,x
            ldx $0a
            sta $06,x
            lda ($00),y
            lsr
            lsr
            lsr
            beq lfc4a
            tax
            dex
            bne lfc38
            dey
            lda ($00),y
            tax
lfc38       lda $0b
lfc3a       ora lfc80,x
            jsr lfe77
            lda lfcaa,x
            jsr lfe77
            lda #$10
lfc4a       ldx $0a
            sta $18,X
            jmp lfc5f
;
lfc51       lda $06,x
            and #$07
            cmp #$07
            bne lfc6f
            dec $18,x
            bpl lfc5f
            inc $18,x
lfc5f       tya
            pha
            ldy $18,x
            lda ($04),y
            ora $0b
            ora #$10
            jsr lfe77
            pla
            tay
lfc6f       dec $0a
            bpl lfc0c
            bmi lfbfc
lfc74       jsr lfe54
            plp
            rts
;
lfc79       dc.b $07, $0f, $17, $1f, $2f
            dc.b $3f, $5f
lfc80       dc.b $7f, $0e, $03, $0a, $02, $0b
            dc.b $06, $02, $0f, $0d, $0c, $0c, $0d, $0f
            dc.b $01, $05, $09, $0e, $03, $09, $0f, $06
            dc.b $0e, $06, $0f, $07, $01, $0a, $04, $0f
            dc.b $09, $0e, $0a, $08, $08, $0a, $04, $00
            dc.b $0b, $07, $03, $0f
lfcaa       dc.b $0c, $1d, $1c, $1a
            dc.b $19, $17, $16, $15, $13, $12, $11, $10
            dc.b $0f, $0e, $0e, $0d, $0c, $0b, $0b, $0a
            dc.b $09, $09, $08, $08, $07, $07, $07, $06
            dc.b $06, $05, $05, $27, $25, $23, $21, $1f
            dc.b $05, $05, $04, $04, $04, $03, $03, $0f
            dc.b $0f, $0e, $0d, $0c, $0b, $0a, $09, $08
            dc.b $07, $06, $05, $04, $03, $02, $01, $00
;
lfce6       lda #$eb
            jmp lfbd8
; 
            dc.b $0f, $00, $00
            dc.b $00, $00, $00, $00, $00, $00, $00, $00
            dc.b $00, $00, $00, $00, $00, $00, $20, $1f
            dc.b $fe, $a2, $e0, $20, $0f, $fe, $95, $e0
            dc.b $e8, $d0, $f8, $60, $a8, $84, $07, $85
            dc.b $06, $a9, $00, $a0, $07, $46, $06, $90
            dc.b $03, $18, $65, $07, $6a, $66, $06, $88
            dc.b $10, $f5, $85, $07, $60, $b1, $06, $20
            dc.b $82, $fd, $c8, $d0, $f8, $60, $ca, $ca
            dc.b $ca, $ca, $ca, $ca, $ca

lfd33       dex
            rts


lfd35       dey
            dey
            dey
            dey
            dey
            dey
            dey
            dey
            rts


lfd3e       asl
lfd3f       asl
            asl
            asl
            asl
            asl
            rts


lfd45       lsr
            lsr
            lsr
            lsr
            lsr
            lsr
            rts

lfd4c       dc.b $ff
lfd4d       lda lbff8
            ldx lbff8+1
lfd53       sta $09
            stx $0a
            ldy #$00
lfd59       lda ($09),y
            beq lfd81
            tax
            jsr lfd7c
            lda ($09),y
            jsr lfe1f
            jsr lfd7c
            lda ($09),y
            tax


lfd6c
            jsr lfd7c
            lda ($09),y
            jsr vdp_write_ram
            dex
            bne lfd6c
            jsr lfd7c
            bne lfd59


lfd7c
            iny
            bne lfd81
            inc $0a


lfd81
            rts


vdp_write_ram       sta VDP_WR_VRAM
lfd85       rts


lfd86
            lda lbffa
            ldx lbffa+1
            sta $06
            stx $07
            ldy #$00


lfd92
            lda ($06),y
            beq lfd85
            jsr lfda6
            iny
            bne lfd92
            ldx #$bf
lfd9e       ldy #$00
            sta $06
            stx $07
            lda ($06),y


lfda6
            tax
            iny
            lda ($06),y
            jsr lfe1f
            iny
            lda ($06),y
            tax
            iny
            lda ($06),y
            sta $09
            iny
            lda ($06),y


lfdb9       jsr vdp_write_ram
            dex
            bne lfdb9
            dec $09
            bpl lfdb9
            rts


lfdc4
            lda #$00
            beq lfdca


lfdc8
            lda #$40


lfdca
            ora $05
            pha
            lda $04
            jsr vdp_write_reg
            pla


vdp_write_reg
            sta VDP_WR_REG


lfdd6       rts

lfdd7       sta $04
lfdd9       asl $04
            rol $05
            asl $04
            rol $05
            asl $04
            rol $05
            asl $05
            asl $05
            asl $05
            rts

lfdec       lsr $05
            lsr $05
            lsr $05
            lsr $05
            ror $04
            lsr $05
            ror $04
            lsr $05
            ror $04
            rts


lfdff       jsr lfdec
            lda $05
            ora #$10
            sta $05
            rts


lfe09       jsr lfdff
            jsr lfdc4
            lda VDP_RD_VRAM


lfe12       rts


lfe13       pha
            jsr lfdff
            jsr lfdc8
            pla
            jsr vdp_write_ram
            rts

; X has VDP register to write to :  0-7
; A has value to write to register
lfe1f       php                 ; save processor status 
            sei                 ; disable interrupts
            jsr vdp_write_reg   ; store the 8-bit data byte
            txa
            eor #$80            ; set B7 and then write register
            jsr vdp_write_reg
            plp                 ; restore processor status
            rts


IRQ_VEC
            jmp (lbffe)


lfe2f
            ldx #$00
            txa


lfe32
            sta $00,x
            inx
            bne lfe32
            rts


lfe38       ldx #$c6    ; %11000110
lfe3a       lda #$00    ; Value to write
lfe3c       jsr lfe1f   ; Set the VDP register
;
            ldx #$00
lfe41       lda lf800,x
            jsr vdp_write_ram
            inx
            bne lfe41


lfe4a       lda lf900,x
            jsr vdp_write_ram
            inx
            bne lfe4a
            rts

lfe54       jsr lfe67
            ldx #$03


lfe59       lda lfe63,x
            jsr lfe77
            dex
            bpl lfe59
            rts


lfe63
            dc.b    $ff, $df, $bf, $9f

lfe67       lda #$22                ; Enable interrupt from PIA
            sta PIA_CTLB
            lda #$ff                ; Set direction as all outputs
            sta PIA_DDRB
            lda #$26                ; Set data register
            sta PIA_CTLB
            rts


lfe77
            sta PIA_REGB


lfe7a
            lda PIA_CTLB
    ifd COMBINED
            nop
            nop
    else
            bpl lfe7a
    endif
            lda PIA_REGB
            rts


lfe83
            lda $15
            beq lfe9a
            dec $0f
            bpl lfe9c
            inc $0d
            lda $0d
            sec
            sbc lbfed
            bne lfe97
            sta $0d


lfe97
            lda lbfe7


lfe9a
            sta $0f


lfe9c
            lda lbfee
            ldx lbfef
            jsr lfe1f          ; Set the VDP register


lfea5
            lda $0d
            clc
            adc #$01
            jsr lfec5
lfead       pha
            lsr
            lsr
            lsr
            lsr
            jsr lfeb8
            pla
            and #$0f


lfeb8
            cmp #$0a
            bcc lfebe
            adc #$06


lfebe
            adc lbfec
            jsr vdp_write_ram
            rts


lfec5
            tay
            ldx #$00
            lda #$0a


lfeca
            sta $0e
            lda #$00
            cpy $0e
            bcc lfede
            inx
            inx
            inx
            inx
            inx
            inx
            lda #$09
            adc $0e
            bcc lfeca


lfede
            stx $0e
            tya
            adc $0e
            rts


lfee4
            stx $07
            sta $06


lfee8
            ldy #$08
            jsr lffba
            lda #$f8


lfeef
            clc
            adc $06
            sta $06
            bcs lfef8
            dec $07


lfef8
            rts


lfef9
            jsr lfee4
            jsr lfee8
            lda #$20
            jsr lff24
            jsr lfee8
            jmp lfee8


lff0a
            stx $07
            sta $06


lff0e
            ldy #$f8


lff10
            lda ($06),y
            sta $09
            ldx #$07


lff16
            asl $09
            ror
            dex
            bpl lff16
            jsr vdp_write_ram
            iny
            bne lff10
            lda #$08


lff24
            clc
            adc $06
            sta $06
            bcc lff2d
            inc $07


lff2d
            rts


lff2e
            jsr lff0a
            jsr lff0e
            lda #$e0
            jsr lfeef
            jsr lff0e
            jmp lff0e


lff3f
            pha
            txa
            pha
            tya
            pha
            lda VDP_RD_REG
            sta $0c
            jsr lff58
            jsr lfa00
            jmp (lbfea)


lff52
            pla
            tay
            pla
            tax
            pla
            rti


lff58
            lda #$20
            and $03
            asl
            eor $03
            asl
            asl
            rol $02
            rol $03
            rts


reset       sei                 ; 
            cld                 ; Go out of decimal mode
            ldx #$40


lff6a       dey
            bne lff6a
            dex
            bne lff6a           ; wait for a bit?
            lda VDP_RD_REG
            jsr lfe54


lff76       jsr lf84b
            ldx #$05


lff7b       dex
            beq lff9e
            lda lbffa+1,x
            cmp $01ff,x
            beq lff7b
            jsr lfe2f
            lda #$f4
            jsr lf85c
            jsr lfe38
            ldx #$03


lff93       lda lbffc,x
            sta $0200,x
            dex
            bpl lff93
            stx $02


lff9e       jmp (lbffc)


lffa1       ldy lbf00,x
            lda lbfe6
            sta $07
            lda lbf01,x
            sta $06
            lda lbf02,x
            sta VDP_WR_REG
            lda lbf03,x
            jsr vdp_write_reg


lffba       lda ($06),y
            jsr vdp_write_ram
            dey
            bne lffba
            rts

lffc3       dc.b $c0, $f2, $e5, $f6, $ef, $c0, $e5, $ed
            dc.b $e1, $e7, $c0, $f0, $f5, $d1, $f0, $f5
            dc.b $d2, $e5, $f2, $ef, $e3, $f3, $c0, $e9
            dc.b $e8, $e8, $e7, $e9, $e8, $a9, $eb, $a2
            dc.b $ff, $20, $9e, $fd, $c8, $4c, $a4, $fd
            dc.b $d1, $4a, $0b, $00, $c0, $d1, $8a, $0b
            dc.b $00, $c0, $00, $00, $40, $00, $ff
            dc.w    reset
            dc.w    reset
            dc.w    IRQ_VEC
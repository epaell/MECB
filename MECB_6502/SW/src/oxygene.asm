MECB_IO       equ   $E000
SID           equ   MECB_IO+$A0
LED            equ   MECB_IO+$C1
;SID            equ   $D400
;
;
; Motorola 6840 PTM (Programmable Timer Module)
;
PTM             EQU     MECB_IO
PTM_CR13        EQU     PTM         ; Write: Timer Control Registers 1 & 3   Read: NOP
PTM_SR          EQU     PTM+1
PTM_CR2         EQU     PTM+1       ; Write: Control Register 2              Read: Status Register (least significant bit selects TCR as TCSR1 or TCSR3)
;
PTM_T1MSB       EQU     PTM+2       ; Write: MSB Buffer Register             Read: Timer 1 Counter
PTM_T1LSB       EQU     PTM+3       ; Write: Timer #1 Latches                Read: LSB Buffer Register
;
PTM_T2MSB       EQU     PTM+4       ; Write: MSB Buffer Register             Read: Timer 1 Counter
PTM_T2LSB       EQU     PTM+5       ; Write: Timer #1 Latches                Read: LSB Buffer Register
;
PTM_T3MSB       EQU     PTM+6       ; Write: MSB Buffer Register             Read: Timer 1 Counter
PTM_T3LSB       EQU     PTM+7       ; Write: Timer #1 Latches                Read: LSB Buffer Register
;
; Motorola 6850 ACIA
;
ACIA            EQU     MECB_IO+$08 ; Location of ACIA
ACIA_STATUS     EQU     ACIA        ; Status
ACIA_CONTROL    EQU     ACIA        ; Control
ACIA_DATA       EQU     ACIA+1      ; Data
;
CR              EQU     $0D         ; Carriage return
LF              EQU     $0A         ; Linefeed
;
STACK           equ     $FF
;
; SMON IQR
;
IRQ_LO          EQU     $0314         ; Vector: Hardware IRQ Interrupt Address Lo
IRQ_HI          EQU     $0315         ; Vector: Hardware IRQ Interrupt Address Hi
;
;
;timer_LSB       equ     $E7          ; 1 mS at 1 MHz
;timer_MSB       equ     $03
timer_LSB       equ     $0C          ; 20 mS at 1 MHz (50 Hz)
timer_MSB       equ     $4E
;timer_LSB       equ     $74          ; 16.67 mS at 1 MHz (60 Hz)
;timer_MSB       equ     $40
;
                ORG     $0e00
;
              org $0f82
;
; SID header
;
L0F82         dc.b  $50,$53,$49,$44,$00,$02,$00,$7C
L0F8A         dc.b  $00,$00,$10,$00,$10,$03,$00,$01
L0F92         dc.b  $00,$01,$00,$00,$00,$00,$4F,$78
L0F9A         dc.b  $79,$67,$65,$6E,$65,$20,$50,$61
L0FA2         dc.b  $72,$74,$20,$34,$00,$00,$00,$00
L0FAA         dc.b  $00,$00,$00,$00,$00,$00,$00,$00
L0FB2         dc.b  $00,$00,$00,$00,$00,$00,$53,$61
L0FBA         dc.b  $6D,$69,$20,$4C,$6F,$75,$6B,$6F
L0FC2         dc.b  $20,$28,$50,$72,$6F,$74,$6F,$6E
L0FCA         dc.b  $29,$00,$00,$00,$00,$00,$00,$00
L0FD2         dc.b  $00,$00,$00,$00,$00,$00,$32,$30
L0FDA         dc.b  $32,$32,$20,$46,$69,$6E,$6E,$69
L0FE2         dc.b  $73,$68,$20,$47,$6F,$6C,$64,$2F
L0FEA         dc.b  $4F,$6E,$73,$6C,$61,$75,$67,$68
L0FF2         dc.b  $74,$00,$00,$00,$00,$00,$00,$24
L0FFA         dc.b  $00,$00,$00,$00,$00,$10
;
              org   $1000
;
sid_init      JMP L10F5
sid_play      JMP L10F9
;
L1006         dc.b  $40,$46,$46,$4D
L100A         dc.b  $4D,$57,$5B,$5F,$5F,$5F,$5F,$5F
L1012         dc.b  $68,$68,$68,$68,$80,$A7,$A7,$A4
L101A         dc.b  $87,$08,$05,$00,$00,$00,$53,$61
L1022         dc.b  $6D,$69,$20,$4C,$6F,$75,$6B,$6F
L102A         dc.b  $20,$28,$70,$72,$6F,$74,$6F,$6E
L1032         dc.b  $29,$20,$20,$20,$20,$20,$20,$20
L103A         dc.b  $20,$20,$20,$20,$20,$20
;
L1040         LDA $152B,Y
              JMP L104D
              TAY
              LDA #$00
              STA $13DD,X
              TYA
L104D         STA $13B4,X
              LDA $13A3,X
              STA $13B3,X
              RTS
              STA SID+$05,X
              RTS
              STA SID+$06,X
              RTS
              STA $117E
              BNE L1067
              STA $1130
L1067         RTS
              BMI L1074
              STA $13CA
              STA $13D1
              STA $13D8
              RTS
L1074         AND #$7F
              STA $13CA,X
              RTS
L107A         DEC $13DE,X
L107D         JMP L12AB
L1080         BEQ L107D
              LDA $13DE,X
              BNE L107A
              LDA #$00
              STA $EF
              LDA $13DD,X
              BMI L1099
              CMP $1620,Y
              BCC L109A
              BEQ L1099
              EOR #$FF
L1099         CLC
L109A         ADC #$02
              STA $13DD,X
              LSR A
              BCC L10C8
              BCS L10DF
              TYA
              BEQ L10EF
              LDA $1620,Y
              STA $EF
              SEC
              LDY $13CC,X
              LDA $13E0,X
              SBC $13FB,Y
              PHA
              LDA $13E1,X
              SBC $144F,Y
              TAY
              PLA
              BCS L10D8
              ADC $EE
              TYA
              ADC $EF
              BPL L10EF
L10C8         LDA $13E0,X
              ADC $EE
              STA $13E0,X
              LDA $13E1,X
              ADC $EF
              JMP L12A8
L10D8         SBC $EE
              TYA
              SBC $EF
              BMI L10EF
L10DF         LDA $13E0,X
              SBC $EE
              STA $13E0,X
              LDA $13E1,X
              SBC $EF
              JMP L12A8
L10EF         LDY $13CC,X
              JMP L129A
L10F5         STA $10FC
              RTS
L10F9         LDX #$00
              LDY #$00
              BMI L112F
              TXA
              LDX #$29
L1102         STA $139E,X
              DEX
              BPL L1102
              STA SID+$15
              STA $117E
              STA $1130
              STX $10FC
              TAX
              JSR L111F
              LDX #$07
              JSR L111F
              LDX #$0E
L111F         LDA #$05
              STA $13CA,X
              LDA #$01
              STA $13CB,X
              STA $13CD,X
              JMP L1394
L112F         LDY #$00
              BEQ L1178
              LDA #$00
              BNE L115A
              LDA $15E3,Y
              BEQ L114E
              BPL L1157
              ASL A
              STA $1183
              LDA $1601,Y
              STA $117E
              LDA L15E4,Y
              BNE L116C
              INY
L114E         LDA $1601,Y
              STA $1179
              JMP L1169
L1157         STA $1134
L115A         LDA $1601,Y
              CLC
              ADC $1179
              STA $1179
              DEC $1134
              BNE L117A
L1169         LDA L15E4,Y
L116C         CMP #$FF
              INY
              TYA
              BCC L1175
              LDA $1601,Y
L1175         STA $1130
L1178         LDA #$00
L117A         STA SID+$16
              LDA #$00
              STA SID+$17
              LDA #$00
              ORA #$0F
              STA SID+$18
              JSR L1193
              LDX #$07
              JSR L1193
              LDX #$0E
L1193         DEC $13CB,X
              BEQ L11A3
              BPL L11A0
              LDA $13CA,X
              STA $13CB,X
L11A0         JMP L1257
L11A3         LDY $13A3,X
              LDA $1006,Y
              STA $124C
              STA $1255
              LDA $13A1,X
              BNE L11E4
              LDY $13C8,X
              LDA $14AF,Y
              STA $EE
              LDA $14B2,Y
              STA $EF
              LDY $139E,X
              LDA ($EE),Y
              CMP #$FF
              BCC L11D0
              INY
              LDA ($EE),Y
              TAY
              LDA ($EE),Y
L11D0         CMP #$E0
              BCC L11DC
              SBC #$F0
              STA $139F,X
              INY
              LDA ($EE),Y
L11DC         STA $13C9,X
              INY
              TYA
              STA $139E,X
L11E4         LDY $13CD,X
              LDA $1545,Y
              STA $13F7,X
              LDA $13B5,X
              BEQ L1251
              SEC
              SBC #$60
              STA $13CC,X
              LDA #$00
              STA $13B3,X
              STA $13B5,X
              LDA $1538,Y
              STA $13DE,X
              LDA $152B,Y
              STA $13B4,X
              LDA $13A3,X
              CMP #$03
              BEQ L1251
              LDA $1552,Y
              STA $13B7,X
              INC $13CE,X
              LDA $1511,Y
              BEQ L1229
              STA $13B8,X
              LDA #$00
              STA $13B9,X
L1229         LDA $151E,Y
              BEQ L1236
              STA $1130
              LDA #$00
              STA $1134
L1236         LDA $1504,Y
              STA $13B6,X
              LDA $14F7,Y
              STA SID+$06,X
              LDA $14EA,Y
              STA SID+$05,X
              LDA $13A4,X
              JSR L1040
              JMP L1394
L1251         LDA $13A4,X
              JSR L1040
L1257         LDY $13B6,X
              BEQ L1279
              LDA $155F,Y
              BEQ L1264
              STA $13B7,X
L1264         LDA $1560,Y
              CMP #$FF
              INY
              TYA
              BCC L1271
              CLC
              LDA $1584,Y
L1271         STA $13B6,X
              LDA $1583,Y
              BNE L1292
L1279         LDA $13CB,X
              BEQ L12AE
              LDY $13B3,X
              LDA $1016,Y
              STA $1290
              LDY $13B4,X
              LDA $1626,Y
              STA $EE
              JMP L1080
L1292         BPL L1299
              ADC $13CC,X
              AND #$7F
L1299         TAY
L129A         LDA #$00
              STA $13DD,X
              LDA $13FB,Y
              STA $13E0,X
              LDA $144F,Y
L12A8         STA $13E1,X
L12AB         LDA $13CB,X
L12AE         CMP $13F7,X
              BEQ L130D
              LDY $13B8,X
              BEQ L130A
              ORA $13A1,X
              BEQ L130A
              LDA $13B9,X
              BNE L12D6
              LDA $15A9,Y
              BPL L12D3
              STA $13E3,X
              LDA $15C6,Y
              STA $13E2,X
              JMP L12EF
L12D3         STA $13B9,X
L12D6         LDA $15C6,Y
              CLC
              BPL L12DF
              DEC $13E3,X
L12DF         ADC $13E2,X
              STA $13E2,X
              BCC L12EA
              INC $13E3,X
L12EA         DEC $13B9,X
              BNE L1301
L12EF         LDA $15AA,Y
              CMP #$FF
              INY
              TYA
              BCC L12FB
              LDA $15C6,Y
L12FB         STA $13B8,X
              LDA $13E2,X
L1301         STA SID+$02,X
              LDA $13E3,X
              STA SID+$03,X
L130A         JMP L1388
L130D         LDY $13C9,X
              LDA $14B5,Y
              STA $EE
              LDA $14D0,Y
              STA $EF
              LDY $13A1,X
              LDA ($EE),Y
              CMP #$40
              BCC L133B
              CMP #$60
              BCC L1345
              CMP #$C0
              BCC L1359
              LDA $13A2,X
              BNE L1332
              LDA ($EE),Y
L1332         ADC #$00
              STA $13A2,X
              BEQ L137F
              BNE L1388
L133B         STA $13CD,X
              INY
              LDA ($EE),Y
              CMP #$60
              BCS L1359
L1345         CMP #$50
              AND #$0F
              STA $13A3,X
              BEQ L1354
              INY
              LDA ($EE),Y
              STA $13A4,X
L1354         BCS L137F
              INY
              LDA ($EE),Y
L1359         CMP #$BD
              BCC L1363
              BEQ L137F
              ORA #$F0
              BNE L137C
L1363         ADC $139F,X
              STA $13B5,X
              LDA $13A3,X
              CMP #$03
              BEQ L137F
              LDA #$00
              STA SID+$06,X
              LDA #$0F
              STA SID+$05,X
              LDA #$FE
L137C         STA $13CE,X
L137F         INY
              LDA ($EE),Y
              BEQ L1385
              TYA
L1385         STA $13A1,X
L1388         LDA $13E0,X
              STA SID+$00,X
              LDA $13E1,X
              STA SID+$01,X
L1394         LDA $13B7,X
              AND $13CE,X
              STA SID+$04,X
              RTS
;
L139D         dc.b  $00,$00,$00,$00
L13A2         dc.b  $00,$00,$00,$00,$00,$00,$00,$00
L13AA         dc.b  $00,$00,$00,$00,$00,$00,$00,$00
L13B2         dc.b  $00,$00,$00,$00,$00,$00,$00,$00
L13BA         dc.b  $00,$00,$00,$00,$00,$00,$00,$00
L13C2         dc.b  $00,$00,$00,$00,$00,$00,$00,$00
L13CA         dc.b  $00,$00,$00,$01,$FE,$01,$00,$00
L13D2         dc.b  $00,$00,$01,$FE,$02,$00,$00,$00
L13DA         dc.b  $00,$01,$FE,$00,$00,$00,$00,$00
L13E2         dc.b  $00,$00,$00,$00,$00,$00,$00,$00
L13EA         dc.b  $00,$00,$00,$00,$00,$00,$00,$00
L13F2         dc.b  $00,$00,$00,$00,$00,$00,$00,$00
L13FA         dc.b  $00,$00,$00,$00,$00,$00,$00,$00
L1402         dc.b  $00,$00,$00,$00,$00,$2D,$4E,$71
L140A         dc.b  $96,$BE,$E8,$14,$43,$74,$A9,$E1
L1412         dc.b  $1C,$5A,$9C,$E2,$2D,$7C,$CF,$28
L141A         dc.b  $85,$E8,$52,$C1,$37,$B4,$39,$C5
L1422         dc.b  $5A,$F7,$9E,$4F,$0A,$D1,$A3,$82
L142A         dc.b  $6E,$68,$71,$8A,$B3,$EE,$3C,$9E
L1432         dc.b  $15,$A2,$46,$04,$DC,$D0,$E2,$14
L143A         dc.b  $67,$DD,$79,$3C,$29,$44,$8D,$08
L1442         dc.b  $B8,$A1,$C5,$28,$CD,$BA,$F1,$78
L144A         dc.b  $53,$87,$1A,$10,$71,$42,$89,$4F
L1452         dc.b  $9B,$74,$E2,$F0,$A6,$0E,$33,$20
L145A         dc.b  $FF,$02,$02,$02,$02,$02,$02,$03
L1462         dc.b  $03,$03,$03,$03,$04,$04,$04,$04
L146A         dc.b  $05,$05,$05,$06,$06,$06,$07,$07
L1472         dc.b  $08,$08,$09,$09,$0A,$0A,$0B,$0C
L147A         dc.b  $0D,$0D,$0E,$0F,$10,$11,$12,$13
L1482         dc.b  $14,$15,$17,$18,$1A,$1B,$1D,$1F
L148A         dc.b  $20,$22,$24,$27,$29,$2B,$2E,$31
L1492         dc.b  $34,$37,$3A,$3E,$41,$45,$49,$4E
L149A         dc.b  $52,$57,$5C,$62,$68,$6E,$75,$7C
L14A2         dc.b  $83,$8B,$93,$9C,$A5,$AF,$B9,$C4
L14AA         dc.b  $D0,$DD,$EA,$F8,$FF,$2C,$4B,$6A
L14B2         dc.b  $16,$16,$16,$89,$90,$93,$96,$B0
L14BA         dc.b  $F3,$0D,$50,$75,$A5,$CB,$0C,$4D
L14C2         dc.b  $75,$AA,$DF,$15,$4B,$81,$93,$A1
L14CA         dc.b  $B4,$C7,$E1,$FE,$16,$30,$16,$16
L14D2         dc.b  $16,$16,$16,$16,$17,$17,$17,$17
L14DA         dc.b  $17,$18,$18,$18,$18,$18,$19,$19
L14E2         dc.b  $19,$19,$19,$19,$19,$19,$19,$1A
L14EA         dc.b  $1A,$00,$00,$00,$00,$00,$00,$00
L14F2         dc.b  $00,$00,$00,$00,$00,$00,$8D,$FB
L14FA         dc.b  $FA,$F9,$AB,$F9,$B9,$D9,$F7,$F8
L1502         dc.b  $FD,$FB,$FB,$01,$03,$19,$01,$13
L150A         dc.b  $01,$01,$05,$21,$0C,$16,$03,$01
L1512         dc.b  $01,$15,$1A,$06,$0C,$06,$11,$11
L151A         dc.b  $1C,$09,$11,$15,$0C,$00,$0A,$0E
L1522         dc.b  $01,$00,$06,$00,$00,$14,$00,$00
L152A         dc.b  $1B,$00,$05,$00,$00,$04,$05,$04
L1532         dc.b  $01,$00,$00,$00,$01,$00,$02,$00
L153A         dc.b  $00,$00,$11,$06,$11,$00,$00,$00
L1542         dc.b  $00,$00,$00,$07,$02,$02,$02,$02
L154A         dc.b  $02,$02,$01,$02,$02,$02,$01,$02
L1552         dc.b  $02,$09,$09,$09,$09,$09,$09,$09
L155A         dc.b  $09,$09,$19,$09,$09,$09,$41,$FF
L1562         dc.b  $41,$FF,$41,$41,$41,$41,$41,$41
L156A         dc.b  $FF,$81,$41,$00,$00,$80,$80,$FF
L1572         dc.b  $43,$41,$FF,$41,$40,$FF,$61,$11
L157A         dc.b  $00,$00,$00,$00,$10,$FF,$81,$41
L1582         dc.b  $41,$80,$FF,$80,$00,$80,$00,$80
L158A         dc.b  $80,$83,$83,$87,$87,$05,$5F,$28
L1592         dc.b  $20,$24,$5F,$44,$00,$80,$80,$00
L159A         dc.b  $80,$80,$00,$28,$24,$20,$1C,$18
L15A2         dc.b  $14,$10,$00,$5F,$30,$2E,$5C,$00
L15AA         dc.b  $81,$08,$10,$10,$FF,$83,$01,$FF
L15B2         dc.b  $30,$30,$FF,$8F,$08,$18,$18,$FF
L15BA         dc.b  $85,$20,$20,$FF,$86,$10,$50,$50
L15C2         dc.b  $FF,$88,$FF,$88,$FF,$00,$18,$18
L15CA         dc.b  $E8,$03,$00,$20,$07,$0C,$F4,$09
L15D2         dc.b  $00,$D0,$08,$F8,$0E,$00,$08,$F8
L15DA         dc.b  $12,$00,$08,$05,$FB,$17,$80,$00
L15E2         dc.b  $00,$00
L15E4         dc.b  $90,$00,$01,$01,$FF,$90
L15EA         dc.b  $00,$7F,$FF,$98,$00,$0A,$FF,$98
L15F2         dc.b  $00,$00,$00,$00,$FF,$A0,$00,$98
L15FA         dc.b  $00,$00,$00,$FF,$98,$00,$0C,$FF
L1602         dc.b  $F4,$60,$FF,$00,$03,$F4,$04,$01
L160A         dc.b  $00,$F1,$0C,$FF,$00,$F1,$80,$03
L1612         dc.b  $02,$01,$00,$41,$80,$F1,$70,$60
L161A         dc.b  $50,$00,$F1,$10,$FF,$00,$00,$03
L1622         dc.b  $03,$00,$03,$03,$00,$10,$28,$28
L162A         dc.b  $40,$48,$F0,$00,$03,$03,$03,$03
L1632         dc.b  $05,$03,$03,$05,$07,$04,$04,$06
L163A         dc.b  $08,$F0,$04,$04,$06,$08,$F0,$04
L1642         dc.b  $04,$06,$09,$0A,$0A,$0B,$0C,$FF
L164A         dc.b  $02,$F0,$01,$0D,$0D,$0D,$0D,$0E
L1652         dc.b  $0D,$0D,$0E,$0D,$0D,$0D,$0E,$0D
L165A         dc.b  $F0,$0D,$0D,$0E,$0D,$F0,$10,$10
L1662         dc.b  $0F,$11,$0D,$0D,$0E,$0D,$FF,$02
L166A         dc.b  $F0,$02,$12,$13,$14,$14,$15,$14
L1672         dc.b  $14,$15,$17,$14,$14,$15,$17,$FC
L167A         dc.b  $14,$14,$15,$17,$F0,$14,$14,$15
L1682         dc.b  $17,$16,$18,$19,$1A,$FF,$02,$02
L168A         dc.b  $4F,$07,$76,$40,$BE,$00,$50,$BD
L1692         dc.b  $00,$50,$BD,$00,$02,$4F,$87,$78
L169A         dc.b  $50,$78,$76,$BD,$6C,$FE,$71,$76
L16A2         dc.b  $BD,$71,$78,$BD,$78,$76,$BD,$6C
L16AA         dc.b  $FE,$71,$76,$BD,$71,$00,$03,$4F
L16B2         dc.b  $83,$78,$50,$02,$78,$BD,$78,$BD
L16BA         dc.b  $09,$76,$BD,$02,$76,$BD,$78,$BD
L16C2         dc.b  $03,$9F,$BD,$02,$78,$BD,$71,$BD
L16CA         dc.b  $09,$76,$BD,$02,$76,$BD,$71,$BD
L16D2         dc.b  $03,$78,$BD,$02,$78,$BD,$78,$BD
L16DA         dc.b  $09,$76,$BD,$02,$76,$BD,$78,$BD
L16E2         dc.b  $03,$9F,$BD,$02,$78,$BD,$71,$BD
L16EA         dc.b  $09,$76,$BD,$02,$76,$BD,$71,$BD
L16F2         dc.b  $00,$02,$4F,$87,$7A,$50,$7A,$78
L16FA         dc.b  $BD,$6E,$FE,$7A,$76,$BD,$73,$7A
L1702         dc.b  $BD,$7A,$78,$BD,$6E,$FE,$7A,$76
L170A         dc.b  $BD,$73,$00,$03,$4F,$83,$7A,$50
L1712         dc.b  $02,$7A,$BD,$7A,$BD,$09,$78,$BD
L171A         dc.b  $02,$78,$BD,$7A,$BD,$03,$93,$BD
L1722         dc.b  $02,$7A,$BD,$7A,$BD,$09,$76,$BD
L172A         dc.b  $02,$76,$BD,$73,$BD,$03,$7A,$BD
L1732         dc.b  $02,$7A,$BD,$7A,$BD,$09,$78,$BD
L173A         dc.b  $02,$78,$BD,$7A,$BD,$03,$93,$BD
L1742         dc.b  $02,$7A,$BD,$7A,$BD,$09,$76,$BD
L174A         dc.b  $02,$76,$BD,$73,$BD,$00,$02,$4F
L1752         dc.b  $87,$7D,$50,$71,$6F,$BD,$6C,$FE
L175A         dc.b  $71,$6F,$BD,$6C,$03,$78,$09,$87
L1762         dc.b  $02,$71,$09,$87,$BD,$02,$78,$09
L176A         dc.b  $87,$03,$84,$BD,$09,$87,$02,$6F
L1772         dc.b  $09,$87,$00,$03,$4F,$87,$7D,$02
L177A         dc.b  $40,$7D,$71,$09,$93,$02,$6F,$78
L1782         dc.b  $03,$93,$02,$7D,$03,$78,$09,$93
L178A         dc.b  $02,$71,$6F,$03,$78,$02,$6C,$03
L1792         dc.b  $78,$09,$87,$02,$71,$09,$87,$03
L179A         dc.b  $78,$02,$78,$09,$87,$0A,$87,$09
L17A2         dc.b  $87,$87,$00,$03,$4F,$87,$7D,$02
L17AA         dc.b  $40,$7D,$71,$09,$93,$02,$6F,$78
L17B2         dc.b  $03,$93,$02,$7D,$03,$78,$09,$93
L17BA         dc.b  $02,$71,$6F,$7D,$7B,$78,$7B,$78
L17C2         dc.b  $76,$78,$76,$73,$76,$78,$09,$7B
L17CA         dc.b  $00,$03,$4F,$83,$78,$50,$0C,$78
L17D2         dc.b  $BD,$78,$BD,$09,$76,$BD,$0C,$76
L17DA         dc.b  $BD,$78,$BD,$03,$9F,$BD,$0C,$78
L17E2         dc.b  $BD,$71,$BD,$09,$76,$BD,$0C,$76
L17EA         dc.b  $BD,$71,$BD,$78,$BD,$78,$BD,$78
L17F2         dc.b  $BD,$09,$76,$BD,$0C,$76,$BD,$78
L17FA         dc.b  $BD,$03,$9F,$BD,$0C,$78,$BD,$71
L1802         dc.b  $BD,$09,$76,$BD,$0C,$76,$BD,$71
L180A         dc.b  $BD,$00,$03,$4F,$83,$7A,$50,$0C
L1812         dc.b  $7A,$BD,$7A,$BD,$09,$78,$BD,$0C
L181A         dc.b  $78,$BD,$7A,$BD,$03,$A1,$BD,$0C
L1822         dc.b  $7A,$BD,$73,$BD,$09,$78,$BD,$0C
L182A         dc.b  $78,$BD,$73,$BD,$7A,$BD,$7A,$BD
L1832         dc.b  $7A,$BD,$09,$78,$BD,$0C,$78,$BD
L183A         dc.b  $7A,$BD,$03,$A1,$BD,$0C,$7A,$BD
L1842         dc.b  $73,$BD,$09,$78,$BD,$0C,$78,$BD
L184A         dc.b  $73,$BD,$00,$03,$4F,$87,$7D,$0C
L1852         dc.b  $40,$7D,$71,$09,$93,$0C,$6F,$78
L185A         dc.b  $03,$93,$0C,$7D,$03,$78,$09,$93
L1862         dc.b  $0C,$71,$6F,$7D,$7B,$78,$7B,$78
L186A         dc.b  $76,$78,$76,$73,$76,$78,$09,$4B
L1872         dc.b  $00,$7B,$00,$07,$4F,$83,$90,$40
L187A         dc.b  $BE,$90,$BE,$9C,$BE,$90,$BE,$9C
L1882         dc.b  $BE,$90,$BE,$9C,$BE,$90,$BE,$90
L188A         dc.b  $BE,$9C,$BE,$90,$BE,$9C,$BE,$90
L1892         dc.b  $BE,$90,$BE,$9C,$BE,$90,$BE,$9C
L189A         dc.b  $BE,$90,$BE,$9C,$BE,$90,$BE,$90
L18A2         dc.b  $BE,$9C,$BE,$90,$BE,$9C,$BE,$00
L18AA         dc.b  $07,$4F,$83,$92,$40,$BE,$92,$BE
L18B2         dc.b  $9E,$BE,$92,$BE,$9E,$BE,$92,$BE
L18BA         dc.b  $9E,$BE,$92,$BE,$92,$BE,$9E,$BE
L18C2         dc.b  $92,$BE,$9E,$BE,$92,$BE,$92,$BE
L18CA         dc.b  $9E,$BE,$92,$BE,$9E,$BE,$92,$BE
L18D2         dc.b  $9E,$BE,$92,$BE,$92,$BE,$9E,$BE
L18DA         dc.b  $92,$BE,$9E,$BE,$00,$0B,$4F,$83
L18E2         dc.b  $92,$43,$00,$97,$9A,$97,$9A,$9E
L18EA         dc.b  $9A,$9E,$A3,$9E,$A3,$A6,$A3,$A6
L18F2         dc.b  $AA,$A6,$AA,$AF,$AA,$AF,$B2,$AF
L18FA         dc.b  $AA,$AF,$AA,$A6,$AA,$A6,$A3,$A6
L1902         dc.b  $A3,$9E,$A3,$9E,$9A,$9E,$9A,$97
L190A         dc.b  $9A,$97,$92,$97,$8E,$92,$8E,$8B
L1912         dc.b  $8E,$8B,$00,$0B,$4F,$83,$90,$43
L191A         dc.b  $00,$93,$97,$93,$97,$9C,$97,$9C
L1922         dc.b  $9F,$9C,$9F,$A3,$9F,$A3,$A8,$A3
L192A         dc.b  $A8,$AB,$A8,$AB,$AF,$AB,$A8,$AB
L1932         dc.b  $A8,$A3,$A8,$A3,$9F,$A3,$9F,$9C
L193A         dc.b  $9F,$9C,$97,$9C,$97,$93,$97,$93
L1942         dc.b  $90,$93,$97,$9C,$9F,$A3,$A8,$AB
L194A         dc.b  $00,$0B,$4F,$83,$84,$43,$00,$89
L1952         dc.b  $8D,$89,$8D,$90,$8D,$90,$95,$90
L195A         dc.b  $95,$99,$95,$99,$9C,$99,$9C,$A1
L1962         dc.b  $9C,$A1,$A5,$A1,$A5,$A8,$A5,$A1
L196A         dc.b  $A5,$A1,$9C,$A1,$9C,$99,$9C,$99
L1972         dc.b  $95,$99,$95,$90,$95,$90,$8D,$90
L197A         dc.b  $8D,$89,$8D,$89,$84,$78,$00,$5F
L1982         dc.b  $83,$05,$45,$D0,$9C,$56,$FD,$43
L198A         dc.b  $03,$A8,$F3,$53,$00,$40,$BE,$E3
L1992         dc.b  $00,$5F,$83,$08,$45,$E0,$9C,$50
L199A         dc.b  $E3,$46,$FD,$BE,$50,$F2,$00,$0D
L19A2         dc.b  $4F,$83,$9C,$40,$BE,$F8,$97,$BE
L19AA         dc.b  $93,$BE,$FE,$97,$BE,$FC,$90,$BE
L19B2         dc.b  $E8,$00,$0D,$4F,$83,$9A,$40,$BE
L19BA         dc.b  $F8,$99,$BE,$97,$BE,$FE,$99,$BE
L19C2         dc.b  $FC,$92,$BE,$E8,$00,$04,$4F,$83
L19CA         dc.b  $9C,$50,$F8,$43,$00,$97,$50,$43
L19D2         dc.b  $00,$93,$50,$FE,$43,$00,$97,$50
L19DA         dc.b  $FC,$43,$00,$90,$50,$E8,$00,$0D
L19E2         dc.b  $4F,$83,$99,$50,$BD,$BE,$97,$BE
L19EA         dc.b  $95,$FE,$BE,$90,$F5,$BE,$BD,$99
L19F2         dc.b  $FE,$BE,$97,$BE,$95,$FE,$BE,$90
L19FA         dc.b  $F5,$BE,$BD,$00,$06,$40,$9C,$F7
L1A02         dc.b  $43,$00,$97,$50,$43,$00,$93,$50
L1A0A         dc.b  $FE,$43,$00,$97,$50,$FC,$43,$00
L1A12         dc.b  $90,$50,$E8,$00,$04,$4F,$83,$9A
L1A1A         dc.b  $50,$F8,$43,$00,$99,$50,$43,$00
L1A22         dc.b  $97,$50,$FE,$43,$00,$99,$50,$FC
L1A2A         dc.b  $43,$00,$92,$50,$E8,$00,$04,$4F
L1A32         dc.b  $83,$99,$50,$FE,$0D,$97,$BD,$95
L1A3A         dc.b  $FD,$90,$F5,$BE,$BD,$99,$FE,$BE
L1A42         dc.b  $97,$BE,$95,$FE,$BE,$90,$F5,$BE
L1A4A         dc.b  $BD,$00
;
                ORG     $6000
;
start           ldx     #<isr       ; Set up IRQ vector in SMON
                stx     IRQ_LO
                ldx     #>isr
                stx     IRQ_HI
;
                lda     #$03        ; Initialise the ACIA
                sta     ACIA_CONTROL
                lda     #$15
                sta     ACIA_CONTROL
;
                lda     #CR
                jsr     outch       ; Write a newline to indicate program started
                lda     #LF
                jsr     outch
                
                lda     #$00
                jsr     sid_init
;
                jsr     ptm_init    ; Initialise the PTM
                cli                 ; Enable interrupts
;
wait            bra     wait
;
;
;
; Subroutine to initialise the PTM for continuous mode with interrupts generated by timer 1
;
ptm_init        lda     #timer_MSB  ; Set up the countdown timer for timer 1
                sta     PTM_T1MSB   ; MSB must be written first!
                lda     #timer_LSB
                sta     PTM_T1LSB
;
                lda     #$00
                sta     counter     ; clear the counter
                sta     led_state   ; current LED state (all off)
                lda     #$01        ; Preset all timers
                sta     PTM_CR2     ; Write to CR1
                lda     #$42        ; CRX6=1 (interrupt); CRX1=1 (enable clock)
                sta     PTM_CR13
                lda     #$00
                sta     PTM_CR2
;
                lda     PTM_SR      ; Read the interrupt flag from the status register
;
                rts 
;
isr             ;pha                 ; Note: Registers already pushed on stack by SMON
                ;txa
                ;pha
                ;tya
                ;pha
;
isr_timer       lda     PTM_SR      ; Read the interrupt flag from the status register
                bpl     isr_other   ; Something else caused the interrupt
                
                ror                 ; rotate bit 0 to carry flag
                bcs     isr_t1      ; if set, handle timer 1 interrupt
                ror
                bcs     isr_t2      ; handle timer 2 interrupt
                ror
                bcs     isr_t3      ; handle timer 3 interrupt
                bra     isr_other   ; shouldn't really get here
;
isr_t1          jsr     sid_play
                lda     counter
                inc
                sta     counter
                cmp     #25         ; Every half second change LED state to show activity
                bne     isr_led
                lda     #$00        ; Reset counter
                sta     counter
                lda     led_state   ; invert the LEDS
                eor     #$FF
                sta     led_state
isr_led         lda     led_state
                sta     LED         ; set the LEDs with current state
;
isr_t1done      lda     PTM_T1MSB   ; clear interrupt flag for T1
                bra     isr_timer   ; check other timers
;
isr_t2          lda     PTM_T2MSB   ; clear interrupt flag for T2
                bra     isr_timer
;
isr_t3          lda     PTM_T3MSB   ; clear interrupt flag for T3
                bra     isr_done
;
isr_other                           ; If get here something else caused the interrupt (ACIA, PIA, etc)
;
isr_done        pla                 ; Restore registers that were previously pushed on stack by SMON
                tay
                pla
                tax
                pla
                rti
;
; write character to the ACIA, wait until ACIA is ready to transmit
; A, X and Y registers preserved
;
outch           pha                 ; save character
outchw          lda     ACIA_STATUS ; check ACIA status
                and     #$02        ; can write?
                beq     outchw      ; wait if not
                pla                 ; restore character
                sta     ACIA_DATA   ; write character
                rts
;
; output data byte in A as HEX (A is destroyed)
;
out2h           pha                 ; Save A
                lsr                 ; Get upper digit
                lsr
                lsr
                lsr
                jsr     outh        ; Output a hex digit
                pla                 ; Restore A
                and     #$0F
outh            cmp     #$0A        ; Is it a number
                bcc     outnum
                adc     #$06        ; Convert to letter
outnum          adc     #$30        ; Add '0'
                jmp     outch       ; write character
;
counter         ds.b    1
led_state       dc.b    1
;
              END

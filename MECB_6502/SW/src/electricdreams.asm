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
STACK           equ     $FF
;
              org   $0F82
;
; SID header
;
L0F82         fcb   $50,$53,$49,$44,$00,$02,$00,$7C
L0F8A         fcb   $00,$00,$10,$00,$10,$03,$00,$01
L0F92         fcb   $00,$01,$00,$00,$00,$00,$45,$6C
L0F9A         fcb   $65,$63,$74,$72,$69,$63,$20,$44
L0FA2         fcb   $72,$65,$61,$6D,$73,$00,$00,$00
L0FAA         fcb   $00,$00,$00,$00,$00,$00,$00,$00
L0FB2         fcb   $00,$00,$00,$00,$00,$00,$4B,$65
L0FBA         fcb   $6E,$74,$20,$50,$61,$74,$66,$69
L0FC2         fcb   $65,$6C,$64,$20,$28,$50,$61,$74
L0FCA         fcb   $74,$6F,$29,$00,$00,$00,$00,$00
L0FD2         fcb   $00,$00,$00,$00,$00,$00,$32,$30
L0FDA         fcb   $31,$39,$20,$4F,$6E,$73,$6C,$61
L0FE2         fcb   $75,$67,$68,$74,$00,$00,$00,$00
L0FEA         fcb   $00,$00,$00,$00,$00,$00,$00,$00
L0FF2         fcb   $00,$00,$00,$00,$00,$00,$00,$24
L0FFA         fcb   $00,$00,$00,$00,$00,$10
;
              org   $1000
;
sid_init      JMP L10DC
sid_play      JMP L10E0
;
L1006         fcb   $40,$46,$46,$4D
L100A         fcb   $4D,$57,$57,$57,$57,$57,$57,$57
L1012         fcb   $57,$57,$57,$57,$67,$8E,$8E,$8B
L101A         fcb   $6E,$08,$05,$00,$00,$00,$50,$41
L1022         fcb   $54,$54,$4F,$2F,$4F,$4E,$53,$4C
L102A         fcb   $41,$55,$47,$48,$54,$20,$28,$4B
L1032         fcb   $65,$6E,$74,$20,$50,$61,$74,$66
L103A         fcb   $69,$65,$6C,$64,$29,$20
;
L1040         LDA $1565,Y
              JMP L104D
              TAY
              LDA #$00
              STA $13C8,X
              TYA
L104D         STA $139F,X
              LDA $138E,X
              STA $139E,X
              RTS
              STA $13B5
              STA $13BC
              STA $13C3
              RTS
L1061         DEC $13C9,X
L1064         JMP L1299
L1067         BEQ L1064
              LDA $13C9,X
              BNE L1061
              LDA #$00
              STA $FC
              LDA $13C8,X
              BMI L1080
              CMP $1668,Y
              BCC L1081
              BEQ L1080
              EOR #$FF
L1080         CLC
L1081         ADC #$02
              STA $13C8,X
              LSR A
              BCC L10AF
              BCS L10C6
              TYA
              BEQ L10D6
              LDA $1668,Y
              STA $FC
              SEC
              LDY $13B7,X
              LDA $13CB,X
              SBC $13F2,Y
              PHA
              LDA $13CC,X
              SBC $1452,Y
              TAY
              PLA
              BCS L10BF
              ADC $FB
              TYA
              ADC $FC
              BPL L10D6
L10AF         LDA $13CB,X
              ADC $FB
              STA $13CB,X
              LDA $13CC,X
              ADC $FC
              JMP L1296
L10BF         SBC $FB
              TYA
              SBC $FC
              BMI L10D6
L10C6         LDA $13CB,X
              SBC $FB
              STA $13CB,X
              LDA $13CC,X
              SBC $FC
              JMP L1296
L10D6         LDY $13B7,X
              JMP L1288
L10DC         STA $10E3
              RTS
L10E0         LDX #$00
              LDY #$00
              BMI L1116
              TXA
              LDX #$29
L10E9         STA $1389,X
              DEX
              BPL L10E9
              STA SID+$15
              STA $1165
              STA $1117
              STX $10E3
              TAX
              JSR L1106
              LDX #$07
              JSR L1106
              LDX #$0E
L1106         LDA #$05
              STA $13B5,X
              LDA #$01
              STA $13B6,X
              STA $13B8,X
              JMP L137F
L1116         LDY #$00
              BEQ L115F
              LDA #$00
              BNE L1141
              LDA L1653,Y
              BEQ L1135
              BPL L113E
              ASL A
              STA $116A
              LDA $165D,Y
              STA $1165
              LDA $1654,Y
              BNE L1153
              INY
L1135         LDA $165D,Y
              STA $1160
              JMP L1150
L113E         STA $111B
L1141         LDA $165D,Y
              CLC
              ADC $1160
              STA $1160
              DEC $111B
              BNE L1161
L1150         LDA $1654,Y
L1153         CMP #$FF
              INY
              TYA
              BCC L115C
              LDA $165D,Y
L115C         STA $1117
L115F         LDA #$00
L1161         STA SID+$16
              LDA #$00
              STA SID+$17
              LDA #$00
              ORA #$0F
              STA SID+$18
              JSR L117A
              LDX #$07
              JSR L117A
              LDX #$0E
L117A         DEC $13B6,X
              BEQ L118A
              BPL L1187
              LDA $13B5,X
              STA $13B6,X
L1187         JMP L1232
L118A         LDY $138E,X
              LDA $1006,Y
              STA $1227
              STA $1230
              LDA $138C,X
              BNE L11BF
              LDY $13B3,X
              LDA $14B2,Y
              STA $FB
              LDA $14B5,Y
              STA $FC
              LDY $1389,X
              LDA ($FB),Y
              CMP #$FF
              BCC L11B7
              INY
              LDA ($FB),Y
              TAY
              LDA ($FB),Y
L11B7         STA $13B4,X
              INY
              TYA
              STA $1389,X
L11BF         LDY $13B8,X
              LDA $1585,Y
              STA $13E2,X
              LDA $13A0,X
              BEQ L122C
              SEC
              SBC #$60
              STA $13B7,X
              LDA #$00
              STA $139E,X
              STA $13A0,X
              LDA $1575,Y
              STA $13C9,X
              LDA $1565,Y
              STA $139F,X
              LDA $138E,X
              CMP #$03
              BEQ L122C
              LDA $1595,Y
              STA $13A2,X
              INC $13B9,X
              LDA $1545,Y
              BEQ L1204
              STA $13A3,X
              LDA #$00
              STA $13A4,X
L1204         LDA L1555,Y
              BEQ L1211
              STA $1117
              LDA #$00
              STA $111B
L1211         LDA $1535,Y
              STA $13A1,X
              LDA $1525,Y
              STA SID+$06,X
              LDA $1515,Y
              STA SID+$05,X
              LDA $138F,X
              JSR L1040
              JMP L137F
L122C         LDA $138F,X
              JSR L1040
L1232         LDY $13A1,X
              BEQ L1267
              LDA $15A5,Y
              CMP #$10
              BCS L1248
              CMP $13CA,X
              BEQ L124D
              INC $13CA,X
              BNE L1267
L1248         SBC #$10
              STA $13A2,X
L124D         LDA $15A6,Y
              CMP #$FF
              INY
              TYA
              BCC L125A
              CLC
              LDA $15D7,Y
L125A         STA $13A1,X
              LDA #$00
              STA $13CA,X
              LDA $15D6,Y
              BNE L1280
L1267         LDA $13B6,X
              BEQ L129C
              LDY $139E,X
              LDA $1016,Y
              STA $127E
              LDY $139F,X
              LDA $166C,Y
              STA $FB
              JMP L1067
L1280         BPL L1287
              ADC $13B7,X
              AND #$7F
L1287         TAY
L1288         LDA #$00
              STA $13C8,X
              LDA $13F2,Y
              STA $13CB,X
              LDA $1452,Y
L1296         STA $13CC,X
L1299         LDA $13B6,X
L129C         CMP $13E2,X
              BEQ L12FB
              LDY $13A3,X
              BEQ L12F8
              ORA $138C,X
              BEQ L12F8
              LDA $13A4,X
              BNE L12C4
              LDA $1609,Y
              BPL L12C1
              STA $13CE,X
              LDA $162E,Y
              STA $13CD,X
              JMP L12DD
L12C1         STA $13A4,X
L12C4         LDA $162E,Y
              CLC
              BPL L12CD
              DEC $13CE,X
L12CD         ADC $13CD,X
              STA $13CD,X
              BCC L12D8
              INC $13CE,X
L12D8         DEC $13A4,X
              BNE L12EF
L12DD         LDA $160A,Y
              CMP #$FF
              INY
              TYA
              BCC L12E9
              LDA $162E,Y
L12E9         STA $13A3,X
              LDA $13CD,X
L12EF         STA SID+$02,X
              LDA $13CE,X
              STA SID+$03,X
L12F8         JMP L1373
L12FB         LDY $13B4,X
              LDA $14B8,Y
              STA $FB
              LDA $14E7,Y
              STA $FC
              LDY $138C,X
              LDA ($FB),Y
              CMP #$40
              BCC L1329
              CMP #$60
              BCC L1333
              CMP #$C0
              BCC L1347
              LDA $138D,X
              BNE L1320
              LDA ($FB),Y
L1320         ADC #$00
              STA $138D,X
              BEQ L136A
              BNE L1373
L1329         STA $13B8,X
              INY
              LDA ($FB),Y
              CMP #$60
              BCS L1347
L1333         CMP #$50
              AND #$0F
              STA $138E,X
              BEQ L1342
              INY
              LDA ($FB),Y
              STA $138F,X
L1342         BCS L136A
              INY
              LDA ($FB),Y
L1347         CMP #$BD
              BCC L1351
              BEQ L136A
              ORA #$F0
              BNE L1367
L1351         STA $13A0,X
              LDA $138E,X
              CMP #$03
              BEQ L136A
              LDA #$00
              STA SID+$06,X
              LDA #$10
              STA SID+$05,X
              LDA #$FE
L1367         STA $13B9,X
L136A         INY
              LDA ($FB),Y
              BEQ L1370
              TYA
L1370         STA $138C,X
L1373         LDA $13CB,X
              STA SID+$00,X
              LDA $13CC,X
              STA SID+$01,X
L137F         LDA $13A2,X
              AND $13B9,X
              STA SID+$04,X
              RTS
;
L1389         fcb   $00
L138A         fcb   $00,$00,$00,$00,$00,$00,$00,$00
L1392         fcb   $00,$00,$00,$00,$00,$00,$00,$00
L139A         fcb   $00,$00,$00,$00,$00,$00,$00,$00
L13A2         fcb   $00,$00,$00,$00,$00,$00,$00,$00
L13AA         fcb   $00,$00,$00,$00,$00,$00,$00,$00
L13B2         fcb   $00,$00,$00,$00,$00,$00,$01,$FE
L13BA         fcb   $01,$00,$00,$00,$00,$01,$FE,$02
L13C2         fcb   $00,$00,$00,$00,$01,$FE,$00,$00
L13CA         fcb   $00,$00,$00,$00,$00,$00,$00,$00
L13D2         fcb   $00,$00,$00,$00,$00,$00,$00,$00
L13DA         fcb   $00,$00,$00,$00,$00,$00,$00,$00
L13E2         fcb   $00,$00,$00,$00,$00,$00,$00,$00
L13EA         fcb   $00,$00,$00,$00,$00,$00,$00,$00
L13F2         fcb   $17,$27,$39,$4B,$5F,$74,$8A,$A1
L13FA         fcb   $BA,$D4,$F0,$0E,$2D,$4E,$71,$96
L1402         fcb   $BE,$E8,$14,$43,$74,$A9,$E1,$1C
L140A         fcb   $5A,$9C,$E2,$2D,$7C,$CF,$28,$85
L1412         fcb   $E8,$52,$C1,$37,$B4,$39,$C5,$5A
L141A         fcb   $F7,$9E,$4F,$0A,$D1,$A3,$82,$6E
L1422         fcb   $68,$71,$8A,$B3,$EE,$3C,$9E,$15
L142A         fcb   $A2,$46,$04,$DC,$D0,$E2,$14,$67
L1432         fcb   $DD,$79,$3C,$29,$44,$8D,$08,$B8
L143A         fcb   $A1,$C5,$28,$CD,$BA,$F1,$78,$53
L1442         fcb   $87,$1A,$10,$71,$42,$89,$4F,$9B
L144A         fcb   $74,$E2,$F0,$A6,$0E,$33,$20,$FF
L1452         fcb   $01,$01,$01,$01,$01,$01,$01,$01
L145A         fcb   $01,$01,$01,$02,$02,$02,$02,$02
L1462         fcb   $02,$02,$03,$03,$03,$03,$03,$04
L146A         fcb   $04,$04,$04,$05,$05,$05,$06,$06
L1472         fcb   $06,$07,$07,$08,$08,$09,$09,$0A
L147A         fcb   $0A,$0B,$0C,$0D,$0D,$0E,$0F,$10
L1482         fcb   $11,$12,$13,$14,$15,$17,$18,$1A
L148A         fcb   $1B,$1D,$1F,$20,$22,$24,$27,$29
L1492         fcb   $2B,$2E,$31,$34,$37,$3A,$3E,$41
L149A         fcb   $45,$49,$4E,$52,$57,$5C,$62,$68
L14A2         fcb   $6E,$75,$7C,$83,$8B,$93,$9C,$A5
L14AA         fcb   $AF,$B9,$C4,$D0,$DD,$EA,$F8,$FF
L14B2         fcb   $70,$83,$96,$16,$16,$16,$A9,$B6
L14BA         fcb   $C4,$D2,$DE,$30,$8C,$CE,$15,$54
L14C2         fcb   $BE,$2D,$9C,$D0,$DE,$E7,$F6,$BA
L14CA         fcb   $3C,$BE,$21,$44,$4E,$5C,$68,$79
L14D2         fcb   $C3,$FD,$1B,$9D,$1F,$36,$43,$50
L14DA         fcb   $61,$74,$89,$C2,$F1,$2B,$6A,$A9
L14E2         fcb   $E2,$02,$25,$34,$3E,$16,$16,$16
L14EA         fcb   $16,$16,$17,$17,$17,$18,$18,$18
L14F2         fcb   $19,$19,$19,$19,$19,$19,$1A,$1B
L14FA         fcb   $1B,$1C,$1C,$1C,$1C,$1C,$1C,$1C
L1502         fcb   $1C,$1D,$1D,$1E,$1E,$1E,$1E,$1E
L150A         fcb   $1E,$1E,$1E,$1E,$1F,$1F,$1F,$1F
L1512         fcb   $20,$20,$20,$20,$08,$49,$02,$02
L151A         fcb   $06,$02,$05,$66,$04,$04,$04,$02
L1522         fcb   $02,$03,$03,$03,$B9,$9A,$77,$8F
L152A         fcb   $AB,$7F,$E5,$55,$4A,$4A,$4A,$6B
L1532         fcb   $79,$53,$53,$53,$11,$15,$08,$0E
L153A         fcb   $01,$05,$1B,$21,$24,$29,$2E,$03
L1542         fcb   $0E,$24,$29,$2E,$08,$14,$00,$0F
L154A         fcb   $08,$0D,$00,$02,$06,$06,$06,$17
L1552         fcb   $1C,$22,$22
L1555         fcb   $24,$00,$04,$00,$02
L155A         fcb   $00,$01,$00,$00,$00,$00,$00,$08
L1562         fcb   $08,$00,$00,$00,$00,$01,$00,$00
L156A         fcb   $00,$00,$00,$00,$00,$00,$00,$02
L1572         fcb   $03,$00,$00,$00,$0E,$07,$00,$00
L157A         fcb   $00,$00,$00,$00,$00,$00,$00,$13
L1582         fcb   $11,$00,$00,$00,$01,$01,$02,$02
L158A         fcb   $02,$02,$02,$01,$02,$02,$02,$01
L1592         fcb   $01,$02,$02,$02,$19,$09,$09,$09
L159A         fcb   $09,$09,$19,$09,$09,$09,$09,$19
L15A2         fcb   $19,$19,$09,$09,$91,$51,$51,$FF
L15AA         fcb   $51,$21,$FF,$91,$51,$51,$50,$00
L15B2         fcb   $FF,$61,$51,$FF,$61,$61,$51,$FF
L15BA         fcb   $91,$51,$51,$91,$51,$FF,$91,$51
L15C2         fcb   $00,$90,$90,$FF,$21,$51,$FF,$51
L15CA         fcb   $02,$02,$02,$FF,$51,$02,$02,$02
L15D2         fcb   $FF,$51,$02,$02,$02,$FF,$58,$28
L15DA         fcb   $80,$00,$80,$80,$00,$58,$26,$20
L15E2         fcb   $18,$14,$00,$80,$80,$00,$80,$80
L15EA         fcb   $80,$00,$4F,$26,$2C,$50,$80,$00
L15F2         fcb   $5F,$2D,$2B,$5F,$40,$00,$8C,$80
L15FA         fcb   $00,$80,$83,$88,$8C,$25,$80,$81
L1602         fcb   $85,$8D,$2A,$80,$83,$87,$8C,$2F
L160A         fcb   $25,$4A,$25,$FF,$08,$08,$FF,$88
L1612         fcb   $18,$08,$08,$FF,$80,$FF,$80,$29
L161A         fcb   $25,$25,$FF,$88,$03,$FF,$82,$10
L1622         fcb   $40,$40,$FF,$80,$3B,$1B,$1B,$FF
L162A         fcb   $FF,$08,$FF,$08,$FF,$30,$D0,$30
L1632         fcb   $01,$C0,$40,$05,$00,$40,$C0,$40
L163A         fcb   $0A,$80,$00,$40,$30,$D0,$30,$11
L1642         fcb   $00,$00,$12,$00,$7F,$E0,$20,$19
L164A         fcb   $20,$40,$C0,$40,$1E,$20,$40,$21
L1652         fcb   $40
L1653         fcb   $23,$88,$00,$70,$B8,$00,$03
L165A         fcb   $FF,$70,$70,$FF,$82,$A0,$FF,$F4
L1662         fcb   $F0,$E0,$02,$FF,$01,$08,$00,$03
L166A         fcb   $02,$03,$00,$10,$40,$08,$00,$01
L1672         fcb   $0D,$02,$0E,$03,$0F,$04,$05,$06
L167A         fcb   $07,$08,$09,$0A,$0B,$0C,$05,$FF
L1682         fcb   $09,$10,$11,$1C,$12,$1D,$11,$1C
L168A         fcb   $13,$14,$15,$16,$17,$18,$19,$1A
L1692         fcb   $1B,$14,$FF,$09,$1E,$1F,$2C,$20
L169A         fcb   $2D,$21,$2E,$22,$23,$24,$25,$26
L16A2         fcb   $27,$28,$29,$2A,$2B,$FF,$09,$4F
L16AA         fcb   $02,$BE,$50,$E2,$01,$7B,$C9,$87
L16B2         fcb   $F9,$7B,$E1,$00,$50,$EF,$BE,$BD
L16BA         fcb   $01,$76,$BD,$BE,$BD,$76,$F9,$7B
L16C2         fcb   $E1,$00,$50,$F5,$01,$82,$BD,$BE
L16CA         fcb   $BD,$82,$F9,$76,$F9,$7B,$E1,$00
L16D2         fcb   $50,$E6,$01,$73,$43,$00,$76,$50
L16DA         fcb   $FE,$7B,$E1,$00,$50,$E9,$01,$82
L16E2         fcb   $BD,$43,$00,$81,$80,$7F,$7E,$7C
L16EA         fcb   $50,$05,$7B,$FA,$BE,$07,$60,$FD
L16F2         fcb   $01,$7B,$FE,$BE,$03,$60,$FD,$01
L16FA         fcb   $7B,$FE,$BE,$07,$60,$FD,$01,$7B
L1702         fcb   $FE,$BE,$05,$7B,$F9,$07,$60,$FD
L170A         fcb   $01,$7B,$FD,$03,$60,$FD,$01,$7B
L1712         fcb   $FD,$07,$60,$FD,$01,$7B,$FE,$BE
L171A         fcb   $05,$7B,$F9,$07,$60,$FD,$01,$7B
L1722         fcb   $FD,$03,$60,$FD,$01,$7B,$FD,$07
L172A         fcb   $60,$FD,$01,$7B,$FD,$00,$05,$40
L1732         fcb   $7B,$FA,$BE,$07,$60,$FD,$01,$7B
L173A         fcb   $FD,$03,$60,$FD,$01,$76,$FD,$07
L1742         fcb   $60,$FD,$01,$76,$FD,$05,$7B,$FA
L174A         fcb   $BE,$07,$60,$FD,$01,$7B,$FE,$BE
L1752         fcb   $03,$60,$FD,$01,$7B,$FE,$BE,$07
L175A         fcb   $60,$FD,$01,$7B,$FE,$BE,$05,$7B
L1762         fcb   $F9,$07,$60,$FD,$01,$7B,$FD,$03
L176A         fcb   $60,$FD,$01,$7B,$FD,$07,$60,$FD
L1772         fcb   $01,$7B,$FE,$BE,$05,$7B,$F9,$07
L177A         fcb   $60,$FD,$01,$7B,$FD,$03,$60,$FD
L1782         fcb   $01,$7B,$FD,$07,$60,$FD,$01,$7B
L178A         fcb   $FD,$00,$05,$40,$7B,$FA,$BE,$07
L1792         fcb   $60,$FD,$01,$7B,$FD,$03,$60,$FD
L179A         fcb   $01,$76,$FD,$02,$78,$FD,$BE,$FD
L17A2         fcb   $05,$7B,$F9,$07,$60,$BD,$BE,$F7
L17AA         fcb   $05,$7B,$FD,$07,$60,$F9,$05,$76
L17B2         fcb   $F9,$07,$60,$FD,$BE,$F9,$05,$76
L17BA         fcb   $FE,$BE,$07,$60,$F9,$05,$78,$F9
L17C2         fcb   $07,$60,$FD,$BE,$F9,$05,$78,$FD
L17CA         fcb   $07,$60,$F9,$00,$05,$40,$74,$F9
L17D2         fcb   $07,$60,$FB,$BE,$FB,$03,$60,$FD
L17DA         fcb   $02,$74,$FA,$BE,$01,$7B,$F9,$07
L17E2         fcb   $60,$FE,$BE,$F8,$05,$7B,$FD,$07
L17EA         fcb   $60,$FE,$BE,$05,$78,$FD,$79,$F9
L17F2         fcb   $07,$60,$BD,$BE,$F7,$05,$79,$FD
L17FA         fcb   $07,$60,$FE,$BE,$FC,$05,$71,$F9
L1802         fcb   $07,$60,$FD,$01,$73,$FC,$BE,$FE
L180A         fcb   $05,$74,$FD,$07,$60,$FE,$BE,$05
L1812         fcb   $76,$FD,$00,$03,$40,$60,$FD,$01
L181A         fcb   $76,$BE,$FE,$02,$76,$F5,$05,$76
L1822         fcb   $FD,$07,$60,$FD,$BE,$FD,$05,$7B
L182A         fcb   $F9,$07,$60,$BD,$BE,$F7,$05,$7B
L1832         fcb   $FD,$07,$60,$F9,$05,$76,$F9,$07
L183A         fcb   $60,$FD,$BE,$F9,$05,$76,$FE,$BE
L1842         fcb   $07,$60,$F9,$05,$78,$F9,$07,$60
L184A         fcb   $FD,$BE,$F9,$05,$78,$FD,$07,$60
L1852         fcb   $F9,$00,$05,$40,$74,$F9,$07,$60
L185A         fcb   $FD,$01,$74,$BD,$BE,$BD,$03,$60
L1862         fcb   $FD,$01,$74,$FD,$76,$BD,$43,$00
L186A         fcb   $77,$50,$43,$00,$79,$50,$BD,$43
L1872         fcb   $00,$7A,$40,$7B,$FD,$7B,$FD,$07
L187A         fcb   $60,$FE,$BE,$01,$7B,$FD,$BE,$FD
L1882         fcb   $7B,$FD,$07,$60,$FE,$BE,$01,$78
L188A         fcb   $FD,$05,$79,$FD,$01,$79,$FD,$07
L1892         fcb   $60,$BD,$BE,$BD,$01,$79,$FD,$BE
L189A         fcb   $FD,$05,$79,$FD,$07,$60,$FE,$BE
L18A2         fcb   $01,$79,$FD,$05,$71,$FD,$01,$71
L18AA         fcb   $FD,$07,$60,$FD,$01,$73,$FC,$BE
L18B2         fcb   $FE,$05,$74,$FD,$07,$60,$FE,$BE
L18BA         fcb   $01,$76,$FD,$00,$03,$40,$60,$FE
L18C2         fcb   $BE,$01,$82,$FE,$BE,$02,$76,$FC
L18CA         fcb   $BE,$FE,$05,$76,$FE,$BE,$01,$82
L18D2         fcb   $FD,$02,$76,$F9,$05,$7B,$BD,$BE
L18DA         fcb   $BD,$01,$7B,$FD,$07,$60,$FD,$01
L18E2         fcb   $7B,$FE,$BE,$03,$60,$FD,$01,$7B
L18EA         fcb   $FD,$07,$60,$FD,$01,$7B,$BE,$FE
L18F2         fcb   $05,$7D,$BD,$BE,$BD,$01,$7D,$FD
L18FA         fcb   $07,$60,$FD,$01,$7D,$FD,$03,$60
L1902         fcb   $FD,$01,$7D,$FD,$07,$60,$FD,$01
L190A         fcb   $7D,$BD,$BE,$BD,$05,$7F,$BD,$BE
L1912         fcb   $BD,$01,$7F,$FE,$BE,$07,$60,$FD
L191A         fcb   $01,$7F,$FE,$BE,$03,$60,$FD,$01
L1922         fcb   $7F,$FD,$07,$60,$FD,$01,$7F,$BD
L192A         fcb   $BE,$BD,$00,$05,$40,$80,$FD,$01
L1932         fcb   $80,$FD,$07,$60,$FD,$01,$80,$FE
L193A         fcb   $BE,$05,$76,$FC,$BE,$FE,$02,$76
L1942         fcb   $F9,$05,$7B,$BD,$BE,$BD,$01,$7B
L194A         fcb   $FD,$07,$60,$FD,$01,$7B,$BD,$BE
L1952         fcb   $BD,$03,$60,$FD,$01,$7B,$FD,$07
L195A         fcb   $60,$FD,$01,$7B,$BE,$FE,$05,$7D
L1962         fcb   $BD,$BE,$BD,$01,$7D,$FD,$07,$60
L196A         fcb   $FD,$01,$7D,$FD,$03,$60,$FD,$01
L1972         fcb   $7D,$FD,$07,$60,$FD,$01,$7D,$BD
L197A         fcb   $BE,$BD,$05,$7F,$BD,$BE,$BD,$01
L1982         fcb   $7F,$FE,$BE,$07,$60,$FD,$01,$7F
L198A         fcb   $BD,$BE,$BD,$03,$60,$FD,$01,$7F
L1992         fcb   $FD,$07,$60,$FD,$01,$7F,$BD,$BE
L199A         fcb   $BD,$00,$05,$40,$80,$FD,$01,$80
L19A2         fcb   $FD,$07,$60,$FD,$01,$80,$BD,$BE
L19AA         fcb   $BD,$05,$76,$FC,$BE,$FE,$02,$76
L19B2         fcb   $F9,$05,$7B,$BD,$BE,$BD,$01,$7B
L19BA         fcb   $FD,$07,$60,$FD,$01,$7B,$FE,$BE
L19C2         fcb   $03,$60,$FD,$01,$7B,$FD,$07,$60
L19CA         fcb   $FD,$01,$87,$FE,$BE,$00,$50,$EF
L19D2         fcb   $BE,$BD,$01,$87,$BD,$BE,$BD,$87
L19DA         fcb   $F9,$7B,$E1,$00,$50,$EA,$BE,$01
L19E2         fcb   $87,$F9,$7B,$E1,$00,$50,$EE,$01
L19EA         fcb   $86,$43,$00,$87,$50,$BE,$BD,$87
L19F2         fcb   $F9,$7B,$E1,$00,$40,$BE,$E1,$04
L19FA         fcb   $93,$BD,$08,$43,$00,$87,$50,$43
L1A02         fcb   $00,$8B,$50,$43,$00,$8E,$50,$43
L1A0A         fcb   $00,$93,$50,$43,$00,$87,$50,$43
L1A12         fcb   $00,$8B,$50,$43,$00,$8E,$50,$43
L1A1A         fcb   $00,$8B,$50,$43,$00,$87,$50,$43
L1A22         fcb   $00,$8B,$50,$43,$00,$8E,$50,$43
L1A2A         fcb   $00,$93,$50,$43,$00,$97,$50,$43
L1A32         fcb   $00,$93,$50,$43,$00,$8B,$50,$43
L1A3A         fcb   $00,$93,$50,$43,$00,$87,$50,$43
L1A42         fcb   $00,$8B,$50,$43,$00,$8E,$50,$43
L1A4A         fcb   $00,$8B,$50,$43,$00,$8E,$50,$43
L1A52         fcb   $00,$93,$50,$43,$00,$97,$50,$43
L1A5A         fcb   $00,$93,$50,$43,$00,$8B,$50,$43
L1A62         fcb   $00,$8E,$50,$43,$00,$87,$50,$43
L1A6A         fcb   $00,$8B,$50,$43,$00,$8E,$50,$43
L1A72         fcb   $00,$97,$50,$43,$00,$93,$50,$43
L1A7A         fcb   $00,$90,$50,$43,$00,$8C,$50,$43
L1A82         fcb   $00,$90,$50,$43,$00,$93,$50,$43
L1A8A         fcb   $00,$98,$50,$43,$00,$93,$50,$43
L1A92         fcb   $00,$90,$50,$43,$00,$8C,$50,$43
L1A9A         fcb   $00,$93,$50,$43,$00,$87,$50,$43
L1AA2         fcb   $00,$8C,$50,$43,$00,$90,$50,$43
L1AAA         fcb   $00,$98,$50,$43,$00,$93,$50,$43
L1AB2         fcb   $00,$98,$50,$43,$00,$9C,$50,$00
L1ABA         fcb   $08,$43,$00,$98,$50,$43,$00,$93
L1AC2         fcb   $50,$43,$00,$90,$50,$43,$00,$93
L1ACA         fcb   $50,$43,$00,$98,$50,$43,$00,$93
L1AD2         fcb   $50,$43,$00,$90,$50,$43,$00,$8C
L1ADA         fcb   $50,$43,$00,$90,$50,$43,$00,$8C
L1AE2         fcb   $50,$43,$00,$87,$50,$43,$00,$8C
L1AEA         fcb   $50,$43,$00,$90,$50,$43,$00,$93
L1AF2         fcb   $50,$43,$00,$98,$50,$43,$00,$9C
L1AFA         fcb   $50,$43,$00,$89,$50,$43,$00,$8E
L1B02         fcb   $50,$43,$00,$92,$50,$43,$00,$95
L1B0A         fcb   $50,$43,$00,$9E,$50,$43,$00,$95
L1B12         fcb   $50,$43,$00,$9A,$50,$43,$00,$95
L1B1A         fcb   $50,$43,$00,$92,$50,$43,$00,$95
L1B22         fcb   $50,$43,$00,$9A,$50,$43,$00,$95
L1B2A         fcb   $50,$43,$00,$92,$50,$43,$00,$95
L1B32         fcb   $50,$43,$00,$8E,$50,$43,$00,$95
L1B3A         fcb   $50,$00,$08,$43,$00,$93,$50,$43
L1B42         fcb   $00,$90,$50,$43,$00,$93,$50,$43
L1B4A         fcb   $00,$9C,$50,$43,$00,$93,$50,$43
L1B52         fcb   $00,$9F,$50,$43,$00,$93,$50,$43
L1B5A         fcb   $00,$9C,$50,$43,$00,$93,$50,$43
L1B62         fcb   $00,$98,$50,$43,$00,$90,$50,$43
L1B6A         fcb   $00,$8C,$50,$43,$00,$87,$50,$43
L1B72         fcb   $00,$8C,$50,$43,$00,$90,$50,$43
L1B7A         fcb   $00,$93,$50,$43,$00,$93,$50,$43
L1B82         fcb   $00,$87,$50,$43,$00,$8B,$50,$43
L1B8A         fcb   $00,$8E,$50,$43,$00,$93,$50,$43
L1B92         fcb   $00,$87,$50,$43,$00,$8B,$50,$43
L1B9A         fcb   $00,$8E,$50,$43,$00,$8B,$50,$43
L1BA2         fcb   $00,$87,$50,$43,$00,$8B,$50,$43
L1BAA         fcb   $00,$8E,$50,$43,$00,$93,$50,$43
L1BB2         fcb   $00,$97,$50,$43,$00,$93,$50,$43
L1BBA         fcb   $00,$8B,$50,$00,$08,$43,$00,$93
L1BC2         fcb   $50,$43,$00,$90,$50,$43,$00,$93
L1BCA         fcb   $50,$43,$00,$9C,$50,$43,$00,$93
L1BD2         fcb   $50,$43,$00,$9F,$50,$43,$00,$93
L1BDA         fcb   $50,$43,$00,$9C,$50,$43,$00,$93
L1BE2         fcb   $50,$43,$00,$98,$50,$43,$00,$90
L1BEA         fcb   $50,$43,$00,$8C,$50,$43,$00,$87
L1BF2         fcb   $50,$43,$00,$8C,$50,$43,$00,$90
L1BFA         fcb   $50,$43,$00,$93,$40,$BE,$09,$97
L1C02         fcb   $F7,$BE,$BD,$97,$FC,$BE,$FE,$97
L1C0A         fcb   $FB,$BE,$BD,$0A,$97,$DD,$09,$92
L1C12         fcb   $F8,$BE,$FE,$92,$FC,$BE,$FE,$92
L1C1A         fcb   $FD,$BE,$FD,$0A,$92,$FD,$00,$50
L1C22         fcb   $E1,$09,$97,$F7,$BE,$BD,$97,$FC
L1C2A         fcb   $BE,$FE,$97,$FB,$BE,$BD,$0A,$97
L1C32         fcb   $DD,$09,$92,$F8,$BE,$FE,$92,$FC
L1C3A         fcb   $BE,$FE,$92,$FD,$BE,$FD,$0A,$92
L1C42         fcb   $FD,$00,$50,$E5,$09,$8B,$DD,$86
L1C4A         fcb   $E1,$8B,$E1,$00,$0A,$40,$8B,$E1
L1C52         fcb   $09,$8B,$E1,$0A,$8B,$E1,$0B,$89
L1C5A         fcb   $E1,$00,$0A,$40,$8B,$E1,$09,$8B
L1C62         fcb   $E1,$86,$E1,$8B,$E1,$00,$0A,$40
L1C6A         fcb   $8B,$E9,$07,$60,$F9,$09,$8B,$E1
L1C72         fcb   $0A,$8B,$E1,$0B,$89,$E1,$00,$0A
L1C7A         fcb   $40,$8B,$E1,$0E,$97,$BD,$97,$BD
L1C82         fcb   $97,$BD,$97,$BD,$97,$FD,$97,$FD
L1C8A         fcb   $97,$FD,$97,$FD,$97,$FD,$97,$BD
L1C92         fcb   $0F,$97,$BD,$97,$BD,$97,$BD,$97
L1C9A         fcb   $BD,$97,$BD,$97,$FD,$97,$FD,$97
L1CA2         fcb   $BD,$97,$BD,$97,$FD,$97,$FD,$97
L1CAA         fcb   $FD,$0E,$97,$BD,$97,$BD,$97,$BD
L1CB2         fcb   $97,$BD,$97,$FD,$97,$FD,$97,$FD
L1CBA         fcb   $97,$FD,$97,$BD,$97,$BD,$97,$FD
L1CC2         fcb   $00,$0F,$40,$97,$BD,$97,$BD,$97
L1CCA         fcb   $BD,$97,$BD,$97,$FD,$10,$97,$FD
L1CD2         fcb   $97,$FD,$97,$FD,$97,$F9,$0D,$97
L1CDA         fcb   $FB,$BE,$FB,$9A,$F5,$9F,$F9,$98
L1CE2         fcb   $F3,$BE,$EF,$0E,$97,$BD,$97,$BD
L1CEA         fcb   $97,$BD,$97,$BD,$97,$FD,$97,$FD
L1CF2         fcb   $97,$FD,$97,$FD,$97,$BD,$97,$BD
L1CFA         fcb   $97,$FD,$00,$0E,$40,$97,$BD,$97
L1D02         fcb   $BD,$97,$BD,$97,$BD,$97,$FD,$97
L1D0A         fcb   $FD,$0F,$97,$FD,$97,$BD,$97,$BD
L1D12         fcb   $97,$FD,$97,$FD,$09,$97,$E2,$BE
L1D1A         fcb   $00,$08,$43,$00,$92,$50,$43,$00
L1D22         fcb   $95,$50,$43,$00,$8E,$50,$43,$00
L1D2A         fcb   $95,$50,$43,$00,$89,$50,$43,$00
L1D32         fcb   $8E,$50,$43,$00,$92,$50,$43,$00
L1D3A         fcb   $95,$50,$43,$00,$9E,$50,$43,$00
L1D42         fcb   $9A,$50,$43,$00,$9E,$50,$43,$00
L1D4A         fcb   $95,$50,$43,$00,$9A,$50,$43,$00
L1D52         fcb   $92,$50,$43,$00,$95,$50,$43,$00
L1D5A         fcb   $8E,$50,$43,$00,$8C,$50,$43,$00
L1D62         fcb   $90,$50,$43,$00,$93,$50,$43,$00
L1D6A         fcb   $9C,$50,$43,$00,$90,$50,$43,$00
L1D72         fcb   $98,$50,$43,$00,$93,$50,$43,$00
L1D7A         fcb   $90,$50,$43,$00,$8C,$50,$43,$00
L1D82         fcb   $87,$50,$43,$00,$8C,$50,$43,$00
L1D8A         fcb   $90,$50,$43,$00,$93,$50,$43,$00
L1D92         fcb   $9C,$50,$43,$00,$93,$50,$43,$00
L1D9A         fcb   $98,$50,$00,$08,$43,$00,$93,$50
L1DA2         fcb   $43,$00,$87,$50,$43,$00,$8B,$50
L1DAA         fcb   $43,$00,$8E,$50,$43,$00,$8B,$50
L1DB2         fcb   $43,$00,$8E,$50,$43,$00,$93,$50
L1DBA         fcb   $43,$00,$97,$50,$43,$00,$93,$50
L1DC2         fcb   $43,$00,$8B,$50,$43,$00,$8E,$50
L1DCA         fcb   $43,$00,$87,$50,$43,$00,$8B,$50
L1DD2         fcb   $43,$00,$8E,$50,$43,$00,$97,$50
L1DDA         fcb   $43,$00,$93,$50,$43,$00,$90,$50
L1DE2         fcb   $43,$00,$8C,$50,$43,$00,$90,$50
L1DEA         fcb   $43,$00,$93,$50,$43,$00,$98,$50
L1DF2         fcb   $43,$00,$93,$50,$43,$00,$90,$50
L1DFA         fcb   $43,$00,$8C,$50,$43,$00,$93,$50
L1E02         fcb   $43,$00,$87,$50,$43,$00,$8C,$50
L1E0A         fcb   $43,$00,$90,$50,$43,$00,$98,$50
L1E12         fcb   $43,$00,$93,$50,$43,$00,$98,$50
L1E1A         fcb   $43,$00,$9C,$50,$00,$40,$BE,$E1
L1E22         fcb   $06,$B7,$FD,$B2,$FD,$AF,$FD,$AB
L1E2A         fcb   $ED,$BE,$E1,$B7,$FD,$B4,$FD,$B0
L1E32         fcb   $FD,$AB,$ED,$00,$40,$BE,$E1,$06
L1E3A         fcb   $B6,$FD,$B2,$FD,$AD,$FD,$AA,$ED
L1E42         fcb   $00,$50,$E3,$04,$95,$43,$00,$96
L1E4A         fcb   $97,$50,$E4,$BE,$BD,$00,$50,$F3
L1E52         fcb   $BE,$BD,$04,$9A,$43,$00,$9B,$9C
L1E5A         fcb   $50,$F4,$9A,$E3,$BE,$BD,$00,$50
L1E62         fcb   $E5,$09,$8B,$BD,$8B,$BD,$8B,$E5
L1E6A         fcb   $0A,$8B,$DD,$09,$86,$E5,$0A,$86
L1E72         fcb   $FD,$00,$50,$E5,$04,$8B,$BE,$8B
L1E7A         fcb   $BE,$8B,$F7,$BE,$EF,$0A,$8B,$DD
L1E82         fcb   $09,$86,$E5,$0A,$86,$FD,$00,$50
L1E8A         fcb   $E5,$0C,$93,$BE,$FE,$93,$FB,$BE
L1E92         fcb   $BD,$93,$FE,$BE,$93,$FC,$BE,$FE
L1E9A         fcb   $93,$FC,$BE,$FE,$95,$F8,$BE,$FE
L1EA2         fcb   $95,$BD,$BE,$BD,$95,$F7,$BE,$FB
L1EAA         fcb   $95,$BD,$BE,$BD,$97,$BE,$FE,$97
L1EB2         fcb   $FC,$BE,$FE,$97,$FB,$BE,$53,$00
L1EBA         fcb   $40,$9F,$FB,$BE,$BD,$9C,$FD,$00
L1EC2         fcb   $50,$F6,$BE,$FC,$0C,$98,$BD,$BE
L1ECA         fcb   $BD,$98,$BD,$BE,$BD,$98,$BE,$FE
L1ED2         fcb   $98,$F6,$BE,$97,$BD,$BE,$BD,$97
L1EDA         fcb   $F8,$BE,$F6,$9A,$F8,$BE,$FE,$9A
L1EE2         fcb   $BE,$FE,$98,$FB,$BE,$BD,$97,$BD
L1EEA         fcb   $BE,$BD,$95,$F3,$BE,$EB,$00,$50
L1EF2         fcb   $E5,$0C,$93,$BD,$BE,$BD,$93,$FC
L1EFA         fcb   $BE,$FE,$93,$BD,$BE,$BD,$93,$FC
L1F02         fcb   $BE,$FE,$93,$FC,$BE,$FE,$95,$F8
L1F0A         fcb   $BE,$FE,$95,$BD,$BE,$BD,$95,$FA
L1F12         fcb   $BE,$F8,$95,$BD,$BE,$BD,$97,$FD
L1F1A         fcb   $BE,$FD,$97,$BD,$BE,$BD,$97,$FC
L1F22         fcb   $BE,$FE,$9F,$FC,$BE,$FE,$9C,$FD
L1F2A         fcb   $00,$50,$F5,$BE,$FD,$0C,$98,$BD
L1F32         fcb   $BE,$BD,$98,$BE,$FE,$98,$BE,$FE
L1F3A         fcb   $98,$FD,$98,$FD,$43,$00,$97,$50
L1F42         fcb   $F5,$BE,$F6,$97,$BD,$BE,$BD,$9A
L1F4A         fcb   $FD,$BE,$FD,$9A,$FC,$BE,$FE,$98
L1F52         fcb   $FC,$BE,$FE,$97,$FD,$98,$BD,$43
L1F5A         fcb   $00,$97,$50,$43,$00,$95,$50,$EE
L1F62         fcb   $BE,$FD,$9C,$FE,$BE,$9A,$FD,$00
L1F6A         fcb   $50,$FB,$BE,$0C,$A1,$43,$00,$A3
L1F72         fcb   $50,$FE,$43,$00,$A1,$50,$FA,$43
L1F7A         fcb   $00,$A3,$50,$F6,$0D,$97,$FB,$BE
L1F82         fcb   $FB,$9A,$F5,$9F,$F9,$98,$F5,$0C
L1F8A         fcb   $9F,$BE,$FE,$9F,$BE,$FE,$9F,$BE
L1F92         fcb   $FE,$9F,$BD,$BE,$BD,$9F,$BE,$FE
L1F9A         fcb   $A1,$BD,$BE,$BD,$A3,$F9,$BE,$F5
L1FA2         fcb   $9F,$BD,$BE,$BD,$A1,$FD,$00,$50
L1FAA         fcb   $BE,$FE,$0C,$A3,$FC,$BE,$BD,$A3
L1FB2         fcb   $43,$00,$A4,$50,$F7,$BE,$A3,$FC
L1FBA         fcb   $BE,$BD,$A1,$43,$00,$A3,$50,$D6
L1FC2         fcb   $9F,$BE,$FE,$9F,$BD,$BE,$BD,$9F
L1FCA         fcb   $BE,$FE,$9F,$BD,$BE,$BD,$9F,$BE
L1FD2         fcb   $FE,$A1,$BD,$BE,$BD,$A3,$F5,$BE
L1FDA         fcb   $F9,$9F,$BD,$BE,$BD,$A1,$FD,$00
L1FE2         fcb   $50,$BE,$FE,$0C,$A1,$BD,$BE,$BD
L1FEA         fcb   $A1,$BE,$FE,$A1,$BE,$BD,$A1,$43
L1FF2         fcb   $00,$A3,$50,$BD,$BE,$A1,$FD,$9F
L1FFA         fcb   $FC,$BE,$FE,$9F,$ED,$BE,$F5,$00
L2002         fcb   $50,$ED,$BE,$F5,$09,$8B,$F7,$BE
L200A         fcb   $BD,$8B,$FC,$BE,$FE,$8B,$F9,$0A
L2012         fcb   $8B,$DD,$09,$86,$F8,$BE,$FE,$86
L201A         fcb   $FC,$BE,$FE,$86,$FD,$BE,$FD,$0A
L2022         fcb   $86,$FD,$00,$40,$BE,$E1,$06,$B7
L202A         fcb   $FD,$B4,$FD,$B0,$FD,$AB,$FD,$BE
L2032         fcb   $F1,$00,$04,$40,$9A,$F2,$BE,$9F
L203A         fcb   $F1,$98,$E1,$00,$04,$40,$A1,$43
L2042         fcb   $00,$A2,$A3,$FE,$50,$F6,$A1,$F1
L204A         fcb   $9F,$E1,$00
;
                ORG     $6000
;
start           ldx     #isr&$ff       ; Set up IRQ vector in SMON
                stx     IRQ_LO
                ldx     #isr>>8
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
counter         rmb     1
led_state       rmb     1
;
              END

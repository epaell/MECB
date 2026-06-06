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
;timer_LSB       equ     $E7          ; 1 mS at 1 MHz
;timer_MSB       equ     $03
timer_LSB       equ     $0C          ; 20 mS at 1 MHz (50 Hz)
timer_MSB       equ     $4E
;timer_LSB       equ     $74          ; 16.67 mS at 1 MHz (60 Hz)
;timer_MSB       equ     $40
;
                ORG     $0e00
;
              org $0F80
;
; SID header
;
L0F82         fcb   $50,$53,$49,$44,$00,$02,$00,$7C
L0F8A         fcb   $00,$00,$10,$00,$10,$03,$00,$01
L0F92         fcb   $00,$01,$00,$00,$00,$00,$52,$61
L0F9A         fcb   $73,$70,$75,$74,$69,$6E,$00,$00
L0FA2         fcb   $00,$00,$00,$00,$00,$00,$00,$00
L0FAA         fcb   $00,$00,$00,$00,$00,$00,$00,$00
L0FB2         fcb   $00,$00,$00,$00,$00,$00,$53,$61
L0FBA         fcb   $6D,$69,$20,$4C,$6F,$75,$6B,$6F
L0FC2         fcb   $20,$28,$50,$72,$6F,$74,$6F,$6E
L0FCA         fcb   $29,$00,$00,$00,$00,$00,$00,$00
L0FD2         fcb   $00,$00,$00,$00,$00,$00,$32,$30
L0FDA         fcb   $32,$32,$20,$46,$69,$6E,$6E,$69
L0FE2         fcb   $73,$68,$20,$47,$6F,$6C,$64,$2F
L0FEA         fcb   $4F,$6E,$73,$6C,$61,$75,$67,$68
L0FF2         fcb   $74,$00,$00,$00,$00,$00,$00,$24
L0FFA         fcb   $00,$00,$00,$00,$00,$10
;
              org $1000
;
sid_init      JMP L1086
sid_play      JMP L108A
;
L1006         LDA $14EB,Y
              JMP L1013
              TAY
              LDA #$00
              STA $1381,X
              TYA
L1013         STA $1358,X
              LDA $1347,X
              STA $1357,X
              RTS
              STA SID+$06,X
              RTS
              STA $110F
              BNE L1029
              STA $10C1
L1029         RTS
              BMI L1036
              STA $136E
              STA $1375
              STA $137C
              RTS
L1036         AND #$7F
              STA $136E,X
              RTS
L103C         DEC $1382,X
L103F         JMP L1244
L1042         BEQ L103F
              LDA $1382,X
              BNE L103C
              LDA #$00
              STA $EF
              LDA $1381,X
              BMI L105B
              CMP $162E,Y
              BCC L105C
              BEQ L105B
              EOR #$FF
L105B         CLC
L105C         ADC #$02
              STA $1381,X
              LSR A
              BCC L1066
              BCS L1076
L1066         LDA $1384,X
              ADC $EE
              STA $1384,X
              LDA $1385,X
              ADC $EF
              JMP L1241
L1076         LDA $1384,X
              SBC $EE
              STA $1384,X
              LDA $1385,X
              SBC $EF
              JMP L1241
L1086         STA $108D
              RTS
L108A         LDX #$00
              LDY #$00
              BMI L10C0
              TXA
              LDX #$29
L1093         STA $1342,X
              DEX
              BPL L1093
              STA SID+$15
              STA $110F
              STA $10C1
              STX $108D
              TAX
              JSR L10B0
              LDX #$07
              JSR L10B0
              LDX #$0E
L10B0         LDA #$05
              STA $136E,X
              LDA #$01
              STA $136F,X
              STA $1371,X
              JMP L1323
L10C0         LDY #$00
              BEQ L1109
              LDA #$00
              BNE L10EB
              LDA $160D,Y
              BEQ L10DF
              BPL L10E8
              ASL A
              STA $1114
              LDA $161D,Y
              STA $110F
              LDA $160E,Y
              BNE L10FD
              INY
L10DF         LDA $161D,Y
              STA $110A
              JMP L10FA
L10E8         STA $10C5
L10EB         LDA $161D,Y
              CLC
              ADC $110A
              STA $110A
              DEC $10C5
              BNE L110B
L10FA         LDA $160E,Y
L10FD         CMP #$FF
              INY
              TYA
              BCC L1106
              LDA $161D,Y
L1106         STA $10C1
L1109         LDA #$00
L110B         STA SID+$16
              LDA #$00
              STA SID+$17
              LDA #$00
              ORA #$0F
              STA SID+$18
              JSR L1124
              LDX #$07
              JSR L1124
              LDX #$0E
L1124         DEC $136F,X
              BEQ L1134
              BPL L1131
              LDA $136E,X
              STA $136F,X
L1131         JMP L11DD
L1134         LDY $1347,X
              LDA $132D,Y
              STA $11D2
              STA $11DB
              LDA $1345,X
              BNE L1169
              LDY $136C,X
              LDA $144B,Y
              STA $EE
              LDA $144E,Y
              STA $EF
              LDY $1342,X
              LDA ($EE),Y
              CMP #$FF
              BCC L1161
              INY
              LDA ($EE),Y
              TAY
              LDA ($EE),Y
L1161         STA $136D,X
              INY
              TYA
              STA $1342,X
L1169         LDY $1371,X
              LDA $150D,Y
              STA $139B,X
              LDA $1359,X
              BEQ L11D7
              SEC
              SBC #$60
              STA $1370,X
              LDA #$00
              STA $1357,X
              STA $1359,X
              LDA $14FC,Y
              STA $1382,X
              LDA $14EB,Y
              STA $1358,X
              LDA $151E,Y
              BEQ L11A2
              CMP #$FE
              BCS L119F
              STA $135B,X
              LDA #$FF
L119F         STA $1372,X
L11A2         LDA $14C9,Y
              BEQ L11AF
              STA $135C,X
              LDA #$00
              STA $135D,X
L11AF         LDA $14DA,Y
              BEQ L11BC
              STA $10C1
              LDA #$00
              STA $10C5
L11BC         LDA $14B8,Y
              STA $135A,X
              LDA $14A7,Y
              STA SID+$06,X
              LDA $1496,Y
              STA SID+$05,X
              LDA $1348,X
              JSR L1006
              JMP L1323
L11D7         LDA $1348,X
              JSR L1006
L11DD         LDY $135A,X
              BEQ L1212
              LDA $152F,Y
              CMP #$10
              BCS L11F3
              CMP $1383,X
              BEQ L11F8
              INC $1383,X
              BNE L1212
L11F3         SBC #$10
              STA $135B,X
L11F8         LDA $1530,Y
              CMP #$FF
              INY
              TYA
              BCC L1205
              CLC
              LDA $1582,Y
L1205         STA $135A,X
              LDA #$00
              STA $1383,X
              LDA $1581,Y
              BNE L122B
L1212         LDA $136F,X
              BEQ L1247
              LDY $1357,X
              LDA $133D,Y
              STA $1229
              LDY $1358,X
              LDA $1632,Y
              STA $EE
              JMP L1042
L122B         BPL L1232
              ADC $1370,X
              AND #$7F
L1232         TAY
              LDA #$00
              STA $1381,X
              LDA $139B,Y
              STA $1384,X
              LDA $13EB,Y
L1241         STA $1385,X
L1244         LDA $136F,X
L1247         CMP $139B,X
              BEQ L12A6
              LDY $135C,X
              BEQ L12A3
              ORA $1345,X
              BEQ L12A3
              LDA $135D,X
              BNE L126F
              LDA $15D5,Y
              BPL L126C
              STA $1387,X
              LDA $15F1,Y
              STA $1386,X
              JMP L1288
L126C         STA $135D,X
L126F         LDA $15F1,Y
              CLC
              BPL L1278
              DEC $1387,X
L1278         ADC $1386,X
              STA $1386,X
              BCC L1283
              INC $1387,X
L1283         DEC $135D,X
              BNE L129A
L1288         LDA $15D6,Y
              CMP #$FF
              INY
              TYA
              BCC L1294
              LDA $15F1,Y
L1294         STA $135C,X
              LDA $1386,X
L129A         STA SID+$02,X
              LDA $1387,X
              STA SID+$03,X
L12A3         JMP L1317
L12A6         LDY $136D,X
              LDA $1451,Y
              STA $EE
              LDA $1474,Y
              STA $EF
              LDY $1345,X
              LDA ($EE),Y
              CMP #$40
              BCC L12D4
              CMP #$60
              BCC L12DE
              CMP #$C0
              BCC L12F2
              LDA $1346,X
              BNE L12CB
              LDA ($EE),Y
L12CB         ADC #$00
              STA $1346,X
              BEQ L130E
              BNE L1317
L12D4         STA $1371,X
              INY
              LDA ($EE),Y
              CMP #$60
              BCS L12F2
L12DE         CMP #$50
              AND #$0F
              STA $1347,X
              BEQ L12ED
              INY
              LDA ($EE),Y
              STA $1348,X
L12ED         BCS L130E
              INY
              LDA ($EE),Y
L12F2         CMP #$BD
              BCC L12FC
              BEQ L130E
              ORA #$F0
              BNE L130B
L12FC         STA $1359,X
              LDA #$00
              STA SID+$06,X
              LDA #$0F
              STA SID+$05,X
              LDA #$FE
L130B         STA $1372,X
L130E         INY
              LDA ($EE),Y
              BEQ L1314
              TYA
L1314         STA $1345,X
L1317         LDA $1384,X
              STA SID+$00,X
              LDA $1385,X
              STA SID+$01,X
L1323         LDA $135B,X
              AND $1372,X
              STA SID+$04,X
              RTS
;
L132D         fcb   $06,$0C,$0C,$13,$13
L1332         fcb   $1D,$1D,$21,$21,$21,$21,$21,$2A
L133A         fcb   $2A,$2A,$2A,$42,$66,$66,$66,$49
L1342         fcb   $00,$00,$00,$00,$00,$00,$00,$00
L134A         fcb   $00,$00,$00,$00,$00,$00,$00,$00
L1352         fcb   $00,$00,$00,$00,$00,$00,$00,$00
L135A         fcb   $00,$00,$00,$00,$00,$00,$00,$00
L1362         fcb   $00,$00,$00,$00,$00,$00,$00,$00
L136A         fcb   $00,$00,$00,$00,$00,$00,$00,$01
L1372         fcb   $FE,$01,$00,$00,$00,$00,$01,$FE
L137A         fcb   $02,$00,$00,$00,$00,$01,$FE,$00
L1382         fcb   $00,$00,$00,$00,$00,$00,$00,$00
L138A         fcb   $00,$00,$00,$00,$00,$00,$00,$00
L1392         fcb   $00,$00,$00,$00,$00,$00,$00,$00
L139A         fcb   $00,$00,$00,$00,$00,$00,$00,$00
L13A2         fcb   $00,$00,$00,$00,$00,$00,$00,$00
L13AA         fcb   $00,$BE,$E8,$14,$43,$74,$A9,$E1
L13B2         fcb   $1C,$5A,$9C,$E2,$2D,$7C,$CF,$28
L13BA         fcb   $85,$E8,$52,$C1,$37,$B4,$39,$C5
L13C2         fcb   $5A,$F7,$9E,$4F,$0A,$D1,$A3,$82
L13CA         fcb   $6E,$68,$71,$8A,$B3,$EE,$3C,$9E
L13D2         fcb   $15,$A2,$46,$04,$DC,$D0,$E2,$14
L13DA         fcb   $67,$DD,$79,$3C,$29,$44,$8D,$08
L13E2         fcb   $B8,$A1,$C5,$28,$CD,$BA,$F1,$78
L13EA         fcb   $53,$87,$1A,$10,$71,$42,$89,$4F
L13F2         fcb   $9B,$74,$E2,$F0,$A6,$0E,$33,$20
L13FA         fcb   $FF,$02,$02,$03,$03,$03,$03,$03
L1402         fcb   $04,$04,$04,$04,$05,$05,$05,$06
L140A         fcb   $06,$06,$07,$07,$08,$08,$09,$09
L1412         fcb   $0A,$0A,$0B,$0C,$0D,$0D,$0E,$0F
L141A         fcb   $10,$11,$12,$13,$14,$15,$17,$18
L1422         fcb   $1A,$1B,$1D,$1F,$20,$22,$24,$27
L142A         fcb   $29,$2B,$2E,$31,$34,$37,$3A,$3E
L1432         fcb   $41,$45,$49,$4E,$52,$57,$5C,$62
L143A         fcb   $68,$6E,$75,$7C,$83,$8B,$93,$9C
L1442         fcb   $A5,$AF,$B9,$C4,$D0,$DD,$EA,$F8
L144A         fcb   $FF,$36,$65,$94,$16,$16,$16,$C3
L1452         fcb   $C7,$DA,$1D,$40,$63,$86,$A9,$EC
L145A         fcb   $2F,$72,$F3,$FA,$0D,$6F,$A1,$D3
L1462         fcb   $05,$37,$5A,$7D,$DF,$A1,$A6,$AB
L146A         fcb   $CC,$F9,$1B,$3A,$59,$88,$C3,$F7
L1472         fcb   $41,$7F,$16,$16,$16,$17,$17,$17
L147A         fcb   $17,$17,$17,$18,$18,$18,$18,$19
L1482         fcb   $19,$19,$19,$1A,$1A,$1A,$1A,$1A
L148A         fcb   $1B,$1B,$1B,$1B,$1B,$1C,$1C,$1C
L1492         fcb   $1C,$1C,$1C,$1D,$1D,$00,$00,$00
L149A         fcb   $00,$00,$00,$00,$00,$00,$00,$00
L14A2         fcb   $00,$00,$00,$00,$00,$00,$A9,$A9
L14AA         fcb   $C8,$F8,$A9,$A9,$99,$B9,$B9,$BB
L14B2         fcb   $B9,$F8,$FC,$B9,$BB,$B9,$B9,$01
L14BA         fcb   $03,$05,$35,$01,$01,$14,$1B,$20
L14C2         fcb   $27,$2E,$0E,$0E,$40,$45,$4A,$4F
L14CA         fcb   $01,$06,$0B,$1B,$12,$12,$16,$16
L14D2         fcb   $16,$16,$16,$10,$10,$16,$16,$16
L14DA         fcb   $16,$08,$00,$01,$00,$0C,$0C,$00
L14E2         fcb   $00,$00,$00,$00,$00,$00,$00,$00
L14EA         fcb   $00,$00,$03,$01,$02,$00,$03,$03
L14F2         fcb   $00,$00,$00,$00,$00,$00,$00,$00
L14FA         fcb   $00,$00,$00,$1F,$0F,$00,$00,$00
L1502         fcb   $00,$00,$00,$00,$00,$00,$00,$00
L150A         fcb   $00,$00,$00,$00,$02,$02,$02,$02
L1512         fcb   $01,$02,$02,$02,$02,$02,$02,$02
L151A         fcb   $02,$02,$02,$02,$02,$09,$09,$09
L1522         fcb   $09,$FF,$09,$09,$09,$09,$09,$09
L152A         fcb   $09,$09,$09,$09,$09,$09,$51,$FF
L1532         fcb   $51,$FF,$91,$51,$00,$00,$00,$00
L153A         fcb   $00,$00,$FF,$91,$51,$51,$51,$90
L1542         fcb   $FF,$51,$51,$51,$51,$51,$51,$FF
L154A         fcb   $51,$00,$00,$00,$FF,$51,$51,$51
L1552         fcb   $51,$51,$51,$FF,$51,$51,$51,$51
L155A         fcb   $51,$51,$FF,$51,$51,$51,$51,$51
L1562         fcb   $51,$FF,$91,$51,$21,$01,$01,$01
L156A         fcb   $01,$01,$01,$20,$FF,$51,$51,$51
L1572         fcb   $51,$FF,$51,$51,$51,$51,$FF,$51
L157A         fcb   $51,$51,$51,$FF,$51,$51,$51,$51
L1582         fcb   $FF,$80,$00,$80,$00,$5F,$8C,$8A
L158A         fcb   $86,$84,$82,$81,$80,$00,$5F,$30
L1592         fcb   $2E,$2C,$5F,$00,$80,$80,$83,$83
L159A         fcb   $87,$87,$14,$80,$80,$83,$83,$1B
L15A2         fcb   $80,$80,$87,$87,$84,$84,$20,$80
L15AA         fcb   $80,$85,$85,$89,$89,$27,$80,$80
L15B2         fcb   $83,$83,$88,$88,$2E,$5F,$20,$1C
L15BA         fcb   $18,$16,$14,$13,$12,$11,$10,$00
L15C2         fcb   $80,$80,$84,$84,$40,$80,$80,$8C
L15CA         fcb   $8C,$45,$80,$80,$89,$89,$4A,$80
L15D2         fcb   $80,$88,$88,$4F,$83,$30,$20,$20
L15DA         fcb   $FF,$87,$18,$18,$08,$FF,$88,$05
L15E2         fcb   $20,$20,$FF,$88,$FF,$8C,$10,$10
L15EA         fcb   $FF,$86,$03,$10,$10,$FF,$86,$FF
L15F2         fcb   $00,$40,$18,$E8,$03,$00,$F0,$20
L15FA         fcb   $E0,$07,$00,$20,$FC,$04,$0D,$00
L1602         fcb   $00,$00,$10,$E0,$13,$00,$70,$02
L160A         fcb   $FE,$18,$00,$00,$98,$00,$00,$00
L1612         fcb   $00,$0C,$FF,$98,$00,$0C,$FF,$98
L161A         fcb   $00,$08,$0A,$FF,$C1,$E0,$70,$40
L1622         fcb   $14,$FF,$00,$F4,$60,$FC,$00,$F4
L162A         fcb   $40,$FE,$02,$0E,$00,$03,$02,$02
L1632         fcb   $00,$08,$04,$30,$00,$01,$01,$02
L163A         fcb   $02,$03,$04,$03,$04,$05,$05,$06
L1642         fcb   $06,$06,$06,$02,$02,$07,$08,$09
L164A         fcb   $09,$06,$06,$06,$06,$02,$02,$07
L1652         fcb   $08,$09,$09,$0A,$06,$06,$06,$06
L165A         fcb   $02,$02,$07,$08,$09,$09,$09,$09
L1662         fcb   $0B,$FF,$00,$00,$0C,$0C,$0D,$0D
L166A         fcb   $0E,$0F,$0E,$0F,$10,$10,$11,$11
L1672         fcb   $11,$11,$0D,$0D,$12,$13,$14,$14
L167A         fcb   $11,$11,$11,$11,$0D,$0D,$12,$13
L1682         fcb   $14,$14,$15,$11,$11,$11,$11,$0D
L168A         fcb   $0D,$12,$13,$14,$14,$14,$14,$16
L1692         fcb   $FF,$00,$17,$18,$18,$19,$19,$1A
L169A         fcb   $1A,$1A,$1A,$1B,$1B,$1C,$1D,$1C
L16A2         fcb   $1D,$19,$19,$1E,$1F,$20,$20,$1C
L16AA         fcb   $1D,$1C,$1D,$19,$19,$1E,$1F,$20
L16B2         fcb   $20,$21,$1C,$1D,$1C,$1D,$19,$19
L16BA         fcb   $1E,$1F,$20,$20,$20,$20,$22,$FF
L16C2         fcb   $00,$5F,$05,$50,$00,$02,$40,$83
L16CA         fcb   $BD,$83,$BD,$83,$BD,$BE,$F7,$83
L16D2         fcb   $BD,$83,$BD,$83,$BD,$BE,$F7,$00
L16DA         fcb   $02,$40,$77,$BD,$83,$BD,$77,$BD
L16E2         fcb   $83,$BD,$77,$BD,$83,$BD,$77,$BD
L16EA         fcb   $83,$BD,$77,$BD,$83,$BD,$77,$BD
L16F2         fcb   $83,$BD,$77,$BD,$83,$BD,$79,$BD
L16FA         fcb   $7A,$BD,$70,$BD,$7C,$BD,$70,$BD
L1702         fcb   $7C,$BD,$70,$BD,$7C,$BD,$70,$BD
L170A         fcb   $7C,$BD,$72,$BD,$7E,$BD,$72,$BD
L1712         fcb   $7E,$BD,$7E,$BD,$7C,$BD,$7A,$BD
L171A         fcb   $79,$BD,$00,$02,$40,$83,$77,$BE
L1722         fcb   $77,$83,$77,$BE,$77,$83,$77,$BE
L172A         fcb   $77,$83,$77,$BE,$77,$83,$77,$BE
L1732         fcb   $77,$83,$77,$BE,$77,$83,$77,$BE
L173A         fcb   $77,$83,$77,$BE,$77,$00,$02,$40
L1742         fcb   $7C,$70,$BE,$70,$7C,$70,$BE,$70
L174A         fcb   $7E,$72,$BE,$72,$7E,$72,$BE,$72
L1752         fcb   $83,$77,$BE,$83,$77,$BD,$83,$BD
L175A         fcb   $77,$BD,$75,$BD,$73,$BD,$72,$BD
L1762         fcb   $00,$02,$40,$83,$BE,$83,$BE,$83
L176A         fcb   $BE,$81,$BE,$81,$BE,$81,$BE,$81
L1772         fcb   $BE,$81,$BE,$81,$BE,$7F,$BE,$7F
L177A         fcb   $BE,$7F,$BE,$7E,$BE,$7E,$BE,$7E
L1782         fcb   $BE,$7E,$BE,$00,$02,$40,$77,$BD
L178A         fcb   $83,$BD,$77,$BD,$83,$BD,$77,$BD
L1792         fcb   $83,$BD,$77,$BD,$83,$BD,$77,$BD
L179A         fcb   $83,$BD,$77,$BD,$7E,$BD,$72,$BD
L17A2         fcb   $7E,$BD,$75,$BD,$81,$BD,$00,$02
L17AA         fcb   $40,$77,$BD,$83,$BD,$77,$BD,$83
L17B2         fcb   $BD,$77,$BD,$83,$BD,$77,$BD,$83
L17BA         fcb   $BD,$77,$BD,$83,$BD,$77,$BD,$83
L17C2         fcb   $BD,$77,$BD,$83,$BD,$77,$BD,$83
L17CA         fcb   $BD,$70,$BD,$7C,$BD,$70,$BD,$7C
L17D2         fcb   $BD,$70,$BD,$7C,$BD,$70,$BD,$7C
L17DA         fcb   $BD,$72,$BD,$7E,$BD,$74,$BD,$80
L17E2         fcb   $BD,$76,$BD,$82,$BD,$72,$BD,$7E
L17EA         fcb   $BD,$00,$02,$40,$77,$BD,$83,$BD
L17F2         fcb   $77,$BD,$83,$BD,$77,$BD,$83,$BD
L17FA         fcb   $77,$BD,$83,$BD,$77,$BD,$83,$BD
L1802         fcb   $77,$BD,$83,$BD,$77,$BD,$83,$BD
L180A         fcb   $77,$BD,$83,$BD,$70,$BD,$7C,$BD
L1812         fcb   $70,$BD,$7C,$BD,$72,$BD,$7E,$BD
L181A         fcb   $72,$BD,$7E,$BD,$77,$BE,$77,$BE
L1822         fcb   $7A,$BE,$7A,$BE,$7C,$BE,$7C,$BE
L182A         fcb   $72,$BD,$7E,$BD,$00,$02,$40,$77
L1832         fcb   $77,$83,$BD,$7E,$BD,$83,$BD,$7A
L183A         fcb   $7A,$86,$BD,$83,$BD,$86,$BD,$7C
L1842         fcb   $7C,$88,$BD,$83,$BD,$88,$BD,$77
L184A         fcb   $77,$83,$BD,$7E,$BD,$83,$BD,$75
L1852         fcb   $75,$81,$BD,$7C,$BD,$81,$BD,$70
L185A         fcb   $70,$7C,$BD,$77,$BD,$7C,$BD,$77
L1862         fcb   $77,$83,$BD,$7E,$BD,$83,$BD,$77
L186A         fcb   $77,$83,$BD,$7E,$BD,$83,$BD,$00
L1872         fcb   $02,$40,$77,$BD,$7E,$BD,$83,$BD
L187A         fcb   $77,$BD,$77,$BD,$7E,$BD,$83,$BD
L1882         fcb   $77,$BD,$75,$BD,$7C,$BD,$81,$BD
L188A         fcb   $75,$BD,$75,$BD,$7C,$BD,$81,$BD
L1892         fcb   $75,$BD,$73,$BD,$7A,$BD,$7F,$BD
L189A         fcb   $73,$BD,$75,$BD,$7C,$BD,$81,$BD
L18A2         fcb   $75,$BD,$77,$BD,$7E,$BD,$83,$BD
L18AA         fcb   $77,$BD,$77,$BD,$7E,$BD,$83,$BD
L18B2         fcb   $77,$BD,$77,$BD,$7E,$BD,$83,$BD
L18BA         fcb   $77,$BD,$77,$BD,$7E,$BD,$83,$BD
L18C2         fcb   $77,$BD,$75,$BD,$7C,$BD,$81,$BD
L18CA         fcb   $75,$BD,$75,$BD,$7C,$BD,$81,$BD
L18D2         fcb   $75,$BD,$73,$BD,$7A,$BD,$7F,$BD
L18DA         fcb   $73,$BD,$75,$BD,$7C,$BD,$81,$BD
L18E2         fcb   $75,$BD,$77,$BD,$7E,$BD,$77,$BD
L18EA         fcb   $83,$BD,$77,$FD,$77,$BD,$83,$BD
L18F2         fcb   $00,$03,$40,$77,$FE,$BE,$E4,$00
L18FA         fcb   $04,$40,$84,$FD,$84,$FD,$84,$FD
L1902         fcb   $84,$FD,$84,$FD,$84,$FD,$84,$FD
L190A         fcb   $84,$FD,$00,$04,$40,$78,$BD,$02
L1912         fcb   $8F,$9B,$0C,$93,$02,$8F,$83,$9B
L191A         fcb   $04,$78,$BD,$02,$8F,$9B,$0C,$93
L1922         fcb   $02,$8F,$83,$9B,$04,$78,$BD,$02
L192A         fcb   $8F,$9B,$0C,$93,$02,$8F,$83,$9B
L1932         fcb   $04,$78,$BD,$02,$8F,$9B,$0C,$93
L193A         fcb   $02,$8F,$83,$9B,$04,$7D,$BD,$02
L1942         fcb   $94,$A0,$0C,$98,$02,$94,$88,$A0
L194A         fcb   $04,$7D,$BD,$02,$94,$A0,$0C,$98
L1952         fcb   $02,$94,$88,$A0,$04,$7F,$BD,$02
L195A         fcb   $96,$A2,$0C,$9A,$02,$96,$8A,$A2
L1962         fcb   $04,$7F,$BD,$02,$94,$A0,$0C,$96
L196A         fcb   $02,$92,$85,$9D,$00,$04,$40,$78
L1972         fcb   $BD,$02,$83,$83,$04,$78,$BD,$02
L197A         fcb   $83,$83,$04,$78,$BD,$02,$83,$83
L1982         fcb   $04,$78,$BD,$02,$83,$83,$04,$78
L198A         fcb   $BD,$02,$83,$83,$04,$78,$BD,$02
L1992         fcb   $83,$83,$04,$78,$BD,$02,$83,$83
L199A         fcb   $04,$78,$BD,$02,$83,$83,$00,$04
L19A2         fcb   $40,$78,$BD,$02,$88,$7C,$04,$78
L19AA         fcb   $BD,$02,$88,$7C,$04,$78,$BD,$02
L19B2         fcb   $8A,$7E,$04,$78,$BD,$02,$8A,$7E
L19BA         fcb   $04,$78,$BD,$02,$8F,$83,$04,$78
L19C2         fcb   $BD,$02,$8F,$83,$04,$78,$BD,$02
L19CA         fcb   $8D,$81,$04,$78,$BD,$02,$8A,$7E
L19D2         fcb   $00,$04,$40,$84,$BD,$02,$77,$BD
L19DA         fcb   $04,$84,$BD,$02,$75,$BD,$04,$84
L19E2         fcb   $BD,$02,$75,$BD,$04,$84,$BD,$02
L19EA         fcb   $75,$BD,$04,$84,$BD,$02,$73,$BD
L19F2         fcb   $04,$84,$BD,$02,$73,$BD,$04,$84
L19FA         fcb   $BD,$02,$72,$BD,$04,$84,$BD,$02
L1A02         fcb   $72,$BD,$00,$04,$40,$90,$BD,$02
L1A0A         fcb   $8F,$9B,$04,$90,$02,$8F,$9B,$8F
L1A12         fcb   $04,$90,$BD,$02,$8F,$9B,$04,$90
L1A1A         fcb   $02,$8F,$9B,$8F,$04,$90,$BD,$02
L1A22         fcb   $8F,$9B,$04,$90,$02,$8F,$96,$8A
L1A2A         fcb   $04,$90,$BD,$02,$8A,$96,$04,$90
L1A32         fcb   $02,$8D,$99,$8D,$00,$04,$40,$90
L1A3A         fcb   $FD,$90,$FD,$90,$FD,$90,$FD,$90
L1A42         fcb   $FD,$90,$FD,$90,$FD,$90,$FD,$90
L1A4A         fcb   $FD,$90,$FD,$90,$FD,$90,$FD,$90
L1A52         fcb   $FD,$90,$FD,$90,$FD,$90,$FD,$00
L1A5A         fcb   $04,$40,$90,$FD,$90,$FD,$90,$FD
L1A62         fcb   $90,$FD,$90,$FD,$90,$FD,$90,$FD
L1A6A         fcb   $90,$FD,$90,$FD,$90,$FD,$90,$FD
L1A72         fcb   $90,$FD,$90,$FD,$90,$FD,$90,$FD
L1A7A         fcb   $90,$FD,$00,$04,$40,$78,$BD,$02
L1A82         fcb   $8F,$9B,$0C,$7B,$BD,$02,$9B,$8F
L1A8A         fcb   $04,$78,$BD,$02,$86,$92,$0C,$7B
L1A92         fcb   $BD,$02,$92,$86,$04,$78,$BD,$02
L1A9A         fcb   $88,$94,$0C,$7B,$BD,$02,$94,$88
L1AA2         fcb   $04,$78,$BD,$02,$8F,$9B,$0C,$7B
L1AAA         fcb   $BD,$02,$9B,$8F,$04,$78,$BD,$02
L1AB2         fcb   $8D,$99,$0C,$7B,$BD,$02,$99,$8D
L1ABA         fcb   $04,$78,$BD,$02,$88,$94,$0C,$93
L1AC2         fcb   $BD,$02,$94,$88,$04,$78,$BD,$02
L1ACA         fcb   $8F,$9B,$0C,$7B,$BD,$02,$9B,$8F
L1AD2         fcb   $04,$78,$BD,$02,$8F,$9B,$0C,$7B
L1ADA         fcb   $BD,$02,$9B,$8F,$00,$04,$40,$78
L1AE2         fcb   $BD,$02,$8F,$9B,$04,$78,$BD,$02
L1AEA         fcb   $9B,$8F,$04,$78,$BD,$02,$8F,$9B
L1AF2         fcb   $04,$78,$BD,$02,$9B,$8F,$04,$78
L1AFA         fcb   $BD,$02,$8D,$99,$04,$90,$BD,$02
L1B02         fcb   $99,$8D,$04,$78,$BD,$02,$8D,$99
L1B0A         fcb   $04,$78,$BD,$02,$99,$8D,$04,$78
L1B12         fcb   $BD,$02,$8B,$97,$04,$78,$BD,$02
L1B1A         fcb   $97,$8B,$04,$78,$BD,$02,$8D,$99
L1B22         fcb   $04,$78,$BD,$02,$99,$8D,$04,$78
L1B2A         fcb   $BD,$02,$8F,$9B,$04,$78,$BD,$02
L1B32         fcb   $9B,$8F,$04,$78,$BD,$02,$8F,$9B
L1B3A         fcb   $04,$78,$BD,$02,$9B,$8F,$04,$78
L1B42         fcb   $BD,$02,$8F,$9B,$04,$78,$BD,$02
L1B4A         fcb   $9B,$8F,$04,$78,$BD,$02,$8F,$9B
L1B52         fcb   $04,$78,$BD,$02,$9B,$8F,$04,$78
L1B5A         fcb   $BD,$02,$8D,$99,$04,$90,$BD,$02
L1B62         fcb   $99,$8D,$04,$78,$BD,$02,$8D,$99
L1B6A         fcb   $04,$78,$BD,$02,$99,$8D,$04,$78
L1B72         fcb   $BD,$02,$8B,$97,$04,$78,$BD,$02
L1B7A         fcb   $97,$8B,$04,$78,$BD,$02,$8D,$99
L1B82         fcb   $04,$78,$BD,$02,$99,$8D,$04,$78
L1B8A         fcb   $BD,$02,$8F,$9B,$04,$78,$BD,$02
L1B92         fcb   $9B,$8F,$04,$78,$BD,$02,$8F,$9B
L1B9A         fcb   $04,$78,$BD,$02,$9B,$8F,$00,$0D
L1BA2         fcb   $40,$93,$E1,$00,$06,$40,$8A,$8D
L1BAA         fcb   $00,$06,$40,$8F,$BE,$FE,$8F,$BE
L1BB2         fcb   $BD,$8F,$8F,$91,$8F,$8D,$8F,$BE
L1BBA         fcb   $8A,$8D,$8F,$8F,$8F,$BE,$8F,$BE
L1BC2         fcb   $BD,$8F,$8F,$91,$8F,$8D,$8F,$BE
L1BCA         fcb   $FE,$00,$06,$4F,$85,$8F,$50,$FE
L1BD2         fcb   $96,$FD,$96,$FB,$96,$96,$97,$BD
L1BDA         fcb   $99,$BD,$97,$BD,$96,$BD,$96,$FD
L1BE2         fcb   $91,$BD,$92,$BD,$94,$FD,$94,$FD
L1BEA         fcb   $94,$FB,$92,$BD,$94,$BD,$94,$BD
L1BF2         fcb   $92,$BD,$91,$BD,$8F,$F9,$00,$06
L1BFA         fcb   $40,$8F,$BE,$FE,$8F,$BE,$BD,$8F
L1C02         fcb   $8F,$91,$8F,$8D,$8F,$BE,$8A,$8D
L1C0A         fcb   $8F,$8F,$8F,$BE,$8F,$BE,$BD,$8F
L1C12         fcb   $8F,$91,$8F,$8D,$8F,$BE,$8A,$8D
L1C1A         fcb   $00,$46,$00,$BE,$5B,$00,$07,$40
L1C22         fcb   $9B,$BE,$FE,$9B,$BE,$FE,$9B,$BE
L1C2A         fcb   $FE,$9B,$BE,$FE,$9B,$BE,$FE,$9B
L1C32         fcb   $BE,$FE,$9B,$BE,$FE,$9B,$BE,$00
L1C3A         fcb   $06,$4F,$85,$9B,$50,$FE,$9B,$FE
L1C42         fcb   $9B,$9B,$9D,$9E,$A0,$A2,$BD,$A7
L1C4A         fcb   $A5,$A7,$BE,$A5,$BE,$A7,$BE,$A2
L1C52         fcb   $FE,$BE,$A0,$BE,$A2,$FD,$00,$06
L1C5A         fcb   $4F,$82,$9B,$50,$FA,$9B,$FB,$9B
L1C62         fcb   $BD,$9B,$BD,$9D,$BD,$9E,$BD,$A0
L1C6A         fcb   $BD,$A2,$FD,$A2,$05,$A3,$A5,$A7
L1C72         fcb   $BE,$FD,$06,$9E,$BD,$BE,$BD,$A0
L1C7A         fcb   $BD,$BE,$BD,$A2,$F7,$BE,$BD,$A0
L1C82         fcb   $BD,$BE,$BD,$A2,$FD,$00,$06,$40
L1C8A         fcb   $8F,$FD,$BE,$BD,$91,$BE,$92,$FD
L1C92         fcb   $94,$FE,$BE,$96,$BD,$97,$BD,$96
L1C9A         fcb   $BD,$94,$BD,$92,$FD,$8F,$FD,$08
L1CA2         fcb   $91,$BE,$91,$BE,$91,$BD,$BE,$BD
L1CAA         fcb   $91,$BE,$0E,$92,$BE,$08,$8F,$BE
L1CB2         fcb   $8F,$BE,$10,$91,$FB,$BE,$BD,$06
L1CBA         fcb   $8E,$8F,$91,$8E,$91,$94,$96,$9A
L1CC2         fcb   $00,$06,$40,$9B,$FD,$BE,$BD,$91
L1CCA         fcb   $BE,$92,$FD,$94,$FE,$BE,$96,$BD
L1CD2         fcb   $97,$BD,$96,$BD,$94,$BD,$92,$FD
L1CDA         fcb   $8F,$FD,$91,$FD,$94,$BE,$FE,$92
L1CE2         fcb   $BD,$91,$FE,$91,$FE,$8F,$9B,$99
L1CEA         fcb   $96,$99,$9B,$99,$96,$99,$9B,$BE
L1CF2         fcb   $BD,$0F,$9B,$FD,$00,$09,$4B,$00
L1CFA         fcb   $9B,$40,$BE,$FE,$9B,$BE,$FE,$0A
L1D02         fcb   $99,$BE,$99,$BE,$99,$BE,$FE,$0B
L1D0A         fcb   $98,$BE,$98,$BE,$98,$BE,$98,$BE
L1D12         fcb   $10,$96,$BD,$94,$BD,$11,$93,$BD
L1D1A         fcb   $BE,$FD,$09,$99,$BE,$99,$BE,$99
L1D22         fcb   $BE,$0B,$98,$BD,$BE,$BD,$98,$BD
L1D2A         fcb   $BE,$BD,$0A,$96,$BE,$96,$BE,$0F
L1D32         fcb   $94,$BE,$0A,$96,$BD,$06,$9B,$99
L1D3A         fcb   $96,$99,$9B,$A0,$A2,$A5,$00,$01
L1D42         fcb   $4F,$05,$8F,$50,$FA,$92,$FD,$96
L1D4A         fcb   $FD,$96,$FD,$94,$F9,$92,$BD,$94
L1D52         fcb   $BD,$96,$FD,$92,$FD,$94,$FD,$91
L1D5A         fcb   $FD,$8F,$F9,$96,$FE,$94,$FE,$92
L1D62         fcb   $BD,$8F,$F9,$8D,$FD,$8F,$FD,$91
L1D6A         fcb   $F5,$92,$BD,$91,$BD,$8F,$FB,$8A
L1D72         fcb   $FB,$8D,$FD,$8F,$FC,$BE,$FC,$9B
L1D7A         fcb   $99,$9B,$BE,$FE,$00,$0F,$4F,$0B
L1D82         fcb   $9B,$40,$BE,$E2,$00
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

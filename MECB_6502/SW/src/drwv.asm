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
              org $0f82
;
; SID header
;
L0F82         dc.b  $50,$53,$49,$44,$00,$02,$00,$7C
L0F8A         dc.b  $00,$00,$10,$00,$10,$03,$00,$01
L0F92         dc.b  $00,$01,$00,$00,$00,$00,$44,$6F
L0F9A         dc.b  $63,$74,$6F,$72,$20,$57,$68,$6F
L0FA2         dc.b  $20,$2D,$20,$54,$68,$65,$20,$56
L0FAA         dc.b  $69,$73,$69,$64,$61,$74,$69,$6F
L0FB2         dc.b  $6E,$00,$00,$00,$00,$00,$41,$6C
L0FBA         dc.b  $65,$78,$69,$73,$20,$47,$6C,$61
L0FC2         dc.b  $73,$73,$20,$28,$6D,$75,$74,$61
L0FCA         dc.b  $67,$65,$6E,$65,$29,$00,$00,$00
L0FD2         dc.b  $00,$00,$00,$00,$00,$00,$32,$30
L0FDA         dc.b  $31,$30,$20,$6D,$75,$74,$61,$67
L0FE2         dc.b  $65,$6E,$65,$00,$00,$00,$00,$00
L0FEA         dc.b  $00,$00,$00,$00,$00,$00,$00,$00
L0FF2         dc.b  $00,$00,$00,$00,$00,$00,$00,$14
L0FFA         dc.b  $00,$00,$00,$00,$00,$10
;
              org $1000
;
sid_init      JMP L10B5
sid_play      JMP L10B9
L1006         LDA $1552,Y
              JMP L1013
              TAY
              LDA #$00
              STA $13C7,X
              TYA
L1013         STA $139E,X
              LDA $138D,X
              STA $139D,X
              RTS
              STA SID+$06,X
              RTS
              TAY
              LDA $168B,Y
              STA $1386
              LDA $1696,Y
              STA $1387
              LDA #$00
              STA $13B4
              STA $13BB
              STA $13C2
              RTS
L103A         DEC $13C8,X
L103D         JMP L1281
L1040         BEQ L103D
              LDA $13C8,X
              BNE L103A
              LDA #$00
              STA $FD
              LDA $13C7,X
              BMI L1059
              CMP $168B,Y
              BCC L105A
              BEQ L1059
              EOR #$FF
L1059         CLC
L105A         ADC #$02
              STA $13C7,X
              LSR A
              BCC L1088
              BCS L109F
              TYA
              BEQ L10AF
              LDA $168B,Y
              STA $FD
              SEC
              LDY $13B6,X
              LDA $13CA,X
              SBC $13EF,Y
              PHA
              LDA $13CB,X
              SBC $144D,Y
              TAY
              PLA
              BCS L1098
              ADC $FC
              TYA
              ADC $FD
              BPL L10AF
L1088         LDA $13CA,X
              ADC $FC
              STA $13CA,X
              LDA $13CB,X
              ADC $FD
              JMP L127E
L1098         SBC $FC
              TYA
              SBC $FD
              BMI L10AF
L109F         LDA $13CA,X
              SBC $FC
              STA $13CA,X
              LDA $13CB,X
              SBC $FD
              JMP L127E
L10AF         LDY $13B6,X
              JMP L1270
L10B5         STA $10BC
              RTS
L10B9         LDX #$00
              LDY #$00
              BMI L10EF
              TXA
              LDX #$29
L10C2         STA $1388,X
              DEX
              BPL L10C2
              STA SID+$15
              STA $113E
              STA $10F0
              STX $10BC
              TAX
              JSR L10DF
              LDX #$07
              JSR L10DF
              LDX #$0E
L10DF         LDA #$05
              STA $13B4,X
              LDA #$01
              STA $13B5,X
              STA $13B7,X
              JMP L1367
L10EF         LDY #$00
              BEQ L1138
              LDA #$00
              BNE L111A
              LDA $1660,Y
              BEQ L110E
              BPL L1117
              ASL A
              STA $1143
              LDA $1675,Y
              STA $113E
              LDA $1661,Y
              BNE L112C
              INY
L110E         LDA $1675,Y
              STA $1139
              JMP L1129
L1117         STA $10F4
L111A         LDA $1675,Y
              CLC
              ADC $1139
              STA $1139
              DEC $10F4
              BNE L113A
L1129         LDA $1661,Y
L112C         CMP #$FF
              INY
              TYA
              BCC L1135
              LDA $1675,Y
L1135         STA $10F0
L1138         LDA #$00
L113A         STA SID+$16
              LDA #$00
              STA SID+$17
              LDA #$00
              ORA #$0F
              STA SID+$18
              JSR L1153
              LDX #$07
              JSR L1153
              LDX #$0E
L1153         DEC $13B5,X
              BEQ L1172
              BPL L116F
              LDA $13B4,X
              CMP #$02
              BCS L116C
              TAY
              EOR #$01
              STA $13B4,X
              LDA $1386,Y
              SBC #$00
L116C         STA $13B5,X
L116F         JMP L121A
L1172         LDY $138D,X
              LDA $1371,Y
              STA $120F
              STA $1218
              LDA $138B,X
              BNE L11A7
              LDY $13B2,X
              LDA $14AD,Y
              STA $FC
              LDA $14B0,Y
              STA $FD
              LDY $1388,X
              LDA ($FC),Y
              CMP #$FF
              BCC L119F
              INY
              LDA ($FC),Y
              TAY
              LDA ($FC),Y
L119F         STA $13B3,X
              INY
              TYA
              STA $1388,X
L11A7         LDY $13B7,X
              LDA $156E,Y
              STA $13E1,X
              LDA $139F,X
              BEQ L1214
              SEC
              SBC #$60
              STA $13B6,X
              LDA #$00
              STA $139D,X
              STA $139F,X
              LDA $1560,Y
              STA $13C8,X
              LDA $1552,Y
              STA $139E,X
              LDA $138D,X
              CMP #$03
              BEQ L1214
              LDA $157C,Y
              STA $13A1,X
              INC $13B8,X
              LDA $1536,Y
              BEQ L11EC
              STA $13A2,X
              LDA #$00
              STA $13A3,X
L11EC         LDA $1544,Y
              BEQ L11F9
              STA $10F0
              LDA #$00
              STA $10F4
L11F9         LDA $1528,Y
              STA $13A0,X
              LDA $151A,Y
              STA SID+$06,X
              LDA $150C,Y
              STA SID+$05,X
              LDA $138E,X
              JSR L1006
              JMP L1367
L1214         LDA $138E,X
              JSR L1006
L121A         LDY $13A0,X
              BEQ L124F
              LDA $158A,Y
              CMP #$10
              BCS L1230
              CMP $13C9,X
              BEQ L1235
              INC $13C9,X
              BNE L124F
L1230         SBC #$10
              STA $13A1,X
L1235         LDA $158B,Y
              CMP #$FF
              INY
              TYA
              BCC L1242
              CLC
              LDA $15C6,Y
L1242         STA $13A0,X
              LDA #$00
              STA $13C9,X
              LDA $15C5,Y
              BNE L1268
L124F         LDA $13B5,X
              BEQ L1284
              LDY $139D,X
              LDA $1381,Y
              STA $1266
              LDY $139E,X
              LDA $1696,Y
              STA $FC
              JMP L1040
L1268         BPL L126F
              ADC $13B6,X
              AND #$7F
L126F         TAY
L1270         LDA #$00
              STA $13C7,X
              LDA $13EF,Y
              STA $13CA,X
              LDA $144D,Y
L127E         STA $13CB,X
L1281         LDA $13B5,X
L1284         CMP $13E1,X
              BEQ L12E3
              LDY $13A2,X
              BEQ L12E0
              ORA $138B,X
              BEQ L12E0
              LDA $13A3,X
              BNE L12AC
              LDA $1602,Y
              BPL L12A9
              STA $13CD,X
              LDA $1631,Y
              STA $13CC,X
              JMP L12C5
L12A9         STA $13A3,X
L12AC         LDA $1631,Y
              CLC
              BPL L12B5
              DEC $13CD,X
L12B5         ADC $13CC,X
              STA $13CC,X
              BCC L12C0
              INC $13CD,X
L12C0         DEC $13A3,X
              BNE L12D7
L12C5         LDA $1603,Y
              CMP #$FF
              INY
              TYA
              BCC L12D1
              LDA $1631,Y
L12D1         STA $13A2,X
              LDA $13CC,X
L12D7         STA SID+$02,X
              LDA $13CD,X
              STA SID+$03,X
L12E0         JMP L135B
L12E3         LDY $13B3,X
              LDA $14B3,Y
              STA $FC
              LDA $14E0,Y
              STA $FD
              LDY $138B,X
              LDA ($FC),Y
              CMP #$40
              BCC L1311
              CMP #$60
              BCC L131B
              CMP #$C0
              BCC L132F
              LDA $138C,X
              BNE L1308
              LDA ($FC),Y
L1308         ADC #$00
              STA $138C,X
              BEQ L1352
              BNE L135B
L1311         STA $13B7,X
              INY
              LDA ($FC),Y
              CMP #$60
              BCS L132F
L131B         CMP #$50
              AND #$0F
              STA $138D,X
              BEQ L132A
              INY
              LDA ($FC),Y
              STA $138E,X
L132A         BCS L1352
              INY
              LDA ($FC),Y
L132F         CMP #$BD
              BCC L1339
              BEQ L1352
              ORA #$F0
              BNE L134F
L1339         STA $139F,X
              LDA $138D,X
              CMP #$03
              BEQ L1352
              LDA #$00
              STA SID+$06,X
              LDA #$0F
              STA SID+$05,X
              LDA #$FE
L134F         STA $13B8,X
L1352         INY
              LDA ($FC),Y
              BEQ L1358
              TYA
L1358         STA $138B,X
L135B         LDA $13CA,X
              STA SID+$00,X
              LDA $13CB,X
              STA SID+$01,X
L1367         LDA $13A1,X
              AND $13B8,X
              STA SID+$04,X
              RTS
;
L1371         dc.b  $06
L1372         dc.b  $0C,$0C,$13,$13,$1D,$1D,$21,$21
L137A         dc.b  $21,$21,$21,$21,$21,$21,$30,$40
L1382         dc.b  $67,$67,$64,$47,$08,$05,$00,$00
L138A         dc.b  $00,$00,$00,$00,$00,$00,$00,$00
L1392         dc.b  $00,$00,$00,$00,$00,$00,$00,$00
L139A         dc.b  $00,$00,$00,$00,$00,$00,$00,$00
L13A2         dc.b  $00,$00,$00,$00,$00,$00,$00,$00
L13AA         dc.b  $00,$00,$00,$00,$00,$00,$00,$00
L13B2         dc.b  $00,$00,$00,$00,$00,$01,$FE,$01
L13BA         dc.b  $00,$00,$00,$00,$01,$FE,$02,$00
L13C2         dc.b  $00,$00,$00,$01,$FE,$00,$00,$00
L13CA         dc.b  $00,$00,$00,$00,$00,$00,$00,$00
L13D2         dc.b  $00,$00,$00,$00,$00,$00,$00,$00
L13DA         dc.b  $00,$00,$00,$00,$00,$00,$00,$00
L13E2         dc.b  $00,$00,$00,$00,$00,$00,$00,$00
L13EA         dc.b  $00,$00,$00,$00,$00,$00,$00,$39
L13F2         dc.b  $4B,$5F,$74,$8A,$A1,$BA,$D4,$F0
L13FA         dc.b  $0E,$2D,$4E,$71,$96,$BE,$E8,$14
L1402         dc.b  $43,$74,$A9,$E1,$1C,$5A,$9C,$E2
L140A         dc.b  $2D,$7C,$CF,$28,$85,$E8,$52,$C1
L1412         dc.b  $37,$B4,$39,$C5,$5A,$F7,$9E,$4F
L141A         dc.b  $0A,$D1,$A3,$82,$6E,$68,$71,$8A
L1422         dc.b  $B3,$EE,$3C,$9E,$15,$A2,$46,$04
L142A         dc.b  $DC,$D0,$E2,$14,$67,$DD,$79,$3C
L1432         dc.b  $29,$44,$8D,$08,$B8,$A1,$C5,$28
L143A         dc.b  $CD,$BA,$F1,$78,$53,$87,$1A,$10
L1442         dc.b  $71,$42,$89,$4F,$9B,$74,$E2,$F0
L144A         dc.b  $A6,$0E,$33,$20,$FF,$01,$01,$01
L1452         dc.b  $01,$01,$01,$01,$01,$01,$02,$02
L145A         dc.b  $02,$02,$02,$02,$02,$03,$03,$03
L1462         dc.b  $03,$03,$04,$04,$04,$04,$05,$05
L146A         dc.b  $05,$06,$06,$06,$07,$07,$08,$08
L1472         dc.b  $09,$09,$0A,$0A,$0B,$0C,$0D,$0D
L147A         dc.b  $0E,$0F,$10,$11,$12,$13,$14,$15
L1482         dc.b  $17,$18,$1A,$1B,$1D,$1F,$20,$22
L148A         dc.b  $24,$27,$29,$2B,$2E,$31,$34,$37
L1492         dc.b  $3A,$3E,$41,$45,$49,$4E,$52,$57
L149A         dc.b  $5C,$62,$68,$6E,$75,$7C,$83,$8B
L14A2         dc.b  $93,$9C,$A5,$AF,$B9,$C4,$D0,$DD
L14AA         dc.b  $EA,$F8,$FF,$A1,$BC,$D7,$16,$16
L14B2         dc.b  $16,$F2,$37,$7A,$83,$C8,$0D,$4A
L14BA         dc.b  $99,$C0,$11,$67,$CE,$DA,$16,$7B
L14C2         dc.b  $E7,$3A,$84,$8E,$E2,$43,$BB,$00
L14CA         dc.b  $61,$80,$C5,$1C,$DB,$22,$75,$34
L14D2         dc.b  $7B,$1E,$CC,$11,$B6,$66,$C5,$18
L14DA         dc.b  $49,$9C,$03,$51,$97,$3B,$16,$17
L14E2         dc.b  $17,$17,$17,$18,$18,$18,$18,$19
L14EA         dc.b  $19,$19,$19,$1A,$1A,$1A,$1B,$1B
L14F2         dc.b  $1B,$1B,$1C,$1C,$1D,$1D,$1D,$1D
L14FA         dc.b  $1E,$1E,$1F,$1F,$20,$20,$21,$21
L1502         dc.b  $22,$22,$23,$23,$24,$24,$24,$25
L150A         dc.b  $25,$25,$26,$09,$05,$05,$00,$00
L1512         dc.b  $01,$07,$00,$03,$00,$00,$00,$00
L151A         dc.b  $00,$A9,$55,$55,$D8,$69,$8D,$00
L1522         dc.b  $5A,$9B,$5C,$67,$67,$D8,$46,$01
L152A         dc.b  $05,$0C,$12,$16,$03,$1F,$22,$29
L1532         dc.b  $2C,$31,$31,$36,$3A,$01,$06,$06
L153A         dc.b  $0A,$0C,$10,$00,$15,$0A,$1C,$21
L1542         dc.b  $21,$26,$2D,$00,$01,$01,$05,$00
L154A         dc.b  $00,$00,$00,$00,$00,$00,$00,$0C
L1552         dc.b  $00,$00,$00,$00,$00,$01,$02,$00
L155A         dc.b  $03,$00,$00,$06,$08,$09,$00,$00
L1562         dc.b  $00,$00,$00,$00,$07,$00,$0F,$00
L156A         dc.b  $00,$00,$0F,$0F,$00,$02,$02,$02
L1572         dc.b  $02,$02,$02,$02,$02,$01,$01,$02
L157A         dc.b  $02,$02,$02,$09,$09,$09,$09,$09
L1582         dc.b  $09,$09,$09,$09,$09,$09,$09,$09
L158A         dc.b  $09,$91,$51,$51,$FF,$51,$51,$51
L1592         dc.b  $51,$51,$51,$FF,$51,$51,$51,$51
L159A         dc.b  $51,$FF,$91,$51,$90,$FF,$21,$51
L15A2         dc.b  $31,$20,$20,$20,$20,$20,$FF,$31
L15AA         dc.b  $31,$FF,$91,$51,$51,$50,$50,$26
L15B2         dc.b  $FF,$51,$21,$FF,$51,$01,$01,$01
L15BA         dc.b  $FF,$51,$31,$05,$51,$FF,$91,$51
L15C2         dc.b  $51,$FF,$91,$91,$FF,$58,$28,$80
L15CA         dc.b  $00,$80,$80,$83,$83,$88,$88,$05
L15D2         dc.b  $80,$83,$83,$87,$87,$0B,$8C,$8C
L15DA         dc.b  $98,$00,$8C,$80,$80,$80,$83,$86
L15E2         dc.b  $88,$8C,$00,$80,$8C,$1F,$40,$80
L15EA         dc.b  $80,$80,$80,$95,$00,$80,$80,$00
L15F2         dc.b  $80,$83,$87,$80,$2D,$80,$80,$80
L15FA         dc.b  $80,$00,$3D,$22,$80,$00,$5F,$5C
L1602         dc.b  $28,$88,$18,$08,$08,$FF,$88,$88
L160A         dc.b  $00,$FF,$88,$FF,$88,$88,$81,$FF
L1612         dc.b  $82,$87,$10,$10,$FF,$84,$88,$84
L161A         dc.b  $81,$10,$10,$FF,$80,$78,$70,$70
L1622         dc.b  $FF,$88,$81,$10,$10,$FF,$88,$88
L162A         dc.b  $88,$81,$10,$10,$FF,$10,$10,$FF
L1632         dc.b  $00,$40,$C0,$40,$03,$88,$88,$06
L163A         dc.b  $06,$00,$00,$00,$00,$00,$0D,$00
L1642         dc.b  $80,$C0,$40,$12,$00,$00,$00,$00
L164A         dc.b  $40,$C0,$19,$80,$10,$F0,$10,$1E
L1652         dc.b  $00,$00,$20,$F0,$23,$00,$00,$00
L165A         dc.b  $00,$20,$E0,$2A,$40,$FC,$2D,$88
L1662         dc.b  $00,$7F,$FF,$98,$00,$00,$00,$00
L166A         dc.b  $01,$FF,$98,$00,$98,$00,$88,$00
L1672         dc.b  $0A,$04,$04,$FF,$81,$88,$FA,$04
L167A         dc.b  $A1,$A1,$FF,$FF,$FF,$F8,$0A,$11
L1682         dc.b  $F0,$C1,$12,$C1,$03,$01,$11,$F0
L168A         dc.b  $13,$00,$02,$02,$01,$00,$00,$02
L1692         dc.b  $00,$01,$01,$00,$00,$F0,$60,$F0
L169A         dc.b  $00,$C0,$50,$40,$50,$20,$10,$09
L16A2         dc.b  $06,$00,$03,$12,$12,$27,$27,$0A
L16AA         dc.b  $0D,$15,$15,$18,$1B,$21,$1E,$21
L16B2         dc.b  $1E,$00,$03,$24,$24,$12,$24,$12
L16BA         dc.b  $FF,$00,$10,$07,$01,$04,$13,$13
L16C2         dc.b  $28,$2A,$0B,$0E,$16,$16,$19,$1C
L16CA         dc.b  $22,$1F,$22,$1F,$01,$04,$25,$25
L16D2         dc.b  $13,$25,$13,$FF,$00,$11,$08,$02
L16DA         dc.b  $05,$14,$14,$29,$2C,$0C,$0F,$17
L16E2         dc.b  $17,$1A,$1D,$23,$20,$23,$2B,$02
L16EA         dc.b  $05,$26,$26,$14,$26,$14,$FF,$00
L16F2         dc.b  $01,$40,$88,$FD,$88,$BD,$88,$FD
L16FA         dc.b  $86,$BD,$88,$FD,$88,$BD,$88,$FD
L1702         dc.b  $86,$BD,$88,$FD,$88,$BD,$88,$FD
L170A         dc.b  $86,$BD,$8B,$FD,$8B,$BD,$8B,$FD
L1712         dc.b  $86,$BD,$88,$FD,$88,$BD,$88,$FD
L171A         dc.b  $86,$BD,$88,$FD,$88,$BD,$88,$FD
L1722         dc.b  $86,$BD,$88,$FD,$88,$BD,$88,$FD
L172A         dc.b  $86,$BD,$8B,$BD,$8B,$BD,$8B,$BD
L1732         dc.b  $8B,$FD,$86,$BD,$00,$02,$40,$94
L173A         dc.b  $BD,$BE,$BD,$A5,$BD,$BE,$FD,$9E
L1742         dc.b  $BD,$A0,$BD,$BE,$FD,$03,$A0,$BD
L174A         dc.b  $BE,$BD,$A0,$FB,$A0,$BD,$56,$00
L1752         dc.b  $50,$FE,$04,$9E,$BD,$A3,$F9,$05
L175A         dc.b  $A2,$BD,$BE,$DD,$07,$99,$BD,$43
L1762         dc.b  $00,$A7,$50,$44,$04,$B3,$50,$44
L176A         dc.b  $04,$AC,$50,$44,$04,$A7,$50,$44
L1772         dc.b  $04,$A0,$50,$44,$04,$A5,$50,$00
L177A         dc.b  $06,$40,$A7,$DD,$AA,$F5,$9B,$D1
L1782         dc.b  $00,$01,$40,$88,$FD,$88,$BD,$88
L178A         dc.b  $FD,$86,$BD,$88,$FD,$88,$BD,$88
L1792         dc.b  $FD,$89,$BD,$8B,$FD,$8B,$BD,$8B
L179A         dc.b  $FD,$81,$BD,$83,$FD,$83,$BD,$83
L17A2         dc.b  $FD,$86,$BD,$88,$FD,$88,$BD,$88
L17AA         dc.b  $FD,$86,$BD,$88,$BD,$88,$BD,$88
L17B2         dc.b  $BD,$88,$FD,$81,$BD,$83,$FD,$83
L17BA         dc.b  $BD,$83,$FD,$81,$BD,$83,$FD,$83
L17C2         dc.b  $BD,$83,$FD,$81,$BD,$00,$01,$40
L17CA         dc.b  $70,$FB,$BE,$BD,$02,$AC,$BD,$01
L17D2         dc.b  $6E,$BD,$43,$00,$70,$50,$FC,$07
L17DA         dc.b  $A7,$BD,$BE,$BD,$01,$71,$BD,$43
L17E2         dc.b  $00,$73,$50,$FC,$BE,$FD,$75,$BD
L17EA         dc.b  $43,$00,$77,$50,$FC,$BE,$FD,$6E
L17F2         dc.b  $BD,$43,$00,$70,$50,$FC,$BE,$FD
L17FA         dc.b  $6E,$BD,$43,$00,$70,$50,$FC,$BE
L1802         dc.b  $FD,$75,$BD,$43,$00,$77,$50,$FC
L180A         dc.b  $BE,$EF,$00,$09,$40,$A7,$FB,$A3
L1812         dc.b  $FB,$9B,$F9,$BE,$BD,$9C,$BD,$9E
L181A         dc.b  $F7,$9C,$BD,$43,$01,$9B,$50,$F8
L1822         dc.b  $43,$00,$9E,$50,$43,$01,$A0,$50
L182A         dc.b  $FC,$43,$00,$99,$50,$FC,$43,$00
L1832         dc.b  $9B,$50,$FC,$43,$00,$9C,$50,$FC
L183A         dc.b  $43,$00,$9B,$50,$F8,$A8,$BD,$43
L1842         dc.b  $00,$A7,$50,$F8,$0C,$8D,$BD,$00
L184A         dc.b  $01,$40,$88,$BD,$88,$BD,$88,$BD
L1852         dc.b  $88,$FD,$86,$BD,$88,$BD,$88,$BD
L185A         dc.b  $88,$BD,$88,$FD,$86,$BD,$88,$BD
L1862         dc.b  $88,$BD,$88,$BD,$88,$FD,$86,$BD
L186A         dc.b  $8B,$FD,$8B,$FD,$89,$BD,$86,$BD
L1872         dc.b  $88,$BD,$88,$BD,$88,$BD,$88,$FD
L187A         dc.b  $86,$BD,$88,$BD,$88,$BD,$88,$BD
L1882         dc.b  $88,$FD,$86,$BD,$88,$BD,$88,$BD
L188A         dc.b  $88,$BD,$88,$FD,$86,$BD,$8B,$FD
L1892         dc.b  $8B,$FD,$89,$BD,$86,$BD,$00,$08
L189A         dc.b  $40,$88,$FD,$8B,$BD,$92,$BD,$90
L18A2         dc.b  $BD,$92,$BD,$84,$BD,$86,$BD,$88
L18AA         dc.b  $BD,$89,$E3,$88,$FD,$8B,$BD,$92
L18B2         dc.b  $BD,$90,$BD,$92,$BD,$84,$BD,$86
L18BA         dc.b  $BD,$88,$BD,$89,$E3,$00,$01,$43
L18C2         dc.b  $01,$70,$50,$FC,$BE,$FD,$46,$10
L18CA         dc.b  $6E,$50,$70,$F9,$BE,$BD,$46,$10
L18D2         dc.b  $71,$50,$70,$FB,$BE,$FD,$46,$10
L18DA         dc.b  $6E,$50,$73,$FB,$BE,$FD,$46,$10
L18E2         dc.b  $6E,$50,$70,$FB,$BE,$FD,$46,$10
L18EA         dc.b  $6E,$50,$70,$BD,$56,$A0,$50,$FE
L18F2         dc.b  $BE,$FD,$46,$10,$6E,$50,$06,$94
L18FA         dc.b  $F7,$43,$05,$A8,$BD,$43,$03,$A8
L1902         dc.b  $BD,$A8,$BD,$A8,$53,$02,$A8,$BD
L190A         dc.b  $43,$01,$A8,$53,$00,$FE,$00,$01
L1912         dc.b  $4F,$02,$86,$50,$88,$FD,$88,$BD
L191A         dc.b  $88,$FD,$46,$10,$86,$50,$88,$FD
L1922         dc.b  $88,$BD,$88,$FD,$46,$10,$86,$50
L192A         dc.b  $88,$FD,$88,$BD,$88,$FD,$46,$10
L1932         dc.b  $86,$50,$8B,$FD,$8B,$BD,$8B,$FD
L193A         dc.b  $46,$10,$86,$50,$88,$FD,$88,$BD
L1942         dc.b  $88,$FD,$46,$10,$86,$50,$88,$FD
L194A         dc.b  $88,$BD,$88,$FD,$46,$10,$86,$50
L1952         dc.b  $88,$FD,$88,$BD,$88,$FD,$46,$10
L195A         dc.b  $86,$50,$8B,$FD,$8B,$BD,$8B,$FD
L1962         dc.b  $46,$10,$86,$50,$00,$01,$40,$7F
L196A         dc.b  $BD,$7F,$BD,$7F,$BD,$7F,$BD,$07
L1972         dc.b  $B8,$BD,$01,$46,$30,$7A,$50,$7F
L197A         dc.b  $BD,$7F,$BD,$7F,$BD,$7F,$BD,$07
L1982         dc.b  $AA,$BD,$01,$46,$30,$7A,$50,$7F
L198A         dc.b  $BD,$7F,$BD,$7F,$BD,$7F,$FD,$78
L1992         dc.b  $BD,$7A,$BD,$7A,$BD,$7A,$BD,$7A
L199A         dc.b  $FD,$7D,$BD,$7F,$BD,$7F,$BD,$7F
L19A2         dc.b  $BD,$7F,$BD,$BE,$BD,$7A,$BD,$7F
L19AA         dc.b  $BD,$7F,$BD,$7F,$BD,$7F,$BD,$BE
L19B2         dc.b  $BD,$7A,$BD,$7F,$BD,$7F,$BD,$7F
L19BA         dc.b  $BD,$7F,$BD,$BE,$BD,$78,$BD,$7A
L19C2         dc.b  $BD,$BE,$BD,$7A,$BD,$BE,$BD,$7A
L19CA         dc.b  $BD,$7A,$BD,$00,$0D,$46,$01,$97
L19D2         dc.b  $50,$46,$00,$BE,$50,$C0,$E4,$00
L19DA         dc.b  $0B,$40,$A7,$E9,$A3,$FB,$A7,$FB
L19E2         dc.b  $A5,$F9,$43,$00,$A3,$50,$43,$00
L19EA         dc.b  $A2,$50,$43,$00,$A3,$50,$EA,$43
L19F2         dc.b  $0A,$86,$50,$53,$0A,$50,$53,$0A
L19FA         dc.b  $50,$53,$0A,$50,$53,$0A,$50,$53
L1A02         dc.b  $0A,$50,$53,$0A,$50,$53,$0A,$50
L1A0A         dc.b  $53,$0A,$50,$53,$0A,$50,$53,$0A
L1A12         dc.b  $50,$9E,$BD,$00,$01,$40,$77,$BD
L1A1A         dc.b  $77,$BD,$77,$BD,$77,$FD,$46,$30
L1A22         dc.b  $77,$50,$7F,$BD,$7F,$BD,$7F,$BD
L1A2A         dc.b  $7F,$BD,$BE,$BD,$46,$30,$75,$50
L1A32         dc.b  $77,$BD,$77,$BD,$77,$BD,$77,$BD
L1A3A         dc.b  $BE,$BD,$7C,$BD,$7F,$BD,$7F,$BD
L1A42         dc.b  $7F,$BD,$7F,$BD,$BE,$BD,$75,$BD
L1A4A         dc.b  $77,$BD,$77,$BD,$77,$BD,$77,$BD
L1A52         dc.b  $BE,$BD,$75,$BD,$77,$BD,$BE,$BD
L1A5A         dc.b  $77,$BD,$BE,$BD,$77,$BD,$75,$BD
L1A62         dc.b  $7C,$BD,$7C,$BD,$7C,$BD,$7C,$BD
L1A6A         dc.b  $BE,$BD,$7A,$BD,$7C,$BD,$BE,$BD
L1A72         dc.b  $7C,$BD,$BE,$BD,$7C,$BD,$7A,$BD
L1A7A         dc.b  $00,$0A,$40,$9B,$BD,$07,$8F,$BD
L1A82         dc.b  $8F,$BD,$9B,$FD,$8B,$BD,$0A,$99
L1A8A         dc.b  $BD,$07,$97,$BD,$9E,$BD,$9B,$BD
L1A92         dc.b  $97,$BD,$46,$20,$99,$50,$0A,$9B
L1A9A         dc.b  $BD,$07,$9B,$BD,$A7,$BD,$A3,$FD
L1AA2         dc.b  $94,$BD,$0A,$99,$BD,$07,$A3,$BD
L1AAA         dc.b  $97,$BD,$0A,$A0,$BD,$07,$A3,$BD
L1AB2         dc.b  $46,$00,$BE,$50,$9B,$BD,$9B,$BD
L1ABA         dc.b  $9B,$BD,$9B,$FD,$99,$BD,$9B,$FD
L1AC2         dc.b  $9B,$FD,$9B,$BD,$99,$BD,$A0,$BD
L1ACA         dc.b  $A0,$BD,$A0,$BD,$AC,$BD,$05,$A0
L1AD2         dc.b  $BD,$07,$9E,$BD,$A0,$BD,$05,$94
L1ADA         dc.b  $BD,$07,$A0,$BD,$05,$A0,$BD,$07
L1AE2         dc.b  $A0,$BD,$9E,$BD,$00,$0B,$40,$A0
L1AEA         dc.b  $F9,$43,$00,$9E,$50,$43,$00,$9C
L1AF2         dc.b  $50,$43,$00,$9E,$50,$FC,$43,$01
L1AFA         dc.b  $9B,$50,$FC,$43,$00,$A0,$50,$FA
L1B02         dc.b  $43,$00,$9E,$50,$43,$00,$9C,$50
L1B0A         dc.b  $43,$00,$9E,$50,$F6,$A0,$F9,$43
L1B12         dc.b  $00,$9E,$50,$43,$00,$9C,$50,$43
L1B1A         dc.b  $00,$9E,$50,$FC,$43,$01,$9B,$50
L1B22         dc.b  $FC,$99,$F9,$97,$BD,$43,$00,$96
L1B2A         dc.b  $50,$43,$00,$97,$50,$FB,$BE,$43
L1B32         dc.b  $04,$94,$50,$43,$03,$94,$50,$00
L1B3A         dc.b  $01,$4F,$02,$6E,$50,$43,$01,$70
L1B42         dc.b  $50,$FC,$BE,$FD,$46,$10,$6E,$50
L1B4A         dc.b  $70,$F9,$BE,$BD,$46,$10,$71,$50
L1B52         dc.b  $70,$FB,$BE,$FD,$46,$10,$6E,$50
L1B5A         dc.b  $73,$FB,$BE,$FD,$46,$10,$6E,$50
L1B62         dc.b  $70,$FB,$BE,$FD,$46,$10,$6E,$50
L1B6A         dc.b  $70,$BD,$56,$A0,$50,$FE,$BE,$FD
L1B72         dc.b  $46,$10,$6E,$50,$70,$FB,$BE,$FD
L1B7A         dc.b  $6E,$BD,$43,$01,$73,$50,$FC,$BE
L1B82         dc.b  $FB,$00,$5F,$02,$40,$BE,$C0,$E2
L1B8A         dc.b  $01,$6E,$BD,$00,$01,$4F,$02,$7C
L1B92         dc.b  $50,$7C,$BD,$7C,$BD,$7C,$FD,$7D
L1B9A         dc.b  $BD,$7F,$FD,$7F,$BD,$BE,$BD,$7D
L1BA2         dc.b  $BD,$7A,$BD,$7C,$BD,$7C,$BD,$7C
L1BAA         dc.b  $BD,$7C,$FD,$7D,$BD,$7F,$FD,$7F
L1BB2         dc.b  $BD,$BE,$BD,$7D,$BD,$7A,$BD,$7C
L1BBA         dc.b  $BD,$7C,$BD,$7C,$BD,$7C,$FD,$7D
L1BC2         dc.b  $BD,$7F,$FD,$7F,$BD,$BE,$BD,$7F
L1BCA         dc.b  $BD,$7A,$BD,$7C,$BD,$7C,$BD,$7C
L1BD2         dc.b  $BD,$7C,$FD,$7D,$BD,$7F,$FD,$7F
L1BDA         dc.b  $BD,$BE,$BD,$7D,$BD,$7A,$BD,$00
L1BE2         dc.b  $09,$40,$6B,$BD,$43,$09,$B3,$50
L1BEA         dc.b  $43,$09,$AC,$50,$43,$09,$AA,$50
L1BF2         dc.b  $08,$91,$FD,$97,$FD,$94,$BD,$BE
L1BFA         dc.b  $FB,$0D,$46,$10,$97,$50,$FE,$46
L1C02         dc.b  $10,$94,$50,$09,$64,$BD,$43,$0A
L1C0A         dc.b  $A3,$50,$43,$09,$A3,$50,$43,$0A
L1C12         dc.b  $A0,$50,$43,$09,$A2,$50,$43,$09
L1C1A         dc.b  $A3,$50,$46,$00,$BE,$50,$FC,$0A
L1C22         dc.b  $46,$10,$94,$50,$08,$94,$BD,$BE
L1C2A         dc.b  $F9,$97,$FD,$94,$BD,$BE,$FB,$56
L1C32         dc.b  $10,$50,$0B,$7E,$BD,$43,$00,$BE
L1C3A         dc.b  $50,$7F,$BD,$46,$10,$BE,$50,$F2
L1C42         dc.b  $00,$0C,$40,$9B,$F5,$43,$00,$94
L1C4A         dc.b  $50,$FC,$43,$00,$9B,$50,$53,$00
L1C52         dc.b  $50,$43,$00,$A7,$50,$FE,$43,$00
L1C5A         dc.b  $A2,$50,$53,$00,$50,$53,$00,$50
L1C62         dc.b  $43,$05,$97,$50,$43,$05,$96,$50
L1C6A         dc.b  $43,$05,$94,$50,$54,$04,$50,$43
L1C72         dc.b  $05,$88,$50,$43,$05,$8A,$50,$43
L1C7A         dc.b  $05,$8B,$50,$54,$04,$50,$0E,$A0
L1C82         dc.b  $F5,$43,$00,$94,$50,$FC,$43,$00
L1C8A         dc.b  $9B,$50,$53,$00,$50,$43,$00,$A7
L1C92         dc.b  $50,$FE,$43,$00,$A2,$50,$FE,$0C
L1C9A         dc.b  $43,$0A,$A3,$50,$43,$0A,$A3,$50
L1CA2         dc.b  $43,$0A,$A3,$50,$43,$0A,$A3,$50
L1CAA         dc.b  $43,$0A,$A3,$50,$43,$0A,$A3,$50
L1CB2         dc.b  $43,$0A,$A7,$A7,$A7,$A7,$A7,$A7
L1CBA         dc.b  $00,$01,$40,$88,$FD,$88,$BD,$88
L1CC2         dc.b  $FD,$86,$BD,$88,$FD,$88,$BD,$88
L1CCA         dc.b  $FD,$86,$BD,$88,$FD,$88,$BD,$88
L1CD2         dc.b  $FD,$86,$BD,$8B,$FD,$8B,$BD,$8B
L1CDA         dc.b  $FD,$86,$BD,$88,$FD,$88,$BD,$88
L1CE2         dc.b  $FD,$86,$BD,$88,$FD,$88,$BD,$88
L1CEA         dc.b  $FD,$86,$BD,$88,$FD,$88,$BD,$88
L1CF2         dc.b  $FD,$86,$BD,$8B,$BD,$8B,$BD,$8B
L1CFA         dc.b  $BD,$8B,$FD,$86,$BD,$00,$02,$46
L1D02         dc.b  $01,$94,$50,$46,$00,$BE,$50,$46
L1D0A         dc.b  $01,$94,$50,$46,$00,$BE,$50,$FE
L1D12         dc.b  $56,$01,$50,$46,$01,$94,$50,$46
L1D1A         dc.b  $00,$BE,$50,$56,$01,$50,$46,$01
L1D22         dc.b  $94,$50,$56,$01,$50,$46,$01,$B8
L1D2A         dc.b  $50,$46,$00,$BE,$50,$FC,$56,$00
L1D32         dc.b  $50,$F4,$05,$A2,$BD,$BE,$E3,$07
L1D3A         dc.b  $46,$08,$88,$50,$46,$10,$89,$50
L1D42         dc.b  $46,$18,$94,$50,$46,$20,$95,$50
L1D4A         dc.b  $46,$28,$97,$50,$46,$30,$A3,$50
L1D52         dc.b  $46,$38,$AA,$50,$46,$40,$AF,$50
L1D5A         dc.b  $46,$48,$B6,$50,$B8,$BD,$00,$01
L1D62         dc.b  $40,$70,$FB,$BE,$FD,$6E,$BD,$43
L1D6A         dc.b  $00,$70,$50,$FE,$BE,$E1,$70,$FB
L1D72         dc.b  $BE,$FD,$6E,$BD,$43,$00,$70,$50
L1D7A         dc.b  $FE,$BE,$E5,$BE,$FD,$00,$01,$40
L1D82         dc.b  $88,$FD,$88,$BD,$88,$FD,$86,$BD
L1D8A         dc.b  $88,$FD,$88,$BD,$88,$FD,$89,$BD
L1D92         dc.b  $8B,$FD,$8B,$BD,$8B,$FD,$81,$BD
L1D9A         dc.b  $83,$FD,$83,$BD,$83,$FD,$86,$BD
L1DA2         dc.b  $88,$FD,$88,$BD,$88,$FD,$86,$BD
L1DAA         dc.b  $88,$BD,$88,$BD,$88,$BD,$88,$FD
L1DB2         dc.b  $81,$BD,$83,$FD,$83,$BD,$83,$FD
L1DBA         dc.b  $81,$BD,$83,$FD,$83,$BD,$83,$FD
L1DC2         dc.b  $81,$BD,$00,$07,$40,$94,$BD,$BE
L1DCA         dc.b  $BD,$8D,$BD,$8F,$BD,$92,$FD,$94
L1DD2         dc.b  $BD,$BE,$BD,$8D,$BD,$8F,$BD,$92
L1DDA         dc.b  $FD,$94,$FD,$8F,$BD,$92,$BD,$94
L1DE2         dc.b  $BD,$99,$BD,$97,$BD,$94,$BD,$92
L1DEA         dc.b  $BD,$94,$BD,$95,$BD,$94,$BD,$94
L1DF2         dc.b  $BD,$BE,$BD,$8D,$BD,$8F,$BD,$92
L1DFA         dc.b  $FD,$94,$BD,$BE,$BD,$8D,$BD,$8F
L1E02         dc.b  $BD,$92,$FD,$94,$FD,$8F,$BD,$92
L1E0A         dc.b  $BD,$94,$BD,$99,$BD,$97,$BD,$94
L1E12         dc.b  $BD,$92,$BD,$94,$BD,$95,$BD,$94
L1E1A         dc.b  $BD,$00,$0C,$40,$94,$BD,$43,$00
L1E22         dc.b  $8F,$50,$43,$00,$8D,$50,$43,$00
L1E2A         dc.b  $94,$50,$43,$00,$8F,$50,$43,$00
L1E32         dc.b  $8D,$50,$43,$00,$94,$50,$43,$00
L1E3A         dc.b  $99,$50,$43,$00,$8F,$50,$43,$00
L1E42         dc.b  $94,$50,$43,$00,$8F,$50,$43,$00
L1E4A         dc.b  $8D,$50,$43,$00,$94,$50,$43,$00
L1E52         dc.b  $8F,$50,$43,$00,$8D,$50,$43,$00
L1E5A         dc.b  $94,$50,$43,$00,$95,$50,$43,$00
L1E62         dc.b  $9B,$50,$43,$00,$99,$50,$43,$00
L1E6A         dc.b  $95,$50,$43,$00,$99,$50,$43,$00
L1E72         dc.b  $9B,$50,$43,$00,$8F,$50,$43,$00
L1E7A         dc.b  $8D,$50,$94,$BD,$43,$00,$8F,$50
L1E82         dc.b  $43,$00,$8D,$50,$43,$00,$94,$50
L1E8A         dc.b  $43,$00,$8F,$50,$43,$00,$8D,$50
L1E92         dc.b  $43,$00,$94,$50,$43,$00,$99,$50
L1E9A         dc.b  $43,$00,$8F,$50,$43,$00,$94,$50
L1EA2         dc.b  $43,$00,$8F,$50,$43,$07,$8D,$50
L1EAA         dc.b  $43,$00,$94,$50,$43,$00,$8F,$50
L1EB2         dc.b  $43,$06,$8D,$50,$43,$00,$94,$50
L1EBA         dc.b  $43,$00,$95,$50,$43,$01,$9B,$50
L1EC2         dc.b  $43,$00,$99,$50,$43,$06,$95,$50
L1ECA         dc.b  $43,$00,$99,$50,$43,$01,$9B,$50
L1ED2         dc.b  $43,$01,$8F,$50,$43,$00,$8D,$50
L1EDA         dc.b  $00,$01,$40,$88,$BD,$88,$BD,$88
L1EE2         dc.b  $BD,$88,$FD,$86,$BD,$88,$FD,$88
L1EEA         dc.b  $BD,$88,$FD,$89,$BD,$8B,$FD,$8B
L1EF2         dc.b  $BD,$8B,$FD,$81,$BD,$83,$FD,$83
L1EFA         dc.b  $BD,$83,$FD,$86,$BD,$88,$BD,$88
L1F02         dc.b  $BD,$88,$BD,$88,$FD,$86,$BD,$88
L1F0A         dc.b  $FD,$88,$BD,$88,$FD,$81,$BD,$83
L1F12         dc.b  $FD,$83,$BD,$83,$FD,$81,$BD,$83
L1F1A         dc.b  $FD,$83,$FD,$83,$BD,$86,$BD,$00
L1F22         dc.b  $07,$40,$94,$FD,$8D,$BD,$8F,$BD
L1F2A         dc.b  $92,$FD,$94,$FD,$8D,$BD,$8F,$BD
L1F32         dc.b  $92,$FD,$94,$FD,$8F,$BD,$92,$BD
L1F3A         dc.b  $94,$BD,$99,$BD,$97,$BD,$94,$BD
L1F42         dc.b  $92,$BD,$94,$BD,$95,$BD,$94,$BD
L1F4A         dc.b  $94,$BD,$BE,$BD,$8D,$BD,$8F,$BD
L1F52         dc.b  $92,$FD,$94,$BD,$BE,$BD,$8D,$BD
L1F5A         dc.b  $8F,$BD,$92,$FD,$94,$FD,$8F,$BD
L1F62         dc.b  $92,$BD,$94,$BD,$99,$BD,$97,$BD
L1F6A         dc.b  $94,$BD,$92,$BD,$94,$BD,$95,$BD
L1F72         dc.b  $94,$BD,$00,$0C,$40,$94,$BD,$43
L1F7A         dc.b  $00,$8F,$50,$43,$00,$8D,$50,$43
L1F82         dc.b  $00,$94,$50,$43,$00,$8F,$50,$43
L1F8A         dc.b  $00,$8D,$50,$43,$00,$94,$50,$43
L1F92         dc.b  $00,$99,$50,$43,$00,$8F,$50,$43
L1F9A         dc.b  $00,$94,$50,$43,$00,$8F,$50,$43
L1FA2         dc.b  $00,$8D,$50,$43,$00,$94,$50,$43
L1FAA         dc.b  $00,$8F,$50,$43,$00,$8D,$50,$43
L1FB2         dc.b  $00,$94,$50,$43,$00,$95,$50,$43
L1FBA         dc.b  $00,$9B,$50,$43,$00,$99,$50,$43
L1FC2         dc.b  $00,$95,$50,$43,$00,$99,$50,$43
L1FCA         dc.b  $00,$9B,$50,$43,$00,$8F,$50,$43
L1FD2         dc.b  $00,$8D,$50,$94,$BD,$43,$00,$8F
L1FDA         dc.b  $50,$43,$00,$8D,$50,$43,$00,$94
L1FE2         dc.b  $50,$43,$00,$8F,$50,$43,$00,$8D
L1FEA         dc.b  $50,$43,$00,$94,$50,$43,$00,$99
L1FF2         dc.b  $50,$43,$00,$8F,$50,$43,$00,$94
L1FFA         dc.b  $50,$43,$00,$8F,$50,$43,$07,$8D
L2002         dc.b  $50,$43,$00,$94,$50,$43,$00,$8F
L200A         dc.b  $50,$43,$06,$8D,$50,$43,$00,$94
L2012         dc.b  $50,$43,$00,$95,$50,$43,$01,$9B
L201A         dc.b  $50,$43,$00,$99,$50,$43,$06,$95
L2022         dc.b  $50,$43,$00,$99,$50,$43,$01,$9B
L202A         dc.b  $50,$43,$01,$8F,$50,$43,$00,$8D
L2032         dc.b  $50,$00,$01,$40,$7C,$FD,$88,$BD
L203A         dc.b  $88,$FD,$86,$BD,$7C,$FD,$88,$BD
L2042         dc.b  $88,$FD,$89,$BD,$8B,$FD,$8B,$BD
L204A         dc.b  $8B,$FD,$81,$BD,$77,$FD,$83,$BD
L2052         dc.b  $83,$FD,$86,$BD,$7C,$FD,$88,$BD
L205A         dc.b  $88,$FD,$86,$BD,$7C,$BD,$88,$BD
L2062         dc.b  $88,$BD,$88,$FD,$81,$BD,$77,$FD
L206A         dc.b  $83,$BD,$83,$FD,$81,$BD,$83,$FD
L2072         dc.b  $81,$BD,$83,$BD,$86,$BD,$8B,$BD
L207A         dc.b  $00,$0B,$40,$94,$BD,$43,$00,$9E
L2082         dc.b  $50,$43,$00,$A0,$50,$43,$00,$99
L208A         dc.b  $50,$43,$00,$9B,$50,$43,$00,$9E
L2092         dc.b  $50,$FE,$BE,$BD,$94,$BD,$43,$00
L209A         dc.b  $9B,$50,$43,$00,$92,$50,$43,$00
L20A2         dc.b  $9E,$50,$43,$00,$97,$50,$43,$00
L20AA         dc.b  $9E,$50,$43,$00,$94,$50,$BE,$BD
L20B2         dc.b  $43,$04,$AC,$50,$BE,$BD,$94,$BD
L20BA         dc.b  $43,$00,$9E,$50,$43,$00,$A0,$50
L20C2         dc.b  $43,$00,$99,$50,$43,$00,$9B,$50
L20CA         dc.b  $43,$00,$9E,$50,$94,$BD,$43,$00
L20D2         dc.b  $9E,$50,$43,$00,$A0,$50,$43,$00
L20DA         dc.b  $99,$50,$43,$00,$9B,$50,$43,$00
L20E2         dc.b  $9E,$50,$FE,$BE,$BD,$94,$BD,$43
L20EA         dc.b  $00,$9B,$50,$43,$00,$92,$50,$43
L20F2         dc.b  $00,$9E,$50,$43,$00,$97,$50,$43
L20FA         dc.b  $00,$9E,$50,$43,$00,$7C,$50,$BE
L2102         dc.b  $BD,$43,$04,$83,$50,$43,$00,$8D
L210A         dc.b  $BD,$8F,$BD,$99,$BD,$9E,$50,$43
L2112         dc.b  $00,$A7,$50,$43,$00,$A8,$50,$43
L211A         dc.b  $00,$B4,$50,$00,$0C,$40,$94,$BD
L2122         dc.b  $43,$00,$8F,$50,$43,$00,$8D,$50
L212A         dc.b  $43,$00,$94,$50,$43,$00,$8F,$50
L2132         dc.b  $43,$00,$8D,$50,$06,$A0,$BD,$0C
L213A         dc.b  $43,$00,$99,$50,$06,$A1,$BD,$0C
L2142         dc.b  $43,$00,$94,$50,$06,$A0,$BD,$43
L214A         dc.b  $00,$92,$50,$0C,$43,$00,$94,$50
L2152         dc.b  $43,$00,$8F,$50,$43,$00,$8D,$50
L215A         dc.b  $43,$00,$94,$50,$43,$00,$95,$50
L2162         dc.b  $43,$00,$9B,$50,$43,$00,$99,$50
L216A         dc.b  $43,$00,$95,$50,$43,$00,$99,$50
L2172         dc.b  $43,$00,$9B,$50,$43,$00,$8F,$50
L217A         dc.b  $43,$00,$8D,$50,$94,$BD,$43,$00
L2182         dc.b  $8F,$50,$43,$00,$8D,$50,$43,$00
L218A         dc.b  $94,$50,$43,$00,$8F,$50,$43,$00
L2192         dc.b  $8D,$50,$43,$00,$94,$50,$43,$00
L219A         dc.b  $99,$50,$43,$00,$8F,$50,$43,$00
L21A2         dc.b  $94,$50,$43,$00,$8F,$50,$43,$07
L21AA         dc.b  $8D,$50,$06,$43,$00,$92,$50,$43
L21B2         dc.b  $00,$BE,$50,$94,$BD,$BE,$BD,$95
L21BA         dc.b  $BD,$BE,$BD,$95,$BD,$BE,$BD,$95
L21C2         dc.b  $BD,$BE,$BD,$94,$BD,$43,$00,$BE
L21CA         dc.b  $50,$00,$01,$40,$7C,$FD,$88,$BD
L21D2         dc.b  $88,$FD,$86,$BD,$7C,$FD,$88,$BD
L21DA         dc.b  $88,$FD,$89,$BD,$8B,$FD,$8B,$BD
L21E2         dc.b  $8B,$FD,$81,$BD,$77,$FD,$83,$BD
L21EA         dc.b  $83,$FD,$86,$BD,$7C,$FD,$88,$BD
L21F2         dc.b  $88,$FD,$86,$BD,$7C,$BD,$88,$BD
L21FA         dc.b  $88,$BD,$88,$FD,$81,$BD,$77,$FD
L2202         dc.b  $83,$BD,$83,$FD,$81,$BD,$83,$FD
L220A         dc.b  $83,$FD,$83,$BD,$86,$BD,$00,$0B
L2212         dc.b  $40,$94,$BD,$43,$00,$9E,$50,$43
L221A         dc.b  $00,$A0,$50,$43,$00,$99,$50,$43
L2222         dc.b  $00,$9B,$50,$43,$00,$9E,$50,$FE
L222A         dc.b  $BE,$BD,$94,$BD,$43,$00,$9B,$50
L2232         dc.b  $43,$00,$92,$50,$43,$00,$9E,$50
L223A         dc.b  $43,$00,$97,$50,$43,$00,$9E,$50
L2242         dc.b  $43,$00,$94,$50,$BE,$BD,$43,$04
L224A         dc.b  $AC,$50,$BE,$BD,$94,$BD,$43,$00
L2252         dc.b  $9E,$50,$43,$00,$A0,$50,$43,$00
L225A         dc.b  $99,$50,$43,$00,$9B,$50,$43,$00
L2262         dc.b  $9E,$50,$94,$BD,$43,$00,$9E,$50
L226A         dc.b  $43,$00,$A0,$50,$43,$00,$99,$50
L2272         dc.b  $43,$00,$9B,$50,$43,$00,$9E,$50
L227A         dc.b  $FE,$BE,$BD,$94,$BD,$43,$00,$9B
L2282         dc.b  $50,$43,$00,$92,$50,$43,$00,$9E
L228A         dc.b  $50,$43,$00,$97,$50,$43,$00,$9E
L2292         dc.b  $50,$43,$00,$94,$50,$BE,$BD,$43
L229A         dc.b  $04,$B3,$50,$BE,$BD,$A5,$BD,$43
L22A2         dc.b  $00,$A1,$50,$43,$00,$A0,$50,$43
L22AA         dc.b  $00,$9E,$50,$43,$00,$9B,$50,$43
L22B2         dc.b  $00,$9E,$50,$00,$0C,$40,$94,$BD
L22BA         dc.b  $43,$00,$8F,$50,$43,$00,$8D,$50
L22C2         dc.b  $43,$00,$94,$50,$43,$00,$8F,$50
L22CA         dc.b  $43,$00,$8D,$50,$43,$00,$94,$50
L22D2         dc.b  $43,$00,$99,$50,$43,$00,$8F,$50
L22DA         dc.b  $43,$00,$94,$50,$43,$00,$8F,$50
L22E2         dc.b  $43,$00,$8D,$50,$43,$00,$94,$97
L22EA         dc.b  $8F,$92,$8D,$8B,$94,$92,$95,$89
L22F2         dc.b  $9B,$8F,$99,$50,$43,$00,$95,$50
L22FA         dc.b  $43,$00,$99,$50,$43,$00,$9B,$50
L2302         dc.b  $43,$00,$8F,$50,$43,$00,$8D,$50
L230A         dc.b  $94,$BD,$43,$00,$8F,$50,$43,$00
L2312         dc.b  $8D,$50,$43,$00,$94,$50,$43,$00
L231A         dc.b  $8F,$50,$43,$00,$8D,$50,$43,$00
L2322         dc.b  $94,$50,$43,$00,$99,$50,$43,$00
L232A         dc.b  $8F,$50,$43,$00,$94,$50,$43,$00
L2332         dc.b  $8F,$50,$43,$07,$8D,$50,$43,$00
L233A         dc.b  $94,$50,$43,$00,$8F,$50,$43,$06
L2342         dc.b  $8D,$53,$00,$94,$50,$43,$00,$95
L234A         dc.b  $50,$43,$01,$9B,$53,$00,$99,$50
L2352         dc.b  $43,$06,$95,$53,$00,$99,$50,$43
L235A         dc.b  $01,$9B,$53,$00,$43,$01,$8F,$53
L2362         dc.b  $00,$8D,$50,$00,$01,$40,$70,$BD
L236A         dc.b  $04,$94,$BD,$88,$BD,$94,$FD,$01
L2372         dc.b  $6E,$BD,$70,$BD,$04,$94,$BD,$88
L237A         dc.b  $BD,$94,$FB,$01,$73,$BD,$04,$88
L2382         dc.b  $BD,$94,$FD,$94,$BD,$01,$6E,$BD
L238A         dc.b  $04,$88,$BD,$94,$FD,$94,$FD,$94
L2392         dc.b  $BD,$01,$70,$BD,$04,$94,$BD,$88
L239A         dc.b  $BD,$94,$FD,$01,$6E,$BD,$70,$FD
L23A2         dc.b  $04,$88,$BD,$94,$FD,$01,$71,$BD
L23AA         dc.b  $43,$00,$73,$50,$04,$88,$BD,$94
L23B2         dc.b  $BD,$94,$FD,$94,$BD,$7C,$BD,$01
L23BA         dc.b  $73,$BD,$04,$94,$BD,$88,$BD,$01
L23C2         dc.b  $6E,$FD,$00,$05,$40,$A0,$BD,$BE
L23CA         dc.b  $BD,$A0,$BD,$A0,$BD,$BE,$BD,$9E
L23D2         dc.b  $BD,$A0,$BD,$BE,$BD,$A0,$BD,$A0
L23DA         dc.b  $BD,$BE,$BD,$9E,$BD,$A3,$BD,$BE
L23E2         dc.b  $BD,$A3,$BD,$A3,$BD,$BE,$BD,$9E
L23EA         dc.b  $BD,$A3,$BD,$BE,$BD,$A3,$BD,$BE
L23F2         dc.b  $BD,$A1,$BD,$9E,$BD,$A0,$FD,$A0
L23FA         dc.b  $BD,$A0,$FD,$9E,$BD,$A0,$FD,$A0
L2402         dc.b  $BD,$A0,$FD,$9E,$BD,$A3,$FD,$A3
L240A         dc.b  $BD,$A3,$FD,$9E,$BD,$A3,$FD,$A3
L2412         dc.b  $FD,$A1,$BD,$9E,$BD,$00,$0A,$46
L241A         dc.b  $30,$A0,$50,$E4,$02,$46,$30,$A0
L2422         dc.b  $50,$FC,$03,$46,$30,$A0,$50,$FE
L242A         dc.b  $0A,$43,$00,$A3,$50,$FA,$03,$46
L2432         dc.b  $30,$A0,$50,$E4,$02,$46,$30,$A0
L243A         dc.b  $50,$FC,$03,$46,$30,$A0,$50,$FE
L2442         dc.b  $02,$43,$00,$97,$50,$FA,$00,$01
L244A         dc.b  $40,$7C,$BD,$7C,$BD,$7C,$BD,$7C
L2452         dc.b  $FD,$7D,$BD,$7F,$FD,$7F,$BD,$BE
L245A         dc.b  $BD,$7D,$BD,$7A,$BD,$7C,$BD,$7C
L2462         dc.b  $BD,$7C,$BD,$7C,$FD,$7D,$BD,$7F
L246A         dc.b  $FD,$7F,$BD,$BE,$BD,$7D,$BD,$7A
L2472         dc.b  $BD,$7C,$BD,$7C,$BD,$7C,$BD,$7C
L247A         dc.b  $FD,$7D,$BD,$7F,$FD,$7F,$BD,$BE
L2482         dc.b  $BD,$7F,$BD,$7A,$BD,$7C,$BD,$7C
L248A         dc.b  $BD,$7C,$BD,$7C,$FD,$7D,$BD,$7F
L2492         dc.b  $FD,$7F,$BD,$BE,$BD,$7D,$BD,$7A
L249A         dc.b  $BD,$00,$09,$40,$6B,$BD,$43,$09
L24A2         dc.b  $B3,$50,$43,$09,$AC,$50,$43,$09
L24AA         dc.b  $AA,$50,$08,$91,$FD,$97,$FD,$94
L24B2         dc.b  $BD,$BE,$FB,$0D,$46,$10,$97,$50
L24BA         dc.b  $FE,$46,$10,$94,$50,$09,$64,$BD
L24C2         dc.b  $43,$0A,$A3,$50,$43,$09,$A3,$50
L24CA         dc.b  $43,$0A,$A0,$50,$43,$09,$A2,$50
L24D2         dc.b  $43,$09,$A3,$50,$46,$00,$BE,$50
L24DA         dc.b  $FC,$94,$BD,$08,$94,$BD,$BE,$F9
L24E2         dc.b  $97,$FD,$94,$BD,$BE,$FB,$56,$10
L24EA         dc.b  $50,$0B,$7E,$BD,$43,$00,$BE,$50
L24F2         dc.b  $7F,$BD,$46,$10,$BE,$50,$FE,$05
L24FA         dc.b  $9B,$FD,$A3,$FD,$9E,$BD,$BE,$BD
L2502         dc.b  $00,$01,$40,$70,$FB,$BE,$FD,$71
L250A         dc.b  $BD,$43,$00,$73,$50,$FC,$BE,$FD
L2512         dc.b  $6E,$BD,$43,$00,$70,$50,$FE,$BE
L251A         dc.b  $FB,$71,$BD,$43,$00,$73,$50,$FE
L2522         dc.b  $02,$7C,$BD,$BE,$FD,$07,$9E,$BD
L252A         dc.b  $01,$70,$FB,$BE,$FD,$71,$BD,$43
L2532         dc.b  $00,$73,$50,$FC,$BE,$FD,$6E,$BD
L253A         dc.b  $43,$00,$70,$50,$FE,$BE,$FB,$71
L2542         dc.b  $BD,$43,$00,$73,$50,$FE,$02,$7C
L254A         dc.b  $BD,$BE,$FD,$07,$9E,$BD,$00,$50
L2552         dc.b  $FC,$0C,$95,$43,$00,$97,$43,$01
L255A         dc.b  $73,$43,$00,$97,$50,$43,$00,$95
L2562         dc.b  $86,$88,$40,$BE,$FC,$53,$00,$53
L256A         dc.b  $01,$53,$00,$50,$53,$00,$50,$53
L2572         dc.b  $00,$53,$01,$53,$00,$50,$53,$00
L257A         dc.b  $40,$95,$43,$00,$97,$43,$01,$73
L2582         dc.b  $43,$00,$97,$50,$43,$00,$95,$86
L258A         dc.b  $88,$40,$BE,$94,$43,$0A,$62,$FA
L2592         dc.b  $BE,$BD,$50,$D1,$00,$0C,$40,$94
L259A         dc.b  $BD,$43,$00,$8F,$50,$43,$00,$8D
L25A2         dc.b  $50,$43,$00,$94,$50,$43,$00,$8F
L25AA         dc.b  $50,$43,$00,$8D,$50,$06,$A0,$BD
L25B2         dc.b  $0C,$43,$00,$99,$50,$06,$A1,$BD
L25BA         dc.b  $0C,$43,$00,$94,$50,$06,$A0,$BD
L25C2         dc.b  $43,$00,$92,$50,$0C,$43,$00,$94
L25CA         dc.b  $50,$43,$00,$8F,$50,$43,$00,$8D
L25D2         dc.b  $50,$43,$00,$94,$50,$43,$00,$95
L25DA         dc.b  $50,$43,$00,$9B,$50,$43,$00,$99
L25E2         dc.b  $50,$43,$00,$95,$50,$43,$00,$99
L25EA         dc.b  $50,$43,$00,$9B,$50,$43,$00,$8F
L25F2         dc.b  $50,$43,$00,$8D,$50,$94,$BD,$43
L25FA         dc.b  $00,$8F,$50,$43,$00,$8D,$50,$43
L2602         dc.b  $00,$94,$50,$43,$00,$8F,$50,$43
L260A         dc.b  $00,$8D,$50,$43,$00,$94,$50,$43
L2612         dc.b  $00,$99,$50,$43,$00,$8F,$50,$43
L261A         dc.b  $00,$94,$50,$43,$00,$8F,$50,$43
L2622         dc.b  $07,$8D,$50,$06,$43,$00,$92,$50
L262A         dc.b  $FE,$43,$00,$94,$50,$FA,$43,$05
L2632         dc.b  $A8,$53,$02,$BD,$53,$00,$50,$F9
L263A         dc.b  $00,$01,$40,$70,$FB,$BE,$FD,$71
L2642         dc.b  $BD,$43,$00,$73,$50,$FC,$BE,$FD
L264A         dc.b  $6E,$BD,$43,$00,$70,$50,$FE,$BE
L2652         dc.b  $FB,$71,$BD,$43,$00,$73,$50,$FE
L265A         dc.b  $02,$7C,$BD,$BE,$FD,$07,$9E,$BD
L2662         dc.b  $01,$70,$FB,$BE,$FD,$71,$BD,$43
L266A         dc.b  $00,$73,$50,$FC,$BE,$FD,$0B,$92
L2672         dc.b  $BD,$43,$00,$94,$50,$BE,$BD,$9E
L267A         dc.b  $BD,$A0,$BD,$BE,$BD,$95,$BD,$43
L2682         dc.b  $00,$97,$50,$94,$BE,$F8,$00
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

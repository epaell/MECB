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
L0F82         fcb   $50,$53,$49,$44,$00,$02,$00,$7C
L0F8A         fcb   $00,$00,$10,$00,$10,$03,$00,$01
L0F92         fcb   $00,$01,$00,$00,$00,$00,$44,$6F
L0F9A         fcb   $63,$74,$6F,$72,$20,$57,$68,$6F
L0FA2         fcb   $20,$2D,$20,$54,$68,$65,$20,$56
L0FAA         fcb   $69,$73,$69,$64,$61,$74,$69,$6F
L0FB2         fcb   $6E,$00,$00,$00,$00,$00,$41,$6C
L0FBA         fcb   $65,$78,$69,$73,$20,$47,$6C,$61
L0FC2         fcb   $73,$73,$20,$28,$6D,$75,$74,$61
L0FCA         fcb   $67,$65,$6E,$65,$29,$00,$00,$00
L0FD2         fcb   $00,$00,$00,$00,$00,$00,$32,$30
L0FDA         fcb   $31,$30,$20,$6D,$75,$74,$61,$67
L0FE2         fcb   $65,$6E,$65,$00,$00,$00,$00,$00
L0FEA         fcb   $00,$00,$00,$00,$00,$00,$00,$00
L0FF2         fcb   $00,$00,$00,$00,$00,$00,$00,$14
L0FFA         fcb   $00,$00,$00,$00,$00,$10
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
L1371         fcb   $06
L1372         fcb   $0C,$0C,$13,$13,$1D,$1D,$21,$21
L137A         fcb   $21,$21,$21,$21,$21,$21,$30,$40
L1382         fcb   $67,$67,$64,$47,$08,$05,$00,$00
L138A         fcb   $00,$00,$00,$00,$00,$00,$00,$00
L1392         fcb   $00,$00,$00,$00,$00,$00,$00,$00
L139A         fcb   $00,$00,$00,$00,$00,$00,$00,$00
L13A2         fcb   $00,$00,$00,$00,$00,$00,$00,$00
L13AA         fcb   $00,$00,$00,$00,$00,$00,$00,$00
L13B2         fcb   $00,$00,$00,$00,$00,$01,$FE,$01
L13BA         fcb   $00,$00,$00,$00,$01,$FE,$02,$00
L13C2         fcb   $00,$00,$00,$01,$FE,$00,$00,$00
L13CA         fcb   $00,$00,$00,$00,$00,$00,$00,$00
L13D2         fcb   $00,$00,$00,$00,$00,$00,$00,$00
L13DA         fcb   $00,$00,$00,$00,$00,$00,$00,$00
L13E2         fcb   $00,$00,$00,$00,$00,$00,$00,$00
L13EA         fcb   $00,$00,$00,$00,$00,$00,$00,$39
L13F2         fcb   $4B,$5F,$74,$8A,$A1,$BA,$D4,$F0
L13FA         fcb   $0E,$2D,$4E,$71,$96,$BE,$E8,$14
L1402         fcb   $43,$74,$A9,$E1,$1C,$5A,$9C,$E2
L140A         fcb   $2D,$7C,$CF,$28,$85,$E8,$52,$C1
L1412         fcb   $37,$B4,$39,$C5,$5A,$F7,$9E,$4F
L141A         fcb   $0A,$D1,$A3,$82,$6E,$68,$71,$8A
L1422         fcb   $B3,$EE,$3C,$9E,$15,$A2,$46,$04
L142A         fcb   $DC,$D0,$E2,$14,$67,$DD,$79,$3C
L1432         fcb   $29,$44,$8D,$08,$B8,$A1,$C5,$28
L143A         fcb   $CD,$BA,$F1,$78,$53,$87,$1A,$10
L1442         fcb   $71,$42,$89,$4F,$9B,$74,$E2,$F0
L144A         fcb   $A6,$0E,$33,$20,$FF,$01,$01,$01
L1452         fcb   $01,$01,$01,$01,$01,$01,$02,$02
L145A         fcb   $02,$02,$02,$02,$02,$03,$03,$03
L1462         fcb   $03,$03,$04,$04,$04,$04,$05,$05
L146A         fcb   $05,$06,$06,$06,$07,$07,$08,$08
L1472         fcb   $09,$09,$0A,$0A,$0B,$0C,$0D,$0D
L147A         fcb   $0E,$0F,$10,$11,$12,$13,$14,$15
L1482         fcb   $17,$18,$1A,$1B,$1D,$1F,$20,$22
L148A         fcb   $24,$27,$29,$2B,$2E,$31,$34,$37
L1492         fcb   $3A,$3E,$41,$45,$49,$4E,$52,$57
L149A         fcb   $5C,$62,$68,$6E,$75,$7C,$83,$8B
L14A2         fcb   $93,$9C,$A5,$AF,$B9,$C4,$D0,$DD
L14AA         fcb   $EA,$F8,$FF,$A1,$BC,$D7,$16,$16
L14B2         fcb   $16,$F2,$37,$7A,$83,$C8,$0D,$4A
L14BA         fcb   $99,$C0,$11,$67,$CE,$DA,$16,$7B
L14C2         fcb   $E7,$3A,$84,$8E,$E2,$43,$BB,$00
L14CA         fcb   $61,$80,$C5,$1C,$DB,$22,$75,$34
L14D2         fcb   $7B,$1E,$CC,$11,$B6,$66,$C5,$18
L14DA         fcb   $49,$9C,$03,$51,$97,$3B,$16,$17
L14E2         fcb   $17,$17,$17,$18,$18,$18,$18,$19
L14EA         fcb   $19,$19,$19,$1A,$1A,$1A,$1B,$1B
L14F2         fcb   $1B,$1B,$1C,$1C,$1D,$1D,$1D,$1D
L14FA         fcb   $1E,$1E,$1F,$1F,$20,$20,$21,$21
L1502         fcb   $22,$22,$23,$23,$24,$24,$24,$25
L150A         fcb   $25,$25,$26,$09,$05,$05,$00,$00
L1512         fcb   $01,$07,$00,$03,$00,$00,$00,$00
L151A         fcb   $00,$A9,$55,$55,$D8,$69,$8D,$00
L1522         fcb   $5A,$9B,$5C,$67,$67,$D8,$46,$01
L152A         fcb   $05,$0C,$12,$16,$03,$1F,$22,$29
L1532         fcb   $2C,$31,$31,$36,$3A,$01,$06,$06
L153A         fcb   $0A,$0C,$10,$00,$15,$0A,$1C,$21
L1542         fcb   $21,$26,$2D,$00,$01,$01,$05,$00
L154A         fcb   $00,$00,$00,$00,$00,$00,$00,$0C
L1552         fcb   $00,$00,$00,$00,$00,$01,$02,$00
L155A         fcb   $03,$00,$00,$06,$08,$09,$00,$00
L1562         fcb   $00,$00,$00,$00,$07,$00,$0F,$00
L156A         fcb   $00,$00,$0F,$0F,$00,$02,$02,$02
L1572         fcb   $02,$02,$02,$02,$02,$01,$01,$02
L157A         fcb   $02,$02,$02,$09,$09,$09,$09,$09
L1582         fcb   $09,$09,$09,$09,$09,$09,$09,$09
L158A         fcb   $09,$91,$51,$51,$FF,$51,$51,$51
L1592         fcb   $51,$51,$51,$FF,$51,$51,$51,$51
L159A         fcb   $51,$FF,$91,$51,$90,$FF,$21,$51
L15A2         fcb   $31,$20,$20,$20,$20,$20,$FF,$31
L15AA         fcb   $31,$FF,$91,$51,$51,$50,$50,$26
L15B2         fcb   $FF,$51,$21,$FF,$51,$01,$01,$01
L15BA         fcb   $FF,$51,$31,$05,$51,$FF,$91,$51
L15C2         fcb   $51,$FF,$91,$91,$FF,$58,$28,$80
L15CA         fcb   $00,$80,$80,$83,$83,$88,$88,$05
L15D2         fcb   $80,$83,$83,$87,$87,$0B,$8C,$8C
L15DA         fcb   $98,$00,$8C,$80,$80,$80,$83,$86
L15E2         fcb   $88,$8C,$00,$80,$8C,$1F,$40,$80
L15EA         fcb   $80,$80,$80,$95,$00,$80,$80,$00
L15F2         fcb   $80,$83,$87,$80,$2D,$80,$80,$80
L15FA         fcb   $80,$00,$3D,$22,$80,$00,$5F,$5C
L1602         fcb   $28,$88,$18,$08,$08,$FF,$88,$88
L160A         fcb   $00,$FF,$88,$FF,$88,$88,$81,$FF
L1612         fcb   $82,$87,$10,$10,$FF,$84,$88,$84
L161A         fcb   $81,$10,$10,$FF,$80,$78,$70,$70
L1622         fcb   $FF,$88,$81,$10,$10,$FF,$88,$88
L162A         fcb   $88,$81,$10,$10,$FF,$10,$10,$FF
L1632         fcb   $00,$40,$C0,$40,$03,$88,$88,$06
L163A         fcb   $06,$00,$00,$00,$00,$00,$0D,$00
L1642         fcb   $80,$C0,$40,$12,$00,$00,$00,$00
L164A         fcb   $40,$C0,$19,$80,$10,$F0,$10,$1E
L1652         fcb   $00,$00,$20,$F0,$23,$00,$00,$00
L165A         fcb   $00,$20,$E0,$2A,$40,$FC,$2D,$88
L1662         fcb   $00,$7F,$FF,$98,$00,$00,$00,$00
L166A         fcb   $01,$FF,$98,$00,$98,$00,$88,$00
L1672         fcb   $0A,$04,$04,$FF,$81,$88,$FA,$04
L167A         fcb   $A1,$A1,$FF,$FF,$FF,$F8,$0A,$11
L1682         fcb   $F0,$C1,$12,$C1,$03,$01,$11,$F0
L168A         fcb   $13,$00,$02,$02,$01,$00,$00,$02
L1692         fcb   $00,$01,$01,$00,$00,$F0,$60,$F0
L169A         fcb   $00,$C0,$50,$40,$50,$20,$10,$09
L16A2         fcb   $06,$00,$03,$12,$12,$27,$27,$0A
L16AA         fcb   $0D,$15,$15,$18,$1B,$21,$1E,$21
L16B2         fcb   $1E,$00,$03,$24,$24,$12,$24,$12
L16BA         fcb   $FF,$00,$10,$07,$01,$04,$13,$13
L16C2         fcb   $28,$2A,$0B,$0E,$16,$16,$19,$1C
L16CA         fcb   $22,$1F,$22,$1F,$01,$04,$25,$25
L16D2         fcb   $13,$25,$13,$FF,$00,$11,$08,$02
L16DA         fcb   $05,$14,$14,$29,$2C,$0C,$0F,$17
L16E2         fcb   $17,$1A,$1D,$23,$20,$23,$2B,$02
L16EA         fcb   $05,$26,$26,$14,$26,$14,$FF,$00
L16F2         fcb   $01,$40,$88,$FD,$88,$BD,$88,$FD
L16FA         fcb   $86,$BD,$88,$FD,$88,$BD,$88,$FD
L1702         fcb   $86,$BD,$88,$FD,$88,$BD,$88,$FD
L170A         fcb   $86,$BD,$8B,$FD,$8B,$BD,$8B,$FD
L1712         fcb   $86,$BD,$88,$FD,$88,$BD,$88,$FD
L171A         fcb   $86,$BD,$88,$FD,$88,$BD,$88,$FD
L1722         fcb   $86,$BD,$88,$FD,$88,$BD,$88,$FD
L172A         fcb   $86,$BD,$8B,$BD,$8B,$BD,$8B,$BD
L1732         fcb   $8B,$FD,$86,$BD,$00,$02,$40,$94
L173A         fcb   $BD,$BE,$BD,$A5,$BD,$BE,$FD,$9E
L1742         fcb   $BD,$A0,$BD,$BE,$FD,$03,$A0,$BD
L174A         fcb   $BE,$BD,$A0,$FB,$A0,$BD,$56,$00
L1752         fcb   $50,$FE,$04,$9E,$BD,$A3,$F9,$05
L175A         fcb   $A2,$BD,$BE,$DD,$07,$99,$BD,$43
L1762         fcb   $00,$A7,$50,$44,$04,$B3,$50,$44
L176A         fcb   $04,$AC,$50,$44,$04,$A7,$50,$44
L1772         fcb   $04,$A0,$50,$44,$04,$A5,$50,$00
L177A         fcb   $06,$40,$A7,$DD,$AA,$F5,$9B,$D1
L1782         fcb   $00,$01,$40,$88,$FD,$88,$BD,$88
L178A         fcb   $FD,$86,$BD,$88,$FD,$88,$BD,$88
L1792         fcb   $FD,$89,$BD,$8B,$FD,$8B,$BD,$8B
L179A         fcb   $FD,$81,$BD,$83,$FD,$83,$BD,$83
L17A2         fcb   $FD,$86,$BD,$88,$FD,$88,$BD,$88
L17AA         fcb   $FD,$86,$BD,$88,$BD,$88,$BD,$88
L17B2         fcb   $BD,$88,$FD,$81,$BD,$83,$FD,$83
L17BA         fcb   $BD,$83,$FD,$81,$BD,$83,$FD,$83
L17C2         fcb   $BD,$83,$FD,$81,$BD,$00,$01,$40
L17CA         fcb   $70,$FB,$BE,$BD,$02,$AC,$BD,$01
L17D2         fcb   $6E,$BD,$43,$00,$70,$50,$FC,$07
L17DA         fcb   $A7,$BD,$BE,$BD,$01,$71,$BD,$43
L17E2         fcb   $00,$73,$50,$FC,$BE,$FD,$75,$BD
L17EA         fcb   $43,$00,$77,$50,$FC,$BE,$FD,$6E
L17F2         fcb   $BD,$43,$00,$70,$50,$FC,$BE,$FD
L17FA         fcb   $6E,$BD,$43,$00,$70,$50,$FC,$BE
L1802         fcb   $FD,$75,$BD,$43,$00,$77,$50,$FC
L180A         fcb   $BE,$EF,$00,$09,$40,$A7,$FB,$A3
L1812         fcb   $FB,$9B,$F9,$BE,$BD,$9C,$BD,$9E
L181A         fcb   $F7,$9C,$BD,$43,$01,$9B,$50,$F8
L1822         fcb   $43,$00,$9E,$50,$43,$01,$A0,$50
L182A         fcb   $FC,$43,$00,$99,$50,$FC,$43,$00
L1832         fcb   $9B,$50,$FC,$43,$00,$9C,$50,$FC
L183A         fcb   $43,$00,$9B,$50,$F8,$A8,$BD,$43
L1842         fcb   $00,$A7,$50,$F8,$0C,$8D,$BD,$00
L184A         fcb   $01,$40,$88,$BD,$88,$BD,$88,$BD
L1852         fcb   $88,$FD,$86,$BD,$88,$BD,$88,$BD
L185A         fcb   $88,$BD,$88,$FD,$86,$BD,$88,$BD
L1862         fcb   $88,$BD,$88,$BD,$88,$FD,$86,$BD
L186A         fcb   $8B,$FD,$8B,$FD,$89,$BD,$86,$BD
L1872         fcb   $88,$BD,$88,$BD,$88,$BD,$88,$FD
L187A         fcb   $86,$BD,$88,$BD,$88,$BD,$88,$BD
L1882         fcb   $88,$FD,$86,$BD,$88,$BD,$88,$BD
L188A         fcb   $88,$BD,$88,$FD,$86,$BD,$8B,$FD
L1892         fcb   $8B,$FD,$89,$BD,$86,$BD,$00,$08
L189A         fcb   $40,$88,$FD,$8B,$BD,$92,$BD,$90
L18A2         fcb   $BD,$92,$BD,$84,$BD,$86,$BD,$88
L18AA         fcb   $BD,$89,$E3,$88,$FD,$8B,$BD,$92
L18B2         fcb   $BD,$90,$BD,$92,$BD,$84,$BD,$86
L18BA         fcb   $BD,$88,$BD,$89,$E3,$00,$01,$43
L18C2         fcb   $01,$70,$50,$FC,$BE,$FD,$46,$10
L18CA         fcb   $6E,$50,$70,$F9,$BE,$BD,$46,$10
L18D2         fcb   $71,$50,$70,$FB,$BE,$FD,$46,$10
L18DA         fcb   $6E,$50,$73,$FB,$BE,$FD,$46,$10
L18E2         fcb   $6E,$50,$70,$FB,$BE,$FD,$46,$10
L18EA         fcb   $6E,$50,$70,$BD,$56,$A0,$50,$FE
L18F2         fcb   $BE,$FD,$46,$10,$6E,$50,$06,$94
L18FA         fcb   $F7,$43,$05,$A8,$BD,$43,$03,$A8
L1902         fcb   $BD,$A8,$BD,$A8,$53,$02,$A8,$BD
L190A         fcb   $43,$01,$A8,$53,$00,$FE,$00,$01
L1912         fcb   $4F,$02,$86,$50,$88,$FD,$88,$BD
L191A         fcb   $88,$FD,$46,$10,$86,$50,$88,$FD
L1922         fcb   $88,$BD,$88,$FD,$46,$10,$86,$50
L192A         fcb   $88,$FD,$88,$BD,$88,$FD,$46,$10
L1932         fcb   $86,$50,$8B,$FD,$8B,$BD,$8B,$FD
L193A         fcb   $46,$10,$86,$50,$88,$FD,$88,$BD
L1942         fcb   $88,$FD,$46,$10,$86,$50,$88,$FD
L194A         fcb   $88,$BD,$88,$FD,$46,$10,$86,$50
L1952         fcb   $88,$FD,$88,$BD,$88,$FD,$46,$10
L195A         fcb   $86,$50,$8B,$FD,$8B,$BD,$8B,$FD
L1962         fcb   $46,$10,$86,$50,$00,$01,$40,$7F
L196A         fcb   $BD,$7F,$BD,$7F,$BD,$7F,$BD,$07
L1972         fcb   $B8,$BD,$01,$46,$30,$7A,$50,$7F
L197A         fcb   $BD,$7F,$BD,$7F,$BD,$7F,$BD,$07
L1982         fcb   $AA,$BD,$01,$46,$30,$7A,$50,$7F
L198A         fcb   $BD,$7F,$BD,$7F,$BD,$7F,$FD,$78
L1992         fcb   $BD,$7A,$BD,$7A,$BD,$7A,$BD,$7A
L199A         fcb   $FD,$7D,$BD,$7F,$BD,$7F,$BD,$7F
L19A2         fcb   $BD,$7F,$BD,$BE,$BD,$7A,$BD,$7F
L19AA         fcb   $BD,$7F,$BD,$7F,$BD,$7F,$BD,$BE
L19B2         fcb   $BD,$7A,$BD,$7F,$BD,$7F,$BD,$7F
L19BA         fcb   $BD,$7F,$BD,$BE,$BD,$78,$BD,$7A
L19C2         fcb   $BD,$BE,$BD,$7A,$BD,$BE,$BD,$7A
L19CA         fcb   $BD,$7A,$BD,$00,$0D,$46,$01,$97
L19D2         fcb   $50,$46,$00,$BE,$50,$C0,$E4,$00
L19DA         fcb   $0B,$40,$A7,$E9,$A3,$FB,$A7,$FB
L19E2         fcb   $A5,$F9,$43,$00,$A3,$50,$43,$00
L19EA         fcb   $A2,$50,$43,$00,$A3,$50,$EA,$43
L19F2         fcb   $0A,$86,$50,$53,$0A,$50,$53,$0A
L19FA         fcb   $50,$53,$0A,$50,$53,$0A,$50,$53
L1A02         fcb   $0A,$50,$53,$0A,$50,$53,$0A,$50
L1A0A         fcb   $53,$0A,$50,$53,$0A,$50,$53,$0A
L1A12         fcb   $50,$9E,$BD,$00,$01,$40,$77,$BD
L1A1A         fcb   $77,$BD,$77,$BD,$77,$FD,$46,$30
L1A22         fcb   $77,$50,$7F,$BD,$7F,$BD,$7F,$BD
L1A2A         fcb   $7F,$BD,$BE,$BD,$46,$30,$75,$50
L1A32         fcb   $77,$BD,$77,$BD,$77,$BD,$77,$BD
L1A3A         fcb   $BE,$BD,$7C,$BD,$7F,$BD,$7F,$BD
L1A42         fcb   $7F,$BD,$7F,$BD,$BE,$BD,$75,$BD
L1A4A         fcb   $77,$BD,$77,$BD,$77,$BD,$77,$BD
L1A52         fcb   $BE,$BD,$75,$BD,$77,$BD,$BE,$BD
L1A5A         fcb   $77,$BD,$BE,$BD,$77,$BD,$75,$BD
L1A62         fcb   $7C,$BD,$7C,$BD,$7C,$BD,$7C,$BD
L1A6A         fcb   $BE,$BD,$7A,$BD,$7C,$BD,$BE,$BD
L1A72         fcb   $7C,$BD,$BE,$BD,$7C,$BD,$7A,$BD
L1A7A         fcb   $00,$0A,$40,$9B,$BD,$07,$8F,$BD
L1A82         fcb   $8F,$BD,$9B,$FD,$8B,$BD,$0A,$99
L1A8A         fcb   $BD,$07,$97,$BD,$9E,$BD,$9B,$BD
L1A92         fcb   $97,$BD,$46,$20,$99,$50,$0A,$9B
L1A9A         fcb   $BD,$07,$9B,$BD,$A7,$BD,$A3,$FD
L1AA2         fcb   $94,$BD,$0A,$99,$BD,$07,$A3,$BD
L1AAA         fcb   $97,$BD,$0A,$A0,$BD,$07,$A3,$BD
L1AB2         fcb   $46,$00,$BE,$50,$9B,$BD,$9B,$BD
L1ABA         fcb   $9B,$BD,$9B,$FD,$99,$BD,$9B,$FD
L1AC2         fcb   $9B,$FD,$9B,$BD,$99,$BD,$A0,$BD
L1ACA         fcb   $A0,$BD,$A0,$BD,$AC,$BD,$05,$A0
L1AD2         fcb   $BD,$07,$9E,$BD,$A0,$BD,$05,$94
L1ADA         fcb   $BD,$07,$A0,$BD,$05,$A0,$BD,$07
L1AE2         fcb   $A0,$BD,$9E,$BD,$00,$0B,$40,$A0
L1AEA         fcb   $F9,$43,$00,$9E,$50,$43,$00,$9C
L1AF2         fcb   $50,$43,$00,$9E,$50,$FC,$43,$01
L1AFA         fcb   $9B,$50,$FC,$43,$00,$A0,$50,$FA
L1B02         fcb   $43,$00,$9E,$50,$43,$00,$9C,$50
L1B0A         fcb   $43,$00,$9E,$50,$F6,$A0,$F9,$43
L1B12         fcb   $00,$9E,$50,$43,$00,$9C,$50,$43
L1B1A         fcb   $00,$9E,$50,$FC,$43,$01,$9B,$50
L1B22         fcb   $FC,$99,$F9,$97,$BD,$43,$00,$96
L1B2A         fcb   $50,$43,$00,$97,$50,$FB,$BE,$43
L1B32         fcb   $04,$94,$50,$43,$03,$94,$50,$00
L1B3A         fcb   $01,$4F,$02,$6E,$50,$43,$01,$70
L1B42         fcb   $50,$FC,$BE,$FD,$46,$10,$6E,$50
L1B4A         fcb   $70,$F9,$BE,$BD,$46,$10,$71,$50
L1B52         fcb   $70,$FB,$BE,$FD,$46,$10,$6E,$50
L1B5A         fcb   $73,$FB,$BE,$FD,$46,$10,$6E,$50
L1B62         fcb   $70,$FB,$BE,$FD,$46,$10,$6E,$50
L1B6A         fcb   $70,$BD,$56,$A0,$50,$FE,$BE,$FD
L1B72         fcb   $46,$10,$6E,$50,$70,$FB,$BE,$FD
L1B7A         fcb   $6E,$BD,$43,$01,$73,$50,$FC,$BE
L1B82         fcb   $FB,$00,$5F,$02,$40,$BE,$C0,$E2
L1B8A         fcb   $01,$6E,$BD,$00,$01,$4F,$02,$7C
L1B92         fcb   $50,$7C,$BD,$7C,$BD,$7C,$FD,$7D
L1B9A         fcb   $BD,$7F,$FD,$7F,$BD,$BE,$BD,$7D
L1BA2         fcb   $BD,$7A,$BD,$7C,$BD,$7C,$BD,$7C
L1BAA         fcb   $BD,$7C,$FD,$7D,$BD,$7F,$FD,$7F
L1BB2         fcb   $BD,$BE,$BD,$7D,$BD,$7A,$BD,$7C
L1BBA         fcb   $BD,$7C,$BD,$7C,$BD,$7C,$FD,$7D
L1BC2         fcb   $BD,$7F,$FD,$7F,$BD,$BE,$BD,$7F
L1BCA         fcb   $BD,$7A,$BD,$7C,$BD,$7C,$BD,$7C
L1BD2         fcb   $BD,$7C,$FD,$7D,$BD,$7F,$FD,$7F
L1BDA         fcb   $BD,$BE,$BD,$7D,$BD,$7A,$BD,$00
L1BE2         fcb   $09,$40,$6B,$BD,$43,$09,$B3,$50
L1BEA         fcb   $43,$09,$AC,$50,$43,$09,$AA,$50
L1BF2         fcb   $08,$91,$FD,$97,$FD,$94,$BD,$BE
L1BFA         fcb   $FB,$0D,$46,$10,$97,$50,$FE,$46
L1C02         fcb   $10,$94,$50,$09,$64,$BD,$43,$0A
L1C0A         fcb   $A3,$50,$43,$09,$A3,$50,$43,$0A
L1C12         fcb   $A0,$50,$43,$09,$A2,$50,$43,$09
L1C1A         fcb   $A3,$50,$46,$00,$BE,$50,$FC,$0A
L1C22         fcb   $46,$10,$94,$50,$08,$94,$BD,$BE
L1C2A         fcb   $F9,$97,$FD,$94,$BD,$BE,$FB,$56
L1C32         fcb   $10,$50,$0B,$7E,$BD,$43,$00,$BE
L1C3A         fcb   $50,$7F,$BD,$46,$10,$BE,$50,$F2
L1C42         fcb   $00,$0C,$40,$9B,$F5,$43,$00,$94
L1C4A         fcb   $50,$FC,$43,$00,$9B,$50,$53,$00
L1C52         fcb   $50,$43,$00,$A7,$50,$FE,$43,$00
L1C5A         fcb   $A2,$50,$53,$00,$50,$53,$00,$50
L1C62         fcb   $43,$05,$97,$50,$43,$05,$96,$50
L1C6A         fcb   $43,$05,$94,$50,$54,$04,$50,$43
L1C72         fcb   $05,$88,$50,$43,$05,$8A,$50,$43
L1C7A         fcb   $05,$8B,$50,$54,$04,$50,$0E,$A0
L1C82         fcb   $F5,$43,$00,$94,$50,$FC,$43,$00
L1C8A         fcb   $9B,$50,$53,$00,$50,$43,$00,$A7
L1C92         fcb   $50,$FE,$43,$00,$A2,$50,$FE,$0C
L1C9A         fcb   $43,$0A,$A3,$50,$43,$0A,$A3,$50
L1CA2         fcb   $43,$0A,$A3,$50,$43,$0A,$A3,$50
L1CAA         fcb   $43,$0A,$A3,$50,$43,$0A,$A3,$50
L1CB2         fcb   $43,$0A,$A7,$A7,$A7,$A7,$A7,$A7
L1CBA         fcb   $00,$01,$40,$88,$FD,$88,$BD,$88
L1CC2         fcb   $FD,$86,$BD,$88,$FD,$88,$BD,$88
L1CCA         fcb   $FD,$86,$BD,$88,$FD,$88,$BD,$88
L1CD2         fcb   $FD,$86,$BD,$8B,$FD,$8B,$BD,$8B
L1CDA         fcb   $FD,$86,$BD,$88,$FD,$88,$BD,$88
L1CE2         fcb   $FD,$86,$BD,$88,$FD,$88,$BD,$88
L1CEA         fcb   $FD,$86,$BD,$88,$FD,$88,$BD,$88
L1CF2         fcb   $FD,$86,$BD,$8B,$BD,$8B,$BD,$8B
L1CFA         fcb   $BD,$8B,$FD,$86,$BD,$00,$02,$46
L1D02         fcb   $01,$94,$50,$46,$00,$BE,$50,$46
L1D0A         fcb   $01,$94,$50,$46,$00,$BE,$50,$FE
L1D12         fcb   $56,$01,$50,$46,$01,$94,$50,$46
L1D1A         fcb   $00,$BE,$50,$56,$01,$50,$46,$01
L1D22         fcb   $94,$50,$56,$01,$50,$46,$01,$B8
L1D2A         fcb   $50,$46,$00,$BE,$50,$FC,$56,$00
L1D32         fcb   $50,$F4,$05,$A2,$BD,$BE,$E3,$07
L1D3A         fcb   $46,$08,$88,$50,$46,$10,$89,$50
L1D42         fcb   $46,$18,$94,$50,$46,$20,$95,$50
L1D4A         fcb   $46,$28,$97,$50,$46,$30,$A3,$50
L1D52         fcb   $46,$38,$AA,$50,$46,$40,$AF,$50
L1D5A         fcb   $46,$48,$B6,$50,$B8,$BD,$00,$01
L1D62         fcb   $40,$70,$FB,$BE,$FD,$6E,$BD,$43
L1D6A         fcb   $00,$70,$50,$FE,$BE,$E1,$70,$FB
L1D72         fcb   $BE,$FD,$6E,$BD,$43,$00,$70,$50
L1D7A         fcb   $FE,$BE,$E5,$BE,$FD,$00,$01,$40
L1D82         fcb   $88,$FD,$88,$BD,$88,$FD,$86,$BD
L1D8A         fcb   $88,$FD,$88,$BD,$88,$FD,$89,$BD
L1D92         fcb   $8B,$FD,$8B,$BD,$8B,$FD,$81,$BD
L1D9A         fcb   $83,$FD,$83,$BD,$83,$FD,$86,$BD
L1DA2         fcb   $88,$FD,$88,$BD,$88,$FD,$86,$BD
L1DAA         fcb   $88,$BD,$88,$BD,$88,$BD,$88,$FD
L1DB2         fcb   $81,$BD,$83,$FD,$83,$BD,$83,$FD
L1DBA         fcb   $81,$BD,$83,$FD,$83,$BD,$83,$FD
L1DC2         fcb   $81,$BD,$00,$07,$40,$94,$BD,$BE
L1DCA         fcb   $BD,$8D,$BD,$8F,$BD,$92,$FD,$94
L1DD2         fcb   $BD,$BE,$BD,$8D,$BD,$8F,$BD,$92
L1DDA         fcb   $FD,$94,$FD,$8F,$BD,$92,$BD,$94
L1DE2         fcb   $BD,$99,$BD,$97,$BD,$94,$BD,$92
L1DEA         fcb   $BD,$94,$BD,$95,$BD,$94,$BD,$94
L1DF2         fcb   $BD,$BE,$BD,$8D,$BD,$8F,$BD,$92
L1DFA         fcb   $FD,$94,$BD,$BE,$BD,$8D,$BD,$8F
L1E02         fcb   $BD,$92,$FD,$94,$FD,$8F,$BD,$92
L1E0A         fcb   $BD,$94,$BD,$99,$BD,$97,$BD,$94
L1E12         fcb   $BD,$92,$BD,$94,$BD,$95,$BD,$94
L1E1A         fcb   $BD,$00,$0C,$40,$94,$BD,$43,$00
L1E22         fcb   $8F,$50,$43,$00,$8D,$50,$43,$00
L1E2A         fcb   $94,$50,$43,$00,$8F,$50,$43,$00
L1E32         fcb   $8D,$50,$43,$00,$94,$50,$43,$00
L1E3A         fcb   $99,$50,$43,$00,$8F,$50,$43,$00
L1E42         fcb   $94,$50,$43,$00,$8F,$50,$43,$00
L1E4A         fcb   $8D,$50,$43,$00,$94,$50,$43,$00
L1E52         fcb   $8F,$50,$43,$00,$8D,$50,$43,$00
L1E5A         fcb   $94,$50,$43,$00,$95,$50,$43,$00
L1E62         fcb   $9B,$50,$43,$00,$99,$50,$43,$00
L1E6A         fcb   $95,$50,$43,$00,$99,$50,$43,$00
L1E72         fcb   $9B,$50,$43,$00,$8F,$50,$43,$00
L1E7A         fcb   $8D,$50,$94,$BD,$43,$00,$8F,$50
L1E82         fcb   $43,$00,$8D,$50,$43,$00,$94,$50
L1E8A         fcb   $43,$00,$8F,$50,$43,$00,$8D,$50
L1E92         fcb   $43,$00,$94,$50,$43,$00,$99,$50
L1E9A         fcb   $43,$00,$8F,$50,$43,$00,$94,$50
L1EA2         fcb   $43,$00,$8F,$50,$43,$07,$8D,$50
L1EAA         fcb   $43,$00,$94,$50,$43,$00,$8F,$50
L1EB2         fcb   $43,$06,$8D,$50,$43,$00,$94,$50
L1EBA         fcb   $43,$00,$95,$50,$43,$01,$9B,$50
L1EC2         fcb   $43,$00,$99,$50,$43,$06,$95,$50
L1ECA         fcb   $43,$00,$99,$50,$43,$01,$9B,$50
L1ED2         fcb   $43,$01,$8F,$50,$43,$00,$8D,$50
L1EDA         fcb   $00,$01,$40,$88,$BD,$88,$BD,$88
L1EE2         fcb   $BD,$88,$FD,$86,$BD,$88,$FD,$88
L1EEA         fcb   $BD,$88,$FD,$89,$BD,$8B,$FD,$8B
L1EF2         fcb   $BD,$8B,$FD,$81,$BD,$83,$FD,$83
L1EFA         fcb   $BD,$83,$FD,$86,$BD,$88,$BD,$88
L1F02         fcb   $BD,$88,$BD,$88,$FD,$86,$BD,$88
L1F0A         fcb   $FD,$88,$BD,$88,$FD,$81,$BD,$83
L1F12         fcb   $FD,$83,$BD,$83,$FD,$81,$BD,$83
L1F1A         fcb   $FD,$83,$FD,$83,$BD,$86,$BD,$00
L1F22         fcb   $07,$40,$94,$FD,$8D,$BD,$8F,$BD
L1F2A         fcb   $92,$FD,$94,$FD,$8D,$BD,$8F,$BD
L1F32         fcb   $92,$FD,$94,$FD,$8F,$BD,$92,$BD
L1F3A         fcb   $94,$BD,$99,$BD,$97,$BD,$94,$BD
L1F42         fcb   $92,$BD,$94,$BD,$95,$BD,$94,$BD
L1F4A         fcb   $94,$BD,$BE,$BD,$8D,$BD,$8F,$BD
L1F52         fcb   $92,$FD,$94,$BD,$BE,$BD,$8D,$BD
L1F5A         fcb   $8F,$BD,$92,$FD,$94,$FD,$8F,$BD
L1F62         fcb   $92,$BD,$94,$BD,$99,$BD,$97,$BD
L1F6A         fcb   $94,$BD,$92,$BD,$94,$BD,$95,$BD
L1F72         fcb   $94,$BD,$00,$0C,$40,$94,$BD,$43
L1F7A         fcb   $00,$8F,$50,$43,$00,$8D,$50,$43
L1F82         fcb   $00,$94,$50,$43,$00,$8F,$50,$43
L1F8A         fcb   $00,$8D,$50,$43,$00,$94,$50,$43
L1F92         fcb   $00,$99,$50,$43,$00,$8F,$50,$43
L1F9A         fcb   $00,$94,$50,$43,$00,$8F,$50,$43
L1FA2         fcb   $00,$8D,$50,$43,$00,$94,$50,$43
L1FAA         fcb   $00,$8F,$50,$43,$00,$8D,$50,$43
L1FB2         fcb   $00,$94,$50,$43,$00,$95,$50,$43
L1FBA         fcb   $00,$9B,$50,$43,$00,$99,$50,$43
L1FC2         fcb   $00,$95,$50,$43,$00,$99,$50,$43
L1FCA         fcb   $00,$9B,$50,$43,$00,$8F,$50,$43
L1FD2         fcb   $00,$8D,$50,$94,$BD,$43,$00,$8F
L1FDA         fcb   $50,$43,$00,$8D,$50,$43,$00,$94
L1FE2         fcb   $50,$43,$00,$8F,$50,$43,$00,$8D
L1FEA         fcb   $50,$43,$00,$94,$50,$43,$00,$99
L1FF2         fcb   $50,$43,$00,$8F,$50,$43,$00,$94
L1FFA         fcb   $50,$43,$00,$8F,$50,$43,$07,$8D
L2002         fcb   $50,$43,$00,$94,$50,$43,$00,$8F
L200A         fcb   $50,$43,$06,$8D,$50,$43,$00,$94
L2012         fcb   $50,$43,$00,$95,$50,$43,$01,$9B
L201A         fcb   $50,$43,$00,$99,$50,$43,$06,$95
L2022         fcb   $50,$43,$00,$99,$50,$43,$01,$9B
L202A         fcb   $50,$43,$01,$8F,$50,$43,$00,$8D
L2032         fcb   $50,$00,$01,$40,$7C,$FD,$88,$BD
L203A         fcb   $88,$FD,$86,$BD,$7C,$FD,$88,$BD
L2042         fcb   $88,$FD,$89,$BD,$8B,$FD,$8B,$BD
L204A         fcb   $8B,$FD,$81,$BD,$77,$FD,$83,$BD
L2052         fcb   $83,$FD,$86,$BD,$7C,$FD,$88,$BD
L205A         fcb   $88,$FD,$86,$BD,$7C,$BD,$88,$BD
L2062         fcb   $88,$BD,$88,$FD,$81,$BD,$77,$FD
L206A         fcb   $83,$BD,$83,$FD,$81,$BD,$83,$FD
L2072         fcb   $81,$BD,$83,$BD,$86,$BD,$8B,$BD
L207A         fcb   $00,$0B,$40,$94,$BD,$43,$00,$9E
L2082         fcb   $50,$43,$00,$A0,$50,$43,$00,$99
L208A         fcb   $50,$43,$00,$9B,$50,$43,$00,$9E
L2092         fcb   $50,$FE,$BE,$BD,$94,$BD,$43,$00
L209A         fcb   $9B,$50,$43,$00,$92,$50,$43,$00
L20A2         fcb   $9E,$50,$43,$00,$97,$50,$43,$00
L20AA         fcb   $9E,$50,$43,$00,$94,$50,$BE,$BD
L20B2         fcb   $43,$04,$AC,$50,$BE,$BD,$94,$BD
L20BA         fcb   $43,$00,$9E,$50,$43,$00,$A0,$50
L20C2         fcb   $43,$00,$99,$50,$43,$00,$9B,$50
L20CA         fcb   $43,$00,$9E,$50,$94,$BD,$43,$00
L20D2         fcb   $9E,$50,$43,$00,$A0,$50,$43,$00
L20DA         fcb   $99,$50,$43,$00,$9B,$50,$43,$00
L20E2         fcb   $9E,$50,$FE,$BE,$BD,$94,$BD,$43
L20EA         fcb   $00,$9B,$50,$43,$00,$92,$50,$43
L20F2         fcb   $00,$9E,$50,$43,$00,$97,$50,$43
L20FA         fcb   $00,$9E,$50,$43,$00,$7C,$50,$BE
L2102         fcb   $BD,$43,$04,$83,$50,$43,$00,$8D
L210A         fcb   $BD,$8F,$BD,$99,$BD,$9E,$50,$43
L2112         fcb   $00,$A7,$50,$43,$00,$A8,$50,$43
L211A         fcb   $00,$B4,$50,$00,$0C,$40,$94,$BD
L2122         fcb   $43,$00,$8F,$50,$43,$00,$8D,$50
L212A         fcb   $43,$00,$94,$50,$43,$00,$8F,$50
L2132         fcb   $43,$00,$8D,$50,$06,$A0,$BD,$0C
L213A         fcb   $43,$00,$99,$50,$06,$A1,$BD,$0C
L2142         fcb   $43,$00,$94,$50,$06,$A0,$BD,$43
L214A         fcb   $00,$92,$50,$0C,$43,$00,$94,$50
L2152         fcb   $43,$00,$8F,$50,$43,$00,$8D,$50
L215A         fcb   $43,$00,$94,$50,$43,$00,$95,$50
L2162         fcb   $43,$00,$9B,$50,$43,$00,$99,$50
L216A         fcb   $43,$00,$95,$50,$43,$00,$99,$50
L2172         fcb   $43,$00,$9B,$50,$43,$00,$8F,$50
L217A         fcb   $43,$00,$8D,$50,$94,$BD,$43,$00
L2182         fcb   $8F,$50,$43,$00,$8D,$50,$43,$00
L218A         fcb   $94,$50,$43,$00,$8F,$50,$43,$00
L2192         fcb   $8D,$50,$43,$00,$94,$50,$43,$00
L219A         fcb   $99,$50,$43,$00,$8F,$50,$43,$00
L21A2         fcb   $94,$50,$43,$00,$8F,$50,$43,$07
L21AA         fcb   $8D,$50,$06,$43,$00,$92,$50,$43
L21B2         fcb   $00,$BE,$50,$94,$BD,$BE,$BD,$95
L21BA         fcb   $BD,$BE,$BD,$95,$BD,$BE,$BD,$95
L21C2         fcb   $BD,$BE,$BD,$94,$BD,$43,$00,$BE
L21CA         fcb   $50,$00,$01,$40,$7C,$FD,$88,$BD
L21D2         fcb   $88,$FD,$86,$BD,$7C,$FD,$88,$BD
L21DA         fcb   $88,$FD,$89,$BD,$8B,$FD,$8B,$BD
L21E2         fcb   $8B,$FD,$81,$BD,$77,$FD,$83,$BD
L21EA         fcb   $83,$FD,$86,$BD,$7C,$FD,$88,$BD
L21F2         fcb   $88,$FD,$86,$BD,$7C,$BD,$88,$BD
L21FA         fcb   $88,$BD,$88,$FD,$81,$BD,$77,$FD
L2202         fcb   $83,$BD,$83,$FD,$81,$BD,$83,$FD
L220A         fcb   $83,$FD,$83,$BD,$86,$BD,$00,$0B
L2212         fcb   $40,$94,$BD,$43,$00,$9E,$50,$43
L221A         fcb   $00,$A0,$50,$43,$00,$99,$50,$43
L2222         fcb   $00,$9B,$50,$43,$00,$9E,$50,$FE
L222A         fcb   $BE,$BD,$94,$BD,$43,$00,$9B,$50
L2232         fcb   $43,$00,$92,$50,$43,$00,$9E,$50
L223A         fcb   $43,$00,$97,$50,$43,$00,$9E,$50
L2242         fcb   $43,$00,$94,$50,$BE,$BD,$43,$04
L224A         fcb   $AC,$50,$BE,$BD,$94,$BD,$43,$00
L2252         fcb   $9E,$50,$43,$00,$A0,$50,$43,$00
L225A         fcb   $99,$50,$43,$00,$9B,$50,$43,$00
L2262         fcb   $9E,$50,$94,$BD,$43,$00,$9E,$50
L226A         fcb   $43,$00,$A0,$50,$43,$00,$99,$50
L2272         fcb   $43,$00,$9B,$50,$43,$00,$9E,$50
L227A         fcb   $FE,$BE,$BD,$94,$BD,$43,$00,$9B
L2282         fcb   $50,$43,$00,$92,$50,$43,$00,$9E
L228A         fcb   $50,$43,$00,$97,$50,$43,$00,$9E
L2292         fcb   $50,$43,$00,$94,$50,$BE,$BD,$43
L229A         fcb   $04,$B3,$50,$BE,$BD,$A5,$BD,$43
L22A2         fcb   $00,$A1,$50,$43,$00,$A0,$50,$43
L22AA         fcb   $00,$9E,$50,$43,$00,$9B,$50,$43
L22B2         fcb   $00,$9E,$50,$00,$0C,$40,$94,$BD
L22BA         fcb   $43,$00,$8F,$50,$43,$00,$8D,$50
L22C2         fcb   $43,$00,$94,$50,$43,$00,$8F,$50
L22CA         fcb   $43,$00,$8D,$50,$43,$00,$94,$50
L22D2         fcb   $43,$00,$99,$50,$43,$00,$8F,$50
L22DA         fcb   $43,$00,$94,$50,$43,$00,$8F,$50
L22E2         fcb   $43,$00,$8D,$50,$43,$00,$94,$97
L22EA         fcb   $8F,$92,$8D,$8B,$94,$92,$95,$89
L22F2         fcb   $9B,$8F,$99,$50,$43,$00,$95,$50
L22FA         fcb   $43,$00,$99,$50,$43,$00,$9B,$50
L2302         fcb   $43,$00,$8F,$50,$43,$00,$8D,$50
L230A         fcb   $94,$BD,$43,$00,$8F,$50,$43,$00
L2312         fcb   $8D,$50,$43,$00,$94,$50,$43,$00
L231A         fcb   $8F,$50,$43,$00,$8D,$50,$43,$00
L2322         fcb   $94,$50,$43,$00,$99,$50,$43,$00
L232A         fcb   $8F,$50,$43,$00,$94,$50,$43,$00
L2332         fcb   $8F,$50,$43,$07,$8D,$50,$43,$00
L233A         fcb   $94,$50,$43,$00,$8F,$50,$43,$06
L2342         fcb   $8D,$53,$00,$94,$50,$43,$00,$95
L234A         fcb   $50,$43,$01,$9B,$53,$00,$99,$50
L2352         fcb   $43,$06,$95,$53,$00,$99,$50,$43
L235A         fcb   $01,$9B,$53,$00,$43,$01,$8F,$53
L2362         fcb   $00,$8D,$50,$00,$01,$40,$70,$BD
L236A         fcb   $04,$94,$BD,$88,$BD,$94,$FD,$01
L2372         fcb   $6E,$BD,$70,$BD,$04,$94,$BD,$88
L237A         fcb   $BD,$94,$FB,$01,$73,$BD,$04,$88
L2382         fcb   $BD,$94,$FD,$94,$BD,$01,$6E,$BD
L238A         fcb   $04,$88,$BD,$94,$FD,$94,$FD,$94
L2392         fcb   $BD,$01,$70,$BD,$04,$94,$BD,$88
L239A         fcb   $BD,$94,$FD,$01,$6E,$BD,$70,$FD
L23A2         fcb   $04,$88,$BD,$94,$FD,$01,$71,$BD
L23AA         fcb   $43,$00,$73,$50,$04,$88,$BD,$94
L23B2         fcb   $BD,$94,$FD,$94,$BD,$7C,$BD,$01
L23BA         fcb   $73,$BD,$04,$94,$BD,$88,$BD,$01
L23C2         fcb   $6E,$FD,$00,$05,$40,$A0,$BD,$BE
L23CA         fcb   $BD,$A0,$BD,$A0,$BD,$BE,$BD,$9E
L23D2         fcb   $BD,$A0,$BD,$BE,$BD,$A0,$BD,$A0
L23DA         fcb   $BD,$BE,$BD,$9E,$BD,$A3,$BD,$BE
L23E2         fcb   $BD,$A3,$BD,$A3,$BD,$BE,$BD,$9E
L23EA         fcb   $BD,$A3,$BD,$BE,$BD,$A3,$BD,$BE
L23F2         fcb   $BD,$A1,$BD,$9E,$BD,$A0,$FD,$A0
L23FA         fcb   $BD,$A0,$FD,$9E,$BD,$A0,$FD,$A0
L2402         fcb   $BD,$A0,$FD,$9E,$BD,$A3,$FD,$A3
L240A         fcb   $BD,$A3,$FD,$9E,$BD,$A3,$FD,$A3
L2412         fcb   $FD,$A1,$BD,$9E,$BD,$00,$0A,$46
L241A         fcb   $30,$A0,$50,$E4,$02,$46,$30,$A0
L2422         fcb   $50,$FC,$03,$46,$30,$A0,$50,$FE
L242A         fcb   $0A,$43,$00,$A3,$50,$FA,$03,$46
L2432         fcb   $30,$A0,$50,$E4,$02,$46,$30,$A0
L243A         fcb   $50,$FC,$03,$46,$30,$A0,$50,$FE
L2442         fcb   $02,$43,$00,$97,$50,$FA,$00,$01
L244A         fcb   $40,$7C,$BD,$7C,$BD,$7C,$BD,$7C
L2452         fcb   $FD,$7D,$BD,$7F,$FD,$7F,$BD,$BE
L245A         fcb   $BD,$7D,$BD,$7A,$BD,$7C,$BD,$7C
L2462         fcb   $BD,$7C,$BD,$7C,$FD,$7D,$BD,$7F
L246A         fcb   $FD,$7F,$BD,$BE,$BD,$7D,$BD,$7A
L2472         fcb   $BD,$7C,$BD,$7C,$BD,$7C,$BD,$7C
L247A         fcb   $FD,$7D,$BD,$7F,$FD,$7F,$BD,$BE
L2482         fcb   $BD,$7F,$BD,$7A,$BD,$7C,$BD,$7C
L248A         fcb   $BD,$7C,$BD,$7C,$FD,$7D,$BD,$7F
L2492         fcb   $FD,$7F,$BD,$BE,$BD,$7D,$BD,$7A
L249A         fcb   $BD,$00,$09,$40,$6B,$BD,$43,$09
L24A2         fcb   $B3,$50,$43,$09,$AC,$50,$43,$09
L24AA         fcb   $AA,$50,$08,$91,$FD,$97,$FD,$94
L24B2         fcb   $BD,$BE,$FB,$0D,$46,$10,$97,$50
L24BA         fcb   $FE,$46,$10,$94,$50,$09,$64,$BD
L24C2         fcb   $43,$0A,$A3,$50,$43,$09,$A3,$50
L24CA         fcb   $43,$0A,$A0,$50,$43,$09,$A2,$50
L24D2         fcb   $43,$09,$A3,$50,$46,$00,$BE,$50
L24DA         fcb   $FC,$94,$BD,$08,$94,$BD,$BE,$F9
L24E2         fcb   $97,$FD,$94,$BD,$BE,$FB,$56,$10
L24EA         fcb   $50,$0B,$7E,$BD,$43,$00,$BE,$50
L24F2         fcb   $7F,$BD,$46,$10,$BE,$50,$FE,$05
L24FA         fcb   $9B,$FD,$A3,$FD,$9E,$BD,$BE,$BD
L2502         fcb   $00,$01,$40,$70,$FB,$BE,$FD,$71
L250A         fcb   $BD,$43,$00,$73,$50,$FC,$BE,$FD
L2512         fcb   $6E,$BD,$43,$00,$70,$50,$FE,$BE
L251A         fcb   $FB,$71,$BD,$43,$00,$73,$50,$FE
L2522         fcb   $02,$7C,$BD,$BE,$FD,$07,$9E,$BD
L252A         fcb   $01,$70,$FB,$BE,$FD,$71,$BD,$43
L2532         fcb   $00,$73,$50,$FC,$BE,$FD,$6E,$BD
L253A         fcb   $43,$00,$70,$50,$FE,$BE,$FB,$71
L2542         fcb   $BD,$43,$00,$73,$50,$FE,$02,$7C
L254A         fcb   $BD,$BE,$FD,$07,$9E,$BD,$00,$50
L2552         fcb   $FC,$0C,$95,$43,$00,$97,$43,$01
L255A         fcb   $73,$43,$00,$97,$50,$43,$00,$95
L2562         fcb   $86,$88,$40,$BE,$FC,$53,$00,$53
L256A         fcb   $01,$53,$00,$50,$53,$00,$50,$53
L2572         fcb   $00,$53,$01,$53,$00,$50,$53,$00
L257A         fcb   $40,$95,$43,$00,$97,$43,$01,$73
L2582         fcb   $43,$00,$97,$50,$43,$00,$95,$86
L258A         fcb   $88,$40,$BE,$94,$43,$0A,$62,$FA
L2592         fcb   $BE,$BD,$50,$D1,$00,$0C,$40,$94
L259A         fcb   $BD,$43,$00,$8F,$50,$43,$00,$8D
L25A2         fcb   $50,$43,$00,$94,$50,$43,$00,$8F
L25AA         fcb   $50,$43,$00,$8D,$50,$06,$A0,$BD
L25B2         fcb   $0C,$43,$00,$99,$50,$06,$A1,$BD
L25BA         fcb   $0C,$43,$00,$94,$50,$06,$A0,$BD
L25C2         fcb   $43,$00,$92,$50,$0C,$43,$00,$94
L25CA         fcb   $50,$43,$00,$8F,$50,$43,$00,$8D
L25D2         fcb   $50,$43,$00,$94,$50,$43,$00,$95
L25DA         fcb   $50,$43,$00,$9B,$50,$43,$00,$99
L25E2         fcb   $50,$43,$00,$95,$50,$43,$00,$99
L25EA         fcb   $50,$43,$00,$9B,$50,$43,$00,$8F
L25F2         fcb   $50,$43,$00,$8D,$50,$94,$BD,$43
L25FA         fcb   $00,$8F,$50,$43,$00,$8D,$50,$43
L2602         fcb   $00,$94,$50,$43,$00,$8F,$50,$43
L260A         fcb   $00,$8D,$50,$43,$00,$94,$50,$43
L2612         fcb   $00,$99,$50,$43,$00,$8F,$50,$43
L261A         fcb   $00,$94,$50,$43,$00,$8F,$50,$43
L2622         fcb   $07,$8D,$50,$06,$43,$00,$92,$50
L262A         fcb   $FE,$43,$00,$94,$50,$FA,$43,$05
L2632         fcb   $A8,$53,$02,$BD,$53,$00,$50,$F9
L263A         fcb   $00,$01,$40,$70,$FB,$BE,$FD,$71
L2642         fcb   $BD,$43,$00,$73,$50,$FC,$BE,$FD
L264A         fcb   $6E,$BD,$43,$00,$70,$50,$FE,$BE
L2652         fcb   $FB,$71,$BD,$43,$00,$73,$50,$FE
L265A         fcb   $02,$7C,$BD,$BE,$FD,$07,$9E,$BD
L2662         fcb   $01,$70,$FB,$BE,$FD,$71,$BD,$43
L266A         fcb   $00,$73,$50,$FC,$BE,$FD,$0B,$92
L2672         fcb   $BD,$43,$00,$94,$50,$BE,$BD,$9E
L267A         fcb   $BD,$A0,$BD,$BE,$BD,$95,$BD,$43
L2682         fcb   $00,$97,$50,$94,$BE,$F8,$00
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

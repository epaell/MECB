MECB_IO        equ   $E000
SID            equ   MECB_IO+$A0    ; $D400 on C64
LED            equ   MECB_IO+$C1
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
;timer_LSB       equ     $E7          ; 1 mS at 1 MHz
;timer_MSB       equ     $03
timer_LSB       equ     $0C          ; 20 mS at 1 MHz (50 Hz)
timer_MSB       equ     $4E
;timer_LSB       equ     $74          ; 16.67 mS at 1 MHz (60 Hz)
;timer_MSB       equ     $40
;

              org   $0f82
;
; SID header
;
L0F82         fcb   $50,$53,$49,$44,$00,$02,$00,$7C
L0F8A         fcb   $00,$00,$10,$00,$10,$03,$00,$01
L0F92         fcb   $00,$01,$00,$00,$00,$00,$50,$6F
L0F9A         fcb   $70,$63,$6F,$72,$6E,$00,$00,$00
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
sid_init      JMP L1080
sid_play      JMP L1084
L1006         LDA $1467,Y
              JMP L1013
              TAY
              LDA #$00
              STA $1358,X
              TYA
L1013         STA $132F,X
              LDA $131E,X
              STA $132E,X
              RTS
              LDY #$00
              STY $10BF
L1022         STA $10BB
              RTS
              STA $1109
              BEQ L1022
              RTS
              STA $1345
              STA $134C
              STA $1353
              RTS
L1036         DEC $1359,X
L1039         JMP L121C
L103C         BEQ L1039
              LDA $1359,X
              BNE L1036
              LDA #$00
              STA $EF
              LDA $1358,X
              BMI L1055
              CMP $1548,Y
              BCC L1056
              BEQ L1055
              EOR #$FF
L1055         CLC
L1056         ADC #$02
              STA $1358,X
              LSR A
              BCC L1060
              BCS L1070
L1060         LDA $135B,X
              ADC $EE
              STA $135B,X
              LDA $135C,X
              ADC $EF
              JMP L1219
L1070         LDA $135B,X
              SBC $EE
              STA $135B,X
              LDA $135C,X
              SBC $EF
              JMP L1219
L1080         STA $1087
              RTS
L1084         LDX #$00
              LDY #$00
              BMI L10BA
              TXA
              LDX #$29
L108D         STA $1319,X
              DEX
              BPL L108D
              STA SID+$15
              STA $1109
              STA $10BB
              STX $1087
              TAX
              JSR L10AA
              LDX #$07
              JSR L10AA
              LDX #$0E
L10AA         LDA #$05
              STA $1345,X
              LDA #$01
              STA $1346,X
              STA $1348,X
              JMP L12FA
L10BA         LDY #$00
              BEQ L1103
              LDA #$00
              BNE L10E5
              LDA $1519,Y
              BEQ L10D9
              BPL L10E2
              ASL A
              STA $110E
              LDA $1530,Y
              STA $1109
              LDA $151A,Y
              BNE L10F7
              INY
L10D9         LDA $1530,Y
              STA $1104
              JMP L10F4
L10E2         STA $10BF
L10E5         LDA $1530,Y
              CLC
              ADC $1104
              STA $1104
              DEC $10BF
              BNE L1105
L10F4         LDA $151A,Y
L10F7         CMP #$FF
              INY
              TYA
              BCC L1100
              LDA $1530,Y
L1100         STA $10BB
L1103         LDA #$00
L1105         STA SID+$16
              LDA #$00
              STA SID+$17
              LDA #$00
              ORA #$0F
              STA SID+$18
              JSR L111E
              LDX #$07
              JSR L111E
              LDX #$0E
L111E         DEC $1346,X
              BEQ L112E
              BPL L112B
              LDA $1345,X
              STA $1346,X
L112B         JMP L11C8
L112E         LDY $131E,X
              LDA $1304,Y
              STA $11BD
              STA $11C6
              LDA $131C,X
              BNE L1163
              LDY $1343,X
              LDA $1415,Y
              STA $EE
              LDA $1418,Y
              STA $EF
              LDY $1319,X
              LDA ($EE),Y
              CMP #$FF
              BCC L115B
              INY
              LDA ($EE),Y
              TAY
              LDA ($EE),Y
L115B         STA $1344,X
              INY
              TYA
              STA $1319,X
L1163         LDY $1348,X
              LDA $1330,X
              BEQ L11C2
              SEC
              SBC #$60
              STA $1347,X
              LDA #$00
              STA $132E,X
              STA $1330,X
              LDA $1470,Y
              STA $1359,X
              LDA $1467,Y
              STA $132F,X
              LDA #$09
              STA $1332,X
              INC $1349,X
              LDA $1455,Y
              BEQ L119A
              STA $1333,X
              LDA #$00
              STA $1334,X
L119A         LDA $145E,Y
              BEQ L11A7
              STA $10BB
              LDA #$00
              STA $10BF
L11A7         LDA $144C,Y
              STA $1331,X
              LDA $1443,Y
              STA SID+$06,X
              LDA $143A,Y
              STA SID+$05,X
              LDA $131F,X
              JSR L1006
              JMP L12FA
L11C2         LDA $131F,X
              JSR L1006
L11C8         LDY $1331,X
              BEQ L11EA
              LDA $1479,Y
              BEQ L11D5
              STA $1332,X
L11D5         LDA $147A,Y
              CMP #$FF
              INY
              TYA
              BCC L11E2
              CLC
              LDA $14A6,Y
L11E2         STA $1331,X
              LDA $14A5,Y
              BNE L1203
L11EA         LDA $1346,X
              BEQ L121F
              LDY $132E,X
              LDA $1314,Y
              STA $1201
              LDY $132F,X
              LDA $154F,Y
              STA $EE
              JMP L103C
L1203         BPL L120A
              ADC $1347,X
              AND #$7F
L120A         TAY
              LDA #$00
              STA $1358,X
              LDA $1361,Y
              STA $135B,X
              LDA $13B5,Y
L1219         STA $135C,X
L121C         LDA $1346,X
L121F         CMP #$02
              BEQ L127D
              LDY $1333,X
              BEQ L127A
              ORA $131C,X
              BEQ L127A
              LDA $1334,X
              BNE L1246
              LDA $14D3,Y
              BPL L1243
              STA $135E,X
              LDA $14F6,Y
              STA $135D,X
              JMP L125F
L1243         STA $1334,X
L1246         LDA $14F6,Y
              CLC
              BPL L124F
              DEC $135E,X
L124F         ADC $135D,X
              STA $135D,X
              BCC L125A
              INC $135E,X
L125A         DEC $1334,X
              BNE L1271
L125F         LDA $14D4,Y
              CMP #$FF
              INY
              TYA
              BCC L126B
              LDA $14F6,Y
L126B         STA $1333,X
              LDA $135D,X
L1271         STA SID+$02,X
              LDA $135E,X
              STA SID+$03,X
L127A         JMP L12EE
L127D         LDY $1344,X
              LDA $141B,Y
              STA $EE
              LDA $142B,Y
              STA $EF
              LDY $131C,X
              LDA ($EE),Y
              CMP #$40
              BCC L12AB
              CMP #$60
              BCC L12B5
              CMP #$C0
              BCC L12C9
              LDA $131D,X
              BNE L12A2
              LDA ($EE),Y
L12A2         ADC #$00
              STA $131D,X
              BEQ L12E5
              BNE L12EE
L12AB         STA $1348,X
              INY
              LDA ($EE),Y
              CMP #$60
              BCS L12C9
L12B5         CMP #$50
              AND #$0F
              STA $131E,X
              BEQ L12C4
              INY
              LDA ($EE),Y
              STA $131F,X
L12C4         BCS L12E5
              INY
              LDA ($EE),Y
L12C9         CMP #$BD
              BCC L12D3
              BEQ L12E5
              ORA #$F0
              BNE L12E2
L12D3         STA $1330,X
              LDA #$00
              STA SID+$06,X
              LDA #$0F
              STA SID+$05,X
              LDA #$FE
L12E2         STA $1349,X
L12E5         INY
              LDA ($EE),Y
              BEQ L12EB
              TYA
L12EB         STA $131C,X
L12EE         LDA $135B,X
              STA SID+$00,X
              LDA $135C,X
              STA SID+$01,X
L12FA         LDA $1332,X
              AND $1349,X
              STA SID+$04,X
              RTS
;
L1304         fcb   $06,$0C,$0C,$13,$13,$1D
L130A         fcb   $1D,$1D,$1D,$1D,$1D,$26,$2C,$2C
L1312         fcb   $2C,$2C,$3C,$60,$60,$60,$43,$00
L131A         fcb   $00,$00,$00,$00,$00,$00,$00,$00
L1322         fcb   $00,$00,$00,$00,$00,$00,$00,$00
L132A         fcb   $00,$00,$00,$00,$00,$00,$00,$00
L1332         fcb   $00,$00,$00,$00,$00,$00,$00,$00
L133A         fcb   $00,$00,$00,$00,$00,$00,$00,$00
L1342         fcb   $00,$00,$00,$00,$00,$00,$01,$FE
L134A         fcb   $01,$00,$00,$00,$00,$01,$FE,$02
L1352         fcb   $00,$00,$00,$00,$01,$FE,$00,$00
L135A         fcb   $00,$00,$00,$00,$00,$00,$00,$00
L1362         fcb   $00,$00,$00,$00,$00,$00,$00,$00
L136A         fcb   $00,$00,$00,$2D,$4E,$71,$96,$BE
L1372         fcb   $E8,$14,$43,$74,$A9,$E1,$1C,$5A
L137A         fcb   $9C,$E2,$2D,$7C,$CF,$28,$85,$E8
L1382         fcb   $52,$C1,$37,$B4,$39,$C5,$5A,$F7
L138A         fcb   $9E,$4F,$0A,$D1,$A3,$82,$6E,$68
L1392         fcb   $71,$8A,$B3,$EE,$3C,$9E,$15,$A2
L139A         fcb   $46,$04,$DC,$D0,$E2,$14,$67,$DD
L13A2         fcb   $79,$3C,$29,$44,$8D,$08,$B8,$A1
L13AA         fcb   $C5,$28,$CD,$BA,$F1,$78,$53,$87
L13B2         fcb   $1A,$10,$71,$42,$89,$4F,$9B,$74
L13BA         fcb   $E2,$F0,$A6,$0E,$33,$20,$FF,$02
L13C2         fcb   $02,$02,$02,$02,$02,$03,$03,$03
L13CA         fcb   $03,$03,$04,$04,$04,$04,$05,$05
L13D2         fcb   $05,$06,$06,$06,$07,$07,$08,$08
L13DA         fcb   $09,$09,$0A,$0A,$0B,$0C,$0D,$0D
L13E2         fcb   $0E,$0F,$10,$11,$12,$13,$14,$15
L13EA         fcb   $17,$18,$1A,$1B,$1D,$1F,$20,$22
L13F2         fcb   $24,$27,$29,$2B,$2E,$31,$34,$37
L13FA         fcb   $3A,$3E,$41,$45,$49,$4E,$52,$57
L1402         fcb   $5C,$62,$68,$6E,$75,$7C,$83,$8B
L140A         fcb   $93,$9C,$A5,$AF,$B9,$C4,$D0,$DD
L1412         fcb   $EA,$F8,$FF,$56,$63,$70,$15,$15
L141A         fcb   $15,$7D,$C1,$07,$83,$E6,$F5,$38
L1422         fcb   $7B,$BE,$01,$20,$3F,$73,$D3,$33
L142A         fcb   $76,$15,$15,$16,$16,$16,$16,$17
L1432         fcb   $17,$17,$18,$18,$18,$18,$18,$19
L143A         fcb   $19,$00,$00,$0D,$00,$00,$08,$00
L1442         fcb   $00,$00,$DD,$CC,$B9,$F9,$F6,$A9
L144A         fcb   $F9,$F9,$DC,$01,$03,$06,$0F,$14
L1452         fcb   $01,$1E,$26,$01,$01,$06,$0B,$10
L145A         fcb   $12,$18,$1F,$1F,$01,$16,$00,$01
L1462         fcb   $00,$00,$00,$00,$00,$00,$01,$02
L146A         fcb   $03,$00,$00,$05,$06,$06,$01,$0F
L1472         fcb   $0F,$1F,$00,$00,$0F,$2F,$2F,$0F
L147A         fcb   $41,$FF,$41,$40,$FF,$81,$41,$00
L1482         fcb   $00,$00,$00,$00,$00,$FF,$81,$41
L148A         fcb   $41,$80,$FF,$81,$11,$11,$11,$11
L1492         fcb   $11,$11,$11,$10,$FF,$21,$20,$20
L149A         fcb   $20,$20,$20,$20,$FF,$21,$20,$20
L14A2         fcb   $20,$20,$20,$20,$FF,$80,$00,$20
L14AA         fcb   $80,$00,$5F,$8C,$8A,$86,$84,$82
L14B2         fcb   $81,$80,$00,$5F,$2E,$2D,$5C,$00
L14BA         fcb   $5F,$28,$22,$1E,$1A,$18,$16,$15
L14C2         fcb   $14,$1C,$80,$83,$83,$87,$87,$80
L14CA         fcb   $80,$1F,$80,$84,$84,$87,$87,$80
L14D2         fcb   $80,$27,$8E,$08,$10,$10,$FF,$87
L14DA         fcb   $18,$18,$08,$FF,$88,$05,$20,$20
L14E2         fcb   $FF,$88,$FF,$80,$FF,$02,$16,$16
L14EA         fcb   $FF,$8A,$FF,$03,$02,$16,$16,$FF
L14F2         fcb   $81,$78,$30,$38,$FF,$00,$C0,$20
L14FA         fcb   $E0,$03,$00,$F0,$10,$F0,$07,$00
L1502         fcb   $20,$FE,$02,$0D,$00,$00,$80,$00
L150A         fcb   $20,$30,$D0,$15,$00,$1A,$40,$20
L1512         fcb   $30,$D0,$1C,$00,$10,$10,$F0,$14
L151A         fcb   $A8,$00,$00,$00,$00,$00,$00,$00
L1522         fcb   $00,$10,$10,$FF,$98,$00,$10,$10
L152A         fcb   $14,$10,$24,$20,$FF,$80,$FF,$C1
L1532         fcb   $E0,$70,$40,$10,$08,$06,$04,$03
L153A         fcb   $04,$FC,$0A,$F1,$50,$FD,$FF,$01
L1542         fcb   $FF,$02,$FE,$00,$00,$00,$00,$02
L154A         fcb   $08,$02,$03,$02,$02,$00,$30,$08
L1552         fcb   $08,$30,$10,$20,$00,$00,$00,$01
L155A         fcb   $01,$00,$00,$02,$02,$03,$03,$FF
L1562         fcb   $00,$04,$05,$06,$07,$08,$05,$06
L156A         fcb   $09,$09,$0A,$0A,$FF,$00,$0B,$0C
L1572         fcb   $0C,$0D,$0D,$0C,$0C,$0E,$0E,$0F
L157A         fcb   $0F,$FF,$00,$02,$4F,$05,$78,$50
L1582         fcb   $84,$7F,$78,$BD,$84,$7F,$78,$BD
L158A         fcb   $84,$7F,$78,$7B,$7F,$84,$78,$BD
L1592         fcb   $84,$7D,$78,$BD,$84,$7F,$78,$BD
L159A         fcb   $84,$7F,$78,$7B,$7F,$84,$78,$BD
L15A2         fcb   $84,$7D,$78,$BD,$84,$7F,$76,$BD
L15AA         fcb   $82,$7B,$76,$BD,$82,$7B,$74,$BD
L15B2         fcb   $80,$79,$74,$BD,$80,$7B,$78,$BD
L15BA         fcb   $84,$7F,$78,$7B,$82,$84,$00,$02
L15C2         fcb   $4F,$05,$7B,$50,$87,$82,$7B,$BD
L15CA         fcb   $87,$82,$7B,$BD,$87,$82,$7B,$7F
L15D2         fcb   $82,$87,$7B,$BD,$87,$7F,$7B,$BD
L15DA         fcb   $87,$82,$7B,$BD,$87,$82,$7B,$7F
L15E2         fcb   $82,$87,$06,$7F,$BD,$8B,$86,$7F
L15EA         fcb   $BD,$8B,$86,$7D,$BD,$89,$84,$7D
L15F2         fcb   $BD,$89,$84,$7B,$BD,$87,$82,$7B
L15FA         fcb   $BD,$87,$82,$02,$7B,$BD,$87,$82
L1602         fcb   $7B,$7F,$82,$87,$00,$05,$4F,$05
L160A         fcb   $78,$02,$40,$78,$84,$7F,$04,$4B
L1612         fcb   $00,$78,$02,$40,$78,$84,$7F,$05
L161A         fcb   $78,$02,$78,$84,$7F,$04,$4B,$00
L1622         fcb   $78,$02,$40,$78,$7F,$84,$05,$78
L162A         fcb   $02,$78,$84,$7D,$04,$4B,$00,$78
L1632         fcb   $02,$40,$78,$84,$7F,$05,$78,$02
L163A         fcb   $78,$84,$7F,$04,$4B,$00,$78,$02
L1642         fcb   $40,$78,$7F,$84,$05,$78,$02,$78
L164A         fcb   $84,$7D,$04,$4B,$00,$78,$02,$40
L1652         fcb   $78,$84,$7F,$05,$76,$02,$76,$82
L165A         fcb   $7B,$04,$4B,$00,$76,$02,$40,$76
L1662         fcb   $82,$7B,$05,$74,$02,$74,$80,$79
L166A         fcb   $04,$4B,$00,$74,$02,$40,$74,$80
L1672         fcb   $7B,$05,$78,$02,$78,$84,$7F,$04
L167A         fcb   $4B,$00,$78,$02,$40,$78,$82,$84
L1682         fcb   $00,$03,$4F,$05,$6F,$50,$02,$7B
L168A         fcb   $76,$04,$6F,$BD,$02,$7B,$76,$03
L1692         fcb   $6F,$BD,$02,$7B,$76,$04,$6F,$BD
L169A         fcb   $02,$76,$7B,$03,$6F,$BD,$02,$7B
L16A2         fcb   $73,$04,$6F,$BD,$02,$7B,$76,$03
L16AA         fcb   $6F,$BD,$02,$7B,$76,$04,$6F,$BD
L16B2         fcb   $02,$76,$7B,$03,$73,$BD,$06,$7F
L16BA         fcb   $7A,$04,$73,$BD,$06,$7F,$7A,$03
L16C2         fcb   $71,$BD,$06,$7D,$78,$04,$71,$BD
L16CA         fcb   $06,$7D,$78,$03,$6F,$BD,$06,$7B
L16D2         fcb   $76,$04,$6F,$BD,$06,$7B,$76,$03
L16DA         fcb   $6F,$BD,$02,$7B,$76,$04,$6F,$BD
L16E2         fcb   $02,$76,$7B,$00,$4A,$0D,$BE,$50
L16EA         fcb   $E2,$5A,$0D,$50,$E6,$06,$9C,$BE
L16F2         fcb   $9A,$BD,$00,$06,$4A,$0D,$9C,$40
L16FA         fcb   $BE,$97,$BE,$93,$97,$BE,$90,$BE
L1702         fcb   $FD,$9C,$BE,$9A,$BE,$9C,$BE,$97
L170A         fcb   $BE,$93,$97,$BE,$90,$BE,$FD,$9C
L1712         fcb   $BE,$9E,$BE,$4A,$0D,$9F,$40,$BE
L171A         fcb   $9E,$9F,$BE,$9F,$BE,$9C,$9E,$BE
L1722         fcb   $9C,$9E,$BE,$9E,$BE,$9A,$9C,$BE
L172A         fcb   $9A,$9C,$BE,$9C,$BE,$98,$9C,$BE
L1732         fcb   $FE,$9C,$BE,$9A,$BE,$00,$06,$4A
L173A         fcb   $0D,$9C,$40,$BE,$97,$BE,$93,$97
L1742         fcb   $BE,$90,$BE,$FD,$9C,$BE,$9A,$BE
L174A         fcb   $9C,$BE,$97,$BE,$93,$97,$BE,$90
L1752         fcb   $BE,$FD,$9C,$BE,$9E,$BE,$4A,$0D
L175A         fcb   $9F,$40,$BE,$9E,$9F,$BE,$9F,$BE
L1762         fcb   $9C,$9E,$BE,$9C,$9E,$BE,$9E,$BE
L176A         fcb   $9A,$9C,$BE,$9A,$9C,$BE,$9C,$BE
L1772         fcb   $9E,$9F,$BE,$FE,$A3,$BE,$A1,$BE
L177A         fcb   $00,$06,$4A,$0D,$A3,$40,$BE,$9F
L1782         fcb   $BE,$9A,$9F,$BE,$97,$BE,$FD,$A3
L178A         fcb   $BE,$A1,$BE,$A3,$BE,$9F,$BE,$9A
L1792         fcb   $9F,$BE,$97,$BE,$FD,$A3,$BE,$A5
L179A         fcb   $BE,$4A,$0D,$A6,$40,$BE,$A5,$A6
L17A2         fcb   $BE,$A6,$BE,$A3,$A5,$BE,$A3,$A5
L17AA         fcb   $BE,$A5,$BE,$A1,$A3,$BE,$A1,$A3
L17B2         fcb   $BE,$A3,$BE,$9F,$A3,$BE,$FE,$A3
L17BA         fcb   $BE,$A1,$BE,$00,$06,$4A,$0D,$A3
L17C2         fcb   $40,$BE,$9F,$BE,$9A,$9F,$BE,$97
L17CA         fcb   $BE,$FD,$A3,$BE,$A1,$BE,$A3,$BE
L17D2         fcb   $9F,$BE,$9A,$9F,$BE,$97,$BE,$FD
L17DA         fcb   $A3,$BE,$A5,$BE,$4A,$0D,$A6,$40
L17E2         fcb   $BE,$A5,$A6,$BE,$A6,$BE,$A3,$A5
L17EA         fcb   $BE,$A3,$A5,$BE,$A5,$BE,$A1,$A3
L17F2         fcb   $BE,$A1,$A3,$BE,$A3,$BE,$9F,$A3
L17FA         fcb   $BE,$FE,$A3,$BE,$A1,$BE,$00,$09
L1802         fcb   $40,$93,$F7,$BE,$FD,$92,$BD,$93
L180A         fcb   $FD,$90,$FB,$BE,$BD,$93,$BD,$95
L1812         fcb   $BD,$97,$FB,$BE,$BD,$95,$FB,$BE
L181A         fcb   $BD,$93,$F7,$BE,$FB,$00,$09,$40
L1822         fcb   $97,$F7,$BE,$FD,$95,$BD,$97,$FD
L182A         fcb   $93,$FB,$BE,$BD,$97,$BD,$99,$BD
L1832         fcb   $9A,$FB,$BE,$BD,$99,$FB,$BE,$BD
L183A         fcb   $97,$F7,$BE,$FB,$00,$05,$40,$6C
L1842         fcb   $FD,$04,$78,$FD,$05,$6C,$FD,$04
L184A         fcb   $78,$FD,$05,$6C,$FD,$04,$78,$FD
L1852         fcb   $05,$9C,$FD,$04,$78,$FD,$05,$6C
L185A         fcb   $FD,$04,$78,$FD,$05,$6C,$FD,$04
L1862         fcb   $78,$FD,$05,$6C,$FD,$04,$78,$FD
L186A         fcb   $05,$6C,$04,$78,$FE,$78,$FE,$78
L1872         fcb   $00,$05,$40,$6C,$BD,$07,$9C,$BD
L187A         fcb   $04,$78,$BD,$07,$9C,$BD,$05,$6C
L1882         fcb   $BD,$07,$9C,$9C,$04,$78,$BD,$07
L188A         fcb   $9C,$BD,$05,$6C,$BD,$07,$9C,$BD
L1892         fcb   $04,$78,$BD,$07,$9C,$BD,$05,$9C
L189A         fcb   $BD,$07,$9C,$9C,$04,$78,$BD,$07
L18A2         fcb   $9C,$BD,$05,$6C,$BD,$07,$9C,$BD
L18AA         fcb   $04,$78,$BD,$07,$9C,$BD,$05,$6C
L18B2         fcb   $BD,$08,$9A,$BD,$04,$78,$BD,$08
L18BA         fcb   $9A,$BD,$05,$6C,$BD,$08,$98,$98
L18C2         fcb   $04,$78,$BD,$08,$98,$BD,$05,$6C
L18CA         fcb   $04,$78,$78,$BD,$78,$BD,$78,$BD
L18D2         fcb   $00,$05,$40,$6C,$BD,$08,$9F,$BD
L18DA         fcb   $04,$78,$BD,$08,$9F,$BD,$05,$6C
L18E2         fcb   $BD,$08,$9F,$9F,$04,$78,$BD,$08
L18EA         fcb   $9F,$BD,$05,$6C,$BD,$08,$9F,$BD
L18F2         fcb   $04,$78,$BD,$08,$9F,$BD,$05,$9C
L18FA         fcb   $BD,$08,$9F,$9F,$04,$78,$BD,$08
L1902         fcb   $9F,$BD,$05,$6C,$BD,$08,$9A,$BD
L190A         fcb   $04,$78,$BD,$08,$9A,$BD,$05,$6C
L1912         fcb   $BD,$07,$98,$BD,$04,$78,$BD,$07
L191A         fcb   $98,$BD,$05,$6C,$BD,$08,$9F,$BD
L1922         fcb   $04,$78,$BD,$08,$9F,$BD,$05,$6C
L192A         fcb   $04,$78,$78,$BD,$78,$BD,$78,$BD
L1932         fcb   $00,$06,$40,$90,$93,$97,$93,$97
L193A         fcb   $9C,$97,$9C,$9F,$9C,$9F,$A3,$9F
L1942         fcb   $A3,$A8,$A3,$A8,$A3,$9F,$A3,$9F
L194A         fcb   $9C,$97,$9C,$97,$93,$97,$93,$90
L1952         fcb   $93,$90,$8B,$90,$93,$97,$93,$97
L195A         fcb   $9C,$97,$9C,$9F,$A3,$A6,$A3,$A6
L1962         fcb   $A8,$A6,$A3,$98,$9C,$A4,$9C,$A4
L196A         fcb   $A8,$A4,$A8,$A3,$9F,$9C,$9F,$9C
L1972         fcb   $97,$9C,$97,$00,$06,$40,$93,$97
L197A         fcb   $9A,$97,$9A,$9F,$9A,$9F,$A3,$9F
L1982         fcb   $A3,$A6,$A3,$A6,$AB,$A6,$AB,$AF
L198A         fcb   $AB,$A6,$AB,$A6,$A3,$A6,$A3,$9F
L1992         fcb   $A3,$9F,$9A,$9F,$9A,$9F,$97,$9A
L199A         fcb   $9E,$9A,$9E,$A3,$9E,$A3,$A1,$A8
L19A2         fcb   $AD,$A8,$A1,$A8,$A1,$9C,$9F,$A6
L19AA         fcb   $AB,$A6,$AB,$B2,$AB,$A6,$9F,$A6
L19B2         fcb   $9F,$9A,$9F,$9A,$93,$9A,$00
;
                ORG     $6000
;
start           ldx     #(isr&$FF)       ; Set up IRQ vector in SMON
                stx     IRQ_LO
                ldx     #(isr>>8)
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
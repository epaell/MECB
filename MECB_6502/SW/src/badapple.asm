               CPU   W65C02S
;
MECB_IO        equ   $E000
SID            equ   MECB_IO+$A0
LED            equ   MECB_IO+$C1
;SID            equ   $D400
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
; https://www.masswerk.at/6502/disassembler.html
;
; Header information
;
              org    $0F82
;
L0F82         fcb   $50,$53,$49,$44,$00,$02,$00,$7C
L0F8A         fcb   $00,$00,$10,$00,$10,$03,$00,$01
L0F92         fcb   $00,$01,$00,$00,$00,$00,$42,$61
L0F9A         fcb   $64,$20,$41,$70,$70,$6C,$65,$00
L0FA2         fcb   $00,$00,$00,$00,$00,$00,$00,$00
L0FAA         fcb   $00,$00,$00,$00,$00,$00,$00,$00
L0FB2         fcb   $00,$00,$00,$00,$00,$00,$75,$6B
L0FBA         fcb   $69,$6D,$65,$6E,$75,$73,$74,$61
L0FC2         fcb   $68,$00,$00,$00,$00,$00,$00,$00
L0FCA         fcb   $00,$00,$00,$00,$00,$00,$00,$00
L0FD2         fcb   $00,$00,$00,$00,$00,$00,$32,$30
L0FDA         fcb   $31,$32,$20,$75,$6B,$69,$6D,$65
L0FE2         fcb   $6E,$75,$73,$74,$61,$68,$00,$00
L0FEA         fcb   $00,$00,$00,$00,$00,$00,$00,$00
L0FF2         fcb   $00,$00,$00,$00,$00,$00,$00,$14
L0FFA         fcb   $00,$00,$00,$00,$00,$10
;
              org $1000
;
sid_init      JMP L107D
sid_play      JMP L1085
;
              JMP L1081
;
L1009         LDA M15C2,Y
              JMP L1016
              TAY
              LDA #$00
              STA M146D,X
              TYA
L1016         STA M141A,X
              LDA $13F4,X
              STA M1419,X
              RTS
;
              STA M1445
              STA M144C
              STA M1453
              STA M145A
              STA M1461
              STA M1468
              RTS
;
L1033         DEC M146E,X
L1036         JMP L12B4
L1039         BEQ L1036
              LDA M146E,X
              BNE L1033
              LDA #$00
              STA $FE
              LDA M146D,X
              BMI L1052
              CMP M160D,Y
              BCC L1053
              BEQ L1052
              EOR #$FF
L1052         CLC
L1053         ADC #$02
              STA M146D,X
              LSR A
              BCC L105D
              BCS L106D
L105D         LDA M1470,X
              ADC $FD
              STA M1470,X
              LDA M1471,X
              ADC $FE
              JMP L12B1
L106D         LDA M1470,X
              SBC $FD
              STA M1470,X
              LDA M1471,X
              SBC $FE
              JMP L12B1
L107D         STA M1087+1
              RTS
;
L1081         STA M112F+1
              RTS
;
L1085         LDX #$00
M1087         LDY #$00
              BMI M10DA
              TXA
              LDX #$53
L108E         STA $13EF,X
              DEX
              BPL L108E
              STA SID+$15
              BIT M113F+1
              STA M1128+1
              STA M1182+1
              STA M10DA+1
              STA M1134+1
              STX M1087+1
              TAX
              JSR L10C3
              LDX #$07
              JSR L10C3
              LDX #$0E
              JSR L10C3
              LDX #$15
              JSR L10C3
              LDX #$1C
              JSR L10C3
              LDX #$23
L10C3         LDA #$05
              STA M1445,X
              LDA #$01
              STA M1446,X
              STA M1448,X
              CPX #$15
              BCS L10D7
              JMP L13A2
L10D7         JMP L13D0
M10DA         LDY #$00
              BEQ M1123
M10DE         LDA #$00
              BNE L1105
              LDA M1600,Y
              BEQ L10F9
              BPL L1102
              ASL A
              STA M112D+1
              LDA M1606,Y
              STA M1128+1
              LDA M1601,Y
              BNE L1117
              INY
L10F9         LDA M1606,Y
              STA M1123+1
              JMP L1114
L1102         STA M10DE+1
L1105         LDA M1606,Y
              CLC
              ADC M1123+1
              STA M1123+1
              DEC M10DE+1
              BNE L1125
L1114         LDA M1601,Y
L1117         CMP #$FF
              INY
              TYA
              BCC L1120
              LDA M1606,Y
L1120         STA M10DA+1
M1123         LDA #$00
L1125         STA SID+$16
M1128         LDA #$00
              STA SID+$17
M112D         LDA #$00
M112F         ORA #$0F
              STA SID+$18
M1134         LDY #$00
              BEQ M117D
M1138         LDA #$00
              BNE L115F
              LDA M1600,Y
M113F         BEQ L1153
              BPL L115C
              ASL A
              STA M1187+1
              LDA M1606,Y
              STA M1182+1
              LDA M1601,Y
              BNE L1171
              INY
L1153         LDA M1606,Y
              STA M117D+1
              JMP L116E
L115C         STA M1138+1
L115F         LDA M1606,Y
              CLC
              ADC M117D+1
              STA M117D+1
              DEC M1138+1
              BNE L117F
L116E         LDA M1601,Y
L1171         CMP #$FF
              INY
              TYA
              BCC L117A
              LDA M1606,Y
L117A         STA M1134+1
M117D         LDA #$00
L117F         BIT M113F+1
M1182         LDA #$00
              BIT M113F+1
M1187         LDA #$00
              ORA M112F+1
              BIT M113F+1
              JSR L11A8
              LDX #$07
              JSR L11A8
              LDX #$0E
              JSR L11A8
              LDX #$15
              JSR L11A8
              LDX #$1C
              JSR L11A8
              LDX #$23
L11A8         DEC M1446,X
              BEQ L11B8
              BPL L11B5
              LDA M1445,X
              STA M1446,X
L11B5         JMP L1260
L11B8         LDY $13F4,X
              LDA $13DA,Y
              STA M1254+1
              STA M125D+1
              LDA $13F2,X
              BNE L11ED
              LDY M1443,X
              LDA M1567,Y
              STA $FD
              LDA M156D,Y
              STA $FE
              LDY $13EF,X
              LDA ($FD),Y
              CMP #$FF
              BCC L11E5
              INY
              LDA ($FD),Y
              TAY
              LDA ($FD),Y
L11E5         STA M1444,X
              INY
              TYA
              STA $13EF,X
L11ED         LDY M1448,X
              LDA M141B,X
              BEQ L125A
              SEC
              SBC #$60
              STA M1447,X
              LDA #$00
              STA M1419,X
              STA M141B,X
              LDA M15C8,Y
              STA M146E,X
              LDA M15C2,Y
              STA M141A,X
              LDA #$09
              STA M141D,X
              INC M1449,X
              LDA M15B6,Y
              BEQ L1224
              STA M141E,X
              LDA #$00
              STA M141F,X
L1224         CPX #$15
              LDA M15BC,Y
              BEQ L123F
              BCS L1237
              STA M10DA+1
              LDA #$00
              STA M10DE+1
              BCC L123F
L1237         STA M1134+1
              LDA #$00
              STA M1138+1
L123F         LDA M15B0,Y
              STA M141C,X
              LDA M15A4,Y
              STA M1497,X
              LDA M15AA,Y
              STA M1498,X
              LDA $13F5,X
M1254         JSR L1009
              JMP L137A
L125A         LDA $13F5,X
M125D         JSR L1009
L1260         LDY M141C,X
              BEQ L1282
              LDA M15CE,Y
              BEQ L126D
              STA M141D,X
L126D         LDA M15CF,Y
              CMP #$FF
              INY
              TYA
              BCC L127A
              CLC
              LDA M15DD,Y
L127A         STA M141C,X
              LDA M15DC,Y
              BNE L129B
L1282         LDA M1446,X
              BEQ L12B7
              LDY M1419,X
              LDA $13EA,Y
              STA L1298+1
              LDY M141A,X
              LDA M160F,Y
              STA $FD
L1298         JMP L1039
L129B         BPL L12A2
              ADC M1447,X
              AND #$7F
L12A2         TAY
              LDA #$00
              STA M146D,X
              LDA M14B6,Y
              STA M1470,X
              LDA M1509,Y
L12B1         STA M1471,X
L12B4         LDA M1446,X
L12B7         CMP #$02
              BEQ L1309
              LDY M141E,X
              BEQ L1306
              ORA $13F2,X
              BEQ L1306
              LDA M141F,X
              BNE L12DE
              LDA M15EC,Y
              BPL L12DB
              STA M1473,X
              LDA M15F6,Y
              STA M1472,X
              JMP L12F7
L12DB         STA M141F,X
L12DE         LDA M15F6,Y
              CLC
              BPL L12E7
              DEC M1473,X
L12E7         ADC M1472,X
              STA M1472,X
              BCC L12F2
              INC M1473,X
L12F2         DEC M141F,X
              BNE L1306
L12F7         LDA M15ED,Y
              CMP #$FF
              INY
              TYA
              BCC L1303
              LDA M15F6,Y
L1303         STA M141E,X
L1306         JMP L137A
L1309         LDY M1444,X
              LDA M1573,Y
              STA $FD
              LDA M158C,Y
              STA $FE
              LDY $13F2,X
              LDA ($FD),Y
              CMP #$40
              BCC L1337
              CMP #$60
              BCC L1341
              CMP #$C0
              BCC L1355
              LDA $13F3,X
              BNE L132E
              LDA ($FD),Y
L132E         ADC #$00
              STA $13F3,X
              BEQ L1371
              BNE L137A
L1337         STA M1448,X
              INY
              LDA ($FD),Y
              CMP #$60
              BCS L1355
L1341         CMP #$50
              AND #$0F
              STA $13F4,X
              BEQ L1350
              INY
              LDA ($FD),Y
              STA $13F5,X
L1350         BCS L1371
              INY
              LDA ($FD),Y
L1355         CMP #$BD
              BCC L135F
              BEQ L1371
              ORA #$F0
              BNE L136E
L135F         STA M141B,X
              LDA #$0F
              STA M1497,X
              LDA #$00
              STA M1498,X
              LDA #$FE
L136E         STA M1449,X
L1371         INY
              LDA ($FD),Y
              BEQ L1377
              TYA
L1377         STA $13F2,X
L137A         CPX #$15
              BCS L13AC
              LDA M1472,X
              STA SID+$02,X
              LDA M1473,X
              STA SID+$03,X
              LDA M1498,X
              STA SID+$06,X
              LDA M1497,X
              STA SID+$05,X
              LDA M1470,X
              STA SID+$00,X
              LDA M1471,X
              STA SID+$01,X
L13A2         LDA M141D,X
              AND M1449,X
              STA SID+$04,X
              RTS
;
L13AC         LDA M1472,X
              BIT M113F+1
              LDA M1473,X
              BIT M113F+1
              LDA M1498,X
              BIT M113F+1
              LDA M1497,X
              BIT M113F+1
              LDA M1470,X
              BIT M113F+1
              LDA M1471,X
              BIT M113F+1
L13D0         LDA M141D,X
              AND M1449,X
              BIT M113F+1
              RTS
;
L13DA         fcb   $09,$0F,$0F,$16,$16,$20,$20,$20
L13E2         fcb   $20,$20,$20,$20,$20,$20,$20,$20
L13EA         fcb   $39,$5D,$5D,$5D,$40,$00,$00,$00
L13F2         fcb   $00,$00,$00,$00,$00,$00,$00,$00
L13FA         fcb   $00,$00,$00,$00,$00,$00,$00,$00
              fcb   $00,$00,$00,$00,$00,$00,$00,$00
              fcb   $00,$00,$00,$00,$00,$00,$00,$00
              fcb   $00,$00,$00,$00,$00,$00,$00
M1419         fcb   $00
M141A         fcb   $00
M141B         fcb   $00
M141C         fcb   $00
M141D         fcb   $00
M141E         fcb   $00
M141F         fcb   $00,$00,$00
              fcb   $00,$00,$00,$00,$00,$00,$00,$00
              fcb   $00,$00,$00,$00,$00,$00,$00,$00
              fcb   $00,$00,$00,$00,$00,$00,$00,$00
              fcb   $00,$00,$00,$00,$00,$00,$00,$00
              fcb   $00
M1443         fcb   $00
M1444         fcb   $00
M1445         fcb   $00
M1446         fcb   $00
M1447         fcb   $00
M1448         fcb   $01
M1449         fcb   $FE
              fcb   $01,$00
M144C         fcb   $00,$00,$00,$01,$FE,$02
              fcb   $00
M1453         fcb   $00,$00,$00,$01,$FE,$03,$00
M145A         fcb   $00,$00,$00,$01,$FE,$04,$00
M1461         fcb   $00
              fcb   $00,$00,$01,$FE,$05,$00
M1468         fcb   $00,$00
              fcb   $00,$01,$FE
M146D         fcb   $00
M146E         fcb   $00,$00
M1470         fcb   $00
M1471         fcb   $00
M1472         fcb   $00
M1473         fcb   $00,$00,$00,$00,$00,$00,$00
              fcb   $00,$00,$00,$00,$00,$00,$00,$00
              fcb   $00,$00,$00,$00,$00,$00,$00,$00
              fcb   $00,$00,$00,$00,$00,$00,$00,$00
              fcb   $00,$00,$00,$00,$00
M1497         fcb   $00
M1498         fcb   $00,$00
              fcb   $00,$00,$00,$00,$00,$00,$00,$00
              fcb   $00,$00,$00,$00,$00,$00,$00,$00
              fcb   $00,$00,$00,$00,$00,$00,$00,$00
              fcb   $00,$00,$00,$00
M14B6         fcb   $00,$00,$00,$00
              fcb   $00,$00,$00,$00,$00,$00,$00,$0E
              fcb   $2D,$4E,$71,$96,$BE,$E8,$14,$43
              fcb   $74,$A9,$E1,$1C,$5A,$9C,$E2,$2D
              fcb   $7C,$CF,$28,$85,$E8,$52,$C1,$37
              fcb   $B4,$39,$C5,$5A,$F7,$9E,$4F,$0A
              fcb   $D1,$A3,$82,$6E,$68,$71,$8A,$B3
              fcb   $EE,$3C,$9E,$15,$A2,$46,$04,$DC
              fcb   $D0,$E2,$14,$67,$DD,$79,$3C,$29
              fcb   $44,$8D,$08,$B8,$A1,$C5,$28,$CD
              fcb   $BA,$F1,$78,$53,$87,$1A,$10
M1509         fcb   $71
              fcb   $42,$89,$4F,$9B,$74,$E2,$F0,$A6
              fcb   $0E,$33,$02,$02,$02,$02,$02,$02
              fcb   $02,$03,$03,$03,$03,$03,$04,$04
              fcb   $04,$04,$05,$05,$05,$06,$06,$06
              fcb   $07,$07,$08,$08,$09,$09,$0A,$0A
              fcb   $0B,$0C,$0D,$0D,$0E,$0F,$10,$11
              fcb   $12,$13,$14,$15,$17,$18,$1A,$1B
              fcb   $1D,$1F,$20,$22,$24,$27,$29,$2B
              fcb   $2E,$31,$34,$37,$3A,$3E,$41,$45
              fcb   $49,$4E,$52,$57,$5C,$62,$68,$6E
              fcb   $75,$7C,$83,$8B,$93,$9C,$A5,$AF
              fcb   $B9,$C4,$D0,$DD,$EA
M1567         fcb   $11,$32,$53
              fcb   $74,$77,$7A
M156D         fcb   $16,$16,$16,$16,$16
M1572         fcb   $16
M1573         fcb   $7D,$80,$87,$E2,$3B,$43,$80
              fcb   $E0,$1B,$57,$8A,$C6,$01,$39,$74
              fcb   $97,$A0,$AF,$B7,$F0,$28,$63,$6C
              fcb   $A7,$E0
M158C         fcb   $16,$16,$16,$16,$17,$17
              fcb   $17,$17,$18,$18,$18,$18,$19,$19
              fcb   $19,$19,$19,$19,$19,$19,$1A,$1A
              fcb   $1A,$1A
M15A4         fcb   $1A,$46,$22,$28,$24,$12
M15AA         fcb   $D4,$E2,$B5,$62,$4A,$85
M15B0         fcb   $F4,$01
              fcb   $03,$07,$09,$0C
M15B6         fcb   $0E,$01,$05,$07
              fcb   $00,$00
M15BC         fcb   $00,$01,$00,$00,$00,$00
M15C2         fcb   $00,$00,$00,$01,$00,$00
M15C8         fcb   $00,$00
              fcb   $00,$05,$00,$00
M15CE         fcb   $00
M15CF         fcb   $41,$FF,$81
              fcb   $41,$40,$FF,$41,$FF,$81,$80,$FF
              fcb   $80,$FF
M15DC         fcb   $81
M15DD         fcb   $FF,$80,$01,$4A,$28
              fcb   $1B,$00,$80,$00,$5A,$51,$00,$5D
              fcb   $00,$51
M15EC         fcb   $00
M15ED         fcb   $85,$17,$17,$FF,$88
              fcb   $FF,$84,$70,$70
M15F6         fcb   $FF,$00,$30,$D0
              fcb   $02,$00,$00,$00,$3F,$D1
M1600         fcb   $07
M1601         fcb   $88
              fcb   $00,$1F,$0F,$0F
M1606         fcb   $FF,$A1,$60,$FF
              fcb   $01,$FF,$04
M160D         fcb   $00,$02
M160F         fcb   $00,$3F,$00
              fcb   $00,$05,$05,$08,$08,$08,$08,$0A
              fcb   $0A,$0A,$0C,$0F,$0F,$0F,$10,$05
              fcb   $05,$08,$08,$08,$08,$0A,$0A,$0A
              fcb   $13,$15,$15,$15,$15,$18,$FF,$00
              fcb   $01,$04,$01,$00,$07,$09,$07,$09
              fcb   $0B,$0B,$0B,$0D,$0B,$0B,$0B,$12
              fcb   $01,$00,$07,$09,$07,$09,$0B,$0B
              fcb   $0B,$14,$16,$16,$16,$17,$18,$FF
              fcb   $00,$02,$03,$06,$06,$06,$06,$06
              fcb   $06,$06,$06,$0E,$0E,$01,$00,$01
              fcb   $11,$06,$06,$06,$06,$06,$06,$06
              fcb   $06,$0E,$0E,$01,$00,$01,$00,$01
              fcb   $FF,$00,$00,$FF,$00,$00,$FF,$00
              fcb   $00,$FF,$00,$50,$C1,$00,$04,$4F
              fcb   $04,$9C,$50,$C2,$00,$02,$40,$90
              fcb   $BD,$05,$90,$BD,$02,$90,$BD,$05
              fcb   $90,$BD,$02,$90,$BD,$05,$90,$BD
              fcb   $02,$90,$90,$90,$90,$90,$BD,$05
              fcb   $90,$BD,$02,$90,$BD,$05,$90,$BD
              fcb   $02,$90,$BD,$05,$90,$BD,$02,$90
              fcb   $BD,$90,$BD,$90,$BD,$05,$90,$BD
              fcb   $02,$90,$BD,$05,$90,$BD,$02,$90
              fcb   $BD,$05,$90,$BD,$02,$90,$90,$90
              fcb   $90,$90,$BD,$05,$90,$BD,$02,$90
              fcb   $BD,$05,$90,$BD,$02,$90,$BD,$05
              fcb   $90,$BD,$02,$90,$BD,$90,$BD,$00
              fcb   $02,$40,$90,$BD,$05,$90,$BD,$02
              fcb   $90,$BD,$05,$90,$BD,$02,$90,$BD
              fcb   $05,$90,$BD,$02,$90,$90,$90,$90
              fcb   $90,$BD,$05,$90,$BD,$02,$90,$BD
              fcb   $05,$90,$BD,$02,$90,$BD,$05,$90
              fcb   $BD,$02,$90,$BD,$90,$BD,$90,$BD
              fcb   $05,$90,$BD,$02,$90,$BD,$05,$90
              fcb   $BD,$02,$90,$BD,$05,$90,$BD,$02
              fcb   $90,$90,$90,$90,$90,$BD,$05,$90
              fcb   $BD,$02,$90,$BD,$05,$90,$BD,$02
              fcb   $90,$BD,$05,$90,$BD,$02,$90,$FD
              fcb   $00,$50,$E1,$06,$90,$E4,$BE,$FE
              fcb   $00,$01,$40,$6F,$FE,$7B,$BD,$7B
              fcb   $79,$7B,$6F,$FE,$7B,$BD,$7B,$79
              fcb   $7B,$6F,$FE,$7B,$BD,$7B,$79,$7B
              fcb   $7B,$BD,$7B,$7E,$80,$BD,$7E,$80
              fcb   $6F,$FE,$7B,$BD,$7B,$79,$7B,$6F
              fcb   $FE,$7B,$BD,$7B,$79,$7B,$6F,$FE
              fcb   $7B,$BD,$7B,$79,$7B,$80,$BD,$7E
              fcb   $80,$7E,$BD,$7B,$7E,$00,$02,$40
              fcb   $90,$BD,$05,$90,$BD,$02,$90,$BD
              fcb   $05,$90,$BD,$02,$90,$BD,$05,$90
              fcb   $BD,$02,$90,$BD,$05,$90,$BD,$02
              fcb   $90,$BD,$05,$90,$BD,$02,$90,$BD
              fcb   $05,$90,$BD,$02,$90,$BD,$05,$90
              fcb   $BD,$02,$90,$BD,$90,$BD,$90,$BD
              fcb   $05,$90,$BD,$02,$90,$BD,$05,$90
              fcb   $BD,$02,$90,$BD,$05,$90,$BD,$02
              fcb   $90,$BD,$05,$90,$BD,$02,$90,$BD
              fcb   $05,$90,$BD,$02,$90,$BD,$05,$90
              fcb   $BD,$02,$90,$BD,$05,$90,$BD,$02
              fcb   $90,$BD,$05,$90,$BD,$00,$03,$40
              fcb   $93,$BD,$95,$BD,$96,$BD,$98,$BD
              fcb   $9A,$FD,$9F,$BD,$9D,$BD,$9A,$FD
              fcb   $93,$FD,$9A,$BD,$98,$BD,$96,$BD
              fcb   $95,$BD,$93,$BD,$95,$BD,$96,$BD
              fcb   $98,$BD,$9A,$FD,$98,$BD,$96,$BD
              fcb   $95,$BD,$93,$BD,$95,$BD,$96,$BD
              fcb   $95,$BD,$93,$BD,$92,$BD,$95,$BD
              fcb   $00,$01,$40,$6F,$FE,$7B,$BD,$7B
              fcb   $79,$7B,$6F,$FE,$7B,$BD,$7B,$79
              fcb   $7B,$6F,$FE,$7B,$BD,$7B,$79,$7B
              fcb   $7B,$BD,$7B,$7E,$80,$BD,$7E,$80
              fcb   $6B,$FE,$77,$BD,$77,$75,$77,$6B
              fcb   $FE,$77,$BD,$77,$75,$77,$6D,$FE
              fcb   $79,$BD,$79,$77,$79,$6E,$FE,$7A
              fcb   $BD,$7A,$78,$7A,$00,$03,$40,$93
              fcb   $BD,$95,$BD,$96,$BD,$98,$BD,$9A
              fcb   $FD,$9F,$BD,$9D,$BD,$9A,$FD,$93
              fcb   $FD,$9A,$BD,$98,$BD,$96,$BD,$95
              fcb   $BD,$93,$BD,$95,$BD,$96,$BD,$98
              fcb   $BD,$9A,$FD,$98,$BD,$96,$BD,$95
              fcb   $FD,$96,$FD,$98,$FD,$9A,$FD,$00
              fcb   $01,$40,$6B,$FE,$77,$BD,$77,$75
              fcb   $77,$6B,$FE,$77,$BD,$77,$75,$77
              fcb   $6D,$FE,$79,$BD,$79,$77,$79,$6D
              fcb   $FE,$79,$BD,$79,$77,$79,$6F,$FE
              fcb   $7B,$BD,$7B,$79,$7B,$6F,$FE,$7B
              fcb   $BD,$7B,$79,$7B,$6F,$FE,$7B,$BD
              fcb   $7B,$79,$7B,$80,$BD,$7E,$80,$7E
              fcb   $BD,$7B,$7E,$00,$03,$40,$9D,$BD
              fcb   $9F,$BD,$9A,$BD,$98,$BD,$9A,$FD
              fcb   $98,$BD,$9A,$BD,$9D,$BD,$9F,$BD
              fcb   $9A,$BD,$98,$BD,$9A,$FD,$98,$BD
              fcb   $9A,$BD,$98,$BD,$96,$BD,$95,$BD
              fcb   $91,$BD,$93,$FD,$91,$BD,$93,$BD
              fcb   $95,$BD,$96,$BD,$98,$BD,$9A,$BD
              fcb   $93,$FD,$9A,$BD,$9D,$BD,$00,$01
              fcb   $40,$6B,$FE,$77,$BD,$77,$75,$77
              fcb   $6B,$FE,$77,$BD,$77,$75,$77,$6D
              fcb   $FE,$79,$BD,$79,$77,$79,$6D,$FE
              fcb   $79,$BD,$79,$77,$79,$6F,$FE,$7B
              fcb   $BD,$7B,$79,$7B,$6F,$FE,$7B,$BD
              fcb   $7B,$79,$7B,$6F,$FE,$7B,$BD,$7B
              fcb   $79,$7B,$80,$FD,$7E,$FD,$00,$03
              fcb   $40,$9D,$BD,$9F,$BD,$9A,$BD,$98
              fcb   $BD,$9A,$FD,$98,$BD,$9A,$BD,$9D
              fcb   $BD,$9F,$BD,$9A,$BD,$98,$BD,$9A
              fcb   $FD,$9F,$BD,$A1,$BD,$A2,$BD,$A1
              fcb   $BD,$9F,$BD,$9D,$BD,$9A,$FD,$98
              fcb   $BD,$9A,$BD,$98,$BD,$96,$BD,$95
              fcb   $BD,$91,$BD,$93,$FD,$9A,$BD,$9D
              fcb   $BD,$00,$04,$40,$9C,$FD,$9C,$FD
              fcb   $9C,$FD,$9C,$FD,$9C,$FD,$9C,$FD
              fcb   $9C,$FD,$9C,$FD,$9C,$FD,$9C,$FD
              fcb   $9C,$FD,$9C,$FD,$9C,$FD,$9C,$FD
              fcb   $9C,$FD,$9C,$FD,$00,$01,$40,$6B
              fcb   $F1,$6D,$F1,$6F,$E1,$00,$01,$40
              fcb   $6B,$F1,$6D,$F1,$6F,$F1,$BE,$F9
              fcb   $74,$FD,$72,$FD,$00,$50,$C9,$04
              fcb   $90,$FD,$90,$FD,$00,$03,$40,$9D
              fcb   $BD,$9F,$BD,$9A,$BD,$98,$BD,$9A
              fcb   $FD,$98,$BD,$9A,$BD,$9D,$BD,$9F
              fcb   $BD,$9A,$BD,$98,$BD,$9A,$FD,$9F
              fcb   $BD,$A1,$BD,$A2,$BD,$A1,$BD,$9F
              fcb   $BD,$9D,$BD,$9A,$FD,$98,$BD,$9A
              fcb   $BD,$98,$BD,$96,$BD,$95,$BD,$91
              fcb   $BD,$93,$FB,$BE,$BD,$00,$01,$40
              fcb   $6B,$FE,$77,$BD,$77,$75,$77,$6B
              fcb   $FE,$77,$BD,$77,$75,$77,$6D,$FE
              fcb   $79,$BD,$79,$77,$79,$6D,$FE,$79
              fcb   $BD,$79,$77,$79,$6F,$FE,$7B,$BD
              fcb   $7B,$79,$7B,$6F,$FE,$7B,$BD,$7B
              fcb   $79,$7B,$6F,$FE,$7B,$BD,$7B,$79
              fcb   $7B,$80,$FD,$7F,$FD,$00,$03,$40
              fcb   $9D,$BD,$9F,$BD,$9A,$BD,$98,$BD
              fcb   $9A,$FD,$98,$BD,$9A,$BD,$9D,$BD
              fcb   $9F,$BD,$9A,$BD,$98,$BD,$9A,$FD
              fcb   $9F,$BD,$A1,$BD,$A2,$BD,$A1,$BD
              fcb   $9F,$BD,$9D,$BD,$9A,$FD,$98,$BD
              fcb   $9A,$BD,$98,$BD,$96,$BD,$95,$BD
              fcb   $91,$BD,$93,$FD,$9B,$BD,$9E,$BD
              fcb   $00,$01,$40,$6C,$F1,$6E,$F1,$70
              fcb   $E1,$00,$03,$40,$9E,$BD,$A0,$BD
              fcb   $9B,$BD,$99,$BD,$9B,$FD,$99,$BD
              fcb   $9B,$BD,$9E,$BD,$A0,$BD,$9B,$BD
              fcb   $99,$BD,$9B,$FD,$99,$BD,$9B,$BD
              fcb   $99,$BD,$97,$BD,$96,$BD,$92,$BD
              fcb   $94,$FD,$92,$BD,$94,$BD,$96,$BD
              fcb   $97,$BD,$99,$BD,$9B,$BD,$94,$FD
              fcb   $9B,$BD,$9E,$BD,$00,$03,$40,$9E
              fcb   $BD,$A0,$BD,$9B,$BD,$99,$BD,$9B
              fcb   $FD,$99,$BD,$9B,$BD,$9E,$BD,$A0
              fcb   $BD,$9B,$BD,$99,$BD,$9B,$FD,$A0
              fcb   $BD,$A2,$BD,$A3,$BD,$A2,$BD,$A0
              fcb   $BD,$9E,$BD,$9B,$FD,$99,$BD,$9B
              fcb   $BD,$99,$BD,$97,$BD,$96,$BD,$92
              fcb   $BD,$94,$FB,$BE,$BD,$00,$40,$BE
              fcb   $C1,$00

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

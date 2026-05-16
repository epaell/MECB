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
L0F82         dc.b  $50,$53,$49,$44,$00,$02,$00,$7C
L0F8A         dc.b  $00,$00,$10,$00,$10,$06,$00,$01
L0F92         dc.b  $00,$01,$00,$00,$00,$00,$44,$72
L0F9A         dc.b  $2E,$20,$57,$68,$6F,$00,$00,$00
L0FA2         dc.b  $00,$00,$00,$00,$00,$00,$00,$00
L0FAA         dc.b  $00,$00,$00,$00,$00,$00,$00,$00
L0FB2         dc.b  $00,$00,$00,$00,$00,$00,$3C,$3F
L0FBA         dc.b  $3E,$00,$00,$00,$00,$00,$00,$00
L0FC2         dc.b  $00,$00,$00,$00,$00,$00,$00,$00
L0FCA         dc.b  $00,$00,$00,$00,$00,$00,$00,$00
L0FD2         dc.b  $00,$00,$00,$00,$00,$00,$31,$39
L0FDA         dc.b  $38,$39,$20,$3C,$3F,$3E,$00,$00
L0FE2         dc.b  $00,$00,$00,$00,$00,$00,$00,$00
L0FEA         dc.b  $00,$00,$00,$00,$00,$00,$00,$00
L0FF2         dc.b  $00,$00,$00,$00,$00,$00,$00,$14
L0FFA         dc.b  $00,$00,$00,$00,$00,$10
;
              org $1000
;
sid_init      JMP L1800
              JMP L190F
sid_play      LDA $1974
              CMP #$02
              BEQ L1014
              CMP #$01
              BNE L102A
              JMP L18E8
L1014         RTS
              SBC $EE26,Y
              ASL $10,X
              INC $1016
              LDA $1016
              CMP #$32
              BNE L1029
              LDA #$01
              STA $1015
L1029         RTS
L102A         INC $1942
              INC $1943
              INC $1944
              LDA #$1F
              STA SID+$18
              LDX #$02
              DEC $1973
              BPL L1045
              LDA $191D
              STA $1973
L1045         NOP
              NOP
              NOP
              STX $FF
              LDA $191E,X
              STA $1956
              TAY
              LDA $1973
              CMP $191D
              BNE L106B
              LDA L16A1,X
              STA $FB
              LDA $16A4,X
              STA $FC
              DEC $1927,X
              BMI L106E
              JMP L11FA
L106B         JMP L120A
L106E         LDY $1921,X
              LDA ($FB),Y
              CMP #$FE
              BEQ L108C
              CMP #$FF
              BNE L1094
              LDA #$00
              STA $1927,X
              STA $1921,X
              STA $1924,X
              STA $1972
              JMP L106E
L108C         LDA #$02
              STA $1974
              JMP L190B
L1094         STA $1967
              AND #$80
              BEQ L10A9
              LDA $1967
              AND #$1F
              STA $194F,X
              INC $1921,X
              JMP L106E
L10A9         LDA $1967
              AND #$40
              BEQ L10BE
              LDA $1967
              AND #$3F
              STA $1976,X
              INC $1921,X
              JMP L106E
L10BE         LDA $1967
              ASL A
              TAY
              LDA $16A7,Y
              STA $FD
              LDA $16A8,Y
              STA $FE
              LDA #$00
              STA $193F,X
              LDY $1924,X
              STA $1942,X
              LDA #$03
              STA $1961,X
L10DD         LDA ($FD),Y
              STA $F8
              AND #$F0
              CMP #$F0
              BNE L10F7
              LDA #$01
              STA $1980,X
              INC $1924,X
              INY
              LDA ($FD),Y
              STA $F8
              JMP L1157
L10F7         LDA #$00
              STA $1980,X
              LDA $F8
              AND #$F0
              CMP #$E0
              BNE L1130
              LDA $F8
              AND #$01
              CLC
              ADC #$01
              STA $193F,X
              LDA $F8
              AND #$0E
              LSR A
              STA $1965
              INC $1924,X
              INY
              LDA ($FD),Y
              PHA
              AND #$F0
              STA $1964
              PLA
              AND #$0F
              STA $12F8
              INC $1924,X
              INY
              LDA ($FD),Y
              STA $F8
L1130         LDA $F8
              AND #$E0
              CMP #$C0
              BNE L1142
              LDA $F8
              AND #$1F
              STA $1933,X
              JSR L11ED
L1142         LDA $F8
              AND #$C0
              CMP #$80
              BNE L1157
              LDA $F8
              AND #$3F
              STA $192A,X
              JSR L11ED
              JMP L10DD
L1157         LDA $192A,X
              STA $1927,X
              LDA $F8
              CLC
              ADC $194F,X
              STA $1930,X
              TAY
              LDA $1564,Y
              PHA
              LDA $15C4,Y
              LDY $1956
              STA SID+$01,Y
              STA $1936,X
              STA $1939,X
              PLA
              STA SID+$00,Y
              STA $193C,X
              LDA $1980,X
              BNE L11CC
              LDA $1933,X
              ASL A
              ASL A
              ASL A
              TAX
              STX $1952
              LDA $198A,X
              STA SID+$05,Y
              LDA $198B,X
              STA SID+$06,Y
              LDA $198C,X
              PHA
              LDA $1988,X
              PHA
              LDA $1989,X
              LDX $FF
              STA $192D,X
              STA $1979,X
              LDA #$00
              STA SID+$02,Y
              STA $1945,X
              PLA
              STA $194B,X
              AND #$0F
              STA SID+$03,Y
              STA $1948,X
              LDA #$01
              STA $196F,X
              PLA
              STA $196C,X
L11CC         INC $1924,X
              LDY $1924,X
              LDA ($FD),Y
              CMP #$FF
              BNE L11EA
L11D8         LDA #$00
              STA $1924,X
              LDA $1976,X
              BEQ L11E7
              DEC $1976,X
              BPL L11EA
L11E7         INC $1921,X
L11EA         JMP L1552
L11ED         INC $1924,X
              INY
              LDA ($FD),Y
              CMP #$FF
              BEQ L11D8
              STA $F8
              RTS
L11FA         LDY $1956
              LDA $1942,X
              BEQ L120A
              LDA $192D,X
              AND #$FE
              STA $1979,X
L120A         LDA $1933,X
              ASL A
              ASL A
              ASL A
              TAY
              LDA $198D,Y
              STA $1953
              LDA $198E,Y
              STA $1954
              LDA $198F,Y
              STA $1955
              AND #$04
              BNE L1233
              LDA $1955
              AND #$10
              BNE L1233
              LDA $1953
              BNE L1236
L1233         JMP L1830
L1236         PHA
              AND #$78
              LSR A
              LSR A
              LSR A
              STA $1958,X
              PLA
              AND #$07
              STA $1957
              LDA $195B,X
              BEQ L1254
              DEC $195E,X
              BNE L1268
              INC $195B,X
              BPL L1268
L1254         INC $195E,X
              LDA $1958,X
              CMP $195E,X
              BCS L1268
              STA $195E,X
              DEC $195B,X
              DEC $195E,X
L1268         LDA $1930,X
              TAY
              LDA $1565,Y
              SEC
              SBC $1564,Y
              STA $197F
              LDA $15C5,Y
              SBC $15C4,Y
              ADC $1942,X
              LSR A
L1280         DEC $1957
              BMI L128C
              LSR A
              ROR $197F
              JMP L1280
L128C         STA $197E
              LDA $1564,Y
              STA $197C
              LDA $15C4,Y
              STA $197D
              LDA $1958,X
              LSR A
              TAY
L12A0         DEY
              BMI L12B9
              SEC
              LDA $197C
              SBC $197F
              STA $197C
              LDA $197D
              SBC $197E
              STA $197D
              JMP L12A0
L12B9         LDA $1942,X
              CMP #$04
              BCC L12EB
              LDY $195E,X
L12C3         DEY
              BMI L12DC
              CLC
              LDA $197C
              ADC $197F
              STA $197C
              LDA $197D
              ADC $197E
              STA $197D
              JMP L12C3
L12DC         LDY $1956
              LDA $197C
              STA SID+$00,Y
              LDA $197D
              STA SID+$01,Y
L12EB         LDX $FF
              LDY $1956
              LDA $192A,X
              SEC
              SBC $1927,X
              CMP #$01
              BCC L1341
              LDA $193F,X
              BEQ L1341
              AND #$03
              CMP #$01
              BEQ L1325
              LDA $1964
              SEC
              LDA $193C,X
              SBC $1964
              STA $193C,X
              STA SID+$00,Y
              LDA $1936,X
              SBC $1965
              STA $1936,X
              STA SID+$01,Y
              JMP L1341
L1325         LDA $1964
              CLC
              LDA $193C,X
              ADC $1964
              STA $193C,X
              STA SID+$00,Y
              LDA $1936,X
              ADC $1965
              STA $1936,X
              STA SID+$01,Y
L1341         LDA $1954
              BEQ L13B2
              AND #$07
              TAY
              DEY
              TYA
              ASL A
              ASL A
              TAY
              LDA $1695,Y
              CMP $1942,X
              BCC L1359
              JMP L1363
L1359         INY
              INY
              LDA $1695,Y
              CMP $1942,X
              BCC L136D
L1363         INY
              LDA $1695,Y
              STA $194E
              JMP L1375
L136D         LDA $1954
              AND #$FC
              STA $194E
L1375         LDA $196F,X
              BNE L1397
              LDA $1945,X
              SEC
              SBC $194E
              STA $1945,X
              LDA $1948,X
              SBC #$00
              STA $1948,X
              CMP #$01
              BCS L13B2
              LDA #$01
              STA $196F,X
              BNE L13B2
L1397         LDA $1945,X
              CLC
              ADC $194E
              STA $1945,X
              LDA $1948,X
              ADC #$00
              STA $1948,X
              CMP #$0F
              BCC L13B2
              LDA #$00
              STA $196F,X
L13B2         LDA #$00
              STA $13D4
              LDA $194B,X
              AND #$80
              BEQ L13CA
              LDA $1942,X
              AND #$01
              BEQ L13CA
              LDA #$B0
              STA $13D4
L13CA         LDX $FF
              LDY $1956
              LDA $1945,X
              CLC
              ADC #$00
              STA SID+$02,Y
              LDA $1948,X
              ADC #$00
              STA SID+$03,Y
              LDA $1955
              AND #$40
              BEQ L13FB
              LDX $FF
              LDA $1942,X
              CMP #$03
              BCC L13FB
              AND #$03
              TAX
              LDA $1632,X
              LDX $FF
              STA $1979,X
L13FB         STY $1967
              LDA $1955
              AND #$01
              BEQ L142F
              LDX $FF
              STX $1975
              LDA #$89
              STA $F9
              LDA #$16
              STA $FA
              LDX $FF
              LDA $1942,X
              LDY #$0B
              CMP ($F9),Y
              BCS L1450
              LDY #$0A
L141F         CMP ($F9),Y
              BCS L145B
              DEY
              CPY #$06
              BNE L141F
              CMP ($F9),Y
              BCS L1432
              JMP L147B
L142F         JMP L146A
L1432         LDA $FF
              ASL A
              BNE L143A
              CLC
              ADC #$01
L143A         STA $1968
              LDX $1972
              TXA
              AND $1968
              BNE L144E
              TXA
              CLC
              ADC $1968
              STA SID+$17
L144E         LDY #$06
L1450         DEY
              DEY
              DEY
              DEY
              DEY
              DEY
              LDA ($F9),Y
              JMP L1473
L145B         DEY
              DEY
              DEY
              DEY
              DEY
              DEY
              LDA $1969,X
              CLC
              ADC ($F9),Y
              JMP L1473
L146A         LDA $FF
              CMP $1975
              BNE L147B
              LDA #$FF
L1473         LDX $FF
              STA $1969,X
              STA SID+$16
L147B         LDY $1967
              LDA $1955
              AND #$10
              BEQ L14E3
              LDA $1953
              AND #$0F
              TAX
              LDA $163E,X
              STA $14AF
              LDA $1640,X
              STA $14B0
              LDA $1642,X
              STA $14B7
              LDA $1644,X
              STA $14B8
              LDX $FF
              LDA $1942,X
              CMP #$0F
              BCS L14E0
              TAX
              DEX
              LDA L1676,X
              LDY $FF
              STA $1979,Y
              LDA $1666,X
              STA $1968
              LDA $1953
              AND #$10
              BEQ L14CF
              LDX $FF
              LDA $1930,X
              CLC
              ADC $1968
              JMP L1542
L14CF         LDY $1956
              LDA $1968
              CLC
              ADC #$0D
              STA SID+$01,Y
              LDA #$00
              STA SID+$00,Y
L14E0         JMP L1552
L14E3         LDA $1955
              AND #$80
              BEQ L151E
              LDX $FF
              LDY $1956
              LDA $1942,X
              CMP #$02
              BCS L150A
              LDA #$48
              STA SID+$01,Y
              LDA #$00
              STA SID+$00,Y
              LDX $FF
              LDA #$81
              STA $1979,X
              JMP L1552
L150A         LDA $193C,X
              STA SID+$00,Y
              LDA $1936,X
              STA SID+$01,Y
              LDA $192D,X
              AND #$FE
              STA $1979,X
L151E         LDA $1955
              AND #$04
              BEQ L1552
              DEC $1961,X
              BPL L152F
              LDA #$02
              STA $1961,X
L152F         LDX $FF
              LDA $1961,X
              TAX
              LDA $1686,X
              STA $41
              LDX $FF
              LDA $1930,X
              CLC
              ADC $41
L1542         TAX
              LDY $1956
              LDA $1564,X
              STA SID+$00,Y
              LDA $15C4,X
              STA SID+$01,Y
L1552         LDX $FF
              LDY $1956
              LDA $1979,X
              STA SID+$04,Y
              DEX
              BMI L1563
              JMP L1045
L1563         RTS
;
L1564         dc.b  $0C,$1C,$2D,$3E,$51,$66
L156A         dc.b  $7B,$91,$A9,$C3,$DD,$FA,$18,$38
L1572         dc.b  $5A,$7D,$A3,$CC,$F6,$23,$53,$86
L157A         dc.b  $BB,$E0,$30,$70,$B4,$FB,$47,$98
L1582         dc.b  $ED,$47,$A7,$0C,$77,$E9,$61,$E1
L158A         dc.b  $68,$F7,$8F,$30,$DA,$8F,$4E,$18
L1592         dc.b  $EF,$D2,$C3,$C3,$D1,$EF,$1F,$60
L159A         dc.b  $B5,$1E,$9C,$31,$DF,$A5,$87,$86
L15A2         dc.b  $A2,$DF,$3E,$C1,$6B,$3C,$39,$63
L15AA         dc.b  $BE,$4B,$0F,$0C,$45,$BF,$7D,$83
L15B2         dc.b  $D6,$79,$73,$C7,$7C,$97,$1E,$18
L15BA         dc.b  $8B,$7E,$FA,$06,$AC,$F3,$E6,$8F
L15C2         dc.b  $F8,$2E,$01,$01,$01,$01,$01,$01
L15CA         dc.b  $01,$01,$01,$01,$01,$01,$02,$02
L15D2         dc.b  $02,$02,$02,$02,$02,$03,$03,$03
L15DA         dc.b  $03,$03,$04,$04,$04,$04,$05,$05
L15E2         dc.b  $05,$06,$06,$07,$07,$07,$08,$08
L15EA         dc.b  $09,$09,$0A,$0B,$0B,$0C,$0D,$0E
L15F2         dc.b  $0E,$0F,$10,$11,$12,$13,$15,$16
L15FA         dc.b  $17,$19,$1A,$1C,$1D,$1F,$21,$23
L1602         dc.b  $25,$27,$2A,$2C,$2F,$32,$35,$38
L160A         dc.b  $3B,$3F,$43,$47,$4B,$4F,$54,$59
L1612         dc.b  $5E,$64,$6A,$70,$77,$7E,$86,$8E
L161A         dc.b  $96,$9F,$A8,$B3,$BD,$C8,$D4,$E1
L1622         dc.b  $EE,$FD,$40,$40,$40,$40,$40,$40
L162A         dc.b  $40,$00,$00,$00,$00,$00,$00,$00
L1632         dc.b  $40,$40,$40,$40,$06,$06,$07,$07
L163A         dc.b  $08,$08,$07,$07,$56,$76,$16,$16
L1642         dc.b  $46,$66,$16,$16,$13,$01,$FF,$23
L164A         dc.b  $08,$13,$03,$23,$00,$00,$00,$00
L1652         dc.b  $00,$00,$00,$00,$81,$41,$40,$80
L165A         dc.b  $80,$80,$80,$80,$10,$10,$10,$10
L1662         dc.b  $10,$10,$10,$10,$24,$FD,$FB,$F9
L166A         dc.b  $F8,$F7,$F6,$F6,$F5,$F5,$F4,$F4
L1672         dc.b  $F5,$F6,$F5,$F4
L1676         dc.b  $81,$41,$40,$40
L167A         dc.b  $40,$40,$40,$40,$40,$40,$40,$40
L1682         dc.b  $40,$40,$40,$40,$00,$0C,$18,$C0
L168A         dc.b  $F0,$F8,$F4,$F2,$40,$01,$02,$06
L1692         dc.b  $0C,$10,$30,$04,$A0,$08,$60,$04
L169A         dc.b  $80,$0C,$10,$03,$80,$10,$40
L16A1         dc.b  $00
L16A2         dc.b  $80,$50,$17,$17,$18,$18,$1A,$19
L16AA         dc.b  $1A,$23,$1A,$2D,$1A,$37,$1A,$41
L16B2         dc.b  $1A,$4B,$1A,$55,$1A,$5F,$1A,$65
L16BA         dc.b  $1A,$6C,$1A,$8C,$1A,$9E,$1A,$BC
L16C2         dc.b  $1A,$C0,$1A,$C1,$1A,$C2,$1A,$C3
L16CA         dc.b  $1A,$C4,$1A,$C5,$1A,$C6,$1A,$C7
L16D2         dc.b  $1A,$C8,$1A,$C9,$1A,$CA,$1A,$CB
L16DA         dc.b  $1A,$CC,$1A,$CD,$1A,$CE,$1A,$CF
L16E2         dc.b  $1A,$D0,$1A,$D1,$1A,$D2,$1A,$D3
L16EA         dc.b  $1A,$D4,$1A,$D5,$1A,$D6,$1A,$D7
L16F2         dc.b  $1A,$D8,$1A,$D9,$1A,$DA,$1A,$DB
L16FA         dc.b  $1A,$DC,$1A,$DD,$1A,$00,$01,$01
L1702         dc.b  $01,$02,$01,$01,$01,$02,$01,$01
L170A         dc.b  $03,$03,$01,$01,$03,$03,$01,$01
L1712         dc.b  $04,$03,$03,$03,$03,$05,$03,$03
L171A         dc.b  $03,$03,$06,$06,$06,$06,$07,$06
L1722         dc.b  $06,$06,$07,$06,$07,$06,$03,$03
L172A         dc.b  $01,$01,$01,$02,$01,$01,$01,$02
L1732         dc.b  $08,$FF,$00,$00,$00,$00,$00,$00
L173A         dc.b  $00,$00,$00,$00,$00,$00,$00,$00
L1742         dc.b  $00,$00,$00,$00,$00,$00,$00,$00
L174A         dc.b  $00,$00,$00,$00,$00,$00,$00,$00
L1752         dc.b  $00,$00,$00,$00,$00,$00,$00,$00
L175A         dc.b  $00,$00,$00,$00,$00,$00,$00,$00
L1762         dc.b  $00,$00,$00,$00,$00,$00,$00,$00
L176A         dc.b  $00,$00,$00,$00,$00,$00,$00,$00
L1772         dc.b  $00,$00,$00,$00,$00,$00,$00,$00
L177A         dc.b  $00,$00,$00,$00,$00,$00,$8C,$01
L1782         dc.b  $01,$01,$02,$01,$01,$01,$02,$01
L178A         dc.b  $01,$03,$03,$01,$01,$03,$03,$01
L1792         dc.b  $01,$04,$03,$03,$03,$03,$05,$03
L179A         dc.b  $03,$03,$03,$06,$06,$06,$06,$07
L17A2         dc.b  $06,$06,$06,$07,$06,$07,$06,$03
L17AA         dc.b  $03,$01,$01,$01,$02,$01,$01,$01
L17B2         dc.b  $02,$08,$FF,$00,$00,$00,$00,$00
L17BA         dc.b  $00,$00,$00,$00,$00,$00,$00,$00
L17C2         dc.b  $00,$00,$00,$00,$00,$00,$00,$00
L17CA         dc.b  $00,$00,$00,$00,$00,$00,$00,$00
L17D2         dc.b  $00,$00,$00,$00,$00,$00,$00,$00
L17DA         dc.b  $00,$00,$00,$00,$00,$00,$00,$00
L17E2         dc.b  $00,$00,$00,$00,$00,$00,$00,$00
L17EA         dc.b  $00,$00,$00,$00,$00,$00,$00,$00
L17F2         dc.b  $00,$00,$00,$00,$00,$00,$00,$00
L17FA         dc.b  $00,$00,$00,$00,$00,$00
L1800         dc.b  $A2,$01
L1802         dc.b  $8E,$74,$19,$AA,$BD,$D0,$18,$85
L180A         dc.b  $2C,$BD,$D3,$18,$85,$2D,$A0,$05
L1812         dc.b  $B1,$2C,$99,$A1,$16,$88,$10,$F8
L181A         dc.b  $4C,$08,$19,$00,$80,$50,$17,$17
L1822         dc.b  $18,$12,$96,$AE,$17,$17,$18,$00
L182A         dc.b  $80,$50,$17,$17,$18,$00
L1830         dc.b  $AD,$53
L1832         dc.b  $19,$F0,$13,$4A,$4A,$4A,$4A,$AA
L183A         dc.b  $AD,$53,$19,$29,$0F,$8D,$88,$16
L1842         dc.b  $8E,$87,$16,$4C,$EB,$12,$A9,$18
L184A         dc.b  $A2,$0C,$D0,$F1,$02,$02,$09,$0A
L1852         dc.b  $0B,$0C,$09,$0D,$FF,$00,$00,$00
L185A         dc.b  $00,$00,$00,$00,$00,$00,$00,$00
L1862         dc.b  $00,$00,$00,$00,$00,$00,$00,$00
L186A         dc.b  $00,$00,$00,$00,$00,$00,$00,$00
L1872         dc.b  $00,$00,$00,$00,$00,$00,$00,$00
L187A         dc.b  $00,$00,$00,$00,$00,$00,$00,$00
L1882         dc.b  $00,$00,$00,$00,$00,$00,$00,$00
L188A         dc.b  $00,$00,$00,$00,$00,$00,$00,$00
L1892         dc.b  $00,$00,$00,$00,$00,$00,$00,$00
L189A         dc.b  $00,$00,$00,$00,$00,$00,$00,$00
L18A2         dc.b  $00,$00,$00,$00,$00,$00,$00,$00
L18AA         dc.b  $00,$00,$00,$00,$00,$00,$00,$00
L18B2         dc.b  $00,$00,$00,$00,$00,$00,$00,$00
L18BA         dc.b  $00,$00,$00,$00,$00,$00,$00,$00
L18C2         dc.b  $00,$00,$00,$00,$00,$00,$00,$00
L18CA         dc.b  $00,$00,$00,$00,$00,$00,$1D,$23
L18D2         dc.b  $29,$18,$18,$18,$00,$00,$00,$A9
L18DA         dc.b  $00,$A2,$62,$9D,$21,$19,$CA,$10
L18E2         dc.b  $FA,$A9,$B0,$8D,$72,$19
L18E8         dc.b  $A9,$00
L18EA         dc.b  $8D,$42,$19,$8D,$43,$19,$8D,$44
L18F2         dc.b  $19,$A2,$02,$9D,$21,$19,$9D,$24
L18FA         dc.b  $19,$9D,$27,$19,$9D,$30,$19,$CA
L1902         dc.b  $10,$F1,$8D,$74,$19,$60,$20,$D9
L190A         dc.b  $18
L190B         dc.b  $A2,$00,$8A,$9D
L190F         dc.b  $00,$D4,$E8
L1912         dc.b  $E0,$18,$D0,$F8,$60,$A9,$02,$8D
L191A         dc.b  $74,$19,$60,$01,$00,$07,$0E,$19
L1922         dc.b  $1A,$01,$00,$00,$1E,$03,$03,$0F
L192A         dc.b  $07,$07,$3F,$41,$41,$00,$17,$23
L1932         dc.b  $00,$01,$01,$00,$03,$07,$01,$03
L193A         dc.b  $07,$01,$E0,$E9,$0C,$00,$00,$00
L1942         dc.b  $09,$09,$61,$40,$40,$00,$08,$08
L194A         dc.b  $00,$04,$04,$00,$40,$00,$0C,$00
L1952         dc.b  $08,$00,$41,$81,$00,$00,$00,$00
L195A         dc.b  $00,$00,$00,$00,$00,$00,$00,$03
L1962         dc.b  $03,$03,$00,$00,$00,$00,$01,$60
L196A         dc.b  $60,$00,$00,$00,$00,$01,$01,$01
L1972         dc.b  $00,$00,$00,$00,$00,$00,$00,$40
L197A         dc.b  $40,$00,$00,$00,$00,$00,$00,$00
L1982         dc.b  $00,$00,$00,$00,$00,$00,$00,$00
L198A         dc.b  $00,$00,$00,$00,$00,$00,$04,$41
L1992         dc.b  $00,$EC,$00,$00,$41,$81,$08,$11
L199A         dc.b  $00,$A9,$00,$00,$00,$10,$08,$41
L19A2         dc.b  $07,$E7,$00,$00,$81,$04,$08,$11
L19AA         dc.b  $00,$A8,$00,$01,$00,$10,$08,$11
L19B2         dc.b  $00,$A8,$00,$00,$00,$80,$02,$21
L19BA         dc.b  $00,$CD,$00,$25,$72,$40,$02,$21
L19C2         dc.b  $00,$EA,$00,$25,$72,$40,$08,$11
L19CA         dc.b  $00,$E8,$00,$00,$43,$40,$08,$11
L19D2         dc.b  $00,$A8,$00,$11,$00,$10,$01,$41
L19DA         dc.b  $00,$AE,$00,$26,$43,$00,$01,$41
L19E2         dc.b  $00,$AF,$00,$00,$43,$00,$08,$15
L19EA         dc.b  $00,$A8,$00,$00,$00,$80,$05,$41
L19F2         dc.b  $00,$E9,$00,$24,$61,$00,$04,$41
L19FA         dc.b  $00,$E8,$00,$85,$63,$04,$04,$41
L1A02         dc.b  $00,$E8,$00,$47,$63,$04,$04,$41
L1A0A         dc.b  $00,$E8,$00,$59,$63,$04,$FF,$FF
L1A12         dc.b  $FF,$FF,$FF,$FF,$FF,$FF,$FF,$C1
L1A1A         dc.b  $83,$1A,$87,$1C,$83,$1C,$87,$1C
L1A22         dc.b  $FF,$C1,$83,$1A,$87,$1F,$83,$1F
L1A2A         dc.b  $1F,$1E,$FF,$C1,$83,$15,$87,$17
L1A32         dc.b  $83,$17,$87,$17,$FF,$C1,$83,$1A
L1A3A         dc.b  $87,$1F,$83,$1F,$87,$1F,$FF,$C1
L1A42         dc.b  $83,$15,$87,$1A,$83,$1A,$1A,$19
L1A4A         dc.b  $FF,$C1,$83,$1A,$87,$1F,$83,$1F
L1A52         dc.b  $87,$1F,$FF,$C1,$83,$18,$87,$1A
L1A5A         dc.b  $83,$1A,$87,$1A,$FF,$C1,$83,$1A
L1A62         dc.b  $BF,$1C,$FF,$C0,$BF,$00,$00,$AB
L1A6A         dc.b  $00,$FF,$CB,$8B,$3B,$48,$AF,$47
L1A72         dc.b  $97,$3B,$4A,$AF,$47,$3B,$8B,$47
L1A7A         dc.b  $43,$97,$3B,$93,$3E,$83,$3C,$93
L1A82         dc.b  $3B,$83,$39,$BF,$3B,$C0,$BF,$00
L1A8A         dc.b  $00,$FF,$CB,$BF,$47,$87,$47,$8B
L1A92         dc.b  $43,$47,$91,$45,$82,$43,$42,$BF
L1A9A         dc.b  $43,$83,$43,$FF,$CB,$82,$3E,$91
L1AA2         dc.b  $40,$82,$3E,$3C,$8B,$3E,$37,$82
L1AAA         dc.b  $40,$3E,$8B,$40,$82,$3E,$3C,$8B
L1AB2         dc.b  $3E,$3B,$AB,$39,$82,$37,$36,$B7
L1ABA         dc.b  $37,$FF,$C0,$9A,$00,$FF
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

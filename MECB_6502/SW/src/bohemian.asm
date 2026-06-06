; Bohemian Rhapsody
; vasm6502_mot -wdc02 -L bohemian.lst -Fihex -o bohemian.hex bohemian.asm
MECB_IO       equ   $E000
SID1           equ   MECB_IO+$A0
SID2           equ   MECB_IO+$E0
LED            equ   MECB_IO+$C1
;SID1            equ   $D400
;SID2            equ   $D500
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
;timer_LSB       equ     $0C          ; 20 mS at 1 MHz (50 Hz)
;timer_MSB       equ     $4E
;timer_LSB       equ     $74          ; 16.67 mS at 1 MHz (60 Hz)
;timer_MSB       equ     $40
timer_LSB       equ     $97          ; 20 mS at 1 MHz (50 Hz)
timer_MSB       equ     $19
;
                ORG     $0e00
;
               org   $0F78
; header
L0F78         fcb   $50,$53,$49,$44,$00,$03,$00,$7C
L0F80         fcb   $00,$00,$0F,$F6,$10,$03,$00,$01
L0F88         fcb   $00,$01,$FF,$FF,$FF,$FF,$42,$6F
L0F90         fcb   $68,$65,$6D,$69,$61,$6E,$20,$52
L0F98         fcb   $68,$61,$70,$73,$6F,$64,$79,$00
L0FA0         fcb   $00,$00,$00,$00,$00,$00,$00,$00
L0FA8         fcb   $00,$00,$00,$00,$00,$00,$42,$65
L0FB0         fcb   $6E,$20,$44,$69,$62,$62,$65,$72
L0FB8         fcb   $74,$20,$28,$4E,$6F,$72,$64,$69
L0FC0         fcb   $73,$63,$68,$73,$6F,$75,$6E,$64
L0FC8         fcb   $29,$00,$00,$00,$00,$00,$32,$30
L0FD0         fcb   $32,$36,$20,$51,$75,$61,$6E,$74
L0FD8         fcb   $75,$6D,$00,$00,$00,$00,$00,$00
L0FE0         fcb   $00,$00,$00,$00,$00,$00,$00,$00
L0FE8         fcb   $00,$00,$00,$00,$00,$00,$00,$A4
L0FF0         fcb   $00,$00,$50,$00,$F6,$0F
;
              org $0FF6
;
sid_init      LDX #$97     ; Init
              STX $DC04    ; CIA 1 Timer A low byte
              LDX #$19
              STX $DC05    ; CIA 1 Timer A high byte
              JMP L10F9
sid_play      JMP L10FD    ; Play
L1006         LDA $17E9,Y
              JMP L1013
              TAY
              LDA #$00
              STA $1529,X
              TYA
L1013         STA $14D6,X
              LDA $14B0,X
              STA $14D5,X
              RTS
;
              STA $1554,X
              RTS
;
              STA $14DA,X
              LDA #$00
              STA $14DB,X
              RTS
;
              CPX #$15
              BCS L1037
              LDY #$00
              STY $1157
L1033         STA $1153
              RTS
;
L1037         LDY #$00
              STY $11B1
L103C         STA $11AD
              RTS
;
              CPX #$15
              BCS L104C
              STA $11A1
              CMP #$00
              BEQ L1033
              RTS
;
L104C         STA $11FB
              CMP #$00
              BEQ L103C
              RTS
;
              TAY
              LDA $195A,Y
              STA $14A9
              LDA $1971,Y
              STA $14AA
              LDA #$00
              STA $1501
              STA $1508
              STA $150F
              STA $1516
              STA $151D
              STA $1524
              RTS
;
L1076         DEC $152A,X
L1079         JMP L1359
L107C         BEQ L1079
              LDA $152A,X
              BNE L1076
              LDA #$00
              STA $FD
              LDA $1529,X
              BMI L1095
              CMP $195A,Y
              BCC L1096
              BEQ L1095
              EOR #$FF
L1095         CLC
L1096         ADC #$02
              STA $1529,X
              LSR A
              BCC L10CC
              BCS L10E3
              TYA
              BEQ L10F3
              LDA $195A,Y
              STA $FD
              LDA $14D5,X
              CMP #$02
              BCC L10CC
              BEQ L10E3
              LDY $1503,X
              LDA $152C,X
              SBC $156D,Y
              PHA
              LDA $152D,X
              SBC $15BD,Y
              TAY
              PLA
              BCS L10DC
              ADC $FC
              TYA
              ADC $FD
              BPL L10F3
L10CC         LDA $152C,X
              ADC $FC
              STA $152C,X
              LDA $152D,X
              ADC $FD
              JMP L1356
L10DC         SBC $FC
              TYA
              SBC $FD
              BMI L10F3
L10E3         LDA $152C,X
              SBC $FC
              STA $152C,X
              LDA $152D,X
              SBC $FD
              JMP L1356
L10F3         LDY $1503,X
              JMP L1348
L10F9         STA $1100
              RTS
;
L10FD         LDX #$00
              LDY #$00
              BMI L1152
              TXA
              LDX #$53
L1106         STA $14AB,X
              DEX
              BPL L1106
              STA SID1+$15    ; SID1
              STA SID2+$15    ; SID2
              STA $11A1
              STA $11FB
              STA $1153
              STA $11AD
              STX $1100
              TAX
              JSR L113B
              LDX #$07
              JSR L113B
              LDX #$0E
              JSR L113B
              LDX #$15
              JSR L113B
              LDX #$1C
              JSR L113B
              LDX #$23
L113B         LDA #$11
              STA $1501,X
              LDA #$01
              STA $1502,X
              STA $1504,X
              CPX #$15
              BCS L114F
              JMP L1456
L114F         JMP L148A
L1152         LDY #$00
              BEQ L119B
              LDA #$00
              BNE L117D
              LDA $18F7,Y
              BEQ L1171
              BPL L117A
              ASL A
              STA $11A6
              LDA L1928,Y
              STA $11A1
              LDA $18F8,Y
              BNE L118F
              INY
L1171         LDA L1928,Y
              STA $119C
              JMP L118C
L117A         STA $1157
L117D         LDA L1928,Y
              CLC
              ADC $119C
              STA $119C
              DEC $1157
              BNE L119D
L118C         LDA $18F8,Y
L118F         CMP #$FF
              INY
              TYA
              BCC L1198
              LDA L1928,Y
L1198         STA $1153
L119B         LDA #$00
L119D         STA SID1+$16    ; SID1
              LDA #$00
              STA SID1+$17    ; SID1
              LDA #$00
              ORA #$0F
              STA SID1+$18    ; SID1
              LDY #$00
              BEQ L11F5
              LDA #$00
              BNE L11D7
              LDA $18F7,Y
              BEQ L11CB
              BPL L11D4
              ASL A
              STA $1200
              LDA L1928,Y
              STA $11FB
              LDA $18F8,Y
              BNE L11E9
              INY
L11CB         LDA L1928,Y
              STA $11F6
              JMP L11E6
L11D4         STA $11B1
L11D7         LDA L1928,Y
              CLC
              ADC $11F6
              STA $11F6
              DEC $11B1
              BNE L11F7
L11E6         LDA $18F8,Y
L11E9         CMP #$FF
              INY
              TYA
              BCC L11F2
              LDA L1928,Y
L11F2         STA $11AD
L11F5         LDA #$00
L11F7         STA SID2+$16    ; SID2
              LDA #$00
              STA SID2+$17    ; SID2
              LDA #$00
              ORA $11A8
              STA SID2+$18    ; SID2
              JSR L1220
              LDX #$07
              JSR L1220
              LDX #$0E
              JSR L1220
              LDX #$15
              JSR L1220
              LDX #$1C
              JSR L1220
              LDX #$23
L1220         DEC $1502,X
              BEQ L123F
              BPL L123C
              LDA $1501,X
              CMP #$02
              BCS L1239
              TAY
              EOR #$01
              STA $1501,X
              LDA $14A9,Y
              SBC #$00
L1239         STA $1502,X
L123C         JMP L12F7
L123F         LDY $14B0,X
              LDA $1494,Y
              STA $12EC
              STA $12F5
              LDA $14AE,X
              BNE L1274
              LDY $14FF,X
              LDA $161D,Y
              STA $FC
              LDA $1623,Y
              STA $FD
              LDY $14AB,X
              LDA ($FC),Y
              CMP #$FF
              BCC L126C
              INY
              LDA ($FC),Y
              TAY
              LDA ($FC),Y
L126C         STA $1500,X
              INY
              TYA
              STA $14AB,X
L1274         LDY $1504,X
              LDA $1807,Y
              STA $1558,X
              LDA $14D7,X
              BEQ L12F1
              SEC
              SBC #$60
              STA $1503,X
              LDA #$00
              STA $14D5,X
              STA $14D7,X
              LDA $17F8,Y
              STA $152A,X
              LDA $17E9,Y
              STA $14D6,X
              LDA $14B0,X
              CMP #$03
              BEQ L12F1
              LDA $1816,Y
              STA $14D9,X
              LDA #$FF
              STA $1505,X
              LDA $17CB,Y
              BEQ L12BB
              STA $14DA,X
              LDA #$00
              STA $14DB,X
L12BB         CPX #$15
              LDA $17DA,Y
              BEQ L12D6
              BCS L12CE
              STA $1153
              LDA #$00
              STA $1157
              BCC L12D6
L12CE         STA $11AD
              LDA #$00
              STA $11B1
L12D6         LDA $17BC,Y
              STA $14D8,X
              LDA $179E,Y
              STA $1553,X
              LDA $17AD,Y
              STA $1554,X
              LDA $14B1,X
              JSR L1006
              JMP L142E
L12F1         LDA $14B1,X
              JSR L1006
L12F7         LDY $14D8,X
              BEQ L132C
              LDA $1825,Y
              CMP #$10
              BCS L130D
              CMP $152B,X
              BEQ L1312
              INC $152B,X
              BNE L132C
L130D         SBC #$10
              STA $14D9,X
L1312         LDA $1826,Y
              CMP #$FF
              INY
              TYA
              BCC L131F
              CLC
              LDA $186A,Y
L131F         STA $14D8,X
              LDA #$00
              STA $152B,X
              LDA $1869,Y
              BNE L1340
L132C         LDY $14D5,X
              LDA $14A4,Y
              STA $133E
              LDY $14D6,X
              LDA $1971,Y
              STA $FC
              JMP L107C
L1340         BPL L1347
              ADC $1503,X
              AND #$7F
L1347         TAY
L1348         LDA #$00
              STA $1529,X
              LDA $156D,Y
              STA $152C,X
              LDA $15BD,Y
L1356         STA $152D,X
L1359         LDA $1502,X
              CMP $1558,X
              BEQ L13AF
              LDY $14DA,X
              BEQ L13AC
              ORA $14AE,X
              BEQ L13AC
              LDA $14DB,X
              BNE L1384
              LDA $18AF,Y
              BPL L1381
              STA $152F,X
              LDA $18D3,Y
              STA $152E,X
              JMP L139D
L1381         STA $14DB,X
L1384         LDA $18D3,Y
              CLC
              BPL L138D
              DEC $152F,X
L138D         ADC $152E,X
              STA $152E,X
              BCC L1398
              INC $152F,X
L1398         DEC $14DB,X
              BNE L13AC
L139D         LDA $18B0,Y
              CMP #$FF
              INY
              TYA
              BCC L13A9
              LDA $18D3,Y
L13A9         STA $14DA,X
L13AC         JMP L142E
L13AF         LDY $1500,X
              LDA $1629,Y
              STA $FC
              LDA $16E4,Y
              STA $FD
              LDY $14AE,X
              LDA ($FC),Y
              CMP #$40
              BCC L13DD
              CMP #$60
              BCC L13E7
              CMP #$C0
              BCC L13FB
              LDA $14AF,X
              BNE L13D4
              LDA ($FC),Y
L13D4         ADC #$00
              STA $14AF,X
              BEQ L1425
              BNE L142E
L13DD         STA $1504,X
              INY
              LDA ($FC),Y
              CMP #$60
              BCS L13FB
L13E7         CMP #$50
              AND #$0F
              STA $14B0,X
              BEQ L13F6
              INY
              LDA ($FC),Y
              STA $14B1,X
L13F6         BCS L1425
              INY
              LDA ($FC),Y
L13FB         CMP #$BD
              BCC L1405
              BEQ L1425
              ORA #$F0
              BNE L1422
L1405         STA $14D7,X
              LDA $14B0,X
              CMP #$03
              BEQ L1425
              LDA $1504,X
              CMP #$10
              BCS L1460
              LDA #$0F
              STA $1553,X
              LDA #$00
              STA $1554,X
L1420         LDA #$FE
L1422         STA $1505,X
L1425         INY
              LDA ($FC),Y
              BEQ L142B
              TYA
L142B         STA $14AE,X
L142E         CPX #$15
              BCS L1466
              LDA $1554,X
              STA SID1+$06,X    ; SID1
              LDA $1553,X
              STA SID1+$05,X    ; SID1
              LDA $152E,X
              STA SID1+$02,X    ; SID1
              LDA $152F,X
              STA SID1+$03,X    ; SID1
              LDA $152C,X
              STA SID1+$00,X    ; SID1
              LDA $152D,X
              STA SID1+$01,X    ; SID1
L1456         LDA $14D9,X
              AND $1505,X
              STA SID1+$04,X    ; SID1
              RTS
;
L1460         CMP #$11
              BCC L1420
              BCS L1425
L1466         LDA $1554,X
              STA SID2-$0F,X    ; SID2?
              LDA $1553,X
              STA SID2-$10,X    ; SID2?
              LDA $152E,X
              STA SID2-$13,X    ; SID2?
              LDA $152F,X
              STA SID2-$12,X    ; SID2?
              LDA $152C,X
              STA SID2-$15,X    ; SID2?
              LDA $152D,X
              STA SID2-$14,X    ; SID2?
L148A         LDA $14D9,X
              AND $1505,X
              STA SID2-$11,X    ; SID2?
              RTS
;
L1494         fcb   $06,$0C,$0C,$13
L1498         fcb   $13,$1D,$1D,$21,$21,$21,$2A,$40
L14A0         fcb   $54,$54,$54,$63,$7C,$A3,$A3,$A0
L14A8         fcb   $83,$08,$05,$00,$00,$00,$00,$00
L14B0         fcb   $00,$00,$00,$00,$00,$00,$00,$00
L14B8         fcb   $00,$00,$00,$00,$00,$00,$00,$00
L14C0         fcb   $00,$00,$00,$00,$00,$00,$00,$00
L14C8         fcb   $00,$00,$00,$00,$00,$00,$00,$00
L14D0         fcb   $00,$00,$00,$00,$00,$00,$00,$00
L14D8         fcb   $00,$00,$00,$00,$00,$00,$00,$00
L14E0         fcb   $00,$00,$00,$00,$00,$00,$00,$00
L14E8         fcb   $00,$00,$00,$00,$00,$00,$00,$00
L14F0         fcb   $00,$00,$00,$00,$00,$00,$00,$00
L14F8         fcb   $00,$00,$00,$00,$00,$00,$00,$00
L1500         fcb   $00,$00,$00,$00,$01,$FE,$01,$00
L1508         fcb   $00,$00,$00,$01,$FE,$02,$00,$00
L1510         fcb   $00,$00,$01,$FE,$03,$00,$00,$00
L1518         fcb   $00,$01,$FE,$04,$00,$00,$00,$00
L1520         fcb   $01,$FE,$05,$00,$00,$00,$00,$01
L1528         fcb   $FE,$00,$00,$00,$00,$00,$00,$00
L1530         fcb   $00,$00,$00,$00,$00,$00,$00,$00
L1538         fcb   $00,$00,$00,$00,$00,$00,$00,$00
L1540         fcb   $00,$00,$00,$00,$00,$00,$00,$00
L1548         fcb   $00,$00,$00,$00,$00,$00,$00,$00
L1550         fcb   $00,$00,$00,$00,$00,$00,$00,$00
L1558         fcb   $00,$00,$00,$00,$00,$00,$00,$00
L1560         fcb   $00,$00,$00,$00,$00,$00,$00,$00
L1568         fcb   $00,$00,$00,$00,$00,$00,$00,$00
L1570         fcb   $00,$00,$00,$00,$00,$00,$00,$00
L1578         fcb   $00,$00,$00,$00,$00,$BE,$E8,$14
L1580         fcb   $43,$74,$A9,$E1,$1C,$5A,$9C,$E2
L1588         fcb   $2D,$7C,$CF,$28,$85,$E8,$52,$C1
L1590         fcb   $37,$B4,$39,$C5,$5A,$F7,$9E,$4F
L1598         fcb   $0A,$D1,$A3,$82,$6E,$68,$71,$8A
L15A0         fcb   $B3,$EE,$3C,$9E,$15,$A2,$46,$04
L15A8         fcb   $DC,$D0,$E2,$14,$67,$DD,$79,$3C
L15B0         fcb   $29,$44,$8D,$08,$B8,$A1,$C5,$28
L15B8         fcb   $CD,$BA,$F1,$78,$53,$87,$1A,$10
L15C0         fcb   $71,$42,$89,$4F,$9B,$74,$E2,$F0
L15C8         fcb   $A6,$0E,$33,$20,$FF,$02,$02,$03
L15D0         fcb   $03,$03,$03,$03,$04,$04,$04,$04
L15D8         fcb   $05,$05,$05,$06,$06,$06,$07,$07
L15E0         fcb   $08,$08,$09,$09,$0A,$0A,$0B,$0C
L15E8         fcb   $0D,$0D,$0E,$0F,$10,$11,$12,$13
L15F0         fcb   $14,$15,$17,$18,$1A,$1B,$1D,$1F
L15F8         fcb   $20,$22,$24,$27,$29,$2B,$2E,$31
L1600         fcb   $34,$37,$3A,$3E,$41,$45,$49,$4E
L1608         fcb   $52,$57,$5C,$62,$68,$6E,$75,$7C
L1610         fcb   $83,$8B,$93,$9C,$A5,$AF,$B9,$C4
L1618         fcb   $D0,$DD,$EA,$F8,$FF,$88,$B0,$D8
L1620         fcb   $00,$28,$50,$19,$19,$19,$1A,$1A
L1628         fcb   $1A,$78,$B5,$F5,$36,$73,$B4,$F7
L1630         fcb   $FD,$22,$3F,$63,$87,$AF,$CB,$EB
L1638         fcb   $29,$5F,$93,$B9,$EA,$FD,$10,$26
L1640         fcb   $3B,$51,$61,$78,$9B,$B0,$0A,$25
L1648         fcb   $50,$6F,$92,$B2,$01,$22,$61,$16
L1650         fcb   $4C,$7A,$DB,$0B,$70,$CD,$EC,$11
L1658         fcb   $40,$5D,$90,$D4,$2F,$77,$C0,$E6
L1660         fcb   $13,$1F,$2A,$37,$46,$57,$62,$75
L1668         fcb   $80,$8B,$BC,$CB,$DA,$0E,$1D,$39
L1670         fcb   $6E,$7B,$C1,$D4,$E5,$0F,$1C,$4F
L1678         fcb   $60,$6D,$78,$89,$C9,$D8,$0C,$44
L1680         fcb   $A4,$15,$87,$FB,$5B,$C4,$60,$FF
L1688         fcb   $42,$D6,$4C,$B9,$2A,$8E,$D0,$1D
L1690         fcb   $76,$D0,$81,$32,$98,$57,$FB,$50
L1698         fcb   $BA,$27,$93,$F0,$5A,$BE,$E9,$0D
L16A0         fcb   $32,$49,$E2,$32,$6C,$8C,$9E,$D7
L16A8         fcb   $18,$37,$5F,$7A,$99,$EA,$23,$3C
L16B0         fcb   $71,$A6,$F0,$40,$8D,$DA,$07,$17
L16B8         fcb   $27,$54,$A1,$B9,$C3,$CD,$E9,$31
L16C0         fcb   $81,$AA,$B6,$C2,$EE,$40,$8F,$AE
L16C8         fcb   $C1,$F8,$36,$55,$5F,$69,$A0,$01
L16D0         fcb   $45,$4C,$5F,$6A,$74,$87,$98,$F7
L16D8         fcb   $4C,$88,$CD,$19,$6E,$BC,$EE,$18
L16E0         fcb   $58,$84,$B8,$BB,$1A,$1A,$1A,$1B
L16E8         fcb   $1B,$1B,$1B,$1B,$1C,$1C,$1C,$1C
L16F0         fcb   $1C,$1C,$1C,$1D,$1D,$1D,$1D,$1D
L16F8         fcb   $1D,$1E,$1E,$1E,$1E,$1E,$1E,$1E
L1700         fcb   $1E,$1F,$1F,$1F,$1F,$1F,$1F,$20
L1708         fcb   $20,$20,$21,$21,$21,$21,$22,$22
L1710         fcb   $22,$22,$23,$23,$23,$23,$23,$24
L1718         fcb   $24,$24,$24,$25,$25,$25,$25,$25
L1720         fcb   $25,$25,$25,$25,$25,$25,$25,$25
L1728         fcb   $26,$26,$26,$26,$26,$26,$26,$26
L1730         fcb   $27,$27,$27,$27,$27,$27,$27,$27
L1738         fcb   $27,$28,$28,$28,$29,$29,$29,$2A
L1740         fcb   $2A,$2B,$2B,$2C,$2C,$2D,$2D,$2E
L1748         fcb   $2E,$2E,$2F,$2F,$2F,$30,$31,$31
L1750         fcb   $32,$32,$33,$33,$34,$34,$34,$35
L1758         fcb   $35,$35,$36,$36,$36,$36,$37,$37
L1760         fcb   $37,$37,$37,$38,$38,$38,$38,$38
L1768         fcb   $38,$39,$39,$39,$39,$39,$3A,$3A
L1770         fcb   $3A,$3B,$3B,$3B,$3B,$3B,$3B,$3B
L1778         fcb   $3B,$3B,$3C,$3C,$3C,$3C,$3C,$3C
L1780         fcb   $3D,$3D,$3D,$3D,$3D,$3E,$3E,$3E
L1788         fcb   $3E,$3E,$3F,$3F,$3F,$3F,$3F,$3F
L1790         fcb   $3F,$3F,$3F,$40,$40,$40,$41,$41
L1798         fcb   $41,$41,$42,$42,$42,$42,$42,$50
L17A0         fcb   $07,$20,$00,$00,$00,$0E,$0E,$00
L17A8         fcb   $01,$00,$00,$00,$00,$00,$C9,$CC
L17B0         fcb   $EB,$E6,$E6,$EB,$E8,$E6,$E8,$EA
L17B8         fcb   $ED,$E9,$E9,$A9,$ED,$01,$03,$01
L17C0         fcb   $07,$0D,$13,$16,$1C,$22,$26,$35
L17C8         fcb   $01,$3B,$44,$35,$00,$05,$09,$0D
L17D0         fcb   $11,$00,$15,$17,$00,$1B,$1D,$21
L17D8         fcb   $21,$00,$1D,$00,$00,$00,$04,$0B
L17E0         fcb   $00,$16,$1F,$00,$2A,$00,$00,$00
L17E8         fcb   $00,$00,$02,$00,$01,$00,$00,$00
L17F0         fcb   $00,$00,$00,$00,$09,$0F,$0E,$00
L17F8         fcb   $15,$1F,$00,$34,$00,$00,$00,$00
L1800         fcb   $00,$00,$00,$47,$01,$0B,$00,$1F
L1808         fcb   $02,$02,$02,$04,$02,$02,$04,$04
L1810         fcb   $04,$02,$02,$02,$02,$04,$06,$09
L1818         fcb   $09,$09,$09,$09,$09,$09,$09,$09
L1820         fcb   $09,$09,$09,$09,$09,$09,$51,$FF
L1828         fcb   $71,$05,$70,$FF,$71,$51,$00,$00
L1830         fcb   $00,$FF,$91,$51,$51,$51,$51,$FF
L1838         fcb   $91,$90,$FF,$91,$51,$02,$90,$08
L1840         fcb   $FF,$91,$51,$01,$01,$20,$FF,$91
L1848         fcb   $21,$15,$FF,$91,$51,$51,$50,$50
L1850         fcb   $02,$02,$02,$02,$02,$02,$02,$02
L1858         fcb   $02,$FF,$65,$02,$63,$02,$51,$FF
L1860         fcb   $51,$00,$00,$00,$63,$65,$61,$65
L1868         fcb   $FF,$31,$FF,$80,$00,$80,$80,$80
L1870         fcb   $00,$26,$20,$18,$10,$80,$00,$59
L1878         fcb   $2F,$29,$20,$12,$07,$80,$80,$00
L1880         fcb   $5F,$2B,$27,$5F,$80,$19,$5F,$2A
L1888         fcb   $21,$15,$80,$00,$5F,$65,$80,$00
L1890         fcb   $48,$90,$8E,$8C,$8A,$88,$87,$86
L1898         fcb   $85,$84,$83,$82,$81,$80,$2E,$80
L18A0         fcb   $80,$80,$80,$80,$00,$80,$80,$80
L18A8         fcb   $80,$80,$80,$80,$80,$00,$80,$00
L18B0         fcb   $83,$50,$50,$FF,$85,$40,$40,$FF
L18B8         fcb   $89,$25,$25,$FF,$88,$03,$87,$FF
L18C0         fcb   $88,$02,$85,$FF,$87,$FF,$88,$61
L18C8         fcb   $61,$FF,$88,$FF,$88,$03,$03,$FF
L18D0         fcb   $88,$13,$13,$FF,$00,$25,$DB,$02
L18D8         fcb   $00,$10,$F0,$06,$00,$05,$FB,$0A
L18E0         fcb   $00,$00,$00,$00,$00,$00,$00,$00
L18E8         fcb   $80,$00,$00,$03,$FD,$18,$00,$00
L18F0         fcb   $00,$05,$05,$00,$00,$15,$EB,$22
L18F8         fcb   $A0,$00,$FF,$98,$00,$98,$00,$00
L1900         fcb   $00,$FF,$98,$00,$00,$00,$00,$00
L1908         fcb   $90,$00,$98,$00,$FF,$98,$00,$B0
L1910         fcb   $00,$00,$00,$00,$00,$FF,$98,$00
L1918         fcb   $00,$98,$00,$00,$00,$00,$01,$03
L1920         fcb   $FF,$98,$00,$B0,$00,$00,$00,$00
L1928         fcb   $FF,$F3,$08,$00,$F4,$30,$F4,$02
L1930         fcb   $01,$05,$00,$F4,$88,$20,$04,$02
L1938         fcb   $01,$F4,$35,$F4,$05,$00,$F1,$68
L1940         fcb   $F1,$05,$04,$03,$04,$03,$00,$F1
L1948         fcb   $40,$0F,$F1,$04,$03,$06,$01,$01
L1950         fcb   $00,$27,$F1,$68,$F1,$04,$03,$04
L1958         fcb   $03,$00,$00,$0C,$12,$1F,$00,$00
L1960         fcb   $00,$00,$08,$09,$05,$00,$09,$10
L1968         fcb   $03,$1E,$06,$00,$0C,$06,$07,$0C
L1970         fcb   $00,$00,$18,$04,$1F,$20,$04,$05
L1978         fcb   $38,$07,$45,$06,$50,$AA,$0F,$08
L1980         fcb   $02,$05,$25,$0A,$07,$08,$07,$21
L1988         fcb   $06,$00,$0C,$0D,$13,$A7,$19,$1F
L1990         fcb   $25,$2B,$A7,$19,$1F,$25,$36,$36
L1998         fcb   $40,$40,$40,$40,$5A,$5B,$61,$67
L19A0         fcb   $6D,$73,$83,$89,$8A,$8B,$89,$96
L19A8         fcb   $83,$9C,$A1,$AD,$B3,$B9,$FF,$25
L19B0         fcb   $06,$01,$07,$0E,$14,$A8,$1A,$20
L19B8         fcb   $26,$2C,$A8,$1A,$20,$26,$38,$3F
L19C0         fcb   $41,$4A,$4F,$50,$59,$5C,$62,$68
L19C8         fcb   $6E,$74,$84,$7D,$82,$8C,$91,$97
L19D0         fcb   $84,$9D,$A2,$AE,$B4,$B9,$FF,$25
L19D8         fcb   $06,$02,$09,$0F,$15,$A9,$1B,$21
L19E0         fcb   $27,$2D,$A9,$1B,$21,$27,$39,$3E
L19E8         fcb   $42,$49,$4E,$51,$58,$5D,$63,$69
L19F0         fcb   $6F,$75,$85,$7C,$81,$8D,$92,$98
L19F8         fcb   $85,$9E,$A3,$AF,$B5,$B9,$FF,$25
L1A00         fcb   $06,$03,$08,$10,$16,$AA,$1C,$22
L1A08         fcb   $28,$2E,$BA,$31,$32,$34,$35,$3D
L1A10         fcb   $43,$48,$4D,$52,$57,$5E,$64,$6A
L1A18         fcb   $70,$76,$86,$7B,$80,$8E,$93,$99
L1A20         fcb   $86,$9F,$A4,$B0,$B6,$B9,$FF,$25
L1A28         fcb   $06,$04,$0A,$11,$17,$AB,$1D,$23
L1A30         fcb   $29,$2F,$AB,$1D,$23,$29,$3A,$3C
L1A38         fcb   $44,$47,$4C,$53,$56,$5F,$65,$6B
L1A40         fcb   $71,$77,$87,$7A,$7F,$8F,$94,$9A
L1A48         fcb   $87,$9F,$A5,$B1,$B7,$B9,$FF,$25
L1A50         fcb   $06,$05,$0B,$12,$18,$AC,$1E,$24
L1A58         fcb   $2A,$30,$AC,$1E,$33,$2A,$37,$3B
L1A60         fcb   $45,$46,$4B,$54,$55,$60,$66,$6C
L1A68         fcb   $72,$78,$88,$79,$7E,$90,$95,$9B
L1A70         fcb   $88,$A0,$A6,$B2,$B8,$B9,$FF,$25
L1A78         fcb   $01,$49,$01,$9A,$50,$9A,$BD,$9A
L1A80         fcb   $BD,$9A,$BD,$9A,$BD,$9A,$BD,$BE
L1A88         fcb   $FB,$9A,$BD,$9A,$BD,$9A,$BD,$9A
L1A90         fcb   $BD,$9A,$9A,$BD,$BE,$FA,$95,$BD
L1A98         fcb   $95,$BD,$95,$BD,$97,$FD,$95,$FE
L1AA0         fcb   $BE,$FC,$95,$BD,$95,$BD,$43,$00
L1AA8         fcb   $97,$50,$43,$00,$95,$50,$95,$BD
L1AB0         fcb   $95,$BD,$BE,$FB,$00,$01,$49,$01
L1AB8         fcb   $97,$50,$97,$BD,$97,$BD,$97,$BD
L1AC0         fcb   $97,$BD,$97,$BD,$BE,$FB,$97,$BD
L1AC8         fcb   $97,$BD,$99,$BD,$97,$BD,$95,$94
L1AD0         fcb   $BD,$BE,$FA,$99,$BD,$99,$BD,$99
L1AD8         fcb   $BD,$9A,$FD,$99,$FE,$BE,$4B,$00
L1AE0         fcb   $89,$50,$89,$BD,$4A,$01,$9A,$50
L1AE8         fcb   $9A,$BD,$9A,$BD,$9A,$BD,$95,$BD
L1AF0         fcb   $95,$BD,$BE,$FB,$00,$01,$49,$01
L1AF8         fcb   $95,$50,$95,$BD,$95,$BD,$95,$BD
L1B00         fcb   $95,$BD,$95,$FE,$BE,$FC,$94,$BD
L1B08         fcb   $94,$BD,$95,$BD,$94,$BD,$92,$90
L1B10         fcb   $BD,$BE,$FA,$93,$BD,$93,$BD,$93
L1B18         fcb   $BD,$93,$FD,$95,$FE,$BE,$FC,$92
L1B20         fcb   $BD,$92,$BD,$43,$00,$93,$50,$43
L1B28         fcb   $00,$92,$50,$43,$00,$90,$50,$43
L1B30         fcb   $00,$8E,$50,$BE,$FB,$00,$01,$49
L1B38         fcb   $01,$95,$50,$95,$BD,$95,$BD,$95
L1B40         fcb   $BD,$95,$BD,$95,$FE,$BE,$FC,$49
L1B48         fcb   $01,$94,$50,$94,$BD,$95,$BD,$94
L1B50         fcb   $BD,$92,$94,$BD,$BE,$FA,$90,$BD
L1B58         fcb   $90,$BD,$90,$BD,$90,$FD,$89,$FD
L1B60         fcb   $89,$BD,$89,$BD,$8E,$BD,$8E,$BD
L1B68         fcb   $90,$BD,$8E,$BD,$8D,$BD,$89,$BD
L1B70         fcb   $BE,$FB,$00,$01,$49,$01,$92,$50
L1B78         fcb   $92,$BD,$92,$BD,$92,$BD,$92,$BD
L1B80         fcb   $92,$FE,$BE,$FC,$90,$BD,$90,$BD
L1B88         fcb   $90,$BD,$92,$BD,$8E,$90,$BD,$BE
L1B90         fcb   $FA,$93,$BD,$93,$BD,$93,$BD,$93
L1B98         fcb   $FD,$90,$FD,$BE,$FD,$92,$BD,$92
L1BA0         fcb   $BD,$43,$00,$93,$50,$43,$00,$92
L1BA8         fcb   $50,$43,$00,$90,$50,$43,$00,$8E
L1BB0         fcb   $50,$BE,$FB,$00,$01,$4F,$1E,$97
L1BB8         fcb   $50,$97,$BD,$97,$BD,$97,$BD,$97
L1BC0         fcb   $BD,$97,$BD,$BE,$FB,$49,$01,$8E
L1BC8         fcb   $50,$8E,$BD,$8E,$BD,$8E,$BD,$8B
L1BD0         fcb   $8E,$BD,$BE,$FA,$95,$BD,$95,$BD
L1BD8         fcb   $95,$BD,$97,$FD,$95,$FD,$BE,$FD
L1BE0         fcb   $95,$BD,$95,$BD,$43,$00,$97,$50
L1BE8         fcb   $43,$00,$95,$50,$43,$00,$93,$50
L1BF0         fcb   $43,$00,$92,$50,$BE,$FB,$00,$50
L1BF8         fcb   $5E,$03,$5A,$01,$00,$02,$4F,$10
L1C00         fcb   $92,$50,$FA,$92,$F9,$92,$F9,$92
L1C08         fcb   $F9,$89,$E1,$97,$F9,$97,$FD,$9A
L1C10         fcb   $FD,$9C,$FD,$9F,$FD,$9A,$FD,$9F
L1C18         fcb   $FD,$93,$F9,$93,$FD,$93,$F9,$93
L1C20         fcb   $F5,$00,$04,$5B,$00,$50,$F2,$02
L1C28         fcb   $97,$F3,$7F,$81,$82,$E1,$93,$FD
L1C30         fcb   $93,$F5,$98,$F9,$97,$F9,$90,$F9
L1C38         fcb   $90,$FD,$90,$F9,$90,$F5,$00,$01
L1C40         fcb   $4B,$00,$92,$50,$FE,$92,$FD,$92
L1C48         fcb   $FD,$92,$F5,$BE,$FD,$49,$01,$92
L1C50         fcb   $50,$FE,$92,$FD,$92,$FD,$93,$FD
L1C58         fcb   $95,$F9,$89,$F9,$87,$DD,$90,$E5
L1C60         fcb   $9A,$FD,$00,$01,$49,$01,$8E,$50
L1C68         fcb   $FE,$8E,$FD,$8E,$FD,$8E,$F5,$BE
L1C70         fcb   $FD,$49,$00,$8E,$50,$FE,$8E,$FD
L1C78         fcb   $8E,$FD,$90,$FD,$92,$F9,$8C,$F9
L1C80         fcb   $8E,$DD,$93,$E5,$9E,$FD,$00,$01
L1C88         fcb   $49,$01,$8B,$50,$FE,$8B,$FD,$8B
L1C90         fcb   $FD,$8B,$F5,$BE,$FD,$8B,$FD,$89
L1C98         fcb   $FD,$89,$FD,$8B,$FD,$8C,$F9,$8E
L1CA0         fcb   $F9,$97,$DD,$03,$97,$FD,$97,$FD
L1CA8         fcb   $97,$FD,$97,$F9,$97,$F5,$00,$02
L1CB0         fcb   $40,$8B,$FD,$8B,$FD,$8E,$FD,$8B
L1CB8         fcb   $FD,$8E,$FD,$8B,$FD,$8E,$FD,$8B
L1CC0         fcb   $FD,$8C,$E1,$87,$E1,$84,$E5,$01
L1CC8         fcb   $92,$FD,$00,$01,$40,$A1,$EE,$BE
L1CD0         fcb   $F4,$02,$9B,$F9,$9A,$F9,$99,$F9
L1CD8         fcb   $9A,$F9,$9B,$F9,$9A,$F9,$99,$F9
L1CE0         fcb   $9A,$F9,$97,$F9,$97,$F9,$95,$F9
L1CE8         fcb   $9A,$F9,$00,$02,$46,$CD,$89,$50
L1CF0         fcb   $F0,$46,$00,$BE,$50,$01,$95,$FD
L1CF8         fcb   $98,$FD,$9A,$FD,$9B,$FD,$9B,$FD
L1D00         fcb   $9A,$FD,$BE,$FD,$99,$FD,$99,$FD
L1D08         fcb   $9A,$FD,$BE,$FD,$9B,$FD,$9B,$FD
L1D10         fcb   $9A,$FC,$BE,$FE,$99,$FD,$99,$FD
L1D18         fcb   $9A,$FC,$BE,$FE,$93,$F9,$93,$FD
L1D20         fcb   $93,$FD,$92,$F9,$95,$FC,$BE,$FE
L1D28         fcb   $00,$01,$40,$99,$EE,$BE,$92,$FD
L1D30         fcb   $95,$FD,$95,$FD,$96,$FD,$96,$FD
L1D38         fcb   $95,$FC,$BE,$FE,$94,$FD,$94,$FD
L1D40         fcb   $95,$FC,$BE,$FE,$96,$FD,$96,$FD
L1D48         fcb   $95,$FC,$BE,$FE,$94,$FD,$94,$FD
L1D50         fcb   $95,$FC,$BE,$FE,$90,$F9,$90,$FD
L1D58         fcb   $90,$FD,$8E,$F9,$92,$F9,$00,$01
L1D60         fcb   $40,$90,$EF,$BE,$F3,$93,$FD,$93
L1D68         fcb   $FD,$92,$FC,$BE,$FE,$91,$FD,$91
L1D70         fcb   $FD,$92,$FD,$BE,$FD,$93,$FD,$93
L1D78         fcb   $FD,$92,$FC,$BE,$FE,$91,$FD,$91
L1D80         fcb   $FD,$92,$FC,$BE,$FE,$03,$97,$FD
L1D88         fcb   $97,$FD,$97,$FD,$97,$FD,$95,$F9
L1D90         fcb   $9A,$F9,$00,$01,$40,$9C,$EF,$BE
L1D98         fcb   $BD,$8E,$FD,$92,$FD,$92,$FD,$02
L1DA0         fcb   $96,$F9,$95,$F9,$94,$F9,$95,$F9
L1DA8         fcb   $96,$F9,$95,$F9,$94,$F9,$95,$F9
L1DB0         fcb   $93,$F9,$93,$F9,$92,$F9,$92,$F9
L1DB8         fcb   $00,$03,$40,$95,$FD,$95,$FD,$97
L1DC0         fcb   $FD,$95,$BD,$43,$00,$93,$50,$43
L1DC8         fcb   $00,$90,$50,$FD,$BE,$F6,$02,$93
L1DD0         fcb   $F9,$92,$F9,$91,$F9,$92,$F9,$93
L1DD8         fcb   $F9,$92,$F9,$91,$F9,$92,$F9,$8E
L1DE0         fcb   $FD,$8E,$F9,$8E,$F9,$8E,$F9,$8E
L1DE8         fcb   $FD,$00,$02,$40,$94,$FD,$8E,$FD
L1DF0         fcb   $94,$FD,$8E,$FD,$95,$F9,$95,$F9
L1DF8         fcb   $90,$F1,$95,$F1,$00,$02,$40,$97
L1E00         fcb   $F9,$97,$F9,$90,$F9,$90,$F9,$93
L1E08         fcb   $F9,$93,$FD,$95,$FD,$95,$F1,$00
L1E10         fcb   $01,$40,$91,$FD,$91,$FD,$91,$FD
L1E18         fcb   $91,$FD,$90,$F9,$90,$FD,$90,$FD
L1E20         fcb   $99,$F1,$02,$99,$F1,$00,$03,$40
L1E28         fcb   $94,$FD,$94,$FD,$94,$FD,$95,$FD
L1E30         fcb   $95,$F9,$89,$FD,$90,$FD,$99,$E9
L1E38         fcb   $8D,$F9,$00,$01,$40,$8E,$FD,$8E
L1E40         fcb   $FD,$8E,$FD,$8E,$FD,$8D,$F9,$8D
L1E48         fcb   $FD,$8D,$FD,$95,$F1,$02,$9F,$F1
L1E50         fcb   $00,$50,$F1,$02,$8D,$FD,$8D,$F9
L1E58         fcb   $8D,$FD,$01,$90,$F1,$02,$9C,$F1
L1E60         fcb   $00,$02,$40,$82,$E1,$7F,$F1,$99
L1E68         fcb   $F9,$97,$F9,$84,$F1,$9E,$F9,$9C
L1E70         fcb   $F9,$84,$F1,$99,$F5,$9C,$FD,$00
L1E78         fcb   $02,$40,$89,$FD,$89,$F1,$89,$F9
L1E80         fcb   $89,$FD,$8B,$FD,$8B,$F1,$8B,$F9
L1E88         fcb   $8B,$FD,$90,$FD,$90,$F1,$90,$FD
L1E90         fcb   $90,$FD,$90,$FD,$90,$FD,$90,$F5
L1E98         fcb   $90,$F1,$00,$02,$40,$8E,$F9,$8E
L1EA0         fcb   $E9,$8E,$F9,$8E,$E9,$93,$F9,$93
L1EA8         fcb   $E9,$93,$F9,$93,$F5,$93,$F5,$00
L1EB0         fcb   $03,$41,$04,$8E,$43,$04,$92,$BD
L1EB8         fcb   $53,$00,$40,$92,$FB,$BE,$EF,$8E
L1EC0         fcb   $FD,$43,$00,$90,$50,$FE,$43,$00
L1EC8         fcb   $92,$50,$92,$FA,$BE,$F2,$92,$BD
L1ED0         fcb   $92,$BD,$43,$00,$93,$50,$FE,$95
L1ED8         fcb   $BD,$43,$00,$93,$50,$FE,$43,$00
L1EE0         fcb   $92,$50,$FE,$43,$00,$90,$50,$FC
L1EE8         fcb   $BE,$FD,$90,$FD,$43,$00,$92,$50
L1EF0         fcb   $FE,$93,$BD,$43,$00,$95,$50,$FE
L1EF8         fcb   $43,$00,$93,$50,$FE,$43,$00,$92
L1F00         fcb   $50,$FE,$43,$00,$90,$50,$FC,$BE
L1F08         fcb   $F5,$00,$02,$40,$92,$F5,$92,$FD
L1F10         fcb   $97,$F9,$95,$F9,$92,$F5,$92,$ED
L1F18         fcb   $97,$F5,$97,$ED,$97,$F5,$97,$FD
L1F20         fcb   $95,$F9,$95,$F9,$00,$04,$4F,$10
L1F28         fcb   $76,$50,$FC,$56,$EE,$40,$BE,$E8
L1F30         fcb   $73,$FB,$56,$EE,$40,$BE,$E8,$78
L1F38         fcb   $FB,$56,$EE,$40,$BE,$E8,$78,$FB
L1F40         fcb   $56,$EE,$40,$BE,$F8,$7D,$FB,$56
L1F48         fcb   $EE,$40,$BE,$FB,$52,$05,$FE,$00
L1F50         fcb   $02,$40,$82,$E1,$7F,$F1,$99,$F9
L1F58         fcb   $97,$F9,$97,$F5,$97,$FD,$83,$FD
L1F60         fcb   $97,$FD,$82,$FD,$97,$FD,$97,$F5
L1F68         fcb   $97,$FD,$8C,$F9,$8B,$F9,$00,$02
L1F70         fcb   $40,$89,$FD,$89,$F1,$89,$F9,$89
L1F78         fcb   $FD,$8B,$FD,$8B,$F1,$8B,$F9,$8B
L1F80         fcb   $FD,$8B,$F1,$8B,$F9,$8B,$F9,$87
L1F88         fcb   $FD,$90,$F5,$90,$FD,$97,$FD,$90
L1F90         fcb   $F9,$00,$02,$40,$8E,$F9,$8E,$E9
L1F98         fcb   $8E,$F9,$8E,$E9,$90,$FD,$90,$F5
L1FA0         fcb   $8F,$F9,$8E,$BD,$BE,$FC,$56,$00
L1FA8         fcb   $06,$40,$B1,$F1,$02,$93,$F9,$90
L1FB0         fcb   $F9,$00,$03,$41,$04,$8E,$43,$04
L1FB8         fcb   $92,$50,$41,$04,$90,$43,$00,$92
L1FC0         fcb   $50,$F5,$BE,$FA,$92,$FD,$95,$FD
L1FC8         fcb   $41,$04,$97,$43,$00,$99,$50,$FD
L1FD0         fcb   $43,$00,$97,$50,$97,$FA,$BE,$F4
L1FD8         fcb   $97,$FD,$9A,$FE,$52,$06,$43,$00
L1FE0         fcb   $9A,$50,$FE,$9A,$FD,$9A,$FD,$9A
L1FE8         fcb   $FB,$43,$00,$97,$50,$43,$07,$93
L1FF0         fcb   $FE,$53,$00,$50,$BD,$43,$00,$92
L1FF8         fcb   $50,$43,$00,$90,$50,$F9,$BE,$EA
L2000         fcb   $00,$02,$40,$92,$F5,$92,$FD,$97
L2008         fcb   $F9,$95,$F9,$92,$F5,$92,$ED,$93
L2010         fcb   $F9,$93,$F9,$93,$F9,$93,$F9,$93
L2018         fcb   $F9,$93,$F9,$93,$F9,$93,$FD,$97
L2020         fcb   $FD,$00,$04,$4F,$10,$76,$50,$FC
L2028         fcb   $56,$EE,$40,$BE,$E8,$73,$FB,$56
L2030         fcb   $EE,$40,$BE,$E8,$84,$FC,$56,$EE
L2038         fcb   $40,$BE,$F7,$83,$FD,$56,$EE,$40
L2040         fcb   $BE,$FE,$82,$FD,$56,$EE,$40,$BE
L2048         fcb   $FE,$05,$81,$FD,$56,$EE,$40,$BE
L2050         fcb   $F6,$04,$80,$FD,$56,$EE,$40,$BE
L2058         fcb   $FE,$7F,$FD,$56,$EE,$40,$BE,$FE
L2060         fcb   $00,$08,$40,$7C,$BD,$BE,$BD,$09
L2068         fcb   $4B,$00,$7D,$50,$BE,$BD,$07,$7C
L2070         fcb   $BD,$BE,$BD,$09,$4B,$00,$7D,$50
L2078         fcb   $BE,$BD,$08,$7C,$BD,$BE,$BD,$7C
L2080         fcb   $BD,$BE,$BD,$07,$7C,$BD,$BE,$BD
L2088         fcb   $09,$4B,$00,$7D,$50,$BE,$BD,$08
L2090         fcb   $7C,$BD,$BE,$BD,$09,$4B,$00,$7D
L2098         fcb   $50,$BE,$BD,$07,$7C,$BD,$BE,$BD
L20A0         fcb   $09,$4B,$00,$7D,$50,$BE,$BD,$08
L20A8         fcb   $7C,$BD,$BE,$BD,$7C,$BD,$BE,$BD
L20B0         fcb   $07,$7C,$BD,$BE,$BD,$09,$4B,$00
L20B8         fcb   $7D,$50,$BE,$BD,$08,$7C,$BD,$BE
L20C0         fcb   $BD,$09,$4B,$00,$7D,$50,$FE,$07
L20C8         fcb   $7C,$BD,$BE,$BD,$09,$4B,$00,$7D
L20D0         fcb   $50,$BE,$BD,$08,$7C,$BD,$BE,$BD
L20D8         fcb   $7C,$BD,$BE,$BD,$07,$7C,$BD,$BE
L20E0         fcb   $BD,$09,$4B,$00,$7D,$50,$BE,$BD
L20E8         fcb   $08,$7C,$BD,$BE,$BD,$09,$4B,$00
L20F0         fcb   $7D,$50,$FE,$07,$7C,$BD,$BE,$BD
L20F8         fcb   $09,$4B,$00,$7D,$50,$BE,$BD,$08
L2100         fcb   $86,$BD,$BE,$BD,$0A,$88,$BD,$BE
L2108         fcb   $BD,$07,$7C,$BD,$0A,$86,$BD,$4B
L2110         fcb   $00,$81,$50,$BE,$BD,$00,$02,$40
L2118         fcb   $93,$F5,$93,$F9,$93,$FD,$8E,$FD
L2120         fcb   $8E,$FD,$90,$FD,$90,$F1,$90,$F9
L2128         fcb   $90,$FD,$8C,$FD,$8C,$FD,$8C,$FD
L2130         fcb   $8C,$FD,$8C,$FD,$8C,$FD,$8C,$FD
L2138         fcb   $8C,$FD,$8E,$FB,$8E,$BD,$8E,$FB
L2140         fcb   $8E,$BD,$8E,$FB,$8E,$BD,$8E,$BD
L2148         fcb   $8E,$FC,$BE,$00,$02,$4F,$10,$8B
L2150         fcb   $50,$FA,$97,$F9,$97,$F9,$92,$F9
L2158         fcb   $93,$F9,$93,$E9,$90,$FD,$90,$FD
L2160         fcb   $90,$FD,$90,$FD,$90,$F9,$90,$F9
L2168         fcb   $92,$FB,$92,$BD,$92,$FB,$92,$BD
L2170         fcb   $92,$FB,$92,$BD,$92,$FD,$92,$FE
L2178         fcb   $BE,$00,$03,$41,$04,$95,$43,$04
L2180         fcb   $97,$50,$41,$04,$95,$43,$00,$97
L2188         fcb   $50,$F0,$BE,$BD,$95,$FD,$97,$BD
L2190         fcb   $43,$00,$98,$50,$43,$00,$97,$50
L2198         fcb   $ED,$BE,$FA,$97,$BD,$43,$00,$97
L21A0         fcb   $50,$43,$00,$98,$50,$FC,$9A,$BD
L21A8         fcb   $43,$00,$98,$50,$BD,$52,$04,$43
L21B0         fcb   $07,$97,$FE,$53,$00,$41,$07,$93
L21B8         fcb   $43,$00,$95,$50,$FC,$BE,$FA,$8E
L21C0         fcb   $BD,$8E,$FD,$95,$FD,$95,$FD,$97
L21C8         fcb   $BD,$97,$FB,$43,$00,$98,$50,$FE
L21D0         fcb   $98,$FD,$43,$00,$9A,$50,$43,$00
L21D8         fcb   $98,$50,$00,$02,$40,$8E,$FD,$8E
L21E0         fcb   $FD,$9A,$FD,$8E,$FD,$9A,$FD,$8E
L21E8         fcb   $FD,$95,$F9,$97,$F5,$97,$FD,$9E
L21F0         fcb   $F9,$9C,$F9,$95,$FD,$95,$FD,$95
L21F8         fcb   $FD,$94,$FD,$93,$F9,$92,$F9,$95
L2200         fcb   $F9,$95,$F9,$95,$F8,$95,$FE,$95
L2208         fcb   $FE,$BE,$00,$04,$4F,$10,$87,$50
L2210         fcb   $FC,$56,$EE,$40,$BE,$F0,$4F,$10
L2218         fcb   $86,$50,$FC,$56,$EE,$40,$BE,$4F
L2220         fcb   $10,$84,$50,$FC,$56,$EE,$40,$BE
L2228         fcb   $E8,$4F,$10,$89,$50,$FC,$56,$EE
L2230         fcb   $40,$BE,$FC,$4F,$10,$88,$50,$56
L2238         fcb   $EE,$40,$BE,$4F,$10,$87,$50,$56
L2240         fcb   $EE,$40,$BE,$FC,$4F,$10,$86,$50
L2248         fcb   $BD,$56,$EE,$40,$BE,$FD,$4F,$10
L2250         fcb   $82,$50,$56,$EE,$50,$F6,$4F,$10
L2258         fcb   $82,$50,$4F,$10,$82,$50,$56,$EE
L2260         fcb   $50,$FE,$4F,$10,$82,$50,$4F,$10
L2268         fcb   $82,$50,$56,$EE,$50,$FD,$BE,$00
L2270         fcb   $08,$40,$7C,$BD,$BE,$BD,$09,$4B
L2278         fcb   $00,$7D,$50,$FE,$07,$7C,$BD,$BE
L2280         fcb   $BD,$09,$4B,$00,$7D,$50,$FE,$08
L2288         fcb   $7C,$BD,$BE,$BD,$7C,$BD,$BE,$BD
L2290         fcb   $07,$7C,$BD,$BE,$BD,$09,$4B,$00
L2298         fcb   $7D,$50,$FE,$08,$7C,$BD,$BE,$BD
L22A0         fcb   $09,$4B,$00,$7D,$50,$FE,$07,$7C
L22A8         fcb   $BD,$BE,$BD,$09,$4B,$00,$7D,$50
L22B0         fcb   $FE,$08,$7C,$F5,$5B,$00,$50,$FA
L22B8         fcb   $5B,$00,$50,$FA,$5B,$00,$50,$F2
L22C0         fcb   $5B,$00,$50,$FA,$5B,$00,$50,$FA
L22C8         fcb   $5B,$00,$50,$FE,$00,$02,$40,$8E
L22D0         fcb   $F9,$9A,$FD,$8E,$FD,$9A,$F5,$8E
L22D8         fcb   $FD,$8B,$F9,$8B,$F9,$93,$F1,$87
L22E0         fcb   $FD,$93,$F5,$9C,$F9,$9A,$F9,$99
L22E8         fcb   $F9,$98,$F9,$00,$02,$40,$93,$FD
L22F0         fcb   $93,$F9,$93,$FD,$92,$FD,$92,$F9
L22F8         fcb   $92,$FD,$90,$FD,$90,$FD,$90,$FD
L2300         fcb   $90,$FD,$8F,$F1,$8B,$F9,$97,$F9
L2308         fcb   $98,$F9,$97,$F9,$96,$F9,$95,$F9
L2310         fcb   $00,$50,$BD,$03,$97,$F7,$95,$BD
L2318         fcb   $43,$00,$97,$50,$43,$00,$9A,$50
L2320         fcb   $F6,$95,$BD,$97,$BD,$93,$F9,$BE
L2328         fcb   $FD,$8E,$BD,$8E,$BD,$8F,$FD,$91
L2330         fcb   $BD,$8F,$FD,$91,$BD,$8F,$FD,$8E
L2338         fcb   $F8,$56,$DD,$50,$FC,$BE,$E0,$00
L2340         fcb   $02,$40,$97,$F9,$97,$F9,$95,$F9
L2348         fcb   $95,$F9,$93,$F9,$93,$F9,$98,$F1
L2350         fcb   $8E,$F5,$9A,$F9,$9F,$F9,$9F,$F9
L2358         fcb   $9F,$F9,$9F,$FD,$00,$04,$4F,$10
L2360         fcb   $87,$50,$FC,$56,$EE,$40,$BE,$F8
L2368         fcb   $4F,$10,$86,$50,$FD,$56,$EE,$40
L2370         fcb   $BE,$F7,$4F,$10,$84,$50,$FC,$56
L2378         fcb   $EE,$40,$BE,$F8,$4F,$10,$80,$50
L2380         fcb   $FC,$56,$EC,$50,$FA,$51,$05,$BD
L2388         fcb   $43,$00,$87,$50,$FA,$BE,$D9,$00
L2390         fcb   $03,$41,$04,$8E,$43,$04,$92,$BD
L2398         fcb   $53,$00,$90,$92,$50,$F5,$BE,$F7
L23A0         fcb   $8E,$FD,$43,$00,$90,$50,$BE,$BD
L23A8         fcb   $92,$BD,$92,$FC,$BE,$F0,$92,$FD
L23B0         fcb   $93,$BD,$95,$FE,$BE,$FE,$93,$FD
L23B8         fcb   $92,$BD,$90,$FB,$BE,$FD,$90,$FD
L23C0         fcb   $92,$FD,$93,$BD,$95,$FE,$BE,$FE
L23C8         fcb   $93,$FD,$92,$FD,$92,$FD,$43,$00
L23D0         fcb   $90,$50,$F6,$00,$03,$41,$04,$8E
L23D8         fcb   $43,$04,$92,$50,$41,$04,$90,$43
L23E0         fcb   $00,$92,$50,$FA,$90,$BD,$8E,$BD
L23E8         fcb   $90,$BD,$43,$00,$92,$50,$FB,$BE
L23F0         fcb   $FE,$95,$FD,$41,$04,$97,$43,$00
L23F8         fcb   $99,$50,$FD,$43,$00,$97,$50,$97
L2400         fcb   $FA,$BE,$F4,$97,$BD,$97,$BD,$9A
L2408         fcb   $FE,$52,$06,$43,$00,$9A,$50,$FE
L2410         fcb   $9A,$FD,$9A,$FD,$9A,$FB,$43,$00
L2418         fcb   $97,$50,$43,$07,$93,$FE,$53,$00
L2420         fcb   $50,$BD,$43,$00,$92,$50,$FE,$43
L2428         fcb   $00,$90,$50,$F9,$BE,$EC,$00,$04
L2430         fcb   $4F,$10,$76,$50,$FC,$56,$EE,$40
L2438         fcb   $BE,$E8,$73,$FB,$56,$EE,$40,$BE
L2440         fcb   $E8,$84,$FC,$56,$EE,$40,$BE,$F7
L2448         fcb   $83,$FD,$56,$EE,$40,$BE,$FE,$82
L2450         fcb   $FD,$56,$EE,$40,$BE,$FE,$05,$4B
L2458         fcb   $00,$81,$50,$FE,$56,$EE,$40,$BE
L2460         fcb   $F6,$04,$4B,$00,$80,$50,$FE,$56
L2468         fcb   $EE,$40,$BE,$FE,$4B,$00,$7F,$50
L2470         fcb   $FE,$56,$EE,$40,$BE,$FE,$00,$03
L2478         fcb   $41,$04,$95,$43,$04,$97,$50,$41
L2480         fcb   $04,$95,$43,$00,$97,$50,$F0,$BE
L2488         fcb   $BD,$95,$FD,$97,$BD,$43,$00,$98
L2490         fcb   $50,$43,$00,$97,$50,$ED,$BE,$F6
L2498         fcb   $98,$FB,$97,$BD,$43,$00,$97,$50
L24A0         fcb   $FE,$95,$FE,$95,$F8,$BE,$FB,$8E
L24A8         fcb   $BD,$8E,$FD,$95,$FD,$95,$FD,$97
L24B0         fcb   $FD,$97,$BD,$43,$00,$98,$50,$98
L24B8         fcb   $FD,$98,$FD,$9A,$BD,$98,$BE,$00
L24C0         fcb   $50,$BD,$03,$97,$FC,$BE,$F6,$0B
L24C8         fcb   $41,$04,$95,$53,$04,$97,$FD,$53
L24D0         fcb   $00,$FE,$50,$FD,$43,$00,$95,$50
L24D8         fcb   $BD,$43,$00,$93,$50,$BD,$43,$00
L24E0         fcb   $9A,$50,$E9,$97,$F7,$00,$08,$4E
L24E8         fcb   $08,$7C,$50,$BE,$FA,$09,$4B,$00
L24F0         fcb   $7D,$50,$F9,$07,$7C,$BD,$BE,$FA
L24F8         fcb   $09,$4B,$00,$7D,$50,$F9,$08,$7C
L2500         fcb   $BD,$BE,$FA,$7C,$BD,$BE,$FA,$07
L2508         fcb   $7C,$BD,$BE,$FA,$09,$4B,$00,$7D
L2510         fcb   $50,$F9,$00,$04,$4B,$00,$7B,$50
L2518         fcb   $DE,$4B,$00,$86,$50,$DE,$00,$02
L2520         fcb   $40,$8E,$EF,$9A,$EF,$9A,$E6,$92
L2528         fcb   $F8,$00,$02,$40,$87,$F8,$87,$F8
L2530         fcb   $9F,$EF,$9A,$EF,$95,$EF,$00,$02
L2538         fcb   $40,$8B,$EF,$97,$EF,$95,$F8,$92
L2540         fcb   $F8,$9A,$F8,$8E,$F8,$00,$04,$4B
L2548         fcb   $00,$84,$50,$E2,$4B,$00,$7F,$50
L2550         fcb   $FE,$4B,$00,$84,$50,$DE,$00,$02
L2558         fcb   $40,$97,$E6,$97,$F8,$9E,$EF,$9C
L2560         fcb   $EF,$00,$0B,$40,$9C,$E2,$BE,$FC
L2568         fcb   $9C,$F8,$9E,$FD,$9F,$FC,$9C,$F8
L2570         fcb   $9E,$FD,$9F,$FC,$00,$02,$40,$93
L2578         fcb   $EF,$93,$E6,$90,$EF,$8B,$F8,$00
L2580         fcb   $02,$40,$90,$F8,$90,$DD,$8B,$EF
L2588         fcb   $90,$F8,$00,$08,$4E,$0A,$7C,$50
L2590         fcb   $BE,$F7,$09,$4B,$00,$7D,$50,$F6
L2598         fcb   $07,$7C,$BD,$BE,$F7,$09,$4B,$00
L25A0         fcb   $7D,$50,$F6,$08,$4E,$0A,$7C,$50
L25A8         fcb   $BE,$F7,$09,$4B,$00,$7D,$50,$F6
L25B0         fcb   $07,$7C,$BD,$BE,$F7,$09,$4B,$00
L25B8         fcb   $7D,$50,$F6,$00,$02,$40,$90,$F5
L25C0         fcb   $90,$F5,$90,$F5,$90,$F5,$90,$E9
L25C8         fcb   $90,$E9,$00,$02,$40,$8C,$F5,$8C
L25D0         fcb   $F5,$8C,$F5,$8C,$F5,$8C,$E9,$8C
L25D8         fcb   $E9,$00,$0B,$41,$00,$A0,$50,$BD
L25E0         fcb   $43,$04,$A1,$FA,$53,$00,$50,$F0
L25E8         fcb   $51,$0B,$BD,$52,$0B,$BD,$51,$0B
L25F0         fcb   $BD,$52,$0B,$BD,$40,$9C,$F5,$A1
L25F8         fcb   $FB,$A3,$FB,$A4,$FB,$A6,$FB,$A8
L2600         fcb   $F2,$51,$0B,$50,$52,$0B,$BD,$51
L2608         fcb   $0B,$BD,$52,$0B,$FE,$00,$02,$40
L2610         fcb   $95,$F5,$95,$F5,$95,$F5,$94,$F5
L2618         fcb   $93,$E9,$92,$E9,$00,$04,$4B,$00
L2620         fcb   $7D,$50,$F6,$02,$90,$F5,$90,$F5
L2628         fcb   $04,$4B,$00,$7C,$50,$F6,$4B,$00
L2630         fcb   $7B,$50,$EA,$4B,$00,$7A,$50,$EA
L2638         fcb   $00,$04,$4B,$00,$82,$50,$F0,$4B
L2640         fcb   $00,$82,$50,$FC,$4B,$00,$82,$50
L2648         fcb   $F0,$0B,$4B,$00,$82,$50,$FC,$04
L2650         fcb   $4B,$00,$82,$50,$F0,$0B,$4B,$00
L2658         fcb   $82,$50,$FC,$04,$4B,$00,$82,$50
L2660         fcb   $FC,$0B,$4B,$00,$82,$50,$FC,$04
L2668         fcb   $4B,$00,$82,$50,$F6,$00,$02,$40
L2670         fcb   $95,$E9,$95,$E9,$95,$E9,$95,$F5
L2678         fcb   $95,$F5,$00,$50,$0B,$A6,$FC,$A4
L2680         fcb   $FC,$A3,$FD,$A4,$FD,$A3,$FE,$A4
L2688         fcb   $BD,$A3,$FE,$A1,$FD,$A3,$FE,$43
L2690         fcb   $00,$A1,$50,$FE,$43,$00,$9F,$50
L2698         fcb   $FE,$9E,$FD,$43,$00,$9F,$50,$BD
L26A0         fcb   $43,$00,$9E,$50,$BD,$43,$00,$9F
L26A8         fcb   $50,$FE,$43,$00,$9E,$50,$BD,$43
L26B0         fcb   $00,$9C,$50,$FE,$9E,$FD,$43,$00
L26B8         fcb   $9C,$50,$FE,$43,$00,$9A,$50,$E9
L26C0         fcb   $00,$02,$40,$92,$EF,$92,$FB,$92
L26C8         fcb   $EF,$92,$FB,$92,$EF,$92,$FB,$92
L26D0         fcb   $F5,$92,$F5,$00,$02,$40,$8E,$EF
L26D8         fcb   $8E,$FB,$8E,$EF,$8E,$FB,$8E,$EF
L26E0         fcb   $8E,$FB,$8E,$E9,$00,$04,$4B,$00
L26E8         fcb   $87,$50,$F6,$4B,$00,$87,$50,$F6
L26F0         fcb   $4B,$00,$87,$50,$F6,$4B,$00,$87
L26F8         fcb   $50,$F6,$4B,$00,$86,$50,$F6,$4B
L2700         fcb   $00,$86,$50,$F6,$4B,$00,$86,$50
L2708         fcb   $F6,$4B,$00,$86,$50,$F6,$00,$02
L2710         fcb   $40,$97,$E9,$97,$E9,$92,$F5,$92
L2718         fcb   $F5,$9A,$E9,$00,$50,$F5,$01,$9A
L2720         fcb   $FD,$0B,$97,$FD,$9A,$FD,$9C,$FD
L2728         fcb   $9E,$FD,$9F,$FD,$A1,$FD,$A3,$FC
L2730         fcb   $A4,$FC,$A6,$F9,$54,$0C,$FE,$51
L2738         fcb   $0B,$FE,$52,$0B,$44,$0C,$9A,$50
L2740         fcb   $FE,$9C,$FD,$9E,$FD,$9F,$FD,$A1
L2748         fcb   $FD,$A3,$FC,$A4,$FC,$A6,$00,$02
L2750         fcb   $40,$93,$F5,$93,$F5,$9A,$F5,$8E
L2758         fcb   $F5,$95,$E9,$95,$F5,$92,$F5,$00
L2760         fcb   $02,$40,$8E,$E9,$9F,$F5,$93,$F5
L2768         fcb   $9A,$DD,$8E,$F5,$00,$02,$40,$90
L2770         fcb   $E9,$97,$E9,$9C,$E9,$97,$E9,$00
L2778         fcb   $02,$40,$93,$F5,$93,$F5,$9C,$F5
L2780         fcb   $90,$F5,$93,$E9,$9C,$F5,$93,$F5
L2788         fcb   $00,$50,$FD,$0B,$43,$00,$A6,$51
L2790         fcb   $06,$FD,$01,$43,$00,$A8,$50,$FD
L2798         fcb   $51,$0B,$BD,$52,$0B,$BD,$51,$0B
L27A0         fcb   $BD,$52,$0B,$BD,$51,$0B,$BD,$52
L27A8         fcb   $0B,$BD,$51,$0B,$BD,$52,$0B,$BD
L27B0         fcb   $51,$0B,$BD,$52,$0B,$FD,$0B,$40
L27B8         fcb   $9E,$FB,$9F,$FB,$9C,$F5,$9E,$FB
L27C0         fcb   $9F,$FB,$9C,$F5,$9E,$FB,$9F,$FB
L27C8         fcb   $00,$02,$40,$97,$E9,$9F,$F5,$93
L27D0         fcb   $F5,$97,$F5,$93,$E9,$90,$F5,$00
L27D8         fcb   $04,$4B,$00,$84,$50,$EA,$4B,$00
L27E0         fcb   $80,$50,$FC,$4B,$00,$7F,$50,$FC
L27E8         fcb   $4B,$00,$7E,$50,$FC,$4B,$00,$7F
L27F0         fcb   $50,$FC,$4B,$00,$84,$50,$EA,$4B
L27F8         fcb   $00,$87,$50,$FC,$4B,$00,$84,$50
L2800         fcb   $FC,$4B,$00,$7F,$50,$FC,$4B,$00
L2808         fcb   $7E,$50,$FC,$00,$04,$4B,$00,$7D
L2810         fcb   $50,$F6,$4B,$00,$88,$50,$FE,$4B
L2818         fcb   $00,$87,$50,$FA,$4B,$00,$86,$50
L2820         fcb   $FA,$4B,$00,$85,$50,$FA,$5B,$00
L2828         fcb   $50,$4B,$00,$84,$50,$4B,$00,$83
L2830         fcb   $50,$FC,$4B,$00,$82,$50,$FC,$4B
L2838         fcb   $00,$81,$50,$BD,$BE,$C8,$01,$91
L2840         fcb   $BE,$91,$BE,$00,$02,$40,$95,$FD
L2848         fcb   $95,$FD,$95,$FD,$94,$FD,$93,$F9
L2850         fcb   $92,$F9,$91,$FB,$91,$BD,$91,$BD
L2858         fcb   $90,$BD,$96,$FB,$96,$FB,$46,$C9
L2860         fcb   $99,$50,$FE,$46,$C9,$99,$50,$FE
L2868         fcb   $46,$C9,$99,$50,$FE,$46,$C9,$99
L2870         fcb   $50,$FE,$46,$C9,$99,$50,$FE,$46
L2878         fcb   $C9,$99,$50,$FE,$46,$C9,$99,$50
L2880         fcb   $FE,$46,$C9,$99,$50,$FE,$46,$C9
L2888         fcb   $99,$50,$FA,$46,$C9,$99,$50,$FE
L2890         fcb   $46,$C9,$99,$50,$FE,$46,$C9,$99
L2898         fcb   $50,$FA,$46,$C9,$99,$50,$FC,$46
L28A0         fcb   $C9,$99,$50,$00,$0B,$40,$A1,$F9
L28A8         fcb   $51,$04,$52,$04,$51,$04,$52,$04
L28B0         fcb   $43,$00,$95,$50,$97,$BD,$98,$F9
L28B8         fcb   $A1,$F9,$98,$F5,$9D,$FC,$52,$0B
L28C0         fcb   $43,$00,$91,$50,$FC,$4F,$0F,$8D
L28C8         fcb   $50,$FE,$56,$E8,$40,$BE,$E6,$03
L28D0         fcb   $92,$56,$D8,$40,$BE,$BD,$46,$D7
L28D8         fcb   $91,$40,$BE,$46,$D7,$91,$40,$BE
L28E0         fcb   $46,$D7,$90,$40,$BE,$46,$D7,$90
L28E8         fcb   $40,$BE,$46,$D7,$91,$40,$BE,$46
L28F0         fcb   $D7,$91,$40,$BE,$46,$D7,$92,$40
L28F8         fcb   $BE,$46,$D7,$92,$40,$BE,$46,$D7
L2900         fcb   $91,$40,$BE,$46,$D7,$91,$40,$BE
L2908         fcb   $46,$D8,$90,$50,$BD,$BE,$43,$00
L2910         fcb   $91,$50,$BE,$BD,$00,$02,$40,$90
L2918         fcb   $FD,$90,$FD,$90,$FD,$90,$FD,$90
L2920         fcb   $F9,$90,$F9,$8C,$FD,$A4,$BD,$95
L2928         fcb   $FB,$93,$FB,$8A,$FB,$46,$C9,$94
L2930         fcb   $50,$FE,$46,$C9,$94,$50,$FE,$46
L2938         fcb   $C9,$94,$50,$FE,$46,$C9,$94,$50
L2940         fcb   $FE,$46,$C9,$94,$50,$FE,$46,$C9
L2948         fcb   $94,$50,$FE,$46,$C9,$94,$50,$FE
L2950         fcb   $46,$C9,$94,$50,$FE,$46,$C9,$96
L2958         fcb   $50,$FE,$46,$C9,$94,$50,$46,$C9
L2960         fcb   $94,$50,$46,$C9,$93,$50,$FE,$46
L2968         fcb   $C9,$94,$50,$FE,$46,$C9,$96,$50
L2970         fcb   $FE,$46,$C9,$94,$50,$46,$C9,$94
L2978         fcb   $50,$46,$C9,$93,$50,$FE,$46,$C9
L2980         fcb   $94,$50,$46,$C9,$94,$50,$00,$02
L2988         fcb   $40,$8C,$FD,$8C,$FD,$8C,$FD,$8C
L2990         fcb   $FD,$8C,$F9,$8C,$F9,$89,$FD,$A1
L2998         fcb   $BD,$98,$FD,$84,$BD,$8F,$FB,$91
L29A0         fcb   $FB,$46,$C9,$91,$50,$FE,$46,$C9
L29A8         fcb   $91,$50,$FE,$46,$C9,$91,$50,$FE
L29B0         fcb   $46,$C9,$91,$50,$FE,$46,$C9,$91
L29B8         fcb   $50,$FE,$46,$C9,$91,$50,$FE,$46
L29C0         fcb   $C9,$91,$50,$FE,$46,$C9,$91,$50
L29C8         fcb   $FE,$46,$C9,$92,$50,$FE,$46,$C9
L29D0         fcb   $91,$50,$46,$C9,$91,$50,$46,$C9
L29D8         fcb   $90,$50,$FE,$46,$C9,$91,$50,$FE
L29E0         fcb   $46,$C9,$92,$50,$FE,$46,$C9,$91
L29E8         fcb   $50,$46,$C9,$91,$50,$46,$C9,$90
L29F0         fcb   $50,$FE,$46,$C9,$91,$50,$46,$C9
L29F8         fcb   $91,$50,$00,$08,$4F,$10,$7C,$50
L2A00         fcb   $BE,$BD,$09,$4B,$00,$7D,$50,$FE
L2A08         fcb   $07,$7C,$BD,$BE,$BD,$09,$4B,$00
L2A10         fcb   $7D,$50,$FE,$08,$7C,$BD,$BE,$FB
L2A18         fcb   $86,$FD,$5B,$00,$50,$FE,$4F,$14
L2A20         fcb   $85,$50,$BD,$5B,$00,$02,$40,$91
L2A28         fcb   $BD,$9D,$FE,$5B,$00,$50,$BD,$08
L2A30         fcb   $8A,$FB,$8E,$FE,$5B,$00,$50,$BD
L2A38         fcb   $46,$C9,$8D,$50,$BD,$5B,$00,$50
L2A40         fcb   $FC,$5B,$00,$50,$F2,$5B,$00,$50
L2A48         fcb   $FA,$5B,$00,$50,$FA,$5B,$00,$50
L2A50         fcb   $F2,$5B,$00,$50,$BD,$01,$94,$BE
L2A58         fcb   $94,$BE,$00,$01,$49,$01,$99,$50
L2A60         fcb   $BD,$BE,$94,$BD,$94,$BD,$99,$FE
L2A68         fcb   $BE,$8D,$BD,$8D,$BD,$8D,$BD,$8D
L2A70         fcb   $BD,$8D,$BD,$BE,$BD,$8D,$BD,$BE
L2A78         fcb   $BD,$8D,$BD,$BE,$BD,$08,$8C,$BD
L2A80         fcb   $01,$8C,$BD,$08,$8C,$BD,$01,$8C
L2A88         fcb   $BD,$08,$8C,$BD,$BE,$BD,$8C,$BD
L2A90         fcb   $BE,$BD,$8B,$BD,$01,$8B,$BD,$08
L2A98         fcb   $8B,$BD,$01,$8B,$BD,$08,$88,$BD
L2AA0         fcb   $BE,$BD,$88,$FE,$BE,$8D,$BD,$BE
L2AA8         fcb   $BD,$BE,$E1,$02,$81,$BD,$81,$BD
L2AB0         fcb   $82,$BD,$81,$BD,$7F,$BD,$7D,$BD
L2AB8         fcb   $7C,$BD,$03,$94,$BD,$9A,$BD,$9A
L2AC0         fcb   $BD,$9A,$F9,$00,$02,$46,$C9,$92
L2AC8         fcb   $50,$FE,$46,$C9,$91,$50,$46,$C9
L2AD0         fcb   $91,$50,$46,$C9,$92,$50,$FE,$46
L2AD8         fcb   $C9,$91,$50,$46,$C9,$91,$50,$46
L2AE0         fcb   $C9,$90,$50,$46,$C9,$90,$50,$46
L2AE8         fcb   $C9,$91,$50,$FE,$46,$C9,$92,$50
L2AF0         fcb   $FE,$46,$C9,$91,$50,$FE,$8C,$56
L2AF8         fcb   $29,$40,$8C,$56,$29,$40,$8C,$56
L2B00         fcb   $29,$40,$8C,$56,$29,$40,$8C,$BD
L2B08         fcb   $46,$29,$BE,$50,$8C,$BD,$46,$29
L2B10         fcb   $BE,$50,$46,$C9,$8B,$50,$46,$C9
L2B18         fcb   $8B,$50,$46,$C9,$8B,$50,$46,$C9
L2B20         fcb   $8B,$50,$8F,$BD,$46,$29,$BE,$50
L2B28         fcb   $8F,$BD,$46,$29,$BE,$50,$8D,$BD
L2B30         fcb   $46,$29,$BE,$50,$01,$A0,$BD,$A0
L2B38         fcb   $BD,$A2,$BD,$A0,$BD,$BE,$F9,$A0
L2B40         fcb   $BD,$A0,$BD,$A2,$BD,$A0,$BD,$BE
L2B48         fcb   $F9,$81,$BD,$81,$BD,$82,$BD,$81
L2B50         fcb   $BD,$7F,$BD,$7D,$BD,$7C,$BD,$46
L2B58         fcb   $C8,$BE,$50,$FA,$03,$97,$FB,$00
L2B60         fcb   $02,$46,$C9,$96,$50,$FE,$46,$C9
L2B68         fcb   $94,$50,$46,$C9,$94,$50,$46,$C9
L2B70         fcb   $96,$50,$FE,$46,$C9,$94,$50,$46
L2B78         fcb   $C9,$94,$50,$46,$C9,$93,$50,$46
L2B80         fcb   $C9,$93,$50,$46,$C9,$94,$50,$FE
L2B88         fcb   $96,$56,$C9,$40,$BE,$BD,$46,$C9
L2B90         fcb   $94,$50,$FE,$91,$56,$29,$40,$91
L2B98         fcb   $56,$29,$40,$90,$56,$29,$40,$90
L2BA0         fcb   $56,$29,$40,$8F,$BD,$46,$29,$BE
L2BA8         fcb   $50,$90,$BD,$46,$29,$BE,$50,$46
L2BB0         fcb   $C9,$92,$50,$46,$C9,$92,$50,$46
L2BB8         fcb   $C9,$92,$50,$46,$C9,$92,$50,$92
L2BC0         fcb   $BD,$46,$29,$BE,$50,$92,$BD,$46
L2BC8         fcb   $29,$BE,$50,$91,$BD,$46,$29,$BE
L2BD0         fcb   $50,$01,$49,$01,$94,$50,$94,$BD
L2BD8         fcb   $96,$BD,$94,$BD,$BE,$F9,$94,$BD
L2BE0         fcb   $94,$BD,$96,$BD,$94,$BD,$BE,$F9
L2BE8         fcb   $8D,$BD,$8D,$BD,$8E,$BD,$8D,$BD
L2BF0         fcb   $8B,$BD,$89,$BD,$88,$BD,$46,$C8
L2BF8         fcb   $BE,$50,$F7,$03,$93,$FE,$00,$01
L2C00         fcb   $49,$01,$96,$50,$BD,$BE,$91,$BD
L2C08         fcb   $91,$BD,$96,$FE,$BE,$91,$BD,$91
L2C10         fcb   $BD,$90,$BD,$90,$BD,$91,$BD,$BE
L2C18         fcb   $BD,$92,$BD,$BE,$BD,$91,$FE,$BE
L2C20         fcb   $91,$BD,$91,$BD,$90,$BD,$90,$BD
L2C28         fcb   $8F,$BD,$BE,$BD,$90,$FE,$BE,$8F
L2C30         fcb   $BD,$8F,$BD,$8F,$BD,$8F,$BD,$8F
L2C38         fcb   $FE,$BE,$8F,$FE,$BE,$91,$BD,$BE
L2C40         fcb   $C3,$00,$02,$46,$C9,$99,$50,$FC
L2C48         fcb   $46,$C9,$99,$50,$46,$C9,$99,$50
L2C50         fcb   $FC,$46,$C9,$99,$50,$46,$C9,$99
L2C58         fcb   $50,$46,$C9,$99,$50,$46,$C9,$99
L2C60         fcb   $50,$FE,$46,$C9,$99,$50,$FE,$46
L2C68         fcb   $C9,$99,$50,$FE,$46,$C9,$95,$50
L2C70         fcb   $46,$C9,$95,$50,$46,$C9,$93,$50
L2C78         fcb   $46,$C9,$93,$50,$92,$BD,$46,$29
L2C80         fcb   $BE,$50,$93,$BD,$46,$29,$BE,$50
L2C88         fcb   $46,$C9,$97,$50,$46,$C9,$97,$50
L2C90         fcb   $46,$C9,$97,$50,$46,$C9,$97,$50
L2C98         fcb   $98,$BD,$46,$29,$BE,$50,$98,$BD
L2CA0         fcb   $46,$29,$BE,$50,$99,$BD,$46,$29
L2CA8         fcb   $BE,$50,$F8,$03,$8D,$BD,$8D,$BD
L2CB0         fcb   $8E,$BD,$46,$D8,$8D,$50,$BE,$F9
L2CB8         fcb   $8D,$BD,$8D,$BD,$8E,$BD,$46,$D8
L2CC0         fcb   $8D,$50,$8D,$BD,$8D,$BD,$8E,$BD
L2CC8         fcb   $8D,$BD,$8B,$BD,$89,$BD,$88,$BD
L2CD0         fcb   $46,$D8,$BE,$50,$F4,$00,$01,$4F
L2CD8         fcb   $0F,$92,$50,$59,$01,$40,$BE,$8D
L2CE0         fcb   $BD,$8D,$BD,$92,$FE,$BE,$94,$BD
L2CE8         fcb   $94,$BD,$93,$BD,$93,$BD,$94,$BD
L2CF0         fcb   $BE,$BD,$96,$BD,$BE,$BD,$94,$BD
L2CF8         fcb   $BE,$BD,$02,$4E,$0D,$80,$50,$80
L2D00         fcb   $BD,$80,$BD,$80,$BD,$80,$BD,$BE
L2D08         fcb   $BD,$80,$BD,$BE,$BD,$7F,$BD,$7F
L2D10         fcb   $BD,$7F,$BD,$7F,$BD,$7C,$BD,$BE
L2D18         fcb   $BD,$7C,$BD,$BE,$BD,$81,$BD,$46
L2D20         fcb   $C8,$BE,$50,$F8,$01,$8D,$BD,$8D
L2D28         fcb   $BD,$8E,$BD,$46,$D8,$8D,$50,$BE
L2D30         fcb   $F9,$8D,$BD,$8D,$BD,$8E,$BD,$46
L2D38         fcb   $D8,$8D,$50,$81,$BD,$81,$BD,$82
L2D40         fcb   $BD,$81,$BD,$7F,$BD,$7D,$BD,$7C
L2D48         fcb   $FD,$BE,$F5,$00,$50,$FE,$BE,$F8
L2D50         fcb   $02,$46,$C9,$8E,$50,$FE,$46,$C9
L2D58         fcb   $8D,$50,$FE,$46,$C9,$8E,$50,$FE
L2D60         fcb   $46,$C9,$8F,$50,$FE,$46,$C9,$8E
L2D68         fcb   $50,$FE,$46,$C9,$8D,$50,$FE,$46
L2D70         fcb   $C9,$8E,$50,$FE,$08,$46,$C9,$7B
L2D78         fcb   $50,$BE,$BD,$7B,$BD,$7B,$BD,$7B
L2D80         fcb   $BD,$BE,$BD,$7B,$BD,$BE,$BD,$7B
L2D88         fcb   $BD,$7B,$BD,$7B,$BD,$BE,$BD,$7B
L2D90         fcb   $BD,$7B,$BD,$7B,$BD,$BE,$BD,$80
L2D98         fcb   $BD,$BE,$BD,$80,$BD,$80,$BD,$7F
L2DA0         fcb   $BD,$BE,$BD,$7F,$BD,$7F,$BD,$7D
L2DA8         fcb   $BD,$7B,$BD,$7A,$BD,$78,$BD,$76
L2DB0         fcb   $E9,$02,$9B,$46,$C8,$BE,$50,$FB
L2DB8         fcb   $00,$50,$FD,$BE,$F9,$02,$46,$C9
L2DC0         fcb   $92,$50,$FE,$46,$C9,$91,$50,$FE
L2DC8         fcb   $46,$C9,$92,$50,$FE,$46,$C9,$93
L2DD0         fcb   $50,$FE,$46,$C9,$92,$50,$FE,$46
L2DD8         fcb   $C9,$91,$50,$FE,$46,$C9,$92,$50
L2DE0         fcb   $FE,$01,$49,$01,$93,$50,$FE,$93
L2DE8         fcb   $BD,$93,$BD,$93,$FD,$93,$FD,$93
L2DF0         fcb   $BD,$93,$BD,$93,$FD,$93,$BD,$93
L2DF8         fcb   $BD,$93,$FD,$93,$FD,$93,$BD,$95
L2E00         fcb   $BD,$93,$FD,$93,$BD,$93,$BD,$90
L2E08         fcb   $FD,$90,$BD,$90,$BD,$8E,$FE,$BE
L2E10         fcb   $02,$9A,$BD,$9A,$BD,$9C,$FD,$9A
L2E18         fcb   $FD,$99,$FD,$98,$FD,$9F,$46,$C9
L2E20         fcb   $BE,$50,$BD,$9E,$46,$C9,$BE,$50
L2E28         fcb   $BD,$00,$50,$FC,$BE,$FA,$02,$46
L2E30         fcb   $C9,$95,$50,$FE,$46,$C9,$94,$50
L2E38         fcb   $FE,$46,$C9,$95,$50,$FE,$46,$C9
L2E40         fcb   $96,$50,$F6,$46,$C9,$95,$50,$FE
L2E48         fcb   $01,$49,$01,$98,$50,$FE,$97,$BD
L2E50         fcb   $97,$BD,$96,$FD,$97,$FD,$98,$BD
L2E58         fcb   $98,$BD,$97,$FD,$96,$BD,$96,$BD
L2E60         fcb   $97,$FD,$98,$FD,$98,$BD,$98,$BD
L2E68         fcb   $97,$FD,$97,$BD,$97,$BD,$95,$FD
L2E70         fcb   $95,$BD,$95,$BD,$95,$FE,$BE,$FA
L2E78         fcb   $02,$9F,$FD,$9F,$FD,$9F,$FD,$9F
L2E80         fcb   $BD,$A2,$46,$C9,$BE,$50,$BD,$A1
L2E88         fcb   $46,$C9,$BE,$50,$BD,$00,$50,$BD
L2E90         fcb   $03,$90,$BE,$DC,$01,$49,$01,$9C
L2E98         fcb   $50,$FE,$9A,$BD,$9A,$BD,$99,$FD
L2EA0         fcb   $9A,$FD,$9C,$BD,$9C,$BD,$9A,$FD
L2EA8         fcb   $99,$BD,$99,$BD,$9A,$FD,$9C,$FD
L2EB0         fcb   $9C,$BD,$9E,$BD,$9A,$FD,$9A,$BD
L2EB8         fcb   $9A,$BD,$99,$FD,$99,$BD,$99,$BD
L2EC0         fcb   $9A,$FE,$BE,$EC,$03,$8F,$BD,$8F
L2EC8         fcb   $BD,$8E,$BD,$46,$D8,$BE,$50,$00
L2ED0         fcb   $50,$FD,$03,$8E,$BD,$BE,$DF,$01
L2ED8         fcb   $49,$01,$87,$50,$FE,$87,$BD,$87
L2EE0         fcb   $BD,$87,$FD,$87,$FD,$87,$BD,$87
L2EE8         fcb   $BD,$87,$FD,$87,$BD,$87,$BD,$87
L2EF0         fcb   $FD,$8C,$FD,$8C,$BD,$8C,$BD,$8B
L2EF8         fcb   $FD,$8B,$BD,$8B,$BD,$89,$FD,$89
L2F00         fcb   $BD,$89,$BD,$8E,$FE,$BE,$FC,$02
L2F08         fcb   $98,$FD,$97,$FD,$96,$FD,$95,$FD
L2F10         fcb   $A7,$46,$C9,$BE,$50,$BD,$A6,$46
L2F18         fcb   $C9,$BE,$50,$BD,$00,$5E,$0D,$50
L2F20         fcb   $FA,$03,$90,$BD,$BE,$BD,$8E,$BD
L2F28         fcb   $8E,$BD,$8D,$BD,$BE,$BD,$8E,$BD
L2F30         fcb   $BE,$BD,$90,$BD,$BE,$BD,$8E,$BD
L2F38         fcb   $8E,$BD,$8D,$BD,$BE,$BD,$8E,$FE
L2F40         fcb   $46,$C8,$BE,$04,$40,$7B,$BD,$BE
L2F48         fcb   $BD,$7B,$BD,$7B,$BD,$7B,$FD,$7B
L2F50         fcb   $FD,$7B,$BD,$7B,$BD,$7B,$FD,$7B
L2F58         fcb   $BD,$7B,$BD,$7B,$FD,$80,$FD,$80
L2F60         fcb   $BD,$80,$BD,$7F,$FD,$7F,$BD,$7F
L2F68         fcb   $BD,$7D,$BD,$7B,$BD,$7A,$BD,$78
L2F70         fcb   $BD,$76,$BD,$BE,$E3,$00,$50,$ED
L2F78         fcb   $05,$4B,$00,$76,$50,$46,$E8,$BE
L2F80         fcb   $50,$4B,$00,$7B,$50,$46,$E8,$BE
L2F88         fcb   $50,$F6,$08,$7C,$BD,$7C,$BD,$7C
L2F90         fcb   $BD,$7C,$BD,$7C,$BD,$7C,$F5,$05
L2F98         fcb   $46,$E8,$76,$50,$FE,$46,$E8,$7B
L2FA0         fcb   $50,$FE,$46,$E8,$76,$50,$08,$7C
L2FA8         fcb   $BD,$7C,$BD,$7C,$BD,$7C,$BD,$7C
L2FB0         fcb   $BD,$88,$F5,$05,$76,$BD,$46,$E8
L2FB8         fcb   $BE,$50,$7B,$BD,$46,$E8,$BE,$50
L2FC0         fcb   $76,$BD,$08,$7C,$BD,$7C,$BD,$7C
L2FC8         fcb   $BD,$7C,$BD,$7C,$BD,$88,$F9,$00
L2FD0         fcb   $02,$40,$8D,$46,$C9,$BE,$50,$BD
L2FD8         fcb   $8E,$46,$C9,$BE,$50,$BD,$8F,$46
L2FE0         fcb   $C9,$BE,$50,$BD,$8E,$46,$C9,$BE
L2FE8         fcb   $50,$BD,$8D,$46,$C9,$BE,$50,$BD
L2FF0         fcb   $8E,$BD,$46,$C9,$BE,$50,$93,$BD
L2FF8         fcb   $46,$C9,$BE,$50,$8E,$BD,$46,$C9
L3000         fcb   $BE,$50,$93,$FB,$9A,$46,$C9,$BE
L3008         fcb   $40,$9A,$46,$C9,$BE,$40,$9A,$46
L3010         fcb   $C9,$BE,$40,$9A,$46,$C9,$BE,$40
L3018         fcb   $9A,$46,$C9,$BE,$40,$9A,$FE,$46
L3020         fcb   $C9,$BE,$50,$F9,$8E,$BD,$46,$C9
L3028         fcb   $BE,$50,$93,$BD,$46,$C9,$BE,$50
L3030         fcb   $9A,$BD,$9A,$46,$C9,$BE,$40,$9A
L3038         fcb   $46,$C9,$BE,$40,$9A,$46,$C9,$BE
L3040         fcb   $40,$9A,$46,$C9,$BE,$40,$9A,$46
L3048         fcb   $C9,$BE,$40,$9A,$FE,$46,$C9,$BE
L3050         fcb   $50,$F9,$8E,$BD,$46,$C9,$BE,$50
L3058         fcb   $93,$BD,$46,$C9,$BE,$50,$9A,$BD
L3060         fcb   $9A,$46,$C9,$BE,$40,$9A,$46,$C9
L3068         fcb   $BE,$40,$9A,$46,$C9,$BE,$40,$9A
L3070         fcb   $46,$C9,$BE,$40,$9A,$46,$C9,$BE
L3078         fcb   $40,$9A,$FE,$46,$C9,$BE,$50,$FD
L3080         fcb   $00,$02,$40,$91,$46,$C9,$BE,$50
L3088         fcb   $BD,$92,$46,$C9,$BE,$50,$BD,$93
L3090         fcb   $46,$C9,$BE,$50,$BD,$92,$46,$C9
L3098         fcb   $BE,$50,$BD,$91,$46,$C9,$BE,$50
L30A0         fcb   $BD,$92,$BD,$46,$C9,$BE,$50,$97
L30A8         fcb   $BD,$46,$C9,$BE,$50,$92,$BD,$46
L30B0         fcb   $C9,$BE,$50,$97,$FB,$92,$46,$C9
L30B8         fcb   $BE,$40,$92,$46,$C9,$BE,$40,$92
L30C0         fcb   $46,$C9,$BE,$40,$92,$46,$C9,$BE
L30C8         fcb   $40,$92,$46,$C9,$BE,$40,$92,$FE
L30D0         fcb   $46,$C9,$BE,$50,$F9,$92,$BD,$46
L30D8         fcb   $C9,$BE,$50,$97,$BD,$46,$C9,$BE
L30E0         fcb   $50,$92,$BD,$92,$46,$C9,$BE,$40
L30E8         fcb   $92,$46,$C9,$BE,$40,$92,$46,$C9
L30F0         fcb   $BE,$40,$92,$46,$C9,$BE,$40,$92
L30F8         fcb   $46,$C9,$BE,$40,$92,$FE,$46,$C9
L3100         fcb   $BE,$50,$F9,$92,$BD,$46,$C9,$BE
L3108         fcb   $50,$97,$BD,$46,$C9,$BE,$50,$92
L3110         fcb   $BD,$92,$46,$C9,$BE,$40,$92,$46
L3118         fcb   $C9,$BE,$40,$92,$46,$C9,$BE,$40
L3120         fcb   $92,$46,$C9,$BE,$40,$92,$46,$C9
L3128         fcb   $BE,$40,$92,$FE,$46,$C9,$BE,$50
L3130         fcb   $FD,$00,$03,$40,$8D,$BD,$8D,$BD
L3138         fcb   $8E,$BD,$46,$D8,$BE,$50,$8F,$BD
L3140         fcb   $8F,$BD,$8E,$BD,$8E,$BD,$8D,$FE
L3148         fcb   $BE,$01,$9A,$BD,$BE,$BD,$9F,$BD
L3150         fcb   $BE,$BD,$9A,$BD,$BE,$BD,$9F,$FC
L3158         fcb   $BE,$92,$BD,$95,$BD,$97,$BD,$98
L3160         fcb   $BD,$97,$BD,$95,$BD,$97,$BD,$97
L3168         fcb   $BD,$97,$FA,$BE,$FA,$92,$BD,$92
L3170         fcb   $BD,$95,$BD,$97,$BD,$98,$BD,$97
L3178         fcb   $BD,$95,$BD,$97,$BD,$97,$BD,$97
L3180         fcb   $FB,$BE,$F9,$92,$BD,$92,$BD,$95
L3188         fcb   $BD,$97,$BD,$98,$BD,$97,$BD,$95
L3190         fcb   $BD,$97,$BD,$97,$BD,$97,$BD,$00
L3198         fcb   $02,$40,$94,$BD,$46,$C9,$BE,$50
L31A0         fcb   $95,$BD,$46,$C9,$BE,$50,$96,$BD
L31A8         fcb   $46,$C9,$BE,$50,$95,$BD,$46,$C9
L31B0         fcb   $BE,$50,$94,$BD,$46,$C9,$BE,$50
L31B8         fcb   $95,$BD,$46,$C9,$BE,$50,$9A,$BD
L31C0         fcb   $46,$C9,$BE,$50,$95,$BD,$46,$C9
L31C8         fcb   $BE,$50,$9A,$FB,$01,$95,$46,$C9
L31D0         fcb   $BE,$40,$9A,$46,$C9,$BE,$40,$9C
L31D8         fcb   $46,$C9,$BE,$40,$9E,$46,$C9,$BE
L31E0         fcb   $40,$9C,$46,$C9,$BE,$40,$9A,$BD
L31E8         fcb   $46,$C9,$9A,$50,$9A,$BD,$9A,$FB
L31F0         fcb   $02,$95,$BD,$46,$C9,$BE,$50,$9A
L31F8         fcb   $BD,$46,$C9,$BE,$50,$01,$95,$BD
L3200         fcb   $95,$46,$C9,$BE,$40,$9A,$46,$C9
L3208         fcb   $BE,$40,$9C,$46,$C9,$BE,$40,$9E
L3210         fcb   $46,$C9,$BE,$40,$9C,$46,$C9,$BE
L3218         fcb   $40,$9A,$BD,$46,$C9,$9A,$50,$9A
L3220         fcb   $BD,$9A,$FB,$02,$95,$BD,$46,$C9
L3228         fcb   $BE,$50,$9A,$BD,$46,$C9,$BE,$50
L3230         fcb   $01,$95,$BD,$95,$46,$C9,$BE,$40
L3238         fcb   $9A,$46,$C9,$BE,$40,$9C,$46,$C9
L3240         fcb   $BE,$40,$9E,$46,$C9,$BE,$40,$9C
L3248         fcb   $46,$C9,$BE,$40,$9A,$BD,$46,$C9
L3250         fcb   $9A,$50,$9A,$BD,$9A,$BD,$00,$5E
L3258         fcb   $0D,$50,$EE,$02,$9A,$BD,$46,$C9
L3260         fcb   $BE,$50,$9F,$BD,$46,$C9,$BE,$50
L3268         fcb   $9A,$BD,$46,$C9,$BE,$50,$9F,$FB
L3270         fcb   $01,$9A,$46,$C9,$BE,$40,$9E,$46
L3278         fcb   $C9,$BE,$40,$9F,$46,$C9,$BE,$40
L3280         fcb   $A1,$46,$C9,$BE,$40,$9F,$46,$C9
L3288         fcb   $BE,$40,$9E,$BD,$46,$C8,$9F,$50
L3290         fcb   $9F,$BD,$9F,$FB,$02,$9A,$BD,$46
L3298         fcb   $C9,$BE,$50,$9F,$BD,$46,$C9,$BE
L32A0         fcb   $50,$01,$9A,$BD,$9A,$46,$C9,$BE
L32A8         fcb   $40,$9E,$46,$C9,$BE,$40,$9F,$46
L32B0         fcb   $C9,$BE,$40,$A1,$46,$C9,$BE,$40
L32B8         fcb   $9F,$46,$C9,$BE,$40,$9E,$BD,$46
L32C0         fcb   $C9,$9F,$50,$9F,$BD,$9F,$FB,$02
L32C8         fcb   $9A,$BD,$46,$C9,$BE,$50,$9F,$BD
L32D0         fcb   $46,$C9,$BE,$50,$01,$9A,$BD,$9A
L32D8         fcb   $46,$C9,$BE,$40,$9E,$46,$C9,$BE
L32E0         fcb   $40,$9F,$46,$C9,$BE,$40,$A1,$46
L32E8         fcb   $C9,$BE,$40,$9F,$46,$C9,$BE,$40
L32F0         fcb   $9E,$BD,$46,$C9,$9F,$50,$9F,$BD
L32F8         fcb   $9F,$BD,$00,$08,$40,$7C,$BD,$7C
L3300         fcb   $BD,$7C,$BD,$7C,$BD,$7C,$BD,$7C
L3308         fcb   $BD,$88,$FB,$01,$9F,$BD,$9F,$BD
L3310         fcb   $9D,$EF,$91,$BD,$BE,$BD,$8D,$BD
L3318         fcb   $BE,$BD,$92,$BD,$BE,$BD,$91,$BD
L3320         fcb   $BE,$BD,$91,$BD,$BE,$BD,$95,$BD
L3328         fcb   $BE,$BD,$93,$BD,$BE,$EF,$08,$7C
L3330         fcb   $BD,$7C,$BD,$7C,$BD,$7C,$BD,$7C
L3338         fcb   $BD,$7C,$BD,$7C,$F9,$7C,$FB,$7C
L3340         fcb   $BD,$7C,$FD,$7C,$BD,$7C,$BD,$7C
L3348         fcb   $BD,$7C,$BD,$7C,$BD,$7C,$BD,$00
L3350         fcb   $02,$40,$9A,$BD,$9A,$46,$C9,$BE
L3358         fcb   $40,$9A,$46,$C9,$BE,$40,$9A,$46
L3360         fcb   $C9,$BE,$40,$9A,$46,$C9,$BE,$40
L3368         fcb   $9A,$46,$C9,$BE,$40,$9A,$BD,$01
L3370         fcb   $92,$FD,$BE,$F9,$9A,$F3,$96,$BD
L3378         fcb   $BE,$BD,$97,$BD,$BE,$BD,$96,$BD
L3380         fcb   $BE,$BD,$98,$BD,$BE,$BD,$9A,$BD
L3388         fcb   $BE,$BD,$9E,$BD,$BE,$BD,$9F,$BD
L3390         fcb   $BE,$EF,$93,$BD,$93,$BD,$93,$BD
L3398         fcb   $93,$BD,$92,$BD,$90,$BD,$8E,$FE
L33A0         fcb   $BE,$8E,$FD,$93,$FD,$BE,$BD,$93
L33A8         fcb   $BD,$90,$BD,$BE,$BD,$90,$BD,$90
L33B0         fcb   $BD,$92,$BD,$92,$BD,$92,$BD,$92
L33B8         fcb   $BD,$00,$02,$40,$92,$BD,$92,$46
L33C0         fcb   $C9,$BE,$40,$92,$46,$C9,$BE,$40
L33C8         fcb   $92,$46,$C9,$BE,$40,$92,$46,$C9
L33D0         fcb   $BE,$40,$92,$46,$C9,$BE,$40,$92
L33D8         fcb   $BD,$01,$95,$FE,$BE,$F4,$96,$F8
L33E0         fcb   $BE,$05,$77,$BD,$BE,$BD,$75,$BD
L33E8         fcb   $BE,$BD,$7A,$BD,$BE,$BD,$79,$BD
L33F0         fcb   $BE,$BD,$7E,$BD,$BE,$BD,$76,$BD
L33F8         fcb   $BE,$BD,$7B,$BD,$BE,$EF,$01,$97
L3400         fcb   $BD,$97,$BD,$98,$BD,$97,$BD,$95
L3408         fcb   $BD,$93,$BD,$92,$FE,$BE,$92,$FD
L3410         fcb   $97,$FD,$BE,$BD,$97,$BD,$93,$BD
L3418         fcb   $BE,$BD,$93,$BD,$93,$BD,$96,$BD
L3420         fcb   $96,$BD,$96,$BD,$96,$BD,$00,$01
L3428         fcb   $40,$92,$BD,$92,$BD,$95,$BD,$97
L3430         fcb   $BD,$98,$BD,$97,$BD,$95,$BD,$9A
L3438         fcb   $FB,$BE,$F5,$94,$F9,$93,$BD,$BE
L3440         fcb   $BD,$91,$BD,$BE,$BD,$92,$BD,$BE
L3448         fcb   $BD,$95,$BD,$BE,$BD,$9A,$BD,$BE
L3450         fcb   $BD,$9A,$BD,$BE,$BD,$93,$BD,$03
L3458         fcb   $8E,$BD,$8E,$BD,$8E,$BD,$90,$BD
L3460         fcb   $8E,$BD,$8E,$BD,$8E,$BD,$90,$BD
L3468         fcb   $8E,$BD,$01,$9A,$BD,$9A,$BD,$9C
L3470         fcb   $BD,$9A,$BD,$98,$BD,$97,$BD,$95
L3478         fcb   $FE,$BE,$95,$FD,$9A,$FD,$BE,$BD
L3480         fcb   $9A,$BD,$98,$BD,$BE,$BD,$98,$BD
L3488         fcb   $98,$BD,$99,$BD,$99,$BD,$99,$BD
L3490         fcb   $99,$BD,$00,$01,$40,$95,$BD,$95
L3498         fcb   $46,$C9,$BE,$40,$9A,$46,$C9,$BE
L34A0         fcb   $40,$9C,$46,$C9,$BE,$40,$9E,$46
L34A8         fcb   $C9,$BE,$40,$9C,$46,$C9,$BE,$40
L34B0         fcb   $9A,$BD,$46,$C9,$9E,$50,$FD,$BE
L34B8         fcb   $F2,$91,$FD,$91,$BD,$8F,$BD,$BE
L34C0         fcb   $BD,$8D,$BD,$BE,$BD,$8D,$BD,$BE
L34C8         fcb   $BD,$95,$BD,$BE,$BD,$96,$BD,$BE
L34D0         fcb   $BD,$9A,$BD,$BE,$BD,$97,$BD,$BE
L34D8         fcb   $DF,$9A,$FD,$9F,$FB,$9F,$BD,$9C
L34E0         fcb   $BD,$BE,$BD,$9C,$BD,$9C,$BD,$9E
L34E8         fcb   $BD,$9E,$BD,$9E,$BD,$9E,$BD,$00
L34F0         fcb   $01,$4E,$0D,$9A,$50,$9A,$46,$C9
L34F8         fcb   $BE,$40,$9E,$46,$C9,$BE,$40,$9F
L3500         fcb   $46,$C9,$BE,$40,$A1,$46,$C9,$BE
L3508         fcb   $40,$9F,$46,$C9,$BE,$40,$9E,$BD
L3510         fcb   $BE,$56,$C9,$40,$A1,$FC,$BE,$EE
L3518         fcb   $8F,$BD,$BE,$BD,$93,$BD,$BE,$BD
L3520         fcb   $96,$BD,$BE,$BD,$98,$BD,$BE,$BD
L3528         fcb   $9A,$BD,$BE,$BD,$9E,$BD,$BE,$BD
L3530         fcb   $9F,$BD,$BE,$EF,$04,$7B,$BD,$7B
L3538         fcb   $BD,$80,$BD,$7B,$BD,$7A,$BD,$78
L3540         fcb   $BD,$76,$FE,$BE,$FC,$7B,$FB,$7B
L3548         fcb   $BD,$74,$BD,$BE,$BD,$74,$BD,$74
L3550         fcb   $BD,$7A,$BD,$7A,$BD,$7A,$BD,$7A
L3558         fcb   $BD,$00,$08,$40,$9E,$FD,$9E,$FD
L3560         fcb   $7A,$BD,$BE,$BD,$7A,$BD,$BE,$BD
L3568         fcb   $7A,$BD,$BE,$BD,$7A,$BD,$BE,$BD
L3570         fcb   $7A,$BD,$BE,$BD,$7A,$BD,$BE,$BD
L3578         fcb   $7A,$BD,$BE,$BD,$7A,$BD,$BE,$BD
L3580         fcb   $7A,$BD,$BE,$BD,$7A,$BD,$BE,$BD
L3588         fcb   $7A,$BD,$BE,$BD,$7A,$BD,$BE,$BD
L3590         fcb   $7A,$BE,$0A,$46,$89,$7A,$40,$BE
L3598         fcb   $46,$89,$78,$40,$BE,$08,$7A,$BE
L35A0         fcb   $0A,$46,$89,$7A,$40,$BE,$46,$89
L35A8         fcb   $78,$40,$BE,$08,$7A,$BE,$0A,$46
L35B0         fcb   $89,$7A,$40,$BE,$46,$89,$78,$40
L35B8         fcb   $BE,$07,$86,$BE,$FC,$00,$01,$49
L35C0         fcb   $01,$92,$50,$BE,$BD,$92,$BD,$BE
L35C8         fcb   $BD,$92,$FB,$90,$BD,$8E,$FE,$BE
L35D0         fcb   $92,$FE,$BE,$95,$FB,$93,$BD,$92
L35D8         fcb   $BD,$BE,$BD,$8E,$FD,$A1,$F1,$0A
L35E0         fcb   $86,$FB,$86,$FB,$86,$FB,$86,$FB
L35E8         fcb   $00,$01,$49,$01,$97,$50,$BE,$BD
L35F0         fcb   $97,$BD,$BE,$BD,$95,$FB,$93,$BD
L35F8         fcb   $92,$FE,$BE,$95,$FE,$BE,$98,$FB
L3600         fcb   $97,$BD,$95,$BD,$BE,$BD,$92,$FD
L3608         fcb   $A6,$E1,$BE,$F9,$00,$01,$49,$01
L3610         fcb   $9B,$50,$BE,$BD,$9B,$BD,$BE,$BD
L3618         fcb   $98,$FB,$97,$BD,$95,$FE,$BE,$98
L3620         fcb   $FE,$BE,$9C,$FB,$9A,$BD,$98,$BD
L3628         fcb   $BE,$BD,$98,$FD,$9E,$DD,$0C,$84
L3630         fcb   $FD,$00,$01,$40,$A3,$BD,$BE,$BD
L3638         fcb   $A3,$BD,$BE,$BD,$0C,$82,$E1,$01
L3640         fcb   $49,$01,$A6,$50,$DE,$0D,$84,$FD
L3648         fcb   $00,$04,$4E,$0D,$7F,$50,$FE,$7F
L3650         fcb   $FD,$05,$76,$BE,$04,$46,$59,$76
L3658         fcb   $40,$BE,$05,$76,$BE,$04,$46,$59
L3660         fcb   $76,$40,$BE,$05,$76,$BE,$04,$46
L3668         fcb   $59,$76,$40,$BE,$05,$76,$BE,$04
L3670         fcb   $46,$59,$76,$40,$BE,$05,$76,$BE
L3678         fcb   $04,$46,$59,$76,$40,$BE,$05,$76
L3680         fcb   $BE,$04,$46,$59,$76,$40,$BE,$05
L3688         fcb   $76,$BE,$04,$46,$59,$76,$40,$BE
L3690         fcb   $05,$76,$BE,$04,$46,$59,$76,$50
L3698         fcb   $05,$76,$BD,$04,$46,$59,$76,$50
L36A0         fcb   $05,$76,$BD,$04,$46,$59,$76,$50
L36A8         fcb   $05,$76,$BD,$04,$46,$59,$76,$50
L36B0         fcb   $05,$76,$BD,$04,$46,$59,$76,$50
L36B8         fcb   $05,$4F,$0A,$76,$50,$04,$46,$89
L36C0         fcb   $76,$50,$46,$89,$76,$50,$05,$76
L36C8         fcb   $BD,$04,$46,$89,$76,$50,$46,$89
L36D0         fcb   $76,$50,$05,$76,$BD,$04,$46,$89
L36D8         fcb   $76,$50,$46,$89,$76,$50,$05,$76
L36E0         fcb   $FB,$00,$4E,$10,$BE,$50,$BE,$BD
L36E8         fcb   $04,$7A,$BD,$BE,$BD,$7B,$F9,$05
L36F0         fcb   $7D,$F9,$04,$75,$BD,$BE,$BD,$75
L36F8         fcb   $FD,$76,$FA,$BE,$05,$78,$FD,$04
L3700         fcb   $7A,$FD,$4E,$10,$78,$50,$F6,$BE
L3708         fcb   $FD,$05,$76,$F9,$04,$76,$BD,$BE
L3710         fcb   $BD,$76,$BD,$BE,$BD,$76,$F9,$05
L3718         fcb   $76,$FA,$BE,$04,$76,$BE,$FE,$76
L3720         fcb   $BD,$BE,$BD,$76,$F9,$05,$76,$F9
L3728         fcb   $04,$76,$BD,$BE,$BD,$76,$BD,$BE
L3730         fcb   $BD,$00,$40,$84,$BD,$BE,$BD,$86
L3738         fcb   $BD,$BE,$BD,$87,$F9,$89,$F9,$81
L3740         fcb   $BD,$BE,$BD,$81,$FD,$82,$FA,$BE
L3748         fcb   $84,$FD,$86,$FD,$84,$E9,$03,$98
L3750         fcb   $FB,$BE,$BD,$98,$FB,$BE,$BD,$98
L3758         fcb   $FC,$BE,$FE,$97,$FC,$BE,$FE,$97
L3760         fcb   $FC,$BE,$FE,$95,$FC,$BE,$FE,$95
L3768         fcb   $FD,$BE,$FD,$00,$40,$84,$BD,$BE
L3770         fcb   $BD,$86,$BD,$BE,$BD,$87,$F9,$89
L3778         fcb   $F9,$81,$BD,$BE,$BD,$81,$FD,$82
L3780         fcb   $FA,$BE,$84,$FD,$86,$FD,$84,$F1
L3788         fcb   $0D,$89,$C1,$00,$40,$BE,$FD,$02
L3790         fcb   $7B,$F5,$7D,$F5,$7D,$F5,$7D,$F5
L3798         fcb   $7D,$F5,$0C,$8E,$C1,$00,$02,$40
L37A0         fcb   $93,$FD,$87,$FD,$93,$FD,$87,$FD
L37A8         fcb   $95,$FD,$89,$FD,$95,$FD,$89,$FD
L37B0         fcb   $95,$FD,$89,$FD,$95,$FD,$89,$E5
L37B8         fcb   $01,$49,$01,$98,$50,$FC,$BE,$BD
L37C0         fcb   $98,$FB,$BE,$BD,$98,$F9,$97,$FB
L37C8         fcb   $BE,$BD,$97,$FC,$BE,$FE,$95,$FD
L37D0         fcb   $BE,$FD,$95,$FD,$BE,$FD,$00,$04
L37D8         fcb   $4E,$10,$7B,$50,$FA,$05,$7B,$BD
L37E0         fcb   $BE,$BD,$04,$7B,$FD,$7B,$F9,$76
L37E8         fcb   $F9,$05,$76,$BD,$BE,$BD,$04,$76
L37F0         fcb   $BD,$BE,$BD,$76,$F9,$05,$82,$FD
L37F8         fcb   $80,$FD,$7D,$FD,$82,$FD,$80,$FD
L3800         fcb   $7D,$FD,$79,$F9,$79,$F1,$04,$76
L3808         fcb   $F9,$05,$76,$BD,$BE,$BD,$04,$76
L3810         fcb   $BD,$BE,$BD,$76,$F9,$76,$F9,$00
L3818         fcb   $03,$40,$95,$FD,$93,$FC,$BE,$FE
L3820         fcb   $93,$F5,$92,$F9,$93,$FD,$95,$EF
L3828         fcb   $BE,$CF,$98,$FD,$BE,$FD,$98,$FD
L3830         fcb   $BE,$FD,$98,$FD,$BE,$FD,$00,$0D
L3838         fcb   $40,$95,$E9,$89,$E9,$8E,$FD,$8C
L3840         fcb   $FD,$89,$FD,$8E,$FD,$8C,$FD,$89
L3848         fcb   $FD,$85,$F9,$01,$41,$11,$8E,$43
L3850         fcb   $11,$91,$FD,$53,$00,$50,$FB,$0D
L3858         fcb   $8B,$BD,$BE,$BD,$89,$E1,$00,$0C
L3860         fcb   $40,$9A,$E9,$8E,$E9,$8E,$FD,$8C
L3868         fcb   $FD,$89,$FD,$8E,$FD,$8C,$FD,$89
L3870         fcb   $FD,$85,$F9,$91,$F5,$8B,$FD,$8E
L3878         fcb   $E1,$00,$01,$40,$95,$FD,$93,$FC
L3880         fcb   $BE,$FE,$93,$F5,$92,$F9,$93,$FD
L3888         fcb   $95,$EF,$BE,$CF,$98,$FB,$BE,$BD
L3890         fcb   $98,$FC,$BE,$FE,$98,$FB,$BE,$BD
L3898         fcb   $00,$08,$40,$7A,$BD,$BE,$FB,$7A
L38A0         fcb   $BD,$BE,$BD,$07,$86,$FD,$08,$7A
L38A8         fcb   $F9,$7A,$BD,$BE,$FB,$7A,$BD,$BE
L38B0         fcb   $BD,$07,$86,$FD,$08,$7A,$F9,$7A
L38B8         fcb   $BD,$BE,$FB,$7A,$BD,$BE,$BD,$07
L38C0         fcb   $86,$FD,$08,$7A,$F9,$7A,$BD,$BE
L38C8         fcb   $FB,$7A,$BD,$BE,$BD,$07,$86,$FD
L38D0         fcb   $08,$7A,$FE,$BE,$FC,$7A,$BD,$BE
L38D8         fcb   $FB,$7A,$BD,$BE,$BD,$07,$86,$FD
L38E0         fcb   $08,$7A,$FD,$BE,$FD,$7A,$BD,$BE
L38E8         fcb   $FB,$00,$02,$40,$93,$F9,$93,$FD
L38F0         fcb   $87,$FD,$93,$FD,$87,$FD,$93,$F9
L38F8         fcb   $93,$FD,$87,$FD,$93,$FD,$87,$FD
L3900         fcb   $93,$FD,$87,$FD,$93,$FD,$87,$FD
L3908         fcb   $93,$FD,$87,$FD,$93,$FD,$87,$FD
L3910         fcb   $8E,$FD,$93,$F9,$87,$FD,$93,$F9
L3918         fcb   $93,$FD,$87,$FD,$93,$FD,$87,$FD
L3920         fcb   $93,$F9,$00,$02,$40,$7B,$F5,$7B
L3928         fcb   $F5,$7B,$F5,$7B,$F5,$7B,$F5,$7B
L3930         fcb   $F5,$7B,$F5,$7B,$F5,$7B,$F5,$7B
L3938         fcb   $F5,$7B,$F9,$00,$0C,$40,$87,$F9
L3940         fcb   $7F,$BD,$BE,$BD,$7F,$FD,$80,$F9
L3948         fcb   $82,$F9,$84,$FD,$86,$FD,$87,$F9
L3950         fcb   $87,$F9,$7F,$BD,$BE,$BD,$7F,$FD
L3958         fcb   $80,$FD,$84,$FD,$82,$FD,$84,$FD
L3960         fcb   $82,$F6,$BE,$FC,$87,$F9,$7F,$BE
L3968         fcb   $FE,$7F,$FE,$BE,$80,$F9,$82,$F9
L3970         fcb   $00,$0D,$40,$87,$F9,$7F,$BD,$BE
L3978         fcb   $BD,$7F,$FD,$80,$F9,$82,$F9,$84
L3980         fcb   $FD,$86,$FD,$87,$F9,$87,$F9,$7F
L3988         fcb   $BD,$BE,$BD,$7F,$FD,$80,$FD,$84
L3990         fcb   $FD,$82,$FD,$84,$FD,$82,$F6,$BE
L3998         fcb   $FC,$87,$F9,$7F,$BE,$FE,$7F,$FE
L39A0         fcb   $BE,$80,$F9,$82,$F9,$00,$05,$4E
L39A8         fcb   $10,$7B,$50,$FA,$04,$73,$BD,$BE
L39B0         fcb   $BD,$73,$FD,$74,$F9,$05,$76,$FA
L39B8         fcb   $BE,$04,$78,$FD,$7A,$BD,$BE,$BD
L39C0         fcb   $7B,$F9,$05,$4E,$10,$7B,$50,$FA
L39C8         fcb   $04,$73,$BD,$BE,$BD,$73,$FD,$74
L39D0         fcb   $FD,$78,$FD,$05,$76,$FD,$04,$78
L39D8         fcb   $FD,$76,$F6,$BE,$FC,$05,$4E,$10
L39E0         fcb   $7B,$50,$FA,$04,$73,$BE,$FE,$73
L39E8         fcb   $FE,$BE,$74,$F9,$05,$76,$F9,$00
L39F0         fcb   $08,$40,$7A,$BD,$BE,$BD,$07,$86
L39F8         fcb   $FD,$08,$7A,$F9,$7A,$BD,$BE,$FB
L3A00         fcb   $7A,$BD,$BE,$BD,$07,$86,$FD,$08
L3A08         fcb   $7A,$F9,$7A,$BD,$BE,$FB,$7A,$BD
L3A10         fcb   $BE,$BD,$07,$86,$FD,$08,$7A,$F9
L3A18         fcb   $7A,$BD,$BE,$FB,$7A,$BD,$BE,$BD
L3A20         fcb   $07,$86,$FD,$08,$7A,$F9,$7A,$BD
L3A28         fcb   $BE,$FB,$7A,$BD,$BE,$BD,$07,$86
L3A30         fcb   $FD,$08,$7A,$F9,$7A,$BD,$BE,$FB
L3A38         fcb   $7A,$BD,$BE,$BD,$07,$86,$FD,$00
L3A40         fcb   $08,$40,$7A,$F9,$7A,$BD,$BE,$FB
L3A48         fcb   $7A,$BD,$BE,$BD,$07,$86,$FD,$08
L3A50         fcb   $7A,$F9,$7A,$BD,$BE,$FB,$7A,$BD
L3A58         fcb   $BE,$BD,$07,$86,$FD,$92,$FD,$92
L3A60         fcb   $FD,$92,$BD,$BE,$BD,$92,$FD,$92
L3A68         fcb   $BD,$BE,$BD,$92,$FD,$92,$F9,$08
L3A70         fcb   $7A,$BD,$BE,$FB,$7A,$BD,$BE,$BD
L3A78         fcb   $07,$86,$FD,$08,$7A,$F9,$7A,$BD
L3A80         fcb   $BE,$FB,$7A,$BD,$BE,$BD,$07,$86
L3A88         fcb   $FD,$08,$7A,$F9,$00,$08,$40,$7A
L3A90         fcb   $BD,$BE,$FB,$7A,$BD,$BE,$BD,$07
L3A98         fcb   $86,$FD,$08,$7A,$F9,$7A,$BD,$BE
L3AA0         fcb   $FB,$7A,$BD,$BE,$BD,$07,$86,$FD
L3AA8         fcb   $08,$7A,$F9,$7A,$BD,$BE,$FB,$7A
L3AB0         fcb   $BD,$BE,$BD,$07,$86,$FD,$08,$7A
L3AB8         fcb   $F9,$7A,$BD,$BE,$FB,$7A,$BD,$BE
L3AC0         fcb   $BD,$07,$86,$FD,$08,$7A,$F9,$7A
L3AC8         fcb   $BD,$BE,$FB,$7A,$BD,$BE,$BD,$07
L3AD0         fcb   $86,$FD,$08,$7A,$F9,$7A,$BD,$BE
L3AD8         fcb   $FB,$00,$01,$40,$97,$FC,$BE,$FE
L3AE0         fcb   $97,$FD,$BE,$FD,$97,$FC,$BE,$FE
L3AE8         fcb   $95,$FC,$BE,$FE,$95,$FC,$BE,$FE
L3AF0         fcb   $95,$F9,$93,$FC,$BE,$FE,$93,$FC
L3AF8         fcb   $BE,$FE,$93,$F9,$98,$F9,$9A,$FD
L3B00         fcb   $9C,$EC,$BE,$FA,$98,$F1,$00,$50
L3B08         fcb   $D9,$0C,$93,$E9,$98,$E1,$98,$F9
L3B10         fcb   $97,$FB,$BE,$BD,$95,$F1,$00,$50
L3B18         fcb   $D9,$0D,$8E,$E9,$93,$E1,$93,$F9
L3B20         fcb   $92,$FB,$BE,$BD,$90,$F1,$00,$03
L3B28         fcb   $40,$97,$FC,$BE,$FE,$97,$FD,$BE
L3B30         fcb   $FD,$97,$FC,$BE,$FE,$95,$FC,$BE
L3B38         fcb   $FE,$95,$FC,$BE,$FE,$95,$F9,$93
L3B40         fcb   $FC,$BE,$FE,$93,$FC,$BE,$FE,$93
L3B48         fcb   $F9,$98,$F9,$9A,$FD,$9C,$EC,$BE
L3B50         fcb   $FA,$98,$F1,$00,$05,$4E,$10,$76
L3B58         fcb   $50,$BE,$BD,$04,$76,$BD,$BE,$BD
L3B60         fcb   $76,$F9,$76,$FB,$BE,$BD,$05,$76
L3B68         fcb   $BE,$FE,$04,$76,$BD,$BE,$BD,$76
L3B70         fcb   $F9,$7B,$F9,$05,$7B,$BD,$BE,$BD
L3B78         fcb   $04,$7B,$FD,$7B,$F9,$80,$F9,$05
L3B80         fcb   $80,$BD,$BE,$BD,$04,$80,$FE,$BE
L3B88         fcb   $80,$F9,$80,$F9,$05,$80,$FB,$BE
L3B90         fcb   $BD,$04,$7F,$FA,$BE,$7D,$F9,$05
L3B98         fcb   $7D,$BD,$BE,$BD,$04,$7D,$FE,$BE
L3BA0         fcb   $00,$50,$D9,$01,$97,$F5,$95,$DF
L3BA8         fcb   $BE,$F3,$98,$FC,$BE,$FE,$98,$FD
L3BB0         fcb   $BE,$FD,$98,$FD,$BE,$FD,$98,$FD
L3BB8         fcb   $00,$50,$E1,$0C,$8E,$D1,$95,$D5
L3BC0         fcb   $8E,$FD,$00,$50,$E1,$0D,$89,$D1
L3BC8         fcb   $90,$D5,$89,$FD,$00,$50,$E5,$03
L3BD0         fcb   $97,$F5,$95,$DF,$BE,$F3,$98,$FC
L3BD8         fcb   $BE,$FE,$98,$FD,$BE,$FD,$98,$FD
L3BE0         fcb   $BE,$FD,$98,$FC,$BE,$FE,$97,$F9
L3BE8         fcb   $00,$04,$4E,$10,$7D,$50,$FA,$7D
L3BF0         fcb   $F9,$05,$7D,$BD,$BE,$BD,$04,$7D
L3BF8         fcb   $FD,$7D,$F9,$76,$F9,$05,$76,$BD
L3C00         fcb   $BE,$BD,$04,$76,$BD,$BE,$BD,$76
L3C08         fcb   $F9,$76,$FA,$BE,$05,$76,$FD,$04
L3C10         fcb   $76,$BD,$BE,$BD,$76,$F9,$71,$FB
L3C18         fcb   $BE,$BD,$05,$71,$BD,$BE,$BD,$04
L3C20         fcb   $71,$F9,$71,$F9,$71,$BD,$BE,$BD
L3C28         fcb   $05,$71,$FD,$04,$71,$F9,$76,$FD
L3C30         fcb   $00,$08,$40,$7A,$F9,$7A,$BD,$BE
L3C38         fcb   $FB,$7A,$BD,$BE,$BD,$07,$86,$FD
L3C40         fcb   $08,$7A,$F9,$7A,$BD,$BE,$FB,$7A
L3C48         fcb   $BD,$BE,$BD,$07,$86,$FD,$08,$7A
L3C50         fcb   $F9,$7A,$BD,$BE,$FB,$7A,$BD,$BE
L3C58         fcb   $BD,$07,$86,$FD,$08,$7A,$F9,$7A
L3C60         fcb   $BD,$BE,$FB,$7A,$BD,$BE,$BD,$07
L3C68         fcb   $86,$FD,$08,$7A,$F9,$7A,$BD,$BE
L3C70         fcb   $FB,$7A,$BD,$BE,$BD,$07,$86,$FD
L3C78         fcb   $92,$BD,$92,$BD,$92,$BD,$92,$BD
L3C80         fcb   $00,$01,$40,$97,$F9,$95,$DD,$93
L3C88         fcb   $FD,$BE,$FD,$93,$FD,$BE,$FE,$93
L3C90         fcb   $FC,$93,$FD,$95,$F5,$BE,$F5,$93
L3C98         fcb   $FE,$BE,$FC,$93,$FD,$BE,$FD,$93
L3CA0         fcb   $FD,$93,$FD,$95,$FD,$95,$FD,$8E
L3CA8         fcb   $FD,$00,$50,$D5,$0C,$95,$E9,$8E
L3CB0         fcb   $E9,$95,$E9,$8E,$F5,$00,$50,$D5
L3CB8         fcb   $0D,$90,$E9,$89,$E9,$90,$E9,$89
L3CC0         fcb   $F5,$00,$03,$40,$97,$F9,$95,$DD
L3CC8         fcb   $93,$FD,$BE,$FD,$93,$FD,$BE,$FE
L3CD0         fcb   $93,$FC,$93,$FD,$95,$F5,$BE,$F5
L3CD8         fcb   $93,$FE,$BE,$FC,$93,$FD,$BE,$FD
L3CE0         fcb   $93,$FD,$93,$FE,$51,$11,$40,$95
L3CE8         fcb   $FD,$95,$FD,$8E,$FD,$00,$5E,$10
L3CF0         fcb   $50,$FE,$04,$76,$BE,$BE,$BD,$05
L3CF8         fcb   $76,$BD,$BE,$BD,$04,$76,$F9,$76
L3D00         fcb   $F9,$76,$BD,$BE,$BD,$05,$76,$FD
L3D08         fcb   $04,$76,$F9,$71,$F9,$71,$BD,$BE
L3D10         fcb   $BD,$05,$71,$FE,$BE,$04,$71,$F9
L3D18         fcb   $76,$F9,$76,$BD,$BE,$BD,$05,$76
L3D20         fcb   $FD,$04,$76,$F9,$71,$F9,$71,$BE
L3D28         fcb   $FE,$05,$71,$BD,$BE,$BD,$04,$71
L3D30         fcb   $F9,$05,$4E,$12,$76,$50,$FE,$76
L3D38         fcb   $BE,$04,$76,$BD,$05,$76,$FD,$00
L3D40         fcb   $08,$40,$7A,$BD,$BE,$BD,$07,$86
L3D48         fcb   $FD,$08,$7A,$F9,$7A,$BD,$BE,$FB
L3D50         fcb   $7A,$BD,$BE,$BD,$07,$86,$FD,$08
L3D58         fcb   $7A,$F9,$7A,$BD,$BE,$FB,$7A,$BD
L3D60         fcb   $BE,$BD,$07,$86,$FD,$08,$7A,$F9
L3D68         fcb   $7A,$BD,$BE,$FB,$7A,$BD,$BE,$BD
L3D70         fcb   $07,$86,$FD,$08,$7A,$F9,$7A,$BD
L3D78         fcb   $BE,$FB,$7A,$BD,$BE,$BD,$07,$86
L3D80         fcb   $FD,$08,$7A,$FB,$46,$00,$BE,$50
L3D88         fcb   $06,$4B,$00,$AD,$50,$F2,$00,$02
L3D90         fcb   $40,$93,$FD,$87,$FD,$93,$FD,$87
L3D98         fcb   $FD,$95,$FD,$89,$FD,$95,$FD,$89
L3DA0         fcb   $FD,$95,$FD,$89,$FD,$95,$FD,$89
L3DA8         fcb   $C0,$FD,$0C,$83,$F1,$00,$40,$BE
L3DB0         fcb   $FD,$02,$7B,$F5,$7D,$F5,$7D,$F5
L3DB8         fcb   $7D,$FC,$BE,$C0,$FE,$0D,$83,$F1
L3DC0         fcb   $00,$40,$84,$BD,$BE,$BD,$86,$BD
L3DC8         fcb   $BE,$BD,$87,$F9,$89,$F9,$81,$BD
L3DD0         fcb   $BE,$FB,$82,$FA,$BE,$84,$F9,$86
L3DD8         fcb   $FD,$88,$FD,$89,$F9,$8A,$FD,$8C
L3DE0         fcb   $FD,$8E,$F9,$8C,$FD,$8E,$FD,$90
L3DE8         fcb   $F9,$8E,$FD,$90,$FD,$91,$F9,$87
L3DF0         fcb   $FD,$88,$FD,$8A,$FD,$8C,$FD,$00
L3DF8         fcb   $4E,$10,$BE,$50,$BE,$BD,$04,$7A
L3E00         fcb   $BD,$BE,$BD,$7B,$F9,$05,$7D,$F9
L3E08         fcb   $04,$75,$BD,$BE,$BD,$75,$FD,$76
L3E10         fcb   $FA,$BE,$05,$78,$F9,$04,$7A,$FD
L3E18         fcb   $7C,$FD,$7D,$F9,$05,$72,$FD,$04
L3E20         fcb   $74,$FD,$76,$F9,$74,$FD,$76,$FD
L3E28         fcb   $05,$78,$F9,$04,$76,$FD,$78,$FD
L3E30         fcb   $79,$F9,$05,$77,$F1,$00,$50,$E4
L3E38         fcb   $46,$00,$BE,$50,$BD,$06,$4B,$00
L3E40         fcb   $AD,$50,$DC,$46,$00,$BE,$50,$4B
L3E48         fcb   $00,$AD,$50,$E0,$56,$00,$50,$4B
L3E50         fcb   $00,$AD,$50,$EE,$00,$50,$E1,$0C
L3E58         fcb   $80,$D9,$82,$DD,$8E,$ED,$00,$50
L3E60         fcb   $E1,$0D,$87,$D9,$89,$DD,$89,$ED
L3E68         fcb   $00,$40,$8E,$FD,$8F,$FD,$91,$FD
L3E70         fcb   $8F,$FD,$91,$FD,$93,$FD,$94,$F7
L3E78         fcb   $89,$FD,$87,$FD,$89,$FD,$8A,$FD
L3E80         fcb   $89,$FC,$8A,$FD,$8C,$FC,$8E,$FA
L3E88         fcb   $BE,$FE,$86,$FD,$84,$FD,$86,$FD
L3E90         fcb   $87,$FD,$89,$FD,$87,$FD,$89,$FD
L3E98         fcb   $8B,$FD,$8C,$BD,$0C,$82,$ED,$00
L3EA0         fcb   $40,$8E,$FD,$8F,$FD,$91,$FD,$8F
L3EA8         fcb   $FD,$91,$FD,$93,$FD,$94,$F7,$89
L3EB0         fcb   $FD,$87,$FD,$89,$FD,$8A,$FD,$89
L3EB8         fcb   $FC,$8A,$FD,$8C,$FC,$8E,$F9,$BE
L3EC0         fcb   $BD,$86,$FD,$84,$FD,$86,$FD,$87
L3EC8         fcb   $FD,$89,$FD,$87,$FD,$89,$FD,$8B
L3ED0         fcb   $FD,$8C,$FD,$02,$46,$1C,$89,$46
L3ED8         fcb   $2C,$86,$46,$3C,$87,$46,$4C,$89
L3EE0         fcb   $46,$5C,$87,$46,$6C,$89,$46,$9C
L3EE8         fcb   $8B,$46,$AC,$89,$46,$BC,$8B,$46
L3EF0         fcb   $CC,$8C,$46,$DC,$8E,$46,$EC,$90
L3EF8         fcb   $46,$FC,$8E,$92,$8E,$95,$8E,$50
L3F00         fcb   $00,$5E,$10,$50,$E2,$05,$74,$D9
L3F08         fcb   $4F,$06,$76,$50,$F7,$5F,$06,$50
L3F10         fcb   $FC,$5E,$13,$50,$FD,$5F,$06,$50
L3F18         fcb   $FC,$5E,$14,$50,$FD,$5F,$07,$50
L3F20         fcb   $5F,$1E,$4F,$21,$76,$50,$5F,$1F
L3F28         fcb   $50,$5F,$20,$50,$5F,$21,$50,$5F
L3F30         fcb   $22,$50,$5F,$23,$50,$5F,$24,$50
L3F38         fcb   $5F,$27,$5F,$24,$5F,$27,$5F,$3F
L3F40         fcb   $5F,$4F,$5F,$64,$00,$02,$40,$82
L3F48         fcb   $E1,$82,$E1,$00,$02,$40,$89,$FD
L3F50         fcb   $89,$F1,$89,$F9,$89,$FD,$89,$FD
L3F58         fcb   $89,$F1,$89,$F9,$89,$FD,$00,$02
L3F60         fcb   $40,$8E,$F9,$8E,$E9,$8E,$F9,$8E
L3F68         fcb   $E9,$00,$03,$40,$8E,$F2,$56,$EA
L3F70         fcb   $50,$BE,$D2,$00,$02,$40,$92,$F5
L3F78         fcb   $92,$FD,$97,$F9,$95,$F9,$92,$F5
L3F80         fcb   $92,$FD,$97,$F9,$95,$F9,$00,$04
L3F88         fcb   $40,$76,$FB,$56,$EE,$40,$BE,$E8
L3F90         fcb   $76,$FB,$56,$EE,$40,$BE,$E8,$00
L3F98         fcb   $08,$40,$77,$FD,$07,$77,$BD,$08
L3FA0         fcb   $77,$BD,$77,$FD,$07,$75,$BD,$08
L3FA8         fcb   $75,$BD,$75,$FD,$07,$75,$FD,$08
L3FB0         fcb   $75,$FD,$75,$FD,$75,$FD,$75,$FD
L3FB8         fcb   $75,$FC,$75,$FD,$75,$FD,$07,$78
L3FC0         fcb   $FD,$08,$75,$FD,$07,$75,$FD,$08
L3FC8         fcb   $75,$BD,$75,$BD,$07,$75,$FD,$08
L3FD0         fcb   $75,$BD,$75,$BD,$07,$75,$BD,$08
L3FD8         fcb   $75,$BD,$75,$BD,$75,$BD,$07,$75
L3FE0         fcb   $FD,$08,$75,$BD,$75,$BD,$07,$75
L3FE8         fcb   $FD,$08,$75,$BD,$75,$BD,$07,$75
L3FF0         fcb   $FD,$08,$75,$EC,$BE,$BD,$00,$46
L3FF8         fcb   $00,$BE,$50,$F9,$0F,$8E,$92,$95
L4000         fcb   $9A,$F5,$01,$49,$01,$9E,$50,$FE
L4008         fcb   $9F,$FD,$9E,$FD,$9F,$FE,$BE,$F9
L4010         fcb   $0F,$9A,$BD,$0C,$99,$F9,$9A,$F9
L4018         fcb   $98,$FB,$9A,$BD,$97,$F9,$01,$98
L4020         fcb   $BD,$97,$BD,$93,$BD,$8B,$43,$00
L4028         fcb   $8E,$50,$8E,$FA,$98,$BD,$97,$BD
L4030         fcb   $93,$BD,$8B,$43,$00,$8E,$50,$8E
L4038         fcb   $FC,$BE,$BD,$97,$BD,$93,$BD,$95
L4040         fcb   $BD,$97,$93,$BD,$8F,$FE,$56,$CC
L4048         fcb   $40,$BE,$BD,$00,$01,$49,$01,$97
L4050         fcb   $50,$FA,$95,$F9,$93,$F9,$0F,$92
L4058         fcb   $FD,$93,$FD,$92,$FE,$43,$00,$95
L4060         fcb   $93,$50,$FE,$95,$FE,$97,$43,$00
L4068         fcb   $98,$97,$50,$FE,$9E,$FD,$0C,$A0
L4070         fcb   $BD,$A2,$BD,$A3,$F9,$9C,$FB,$9E
L4078         fcb   $BD,$9A,$F9,$9C,$FB,$9E,$BD,$9A
L4080         fcb   $BD,$BE,$FB,$BE,$E4,$BE,$BD,$00
L4088         fcb   $50,$0F,$8E,$93,$97,$9A,$F4,$8E
L4090         fcb   $93,$97,$9C,$FE,$52,$11,$43,$00
L4098         fcb   $97,$50,$BD,$43,$00,$98,$97,$50
L40A0         fcb   $FE,$97,$FE,$43,$00,$98,$97,$50
L40A8         fcb   $FE,$92,$FE,$93,$43,$00,$95,$93
L40B0         fcb   $50,$FE,$96,$FD,$0B,$97,$BD,$99
L40B8         fcb   $BD,$0C,$9A,$F9,$A4,$FB,$A6,$BD
L40C0         fcb   $A3,$F9,$9F,$FB,$A1,$BD,$9E,$F9
L40C8         fcb   $BE,$E4,$BE,$BD,$00,$01,$49,$01
L40D0         fcb   $93,$50,$FA,$92,$F9,$90,$F9,$8F
L40D8         fcb   $FD,$90,$FD,$8F,$FD,$93,$FE,$BE
L40E0         fcb   $F3,$0C,$9E,$FD,$97,$FD,$BE,$ED
L40E8         fcb   $03,$A4,$BD,$A3,$BD,$9F,$BD,$97
L40F0         fcb   $43,$00,$9A,$50,$9A,$BD,$BE,$FC
L40F8         fcb   $A4,$BD,$A3,$BD,$9F,$BD,$97,$43
L4100         fcb   $00,$9A,$50,$9A,$FC,$BE,$BD,$01
L4108         fcb   $A3,$BD,$9F,$BD,$A1,$BD,$A3,$9F
L4110         fcb   $BD,$8F,$FE,$56,$CC,$40,$BE,$BD
L4118         fcb   $00,$05,$4F,$1F,$7B,$50,$BD,$04
L4120         fcb   $82,$87,$BD,$82,$7B,$05,$7A,$FD
L4128         fcb   $04,$86,$BD,$7A,$BD,$05,$78,$F9
L4130         fcb   $77,$FD,$04,$78,$FD,$05,$77,$FD
L4138         fcb   $04,$78,$FD,$05,$82,$04,$80,$7F
L4140         fcb   $4F,$0F,$7D,$BD,$4F,$1F,$7B,$50
L4148         fcb   $FE,$05,$7A,$FE,$04,$81,$86,$BD
L4150         fcb   $81,$7A,$05,$7F,$F9,$80,$FB,$04
L4158         fcb   $80,$BE,$05,$7B,$FB,$04,$7B,$7A
L4160         fcb   $05,$78,$F9,$73,$F9,$78,$F9,$73
L4168         fcb   $F9,$78,$F9,$74,$FA,$00,$50,$EC
L4170         fcb   $02,$97,$FD,$97,$BD,$9A,$BD,$9C
L4178         fcb   $BD,$9E,$BD,$9C,$BD,$9E,$BD,$97
L4180         fcb   $FD,$97,$BD,$9A,$BD,$9C,$BD,$9E
L4188         fcb   $BD,$9C,$BD,$9E,$FE,$9A,$FC,$9A
L4190         fcb   $BD,$9D,$BD,$9C,$BD,$9D,$BD,$9C
L4198         fcb   $BD,$9C,$FB,$9A,$BD,$98,$BD,$98
L41A0         fcb   $BD,$97,$BD,$97,$BD,$94,$BD,$90
L41A8         fcb   $BD,$8E,$BD,$95,$BD,$99,$BD,$95
L41B0         fcb   $FD,$95,$FD,$95,$FD,$95,$FD,$95
L41B8         fcb   $FD,$95,$F4,$00,$50,$EC,$02,$93
L41C0         fcb   $BD,$93,$FB,$98,$FD,$98,$FD,$93
L41C8         fcb   $BD,$93,$FB,$98,$FD,$98,$FD,$95
L41D0         fcb   $FD,$95,$FD,$8E,$BD,$8C,$BD,$8E
L41D8         fcb   $BD,$8C,$BD,$8B,$FB,$95,$F9,$94
L41E0         fcb   $F9,$89,$FB,$92,$FD,$90,$FD,$8F
L41E8         fcb   $FD,$8E,$FB,$89,$F4,$00,$5B,$00
L41F0         fcb   $50,$ED,$02,$8E,$F9,$93,$FD,$93
L41F8         fcb   $FD,$8E,$F9,$93,$FD,$93,$FD,$92
L4200         fcb   $BD,$92,$FB,$91,$F9,$90,$FB,$91
L4208         fcb   $F9,$90,$F9,$8D,$FB,$8E,$FD,$8D
L4210         fcb   $FD,$8C,$FD,$8B,$FA,$8D,$F5,$00
L4218         fcb   $50,$FD,$01,$97,$BD,$95,$BD,$95
L4220         fcb   $BD,$93,$BD,$93,$BD,$90,$FC,$92
L4228         fcb   $BD,$93,$FB,$46,$CD,$BE,$50,$E0
L4230         fcb   $0E,$8E,$BD,$43,$16,$8C,$BD,$43
L4238         fcb   $00,$8C,$50,$43,$16,$8B,$BD,$40
L4240         fcb   $8B,$F3,$97,$BE,$94,$BD,$90,$BD
L4248         fcb   $8E,$BD,$8D,$FD,$95,$FA,$56,$AC
L4250         fcb   $50,$BD,$BE,$F7,$02,$A1,$F4,$00
L4258         fcb   $50,$FD,$01,$A3,$BD,$A1,$BD,$A1
L4260         fcb   $BD,$9F,$BD,$9F,$BD,$9C,$FC,$9E
L4268         fcb   $BD,$9F,$FB,$46,$CD,$BE,$50,$E8
L4270         fcb   $02,$86,$F9,$95,$F9,$94,$BD,$94
L4278         fcb   $BD,$97,$F7,$84,$F9,$90,$FB,$89
L4280         fcb   $EE,$89,$F5,$00,$5F,$1F,$50,$FD
L4288         fcb   $04,$82,$F1,$7B,$F1,$7B,$F1,$7A
L4290         fcb   $FD,$5F,$20,$50,$FE,$79,$F9,$78
L4298         fcb   $FA,$5F,$21,$50,$FB,$78,$F7,$5F
L42A0         fcb   $22,$50,$FE,$71,$F9,$5F,$24,$50
L42A8         fcb   $BE,$FE,$5F,$24,$50,$BD,$5F,$25
L42B0         fcb   $50,$02,$4F,$0F,$99,$50,$F5,$00
L42B8         fcb   $50,$C1,$00,$50,$C1,$00
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

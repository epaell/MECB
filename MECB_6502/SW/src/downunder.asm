               org   $002F
;
; Zero-page variables
;
Z002F          dc.b  $00
Z0030          dc.b  $00
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
;
;
; Header information
;
               org   $0F82
;
L0F82          dc.b  $50,$53,$49,$44,$00,$02,$00,$7C
L0F8A          dc.b  $00,$00,$10,$00,$10,$03,$00,$01
L0F92          dc.b  $00,$01,$00,$00,$00,$00,$44,$6F
L0F9A          dc.b  $77,$6E,$20,$55,$6E,$64,$65,$72
L0FA2          dc.b  $00,$00,$00,$00,$00,$00,$00,$00
L0FAA          dc.b  $00,$00,$00,$00,$00,$00,$00,$00
L0FB2          dc.b  $00,$00,$00,$00,$00,$00,$53,$61
L0FBA          dc.b  $6D,$69,$20,$4C,$6F,$75,$6B,$6F
L0FC2          dc.b  $20,$28,$50,$72,$6F,$74,$6F,$6E
L0FCA          dc.b  $29,$00,$00,$00,$00,$00,$00,$00
L0FD2          dc.b  $00,$00,$00,$00,$00,$00,$32,$30
L0FDA          dc.b  $32,$30,$20,$46,$69,$6E,$6E,$69
L0FE2          dc.b  $73,$68,$20,$47,$6F,$6C,$64,$00
L0FEA          dc.b  $00,$00,$00,$00,$00,$00,$00,$00
L0FF2          dc.b  $00,$00,$00,$00,$00,$00,$00,$24
L0FFA          dc.b  $00,$00,$00,$00,$00,$10
;
               org   $1000
;
sid_init:
               JMP   INIT
;
sid_play:
               JMP   PLAY
;
M1006          dc.b  $40,$46,$46,$4D,$4D,$57,$57
               dc.b  $5B,$5B,$5B,$5B,$5B,$5B,$5B,$5B
               dc.b  $6C
M1016          dc.b  $84,$AB,$AB,$A8,$8B
M101B          dc.b  $08
M101C          dc.b  $05,$00,$00,$00
;
               dc.b  'Sami Louko (proton)             '
;
L1040          LDA   M1528,Y
               JMP   L104D
               TAY
               LDA   #$00
               STA   M13DC,X
               TYA
L104D          STA   M13B3,X
               LDA   M13A2,X
               STA   M13B2,X
               RTS
;
               STA   SID+$06,X     ; SID sustain level / release duration
               RTS
;
               TAY
               LDA   M15CD,Y
               STA   M101B
               LDA   M15D1,Y
               STA   M101C
               LDA   #$00
               BEQ   L106E
               BMI   L1078
L106E          STA   M13C9
               STA   M13D0
               STA   M13D7
               RTS
;
L1078          AND   #$7F
               STA   M13C9,X
               RTS
;
L107E          DEC   M13DD,X
L1081          JMP   L12C0
L1084          BEQ   L1081
               LDA   M13DD,X
               BNE   L107E
               LDA   #$00
               STA   Z0030
               LDA   M13DC,X
               BMI   L109D
               CMP   M15CD,Y
               BCC   L109E
               BEQ   L109D
               EOR   #$FF
L109D          CLC
L109E          ADC   #$02
               STA   M13DC,X
               LSR   A
               BCC   L10CC
               BCS   L10E3
               TYA
               BEQ   L10F3
               LDA   M15CD,Y
               STA   Z0030
               SEC
               LDY   M13CB,X
               LDA   M13DF,X
               SBC   M13FA,Y
               PHA
               LDA   M13E0,X
               SBC   M144E,Y
               TAY
               PLA
               BCS   L10DC
               ADC   Z002F
               TYA
               ADC   Z0030
               BPL   L10F3
L10CC          LDA   M13DF,X
               ADC   Z002F
               STA   M13DF,X
               LDA   M13E0,X
               ADC   Z0030
               JMP   L12BD
L10DC          SBC   Z002F
               TYA
               SBC   Z0030
               BMI   L10F3
L10E3          LDA   M13DF,X
               SBC   Z002F
               STA   M13DF,X
               LDA   M13E0,X
               SBC   Z0030
               JMP   L12BD
L10F3          LDY   M13CB,X
               JMP   L12AF
;
INIT           STA   L10FF+1
               RTS
;
PLAY           LDX   #$00
L10FF          LDY   #$00
               BMI   L1133
               TXA
               LDX   #$29
L1106          STA   M139D,X
               DEX
               BPL   L1106
               STA   SID+$15    ; SID filter cutoff frequency low byte
               STA   L1181+1
               STA   L1133+1
               STX   L10FF+1
               TAX
               JSR   L1123
               LDX   #$07
               JSR   L1123
               LDX   #$0E
L1123          LDA   #$05
               STA   M13C9,X
               LDA   #$01
               STA   M13CA,X
               STA   M13CC,X
               JMP   L1393
;
L1133          LDY   #$00
               BEQ   L117C
L1137          LDA   #$00
               BNE   L115E
               LDA   M15C4,Y
               BEQ   L1152
               BPL   L115B
               ASL   A
               STA   L1186+1
               LDA   M15C8,Y
               STA   L1181+1
               LDA   M15C5,Y
               BNE   L1170
               INY
L1152          LDA   M15C8,Y
               STA   L117C+1
               JMP   L116D
;
L115B          STA   L1137+1
L115E          LDA   M15C8,Y
               CLC
               ADC   L117C+1
               STA   L117C+1
               DEC   L1137+1
               BNE   L117E
L116D          LDA   M15C5,Y
L1170          CMP   #$FF
               INY
               TYA
               BCC   L1179
               LDA   M15C8,Y
L1179          STA   L1133+1
L117C          LDA   #$00
L117E          STA   SID+$16    ; SID filter cutoff frequency high byte
L1181          LDA   #$00
               STA   SID+$17    ; SID filter resonance and routing
L1186          LDA   #$00
               ORA   #$0F
               STA   SID+$18    ; SID filter mode and main volume control
               JSR   L1197
               LDX   #$07
               JSR   L1197
               LDX   #$0E
L1197          DEC   M13CA,X
               BEQ   L11B6
               BPL   L11B3
               LDA   M13C9,X
               CMP   #$02
               BCS   L11B0
               TAY
               EOR   #$01
               STA   M13C9,X
               LDA   M101B,Y
               SBC   #$00
L11B0          STA   M13CA,X
L11B3          JMP   L125E
L11B6          LDY   M13A2,X
               LDA   M1006,Y
               STA   L1252+1
               STA   L125B+1
               LDA   M13A0,X
               BNE   L11EB
               LDY   M13C7,X
               LDA   M14AE,Y
               STA   Z002F
               LDA   M14B1,Y
               STA   Z0030
               LDY   M139D,X
               LDA   (Z002F),Y
               CMP   #$FF
               BCC   L11E3
               INY
               LDA   (Z002F),Y
               TAY
               LDA   (Z002F),Y
L11E3          STA   M13C8,X
               INY
               TYA
               STA   M139D,X
L11EB          LDY   M13CC,X
               LDA   M153A,Y
               STA   M13F6,X
               LDA   M13B4,X
               BEQ   L1258
               SEC
               SBC   #$60
               STA   M13CB,X
               LDA   #$00
               STA   M13B2,X
               STA   M13B4,X
               LDA   M1531,Y
               STA   M13DD,X
               LDA   M1528,Y
               STA   M13B3,X
               LDA   M13A2,X
               CMP   #$03
               BEQ   L1258
               LDA   M1543,Y
               STA   M13B6,X
               INC   M13CD,X
               LDA   M1516,Y
               BEQ   L1230
               STA   M13B7,X
               LDA   #$00
               STA   M13B8,X
L1230          LDA   M151F,Y
               BEQ   L123D
               STA   L1133+1
               LDA   #$00
               STA   L1137+1
L123D          LDA   M150D,Y
               STA   M13B5,X
               LDA   M1504,Y
               STA   SID+$06,X
               LDA   M14FB,Y
               STA   SID+$05,X
               LDA   M13A3,X
L1252          JSR   L1040
               JMP   L1393
;
L1258          LDA   M13A3,X
L125B          JSR   L1040
L125E          LDY   M13B5,X
               BEQ   L1293
               LDA   M154C,Y
               CMP   #$10
               BCS   L1274
               CMP   M13DE,X
               BEQ   L1279
               INC   M13DE,X
               BNE   L1293
L1274          SBC   #$10
               STA   M13B6,X
L1279          LDA   M154D,Y
               CMP   #$FF
               INY
               TYA
               BCC   L1286
               CLC
               LDA   M1573,Y
L1286          STA   M13B5,X
               LDA   #$00
               STA   M13DE,X
               LDA   M1572,Y
               BNE   L12A7
L1293          LDY   M13B2,X
               LDA   M1016,Y
               STA   L12A4+1
               LDY   M13B3,X
               LDA   M15D1,Y
               STA   Z002F
L12A4          JMP   L1084
;
L12A7          BPL   L12AE
               ADC   M13CB,X
               AND   #$7F
L12AE          TAY
L12AF          LDA   #$00
               STA   M13DC,X
               LDA   M13FA,Y
               STA   M13DF,X
               LDA   M144E,Y
L12BD          STA   M13E0,X
L12C0          LDY   M13B7,X
               BEQ   L1304
               LDA   M13B8,X
               BNE   L12DB
               LDA   M159A,Y
               BPL   L12D8
               LDA   M15AF,Y
               STA   M13E1,X
               JMP   L12EC
L12D8          STA   M13B8,X
L12DB          LDA   M13E1,X
               CLC
               ADC   M15AF,Y
               ADC   #$00
               STA   M13E1,X
               DEC   M13B8,X
               BNE   L12FE
L12EC          LDA   M159B,Y
               CMP   #$FF
               INY
               TYA
               BCC   L12F8
               LDA   M15AF,Y
L12F8          STA   M13B7,X
               LDA   M13E1,X
L12FE          STA   SID+$02,X
               STA   SID+$03,X
L1304          LDA   M13CA,X
               CMP   M13F6,X
               BEQ   L130F
               JMP   L1387
;
L130F          LDY   M13C8,X
               LDA   M14B4,Y
               STA   Z002F
               LDA   M14D8,Y
               STA   Z0030
               LDY   M13A0,X
               LDA   (Z002F),Y
               CMP   #$40
               BCC   L133D
               CMP   #$60
               BCC   L1347
               CMP   #$C0
               BCC   L135B
               LDA   M13A1,X
               BNE   L1334
               LDA   (Z002F),Y
L1334          ADC   #$00
               STA   M13A1,X
               BEQ   L137E
               BNE   L1387
L133D          STA   M13CC,X
               INY
               LDA   (Z002F),Y
               CMP   #$60
               BCS   L135B
L1347          CMP   #$50
               AND   #$0F
               STA   M13A2,X
               BEQ   L1356
               INY
               LDA   (Z002F),Y
               STA   M13A3,X
L1356          BCS   L137E
               INY
               LDA   (Z002F),Y
L135B          CMP   #$BD
               BCC   L1365
               BEQ   L137E
               ORA   #$F0
               BNE   L137B
L1365          STA   M13B4,X
               LDA   M13A2,X
               CMP   #$03
               BEQ   L137E
               LDA   #$00
               STA   SID+$06,X
               LDA   #$0F
               STA   SID+$05,X
               LDA   #$FE
L137B          STA   M13CD,X
L137E          INY
               LDA   (Z002F),Y
               BEQ   L1384
               TYA
L1384          STA   M13A0,X
L1387          LDA   M13DF,X
               STA   SID+$00,X
               LDA   M13E0,X
               STA   SID+$01,X
L1393          LDA   M13B6,X
               AND   M13CD,X
               STA   SID+$04,X
               RTS
;
M139D          dc.b  $00,$00,$00
M13A0          dc.b  $00
M13A1          dc.b  $00
M13A2          dc.b  $00
M13A3          dc.b  $00,$00,$00,$00,$00,$00,$00
               dc.b  $00,$00,$00,$00,$00,$00,$00,$00
M13B2          dc.b  $00
M13B3          dc.b  $00
M13B4          dc.b  $00
M13B5          dc.b  $00
M13B6          dc.b  $00
M13B7          dc.b  $00
M13B8          dc.b  $00,$00
               dc.b  $00,$00,$00,$00,$00,$00,$00,$00
               dc.b  $00,$00,$00,$00,$00
M13C7          dc.b  $00
M13C8          dc.b  $00
M13C9          dc.b  $00
M13CA          dc.b  $00
M13CB          dc.b  $00
M13CC          dc.b  $01
M13CD          dc.b  $FE,$01,$00
M13D0          dc.b  $00,$00
               dc.b  $00,$01,$FE,$02,$00
M13D7          dc.b  $00,$00,$00
               dc.b  $01,$FE
M13DC          dc.b  $00
M13DD          dc.b  $00
M13DE          dc.b  $00
M13DF          dc.b  $00
M13E0          dc.b  $00
M13E1          dc.b  $00
               dc.b  $00,$00,$00,$00,$00,$00,$00,$00
               dc.b  $00,$00,$00,$00,$00,$00,$00,$00
               dc.b  $00,$00,$00,$00
M13F6          dc.b  $00,$00,$00,$00
M13FA          dc.b  $00,$00,$00,$00,$00,$00,$00,$00
               dc.b  $00,$00,$00,$00,$2D,$4E,$71,$96
               dc.b  $BE,$E8,$14,$43,$74,$A9,$E1,$1C
               dc.b  $5A,$9C,$E2,$2D,$7C,$CF,$28,$85
               dc.b  $E8,$52,$C1,$37,$B4,$39,$C5,$5A
               dc.b  $F7,$9E,$4F,$0A,$D1,$A3,$82,$6E
               dc.b  $68,$71,$8A,$B3,$EE,$3C,$9E,$15
               dc.b  $A2,$46,$04,$DC,$D0,$E2,$14,$67
               dc.b  $DD,$79,$3C,$29,$44,$8D,$08,$B8
               dc.b  $A1,$C5,$28,$CD,$BA,$F1,$78,$53
               dc.b  $87,$1A,$10,$71
M144E          dc.b  $42,$89,$4F,$9B
               dc.b  $74,$E2,$F0,$A6,$0E,$33,$20,$FF
               dc.b  $02,$02,$02,$02,$02,$02,$03,$03
               dc.b  $03,$03,$03,$04,$04,$04,$04,$05
               dc.b  $05,$05,$06,$06,$06,$07,$07,$08
               dc.b  $08,$09,$09,$0A,$0A,$0B,$0C,$0D
               dc.b  $0D,$0E,$0F,$10,$11,$12,$13,$14
               dc.b  $15,$17,$18,$1A,$1B,$1D,$1F,$20
               dc.b  $22,$24,$27,$29,$2B,$2E,$31,$34
               dc.b  $37,$3A,$3E,$41,$45,$49,$4E,$52
               dc.b  $57,$5C,$62,$68,$6E,$75,$7C,$83
               dc.b  $8B,$93,$9C,$A5,$AF,$B9,$C4,$D0
               dc.b  $DD,$EA,$F8,$FF
M14AE          dc.b  $D5,$EF,$09
M14B1          dc.b  $15
               dc.b  $15,$16
M14B4          dc.b  $23,$67,$A5,$E4,$F1,$5A
               dc.b  $BE,$1E,$82,$E5,$45,$A8,$0D,$71
               dc.b  $D5,$32,$92,$B0,$FC,$22,$4F,$73
               dc.b  $99,$E8,$18,$47,$6A,$99,$D5,$11
               dc.b  $46,$7D,$B3,$EC,$29,$70
M14D8          dc.b  $16,$16
               dc.b  $16,$16,$16,$17,$17,$18,$18,$18
               dc.b  $19,$19,$1A,$1A,$1A,$1B,$1B,$1B
               dc.b  $1B,$1C,$1C,$1C,$1C,$1C,$1D,$1D
               dc.b  $1D,$1D,$1D,$1E,$1E,$1E,$1E,$1E
               dc.b  $1F
M14FB          dc.b  $1F,$00,$00,$04,$00,$00,$00
               dc.b  $00,$08
M1504          dc.b  $02,$CA,$D8,$F7,$F8,$F9
               dc.b  $A8,$72,$F9
M150D          dc.b  $C9,$01,$01,$03,$18
               dc.b  $08,$0B,$21,$16
M1516          dc.b  $25,$01,$06,$0B
               dc.b  $0B,$06,$0B,$00,$0D
M151F          dc.b  $14,$00,$01
               dc.b  $00,$00,$00,$00,$00,$00
M1528          dc.b  $00,$01
               dc.b  $00,$00,$00,$02,$00,$00,$01
M1531          dc.b  $02
               dc.b  $0F,$00,$00,$00,$00,$00,$00,$0F
M153A          dc.b  $07,$02,$02,$02,$02,$02,$02,$02
               dc.b  $02
M1543          dc.b  $02,$09,$09,$09,$09,$09,$09
               dc.b  $19,$09
M154C          dc.b  $09
M154D          dc.b  $51,$FF,$91,$51,$51
               dc.b  $90,$FF,$21,$51,$FF,$91,$51,$51
               dc.b  $50,$50,$50,$50,$50,$50,$50,$FF
               dc.b  $31,$FF,$91,$21,$21,$21,$21,$21
               dc.b  $21,$20,$FF,$91,$01,$90,$FF,$51
M1572          dc.b  $21
M1573          dc.b  $FF,$80,$00,$58,$28,$2C,$54
               dc.b  $00,$80,$80,$00,$48,$94,$90,$92
               dc.b  $8C,$8A,$88,$86,$84,$82,$00,$80
               dc.b  $00,$5F,$24,$22,$1E,$1B,$1A,$17
               dc.b  $14,$1F,$5F,$5F,$4F,$00,$80,$80
M159A          dc.b  $00
M159B          dc.b  $80,$08,$30,$30,$FF,$80,$08
               dc.b  $18,$18,$FF,$80,$FF,$80,$FF,$03
               dc.b  $02,$16,$16,$FF,$80
M15AF          dc.b  $FF,$0A,$DF
               dc.b  $10,$EF,$03,$06,$20,$EF,$10,$08
               dc.b  $08,$00,$0A,$0F,$40,$20,$30,$CF
               dc.b  $11,$80
M15C4          dc.b  $00
M15C5          dc.b  $98,$00,$14
M15C8          dc.b  $FF,$81
               dc.b  $18,$FF,$00
M15CD          dc.b  $00,$03,$03,$03
M15D1          dc.b  $00
               dc.b  $40,$38,$04,$00,$00,$00,$01,$01
               dc.b  $00,$00,$00,$02,$02,$00,$00,$00
               dc.b  $00,$00,$02,$02,$02,$02,$02,$02
               dc.b  $02,$02,$03,$FF,$00,$04,$05,$05
               dc.b  $05,$06,$05,$05,$06,$07,$08,$09
               dc.b  $09,$04,$0A,$0B,$0C,$0D,$0E,$0F
               dc.b  $0E,$0F,$0F,$0F,$10,$FF,$00,$11
               dc.b  $12,$13,$14,$15,$16,$17,$18,$19
               dc.b  $1A,$1B,$1C,$11,$1D,$1E,$1F,$20
               dc.b  $21,$22,$21,$22,$22,$22,$23,$FF
               dc.b  $00,$02,$4E,$03,$77,$50,$83,$BE
               dc.b  $77,$BD,$83,$BE,$75,$BD,$81,$BE
               dc.b  $75,$BD,$81,$BE,$77,$BD,$83,$BE
               dc.b  $77,$BD,$83,$BE,$73,$BD,$7F,$BE
               dc.b  $75,$BD,$81,$BE,$77,$BD,$83,$BE
               dc.b  $77,$BD,$83,$BE,$75,$BD,$81,$BE
               dc.b  $75,$BD,$81,$BE,$77,$BD,$83,$BE
               dc.b  $77,$BD,$83,$BE,$73,$BD,$7F,$BE
               dc.b  $75,$BD,$81,$BE,$00,$02,$4F,$06
               dc.b  $7A,$50,$BD,$7A,$7A,$BD,$7A,$BD
               dc.b  $75,$FE,$75,$75,$BD,$75,$BD,$77
               dc.b  $FE,$77,$77,$BD,$77,$BD,$73,$BD
               dc.b  $73,$BD,$77,$FE,$77,$7A,$FE,$7A
               dc.b  $7A,$BD,$7A,$BD,$75,$FE,$75,$75
               dc.b  $BD,$75,$BD,$77,$FE,$77,$77,$BD
               dc.b  $77,$BD,$73,$BD,$73,$BD,$77,$BD
               dc.b  $77,$BD,$00,$02,$4F,$06,$6E,$50
               dc.b  $BD,$6E,$7A,$BD,$6E,$BD,$75,$FE
               dc.b  $75,$81,$BD,$75,$BD,$77,$FE,$77
               dc.b  $83,$BD,$77,$BD,$73,$BD,$7F,$BE
               dc.b  $75,$BD,$81,$BE,$6E,$FE,$6E,$7A
               dc.b  $BD,$6E,$BD,$75,$FE,$75,$81,$BD
               dc.b  $75,$BD,$77,$FE,$77,$83,$BD,$77
               dc.b  $BD,$73,$BD,$7F,$BE,$75,$BD,$81
               dc.b  $BE,$00,$02,$40,$77,$F7,$73,$FD
               dc.b  $75,$FD,$6E,$F4,$BE,$E0,$00,$04
               dc.b  $4F,$06,$9C,$50,$07,$9A,$9A,$04
               dc.b  $9C,$BD,$07,$9A,$9A,$04,$9C,$BD
               dc.b  $07,$9A,$9A,$04,$9C,$BD,$07,$9A
               dc.b  $9A,$04,$9C,$BD,$08,$92,$07,$9A
               dc.b  $04,$9C,$BD,$08,$92,$07,$9A,$04
               dc.b  $9C,$BD,$08,$8F,$07,$9A,$04,$9C
               dc.b  $BD,$08,$94,$07,$9A,$04,$9C,$BD
               dc.b  $07,$9A,$9A,$04,$9C,$BD,$07,$9A
               dc.b  $9A,$04,$9C,$BD,$08,$94,$07,$98
               dc.b  $04,$9C,$BD,$08,$94,$07,$98,$04
               dc.b  $9C,$BD,$07,$98,$98,$04,$9C,$BD
               dc.b  $07,$98,$98,$04,$9C,$BD,$07,$98
               dc.b  $98,$04,$9C,$BD,$07,$98,$98,$00
               dc.b  $04,$4F,$06,$9C,$50,$07,$98,$98
               dc.b  $03,$9F,$BD,$07,$A4,$A4,$04,$9C
               dc.b  $BD,$07,$98,$98,$03,$9F,$BD,$07
               dc.b  $A4,$A4,$04,$9C,$BD,$07,$98,$98
               dc.b  $03,$9F,$BD,$07,$A4,$A4,$04,$9C
               dc.b  $BD,$07,$98,$98,$03,$9F,$BD,$07
               dc.b  $A4,$03,$A4,$04,$9C,$BD,$07,$98
               dc.b  $98,$03,$9F,$BD,$07,$A4,$A4,$04
               dc.b  $9C,$BD,$07,$98,$98,$03,$9F,$BD
               dc.b  $07,$A4,$A4,$04,$9C,$BD,$07,$98
               dc.b  $98,$03,$9F,$BD,$07,$A4,$A4,$04
               dc.b  $9C,$03,$98,$07,$98,$98,$03,$9F
               dc.b  $BD,$A4,$A4,$00,$04,$4F,$06,$9C
               dc.b  $50,$07,$98,$98,$03,$9F,$BD,$07
               dc.b  $A4,$A4,$04,$9C,$BD,$07,$98,$98
               dc.b  $03,$9F,$BD,$07,$A4,$A4,$04,$9C
               dc.b  $BD,$07,$98,$98,$03,$9F,$BD,$07
               dc.b  $A4,$A4,$04,$9C,$BD,$07,$98,$98
               dc.b  $03,$9F,$BD,$07,$A4,$A4,$04,$9C
               dc.b  $BD,$07,$98,$98,$03,$9F,$BD,$07
               dc.b  $A4,$A4,$04,$9C,$BD,$07,$98,$98
               dc.b  $03,$9F,$BD,$07,$A4,$A4,$04,$9C
               dc.b  $03,$AB,$07,$98,$98,$03,$9F,$BD
               dc.b  $06,$7C,$7C,$BD,$78,$78,$BD,$75
               dc.b  $75,$70,$70,$00,$04,$4F,$06,$A2
               dc.b  $50,$08,$9E,$BE,$03,$9E,$BE,$08
               dc.b  $9E,$9E,$04,$9D,$BE,$08,$9D,$BE
               dc.b  $03,$9D,$BD,$08,$9B,$BD,$04,$9C
               dc.b  $BD,$07,$98,$98,$03,$9F,$BD,$07
               dc.b  $98,$98,$04,$9C,$BD,$07,$98,$98
               dc.b  $03,$9F,$BD,$07,$98,$98,$04,$9C
               dc.b  $BD,$07,$A4,$08,$9E,$03,$A2,$08
               dc.b  $A2,$BE,$A2,$04,$9C,$BD,$08,$9D
               dc.b  $07,$A4,$03,$AB,$BE,$08,$9D,$04
               dc.b  $A8,$08,$9B,$FE,$07,$A4,$03,$AB
               dc.b  $BD,$07,$A4,$A4,$04,$9C,$BD,$07
               dc.b  $A4,$A4,$03,$AB,$BD,$A4,$A4,$00
               dc.b  $04,$4F,$06,$90,$50,$08,$9E,$03
               dc.b  $9E,$08,$9E,$BD,$9E,$9E,$04,$9D
               dc.b  $BE,$08,$9D,$BE,$03,$9D,$BE,$08
               dc.b  $9E,$BD,$04,$9C,$BD,$07,$98,$98
               dc.b  $03,$9F,$BD,$07,$98,$98,$04,$9C
               dc.b  $BD,$07,$98,$98,$03,$9F,$BD,$07
               dc.b  $98,$A2,$04,$A2,$08,$A2,$A2,$BD
               dc.b  $03,$9E,$BE,$07,$98,$98,$04,$9C
               dc.b  $08,$9D,$9D,$BE,$03,$9D,$BD,$08
               dc.b  $9D,$9B,$04,$9C,$BD,$07,$98,$98
               dc.b  $03,$9F,$BD,$07,$98,$98,$04,$9C
               dc.b  $03,$9F,$07,$98,$98,$03,$9F,$BD
               dc.b  $98,$98,$00,$04,$4F,$06,$6C,$50
               dc.b  $08,$92,$92,$03,$93,$BD,$08,$92
               dc.b  $BE,$04,$6C,$BD,$08,$94,$94,$03
               dc.b  $93,$BD,$08,$94,$BE,$04,$6C,$BD
               dc.b  $08,$92,$92,$03,$93,$BD,$08,$92
               dc.b  $BE,$04,$6C,$BD,$08,$8F,$BE,$03
               dc.b  $93,$BD,$08,$91,$BE,$04,$6C,$BD
               dc.b  $08,$92,$92,$03,$93,$BD,$08,$92
               dc.b  $BE,$04,$6C,$BD,$08,$94,$94,$03
               dc.b  $93,$BD,$08,$94,$BE,$04,$6C,$BD
               dc.b  $07,$74,$74,$03,$93,$BD,$07,$74
               dc.b  $74,$04,$6C,$03,$93,$FE,$93,$BD
               dc.b  $93,$93,$00,$04,$4F,$06,$78,$50
               dc.b  $08,$92,$92,$03,$9F,$BD,$08,$92
               dc.b  $BE,$04,$78,$BD,$08,$94,$94,$03
               dc.b  $9F,$BD,$08,$94,$BE,$04,$78,$BD
               dc.b  $08,$92,$BE,$03,$9F,$BD,$08,$92
               dc.b  $BE,$04,$78,$BD,$08,$97,$BE,$03
               dc.b  $9F,$BD,$08,$94,$BE,$04,$78,$BD
               dc.b  $08,$99,$99,$03,$9F,$BE,$08,$9B
               dc.b  $BD,$04,$78,$BD,$08,$94,$94,$03
               dc.b  $9F,$BD,$08,$94,$BE,$04,$78,$BD
               dc.b  $07,$98,$BD,$03,$9F,$BD,$07,$98
               dc.b  $BD,$04,$78,$BD,$08,$8F,$BE,$03
               dc.b  $9F,$BD,$08,$94,$BE,$00,$04,$4F
               dc.b  $06,$78,$50,$07,$98,$08,$9E,$03
               dc.b  $93,$BE,$08,$A2,$A2,$04,$78,$08
               dc.b  $A2,$A0,$9E,$03,$93,$08,$9E,$9E
               dc.b  $BD,$04,$78,$08,$9E,$A2,$BD,$03
               dc.b  $93,$BD,$07,$98,$98,$04,$78,$BD
               dc.b  $07,$98,$98,$03,$93,$BD,$07,$98
               dc.b  $98,$04,$78,$BD,$07,$98,$08,$96
               dc.b  $03,$93,$BD,$07,$98,$98,$04,$78
               dc.b  $BD,$07,$98,$98,$03,$93,$BD,$07
               dc.b  $98,$98,$04,$78,$BD,$07,$98,$98
               dc.b  $03,$93,$BD,$07,$98,$98,$04,$78
               dc.b  $03,$9F,$07,$98,$98,$03,$93,$BD
               dc.b  $9F,$9F,$00,$04,$40,$6C,$BD,$07
               dc.b  $8C,$8C,$03,$93,$BD,$07,$8C,$8C
               dc.b  $04,$6C,$BD,$08,$9B,$BD,$03,$93
               dc.b  $08,$9D,$9E,$BD,$04,$6C,$BD,$08
               dc.b  $92,$96,$03,$93,$BD,$08,$92,$BE
               dc.b  $04,$6C,$BD,$08,$8F,$BE,$03,$93
               dc.b  $BD,$08,$91,$BE,$04,$6C,$BD,$07
               dc.b  $8C,$08,$96,$03,$93,$08,$99,$BE
               dc.b  $9B,$04,$6C,$BD,$08,$94,$BE,$03
               dc.b  $93,$08,$94,$94,$BD,$04,$6C,$BD
               dc.b  $08,$92,$BE,$03,$93,$BD,$08,$9E
               dc.b  $BE,$04,$6C,$BD,$08,$A3,$BE,$03
               dc.b  $93,$BD,$08,$A0,$03,$93,$00,$04
               dc.b  $40,$78,$BD,$07,$8C,$8C,$03,$93
               dc.b  $BD,$07,$8C,$8C,$04,$78,$BD,$08
               dc.b  $91,$BE,$03,$93,$08,$91,$91,$BE
               dc.b  $04,$78,$08,$8F,$BE,$92,$03,$93
               dc.b  $BD,$08,$92,$BE,$04,$78,$BD,$08
               dc.b  $8F,$BE,$03,$93,$BD,$08,$91,$BE
               dc.b  $04,$78,$08,$96,$BE,$96,$03,$93
               dc.b  $BD,$07,$8C,$8C,$04,$78,$08,$94
               dc.b  $BE,$94,$03,$93,$BD,$07,$8A,$8A
               dc.b  $04,$78,$08,$92,$BD,$07,$8A,$09
               dc.b  $A2,$08,$A7,$07,$8A,$8A,$04,$78
               dc.b  $03,$93,$07,$8A,$8A,$03,$93,$BD
               dc.b  $93,$93,$00,$04,$40,$78,$BD,$07
               dc.b  $8C,$8C,$03,$93,$BD,$07,$8C,$8C
               dc.b  $04,$78,$08,$91,$91,$BE,$03,$93
               dc.b  $08,$91,$8F,$BD,$04,$78,$BD,$08
               dc.b  $92,$BE,$03,$93,$BD,$08,$92,$BE
               dc.b  $04,$78,$BD,$08,$8F,$BE,$03,$93
               dc.b  $BD,$08,$91,$BE,$04,$78,$FE,$08
               dc.b  $96,$03,$93,$08,$92,$BE,$91,$04
               dc.b  $78,$BD,$BE,$BD,$03,$93,$BD,$08
               dc.b  $91,$BD,$04,$78,$08,$8F,$BE,$BD
               dc.b  $03,$93,$BD,$04,$90,$06,$7C,$7C
               dc.b  $BD,$78,$78,$73,$73,$6E,$6E,$00
               dc.b  $04,$4F,$06,$90,$50,$08,$99,$99
               dc.b  $03,$93,$08,$99,$99,$99,$04,$90
               dc.b  $08,$99,$99,$BE,$03,$93,$08,$99
               dc.b  $9B,$BD,$04,$90,$BD,$08,$92,$BE
               dc.b  $03,$93,$BD,$08,$92,$BE,$04,$90
               dc.b  $BD,$08,$8F,$BE,$03,$93,$BD,$08
               dc.b  $91,$BE,$04,$90,$08,$A2,$BD,$9E
               dc.b  $03,$93,$FD,$04,$90,$08,$9D,$FE
               dc.b  $03,$93,$BD,$08,$9D,$9B,$04,$90
               dc.b  $BD,$08,$92,$BE,$03,$93,$BD,$08
               dc.b  $92,$BE,$04,$90,$BD,$08,$8F,$BE
               dc.b  $03,$93,$BD,$08,$91,$03,$93,$00
               dc.b  $03,$46,$F9,$78,$50,$07,$74,$74
               dc.b  $74,$74,$74,$74,$74,$74,$74,$74
               dc.b  $74,$74,$74,$74,$74,$74,$74,$74
               dc.b  $74,$74,$74,$74,$D8,$00,$09,$40
               dc.b  $A2,$BD,$A0,$9E,$BD,$4F,$80,$9B
               dc.b  $43,$00,$9C,$4F,$86,$9B,$40,$99
               dc.b  $9D,$BD,$A0,$BE,$FA,$08,$9B,$BE
               dc.b  $FE,$9B,$BE,$FE,$97,$BE,$FE,$99
               dc.b  $BE,$09,$A2,$BD,$A0,$9E,$BD,$4F
               dc.b  $80,$9B,$43,$00,$9C,$4F,$86,$9B
               dc.b  $40,$99,$9D,$BD,$A0,$BE,$FE,$99
               dc.b  $BE,$A2,$A2,$A2,$A2,$A3,$BD,$A5
               dc.b  $A5,$A2,$BD,$9E,$BE,$A2,$BD,$9E
               dc.b  $BE,$00,$50,$BD,$08,$96,$96,$96
               dc.b  $BD,$96,$96,$99,$BD,$99,$BD,$97
               dc.b  $BD,$96,$BD,$BE,$EF,$92,$92,$92
               dc.b  $92,$BD,$96,$FE,$94,$BD,$94,$96
               dc.b  $BE,$94,$FE,$92,$BD,$BE,$F5,$00
               dc.b  $50,$BD,$08,$96,$96,$96,$96,$96
               dc.b  $BD,$99,$BD,$99,$BE,$FA,$97,$97
               dc.b  $99,$97,$BD,$96,$BE,$F7,$96,$96
               dc.b  $99,$BE,$99,$99,$FE,$94,$BE,$94
               dc.b  $BD,$96,$94,$BE,$92,$FD,$BE,$FB
               dc.b  $8D,$8F,$8D,$FE,$00,$50,$BD,$05
               dc.b  $96,$96,$96,$BD,$96,$96,$99,$BE
               dc.b  $99,$BD,$97,$BD,$96,$BD,$BE,$EE
               dc.b  $96,$9E,$9E,$BE,$9E,$BD,$9D,$BE
               dc.b  $9D,$BE,$9D,$FE,$9B,$FE,$BE,$F4
               dc.b  $00,$50,$BD,$05,$96,$96,$96,$BD
               dc.b  $96,$96,$99,$BD,$99,$BD,$97,$BD
               dc.b  $96,$BD,$BE,$F2,$96,$99,$99,$BD
               dc.b  $96,$BE,$FE,$92,$94,$94,$BE,$94
               dc.b  $FE,$94,$92,$FB,$BE,$F6,$00,$09
               dc.b  $40,$A2,$BD,$A0,$9E,$BD,$4F,$80
               dc.b  $9B,$43,$00,$9C,$4F,$86,$9B,$40
               dc.b  $99,$9D,$BD,$A0,$BE,$FC,$A5,$A5
               dc.b  $A5,$A5,$A7,$BD,$A7,$A7,$A5,$BD
               dc.b  $A2,$BD,$A5,$BD,$A2,$BD,$A2,$BD
               dc.b  $A0,$9E,$BD,$4F,$80,$9B,$43,$00
               dc.b  $9C,$4F,$86,$9B,$40,$99,$9D,$BD
               dc.b  $A0,$BE,$FE,$99,$BE,$A2,$A2,$A2
               dc.b  $A2,$A3,$BD,$A5,$A5,$A2,$BD,$9E
               dc.b  $BE,$A2,$BD,$9E,$BE,$00,$50,$BD
               dc.b  $08,$9E,$BD,$9E,$BD,$9E,$9E,$9E
               dc.b  $BD,$9D,$BD,$9D,$BD,$9E,$BD,$BE
               dc.b  $F5,$05,$46,$AA,$9B,$99,$50,$BD
               dc.b  $BE,$BD,$08,$9E,$BD,$9E,$BD,$9E
               dc.b  $BD,$BE,$FE,$96,$9D,$9E,$BD,$9D
               dc.b  $BE,$9B,$FE,$BE,$F5,$00,$50,$BD
               dc.b  $08,$A2,$BD,$A0,$BD,$A0,$A0,$A0
               dc.b  $A0,$A0,$BD,$A2,$BD,$9E,$FE,$BE
               dc.b  $F2,$9E,$9E,$BD,$9E,$FE,$9B,$BD
               dc.b  $9D,$9E,$BD,$9D,$9D,$9D,$9D,$BE
               dc.b  $FE,$9D,$BD,$9B,$FE,$BE,$FD,$99
               dc.b  $9B,$99,$BD,$BE,$00,$50,$BD,$08
               dc.b  $A2,$BE,$A2,$BE,$A2,$A2,$A5,$BE
               dc.b  $A5,$BE,$A7,$BE,$A2,$FE,$BE,$EE
               dc.b  $A5,$A5,$BE,$A5,$FE,$A0,$BE,$A0
               dc.b  $BE,$A0,$BD,$9E,$FE,$BE,$F4,$00
               dc.b  $50,$BD,$08,$A2,$A2,$A2,$BD,$A2
               dc.b  $A2,$A5,$BE,$A5,$BE,$A5,$BE,$A7
               dc.b  $FD,$BE,$F3,$A5,$A5,$BD,$BE,$A2
               dc.b  $BE,$FE,$A2,$A5,$A5,$BE,$A5,$BE
               dc.b  $A0,$9E,$FD,$BE,$FD,$05,$46,$AA
               dc.b  $9B,$94,$50,$BD,$BE,$FC,$00,$50
               dc.b  $BD,$08,$9B,$9B,$BE,$BD,$9B,$BE
               dc.b  $FE,$99,$99,$BE,$BD,$99,$BE,$FE
               dc.b  $9B,$9B,$BE,$BD,$9B,$BE,$FE,$97
               dc.b  $BE,$FE,$99,$BE,$FE,$9B,$9B,$BE
               dc.b  $BD,$9B,$BE,$FE,$99,$99,$BE,$BD
               dc.b  $09,$99,$BE,$A2,$BE,$A2,$A2,$9E
               dc.b  $BE,$A2,$BE,$A0,$FE,$9E,$9D,$BE
               dc.b  $9B,$BD,$00,$50,$BD,$08,$9B,$9B
               dc.b  $BE,$BD,$9B,$BE,$FE,$99,$99,$BE
               dc.b  $BD,$99,$BE,$FE,$9B,$9B,$BE,$BD
               dc.b  $9B,$BE,$FE,$97,$BE,$FE,$99,$BE
               dc.b  $FE,$9B,$9B,$BE,$BD,$9B,$BE,$FE
               dc.b  $99,$99,$BE,$BD,$99,$BE,$09,$A5
               dc.b  $A5,$A5,$A5,$A2,$BE,$A5,$BE,$A3
               dc.b  $FE,$A2,$A0,$BE,$9E,$BD,$00,$50
               dc.b  $BD,$08,$9E,$BD,$9E,$BE,$BD,$9E
               dc.b  $9E,$9D,$BD,$9D,$BE,$9E,$BD,$BE
               dc.b  $FE,$9B,$BE,$FE,$9B,$BE,$FE,$9E
               dc.b  $BE,$FE,$9D,$BE,$FC,$9D,$BE,$9E
               dc.b  $BD,$BE,$FE,$9E,$9D,$BE,$9D,$BE
               dc.b  $9D,$BE,$9B,$BD,$BE,$FB,$97,$BE
               dc.b  $FE,$99,$BE,$00,$50,$FD,$08,$A2
               dc.b  $BE,$A5,$A5,$A5,$BD,$A3,$A2,$A3
               dc.b  $BD,$A2,$BD,$A3,$BE,$A5,$BD,$BE
               dc.b  $FD,$05,$9E,$FE,$BE,$9D,$FE,$BE
               dc.b  $FC,$08,$9E,$9E,$BE,$9E,$BD,$9D
               dc.b  $BD,$9B,$9D,$BE,$9E,$BD,$9D,$BE
               dc.b  $9B,$BD,$BE,$FA,$09,$A2,$A2,$A2
               dc.b  $A5,$BD,$00,$50,$BD,$08,$A2,$A2
               dc.b  $A2,$BE,$A0,$9E,$A0,$BE,$9E,$BD
               dc.b  $A0,$BE,$A2,$BD,$BE,$BD,$9B,$BE
               dc.b  $FE,$9B,$BE,$FE,$97,$BE,$FE,$99
               dc.b  $BE,$FC,$9D,$9D,$BE,$9E,$FE,$9D
               dc.b  $BE,$9D,$BE,$9D,$FD,$9B,$BE,$FE
               dc.b  $A7,$BE,$FE,$AA,$BE,$FE,$A5,$BE
               dc.b  $00,$50,$BD,$08,$99,$BE,$99,$96
               dc.b  $99,$BE,$99,$96,$99,$BE,$99,$BE
               dc.b  $99,$BE,$96,$BD,$BE,$9B,$BE,$BD
               dc.b  $9B,$BE,$FE,$97,$BE,$FE,$99,$BE
               dc.b  $9E,$9E,$BE,$9E,$BE,$FD,$9D,$9D
               dc.b  $BE,$9D,$BE,$FD,$9D,$9B,$BD,$BE
               dc.b  $03,$93,$09,$A9,$AA,$A9,$FB,$BE
               dc.b  $FE,$00,$50,$BD,$08,$96,$96,$96
               dc.b  $BE,$96,$96,$99,$BE,$99,$BE,$99
               dc.b  $BE,$96,$BD,$BE,$BD,$05,$46,$AA
               dc.b  $9B,$40,$BE,$FE,$46,$AA,$9B,$40
               dc.b  $BE,$FE,$46,$AA,$97,$40,$BE,$FE
               dc.b  $46,$AA,$99,$40,$BE,$FC,$08,$99
               dc.b  $99,$BE,$99,$FE,$94,$BE,$94,$BE
               dc.b  $94,$BD,$92,$FD,$BE,$F5,$00,$50
               dc.b  $BD,$09,$9E,$9E,$9E,$A2,$9E,$9E
               dc.b  $9D,$A2,$9D,$A2,$9D,$A2,$08,$9E
               dc.b  $BD,$BE,$BD,$9B,$BE,$FE,$9B,$BE
               dc.b  $FE,$97,$BE,$FE,$99,$BE,$A5,$A5
               dc.b  $BD,$A2,$BE,$FD,$A5,$A5,$BD,$A0
               dc.b  $BE,$BD,$A0,$9E,$FE,$05,$46,$AA
               dc.b  $9B,$40,$BE,$FE,$46,$AA,$9B,$40
               dc.b  $BE,$FE,$46,$AA,$97,$40,$BE,$FE
               dc.b  $46,$AA,$99,$40,$BE,$00,$04,$40
               dc.b  $78,$BD,$08,$A2,$A2,$A2,$A2,$A3
               dc.b  $BE,$A3,$A3,$A2,$BE,$9E,$BE,$A2
               dc.b  $BE,$9E,$BE,$D2,$00
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

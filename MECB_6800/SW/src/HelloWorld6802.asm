******************************************************************************
*	HelloWorld6802.asm
*
*	A simple 'Hello World' character output test.
*	For 6800 / 6802 / 6808 based system.
*	For ROM target (See Vector Table).
*	eg. $F000 - $FFFF
*
*   	For as0 Assembler.
*
*	Author: Greg
*	Date:	02/2026
*
******************************************************************************
*       OPT     l           ; Enable Listing Assembler Output
ACIA    EQU     $8008       ; MC6850 ACIA Address
ACIAtr  EQU     ACIA+1      ; ACIA Transmit / Receive Data Register
*
        ORG     $F000       ; Entry point
* Initialise 6802
Start   SEI                 ; Disable Interrupts
        LDS     #$01FF      ; Initialise Stack pointer ($01FF)
* Initialise ACIA
        LDAA    #$03        ; Reset ACIA
        STAA    ACIA
        LDAA    #$51        ; Set ACIA Control
        STAA    ACIA        ; 8 bits,2 stop bits,/16 clock,Interrupt disabled
;
        LDX     #$0100
        LDAA    #$55
        STAA    0,X
        LDAA    0,X
        CMPA    #$55
        BNE     byebye
        LDX     #$7F00
        LDAA    #$AA
        STAA    0,X
        LDAA    0,X
        CMPA    #$AA
        BEQ     hello
      
byebye  LDX      #Bye
        JMP      PrintLp
* Output Hello string
hello   LDX     #Hello      ; Initialise character offset pointer
PrintLp LDAA    #$02        ; Transmit Data Register Empty flag mask
        BITA    ACIA        ; Is Transmit Data Register Empty?
        BEQ     PrintLp     ; Loop if not empty
*
        LDAA    0,X         ; Get next character to send
        BEQ     Done        ; If it's the zero string terminator, we're done!
        STAA    ACIAtr      ; Send the character
        INX                 ; Increment character offset pointer
        JMP     PrintLp     ; Loop to process next character
*
Done    JMP     Done        ; Done, so just Loop Forever!
* Return from Interrupt - default Interrupt vector
VectRtn RTI                 ; Just return from an Interrupt
* Zero Terminated string to output
Hello   dc.b     "Hello 6802 World!"
        dc.b     $0D,$0A,$00
* Zero Terminated string to output
Bye     dc.b     "Couldn't validate memory!"
        dc.b     $0D,$0A,$00
*
* Vector Table for 6802 located at $FFF8 - $FFFF
    	ORG	$FFF8
	dc.w	VectRtn     ; IRQ Vector
	dc.w	VectRtn     ; Software Interupt Vector
	dc.w	VectRtn     ; NMI Vector
	dc.w	Start       ; Reset Vector
*
        END
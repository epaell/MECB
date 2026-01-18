/*
	MC6800 cock/reset generator
	Device: PIC12F1822
	Compiler: XC8
*/

#include <xc.h>

#pragma config FOSC = INTOSC
#pragma config WDTE = OFF
#pragma config MCLRE = ON
#pragma config CLKOUTEN = OFF
#pragma config PLLEN = ON

#define _XTAL_FREQ 32000000
/*
  P2 = RA5 = RESET*
  P3 = RA4 = CLK2 
  P5 = RA2 = CLK1
  P7 = RA0 = external reset
*/
void main() {
	// initialize
	OSCCON = 0b11110000;
	ANSELA = 0;
	nWPUEN = 0;
	TRISA  = 0b00001011;
	P1BSEL = 1;

	// clock generate
	CCP1CON = 0b10001100;
	PR2 = 7;
	CCPR1L = 4;
	PWM1CON = 1;
	T2CON = 0;
	TMR2ON = 1;

	// reset
	LATA5 = 0;
	__delay_ms(200);
	LATA5 = 1;

	// manual reset
	while(1)
		LATA5 = RA0;
}
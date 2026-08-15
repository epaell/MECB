
ver()
{
puts("* Program: GETCH.CMD  v1.0        CP/M-86 (IBM-PC)");
puts("* Author : Ken Mauro                              ");
puts("* Date...: Aug 1, 1998                            ");
puts("* Purpose: DRC getch() and sysinfo                ");
}

#include <dos.h>
#include <stdio.h>
#include <conio.h>

#define ON	0
#define OFF	1

/*#define IBMPC	0*/

#if CPM86
extern	int keyb();
extern	int inp();
extern	char peek();
extern	int int86();
#endif


main()
{
	int i,c=0;

#if IBMPC
	static char fn[]={ 27,58,';','D','I','R','S',13,0,0 };
#else
	static char fn[]={ 27,58,';',';',0,0 };
#endif


	color(7,0);
	clrscr();
	ver();
	i=-1;
	while(fn[++i]!=0){ 
		putchar((fn[i]));
		}
	putchar(0);


	version();
	output(c);


	while(c!=27){
		if(kbhit()){
			c=getkey();
			output(c);
			}
		}

}


getkey()
{
        int c;

        c = getch();
	if(!(c & 0xff)) c = getch() << 8 ;
        return(c) ;
}


output(c)
int c;
{
	int flags;



	if(IBMPC)  myputs(7,30,"Compiled with enhanced keyb handling: ON  ");
	if(!IBMPC) myputs(7,30,"Compiled with enhanced keyb handling: OFF ");

	gotoxy(7,0);
	flags=peek(0,0x417);


	printf("ASCII CHR$:");
	if(c<32) printf("(%u)  \n", c);
	else     printf(" %c   \n", c);

	printf("      DEC : %u    \n", c);
	printf("      HEX : %04x  \n", c);
	printf("     FLAG : %04x  \n", flags);


	gotoxy(21,0);
	printf("Press a key to see it's value or ESC to end..");

}

version()
{

	int i, ret,x,y;

	ret = bdos(12);

	gotoxy(12,0);
	printf("DRC env$  : ");
	myputs(12,12,"OS_version: %04xh   \n", _OS_VERSION );
	myputs(13,12,"OS_ability: %b    \n\n",  _OS_ABILITY );
	printf("Bdos #12  : %04xh    \n", ret );
	printf("System(s) : ");

	x=16,y=12;
							/* source of info */

	if(ret==0x20) myputs(x,y  ,"CP/M 2.0            "); /* jce */
	if(ret==0x21) myputs(x,y  ,"CP/M 2.1            "); /* jce */
	if(ret==0x22) myputs(x,y  ,"CP/M-86 1.1         "); /* verified */
	if(ret==0x23) myputs(x,y  ,"MP/M-86             "); /* DRC startup.a86*/
	if(ret==0x24) myputs(x,y  ,"CCP/M-86            "); /* DRC startup.a86*/
	if(ret==0x25) myputs(x,y  ,"DOS+ (CP/M)         "); /* jce */
	if(ret==0x28) myputs(x,y  ,"Personal CP/M       "); /* jce */
	if(ret==0x30) myputs(x,y  ,"CCP/M-86 3.0        "); /* Lopushinki's */
	if(ret==0x31) myputs(x,y  ,"CCP/M-86 3.1        "); /* CPM emulator */
	if(ret==0x41) myputs(x,y  ,"DOS Plus 1.2        "); /* verified -km */
	if(ret==0x41) myputs(x+1,y,"Personal CP/M-86 2.0"); /* verified -km */
	if(ret==0x41) myputs(x+2,y,"Concurrent PCDOS 4.1"); /* verified -km */
	if(ret==0x50) myputs(x+2,y,"Concurrent PCDOS XM "); /* assumed -km */
	if(ret==0x60) myputs(x,y  ,"DOS Plus 2.0        "); /* jce */
	if(ret==0x61) myputs(x,y  ,"Concurrent DOS 6.1  "); /* assumed -km */
	if(ret==0x62) myputs(x,y  ,"Concurrent DOS 6.2  "); /* assumed -km */

}


myputs(x,y,format,p)
int x,y;
char *format,*p;
{
	gotoxy(x,y);
	printf(format,p);
}


/* from JCE's website 

BDOS function 12 - Return version number
Supported by: Versions 2.0 and later
Entered with C=0Ch. Returns B=H=system type, A=L=version number.

The system type is subdivided into a machine type and a CP/M type. 
The machine type occupies the high nibble of the byte; the CP/M type
occupies the low nibble.

Machine types:   CP/M types:         Version numbers:
0 - 8080         0 - CP/M                  00h - Version 1 (see above)
1 - 8086         1 - MP/M                  20h - Version 2.0
                 2 - CP/Net                21h - Version 2.1
                                           22h - Version 2.2
                                           25h - Version 2.5 (DOS +)
					   28h - Version 2.8 (Personal CP/M)
                                           30h - Version 3.0
                                           31h - Version 3.1
	                   		   41h - Version 4.1 (DOS Plus 1)
                                           60h - Version 6.0 (DOS Plus 2)

*/


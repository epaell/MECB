
ver(n) int n;{
	puts("ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿");
if(!n){	puts("³Program: IMG63T.CMD v1.1     CP/M-86 (IBM-PC) ³");
	puts("³Author : Ken Mauro                            ³");
	puts("³Date...: Aug 12, 1999                         ³");
	puts("³Purpose: GEM IMG (b/w) viewer                 ³");
	puts("³Note...: handles images <65k (unpacked).      ³");
	puts("³                                              ³");
	puts("³(C)1999 Ken Mauro, all rights reserved.       ³");
	puts("³            free for non-commercial use.      ³");
}if(n){	puts("³Usage..: filename d                           ³");
	puts("³Option : d = diagnostic info.                 ³");
	puts("³         i = inverted display.                ³");
	puts("³Control: Enter or Esc to exit.                ³");
	puts("³Panning: Csr, Home, PgUP, PgDn & End keys     ³");
	puts("³         Shift-5 = jump to image center.      ³");
}	puts("ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ");
}


#include <dos.h>
#include <stdio.h>
#include <conio.h>

#if CPM86
extern unsigned int86();
#endif


char arg[16];
char header[16];
char linebuf[256];  /* orig. 2048 bytes, may need for color images.*/

unsigned int voff, vseg=0xa000;
unsigned int ScreenDeep=350;
unsigned int width,depth,seg,off,mode=16;
unsigned int bytes,repcount,patternsize=1;
unsigned int pixels2bytes();

FILE *fp;


main(argc,argv)
	int argc;
	char *argv[];
{

	ver(0);

	if(argc > 1) {
		strmfe(linebuf,argv[1],"img");

#if CPM86
	if( (fp=fopenb(linebuf,"r")) != NULL ) {
#else
	if( (fp=fopen(linebuf,"rb")) != NULL ) {
#endif

		if(fread(header,1,16,fp)==16) {
		        patternsize = (header[7]&0xff)+((header[6]&0xff)<<8);
			width = (header[13] & 0xff)+((header[12] & 0xff)<<8);
			depth = (header[15] & 0xff)+((header[14] & 0xff)<<8);
			bytes = pixels2bytes(width);
			if(UnpackImgFile()==bytes);
			} else printf("Decoding error.\n");

		} else printf("Error reading %s.\n",argv[1]);
		fclose(fp);
	} else printf("Invalid filename: %s.\n",argv[1]);
}



UnpackImgFile()				/* Unpack image directly to screen. */
{
	char *ptr1, *ptr2;
	unsigned int n,deep;
	register int i,j;


	seg=FP_SEG(linebuf);
	off=FP_OFF(linebuf);
	ptr1=MK_FP(seg,off);

	init();

	deep=depth;
        if(depth>ScreenDeep) deep=ScreenDeep;

	/*for(i=0;i<deep;) {*/
	i=0;
	while(deep--){
		if((n=ReadImgLine(linebuf,fp)) != bytes) break;
		while(repcount--) {

			/*voff=( 0x2000*(i%4))+(80*(i/4) );*/
			voff=(i*80);
			ptr2=MK_FP(vseg,voff);
			memcpy(ptr2,ptr1,bytes);

			/*
			ptr1=MK_FP(seg,off);
			n=bytes;
			while(n--){
				*ptr2++ = ~*ptr1++;
				}
			*/
			++i;


		}
	 }
	getchar();		/* getch() handles ESC properly */
	deinit();
        return(n);
}

ReadImgLine(p)	/* read and decode a gem img line into p */
	char *p;
{
	char *pr;
	unsigned int c,i,j,n;

	n=0;
	repcount=1;
							/*memset(p,0,bytes); */
	do{
		c=fgetc(fp) & 0xff;
		if(c==0){					
		c=fgetc(fp) & 0xff;
		if(c==0) repcount=fgetc(fp) & 0xff;
       		else{
			i=c & 0xff;
			pr=p+n;
			j=patternsize;
			while(j--) p[n++]= fgetc(fp);
			i--;				     /*k=i-1;*/
			while(i--){
				memcpy(p+n,pr,patternsize);
				n+=patternsize;
				}
			}
		}
		else if(c==0x80){
			i=fgetc(fp) & 0xff;
			pr=p+n;					/*j=i;*/
			while(i--) p[n++]= fgetc(fp);
			}

		else if(c & 0x80){
			i = c & 0x7f;
			pr=p+n;					/*j=i;*/
			while (i--) p[n++]= 0xff;
			}
		else {
			i= c & 0x7f;
			pr=p+n;					/*j=i;*/
			while(i--) p[n++]= 0x00;
               	        }

		} while(n < bytes);

		i=n;
		while(i--) linebuf[i] = ~linebuf[i];	

	return(n);
}

init()
{
	union REGS r;

	r.x.ax=0x0010;
	int86(0x10,&r,&r);
}

deinit()
{
	union REGS r;

	r.x.ax=0x0003;
	int86(0x10,&r,&r);
}

unsigned int pixels2bytes(n)
unsigned int n;
{
	if(n & 0x0007) return((n >> 3) + 1);
	else return(n >> 3);
}

strmfe(new,old,ext)
char *new,*old,*ext;
{
	while(*old != 0 && *old != '.') *new++=*old++;
	*new++='.';
	while(*ext) *new++=*ext++;
	*new=0;
}



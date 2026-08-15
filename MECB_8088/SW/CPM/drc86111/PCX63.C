
ver(n) int n;{
	puts("ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿");
if(!n){	puts("³Program: PCX63.CMD v1.1      CP/M-86 (IBM-PC) ³");
	puts("³Author : Ken Mauro                            ³");
	puts("³Date...: July 4, 1998                         ³");
	puts("³Purpose: PCX (b/w) viewer w/panning.          ³");
	puts("³Note...: handles images <65k (unpacked).      ³");
	puts("³                                              ³");
	puts("³(C)1999 Ken Mauro, all rights reserved.       ³");
	puts("³        free for non-commercial use.          ³");
}if(n){	puts("³Usage..: filename d                           ³");
	puts("³Option : d = diagnostic info.                 ³");
	puts("³         i = inverted display.                ³");
	puts("³Control: Enter or Esc to exit.                ³");
	puts("³Panning: Csr, Home, PgUP, PgDn & End keys     ³");
	puts("³         Shift-5 = jump to image center.      ³");
}	puts("ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ");
}

/* date   : Apr 20, 1991 (msdos)  */
/* update : July 4, 1998 (cpm86)  */
/* Compile: Large model only      */

#include <dos.h>
#include <stdio.h>
#include <conio.h>
#include <alloc.h>

#if CPM86
extern unsigned int86();
extern int outp();
#endif

#define ON	0
#define OFF	1

#define HOME            0x4700
#define PGUP            0x4900
#define CSR_UP		0x4800
#define CSR_LEFT	0x4b00
#define CENTER          0x0035
#define CSR_RIGHT	0x4d00
#define CSR_DN		0x5000
#define PGDN            0x5100
#define END             0x4f00
#define PLUS            0x002b
#define MINUS           0x002d
#define PRTSC           0x002a

#define step	16


#define CGA	0
#define EGA	1
#define VGA	0
#define ATT	0
#define HERC	0

#if CGA
unsigned vseg  = 0xb800;
unsigned gmode = 0x0006;
unsigned tmode = 0x0003;
unsigned ScrnWide = 640;
#define	MAXLINES    200
#endif

#if EGA
unsigned vseg  = 0xa000;
unsigned gmode = 0x0010;
unsigned tmode = 0x0003;
unsigned ScrnWide = 640;
#define	MAXLINES    350
#endif

#if VGA
unsigned vseg  = 0xa000;
unsigned gmode = 0x0012;
unsigned tmode = 0x0003;
unsigned ScrnWide = 640;
#define	MAXLINES    480
#endif

#if HERC
unsigned vseg  = 0xb000;
unsigned gmode = 0x0000;
unsigned tmode = 0x0007;
unsigned ScrnWide = 720;
#define	MAXLINES    350			/* maybe 348 for a real herc card  */
#endif

#if ATT
unsigned vseg  = 0xb800;
unsigned gmode = 0x0040;
unsigned tmode = 0x0003;
unsigned ScrnWide = 640;
#define	MAXLINES    400
#endif


long int patchstr = 0x6778797a;		/* DRI's "zyxg" patch area finder */
unsigned int echo = 1;			/* 0 = no echo messages */
unsigned int diag = 0;			/* 0 = no diag messages */
unsigned ScrnDeep=MAXLINES;
char *lptr[MAXLINES];			/* can also be long int *lptr */	
unsigned int width,depth;
unsigned int bytes,bpl,w;
unsigned int BxP;			/* bytes per plane */

typedef struct	{
	char	manufacturer,version;
	char	encoding,bits_per_pixel;
	int	xmin,ymin,xmax,ymax;
	int	hres,vres;
	char	palette[48];
	char	reserved;
	char	color_planes;
	int	bytes_per_line;
	int	palette_type;
	char	filler[58];
		} PCXHEAD;
PCXHEAD header;

char *ps, arg[16];				/* holds cmdline switches */
unsigned pixels2bytes();
FILE *fp;

main(argc,argv)
	int argc;
	char *argv[];
{
	int i,ret;
	unsigned int size;
	char *p, linebuf[256];


	cursor(OFF);
	cls();

	if(echo) ver(0);
	if(argc > 1) {
		strmfe(linebuf,argv[1],"pcx");
#if CPM86 
	if( (fp=fopenb(linebuf,"r")) != NULL ) {
#else
	if( (fp=fopen(linebuf,"rb")) != NULL ) {
#endif
		arg[2] = *argv[2];
		if(arg[2]==100) diag=1;

	if(fread((char *)&header,1,sizeof(PCXHEAD),fp)==sizeof(PCXHEAD)){
	if(header.manufacturer==0x0a) {
		width = (header.xmax-header.xmin)+1;
		depth = (header.ymax-header.ymin)+1;
		bytes = header.bytes_per_line;
		  BxP = (bytes*header.color_planes);
		 size = bytes*depth*header.color_planes;

		if(width > ScrnWide) w=pixels2bytes(ScrnWide);
		else w=bytes;
		w=w-1;

		if(diag){ 
			printf("command line  : %s \n",linebuf);
			printf("image size    : %ux%u pixels.\n\n",width,depth);
			printf("unpacked size : %u bytes.\n",size);
			}

		if(size < 65400) {
			if((p=farmalloc(size+128)) != NULL){
				if(diag) diags(p,size);

				if(UnpackPcxFile(p)==bytes) 
					i=100; while(i--);	/* fget delay */

					PanPcxPicture(p);
					farfree(p);

			    	} else printf("can't allocate memory.\n");
			    } else printf("unpacked image > 65k limit.\n");
			} else printf("not a standard pcx file.\n");
		    } else printf("not a pcx file, or header damaged.\n");
		fclose(fp);
	    } else printf("file not found: %s.\n",linebuf);
	} else {
		ver(1);
		}

cursor(ON); 

}


diags(p,size)
char *p; 
unsigned size;
{

printf("mcb allocated : %u bytes. \n", mcb.len*16);
printf("start address : %lx     \n\n", p );

printf("screen mode   : %ux%u     \n", ScrnWide, ScrnDeep);
printf("screen address: %x0000\n\n\n", vseg);
printf("Press enter to continue..");
getkey();
}


PanPcxPicture(p)
        char *p;
{
	char *s;
        int c,x,y;
	register i,j;


	if(depth>ScrnDeep) j=ScrnDeep;
	else j=depth;
	x=0; y=0;

        init();

        do {
		s = p+(y*bytes)+(x>>3);
		for(i=0;i<j;++i) memcpy(lptr[i], s+(i*BxP), w );

		switch(c=getkey()) {

	        case CSR_LEFT:
			if((x-step)  >  0)  x-=step;
			else x=0;
			break;
        	case CSR_RIGHT:
			if((x+step+ScrnWide) < width) x+=step;
			else if(width > ScrnWide) x=width-ScrnWide;
			else x=0;
			break;
	        case CSR_UP:
			if((y-step) > 0) y-=step;
			else y=0;
			break;
	        case CSR_DN:
			if((y+step+ScrnDeep) < depth) y+=step;
			else if(depth > ScrnDeep) y=depth-ScrnDeep;
			else y=0;
			break;
	        case CENTER:
			if(width > ScrnWide) x=(width/2)-(ScrnWide/2);
			else x=0;
			if(depth > ScrnDeep) y=(depth/2)-(ScrnDeep/2);
			else y=0;
			break;
	        case HOME:
			x=y=0;
			break;
	        case PGUP:
			if(width > ScrnWide) x=width-ScrnWide;
			else x=0;
			y=0;
			break;
	        case END:
			if(depth > ScrnDeep) y=depth-ScrnDeep;
			else y=0;
			x=0;
			break;
	        case PGDN:
			if(width > ScrnWide) x=width-ScrnWide;
			else x=0;
			if(depth > ScrnDeep) y=depth-ScrnDeep;
			else y=0;
			break;
	                }
        	} while(c != 13 && c !=27);
    deinit();
}


UnpackPcxFile(p)	  /* open and print PCX image. */
	char *p;
{
	int i,j,k,n;

	for(i=0;i<depth;++i) {
		n=ReadPcxLine(p);
		p+=bytes;
		}

return(n);
}


ReadPcxLine(p)   		/* read and decode a PCX line into p */
	char *p;
{
	int c,n,i;

	n=0;
	do {
		c = fgetc(fp) & 0xff;
		if( (c & 0xc0) == 0xc0 ) {
			i=(c & 0x3f);			/* get the run byte */
			c=fgetc(fp);			/* run out the byte */
			while(i--)
			if(arg[2]==0x69) p[n++]=~c;
				    else p[n++]=c;
		} else
			if(arg[2]==0x69) p[n++]=~c;
				    else p[n++]=c;

	} while(n < bytes);

return(n);
}


init()
{
        union REGS r;

	LineCalc();				/* calc line starts */

#if CPM86
	statline(OFF);				/* prints on non cpm ansi's */
#endif

#if HERC
	doherc(gmode);
#else
	r.x.ax=gmode;
	int86(0x10,&r,&r);
#endif
}


deinit()
{
        union REGS r;

#if CPM86
	statline(ON);
#endif
#if HERC
	doherc(tmode);
#endif

	r.x.ax=tmode;
        int86(0x10,&r,&r);

cls();

}


LineCalc()		/* raster line start addresses for any card type */
{
        unsigned i;

        bpl=(ScrnWide/8);
        for(i=0;i<ScrnDeep;i++){

#if CGA
	lptr[i]=MK_FP(vseg,((0x2000*(i%2))+(bpl*(i/2))));
#endif
#if ATT||HERC
	lptr[i]=MK_FP(vseg,((0x2000*(i%4))+(bpl*(i/4))));
#endif
#if EGA||VGA
	lptr[i]=MK_FP(vseg,i*80);
#endif

	}
}

#if HERC		/*--------------------------------------------------*/
doherc(hercmode)
int hercmode;
{
	int i;
	static char g_table[12] = { 0x35,0x2d,0x2e,0x07,0x5b,0x02,
        	                    0x57,0x57,0x02,0x03,0x00,0x00 };
	static char t_table[12] = { 0x61,0x50,0x52,0x0f,0x19,0x06,
	                            0x19,0x19,0x02,0x0d,0x0b,0x0c };

	gcls();
	if(hercmode==0){	
		outp(0x3bf,1); outp(0x3b8,2);
		for(i=0;i<12;++i) {
			outp(0x3b4,i);
			outp(0x3b5,g_table[i]);
			}
	        outp(0x3b8,2+8);
		}

	if(hercmode==7){	
	        outp(0x3bf,0); outp(0x3b8,2);
        	for(i=0;i<12;++i) {
			outp(0x3b4,i);
			outp(0x3b5,t_table[i]);
	                }
	        outp(0x3b8,32+8);
		}	

}
#endif			/*---------------------------------------------------*/


gcls()					/* only really needed for herc */
{	
	memset( MK_FP(vseg,0), 0, 32512); 
	/*memset( MK_FP(vseg,0), 0, bpl*MAXLINES);*/
}					      

cls()
{	
	clrscr(); 
}


getkey()
{
	int c;
	c = getch();
	if(!(c & 0xff)) c = getch()<<8;		/* if second char, get it */

	return(c) ;
}


unsigned pixels2bytes(n)
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
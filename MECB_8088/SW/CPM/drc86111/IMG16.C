ver()
{
printf("* Program: IMG16.C  v1.11				\n");
printf("* Author : Ken Mauro                     		\n");
printf("* Date...: May 1,1994  msdos (turbo c)     	  	\n");
printf("* UpDate : May 1,1999  cpm86 (drc 1.11)        		\n");
printf("* Purpose: GEM bitmap image display          		\n");
printf("* Display: EGA/VGA 640x350x16c      		       	\n");
printf("* Notes..: Use: filename.img				\n");
printf("* .......: Press ENTER to exit program.                 \n");
}

#include <dos.h>
#include <stdio.h>


#if CPM86
#include <conio.h>
extern int outp();
extern unsigned	int86();
#else
#define UBYTE	unsigned char
#endif

#define ON	0
#define OFF	1


#define pixels2bytes(n) ((n+7)/8)

char header[18];                       /* Graphics file header */

unsigned int vseg=0xA000,voff=80;
unsigned int scrndeep=350;
unsigned int width,depth,bits;
unsigned int bytes,psize=1;


/* GEM fixed palette */
char fixedpalette[48]={ 0x00,0x00,0x00,	0x00,0xaa,0xaa, 0xaa,0x00,0xaa,
			0x00,0x00,0xaa,	0xaa,0xaa,0x00, 0x00,0xaa,0x00,
			0xaa,0x00,0x00,	0x55,0x55,0x55, 
			0xaa,0xaa,0xaa,	0x00,0xff,0xff, 0xff,0x00,0xff, 
			0x55,0x55,0xff,	0xff,0xff,0x00,	0x00,0xff,0x00, 
			0xff,0x00,0x00,	0xff,0xff,0xff  };


main(argc,argv)
        int argc;
        char *argv[];
{
        FILE *fp;
	char *p, linebuf[64];


	cursor(OFF);
	clrscr();

	if(argc > 1) strmfe(linebuf,argv[1],"img");
	else error("File not found.");

#if CPM86
	if( (fp=fopenb(linebuf,"r")) == NULL ) error("error open file");
#else
	if( (fp=fopen(linebuf,"rb")) == NULL ) error("error open file");
#endif

	if(fread(header,1,16,fp) !=16) error("bad file header");
		bits = (header[5] & 0xff)+((header[4] & 0xff)<<8);
		psize = (header[7]&0xff)+((header[6]&0xff)<<8);
		width = (header[13] & 0xff)+((header[12] & 0xff)<<8);
		depth = (header[15] & 0xff)+((header[14] & 0xff)<<8);
		bytes = pixels2bytes((width));

		UnpackFile(fp);
		fclose(fp);

cursor(ON);

}


UnpackFile(fp)    /* unpack the image directly to video memory */
        FILE *fp;
{
	char *s,pal[50];          /* set the palette */
	register int i,j;



        init();

	if(bits>1){
		rgb2ega(pal,fixedpalette,1<<bits);
		setpalette(pal,1<<bits);
		}

        outp(0x3c4,0x02);
	s=MK_FP(vseg,0);

	if(depth>scrndeep) j=scrndeep;
	else j=depth;

	for(i=0;i<j;++i) {
		if (bits>1){				/* color img > 1 bit */
			outp(0x3c5,1);
			ReadLine(fp,s);		
			outp(0x3c5,2);
			ReadLine(fp,s);		
			outp(0x3c5,4);
			ReadLine(fp,s);		
			outp(0x3c5,8);
			}
		ReadLine(fp,s);
		s+=voff;
		}
        outp(0x3c5,0x0f);
        getchar();
        deinit();

}

ReadLine(fp,s)			/* read and decode an imgage line into p  */
FILE *fp; 
char *s;
{
	int c,j,n=0,reps=1;
	register int i;
	static char *pr, p[128];

	    do {
		c=fgetc(fp) & 0xff;
		if(c==0) {
		c=fgetc(fp) & 0xff;
		if(c==0) {
                        fgetc(fp) ;
			reps=fgetc(fp) & 0xff;
			}
		else {
			i=c & 0xff;
			pr=p+n;
			j=psize;
			while(j--) p[n++] = fgetc(fp);

			i--;
			while(i--) {
			memcpy(p+n,pr,psize);
			n+=psize;
			}
		    }
		}
                 else if(c==0x80) {
			i = fgetc(fp) & 0xff;
                        pr=p+n;
			while(i--) p[n++] = fgetc(fp);
			}
		 else if(c & 0x80) {
                        i = c & 0x7f;
                        pr=p+n;
			while(i--) p[n++] = 0xff;
			}
		  else{
                        i = c & 0x7f;
                        pr=p+n;
			while(i--) p[n++] = 0x00;
			}

	} while(n < bytes);

	i=n;
	while(i--) p[i] = ~p[i];			/* invert line */
	memcpy(s,p,bytes);

    return(n);
}

error(s)
    char *s;

{
    puts(s);
        puts("Press any key to return to DOS");
	cursor(ON);
        getchar();
        exit(1);

}

init()
{
	union REGS r;

#if CPM86
statline(OFF);
#endif

	r.x.ax=0x0010;
	int86(0x10,&r,&r);
}

deinit()
{
	union REGS r;

#if CPM86
statline(ON);
#endif

	r.x.ax=0x0003;
	int86(0x10,&r,&r);
}

strmfe(new,old,ext)
	char *new,*old,*ext;
{
	while(*old != 0 && *old != '.') *new++=*old++;
	*new++='.';
	while(*ext) *new++=*ext++;
	*new=0;
}


rgb2ega(dest,src,n)
char *dest,*src;
int n;
{
	int i;

	for(i=0;i<n;++i) {
		*dest=0;
		pbits(dest,src++,0x20,0x04);
		pbits(dest,src++,0x10,0x02);
		pbits(dest,src++,0x08,0x01);
		++dest;
		}

}

pbits(dest,src,l,h)
UBYTE *dest,*src;
int l,h;
{
	if(*src>0x33){
	    *dest |= l;
	    if(*src>0x77){
		*dest &=~l;
		*dest |= h;
		if(*src > 0xbb) *dest |= l+h;
		}
	}
}

setpalette(pal,n)
char *pal;
int n;
{
	union REGS r;
	int i;

	for(i=0;i<n;i++){				/* n = # of colors */
		r.h.bl = i;
		r.h.bh = pal[i];
		r.x.ax = 0x1000;
		int86(0x10,&r,&r);
	}
}

 /* b=0; will force background to black */

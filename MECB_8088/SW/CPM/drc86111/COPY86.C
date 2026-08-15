
ver(n) int n;{
	puts("ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿");
if(!n){	puts("³Program: COPY86.CMD v1.0     CP/M-86 (IBM-PC) ³");
	puts("³Author : Ken Mauro                            ³");
	puts("³Date...: Sept 1, 1998                         ³");
	puts("³Purpose: Dos/Unix style copy                  ³");
	puts("³                                              ³");
	puts("³(C)1998 Ken Mauro, all rights reserved.       ³");
	puts("³        free for non-commercial use.          ³");
}if(n){ puts("³Usage..: copy UD:src UD:dest                  ³");
	puts("³example: see copy86.doc                       ³");
	puts("³                                              ³");
	puts("³Notes..: Press CTRL-C to abort.               ³");
	puts("³         File attributes are ignored.         ³");
	puts("³         Partial destination is required.     ³");
	puts("³                                              ³");
	puts("³Warning:*DO NOT* interrupt by using the       ³");
	puts("³         ctrl-break/scrl-lock key combo.      ³");
	puts("³         Like PIP.CMD, the destination        ³");
	puts("³         disk directory may be damaged.       ³");
}	puts("ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ");
}

#include <stdio.h>

#define ON	0
#define OFF	1
#define BUFSIZE	2048

long int patchstr = 0x6778797a;		/* DRI's "zyxg" patch area finder */
int echo = 1;				/* 0 = no echo messages */
int diag = 0;				/* 0 = no diag messages */

char arg[64];						/* holds cmdline */
FILE *fp;

main(argc,argv)
	int argc;
	char *argv[];
{
	int c,i,j,n,t,f1,f2;
	long int tbytes;
	char u[8],d[8];
	int d1,d2,u1,u2;
	int next,last,usr,drv;
	int len,len1,len2,len3,ret;
	static char space[]={"                 "};	/* must be 17 spaces */	
	char buf[BUFSIZE+1];
	char du1[8],du2[8];
	char tmp[20],src[20],dest[20];
	

    if(argc >1 ){
    if(argc >2 ){

	puts(" ");

	next = 1;
	last  = argc-1;

	usr = __BDOS(32,255); 
	drv = __BDOS(0x19); 
	drv+=97;
	sprintf(u,"%u",usr);
	sprintf(d,"%c",drv);


	strcpy(tmp,argv[1]);	
	len = instr(tmp,':');
	if(len > 0){
		tmp[len]=0; c=tmp[len-1];
		if( c <= '9') sprintf( du1,"%s%s%c%c",tmp,d,':', 0 );
		if(c>='a' && len>1 ) sprintf( du1,"%s%c%c",tmp,':', 0 );
		if(c>='a' && len==1 ) sprintf( du1,"%s%s%c%c",u,tmp,':', 0 );
		}
	else sprintf( du1,"%s%s%c%c",u,d,':',0);
	len1=strlen(du1);


	strcpy(tmp,argv[last]);	
	len = instr(tmp,':');
	if(len > 0){ 
		tmp[len]=0; c=tmp[len-1];
		if( c <= '9') sprintf( du2,"%s%s%c%c",tmp,d,':', 0 );
		if(c>='a' && len>1 ) sprintf( du2,"%s%c%c",tmp,':', 0 );
		if(c>='a' && len==1 ) sprintf( du2,"%s%s%c%c",u,tmp,':', 0 );
		}
	else sprintf( du2,"%s%s%c%c",u,d,':',0);
	len2=strlen(du2);

	len = len1;

	
	ret=instr(argv[1],':'); 
	if(ret > 0) len1=ret+1;
	else len1=0;

	ret=instr(argv[2],':'); 
	if(ret > 0) len2=ret+1;
	else len2=0;

	if(diag){
		printf("Default usr: %s   \n", u);
		printf("Default drv: %s \n\n", d);

		printf("SRC  u:drv : %s \n",du1);
		printf("DEST u:drv : %s \n",du2);
		printf("argv[1]    : %s \n",argv[1]);
		printf("argv[last] : %s \n",argv[last]);
		printf("argv[l+1]  : %c \n",argv[last][len2]);
		printf("#args      : %u \n", last);

		printf("\nPress any key to continue.. \n");
		getchar();
		}

/*===========================================================================*/

while(next++ < last ){

	strcpy(src,du1);	
	strcpy(tmp,argv[next-1]);
	strcat(src,&tmp[len1]);
	if(argc>3){
		strcpy(dest,du2);	
		strcpy(tmp,argv[next-1]);
		strcat(dest,&tmp[len2]);	
		}
	else{	
		strcpy(dest,du2);	
		if(argv[2][len2]==0){
			strcpy(tmp,argv[1]);
			strcat(dest,&tmp[len1]);
			}
		else{
			strcpy(tmp,argv[2]);
			strcat(dest,&tmp[len2]);
			}
		}

		len=strlen(src);

		printf("%s%s%s\n",src, &space[len], dest);
		if( strcmp(src,dest) == 0 ){ 
			error("Source and destination are the same.");
			}	

		tbytes=0;

		if((f1=openb (src ,0))== -1) error("Invalid Source.");
		if((f2=creatb(dest,1))== -1) error("Invalid Destination.");
		while( (n=read(f1,buf,BUFSIZE)) > 0){
		    if(write(f2,buf,n)!=n)error("Write Error or Disk full.");
		    tbytes += n;
		    if(echo)printf("%u bytes \r",tbytes);
		    }
		close(f2);
		close(f1);

		if( __BDOS(6,254) ) ctrlbrk();

		} /* end of copy loop */
		printf("%u file(s) copied.    \r",next-2);
	} else puts("You must supply a source and destination.");
   } else { 
	    ver(0);
	    ver(1); 
	    }
 }

/* =============================== END MAIN ================================ */

instr(a,b)
char *a, *b;
{
	int i=0;
	while( a[i++] != 0 ) {
		if( a[i] == b ) return(i);
		}
	return(0);
}

error(s)
char *s;
{
	puts(s);
        exit(1);

}

ctrlbrk(c)
int c;
{
	c=__BDOS(6,255);
	if (c=3){
	        puts("*interrupted*          ");
	        exit(1);
	}
}


/* eof */

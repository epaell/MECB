/*----------------------------------------------------------------------------
	Lar86 - LBR format library file maintainer

	Update:	Ken Mauro DRC 1.11 for CP/M-86  Nov 1, 1998

 	Author:	by Stephen C. Hemminger
 		linus!sch or sch @Mitre-Bedford MA
		Lattice C version: T. Jennings 1 Dec 83 (MS-DOS)
-----------------------------------------------------------------------------*/

#include <stdio.h>
#include <ctype.h>

#define CPM86	1

memcpy(dest,src,n) char *dest, *src; int n; { blkmove(dest, src, n); }

extern long lseek();
extern long tell();
#define seek lseek

/* Library file status values: */

#define ACTIVE 0
#define UNUSED	0xff
#define	DELETED	0xfe
#define	CTRLZ	0x1a

#define	MAXFILES 128
#define	SECTOR 128
#define	DSIZE (sizeof(struct ludir))
#define	SLOTS_SEC (SECTOR/DSIZE)
#define	equal(s1, s2) (	strcmp(s1,s2) == 0 )
#define false 0
#define	true 1
#define	bool int

/* --- Globals ----- */
char *fname[MAXFILES];
bool ftouched[MAXFILES];
int errcnt, nfiles, nslots, pause;

char *getname();


struct ludir {			/* Internal library ldir structure */
	char l_stat;		/*  status of file */
	char l_name[8];		/*  name */
	char l_ext[3];		/*  extension */
    unsigned l_off;		/*  index/offset in library to current file */
    unsigned l_len;		/*  length of file in sectors (x 128bytes) */
	char l_fill[16];	/*  pad to 32 bytes */
} ldir[MAXFILES];




main (argc, argv)
int argc;
char **argv;
{
	char *flagp;
	char *aname;
	char linebuf[128];


	puts("\n");

	if (argc < 3) help();
	strmfe(linebuf,argv[2],"lbr");
	aname = linebuf;			/* name of LBR file, */

	filenames(argc, argv);

	switch(tolower(*argv[1])) {

	case 'a':
		update(aname,argc);
		break;
	case 'l':
		pause=1;
	case 't':
		table(aname);
		pause=0;
		break;
	case 'e':
		extract(aname);
		break;
	/*case 'p':
		print(aname);
		break;*/
	case 'd':
		delete(aname,1);
		break;
	case 'u':
		delete(aname,0);
		break;
	case 'r': 
		reorg(aname);
		break;
	default:
		help();
	}
	exit();
}


help(){						/* print error msg and exit */
	printf ("LAR86 1.4 for CP/M-86 \n\n");
	printf ("Usage: LAR86 [atedupr] library [files] ...\n\n");
	printf ("Functions:\n\tu - Update/ Add files to library\n");
	printf ("\tt - Table of contents\n");
	printf ("\tl - List contents w/pause \n");
 	printf ("\te - Extract files from library\n");
	printf ("\td - Delete files in library\n");
	printf ("\tu - UnDelete files in library\n");
	printf ("\tp - Print files in library\n");
	printf ("\tr - Reorganize library\n\n");

	exit (1);
}

error (str)
char *str;
{
	printf ("LAR: %s\n", str);
	exit (1);
}

cant (name)
char *name;
{
	printf ("%s: file not found \n", name);
	exit (1);
}



filenames(ac,av)	/* Get file names, check for dups, and initialize */
int ac;
char **av;
{
	register int i, j;


	errcnt = 0;
	for (i = 0; i < ac - 3; i++) {
		fname[i] = av[i + 3];
		ftouched[i] = false;
		if (i == MAXFILES) error ("Too many file names.");
		}

	fname[i] = NULL;
	nfiles = i;

	for (i = 0; i < nfiles; i++){
		for (j = i + 1; j < nfiles; j++)
			if (equal (fname[i], fname[j])) {
			printf ("%s", fname[i]);
			error (": duplicate file name");
			}
		}	

}


table(lib)
char *lib;
{
	char *uname;
	int lfd, i, j;
	int total=0, active = 0, unused = 0, deleted = 0;


	if ((lfd= openb(lib,2)) == -1) cant(lib);

	getdir(lfd);
	total =	ldir[0].l_len;

	printf("LU  Library: %s \n\n",lib);

	printf("Name         Index    Sectors    Bytes   \n\n");
	printf("Catalog*     %4u   %6u      %6u  \n", ldir[i].l_off, 
                                                      total, total*128);
	j=0;
	for (i = 1; i < nslots;	i++){
		switch(ldir[i].l_stat) {
		case ACTIVE:
			active++;
			uname = getname(ldir[i].l_name, ldir[i].l_ext);
			total += ldir[i].l_len;
			printf("%-12s %4u   %6u      %6lu\n", uname,
						ldir[i].l_off, ldir[i].l_len,
						(long) ldir[i].l_len*SECTOR);
			break;

		case DELETED:
			deleted++;
			uname = getname(ldir[i].l_name, ldir[i].l_ext);
			total += ldir[i].l_len;
			printf("%-12s %4u * %6u *    %6lu *del\n", uname,
						ldir[i].l_off, ldir[i].l_len,
						(long) ldir[i].l_len*SECTOR);
			break;
		case UNUSED:
			unused++;
			break;
		/*fault:
			deleted++;*/

		}
		j++;
		if(pause && j==18){
			j=0;
			printf("[ more.. ]"); 
			getchar();
			putchar(27);putchar('A');
			}

		}
	printf("          \n");
	printf("%3u files    totals   %4u      %6lu\n\n",active,total,
							(long)total*SECTOR);

	printf("%u slots, %u deleted, %u active, %u unused\n",
				              nslots, deleted,
                                               active, unused);

	close(lfd);
	not_found();

}

getdir(f)
int f;
{
	int cnt;

	if (read(f,&ldir[0],DSIZE) != DSIZE)	/* read 1st entry to find */
		error ("No directory\n");	/* number of slots, */

	nslots = ldir[0].l_len * SLOTS_SEC;
	cnt= DSIZE * (nslots - 1);		/* already read one slot, */

	if (read(f,&ldir[1],cnt) != cnt)
		error ("Can't read directory - is it a library?");
}


putdir(f)
int f;
{
	seek(f,0L,0);
	if(write(f,&ldir[0],nslots * DSIZE) != (nslots * DSIZE))
		error("Can't write directory - possible disk full.");

}

initdir(f,args)
int f, args;
{
	register int i, saved;
	int numsecs;
	char input[80];


	/* calculate LU dir sectors required, rounding up to nearest sector */

	numsecs = (args>>2)+1*((args%SLOTS_SEC)!=0);
	nslots = numsecs * SLOTS_SEC;
	saved = nslots;
	if (args > MAXFILES) error("Too many files specified.\n");

	printf("LAR-86: reserving slots for : %3u files.\n", nslots );
	printf("Option: add extra slots ?...: %3u free. \n", MAXFILES-nslots);
	printf("        or ENTER to continue: ");
	gets(input);
	printf("\n");
	nslots = atoi(input); 

	if( nslots == 0) nslots = saved;
	else {	numsecs = ((args+nslots)>>2)+1*(((args+nslots)%SLOTS_SEC)!=0);
		nslots = numsecs * SLOTS_SEC;
		}

	if (nslots > MAXFILES) error("Too many requested filename slots.\n");

	for (i = 0; i < nslots;	i++) {
		ldir[i].l_stat= UNUSED;
		blank_fill(ldir[i].l_name,8);
		blank_fill(ldir[i].l_ext,3);
		}

	ldir[0].l_stat = ACTIVE;
	ldir[0].l_len  = numsecs;
	
	putdir(f);

}


blank_fill(s,n)		/*Fill an array with blanks, no trailing null.*/
char *s;
int n;
{
	while (n--) *s++= ' ';
}


char *getname(nm, ex)		/* convert nm.ex to a Unix style string */
char *nm, *ex;
{
	static char namebuf[14];
	int i,j;


	for (i=0; (i<8) && (nm[i] != ' '); i++) namebuf[i]= tolower(nm[i]);
	j= i;
	namebuf[j++]= '.';

	for (i=0; (i<3) && (ex[i] != ' '); i++) namebuf[j++]= tolower(ex[i]);
	namebuf[j]= '\0';

	return(namebuf);

}


putname(cpmname, unixname)
char *cpmname, *unixname;
{

	cvt_to_fcb(unixname,cpmname);
}


filarg(name)			/* check if name matches argument list */
char *name;
{
	register int i;


	if (nfiles <= 0) return(1);

	for (i = 0; i < nfiles;	i++){
		if (equal (name, fname[i])) {
			ftouched[i] = true;
			return(1);
			}
		}

	return(0);
}


not_found() 
{
	register int i;

	for (i = 0; i < nfiles;	i++){
		if(!ftouched[i]) {
			printf ("%s: not in library.\n", fname[i]);
			errcnt++;
			}
		}

}


extract(name)
char *name;
{
	getfiles(name,false);
}


print(name)
char *name;
{
	getfiles(name,true);
}


acopy(fdi, fdo, nsecs)
int fdi, fdo;
unsigned nsecs;
{
	char buf[SECTOR];

	while( nsecs-- != 0) {
	    if (read(fdi,buf,SECTOR) != SECTOR) error("read error [acopy]");
	    if (write(fdo,buf,SECTOR) != SECTOR) error("write error [acopy]");
	    }
}


getfiles(name,pflag)
char *name;
bool pflag;
{
	int lfd, ofd;
	register int i;
	char *unixname;


	if((lfd= openb(name,2)) == -1) cant(name);

	getdir(lfd);

	for(i = 1; i < nslots;	i++) {
	if(ldir[i].l_stat != ACTIVE) continue;

	unixname = getname(ldir[i].l_name, ldir[i].l_ext);
	if(!filarg(unixname))	continue;

	printf("Extracting %s\n", unixname);

	if(pflag) ofd= openb("CON",2);
	else ofd = creatb(unixname,2);

	if(ofd == -1) {
		printf (" - can't create output file\n");
		errcnt++;
		}
	else {
		seek(lfd, (long) ldir[i].l_off * SECTOR,0);
		acopy(lfd, ofd, ldir[i].l_len);
		if(!pflag) close (ofd);
		}
	}
	close(lfd);
	not_found();
}


update(name, argc)			/*must open/create then re-open */
char *name;				/* lattice c problem ? */
int argc;
{
	int lfd;
	register int i;

	if((lfd = openb(name,0)) == -1) {	
		if((lfd = creatb(name, 2 )) == -1) cant(name);
		initdir(lfd, argc);
		}
	close(lfd);
	lfd=openb(name,2);


	getdir(lfd);			/* read directory, */

	seek(lfd, 0L, 2);		/* added 9/20/98 -km */

	for (i=0;(i<nfiles)&&(errcnt==0);i++){
		addfil(fname[i], lfd);
		}

	if (errcnt != 0) printf ("fatal errors - last file may be bad\n");
	putdir(lfd);

	close(lfd);

}


addfil(name, lfd)
char *name;
int lfd;
{
	int ifd;
	register int secoffs=0, numsecs=0;
	register int i=0;
	long int pos;


	if((ifd = openb(name, 0)) == -1) {
		printf("%s: can't find to add\n",name);
		errcnt++;
		return;
		}

	for(i = 0; i < nslots;	i++) {
		if (equal( getname(ldir[i].l_name, ldir[i].l_ext), name) ) {
			printf("Updating existing file %s\n",name);
			break;
			}

		if(ldir[i].l_stat != ACTIVE) {
			printf("Adding new file %s\n",name);
			break;
			}
		}

	if (i >= nslots) {
		printf("Can't add %s, all library slots are used.\n",name);
		errcnt++;
		return;
		}

	ldir[i].l_stat = ACTIVE;
	putname(ldir[i].l_name, name);


	pos = seek(lfd, 1L, 1);

	secoffs	= pos/SECTOR;
	ldir[i].l_off = secoffs;

	numsecs = fcopy(ifd, lfd);

	ldir[i].l_len = numsecs;


	close(ifd);

}


/* ======================================================================== */

fcopy(ifd, ofd)
int ifd, ofd;
{
	long pos;
	int i, n=1, total = 0;
	char sbuf[SECTOR];


	while( (n=read(ifd,sbuf,SECTOR)) == SECTOR ){
		if( write(ofd,sbuf,SECTOR)!=SECTOR) error("disk full [fcopy]");
		++total;
		};


	pos = seek(ifd, -1L, 1);
	pos = seek(ifd, 0L, 2);
	if( (pos/SECTOR) != total ){
	    if((n=read(ifd,sbuf,SECTOR)) >0 ) error("read error [fcopy-2]");
	    if(  write(ofd,sbuf,SECTOR)!=SECTOR) error("disk full [fcopy-2]");
	    ++total;
	    }; 


	return(total);

}


delete(lname,flag)
char *lname;
int flag;
{
	int f;
	register int i;


	if ((f= openb(lname,2)) == -1) cant (lname);
	if(nfiles <= 0) error("ext wildcard not supported,delete by name only");
	getdir (f);

	if(flag){
	for(i = 0; i < nslots; i++) {
	    if (!filarg ( getname (ldir[i].l_name, ldir[i].l_ext))) continue;
	    ldir[i].l_stat = DELETED;
	    }
	}

	if(!flag){
	for(i = 0; i < nslots; i++) {
	    if (!filarg ( getname (ldir[i].l_name, ldir[i].l_ext))) continue;
	    ldir[i].l_stat = ACTIVE;
	    }
	}
	not_found();

	if (errcnt > 0)	printf ("library not updated.\n");
	else putdir (f);
	close (f);

}


reorg (name)
char *name;
{
	int olib, nlib;
	int oldsize;
	register int i, j;
	struct ludir odir[MAXFILES];
	char tmpname[SECTOR];


	/*copy filename, strip off extention */
	for (i= 0; (i < 8) && (name[i] != '.'); i++) tmpname[i]= name[i];

	tmpname[i]= '\0';
	strcat(tmpname,".tmp");			/* make new name, */

	if ((olib = openb(name,2)) == -1) cant(name);
	if ((nlib = creatb(tmpname,2)) == -1) cant(tmpname);

	getdir(olib);
	printf("Old library has %d slots. \n\n", oldsize = nslots);

	for(i = 0; i < nslots ; i++)
		memcpy((char *)&odir[i],(char *)&ldir[i],sizeof(struct ludir));

	initdir(nlib,nslots);			/* added nslots -ken */
	errcnt = 0;

	for (i = j = 1; i < oldsize; i++)
	if( odir[i].l_stat == ACTIVE ) {
		printf("Copying: %-8.8s.%3.3s\n",odir[i].l_name,odir[i].l_ext);

		copyentry( &odir[i], olib, &ldir[j], nlib);

		if (++j >= nslots) {
			errcnt++;
			printf("Not enough room in new library\n");
			break;
			}
		}

	close(olib);
	putdir(nlib);
	close (nlib);

	if (errcnt == 0) {
		unlink(name);			/* delete orig file, */
		link(tmpname,name);		/* rename it, */
	} else {
		printf("Errors, library not updated\n");
		unlink(tmpname);
	}
}


copyentry( old, of, new, nf )
struct ludir *old, *new;
int of, nf;
{
	long int pos;
	register int secoffs, numsecs;
	char buf[SECTOR];

	new ->l_stat = ACTIVE;
	memcpy(new -> l_name, old -> l_name, 8);
	memcpy(new -> l_ext,  old -> l_ext, 3);

	seek(of,(long) (old -> l_off * SECTOR), 0);
	pos = seek(nf, 1L, 1);				/* added -ken */

	/*pos = seek(nf, 0L, 2);*/

	secoffs = pos/SECTOR;				/* added -ken */

	/*secoffs = tell(nf) / SECTOR;*/
	/*seek(nf,0L,2);*/		/* clear write error? */

	new->l_off= secoffs;
	numsecs	= old->l_len;
	new->l_len= numsecs;

	while(numsecs--	!= 0) {
	    if (read(of,buf,SECTOR) != SECTOR) error("read error [copyentry]");
	    if (write(nf,buf,SECTOR) != SECTOR)error("write error [copyentry]");
	}
}



/* Missing Lattice C function: File rename    error= link(oldname,newname); */

link(old,new)
char *old,*new;
{
	char fcb[36];
	int i;
	char *p;

	for (i= 0; i < sizeof(fcb); i++) fcb[i]= '\0'; 	/* clear it first */
	cvt_to_fcb(old,&fcb[1]);			/* first name, */
	cvt_to_fcb(new,&fcb[17]);			/* new name, */
	return(__BDOS(23,&fcb[0]) == 0xff);		/* do it. */

}


/*	Convert a normal asciz string to MSDOS/CPM FCB format. 
	Make the filename portion 8 characters, extention 3 maximum.	*/

cvt_to_fcb(inname,outname)
char *inname;
char outname[];
{
	char c;
	int i;

	for (i= 0; i < 11; i++)	outname[i]= ' ';	/* clear out name, */
	for (i= 0; i < 11; i++) {
		if (*inname == '\0') outname[i]= ' ';	/* if null, pad it, */
		else if (*inname == '.') {		/* if a dot, */
			++inname;			/* skip it, */
			i= 7;				/* skip to extention */
		} else {
			outname[i]= toupper(*inname);
			++inname;
			}
		}
	return;

}


strmfe(new,old,ext)
char *new,*old,*ext;
{
	while(*old != 0 && *old != '.') *new++=*old++;
	*new++='.';
	while(*ext) *new++=*ext++;
	*new=0;
}

/*eof*/


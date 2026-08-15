/*----------------------------------------------------------------------------
  DRC 1.11  Standard I/O header, modified to optimize *.cmd file size 

            Conditionally removes less commonly used library routines.
            reduce the resulting *.cmd file size approximately 10k 
-----------------------------------------------------------------------------*/

#include <portab.h>

#define FLOATS	FALSE		4/29/99 - Ken Mauro
#define LONGS 	FALSE			  constants defined in portab.h
#define STRINGS	FALSE
#define UNIX	FALSE

#define BUFSIZ	   512
#define MAXFILES   16
struct _iobuf {
	WORD _fd;
	WORD _flag;
	BYTE *_base;
	BYTE *_ptr;
	WORD _cnt;
};

#ifndef FILE
extern struct _iobuf _iob[MAXFILES];
#define FILE struct _iobuf
#endif


#define NULLFILE ((FILE *)0)

#define _IOREAD 0x01
#define _IOWRT	0x02
#define _IOABUF 0x04
#define _IONBUF 0x08
#define _IOERR	0x10
#define _IOEOF	0x20
#define _IOLBUF 0x40
#define _IOSTRI 0x80
#define _IOASCI 0x100

#define stdin  (&_iob[0])
#define stdout (&_iob[1])
#define stderr (&_iob[2])

#define clearerr(p) ((p)->_flag &= ~_IOERR)
#define feof(p) ((p)->_flag & _IOEOF)
#define ferror(p) ((p)->_flag & _IOERR)
#define fileno(p) ((p)->_fd)
#define getchar() getc(stdin)
#define putchar(c) putc(c,stdout)
#define putc fputc
#define getc fgetc


#define abs(x)	((x) < 0 ? -(x) : (x))

#define MAX(x,y)   (((x) > (y)) ? (x) :  (y))
#define MIN(x,y)   (((x) < (y)) ? (x) :  (y))


/*   Defined supplied functions  */

extern long	atol();

#if FLOATS
extern double atof();
#endif

#ifdef UNIX
extern char   *sbrk();
#endif

extern char	*calloc() , *malloc() , *realloc() , *zalloc();
extern FILE	*fopen(), *fopena(), *fopenb();

/*extern FILE   *freopen(), *freopa(), *freopb();*/
/*extern FILE   *fdopen();*/
/*extern void   perror();*/

extern char    *gets(), *fgets();

#ifdef LONGS
extern long	lseek();
extern long	ftell();
extern long	tell();
extern long	getl();
extern long	putl();
#endif

#ifdef STRINGS
extern char	*index(), *rindex(), *strchr(), *strrchr();
#endif

extern char	*strcat();
extern char	*strncat();
extern char	*strcpy();
extern char	*strncpy();

#ifdef FLOATS
extern double	sqrt();
extern double	cos(), sin();
extern double	exp(), fabs();
extern double	tan(), atan();
extern double	log(), log10(); 
#endif

#ifdef UNIX 
extern char	*mktemp();
extern char	*getpass();
extern char	*ttyname();
extern void	longjmp();
#endif




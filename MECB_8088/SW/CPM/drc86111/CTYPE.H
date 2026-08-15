/****************************************************************************/
/*									    */
/*				CTYPE					    */
/*				-----					    */
/*									    */
/*   CTYPE.H  -  macros to classify ASCII-coded integers by table lookup.   */
/*									    */
/*									    */
/*	Note:	Integer args are defined only for int values such that	    */
/*		-1 <= value <= 127, i.e., EOF and 7-bit ASCII,		    */
/*		except for macro isascii(), which takes any int.	    */
/*		Any other args produce undefined results.		    */
/*	Assumes:							    */
/*		User will link with standard library functions. 	    */
/*		Compiler can handle declarator initializers and 	    */
/*		'#defines' with parameters.                                 */
/*									    */
/****************************************************************************/

/*
 *	Bit patterns for character class DEFINEs
 */
#define __c	01
#define __p	02
#define __d	04
#define __u	010
#define __l	020
#define __s	040
#define __cs	041
#define __ps	042

#ifndef CTYPE
extern	char	___atab();
extern	char	__atab[];
#endif

/*
 *	Character Class Testing and Conversion DEFINEs:
 */
#define isascii(ch) ((ch) < 0200 && (ch) >= 0)
#define isalpha(ch) (*(__atab+1+(ch)) & (__u | __l))
#define isupper(ch) (*(__atab+1+(ch)) & __u)
#define islower(ch) (*(__atab+1+(ch)) & __l)
#define isdigit(ch) (*(__atab+1+(ch)) & __d)
#define isalnum(ch) (*(__atab+1+(ch)) & (__u | __l | __d))
#define isspace(ch) (*(__atab+1+(ch)) & __s)
#define ispunct(ch) (*(__atab+1+(ch)) & __p)
#define isprint(ch) (*(__atab+1+(ch)) & (__u | __l | __d | __p))
#define iscntrl(ch) (*(__atab+1+(ch)) & __c)

#define tolower(ch) ((isascii(ch) && isupper(ch)) ? (ch)+('a'-'A') : (ch))
#define toupper(ch) ((isascii(ch) && islower(ch)) ? (ch)+('A'-'a') : (ch))
#define toascii(ch) ((ch) & 0177)




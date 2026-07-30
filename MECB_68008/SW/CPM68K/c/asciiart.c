/*
cp68 -i 0: asciiart.c asciiart.i
c068 asciiart.i asciiart.1 asciiart.2 asciiart.3 -f
era  asciiart.i
c168 asciiart.1 asciiart.2 asciiart.s
era  asciiart.1
era asciiart.2
as68 -l -u -s 0: asciiart.s
era  asciiart.s
lo68 -r -o asciiart.68k 0:s.o asciiart.o libf.a 0:clib
*/

#include "stdio.h"
extern float atof();

int main()
{
   int x, y, i;
   float ca, cb, a, b, t;
   float c1, c2, c3, c4;
   c1 = atof("0.0458");
   c2 = atof("0.08333");
   c3 = atof("2.0");
   c4 = atof("4.0");
   for(y = -12; y <= 12; y++) {
      for(x = -39; x <= 39; x++) {
         ca = c1*x;
         cb = c2*y;
         a = ca;
         b = cb;
         for(i=0; i<=15; i++) {
            t = a*a-b*b+ca;
            b = c3*a*b+cb;
            a = t;
            if((a*a+b*b)>c4)
               break;
         }
         if(i>=16)
            putchar(' ');
         else if(i>9)
            putchar(i+7+48);
         else
            putchar(i+48);
      }
      putchar('\n');
   }
}

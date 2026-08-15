#include <stdio.h>

int main()
{
   int i, j, k, l, n, p, q, r, x, y, z;
   int a[1000];
   n = 100;
   l = (int)(10 * n / 3 + 1);
   j = k = q = r = i = x = y = p = z = 0;
   for(j = 1; j <= l; j++)
      a[j] = 2;
   for(j = 1; j <= n; j++)
   {
      i = n - j;
      i = (int)(i * 10 / 3) + 16;
      if(i>l)
         i = l;
      r = 0;
      do
      {
         x = 10 * a[i] + r*i;
         r = (int)(x / (2 * i - 1));
         a[i] = (x % (2 * i - 1));
         i = i - 1;
      } while(i > 0);
      q = r;
      a[1] = (q % 10);
      q = (int)(q / 10);
      switch(q) {
         case 9:
            y = y + 1;
            break;
         case 10:
            printf("%d", p + 1);
            if(y != 0)
               for(k = 1; k <= y; k++)
                  printf("0");
            p = 0;
            y = 0;
            break;
         default:
            if(z)
            {
               if(z == 1)
                  printf("%d.", p);
               else
                  printf("%d", p);
            }
            z++;
            p = q;
            if (y != 0)
            {
               for(k = 1; k <= y; k++)
                  printf("9");
               y = 0;
            }
        }
   }
   printf("%d", p);
   return 0;
}
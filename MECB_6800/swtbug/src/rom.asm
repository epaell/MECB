*    VERSION 1.00

         ORG   $E000

START    BRA   START

         ORG   $FFF8
         dc.w  START          IRQ VECTOR
         dc.w  START          SOFTWARE INTERRUPT
         dc.w  START          NMI VECTOR
         dc.w  START          RESTART VECTOR

         END


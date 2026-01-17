*    VERSION 1.00

         ORG   $E000

START    LDX   #$0000         Fill memory from $0000 to $7FFF
FILL     LDAA  #$AA           Fill with $AA
         STAA  0,X            Store at current location
         INX                  Bump location
         CPX   #$8000         Reached end?
         BNE   FILL           No, keep filling
;
         LDX   #$0000         Go back to start of RAM
CHECK1   LDAA  0,X            Read a byte
         CMPA  #$AA           Was it what was written?
         BNE   BAD_RAM        No, RAM is bad
         INX                  Bump location
         CPX   #$8000         Reached end?
         BNE   CHECK1         No, keep checking
;
         LDX   #$0000         Fill memory from $0000 to $7FFF
FILL2    LDAA  #$55           Fill with $55
         STAA  0,X            Store at current location
         INX                  Bump location
         CPX   #$8000         Reached end?
         BNE   FILL2          No, keep filling
;
         LDX   #$0000         Go back to start of RAM
CHECK2   LDAA  0,X            Read a byte
         CMPA  #$55           Was it what was written?
         BNE   BAD_RAM        No, RAM is bad
         INX                  Bump location
         CPX   #$8000         Reached end?
         BNE   CHECK2         No, keep checking
         JMP   GOOD_RAM
BAD_RAM  JMP   BAD_RAM1

         ORG   $E800
BAD_RAM1  BRA  BAD_RAM1        If RAM is bad then check for   A15-A14-A13-A12 = 1-1-1-0

         ORG   $F000
GOOD_RAM BRA   GOOD_RAM       If RAMN is good then check for A15-A14-A13-A12 = 1-1-1-1

         ORG   $FFF8
         dc.w  START          IRQ VECTOR
         dc.w  START          SOFTWARE INTERRUPT
         dc.w  START          NMI VECTOR
         dc.w  START          RESTART VECTOR

         END


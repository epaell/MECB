********************************************************************
* Testvdp2 - Write date/sprite to VDP screen
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2024/08/29  epaell

               nam      Testvdp2
               ttl      Write date/sprite to VDP screen

               ifp1
               use      /dd/defs/defsfile
               endc

tylg           set      Prgrm+Objct   
atrv           set      ReEnt+rev
rev            set      $00
edition        set      1

               mod      eom,name,tylg,atrv,start,size

               org      0
sysyear        rmb      1
sysmonth       rmb      1
sysday         rmb      1
syshour        rmb      1
sysmin         rmb      1
syssec         rmb      1
filepath       rmb      1
parmptr        rmb      2
bufptr         rmb      2
sx             rmb      1
dx             rmb      1
sy             rmb      1
dy             rmb      1
buffer         rmb      40
               rmb      400
size           equ      .

name           fcs      /Testvdp2/
               fcb      edition

* Macro to introduce more VDP wait states for faster CPUs
*
vdp_wait       macro
               nop
               nop
               nop
               nop
               endm

vdp_wvram      macro
               sta      VDP_VRAM
               nop
               nop
               nop
               nop
               endm

* Include the text character definitions
               use      textfont.asm
               use      sprites.asm

* Message to notify user that graphics device is being started up
text1          fcc      "Initialising graphics device"
               fcb      C$CR,C$LF
text1len       equ      *-text1

PATTABLE        EQU     0x0000             * 768 x 8                          : 0x0000 - 0x17FF (0x1800)
SPRPATTABLE     EQU     0x1800             * up to 32 sprites* 32 bytes each  : 0x0000 - 0x07FF (up to 2K)
COLORTABLE      EQU     0x2000             *                                  * 0x2000 - 0x37FF (0x1800)
NAMETABLE       EQU     0x3800             * 768 x 1                          : 0x3800 - 0x3AFF (0x0300)
SPRATTABLE      EQU     0x3B00             * 32 x 4 bytes                     : 0x3B00 - 0x3B7F (0x0080)

* VDP register settings for graphics mode II
vdp_regs       fcb      0x00               * graphics mode II
               fcb      0x82               * graphics mode II, 16K, display off, ints off
               fcb      NAMETABLE/0x0400
               fcb      COLORTABLE/0x0040
               fcb      PATTABLE/0x0800
               fcb      SPRATTABLE/0x0080
               fcb      SPRPATTABLE/0x0800
               fcb      0xF1               * white text, black background
*
* Month names
MonTable       fcs      '???'
               fcs      'January'
               fcs      'February'
               fcs      'March'
               fcs      'April'
               fcs      'May'
               fcs      'June'
               fcs      'July'
               fcs      'August'
               fcs      'September'
               fcs      'October'
               fcs      'November'
               fcs      'December'
*
Hello          fcc      "Hello, World!"
               fcb      0x00
*
* I/O mapping for VDP
VDP            equ      0xEF80            * TMS9918A Video Display Processor
VDP_VRAM       equ      VDP+0             * used for VRAM reads/writes
VDP_REG        equ      VDP+1             * control registers/address latch
VBANK_LOWER    equ      VDP+0x4           * read to select lower 16K of VRAM
VBANK_UPPER    equ      VDP+0xC           * read to select upper 16K of VRAM
VRAM           equ      0x4000            * high bits of VRAM address

start          stx      <parmptr          * save parameter pointer
               lda      #1
               leax     text1,pcr
               ldy      #text1len
               os9      I$WritLn          * Write a message to indicate VDP is being started
*
               lbsr     vdp_init_g2       * Initialise the VDP
               lbsr     vdp_display_on    * Turn display on
*
               lda      #10               * Set up x for sprite
               sta      sx,u
               lda      #40               * Set up y for sprite
               sta      sy,u
               lda      #1                * Set up direction for x and y
               sta      dx,u
               sta      dy,u
*
loop           pshs     u
               leax     sysyear,u         * location where date/time will be stored
               os9      F$Time            * get the current date and time
               leau     buffer,u
               bsr      Add2Buff          * go print the date in buffer
               ldd      #C$SPAC*256+C$SPAC  * else space it out
               std      ,u++
               bsr      DoTime            * and go add the time to the buffer
               clr      ,u                * terminate the line to print
               puls     u
               ldd      #NAMETABLE        * Start writing at the top of the screen
               lbsr     vdp_set_waddr
               leax     buffer,u
               lbsr     vdp_printstr
*
               ldy      #50               * count down the number of sleeps
loop1          ldx      #1                * Sleep for a tick
               os9      F$Sleep
               leay     -1,y
               bne      loop1             * Wait a bit more before updating time

               bsr      move_sprite

               bra      loop
*
*               clrb                       * else clear carry
*               os9      F$Exit            * and exit
*
DoTime         ldb      <syshour
               bsr      Byte2ASC
               ldb      <sysmin
               bsr      L00AB
               ldb      <syssec
L00AB          lda      #':
               sta      ,u+
               bra      Byte2ASC
*
Add2Buff       leay     >MonTable,pcr     * point to month table
               ldb      <sysmonth         * get month byte
               beq      L00C4             * branch if zero (illegal)
               cmpb     #12               * compare against last month of year
               bhi      L00C4             * if too high, branch
L00BD          lda      ,y+               * get byte
               bpl      L00BD             * keep going if hi bit not set
               decb                       * else decrement month
               bne      L00BD             * if not 0, keep going
L00C4          bsr      PrtStrng
               ldb      <sysday
               bsr      Byte2ASC
               ldd      #C$COMA*256+C$SPAC   * get comma and space in D
               std      ,u++              * store in buffer and increment twice
               lda      <sysyear          * get year
               ldb      #19-1             * century in B
CntyLp         incb                       * add a century
               suba     #100              * subtract 100 yrs
               bhs      CntyLp            * until yr<0
               adda     #100              * restore year to 00-99 range
               pshs     a                 * save year
               bsr      Byte2ASC          * print century
               puls     b                 * restore year & print

* write B reg to buffer as 2-digit decimal ASCII
* we don't need to do 100s digit, value are 00-99
Byte2ASC       lda      #'0-1                * start A out just below $30 (0)
Tens           inca                       * inc it
               subb     #10                  * subtract 10
               bcc      Tens                 * if result >= 0, continue
               sta      ,u+                  * else save 10's digit
               addb     #'0+10
               stb      ,u+                  * and 1's digit
               rts   
*
* make fcs strings printable
PrtStrng       lda      ,y
               anda     #$7F
               sta      ,u+
               lda      ,y+
               bpl      PrtStrng
               lda      #C$SPAC
               sta      ,u+
               rts
*
move_sprite    pshs     d
               lda      sx,u              * get the x position
               tst      dx,u              * check direction
               beq      negx
               inca
               sta      sx,u
               cmpa     #240
               bne      shifty
               lda      #0
               sta      dx,u              * reverse direction
               bra      shifty
negx           deca
               sta      sx,u
               cmpa     #0
               bne      shifty
               lda      #1
               sta      dx,u              * reverse direction
shifty         lda      sy,u              * get the y position
               tst      dy,u              * check direction
               beq      negy
               inca
               sta      sy,u
               cmpa     #176
               bne      update_sprite
               lda      #0
               sta      dy,u              * reverse direction
               bra      update_sprite
negy           deca
               sta      sy,u
               cmpa     #0
               bne      update_sprite
               lda      #1
               sta      dy,u              * reverse direction
update_sprite  ldd      #SPRATTABLE       * Set up the attribute for sprite 0
               lbsr     vdp_set_waddr
               lda      sy,u
               vdp_wvram
               lda      sx,u
               vdp_wvram
               lda      #0                * Sprite name
               vdp_wvram
               lda      #9                * Sprite colour
               vdp_wvram
               puls     d,pc

*
* ------ VDP Utility Functions ------
* -----------------------------------
*
* clear all VDP memory
* arguments:    none
* returns:      none
* destroys:     none
vdp_clear       pshs    d,x
                ldd     #0x0000           * write address, start at 0x0000
                lbsr    vdp_set_waddr     * Set up the destination VRAM address
                ldx     #16384	         * fill all 16K of available memory
                bra     vdp_fill1         * A=0

* fill a portion of VDP memory with a byte
* arguments:    VRAM address should be set already
*               x - number of bytes to fill
*               a - value to fill with
* returns:      none
* destroys:     none
vdp_fill        pshs    d,x
vdp_fill1       vdp_wvram
                leax    -1,x
                bne     vdp_fill1
                puls    d,x,pc            * restore X and return

* clear VRAM and initialize graphics II mode
* arguments:	U points to user stack
* returns:	none
* destroys:
vdp_init_g2     leax    vdp_regs,pcr      * point X to register settings
                bsr     vdp_set_regs
                bsr     vdp_clear         * clear VRAM
* copy character set to pattern table (make six copies to fill pattern table)
                ldx     #6                * Make six copies to cover 6 banks of characters
                ldd     #PATTABLE         * VRAM destination address
vdp_init2       bsr     copy_patterns
                leax    -1,x
                bne     vdp_init2         * Repeat until all banks copied across
* set up the colour tabble for the patterns
                ldd     #COLORTABLE
                lbsr    vdp_set_waddr
                lda     #0xC1             * text colour is green, background is black
                ldx     #128*8*6          * number of pattern colors to set
                bsr     vdp_fill
* initialize sprites
                ldd     #SPRPATTABLE      * Set up destination to sprite pattern table
                lbsr    vdp_set_waddr
                leax    sprite_def,pcr    * point to the sprite definitions
                ldy     #9*32             * transfer 9 x 32-byte patterns
                bsr     vdp_copy
                rts

*
* copy text character patterns to VRAM
* arguments: d - VRAM address to copy to
* returns:   none
* destroys:  none
copy_patterns   pshs    x,y
                bsr     vdp_set_waddr     * set up the VRAM address
                leax    text_font_def,pcr * point X to the text font definition
                ldy     #128*8            * 128 x 8-byte patterns to load
                bsr     vdp_copy
                puls    x,y,pc

* set VDP registers
* arguments:    pointer to 8-byte register set in X
* returns:      none
* destroys:     none
vdp_set_regs    pshs    d,x
                ldb     #0x80             * B holds register number, start at 0
vdp_set_regs1   lda     ,x+               * A holds register value
                sta     VDP_REG           * write data byte
                vdp_wait
                stb     VDP_REG           * then write register number
                vdp_wait
                incb
                cmpb    #0x88
                bne     vdp_set_regs1
                puls    d,x,pc

* copy from RAM to VRAM at current VRAM address
* arguments:  VRAM address should be set prior to entry
*             x - points to start of first pattern
*             y - number of bytes to transfer
* returns:    x advanced
* destroys:   none
vdp_copy        pshs    a,y
vdp_copy1       lda     ,x+
                vdp_wvram
                leay    -1,y
                bne    vdp_copy1
                puls    a,y,pc

* print a null-terminated string into VRAM
* arguments:    VRAM address in D
*               pointer to start of string in X
* returns:      X advanced
* destroys:     none
vdp_printstr    bsr     vdp_set_waddr

* print a null-terminated string into VRAM at current address
* arguments:  pointer to start of string in X
* returns:    x advanced
* destroys:   none
vdp_printstrc   pshs    a
vdp_printstrc1  lda     ,x+
                beq     vdp_printstrc2      * stop when nul
                vdp_wvram
                bra     vdp_printstrc1
vdp_printstrc2  puls    a,pc

* turn on the display after setup with vdp_init
* arguments:  none
* returns:    none
* destroys:   none
vdp_display_on  pshs    d
                ldd     #0xC281     * 0b11000010 （16K/enable/noint/gfx2/16pix sprite/x1 0b10000001 (register 1)
                sta     VDP_REG
                vdp_wait
                stb     VDP_REG
                vdp_wait
                puls    d,pc
*
* set up the VRAM write address
* arguments: D - VRAM address
* destroys:  none
vdp_set_waddr   pshs    a
                ora     #$40
                stb     VDP_REG     * set low byte of address
                vdp_wait
                sta     VDP_REG     * set high byte of address
                vdp_wait
                puls    a,pc
*
* set up the VRAM read address
* arguments: D - VRAM address
* destroys:  none
vdp_set_raddr   pshs    a
                anda    #$3F
                stb     VDP_REG     * set low byte of address
                vdp_wait
                sta     VDP_REG     * set high byte of address
                vdp_wait
                puls    a,pc
*
                emod
eom             equ   *
                end

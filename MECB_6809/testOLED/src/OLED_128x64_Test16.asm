;******************************************************************************
;	OLED_128x64_Test.asm
;
;	A simple MECB OLED Display 128x64 Card Test (for a 6809 CPU Card).
;
;	Set ENTRY EQU for your preferred code assembly location.
;	e.g. $0100 specified for running the code in the 2nd page of main RAM.
;	Set OLED EQU for your OLED's base address.
;	e.g. $C088 is for $C0 IORQ bank and $88 - $8F I/O block allocation. 
;
;	Author: Greg
;	Date:	Aug 2025
;
;******************************************************************************
               include  "src/mecb.inc"
               include  "src/ASSISTMacros.inc"

ENTRY          EQU   $0100
STKTOP         EQU   $007F             ; System Stack Top
;
; Code Entry Point
; ----------------
               ORG   ENTRY
; Initialise Direct Page Register for Zero page
               CLRA
               TFR   A,DP	
; Tell asm6809 what page the DP register has been set to
               SETDP #$00
; Set Stack to Stack Top
               LDS   #STKTOP
               pdata1   text1
;
; Initialise our OLED Display Panel
; There are many settings for the SSD1327, but most are correctly initialised
; following a Reset.  Therefore, I only update the settings that I wish to
; change from their default Reset value (as per the SSD1327 datasheet). 
;
               LDX   #OledInitCmds	   ; Load X as pointer to Initialise Command table
               LDB   #16               ; Number of Command bytes in table
LoadCmdLoop    LDA   ,X+               ; Load register data pointed to by X and increment X
               STA   OLED_CMD          ; Store Command byte
               DECB                    ; Point to next register
               BNE   LoadCmdLoop       ; Have we done all Command bytes?
; Clear the Display Buffer (VRAM)
               CLRA                    ; Zero byte to Clear Display buffer (VRAM)
               CLRB                    ; Full Display (Start row = 0)
               LBSR  OledFill          ; Fill OLED Display
; Turn ON the Display		
               LDA   #$AF              ; Turn Display ON (after clearing buffer)
               STA   OLED_CMD          ;
;
               clra                    ; Set colour
               sta   c
               sta   lx1               ; Start x1,y1 = (0,0)
               sta   ly1
               sta   lx2
               sta   ly2
               STA   ly1+1
               STA   lx1+1
               LDA   #63               ; End x2,y2 = (127,63)
               STA   ly2+1
               LDB   #127
               STB   lx2+1
lloop1         lda   c                 ; Set the current colour
               jsr   SetColour
               jsr   line              ; Draw the line
               inc   c                 ; increment colour
               inc   lx1+1             ; increment x1
               decb                    ; decrement x2
               stb   lx2+1
               bne   lloop1
;
               ldb   ly2+1
lloop1a        lda   c
               jsr   SetColour
               jsr   line
               inc   ly1+1
               inc   c
               decb
               stb   ly2+1
               bne   lloop1a
               
; fill by sweeping top to bottom with horizontal lines
               pdata1  test1
               lda   #$04
               jsr   SetColour
               clra
               sta   lx1+1
               sta   ly1+1
               sta   ly2+1
               lda   #127
               sta   lx2+1
lloop2         jsr   line
               inc   ly1+1
               inc   ly2+1
               lda   ly1+1
               cmpa  #64
               bne   lloop2
; clear by sweeping left to right with vertical lines
               pdata1   test2
               lda   #$08
               jsr   SetColour
               clra
               sta   lx1+1
               sta   ly2+1
               sta   lx2+1
               lda   #63
               sta   ly1+1
lloop5         jsr   line
               inc   lx1+1
               inc   lx2+1
               lda   lx1+1
               cmpa  #128
               bne   lloop5
; clear by sweeping top to bottom with horizontal lines
               pdata1   test3
               lda   #$0C
               jsr   SetColour
               clra
               sta   lx2+1
               sta   ly1+1
               sta   ly2+1
               lda   #127
               sta   lx1+1
lloop3         jsr   line
               inc   ly1+1
               inc   ly2+1
               lda   ly1+1
               cmpa  #64
               bne   lloop3
; fill by sweeping left to right with vertical lines
               pdata1 test4
               lda   #$0f
               jsr   SetColour
               clra
               sta   lx1+1
               sta   ly1+1
               sta   lx2+1
               lda   #63
               sta   ly2+1
lloop4         jsr   line
               inc   lx1+1
               inc   lx2+1
               lda   lx1+1
               cmpa  #128
               bne   lloop4
;
;
; Return to ASSIST09
;
exit           monitr   #$01
;
hello          fcc   "Hello, World!"
               fcb   EOT
c              RMB   1
vx             RMB   1                 ; X coord
vy             RMB   1                 ; Y coord
colourl        RMB   1                 ; Colour to plot with (assuming low nybble)
colourh        RMB   1                 ; Colour to plot with (assuming high nybble)
;
lx1            rmb   2                 ; line start and end coordinate
ly1            rmb   2
lx2            rmb   2
ly2            rmb   2
;
x1             rmb   2                 ; line drawing internal variables
y1             rmb   2
x2             rmb   2
y2             rmb   2
;
dy             rmb   2                 ; line drawing internal variables
dx             rmb   2
lx             rmb   2
ly             rmb   2
error          rmb   2
stepy          rmb   2
steep          rmb   1                 ; non-zero if (dy>dx)
;
; Text writing positions
;TEXTRS         RMB   1                 ; Text start row
;TEXTCS         RMB   1                 ; Text start column
;TEXTCOL        RMB   1                 ; Columns to output
;
;OUT4X          RMB   2
;
;OUTS           PSHS  A,X
;OUTS2          LDA   ,X+
;               CMPA  #EOT
;               BEQ   OUTS3
;               BSR   OUTC
;               BRA   OUTS2
;OUTS3          PULS  A,X,PC
;
;OUTC           PSHS  D,X,Y
;               PSHS  A
;               LDA   TEXTCS            ; Start =current text column
;               TFR   A,B
;               ADDB  #5                ; End = start + 2 (6 pixels)
;               LBSR  ColSetF           ;
;               LDA   TEXTRS            ; Start = current text row
;               TFR   A,B
;               ADDB  #8                ; End = start + 7 (8 lines)
;               LBSR  RowSetF           ;
;               PULS  B                 ; The character to write
;               CLRA
;               ASLB                    ; D x 2
;               ROLA
;               ASLB                    ; D x 4
;               ROLA
;               ASLB                    ; D x 8
;               ROLA
;               LDX   #text_font_def    ; Point to character table
;               LEAX  D,X               ; Get offset to character definition (8 bytes follow)
;               LDY   #8                ; Number of bytes to read
;OLOOP          LDA   #3                ; Reset number of columns to shift
;               STA   TEXTCOL
;               LDA   ,X+               ; Read character definition byte
;OSHIFT         CLRB                    ; Assume both pixels off
;               ASLA                    ; Get the MS Bit
;               BCC   POFF              ; If it is off continue to next bit
;               LDB   COLOURH           ; Otherwise set upper nybble with colour
;POFF           ASLA                    ; Get next bit
;               BCC   POFF2             ; If off, continue
;               ORB   COLOURL           ; Otherwise set lower nybble with colour
;POFF2          STB   OLED_DTA          ; Output to OLED
;               STB   OUT4X
;               DEC   TEXTCOL           ; Decrement the column counter
;               BNE   OSHIFT            ; If not zero there are more bits to shift
;               LEAY  -1,Y              ; Get next row
;               BNE   OLOOP
;               LDA   TEXTCS
;               ADDA  #6
;               STA   TEXTCS
;               PULS  D,X,Y,PC
;
; Message to notify user that graphics device is being started up
;
text1          fcc   "Initialising graphics device"
               fcb   CR,LF,EOT
test1          fcc   "Test1"
               fcb   CR,LF,EOT
test2          fcc   "Test2"
               fcb   CR,LF,EOT
test3          fcc   "Test3"
               fcb   CR,LF,EOT
test4          fcc   "Test4"
               fcb   CR,LF,EOT
;
; Data Structures
; ---------------
OledInitCmds   FCB   $B3,$70           ; Set Clk Divider / Osc Fequency
               FCB   $A0,$51           ; Set appropriate Display re-map
               FCB   $D5,$62           ; Enable second pre-charge
               FCB   $81,$FF           ; Set contrast (0 - $FF)
               FCB   $B1,$74           ; Set phase length - Phase 1 = 4 DCLK / Phase 2 = 7 DCLK
               FCB   $B6,$0F           ; Set second pre-charge period
               FCB   $BC,$07           ; Set pre-charge voltage - 0.613 x Vcc
               FCB   $BE,$07           ; Set VCOMH - 0.86 x Vcc
;
; Subroutines
; -----------
;
; Negate Acc D
negd           nega
               negb
               sbca     #$00              ; Negate Acc D if A=0
               rts
;
;
; Draw line from (lx1, ly1) to (lx2, ly2)
line           pshs     d
               ldd      lx1
               std      x1
               ldd      lx2              ; dx = abs(x2-x1)
               std      x2
               subd     x1
               bcc      line2
               jsr      negd
line2          std      dx
               ldd      ly1
               std      y1
               ldd      ly2               ; dy = abs(y2-y1)
               std      y2
               subd     y1
               bcc      line2a
               jsr      negd
line2a         std      dy
               clr      steep
               cmpd     dx
               bls      line3
               inc      steep             ; if steep swap x with y
; swap x and y
               ldd      x1                ; x1, y1 = y1, x1
               pshs     d
               ldd      y1
               std      x1
               puls     d
               std      y1
               ldd      x2                ; x2, y2 = y2, x2
               pshs     d
               ldd      y2
               std      x2
               puls     d
               std      y2
line3          ldd      x1                ; if (x1>x2)
               cmpd     x2
               lbgt      line_rev          ; reversed
;
               ldd      x2                ; dx = x2 - x1
               subd     x1
               std      dx
               lsra
               rorb
               std      error             ; error = (dx >> 1)
               ldd      y2                ; dy = abs(y2-y1)
               subd     y1
               bcc      line4
               jsr      negd
line4          std      dy
               ldd      #0
               std      stepy             ; stepy = 0
               ldd      y1                ; ly = y1
               std      ly
               cmpd     y2
               blt      line5
               ldd      stepy             ; if y1 >= y2 stepy = -1
               subd     #1
               bra      line6
;
line5          ldd      #1                ; else stepy = 1
line6          std      stepy
               ldd      x1
               std      lx
line6a         tst      steep
               beq      line7
               ldd      ly                ; if steep
               stb      vx
               ldd      lx
               stb      vy
               bra      line8             ; plot(y, x)
line7          ldd      lx                ; else plot(x, y)
               stb      vx
               ldd      ly
               stb      vy
line8          jsr      SetPixel
               ldd      error             ; error -= dy
               subd     dy
               std      error
               bge      line9
               ldd      ly                ; if error < 0
               addd     stepy             ; ly += ystep
               std      ly
               ldd      error             ; error += dx
               addd     dx
               std      error
line9          ldd      lx
               cmpd     x2
               beq      line_done
               addd     #1
               std      lx
               bra      line6a
line_done      puls     d,pc
;
line_rev       ldd      x1                ; Reversed, x1, x2 = x2, x1
               pshs     d
               ldd      x2
               std      x1
               puls     d
               std      x2
               ldd      y1                ; y1, y2 = y2, y1
               pshs     d
               ldd      y2
               std      y1
               puls     d
               std      y2
;
               ldd      x2                ; dx = x2 - x1
               subd     x1
               std      dx
               lsra
               rorb
               std      error             ; error = (dx >> 1)
               ldd      y2                ; dy = abs(y2-y1)
               subd     y1
               bcc      liner4
               jsr      negd
liner4         std      dy
               ldd      #0
               std      stepy             ; stepy = 0
               ldd      y2                ; ly = y2
               std      ly
               cmpd     y1
               blt      liner5
               ldd      #1                ; if y1 < y2 stepy = 1
               bra      liner6
;
liner5         ldd      stepy
               subd     #1                ; else stepy = -1
liner6         std      stepy
               ldd      x2
               std      lx
liner6a        tst      steep             ; if steep
               beq      liner7
               ldd      ly
               stb      vx
               ldd      lx
               stb      vy
               bra      liner8             ; plot(y, x)
liner7         ldd      lx                 ; else plot(x, y)
               stb      vx
               ldd      ly
               stb      vy
liner8         bsr      SetPixel
               ldd      error
               subd     dy
               std      error
               bgt      liner9
               ldd      ly
               subd     stepy
               std      ly
               ldd      error
               addd     dx
               std      error
liner9         ldd      lx
               beq      liner_done
               subd     #1
               std      lx
               bra      liner6a
liner_done     puls     d,pc

;
; Function:    Set the Pixel at vx,vy
; Parameters:  vx - X coord (0 - 63 / 127)
;              vy - Y coord (0 - 31 / 63)
; Returns:     -
; Destroys:    A, B
SetPixel
               lda   #$75              ; Set Row Address Command
               sta   OLED_CMD          ;
               lda   vy                ; Start row (top)
               sta   OLED_CMD          ;
               sta   OLED_CMD          ; End row (bottom) = Start row

               lda   #$15              ; Set Column Address Command
               sta   OLED_CMD          ;
               lda   vx                ; Start column (left)
               lsra                    ; Div A by 2 (2 pixels per byte)
               sta   OLED_CMD          ;
               sta   OLED_CMD          ; End column address (right) = Start column

               ldb   OLED_DTA          ; Dummy Read
               ldb   OLED_DTA          ; Actual Read
               lda   vx
               bita  #$01              ; Test if we're updating odd column?
               beq   WasEvnSet         ;
               andb  #$F0              ; Mask out odd column
               orb   colourl           ; Set for odd column pixel
               bra   StrPxlSet         ;
WasEvnSet      andb  #$0F              ; Mask out even column
               orb   colourh           ; Set for even column pixel
StrPxlSet      stb   OLED_DTA          ;
               rts

;
; Function:    Set colour for pixel write
; Parameters:  A - Colour (0-15)
; Returns:     -
; Destroys:    -
SetColour
               pshs  a                 ; Save A
               anda  #$0f              ; Ensure only lower nybble has value
               sta   colourl           ; Save it for use
               asla                    ; Shift to upper nybble
               asla
               asla
               asla
               sta   colourh           ; Save it for use
               puls  a,pc              ; Return

;
; Function:    Fill OLED display VRAM with byte, from a specified start row
; Parameters:  A - Byte to fill OLED buffer with
;              B - Start Row (i.e. 0 for full panel fill)
; Returns:     -
; Destroys:    B,Y
OledFill
               tfr   d,y               ; Save Parameters
;
               clra                    ; Set Column Address range
               ldb   #127              ; Start =0, End = 127
               bsr   ColSetF           ;
;
               tfr   y,d               ; Restore Parameters
               pshs  a                 ; Save Byte to fill
               tfr   b,a               ; Set Row Address range

               ldy   #0                ; Establish Count of Bytes to Write
WrtDtaLp1      leay  128,y             ; Add 128 to Y
               incb
               cmpb  #64
               bne   WrtDtaLp1
;
               ldb   #63               ; Start = A, End = 63
               bsr   RowSetF           ;
               puls  a                 ; Restore Byte to fill
WrtDtaLp2      sta   OLED_DTA          ; Write Byte to curent buffer location
               leay  -1,y              ; Dec Y
               bne   WrtDtaLp2         ; Done?
               rts
;
; Support Subroutines
; -------------------
;
; Function:	Set the Display buffer Column Start and End addresses (128x64 res)
; Parameters:  A - Start column (0 - 127)
;              B - End column  (0 - 127)
; Returns:     -
; Destroys:    -
ColSetF
               pshs  a                 ;
               lda   #$15              ; Set Column Address Command
               sta   OLED_CMD          ;
               puls  a                 ; Start column (left)
               lsra                    ; Div A by 2 (2 pixels per byte)
               sta   OLED_CMD          ;
               lsrb                    ; Div B by 2 (2 pixels per byte)
               stb   OLED_CMD          ; End column address (right)
               rts
;
; Function:	Set the Display buffer Row Start and End addresses (128x64 res)
; Parameters:  A - Start row (0 - 63)
;              B - End row (0 - 63) 
; Returns:     -
; Destroys:    -
RowSetF
               pshs  a                 ; Save A
               lda   #$75              ; Set Row Address Command
               sta   OLED_CMD          ;
               puls  a                 ; Start row (top)
               sta   OLED_CMD          ;
               stb   OLED_CMD          ; End row (bottom)
               rts
;
; Function:	Fill OLED display VRAM with byte (note 1 byte = 2 pixels)
; Parameters:  A - Byte to fill OLED buffer with
; Returns:     -
; Destroys:    y,b
OledFillAll
               ldy   #4096             ; 128 x 64 bytes (128 x 64 pixels)
               pshs  a                 ; Save Byte we want to fill with
;
               clra                    ; Set Column Address range
               ldb   #127              ; Start =0, End = 127
               bsr   ColSetF           ;
;
               clra                    ; Set Row Address range
               ldb   #63               ; Start = 0, End = 63
               bsr   RowSetF           ;
;
               puls  a                 ; Restore Byte we want to fill with
WrtDtaLp       sta   OLED_DTA          ; Write Byte to current buffer location
               leay  -1,Y              ; Dec Y
               bne   WrtDtaLp          ; Done?
               rts
;
               end
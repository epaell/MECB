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
               ldx   #OledInitCmds	   ; Load X as pointer to Initialise Command table
               ldb   #16               ; Number of Command bytes in table
LoadCmdLoop    lda   ,X+               ; Load register data pointed to by X and increment X
               sta   OLED_CMD          ; Store Command byte
               decb                    ; Point to next register
               bne   LoadCmdLoop       ; Have we done all Command bytes?
; Clear the Display Buffer (VRAM)
               clra
               lbsr  OledFillAll       ; Fill OLED Display
; Turn ON the Display		
               lda   #$AF              ; Turn Display ON (after clearing buffer)
               sta   OLED_CMD          ;
;
               lda      #10
               sta      lx1
               sta      ly1
               lda      #100
               sta      lx2
               lda      #50
               sta      ly2
               lda      #3
               sta      dx1
               sta      dy1
               lda      #$ff
               sta      dx2
               lda      #2
               sta      dy2
               lda      #0
               sta      c

loop           lda      lx1 ; x1 += dx1
               adda     dx1
               sta      lx1
               cmpa     #120
               blo      loop1
               ldb      dx1 ; if lx1>=123 then dx1=-dx1
               negb
               stb      dx1
loop1          cmpa     #5
               bhi      loop2
               ldb      dx1 ; if lx1<=5 then dx1=-dx1
               negb
               stb      dx1
;
loop2          lda      ly1 ; y1 += dy
               adda     dy1
               sta      ly1
               cmpa     #56
               blo      loop3
               ldb      dy1 ; if ly1>=58 then dy1=-dy1
               negb
               stb      dy1
loop3          cmpa     #5    ; if ly1<=5 then dy1=-dy1
               bhi      loop5
               ldb      dy1
               negb
               stb      dy1

loop5          lda      lx2 ; lx2 += dx2
               adda     dx2
               sta      lx2
               cmpa     #120
               blo      loop6
               ldb      dx2 ; if lx2>=123 then dx2=-dx2
               negb
               stb      dx2
loop6          cmpa     #5    ; if lx2<=5 then dx2=-dx2
               bhi      loop7
               ldb      dx2
               negb
               stb      dx2
loop7          lda      ly2 ; ly2 += dy2
               adda     dy2
               sta      ly2
               cmpa     #56  ; if ly2>= 56 then dy2=-dy2
               blo      loop8
               ldb      dy2
               negb
               stb      dy2
loop8          cmpa     #5    ; if ly2<=5 then dy2=-dy2
               bhi      loop9
               ldb      dy2
               negb
               stb      dy2
loop9          inc      c
               lda      c
               jsr      SetColour
               jsr      line
               lbra     loop

               if    0
               lda   #$0F              ; Set colour
               sta   C
               clra                    ; Start x1,y1 = (0,0)
               sta   ly1
               sta   lx1
               lda   #63               ; End x2,y2 = (127,63)
               sta   ly2
               ldb   #127
               stb   lx2
lloop1         lda   c                 ; Set the current colour
               jsr   SetColour
               jsr   line              ; Draw the line
               inc   c                 ; increment colour
               inc   lx1               ; increment x1
               decb                    ; decrement x2
               stb   lx2
               bne   lloop1
               lbra  exit
;
               ldb   ly2
lloop1a        lda   C
               jsr   SetColour
               jsr   line
               inc   ly1
               inc   
               decb
               stb   ly2
               bne   lloop1a
               
; fill by sweeping top to bottom with horizontal lines
               pdata1  test1
               pcrlf
               lda   #$04
               jsr   SetColour
               clra
               sta   lx1
               sta   ly1
               sta   ly2
               lda   #127
               sta   lx2
lloop2         jsr   line
               inc   ly1
               inc   ly2
               lda   ly1
               cmpa  #64
               bne   lloop2
; clear by sweeping left to right with vertical lines
               pdata1   test2
               pcrlf
               
               lda   #$08
               jsr   SetColour
               clra
               sta   lx1
               sta   ly2
               sta   lx2
               lda   #63
               sta   ly1
lloop5         jsr   line
               inc   lx1
               inc   lx2
               lda   lx1
               cmpa  #128
               bne   lloop5
; clear by sweeping top to bottom with horizontal lines
               pdata1   test3
               pcrlf
               lda   #$0C
               jsr   SetColour
               clra
               sta   lx2
               sta   ly1
               sta   ly2
               lda   #127
               sta   lx1
lloop3         jsr   line
               inc   ly1
               inc   ly2
               lda   ly1
               cmpa  #64
               bne   lloop3
; fill by sweeping left to right with vertical lines
               pdata1 test4
               pcrlf
               lda   #$0f
               jsr   SetColour
               clra
               sta   lx1
               sta   ly1
               sta   lx2
               lda   #63
               sta   ly2
lloop4         jsr   line
               inc   lx1
               inc   lx2
               lda   lx1
               cmpa  #128
               bne   lloop4
               endif
;
;
; Return to ASSIST09
;
exit           monitr   #$01
;
test1          fcc   "Test1"
               fcb   EOT
test2          fcc   "Test2"
               fcb   EOT
test3          fcc   "Test3"
               fcb   EOT
test4          fcc   "Test4"
               fcb   EOT
hello          fcc   "Hello, World!"
               fcb   EOT
;
c              rmb   1
dx1            rmb   1
dy1            rmb   1
dx2            rmb   1
dy2            rmb   1

vx             rmb   1                 ; X coord
vy             rmb   1                 ; Y coord
colourl        rmb   1                 ; Colour to plot with (assuming low nybble)
colourh        rmb   1                 ; Colour to plot with (assuming high nybble)
lx1            rmb   1                 ; line start and end coordinate
ly1            rmb   1
lx2            rmb   1
ly2            rmb   1
;
x1             rmb   1                 ; line drawing internal variables
y1             rmb   1
x2             rmb   1
y2             rmb   1
;
dy             rmb   1                 ; line drawing internal variables
dx             rmb   1
lx             rmb   1
ly             rmb   1
error          rmb   1
stepy          rmb   1
steep          rmb   1                 ; non-zero if (dy>dx)
;
;
; Message to notify user that graphics device is being started up
;
text1          fcc      "Initialising graphics device"
               fcb      CR,LF,EOT
;
; Data Structures
; ---------------
OledInitCmds   fcb   $B3,$70           ; Set Clk Divider / Osc Fequency
               fcb   $A0,$51           ; Set appropriate Display re-map
               fcb   $D5,$62           ; Enable second pre-charge
               fcb   $81,$FF           ; Set contrast (0 - $FF)
               fcb   $B1,$74           ; Set phase length - Phase 1 = 4 DCLK / Phase 2 = 7 DCLK
               fcb   $B6,$0F           ; Set second pre-charge period
               fcb   $BC,$07           ; Set pre-charge voltage - 0.613 x Vcc
               fcb   $BE,$07           ; Set VCOMH - 0.86 x Vcc
;
; Subroutines
; -----------
;
; Draw line from (lx1, ly1) to (lx2, ly2)
line           
               if    0                 ; Print out inputs if debugging
               pshs  d,x
               lda   #'(
               outch
               ldx   #lx1
               out2hs
               lda   #',
               outch
               ldx   #ly1
               out2hs
               lda   #')
               outch
               lda   #'-
               outch
               lda   #'(
               outch
               ldx   #lx2
               out2hs
               lda   #',
               outch
               ldx   #ly2
               out2hs
               lda   #')
               outch
               pcrlf
               puls  d,x
               endif
               
               pshs     d
               lda      lx1
               sta      x1
               lda      lx2              ; dx = abs(x2-x1)
               sta      x2
               suba     x1
               bcc      line2
               nega
line2          sta      dx
               lda      ly1
               sta      y1
               lda      ly2               ; dy = abs(y2-y1)
               sta      y2
               suba     y1
               bcc      line2a
               nega
line2a         sta      dy
               clr      steep
               cmpa     dx
               bls      line3
               inc      steep             ; if steep swap x with y
; swap x and y
               lda      x1                ; x1, y1 = y1, x1
               ldb      y1
               stb      x1
               sta      y1
               lda      x2                ; x2, y2 = y2, x2
               ldb      y2
               stb      x2
               sta      y2
line3          lda      x1                ; if (x1>x2)
               cmpa     x2
               lbgt     line_rev          ; reversed
;
               lda      x2                ; dx = x2 - x1
               suba     x1
               sta      dx
               lsra
               sta      error             ; error = (dx >> 1)
               lda      y2                ; dy = abs(y2-y1)
               suba     y1
               bcc      line4
               nega
line4          sta      dy
               clr      stepy             ; stepy = 0
               lda      y1                ; ly = y1
               sta      ly
               cmpa     y2
               blt      line5
               lda      #$ff             ; if y1 >= y2 stepy = -1
               bra      line6
;
line5          lda      #1                ; else stepy = 1
line6          sta      stepy
               lda      x1
               sta      lx
;
line6a         tst      steep
               beq      line7
               lda      ly                ; if steep
               sta      vx
               lda      lx
               sta      vy
               bra      line8             ; plot(y, x)
line7          lda      lx                ; else plot(x, y)
               sta      vx
               lda      ly
               sta      vy
line8          jsr      SetPixel
               lda      error             ; error -= dy
               suba     dy
               sta      error
               bge      line9
               lda      ly                ; if error < 0
               adda     stepy             ; ly += ystep
               sta      ly
               lda      error             ; error += dx
               adda     dx
               sta      error
line9          lda      lx
               cmpa     x2
               beq      ldone
               inc      lx
               bra      line6a
ldone          puls     d,pc
;
line_rev       lda      x1                ; Reversed, x1, x2 = x2, x1
               ldb      x2
               stb      x1
               sta      x2
               lda      y1                ; y1, y2 = y2, y1
               ldb      y2
               stb      y1
               sta      y2
;
               lda      x2                ; dx = x2 - x1
               suba     x1
               sta      dx
               lsra
               sta      error             ; error = (dx >> 1)
               lda      y2                ; dy = abs(y2-y1)
               suba     y1
               bcc      liner4
               nega
liner4         sta      dy
               clr      stepy             ; stepy = 0
               lda      y2                ; ly = y2
               sta      ly
               cmpa     y1
               blt      liner5
               lda      #1                ; if y1 < y2 stepy = 1
               bra      liner6
;
liner5         lda      #$FF              ; else stepy = -1
liner6         sta      stepy
               lda      x2
               sta      lx
liner6a        tst      steep             ; if steep
               beq      liner7
               lda      ly
               sta      vx
               lda      lx
               sta      vy
               bra      liner8             ; plot(y, x)
liner7         lda      lx                 ; else plot(x, y)
               sta      vx
               lda      ly
               sta      vy
liner8         bsr      SetPixel
               lda      error
               suba     dy
               sta      error
               bgt      liner9
               lda      ly
               suba     stepy
               sta      ly
               lda      error
               adda     dx
               sta      error
liner9         lda      lx
               cmpa     x1
               beq      liner_done
               deca
               sta      lx
               bra      liner6a
liner_done     puls     d,pc

;
; Function:    Set the Pixel at vx,vy (Res as per OLEDRES)
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

               if    0                 ; Print out pixel coordinate for debugging
               pshs  a
               LDA   #'(
               outch
               LDX   #vx
               out2hs
               LDA   #',
               outch
               LDX   #vy
               out2hs
               LDA   #')
               outch
               pcrlf
               puls  a
               endif
               
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
               END
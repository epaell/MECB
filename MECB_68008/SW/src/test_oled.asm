               org      $4000
;
               include  'mecb.inc'
               include  'tutor.inc'
               include  'library_rom.inc'
               include  'sdcard.inc'
               include  'oled.inc'
;
BUFFER_SIZE    equ      255
;
start          move.l   #RAM_END+1,a7              ; Set up stack
               jsr      SDParInit                  ; Set up SD interface
               jsr      oled_init
;
               move.b   #$00,d0                    ; d0 = fill value
               move.b   #$00,d1                    ; d1 = start row
               move.b   #$3f,d2                    ; d2 = end row
               jsr      oled_fill
               jsr      oled_on
;
               move.l   #40,d0                     ; Loop a number of times
loop           move.l   #RTC_struct,a0
               jsr      SDGetClock                 ; Get the RTC date/time
               bcs      clock_err
               move.l   #RTC_struct,a2
               move.l   #buffer,a6
               bsr      time2str
               move.b   #$00,(a6)                  ; Add a NULL terminator
               
               move.l   #char,a0                   ; point to pixel data structure
               move.b   #$00,OLED_CX(a0)           ; x
               move.b   #$3f-16,OLED_CY(a0)        ; y
               move.b   #$0f,OLED_CFC(a0)          ; foreground colour
               move.b   #$00,OLED_CBC(a0)          ; background colour
               move.b   #OLED_PSET,OLED_CL(a0)     ; Logical function
               move.l   #text_font_def,OLED_CF(a0) ; Font pointer
               move.l   #buffer,a1                 ; Point to date string
               jsr      oled_str
               sub.l    #1,d0
               bne      loop
               bra      test_end
;
clock_err      move.l   d0,-(a7)
               move.b   #OUTPUT,d7           ; Display an error
               move.l   #MS_RTCERR,a5
               move.l   #MS_RTCERRE,a6
               trap     #14
               move.l   (a7)+,d0
            
               move.b   #PNT2HX,d7           ; Add the error code
               move.l   #buffer,a6
               trap     #14
;
               move.b   #OUT1CR,d7           ; Output
               move.l   #buffer,a5
               trap     #14
               bra      test_end

test_end       move.b   #TUTOR,d7
               trap     #14
;
; convert RTC structure to string
; a2 - points to RTC structure
; a6 - points to destination buffer
; On return a6 points to last character in buffer
time2str       movem.l  d0/a0,-(a7)
               move.l   #0,d0
               move.b   SD_Day(a2),d0        ; Get the day
               bsr      add_two_dig
               move.b   #' ',(a6)+           ; Add a separator
               move.l   #0,d0
               move.b   SD_Month(a2),d0      ; Get the month
               sub.b    #1,d0                ; 0-index
               lsl.l    #2,d0                ; Create offset to month (4 char/month)
               move.l   #MONTH_NAME_TABLE,a0 ; Point to the month name table
               add.l    d0,a0                ; Add offset to the day of interest
month_copy     move.b   (a0)+,d0             ; Get a character
               cmp.b    #' ',d0              ; Check for a space
               beq      month_copied         ; if so then done
               move.b   d0,(a6)+             ; Otherwise add to the buffer
               bra      month_copy           ; loop until copied
month_copied   move.b   #' ',(a6)+           ; Add a separator
               move.b   #'2',(a6)+           ; Assume century is 2000
               move.b   #'0',(a6)+           ;
               move.b   SD_YearLow(a2),d0    ; Get the year
               bsr      add_two_dig
               move.b   #' ',(a6)+           ; Add a separator
               move.l   #0,d0
               move.b   SD_Hour(a2),d0       ; Get the hour
               bsr      add_two_dig
               move.b   #':',(a6)+           ; Add a separator
               move.l   #0,d0
               move.b   SD_Minute(a2),d0     ; Get the minute
               bsr      add_two_dig
               move.b   #':',(a6)+           ; Add a separator
               move.b   SD_Second(a2),d0    ; Get the second
               bsr      add_two_dig
               move.b   #' ',(a6)+           ; Add a separator
               move.l   #0,d0
               move.b   SD_DayOfWeek(a2),d0  ; Get the day of week
               sub.b    #1,d0                ; Change to zero indexed
               mulu.w   #12,d0
               move.l   #DAY_NAME_TABLE,a0   ; Point to the day name table
               add.l    d0,a0                ; Add offset to the day of interest
day_copy       move.b   (a0)+,d0             ; Get a character
               cmp.b    #' ',d0              ; Check for a space
               beq      day_copied           ; if so then done
               move.b   d0,(a6)+             ; Otherwise add to the buffer
               bra      day_copy             ; loop until copied
day_copied     movem.l  (a7)+,d0/a0          ; restore registers
               rts
;
add_two_dig    cmp.b    #10,d0
               bge      add_two_dig1            ; Has two digits
               move.b   #'0',(a6)+              ; Otherwise add a leading 0
add_two_dig1   move.b   #HEX2DEC,d7             ; Convert to decimal
               trap     #14
               rts

;
; Structure for pixel drawing
;
pixel          ds.b     1              ; x
               ds.b     1              ; y
               ds.b     1              ; colour
               ds.b     1              ; logical function
;
; Structure for character drawing
;
char           ds.b     1              ; x
               ds.b     1              ; y
               ds.b     1              ; foreground colour
               ds.b     1              ; background colour
               ds.b     1              ; logical function
               ds.b     3              ; alignment
               ds.l     1              ; font pointer
;
; Structure for line drawing
;
line           ds.b     1              ; x1
               ds.b     1              ; y1
               ds.b     1              ; x2
               ds.b     1              ; y2
               ds.b     1              ; colour
               ds.b     1              ; logical function
;
buffer         ds.b     BUFFER_SIZE+1
;
RTC_struct     ds.b     SD_RTC_STRUCT_SIZE
;
DAY_NAME_TABLE
               dc.b     'Sunday      ' ; 12 bytes per day name
               dc.b     'Monday      '
               dc.b     'Tuesday     '
               dc.b     'Wednesday   '
               dc.b     'Thursday    '
               dc.b     'Friday      '
               dc.b     'Saturday    '

MONTH_NAME_TABLE
               dc.b     'Jan ','Feb ','Mar ','Apr ','May ','Jun '
               dc.b     'Jul ','Aug ','Sep ','Oct ','Nov ','Dec '
;
MS_RTCERR      dc.b     "RTC Error Code: $"
MS_RTCERRE
;
               end

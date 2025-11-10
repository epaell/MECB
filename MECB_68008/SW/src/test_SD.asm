            org      $4000
;
            include  'mecb.asm'
            include  'tutor.asm'

BUFFER_SIZE equ      255
;
start       move.l   #RAM_END+1,a7        ; Set up stack
            bsr      SDParInit            ; Set up interface
            bsr      SDDiskPing
;
            move.l   #RTC_struct,a0
            bsr      SDGetClock           ; Get the RTC date/time
            bcs      clock_err
            
            move.l   #RTC_struct,a0       ; Check that we can write it back to the RTC
            bsr      SDSetClock
;
            move.l   #RTC_struct,a0       ; Read it back out again
            bsr      SDGetClock
            bcs      clock_err

            move.l   #RTC_struct,a2
            move.l   #0,d0
            move.b   SD_Day(a2),d0        ; Get the day
            move.l   #buffer,a6           ; Point to string buffer
            bsr      add_two_digits
            move.b   #' ',(a6)+           ; Add a separator
            move.l   #0,d0
            move.b   SD_Month(a2),d0      ; Get the month
            sub.b    #1,d0                ; 0-index
            lsl.l    #2,d0                ; Create offset to month (4 char/month)
            move.l   #MONTH_NAME_TABLE,a0 ; Point to the month name table
            add.l    d0,a0                ; Add offset to the day of interest
month_copy  move.b   (a0)+,d0             ; Get a character
            cmp.b    #' ',d0              ; Check for a space
            beq      month_copied         ; if so then done
            move.b   d0,(a6)+             ; Otherwise add to the buffer
            bra      month_copy           ; loop until copied
month_copied
            move.b   #' ',(a6)+           ; Add a separator
            move.b   #'2',(a6)+           ; Assume century is 2000
            move.b   #'0',(a6)+           ;
            move.b   SD_YearLow(a2),d0    ; Get the year
            bsr      add_two_digits
            move.b   #' ',(a6)+           ; Add a separator

            move.l   #0,d0
            move.b   SD_Hour(a2),d0       ; Get the hour
            bsr      add_two_digits
            move.b   #':',(a6)+           ; Add a separator
            move.l   #0,d0
            move.b   SD_Minute(a2),d0     ; Get the minute
            bsr      add_two_digits
            move.b   #':',(a6)+           ; Add a separator
            move.b   SD_Second(a2),d0    ; Get the second
            bsr      add_two_digits
            move.b   #' ',(a6)+           ; Add a separator
            move.l   #0,d0
            move.b   SD_DayOfWeek(a2),d0  ; Get the day of week
            sub.b    #1,d0                ; Change to zero indexed
            mulu.w   #12,d0
            move.l   #DAY_NAME_TABLE,a0   ; Point to the day name table
            add.l    d0,a0                ; Add offset to the day of interest
day_copy    move.b   (a0)+,d0             ; Get a character
            cmp.b    #' ',d0              ; Check for a space
            beq      day_copied           ; if so then done
            move.b   d0,(a6)+             ; Otherwise add to the buffer
            bra      day_copy             ; loop until copied
day_copied  move.b   #OUT1CR,d7           ; output the date/time string
            move.l   #buffer,a5           ; point to the date/time string
            trap     #14
            bra      end
;
clock_err   move.l   d0,-(a7)
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
            bra      end
;
            bsr      dir
            move.l   #FNAME,a0            ; Type a file
            bsr      type_file
;
            move.l   #FBADNAME,a0         ; Try to type a non-existent file
            bsr      type_file
            bra      end
;
add_two_digits
            cmp.b    #10,d0
            bge      time_out1            ; Has two digits
            move.b   #'0',(a6)+           ; Otherwise add a leading 0
time_out1   move.b   #HEX2DEC,d7          ; Convert to decimal
            trap     #14
            rts
;
type_file   bsr      SDDiskOpenRead       ; Open for read
            bcs      ropen_fail           ; Check for error
;
type_loop   move.l   #buffer,a0           ; Read bytes into buffer
            move.l   #BUFFER_SIZE,d0      ; Number of bytes to read
            bsr      SDDiskRead           ; Do the read
            bcs      type_done            ; Check for EoF
            move.l   a0,a2                ; End of data read
            move.l   #buffer,a1           ; Point to start of buffer
type_loop1  cmp.l    a1,a2                ; are we at the end?
            beq      type_loop            ; if so, read next chunk
            move.b   (a1)+,d0             ; Otherwise, get a byte
            move.b   #OUTCH,d7            ; output byte to terminal
            trap     #14
            cmp.b    #$0a,d0              ; was it a linefeed?
            bne      type_loop1           ; if not, check for next character
            move.b   #$0d,d0              ; otherwise output a carriage return as well
            move.b   #OUTCH,d7            ; output byte to terminal
            trap     #14
            bra      type_loop1           ; Loop back

ropen_fail  move.l   d0,-(a7)
            move.b   #OUTPUT,d7           ; Display an error
            move.l   #MS_OPENERR,a5
            move.l   #MS_OPENERRE,a6
            trap     #14
            move.l   (a7)+,d0
            
            move.b   #PNT2HX,d7           ; Add the error code
            move.l   #buffer,a6
            trap     #14
;
            move.b   #OUT1CR,d7           ; Output
            move.l   #buffer,a5
            trap     #14
;
type_done   bsr      SDDiskClose          ; Close the file
            rts
;
            bra      end
;
end         move.b   #TUTOR,d7
            trap     #14
;
; dir - display directory of SD card contents
;
dir         move.b   #OUT1CR,d7           ; Write message
            move.l   #MS_DIR,a5
            move.l   #MS_DIRE,a6
            trap     #14
;
            bsr      SDDiskDir            ; Initiate directory function
            bcs      dir_error
dir_loop    move.l   #buffer,a0           ; Point to buffer
            bsr      SDDiskDirNext        ; Get next entry
            bcs      dir_done             ; If it was the last entry then exit
;
            move.b   #OUT1CR,D7           ; Write the file name
            move.l   #buffer,a5
            move.l   a0,a6
            trap     #14
;
            bra      dir_loop             ; Loop back for more
;
dir_error   move.b   #OUT1CR,d7
            move.l   #MS_ERROR1,a5
            move.l   #MS_ERROR1E,a6
            trap     #14
;
dir_done    rts

            include  'sdcard.asm'
;
; File to test open (read)
;
FNAME       dc.b     'SD.CFG',$00
;
; File to test open on non-existant file (read)
;
FBADNAME    dc.b     'SDbad.CFG',$00
;
MS_RTCERR   dc.b     "RTC Error Code: $"
MS_RTCERRE
;
MS_OPENERR  dc.b     "File Open Error Code: "
MS_OPENERRE
;
MS_DIR      dc.b     "SD Card directory:"
MS_DIRE
;
MS_ERROR1   dc.b     "Failed  directory."
MS_ERROR1E
;
MS_ERROR2   dc.b     "Failed to mount."
MS_ERROR2E
;
; Buffer for directory
;
buffer      ds.b     BUFFER_SIZE+1
;
RTC_struct  ds.b     SD_RTC_STRUCT_SIZE
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

            end

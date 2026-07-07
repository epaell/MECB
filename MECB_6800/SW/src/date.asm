;
; Set and examine date
;
; Copyright (C) 1979 by
; Technical Systems Consultants, Inc.
; P.O. Box 2574
; West Lafayette, Indiana  47906
; (317) 423-5465
;
; Fixed for Y2K by Michael Holley, 12/13/2001
;
; Support added for MECB FujiNet network time 07/07/2026
; Modified to allow compilation with asl
; The binary can be saved to a FLEX disk by
; 1. Boot to FLEX
; 2. Type 'MON' to enter DigiBug
; 3. Use 'L' to load the S19 hex code
; 4. Type 'G CD03' to enter FLEX (warm start)
; 5. Type 'SAVE.LOW FNDATE.CMD,A100,A2FD,A100' to write the binary file to disk
; 6. Test by typing 'FNDATE' and hit return - it should output the current time and date.
; 7. Make FLEX automatically update the date on startup by creating a startup.txt file
; 8. Type 'build STARTUP.TXT'
; 9. Type 'FNDATE', press return, type '#' and press return. On boot, FLEX will still ask for a date - just enter 1,1,1
;     - it'll then update this with the network date.
;
; ASCII constants
;
EOT      equ     $04
LF       equ     $0A
CR       equ     $0D
;
         include "libfujinetlib.inc"
         include "libfujinet.inc"
         include "flex.inc"

         org   $A100

DATE0    bra   DATE1
         fcb   2           ; Version number
VALUE    fdb   0           ; Working register
DATE1    lda   LSTTRM
         cmpa  #CR         ; carriage return?
         beq   PDAT
         cmpa  #LF         ; line feed?
         beq   PDAT
;
; It looks like the user entered something
; on the command line, so parse it.
;
         bsr   GETDAT      ; Input number
         bcs   DATE4       ; error?
         cmpa  #12         ; month too high?
         bhi   DATE4       ; yes
         sta   LDATE       ; save month
;
         bsr   GETDAT      ; get the day
         bcs   DATE4
         cmpa  #31
         bhi   DATE4       ; branch if illegal
         sta   LDATE+1     ; else save it
;
         bsr   GETDAT      ; get the year
         bcs   DATE4
         cmpa  #99
         bhi   DATE4
         sta   lDATE+2     ; save the year
         jmp   WARMS       ; and return to FLEX
;
; Error handler.
;
DATE4    ldx   #fcb
         ldb   #26         ; set up error number
         stb   1,x
         jsr   RPTERR      ; report error
         ldx   #USAGE
         jsr   PSTRNG
         jmp   WARMS       ; back to FLEX
;
; Input a date value
;
GETDAT   jsr   INDEC       ; Input a number
         bcs   GETDA4
         tstb              ; Is there a number?
         beq   GETDA3
         stx   VALUE       ; save value
         lda   VALUE+1     ; get least signif part
         clc               ; indicate no errors (clear carry)
         rts
GETDA3   sec               ; Error flag (set carry)
GETDA4   rts
;
; Print the date
;
PDAT     jsr   PCRLF       ; New line
;
; First, call to get the current date/time
; from the real time clock if it exists.
;
         jsr   GETFNTIME
;
; If the clock returned valid data, update
; FLEX's date variables.
;
         jsr   UPDATE
;
; Now print the time.  If the RTC isn't
; there, this will do nothing.
;
         jsr   PTIME
;
; Now fall through and print the date.
;
         lda   LDATE       ; get the month
         ldx   #MONTH      ; start of table
PDAT1    deca
         beq   PDAT3
PDAT2    inx               ; find month string
         tst   0,X
         bne   PDAT2
         inx
         bra   PDAT1
;
PDAT3    bsr   PST         ; print it
         lda   #$20
         jsr   PUTCHR
         clr   VALUE
         lda   LDATE+1     ; day of the month
         sta   VALUE+1
         ldx   #VALUE
         clrb
         jsr   OUTDEC      ; print it
         ldx   #CST
         bsr   PST
;
; Now do the year.  This is where Michael Holley
; made changes to support the year.  Basically,
; if the year is less than 75, assume it's the
; year + 2000, else assume it's the year + 1900.
;
; YEAR   VALUE
; 1975   $07B7
; 1999   $07CF
; 2000   $07D0
;
OUTY     clrb
         lda   LDATE+2     ; get year
         cmpa  #75         ; 1975?
         bhs   OUTY2       ; lower than 75
         adda  #100        ; bump to next century
OUTY2    adda  #$6C        ; add low byte of 1900
         adcb  #$07        ; high part of 1900
         ldx   #VALUE
         stb   0,X
         sta   1,X
         clrb              ; suppress leading zeros
         jsr   OUTDEC
         jmp   WARMS       ; all done, back to FLEX
;
; Print string
;
PST      lda   0,X         ; get character
         beq   PST2        ; jump if end
         jsr   PUTCHR
         inx               ; move to next char
         bra   PST
PST2     rts
;
;================================================
; This function will attempt to get the current
; date/time from the real time clock.  If it
; succeeds, set the date with the RTC's value.
;
GETFNTIME:
         clr   CLKGUD      ; assume clock data is no good
                           ; Point to the DCB
         ldx   #fujinet_dcb
         jsr   fujinet_get_time
         cmpa  #FUJINET_RC_OK
         bne   GETRET      ; if failed, return
         inc   CLKGUD      ; Mark as succeeded
GETRET   rts
;
;================================================
; If the date from the RTC is good, move it into
; FLEX's date variables.  Else, do nothing.
;
UPDATE   lda   CLKGUD      ; non-zero if good data
         beq   EXIT1       ; no good, just exit.
;
         lda   TIMBUF+FN_TIME_MONTH       ; month
         sta   LDATE
         lda   TIMBUF+FN_TIME_MDAY        ; day of month
         sta   LDATE+1
         lda   TIMBUF+FN_TIME_YEARL       ; low part of year
;         suba   #$6C          ; 1900 AND $FF
;         cmpa   #100
;         blo    UPDA1         ; branch if < 100
;         suba   #100
UPDA1    sta   LDATE+2
EXIT1    rts
;
;================================================
; If the date/time were collected from the RTC,
; then format and display the current time.  If
; the RTC didn't respond, quietly return without
; displaying anything.
;
PTIME    lda   TIMBUF+FN_TIME_HOUR        ; hours
         jsr   PR2DIG
         lda   #':'
         jsr   PUTCHR
         lda   TIMBUF+FN_TIME_MIN         ; minutes
         jsr   PR2DIG
         lda   #':'
         jsr   PUTCHR
         lda   TIMBUF+FN_TIME_SEC         ; seconds
         jsr   PR2DIG
;
         lda   #','
         jsr   PUTCHR
         lda   #' '
         jsr   PUTCHR

;
; Now convert the day-of-week value into a string
; and print it.  Re-use the logic from the
; month display.
; 
;         lda   TIMBUF+7    ; day of week
;         ldx   #DAYS
;PR23     deca
;         beq   PR24
;PR25     inx
;         tst   0,X
;         bne   PR25
;         inx
;         bra   PR23
;PR24     jsr   PST         ; print day name
         rts
;
;================================================
; Print the value in A as two decimal digits
; with exactly two places.  This is used for
; printing the time, where hour, minute and
; second fields are always two digits.
;
PR2DIG   clrb              ; B is the tens
PR21     suba  #10
         bmi   PR22        ; one too many
         incb
         bra   PR21        ; and do again
PR22     adda  #10         ; add back
;
; A contains ones, and B contains tens.
;
         psha
         tba
         ora   #'0'        ; make ASCII
         jsr   PUTCHR
         pula
         ora   #'0'
         jmp   PUTCHR
;
; Text strings
;
CST      fcb   ", ",0
;
USAGE    fcb   "USAGE: DATE MM,DD,YY",4
;
; Month strings
;
MONTH    fcb   "January",0
         fcb   "February",0
         fcb   "March",0
         fcb   "April",0
         fcb   "May",0
         fcb   "June",0
         fcb   "July",0
         fcb   "August",0
         fcb   "September",0
         fcb   "October",0
         fcb   "November",0
         fcb   "December",0
;
; Day strings
;
DAYS     fcb   ", Sunday, "
         fcb   0
         fcb   ", Monday, "
         fcb   0
         fcb   ", Tuesday, "
         fcb   0
         fcb   ", Wednesday, "
         fcb   0
         fcb   ", Thursday, "
         fcb   0
         fcb   ", Friday, "
         fcb   0
         fcb   ", Saturday, "
         fcb   0
;
;================================================
; Data storage
;
CLKGUD   rmb   1        ; non-zero means clock data is valid
TIMBUF   rmb   8        ; clock data storage
;
fujinet_dcb:
         rmb   1        ; FujiNet device
         rmb   1        ; FujiNet command
         rmb   1        ; Aux1
         rmb   1        ; Aux2
         fdb   0        ; pointer to transmit buffer (not used)
         rmb   2        ; length of data in bytes
         fdb   TIMBUF   ; pointer to receive buffer (time)
         rmb   2        ; length of response buffer in bytes
         rmb   2        ; timeout in milliseconds

;
         end   DATE0

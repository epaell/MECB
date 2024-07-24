*================================================
* SETCLOCK utility to set the date and time on
* a Corsham Technologies SD/RTC board.
*
* 07/12/2015 - Bob Applegate K2UT
*              bob@corshamtech.com
*================================================
*
* Version number.  Must be from 0 to 9.
*
VERSION EQU     1
*
* ASCII constants
*
EOT     EQU     $04
LF      EQU     $0A
CR      EQU     $0D
SPACE   EQU     $20
*
        LIB     SDLIB.INC
        LIB     FLEX.INC
* Actual start of code
*
        ORG     $A100
SETTIME BRA     SET1
        FCB     VERSION
*
SET1    LDX     #INTRO
        JSR     PSTRNG
*
* See if the RTC is even available.  Get the
* current date/time.
*
        JSR     GETRTC
        BCC     SET2    *jump if RTC replied
*
* RTC failed, so print an error and just exit.
*
        LDX     #NORTC
        JSR     PSTRNG
        JMP     WARMS   *back to FLEX
*
* The RTC is good, so display the current date
* and time as a reference for the user before
* asking their input for a new date/time.
*
SET2    LDX     #CURRENT
        JSR     PSTRNG
        LDAA    TIMBUF+4 *hour
        JSR     PR2DIG
        LDAA    #':
        JSR     PUTCHR
        LDAA    TIMBUF+5 *minute
        JSR     PR2DIG
        LDAA    #':
        JSR     PUTCHR
        LDAA    TIMBUF+6 *second
        JSR     PR2DIG
*
        LDAA    #SPACE
        JSR     PUTCHR
*
        LDAA    TIMBUF  *month
        JSR     PRADEC  *print month
        LDAA    #'/
        JSR     PUTCHR
        LDAA    TIMBUF+1 *day of month
        JSR     PRADEC
        LDAA    #'/
        JSR     PUTCHR
        LDAA    TIMBUF+2 *high part of year
        STAA    VALUE
        LDAA    TIMBUF+3
        STAA    VALUE+1
        JSR     PRVDEC
*
* Give them instructions
*
        LDX     #INSTRU
        JSR     PSTRNG
*
        LDX     #MONPR
        LDAA    TIMBUF
        JSR     GETNUM
        STAA    TIMBUF
*
        LDX     #DAYPR
        LDAA    TIMBUF+1
        JSR     GETNUM
        STAA    TIMBUF+1
*
        LDX     #YEARPR
        LDAA    TIMBUF+3
        JSR     GETNUM
        STAA    TIMBUF+3
*
        LDX     #HOURPR
        LDAA    TIMBUF+4
        JSR     GETNUM
        STAA    TIMBUF+4
*
        LDX     #MINPR
        LDAA    TIMBUF+5
        JSR     GETNUM
        STAA    TIMBUF+5
*
        LDX     #SECPR
        LDAA    TIMBUF+6
        JSR     GETNUM
        STAA    TIMBUF+6
*
        LDX     #DOWPR
        LDAA    TIMBUF+7
        JSR     GETNUM
        STAA    TIMBUF+7
*
* Now comes the fun part.  Let another
* subroutine send the data back to the RTC.
*
        JSR     PUTRTC
        LDX     #SETMSG
        JSR     PSTRNG
*
        JMP     WARMS   *Back to FLEX!
*
*================================================
* This gets the current time from the RTC.
* Puts the data into TIMBUF.  On return, C is
* clear if the data was received.  C is set if
* there were errors; the data should not be used.
*
* The data is stored in TIMBUF as eight
* bytes with each field being in binary.  All
* but the year are a single byte:
*
* MDYYHMSW
*
* All fields are one based.  The W is the day of
* the week, with Sunday being 1, Monday is 2,
* etc.
*
GETRTC  JSR     PSETWR  *make sure we're in write mode
        LDAA    #CGETCLK *ask for RTC data
        JSR     PWRITE  *write the command
        JSR     PSETREA *get ready to receive bytes
        JSR     PREAD   *get response code
        CMPA    #RCLKDAT *clock data?
        BEQ     GET1    *jump if yes
*
* Assume a NAK.  Get the error code, but don't
* do anything with it.  Set C and then return.
*
        JSR     PREAD   *error code
        JSR     PSETWRI *set write mode again
        SEC             *indicate an error
        RTS
*
* Now get 8 bytes of data and store them into
* TIMBUF.
*
GET1    LDAB    #8
        LDX     #TIMBUF
GET2    JSR     PREAD
        STAA    0,X     *save next byte
        INX
        DECB
        BNE     GET2
*
* All of the bytes have been received, so
* clean up and return C clear.
*
        JSR     PSETWRI *set interface back to writing
        CLC             *indicate success
        RTS
*
*================================================
* This takes the 8 bytes in TIMBUF and sends them
* back to the Arduino to be written to the RTC.
*
PUTRTC  JSR     PSETWRI *make sure we're in write mode
        LDAA    #CSETCLK *SET CLOCK command
        JSR     PWRITE
*
* Now write 8 bytes of data
*
        LDX     #TIMBUF *start of data
        LDAB    #8      *number of bytes to write
PUT1    LDAA    0,X
        JSR     PWRITE
        INX
        DECB
        BNE     PUT1    *do next byte
*
* Now get response.  Should be an ACK, but if
* a NAK, get the error code.
*
        JSR     PSETREA
        JSR     PREAD
        CMPA    #RACK
        BEQ     PUT2
        JSR     PREAD   *get error code
PUT2    JSR     PSETWRI *back to write mode
        RTS
*
*================================================
* Given a value in A, print it in decimal.
*
PRADEC  STAA    VALUE+1
        CLR     VALUE
PRVDEC  LDX     #VALUE
        CLRB
        JMP     OUTDEC
*
*================================================
* This prints the value in A as two digits with
* a leading zero if needed.  Will not handle any
* number greater than 99.
*
PR2DIG  CLRB            *B is the tens
PR21    SUBA    #10
        BMI     PR22
        INCB
        BRA     PR21
PR22    ADDA    #10     *add it back
*
* A contains ones and B contains tens
*
        PSHA
        TBA
        ORAA    #'0     *make ASCII
        JSR     PUTCHR
        PULA
        ORAA    #'0
        JMP     PUTCHR
*
*================================================
* This helper prints a prompt, a number, gets
* user input and returns it as a number.  On
* entry X points to a prompt that ends with a
* '(', and A contains the default value.  This
* prints the prompt, number, and "): " and gets
* the user input, which is converted to a binary
* number and returned.
*
GETNUM  STAA    VALUE+1 *save for later
        JSR     PSTRNG  *print prompt
        CLR     VALUE
        CLRB
        LDX     #VALUE
        JSR     OUTDEC
        LDAA    #')
        JSR     PUTCHR
        LDAA    #':
        JSR     PUTCHR
        LDAA    #SPACE
        JSR     PUTCHR
        JSR     INBUFF  *get line from user
        JSR     INDEC   *conver to decimal
        BCS     GETDEF  *no number, so use default
        CMPB    #0
        BEQ     GETDEF
*
* Else X contains the value to return.
*
        STX     VALUE
GETDEF  LDAA    VALUE+1
        RTS
        PAG
*================================================
* Strings
*
INTRO   FCB     CR,LF
        FCC     'Set Time Utility v'
        FCB     VERSION+'0
        FCB     CR,LF,EOT
NORTC   FCC     "The RTC is not present.  Can't "
        FCC     'set the time or date.'
        FCB     CR,LF,EOT
CURRENT FCC     'Current time and date: '
        FCB     EOT
INSTRU  FCC     "For each field you can either type "
        FCC     "a new value or use the default value"
        FCB     CR,LF
        FCC     "(in parenthesis) by simply pressing "
        FCC     "the return key."
        FCB     CR,LF,EOT
MONPR   FCC     "Month ("
        FCB     EOT
DAYPR   FCC     "Day of month ("
        FCB     EOT
YEARPR  FCC     "Last two digits of year ("
        FCB     EOT
HOURPR  FCC     "Hour - 24 hour time ("
        FCB     EOT
MINPR   FCC     "Minutes ("
        FCB     EOT
SECPR   FCC     "Seconds ("
        FCB     EOT
DOWPR   FCC     "Day of week.  1=Sunday, 2=Monday, etc. ("
        FCB     EOT
SETMSG  FCB     CR,LF
        FCC     "The new time & date have been set"
        FCB     CR,LF,CR,LF,EOT
*
*================================================
* Data
*
TIMBUF  RMB     8
VALUE   RMB     2
*
        END     SETTIME


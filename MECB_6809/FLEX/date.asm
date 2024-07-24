        OPT     PAG
        TTL     DATE UTILITY
*
* Set and examine date
*
* Copyright (C) 1979 by
* Technical Systems Consultants, Inc.
* P.O. Box 2574
* West Lafayette, Indiana  47906
* (317) 423-5465
*
* Fixed for Y2K by Michael Holley, 12/13/2001
*
* Support added for external real time clock
* by Bob Applegate, K2UT, bob@corshamtech.com
* July 10, 2015
*
* ASCII constants
*
EOT     EQU     $04
LF      EQU     $0A
CR      EQU     $0D
*
        LIB     SDLIB.INC
        LIB     FLEX.INC

        ORG     $A100

DATE0   BRA     DATE1
        FCB     2       * Version number
VALUE   FDB     0       * Working register
DATE1   LDAA    LSTTRM
        CMPA    #CR     * carriage return?
        BEQ     PDAT
        CMPA    #LF     * line feed?
        BEQ     PDAT
*
* It looks like the user entered something
* on the command line, so parse it.
*
        BSR     GETDAT  * Input number
        BCS     DATE4   * error?
        CMPA    #12     * month too high?
        BHI     DATE4   * yes
        STAA    DATE    * save month
*
        BSR     GETDAT  * get the day
        BCS     DATE4
        CMPA    #31
        BHI     DATE4   * branch if illegal
        STAA    DATE+1  * else save it
*
        BSR     GETDAT  * get the year
        BCS     DATE4
        CMPA    #99
        BHI     DATE4
        STAA    DATE+2  * save the year
        JMP     WARMS   * and return to FLEX
*
* Error handler.
*
DATE4   LDX     #FCB
        LDAB    #26     * set up error number
        STAB    1,x
        JSR     RPTERR  * report error
        LDX     #USAGE
        JSR     PSTRNG
        JMP     WARMS   * back to FLEX
*
* Input a date value
*
GETDAT  JSR     INDEC   * Input a number
        BCS     GETDA4
        TSTB            * Is there a number?
        BEQ     GETDA3
        STX     VALUE   * save value
        LDAA    VALUE+1 * get least signif part
        CLC             * indicate no errors
        RTS
GETDA3  SEC             * Error flag
GETDA4  RTS
*
* Print the date
*
PDAT    JSR     PCRLF   * New line
*
* First, call to get the current date/time
* from the real time clock if it exists.
*
        JSR     GETRTC
*
* If the clock returned valid data, update
* FLEX's date variables.
*
        JSR     UPDATE
*
* Now print the time.  If the RTC isn't
* there, this will do nothing.
*
        JSR     PTIME
*
* Now fall through and print the date.
*
        LDAA    DATE    * get the month
        LDX     #MONTH  * start of table
PDAT1   DECA
        BEQ     PDAT3
PDAT2   INX             * find month string
        TST     0,X
        BNE     PDAT2
        INX
        BRA     PDAT1
*
PDAT3   BSR     PST     * print it
        LDAA    #$20
        JSR     PUTCHR
        CLR     VALUE
        LDAA    DATE+1  * day of the month
        STAA    VALUE+1
        LDX     #VALUE
        CLRB
        JSR     OUTDEC  * print it
        LDX     #CST
        BSR     PST
*
* Now do the year.  This is where Michael Holley
* made changes to support the year.  Basically,
* if the year is less than 75, assume it's the
* year + 2000, else assume it's the year + 1900.
*
* YEAR   VALUE
* 1975   $07B7
* 1999   $07CF
* 2000   $07D0
*
OUTY    CLRB
        LDAA    DATE+2  * get year
        CMPA    #75     * 1975?
        BHS     OUTY2   * lower than 75
        ADDA    #100    * bump to next century
OUTY2   ADDA    #$6C    * add low byte of 1900
        ADCB    #$07    * high part of 1900
        LDX     #VALUE
        STAB    0,X
        STAA    1,X
        CLRB     * suppress leading zeros
        JSR     OUTDEC
        JMP     WARMS   * all done, back to FLEX
*
* Print string
*
PST     LDAA    0,X     * get character
        BEQ     PST2    * jump if end
        JSR     PUTCHR
        INX             * move to next char
        BRA     PST
PST2    RTS
*
*================================================
* This function will attempt to get the current
* date/time from the real time clock.  If it
* succeeds, set the date with the RTC's value.
*
GETRTC  CLR     CLKGUD  *assume clock data is no good
        JSR     PSETWR  *make sure we're in write mode
        LDAA    #CGETCLK *ask for RTC data
        JSR     PWRITE  *send the command
        JSR     PSETREA *get ready to receive data
        JSR     PREAD   *get response code
        CMPA    #RCLKDAT *clock data?
        BEQ     GCD     *yes, so go get it
*
* Assume it's a NAK.  Get the response code,
* but don't really care about what it is.
*
        JSR     PREAD
        BRA     GETCU   *jump to common clean-up
*
* Clock data is coming.  Just store the raw
* values for now.
*
GCD     LDAB    #8      *8 bytes to follow
        LDX     #TIMBUF *where to put the data
GCLOOP  JSR     PREAD
        STAA    0,X
        INX
        DECB
        BNE     GCLOOP  *get next byte
*
* All of the bytes have been received.
*
        LDAA    #$FF
        STAA    CLKGUD  *indicate clock data is good
GETCU   JSR     PSETWRI *restore interface to writing
        RTS
*
*================================================
* If the date from the RTC is good, move it into
* FLEX's date variables.  Else, do nothing.
*
UPDATE  LDAA    CLKGUD  *non-zero if good data
        BEQ     EXIT1   *no good, just exit.
*
* This code should be cleaned up because it
* assumes the year has a century, which is not
* a safe assumption based on the protocol spec.
*
        LDAA    TIMBUF  *month
        STAA    DATE
        LDAA    TIMBUF+1 *day of month
        STAA    DATE+1
        LDAA    TIMBUF+3 *low part of year
*        SUBA    #$6C    *1900 AND $FF
*        CMPA    #100
*        BLO     UPDA1    *branch if < 100
*        SUBA    #100
UPDA1   STAA    DATE+2
EXIT1   RTS
*
*================================================
* If the date/time were collected from the RTC,
* then format and display the current time.  If
* the RTC didn't respond, quietly return without
* displaying anything.
*
PTIME   LDAA    TIMBUF+4 *hours
        JSR     PR2DIG
        LDAA    #':
        JSR     PUTCHR
        LDAA    TIMBUF+5 *minutes
        JSR     PR2DIG
        LDAA    #':
        JSR     PUTCHR
        LDAA    TIMBUF+6 *seconds
        JSR     PR2DIG
*
* Now convert the day-of-week value into a string
* and print it.  Re-use the logic from the
* month display.
*
        LDAA    TIMBUF+7 *day of week
        LDX     #DAYS
PR23    DECA
        BEQ     PR24
PR25    INX
        TST     0,X
        BNE     PR25
        INX
        BRA     PR23
PR24    JSR     PST     *print day name
        RTS
*
*================================================
* Print the value in A as two decimal digits
* with exactly two places.  This is used for
* printing the time, where hour, minute and
* second fields are always two digits.
*
PR2DIG  CLRB            *B is the tens
PR21    SUBA    #10
        BMI     PR22    *one too many
        INCB
        BRA     PR21    *and do again
PR22    ADDA    #10     *add back
*
* A contains ones, and B contains tens.
*
        PSHA
        TBA
        ORAA    #'0     *make ASCII
        JSR     PUTCHR
        PULA
        ORAA    #'0
        JMP     PUTCHR
*
* Text strings
*
CST     FCC     ", "
        FCB     0
*
USAGE   FCC     "USAGE: DATE MM,DD,YY"
        FCB     4
*
* Month strings
*
MONTH   FCC     'January'
        FCB     0
        FCC     'February'
        FCB     0
        FCC     'March'
        FCB     0
        FCC     'April'
        FCB     0
        FCC     'May'
        FCB     0
        FCC     'June'
        FCB     0
        FCC     'July'
        FCB     0
        FCC     'August'
        FCB     0
        FCC     'September'
        FCB     0
        FCC     'October'
        FCB     0
        FCC     'November'
        FCB     0
        FCC     'December'
        FCB     0
*
* Day strings
*
DAYS    FCC     ', Sunday, '
        FCB     0
        FCC     ', Monday, '
        FCB     0
        FCC     ', Tuesday, '
        FCB     0
        FCC     ', Wednesday, '
        FCB     0
        FCC     ', Thursday, '
        FCB     0
        FCC     ', Friday, '
        FCB     0
        FCC     ', Saturday, '
        FCB     0
*
*================================================
* Data storage
*
CLKGUD  RMB     1       *non-zero means clock data is valid
TIMBUF  RMB     8       *clock data storage
*
        END     DATE0

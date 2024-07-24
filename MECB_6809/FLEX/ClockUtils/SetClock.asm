;*****************************************************
; SetClock.asm
;
; This is a small tool to set the real time clock on
; the Corsham Technologies SD Card System.  The code
; runs with the xKIM monitor.
;
; 05/11/2021 - Bob Applegate, bob@corshamtech.com
;
		include	"xkim.inc"
		include	"parproto.inc"
;
; Common ASCII stuff
;
NULL		equ	$00
LF		equ	$0a
CR		equ	$0d
;
; KIM monitor functions
;
CRLF		equ	$1e2f
;
;*****************************************************
; The actual code.  I put it high in RAM to avoid
; using pages 2 and 3 which are commonly used.
;
		code
		org	$1000
SetClock	jsr	putsil
		db	CR,LF,LF,LF
		db	"SetClock v1, 09/17/2021",CR,LF
		db	"This is a crude utility to "
		db	"set the clock on the SD card."
		db	CR,LF,LF
		db	"It is not very tolerant of "
		db	"unexpected input data."
		db	CR,LF,LF,NULL
;
; Get the date
;
TopLoop		jsr	putsil
		db	"Enter month (1-12): ",NULL
		ldx	#1	;lowest valid month
		ldy	#12	;highest valid month
		jsr	GetDecimal
		bcs	BadInputVector
		sta	SD_Month
;
		jsr	putsil
		db	CR,LF,"Enter day of month (1-31): ",NULL
		ldx	#1	;lowest valid day of month
		ldy	#31	;highest valid day of month
		jsr	GetDecimal
		bcs	BadInputVector
		sta	SD_Day
;
		jsr	putsil
		db	CR,LF,"Enter last two digits of the year (21-90): ",NULL
		ldx	#21	;can't be before I wrote this code
		ldy	#90	;I'm an optimist
		jsr	GetDecimal
		bcc	StillGood
BadInputVector	jmp	BadInput	;resolves long branch issues
;
StillGood	sta	SD_YearLow
		lda	#20
		sta	SD_YearHigh	;force to 20xx
		jsr	putsil
		db	CR,LF,"Enter the day of the week (01 = Sunday, "
		db	"02 = Monday, 03 = Tuesday"
		db	CR,LF
		db	"04 = Wednesday, 05 = Thursday, 06 = Friday, "
		db	"07 = Saturday): ",NULL
		ldx	#1	;Sunday
		ldy	#7	;Saturday
		jsr	GetDecimal
		bcc	StillGood2
BadInputVector2	jmp	BadInput	;resolves long branch issues

StillGood2	sta	SD_DayOfWeek
		jsr	putsil
		db	CR,LF,"Enter hour (00-23): ",NULL
		ldx	#00	;lowest valid
		ldy	#23	;highest valid
		jsr	GetDecimal
		bcs	BadInputVector2
		sta	SD_Hour
;
		jsr	putsil
		db	CR,LF,"Enter minute (00-59): ",NULL
		ldx	#00	;lowest valid
		ldy	#59	;highest valid
		jsr	GetDecimal
		bcs	BadInputVector2
		sta	SD_Minute
;
		jsr	putsil
		db	CR,LF,"Enter second (00-59): ",NULL
		ldx	#00	;lowest valid
		ldy	#59	;highest valid
		jsr	GetDecimal
		bcs	BadInputVector2
		sta	SD_Second
;
; Wow, we finally have all the data!  Now confirm it is correct.
; Start by printing what the user entered.
;
		jsr	putsil
		db	CR,LF
		db	"Setting clock to ",NULL
		lda	SD_Month
		jsr	PrintDecimal
		lda	#'/'
		jsr	xkOUTCH
		lda	SD_Day
		jsr	PrintDecimal
		lda	#'/'
		jsr	xkOUTCH
		lda	#20
		jsr	PrintDecimal
		lda	SD_YearLow
		jsr	PrintDecimal
;
		lda	#' '
		jsr	xkOUTCH
;
		lda	SD_Hour
		jsr	PrintDecimal
		lda	#':'
		jsr	xkOUTCH
		lda	SD_Minute
		jsr	PrintDecimal
		lda	#':'
		jsr	xkOUTCH
		lda	SD_Second
		jsr	PrintDecimal
;
		jsr	putsil
		db	CR,LF
		db	"Is that correct (Y/N)? ",NULL
		jsr	xkGETCH
		cmp	#'Y'
		beq	SaveIt
		jsr	CRLF
		jmp	TopLoop
;
; All good, so format it and send to the SD Card System.
;
SaveIt		jsr	xParSetWrite	;turn on write mode
		lda	#PC_SET_CLOCK
		jsr	xParWriteByte	;send command
		ldx	#0		;contains offset in data
SendLoop	lda	SD_Data,x
		jsr	xParWriteByte	;send data
		inx
		cpx	#SD_DATA_SIZE
		bne	SendLoop
;
		jsr	xParSetRead	;back to read mode
		jsr	xParReadByte	;get response
		pha
		jsr	xParSetWrite	;must leave in write state
		pla
		cmp	#PR_ACK
		beq	AllGood		;yeah!
;
; Huh, got an error, so get the error code
;
		jsr	xParReadByte
		pha
		jsr	putsil
		db	CR,LF
		db	"Hmmm, there was an error code: "
		db	NULL
		pla
		jsr	PRTBYT
		jsr	CRLF
		jmp	extKim
;
; In theory the code should check for ACK/NAK here.
; PR_ACK, PR_NAK
;
AllGood		jsr	putsil
		db	CR,LF
		db	"The new date/time have been set."
		db	CR,LF,LF,NULL
;
		jmp	extKim
;
;*****************************************************
; Jump to here if the user input bad data, either
; non-decimal values or a value out of range.
;
BadInput	jsr	putsil
		db	CR,LF
		db	"Invalid key or value"
		db	CR,LF,NULL
		jmp	extKim	;return to monitor
;
;*****************************************************
; Get a decimal number from the user and compare it
; to the minimum (X) and maximum (Y) valid values.  If
; all goes well, return the value in A with C clear.
; If the user types bad data then return C set.  Is
; not very smart and will continue to get digits until
; the user presses RETURN.  No handling of overflow.
;
GetDecimal	stx	minimum
		iny
		sty	maximum
		lda	#0
		sta	number	;value to return
;
; Keep getting digits until they press RETURN.
;
GetDecLoop	jsr	xkGETCH	;get key
		cmp	#CR
		beq	GetGood
		cmp	#'0'
		bcc	GetBadKey
		cmp	#'9'+1
		bcs	GetBadKey
;
; Key is good!
;
		sec
		sbc	#'0'	;convert to binary
;
; Multiply current number by 10.
;
		pha		;save new digit
		asl	number	;*2
		lda	number
		asl	number	;*4
		asl	number	;*8
		clc
		adc	number	;*10
		sta	number
;
; Add in new digit
;
		pla
		clc
		adc	number	;add in latest key
		sta	number	;save new value
		jmp	GetDecLoop
;
; All digits entered good, now verify the value is in
; the desired range.
;
GetGood		lda	number	;get current value
		cmp	minimum
		bcc	GetBadKey	;too low
		cmp	maximum
		bcs	GetBadKey
;
		clc		;indicate no error
		rts
;
; Bad input.
;
GetBadKey	sec		;error
		rts
;
;========================================================
; Given a binary value in A, display it as two decimal
; digits.  The input can't be greater than 99.  Always
; print a leading zero if less than 10.
;
PrintDecimal	ldy	#0	;counts 10s
out1		cmp	#10
		bcc	out2	;below 10
		iny		;count 10
		sec
		sbc	#10
		jmp	out1
;
out2		pha		;save ones
		tya		;get tens
		jsr	out3	;print tens digit
		pla		;restore ones
;
out3		ora	#'0'
		jsr	xkOUTCH
		rts
;
;*****************************************************
; Non zero-page data.  There is nothing in this code
; which needs zero page, and the tiny bit of speed-up
; isn't worth wasting zero page space.
;
number		ds	1
minimum		ds	1	;lowest good value
maximum		ds	1	;highest good value + 1
;
; This is the raw clock data in the exact format used
; by the SD Card System.  Each field is binary and
; gets sent to the SD as-is... I need to fix the
; documentation for the set/get clock commands!
;
SD_Data		equ	*
SD_Month	ds	1
SD_Day		ds	1
SD_YearHigh	ds	1
SD_YearLow	ds	1
SD_Hour		ds	1
SD_Minute	ds	1
SD_Second	ds	1
SD_DayOfWeek	ds	1
SD_DATA_SIZE	equ	(*-SD_Data)
;
; Make sure we haven't exceeded RAM!
;
	if	* > $13ff
		error	Overran RAM!
	endif
;
;*****************************************************
; Set the auto-run vector so this code will run right
; after loading it.
;
		org	AutoRun
		dw	SetClock
		end




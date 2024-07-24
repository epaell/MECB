;*****************************************************
; GetClock.asm
;
; This is a small tool to get the real time clock on
; the Corsham Technologies SD Card System.  The code
; runs with the xKIM monitor.  There is a C command
; in xKIM to get the clock but this tool also displays
; the day of the week.  I needed this to test SetClock.
;
; 09/17/2021 - Bob Applegate, bob@corshamtech.com
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
; If true, print the day of the week in a numeric
; form as well.
;
PRINT_DOW_NUM	equ	1
;
;*****************************************************
; The actual code.  I put it high in RAM to avoid
; using pages 2 and 3 which are commonly used.
;
		code
		org	$1000
SetClock	jsr	putsil
		db	CR,LF,LF,LF
		db	"GetClock v1, 09/17/2021"
		db	CR,LF,NULL
;
; Set up to read the RTC
;
		jsr	xParSetWrite
		lda	#PC_GET_CLOCK
		jsr	xParWriteByte
		jsr	xParSetRead	;prepare to read
;
		jsr	xParReadByte
;
; Loop to read the raw data
;
		ldx	#0
clockread	jsr	xParReadByte
		sta	SD_Data,x
		inx
		cpx	#SD_DATA_SIZE
		bne	clockread
;
; Set back to write mode to finish up; all apps are
; supposed to leave the SD interface in write mode.
;
		jsr	xParSetWrite
;
; Display the day of the week as both a name and the
; raw binary value.
;
		ldx	SD_DayOfWeek
		dex			;zero base
		txa
		asl	a
		asl	a
		asl	a
		asl	a		;make index
		tax
;
; X contains an offset into DaysOfWeek.  Print until
; a null byte.
;
prloop		lda	DaysOfWeek,x
		beq	prdone
		stx	saveX
		jsr	xkOUTCH
		ldx	saveX
		inx
		bne	prloop
;
; Print the numeric value.  This should be taken out
; eventually but is handy for me to debug with.
;
prdone
	if	PRINT_DOW_NUM
		jsr	putsil
		db	" (",0
		lda	SD_DayOfWeek
		ora	#'0'
		jsr	xkOUTCH
		jsr	putsil
		db	")",NULL
	endif
;
; Now display the data in a user-friendly format.  Each
; numberic value is in binary, so convert to decimal
; for display.
;
		lda	#' '
		jsr	xkOUTCH
;
		lda	SD_Month
		jsr	PrintDecimal
		lda	#'/'
		jsr	xkOUTCH
		lda	SD_Day
		jsr	PrintDecimal
;
; Always force the high part of the year to "20"
;
		jsr	putsil
		db	"/20",0
		lda	SD_YearLow
		jsr	PrintDecimal
;
; Space over, then do the time
;
		jsr	putsil
		db	", ",0
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
		db	CR,LF,0
		jmp	extKim	;return to monitor
;
;*****************************************************
; Names of days of the week.  Each is null terminated
; and each entry is exactly 16 bytes long.
;
DaysOfWeek	db	"Sunday",0,0,0,0,0,0,0,0,0,0
		db	"Monday",0,0,0,0,0,0,0,0,0,0
		db	"Tuesday",0,0,0,0,0,0,0,0,0
		db	"Wednesday",0,0,0,0,0,0,0
		db	"Thursday",0,0,0,0,0,0,0,0
		db	"Friday",0,0,0,0,0,0,0,0,0,0
		db	"Saturday",0,0,0,0,0,0,0,0,0
;
;*****************************************************
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
; Non zero-page RAM.
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
saveX		ds	1
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


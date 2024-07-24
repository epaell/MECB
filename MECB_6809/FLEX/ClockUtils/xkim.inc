;=====================================================
; This file contains vectors for Corsham Technologies'
; xKIM monitor.
;
; www.corshamtech.com
;
; 05/11/2021	Bob Applegate
;		Added lots of RAM locations
;
xKIM_BASE	equ	$e000
		bss
origBss		equ	*	;SAVE BSS!!!
		org	xKIM_BASE
;
; Main functions
;
extKim		ds	3	;extended monitor
xkOUTCH		ds	3	;output A to console
xkGETCH		ds	3	;get a key and echo
xkGETCHne	ds	3	;no echo - KIM can't do it
xKIM_res_0	ds	3	;future - console stat
putsil		ds	3	;print string after JSR
getHex		ds	3	;get hex value in A
PRTBYT		ds	3	;print A as hex
getStartAddr	ds	3
getEndAddr	ds	3
getAddrRange	ds	3
;
; future use
;
;		org	xKIM_BASE+$0021
xKIM_res_1	ds	3
xKIM_res_2	ds	3
xKIM_res_3	ds	3
xKIM_res_4	ds	3
xKIM_res_5	ds	3
xKIM_res_6	ds	3
;
; SD card functions
;
;		org	xKIM_BASE+$0033
xParInit	ds	3
xParSetWrite	ds	3
xParSetRead	ds	3
xParWriteByte	ds	3
xParReadByte	ds	3
DiskPing	ds	3
DiskDir		ds	3
DiskDirNext	ds	3
DiskOpenRead	ds	3
DiskRead	ds	3
DiskClose	ds	3
DiskOpenWrite	ds	3
DiskWrite	ds	3
;
; RAM locations used by xKIM that are available for
; user access.
;
		org	$dff8
AutoRun		ds	2	;where to jump after L
ColdFlag	ds	2
ExtensionAddr	ds	2
HighestAddress	ds	2
;
; Now restore BSS!
;
		org	origBss
;
; KIM Stuff
;
NMIV		equ	$17fa	;NMI vector
IRQV		equ	$17fe	;IRQ vector



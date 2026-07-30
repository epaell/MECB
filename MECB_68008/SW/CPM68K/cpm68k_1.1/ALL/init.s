*********************************************************
*							*
*	Disk Initialization Program for CP/M-68K (tm)	*
*							*
*	Copyright Digital Research 1983			*
*							*
*********************************************************
*
*
*
prntstr	=	9	BDOS Functions
readbuf =	10
*
seldsk	=	9	BIOS Functions
settrk	=	10
setsec	=	11
setdma	=	12
write	=	14
sectran	=	16
flush	=	21
*
	.text
*
start:	link	a6,#0
	move.l	8(a6),a0	base page address
	add	#$81,a0		first character of command tail
scan:	cmpi.b	#$20,(a0)+	skip over blanks
	beq	scan
	cmpi.b	#$61,-(a0)	get disk letter
	blt	upper		upshift
	sub	#$20,(a0)
upper:	cmpi.b	#$41,(a0)	compare with range A - P
	blt	erxit
	cmpi.b	#$50,(a0)
	bgt	erxit
query:	move.b	(a0),d0		put disk letter in message
	move.b	d0,msgdskx
	ext.w	d0		put disk letter into range 0 - 15
	sub.w	#$41,d0
	move.w	d0,dsk
	move.w	#prntstr,d0	ask whether it's really ok to init
	move.l	#msgdsk,d1
	trap	#2
	move.w	#readbuf,d0	read reply
	move.l	#buf,d1
	trap	#2
	move.b	buf+2,d0	if answer isn't Y then exit
	cmpi.b	#$59,d0
	beq	doit
	cmpi.b	#$79,d0
	bne	exit
*
doit:	lea	buf,a0		init disk buffer to empty directory entries
	move.l	#$e5e5e5e5,d0
	move.w	#31,d1
bloop:	move.l	d0,(a0)+
	dbf	d1,bloop
	move.w	#setdma,d0	set up dma address for write
	move.l	#buf,d1
	trap	#3
	move.w	#seldsk,d0	select the disk
	move.w	dsk,d1
	clr.b	d2
	trap	#3
	tst.l	d0		check for select error
	beq	selerx
	move.l	d0,a0		get translate table address for sectran
	move.l	(a0),xlt
	move.l	14(a0),a0	get DPB address
	move.w	(a0),spt	get sectors per track
	move.w	8(a0),drm	get directory entry count - 1
	move.w	14(a0),trk	get starting track (=offset)
	clr.w	sect		start at sector 0
	clr.w	count		count of initialized sectors
*
dloop:	move.w	count,d0	while count <= drm ...
	cmp.w	drm,d0
	bgt	exit
	move.w	sect,d1		check for end-of-track
	cmp.w	spt,d1
	blt	sok
	clr.w	sect		advance to new track
	add.w	#1,trk
sok:	move.w	#settrk,d0	set the track
	move.w	trk,d1
	trap	#3
	move.w	#sectran,d0	do sector translate
	move.w	sect,d1
	move.l	xlt,d2
	trap	#3
	move.w	d0,d1		set sector
	move.w	#setsec,d0
	trap	#3
	move.w	#write,d0	and write
	clr.w	d1
	trap	#3
	tst.w	d0		check for write error
	bne	wrterx
	add	#1,sect		increment sector number
	add	#4,count	increment count of directory entries
	bra	dloop		and loop
*
exit:	move.w	#flush,d0	exit location - flush bios buffers
	trap	#3
	unlk	a6
	rts			and exit to CCP
*
erxit:	move.l	#erstr,d1	miscellaneous errors
erx:	move.w	#prntstr,d0	print error message and exit
	trap	#2
	bra	exit
*
selerx:	move.l	#selstr,d1	disk select error
	bra	erx
wrterx:	move.l	#wrtstr,d1	disk write error
	bra	erx
*
	.data
msgdsk:	.dc.b	'Do you really want to init disk '
msgdskx:.dc.b	'x ? $'
*
	.even
buf:	.dc.b	126,0		dual use buffer -- console input & dsk output
	.ds.b	126
*
xlt:	.ds.l	1		translate table address
spt:	.ds.w	1		sectors per track
drm:	.ds.w	1		maximum directory entry number
sect:	.ds.w	1		current sector
trk:	.ds.w	1		current track
dsk:	.ds.w	1		selected disk
count:	.ds.w	1		number of directory entries written so far
*
erstr:	.dc.b	'Error',13,10,'$'
selstr:	.dc.b	'Select Error',13,10,'$'
wrtstr:	.dc.b	'Write Error',13,10,'$'
*
copyrt:	.dc.b	'CP/M-68K(tm), Version 1.1, Copyright 1983, Digital Research'
serial:	.dc.b	'1015-0000-000436'
*
	.end

*********************************************************
*							*
*	Disk Formatting Program for CP/M-68K (tm)	*
*							*
*	Copyright Digital Research 1982			*
*							*
*********************************************************
*
*
*
prntstr	=	9
readbuf =	10
*
seldsk	=	9
settrk	=	10
setsec	=	11
setdma	=	12
write	=	14
sectran	=	16
flush	=	21
format	=	63
*
	.text
*
start:	link	a6,#0
	move.l	8(a6),a0
	add	#$81,a0
scan:	cmpi.b	#$20,(a0)+
	beq	scan
	cmpi.b	#$61,-(a0)
	blt	upper
	sub	#$20,(a0)
upper:	cmpi.b	#$41,(a0)
	blt	erxit
	cmpi.b	#$50,(a0)
	bgt	erxit
query:	move.b	(a0),d0
	move.b	d0,msgdskx
	ext.w	d0
	sub.w	#$41,d0
	move.w	d0,dsk
	move.w	#prntstr,d0
	move.l	#msgdsk,d1
	trap	#2
	move.w	#readbuf,d0
	move.l	#buf,d1
	trap	#2
	move.b	buf+2,d0
	cmpi.b	#$59,d0
	beq	doit
	cmpi.b	#$79,d0
	bne	exit
*
doit:	clr.l	d0
	clr.l	d1
*
* Select the disk to format
*
	move.w	#seldsk,d0
	move.w  dsk,d1
	clr.b	d2
	trap	#3
	tst.l	d0
	beq	selerx
	move.l	d0,a0
	move.l	(a0),xlt
	move.l	14(a0),a0
	move.w	(a0),spt
	move.w	8(a0),drm
	move.w	14(a0),trk
	clr.w	sect
	clr.w	count
*
* Call the format function
*
	move.w	#format,d0
	move.w	dsk,d1
	trap	#3
	tst.w	d0
	bne	fmterx
	lea	buf,a0
	move.l	#$e5e5e5e5,d0
	move.w	#31,d1
bloop:	move.l	d0,(a0)+
	dbf	d1,bloop
	move.w	#setdma,d0
	move.l	#buf,d1
	trap	#3
*
dloop:	move.w	count,d0
	cmp.w	drm,d0
	bgt	exit
	move.w	sect,d1
	cmp.w	spt,d1
	blt	sok
	clr.w	sect
	add.w	#1,trk
sok:	move.w	#settrk,d0
	move.w	trk,d1
	trap	#3
	move.w	#sectran,d0
	move.w	sect,d1
	move.l	xlt,d2
	trap	#3
	move.w	d0,d1
	move.w	#setsec,d0
	trap	#3
	move.w	#write,d0
	clr.w	d1
	trap	#3
	tst.w	d0
	bne	wrterx
	add	#1,sect
	add	#1,count
	bra	dloop
*
exit:	move.w	#flush,d0
	trap	#3
	unlk	a6
	rts
*
erxit:	move.l	#erstr,d1
erx:	move.w	#prntstr,d0
	trap	#2
	bra	exit
*
fmterx: move.l	#fmtstr,d1
	bra	erx
selerx:	move.l	#selstr,d1
	bra	erx
wrterx:	move.l	#wrtstr,d1
	bra	erx
*
	.data
msgdsk:	.dc.b	'Do you really want to format disk '
msgdskx:.dc.b	'x ? $'
*
	.even
buf:	.dc.b	126,0
	.ds.b	126
*
xlt:	.ds.l	1
spt:	.ds.w	1
drm:	.ds.w	1
sect:	.ds.w	1
trk:	.ds.w	1
dsk:	.ds.w	1
count:	.ds.w	1
*
fmtstr:	.dc.b	'Formatting Error',13,10,'$'
erstr:	.dc.b	'Error',13,10,'$'
selstr:	.dc.b	'Select Error',13,10,'$'
wrtstr:	.dc.b	'Write Error',13,10,'$'
*
copyrt:	.dc.b	'CP/M-68K(tm), Version 1.1, Copyright 1983, Digital Research'
serial:	.dc.b	'1015-0000-000436'
*
	.end

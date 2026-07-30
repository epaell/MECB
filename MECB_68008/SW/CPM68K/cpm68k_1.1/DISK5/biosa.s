	.text
	.globl	_init
	.globl	_biosinit
	.globl	_flush
	.globl	_wboot
	.globl	_cbios
	.globl	_dskia
	.globl	_dskic
	.globl	_setimask
	.globl	_ccp
*
*
_init:	lea	entry,a0
	move.l	a0,$8C
	lea	_dskia,a0
	move.l	a0,$3fc
	move	#$2000,sr
	jsr	_biosinit
	clr.l	d0
	rts
*
_wboot:	clr.l	d0
	jmp	_ccp
*
entry:	move.l	d2,-(a7)
	move.l	d1,-(a7)
	move.w	d0,-(a7)
	jsr	_cbios
	add	#10,a7
	rte
*
_dskia:	link	a6,#0
	movem.l	d0-d7/a0-a5,-(a7)
	jsr	_dskic
	movem.l	(a7)+,d0-d7/a0-a5
	unlk	a6
	rte
*
_setimask: move sr,d0
	lsr	#8,d0
	and.l	#7,d0
	move	sr,d1
	ror.w	#8,d1
	and.w	#$fff8,d1
	add.w	4(a7),d1
	ror.w	#8,d1
	move	d1,sr
	rts	
*
	.end

***************************************************************************
**************************** EagleRipper V1.0 *****************************
*********************** for Martin Walker modules, ************************
************************* adapted by Wanted Team **************************
***************************************************************************

	incdir	dh2:include/
	include	misc/eagleplayerripper.i
			
	RIPPERHEADER	MartinWalkerTags

	dc.b	"Martin Walker EagleRipper V1.0",10
	dc.b	"done by Wanted Team (31 Dec 1999)",0
	even

MartinWalkerTags
	dc.l	RPT_Formatname,FormatName
	dc.l	RPT_Ripp1,MartinWalkerRipp1
	dc.l	RPT_RequestRipper,1
	dc.l	RPT_Version,1<<16!0
	dc.l	RPT_Creator,Creator
	dc.l	RPT_Playername,FormatName
	dc.l	RPT_Prefix,Prefix
	dc.l	0

Creator
	dc.b	"Martin Walker, adapted by Wanted Team",0
FormatName
	dc.b	"Martin Walker",0
Prefix
	dc.b	"MW.",0
	even

*-----------------------------------------------------------------------------*
* Input: a0=Adr (start of memory)
*	 d0=Size (size of memory)
*	 a1=current adr
*	 d1=(a1.l)
* Output:d0=Error oder NULL
*	 d1=Size
*	 a0=Startadr (data)
*-----------------------------------------------------------------------------*

MartinWalkerRipp1
	lsr.l	#8,D1
	lsr.l	#8,D1
	cmp.w	#$6000,D1
	beq.b	check_1
	cmp.w	#$48E7,D1
	beq.b	check_2
	cmp.w	#$2F08,D1
	beq.b	check_3
	rts
One
	move.l	A1,A0
	move.l	#$48E7FCFE,D1
	rts
check_3
	bsr.b	One
	cmp.w	#$41FA,2(A1)
	bne.b	error
	addq.l	#4,A1
	add.w	(A1),A1
OK_3
	moveq	#28,D2
	add.l	D2,A1
	cmp.w	#$45FA,220(A1)
	bne.b	error
	bra.b	loop_1

check_2
	bsr.b	One
	cmp.l	(A1),D1
	bne.b	error
	cmp.w	#$45FA,220(A1)
	beq.b	error
	cmp.w	#$45FA,268(A1)
	beq.b	error
	cmp.w	#$E942,274(A1)
	beq.b	error
	bra.b	loop_1
check_1
	bsr.b	One
	move.w	#$6000,D0
	cmp.w	4(A1),D0
	bne.b	error
	cmp.w	8(A1),D0
	bne.b	error
	cmp.w	12(A1),D0
	bne.b	error
	cmp.w	16(A1),D0
	bne.b	error
	cmp.w	20(A1),D0
	bne.b	error
	cmp.w	24(A1),D0
	bne.b	error
	cmp.w	28(A1),D0
	bne.b	error
	cmp.w	32(A1),D0
	bne.b	NextCheck
	cmp.w	36(A1),D0
	beq.b	NextCheck
error
	moveq	#-1,D0
	rts

loop_2
	cmp.w	#$45FA,268(A1)
	beq.b	loop_1
	cmp.w	#$E942,274(A1)
	bne.b	error
loop_1
	addq.l	#4,A1
	cmp.l	#$E9417000,(A1)+
	bne.b	error
	cmp.w	#$41FA,(A1)
	bne.b	error
	cmp.l	140(A1),D1
	beq.b	OK1
	cmp.l	156(A1),D1
	beq.b	OK1
	cmp.l	160(A1),D1
	bne.b	error
	bra.b	OK1

NextCheck
	addq.l	#8,A1
	addq.l	#6,A1
	move.l	A1,A2
	add.w	(A1),A1
	cmp.l	(A1),D1
	beq.b	loop_2
	addq.l	#8,A2
	addq.l	#4,A2
	add.w	(A2),A2
	cmp.l	(A2)+,D1		; 5th format
	bne.b	error
	cmp.w	#$43FA,(A2)
	bne.b	error
OK1
	cmp.l	#$2A325000,(A1)
	beq.b	Later
	tst.l	(A1)
	beq.b	error
	addq.l	#2,A1
	bra.b	OK1
Later
	move.l	A1,A2
	subq.l	#2,A2
	add.w	(A2),A2
	moveq	#31,D0
FindMax
	move.l	(A2)+,D1
	move.l	(A2),D2
	cmp.l	D1,D2
	ble.b	MaxLength
	and.l	#$FFF00000,D2
	tst.l	D2
	bne.b	MaxLength
	dbf	D0,FindMax
MaxLength
	addq.l	#6,A1
	add.w	(A1),A1
	add.l	D1,A1
	sub.l	A0,A1
	move.l	A1,D1
	btst	#0,D1
	beq.b	OK2
	addq.l	#1,D1
OK2
	addq.l	#1,D1
	moveq	#0,D0
	rts

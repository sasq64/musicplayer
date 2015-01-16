***************************************************************************
**************************** EagleRipper V1.0 *****************************
*********************** for Dave Lowe New modules, ************************
************************* adapted by Wanted Team **************************
***************************************************************************

	incdir	dh2:include/
	include	misc/eagleplayerripper.i
			
	RIPPERHEADER	DaveLoweNewTags

	dc.b	"Dave Lowe New EagleRipper V1.0",10
	dc.b	"done by Wanted Team (22 Aug 2000)",0
	even

DaveLoweNewTags
	dc.l	RPT_Formatname,Formatname
	dc.l	RPT_Ripp1,DaveLoweNewRipp1
	dc.l	RPT_RequestRipper,1
	dc.l	RPT_Version,1<<16!0
	dc.l	RPT_Creator,Creator
	dc.l	RPT_Playername,Formatname
	dc.l	RPT_Prefix,Prefix
	dc.l	0
Creator
	dc.b	"Dave Lowe, adapted by Wanted Team",0
Formatname
	dc.b	"Dave Lowe New",0
Prefix
	dc.b	"DLN.",0
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

DaveLoweNewRipp1
	lsr.l	#8,D1
	lsr.l	#8,D1
	move.l	A1,A0
	cmp.w	#8,D1
	beq.b	Check_1
	cmp.w	#4,D1
	beq.b	check_2
	rts
check_2
	tst.l	24(A1)
	bne.b	Later1
Check_1
	addq.l	#4,A1
Later1
	addq.l	#4,A1
	moveq	#3,D2
	move.l	A1,A2
FirstCheck
	tst.w	(A1)+
	bne.b	fail
	move.w	(A1)+,D1
	bmi.b	fail
	beq.b	fail
	btst	#0,D1
	bne.b	fail
	dbf	D2,FirstCheck
	moveq	#3,D0
SecondCheck
	move.l	(A2)+,D1
	lea	0(A0,D1.L),A1
	move.l	(A1),D2
	tst.w	(A1)+
	bne.b	fail
	move.w	(A1)+,D1
	bmi.b	fail
	beq.b	fail
	btst	#0,D1
	bne.b	fail
	lea	0(A0,D2.L),A1
	cmp.w	#$30,(A1)
	bne.b	Standard
	addq.l	#2,A1
Standard
	cmp.w	#12,(A1)
	bne.b	NextLong
	addq.l	#6,A1
	cmp.w	#4,(A1)+
	beq.b	Found
NextLong
	dbf	D0,SecondCheck
fail
	moveq	#-1,D0
	rts
Found
	move.l	(A1),D2
	lea	0(A0,D2.L),A1
	cmp.w	#1,(A1)
	bne.b	fail
FindFirst
	move.l	A1,A2
	subq.l	#6,A1
	subq.l	#8,A1
	cmp.w	#1,(A1)
	beq.b	FindFirst
	cmp.w	#8,-2(A2)
	beq.b	InfoOK
	tst.w	-2(A2)
	beq.b	InfoOK
	lea	14(A2),A2
InfoOK
	moveq	#0,D1
CheckInfo
	cmp.w	#1,(A2)+
	bne.b	Last
	move.l	(A2)+,D2
	addq.l	#2,A2
	cmp.l	(A2),D2
	bge.b	NoMax
	move.l	(A2),D2
NoMax
	cmp.l	D2,D1
	bge.b	Next1
	move.l	D2,D1
Next1
	addq.l	#6,A2
	bra.b	CheckInfo
Last
	moveq	#127,D0
	add.l	D0,D0
	add.l	D0,D1
	moveq	#0,D0
	rts

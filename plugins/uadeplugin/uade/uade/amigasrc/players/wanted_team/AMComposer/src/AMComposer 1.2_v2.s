***************************************************************************
**************************** EagleRipper V1.1 *****************************
******************** for A. M. Composer V1.2 modules **********************
************************* adapted by Wanted Team **************************
***************************************************************************

	incdir	dh2:include/
	include	misc/eagleplayerripper.i
			
	RIPPERHEADER	AMCTags

	dc.b	"A.M.Composer v1.2 EagleRipper V1.1",10
	dc.b	"done by Wanted Team (20 Oct 2001)",0
	even

AMCTags
	dc.l	RPT_Formatname,Formatname
	dc.l	RPT_Ripp1,AMCRipp1
	dc.l	RPT_RequestRipper,1
	dc.l	RPT_Version,1<<16!1
	dc.l	RPT_Creator,Creator
	dc.l	RPT_Playername,Playername
	dc.l	RPT_Prefix,Prefix
	dc.l	0

Creator
	dc.b	"Marc Hawlitzeck, adapted by Wanted Team",0
Formatname
	dc.b	"A.M.Composer v1.2",0
Playername
	dc.b	"AMComposer 1.2",0
Prefix
	dc.b	"AMC.",0
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

AMCRipp1
	cmp.l	#'AMC ',D1
	beq.b	OK
	rts
OK
	move.l	A1,A0
	addq.l	#4,A1
	cmp.l	#'V1.2',(A1)+
	bne.s	Fault

	cmp.l	#' REP',(A1)+
	bne.s	Fault

	cmp.l	#'LAY!',(A1)+
	bne.s	Fault
	addq.l	#8,A1
	tst.w	(A1)
	bne.s	Fault
	move.l	(A1),D1
	lea	(A0,D1.L),A2

	moveq	#0,D1
	lea	72(A0),A1
GetSize
	move.l	(A1)+,D2
	moveq	#0,D0
	move.w	(A1),D0
	add.l	D0,D0
	add.l	D0,D2
	cmp.l	D2,D1
	bge.b	MaxSize
	move.l	D2,D1
MaxSize
	lea	12(A1),A1
	cmp.l	A1,A2
	bne.b	GetSize

	lea	(A0,D1.L),A1
	cmp.b	#$20,39(A1)
	bne.b	Skip
	moveq	#62,D0
	add.l	D0,D1
Skip
	moveq	#0,D0
	rts
Fault
	moveq	#-1,D0
	rts

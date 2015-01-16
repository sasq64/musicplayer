***************************************************************************
*************************** EagleRipper V1.0 ******************************
********************** for Steve Barrett modules, *************************
************************* adapted by Wanted Team **************************
***************************************************************************

	incdir	dh2:include/
	include	misc/eagleplayerripper.i
			
	RIPPERHEADER	SteveBarrettTags

	dc.b	"Steve Barrett EagleRipper V1.0",10
	dc.b	"done by Wanted Team (1 Jan 2001)",0
	even

SteveBarrettTags
	dc.l	RPT_Formatname,Formatname
	dc.l	RPT_Ripp1,SteveBarrettRipp1
	dc.l	RPT_RequestRipper,1
	dc.l	RPT_Version,1<<16!0
	dc.l	RPT_Creator,Creator
	dc.l	RPT_Playername,Formatname
	dc.l	RPT_Prefix,Prefix
	dc.l	0

Creator		dc.b	"Steve Barrett & Wally Beben, adapted by Wanted Team",0
Formatname	dc.b	"Steve Barrett",0
Prefix		dc.b	"SB.",0
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

SteveBarrettRipp1
	lsr.l	#8,D1
	lsr.l	#8,D1
	cmp.w	#$6000,D1
	beq.s	check
	rts
check
	move.l	A1,A0
	moveq	#3,D1
NextBranch
	cmp.w	#$6000,(A1)+
	bne.b	Fault
	move.w	(A1)+,D2
	btst	#0,D2
	bne.b	Fault
	dbf	D1,NextBranch
	lea	(A1,D2.W),A1
	cmp.w	#$2A7C,(A1)+
	bne.b	Fault
	cmp.l	#$00DFF0A8,(A1)
	bne.b	Fault
	move.l	A0,A1
FindIt0
	cmp.w	#$41FA,(A1)+
	bne.b	FindIt0
	add.w	(A1),A1
	cmp.l	#'FORM',(A1)
	bne.b	Fault
	moveq	#104,D1
NextSample
	cmp.l	#'FORM',(A1)
	bne.b	LastSample
	add.l	100(A1),A1
	add.l	D1,A1
	bra.b	NextSample
LastSample
	move.l	A1,D1
	addq.l	#4,D1
	sub.l	A0,D1
	moveq	#0,D0
	rts
Fault
	moveq	#-1,D0
	rts

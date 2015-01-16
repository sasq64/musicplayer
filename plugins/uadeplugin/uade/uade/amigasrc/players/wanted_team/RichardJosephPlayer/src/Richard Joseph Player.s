***************************************************************************
**************************** EagleRipper V1.0 *****************************
******************* for Richard Joseph Player modules, ********************
************************* adapted by Wanted Team **************************
***************************************************************************

	incdir	dh2:include/
	include	misc/eagleplayerripper.i
	include	misc/eagleplayer2.01.i
			
	RIPPERHEADER	RJPTags

	dc.b	"Richard Joseph Player EagleRipper V1.0",10
	dc.b	"done by Wanted Team (22 Dec 1999)",0
	even

RJPTags
	dc.l	RPT_Formatname,Formatname
	dc.l	RPT_Ripp1,DaveLoweRipp1
	dc.l	RPT_RequestRipper,1
	dc.l	RPT_Version,1<<16!0
	dc.l	RPT_Creator,Creator
	dc.l	RPT_Playername,Formatname
	dc.l	RPT_Prefix,Prefix
	dc.l	RPT_ExtRipp,ExtRipp
	dc.l	RPT_EagleBase,EagleBase
	dc.l	RPT_ExtSave,Special
	dc.l	0

Creator
	dc.b	"Richard Joseph and Andi Smithers, adapted by Wanted Team",0
Formatname
	dc.b	"Richard Joseph Player",0
Prefix
	dc.b	"RJP.",0
		even
EagleBase
	dc.l	0

*-----------------------------------------------------------------------------*
* Input: a0=Adr (start of memory)
*	 d0=Size (size of memory)
*	 a1=current adr
*	 d1=(a1.l)
* Output:d0=Error oder NULL
*	 d1=Size
*	 a0=Startadr (data)
*-----------------------------------------------------------------------------*

DaveLoweRipp1
	and.l	#$FFFFFF00,D1
	cmp.l	#$524A5000,D1
	beq.b	check
	rts
check
	lea	StartMemory(PC),A2
	move.l	A0,(A2)+
	move.l	D0,(A2)
	move.l	A1,A0
	cmp.l	#'SMOD',4(A1)
	bne.b	error
	tst.l	12(A1)				; check init module
	bne.b	error
	addq.l	#8,A1
	move.l	(A1),D1
	lsr.l	#5,D1				; D1 = number of samples
	subq.l	#1,D1
	addq.l	#4,A1
	sub.l	A2,A2
FindMax
	moveq	#0,D2
	move.w	18(A1),D2
	add.w	16(A1),D2
	lsl.l	#1,D2
	add.l	(A1),D2
	moveq	#0,D0
	move.w	26(A1),D0
	lsl.l	#1,D0
	add.l	4(A1),D0
	cmp.l	D0,D2
	bge.b	OKi
	move.l	D0,D2
OKi
	cmp.l	D2,A2
	bge.b	Max
	move.l	D2,A2
Max
	lea	32(A1),A1
	dbf	D1,FindMax
	addq.l	#4,A2
	lea	SamplesLength(PC),A1
	move.l	A2,(A1)
	move.l	A0,A1
	addq.l	#8,A1
	moveq	#6,D1
NextLong
	add.l	(A1)+,A1
	dbf	D1,NextLong
	sub.l	A0,A1
	move.l	A1,D1
	moveq	#0,D0
	rts

ExtRipp
	move.l	EagleBase(PC),A5
	move.l	StartMemory(PC),A0
	move.l	SizeMemory(PC),D1
NextWord
	move.l	(A0),D0
	and.l	#$FFFFFF00,D0
	cmp.l	#$524A5000,D0
	beq.b	FindHeader
NotThis
	addq.l	#2,A0
	subq.l	#2,D1
	bgt.b	NextWord
error
	moveq	#-1,D0
	rts
FindHeader
	tst.w	4(A0)
	bne.b	NotThis
	lea	SamplesAddress(PC),A1
	move.l	A0,(A1)
	move.l	SamplesLength(PC),D0
	moveq	#0,D1
	sub.l	A1,A1
	jsr	ENPP_SetListData(A5)
	move.l	D0,D1
	moveq	#0,D0
	rts

SamplesAddress
	dc.l	0
SamplesLength
	dc.l	0
StartMemory
	dc.l	0
SizeMemory
	dc.l	0
Special
	move.l	EagleBase(PC),A5
	move.l	A1,EPG_ARG3(A5)
	move.l	A1,A0
	jsr	ENPP_CalcStringSize(A5)
	lea	0(A0,D0.W),A1
	lea	SamplesPrefix(PC),A0
	moveq	#32,D1
	jsr	ENPP_StringCopy(A5)
	lea	4(A2),A0
	jsr	ENPP_StringCopy(A5)
	bsr.w	ExtRipp
	bne.b	Exit
	move.l	SamplesAddress(PC),EPG_ARG1(A5)
	move.l	SamplesLength(PC),EPG_ARG2(A5)
	moveq	#-1,D0
	move.l	D0,EPG_ARG4(A5)
	moveq	#7,D0
	move.l	D0,EPG_ARG5(A5)
	moveq	#5,D0
	move.l	D0,EPG_ARGN(A5)
	move.l	EPG_SaveMem(A5),A0
	jsr	(A0)
Exit
	rts

SamplesPrefix
	dc.b	'SMP.'
	dc.w	0
	end

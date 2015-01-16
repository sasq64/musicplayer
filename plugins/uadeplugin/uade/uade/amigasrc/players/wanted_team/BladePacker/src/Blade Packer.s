***************************************************************************
**************************** EagleRipper V1.0 *****************************
*********************** for Blade Packer modules, *************************
************************* adapted by Wanted Team **************************
***************************************************************************

	incdir	dh2:include/
	include	misc/eagleplayerripper.i
	include	misc/eagleplayer2.01.i
			
	RIPPERHEADER	BPTags

	dc.b	"Blade Packer EagleRipper V1.0",10
	dc.b	"done by Wanted Team (8 Nov 2002)",0
	even

BPTags
	dc.l	RPT_Formatname,Formatname
	dc.l	RPT_Ripp1,BladePackerRipp1
	dc.l	RPT_RequestRipper,1
	dc.l	RPT_Version,1<<16!0
	dc.l	RPT_Creator,Creator
	dc.l	RPT_Playername,Formatname
	dc.l	RPT_Prefix,Prefix
	dc.l	RPT_ExtRipp,ExtRipp
	dc.l	RPT_EagleBase,EagleBase
	dc.l	RPT_ExtSave,ExtSave
	dc.l	0

Creator
	dc.b	"Tord 'Blade' Jansson, adapted by Wanted Team",0
Formatname
	dc.b	"Blade Packer",0
Prefix
	dc.b	"UDS.",0
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

BladePackerRipp1
	cmp.l	#$538F4E47,D1
	beq.b	check
	rts
check
	cmp.b	#$2E,4(A1)
	bne.b	error
	lea	StartMemory(PC),A2
	move.l	A0,(A2)+
	move.l	D0,(A2)
	lea	(A0,D0.L),A2
	move.l	A1,A0
FindIt1
	cmp.w	#$DD48,(A1)
	beq.b	OK1
	addq.l	#2,A1
	cmp.l	A1,A2
	blt.b	error
	bra.b	FindIt1
OK1
	addq.l	#2,A1
	moveq	#0,D0
FindIt2
	cmp.w	#$D8F1,(A1)
	beq.b	OK2
	cmp.b	#$42,5(A0)
	bne.b	NoShort
	cmp.b	(A1),D0
	bhi.b	NoMax1
	move.b	(A1),D0
NoMax1
	cmp.b	1(A1),D0
	bhi.b	NoMax
	move.b	1(A1),D0
	bra.b	NoMax
NoShort
	cmp.w	(A1),D0
	bhi.b	NoMax
	move.w	(A1),D0
NoMax
	addq.l	#2,A1
	cmp.l	A1,A2
	blt.b	error
	bra.b	FindIt2
OK2
	addq.l	#2,A1
	addq.l	#1,D0
	lsl.l	#2,D0
	add.l	D0,A1
	cmp.l	A1,A2
	blt.b	error
	sub.l	A0,A1
	move.l	A1,D1
	moveq	#0,D0
	rts

ExtRipp
	move.l	EagleBase(PC),A5
	move.l	StartMemory(PC),A0
	move.l	SizeMemory(PC),D1
NextWord
	cmp.l	#'SPLS',(A0)
	beq.b	GetSize
NotThis
	addq.l	#2,A0
	subq.l	#2,D1
	bgt.b	NextWord
error
	moveq	#-1,D0
	rts
GetSize
	lea	4(A0),A1
	move.l	(A1),D2
	lsr.l	#4,D2
	subq.l	#1,D2
	moveq	#0,D0
NextInfo
	move.l	(A1)+,D1
	move.l	(A1),A2
	sub.l	(A1)+,D1
	beq.b	MaxLen
	cmp.l	A2,D0
	bge.b	MaxLen
	move.l	A2,D0
MaxLen
	addq.l	#8,A1
	dbf	D2,NextInfo
	lea	SamplesAddress(PC),A1
	move.l	A0,(A1)+
	move.l	D0,(A1)
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
ExtSave
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

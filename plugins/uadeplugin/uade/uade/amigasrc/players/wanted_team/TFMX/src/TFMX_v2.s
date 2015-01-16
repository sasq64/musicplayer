***************************************************************************
**************************** EagleRipper V1.1 *****************************
******************** for TFMX (all formats) modules, **********************
************************* adapted by Wanted Team **************************
***************************************************************************

	incdir	dh2:include/
	include	misc/eagleplayerripper.i
	include	misc/eagleplayer2.01.i
			
	RIPPERHEADER	TFMXTags

	dc.b	"TFMX (all formats) EagleRipper V1.1",10
	dc.b	"done by Wanted Team (16 Jan 2002)",0
	even

TFMXTags
	dc.l	RPT_Formatname,Formatname
	dc.l	RPT_Ripp1,TFMXRipp1
	dc.l	RPT_Ripp2,TFMXRipp2
	dc.l	RPT_RequestRipper,1
	dc.l	RPT_Version,1<<16!1
	dc.l	RPT_Creator,Creator
	dc.l	RPT_Playername,Playername
	dc.l	RPT_Prefix,Prefix
	dc.l	RPT_ExtRipp,ExtRipp
	dc.l	RPT_EagleBase,EagleBase
	dc.l	RPT_ExtSave,ExtSave
	dc.l	0

Creator
	dc.b	"Chris Huelsbeck, adapted by Wanted Team",0
Formatname
	dc.b	"TFMX",0
Playername
	dc.b	"unknown TFMX",0
Prefix
	dc.b	'MDAT.',0
SamplesPrefix
	dc.b	'SMPL.',0
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

TFMXRipp2
	cmp.l	#'-SON',D1
	beq.b	check3
	cmp.l	#$00000200,D1
	beq.b	check4
TFMXRipp1
	cmp.l	#'TFMX',D1
	beq.b	check1
	cmp.l	#'tfmx',D1
	beq.b	check2
	rts
check4
	moveq	#3,D2
ZeroTest
	tst.l	-(A1)
	bne.w	error
	dbf	D2,ZeroTest
	sub.w	#436,A1
	bra.b	Patch2
check3
	tst.l	-4(A1)
	beq.b	Patch1
	rts
Patch2
	move.l	#$47200001,-(A1)
	move.l	#'-SON',-(A1)
Patch1
	move.l	#'TFMX',-(A1)
	bra.b	checkit
check2
	cmp.l	#'song',4(A1)
	bne.w	error
	tst.w	8(A1)
	bne.w	error
	bra.b	RockMe
check1
	cmp.w	#$2000,4(A1)
	beq.b	RockMe
	cmp.l	#'-SON',4(A1)
	bne.w	error
checkit
	cmp.w	#'G ',8(A1)
	bne.b	error
RockMe
	lea	StartMemory(PC),A2
	move.l	A0,(A2)+
	move.l	D0,(A2)
	move.l	A1,A0
	tst.w	464(A1)
	bne.b	error
	move.w	466(A1),D1
	beq.b	Unpacked
	bmi.b	error
	btst	#0,D1
	bne.b	error
	tst.w	468(A1)
	bne.b	error
	move.w	470(A1),D1
	bmi.b	error
	btst	#0,D1
	bne.b	error
	lea	(A0,D1.W),A2
FindStop1
	cmp.l	#$07000000,-(A2)
	bne.b	FindStop1
	move.l	A2,D2
FindStop2
	cmp.l	#'    ',(A2)
	beq.b	OneMacro
	cmp.l	#$07000000,-(A2)
	bne.b	FindStop2
back2
	addq.l	#4,A2
	sub.l	A0,A2
	tst.w	472(A1)
	bne.b	error
	move.w	474(A1),D1
	bmi.b	error
	btst	#0,D1
	bne.b	error
	lea	(A0,D1.W),A1
	add.l	A0,D0
	moveq	#-1,D2
NextLong
	addq.l	#1,D2				; used macros
	move.l	(A1)+,D1
	beq.b	error
	bmi.b	error
	cmp.l	D1,A2
	beq.b	EndLong
	cmp.l	A1,D0
	bgt.b	NextLong
error
	moveq	#-1,D0
	rts
OneMacro
	move.l	D2,A2
FindStop3
	tst.b	(A2)
	bmi.b	back2
	subq.l	#4,A2
	bra.b	FindStop3

Unpacked
	tst.l	468(A1)
	bne.b	error
	tst.l	472(A1)
	bne.b	error
	tst.w	2044(A1)
	bne.b	error
	move.w	2046(A1),D1
	bmi.b	error
	btst	#0,D1
	bne.b	error
	lea	(A1,D1.W),A1
	move.l	A0,A2
	add.l	D0,A2
FindStopMacro
	cmp.l	#$07000000,(A1)+
	beq.b	LastMacro
	cmp.l	A1,A2
	bgt.b	FindStopMacro
	bra.b	error
EndLong
	move.l	A0,A2
	add.l	472(A0),A2
	bra.b	SkipOld
LastMacro
	lea	1536(A0),A2
	moveq	#127,D2
SkipOld					; calculate length of samples
	sub.l	A0,A1
	move.l	A1,D1			; mdat length
	movem.l	D3/D4,-(SP)
	moveq	#0,D3
NextMacro
	move.l	(A2)+,D0
	lea	(A0,D0.L),A1
FindSample
	cmp.b	#$02,(A1)		; normal
	beq.b	SampleFound
	cmp.b	#$22,(A1)		; synth
	beq.b	SampleFound
	cmp.l	#$07000000,(A1)+
	beq.b	CheckMacro
	bra.b	FindSample
SampleFound
	move.l	(A1),D0
	and.l	#$00FFFFFF,D0
	addq.l	#6,A1
	moveq	#0,D4
	move.w	(A1)+,D4
	lsl.l	#1,D4
	add.l	D4,D0
	cmp.l	D0,D3
	bgt.b	CheckMore
	move.l	D0,D3				; samples length
CheckMore
	bra.b	FindSample
CheckMacro
	dbf	D2,NextMacro
	lea	SamplesLength(PC),A2
	move.l	D3,(A2)+
	movem.l	(SP)+,D3/D4
	move.l	A0,(A2)				; mdat address
	moveq	#0,D0
	rts
FindNext
	move.l	A2,A0
	moveq	#126,D1
	sub.l	D1,D2
	bra.b	NextWord
ExtRipp
	move.l	SamplesLength(PC),D0
	beq.b	NoSample
	move.l	StartMemory(PC),A0
	move.l	A0,A1
	move.l	SizeMemory(PC),D2
NextWord
	cmp.l	#$06AE064E,(A0)			; TFMX player table
	beq.b	FindRTS
NotThis
	addq.l	#2,A0
	subq.l	#2,D2
	bgt.b	NextWord
NoSample
	moveq	#-1,D0
	rts
FindRTS
	lea	126(A0),A2
FindBase
	cmp.w	#$4E75,(A0)
	beq.b	OK1
	cmp.w	#$4E73,(A0)			; Turrican intro
	beq.b	OK1
	cmp.w	#$4EF9,(A0)			; Circus Attractions
	beq.b	OK2
	cmp.l	#'eld0',(A0)			; TFMX 1.0
	beq.b	OK3
	subq.l	#2,A0
	cmp.l	A0,A1
	beq.b	FindNext
	bra.b	FindBase
OK2
	addq.l	#2,A0
OK3
	addq.l	#2,A0
OK1
	addq.l	#2,A0
	move.l	(A0)+,D1			; mdat base
	beq.b	FindNext
	btst	#0,D1
	bne.b	NoSample
	cmp.l	#$200000,D1			; mdat out of Chip RAM
	bgt.b	NoSample
	move.l	(A0),D2				; smpl base
	beq.b	NoSample
	btst	#0,D2
	bne.b	NoSample
	sub.l	D1,D2
	add.l	DataAddress(PC),D2
	move.l	D2,A0
	lea	SamplesAddress(PC),A1
	move.l	A0,(A1)
	moveq	#0,D1
	sub.l	A1,A1
	move.l	EagleBase(PC),A5
	jsr	ENPP_SetListData(A5)
	move.l	D0,D1
	moveq	#0,D0
	rts

SamplesAddress
	dc.l	0
SamplesLength
	dc.l	0
DataAddress
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
	lea	5(A2),A0
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

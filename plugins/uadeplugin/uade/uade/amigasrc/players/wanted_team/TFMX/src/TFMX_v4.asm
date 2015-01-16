	*****************************************************
	****        TFMX replayer for EaglePlayer, 	 ****
	****	     all adaptions by Wanted Team	 ****
	****      DeliTracker compatible (?) version	 ****
	*****************************************************

	incdir	"dh2:include/"
	include 'misc/eagleplayer2.01.i'
	include 'hardware/intbits.i'
	include 'exec/exec_lib.i'

	SECTION	Player_Code,CODE

	PLAYERHEADER Tags

	dc.b	'$VER: TFMX player module V1.3 (9 Feb 2002)',0
	even
Tags
	dc.l	DTP_PlayerVersion,4
	dc.l	EP_PlayerVersion,9
	dc.l	DTP_RequestDTVersion,DELIVERSION
	dc.l	DTP_PlayerName,PlayerName
	dc.l	DTP_Creator,Creator
	dc.l	DTP_Check2,Check2
	dc.l	DTP_ExtLoad,ExtLoad
	dc.l	DTP_SubSongRange,SubSongRange
	dc.l	DTP_InitPlayer,InitPlayer
	dc.l	DTP_EndPlayer,EndPlayer
	dc.l	DTP_InitSound,InitSound
	dc.l	DTP_EndSound,EndSound
	dc.l	DTP_Interrupt,Interrupt
	dc.l	DTP_Volume,SetVolume
	dc.l	DTP_Balance,SetBalance
	dc.l	EP_Voices,SetVoices
	dc.l	EP_Get_ModuleInfo,GetInfos
	dc.l	EP_StructInit,StructInit
	dc.l	EP_GetPositionNr,GetPosition
	dc.l	EP_SampleInit,SampleInit
	dc.l	EP_Save,Save
	dc.l	DTP_NextPatt,Next_Pattern
	dc.l	DTP_PrevPatt,BackPattern
	dc.l	EP_Flags,EPB_Volume!EPB_Balance!EPB_ModuleInfo!EPB_LoadFast!EPB_Voices!EPB_SampleInfo!EPB_Save!EPB_PrevPatt!EPB_NextPatt!EPB_Songend!EPB_Analyzer!EPB_NextSong!EPB_PrevSong!EPB_Packable!EPB_Restart
	dc.l	DTP_DeliBase,DeliBase
	dc.l	EP_EagleBase,Eagle2Base
	dc.l	0

PlayerName
	dc.b	'TFMX',0
Creator
	dc.b	'(c) 1988-90 by Chris Hülsbeck,',10
	dc.b	'adapted by Wanted Team',0
TFMXmdat
	dc.b	'mdat.',0
TFMXsmpl
	dc.b	'smpl.',0
SampleName
	dc.b	'SMPL.set',0
	even
DeliBase
	dc.l	0
Eagle2Base
	dc.l	0
ModulePtr
	dc.l	0
SamplePtr
	dc.l	0
SampleLen
	dc.l	0
EagleBase
	dc.l	0
UsedTiming
	dc.w	0
RightVolume
	dc.w	64
LeftVolume
	dc.w	64
Voice1
	dc.w	-1
Voice2
	dc.w	-1
Voice3
	dc.w	-1
Voice4
	dc.w	-1
StructAdr
	ds.b	UPS_SizeOF

***************************************************************************
***************************** DTP_EndSound ********************************
***************************************************************************

EndSound
	bsr.w	ClearAudioVector
	bra.w	ALLOFF

***************************************************************************
***************************** DTP_Interrupt *******************************
***************************************************************************

Interrupt
	movem.l	D1-D7/A0-A6,-(A7)

	lea	StructAdr(PC),A2
	st	UPS_Enabled(A2)
	clr.w	UPS_Voice1Per(A2)
	clr.w	UPS_Voice2Per(A2)
	clr.w	UPS_Voice3Per(A2)
	clr.w	UPS_Voice4Per(A2)
	move.w	#UPSB_Adr!UPSB_Len!UPSB_Per!UPSB_Vol,UPS_Flags(A2)

	lea	lbL0012D0(PC),A0
	cmp.b	#-1,$48(A0)
	bne.b	Play
	addq.l	#4,A0
	cmp.b	#-1,$48(A0)
	bne.b	Play
	addq.l	#4,A0
	cmp.b	#-1,$48(A0)
	bne.b	Play
	addq.l	#4,A0
	cmp.b	#-1,$48(A0)
	bne.b	Play
	addq.l	#4,A0
	cmp.b	#-1,$48(A0)
	bne.b	Play
	addq.l	#4,A0
	cmp.b	#-1,$48(A0)
	bne.b	Play
	addq.l	#4,A0
	cmp.b	#-1,$48(A0)
	bne.b	Play
	addq.l	#4,A0
	cmp.b	#-1,$48(A0)
	bne.b	Play

	move.l	EagleBase(PC),A5
	move.l	dtg_SongEnd(A5),A1
	jsr	(A1)
Play
	bsr.w	IRQIN

	lea	StructAdr(PC),A2
	clr.w	UPS_Enabled(A2)

	movem.l	(A7)+,D1-D7/A0-A6
	moveq	#0,D0
	rts

SongEnd
	movem.l	A1/A5,-(A7)
	move.l	EagleBase(PC),A5
	move.l	dtg_SongEnd(A5),A1
	jsr	(A1)
	movem.l	(A7)+,A1/A5
	rts

DMAWait
	movem.l	D0/D1,-(SP)
	moveq	#8,D0
.dma1	move.b	$DFF006,D1
.dma2	cmp.b	$DFF006,D1
	beq.b	.dma2
	dbeq	D0,.dma1
	movem.l	(SP)+,D0/D1
	rts

SetAudioVector
	movem.l	D0/A1/A6,-(A7)
	movea.l	4.W,A6
	lea	StructInt(PC),A1
	moveq	#INTB_AUD0,D0
	jsr	_LVOSetIntVector(A6)		; SetIntVector
	move.l	D0,Channel0
	lea	StructInt(PC),A1
	moveq	#INTB_AUD1,D0
	jsr	_LVOSetIntVector(A6)
	move.l	D0,Channel1
	lea	StructInt(PC),A1
	moveq	#INTB_AUD2,D0
	jsr	_LVOSetIntVector(A6)
	move.l	D0,Channel2
	lea	StructInt(PC),A1
	moveq	#INTB_AUD3,D0
	jsr	_LVOSetIntVector(A6)
	move.l	D0,Channel3
	movem.l	(A7)+,D0/A1/A6
	rts

ClearAudioVector
	movea.l	4.W,A6
	movea.l	Channel0(PC),A1
	moveq	#INTB_AUD0,D0
	jsr	_LVOSetIntVector(A6)
	movea.l	Channel1(PC),A1
	moveq	#INTB_AUD1,D0
	jsr	_LVOSetIntVector(A6)
	movea.l	Channel2(PC),A1
	moveq	#INTB_AUD2,D0
	jsr	_LVOSetIntVector(A6)
	movea.l	Channel3(PC),A1
	moveq	#INTB_AUD3,D0
	jmp	_LVOSetIntVector(A6)

Channel0
	dc.l	0
Channel1
	dc.l	0
Channel2
	dc.l	0
Channel3
	dc.l	0
StructInt
	dc.l	0
	dc.l	0
	dc.w	$205
	dc.l	IntName
	dc.l	0
	dc.l	lbC00079C
IntName
	dc.b	'TFMX Audio Interrupt',0,0
	even

***************************************************************************
******************************* DTP_NextPatt ******************************
***************************************************************************

Next_Pattern
	move.l	dtg_StopInt(A5),A0
	jsr	(A0)
	lea	lbL001102(PC),A6
	lea	lbL0012D0(PC),A5
	move.l	(A6),A4
	bsr.w	StopTrax
	bsr.w	NextStep
	move.l	EagleBase(PC),A5
	move.l	dtg_StartInt(A5),A0
	jsr	(A0)
	rts

StopTrax
	move.l	A5,A0
	moveq	#7,D0
StopLoop
	st	$48(A0)
	addq.l	#4,A0
	dbf	D0,StopLoop
	rts

***************************************************************************
******************************* DTP_BackPatt ******************************
***************************************************************************

BackPattern
	move.l	dtg_StopInt(A5),A0
	jsr	(A0)
	lea	lbL001102(PC),A6
	lea	lbL0012D0(PC),A5
	move.l	(A6),A4
	bsr.w	StopTrax
	move.w	4(A5),D0
	subq.w	#1,D0
	bcs.s	skip2
	cmp.w	(A5),D0
	bhs.s	skip
skip2
	move.w	(A5),D0
skip
	move.w	D0,4(A5)
	bsr.w	lbC0003B6
	move.l	EagleBase(PC),A5
	move.l	dtg_StartInt(A5),A0
	jsr	(A0)
	rts

***************************************************************************
********************************* EP_Save *********************************
***************************************************************************

	*------------------- Save Mem to Disk ----------------------*
	*---- ARG1 = StartAdr					----*
	*---- ARG2 = EndAdr					----*
	*---- ARG3 = PathAdr					----*

Save
	move.l	EPG_ARG1(A5),A2
	move.l	EPG_ARG2(A5),A3
	move.l	dtg_PathArrayPtr(A5),EPG_ARG3(A5)
	move.l	ModulePtr(PC),EPG_ARG1(A5)
	move.l	InfoBuffer+Songsize(PC),EPG_ARG2(A5)
	moveq	#-1,D0
	move.l	D0,EPG_ARG4(A5)
	clr.l	EPG_ARG5(A5)
	moveq	#5,D0
	move.l	D0,EPG_ARGN(A5)
	move.l	EPG_SaveMem(A5),A0
	jsr	(A0)
	bne.b	NoSave
	move.l	dtg_PathArrayPtr(A5),A0
	clr.b	(A0)
	move.l	A2,A0
	move.l	dtg_CopyString(A5),A1
	jsr	(A1)
	lea	TFMXsmpl(PC),A0
	move.l	dtg_CopyString(A5),A1
	jsr	(A1)
	move.l	A3,A0
	addq.l	#5,A0
	move.l	dtg_CopyString(A5),A1
	jsr	(A1)
	move.l	dtg_PathArrayPtr(A5),EPG_ARG3(A5)
	move.l	SamplePtr(PC),EPG_ARG1(A5)
	move.l	SampleLen(PC),D0
	cmp.l	InfoBuffer+SamplesSize(PC),D0
	blt.b	LoadedSizeLower
	move.l	InfoBuffer+SamplesSize(PC),D0
LoadedSizeLower
	move.l	D0,EPG_ARG2(A5)
	moveq	#-1,D0
	move.l	D0,EPG_ARG4(A5)
	moveq	#2,D0
	move.l	D0,EPG_ARG5(A5)
	moveq	#5,D0
	move.l	D0,EPG_ARGN(A5)
	move.l	EPG_SaveMem(A5),A0
	jsr	(A0)
NoSave
	rts

***************************************************************************
******************************* EP_SampleInit *****************************
***************************************************************************

SampleInit
	moveq	#EPR_NotEnoughMem,D7
	lea	EPG_SampleInfoStructure(A5),A3
	move.l	SamplePtr(PC),D0
	beq.b	return
	move.l	D0,A2

	move.l	A2,A4
	move.l	ModulePtr(PC),A1
	move.l	A1,A0
	lea	1536(A1),A1
	add.l	InfoBuffer+Songsize(PC),A0
	subq.l	#4,A0
	moveq	#127,D5
NextCheck
	subq.l	#8,A0
	cmp.w	#$0700,(A0)
	bne.b	Sample
	dbf	D5,NextCheck
Sample
	jsr	ENPP_AllocSampleStruct(A5)
	move.l	D0,(A3)
	beq.b	return
	move.l	D0,A3

NextShort
	move.l	A4,A2
	move.l	ModulePtr(PC),A0
	move.l	(A1)+,D2
	add.l	D2,A0

	tst.l	(A0)
	bne.b	NoSample
	cmp.b	#02,4(A0)
	bne.b	NoSample
	move.l	4(A0),D4
	sub.l	#$02000000,D4
	add.l	D4,A2
	move.w	10(A0),D1
	lsl.l	#1,D1
	bra.b	Normal
NoSample
	dbf	D5,NextShort
	bra.b	Skip
Normal
	move.l	A2,EPS_Adr(A3)			; sample address
	move.l	D1,EPS_Length(A3)		; sample length
	move.l	#64,EPS_Volume(A3)
	move.w	#USITY_RAW,EPS_Type(A3)
	move.w	#USIB_Playable!USIB_Saveable!USIB_8BIT,EPS_Flags(A3)

	dbf	D5,Sample
Skip
	moveq	#0,D7
return
	move.l	D7,D0
	rts

***************************************************************************
********************************* EP_GetPosNr *****************************
***************************************************************************

GetPosition
	moveq	#0,D0
	move.w	CurrentPos(PC),D0
	sub.w	lbL0012D0(PC),D0
	rts

***************************************************************************
******************************* EP_StructInit *****************************
***************************************************************************

StructInit
	lea	StructAdr(PC),A0
	rts

***************************************************************************
***************************** EP_Get_ModuleInfo ***************************
***************************************************************************

GetInfos
	lea	InfoBuffer(PC),A0
	rts

SubSongs	=	4
LoadSize	=	12
Songsize	=	20
Length		=	28
Samples		=	36
SamplesSize	=	44
Calcsize	=	52
Pattern		=	60
SpecialInfo	=	68
Author		=	76

InfoBuffer
	dc.l	MI_SubSongs,0		;4
	dc.l	MI_LoadSize,0		;12
	dc.l	MI_Songsize,0		;20
	dc.l	MI_Length,0		;28
	dc.l	MI_Samples,0		;36
	dc.l	MI_SamplesSize,0	;44
	dc.l	MI_Calcsize,0		;52
	dc.l	MI_Pattern,0		;60
	dc.l	MI_SpecialInfo,0	;68
	dc.l	MI_AuthorName,0		;76
	dc.l	MI_MaxSubSongs,32
	dc.l	MI_MaxPattern,128
	dc.l	MI_MaxSamples,128
	dc.l	MI_MaxLength,512
	dc.l	MI_Prefix,TFMXmdat
	dc.l	0

***************************************************************************
******************************* DTP_Check2 ********************************
***************************************************************************

Check2
	movea.l	dtg_ChkData(A5),A0
	moveq	#-1,D0

	cmp.l	#'TFMX',(A0)
	bne.w	Fault

	cmp.b	#$20,4(A0)
	bne.b	CheckAnother

	bra.b	test
CheckAnother
	cmp.l	#'-SON',4(A0)
	bne.w	Fault
	cmp.w	#'G ',8(A0)
	bne.w	Fault
	cmp.w	#'by',10(A0)
	beq.b	test
	cmp.l	#'(Emp',16(A0)
	bne.b	NoEmpty
	cmp.l	#'ty) ',20(A0)
	bne.w	Fault
	bra.b	test
NoEmpty
	cmp.w	#'  ',16(A0)
	beq.b	test
	cmp.w	#$303D,16(A0)		; extension for Lethal Zone
	bne.b	Fault
test
	tst.l	464(A0)
	bne.b	Fault
	cmp.w	#$0E60,14(A0)		; extension for Z-Out (title)
	beq.b	Fault
	cmp.w	#$0860,14(A0)		; extension for Metal Law (jingle)
	bne.b	NextNew1
	cmp.w	#$090C,4644(A0)
	beq.b	Fault
NextNew1
	cmp.w	#$0B20,14(A0)		; extension for Bug Bomber (unpacked)
	bne.b	NextNew2
	cmp.w	#$8C26,5120(A0)
	beq.b	Fault
NextNew2
	cmp.w	#$0920,14(A0)		; extension for Metal Law (preview)
	bne.b	OK
	cmp.w	#$9305,3876(A0)
	beq.b	Fault
OK
	move.l	1536(A0),D1
	beq.b	Fault
	bmi.b	Fault
	btst	#0,D1
	bne.b	Fault
	move.l	2044(A0),D2
	beq.b	Fault
	bmi.b	Fault
	btst	#0,D2
	bne.b	Fault
	lea	(A0,D2.L),A1
	lea	(A0,D1.L),A0
CheckForPro_ST
	cmp.b	#36,(A0)
	bhi.b	Fault
	addq.l	#4,A0
	cmp.l	A0,A1
	bne.b	CheckForPro_ST

	moveq	#0,D0
Fault
	rts

***************************************************************************
******************************* DTP_ExtLoad *******************************
***************************************************************************

ExtLoad
	movea.l	dtg_PathArrayPtr(A5),A0
	clr.b	(A0)
	movea.l	dtg_CopyDir(A5),A0
	jsr	(A0)
	bsr.s	CopyName
	movea.l	dtg_LoadFile(A5),A0
	jsr	(A0)
	tst.l	D0
	beq.b	ExtLoadOK
	move.l	dtg_PathArrayPtr(A5),A0
	clr.b	(A0)
	move.l	dtg_CopyDir(A5),A0
	jsr	(A0)
	bsr.b	CopyName2
	move.l	dtg_LoadFile(A5),A0
	jsr	(A0)
ExtLoadOK
	rts

CopyName2
	movea.l	dtg_PathArrayPtr(A5),A0
loop1
	tst.b	(A0)+
	bne.s	loop1
	subq.l	#1,A0
	lea	SampleName(PC),A3
smp2
	move.b	(A3)+,(A0)+
	bne.s	smp2
	rts

CopyName
	move.l	dtg_PathArrayPtr(A5),A0
loop	tst.b	(A0)+
	bne.s	loop
	subq.l	#1,A0
	lea	TFMXsmpl(PC),A1
smpl	move.b	(A1)+,(A0)+
	bne.s	smpl
	subq.l	#1,A0

	move.l	dtg_FileArrayPtr(A5),A1
	lea	TFMXmdat(PC),A2
mdat	move.b	(A2)+,D0
	beq.s	copy
	move.b	(A1)+,D1
	bset	#5,D1
	cmp.b	D0,D1
	beq.s	mdat

	move.l	dtg_FileArrayPtr(A5),A1
copy	move.b	(A1)+,(A0)+
	bne.s	copy
	rts

***************************************************************************
***************************** DTP_SubSongRange ****************************
***************************************************************************

SubSongRange
	moveq	#0,D0
	move.l	InfoBuffer+SubSongs(PC),D1
	subq.l	#1,D1
	rts

***************************************************************************
***************************** DTP_InitPlayer ******************************
***************************************************************************

InitPlayer
	moveq	#0,D0
	movea.l	dtg_GetListData(A5),A0
	jsr	(A0)

	lea	ModulePtr(PC),A1
	move.l	A0,(A1)			; songdata buffer

	lea	InfoBuffer(PC),A2	; A2 reserved for InfoBuffer
	move.l	D0,LoadSize(A2)

	moveq	#1,D1			; subsongs check
	moveq	#30,D5
	move.l	A0,A1			; A0 reserved for late use
Next
	move.w	322(A1),D2
	move.w	324(A1),D3
	cmp.w	D2,D3
	beq.b	ReallyLast

NoLast	
	subq.l	#1,D5
	addq.l	#2,A1
	addq.l	#1,D1
	cmp.w	#32,D1			; for safety, 32 = maximum of subsongs
	beq.b	Exit
	bra.b	Next

ReallyLast
	move.w	326(A1),D4
	cmp.w	D3,D4
	bne.b	NoLast

SearchForMore
	move.w	322(A1),D4
	sub.w	258(A1),D4
	addq.l	#2,A1
	tst.w	D4
	beq.b	NoSub
	addq.l	#1,D1
NoSub
	dbf	D5,SearchForMore

Exit
	move.l	D1,SubSongs(A2)

	move.l	A0,A3			; calculate length of songdata
	move.l	A0,A4
	add.l	D0,A4
	lea	1024(A3),A1
	add.l	2044(A3),A3
FindEndMacro
	cmp.l	#$07000000,(A3)+
	beq.b	LastMacro
	cmp.l	A3,A4
	bgt.b	FindEndMacro
	moveq	#EPR_ModuleTooShort,D0		; error message
	rts
LastMacro
	sub.l	A0,A3
	move.l	A3,Songsize(A2)
	move.l	A3,Calcsize(A2)

	cmp.l	#10688,A3		; fix for corrupted SubRally song
	bne.b	Dalej1
	cmp.w	#$2B,326(A0)		; better check
	bne.b	Dalej1
	subq.w	#1,326(A0)
	bra.b	Dalej4
Dalej1
	cmp.l	#8084,A3		; fix for corrupted AP part1.2 song
	beq.b	More
	cmp.l	#7912,A3		; fix for corrupted AP part1.3 song
	bne.b	Dalej2
More
	cmp.l	#$002D003F,322(A0)
	bne.b	Dalej2
	moveq	#1,D4
	move.l	D4,SubSongs(A2)
	bra.b	Dalej4
Dalej2
	cmp.l	#8660,A3		; fix for corrupted Apprentice song
	bne.b	Dalej3
	cmp.l	#$001D0020,330(A0)
	bne.b	Dalej3
	subq.w	#3,332(A0)
	bra.b	Dalej4
Dalej3
	cmp.l	#13864,A3		; fix for unused Wolfen song
	bne.b	Dalej4
	cmp.w	#32,SubSongs+2(A2)
	bne.b	Dalej4
	subq.w	#1,SubSongs+2(A2)
Dalej4
	lea	512(A1),A4

	moveq	#127,D4			; calculate number of patterns
	moveq	#0,D5
CheckPattern
	tst.l	D4
	beq.b	LastPattern
	subq.l	#1,D4
NextPattern
	move.l	(A1)+,D1
	move.l	(A1),D2
	sub.l	D1,D2
	cmp.w	#8,D2
	beq.b	CheckPattern
	addq.l	#1,D5
	dbf	D4,NextPattern
LastPattern
	move.l	D5,Pattern(A2)
	moveq	#127,D4		; calculate number and length of samples
	moveq	#0,D5
	moveq	#0,D3
CheckMacro
	tst.l	D4
	beq.b	FoundLast
	subq.l	#1,D4
NextMacro
	move.l	(A4),D1
	move.l	A0,A1
	addq.l	#4,A4
	move.l	(A4),D2
	sub.l	D1,D2
	cmp.w	#8,D2
	beq.b	CheckMacro
	add.w	D1,A1
	tst.l	(A1)
	bne.b	CheckMacro
	cmp.b	#02,4(A1)
	bne.b	CheckMacro
	move.l	4(A1),D1
	sub.l	#$02000000,D1
	move.w	10(A1),D2
	lsl.l	#1,D2
	add.l	D2,D1
	cmp.l	D1,D5
	bgt.b	NextSample
	move.l	D1,D5
NextSample
	addq.l	#1,D3
	dbf	D4,NextMacro
FoundLast
	move.l	D3,Samples(A2)
	move.l	D5,SamplesSize(A2)
	add.l	D5,Calcsize(A2)

	clr.l	Author(A2)
	sub.l	A4,A4
	tst.b	16(A0)
	beq.b	NoText

	lea	16(A0),A3
	lea	Header,A1
	lea	248(A1),A0
	move.l	A1,A4
	moveq	#5,D3
NextLine
	moveq	#39,D2
copy2
	move.b	(A3),(A0)+
	move.b	(A3)+,(A1)+
	dbf	D2,copy2
	move.b	#10,(A1)+                 ; insert linefeeds
	clr.b	(A0)+
	dbf	D3,NextLine
	clr.w	(A1)
	clr.w	(A0)
NoText
	move.l	A4,SpecialInfo(A2)
	beq.b	NoName
	move.l	Eagle2Base(PC),D0
	bne.b	Eagle2
	move.l	DeliBase(PC),D0
	bne.b	NoName
Eagle2
	bsr.b	FindName
NoName
	moveq	#1,D0
	movea.l	dtg_GetListData(A5),A0
	jsr	(A0)

	lea	SamplePtr(PC),A1
	move.l	A0,(A1)+			; sample buffer
	move.l	D0,(A1)+			; sample len
	add.l	D0,LoadSize(A2)

	move.l	A5,(A1)				; EagleBase

	movea.l	dtg_AudioAlloc(A5),A0
	jmp	(A0)

FindName
	lea	Header+248,A1			; A1 - begin sampleinfo
	move.l	A1,EPG_ARG1(A5)
	moveq	#41,D0				; D0 - length per one sampleinfo
	move.l	D0,EPG_ARG2(A5)
	moveq	#40,D0				; D0 - max. sample name
	move.l	D0,EPG_ARG3(A5)
	moveq	#6,D0				; D0 - max. samples number
	move.l	D0,EPG_ARG4(A5)
	moveq	#4,D0
	move.l	D0,EPG_ARGN(A5)
	jsr	ENPP_FindAuthor(A5)
	move.l	EPG_ARG1(A5),Author(A2)		; output
	rts

***************************************************************************
***************************** DTP_EndPlayer *******************************
***************************************************************************

EndPlayer
	movea.l	dtg_AudioFree(A5),A0
	jmp	(A0)

***************************************************************************
***************************** DTP_InitSound *******************************
***************************************************************************

InitSound
	lea	StructAdr(PC),A0
	lea	UPS_SizeOF(A0),A1
ClearUPS
	clr.w	(A0)+
	cmp.l	A0,A1
	bne.b	ClearUPS
	move.l	ModulePtr(PC),D0
	move.l	SamplePtr(PC),D1
	bsr.w	INITDATA
	move.l	ModulePtr(PC),A3
	move.l	A3,A0
	lea	320(A0),A0
	moveq	#0,D1
	move.w	dtg_SndNum(A5),D1
	move.w	D1,D0
	tst.w	D0
	beq.b	SubOK
	lsl.l	#1,D1
	add.l	D1,A0
NextSub
	tst.w	(A0)
	bne.b	SubOK
	addq.l	#2,A0
	tst.w	(A0)
	beq.b	NoCheck
	tst.w	-4(A0)
	bne.b	SubOK
NoCheck
	addq.w	#1,D0
	bra.b	NextSub
SubOK
	move.w	D0,D4
SongLen
	move.w	320(A3),D6
	sub.w	256(A3),D6
	addq.l	#2,A3
	dbf	D4,SongLen
	lea	InfoBuffer(PC),A1
	tst.w	D6
	bpl.b	LengthOK
	move.w	320-2(A3),D6
LengthOK
	move.w	D6,Length+2(A1)	

	move.w	384-2(A3),D2
	move.w	UsedTiming(PC),D1
	bne.b	TimingOK
	move.w	dtg_Timer(A5),D1
	move.w	D1,UsedTiming
TimingOK
	cmp.w	#$1F,D2
	bls.b	NoTimer
	move.l	#$1C00,D1
	divu.w	D2,D1
	lsl.w	#8,D1
NoTimer
	move.w	D1,dtg_Timer(A5)
	bsr.w	SONGPLAY
	moveq	#64,D0
	bra.w	FADE

***************************************************************************
************************* DTP_Volume, DTP_Balance *************************
***************************************************************************
; Copy Volume and Balance Data to internal buffer

SetVolume
SetBalance
	move.w	dtg_SndLBal(A5),D0
	mulu.w	dtg_SndVol(A5),D0
	lsr.w	#6,D0

	move.w	D0,LeftVolume

	move.w	dtg_SndRBal(A5),D0
	mulu.w	dtg_SndVol(A5),D0
	lsr.w	#6,D0

	move.w	D0,RightVolume

	moveq	#0,D0
	rts

ChangeVolume
	move.l	D1,-(A7)
	and.w	#$7F,D0
	move.l	A4,D1
	cmp.w	#$F0A0,D1
	beq.s	Left1
	cmp.w	#$F0B0,D1
	beq.s	Right1
	cmp.w	#$F0C0,D1
	beq.s	Right2
	cmp.w	#$F0D0,D1
	bne.s	Exit2
Left2
	mulu.w	LeftVolume(PC),D0
	and.w	Voice4(PC),D0
	bra.s	Ex
Left1
	mulu.w	LeftVolume(PC),D0
	and.w	Voice1(PC),D0
	bra.s	Ex

Right1
	mulu.w	RightVolume(PC),D0
	and.w	Voice2(PC),D0
	bra.s	Ex
Right2
	mulu.w	RightVolume(PC),D0
	and.w	Voice3(PC),D0
Ex
	lsr.w	#6,D0
	move.w	D0,8(A4)
Exit2
	move.l	(A7)+,D1
	rts

*------------------------------- Set Vol -------------------------------*

SetVol
	move.l	A0,-(A7)
	lea	StructAdr+UPS_Voice1Vol(PC),A0
	cmp.l	#$DFF0A0,A4
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice2Vol(PC),A0
	cmp.l	#$DFF0B0,A4
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice3Vol(PC),A0
	cmp.l	#$DFF0C0,A4
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice4Vol(PC),A0
.SetVoice
	move.w	D0,(A0)
	move.l	(A7)+,A0
	rts

*------------------------------- Set Adr -------------------------------*

SetAdr
	move.l	A0,-(A7)
	lea	StructAdr+UPS_Voice1Adr(PC),A0
	cmp.l	#$DFF0A0,A4
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice2Adr(PC),A0
	cmp.l	#$DFF0B0,A4
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice3Adr(PC),A0
	cmp.l	#$DFF0C0,A4
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice4Adr(PC),A0
.SetVoice
	move.l	D0,(A0)
	move.l	(A7)+,A0
	rts

*------------------------------- Set Len -------------------------------*

SetLen
	move.l	A0,-(A7)
	lea	StructAdr+UPS_Voice1Len(PC),A0
	cmp.l	#$DFF0A0,A4
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice2Len(PC),A0
	cmp.l	#$DFF0B0,A4
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice3Len(PC),A0
	cmp.l	#$DFF0C0,A4
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice4Len(PC),A0
.SetVoice
	move.w	D1,(A0)
	move.l	(A7)+,A0
	rts

*------------------------------- Set Per -------------------------------*

SetPer
	move.l	A0,-(A7)
	lea	StructAdr+UPS_Voice1Per(PC),A0
	cmp.l	#$DFF0A0,A4
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice2Per(PC),A0
	cmp.l	#$DFF0B0,A4
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice3Per(PC),A0
	cmp.l	#$DFF0C0,A4
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice4Per(PC),A0
.SetVoice
	move.w	D0,(A0)
	move.l	(A7)+,A0
	rts

***************************************************************************
**************************** EP_Voices ************************************
***************************************************************************

SetVoices
	lea	Voice1(PC),A0
	lea	StructAdr(PC),A1
	move.w	#$FFFF,D1
	move.w	D1,(A0)+			Voice1=0 setzen
	btst	#0,D0
	bne.s	.NoVoice1
	clr.w	-2(A0)
	clr.w	$DFF0A8
	clr.w	UPS_Voice1Vol(A1)
.NoVoice1
	move.w	D1,(A0)+			Voice2=0 setzen
	btst	#1,D0
	bne.s	.NoVoice2
	clr.w	-2(A0)
	clr.w	$DFF0B8
	clr.w	UPS_Voice2Vol(A1)
.NoVoice2
	move.w	D1,(A0)+			Voice3=0 setzen
	btst	#2,D0
	bne.s	.NoVoice3
	clr.w	-2(A0)
	clr.w	$DFF0C8
	clr.w	UPS_Voice3Vol(A1)
.NoVoice3
	move.w	D1,(A0)+			Voice4=0 setzen
	btst	#3,D0
	bne.s	.NoVoice4
	clr.w	-2(A0)
	clr.w	$DFF0D8
	clr.w	UPS_Voice4Vol(A1)
.NoVoice4
	move.w	D0,UPS_DMACon(A1)
	moveq	#0,D0
	rts

***************************************************************************
***************************** TFMX 1.6 player *****************************
***************************************************************************

; Player from game Turrican (intro music)

TFMXbase
;	BRA.W	ALLOFF

;	BRA.W	IRQIN

;	BRA.W	ALLOFF

;	BRA.W	SONGPLAY

;	BRA.W	NOTEPORT

;	BRA.W	INITDATA

;	BRA.W	ALLOFF

;	BRA.W	ALLOFF

;	BRA.W	CHANNELOFF

;	BRA.W	lbC000FB4			; BSET

;	BRA.W	FADE

;	BRA.W	INFO

;	BRA.W	ALLOFF

;	BRA.W	ALLOFF

;	BRA.W	ALLOFF

;	BRA.W	FXPLAY

;	BRA.W	PLAYCONT

;	BRA.W	ALLOFF

;	BRA.W	ALLOFF

;	BRA.W	ALLOFF

;	BRA.W	ALLOFF

;	BRA.W	TIMERINIT

IRQIN
;	MOVE.L	A6,-(A7)
;	LEA	lbL001102(PC),A6
;	TST.B	$4A(A6)
;	BEQ.S	lbC000068
;	MOVEA.L	(A7)+,A6
;	RTS

;lbC000068	MOVEA.L	(A7)+,A6
lbC00006A	MOVEM.L	D0-D7/A0-A6,-(A7)
	LEA	lbL001102(PC),A6
	TST.B	$3D(A6)
	BMI.S	lbC00007E
	BSR.W	lbC000D48
	BRA.S	lbC00009C

lbC00007E	TST.W	8(A6)
	BEQ.S	lbC00008A
	TST.B	$2E(A6)
	BNE.S	lbC000096
lbC00008A	LEA	lbL001418(PC),A0
	CLR.W	0(A0)
	BRA.W	lbC00009C

lbC000096	BSR.S	lbC0000A2
	BSR.W	lbC0005E8
lbC00009C	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS

lbC0000A2	LEA	lbL0012D0(PC),A5
	MOVEA.L	0(A6),A4
	TST.W	$2C(A6)
	BEQ.S	lbC0000B8
	SUBI.W	#1,$2C(A6)
	RTS

lbC0000B8	MOVE.W	6(A5),$2C(A6)
lbC0000BE	TST.W	$3E(A6)
	BEQ.L	lbC0000DE
	TST.W	10(A6)
	BEQ.L	lbC0000DE
	CLR.W	$2C(A6)
	CLR.W	10(A6)
	MOVE.W	#1,$44(A6)
	RTS

lbC0000DE	MOVEA.L	A5,A0
	CLR.B	10(A6)
	BSR.S	lbC000134
	TST.B	10(A6)
	BNE.S	lbC0000BE
	ADDQ.L	#4,A0
	BSR.S	lbC000134
	TST.B	10(A6)
	BNE.S	lbC0000BE
	ADDQ.L	#4,A0
	BSR.S	lbC000134
	TST.B	10(A6)
	BNE.S	lbC0000BE
	ADDQ.L	#4,A0
	BSR.S	lbC000134
	TST.B	10(A6)
	BNE.S	lbC0000BE
	ADDQ.L	#4,A0
	BSR.S	lbC000134
	TST.B	10(A6)
	BNE.S	lbC0000BE
	ADDQ.L	#4,A0
	BSR.S	lbC000134
	TST.B	10(A6)
	BNE.S	lbC0000BE
	ADDQ.L	#4,A0
	BSR.S	lbC000134
	TST.B	10(A6)
	BNE.S	lbC0000BE
	ADDQ.L	#4,A0
	BSR.S	lbC000134
	TST.B	10(A6)
	BNE.S	lbC0000BE
	RTS

lbC000134	CMPI.B	#$90,$48(A0)
	BCS.S	lbC000158
	CMPI.B	#$FE,$48(A0)
	BNE.S	lbC000164
	MOVE.B	#$FF,$48(A0)
	MOVE.B	$49(A0),D0
	TST.W	8(A0)
	BEQ.L	CHANNELOFF
	RTS

lbC000158	TST.W	$6A(A0)
	BEQ.S	lbC000166
	SUBI.W	#1,$6A(A0)
lbC000164	RTS

lbC000166	MOVE.W	$68(A0),D0
	LSL.W	#2,D0
	MOVEA.L	$28(A0),A1
	MOVE.L	0(A1,D0.W),$28(A6)
	CMPI.B	#$F0,$28(A6)
	BCC.S	lbC0001C8
	CMPI.B	#$C0,$28(A6)
	BCC.S	lbC00019A
	CMPI.B	#$7F,$28(A6)
	BCS.S	lbC00019A
	MOVE.B	$2B(A6),$6B(A0)
	ANDI.W	#$FF00,$2A(A6)
lbC00019A	MOVE.B	$49(A0),D0
	ADD.B	D0,$28(A6)
	MOVE.L	$28(A6),D0
	TST.W	8(A0)
	BNE.S	lbC0001B0
	BSR.W	NOTEPORT
lbC0001B0	CMPI.B	#$C0,$28(A6)
	BCC.S	lbC0001E2
	CMPI.B	#$7F,$28(A6)
	BCS.S	lbC0001E2
lbC0001C0	ADDI.W	#1,$68(A0)
	RTS

lbC0001C8	MOVE.B	$28(A6),D0
	ANDI.W	#15,D0
	LSL.W	#2,D0
	LEA	lbL000376(PC),A1
	MOVE.L	0(A1,D0.W),D1
	LEA	TFMXbase(PC),A1
	ADDA.L	D1,A1
	JMP	(A1)

lbC0001E2	ADDI.W	#1,$68(A0)
	BRA.W	lbC000166

lbC0001EC	CMPI.B	#$81,$48(A0)
	BEQ.L	lbC000282
NextStep
	MOVE.W	4(A5),D0
	CMP.W	2(A5),D0
	BNE.S	lbC000208

	bsr.w	SongEnd

	MOVE.W	0(A5),4(A5)
	BRA.S	lbC00020E

lbC000208	ADDI.W	#1,4(A5)
lbC00020E	BSR.W	lbC0003B6
	MOVE.W	#$FFFF,10(A6)
	RTS

lbC00021A	TST.B	$4A(A0)
	BEQ.S	lbC000230
	CMPI.B	#$FF,$4A(A0)
	BEQ.S	lbC000238
	SUBI.B	#1,$4A(A0)
	BRA.S	lbC000244

lbC000230	MOVE.B	#$FF,$4A(A0)
	BRA.S	lbC0001E2

lbC000238	MOVE.B	$29(A6),D0
	SUBI.B	#1,D0
	MOVE.B	D0,$4A(A0)
lbC000244	MOVE.W	$2A(A6),$68(A0)
	BRA.W	lbC000166

lbC00024E	MOVE.B	$29(A6),D0
	ANDI.W	#$7F,D0
	MOVE.B	D0,$48(A0)
	LSL.W	#2,D0
	MOVEA.L	A4,A1
	ADDA.L	#$400,A1
	MOVE.L	0(A1,D0.W),D0
	ADD.L	A4,D0
	MOVE.L	D0,$28(A0)
	MOVE.W	$2A(A6),$68(A0)
	BRA.W	lbC000166

lbC000278	MOVE.B	$29(A6),$6B(A0)
	BRA.W	lbC0001C0

lbC000282	MOVE.B	#$FF,$48(A0)
	RTS

lbC00028A	MOVE.L	$28(A6),D0
	TST.W	8(A0)
	BNE.S	lbC000298
	BSR.W	NOTEPORT
lbC000298	BRA.W	lbC0001E2

lbC00029C	MOVE.L	$28(A0),$88(A0)
	MOVE.W	$68(A0),$A8(A0)
	MOVE.B	$29(A6),D0
	ANDI.W	#$7F,D0
	MOVE.B	D0,$48(A0)
	LSL.W	#2,D0
	MOVEA.L	A4,A1
	ADDA.L	#$400,A1
	MOVE.L	0(A1,D0.W),D0
	ADD.L	A4,D0
	MOVE.L	D0,$28(A0)
	MOVE.W	$2A(A6),$68(A0)
	BRA.W	lbC000166

lbC0002D2	MOVE.L	$88(A5),$28(A5)
	MOVE.W	$A8(A5),$68(A5)
	BRA.W	lbC0001E2

lbC0002E2	LEA	lbL001418(PC),A1
	TST.W	0(A1)
	BNE.L	lbC0001E2
	MOVE.W	#1,0(A1)
	MOVE.B	$2B(A6),$51(A6)
	MOVE.B	$29(A6),$52(A6)
	MOVE.B	$29(A6),$53(A6)
	BEQ.S	lbC000324
	MOVE.B	#1,$1C(A6)
	MOVE.B	$50(A6),D0
	CMP.B	$51(A6),D0
	BEQ.S	lbC00032A
	BCS.L	lbC0001E2
	NEG.B	$1C(A6)
	BRA.W	lbC0001E2

lbC000324	MOVE.B	$51(A6),$50(A6)
lbC00032A	MOVE.B	#0,$1C(A6)
	CLR.W	0(A1)
	BRA.W	lbC0001E2

lbC000338	MOVE.B	$2A(A6),D1
	ANDI.W	#7,D1
	LSL.W	#2,D1
	MOVE.B	$29(A6),D0
	MOVE.B	D0,$48(A5,D1.W)
	MOVE.B	$2B(A6),$49(A5,D1.W)
	ANDI.W	#$7F,D0
	LSL.W	#2,D0
	MOVEA.L	A4,A1
	ADDA.L	#$400,A1
	MOVE.L	0(A1,D0.W),D0
	ADD.L	A4,D0
	MOVE.L	D0,$28(A5,D1.W)
	CLR.L	$68(A5,D1.W)
	MOVE.W	#$FFFF,$4A(A5,D1.W)
	BRA.W	lbC0001E2

lbL000376	dc.l	lbC0001EC-TFMXbase
	dc.l	lbC00021A-TFMXbase
	dc.l	lbC00024E-TFMXbase
	dc.l	lbC000278-TFMXbase
	dc.l	lbC000282-TFMXbase
	dc.l	lbC00028A-TFMXbase
	dc.l	lbC00028A-TFMXbase
	dc.l	lbC00028A-TFMXbase
	dc.l	lbC00029C-TFMXbase
	dc.l	lbC0002D2-TFMXbase
	dc.l	lbC0002E2-TFMXbase
	dc.l	lbC000338-TFMXbase
	dc.l	lbC0001C0-TFMXbase
	dc.l	lbC0001C0-TFMXbase
	dc.l	lbC000282-TFMXbase
	dc.l	lbC0001E2-TFMXbase

lbC0003B6	MOVEM.L	D0/A0/A1,-(A7)
lbC0003BA	MOVEQ	#0,D0
	MOVE.W	4(A5),D0
	LSL.W	#4,D0
	ADD.L	A4,D0
	ADDI.L	#$800,D0
	MOVEA.L	D0,A0
	MOVEA.L	A4,A1
	ADDA.L	#$400,A1
	MOVE.W	(A0)+,D0

	cmp.w	#$FA00,D0			; Fix for TFMX 1.0 modules
	bne.b	Next1				; from the 1988 year
	bra.b	Zero
Next1
	cmp.w	#$FA01,D0
	bne.b	Next2
	moveq	#1,D0
	bra.b	lbC0003E6
Next2
	cmp.w	#$FA02,D0
	bne.b	Next3
	moveq	#2,D0
	bra.b	lbC0003E6
Next3
	CMP.W	#$EFFE,D0
	BNE.S	lbC0003F8
	MOVE.W	(A0)+,D0
	CMP.W	#5,D0
	BCS.S	lbC0003E6
Zero
	MOVEQ	#0,D0
lbC0003E6	LSL.W	#2,D0
	LEA	lbL0005D4(PC),A1
	MOVE.L	0(A1,D0.W),D0
	LEA	TFMXbase(PC),A1
	ADDA.L	D0,A1
	JMP	(A1)

lbC0003F8	MOVE.W	D0,$48(A5)
	BMI.S	lbC000418
	ANDI.W	#$7F00,D0
	LSR.W	#6,D0
	MOVE.L	0(A1,D0.W),D0
	ADD.L	A4,D0
	MOVE.L	D0,$28(A5)
	CLR.L	$68(A5)
	MOVE.W	#$FFFF,$4A(A5)
lbC000418	MOVE.W	(A0)+,D0
	MOVE.W	D0,$4C(A5)
	BMI.S	lbC00043A
	ANDI.W	#$7F00,D0
	LSR.W	#6,D0
	MOVE.L	0(A1,D0.W),D0
	ADD.L	A4,D0
	MOVE.L	D0,$2C(A5)
	CLR.L	$6C(A5)
	MOVE.W	#$FFFF,$4E(A5)
lbC00043A	MOVE.W	(A0)+,D0
	MOVE.W	D0,$50(A5)
	BMI.S	lbC00045C
	ANDI.W	#$7F00,D0
	LSR.W	#6,D0
	MOVE.L	0(A1,D0.W),D0
	ADD.L	A4,D0
	MOVE.L	D0,$30(A5)
	CLR.L	$70(A5)
	MOVE.W	#$FFFF,$52(A5)
lbC00045C	MOVE.W	(A0)+,D0
	MOVE.W	D0,$54(A5)
	BMI.S	lbC00047E
	ANDI.W	#$7F00,D0
	LSR.W	#6,D0
	MOVE.L	0(A1,D0.W),D0
	ADD.L	A4,D0
	MOVE.L	D0,$34(A5)
	CLR.L	$74(A5)
	MOVE.W	#$FFFF,$56(A5)
lbC00047E	MOVE.W	(A0)+,D0
	MOVE.W	D0,$58(A5)
	BMI.S	lbC0004A0
	ANDI.W	#$7F00,D0
	LSR.W	#6,D0
	MOVE.L	0(A1,D0.W),D0
	ADD.L	A4,D0
	MOVE.L	D0,$38(A5)
	CLR.L	$78(A5)
	MOVE.W	#$FFFF,$5A(A5)
lbC0004A0	MOVE.W	(A0)+,D0
	MOVE.W	D0,$5C(A5)
	BMI.S	lbC0004C2
	ANDI.W	#$7F00,D0
	LSR.W	#6,D0
	MOVE.L	0(A1,D0.W),D0
	ADD.L	A4,D0
	MOVE.L	D0,$3C(A5)
	CLR.L	$7C(A5)
	MOVE.W	#$FFFF,$5E(A5)
lbC0004C2	MOVE.W	(A0)+,D0
	MOVE.W	D0,$60(A5)
	BMI.S	lbC0004E4
	ANDI.W	#$7F00,D0
	LSR.W	#6,D0
	MOVE.L	0(A1,D0.W),D0
	ADD.L	A4,D0
	MOVE.L	D0,$40(A5)
	CLR.L	$80(A5)
	MOVE.W	#$FFFF,$62(A5)
lbC0004E4	MOVE.W	(A0)+,D0
	MOVE.W	D0,$64(A5)
	BMI.S	lbC000506
	ANDI.W	#$7F00,D0
	LSR.W	#6,D0
	MOVE.L	0(A1,D0.W),D0
	ADD.L	A4,D0
	MOVE.L	D0,$44(A5)
	CLR.L	$84(A5)
	MOVE.W	#$FFFF,$66(A5)
lbC000506	MOVEM.L	(A7)+,D0/A0/A1
	RTS

;	BSR.W	lbC000F0E
lbC000510	CLR.B	$2E(A6)
	LEA	lbL001418(PC),A1
	MOVE.W	#2,2(A1)

	move.l	EagleBase(PC),A5
	move.l	dtg_SongEnd(A5),A1
	jsr	(A1)

	MOVEM.L	(A7)+,D0/A0/A1

	bsr.w	InitSound

	RTS

lbC000524	
	bsr.w	SongEnd

	MOVE.W	(A0),4(A5)
	BRA.W	lbC0003BA

lbC00052C	MOVE.W	(A0),6(A5)
	MOVE.W	(A0),$2C(A6)
	MOVE.B	$5C(A6),$4A(A6)
	MOVE.W	2(A0),D0
	BMI.L	lbC000560
	ANDI.W	#$1FF,D0
	TST.W	D0
	BEQ.L	lbC000560
	MOVE.L	#$1C00,D1
	DIVU.W	D0,D1
;	MOVE.B	D1,$BFD700

	movem.l	A1/A5,-(SP)
	move.l	EagleBase(PC),A5
	move.b	D1,dtg_Timer(A5)
	move.l	dtg_SetTimer(A5),A1
	jsr	(A1)
	movem.l	(SP)+,A1/A5

	MOVE.B	#1,$4A(A6)
lbC000560	ADDI.W	#1,4(A5)
	BRA.W	lbC0003BA

lbC00056A	MOVE.W	(A0),$3E(A6)
	ADDI.W	#1,4(A5)
	BRA.W	lbC0003BA

lbC000578	ADDI.W	#1,4(A5)
	LEA	lbL001418(PC),A1
	TST.W	0(A1)
	BNE.L	lbC0003BA
	MOVE.W	#1,0(A1)
	MOVE.B	3(A0),$51(A6)
	MOVE.B	1(A0),$52(A6)
	MOVE.B	1(A0),$53(A6)
	BEQ.S	lbC0005C0
	MOVE.B	#1,$1C(A6)
	MOVE.B	$50(A6),D0
	CMP.B	$51(A6),D0
	BEQ.S	lbC0005C6
	BCS.L	lbC0003BA
	NEG.B	$1C(A6)
	BRA.W	lbC0003BA

lbC0005C0	MOVE.B	$51(A6),$50(A6)
lbC0005C6	MOVE.B	#0,$1C(A6)
	CLR.W	0(A1)
	BRA.W	lbC0003BA

lbL0005D4	dc.l	lbC000510-TFMXbase
	dc.l	lbC000524-TFMXbase
	dc.l	lbC00052C-TFMXbase
	dc.l	lbC00056A-TFMXbase
	dc.l	lbC000578-TFMXbase

lbC0005E8	LEA	lbL001102(PC),A6
	LEA	lbL00115C(PC),A5
	BSR.S	lbC0005F8
	BSR.S	lbC0005F8
	BSR.W	lbC0005F8
lbC0005F8	ADDA.L	#4,A5
	MOVEA.L	$160(A5),A4
	TST.W	2(A5)
	BEQ.S	lbC00060A
	BPL.S	lbC00067A
lbC00060A	TST.W	$100(A5)
	BMI.S	lbC000618
	SUBI.W	#1,$100(A5)
	BRA.S	lbC00061C

lbC000618	CLR.B	$103(A5)
lbC00061C	BSR.W	lbC000B26
	BSR.W	lbC000B64
	BSR.W	lbC000BB2
	TST.B	$1C(A6)
	BEQ.S	lbC00065A
	SUBI.B	#1,$52(A6)
	BNE.S	lbC00065A
	MOVE.B	$53(A6),$52(A6)
	MOVE.B	$1C(A6),D0
	ADD.B	D0,$50(A6)
	MOVE.B	$51(A6),D0
	CMP.B	$50(A6),D0
	BNE.S	lbC00065A
	CLR.B	$1C(A6)
	LEA	lbL001418(PC),A0
	CLR.W	0(A0)
lbC00065A	MOVEQ	#0,D1
	MOVE.B	$50(A6),D1
	MOVEQ	#0,D0
	MOVE.B	$60(A5),D0
	CMP.W	#$40,D1
	BEQ.S	lbC000676
	LSL.W	#2,D0
	MULU.W	D1,D0
	LSR.W	#8,D0
	ANDI.W	#$7F,D0
lbC000676
;	MOVE.W	D0,8(A4)

	bsr.w	ChangeVolume
	bsr.w	SetVol

lbC00067A	TST.W	2(A5)
	BEQ.S	lbC0006B4
	BMI.S	lbC0006A8
	CLR.W	$40(A5)
	MOVE.W	$44(A6),$42(A5)
	MOVE.W	#$FFFF,2(A5)
	MOVE.W	#$FFFF,$62(A5)
	MOVE.W	$112(A5),$DFF09A
	MOVE.W	$112(A5),$DFF09C
lbC0006A8	TST.W	$42(A5)
	BEQ.S	lbC0006B6
	SUBI.W	#1,$42(A5)
lbC0006B4	RTS

lbC0006B6	MOVEA.L	$30(A5),A0
	MOVE.W	$40(A5),D0
	LSL.W	#2,D0
	MOVE.L	0(A0,D0.W),$28(A6)
	MOVE.B	$28(A6),D0
	CLR.B	$28(A6)
	ANDI.W	#$FF,D0
	CMP.W	#$23,D0
	BCC.S	lbC0006EA
	LSL.W	#2,D0
	LEA	lbL000A92(PC),A0
	MOVE.L	0(A0,D0.W),D1
	LEA	TFMXbase(PC),A0
	ADDA.L	D1,A0
	JMP	(A0)

lbC0006EA	ADDI.W	#1,$40(A5)
	RTS

lbC0006F2	ADDI.W	#1,$40(A5)
	BRA.S	lbC0006B6

lbC0006FA	CLR.B	$70(A5)
	CLR.B	$92(A5)
	CLR.W	$C0(A5)
	MOVE.W	$112(A5),$DFF09A
	MOVE.W	$112(A5),$DFF09C
	MOVE.W	$52(A5),$DFF096
	BRA.S	lbC0006F2

lbC000720

	bsr.w	DMAWait

	MOVE.W	$50(A5),$DFF096

	bsr.w	DMAWait

	BRA.S	lbC0006F2

lbC00072A	MOVE.L	$28(A6),D0
	ADD.L	4(A6),D0
lbC000732	MOVE.L	D0,$B0(A5)
	MOVE.L	D0,(A4)

	bsr.w	SetAdr

	BRA.S	lbC0006F2

lbC00073A	MOVE.W	$2A(A6),D1
	EXT.L	D1
	MOVE.L	$B0(A5),D0
	ADD.L	D1,D0
	BRA.S	lbC000732

lbC000748	MOVE.W	$2A(A6),D0
	MOVE.W	$D0(A5),D1
	ADD.W	D0,D1
	MOVE.W	D1,$D0(A5)
	MOVE.W	D1,4(A4)

	bsr.w	SetLen

	BRA.S	lbC0006F2

lbC00075C	MOVE.W	$2A(A6),$D0(A5)
	MOVE.W	$2A(A6),4(A4)

	move.l	D1,-(A7)
	move.w	$2A(A6),D1
	bsr.w	SetLen
	move.l	(A7)+,D1

	BRA.w	lbC0006F2

lbC00076A	MOVE.W	$2A(A6),$42(A5)
	BRA.W	lbC0006EA

lbC000774	MOVE.L	$28(A6),D0
	BRA.W	lbC0006F2

lbC00077C
;	BRA.W	lbC0006F2

lbC000780
;	BRA.W	lbC0006F2

lbC000784
;	BRA.W	lbC0006F2

lbC000788
	BRA.W	lbC0006F2

lbC00078C	CLR.W	2(A5)
	MOVE.W	$110(A5),$DFF09A
	BRA.W	lbC0006EA

lbC00079C	MOVEM.L	D0/A5,-(A7)
	LEA	lbL001160(PC),A5
	MOVE.W	$DFF01E,D0
	BTST	#7,D0
	BNE.L	lbC0007D4
	ADDA.L	#4,A5
	BTST	#8,D0
	BNE.L	lbC0007D4
	ADDA.L	#4,A5
	BTST	#9,D0
	BNE.L	lbC0007D4
	ADDA.L	#4,A5
lbC0007D4	MOVE.W	$112(A5),$DFF09A
	MOVE.W	$112(A5),$DFF09C
	MOVE.W	#$FFFF,2(A5)
	MOVEM.L	(A7)+,D0/A5
;	RTE

	rts

lbC0007F0	MOVE.B	$29(A6),D0
	CMP.B	$11(A5),D0
	BCC.L	lbC0006F2
	MOVE.W	$2A(A6),$40(A5)
	BRA.W	lbC0006B6

lbC000806	MOVE.B	$29(A6),D0
	CMP.B	$60(A5),D0
	BCC.L	lbC0006F2
	MOVE.W	$2A(A6),$40(A5)
	BRA.W	lbC0006B6

lbC00081C	BRA.W	lbC0006F2

lbC000820	TST.B	$62(A5)
	BEQ.S	lbC000836
	CMPI.B	#$FF,$62(A5)
	BEQ.S	lbC000840
	SUBI.B	#1,$62(A5)
	BRA.S	lbC00084C

lbC000836	MOVE.B	#$FF,$62(A5)
	BRA.W	lbC0006F2

lbC000840	MOVE.B	$29(A6),D0
	SUBI.B	#1,D0
	MOVE.B	D0,$62(A5)
lbC00084C	MOVE.W	$2A(A6),$40(A5)
	BRA.W	lbC0006B6

lbC000856	TST.B	$D2(A5)
	BNE.S	lbC000820
	BRA.W	lbC0006F2

lbC000860	MOVE.B	$29(A6),D0
	ANDI.L	#$7F,D0
	MOVEA.L	0(A6),A0
	LSL.W	#2,D0
	ADDA.L	D0,A0
	MOVE.L	$600(A0),D0
	ADD.L	0(A6),D0
	MOVE.L	D0,$30(A5)
	MOVE.W	$2A(A6),$40(A5)
	MOVE.W	#$FFFF,$62(A5)
	BRA.W	lbC00067A

lbC00088E	CLR.W	2(A5)
	RTS

lbC000894	CMPI.B	#$FE,$2A(A6)
	BNE.L	lbC0008B0
	MOVE.B	$11(A5),D2
	MOVE.B	$2B(A6),-(A7)
	CLR.W	$2A(A6)
	BSR.S	lbC0008FC
	MOVE.B	(A7)+,$2B(A6)
lbC0008B0	MOVE.W	$20(A5),D0
	LSL.W	#1,D0
	ADD.W	$20(A5),D0
	ADD.W	$2A(A6),D0
	MOVE.B	D0,$60(A5)
	BRA.W	lbC0006F2

lbC0008C6	CMPI.B	#$FE,$2A(A6)
	BNE.S	lbC0008E0
	MOVE.B	$11(A5),D2
	MOVE.B	$2B(A6),-(A7)
	CLR.W	$2A(A6)
	BSR.S	lbC0008FC
	MOVE.B	(A7)+,$2B(A6)
lbC0008E0	MOVE.B	$2B(A6),$60(A5)
	BRA.W	lbC0006F2

*******************************************************************************
; Macro $1F taken from "Apprentice"
Macro_1F
	move.b	$10(A5),D2
	bsr.b	lbC0008FC
	bra.w	lbC0006EA

*******************************************************************************

lbC0008EA	MOVE.B	$11(A5),D2
	BSR.S	lbC0008FC
	BRA.W	lbC0006EA

lbC0008F4	MOVEQ	#0,D2
	BSR.S	lbC0008FC
	BRA.W	lbC0006EA

lbC0008FC	MOVE.B	$29(A6),D0
	ADD.B	D2,D0
	EXT.W	D0
	LSL.W	#1,D0
	LEA	lbL00144E(PC),A0
	MOVE.W	$22(A5),D1
	EXT.W	D1
	MOVE.W	0(A0,D0.W),D0
	ADD.W	D1,D0
	ADD.W	$2A(A6),D0
	MOVE.W	D0,$A0(A5)
	TST.W	$C0(A5)
	BNE.L	lbC00092A
	MOVE.W	D0,6(A4)

	bsr.w	SetPer

lbC00092A	RTS

lbC00092C	MOVE.W	$2A(A6),$A0(A5)
	TST.W	$C0(A5)
	BNE.L	lbC0006F2
	MOVE.W	$2A(A6),6(A4)

	move.l	D0,-(A7)
	move.w	$2A(A6),D0
	bsr.w	SetPer
	move.l	(A7)+,D0

	BRA.W	lbC0006F2

lbC000944	MOVE.B	$29(A6),$82(A5)
	MOVE.B	#1,$83(A5)
	MOVE.W	$2A(A6),$C0(A5)
	MOVE.W	$A0(A5),$C2(A5)
	BRA.W	lbC0006F2

lbC000960	MOVE.B	$29(A6),D0
	MOVE.B	D0,$92(A5)
	LSR.B	#1,D0
	MOVE.B	D0,$93(A5)
	MOVE.B	$2B(A6),$80(A5)
	MOVE.B	#1,$81(A5)
	TST.W	$C0(A5)
	BNE.L	lbC0006F2
	MOVE.W	$A0(A5),6(A4)

	move.l	D0,-(A7)
	move.w	$A0(A5),D0
	bsr.w	SetPer
	move.l	(A7)+,D0

	CLR.W	$90(A5)
	BRA.W	lbC0006F2

lbC000990	MOVE.B	$2A(A6),$70(A5)
	MOVE.B	$29(A6),$73(A5)
	MOVE.B	$2A(A6),$71(A5)
	MOVE.B	$2B(A6),$72(A5)
	BRA.W	lbC0006F2

lbC0009AC	CLR.B	$70(A5)
	CLR.B	$92(A5)
	CLR.W	$C0(A5)
	BRA.W	lbC0006F2

lbC0009BC	MOVE.W	$112(A5),$DFF09A
	MOVE.W	$112(A5),$DFF09C
	MOVE.W	$52(A5),$DFF096
	BRA.W	lbC0006F2

lbC0009D8	TST.B	$D2(A5)
	BEQ.L	lbC0006F2
	TST.B	$62(A5)
	BEQ.S	lbC0009F6
	CMPI.B	#$FF,$62(A5)
	BEQ.S	lbC000A00
	SUBI.B	#1,$62(A5)
	BRA.S	lbC000A0C

lbC0009F6	MOVE.B	#$FF,$62(A5)
	BRA.W	lbC0006F2

lbC000A00	MOVE.B	$2B(A6),D0
	SUBI.B	#1,D0
	MOVE.B	D0,$62(A5)
lbC000A0C	RTS

lbC000A0E	MOVE.L	$30(A5),$E0(A5)
	MOVE.W	$40(A5),$F0(A5)
	MOVE.B	$29(A6),D0
	ANDI.L	#$7F,D0
	MOVEA.L	0(A6),A0
	LSL.W	#2,D0
	ADDA.L	D0,A0
	MOVE.L	$600(A0),D0
	ADD.L	0(A6),D0
	MOVE.L	D0,$30(A5)
	MOVE.W	$2A(A6),$40(A5)
	BRA.W	lbC00067A

lbC000A42
	MOVE.L	$E0(A5),$30(A5)
	MOVE.W	$F0(A5),$40(A5)
	BRA.W	lbC0006F2

lbC000A52	MOVE.L	$28(A6),D0
	ANDI.L	#$FFFF,D0
	ADD.L	D0,$B0(A5)
	MOVE.L	$B0(A5),(A4)
	LSR.W	#1,D0
	SUB.W	D0,$D0(A5)
	MOVE.W	$D0(A5),4(A4)
	BRA.W	lbC0006F2

lbC000A74	MOVE.L	4(A6),$B0(A5)
	MOVE.L	4(A6),(A4)
	MOVE.W	#1,$D0(A5)
	MOVE.W	#1,4(A4)
	BRA.W	lbC0006F2

lbC000A8E	BRA.W	lbC0006F2

lbL000A92
	dc.l	lbC0006FA-TFMXbase
	dc.l	lbC000720-TFMXbase
	dc.l	lbC00072A-TFMXbase
	dc.l	lbC00075C-TFMXbase
	dc.l	lbC00076A-TFMXbase
	dc.l	lbC000820-TFMXbase
	dc.l	lbC000860-TFMXbase
	dc.l	lbC00088E-TFMXbase
	dc.l	lbC0008EA-TFMXbase
	dc.l	lbC0008F4-TFMXbase
	dc.l	lbC0009AC-TFMXbase
	dc.l	lbC000944-TFMXbase
	dc.l	lbC000960-TFMXbase
	dc.l	lbC000894-TFMXbase
	dc.l	lbC0008C6-TFMXbase
	dc.l	lbC000990-TFMXbase
	dc.l	lbC000856-TFMXbase
	dc.l	lbC00073A-TFMXbase
	dc.l	lbC000748-TFMXbase
	dc.l	lbC0009BC-TFMXbase
	dc.l	lbC0009D8-TFMXbase
	dc.l	lbC000A0E-TFMXbase
	dc.l	lbC000A42-TFMXbase
	dc.l	lbC00092C-TFMXbase
	dc.l	lbC000A52-TFMXbase
	dc.l	lbC000A74-TFMXbase
	dc.l	lbC00078C-TFMXbase
	dc.l	lbC00081C-TFMXbase
	dc.l	lbC0007F0-TFMXbase
	dc.l	lbC000806-TFMXbase
	dc.l	lbC000A8E-TFMXbase
;	dc.l	lbC000A8E-TFMXbase

	dc.l	Macro_1F-TFMXbase

	dc.l	lbC000774-TFMXbase
	dc.l	lbC00077C-TFMXbase
	dc.l	lbC000780-TFMXbase
	dc.l	lbC000784-TFMXbase
	dc.l	lbC000788-TFMXbase

lbC000B26	TST.B	$92(A5)
	BEQ.S	lbC000B62
	MOVE.B	$80(A5),D0
	EXT.W	D0
	ADD.W	D0,$90(A5)
	MOVE.W	$90(A5),D0
	ADD.W	$A0(A5),D0
	TST.W	$C0(A5)
	BNE.S	lbC000B48
	MOVE.W	D0,6(A4)
lbC000B48	SUBI.B	#1,$93(A5)
	BNE.S	lbC000B62
	MOVE.B	$92(A5),$93(A5)
	EORI.B	#$FF,$80(A5)
	ADDI.B	#1,$80(A5)
lbC000B62	RTS

lbC000B64	TST.W	$C0(A5)
	BEQ.S	lbC000B62
	SUBI.B	#1,$83(A5)
	BNE.S	lbC000B62
	MOVE.B	$82(A5),$83(A5)
	MOVE.W	$A0(A5),D1
	MOVE.W	$C2(A5),D0
	CMP.W	D1,D0
	BEQ.S	lbC000B62
	BCS.S	lbC000BA6
	SUB.W	$C0(A5),D0
	CMP.W	D1,D0
	BEQ.S	lbC000B90
	BCC.S	lbC000B98
lbC000B90	CLR.W	$C0(A5)
	MOVE.W	$A0(A5),D0
lbC000B98	ANDI.W	#$7FF,D0
	MOVE.W	D0,$C2(A5)
	MOVE.W	D0,6(A4)
	RTS

lbC000BA6	ADD.W	$C0(A5),D0
	CMP.W	D1,D0
	BEQ.S	lbC000B90
	BCC.S	lbC000B90
	BRA.S	lbC000B98

lbC000BB2	TST.B	$70(A5)
	BEQ.S	lbC000BC4
	TST.B	$71(A5)
	BEQ.S	lbC000BC6
	SUBI.B	#1,$71(A5)
lbC000BC4	RTS

lbC000BC6	MOVE.B	$70(A5),$71(A5)
	MOVE.B	$72(A5),D0
	CMP.B	$60(A5),D0
	BGT.S	lbC000BF6
	MOVE.B	$73(A5),D1
	SUB.B	D1,$60(A5)
	BMI.L	lbC000BEA
	CMP.B	$60(A5),D0
	BGE.S	lbC000BEA
	RTS

lbC000BEA	MOVE.B	$72(A5),$60(A5)
	CLR.B	$70(A5)
	RTS

lbC000BF6	MOVE.B	$73(A5),D1
	ADD.B	D1,$60(A5)
	CMP.B	$60(A5),D0
	BLE.S	lbC000BEA
	RTS

NOTEPORT	MOVEM.L	D0/A4-A6,-(A7)
	LEA	lbL001102(PC),A6
	MOVE.L	$28(A6),-(A7)
	LEA	lbL001160(PC),A5
	MOVE.L	D0,$28(A6)
	MOVE.B	$2A(A6),D0
	ANDI.L	#3,D0
	LSL.W	#2,D0
	ADDA.L	D0,A5
	TST.B	$103(A5)
	BNE.L	lbC000CDE
	CMPI.B	#$F7,$28(A6)
	BNE.S	lbC000C54
	MOVE.B	#1,$70(A5)
	MOVE.B	$29(A6),$73(A5)
	MOVE.B	#1,$71(A5)
	MOVE.B	$2B(A6),$72(A5)
	BRA.W	lbC000CDE

lbC000C54	CMPI.B	#$F6,$28(A6)
	BNE.S	lbC000C80
	MOVE.B	$29(A6),D0
	ANDI.B	#$FE,D0
	MOVE.B	D0,$92(A5)
	LSR.B	#1,D0
	MOVE.B	D0,$93(A5)
	MOVE.B	$2B(A6),$80(A5)
	MOVE.B	#1,$81(A5)
	CLR.W	$90(A5)
	BRA.S	lbC000CDE

lbC000C80	CMPI.B	#$F5,$28(A6)
	BNE.S	lbC000C8E
	CLR.B	$D2(A5)
	BRA.S	lbC000CDE

lbC000C8E	CMPI.B	#$BF,$28(A6)
	BCC.S	lbC000CE8
	ANDI.W	#$3FFF,$28(A6)
	MOVE.B	$2B(A6),$23(A5)
	MOVE.B	$2A(A6),D0
	LSR.B	#4,D0
	ANDI.B	#15,D0
	MOVE.B	D0,$21(A5)
	MOVE.B	$29(A6),D0
	MOVE.B	D0,$13(A5)

	move.b	$11(A5),$10(A5)		; macro $1F (update from Apprentice)

	MOVE.B	$28(A6),$11(A5)
	MOVEA.L	0(A6),A4
	LSL.W	#2,D0
	ADDA.L	D0,A4
	MOVEA.L	$600(A4),A4
	ADDA.L	0(A6),A4
	MOVE.L	A4,$30(A5)
	MOVE.W	#1,2(A5)
	MOVE.B	#1,$D2(A5)
lbC000CDE	MOVE.L	(A7)+,$28(A6)
	MOVEM.L	(A7)+,D0/A4-A6
	RTS

lbC000CE8	MOVE.L	D1,-(A7)
	MOVE.B	$29(A6),$82(A5)
	MOVE.B	#1,$83(A5)
	CLR.B	$C0(A5)
	MOVE.B	$2B(A6),$C1(A5)
	MOVE.W	$A0(A5),$C2(A5)
	MOVE.B	$28(A6),D0
	ANDI.W	#$3F,D0
	MOVE.B	D0,$11(A5)
	LSL.W	#1,D0
	LEA	lbL00144E(PC),A4
	MOVE.W	0(A4,D0.W),$A0(A5)
	MOVE.L	(A7)+,D1
	BRA.S	lbC000CDE

CHANNELOFF	MOVEM.L	A5,-(A7)
	LEA	lbL001160(PC),A5
	ANDI.W	#3,D0
	LSL.W	#2,D0
	ADDA.W	D0,A5
	MOVE.W	$52(A5),$DFF096
	CLR.W	2(A5)
	CLR.B	$123(A5)
	MOVEM.L	(A7)+,A5
	RTS

lbC000D48	BTST	#5,$3D(A6)
	BNE.S	lbC000D54
	BSR.W	ALLOFF
lbC000D54	CLR.B	$2E(A6)
	MOVE.W	#1,$44(A6)
	MOVEA.L	4(A6),A4
	CLR.L	(A4)
	MOVEA.L	0(A6),A4
	MOVE.W	$3C(A6),D0
	ANDI.L	#$1F,D0
	LSL.L	#1,D0
	ADDA.L	D0,A4
	LEA	lbL0012D0(PC),A5
	LEA	lbL001398(PC),A0
	MOVE.W	12(A6),D1
	ANDI.W	#$1F,D1
	LSL.W	#1,D1
	MOVE.W	4(A5),0(A0,D1.W)
	MOVE.B	$3F(A6),$40(A0,D1.W)
	MOVE.B	7(A5),$41(A0,D1.W)
	CLR.W	$3E(A6)
	MOVE.W	$100(A4),4(A5)
	MOVE.W	$100(A4),0(A5)
	MOVE.W	$140(A4),2(A5)
	MOVE.W	$180(A4),6(A5)
	MOVE.W	#$1C,D1
	BTST	#6,$3D(A6)
	BEQ.S	lbC000DD4
	MOVE.W	0(A0,D0.W),4(A5)
	MOVE.B	$40(A0,D0.W),$3F(A6)
	MOVE.B	$41(A0,D0.W),7(A5)
lbC000DD4	MOVE.B	$5C(A6),$4A(A6)
	CMPI.W	#15,6(A5)
	BLS.S	lbC000E34
	CMPI.W	#$1F,6(A5)
	BLS.S	lbC000E22
;	MOVEM.L	D0/D1,-(A7)
;	MOVE.W	6(A5),D0
	MOVE.W	#5,6(A5)
;	MOVE.L	#$1C00,D1
;	DIVU.W	D0,D1
;	MOVE.B	D1,$BFD700
;	MOVE.B	#0,$BFD600
	MOVE.B	#1,$5C(A6)
	MOVE.B	#1,$4A(A6)
;	MOVEM.L	(A7)+,D0/D1
	BRA.W	lbC000E34

lbC000E22	MOVE.W	#1,$3E(A6)
	SUBI.W	#$10,6(A5)
	MOVE.W	#2,$44(A6)
lbC000E34	MOVE.L	lbL00142E(PC),$28(A5,D1.W)
	MOVE.W	#$FF00,$48(A5,D1.W)
	CLR.L	$68(A5,D1.W)
	SUBI.W	#4,D1
	BPL.S	lbC000DD4
	CMPI.W	#$1FF,0(A5)
	BEQ.S	lbC000E5A
	MOVEA.L	0(A6),A4
	BSR.W	lbC0003B6
lbC000E5A	CLR.W	10(A6)
	CLR.W	$2C(A6)
	BSET	#1,$BFE001
	MOVE.W	#$FF,$DFF09E
	MOVE.W	$3C(A6),D0
	ANDI.W	#$1F,D0
	MOVE.W	D0,12(A6)
	MOVE.B	#$FF,$3D(A6)
	LEA	lbL001418(PC),A4
	CLR.W	2(A4)
	LEA	lbL001160(PC),A5
	CLR.B	$103(A5)
	CLR.B	$107(A5)
	CLR.B	$10B(A5)
	CLR.B	$10F(A5)
	CLR.W	$100(A5)
	CLR.W	$104(A5)
	CLR.W	$108(A5)
	CLR.W	$10C(A5)
	MOVE.B	#1,$2E(A6)
	RTS

FADE	MOVEM.L	A5/A6,-(A7)
	LEA	lbL001102(PC),A6
	LEA	lbL001418(PC),A5
	MOVE.W	#1,0(A5)
	MOVE.B	D0,$51(A6)
	SWAP	D0
	MOVE.B	D0,$52(A6)
	MOVE.B	D0,$53(A6)
	BEQ.S	lbC000EF2
	MOVE.B	$50(A6),D0
	MOVE.B	#1,$1C(A6)
	CMP.B	$51(A6),D0
	BEQ.S	lbC000EF8
	BCS.S	lbC000F02
	NEG.B	$1C(A6)
	BRA.S	lbC000F02

lbC000EF2	MOVE.B	$51(A6),$50(A6)
lbC000EF8	MOVE.B	#0,$1C(A6)
	CLR.W	0(A5)
lbC000F02	MOVEM.L	(A7)+,A5/A6
	RTS

;INFO	LEA	lbL001418(PC),A0
;	RTS

;lbC000F0E	MOVE.L	A0,-(A7)
;	LEA	lbL001418(PC),A0
;	MOVE.W	#1,2(A0)
;	CLR.W	0(A0)
;	CLR.B	$2E(A6)
;	MOVEA.L	(A7)+,A0
;	RTS

;FXPLAY	MOVEM.L	D1-D3/A4-A6,-(A7)
;	LEA	lbL001102(PC),A6
;	LEA	lbL001160(PC),A4
;	MOVE.W	D0,D2
;	MOVEA.L	0(A6),A5
;	ADDA.L	#$5FC,A5
;	MOVEA.L	(A5),A5
;	ADDA.L	0(A6),A5
;	ANDI.W	#$3F,D2
;	LSL.W	#3,D2
;	MOVE.B	2(A5,D2.W),D1
;	CMPI.B	#$1F,13(A6)
;	BNE.L	lbC000F5C
;	MOVE.B	4(A5,D2.W),D1
;lbC000F5C	ANDI.L	#3,D1
;	LSL.W	#2,D1
;	MOVE.L	D1,D3
;	LSL.W	#6,D3
;	ADDA.L	D1,A4
;	CMP.B	$102(A4),D2
;	BNE.S	lbC000F7A
;	BTST	#7,5(A5,D2.W)
;	BNE.S	lbC000FAE
;	BRA.S	lbC000F8A

;lbC000F7A	MOVE.B	5(A5,D2.W),D1
;	CMP.B	$103(A4),D1
;	BGE.S	lbC000F8A
;	TST.W	$100(A4)
;	BPL.S	lbC000FAE
;lbC000F8A	CLR.B	$103(A4)
;	MOVE.L	0(A5,D2.W),D0
;	ANDI.L	#$FFFFF0FF,D0
;	OR.L	D3,D0
;	BSR.W	NOTEPORT
;	MOVE.B	5(A5,D2.W),$103(A4)
;	MOVE.W	6(A5,D2.W),$100(A4)
;	MOVE.B	D2,$102(A4)
;lbC000FAE	MOVEM.L	(A7)+,D1-D3/A4-A6
;	RTS

;lbC000FB4	BSET	#5,D0
SONGPLAY	MOVEM.L	A5/A6,-(A7)
;	BSR.W	TIMERINIT
	LEA	lbL001102(PC),A6
	MOVE.W	D0,$3C(A6)
	CLR.B	$4A(A6)
	MOVEM.L	(A7)+,A5/A6
	RTS

;PLAYCONT	MOVEM.L	A5/A6,-(A7)
;	BSR.W	TIMERINIT
;	LEA	lbL001102(PC),A6
;	BSET	#6,D0
;	MOVE.W	D0,$3C(A6)
;	MOVEM.L	(A7)+,A5/A6
;	RTS

ALLOFF	MOVEM.L	D0/A4-A6,-(A7)
	LEA	lbL001102(PC),A6
	CLR.B	$2E(A6)
	CLR.W	$DFF0A8
	CLR.W	$DFF0B8
	CLR.W	$DFF0C8
	CLR.W	$DFF0D8
	MOVE.W	#15,$DFF096
	LEA	lbL001160(PC),A5
	CLR.W	2(A5)
	CLR.W	6(A5)
	CLR.W	10(A5)
	CLR.W	14(A5)
	CLR.B	$123(A5)
	CLR.B	$127(A5)
	CLR.B	$12B(A5)
	CLR.B	$12F(A5)
	MOVEM.L	(A7)+,D0/A4-A6
	RTS

INITDATA	MOVEM.L	A4-A6,-(A7)
	LEA	lbL001102(PC),A6
	MOVE.L	#$40400000,$50(A6)
	MOVE.L	D0,0(A6)
	MOVE.L	D1,4(A6)
	MOVE.W	#1,8(A6)
	MOVEA.L	D0,A5
	MOVEA.L	D0,A4
	ADDA.L	#$100,A5
	ADDA.L	#$180,A4
	LEA	lbL001398(PC),A6
	MOVE.W	#$1F,D0
lbC001078	MOVE.W	(A4)+,$40(A6)
	MOVE.W	(A5)+,(A6)+
	DBRA	D0,lbC001078
;	LEA	lbC00079C(PC),A4
;	MOVE.L	A4,$70

	bsr.w	SetAudioVector

	MOVEM.L	(A7)+,A4-A6
	RTS

;TIMERINIT	MOVEM.L	A5/A6,-(A7)
;	LEA	lbL001102(PC),A6
;	CLR.B	$5C(A6)
;	MOVE.B	#$37,$BFD700
;	MOVE.B	#$F0,$BFD600
;	TST.L	$4C(A6)
;	BNE.S	lbC0010D6
;	MOVE.L	$78,$4C(A6)
;	LEA	lbC0010DC(PC),A6
;	MOVE.L	A6,$78
;	MOVE.B	#$11,$BFDF00
;	MOVE.B	#$82,$BFDD00
;lbC0010D6	MOVEM.L	(A7)+,A5/A6
;	RTS

;lbC0010DC	MOVEM.L	D0/A6,-(A7)
;	MOVE.B	$BFDD00,D0
;	LEA	lbL001102(PC),A6
;	TST.B	$4A(A6)
;	BEQ.S	lbC0010F4
;	BSR.W	lbC00006A
;lbC0010F4	MOVE.W	#$2000,$DFF09C
;	MOVEM.L	(A7)+,D0/A6
;	RTE

lbL001102	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	$FFFF0000
	dc.l	0
	dc.l	$10000
	dc.l	0
	dc.l	0
	dc.l	$40400000
	dc.l	0
	dc.w	0
lbL00115C	dc.l	0
lbL001160	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	$82010001
	dc.l	$82020002
	dc.l	$82040004
	dc.l	$82080008
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	$C0800080
	dc.l	$C1000100
	dc.l	$C2000200
	dc.l	$C4000400
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	4
	dc.l	4
	dc.l	4
	dc.l	$FFFFFFF4
	dc.l	$DFF0A0
	dc.l	$DFF0B0
	dc.l	$DFF0C0
	dc.l	$DFF0D0
lbL0012D0
FirstUsed
	dc.w	0
LastUsed
	dc.w	0
CurrentPos
	dc.w	0
ActualSpeed
	dc.w	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbL001398	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbL001418	dc.l	2
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
lbL00142E	dc.l	$F4000000
	dc.l	$F0000000
	dc.l	$D5C0C9C
	dc.l	$BE80B3C
	dc.l	$A9A0A02
	dc.l	$97208EA
	dc.l	$86A07F2
	dc.l	$7800718
lbL00144E	dc.l	$6AE064E
	dc.l	$5F4059E
	dc.l	$54D0501
	dc.l	$4B90475
	dc.l	$43503F9
	dc.l	$3C0038C
	dc.l	$358032A
	dc.l	$2FC02D0
	dc.l	$2A80282
	dc.l	$25E023B
	dc.l	$21B01FD
	dc.l	$1E001C6
	dc.l	$1AC0194
	dc.l	$17D0168
	dc.l	$1540140
	dc.l	$12F011E
	dc.l	$10E00FE
	dc.l	$F000E3
	dc.l	$D600CA
	dc.l	$BF00B4
	dc.l	$AA00A0
	dc.l	$97008F
	dc.l	$87007F
	dc.l	$780071
	dc.l	$D600CA
	dc.l	$BF00B4
	dc.l	$AA00A0
	dc.l	$97008F
	dc.l	$87007F
	dc.l	$780071
	dc.l	$D600CA
	dc.l	$BF00B4

	Section HeaderBuffer,BSS
Header
	ds.b	248*2

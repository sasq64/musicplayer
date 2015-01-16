	*****************************************************
	****   Thomas Hermann replayer for EaglePlayer,  ****
	****	     all adaptions by Wanted Team	 ****
	****     DeliTracker 2.32 compatible version	 ****
	*****************************************************

	incdir	"dh2:include/"
	include 'misc/eagleplayer2.01.i'
	include 'hardware/intbits.i'
	include 'exec/exec_lib.i'
	include	'exec/execbase.i'

	SECTION Player,Code

	PLAYERHEADER Tags

	dc.b	'$VER: Thomas Hermann player module V1.1 (1 Feb 2002)',0
	even
Tags
	dc.l	DTP_PlayerVersion,2
	dc.l	EP_PlayerVersion,9
	dc.l	DTP_RequestDTVersion,'WT'
	dc.l	DTP_PlayerName,PlayerName
	dc.l	DTP_Creator,Creator
	dc.l	DTP_Check2,Check2
	dc.l	DTP_Interrupt,Interrupt
	dc.l	DTP_SubSongRange,SubSongRange
	dc.l	DTP_InitPlayer,InitPlayer
	dc.l	DTP_EndPlayer,EndPlayer
	dc.l	DTP_InitSound,InitSound
	dc.l	DTP_EndSound,EndSound
	dc.l	EP_NewModuleInfo,NewModuleInfo
	dc.l	DTP_ExtLoad,ExtLoad
	dc.l	DTP_Volume,SetVolume
	dc.l	DTP_Balance,SetBalance
	dc.l	EP_Voices,SetVoices
	dc.l	EP_StructInit,StructInit
	dc.l	EP_GetPositionNr,GetPosition
	dc.l	EP_SampleInit,SampleInit
	dc.l	DTP_NextPatt,Next_Pattern
	dc.l	DTP_PrevPatt,BackPattern
	dc.l	EP_Flags,EPB_Volume!EPB_Balance!EPB_ModuleInfo!EPB_Voices!EPB_SampleInfo!EPB_Songend!EPB_Analyzer!EPB_NextSong!EPB_PrevSong!EPB_Packable!EPB_Restart!EPB_PrevPatt!EPB_NextPatt!EPB_LoadFast
	dc.l	DTP_Duration,CalcDuration
	dc.l	TAG_DONE
PlayerName
	dc.b	'Thomas Hermann',0
Creator
	dc.b	"(c) 1989 by Thomas Hermann,",10
	dc.b	'adapted by Wanted Team',0
Prefix
	dc.b	'THM.',0
SamplesPath
	dc.b	'Instruments/',0
	even
ModulePtr
	dc.l	0
EagleBase
	dc.l	0
SongData
	dc.l	0
SongData3
	dc.w	$006F				; kramer extension
	dc.w	$FE03
	dc.w	$8087
	dc.w	$7F03
	dc.w	$8989
	dc.w	$8803
SongData5
	dc.w	$115A				; Blue Angel 69 extension
	dc.w	$FF03
	dc.w	$6085
	dc.w	$5F05
	dc.w	$90B5
	dc.w	$8F05
	dc.w	$C0C7
	dc.w	$BF03
	dc.w	$D5D6
	dc.w	$CF03
Interrupts
	dc.l	0
Timer
	dc.w	0
SamplesVer
	dc.w	0
EndPos
	dc.b	0
FirstPos
	dc.b	0
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
******************************* DTP_Duration ******************************
***************************************************************************

CalcDuration
	move.l	Interrupts(PC),D0
	move.l	ModulePtr(PC),A0
	mulu.w	42(A0),D0
	rts

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
	and.w	#$7F,D2
	cmp.w	#$A8,D1
	beq.s	Left1
	cmp.w	#$B8,D1
	beq.s	Right1
	cmp.w	#$C8,D1
	beq.s	Right2
	cmp.w	#$D8,D1
	bne.s	Exit
Left2
	mulu.w	LeftVolume(PC),D2
	and.w	Voice4(PC),D2
	bra.s	Ex
Left1
	mulu.w	LeftVolume(PC),D2
	and.w	Voice1(PC),D2
	bra.s	Ex

Right1
	mulu.w	RightVolume(PC),D2
	and.w	Voice2(PC),D2
	bra.s	Ex
Right2
	mulu.w	RightVolume(PC),D2
	and.w	Voice3(PC),D2
Ex
	lsr.w	#6,D2
Exit
	rts

ChangeVolume2
	and.w	#$7F,D1
	cmp.w	#$A8,D5
	beq.s	Left12
	cmp.w	#$B8,D5
	beq.s	Right12
	cmp.w	#$C8,D5
	beq.s	Right22
	cmp.w	#$D8,D5
	bne.s	Exit2
Left22
	mulu.w	LeftVolume(PC),D1
	and.w	Voice4(PC),D1
	bra.s	Ex2
Left12
	mulu.w	LeftVolume(PC),D1
	and.w	Voice1(PC),D1
	bra.s	Ex2

Right12
	mulu.w	RightVolume(PC),D1
	and.w	Voice2(PC),D1
	bra.s	Ex2
Right22
	mulu.w	RightVolume(PC),D1
	and.w	Voice3(PC),D1
Ex2
	lsr.w	#6,D1
Exit2
	rts

*------------------------------- Set Vol -------------------------------*

SetVol
	move.l	A0,-(A7)
	lea	StructAdr+UPS_Voice1Vol(PC),A0
	cmp.w	#$A8,D1
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice2Vol(PC),A0
	cmp.w	#$B8,D1
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice3Vol(PC),A0
	cmp.w	#$C8,D1
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice4Vol(PC),A0
.SetVoice
	move.w	D2,(A0)
	move.l	(A7)+,A0
	rts

*------------------------------- Set Vol -------------------------------*

SetVol2
	move.l	A0,-(A7)
	lea	StructAdr+UPS_Voice1Vol(PC),A0
	cmp.w	#$A8,D5
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice2Vol(PC),A0
	cmp.w	#$B8,D5
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice3Vol(PC),A0
	cmp.w	#$C8,D5
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice4Vol(PC),A0
.SetVoice
	move.w	D1,(A0)
	move.l	(A7)+,A0
	rts

*------------------------------- Set Adr -------------------------------*

SetAdr
	move.l	A0,-(A7)
	lea	StructAdr+UPS_Voice1Adr(PC),A0
	cmp.w	#$A0,D1
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice2Adr(PC),A0
	cmp.w	#$B0,D1
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice3Adr(PC),A0
	cmp.w	#$C0,D1
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice4Adr(PC),A0
.SetVoice
	move.l	4(A2),(A0)
	move.l	(A7)+,A0
	rts

*------------------------------- Set Len -------------------------------*

SetLen
	move.l	A0,-(A7)
	lea	StructAdr+UPS_Voice1Len(PC),A0
	cmp.w	#$A4,D1
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice2Len(PC),A0
	cmp.w	#$B4,D1
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice3Len(PC),A0
	cmp.w	#$C4,D1
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice4Len(PC),A0
.SetVoice
	move.w	D2,(A0)
	move.l	(A7)+,A0
	rts

*------------------------------- Set Per -------------------------------*

SetPer
	move.l	A0,-(A7)
	lea	StructAdr+UPS_Voice1Per(PC),A0
	cmp.w	#$A6,D1
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice2Per(PC),A0
	cmp.w	#$B6,D1
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice3Per(PC),A0
	cmp.w	#$C6,D1
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice4Per(PC),A0
.SetVoice
	move.w	D2,(A0)
	move.l	(A7)+,A0
	rts

***************************************************************************
****************************** EP_Voices  *********************************
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
******************************* EP_StructInit *****************************
***************************************************************************

StructInit
	lea	StructAdr(PC),A0
	rts

***************************************************************************
******************************* DTP_NextPatt ******************************
***************************************************************************

Next_Pattern
	move.l	ModulePtr(PC),A4
	lea	$22(A4),A4
	move.b	(A4),D7
	move.l	dtg_StopInt(A5),A0
	jsr	(A0)
	bsr.w	EndSound
	bsr.w	InitSound
	addq.b	#1,D7
	cmp.b	EndPos(PC),D7
	bhi.b	MaxPos
	move.b	D7,(A4)
	bra.b	NoEnd
MaxPos
	bsr.w	SongEnd
NoEnd
	move.l	dtg_StartInt(A5),A0
	jsr	(A0)
	rts

***************************************************************************
******************************* DTP_BackPatt ******************************
***************************************************************************

BackPattern
	move.l	ModulePtr(PC),A4
	lea	$22(A4),A4
	move.b	(A4),D7
	cmp.b	FirstPos(PC),D7
	beq.b	MinPos
	move.l	dtg_StopInt(A5),A0
	jsr	(A0)
	bsr.w	EndSound
	bsr.w	InitSound
	subq.b	#1,D7
	move.b	D7,(A4)
	move.l	dtg_StartInt(A5),A0
	jsr	(A0)
MinPos
	rts

***************************************************************************
******************************* EP_SampleInit *****************************
***************************************************************************

SampleInit
	moveq	#EPR_NotEnoughMem,D7
	lea	EPG_SampleInfoStructure(A5),A3
	move.l	ModulePtr(PC),D0
	beq.b	return
	move.l	D0,A2
	lea	5358(A2),A2
	move.l	InfoBuffer+Samples(PC),D5
	subq.l	#1,D5
hop
	jsr	ENPP_AllocSampleStruct(A5)
	move.l	D0,(A3)
	beq.b	return
	move.l	D0,A3

	move.l	(A2),D0	
	move.l	6(A2),A0
	lea	16(A2),A1

	move.l	A0,EPS_Adr(A3)			; sample address
	move.l	A1,EPS_SampleName(A3)		; sample name
	move.l	D0,EPS_Length(A3)		; sample length
	move.l	#64,EPS_Volume(A3)
	move.w	#22,EPS_MaxNameLen(A3)
	move.w	#USITY_RAW,EPS_Type(A3)
	move.w	#USIB_Playable!USIB_Saveable!USIB_8BIT,EPS_Flags(A3)
	lea	48(A2),A2
	dbf	D5,hop

	moveq	#0,D7
return
	move.l	D7,D0
	rts

***************************************************************************
********************************* EP_GetPosNr *****************************
***************************************************************************

GetPosition
	moveq	#0,D0
	move.l	ModulePtr(PC),A0
	move.b	$22(A0),D0
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
******************************* DTP_ExtLoad *******************************
***************************************************************************

ExtLoad
	lea	SamplesVer(PC),A6
	move.l	dtg_PathArrayPtr(A5),A0
	clr.b	(A0)
	move.l	dtg_CopyDir(A5),A0
	jsr	(A0)
	bsr.s	CopyName2
	move.l	dtg_LoadFile(A5),A0
	jsr	(A0)
	tst.l	D0
	beq.b	ExtLoadOK
	bra.b	SecondTry
ExtLoadOK
	clr.w	(A6)
	rts
CopyName2
	move.l	dtg_PathArrayPtr(A5),A0
loop
	tst.b	(A0)+
	bne.s	loop
	subq.l	#1,A0
	move.l	A0,A3
	move.l	dtg_FileArrayPtr(A5),A1
smp
	move.b	(A1)+,(A0)+
	bne.s	smp

	cmpi.b	#'T',(A3)
	beq.b	T_OK
	cmpi.b	#'t',(A3)
	bne.s	ExtError
T_OK
	cmpi.b	#'H',1(A3)
	beq.b	H_OK
	cmpi.b	#'h',1(A3)
	bne.s	ExtError
H_OK
	cmpi.b	#'M',2(A3)
	beq.b	M_OK
	cmpi.b	#'m',2(A3)
	bne.s	ExtError
M_OK
	cmpi.b	#'.',3(A3)
	bne.s	ExtError

	move.b	#'S',(A3)+
	move.b	#'M',(A3)+
	move.b	#'P',(A3)

	bra.b	ExtOK
ExtError
	clr.b	-2(A0)
ExtOK
	clr.b	-1(A0)
	rts

SecondTry
	move.l	dtg_ChkData(A5),A0
	moveq	#0,D2
	move.b	35(A0),D2			; number of samples
	subq.l	#1,D2
	lea	5374(A0),A2
LoadNextSample
	move.l	A2,A4
	bsr.b	LoadFile
	bne.b	ExtError2
	lea	48(A2),A2
	dbf	D2,LoadNextSample
	st	(A6)
ExtError2
	rts

LoadFile
	move.l	dtg_PathArrayPtr(A5),A0
	clr.b	(A0)
	move.l	dtg_CopyDir(A5),A0
	jsr	(A0)
	bsr.b	CopyName
	move.l	dtg_LoadFile(A5),A0
	jsr	(A0)
	rts

CopyName
	movea.l	dtg_PathArrayPtr(A5),A0
loop1
	tst.b	(A0)+
	bne.s	loop1
	subq.l	#1,A0
	lea	SamplesPath(PC),A3
smp1
	move.b	(A3)+,(A0)+
	bne.s	smp1
	subq.l	#1,A0
back
	move.l	A4,A3
CheckName
	move.b	(A3)+,D3
	cmp.b	#':',D3
	beq.b	WrongName
	cmp.b	#'/',D3
	beq.b	WrongName
	tst.b	(A3)
	beq.b	NameOK
	bra.b	CheckName
NameOK
	move.l	A4,A3
smp2
	move.b	(A3)+,(A0)+
	bne.s	smp2
	rts
WrongName
	move.l	A3,A4
	bra.b	back

***************************************************************************
******************************** DTP_Check2 *******************************
***************************************************************************

Check2
	move.l	dtg_ChkData(A5),A0
	moveq	#-1,D0

	cmp.l	#6848,dtg_ChkSize(A5)
	ble.b	fault
	move.l	46(A0),D1
	beq.b	fault
	bmi.b	fault
	btst	#0,D1
	bne.b	fault
	moveq	#64,D2
	move.l	(A0)+,D3
	sub.l	D1,D3
	cmp.l	D2,D3
	bne.b	fault
	move.l	D2,D4
	lsl.l	#4,D2

	moveq	#3,D5
NextLong
	add.l	D2,D4
	move.l	(A0)+,D3
	sub.l	D1,D3
	cmp.l	D4,D3
	bne.b	fault
	dbf	D5,NextLong
	lsr.l	#2,D2
	moveq	#2,D5
NextLong2
	add.l	D2,D4
	move.l	(A0)+,D3
	sub.l	D1,D3
	cmp.l	D4,D3
	bne.b	fault
	dbf	D5,NextLong2
	moveq	#0,D0
fault
	rts

***************************************************************************
****************************** EP_NewModuleInfo ***************************
***************************************************************************

NewModuleInfo

SubSongs	=	4
LoadSize	=	12
Samples		=	20
Length		=	28
SamplesSize	=	36
SongSize	=	44
CalcSize	=	52
Pattern		=	60
Duration	=	68

InfoBuffer
	dc.l	MI_SubSongs,0		;4
	dc.l	MI_LoadSize,0		;12
	dc.l	MI_Samples,0		;20
	dc.l	MI_Length,0		;28
	dc.l	MI_SamplesSize,0	;36
	dc.l	MI_Songsize,0		;44
	dc.l	MI_Calcsize,0		;52
	dc.l	MI_Pattern,0		;60
	dc.l	MI_Duration,0		;68
	dc.l	MI_MaxLength,256
	dc.l	MI_MaxSamples,31
	dc.l	MI_MaxPattern,1024
	dc.l	MI_Prefix,Prefix
	dc.l	MI_AuthorName,PlayerName
	dc.l	0

***************************************************************************
***************************** DTP_InitPlayer ******************************
***************************************************************************

InitPlayer
	moveq	#0,D0
	move.l	dtg_GetListData(A5),A0
	jsr	(A0)
	lea	ModulePtr(PC),A4
	move.l	A0,(A4)+			; module buffer
	move.l	A5,(A4)+			; EagleBase
	lea	InfoBuffer(PC),A6
	move.l	D0,LoadSize(A6)

	move.l	46(A0),D2			; origin
	move.l	A0,A1
	move.l	A0,D3
	moveq	#7,D1
RelocOne
	sub.l	D2,(A1)
	add.l	D3,(A1)+
	dbf	D1,RelocOne

	moveq	#0,D0
	move.w	(A1)+,(A4)+
	move.b	(A1),D0
	bmi.b	NoInit
	st	(A1)
NoInit
	move.b	(A1)+,(A4)+
SkipOne
	move.b	(A1)+,D0
	move.l	D0,Samples(A6)
	subq.l	#1,D0
	move.l	D0,D5
	sub.l	D2,(A1)
	add.l	D3,(A1)+
	addq.l	#4,A1
	move.b	(A1),(A4)

	lea	64(A0),A1
	move.w	#1023,D1
RelocTwo
	sub.l	D2,(A1)
	add.l	D3,(A1)
	move.l	(A1)+,D4
	cmp.l	D4,D0
	bgt.b	MaxAdr
	move.l	D4,D0
MaxAdr
	dbf	D1,RelocTwo
	moveq	#64,D1
	add.l	D1,D0
	sub.l	A0,D0
	cmp.l	LoadSize(A6),D0
	ble.b	SizeOK
SizeError
	moveq	#EPR_ModuleTooShort,D0		; error message
	rts
SizeOK
	move.l	D0,SongSize(A6)
	moveq	#1,D1
	cmp.l	#11792,D0			; fix for Blue Angel 69
	bne.b	NoBlue
	moveq	#5,D1
NoBlue
	cmp.l	#10112,D0			; fix for kramer
	bne.b	NoBK
	moveq	#3,D1
NoBK
	move.l	D1,SubSongs(A6)
	move.l	D0,CalcSize(A6)
	sub.w	#6800,D0
	divu.w	#3,D0
	moveq	#1,D7
	add.b	41(A0),D7			; number of rows
	divu.w	D7,D0
	move.l	D0,Pattern(A6)
	lea	5184(A0),A1
	moveq	#31,D1
RelocThree
	sub.l	D2,(A1)
	add.l	D3,(A1)+
	dbf	D1,RelocThree

	moveq	#1,D6
	lea	5364(A0),A4

	moveq	#0,D4
	lea	SamplesVer(PC),A1
	tst.w	(A1)
	bne.b	MultiFiles
	moveq	#1,D0
	move.l	dtg_GetListData(A5),A0
	jsr	(A0)

	add.l	D0,LoadSize(A6)
NextSample1
	move.l	A0,(A4)
	add.l	-6(A4),A0
	add.l	-6(A4),D4

	lea	48(A4),A4
	dbf	D5,NextSample1
	bra.b	SkipMulti
MultiFiles
	moveq	#104,D3
	moveq	#0,D2
NextSample
	move.l	D6,D0
	move.l	dtg_GetListData(A5),A0
	jsr	(A0)

	cmp.l	#'FORM',(A0)
	bne.b	NoIFF
	add.l	D3,A0
	add.l	D3,D4
NoIFF
	move.l	A0,(A4)
	add.l	-6(A4),D4
	add.l	D0,D2
	addq.l	#1,D6
	lea	48(A4),A4
	dbf	D5,NextSample

	add.l	D2,LoadSize(A6)
SkipMulti
	move.l	D4,SamplesSize(A6)
	add.l	D4,CalcSize(A6)

	move.l	ModulePtr(PC),A0
	moveq	#0,D0
	move.b	34(A0),D0
	moveq	#64,D1
	lsl.l	#2,D1
	sub.l	D0,D1
	add.b	33(A0),D1
	addq.l	#1,D1				; song length
	moveq	#2,D0
	add.b	44(A0),D0			; song speed
	mulu.w	D0,D1
	move.l	D1,D2
	mulu.w	42(A0),D1			; dtg_Timer value

        move.l	#(709379-3),D3		; PAL ex_EClockFrequency
	cmp.w	#$37EE,dtg_Timer(A5)
	bne.b	NoNTSC
        move.l	#(715909-5),D3		; NTSC ex_EClockFrequency
NoNTSC
	divu.w	D7,D3
	divu.w	D3,D1
	move.w	D1,Duration+2(A6)

	mulu.w	D7,D2
	lea	Interrupts(PC),A0
	move.l	D2,(A0)				; Interrupts

	lea	CiaName(PC),A1
	move.l	4.W,A6
	jsr	_LVOOpenResource(A6)	; open resource
	move.l	D0,ResourcePtr		; resource pointer
	beq.b	AllocError
	move.l	D0,A6			; resource base
	lea	InterruptStruct(PC),A1	; interrupt structure
	moveq	#1,D0			; ICRbit
	jsr	-6(A6)			; AddICRVector
	tst.l	D0
	bne.s	AudioError

	move.l	dtg_AudioAlloc(A5),A0
	jmp	(A0)

AllocError
	moveq	#EPR_CantAllocCia,D0
	rts

AudioError
	moveq	#EPR_CantAllocAudio,D0
	rts

ResourcePtr
	dc.l	0
CiaName
	dc.b	'ciab.resource',0

TimName
	dc.b	'Thomas Hermann Timer Interrupt',0
	even

***************************************************************************
***************************** DTP_EndPlayer *******************************
***************************************************************************

EndPlayer
	move.l	ResourcePtr(PC),D0
	beq.b	FreeAudio
	move.l	D0,A6			; resource base
	moveq	#1,D0
	lea	InterruptStruct(PC),A1	; interrupt structure
	jsr	-12(A6)			; RemICRVector
FreeAudio
	move.l	dtg_AudioFree(A5),A0
	jmp	(A0)

***************************************************************************
***************************** DTP_Intterrupt ******************************
***************************************************************************

Interrupt
	movem.l	D1-A6,-(SP)

	lea	StructAdr(PC),A0
	st	UPS_Enabled(A0)
	move.w	#UPSB_Adr!UPSB_Len!UPSB_Per!UPSB_Vol,UPS_Flags(A0)
	clr.w	UPS_Voice1Per(A0)
	clr.w	UPS_Voice2Per(A0)
	clr.w	UPS_Voice3Per(A0)
	clr.w	UPS_Voice4Per(A0)

	bsr.w	Play

	lea	StructAdr(PC),A0
	clr.w	UPS_Enabled(A0)

	movem.l	(SP)+,D1-A6
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
IntName
	dc.b	'Thomas Hermann Audio Interrupt',0
	even

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

	lea	lbB00C7BC(PC),A0
	lea	lbW00C85C(PC),A1
Clear_1
	clr.w	(A0)+
	cmp.l	A0,A1
	bne.b	Clear_1

	move.w	Timer(PC),D0
	bne.b	TimerOK
	move.w	dtg_Timer(A5),Timer
TimerOK
	move.w	dtg_SndNum(A5),D0
	move.l	ModulePtr(PC),A0
	lea	lbL00C7D8(PC),A1
	move.l	A0,(A1)
	lea	32(A0),A0
	lea	SongData(PC),A1
	cmp.w	#5,InfoBuffer+SubSongs+2
	bne.b	NoAngel
	lea	SongData5(PC),A1
NoAngel
	cmp.w	#3,InfoBuffer+SubSongs+2
	bne.b	NoKramer
	lea	SongData3(PC),A1
NoKramer
	asl.w	#2,D0
	lea	EndPos(PC),A2
	lea	(A1,D0.W),A1
	move.b	(A1)+,(A0)+			; loop pos
	move.b	(A1),D0
	move.b	(A1),(A2)+
	move.b	(A1)+,(A0)+			; end pos
	move.b	(A1),(A2)
	move.b	(A1)+,(A0)+			; first pos
	addq.l	#7,A0
	move.w	(A0)+,dtg_Timer(A5)		; timer speed
	move.b	(A1),(A0)			; song speed
	lea	lbB00C7CD(PC),A0
	move.b	(A1),(A0)			; song speed
	lea	InfoBuffer(PC),A0
	move.b	D0,Length+3(A0)

	lea	$BFD000,A0
	move.b	Timer(PC),$600(A0)
	move.b	Timer+1(PC),$700(A0)
	move.b	#$11,$F00(A0)			; start timer
	bra.w	SetAudioVector

***************************************************************************
***************************** DTP_EndSound ********************************
***************************************************************************

EndSound
	bclr	#0,$BFDF00			; stop timer
	bsr.w	ClearAudioVector
	lea	$DFF000,A0
	move.w	#15,$96(A0)
	moveq	#0,D0
	move.w	D0,$A8(A0)
	move.w	D0,$B8(A0)
	move.w	D0,$C8(A0)
	move.w	D0,$D8(A0)
	rts

***************************************************************************
*************************** Thomas Hermann player *************************
***************************************************************************

; Player from game Beam (c) Magic Bytes

;	BSR.L	lbC00C44C
;	BSR.L	lbC00C47A
;	BSR.L	lbC00C46A
;	BSR.L	lbC00C56A
;	RTS

;lbC00C44C	MOVEA.L	lbL00C7D0,A6
;	MOVE.L	lbL00C7E0,D1
;	MOVE.L	#$3ED,D2
;	JSR	-$1E(A6)
;	MOVE.L	D0,lbL00C7E4
;lbC00C468	RTS

;lbC00C46A	MOVEA.L	lbL00C7D0,A6
;	MOVE.L	lbL00C7E4,D1
;	JMP	-$24(A6)

;lbC00C47A	MOVE.L	lbL00C7E4,D1
;	MOVE.L	lbL00C7D8,D2
;	MOVE.L	lbL00C7DC,D3
;	MOVEA.L	lbL00C7D0,A6
;	JSR	-$2A(A6)
;	MOVEA.L	lbL00C7D8,A1
;	MOVE.L	$2E(A1),lbL00C858
;	MOVE.L	#7,D3
;lbC00C4AA	MOVE.L	(A1),D1
;	SUB.L	lbL00C858,D1
;	ADD.L	lbL00C7D8,D1
;	MOVE.L	D1,(A1)+
;	DBRA	D3,lbC00C4AA
;	CLR.L	D0
;	MOVEA.L	lbL00C7D8,A1
;	MOVE.L	$24(A1),D1
;	SUB.L	lbL00C858,D1
;	ADD.L	lbL00C7D8,D1
;	MOVE.L	D1,$24(A1)
;	MOVEA.L	(A1),A2
;	MOVEA.L	4(A1),A3
;	MOVEA.L	8(A1),A4
;	MOVEA.L	12(A1),A5
;	MOVE.L	#$FF,D0
;lbC00C4EE	MOVE.L	(A2),D1
;	BEQ.L	lbC00C500
;	SUB.L	lbL00C858,D1
;	ADD.L	lbL00C7D8,D1
;lbC00C500	MOVE.L	D1,(A2)+
;	MOVE.L	(A3),D1
;	BEQ.L	lbC00C514
;	SUB.L	lbL00C858,D1
;	ADD.L	lbL00C7D8,D1
;lbC00C514	MOVE.L	D1,(A3)+
;	MOVE.L	(A4),D1
;	BEQ.L	lbC00C528
;	SUB.L	lbL00C858,D1
;	ADD.L	lbL00C7D8,D1
;lbC00C528	MOVE.L	D1,(A4)+
;	MOVE.L	(A5),D1
;	BEQ.L	lbC00C53C
;	SUB.L	lbL00C858,D1
;	ADD.L	lbL00C7D8,D1
;lbC00C53C	MOVE.L	D1,(A5)+
;	DBRA	D0,lbC00C4EE
;	CLR.W	D0
;	MOVE.B	#$1F,D0
;	MOVEA.L	$24(A1),A2
;lbC00C54C	MOVE.L	(A2),D1
;	SUB.L	lbL00C858,D1
;	ADD.L	lbL00C7D8,D1
;	MOVE.L	D1,(A2)+
;	DBRA	D0,lbC00C54C
;	RTS

;	MOVE.L	#0,D0
;	RTS

;lbC00C56A	MOVEA.L	lbL00C7D8,A1
;	CLR.L	D2
;	MOVE.B	$23(A1),D2
;	MOVEA.L	$24(A1),A2
;lbC00C57A	MOVEA.L	(A2)+,A3
;	MOVE.L	D2,lbL00C7F8
;	MOVE.L	A2,lbL00C7FC
;	MOVE.L	A3,lbL00C800
;	MOVE.B	#0,lbW00C80C
;	BSR.L	lbC00C5D8
;	BEQ.L	lbC00C5D4
;	TST.B	lbW00C80C
;	BMI.L	lbC00C5BC
;	MOVE.B	#$FF,lbW00C80C
;	BSR.L	lbC00C61A
;	BSR.L	lbC00C60A
;	BEQ.L	lbC00C5D4
;lbC00C5BC	MOVE.L	lbL00C7F8,D2
;	MOVEA.L	lbL00C7FC,A2
;	DBRA	D2,lbC00C57A
;	MOVE.L	#$FF,D0
;	RTS

;lbC00C5D4	CLR.L	D0
;	RTS

;lbC00C5D8	MOVE.L	A3,D1
;	ADDI.L	#14,D1
;	MOVEA.L	D1,A6
;	TST.B	(A6)
;	BEQ.L	lbC00C600
;	MOVE.L	#$3ED,D2
;	MOVEA.L	lbL00C7D0,A6
;	JSR	-$1E(A6)
;	MOVE.L	D0,lbL00C7EC
;	RTS

;lbC00C600	MOVE.B	#$FF,lbW00C80C
;	RTS

;lbC00C60A	MOVE.L	lbL00C7EC,D1
;	MOVEA.L	lbL00C7D0,A6
;	JMP	-$24(A6)

;lbC00C61A	MOVE.L	#4,D3
;	BSR.L	lbC00C71E
;	MOVE.L	lbL00C838,D0
;	CMPI.L	#$464F524D,D0
;	BNE.L	lbC00C5D4
;	MOVE.L	#$20,D3
;	BSR.L	lbC00C71E
;	MOVEA.L	lbL00C800,A3
;	TST.B	lbW00C80C
;	BNE.L	lbC00C6B4
;	LEA	lbL00C838,A4
;	MOVE.W	$12(A4),D3
;	MOVE.W	D3,8(A3)
;	ADD.W	$16(A4),D3
;	MOVE.W	D3,(A3)
;	MOVE.B	#0,$23(A3)
;	MOVE.W	$16(A4),10(A3)
;	BEQ.L	lbC00C686
;	MOVE.B	#1,$23(A3)
;	TST.W	8(A3)
;	BNE.L	lbC00C686
;	MOVE.B	#$FF,$23(A3)
;lbC00C686	MOVE.L	#$608080A,$24(A3)
;	MOVE.L	#$40302800,$28(A3)
;	MOVE.B	#$40,2(A3)
;	CLR.L	D0
;	MOVE.L	#$369E9A,D3
;	MOVE.W	$1C(A4),D0
;	DIVU.W	D0,D3
;	MOVE.W	D3,12(A3)
;	MOVE.B	$1E(A4),3(A3)
;lbC00C6B4	MOVE.L	#4,D3
;	BSR.L	lbC00C71E
;	MOVE.L	lbL00C838,D0
;	CMPI.L	#$424F4459,D0
;	BNE.L	lbC00C6B4
;	MOVE.L	#4,D3
;	BSR.L	lbC00C71E
;	MOVE.L	lbL00C838,D0
;	MOVE.L	D0,lbL00C7F0
;	MOVEA.L	4,A6
;	MOVE.L	#2,D1
;	JSR	-$C6(A6)
;	MOVEA.L	lbL00C800,A3
;	MOVE.L	D0,4(A3)
;	BEQ.L	lbC00C5D4
;	MOVE.L	lbL00C7EC,D1
;	MOVE.L	4(A3),D2
;	MOVE.L	lbL00C7F0,D3
;	MOVEA.L	lbL00C7D0,A6
;	JSR	-$2A(A6)
;	RTS

;lbC00C71E	MOVEA.L	lbL00C7D0,A6
;	MOVE.L	lbL00C7EC,D1
;	MOVE.L	#lbL00C838,D2
;	JSR	-$2A(A6)
;	RTS

;	dc.b	'dos.library',0
;ciaaresource.MSG	dc.b	'ciaa.resource',0
;HUSTEN.MSG	dc.b	'HUSTEN',0
;	dc.b	'SNG/NEWSTUFF',0
lbW00C764	dc.w	1
	dc.w	2
	dc.w	4
	dc.w	8
lbW00C76C	dc.w	$A0
	dc.w	$B0
	dc.w	$C0
	dc.w	$D0
lbW00C774	dc.w	$A4
	dc.w	$B4
	dc.w	$C4
	dc.w	$D4
lbW00C77C	dc.w	$A6
	dc.w	$B6
	dc.w	$C6
	dc.w	$D6
lbW00C784	dc.w	$A8
	dc.w	$B8
	dc.w	$C8
	dc.w	$D8
lbW00C78C	dc.w	0
	dc.w	$202
	dc.w	$404
	dc.w	$404
	dc.w	$606
	dc.w	$606
	dc.w	$606
	dc.w	$606
lbW00C79C	dc.w	$80
	dc.w	$100
	dc.w	$200
	dc.w	$400
lbW00C7A4	dc.w	$1AC
	dc.w	$194
	dc.w	$17C
	dc.w	$168
	dc.w	$154
	dc.w	$140
	dc.w	$12E
	dc.w	$11E
	dc.w	$10E
	dc.w	$FE
	dc.w	$F0
	dc.w	$E2
lbB00C7BC	dc.b	0
lbB00C7BD	dc.b	0
lbB00C7BE	dc.b	0
	dc.b	0
lbB00C7C0	dc.b	0
lbB00C7C1	dc.b	0
lbB00C7C2	dc.b	0
	dc.b	0
lbB00C7C4	dc.b	0
lbB00C7C5	dc.b	0
lbB00C7C6	dc.b	0
	dc.b	0
lbB00C7C8	dc.b	0
lbB00C7C9	dc.b	0
lbB00C7CA	dc.b	0
	dc.b	0
lbB00C7CC	dc.b	1
lbB00C7CD	dc.b	4
lbB00C7CE	dc.b	0
lbB00C7CF	dc.b	0
lbL00C7D0	dc.l	0
lbL00C7D4	dc.l	0
lbL00C7D8	dc.l	0
lbL00C7DC	dc.l	0
lbL00C7E0	dc.l	0
lbL00C7E4	dc.l	0
	dc.l	0
lbL00C7EC	dc.l	0
lbL00C7F0	dc.l	0
	dc.l	0
lbL00C7F8	dc.l	0
lbL00C7FC	dc.l	0
lbL00C800	dc.l	0
lbW00C804	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
;lbW00C80C	dc.w	0
;	dc.w	0
;	dc.w	$FFFF
;	dc.w	$FFFF
;	dc.w	$FFFF
;	dc.w	$FFFF
;	dc.w	$FFFF
;	dc.w	$FFFF
;	dc.w	$FFFF
;	dc.w	$FFFF
;	dc.w	$FFFF
;	dc.w	$FFFF
;	dc.w	$FFFF
;	dc.w	$FFFF
;	dc.w	$FFFF
;	dc.w	$FFFF
;	dc.w	$FFFF
;	dc.w	$FFFF
;	dc.w	$FFFF
;	dc.w	$FFFF
;	dc.w	$FFFF
;	dc.w	$FFFF
;lbL00C838	dc.l	$FFFFFFFF
;	dc.l	$FFFFFFFF
;	dc.l	$FFFFFFFF
;	dc.l	$FFFFFFFF
;	dc.l	$FFFFFFFF
;	dc.l	$FFFFFFFF
;	dc.l	$FFFFFFFF
;	dc.l	$FFFFFFFF
;lbL00C858	dc.l	0
lbW00C85C	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF

;	MOVEM.L	D0-D7/A0-A6,-(SP)
;	CLR.L	D0
;	MOVE.B	lbB00C7CC,D0
;	BEQ.L	lbC00C8AE
;	BSR.L	lbC00C8D0
;	MOVE.B	#0,lbB00C7CC
;	MOVEM.L	(SP)+,D0-D7/A0-A6
;	RTS

;lbC00C8AE	MOVE.B	#$FF,lbB00C7CC
;	LEA	$DFF000,A5
;	MOVE.W	#15,$96(A5)
;	BSR.L	lbC00C912
;	BSR.L	lbC00C9AA
;	MOVEM.L	(SP)+,D0-D7/A0-A6
;	RTS

;lbC00C8D0	MOVE.B	#$FF,lbB00C7CC
;	MOVEA.L	4,A6
;	MOVEA.L	$150(A6),A0
;	LEA	ciaaresource.MSG,A1
;	JSR	-$114(A6)
;	TST.L	D0
;	BEQ.L	lbC00C9A8
;	MOVE.L	D0,lbL00C7D4
;	BSR.L	lbC00C912
;	BSR.L	lbC00C91E
;	MOVEA.L	lbL00C7D4,A6
;	LEA	lbL00CE3C,A1
;	CLR.L	D0
;	JMP	-6(A6)

;lbC00C912	MOVEA.L	lbL00C7D4,A6
;	CLR.L	D0
;	JMP	-12(A6)

;lbC00C91E	ANDI.B	#$D6,$BFEE01
;	MOVEA.L	lbL00C7D8,A2
;	MOVE.B	$2B(A2),$BFE401
;	MOVE.B	$2A(A2),$BFE501
;	MOVE.B	$2C(A2),lbB00C7CD
;	ORI.B	#1,$BFEE01
;	LEA	lbL00CCEE,A1
;	MOVE.L	#7,D0
;	MOVEA.L	4,A6
;	JSR	-$A2(A6)
;	LEA	lbL00CCEE,A1
;	MOVE.L	#8,D0
;	JSR	-$A2(A6)
;	LEA	lbL00CCEE,A1
;	MOVE.L	#9,D0
;	JSR	-$A2(A6)
;	LEA	lbL00CCEE,A1
;	MOVE.L	#10,D0
;	JSR	-$A2(A6)
;	MOVEA.L	4,A6
;	MOVE.L	#5,D0
;	LEA	lbL00C9C2,A1
;	JSR	-$A8(A6)
;lbC00C9A8	RTS

;lbC00C9AA	MOVEA.L	4,A6
;	MOVE.L	#5,D0
;	LEA	lbL00C9C2,A1
;	JSR	-$AE(A6)
;	RTS

InterruptStruct
lbL00C9C2	dc.l	0
	dc.l	0
	dc.w	$200
;	dc.l	HUSTEN.MSG

	dc.l	TimName

	dc.l	lbL00C9D8
	dc.l	lbC00C9DC
lbL00C9D8	dc.l	$3000000

lbC00C9DC	MOVEM.L	D2-D5/A0/A2/A3,-(SP)
	LEA	$DFF000,A1
	MOVE.L	#0,D0
	BSR.L	lbC00CC56
	MOVE.B	#2,D0
	BSR.L	lbC00CC56
	MOVE.B	#4,D0
	BSR.L	lbC00CC56
	MOVE.B	#6,D0
	BSR.L	lbC00CC56
	SUBI.B	#1,lbL00C9D8
	BMI.L	lbC00CA18
	BRA.L	lbC00CA42

lbC00CA18	MOVE.B	#3,lbL00C9D8
	MOVE.L	#0,D0
	BSR.L	lbC00CA4A
	MOVE.B	#2,D0
	BSR.L	lbC00CA4A
	MOVE.B	#4,D0
	BSR.L	lbC00CA4A
	MOVE.B	#6,D0
	BSR.L	lbC00CA4A
lbC00CA42	MOVEM.L	(SP)+,D2-D5/A0/A2/A3
	CLR.L	D0
lbC00CA48	RTS

lbC00CA4A	LEA	lbL00CD14(pc),A3
	TST.B	0(A3,D0.L)
	BEQ.L	lbC00CA48
	CLR.L	D1
	CLR.L	D2
	CLR.L	D3
	CLR.L	D4
	LEA	lbL00CD34(pc),A2
	TST.B	0(A2,D0.L)
	BMI.L	lbC00CB6E
	TST.B	0(A3,D0.L)
	BPL.L	lbC00CA48
	LEA	lbL00CD5C(pc),A3
	MOVE.B	0(A3,D0.L),D1
	CMPI.B	#3,D1
	BHI.L	lbC00CA48
	BEQ.L	lbC00CB4C
	CMPI.B	#2,D1
	BEQ.L	lbC00CB26
	CMPI.B	#1,D1
	BEQ.L	lbC00CB00
	ASL.B	#1,D0
	LEA	lbL00CD44(pc),A3
	MOVEA.L	0(A3,D0.L),A2
	LSR.B	#1,D0
	MOVE.B	$28(A2),D2
	ASL.W	#8,D2
	MOVE.B	$24(A2),D4
	DIVU.W	D4,D2
	LEA	lbL00CD54(pc),A3
	MOVE.W	D2,0(A3,D0.L)
	LEA	lbL00CD3C(pc),A3
	MOVE.W	D2,0(A3,D0.L)
	LEA	lbL00CD5C(pc),A0
	MOVE.B	#1,0(A0,D0.L)
	MOVE.B	0(A3,D0.L),D5
lbC00CADA	LEA	lbL00CD64(pc),A3
	MOVE.B	0(A3,D0.L),D1
	ANDI.W	#$FF,D1
	ANDI.W	#$FF,D5
	MULU.W	D5,D1
	LSR.W	#6,D1
	LEA	lbW00C784(pc),A3
	MOVE.W	0(A3,D0.L),D5
;	MOVE.W	D1,0(A1,D5.L)

	bsr.w	ChangeVolume2
	bsr.w	SetVol2
	move.w	D1,0(A1,D5.W)				; Volume fix

	RTS

lbC00CB00	ASL.B	#1,D0
	LEA	lbL00CD44(pc),A3
	MOVEA.L	0(A3,D0.L),A2
	LSR.B	#1,D0
	MOVE.B	$28(A2),D2
	MOVE.B	$29(A2),D3
	MOVE.B	$25(A2),D4
	BNE.L	lbC00CBF2
	MOVE.B	#1,D4
	BRA.L	lbC00CBF2

lbC00CB26	ASL.B	#1,D0
	LEA	lbL00CD44(pc),A3
	MOVEA.L	0(A3,D0.L),A2
	LSR.B	#1,D0
	MOVE.B	$29(A2),D2
	MOVE.B	$2A(A2),D3
	MOVE.B	$26(A2),D4
	BNE.L	lbC00CBF2
	MOVE.B	#1,D4
	BRA.L	lbC00CBF2

lbC00CB4C	ASL.B	#1,D0
	LEA	lbL00CD44(pc),A3
	MOVEA.L	0(A3,D0.L),A2
	LSR.B	#1,D0
	MOVE.B	$2A(A2),D2
	MOVE.B	$27(A2),D4
	BNE.L	lbC00CBF2
	MOVE.B	#1,D4
	BRA.L	lbC00CBF2

lbC00CB6E	ASL.B	#1,D0
	LEA	lbL00CD44(pc),A3
	MOVEA.L	0(A3,D0.L),A2
	LSR.B	#1,D0
	LEA	lbL00CD5C(pc),A3
	MOVE.B	0(A3,D0.L),D1
	MOVE.B	#1,D4
	CMPI.B	#4,D1
	BNE.L	lbC00CB9A
	BSR.L	lbC00CBF2
	BRA.L	lbC00CBD0

lbC00CB9A	MOVE.B	#4,0(A3,D0.L)
	LEA	lbL00CD3C(pc),A3
	MOVE.W	0(A3,D0.L),D2
	MOVE.B	$27(A2),D4
	BNE.L	lbC00CBB6
	MOVE.B	#1,D4
lbC00CBB6	SUB.L	D2,D3
	DIVS.W	D4,D3
	LEA	lbL00CD54(pc),A3
	MOVE.W	D3,0(A3,D0.L)
	CLR.W	D2
	CLR.W	D3
	MOVE.W	#1,D4
	BSR.L	lbC00CBF2
lbC00CBD0	LEA	lbL00CD5C(pc),A3
	MOVE.B	0(A3,D0.L),D1
	CMPI.B	#5,D1
	BEQ.L	lbC00CBE4
	RTS

lbC00CBE4	LEA	lbL00CD14(pc),A3
	MOVE.B	#0,0(A3,D0.L)
	RTS

lbC00CBF2	LEA	lbL00CD54(pc),A3
	MOVE.W	0(A3,D0.L),D1
	LEA	lbL00CD3C(pc),A0
	ADD.W	D1,0(A0,D0.L)
	MOVE.B	0(A0,D0.L),D5
	TST.W	D1
	BMI.L	lbC00CC1A
	CMP.B	D2,D5
	BGE.L	lbC00CC24
	BRA.L	lbC00CADA

lbC00CC1A	CMP.B	D2,D5
	BLE.L	lbC00CC24
	BRA.L	lbC00CADA

lbC00CC24	LEA	lbL00CD3C(pc),A3
	MOVE.B	D2,0(A3,D0.L)
	MOVE.B	#0,1(A3,D0.L)
	MOVE.B	D2,D5
	BSR.L	lbC00CADA
	SUB.L	D2,D3
	ASL.L	#8,D3
	DIVS.W	D4,D3
	LEA	lbL00CD54(pc),A3
	MOVE.W	D3,0(A3,D0.L)
	LEA	lbL00CD5C(pc),A3
	ADDQ.B	#1,0(A3,D0.L)
	RTS

lbC00CC56	LEA	lbL00CD6C(pc),A3
	TST.B	0(A3,D0.L)
	BEQ.L	lbC00CA48
	ASL.B	#1,D0
	LEA	lbL00CD44(pc),A3
	MOVEA.L	0(A3,D0.L),A2
	LSR.B	#1,D0
	CLR.L	D1
	MOVE.B	$2D(A2),D1
	LEA	lbL00CD74(pc),A3
	MOVE.W	0(A3,D0.L),D2
	LEA	lbL00CD7C(pc),A3
	CMP.W	0(A3,D0.L),D2
	BCS.L	lbC00CCAC
	BEQ.L	lbC00CCD0
	SUB.W	D1,D2
	CMP.W	0(A3,D0.L),D2
	BLS.L	lbC00CCD0
	LEA	lbL00CD74(pc),A3
	MOVE.W	D2,0(A3,D0.L)
	BRA.L	lbC00CCC0

lbC00CCAC	ADD.W	D1,D2
	CMP.W	0(A3,D0.L),D2
	BCC.L	lbC00CCD0
	LEA	lbL00CD74(pc),A3
	MOVE.W	D2,0(A3,D0.L)
lbC00CCC0	LEA	lbW00C77C(pc),A3
	MOVE.W	0(A3,D0.L),D1
	MOVE.W	D2,0(A1,D1.W)
	RTS

lbC00CCD0	MOVE.W	0(A3,D0.L),D2
	LEA	lbL00CD74(pc),A3
	MOVE.W	D2,0(A3,D0.L)
	LEA	lbL00CD6C(pc),A3
	MOVE.B	#0,0(A3,D0.L)
	BRA.L	lbC00CCC0

StructInt
lbL00CCEE	dc.l	0
	dc.l	0
	dc.w	$200
;	dc.l	0

	dc.l	IntName

	dc.l	lbL00CD04
	dc.l	lbC00CD86
lbL00CD04	dc.l	0
	dc.l	0
lbL00CD0C	dc.l	0
	dc.l	0
lbL00CD14	dc.l	0
	dc.l	0
lbL00CD1C	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbL00CD2C	dc.l	0
	dc.l	0
lbL00CD34	dc.l	0
	dc.l	0
lbL00CD3C	dc.l	0
	dc.l	0
lbL00CD44	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbL00CD54	dc.l	0
	dc.l	0
lbL00CD5C	dc.l	0
	dc.l	0
lbL00CD64	dc.l	0
	dc.l	0
lbL00CD6C	dc.l	0
	dc.l	0
lbL00CD74	dc.l	0
	dc.l	0
lbL00CD7C	dc.l	0
	dc.l	0
lbW00CD84	dc.w	0

lbC00CD86	CLR.L	D0
	LSR.W	#7,D1
	ANDI.L	#15,D1
	LEA	lbW00C78C(pc),A5
	MOVE.B	0(A5,D1.L),D0
	LEA	lbW00C79C(pc),A5
	MOVE.W	0(A5,D0.L),lbW00CD84
	MOVE.W	lbW00CD84(pc),$9C(A0)
	LEA	lbL00CD0C(pc),A5
	MOVE.B	0(A5,D0.L),D1
	BEQ.L	lbC00CE08
	LEA	lbL00CD04(pc),A5
	CMPI.B	#1,0(A5,D0.L)
	BNE.L	lbC00CE34
	LEA	lbL00CD1C(pc),A5
	LEA	lbW00C76C(pc),A1
	MOVE.W	0(A1,D0.L),D1
	ASL.B	#1,D0
	MOVE.L	0(A5,D0.L),0(A0,D1.L)
	LSR.B	#1,D0
	LEA	lbL00CD2C(pc),A5
	LEA	lbW00C774(pc),A1
	MOVE.W	0(A1,D0.L),D1
	MOVE.W	0(A5,D0.L),0(A0,D1.L)
	MOVE.W	lbW00CD84(pc),$9A(A0)
	RTS

lbC00CE08	LEA	lbL00CD04(pc),A5
	CMPI.B	#2,0(A5,D0.L)
	BCS.L	lbC00CE34
	MOVE.W	lbW00CD84(pc),$9A(A0)
	MOVE.B	#0,0(A5,D0.L)
	LEA	lbW00C764(pc),A5
	MOVE.W	0(A5,D0.L),$96(A0)
	RTS

lbC00CE34	ADDI.B	#1,0(A5,D0.L)
	RTS

;lbL00CE3C	dc.l	0
;	dc.l	0
;	dc.w	$200
;	dc.l	0
;	dc.l	lbW00CE52
;	dc.l	lbC00CEA2
;lbW00CE52	dc.w	$FFFF
;	dc.w	$FFFF
;	dc.w	$FFFF
;	dc.w	$FFFF
;	dc.w	$FFFF
;	dc.w	$FFFF
;	dc.w	$FFFF
;	dc.w	$FFFF
;	dc.w	$FFFF
;	dc.w	$FFFF
;	dc.w	$FFFF
;	dc.w	$FFFF
;	dc.w	$FFFF
;	dc.w	$FFFF
;	dc.w	$FFFF
;	dc.w	$FFFF
;	dc.w	$FFFF
;	dc.w	$FFFF
;	dc.w	$FFFF
;	dc.w	$FFFF
;	dc.w	$FFFF
;	dc.w	$FFFF
;	dc.w	$FFFF
;	dc.w	$FFFF
;	dc.w	$FFFF
;	dc.w	$FFFF
;	dc.w	$FFFF
;	dc.w	$FFFF
;	dc.w	$FFFF
;	dc.w	$FFFF
;	dc.w	$FFFF
;	dc.w	$FFFF
;	dc.w	$FFFF
;	dc.w	$FFFF
;	dc.w	$FFFF
;	dc.w	$FFFF
;	dc.w	$FFFF
;	dc.w	$FFFF
;	dc.w	$FFFF
;	dc.w	$FFFF

Play
lbC00CEA2	MOVEM.L	D0-D7/A0-A7,-(SP)
	CLR.L	D0
	MOVE.B	lbB00C7CD(pc),D0
	BEQ.L	lbC00CEC0
	BMI.L	lbC00CF10
lbC00CEB6	SUBQ.B	#1,lbB00C7CD
	BRA.L	lbC00CFF2

lbC00CEC0	MOVEA.L	lbL00C7D8(pc),A0
	LEA	$DFF000,A5
	MOVEA.L	(A0),A1
	MOVEA.L	$10(A0),A2
	MOVE.L	#0,D0
	BSR.L	lbC00CFF8
	MOVEA.L	4(A0),A1
	MOVEA.L	$14(A0),A2
	MOVE.B	#1,D0
	BSR.L	lbC00CFF8
	MOVEA.L	8(A0),A1
	MOVEA.L	$18(A0),A2
	MOVE.B	#2,D0
	BSR.L	lbC00CFF8
	MOVEA.L	12(A0),A1
	MOVEA.L	$1C(A0),A2
	MOVE.B	#3,D0
	BSR.L	lbC00CFF8
	BRA.L	lbC00CEB6

lbC00CF10	CLR.L	D3
	CLR.L	D2
	CLR.L	D1
	MOVEA.L	lbL00C7D8(pc),A0
	LEA	$DFF000,A5
	MOVE.B	$2C(A0),lbB00C7CD
	MOVE.B	$32(A0),D0
	BNE.L	lbC00CF4E
	MOVE.L	#0,D0
	MOVE.B	lbB00C7BE(pc),D4
	MOVE.B	lbB00C7BC(pc),D3
	MOVE.B	lbB00C7BD(pc),D2
	BSR.L	lbC00D05A
lbC00CF4E	MOVE.B	$33(A0),D0
	BNE.L	lbC00CF70
	MOVE.B	#1,D0
	MOVE.B	lbB00C7C2(pc),D4
	MOVE.B	lbB00C7C0(pc),D3
	MOVE.B	lbB00C7C1(pc),D2
	BSR.L	lbC00D05A
lbC00CF70	MOVE.B	$34(A0),D0
	BNE.L	lbC00CF92
	MOVE.B	#2,D0
	MOVE.B	lbB00C7C6(pc),D4
	MOVE.B	lbB00C7C4(pc),D3
	MOVE.B	lbB00C7C5(pc),D2
	BSR.L	lbC00D05A
lbC00CF92	MOVE.B	$35(A0),D0
	BNE.L	lbC00CFB4
	MOVE.B	#3,D0
	MOVE.B	lbB00C7CA(pc),D4
	MOVE.B	lbB00C7C8(pc),D3
	MOVE.B	lbB00C7C9(pc),D2
	BSR.L	lbC00D05A
lbC00CFB4	MOVE.B	lbB00C7CE(pc),D0
	ADDI.B	#1,lbB00C7CE
	MOVE.B	$29(A0),D1
	CMP.B	D1,D0
	BEQ.L	lbC00CFD0
	BRA.L	lbC00CFF2

lbC00CFD0	MOVE.B	#0,lbB00C7CE
	MOVE.B	$22(A0),D0
	CMP.B	$21(A0),D0
	BEQ.L	lbC00CFEC
	ADDQ.B	#1,$22(A0)
	BRA.L	lbC00CFF2

lbC00CFEC	MOVE.B	$20(A0),$22(A0)

	bsr.w	SongEnd

lbC00CFF2	MOVEM.L	(SP)+,D0-D7/A0-A7
	RTS

lbC00CFF8	CLR.L	D1
	MOVE.B	$22(A0),D1
	MOVE.B	0(A2,D1.L),lbW00C804
	ASL.W	#2,D1
	MOVEA.L	0(A1,D1.L),A3
	LEA	lbB00C7BC(pc),A2
	ASL.W	#2,D0
	CLR.L	D1
	MOVE.B	lbB00C7CE(pc),D1
	MULU.W	#3,D1
	MOVE.B	0(A3,D1.L),0(A2,D0.L)
	MOVE.B	1(A3,D1.L),1(A2,D0.L)
	MOVE.B	2(A3,D1.L),2(A2,D0.L)
	MOVE.B	0(A2,D0.L),D1
	MOVE.B	2(A2,D0.L),D4
	BSR.L	lbC00D236
	BTST	#1,D4
	BNE.L	lbC00D058
	LSR.B	#2,D0
	CMPI.B	#$C0,D1
	BCS.L	lbC00D092
	CMPI.B	#$CF,D1
	BEQ.L	lbC00D092
lbC00D058	RTS

lbC00D05A	CMPI.B	#$FF,D3
	BNE.L	lbC00D064
	RTS

lbC00D064	MOVE.B	D3,lbB00C7CF
	CMPI.B	#$CF,D3
	BEQ.L	lbC00D0BA
	CMPI.B	#$DF,D3
	BNE.L	lbC00D08A
	ASL.W	#1,D0
	LEA	lbL00CD34(pc),A2
	MOVE.B	#$FF,0(A2,D0.L)
	RTS

lbC00D08A	CMPI.B	#$EF,D3
	BNE.L	lbC00D0BA
lbC00D092	ASL.B	#1,D0
	LEA	lbW00C764(pc),A3
	MOVE.W	0(A3,D0.L),$96(A5)
	LEA	lbW00C79C(pc),A3
	MOVE.W	0(A3,D0.L),$9A(A5)
	LEA	lbL00CD14(pc),A3
	MOVE.B	#0,0(A3,D0.L)
	RTS

lbC00D0BA	MOVEA.L	$24(A0),A1
	LEA	lbW00C85C(pc),A2
	ASL.W	#2,D2
	MOVEA.L	0(A1,D2.L),A1
	MOVE.W	12(A1),$12(A2)
	MOVE.W	(A1),(A2)
	MOVE.B	2(A1),2(A2)
	MOVE.L	4(A1),4(A2)
	MOVE.B	$23(A1),8(A2)
	CLR.W	10(A2)
	MOVE.W	8(A1),12(A2)
	MOVE.W	10(A1),14(A2)
	MOVE.B	3(A1),D1
	CMPI.B	#1,D1
	BNE.L	lbC00D17E
	CLR.L	D1
	MOVE.B	D3,D1
	CMPI.B	#$CF,D1
	BEQ.L	lbC00D27E
	CMPI.B	#$C0,D1
	BCS.L	lbC00D116
	RTS

lbC00D116	ANDI.B	#$F0,D1
	LSR.B	#3,D1
	LEA	lbW00C7A4(pc),A3
	MOVE.W	0(A3,D1.L),D2
	MOVE.B	D3,D1
	ANDI.B	#15,D1
	CMPI.B	#1,D1
	BNE.L	lbC00D13C
	MOVE.W	D2,$10(A2)
	BRA.L	lbC00D27E

lbC00D13C	CMPI.B	#2,D1
	BNE.L	lbC00D158
	LSR.W	#1,D2
	CMPI.W	#$82,D2
	BHI.L	lbC00D150
	RTS

lbC00D150	MOVE.W	D2,$10(A2)
	BRA.L	lbC00D27E

lbC00D158	CMPI.B	#0,D1
	BNE.L	lbC00D16A
	ASL.W	#1,D2
	MOVE.W	D2,$10(A2)
	BRA.L	lbC00D27E

lbC00D16A	CMPI.B	#15,D1
	BEQ.L	lbC00D174
	RTS

lbC00D174	ASL.W	#2,D2
	MOVE.W	D2,$10(A2)
	BRA.L	lbC00D27E

lbC00D17E	CLR.L	D1
	MOVE.B	D3,D1
	CMPI.B	#$CF,D1
	BEQ.L	lbC00D1D6
	CMPI.B	#$C0,D1
	BCS.L	lbC00D194
	RTS

lbC00D194	ANDI.B	#$F0,D1
	LSR.B	#3,D1
	LEA	lbW00C7A4(pc),A3
	MOVE.W	0(A3,D1.L),D2
	MOVE.B	D3,D1
	ANDI.B	#15,D1
	CMPI.B	#3,D1
	BNE.L	lbC00D1BE
	LSR.W	#1,D2
	CMPI.W	#$82,D2
	BHI.L	lbC00D150
	RTS

lbC00D1BE	CMPI.B	#2,D1
	BNE.L	lbC00D1CE
	MOVE.W	D2,$10(A2)
	BRA.L	lbC00D27E

lbC00D1CE	CMPI.B	#1,D1
	BNE.L	lbC00D1F6
lbC00D1D6	MOVE.W	(A2),D1
	ADD.L	D1,4(A2)
	ASL.W	#1,D1
	MOVE.W	D1,(A2)
	MOVE.W	D2,$10(A2)
	MOVE.L	10(A2),D2
	ASL.L	#1,D2
	MOVE.L	D2,10(A2)
	ASL.W	14(A2)
	BRA.L	lbC00D27E

lbC00D1F6	CMPI.B	#0,D1
	BNE.L	lbC00D226
lbC00D1FE	MOVE.W	D2,$10(A2)
	MOVE.W	(A2),D1
	MULU.W	#3,D1
	ADD.L	D1,4(A2)
	ASL.W	(A2)
	ASL.W	(A2)
	MOVE.L	10(A2),D2
	ASL.L	#2,D2
	MOVE.L	D2,10(A2)
	ASL.W	14(A2)
	ASL.W	14(A2)
	BRA.L	lbC00D27E

lbC00D226	CMPI.B	#15,D1
	BNE.L	lbC00D234
	ASL.W	#1,D2
	BRA.L	lbC00D1FE

lbC00D234	RTS

lbC00D236	MOVE.B	lbW00C804(pc),D3
	MOVE.B	D1,D5
	CMPI.B	#$C0,D1
	BCS.L	lbC00D248
	RTS

lbC00D248	LSR.B	#4,D5
	ADD.B	D3,D5
	BMI.L	lbC00D266
	CMPI.B	#12,D5
	BGE.L	lbC00D272
lbC00D258	ASL.B	#4,D5
	ANDI.B	#15,D1
	OR.B	D5,D1
	MOVE.B	D1,0(A2,D0.L)
	RTS

lbC00D266	SUBI.B	#4,D5
	SUBI.B	#1,D1
	BRA.L	lbC00D258

lbC00D272	ADDI.B	#4,D5
	ADDI.B	#1,D1
	BRA.L	lbC00D258

lbC00D27E	CLR.L	D1
	MOVE.W	#$FF,$9E(A5)
	LEA	lbL00CD44(pc),A3
	ASL.B	#2,D0
	MOVE.L	A1,0(A3,D0.L)
	LSR.B	#1,D0
	LEA	lbW00C76C(pc),A3
	MOVE.W	0(A3,D0.L),D1
	MOVE.L	4(A2),0(A5,D1.L)			; address

	bsr.w	SetAdr

	LEA	lbW00C774(pc),A3
	MOVE.W	0(A3,D0.L),D1
	MOVE.W	(A2),D2
	LSR.W	#1,D2
	MOVE.W	D2,0(A5,D1.L)				; length

	bsr.w	SetLen

	LEA	lbW00C77C(pc),A3
	MOVE.W	0(A3,D0.L),D1
	MOVE.W	$10(A2),D2
	CMPI.B	#$CF,lbB00C7CF
	BNE.L	lbC00D2D4
	MOVE.W	$12(A2),D2
lbC00D2D4	LEA	lbL00CD7C(pc),A3
	MOVE.W	D2,0(A3,D0.L)
	LEA	lbL00CD6C(pc),A3
	MOVE.B	#$FF,0(A3,D0.L)
	BTST	#0,D4
	BNE.L	lbC00D306
	MOVE.B	#0,0(A3,D0.L)
	MOVE.W	D2,0(A5,D1.W)				; period

	bsr.w	SetPer

	LEA	lbL00CD74(pc),A3
	MOVE.W	D2,0(A3,D0.L)
lbC00D306	CLR.W	D2
	LEA	lbL00CD34(pc),A3
	MOVE.B	#0,0(A3,D0.L)
	MOVE.B	8(A2),D1
	LEA	lbL00CD0C(pc),A3
	MOVE.B	D1,0(A3,D0.L)
	MOVE.B	D1,8(A3,D0.L)
	BEQ.L	lbC00D3CC
	LEA	lbL00CD1C(pc),A3
	MOVE.L	10(A2),D1
	ADD.L	4(A2),D1
	ASL.B	#1,D0
	MOVE.L	D1,0(A3,D0.L)
	LSR.B	#1,D0
	LEA	lbL00CD2C(pc),A3
	MOVE.W	14(A2),D1
	LSR.W	#1,D1
	MOVE.W	D1,0(A3,D0.L)
	LEA	lbL00CD5C(pc),A3
	MOVE.B	#0,0(A3,D0.L)
	LEA	lbL00CD64(pc),A3
	MOVE.B	2(A2),0(A3,D0.L)
	TST.B	8(A2)
	BMI.L	lbC00D386
	LEA	lbL00CD3C(pc),A3
	MOVE.B	#$40,0(A3,D0.L)
	MOVE.B	#0,1(A3,D0.L)
	BRA.L	lbC00D3CC

lbC00D386	MOVE.B	#0,D2
	TST.B	$24(A1)
	BNE.L	lbC00D3D0
	LEA	lbL00CD54(pc),A3
	MOVE.W	#0,0(A3,D0.L)
	LEA	lbL00CD5C(pc),A3
	MOVE.B	#1,0(A3,D0.L)
	MOVE.B	$28(A1),D5
	LEA	lbL00CD3C(pc),A3
	MOVE.B	D5,0(A3,D0.L)
	MOVE.B	#0,1(A3,D0.L)
	LEA	$DFF000,A1
	BSR.L	lbC00CADA
	BRA.L	lbC00D3DE

lbC00D3CC	MOVE.B	2(A2),D2
lbC00D3D0	LEA	lbW00C784(pc),A3
	MOVE.W	0(A3,D0.L),D1

	bsr.w	ChangeVolume
	bsr.w	SetVol

	MOVE.W	D2,0(A5,D1.W)				; volume

lbC00D3DE	LEA	lbL00CD04(pc),A3
	MOVE.B	#0,0(A3,D0.L)
	LEA	lbW00C79C(pc),A3
	MOVE.W	0(A3,D0.L),D1

	bsr.w	DMAWait

	ADDI.W	#$8000,D1
	MOVE.W	D1,$9A(A5)
	LEA	lbW00C764(pc),A3
	MOVE.W	0(A3,D0.L),D1
	ADDI.W	#$8200,D1
	MOVE.W	D1,$96(A5)
	RTS

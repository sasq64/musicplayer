	*****************************************************
	****    Jochen Hippel replayer for EaglePlayer	 ****
	****         all adaptions by Wanted Team,	 ****
	****      DeliTracker 2.32 compatible version	 ****
	*****************************************************

	incdir	"dh2:include/"
	include "misc/eagleplayer2.01.i"

	SECTION	Player,CODE

	PLAYERHEADER Tags

	dc.b	'$VER: Jochen Hippel player module V1.0 (17 Jan 2003)',0
	even
Tags
	dc.l	DTP_PlayerVersion,1
	dc.l	EP_PlayerVersion,9
	dc.l	DTP_PlayerName,PlayerName
	dc.l	DTP_RequestDTVersion,'WT'
	dc.l	DTP_Creator,Creator
	dc.l	DTP_Check2,Check2
	dc.l	DTP_Interrupt,Interrupt
	dc.l	DTP_SubSongRange,SubSongRange
	dc.l	DTP_InitPlayer,InitPlayer
	dc.l	DTP_EndPlayer,EndPlayer
	dc.l	DTP_InitSound,InitSound
	dc.l	DTP_EndSound,EndSound
	dc.l	EP_Get_ModuleInfo,GetInfos
	dc.l	EP_ModuleChange,ModuleChange
	dc.l	DTP_Volume,SetVolume
	dc.l	DTP_Balance,SetBalance
	dc.l	EP_Voices,SetVoices
	dc.l	EP_StructInit,StructInit
	dc.l	EP_GetPositionNr,GetPosition
	dc.l	EP_SampleInit,SampleInit
	dc.l	EP_Flags,EPB_Volume!EPB_Balance!EPB_ModuleInfo!EPB_Voices!EPB_SampleInfo!EPB_Songend!EPB_Analyzer!EPB_NextSong!EPB_PrevSong!EPB_Packable!EPB_Restart
	dc.l	TAG_DONE

PlayerName
	dc.b	'Jochen Hippel',0
Creator
	dc.b	'(c) 1988-91 Jochen ''Mad Max'' Hippel,',10
	dc.b	'adapted by Wanted Team',0
Prefix1
	dc.b	'SOG.',0
Prefix2
	dc.b	'MCMD.',0
Text1
	dc.b	"Initialized module loaded !!!",0
Text2
	dc.b	"MCMD module loaded !!!",0
	even
ModulePtr
	dc.l	0
PlayPtr
	dc.l	0
SubSongsPtr
	dc.l	0
SampleInfoPtr
	dc.l	0
SamplesPtr
	dc.l	0
EagleBase
	dc.l	0
Voice1Data
	dc.l	0
Change
	dc.w	0
InitFlag
	dc.w	0
DataTemp
	dc.l	0
Format
	dc.b	0
CurrentFormat
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
Periods
	ds.b	8

***************************************************************************
******************************* EP_SampleInit *****************************
***************************************************************************

SampleInit
	moveq	#EPR_NotEnoughMem,D7
	lea	EPG_SampleInfoStructure(A5),A3
	move.l	SampleInfoPtr(PC),D0
	beq.b	return
	move.l	D0,A2

	move.l	InfoBuffer+Samples(PC),D5
	beq.b	return
	subq.l	#1,D5
	move.l	SamplesPtr(PC),A1
	moveq	#30,D2
	lea	CurrentFormat(PC),A4
	tst.b	(A4)
	bpl.b	Normal
	moveq	#28,D2
Normal
	jsr	ENPP_AllocSampleStruct(A5)
	move.l	D0,(A3)
	beq.b	return
	move.l	D0,A3

	move.l	18(A2),D0
	lea	(A1,D0.L),A0
	moveq	#0,D1
	move.w	22(A2),D1
	add.l	D1,D1
	move.l	A2,EPS_SampleName(A3)		; sample name
	move.l	A0,EPS_Adr(A3)			; sample address
	move.l	D1,EPS_Length(A3)		; sample length
	move.l	#64,EPS_Volume(A3)
	move.w	#USITY_RAW,EPS_Type(A3)
	move.w	#18,EPS_MaxNameLen(A3)
	move.w	#USIB_Playable!USIB_Saveable!USIB_8BIT,EPS_Flags(A3)

	add.w	D2,A2
	dbf	D5,Normal

	moveq	#0,D7
return
	move.l	D7,D0
	rts

***************************************************************************
********************************* EP_GetPosNr *****************************
***************************************************************************

GetPosition
	move.l	Voice1Data(PC),A0
	move.b	CurrentFormat(PC),D0
	beq.b	OldPos
	bpl.b	NewPos
	moveq	#0,D0
	move.w	$24(A0),D0
	bra.b	Podziel
NewPos
	moveq	#0,D0
	move.w	$3A(A0),D0
	bra.b	Podziel
OldPos
	move.l	4(A0),D0
Podziel
	divu.w	#12,D0
	rts

***************************************************************************
**************************** EP_ModuleChange ******************************
***************************************************************************

ModuleChange
	move.w	Change(PC),D0
	bne.s	NoChange
	move.l	PlayPtr(PC),EPG_ARG1(A5)
	lea	PatchTable(PC),A1
	move.b	CurrentFormat(PC),D1
	beq.b	TableOK
	lea	PatchTable2(PC),A1
TableOK
	move.l	DataTemp(PC),D1
	sub.w	#500,D1
	move.l	A1,EPG_ARG3(A5)
	move.l	D1,EPG_ARG2(A5)
	moveq	#-2,D0
	move.l	D0,EPG_ARG5(A5)
	moveq	#1,D0
	move.l	D0,EPG_ARG4(A5)			;Search-Modus
	moveq	#5,D0
	move.l	D0,EPG_ARGN(A5)
	move.l	EPG_ModuleChange(A5),A0
	jsr	(A0)
NoChange
	move.w	#1,Change
	moveq	#0,D0
	rts

***************************************************************************
******************** DTP_Volume DTP_Balance *******************************
***************************************************************************

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

*-------------------------------- Set All -------------------------------*

SetAll
	movem.l	D0/A1/A5,-(A7)
	lea	Periods(PC),A5
	move.w	(A5)+,D0
	lea	StructAdr+UPS_Voice1Adr(PC),A1
	cmp.l	#$DFF0A0,A3
	beq.s	.SetVoice
	move.w	(A5)+,D0
	lea	StructAdr+UPS_Voice2Adr(PC),A1
	cmp.l	#$DFF0B0,A3
	beq.s	.SetVoice
	move.w	(A5)+,D0
	lea	StructAdr+UPS_Voice3Adr(PC),A1
	cmp.l	#$DFF0C0,A3
	beq.s	.SetVoice
	move.w	(A5)+,D0
	lea	StructAdr+UPS_Voice4Adr(PC),A1
.SetVoice
	move.l	A2,(A1)
	move.w	$16(A4),UPS_Voice1Len(A1)
	move.w	D0,UPS_Voice1Per(A1)
	movem.l	(A7)+,D0/A1/A5
	rts

*-------------------------------- Set All2 -------------------------------*

SetAll2
	movem.l	D0/A2/A5,-(A7)
	lea	Periods(PC),A5
	move.w	(A5)+,D0
	lea	StructAdr+UPS_Voice1Adr(PC),A2
	cmp.l	#$DFF0A0,(A0)
	beq.s	.SetVoice
	move.w	(A5)+,D0
	lea	StructAdr+UPS_Voice2Adr(PC),A2
	cmp.l	#$DFF0B0,(A0)
	beq.s	.SetVoice
	move.w	(A5)+,D0
	lea	StructAdr+UPS_Voice3Adr(PC),A2
	cmp.l	#$DFF0C0,(A0)
	beq.s	.SetVoice
	move.w	(A5)+,D0
	lea	StructAdr+UPS_Voice4Adr(PC),A2
.SetVoice
	move.l	A1,(A2)
	move.w	D2,UPS_Voice1Len(A2)
	move.w	D0,UPS_Voice1Per(A2)
	movem.l	(A7)+,D0/A2/A5
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
******************************* DTP_Check2 ********************************
***************************************************************************

Check2
	move.l	dtg_ChkData(A5),A0
	moveq	#-1,D0

	move.l	A0,A1
	cmp.l	#$48E7FFFE,(A0)
	bne.b	NoMCMD
	moveq	#-1,D5
	addq.l	#4,A0
	moveq	#0,D1
	cmp.b	#$61,(A0)+
	bne.b	Fault1
	move.b	(A0)+,D1
	beq.b	Fault1
	btst	#0,D1
	bne.b	Fault1
	add.w	D1,A0
	cmp.l	#$2F006100,(A0)+
	bne.b	Fault1
	add.w	(A0),A0
	cmp.w	#$41FA,(A0)
	bne.b	Fault1
	lea	18(A0),A0
	cmp.w	#$41FA,(A0)+
	bne.b	Fault1
	add.w	(A0),A0
	move.l	A0,A2
	cmp.l	#'MCMD',(A0)
	beq.w	Found
Fault1
	rts
NoMCMD
	moveq	#0,D5
	moveq	#0,D1
	cmp.b	#$60,(A0)+
	bne.b	Fault1
	move.b	(A0)+,D1
	bne.b	No3
	moveq	#1,D5
	move.w	(A0),D1
	bmi.b	Fault1
	btst	#0,D1
	bne.b	Fault1
	cmp.w	#$6000,2(A0)
	bne.b	Fault1
	add.w	D1,A0
	cmp.l	#$48E7FFFE,(A0)+
	bne.b	Fault1
	bra.b	Later
No3
	btst	#0,D1
	bne.b	Fault1
	add.w	D1,A0
	cmp.l	#$48E7FFFE,(A0)+
	bne.b	Fault1
	cmp.w	#$6100,(A0)+
	bne.w	Fault
	add.w	(A0),A0
	cmp.l	#$2F006100,(A0)+
	bne.b	Fault
	add.w	(A0),A0
	cmp.w	#$41FA,(A0)
	bne.b	Fault
	lea	20(A0),A0
Later
	cmp.w	#$41FA,(A0)+
	beq.b	Later2
	cmp.w	#$41FA,(A0)+
	bne.b	Fault
Later2
	add.w	(A0),A0
	move.l	A0,A2
	cmp.l	#'TFMX',(A0)+
	bne.b	Fault
	tst.b	(A0)
	bne.b	Fault
	tst.w	12(A0)				; SFX file test
	beq.b	Fault
	moveq	#2,D1
	add.w	(A0)+,D1
	add.w	(A0)+,D1
	lsl.l	#6,D1
	moveq	#1,D2
	add.w	(A0)+,D2
	moveq	#1,D3
	add.w	(A0)+,D3
	mulu.w	#12,D3
	mulu.w	(A0)+,D2
	add.l	D2,D1
	add.l	D3,D1
	addq.l	#2,A0
	moveq	#1,D2
	add.w	(A0)+,D2
	mulu.w	#6,D2
	add.l	D2,D1
	moveq	#32,D2
	add.l	D2,D1
	add.l	D1,A0
	tst.l	(A0)+
	bne.b	Fault
	move.w	(A0),D2
	beq.b	Fault
	add.l	D2,D2
	cmp.l	26(A0),D2
	bne.b	Fault
Found
	sub.l	A1,A2
	lea	DataTemp(PC),A0
	move.l	A2,(A0)+
	move.b	D5,(A0)				; Format

	moveq	#0,D0
Fault
	rts

***************************************************************************
***************************** EP_Get_ModuleInfo ***************************
***************************************************************************

GetInfos
	lea	InfoBuffer(PC),A0
	rts

SubSongs	=	4
LoadSize	=	12
CalcSize	=	20
Pattern		=	28
Length		=	36
SamplesSize	=	44
SongSize	=	52
Samples		=	60
Special		=	68
Extra		=	76
Prefix		=	84
Author		=	92

InfoBuffer
	dc.l	MI_SubSongs,0		;4
	dc.l	MI_LoadSize,0		;12
	dc.l	MI_Calcsize,0		;20
	dc.l	MI_Pattern,0		;28
	dc.l	MI_Length,0		;36
	dc.l	MI_SamplesSize,0	;44
	dc.l	MI_Songsize,0		;52
	dc.l	MI_Samples,0		;60
	dc.l	MI_SpecialInfo,0	;68
	dc.l	MI_ExtraInfo,0		;76
	dc.l	MI_Prefix,0		;84
	dc.l	MI_AuthorName,0		;92
	dc.l	0

***************************************************************************
***************************** DTP_Intterrupt ******************************
***************************************************************************

Interrupt	
	movem.l	D0-D7/A0-A6,-(SP)

	lea	StructAdr(PC),A0
	st	UPS_Enabled(A0)
	clr.w	UPS_Voice1Per(A0)
	clr.w	UPS_Voice2Per(A0)
	clr.w	UPS_Voice3Per(A0)
	clr.w	UPS_Voice4Per(A0)
	move.w	#UPSB_Adr!UPSB_Len!UPSB_Per!UPSB_Vol,UPS_Flags(A0)

	move.l	PlayPtr(PC),A0
	jsr	(A0)			; play module

	lea	StructAdr(PC),A0
	clr.w	UPS_Enabled(A0)

	movem.l	(SP)+,D0-D7/A0-A6
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

***************************************************************************
***************************** DTP_SubSongRange ****************************
***************************************************************************

SubSongRange	
	moveq	#1,D0
	move.l	InfoBuffer+SubSongs(PC),D1
	rts

***************************************************************************
***************************** DTP_InitPlayer ******************************
***************************************************************************

InitPlayer
	moveq	#0,D0
	movea.l	dtg_GetListData(A5),A0
	jsr	(A0)

	lea	ModulePtr(PC),A6
	move.l	A0,(A6)+			; module buffer

	lea	InfoBuffer(PC),A4
	move.l	D0,LoadSize(A4)

	lea	Format(PC),A3
	move.b	(A3)+,(A3)			; current format
	lea	PlayerName(PC),A1
	lea	Prefix1(PC),A2
	clr.l	Special(A4)
	tst.b	(A3)
	bpl.b	Hip
	lea	Text2(PC),A1
	move.l	A1,Special(A4)
	lea	Prefix2(PC),A2
	sub.l	A1,A1
Hip
	move.l	A2,Prefix(A4)
	move.l	A1,Author(A4)
	bne.b	Hipcio
	lea	10(A0),A1
FindPlay
	cmp.l	#$48E7FFFE,(A1)
	beq.b	Old1
	addq.l	#2,A1
	bra.b	FindPlay
Hipcio
	move.l	A0,A1
	addq.l	#2,A1
	tst.b	(A3)
	beq.b	Old1
	addq.l	#2,A1
Old1
	move.l	A1,(A6)+			; PlayPtr

	move.l	DataTemp(PC),D1
	lea	(A0,D1.L),A1

	moveq	#2,D0
	moveq	#32,D1
	tst.b	(A3)
	bpl.b	Hipcio1
	moveq	#0,D0
	moveq	#18,D1
Hipcio1
	add.w	4(A1),D0
	add.w	6(A1),D0
	lsl.l	#6,D0
	add.l	D1,D0
	moveq	#1,D1
	tst.b	(A3)
	bpl.b	Hipcio2
	moveq	#0,D1
Hipcio2
	add.w	8(A1),D1
	move.l	D1,Pattern(A4)
	mulu.w	12(A1),D1
	add.l	D1,D0
	moveq	#1,D1
	tst.b	(A3)
	bpl.b	Hipcio3
	moveq	#0,D1
Hipcio3
	add.w	10(A1),D1
	mulu.w	#12,D1
	add.l	D1,D0
	lea	(A1,D0.L),A2
	move.l	A2,(A6)+			; subsongs ptr
	moveq	#1,D1
	tst.b	(A3)
	bpl.b	Hipcio4
	move.w	14(A1),D2
	move.w	D2,D1
	lsl.l	#3,D1
	bra.b	Dodaj
Hipcio4
	add.w	16(A1),D1
	mulu.w	#6,D1
	move.w	16(A1),D2
Dodaj
	move.w	D2,SubSongs+2(A4)
	add.l	D1,D0
	lea	(A1,D0.L),A2
	move.l	A2,(A6)+			; sampleinfo ptr
	move.w	18(A1),D1
	moveq	#30,D2
	tst.b	(A3)
	bpl.b	Hipcio5
	move.w	16(A1),D1
	moveq	#28,D2
Hipcio5
	move.l	D1,Samples(A4)
	mulu.w	D2,D1
	add.l	D1,D0

	lea	(A1,D0.L),A2
	move.l	A2,(A6)+			; samples ptr
	move.l	A2,A1
	tst.b	(A3)
	bpl.b	Hipcio6
	addq.l	#2,A1
Hipcio6
	moveq	#0,D0
	move.w	-8(A1),D0
	add.l	D0,D0
	add.l	-12(A1),D0
	move.l	D0,SamplesSize(A4)
	sub.l	A0,A2
	move.l	A2,SongSize(A4)
	add.l	A2,D0
	move.l	D0,CalcSize(A4)

	move.l	A5,(A6)+			; EagleBase
	tst.b	(A3)
	bpl.b	FindOne
	move.l	PlayPtr(PC),A0
	addq.l	#6,A0
	add.w	(A0),A0
FindRTS
	cmp.w	#$4E75,(A0)+
	bne.b	FindRTS
	bra.b	FindTwo
FindOne
	cmp.w	#$F096,(A0)+
	bne.b	FindOne
FindTwo
	cmp.w	#$41FA,(A0)+
	bne.b	FindTwo
	cmp.w	#$6100,2(A0)
	bne.b	FindOne
	move.l	A0,A2
	add.w	(A2),A2
	move.l	A2,(A6)+			; Voice1Data

	lea	256(A0),A1
	move.l	A0,A2
FindDMA
	cmp.l	#$3D470096,(A0)
	bne.b	NoDMA
	addq.l	#4,A0
	cmp.b	#$61,(A0)
	bne.b	ExitDMA
	move.w	#'WT',(A0)
	bra.b	ExitDMA
NoDMA
	addq.l	#2,A0
	cmp.l	A0,A1
	bne.b	FindDMA
ExitDMA
	tst.b	(A3)
	beq.b	NoNew
FindChip
	cmp.w	#$3A85,(A2)+
	bne.b	FindChip
FindBra
	cmp.w	#$6100,(A2)+
	bne.b	FindBra
	move.l	A2,A0
	add.w	(A0),A0
	move.l	A0,PatchE+2
	move.l	A0,PatchF+2
	move.l	A0,PatchG+2
	move.l	A0,PatchH+2
	subq.l	#2,A2
	move.l	#'WTWT',D0
	cmp.w	#$A6,6(A2)
	bne.b	NoNew
	move.l	D0,(A2)+
	addq.l	#8,A2
	cmp.w	#$B6,6(A2)
	bne.b	NoNew
	move.l	D0,(A2)+
	addq.l	#8,A2
	cmp.w	#$C6,6(A2)
	bne.b	NoNew
	move.l	D0,(A2)+
	addq.l	#8,A2
	cmp.w	#$D6,6(A2)
	bne.b	NoNew
	move.l	D0,(A2)+
NoNew
	move.l	ModulePtr(PC),A0
FindFilter
	cmp.w	#$00BF,(A0)+
	bne.b	FindFilter
FindLea2
	cmp.w	#$41FA,-(A0)
	bne.b	FindLea2
	addq.l	#2,A0
	add.w	(A0),A0
	clr.l	Extra(A4)
	tst.w	(A0)
	beq.b	NoInit
	clr.w	(A0)				; init flag
	lea	Text1(PC),A0
	move.l	A0,Extra(A4)
NoInit
	clr.w	(A6)				; clearing change
	bsr.w	ModuleChange

	movea.l	dtg_AudioAlloc(A5),A0
	jmp	(A0)


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

	lea	Periods(PC),A0
	clr.l	(A0)+
	clr.l	(A0)

	move.l	SubSongsPtr(PC),A0
	move.w	dtg_SndNum(A5),D0
	move.w	D0,D1
	subq.w	#1,D1
	tst.b	CurrentFormat
	bpl.b	NoMCM
	lsl.w	#3,D1
	bra.b	SkipMC
NoMCM
	mulu.w	#6,D1
SkipMC
	move.w	2(A0,D1.W),D2
	sub.w	0(A0,D1.W),D2
	bpl.b	LengthOK
	clr.l	0(A0,D1.W)
	moveq	#0,D2
LengthOK
	addq.w	#1,D2
	lea	InfoBuffer(PC),A0
	move.w	D2,Length+2(A0)
	lea	InitFlag(PC),A1
	st	(A1)
	move.l	ModulePtr(PC),A0
	jsr	(A0)
	clr.w	(A1)
	rts

***************************************************************************
***************************** DTP_EndSound ********************************
***************************************************************************

EndSound
	lea	$DFF000,A0
	move.w	#15,$96(A0)
	moveq	#0,D0
	move.w	D0,$A8(A0)
	move.w	D0,$B8(A0)
	move.w	D0,$C8(A0)
	move.w	D0,$D8(A0)
	rts

	*----------------- PatchTable for Jochen Hippel -------------------*

PatchTable
	dc.w	Code0-PatchTable,(Code0End-Code0)/2-1,Patch0-PatchTable
	dc.w	Code1-PatchTable,(Code1End-Code1)/2-1,Patch1-PatchTable
	dc.w	Code2-PatchTable,(Code2End-Code2)/2-1,Patch2-PatchTable
	dc.w	Code3-PatchTable,(Code3End-Code3)/2-1,Patch3-PatchTable
	dc.w	Code4-PatchTable,(Code4End-Code4)/2-1,Patch4-PatchTable
	dc.w	Code5-PatchTable,(Code5End-Code5)/2-1,Patch5-PatchTable
	dc.w	Code6-PatchTable,(Code6End-Code6)/2-1,Patch6-PatchTable
	dc.w	Code7-PatchTable,(Code7End-Code7)/2-1,Patch7-PatchTable
	dc.w	Code8-PatchTable,(Code8End-Code8)/2-1,Patch8-PatchTable
	dc.w	Code9-PatchTable,(Code9End-Code9)/2-1,Patch9-PatchTable
	dc.w	CodeA-PatchTable,(CodeAEnd-CodeA)/2-1,PatchA-PatchTable
	dc.w	CodeB-PatchTable,(CodeBEnd-CodeB)/2-1,PatchB-PatchTable
	dc.w	CodeC-PatchTable,(CodeCEnd-CodeC)/2-1,PatchC-PatchTable
	dc.w	CodeD-PatchTable,(CodeDEnd-CodeD)/2-1,PatchD-PatchTable
	dc.w	0

PatchTable2
	dc.w	Code0-PatchTable2,(Code0End-Code0)/2-1,Patch0-PatchTable2
	dc.w	Code1-PatchTable2,(Code1End-Code1)/2-1,Patch1-PatchTable2
	dc.w	Code4-PatchTable2,(Code4End-Code4)/2-1,Patch4-PatchTable2
	dc.w	CodeE-PatchTable2,(CodeEEnd-CodeE)/2-1,PatchE-PatchTable2
	dc.w	CodeF-PatchTable2,(CodeFEnd-CodeF)/2-1,PatchF-PatchTable2
	dc.w	CodeG-PatchTable2,(CodeGEnd-CodeG)/2-1,PatchG-PatchTable2
	dc.w	CodeH-PatchTable2,(CodeHEnd-CodeH)/2-1,PatchH-PatchTable2
	dc.w	CodeI-PatchTable2,(CodeIEnd-CodeI)/2-1,PatchI-PatchTable2
	dc.w	CodeJ-PatchTable2,(CodeJEnd-CodeJ)/2-1,PatchJ-PatchTable2
	dc.w	CodeK-PatchTable2,(CodeKEnd-CodeK)/2-1,PatchK-PatchTable2
	dc.w	CodeL-PatchTable2,(CodeLEnd-CodeL)/2-1,PatchL-PatchTable2
	dc.w	CodeM-PatchTable2,(CodeMEnd-CodeM)/2-1,PatchM-PatchTable2
	dc.w	CodeN-PatchTable2,(CodeNEnd-CodeN)/2-1,PatchN-PatchTable2
	dc.w	CodeO-PatchTable2,(CodeOEnd-CodeO)/2-1,PatchO-PatchTable2
	dc.w	CodeP-PatchTable2,(CodePEnd-CodeP)/2-1,PatchP-PatchTable2
	dc.w	CodeQ-PatchTable2,(CodeQEnd-CodeQ)/2-1,PatchQ-PatchTable2
	dc.w	CodeS-PatchTable2,(CodeSEnd-CodeS)/2-1,PatchS-PatchTable2
	dc.w	CodeT-PatchTable2,(CodeTEnd-CodeT)/2-1,PatchT-PatchTable2
	dc.w	0

; DMAWait patch for Jochen Hippel modules (2nd & 3rd type) & MCMD modules

Code0
	MOVE.W	D7,$96(A6)
	dc.w	'WT'
Code0End
Patch0
	bsr.w	DMAWait
	move.w	D7,$96(A6)
	bsr.w	DMAWait
	rts

; DMAWait patch for Jochen Hippel modules (2nd & 3rd type) & MCMD modules

Code1
lbC0008AA	MOVE.B	6(A6),D6
lbC0008AE	CMP.B	6(A6),D6
	BEQ.S	lbC0008AE
Code1End
Patch1
	rts

; SongEnd (loop) patch for Jochen Hippel modules (1st & 2nd type)

Code2
	MOVE.L	D5,4(A0)
	MOVEA.L	(A0),A2
Code2End
Patch2
	bsr.w	SongEnd
	move.l	D5,4(A0)
	move.l	(A0),A2
	rts

; DMAWait patch for Jochen Hippel modules (1st type)

Code3
	MOVE.W	(SP)+,$DFF096
Code3End
Patch3
	bsr.w	DMAWait
	move.w	4(SP),$DFF096
	move.l	(SP),2(SP)
	addq.l	#2,SP
	bsr.w	DMAWait
	rts

; SongEnd (stop) patch for Jochen Hippel modules

Code4
	MOVE.W	#15,$DFF096
Code4End
Patch4
	move.w	#15,$DFF096
	tst.w	InitFlag
	bne.b	NoEnd
	bsr.w	SongEnd
	move.l	EagleBase(PC),A5
	bsr.w	InitSound
NoEnd
	rts

; Address/length/period patch for Jochen Hippel modules (2nd type)

Code5
	ADDA.L	D1,A2
	MOVE.L	A2,$44(A0)
	MOVE.W	$16(A4),4(A3)
Code5End
Patch5
	bsr.w	SetAll
	add.l	D1,A2
	move.l	A2,$44(A0)
	move.w	$16(A4),4(A3)
	rts

; Volume (voice 1) patch for Jochen Hippel modules (2nd type)

Code6
	MOVE.L	D0,$DFF0A6
Code6End
Patch6
	movem.l	D1/A0,-(SP)
	move.w	D0,D1
	and.w	#$7F,D1
	mulu.w	LeftVolume(PC),D1
	and.w	Voice1(PC),D1
	lsr.w	#6,D1
	lea	StructAdr+UPS_Voice1Vol(PC),A0
	move.w	D1,(A0)
	move.w	D1,D0
	swap	D0
	lea	Periods(PC),A0
	move.w	D0,(A0)
	swap	D0
	movem.l	(SP)+,D1/A0
	move.l	D0,$DFF0A6
	rts

; Volume (voice 2) patch for Jochen Hippel modules (2nd type)

Code7
	MOVE.L	D0,$DFF0B6
Code7End
Patch7
	movem.l	D1/A0,-(SP)
	move.w	D0,D1
	and.w	#$7F,D1
	mulu.w	RightVolume(PC),D1
	and.w	Voice2(PC),D1
	lsr.w	#6,D1
	lea	StructAdr+UPS_Voice2Vol(PC),A0
	move.w	D1,(A0)
	move.w	D1,D0
	swap	D0
	lea	Periods+2(PC),A0
	move.w	D0,(A0)
	swap	D0
	movem.l	(SP)+,D1/A0
	move.l	D0,$DFF0B6
	rts

; Volume (voice 3) patch for Jochen Hippel modules (2nd type)

Code8
	MOVE.L	D0,$DFF0C6
Code8End
Patch8
	movem.l	D1/A0,-(SP)
	move.w	D0,D1
	and.w	#$7F,D1
	mulu.w	RightVolume(PC),D1
	and.w	Voice3(PC),D1
	lsr.w	#6,D1
	lea	StructAdr+UPS_Voice3Vol(PC),A0
	move.w	D1,(A0)
	move.w	D1,D0
	swap	D0
	lea	Periods+4(PC),A0
	move.w	D0,(A0)
	swap	D0
	movem.l	(SP)+,D1/A0
	move.l	D0,$DFF0C6
	rts

; Volume (voice 4) patch for Jochen Hippel modules (2nd type)

Code9
	MOVE.L	D0,$DFF0D6
Code9End
Patch9
	movem.l	D1/A0,-(SP)
	move.w	D0,D1
	and.w	#$7F,D1
	mulu.w	LeftVolume(PC),D1
	and.w	Voice4(PC),D1
	lsr.w	#6,D1
	lea	StructAdr+UPS_Voice4Vol(PC),A0
	move.w	D1,(A0)
	move.w	D1,D0
	swap	D0
	lea	Periods+6(PC),A0
	move.w	D0,(A0)
	swap	D0
	movem.l	(SP)+,D1/A0
	move.l	D0,$DFF0D6
	rts

; Address/length/period patch for Jochen Hippel modules (1st type)

CodeA
	MOVE.L	D1,$44(A0)
	MOVE.W	$16(A4),4(A3)
CodeAEnd
PatchA
	move.l	A2,-(SP)
	move.l	D1,A2
	bsr.w	SetAll
	move.l	(SP)+,A2
	move.l	D1,$44(A0)
	move.w	$16(A4),4(A3)
	rts

; Volume patch (voice 1 & 2) for Jochen Hippel modules (1st type)

CodeB
	MOVE.W	(A6)+,$A6(A5)
	MOVE.W	(A6)+,$A8(A5)
	MOVE.W	(A6)+,$B6(A5)
	MOVE.W	(A6)+,$B8(A5)
CodeBEnd
PatchB
	move.l	D0,-(SP)
	move.l	(A6)+,D0
	bsr.w	Patch6
	move.l	(A6)+,D0
	bsr.w	Patch7
	movem.l	(SP)+,D0
	rts

; Volume patch (voice 3) for Jochen Hippel modules (1st type)

CodeC
	MOVE.W	(A6)+,$C6(A5)
	MOVE.W	(A6)+,$C8(A5)
CodeCEnd
PatchC
	move.l	D0,-(SP)
	move.l	(A6)+,D0
	bsr.w	Patch8
	movem.l	(SP)+,D0
	rts

; Volume patch (voice 4) for Jochen Hippel modules (1st type)

CodeD
	MOVE.W	(A6)+,$D6(A5)
	MOVE.W	(A6)+,$D8(A5)
CodeDEnd
PatchD
	move.l	D0,-(SP)
	move.l	(A6)+,D0
	bsr.w	Patch9
	movem.l	(SP)+,D0
	rts

; Volume (voice 1) patch for Jochen Hippel modules (3rd type) & MCMD modules

CodeE
	dc.l	'WTWT'
	MOVE.L	D0,$A6(A6)
CodeEEnd
PatchE
	jsr	'WTWT'
	bsr.w	Patch6
	rts

; Volume (voice 2) patch for Jochen Hippel modules (3rd type) & MCMD modules

CodeF
	dc.l	'WTWT'
	MOVE.L	D0,$B6(A6)
CodeFEnd
PatchF
	jsr	'WTWT'
	bsr.w	Patch7
	rts

; Volume (voice 3) patch for Jochen Hippel modules (3rd type) & MCMD modules

CodeG
	dc.l	'WTWT'
	MOVE.L	D0,$C6(A6)
CodeGEnd
PatchG
	jsr	'WTWT'
	bsr.w	Patch8
	rts

; Volume (voice 4) patch for Jochen Hippel modules (3rd type) & MCMD modules

CodeH
	dc.l	'WTWT'
	MOVE.L	D0,$D6(A6)
CodeHEnd
PatchH
	jsr	'WTWT'
	bsr.w	Patch9
	rts

; SongEnd (loop) patch for Jochen Hippel modules (3rd type)

CodeI
	MOVE.W	D5,$3A(A0)
	MOVEA.L	4(A0),A2
CodeIEnd
PatchI
	bsr.w	SongEnd
	move.w	D5,$3A(A0)
	move.l	4(A0),A2
	rts

; Address/length/period patch for Jochen Hippel modules (3rd type)

CodeJ
	MOVE.W	$1A(A4),D1
	ADDA.L	D1,A2
CodeJEnd
PatchJ
	move.l	A3,-(SP)
	move.l	(A0),A3
	bsr.w	SetAll
	move.l	(SP)+,A3
	move.w	$1A(A4),D1
	add.l	D1,A2
	rts

; Address/length/period patch for Jochen Hippel modules (3rd type)

CodeK
	MOVEA.L	0(A0),A2
	MOVE.L	A1,(A2)+
	MOVE.W	D2,(A2)+
CodeKEnd
PatchK
	bsr.w	SetAll2
	move.l	(A0),A2
	move.l	A1,(A2)+
	move.w	D2,(A2)+
	rts

; Address/length/period patch for MCMD modules

CodeL
	MOVE.L	D1,(A3)
	MOVEQ	#0,D2
	MOVE.W	$18(A4),D2
CodeLEnd
PatchL
	move.l	A2,-(SP)
	move.l	D1,A2
	bsr.w	SetAll
	move.l	(SP)+,A2
	move.l	D1,(A3)
	moveq	#0,D2
	move.w	$18(A4),D2
	rts

; SongEnd (loop) patch for MCMD modules

CodeM
	MOVE.W	D1,$24(A0)
	MOVEA.L	0(A0),A2
CodeMEnd
PatchM
	bsr.w	SongEnd
	move.w	D1,$24(A0)
	move.l	(A0),A2
	rts

; SongEnd (stop) patch for MCMD modules

CodeN
	MOVE.W	#15,$96(A6)
	MOVEQ	#0,D0
CodeNEnd
PatchN
	move.w	#15,$96(A6)
	bsr.w	SongEnd
	move.l	EagleBase(PC),A5
	bsr.w	InitSound
	moveq	#0,D0
	rts

; Initialization song fix for Jochen Hippel modules (3rd type)

CodeO
	SUBQ.L	#1,D0
	ADD.W	D0,D0
	MOVE.W	D0,D1
	ADD.W	D1,D0
CodeOEnd
PatchO
	subq.w	#1,D0
	add.w	D0,D0
	move.w	D0,D1
	add.w	D0,D0
	add.w	D1,D0
	rts

; Wait fix for Jochen Hippel modules (3rd type)

CodeP
	MOVE.W	#4,(A3)+
	MOVEQ	#0,D1
CodePEnd
PatchP
	moveq	#0,D1
	rts

; Wait fix for Jochen Hippel modules (3rd type)

CodeQ
	MOVE.W	D2,(A3)+
	MOVE.W	#4,(A3)
CodeQEnd
PatchQ
	move.w	D2,(A3)+
	rts

; Wait fix for Jochen Hippel modules (3rd type)

CodeS
	MOVE.W	#4,6(A3)
	MOVEQ	#0,D1
CodeSEnd
PatchS
	moveq	#0,D1
	rts

; Wait fix for Jochen Hippel modules (3rd type)

CodeT
	MOVE.W	#4,(A3)
	MOVEQ	#0,D1
CodeTEnd
PatchT
	moveq	#0,D1
	rts

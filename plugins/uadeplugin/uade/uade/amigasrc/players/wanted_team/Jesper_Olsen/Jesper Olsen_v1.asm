 	*****************************************************
	****    Jesper Olsen replayer for EaglePlayer	 ****
	****        all adaptions by Wanted Team,	 ****
	****     DeliTracker 2.32 compatible version	 ****
	*****************************************************

	incdir	"dh2:include/"
	include 'misc/eagleplayer2.01.i'
	include	'hardware/custom.i'

	SECTION	Player,CODE

	PLAYERHEADER Tags

	dc.b	'$VER: Jesper Olsen player module V1.0 (23 Nov 2007)',0
	even
Tags
	dc.l	DTP_PlayerVersion,1
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
	dc.l	EP_Get_ModuleInfo,Get_ModuleInfo
	dc.l	DTP_Volume,SetVolume
	dc.l	DTP_Balance,SetBalance
	dc.l	EP_Voices,SetVoices
	dc.l	EP_StructInit,StructInit
	dc.l	EP_ModuleChange,ModuleChange
	dc.l	EP_SampleInit,SampleInit
	dc.l	EP_Flags,EPB_Volume!EPB_Balance!EPB_ModuleInfo!EPB_Voices!EPB_SampleInfo!EPB_Songend!EPB_Analyzer!EPB_NextSong!EPB_PrevSong!EPB_Packable!EPB_Restart
	dc.l	DTP_ExtLoad,ExtLoad
	dc.l	EP_GetPositionNr,GetPosition
	dc.l	TAG_DONE

PlayerName
	dc.b	'Jesper Olsen',0
Creator
	dc.b	'(c) 1990-95 by Jesper Olsen,',10
	dc.b	'adapted by Wanted Team',0
ExPlayerName
	dc.b	'WantedTeam.bin',0
Prefix
	dc.b	'JO.',0
	even
Mulu
	dc.w	0
ModulePtr
	dc.l	0
Format
	dc.b	0
CurrentFormat
	dc.b	0
Change
	dc.w	0
EagleBase
	dc.l	0
SampleInfo
	dc.l	0
ExPlayPtr
	dc.l	0
VoicePtrTemp
	dc.l	0
AddFlag
	dc.w	0
Value
	dc.w	0
Songend
	dc.l	'WTWT'
SongendTemp
	dc.l	0
VoicePtr
	dc.l	0
FirstStep
	dc.w	0
AddValue
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
********************************* EP_GetPosNr *****************************
***************************************************************************

GetPosition
	moveq	#0,D0
	move.l	VoicePtr(PC),A0
	move.b	CurrentFormat(PC),D1
	bmi.b	Poza
	bne.b	Sek
	add.w	Value(PC),A0
	add.w	AddValue(PC),A0
	move.w	(A0),D0
	bne.b	PosOK
	rts
Sek
	move.w	4(A0),D0
	bne.b	PosOK
	rts
Poza
	move.w	$34(A0),D0
	beq.b	NoPos
PosOK
	sub.w	FirstStep(PC),D0
	lsr.w	#1,D0
NoPos
	rts

***************************************************************************
******************************* EP_SampleInit *****************************
***************************************************************************

SampleInit
	moveq	#EPR_NotEnoughMem,D7
	lea	EPG_SampleInfoStructure(A5),A3
	move.l	SampleInfo(PC),D0
	beq.b	return
	move.l	D0,A2

	move.l	InfoBuffer+Samples(PC),D5
	beq.b	return
	subq.l	#1,D5
	move.b	CurrentFormat(PC),D1
	bmi.b	ThirdSamp
hop
	jsr	ENPP_AllocSampleStruct(A5)
	move.l	D0,(A3)
	beq.b	return
	move.l	D0,A3
NextSam
	cmp.l	#'FORM',(A2)
	bne.b	NoIFF4
	move.l	A2,EPS_Adr(A3)			; sample address
	addq.l	#4,A2
	move.l	(A2)+,D1
	move.l	D1,EPS_Length(A3)		; sample length
	move.l	#64,EPS_Volume(A3)
	lea	38(A2),A0
	move.w	(A0)+,EPS_MaxNameLen(A3)
	move.l	A0,EPS_SampleName(A3)		; sample name
	move.w	#USITY_RAW,EPS_Type(A3)
	move.w	#USIB_Playable!USIB_Saveable!USIB_8BIT,EPS_Flags(A3)
	bra.b	SkipInfo
NoIFF4
	addq.l	#2,A2
	bra.b	NextSam

SkipInfo
	dbf	D5,hop
backsamp
	moveq	#0,D7
return
	move.l	D7,D0
	rts

ThirdSamp
	move.l	ModulePtr(PC),A1
	moveq	#104,D2
hop3
	jsr	ENPP_AllocSampleStruct(A5)
	move.l	D0,(A3)
	beq.b	return
	move.l	D0,A3

	move.w	(A2)+,D1
	moveq	#0,D0
	move.w	18(A1,D1.W),D0
	add.l	D0,D0
	move.l	14(A1,D1.W),D1
	and.l	#$FFFFFF,D1
	add.l	A1,D1
	move.l	D1,A0
	cmp.l	#'FORM',-104(A0)
	bne.b	NoIFF3
	sub.l	D2,D1
	move.l	-(A0),D0
	add.l	D2,D0
	lea	-54(A0),A0
	move.w	(A0)+,EPS_MaxNameLen(A3)
	move.l	A0,EPS_SampleName(A3)		; sample name
NoIFF3
	move.l	D1,EPS_Adr(A3)			; sample address
	move.l	D0,EPS_Length(A3)		; sample length
	move.l	#64,EPS_Volume(A3)
	move.w	#USITY_RAW,EPS_Type(A3)
	move.w	#USIB_Playable!USIB_Saveable!USIB_8BIT,EPS_Flags(A3)
	dbf	D5,hop3
	bra.b	backsamp

***************************************************************************
******************************* DTP_ExtLoad *******************************
***************************************************************************

ExtLoad
	move.b	Format(PC),D0
	bpl.b	NoExt
	movea.l	dtg_PathArrayPtr(A5),A0
	clr.b	(A0)
	movea.l	dtg_CopyDir(A5),A0
	jsr	(A0)
	movea.l	dtg_PathArrayPtr(A5),A0
loop
	tst.b	(A0)+
	bne.s	loop
	subq.l	#1,A0
	lea	ExPlayerName(PC),A1
smp
	move.b	(A1)+,(A0)+
	bne.s	smp
	movea.l	dtg_LoadFile(A5),A0
	jmp	(A0)
NoExt
	moveq	#0,D0
	rts

***************************************************************************
**************************** EP_ModuleChange ******************************
***************************************************************************

ModuleChange
	move.w	Change(PC),D0
	bne.s	NoChange

	move.b	CurrentFormat(PC),D2
	cmp.b	#1,D2
	bne.b	NoOne
	lea	PatchTable1(PC),A1
	move.l	ModulePtr(PC),A0
	move.l	#1500,D1
	bra.b	RightPatch
NoOne
	lea	PatchTable2(PC),A1
	move.l	#1700,D1
	move.l	ModulePtr(PC),A0
	addq.l	#6,A0
	add.w	(A0),A0
	tst.b	D2
	beq.b	RightPatch
	lea	PatchTable(PC),A1
	move.l	ExPlayPtr(PC),A0
RightPatch
	move.l	A0,EPG_ARG1(A5)
	move.l	A1,EPG_ARG3(A5)
	move.l	D1,EPG_ARG2(A5)
	moveq	#-2,D0
	move.l	d0,EPG_ARG5(A5)		
	moveq	#1,D0
	move.l	d0,EPG_ARG4(A5)			;Search-Modus
	moveq	#5,D0
	move.l	d0,EPG_ARGN(A5)
	move.l	EPG_ModuleChange(A5),A0
	jsr	(A0)
NoChange
	move.w	#1,Change
	moveq	#0,D0
	rts

***************************************************************************
******************************* EP_StructInit *****************************
***************************************************************************

StructInit
	lea	StructAdr(PC),A0
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
	move.l	D2,-(A7)
	and.w	#$7F,D0
	move.l	A2,D2
	cmp.w	#$F0A0,D2
	beq.s	Left1
	cmp.w	#$F0B0,D2
	beq.s	Right1
	cmp.w	#$F0C0,D2
	beq.s	Right2
	cmp.w	#$F0D0,D2
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
	move.w	D0,8(A2)
Exit2
	move.l	(A7)+,D2
	rts

*------------------------------- Set Vol -------------------------------*

SetVol
	move.l	A0,-(A7)
	lea	StructAdr+UPS_Voice1Vol(PC),A0
	cmp.l	#$DFF0A0,A2
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice2Vol(PC),A0
	cmp.l	#$DFF0B0,A2
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice3Vol(PC),A0
	cmp.l	#$DFF0C0,A2
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
	cmp.l	#$DFF0A0,A2
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice2Adr(PC),A0
	cmp.l	#$DFF0B0,A2
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice3Adr(PC),A0
	cmp.l	#$DFF0C0,A2
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
	cmp.l	#$DFF0A0,A2
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice2Len(PC),A0
	cmp.l	#$DFF0B0,A2
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice3Len(PC),A0
	cmp.l	#$DFF0C0,A2
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice4Len(PC),A0
.SetVoice
	move.w	D0,(A0)
	move.l	(A7)+,A0
	rts

*------------------------------- Set Per -------------------------------*

SetPer
	move.l	A0,-(A7)
	lea	StructAdr+UPS_Voice1Per(PC),A0
	cmp.l	#$DFF0A0,A2
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice2Per(PC),A0
	cmp.l	#$DFF0B0,A2
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice3Per(PC),A0
	cmp.l	#$DFF0C0,A2
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
	lea	Voice1(pc),a0
	lea	StructAdr(pc),a1
	move.w	#$ffff,d1
	move.w	d1,(a0)+			Voice1=0 setzen
	btst	#0,d0
	bne.s	.NoVoice1
	clr.w	-2(a0)
	clr.w	$dff0a8
	clr.w	UPS_Voice1Vol(a1)
.NoVoice1
	move.w	d1,(a0)+			Voice2=0 setzen
	btst	#1,d0
	bne.s	.NoVoice2
	clr.w	-2(a0)
	clr.w	$dff0b8
	clr.w	UPS_Voice2Vol(a1)
.NoVoice2
	move.w	d1,(a0)+			Voice3=0 setzen
	btst	#2,d0
	bne.s	.NoVoice3
	clr.w	-2(a0)
	clr.w	$dff0c8
	clr.w	UPS_Voice3Vol(a1)
.NoVoice3
	move.w	d1,(a0)+			Voice4=0 setzen
	btst	#3,d0
	bne.s	.NoVoice4
	clr.w	-2(a0)
	clr.w	$dff0d8
	clr.w	UPS_Voice4Vol(a1)
.NoVoice4
	move.w	d0,UPS_DMACon(a1)
	moveq	#0,D0
	rts

***************************************************************************
******************************* DTP_Check2 ********************************
***************************************************************************

Check2
	movea.l	dtg_ChkData(A5),A0
	moveq	#-1,D0

	lea	Format(PC),A3

	cmp.w	#$6000,(A0)
	beq.w	CheckOld

	move.w	(A0),D1
	cmp.w	#$200,D1
	bhi.b	fault
	cmp.w	#4,D1
	blt.b	fault
	btst	#0,D1
	bne.b	fault
	lsr.w	#1,D1
	subq.w	#1,D1
	lea	2(A0),A1
NextChick
	move.w	(A1)+,D2
	beq.b	fault
	bmi.b	fault
	btst	#0,D2
	bne.b	fault
	lea	(A0,D2.W),A2
	cmp.w	#$7FFF,-2(A2)
	bne.b	fault
	dbf	D1,NextChick
	st	(A3)
	bra.b	found
Old
	move.b	#1,(A3)
found
	moveq	#0,D0
fault
	rts

CheckOld
	move.l	A0,A1
	moveq	#2,D1
NextBra
	cmp.w	#$6000,(A1)+
	bne.b	fault
	move.w	(A1)+,D2
	beq.b	fault
	bmi.b	fault
	btst	#0,D2
	bne.b	fault
	dbf	D1,NextBra
	addq.w	#6,A0
	add.w	(A0),A0
	cmp.l	#$4A406B00,(A0)+
	bne.b	CheckOlder
	cmp.l	#$000641FA,(A0)+
	bne.b	fault
	add.w	(A0),A0
	cmp.l	#$00017FFF,4(A0)
	beq.b	Old
	rts

CheckOlder
	subq.l	#4,A0
	cmp.w	#$C0FC,(A0)
	bne.b	No
	addq.l	#2,A0
	bra.b	Older
No
	moveq	#15,D1
NextWord
	cmp.l	#$02800000,(A0)
	beq.b	Late
	addq.l	#2,A0
	dbf	D1,NextWord
	rts

Late
	addq.l	#4,A0
	cmp.l	#$00FFC0FC,(A0)+
	bne.b	fault
Older
	move.w	(A0),-6(A3)			; mulu value
	lea	800(A0),A0
	lea	900(A0),A1
FindTable
	cmp.l	#$6AE064E0,(A0)
	beq.b	Okej
	addq.l	#2,A0
	cmp.l	A0,A1
	bne.b	FindTable
	rts
Okej
	clr.b	(A3)
	bra.w	found

***************************************************************************
***************************** EP_Get_ModuleInfo ***************************
***************************************************************************

Get_ModuleInfo
	lea	InfoBuffer(PC),A0
	rts

SubSongs	=	4
LoadSize	=	12
SongSize	=	20
SamplesSize	=	28
Samples		=	36
CalcSize	=	44
Length		=	52
Fast		=	60
Voices		=	68

InfoBuffer
	dc.l	MI_SubSongs,0		;4
	dc.l	MI_LoadSize,0		;12
	dc.l	MI_Songsize,0		;20
	dc.l	MI_SamplesSize,0	;28
	dc.l	MI_Samples,0		;36
	dc.l	MI_Calcsize,0		;44
	dc.l	MI_Length,0		;52
	dc.l	MI_OtherSize,0		;60
	dc.l	MI_Voices,0		;68
	dc.l	MI_MaxVoices,4
	dc.l	MI_Prefix,Prefix
	dc.l	MI_AuthorName,PlayerName
	dc.l	0

***************************************************************************
***************************** DTP_Intterrupt ******************************
***************************************************************************

Interrupt
	movem.l	D1-D7/A0-A6,-(SP)

	lea	StructAdr(PC),A0
	st	UPS_Enabled(A0)
	clr.w	UPS_Voice1Per(A0)
	clr.w	UPS_Voice2Per(A0)
	clr.w	UPS_Voice3Per(A0)
	clr.w	UPS_Voice4Per(A0)
	move.w	#UPSB_Adr!UPSB_Len!UPSB_Per!UPSB_Vol,UPS_Flags(A0)

	move.b	CurrentFormat(PC),D1
	bmi.b	PlayNew
	move.l	ModulePtr(PC),A0
	jsr	8(A0)			; play module
	bra.b	SkipPlay
PlayNew
	moveq	#0,D0
	move.l	ExPlayPtr(PC),A0
	jsr	(A0)			; play module
SkipPlay
	lea	StructAdr(PC),A0
	clr.w	UPS_Enabled(A0)

	movem.l	(SP)+,D1-D7/A0-A6
	moveq	#0,D0
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

SongEndTest
	movem.l	A1/A5,-(A7)
	lea	Songend(PC),A1
	cmp.l	#$DFF0A0,A2
	bne.b	test1
	clr.b	(A1)
	bra.b	test
test1
	cmp.l	#$DFF0B0,A2
	bne.b	test2
	clr.b	1(A1)
	bra.b	test
test2
	cmp.l	#$DFF0C0,A2
	bne.b	test3
	clr.b	2(A1)
	bra.b	test
test3
	cmp.l	#$DFF0D0,A2
	bne.b	test
	clr.b	3(A1)
test
	tst.l	(A1)+
	bne.b	SkipEnd
	move.l	(A1),-(A1)

	move.l	EagleBase(PC),A5
	move.l	dtg_SongEnd(A5),A1
	jsr	(A1)
SkipEnd
	movem.l	(A7)+,A1/A5
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
	move.b	(A6)+,D7
	move.b	D7,(A6)+			; Current Format
	clr.w	(A6)+				; Change
	move.l	A5,(A6)+			; EagleBase

	lea	InfoBuffer(PC),A4
	move.l	D0,LoadSize(A4)
	clr.l	Fast(A4)
	tst.b	D7
	bmi.w	Latest
	bne.w	Second
	lea	6(A0),A1
	add.w	(A1),A1
NextWord1
	move.w	(A1)+,D1
	bmi.b	NextWord1
	and.w	#$40FA,D1
	cmp.w	#$40FA,D1
	bne.b	NextWord1
	move.w	(A1)+,D1
	bmi.b	NextWord1
	subq.w	#2,A1
	add.w	D1,A1
	move.l	A1,4(A6)			; SongPtr in ExPlayPtr
	move.w	(A1),D2
	lea	(A0,D2.W),A2
	sub.l	A1,A2
	move.l	A2,D2
	move.l	A1,A2
	divu.w	Mulu(PC),D2
	tst.w	D2
	bne.b	SongOK
	moveq	#1,D2
SongOK
	move.w	D2,SubSongs+2(A4)

	lea	(A0,D0.L),A1
	moveq	#0,D0
	moveq	#0,D1
NextIFFO
	cmp.l	#'FORM',(A2)
	bne.b	NoIFFO
	tst.l	D1
	bne.b	PtrSetO
	move.l	A2,D1
PtrSetO
	addq.l	#1,D0
	addq.l	#4,A2
	add.l	(A2),A2
	addq.l	#2,A2
NoIFFO
	addq.l	#2,A2
	cmp.l	A2,A1
	bgt.b	NextIFFO
	move.l	D0,Samples(A4)

	move.l	D1,(A6)+			; SampleInfo
	addq.l	#4,A6

	lea	10(A0),A1
	add.w	(A1),A1
FindLea
	cmp.w	#$43FA,(A1)+
	bne.b	FindLea
	move.l	A1,A2
	add.w	(A1),A1
	move.l	A1,(A6)+			; VoicePtrTemp
	addq.l	#2,A2
	moveq	#0,D1
	cmp.w	#$D3D6,(A2)
	bne.b	NoAddL
	moveq	#1,D1
	bra.b	PutFlag
NoAddL
	cmp.w	#$D3D6,(A2)
	bne.b	PutFlag
	moveq	#1,D1
PutFlag
	move.w	D1,(A6)+			; AddFlag

	move.w	#$7FFE,D1
	cmp.w	#$6000,12(A0)
	beq.b	FindLoop
	addq.w	#1,D1
FindLoop
	cmp.w	(A2)+,D1
	bne.b	FindLoop
FindValue
	cmp.w	#$336C,(A2)+
	bne.b	FindValue
	move.w	2(A2),D1
	move.w	D1,(A6)				; Value
	move.w	D1,CodeN+4
	move.w	D1,PatchN+4
Jump
	clr.l	SongSize(A4)
	clr.l	CalcSize(A4)
	clr.l	SamplesSize(A4)
	bra.w	OneFile

Second
	move.l	A0,A1	
	addq.w	#6,A1
	add.w	(A1),A1
	addq.l	#8,A1
	add.w	(A1),A1				; song offset
	move.l	A1,4(A6)			; SongPtr in ExPlayPtr
	move.l	A1,A2
	addq.l	#8,A1
	moveq	#0,D1
	move.l	10(A1),D2
NextSong
	cmp.l	10(A1),D2
	bne.b	NoMore
	addq.l	#1,D1
	lea	$1A(A1),A1
	bra.b	NextSong
NoMore
	move.l	D1,SubSongs(A4)

	lea	(A0,D0.L),A1
	add.l	(A2),A2
	addq.l	#2,A2
	move.l	A2,(A6)+			; SampleInfo begin
	moveq	#0,D0
NextIFF
	cmp.l	#'FORM',(A2)
	bne.b	NoIFF
	addq.l	#1,D0
	addq.l	#4,A2
	add.l	(A2),A2
	addq.l	#2,A2
NoIFF
	addq.l	#2,A2
	cmp.l	A2,A1
	bgt.b	NextIFF

	move.l	D0,Samples(A4)
	move.l	(A6),A2
	move.l	(A2),D1
	move.l	18(A2),D2
	cmp.l	D1,D2
	bgt.b	EndVer
	add.l	(A2),A2
	sub.l	A0,A2
	move.l	A2,SongSize(A4)
	clr.l	CalcSize(A4)
	clr.l	SamplesSize(A4)
	bra.w	OneFile
EndVer
	move.l	D2,D3
	sub.l	22(A2),D3
	add.l	D3,D2
	add.l	A2,D2
	sub.l	A0,D2
	move.l	D2,CalcSize(A4)
	cmp.l	#35944,D2
	bne.b	NoLol
	subq.l	#1,SubSongs(A4)
NoLol
	cmp.l	LoadSize(A4),D2
	bgt.w	Short
	lsl.l	#2,D3
	add.l	(A2),A2
	sub.l	A0,A2
	add.l	A2,D3
	move.l	D3,SongSize(A4)
	sub.l	D3,D2
	move.l	D2,SamplesSize(A4)
	bra.w	OneFile
Latest
	move.w	(A0),D0
	move.w	2(A0,D0.W),D1
	move.w	(A0,D0.W),D3
	lsr.w	#1,D0
	subq.w	#1,D0
	cmp.w	#1,D0
	beq.b	SubOK
	tst.w	-6(A0,D3.W)
	beq.b	OneLeft
	cmp.w	#$7F00,-4(A0,D3.W)
	bne.b	SubOK
OneLeft
	subq.w	#1,D0
SubOK
	move.w	D0,SubSongs+2(A4)
	lea	(A0,D1.W),A1
	move.l	A1,(A6)+			; SampleInfo
	move.w	(A1),D2
	move.l	14(A0,D2.W),D3
	lea	(A0,D2.W),A2
	and.l	#$FFFFFF,D3			; high
	move.l	D3,D1				; low
	moveq	#0,D5
	moveq	#0,D2
NextS1
	addq.l	#1,D2
	move.w	(A1)+,D0
	move.l	14(A0,D0.W),D4
	and.l	#$FFFFFF,D4
	cmp.l	D4,D1
	blt.b	NoLow1
	move.l	D4,D1
NoLow1
	cmp.l	D4,D3
	bgt.b	NoHigh1
	move.l	D4,D3
	move.w	18(A0,D0.W),D5
	tst.b	14(A0,D0.W)
	bne.b	NoHigh1	
	move.l	20(A0,D0.W),D4
	cmp.l	D4,D3
	bgt.b	NoHigh1
	move.l	D4,D3
	move.w	24(A0,D0.W),D5
NoHigh1
	lea	(A0,D0.W),A3
	cmp.l	A3,A2
	blt.b	NoLow
	move.l	A3,A2
NoLow
	cmp.l	A1,A2
	bne.b	NextS1

	cmp.l	LoadSize(A4),D3
	bge.b	Short

	lea	(A0,D1.L),A1
	cmp.l	#'FORM',-104(A1)
	bne.b	NoIFF1
	moveq	#104,D0
	sub.l	D0,D1
NoIFF1
	move.l	D1,SongSize(A4)
	lea	(A0,D3.L),A1
	cmp.l	#'FORM',-104(A1)
	bne.b	NoIFF2
	add.l	-(A1),D3
	bra.b	SetCalc
NoIFF2
	add.l	D5,D5
	add.l	D5,D3
SetCalc
	move.l	D3,CalcSize(A4)
	sub.l	D1,D3
	move.l	D3,SamplesSize(A4)

	move.l	D2,Samples(A4)

	moveq	#1,D0
	movea.l	dtg_GetListData(A5),A0
	jsr	(A0)

	move.l	A0,(A6)				; ExPlayPtr
	cmp.l	#$4A806700,(A0)
	bne.b	InFile
	btst	#0,D0
	bne.b	InFile
	add.l	D0,A0
	cmp.l	#$3C3D3E3F,-(A0)
	bne.b	InFile
	move.l	D0,Fast(A4)
OneFile
	bsr.w	ModuleChange

	movea.l	dtg_AudioAlloc(A5),A0
	jmp	(A0)

Short
	moveq	#EPR_ModuleTooShort,D0		; error message
	rts
InFile
	moveq	#EPR_ErrorInFile,D0
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

	lea	Songend(PC),A0
	clr.l	(A0)
	clr.l	8(A0)				; VoicePtr
	move.l	ModulePtr(PC),A0
	move.b	CurrentFormat(PC),D1
	bmi.b	Latex
	bne.b	Secundo
	move.w	dtg_SndNum(A5),D0
	subq.w	#1,D0
	move.w	D0,D1
	lea	Songend(PC),A1
	move.l	#"WTWT",(A1)
	move.l	VoicePtrTemp(PC),8(A1)
	move.l	ExPlayPtr(PC),A2
	mulu.w	Mulu(PC),D1
	add.w	D1,A2
	move.w	(A2),12(A1)			; FirstStep
	move.w	AddFlag(PC),D1
	beq.b	AddZero
	move.w	Mulu(PC),D1
	move.w	-2(A2,D1.W),D1
AddZero
	move.w	D1,14(A1)			; AddValue
	moveq	#3,D1
NextVoice3
	tst.w	(A2)+
	bne.b	VoiceOn3
	clr.b	(A1)
VoiceOn3
	addq.l	#1,A1
	dbf	D1,NextVoice3
	jsr	4(A0)
	bra.b	Here
Secundo
	move.w	dtg_SndNum(A5),D0
	subq.w	#1,D0
	jsr	4(A0)
	move.l	ExPlayPtr(PC),A0
	bra.b	SkipLatex
Latex
	moveq	#80,D0
	lsl.l	#8,D0
	move.l	ExPlayPtr(PC),A1
	jsr	(A1)
	moveq	#64,D0
	lsl.l	#8,D0
	move.l	EagleBase(PC),A5
	or.w	dtg_SndNum(A5),D0
	move.l	ExPlayPtr(PC),A1
	jsr	(A1)
Here
	move.l	ModulePtr(PC),A0
SkipLatex
	add.w	FirstStep(PC),A0
	moveq	#0,D1
NextStep
	addq.l	#1,D1
	cmp.w	#$7FFE,(A0)
	beq.b	EndStep
	cmp.w	#$7FFF,(A0)+
	bne.b	NextStep
EndStep
	lea	InfoBuffer(PC),A1
	move.l	D1,Length(A1)
	lea	Songend(PC),A0
	move.l	(A0)+,(A0)
	moveq	#3,D1
	moveq	#0,D0
NextVoice1
	tst.b	(A0)+
	beq.b	NoVoice1
	addq.l	#1,D0
NoVoice1
	dbf	D1,NextVoice1
	move.l	D0,Voices(A1)
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

	*--------------- PatchTable for Jesper Olsen ------------------*

PatchTable
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
	dc.w	0
PatchTable1
	dc.w	CodeC-PatchTable1,(CodeCEnd-CodeC)/2-1,PatchC-PatchTable1
	dc.w	CodeD-PatchTable1,(CodeDEnd-CodeD)/2-1,PatchD-PatchTable1
	dc.w	CodeE-PatchTable1,(CodeEEnd-CodeE)/2-1,PatchE-PatchTable1
	dc.w	CodeF-PatchTable1,(CodeFEnd-CodeF)/2-1,PatchF-PatchTable1
	dc.w	CodeG-PatchTable1,(CodeGEnd-CodeG)/2-1,PatchG-PatchTable1
	dc.w	CodeH-PatchTable1,(CodeHEnd-CodeH)/2-1,PatchH-PatchTable1
	dc.w	CodeI-PatchTable1,(CodeIEnd-CodeI)/2-1,PatchI-PatchTable1
	dc.w	CodeJ-PatchTable1,(CodeJEnd-CodeJ)/2-1,PatchJ-PatchTable1
	dc.w	CodeK-PatchTable1,(CodeKEnd-CodeK)/2-1,PatchK-PatchTable1
	dc.w	CodeL-PatchTable1,(CodeLEnd-CodeL)/2-1,PatchL-PatchTable1
	dc.w	CodeM-PatchTable1,(CodeMEnd-CodeM)/2-1,PatchM-PatchTable1
	dc.w	CodeU-PatchTable1,(CodeUEnd-CodeU)/2-1,PatchU-PatchTable1
	dc.w	0
PatchTable2
	dc.w	Code2-PatchTable2,(Code2End-Code2)/2-1,Patch2-PatchTable2
	dc.w	CodeF-PatchTable2,(CodeFEnd-CodeF)/2-1,PatchF-PatchTable2
	dc.w	CodeG-PatchTable2,(CodeGEnd-CodeG)/2-1,PatchG-PatchTable2
	dc.w	CodeH-PatchTable2,(CodeHEnd-CodeH)/2-1,PatchH-PatchTable2
	dc.w	CodeN-PatchTable2,(CodeNEnd-CodeN)/2-1,PatchN-PatchTable2
	dc.w	CodeO-PatchTable2,(CodeOEnd-CodeO)/2-1,PatchO-PatchTable2
	dc.w	CodeP-PatchTable2,(CodePEnd-CodeP)/2-1,PatchP-PatchTable2
	dc.w	CodeQ-PatchTable2,(CodeQEnd-CodeQ)/2-1,PatchQ-PatchTable2
	dc.w	CodeR-PatchTable2,(CodeREnd-CodeR)/2-1,PatchR-PatchTable2
	dc.w	CodeS-PatchTable2,(CodeSEnd-CodeS)/2-1,PatchS-PatchTable2
	dc.w	CodeT-PatchTable2,(CodeTEnd-CodeT)/2-1,PatchT-PatchTable2
	dc.w	0

; SongEnd (set voice) patch for Jesper Olsen modules (third format)

Code1
	LSL.W	D0,D1
	MOVE.W	D1,$3A(A1)
Code1End
Patch1
	tst.w	$34(A1)
	beq.b	VoiceOff
	move.l	A0,-(SP)
	lea	Songend(PC),A0
	st	(A0,D0.W)
	tst.l	8(A0)	
	bne.b	PtrSet
	move.l	A1,8(A0)
	move.w	$34(A1),12(A0)
PtrSet
	move.l	(SP)+,A0
VoiceOff
	lsl.w	D0,D1
	move.w	D1,$3A(A1)
	rts

; SongEnd (stop) patch for Jesper Olsen modules (third format)

Code2
	MOVE.W	#0,8(A2)
Code2End
Patch2
	move.w	#0,8(A2)
	move.l	D0,-(SP)
	moveq	#0,D0
	bsr.w	SetVol
	move.l	(SP)+,D0
	bsr.w	SongEndTest
	rts

; SongEnd (loop) patch for Jesper Olsen modules (third format)

Code3
	MOVE.W	2(A4),$34(A1)
Code3End
Patch3
	move.w	2(A4),$34(A1)
	bsr.w	SongEndTest
	rts

; Address/length fix/patch for Jesper Olsen modules (third format)

Code4
	MOVE.L	A5,(A2)				; address
	MOVE.W	$12(A3),4(A2)			; length
Code4End
Patch4
	move.l	D0,-(A7)
	move.l	A5,D0
	and.l	#$FFFFFF,D0
	move.l	D0,(A2)
	bsr.w	SetAdr
	move.w	$12(A3),D0
	move.w	D0,4(A2)
	bsr.w	SetLen
	move.l	(A7)+,D0
	rts

; Volume fix/patch for Jesper Olsen modules (third format)

Code5
	MOVE.B	0(A4,D3.W),8(A2)
Code5End
Patch5
	move.l	D0,-(SP)
	move.b	(A4,D3.W),D0
	bsr.w	ChangeVolume
	bsr.w	SetVol
	move.l	(SP)+,D0
	rts

; Period patch for Jesper Olsen modules (third format)

Code6
	SUB.W	$20(A1),D4
	MOVE.W	D4,6(A2)
Code6End
Patch6
	sub.w	$20(A1),D4
	move.w	D4,6(A2)
	move.l	D0,-(SP)
	move.w	D4,D0
	bsr.w	SetPer
	move.l	(SP)+,D0
	rts

; Address/length patch for Jesper Olsen modules (third format)

Code7
	MOVE.L	A4,(A2)
	MOVE.W	$12(A3),4(A2)
Code7End
Patch7
	move.l	A4,(A2)
	move.w	$12(A3),4(A2)
	move.l	D0,-(A7)
	move.l	A4,D0
	bsr.w	SetAdr
	move.w	$12(A3),D0
	bsr.w	SetLen
	move.l	(A7)+,D0
	rts

; Address/length patch for Jesper Olsen modules (third format)

Code8
	MOVE.L	A4,(A2)
	SUBA.L	#$68,A4
	MOVE.W	$1A(A4),D4
	ADD.W	$16(A4),D4
	LSR.W	#1,D4
	MOVE.W	D4,4(A2)
Code8End
Patch8
	move.l	A4,(A2)
	move.l	D0,-(A7)
	move.l	A4,D0
	bsr.w	SetAdr
	sub.w	#$68,A4
	move.w	$1A(A4),D4
	add.w	$16(A4),D4
	lsr.w	#1,D4
	move.w	D4,4(A2)
	move.w	D4,D0
	bsr.w	SetLen
	move.l	(A7)+,D0
	rts

; DMAWait patch for Jesper Olsen modules (third format)

Code9
	MOVE.B	$DFF006,D1
	SUB.B	D0,D1
	CMP.B	1(A1),D1
	BLT.S	lbC0022EA
	ADDI.B	#1,D1
	MOVE.B	D1,1(A1)
lbC0022EA	MOVE.B	(A1),D0
	ADD.B	1(A1),D0
lbC0022F0	CMP.B	$DFF006,D0
	BNE.S	lbC0022F0
Code9End
Patch9
	rts

; DMAWait patch for Jesper Olsen modules (third format)

CodeA
	MOVE.W	D7,$DFF096
CodeAEnd
PatchA
	bsr.w	DMAWait
	move.w	D7,$DFF096
	rts

; Fix for Jesper Olsen modules (third format)

CodeB
	MOVE.L	(A6),D0
	ADD.W	(A0)+,D0
	MOVE.L	D0,$2E(A1)
CodeBEnd
PatchB
	move.l	(A6),A3
	add.w	(A0)+,A3
	move.l	A3,$2E(A1)
	rts

; Period/DMAWait patch for Jesper Olsen modules (second format)

CodeC
	MOVE.W	D5,6(A2)
	MOVE.W	#$8000,D6
CodeCEnd
PatchC
	move.w	D5,6(A2)
	move.l	D0,-(SP)
	move.w	D5,D0
	bsr.w	SetPer
	move.l	(SP)+,D0
	bsr.w	DMAWait
	move.w	#$8000,D6
	rts

; Address/length patch for Jesper Olsen modules (second format)

CodeD
	MOVE.L	D1,(A2)
	MOVE.W	4(A4),4(A2)
CodeDEnd
PatchD
	move.l	D1,(A2)
	move.w	4(A4),4(A2)
	move.l	D0,-(A7)
	move.l	D1,D0
	bsr.w	SetAdr
	move.w	4(A4),D0
	bsr.w	SetLen
	move.l	(A7)+,D0
	rts

; Volume fix/patch for Jesper Olsen modules (second format)

CodeE
	LSR.W	#4,D2
	MOVE.B	D2,8(A2)
CodeEEnd
PatchE
	lsr.w	#4,D2
	move.l	D0,-(SP)
	move.b	D2,D0
	bsr.w	ChangeVolume
	bsr.w	SetVol
	move.l	(SP)+,D0
	rts

; Period patch for Jesper Olsen modules (second format)

CodeF
	SUB.W	14(A1),D3
	MOVE.W	D3,6(A2)
CodeFEnd
PatchF
	sub.w	14(A1),D3
	move.w	D3,6(A2)
	move.l	D0,-(SP)
	move.w	D3,D0
	bsr.w	SetPer
	move.l	(SP)+,D0
	rts

; Address/length patch for Jesper Olsen modules (second format)

CodeG
	MOVE.L	A5,(A2)
	MOVE.W	4(A4),4(A2)
CodeGEnd
PatchG
	move.l	A5,(A2)
	move.w	4(A4),4(A2)
	move.l	D0,-(A7)
	move.l	A5,D0
	bsr.w	SetAdr
	move.w	4(A4),D0
	bsr.w	SetLen
	move.l	(A7)+,D0
	rts

; Volume fix/patch for Jesper Olsen modules (second format)

CodeH
	LSR.W	#5,D2
	MOVE.B	D2,8(A2)
CodeHEnd
PatchH
	lsr.w	#5,D2
	move.l	D0,-(SP)
	move.b	D2,D0
	bsr.w	ChangeVolume
	bsr.w	SetVol
	move.l	(SP)+,D0
	rts

; Address/length patch for Jesper Olsen modules (second format)

CodeI
	MOVE.L	D2,(A2)
	MOVE.W	$10(A3),4(A2)
CodeIEnd
PatchI
	move.l	D2,(A2)
	move.w	$10(A3),4(A2)
	move.l	D0,-(A7)
	move.l	D2,D0
	bsr.w	SetAdr
	move.w	$10(A3),D0
	bsr.w	SetLen
	move.l	(A7)+,D0
	rts

; SongEnd (stop) patch for Jesper Olsen modules (second format)

CodeJ
	CLR.W	4(A1)
	MOVE.W	#0,8(A2)
CodeJEnd
PatchJ
	clr.w	4(A1)
	move.w	#0,8(A2)
	move.l	D0,-(SP)
	moveq	#0,D0
	bsr.w	SetVol
	move.l	(SP)+,D0
	bsr.w	SongEndTest
	rts

; Empty voice fix/patch for Jesper Olsen modules (second format)

CodeK
	ADDA.W	#4,A1
	CMPI.W	#1,(A3)
CodeKEnd
PatchK
	addq.l	#4,A1
	addq.l	#2,(SP)
	rts

; SongEnd (set voice) patch for Jesper Olsen modules (second format)

CodeL
	MOVE.W	(A3),4(A2)
	ADDQ.W	#2,A3
CodeLEnd
PatchL
	tst.w	(A3)
	beq.b	VoiceOff2
	cmp.w	#1,(A3)
	beq.b	VoiceOff2
	move.l	A0,-(SP)
	lea	Songend(PC),A0
	st	(A0,D0.W)
	tst.l	8(A0)	
	bne.b	PtrSet2
	move.l	A2,8(A0)
	move.w	(A3),12(A0)
PtrSet2
	move.l	(SP)+,A0
	move.w	(A3),4(A2)
	bra.b	VoiceOn
VoiceOff2
	clr.w	4(A2)
VoiceOn
	addq.w	#2,A3
	rts

; SongEnd (loop) patch for Jesper Olsen modules (second format)

CodeM
	MOVE.W	2(A4),4(A1)
CodeMEnd
PatchM
	move.w	2(A4),4(A1)
	bsr.w	SongEndTest
	rts

; SongEnd (loop) patch for Jesper Olsen modules (first format)

CodeN
	MOVE.W	2(A4),6(A1)
CodeNEnd
PatchN
	move.w	2(A4),6(A1)
	bsr.w	SongEndTest
	rts

; Address/length patch for Jesper Olsen modules (first format)

CodeO
	MOVE.L	A5,(A2)
	MOVE.W	4(A3),4(A2)
CodeOEnd
PatchO
	move.l	A5,(A2)
	move.w	4(A3),4(A2)
	move.l	D0,-(A7)
	move.l	A5,D0
	bsr.w	SetAdr
	move.w	4(A3),D0
	bsr.w	SetLen
	move.l	(A7)+,D0
	rts

; Period/volume patch/fix for Jesper Olsen modules (first format)

CodeP
	ADD.W	D3,D1
	MOVE.W	D1,6(A2)
	SUB.B	$1D(A1),D2
	MOVE.B	D2,8(A2)
CodePEnd
PatchP
	add.w	D3,D1
	move.w	D1,6(A2)
	sub.b	$1D(A1),D2
	move.l	D0,-(SP)
	move.w	D1,D0
	bsr.w	SetPer
	move.b	D2,D0
	bsr.w	ChangeVolume
	bsr.w	SetVol
	move.l	(SP)+,D0
	rts

; Address/length patch for Jesper Olsen modules (first format)

CodeQ
	MOVE.L	$36(A1),(A2)
	MOVE.W	$3A(A1),4(A2)
CodeQEnd
PatchQ
	move.l	$36(A1),(A2)
	move.w	$3A(A1),4(A2)
	move.l	D0,-(A7)
	move.l	$36(A1),D0
	bsr.w	SetAdr
	move.w	$3A(A1),D0
	bsr.w	SetLen
	move.l	(A7)+,D0
	rts

; Volume patch/fix for Jesper Olsen modules (first format)

CodeR
	LSR.W	#5,D0
	MOVE.B	D0,8(A2)
CodeREnd
PatchR
	lsr.w	#5,D0
	bsr.w	ChangeVolume
	bsr.w	SetVol
	rts

; Period patch for Jesper Olsen modules (first format)

CodeS
	SUB.W	$2C(A1),D3
	MOVE.W	D3,6(A2)
CodeSEnd
PatchS
	sub.w	$2C(A1),D3
	move.w	D3,6(A2)
	move.l	D0,-(SP)
	move.w	D3,D0
	bsr.w	SetPer
	move.l	(SP)+,D0
	rts

; Period/volume patch/fix for Jesper Olsen modules (first format)

CodeT
	LSR.W	#4,D0
	MOVE.B	D0,8(A2)
CodeTEnd
PatchT
	move.l	D0,-(SP)
	move.w	D1,D0
	bsr.w	SetPer
	move.l	(SP)+,D0
	lsr.w	#4,D0
	bsr.w	ChangeVolume
	bsr.w	SetVol
	rts

; Bugfix for Jesper Olsen module (24th hiphop)

CodeU
	MOVE.W	#0,8(A1)
	ADDQ.W	#2,A4
	dc.w	$6052
CodeUEnd
PatchU
	move.w	#0,8(A1)
	addq.w	#2,A4
	move.l	D7,A3
	add.w	(A1),A3
	add.l	#$52+4,(SP)
	rts

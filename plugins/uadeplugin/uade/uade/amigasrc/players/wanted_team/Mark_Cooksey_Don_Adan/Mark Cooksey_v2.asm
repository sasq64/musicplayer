	*****************************************************
	****    Mark Cooksey replayer for EaglePlayer	 ****
	****        all adaptions by Wanted Team,	 ****
	****     DeliTracker 2.32 compatible version	 ****
	*****************************************************

	incdir	"dh2:include/"
	include 'misc/eagleplayer2.01.i'
	include	'hardware/custom.i'

	SECTION	Player,CODE

	PLAYERHEADER Tags

	dc.b	'$VER: Mark Cooksey player module V1.1 (13 Dec 2006)',0
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
	dc.b	'Mark Cooksey',0
Creator
	dc.b	'(c) 1988-90 by Mark Cooksey & Richard',10
	dc.b	'Frankish, adapted by Wanted Team',0
Prefix
	dc.b	'MC.',0
OldPrefix
	dc.b	'MCR.',0
	even
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
DataPtr
	dc.l	0
SampleInfoPtr
	dc.l	0
SamplesPtr
	dc.l	0
Songend
	dc.l	'WTWT'
FirstStep
	dc.l	0
CurrentPos
	dc.l	0
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
	tst.b	CurrentFormat
	bpl.b	NoPos
	move.l	CurrentPos(PC),D0
	beq.b	NoPos
	sub.l	FirstStep(PC),D0
	lsr.l	#2,D0
NoPos
	rts

***************************************************************************
******************************* EP_SampleInit *****************************
***************************************************************************

SampleInit
	moveq	#EPR_NotEnoughMem,D7
	lea	EPG_SampleInfoStructure(A5),A3
	move.l	SampleInfoPtr(PC),D0
	beq.b	return
	move.l	D0,A0

	move.l	InfoBuffer+Samples(PC),D5
	beq.b	return
	subq.l	#1,D5
	tst.b	CurrentFormat
	beq.b	NewSamp
	bpl.w	ThirdSamp

	move.l	A0,A1
hop
	jsr	ENPP_AllocSampleStruct(A5)
	move.l	D0,(A3)
	beq.b	return
	move.l	D0,A3

	move.l	(A0)+,D1
	lea	0(A1,D1.L),A2
	moveq	#0,D1
	move.w	(A2),D1
	lsl.l	#1,D1
	move.l	A2,EPS_Adr(A3)			; sample address
	move.l	D1,EPS_Length(A3)		; sample length
	move.l	#64,EPS_Volume(A3)
	move.w	#USITY_RAW,EPS_Type(A3)
	move.w	#USIB_Playable!USIB_Saveable!USIB_8BIT,EPS_Flags(A3)
SkipInfo
	dbf	D5,hop
backsamp
	moveq	#0,D7
return
	move.l	D7,D0
	rts

NewSamp
hop2
	jsr	ENPP_AllocSampleStruct(A5)
	move.l	D0,(A3)
	beq.b	return
	move.l	D0,A3

	move.l	SamplesPtr(PC),A1
	move.w	(A0),D1
	lea	0(A0,D1.W),A2
	move.l	(A2),D2
	bne.b	AdrOK
	addq.l	#2,A2
	move.l	2(A2),D2
AdrOK
	moveq	#0,D1
	move.w	16(A2),D1
	lsl.l	#1,D1
	add.l	D2,A1
	move.l	A1,EPS_Adr(A3)			; sample address
	move.l	D1,EPS_Length(A3)		; sample length
	move.l	#64,EPS_Volume(A3)
	move.w	#USITY_RAW,EPS_Type(A3)
	move.w	#USIB_Playable!USIB_Saveable!USIB_8BIT,EPS_Flags(A3)
	addq.l	#2,A0
	dbf	D5,hop2
	bra.b	backsamp

ThirdSamp
	move.l	A0,A1
hop3
	jsr	ENPP_AllocSampleStruct(A5)
	move.l	D0,(A3)
	beq.b	return
	move.l	D0,A3

	move.w	(A1),D1
	lea	(A0,D1.W),A2
	moveq	#0,D1
	move.w	2(A1),D1
	add.l	D1,D1
	move.l	A2,EPS_Adr(A3)			; sample address
	move.l	D1,EPS_Length(A3)		; sample length
	move.l	#64,EPS_Volume(A3)
	move.w	#USITY_RAW,EPS_Type(A3)
	move.w	#USIB_Playable!USIB_Saveable!USIB_8BIT,EPS_Flags(A3)
	addq.l	#8,A1
	dbf	D5,hop3
	bra.w	backsamp

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
	bsr.s	CopyName
	movea.l	dtg_LoadFile(A5),A0
	jmp	(A0)

NoExt
	moveq	#0,D0
	rts
CopyName
	movea.l	dtg_PathArrayPtr(A5),A0
loop
	tst.b	(A0)+
	bne.s	loop
	subq.l	#1,A0
	movea.l	A0,A3
	movea.l	dtg_FileArrayPtr(A5),A1
smp
	move.b	(A1)+,(A0)+
	bne.s	smp

	cmpi.b	#'M',(A3)
	beq.b	M_OK
	cmpi.b	#'m',(A3)
	bne.s	ExtError
M_OK
	cmpi.b	#'C',1(A3)
	beq.b	C_OK
	cmpi.b	#'c',1(A3)
	bne.s	ExtError
C_OK
	cmpi.b	#'R',2(A3)
	beq.b	R_OK
	cmpi.b	#'r',2(A3)
	bne.s	ExtError
R_OK
	cmpi.b	#'.',3(A3)
	bne.s	ExtError

	addq.l	#2,A3
	move.b	#'S',(A3)

	bra.b	ExtOK
ExtError
	clr.b	-2(A0)
ExtOK
	clr.b	-1(A0)
	rts

***************************************************************************
**************************** EP_ModuleChange ******************************
***************************************************************************

ModuleChange
	move.w	Change(PC),D0
	bne.s	NoChange
	move.l	ModulePtr(PC),EPG_ARG1(A5)

	cmp.b	#1,CurrentFormat
	bne.b	No1
	lea	PatchTable2(PC),A1
	move.l	#800,D1
	bra.b	RightPatch
No1
	lea	PatchTable(PC),A1
	move.l	#2500,D1
	tst.b	CurrentFormat
	beq.b	RightPatch
	lea	PatchTable1(PC),A1
	move.l	ModulePtr(PC),A0
	addq.l	#2,A0
	move.l	(A0),D1
RightPatch
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
	move.l	A4,D2
	cmp.w	#$F000,D2
	beq.s	Left1
	cmp.w	#$F010,D2
	beq.s	Right1
	cmp.w	#$F020,D2
	beq.s	Right2
	cmp.w	#$F030,D2
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
	move.w	D0,$A8(A4)
Exit2
	move.l	(A7)+,D2
	rts

*------------------------------- Set Vol -------------------------------*

SetVol
	move.l	A0,-(A7)
	lea	StructAdr+UPS_Voice1Vol(PC),A0
	cmp.l	#$DFF000,A4
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice2Vol(PC),A0
	cmp.l	#$DFF010,A4
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice3Vol(PC),A0
	cmp.l	#$DFF020,A4
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice4Vol(PC),A0
.SetVoice
	move.w	D0,(A0)
	move.l	(A7)+,A0
	rts

*------------------------------- Set Adr -------------------------------*

SetAdr
	move.l	a0,-(a7)
	lea	StructAdr+UPS_Voice1Adr(pc),a0
	cmp.l	#$dff000,a4
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice2Adr(pc),a0
	cmp.l	#$dff010,a4
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice3Adr(pc),a0
	cmp.l	#$dff020,a4
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice4Adr(pc),a0
.SetVoice
	move.l	D0,(a0)
	move.l	(a7)+,a0
	rts

*------------------------------- Set Len -------------------------------*

SetLen
	move.l	a0,-(a7)
	lea	StructAdr+UPS_Voice1Len(pc),a0
	cmp.l	#$dff000,a4
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice2Len(pc),a0
	cmp.l	#$dff010,a4
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice3Len(pc),a0
	cmp.l	#$dff020,a4
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice4Len(pc),a0
.SetVoice
	move.w	D0,(a0)
	move.l	(a7)+,a0
	rts

*------------------------------- Set Per -------------------------------*

SetPer
	move.l	a0,-(a7)
	lea	StructAdr+UPS_Voice1Per(pc),a0
	cmp.l	#$dff000,a4
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice2Per(pc),a0
	cmp.l	#$dff010,a4
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice3Per(pc),a0
	cmp.l	#$dff020,a4
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice4Per(pc),a0
.SetVoice
	move.w	d0,(a0)
	move.l	(a7)+,a0
	rts

ChangeVolume2
	move.l	D1,-(A7)
	and.w	#$7F,D4
	move.l	A5,D1
	cmp.w	#$F0A0,D1
	beq.s	Left13
	cmp.w	#$F0B0,D1
	beq.s	Right13
	cmp.w	#$F0C0,D1
	beq.s	Right23
	cmp.w	#$F0D0,D1
	bne.s	Exit23
Left23
	mulu.w	LeftVolume(PC),D4
	and.w	Voice4(PC),D4
	bra.s	Ex3
Left13
	mulu.w	LeftVolume(PC),D4
	and.w	Voice1(PC),D4
	bra.s	Ex3

Right13
	mulu.w	RightVolume(PC),D4
	and.w	Voice2(PC),D4
	bra.s	Ex3
Right23
	mulu.w	RightVolume(PC),D4
	and.w	Voice3(PC),D4
Ex3
	lsr.w	#6,D4
	MOVE.W	D4,8(A5)
Exit23
	move.l	(A7)+,D1
	rts

*------------------------------- Set Vol -------------------------------*

SetVol2
	move.l	A0,-(A7)
	lea	StructAdr+UPS_Voice1Vol(PC),A0
	cmp.l	#$DFF0A0,A5
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice2Vol(PC),A0
	cmp.l	#$DFF0B0,A5
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice3Vol(PC),A0
	cmp.l	#$DFF0C0,A5
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice4Vol(PC),A0
.SetVoice
	move.w	D4,(A0)
	move.l	(A7)+,A0
	rts

*------------------------------- Set Adr -------------------------------*

SetAdr2
	move.l	a0,-(a7)
	lea	StructAdr+UPS_Voice1Adr(pc),a0
	cmp.l	#$dff0A0,A5
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice2Adr(pc),a0
	cmp.l	#$dff0B0,A5
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice3Adr(pc),a0
	cmp.l	#$dff0C0,A5
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice4Adr(pc),a0
.SetVoice
	move.l	A4,(A0)
	move.l	(a7)+,a0
	rts

*------------------------------- Set Len -------------------------------*

SetLen2
	move.l	a0,-(a7)
	lea	StructAdr+UPS_Voice1Len(pc),a0
	cmp.l	#$dff0A0,A5
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice2Len(pc),a0
	cmp.l	#$dff0B0,A5
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice3Len(pc),a0
	cmp.l	#$dff0C0,A5
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice4Len(pc),a0
.SetVoice
	move.w	D4,(a0)
	move.l	(a7)+,a0
	rts

*------------------------------- Set Per -------------------------------*

SetPer2
	move.l	a0,-(a7)
	lea	StructAdr+UPS_Voice1Per(pc),a0
	cmp.l	#$dff0A0,A5
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice2Per(pc),a0
	cmp.l	#$dff0B0,A5
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice3Per(pc),a0
	cmp.l	#$dff0C0,A5
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice4Per(pc),a0
.SetVoice
	move.w	D4,(A0)
	move.l	(a7)+,a0
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

	lea	Format(PC),A1
	cmp.l	#$D040D040,(A0)
	bne.b	NextCheck
	cmp.w	#$4EFB,4(A0)
	bne.b	fail
	move.w	#$6000,D1
	cmp.w	8(A0),D1
	bne.b	fail
	cmp.w	12(A0),D1
	bne.b	fail
	cmp.w	16(A0),D1
	bne.b	fail
	cmp.w	20(A0),D1
	bne.b	fail
	cmp.w	#$43FA,40(A0)
	beq.b	Old
	cmp.w	24(A0),D1
	bne.b	fail
	cmp.w	#$43FA,150(A0)
	bne.b	fail
Old
	clr.b	(A1)
Older
	moveq	#0,D0
fail
	rts

NextCheck
	cmp.w	#$601A,(A0)
	bne.b	Third
	addq.l	#2,A0
	move.l	(A0)+,D1
	bmi.b	fail
	btst	#0,D1
	bne.b	fail
	tst.w	(A0)+
	bne.b	fail
	moveq	#4,D2
ZeroCheck
	tst.l	(A0)+
	bne.b	fail
	dbf	D2,ZeroCheck
	lea	2(A0),A2
	moveq	#3,D2
BranchCheck
	cmp.w	#$6000,(A0)+
	bne.b	fail
	move.w	(A0)+,D1
	bmi.b	fail
	btst	#0,D1
	bne.b	fail
	dbf	D2,BranchCheck
	add.w	(A2),A2
	cmp.l	#$48E780F0,(A2)
	bne.b	fail

	st	(A1)
	bra.b	Older

Third
	moveq	#1,D2
BranchCheck2
	cmp.w	#$6000,(A0)+
	bne.b	fail2
	move.w	(A0)+,D1
	bmi.b	fail2
	btst	#0,D1
	bne.b	fail2
	dbf	D2,BranchCheck2
	cmp.w	#$4DFA,(A0)+
	bne.b	fail2
	addq.l	#2,A0
	cmp.w	#$4A56,(A0)
	beq.b	Later
	cmp.w	#$4A16,(A0)
	bne.b	fail2
Later
	addq.l	#6,A0
	cmp.w	#$41F9,(A0)+
	bne.b	fail2
	cmp.l	#$DFF000,(A0)+
	bne.b	fail2
	move.b	#1,(A1)
	moveq	#0,D0
fail2
	rts

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
Prefixes	=	60

InfoBuffer
	dc.l	MI_SubSongs,0		;4
	dc.l	MI_LoadSize,0		;12
	dc.l	MI_Songsize,0		;20
	dc.l	MI_SamplesSize,0	;28
	dc.l	MI_Samples,0		;36
	dc.l	MI_Calcsize,0		;44
	dc.l	MI_Length,0		;52
	dc.l	MI_Prefix,0		;60
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

	move.l	ModulePtr(PC),A0	; module buffer
	tst.b	CurrentFormat
	beq.b	PlayNew
	bmi.b	PlayOld	
	jsr	8(A0)			; play module
	bra.b	SkipPlay
PlayOld
	jsr	36(A0)			; play module
	bra.b	SkipPlay
PlayNew
	moveq	#0,D0
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

SongEnd
	movem.l	A1/A5,-(A7)
	bra.b	EndOK

SongEndTest
	movem.l	A1/A5,-(A7)
	lea	Songend(PC),A1
	cmp.l	#$DFF0A0,A5
	bne.b	test1
	clr.b	(A1)
	bra.b	test
test1
	cmp.l	#$DFF0B0,A5
	bne.b	test2
	clr.b	1(A1)
	bra.b	test
test2
	cmp.l	#$DFF0C0,A5
	bne.b	test3
	clr.b	2(A1)
	bra.b	test
test3
	cmp.l	#$DFF0D0,A5
	bne.b	test
	clr.b	3(A1)
test
	tst.l	(A1)
	bne.b	SkipEnd
	move.l	#'WTWT',(A1)
EndOK
	move.l	EagleBase(PC),A5
	move.l	dtg_SongEnd(A5),A1
	jsr	(A1)
SkipEnd
	movem.l	(A7)+,A1/A5
	rts

SongEndTest2
	movem.l	A1/A5,-(A7)
	lea	Songend(PC),A1
	cmp.l	#$DFF000,A4
	bne.b	test12
	clr.b	(A1)
	bra.b	test21
test12
	cmp.l	#$DFF010,A4
	bne.b	test22
	clr.b	1(A1)
	bra.b	test21
test22
	cmp.l	#$DFF020,A4
	bne.b	test32
	clr.b	2(A1)
	bra.b	test21
test32
	cmp.l	#$DFF030,A4
	bne.b	test21
	clr.b	3(A1)
test21
	tst.l	(A1)
	bne.b	SkipEnd2
	move.l	#'WTWT',(A1)
	move.l	EagleBase(PC),A5
	move.l	dtg_SongEnd(A5),A1
	jsr	(A1)
SkipEnd2
	movem.l	(A7)+,A1/A5
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
	lea	ModulePtr(PC),A6
	move.l	A0,(A6)+			; module buffer
	move.b	(A6)+,(A6)+			; Current Format
	clr.w	(A6)+				; Change
	move.l	A5,(A6)+			; EagleBase

	lea	InfoBuffer(PC),A4
	move.l	D0,LoadSize(A4)

	move.l	A0,A1
	cmp.w	#$6000,(A1)
	beq.w	Troi
	cmp.w	#$601A,(A1)+
	beq.w	FirstFormat
	cmp.w	#$6000,24(A0)
	bne.b	Skip
	jsr	8(A0)				; init module
Skip
	cmp.w	#$43FA,(A1)+
	bne.b	Skip
	move.l	A1,A2
	add.w	(A1),A1
FindIt2
	cmp.w	#$43FA,(A2)+
	bne.b	FindIt2
	move.l	A2,A3
	add.w	(A2),A2
	move.l	A2,D1
	sub.l	A1,D1
	lsr.l	#4,D1
	move.l	D1,SubSongs(A4)
FindIt5
	cmp.l	#$000041FA,(A3)
	beq.b	OK_3
	addq.l	#2,A3
	bra.b	FindIt5
OK_3
	addq.l	#4,A3
	move.l	A3,A2
	add.w	(A3),A3
	clr.l	(A6)+				; DataPtr
	move.l	A3,(A6)+			; SampleInfoPtr
	move.w	(A3),D1
	lsr.l	#1,D1
	move.l	D1,Samples(A4)
FindIt6
	cmp.w	#$43FA,(A2)+
	bne.b	FindIt6
	add.w	(A2),A2
	move.l	A2,(A6)				; SamplesPtr
	subq.l	#1,D1
	moveq	#0,D4
	moveq	#0,D5
FindMax
	move.w	(A3),D0
	lea	0(A3,D0.W),A1
	addq.l	#2,A3
	move.l	(A1),D3
	bne.b	FirstAdr
	addq.l	#2,A1
	move.l	2(A1),D3
FirstAdr
	cmp.l	D3,D4
	bge.b	NoMax
	move.l	D3,D4
NoMax
	moveq	#0,D6
	move.w	16(A1),D6
	lsl.l	#1,D6
	add.l	D3,D6
	cmp.l	D6,D5
	bge.b	NotThis
	move.l	D6,D5
NotThis
	dbf	D1,FindMax
	move.l	A2,A3
	add.l	D4,A3
	moveq	#$40,D2
	add.l	D2,A2
	sub.l	A0,A2
	move.l	A2,SongSize(A4)
	tst.w	-6(A3)
	bne.b	BadSize
	add.l	-6(A3),A3
	sub.l	A0,A3
	move.l	A3,CalcSize(A4)
	sub.l	A2,A3
	move.l	A3,SamplesSize(A4)
	bra.b	SkipSize
BadSize
	sub.l	D2,D5
	move.l	D5,SamplesSize(A4)
	add.l	D5,A2
	move.l	A2,CalcSize(A4)
SkipSize
	clr.l	Length(A4)
	lea	Prefix(PC),A0
Back
	move.l	A0,Prefixes(A4)

	bsr.w	ModuleChange

	tst.b	CurrentFormat
	bpl.b	OneFile

	moveq	#1,D0
	movea.l	dtg_GetListData(A5),A0
	jsr	(A0)

	move.l	A0,(A6)+			; DataPtr
	add.l	D0,LoadSize(A4)

	cmp.w	#$601A,(A0)+
	beq.b	HeaderOK
	moveq	#EPR_CorruptModule,D0		; error message
	rts
HeaderOK
	move.l	D2,D3
	moveq	#28,D1
	add.l	D1,D3
	add.l	(A0)+,D1
	cmp.l	D1,D0
	bge.s	SizeOK
	bra.b	Error
SizeOK
	add.l	D1,D2
	moveq	#22,D1
	add.l	D1,A0
	moveq	#-8,D1
	add.l	8(A0),D1
	lsr.l	#4,D1
	move.l	D1,SubSongs(A4)			; D1 = subsongs
	move.l	D2,CalcSize(A4)
	move.l	4(A0),D1
	add.l	D1,A0
	move.l	A0,(A6)				; SampleInfoPtr
	add.l	D1,D3
	move.l	(A0),D1
	add.l	D1,D3
	lsr.l	#2,D1
	move.l	D1,Samples(A4)
	move.l	D3,SongSize(A4)
	sub.l	D3,D2
	move.l	D2,SamplesSize(A4)

OneFile
	movea.l	dtg_AudioAlloc(A5),A0
	jmp	(A0)

FirstFormat
	moveq	#28,D2
	add.l	(A1),D2
	cmp.l	D2,D0
	bge.s	ReplayerOKi
Error
	moveq	#EPR_ModuleTooShort,D0		; error message
	rts
ReplayerOKi
	cmp.l	#$38280002,(A1)
	beq.b	FoundBeg
	addq.l	#2,A1
	bra.b	ReplayerOKi
FoundBeg
	move.w	#$4EF9,(A1)+
	lea	PatchOld(PC),A2
	move.l	A2,(A1)+

ReplayerOK
	cmp.w	#$009C,(A1)+
	beq.b	CheckIt
	bra.b	ReplayerOK
CheckIt
	cmp.w	#$316A,(A1)
	bne.b	ReplayerOK
	addq.l	#2,A1
	move.w	(A1),ChangeIt1+2-PatchOld(A2)		; DMA
	move.w	(A1),ChangeIt2+2-PatchOld(A2)
FindIt1
	cmp.w	#$3B6A,(A1)+
	bne.b	FindIt1
	move.w	(A1),ChangeIt3+2-PatchOld(A2)		; volume
	move.w	-14(A1),ChangeIt4+2-PatchOld(A2)	; address
FindIt3
	cmp.w	#$290B,(A1)+
	bne.b	FindIt3
	subq.l	#4,A1
	move.w	(A1),ChangeIt7+2-PatchOld(A2)
	move.w	(A1),ChangeIt8+2-PatchOld(A2)
	move.w	(A1),ChangeIt9+2-PatchOld(A2)
	move.w	(A1),ChangeItA+2-PatchOld(A2)
	move.w	(A1),ChangeItB+2-PatchOld(A2)
	move.w	(A1),ChangeItC+2-PatchOld(A2)

FindIt4
	cmp.w	#$78FF,(A1)+
	bne.b	FindIt4
	addq.l	#2,A1
	move.w	(A1),ChangeIt5+2-PatchOld(A2)
	move.w	(A1),ChangeIt6+2-PatchOld(A2)

FindIt7
	cmp.w	#$254B,(A1)+
	bne.b	FindIt7
	move.w	(A1),ChangeItD+2-PatchOld(A2)

	lea	OldPrefix(PC),A0
	bra.w	Back

Troi
	cmp.l	#$161449FA,(A1)
	beq.b	TOK
	cmp.w	#$7402,(A1)
	bne.b	No3
	addq.w	#1,(A1)				; 4th voice on
No3
	addq.l	#2,A1
	bra.b	Troi
TOK
	addq.l	#4,A1
	add.w	(A1),A1
	moveq	#0,D1
	move.w	(A1),D1
	clr.l	(A6)+
	move.l	A1,(A6)+			; SamplesInfoPtr
	move.l	D1,D2
	lsr.l	#3,D1
	move.l	D1,Samples(A4)
	add.w	D2,A1
	move.w	-6(A1),D1
	add.l	D1,D1
	sub.l	D2,D1
	move.w	-8(A1),D2
	add.l	D2,D1
	move.l	D1,SamplesSize(A4)
	sub.l	A0,A1
	move.l	A1,SongSize(A4)
	add.l	D1,A1
	move.l	A1,CalcSize(A4)
	move.l	A0,A2
	addq.l	#2,A0
	add.w	(A0),A0
	move.l	A0,A1
	move.l	A0,(A6)				; Init at SamplesPtr
FindT
	cmp.w	#$45FA,(A0)+
	bne.b	FindT
	moveq	#1,D0
	cmp.w	#$C0FC,2(A0)
	bne.b	OnlyOne
	add.w	(A0),A0
	move.w	8(A0),D0
	divu.w	#10,D0
OnlyOne
	move.l	D0,SubSongs(A4)
FindT1
	cmp.w	#$A6,-(A1)
	bne.b	FindT1
	move.w	-(A1),Base
FindT2
	cmp.w	#$4000,-(A1)
	bne.b	FindT2
	lea	Patch(PC),A0
	move.l	A0,(A1)
	subq.l	#2,A1
	move.w	#$4EF9,(A1)
	move.l	A2,D1
	move.w	#$4EF9,(A2)+
	lea	PatchVol(PC),A0
	move.l	A0,(A2)+
FindV
	cmp.l	#$334300A8,(A2)
	beq.b	VolF
	addq.l	#2,A2
	bra.b	FindV
VolF
	move.w	#$6100,(A2)+
	sub.l	A2,D1
	move.w	D1,(A2)
	bra.w	SkipSize
Base
	dc.w	0
Patch
	move.w	D0,$96(A0)
	move.w	Base(PC),D7
	movem.l	A3/A4,-(SP)
	move.l	A1,A4
	lea	(A2,D7.W),A3
	move.w	D0,D7
	move.l	4(A3),$A0(A1)
	move.w	8(A3),$A4(A1)
	move.w	(A3),$A6(A1)
;	move.w	2(A3),$A8(A1)
	move.l	4(A3),D0
	bsr.w	SetAdr
	move.w	8(A3),D0
	bsr.w	SetLen
	move.w	(A3),D0
	bsr.w	SetPer
	move.w	2(A3),D0
	bsr.w	ChangeVolume
	bsr.w	SetVol
	bsr.w	DMAWait
	move.w	D7,D0
	bset	#15,D0
	move.w	D0,$96(A0)
	bclr	#15,D0
	bsr.w	DMAWait
	move.l	10(A3),$A0(A1)
	move.w	14(A3),$A4(A1)
	movem.l	(SP)+,A3/A4
	rts

PatchVol
	movem.l	D0/A4,-(SP)
	move.w	D3,D0
	move.l	A1,A4
	bsr.w	ChangeVolume
	bsr.w	SetVol
	movem.l	(SP)+,D0/A4
	rts

PatchOld
ChangeIt1
	move.w	6(A2),$96(A0)			; DMA off
ChangeIt4
	move.l	10(A2),A4
	move.w	(A4)+,D4
	move.l	A4,(A5)				; address
	bsr.w	SetAdr2
	move.w	D4,4(A5)			; length
	bsr.w	SetLen2
ChangeIt3
;	move.w	$12(A2),8(A5)			; volume
	move.w	$12(A2),D4
	bsr.w	ChangeVolume2
	bsr.w	SetVol2
	move.w	(SP)+,D4
	move.w	D4,6(A5)			; period
	bsr.w	SetPer2
	bsr.w	DMAWait
ChangeIt2
	move.w	6(A2),D4
	or.w	#$8000,D4
	move.w	D4,$96(A0)			; DMA On
	bsr.w	DMAWait
	lea	Buffy,A4
	move.l	A4,(A5)				; address
	move.w	#2,4(A5)			; length
ChangeItD
	move.l	A3,2(A2)
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
	lea	Songend(PC),A3
	move.l	#'WTWT',(A3)+
	moveq	#0,D0
	move.w	dtg_SndNum(A5),D0
	move.l	ModulePtr(PC),A1
	tst.b	CurrentFormat
	beq.b	NewFormat
	bpl.b	ThirdFormat
	move.l	DataPtr(PC),A0
	lea	28(A0),A0
	move.l	A0,A2
	move.l	D0,D1
	lsl.l	#4,D1
	lea	8(A2,D1.W),A4
	move.l	4(A4),D1
	sub.l	(A4),D1
	add.l	(A4),A2
	move.l	A2,(A3)+			; FirstStep
	clr.l	(A3)				; CurrentPos
	lsr.l	#2,D1
	lea	InfoBuffer(PC),A2
	move.l	D1,Length(A2)
	jmp	28(A1)
NewFormat
	swap	D0
	move.w	#1,D0
	jmp	(A1)
ThirdFormat
	move.l	SamplesPtr(PC),A0
	jmp	(A0)

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

	*--------------- PatchTable for Mark Cooksey ------------------*

PatchTable
	dc.w	Code1-PatchTable,(Code1End-Code1)/2-1,Patch1-PatchTable
	dc.w	Code2-PatchTable,(Code2End-Code2)/2-1,Patch2-PatchTable
	dc.w	Code3-PatchTable,(Code3End-Code3)/2-1,Patch1-PatchTable
	dc.w	Code4-PatchTable,(Code4End-Code4)/2-1,Patch2-PatchTable
	dc.w	Code5-PatchTable,(Code5End-Code5)/2-1,Patch5-PatchTable
	dc.w	Code6-PatchTable,(Code6End-Code6)/2-1,Patch6-PatchTable
	dc.w	Code7-PatchTable,(Code7End-Code7)/2-1,Patch7-PatchTable
	dc.w	Code8-PatchTable,(Code8End-Code8)/2-1,Patch8-PatchTable
	dc.w	Code9-PatchTable,(Code9End-Code9)/2-1,Patch9-PatchTable
	dc.w	CodeA-PatchTable,(CodeAEnd-CodeA)/2-1,PatchA-PatchTable
	dc.w	CodeB-PatchTable,(CodeBEnd-CodeB)/2-1,PatchB-PatchTable
	dc.w	CodeC-PatchTable,(CodeCEnd-CodeC)/2-1,PatchC-PatchTable
	dc.w	CodeD-PatchTable,(CodeDEnd-CodeD)/2-1,PatchD-PatchTable
	dc.w	CodeO-PatchTable,(CodeOEnd-CodeO)/2-1,PatchO-PatchTable
	dc.w	CodeP-PatchTable,(CodePEnd-CodeP)/2-1,PatchP-PatchTable
	dc.w	0
PatchTable1
	dc.w	CodeH-PatchTable1,(CodeHEnd-CodeH)/2-1,PatchH-PatchTable1
	dc.w	CodeI-PatchTable1,(CodeIEnd-CodeI)/2-1,PatchI-PatchTable1
	dc.w	CodeJ-PatchTable1,(CodeJEnd-CodeJ)/2-1,PatchJ-PatchTable1
	dc.w	CodeK-PatchTable1,(CodeKEnd-CodeK)/2-1,PatchK-PatchTable1
	dc.w	CodeL-PatchTable1,(CodeLEnd-CodeL)/2-1,PatchL-PatchTable1
	dc.w	CodeM-PatchTable1,(CodeMEnd-CodeM)/2-1,PatchM-PatchTable1
	dc.w	CodeN-PatchTable1,(CodeNEnd-CodeN)/2-1,PatchN-PatchTable1
	dc.w	0

PatchTable2
	dc.w	CodeZ-PatchTable2,(CodeZEnd-CodeZ)/2-1,PatchZ-PatchTable2
	dc.w	0

; Volume patch (D2 register) for Mark Cooksey modules from 1989

Code1
	lsr.w	#2,D2
	tst.b	0(A3)
	dc.w	$6704
	move.w	D2,$A8(A4)
Code1End
Patch1
	lsr.w	#1,D2
	tst.b	(A3)
	beq.b	SkipVol2
	cmp.w	#$40,D2
	bls.b	VolD2_OK
	moveq	#$40,D2
VolD2_OK
	move.l	D0,-(SP)
	move.l	D2,D0
	bsr.w	ChangeVolume
	bsr.w	SetVol
	move.l	(SP)+,D0
SkipVol2
	rts

; Volume patch (D0 register) for Mark Cooksey modules from 1989

Code2
	lsr.w	#2,D0
	tst.b	0(A3)
	dc.w	$6704
	move.w	D0,$A8(A4)
Code2End
Patch2
	lsr.w	#1,D0
	tst.b	(A3)
	beq.b	SkipVol
	cmp.w	#$40,D0
	bls.b	VolD0_OK
	moveq	#$40,D0
VolD0_OK
	bsr.w	ChangeVolume
	bsr.w	SetVol
SkipVol
	rts

; Volume patch (D2 register) for Mark Cooksey modules from 1990

Code3
	dc.l	$4A2B0000
	dc.l	$671EC4EB
	dc.l	$2E04A
	dc.l	$5242B47C
	dc.l	$1006504
	dc.l	$74406008
Code3End
Patch3							; used patch 1

; Volume patch (D0 register) for Mark Cooksey modules from 1990

Code4
	dc.l	$4A2B0000
	dc.l	$671EC0EB
	dc.l	$2E048
	dc.l	$5240B07C
	dc.l	$1006504
	dc.l	$70406008
Code4End
Patch4							; used patch 2

; Period patch for Mark Cooksey modules from 1989/1990

Code5
	swap	D0
	move.w	D0,$A6(A4)
Code5End
Patch5
	swap	D0
	move.w	D0,$A6(A4)
	bsr.w	SetPer
	rts

; Address and length patch for Mark Cooksey modules from 1989/1990

Code6
	move.w	$10(A5),$A4(A4)
	move.l	D1,$A0(A4)
Code6End
Patch6
	move.w	$10(A5),$A4(A4)
	move.l	D0,-(A7)
	move.w	$10(A5),D0
	bsr.w	SetLen
	move.l	D1,$A0(A4)
	move.l	D1,D0
	bsr.w	SetAdr
	move.l	(A7)+,D0
	rts

; Address and length patch for Mark Cooksey modules from 1989/1990

Code7
	move.l	D0,$A0(A4)
	move.w	14(A5),$A4(A4)
Code7End
Patch7
	move.l	D0,$A0(A4)
	bsr.w	SetAdr
	move.w	14(A5),$A4(A4)
	move.l	D0,-(A7)
	move.w	14(A5),D0
	bsr.w	SetLen
	move.l	(A7)+,D0
	rts

; Period patch & fix for Mark Cooksey modules from 1989/1990

Code8
	move.w	D2,$A6(A4)
	bset	#15,D3
	move.w	D4,$9C(A2)
	move.w	D3,$96(A2)
	move.w	D4,$9C(A2)
Wait
	move.w	$1E(A2),D1
	and.w	D4,D1
	beq.b	Wait
Code8End
Patch8
	move.w	D2,$A6(A4)
	move.l	D0,-(A7)
	move.w	D2,D0
	bsr.w	SetPer
	move.l	(A7)+,D0
	move.b	vhposr(A2),d1
.WaitLine2
	cmp.b	vhposr(A2),d1			; sync routine to start at linestart
	beq.s	.WaitLine2
.WaitDMA2
	cmp.b	#$16,vhposr+1(A2)		; wait til after Audio DMA slots
	bcs.s	.WaitDMA2
.StartDMA
	move.w	dmaconr(A2),d0			; get active channels
	not.w	d0
	and.w	d3,d0
	move.w	d0,d1
	or.w	#$8000,d1
	lsl.w	#7,d0
	move.w	d0,intreq(A2)			; clear requests
	move.w	d1,dmacon(A2)			; start channels
.WaitStart
	move.w	intreqr(A2),d1			; wait until all channels are running
	and.w	d0,d1
	cmp.w	d0,d1
	bne.s	.WaitStart

	move.b	vhposr(A2),d1
.WaitLine3
	cmp.b	vhposr(A2),d1			; sync routine to start at linestart
	beq.s	.WaitLine3
.WaitDMA3
	cmp.b	#$16,vhposr+1(A2)		; wait til after Audio DMA slots
	bcs.s	.WaitDMA3
	rts

; Address, length and period patch for Mark Cooksey modules from 1989/1990

Code9
	move.l	10(A5),$A0(A4)
	move.w	$10(A5),$A4(A4)
	move.w	D2,$A6(A4)
Code9End
Patch9
	move.l	10(A5),$A0(A4)
	move.l	D0,-(A7)
	move.l	10(A5),D0
	bsr.w	SetAdr
	move.w	$10(A5),$A4(A4)
	move.w	$10(A5),D0
	bsr.w	SetLen
	move.w	D2,$A6(A4)
	move.w	D2,D0
	bsr.w	SetPer
	move.l	(A7)+,D0
	rts

; Volume patch (D2 register) for Mark Cooksey modules from 1990

CodeA
	move.b	0(A0,D2.W),D2
	move.w	D2,$A8(A4)
CodeAEnd
PatchA
	rts

; Volume patch (D0 register) for Mark Cooksey modules from 1990

CodeB
	move.b	0(A0,D0.W),D0
	move.w	D0,$A8(A4)
CodeBEnd
PatchB
	rts

; SongEnd patch for Mark Cooksey modules from 1989-90

CodeC
	MOVEQ	#$7F,D1
	AND.B	D0,D1
	SUBI.B	#$60,D1
CodeCEnd
PatchC
	cmp.b	#$68,D0				; song loop
	beq.b	TestEnd
NoLoop
	cmp.b	#$67,D0				; song stop
	bne.b	SkipLoop
TestEnd
	bsr.w	SongEndTest2
SkipLoop
	moveq	#$7F,D1
	and.b	D0,D1
	subi.b	#$60,D1
	rts

; Fix for Mark Cooksey modules from 1989-90

CodeD
	move.w	#$4000,$9A(A2)
	move.w	D3,$96(A2)
	move.w	#1,$A6(A4)
	clr.w	D4
	addq.w	#7,D1
	bset	D1,D4
	move.w	D4,$9C(A2)
CodeDEnd
PatchD
	move.b	vhposr(A2),d1
.WaitLine1
	cmp.b	vhposr(A2),d1			; sync routine to start at linestart
	beq.s	.WaitLine1
.WaitDMA1
	cmp.b	#$16,vhposr+1(A2)		; wait til after Audio DMA slots
	bcs.s	.WaitDMA1

	move.w	#1,aud0+ac_per(A4)		; max. speed
	move.w	dmaconr(A2),d4			; get active channels
	and.w	d3,d4
	move.w	d4,d1
	lsl.w	#7,d4
	move.w	d4,intreq(A2)			; clear requests
	move.w	d1,dmacon(A2)			; stop channels
.WaitStop
	move.w	intreqr(A2),d1			; wait until all channels are stopped
	and.w	d4,d1
	cmp.w	d4,d1
	bne.s	.WaitStop
.Skip
	rts

; Fix (2x) for Mark Cooksey modules from 1989-90

CodeO
	clr.w	$AA(A4)
WaitO
	move.w	$1E(A2),D1
	and.w	D4,D1
	beq.b	WaitO
	move.w	D4,$9C(A2)
CodeOEnd
PatchO
	rts

; Fix (2x) for Mark Cooksey modules from 1989-90

CodeP
	move.w	#$C000,$9A(A2)
CodePEnd
PatchP
	rts

; Volume patch for Mark Cooksey modules from 1988

CodeH
	TST.W	0(A2)
	BNE.S	lbC0006F8
	MOVE.W	D4,8(A5)
lbC0006F8
CodeHEnd
PatchH
	bsr.w	ChangeVolume2
	bsr.w	SetVol2
	rts

; Volume patch for Mark Cooksey modules from 1988

CodeI
	ADD.W	D4,D4
	MOVE.W	D4,8(A5)
CodeIEnd
PatchI
	add.w	D4,D4
	bsr.w	ChangeVolume2
	bsr.w	SetVol2
	rts

; Period patch for Mark Cooksey modules from 1988

CodeJ
	TST.W	0(A2)
	BNE.S	lbC0006CE
	MOVE.W	(A4),6(A5)
lbC0006CE
CodeJEnd
PatchJ
	move.w	(A4),6(A5)
	move.l	D4,-(SP)
	move.w	(A4),D4
	bsr.w	SetPer2
	move.l	(SP)+,D4
	rts

; Bug & period patch for Mark Cooksey modules from 1988

CodeK
	ADDA.W	D4,A4
	MOVE.L	(A4),6(A5)
CodeKEnd
PatchK
	add.w	D4,A4
	move.w	(A4),6(A5)
	move.l	D4,-(SP)
	move.w	(A4),D4
	bsr.w	SetPer2
	move.l	(SP)+,D4
	rts

; SongEnd (stop) patch for Mark Cooksey modules from 1988

CodeL
	MOVEQ	#-1,D4
ChangeIt5
	MOVE.W	D4,$62(A2)
CodeLEnd
PatchL
	moveq	#-1,D4
ChangeIt6
	move.w	D4,$62(A2)
	bsr.w	SongEndTest
	rts

; SongEnd (loop) patch for Mark Cooksey modules from 1988

CodeM
ChangeIt7
	MOVEA.L	$78(A2),A4
	MOVEA.L	(A4),A3
CodeMEnd
PatchM
ChangeIt8
	move.l	$78(A2),A4
	move.l	(A4),A3
	bsr.w	SongEndTest
	rts

; Position Counter patch for Mark Cooksey modules from 1988

CodeN
ChangeIt9
	MOVEA.L	$16(A2),A4
	MOVE.L	A3,-(A4)
ChangeItA
	MOVE.L	A4,$16(A2)
CodeNEnd
PatchN
ChangeItB
	move.l	$16(A2),A4
	move.l	A3,-(A4)
ChangeItC
	move.l	A4,$16(A2)
	cmp.l	#$DFF0A0,A5
	bne.b	NoPosit
	move.l	A3,CurrentPos
NoPosit
	rts

; SongEnd patch for third type of Mark Cooksey modules

CodeZ
	SUBI.B	#$80,D3
	EXT.W	D3
CodeZEnd
PatchZ
	cmp.b	#$80,D3				; song stop
	bne.b	NoStop
	bsr.w	SongEnd
	bra.b	SkipLoop2
NoStop
	cmp.b	#$82,D3				; song loop
	bne.b	SkipLoop2
TestEnd2
	move.l	A4,-(SP)
	move.l	A1,A4
	bsr.w	SongEndTest2
	move.l	(SP)+,A4
SkipLoop2
	sub.b	#$80,D3
	ext.w	D3
	rts

	Section	Buffy,BSS_C
Buffy	
	ds.b	4

	******************************************************
	****   Kris Hatlelid replayer for EaglePlayer,    ****
	****         all adaptions by Wanted Team	  ****
	****     DeliTracker 2.32 compatible version	  ****
	******************************************************

	incdir	"dh2:include/"
	include 'misc/eagleplayer2.01.i'
	include 'hardware/intbits.i'
	include 'exec/exec_lib.i'
	include	'dos/dos_lib.i'

	SECTION	Player,CODE

	PLAYERHEADER Tags

	dc.b	'$VER: Kris Hatlelid player module V1.0 (6 Nov 2001)',0
	even
Tags
	dc.l	DTP_PlayerVersion,1
	dc.l	EP_PlayerVersion,9
	dc.l	DTP_RequestDTVersion,'WT'
	dc.l	DTP_PlayerName,PlayerName
	dc.l	DTP_Creator,Creator
	dc.l	DTP_Check1,Check1
	dc.l	EP_Check3,Check3
	dc.l	DTP_Interrupt,Interrupt
	dc.l	DTP_SubSongRange,SubSongRange
	dc.l	DTP_InitPlayer,InitPlayer
	dc.l	DTP_EndPlayer,EndPlayer
	dc.l	DTP_InitSound,InitSound
	dc.l	DTP_EndSound,EndSound
	dc.l	EP_Get_ModuleInfo,GetInfos
	dc.l	EP_ModuleChange,ModuleChange
	dc.l	EP_GetPositionNr,GetPosition
	dc.l	DTP_Volume,SetVolume
	dc.l	DTP_Balance,SetBalance
	dc.l	EP_Voices,SetVoices
	dc.l	EP_StructInit,StructInit
	dc.l	EP_SampleInit,SampleInit
	dc.l	EP_Flags,EPB_Volume!EPB_Balance!EPB_ModuleInfo!EPB_Voices!EPB_SampleInfo!EPB_Songend!EPB_Analyzer!EPB_NextSong!EPB_PrevSong!EPB_Restart
	dc.l	DTP_DeliBase,DeliBase
	dc.l	EP_EagleBase,Eagle2Base
	dc.l	TAG_DONE
PlayerName
	dc.b	'Kris Hatlelid',0
Creator
	dc.b	'(c) 1989-91 by Kris Hatlelid,',10
	dc.b	'adapted by Wanted Team',0
Prefix
	dc.b	'KH.',0
EPlayerName
	dc.b	'songplay',0
	even
DeliBase
	dc.l	0
Eagle2Base
	dc.l	0
ModulePtr
	dc.l	0
EagleBase
	dc.l	0
TwoFilesFlags
	dc.w	0
DataPtr
	dc.l	0
SongsPtr
	dc.l	0
SpeedPtr
	dc.l	0
InitPtr
	dc.l	0
PlayPtr
	dc.l	0
Track0Info
	dc.l	0
VoicesPtr
	dc.l	0
Change
	dc.w	0
Stack
	dc.l	0
FirstVoice
	dc.l	0
Songend
	dc.l	0
SamplesPtr
	dc.l	0
RightVolume
	dc.w	64
LeftVolume
	dc.w	64
Voice1
	dc.w	1
Voice2
	dc.w	1
Voice3
	dc.w	1
Voice4
	dc.w	1
OldVoice1
	dc.w	0
OldVoice2
	dc.w	0
OldVoice3
	dc.w	0
OldVoice4
	dc.w	0
StructAdr
	ds.b	UPS_SizeOF

***************************************************************************
***************************** EP_GetPositionNr ****************************
***************************************************************************

GetPosition
	move.l	Track0Info(PC),A0
	move.l	10(A0),D0
	divu.w	#6,D0
	rts

***************************************************************************
******************************* EP_SampleInit *****************************
***************************************************************************

SampleInit
	moveq	#EPR_NotEnoughMem,D7
	lea	EPG_SampleInfoStructure(A5),A3
	move.l	SamplesPtr(PC),D0
	beq.b	return
	move.l	D0,A2

	move.l	InfoBuffer+Samples(PC),D5
	beq.b	return
	subq.l	#1,D5
hop
	jsr	ENPP_AllocSampleStruct(A5)
	move.l	D0,(A3)
	beq.b	return
	move.l	D0,A3

	move.l	A2,EPS_Adr(A3)			; sample address
	moveq	#8,D1
	cmp.l	#'NAME',40(A2)
	bne.b	NoName
	lea	46(A2),A1
	move.w	(A1)+,EPS_MaxNameLen(A3)
	move.l	A1,EPS_SampleName(A3)		; sample name
NoName
	addq.l	#4,A2
	add.l	(A2),D1
	add.l	(A2)+,A2
	move.l	D1,EPS_Length(A3)		; sample length
	move.l	#64,EPS_Volume(A3)
	move.w	#USITY_RAW,EPS_Type(A3)
	move.w	#USIB_Playable!USIB_Saveable!USIB_8BIT,EPS_Flags(A3)
	dbf	D5,hop

	moveq	#0,D7
return
	move.l	D7,D0
	rts

***************************************************************************
**************************** EP_ModuleChange ******************************
***************************************************************************

ModuleChange
	move.w	Change(PC),D0
	bne.s	NoChange
	move.l	ModulePtr(PC),EPG_ARG1(A5)
	lea	PatchTable(PC),A1
	move.l	A1,EPG_ARG3(A5)
	move.l	#2600,D1
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
************************* DTP_Volume, DTP_Balance *************************
***************************************************************************
; Copy Volume and Balance Data to internal buffer

SetVolume
SetBalance
	move.w	dtg_SndLBal(A5),D0
	mulu.w	dtg_SndVol(A5),D0
	lsr.w	#6,D0				; durch 64
	move.w	D0,LeftVolume

	move.w	dtg_SndRBal(A5),D0
	mulu.w	dtg_SndVol(A5),D0
	lsr.w	#6,D0				; durch 64
	move.w	D0,RightVolume			; Right Volume

	lea	OldVoice1(PC),A2
	moveq	#3,D1
	lea	$DFF0A8,A6
SetNew
	move.w	(A2)+,D0
	bsr.b	ChangeVolume
	addq.l	#8,A6
	addq.l	#8,A6
	dbf	D1,SetNew
	rts

ChangeVolume
	and.w	#$7F,D0
	cmpa.l	#$DFF0A8,A6			;Left Volume
	bne.b	NoVoice1
	move.w	D0,OldVoice1
	tst.w	Voice1
	bne.b	Voice1On
	moveq	#0,D0
Voice1On
	mulu.w	LeftVolume(PC),D0
	bra.b	SetIt
NoVoice1
	cmpa.l	#$DFF0B8,A6			;Right Volume
	bne.b	NoVoice2
	move.w	D0,OldVoice2
	tst.w	Voice2
	bne.b	Voice2On
	moveq	#0,D0
Voice2On
	mulu.w	RightVolume(PC),D0
	bra.b	SetIt
NoVoice2
	cmpa.l	#$DFF0C8,A6			;Right Volume
	bne.b	NoVoice3
	move.w	D0,OldVoice3
	tst.w	Voice3
	bne.b	Voice3On
	moveq	#0,D0
Voice3On
	mulu.w	RightVolume(PC),D0
	bra.b	SetIt
NoVoice3
	move.w	D0,OldVoice4
	tst.w	Voice4
	bne.b	Voice4On
	moveq	#0,D0
Voice4On
	mulu.w	LeftVolume(PC),D0
SetIt
	lsr.w	#6,D0
	move.w	D0,(A6)
	rts

*------------------------------- Set Vol -------------------------------*

SetVol
	move.l	A2,-(A7)
	lea	StructAdr+UPS_Voice1Vol(PC),A2
	cmp.l	#$DFF0A8,A6
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice2Vol(PC),A2
	cmp.l	#$DFF0B8,A6
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice3Vol(PC),A2
	cmp.l	#$DFF0C8,A6
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice4Vol(PC),A2
.SetVoice
	move.w	D0,(A2)
	move.l	(A7)+,A2
	rts

*------------------------------- Set Adr -------------------------------*

SetAdr
	move.l	A2,-(A7)
	lea	StructAdr+UPS_Voice1Adr(PC),A2
	cmp.l	#$DFF0A0,A6
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice2Adr(PC),A2
	cmp.l	#$DFF0B0,A6
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice3Adr(PC),A2
	cmp.l	#$DFF0C0,A6
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice4Adr(PC),A2
.SetVoice
	move.l	A0,(A2)
	move.l	(A7)+,A2
	rts

*------------------------------- Set Len -------------------------------*

SetLen
	move.l	A0,-(A7)
	lea	StructAdr+UPS_Voice1Len(PC),A0
	cmp.l	#$DFF0A4,A6
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice2Len(PC),A0
	cmp.l	#$DFF0B4,A6
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice3Len(PC),A0
	cmp.l	#$DFF0C4,A6
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
	cmp.l	#$DFF0A6,A6
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice2Per(PC),A0
	cmp.l	#$DFF0B6,A6
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice3Per(PC),A0
	cmp.l	#$DFF0C6,A6
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice4Per(PC),A0
.SetVoice
	move.w	D2,(A0)
	move.l	(A7)+,A0
	rts

***************************************************************************
**************************** EP_Voices ************************************
***************************************************************************

SetVoices
	lea	Voice1(PC),A0
	lea	StructAdr(PC),A1
	moveq	#1,D1
	move.w	D1,(A0)+			Voice1=0 setzen
	btst	#0,D0
	bne.b	No_Voice1
	clr.w	-2(A0)
	clr.w	$DFF0A8
	clr.w	UPS_Voice1Vol(A1)
No_Voice1
	move.w	D1,(A0)+			Voice2=0 setzen
	btst	#1,D0
	bne.b	No_Voice2
	clr.w	-2(A0)
	clr.w	$DFF0B8
	clr.w	UPS_Voice2Vol(A1)
No_Voice2
	move.w	D1,(A0)+			Voice3=0 setzen
	btst	#2,D0
	bne.b	No_Voice3
	clr.w	-2(A0)
	clr.w	$DFF0C8
	clr.w	UPS_Voice3Vol(A1)
No_Voice3
	move.w	D1,(A0)+			Voice4=0 setzen
	btst	#3,D0
	bne.b	No_Voice4
	clr.w	-2(A0)
	clr.w	$DFF0D8
	clr.w	UPS_Voice4Vol(A1)
No_Voice4
	move.w	D0,UPS_DMACon(A1)	;Stimme an = Bit gesetzt
					;Bit 0 = Kanal 1 usw.
	moveq	#0,D0
	rts

***************************************************************************
******************************* EP_StructInit *****************************
***************************************************************************

StructInit
	lea	StructAdr(PC),A0
	rts

***************************************************************************
******************************** DTP_Check1 *******************************
***************************************************************************

Check1
	move.l	Eagle2Base(PC),D0
	bne.b	fail
	move.l	DeliBase(PC),D0
	beq.b	fail

***************************************************************************
******************************** EP_Check3 ********************************
***************************************************************************

Check3
	movea.l	dtg_ChkData(A5),A0

	cmp.l	#$000003F3,(A0)+
	bne.b	fail
	tst.l	(A0)+
	bne.b	fail
	cmp.l	#$00000003,(A0)+
	bne.b	fail
	tst.l	(A0)+
	bne.b	fail
	cmp.l	#$00000002,(A0)+
	bne.b	fail
	move.l	(A0)+,D1
	bclr	#30,D1
	cmp.b	#$40,(A0)
	bne.b	fail
	addq.l	#4,A0
	cmp.l	#$00000001,(A0)+
	bne.b	fail
	cmp.l	#$000003E9,(A0)+
	bne.b	fail
	cmp.l	(A0)+,D1
	bne.b	fail
	lea	TwoFilesFlags(PC),A1
	cmp.l	#$60000016,(A0)+
	bne.b	Trzy
	cmp.l	#$0000ABCD,(A0)+
	bne.b	fail
	cmp.l	#$B07C0000,16(A0)
	bne.b	Dwa
	clr.b	(A1)
	bra.b	Found
fail
	moveq	#-1,D0
	rts
Trzy
	lea	-20(A0),A0
Dwa
	cmp.l	#$41F90000,16(A0)
	bne.b	fail
	cmp.l	#$00004E75,20(A0)
	bne.b	fail
	st	(A1)
Found
	moveq	#0,D0
	rts

***************************************************************************
***************************** EP_Get_ModuleInfo ***************************
***************************************************************************

GetInfos
	lea	InfoBuffer(PC),A0
	rts

SubSongs	=	4
SamplesSize	=	12
Length		=	20
Samples		=	28

InfoBuffer
	dc.l	MI_SubSongs,0		;4
	dc.l	MI_SamplesSize,0	;12
	dc.l	MI_Length,0		;20
	dc.l	MI_Samples,0		;28
	dc.l	MI_Prefix,Prefix
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

	move.l	Track0Info(PC),A0
	tst.w	(A0)
	bne.b	Play
	lea	74(A0),A0
	tst.w	(A0)
	bne.b	Play
	lea	74(A0),A0
	tst.w	(A0)
	bne.b	Play
	lea	74(A0),A0
	tst.w	(A0)
	bne.b	Play
	move.l	EagleBase(PC),A5
	move.l	dtg_SongEnd(A5),A1
	jsr	(A1)

Play
	move.l	PlayPtr(PC),A0
	jsr	(A0)			; play module

	lea	StructAdr(PC),A0
	clr.w	UPS_Enabled(A0)

	movem.l	(SP)+,D1-D7/A0-A6
	moveq	#0,D0
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
IntAddress
	dc.l	0
IntName
	dc.b	'Kris Hatlelid Audio Interrupt',0,0
	even

SongEnd
	movem.l	A1/A5,-(A7)
	move.l	EagleBase(PC),A5
	move.l	dtg_SongEnd(A5),A1
	jsr	(A1)
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

FindSamp
	cmp.l	#'FORM',(A0)
	beq.b	SampFound
	addq.l	#2,A0
	bra.b	FindSamp
SampFound
	moveq	#0,D0
	move.l	A0,A1
FindNext
	cmp.l	#'FORM',(A0)
	bne.b	NoSamp
	addq.l	#1,D0
	addq.l	#4,A0
	add.l	(A0)+,A0
	bra.b	FindNext
NoSamp
	sub.l	A1,A0
	lea	InfoBuffer(PC),A2
	move.l	D0,Samples(A2)
	move.l	A0,SamplesSize(A2)

	move.l	dtg_DOSBase(A5),A6
	move.l	dtg_PathArrayPtr(A5),D1
	jsr	_LVOLoadSeg(A6)
	lsl.l	#2,D0
	beq.b	InitFail
	addq.l	#4,D0

	move.l	D0,A0				; module address
	lea	ModulePtr(PC),A4
	move.l	D0,(A4)+
	move.l	A5,(A4)+			; EagleBase
	move.b	(A4)+,(A4)			; copy flag
	tst.b	(A4)+
	beq.b	OneFile
	clr.l	(A4)				; DataPtr
	move.l	dtg_PathArrayPtr(A5),A0
	clr.b	(A0)
	move.l	dtg_CopyDir(A5),A0
	jsr	(A0)
	movea.l	dtg_PathArrayPtr(A5),A0
loop1
	tst.b	(A0)+
	bne.s	loop1
	subq.l	#1,A0
	lea	EPlayerName(PC),A3
smp2
	move.b	(A3)+,(A0)+
	bne.s	smp2
	move.l	dtg_PathArrayPtr(A5),D1
	jsr	_LVOLoadSeg(A6)
	lsl.l	#2,D0
	beq.b	ExtFail
	addq.l	#4,D0
	move.l	ModulePtr(PC),A0
	move.l	D0,ModulePtr
	move.l	A0,(A4)+			; DataPtr
	jsr	(A0)
	move.l	A0,(A4)+			; SongsPtr

	move.l	A0,A1

	bsr.b	FindSamp2

	moveq	#0,D1
	move.l	(A0),A1
CheckSub
	tst.l	(A0)+
	beq.b	LastSub
	addq.l	#1,D1
	cmp.l	A0,A1
	beq.b	LastSub
	bra.b	CheckSub
LastSub
	move.l	D0,A0
	bra.b	SkipOne

FindSamp2
	cmp.l	#'FORM',(A1)
	beq.b	SampFound2
	addq.l	#2,A1
	bra.b	FindSamp2
SampFound2
	move.l	A1,SamplesPtr
	rts

InitFail
	moveq	#EPR_NotEnoughMem,D0
	rts
ExtFail
	moveq	#EPR_ErrorExtLoad,D0
	rts

OneFile
	clr.l	(A4)+				; DataPtr
	clr.l	(A4)+				; SongsPtr
	moveq	#1,D1
SkipOne
	move.l	A0,A1
	move.l	D1,SubSongs(A2)

FindSpeed
	cmp.l	#$00DE6700,(A1)
	beq.b	SpeedFound
	addq.l	#2,A1
	bra.b	FindSpeed
SpeedFound
	addq.l	#4,A1
	move.l	A1,A3
	add.w	(A1),A3
	move.l	A3,(A4)+			; SpeedPtr

FindVol
	cmp.l	#$302B001E,(A1)
	beq.b	VolFound
	addq.l	#2,A1
	bra.b	FindVol
VolFound
	move.l	6(A1),ChangeIt

FindRTE
	cmp.w	#$4E73,(A1)+
	bne.b	FindRTE
	move.w	#$4E75,-2(A1)

FindZero
	cmp.l	#$B07C0000,(A0)
	beq.b	ZeroFound
	addq.l	#2,A0
	bra.b	FindZero
ZeroFound
	addq.l	#6,A0
	add.w	(A0),A0
	addq.l	#2,A0
	move.l	A0,(A4)+			; InitPtr

FindLea
	cmp.w	#$43F9,(A0)+
	bne.b	FindLea
	move.w	#$4E75,-2(A0)

FindLea2
	cmp.w	#$43FA,(A0)+
	bne.b	FindLea2
	move.l	A0,A1
	add.w	(A0),A1
	move.l	A1,(A4)+			; PlayPtr

FindLea3
	cmp.w	#$43FA,(A0)+
	bne.b	FindLea3
	add.w	(A0),A0

	move.l	A0,IntAddress

FindLea4
	cmp.w	#$41F9,(A0)+
	bne.b	FindLea4
	move.l	(A0),(A4)+			; Track0Info

	tst.b	TwoFilesFlags+1
	beq.b	OldFormat
	clr.l	(A4)+
	bra.b	ChangeFlag
OldFormat
	move.l	ModulePtr(PC),A0
FindOne
	cmp.l	#$B07C0001,(A0)
	beq.b	OneFound
	addq.l	#2,A0
	bra.b	FindOne
OneFound
	addq.l	#6,A0
	add.w	(A0),A0

FindLea5
	cmp.w	#$41F9,(A0)+
	bne.b	FindLea5
	move.l	(A0),(A4)+			; VoicesPtr
	move.l	(A0),A1
	bsr.w	FindSamp2

ChangeFlag
	clr.w	(A4)				; ChangeFlag

	bsr.w	ModuleChange

	movea.l	dtg_AudioAlloc(A5),A0
	jmp	(A0)

***************************************************************************
***************************** DTP_EndPlayer *******************************
***************************************************************************

EndPlayer
	move.l	dtg_DOSBase(A5),A6
	move.l	ModulePtr(PC),D1
	subq.l	#4,D1
	lsr.l	#2,D1
	jsr	_LVOUnLoadSeg(A6)
	move.l	DataPtr(PC),D1
	beq.b	NoData
	subq.l	#4,D1
	lsr.l	#2,D1
	jsr	_LVOUnLoadSeg(A6)
NoData
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

	lea	OldVoice1(PC),A0
	clr.l	(A0)+
	clr.l	(A0)
	move.w	#$3700,dtg_Timer(A5)

	lea	Songend(PC),A0
	move.l	#'WTWT',(A0)
	move.l	InitPtr(PC),A0
	jsr	(A0)
	move.w	dtg_SndNum(A5),D1
	move.l	SongsPtr(PC),D2
	moveq	#1,D0				; ReadInstruments
	move.l	ModulePtr(PC),A0
	jsr	(A0)

	moveq	#2,D0				; PlaySong
	move.l	ModulePtr(PC),A0
	jsr	(A0)

	tst.b	TwoFilesFlags+1
	bne.b	SkipNextTrack

	lea	Track0Info(PC),A0
	move.l	(A0)+,A1
	moveq	#3,D1
NextTrack
	move.w	#$FFFF,(A1)
	clr.w	58(A1)
	move.l	(A0),$3C(A1)
	lea	74(A1),A1
	dbf	D1,NextTrack
	move.l	(A0),A0
	lea	-16(A0),A0
	bra.b	SkipIt
SkipNextTrack
	move.l	FirstVoice(PC),A0
SkipIt
	move.l	4(A0),D0
	sub.l	(A0),D0
	divu.w	#6,D0
	lea	InfoBuffer(PC),A2
	move.l	D0,Length(A2)

	move.l	(A0),A0
	move.l	(A0),A0

	cmp.b	#$DE,(A0)
	beq.b	NewSpeed

	cmp.b	#$DC,(A0)
	bne.b	Normal
	addq.l	#2,A0
Normal
	cmp.b	#$DD,(A0)+
	bne.b	SkipNew
	move.b	(A0)+,D0
	lsl.l	#8,D0
	cmp.b	#$DE,(A0)+
	bne.b	NoSecond
	move.b	(A0)+,D0
NoSecond
	move.w	D0,dtg_Timer(A5)
	bra.b	SkipNew
NewSpeed
	moveq	#0,D2
	move.b	1(A0),D2
	move.l	A7,Stack

	move.l	SpeedPtr(PC),A0
	jsr	(A0)
Back
	lea	Stack(PC),A0
	move.l	(A0),A7
	clr.l	(A0)
SkipNew
	bra.w	SetAudioVector

***************************************************************************
***************************** DTP_EndSound ********************************
***************************************************************************

EndSound
	bsr.w	ClearAudioVector
	lea	$DFF000,A0
	move.w	#15,$96(A0)
	clr.w	$A8(A0)
	clr.w	$B8(A0)
	clr.w	$C8(A0)
	clr.w	$D8(A0)
	rts

*--------------------- PatchTable for Kris Hatlelid ----------------------*

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

; Audio Interrupt fix for Kris Hatlelid modules

Code0
	MOVE.L	$24(A0),(A1)
	MOVE.W	#$FFFF,$12(A0)
Code0End
	dc.l	0				; safety buffer (?)
Patch0
	move.l	$24(A0),(A1)
	move.w	#$FFFF,$12(A0)
	move.w	D3,$DFF09A
	rts

; Timer patch for Kris Hatlelid modules

Code1
	MOVE.B	D2,$BFE501
	MOVE.B	#$10,$BFEE01
	MOVE.B	#1,$BFEE01
Code1End
Patch1
	movem.l	A1/A5,-(SP)
	move.l	EagleBase(PC),A5
	move.b	D2,dtg_Timer(A5)
	move.l	dtg_SetTimer(A5),A1
	jsr	(A1)
	movem.l	(SP)+,A1/A5
	tst.l	Stack
	bne.w	Back
	rts

; Timer patch for Kris Hatlelid modules

Code2
	MOVE.B	D2,$BFE401
	MOVE.B	#$10,$BFEE01
	MOVE.B	#1,$BFEE01
Code2End
Patch2
	movem.l	A1/A5,-(SP)
	move.l	EagleBase(PC),A5
	move.b	D2,dtg_Timer+1(A5)
	move.l	dtg_SetTimer(A5),A1
	jsr	(A1)
	movem.l	(SP)+,A1/A5
	rts

; Initialization fix for Kris Hatlelid modules

Code3
	ADDA.L	#$10,A0
Code3End
Patch3
	move.l	A0,FirstVoice
	lea	$10(A0),A0
	move.l	Track0Info(PC),A3
	moveq	#3,D0
NextTrackNew
	move.w	#$FFFF,(A3)
	clr.w	58(A3)
	move.l	(A0),$3C(A3)
	lea	74(A3),A3
	dbf	D0,NextTrackNew
	rts

; SongEnd patch for Kris Hatlelid modules

Code4
	MOVE.W	#$780,$DFF09A
	MOVE.W	#$780,$DFF01E
Code4End
Patch4
	bsr.w	SongEnd
	rts

; SongEnd patch for Kris Hatlelid modules

Code5
	CLR.L	10(A3)
	MOVEA.L	2(A3),A0
Code5End
Patch5
	clr.l	10(A3)
	move.l	2(A3),A0
SongEndTest
	movem.l	A0/A5,-(A7)
	lea	Songend(PC),A0
	cmp.l	#$DFF0A8,40(A3)
	bne.b	test1
	clr.b	(A0)
	bra.b	test
test1
	cmp.l	#$DFF0B8,40(A3)
	bne.b	test2
	clr.b	1(A0)
	bra.b	test
test2
	cmp.l	#$DFF0C8,40(A3)
	bne.b	test3
	clr.b	2(A0)
	bra.b	test
test3
	cmp.l	#$DFF0D8,40(A3)
	bne.b	test
	clr.b	3(A0)
test
	tst.l	(A0)
	bne.b	SkipEnd
	move.l	#'WTWT',(A0)				; SongEnd
	move.l	EagleBase(PC),A5
	move.l	dtg_SongEnd(A5),A0
	jsr	(A0)
SkipEnd
	movem.l	(A7)+,A0/A5
	rts

; Volume patch for Kris Hatlelid modules

Code6
	dc.w	$302B
	dc.w	$1E
	dc.w	$4A79
ChangeIt
	dc.l	'WTWT'
	dc.w	$6604
	dc.w	$3C80
Code6End
Patch6
	move.w	$1E(A3),D0
	lsl.w	#1,D0
	cmp.w	#64,D0
	ble.b	VolLow1
	moveq	#64,D0
VolLow1
	bsr.w	ChangeVolume
	bsr.w	SetVol
	rts

; Volume patch for Kris Hatlelid modules

Code7
	MOVEA.L	$28(A3),A6
	MOVE.W	D2,(A6)
Code7End
Patch7
	move.l	$28(A3),A6
	move.l	D0,-(SP)
	move.w	D2,D0
	lsl.w	#1,D0
	cmp.w	#64,D0
	ble.b	VolLow2
	moveq	#64,D0
VolLow2
	bsr.w	ChangeVolume
	bsr.w	SetVol
	move.l	(SP)+,D0
	rts

; Address patch for Kris Hatlelid modules

Code8
	MOVEA.L	$30(A3),A6
	MOVE.L	A0,(A6)
Code8End
Patch8
	move.l	$30(A3),A6
	move.l	A0,(A6)
	bsr.w	SetAdr
	rts

; Length patch for Kris Hatlelid modules

Code9
	MOVEA.L	$34(A3),A6
	MOVE.W	D2,(A6)
Code9End
Patch9
	move.l	$34(A3),A6
	move.w	D2,(A6)
	bsr.w	SetLen
	rts

; Period patch for Kris Hatlelid modules

CodeA
	MOVEA.L	$2C(A3),A6
	MOVE.W	D2,(A6)
CodeAEnd
PatchA
	move.l	$2C(A3),A6
	move.w	D2,(A6)
	bsr.w	SetPer
	rts

; Period patch for Kris Hatlelid modules

CodeB
	MOVEA.L	$2C(A3),A6
	MOVE.W	D1,(A6)
CodeBEnd
PatchB
	move.l	$2C(A3),A6
	move.w	D1,(A6)
	move.l	D2,-(SP)
	move.w	D1,D2
	bsr.w	SetPer
	move.l	(SP)+,D2
	rts

; Volume patch for Kris Hatlelid modules

CodeC
	MOVEA.L	$28(A3),A6
	CLR.W	(A6)
CodeCEnd
PatchC
	move.l	$28(A3),A6
	move.l	D0,-(SP)
	moveq	#0,D0
	bsr.w	ChangeVolume
	bsr.w	SetVol
	move.l	(SP)+,D0
	rts

; Audio Interrupt fix for Kris Hatlelid modules

CodeD
	MOVE.W	$DFF01E,D0
CodeDEnd
PatchD
	move.b	$DFF006,d0
.line	cmp.b	$DFF006,d0
	beq.s	.line
.wait	cmp.b	#$16,$DFF007
	bcs.b	.wait
	move.w	$DFF01C,D0
	and.w	$DFF01E,D0
	rts

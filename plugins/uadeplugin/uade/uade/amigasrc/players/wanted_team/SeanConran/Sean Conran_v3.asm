	*****************************************************
	****    Sean Conran replayer for EaglePlayer	 ****
	****        all adaptions by Wanted Team,	 ****
	****     DeliTracker 2.32 compatible version	 ****
	*****************************************************

	incdir	"dh2:include/"
	include "misc/eagleplayer2.01.i"
	include 'hardware/intbits.i'
	include 'exec/exec_lib.i'
	include	'dos/dos_lib.i'

	SECTION	Player,CODE

	PLAYERHEADER Tags

	dc.b	'$VER: Sean Conran player module V1.2 (10 Nov 2003)',0
	even
Tags
	dc.l	DTP_PlayerVersion,3
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
	dc.l	EP_Get_ModuleInfo,GetInfos
	dc.l	EP_ModuleChange,ModuleChange
	dc.l	DTP_Volume,SetVolume
	dc.l	DTP_Balance,SetBalance
	dc.l	EP_Voices,SetVoices
	dc.l	EP_StructInit,StructInit
	dc.l	EP_GetPositionNr,GetPosition
	dc.l	EP_Flags,EPB_Songend!EPB_Volume!EPB_Balance!EPB_Voices!EPB_Analyzer!EPB_ModuleInfo
	dc.l	0

PlayerName
	dc.b	'Sean Conran',0
Creator
	dc.b	'(c) 1989-91 by Sean Conran,',10
	dc.b	'adapted by Mr.Larmer/Wanted Team',0
Prefix
	dc.b	'SCR.',0
	even
ModulePtr
	dc.l	0
InitPtr
	dc.l	0
SongsPtr
	dc.l	0
PlayPtr
	dc.l	0
Change
	dc.w	0
EagleBase
	dc.l	0
FirstPos
	dc.l	0
CurrentPos
	dc.l	0
Twin
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
	move.l	CurrentPos(PC),D0
	sub.l	FirstPos(PC),D0
	bpl.b	PosOk
	moveq	#0,D0
PosOk
	rts

***************************************************************************
**************************** EP_ModuleChange ******************************
***************************************************************************

ModuleChange
	move.w	Change(PC),D0
	bne.s	NoChange
	move.l	PlayPtr(PC),EPG_ARG1(A5)
	lea	PatchTable(PC),A1
	move.l	#2200,D1
	move.l	ModulePtr(PC),A0
	cmp.w	#$0FFF,(A0)
	bne.b	New
	lea	PatchTable2(PC),A1
	sub.w	#200,D1
New
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

Left2
	mulu.w	LeftVolume(PC),D6
	and.w	Voice4(PC),D6
	bra.s	Ex
Left1
	mulu.w	LeftVolume(PC),D6
	and.w	Voice1(PC),D6
	bra.s	Ex

Right1
	mulu.w	RightVolume(PC),D6
	and.w	Voice2(PC),D6
	bra.s	Ex
Right2
	mulu.w	RightVolume(PC),D6
	and.w	Voice3(PC),D6
Ex
	lsr.w	#6,D6
	rts

Left22
	mulu.w	LeftVolume(PC),D4
	and.w	Voice4(PC),D4
	bra.s	Ex2
Left12
	mulu.w	LeftVolume(PC),D4
	and.w	Voice1(PC),D4
	bra.s	Ex2

Right12
	mulu.w	RightVolume(PC),D4
	and.w	Voice2(PC),D4
	bra.s	Ex2
Right22
	mulu.w	RightVolume(PC),D4
	and.w	Voice3(PC),D4
Ex2
	lsr.w	#6,D4
	rts

*------------------------------- Set Vol -------------------------------*

SetVol1
	move.l	A2,-(A7)
	lea	StructAdr+UPS_Voice1Vol(PC),A2
	bra.b	SetVoiceVol

SetVol2
	move.l	A2,-(A7)
	lea	StructAdr+UPS_Voice2Vol(PC),A2
	bra.b	SetVoiceVol

SetVol3
	move.l	A2,-(A7)
	lea	StructAdr+UPS_Voice3Vol(PC),A2
	bra.b	SetVoiceVol

SetVol4
	move.l	A2,-(A7)
	lea	StructAdr+UPS_Voice4Vol(PC),A2
SetVoiceVol
	move.w	D6,(A2)
	move.l	(A7)+,A2
	rts

*------------------------------- Set Vol -------------------------------*

SetVol12
	move.l	A2,-(A7)
	lea	StructAdr+UPS_Voice1Vol(PC),A2
	bra.b	SetVoiceVol2

SetVol22
	move.l	A2,-(A7)
	lea	StructAdr+UPS_Voice2Vol(PC),A2
	bra.b	SetVoiceVol2

SetVol32
	move.l	A2,-(A7)
	lea	StructAdr+UPS_Voice3Vol(PC),A2
	bra.b	SetVoiceVol2

SetVol42
	move.l	A2,-(A7)
	lea	StructAdr+UPS_Voice4Vol(PC),A2
SetVoiceVol2
	move.w	D4,(A2)
	move.l	(A7)+,A2
	rts

*------------------------------- Set Per -------------------------------*

SetPer1
	move.l	A2,-(A7)
	lea	StructAdr+UPS_Voice1Per(PC),A2
	bra.b	SetVoicePer
SetPer2
	move.l	A2,-(A7)
	lea	StructAdr+UPS_Voice2Per(PC),A2
	bra.b	SetVoicePer
SetPer3
	move.l	A2,-(A7)
	lea	StructAdr+UPS_Voice3Per(PC),A2
	bra.b	SetVoicePer
SetPer4
	move.l	A2,-(A7)
	lea	StructAdr+UPS_Voice4Per(PC),A2
SetVoicePer
	move.w	D1,(A2)
	move.l	(A7)+,A2
	rts

*------------------------------- Set Adr -------------------------------*

SetAdr1
	move.l	A2,-(A7)
	lea	StructAdr+UPS_Voice1Adr(PC),A2
	bra.b	SetVoiceAdr
SetAdr2
	move.l	A2,-(A7)
	lea	StructAdr+UPS_Voice2Adr(PC),A2
	bra.b	SetVoiceAdr
SetAdr3
	move.l	A2,-(A7)
	lea	StructAdr+UPS_Voice3Adr(PC),A2
	bra.b	SetVoiceAdr
SetAdr4
	move.l	A2,-(A7)
	lea	StructAdr+UPS_Voice4Adr(PC),A2
SetVoiceAdr
	move.l	A1,(A2)
	move.l	(A7)+,A2
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
	movea.l	dtg_ChkData(A5),A0
	moveq	#-1,D0

	cmp.l	#$0FFF0FE2,(A0)
	beq.b	test1

	cmp.l	#$10000FE2,(A0)
	beq.b	test1

	cmp.l	#$0F1C0F0E,(A0)+
	bne.b	fail
	cmp.l	#$0F000EF2,(A0)+
	bne.b	fail
	cmp.l	#$0EE40ED6,(A0)
	bne.b	fail
	lea	160(A0),A0
	bra.b	LastCheck
test1
	addq.l	#4,A0
	cmp.l	#$0FC40FA7,(A0)+
	bne.b	fail
	cmp.l	#$0F8B0F6E,(A0)
	bne.b	fail
LastCheck
	lea	284(A0),A1
	moveq	#127,D1
CheckSFX
	cmp.l	#$7F7F7F7F,(A1)
	beq.b	fail
	cmp.w	#$FFFF,(A1)
	beq.b	fail
	addq.l	#2,A1
	dbf	D1,CheckSFX
	moveq	#0,D0
fail
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
***************************** EP_Get_ModuleInfo ***************************
***************************************************************************

GetInfos
	lea	InfoBuffer(PC),A0
	rts

SubSongs	=	4
LoadSize	=	12
Length		=	20

InfoBuffer
	dc.l	MI_SubSongs,0		;4
	dc.l	MI_LoadSize,0		;12
	dc.l	MI_Length,0		;20
	dc.l	MI_AuthorName,PlayerName
	dc.l	MI_Prefix,Prefix
	dc.l	0

***************************************************************************
***************************** DTP_InitPlayer ******************************
***************************************************************************

InitPlayer
	moveq	#0,D0
	movea.l	dtg_GetListData(A5),A0
	jsr	(A0)
	lea	ModulePtr(PC),A1
	move.l	A0,(A1)+			; module buffer

	lea	IntAddress(PC),A2
	clr.l	(A2)
	lea	Twin(PC),A2
	clr.w	(A2)

	lea	InfoBuffer(PC),A6
	move.l	D0,LoadSize(A6)
	lea	292(A0),A2
	cmp.w	#$0F1C,(A0)
	bne.b	FindInit
	lea	452(A0),A2
FindInit
	cmp.w	#$45FA,(A2)
	beq.b	OK3
	cmp.w	#$43F9,(A2)
	beq.b	OK3
	cmp.w	#$41F9,(A2)
	beq.b	OK3
	tst.l	(A2)
	beq.w	error
	addq.l	#2,A2
	bra.b	FindInit
OK3
	move.l	A2,(A1)+			; InitPtr
Next
	cmp.w	#$7200,(A2)
	beq.b	FindIt0
	cmp.w	#$7000,(A2)
	beq.b	OneSub
	addq.l	#2,A2
	bra.b	Next
OneSub
	moveq	#1,D0
FindSongs
	cmp.w	#$41FA,(A2)+
	bne.b	FindSongs
	move.l	A2,A3
	add.w	(A3),A3
	lea	FirstPos(PC),A4
	move.l	A3,(A4)
	clr.l	(A1)+				; SongsPtr
	bra.b	OneSong
FindIt0
	cmp.w	#$43FA,(A2)
	beq.b	OK0
	cmp.w	#$43EA,(A2)
	beq.b	OK2
	cmp.l	#$21C80070,(A2)
	beq.b	OK4
	tst.l	(A2)
	beq.w	error
	addq.l	#2,A2
	bra.b	FindIt0
OK4
	move.l	#$4E714E71,(A2)+		; patch for mods with $70.W
	lea	-6(A2),A3
	add.w	(A3),A3
	lea	IntAddress(PC),A4
	move.l	A3,(A4)
	lea	450(A0),A3
	move.l	InitPtr(PC),A4
PatchRTE
	cmp.w	#$4E73,(A3)
	bne.b	NoRTE
	addq.w	#2,(A3)
NoRTE
	addq.l	#2,A3
	cmp.l	A3,A4
	bne.b	PatchRTE
	lea	588(A0),A3
	cmp.l	#$00003B76,(A3)
	bne.b	FindIt0
	move.l	A0,D1
	sub.l	#5236,D1
	add.l	D1,(A3)
	lea	Twin(PC),A3
	st	(A3)
	bra.b	FindIt0
OK2
	addq.l	#2,A2
	move.l	A0,A3
	add.w	(A2),A3
	bra.b	SkipIt1
OK0
	addq.l	#2,A2
	move.l	A2,A3
	add.w	(A3),A3
SkipIt1
	move.l	A3,(A1)+			; SongsPtr
	moveq	#0,D0
	move.w	(A3),D0
	sub.l	A0,A3
	sub.l	A3,D0
	lsr.l	#3,D0
OneSong
	move.l	D0,SubSongs(A6)
FindPlay
	cmp.w	#$1080,(A2)
	beq.b	PlayFound
	cmp.w	#$4210,(A2)
	beq.b	PlayFound
	cmp.w	#$50D0,(A2)
	beq.b	PlayFound
	tst.l	(A2)
	beq.b	error
	addq.l	#2,A2
	bra.b	FindPlay
PlayFound
	addq.l	#4,A2
	move.l	A2,(A1)+			; PlayPtr

	lea	PatchTable(PC),A3

	cmp.w	#$0FFF,(A0)
	bne.b	FindIt1
FindIt11
	cmp.w	#$3D41,(A2)+
	beq.b	OK51
	tst.l	(A2)
	beq.b	error
	bra.b	FindIt11
OK51
	addq.l	#4,A2
	move.w	(A2),ChangeIt9+2-PatchTable(A3)
	move.w	(A2),ChangeItA+2-PatchTable(A3)

FindIt21
	cmp.w	#$3D41,(A2)+
	beq.b	OK61
	tst.l	(A2)
	beq.b	error
	bra.b	FindIt21
OK61
	addq.l	#4,A2
	move.w	(A2),ChangeItB+2-PatchTable(A3)
	move.w	(A2),ChangeItC+2-PatchTable(A3)

FindIt31
	cmp.w	#$3D41,(A2)+
	beq.b	OK71
	tst.l	(A2)
	beq.b	error
	bra.b	FindIt31
OK71
	addq.l	#4,A2
	move.w	(A2),ChangeItD+2-PatchTable(A3)
	move.w	(A2),ChangeItE+2-PatchTable(A3)

FindIt41
	cmp.w	#$3D41,(A2)+
	beq.b	OK81
	tst.l	(A2)
	beq.b	error
	bra.b	FindIt41
OK81
	addq.l	#4,A2
	move.w	(A2),ChangeItF+2-PatchTable(A3)
	move.w	(A2),ChangeItG+2-PatchTable(A3)
	bra.b	SkipNew
error
	moveq	#EPR_UnknownFormat,D0
	rts

FindIt1
	cmp.w	#$3741,(A2)+
	beq.b	OK5
	tst.l	(A2)
	beq.b	error
	bra.b	FindIt1
OK5
	addq.l	#4,A2
	move.w	(A2),ChangeIt1+2-PatchTable(A3)
	move.w	(A2),ChangeIt2+2-PatchTable(A3)

FindIt2
	cmp.w	#$3741,(A2)+
	beq.b	OK6
	tst.l	(A2)
	beq.b	error
	bra.b	FindIt2
OK6
	addq.l	#4,A2
	move.w	(A2),ChangeIt3+2-PatchTable(A3)
	move.w	(A2),ChangeIt4+2-PatchTable(A3)

FindIt3
	cmp.w	#$3741,(A2)+
	beq.b	OK7
	tst.l	(A2)
	beq.b	error
	bra.b	FindIt3
OK7
	addq.l	#4,A2
	move.w	(A2),ChangeIt5+2-PatchTable(A3)
	move.w	(A2),ChangeIt6+2-PatchTable(A3)

FindIt4
	cmp.w	#$3741,(A2)+
	beq.b	OK8
	tst.l	(A2)
	beq.b	error
	bra.b	FindIt4
OK8
	addq.l	#4,A2
	move.w	(A2),ChangeIt7+2-PatchTable(A3)
	move.w	(A2),ChangeIt8+2-PatchTable(A3)
SkipNew
	clr.w	(A1)+				; clearing Change
	move.l	A5,(A1)				; EagleBase
	bsr.w	ModuleChange

	move.l	InitPtr(PC),A0
Find1
	cmp.w	#$1018,(A0)+
	bne.b	Find1
	cmp.b	#$6B,(A0)
	bne.b	Find1
	move.w	(A0)+,D0
	lea	-4(A0),A1
	ext.w	D0
	add.w	D0,A0
	lea	Here+2(PC),A2
	move.l	A0,(A2)
	move.l	ModulePtr(PC),A3
	add.l	LoadSize(A6),A3
	lea	32767(A0),A2
	cmp.l	A2,A3
	bge.b	Find2
	move.l	A3,A2
Find2
	cmp.b	#'S',(A0)
	beq.b	Find4
Find3
	addq.l	#1,A0
	cmp.l	A0,A2
	bne.b	Find2
	bra.w	error
Find4
	cmp.b	#'e',1(A0)
	bne.b	Find3
	cmp.b	#'a',2(A0)
	bne.b	Find3
	cmp.b	#'n',3(A0)
	bne.b	Find3
	move.l	A0,D0
	subq.l	#1,D0
	bclr	#0,D0
	move.l	D0,A0
	move.w	#$4EF9,(A0)+
	lea	ExtraPatch(PC),A2
	move.l	A2,(A0)
	move.w	#$6100,(A1)+
	sub.l	A1,D0
	move.w	D0,(A1)

	movea.l	dtg_AudioAlloc(A5),A0
	jmp	(A0)

ExtraPatch
	move.l	A0,CurrentPos
	move.b	(A0)+,D0
	bmi.b	Jump
	rts
Jump
	addq.l	#4,SP
	moveq	#0,D0
	move.b	(A0),D0
	bmi.b	NoSub
	beq.b	NoSub
	subq.l	#1,D0
	sub.l	D0,CurrentPos
NoSub
	bsr.w	SongEnd
Here
	jmp	'WTWT'

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

	move.w	dtg_SndNum(A5),D0
	move.w	D0,D1
	add.w	#$0F00,D0
	lea	FirstPos(PC),A2
	move.l	SongsPtr(PC),D2
	bne.b	Multi
	move.l	(A2)+,A1
	bra.b	Put
Multi
	move.l	D2,A1
	lsl.w	#3,D1
	lea	(A1,D1.W),A1
	move.w	(A1),A1
	add.l	ModulePtr(PC),A1
	move.l	A1,(A2)+
Put
	move.l	A1,(A2)
	move.l	A1,D1
FindEnd
	cmp.b	#$FF,(A1)+
	bne.b	FindEnd
	sub.l	D1,A1
	lea	InfoBuffer(PC),A2
	move.l	A1,Length(A2)
	move.l	InitPtr(PC),A0
	cmp.l	#$00020A69,150(A0)
	bne.b	NoInfest
	move.b	#2,2221(A0)			; some 68030 configs fix
	bra.b	NoMega
NoInfest
	move.w	Twin(PC),D1
	beq.b	NoMega
	move.w	#$2E6,272(A0)			; my A4000 cache fix
	move.w	#$2FE,312(A0)
	move.w	#$316,352(A0)
	move.w	#$32E,392(A0)
NoMega
	jsr	(A0)
	move.l	IntAddress(PC),D0
	beq.b	NoAudio2
	bsr.w	SetAudioVector
NoAudio2
	rts

***************************************************************************
***************************** DTP_EndSound ********************************
***************************************************************************

EndSound
	move.l	IntAddress(PC),D0
	beq.b	NoAudio1
	bsr.w	ClearAudioVector
NoAudio1
	lea	$DFF000,A0
	move.w	#15,$96(A0)
	moveq	#0,D0
	move.w	D0,$A8(A0)
	move.w	D0,$B8(A0)
	move.w	D0,$C8(A0)
	move.w	D0,$D8(A0)
	rts

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

	move.l	PlayPtr(PC),A0
	jsr	(A0)

	lea	StructAdr(PC),A0
	clr.w	UPS_Enabled(A0)

	movem.l	(SP)+,D1-D7/A0-A6
	moveq	#0,D0
	rts

SongEnd
	movem.l	A1/A5,-(A7)
	move.l	EagleBase(PC),A5
	move.l	dtg_SongEnd(A5),A1
	jsr	(A1)
	movem.l	(A7)+,A1/A5
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
	dc.b	'Sean Conran Audio Interrupt',0
	even

	*----------------- PatchTable for Sean Conran -------------------*

PatchTable
	dc.w	Code4-PatchTable,(Code4End-Code4)/2-1,Patch4-PatchTable
	dc.w	Code5-PatchTable,(Code5End-Code5)/2-1,Patch5-PatchTable
	dc.w	Code6-PatchTable,(Code6End-Code6)/2-1,Patch6-PatchTable
	dc.w	Code7-PatchTable,(Code7End-Code7)/2-1,Patch7-PatchTable
	dc.w	Code8-PatchTable,(Code8End-Code8)/2-1,Patch8-PatchTable
	dc.w	Code9-PatchTable,(Code9End-Code9)/2-1,Patch9-PatchTable
	dc.w	CodeA-PatchTable,(CodeAEnd-CodeA)/2-1,PatchA-PatchTable
	dc.w	CodeB-PatchTable,(CodeBEnd-CodeB)/2-1,PatchB-PatchTable
	dc.w	CodeS-PatchTable,(CodeSEnd-CodeS)/2-1,PatchS-PatchTable
	dc.w	CodeT-PatchTable,(CodeTEnd-CodeT)/2-1,PatchT-PatchTable
	dc.w	CodeU-PatchTable,(CodeUEnd-CodeU)/2-1,PatchU-PatchTable
	dc.w	CodeV-PatchTable,(CodeVEnd-CodeV)/2-1,PatchV-PatchTable
	dc.w	CodeX-PatchTable,(CodeXEnd-CodeX)/2-1,PatchX-PatchTable
	dc.w	CodeY-PatchTable,(CodeYEnd-CodeY)/2-1,PatchY-PatchTable
	dc.w	0
PatchTable2
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
	dc.w	CodeR-PatchTable2,(CodeREnd-CodeR)/2-1,PatchR-PatchTable2
	dc.w	0

; Period patch (voice 1) for Sean Conran modules (1990-91)

Code4
;	LSR.W	#8,D1
	MOVE.W	D1,$10(A3)
ChangeIt1
	MOVE.L	A0,$624(A2)
Code4End
Patch4
;	lsr.w	#8,D1
	move.w	D1,$10(A3)
	bsr.w	SetPer1
ChangeIt2
	move.l	A0,$624(A2)
	rts

; Period patch (voice 2) for Sean Conran modules (1990-91)

Code5
;	LSR.W	#7,D1
	MOVE.W	D1,$20(A3)
ChangeIt3
	MOVE.L	A0,$808(A2)
Code5End
Patch5
;	lsr.w	#7,D1
	move.w	D1,$20(A3)
	bsr.w	SetPer2
ChangeIt4
	move.l	A0,$808(A2)
	rts

; Period patch (voice 3) for Sean Conran modules (1990-91)

Code6
;	LSR.W	#6,D1
	MOVE.W	D1,$30(A3)
ChangeIt5
	MOVE.L	A0,$9F0(A2)
Code6End
Patch6
;	lsr.w	#6,D1
	move.w	D1,$30(A3)
	bsr.w	SetPer3
ChangeIt6
	move.l	A0,$9F0(A2)
	rts

; Period patch (voice 4) for Sean Conran modules (1990-91)

Code7
;	LSR.W	#5,D1
	MOVE.W	D1,$40(A3)
ChangeIt7
	MOVE.L	A0,$BEE(A2)
Code7End
Patch7
;	lsr.w	#5,D1
	move.w	D1,$40(A3)
	bsr.w	SetPer4
ChangeIt8
	move.l	A0,$BEE(A2)
	rts

; Volume patch (voice 1) for Sean Conran modules (1990-91)

Code8
;	ADD.B	D0,D1
	BPL.S	lbC000C3A
	MOVE.W	D6,$12(A3)
	BRA.S	lbC000C42

lbC000C3A	ADD.W	D1,D1
	MOVE.W	0(A0,D1.W),$12(A3)
lbC000C42
Code8End
Patch8
;	add.b	D0,D1
	bpl.b	lbC000C3A1
	bsr.w	Left1
	bsr.w	SetVol1
	move.w	D6,$12(A3)
	bra.b	lbC000C421
lbC000C3A1
	add.w	D1,D1
	move.l	D6,-(A7)
	move.w	0(A0,D1.W),D6
	bsr.w	Left1
	bsr.w	SetVol1
	move.w	D6,$12(A3)
	move.l	(A7)+,D6
lbC000C421
	rts

; Volume patch (voice 2) for Sean Conran modules (1990-91)

Code9
;	ADD.B	D0,D1
	BPL.S	lbC000C4E
	MOVE.W	D6,$22(A3)
	BRA.S	lbC000C56

lbC000C4E	ADD.W	D1,D1
	MOVE.W	0(A0,D1.W),$22(A3)
lbC000C56
Code9End
Patch9
;	add.b	D0,D1
	bpl.b	lbC000C4E1
	bsr.w	Right1
	bsr.w	SetVol2
	move.w	D6,$22(A3)
	bra.b	lbC000C561
lbC000C4E1
	add.w	D1,D1
	move.l	D6,-(A7)
	move.w	0(A0,D1.W),D6
	bsr.w	Right1
	bsr.w	SetVol2
	move.w	D6,$22(A3)
	move.l	(A7)+,D6
lbC000C561
	rts

; Volume patch (voice 3) for Sean Conran modules (1990-91)

CodeA
;	ADD.B	D0,D1
	BPL.S	lbC000C62
	MOVE.W	D6,$32(A3)
	BRA.S	lbC000C6A

lbC000C62	ADD.W	D1,D1
	MOVE.W	0(A0,D1.W),$32(A3)
lbC000C6A
CodeAEnd
PatchA
;	add.b	D0,D1
	bpl.b	lbC000C621
	bsr.w	Right2
	bsr.w	SetVol3
	move.w	D6,$32(A3)
	bra.b	lbC000C6A1
lbC000C621
	add.w	D1,D1
	move.l	D6,-(A7)
	move.w	0(A0,D1.W),D6
	bsr.w	Right2
	bsr.w	SetVol3
	move.w	D6,$32(A3)
	move.l	(A7)+,D6
lbC000C6A1
	rts

; Volume patch (voice 4) for Sean Conran modules (1990-91)

CodeB
;	ADD.B	D0,D1
	BPL.S	lbC000C76
	MOVE.W	D6,$42(A3)
	BRA.S	lbC000C7E

lbC000C76	ADD.W	D1,D1
	MOVE.W	0(A0,D1.W),$42(A3)
lbC000C7E
CodeBEnd
PatchB
;	add.b	D0,D1
	bpl.b	lbC000C761
	bsr.w	Left2
	bsr.w	SetVol4
	move.w	D6,$42(A3)
	bra.b	lbC000C7E1
lbC000C761
	add.w	D1,D1
	move.l	D6,-(A7)
	move.w	0(A0,D1.W),D6
	bsr.w	Left2
	bsr.w	SetVol4
	move.w	D6,$42(A3)
	move.l	(A7)+,D6
lbC000C7E1
	rts

; Period patch (voice 1) for Sean Conran modules (1989)

CodeG
	MOVE.W	D1,$10(A6)
ChangeIt9
	MOVE.L	A0,$4DC(A5)
CodeGEnd
PatchG
	move.w	D1,$10(A6)
	bsr.w	SetPer1
ChangeItA
	move.l	A0,$4DC(A5)
	rts

; Period patch (voice 2) for Sean Conran modules (1989)

CodeH
	MOVE.W	D1,$20(A6)
ChangeItB
	MOVE.L	A0,$696(A5)
CodeHEnd
PatchH
	move.w	D1,$20(A6)
	bsr.w	SetPer2
ChangeItC
	move.l	A0,$696(A5)
	rts

; Period patch (voice 3) for Sean Conran modules (1989)

CodeI
	MOVE.W	D1,$30(A6)
ChangeItD
	MOVE.L	A0,$864(A5)
CodeIEnd
PatchI
	move.w	D1,$30(A6)
	bsr.w	SetPer3
ChangeItE
	move.l	A0,$864(A5)
	rts

; Period patch (voice 4) for Sean Conran modules (1989)

CodeJ
	MOVE.W	D1,$40(A6)
ChangeItF
	MOVE.L	A0,$A30(A5)
CodeJEnd
PatchJ
	move.w	D1,$40(A6)
	bsr.w	SetPer4
ChangeItG
	move.l	A0,$A30(A5)
	rts

; Volume patch (voice 1) for Sean Conran modules (1989)

CodeK
;	ADD.B	D0,D1
	BPL.S	lbC000A7C
	MOVE.W	D4,$12(A6)
	BRA.S	lbC000A84

lbC000A7C	ADD.W	D1,D1
	MOVE.W	0(A0,D1.W),$12(A6)
lbC000A84
CodeKEnd
PatchK
;	ADD.B	D0,D1
	bpl.b	lbC000A7C1
	bsr.w	Left12
	bsr.w	SetVol12
	move.w	D4,$12(A6)
	bra.b	lbC000A841
lbC000A7C1
	add.w	D1,D1
	move.l	D4,-(A7)
	move.w	0(A0,D1.W),D4
	bsr.w	Left12
	bsr.w	SetVol12
	move.w	D4,$12(A6)
	move.l	(A7)+,D4
;	move.w	0(A0,D1.W),$12(A6)
lbC000A841
	rts

; Volume patch (voice 2) for Sean Conran modules (1989)

CodeL
;	ADD.B	D0,D1
	BPL.S	lbC000A90
	MOVE.W	D4,$22(A6)
	BRA.S	lbC000A98

lbC000A90	ADD.W	D1,D1
	MOVE.W	0(A0,D1.W),$22(A6)
lbC000A98
CodeLEnd
PatchL
;	ADD.B	D0,D1
	bpl.b	lbC000A901
	bsr.w	Right12
	bsr.w	SetVol22
	move.w	D4,$22(A6)
	bra.b	lbC000A981
lbC000A901
	add.w	D1,D1
	move.l	D4,-(A7)
	move.w	0(A0,D1.W),D4
	bsr.w	Right12
	bsr.w	SetVol22
	move.w	D4,$22(A6)
	move.l	(A7)+,D4
;	move.w	0(A0,D1.W),$22(A6)
lbC000A981
	rts

; Volume patch (voice 3) for Sean Conran modules (1989)

CodeM
;	ADD.B	D0,D1
	BPL.S	lbC000AA4
	MOVE.W	D4,$32(A6)
	BRA.S	lbC000AAC

lbC000AA4	ADD.W	D1,D1
	MOVE.W	0(A0,D1.W),$32(A6)
lbC000AAC
CodeMEnd
PatchM
;	ADD.B	D0,D1
	bpl.b	lbC000AA41
	bsr.w	Right22
	bsr.w	SetVol32
	move.w	D4,$32(A6)
	bra.b	lbC000AAC1
lbC000AA41
	add.w	D1,D1
	move.l	D4,-(A7)
	move.w	0(A0,D1.W),D4
	bsr.w	Right22
	bsr.w	SetVol32
	move.w	D4,$32(A6)
	move.l	(A7)+,D4
;	move.w	0(A0,D1.W),$32(A6)
lbC000AAC1
	rts

; Volume patch (voice 4) for Sean Conran modules (1989)

CodeN
;	ADD.B	D0,D1
	BPL.S	lbC000AB8
	MOVE.W	D4,$42(A6)
	BRA.S	lbC000AC0

lbC000AB8	ADD.W	D1,D1
	MOVE.W	0(A0,D1.W),$42(A6)
lbC000AC0
CodeNEnd
PatchN
;	ADD.B	D0,D1
	bpl.b	lbC000AB81
	bsr.w	Left22
	bsr.w	SetVol42
	move.w	D4,$42(A6)
	bra.b	lbC000AC01
lbC000AB81
	add.w	D1,D1
	move.l	D4,-(A7)
	move.w	0(A0,D1.W),D4
	bsr.w	Left22
	bsr.w	SetVol42
	move.w	D4,$42(A6)
	move.l	(A7)+,D4
;	move.w	0(A0,D1.W),$42(A6)
lbC000AC01
	rts

; Address patch (voice 1) for Sean Conran modules (1989)

CodeO
	ADDA.L	A5,A1
	MOVE.L	A1,10(A6)
CodeOEnd
PatchO
	add.l	A5,A1
	move.l	A1,10(A6)
	bsr.w	SetAdr1
	rts

; Address patch (voice 2) for Sean Conran modules (1989)

CodeP
	ADDA.L	A5,A1
	MOVE.L	A1,$1A(A6)
CodePEnd
PatchP
	add.l	A5,A1
	move.l	A1,$1A(A6)
	bsr.w	SetAdr2
	rts

; Address patch (voice 3) for Sean Conran modules (1989)

CodeQ
	ADDA.L	A5,A1
	MOVE.L	A1,$2A(A6)
CodeQEnd
PatchQ
	add.l	A5,A1
	move.l	A1,$2A(A6)
	bsr.w	SetAdr3
	rts

; Address patch (voice 4) for Sean Conran modules (1989)

CodeR
	ADDA.L	A5,A1
	MOVE.L	A1,$3A(A6)
CodeREnd
PatchR
	add.l	A5,A1
	move.l	A1,$3A(A6)
	bsr.w	SetAdr4
	rts

; Address patch (voice 1) for Sean Conran modules (1990-91)

CodeS
	ADDA.L	A2,A1
	MOVE.L	A1,10(A3)
CodeSEnd
PatchS
	add.l	A2,A1
	move.l	A1,10(A3)
	bsr.w	SetAdr1
	rts

; Address patch (voice 2) for Sean Conran modules (1990-91)

CodeT
	ADDA.L	A2,A1
	MOVE.L	A1,$1A(A3)
CodeTEnd
PatchT
	add.l	A2,A1
	move.l	A1,$1A(A3)
	bsr.w	SetAdr2
	rts

; Address patch (voice 3) for Sean Conran modules (1990-91)

CodeU
	ADDA.L	A2,A1
	MOVE.L	A1,$2A(A3)
CodeUEnd
PatchU
	add.l	A2,A1
	move.l	A1,$2A(A3)
	bsr.w	SetAdr3
	rts

; Address patch (voice 4) for Sean Conran modules (1990-91)

CodeV
	ADDA.L	A2,A1
	MOVE.L	A1,$3A(A3)
CodeVEnd
PatchV
	add.l	A2,A1
	move.l	A1,$3A(A3)
	bsr.w	SetAdr4
	rts

; Address/length patch (voice 1) for Sean Conran module (MegaTwins)

CodeX
	MOVE.L	D1,10(A3)
	MOVE.W	(A1)+,14(A3)
CodeXEnd
PatchX
	move.l	D1,10(A3)
	move.l	A1,-(A7)
	move.l	D1,A1
	bsr.w	SetAdr1
	move.l	(A7)+,A1
	move.l	A2,-(A7)
	lea	StructAdr(PC),A2
	move.w	(A1),UPS_Voice1Len(A2)
	move.w	(A1)+,14(A3)
	move.l	(A7)+,A2
	rts

; Address/length patch (voice 2) for Sean Conran module (MegaTwins)

CodeY
	MOVE.L	D1,$1A(A3)
	MOVE.W	(A1)+,$1E(A3)
CodeYEnd
PatchY
	move.l	D1,$1A(A3)
	move.l	A1,-(A7)
	move.l	D1,A1
	bsr.w	SetAdr2
	move.l	(A7)+,A1
	move.l	A2,-(A7)
	lea	StructAdr(PC),A2
	move.w	(A1),UPS_Voice2Len(A2)
	move.w	(A1)+,$1E(A3)
	move.l	(A7)+,A2
	rts

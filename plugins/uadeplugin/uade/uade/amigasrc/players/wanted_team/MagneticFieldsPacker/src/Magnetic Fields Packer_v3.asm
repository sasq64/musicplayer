	*****************************************************
	****        MFP replayer for EaglePlayer	 ****
	****        all adaptions by Wanted Team,	 ****
	****      DeliTracker compatible (?) version	 ****
	*****************************************************

	incdir	"dh2:include/"
	include 'misc/eagleplayer2.01.i'

	SECTION	Player,CODE

	PLAYERHEADER Tags

	dc.b	'$VER: Magnetic Fields Packer player module V1.2 (31 Jan 2003)',0
	even
Tags
	dc.l	DTP_PlayerVersion,3
	dc.l	EP_PlayerVersion,9
	dc.l	DTP_RequestDTVersion,DELIVERSION
	dc.l	DTP_PlayerName,PlayerName
	dc.l	DTP_Creator,Creator
	dc.l	DTP_Check2,Check2
	dc.l	DTP_InitPlayer,InitPlayer
	dc.l	DTP_EndPlayer,EndPlayer
	dc.l	DTP_InitSound,InitSound
	dc.l	DTP_EndSound,EndSound
	dc.l	DTP_Interrupt,Interrupt
	dc.l	EP_Get_ModuleInfo,Get_ModuleInfo
	dc.l	DTP_ExtLoad,ExtLoad
	dc.l	DTP_Volume,SetVolume
	dc.l	DTP_Balance,SetBalance
	dc.l	EP_Voices,SetVoices
	dc.l	EP_StructInit,StructInit
	dc.l	EP_GetPositionNr,GetPosition
	dc.l	DTP_NextPatt,Next_Pattern
	dc.l	DTP_PrevPatt,BackPattern
	dc.l	EP_SampleInit,SampleInit
	dc.l	EP_Save,Save
	dc.l	EP_Flags,EPB_Save!EPB_Volume!EPB_Balance!EPB_ModuleInfo!EPB_Voices!EPB_SampleInfo!EPB_Songend!EPB_Analyzer!EPB_Packable!EPB_Restart!EPB_PrevPatt!EPB_NextPatt!EPB_LoadFast
	dc.l	0

PlayerName
	dc.b	'Magnetic Fields Packer',0
Creator
	dc.b	'(c) 1994-95 by Shaun Southern,',10
	dc.b	'adapted by Mr.Larmer/Wanted Team',0
Prefix
	dc.b	'MFP.',0
SMP
	dc.b	'SMP.',0
	even
ModulePtr
	dc.l	0
SamplesPtr
	dc.l	0
EagleBase
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
	move.l	InfoBuffer+SongSize(PC),EPG_ARG2(A5)
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
	lea	SMP(PC),A0
	move.l	dtg_CopyString(A5),A1
	jsr	(A1)
	move.l	A3,A0
	addq.l	#4,A0
	move.l	dtg_CopyString(A5),A1
	jsr	(A1)
	move.l	dtg_PathArrayPtr(A5),EPG_ARG3(A5)
	move.l	SamplesPtr(PC),EPG_ARG1(A5)
	move.l	InfoBuffer+SamplesSize(PC),D0
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
******************************* DTP_ExtLoad *******************************
***************************************************************************

ExtLoad
	lea	SetName(PC),A2
	clr.w	(A2)
	movea.l	dtg_PathArrayPtr(A5),A0
	clr.b	(A0)
	movea.l	dtg_CopyDir(A5),A0
	jsr	(A0)
	bsr.s	CopyName
	movea.l	dtg_LoadFile(A5),A0
	jsr	(A0)
	tst.l	D0
	beq.b	LoadOK

	st	(A2)
	movea.l	dtg_PathArrayPtr(A5),A0
	clr.b	(A0)
	movea.l	dtg_CopyDir(A5),A0
	jsr	(A0)
	bsr.s	CopyName
	movea.l	dtg_LoadFile(A5),A0
	jsr	(A0)
LoadOK
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
	cmpi.b	#'F',1(A3)
	beq.b	F_OK
	cmpi.b	#'f',1(A3)
	bne.s	ExtError
F_OK
	cmpi.b	#'P',2(A3)
	beq.b	P_OK
	cmpi.b	#'p',2(A3)
	bne.s	ExtError
P_OK
	cmpi.b	#'.',3(A3)
	bne.s	ExtError

	move.b	#'S',(A3)+
	move.b	#'M',(A3)+
	move.b	#'P',(A3)+
	clr.b	-1(A0)
	tst.w	(A2)
	beq.b	ExtOK
CheckName
	cmp.b	#'-',(A3)
	beq.b	Set
	tst.b	(A3)+
	bne.b	CheckName
	rts
Set
	move.b	#'.',(A3)+
	move.b	#'S',(A3)+
	move.b	#'E',(A3)+
	move.b	#'T',(A3)+
	clr.b	(A3)
	rts
ExtError
	clr.b	-2(A0)
ExtOK
	rts

SetName
	dc.w	0

***************************************************************************
******************************* EP_SampleInit *****************************
***************************************************************************

SampleInit
	moveq	#EPR_NotEnoughMem,D7
	lea	EPG_SampleInfoStructure(A5),A3
	move.l	ModulePtr(PC),D0
	beq.b	return
	move.l	D0,A2

	move.l	SamplesPtr(PC),A1
	moveq	#30,D5
hop
	jsr	ENPP_AllocSampleStruct(A5)
	move.l	D0,(A3)
	beq.b	return
	move.l	D0,A3

	moveq	#0,D0
	move.w	(A2),D0
	add.l	D0,D0
	move.l	A1,EPS_Adr(A3)			; sample address
	move.l	D0,EPS_Length(A3)		; sample length
	move.l	#64,EPS_Volume(A3)
	move.w	#USITY_RAW,EPS_Type(A3)
	move.w	#USIB_Playable!USIB_Saveable!USIB_8BIT,EPS_Flags(A3)
	addq.l	#8,A2
	add.l	D0,A1
	dbf	D5,hop

	moveq	#0,D7
return
	move.l	D7,D0
	rts

***************************************************************************
******************************* DTP_NextPatt ******************************
***************************************************************************

Next_Pattern
	move.b	lbB04463C(PC),D7
	addq.b	#1,D7
	cmp.b	InfoBuffer+Length+3(PC),D7
	beq.b	MaxPos
	move.l	dtg_StopInt(A5),A0
	jsr	(A0)
	move.b	D7,lbW044918+1
	bsr.w	SetPosition
	move.l	dtg_StartInt(A5),A0
	jsr	(A0)
MaxPos
	rts

***************************************************************************
******************************* DTP_BackPatt ******************************
***************************************************************************

BackPattern
	move.b	lbB04463C(PC),D7
	beq.b	MinPos
	move.l	dtg_StopInt(A5),A0
	jsr	(A0)
	subq.b	#1,D7
	move.b	D7,lbW044918+1
	bsr.w	SetPosition
	move.l	dtg_StartInt(A5),A0
	jsr	(A0)
MinPos
	rts

***************************************************************************
***************************** EP_Get_ModuleInfo ***************************
***************************************************************************

Get_ModuleInfo
	lea	InfoBuffer(PC),A0
	rts

LoadSize	=	4
Samples		=	12
Length		=	20
SamplesSize	=	28
SongSize	=	36
CalcSize	=	44
Pattern		=	52

InfoBuffer
	dc.l	MI_LoadSize,0		;4
	dc.l	MI_Samples,0		;12
	dc.l	MI_Length,0		;20
	dc.l	MI_SamplesSize,0	;28
	dc.l	MI_Songsize,0		;36
	dc.l	MI_Calcsize,0		;44
	dc.l	MI_Pattern,0		;52
	dc.l	MI_MaxLength,128
	dc.l	MI_MaxSamples,31
	dc.l	MI_MaxPattern,100
	dc.l	MI_Prefix,Prefix
	dc.l	0

***************************************************************************
******************************* DTP_Check2 ********************************
***************************************************************************

Check2
	movea.l	dtg_ChkData(A5),A0
	moveq	#-1,D0

	cmp.l	#400,dtg_ChkSize(A5)
	ble.b	Fault
	lea	248(A0),A0
	move.b	(A0)+,D1
	beq.b	Fault
	moveq	#127,D3
	cmp.b	(A0)+,D3
	bne.b	Fault
	lea	128(A0),A0
	move.w	(A0)+,D2
	cmp.w	(A0),D2
	bne.b	Fault
	cmp.w	D3,D2
	bhi.b	Fault
	cmp.b	D1,D2
	bne.b	Fault
	moveq	#0,D0
Fault
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

	move.l	A0,A1
	moveq	#30,D0
	moveq	#0,D1
	moveq	#0,D2
	moveq	#0,D3
NextInfo
	move.w	(A1),D1
	beq.b	Empty
	addq.l	#1,D2
	add.l	D1,D3
Empty
	addq.l	#8,A1
	dbf	D0,NextInfo
	add.l	D3,D3
	move.l	D3,SamplesSize(A4)
	move.l	D2,Samples(A4)
	move.b	(A1)+,D2
	move.l	D2,Length(A4)
	addq.l	#1,A1
	moveq	#0,D0
NextPos
	move.b	(A1)+,D1
	cmp.b	D1,D0
	bge.b	MaxPat
	move.b	D1,D0
MaxPat
	dbf	D2,NextPos
	addq.l	#1,D0
	move.l	D0,Pattern(A4)

	move.w	378(A0),D0
	asl.l	#2,D0
	subq.l	#1,D0
	lea	382(A0),A1
	moveq	#0,D2
NextWord
	move.w	(A1)+,D1
	cmp.w	D1,D2
	bge.b	MaxWord
	move.w	D1,D2
MaxWord
	dbf	D0,NextWord
	add.l	D2,A1
	cmp.w	#1,Pattern+2(A4)
	bne.b	FindIt

	move.w	-2(A1),D0
FindOne
	cmp.w	(A1)+,D0
	beq.b	Koniec
	bra.b	FindOne

FindIt
	cmp.l	#$04040404,(A1)
	beq.b	GoodLong
BadLong
	addq.l	#2,A1
	bra.b	FindIt

GoodLong
	cmp.l	#$08080808,4(A1)
	bne.b	BadLong
NextLong
	cmp.l	#$04040404,(A1)
	bne.b	Koniec
	lea	16(A1),A1
	bra.b	NextLong
Koniec
	sub.l	A0,A1
	move.l	A1,SongSize(A4)
	add.l	A1,D3
	move.l	D3,CalcSize(A4)
	moveq	#1,D0
	movea.l	dtg_GetListData(A5),A0
	jsr	(A0)

	move.l	A0,(A6)+				; sample buffer
	add.l	D0,LoadSize(A4)

	move.l	A5,(A6)					; EagleBase

	movea.l	dtg_AudioAlloc(A5),A0
	jmp	(A0)

***************************************************************************
***************************** DTP_EndPlayer *******************************
***************************************************************************

EndPlayer
	movea.l	dtg_AudioFree(A5),A0
	jmp	(A0)

***************************************************************************
********************************* EP_GetPosNr *****************************
***************************************************************************

GetPosition
	moveq	#0,D0
	move.b	lbB04463C(PC),D0
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
***************************** DTP_InitSound *******************************
***************************************************************************

InitSound
	lea	StructAdr(PC),A0
	lea	UPS_SizeOF(A0),A1
ClearUPS
	clr.w	(A0)+
	cmp.l	A0,A1
	bne.b	ClearUPS
	bra.w	Init

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

***************************************************************************
***************************** DTP_Interrupt *******************************
***************************************************************************

Interrupt
	movem.l	D0-A6,-(A7)
	lea	StructAdr(PC),A5
	st	UPS_Enabled(A5)
	clr.w	UPS_Voice1Per(A5)
	clr.w	UPS_Voice2Per(A5)
	clr.w	UPS_Voice3Per(A5)
	clr.w	UPS_Voice4Per(A5)
	move.w	#UPSB_Adr!UPSB_Len!UPSB_Per!UPSB_Vol,UPS_Flags(A5)

	bsr.w	Play

	clr.w	UPS_Enabled(A5)
	movem.l	(A7)+,D0-A6
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
	movem.l	A1/A5,-(A7)
	move.l	EagleBase(PC),A5
	move.l	dtg_WaitAudioDMA(A5),A1
	jsr	(A1)
	movem.l	(A7)+,A1/A5
	rts

***************************************************************************
******************************** MFP player *******************************
***************************************************************************

; Player from game "Tower of Souls" (c) 1995 by Black Legend

;lbC0074AC	LEA	lbL007562,A0
;	MOVEQ	#$1B,D7
;lbC0074B4	CLR.W	(A0)+
;	DBRA	D7,lbC0074B4
;	ORI.B	#2,$BFE001
;	MOVE.W	#15,$96(A6)
;	LEA	lbW007542,A0
;	MOVEQ	#7,D7
;lbC0074D0	CLR.W	(A0)+
;	DBRA	D7,lbC0074D0
;	RTS


;lbL00752A	dc.l	0
;	dc.l	0
;	dc.w	0
;lbW007534	dc.w	$100
;lbW007536	dc.w	$100
;lbW007538	dc.w	0
;lbW00753A	dc.w	0
;lbW00753C	dc.w	0
;lbW00753E	dc.w	0
;	dc.w	0
;lbW007542	dc.w	0
;lbW007544	dc.w	0
;lbW007546	dc.w	0
;lbW007548	dc.w	0
;	dc.w	0
;	dc.w	0
;	dc.w	0
;	dc.w	0
;lbL007552	dc.l	0
;	dc.l	0
;lbL00755A	dc.l	0
;	dc.l	0
;lbL007562	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;lbL007582	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;lbL0075B6	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;lbW00763A	dc.w	0
;lbW00763C	dc.w	1
;	dc.w	0
;	dc.w	0
;	dc.w	0
;	dc.w	0
;	dc.w	0
;	dc.w	0
;	dc.w	0
;	dc.w	0
;	dc.w	0
;	dc.w	0
;	dc.w	0
;	dc.w	0
;	dc.w	0
;	dc.w	0
;	dc.w	0
;	dc.w	0
;	dc.w	0
;	dc.w	0
;	dc.w	0
;	dc.w	0
;	dc.w	0
;	dc.w	0
;	dc.w	0
;	dc.w	0
;	dc.w	0
;	dc.w	0
;	dc.w	0
;	dc.w	0
;	dc.w	0
;	dc.w	0
;lbL00767A	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0


;lbL044384	dc.l	0
;lbL044388	dc.l	0
;lbL04438C	dc.l	0
;lbL044390	dc.l	0
;lbW044394	dc.w	0
;lbL044396	dc.l	0
;lbW04439A	dc.w	1
;lbW04439C	dc.w	1
;lbL04439E	dc.l	0
;lbL0443A2	dc.l	0
;lbL0443A6	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;lbL044426	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;lbL0444A6	dc.l	0
lbL0444AA	dc.l	0
;lbL0444AE	dc.l	0
;lbW0444B2	dc.w	0
;lbW0444B4	dc.w	0
lbL0444B6	dc.l	0
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
	dc.w	0
lbW0444E8	dc.w	0
lbW0444EA	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
lbL0444F6	dc.l	0
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
	dc.w	0
lbW044528	dc.w	0
lbW04452A	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
lbL044536	dc.l	0
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
	dc.w	0
lbW044568	dc.w	0
lbW04456A	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
lbL044576	dc.l	0
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
	dc.w	0
lbW0445A8	dc.w	0
lbW0445AA	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
lbL0445B6	dc.l	0
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
lbL044636	dc.l	0
lbB04463A	dc.b	0
lbB04463B	dc.b	0
lbB04463C	dc.b	0
lbB04463D	dc.b	0
lbB04463E	dc.b	0
lbB04463F	dc.b	0
lbB044640	dc.b	0
lbB044641	dc.b	0
lbB044642	dc.b	0
	dc.b	0
lbW044644	dc.w	0
lbW044646	dc.w	0
lbW044648	dc.w	0
;lbW04464A	dc.w	0
lbL04464C	dc.l	0
lbL044650	dc.l	0
lbL044654	dc.l	0
lbW044658	dc.w	0
;lbL04465A	dc.l	0
;lbW04465E	dc.w	0
;lbW044660	dc.w	0

;lbC044662	MOVE.B	lbL044668(PC,D0.W),D0
;	RTS

;lbL044668	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.w	0

;lbC0446AA	LEA	lbL044668,A0
;	MOVE.W	#0,D0
;lbC0446B4	MOVE.W	D0,D1
;	MULU.W	lbW00753A,D1
;	LSR.W	#8,D1
;	MOVE.B	D1,(A0)+
;	ADDQ.W	#1,D0
;	CMPI.W	#$41,D0
;	BNE.L	lbC0446B4
;	RTS

;lbC0446CC	MOVEM.L	D0/D1/D7,-(SP)
;lbC0446D0	MOVE.L	$DFF004,D0
;	ANDI.L	#$1FF00,D0
;lbC0446DC	MOVE.L	$DFF004,D1
;	ANDI.L	#$1FF00,D1
;	CMP.L	D0,D1
;	BEQ.S	lbC0446DC
;	DBRA	D7,lbC0446D0
;	MOVEM.L	(SP)+,D0/D1/D7
;	RTS

;	MOVE.L	A0,-(SP)
;	MOVE.W	lbW04465E,D0
;	MOVEA.L	lbL04465A,A0
;	MOVE.B	0(A0,D0.W),D0
;	MOVEA.L	(SP)+,A0
;	ADDQ.W	#1,lbW04465E
;	ANDI.W	#$3FF,lbW04465E
;	ANDI.W	#$FF,D0
;	RTS

;	MOVE.L	A0,-(SP)
;	MOVE.W	lbW04465E,D0
;	MOVEA.L	lbL04465A,A0
;	MOVE.B	0(A0,D0.W),D0
;	MOVEA.L	(SP)+,A0
;	ADDQ.W	#1,lbW04465E
;	ANDI.W	#$3FF,lbW04465E
;	ASL.W	#8,D0
;	RTS

;	MOVE.W	#0,lbW04465E
;	RTS

;lbC04474E	BSR.L	lbC04550C
;	MOVE.L	D1,lbL0444A6
;	JSR	lbC045CA4
;	JSR	lbC045CCE
;	MOVE.B	#6,lbB04463A
;	JSR	lbC044A40
;	RTS

;lbC044774	MOVE.L	lbL044384,lbL044802
;	MOVE.L	lbL044388,lbL044806
;	LEA	lbL044802,A3
;	LEA	lbW044832,A4
;	MOVE.W	#3,D7
;lbC044798	MOVE.W	D7,-(SP)
;	MOVE.W	(A4)+,D0
;	MOVEA.L	(A3),A0
;	MOVEM.L	A3/A4,-(SP)
;	MOVEA.L	A0,A1
;	JSR	lbC005E56
;	MOVEM.L	(SP)+,A3/A4
;	MOVE.L	(A3)+,D1
;	ADD.L	D0,D1
;	ADDI.L	#1,D1
;	ANDI.L	#$FFFFFFFE,D1
;	MOVE.L	D1,4(A3)
;	MOVE.W	(A4)+,D0
;	MOVEA.L	(A3),A0
;	MOVEM.L	A3/A4,-(SP)
;	MOVEA.L	A0,A1
;	JSR	lbC005E56
;	MOVEM.L	(SP)+,A3/A4
;	MOVE.L	(A3)+,D1
;	ADD.L	D0,D1
;	ADDI.L	#1,D1
;	ANDI.L	#$FFFFFFFE,D1
;	MOVE.L	D1,4(A3)
;	MOVE.W	(SP)+,D7
;	DBRA	D7,lbC044798
;	RTS

;lbL0447F2	dc.l	lbL044802
;	dc.l	lbL04480A
;	dc.l	lbL044812
;	dc.l	lbL04481A
;lbL044802	dc.l	0
;lbL044806	dc.l	0
;lbL04480A	dc.l	0
;	dc.l	0
;lbL044812	dc.l	0
;	dc.l	0
;lbL04481A	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;lbW044832	dc.w	1
;	dc.w	2
;	dc.w	3
;	dc.w	4
;	dc.w	5
;	dc.w	6
;	dc.w	7
;	dc.w	8
;	dc.w	9
;	dc.w	10

Init
	move.l	SamplesPtr(PC),A0
	move.l	ModulePtr(PC),A1
	lea	lbL0444AA(PC),A2
	move.l	A1,(A2)
	lea	lbL0445B6(PC),A3
	moveq	#30,D7
Next
	move.l	A0,(A3)+
	moveq	#0,D1
	move.w	(A1),D1
	beq.b	EmptyInfo		; fix - no more no allocated memory clearing
	clr.l	(A0)			; necessary for bad ripped Crystal Dragon songs
	add.l	D1,D1
	add.l	D1,A0
EmptyInfo
	addq.l	#8,A1
	dbf	D7,Next
	move.b	#6,lbB04463A

lbC044846	LEA	lbL0444B6(pc),A0
	MOVE.W	#$3F,D7
lbC044850	CLR.L	(A0)+
	DBRA	D7,lbC044850
	LEA	lbL0444B6(pc),A0
	MOVE.L	#$10000,$14(A0)
	LEA	lbL0444F6(pc),A0
	MOVE.L	#$20000,$14(A0)
	LEA	lbL044536(pc),A0
	MOVE.L	#$40000,$14(A0)
	LEA	lbL044576(pc),A0
	MOVE.L	#$80000,$14(A0)
	MOVEA.L	lbL0444AA(pc),A0
	MOVE.L	A0,lbL044636
;	MOVEA.L	lbL044636,A0
	MOVE.W	$17A(A0),D0
	ASL.W	#3,D0
	LEA	$17E(A0),A0
	MOVE.L	A0,lbL04464C
	ADDA.W	D0,A0
	MOVE.L	A0,lbL044650
;	MOVEA.L	lbL044636,A0
;	LEA	lbB04463A,A1
	ORI.B	#2,$BFE001
SetPosition
	MOVEQ	#0,D0
	LEA	$DFF000,A0
	MOVE.W	D0,$A8(A0)
	MOVE.W	D0,$B8(A0)
	MOVE.W	D0,$C8(A0)
	MOVE.W	D0,$D8(A0)
	MOVE.B	D0,lbB04463C
	MOVE.B	D0,lbB04463B
	MOVE.W	D0,lbW044644
	MOVE.B	D0,lbB044641
	MOVE.B	D0,lbB044642
	MOVE.W	lbW044918(pc),D0
	MOVE.B	D0,lbB04463C
	CLR.W	lbW044918
	RTS

;	dc.w	0
lbW044918	dc.w	0

;lbC04491A	MOVEQ	#0,D0
;	LEA	$DFF000,A0
;	MOVE.W	D0,$A8(A0)
;	MOVE.W	D0,$B8(A0)
;	MOVE.W	D0,$C8(A0)
;	MOVE.W	D0,$D8(A0)
;	MOVE.W	#15,$DFF096
;	RTS

lbC04493C	MOVE.W	D1,D2
	LSR.W	#4,D2
	ANDI.W	#3,D2
	MOVE.B	0(A0,D2.W),D0
	MOVE.W	D1,D2
	LSR.W	#2,D2
	ANDI.W	#3,D2
	ADD.B	D0,D2
	MOVE.B	0(A0,D2.W),D0
	MOVE.W	D1,D2
	ANDI.W	#3,D2
	ADD.B	D0,D2
	MOVEQ	#0,D0
	MOVE.B	0(A0,D2.W),D0
	ADD.W	D0,D0
	MOVE.L	0(A0,D0.W),D0
	RTS

lbC04496C
;	MOVE.W	lbW007542,lbW04464A
	LEA	lbL0444B6(pc),A6
	BSR.L	lbC04506E
;	MOVE.W	lbW007544,lbW04464A
	LEA	lbL0444F6(pc),A6
	BSR.L	lbC04506E
;	MOVE.W	lbW007546,lbW04464A
	LEA	lbL044536(pc),A6
	BSR.L	lbC04506E
;	MOVE.W	lbW007548,lbW04464A
	LEA	lbL044576(pc),A6
	BSR.L	lbC04506E
	RTS

lbC0449BE
;	TST.W	lbW007542
;	BPL.L	lbC0449DE
	LEA	lbL0444B6(pc),A6
	MOVE.L	10(A6),$DFF0A0
	MOVE.W	14(A6),$DFF0A4
lbC0449DE
;	TST.W	lbW007544
;	BPL.L	lbC0449FE
	LEA	lbL0444F6(pc),A6
	MOVE.L	10(A6),$DFF0B0
	MOVE.W	14(A6),$DFF0B4
lbC0449FE
;	TST.W	lbW007546
;	BPL.L	lbC044A1E
	LEA	lbL044536(pc),A6
	MOVE.L	10(A6),$DFF0C0
	MOVE.W	14(A6),$DFF0C4
lbC044A1E
;	TST.W	lbW007548
;	BPL.L	lbC044A3E
	LEA	lbL044576(pc),A6
	MOVE.L	10(A6),$DFF0D0
	MOVE.W	14(A6),$DFF0D4
lbC044A3E	RTS

;lbC044A40	MOVE.W	lbW007536,lbW00753A
;	MOVE.W	lbW007536,lbW00753E
;	MOVE.L	lbL0443A2,lbL0444AA
;	LEA	lbL044426,A1
;	LEA	lbL0445B6(pc),A3
;	MOVE.W	#$1F,D7
;lbC044A6E	MOVE.L	(A1)+,(A3)+
;	DBRA	D7,lbC044A6E
;	JSR	lbC044846
;	MOVE.W	#1,lbW0444B4
;	JSR	lbC0074AC
;	LEA	lbL00755A,A0
;	MOVE.W	#$64,(A0)+
;	MOVE.W	#$50,(A0)+
;	MOVE.W	#$32,(A0)+
;	MOVE.W	#0,(A0)+
;	LEA	lbW007542,A0
;	MOVE.W	#$FFFF,(A0)+
;	MOVE.W	#$FFFF,(A0)+
;	MOVE.W	#$FFFF,(A0)+
;	MOVE.W	#$FFFF,(A0)+
;	BSR.L	lbC0446AA
;	RTS

;lbC044ABA	MOVE.W	lbW00753E,D3
;	MOVE.W	lbW00753A,D2
;	CMP.W	D3,D2
;	BEQ.S	lbC044AEA
;	BMI.S	lbC044AD6
;	SUBI.W	#8,D2
;	BPL.S	lbC044AE0
;	MOVEQ	#0,D2
;	BRA.S	lbC044AE0

;lbC044AD6	ADDI.W	#8,D2
;	CMP.W	D3,D2
;	BMI.S	lbC044AE0
;	MOVE.W	D3,D2
;lbC044AE0	MOVE.W	D2,lbW00753A
;	BSR.L	lbC0446AA
;lbC044AEA	TST.W	lbW0444B4
;	BEQ.S	lbC044B00
;	MOVEM.L	D0-D7/A0-A6,-(SP)
;	JSR	lbC044BDA
;	MOVEM.L	(SP)+,D0-D7/A0-A6
;lbC044B00	RTS

lbC044B02	MOVEA.L	lbL044636(pc),A0
	LEA	-8(A0),A3
	LEA	$FA(A0),A2
	MOVEA.L	lbL04464C(pc),A0
	MOVEQ	#0,D0
	MOVE.B	lbB04463C(pc),D0
	ASL.W	#3,D0
	ADDA.W	D0,A0
	MOVE.L	A0,lbL044654
	MOVEA.L	lbL044654(pc),A0
	MOVE.W	0(A0),D1
	MOVEA.L	lbL044650(pc),A0
	ADDA.W	D1,A0
	MOVE.W	lbW044644(pc),D1
	BSR.L	lbC04493C
;	LEA	lbW007542,A4
	LEA	lbL0444B6(pc),A6
	BSR.L	lbC044EC8
	MOVEA.L	lbL044654(pc),A0
	MOVE.W	2(A0),D1
	MOVEA.L	lbL044650(pc),A0
	ADDA.W	D1,A0
	MOVE.W	lbW044644(pc),D1
	BSR.L	lbC04493C
;	LEA	lbW007544,A4
	LEA	lbL0444F6(pc),A6
	BSR.L	lbC044EC8
	MOVEA.L	lbL044654(pc),A0
	MOVE.W	4(A0),D1
	MOVEA.L	lbL044650(pc),A0
	ADDA.W	D1,A0
	MOVE.W	lbW044644(pc),D1
	BSR.L	lbC04493C
;	LEA	lbW007546,A4
	LEA	lbL044536(pc),A6
	BSR.L	lbC044EC8
	MOVEA.L	lbL044654(pc),A0
	MOVE.W	6(A0),D1
	MOVEA.L	lbL044650(pc),A0
	ADDA.W	D1,A0
	MOVE.W	lbW044644(pc),D1
	BSR.L	lbC04493C
;	LEA	lbW007548,A4
	LEA	lbL044576(pc),A6
	BSR.L	lbC044EC8
	RTS

Play
lbC044BDA	MOVEQ	#-1,D0
	LEA	lbW0444E8(pc),A4
	MOVE.W	D0,(A4)+
	MOVE.L	D0,(A4)+
	MOVE.L	D0,(A4)+
	LEA	lbW044528(pc),A4
	MOVE.W	D0,(A4)+
	MOVE.L	D0,(A4)+
	MOVE.L	D0,(A4)+
	LEA	lbW044568(pc),A4
	MOVE.W	D0,(A4)+
	MOVE.L	D0,(A4)+
	MOVE.L	D0,(A4)+
	LEA	lbW0445A8(pc),A4
	MOVE.W	D0,(A4)+
	MOVE.L	D0,(A4)+
	MOVE.L	D0,(A4)+
	CLR.W	lbW044658
	BSR.L	lbC0449BE
	ADDQ.B	#1,lbB04463B
	MOVE.B	lbB04463B(pc),D0
	CMP.B	lbB04463A(pc),D0
	BCS.S	lbC044C42
	CLR.B	lbB04463B
	TST.B	lbB044642
	BEQ.L	lbC044C4A
	BSR.L	lbC04496C
	BRA.L	lbC044C5A

lbC044C42	BSR.L	lbC04496C
	BRA.L	lbC044D12

lbC044C4A	CLR.W	lbW044646
	CLR.W	lbW044648
	BSR.L	lbC044B02
lbC044C5A	ADDI.W	#1,lbW044644
	MOVE.B	lbB044641(pc),D0
	BEQ.S	lbC044C76
	MOVE.B	D0,lbB044642
	CLR.B	lbB044641
lbC044C76	TST.B	lbB044642
	BEQ.S	lbC044C8E
	SUBQ.B	#1,lbB044642
	BEQ.S	lbC044C8E
	SUBI.W	#1,lbW044644
lbC044C8E	TST.B	lbB04463F
	BEQ.S	lbC044CB0
	SF	lbB04463F
	MOVEQ	#0,D0
	MOVE.B	lbB04463D(pc),D0
	CLR.B	lbB04463D
	MOVE.W	D0,lbW044644
lbC044CB0	CMPI.W	#$40,lbW044644
	BCS.S	lbC044D12
lbC044CBA	MOVEQ	#0,D0
	MOVE.B	lbB04463D(pc),D0
	MOVE.W	D0,lbW044644
	CLR.B	lbB04463D
	CLR.B	lbB04463E
	ADDQ.B	#1,lbB04463C
;	TST.W	lbW044394
;	BEQ.S	lbC044CF2
;	CMPI.B	#2,lbB04463C
;	BNE.S	lbC044CF2
;	SUBQ.B	#1,lbB04463C
lbC044CF2	ANDI.B	#$7F,lbB04463C
	MOVE.B	lbB04463C(pc),D1
	MOVEA.L	lbL044636(pc),A0
	CMP.B	$F8(A0),D1
	BCS.S	lbC044D12

	bsr.w	SongEnd

	CLR.B	lbB04463C
lbC044D12	LEA	$DFF000,A6
;	TST.W	lbW007542
;	BPL.L	lbC044D54
	LEA	lbW0444E8(pc),A4
	MOVE.W	(A4)+,D0
	BMI.L	lbC044D36
;	BSR.L	lbC044662

	bsr.w	Left1
	move.w	D0,UPS_Voice1Vol(A5)

	MOVE.W	D0,$A8(A6)
lbC044D36	MOVE.W	(A4)+,D0
	BMI.L	lbC044D40
	MOVE.W	D0,$A6(A6)
lbC044D40	MOVE.W	(A4)+,D0
	BMI.L	lbC044D4A
	MOVE.W	D0,$A4(A6)

	move.w	D0,UPS_Voice1Len(A5)
	move.w	-4(A4),UPS_Voice1Per(A5)

lbC044D4A	MOVE.L	(A4)+,D0
	BMI.L	lbC044D54
	MOVE.L	D0,$A0(A6)

	move.l	D0,UPS_Voice1Adr(A5)

lbC044D54
;	TST.W	lbW007544
;	BPL.L	lbC044D90
	LEA	lbW044528(pc),A4
	MOVE.W	(A4)+,D0
	BMI.L	lbC044D72
;	BSR.L	lbC044662

	bsr.w	Right1
	move.w	D0,UPS_Voice2Vol(A5)

	MOVE.W	D0,$B8(A6)
lbC044D72	MOVE.W	(A4)+,D0
	BMI.L	lbC044D7C
	MOVE.W	D0,$B6(A6)
lbC044D7C	MOVE.W	(A4)+,D0
	BMI.L	lbC044D86
	MOVE.W	D0,$B4(A6)

	move.w	D0,UPS_Voice2Len(A5)
	move.w	-4(A4),UPS_Voice2Per(A5)

lbC044D86	MOVE.L	(A4)+,D0
	BMI.L	lbC044D90
	MOVE.L	D0,$B0(A6)

	move.l	D0,UPS_Voice2Adr(A5)

lbC044D90
;	TST.W	lbW007546
;	BPL.L	lbC044DCC
	LEA	lbW044568(pc),A4
	MOVE.W	(A4)+,D0
	BMI.L	lbC044DAE
;	BSR.L	lbC044662

	bsr.w	Right2
	move.w	D0,UPS_Voice3Vol(A5)

	MOVE.W	D0,$C8(A6)
lbC044DAE	MOVE.W	(A4)+,D0
	BMI.L	lbC044DB8
	MOVE.W	D0,$C6(A6)
lbC044DB8	MOVE.W	(A4)+,D0
	BMI.L	lbC044DC2
	MOVE.W	D0,$C4(A6)

	move.w	D0,UPS_Voice3Len(A5)
	move.w	-4(A4),UPS_Voice3Per(A5)

lbC044DC2	MOVE.L	(A4)+,D0
	BMI.L	lbC044DCC
	MOVE.L	D0,$C0(A6)

	move.l	D0,UPS_Voice3Adr(A5)

lbC044DCC
;	TST.W	lbW007548
;	BPL.L	lbC044E08
	LEA	lbW0445A8(pc),A4
	MOVE.W	(A4)+,D0
	BMI.L	lbC044DEA
;	BSR.L	lbC044662

	bsr.w	Left2
	move.w	D0,UPS_Voice4Vol(A5)

	MOVE.W	D0,$D8(A6)
lbC044DEA	MOVE.W	(A4)+,D0
	BMI.L	lbC044DF4
	MOVE.W	D0,$D6(A6)
lbC044DF4	MOVE.W	(A4)+,D0
	BMI.L	lbC044DFE
	MOVE.W	D0,$D4(A6)

	move.w	D0,UPS_Voice4Len(A5)
	move.w	-4(A4),UPS_Voice4Per(A5)

lbC044DFE	MOVE.L	(A4)+,D0
	BMI.L	lbC044E08
	MOVE.L	D0,$D0(A6)

	move.l	D0,UPS_Voice4Adr(A5)

lbC044E08
;	MOVE.W	#0,lbW044EC6
	MOVE.W	lbW044646(pc),D0
	OR.W	lbW044658(pc),D0
	BEQ.L	lbC044EA8
	MOVE.W	D0,$DFF096
;	MOVE.W	#$80,D1
;	BTST	#0,D0
;	BEQ.S	lbC044E3C
;	MOVE.W	lbW0444EA(pc),D2
;	CMP.W	D1,D2
;	BMI.S	lbC044E3C
;	MOVE.W	D2,D1
;lbC044E3C	BTST	#1,D0
;	BEQ.S	lbC044E4E
;	MOVE.W	lbW04452A(pc),D2
;	CMP.W	D1,D2
;	BMI.S	lbC044E4E
;	MOVE.W	D2,D1
;lbC044E4E	BTST	#2,D0
;	BEQ.S	lbC044E60
;	MOVE.W	lbW04456A(pc),D2
;	CMP.W	D1,D2
;	BMI.S	lbC044E60
;	MOVE.W	D2,D1
;lbC044E60	BTST	#3,D0
;	BEQ.S	lbC044E72
;	MOVE.W	lbW0445AA(pc),D2
;	CMP.W	D1,D2
;	BMI.S	lbC044E72
;	MOVE.W	D2,D1
;lbC044E72	LSR.W	#7,D1
;	ADDQ.W	#1,D1
;	CMPI.W	#2,D1
;	BPL.S	lbC044E7E
;	MOVEQ	#2,D1
;lbC044E7E	CMPI.W	#7,D1
;	BMI.S	lbC044E86
;	MOVEQ	#7,D1
;lbC044E86	MOVE.W	D1,D7
;	MOVE.W	D1,lbW044EC6
;	BSR.L	lbC0446CC

	bsr.w	DMAWait

	MOVE.W	lbW044648(pc),D0
	OR.W	lbW044658(pc),D0
	ORI.W	#$8000,D0
	MOVE.W	D0,$DFF096

	bsr.w	DMAWait

lbC044EA8	CLR.W	lbW044646
	CLR.W	lbW044648
	CLR.W	lbW044658
	TST.B	lbB04463E
	BNE.L	lbC044CBA
	RTS

;lbW044EC6	dc.w	0

lbC044EC8
;	MOVE.W	(A4),lbW04464A
	TST.L	(A6)
	BNE.S	lbC044ED8
	MOVE.W	$10(A6),$34(A6)
lbC044ED8	MOVE.L	D0,(A6)
	MOVEQ	#0,D2
	MOVE.B	2(A6),D2
	LSR.B	#4,D2
	MOVE.B	(A6),D0
	ANDI.B	#$F0,D0
	OR.B	D0,D2
	BEQ.L	lbC044F74
;	TST.W	(A4)
;	BMI.S	lbC044EF4
;	BNE.S	lbC044F06
;lbC044EF4	MOVE.W	$18(A4),8(A4)
;	MOVE.W	#$1F4,$10(A4)
;	MOVE.W	#$FFFF,0(A4)
lbC044F06	MOVEQ	#0,D3
	LEA	lbL0445B6(pc),A1
	MOVE.W	D2,D4
	SUBQ.W	#1,D2
	ASL.W	#2,D2
	ASL.W	#3,D4
	MOVE.L	0(A1,D2.W),4(A6)
	MOVE.W	0(A3,D4.W),8(A6)
	MOVE.W	0(A3,D4.W),$28(A6)
	MOVE.B	2(A3,D4.W),$12(A6)
	MOVE.B	3(A3,D4.W),$13(A6)
	MOVE.W	4(A3,D4.W),D3
	TST.W	D3
	BEQ.S	lbC044F60
	MOVE.L	4(A6),D2
	ASL.W	#1,D3
	ADD.L	D3,D2
	MOVE.L	D2,10(A6)
	MOVE.L	D2,$24(A6)
	MOVE.W	4(A3,D4.W),D0
	ADD.W	6(A3,D4.W),D0
	MOVE.W	D0,8(A6)
	MOVE.W	6(A3,D4.W),14(A6)
	BRA.S	lbC044F74

lbC044F60	MOVE.L	4(A6),D2
	ADD.L	D3,D2
	MOVE.L	D2,10(A6)
	MOVE.L	D2,$24(A6)
	MOVE.W	6(A3,D4.W),14(A6)
lbC044F74	MOVEQ	#0,D0
	MOVE.B	$13(A6),D0
	MOVE.W	D0,$32(A6)
	MOVE.W	(A6),D0
	ANDI.W	#$FFF,D0
	BNE.L	lbC044F8E
	BSR.L	lbC04551A
	RTS

lbC044F8E	MOVE.W	2(A6),D0
	ANDI.W	#$FF0,D0
	CMPI.W	#$E50,D0
	BEQ.S	lbC044FBC
	MOVE.B	2(A6),D0
	ANDI.B	#15,D0
	CMPI.B	#3,D0
	BEQ.S	lbC044FC2
	CMPI.B	#5,D0
	BEQ.S	lbC044FC2
	CMPI.B	#9,D0
	BNE.S	lbC044FCC
	BSR.L	lbC04551A
	BRA.S	lbC044FCC

lbC044FBC	BSR.L	lbC045614
	BRA.S	lbC044FCC

lbC044FC2	BSR.L	lbC0451EA
	BSR.L	lbC04551A
	RTS

lbC044FCC	MOVEM.L	D0/D1/A0/A1,-(SP)
	MOVE.W	(A6),D1
	ANDI.W	#$FFF,D1
	LEA	lbW04580E(PC),A1
	MOVEQ	#0,D0
	MOVEQ	#$24,D7
lbC044FDE	CMP.W	0(A1,D0.W),D1
	BCC.S	lbC044FEA
	ADDQ.L	#2,D0
	DBRA	D7,lbC044FDE
lbC044FEA	MOVEQ	#0,D1
	MOVE.B	$12(A6),D1
	MULU.W	#$48,D1
	ADDA.L	D1,A1
	MOVE.W	0(A1,D0.W),$10(A6)
	MOVEM.L	(SP)+,D0/D1/A0/A1
	MOVE.W	2(A6),D0
	ANDI.W	#$FF0,D0
	CMPI.W	#$ED0,D0
	BNE.L	lbC045016
	BSR.L	lbC04551A
	RTS

lbC045016
;	TST.W	lbW04464A
;	BPL.L	lbC04502A
	MOVE.W	$14(A6),D0
	OR.W	D0,lbW044646
lbC04502A	BTST	#2,$1E(A6)
	BNE.S	lbC045036
	CLR.B	$1B(A6)
lbC045036	BTST	#6,$1E(A6)
	BNE.S	lbC045042
	CLR.B	$1D(A6)
lbC045042	MOVE.L	4(A6),$38(A6)
	MOVE.W	8(A6),$36(A6)
	MOVE.W	$10(A6),$34(A6)
;	TST.W	lbW04464A
;	BPL.L	lbC045068
	MOVE.W	$14(A6),D0
	OR.W	D0,lbW044648
lbC045068	BSR.L	lbC04551A
	RTS

lbC04506E	CLR.W	$3E(A6)
	BSR.L	lbC045788
	MOVE.W	2(A6),D0
	ANDI.W	#$FFF,D0
	BEQ.S	lbC0450DA
	MOVE.B	2(A6),D0
	ANDI.B	#15,D0
	BEQ.S	lbC0450E2
	CMPI.B	#1,D0
	BEQ.L	lbC045158
	CMPI.B	#2,D0
	BEQ.L	lbC0451AA
	CMPI.B	#3,D0
	BEQ.L	lbC04524C
	CMPI.B	#4,D0
	BEQ.L	lbC0452DA
	CMPI.B	#5,D0
	BEQ.L	lbC045372
	CMPI.B	#6,D0
	BEQ.L	lbC04537A
	CMPI.B	#14,D0
	BEQ.L	lbC045556
	MOVE.W	$10(A6),$34(A6)
	CMPI.B	#7,D0
	BEQ.L	lbC045380
	CMPI.B	#10,D0
	BEQ.L	lbC045456
lbC0450D8	RTS

lbC0450DA	MOVE.W	$10(A6),$34(A6)
	RTS

lbC0450E2	MOVEQ	#0,D0
	MOVE.B	lbB04463B(pc),D0
	DIVS.W	#3,D0
	SWAP	D0
	CMPI.W	#0,D0
	BEQ.S	lbC045112
	CMPI.W	#2,D0
	BEQ.S	lbC045106
	MOVEQ	#0,D0
	MOVE.B	3(A6),D0
	LSR.B	#4,D0
	BRA.S	lbC045118

lbC045106	MOVEQ	#0,D0
	MOVE.B	3(A6),D0
	ANDI.B	#15,D0
	BRA.S	lbC045118

lbC045112	MOVE.W	$10(A6),D2
	BRA.S	lbC045142

lbC045118	ASL.W	#1,D0
	MOVEQ	#0,D1
	MOVE.B	$12(A6),D1
	MULU.W	#$48,D1
	LEA	lbW04580E(PC),A0
	ADDA.L	D1,A0
	MOVEQ	#0,D1
	MOVE.W	$10(A6),D1
	MOVEQ	#$24,D7
lbC045132	MOVE.W	0(A0,D0.W),D2
	CMP.W	(A0),D1
	BCC.S	lbC045142
	ADDQ.L	#2,A0
	DBRA	D7,lbC045132
	RTS

lbC045142	MOVE.W	D2,$34(A6)
	RTS

lbC045148	TST.B	lbB04463B
	BNE.S	lbC0450D8
	MOVE.B	#15,lbB044640
lbC045158	MOVEQ	#0,D0
	MOVE.B	3(A6),D0
	AND.B	lbB044640(pc),D0
	MOVE.B	#$FF,lbB044640
	SUB.W	D0,$10(A6)
	MOVE.W	$10(A6),D0
	ANDI.W	#$FFF,D0
	CMPI.W	#$71,D0
	BPL.S	lbC04518A
	ANDI.W	#$F000,$10(A6)
	ORI.W	#$71,$10(A6)
lbC04518A	MOVE.W	$10(A6),D0
	ANDI.W	#$FFF,D0
	MOVE.W	D0,$34(A6)
	RTS

lbC045198	TST.B	lbB04463B
	BNE.L	lbC0450D8
	MOVE.B	#15,lbB044640
lbC0451AA	CLR.W	D0
	MOVE.B	3(A6),D0
	AND.B	lbB044640(pc),D0
	MOVE.B	#$FF,lbB044640
	ADD.W	D0,$10(A6)
	MOVE.W	$10(A6),D0
	ANDI.W	#$FFF,D0
	CMPI.W	#$358,D0
	BMI.S	lbC0451DC
	ANDI.W	#$F000,$10(A6)
	ORI.W	#$358,$10(A6)
lbC0451DC	MOVE.W	$10(A6),D0
	ANDI.W	#$FFF,D0
	MOVE.W	D0,$34(A6)
	RTS

lbC0451EA	MOVE.L	A0,-(SP)
	MOVE.W	(A6),D2
	ANDI.W	#$FFF,D2
	MOVEQ	#0,D0
	MOVE.B	$12(A6),D0
	MULU.W	#$4A,D0
	LEA	lbW04580E(PC),A0
	ADDA.L	D0,A0
	MOVEQ	#0,D0
lbC045204	CMP.W	0(A0,D0.W),D2
	BCC.S	lbC045214
	ADDQ.W	#2,D0
	CMPI.W	#$4A,D0
	BCS.S	lbC045204
	MOVEQ	#$46,D0
lbC045214	MOVE.B	$12(A6),D2
	ANDI.B	#8,D2
	BEQ.S	lbC045224
	TST.W	D0
	BEQ.S	lbC045224
	SUBQ.W	#2,D0
lbC045224	MOVE.W	0(A0,D0.W),D2
	MOVEA.L	(SP)+,A0
	MOVE.W	D2,$18(A6)
	MOVE.W	$10(A6),D0
	CLR.B	$16(A6)
	CMP.W	D0,D2
	BEQ.S	lbC045246
	BGE.L	lbC0450D8
	MOVE.B	#1,$16(A6)
	RTS

lbC045246	CLR.W	$18(A6)
	RTS

lbC04524C	MOVE.B	3(A6),D0
	BEQ.S	lbC04525A
	MOVE.B	D0,$17(A6)
	CLR.B	3(A6)
lbC04525A	TST.W	$18(A6)
	BEQ.L	lbC0450D8
	MOVEQ	#0,D0
	MOVE.B	$17(A6),D0
	TST.B	$16(A6)
	BNE.S	lbC045288
	ADD.W	D0,$10(A6)
	MOVE.W	$18(A6),D0
	CMP.W	$10(A6),D0
	BGT.S	lbC0452A0
	MOVE.W	$18(A6),$10(A6)
	CLR.W	$18(A6)
	BRA.S	lbC0452A0

lbC045288	SUB.W	D0,$10(A6)
	MOVE.W	$18(A6),D0
	CMP.W	$10(A6),D0
	BLT.S	lbC0452A0
	MOVE.W	$18(A6),$10(A6)
	CLR.W	$18(A6)
lbC0452A0	MOVE.W	$10(A6),D2
	MOVE.B	$1F(A6),D0
	ANDI.B	#15,D0
	BEQ.S	lbC0452D4
	MOVEQ	#0,D0
	MOVE.B	$12(A6),D0
	MULU.W	#$48,D0
	LEA	lbW04580E(PC),A0
	ADDA.L	D0,A0
	MOVEQ	#0,D0
lbC0452C0	CMP.W	0(A0,D0.W),D2
	BCC.S	lbC0452D0
	ADDQ.W	#2,D0
	CMPI.W	#$48,D0
	BCS.S	lbC0452C0
	MOVEQ	#$46,D0
lbC0452D0	MOVE.W	0(A0,D0.W),D2
lbC0452D4	MOVE.W	D2,$34(A6)
	RTS

lbC0452DA	MOVE.B	3(A6),D0
	BEQ.S	lbC045304
	MOVE.B	$1A(A6),D2
	ANDI.B	#15,D0
	BEQ.S	lbC0452F0
	ANDI.B	#$F0,D2
	OR.B	D0,D2
lbC0452F0	MOVE.B	3(A6),D0
	ANDI.B	#$F0,D0
	BEQ.S	lbC045300
	ANDI.B	#15,D2
	OR.B	D0,D2
lbC045300	MOVE.B	D2,$1A(A6)
lbC045304	MOVE.B	$1B(A6),D0
	LEA	lbW0457EE(PC),A4
	LSR.W	#2,D0
	ANDI.W	#$1F,D0
	MOVEQ	#0,D2
	MOVE.B	$1E(A6),D2
	ANDI.B	#3,D2
	BEQ.S	lbC04533E
	LSL.B	#3,D0
	CMPI.B	#1,D2
	BEQ.S	lbC04532C
	MOVE.B	#$FF,D2
	BRA.S	lbC045342

lbC04532C	TST.B	$1B(A6)
	BPL.S	lbC04533A
	MOVE.B	#$FF,D2
	SUB.B	D0,D2
	BRA.S	lbC045342

lbC04533A	MOVE.B	D0,D2
	BRA.S	lbC045342

lbC04533E	MOVE.B	0(A4,D0.W),D2
lbC045342	MOVE.B	$1A(A6),D0
	ANDI.W	#15,D0
	MULU.W	D0,D2
	LSR.W	#7,D2
	MOVE.W	$10(A6),D0
	TST.B	$1B(A6)
	BMI.S	lbC04535C
	ADD.W	D2,D0
	BRA.S	lbC04535E

lbC04535C	SUB.W	D2,D0
lbC04535E	MOVE.W	D0,$34(A6)
	MOVE.B	$1A(A6),D0
	LSR.W	#2,D0
	ANDI.W	#$3C,D0
	ADD.B	D0,$1B(A6)
	RTS

lbC045372	BSR.L	lbC04525A
	BRA.L	lbC045456

lbC04537A	BSR.S	lbC045304
	BRA.L	lbC045456

lbC045380	MOVE.B	3(A6),D0
	BEQ.S	lbC0453AA
	MOVE.B	$1C(A6),D2
	ANDI.B	#15,D0
	BEQ.S	lbC045396
	ANDI.B	#$F0,D2
	OR.B	D0,D2
lbC045396	MOVE.B	3(A6),D0
	ANDI.B	#$F0,D0
	BEQ.S	lbC0453A6
	ANDI.B	#15,D2
	OR.B	D0,D2
lbC0453A6	MOVE.B	D2,$1C(A6)
lbC0453AA	MOVE.B	$1D(A6),D0
	LEA	lbW0457EE(PC),A4
	LSR.W	#2,D0
	ANDI.W	#$1F,D0
	MOVEQ	#0,D2
	MOVE.B	$1E(A6),D2
	LSR.B	#4,D2
	ANDI.B	#3,D2
	BEQ.S	lbC0453E6
	LSL.B	#3,D0
	CMPI.B	#1,D2
	BEQ.S	lbC0453D4
	MOVE.B	#$FF,D2
	BRA.S	lbC0453EA

lbC0453D4	TST.B	$1B(A6)
	BPL.S	lbC0453E2
	MOVE.B	#$FF,D2
	SUB.B	D0,D2
	BRA.S	lbC0453EA

lbC0453E2	MOVE.B	D0,D2
	BRA.S	lbC0453EA

lbC0453E6	MOVE.B	0(A4,D0.W),D2
lbC0453EA	MOVE.B	$1C(A6),D0
	ANDI.W	#15,D0
	MULU.W	D0,D2
	LSR.W	#6,D2
	MOVEQ	#0,D0
	MOVE.B	$13(A6),D0
	TST.B	$1D(A6)
	BMI.S	lbC045406
	ADD.W	D2,D0
	BRA.S	lbC045408

lbC045406	SUB.W	D2,D0
lbC045408	BPL.S	lbC04540C
	CLR.W	D0
lbC04540C	CMPI.W	#$40,D0
	BLS.S	lbC045416
	MOVE.W	#$40,D0
lbC045416	MOVE.W	D0,$32(A6)
	MOVE.B	$1C(A6),D0
	LSR.W	#2,D0
	ANDI.W	#$3C,D0
	ADD.B	D0,$1D(A6)
	RTS

lbC04542A	MOVEQ	#0,D0
	MOVE.B	3(A6),D0
	BEQ.S	lbC045436
	MOVE.B	D0,$20(A6)
lbC045436	MOVE.B	$20(A6),D0
	LSL.W	#7,D0
	CMP.W	8(A6),D0
	BGE.S	lbC04544E
	SUB.W	D0,8(A6)
	LSL.W	#1,D0
	ADD.L	D0,4(A6)
	RTS

lbC04544E	MOVE.W	#1,8(A6)
	RTS

lbC045456	MOVEQ	#0,D0
	MOVE.B	3(A6),D0
	LSR.B	#4,D0
	TST.B	D0
	BEQ.S	lbC04547E
lbC045462	ADD.B	D0,$13(A6)
	CMPI.B	#$40,$13(A6)
	BMI.S	lbC045474
	MOVE.B	#$40,$13(A6)
lbC045474	MOVE.B	$13(A6),D0
	MOVE.W	D0,$32(A6)
	RTS

lbC04547E	MOVEQ	#0,D0
	MOVE.B	3(A6),D0
	ANDI.B	#15,D0
lbC045488	SUB.B	D0,$13(A6)
	BPL.S	lbC045492
	CLR.B	$13(A6)
lbC045492	MOVE.B	$13(A6),D0
	MOVE.W	D0,$32(A6)
	RTS

lbC04549C	MOVE.B	3(A6),D0
	SUBQ.B	#1,D0
	MOVE.B	D0,lbB04463C

	bsr.w	SongEnd

lbC0454A8	CLR.B	lbB04463D
	ST	lbB04463E
	RTS

lbC0454B6	MOVEQ	#0,D0
	MOVE.B	3(A6),D0
	CMPI.B	#$40,D0
	BLS.S	lbC0454C4
	MOVEQ	#$40,D0
lbC0454C4	MOVE.B	D0,$13(A6)
	MOVE.W	D0,$32(A6)
	RTS

lbC0454CE	MOVEQ	#0,D0
	MOVE.B	3(A6),D0
	MOVE.L	D0,D2
	LSR.B	#4,D0
	MULU.W	#10,D0
	ANDI.B	#15,D2
	ADD.B	D2,D0
	CMPI.B	#$3F,D0
	BHI.S	lbC0454A8
	MOVE.B	D0,lbB04463D
	ST	lbB04463E
	RTS

lbC0454F6	MOVE.B	3(A6),D0
	BEQ.L	lbC04550C
	CLR.B	lbB04463B
	MOVE.B	D0,lbB04463A
	RTS

lbC04550C
;	MOVEM.L	D0-D7/A0-A4/A6,-(SP)
;	BSR.L	lbC045EC4
;	MOVEM.L	(SP)+,D0-D7/A0-A4/A6
	RTS

lbC04551A	CLR.W	$3E(A6)
	BSR.L	lbC045788
	MOVE.B	2(A6),D0
	ANDI.B	#15,D0
	CMPI.B	#9,D0
	BEQ.L	lbC04542A
	CMPI.B	#11,D0
	BEQ.L	lbC04549C
	CMPI.B	#13,D0
	BEQ.S	lbC0454CE
	CMPI.B	#14,D0
	BEQ.S	lbC045556
	CMPI.B	#15,D0
	BEQ.S	lbC0454F6
	CMPI.B	#12,D0
	BEQ.L	lbC0454B6
	RTS

lbC045556	MOVE.B	3(A6),D0
	ANDI.B	#$F0,D0
	LSR.B	#4,D0
	BEQ.S	lbC0455D2
	CMPI.B	#1,D0
	BEQ.L	lbC045148
	CMPI.B	#2,D0
	BEQ.L	lbC045198
	CMPI.B	#3,D0
	BEQ.S	lbC0455EC
	CMPI.B	#4,D0
	BEQ.L	lbC045600
	CMPI.B	#5,D0
	BEQ.L	lbC045614
	CMPI.B	#6,D0
	BEQ.L	lbC045622
	CMPI.B	#7,D0
	BEQ.L	lbC045666
	CMPI.B	#9,D0
	BEQ.L	lbC04567C
	CMPI.B	#10,D0
	BEQ.L	lbC0456CC
	CMPI.B	#11,D0
	BEQ.L	lbC0456E4
	CMPI.B	#12,D0
	BEQ.L	lbC0456FC
	CMPI.B	#13,D0
	BEQ.L	lbC04571C
	CMPI.B	#14,D0
	BEQ.L	lbC04573C
	CMPI.B	#15,D0
	BEQ.L	lbC045764
	RTS

lbC0455D2	MOVE.B	3(A6),D0
	ANDI.B	#1,D0
	ASL.B	#1,D0
	ANDI.B	#$FD,$BFE001
	OR.B	D0,$BFE001
	RTS

lbC0455EC	MOVE.B	3(A6),D0
	ANDI.B	#15,D0
	ANDI.B	#$F0,$1F(A6)
	OR.B	D0,$1F(A6)
	RTS

lbC045600	MOVE.B	3(A6),D0
	ANDI.B	#15,D0
	ANDI.B	#$F0,$1E(A6)
	OR.B	D0,$1E(A6)
	RTS

lbC045614	MOVE.B	3(A6),D0
	ANDI.B	#15,D0
	MOVE.B	D0,$12(A6)
	RTS

lbC045622	TST.B	lbB04463B
	BNE.L	lbC0450D8
	MOVE.B	3(A6),D0
	ANDI.B	#15,D0
	BEQ.S	lbC04565A
	TST.B	$22(A6)
	BEQ.S	lbC045654
	SUBQ.B	#1,$22(A6)
	BEQ.L	lbC0450D8
lbC045644	MOVE.B	$21(A6),lbB04463D
	ST	lbB04463F
	RTS

lbC045654	MOVE.B	D0,$22(A6)
	BRA.S	lbC045644

lbC04565A	MOVE.W	lbW044644(pc),D0
	MOVE.B	D0,$21(A6)
	RTS

lbC045666	MOVE.B	3(A6),D0
	ANDI.B	#15,D0
	LSL.B	#4,D0
	ANDI.B	#15,$1E(A6)
	OR.B	D0,$1E(A6)
	RTS

lbC04567C	MOVE.L	D1,-(SP)
	MOVEQ	#0,D0
	MOVE.B	3(A6),D0
	ANDI.B	#15,D0
	BEQ.S	lbC0456C8
	MOVEQ	#0,D1
	MOVE.B	lbB04463B(pc),D1
	BNE.S	lbC0456A4
	MOVE.W	(A6),D1
	ANDI.W	#$FFF,D1
	BNE.S	lbC0456C8
	MOVEQ	#0,D1
	MOVE.B	lbB04463B(pc),D1
lbC0456A4	DIVU.W	D0,D1
	SWAP	D1
	TST.W	D1
	BNE.S	lbC0456C8
lbC0456AC	MOVE.W	#1,$3E(A6)
	MOVE.L	4(A6),$38(A6)
	MOVE.W	8(A6),$36(A6)
	MOVE.W	$14(A6),D0
	OR.W	D0,lbW044658
lbC0456C8	MOVE.L	(SP)+,D1
	RTS

lbC0456CC	TST.B	lbB04463B
	BNE.L	lbC0450D8
	MOVEQ	#0,D0
	MOVE.B	3(A6),D0
	ANDI.B	#15,D0
	BRA.L	lbC045462

lbC0456E4	TST.B	lbB04463B
	BNE.L	lbC0450D8
	MOVEQ	#0,D0
	MOVE.B	3(A6),D0
	ANDI.B	#15,D0
	BRA.L	lbC045488

lbC0456FC	MOVEQ	#0,D0
	MOVE.B	3(A6),D0
	ANDI.B	#15,D0
	CMP.B	lbB04463B(pc),D0
	BNE.L	lbC0450D8
	CLR.B	$13(A6)
	MOVE.W	#0,$32(A6)
	RTS

lbC04571C	MOVEQ	#0,D0
	MOVE.B	3(A6),D0
	ANDI.B	#15,D0
	CMP.B	lbB04463B(pc),D0
	BNE.L	lbC0450D8
	MOVE.W	(A6),D0
	BEQ.L	lbC0450D8
	MOVE.L	D1,-(SP)
	BRA.L	lbC0456AC

lbC04573C	TST.B	lbB04463B
	BNE.L	lbC0450D8
	MOVEQ	#0,D0
	MOVE.B	3(A6),D0
	ANDI.B	#15,D0
	TST.B	lbB044642
	BNE.L	lbC0450D8
	ADDQ.B	#1,D0
	MOVE.B	D0,lbB044641
	RTS

lbC045764	TST.B	lbB04463B
	BNE.L	lbC0450D8
	MOVE.B	3(A6),D0
	ANDI.B	#15,D0
	LSL.B	#4,D0
	ANDI.B	#15,$1F(A6)
	OR.B	D0,$1F(A6)
	TST.B	D0
	BEQ.L	lbC0450D8
lbC045788	MOVEM.L	D1/A0,-(SP)
	MOVEQ	#0,D0
	MOVE.B	$1F(A6),D0
	LSR.B	#4,D0
	BEQ.S	lbC0457D8
	LEA	lbW0457DE(PC),A0
	MOVE.B	0(A0,D0.W),D0
	ADD.B	D0,$23(A6)
	BTST	#7,$23(A6)
	BEQ.S	lbC0457D8
	CLR.B	$23(A6)
	CLR.B	$23(A6)
	MOVE.L	10(A6),D0
	MOVEQ	#0,D1
	MOVE.W	14(A6),D1
	ADD.L	D1,D0
	ADD.L	D1,D0
	MOVEA.L	$24(A6),A0
	ADDQ.L	#1,A0
	CMPA.L	D0,A0
	BCS.S	lbC0457CE
	MOVEA.L	10(A6),A0
lbC0457CE	MOVE.L	A0,$24(A6)
	MOVEQ	#-1,D0
	SUB.B	(A0),D0
	MOVE.B	D0,(A0)
lbC0457D8	MOVEM.L	(SP)+,D1/A0
	RTS

lbW0457DE	dc.w	5
	dc.w	$607
	dc.w	$80A
	dc.w	$B0D
	dc.w	$1013
	dc.w	$161A
	dc.w	$202B
	dc.w	$4080
lbW0457EE	dc.w	$18
	dc.w	$314A
	dc.w	$6178
	dc.w	$8DA1
	dc.w	$B4C5
	dc.w	$D4E0
	dc.w	$EBF4
	dc.w	$FAFD
	dc.w	$FFFD
	dc.w	$FAF4
	dc.w	$EBE0
	dc.w	$D4C5
	dc.w	$B4A1
	dc.w	$8D78
	dc.w	$614A
	dc.w	$3118
lbW04580E	dc.w	$358
	dc.w	$328
	dc.w	$2FA
	dc.w	$2D0
	dc.w	$2A6
	dc.w	$280
	dc.w	$25C
	dc.w	$23A
	dc.w	$21A
	dc.w	$1FC
	dc.w	$1E0
	dc.w	$1C5
	dc.w	$1AC
	dc.w	$194
	dc.w	$17D
	dc.w	$168
	dc.w	$153
	dc.w	$140
	dc.w	$12E
	dc.w	$11D
	dc.w	$10D
	dc.w	$FE
	dc.w	$F0
	dc.w	$E2
	dc.w	$D6
	dc.w	$CA
	dc.w	$BE
	dc.w	$B4
	dc.w	$AA
	dc.w	$A0
	dc.w	$97
	dc.w	$8F
	dc.w	$87
	dc.w	$7F
	dc.w	$78
	dc.w	$71
	dc.w	$352
	dc.w	$322
	dc.w	$2F5
	dc.w	$2CB
	dc.w	$2A2
	dc.w	$27D
	dc.w	$259
	dc.w	$237
	dc.w	$217
	dc.w	$1F9
	dc.w	$1DD
	dc.w	$1C2
	dc.w	$1A9
	dc.w	$191
	dc.w	$17B
	dc.w	$165
	dc.w	$151
	dc.w	$13E
	dc.w	$12C
	dc.w	$11C
	dc.w	$10C
	dc.w	$FD
	dc.w	$EF
	dc.w	$E1
	dc.w	$D5
	dc.w	$C9
	dc.w	$BD
	dc.w	$B3
	dc.w	$A9
	dc.w	$9F
	dc.w	$96
	dc.w	$8E
	dc.w	$86
	dc.w	$7E
	dc.w	$77
	dc.w	$71
	dc.w	$34C
	dc.w	$31C
	dc.w	$2F0
	dc.w	$2C5
	dc.w	$29E
	dc.w	$278
	dc.w	$255
	dc.w	$233
	dc.w	$214
	dc.w	$1F6
	dc.w	$1DA
	dc.w	$1BF
	dc.w	$1A6
	dc.w	$18E
	dc.w	$178
	dc.w	$163
	dc.w	$14F
	dc.w	$13C
	dc.w	$12A
	dc.w	$11A
	dc.w	$10A
	dc.w	$FB
	dc.w	$ED
	dc.w	$E0
	dc.w	$D3
	dc.w	$C7
	dc.w	$BC
	dc.w	$B1
	dc.w	$A7
	dc.w	$9E
	dc.w	$95
	dc.w	$8D
	dc.w	$85
	dc.w	$7D
	dc.w	$76
	dc.w	$70
	dc.w	$346
	dc.w	$317
	dc.w	$2EA
	dc.w	$2C0
	dc.w	$299
	dc.w	$274
	dc.w	$250
	dc.w	$22F
	dc.w	$210
	dc.w	$1F2
	dc.w	$1D6
	dc.w	$1BC
	dc.w	$1A3
	dc.w	$18B
	dc.w	$175
	dc.w	$160
	dc.w	$14C
	dc.w	$13A
	dc.w	$128
	dc.w	$118
	dc.w	$108
	dc.w	$F9
	dc.w	$EB
	dc.w	$DE
	dc.w	$D1
	dc.w	$C6
	dc.w	$BB
	dc.w	$B0
	dc.w	$A6
	dc.w	$9D
	dc.w	$94
	dc.w	$8C
	dc.w	$84
	dc.w	$7D
	dc.w	$76
	dc.w	$6F
	dc.w	$340
	dc.w	$311
	dc.w	$2E5
	dc.w	$2BB
	dc.w	$294
	dc.w	$26F
	dc.w	$24C
	dc.w	$22B
	dc.w	$20C
	dc.w	$1EF
	dc.w	$1D3
	dc.w	$1B9
	dc.w	$1A0
	dc.w	$188
	dc.w	$172
	dc.w	$15E
	dc.w	$14A
	dc.w	$138
	dc.w	$126
	dc.w	$116
	dc.w	$106
	dc.w	$F7
	dc.w	$E9
	dc.w	$DC
	dc.w	$D0
	dc.w	$C4
	dc.w	$B9
	dc.w	$AF
	dc.w	$A5
	dc.w	$9C
	dc.w	$93
	dc.w	$8B
	dc.w	$83
	dc.w	$7C
	dc.w	$75
	dc.w	$6E
	dc.w	$33A
	dc.w	$30B
	dc.w	$2E0
	dc.w	$2B6
	dc.w	$28F
	dc.w	$26B
	dc.w	$248
	dc.w	$227
	dc.w	$208
	dc.w	$1EB
	dc.w	$1CF
	dc.w	$1B5
	dc.w	$19D
	dc.w	$186
	dc.w	$170
	dc.w	$15B
	dc.w	$148
	dc.w	$135
	dc.w	$124
	dc.w	$114
	dc.w	$104
	dc.w	$F5
	dc.w	$E8
	dc.w	$DB
	dc.w	$CE
	dc.w	$C3
	dc.w	$B8
	dc.w	$AE
	dc.w	$A4
	dc.w	$9B
	dc.w	$92
	dc.w	$8A
	dc.w	$82
	dc.w	$7B
	dc.w	$74
	dc.w	$6D
	dc.w	$334
	dc.w	$306
	dc.w	$2DA
	dc.w	$2B1
	dc.w	$28B
	dc.w	$266
	dc.w	$244
	dc.w	$223
	dc.w	$204
	dc.w	$1E7
	dc.w	$1CC
	dc.w	$1B2
	dc.w	$19A
	dc.w	$183
	dc.w	$16D
	dc.w	$159
	dc.w	$145
	dc.w	$133
	dc.w	$122
	dc.w	$112
	dc.w	$102
	dc.w	$F4
	dc.w	$E6
	dc.w	$D9
	dc.w	$CD
	dc.w	$C1
	dc.w	$B7
	dc.w	$AC
	dc.w	$A3
	dc.w	$9A
	dc.w	$91
	dc.w	$89
	dc.w	$81
	dc.w	$7A
	dc.w	$73
	dc.w	$6D
	dc.w	$32E
	dc.w	$300
	dc.w	$2D5
	dc.w	$2AC
	dc.w	$286
	dc.w	$262
	dc.w	$23F
	dc.w	$21F
	dc.w	$201
	dc.w	$1E4
	dc.w	$1C9
	dc.w	$1AF
	dc.w	$197
	dc.w	$180
	dc.w	$16B
	dc.w	$156
	dc.w	$143
	dc.w	$131
	dc.w	$120
	dc.w	$110
	dc.w	$100
	dc.w	$F2
	dc.w	$E4
	dc.w	$D8
	dc.w	$CC
	dc.w	$C0
	dc.w	$B5
	dc.w	$AB
	dc.w	$A1
	dc.w	$98
	dc.w	$90
	dc.w	$88
	dc.w	$80
	dc.w	$79
	dc.w	$72
	dc.w	$6C
	dc.w	$38B
	dc.w	$358
	dc.w	$328
	dc.w	$2FA
	dc.w	$2D0
	dc.w	$2A6
	dc.w	$280
	dc.w	$25C
	dc.w	$23A
	dc.w	$21A
	dc.w	$1FC
	dc.w	$1E0
	dc.w	$1C5
	dc.w	$1AC
	dc.w	$194
	dc.w	$17D
	dc.w	$168
	dc.w	$153
	dc.w	$140
	dc.w	$12E
	dc.w	$11D
	dc.w	$10D
	dc.w	$FE
	dc.w	$F0
	dc.w	$E2
	dc.w	$D6
	dc.w	$CA
	dc.w	$BE
	dc.w	$B4
	dc.w	$AA
	dc.w	$A0
	dc.w	$97
	dc.w	$8F
	dc.w	$87
	dc.w	$7F
	dc.w	$78
	dc.w	$384
	dc.w	$352
	dc.w	$322
	dc.w	$2F5
	dc.w	$2CB
	dc.w	$2A3
	dc.w	$27C
	dc.w	$259
	dc.w	$237
	dc.w	$217
	dc.w	$1F9
	dc.w	$1DD
	dc.w	$1C2
	dc.w	$1A9
	dc.w	$191
	dc.w	$17B
	dc.w	$165
	dc.w	$151
	dc.w	$13E
	dc.w	$12C
	dc.w	$11C
	dc.w	$10C
	dc.w	$FD
	dc.w	$EE
	dc.w	$E1
	dc.w	$D4
	dc.w	$C8
	dc.w	$BD
	dc.w	$B3
	dc.w	$A9
	dc.w	$9F
	dc.w	$96
	dc.w	$8E
	dc.w	$86
	dc.w	$7E
	dc.w	$77
	dc.w	$37E
	dc.w	$34C
	dc.w	$31C
	dc.w	$2F0
	dc.w	$2C5
	dc.w	$29E
	dc.w	$278
	dc.w	$255
	dc.w	$233
	dc.w	$214
	dc.w	$1F6
	dc.w	$1DA
	dc.w	$1BF
	dc.w	$1A6
	dc.w	$18E
	dc.w	$178
	dc.w	$163
	dc.w	$14F
	dc.w	$13C
	dc.w	$12A
	dc.w	$11A
	dc.w	$10A
	dc.w	$FB
	dc.w	$ED
	dc.w	$DF
	dc.w	$D3
	dc.w	$C7
	dc.w	$BC
	dc.w	$B1
	dc.w	$A7
	dc.w	$9E
	dc.w	$95
	dc.w	$8D
	dc.w	$85
	dc.w	$7D
	dc.w	$76
	dc.w	$377
	dc.w	$346
	dc.w	$317
	dc.w	$2EA
	dc.w	$2C0
	dc.w	$299
	dc.w	$274
	dc.w	$250
	dc.w	$22F
	dc.w	$210
	dc.w	$1F2
	dc.w	$1D6
	dc.w	$1BC
	dc.w	$1A3
	dc.w	$18B
	dc.w	$175
	dc.w	$160
	dc.w	$14C
	dc.w	$13A
	dc.w	$128
	dc.w	$118
	dc.w	$108
	dc.w	$F9
	dc.w	$EB
	dc.w	$DE
	dc.w	$D1
	dc.w	$C6
	dc.w	$BB
	dc.w	$B0
	dc.w	$A6
	dc.w	$9D
	dc.w	$94
	dc.w	$8C
	dc.w	$84
	dc.w	$7D
	dc.w	$76
	dc.w	$371
	dc.w	$340
	dc.w	$311
	dc.w	$2E5
	dc.w	$2BB
	dc.w	$294
	dc.w	$26F
	dc.w	$24C
	dc.w	$22B
	dc.w	$20C
	dc.w	$1EE
	dc.w	$1D3
	dc.w	$1B9
	dc.w	$1A0
	dc.w	$188
	dc.w	$172
	dc.w	$15E
	dc.w	$14A
	dc.w	$138
	dc.w	$126
	dc.w	$116
	dc.w	$106
	dc.w	$F7
	dc.w	$E9
	dc.w	$DC
	dc.w	$D0
	dc.w	$C4
	dc.w	$B9
	dc.w	$AF
	dc.w	$A5
	dc.w	$9C
	dc.w	$93
	dc.w	$8B
	dc.w	$83
	dc.w	$7B
	dc.w	$75
	dc.w	$36B
	dc.w	$33A
	dc.w	$30B
	dc.w	$2E0
	dc.w	$2B6
	dc.w	$28F
	dc.w	$26B
	dc.w	$248
	dc.w	$227
	dc.w	$208
	dc.w	$1EB
	dc.w	$1CF
	dc.w	$1B5
	dc.w	$19D
	dc.w	$186
	dc.w	$170
	dc.w	$15B
	dc.w	$148
	dc.w	$135
	dc.w	$124
	dc.w	$114
	dc.w	$104
	dc.w	$F5
	dc.w	$E8
	dc.w	$DB
	dc.w	$CE
	dc.w	$C3
	dc.w	$B8
	dc.w	$AE
	dc.w	$A4
	dc.w	$9B
	dc.w	$92
	dc.w	$8A
	dc.w	$82
	dc.w	$7B
	dc.w	$74
	dc.w	$364
	dc.w	$334
	dc.w	$306
	dc.w	$2DA
	dc.w	$2B1
	dc.w	$28B
	dc.w	$266
	dc.w	$244
	dc.w	$223
	dc.w	$204
	dc.w	$1E7
	dc.w	$1CC
	dc.w	$1B2
	dc.w	$19A
	dc.w	$183
	dc.w	$16D
	dc.w	$159
	dc.w	$145
	dc.w	$133
	dc.w	$122
	dc.w	$112
	dc.w	$102
	dc.w	$F4
	dc.w	$E6
	dc.w	$D9
	dc.w	$CD
	dc.w	$C1
	dc.w	$B7
	dc.w	$AC
	dc.w	$A3
	dc.w	$9A
	dc.w	$91
	dc.w	$89
	dc.w	$81
	dc.w	$7A
	dc.w	$73
	dc.w	$35E
	dc.w	$32E
	dc.w	$300
	dc.w	$2D5
	dc.w	$2AC
	dc.w	$286
	dc.w	$262
	dc.w	$23F
	dc.w	$21F
	dc.w	$201
	dc.w	$1E4
	dc.w	$1C9
	dc.w	$1AF
	dc.w	$197
	dc.w	$180
	dc.w	$16B
	dc.w	$156
	dc.w	$143
	dc.w	$131
	dc.w	$120
	dc.w	$110
	dc.w	$100
	dc.w	$F2
	dc.w	$E4
	dc.w	$D8
	dc.w	$CB
	dc.w	$C0
	dc.w	$B5
	dc.w	$AB
	dc.w	$A1
	dc.w	$98
	dc.w	$90
	dc.w	$88
	dc.w	$80
	dc.w	$79
	dc.w	$72

;	MOVE.L	A0,-(SP)
;	MOVE.L	A0,D1
;	MOVEA.L	(SP)+,A0
;	ADDA.L	lbL0444AE,A0
;	RTS

;	MOVE.L	A0,D1
;	MOVE.L	A0,-(SP)
;	MOVEA.L	(SP)+,A0
;	RTS

;lbC045CA4	LEA	lbL0443A6,A3
;	MOVEA.L	lbL0444A6,A1
;	MOVEQ	#0,D7
;lbC045CB2	MOVE.L	A0,(A3)+
;	MOVEQ	#0,D1
;	MOVE.W	0(A1),D1
;	ADD.L	D1,D1
;	ADDA.L	D1,A0
;	ADDA.W	#8,A1
;	ADDQ.W	#1,D7
;	CMPI.W	#$1F,D7
;	BNE.L	lbC045CB2
;	RTS

;lbC045CCE	LEA	lbL0443A6,A0
;	LEA	lbL044426,A1
;	MOVE.W	#$1F,D7
;lbC045CDE	MOVE.L	(A0)+,(A1)+
;	DBRA	D7,lbC045CDE
;	MOVE.L	lbL0444A6,lbL0443A2
;	RTS

;lbC045EC4	TST.W	lbW0444B4
;	BEQ.S	lbC045EE0
;	CLR.W	lbW0444B4
;	MOVEM.L	D0-D7/A0-A4/A6,-(SP)
;	JSR	lbC04491A
;	MOVEM.L	(SP)+,D0-D7/A0-A4/A6
;lbC045EE0	MOVE.W	#15,$96(A6)
;	ORI.B	#2,$BFE001
;	JSR	lbC0074AC
;	RTS

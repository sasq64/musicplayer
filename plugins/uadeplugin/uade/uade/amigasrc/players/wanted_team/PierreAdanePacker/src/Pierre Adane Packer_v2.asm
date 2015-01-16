	******************************************************
	**** Pierre Adane Packer replayer for EaglePlayer ****
	****        all adaptions by Wanted Team,	  ****
	****      DeliTracker compatible (?) version	  ****
	******************************************************

	incdir	"dh2:include/"
	include 'misc/eagleplayer2.01.i'

	SECTION	Player,CODE

	PLAYERHEADER Tags

	dc.b	'$VER: Pierre Adane Packer player module V1.1 (22 Dec 2001)',0
	even

Tags
	dc.l	DTP_PlayerVersion,2
	dc.l	EP_PlayerVersion,9
	dc.l	DTP_RequestDTVersion,DELIVERSION
	dc.l	DTP_PlayerName,PlayerName
	dc.l	DTP_Creator,Creator
	dc.l	DTP_Check2,Check2
	dc.l	DTP_Interrupt,Interrupt
	dc.l	DTP_InitPlayer,InitPlayer
	dc.l	DTP_EndPlayer,EndPlayer
	dc.l	DTP_InitSound,InitSound
	dc.l	DTP_EndSound,EndSound
	dc.l	DTP_ExtLoad,ExtLoad
	dc.l	EP_Get_ModuleInfo,Get_ModuleInfo
	dc.l	DTP_Volume,SetVolume
	dc.l	DTP_Balance,SetBalance
	dc.l	EP_Voices,SetVoices
	dc.l	EP_StructInit,StructInit
	dc.l	EP_GetPositionNr,GetPosition
	dc.l	DTP_NextPatt,NextPattern
	dc.l	DTP_PrevPatt,BackPattern
	dc.l	EP_SampleInit,SampleInit
	dc.l	EP_Save,Save
	dc.l	EP_Flags,EPB_Save!EPB_Volume!EPB_Balance!EPB_ModuleInfo!EPB_Voices!EPB_SampleInfo!EPB_Songend!EPB_Analyzer!EPB_Packable!EPB_Restart!EPB_PrevPatt!EPB_NextPatt
	dc.l	0

PlayerName
	dc.b	'Pierre Adane Packer',0
Creator
	dc.b	'(c) 1990 by Pierre Adane,',10
	dc.b	'adapted by Mr.Larmer/Wanted Team',0
Prefix
	dc.b	"PAP.",0
SampleName
	dc.b	'SMP.set',0
SMP
	dc.b	'SMP.',0
	even
SamplesPtr
	dc.l	0
ModulePtr
	dc.l	0
EagleBase
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
******************************* EP_SampleInit *****************************
***************************************************************************

SampleInit
	moveq	#EPR_NotEnoughMem,D7
	lea	EPG_SampleInfoStructure(A5),A3
	move.l	ModulePtr(PC),D0
	beq.b	return
	move.l	D0,A2

	move.l	InfoBuffer+Samples(PC),D5
	subq.l	#1,D5
	addq.l	#8,A2
	move.l	SamplesPtr(PC),A1
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

NextPattern
	move.w	lbW0004D4(PC),D0
	lsr.w	#1,D0
	addq.w	#1,D0
	cmp.w	InfoBuffer+Length+2(PC),D0
	beq.b	MaxPos
	lea	lbW0003C2(PC),A2
	clr.w	lbW0004D6
	bsr.w	SetData
	clr.l	$3DA-$3C2(A2)
	clr.l	$3FA-$3C2(A2)
	clr.l	$41A-$3C2(A2)
	clr.l	$43A-$3C2(A2)
MaxPos
	rts

***************************************************************************
******************************* DTP_BackPatt ******************************
***************************************************************************

BackPattern
	move.w	lbW0004D4(PC),D0
	beq.b	MinPos
	subq.w	#4,D0
	bmi.b	MinPos
	move.w	D0,lbW0004D4
	clr.w	lbW0004D6
	lea	lbW0003C2(PC),A2
	bsr.w	SetData
	clr.l	$3DA-$3C2(A2)
	clr.l	$3FA-$3C2(A2)
	clr.l	$41A-$3C2(A2)
	clr.l	$43A-$3C2(A2)
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

InfoBuffer
	dc.l	MI_LoadSize,0		;4
	dc.l	MI_Samples,0		;12
	dc.l	MI_Length,0		;20
	dc.l	MI_SamplesSize,0	;28
	dc.l	MI_Songsize,0		;36
	dc.l	MI_Calcsize,0		;44
	dc.l	MI_MaxLength,128
	dc.l	MI_MaxSamples,15
	dc.l	MI_MaxPattern,64
	dc.l	MI_Prefix,Prefix
	dc.l	0

***************************************************************************
******************************* DTP_ExtLoad *******************************
***************************************************************************

ExtLoad
	move.l	dtg_PathArrayPtr(A5),A0
	clr.b	(A0)
	move.l	dtg_CopyDir(A5),A0
	jsr	(A0)
	bsr.s	CopyName2
	move.l	dtg_LoadFile(A5),A0
	jsr	(A0)
	tst.l	D0
	beq.b	ExtLoadOK
	move.l	dtg_PathArrayPtr(A5),A0
	clr.b	(A0)
	move.l	dtg_CopyDir(A5),A0
	jsr	(A0)
	bsr.b	CopyName
	move.l	dtg_LoadFile(A5),A0
	jsr	(A0)
ExtLoadOK
	rts

CopyName
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

	cmpi.b	#'P',(A3)
	beq.b	P_OK
	cmpi.b	#'p',(A3)
	bne.s	ExtError
P_OK
	cmpi.b	#'A',1(A3)
	beq.b	A_OK
	cmpi.b	#'a',1(A3)
	bne.s	ExtError
A_OK
	cmpi.b	#'P',2(A3)
	beq.b	PA_OK
	cmpi.b	#'p',2(A3)
	bne.s	ExtError
PA_OK
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

***************************************************************************
******************************* DTP_Check2 ********************************
***************************************************************************

Check2
	movea.l	dtg_ChkData(A5),A0
	moveq	#-1,D0

	move.l	A0,A1
	move.w	(A1)+,D1
	beq.b	fail
	bmi.b	fail
	btst	#0,D1
	bne.b	fail
	move.w	(A1)+,D2
	beq.b	fail
	bmi.b	fail
	btst	#0,D2
	bne.b	fail
	move.w	(A1)+,D3
	beq.b	fail
	bmi.b	fail
	btst	#0,D3
	bne.b	fail
	move.w	(A1)+,D4
	beq.b	fail
	bmi.b	fail
	btst	#0,D4
	bne.b	fail
	move.w	D4,D5
	sub.w	D3,D4
	bmi.b	fail
	sub.w	D2,D3
	bmi.b	fail
	cmp.w	D3,D4
	bne.b	fail
	sub.w	D1,D2
	bmi.b	fail
	subq.w	#2,D2
	cmp.w	D2,D4
	bne.b	fail
	add.w	D4,D5
	lea	(A0,D1.W),A2
	move.w	(A2),D4
	lea	(A0,D4.W),A3
	cmp.b	#-1,(A3)
	bne.b	fail
	lea	(A0,D5.W),A0
Next
	move.w	(A2)+,D2
	bmi.b	fail
	btst	#0,D2
	bne.b	fail
	cmp.w	D1,D2
	bgt.b	fail
	cmp.l	A2,A0
	bne.b	Next

	moveq	#0,D0
fail
	rts

***************************************************************************
***************************** DTP_InitPlayer ******************************
***************************************************************************

InitPlayer
	moveq	#1,D0
	movea.l	dtg_GetListData(A5),A0
	jsr	(A0)

	lea	SamplesPtr(PC),A6
	move.l	A0,(A6)+			; sample buffer
	move.l	D0,D5
	move.l	A0,A3

	moveq	#0,D0
	movea.l	dtg_GetListData(A5),A0
	jsr	(A0)

	move.l	A0,(A6)+			; module buffer
	move.l	A5,(A6)				; EagleBase

	lea	InfoBuffer(PC),A4
	add.l	D5,D0
	move.l	D0,LoadSize(A4)
	move.l	A0,A1
	move.w	6(A1),D0
	move.w	D0,D1
	sub.w	4(A1),D0
	add.w	D0,D1
	lsr.w	#1,D0
	addq.w	#1,D0
	move.w	D0,Length+2(A4)
	lea	(A0,D1.W),A2
	sub.l	A0,A2
	move.l	A2,SongSize(A4)
	move.l	A2,CalcSize(A4)
	cmp.l	#2604,A2			; Pang9 fix
	bne.b	NoPang9
	cmp.w	#$6FC,16(A0)
	bne.b	NoPang9
	move.w	#$6AE,16(A0)
NoPang9
	addq.l	#8,A1
	moveq	#0,D0
	moveq	#0,D1
	moveq	#0,D2
	lea	lbW000448+2(PC),A2
NextInf
	cmp.b	#-1,(A1)
	beq.b	Last
	clr.l	(A3)
	move.l	A3,(A2)+
	addq.l	#1,D0
	move.w	(A1),D1
	add.l	D1,D1
	add.l	D1,D2
	add.l	D1,A3
	addq.l	#8,A1
	bra.b	NextInf
Last
	move.l	D0,Samples(A4)
	move.l	D2,SamplesSize(A4)
	add.l	D2,CalcSize(A4)

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
	move.w	lbW0004D4(PC),D0
	lsr.w	#1,D0
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
	lsr.w	#6,D0				; durch 64
	move.w	D0,LeftVolume

	move.w	dtg_SndRBal(A5),D0
	mulu.w	dtg_SndVol(A5),D0
	lsr.w	#6,D0				; durch 64
	move.w	D0,RightVolume			; Right Volume

	lea	OldVoice1(PC),A1
	moveq	#3,D0
	lea	$DFF0A0,A5
SetNew
	move.w	(A1)+,D2
	bsr.b	ChangeVolume
	addq.l	#8,A5
	addq.l	#8,A5
	dbf	D0,SetNew
	rts

ChangeVolume
	and.w	#$7F,D2
	cmpa.l	#$DFF0A0,A5			;Left Volume
	bne.b	NoVoice1
	move.w	D2,OldVoice1
	tst.w	Voice1
	bne.b	Voice1On
	moveq	#0,D2
Voice1On
	mulu.w	LeftVolume(PC),D2
	bra.b	SetIt
NoVoice1
	cmpa.l	#$DFF0B0,A5			;Right Volume
	bne.b	NoVoice2
	move.w	D2,OldVoice2
	tst.w	Voice2
	bne.b	Voice2On
	moveq	#0,D2
Voice2On
	mulu.w	RightVolume(PC),D2
	bra.b	SetIt
NoVoice2
	cmpa.l	#$DFF0C0,A5			;Right Volume
	bne.b	NoVoice3
	move.w	D2,OldVoice3
	tst.w	Voice3
	bne.b	Voice3On
	moveq	#0,D2
Voice3On
	mulu.w	RightVolume(PC),D2
	bra.b	SetIt
NoVoice3
	move.w	D2,OldVoice4
	tst.w	Voice4
	bne.b	Voice4On
	moveq	#0,D2
Voice4On
	mulu.w	LeftVolume(PC),D2
SetIt
	lsr.w	#6,D2
	move.w	D2,8(A5)
	rts

*------------------------------- Set Vol -------------------------------*

SetVol
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
	move.w	D2,(A0)
	move.l	(A7)+,A0
	rts

*------------------------------- Set All -------------------------------*

SetAll
	move.l	A0,-(A7)
	lea	StructAdr+UPS_Voice1Adr(PC),A0
	cmp.l	#$DFF0A0,A5
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice2Adr(PC),A0
	cmp.l	#$DFF0B0,A5
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice3Adr(PC),A0
	cmp.l	#$DFF0C0,A5
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice4Adr(PC),A0
.SetVoice
	move.l	4(A6),(A0)
	move.w	8(A6),UPS_Voice1Len(A0)
	move.w	(A6),UPS_Voice1Per(A0)
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

	move.w	#3,Speed		; default speed
	move.l	ModulePtr(PC),A0
	bra.w	Init

***************************************************************************
***************************** DTP_EndSound ********************************
***************************************************************************

EndSound
	lea	$DFF000,A0
	move.w	#15,$96(A0)
	clr.w	$A8(A0)
	clr.w	$B8(A0)
	clr.w	$C8(A0)
	clr.w	$D8(A0)
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

	bsr.w	Play_1
	bsr.w	DMAWait
	bsr.w	Play_2

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
	move.l	EagleBase(PC),A5
	move.l	dtg_SongEnd(A5),A1
	jsr	(A1)
	movem.l	(A7)+,A1/A5
	rts

***************************************************************************
************************* Pierre Adane Packer player **********************
***************************************************************************

; Player from "Pang" (c) 1990 by Ocean

Init
	lea	lbW0003C2(PC),A2
;	sf	lbB000272
	clr.w	$DFF0A8
	clr.w	$DFF0B8
	clr.w	$DFF0C8
	clr.w	$DFF0D8
	move.w	#15,$DFF096
	move.l	A0,$4D0-$3C2(A2)
	clr.l	$3DA-$3C2(A2)
	clr.l	$3FA-$3C2(A2)
	clr.l	$41A-$3C2(A2)
	clr.l	$43A-$3C2(A2)
	move.w	(A0),$3E0-$3C2(A2)
	move.w	2(A0),$400-$3C2(A2)
	move.w	4(A0),$420-$3C2(A2)
	move.w	6(A0),$440-$3C2(A2)
	clr.w	$4DA-$3C2(A2)
	clr.w	$4D6-$3C2(A2)
	move.w	lbW0003E0(PC),D0
	move.w	0(A0,D0.W),$3DE-$3C2(A2)
	move.w	lbW000400(PC),D0
	move.w	0(A0,D0.W),$3FE-$3C2(A2)
	move.w	lbW000420(PC),D0
	move.w	0(A0,D0.W),$41E-$3C2(A2)
	move.w	lbW000440(PC),D0
	move.w	0(A0,D0.W),$43E-$3C2(A2)
	move.w	#2,$4D4-$3C2(A2)
	rts

;lbW00008A:
;	dc.w	$FFFF
Play_1
	lea	lbW0003C2(PC),A2
	addq.w	#1,$4DA-$3C2(A2)
;	cmpi.w	#3,$4DA-$3C2(A2)

		move.w	Speed(PC),D0
		cmp.w	$4DA-$3C2(A2),D0

	beq.w	lbC0001AC
	movem.l	D0-D7/A0-A6,-(SP)
	move.b	lbB0003C5(PC),D0
	beq.s	lbC0000B8
	lea	lbW0003C2(PC),A6
	lea	lbW000442(PC),A4
	lea	$DFF0A0,A5
	bsr.s	lbC000100
lbC0000B8:
	move.b	lbB0003E5(PC),D0
	beq.s	lbC0000CE
	lea	lbW0003E2(PC),A6
	lea	lbW000444(PC),A4
	lea	$DFF0B0,A5
	bsr.s	lbC000100
lbC0000CE:
	move.b	lbB000405(PC),D0
	beq.s	lbC0000E4
	lea	lbW000402(PC),A6
	lea	lbW000446(PC),A4
	lea	$DFF0C0,A5
	bsr.s	lbC000100
lbC0000E4:
	move.b	lbB000425(PC),D0
	beq.s	lbC0000FA
	lea	lbW000422(PC),A6
	lea	lbW000448(PC),A4
	lea	$DFF0D0,A5
	bsr.s	lbC000100
lbC0000FA:
	movem.l	(SP)+,D0-D7/A0-A6
	rts

lbC000100:
	moveq	#15,D0
	and.b	2(A6),D0
	add.w	D0,D0
	jmp	lbC000142(PC,D0.W)

lbC00010C:
	moveq	#15,D0
	and.b	3(A6),D0
	add.w	(A4),D0
	cmpi.w	#$358,D0
	bmi.s	lbC00011E
	move.w	#$358,D0
lbC00011E:
	move.w	D0,(A4)
	move.w	D0,6(A5)
	rts

lbC000126:
	moveq	#15,D0
	and.b	3(A6),D0
	sub.w	(A4),D0
	neg.w	D0
	cmpi.w	#$71,D0
	bpl.s	lbC00013A
	move.w	#$71,D0
lbC00013A:
	move.w	D0,(A4)
	move.w	D0,6(A5)
	rts

lbC000142:
	bra.s	lbC00016C

	bra.s	lbC000126

	bra.s	lbC00010C

	rts

	rts

	rts

	rts

	rts

	rts

	rts

	rts

	rts

	bra.s	lbC000162

	rts

	rts

	bra.s	lbC00016A

lbC000162:
;	move.b	3(A6),8(A5)

		move.l	D2,-(SP)
		move.b	3(A6),D2
		bsr.w	ChangeVolume
		bsr.w	SetVol
		move.l	(SP)+,D2

	rts

lbC00016A:
		moveq	#15,D0
		and.b	3(A6),D0
		beq.b	Exit
		move.w	D0,Speed
Exit
	rts

lbC00016C:
	move.w	lbW0004DA(PC),D0
	add.w	D0,D0
	jmp	lbW000174(PC,D0.W)
lbW000174:	equ	*-2

	bra.s	lbC000188

	bra.s	lbC000190

	bra.s	lbC000180

	bra.s	lbC000188

	bra.s	lbC000190

lbC000180:
	move.w	$10(A6),6(A5)
	rts

lbC000188:
	move.b	3(A6),D0
	lsr.b	#4,D0
	bra.s	lbC000196

lbC000190:
	moveq	#15,D0
	and.b	3(A6),D0
lbC000196:
	add.w	D0,D0
	move.w	$10(A6),D1
	lea	lbW000486(PC),A0
lbC0001A0:
	cmp.w	(A0)+,D1
	bne.s	lbC0001A0
	move.w	-2(A0,D0.W),6(A5)
	rts

lbC0001AC:
;	movem.l	D0-D7/A0-A6,-(SP)
	clr.w	$4DA-$3C2(A2)
	movea.l	lbL0004D0(PC),A0
	movea.l	A0,A3
	move.w	#$8000,$4D8-$3C2(A2)
	lea	$DFF0A0,A5
	lea	lbW0003C2(PC),A6
	lea	lbW000442(PC),A4
	bsr.w	lbC0002D8
	lea	$DFF0B0,A5
	lea	lbW0003E2(PC),A6
	lea	lbW000444(PC),A4
	bsr.w	lbC0002D8
	lea	$DFF0C0,A5
	lea	lbW000402(PC),A6
	lea	lbW000446(PC),A4
	bsr.w	lbC0002D8
	lea	$DFF0D0,A5
	lea	lbW000422(PC),A6
	lea	lbW000448(PC),A4
	bsr.w	lbC0002D8
	move.w	lbW0004D6(PC),D0
	addq.w	#1,D0
	andi.w	#$3F,D0
	move.w	D0,$4D6-$3C2(A2)
	bne.s	lbC00026C
SetData
	movea.l	lbL0004D0(PC),A0
	move.w	lbW0003E0(PC),D0
	add.w	lbW0004D4(PC),D0
	move.w	0(A0,D0.W),D0
	bne.s	lbC00023A
;	st	lbB000272

		bsr.w	SongEnd

	clr.w	$4D4-$3C2(A2)
	move.w	lbW0003E0(PC),D0
	move.w	0(A0,D0.W),D0
lbC00023A:
	move.w	D0,$3DE-$3C2(A2)
	move.w	lbW000400(PC),D0
	add.w	lbW0004D4(PC),D0
	move.w	0(A0,D0.W),$3FE-$3C2(A2)
	move.w	lbW000420(PC),D0
	add.w	lbW0004D4(PC),D0
	move.w	0(A0,D0.W),$41E-$3C2(A2)
	move.w	lbW000440(PC),D0
	add.w	lbW0004D4(PC),D0
	move.w	0(A0,D0.W),$43E-$3C2(A2)
	addq.w	#2,$4D4-$3C2(A2)
lbC00026C:
;	movem.l	(SP)+,D0-D7/A0-A6
	rts
;lbB000272
;	dc.w	0
Play_2
	lea	lbW0003C2(PC),A2
	move.w	lbW0004D8(PC),D0
;	and.w	lbW00008A(PC),D0
	move.w	D0,$DFF096
	cmpi.w	#1,$3D0-$3C2(A2)
	bne.s	lbC00029A
	clr.w	$3D0-$3C2(A2)
	move.w	#1,$DFF0A4
lbC00029A:
	cmpi.w	#1,$3F0-$3C2(A2)
	bne.s	lbC0002AE
	clr.w	$3F0-$3C2(A2)
	move.w	#1,$DFF0B4
lbC0002AE:
	cmpi.w	#1,$410-$3C2(A2)
	bne.s	lbC0002C2
	clr.w	$410-$3C2(A2)
	move.w	#1,$DFF0C4
lbC0002C2:
	cmpi.w	#1,$430-$3C2(A2)
	bne.s	lbC0002D6
	clr.w	$430-$3C2(A2)
	move.w	#1,$DFF0D4
lbC0002D6:
	rts

lbC0002D8:
	movea.l	lbL0004D0(PC),A0
	adda.w	$1C(A6),A0
	subq.w	#1,$18(A6)
	bpl.s	lbC00030A
	cmpi.b	#$FF,(A0)
	bne.s	lbC0002FC
	addq.w	#1,A0
	moveq	#0,D0
	move.b	(A0)+,D0
	subq.w	#1,D0
	move.w	D0,$1A(A6)
	addq.w	#2,$1C(A6)
lbC0002FC:
	move.l	(A0),(A6)
	addq.w	#4,$1C(A6)
	move.w	$1A(A6),$18(A6)
	bra.s	lbC00030C

lbC00030A:
	clr.l	(A6)
lbC00030C:
	moveq	#0,D2
	move.b	2(A6),D2
	lsr.b	#4,D2
	beq.s	lbC000374
	add.w	D2,D2
	add.w	D2,D2
	move.w	D2,D4
	add.w	D4,D4
	lea	lbW000446(PC),A1
	move.l	0(A1,D2.W),4(A6)
	move.w	0(A3,D4.W),8(A6)
	move.w	2(A3,D4.W),$12(A6)
	moveq	#15,D3
	and.b	2(A6),D3
	cmpi.b	#12,D3
	bne.s	lbC000348
;	move.b	3(A6),8(A5)

		move.l	D2,-(SP)
		move.b	3(A6),D2
		bsr.w	ChangeVolume
		bsr.w	SetVol
		move.l	(SP)+,D2

	bra.s	lbC00034E

lbC000348:
;	move.w	2(A3,D4.W),8(A5)

		move.l	D2,-(SP)
		move.w	2(A3,D4.W),D2
		bsr.w	ChangeVolume
		bsr.w	SetVol
		move.l	(SP)+,D2

lbC00034E:
	move.w	4(A3,D4.W),D3
	add.l	4(A6),D3
	move.l	D3,10(A6)
	move.w	6(A3,D4.W),14(A6)
	cmpi.w	#1,14(A6)
	beq.s	lbC000374
	move.l	10(A6),4(A6)
	move.w	6(A3,D4.W),8(A6)
lbC000374:
	tst.w	(A6)
	beq.s	lbC0003B8
	move.w	$16(A6),D0
;	and.w	lbW00008A(PC),D0
	move.w	D0,$DFF096
	tst.w	14(A6)
	bne.s	lbC000392
	move.w	#1,14(A6)
lbC000392:
	move.w	(A6),D0
	move.w	D0,(A4)
	move.w	D0,$10(A6)
	move.l	4(A6),(A5)
	move.w	8(A6),4(A5)
	move.w	D0,6(A5)

		bsr.w	SetAll

	move.w	$16(A6),D0
	or.w	D0,$4D8-$3C2(A2)
	move.w	$12(A6),$14(A6)
lbC0003B6:
	rts

lbC0003B8:
	tst.w	2(A6)
	beq.s	lbC0003B6
	bra.w	lbC000100

lbW0003C2:
	dc.w	0
	dc.b	0
lbB0003C5:
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0
	dc.b	0,0
lbW0003E0:
	dc.w	0
lbW0003E2:
	dc.w	0
	dc.b	0
lbB0003E5:
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,0,0,0,0
	dc.b	0,0
lbW000400:
	dc.w	0
lbW000402:
	dc.w	0
	dc.b	0
lbB000405:
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,0,0,0,0
	dc.b	0,0
lbW000420:
	dc.w	0
lbW000422:
	dc.w	0
	dc.b	0
lbB000425:
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,0,0,0,0
	dc.b	0,0
lbW000440:
	dc.w	0
lbW000442:
	dc.w	0
lbW000444:
	dc.w	0
lbW000446:
	dc.w	0
lbW000448:
	dc.w	0
	ds.b	15*4
lbW000486:
	dc.w	$358,$328,$2FA,$2D0,$2A6,$280,$25C,$23A,$21A,$1FC
	dc.w	$1E0,$1C5,$1AC,$194,$17D,$168,$153,$140,$12E,$11D
	dc.w	$10D,$FE,$F0,$E2,$D6,$CA,$BE,$B4,$AA,$A0,$97,$8F
	dc.w	$87,$7F,$78,$71,0
lbL0004D0:
	dc.l	0
lbW0004D4:
	dc.w	0
lbW0004D6:
	dc.w	0
lbW0004D8:
	dc.w	0
lbW0004DA:
	dc.w	0
Speed
	dc.w	0

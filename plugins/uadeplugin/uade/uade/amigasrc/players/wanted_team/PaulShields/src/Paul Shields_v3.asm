	*****************************************************
	****    Paul Shields replayer for EaglePlayer, 	 ****
	****	     all adaptions by Wanted Team	 ****
	****      DeliTracker compatible (?) version	 ****
	*****************************************************

	incdir	"dh2:include/"
	include 'misc/eagleplayer2.01.i'

	SECTION	Player_Code,Code

	PLAYERHEADER Tags

	dc.b '$VER: Paul Shields player module V1.2 (4 Feb 2002)',0
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
	dc.l	DTP_Volume,SetVolume
	dc.l	DTP_Balance,SetBalance
	dc.l	EP_Voices,SetVoices
	dc.l	EP_StructInit,StructInit
	dc.l	EP_Get_ModuleInfo,GetInfos
	dc.l	EP_SampleInit,SampleInit
	dc.l	EP_GetPositionNr,GetPosition
	dc.l	EP_Flags,EPB_Volume!EPB_Balance!EPB_ModuleInfo!EPB_Voices!EPB_SampleInfo!EPB_Songend!EPB_Analyzer!EPB_Save!EPB_Packable!EPB_Restart
	dc.l	TAG_DONE

PlayerName
	dc.b	"Paul Shields",0
Creator
	dc.b	"(c) 1988-91 by Paul Shields and Paul",10
	dc.b	"Hunter, adapted by Wanted Team",0
Prefix
	dc.b	"PS.",0
	even
ModulePtr
	dc.l	0
SamplePtr
	dc.l	0
EagleBase
	dc.l	0
IntenaTemp
	dc.w	0
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

***************************************************************************
**************************** EP_GetPositionNr *****************************
***************************************************************************

GetPosition
	lea	VoiceB(PC),A1
	move.b	CurrentFormat(PC),D0
	bne.b	OtherVoice
	lea	VoiceA(PC),A1
OtherVoice
	move.l	24(A1),D0
	sub.l	20(A1),D0
	lsr.l	#1,D0
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

*------------------------------- Set All -------------------------------*

SetAll
	move.l	A1,-(A7)
	lea	StructAdr+UPS_Voice1Adr(PC),A1
	cmp.l	#$DFF0A0,A4
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice2Adr(PC),A1
	cmp.l	#$DFF0B0,A4
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice3Adr(PC),A1
	cmp.l	#$DFF0C0,A4
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice4Adr(PC),A1
.SetVoice
	move.l	8(A0),(A1)
	move.w	12(A0),UPS_Voice1Len(A1)
	move.w	$34(A0),UPS_Voice1Per(A1)
	move.l	(A7)+,A1
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
******************************* EP_SampleInit *****************************
***************************************************************************

SampleInit
	moveq	#EPR_NotEnoughMem,D7
	lea	EPG_SampleInfoStructure(A5),A3
	move.l	ModulePtr(PC),D0
	beq.w	return
	move.l	D0,A2

	lea	CurrentFormat(PC),A0
	moveq	#10,D2
	cmp.b	#1,(A0)
	beq.b	New0
	moveq	#32,D2
New0
	add.l	D2,A2
	move.l	SamplePtr(PC),A1
	moveq	#14,D5
hop
	jsr	ENPP_AllocSampleStruct(A5)
	move.l	D0,(A3)
	beq.b	return
	move.l	D0,A3

	moveq	#0,D0
	move.w	2(A2),D0
	cmp.b	#1,(A0)
	beq.b	New2
	move.w	22(A2),D0
New2
	add.l	D0,D0
	move.l	D0,EPS_Length(A3)		; sample length
	move.l	A2,EPS_SampleName(A3)
	move.l	A1,EPS_Adr(A3)			; sample address
	move.w	#22,EPS_MaxNameLen(A3)
	move.l	#64,EPS_Volume(A3)
	move.w	#USITY_RAW,EPS_Type(A3)
	move.w	#USIB_Playable!USIB_Saveable!USIB_8BIT,EPS_Flags(A3)

	add.l	D0,A1
	add.l	D2,A2
	dbf	D5,hop

	moveq	#0,D7
return
	move.l	D7,D0
	rts

***************************************************************************
***************************** EP_Get_ModuleInfo ***************************
***************************************************************************

GetInfos
	lea	InfoBuffer(PC),A0
	rts

LoadSize	=	4
Songsize	=	12
Length		=	20
Calcsize	=	28
Samples		=	36
SamplesSize	=	44

InfoBuffer
	dc.l	MI_LoadSize,0		;4
	dc.l	MI_Songsize,0		;12
	dc.l	MI_Length,0		;20
	dc.l	MI_Calcsize,0		;28
	dc.l	MI_Samples,0		;36
	dc.l	MI_SamplesSize,0	;44
	dc.l	MI_MaxSamples,15
	dc.l	MI_MaxSynthSamples,7
	dc.l	MI_AuthorName,PlayerName
	dc.l	MI_Prefix,Prefix
	dc.l	0

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

	lea	Format(PC),A2
	move.l	A0,A1
	tst.l	(A0)
	bne.b	Fault
	tst.l	4(A0)
	bne.b	Fault
	tst.w	8(A0)
	bne.b	Fault
	move.w	164(A0),D1
	cmp.w	168(A0),D1
	bne.b	Old
	cmp.w	172(A0),D1
	bne.b	Old
	cmp.w	176(A0),D1
	bne.b	Old
	move.w	160(A0),D1
	beq.b	Old
	bmi.b	Old
	btst	#0,D1
	bne.b	Old
	add.w	D1,A1
	cmp.l	#$00B400B6,(A1)
	bne.b	Old
	move.b	#1,(A2)
	bra.b	Found
Old
	move.w	516(A0),D1
	cmp.w	520(A0),D1
	bne.b	Last
	cmp.w	524(A0),D1
	bne.b	Last
	cmp.w	528(A0),D1
	bne.b	Last
	move.w	512(A0),D1
	beq.b	Last
	bmi.b	Last
	btst	#0,D1
	bne.b	Last
	add.w	D1,A1
	cmp.l	#$02140216,(A1)
	bne.b	Last
	st	(A2)
Found
	moveq	#0,D0
Fault
	rts
Last
	move.w	514(A0),D1
	cmp.w	518(A0),D1
	bne.b	Fault
	cmp.w	522(A0),D1
	bne.b	Fault
	cmp.w	526(A0),D1
	bne.b	Fault
	move.w	516(A0),D1
	beq.b	Fault
	bmi.b	Fault
	btst	#0,D1
	bne.b	Fault
	add.w	D1,A1
	cmp.w	#$FFEC,-2(A1)				; Song Loop
	beq.b	Loop
	cmp.w	#$FFE8,-2(A1)				; Song Stop
	bne.b	Fault
Loop
	clr.b	(A2)
	bra.b	Found

***************************************************************************
***************************** DTP_InitPlayer ******************************
***************************************************************************

InitPlayer
	moveq	#0,D0
	movea.l	dtg_GetListData(A5),A0
	jsr	(A0)

	lea	ModulePtr(PC),A1
	move.l	A0,(A1)+			; module buffer
	lea	Format(PC),A6
	move.b	(A6)+,(A6)

	lea	InfoBuffer(PC),A4
	move.l	D0,LoadSize(A4)

	moveq	#0,D1
	moveq	#3,D2
	move.l	A0,A3
	lea	166(A0),A2
	cmp.b	#1,(A6)
	beq.b	FindMax
	add.w	#352,A2
	tst.b	(A6)
	bne.b	FindMax
	subq.l	#2,A2
FindMax
	move.w	(A2),D0
	cmp.w	D0,D1
	bgt.b	Max
	move.w	D0,D1
Max
	addq.l	#4,A2
	dbf	D2,FindMax
	add.w	D1,A3
	move.w	-2(A3),D1
FindIt
	cmp.w	(A3)+,D1
	bne.b	FindIt
	move.l	A3,(A1)+				; SamplePtr

	sub.l	A0,A3
	move.l	A3,Songsize(A4)
	move.l	A3,D3

	move.l	A0,A3
	cmp.b	#1,(A6)
	bne.b	Old2
	add.w	170(A0),A3
	bra.b	SkipIt
Old2
	tst.b	(A6)
	bne.b	VeryFirst
	add.w	516(A0),A3
	bra.b	SkipIt
VeryFirst
	add.w	522(A0),A3
SkipIt
	moveq	#0,D2
NextStep
	move.w	(A3)+,D0
	cmp.w	D0,D1
	beq.b	LastStep
	addq.l	#1,D2
	bra.b	NextStep
LastStep
	move.l	D2,Length(A4)

	moveq	#0,D0
	moveq	#0,D1
	moveq	#0,D4
	moveq	#15,D2
NextSample
	addq.l	#2,A0
	cmp.b	#1,(A6)
	beq.b	New6
	lea	20(A0),A0
New6
	tst.w	(A0)
	beq.b	NoSample
	move.w	(A0),D4
	add.l	D4,D0
	addq.l	#1,D1
NoSample
	cmp.b	#1,(A6)
	beq.b	New7
	addq.l	#2,A0
New7
	addq.l	#8,A0
	dbf	D2,NextSample

	add.l	D0,D0
	move.l	D0,SamplesSize(A4)
	add.l	D0,D3
	move.l	D1,Samples(A4)
	move.l	D3,Calcsize(A4)
	cmp.l	LoadSize(A4),D3
	ble.b	SizeOK
	moveq	#EPR_ModuleTooShort,D0		; error message
	rts
SizeOK	
	move.l	A5,(A1)				; EagleBase

	movea.l	dtg_AudioAlloc(A5),A0
	jmp	(A0)

***************************************************************************
***************************** DTP_EndPlayer *******************************
***************************************************************************

EndPlayer
	move.l	dtg_AudioFree(a5),a0		; Function
	jmp	(a0)

***************************************************************************
***************************** DTP_InitSound *******************************
***************************************************************************

InitSound
	move.b	CurrentFormat(PC),D1
	bne.b	OldInit
	bsr.w	InitSamples_2
	bra.w	InitSong_2
OldInit
	move.l	SamplePtr(PC),A3
	move.l	ModulePtr(PC),A0
	cmp.b	#1,D1
	beq.b	New4
	bsr.w	InitSamplesOld
	bra.b	Skip1
New4
	bsr.w	InitSamplesNew
Skip1
	bra.w	InitSong

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
***************************** DTP_Intterrupt ******************************
***************************************************************************

Interrupt	
	movem.l	D1-D7/A0-A6,-(A7)

	lea	StructAdr(PC),A3
	st	UPS_Enabled(A3)
	clr.w	UPS_Voice1Per(A3)
	clr.w	UPS_Voice2Per(A3)
	clr.w	UPS_Voice3Per(A3)
	clr.w	UPS_Voice4Per(A3)
	move.w	#UPSB_Adr!UPSB_Len!UPSB_Per!UPSB_Vol,UPS_Flags(A3)

	move.b	CurrentFormat(PC),D0
	beq.b	New_2
	bsr.w	Play_1			; play module
	bsr.b	DMAWait
	bsr.w	Audio_1
	bra.b	SkipNew
New_2
	bsr.w	Play_2
	bsr.b	DMAWait
	bsr.w	Audio_2
SkipNew
	clr.w	UPS_Enabled(A3)

	movem.l	(A7)+,D1-D7/A0-A6
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
************************** Paul Shields player (old) **********************
***************************************************************************

;	MOVE.L	#lbL0009F0,lbL0009E4
;	LEA	$DFF000,A6
;	MOVE.W	#$780,$9A(A6)
;	MOVE.W	#15,$96(A6)
;	MOVE.L	#lbC000238,$70
;	CLR.W	lbW000B88
;	MOVE.W	#15,$96(A6)
;	MOVEA.L	lbL0009E4(PC),A0
;	BSR.L	lbC0000FA
;	BSR.L	lbC000150
;	RTS

InitSamplesOld
lbC0000FA
;	MOVEA.L	lbL0009E4(PC),A0
	LEA	lbL000746(PC),A2
	MOVEQ	#15,D7
lbC000104
;	TST.W	$16(A0)
;	BEQ.S	lbC00011C
;	MOVEM.L	D7/A0/A2,-(SP)
;	MOVEA.L	(A0),A0
;	TST.L	(A0)+
;	MOVE.L	A0,lbL0009E8
;	MOVEM.L	(SP)+,D7/A0/A2
;lbC00011C
;	MOVEA.L	lbL0009E8(PC),A1

	move.l	A3,A1

	MOVE.L	A1,(A2)+
	MOVE.W	$16(A0),(A2)+
	ADDA.W	$1A(A0),A1
	MOVE.W	$1C(A0),D0
	CMP.W	#2,D0
	BCC.S	lbC00013A
	MOVEQ	#2,D0
	LEA	lbL0009DC,A1			; was PC
lbC00013A	MOVE.L	A1,(A2)+
	MOVE.W	D0,(A2)+
	MOVE.W	$1E(A0),(A2)+
	MOVE.W	$18(A0),(A2)+

	add.w	22(A0),A3
	add.w	22(A0),A3

	ADDA.W	#$20,A0
	DBRA	D7,lbC000104
	RTS

InitSamplesNew
	LEA	lbL000746(PC),A2
	MOVEQ	#15,D7
nlbC000104

	move.l	A3,A1

	MOVE.L	A1,(A2)+
	MOVE.W	2(A0),(A2)+
	ADDA.W	4(A0),A1
	MOVE.W	6(A0),D0
	CMP.W	#2,D0
	BCC.S	nlbC00013A
	MOVEQ	#2,D0
	LEA	lbL0009DC,A1			; was PC
nlbC00013A	MOVE.L	A1,(A2)+
	MOVE.W	D0,(A2)+
	MOVE.W	8(A0),(A2)+

	clr.w	(A2)+
	add.w	2(A0),A3
	add.w	2(A0),A3

	ADDA.W	#10,A0
	DBRA	D7,nlbC000104
	RTS

InitSong
;lbC000150	CLR.W	lbW0002B8
;	MOVEA.L	lbL0009E4(PC),A0

	move.l	ModulePtr(PC),A0

	LEA	$DFF000,A6
	MOVE.W	#$780,$9A(A6)
	MOVE.W	#15,$96(A6)
	MOVE.W	#$FF,$9E(A6)
	LEA	lbL0009C6(PC),A5
	MOVE.L	A0,2(A5)
;	ADDA.W	#$200,A0

	add.w	#$A0,A0
	cmp.b	#1,D1
	beq.b	New5
	add.w	#$160,A0
New5
	CLR.L	D1
	MOVE.W	(A0)+,D1
	ADD.L	2(A5),D1
	MOVE.L	D1,6(A5)
	CLR.L	D1
	MOVE.W	(A0)+,D1
	ADD.L	2(A5),D1
	MOVE.L	D1,10(A5)
	CLR.W	$10(A5)
	CLR.W	14(A5)
	LEA	lbL000966(PC),A1
	MOVE.W	#3,D0
lbC0001A6	CLR.W	4(A1)
	CLR.W	2(A1)
	CLR.W	6(A1)
	CLR.W	$2C(A1)
	CLR.W	$30(A1)
	CLR.W	$26(A1)
	MOVE.W	(A0),$2A(A1)
	MOVE.W	(A0)+,$28(A1)
	CLR.L	D1
	MOVE.W	(A0)+,D1
	ADD.L	2(A5),D1
	MOVE.L	D1,$14(A1)
	MOVE.L	D1,$18(A1)
	LEA	lbB0009DA(PC),A2
	MOVE.L	A2,$20(A1)
	MOVE.W	#1,$3E(A1)
	MOVE.W	#1,$3C(A1)
	MOVE.W	#1,12(A1)
	MOVE.W	#1,$12(A1)
;	LEA	lbL0009DC(PC),A2

	lea	lbL000B56,A2			; + synth samples fix

	MOVE.L	A2,8(A1)
	MOVE.L	A2,14(A1)
	LEA	lbB0009DB(PC),A2
	MOVE.L	A2,$40(A1)
	MOVE.L	A2,$44(A1)
	MOVE.L	A2,$4C(A1)
	MOVE.L	A2,$50(A1)
	MOVE.W	#$100,0(A1)
	SUBA.W	#$60,A1
	DBRA	D0,lbC0001A6
;	MOVE.W	#$FFFF,lbW0002B8
	RTS

;	MOVE.W	#0,lbW0002B8
;	RTS

;lbC000238	MOVEM.L	D0/D1/A0/A6,-(SP)
;	MOVE.W	#$20,D0
;lbC000240	DBRA	D0,lbC000240
;	LEA	$DFF000,A6
;	MOVE.W	$1E(A6),D0
;	ANDI.W	#$780,D0
;	MOVE.W	D0,$9A(A6)
;	MOVE.W	D0,$9C(A6)

Audio_1
	move.w	IntenaTemp(PC),D0

	BTST	#10,D0
	BEQ.S	lbC000270
	LEA	lbL000966(PC),A0
	MOVE.L	14(A0),$D0(A6)
	MOVE.W	$12(A0),$D4(A6)
lbC000270	BTST	#9,D0
	BEQ.S	lbC000286
	LEA	lbL000906(PC),A0
	MOVE.L	14(A0),$C0(A6)
	MOVE.W	$12(A0),$C4(A6)
lbC000286	BTST	#8,D0
	BEQ.S	lbC00029C
	LEA	lbL0008A6(PC),A0
	MOVE.L	14(A0),$B0(A6)
	MOVE.W	$12(A0),$B4(A6)
lbC00029C	BTST	#7,D0
	BEQ.S	lbC0002B2
	LEA	lbL000846(PC),A0
	MOVE.L	14(A0),$A0(A6)
	MOVE.W	$12(A0),$A4(A6)
lbC0002B2
;	MOVEM.L	(SP)+,D0/D1/A0/A6
;	RTE

	rts

;lbW0002B8	dc.w	0

Play_1
;	TST.W	lbW0002B8
;	BNE.S	lbC0002C4
;	RTS

lbC0002C4
	LEA	lbL0009C6(PC),A5
	LEA	$DFF000,A6
;	MOVE.W	$10(A5),D0
;	ANDI.W	#$780,D0
;	MOVE.W	D0,$9C(A6)
;	MOVE.W	$10(A5),$9A(A6)

	move.w	$10(A5),IntenaTemp

	MOVE.W	14(A5),$96(A6)
	CLR.W	14(A5)
	CLR.W	$10(A5)
	LEA	lbL000966(PC),A0
	LEA	$D0(A6),A4
	MOVE.W	#3,D2
lbC0002FA	BTST	#0,0(A0)
	BEQ.L	lbC000624
	SUBQ.W	#1,$26(A0)
	BNE.S	lbC000326
	MOVE.W	$2A(A0),D0
	CMP.W	$28(A0),D0
	BEQ.S	lbC000326
	BCS.S	lbC00031C
	SUBQ.W	#1,$2A(A0)
	BRA.S	lbC000320

lbC00031C	ADDQ.W	#1,$2A(A0)
lbC000320	MOVE.W	$24(A0),$26(A0)
lbC000326	SUBQ.W	#1,$3C(A0)
	BNE.L	lbC000576
	MOVEA.L	$20(A0),A1
lbC000332	CLR.W	D0
	MOVE.B	(A1)+,D0
	JMP	lbC00033A(PC,D0.W)

lbC00033A	BRA.L	lbC000500

	BRA.L	lbC000722

	BRA.L	lbC0004EC

	BRA.L	lbC000376

	BRA.L	lbC0004F4

	BRA.L	lbC0004BA

	BRA.L	lbC000496

	BRA.L	lbC0004C2

	BRA.L	lbC00042A

	BRA.L	lbC00038E

	BRA.L	lbC00039C

	BRA.L	lbC0003F2

	BRA.L	lbC000422

	BRA.L	lbC0003A8

	BRA.L	lbC0003A2

lbC000376	SUBQ.W	#1,$3E(A0)
	BNE.L	lbC00041A
	MOVEA.L	$18(A0),A2
lbC000382	MOVE.W	(A2)+,D0
	CMP.W	#$FFE8,D0
	BCS.S	lbC0003F8
	JMP	lbC000376(PC,D0.W)

lbC00038E	MOVE.W	(A2)+,$28(A0)
	MOVE.W	(A2),$24(A0)
	MOVE.W	(A2)+,$26(A0)
	BRA.S	lbC000382

lbC00039C	MOVE.W	(A2)+,2(A0)
	BRA.S	lbC000382

lbC0003A2	MOVE.W	(A2)+,4(A0)
	BRA.S	lbC000382

lbC0003A8	PEA	(A0)
	MOVE.W	(A2)+,D0
	MOVE.W	(A2)+,D1
	LEA	lbL000846(PC),A0
	MOVE.W	D0,$28(A0)
	MOVE.W	D1,$24(A0)
	MOVE.W	D1,$26(A0)
	LEA	lbL0008A6(PC),A0
	MOVE.W	D0,$28(A0)
	MOVE.W	D1,$24(A0)
	MOVE.W	D1,$26(A0)
	LEA	lbL000906(PC),A0
	MOVE.W	D0,$28(A0)
	MOVE.W	D1,$24(A0)
	MOVE.W	D1,$26(A0)
	LEA	lbL000966(PC),A0
	MOVE.W	D0,$28(A0)
	MOVE.W	D1,$24(A0)
	MOVE.W	D1,$26(A0)
	MOVEA.L	(SP)+,A0
	BRA.S	lbC000382

lbC0003F2	MOVEA.L	$14(A0),A2

	cmp.l	#$DFF0B0,A4
	bne.b	Skip2
	bsr.w	SongEnd
Skip2
	BRA.w	lbC000382

lbC0003F8	MOVE.W	#1,$3E(A0)
	BCLR	#15,D0
	BEQ.S	lbC000408
	MOVE.W	(A2)+,$3E(A0)
lbC000408	MOVEA.L	2(A5),A1
	ADDA.W	D0,A1
	MOVE.L	A1,$1C(A0)
	MOVE.L	A2,$18(A0)
	BRA.L	lbC000332

lbC00041A	MOVEA.L	$1C(A0),A1
	BRA.L	lbC000332

lbC000422	CLR.W	0(A0)

	bsr.w	SongEnd

	BRA.L	lbC000624

lbC00042A	MOVE.B	(A1)+,D0
	LSL.W	#3,D0
	BTST	#3,0(A0)
	BNE.S	lbC000442
	MOVE.W	D0,$34(A0)
	CLR.W	D0
	MOVE.B	(A1)+,D0
	LSL.W	#3,D0
	BRA.S	lbC000454

lbC000442	BSR.L	lbC0006F2
	MOVE.W	D0,$34(A0)
	CLR.W	D0
	MOVE.B	(A1)+,D0
	LSL.W	#3,D0
	BSR.L	lbC0006F2
lbC000454	SUB.W	$34(A0),D0
	CLR.L	D1
	MOVE.W	D0,D1
	BMI.L	lbC000478
	CLR.W	D0
	BSR.L	lbC000712
	DIVU.W	D0,D1
	MOVE.W	D1,$38(A0)
	CLR.W	D1
	DIVU.W	D0,D1
	MOVE.W	D1,$3A(A0)
	BRA.L	lbC00051E

lbC000478	NEG.W	D1
	CLR.W	D0
	BSR.L	lbC000712
	DIVU.W	D0,D1
	MOVE.W	D1,$38(A0)
	CLR.W	D1
	DIVU.W	D0,D1
	MOVE.W	D1,$3A(A0)
	NEG.L	$38(A0)
	BRA.L	lbC00051E

lbC000496	MOVEA.L	10(A5),A2
	MOVE.B	(A1)+,D0
	MOVE.W	0(A2,D0.W),D0
	MOVEA.L	2(A5),A2
	ADDA.W	D0,A2
	MOVE.B	(A2),$56(A0)
	MOVE.B	(A2)+,$54(A0)
	MOVE.L	A2,$50(A0)
	MOVE.L	A2,$4C(A0)
	BRA.L	lbC000332

lbC0004BA	BSET	#3,0(A0)
	BRA.S	lbC0004C8

lbC0004C2	BCLR	#3,0(A0)
lbC0004C8	MOVEA.L	6(A5),A2
	MOVE.B	(A1)+,D0
	MOVE.W	0(A2,D0.W),D0
	MOVEA.L	2(A5),A2
	ADDA.W	D0,A2
	MOVE.B	(A2),$4A(A0)
	MOVE.B	(A2)+,$48(A0)
	MOVE.L	A2,$44(A0)
	MOVE.L	A2,$40(A0)
	BRA.L	lbC000332

lbC0004EC	MOVE.B	(A1)+,$2D(A0)
	BRA.L	lbC000332

lbC0004F4	BSET	#1,0(A0)
	BSR.L	lbC000712
	BRA.S	lbC000572

lbC000500	MOVE.B	(A1)+,D0
	LSL.W	#3,D0
	BTST	#3,0(A0)
	BEQ.S	lbC000510
	BSR.L	lbC0006F2
lbC000510	MOVE.W	D0,$34(A0)
	CLR.W	D0
	BSR.L	lbC000712
	CLR.L	$38(A0)
lbC00051E
;	MOVE.W	$5E(A0),$9A(A6)
	MOVE.W	$5A(A0),$96(A6)
	MOVE.W	$2C(A0),D0
	BNE.S	lbC000534
	MOVE.W	$30(A0),D0
lbC000534	MOVE.W	D0,$2E(A0)
	MOVE.B	$54(A0),$56(A0)
	MOVE.L	$4C(A0),$50(A0)
	MOVE.B	$48(A0),$4A(A0)
	MOVE.L	$40(A0),$44(A0)
	MOVE.L	8(A0),0(A4)
	MOVE.W	12(A0),4(A4)

	bsr.w	SetAll

	MOVE.W	$5C(A0),D0
	OR.W	D0,$10(A5)
	MOVE.W	$58(A0),D0
	OR.W	D0,14(A5)
	BCLR	#1,0(A0)
lbC000572	MOVE.L	A1,$20(A0)
lbC000576	BTST	#1,0(A0)
	BEQ.S	lbC00058A
	TST.W	$2E(A0)
	BMI.S	lbC0005B8
	SUBQ.W	#2,$2E(A0)
	BRA.S	lbC0005B8

lbC00058A	SUBQ.B	#1,$56(A0)
	BNE.S	lbC0005B8
	MOVEA.L	$50(A0),A1
lbC000594	MOVE.B	(A1)+,D0
	CMP.B	#$80,D0
	BEQ.S	lbC0005B8
	CMP.B	#$81,D0
	BNE.S	lbC0005A8
	MOVEA.L	$4C(A0),A1
	BRA.S	lbC000594

lbC0005A8	EXT.W	D0
	ADD.W	D0,$2E(A0)
	MOVE.B	$54(A0),$56(A0)
	MOVE.L	A1,$50(A0)
lbC0005B8	MOVE.W	$2A(A0),D0
	ADD.W	$2E(A0),D0
	SUB.W	$12(A5),D0
	MOVE.W	D0,$32(A0)
	BPL.S	lbC0005CE
	CLR.W	D0
	BRA.S	lbC0005D6

lbC0005CE	CMP.W	#$40,D0
	BLE.S	lbC0005D6
	MOVEQ	#$40,D0
lbC0005D6
;	MOVE.W	D0,8(A4)

	bsr.w	ChangeVolume
	bsr.w	SetVol

	MOVE.L	$38(A0),D0
	ADD.L	D0,$34(A0)
	SUBQ.B	#1,$4A(A0)
	BNE.S	lbC000610
	MOVEA.L	$44(A0),A1
lbC0005EC	MOVE.B	(A1)+,D0
	CMP.B	#$80,D0
	BEQ.S	lbC000610
	CMP.B	#$81,D0
	BNE.S	lbC000600
	MOVEA.L	$40(A0),A1
	BRA.S	lbC0005EC

lbC000600	EXT.W	D0
	ADD.W	D0,$34(A0)
	MOVE.B	$48(A0),$4A(A0)
	MOVE.L	A1,$44(A0)
lbC000610	MOVE.W	$34(A0),D0
	BTST	#3,0(A0)
	BNE.S	lbC000620
	BSR.L	lbC0006F2
lbC000620	MOVE.W	D0,6(A4)
lbC000624	SUBA.W	#$60,A0
	SUBA.W	#$10,A4
	DBRA	D2,lbC0002FA
	RTS

	dc.l	$6AE46A1F
	dc.l	$695C689A
	dc.l	$67D9671A
	dc.l	$665C659F
	dc.l	$64E4642A
	dc.l	$637262BB
	dc.l	$62056150
	dc.l	$609D5FEB
	dc.l	$5F3A5E8B
	dc.l	$5DDD5D30
	dc.l	$5C845BDA
	dc.l	$5B315A89
	dc.l	$59E2593D
	dc.l	$589857F5
	dc.l	$575356B2
	dc.l	$56135574
	dc.l	$54D7543A
	dc.l	$539F5305
	dc.l	$526C51D5
	dc.l	$513E50A8
	dc.l	$50144F80
	dc.l	$4EEE4E5C
	dc.l	$4DCC4D3D
	dc.l	$4CAF4C21
	dc.l	$4B954B0A
	dc.l	$4A8049F7
	dc.l	$496E48E7
	dc.l	$486147DC
	dc.l	$475746D4
	dc.l	$465145D0
	dc.l	$454F44D0
	dc.l	$445143D3
	dc.l	$435642DA
	dc.l	$425F41E5
	dc.l	$416B40F3
	dc.l	$407B4005
	dc.l	$3F8F3F1A
	dc.l	$3EA53E32
	dc.l	$3DBF3D4E
	dc.l	$3CDD3C6D
	dc.l	$3BFD3B8F
	dc.l	$3B213AB4
	dc.l	$3A4839DD
	dc.l	$39723909
	dc.l	$38A03837
	dc.l	$37D03769
	dc.l	$3703369E
	dc.l	$363935D5

lbC0006F2	ADD.W	4(A0),D0
	ADD.W	6(A0),D0
	MOVEQ	#-1,D1
lbC0006FC	ADDQ.W	#1,D1
	SUBI.W	#$60,D0
	BPL.S	lbC0006FC
	ADD.W	D0,D0
	MOVE.W	lbC0006F2(PC,D0.W),D0
	LSR.W	D1,D0
	ADD.W	2(A0),D0
	RTS

lbC000712	MOVE.B	(A1)+,D0
	BNE.S	lbC00071C
	MOVE.B	(A1)+,D0
	LSL.W	#8,D0
	MOVE.B	(A1)+,D0
lbC00071C	MOVE.W	D0,$3C(A0)
	RTS

lbC000722	MOVE.B	(A1)+,D0
	LSL.W	#4,D0
	LEA	lbL000746(PC,D0.W),A2
	MOVE.L	(A2)+,8(A0)
	MOVE.W	(A2)+,12(A0)
	MOVE.L	(A2)+,14(A0)
	MOVE.W	(A2)+,$12(A0)
	MOVE.W	(A2)+,6(A0)
	MOVE.W	(A2)+,$30(A0)
	BRA.L	lbC000332

lbL000746	dc.l	0
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
	dc.l	lbL000B56
	dc.w	2
	dc.l	lbL000B56
	dc.l	$20000
	dc.w	0
	dc.l	lbL000B5A
	dc.w	4
	dc.l	lbL000B5A
	dc.l	$40000
	dc.w	0
	dc.l	lbL000B62
	dc.w	2
	dc.l	lbL000B62
	dc.l	$20000
	dc.w	0
	dc.l	lbL000B66
	dc.w	4
	dc.l	lbL000B66
	dc.l	$40000
	dc.w	0
	dc.l	lbL000B6E
	dc.w	2
	dc.l	lbL000B6E
	dc.l	$20000
	dc.w	0
	dc.l	lbL000B72
	dc.w	4
	dc.l	lbL000B72
	dc.w	4
	dc.w	0
	dc.w	0
	dc.l	lbC000394
	dc.w	$C8
	dc.l	lbC000394
	dc.l	$C80000
	dc.w	0

lbL000846	dc.l	0
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
	dc.w	$8201
	dc.w	1
	dc.w	$C080
	dc.w	$80
lbL0008A6	dc.l	0
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
	dc.w	$8202
	dc.w	2
	dc.w	$C100
	dc.w	$100
VoiceB
lbL000906	dc.l	0
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
	dc.w	$8204
	dc.w	4
	dc.w	$C200
	dc.w	$200
lbL000966	dc.l	0
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
	dc.w	$8208
	dc.w	8
	dc.w	$C400
	dc.w	$400
lbL0009C6	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	$40
lbB0009DA	dc.b	12
lbB0009DB	dc.b	$80

;lbL0009E4	dc.l	0		; start address of song
;lbL0009E8	dc.l	0		; last sample address (?) or samples address
;	dc.l	$DFA			; length of song
;lbL0009F0	incbin	'ram:mod'	; module ptr

***************************************************************************
************************** Paul Shields player (new) **********************
***************************************************************************

; Player from game Amnios (c) 1991 by Psygnosis

;End
;	LEA	$DFF000,A6
;	MOVE.W	#$780,$9A(A6)
;	MOVE.W	#15,$96(A6)
;	MOVE.W	#0,$DFF0A8
;	MOVE.W	#0,$DFF0B8
;	MOVE.W	#0,$DFF0C8
;	MOVE.W	#0,$DFF0D8
;	MOVE.L	#$1B4A,$70
;	RTS

;	MOVE.L	#$32F5E,$24BC
;	MOVEA.L	#$24C4,A4
;	BSR.L	lbC0013B0
;	BRA.L	lbC001434

;	MOVE.L	#$32F5E,$24BC
;	MOVEA.L	#$24E4,A4
;	BSR.L	lbC0013B0
;	BRA.L	lbC001434

;	CLR.W	$1C40
;	LEA	lbL001C7A(PC),A0
;	MOVEQ	#3,D0
;lbC001342	BCLR	#0,0(A0)
;	ADDA.W	#$8C,A0
;	DBRA	D0,lbC001342
;	MOVE.W	#$FFFF,$1C40
;	RTS

;	CLR.W	$1C40
;	LEA	lbL001C7A(PC),A0
;	MOVEQ	#3,D0
;lbC001366	BSET	#0,0(A0)
;	ADDA.W	#$8C,A0
;	DBRA	D0,lbC001366
;	MOVE.W	#$FFFF,$1C40
;	RTS

;lbC00137E	BTST	#6,$BFE001
;	BEQ.S	lbC00137E
;	RTS

;lbC00138A	BTST	#6,$BFE001
;	BNE.S	lbC00138A
;	RTS

;	dc.w	$2FF
;	dc.w	$8101
;	dc.w	$101
;	dc.w	$101
;	dc.w	$EC81
;	dc.w	0
;	dc.w	$19AC
;	dc.w	2
;	dc.w	0
;	dc.w	$19AC
;	dc.w	2
;	dc.w	$7F
;	dc.w	$81

InitSamples_2
;lbC0013B0	CLR.W	$1C40
;	LEA	$DFF000,A6
;	MOVE.W	#15,$96(A6)
;	MOVE.W	#$C000,$9A(A6)
;	MOVEA.L	lbL001EBC(PC),A3

	move.l	ModulePtr(PC),A3
	move.l	SamplePtr(PC),A4

	LEA	lbL001B7A(PC),A2
	MOVEQ	#15,D7
lbC0013D2
;	TST.W	$16(A3)
;	BEQ.S	lbC001400
;	MOVE.L	(A4)+,$24C0
;	TST.L	$24C0
;	BMI.L	lbC0013F6
;	ADDI.L	#$E6B8,$24C0
;	BRA.L	lbC001400

;lbC0013F6	MOVE.L	#$33922,$24C0
;lbC001400	MOVEA.L	lbL001EC0(PC),A0

	move.l	A4,A0

	MOVE.L	A0,(A2)+
	MOVE.W	$16(A3),(A2)+
	ADDA.W	$1A(A3),A0
	MOVE.W	$1C(A3),D0
	CMP.W	#2,D0
	BCC.S	lbC00141E
	MOVEQ	#2,D0
	LEA	lbL001F10,A0			; was PC
lbC00141E	MOVE.L	A0,(A2)+
	MOVE.W	D0,(A2)+
	MOVE.W	$1E(A3),(A2)+
	MOVE.W	$18(A3),(A2)+

	add.w	22(A3),A4
	add.w	22(A3),A4

	ADDA.W	#$20,A3
	DBRA	D7,lbC0013D2
	RTS

InitSong_2
lbC001434	LEA	$DFF000,A6
;	MOVEA.L	lbL001EBC(PC),A0

	move.l	ModulePtr(PC),A0

	MOVE.W	#$780,$9A(A6)
	MOVE.W	#15,$96(A6)
	MOVE.W	#$FF,$9E(A6)
	BCLR	#1,$BFE001
	LEA	lbL001EAA(PC),A5
	MOVE.L	A0,2(A5)
	ADDA.W	#$200,A0
	MOVEA.L	2(A5),A2
	ADDA.W	(A0)+,A2
	MOVE.L	A2,6(A5)
	CLR.W	12(A5)
	CLR.W	10(A5)
	LEA	lbL001E1E(PC),A1
	MOVEQ	#3,D0
lbC00147C	CLR.W	4(A1)
	CLR.W	2(A1)
	CLR.W	6(A1)
	CLR.W	$2C(A1)
	CLR.W	$30(A1)
	CLR.W	$26(A1)
	MOVE.W	(A0),$2A(A1)
	MOVE.W	(A0)+,$28(A1)
	MOVEA.L	2(A5),A2
	ADDA.W	(A0)+,A2
	MOVE.L	A2,$14(A1)
	MOVE.L	A2,$18(A1)
	LEA	lbB001EBA(PC),A2
	MOVE.L	A2,$20(A1)
	MOVE.W	#1,$3E(A1)
	MOVE.W	#1,$3C(A1)
	MOVE.W	#1,12(A1)
	MOVE.W	#1,$12(A1)
	LEA	lbL001F10,A2				; was PC
	MOVE.L	A2,8(A1)
	MOVE.L	A2,14(A1)
	LEA	lbB001EBB(PC),A2
	MOVE.L	A2,$40(A1)
	MOVE.L	A2,$44(A1)
	MOVE.L	A2,$4C(A1)
	MOVE.L	A2,$50(A1)
	MOVE.B	#1,0(A1)
	SUBA.W	#$8C,A1
	DBRA	D0,lbC00147C
;	MOVE.W	#$FFFF,$1C40
	RTS

;	CLR.B	$58(A0)
;	MOVE.W	D0,$5E(A0)
;	MOVE.W	D1,$5A(A0)
;	MOVE.W	D2,$5C(A0)
;	MOVE.B	(A1),$82(A0)
;	MOVE.B	(A1)+,$80(A0)
;	MOVE.L	A1,$7C(A0)
;	MOVE.L	A1,$78(A0)
;	MOVE.B	(A2),$76(A0)
;	MOVE.B	(A2)+,$74(A0)
;	MOVE.L	A2,$70(A0)
;	MOVE.L	A2,$6C(A0)
;	MOVE.L	(A3)+,$60(A0)
;	MOVE.W	(A3)+,$64(A0)
;	MOVE.L	(A3)+,$66(A0)
;	MOVE.W	(A3)+,$6A(A0)
;	MOVE.B	#1,$58(A0)
;	RTS

;	MOVEM.L	D0/A0/A6,-(SP)
;	LEA	$DFF000,A6
;	MOVEQ	#$20,D0
;lbC001556	DBRA	D0,lbC001556
;	MOVE.W	$1E(A6),D0
;	ANDI.W	#$780,D0
;	MOVE.W	D0,$9A(A6)
;	MOVE.W	D0,$9C(A6)

Audio_2
	move.w	IntenaTemp(PC),D0

	BTST	#10,D0
	BEQ.S	lbC001594
	LEA	lbL001E1E(PC),A0
;	TST.B	$58(A0)
;	BEQ.S	lbC001588
;	MOVE.L	$66(A0),$D0(A6)
;	MOVE.W	$6A(A0),$D4(A6)
;	BRA.S	lbC001594

lbC001588	MOVE.L	14(A0),$D0(A6)
	MOVE.W	$12(A0),$D4(A6)
lbC001594	BTST	#9,D0
	BEQ.S	lbC0015BE
	LEA	lbL001D92(PC),A0
;	TST.B	$58(A0)
;	BEQ.S	lbC0015B2
;	MOVE.L	$66(A0),$C0(A6)
;	MOVE.W	$6A(A0),$C4(A6)
;	BRA.S	lbC0015BE

lbC0015B2	MOVE.L	14(A0),$C0(A6)
	MOVE.W	$12(A0),$C4(A6)
lbC0015BE	BTST	#8,D0
	BEQ.S	lbC0015E8
	LEA	lbL001D06(PC),A0
;	TST.B	$58(A0)
;	BEQ.S	lbC0015DC
;	MOVE.L	$66(A0),$B0(A6)
;	MOVE.W	$6A(A0),$B4(A6)
;	BRA.S	lbC0015E8

lbC0015DC	MOVE.L	14(A0),$B0(A6)
	MOVE.W	$12(A0),$B4(A6)
lbC0015E8	BTST	#7,D0
	BEQ.S	lbC001612
	LEA	lbL001C7A(PC),A0
;	TST.B	$58(A0)
;	BEQ.S	lbC001606
;	MOVE.L	$66(A0),$A0(A6)
;	MOVE.W	$6A(A0),$A4(A6)
;	BRA.S	lbC001612

lbC001606	MOVE.L	14(A0),$A0(A6)
	MOVE.W	$12(A0),$A4(A6)
lbC001612
;	MOVEM.L	(SP)+,D0/A0/A6
;	RTE

	rts

;	MOVEM.L	D0-D2/A0-A2/A4-A6,-(SP)
;	LEA	$DFF000,A6
;	MOVE.W	$1E(A6),D0
;	AND.W	lbW001640(PC),D0
;	BTST	#5,D0
;	BEQ.S	lbC001634
;	BSR.L	lbC001642
;lbC001634	MOVEM.L	(SP)+,D0-D2/A0-A2/A4-A6
;	RTS

;	JMP	$1E240

;lbW001640	dc.w	0

Play_2
lbC001642	LEA	lbL001EAA(PC),A5
lbC001646	LEA	$DFF000,A6
;	MOVE.W	12(A5),D0
;	ANDI.W	#$780,D0
;	MOVE.W	D0,$9C(A6)
;	MOVE.W	12(A5),$9A(A6)

	move.w	12(A5),IntenaTemp

	MOVE.W	10(A5),$96(A6)
	CLR.W	10(A5)
	CLR.W	12(A5)
	LEA	lbL001E1E(PC),A0
	LEA	$D0(A6),A4
	MOVEQ	#3,D2
lbC001676	BTST	#0,0(A0)
	BEQ.L	lbC0018CC
	SUBQ.W	#1,$26(A0)
	BNE.S	lbC0016A2
	MOVE.W	$2A(A0),D0
	CMP.W	$28(A0),D0
	BEQ.S	lbC0016A2
	BCS.S	lbC001698
	SUBQ.W	#1,$2A(A0)
	BRA.S	lbC00169C

lbC001698	ADDQ.W	#1,$2A(A0)
lbC00169C	MOVE.W	$24(A0),$26(A0)
lbC0016A2	SUBQ.W	#1,$3C(A0)
	BNE.L	lbC0017EA
	BTST	#2,$58(A0)
	BEQ.S	lbC0016B6
	CLR.B	$58(A0)
lbC0016B6	MOVEA.L	$20(A0),A1
lbC0016BA	CLR.W	D0
	MOVE.B	(A1)+,D0
	BPL.L	lbC00174C
;	JMP	lbC001646(PC,D0.W)

	jmp	Here-128(PC,D0.W)
Here

	BRA.L	lbC0017DA

	BRA.L	lbC001700

	BRA.L	lbC0016F6

	BRA.L	lbC001B20

	BRA.L	lbC001976

	BRA.L	lbC0016EC

	BRA.L	lbC0016E2

lbC0016E2	BSET	#1,$BFE001
	BRA.S	lbC0016BA

lbC0016EC	BCLR	#1,$BFE001
	BRA.S	lbC0016BA

lbC0016F6	MOVE.B	(A1),$2D(A0)
	MOVE.B	(A1)+,$2F(A0)
	BRA.S	lbC0016BA

lbC001700	MOVE.B	(A1)+,D0
	LSL.W	#3,D0
	MOVE.W	D0,$34(A0)
	CLR.W	D0
	MOVE.B	(A1)+,D0
	LSL.W	#3,D0
	SUB.W	$34(A0),D0
	CLR.L	D1
	MOVE.W	D0,D1
	BMI.L	lbC001730
	CLR.W	D0
	BSR.L	lbC001B10
	DIVU.W	D0,D1
	MOVE.W	D1,$38(A0)
	CLR.W	D1
	DIVU.W	D0,D1
	MOVE.W	D1,$3A(A0)
	BRA.S	lbC00175C

lbC001730	NEG.W	D1
	CLR.W	D0
	BSR.L	lbC001B10
	DIVU.W	D0,D1
	MOVE.W	D1,$38(A0)
	CLR.W	D1
	DIVU.W	D0,D1
	MOVE.W	D1,$3A(A0)
	NEG.L	$38(A0)
	BRA.S	lbC00175C

lbC00174C	LSL.W	#3,D0
	MOVE.W	D0,$34(A0)
	CLR.W	D0
	BSR.L	lbC001B10
	CLR.L	$38(A0)
lbC00175C	MOVE.W	$2C(A0),D0
	BNE.S	lbC001766
	MOVE.W	$30(A0),D0
lbC001766	MOVE.W	D0,$2E(A0)
	MOVE.B	$54(A0),$56(A0)
	MOVE.L	$4C(A0),$50(A0)
	MOVE.B	$48(A0),$4A(A0)
	MOVE.L	$40(A0),$44(A0)
	BCLR	#1,0(A0)
	MOVE.L	A1,$20(A0)
	TST.W	$58(A0)
	BNE.L	lbC0018D2
	MOVE.W	$86(A0),$96(A6)
;	MOVE.W	$8A(A0),$9A(A6)
	MOVE.W	$88(A0),D0
	OR.W	D0,12(A5)
	MOVE.W	$84(A0),D0
	OR.W	D0,10(A5)
	MOVE.L	8(A0),0(A4)
	MOVE.W	12(A0),4(A4)

	bsr.w	SetAll

lbC0017BC	SUBQ.B	#1,$56(A0)
	BNE.S	lbC00180E
	MOVEA.L	$50(A0),A1
lbC0017C6	MOVE.B	(A1)+,D0
	CMP.B	#$80,D0
	BEQ.S	lbC00180E
	CMP.B	#$81,D0
	BNE.S	lbC0017FE
	MOVEA.L	$4C(A0),A1
	BRA.S	lbC0017C6

lbC0017DA	BSET	#1,0(A0)
	BSR.L	lbC001B10
	MOVE.L	A1,$20(A0)
	BRA.S	lbC00180E

lbC0017EA	BTST	#1,0(A0)
	BEQ.S	lbC0017BC
	TST.W	$2E(A0)
	BMI.S	lbC00180E
	SUBQ.W	#2,$2E(A0)
	BRA.S	lbC00180E

lbC0017FE	EXT.W	D0
	ADD.W	D0,$2E(A0)
	MOVE.B	$54(A0),$56(A0)
	MOVE.L	A1,$50(A0)
lbC00180E	MOVE.L	$38(A0),D0
	ADD.L	D0,$34(A0)
	TST.B	$58(A0)
	BNE.L	lbC0018D2
	SUBQ.B	#1,$4A(A0)
	BNE.S	lbC00184C
	MOVEA.L	$44(A0),A1
lbC001828	MOVE.B	(A1)+,D0
	CMP.B	#$80,D0
	BEQ.S	lbC00184C
	CMP.B	#$81,D0
	BNE.S	lbC00183C
	MOVEA.L	$40(A0),A1
	BRA.S	lbC001828

lbC00183C	EXT.W	D0
	ADD.W	D0,$34(A0)
	MOVE.B	$48(A0),$4A(A0)
	MOVE.L	A1,$44(A0)
lbC00184C	MOVE.W	$34(A0),D0
	BSR.L	lbC001AEA
	MOVE.W	D0,6(A4)
	MOVE.W	$2A(A0),D0
	ADD.W	$2E(A0),D0
	SUB.W	14(A5),D0
	MOVE.W	D0,$32(A0)
	BPL.S	lbC00186E
	CLR.W	D0
	BRA.S	lbC001876

lbC00186E	CMP.W	#$40,D0
	BLE.S	lbC001876
	MOVEQ	#$40,D0
lbC001876
;	MOVE.W	D0,8(A4)

	bsr.w	ChangeVolume
	bsr.w	SetVol

lbC00187A	SUBA.W	#$8C,A0
	SUBA.W	#$10,A4
	DBRA	D2,lbC001676
	RTS

lbC001888	MOVE.W	$86(A0),$96(A6)
;	MOVE.W	$8A(A0),$9A(A6)
	MOVE.W	$88(A0),D0
	OR.W	D0,12(A5)
	MOVE.W	$84(A0),D0
	OR.W	D0,10(A5)
	MOVE.B	#2,$58(A0)
	MOVE.L	$60(A0),0(A4)
	MOVE.W	$64(A0),4(A4)
	BRA.S	lbC00187A

lbC0018B8	BSET	#2,$58(A0)
;	MOVE.W	$8A(A0),$9A(A6)
	MOVE.W	$86(A0),$96(A6)
	BRA.S	lbC00187A

lbC0018CC	TST.B	$58(A0)
	BEQ.S	lbC00187A
lbC0018D2	BTST	#0,$58(A0)
	BNE.S	lbC001888
	SUBQ.W	#1,$5A(A0)
	BMI.S	lbC0018B8
	SUBQ.B	#1,$82(A0)
	BNE.S	lbC00190E
	MOVEA.L	$7C(A0),A1
lbC0018EA	MOVE.B	(A1)+,D0
	CMP.B	#$80,D0
	BEQ.S	lbC00190E
	CMP.B	#$81,D0
	BNE.S	lbC0018FE
	MOVEA.L	$78(A0),A1
	BRA.S	lbC0018EA

lbC0018FE	EXT.W	D0
	ADD.W	D0,$5C(A0)
	MOVE.B	$80(A0),$82(A0)
	MOVE.L	A1,$7C(A0)
lbC00190E	MOVE.W	$5C(A0),D0
	BPL.S	lbC001918
	CLR.W	D0
	BRA.S	lbC001920

lbC001918	CMP.W	#$40,D0
	BLE.S	lbC001920
	MOVEQ	#$40,D0
lbC001920	MOVE.W	D0,8(A4)
	SUBQ.B	#1,$76(A0)
	BNE.S	lbC001952
	MOVEA.L	$70(A0),A1
lbC00192E	MOVE.B	(A1)+,D0
	CMP.B	#$80,D0
	BEQ.S	lbC001952
	CMP.B	#$81,D0
	BNE.S	lbC001942
	MOVEA.L	$6C(A0),A1
	BRA.S	lbC00192E

lbC001942	EXT.W	D0
	ADD.W	D0,$5E(A0)
	MOVE.B	$74(A0),$76(A0)
	MOVE.L	A1,$70(A0)
lbC001952	MOVE.W	$5E(A0),D0
	MOVE.W	D0,6(A4)
	BRA.L	lbC00187A

	BRA.L	lbC00198E

	BRA.L	lbC0019FA

	BRA.L	lbC001996

	BRA.L	lbC0019B0

	BRA.L	lbC0019A4

	BRA.L	lbC0019AA

lbC001976	SUBQ.W	#1,$3E(A0)
	BNE.L	lbC001A22
	MOVEA.L	$18(A0),A2
lbC001982	MOVE.W	(A2)+,D0
	CMP.W	#$FFE8,D0
	BCS.w	lbC001A00
	JMP	lbC001976(PC,D0.W)

lbC00198E	CLR.B	0(A0)

	bsr.w	SongEnd

	BRA.L	lbC0018CC

lbC001996	MOVE.W	(A2)+,$28(A0)
	MOVE.W	(A2),$24(A0)
	MOVE.W	(A2)+,$26(A0)
	BRA.S	lbC001982

lbC0019A4	MOVE.W	(A2)+,2(A0)
	BRA.S	lbC001982

lbC0019AA	MOVE.W	(A2)+,4(A0)
	BRA.S	lbC001982

lbC0019B0	PEA	(A0)
	MOVE.W	(A2)+,D0
	MOVE.W	(A2)+,D1
	LEA	lbL001C7A(PC),A0
	MOVE.W	D0,$28(A0)
	MOVE.W	D1,$24(A0)
	MOVE.W	D1,$26(A0)
	LEA	lbL001D06(PC),A0
	MOVE.W	D0,$28(A0)
	MOVE.W	D1,$24(A0)
	MOVE.W	D1,$26(A0)
	LEA	lbL001D92(PC),A0
	MOVE.W	D0,$28(A0)
	MOVE.W	D1,$24(A0)
	MOVE.W	D1,$26(A0)
	LEA	lbL001E1E(PC),A0
	MOVE.W	D0,$28(A0)
	MOVE.W	D1,$24(A0)
	MOVE.W	D1,$26(A0)
	MOVEA.L	(SP)+,A0
	BRA.S	lbC001982

lbC0019FA	MOVEA.L	$14(A0),A2

	cmp.l	#$DFF0A0,A4
	bne.b	Skipi2
	bsr.w	SongEnd
Skipi2

	BRA.w	lbC001982

lbC001A00	MOVE.W	#1,$3E(A0)
	BCLR	#15,D0
	BEQ.S	lbC001A10
	MOVE.W	(A2)+,$3E(A0)
lbC001A10	MOVEA.L	2(A5),A1
	ADDA.W	D0,A1
	MOVE.L	A1,$1C(A0)
	MOVE.L	A2,$18(A0)
	BRA.L	lbC0016BA

lbC001A22	MOVEA.L	$1C(A0),A1
	BRA.L	lbC0016BA

	dc.w	$6AE4
	dc.w	$6A1F
	dc.w	$695C
	dc.w	$689A
	dc.w	$67D9
	dc.w	$671A
	dc.w	$665C
	dc.w	$659F
	dc.w	$64E4
	dc.w	$642A
	dc.w	$6372
	dc.w	$62BB
	dc.w	$6205
	dc.w	$6150
	dc.w	$609D
	dc.w	$5FEB
	dc.w	$5F3A
	dc.w	$5E8B
	dc.w	$5DDD
	dc.w	$5D30
	dc.w	$5C84
	dc.w	$5BDA
	dc.w	$5B31
	dc.w	$5A89
	dc.w	$59E2
	dc.w	$593D
	dc.w	$5898
	dc.w	$57F5
	dc.w	$5753
	dc.w	$56B2
	dc.w	$5613
	dc.w	$5574
	dc.w	$54D7
	dc.w	$543A
	dc.w	$539F
	dc.w	$5305
	dc.w	$526C
	dc.w	$51D5
	dc.w	$513E
	dc.w	$50A8
	dc.w	$5014
	dc.w	$4F80
	dc.w	$4EEE
	dc.w	$4E5C
	dc.w	$4DCC
	dc.w	$4D3D
	dc.w	$4CAF
	dc.w	$4C21
	dc.w	$4B95
	dc.w	$4B0A
	dc.w	$4A80
	dc.w	$49F7
	dc.w	$496E
	dc.w	$48E7
	dc.w	$4861
	dc.w	$47DC
	dc.w	$4757
	dc.w	$46D4
	dc.w	$4651
	dc.w	$45D0
	dc.w	$454F
	dc.w	$44D0
	dc.w	$4451
	dc.w	$43D3
	dc.w	$4356
	dc.w	$42DA
	dc.w	$425F
	dc.w	$41E5
	dc.w	$416B
	dc.w	$40F3
	dc.w	$407B
	dc.w	$4005
	dc.w	$3F8F
	dc.w	$3F1A
	dc.w	$3EA5
	dc.w	$3E32
	dc.w	$3DBF
	dc.w	$3D4E
	dc.w	$3CDD
	dc.w	$3C6D
	dc.w	$3BFD
	dc.w	$3B8F
	dc.w	$3B21
	dc.w	$3AB4
	dc.w	$3A48
	dc.w	$39DD
	dc.w	$3972
	dc.w	$3909
	dc.w	$38A0
	dc.w	$3837
	dc.w	$37D0
	dc.w	$3769
	dc.w	$3703
	dc.w	$369E
	dc.w	$3639
	dc.w	$35D5

lbC001AEA	ADD.W	4(A0),D0
	ADD.W	6(A0),D0
	BMI.S	lbC001B0C
	MOVEQ	#-1,D1
lbC001AF6	ADDQ.W	#1,D1
	SUBI.W	#$60,D0
	BPL.S	lbC001AF6
	ADD.W	D0,D0
	MOVE.W	lbC001AEA(PC,D0.W),D0
	LSR.W	D1,D0
	ADD.W	2(A0),D0
	RTS

lbC001B0C	MOVEQ	#-1,D0
	RTS

lbC001B10	MOVE.B	(A1)+,D0
	BNE.S	lbC001B1A
	MOVE.B	(A1)+,D0
	LSL.W	#8,D0
	MOVE.B	(A1)+,D0
lbC001B1A	MOVE.W	D0,$3C(A0)
	RTS

lbC001B20	MOVE.B	(A1)+,D0
	PEA	(A1)
	MOVEA.L	6(A5),A1
	ADDA.W	D0,A1
	MOVE.W	(A1)+,D0
	LEA	lbL001B7A(PC,D0.W),A2
	MOVE.L	(A2)+,8(A0)
	MOVE.W	(A2)+,12(A0)
	MOVE.L	(A2)+,14(A0)
	MOVE.W	(A2)+,$12(A0)
	MOVE.W	(A2)+,6(A0)
	MOVE.W	(A2)+,$30(A0)
	MOVEA.L	2(A5),A2
	ADDA.W	(A1)+,A2
	MOVE.B	(A2),$56(A0)
	MOVE.B	(A2)+,$54(A0)
	MOVE.L	A2,$50(A0)
	MOVE.L	A2,$4C(A0)
	MOVEA.L	2(A5),A2
	ADDA.W	(A1)+,A2
	MOVE.B	(A2),$4A(A0)
	MOVE.B	(A2)+,$48(A0)
	MOVE.L	A2,$44(A0)
	MOVE.L	A2,$40(A0)
	MOVEA.L	(SP)+,A1
	BRA.L	lbC0016BA

lbL001B7A	dc.l	0
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
lbL001C7A	dc.l	0
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
	dc.l	$82010001
	dc.l	$C0800080
lbL001D06	dc.l	0
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
	dc.l	$82020002
	dc.l	$C1000100
lbL001D92	dc.l	0
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
	dc.l	$82040004
	dc.l	$C2000200
VoiceA
lbL001E1E	dc.l	0
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
	dc.l	$82080008
	dc.l	$C4000400
lbL001EAA	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	$40
lbB001EBA	dc.b	$90
lbB001EBB	dc.b	$80
;lbL001EBC	dc.l	0
;lbL001EC0	dc.l	0
;	dc.l	0
;	dc.l	$1FA4
;	dc.l	$7AA8
;	dc.l	$87F0
;	dc.l	$FFFFFFFF
;	dc.l	$17D4
;	dc.l	$D48
;	dc.l	$8CA0
;	dc.l	0
;	dc.l	$D48
;	dc.l	$17D4
;	dc.l	$8CA0
;	dc.l	$1FA4
;	dc.l	$332C
;	dc.l	$5460
;	dc.l	$959C
;	dc.l	$5460
;	dc.l	$7AA8
;	dc.l	$87F0

	Section	Synth,Data_C

lbL000B56
	dc.l	$7F7F8181
lbL000B5A
	dc.l	$7F7F7F7F
	dc.l	$81818181
lbL000B62
	dc.l	$7F0081
lbL000B66
	dc.l	$597F59
	dc.l	$A781A7
lbL000B6E
	dc.l	$7F2AD580
lbL000B72
	dc.l	$7F5A3611
	dc.l	$EEC9A580

lbL001F10
	ds.b	8
lbL0009DC
	ds.b	16
lbC000394						; trash sample
	dc.l	$48E7E0EE
	dc.l	$4BFA078E
	dc.l	$4DF900DF
	dc.l	$F000302D
	dc.l	$180240
	dc.l	$7803D40
	dc.l	$9C3D6D
	dc.l	$18009A
	dc.l	$3D6D0016
	dc.l	$96426D
	dc.l	$16426D
	dc.l	$184A39
	dc.l	$A8BC
	dc.l	$670C0C6D
	dc.l	$40001A
	dc.l	$6704536D
	dc.l	$1A4A39
	dc.l	$A8BD
	dc.l	$670C0C6D
	dc.l	$80001A
	dc.l	$6704526D
	dc.l	$1A41FA
	dc.l	$6DE49EE
	dc.l	$D0343C
	dc.l	$30828
	dc.l	$2C
	dc.l	$6700031A
	dc.l	$5368004E
	dc.l	$661C3028
	dc.l	$52B068
	dc.l	$506712
	dc.l	$65065368
	dc.l	$526004
	dc.l	$52680052
	dc.l	$3168004C
	dc.l	$4E5368
	dc.l	$286600
	dc.l	$2422268
	dc.l	$C4240
	dc.l	$10194EFB
	dc.l	$26000
	dc.l	$1C46000
	dc.l	$3E46000
	dc.l	$1A86000
	dc.l	$2E6000
	dc.l	$1A86000
	dc.l	$16A6000
	dc.l	$1426000
	dc.l	$16A6000
	dc.l	$CE6000
	dc.l	$2E6000
	dc.l	$386000
	dc.l	$8A6000
	dc.l	$B66000
	dc.l	$386000
	dc.l	$2E5368
	dc.l	$2A6600
	dc.l	$9E2468
	dc.l	$4301A
	dc.l	$B07CFFE8
	dc.l	$656E4EFB
	dc.l	$EA315A
	dc.l	$503152
	dc.l	$4C315A
	dc.l	$4E60E6
	dc.l	$315A0030
	dc.l	$60E0315A
	dc.l	$2E60DA
	dc.l	$4850301A
	dc.l	$321A41FA
	dc.l	$5043140
	dc.l	$503141
	dc.l	$4C3141
	dc.l	$4E41FA
	dc.l	$5523140
	dc.l	$503141
	dc.l	$4C3141
	dc.l	$4E41FA
	dc.l	$5A03140
	dc.l	$503141
	dc.l	$4C3141
	dc.l	$4E41FA
	dc.l	$5EE3140
	dc.l	$503141
	dc.l	$4C3141
	dc.l	$4E205F
	dc.l	$60902468
	dc.l	$608A
	dc.l	$317C0001
	dc.l	$2A0880
	dc.l	$F6704
	dc.l	$315A002A
	dc.l	$226D000A
	dc.l	$D2C02149
	dc.l	$8214A
	dc.l	$46000
	dc.l	$FF1A2268
	dc.l	$86000
	dc.l	$FF124268
	dc.l	$2C6000

	*****************************************************
	****        MMDC replayer for EaglePlayer	 ****
	****        all adaptions by Wanted Team,	 ****
	****      DeliTracker compatible (?) version	 ****
	*****************************************************

	incdir	"dh2:include/"
	include 'misc/eagleplayer2.01.i'

	SECTION	Player_Code,CODE

	PLAYERHEADER Tags

	dc.b	'$VER: MED Packer player module V1.2 (8 Mar 2003)',0
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
	dc.l	DTP_Volume,SetVolume
	dc.l	DTP_Balance,SetBalance
	dc.l	EP_Voices,SetVoices
	dc.l	EP_StructInit,StructInit
	dc.l	EP_GetPositionNr,GetPosition
	dc.l	DTP_NextPatt,Next_Pattern
	dc.l	DTP_PrevPatt,BackPattern
	dc.l	EP_SampleInit,SampleInit
	dc.l	EP_Flags,EPB_Volume!EPB_Balance!EPB_ModuleInfo!EPB_Voices!EPB_SampleInfo!EPB_Songend!EPB_Analyzer!EPB_Packable!EPB_Restart!EPB_PrevPatt!EPB_NextPatt
	dc.l	0

PlayerName
	dc.b	'MED Packer',0
Creator
	dc.b	'(c) 1991 Antony ''Ratt'' Crowther,',10
	dc.b	'adapted by Wanted Team',0
Prefix
	dc.b	'MMDC.',0
	even
ModulePtr
	dc.l	0
EagleBase
	dc.l	0
BaseA0
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
******************************* EP_SampleInit *****************************
***************************************************************************

SampleInit
	moveq	#EPR_NotEnoughMem,D7
	lea	EPG_SampleInfoStructure(A5),A3
	move.l	ModulePtr(PC),D0
	beq.b	return
	move.l	D0,A0

	move.l	InfoBuffer+Samples(PC),D5
	subq.l	#1,D5
	add.l	24(A0),A0
hop
	jsr	ENPP_AllocSampleStruct(A5)
	move.l	D0,(A3)
	beq.b	return
	move.l	D0,A3

	move.l	(A0)+,D1
	bne.b	NoEmpty
	move.l	#Empty,D1
NoEmpty
	move.l	D1,A1
	move.l	A1,EPS_Adr(A3)			; sample address
	move.l	(A1),EPS_Length(A3)		; sample length
	move.l	#64,EPS_Volume(A3)
	move.w	#USITY_RAW,EPS_Type(A3)
	move.w	#USIB_Playable!USIB_Saveable!USIB_8BIT,EPS_Flags(A3)
	dbf	D5,hop

	moveq	#0,D7
return
	move.l	D7,D0
	rts

***************************************************************************
******************************* DTP_NextPatt ******************************
***************************************************************************

Next_Pattern
	move.w	lbL000AF2+$2E(PC),D7
	move.l	dtg_StopInt(A5),A0
	jsr	(A0)
	bsr.w	InitSong
	addq.w	#1,D7
	cmp.w	InfoBuffer+Length+2(PC),D7
	bgt.b	MaxPos
	move.w	D7,lbL000AF2+$2E
	lea	lbL000AF2(PC),A4
	move.l	BaseA0(PC),A0
	bsr.w	SetPosition
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
	move.w	lbL000AF2+$2E(PC),D7
	beq.b	MinPos
	move.l	dtg_StopInt(A5),A0
	jsr	(A0)
	bsr.w	InitSong
	subq.w	#1,D7
	move.w	D7,lbL000AF2+$2E
	lea	lbL000AF2(PC),A4
	move.l	BaseA0(PC),A0
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
	dc.l	MI_MaxSamples,64
	dc.l	MI_Prefix,Prefix
	dc.l	0

***************************************************************************
******************************* DTP_Check2 ********************************
***************************************************************************

Check2
	movea.l	dtg_ChkData(A5),A0
	moveq	#-1,D0

	cmp.l	#'MMDC',(A0)
	bne.b	Fault
	tst.w	16(A0)
	bne.b	Fault
	move.w	18(A0),D1
	beq.b	Fault
	bmi.b	Fault
	btst	#0,D1
	bne.b	Fault
	lea	(A0,D1.W),A0
	tst.w	(A0)
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

	move.l	4(A0),D2
	cmp.l	D0,D2
	ble.b	SizeOK
	moveq	#EPR_ModuleTooShort,D0
	rts
SizeOK
	move.l	D2,CalcSize(A4)
	move.w	556(A0),Pattern+2(A4)
	move.w	558(A0),Length+2(A4)
	move.l	A0,A1
	add.l	16(A0),A1
	move.l	(A1),D0
	move.l	24(A0),D1
	sub.l	D1,D0
	lsr.l	#2,D0
	move.l	D0,Samples(A4)
	move.l	(A0,D1.L),D0
	move.l	D0,SongSize(A4)
	sub.l	D0,D2
	move.l	D2,SamplesSize(A4)

	bsr.w	InitModule

	move.l	A5,(A6)				; EagleBase

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
	move.w	lbL000AF2+$2E(PC),D0
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
	move.l	D1,-(A7)
	and.w	#$7F,D5
	move.l	A1,D1
	cmp.w	#$F0A0,D1
	beq.s	Left1
	cmp.w	#$F0B0,D1
	beq.s	Right1
	cmp.w	#$F0C0,D1
	beq.s	Right2
	cmp.w	#$F0D0,D1
	bne.s	Exit2
Left2
	mulu.w	LeftVolume(PC),D5
	and.w	Voice4(PC),D5
	bra.s	Ex
Left1
	mulu.w	LeftVolume(PC),D5
	and.w	Voice1(PC),D5
	bra.s	Ex
Right1
	mulu.w	RightVolume(PC),D5
	and.w	Voice2(PC),D5
	bra.s	Ex
Right2
	mulu.w	RightVolume(PC),D5
	and.w	Voice3(PC),D5
Ex
	lsr.w	#6,D5
	move.w	D5,8(A1)
Exit2
	move.l	(A7)+,D1
	rts

*------------------------------- Set Vol -------------------------------*

SetVol
	move.l	A0,-(A7)
	lea	StructAdr+UPS_Voice1Vol(PC),A0
	cmp.l	#$DFF0A0,A1
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice2Vol(PC),A0
	cmp.l	#$DFF0B0,A1
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice3Vol(PC),A0
	cmp.l	#$DFF0C0,A1
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice4Vol(PC),A0
.SetVoice
	move.w	D5,(A0)
	move.l	(A7)+,A0
	rts

*------------------------------- Set Adr -------------------------------*

SetAdr
	move.l	A0,-(A7)
	lea	StructAdr+UPS_Voice1Adr(PC),A0
	cmp.l	#$DFF0A0,A1
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice2Adr(PC),A0
	cmp.l	#$DFF0B0,A1
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice3Adr(PC),A0
	cmp.l	#$DFF0C0,A1
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
	cmp.l	#$DFF0A0,A1
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice2Len(PC),A0
	cmp.l	#$DFF0B0,A1
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice3Len(PC),A0
	cmp.l	#$DFF0C0,A1
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
	cmp.l	#$DFF0A0,A1
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice2Per(PC),A0
	cmp.l	#$DFF0B0,A1
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice3Per(PC),A0
	cmp.l	#$DFF0C0,A1
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice4Per(PC),A0
.SetVoice
	move.w	D5,(A0)
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
***************************** DTP_InitSound *******************************
***************************************************************************

InitSound
	lea	StructAdr(PC),A0
	lea	UPS_SizeOF(A0),A1
ClearUPS
	clr.w	(A0)+
	cmp.l	A0,A1
	bne.b	ClearUPS
	bsr.w	InitPlay
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
***************************** DTP_Interrupt *******************************
***************************************************************************

Interrupt
	movem.l	D1-A6,-(A7)

	lea	StructAdr(PC),A0
	st	UPS_Enabled(A0)
	clr.w	UPS_Voice1Per(A0)
	clr.w	UPS_Voice2Per(A0)
	clr.w	UPS_Voice3Per(A0)
	clr.w	UPS_Voice4Per(A0)
	move.w	#UPSB_Adr!UPSB_Len!UPSB_Per!UPSB_Vol,UPS_Flags(A0)

	bsr.w	Play

	lea	StructAdr(PC),A0
	clr.w	UPS_Enabled(A0)

	movem.l	(A7)+,D1-A6
	moveq	#0,D0
	rts

SongEnd
	movem.l	A1/A5,-(A7)
	move.l	EagleBase(PC),A5
	move.l	dtg_SongEnd(A5),A1
	jsr	(A1)
	movem.l	(A7)+,A1/A5
	rts

***************************************************************************
******************************* MMDC player *******************************
***************************************************************************

; Player from game Knightmare (c) 1991 by Mindscape

;	BRA.L	lbC000014

;	BSR.L	lbC000ACC
;	MOVEQ	#-1,D0
;lbC00000A	DBRA	D0,lbC00000A
;	BSR.L	lbC0009AA
;	RTS

;lbC000014	BSR.L	lbC000906
;	LEA	MMDC.MSG(PC),A0
;	BSR.L	lbC000026
;	BSR.L	lbC000A10
;	RTS

InitModule
lbC000026	MOVEM.L	D0-D7/A0-A6,-(SP)
	BSR.S	lbC00006E
	LEA	lbL000AF2(PC),A2
	MOVE.L	A0,D0
	ADD.L	D0,$10(A2)
	ADD.L	D0,8(A2)
	ADD.L	D0,$18(A2)
	MOVEA.L	$10(A2),A1
	MOVE.L	$18(A2),D1
	SUB.L	A1,D1
	LSR.W	#2,D1
	SUBQ.W	#1,D1
lbC00004C	ADD.L	D0,(A1)+
	DBRA	D1,lbC00004C
	MOVEA.L	$10(A2),A3
	MOVEA.L	(A3),A3
lbC000058	CMPA.L	A3,A1
	BEQ.S	lbC000068
	BHI.S	lbC000068
	TST.L	(A1)+
	BEQ.S	lbC000058
	ADD.L	D0,-4(A1)
	BRA.S	lbC000058

lbC000068	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTS

lbC00006E	MOVEM.L	D0/A0/A1,-(SP)
	LEA	lbL000AF2(PC),A1
	MOVEQ	#15,D0
lbC000078	MOVE.L	(A0)+,(A1)+
	DBRA	D0,lbC000078
	MOVEM.L	(SP)+,D0/A0/A1
	RTS

lbC000084	CMP.B	#3,D0
	BHI.S	lbC000094
	MOVEQ	#1,D1
	LSL.W	D0,D1
	MOVE.W	D1,$DFF096				; DMA
lbC000094	RTS

lbC000096	CLR.W	D1
	CLR.W	D2
	MOVE.B	$312(A6),D1
	LEA	$302(A6),A0
	MOVE.B	0(A0,D7.W),D2
	MULU.W	D2,D0
	MULU.W	D1,D0
	LSR.L	#4,D0
	LSR.W	#8,D0
	RTS

lbW0000B0	dc.w	0

lbC0000B2	MOVEM.L	D3-D7,-(SP)
	MOVE.W	D2,-(SP)
	CLR.L	D4
	BSET	D0,D4
	MOVEA.L	$18(A4),A0
	MOVE.W	D3,D7
	LSL.W	#2,D7
	TST.L	0(A0,D7.W)
	BEQ.L	lbC000160
	ADD.B	$2FE(A6),D1
	ADD.B	7(A3),D1
	CMP.B	#3,D0
	BHI.S	lbC0000E8
	BTST	D0,lbW0000B0(PC)
	BNE.L	lbC000160
	MOVE.W	D4,$DFF096				; DMA
lbC0000E8	TST.B	D1
	BPL.S	lbC0000F2
	ADDI.B	#12,D1
	BRA.S	lbC0000E8

lbC0000F2	CMP.B	#$3F,D1
	BLE.S	lbC0000FC
	SUBI.B	#12,D1
lbC0000FC	CMP.B	#3,D0
	BHI.L	lbC000160
	OR.W	D4,lbW0001BE-lbL000AF2(A4)
	SUBQ.B	#1,D1
	MOVEA.L	10(A5),A1
	MOVEA.L	$18(A4),A0
	MOVEA.L	0(A0,D7.W),A0
	ADD.W	D3,D3
	BSR.L	lbC00086C
	MOVE.L	D0,0(A1)				; address ?

	bsr.w	SetAdr

	CMP.W	#1,D3
	BHI.S	lbC00013A
;	MOVE.L	lbL000BE0(PC),14(A5)		; bug !

	move.l	#Empty,14(A5)

	MOVE.W	#1,$12(A5)
	LSR.L	#1,D1
	MOVE.W	D1,4(A1)				; length ?

	bsr.w	SetLen

	BRA.S	lbC000154

lbC00013A	TST.W	D2
	BEQ.S	lbC000144
	MOVE.W	D2,4(A1)				; length ?

	move.l	D1,-(SP)
	move.l	D2,D1
	bsr.w	SetLen
	move.l	(SP)+,D1

	BRA.S	lbC000148

lbC000144	MOVE.W	D3,4(A1)			; length ?

	move.l	D1,-(SP)
	move.l	D3,D1
	bsr.w	SetLen
	move.l	(SP)+,D1

lbC000148	ADD.L	D2,D2
	ADD.L	D2,D0
	MOVE.L	D0,14(A5)
	MOVE.W	D3,$12(A5)
lbC000154	MOVE.W	D5,6(A1)			; period ?

	bsr.w	SetPer

	MOVE.W	D5,8(A5)
;	MOVE.W	(SP),8(A1)				; volume ?

	move.l	D5,-(SP)
	move.w	4(SP),D5
	bsr.w	ChangeVolume
	bsr.w	SetVol
	move.l	(SP)+,D5

lbC000160	ADDQ.L	#2,SP
	MOVEM.L	(SP)+,D3-D7
	RTS

lbC000168
;	MOVE.L	D0,-(SP)
;	MOVEQ	#$79,D0
;lbC00016C	MOVE.B	$DFF007,D1
;lbC000172	CMP.B	$DFF007,D1
;	BEQ.S	lbC000172
;	DBRA	D0,lbC00016C
;	MOVE.L	(SP)+,D0
;	RTS
DMAWait
	movem.l	D0/D1,-(SP)
	moveq	#8,D0
.dma1	move.b	$DFF006,D1
.dma2	cmp.b	$DFF006,D1
	beq.b	.dma2
	dbeq	D0,.dma1
	movem.l	(SP)+,D0/D1
	rts

lbC000182	LEA	lbL0001C0(PC),A5
	ADDA.W	(A1)+,A5
	LSR.B	#1,D0
	BCC.S	lbC00019C
	MOVEA.L	10(A5),A0
	MOVE.L	14(A5),0(A0)				; address ?
	MOVE.W	$12(A5),4(A0)				; length ?

;	movem.l	D0/D1/A1,-(SP)
;	move.l	14(A5),D0
;	move.l	A0,A1
;	bsr.w	SetAdr
;	move.w	$12(A5),D1
;	bsr.w	SetLen
;	movem.l	(SP)+,D0/D1/A1

lbC00019C	RTS

lbC00019E	MOVE.W	lbW0001BE(PC),D0
	BEQ.S	lbC00019C
	BSET	#15,D0
	BSR.S	lbC000168
	MOVE.W	D0,$DFF096				; DMA
	BSR.S	lbC000168
	LEA	lbW000220(PC),A1
	BSR.S	lbC000182
	BSR.S	lbC000182
	BSR.S	lbC000182
	BRA.S	lbC000182

lbW0001BE	dc.w	0
lbL0001C0	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbW000220	dc.w	0
	dc.w	$18
	dc.w	$30
	dc.w	$48
lbW000228	dc.w	0
lbW00022A	dc.w	0

;lbC00022C	MOVE.L	D0,-(SP)
;	MOVE.W	$DFF01E,D0
;	BTST	#13,D0
;	BEQ.S	lbC000250
;	MOVE.B	$BFDD00,D0
;	MOVEM.L	D1-D7/A0-A6,-(SP)
;	LEA	$DFF000,A0
;	BSR.S	lbC00025C
;	MOVEM.L	(SP)+,D1-D7/A0-A6
;lbC000250	MOVE.W	#$2000,$DFF09C
;	MOVE.L	(SP)+,D0
;	RTE

Play
lbC00025C	MOVE.L	lbL000BDC(PC),D0
	BEQ.S	lbC000272
	LEA	lbL000AF2(PC),A4
	TST.W	$28(A4)
	BNE.S	lbC000284
	MOVE.B	#5,$32(A4)
lbC000272
;	BCLR	#0,$BFDE00
;	MOVE.W	#15,$DFF096

	bsr.w	SongEnd
	bsr.w	InitSound

	RTS

lbC000284	CLR.W	lbW0001BE-lbL000AF2(A4)
	MOVEA.L	8(A4),A6
	ADDI.B	#1,$32(A4)
	CMPI.B	#6,$32(A4)
	BNE.L	lbC00052E
	MOVEA.L	$10(A4),A0
	MOVE.W	$2A(A4),D2
	LSL.W	#2,D2
	MOVEA.L	0(A0,D2.W),A2
	CLR.W	D0
	MOVE.B	1(A2),D0
	LEA	$30(A4),A3
	ADDQ.W	#1,(A3)
	CMP.W	(A3),D0
	BLT.S	lbC0002C0
	TST.B	lbW000228-lbL000AF2(A4)
	BEQ.S	lbC000312
lbC0002C0	CLR.W	(A3)
	CMPI.W	#2,$28(A4)
	BNE.S	lbC00030E
	CMPI.B	#1,lbW000228-lbL000AF2(A4)
	BEQ.S	lbC0002D6
	ADDQ.W	#1,$2E(A4)
lbC0002D6	MOVE.W	$1FA(A6),D0
	MOVE.W	$2E(A4),D1
	CMP.W	D0,D1
	BLT.S	lbC0002E8
	CLR.W	$2E(A4)
	CLR.W	D1

	bsr.w	SongEnd

lbC0002E8	CLR.W	D0
	LEA	$1FC(A6),A1
	MOVE.B	0(A1,D1.W),D0
	MOVE.W	D0,$2A(A4)
	CLR.W	D1
	MOVE.B	$1F9(A6),D1
	SUBQ.W	#1,D1
	CMP.W	D1,D0
	BLT.S	lbC000308
	MOVE.W	D1,$2A(A4)
	MOVE.W	D1,D0
lbC000308	LSL.W	#2,D0
	MOVEA.L	0(A0,D0.W),A2
lbC00030E	CLR.B	lbW000228-lbL000AF2(A4)
lbC000312	MOVE.W	(A3),$2C(A4)
	CLR.B	$32(A4)
	CLR.L	D7
	MOVE.B	(A2),lbW000228-lbL000AF2+3(A4)
	CMPI.W	#$4443,2(A4)
	BEQ.S	lbC00033C
	ADDQ.W	#2,A2
	MOVE.W	lbW00022A(PC),D3
	MULU.W	#3,D3
	MOVE.W	$2C(A4),D2
	MULU.W	D2,D3
	ADDA.L	D3,A2
	BRA.S	lbC0003A6

lbC00033C	TST.W	$2C(A4)
	BNE.S	lbC00035A
	ADDQ.W	#2,A2
	MOVE.W	lbW00022A(PC),D3
	MULU.W	#3,D3
	SUBQ.W	#1,D3
	MOVE.W	D3,$FA(A4)
	MOVE.L	A2,$F2(A4)
	ST	$F8(A4)
lbC00035A	LEA	lbL000BEE(PC),A2
	MOVEM.L	A0/A2,-(SP)
	MOVEA.L	$F2(A4),A0
	MOVE.W	$FA(A4),D5
	MOVE.W	$F6(A4),D3
	MOVE.W	$F8(A4),D0
lbC000372	TST.W	D0
	BPL.S	lbC000386
	CLR.W	D0
	MOVE.B	(A0)+,D0
	ST	D3
	BPL.S	lbC000382
	CLR.W	D3
	NOT.B	D0
lbC000382	MOVE.W	D0,$F8(A4)
lbC000386	SUBQ.W	#1,D0
	TST.W	D3
	BNE.S	lbC000390
	CLR.B	(A2)+
	BRA.S	lbC000392

lbC000390	MOVE.B	(A0)+,(A2)+
lbC000392	DBRA	D5,lbC000372
	MOVE.W	D0,$F8(A4)
	MOVE.W	D3,$F6(A4)
	MOVE.L	A0,$F2(A4)
	MOVEM.L	(SP)+,A0/A2
lbC0003A6	PEA	lbW000220(PC)
lbC0003AA	CLR.W	D5
	MOVEA.L	(SP),A1
	LEA	lbL0001C0(PC),A5
	ADDA.W	(A1)+,A5
	MOVE.L	A1,(SP)
	MOVE.B	(A2)+,D5
	MOVE.B	(A2)+,D6
	LSL.W	#8,D6
	MOVE.B	(A2)+,D6
	MOVE.B	D6,5(A5)
	MOVE.W	D6,D0
	ANDI.W	#$F000,D0
	ROL.W	#4,D0
	BCLR	#7,D5
	BEQ.S	lbC0003D4
	BSET	#4,D0
lbC0003D4	BCLR	#6,D5
	BEQ.S	lbC0003DE
	BSET	#5,D0
lbC0003DE	TST.W	D0
	BEQ.S	lbC000400
	SUBQ.B	#1,D0
	MOVE.B	D0,1(A5)
	CLR.B	$17(A5)
	ASL.W	#3,D0
	LEA	0(A6,D0.W),A3
	MOVEQ	#0,D0
	MOVE.B	6(A3),D0
	BSR.L	lbC000096
	MOVE.B	D0,2(A5)
lbC000400	MOVE.W	D6,D0
	LSR.W	#8,D0
	ANDI.B	#15,D0
	MOVE.B	D0,4(A5)
	BEQ.L	lbC0004FC
	CMP.B	#15,D0
	BNE.S	lbC000482
	TST.B	D6
	BEQ.S	lbC00047A
	CMP.B	#$F0,D6
	BHI.S	lbC00042C
	CLR.L	D0
	MOVE.B	D6,D0
	BSR.L	lbC0007E6
	BRA.L	lbC0004FC

lbC00042C	CMP.B	#$F2,D6
	BNE.S	lbC00043C
	MOVE.B	D5,0(A5)
	CLR.W	D5
	BRA.L	lbC0004FC

lbC00043C	CMP.B	#$FE,D6
	BNE.S	lbC00044A
	CLR.W	$28(A4)
	BRA.L	lbC0004FC

lbC00044A	CMP.B	#$FD,D6
	BNE.L	lbC0004FC
	CMP.B	#3,D7
	BHI.L	lbC0004FC
	LEA	lbL000B4C(PC),A0
	TST.B	D5
	BEQ.L	lbC0004FC
	SUBQ.B	#1,D5
	ADD.B	D5,D5
	MOVE.W	0(A0,D5.W),D0
	MOVEA.L	10(A5),A0
	MOVE.W	D0,6(A0)				; period ?

;	movem.l	D5/A1,-(SP)
;	move.l	A0,A1
;	move.l	D0,D5
;	bsr.w	SetPer
;	movem.l	(SP)+,D5/A1

	CLR.B	D5
	BRA.L	lbC0004FC

lbC00047A	ST	lbW000228-lbL000AF2(A4)
	BRA.L	lbC0004FC

lbC000482	CMP.B	#12,D0
	BNE.S	lbC0004AA
	MOVE.B	D6,D0
	LSR.B	#4,D0
	MULU.W	#10,D0
	MOVE.B	D6,D1
	ANDI.B	#15,D1
	ADD.B	D1,D0
	CMP.B	#$40,D0
	BLS.S	lbC0004A0
	MOVEQ	#$40,D0
lbC0004A0	BSR.L	lbC000096
	MOVE.B	D0,2(A5)
	BRA.S	lbC0004FC

lbC0004AA	CMP.B	#11,D0
	BNE.S	lbC0004C8
	MOVE.W	D6,D0
	ANDI.W	#$FF,D0
	CMP.W	$1FA(A6),D0
	BHI.S	lbC0004FC
	MOVE.W	D0,$2E(A4)
	MOVE.B	#1,lbW000228-lbL000AF2(A4)
	BRA.S	lbC0004FC

lbC0004C8	CMP.B	#3,D0
	BNE.S	lbC0004FC
	SUBQ.B	#1,D5
	BMI.S	lbC000522
	CMP.B	#3,D7
	BHI.S	lbC000522
	LEA	lbL000B4C(PC),A0
	ADD.B	$2FE(A6),D5
	CLR.W	D0
	MOVE.B	1(A5),D0
	ASL.W	#3,D0
	ADD.B	7(A6,D0.W),D5
	BMI.S	lbC000522
	ADD.W	D5,D5
	MOVE.W	0(A0,D5.W),$14(A5)
	MOVE.B	D6,7(A5)
	CLR.W	D5
lbC0004FC	TST.B	D5
	BEQ.S	lbC000522
	MOVE.B	D5,0(A5)
	MOVE.W	D7,D0
	MOVE.W	D5,D1
	CLR.W	D3
	MOVE.B	1(A5),D3
	MOVE.W	D3,D2
	ASL.W	#3,D3
	LEA	0(A6,D3.W),A3
	MOVE.W	D2,D3
	CLR.W	D2
	MOVE.B	2(A5),D2
	BSR.L	lbC0000B2
lbC000522	ADDQ.B	#1,D7
	CMP.W	lbW00022A(PC),D7
	BLT.L	lbC0003AA
	ADDQ.L	#4,SP
lbC00052E	CLR.L	D7
	LEA	lbW000220(PC),A2
lbC000534	LEA	lbL0001C0(PC),A5
	ADDA.W	(A2)+,A5
	CLR.W	D5
	CLR.W	D4
	MOVE.B	4(A5),D6
	MOVE.B	5(A5),D4
	CMP.B	#3,D7
	BHI.L	lbC0007D6
	CMP.B	#1,D6
	BNE.S	lbC000584
	BTST	#5,$2FF(A6)
	BEQ.S	lbC000568
	MOVE.B	$301(A6),D0
	CMP.B	$32(A4),D0
	BLE.L	lbC0007D6
lbC000568	SUB.W	D4,8(A5)
	MOVE.W	8(A5),D5
	CMP.W	#$71,D5
	BGE.L	lbC0007BC
	MOVE.W	#$71,D5
	MOVE.W	D5,8(A5)
	BRA.L	lbC0007BC

lbC000584	CMP.B	#2,D6
	BNE.S	lbC0005BA
	BTST	#5,$2FF(A6)
	BEQ.S	lbC00059E
	MOVE.B	$301(A6),D0
	CMP.B	$32(A4),D0
	BLE.L	lbC0007D6
lbC00059E	ADD.W	D4,8(A5)
	MOVE.W	8(A5),D5
	CMP.W	#$358,D5
	BLE.L	lbC0007BC
	MOVE.W	#$358,D5
	MOVE.W	D5,8(A5)
	BRA.L	lbC0007BC

lbC0005BA	TST.B	D6
	BNE.S	lbC0005EC
	TST.B	D4
	BEQ.L	lbC0007D6
	MOVE.B	0(A5),D1
	BSR.L	lbC000840
	SUBQ.B	#1,D4
	ADD.B	$2FE(A6),D4
	CLR.W	D0
	MOVE.B	1(A5),D0
	ASL.W	#3,D0
	ADD.B	7(A6,D0.W),D4
	ADD.B	D4,D4
	LEA	lbL000B4C(PC),A1
	MOVE.W	0(A1,D4.W),D5
	BRA.L	lbC0007BC

lbC0005EC	CMP.B	#10,D6
	BEQ.S	lbC0005F8
	CMP.B	#13,D6
	BNE.S	lbC00063A
lbC0005F8	BTST	#5,$2FF(A6)
	BEQ.S	lbC00060C
	MOVE.B	$301(A6),D0
	CMP.B	$32(A4),D0
	BLE.L	lbC0007D6
lbC00060C	MOVE.B	D4,D1
	MOVE.B	2(A5),D0
	ANDI.B	#$F0,D1
	BNE.S	lbC000626
	SUB.B	D4,D0
	BPL.S	lbC00061E
	CLR.B	D0
lbC00061E	MOVE.B	D0,2(A5)
	BRA.L	lbC0007BC

lbC000626	LSR.B	#4,D1
	ADD.B	D1,D0
	CMP.B	#$40,D0
	BLE.S	lbC000632
	MOVEQ	#$40,D0
lbC000632	MOVE.B	D0,2(A5)
	BRA.L	lbC0007BC

lbC00063A	CMP.B	#5,D6
	BNE.S	lbC000654
	MOVE.W	8(A5),D5
	CMPI.B	#3,$32(A4)
	BGE.L	lbC0007BC
	SUB.W	D4,D5
	BRA.L	lbC0007BC

lbC000654	CMP.B	#3,D6
	BNE.S	lbC0006A2
	BTST	#5,$2FF(A6)
	BEQ.S	lbC00066E
	MOVE.B	$301(A6),D0
	CMP.B	$32(A4),D0
	BLE.L	lbC0007D6
lbC00066E	MOVE.W	$14(A5),D0
	BEQ.L	lbC0007BC
	MOVE.W	8(A5),D1
	MOVE.B	7(A5),D4
	CMP.W	D0,D1
	BHI.S	lbC00068A
	ADD.W	D4,D1
	CMP.W	D0,D1
	BGE.S	lbC000690
	BRA.S	lbC000698

lbC00068A	SUB.W	D4,D1
	CMP.W	D0,D1
	BGT.S	lbC000698
lbC000690	MOVE.W	$14(A5),D1
	CLR.W	$14(A5)
lbC000698	MOVE.W	D1,8(A5)
	MOVE.W	D1,D5
	BRA.L	lbC0007BC

lbC0006A2	CMP.B	#12,D6
	BNE.S	lbC0006B4
	TST.B	$32(A4)
	BNE.L	lbC0007D6
	BRA.L	lbC0007BC

lbC0006B4	CMP.B	#4,D6
	BNE.S	lbC000724
	TST.B	D4
	BEQ.S	lbC0006C2
	MOVE.B	D4,$17(A5)
lbC0006C2	MOVE.B	$16(A5),D0
	LSR.B	#1,D0
	ANDI.W	#$1F,D0
	CLR.W	D1
	MOVE.B	lbL000704(PC,D0.W),D1
	MOVE.B	$17(A5),D0
	ANDI.W	#15,D0
	MULU.W	D0,D1
	LSR.W	#6,D1
	MOVE.W	8(A5),D5
	BTST	#6,$16(A5)
	BNE.S	lbC0006EE
	ADD.W	D1,D5
	BRA.S	lbC0006F0

lbC0006EE	SUB.W	D1,D5
lbC0006F0	MOVE.B	$17(A5),D0
	LSR.B	#4,D0
	ANDI.B	#15,D0
	ADDQ.W	#1,D0
	ADD.B	D0,$16(A5)
	BRA.L	lbC0007BC

lbL000704	dc.l	$18314A
	dc.l	$61788DA1
	dc.l	$B4C5D4E0
	dc.l	$EBF4FAFD
	dc.l	$FFFDFAF4
	dc.l	$EBE0D4C5
	dc.l	$B4A18D78
	dc.l	$614A3118

lbC000724	CMP.B	#15,D6
	BNE.L	lbC0007B6
	CMP.B	#$FF,D4
	BNE.S	lbC00073C
	MOVE.W	D7,D0
	BSR.L	lbC000084
	BRA.L	lbC0007D6

lbC00073C	CMP.B	#$F1,D4
	BNE.S	lbC00074E
	CMPI.B	#3,$32(A4)
	BNE.L	lbC0007D6
	BRA.S	lbC000770

lbC00074E	CMP.B	#$F2,D4
	BNE.S	lbC000760
	CMPI.B	#3,$32(A4)
	BNE.L	lbC0007D6
	BRA.S	lbC000770

lbC000760	CMP.B	#$F3,D4
	BNE.S	lbC000796
	MOVE.B	$32(A4),D0
	ANDI.B	#6,D0
	BEQ.S	lbC0007D6
lbC000770	CLR.W	D0
	MOVE.B	1(A5),D0
	ASL.W	#3,D0
	LEA	0(A6,D0.W),A3
	MOVE.W	D7,D0
	CLR.W	D1
	MOVE.B	0(A5),D1
	CLR.W	D2
	MOVE.B	2(A5),D2
	CLR.W	D3
	MOVE.B	1(A5),D3
	BSR.L	lbC0000B2
	BRA.S	lbC0007D6

lbC000796
	CMP.B	#$F8,D4
	BEQ.S	lbC0007AC
	CMP.B	#$F9,D4
	BNE.S	lbC0007D6
	BCLR	#1,$BFE001
	BRA.S	lbC0007D6

lbC0007AC	BSET	#1,$BFE001
	BRA.S	lbC0007D6

lbC0007B6	CMP.B	#12,D6
	BNE.S	lbC0007D6
lbC0007BC	TST.W	D5
	BNE.S	lbC0007C4
	MOVE.W	8(A5),D5
lbC0007C4	MOVEA.L	10(A5),A1
	MOVE.W	D5,6(A1)				; period ?

	bsr.w	SetPer

	CLR.W	D5
	MOVE.B	2(A5),D5
;	MOVE.W	D5,8(A1)				; volume ?

	bsr.w	ChangeVolume
	bsr.w	SetVol

lbC0007D6	ADDQ.B	#1,D7
	CMP.W	lbW00022A(PC),D7
	BLT.L	lbC000534
	BSR.L	lbC00019E
	RTS

lbC0007E6	LEA	lbL000AF2(PC),A4
	TST.B	$48(A4)
	BEQ.S	lbC000828
	MOVE.L	lbL000BDC(PC),D1
	BEQ.S	lbC000812
	MOVEA.L	lbL000AFA(PC),A0
	MOVE.B	D0,$2FD(A0)
	CMP.B	#10,D0
	BHI.S	lbC000812
	SUBQ.B	#1,D0
	MOVE.B	D0,$301(A0)
	ADD.W	D0,D0
	MOVE.W	lbW00082C(PC,D0.W),D1
	BRA.S	lbC00081A

lbC000812	MOVE.L	#$72BF0,D1
	DIVU.W	D0,D1
lbC00081A
;	MOVE.B	D1,$BFD400
;	LSR.W	#8,D1
;	MOVE.B	D1,$BFD500

	movem.l	A1/A5,-(SP)
	move.l	EagleBase(PC),A5
	move.w	D1,dtg_Timer(A5)
	move.l	dtg_SetTimer(A5),A1
	jsr	(A1)
	movem.l	(SP)+,A1/A5

lbC000828	RTS

	dc.w	$F00
lbW00082C	dc.w	$971
	dc.w	$12E1
	dc.w	$1C52
	dc.w	$25C2
	dc.w	$2F33
	dc.w	$38A4
	dc.w	$4214
	dc.w	$4B84
	dc.w	$53BC
	dc.w	$5E63

lbC000840	MOVE.B	$32(A4),D0
	TST.B	D0
	BEQ.S	lbC00084E
	CMP.B	#3,D0
	BNE.S	lbC000856
lbC00084E	ANDI.B	#15,D4
	ADD.B	D1,D4
	RTS

lbC000856	CMP.B	#1,D0
	BEQ.S	lbC000862
	CMP.B	#4,D0
	BNE.S	lbC000868
lbC000862	LSR.B	#4,D4
	ADD.B	D1,D4
	RTS

lbC000868	MOVE.B	D1,D4
	RTS

lbC00086C	CLR.L	D2
;	MOVE.W	4(A0),D0			; po co ?
	MOVE.L	A0,D0
	LEA	lbL000B4C(PC),A0
	ADD.B	D1,D1
	MOVE.W	0(A0,D1.W),D5
	MOVEA.L	D0,A0
	ADDQ.L	#6,D0
	MOVE.L	(A0),D1
	MOVE.W	(A3),D2
	MOVE.W	2(A3),D3
	RTS

;	MOVEM.L	D6/D7/A1,-(SP)
;	MOVEQ	#0,D7
;	MOVE.W	D1,D7
;	DIVU.W	#12,D7
;	MOVE.L	D7,D5
;	SWAP	D5
;	MOVE.L	(A0),D1
;	CMP.B	#2,D0
;	BNE.S	lbC0008AC
;	ADDQ.L	#6,D7
;	DIVU.W	#7,D1
;	BRA.S	lbC0008B0

;lbC0008AC	DIVU.W	#$1F,D1
;lbC0008B0	MOVE.L	D1,D0
;	MOVE.W	(A3),D2
;	MOVE.W	2(A3),D3
;	CLR.W	D6
;	MOVE.B	lbL0008E2(PC,D7.W),D6
;	LSL.W	D6,D2
;	LSL.W	D6,D3
;	LSL.W	D6,D1
;	MOVE.B	lbL0008EE(PC,D7.W),D6
;	MULU.W	D6,D0
;	ADD.L	A0,D0
;	ADDQ.L	#6,D0
;	LEA	lbL000B4C(PC),A1
;	ADD.B	lbL0008FA(PC,D7.W),D5
;	ADD.B	D5,D5
;	MOVE.W	0(A1,D5.W),D5
;	MOVEM.L	(SP)+,D6/D7/A1
;	RTS

;lbL0008E2	dc.l	$4030201
;	dc.l	$1000202
;	dc.l	$1010000
;lbL0008EE	dc.l	$F070301
;	dc.l	$1000303
;	dc.l	$1010000
;lbL0008FA	dc.l	$C0C0C0C
;	dc.l	$1818000C
;	dc.l	$C181824

;lbC000906	MOVEM.L	D0-D7/A0-A6,-(SP)
;	BSR.L	lbC000914
;	MOVEM.L	(SP)+,D0-D7/A0-A6
;	RTS

InitPlay
lbC000914	LEA	lbL000AF2(PC),A4
	LEA	lbL0001C0(PC),A0
	MOVEQ	#3,D0
	MOVE.L	#$DFF0A0,D1
lbC000924	MOVE.L	D1,10(A0)
	LEA	$18(A0),A0
	ADDI.W	#$10,D1
	DBRA	D0,lbC000924
;	MOVE.L	A6,-(SP)
;	LEA	lbB000B3B(PC),A0
;	CLR.B	(A0)
;	BTST	#1,$BFE001
;	SNE	(A0)
;	MOVE.L	$64.W,$4A(A4)
;	MOVE.L	$78.W,$4E(A4)
;	MOVE.L	$6C.W,$52(A4)
;	MOVE.W	$DFF01C,$56(A4)
;	MOVE.W	#$4000,$DFF09A
;	LEA	lbC00022C(PC),A0
;	MOVE.L	A0,$78.W
;	MOVE.W	#$72,$DFF032
;	ANDI.B	#$80,$BFDE00
;	MOVE.W	#$E000,$DFF09A
	ST	$46(A4)
;	MOVE.B	#$81,$BFDD00
	ST	$48(A4)
	MOVEQ	#6,D0
	BSR.L	lbC000812
	CLR.L	D0
;lbC0009A0	MOVEA.L	(SP)+,A6
	RTS

;	BSR.S	lbC0009AA
;	MOVEQ	#-1,D0
;	BRA.S	lbC0009A0

;lbC0009AA	LEA	lbL000AF2(PC),A4
;	MOVE.L	A6,-(SP)
;	MOVEA.L	4,A6
;	LEA	lbL000BDC(PC),A0
;	TST.L	(A0)
;	BEQ.S	lbC0009CA
;	MOVEA.L	A4,A0
;	TST.W	$28(A0)
;	BEQ.S	lbC0009CA
;	BSR.L	lbC000ACC
;lbC0009CA	LEA	lbB000B3A(PC),A0
;	CLR.B	(A0)+
;	BCLR	#1,$BFE001
;	MOVE.B	(A0),D0
;	ANDI.B	#2,D0
;	OR.B	D0,$BFE001
;	CLR.B	$46(A4)
;	MOVE.W	$56(A4),D0
;	MOVE.W	#$4000,$DFF09A
;	MOVE.L	lbL000B40(PC),$78.W
;	MOVE.W	#$2000,$DFF09A
;	ORI.W	#$C000,D0
;	MOVE.W	D0,$DFF09A
;	MOVEA.L	(SP)+,A6
lbC000A0E	RTS

;lbC000A10	MOVEM.L	D0-D7/A0-A6,-(SP)
;	BSR.L	lbC000A1E
;	MOVEM.L	(SP)+,D0-D7/A0-A6
;	RTS

InitSong
lbC000A1E	LEA	lbL000AF2(PC),A4
	TST.B	$48(A4)
	BEQ.S	lbC000A0E
	MOVEA.L	A4,A0
	LEA	$28(A0),A1
	CLR.L	(A1)+
	CLR.L	(A1)+
	CLR.W	(A1)
	NOT.W	(A1)+
	MOVE.B	#5,(A1)
	MOVEA.L	8(A0),A1
	BTST	#0,$2FF(A1)
	BNE.S	lbC000A50
	BSET	#1,$BFE001
	BRA.S	lbC000A66

lbC000A50	BCLR	#1,$BFE001
;	BRA.S	lbC000A66

;	MOVEM.L	D0-D7/A0-A6,-(SP)
;	BSR.S	lbC000A66
;	MOVEM.L	(SP)+,D0-D7/A0-A6
;	RTS

lbC000A66
;	LEA	lbL000AF2(PC),A4
;	TST.B	$48(A4)
;	BEQ.S	lbC000ACA
;	MOVE.L	A6,-(SP)
;	MOVE.W	#$4000,$DFF09A
	MOVE.L	A0,D0
	BNE.S	lbC000A88
	LEA	lbL000BDC(PC),A0
	TST.L	(A0)
	BEQ.S	lbC000AC0
	MOVEA.L	(A0),A0
lbC000A88	TST.B	$46(A4)
	BEQ.S	lbC000AC0

	move.l	A0,BaseA0
SetPosition
	MOVE.W	$2E(A0),D1
	MOVEA.L	8(A4),A1
	MOVE.W	$2FC(A1),D0
	ADDA.W	D1,A1
	MOVE.B	$1FC(A1),$2B(A0)
	MOVE.L	A0,$EA(A4)
	MOVE.W	#2,$28(A0)
	BSR.L	lbC0007E6
;	MOVE.B	#1,$BFDE00
;	MOVE.W	#15,$DFF096
lbC000AC0
;	MOVE.W	#$C000,$DFF09A
;	MOVEA.L	(SP)+,A6
lbC000ACA	RTS

lbC000ACC	MOVEM.L	D0-D7/A0-A6,-(SP)
	BSR.L	lbC000ADA
	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTS

lbC000ADA	LEA	lbL000AF2(PC),A4
	TST.B	$48(A4)
	BEQ.S	lbC000AF0
	TST.L	$EA(A4)
	BEQ.S	lbC000AF0
	MOVEA.L	A4,A0
	CLR.W	$28(A0)
lbC000AF0	RTS

lbL000AF2	dc.l	0
	dc.l	0
lbL000AFA	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	$FF000000
lbB000B3A	dc.b	0
lbB000B3B	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	0
lbL000B40	dc.l	0
	dc.l	0
	dc.l	0
lbL000B4C	dc.l	$3580328
	dc.l	$2FA02D0
	dc.l	$2A60280
	dc.l	$25C023A
	dc.l	$21A01FC
	dc.l	$1E001C5
	dc.l	$1AC0194
	dc.l	$17D0168
	dc.l	$1530140
	dc.l	$12E011D
	dc.l	$10D00FE
	dc.l	$F000E2
	dc.l	$D600CA
	dc.l	$BE00B4
	dc.l	$AA00A0
	dc.l	$97008F
	dc.l	$87007F
	dc.l	$780071
	dc.l	$D600CA
	dc.l	$BE00B4
	dc.l	$AA00A0
	dc.l	$97008F
	dc.l	$87007F
	dc.l	$780071
	dc.l	$D600CA
	dc.l	$BE00B4
	dc.l	$AA00A0
	dc.l	$97008F
	dc.l	$87007F
	dc.l	$780071
	dc.l	$D600CA
	dc.l	$BE00B4
	dc.l	$AA00A0
	dc.l	$97008F
	dc.l	$87007F
	dc.l	$780071
lbL000BDC	dc.l	0
lbL000BE0	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
lbL000BEE	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
;MMDC.MSG	dc.b	'MMDC',0,0

	Section	Sample,BSS_C
Empty
	ds.b	4

	*****************************************************
	****        PVP replayer for EaglePlayer	 ****
	****        all adaptions by Wanted Team,	 ****
	****      DeliTracker compatible (?) version	 ****
	*****************************************************

	incdir	"dh2:include/"
	include 'misc/eagleplayer2.01.i'

	SECTION	Player,CODE

	PLAYERHEADER Tags

	dc.b	'$VER: Peter Verswyvelen Packer player module V1.1 (22 Aug 2002)',0
	even
Tags
	dc.l	DTP_PlayerVersion,2
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
	dc.l	EP_Flags,EPB_Save!EPB_Volume!EPB_Balance!EPB_ModuleInfo!EPB_Voices!EPB_SampleInfo!EPB_Songend!EPB_Analyzer!EPB_Packable!EPB_Restart!EPB_PrevPatt!EPB_NextPatt
	dc.l	0

PlayerName
	dc.b	'Peter Verswyvelen Packer',0
Creator
	dc.b	'(c) 1990 by Peter Verswyvelen,',10
	dc.b	'adapted by Wanted Team',0
Prefix
	dc.b	'PVP.',0
	even
ModulePtr
	dc.l	0
SamplePtr
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
******************************* EP_SampleInit *****************************
***************************************************************************

SampleInit
	moveq	#EPR_NotEnoughMem,D7
	lea	EPG_SampleInfoStructure(A5),A3
	move.l	ModulePtr(PC),D0
	beq.b	return
	move.l	D0,A2

	move.l	SamplePtr(PC),A1
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
	move.l	dtg_StopInt(A5),A0
	jsr	(A0)
	move.b	Base+6,D6			; copy speed
	bsr.w	EndSound
	bsr.w	GetPosition
	move.l	D0,D7
	bsr.w	InitSound
	addq.l	#1,D7
	cmp.l	InfoBuffer+Length(PC),D7
	beq.b	MaxPos
	lsl.l	#5,D7
	move.w	D7,Base+8
	move.b	D6,Base+6
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
	bsr.w	GetPosition
	move.l	D0,D7
	beq.b	MinPos
	move.l	dtg_StopInt(A5),A0
	jsr	(A0)
	bsr.w	EndSound
	move.b	Base+6,D6			; copy speed
	bsr.w	InitSound
	subq.l	#1,D7
	lsl.l	#5,D7
	move.w	D7,Base+8
	move.b	D6,Base+6
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

InfoBuffer
	dc.l	MI_LoadSize,0		;12
	dc.l	MI_Samples,0		;20
	dc.l	MI_Length,0		;28
	dc.l	MI_SamplesSize,0	;36
	dc.l	MI_Songsize,0		;44
	dc.l	MI_Calcsize,0		;52
	dc.l	MI_MaxLength,128
	dc.l	MI_MaxSamples,31
	dc.l	MI_MaxPattern,64
	dc.l	MI_Prefix,Prefix
	dc.l	0

***************************************************************************
******************************* DTP_Check2 ********************************
***************************************************************************

Check2
	movea.l	dtg_ChkData(A5),A0
	moveq	#-1,D0

	moveq	#30,D1
NextInfos
	tst.w	(A0)+
	bmi.b	Fault
	cmp.w	#$40,(A0)+
	bhi.b	Fault
	tst.w	(A0)+
	bmi.b	Fault
	tst.w	(A0)+
	bmi.b	Fault
	dbf	D1,NextInfos
	move.w	(A0)+,D1
	beq.b	Fault
	bmi.b	Fault
	move.w	(A0)+,D2
	beq.b	Fault
	bmi.b	Fault
	btst	#0,D2
	bne.b	Fault
	cmp.w	(A0)+,D2
	bls.b	Fault
	move.w	(A0)+,D3
	beq.b	Fault
	bmi.b	Fault
	subq.w	#2,D1
NextStep
	move.w	(A0)+,D2
	bmi.b	Fault
	btst	#0,D2
	bne.b	Fault
	cmp.w	(A0),D2
	bhi.b	Fault
	cmp.w	D3,D2
	bgt.b	Fault
	dbf	D1,NextStep
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
	move.w	(A1)+,D2
	add.l	D2,D2
	move.w	(A1)+,D1
	move.l	D1,D0
	lsl.l	#3,D1
	addq.l	#2,A1
	add.w	(A1)+,A1
	add.l	D1,A1
	add.l	D2,A1
	move.l	A1,(A6)+			; SamplesPtr
	sub.l	A0,A1
	move.l	A1,SongSize(A4)
	add.l	A1,D3
	move.l	D3,CalcSize(A4)
	cmp.l	LoadSize(A4),D3
	ble.b	SizeOK
	moveq	#EPR_ModuleTooShort,D0
	rts
SizeOK
	lsr.l	#2,D0
	move.l	D0,Length(A4)
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
	move.w	Base+8,D0
	lsr.l	#5,D0
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
	lea	$DFF0A0,A3
SetNew
	move.w	(A1)+,D1
	bsr.b	ChangeVolume
	addq.l	#8,A3
	addq.l	#8,A3
	dbf	D0,SetNew
	rts

ChangeVolume
	and.w	#$7F,D1
	cmpa.l	#$DFF0A0,A3			;Left Volume
	bne.b	NoVoice1
	move.w	D1,OldVoice1
	tst.w	Voice1
	bne.b	Voice1On
	moveq	#0,D1
Voice1On
	mulu.w	LeftVolume(PC),D1
	bra.b	SetIt
NoVoice1
	cmpa.l	#$DFF0B0,A3			;Right Volume
	bne.b	NoVoice2
	move.w	D1,OldVoice2
	tst.w	Voice2
	bne.b	Voice2On
	moveq	#0,D1
Voice2On
	mulu.w	RightVolume(PC),D1
	bra.b	SetIt
NoVoice2
	cmpa.l	#$DFF0C0,A3			;Right Volume
	bne.b	NoVoice3
	move.w	D1,OldVoice3
	tst.w	Voice3
	bne.b	Voice3On
	moveq	#0,D1
Voice3On
	mulu.w	RightVolume(PC),D1
	bra.b	SetIt
NoVoice3
	move.w	D1,OldVoice4
	tst.w	Voice4
	bne.b	Voice4On
	moveq	#0,D1
Voice4On
	mulu.w	LeftVolume(PC),D1
SetIt
	lsr.w	#6,D1
	move.w	D1,8(A3)
	rts

*------------------------------- Set Vol -------------------------------*

SetVol
	move.l	A0,-(A7)
	lea	StructAdr+UPS_Voice1Vol(PC),A0
	cmp.l	#$DFF0A0,A3
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice2Vol(PC),A0
	cmp.l	#$DFF0B0,A3
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice3Vol(PC),A0
	cmp.l	#$DFF0C0,A3
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
	cmp.l	#$DFF0A0,A3
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice2Adr(PC),A0
	cmp.l	#$DFF0B0,A3
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice3Adr(PC),A0
	cmp.l	#$DFF0C0,A3
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice4Adr(PC),A0
.SetVoice
	move.l	D1,(A0)
	move.l	(A7)+,A0
	rts

*------------------------------- Set Len -------------------------------*

SetLen
	move.l	A0,-(A7)
	lea	StructAdr+UPS_Voice1Len(PC),A0
	cmp.l	#$DFF0A0,A3
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice2Len(PC),A0
	cmp.l	#$DFF0B0,A3
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice3Len(PC),A0
	cmp.l	#$DFF0C0,A3
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
	cmp.l	#$DFF0A0,A3
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice2Per(PC),A0
	cmp.l	#$DFF0B0,A3
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice3Per(PC),A0
	cmp.l	#$DFF0C0,A3
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice4Per(PC),A0
.SetVoice
	move.w	D1,(A0)
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

	move.l	ModulePtr(PC),A0
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

Wait
	movem.l	A1/A5,-(A7)
	move.l	EagleBase(PC),A5
	move.l	dtg_WaitAudioDMA(A5),A1
	jsr	(A1)
	movem.l	(A7)+,A1/A5
	rts

***************************************************************************
******************************** PVP player *******************************
***************************************************************************

; Player from game Ziriax (c) 1989 by Whiz Kidz

InitSong
;lbC000326	CLR.W	$6DE
;lbC00032A	SF	$327
;	SF	$333
;	SF	$33F
;	SF	$34B
;	MOVE.W	$6DE,D0
;	CMP.W	#2,D0
;	BGE.L	lbC0003EE
;	ADDQ.W	#1,$6DE
;	MULU.W	#$150,D0
;	ADDI.L	#$1A1BE,D0
;	MOVEA.L	D0,A4
;	SF	$6D9

	lea	Base,A4

	MOVEA.L	A4,A1
	MOVE.W	#$A7,D0
lbC000360	CLR.W	(A1)+
	DBRA	D0,lbC000360
	MOVE.L	A0,(A4)
	MOVE.W	$FA(A0),D0
	LSL.W	#3,D0
	MOVE.W	D0,10(A4)
	LEA	$100(A0),A1
	MOVE.L	A1,$94(A4)
	MOVE.W	$F8(A0),D1
	ADD.W	D1,D1
	ADDA.W	D1,A1
	MOVE.L	A1,$8C(A4)
	ADDA.W	D0,A1
	MOVE.L	A1,$90(A4)
;	MOVE.L	A2,D0
;	BNE.S	lbC000398
	ADDA.W	$FE(A0),A1
	MOVEA.L	A1,A2
;	BRA.S	lbC00039E

;lbC000398	LEA	$F8(A2),A0
;	EXG	A2,A0
lbC00039E	LEA	$10(A4),A1
	MOVEQ	#$1E,D0
lbC0003A4	CLR.L	(A2)
	MOVE.L	A2,(A1)+
	MOVE.W	(A0),D1
	ADD.W	D1,D1
	ADDA.W	D1,A2
	LEA	8(A0),A0
	DBRA	D0,lbC0003A4
	BSET	#1,$BFE001
	MOVE.B	#6,6(A4)
	MOVE.W	#1,$BE(A4)
	MOVE.W	#2,$EC(A4)
	MOVE.W	#4,$11A(A4)
	MOVE.W	#8,$148(A4)
;	SF	$6D4
;	MOVE.W	#$F000,$6D2
;	MOVE.L	A4,$6DA
;	ST	$6D9
lbC0003EE	RTS

;	MOVE.W	#$F000,$6D2
;	ST	$6D4
;	RTS

;	MOVE.B	#1,$6D4
;	RTS

;lbC000404	SF	$6D9
;	SF	$6D4
;	CLR.W	$A8(A6)
;	CLR.W	$B8(A6)
;	CLR.W	$C8(A6)
;	CLR.W	$D8(A6)
;	MOVE.W	#15,$96(A6)
;	MOVE.W	$6DE,D0
;	BEQ.S	lbC000442
;	SUBQ.W	#1,$6DE
;	SUBQ.W	#2,D0
;	BMI.S	lbC000442
;	MULU.W	#$150,D0
;	ADDI.L	#$1A1BE,D0
;	MOVE.L	D0,$6DA
;	ST	$6D9
;lbC000442	RTS

;	TST.B	$6D9
;	BNE.S	lbC00044C
;	RTS

Play
lbC00044C	MOVEM.L	D0-D7/A0-A6,-(SP)
	LEA	$DFF000,A6
;	MOVEA.L	$6DA,A5

	lea	Base,A5

	MOVEA.L	(A5),A4
;	MOVE.B	$370,D0
;	NOT.B	D0
;	MOVE.B	D0,$CA(A5)
;	MOVE.B	D0,$F8(A5)
;	MOVE.B	D0,$126(A5)
;	MOVE.B	$327,D1
;	OR.B	D0,D1
;	MOVE.B	D1,$9C(A5)
;	MOVE.B	$333,D1
;	OR.B	D0,D1
;	MOVE.B	D1,$CA(A5)
	SUBQ.B	#1,7(A5)
	BGT.L	lbC00079E
	MOVE.B	6(A5),7(A5)
	CLR.W	14(A5)

;	TST.B	5(A5)
;	BEQ.S	lbC0004AE
;	SF	5(A5)
;	CLR.W	$A2(A5)
;	CLR.W	$D0(A5)
;	CLR.W	$FE(A5)
;	CLR.W	$12C(A5)
lbC0004AE	SUBQ.W	#1,12(A5)
	BGT.S	lbC000512
	MOVE.W	#$10,12(A5)
	MOVEA.L	$8C(A5),A0
	MOVE.W	8(A5),D0
	ADDA.W	D0,A0
	ADDQ.W	#8,D0
	CMP.W	10(A5),D0
	BLT.S	lbC0004DA
;	TST.B	4(A5)
;	BNE.L	lbC000608
	MOVE.W	$FC(A4),D0
	LSL.W	#3,D0

	bsr.w	SongEnd

lbC0004DA	MOVE.W	D0,8(A5)
	MOVEM.W	(A0),D0-D3
	MOVEA.L	$94(A5),A0
	MOVEA.L	$90(A5),A1
	MOVEA.L	A1,A2
	ADDA.W	0(A0,D0.W),A2
	MOVE.L	A2,$98(A5)
	MOVEA.L	A1,A2
	ADDA.W	0(A0,D1.W),A2
	MOVE.L	A2,$C6(A5)
	MOVEA.L	A1,A2
	ADDA.W	0(A0,D2.W),A2
	MOVE.L	A2,$F4(A5)
	MOVEA.L	A1,A2
	ADDA.W	0(A0,D3.W),A2
	MOVE.L	A2,$122(A5)
lbC000512	LEA	$98(A5),A2
	LEA	$A0(A6),A3
	BSR.L	lbC000612
	LEA	$C6(A5),A2
	LEA	$B0(A6),A3
	BSR.L	lbC000612
	LEA	$F4(A5),A2
	LEA	$C0(A6),A3
	BSR.L	lbC000612
	LEA	$122(A5),A2
	LEA	$D0(A6),A3
	BSR.L	lbC000612
;	MOVE.B	6(A6),D0
;	ADDQ.B	#3,D0
;lbC000548	CMP.B	6(A6),D0
;	BNE.S	lbC000548

	bsr.w	Wait

	MOVE.W	14(A5),D1
	ORI.W	#$8200,D1
	MOVE.W	D1,$96(A6)
;	MOVE.B	6(A6),D0
;	ADDQ.B	#1,D0
;lbC000560	CMP.B	6(A6),D0
;	BNE.S	lbC000560

	bsr.w	Wait

	LEA	$98(A5),A2
	LEA	$A0(A6),A3
	MOVEQ	#3,D4
;	TST.B	$6D4
;	BNE.S	lbC0005A8
lbC000576	LSR.W	#1,D1
	BCC.S	lbC000596
	TST.B	4(A2)
	BNE.S	lbC000596
	MOVE.L	$1C(A2),(A3)
	MOVE.W	$20(A2),4(A3)
	MOVE.W	$22(A2),6(A3)
;	MOVE.W	$18(A2),8(A3)

	move.l	D1,-(SP)
	move.w	$22(A2),D1
	bsr.w	SetPer
	move.w	$18(A2),D1
	bsr.w	ChangeVolume
	bsr.w	SetVol
	move.l	(SP)+,D1

lbC000596	LEA	$2E(A2),A2
	LEA	$10(A3),A3
	DBRA	D4,lbC000576
	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTS

;lbC0005A8	MOVE.W	$6D2,D3
;lbC0005AC	LSR.W	#1,D1
;	TST.B	4(A2)
;	BNE.S	lbC0005D4
;	SUBX.W	D0,D0
;	BEQ.S	lbC0005C8
;	MOVE.L	$1C(A2),(A3)
;	MOVE.W	$20(A2),4(A3)
;	MOVE.W	$22(A2),6(A3)
;lbC0005C8	MOVE.W	$18(A2),D0
;	MULU.W	D3,D0
;	SWAP	D0
;	MOVE.W	D0,8(A3)
;lbC0005D4	LEA	$2E(A2),A2
;	LEA	$10(A3),A3
;	DBRA	D4,lbC0005AC
;	TST.B	$6D4
;	BMI.S	lbC0005F6
;	ADDI.W	#$1000,D3
;	BCC.S	lbC0005FE
;	MOVE.W	#$F000,D3
;	SF	$6D4
;	BRA.S	lbC0005FE

;lbC0005F6	SUBI.W	#$800,D3
;	BCC.S	lbC0005FE
;	MOVEQ	#0,D3
;lbC0005FE	MOVE.W	D3,$6D2
;	MOVEM.L	(SP)+,D0-D7/A0-A6
;	RTS

;lbC000608	BSR.L	lbC000404
;	MOVEM.L	(SP)+,D0-D7/A0-A6
;	RTS

lbC000612	SUBQ.B	#1,10(A2)
	BMI.S	lbC00064E
	TST.B	11(A2)
	BNE.S	lbC000628
	CLR.W	6(A2)
	CLR.W	12(A2)
	RTS

lbC000628	MOVE.W	6(A2),D0
	BEQ.S	lbC00064C
	MOVE.W	$1A(A2),$18(A2)
	MOVE.W	$24(A2),$22(A2)
	MOVE.B	12(A2),D2
	MOVEM.W	14(A2),D1/D3
	CMP.B	#3,D2
	BNE.L	lbC0006F2
lbC00064C	RTS

lbC00064E	MOVEA.L	(A2),A0
	MOVEQ	#0,D0
	MOVE.B	(A0),D0
	LSR.B	#3,D0
	SCS	11(A2)
	MOVE.W	D0,8(A2)
	BEQ.S	lbC00069A
	SUBQ.W	#1,D0
	ADD.W	D0,D0
	ADD.W	D0,D0
	MOVE.L	$10(A5,D0.W),D2
	MOVE.L	D2,$12(A2)
	ADD.W	D0,D0
	LEA	0(A4,D0.W),A1
	MOVE.L	(A1)+,$16(A2)
	MOVE.W	(A1)+,D0
	BEQ.S	lbC000692
	MOVE.W	(A1)+,D1
	MOVE.W	D1,$20(A2)
	ADD.W	D0,D1
	MOVE.W	D1,$16(A2)
	ADD.W	D0,D0
	ADD.L	D0,D2
	MOVE.L	D2,$1C(A2)
	BRA.S	lbC00069A

lbC000692	MOVE.L	D2,$1C(A2)
	MOVE.W	(A1)+,$20(A2)
lbC00069A	MOVE.W	(A0)+,D0
	ANDI.W	#$3FF,D0
	MOVEQ	#0,D1
	MOVE.B	(A0)+,D1
	MOVEQ	#15,D2
	AND.B	D1,D2
	MOVE.B	D2,12(A2)
	LSR.B	#4,D1
	MOVE.B	D1,10(A2)
	MOVEQ	#0,D3
	MOVE.B	(A0)+,D3
	MOVE.B	D3,13(A2)
	MOVE.L	A0,(A2)
	MOVEQ	#15,D1
	AND.B	D3,D1
	LSR.B	#4,D3
	MOVEM.W	D1/D3,14(A2)
	MOVE.W	D0,6(A2)
	BEQ.S	lbC000720
	CMP.B	#3,D2
	BNE.S	lbC0006F2
	MOVE.W	D0,$2A(A2)
	MOVE.W	$22(A2),D2
	CMP.W	D2,D0
	SLT	$28(A2)
	MOVE.B	13(A2),$29(A2)
	MOVE.W	$26(A2),D0
	OR.W	D0,14(A5)
	RTS

lbC0006F2	MOVE.W	D0,$22(A2)
	CLR.B	$2D(A2)
	TST.B	4(A2)
	BNE.S	lbC000720
	CLR.W	8(A3)
	MOVE.W	#1,6(A3)
	MOVE.W	$26(A2),D0
	MOVE.W	D0,$96(A6)
	OR.W	D0,14(A5)
	MOVE.L	$12(A2),(A3)			; address

	move.l	D1,-(SP)
	move.l	$12(A2),D1
	bsr.w	SetAdr

	MOVE.W	$16(A2),4(A3)			; length

	move.w	$16(A2),D1
	bsr.w	SetLen
	move.l	(SP)+,D1

lbC000720	MOVE.W	$18(A2),$1A(A2)
	MOVE.W	$22(A2),$24(A2)
	MOVEQ	#0,D1
	MOVE.B	13(A2),D1
	SUBI.B	#11,D2
	BLT.S	lbC00074E
	BEQ.S	lbC000750
	SUBQ.B	#1,D2
	BEQ.S	lbC000756
	SUBQ.B	#1,D2
	BEQ.S	lbC000778
	SUBQ.B	#1,D2
	BEQ.S	lbC000762
	MOVE.B	D1,6(A5)
	MOVE.B	D1,7(A5)
lbC00074E	RTS

lbC000750	SUBQ.W	#1,D1
	LSL.W	#5,D1
	BRA.S	lbC000790

lbC000756	CMP.W	#$40,D1
	BLE.S	lbC00075E
	MOVEQ	#$40,D1
lbC00075E	BRA.L	lbC000818

lbC000762	ANDI.B	#$FD,$BFE001
	NOT.B	D1
	ANDI.B	#1,D1

	asl.b	#1,D1				; bug, missing command

	OR.B	D1,$BFE001
	RTS

lbC000778	MOVE.W	8(A5),D1
	ANDI.W	#$FFE0,D1
	ADDI.W	#$20,D1
	CMP.W	10(A5),D1
	BLT.S	lbC000790
	MOVE.W	$FC(A4),D1
	LSL.W	#3,D1

	bsr.w	SongEnd

lbC000790	MOVE.W	D1,8(A5)
	CLR.W	12(A5)
;	ST	5(A5)
	RTS

lbC00079E	LEA	$98(A5),A2
	LEA	$A0(A6),A3
	BSR.L	lbC0007D4
	LEA	$C6(A5),A2
	LEA	$B0(A6),A3
	BSR.L	lbC0007D4
	LEA	$F4(A5),A2
	LEA	$C0(A6),A3
	BSR.L	lbC0007D4
	LEA	$122(A5),A2
	LEA	$D0(A6),A3
	BSR.L	lbC0007D4
	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTS

lbC0007D4	MOVE.B	12(A2),D0
	BEQ.L	lbC0008FA
	CMP.B	#10,D0
	BEQ.S	lbC0007F8
	SUBQ.B	#1,D0
	BEQ.S	lbC000834
	SUBQ.B	#1,D0
	BEQ.S	lbC00084A
	SUBQ.B	#1,D0
	BEQ.L	lbC000870
	SUBQ.B	#1,D0
	BEQ.L	lbC0008B4
	RTS

lbC0007F8	MOVE.W	$18(A2),D1
	MOVE.W	$10(A2),D0
	BEQ.S	lbC00080E
	ADD.W	D0,D1
	CMP.W	#$40,D1
	BLE.S	lbC000818
	MOVEQ	#$40,D1
	BRA.S	lbC000818

lbC00080E	MOVE.W	14(A2),D0
	SUB.W	D0,D1
	BPL.S	lbC000818
	MOVEQ	#0,D1
lbC000818	MOVE.W	D1,$18(A2)
	TST.B	4(A2)
	BNE.S	lbC000832
;	TST.B	$6D4
;	BEQ.S	lbC00082E
;	MULU.W	$6D2,D1
;	SWAP	D1
;lbC00082E	MOVE.W	D1,8(A3)		; volume

	bsr.w	ChangeVolume
	bsr.w	SetVol

lbC000832	RTS

lbC000834	MOVEQ	#0,D0
	MOVE.B	13(A2),D0
	MOVE.W	$22(A2),D1
	SUB.W	D0,D1
	CMP.W	#$71,D1
	BGE.S	lbC000860
	MOVEQ	#$71,D1
	BRA.S	lbC000860

lbC00084A	MOVEQ	#0,D0
	MOVE.B	13(A2),D0
	MOVE.W	$22(A2),D1
	ADD.W	D0,D1
	CMP.W	#$358,D1
	BLE.S	lbC000860
	MOVE.W	#$358,D1
lbC000860	MOVE.W	D1,$22(A2)
	TST.B	4(A2)
	BNE.S	lbC00086E
	MOVE.W	D1,6(A3)			; period

	bsr.w	SetPer

lbC00086E	RTS

lbC000870	MOVE.B	13(A2),D0
	BEQ.S	lbC00087A
	MOVE.B	D0,$29(A2)
lbC00087A	MOVE.W	$22(A2),D1
	MOVE.W	$2A(A2),D2
	CMP.W	D1,D2
	BEQ.S	lbC0008B2
	MOVEQ	#0,D0
	MOVE.B	$29(A2),D0
	TST.B	$28(A2)
	BNE.S	lbC00089C
	ADD.W	D0,D1
	CMP.W	D1,D2
	BGT.S	lbC0008A4
	MOVE.W	D2,D1
	BRA.S	lbC0008A4

lbC00089C	SUB.W	D0,D1
	CMP.W	D1,D2
	BLT.S	lbC0008A4
	MOVE.W	D2,D1
lbC0008A4	MOVE.W	D1,$22(A2)
	TST.B	4(A2)
	BNE.S	lbC0008B2
	MOVE.W	D1,6(A3)			; period

	bsr.w	SetPer

lbC0008B2	RTS

lbC0008B4	MOVE.B	13(A2),D0
	BEQ.S	lbC0008BE
	MOVE.B	D0,$2C(A2)
lbC0008BE	LEA	lbW000952(PC),A0
	MOVEQ	#$7F,D0
	AND.B	$2D(A2),D0
	LSR.B	#2,D0
	MOVEQ	#0,D1
	MOVE.B	0(A0,D0.W),D1
	MOVEQ	#15,D0
	AND.B	$2C(A2),D0
	MULU.W	D0,D1
	LSR.W	#6,D1
	MOVE.W	$22(A2),D0
	ADD.W	D0,D1
	MOVE.B	$2C(A2),D0
	LSR.B	#2,D0
	ANDI.B	#$3C,D0
	ADD.B	D0,$2D(A2)
	TST.B	4(A2)
	BNE.S	lbC0008F8
	MOVE.W	D1,6(A3)			; period

	bsr.w	SetPer

lbC0008F8	RTS

lbC0008FA	TST.B	13(A2)
	BEQ.S	lbC000950
	TST.B	4(A2)
	BNE.S	lbC000950
	MOVE.B	6(A5),D1
	SUB.B	7(A5),D1
	BEQ.S	lbC00092E
	CMP.B	#2,D1
	BEQ.S	lbC000928
	CMP.B	#3,D1
	BEQ.S	lbC00092E
	CMP.B	#5,D1
	BEQ.S	lbC000928
	MOVE.W	$10(A2),D0
	BRA.S	lbC000934

lbC000928	MOVE.W	14(A2),D0
	BRA.S	lbC000934

lbC00092E	MOVE.W	$22(A2),D2
	BRA.S	lbC00094C

lbC000934	ADD.W	D0,D0
	MOVE.W	$22(A2),D1
	LEA	lbW000972(PC),A0
	LEA	0(A0,D0.W),A1
	MOVEQ	#$24,D3
lbC000944	MOVE.W	(A1)+,D2
	CMP.W	(A0)+,D1
	DBGE	D3,lbC000944
lbC00094C	MOVE.W	D2,6(A3)		; period

	move.l	D1,-(SP)
	move.l	D2,D1
	bsr.w	SetPer
	move.l	(SP)+,D1

lbC000950	RTS

lbW000952	dc.w	$18
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
lbW000972	dc.w	$358
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
	dc.w	0
	dc.w	0

	Section	Buffer,BSS
Base
	ds.b	336

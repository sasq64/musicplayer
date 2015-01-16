	*****************************************************
	****   Paul Robotham replayer for EaglePlayer,	 ****
	****        all adaptions by Wanted Team	 ****
	****     DeliTracker (?) compatible version	 ****
	*****************************************************

	incdir	"dh2:include/"
	include 'misc/eagleplayer2.01.i'

	SECTION	Player_Code,CODE

	PLAYERHEADER Tags

	dc.b	'$VER: Paul Robotham player module V1.0 (31 May 2001)',0
	even
Tags
	dc.l	DTP_PlayerVersion,1
	dc.l	EP_PlayerVersion,9
	dc.l	DTP_RequestDTVersion,DELIVERSION
	dc.l	DTP_PlayerName,PlayerName
	dc.l	DTP_Creator,Creator
	dc.l	DTP_Check2,Check2
	dc.l	DTP_ExtLoad,ExtLoad
	dc.l	DTP_InitPlayer,InitPlayer
	dc.l	DTP_EndPlayer,EndPlayer
	dc.l	DTP_InitSound,InitSound
	dc.l	DTP_EndSound,EndSound
	dc.l	DTP_Interrupt,Interrupt
	dc.l	DTP_Volume,SetVolume
	dc.l	DTP_Balance,SetVolume
	dc.l	EP_Voices,SetVoices
	dc.l	EP_Get_ModuleInfo,GetInfos
	dc.l	EP_StructInit,StructInit
	dc.l	EP_SampleInit,SampleInit
	dc.l	EP_Flags,EPB_Volume!EPB_Balance!EPB_ModuleInfo!EPB_Voices!EPB_SampleInfo!EPB_Songend!EPB_Analyzer!EPB_Packable!EPB_Restart!EPB_LoadFast
	dc.l	0

PlayerName
	dc.b	'Paul Robotham',0
Creator
	dc.b	'(c) 1990-95 by Paul Robotham,',10
	dc.b	'adapted by Wanted Team',0
Prefix
	dc.b	'.dat',0
SampleName
	dc.b	'mdtest.ssd',0
	even
ModulePtr
	dc.l	0
EagleBase
	dc.l	0
SampleInfoPtr
	dc.l	0
LastPos
	dc.l	0
Voice1
	dc.w	-1
Voice2
	dc.w	-1
Voice3
	dc.w	-1
Voice4
	dc.w	-1
RightVolume
	dc.w	64
LeftVolume
	dc.w	64
StructAdr
	ds.b	UPS_SizeOF

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

	move.l	lbL015828(PC),A2
	cmp.l	LastPos(PC),A2
	bne.b	NoStop
	move.l	EagleBase(PC),A5
	move.l	dtg_SongEnd(A5),A1
	jsr	(A1)
	bsr.w	InitSound
NoStop
	lea	StructAdr(PC),A0
	clr.w	UPS_Enabled(A0)
	movem.l	(A7)+,D1-A6
	moveq	#0,D0
	rts

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
	subq.l	#1,D5
Next
	jsr	ENPP_AllocSampleStruct(A5)
	move.l	D0,(A3)
	beq.b	return
	move.l	D0,A3

	move.l	(A2)+,EPS_Adr(A3)		; sample address
	moveq	#0,D0
	move.w	(A2)+,D0
	add.l	D0,D0
	move.l	D0,EPS_Length(A3)		; sample length
	move.l	#64,EPS_Volume(A3)
	move.w	#USITY_RAW,EPS_Type(A3)
	move.w	#USIB_Playable!USIB_Saveable!USIB_8BIT,EPS_Flags(A3)
	addq.l	#6,A2
	dbf	D5,Next

	moveq	#0,D7
return
	move.l	D7,D0
	rts

***************************************************************************
******************************* EP_StructInit *****************************
***************************************************************************

StructInit
	lea	StructAdr(PC),A0
	rts

***************************************************************************
***************************** EP_Get_ModuleInfo ***************************
***************************************************************************

GetInfos
	lea	InfoBuffer(PC),A0
	rts

LoadSize	=	4
Samples		=	12
SamplesSize	=	20
Voices		=	28

InfoBuffer
	dc.l	MI_LoadSize,0		;4
	dc.l	MI_Samples,0		;12
	dc.l	MI_SamplesSize,0	;20
	dc.l	MI_Voices,0		;28
	dc.l	MI_MaxVoices,4
	dc.l	MI_Prefix,Prefix
	dc.l	0

***************************************************************************
******************************* DTP_Check2 ********************************
***************************************************************************

Check2
	movea.l	dtg_ChkData(A5),A0
	moveq	#-1,D0

	move.l	A0,A1
	move.w	(A0)+,D1
	beq.b	Fault
	cmp.w	#4,D1
	bhi.b	Fault
	tst.b	(A0)
	bne.b	Fault
	move.w	(A0)+,D2
	tst.b	(A0)
	bne.b	Fault
	move.w	(A0)+,D3
	tst.b	(A0)
	bne.b	Fault
	move.w	(A0)+,D4
	subq.w	#1,D1
StartPos
	tst.w	(A0)	
	bne.b	Fault
	tst.l	(A0)+
	beq.b	Fault
	dbf	D1,StartPos
	subq.w	#1,D2
Next1
	move.l	(A0)+,D1
	beq.b	Fault
	bmi.b	Fault
	btst	#0,D1
	bne.b	Fault
	dbf	D2,Next1
	subq.w	#1,D3
	move.l	(A0),D2
Next2
	move.l	(A0)+,D1
	beq.b	Fault
	bmi.b	Fault
	btst	#0,D1
	bne.b	Fault
	dbf	D3,Next2
	mulu.w	#12,D4
	lea	(A0,D4.W),A0
	sub.l	A1,A0
	cmp.l	A0,D2
	bne.b	Fault
	add.l	D2,A1
	moveq	#126,D1
	move.w	#$3F3F,D2
FinalCheck
	cmp.w	(A1)+,D2
	bne.b	Fault
	dbf	D1,FinalCheck

	moveq	#0,D0
Fault
	rts

***************************************************************************
******************************* DTP_ExtLoad *******************************
***************************************************************************

ExtLoad
	movea.l	dtg_PathArrayPtr(A5),A0
	clr.b	(A0)
	movea.l	dtg_CopyDir(A5),A0
	jsr	(A0)
	bsr.s	CopyName
	move.l	dtg_LoadFile(A5),A0
	jsr	(A0)
	tst.l	D0
	beq.b	ExtLoadOK
	move.l	dtg_PathArrayPtr(A5),A0
	clr.b	(A0)
	move.l	dtg_CopyDir(A5),A0
	jsr	(A0)
	bsr.b	CopyName2
	move.l	dtg_LoadFile(A5),A0
	jsr	(A0)
ExtLoadOK
	rts

CopyName2
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

CopyName
	movea.l	dtg_PathArrayPtr(A5),A0
loop
	tst.b	(A0)+
	bne.s	loop
	subq.l	#1,A0
	movea.l	dtg_FileArrayPtr(A5),A1
smp
	move.b	(A1)+,(A0)+
	bne.s	smp
	subq.l	#5,A0

	cmpi.b	#'.',(A0)+
	bne.s	ExtError

	cmpi.b	#'d',(A0)
	beq.b	d_OK
	cmpi.b	#'D',(A0)
	bne.s	ExtError
d_OK
	cmpi.b	#'a',1(A0)
	beq.b	a_OK
	cmpi.b	#'A',1(A0)
	bne.s	ExtError
a_OK
	cmpi.b	#'t',2(A0)
	beq.b	t_OK
	cmpi.b	#'T',2(A0)
	bne.s	ExtError
t_OK
	move.b	#'S',(A0)+
	move.b	#'S',(A0)+
	move.b	#'D',(A0)+
	clr.b	(A0)
	rts

ExtError
	clr.b	-2(A0)
	rts

***************************************************************************
***************************** DTP_InitPlayer ******************************
***************************************************************************

InitPlayer
	moveq	#0,D0
	movea.l	dtg_GetListData(A5),A0
	jsr	(A0)

	lea	ModulePtr(PC),A6
	move.l	A0,(A6)+			; songdata buffer
	lea	InfoBuffer(PC),A4		; A4 reserved for InfoBuffer
	move.l	D0,LoadSize(A4)
	move.w	(A0),Voices+2(A4)
	move.w	6(A0),Samples+2(A4)

	moveq	#1,D0
	movea.l	dtg_GetListData(A5),A0
	jsr	(A0)

	add.l	D0,LoadSize(A4)
	move.l	A5,(A6)+			; EagleBase
	move.l	A0,A1
	move.l	ModulePtr(PC),A0
	bsr.w	Init_Mod

	cmp.l	SamplesSize(A4),D0
	bge.b	SamplesOK
	moveq	#EPR_ModuleTooShort,D0
	rts
SamplesOK
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
	lea	lbW015DBE(PC),A0
	move.l	#$003F003F,(A0)
	move.l	ModulePtr(PC),A0
	bra.w	Init_Song

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
	move.l	A0,-(A7)
	lea	StructAdr+UPS_Voice1Adr(PC),A0
	cmp.l	#$DFF0A0,A4
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice2Adr(PC),A0
	cmp.l	#$DFF0B0,A4
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice3Adr(PC),A0
	cmp.l	#$DFF0C0,A4
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice4Adr(PC),A0
.SetVoice
	move.l	-6(A2),(A0)
	move.l	D0,UPS_Voice1Len(A0)
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
*************************** Paul Robotham player **************************
***************************************************************************

; Player from game Starlord (c) 1994 by Microprose

Init_Mod
lbC014CC2	MOVEM.L	D0-D7/A0-A6,-(SP)
	MOVE.L	A0,D1
	MOVE.L	A1,D0
	LEA	lbL015828(pc),A1
	MOVE.W	(A0)+,D7
	MOVE.W	D7,lbW015DA2
	MOVE.W	(A0)+,D6
	MOVE.W	(A0)+,D5
	MOVE.W	(A0)+,D4
	MOVE.W	D7,D3
	MOVE.W	D7,D2
	ADD.W	D5,D2
	ADD.W	D6,D2
	SUBQ.W	#1,D2
	MOVEA.L	A0,A2
lbC014CEA	ADD.L	D1,(A2)+
	DBRA	D2,lbC014CEA
	ASL.W	#2,D6
	ASL.W	#2,D5
	ASL.W	#2,D3
	MOVEA.L	A0,A2
	ADDA.W	D3,A2
	ADDA.W	D6,A2
	ADDA.W	D5,A2
	SUBQ.W	#1,D4

	move.l	A2,(A6)				; SampleInfoPtr
	moveq	#0,D1

lbC014D00
	moveq	#0,D2
	add.w	4(A2),D2
	add.l	D2,D2
	add.l	(A2),D2
	cmp.l	D2,D1
	bge.b	MaxSize
	move.l	D2,D1
MaxSize
	ADD.L	D0,(A2)
	ADD.L	D0,6(A2)
	LEA	12(A2),A2
	DBRA	D4,lbC014D00

	move.l	D1,SamplesSize(A4)

;	MOVE.W	#1,lbW015DA4
;	CLR.L	lbL015E44
	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTS

Init_Song
lbC014D22	MOVEM.L	D0-D7/A0-A6,-(SP)
	MOVE.L	A0,D1
;	MOVE.L	A1,D0
	LEA	lbL015828(pc),A1
	MOVE.W	(A0)+,D7
	MOVE.W	D7,lbW015DA2
	MOVE.W	(A0)+,D6
	MOVE.W	(A0)+,D5
	MOVE.W	(A0)+,D4
	MOVE.W	D7,D3
	MOVE.W	D7,D2
	ADD.W	D5,D2
	ADD.W	D6,D2
	SUBQ.W	#1,D2
	MOVEA.L	A0,A2
	ASL.W	#2,D6
	ASL.W	#2,D5
	ASL.W	#2,D3
	MOVEA.L	A0,A2
	ADDA.W	D3,A2
	MOVE.L	A2,lbL015D94
	ADDA.W	D6,A2
	MOVE.L	A2,lbL015D98
	ADDA.W	D5,A2
	MOVE.L	A2,lbL015CD0
;	SUBQ.W	#1,D4
	SUBQ.W	#1,D7
	LEA	lbL015D84(pc),A2

	lea	LastPos(PC),A4
	move.l	4(A0),(A4)
	subq.l	#1,(A4)

lbC014D74	MOVE.L	(A0)+,(A1)
	MOVE.W	#10,4(A1)
	CLR.W	$32(A1)
	MOVE.W	#10,$34(A1)
	CLR.B	$1A(A1)
	CLR.B	$1B(A1)
	CLR.B	$2E(A1)
	BSET	#5,$1B(A1)
	CLR.W	$24(A1)
	CLR.B	6(A1)
	MOVE.B	#3,7(A1)
	CLR.B	8(A1)
	CLR.B	9(A1)
	CLR.B	$30(A1)
	CLR.B	$2F(A1)
	MOVE.W	#$2710,$1E(A1)
	MOVE.B	#1,$1C(A1)
	MOVE.B	#1,$1D(A1)
	MOVEA.L	lbL015D94(pc),A3
	MOVE.L	(A3),10(A1)
	MOVEA.L	lbL015D98(pc),A3
	MOVE.L	(A3),14(A1)
	MOVEA.L	lbL015CD0(pc),A3
	MOVE.L	A3,$12(A1)
	MOVE.L	(A2)+,$16(A1)
	LEA	$38(A1),A1
	DBRA	D7,lbC014D74
	CLR.W	lbW015DA0
	LEA	lbL0159E8(pc),A1
	MOVE.W	#3,D7
lbC014E02	CLR.L	(A1)
	CLR.W	4(A1)
	CLR.L	6(A1)
	CLR.W	10(A1)
	CLR.W	14(A1)
	LEA	$12(A1),A1
	DBRA	D7,lbC014E02
	MOVE.W	#1,lbW015DA4
	CLR.L	lbL015E44
	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTS

Play
;lbC014E30	TST.W	lbW023E4C
;	BEQ.L	lbC01526E
;	TST.B	lbB015DB6
;	BNE.L	lbC01526E
	MOVE.W	lbW015DA2(pc),D7
	MOVE.L	lbL015E58(pc),D5
	SUBQ.W	#1,D7
	LEA	lbL015828(pc),A0
	LEA	$DFF0A0,A4
	LEA	lbL0159E8(pc),A5
	MOVE.W	#0,D6
lbC014E68	TST.W	14(A5)
	BEQ.S	lbC014E76
	BSR.L	lbC015292
	BRA.L	lbC015214

lbC014E76	TST.B	$1B(A0)
	BPL.S	lbC014E80
	BRA.L	lbC015214

lbC014E80	MOVE.B	$1C(A0),D0
	ADD.B	D0,6(A0)
	ADDQ.B	#4,7(A0)
	ADDQ.B	#1,8(A0)
	TST.W	4(A0)
	BNE.L	lbC01509A
	MOVEA.L	(A0),A1
lbC014E9A	MOVEQ	#0,D0
	MOVE.B	(A1)+,D0
	BMI.L	lbC0151FC
	BEQ.L	lbC0151D8
	BCLR	#3,$1B(A0)
	CMP.B	#$7F,D0
	BNE.S	lbC014EBC
	BSET	#3,$1B(A0)
	BRA.L	lbC015034

lbC014EBC	BTST	#0,$2E(A0)
	BEQ.S	lbC014ED0
	TST.B	$2F(A0)
	BNE.L	lbC014FB4
	BRA.L	lbC014F3E

lbC014ED0	CLR.B	$2F(A0)
	MOVEQ	#0,D1
	MOVE.W	D1,10(A4)
	BSET	D6,D1
	OR.L	D1,lbL015E48
	ANDI.W	#15,D1
	MOVE.W	D1,$DFF096
	BCLR	D6,lbB015DAE
	CLR.B	$36(A0)
	BCLR	#6,$1B(A0)
	SWAP	D0
	MOVEA.L	$12(A0),A2
	MOVE.L	(A2)+,(A4)			; adress
	MOVE.W	(A2)+,D0
	SWAP	D0
	ADD.W	D0,D0
	LEA	lbW015DCC(pc),A3
	MOVE.W	0(A3,D0.W),D0
	MOVE.L	D0,4(A4)			; length, period

	bsr.w	SetAll

	MOVE.W	D0,$22(A0)
	MOVE.L	(A2)+,$26(A0)
	MOVE.W	(A2)+,D1
	BNE.S	lbC014F32
	MOVEA.L	lbL023E4E(pc),A3
	MOVE.L	A3,$26(A0)
	MOVE.W	#8,D1
lbC014F32	SWAP	D1
	MOVE.W	D0,D1
	MOVE.L	D1,$2A(A0)
	BRA.L	lbC015034

lbC014F3E	MOVEQ	#0,D1
	BSET	D6,D1
	OR.L	D1,lbL015E48
	MOVE.L	$2A(A0),D1
	ADD.W	D0,D0
	LEA	lbW015DCC(pc),A3
	MOVE.W	0(A3,D0.W),D0
	MOVE.W	D0,D1
	MOVE.W	D1,6(A4)			; period
	MOVE.W	D0,$22(A0)
	MOVEQ	#0,D0
	MOVE.B	(A1)+,D0
	MOVE.W	D0,D1
	ANDI.B	#$1F,D1
	LSR.B	#5,D0
	LSL.W	D0,D1
	MOVEQ	#0,D2
	MOVE.W	$32(A0),D2
	MULU.W	lbW015DB2(pc),D1
	ADD.L	D2,D1
	DIVU.W	lbW015DB4(pc),D1
	MOVE.W	D1,4(A0)
	SWAP	D1
	MOVE.W	D1,$32(A0)
	MOVE.L	A1,(A0)
	BTST	#2,$2E(A0)
	BNE.S	lbC014F9C
	CLR.B	6(A0)
lbC014F9C	BTST	#1,$2E(A0)
	BNE.L	lbC0150DE
	MOVE.B	#3,7(A0)
	CLR.B	8(A0)
	BRA.L	lbC0150DE

lbC014FB4	MOVE.W	#0,8(A4)
	MOVEQ	#0,D1
	MOVE.W	D1,10(A4)
	BSET	D6,D1
	OR.L	D1,lbL015E48
	ANDI.W	#15,D1
	MOVE.W	D1,$DFF096
	BCLR	D6,lbB015DAE
	SWAP	D0
	MOVEA.L	$12(A0),A2
	MOVE.W	10(A2),D0
	BNE.S	lbC014FF4
	MOVEA.L	lbL023E4E(pc),A3
	MOVE.L	A3,(A4)					; address
	MOVE.L	#$80100,D0
	BRA.S	lbC015006

lbC014FF4	MOVE.L	6(A2),(A4)			; address
	SWAP	D0
	ADD.W	D0,D0
	LEA	lbW015DCC(pc),A3
	MOVE.W	0(A3,D0.W),D0
lbC015006	MOVE.L	D0,4(A4)			; length, period
	MOVE.W	D0,$22(A0)
	MOVE.L	6(A2),$26(A0)
	MOVE.W	10(A2),D1
	BNE.S	lbC015028
	MOVEA.L	lbL023E4E(pc),A3
	MOVE.L	A3,$26(A0)
	MOVE.W	#8,D1
lbC015028	SWAP	D1
	MOVE.W	D0,D1
	MOVE.L	D1,$2A(A0)
	CLR.B	$2F(A0)
lbC015034	MOVEQ	#0,D0
	MOVE.B	(A1)+,D0
	MOVE.W	D0,D1
	ANDI.B	#$1F,D1
	LSR.B	#5,D0
	LSL.W	D0,D1
	MOVEQ	#0,D2
	MOVE.W	$32(A0),D2
	MULU.W	lbW015DB2(pc),D1
	ADD.L	D2,D1
	DIVU.W	lbW015DB4(pc),D1
	MOVE.W	D1,4(A0)
	SWAP	D1
	MOVE.W	D1,$32(A0)
	BTST	#3,$1B(A0)
	BNE.S	lbC015086
	BTST	#2,$2E(A0)
	BNE.S	lbC015074
	CLR.B	6(A0)
lbC015074	BTST	#1,$2E(A0)
	BNE.S	lbC015086
	MOVE.B	#3,7(A0)
	CLR.B	8(A0)
lbC015086	MOVE.L	A1,(A0)
	BTST	#3,$1B(A0)
	BNE.S	lbC01509A
	BSET	D6,lbB015DA9
	BRA.L	lbC0150DE

lbC01509A	BTST	D6,lbB015DA9
	BEQ.S	lbC0150C6
	BCLR	D6,lbB015DA9
	BSET	D6,lbB015DA8
	BTST	D6,D5
	BEQ.S	lbC0150DE
	MOVE.W	#$8200,D0
	BSET	D6,D0
	MOVE.W	D0,$DFF096
	BSET	D6,lbB015DAE
	BRA.S	lbC0150DE

lbC0150C6	BTST	D6,lbB015DA8
	BEQ.S	lbC0150DE
	BCLR	D6,lbB015DA8
	MOVE.L	$26(A0),(A4)			; address
	MOVE.L	$2A(A0),4(A4)
lbC0150DE	BTST	#2,$1B(A0)
	BEQ.S	lbC01510C
	MOVE.W	$22(A0),D0
	MOVE.W	$20(A0),D1
	MOVE.W	D0,D2
	MOVE.W	$24(A0),D3
	SUB.W	D1,D2
	BPL.S	lbC0150FA
	NEG.W	D3
lbC0150FA	ADD.W	D3,D1
	TST.W	D3
	BPL.S	lbC015104
	NEG.W	D2
	NEG.W	D3
lbC015104	CMP.W	D2,D3
	BGE.S	lbC01510C
	MOVE.W	D1,D0
	BRA.S	lbC015110

lbC01510C	MOVE.W	$22(A0),D0
lbC015110	MOVE.W	D0,$20(A0)
	BTST	#4,$1B(A0)
	BEQ.S	lbC015140
	MOVEA.L	10(A0),A2
	MOVEQ	#0,D0
	MOVE.B	6(A0),D0
	MOVE.B	0(A2,D0.W),D2
	EXT.W	D2
	MOVE.W	$20(A0),D1
	MOVE.W	D1,D0
	MULS.W	D2,D1
	MOVEQ	#0,D2
	MOVE.W	$1E(A0),D2
	DIVS.W	D2,D1
	ADD.W	D1,D0
	BRA.S	lbC015144

lbC015140	MOVE.W	$20(A0),D0
lbC015144	MOVE.W	D0,D1
	MOVE.W	D0,6(A4)			; period
	SUBQ.W	#1,4(A0)
	BTST	D6,lbB015DAE
	BEQ.L	lbC015214
	MOVE.B	$1A(A0),D0
	BNE.S	lbC015162
	MOVEQ	#0,D0
	BRA.S	lbC0151D0

lbC015162	MOVEA.L	14(A0),A1
	MOVE.B	7(A0),D0
	ANDI.W	#$FF,D0
	MOVE.B	0(A1,D0.W),D0
	BPL.L	lbC015184
	NEG.B	D0
	ADDQ.B	#3,D0
	ANDI.B	#$FC,D0
	SUB.B	D0,7(A0)
	BRA.S	lbC015162

lbC015184	ANDI.W	#$3F,D0
	BTST	#6,$1B(A0)
	BEQ.S	lbC0151A4
	MOVE.B	$36(A0),D2
	BEQ.S	lbC0151A8
	SUB.B	$37(A0),D2
	BPL.S	lbC01519E
	MOVEQ	#0,D2
lbC01519E	MOVE.B	D2,$36(A0)
	BRA.S	lbC0151A8

lbC0151A4	MOVE.B	$1A(A0),D2
lbC0151A8	ANDI.W	#$3F,D2
	MULU.W	D2,D0
	DIVU.W	#$3F,D0
	BTST	D6,D5
	BNE.S	lbC0151BA
	MOVEQ	#0,D0
	BRA.S	lbC0151D0

lbC0151BA	MOVE.W	lbW015DBE(pc),D2
	CMP.W	#$3F,D2
	BEQ.S	lbC0151D0
	MULU.W	D2,D0
	DIVU.W	#$3F,D0
	ANDI.W	#$3F,D0
lbC0151D0
;	MOVE.W	D0,8(A4)		; volume

	bsr.w	ChangeVolume
	bsr.w	SetVol

	BRA.L	lbC015214

lbC0151D8	ADDQ.W	#1,lbW015DA0
	BSET	#7,$1B(A0)
	MOVEQ	#0,D0
	BSET	D6,D0
	ANDI.W	#15,D0
	MOVE.W	D0,$DFF096
	BCLR	D6,lbB015DAE
	BRA.L	lbC015214

lbC0151FC	ANDI.W	#$1F,D0
	LSL.W	#2,D0
	LEA	lbL015CE4(pc),A3
	MOVEA.L	0(A3,D0.W),A3
	JSR	(A3)
	MOVE.L	A1,(A0)
	BRA.L	lbC014E9A

lbC015214	LEA	$10(A4),A4
	ADDQ.W	#1,D6
	LEA	$38(A0),A0
	LEA	$12(A5),A5
	DBRA	D7,lbC014E68
	MOVE.W	lbW015DC4(pc),D0
	ADDQ.W	#1,D0
	CMP.W	lbW015DC6(pc),D0
	BPL.S	lbC01523E
	MOVE.W	D0,lbW015DC4
	BRA.S	lbC01526E

lbC01523E	CLR.W	lbW015DC4
	MOVE.W	lbW015DC2(pc),D0
	BEQ.S	lbC01526E
	MOVE.W	lbW015DBE(pc),D0
	CMP.W	lbW015DC0(pc),D0
	BEQ.S	lbC015262
	ADD.W	lbW015DC2(pc),D0
	BRA.S	lbC015268

lbC015262	CLR.W	lbW015DC2
lbC015268	MOVE.W	D0,lbW015DBE
lbC01526E	RTS

;	MOVE.W	D0,-(SP)
;	TST.W	lbW015DC2
;	BNE.S	lbC01528E
;	MOVE.W	lbW015DC8,D0
;	NEG.W	D0
;	MOVE.W	D0,lbW015DC8
;	MOVE.W	D0,lbW015DC2
;lbC01528E	MOVE.W	(SP)+,D0
;	RTS

lbC015292	MOVE.B	$1C(A0),D0
	ADD.B	D0,6(A0)
	ADDQ.B	#4,7(A0)
	ADDQ.B	#1,8(A0)
	TST.W	4(A0)
	BNE.L	lbC01546C
	MOVEA.L	(A0),A1
lbC0152AC	MOVEQ	#0,D0
	MOVE.B	(A1)+,D0
	BMI.L	lbC015554
	BEQ.L	lbC015544
	BCLR	#3,$1B(A0)
	CMP.B	#$7F,D0
	BNE.S	lbC0152CE
	BSET	#3,$1B(A0)
	BRA.L	lbC015406

lbC0152CE	BTST	#0,$2E(A0)
	BEQ.S	lbC0152E2
	TST.B	$2F(A0)
	BNE.L	lbC0153A0
	BRA.L	lbC01532E

lbC0152E2	CLR.B	$2F(A0)
	MOVEQ	#0,D1
	BSET	D6,D1
	OR.L	D1,lbL015E48
	SWAP	D0
	MOVEA.L	$12(A0),A2
	MOVE.W	4(A2),D0
	SWAP	D0
	ADD.W	D0,D0
	LEA	lbW015DCC(pc),A3
	MOVE.W	0(A3,D0.W),D0
	MOVE.W	D0,$22(A0)
	MOVE.L	(A2)+,$26(A0)
	MOVE.W	(A2)+,D1
	BNE.S	lbC015322
	MOVEA.L	lbL023E4E(pc),A3
	MOVE.L	A3,$26(A0)
	MOVE.W	#8,D1
lbC015322	SWAP	D1
	MOVE.W	D0,D1
	MOVE.L	D1,$2A(A0)
	BRA.L	lbC015406

lbC01532E	MOVEQ	#0,D1
	BSET	D6,D1
	OR.L	D1,lbL015E48
	MOVE.L	$2A(A0),D1
	ADD.W	D0,D0
	LEA	lbW015DCC(pc),A3
	MOVE.W	0(A3,D0.W),D0
;	MOVE.W	D0,D1					; po co ?
	MOVE.W	D0,$22(A0)
	MOVEQ	#0,D0
	MOVE.B	(A1)+,D0
	MOVE.W	D0,D1
	ANDI.B	#$1F,D1
	LSR.B	#5,D0
	LSL.W	D0,D1
	MOVEQ	#0,D2
	MOVE.W	$32(A0),D2
	MULU.W	lbW015DB2(pc),D1
	ADD.L	D2,D1
	DIVU.W	lbW015DB4(pc),D1
	MOVE.W	D1,4(A0)
	SWAP	D1
	MOVE.W	D1,$32(A0)
	MOVE.L	A1,(A0)
	BTST	#2,$2E(A0)
	BNE.S	lbC015388
	CLR.B	6(A0)
lbC015388	BTST	#1,$2E(A0)
	BNE.L	lbC015494
	MOVE.B	#3,7(A0)
	CLR.B	8(A0)
	BRA.L	lbC015494

lbC0153A0	MOVEQ	#0,D1
	BSET	D6,D1
	OR.L	D1,lbL015E48
	ANDI.W	#15,D1
	MOVE.W	D1,$DFF096
	SWAP	D0
	MOVEA.L	$12(A0),A2
	MOVE.W	10(A2),D0
	BNE.S	lbC0153CE
	MOVEA.L	lbL023E4E(pc),A3
	MOVE.L	#$80100,D0
	BRA.S	lbC0153DC

lbC0153CE	SWAP	D0
	ADD.W	D0,D0
	LEA	lbW015DCC(pc),A3
	MOVE.W	0(A3,D0.W),D0
lbC0153DC	MOVE.W	D0,$22(A0)
	MOVE.L	6(A2),$26(A0)
	MOVE.W	10(A2),D1
	BNE.S	lbC0153FA
	MOVEA.L	lbL023E4E(pc),A3
	MOVE.L	A3,$26(A0)
	MOVE.W	#8,D1
lbC0153FA	SWAP	D1
	MOVE.W	D0,D1
	MOVE.L	D1,$2A(A0)
	CLR.B	$2F(A0)
lbC015406	MOVEQ	#0,D0
	MOVE.B	(A1)+,D0
	MOVE.W	D0,D1
	ANDI.B	#$1F,D1
	LSR.B	#5,D0
	LSL.W	D0,D1
	MOVEQ	#0,D2
	MOVE.W	$32(A0),D2
	MULU.W	lbW015DB2(pc),D1
	ADD.L	D2,D1
	DIVU.W	lbW015DB4(pc),D1
	MOVE.W	D1,4(A0)
	SWAP	D1
	MOVE.W	D1,$32(A0)
	BTST	#3,$1B(A0)
	BNE.S	lbC015458
	BTST	#2,$2E(A0)
	BNE.S	lbC015446
	CLR.B	6(A0)
lbC015446	BTST	#1,$2E(A0)
	BNE.S	lbC015458
	MOVE.B	#3,7(A0)
	CLR.B	8(A0)
lbC015458	MOVE.L	A1,(A0)
	BTST	#3,$1B(A0)
	BNE.S	lbC01546C
	BSET	D6,lbB015DA9
	BRA.L	lbC015494

lbC01546C	BTST	D6,lbB015DA9
	BEQ.S	lbC015486
	BCLR	D6,lbB015DA9
	BSET	D6,lbB015DA8
	BTST	D6,D5
	BEQ.S	lbC015494
	BRA.S	lbC015494

lbC015486	BTST	D6,lbB015DA8
	BEQ.S	lbC015494
	BCLR	D6,lbB015DA8
lbC015494	BTST	#2,$1B(A0)
	BEQ.S	lbC0154C2
	MOVE.W	$22(A0),D0
	MOVE.W	$20(A0),D1
	MOVE.W	D0,D2
	MOVE.W	$24(A0),D3
	SUB.W	D1,D2
	BPL.S	lbC0154B0
	NEG.W	D3
lbC0154B0	ADD.W	D3,D1
	TST.W	D3
	BPL.S	lbC0154BA
	NEG.W	D2
	NEG.W	D3
lbC0154BA	CMP.W	D2,D3
	BGE.S	lbC0154C2
	MOVE.W	D1,D0
	BRA.S	lbC0154C6

lbC0154C2	MOVE.W	$22(A0),D0
lbC0154C6	MOVE.W	D0,$20(A0)
	BTST	#4,$1B(A0)
	BEQ.S	lbC0154F6
	MOVEA.L	10(A0),A2
	MOVEQ	#0,D0
	MOVE.B	6(A0),D0
	MOVE.B	0(A2,D0.W),D2
	EXT.W	D2
	MOVE.W	$20(A0),D1
	MOVE.W	D1,D0
	MULS.W	D2,D1
	MOVEQ	#0,D2
	MOVE.W	$1E(A0),D2
	DIVS.W	D2,D1
	ADD.W	D1,D0
	BRA.S	lbC0154FA

lbC0154F6	MOVE.W	$20(A0),D0
lbC0154FA	MOVE.W	D0,D1
	SUBQ.W	#1,4(A0)
	MOVE.B	$1A(A0),D0
	BEQ.S	lbC01553A
lbC015506	MOVEA.L	14(A0),A1
	MOVE.B	7(A0),D0
	ANDI.W	#$FF,D0
	MOVE.B	0(A1,D0.W),D0
	BPL.L	lbC015528
	NEG.B	D0
	ADDQ.B	#3,D0
	ANDI.B	#$FC,D0
	SUB.B	D0,7(A0)
	BRA.S	lbC015506

lbC015528	ANDI.W	#$3F,D0
	MOVE.B	$1A(A0),D2
	ANDI.W	#$3F,D2
	MULU.W	D2,D0
	DIVU.W	#$3F,D0
lbC01553A	BTST	D6,D5
	BNE.S	lbC015540
	MOVEQ	#0,D0
lbC015540	BRA.L	lbC01556C

lbC015544	ADDQ.W	#1,lbW015DA0
	BSET	#7,$1B(A0)
	BRA.L	lbC01556C

lbC015554	ANDI.W	#$1F,D0
	LSL.W	#2,D0
	LEA	lbL015CE4(pc),A3
	MOVEA.L	0(A3,D0.W),A3
	JSR	(A3)
	MOVE.L	A1,(A0)
	BRA.L	lbC0152AC

lbC01556C	BTST	D6,lbB015DAC
	BEQ.S	lbC015594
	MOVEQ	#0,D0
	BSET	D6,D0
	MOVE.W	D0,$DFF096
	MOVE.L	(A5),(A4)			; address
;	MOVE.L	4(A5),4(A4)			; period bug !!!

	move.w	4(A5),4(A4)

	BCLR	D6,lbB015DAC
	BSET	D6,lbB015DAB
	BRA.S	lbC0155DA

lbC015594	BTST	D6,lbB015DAB
	BEQ.S	lbC0155BC
	MOVE.W	#0,8(A4)
	MOVE.W	#$8200,D0
	BSET	D6,D0
	MOVE.W	D0,$DFF096
	BCLR	D6,lbB015DAB
	BSET	D6,lbB015DAA
	BRA.S	lbC0155DA

lbC0155BC	BTST	D6,lbB015DAA
	BEQ.S	lbC0155DA
	MOVE.L	6(A5),(A4)			; address
;	MOVE.L	10(A5),4(A4)			; period bug !!! 

	move.w	10(A5),4(A4)

	BCLR	D6,lbB015DAA
;	MOVE.W	$10(A5),8(A4)			; volume

	move.l	D0,-(SP)
	move.w	$10(A5),D0
	bsr.w	ChangeVolume
	bsr.w	SetVol
	move.l	(SP)+,D0

lbC0155DA	SUBQ.W	#1,14(A5)
	TST.W	14(A5)
	BNE.S	lbC0155F4
	MOVEQ	#0,D0
	BSET	D6,D0
	MOVE.W	D0,$DFF096
	MOVE.W	#0,8(A4)
lbC0155F4	TST.W	lbW015E5C
	BEQ.S	lbC015608
	CLR.W	lbW015E5C
	MOVE.W	#2,14(A5)
lbC015608	RTS

;	MOVEM.L	D0/A0,-(SP)
;	LEA	lbL0159E8,A0
;	MOVEQ	#3,D0
;lbC015616	TST.W	14(A0)
;	BPL.S	lbC015620
;	CLR.W	14(A0)
;lbC015620	LEA	$12(A0),A0
;	DBRA	D0,lbC015616
;	MOVEM.L	(SP)+,D0/A0
;	RTS

;lbC01562E	MOVEM.L	D2-D7/A2-A6,-(SP)
;	TST.L	(A0)
;	BEQ.L	lbC0156BA
;	MOVE.W	4(A0),D2
;	MULU.W	D0,D2
;	DIVU.W	#$3E8,D2
;	MULU.W	#$1C,D2
;	DIVU.W	#$3E8,D2
;	MOVEA.L	D2,A1
;	MOVEQ	#0,D2
;	MOVE.W	lbW015DBC,D3
;	LEA	lbL0159E8,A2
;	MOVE.W	#$7FFF,D4
;lbC01565E	CMP.W	14(A2),D4
;	BLT.S	lbC01566C
;	MOVE.W	14(A2),D4
;	MOVEA.L	A2,A3
;	MOVE.W	D2,D5
;lbC01566C	ADDQ.W	#1,D2
;	LEA	$12(A2),A2
;	DBRA	D3,lbC01565E
;	MOVE.L	(A0),(A3)
;	MOVE.W	4(A0),4(A3)
;	MOVE.W	D1,$10(A3)
;	MOVE.W	A1,14(A3)
;	MOVE.W	10(A0),D1
;	BNE.S	lbC01569E
;	MOVEA.L	lbL023E4E,A0
;	MOVE.L	A0,6(A3)
;	MOVE.W	#8,10(A3)
;	BRA.S	lbC0156B0

;lbC01569E	MOVE.L	6(A0),6(A3)
;	MOVE.W	10(A0),10(A3)
;	MOVE.W	#$FFFF,14(A3)
;lbC0156B0	MOVE.W	D0,12(A3)
;	BSET	D5,lbB015DAC
;lbC0156BA	MOVEM.L	(SP)+,D2-D7/A2-A6
;	RTS

lbC0156C0	MOVE.B	(A1)+,D0
	ANDI.W	#$FF,D0
	MOVEA.L	$16(A0),A2
	MOVE.L	A1,-(A2)
	MOVE.W	D0,-(A2)
	MOVE.L	A2,$16(A0)
	RTS

lbC0156D4	MOVEA.L	$16(A0),A2
	SUBQ.W	#1,(A2)
	BNE.S	lbC0156E2
	ADDQ.L	#6,$16(A0)
	RTS

lbC0156E2	MOVEA.L	2(A2),A1
	RTS

lbC0156E8	MOVEQ	#0,D0
	MOVE.B	(A1)+,D0
	BEQ.S	lbC015702
	MOVE.L	#$2710,D1
	DIVU.W	D0,D1
	MOVE.W	D1,$1E(A0)
	BSET	#4,$1B(A0)
	RTS

lbC015702	BCLR	#4,$1B(A0)
	RTS

lbC01570A	MOVE.B	(A1)+,$1C(A0)
	RTS

lbC015710	MOVEQ	#0,D0
	MOVE.B	(A1)+,D0
	BEQ.S	lbC015726
	ADD.W	D0,D0
	ADD.W	D0,D0
	MOVE.W	D0,$24(A0)
	BSET	#2,$1B(A0)
	RTS

lbC015726	BCLR	#2,$1B(A0)
	RTS

lbC01572E	MOVEQ	#0,D0
	MOVE.B	(A1)+,D0
	ASL.W	#2,D0
	MOVEA.L	lbL015D94(pc),A2
	MOVE.L	0(A2,D0.W),10(A0)
	RTS

lbC015742	MOVEQ	#0,D0
	MOVE.B	(A1)+,D0
	ASL.W	#2,D0
	MOVEA.L	lbL015D98(pc),A2
	MOVE.L	0(A2,D0.W),14(A0)
	RTS

lbC015756	MOVEQ	#0,D0
	MOVE.B	(A1)+,D0
	MOVE.B	D0,9(A0)
	MULU.W	#12,D0
	MOVEA.L	lbL015CD0(pc),A2
	ADDA.L	D0,A2
	MOVE.L	A2,$12(A0)
	MOVEQ	#0,D0
	BSET	D6,D0
	OR.L	D0,lbL015E4C

	or.l	D0,lbL015E54			; update from "Dawn Patrol"

	BCLR	#0,$2E(A0)
	MOVE.B	#1,$2F(A0)
	RTS

lbC015786	MOVE.B	(A1)+,D0
	MOVE.B	D0,$1A(A0)
	RTS

lbC01578E	MOVEQ	#0,D0
	MOVE.B	(A1)+,D0
	ASL.W	#4,D0
	MOVE.W	D0,lbW015DB2
	RTS

Error	MOVE.W	#$FFF,$DFF180
	RTS

lbC0157A6	MOVE.B	(A1)+,D0
	MOVE.B	D0,$2E(A0)
	MOVEQ	#0,D0
	BSET	D6,D0
	OR.L	D0,lbL015E54
	RTS

lbC0157B8	MOVE.B	(A1)+,D0
	ANDI.W	#3,D0
	MOVE.W	D0,lbW015DBC
	RTS

lbC0157C6	MOVE.B	(A1)+,D0
	MOVE.B	D0,lbB015DAD
	RTS

lbC0157D0	MOVEQ	#0,D0
	MOVE.B	(A1)+,D0
	MOVE.W	D0,lbW015DC0
	CMP.W	lbW015DBE(pc),D0
	BEQ.S	lbC0157E4
	BGT.S	lbC0157EE
lbC0157E4	MOVE.W	#$FFFF,lbW015DC2
	BRA.S	lbC0157F6

lbC0157EE	MOVE.W	#1,lbW015DC2
lbC0157F6	MOVE.B	(A1)+,D0
	BNE.S	lbC01580A
	CLR.W	lbW015DC2
	MOVE.W	lbW015DC0(pc),lbW015DBE
lbC01580A	MOVE.W	D0,lbW015DC6
	RTS

lbC015812	MOVE.B	$1A(A0),$36(A0)
	BSET	#6,$1B(A0)
	RTS

lbC015820	MOVE.B	(A1)+,D0
	MOVE.B	D0,$37(A0)
	RTS

*******************************************************************************
; New macros taken from "Dawn Patrol"

lbC009AC0	MOVE.B	$BFE001,D0
	ORI.B	#2,D0
	MOVE.B	D0,$BFE001
	RTS

lbC009AD2	MOVE.B	$BFE001,D0
	ANDI.B	#$FD,D0
	MOVE.B	D0,$BFE001
	RTS

*******************************************************************************

lbL015828	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbL015898	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbL015908	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbL015978	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbL0159E8	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbL015AF0	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbL015B68	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbL015BE0	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbL015C58	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbL015CD0	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbL015CE4	dc.l	Error
	dc.l	lbC0156C0
	dc.l	lbC0156D4
	dc.l	Error
	dc.l	Error
	dc.l	Error
	dc.l	Error
	dc.l	lbC0156E8
	dc.l	lbC01570A
	dc.l	lbC015710
	dc.l	Error
	dc.l	lbC01572E
	dc.l	lbC015742
	dc.l	lbC015786
	dc.l	lbC01578E
	dc.l	lbC015756
	dc.l	Error
	dc.l	Error
	dc.l	Error
	dc.l	lbC0157A6
	dc.l	lbC0157B8
	dc.l	lbC0157C6
	dc.l	lbC0157D0
	dc.l	lbC015812
	dc.l	lbC015820
	dc.l	lbC009AD2
	dc.l	lbC009AC0
	dc.l	Error
	dc.l	Error
	dc.l	Error
	dc.l	Error
	dc.l	Error
	dc.l	Error
	dc.l	Error
	dc.l	Error
	dc.l	Error
	dc.l	Error
	dc.l	Error
	dc.l	Error
	dc.l	Error
lbL015D84	dc.l	lbL015AF0
	dc.l	lbL015B68
	dc.l	lbL015BE0
	dc.l	lbL015C58
lbL015D94	dc.l	0
lbL015D98	dc.l	0
	dc.l	0
lbW015DA0	dc.w	0
lbW015DA2	dc.w	0
lbW015DA4	dc.w	0
	dc.w	0
lbB015DA8	dc.b	0
lbB015DA9	dc.b	0
lbB015DAA	dc.b	0
lbB015DAB	dc.b	0
lbB015DAC	dc.b	0
lbB015DAD	dc.b	0
lbB015DAE	dc.b	0
	dc.b	0
	dc.b	$25
	dc.b	$1C
lbW015DB2	dc.w	$3E8
lbW015DB4	dc.w	$2A30
lbB015DB6	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	0
lbW015DBC	dc.w	3
lbW015DBE	dc.w	$3F
lbW015DC0	dc.w	$3F
lbW015DC2	dc.w	0
lbW015DC4	dc.w	0
lbW015DC6	dc.w	1
lbW015DC8	dc.w	1
lbW015DCA	dc.w	0
lbW015DCC	dc.w	$358
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
	dc.w	$1C4
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
	dc.w	$A9
	dc.w	$A0
	dc.w	$97
	dc.w	$8E
	dc.w	$86
	dc.w	$7F
	dc.w	$78
	dc.w	$71
	dc.w	$6B
	dc.w	$65
	dc.w	$5F
	dc.w	$5A
	dc.w	$54
	dc.w	$50
	dc.w	$4B
	dc.w	$47
	dc.w	$43
	dc.w	$3F
	dc.w	$3C
	dc.w	$38
	dc.w	$35
	dc.w	$32
	dc.w	$2F
	dc.w	$2D
	dc.w	$2A
	dc.w	$28
	dc.w	$25
	dc.w	$23
	dc.w	$21
	dc.w	$1F
	dc.w	$1E
	dc.w	$1C
lbL015E44	dc.l	0
lbL015E48	dc.l	0
lbL015E4C	dc.l	0
	dc.l	0
lbL015E54	dc.l	0
lbL015E58	dc.l	$FFFFFFFF
lbW015E5C	dc.w	0

lbL023E4E
	dc.l	Empty

	Section	Empty,BSS_C
Empty
	ds.b	16

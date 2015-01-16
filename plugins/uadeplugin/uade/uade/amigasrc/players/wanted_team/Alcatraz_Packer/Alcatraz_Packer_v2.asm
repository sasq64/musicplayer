	******************************************************
	****   Alcatraz Packer replayer for EaglePlayer   ****
	****        all adaptions by Wanted Team,	  ****
	****      DeliTracker compatible (?) version	  ****
	******************************************************

	incdir	"dh2:include/"
	include 'misc/eagleplayer2.01.i'

	SECTION	Player,CODE

	PLAYERHEADER Tags

	dc.b	'$VER: Alcatraz Packer player module V1.1 (2 Feb 2008)',0
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
	dc.l	EP_SampleInit,SampleInit
	dc.l	EP_Flags,EPB_Volume!EPB_Balance!EPB_ModuleInfo!EPB_Voices!EPB_SampleInfo!EPB_Songend!EPB_Analyzer!EPB_Packable!EPB_Restart
	dc.l	0

PlayerName
	dc.b	'Alcatraz Packer',0
Creator
	dc.b	'(c) 1995 by Andy Sterbenz,',10
	dc.b	'adapted by Wanted Team',0
Prefix
	dc.b	"ALP.",0
	even
ModulePtr
	dc.l	0
EagleBase
	dc.l	0
SampPtr
	dc.l	0
SamplesPtr
	dc.l	0
TwoFiles
	dc.w	0
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

	move.l	InfoBuffer+Samples(PC),D5
	subq.l	#1,D5
	lea	20(A2),A2
	move.l	SampPtr(PC),A1
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
	lea	16(A2),A2
	add.l	D0,A1
	dbf	D5,hop

	moveq	#0,D7
return
	move.l	D7,D0
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
	dc.l	MI_MaxSamples,31
	dc.l	MI_MaxPattern,64
	dc.l	MI_Prefix,Prefix
	dc.l	0

***************************************************************************
******************************* DTP_ExtLoad *******************************
***************************************************************************

ExtLoad
	move.w	TwoFiles(PC),D1
	beq.b	NoExt
	move.l	dtg_PathArrayPtr(A5),A0
	clr.b	(A0)
	move.l	dtg_CopyDir(A5),A0
	jsr	(A0)
	bsr.s	CopyName
	move.l	dtg_LoadFile(A5),A0
	jmp	(A0)
NoExt
	moveq	#0,D0
	rts

CopyName
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

	cmpi.b	#'A',(A3)
	beq.b	A_OK
	cmpi.b	#'a',(A3)
	bne.s	ExtError
A_OK
	cmpi.b	#'L',1(A3)
	beq.b	L_OK
	cmpi.b	#'l',1(A3)
	bne.s	ExtError
L_OK
	cmpi.b	#'P',2(A3)
	beq.b	P_OK
	cmpi.b	#'p',2(A3)
	bne.s	ExtError
P_OK
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

	cmp.l	#$50416E10,(A0)+
	bne.b	fail
	move.l	(A0),D1
	beq.b	fail
	bmi.b	fail
	lea	TwoFiles(PC),A0
	clr.w	(A0)
	cmp.l	dtg_ChkSize(A5),D1
	ble.b	OneFile
	st	(A0)
OneFile
	moveq	#0,D0
fail
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
	move.l	A5,(A6)+			; EagleBase
	lea	InfoBuffer(PC),A4
	move.l	D0,LoadSize(A4)
	move.l	4(A0),D2
	move.l	D2,CalcSize(A4)
	sub.l	A1,A1
	addq.l	#8,A0
	move.w	(A0),D3
	move.w	2(A0),D1
	lsr.w	#1,D1
	move.w	D1,Length+2(A4)
	moveq	#3,D1
Dodaj
	add.w	(A0)+,A1
	dbf	D1,Dodaj
	addq.l	#8,A1
	move.l	A1,SongSize(A4)
	sub.l	A1,D2
	move.l	D2,SamplesSize(A4)
	lsr.w	#4,D3
	move.w	D3,Samples+2(A4)
	cmp.l	A1,D0
	blt.b	Short

	add.l	A1,A0
	move.l	A0,(A6)				; SampPtr
	clr.l	4(A6)
	move.b	TwoFiles(PC),D1
	beq.b	NoTwo

	moveq	#1,D0
	movea.l	dtg_GetListData(A5),A0
	jsr	(A0)

	move.l	A0,(A6)+			; SampPtr
	move.l	A0,(A6)				; sample buffer
	add.l	D0,LoadSize(A4)
NoTwo
	movea.l	dtg_AudioAlloc(A5),A0
	jmp	(A0)

Short
	moveq	#EPR_ModuleTooShort,D0
	rts

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
	move.w	lbL0033B6+6(PC),D0
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
	moveq	#3,D1
	lea	$DFF0A0,A4
SetNew
	move.w	(A1)+,D0
	bsr.b	ChangeVolume
	lea	16(A4),A4
	dbf	D1,SetNew
	rts

ChangeVolume
	and.w	#$7F,D0
	cmpa.l	#$DFF0A0,A4			;Left Volume
	bne.b	NoVoice1
	move.w	D0,OldVoice1
	tst.w	Voice1
	bne.b	Voice1On
	moveq	#0,D0
Voice1On
	mulu.w	LeftVolume(PC),D0
	bra.b	SetIt
NoVoice1
	cmpa.l	#$DFF0B0,A4			;Right Volume
	bne.b	NoVoice2
	move.w	D0,OldVoice2
	tst.w	Voice2
	bne.b	Voice2On
	moveq	#0,D0
Voice2On
	mulu.w	RightVolume(PC),D0
	bra.b	SetIt
NoVoice2
	cmpa.l	#$DFF0C0,A4			;Right Volume
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
	move.w	D0,8(A4)
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

*------------------------------- Set Adr -------------------------------*

SetAdr
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
	move.l	D0,(A0)
	move.l	(A7)+,A0
	rts

*------------------------------- Set Len -------------------------------*

SetLen
	move.l	A0,-(A7)
	lea	StructAdr+UPS_Voice1Len(PC),A0
	cmp.l	#$DFF0A0,A4
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice2Len(PC),A0
	cmp.l	#$DFF0B0,A4
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice3Len(PC),A0
	cmp.l	#$DFF0C0,A4
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
	cmp.l	#$DFF0A0,A4
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice2Per(PC),A0
	cmp.l	#$DFF0B0,A4
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice3Per(PC),A0
	cmp.l	#$DFF0C0,A4
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
	move.l	SamplesPtr(PC),A1
	bra.w	Init

***************************************************************************
***************************** DTP_EndSound ********************************
***************************************************************************

EndSound
	lea	$DFF000,A0
	moveq	#0,D0
	move.w	D0,$A8(A0)
	move.w	D0,$B8(A0)
	move.w	D0,$C8(A0)
	move.w	D0,$D8(A0)
	move.w	#15,$96(A0)
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
	bsr.b	DMAWait
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
*************************** Alcatraz Packer player ************************
***************************************************************************

; Player from "Cedric" (CD32 version) (c) 1995 by Alcatraz/NEO

;	BRA.L	lbC00288A

;lbC0027CC	BRA.L	lbC002906

;lbC0027D0	BRA.L	lbC0029D8

;lbC0027D4	BRA.L	lbC0029EE

;lbC0027D8	BRA.L	lbC002816

;lbC0027DC	BRA.L	lbC002848

;	BRA.L	lbC0027E8

;	BRA.L	lbC0027FE

;lbC0027E8	MOVEM.L	D0/A0/A1,-(SP)
;	LEA	lbL0033A6(PC),A1
;	MOVEQ	#$47,D0
;lbC0027F2	MOVE.W	(A1)+,(A0)+
;	DBRA	D0,lbC0027F2
;	MOVEM.L	(SP)+,D0/A0/A1
;	RTS

;lbC0027FE	BSR.S	lbC0027D4
;	MOVEM.L	D0/A0/A1,-(SP)
;	LEA	lbL0033A6(PC),A1
;	MOVEQ	#$47,D0
;lbC00280A	MOVE.W	(A0)+,(A1)+
;	DBRA	D0,lbC00280A
;	MOVEM.L	(SP)+,D0/A0/A1
;	BRA.S	lbC0027D8

;lbC002816	MOVEM.L	D0/A0,-(SP)
;	MOVE.B	lbB0029D6(PC),D0
;	BNE.S	lbC002842
;	MOVEA.L	lbL0033A6(PC),A0
;	BSR.L	lbC0028EA
;	BNE.S	lbC002842
;	LEA	lbB0029D6(PC),A0
;	ST	(A0)
;	MOVE.W	#$2000,$DFF09C
;	MOVE.W	#$A000,$DFF09A
;	MOVEQ	#0,D0
;lbC002842	MOVEM.L	(SP)+,D0/A0
;	RTS

;lbC002848	MOVE.L	A0,-(SP)
;	LEA	lbW002884(PC),A0
;	TST.W	D0
;	BMI.S	lbC002878
;	ANDI.W	#$FF,D1
;	BEQ.S	lbC002870
;	BSR.L	lbC0027D8
;	CMP.B	#$40,D0
;	BLE.S	lbC002864
;	MOVEQ	#$40,D0
;lbC002864	EXT.W	D0
;	LSL.W	#4,D0
;	CMP.W	-2(A0),D0
;	BPL.S	lbC002870
;	NEG.W	D1
;lbC002870	MOVE.W	D0,(A0)+
;	MOVE.W	D1,(A0)+
;lbC002874	MOVEA.L	(SP)+,A0
;	RTS

;lbC002878	MOVE.W	-2(A0),D2
;	MOVE.W	(A0)+,D0
;	MOVE.W	(A0)+,D1
;	BRA.S	lbC002874

;lbW002882	dc.w	0
;lbW002884	dc.w	0
;lbW002886	dc.w	0
;lbW002888	dc.w	0

;lbC00288A	MOVE.L	A1,-(SP)
;	LEA	lbL003436(PC),A0
;	BSR.L	lbC0027CC
;	BNE.S	lbC0028B4
;	LEA	lbB0029D7(PC),A1
;	TST.B	(A1)
;	BNE.S	lbC0028B0
;	ST	(A1)
;	LEA	lbL0028E6(PC),A1
;	MOVE.L	$6C,(A1)
;	LEA	lbC0028B8(PC),A1
;	MOVE.L	A1,$6C
;lbC0028B0	CLR.W	-2(SP)
;lbC0028B4	MOVEA.L	(SP)+,A1
;	RTS

;lbC0028B8	BTST	#5,$DFF01F
;	BEQ.S	lbC0028E4
;	BSR.L	lbC0027D0
;	BTST	#6,$BFE001
;	BNE.S	lbC0028E4
;	MOVE.L	lbL0028E6(PC),$6C
;	MOVE.L	A0,-(SP)
;	LEA	lbB0029D7(PC),A0
;	CLR.B	(A0)
;	BSR.L	lbC0027D4
;	MOVEA.L	(SP)+,A0
;lbC0028E4	JMP	0
;lbL0028E6	EQU	*-4

;lbC0028EA	MOVE.B	(A0),D0
;	SUBI.B	#$50,D0
;	EORI.B	#$41,D0
;	CMP.B	1(A0),D0
;	BNE.S	lbC002904
;	CMPI.B	#$6E,2(A0)
;	BNE.S	lbC002904
;	MOVEQ	#0,D0
;lbC002904	RTS

Init
;lbC002906	BSR.L	lbC0027D4
;	MOVEM.L	D0-D3/A0-A4/A6,-(SP)
	MOVE.L	A1,D3
;	BSR.S	lbC0028EA
;	BNE.L	lbC0029D0
;	LEA	lbL0033A2(PC),A2
;	MOVEA.L	lbL002554,A4
;	MOVE.L	$78(A4),(A2)
;	LEA	lbW0033A0(PC),A2
;	MOVE.W	$DFF01C,D0
;	ANDI.W	#$2000,D0
;	ORI.W	#$8000,D0
;	MOVE.W	D0,(A2)
	LEA	lbL0033A6(PC),A2
	MOVE.L	A0,(A2)+
	ADDQ.L	#8,A0
	MOVE.W	(A0),D2
	LSR.W	#4,D2
	SUBQ.W	#1,D2
	MOVEQ	#3,D0
	MOVEQ	#0,D1
	MOVEA.L	A0,A1
	BRA.S	lbC002950

lbC00294E	MOVE.L	A1,(A2)+
lbC002950	ADDA.W	(A0)+,A1
	DBRA	D0,lbC00294E
	MOVE.L	#$60000,(A2)+
	MOVE.W	#$8200,(A2)+
	MOVE.W	D1,(A2)
	TST.L	D3
	BEQ.S	lbC002968
	MOVEA.L	D3,A1
lbC002968	MOVE.L	A1,(A0)
	MOVEA.L	A1,A2
	MOVE.W	14(A0),D1
	ADDA.L	D1,A2
	ADDA.L	D1,A2
	MOVE.L	A2,8(A0)
	MOVE.W	4(A0),D1
	ADDA.L	D1,A1
	ADDA.L	D1,A1
	ADDA.W	#$10,A0
	DBRA	D2,lbC002968
;	MOVEQ	#0,D0
;	LEA	$BFD000,A0
;	LEA	$DFF000,A1
;	MOVE.B	#$7F,$D00(A0)
;	MOVE.B	D0,$E00(A0)
;	MOVE.B	#0,$400(A0)
;	MOVE.B	#2,$500(A0)
	LEA	lbL0033BE(PC),A2
	LEA	lbL0033B6(PC),A6
	BSR.L	lbC002A88
;	BSET	#1,$BFE001
;	LEA	lbB0029D6(PC),A0
;	ST	(A0)
;	MOVEQ	#$40,D0
;	MOVEQ	#-1,D1
;	BSR.L	lbC0027DC
;	MOVEQ	#0,D0
;lbC0029D0	MOVEM.L	(SP)+,D0-D3/A0-A4/A6
	RTS

;lbB0029D6	dc.b	0
;lbB0029D7	dc.b	0

;lbC0029D8	MOVE.B	lbB0029D6(PC),-1(SP)
;	BEQ.S	lbC0029EC
;	MOVEM.L	D0-D7/A0-A6,-(SP)
;	BSR.L	lbC002ACE
;	MOVEM.L	(SP)+,D0-D7/A0-A6
;lbC0029EC	RTS

;lbC0029EE	MOVEM.L	D0/A0,-(SP)
;	LEA	lbB0029D6(PC),A0
;	TST.B	(A0)
;	BEQ.S	lbC002A34
;	CLR.B	(A0)
;	MOVEQ	#0,D0
;	LEA	$DFF000,A0
;	MOVE.W	D0,$A8(A0)
;	MOVE.W	D0,$B8(A0)
;	MOVE.W	D0,$C8(A0)
;	MOVE.W	D0,$D8(A0)
;	MOVE.W	#15,$96(A0)
;	MOVE.W	#$2000,$9A(A0)
;	MOVEA.L	lbL002554,A0
;	MOVE.L	lbL0033A2(PC),$78(A0)
;	MOVE.W	lbW0033A0(PC),$DFF09A
;lbC002A34	MOVEM.L	(SP)+,D0/A0
;	RTS

;lbC002A3A	LEA	lbW002882(PC),A0
;	MOVE.W	(A0),D1
;	MOVE.W	2(A0),D2
;	ADD.W	D0,D1
;	TST.W	D0
;	BPL.S	lbC002A50
;	CMP.W	D1,D2
;	BPL.S	lbC002A54
;	BRA.S	lbC002A62

;lbC002A50	CMP.W	D1,D2
;	BGT.S	lbC002A62
;lbC002A54	CLR.W	4(A0)
;	MOVE.W	D2,D1
;	BNE.S	lbC002A62
;	ADDQ.L	#4,SP
;	PEA	lbC0027D4(PC)
;lbC002A62	MOVE.W	D1,(A0)
;	LSR.W	#2,D1
;	BCLR	#8,D1
;	BEQ.S	lbC002A6E
;	NOT.W	D1
;lbC002A6E	MOVE.W	D1,6(A0)
;	RTS

lbC002A74	TST.B	3(A6)
	BEQ.S	lbC002ACC
	CLR.B	3(A6)
	SUBQ.B	#1,2(A6)
	BGT.S	lbC002ACC
	ADDQ.W	#2,6(A6)
lbC002A88	LEA	lbL0033AA(PC),A3
	MOVEA.L	(A3),A0
	MOVE.B	#$40,2(A6)
	MOVE.W	6(A6),D0
	CMP.W	-4(A0),D0
	BNE.S	lbC002AA4
	MOVE.W	-2(A0),6(A6)

	bsr.w	SongEnd

lbC002AA4	MOVEA.L	(A3)+,A0
	ADDA.W	6(A6),A0
	MOVE.W	(A0),D0
	MOVEA.L	(A3)+,A0
	ADDA.W	D0,A0
	MOVEA.L	(A3)+,A1
	MOVEA.L	A1,A3
	MOVEQ	#3,D0
lbC002AB6	ADDA.W	(A0)+,A1
	MOVE.L	A1,$48(A2)
	CLR.B	$4C(A2)
	ADDQ.L	#6,A2
	MOVEA.L	A3,A1
	DBRA	D0,lbC002AB6
	LEA	lbL0033BE(PC),A2
lbC002ACC	RTS

Play_1
lbC002ACE	LEA	$DFF000,A5
	LEA	$D0(A5),A4
	LEA	lbL0033BE(PC),A2
	LEA	lbL0033B6(PC),A6
;	MOVE.W	lbW002886(PC),D0
;	BEQ.S	lbC002AEA
;	BSR.L	lbC002A3A
lbC002AEA	MOVEQ	#0,D6
	BSR.S	lbC002A74
	SUBQ.B	#1,(A6)
	BGT.L	lbC003172
	ST	3(A6)
	MOVEQ	#3,D0
	MOVEQ	#0,D5
lbC002AFC	MOVEA.L	$48(A2),A1
	TST.B	$4C(A2)
	BEQ.S	lbC002B12
	SUBQ.B	#1,$4C(A2)
lbC002B0A	TST.B	$4D(A2)
	BNE.L	lbC003070
lbC002B12	MOVE.B	(A1)+,D1
	BPL.S	lbC002B2E
	NOT.B	D1
	BCLR	#6,D1
	SNE	$4D(A2)
	MOVE.B	D1,$4C(A2)
	MOVE.L	A1,$48(A2)
	MOVE.B	D6,2(A2)
	BRA.S	lbC002B0A

lbC002B2E	MOVE.B	(A1)+,D3
	MOVEA.L	lbL0033A6(PC),A3
	MOVE.B	D3,D7
	LSR.B	#4,D7
	MOVE.B	D1,D2
	ANDI.W	#1,D2
	BEQ.S	lbC002B42
	MOVEQ	#$10,D2
lbC002B42	ADD.B	D2,D7
	BEQ.S	lbC002B4A
	MOVE.B	D7,1(A2)
lbC002B4A	MOVE.B	1(A2),D2
	LSL.W	#4,D2
	ADDA.W	D2,A3
	TST.B	D7
	BEQ.S	lbC002B5C
	MOVE.B	7(A3),5(A2)
lbC002B5C	ANDI.W	#15,D3
	MOVE.B	D3,2(A2)
	BEQ.S	lbC002B6C
	MOVE.B	(A1)+,D4
	MOVE.B	D4,3(A2)
lbC002B6C	ANDI.W	#$FE,D1
	BEQ.L	lbC00305A
	LEA	lbL002BC6(PC),A0
	MOVEQ	#0,D2
	MOVE.B	6(A3),D2
	MULU.W	#$48,D2
	ADD.W	D0,D0
	MOVE.W	D2,-6(A0,D0.W)
	LSR.W	#1,D0
	ADD.W	D1,D2
	MOVE.W	0(A0,D2.W),D7
	SUBQ.W	#3,D3
	BEQ.L	lbC003048
	SUBQ.W	#2,D3
	BEQ.L	lbC003048
	MOVE.B	D1,(A2)
	MOVE.W	D7,$1C(A2)
	MOVE.B	D6,$19(A2)
	MOVE.B	D6,$31(A2)
	BSET	D0,D5

	move.l	D0,-(SP)
	move.l	(A3),D0
	bsr.w	SetAdr
	move.w	4(A3),D0
	bsr.w	SetLen
	move.l	(SP)+,D0

	MOVE.L	(A3)+,(A4)			; address
	MOVE.W	(A3)+,4(A4)			; length
	ADDQ.L	#2,A3
	MOVE.L	(A3)+,$60(A2)
	MOVE.W	(A3)+,$64(A2)
	BRA.L	lbC00305C

	dc.w	0
	dc.w	0
	dc.w	0
lbL002BC6	dc.l	$358
	dc.l	$32802FA
	dc.l	$2D002A6
	dc.l	$280025C
	dc.l	$23A021A
	dc.l	$1FC01E0
	dc.l	$1C501AC
	dc.l	$194017D
	dc.l	$1680153
	dc.l	$140012E
	dc.l	$11D010D
	dc.l	$FE00F0
	dc.l	$E200D6
	dc.l	$CA00BE
	dc.l	$B400AA
	dc.l	$A00097
	dc.l	$8F0087
	dc.l	$7F0078
	dc.l	$710352
	dc.l	$32202F5
	dc.l	$2CB02A2
	dc.l	$27D0259
	dc.l	$2370217
	dc.l	$1F901DD
	dc.l	$1C201A9
	dc.l	$191017B
	dc.l	$1650151
	dc.l	$13E012C
	dc.l	$11C010C
	dc.l	$FD00EF
	dc.l	$E100D5
	dc.l	$C900BD
	dc.l	$B300A9
	dc.l	$9F0096
	dc.l	$8E0086
	dc.l	$7E0077
	dc.l	$71034C
	dc.l	$31C02F0
	dc.l	$2C5029E
	dc.l	$2780255
	dc.l	$2330214
	dc.l	$1F601DA
	dc.l	$1BF01A6
	dc.l	$18E0178
	dc.l	$163014F
	dc.l	$13C012A
	dc.l	$11A010A
	dc.l	$FB00ED
	dc.l	$E000D3
	dc.l	$C700BC
	dc.l	$B100A7
	dc.l	$9E0095
	dc.l	$8D0085
	dc.l	$7D0076
	dc.l	$700346
	dc.l	$31702EA
	dc.l	$2C00299
	dc.l	$2740250
	dc.l	$22F0210
	dc.l	$1F201D6
	dc.l	$1BC01A3
	dc.l	$18B0175
	dc.l	$160014C
	dc.l	$13A0128
	dc.l	$1180108
	dc.l	$F900EB
	dc.l	$DE00D1
	dc.l	$C600BB
	dc.l	$B000A6
	dc.l	$9D0094
	dc.l	$8C0084
	dc.l	$7D0076
	dc.l	$6F0340
	dc.l	$31102E5
	dc.l	$2BB0294
	dc.l	$26F024C
	dc.l	$22B020C
	dc.l	$1EF01D3
	dc.l	$1B901A0
	dc.l	$1880172
	dc.l	$15E014A
	dc.l	$1380126
	dc.l	$1160106
	dc.l	$F700E9
	dc.l	$DC00D0
	dc.l	$C400B9
	dc.l	$AF00A5
	dc.l	$9C0093
	dc.l	$8B0083
	dc.l	$7C0075
	dc.l	$6E033A
	dc.l	$30B02E0
	dc.l	$2B6028F
	dc.l	$26B0248
	dc.l	$2270208
	dc.l	$1EB01CF
	dc.l	$1B5019D
	dc.l	$1860170
	dc.l	$15B0148
	dc.l	$1350124
	dc.l	$1140104
	dc.l	$F500E8
	dc.l	$DB00CE
	dc.l	$C300B8
	dc.l	$AE00A4
	dc.l	$9B0092
	dc.l	$8A0082
	dc.l	$7B0074
	dc.l	$6D0334
	dc.l	$30602DA
	dc.l	$2B1028B
	dc.l	$2660244
	dc.l	$2230204
	dc.l	$1E701CC
	dc.l	$1B2019A
	dc.l	$183016D
	dc.l	$1590145
	dc.l	$1330122
	dc.l	$1120102
	dc.l	$F400E6
	dc.l	$D900CD
	dc.l	$C100B7
	dc.l	$AC00A3
	dc.l	$9A0091
	dc.l	$890081
	dc.l	$7A0073
	dc.l	$6D032E
	dc.l	$30002D5
	dc.l	$2AC0286
	dc.l	$262023F
	dc.l	$21F0201
	dc.l	$1E401C9
	dc.l	$1AF0197
	dc.l	$180016B
	dc.l	$1560143
	dc.l	$1310120
	dc.l	$1100100
	dc.l	$F200E4
	dc.l	$D800CC
	dc.l	$C000B5
	dc.l	$AB00A1
	dc.l	$980090
	dc.l	$880080
	dc.l	$790072
	dc.l	$6C038B
	dc.l	$3580328
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
	dc.l	$780384
	dc.l	$3520322
	dc.l	$2F502CB
	dc.l	$2A3027C
	dc.l	$2590237
	dc.l	$21701F9
	dc.l	$1DD01C2
	dc.l	$1A90191
	dc.l	$17B0165
	dc.l	$151013E
	dc.l	$12C011C
	dc.l	$10C00FD
	dc.l	$EE00E1
	dc.l	$D400C8
	dc.l	$BD00B3
	dc.l	$A9009F
	dc.l	$96008E
	dc.l	$86007E
	dc.l	$77037E
	dc.l	$34C031C
	dc.l	$2F002C5
	dc.l	$29E0278
	dc.l	$2550233
	dc.l	$21401F6
	dc.l	$1DA01BF
	dc.l	$1A6018E
	dc.l	$1780163
	dc.l	$14F013C
	dc.l	$12A011A
	dc.l	$10A00FB
	dc.l	$ED00DF
	dc.l	$D300C7
	dc.l	$BC00B1
	dc.l	$A7009E
	dc.l	$95008D
	dc.l	$85007D
	dc.l	$760377
	dc.l	$3460317
	dc.l	$2EA02C0
	dc.l	$2990274
	dc.l	$250022F
	dc.l	$21001F2
	dc.l	$1D601BC
	dc.l	$1A3018B
	dc.l	$1750160
	dc.l	$14C013A
	dc.l	$1280118
	dc.l	$10800F9
	dc.l	$EB00DE
	dc.l	$D100C6
	dc.l	$BB00B0
	dc.l	$A6009D
	dc.l	$94008C
	dc.l	$84007D
	dc.l	$760371
	dc.l	$3400311
	dc.l	$2E502BB
	dc.l	$294026F
	dc.l	$24C022B
	dc.l	$20C01EE
	dc.l	$1D301B9
	dc.l	$1A00188
	dc.l	$172015E
	dc.l	$14A0138
	dc.l	$1260116
	dc.l	$10600F7
	dc.l	$E900DC
	dc.l	$D000C4
	dc.l	$B900AF
	dc.l	$A5009C
	dc.l	$93008B
	dc.l	$83007B
	dc.l	$75036B
	dc.l	$33A030B
	dc.l	$2E002B6
	dc.l	$28F026B
	dc.l	$2480227
	dc.l	$20801EB
	dc.l	$1CF01B5
	dc.l	$19D0186
	dc.l	$170015B
	dc.l	$1480135
	dc.l	$1240114
	dc.l	$10400F5
	dc.l	$E800DB
	dc.l	$CE00C3
	dc.l	$B800AE
	dc.l	$A4009B
	dc.l	$92008A
	dc.l	$82007B
	dc.l	$740364
	dc.l	$3340306
	dc.l	$2DA02B1
	dc.l	$28B0266
	dc.l	$2440223
	dc.l	$20401E7
	dc.l	$1CC01B2
	dc.l	$19A0183
	dc.l	$16D0159
	dc.l	$1450133
	dc.l	$1220112
	dc.l	$10200F4
	dc.l	$E600D9
	dc.l	$CD00C1
	dc.l	$B700AC
	dc.l	$A3009A
	dc.l	$910089
	dc.l	$81007A
	dc.l	$73035E
	dc.l	$32E0300
	dc.l	$2D502AC
	dc.l	$2860262
	dc.l	$23F021F
	dc.l	$20101E4
	dc.l	$1C901AF
	dc.l	$1970180
	dc.l	$16B0156
	dc.l	$1430131
	dc.l	$1200110
	dc.l	$10000F2
	dc.l	$E400D8
	dc.l	$CB00C0
	dc.l	$B500AB
	dc.l	$A10098
	dc.l	$900088
	dc.l	$800079
	dc.w	$72

lbC003048	CMP.W	$1C(A2),D7
	BNE.S	lbC003050
	MOVE.W	D6,D7
lbC003050	SMI	$34(A2)
	MOVE.W	D7,$1A(A2)
	BRA.S	lbC003066

lbC00305A	SUBQ.W	#5,D3
lbC00305C	SUBQ.W	#4,D3
	BMI.S	lbC003066
	LSL.W	#2,D3
	JSR	lbC0030D4(PC,D3.W)
lbC003066	TST.B	$4C(A2)
	BNE.S	lbC003070
	MOVE.L	A1,$48(A2)
lbC003070	MOVE.W	$1C(A2),6(A4)		; period
	MOVE.W	4(A2),D1
;	MOVE.W	lbW002888(PC),D2
;	BMI.S	lbC003084
;	MULU.W	D2,D1
;	LSR.W	#8,D1
;lbC003084	MOVE.W	D1,8(A4)		; volume

	move.l	D0,-(SP)
	move.w	D1,D0
	bsr.w	ChangeVolume
	bsr.w	SetVol
	move.l	(SP)+,D0

	ADDQ.L	#6,A2
	SUBA.W	#$10,A4
	DBRA	D0,lbC002AFC
	MOVE.B	1(A6),(A6)
	MOVE.B	D5,5(A6)
	BEQ.S	lbC0030D2
	MOVE.W	D5,$96(A5)			; DMA off
;	LEA	lbC00331C(PC),A0
;	MOVE.L	A1,-(SP)
;	MOVEA.L	lbL002554,A1
;	MOVE.L	A0,$78(A1)
;	MOVEA.L	(SP)+,A1
;	MOVE.W	#$2000,$DFF09C
;	MOVE.W	#$A000,$DFF09A
;	MOVE.B	#$81,$BFDD00
;	MOVE.B	#$19,$BFDE00
lbC0030D2	RTS

lbC0030D4	BRA.L	lbC0030F0

	BRA.L	lbC003114

	BRA.L	lbC003100

	BRA.L	lbC0030FA

	BRA.L	lbC003106

	BRA.L	lbC00314E

	BRA.L	lbC00310E

lbC0030F0	LEA	lbW0030F8(PC),A3
	OR.B	D4,(A3)
	RTS

lbW0030F8	dc.w	0

lbC0030FA	MOVE.B	D4,5(A2)
	RTS

lbC003100	EXT.W	D4
	MOVE.W	D4,6(A6)
lbC003106	BSET	#7,2(A6)
	RTS

lbC00310E	MOVE.B	D4,1(A6)
	RTS

lbC003114	TST.B	D4
	BEQ.S	lbC00311C
	MOVE.B	D4,$35(A2)
lbC00311C	SUBA.W	#14,A3
	MOVEA.L	(A3)+,A0
	MOVE.W	(A3)+,D1
	MOVEQ	#0,D4
	MOVE.B	$35(A2),D4
	LSL.W	#7,D4
	SUB.W	D4,D1
	BGT.S	lbC003132
	MOVEQ	#1,D1
lbC003132	MOVE.W	D1,4(A4)		; length
	ADD.W	D4,D4
	ADDA.W	D4,A0
	MOVE.L	A0,(A4)				; address

	move.l	D0,-(SP)
	move.l	A0,D0
	bsr.w	SetAdr
	move.w	D1,D0
	bsr.w	SetLen
	move.l	(SP)+,D0

	RTS

lbC00313E	ANDI.B	#$FD,$BFE001
	OR.B	D2,$BFE001
	RTS

lbC00314E	MOVE.W	D4,D2
	ANDI.W	#15,D2
	ANDI.W	#$F0,D4
	LSR.W	#2,D4
	JMP	lbC00315E(PC,D4.W)

lbC00315E	BRA.L	lbC00313E

	NEG.W	D2
	NOP
	BRA.L	lbC0031CC

	NEG.W	D2
	NOP
	BRA.L	lbC0031F6

lbC003172	MOVEQ	#3,D0
lbC003174	MOVEQ	#0,D1
	MOVE.B	2(A2),D1
	BEQ.S	lbC00318A
	CMP.W	#8,D1
	BGT.S	lbC00318A
	SUBQ.W	#1,D1
	LSL.W	#2,D1
	JSR	lbC0031A8(PC,D1.W)
lbC00318A	MOVE.W	4(A2),D3
;	MOVE.W	lbW002888(PC),D2
;	BMI.S	lbC003198
;	MULU.W	D2,D3
;	LSR.W	#8,D3
;lbC003198	MOVE.W	D3,8(A4)		; volume

	move.l	D0,-(SP)
	move.w	D3,D0
	bsr.w	ChangeVolume
	bsr.w	SetVol
	move.l	(SP)+,D0

	ADDQ.L	#6,A2
	SUBA.W	#$10,A4
	DBRA	D0,lbC003174
	RTS

lbC0031A8	BRA.L	lbC003218

	BRA.L	lbC0031C8

	BRA.L	lbC003254

	BRA.L	lbC0032B0

	BRA.L	lbC0031F0

	BRA.L	lbC0032A6

	BRA.L	lbC003290

	BRA.L	lbC0031F2

lbC0031C8	MOVE.B	3(A2),D2
lbC0031CC	EXT.W	D2
	MOVE.W	$1C(A2),D3
	SUB.W	D2,D3
	CMP.W	#$71,D3
	BPL.S	lbC0031DC
	MOVEQ	#$71,D3
lbC0031DC	CMP.W	#$358,D3
	BMI.S	lbC0031E6
	MOVE.W	#$358,D3
lbC0031E6	MOVE.W	D3,$1C(A2)
	MOVE.W	D3,6(A4)			; period

	move.l	D0,-(SP)
	move.w	D3,D0
	bsr.w	SetPer
	move.l	(SP)+,D0

	RTS

lbC0031F0	BSR.S	lbC00325E
lbC0031F2	MOVE.B	3(A2),D2
lbC0031F6	MOVE.W	4(A2),D3
	ADD.B	D2,D3
	BMI.S	lbC003208
	CMP.W	#$40,D3
	BMI.S	lbC00320A
	MOVEQ	#$40,D3
	BRA.S	lbC00320A

lbC003208	MOVE.W	D6,D3
lbC00320A	MOVE.W	D3,4(A2)
	RTS

lbC003210	MOVE.W	$1C(A2),6(A4)		; period

;	move.l	D0,-(SP)
;	move.w	$1C(A2),D0
;	bsr.w	SetPer
;	move.l	(SP)+,D0

	RTS

lbC003218	MOVEQ	#0,D2
	MOVE.B	(A6),D2
	SUB.B	1(A6),D2
lbC003220	ADDQ.B	#3,D2
	BMI.S	lbC003220
	BEQ.S	lbC003210
	MOVE.B	3(A2),D3
	SUBQ.B	#1,D2
	BEQ.S	lbC003230
	LSR.W	#4,D3
lbC003230	ANDI.W	#15,D3
	ADD.W	D3,D3
	ADD.B	(A2),D3
	CMP.W	#$48,D3
	BLS.S	lbC003240
	MOVEQ	#$48,D3
lbC003240	LEA	lbL002BC6(PC),A3
	ADD.W	D0,D0
	ADD.W	-6(A3,D0.W),D3
	LSR.W	#1,D0
	MOVE.W	0(A3,D3.W),6(A4)		; period

	move.l	D0,-(SP)
	move.w	(A3,D3.W),D0
	bsr.w	SetPer
	move.l	(SP)+,D0

	RTS

lbC003254	MOVE.B	3(A2),D2
	BEQ.S	lbC00325E
	MOVE.B	D2,$33(A2)
lbC00325E	MOVE.W	$1A(A2),D2
	BEQ.S	lbC003286
	MOVE.W	$32(A2),D3
	MOVE.W	$1C(A2),D1
	TST.B	$34(A2)
	BNE.S	lbC003288
	ADD.W	D3,D1
	CMP.W	D1,D2
	BGT.S	lbC00327E
lbC003278	MOVE.W	D2,D1
	MOVE.W	D6,$1A(A2)
lbC00327E	MOVE.W	D1,6(A4)		; period

	move.l	D0,-(SP)
	move.w	D1,D0
	bsr.w	SetPer
	move.l	(SP)+,D0

	MOVE.W	D1,$1C(A2)
lbC003286	RTS

lbC003288	SUB.W	D3,D1
	CMP.W	D1,D2
	BLT.S	lbC00327E
	BRA.S	lbC003278

lbC003290	MOVE.B	3(A2),D3
	BEQ.S	lbC00329A
	MOVE.B	D3,$30(A2)
lbC00329A	ADDA.W	#$18,A2
	BSR.S	lbC0032C2
	SUBA.W	#$18,A2
	RTS

lbC0032A6	BSR.S	lbC0032C2
	MOVE.W	D3,6(A4)			; period

	move.l	D0,-(SP)
	move.w	D3,D0
	bsr.w	SetPer
	move.l	(SP)+,D0

	BRA.L	lbC0031F2

lbC0032B0	BSR.S	lbC0032B8
	MOVE.W	D3,6(A4)			; period

	move.l	D0,-(SP)
	move.w	D3,D0
	bsr.w	SetPer
	move.l	(SP)+,D0

	RTS

lbC0032B8	MOVE.B	3(A2),D3
	BEQ.S	lbC0032C2
	MOVE.B	D3,$18(A2)
lbC0032C2	MOVE.B	$19(A2),D3
	LSR.B	#2,D3
	ANDI.W	#$1F,D3
	MOVEQ	#0,D2
	MOVE.B	lbW0032FC(PC,D3.W),D2
	MOVE.B	$18(A2),D3
	ANDI.W	#15,D3
	MULU.W	D3,D2
	LSR.W	#7,D2
	MOVE.W	$1C(A2),D3
	TST.B	$19(A2)
	BPL.S	lbC0032EA
	NEG.W	D2
lbC0032EA	ADD.W	D2,D3
	MOVE.B	$18(A2),D2
	LSR.B	#2,D2
	ANDI.W	#$3C,D2
	ADD.B	D2,$19(A2)
	RTS

lbW0032FC	dc.w	$18
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

Play_2
;lbC00331C	TST.B	$BFDD00
;	MOVE.B	#$19,$BFDE00
;	MOVE.W	#$2000,$DFF09C
;	MOVEM.L	A0/A1,-(SP)
;	MOVEA.L	lbL002554,A0
;	LEA	lbC003352(PC),A1
;	MOVE.L	A1,$78(A0)
;	MOVEM.L	(SP)+,A0/A1
	MOVE.W	lbW0033BA(PC),$DFF096			; DMA on
;	RTE

	bsr.w	DMAWait

;lbC003352	TST.B	$BFDD00
;	MOVEM.L	A0/A1,-(SP)
	LEA	lbL00341E(PC),A0
	LEA	$DFF000,A1
	MOVE.L	(A0)+,$D0(A1)
	MOVE.W	(A0)+,$D4(A1)
	MOVE.L	(A0)+,$C0(A1)
	MOVE.W	(A0)+,$C4(A1)
	MOVE.L	(A0)+,$B0(A1)
	MOVE.W	(A0)+,$B4(A1)
	MOVE.L	(A0)+,$A0(A1)
	MOVE.W	(A0)+,$A4(A1)
;	MOVE.B	#$7F,$BFDD00
;	MOVE.W	#$2000,$9C(A1)
;	MOVE.W	#$2000,$9A(A1)
;	MOVEM.L	(SP)+,A0/A1
;	RTE

	rts

;lbW0033A0	dc.w	0
;lbL0033A2	dc.l	0
lbL0033A6	dc.l	0
lbL0033AA	dc.l	0
	dc.l	0
	dc.l	0
lbL0033B6	dc.l	0
lbW0033BA	dc.w	0
	dc.w	0
lbL0033BE	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbL00341E	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
;lbL003436	dc.l	0

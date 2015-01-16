	*****************************************************
	****     SoundPlayer replayer for EaglePlayer	 ****
	****        all adaptions by Wanted Team,	 ****
	****      DeliTracker compatible (?) version	 ****
	*****************************************************

	incdir	"dh2:include/"
	include 'misc/eagleplayer2.01.i'

	SECTION Player,CODE

	PLAYERHEADER Tags

	dc.b	'$VER: SoundPlayer V4.05 replayer module V1.0 (2 Mar 2003)',0
	even
Tags
	dc.l	DTP_PlayerVersion,1
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
	dc.l	EP_Get_ModuleInfo,Get_ModuleInfo
	dc.l	DTP_ExtLoad,ExtLoad
	dc.l	DTP_Volume,SetVolume
	dc.l	DTP_Balance,SetBalance
	dc.l	EP_Voices,SetVoices
	dc.l	EP_StructInit,StructInit
	dc.l	EP_GetPositionNr,GetPosition
	dc.l	EP_SampleInit,SampleInit
	dc.l	EP_Flags,EPB_Volume!EPB_Balance!EPB_ModuleInfo!EPB_LoadFast!EPB_Voices!EPB_SampleInfo!EPB_Songend!EPB_Analyzer!EPB_Packable!EPB_Restart
	dc.l	TAG_DONE
PlayerName
	dc.b	'SoundPlayer',0
Creator
	dc.b	"(c) 1991 by Scott Johnston,",10
	dc.b	'adapted by Wanted Team',0
Prefix
	dc.b	'SJS.',0
	even
ModulePtr
	dc.l	0
SamplesPtr
	dc.l	0
Info
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
	move.l	SamplesPtr(PC),D0
	beq.b	return
	move.l	D0,A2

	move.l	Info(PC),D5
	subq.l	#1,D5
hop
	jsr	ENPP_AllocSampleStruct(A5)
	move.l	D0,(A3)
	beq.b	return
	move.l	D0,A3

	cmp.l	#'FORM',(A2)
	bne.b	NoSamp1
	cmp.l	#'NAME',40(A2)
	bne.b	NoName
	lea	48(A2),A1
	move.w	#20,EPS_MaxNameLen(A3)
	move.l	A1,EPS_SampleName(A3)		; sample name
NoName
	move.l	A2,EPS_Adr(A3)			; sample address
	addq.l	#4,A2
	moveq	#8,D1
	add.l	(A2),D1
	add.l	(A2),A2
	move.l	D1,EPS_Length(A3)		; sample length
	move.l	#64,EPS_Volume(A3)
	move.w	#USITY_RAW,EPS_Type(A3)
	move.w	#USIB_Playable!USIB_Saveable!USIB_8BIT,EPS_Flags(A3)
NoSamp1
	addq.l	#4,A2
	dbf	D5,hop

	moveq	#0,D7
return
	move.l	D7,D0
	rts

***************************************************************************
********************************* EP_GetPosNr *****************************
***************************************************************************

GetPosition
	move.l	ModulePtr(PC),A1
	lea	-9(A1),A1
	move.l	lbW064178+$CC+10(PC),A0
	moveq	#0,D0
	move.l	(A0),D1
	sub.l	A1,D1
	divu.w	#600,D1
	move.w	D1,D0
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

	lea	StructAdr(PC),A4
	lea	OldVoice1(PC),A2
	moveq	#3,D1
	lea	$DFF0A0,A3
SetNew
	move.w	(A2)+,D0
	bsr.b	ChangeVolume
	lea	16(A3),A3
	dbf	D1,SetNew
	rts

ChangeVolume
	move.l	A4,-(SP)
	lea	StructAdr(PC),A4
	and.w	#$7F,D0
	cmpa.l	#$DFF0A0,A3			;Left Volume
	bne.b	NoVoice1
	move.w	D0,OldVoice1
	tst.w	Voice1
	bne.b	Voice1On
	moveq	#0,D0
Voice1On
	mulu.w	LeftVolume(PC),D0
	lsr.w	#6,D0
	move.w	D0,8(A3)
	move.w	D0,UPS_Voice1Vol(A4)
	bra.b	SetIt
NoVoice1
	cmpa.l	#$DFF0B0,A3			;Right Volume
	bne.b	NoVoice2
	move.w	D0,OldVoice2
	tst.w	Voice2
	bne.b	Voice2On
	moveq	#0,D0
Voice2On
	mulu.w	RightVolume(PC),D0
	lsr.w	#6,D0
	move.w	D0,8(A3)
	move.w	D0,UPS_Voice2Vol(A4)
	bra.b	SetIt
NoVoice2
	cmpa.l	#$DFF0C0,A3			;Right Volume
	bne.b	NoVoice3
	move.w	D0,OldVoice3
	tst.w	Voice3
	bne.b	Voice3On
	moveq	#0,D0
Voice3On
	mulu.w	RightVolume(PC),D0
	lsr.w	#6,D0
	move.w	D0,8(A3)
	move.w	D0,UPS_Voice3Vol(A4)
	bra.b	SetIt
NoVoice3
	cmpa.l	#$DFF0D0,A3			;Left Volume
	bne.b	SetIt
	move.w	D0,OldVoice4
	tst.w	Voice4
	bne.b	Voice4On
	moveq	#0,D0
Voice4On
	mulu.w	LeftVolume(PC),D0
	lsr.w	#6,D0
	move.w	D0,8(A3)
	move.w	D0,UPS_Voice4Vol(A4)
SetIt
	move.l	(SP)+,A4
	rts

SetAll
	move.l	A0,-(SP)
	lea	StructAdr+UPS_Voice1Adr(PC),A0
	cmp.l	#$DFF0A0,A1
	beq.b	.SetVoice
	lea	StructAdr+UPS_Voice2Adr(PC),A0
	cmp.l	#$DFF0B0,A1
	beq.b	.SetVoice
	lea	StructAdr+UPS_Voice3Adr(PC),A0
	cmp.l	#$DFF0C0,A1
	beq.b	.SetVoice
	lea	StructAdr+UPS_Voice4Adr(PC),A0
.SetVoice
	move.l	(A2),(A0)
	move.w	4(A2),UPS_Voice1Len(A0)
	move.w	6(A2),UPS_Voice1Per(A0)
	move.l	(SP)+,A0
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
******************************* DTP_Check2 ********************************
***************************************************************************

Check2
	movea.l	dtg_ChkData(A5),A0

	tst.b	1(A0)
	beq.b	error
	tst.b	2(A0)
	beq.b	error
	tst.w	6(A0)
	bne.b	error
	tst.w	12(A0)
	bne.b	error
	tst.b	3(A0)
	bne.b	error
	tst.b	4(A0)
	bne.b	error
	tst.b	9(A0)
	bne.b	error
	tst.b	10(A0)
	bne.b	error
	cmp.b	#$A0,1(A0)
	bhi.b	error
	cmp.b	#$0A,1(A0)
	bls.b	error
	move.b	5(A0),D1
	beq.b	error
	cmp.b	#7,2(A0)
	beq.b	Checkv3
	cmp.b	#15,2(A0)
	bne.b	error
	cmp.b	14(A0),D1
	bne.b	error
Checkv3
	cmp.b	11(A0),D1
	bne.b	error
	cmp.b	8(A0),D1
	bne.b	error
	moveq	#0,D0
	rts
error
	moveq	#-1,D0
	rts

***************************************************************************
******************************* DTP_ExtLoad *******************************
***************************************************************************

ExtLoad
	move.l	dtg_PathArrayPtr(A5),A0
	clr.b	(A0)
	move.l	dtg_CopyDir(A5),A0
	jsr	(A0)
	bsr.s	CopyName
	move.l	dtg_LoadFile(A5),A0
	jmp	(A0)

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

	cmpi.b	#'S',(A3)
	beq.b	S_OK
	cmpi.b	#'s',(A3)
	bne.s	ExtError
S_OK
	cmpi.b	#'J',1(A3)
	beq.b	J_OK
	cmpi.b	#'j',1(A3)
	bne.s	ExtError
J_OK
	cmpi.b	#'S',2(A3)
	beq.b	S2_OK
	cmpi.b	#'s',2(A3)
	bne.s	ExtError
S2_OK
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
***************************** EP_Get_ModuleInfo ***************************
***************************************************************************

Get_ModuleInfo
	lea	InfoBuffer(PC),A0
	rts

SamplesSize	=	4
LoadSize	=	12
Samples		=	20
Length		=	28
Voices		=	36

InfoBuffer
	dc.l	MI_SamplesSize,0	;4
	dc.l	MI_LoadSize,0		;12
	dc.l	MI_Samples,0		;20
	dc.l	MI_Length,0		;28
	dc.l	MI_Voices,0		;36
	dc.l	MI_MaxVoices,4
	dc.l	MI_MaxSamples,38
	dc.l	MI_Prefix,Prefix
	dc.l	0

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
	divu.w	#600,D0
	tst.w	D0
	bne.b	NoShort
	moveq	#1,D0
NoShort
	move.w	D0,Length+2(A4)
	moveq	#4,D0
	cmp.b	#15,2(A0)
	beq.b	VoiceOK
	subq.l	#1,D0
VoiceOK
	move.l	D0,Voices(A4)

	moveq	#1,D0
	movea.l	dtg_GetListData(A5),A0
	jsr	(A0)

	move.l	A0,(A6)+			; SamplesPtr
	add.l	D0,LoadSize(A4)

	lea	lbL0643F4(PC),A1
	lea	532+60(A1),A2
Clear
	clr.w	(A1)+
	cmp.l	A1,A2
	bne.b	Clear

	moveq	#0,D1
	move.l	A0,A1
	add.l	D0,A0
	moveq	#1,D0
	bsr.w	InstallSamples
	move.l	D1,Samples(A4)
	sub.l	A1,A2
	move.l	A2,SamplesSize(A4)

	move.l	D2,(A6)+			; Info 
	move.l	A5,(A6)				; EagleBase

	move.l	dtg_AudioAlloc(A5),A0
	jmp	(A0)

***************************************************************************
***************************** DTP_EndPlayer *******************************
***************************************************************************

EndPlayer
	move.l	dtg_AudioFree(A5),A0
	jmp	(A0)

***************************************************************************
***************************** DTP_Intterrupt ******************************
***************************************************************************

Interrupt
	movem.l	D1-A6,-(SP)

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

	movem.l	(SP)+,D1-A6
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
	lea	Empty,A0
	move.l	ModulePtr(PC),A2
	move.w	(A2),D0
	rol.w	#8,D0
	move.w	D0,dtg_Timer(A5)
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
************************ SoundPlayer V4.05 replayer ***********************
***************************************************************************

; Player from game "Lemmings" (CDTV version) by DMA Design/Psygnosis

;lbC063782	BRA.L	lbC0637FA

;	BRA.L	lbC06392C

;	BRA.L	lbC0639BE

;	BRA.L	lbC0639D6

;	BRA.L	lbC063A2A

;	BRA.L	lbC063916

;	BRA.L	lbC063A40

;	BRA.L	lbC063A96

;	BRA.L	lbC063B10

;lbC0637A6	BRA.L	lbC063B6C

;	BRA.L	lbC063C0E

;	BRA.L	lbC063C50

;	BRA.L	lbC063C76

;	BRA.L	lbC063C92

;	BRA.L	lbC063CAE

;	BRA.L	lbC063CCA

;	BRA.L	lbC063CE6

;lbC0637C6	BRA.L	lbC064154

;	dc.b	'SoundPlayer V4.05',0
;CScottJohnsto.MSG	dc.b	'(C) Scott Johnston  12/3/1991',0

Init
lbC0637FA	MOVEM.L	D0-D4/A0-A6,-(SP)
	MOVEA.L	#$DFF000,A6
	LEA	lbW064178(PC),A5
;	MOVE.L	D0,-(SP)			; D0 timer type
;	BSR.L	lbC06383A			; copyright protection :-)
	BSR.L	lbC0638DA			; A0 empty sample ptr
	MOVEQ	#0,D0
;	LEA	lbW064D88(PC),A2		; A2 song ptr
	BSR.L	lbC0639D6
	MOVEQ	#15,D0
	BSR.L	lbC063B6C
;	BSR.L	lbC063CE6			; play
;	MOVE.L	(SP)+,D0
;	BSR.L	lbC06385A			; init timer
	MOVEM.L	(SP)+,D0-D4/A0-A6
lbC063830	RTS

;lbC063832	MOVE.W	#$F00,$180(A6)
;	BRA.S	lbC063832

;lbC06383A	LEA	CScottJohnsto.MSG(PC),A1
;	MOVEQ	#0,D0
;	ADD.L	(A1)+,D0
;	ADD.L	(A1)+,D0
;	ADD.L	(A1)+,D0
;	ADD.L	(A1),D0
;	CMP.L	#$58355677,D0
;	BEQ.S	lbC063858
;	LEA	lbC063830(PC),A0
;	MOVE.W	#$4E71,(A0)
;lbC063858	RTS

;lbC06385A	TST.B	D0
;	BNE.S	lbC063898
;	MOVE.L	#$BFE401,$112(A5)
;	MOVE.L	#$BFE501,$116(A5)
;	MOVE.B	#$81,$BFED01
;	MOVE.B	#1,$BFDD00
;	MOVE.B	#$FF,$BFE401
;	MOVE.B	#$FF,$BFE501
;	MOVE.B	#1,$BFEE01
;	RTS

;lbC063898	CMPI.B	#1,D0
;	BNE.S	lbC0638D8
;	MOVE.L	#$BFD400,$112(A5)
;	MOVE.L	#$BFD500,$116(A5)
;	MOVE.B	#$81,$BFDD00
;	MOVE.B	#1,$BFED01
;	MOVE.B	#$FF,$BFD400
;	MOVE.B	#$FF,$BFD500
;	MOVE.B	#1,$BFDE00
;	RTS

;lbC0638D8	RTS

lbC0638DA
;	MOVE.L	A0,$10E(A5)			; bug
	LEA	$8C(A5),A3
	LEA	$12E(A5),A4
lbC0638E6	CLR.B	(A3)+
	CMPA.L	A3,A4
	BNE.S	lbC0638E6
	LEA	$8C(A5),A1
	MOVE.W	#$3F,8(A1)
	LEA	$AC(A5),A1
	MOVE.W	#$3F,8(A1)
	LEA	$CC(A5),A1
	MOVE.W	#$3F,8(A1)
	LEA	$EC(A5),A1
	MOVE.W	#$3F,8(A1)

	move.l	A0,$10E(A5)

	RTS

;lbC063916	MOVE.L	D0,-(SP)
;	MOVEQ	#1,D0
;	BSR.L	lbC0639BE
;	MOVEQ	#1,D0
;	BSR.L	lbC0639D6
;	BSR.L	lbC063A40
;	MOVE.L	(SP)+,D0
;	RTS

lbC06392C	MOVEM.L	D0-D7/A0-A6,-(SP)
	LEA	lbW064178(PC),A5
	LEA	lbL0643F4(PC),A4
	SUBQ.W	#1,D0
	LSL.W	#1,D0
	MOVE.W	$40(A5,D0.W),D0
	LEA	0(A4,D0.W),A3
	MOVE.L	#'VHDR',D0
	LEA	(A1),A0
	LEA	$400(A1),A2
	BSR.S	lbC06398A
	LEA	4(A0),A0
	MOVE.L	(A0)+,D0
	MOVE.L	D0,D1
	LSR.L	#1,D0
	MOVE.W	D0,4(A3)
	MOVE.L	(A0)+,D0
	LSR.L	#1,D0
	MOVE.W	D0,10(A3)
	MOVE.L	#'BODY',D0
	LEA	(A1),A0
	LEA	$800(A1),A2
	BSR.S	lbC06398A
	LEA	4(A0),A0
	MOVE.L	A0,0(A3)
	ADDA.W	D1,A0
	MOVE.L	A0,6(A3)
	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTS

lbC06398A	MOVEM.L	D1/A1,-(SP)
lbC06398E	MOVE.L	D0,D1
	ROL.L	#8,D1
lbC063992	CMPA.L	A0,A2
	BEQ.S	lbC0639B6
	CMP.B	(A0)+,D1
	BNE.S	lbC063992
	MOVEA.L	A0,A1
	ROL.L	#8,D1
	CMP.B	(A1)+,D1
	BNE.S	lbC06398E
	ROL.L	#8,D1
	CMP.B	(A1)+,D1
	BNE.S	lbC06398E
	ROL.L	#8,D1
	CMP.B	(A1)+,D1
	BNE.S	lbC06398E
	MOVEA.L	A1,A0
	MOVEM.L	(SP)+,D1/A1
	RTS

lbC0639B6	SUBA.L	A0,A0
	MOVEM.L	(SP)+,D1/A1
	RTS

InstallSamples
lbC0639BE	MOVEM.L	D0/A0/A1,-(SP)
lbC0639C2
;	MOVEA.L	(A0),A1
;	TST.L	(A0)+
;	BEQ.S	lbC0639D0

	cmp.l	#'FORM',(A1)
	bne.b	NoSamp

	BSR.L	lbC06392C

	addq.l	#1,D1
	addq.l	#4,A1
	add.l	(A1),A1
	lea	4(A1),A2
NoSamp
	addq.l	#4,A1
	cmp.l	A1,A0
	ble.b	lbC0639D0
	cmp.w	#38,D0
	beq.b	lbC0639D0

	ADDQ.W	#1,D0
	BRA.S	lbC0639C2

lbC0639D0
	move.l	D0,D2

	MOVEM.L	(SP)+,D0/A0/A1
	RTS

lbC0639D6	MOVEM.L	D0/A2-A5,-(SP)
	LEA	lbW064178(PC),A5
	LSL.W	#1,D0
	MOVE.W	0(A5,D0.W),D0
	LEA	lbL0643F4(PC),A4
	LEA	$214(A4),A4
	ADDA.W	D0,A4
	MOVE.B	0(A2),$39(A4)
	MOVE.B	1(A2),$38(A4)
	MOVE.B	2(A2),$3A(A4)			; voices number
	LEA	-9(A2),A2
	LEA	0(A4),A3
	MOVE.L	A2,8(A3)
	LEA	14(A4),A3
	MOVE.L	A2,8(A3)
	LEA	$1C(A4),A3
	MOVE.L	A2,8(A3)
	LEA	$2A(A4),A3
	MOVE.L	A2,8(A3)
	MOVEM.L	(SP)+,D0/A2-A5
	RTS

;lbC063A2A	MOVEM.L	D0/A0-A2,-(SP)
;lbC063A2E	MOVEA.L	(A0),A2
;	TST.L	(A0)+
;	BEQ.S	lbC063A3A
;	BSR.S	lbC0639D6
;	ADDQ.W	#1,D0
;	BRA.S	lbC063A2E

;lbC063A3A	MOVEM.L	(SP)+,D0/A0-A2
;	RTS

lbC063A40	BSR.L	lbC063A4A
	BSR.L	lbC063A96
	RTS

lbC063A4A	MOVEM.L	D0/A2-A5,-(SP)
	LEA	lbW064178(PC),A5
	LSL.W	#1,D0
	MOVE.W	0(A5,D0.W),D0
	LEA	lbL0643F4(PC),A4
	LEA	$214(A4),A4
	ADDA.W	D0,A4
	LEA	0(A4),A3
	BSR.S	lbC063A80
	LEA	14(A4),A3
	BSR.S	lbC063A80
	LEA	$1C(A4),A3
	BSR.S	lbC063A80
	LEA	$2A(A4),A3
	BSR.S	lbC063A80
	MOVEM.L	(SP)+,D0/A2-A5
	RTS

lbC063A80	MOVE.L	8(A3),0(A3)
	MOVE.B	#$FF,12(A3)
	CLR.B	13(A3)
;	CLR.B	$1B(A3)				; bug !!!
	RTS

lbC063A96	MOVEM.L	D0/A2-A5,-(SP)
	LEA	lbW064178(PC),A5
	LSL.W	#1,D0
	MOVE.W	0(A5,D0.W),D0
	LEA	lbL0643F4(PC),A4
	LEA	$214(A4),A4
	ADDA.W	D0,A4
	MOVE.B	$3A(A4),D0
	LEA	0(A4),A3
	LEA	$8C(A5),A2
	BSR.S	lbC063AF8			; set data v1
	LEA	14(A4),A3
	LEA	$AC(A5),A2
	BSR.S	lbC063AF8			; set data v2
	LEA	$1C(A4),A3
	LEA	$CC(A5),A2
	BSR.S	lbC063AF8			; set data v3
	LEA	$2A(A4),A3
	LEA	$EC(A5),A2
	BSR.S	lbC063AF8			; set data v4
;	CMPI.B	#$FF,$39(A4)
;	BEQ.S	lbC063AF2
;	MOVEA.L	$112(A5),A2
;	MOVE.B	$39(A4),(A2)
;	MOVEA.L	$116(A5),A2
;	MOVE.B	$38(A4),(A2)
lbC063AF2	MOVEM.L	(SP)+,D0/A2-A5
	RTS

lbC063AF8	BTST	#0,D0
	BEQ.S	lbC063B0C
	MOVE.L	A3,10(A2)
	MOVE.W	#0,8(A2)
	SF	$1F(A2)
lbC063B0C	ROR.B	#1,D0
	RTS

;lbC063B10	MOVEM.L	D0-D2/A1-A6,-(SP)
;	MOVEA.L	#$DFF000,A6
;	LEA	lbW064178(PC),A5
;	MOVE.L	D0,D1
;	LEA	$8C(A5),A1
;	BSR.S	lbC063B42
;	LEA	$AC(A5),A1
;	BSR.S	lbC063B42
;	LEA	$CC(A5),A1
;	BSR.S	lbC063B42
;	LEA	$EC(A5),A1
;	BSR.S	lbC063B42
;	BSR.L	lbC063EA8
;	MOVEM.L	(SP)+,D0-D2/A1-A6
;	RTS

;lbC063B42	BTST	#0,D1
;	BEQ.S	lbC063B68
;	ROR.L	#8,D0
;	MOVE.B	D0,$18(A1)
;	ROR.L	#8,D0
;	MOVE.B	D0,$19(A1)
;	ROR.L	#8,D0
;	TST.B	$1F(A1)
;	BNE.S	lbC063B60
;	MOVE.B	D0,9(A1)
;lbC063B60	ROR.L	#8,D0
;	MOVE.B	#0,$1A(A1)
;lbC063B68	ROR.B	#1,D1
;	RTS

lbC063B6C	MOVEM.L	D0/A3-A6,-(SP)
	MOVEA.L	#$DFF000,A6
	LEA	lbW064178(PC),A5
	MOVEA.L	$10E(A5),A3
	LEA	lbL0643F4(PC),A4
	LEA	$214(A4),A4
	LEA	$3A(A4),A4
	BCLR	#0,(A4)
	BTST	#0,D0
	BEQ.S	lbC063BA8
	BSET	#0,(A4)
	MOVE.W	#1,$96(A6)
	MOVE.L	A3,$A0(A6)
	MOVE.W	#1,$A4(A6)
lbC063BA8	BCLR	#1,(A4)
	BTST	#1,D0
	BEQ.S	lbC063BC6
	BSET	#1,(A4)
	MOVE.W	#2,$96(A6)
	MOVE.L	A3,$B0(A6)
	MOVE.W	#1,$B4(A6)
lbC063BC6	BCLR	#2,(A4)
	BTST	#2,D0
	BEQ.S	lbC063BE4
	BSET	#2,(A4)
	MOVE.W	#4,$96(A6)
	MOVE.L	A3,$C0(A6)
	MOVE.W	#1,$C4(A6)
lbC063BE4	BCLR	#3,(A4)
	BTST	#3,D0
	BEQ.S	lbC063C02
	BSET	#3,(A4)
	MOVE.W	#8,$96(A6)
	MOVE.L	A3,$D0(A6)
	MOVE.W	#1,$D4(A6)
lbC063C02	MOVEQ	#0,D0
	BSR.L	lbC063A40
	MOVEM.L	(SP)+,D0/A3-A6
	RTS

;lbC063C0E	MOVEM.L	D1/A4/A5,-(SP)
;	LEA	lbW064178(PC),A5
;	LEA	$8C(A5),A4
;	BSR.S	lbC063C34
;	LEA	$AC(A5),A4
;	BSR.S	lbC063C34
;	LEA	$CC(A5),A4
;	BSR.S	lbC063C34
;	LEA	$EC(A5),A4
;	BSR.S	lbC063C34
;	MOVEM.L	(SP)+,D1/A4/A5
;	RTS

;lbC063C34	BTST	#0,D1
;	BEQ.S	lbC063C4C
;	MOVE.B	#1,$1C(A4)
;	MOVE.B	D0,$1D(A4)
;	MOVE.B	D0,$1E(A4)
;	ST	$1F(A4)
;lbC063C4C	ROR.B	#1,D1
;	RTS

;lbC063C50	MOVEM.L	A3-A5,-(SP)
;	LEA	lbW064178(PC),A5
;	LEA	lbL0643F4(PC),A4
;	SUBQ.W	#1,D0
;	LSL.W	#1,D0
;	MOVE.W	$40(A5,D0.W),D0
;	LEA	0(A4,D0.W),A3
;	MOVE.B	12(A3),D0
;	SF	12(A3)
;	MOVEM.L	(SP)+,A3-A5
;	RTS

;lbC063C76	MOVEM.L	A4/A5,-(SP)
;	LEA	lbW064178(PC),A5
;	LEA	$11A(A5),A4
;	SUBQ.B	#1,D0
;	ANDI.W	#$FF,D0
;	MOVE.B	0(A4,D0.W),D0
;	MOVEM.L	(SP)+,A4/A5
;	RTS

;lbC063C92	MOVEM.L	D0/A4/A5,-(SP)
;	LEA	lbW064178(PC),A5
;	LEA	$11A(A5),A4
;	SUBQ.B	#1,D0
;	ANDI.W	#$FF,D0
;	ST	0(A4,D0.W)
;	MOVEM.L	(SP)+,D0/A4/A5
;	RTS

;lbC063CAE	MOVEM.L	D0/A4/A5,-(SP)
;	LEA	lbW064178(PC),A5
;	LEA	$11A(A5),A4
;	SUBQ.B	#1,D0
;	ANDI.W	#$FF,D0
;	SF	0(A4,D0.W)
;	MOVEM.L	(SP)+,D0/A4/A5
;	RTS

;lbC063CCA	MOVEM.L	D0/A4/A5,-(SP)
;	LEA	lbW064178(PC),A5
;	LEA	$11A(A5),A4
;	MOVE.W	#4,D0
;lbC063CDA	CLR.L	(A4)+
;	DBRA	D0,lbC063CDA
;	MOVEM.L	(SP)+,D0/A4/A5
;	RTS

Play
lbC063CE6	MOVEM.L	D0-D7/A0-A6,-(SP)
	MOVEA.L	#$DFF000,A6
	LEA	lbW064178(PC),A5
	BSR.L	lbC063E0A
	BSR.L	lbC063DAA
	BSR.S	lbC063D18
	TST.W	$10C(A5)
	BNE.S	lbC063D12
	BSR.L	lbC063D70
	BSR.S	lbC063D2C
	BSR.L	lbC063EA8
	BSR.L	lbC063F1E
lbC063D12	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTS

lbC063D18	TST.W	$10C(A5)
	BNE.S	lbC063D26
	MOVE.W	#5,$10C(A5)
	RTS

lbC063D26	SUBQ.W	#1,$10C(A5)
	RTS

lbC063D2C	LEA	$8C(A5),A2
	MOVEQ	#0,D0
	BSR.S	lbC063D4E
	LEA	$AC(A5),A2
	MOVEQ	#3,D0
	BSR.S	lbC063D4E
	LEA	$CC(A5),A2
	MOVEQ	#6,D0
	BSR.S	lbC063D4E
	LEA	$EC(A5),A2
	MOVEQ	#9,D0
	BSR.S	lbC063D4E
	RTS

lbC063D4E	MOVEA.L	10(A2),A0
	TST.B	13(A0)
	BNE.S	lbC063D6E
	MOVEA.L	0(A0),A1
	MOVE.B	0(A1,D0.W),$18(A2)
	MOVE.B	1(A1,D0.W),$19(A2)
	MOVE.B	2(A1,D0.W),$1A(A2)
lbC063D6E	RTS

lbC063D70	LEA	$8C(A5),A2
	BSR.S	lbC063D8A
	LEA	$AC(A5),A2
	BSR.S	lbC063D8A
	LEA	$CC(A5),A2
	BSR.S	lbC063D8A
	LEA	$EC(A5),A2
	BSR.S	lbC063D8A
	RTS

lbC063D8A	MOVEA.L	10(A2),A2
	TST.B	13(A2)
	BEQ.S	lbC063DA0
	SUBQ.B	#1,13(A2)
	TST.B	13(A2)
	BEQ.S	lbC063DA0
	RTS

lbC063DA0	ADDI.L	#12,0(A2)
	RTS

lbC063DAA	MOVE.W	#$8001,D0
	LEA	$8C(A5),A2
	LEA	$A0(A6),A1
	BSR.S	lbC063DD8
	LEA	$AC(A5),A2
	LEA	$B0(A6),A1
	BSR.S	lbC063DD8
	LEA	$CC(A5),A2
	LEA	$C0(A6),A1
	BSR.S	lbC063DD8
	LEA	$EC(A5),A2
	LEA	$D0(A6),A1
	BSR.S	lbC063DD8
	RTS

lbC063DD8	TST.W	4(A2)
	BEQ.S	lbC063E06
	MOVE.L	0(A2),0(A1)
	MOVE.W	4(A2),4(A1)
;	MOVE.W	8(A2),8(A1)
	MOVE.W	6(A2),6(A1)

	bsr.w	SetAll
	movem.l	D0/A3,-(SP)
	move.l	A1,A3
	move.w	8(A2),D0
	bsr.w	ChangeVolume
	movem.l	(SP)+,D0/A3

	MOVE.W	D0,$96(A6)
	CLR.W	4(A2)
	MOVEA.L	14(A2),A2
	ST	12(A2)
lbC063E06	ROL.B	#1,D0
	RTS

lbC063E0A	MOVEA.L	$10E(A5),A2
	LEA	$8C(A5),A3
	LEA	$A0(A6),A4
	BSR.S	lbC063E38
	LEA	$AC(A5),A3
	LEA	$B0(A6),A4
	BSR.S	lbC063E38
	LEA	$CC(A5),A3
	LEA	$C0(A6),A4
	BSR.S	lbC063E38
	LEA	$EC(A5),A3
	LEA	$D0(A6),A4
	BSR.S	lbC063E38
	RTS

lbC063E38	BSR.S	lbC063E82
	TST.B	$1D(A3)
	BEQ.S	lbC063E80
	SUBQ.B	#1,$1E(A3)
	TST.B	$1E(A3)
	BNE.S	lbC063E80
	MOVE.B	$1D(A3),$1E(A3)
	TST.B	$1C(A3)
	BEQ.S	lbC063E68
	TST.W	8(A3)
	BEQ.S	lbC063E7C
	SUBQ.W	#1,8(A3)
;	MOVE.W	8(A3),8(A4)

	move.l	D0,-(SP)
	move.w	8(A3),D0
	bsr.w	ChangeVolume
	move.l	(SP)+,D0

	BRA.S	lbC063E80

lbC063E68	CMPI.W	#$3F,8(A3)
	BEQ.S	lbC063E7C
	ADDQ.W	#1,8(A3)
;	MOVE.W	8(A3),8(A4)

	move.l	D0,-(SP)
	move.w	8(A3),D0
	bsr.w	ChangeVolume
	move.l	(SP)+,D0

	BRA.S	lbC063E80

lbC063E7C	CLR.B	$1D(A3)
lbC063E80	RTS

lbC063E82	TST.B	$1B(A3)
	BNE.S	lbC063EA6
	TST.W	$16(A3)
	BEQ.S	lbC063E9C
	MOVE.L	$12(A3),0(A4)
	MOVE.W	$16(A3),4(A4)
	RTS

lbC063E9C	MOVE.L	A2,0(A4)
	MOVE.W	#1,4(A4)
lbC063EA6	RTS

lbC063EA8	LEA	lbW0642A6(PC),A1
	LEA	lbL0643F4(PC),A4
	MOVE.W	#1,D0
	LEA	$8C(A5),A2
	BSR.S	lbC063ECE
	LEA	$AC(A5),A2
	BSR.S	lbC063ECE
	LEA	$CC(A5),A2
	BSR.S	lbC063ECE
	LEA	$EC(A5),A2
	BSR.S	lbC063ECE
	RTS

lbC063ECE	TST.B	$18(A2)
	BEQ.S	lbC063F1A
	CLR.L	D2
	CLR.L	D1
	MOVE.W	D0,$96(A6)
	MOVE.B	$18(A2),D1
	MOVE.B	$19(A2),D2
	SUBQ.W	#1,D1
	LSL.W	#1,D1
	MOVE.W	0(A1,D1.W),6(A2)
	SUBQ.W	#1,D2
	LSL.W	#1,D2
	MOVE.W	$40(A5,D2.W),D2
	LEA	0(A4,D2.W),A3
	MOVE.L	A3,14(A2)
	MOVE.L	0(A3),0(A2)
	MOVE.W	4(A3),4(A2)
	MOVE.L	6(A3),$12(A2)
	MOVE.W	10(A3),$16(A2)
	CLR.B	$18(A2)
lbC063F1A	ROL.B	#1,D0
	RTS

lbC063F1E	LEA	lbW0642F4(PC),A4
	LEA	$8C(A5),A1
	LEA	$A0(A6),A3
	BSR.S	lbC063F4C
	LEA	$AC(A5),A1
	LEA	$B0(A6),A3
	BSR.S	lbC063F4C
	LEA	$CC(A5),A1
	LEA	$C0(A6),A3
	BSR.S	lbC063F4C
	LEA	$EC(A5),A1
	LEA	$D0(A6),A3
	BSR.S	lbC063F4C
	RTS

lbC063F4C	MOVEA.L	10(A1),A2
	CLR.W	D1
	CLR.W	D0
	MOVE.B	$1A(A1),D0
	CLR.B	$1A(A1)
	MOVE.B	0(A4,D0.W),D1
	JMP	lbC063F64(PC,D1.W)

lbC063F64	RTS

	NOP
	BRA.L	lbC063FD8

	BRA.L	lbC063FE2

	BRA.L	lbC063FEC

	BRA.L	lbC06410A

	BRA.L	lbC064144

	BRA.L	lbC063FFE

	BRA.L	lbC064012

	BRA.L	lbC064026

	BRA.L	lbC064038

	BRA.L	lbC06403E

	BRA.L	lbC064044

	BRA.L	lbC064054

	BRA.L	lbC06406C

	BRA.L	lbC064086

	BRA.L	lbC064090

	BRA.L	lbC064098

	BRA.L	lbC0640A0

	BRA.L	lbC0640A8

	BRA.L	lbC0640B0

	BRA.L	lbC0640B8

	BRA.L	lbC0640C0

	BRA.L	lbC0640C8

	BRA.L	lbC0640DA

	BRA.L	lbC0640E2

	BRA.L	lbC0640EA

	BRA.L	lbC0640F2

	BRA.L	lbC0640FA

	BRA.L	lbC064102

lbC063FD8	BSET	#1,$BFE001
	RTS

lbC063FE2	BCLR	#1,$BFE001
	RTS

lbC063FEC	TST.B	$1F(A1)
	BNE.S	lbC063FFC
	SUBQ.B	#3,D0
	MOVE.W	D0,8(A1)
;	MOVE.W	D0,8(A3)

	bsr.w	ChangeVolume

lbC063FFC	RTS

lbC063FFE	SUBI.B	#$A6,D0
	MOVE.B	#0,$1C(A1)
	MOVE.B	D0,$1D(A1)
	MOVE.B	D0,$1E(A1)
	RTS

lbC064012	SUBI.B	#$B0,D0
	MOVE.B	#1,$1C(A1)
	MOVE.B	D0,$1D(A1)
	MOVE.B	D0,$1E(A1)
	RTS

lbC064026	SUBI.B	#$BB,D0
	ANDI.W	#$FF,D0
	LEA	$11A(A5),A1
	ST	0(A1,D0.W)
	RTS

lbC064038	ST	$1B(A1)
	RTS

lbC06403E	SF	$1B(A1)
	RTS

lbC064044	LEA	$11A(A5),A1
	MOVE.W	#4,D0
lbC06404C	CLR.L	(A1)+
	DBRA	D0,lbC06404C
	RTS

lbC064054	CMPI.B	#$FF,12(A2)
	BNE.S	lbC06406A
	MOVE.L	0(A2),4(A2)
	SUBI.B	#$D1,D0
	MOVE.B	D0,12(A2)
lbC06406A	RTS

lbC06406C	TST.B	12(A2)
	BNE.S	lbC06407A
	MOVE.B	#$FF,12(A2)
	RTS

lbC06407A	SUBQ.B	#1,12(A2)
	MOVE.L	4(A2),0(A2)
	RTS

lbC064086	SUBI.L	#12,0(A2)
	RTS

lbC064090	MOVE.L	8(A2),0(A2)		; SongEnd (restart song)

	bsr.w	SongEnd

	RTS

lbC064098	MOVE.W	#$8001,$9E(A6)
	RTS

lbC0640A0	MOVE.W	#$8002,$9E(A6)
	RTS

lbC0640A8	MOVE.W	#$8004,$9E(A6)
	RTS

lbC0640B0	MOVE.W	#$8010,$9E(A6)
	RTS

lbC0640B8	MOVE.W	#$8020,$9E(A6)
	RTS

lbC0640C0	MOVE.W	#$8040,$9E(A6)
	RTS

lbC0640C8	SUBI.B	#$E5,D0
	ANDI.W	#$FF,D0
	LEA	$11A(A5),A1
	SF	0(A1,D0.W)
	RTS

lbC0640DA	MOVE.W	#1,$9E(A6)
	RTS

lbC0640E2	MOVE.W	#2,$9E(A6)
	RTS

lbC0640EA	MOVE.W	#4,$9E(A6)
	RTS

lbC0640F2	MOVE.W	#$10,$9E(A6)
	RTS

lbC0640FA	MOVE.W	#$20,$9E(A6)
	RTS

lbC064102	MOVE.W	#$40,$9E(A6)
	RTS

lbC06410A	LEA	$8C(A5),A2
	CMPA.L	A2,A1
	BNE.S	lbC064118
	MOVE.W	#1,$96(A6)
lbC064118	LEA	$AC(A5),A2
	CMPA.L	A2,A1
	BNE.S	lbC064126
	MOVE.W	#2,$96(A6)
lbC064126	LEA	$CC(A5),A2
	CMPA.L	A2,A1
	BNE.S	lbC064134
	MOVE.W	#4,$96(A6)
lbC064134	LEA	$EC(A5),A2
	CMPA.L	A2,A1
	BNE.S	lbC064142
	MOVE.W	#8,$96(A6)
lbC064142	RTS

lbC064144	SUBI.B	#$56,D0
	TST.B	13(A2)
	BNE.S	lbC064152
	MOVE.B	D0,13(A2)
lbC064152	RTS

;lbC064154	MOVEM.L	D0/A6,-(SP)
;	MOVEA.L	#$DFF000,A6
;	MOVEQ	#15,D0
;	BSR.L	lbC063B6C
;	MOVE.B	#1,$BFED01
;	MOVE.W	#15,$96(A6)
;	MOVEM.L	(SP)+,D0/A6
;	RTS

lbW064178	dc.w	0
	dc.w	$3C
	dc.w	$78
	dc.w	$B4
	dc.w	$F0
	dc.w	$12C
	dc.w	$168
	dc.w	$1A4
	dc.w	$1E0
	dc.w	$21C
	dc.w	$258
	dc.w	$294
	dc.w	$2D0
	dc.w	$30C
	dc.w	$348
	dc.w	$384
	dc.w	$3C0
	dc.w	$3FC
	dc.w	$438
	dc.w	$474
	dc.w	$4B0
	dc.w	$4EC
	dc.w	$528
	dc.w	$564
	dc.w	$5A0
	dc.w	$5DC
	dc.w	$618
	dc.w	$654
	dc.w	$690
	dc.w	$6CC
	dc.w	$708
	dc.w	$744
	dc.w	0
	dc.w	14
	dc.w	$1C
	dc.w	$2A
	dc.w	$38
	dc.w	$46
	dc.w	$54
	dc.w	$62
	dc.w	$70
	dc.w	$7E
	dc.w	$8C
	dc.w	$9A
	dc.w	$A8
	dc.w	$B6
	dc.w	$C4
	dc.w	$D2
	dc.w	$E0
	dc.w	$EE
	dc.w	$FC
	dc.w	$10A
	dc.w	$118
	dc.w	$126
	dc.w	$134
	dc.w	$142
	dc.w	$150
	dc.w	$15E
	dc.w	$16C
	dc.w	$17A
	dc.w	$188
	dc.w	$196
	dc.w	$1A4
	dc.w	$1B2
	dc.w	$1C0
	dc.w	$1CE
	dc.w	$1DC
	dc.w	$1EA
	dc.w	$1F8
	dc.w	$206
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
lbW0642A6	dc.w	$434
	dc.w	$3F8
	dc.w	$3C0
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
	dc.w	$71
lbW0642F4	dc.w	4
	dc.w	$80C
	dc.w	$C0C
	dc.w	$C0C
	dc.w	$C0C
	dc.w	$C0C
	dc.w	$C0C
	dc.w	$C0C
	dc.w	$C0C
	dc.w	$C0C
	dc.w	$C0C
	dc.w	$C0C
	dc.w	$C0C
	dc.w	$C0C
	dc.w	$C0C
	dc.w	$C0C
	dc.w	$C0C
	dc.w	$C0C
	dc.w	$C0C
	dc.w	$C0C
	dc.w	$C0C
	dc.w	$C0C
	dc.w	$C0C
	dc.w	$C0C
	dc.w	$C0C
	dc.w	$C0C
	dc.w	$C0C
	dc.w	$C0C
	dc.w	$C0C
	dc.w	$C0C
	dc.w	$C0C
	dc.w	$C0C
	dc.w	$C0C
	dc.w	$C10
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	$14
	dc.w	$1414
	dc.w	$1414
	dc.w	$1414
	dc.w	$1414
	dc.w	$1414
	dc.w	$1414
	dc.w	$1414
	dc.w	$1414
	dc.w	$1414
	dc.w	$1414
	dc.w	$1414
	dc.w	$1414
	dc.w	$1414
	dc.w	$1414
	dc.w	$1414
	dc.w	$1414
	dc.w	$1414
	dc.w	$1414
	dc.w	$1414
	dc.w	$1414
	dc.w	$1414
	dc.w	$1414
	dc.w	$1414
	dc.w	$1414
	dc.w	$1400
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	$18
	dc.w	$1818
	dc.w	$1818
	dc.w	$1818
	dc.w	$1818
	dc.w	$181C
	dc.w	$1C1C
	dc.w	$1C1C
	dc.w	$1C1C
	dc.w	$1C1C
	dc.w	$1C20
	dc.w	$2020
	dc.w	$2020
	dc.w	$2020
	dc.w	$2020
	dc.w	$2020
	dc.w	$2020
	dc.w	$2020
	dc.w	$2020
	dc.w	$2020
	dc.w	$2024
	dc.w	$282C
	dc.w	$3030
	dc.w	$3030
	dc.w	$3030
	dc.w	$3030
	dc.w	$3030
	dc.w	$3438
	dc.w	$3C40
	dc.w	$4448
	dc.w	$4C50
	dc.w	$5458
	dc.w	$5858
	dc.w	$5858
	dc.w	$5858
	dc.w	$5858
	dc.w	$5858
	dc.w	$5858
	dc.w	$5858
	dc.w	$5858
	dc.w	$5858
	dc.w	$585C
	dc.w	$6064
	dc.w	$686C
	dc.w	0
lbL0643F4	
	ds.b	532			; 38 samples * 14 sampleinfos
	ds.b	60			; was 60 * 32

;lbW064D88	dc.w	$FFFF
;	dc.w	$F00
;	dc.w	0
;	dc.w	0
;	dc.w	0
;	dc.w	0
;	dc.w	0
;	dc.w	0
;	dc.w	$DE
;	dc.w	0
;	dc.w	$DE00
;	dc.w	$DE
;	dc.w	0
;	dc.w	$DE00
;	dc.w	0
;	dc.w	0
;	dc.w	$3F2

	Section	Sample,BSS_C
Empty
	ds.b	4

	*****************************************************
	****  NovoTrade Packer replayer for EaglePlayer	 ****
	****        all adaptions by Wanted Team,	 ****
	****      DeliTracker compatible (?) version	 ****
	*****************************************************

	incdir	"dh2:include/"
	include 'misc/eagleplayer2.01.i'
	include 'hardware/intbits.i'
	include 'exec/exec_lib.i'

	SECTION	Player,CODE

	PLAYERHEADER Tags

	dc.b	'$VER: NovoTrade Packer player module V1.0 (15 Oct 2001)',0
	even
Tags
	dc.l	DTP_PlayerVersion,1
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
	dc.l	DTP_NextPatt,NextPattern
	dc.l	DTP_PrevPatt,BackPattern
	dc.l	EP_SampleInit,SampleInit
	dc.l	EP_Flags,EPB_Save!EPB_Volume!EPB_Balance!EPB_ModuleInfo!EPB_Voices!EPB_SampleInfo!EPB_Songend!EPB_Analyzer!EPB_Packable!EPB_Restart!EPB_PrevPatt!EPB_NextPatt
	dc.l	0

PlayerName
	dc.b	'NovoTrade Packer',0
Creator
	dc.b	'(c) 1990 by NovoTrade,',10
	dc.b	'adapted by Wanted Team',0
Prefix
	dc.b	'NTP.',0
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
	beq.b	return
	subq.l	#1,D5
	lea	32(A2),A2
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
	move.w	lbW01534C(PC),D0
	addq.w	#1,D0
	cmp.w	InfoBuffer+Length+2(PC),D0
	beq.b	MaxPos
	move.w	D0,lbW01534C
	clr.w	lbW01534A
MaxPos
	rts

***************************************************************************
******************************* DTP_BackPatt ******************************
***************************************************************************

BackPattern
	move.w	lbW01534C(PC),D0
	beq.b	MinPos
	subq.w	#1,D0
	move.w	D0,lbW01534C
	clr.w	lbW01534A
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
SongName	=	52
Patterns	=	60

InfoBuffer
	dc.l	MI_LoadSize,0		;4
	dc.l	MI_Samples,0		;12
	dc.l	MI_Length,0		;20
	dc.l	MI_SamplesSize,0	;28
	dc.l	MI_Songsize,0		;36
	dc.l	MI_Calcsize,0		;44
	dc.l	MI_SongName,0		;52
	dc.l	MI_Pattern,0		;60
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

	cmp.l	#'MODU',(A0)+
	bne.b	Fault
	move.w	16(A0),D1
	bmi.b	Fault
	beq.b	Fault
	btst	#0,D1
	bne.b	Fault
	move.w	24(A0),D2
	bmi.b	Fault
	beq.b	Fault
	btst	#0,D2
	bne.b	Fault
	lea	(A0,D1.W),A0
	cmp.l	#'BODY',(A0)+
	bne.b	Fault
	lea	(A0,D2.W),A0
	cmp.l	#'SAMP',(A0)
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

	moveq	#0,D2
	move.w	22(A0),D2
	move.l	D2,Samples(A4)

	moveq	#0,D0
	moveq	#12,D1
	move.w	20(A0),D0
	add.l	D0,D1
	move.w	28(A0),D0
	add.l	D0,D1
	move.l	D1,SongSize(A4)

	lea	(A0,D1.L),A1
	move.l	A1,(A6)+			; SamplesPtr
	subq.l	#1,D2
	lea	32(A0),A1
	moveq	#0,D3
NextInfo
	move.w	(A1),D0
	add.l	D0,D3
	addq.l	#8,A1
	dbf	D2,NextInfo
	add.l	D3,D3
	move.l	D3,SamplesSize(A4)
	add.l	D1,D3
	move.l	D3,CalcSize(A4)
	cmp.l	LoadSize(A4),D3
	ble.b	SizeOK
	moveq	#EPR_ModuleTooShort,D0
	rts
SizeOK

	move.w	24(A0),Length+2(A4)
	move.w	26(A0),Patterns+2(A4)

	addq.l	#4,A0
	move.l	A0,SongName(A4)

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
	move.w	lbW01534C(PC),D0
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

	lea	DT(PC),A4
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
	dc.l	lbC00F13E
IntName
	dc.b	'NovoTrade Packer Audio Interrupt',0,0
	even

DMAWait
	movem.l	D0/D1,-(SP)
	moveq	#8,D0
.dma1	move.b	$DFF006,D1
.dma2	cmp.b	$DFF006,D1
	beq.b	.dma2
	dbeq	D0,.dma1
	movem.l	(SP)+,D0/D1
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
	lea	DT(PC),A4
	move.l	ModulePtr(PC),A2
	bsr.w	Init
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

***************************************************************************
************************** NovoTrade Packer player ************************
***************************************************************************

; Player from "Castlevania" (c) 1990 by NovoTrade/Konami

;InitAudio
;	MOVE.L	D0,lbL015374-DT(A4)
;	MOVE.L	$70,lbL01536C-DT(A4)
;	MOVE.L	#lbC00F13E,$70
;	MOVE.W	#1,D0
;	MOVE.W	#1,lbW015372-DT(A4)
;lbC00ED32	MOVEM.L	(SP)+,D1-D7/A0-A6
;	UNLK	A5
;	RTS

Init
;	LINK.W	A5,#0
	MOVEM.L	D1-D7/A0-A6,-(SP)
;	CLR.W	lbW015358-DT(A4)
;	CLR.W	lbW01535E-DT(A4)
;	MOVEA.L	8(A5),A0
;	MOVEA.L	(A0),A2
;	MOVE.W	#$FFFF,D0
;	CMPI.L	#$534F4E47,(A2)
;	BEQ.L	lbC00ED86
;	CMPI.L	#$4D4F4455,(A2)
;	BNE.L	lbC00EE3A
	ADDQ.W	#4,A2
	MOVEA.L	A2,A1
	ADDQ.W	#4,A1
	ADDA.W	$10(A2),A1
	ADDA.W	$18(A2),A1
;	CMPI.L	#$53414D50,(A1)
;	BNE.L	lbC00EE3A
	ADDQ.W	#4,A1
;	BRA.L	lbC00ED8C

;lbC00ED86	ADDQ.W	#4,A2
;	MOVEA.L	4(A0),A1
lbC00ED8C	MOVE.L	A2,lbL015336-DT(A4)
	MOVEA.L	A2,A3
	ADDA.W	#$1A,A3
	MOVE.L	A3,lbL01533A-DT(A4)
	LEA	lbL01526C-DT(A4),A0
	MOVE.W	$12(A2),D0
	SUBQ.W	#1,D0
lbC00EDA4	MOVE.B	(A3),D1
	EXT.W	D1
	LSL.W	#2,D1
	MOVE.L	A1,0(A0,D1.W)
	CLR.L	(A1)
	CLR.L	D1
	MOVE.W	2(A3),D1
	LSL.L	#1,D1
	ADDA.L	D1,A1
	ADDQ.W	#8,A3
	DBRA	D0,lbC00EDA4
	CLR.W	lbW01534C-DT(A4)
	CLR.W	lbW015356-DT(A4)
	CLR.W	lbW015358-DT(A4)
	CLR.W	lbW01535A-DT(A4)
	CLR.W	lbW01534A-DT(A4)
	MOVE.W	#6,lbW015352-DT(A4)
	MOVE.W	#6,lbW015350-DT(A4)
	MOVE.W	$14(A2),lbW015354-DT(A4)
	MOVEA.L	A2,A3
	ADDA.W	$10(A2),A3
	ADDQ.W	#4,A3
	MOVE.L	A3,lbL01533E-DT(A4)
	SUBQ.W	#4,A3
	MOVE.W	$16(A2),D0
	LSL.W	#1,D0
	SUBA.W	D0,A3
	MOVE.L	A3,lbL015346-DT(A4)
	MOVE.W	$14(A2),D0
	LSL.W	#1,D0
	SUBA.W	D0,A3
	MOVE.L	A3,lbL015342-DT(A4)
	LEA	lbL0151FC-DT(A4),A6
	ADDA.W	#$54,A6
	MOVEQ	#3,D0
lbC00EE16	CLR.W	D1
	BSET	D0,D1
	MOVE.W	D1,$14(A6)
	MOVE.B	#0,$16(A6)
	MOVE.B	#0,$17(A6)
	SUBA.W	#$1C,A6
	DBRA	D0,lbC00EE16
	MOVE.W	#1,lbW01535E-DT(A4)
	CLR.W	D0
lbC00EE3A	MOVEM.L	(SP)+,D1-D7/A0-A6
;	UNLK	A5
	RTS

lbC00EE42

	bsr.w	SongEnd

	MOVEM.L	D0/D1/A0,-(SP)
	TST.W	lbW01535E-DT(A4)
	BEQ.L	lbC00EE86
	CLR.W	lbW01535E-DT(A4)
	LEA	$DFF0D8,A0
	MOVE.W	lbW015362-DT(A4),D1
	MOVE.W	#3,D0
lbC00EE60	BTST	D0,D1
	BEQ.L	lbC00EE6A
	MOVE.W	#0,(A0)
lbC00EE6A	SUBA.W	#$10,A0
	DBRA	D0,lbC00EE60
	MOVE.W	lbW015362-DT(A4),D1
	EORI.W	#15,D1
	MOVE.W	D1,$DFF096
	MOVE.W	#$FFFF,lbW015356-DT(A4)
lbC00EE86	MOVEM.L	(SP)+,D0/D1/A0
	RTS

;lbC00EE8C	LINK.W	A5,#0
;	MOVEM.L	D0,-(SP)
;	MOVE.W	8(A5),D0
;	NEG.W	D0
;	MOVE.W	D0,lbW015358-DT(A4)
;	MOVEM.L	(SP)+,D0
;	UNLK	A5
;	RTS

;lbC00EEA6	CLR.W	D0
;	TST.W	lbW015356-DT(A4)
;	BEQ.L	lbC00EEB6
;	MOVE.W	#1,D0
;	BSR.S	lbC00EE42
;lbC00EEB6	RTS

Play
	TST.W	lbW01535E-DT(A4)
	BEQ.L	lbC00EFDC
	MOVEM.L	D0-D7/A0-A6,-(SP)
;	TST.W	lbW015358-DT(A4)
;	BPL.L	lbC00EEF6
;	MOVE.W	lbW015350-DT(A4),D0
;	LSR.W	#1,D0
;	BCC.L	lbC00EEF6
;	MOVE.W	lbW01535A-DT(A4),D0
;	MOVE.W	lbW015358-DT(A4),D1
;	NEG.W	D1
;	ADD.W	D1,D0
;	MOVE.W	D0,lbW01535A-DT(A4)
;	CMPI.W	#$40,D0
;	BMI.L	lbC00EEF6
;	BSR.L	lbC00EE42
;	BRA.L	lbC00EFD8

lbC00EEF6	ADDQ.W	#1,lbW015350-DT(A4)
	MOVE.W	lbW015352-DT(A4),D0
	CMP.W	lbW015350-DT(A4),D0
	BLE.L	lbC00EF0A
	BRA.L	lbC00EFD4

lbC00EF0A	CLR.W	lbW015350-DT(A4)
	MOVEA.L	lbL01533E-DT(A4),A0
	MOVE.W	lbW01534C-DT(A4),D0
	CLR.L	D1
	LSL.W	#1,D0
	MOVEA.L	lbL015342-DT(A4),A2
	MOVE.W	0(A2,D0.W),D0
	MOVEA.L	lbL015346-DT(A4),A2
	LSL.W	#1,D0
	MOVE.W	0(A2,D0.W),D1
	ADD.W	lbW01534A-DT(A4),D1
	ADDA.W	D1,A0
	CLR.W	lbW01535C-DT(A4)
	MOVE.W	(A0)+,D1
	ADDQ.W	#2,lbW01534A-DT(A4)
	CLR.W	lbW01534E-DT(A4)
	TST.W	D1
	BPL.L	lbC00EF4C
	MOVE.W	#$FFFF,lbW01534E-DT(A4)
lbC00EF4C	MOVEA.L	#$DFF0A0,A5
	LEA	lbL0151FC-DT(A4),A6
	MOVE.W	#3,D5
lbC00EF5A	BSR.L	lbC00EFDE
	ADDA.W	#$10,A5
	ADDA.W	#$1C,A6
	DBRA	D5,lbC00EF5A
;	MOVE.W	#$220,D0
;lbC00EF6E	DBRA	D0,lbC00EF6E

	bsr.w	DMAWait

	MOVE.W	lbW01535C-DT(A4),D0
	OR.W	D0,lbW015366-DT(A4)
	MOVE.W	D0,D1
	LSL.W	#7,D1
	BCLR	#15,D1
	MOVE.W	D1,$DFF09C
	BSET	#15,D1
	MOVE.W	D1,$DFF09A
	BSET	#15,D0
	MOVE.W	D0,$DFF096
	BCLR	#15,D1
	MOVE.W	D1,$DFF09C
	MOVE.W	#0,lbW015356-DT(A4)
	TST.W	lbW01534E-DT(A4)
	BEQ.L	lbC00EFD4
	CLR.W	lbW01534A-DT(A4)
	ADDQ.W	#1,lbW01534C-DT(A4)
	CLR.L	D0
	MOVE.W	lbW015354-DT(A4),D0
	CMP.W	lbW01534C-DT(A4),D0
	BNE.L	lbC00EFD4

	bsr.w	SongEnd

	CLR.W	lbW01534C-DT(A4)
	MOVE.W	#$FFFF,lbW015356-DT(A4)
lbC00EFD4	BSR.L	lbC00F1C6
lbC00EFD8	MOVEM.L	(SP)+,D0-D7/A0-A6
lbC00EFDC	RTS

lbC00EFDE	CLR.L	(A6)
	MOVE.W	#3,D0
	SUB.W	D5,D0
	BTST	D0,D1
	BEQ.L	lbC00F0F2
	MOVE.L	(A0)+,(A6)
	ADDQ.W	#4,lbW01534A-DT(A4)
	TST.B	$16(A6)
	BNE.L	lbC00F13C
	MOVE.B	(A6),D2
	LSL.W	#4,D2
	MOVE.B	2(A6),D2
	LSR.W	#4,D2
	ANDI.W	#$1F,D2
	SUBQ.W	#1,D2
	BPL.L	lbC00F012
	MOVE.W	$1A(A6),D2
lbC00F012	MOVE.W	D2,$1A(A6)
	ANDI.W	#$FFF,(A6)
	BEQ.L	lbC00F0D0
	LEA	lbL01526C-DT(A4),A1
	MOVEA.L	lbL01533A-DT(A4),A3
	MOVE.W	D2,D4
	LSL.W	#2,D2
lbC00F02A	CMP.B	(A3),D4
	BEQ.L	lbC00F034
	ADDQ.W	#8,A3
	BRA.S	lbC00F02A

lbC00F034	MOVE.L	0(A1,D2.W),4(A6)
	MOVE.W	2(A3),8(A6)
	MOVE.B	1(A3),D6
	EXT.W	D6
	MOVE.W	D6,$12(A6)
	MOVE.W	4(A3),D3
	EXT.L	D3
	MOVE.L	4(A6),D2
	ADD.L	D3,D2
	MOVE.L	D2,10(A6)
	MOVE.W	6(A3),14(A6)
	MOVE.W	(A6),$10(A6)
	MOVE.W	$14(A6),D0
	OR.W	D0,lbW01535C-DT(A4)
lbC00F06C	LSL.W	#7,D0
	MOVE.W	D0,$DFF09A
	MOVE.W	D0,$DFF09C
	MOVE.W	$14(A6),D0
	MOVE.W	D0,$DFF096
	MOVE.W	#1,4(A5)
	MOVE.W	#$7C,6(A5)
	BSET	#15,D0
	MOVE.W	D0,$DFF096
	NOP
	BCLR	#15,D0
	MOVE.W	D0,$DFF096
	MOVE.W	(A6),6(A5)
	MOVE.W	(A6),6(A5)
	MOVE.W	8(A6),4(A5)
	MOVE.W	8(A6),4(A5)
	MOVE.L	4(A6),(A5)
	MOVE.L	4(A6),(A5)

	bsr.w	SetAll

	MOVE.B	#1,$17(A6)
	TST.B	$16(A6)
	BNE.L	lbC00F13C
lbC00F0D0	MOVE.W	2(A6),$18(A6)
	MOVE.B	2(A6),D0
	AND.B	#15,D0
	CMP.B	#12,D0
	BNE.L	lbC00F10E
lbC00F0E6	MOVE.B	3(A6),D2
	ANDI.W	#$FF,D2
	BRA.L	lbC00F112

lbC00F0F2	MOVE.B	$18(A6),D0
	ANDI.B	#15,D0
	CMP.B	#12,D0
	BNE.L	lbC00F10E
	MOVE.B	$19(A6),D2
	ANDI.W	#$FF,D2
	BRA.L	lbC00F112

lbC00F10E	MOVE.W	$12(A6),D2
lbC00F112	MOVE.W	#3,D0
	SUB.W	D5,D0
	TST.B	$16(A6)
	BNE.L	lbC00F13C
	SUB.W	lbW01535A-DT(A4),D2
	BMI.L	lbC00F134
	TST.W	lbW015368-DT(A4)
	BNE.L	lbC00F134
	BRA.L	lbC00F138

lbC00F134	MOVE.W	#0,D2
lbC00F138
;	MOVE.W	D2,8(A5)

	bsr.w	ChangeVolume
	bsr.w	SetVol

lbC00F13C	RTS

lbC00F13E	MOVEM.L	D0-D7/A0-A6,-(SP)
	JSR	lbC00DC7A(PC)
	MOVE.W	$DFF01E,D1
	AND.W	$DFF01C,D1
	LSR.W	#7,D1
	LEA	$DFF0D0,A5
	LEA	lbL0151FC-DT(A4),A6
	ADDA.W	#$54,A6
	MOVEQ	#3,D0
lbC00F164	BTST	D0,D1
	BEQ.L	lbC00F16E
	BSR.L	lbC00F180
lbC00F16E	SUBA.W	#$10,A5
	SUBA.W	#$1C,A6
	DBRA	D0,lbC00F164
	MOVEM.L	(SP)+,D0-D7/A0-A6
;	RTE

	rts

lbC00F180	MOVEM.L	D0/D1,-(SP)
	CLR.W	D1
	BSET	D0,D1
	LSL.W	#7,D1
	MOVE.W	D1,$DFF09C
	MOVE.L	10(A6),(A5)
	MOVE.W	14(A6),4(A5)
	TST.B	$16(A6)
	BEQ.L	lbC00F1B2
	TST.B	$17(A6)
	BEQ.L	lbC00F1B2
	CLR.B	$17(A6)
	BRA.L	lbC00F1C0

lbC00F1B2	CLR.B	$16(A6)
	MOVE.W	D1,$DFF09A
	BRA.L	lbC00F1C0

lbC00F1C0	MOVEM.L	(SP)+,D0/D1
	RTS

lbC00F1C6	MOVE.W	#3,D5
	MOVEA.L	#$DFF0A0,A5
	LEA	lbL0151FC-DT(A4),A6
lbC00F1D4	CMPI.B	#0,3(A6)
	BEQ.L	lbC00F1EA
	BSR.L	lbC00F1F8
	TST.W	lbW01535E-DT(A4)
	BEQ.L	lbC00F1F6
lbC00F1EA	ADDA.W	#$10,A5
	ADDA.W	#$1C,A6
	DBRA	D5,lbC00F1D4
lbC00F1F6	RTS

lbC00F1F8	MOVE.B	2(A6),D0
	MOVE.W	#3,D1
	SUB.W	D5,D1
	TST.B	$16(A6)
	BNE.L	lbC00F22C
	AND.B	#15,D0
	TST.B	D0
	BEQ.L	lbC00F23E
	CMP.B	#1,D0
	BEQ.L	lbC00F2E0
	CMP.B	#2,D0
	BEQ.L	lbC00F2B2
	CMP.B	#12,D0
	BEQ.L	lbC00F0E6
lbC00F22C	CMP.B	#14,D0
	BEQ.L	lbC00F334
	CMP.B	#15,D0
	BEQ.L	lbC00F30C
	RTS

lbC00F23E	MOVE.W	lbW015350-DT(A4),D0
	SUBQ.W	#1,D0
	ANDI.W	#3,D0
	BEQ.L	lbC00F25E
	CMP.W	#1,D0
	BEQ.L	lbC00F26A
	CMP.W	#2,D0
	BEQ.L	lbC00F278
	RTS

lbC00F25E	CLR.L	D0
	MOVE.B	3(A6),D0
	LSR.B	#4,D0
	BRA.L	lbC00F280

lbC00F26A	CLR.L	D0
	MOVE.B	3(A6),D0
	AND.B	#15,D0
	BRA.L	lbC00F280

lbC00F278	MOVE.W	$10(A6),D2
	BRA.L	lbC00F2AC

lbC00F280	LSL.W	#1,D0
	CLR.L	D1
	MOVE.W	$10(A6),D1
	LEA	lbW0152E4-DT(A4),A0
lbC00F28C	MOVE.W	0(A0,D0.W),D2
	TST.W	D2
	BNE.L	lbC00F2A2
	SUBQ.W	#2,D0
	BPL.L	lbC00F29E
	CLR.W	D0
lbC00F29E	MOVE.W	0(A0,D0.W),D2
lbC00F2A2	CMP.W	(A0),D1
	BEQ.L	lbC00F2AC
	ADDQ.L	#2,A0
	BRA.S	lbC00F28C

lbC00F2AC	MOVE.W	D2,6(A5)
	RTS

lbC00F2B2	MOVE.W	lbW015350-DT(A4),D0
	CMPI.W	#6,D0
	BPL.L	lbC00F2DE
	BSR.L	lbC00F354
	CLR.L	D0
	MOVE.B	3(A6),D0
	AND.B	#15,D0
	ADD.W	D0,(A0)
	CMPI.W	#$358,(A0)
	BMI.L	lbC00F2DA
	MOVE.W	#$358,(A0)
lbC00F2DA	MOVE.W	(A0),6(A5)
lbC00F2DE	RTS

lbC00F2E0	MOVE.W	lbW015350-DT(A4),D0
	CMPI.W	#6,D0
	BPL.S	lbC00F2DE
	BSR.L	lbC00F354
	CLR.L	D0
	MOVE.B	3(A6),D0
	AND.B	#15,D0
	SUB.W	D0,(A0)
	CMPI.W	#$71,(A0)
	BPL.L	lbC00F306
	MOVE.W	#$71,(A0)
lbC00F306	MOVE.W	(A0),6(A5)
	RTS

lbC00F30C	MOVE.W	2(A6),D0
	AND.W	#$FF,D0
	BNE.L	lbC00F31C
	MOVE.W	#6,D0
lbC00F31C	TST.B	D0
	BPL.L	lbC00F32A
	BSR.L	lbC00EE42
	BRA.L	lbC00F332

lbC00F32A	ANDI.B	#15,D0
	MOVE.W	D0,lbW015352-DT(A4)
lbC00F332	RTS

lbC00F334	MOVE.B	3(A6),D0
	LSR.B	#1,D0
	BCC.L	lbC00F34A
	BSET	#1,$BFE001
	BRA.L	lbC00F352

lbC00F34A	BCLR	#1,$BFE001
lbC00F352	RTS

lbC00F354	LEA	lbL01532E-DT(A4),A0
	MOVE.W	#3,D0
	SUB.W	D5,D0
	LSL.W	#2,D0
	ADDA.W	D0,A0
	RTS

;	LINK.W	A5,#0
;	MOVEM.L	D0/D1/A0/A1,-(SP)
;	TST.W	lbW015372-DT(A4)
;	BEQ.L	lbC00F40A
;	MOVEA.L	lbL015374-DT(A4),A1
;	MOVEA.L	8(A5),A0
;	MOVE.W	12(A5),D0
;	MULU.W	#10,D0
;	ADDA.W	D0,A1
;	CMPI.L	#$464F524D,(A0)
;	BNE.L	lbC00F40A
;	CLR.W	D1
;lbC00F392	ADDQ.W	#1,D1
;	CMPI.W	#$64,D1
;	BPL.L	lbC00F40A
;	CMPI.L	#$56484452,(A0)+
;	BNE.S	lbC00F392
;	ADDQ.W	#4,A0
;	MOVE.L	(A0),D1
;	BNE.L	lbC00F3B4
;	MOVE.L	4(A0),D1
;	BEQ.L	lbC00F40A
;lbC00F3B4	MOVE.W	D1,4(A1)
;	MOVE.W	#$40,D1
;	TST.W	14(A5)
;	BEQ.L	lbC00F3C8
;	MOVE.B	15(A5),D1
;lbC00F3C8	MOVE.B	D1,8(A1)
;	MOVE.W	12(A0),D1
;	TST.W	D1
;	BNE.L	lbC00F3DA
;	MOVE.W	#$1F40,D1
;lbC00F3DA	MOVE.L	#$369E99,D0
;	DIVU.W	D1,D0
;	MOVE.W	D0,6(A1)
;	CLR.W	D1
;lbC00F3E8	ADDQ.W	#1,D1
;	CMPI.W	#$64,D1
;	BPL.L	lbC00F40A
;	CMPI.L	#$424F4459,(A0)+
;	BNE.S	lbC00F3E8
;	ADDQ.W	#4,A0
;	MOVE.L	A0,(A1)
;	CLR.W	(A0)
;	MOVE.B	#1,9(A1)
;	BRA.L	lbC00F41A

;lbC00F40A	MOVE.W	#$1F40,D0
;lbC00F40E	MOVE.W	#$FFF,$DFF180
;	DBRA	D0,lbC00F40E
;lbC00F41A	MOVEM.L	(SP)+,D0/D1/A0/A1
;	UNLK	A5
;	RTS

;lbC00F422	LINK.W	A5,#0
;	MOVEM.L	D0/D1/A0/A1,-(SP)
;	TST.W	lbW015372-DT(A4)
;	BEQ.S	lbC00F40A
;	MOVEA.L	lbL015374-DT(A4),A1
;	MOVE.W	8(A5),D0
;	MULU.W	#10,D0
;	ADDA.W	D0,A1
;	MOVE.B	#0,9(A1)
;	MOVEM.L	(SP)+,D0/D1/A0/A1
;	UNLK	A5
;	RTS

;	LINK.W	A5,#0
;	MOVEM.L	D0/D1/A0-A6,-(SP)
;	TST.W	lbW015372-DT(A4)
;	BEQ.L	lbC00F4EC
;	TST.W	lbW01536A-DT(A4)
;	BNE.L	lbC00F4EC
;	MOVE.W	8(A5),D0
;	MOVE.W	10(A5),D1
;	ANDI.W	#15,D1
;	LEA	$DFF0A0,A5
;	LEA	lbL0151FC-DT(A4),A6
;	MOVEA.L	lbL015374-DT(A4),A0
;	MULU.W	#10,D0
;	TST.B	9(A0,D0.W)
;	BEQ.L	lbC00F4EC
;	CLR.W	D2
;lbC00F48C	BTST	D2,D1
;	BEQ.L	lbC00F49A
;	TST.B	$16(A6)
;	BEQ.L	lbC00F4AE
;lbC00F49A	ADDA.W	#$1C,A6
;	ADDA.W	#$10,A5
;	ADDQ.W	#1,D2
;	CMPI.W	#4,D2
;	BMI.S	lbC00F48C
;	BRA.L	lbC00F4EC

;lbC00F4AE	MOVE.B	#1,$16(A6)
;	MOVE.L	0(A0,D0.W),4(A6)
;	MOVE.L	0(A0,D0.W),10(A6)
;	MOVE.W	4(A0,D0.W),D1
;	LSR.W	#1,D1
;	MOVE.W	D1,8(A6)
;	MOVE.W	6(A0,D0.W),(A6)
;	MOVE.W	#1,14(A6)
;	MOVE.B	8(A0,D0.W),D1
;	EXT.W	D1
;	MOVE.W	D1,$12(A6)
;	MOVE.W	$14(A6),D0
;	BSR.L	lbC00F06C
;	MOVE.W	$12(A6),8(A5)
;lbC00F4EC	MOVE.W	#$1F4,D0
;lbC00F4F0	DBRA	D0,lbC00F4F0
;	MOVE.W	$14(A6),D0
;	MOVE.W	D0,D1
;	LSL.W	#7,D1
;	BCLR	#15,D1
;	MOVE.W	D1,$DFF09C
;	BSET	#15,D1
;	MOVE.W	D1,$DFF09A
;	BSET	#15,D0
;	MOVE.W	D0,$DFF096
;	BCLR	#15,D1
;	MOVE.W	D1,$DFF09C
;	MOVEM.L	(SP)+,D0/D1/A0-A6
;	UNLK	A5
;	RTS

lbC00DC7A	LEA	DT(pc),A4
	RTS

DT

lbL0151FC	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbL01526C	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbW0152E4	dc.w	$358
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
lbL01532E	dc.l	0
	dc.l	0
lbL015336	dc.l	0
lbL01533A	dc.l	0
lbL01533E	dc.l	0
lbL015342	dc.l	0
lbL015346	dc.l	0
lbW01534A	dc.w	0
lbW01534C	dc.w	0
lbW01534E	dc.w	0
lbW015350	dc.w	0
lbW015352	dc.w	6
lbW015354	dc.w	0
lbW015356	dc.w	$FFFF
lbW015358	dc.w	0
lbW01535A	dc.w	0
lbW01535C	dc.w	0
lbW01535E	dc.w	0
	dc.w	0
lbW015362	dc.w	0
	dc.w	0
lbW015366	dc.w	0
lbW015368	dc.w	0
lbW01536A	dc.w	0
lbL01536C	dc.l	0
lbW015370	dc.w	0
lbW015372	dc.w	0
lbL015374	dc.l	0

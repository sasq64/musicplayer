	*****************************************************
	****     Digital Sonix & Chrome replayer for 	 ****
	****  EaglePlayer all adaptions by Wanted Team,  ****
	****     DeliTracker compatible (?) version	 ****
	*****************************************************

	incdir	"dh2:include/"
	include 'misc/eagleplayer2.01.i'
	include 'hardware/intbits.i'
	include 'exec/exec_lib.i'

	SECTION	Player,CODE

	PLAYERHEADER Tags

	dc.b	'$VER: Digital Sonix & Chrome player module V1.0 (19 May 2003)',0
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
	dc.l	DTP_SubSongRange,SubSongRange
	dc.l	DTP_Volume,SetVolume
	dc.l	DTP_Balance,SetBalance
	dc.l	EP_Voices,SetVoices
	dc.l	EP_StructInit,StructInit
	dc.l	EP_GetPositionNr,GetPosition
	dc.l	EP_SampleInit,SampleInit
	dc.l	EP_Flags,EPB_Volume!EPB_Balance!EPB_ModuleInfo!EPB_Voices!EPB_SampleInfo!EPB_Songend!EPB_Analyzer!EPB_Packable!EPB_Restart!EPB_NextSong!EPB_PrevSong
	dc.l	0

PlayerName
	dc.b	'Digital Sonix & Chrome',0
Creator
	dc.b	'(c) 1990 by Andrew E. Bailey & David',10
	dc.b	'M. Hanlon, adapted by Wanted Team',0
Prefix
	dc.b	'DSC.',0
	even
ModulePtr
	dc.l	0
EagleBase
	dc.l	0
SamplesInfoPtr
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
***************************** DTP_SubSongRange ****************************
***************************************************************************

SubSongRange
	moveq	#0,D0
	move.l	InfoBuffer+SubSongs(PC),D1
	subq.l	#1,D1
	rts

***************************************************************************
******************************* EP_SampleInit *****************************
***************************************************************************

SampleInit
	moveq	#EPR_NotEnoughMem,D7
	lea	EPG_SampleInfoStructure(A5),A3
	move.l	SamplesInfoPtr(PC),D0
	beq.b	return
	move.l	D0,A2

	move.l	InfoBuffer+Samples(PC),D5
	subq.l	#1,D5
hop
	jsr	ENPP_AllocSampleStruct(A5)
	move.l	D0,(A3)
	beq.b	return
	move.l	D0,A3

	move.l	2(A2),EPS_Length(A3)		; sample length
	move.l	12(A2),EPS_Adr(A3)		; sample address
	move.l	#64,EPS_Volume(A3)
	move.w	#USITY_RAW,EPS_Type(A3)
	move.w	#USIB_Playable!USIB_Saveable!USIB_8BIT,EPS_Flags(A3)
	lea	18(A2),A2
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
SubSongs	=	52

InfoBuffer
	dc.l	MI_LoadSize,0		;4
	dc.l	MI_Samples,0		;12
	dc.l	MI_Length,0		;20
	dc.l	MI_SamplesSize,0	;28
	dc.l	MI_Songsize,0		;36
	dc.l	MI_Calcsize,0		;44
	dc.l	MI_SubSongs,0		;52
	dc.l	MI_MaxLength,255
	dc.l	MI_MaxSamples,255
	dc.l	MI_Prefix,Prefix
	dc.l	0

***************************************************************************
******************************* DTP_Check2 ********************************
***************************************************************************

Check2
	movea.l	dtg_ChkData(A5),A0

	move.l	dtg_ChkSize(A5),D3
	lea	(A0,D3.L),A1

	tst.w	(A0)+
	beq.w	Fault
	moveq	#0,D0
	move.b	(A0)+,D0
	beq.w	Fault
	moveq	#0,D1
	move.b	(A0)+,D1
	beq.w	Fault
	move.l	(A0)+,D2
	beq.b	Fault
	btst	#0,D2
	bne.b	Fault
	cmp.l	#$80000,D2
	bhi.b	Fault
	cmp.l	D3,D2
	bge.b	Fault
	move.l	(A0)+,D3
	beq.b	Fault
	cmp.l	#$20000,D3
	bhi.b	Fault
	subq.l	#2,D1
	bmi.b	Fault
CheckOne
	move.l	(A0)+,D4
	bmi.b	Fault
	btst	#0,D4
	bne.b	Fault
	cmp.l	#$20000,D4
	bhi.b	Fault
	addq.l	#2,A0
	dbf	D1,CheckOne
	tst.l	(A0)+
	bne.b	Fault
	tst.w	(A0)+
	bne.b	Fault
	lsl.l	#2,D3
	add.l	D3,A0
	mulu.w	#18,D0
	lea	(A0,D0.W),A2
	cmp.l	A2,A1
	ble.b	Fault
CheckTwo
	move.l	2(A0),D1
	beq.b	Fault
	bmi.b	Fault
	cmp.l	D2,D1
	bgt.b	Fault
	move.l	12(A0),D0
	cmp.l	D2,D0
	bhi.b	Fault
	lea	18(A0),A0
	cmp.l	A0,A2
	bne.b	CheckTwo
	add.l	-16(A0),D0
	cmp.l	D2,D0
	bne.b	Fault

	moveq	#0,D0
	rts
Fault
	moveq	#-1,D0
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

	moveq	#0,D0
	move.b	3(A0),D0
	move.l	D0,Length(A4)
	mulu.w	#6,D0
	lea	12(A0),A1
	lea	(A1,D0.W),A2
	moveq	#12,D1
	add.l	D0,D1
	moveq	#0,D0
SubCheck
	tst.b	4(A1)
	bne.b	NoSong
	addq.l	#1,D0
NoSong
	addq.l	#6,A1
	cmp.l	A1,A2
	bne.b	SubCheck
	move.l	D0,SubSongs(A4)
	moveq	#0,D0
	move.b	2(A0),D0
	move.l	D0,Samples(A4)
	move.l	8(A0),D2
	lsl.l	#2,D2
	add.l	D2,D1
	lea	(A0,D1.L),A1
	move.l	A1,(A6)				; SamplesInfoPtr
	mulu.w	#18,D0
	add.l	D0,D1
	move.l	D1,SongSize(A4)
	move.l	4(A0),D0
	move.l	D0,SamplesSize(A4)
	add.l	D0,D1
	move.l	D1,CalcSize(A4)

	cmp.l	LoadSize(A4),D1
	ble.b	SizeOK
	moveq	#EPR_ModuleTooShort,D0
	rts
SizeOK
	lea	WT(PC),A4
	move.l	A5,-(SP)
	lea	12(A0),A5
	bsr.w	InstallSamples
	move.l	(SP)+,A5

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
	move.l	lbL008072(PC),D0
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
	lea	$DFF0A0,A2
SetNew
	move.w	(A1)+,D0
	bsr.b	ChangeVolume
	lea	16(A2),A2
	dbf	D1,SetNew
	rts

ChangeVolume
	and.w	#$7F,D0
	cmpa.l	#$DFF0A0,A2			;Left Volume
	bne.b	NoVoice1
	move.w	D0,OldVoice1
	tst.w	Voice1
	bne.b	Voice1On
	moveq	#0,D0
Voice1On
	mulu.w	LeftVolume(PC),D0
	bra.b	SetIt
NoVoice1
	cmpa.l	#$DFF0B0,A2			;Right Volume
	bne.b	NoVoice2
	move.w	D0,OldVoice2
	tst.w	Voice2
	bne.b	Voice2On
	moveq	#0,D0
Voice2On
	mulu.w	RightVolume(PC),D0
	bra.b	SetIt
NoVoice2
	cmpa.l	#$DFF0C0,A2			;Right Volume
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
	move.w	D0,8(A2)
	rts

*------------------------------- Set Vol -------------------------------*

SetVol
	move.l	A0,-(A7)
	lea	StructAdr+UPS_Voice1Vol(PC),A0
	cmp.l	#$DFF0A0,A2
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice2Vol(PC),A0
	cmp.l	#$DFF0B0,A2
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice3Vol(PC),A0
	cmp.l	#$DFF0C0,A2
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
	cmp.l	#$DFF0A0,A2
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice2Adr(PC),A0
	cmp.l	#$DFF0B0,A2
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice3Adr(PC),A0
	cmp.l	#$DFF0C0,A2
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice4Adr(PC),A0
.SetVoice
	move.l	12(A3),(A0)
	move.w	D0,UPS_Voice1Len(A0)
	move.w	(A3),UPS_Voice1Per(A0)
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

	lea	WT(PC),A4
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
	lea	StructInt0(PC),A1
	moveq	#INTB_AUD0,D0
	jsr	_LVOSetIntVector(A6)		; SetIntVector
	move.l	D0,Channel0
	lea	StructInt1(PC),A1
	moveq	#INTB_AUD1,D0
	jsr	_LVOSetIntVector(A6)
	move.l	D0,Channel1
	lea	StructInt2(PC),A1
	moveq	#INTB_AUD2,D0
	jsr	_LVOSetIntVector(A6)
	move.l	D0,Channel2
	lea	StructInt3(PC),A1
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
StructInt0
	dc.l	0
	dc.l	0
	dc.w	$205
	dc.l	IntName0
	dc.l	Empty
	dc.l	Audio0
IntName0
	dc.b	'Digital Sonix & Chrome Aud0 Interrupt',0
	even

StructInt1
	dc.l	0
	dc.l	0
	dc.w	$205
	dc.l	IntName1
	dc.l	Empty
	dc.l	Audio1
IntName1
	dc.b	'Digital Sonix & Chrome Aud1 Interrupt',0
	even

StructInt2
	dc.l	0
	dc.l	0
	dc.w	$205
	dc.l	IntName2
	dc.l	Empty
	dc.l	Audio2
IntName2
	dc.b	'Digital Sonix & Chrome Aud2 Interrupt',0
	even

StructInt3
	dc.l	0
	dc.l	0
	dc.w	$205
	dc.l	IntName3
	dc.l	Empty
	dc.l	Audio3
IntName3
	dc.b	'Digital Sonix & Chrome Aud3 Interrupt',0
	even

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
	moveq	#0,D7
	move.w	dtg_SndNum(A5),D7
	lea	WT(PC),A4
	bsr.w	Init
	bra.w	SetAudioVector

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
	move.w	#$780,$9A(A0)
	move.w	#$780,$9C(A0)
	bra.w	ClearAudioVector

***************************************************************************
*********************** Digital Sonix & Chrome player *********************
***************************************************************************

; Player from "Dragon's Breath" (c) 1990 by Digital Sonix & Chrome

Play
;lbC005290	LINK.W	A5,#0
;	JSR	lbC006D56(PC)
;	MOVE.L	D4,lbL008334-WT(A4)
	SUBQ.B	#1,lbB008083-WT(A4)
	BNE.S	lbC0052DC
;	TST.B	lbB008084-WT(A4)
;	BEQ.S	lbC0052DC
	MOVE.B	lbB008082-WT(A4),lbB008083-WT(A4)
	JSR	lbC005400(PC)
;	MOVE.B	lbB008085-WT(A4),D0
;	CMP.B	lbB008086-WT(A4),D0
;	BEQ.S	lbC0052DC
;	MOVE.L	lbL008076-WT(A4),D1
;	AND.L	#3,D1
;	BNE.S	lbC0052DC
;	MOVE.B	lbB008085-WT(A4),D0
;	CMP.B	lbB008086-WT(A4),D0
;	BGE.S	lbC0052D8
;	ADDQ.B	#1,lbB008085-WT(A4)
;	BRA.S	lbC0052DC

;lbC0052D8	SUBQ.B	#1,lbB008085-WT(A4)
lbC0052DC	CLR.L	D4
	MOVE.B	lbB0080B0-WT(A4),D4
	BMI.S	lbC0052FE
	CMP.B	lbB0080AC-WT(A4),D4
	BHI.S	lbC0052F8
;	CLR.L	-(SP)
;	MOVE.L	D4,-(SP)

	moveq	#0,D5

	JSR	lbC005936(PC)
;	ADDQ.L	#8,SP
	MOVE.B	D4,lbB0080AC-WT(A4)
lbC0052F8	MOVE.B	#$FF,lbB0080B0-WT(A4)
lbC0052FE	CLR.L	D4
	MOVE.B	lbB0080B1-WT(A4),D4
	BMI.S	lbC005322
	CMP.B	lbB0080AD-WT(A4),D4
	BHI.S	lbC00531C
;	PEA	1
;	MOVE.L	D4,-(SP)

	moveq	#1,D5

	JSR	lbC005936(PC)
;	ADDQ.L	#8,SP
	MOVE.B	D4,lbB0080AD-WT(A4)
lbC00531C	MOVE.B	#$FF,lbB0080B1-WT(A4)
lbC005322	CLR.L	D4
	MOVE.B	lbB0080B2-WT(A4),D4
	BMI.S	lbC005346
	CMP.B	lbB0080AE-WT(A4),D4
	BHI.S	lbC005340
;	PEA	2
;	MOVE.L	D4,-(SP)

	moveq	#2,D5

	JSR	lbC005936(PC)
;	ADDQ.L	#8,SP
	MOVE.B	D4,lbB0080AE-WT(A4)
lbC005340	MOVE.B	#$FF,lbB0080B2-WT(A4)
lbC005346	CLR.L	D4
	MOVE.B	lbB0080B3-WT(A4),D4
	BMI.S	lbC00536A
	CMP.B	lbB0080AF-WT(A4),D4
	BHI.S	lbC005364
;	PEA	3
;	MOVE.L	D4,-(SP)

	moveq	#3,D5

	JSR	lbC005936(PC)
;	ADDQ.L	#8,SP
	MOVE.B	D4,lbB0080AF-WT(A4)
lbC005364	MOVE.B	#$FF,lbB0080B3-WT(A4)
lbC00536A
;	MOVE.L	lbL008334-WT(A4),D4
;	JSR	lbC006D64(PC)
;	UNLK	A5
	RTS


Init
;	LINK.W	A5,#0
	MOVE.L	#$FFFFFFFF,lbB0080AC-WT(A4)
	MOVE.L	#$FFFFFFFF,lbB0080B0-WT(A4)
	CLR.L	lbL00807A-WT(A4)
lbC00538E
;	MOVE.L	8(A5),D0
;	SUBQ.L	#1,8(A5)

	move.l	D7,D0
	subq.l	#1,D7

	TST.L	D0
	BEQ.S	lbC0053B8
lbC00539A	MOVE.L	lbL00807A-WT(A4),D0
	ADDQ.L	#1,lbL00807A-WT(A4)
	MOVEQ	#6,D1
	JSR	lbC007930(PC)
	MOVEA.L	D0,A0
	ADDA.L	lbL008318-WT(A4),A0
	TST.B	4(A0)
	BEQ.S	lbC0053B6
	BRA.S	lbC00539A

lbC0053B6	BRA.S	lbC00538E

lbC0053B8	MOVE.L	lbL00807A-WT(A4),lbL008072-WT(A4)
	CLR.L	lbL008076-WT(A4)
	MOVEQ	#6,D1
	MOVE.L	lbL008072-WT(A4),D0
	JSR	lbC007930(PC)
	MOVEA.L	lbL008318-WT(A4),A0
	MOVE.L	0(A0,D0.L),lbL008330-WT(A4)
	MOVEQ	#6,D1
	MOVE.L	lbL008072-WT(A4),D0
	JSR	lbC007930(PC)
	MOVEA.L	D0,A0
	ADDA.L	lbL008318-WT(A4),A0
	MOVEQ	#0,D2
	MOVE.B	4(A0),D2
	MOVE.L	D2,lbL00807E-WT(A4)
;	MOVE.B	lbB008056-WT(A4),lbB008084-WT(A4)
	MOVE.B	#1,lbB008083-WT(A4)
;	UNLK	A5
	RTS

lbC005400
;	LINK.W	A5,#-$10
	TST.B	lbB0080AC-WT(A4)
	BGE.S	lbC005414
	MOVEA.L	lbL008330-WT(A4),A0
	MOVEQ	#0,D0
	MOVE.B	(A0),D0
	BRA.S	lbC00541A

lbC005414	MOVE.L	#$FF,D0
lbC00541A
;	MOVE.L	D0,-4(A5)

	move.l	D0,V1Temp-WT(A4)

	TST.B	lbB0080AD-WT(A4)
	BGE.S	lbC005436
	MOVE.L	lbL008324-WT(A4),D0
	MOVEA.L	lbL008330-WT(A4),A0
	MOVE.L	D0,D1
	MOVEQ	#0,D0
	MOVE.B	0(A0,D1.L),D0
	BRA.S	lbC00543C

lbC005436	MOVE.L	#$FF,D0
lbC00543C
;	MOVE.L	D0,-8(A5)

	move.l	D0,V2Temp-WT(A4)

	TST.B	lbB0080AE-WT(A4)
	BGE.S	lbC005458
	MOVE.L	lbL008328-WT(A4),D0
	MOVEA.L	lbL008330-WT(A4),A0
	MOVE.L	D0,D1
	MOVEQ	#0,D0
	MOVE.B	0(A0,D1.L),D0
	BRA.S	lbC00545E

lbC005458	MOVE.L	#$FF,D0
lbC00545E
;	MOVE.L	D0,-12(A5)

	move.l	D0,V3Temp-WT(A4)

	TST.B	lbB0080AF-WT(A4)
	BGE.S	lbC00547A
	MOVE.L	lbL00832C-WT(A4),D0
	MOVEA.L	lbL008330-WT(A4),A0
	MOVE.L	D0,D1
	MOVEQ	#0,D0
	MOVE.B	0(A0,D1.L),D0
	BRA.S	lbC005480

lbC00547A	MOVE.L	#$FF,D0
lbC005480
;	MOVE.L	D0,-$10(A5)

	move.l	D0,V4Temp-WT(A4)

	ADDQ.L	#1,lbL008330-WT(A4)
;	CLR.L	-(SP)
;	MOVE.L	-4(A5),-(SP)

	moveq	#0,D5
	move.l	V1Temp-WT(A4),D4

	JSR	lbC005936(PC)
;	ADDQ.W	#8,SP
;	PEA	1
;	MOVE.L	-8(A5),-(SP)

	moveq	#1,D5
	move.l	V2Temp-WT(A4),D4

	JSR	lbC005936(PC)
;	ADDQ.W	#8,SP
;	PEA	2
;	MOVE.L	-12(A5),-(SP)

	moveq	#2,D5
	move.l	V3Temp-WT(A4),D4

	JSR	lbC005936(PC)
;	ADDQ.W	#8,SP
;	PEA	3
;	MOVE.L	-$10(A5),-(SP)

	moveq	#3,D5
	move.l	V4Temp-WT(A4),D4

	JSR	lbC005936(PC)
;	ADDQ.W	#8,SP
	MOVEQ	#6,D1
	MOVE.L	lbL008072-WT(A4),D0
	JSR	lbC007930(PC)
	MOVEA.L	D0,A0
	ADDA.L	lbL008318-WT(A4),A0
	MOVEQ	#0,D2
	MOVE.B	5(A0),D2
	ADDQ.L	#1,lbL008076-WT(A4)
	CMP.L	lbL008076-WT(A4),D2
	BNE.S	lbC00554C
	CLR.L	lbL008076-WT(A4)
	SUBQ.L	#1,lbL00807E-WT(A4)
	BEQ.S	lbC0054FE
	MOVEQ	#6,D1
	MOVE.L	lbL008072-WT(A4),D0
	JSR	lbC007930(PC)
	MOVEA.L	lbL008318-WT(A4),A0
	MOVE.L	0(A0,D0.L),lbL008330-WT(A4)
	BRA.S	lbC00554C

lbC0054FE	ADDQ.L	#1,lbL008072-WT(A4)
	MOVE.L	lbL008072-WT(A4),D0
	MOVEQ	#6,D1
	JSR	lbC007930(PC)
	MOVEA.L	D0,A0
	ADDA.L	lbL008318-WT(A4),A0
	TST.B	4(A0)
	BNE.S	lbC00551E
	MOVE.L	lbL00807A-WT(A4),lbL008072-WT(A4)

	bsr.w	SongEnd

lbC00551E	MOVEQ	#6,D1
	MOVE.L	lbL008072-WT(A4),D0
	JSR	lbC007930(PC)
	MOVEA.L	lbL008318-WT(A4),A0
	MOVE.L	0(A0,D0.L),lbL008330-WT(A4)
	MOVEQ	#6,D1
	MOVE.L	lbL008072-WT(A4),D0
	JSR	lbC007930(PC)
	MOVEA.L	D0,A0
	ADDA.L	lbL008318-WT(A4),A0
	MOVEQ	#0,D2
	MOVE.B	4(A0),D2
	MOVE.L	D2,lbL00807E-WT(A4)
lbC00554C
;	UNLK	A5
	RTS

InstallSamples
;	LINK.W	A5,#-$14
;	MOVE.L	#$FFFFFFFF,lbB0080AC-WT(A4)
;	MOVE.L	#$FFFFFFFF,lbB0080B0-WT(A4)
;	PEA	$3ED
;	MOVE.L	8(A5),-(SP)
;	JSR	lbC00469E(PC)
;	ADDQ.W	#8,SP
;	MOVE.L	D0,-$10(A5)
;	BNE.S	lbC005582
;	PEA	Musicfile.MSG(PC)
;	JSR	lbC003BDA(PC)
;	ADDQ.W	#4,SP
;lbC005582	PEA	12
;	PEA	-12(A5)
;	MOVE.L	-$10(A5),-(SP)
;	JSR	lbC004804(PC)
;	LEA	12(SP),SP

	MOVEQ	#0,D0
	MOVE.B	-9(A5),D0
	MOVEQ	#6,D1
	JSR	lbC007930(PC)
	MOVE.L	D0,-(SP)
	MOVEQ	#0,D0
	MOVE.B	-10(A5),D0
	MOVEQ	#$12,D1
	JSR	lbC007930(PC)
	MOVE.L	(SP)+,D2
	ADD.L	D0,D2
	MOVE.L	-4(A5),D3
	ASL.L	#2,D3
	ADD.L	D3,D2
;	MOVE.L	D2,lbL00831C-WT(A4)
;	CLR.L	-(SP)
;	MOVE.L	lbL00831C-WT(A4),-(SP)
;	JSR	lbC007B72(PC)
;	ADDQ.W	#8,SP

	move.l	A5,D0
	add.l	D0,D2

	MOVE.L	D0,lbL008068-WT(A4)
;	BNE.S	lbC0055E6
;	MOVE.L	-$10(A5),-(SP)
;	JSR	lbC00489C(PC)
;	ADDQ.W	#4,SP
;	PEA	Musicmem.MSG(PC)
;	JSR	lbC003BDA(PC)
;	ADDQ.W	#4,SP
;lbC0055E6	MOVE.L	lbL00831C-WT(A4),-(SP)
;	MOVE.L	lbL008068-WT(A4),-(SP)
;	MOVE.L	-$10(A5),-(SP)
;	JSR	lbC004804(PC)
;	LEA	12(SP),SP
	MOVE.L	lbL008068-WT(A4),lbL008318-WT(A4)
	MOVE.L	-4(A5),lbL008324-WT(A4)
	MOVE.L	lbL008324-WT(A4),D0
	ASL.L	#1,D0
	MOVE.L	D0,lbL008328-WT(A4)
	MOVE.L	lbL008324-WT(A4),D0
	ADD.L	lbL008328-WT(A4),D0
	MOVE.L	D0,lbL00832C-WT(A4)
	MOVE.W	-12(A5),D0
	EXT.L	D0
	MOVEQ	#2,D1
	JSR	lbC00771A(PC)
	ADD.L	lbL008088-WT(A4),D0
	MOVE.W	-12(A5),D1
	EXT.L	D1
	JSR	lbC00771A(PC)
	MOVE.B	D0,lbB008082-WT(A4)
	MOVEQ	#0,D0
	MOVE.B	-9(A5),D0
	MOVEQ	#6,D1
	JSR	lbC007930(PC)
	ADD.L	lbL008068-WT(A4),D0
	MOVE.L	D0,lbL00830C-WT(A4)
	MOVE.L	lbL008324-WT(A4),D0
	ASL.L	#2,D0
	ADD.L	lbL00830C-WT(A4),D0
	MOVE.L	D0,lbL008314-WT(A4)
;	MOVE.L	-8(A5),lbL008320-WT(A4)
;	PEA	2
;	MOVE.L	lbL008320-WT(A4),-(SP)
;	JSR	lbC007B72(PC)
;	ADDQ.W	#8,SP

	move.l	D2,D0

	MOVE.L	D0,lbL00806C-WT(A4)
;	BNE.S	lbC00568A
;	MOVE.L	-$10(A5),-(SP)
;	JSR	lbC00489C(PC)
;	ADDQ.W	#4,SP
;	PEA	Samplemem.MSG(PC)
;	JSR	lbC003BDA(PC)
;	ADDQ.W	#4,SP
;lbC00568A	MOVE.L	lbL008320-WT(A4),-(SP)
;	MOVE.L	lbL00806C-WT(A4),-(SP)
;	MOVE.L	-$10(A5),-(SP)
;	JSR	lbC004804(PC)
;	LEA	12(SP),SP
;	MOVE.L	-$10(A5),-(SP)
;	JSR	lbC00489C(PC)
;	ADDQ.W	#4,SP
;	CLR.L	-$14(A5)

	moveq	#0,D3

	BRA.S	lbC0056CA

lbC0056AE	MOVEQ	#$12,D1
;	MOVE.L	-$14(A5),D0

	move.l	D3,D0

	JSR	lbC007930(PC)
	MOVEA.L	D0,A0
	ADDA.L	lbL008314-WT(A4),A0
	MOVE.L	lbL00806C-WT(A4),D2
	ADD.L	D2,12(A0)
;	ADDQ.L	#1,-$14(A5)

	addq.l	#1,D3

lbC0056CA	MOVEQ	#0,D0
	MOVE.B	-10(A5),D0
;	MOVE.L	-$14(A5),D1

	move.l	D3,D1

	CMP.L	D0,D1
	BCS.S	lbC0056AE
;	CLR.L	-$14(A5)

	moveq	#0,D3

	BRA.S	lbC0056F8

lbC0056DE	MOVEQ	#6,D1
;	MOVE.L	-$14(A5),D0

	move.l	D3,D0

	JSR	lbC007930(PC)
	MOVEA.L	lbL008318-WT(A4),A0
	ADDA.L	D0,A0
	MOVE.L	lbL00830C-WT(A4),D2
	ADD.L	D2,(A0)
;	ADDQ.L	#1,-$14(A5)

	addq.l	#1,D3

lbC0056F8	MOVEQ	#0,D0
	MOVE.B	-9(A5),D0
;	MOVE.L	-$14(A5),D1

	move.l	D3,D1

	CMP.L	D0,D1
	BCS.S	lbC0056DE
;	UNLK	A5
	RTS

;Musicfile.MSG	dc.b	'Music file',0
;Musicmem.MSG	dc.b	'Music mem',0
;Samplemem.MSG	dc.b	'Sample mem',0

;	LINK.W	A5,#0
;	MOVE.L	#$FFFFFFFF,lbB0080AC-WT(A4)
;	MOVE.L	#$FFFFFFFF,lbB0080B0-WT(A4)
;	CLR.B	lbB008084-WT(A4)
;	MOVE.W	#$780,$DFF09A
;	MOVE.W	#15,$DFF096
;	TST.L	lbL00806C-WT(A4)
;	BEQ.S	lbC005766
;	MOVE.L	lbL008320-WT(A4),-(SP)
;	MOVE.L	lbL00806C-WT(A4),-(SP)
;	JSR	lbC007BC6(PC)
;	ADDQ.W	#8,SP
;lbC005766	CLR.L	lbL00806C-WT(A4)
;	TST.L	lbL008068-WT(A4)
;	BEQ.S	lbC00577E
;	MOVE.L	lbL00831C-WT(A4),-(SP)
;	MOVE.L	lbL008068-WT(A4),-(SP)
;	JSR	lbC007BC6(PC)
;	ADDQ.W	#8,SP
;lbC00577E	CLR.L	lbL008068-WT(A4)
;	UNLK	A5
;	RTS

;	LINK.W	A5,#-4
;	MOVE.W	#$780,$DFF09A
;	MOVE.W	#$780,$DFF09C
;	PEA	$10002
;	PEA	8
;	JSR	lbC007B72(PC)
;	ADDQ.W	#8,SP
;	MOVE.L	D0,lbL008310-WT(A4)
;	MOVE.B	#2,lbB008368-WT(A4)
;	CLR.B	lbB008369-WT(A4)
;	LEA	DSCMU.MSG(PC),A0
;	MOVE.L	A0,lbL00836A-WT(A4)
;	LEA	lbB008084-WT(A4),A0
;	MOVE.L	A0,lbL00836E-WT(A4)
;	LEA	lbC005290(PC),A0
;	MOVE.L	A0,lbL008372-WT(A4)
;	JSR	lbC007B84(PC)
;	PEA	lbL008360-WT(A4)
;	PEA	5
;	JSR	lbC0079A2(PC)
;	ADDQ.W	#8,SP
;	MOVE.B	#2,lbB00837E-WT(A4)
;	CLR.B	lbB00837F-WT(A4)
;	LEA	vh1.MSG(PC),A0
;	MOVE.L	A0,lbL008380-WT(A4)
;	MOVE.L	lbL008310-WT(A4),lbL008384-WT(A4)
;	LEA	lbC005A42(PC),A0
;	MOVE.L	A0,lbL008388-WT(A4)
;	PEA	lbL008376-WT(A4)
;	PEA	7
;	JSR	lbC007C6A(PC)
;	ADDQ.W	#8,SP
;	MOVE.L	D0,lbL0082FC-WT(A4)
;	MOVE.B	#2,lbB008394-WT(A4)
;	CLR.B	lbB008395-WT(A4)
;	LEA	vh2.MSG(PC),A0
;	MOVE.L	A0,lbL008396-WT(A4)
;	MOVE.L	lbL008310-WT(A4),lbL00839A-WT(A4)
;	LEA	lbC005A90(PC),A0
;	MOVE.L	A0,lbL00839E-WT(A4)
;	PEA	lbL00838C-WT(A4)
;	PEA	8
;	JSR	lbC007C6A(PC)
;	ADDQ.W	#8,SP
;	MOVE.L	D0,lbL008300-WT(A4)
;	MOVE.B	#2,lbB0083AA-WT(A4)
;	CLR.B	lbB0083AB-WT(A4)
;	LEA	vh3.MSG(PC),A0
;	MOVE.L	A0,lbL0083AC-WT(A4)
;	MOVE.L	lbL008310-WT(A4),lbL0083B0-WT(A4)
;	LEA	lbC005ADE(PC),A0
;	MOVE.L	A0,lbL0083B4-WT(A4)
;	PEA	lbL0083A2-WT(A4)
;	PEA	9
;	JSR	lbC007C6A(PC)
;	ADDQ.W	#8,SP
;	MOVE.L	D0,lbL008304-WT(A4)
;	MOVE.B	#2,lbB0083C0-WT(A4)
;	CLR.B	lbB0083C1-WT(A4)
;	LEA	vh4.MSG(PC),A0
;	MOVE.L	A0,lbL0083C2-WT(A4)
;	MOVE.L	lbL008310-WT(A4),lbL0083C6-WT(A4)
;	LEA	lbC005B2C(PC),A0
;	MOVE.L	A0,lbL0083CA-WT(A4)
;	PEA	lbL0083B8-WT(A4)
;	PEA	10
;	JSR	lbC007C6A(PC)
;	ADDQ.W	#8,SP
;	MOVE.L	D0,lbL008308-WT(A4)
;	JSR	lbC007BA2(PC)
;	MOVEQ	#1,D0
;	UNLK	A5
;	RTS

;DSCMU.MSG	dc.b	'DSCMU',0
;vh1.MSG	dc.b	'vh1',0
;vh2.MSG	dc.b	'vh2',0
;vh3.MSG	dc.b	'vh3',0
;vh4.MSG	dc.b	'vh4',0

;	LINK.W	A5,#-4
;	PEA	lbL008360-WT(A4)
;	PEA	5
;	JSR	lbC007C40(PC)
;	ADDQ.W	#8,SP
;	MOVE.W	#15,$DFF096
;	MOVE.W	#$780,$DFF09A
;	MOVE.L	lbL0082FC-WT(A4),-(SP)
;	PEA	7
;	JSR	lbC007C6A(PC)
;	ADDQ.W	#8,SP
;	MOVE.L	lbL008300-WT(A4),-(SP)
;	PEA	8
;	JSR	lbC007C6A(PC)
;	ADDQ.W	#8,SP
;	MOVE.L	lbL008304-WT(A4),-(SP)
;	PEA	9
;	JSR	lbC007C6A(PC)
;	ADDQ.W	#8,SP
;	MOVE.L	lbL008308-WT(A4),-(SP)
;	PEA	10
;	JSR	lbC007C6A(PC)
;	ADDQ.W	#8,SP
;	PEA	8
;	MOVE.L	lbL008310-WT(A4),-(SP)
;	JSR	lbC007BC6(PC)
;	ADDQ.W	#8,SP
;	UNLK	A5
;	RTS

lbC005936
;	LINK.W	A5,#-4
	MOVEM.L	D4-D7/A2/A3,-(SP)
;	MOVE.L	8(A5),D4
;	MOVE.L	12(A5),D5
	MOVE.L	D5,D0
	ASL.L	#4,D0
	ADD.L	#$DFF0A0,D0
	MOVEA.L	D0,A2
	MOVEQ	#1,D0
	ASL.L	D5,D0
	MOVE.W	D0,D6
	MOVE.W	D6,D0
	EXT.L	D0
	ASL.L	#7,D0
	MOVE.W	D0,D7
	CMP.L	#$FF,D4
	BNE.S	lbC005970
lbC005968	MOVEM.L	(SP)+,D4-D7/A2/A3
;	UNLK	A5
	RTS

lbC005970
;	MOVE.W	D7,$DFF09A
	MOVE.W	D6,$DFF096
	MOVE.W	#1,6(A2)
	MOVE.W	D7,$DFF09C

	move.w	D7,$DFF09A

	CLR.W	10(A2)
	MOVEQ	#$12,D1
	MOVE.L	D4,D0
	JSR	lbC007930(PC)
	MOVEA.L	D0,A3
	ADDA.L	lbL008314-WT(A4),A3
	MOVE.B	$10(A3),D0
	EXT.W	D0
;	EXT.L	D0
;	MOVE.B	lbB008085-WT(A4),D1
;	EXT.W	D1
;	EXT.L	D1
;	ASR.L	D1,D0
;	MOVE.W	D0,8(A2)

	bsr.w	ChangeVolume
	bsr.w	SetVol

	MOVE.L	2(A3),D0
	ASR.L	#1,D0
	MOVE.W	D0,4(A2)
	MOVE.L	12(A3),(A2)

	bsr.w	SetAll

	MOVEQ	#0,D0
	MOVE.W	10(A3),D0
	ADDQ.L	#1,D0
	MOVE.L	D5,D1
	ASL.L	#1,D1
	LEA	lbW00808C-WT(A4),A0
	MOVE.W	D0,0(A0,D1.L)
	TST.W	10(A3)
	BEQ.S	lbC005A08
;	MOVE.L	6(A3),-4(A5)

	move.l	6(A3),D3

	MOVE.L	2(A3),D0
;	SUB.L	-4(A5),D0

	sub.l	D3,D0

	ASR.L	#1,D0
	MOVE.L	D5,D1
	ASL.L	#1,D1
	LEA	lbW008094-WT(A4),A0
	MOVE.W	D0,0(A0,D1.L)
	MOVEA.L	12(A3),A0
;	ADDA.L	-4(A5),A0

	add.l	D3,A0

	MOVE.L	D5,D0
	ASL.L	#2,D0
	LEA	lbL00809C-WT(A4),A1
	MOVE.L	A0,0(A1,D0.L)
lbC005A08	MOVE.W	$DFF01E,D0
	AND.W	D7,D0
	BNE.S	lbC005A14
	BRA.S	lbC005A08

lbC005A14	MOVE.W	(A3),6(A2)
	MOVE.W	D6,D0
	EXT.L	D0
	BSET	#15,D0
	MOVE.W	D0,$DFF096
	MOVE.W	D7,$DFF09C
	MOVE.W	D7,D0
	EXT.L	D0
	BSET	#15,D0
	MOVE.W	D0,$DFF09A
	BRA.L	lbC005968

Audio0
	move.l	A4,-(SP)
	move.b	6(A0),D0
.line	cmp.b	6(A0),D0
	beq.s	.line
.wait	cmp.b	#$16,7(A0)
	bcs.b	.wait
	move.w	$1C(A0),D0
	and.w	$1E(A0),D0
	btst	#7,D0
	beq.b	Out0
	lea	WT(PC),A4

;	LINK.W	A5,#0
;lbC005A42	JSR	lbC006D56(PC)
	TST.W	lbW00808C-WT(A4)
	BEQ.S	lbC005A80
	SUBQ.W	#1,lbW00808C-WT(A4)
	BNE.S	lbC005A62
;	MOVE.L	A1,$DFF0A0
;	MOVE.W	#2,$DFF0A4

	move.l	A1,$A0(A0)
	move.w	#2,$A4(A0)

	BRA.S	lbC005A72

lbC005A62
;	MOVE.W	lbW008094-WT(A4),$DFF0A4
;	MOVE.L	lbL00809C-WT(A4),$DFF0A0

	move.w	lbW008094-WT(A4),$A4(A0)
	move.l	lbL00809C-WT(A4),$A0(A0)

lbC005A72
;	MOVE.W	#$80,$DFF09C
;	JSR	lbC006D64(PC)

	move.w	#$80,$9C(A0)
	move.l	(SP)+,A4
Out0
	RTS

lbC005A80
;	MOVE.W	#$80,$DFF09A

	move.w	#$80,$9A(A0)

	MOVE.B	#$FF,lbB0080AC-WT(A4)
	BRA.S	lbC005A72

Audio1
	move.l	A4,-(SP)
	move.b	6(A0),D0
.line	cmp.b	6(A0),D0
	beq.s	.line
.wait	cmp.b	#$16,7(A0)
	bcs.b	.wait
	move.w	$1C(A0),D0
	and.w	$1E(A0),D0
	btst	#8,D0
	beq.b	Out1
	lea	WT(PC),A4

;lbC005A90	JSR	lbC006D56(PC)
	TST.W	lbW00808E-WT(A4)
	BEQ.S	lbC005ACE
	SUBQ.W	#1,lbW00808E-WT(A4)
	BNE.S	lbC005AB0
;	MOVE.L	A1,$DFF0B0
;	MOVE.W	#2,$DFF0B4

	move.l	A1,$B0(A0)
	move.w	#2,$B4(A0)

	BRA.S	lbC005AC0

lbC005AB0
;	MOVE.W	lbW008096-WT(A4),$DFF0B4
;	MOVE.L	lbL0080A0-WT(A4),$DFF0B0

	move.w	lbW008096-WT(A4),$B4(A0)
	move.l	lbL0080A0-WT(A4),$B0(A0)

lbC005AC0
;	MOVE.W	#$100,$DFF09C
;	JSR	lbC006D64(PC)

	move.w	#$100,$9C(A0)
	move.l	(SP)+,A4
Out1
	RTS

lbC005ACE
;	MOVE.W	#$100,$DFF09A

	move.w	#$100,$9A(A0)

	MOVE.B	#$FF,lbB0080AD-WT(A4)
	BRA.S	lbC005AC0

Audio2
	move.l	A4,-(SP)
	move.b	6(A0),D0
.line	cmp.b	6(A0),D0
	beq.s	.line
.wait	cmp.b	#$16,7(A0)
	bcs.b	.wait
	move.w	$1C(A0),D0
	and.w	$1E(A0),D0
	btst	#9,D0
	beq.b	Out2
	lea	WT(PC),A4

;lbC005ADE	JSR	lbC006D56(PC)
	TST.W	lbW008090-WT(A4)
	BEQ.S	lbC005B1C
	SUBQ.W	#1,lbW008090-WT(A4)
	BNE.S	lbC005AFE
;	MOVE.L	A1,$DFF0C0
;	MOVE.W	#2,$DFF0C4

	move.l	A1,$C0(A0)
	move.w	#2,$C4(A0)

	BRA.S	lbC005B0E

lbC005AFE
;	MOVE.W	lbW008098-WT(A4),$DFF0C4
;	MOVE.L	lbL0080A4-WT(A4),$DFF0C0

	move.w	lbW008098-WT(A4),$C4(A0)
	move.l	lbL0080A4-WT(A4),$C0(A0)

lbC005B0E
;	MOVE.W	#$200,$DFF09C
;	JSR	lbC006D64(PC)

	move.w	#$200,$9C(A0)
	move.l	(SP)+,A4
Out2
	RTS

lbC005B1C
;	MOVE.W	#$200,$DFF09A

	move.w	#$200,$9A(A0)

	MOVE.B	#$FF,lbB0080AE-WT(A4)
	BRA.S	lbC005B0E

Audio3
	move.l	A4,-(SP)
	move.b	6(A0),D0
.line	cmp.b	6(A0),D0
	beq.s	.line
.wait	cmp.b	#$16,7(A0)
	bcs.b	.wait
	move.w	$1C(A0),D0
	and.w	$1E(A0),D0
	btst	#10,D0
	beq.b	Out3
	lea	WT(PC),A4

;lbC005B2C	JSR	lbC006D56(PC)
	TST.W	lbW008092-WT(A4)
	BEQ.S	lbC005B6A
	SUBQ.W	#1,lbW008092-WT(A4)
	BNE.S	lbC005B4C
;	MOVE.L	A1,$DFF0D0
;	MOVE.W	#2,$DFF0D4

	move.l	A1,$D0(A0)
	move.w	#2,$D4(A0)

	BRA.S	lbC005B5C

lbC005B4C
;	MOVE.W	lbW00809A-WT(A4),$DFF0D4
;	MOVE.L	lbL0080A8-WT(A4),$DFF0D0

	move.w	lbW00809A-WT(A4),$D4(A0)
	move.l	lbL0080A8-WT(A4),$D0(A0)

lbC005B5C
;	MOVE.W	#$400,$DFF09C
;	JSR	lbC006D64(PC)

	move.w	#$400,$9C(A0)
	move.l	(SP)+,A4
Out3
	RTS

lbC005B6A
;	MOVE.W	#$400,$DFF09A

	move.w	#$400,$9A(A0)

	MOVE.B	#$FF,lbB0080AF-WT(A4)
	BRA.S	lbC005B5C

;	UNLK	A5
;	RTS

lbC00771A	MOVEM.L	D1/D4,-(SP)
	CLR.L	D4
	TST.L	D0
	BPL.S	lbC007728
	NEG.L	D0
	ADDQ.W	#1,D4
lbC007728	TST.L	D1
	BPL.S	lbC007732
	NEG.L	D1
	EORI.W	#1,D4
lbC007732	BSR.S	lbC007772
	TST.W	D4
	BEQ.S	lbC00773A
	NEG.L	D0
lbC00773A	MOVEM.L	(SP)+,D1/D4
	TST.L	D0
	RTS


lbC007772	MOVEM.L	D2/D3,-(SP)
	SWAP	D1
	TST.W	D1
	BNE.S	lbC00779C
	SWAP	D1
	MOVE.W	D1,D3
	MOVE.W	D0,D2
	CLR.W	D0
	SWAP	D0
	DIVU.W	D3,D0
	MOVE.L	D0,D1
	SWAP	D0
	MOVE.W	D2,D1
	DIVU.W	D3,D1
	MOVE.W	D1,D0
	CLR.W	D1
	SWAP	D1
	MOVEM.L	(SP)+,D2/D3
	RTS

lbC00779C	SWAP	D1
	MOVE.L	D1,D3
	MOVE.L	D0,D1
	CLR.W	D1
	SWAP	D1
	SWAP	D0
	CLR.W	D0
	MOVEQ	#15,D2
lbC0077AC	ADD.L	D0,D0
	ADDX.L	D1,D1
	CMP.L	D1,D3
	BHI.S	lbC0077B8
	SUB.L	D3,D1
	ADDQ.W	#1,D0
lbC0077B8	DBRA	D2,lbC0077AC
	MOVEM.L	(SP)+,D2/D3
	RTS

lbC007930	MOVEM.L	D1-D3,-(SP)
	MOVE.W	D1,D2
	MULU.W	D0,D2
	MOVE.L	D1,D3
	SWAP	D3
	MULU.W	D0,D3
	SWAP	D3
	CLR.W	D3
	ADD.L	D3,D2
	SWAP	D0
	MULU.W	D1,D0
	SWAP	D0
	CLR.W	D0
	ADD.L	D2,D0
	MOVEM.L	(SP)+,D1-D3
	RTS

WT
V1Temp
	dc.l	0
V2Temp
	dc.l	0
V3Temp
	dc.l	0
V4Temp
	dc.l	0

;lbB008056	dc.b	1
;	dc.b	0
;	dc.b	0
;	dc.b	0
;	dc.b	0
;	dc.b	0
;	dc.b	0
;	dc.b	0
;	dc.b	0
;	dc.b	0
;	dc.b	0
;	dc.b	0
;	dc.b	0
;	dc.b	0
;	dc.b	0
;	dc.b	0
;	dc.b	0
;	dc.b	0
lbL008068	dc.l	0
lbL00806C	dc.l	0
;	dc.w	$FF00
lbL008072	dc.l	0
lbL008076	dc.l	0
lbL00807A	dc.l	0
lbL00807E	dc.l	0
lbB008082	dc.b	1
lbB008083	dc.b	1
;lbB008084	dc.b	0
;lbB008085	dc.b	0
;lbB008086	dc.b	0
;	dc.b	0
lbL008088	dc.l	$5DC
lbW00808C	dc.w	0
lbW00808E	dc.w	0
lbW008090	dc.w	0
lbW008092	dc.w	0
lbW008094	dc.w	0
lbW008096	dc.w	0
lbW008098	dc.w	0
lbW00809A	dc.w	0
lbL00809C	dc.l	0
lbL0080A0	dc.l	0
lbL0080A4	dc.l	0
lbL0080A8	dc.l	0
lbB0080AC	dc.b	$FF
lbB0080AD	dc.b	$FF
lbB0080AE	dc.b	$FF
lbB0080AF	dc.b	$FF
lbB0080B0	dc.b	$FF
lbB0080B1	dc.b	$FF
lbB0080B2	dc.b	$FF
lbB0080B3	dc.b	$FF

lbL00830C	dc.l	0
;lbL008310	dc.l	0
lbL008314	dc.l	0
lbL008318	dc.l	0
;lbL00831C	dc.l	0
;lbL008320	dc.l	0
lbL008324	dc.l	0
lbL008328	dc.l	0
lbL00832C	dc.l	0
lbL008330	dc.l	0

	Section	Empty,BSS_C
Empty
	ds.b	4

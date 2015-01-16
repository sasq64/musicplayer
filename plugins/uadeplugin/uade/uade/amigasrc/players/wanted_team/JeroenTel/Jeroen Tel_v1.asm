	*****************************************************
	****    Jeroen Tel replayer for EaglePlayer,     ****
	****        all adaptions by Wanted Team	 ****
	****     DeliTracker compatible (?) version	 ****
	*****************************************************

	incdir	"dh2:include/"
	include 'misc/eagleplayer2.01.i'

	SECTION	Player_Code,CODE

	PLAYERHEADER Tags

	dc.b	'$VER: Jeroen Tel player module V1.0 (27 Oct 2004)',0
	even
Tags
	dc.l	DTP_PlayerVersion,1
	dc.l	EP_PlayerVersion,9
	dc.l	DTP_RequestDTVersion,DELIVERSION
	dc.l	DTP_PlayerName,PlayerName
	dc.l	DTP_Creator,Creator
	dc.l	DTP_Check2,Check2
	dc.l	DTP_SubSongRange,SubSongRange
	dc.l	DTP_InitPlayer,InitPlayer
	dc.l	DTP_EndPlayer,EndPlayer
	dc.l	DTP_InitSound,InitSound
	dc.l	DTP_EndSound,EndSound
	dc.l	DTP_Interrupt,Interrupt
	dc.l	DTP_Volume,SetVolume
	dc.l	DTP_Balance,SetBalance
	dc.l	EP_Voices,SetVoices
	dc.l	EP_Get_ModuleInfo,GetInfos
	dc.l	EP_StructInit,StructInit
	dc.l	EP_SampleInit,SampleInit
	dc.l	EP_GetPositionNr,GetPosition
	dc.l	EP_Flags,EPB_Volume!EPB_Balance!EPB_ModuleInfo!EPB_Voices!EPB_SampleInfo!EPB_Songend!EPB_Analyzer!EPB_NextSong!EPB_PrevSong!EPB_Packable!EPB_Restart
	dc.l	0

PlayerName
	dc.b	'Jeroen Tel',0
Creator
	dc.b	'(c) 1989-90 by Jeroen Tel & Charles',10
	dc.b	'Deenen, adapted by Wanted Team',0
Prefix
	dc.b	'JT.',0
	even
ModulePtr
	dc.l	0
EagleBase
	dc.l	0
lbW00115C
	dc.l	0
Origin
	dc.l	0
RepeatVal1
	dc.b	0
RepeatVal2
	dc.b	0
RepeatVal3
	dc.b	0
RepeatVal4
	dc.b	0
lbL000670
	dc.l	0
lbL0011AC
	dc.l	0
lbL0016CA
	dc.l	0
lbL000596
	dc.l	0
Infos
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
**************************** EP_GetPositionNr *****************************
***************************************************************************

GetPosition
	moveq	#0,D0
	move.b	lbB0005C1(PC),D0
	rts

***************************************************************************
***************************** DTP_EndPlayer *******************************
***************************************************************************

EndPlayer
	movea.l	dtg_AudioFree(A5),A0
	jmp	(A0)

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
***************************** EP_Get_ModuleInfo ***************************
***************************************************************************

GetInfos	
	lea	InfoBuffer(PC),A0
	rts

SubSongs	=	4
LoadSize	=	12
SongSize	=	20
SamplesSize	=	28
Samples		=	36
CalcSize	=	44
Length		=	52
Special		=	60

InfoBuffer
	dc.l	MI_SubSongs,0		;4
	dc.l	MI_LoadSize,0		;12
	dc.l	MI_Songsize,0		;20
	dc.l	MI_SamplesSize,0	;28
	dc.l	MI_Samples,0		;36
	dc.l	MI_Calcsize,0		;44
	dc.l	MI_Length,0		;52
	dc.l	MI_SpecialInfo,0	;60
	dc.l	MI_Prefix,Prefix
	dc.l	0

***************************************************************************
******************************* EP_SampleInit *****************************
***************************************************************************

SampleInit
	moveq	#EPR_NotEnoughMem,D7
	lea	EPG_SampleInfoStructure(A5),A3
	move.l	lbL0011AC(PC),D0
	beq.b	return
	move.l	D0,A2

	move.l	Infos(PC),D5
	beq.b	return
	subq.l	#1,D5
Hop
	jsr	ENPP_AllocSampleStruct(A5)
	move.l	D0,(A3)
	beq.b	return
	move.l	D0,A3

	move.l	(A2)+,A1
	sub.l	Origin(PC),A1
	add.l	ModulePtr(PC),A1
	moveq	#0,D0
	move.w	2(A1),D0
	lsl.l	#1,D0
	move.l	4(A1),A1
	sub.l	Origin(PC),A1
	add.l	ModulePtr(PC),A1
	move.l	A1,EPS_Adr(A3)			; sample address
	move.l	D0,EPS_Length(A3)		; sample length
	move.l	#64,EPS_Volume(A3)
	move.w	#USITY_RAW,EPS_Type(A3)
	move.w	#USIB_Playable!USIB_Saveable!USIB_8BIT,EPS_Flags(A3)
	dbf	D5,Hop

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
******************************* DTP_Check2 ********************************
***************************************************************************

Check2
	movea.l	dtg_ChkData(A5),A0
	moveq	#-1,D0
	cmp.l	#1700,dtg_ChkSize(A5)
	ble.b	Fault

	lea	40(A0),A1
Check
	cmp.l	#$02390001,(A0)
	beq.b	More
	addq.l	#2,A0
	cmp.l	A0,A1
	bne.b	Check
	rts
More
	addq.l	#8,A0
	cmp.b	#$66,(A0)+
	bne.b	Fault
	move.b	(A0)+,D1
	bmi.b	Fault
	beq.b	Fault
	cmp.w	#$4E75,(A0)
	bne.b	Fault
	ext.w	D1
	add.w	D1,A0
	cmp.w	#$4A39,(A0)
	bne.b	NoOne
	moveq	#3,D1
NextOne
	cmp.w	#$4A39,(A0)
	bne.b	Fault
	lea	18(A0),A0
	dbf	D1,NextOne
NoOne
	cmp.l	#$78001839,(A0)
	bne.b	Fault
	moveq	#0,D0
Fault
	rts

***************************************************************************
***************************** DTP_SubSongRange ****************************
***************************************************************************

SubSongRange
	moveq 	#0,D0
	move.l	InfoBuffer+SubSongs(PC),D1
	subq.l	#1,D1
	rts

***************************************************************************
***************************** DTP_InitPlayer ******************************
***************************************************************************

InitPlayer
	moveq	#0,D0
	move.l	dtg_GetListData(A5),A0		; Function
	jsr	(A0)

	lea	ModulePtr(PC),A4
	move.l	A0,(A4)+
	move.l	A5,(A4)+			; EagleBase

	lea	InfoBuffer(PC),A6
	move.l	D0,LoadSize(A6)

	move.l	A0,A1
Find1
	cmp.l	#$1400E302,(A1)
	beq.b	OK1
	addq.l	#2,A1
	bra.b	Find1
OK1
	move.l	6(A1),D7

Find2
	cmp.l	#$03580328,(A1)
	beq.b	OK2
	addq.l	#2,A1
	bra.b	Find2
OK2
	move.l	A1,(A4)+
	sub.l	A0,A1
	sub.l	A1,D7				; Origin
	move.l	D7,(A4)+
	move.l	A0,D6

	move.l	A0,A1

FindR
	cmp.l	#$B23C00FF,(A1)
	beq.b	OKR
	cmp.l	#$0C0100FF,(A1)
	beq.b	OKR
	addq.l	#2,A1
	bra.b	FindR
OKR
	clr.l	(A4)
	cmp.w	#$13FC,6(A1)
	bne.b	NoRep
	move.b	9(A1),(A4)
	move.b	17(A1),1(A4)
	move.b	25(A1),2(A4)
	move.b	33(A1),3(A4)
NoRep
	addq.l	#4,A4
Find3
	cmp.w	#$267C,(A1)+
	bne.b	Find3
	move.l	(A1)+,D0
	sub.l	D7,D0
	add.l	D6,D0
	move.l	D0,(A4)+

Find4
	cmp.w	#$49F9,(A1)+
	bne.b	Find4
	move.l	(A1)+,D0
	sub.l	D7,D0
	add.l	D6,D0
	move.l	D0,(A4)+			; SamplesInfo
	move.l	D0,A2

Find5
	cmp.l	#$0026267C,(A1)
	beq.b	OK3
	addq.l	#2,A1
	bra.b	Find5
OK3
	addq.l	#4,A1
	move.l	(A1)+,D0
	sub.l	D7,D0
	add.l	D6,D0
	move.l	D0,(A4)+

Find6
	cmp.w	#$23F4,(A1)+
	bne.b	Find6

	move.l	-6(A1),D0
	sub.l	D7,D0
	add.l	D6,D0
	move.l	D0,(A4)+			; subsongs ptr

	move.l	D0,A1
	moveq	#0,D0
CheckSongs
	cmp.b	#12,16(A1)
	bne.b	NoMore
	move.l	(A1),D1
	cmp.l	4(A1),D1
	bne.b	AddSong
	cmp.l	8(A1),D1
	bne.b	AddSong
	cmp.l	12(A1),D1
	beq.b	NoMore
AddSong
	addq.l	#1,D0
	lea	18(A1),A1
	bra.b	CheckSongs
NoMore
	move.l	D0,SubSongs(A6)

	move.l	(A2)+,A3
	sub.l	D7,A3
	add.l	D6,A3
	move.l	A3,D2
	sub.l	A2,D2
	lsr.l	#2,D2
	move.l	D2,(A4)				; Infos

	moveq	#0,D1
	move.w	2(A3),D1
	add.l	D1,D1
	move.l	4(A3),D0
	add.l	D0,D1
	moveq	#1,D2
NextInfo
	move.l	(A2)+,A1
	sub.l	D7,A1
	add.l	D6,A1
	move.l	4(A1),D3
	beq.b	NoSamp
	moveq	#0,D4
	move.w	2(A1),D4
	add.l	D4,D4
	add.l	D3,D4
	cmp.l	D3,D0
	ble.b	NoMin
	move.l	D3,D0
NoMin
	cmp.l	D4,D1
	bge.b	NoMax
	move.l	D4,D1
NoMax
	addq.l	#1,D2
NoSamp
	cmp.l	A2,A3
	bne.b	NextInfo

	sub.l	D7,D0
	sub.l	D7,D1
	move.l	D0,SongSize(A6)
	move.l	D1,CalcSize(A6)
	move.l	D2,Samples(A6)
	sub.l	D0,D1
	move.l	D1,SamplesSize(A6)

	moveq	#0,D0
FindRTS
	cmp.w	#$4E75,(A0)+
	bne.b	FindRTS
	cmp.b	#2,-3(A0)
	beq.b	NoText

	move.b	-3(A0),D1
	ext.w	D1
	clr.b	-2(A0,D1.W)
	move.l	A0,D0
NoText
	move.l	D0,Special(A6)

	move.l	dtg_AudioAlloc(A5),A0
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
	lea	WT(PC),A6
	move.l	A6,A0
	lea	lbL000660(PC),A1
Clear
	clr.w	(A0)+
	cmp.l	A0,A1
	bne.b	Clear
	move.w	#1,lbW0005D2+2-WT(A6)
	move.w	#$8001,lbW0005D2+4-WT(A6)
	move.w	#2,lbW0005FA+2-WT(A6)
	move.w	#$8002,lbW0005FA+4-WT(A6)
	move.w	#4,lbW000622+2-WT(A6)
	move.w	#$8004,lbW000622+4-WT(A6)
	move.w	#8,lbW00064A+2-WT(A6)
	move.w	#$8008,lbW00064A+4-WT(A6)
	move.w	#$1000,lbL0005EE+2-WT(A6)
	move.w	#$2000,lbL000616+2-WT(A6)
	move.w	#$3000,lbL00063E+2-WT(A6)
	move.w	dtg_SndNum(A5),D0
	mulu.w	#18,D0
	bsr.w	Init
	moveq	#0,D0
FindFF
	addq.l	#1,D0
	cmp.b	#$FE,(A1)
	beq.b	StopPos
	cmp.b	#$FF,(A1)+
	bne.b	FindFF
StopPos
	lea	InfoBuffer(PC),A1
	move.l	D0,Length(A1)
	moveq	#3,D1
	lea	Fix,A0
	lea	lbL000660(PC),A1
FixUp
	move.l	(A1)+,A2
	move.l	A0,$18(A2)
	dbf	D1,FixUp
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

	lea	WT(PC),A6
	moveq	#0,D3
	bsr.w	Play_1
	bsr.b	DMAWait
	bsr.w	Play_2

	lea	StructAdr(PC),A0
	clr.w	UPS_Enabled(A0)
	movem.l	(A7)+,D1-A6
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
	tst.w	D3
	beq.s	Left1
	cmp.w	#$10,D3
	beq.s	Right1
	cmp.w	#$20,D3
	beq.s	Right2
	cmp.w	#$30,D3
	bne.s	Exit
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
Exit
	rts

*------------------------------- Set Vol -------------------------------*

SetVol
	move.l	A0,-(A7)
	lea	StructAdr+UPS_Voice1Vol(PC),A0
	tst.b	8(A5)
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice2Vol(PC),A0
	cmp.b	#$10,8(A5)
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice3Vol(PC),A0
	cmp.b	#$20,8(A5)
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice4Vol(PC),A0
.SetVoice
	move.w	D0,(A0)
	move.l	(A7)+,A0
	rts

*------------------------------ Set Adr/Len -----------------------------*

SetTwo
	move.l	A0,-(A7)
	lea	StructAdr+UPS_Voice1Adr(PC),A0
	tst.b	8(A5)
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice2Adr(PC),A0
	cmp.b	#$10,8(A5)
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice3Adr(PC),A0
	cmp.b	#$20,8(A5)
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice4Adr(PC),A0
.SetVoice
	move.l	D7,(A0)
	move.w	2(A4),UPS_Voice1Len(A0)
	move.l	(A7)+,A0
	rts

*------------------------------- Set Per -------------------------------*

SetPer
	move.l	A0,-(A7)
	lea	StructAdr+UPS_Voice1Per(PC),A0
	tst.b	8(A5)
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice2Per(PC),A0
	cmp.b	#$10,8(A5)
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice3Per(PC),A0
	cmp.b	#$20,8(A5)
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice4Per(PC),A0
.SetVoice
	move.w	14(A5),(A0)
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
************************** Jeroen Tel - MON player ************************
***************************************************************************

; A few (size) optimized player from "Unreal" (title tune)

;	BRA.L	lbC00048E

;	BRA.L	lbC00044A
Play_1
	ANDI.B	#1,lbB0005BE-WT(A6)
	BNE.S	lbC000014
	RTS

lbC000014	MOVEQ	#0,D4
	MOVE.B	lbB0005BD-WT(A6),D4
	SUBQ.B	#1,lbB0005BB-WT(A6)
	CMPI.B	#$FE,lbB0005BB-WT(A6)
	BNE.S	lbC000036
	MOVE.B	lbB0005BC-WT(A6),lbB0005BB-WT(A6)
lbC000036	MOVEA.L	#lbL000660,A5
	MOVEA.L	0(A5,D4.W),A5
	CMPI.B	#$FF,lbB0005BB-WT(A6)
	BEQ.S	lbC000068
	CMPI.B	#0,lbB0005BB-WT(A6)
	BEQ.S	lbC000058
	BRA.L	lbC000238

lbC000058	SUBQ.B	#1,0(A5)
	BPL.L	lbC000238
	CLR.B	6(A5)
	BRA.L	lbC000238

lbC000068	CMPI.B	#$FF,0(A5)
	BNE.L	lbC000238
	MOVEA.L	$1C(A5),A3
	MOVEQ	#0,D0
lbC000078	MOVE.B	1(A5),D0
	MOVEQ	#0,D1
	MOVE.B	0(A3,D0.W),D1
	CMP.B	#$FF,D1
	BNE.S	lbC0000B4

	bsr.w	SongEnd

;	MOVE.B	#0,lbB0005C1
;	MOVE.B	#0,lbB0005E9
;	MOVE.B	#0,lbB000611
;	MOVE.B	#0,lbB000639

	move.b	RepeatVal1-WT(A6),lbB0005C1-WT(A6)
	move.b	RepeatVal2-WT(A6),lbB0005E9-WT(A6)
	move.b	RepeatVal3-WT(A6),lbB000611-WT(A6)
	move.b	RepeatVal4-WT(A6),lbB000639-WT(A6)

	MOVE.B	1(A5),D0
	MOVE.B	0(A3,D0.W),D1
	BRA.L	lbC0000C0

lbC0000B4	CMP.B	#$FE,D1
	BNE.S	lbC0000C0
	JMP	lbC000586

lbC0000C0	CMP.B	#$7F,D1
	BLS.S	lbC0000D6
	MOVE.B	D1,$27(A5)
	SUBI.B	#$C0,$27(A5)
	ADDQ.B	#1,1(A5)
	BRA.S	lbC000078

lbC0000D6
;	MOVEA.L	#lbL000670,A3

	move.l	lbL000670-WT(A6),A3

	ASL.W	#2,D1
	MOVEA.L	0(A3,D1.W),A3

	sub.l	Origin(PC),A3
	add.l	ModulePtr(PC),A3

	MOVE.B	2(A5),D0
	MOVE.B	0(A3,D0.W),0(A5)
	ANDI.B	#$1F,0(A5)
	MOVE.B	0(A3,D0.W),D3
	MOVE.B	D3,lbB0005BA-WT(A6)
	ANDI.B	#$20,lbB0005BA-WT(A6)
	CMP.B	#$DF,D3
	BLS.S	lbC00011E
	MOVE.B	1(A3,D0.W),$26(A5)
	ADDQ.B	#1,D0
	MOVE.B	0(A3,D0.W),D3
	MOVE.B	#0,lbB0005BA-WT(A6)
lbC00011E	CMP.B	#$BF,D3
	BLS.S	lbC00013E
	ADDQ.B	#1,2(A5)
	CMPI.B	#$FF,1(A3,D0.W)
	BNE.L	lbC000238
	CLR.B	2(A5)
	ADDQ.B	#1,1(A5)
	BRA.L	lbC000238

lbC00013E	ANDI.B	#$C0,D3
	BMI.S	lbC000162
	BEQ.S	lbC00019C
	CLR.W	10(A5)
	MOVE.B	1(A3,D0.W),11(A5)
	ADDQ.B	#2,D0
	MOVE.B	0(A3,D0.W),4(A5)
	MOVE.B	$27(A5),D1
	ADD.B	D1,4(A5)
	BRA.S	lbC0001A0

lbC000162	ADDQ.B	#1,D0
	MOVEQ	#0,D1
	MOVE.B	0(A3,D0.W),D1
	ASL.W	#2,D1
;	LEA	lbL0011AC,A4
;	MOVE.L	0(A4,D1.W),$18(A5)
;	MOVEA.L	$18(A5),A4

	move.l	lbL0011AC-WT(A6),A4
	move.l	0(A4,D1.W),A4
	sub.l	Origin(PC),A4
	add.l	ModulePtr(PC),A4
	move.l	A4,$18(A5)

	MOVE.B	$1C(A4),$26(A5)
	MOVEQ	#0,D1
	MOVE.B	1(A3,D0.W),D1
	BPL.S	lbC00019C
	ADDQ.B	#1,D0
	ANDI.B	#$7F,D1
	MOVE.B	D1,$26(A5)
	MOVE.B	#0,lbB0005BA-WT(A6)
lbC00019C	CLR.W	10(A5)
lbC0001A0	ADDQ.B	#1,D0
	MOVE.B	0(A3,D0.W),3(A5)
	MOVE.B	$27(A5),D1
	ADD.B	D1,3(A5)
	CMPI.B	#$FF,1(A3,D0.W)
	BNE.S	lbC0001C2
	CLR.B	2(A5)
	ADDQ.B	#1,1(A5)
	BRA.S	lbC0001C8

lbC0001C2	ADDQ.B	#1,D0
	MOVE.B	D0,2(A5)
lbC0001C8	ANDI.B	#$20,lbB0005BA-WT(A6)
	BEQ.S	lbC0001E6
	MOVE.B	#2,5(A5)
	MOVEA.L	$18(A5),A3
	MOVE.W	$12(A3),$12(A5)
	BRA.L	lbC000378

lbC0001E6	MOVE.W	$14(A5),$DFF096
	CLR.W	$12(A5)
	CLR.B	5(A5)
	CLR.W	$10(A5)
	CLR.L	$22(A5)
	MOVE.B	#1,$20(A5)
	MOVEA.L	$18(A5),A4
	MOVE.W	$18(A4),12(A5)
	LSR.W	12(A5)
	MOVE.B	#1,7(A5)
	MOVE.B	8(A5),D3
	MOVEA.L	#$DFF0A0,A3
;	MOVE.L	4(A4),0(A3,D3.W)			; address

	move.l	4(A4),D7
	sub.l	Origin(PC),D7
	add.l	ModulePtr(PC),D7
	move.l	D7,0(A3,D3.W)

	MOVE.W	2(A4),4(A3,D3.W)			; length

	bsr.w	SetTwo

	MOVE.B	#1,6(A5)
	BRA.L	lbC000392

lbC000238	MOVEQ	#0,D0
	MOVEA.L	$18(A5),A3
	MOVE.W	$20(A3),D0
	BEQ.S	lbC00027E
	MOVE.W	lbW0005D0-WT(A6),D0
	ANDI.W	#1,D0
	BEQ.L	lbC00027E
	MOVEA.L	4(A3),A4

	sub.l	Origin(PC),A4
	add.l	ModulePtr(PC),A4

	ADDA.L	$22(A5),A4
	MOVE.B	8(A5),D0
	MOVEA.L	#$DFF0A0,A3
	MOVE.L	A4,0(A3,D0.W)				; address
	ADDQ.L	#1,$22(A5)
	CMPI.L	#$20,$22(A5)
	BLS.S	lbC00027E
	MOVE.L	#0,$22(A5)
lbC00027E	MOVEA.L	$18(A5),A3
	MOVEQ	#0,D0
	MOVE.W	$1E(A3),D0
	BEQ.L	lbC00029E
	CMP.W	$10(A5),D0
	BGT.S	lbC00029E
	MOVE.B	#2,5(A5)
	MOVE.B	#0,6(A5)
lbC00029E	ADDQ.W	#1,$10(A5)
	CMPI.W	#1,$10(A5)
	BNE.S	lbC0002C6
	MOVEA.L	$18(A5),A3
	LEA	$DFF0A0,A4
	MOVEQ	#0,D3
	MOVE.B	8(A5),D3
;	MOVE.L	8(A3),0(A4,D3.W)			; address

	move.l	8(A3),D7
	bne.b	NoZero
	move.l	#Fix,D7
	bra.b	SkipZero
NoZero
	sub.l	Origin(PC),D7
	add.l	ModulePtr(PC),D7
SkipZero
	move.l	D7,0(A4,D3.W)

	MOVE.W	12(A3),4(A4,D3.W)			; length
lbC0002C6	CMPI.W	#0,10(A5)
	BNE.S	lbC00032E
	MOVEA.L	$18(A5),A3
	MOVE.W	$10(A5),D1
	MOVE.B	3(A5),D2
	BTST	#7,3(A5)
	BNE.S	lbC0002F4
	CMPI.W	#0,$16(A3)
	BEQ.L	lbC000378
	CMP.W	$16(A3),D1
	BLS.L	lbC000378
lbC0002F4	MOVE.W	$18(A3),D2
	MOVE.W	$1A(A3),D3
	CMPI.B	#0,7(A5)
	BEQ.S	lbC000318
	ADD.W	D3,14(A5)
	SUBQ.W	#1,12(A5)
	BPL.S	lbC000378
	CLR.B	7(A5)
	MOVE.W	D2,12(A5)
	BRA.S	lbC000378

lbC000318	SUB.W	D3,14(A5)
	SUBQ.W	#1,12(A5)
	BPL.S	lbC000378
	MOVE.B	#1,7(A5)
	MOVE.W	D2,12(A5)
	BRA.S	lbC000378

lbC00032E	MOVEQ	#0,D0
	MOVEQ	#0,D2
	MOVE.B	4(A5),D0
	ANDI.B	#$7F,D0
	MOVE.W	10(A5),D1
	MOVE.B	D0,D2
	ASL.B	#1,D2
;	MOVEA.L	#lbW00115C,A3

	move.l	lbW00115C-WT(A6),A3
	cmp.w	#72,D2
	blt.b	PerOk1
	moveq	#70,D2
PerOk1
	MOVE.W	0(A3,D2.W),D2
	CMP.B	3(A5),D0
	BGE.S	lbC000366
	ADD.W	D1,14(A5)
	CMP.W	14(A5),D2
	BGE.S	lbC000378
	MOVE.W	D2,14(A5)
	CLR.W	10(A5)
	BRA.S	lbC000378

lbC000366	SUB.W	D1,14(A5)
	CMP.W	14(A5),D2
	BLT.S	lbC000378
	MOVE.W	D2,14(A5)
	CLR.W	10(A5)
lbC000378	ANDI.B	#1,6(A5)
	BEQ.S	lbC0003E0
	MOVE.W	$10(A5),D1
	ANDI.W	#1,D1
	BNE.S	lbC0003F2
	CMPI.B	#0,5(A5)
	BNE.S	lbC0003B2
lbC000392	MOVEA.L	$18(A5),A3
	MOVE.W	14(A3),D0
	ADD.W	D0,$12(A5)
	MOVE.W	$12(A5),D1
	CMP.W	(A3),D1
	BLS.S	lbC0003F2
	MOVE.W	(A3),$12(A5)
	MOVE.B	#1,5(A5)
	BRA.S	lbC0003F2

lbC0003B2	CMPI.B	#2,5(A5)
	BEQ.S	lbC0003F2
	MOVEA.L	$18(A5),A3
	MOVE.W	$10(A3),D0
	SUB.W	D0,$12(A5)
	BMI.S	lbC0003D2
	MOVE.W	$12(A5),D1
	CMP.W	$12(A3),D1
	BGE.S	lbC0003F2
lbC0003D2	MOVE.W	$12(A3),$12(A5)
	MOVE.B	#2,5(A5)
	BRA.S	lbC0003F2

lbC0003E0	MOVEA.L	$18(A5),A3
	MOVE.W	$14(A3),D0
	SUB.W	D0,$12(A5)
	BPL.S	lbC0003F2
	CLR.W	$12(A5)
lbC0003F2	MOVEQ	#0,D1
	MOVEQ	#0,D0
	MOVE.B	$26(A5),D0
;	MOVEA.L	#lbL0016CA,A3

	move.l	lbL0016CA-WT(A6),A3

	MOVEA.L	0(A3,D0.W),A4

	sub.l	Origin(PC),A4
	add.l	ModulePtr(PC),A4

	MOVE.B	$20(A5),D0
lbC000408	MOVE.B	0(A4,D0.W),D1
	CMP.B	#$FF,D1
	BNE.S	lbC00041A
	CLR.B	D0
	MOVE.B	0(A4,D0.W),D0
	BRA.S	lbC000408

lbC00041A	CMP.W	#$FE,D1
	BEQ.S	lbC000442
	ADDQ.B	#1,D0
	MOVE.B	D0,$20(A5)
	CMP.B	#$80,D1
	BPL.S	lbC000430
	ADD.B	3(A5),D1
lbC000430	ANDI.B	#$7F,D1
;	MOVEA.L	#lbW00115C,A3

	move.l	lbW00115C-WT(A6),A3

	ASL.B	#1,D1

	cmp.w	#72,D1
	blt.b	PerOk2
	moveq	#70,D1
PerOk2

	MOVE.W	0(A3,D1.W),14(A5)

	bsr.w	SetPer

lbC000442	SUBQ.B	#4,D4
	BPL.L	lbC000036
	RTS
Play_2
lbC00044A	ANDI.B	#1,lbB0005BE-WT(A6)
	BNE.S	lbC000456
	RTS

lbC000456	MOVEQ	#0,D4
	MOVE.B	lbB0005BD-WT(A6),D4
	LEA	$DFF0A6,A4
	MOVEQ	#0,D3
lbC000466	MOVEA.L	#lbL000660,A5
	MOVEA.L	0(A5,D4.W),A5
	MOVE.B	8(A5),D3
	MOVE.W	14(A5),0(A4,D3.W)			; period
;	MOVE.W	$12(A5),2(A4,D3.W)			; volume

	move.w	$12(A5),D0
	cmp.w	#64,D0
	ble.b	NoMaxVol
	moveq	#64,D0
NoMaxVol
	bsr.w	ChangeVolume
	bsr.w	SetVol
	move.w	D0,2(A4,D3.W)

	MOVE.W	$16(A5),$DFF096
	SUBQ.B	#4,D4
	BPL.S	lbC000466
	RTS
Init
;lbC00048E	CLR.B	lbB0005E7-WT(A6)
;	CLR.B	lbB00060F-WT(A6)
;	CLR.B	lbB000637-WT(A6)
;	CLR.B	lbB00065F-WT(A6)
;	CLR.B	lbB0005C0-WT(A6)
;	CLR.B	lbB0005E8-WT(A6)
;	CLR.B	lbB000610-WT(A6)
;	CLR.B	lbB000638-WT(A6)
;	CLR.B	lbB0005C2-WT(A6)
;	CLR.B	lbW0005EA-WT(A6)
;	CLR.B	lbW000612-WT(A6)
;	CLR.B	lbW00063A-WT(A6)
;	CLR.B	lbB0005C1-WT(A6)
;	CLR.B	lbB0005E9-WT(A6)
;	CLR.B	lbB000611-WT(A6)
;	CLR.B	lbB000639-WT(A6)
	MOVE.B	#2,lbB0005C5-WT(A6)
	MOVE.B	#2,lbB0005ED-WT(A6)
	MOVE.B	#2,lbB000615-WT(A6)
	MOVE.B	#2,lbB00063D-WT(A6)
;	CLR.B	lbL0005C6-WT(A6)
;	CLR.B	lbL0005EE-WT(A6)
;	CLR.B	lbL000616-WT(A6)
;	CLR.B	lbL00063E-WT(A6)
;	CLR.W	lbW0005D2-WT(A6)
;	CLR.W	lbW0005FA-WT(A6)
;	CLR.W	lbW000622-WT(A6)
;	CLR.W	lbW00064A-WT(A6)
;	LEA	lbL000596,A4
;	MOVE.L	0(A4,D0.W),lbL0005DC
;	MOVE.L	4(A4,D0.W),lbL000604
;	MOVE.L	8(A4,D0.W),lbL00062C
;	MOVE.L	12(A4,D0.W),lbL000654

	move.l	lbL000596-WT(A6),A4
	move.l	Origin(PC),D7
	move.l	ModulePtr(PC),D6
	move.l	0(A4,D0.W),D1
	sub.l	D7,D1
	add.l	D6,D1
	move.l	D1,lbL0005DC-WT(A6)
	move.l	D1,A1
	move.l	4(A4,D0.W),D1
	sub.l	D7,D1
	add.l	D6,D1
	move.l	D1,lbL000604-WT(A6)
	move.l	8(A4,D0.W),D1
	sub.l	D7,D1
	add.l	D6,D1
	move.l	D1,lbL00062C-WT(A6)
	move.l	12(A4,D0.W),D1
	sub.l	D7,D1
	add.l	D6,D1
	move.l	D1,lbL000654-WT(A6)

	MOVE.B	$10(A4,D0.W),lbB0005BD-WT(A6)
	MOVE.B	$11(A4,D0.W),lbB0005BC-WT(A6)
	MOVE.W	#15,$DFF096
	MOVE.B	#1,lbB0005BE-WT(A6)
	RTS

lbC000586	CLR.B	lbB0005BE-WT(A6)
	MOVE.W	#15,$DFF096

	bsr.w	SongEnd

	RTS

WT
;lbL000596	dc.l	lbW000710
;	dc.l	lbB000741
;	dc.l	lbB00078F
;	dc.l	lbB0007B7
;	dc.w	$C02
;	dc.l	lbW0007E0
;	dc.l	lbW0007E0
;	dc.l	lbW0007E0
;	dc.l	lbW0007E0
;	dc.w	$C04
lbB0005BA	dc.b	0
lbB0005BB	dc.b	0
lbB0005BC	dc.b	0
lbB0005BD	dc.b	0
lbB0005BE	dc.b	0
	dc.b	0
lbB0005C0	dc.b	0
lbB0005C1	dc.b	0
lbB0005C2	dc.b	0
	dc.b	0
	dc.b	0
lbB0005C5	dc.b	0
lbL0005C6	dc.l	0
	dc.l	0
	dc.w	0
lbW0005D0	dc.w	0
lbW0005D2	dc.w	0
	dc.w	1
	dc.w	$8001
	dc.w	0
	dc.w	0
lbL0005DC	dc.l	0
	dc.l	0
	dc.w	0
	dc.b	0
lbB0005E7	dc.b	0
lbB0005E8	dc.b	0
lbB0005E9	dc.b	0
lbW0005EA	dc.w	0
	dc.b	0
lbB0005ED	dc.b	0
lbL0005EE	dc.l	$1000
	dc.l	0
	dc.l	0
lbW0005FA	dc.w	0
	dc.w	2
	dc.w	$8002
	dc.w	0
	dc.w	0
lbL000604	dc.l	0
	dc.l	0
	dc.w	0
	dc.b	0
lbB00060F	dc.b	0
lbB000610	dc.b	0
lbB000611	dc.b	0
lbW000612	dc.w	0
	dc.b	0
lbB000615	dc.b	0
lbL000616	dc.l	$2000
	dc.l	0
	dc.l	0
lbW000622	dc.w	0
	dc.w	4
	dc.w	$8004
	dc.w	0
	dc.w	0
lbL00062C	dc.l	0
	dc.l	0
	dc.w	0
	dc.b	0
lbB000637	dc.b	0
lbB000638	dc.b	0
lbB000639	dc.b	0
lbW00063A	dc.w	0
	dc.b	0
lbB00063D	dc.b	0
lbL00063E	dc.l	$3000
	dc.l	0
	dc.l	0
lbW00064A	dc.w	0
	dc.w	8
	dc.w	$8008
	dc.w	0
	dc.w	0
lbL000654	dc.l	0
	dc.l	0
	dc.w	0
	dc.b	0
lbB00065F	dc.b	0
lbL000660	dc.l	lbB0005C0
	dc.l	lbB0005E8
	dc.l	lbB000610
	dc.l	lbB000638

	Section	Buffy,BSS_C

Fix
	ds.b	34

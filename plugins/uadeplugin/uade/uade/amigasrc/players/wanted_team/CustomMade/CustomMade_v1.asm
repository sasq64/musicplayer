	****************************************************
	****     CustomMade replayer for Eagleplayer	****
	****        all adaptions by ANDY SILVA,	****
	****    small (?) updates done by Wanted Team	****
	****      DeliTracker (?) compatible version	****
	****************************************************

**
** DeliTracker Player for Custommade (Ivo Zoer / Ron Klaren)
**
**	very great typical art of sound with synthetic instruments
**	and samples combined, many strange typical effects
**
** by ANDY SILVA, relocates everything, plays custommade (rk) mods as
** found in memory, doesnt matter if played before
**
** SPECIAL NOTE FOR YOU:
**
**    The real name of the format formerly known as 'Ron Klaren' is
**
**		Custommade	!!!
**
**    Replay routine all coded by: Ivo Zoer
**    Songs all composed by      : Ron Klaren
**
**    (as described in a sounddemo)

	incdir	"dh2:include/"
	include 'misc/eagleplayer2.01.i'

	PLAYERHEADER PlayerTagArray

	dc.b	"$VER: CustomMade player module V1.1 (5 Jan 2004)",0
	even

PlayerTagArray
	dc.l	EP_PlayerVersion,9
	dc.l	DTP_PlayerVersion,2
	dc.l	DTP_RequestDTVersion,DELIVERSION
	dc.l	DTP_PlayerName,PlayerName
	dc.l	DTP_Creator,Creator
	dc.l	DTP_Check2,Check2
	dc.l	DTP_InitPlayer,InitPlayer
	dc.l	DTP_InitSound,InitSound
	dc.l	DTP_Interrupt,Interrupt
	dc.l	DTP_EndSound,EndSound
	dc.l	DTP_EndPlayer,EndPlayer
	dc.l	DTP_Volume,SetVolume
	dc.l	DTP_Balance,SetBalance
	dc.l	EP_Voices,SetVoices
	dc.l	EP_StructInit,StructInit
	dc.l	EP_Get_ModuleInfo,GetInfos
	dc.l	EP_SampleInit,SampleInit
	dc.l	DTP_SubSongRange,SubSongRange
	dc.l	EP_GetPositionNr,GetPosition
	dc.l	EP_Flags,EPB_Songend!EPB_NextSong!EPB_PrevSong!EPB_Volume!EPB_Balance!EPB_Voices!EPB_Analyzer!EPB_ModuleInfo!EPB_SampleInfo!EPB_Packable!EPB_Restart
	dc.l	TAG_DONE

PlayerName
	dc.b	"CustomMade",0
Creator
	dc.b	"(c) 1989-90 by Ivo Zoer & Ron Klaren,",10
	dc.b	"adapted by Andy Silva & Wanted Team",0
Prefix
	dc.b	"CM.",0
Author
	dc.b	"Ron Klaren",0
	even

ModulePtr
	dc.l	0
EagleBase
	dc.l	0
Origin
	dc.l	0
SongsTab
	dc.l	0
Table
	dc.l	0
SamplesInfo
	dc.l	0
SongEndFlag
	dc.l	'WTWT'
TimerValue
	dc.w	0
TraceVoice
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
**************************** EP_GetPositionNr *****************************
***************************************************************************

GetPosition
	move.l	TraceVoice(PC),A0
	move.l	4(A0),D0
	sub.l	(A0),D0
	divu.w	#12,D0
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
Samples		=	20
Length		=	28
SynthSamples	=	36

InfoBuffer
	dc.l	MI_SubSongs,0		;4
	dc.l	MI_LoadSize,0		;12
	dc.l	MI_Samples,0		;20
	dc.l	MI_Length,0		;28
	dc.l	MI_SynthSamples,0	;36
	dc.l	MI_MaxSubSongs,15
	dc.l	MI_Prefix,Prefix
	dc.l	MI_AuthorName,Author
	dc.l	0

***************************************************************************
******************************* EP_SampleInit *****************************
***************************************************************************

SampleInit
	moveq	#EPR_NotEnoughMem,D7
	lea	EPG_SampleInfoStructure(A5),A3
	move.l	SamplesInfo(PC),D0
	beq.b	return
	move.l	D0,A2

	move.l	InfoBuffer+Samples(PC),D5
	add.l	InfoBuffer+SynthSamples(PC),D5
	subq.l	#1,D5
Hop
	jsr	ENPP_AllocSampleStruct(A5)
	move.l	D0,(A3)
	beq.b	return
	move.l	D0,A3

	move.l	(A2),A1
	sub.l	Origin(PC),A1
	add.l	ModulePtr(PC),A1
	moveq	#0,D0
	move.w	4(A1),D0
	cmp.w	#2,D0
	beq.b	NoSynth
	cmp.w	#16,D0
	bhi.b	NoSynth
	move.w	#USITY_AMSynth,EPS_Type(A3)
	bra.b	SkipNor
NoSynth
	lsl.l	#1,D0
	move.l	(A1),A1
	sub.l	Origin(PC),A1
	add.l	ModulePtr(PC),A1

	move.l	A1,EPS_Adr(A3)			; sample address
	move.l	D0,EPS_Length(A3)		; sample length
	move.l	#64,EPS_Volume(A3)
	move.w	#USITY_RAW,EPS_Type(A3)
	move.w	#USIB_Playable!USIB_Saveable!USIB_8BIT,EPS_Flags(A3)
SkipNor
	lea	32(A2),A2
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
	cmp.l	#3000,dtg_ChkSize(A5)
	ble.b	Fault

	cmp.w	#$4EF9,(A0)		; jmp
	beq.b	Later
	cmp.w	#$4EB9,(A0)		; jsr
	beq.b	Later
	cmp.w	#$6000,(A0)		; bra.w
	bne.b	Fault
	cmp.w	#$6000,4(A0)
	beq.b	More
Fault
	rts
Later
	cmp.w	#$4EF9,6(A0)
	bne.b	Fault
More
	lea	8(A0),A1
	lea	400(A1),A2
Last
	cmp.l	#$42280030,(A1)
	bne.b	NOM
	cmp.l	#$42280031,4(A1)
	bne.b	NOM
	cmp.l	#$42280032,8(A1)
	beq.b	Found
NOM
	addq.l	#2,A1
	cmp.l	A1,A2
	bne.b	Last
	rts
Found
	moveq	#0,D0
	rts

***************************************************************************
***************************** DTP_SubSongRange ****************************
***************************************************************************

SubSongRange
	moveq 	#1,D0
	move.l	InfoBuffer+SubSongs(PC),D1
	rts

***************************************************************************
***************************** DTP_InitPlayer ******************************
***************************************************************************

InitPlayer
	moveq	#0,D0
	move.l	dtg_GetListData(A5),A0		; Function
	jsr	(A0)

	lea	ModulePtr(PC),A2
	move.l	A0,(A2)+
	move.l	A5,(A2)+			; EagleBase

	lea	InfoBuffer(PC),A6
	move.l	D0,LoadSize(A6)

	clr.l	(A2)				; Origin
	move.l	A0,D5

	move.w	#$7FF,D7
i_lp	cmp.l	#$d04149fa,(a0)	; tab
	bne.b	i_2
	move.w	4(a0),d0
	lea	4(a0,d0.w),a1
	move.l	A1,8(A2)	; table
	bra	i_lp_c
i_2	cmp.l	#$48e7f8fc,(a0)	; play / pattab
	beq.b	i_2.0
	cmp.l	#$48e7fffe,(a0)
	bne.b	i_3
i_2.0	move.l	a3,d6
	beq.b	i_2.1
	tst.l	(A2)
	bne.b	i_2.1
	move.l	a0,a1
	sub.l	a3,a1	; play-oldplay
	sub.l	a1,D5	; nowadr-dx
	move.l	D5,(A2)
i_2.1	moveq	#20,d6
i_2.lp	cmp.w	#$41fa,(a0)+
	beq.b	i_2.2
	dbf	d6,i_2.lp
	bra	i_lp_c
i_2.2	move.w	(a0),d0
	lea	(a0,d0.w),a1
	move.l	A1,4(A2)
	bra	i_lp_c
i_3	cmp.l	#$e94847f0,(a0)	; ptoff
	bne.b	i_4
	move.w	4(a0),d1
	bra	i_lp_c
i_4	cmp.l	#$00bfd500,(a0)	; oldplay
	bne.b	i_6
	move.b	-1(a0),d0	; hi
	lsl.w	#8,d0
	move.b	7(a0),d0	; lo
	move.w	d0,TimerValue
	cmp.w	#$4e71,20(a0)
	beq	i_lp_c
	cmp.w	#$21fc,28(a0)
	beq.b	i_4.2
	cmp.w	#$c000,32(a0)
	bne.b	i_4.1
	move.l	22(a0),a3
	bra.b	i_lp_c
i_4.1	move.l	32(a0),a3
	bra.b	i_lp_c
i_4.2	move.l	30(a0),a3
	bra.b	i_lp_c
;i_5	cmp.l	#$000f3001,(a0)	; fxtab
;	bne.b	i_6
;	move.w	6(a0),d0
;	lea	6(a0,d0.w),a1
;	move.l	a1,fxtab
;	bra.b	i_lp_c
i_6	cmp.l	#$42a8001c,(a0)	; SamplesInfo
	bne.b	i_7
	lea	6(a0),a1
	move.w	(a1),d0
	lea	(a1,d0.w),a1
	move.l	A1,12(A2)	; SamplesInfo
	bra.b	i_lp_c
i_7	cmp.l	#$e44843fa,(a0)	; oldvoc1
	beq.b	i_7.1
	cmp.l	#$e448207b,(a0)
	bne.b	i_8
i_7.1	move.l	a4,d6
	beq.b	i_lp_c
	move.w	4(a0),d0
	sub.l	4(a0,d0.w),a4 ; voc0-oldvoc0
	tst.l	(A2)
	bne.b	i_lp_c
	sub.l	a4,D5
	move.l	D5,(A2)
	bra.b	i_lp_c
i_8	cmp.l	#$48e700f0,(a0)	; voc0
	bne.b	i_lp_c
	move.w	6(a0),d0
	lea	6(a0,d0.w),a4
i_lp_c	addq.l	#2,A0

	cmp.l	#$1AC01940,(A0)
	beq.b	ex

	dbf	d7,i_lp
ex
	ext.l	D1
	add.l	D1,4(A2)

	move.l	4(A2),A1
	moveq	#0,D1
Find
	move.l	(A1),D2
	and.l	#$FFFFFF,D2
	cmp.l	#$DFF0A0,D2
	beq.b	NoMore
	addq.l	#1,D1
	lea	16(A1),A1
	bra.b	Find
NoMore
	move.l	D1,SubSongs(A6)

	move.l	SamplesInfo(PC),A1
	moveq	#0,D1
	moveq	#0,D0
NextSam
	tst.l	28(A1)
	bne.b	NoSamp
	move.l	(A1),A2
	sub.l	Origin(PC),A2
	add.l	ModulePtr(PC),A2
	cmp.w	#2,4(A2)		; empty sample
	beq.b	NoSynthia
	cmp.w	#16,4(A2)
	bhi.b	NoSynthia
	addq.l	#1,D0
	bra.b	SkipNora
NoSynthia
	addq.l	#1,D1
SkipNora
	lea	32(A1),A1
	bra.b	NextSam
NoSamp
	move.l	D1,Samples(A6)
	move.l	D0,SynthSamples(A6)
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
	lea	OldVoice1(PC),A0
	clr.l	(A0)+
	clr.l	(A0)
	lea	SongEndFlag(PC),A4
	move.l	#'WTWT',(A4)+
	move.w	(A4)+,dtg_Timer(A5)
	move.w	dtg_SndNum(A5),D0
	lea	lbL000A86(PC),A0
	move.w	#$013F,(A0)
	move.l	SongsTab(PC),A1
	move.w	D0,D5
	subq.w	#1,D5
	lsl.w	#4,D5
	add.w	D5,A1
	moveq	#0,D1
	lea	lbL000AA2+8(PC),A2
	moveq	#3,D3
	moveq	#-1,D4
NextVoice
	moveq	#0,D5
	move.l	(A1)+,A3
	sub.l	Origin(PC),A3
	add.l	ModulePtr(PC),A3
FindEndVoice
	cmp.l	(A3),D4
	beq.b	EndVoice
	addq.l	#1,D5
	lea	12(A3),A3
	bra.b	FindEndVoice
EndVoice
	cmp.l	D5,D1
	bge.b	MaxLen
	move.l	D5,D1
	move.l	A2,(A4)
MaxLen
	lea	62(A2),A2
	dbf	D3,NextVoice

	lea	InfoBuffer(PC),A1
	move.l	D1,Length(A1)
	bra.w	Init

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

	move.b	lbL000A86(PC),D1
	bne.b	NoPlay
	bsr.w	Play
NoPlay
	lea	StructAdr(PC),A0
	clr.w	UPS_Enabled(A0)
	movem.l	(A7)+,D1-A6
	moveq	#0,D0
	rts

SongEndTest
	movem.l	A1/A5,-(A7)
	lea	SongEndFlag(PC),A1
	cmp.l	#$DFF0A0,(A0)
	bne.b	test1
	clr.b	(A1)
	bra.b	test
test1
	cmp.l	#$DFF0B0,(A0)
	bne.b	test2
	clr.b	1(A1)
	bra.b	test
test2
	cmp.l	#$DFF0C0,(A0)
	bne.b	test3
	clr.b	2(A1)
	bra.b	test
test3
	cmp.l	#$DFF0D0,(A0)
	bne.b	test
	clr.b	3(A1)
test
	tst.l	(A1)
	bne.b	SkipEnd
	move.l	#'WTWT',(A1)
	move.l	EagleBase(PC),A5
	move.l	dtg_SongEnd(A5),A1
	jsr	(A1)
SkipEnd
	movem.l	(A7)+,A1/A5
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
	move.w	(A1)+,D3
	bsr.b	ChangeVolume
	lea	16(A3),A3
	dbf	D0,SetNew
	rts

ChangeVolume
	cmpa.l	#$DFF0A0,A3			;Left Volume
	bne.b	NoVoice1
	move.w	D3,OldVoice1
	tst.w	Voice1
	bne.b	Voice1On
	moveq	#0,D3
Voice1On
	mulu.w	LeftVolume(PC),D3
	bra.b	SetIt
NoVoice1
	cmpa.l	#$DFF0B0,A3			;Right Volume
	bne.b	NoVoice2
	move.w	D3,OldVoice2
	tst.w	Voice2
	bne.b	Voice2On
	moveq	#0,D3
Voice2On
	mulu.w	RightVolume(PC),D3
	bra.b	SetIt
NoVoice2
	cmpa.l	#$DFF0C0,A3			;Right Volume
	bne.b	NoVoice3
	move.w	D3,OldVoice3
	tst.w	Voice3
	bne.b	Voice3On
	moveq	#0,D3
Voice3On
	mulu.w	RightVolume(PC),D3
	bra.b	SetIt
NoVoice3
	move.w	D3,OldVoice4
	tst.w	Voice4
	bne.b	Voice4On
	moveq	#0,D3
Voice4On
	mulu.w	LeftVolume(PC),D3
SetIt
	lsr.w	#6,D3
	move.w	D3,8(A3)
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
	move.w	D3,(A0)
	move.l	(A7)+,A0
	rts

*------------------------------ Set Adr/Len -----------------------------*

SetTwo
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
	move.l	D7,(A0)
	move.w	4(A4),UPS_Voice1Len(A0)
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
	move.w	D0,(A0)
	move.l	(A7)+,A0
	rts

***************************************************************************
****************************** EP_Voices **********************************
***************************************************************************

;		d0 Bit 0-3 = Set Voices Bit=1 Voice on

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
***************************** CustomMade player ***************************
***************************************************************************

; Player from "Cyberblast" (victory tune)

;	JMP	lbC0004D6

;	JMP	lbC000530

;	MOVE.W	#1,D0
;	BRA.L	lbC00065A

;lbC000014:	MOVEM.L	A0-A3,-(SP)
;	LEA	lbL000AA2(PC),A0
;	BSR.S	lbC000036
;	LEA	lbL000AE0(PC),A0
;	BSR.S	lbC000036
;	LEA	lbL000B1E(PC),A0
;	BSR.S	lbC000036
;	LEA	lbL000B5C(PC),A0
;	BSR.S	lbC000036
;	MOVEM.L	(SP)+,A0-A3
;	RTS

lbC000036:	CLR.B	$30(A0)
	CLR.B	$31(A0)
	CLR.B	$32(A0)
	CLR.B	$33(A0)
	CLR.B	$34(A0)
	CLR.B	$39(A0)
	CLR.B	$35(A0)
	CLR.B	$37(A0)
	CLR.B	$36(A0)
	CLR.B	$3B(A0)
	CLR.B	$3C(A0)
	MOVE.B	#1,$3A(A0)
;	CLR.B	$3D(A0)
	CLR.W	$28(A0)
	CLR.W	$2A(A0)
	CLR.W	$2C(A0)
	CLR.L	$14(A0)
	CLR.L	$18(A0)
	CLR.L	$1C(A0)
;	LEA	lbL000C4E(PC),A1

	move.l	SamplesInfo(PC),A1	; fuzzy to a1

	MOVE.L	A1,4(A0)	; fuzzy to 4(voice)
	MOVEA.L	(A1),A1		; (fuzzy) to a1

	sub.l	Origin(PC),A1
	add.l	ModulePtr(PC),A1

	MOVEA.L	(A0),A2		; regbase to a2
;	MOVE.L	0(A1),0(A2)

	move.l	(A1),D7
	sub.l	Origin(PC),D7
	add.l	ModulePtr(PC),D7
	move.l	D7,(A2)		; adr=0

	MOVE.W	4(A1),4(A2)	; len=0
	MOVE.L	8(A0),12(A0)	; save start
	MOVEA.L	12(A0),A1	; read startpatt
;	MOVE.L	(A1),$10(A0)

	move.l	(A1),D7
	sub.l	Origin(PC),D7
	add.l	ModulePtr(PC),D7
	move.l	D7,$10(A0)

	MOVE.W	6(A1),$20(A0)

	cmp.w	#$270F,10(A1)
	bne.b	NoIntro
	move.w	#$003E,10(A1)	; for better SongEnd handling for BS intro
NoIntro
	MOVE.W	10(A1),D0
	SUBQ.W	#1,D0
	MOVE.W	D0,$22(A0)
	RTS

				; everything below belongs to _play

lbC0000C0:	MOVEA.L	4(A0),A1	; get *fuzzy
	MOVEA.L	$10(A0),A2
	MOVEA.L	(A0),A3
;	TST.B	$3D(A0)
;	BNE.S	lbC000126
	TST.B	$3B(A0)
	BEQ.S	lbC000108
	TST.B	$3C(A0)
	BEQ.S	lbC0000E4
	SUBQ.B	#1,$3C(A0)
	BRA.S	lbC000108

lbC0000E4:	CLR.B	$3B(A0)
;	LEA	lbL000A86(PC),A4
;	TST.B	4(A4)				; fx
;	BNE.S	lbC000108
	MOVE.B	8(A1),$3A(A0)			; new
;	MOVEA.L	0(A1),A4

	move.l	(A1),A4
	sub.l	Origin(PC),A4
	add.l	ModulePtr(PC),A4

;	MOVE.L	0(A4),0(A3)

	move.l	(A4),D7
	sub.l	Origin(PC),D7
	add.l	ModulePtr(PC),D7
	move.l	D7,(A3)				; address

	MOVE.W	4(A4),4(A3)			; length

	bsr.w	SetTwo

lbC000108:	MOVE.W	#$8000,D0
	OR.W	$2E(A0),D0
	MOVE.W	D0,$DFF096
	TST.B	$3A(A0)
	BEQ.S	lbC000126
	CLR.B	$3A(A0)
	MOVE.W	#1,4(A3)			; length
lbC000126:
;	LEA	lbL000A86(PC),A4
;	TST.B	4(A4)				; fx
;	BEQ.S	lbC000132
;	RTS

lbC000132:	TST.B	$31(A0)
	BEQ.L	lbC0002E8
	SUBQ.B	#1,$31(A0)
	TST.B	$3B(A0)
	BEQ.S	lbC000146
	RTS

lbC000146:	CLR.W	D0
	TST.B	9(A1)
	BEQ.S	lbC0001BA
	TST.B	$36(A0)
	BEQ.S	lbC00015A
	SUBQ.B	#1,$36(A0)
	BRA.S	lbC0001BA

lbC00015A:	MOVE.B	9(A1),D0
	SUBQ.B	#1,D0
	MOVE.B	D0,$36(A0)
;	MOVEA.L	0(A1),A4

	move.l	(A1),A4
	sub.l	Origin(PC),A4
	add.l	ModulePtr(PC),A4

	MOVE.W	6(A4),D0
	SUB.B	10(A1),D0
;	MOVEA.L	0(A4),A4

	move.l	(A4),A4
	sub.l	Origin(PC),A4
	add.l	ModulePtr(PC),A4

	LEA	0(A4,D0.W),A4
	CLR.W	D0
	TST.B	$17(A1)
	BMI.S	lbC0001A0
	MOVE.B	$18(A1),D0
	MOVE.B	$16(A1),0(A4,D0.W)
	ADDQ.B	#1,D0
	MOVE.B	10(A1),D1
	ADD.B	D1,D1
	CMP.B	D0,D1
	BNE.S	lbC0001B6
	NOT.B	$17(A1)
	NOT.B	$16(A1)
	BRA.S	lbC0001B6

lbC0001A0:	MOVE.B	$18(A1),D0
	MOVE.B	$16(A1),0(A4,D0.W)
	SUBQ.B	#1,D0
	BNE.S	lbC0001B6
	NOT.B	$17(A1)
	NOT.B	$16(A1)
lbC0001B6:	MOVE.B	D0,$18(A1)
lbC0001BA:	TST.B	$37(A0)
	BEQ.S	lbC0001F2

	clr.w	D0			; missing ?

	MOVE.B	$37(A0),D0
	MOVE.W	$26(A0),D1
	MOVE.W	$24(A0),D2
	CMP.W	D2,D1
	BPL.S	lbC0001DA
	SUB.W	D0,D2
	CMP.W	D2,D1
	BMI.S	lbC0001E2
	MOVE.W	D1,D2
	BRA.S	lbC0001E2

lbC0001DA:	ADD.W	D0,D2
	CMP.W	D2,D1
	BPL.S	lbC0001E2
	MOVE.W	D1,D2
lbC0001E2:	MOVE.W	D2,$24(A0)
;	TST.B	$3D(A0)
;	BNE.S	lbC00022A
	MOVE.W	D2,6(A3)			; period

	move.l	D0,-(SP)
	move.w	D2,D0
	bsr.w	SetPer
	move.l	(SP)+,D0

	BRA.S	lbC00022A

lbC0001F2:	LEA	$14(A0),A4
	MOVE.W	$2C(A0),D1
	MOVE.B	0(A4,D1.W),D0
	ADD.B	$30(A0),D0
	ADD.W	$20(A0),D0
	ADD.W	D0,D0
	LEA	lbL0009F4(PC),A4
	MOVE.W	0(A4,D0.W),D0
	MOVE.W	D0,$24(A0)
;	TST.B	$3D(A0)
;	BNE.S	lbC00021E
	MOVE.W	D0,6(A3)			; period

;	bsr.w	SetPer	

lbC00021E:	SUBQ.W	#1,D1
	BPL.S	lbC000226
	ADDI.W	#12,D1
lbC000226:	MOVE.W	D1,$2C(A0)
lbC00022A:	TST.B	11(A1)
	BEQ.L	lbC000280
	TST.B	$35(A0)
	BEQ.S	lbC00023E
	SUBQ.B	#1,$35(A0)
	BRA.S	lbC000280

lbC00023E:	MOVE.W	$2A(A0),D0
	MOVEA.L	4(A1),A4

	sub.l	Origin(PC),A4
	add.l	ModulePtr(PC),A4

;	MOVEA.L	0(A4),A4

	move.l	(A4),A4
	sub.l	Origin(PC),A4
	add.l	ModulePtr(PC),A4

	MOVE.B	0(A4,D0.W),D2
	CLR.W	D1
	EXT.W	D2
	MOVE.B	12(A1),D1
	MULS.W	D1,D2
	ADD.W	$24(A0),D2
;	TST.B	$3D(A0)
;	BNE.S	lbC000266
	MOVE.W	D2,6(A3)			; period

	move.w	D2,D0
	bsr.w	SetPer

lbC000266:	CLR.W	D0
	MOVE.B	11(A1),D0
	SUB.W	D0,$2A(A0)
	BPL.S	lbC000280
	MOVEA.L	4(A1),A4

	sub.l	Origin(PC),A4
	add.l	ModulePtr(PC),A4

	MOVE.W	4(A4),D0
	ADD.W	D0,D0
	MOVE.W	D0,$2A(A0)
lbC000280:	SUBQ.B	#1,$34(A0)
	BPL.S	lbC0002E6
	MOVE.B	$33(A0),$34(A0)
	MOVE.W	$28(A0),D0
	LEA	14(A1),A4
	MOVE.B	0(A4,D0.W),D1
	MOVE.B	4(A4,D0.W),D2
	MOVE.B	$39(A0),D3
	CMP.B	D3,D1
	BPL.S	lbC0002B6
	SUB.B	D2,D3
	CMP.B	D3,D1
	BMI.S	lbC0002D0
	MOVE.B	D1,D3
lbC0002AC:	CMPI.W	#3,D0
	BEQ.S	lbC0002D0
	ADDQ.W	#1,D0
	BRA.S	lbC0002D0

lbC0002B6:	LEA	lbL000A86(PC),A1
	ADD.B	D2,D3
	CMP.B	1(A1),D3
	BMI.S	lbC0002C8
	MOVE.B	1(A1),D3
	BRA.S	lbC0002AC

lbC0002C8:	CMP.B	D3,D1
	BPL.S	lbC0002D0
	MOVE.B	D1,D3
	BRA.S	lbC0002AC

lbC0002D0:	MOVE.W	D0,$28(A0)
	MOVE.B	D3,$39(A0)
;	TST.B	$3D(A0)
;	BNE.S	lbC0002E6
	ANDI.W	#$3F,D3
;	MOVE.W	D3,8(A3)			; volume

	bsr.w	ChangeVolume
	bsr.w	SetVol

lbC0002E6:	RTS

lbC0002E8:
;	LEA	lbL000A86(PC),A4
;	TST.B	4(A4)				; fx
;	BNE.S	lbC0002E6
	CLR.B	$37(A0)
	MOVE.B	13(A1),D0
	BEQ.S	lbC000304
	LSL.B	#2,D0
	SUBQ.B	#1,D0
	MOVE.B	D0,$35(A0)
lbC000304:	CMPI.B	#$80,(A2)
	BNE.S	lbC000338
	CLR.L	D0
	CLR.W	D1
	CLR.W	$2C(A0)
	MOVE.B	1(A2),D0
	MOVE.W	D0,D1
	LSL.W	#3,D0
	LSL.W	#2,D1
	ADD.W	D1,D0
;	LEA	lbL000BA6(PC),A4

	move.l	Table(PC),A4

	ADDA.L	D0,A4
	MOVE.L	(A4),$14(A0)
	MOVE.L	4(A4),$18(A0)
	MOVE.L	8(A4),$1C(A0)
	ADDQ.L	#2,A2
lbC000338:	CMPI.B	#$81,(A2)
	BNE.S	lbC000374
	CLR.W	D0
	CLR.W	$28(A0)				; new
	MOVE.B	1(A2),D0
	MOVE.B	D0,$32(A0)
	ADD.W	$20(A0),D0
	ADD.W	D0,D0
	LEA	lbL0009F4(PC),A4
	MOVE.W	0(A4,D0.W),$26(A0)
	MOVE.B	2(A2),$37(A0)
	MOVE.B	3(A2),D0
	LSL.B	#2,D0
	SUBQ.B	#1,D0
	MOVE.B	D0,$31(A0)
	ADDQ.L	#4,A2
	BRA.L	lbC0004C4

lbC000374:	CMPI.B	#$82,(A2)
	BNE.S	lbC0003BC
	CLR.W	D0
	CLR.B	$39(A0)				; new
	CLR.W	$28(A0)
	MOVE.B	1(A2),D0
	LSL.W	#5,D0
;	LEA	lbL000C4E(PC),A4

	move.l	SamplesInfo(PC),A4

	LEA	0(A4,D0.W),A1
	MOVE.L	A1,4(A0)
;	TST.B	$3D(A0)
;	BNE.S	lbC0003BA
	TST.B	$3B(A0)
	BNE.S	lbC0003BA
	MOVE.W	$2E(A0),$DFF096
;	MOVEA.L	0(A1),A4

	move.l	(A1),A4
	sub.l	Origin(PC),A4
	add.l	ModulePtr(PC),A4

;	MOVE.L	0(A4),0(A3)

	move.l	(A4),D7
	sub.l	Origin(PC),D7
	add.l	ModulePtr(PC),D7
	move.l	D7,(A3)				; address

	MOVE.W	4(A4),4(A3)			; length

	bsr.w	SetTwo

lbC0003BA:	ADDQ.L	#2,A2
lbC0003BC:	CMPI.B	#$83,(A2)
	BNE.S	lbC0003D8
Back
	LEA	lbL000A86(PC),A0
	MOVE.B	#1,(A0)
;	CLR.W	8(A0)
;	MOVE.W	#1,6(A0)

	bsr.w	SongEnd

	RTS

lbC0003D8:	CMPI.B	#$84,(A2)
	BNE.S	lbC0003E6
	MOVE.B	1(A2),$33(A0)
	ADDQ.L	#2,A2
lbC0003E6:
	cmp.b	#$85,(A2)
	beq.b	Back

	TST.B	(A2)
	BPL.S	lbC000444
	TST.W	$22(A0)
	BEQ.S	lbC000408
	SUBQ.W	#1,$22(A0)
	MOVEA.L	12(A0),A4
	MOVEA.L	(A4),A2

	sub.l	Origin(PC),A2
	add.l	ModulePtr(PC),A2

	MOVE.L	A2,$10(A0)
	MOVE.W	6(A4),$20(A0)
	BRA.L	lbC000304

lbC000408:	ADDI.L	#12,12(A0)
	MOVEA.L	12(A0),A4
	MOVE.W	10(A4),$22(A0)
	SUBQ.W	#1,$22(A0)
	TST.B	(A4)
	BPL.S	lbC00042A
	MOVEA.L	8(A0),A4
	MOVE.L	A4,12(A0)

	bsr.w	SongEndTest

lbC00042A:	MOVEA.L	(A4),A2

	sub.l	Origin(PC),A2
	add.l	ModulePtr(PC),A2

	MOVE.L	A2,$10(A0)
	MOVE.W	6(A4),$20(A0)
	MOVE.W	10(A4),D0
	SUBQ.W	#1,D0
	MOVE.W	D0,$22(A0)
	BRA.L	lbC000304

lbC000444:	MOVE.B	1(A2),D0
	BNE.S	lbC000466
	MOVE.B	(A2),D0
	MOVE.B	D0,$30(A0)
	ADD.W	$20(A0),D0
	ADD.W	D0,D0
	LEA	lbL0009F4(PC),A4
	MOVE.W	0(A4,D0.W),$24(A0)
	ADDQ.L	#2,A2
	BRA.L	lbC000304

lbC000466:	LSL.B	#2,D0
	SUBQ.B	#1,D0
	MOVE.B	D0,$31(A0)
	CLR.W	D0
	CLR.W	$28(A0)
	MOVE.B	(A2),D0
	MOVE.B	D0,$30(A0)
	ADD.W	$20(A0),D0
	ADD.W	D0,D0
	LEA	lbL0009F4(PC),A4
	MOVE.W	0(A4,D0.W),$24(A0)
;	TST.B	$3D(A0)
;	BNE.S	lbC000496
	TST.B	$3B(A0)
	BEQ.S	lbC00049E
lbC000496:	ADDQ.L	#2,A2
	MOVE.L	A2,$10(A0)
	RTS

lbC00049E:	MOVE.W	$2E(A0),$DFF096
	MOVEA.L	(A1),A4

	sub.l	Origin(PC),A4
	add.l	ModulePtr(PC),A4

;	MOVE.L	0(A4),0(A3)

	move.l	(A4),D7
	sub.l	Origin(pc),D7
	add.l	ModulePtr(pc),D7
	move.l	D7,(A3)				; address

	MOVE.W	4(A4),4(A3)			; length

	bsr.w	SetTwo

	ADDQ.L	#2,A2
	TST.B	8(A1)
	BEQ.S	lbC0004C4
	MOVE.B	#1,$3A(A0)
lbC0004C4:	MOVE.L	A2,$10(A0)
;	TST.B	$3D(A0)
;	BNE.S	lbC0004D4
	MOVE.W	$24(A0),6(A3)			; period

	move.l	D0,-(SP)
	move.w	$24(A0),D0
	bsr.w	SetPer
	move.l	(SP)+,D0

lbC0004D4:	RTS

;lbC0004D6:	BSR.L	lbC000014
;	MOVE.W	#$4000,$DFF09A
;	MOVE.B	#0,$BFDE00
;	MOVE.B	#0,$BFD400
;	MOVE.B	#$37,$BFD500
;	MOVE.B	#$81,$BFDD00
;	MOVE.B	#$11,$BFDE00
;	MOVE.L	$78,lbL000A80
;	MOVE.L	#lbC0007B0,$78
;	MOVE.W	#$C000,$DFF09A
;	MOVE.W	#$800F,$DFF096
;	RTS

;lbC000530:	MOVE.W	#$4000,$DFF09A
;	MOVE.B	#1,$BFDD00
;	MOVE.L	lbL000A80,$78
;	MOVE.W	#$C000,$DFF09A
;	MOVE.W	#15,$DFF096
;	RTS

;	MOVE.L	A0,-(SP)
;	LEA	lbL000A86(PC),A0
;	TST.B	3(A0)
;	BNE.S	lbC00056E
;	MOVE.B	1(A0),3(A0)
;lbC00056E:	MOVE.B	#1,2(A0)
;	MOVEA.L	(SP)+,A0
;	RTS

;	MOVE.W	#1,lbW0006AE
;	RTS

;	MOVE.L	A0,-(SP)
;	LEA	lbL000A86(PC),A0
;	EORI.B	#1,5(A0)
;	MOVEA.L	(SP)+,A0
;	RTS

;	MOVEM.L	D0/A0/A1,-(SP)
;	LEA	lbL00069E(PC),A0
;	ANDI.W	#3,D0
;	LSL.W	#2,D0
;	MOVEA.L	0(A0,D0.W),A0
;	EORI.B	#1,$3D(A0)
;	MOVEA.L	0(A0),A1
;	CLR.W	8(A1)
;	TST.B	$3D(A0)
;	BNE.S	lbC0005E4
;	MOVE.W	$24(A0),6(A1)
;	MOVE.W	$2E(A0),$DFF096
;	CLR.W	D0
;	MOVE.B	$39(A0),D0
;	MOVE.W	D0,8(A1)
;	MOVEA.L	4(A0),A0
;	MOVEA.L	0(A0),A0
;	MOVE.L	0(A0),0(A1)
;	MOVE.W	4(A0),4(A1)
;lbC0005E4:	MOVEM.L	(SP)+,D0/A0/A1
;	RTS

;	MOVEM.L	D0/D1/A0/A1,-(SP)
;	LEA	lbL000A86(PC),A0
;	TST.B	5(A0)
;	BNE.S	lbC000654
;	MOVE.W	D0,D1
;	ANDI.W	#$30,D0
;	LSR.W	#2,D0
;	LEA	lbL00069E(PC),A1
;	MOVEA.L	0(A1,D0.W),A0
;	TST.B	$3D(A0)
;	BNE.S	lbC000654
;	MOVE.B	#1,$3A(A0)
;	MOVE.W	$2E(A0),$DFF096
;	ANDI.W	#15,D1
;	MOVE.W	D1,D0
;	LEA	lbL000B9A(PC),A1
;	LSL.W	#3,D1
;	LSL.W	#2,D0
;	ADD.W	D0,D1
;	MOVE.B	11(A1,D1.W),$3C(A0)
;	MOVE.B	#1,$3B(A0)
;	MOVEA.L	0(A0),A0
;	MOVE.L	0(A1,D1.W),0(A0)
;	MOVE.W	4(A1,D1.W),4(A0)
;	MOVE.W	6(A1,D1.W),6(A0)
;	MOVE.W	8(A1,D1.W),8(A0)
;lbC000654:	MOVEM.L	(SP)+,D0/D1/A0/A1
;	RTS

;lbC00065A:	MOVEM.L	D0/A0,-(SP)
;	LEA	lbL000A86(PC),A0
;	CLR.B	2(A0)
;	TST.B	3(A0)
;	BEQ.S	lbC000676
;	MOVE.B	3(A0),1(A0)
;	CLR.B	3(A0)
;lbC000676:	TST.B	4(A0)
;	BNE.S	lbC000698
;	TST.W	10(A0)
;	BNE.S	lbC000698
;	MOVE.W	D0,8(A0)
;	MOVE.B	#1,0(A0)
;	CMPI.W	#1,D0
;	BEQ.S	lbC000698
;	MOVE.W	#1,10(A0)
;lbC000698:	MOVEM.L	(SP)+,D0/A0
;	RTS

;lbL00069E:	dc.l	lbL000AA2
;	dc.l	lbL000AE0
;	dc.l	lbL000B1E
;	dc.l	lbL000B5C
;lbW0006AE:	dc.w	0
;lbL0006B0:	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0

;lbC0007B0:	MOVEM.L	D0-D4/A0-A5,-(SP)
;	BSR.S	lbC0007CA
;	MOVE.B	$BFDD00,D0
;	MOVE.W	#$2000,$DFF09C
;	MOVEM.L	(SP)+,D0-D4/A0-A5
;	RTE

;lbC0007CA:	LEA	lbL000A86(PC),A0
;	TST.W	lbW0006AE
;	BEQ.L	lbC0007FE
;	CLR.W	lbW0006AE
;	EORI.B	#1,4(A0)
;	BEQ.L	lbC0007FE
;	LEA	$DFF008,A1
;	CLR.W	$A0(A1)
;	CLR.W	$B0(A1)
;	CLR.W	$C0(A1)
;	CLR.W	$D0(A1)
;lbC0007FE:	TST.B	(A0)
;	BNE.S	lbC000878
;	TST.B	2(A0)
;	BEQ.S	lbC000854
;	TST.B	1(A0)
;	BEQ.S	lbC000826
;	SUBQ.B	#1,lbW000A84
;	BPL.S	lbC000854
;	MOVE.B	#2,lbW000A84
;	SUBQ.B	#1,1(A0)
;	BRA.S	lbC000854

;lbC000826:	MOVE.B	#1,(A0)
;	MOVE.B	3(A0),1(A0)
;	CLR.B	2(A0)
;	CLR.B	3(A0)
;	LEA	$DFF008,A0
;	CLR.W	$A0(A0)
;	CLR.W	$B0(A0)
;	CLR.W	$C0(A0)
;	CLR.W	$D0(A0)
;	BRA.L	lbC0009F2

Play
lbC000854:	LEA	lbL000AA2(PC),A0
	BSR.L	lbC0000C0
	LEA	lbL000AE0(PC),A0
	BSR.L	lbC0000C0
	LEA	lbL000B1E(PC),A0
	BSR.L	lbC0000C0
	LEA	lbL000B5C(PC),A0
	BSR.L	lbC0000C0
;	BRA.L	lbC0009F2

	rts

Init
;lbC000878:	TST.W	8(A0)
;	BEQ.S	lbC0008F8
;	MOVEM.L	A0/A1,-(SP)
;	LEA	lbL000AA2(PC),A0
;	LEA	lbL0006B0(PC),A1
;	MOVE.W	#$3F,D0
;lbC00088E:	MOVE.L	(A0)+,(A1)+
;	DBRA	D0,lbC00088E
;	MOVEM.L	(SP)+,A0/A1
;	MOVE.W	#15,$DFF096
;	MOVE.W	8(A0),D0
	ANDI.W	#15,D0
	SUBQ.W	#1,D0
	LSL.W	#4,D0
;	LEA	12(A0,D0.W),A3

	move.l	SongsTab(PC),A0
	lea	(A0,D0.W),A3	; access pattab, init subsong

	LEA	lbL000AA2(PC),A0
;	MOVE.L	0(A3),8(A0)

	move.l	(A3),D7
	sub.l	Origin(PC),D7
	add.l	ModulePtr(PC),D7
	move.l	D7,8(A0)

	BSR.L	lbC000036
	LEA	lbL000AE0(PC),A0
;	MOVE.L	4(A3),8(A0)

	move.l	4(A3),D7
	sub.l	Origin(PC),D7
	add.l	ModulePtr(PC),D7
	move.l	D7,8(A0)

	BSR.L	lbC000036
	LEA	lbL000B1E(PC),A0
;	MOVE.L	8(A3),8(A0)

	move.l	8(A3),D7
	sub.l	Origin(PC),D7
	add.l	ModulePtr(PC),D7
	move.l	D7,8(A0)

	BSR.L	lbC000036
	LEA	lbL000B5C(PC),A0
;	MOVE.L	12(A3),8(A0)

	move.l	12(A3),D7
	sub.l	Origin(PC),D7
	add.l	ModulePtr(PC),D7
	move.l	D7,8(A0)

	BSR.L	lbC000036
	LEA	lbL000A86(PC),A0
	CLR.B	(A0)
;	CLR.W	8(A0)
;	BRA.L	lbC0009F2

	rts

;lbC0008F8:;	TST.W	6(A0)
;	BEQ.L	lbC0009F2
;	LEA	lbL0006B0(PC),A0
;	LEA	lbL000AA2(PC),A1
;	MOVE.W	#$3F,D0
;lbC00090C:	MOVE.L	(A0)+,(A1)+
;	DBRA	D0,lbC00090C
;	LEA	lbL000AA2(PC),A0
;	MOVE.W	$2E(A0),$DFF096
;	MOVEA.L	0(A0),A1
;	MOVE.W	$24(A0),6(A1)
;	MOVEA.L	4(A0),A2
;	MOVEA.L	0(A2),A2
;	MOVE.L	0(A2),0(A1)
;	MOVE.W	4(A2),4(A1)
;	CLR.W	D0
;	MOVE.B	$39(A0),D0
;	MOVE.W	D0,8(A1)
;	LEA	lbL000AE0(PC),A0
;	MOVE.W	$2E(A0),$DFF096
;	MOVEA.L	0(A0),A1
;	MOVE.W	$24(A0),6(A1)
;	MOVEA.L	4(A0),A2
;	MOVEA.L	0(A2),A2
;	MOVE.L	0(A2),0(A1)
;	MOVE.W	4(A2),4(A1)
;	CLR.W	D0
;	MOVE.B	$39(A0),D0
;	MOVE.W	D0,8(A1)
;	LEA	lbL000B1E(PC),A0
;	MOVE.W	$2E(A0),$DFF096
;	MOVEA.L	0(A0),A1
;	MOVE.W	$24(A0),6(A1)
;	MOVEA.L	4(A0),A2
;	MOVEA.L	0(A2),A2
;	MOVE.L	0(A2),0(A1)
;	MOVE.W	4(A2),4(A1)
;	CLR.W	D0
;	MOVE.B	$39(A0),D0
;	MOVE.W	D0,8(A1)
;	LEA	lbL000B5C(PC),A0
;	MOVE.W	$2E(A0),$DFF096
;	MOVEA.L	0(A0),A1
;	MOVE.W	$24(A0),6(A1)
;	MOVEA.L	4(A0),A2
;	MOVEA.L	0(A2),A2
;	MOVE.L	0(A2),0(A1)
;	MOVE.W	4(A2),4(A1)
;	CLR.W	D0
;	MOVE.B	$39(A0),D0
;	MOVE.W	D0,8(A1)
;	LEA	lbL000A86(PC),A0
;	CLR.W	10(A0)
;	CLR.W	6(A0)
;	CLR.B	0(A0)
;lbC0009F2:	RTS

lbL0009F4:	dc.l	$1AC01940
	dc.l	$17D01680
	dc.l	$15301400
	dc.l	$12E011D0
	dc.l	$10D00FE0
	dc.l	$F000E20
	dc.l	$D600CA0
	dc.l	$BE80B40
	dc.l	$A980A00
	dc.l	$97008E8
	dc.l	$86807F0
	dc.l	$7800710
	dc.l	$6B00650
	dc.l	$5F405A0
	dc.l	$54C0500
	dc.l	$4B80474
	dc.l	$43403F8
	dc.l	$3C00388
	dc.l	$3580328
	dc.l	$2FA02D0
	dc.l	$2A60280
	dc.l	$25C023A
	dc.l	$21A01FC
	dc.l	$1E001C4
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

; extended periods table for some buggy (?) mods

	dc.l	$780071
	dc.l	$6B0065
	dc.l	$5F005A
	dc.l	$550050
	dc.l	$4B0047
	dc.l	$43003F
	dc.l	$3C0038

;lbL000A80:	dc.l	0
;lbW000A84:	dc.w	0
lbL000A86:	dc.w	$3F
;	dc.w	0
;	dc.l	0
;	dc.l	0
;	dc.l	lbL0025E8
;	dc.l	lbL0025B4
;	dc.l	lbL002644
;	dc.l	lbL002610
lbL000AA2:	dc.l	$DFF0A0		; *regbase
	dc.l	0		; <- SamplesInfo
	dc.l	0		; *startpatt
	dc.l	0		; *tmppatt
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	1
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
lbL000AE0:	dc.l	$DFF0B0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	2
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
lbL000B1E:	dc.l	$DFF0C0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	4
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
lbL000B5C:	dc.l	$DFF0D0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	8
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0

	*****************************************************
	****  Soundcontrol 3.0/3.2/4.0/5.0 replayer for	 ****
	****  EaglePlayer, all adaptions by Wanted Team	 ****
	****      DeliTracker compatible (?) version	 ****
	*****************************************************

	incdir	"dh2:include/"
	include 'misc/eagleplayer2.01.i'

	SECTION	Player_Code,CODE

	PLAYERHEADER Tags

	dc.b	'$VER: Soundcontrol 3.0/3.2/4.0/5.0 player module V1.2 (25 Mar 2002)',0
	even
Tags
	dc.l	DTP_PlayerVersion,3
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
	dc.l	EP_Get_ModuleInfo,ModuleInfo
	dc.l	EP_GetPositionNr,GetPosition
	dc.l	DTP_NextPatt,NextPatt
	dc.l	DTP_PrevPatt,PrevPatt
	dc.l	EP_SampleInit,SampleInit
	dc.l	EP_StructInit,StructInit
	dc.l	EP_Flags,EPB_Save!EPB_ModuleInfo!EPB_SampleInfo!EPB_Packable!EPB_Restart!EPB_Songend!EPB_NextPatt!EPB_PrevPatt!EPB_Volume!EPB_Balance!EPB_Voices!EPB_Analyzer
	dc.l	0

PlayerName
	dc.b	'Soundcontrol 3.0/3.2/4.0/5.0',0
Creator
	dc.b	'(c) 1989-95 by Holger Gehrmann,',10
	dc.b	'adapted by Wanted Team',0
Prefix
	dc.b	'SCT.',0,0
Info
	dc.b	'Soundcontrol'
Numer
	dc.b	' WT! module loaded!',0
	even
ModulePtr
	dc.l	0
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
addressA
	dc.b	0
Format
	dc.b	0
EagleBase
	dc.l	0
VideoMode
	dc.w	50
RightVolume
	dc.w	64
LeftVolume
	dc.w	64
StructAdr
	ds.b	UPS_SizeOF

***************************************************************************
******************************* EP_StructInit *****************************
***************************************************************************

StructInit
	lea	StructAdr(PC),A0
	rts

***************************************************************************
******************************* DTP_NextPatt ******************************
***************************************************************************

NextPatt
	cmp.b	#30,Format
	bne.b	Next32
	add.w	#12,lbW018380
	move.w	lbW018380(PC),D0
	move.l	lbL0183A4(PC),A0
	cmp.w	lbL018804(PC),D0
	bne.b	Next1
	bsr.w	SongEnd
	bra.w	InitSound
Next1
	bra.w	lbC0187B6
Next32
	cmp.b	#32,Format
	bne.b	Next40
	add.w	#12,lbW005708
	move.w	lbW005708(PC),D0
	move.l	lbL00572C(PC),A0
	cmp.w	lbW005C64(PC),D0
	bne.b	Next2
	bsr.w	SongEnd
	bra.w	InitSound
Next2
	bra.w	lbC005C10
Next40
	cmp.b	#40,Format
	bne.b	Next50
	add.w	#12,lbW008696
	move.w	lbW008696(PC),D0
	move.l	lbL00867A(PC),A0
	cmp.w	lbW008684(PC),D0
	bne.b	Next3
	bsr.w	SongEnd
	bra.w	InitSound
Next3
	bra.w	lbC008C06
Next50
	add.w	#12,lbW0664BC
	move.w	lbW0664BC(PC),D0
	move.l	lbL0664A0(PC),A0
	cmp.w	lbW0664AA(PC),D0
	bne.b	Next4
	bsr.w	SongEnd
	bra.w	InitSound
Next4
	bra.w	lbC06695A

***************************************************************************
******************************* DTP_PrevPatt ******************************
***************************************************************************

PrevPatt
	cmp.b	#30,Format
	bne.b	Prev32
	move.w	lbW018380(PC),D0
	cmp.w	lbL018800(PC),D0
	beq.b	ExitPrev
	sub.w	#12,lbW018380
	move.l	lbL0183A4(PC),A0
	bra.w	lbC0187B6
Prev32
	cmp.b	#32,Format
	bne.b	Prev40
	move.w	lbW005708(PC),D0
	cmp.w	lbW005C60(PC),D0
	beq.b	ExitPrev
	sub.w	#12,lbW005708
	move.l	lbL00572C(PC),A0
	bra.w	lbC005C10
Prev40
	cmp.b	#40,Format
	bne.b	Prev50
	move.w	lbW008696(PC),D0
	cmp.w	lbW008682(PC),D0
	beq.b	ExitPrev
	sub.w	#12,lbW008696
	move.l	lbL00867A(PC),A0
	bra.w	lbC008C06
Prev50
	move.w	lbW0664BC(PC),D0
	cmp.w	lbW0664A8(PC),D0
	beq.b	ExitPrev
	sub.w	#12,lbW0664BC
	move.l	lbL0664A0(PC),A0
	bra.w	lbC06695A
ExitPrev
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

	add.l	16(A2),A2
	add.w	#1088,A2
	moveq	#-1,D5
	add.l	InfoBuffer+Samples(PC),D5
	moveq	#64,D2
hop
	jsr	ENPP_AllocSampleStruct(A5)
	move.l	D0,(A3)
	beq.b	return
	move.l	D0,A3

	move.l	60(A2),D1
	move.l	A2,EPS_SampleName(A3)		; sample name
	lea	64(A2),A1
	move.l	A1,EPS_Adr(A3)			; sample address
	add.l	D1,A2
	sub.l	D2,D1
	move.l	D1,EPS_Length(A3)		; sample length
	move.l	#64,EPS_Volume(A3)
	move.w	#USITY_RAW,EPS_Type(A3)
	move.w	#16,EPS_MaxNameLen(A3)
	move.w	#USIB_Playable!USIB_Saveable!USIB_8BIT,EPS_Flags(A3)
	dbf	D5,hop

	moveq	#0,D7
return
	move.l	D7,D0
	rts

***************************************************************************
***************************** EP_GetPositionNr ****************************
***************************************************************************

GetPosition
	moveq	#0,D0
	cmp.b	#30,Format
	bne.b	Sc32
	move.w	lbW018380(PC),D0
	bra.b   skip2
Sc32
	cmp.b	#32,Format
	bne.b	SC4
	move.w	lbW005708(PC),D0
	bra.b   skip2
SC4
	cmp.b	#40,Format
	bne.b	SC5
	move.w	lbW008696(PC),D0
	bra.b   skip2
SC5
	move.w	lbW0664BC(PC),D0
skip2
	divu.w	#12,D0
	rts

***************************************************************************
***************************** EP_Get_ModuleInfo ***************************
***************************************************************************
ModuleInfo	
		lea	InfoBuffer(PC),A0
		rts

SubSongs	=	4
LoadSize	=	12
CalcSize	=	20
SongName	=	28
Length		=	36
SamplesSize	=	52
SongSize	=	60
Samples		=	76
Pattern		=	84
Voices		=	100

InfoBuffer
	dc.l	MI_SubSongs,0		;4
	dc.l	MI_LoadSize,0		;12
	dc.l	MI_Calcsize,0		;20
	dc.l	MI_SongName,0		;28
	dc.l	MI_Length,0		;36
	dc.l	MI_SpecialInfo,Info	;44
	dc.l	MI_SamplesSize,0	;52
	dc.l	MI_Songsize,0		;60
	dc.l	MI_MaxSamples,256	;68
	dc.l	MI_Samples,0		;76
	dc.l	MI_Pattern,0		;84
	dc.l	MI_MaxPattern,256	;92
	dc.l	MI_Voices,0		;100
	dc.l	MI_MaxVoices,6
	dc.l	MI_Prefix,Prefix
	dc.l	0

***************************************************************************
******************************* DTP_Check2 ********************************
***************************************************************************

Check2
	movea.l	dtg_ChkData(A5),A0
	moveq	#-1,D0

	cmp.w	#$0003,32(A0)
	beq.b	Later
	cmp.w	#$0002,32(A0)
	bne.b	Fault
	tst.l	28(A0)
	bne.b	Fault
Later
	tst.w	16(A0)
	bne.b	Fault
	move.w	18(A0),D1
	bmi.b	Fault
	btst	#0,D1
	bne.b	Fault
	add.w	D1,A0
	cmp.w	#$FFFF,62(A0)
	bne.b	Fault
	cmp.l	#$00000400,64(A0)
	bne.b	Fault
	moveq	#0,D0
Fault
	rts

***************************************************************************
***************************** DTP_SubSongRange ****************************
***************************************************************************

SubSongRange
	moveq	#0,D0
	move.l	InfoBuffer+SubSongs(PC),D1
	subq.l	#1,D1
	rts

***************************************************************************
***************************** DTP_InitPlayer ******************************
***************************************************************************

InitPlayer
	moveq	#0,D0
	movea.l	dtg_GetListData(A5),A0
	jsr	(A0)

	lea	ModulePtr(PC),A1
	move.l	A0,(A1)				; module buffer

	lea	InfoBuffer(PC),A1
	move.l	D0,LoadSize(A1)

	lea	addressA(PC),A6
	clr.w	(A6)				; clearing addressA & Format

	move.l	ModulePtr(PC),A2
	move.l	A2,A3
	move.l	A2,A4
	moveq	#64,D0
	add.l	16(A2),D0
	add.l	D0,A3
	move.l	20(A2),D2
	add.l	D2,D0
	move.l	24(A2),D1
	add.l	D0,A4
	add.l	D1,D0
	add.l	28(A2),D0
	sub.l	#1024,D2
	move.l	D0,CalcSize(A1)
	cmp.l	LoadSize(A1),D0
	ble.b	SizeOK
	moveq	#EPR_ModuleTooShort,D0		; error message
	rts
SizeOK	
	move.l	D0,SongSize(A1)
	move.l	A2,SongName(A1)
	divu.w	#12,D1
	move.l	D1,Length(A1)	
	subq.w	#1,D1
	moveq	#0,D5
	moveq	#5,D3

nexttrack
	move.l	A4,A0
	move.w	D1,D4
nextpos
	tst.w	(A0)
	bne.b	voicefound
	lea	12(A0),A0
	dbf	D4,nextpos
again
	addq.l	#2,A4
	dbf	D3,nexttrack
	bra.b	last
voicefound
	addq.l	#1,D5
	bra.b	again
last
	move.l	D5,Voices(A1)

	lea	1084(A3),A3
	moveq	#0,D1
	moveq	#0,D3
Samp
	move.l	(A3),D4
	add.l	D4,A3
	add.l	D4,D3
	addq.l	#1,D1
	cmp.l	D3,D2
	bgt.b	Samp

	move.l	D1,Samples(A1)
	lsl.l	#6,D1
	sub.l	D1,D2
	move.l	D2,SamplesSize(A1)
	sub.l	D2,SongSize(A1)

	moveq	#1,D1				; D1 = number of subsongs
	tst.l	28(A2)
	bne.b	next0
	move.b	#$A0,(A6)+			; addressA
	cmp.l	#126446,D0			; fix for NUMBER9
	bne.b	next31
	moveq	#3,D1
	bra.b	SC32
next31	
	cmp.l	#136612,D0			; fix for DOMINATION 1
	bne.b	next32
	moveq	#2,D1
	bra.b	SC32
next32
	cmp.l	#154704,D0			; fix for DYNATSONG
	bne.b	next33
	moveq	#2,D1
	bra.b	SC3.2
next33
	cmp.l	#103808,D0			; fix for ELEVEN6
	bne.b	next34
	bra.b	SC3.2
next34
	clr.w	lbL018800
	move.w	26(A2),lbL018804
SC32
	move.b	#30,(A6)+			; current Format
	move.l	#' 3.0',Numer
	bra.b	skip
SC3.2
	clr.w	lbW005C60
	move.w	26(A2),lbW005C64
	move.b	#32,(A6)+			; current Format
	move.l	#' 3.2',Numer
	bra.b	skip
next0
	addq.l	#1,A6
	cmp.l	#54544,D0			; fix for HNDTITLE
	bne.b	next1
	bra.b	SC40
next1
	cmp.l	#95960,D0			; fix for HNDONGAME2
	bne.b	next2
	moveq	#2,D1
	bra.b	SC40
next2
	cmp.l	#81906,D0			; fix for HNDINTRO
	bne.b	SC50
	moveq	#4,D1
SC40
	move.b	#40,(A6)+			; current Format
	move.l	#' 4.0',Numer
	bra.b	skip
SC50
	addq.l	#1,A6
	move.l	#' 5.0',Numer
skip
	move.l	D1,SubSongs(A1)

	lea	64(A2),A2
	moveq	#0,D2
	move.w	#255,D1
Patt
	tst.w	(A2)+
	beq.b	NextWord
	addq.l	#1,D2
NextWord
	dbf	D1,Patt

	move.l	D2,Pattern(A1)

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

	move.w	dtg_SndNum(A5),D0
	move.l	InfoBuffer+CalcSize(PC),D1
	cmp.b	#30,Format
	bne.b	SC_32
	cmp.l	#126446,D1			; fix for NUMBER9
	bne.b	Domina
	tst.w	D0
	bne.b	SecondNum
	clr.w	lbL018800
	move.w	#$1E0,lbL018804
	bra.b	SC_30
SecondNum
	cmp.w	#1,D0
	bne.b	ThirdNum
	move.w	#$1E0,lbL018800
	move.w	#$2D0,lbL018804
	bra.b	SC_30
ThirdNum
	move.w	#$2D0,lbL018800
	move.w	#$3C0,lbL018804
	bra.b	SC_30
Domina
	cmp.l	#136612,D1			; fix for DOMINATION 1
	bne.b	SC_30
	tst.w	D0
	bne.b	SecondDom
	clr.w	lbL018800
	move.w	#$144,lbL018804
	bra.b	SC_30
SecondDom
	move.w	#$174,lbL018800
	move.w	#$348,lbL018804
;	bra.b	SC_30
SC_30
	bra.w	Init_3

SC_32
	cmp.b	#32,Format
	bne.b	SC_40
	cmp.l	#154704,D1			; fix for DYNATSONG
	bne.b	SCT32
	tst.w	D0
	bne.b	SecondDyna
	clr.w	lbW005C60
	move.w	#$150,lbW005C64
	bra.b	SCT32
SecondDyna
	move.w	#$150,lbW005C60
	move.w	#$2E8,lbW005C64
;	bra.b	SCT32
SCT32
	bra.w	Init_32

SC_40
	cmp.b	#40,Format
	bne.b	SC_50
	move.l	#Buffer,lbL0001C4
	add.w	InfoBuffer+SubSongs+2(PC),D0
	bra.w	Init_4

SC_50
	move.l	#Buffer,lbL066482
	bra.w	Init_5

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

	cmp.b	#30,Format
	bne.b	SC.32
	bsr.w	Play_3
	bra.b	End
SC.32
	cmp.b	#32,Format
	bne.b	SC.40
	bsr.w	Play_32
	bra.b	End
SC.40
	cmp.b	#40,Format
	bne.b	SC.50
	bsr.w	Play_4
	bra.b	End
SC.50
	bsr.w	Play_5
End
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
************************* DTP_Volume, DTP_Balance *************************
***************************************************************************
; Copy Volume and Balance Data to internal buffer

SetBalance
SetVolume
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
	tst.b	addressA
	beq.w	addressA4

; Volume and Balance for Soundcontrol 3.0/3.2 modules

	lea	$DFF0A0,A0
SetNew
	move.w	(A1)+,D2
	bsr.b	SetVoices_A0
	lea	16(A0),A0
	dbf	D1,SetNew
	rts

SetVoices_A0
	and.w	#$7F,D2
	cmpa.l	#$DFF0A0,A0			;Left Volume
	bne.b	NoVoice1
	move.w	D2,OldVoice1
	tst.w	Voice1
	bne.b	Voice1On
	moveq	#0,D2
Voice1On
	mulu.w	LeftVolume(PC),D2
	bra.b	SetIt

NoVoice1
	cmpa.l	#$DFF0B0,A0			;Right Volume
	bne.b	NoVoice2
	move.w	D2,OldVoice2
	tst.w	Voice2
	bne.b	Voice2On
	moveq	#0,D2
Voice2On
	mulu.w	RightVolume(PC),D2
	bra.b	SetIt

NoVoice2
	cmpa.l	#$DFF0C0,A0			;Right Volume
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
	move.w	D2,8(A0)
	rts

*------------------------------- Set Vol -------------------------------*

SetVol
	move.l	A1,-(A7)
	lea	StructAdr+UPS_Voice1Vol(PC),A1
	cmp.l	#$DFF0A0,A0
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice2Vol(PC),A1
	cmp.l	#$DFF0B0,A0
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice3Vol(PC),A1
	cmp.l	#$DFF0C0,A0
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice4Vol(PC),A1
.SetVoice
	move.w	D2,(A1)
	move.l	(A7)+,A1
	rts

*------------------------------- Set Adr -------------------------------*

SetAdr
	move.l	A2,-(A7)
	lea	StructAdr+UPS_Voice1Adr(PC),A2
	cmp.l	#$DFF0A0,A0
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice2Adr(PC),A2
	cmp.l	#$DFF0B0,A0
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice3Adr(PC),A2
	cmp.l	#$DFF0C0,A0
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice4Adr(PC),A2
.SetVoice
	move.l	A1,(A2)
	move.l	(A7)+,A2
	rts

*------------------------------- Set Len -------------------------------*

SetLen
	move.l	A1,-(A7)
	lea	StructAdr+UPS_Voice1Len(PC),A1
	cmp.l	#$DFF0A0,A0
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice2Len(PC),A1
	cmp.l	#$DFF0B0,A0
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice3Len(PC),A1
	cmp.l	#$DFF0C0,A0
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice4Len(PC),A1
.SetVoice
	move.w	D5,(A1)
	move.l	(A7)+,A1
	rts

*------------------------------- Set Per -------------------------------*

SetPer
	move.l	A1,-(A7)
	lea	StructAdr+UPS_Voice1Per(PC),A1
	cmp.l	#$DFF0A0,A0
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice2Per(PC),A1
	cmp.l	#$DFF0B0,A0
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice3Per(PC),A1
	cmp.l	#$DFF0C0,A0
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice4Per(PC),A1
.SetVoice
	move.w	D3,(A1)
	move.l	(A7)+,A1
	rts

; Volume and Balance for Soundcontrol 4.0/5.0 modules

addressA4
	lea	$DFF0A0,A4
SetNewA4
	move.w	(A1)+,D0
	bsr.b	SetVoices_A4
	lea	16(A4),A4
	dbf	D1,SetNewA4
	rts

SetVoices_A4
	move.l	A0,-(A7)
	and.w	#$7F,D0
	cmpa.l	#$DFF0A0,A4			;Left Volume
	bne.b	NoVoice1A4
	move.w	D0,OldVoice1
	tst.w	Voice1
	bne.b	Voice1OnA4
	moveq	#0,D0
Voice1OnA4
	mulu.w	LeftVolume(PC),D0
	bra.b	SetItA4

NoVoice1A4
	cmpa.l	#$DFF0B0,A4			;Right Volume
	bne.b	NoVoice2A4
	move.w	D0,OldVoice2
	tst.w	Voice2
	bne.b	Voice2OnA4
	moveq	#0,D0
Voice2OnA4
	mulu.w	RightVolume(PC),D0
	bra.b	SetItA4

NoVoice2A4
	cmpa.l	#$DFF0C0,A4			;Right Volume
	bne.b	NoVoice3A4
	move.w	D0,OldVoice3
	tst.w	Voice3
	bne.b	Voice3OnA4
	moveq	#0,D0
Voice3OnA4
	mulu.w	RightVolume(PC),D0
	bra.b	SetItA4

NoVoice3A4
	move.w	D0,OldVoice4
	tst.w	Voice4
	bne.b	Voice4OnA4
	moveq	#0,D0
Voice4OnA4
	mulu.w	LeftVolume(PC),D0
SetItA4
	lsr.w	#6,D0
	move.w	D0,8(A4)
	move.l	(A7)+,A0
	rts

*------------------------------- Set Vol -------------------------------*

SetVol_A4
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

SetAdr_A4
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
	move.l	$12(A5),(A0)
	move.l	(A7)+,A0
	rts

*------------------------------- Set Len -------------------------------*

SetLen_A4
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
	move.w	D1,(A0)
	move.l	(A7)+,A0
	rts

*------------------------------- Set Per -------------------------------*

SetPer_A4
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
	move.w	D1,(A0)
	move.l	(A7)+,A0
	rts

***************************************************************************
******************************* EP_Voices *********************************
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
**************************** Soundcontrol 3.0 player **********************
***************************************************************************

; player from game Dynatech (UNDERWATER)

;lbW01A308	dc.w	1

;lbL017F54	dc.l	0
lbL017F58
	ds.b	256		; Table buffer for Soundcontrol 3.0/3.2

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
;	dc.l	0
;	dc.l	0
;	dc.l	0
lbL018258	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbL018358	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbL018370	dc.l	0
lbL018374	dc.l	0
	dc.l	0
lbW01837C	dc.w	0
	dc.w	0
lbW018380	dc.w	0
	dc.w	0
lbW018384	dc.w	0
	dc.w	0
lbW018388	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
lbL018394	dc.l	0
lbL018398	dc.l	0
lbL01839C	dc.l	0
lbL0183A0	dc.l	0
lbL0183A4	dc.l	0
lbL0183A8	dc.l	$D600CA00
	dc.l	$BE80B400
	dc.l	$A980A000
	dc.l	$97008E80
	dc.l	$86807F00
	dc.l	$78007100
	dc.l	$6B000000
	dc.l	0

Play_3
lbC0183C8
;	NOP
	MOVEM.L	D0-D7/A0-A6,-(SP)
	ADDQ.W	#1,lbW018384
;	CMPI.W	#1,lbW01A308

	cmp.w	#50,VideoMode

	BEQ.S	lbC0183EA
	CMPI.W	#6,lbW018384
	BNE.S	lbC0183FE
	BRA.S	lbC0183F4

lbC0183EA	CMPI.W	#3,lbW018384
	BNE.S	lbC0183FE
lbC0183F4	BSR.W	lbC018406
	CLR.W	lbW018384
lbC0183FE	BSR.W	lbC018406
;	BRA.W	lbC018422
lbC018422	MOVEM.L	(SP)+,D0-D7/A0-A6
;	JMP	lbC01842C

lbC01842C	RTS

lbC018406	ADDQ.W	#1,lbW01837C
	CMPI.W	#2,lbW01837C
	BNE.S	lbC018420
	BSR.W	lbC0185F8
	CLR.W	lbW01837C
lbC018420	RTS

Init_3
lbC01842E	MOVEM.L	D0-D7/A0-A6,-(SP)
	MOVE.B	#$FE,$BFE001
;	MOVEA.L	lbL017F54(PC),A0

	move.l	ModulePtr(PC),A0

	LEA	$40(A0),A0
	MOVE.L	A0,lbL018394
	LEA	$200(A0),A0
	MOVE.L	A0,lbL018398
	LEA	lbL017F58(PC),A0
	MOVEQ	#2,D6
lbC018458	LEA	lbL0183A8(PC),A1
	MOVEQ	#0,D7
lbC01845E	MOVE.W	0(A1,D7.W),D0
	LSR.W	D6,D0
	MOVE.W	D0,(A0)+
	ADDQ.L	#2,D7
	CMP.L	#$20,D7
	BNE.S	lbC01845E
	ADDQ.L	#1,D6
	CMP.L	#10,D6
	BNE.S	lbC018458
;	MOVEA.L	lbL017F54(PC),A0

	move.l	ModulePtr(PC),A0

	MOVE.L	$10(A0),D0
	ADDI.L	#$40,D0
	ADD.L	A0,D0
	MOVE.L	D0,lbL01839C
	ADDI.L	#$400,D0
	MOVE.L	D0,lbL0183A0
	MOVE.L	$10(A0),D0
	ADD.L	$14(A0),D0
	ADDI.L	#$40,D0
	ADD.L	A0,D0
	MOVE.L	D0,lbL0183A4
;	ADD.L	$18(A0),D0
;	MOVEA.L	D0,A0
;	CLR.L	(A0)				; bug (?) in replayer
;	CLR.L	4(A0)				; cleared 16 bytes after
;	CLR.L	8(A0)				; end of loaded module and
;	CLR.L	12(A0)				; trashes Amiga memory
	MOVE.W	lbL018800(PC),lbW018380
	BSR.W	lbC0187B6
	MOVE.W	#$800F,$DFF096
	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTS

lbC0184E2	MOVEM.L	D0-D7/A0-A6,-(SP)
	BSR.W	lbC0184F0
	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTS

lbC0184F0	TST.W	$2A(A1)
	BEQ.S	lbC018510
	MOVE.W	$2A(A1),D5
	SUBQ.W	#1,D5
lbC0184FC	ADDQ.W	#1,D0
	MOVE.W	D0,D3
	ANDI.W	#15,D3
	CMP.W	#12,D3
	BNE.S	lbC01850C
	ADDQ.W	#4,D0
lbC01850C	DBRA	D5,lbC0184FC
lbC018510	LEA	lbL017F58(PC),A4
	ANDI.L	#$FF,D0
	ASL.W	#1,D0
	MOVE.W	0(A4,D0.W),D3
	ADDA.W	#$40,A1
	MOVE.L	A1,(A0)

	bsr.w	SetAdr

	MOVE.L	#$10001,4(A0)
;	MOVEQ	#7,D5
	BSR.W	lbC01858E
	MOVE.W	D1,$DFF096
;	MOVE.W	D2,8(A0)

	bsr.w	SetVoices_A0
	bsr.w	SetVol

	MOVE.W	D3,6(A0)

	bsr.w	SetPer

	MOVE.W	-$30(A1),D5
	LSR.W	#1,D5
	MOVE.W	D5,4(A0)

	bsr.w	SetLen

	MOVE.L	A1,(A0)

	bsr.w	SetAdr

	CLR.L	(A1)
	SUBA.W	#$40,A1
	ORI.W	#$8200,D1
	MOVE.W	D1,$DFF096
;	MOVEQ	#3,D5
	BSR.W	lbC01858E
	TST.W	$12(A1)
	BNE.S	lbC018572
	MOVE.W	#1,4(A0)
	RTS

lbC018572	MOVE.W	$14(A1),D5
	SUB.W	$12(A1),D5
	LSR.W	#1,D5
	MOVE.W	D5,4(A0)

	bsr.w	SetLen

	MOVEA.L	A1,A4
	ADDA.W	#$40,A4
	ADDA.W	$12(A1),A4
	MOVE.L	A4,(A0)

	move.l	A1,-(SP)
	move.l	A4,A1
	bsr.w	SetAdr
	move.l	(SP)+,A1

	RTS

lbC01858E				;MRH - new scanline wait...
	movem.l	D0/D1,-(SP)

	moveq	#8,d0
.dma1	move.b	$dff006,d1
.dma2	cmp.b	$dff006,d1
	beq	.dma2
	dbeq	d0,.dma1

	movem.l	(SP)+,D0/D1
	rts

;	MOVEM.W	D0-D2,-(SP)
;lbC018592	MOVE.B	$DFF006,D0
;	MOVE.B	D0,D2
;	ADD.B	D5,D2
;lbC01859C	MOVE.B	$DFF006,D1
;	CMP.B	D0,D1
;	BCS.S	lbC018592
;	CMP.B	D2,D1
;	BCS.S	lbC01859C
;	MOVEM.W	(SP)+,D0-D2
;	RTS

lbC0185B0	MOVEM.L	D0-D7/A0-A6,-(SP)
	BSR.W	lbC0185BE
	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTS

lbC0185BE	TST.W	$2A(A1)
	BEQ.S	lbC0185DE
	MOVE.W	$2A(A1),D5
lbC0185C8	SUBQ.W	#1,D5
	ADDQ.W	#1,D0
	MOVE.W	D0,D3
	ANDI.W	#15,D3
	CMP.W	#12,D3
	BNE.S	lbC0185DA
	ADDQ.W	#4,D0
lbC0185DA	DBRA	D5,lbC0185C8
lbC0185DE	LEA	lbL017F58(PC),A4
	ANDI.L	#$FF,D0
	ASL.W	#1,D0
	MOVE.W	0(A4,D0.W),D3
	MOVE.W	D2,8(A0)
	MOVE.W	D3,6(A0)
	RTS

lbC0185F8	MOVEQ	#3,D7
	LEA	lbL018358(PC),A4
	LEA	lbL018370(PC),A3
	LEA	lbL018258(PC),A5
	LEA	$DFF0A0,A0
	MOVE.W	#1,D6
lbC018610	MOVEA.L	(A4),A2
	TST.W	(A3)
	BNE.S	lbC018622
	MOVE.B	1(A2),1(A3)
	ADDQ.L	#4,(A4)
	BRA.W	lbC018628

lbC018622	SUBQ.W	#1,(A3)
	BRA.W	lbC0186D2

lbC018628	SUBQ.W	#1,(A3)
	CMPI.B	#$FF,(A2)
	BEQ.W	lbC0186EA
	TST.B	(A2)
	BEQ.W	lbC0186D2
	MOVE.B	(A2),D0
	MOVEQ	#0,D3
	MOVE.B	2(A2),D3
	MOVE.B	3(A2),D2
	CMP.B	#$80,D2
	BNE.S	lbC0186A4
;	TST.B	-3(A5)
;	BNE.S	lbC018652
;	NOP
lbC018652	MOVE.B	#1,-3(A5)
	BSR.W	lbC01871E
	BRA.W	lbC0186D2

lbC018660	MOVE.B	#1,-1(A5)
	MOVE.B	D2,-2(A5)
	SF	-3(A5)
	BSR.W	lbC01871E
	MOVE.L	-2(A5),$12(A5)
	MOVE.L	2(A5),$16(A5)
	MOVE.L	6(A5),$1A(A5)
	MOVE.W	10(A5),$1E(A5)
	CLR.L	-2(A5)
	CLR.L	2(A5)
	CLR.L	6(A5)
	CLR.L	10(A5)
	CLR.W	lbW018388
	BRA.W	lbC0186B0

lbC0186A4	TST.W	(A5)
	BNE.S	lbC018660
	SF	-1(A5)
	SF	$13(A5)
lbC0186B0	ASL.W	#2,D3
	ADD.L	lbL01839C(PC),D3
	MOVEA.L	D3,A1
	MOVEA.L	(A1),A1
;	CMPA.L	#$27100,A1
;	BLE.S	lbC0186C8
;	SUBA.L	#$40000,A1
lbC0186C8	ADDA.L	lbL01839C(PC),A1
	MOVE.W	D6,D1
	BSR.W	lbC0184E2
lbC0186D2	ASL.W	#1,D6
	LEA	$28(A5),A5
	ADDA.L	#$10,A0
	ADDQ.L	#4,A4
	ADDQ.L	#2,A3
	DBRA	D7,lbC018610
;	BRA.W	lbC01871C
lbC01871C	RTS

lbC0186EA	ADDI.W	#12,lbW018380
	MOVE.W	lbW018380(PC),D0
	MOVEA.L	lbL0183A4(PC),A0
;	CMPI.B	#1,1(A0,D0.W)
;	BEQ.S	lbC018714
;	CMPI.B	#1,3(A0,D0.W)
;	BEQ.S	lbC018714

	cmp.w	lbL018804(PC),D0
	bne.b	lbC018714
	bsr.w	SongEnd

	MOVE.W	lbL018800(pc),lbW018380
lbC018714	BSR.W	lbC0187B6
	BRA.W	lbC0185F8

lbC01871E	MOVEA.L	A5,A4
	MOVEQ	#6,D4
lbC018722	TST.W	(A4)+
	BEQ.S	lbC01872A
	DBRA	D4,lbC018722
lbC01872A	MOVE.B	D0,-2(A4)
	MOVE.B	D3,-1(A4)
	RTS

;	NOP
;	TST.W	lbW018388
;	BEQ.S	lbC018746
;	SUBQ.W	#1,lbW018388
;	RTS

;lbC018746	LEA	lbL018258(PC),A5
;	LEA	$DFF0A0,A0
;	MOVEQ	#1,D6
;	MOVEQ	#3,D7
lbC018754
;	NOP
	MOVE.B	$13(A5),D2
	BEQ.S	lbC0187A2
	ADDQ.B	#1,$13(A5)
	SUBQ.B	#1,D2
	ASL.B	#1,D2
	ANDI.L	#$FF,D2
	MOVE.B	$14(A5,D2.W),D0
	BNE.S	lbC018778
	MOVE.B	#1,$13(A5)
	BRA.S	lbC018754

lbC018778	MOVE.B	$15(A5,D2.W),D3
	MOVE.B	$12(A5),D2
	ANDI.L	#$FE,D3
	ASL.W	#2,D3
	ADD.L	lbL01839C(PC),D3
	MOVEA.L	D3,A1
	MOVEA.L	(A1),A1
	ADDA.L	lbL01839C(PC),A1
	MOVE.W	D6,D1
	MOVE.W	$30(A1),lbW018388
	BSR.W	lbC0185B0
lbC0187A2	ASL.W	#1,D6
	ADDA.L	#$10,A0
	ADDA.L	#$28,A5
	DBRA	D7,lbC018754
	RTS

lbC0187B6
;	NOP
	MOVEM.L	D0-D7/A0-A6,-(SP)
	LEA	lbL018358(PC),A3
	CLR.L	lbL018370
	CLR.L	lbL018374
	MOVEQ	#5,D7
	CLR.L	D0
	MOVE.W	lbW018380(PC),D0
	MOVEA.L	lbL0183A4(PC),A0
	MOVEA.L	lbL018394(PC),A1
lbC0187DC	CLR.L	D1
	MOVE.B	0(A0,D0.W),D1
	ASL.W	#1,D1
	CLR.L	D2
	MOVE.W	0(A1,D1.W),D2
	ADD.L	A1,D2
	ADDI.L	#$10,D2
	MOVE.L	D2,(A3)+
	ADDQ.L	#2,D0
	DBRA	D7,lbC0187DC
	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTS

lbL018800	dc.l	0
lbL018804	dc.l	0

***************************************************************************
**************************** Soundcontrol 3.2 player **********************
***************************************************************************

; player from game Dynatech (ELEVEN6)

;lbW003B7C	dc.w	0
;lbW003B82	dc.w	0
;lbW003BC0	dc.w	0
;lbW01A308	dc.w	1

;lbL0056DC	dc.l	$50000
lbL0056E0	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbL0056F4	dc.l	0
lbL0056F8	dc.l	0
lbL0056FC	dc.l	0
lbB005700	dc.b	0
	dc.b	0
lbW005702	dc.w	0
lbW005704	dc.w	0
	dc.w	0
lbW005708	dc.w	0
	dc.w	0
lbW00570C	dc.w	0
	dc.w	0
lbW005710	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
lbL00571C	dc.l	0
lbL005720	dc.l	0
lbL005724	dc.l	0
lbL005728	dc.l	0
lbL00572C	dc.l	0
lbL005730	dc.l	0
	dc.l	0
	dc.l	0
lbL00573C	dc.l	$D600CA00
	dc.l	$BE80B400
	dc.l	$A980A000
	dc.l	$97008E80
	dc.l	$86807F00
	dc.l	$78007100
	dc.l	$6B000000
	dc.l	0

Play_32
lbC00575C
;	NOP
;	BTST	#5,$DFF01F
;	BEQ.W	lbC0057DA
;	ADDQ.W	#1,lbW003B7C
;	ADDQ.W	#1,lbW003BC0
	MOVEM.L	D0-D7/A0-A6,-(SP)
	ADDQ.W	#1,lbW00570C
;	TST.W	lbW01A308
;	BEQ.S	lbC005798

	cmp.w	#50,VideoMode
	bne.b	lbC005798

	CMPI.W	#2,lbW00570C
	BNE.S	lbC0057AC
	BSR.W	lbC0057B4
	BRA.S	lbC0057A6

lbC005798	CMPI.W	#4,lbW00570C
	BNE.S	lbC0057AC
	BSR.W	lbC0057B4
lbC0057A6	CLR.W	lbW00570C
lbC0057AC	BSR.W	lbC0057B4
;	BRA.W	lbC0057D6
lbC0057D6	MOVEM.L	(SP)+,D0-D7/A0-A6
;lbC0057DA	JMP	lbC0057E0
;lbL0057DC	EQU	*-4

lbC0057E0	RTS


lbC0057B4	ADDQ.W	#1,lbW005704
	CMPI.W	#2,lbW005704
	BNE.S	lbC0057D4
;	ADDQ.W	#1,lbW003B82
	BSR.W	lbC00599A
	CLR.W	lbW005704
lbC0057D4	RTS



Init_32
lbC0057E2	MOVEM.L	D0-D7/A0-A6,-(SP)
	MOVE.B	#$FE,$BFE001
;	MOVEA.L	lbL0056DC(PC),A0

	move.l	ModulePtr(PC),A0

	LEA	$40(A0),A0
	MOVE.L	A0,lbL00571C
	LEA	$200(A0),A0
	MOVE.L	A0,lbL005720
	LEA	lbL017F58,A0
	MOVEQ	#2,D6
lbC00580E	LEA	lbL00573C(PC),A1
	MOVEQ	#0,D7
lbC005814	MOVE.W	0(A1,D7.W),D0
	LSR.W	D6,D0
	MOVE.W	D0,(A0)+
	ADDQ.L	#2,D7
	CMP.L	#$20,D7
	BNE.S	lbC005814
	ADDQ.L	#1,D6
	CMP.L	#10,D6
	BNE.S	lbC00580E
;	MOVEA.L	lbL0056DC(PC),A0

	move.l	ModulePtr(PC),A0

	MOVE.L	$10(A0),D0
	ADDI.L	#$40,D0
	ADD.L	A0,D0
	MOVE.L	D0,lbL005724
	ADDI.L	#$400,D0
	MOVE.L	D0,lbL005728
	MOVE.L	$10(A0),D0
	ADD.L	$14(A0),D0
	ADDI.L	#$40,D0
	ADD.L	A0,D0
	MOVE.L	D0,lbL00572C
	MOVEA.L	D0,A1
	MOVE.B	#1,(A1)
;	ADD.L	$18(A0),D0
;	MOVEA.L	D0,A0
;	CLR.L	(A0)				; bug (?) in replayer
;	CLR.L	4(A0)				; cleared 16 bytes after
;	CLR.L	8(A0)				; end of loaded module and
;	CLR.L	12(A0)				; trashes Amiga memory
	MOVE.W	lbW005C60(pc),lbW005708
	BSR.W	lbC005C10
	MOVE.W	#$800F,$DFF096
	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTS

lbC00589E	MOVEM.L	D0-D7/A0-A6,-(SP)
	BSR.W	lbC0058AC
	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTS

lbC0058AC	TST.W	$2A(A1)
	BEQ.S	lbC0058CC
	MOVE.W	$2A(A1),D5
	SUBQ.W	#1,D5
lbC0058B8	ADDQ.W	#1,D0
	MOVE.W	D0,D3
	ANDI.W	#15,D3
	CMP.W	#12,D3
	BNE.S	lbC0058C8
	ADDQ.W	#4,D0
lbC0058C8	DBRA	D5,lbC0058B8
lbC0058CC	LEA	lbL017F58(pc),A4
	ANDI.L	#$FF,D0
	ASL.W	#1,D0
	MOVE.W	0(A4,D0.W),D3
	ADDA.W	#$40,A1
	MOVE.L	A1,(A0)

	bsr.w	SetAdr

	MOVE.L	#$10001,4(A0)
;	MOVEQ	#10,D5
;	JSR	lbC01858E

	bsr.w	lbC01858E

	MOVE.W	D1,$DFF096
;	MOVE.W	D2,8(A0)

	bsr.w	SetVoices_A0
	bsr.w	SetVol

	MOVE.W	D3,6(A0)

	bsr.w	SetPer

	MOVE.W	-$30(A1),D5
	LSR.W	#1,D5
	MOVE.W	D5,4(A0)

	bsr.w	SetLen

	MOVE.L	A1,(A0)

	bsr.w	SetAdr

	CLR.L	(A1)
	SUBA.W	#$40,A1
	ORI.W	#$8200,D1
	MOVE.W	D1,$DFF096
;	MOVEQ	#4,D5
;	JSR	lbC01858E

	bsr.w	lbC01858E

	TST.W	$12(A1)
	BNE.S	lbC005934
	MOVE.W	#1,4(A0)
	RTS

lbC005934	MOVE.W	$14(A1),D5
	SUB.W	$12(A1),D5
	LSR.W	#1,D5
	MOVE.W	D5,4(A0)

	bsr.w	SetLen

	MOVEA.L	A1,A4
	ADDA.W	#$40,A4
	ADDA.W	$12(A1),A4
	MOVE.L	A4,(A0)

	move.l	A1,-(SP)
	move.l	A4,A1
	bsr.w	SetAdr
	move.l	(SP)+,A1

	RTS

lbC005950	MOVEM.L	D0-D7/A0-A6,-(SP)
	BSR.W	lbC00595E
	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTS

lbC00595E	TST.W	$2A(A1)
	BEQ.S	lbC00597E
	MOVE.W	$2A(A1),D5
lbC005968	SUBQ.W	#1,D5
	ADDQ.W	#1,D0
	MOVE.W	D0,D3
	ANDI.W	#15,D3
	CMP.W	#12,D3
	BNE.S	lbC00597A
	ADDQ.W	#4,D0
lbC00597A	DBRA	D5,lbC005968
lbC00597E	LEA	lbL017F58(pc),A4
	ANDI.L	#$FF,D0
	ASL.W	#1,D0
	MOVE.W	0(A4,D0.W),D3
	MOVE.W	D2,8(A0)
	MOVE.W	D3,6(A0)
	RTS

lbC00599A	LEA	lbL0056F4(PC),A4
	LEA	lbW005702(PC),A3
	MOVEA.L	(A4),A2
	CMPI.B	#$FF,(A2)
	BEQ.S	lbC0059FC
	TST.W	(A3)
	BNE.S	lbC0059B8
	MOVE.B	1(A2),1(A3)
	ADDQ.L	#4,(A4)
	BRA.S	lbC0059BE

lbC0059B8	SUBQ.W	#1,(A3)
	BRA.W	lbC0059FC

lbC0059BE	SUBQ.W	#1,(A3)
	LEA	lbL005730(PC),A5
	TST.B	(A2)
	BEQ.S	lbC0059FC
	MOVE.B	3(A2),D1
	ANDI.W	#$3F,D1
	BTST	#6,D1
	BEQ.S	lbC0059DA
	ORI.W	#$FF10,D1
lbC0059DA	MOVE.B	2(A2),D0
	SUBQ.B	#1,D0
	CMP.B	#4,D0
	BNE.S	lbC0059F4
	MOVE.B	D1,(A5)
	MOVE.B	D1,1(A5)
	MOVE.B	D1,2(A5)
	MOVE.B	D1,3(A5)
lbC0059F4	ANDI.W	#3,D0
	MOVE.B	D1,0(A5,D0.W)
lbC0059FC	MOVEQ	#3,D7
	LEA	lbL0056E0(PC),A4
	LEA	lbL0056F8(PC),A3
	LEA	lbL018258(pc),A5
	LEA	$DFF0A0,A0
	MOVE.W	#1,D6
lbC005A16	MOVEA.L	(A4),A2
	TST.W	(A3)
	BNE.S	lbC005A28
	MOVE.B	1(A2),1(A3)
	ADDQ.L	#4,(A4)
	BRA.W	lbC005A2E

lbC005A28	SUBQ.W	#1,(A3)
	BRA.W	lbC005B30

lbC005A2E	SUBQ.W	#1,(A3)
	CMPI.B	#$FF,(A2)
	BEQ.W	lbC005B46
	TST.B	(A2)
	BEQ.W	lbC005B30
	MOVE.B	(A2),D0
	MOVEM.L	D1/D7/A4,-(SP)
	LEA	lbL005730(PC),A4
	NOT.W	D7
	ANDI.W	#3,D7
	MOVE.B	0(A4,D7.W),D7
	ADDI.B	#$FF,D7
lbC005A56	TST.B	D7
	BEQ.S	lbC005A84
	BMI.S	lbC005A70
	SUBQ.W	#1,D7
	ADDQ.W	#1,D0
	MOVE.W	D0,D1
	ANDI.W	#15,D1
	CMP.W	#12,D1
	BNE.S	lbC005A56
	ADDQ.W	#4,D0
	BRA.S	lbC005A56

lbC005A70	ADDQ.W	#1,D7
	SUBQ.W	#1,D0
	MOVE.W	D0,D1
	ANDI.W	#15,D1
	CMP.W	#15,D1
	BNE.S	lbC005A56
	SUBQ.W	#4,D0
	BRA.S	lbC005A56

lbC005A84	MOVEM.L	(SP)+,D1/D7/A4
	MOVEQ	#0,D3
	MOVE.B	2(A2),D3
	CMP.B	#$FF,D3
	BNE.S	lbC005A9E
	MOVEQ	#1,D3
	MOVEQ	#0,D2
	CLR.W	(A3)
	BRA.W	lbC005AA2

lbC005A9E	MOVE.B	3(A2),D2
lbC005AA2	CMP.B	#$80,D2
	BNE.S	lbC005B02
;	TST.B	-3(A5)
;	BNE.S	lbC005AB0
;	NOP
lbC005AB0	MOVE.B	#1,-3(A5)
	BSR.W	lbC005B7A
	BRA.W	lbC005B30

lbC005ABE	MOVE.B	#1,-1(A5)
	MOVE.B	D2,-2(A5)
	SF	-3(A5)
	BSR.W	lbC005B7A
	MOVE.L	-2(A5),$12(A5)
	MOVE.L	2(A5),$16(A5)
	MOVE.L	6(A5),$1A(A5)
	MOVE.W	10(A5),$1E(A5)
	CLR.L	-2(A5)
	CLR.L	2(A5)
	CLR.L	6(A5)
	CLR.L	10(A5)
	CLR.W	lbW005710
	BRA.W	lbC005B0E

lbC005B02	TST.W	(A5)
	BNE.S	lbC005ABE
	SF	-1(A5)
	SF	$13(A5)
lbC005B0E	ASL.W	#2,D3
	ADD.L	lbL005724(PC),D3
	MOVEA.L	D3,A1
	MOVEA.L	(A1),A1
;	CMPA.L	#$27100,A1
;	BLE.S	lbC005B26
;	SUBA.L	#$40000,A1
lbC005B26	ADDA.L	lbL005724(PC),A1
	MOVE.W	D6,D1
	BSR.W	lbC00589E
lbC005B30	ASL.W	#1,D6
	LEA	$28(A5),A5
	LEA	$10(A0),A0
	ADDQ.L	#4,A4
	ADDQ.L	#2,A3
	DBRA	D7,lbC005A16
;	BRA.W	lbC005B78
lbC005B78	RTS

lbC005B46	ADDI.W	#12,lbW005708
	MOVE.W	lbW005708(PC),D0
	MOVEA.L	lbL00572C(PC),A0
;	CMPI.B	#1,1(A0,D0.W)
;	BEQ.S	lbC005B70
;	CMPI.B	#1,3(A0,D0.W)
;	BEQ.S	lbC005B70

	cmp.w	lbW005C64(PC),D0
	bne.b	lbC005B70
	bsr.w	SongEnd

	MOVE.W	lbW005C60(pc),lbW005708
lbC005B70	BSR.W	lbC005C10
	BRA.W	lbC00599A

lbC005B7A	MOVEA.L	A5,A4
	MOVEQ	#6,D4
lbC005B7E	TST.W	(A4)+
	BEQ.S	lbC005B86
	DBRA	D4,lbC005B7E
lbC005B86	MOVE.B	D0,-2(A4)
	MOVE.B	D3,-1(A4)
	RTS

;	NOP
;	TST.W	lbW005710
;	BEQ.S	lbC005BA2
;	SUBQ.W	#1,lbW005710
;	RTS

;lbC005BA2	LEA	lbL018258,A5
;	LEA	$DFF0A0,A0
;	MOVEQ	#1,D6
;	MOVEQ	#3,D7
lbC005BB2
;	NOP
	MOVE.B	$13(A5),D2
	BEQ.S	lbC005C00
	ADDQ.B	#1,$13(A5)
	SUBQ.B	#1,D2
	ASL.B	#1,D2
	ANDI.L	#$FF,D2
	MOVE.B	$14(A5,D2.W),D0
	BNE.S	lbC005BD6
	MOVE.B	#1,$13(A5)
	BRA.S	lbC005BB2

lbC005BD6	MOVE.B	$15(A5,D2.W),D3
	MOVE.B	$12(A5),D2
	ANDI.L	#$FE,D3
	ASL.W	#2,D3
	ADD.L	lbL005724(PC),D3
	MOVEA.L	D3,A1
	MOVEA.L	(A1),A1
	ADDA.L	lbL005724(PC),A1
	MOVE.W	D6,D1
	MOVE.W	$30(A1),lbW005710
	BSR.W	lbC005950
lbC005C00	ASL.W	#1,D6
	LEA	$10(A0),A0
	LEA	$28(A5),A5
	DBRA	D7,lbC005BB2
	RTS

lbC005C10
;	NOP
	MOVEM.L	D0-D7/A0-A6,-(SP)
	LEA	lbL0056E0(PC),A3
	CLR.L	lbL0056F8
	CLR.L	lbL0056FC
	CLR.L	lbB005700
	MOVEQ	#5,D7
	MOVEQ	#0,D0
	MOVE.W	lbW005708(PC),D0
	MOVEA.L	lbL00572C(PC),A0
	MOVEA.L	lbL00571C(PC),A1
lbC005C3C	MOVEQ	#0,D1
	MOVE.B	0(A0,D0.W),D1
	ASL.W	#1,D1
	MOVEQ	#0,D2
	MOVE.W	0(A1,D1.W),D2
	ADD.L	A1,D2
	ADDI.L	#$10,D2
	MOVE.L	D2,(A3)+
	ADDQ.L	#2,D0
	DBRA	D7,lbC005C3C
	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTS

lbW005C60	dc.l	0
lbW005C64	dc.l	0

***************************************************************************
**************************** Soundcontrol 4.0 player **********************
***************************************************************************

; player from game Hot Numbers Deluxe

;lbW00001E	dc.w	$32
lbW000144	dc.w	0
lbL0001C4	dc.l	0
lbW000B94	dc.w	0
lbL008662	dc.l	0
lbL008666	dc.l	0
lbL00866A	dc.l	0
lbL00866E	dc.l	0
lbL008672	dc.l	0
lbL008676	dc.l	0
lbL00867A	dc.l	0
;lbL00867E	dc.l	0
lbW008682	dc.w	0
lbW008684	dc.w	0
lbW008686	dc.w	0
lbW008688	dc.w	$6D
lbL00868A	dc.l	0
	dc.l	0
lbW008692	dc.w	$FFFF
lbW008694	dc.w	$FFFF
lbW008696	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	$FFFF
	dc.w	$FFFF
lbL0086A2	dc.l	0
lbL0086A6	dc.l	0
	dc.l	0
lbW0086AE	dc.w	$D600
	dc.w	$CA00
	dc.w	$BE80
	dc.w	$B400
	dc.w	$A980
	dc.w	$A000
	dc.w	$9700
	dc.w	$8E80
	dc.w	$8680
	dc.w	$7F00
	dc.w	$7800
	dc.w	$7100
	dc.w	$6B00
	dc.w	0
	dc.w	0
	dc.w	0
lbL0086CE	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbL0086E2	dc.l	0
lbL0086E6	dc.l	0
lbL0086EA	dc.l	0
lbW0086EE	dc.w	0
lbW0086F0	dc.w	0

Init_4
lbC0086F2
;	TST.L	lbL00867E
;	BEQ.W	lbC0088A4
	MOVEM.L	D0-D7/A0-A6,-(SP)
	MOVE.W	D0,lbW008686
	BSR.W	lbC008902
	CLR.L	lbL00893A
	CLR.L	lbL008A02
	CLR.L	lbL008A4C
	CLR.L	lbL008A96
	MOVE.B	#$FE,$BFE001
;	MOVEA.L	lbL00867E(PC),A0

	move.l	ModulePtr(PC),A0

	MOVE.L	A0,D0
	ADD.L	#$40,D0
	MOVE.L	D0,lbL00866E
	MOVE.L	D0,lbL00866A
	ADDI.L	#$200,lbL00866A
	MOVE.W	$22(A0),lbW008688
	ADD.L	$10(A0),D0
	MOVE.L	D0,lbL008666
	MOVE.L	D0,lbL008662
	ADDI.L	#$400,lbL008662
	ADD.L	$14(A0),D0
	MOVE.L	D0,lbL00867A
	ADD.L	$18(A0),D0
	MOVE.L	D0,lbL008676
	MOVE.L	D0,lbL008672
	ADDI.L	#$200,lbL008672
	CLR.W	lbW008682
	CLR.L	lbL0086A2
	CLR.L	lbL0086A6
	MOVE.W	lbW008682(PC),lbW008696
	MOVE.W	#$108,lbW008684
	CMPI.W	#1,lbW008686
	BEQ.W	lbC00888E
	CMPI.W	#7,lbW008686
	BNE.S	lbC0087DE
	MOVE.W	#$124,lbW008688
	MOVE.W	#$330,lbW008684
	BRA.W	lbC00888E

lbC0087DE	CMPI.W	#4,lbW008686
	BNE.S	lbC00880C
	MOVE.W	#$330,lbW008682
	MOVE.W	#$330,lbW008696
	MOVE.W	#$3F0,lbW008684
	MOVE.W	#$1B3,lbW008688
	BRA.W	lbC00888E

lbC00880C	CMPI.W	#5,lbW008686
	BNE.S	lbC008838
	MOVE.W	#$3F0,lbW008682
	MOVE.W	#$3F0,lbW008696
	MOVE.W	#$4E0,lbW008684
	MOVE.W	#$D2,lbW008688
	BRA.S	lbC00888E

lbC008838	CMPI.W	#6,lbW008686
	BNE.S	lbC008864
	MOVE.W	#$4E0,lbW008682
	MOVE.W	#$4E0,lbW008696
	MOVE.W	#$630,lbW008684
	MOVE.W	#$B5,lbW008688
	BRA.S	lbC00888E

lbC008864	MOVE.W	#$120,lbW008696
	MOVE.W	#$12C,lbW008684
	CMPI.W	#2,lbW008686
	BEQ.S	lbC00888E
	MOVE.W	lbW008682(PC),lbW008696
	MOVE.W	#$120,lbW008684
lbC00888E	BSR.W	lbC008C06
	MOVE.W	#$800F,$DFF096
	MOVEM.L	(SP)+,D0-D7/A0-A6
	CLR.W	lbW008692
lbC0088A4	RTS

Play_4
lbC0088A6	MOVEM.L	D0-D7/A0-A6,-(SP)
	TST.W	lbW008692
	BNE.S	lbC0088BC
	BSR.S	lbC0088C2
	BSR.W	lbC008DE6
	BSR.W	lbC008CDC
lbC0088BC	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTS

lbC0088C2	TST.W	lbW008692
	BNE.S	lbC008900
	MOVE.W	lbW008688(PC),D0
	ADD.W	D0,lbL00868A
lbC0088D4	MOVE.W	#$BB,D0
;	CMPI.W	#$32,lbW00001E

	cmp.w	#50,VideoMode

	BEQ.S	lbC0088E6
	MOVE.W	#$E1,D0
lbC0088E6	CMP.W	lbL00868A(PC),D0
	BCC.S	lbC008900
	SUB.W	D0,lbL00868A
	ADDI.W	#11,lbW000144
	BSR.W	lbC008B4E
	BRA.S	lbC0088D4

lbC008900	RTS

lbC008902	MOVEA.L	lbL0001C4(pc),A0
	MOVEQ	#2,D6
lbC00890A	LEA	lbW0086AE(PC),A1
	MOVEQ	#0,D7
lbC008910	MOVE.W	0(A1,D7.W),D0
	LSR.W	D6,D0
	MOVE.W	D0,(A0)+
	ADDQ.L	#2,D7
	CMP.W	#$18,D7
	BNE.S	lbC008910
	ADDQ.L	#1,D6
	CMP.W	#10,D6
	BNE.S	lbC00890A
	RTS

lbL00892A	dc.l	lbL00893A
	dc.l	lbL008A02
lbL008932	dc.l	lbL008A4C
	dc.l	lbL008A96
lbL00893A	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbL008A02	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
lbL008A4C	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
lbL008A96	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0

lbC008AE0	MOVEM.L	D0-D7/A0-A6,-(SP)
	ASL.W	#2,D7
	LEA	lbL00892A(PC),A2
	MOVEA.L	0(A2,D7.W),A5
	MOVE.W	D3,D5
	ADD.W	D5,D5
	MOVEA.L	lbL008676(PC),A2
	MOVE.W	0(A2,D5.W),D5
	MOVE.W	D3,6(A5)
	ADDA.W	D5,A2
	ADDA.W	#$30,A2
	MOVE.L	A2,(A5)
	MOVE.W	D2,$10(A5)
	CLR.W	$1C(A5)
	CLR.W	4(A5)
	MOVE.L	A5,$26(A5)
	ADDI.L	#$2A,$26(A5)
	MOVE.W	D0,D4
	AND.W	#15,D4
	AND.W	#$F0,D0
	LSR.W	#2,D0
	ADD.W	D0,D4
	ADD.W	D0,D0
	ADD.W	D0,D4
	ADD.W	(A4),D4
	MOVE.W	D4,12(A5)
	CLR.W	$22(A5)
	MOVE.W	#1,$20(A5)
	CLR.W	$1E(A5)
	CLR.W	$24(A5)
	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTS

lbC008B4E	BSR.W	lbC008C64
	LEA	lbL0086CE(PC),A5
	LEA	lbL0086E6(PC),A3
	LEA	lbL0086A2(PC),A4
	LEA	$DFF0A0,A0
	MOVEQ	#0,D7
lbC008B66	MOVEA.L	(A5),A2
	TST.W	(A3)
	BEQ.S	lbC008B70
	SUBQ.W	#1,(A3)
	BRA.S	lbC008BCC

lbC008B70	MOVE.B	1(A2),1(A3)
	ADDQ.L	#4,(A5)
	SUBQ.W	#1,(A3)
	CMPI.B	#$FF,(A2)
	BEQ.S	lbC008BE0
	TST.B	(A2)
	BEQ.S	lbC008BCC
	MOVEQ	#0,D0
	MOVE.B	(A2),D0
	BEQ.S	lbC008BCC
	MOVEQ	#0,D3
	MOVE.B	2(A2),D3
	CMP.B	#$FF,D3
	BEQ.W	lbC008C54
	MOVEQ	#0,D2
	MOVE.B	3(A2),D2
	CMP.B	#$80,D2
	MOVEA.L	lbL008676(PC),A1
	MOVE.W	D3,D5
	ASL.W	#1,D5
	MOVE.W	0(A1,D5.W),D5
	ADDA.L	D5,A1
	CMP.W	lbW008694(PC),D7
	BEQ.S	lbC008BCC
	TST.W	lbW000B94
	BEQ.S	lbC008BC8
	MOVE.W	#15,$DFF096
	BRA.S	lbC008BCC

lbC008BC8	BSR.W	lbC008AE0
lbC008BCC	LEA	$10(A0),A0
	ADDQ.L	#2,A3
	ADDQ.L	#2,A4
	ADDQ.L	#4,A5
	ADDQ.W	#1,D7
	CMP.W	#4,D7
	BNE.S	lbC008B66
	RTS

lbC008BE0	ADDI.W	#12,lbW008696
	MOVE.W	lbW008696(PC),D0
	MOVEA.L	lbL00867A(PC),A0
	CMP.W	lbW008684(PC),D0
	BNE.S	lbC008BFE

	bsr.w	SongEnd

	MOVE.W	lbW008682(PC),lbW008696
lbC008BFE	BSR.S	lbC008C06
	BRA.W	lbC008B4E

;	RTS

lbC008C06	MOVEM.L	D0-D7/A0-A6,-(SP)
	LEA	lbL0086CE(PC),A3
	CLR.L	lbL0086E6
	CLR.L	lbL0086EA
	CLR.L	lbW0086EE
	MOVEQ	#0,D0
	MOVE.W	lbW008696(PC),D0
	MOVEA.L	lbL00867A(PC),A0
	MOVEA.L	lbL00866E(PC),A1
	MOVEQ	#5,D7
lbC008C30	MOVEQ	#0,D1
	MOVE.B	0(A0,D0.W),D1
	ASL.W	#1,D1
	MOVEQ	#0,D2
	MOVE.W	0(A1,D1.W),D2
	ADD.L	A1,D2
	ADD.L	#$10,D2
	MOVE.L	D2,(A3)+
	ADDQ.L	#2,D0
	DBRA	D7,lbC008C30
	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTS

lbC008C54	BRA.S	lbC008BE0

;	ADDI.W	#12,lbW008696
;	BSR.S	lbC008C06
;	BRA.W	lbC008B4E

lbC008C64	MOVEA.L	lbL0086E2(PC),A2
	LEA	lbW0086F0(PC),A3
	LEA	lbL0086A2(PC),A5
	TST.W	(A3)
	BEQ.S	lbC008C78
	SUBQ.W	#1,(A3)
	BRA.S	lbC008CD0

lbC008C78	MOVE.B	1(A2),1(A3)
	ADDQ.L	#4,lbL0086E2
	SUBQ.W	#1,(A3)
	TST.B	(A2)
	BEQ.S	lbC008CD0
	CMPI.B	#$FF,(A2)
	BEQ.S	lbC008CD2
	MOVE.B	3(A2),D1
	AND.W	#$3F,D1
	BTST	#6,D1
	BEQ.S	lbC008CA2
	OR.W	#$FF10,D1
lbC008CA2	MOVE.B	2(A2),D0
	SUBQ.B	#1,D0
	CMP.B	#4,D0
	BNE.S	lbC008CBE
	MOVE.W	D1,(A5)
	MOVE.W	D1,2(A5)
	MOVE.W	D1,4(A5)
	MOVE.W	D1,6(A5)
	BRA.S	lbC008CD0

lbC008CBE	MOVE.W	#$F00,$DFF180
	AND.W	#3,D0
	ADD.W	D0,D0
	MOVE.W	D1,0(A5,D0.W)
lbC008CD0	RTS

lbC008CD2	SUBQ.L	#4,lbL0086E2
	RTS

;	RTS

lbC008CDC	LEA	lbL00892A(PC),A0
	LEA	lbL008D3C(PC),A1
	LEA	$DFF0A0,A4
	MOVEA.L	lbL008676(PC),A3
	MOVEQ	#0,D7
lbC008CF0	MOVEA.L	(A0)+,A5
	TST.W	$20(A5)
	BEQ.S	lbC008CFE
	SUBQ.W	#1,$20(A5)
	BRA.S	lbC008D16

lbC008CFE	MOVE.W	$1E(A5),D0
	ASL.W	#2,D0
	MOVEA.L	0(A1,D0.W),A2
	MOVE.W	6(A5),D0
	ADD.W	D0,D0
	MOVEA.L	A3,A6
	ADDA.W	0(A3,D0.W),A6
	JSR	(A2)
lbC008D16	MOVEQ	#0,D0
	MOVE.W	$10(A5),D0
	MULU.W	$22(A5),D0
	LSR.W	#8,D0
;	LSR.W	#1,D0
	CMP.W	lbW008694(PC),D7
	BEQ.S	lbC008D2E
;	MOVE.W	D0,8(A4)

	bsr.w	SetVoices_A4
	bsr.w	SetVol_A4

lbC008D2E	LEA	$10(A4),A4
	ADDQ.W	#1,D7
	CMP.W	#4,D7
	BNE.S	lbC008CF0
	RTS

lbL008D3C	dc.l	lbC008D50
	dc.l	lbC008D78
	dc.l	lbC008DA2
	dc.l	lbC008DB0
	dc.l	lbC008DCC

lbC008D50	MOVEQ	#0,D0
	MOVE.B	$13(A6),D0
	ADD.W	D0,$22(A5)
	CMPI.W	#$100,$22(A5)
	BLT.S	lbC008D6C
	MOVE.W	#$100,$22(A5)
	ADDQ.W	#1,$1E(A5)
lbC008D6C	MOVEQ	#0,D0
	MOVE.B	$12(A6),D0
	MOVE.W	D0,$20(A5)
	RTS

lbC008D78	MOVEQ	#0,D0
	MOVE.B	$15(A6),D0
	SUB.W	D0,$22(A5)
	MOVEQ	#0,D1
	MOVE.B	$17(A6),D1
	CMP.W	$22(A5),D1
	BLT.S	lbC008D96
	MOVE.W	D1,$22(A5)
	ADDQ.W	#1,$1E(A5)
lbC008D96	MOVEQ	#0,D0
	MOVE.B	$14(A6),D0
	MOVE.W	D0,$20(A5)
	RTS

lbC008DA2	CMPI.W	#$80,$24(A5)
	BNE.S	lbC008DAE
	ADDQ.W	#1,$1E(A5)
lbC008DAE	RTS

lbC008DB0	MOVEQ	#0,D0
	MOVE.B	$19(A6),D0
	SUB.W	D0,$22(A5)
	BCC.S	lbC008DC0
	CLR.W	$22(A5)
lbC008DC0	MOVEQ	#0,D0
	MOVE.B	$18(A6),D0
	MOVE.W	D0,$20(A5)
	RTS

lbC008DCC	RTS

;	MOVEM.L	D7/A0/A5,-(SP)
;	LEA	lbL00892A(PC),A0
;	MOVEQ	#3,D7
;lbC008DD8	MOVEA.L	(A0)+,A5
;	CLR.L	(A5)
;	DBRA	D7,lbC008DD8
;	MOVEM.L	(SP)+,D7/A0/A5
;	RTS

lbC008DE6	MOVEQ	#1,D4
	LEA	$DFF0A0,A4
	LEA	lbL00892A(PC),A0
	MOVEQ	#3,D7
lbC008DF4	MOVEA.L	(A0)+,A5
	CMPA.L	#0,A5
	BEQ.S	lbC008E08
	MOVEM.L	D0-D7/A0-A6,-(SP)
	BSR.S	lbC008E14
	MOVEM.L	(SP)+,D0-D7/A0-A6
lbC008E08	ASL.W	#1,D4
	ADDA.W	#$10,A4
	DBRA	D7,lbC008DF4
	RTS

lbC008E14	MOVE.L	lbL008666(PC),D3
	MOVEA.L	(A5),A0
	CMPA.L	#0,A0
	BEQ.S	lbC008E66
	LEA	lbL008E68(PC),A2
lbC008E26	TST.W	4(A5)
	BNE.S	lbC008E60
	MOVEA.L	A0,A1
	MOVEM.W	(A0)+,D0/D5/D6
	BTST	#14,D0
	BEQ.S	lbC008E40
	MOVE.W	D5,D1
	ADD.W	D1,D1
	MOVE.W	$3A(A5,D1.W),D5
lbC008E40	BTST	#15,D0
	BEQ.S	lbC008E4E
	MOVE.W	D6,D1
	ADD.W	D1,D1
	MOVE.W	$3A(A5,D1.W),D6
lbC008E4E	AND.W	#$1F,D0
	ASL.W	#2,D0
	MOVEA.L	0(A2,D0.W),A3
	JSR	(A3)
	LEA	6(A1),A0
	BRA.S	lbC008E26

lbC008E60	SUBQ.W	#1,4(A5)
	MOVE.L	A0,(A5)
lbC008E66	RTS

lbL008E68	dc.l	lbC008EF4
	dc.l	lbC008EFE
	dc.l	lbC008F3A
	dc.l	lbC008F40
	dc.l	lbC008F4E
	dc.l	lbC008F6C
	dc.l	lbC008F7A
	dc.l	lbC008F9C
	dc.l	lbC008FAC
	dc.l	lbC008FCC
	dc.l	lbC008FE6
	dc.l	lbC008FFE
	dc.l	lbC009030
	dc.l	lbC00903C
	dc.l	lbC009048
	dc.l	lbC00904A
	dc.l	lbC0090E8
	dc.l	lbC0090E8
	dc.l	lbC0090E8
	dc.l	lbC0090E8
	dc.l	lbC0090E8
	dc.l	lbC0090E8
	dc.l	lbC0090E8
	dc.l	lbC0090E8
	dc.l	lbC0090E8
	dc.l	lbC0090E8
	dc.l	lbC0090E8
	dc.l	lbC0090E8
	dc.l	lbC0090E8
	dc.l	lbC0090E8
	dc.l	lbC0090E8
	dc.l	lbC0090E8
lbL008EE8	dc.l	lbC00905C
	dc.l	lbC009084
	dc.l	lbC0090BA

lbC008EF4	SUBQ.L	#6,A1
	MOVE.W	#1,4(A5)
	RTS

lbC008EFE	MOVE.W	D5,D1
	MOVE.W	D1,8(A5)
	ASL.W	#2,D1
	MOVEA.L	D3,A6
	ADDA.L	0(A6,D1.W),A6
	MOVE.L	A6,$16(A5)
	MOVE.W	$10(A6),$1A(A5)
	MOVE.W	12(A5),D4
	ADD.W	$2A(A6),D4
	MOVE.W	D4,14(A5)
	MOVEA.L	lbL0001C4(pc),A3
	ADD.W	D4,D4
	MOVE.W	0(A3,D4.W),10(A5)
	LEA	$40(A6),A6
	MOVE.L	A6,$12(A5)
	RTS

lbC008F3A	MOVE.W	D5,4(A5)
	RTS

lbC008F40	MOVEA.L	$16(A5),A6
	LEA	$40(A6),A6
	ADDA.W	D5,A6
	MOVE.L	A6,(A4)
	RTS

lbC008F4E	MOVE.W	D5,D1
	MOVE.W	D1,8(A5)
	MOVEA.L	D3,A6
	ASL.W	#2,D1
	ADDA.L	0(A6,D1.W),A6
	MOVE.L	A6,$16(A5)
	LEA	$40(A6),A6
	MOVE.L	A6,(A4)
	MOVE.L	A6,$12(A5)
	RTS

lbC008F6C	MOVE.W	D5,D1
	MOVE.W	D1,$1A(A5)
	LSR.W	#1,D1
	MOVE.W	D1,4(A4)

	bsr.w	SetLen_A4

	RTS

lbC008F7A	MOVE.W	D5,D1
	MOVE.W	D1,8(A5)
	MOVEA.L	D3,A6
	ASL.W	#2,D1
	ADDA.L	0(A6,D1.W),A6
	MOVE.L	A6,$16(A5)
	MOVE.W	$10(A6),D1
	MOVE.W	D1,$1A(A5)
	LSR.W	#1,D1
	MOVE.W	D1,4(A4)

	bsr.w	SetLen_A4

	RTS

lbC008F9C	MOVE.W	10(A5),D1
	ADD.W	D5,D1
	MOVE.W	D1,6(A4)

	bsr.w	SetPer_A4

	MOVE.W	D1,10(A5)
	RTS

lbC008FAC	MOVE.W	14(A5),D1
	ADD.W	D5,D1
	MOVE.W	D1,14(A5)
	ADD.W	D1,D1
	MOVEA.L	lbL0001C4(pc),A6
	MOVE.W	0(A6,D1.W),D1
	MOVE.W	D1,10(A5)
	MOVE.W	D1,6(A4)

	bsr.w	SetPer_A4

	RTS

lbC008FCC	MOVE.W	$10(A5),D1
	ADD.W	D5,D1
	TST.W	D1
	BPL.S	lbC008FD8
	MOVEQ	#0,D1
lbC008FD8	CMP.W	#$40,D1
	BCS.S	lbC008FE0
	MOVEQ	#$40,D1
lbC008FE0	MOVE.W	D1,$10(A5)
	RTS

lbC008FE6	MOVEA.L	$26(A5),A6
	ADDQ.L	#4,A6
	MOVE.L	A0,(A6)
	SUBQ.L	#6,(A6)
	MOVE.L	A6,$26(A5)
	MOVE.W	D5,D1
	ADD.W	D1,D1
	MOVE.W	D6,$3A(A5,D1.W)
	RTS

lbC008FFE	MOVEA.L	$26(A5),A6
	MOVEA.L	(A6),A6
	MOVE.W	2(A6),D1
	ADD.W	D1,D1
	MOVE.W	D6,D0
	ADD.W	D0,$3A(A5,D1.W)
	MOVE.W	D5,D0
	TST.W	D6
	BMI.S	lbC009020
	CMP.W	$3A(A5,D1.W),D0
	BCS.S	lbC00902A
	MOVEA.L	A6,A1
	RTS

lbC009020	CMP.W	$3A(A5,D1.W),D0
	BCC.S	lbC00902A
	MOVEA.L	A6,A1
	RTS

lbC00902A	SUBQ.L	#4,$26(A5)
	RTS

lbC009030	MOVE.W	D6,D0
	MOVE.W	D5,D1
	ADD.W	D1,D1
	ADD.W	D0,$3A(A5,D1.W)
	RTS

lbC00903C	MOVE.W	D6,D0
	MOVE.W	D5,D1
	ADD.W	D1,D1
	MOVE.W	D0,$3A(A5,D1.W)
	RTS

lbC009048	RTS

lbC00904A	MOVE.W	$1C(A5),D1
	ADDQ.W	#4,$1C(A5)
	LEA	lbL008EE8(PC),A3
	MOVEA.L	0(A3,D1.W),A3
	JMP	(A3)

lbC00905C	MOVE.L	$12(A5),(A4)

	bsr.w	SetAdr_A4

	OR.W	#$8200,D4
	MOVE.W	D4,$DFF096
	AND.W	#15,D4
	MOVE.L	#$10001,4(A4)
	CLR.W	8(A4)
	MOVE.W	#1,4(A5)
	SUBQ.L	#6,A1
	RTS

lbC009084	MOVE.W	D4,$DFF096
	MOVE.W	10(A5),6(A4)

	move.l	D1,-(SP)
	move.w	10(A5),D1
	bsr.w	SetPer_A4
	move.l	(SP)+,D1

	MOVE.W	$1A(A5),D1
	LSR.W	#1,D1
	MOVE.W	D1,4(A4)

	bsr.w	SetLen_A4

	MOVEA.L	$16(A5),A6
	CLR.L	$40(A6)
	OR.W	#$8200,D4
	MOVE.W	D4,$DFF096
	AND.W	#15,D4
	MOVE.W	#1,4(A5)
	SUBQ.L	#6,A1
	RTS

lbC0090BA	CLR.W	$1C(A5)
	MOVEA.L	$16(A5),A6
	MOVE.W	$14(A6),D0
	BEQ.S	lbC0090E0
	SUB.W	$12(A6),D0
	LSR.W	#1,D0
	MOVE.W	D0,4(A4)
	MOVE.W	$12(A6),D0
	LEA	$40(A6),A6
	ADDA.W	D0,A6
	MOVE.L	A6,(A4)
	RTS

lbC0090E0	MOVE.W	#2,4(A4)
	RTS

lbC0090E8	RTS

***************************************************************************
**************************** Soundcontrol 5.0 player **********************
***************************************************************************

; player from game Biing (Bipro v1.01 file)

;lbW062AE0	dc.w	$32
lbW06647E	dc.w	0
lbW066480	dc.w	0
lbL066482	dc.l	0
;lbW066486	dc.w	$FFFF
lbL066488	dc.l	0
lbL06648C	dc.l	0
lbL066490	dc.l	0
lbL066494	dc.l	0
lbL066498	dc.l	0
lbL06649C	dc.l	0
lbL0664A0	dc.l	0
;lbL0664A4	dc.l	0
lbW0664A8	dc.w	0
lbW0664AA	dc.w	0
lbW0664AC	dc.w	0
lbW0664AE	dc.w	$6D
lbW0664B0	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
lbW0664B8	dc.w	$FFFF
lbW0664BA	dc.w	$FFFF
lbW0664BC	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	$FFFF
	dc.w	$FFFF
lbW0664C8	dc.w	0
lbW0664CA	dc.w	$40
lbW0664CC	dc.w	15
lbL0664CE	dc.l	0
lbL0664D2	dc.l	0
	dc.l	0
lbW0664DA	dc.w	$D600
	dc.w	$CA00
	dc.w	$BE80
	dc.w	$B400
	dc.w	$A980
	dc.w	$A000
	dc.w	$9700
	dc.w	$8E80
	dc.w	$8680
	dc.w	$7F00
	dc.w	$7800
	dc.w	$7100
	dc.w	$6B00
	dc.w	0
	dc.w	0
	dc.w	0
lbL0664FA	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbL06650E	dc.l	0
lbL066512	dc.l	0
lbL066516	dc.l	0
lbW06651A	dc.w	0
lbW06651C	dc.w	0

Init_5
;	TST.L	lbL0664A4
;	BEQ.W	lbC0665F4
;	TST.W	lbW066486
;	BNE.W	lbC0665F4
	MOVEM.L	D0-D7/A0-A6,-(SP)
	MOVE.W	D0,lbW0664AC
	BSR.W	lbC066676
	CLR.L	lbL0666AC
	CLR.L	lbL066774
	CLR.L	lbL0667BE
	CLR.L	lbL066808
	MOVE.B	#$FE,$BFE001
;	MOVEA.L	lbL0664A4(PC),A0

	movea.l	ModulePtr(PC),A0

	MOVE.L	A0,D0
	ADD.L	#$40,D0
	MOVE.L	D0,lbL066494
	MOVE.L	D0,lbL066490
	ADDI.L	#$200,lbL066490
	MOVE.W	$22(A0),lbW0664AE
	ADD.L	$10(A0),D0
	MOVE.L	D0,lbL06648C
	MOVE.L	D0,lbL066488
	ADDI.L	#$400,lbL066488
	ADD.L	$14(A0),D0
	MOVE.L	D0,lbL0664A0
	ADD.L	$18(A0),D0
	MOVE.L	D0,lbL06649C
	MOVE.L	D0,lbL066498
	ADDI.L	#$200,lbL066498
	CLR.W	lbW0664A8
	CLR.L	lbL0664CE
	CLR.L	lbL0664D2
	MOVE.W	lbW0664A8(PC),lbW0664BC
	MOVE.L	$18(A0),D0
	MOVE.W	D0,lbW0664AA
	BSR.W	lbC06695A
	MOVEM.L	(SP)+,D0-D7/A0-A6
lbC0665F4	CLR.W	lbW0664B8
	RTS

Play_5
lbC0665FC	MOVEM.L	D0-D7/A0-A6,-(SP)
	TST.W	lbW0664B8
	BNE.S	lbC06661A
	BSR.S	lbC066620
;	TST.W	lbW066486
;	BNE.S	lbC06661A
	BSR.W	lbC066B3E
	BSR.W	lbC066A28
lbC06661A	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTS

lbC066620	TST.W	lbW0664B8
	BNE.S	lbC066674
	MOVE.W	lbW0664AE(PC),D0
	ADD.W	D0,lbW0664B0
lbC066632	MOVE.W	#$2E,D0
;	CMPI.W	#$32,lbW062AE0

	cmp.w	#50,VideoMode

	BEQ.S	lbC066644
	MOVE.W	#$38,D0
lbC066644	CMP.W	lbW0664B0(PC),D0
	BCC.S	lbC066674
	SUB.W	D0,lbW0664B0
	ADDQ.W	#1,lbW06647E
	ADDQ.W	#1,lbW066480
	MOVE.W	lbW066480(PC),D0
	AND.W	#3,D0
	BNE.S	lbC066672
;	TST.W	lbW066486
;	BNE.S	lbC066632
	BSR.W	lbC0668C4
lbC066672	BRA.S	lbC066632

lbC066674	RTS

lbC066676	MOVEA.L	lbL066482(PC),A0
	MOVEQ	#2,D6
lbC06667C	LEA	lbW0664DA(PC),A1
	MOVEQ	#0,D7
lbC066682	MOVE.W	0(A1,D7.W),D0
	LSR.W	D6,D0
	MOVE.W	D0,(A0)+
	ADDQ.L	#2,D7
	CMP.W	#$18,D7
	BNE.S	lbC066682
	ADDQ.L	#1,D6
	CMP.W	#10,D6
	BNE.S	lbC06667C
	RTS

lbL06669C	dc.l	lbL0666AC
	dc.l	lbL066774
	dc.l	lbL0667BE
	dc.l	lbL066808
lbL0666AC	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbL066774	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
lbL0667BE	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
lbL066808	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0

lbC066852	MOVEM.L	D0-D7/A0-A6,-(SP)
	ASL.W	#2,D7
	LEA	lbL06669C(PC),A2
	MOVEA.L	0(A2,D7.W),A5
	MOVE.W	D3,D5
	ADD.W	D5,D5
	MOVEA.L	lbL06649C(PC),A2
	MOVE.W	0(A2,D5.W),D5
	MOVE.W	D3,6(A5)
	ADDA.W	D5,A2
	ADDA.W	#$30,A2
	MOVE.L	A2,(A5)
	MOVE.W	D2,$10(A5)
	CLR.W	$1C(A5)
	CLR.W	4(A5)
	MOVE.L	A5,$26(A5)
	ADDI.L	#$2A,$26(A5)
	MOVE.W	D0,D4
	AND.W	#15,D4
	AND.W	#$F0,D0
	LSR.W	#2,D0
	ADD.W	D0,D4
	ADD.W	D0,D0
	ADD.W	D0,D4
	ADD.W	(A4),D4
	ADD.W	lbW0664C8(PC),D4
	MOVE.W	D4,12(A5)
	CLR.W	$22(A5)
	MOVE.W	#1,$20(A5)
	CLR.W	$1E(A5)
	CLR.W	$24(A5)
	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTS

lbC0668C4	BSR.W	lbC0669B8
	LEA	lbL0664FA(PC),A5
	LEA	lbL066512(PC),A3
	LEA	lbL0664CE(PC),A4
	LEA	$DFF0A0,A0
	MOVEQ	#0,D7
lbC0668DC	MOVEA.L	(A5),A2
	TST.W	(A3)
	BEQ.S	lbC0668E6
	SUBQ.W	#1,(A3)
	BRA.S	lbC066922

lbC0668E6	MOVE.B	1(A2),1(A3)
	ADDQ.L	#4,(A5)
	SUBQ.W	#1,(A3)
	CMPI.B	#$FF,(A2)
	BEQ.S	lbC066936
	TST.B	(A2)
	BEQ.S	lbC066922
	MOVEQ	#0,D0
	MOVE.B	(A2),D0
	BEQ.S	lbC066922
	MOVEQ	#0,D3
	MOVE.B	2(A2),D3
	CMP.B	#$FF,D3
	BEQ.W	lbC0669A8
	MOVEQ	#0,D2
	MOVE.B	3(A2),D2
	CMP.B	#$80,D2
	CMP.W	lbW0664BA(PC),D7
	BEQ.S	lbC066922
	BSR.W	lbC066852
lbC066922	LEA	$10(A0),A0
	ADDQ.L	#2,A3
	ADDQ.L	#2,A4
	ADDQ.L	#4,A5
	ADDQ.W	#1,D7
	CMP.W	#4,D7
	BNE.S	lbC0668DC
	RTS

lbC066936	ADDI.W	#12,lbW0664BC
	MOVE.W	lbW0664BC(PC),D0
	MOVEA.L	lbL0664A0(PC),A0
	CMP.W	lbW0664AA(PC),D0
	BNE.S	lbC066954

	bsr.w	SongEnd

	MOVE.W	lbW0664A8(PC),lbW0664BC
lbC066954	BSR.S	lbC06695A
	BRA.W	lbC0668C4

lbC06695A	MOVEM.L	D0-D7/A0-A6,-(SP)
	LEA	lbL0664FA(PC),A3
	CLR.L	lbL066512
	CLR.L	lbL066516
	CLR.L	lbW06651A
	MOVEQ	#0,D0
	MOVE.W	lbW0664BC(PC),D0
	MOVEA.L	lbL0664A0(PC),A0
	MOVEA.L	lbL066494(PC),A1
	MOVEQ	#5,D7
lbC066984	MOVEQ	#0,D1
	MOVE.B	0(A0,D0.W),D1
	ASL.W	#1,D1
	MOVEQ	#0,D2
	MOVE.W	0(A1,D1.W),D2
	ADD.L	A1,D2
	ADD.L	#$10,D2
	MOVE.L	D2,(A3)+
	ADDQ.L	#2,D0
	DBRA	D7,lbC066984
	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTS

lbC0669A8	BRA.S	lbC066936

;	ADDI.W	#12,lbW0664BC
;	BSR.S	lbC06695A
;	BRA.W	lbC0668C4

lbC0669B8	MOVEA.L	lbL06650E(PC),A2
	LEA	lbW06651C(PC),A3
	LEA	lbL0664CE(PC),A5
	TST.W	(A3)
	BEQ.S	lbC0669CC
	SUBQ.W	#1,(A3)
	BRA.S	lbC066A1C

lbC0669CC	MOVE.B	1(A2),1(A3)
	ADDQ.L	#4,lbL06650E
	SUBQ.W	#1,(A3)
	TST.B	(A2)
	BEQ.S	lbC066A1C
	CMPI.B	#$FF,(A2)
	BEQ.S	lbC066A1E
	MOVE.B	3(A2),D1
	AND.W	#$3F,D1
	BTST	#6,D1
	BEQ.S	lbC0669F6
	OR.W	#$FF10,D1
lbC0669F6	MOVE.B	2(A2),D0
	SUBQ.B	#1,D0
	CMP.B	#4,D0
	BNE.S	lbC066A12
	MOVE.W	D1,(A5)
	MOVE.W	D1,2(A5)
	MOVE.W	D1,4(A5)
	MOVE.W	D1,6(A5)
	BRA.S	lbC066A1C

lbC066A12	AND.W	#3,D0
	ADD.W	D0,D0
	MOVE.W	D1,0(A5,D0.W)
lbC066A1C	RTS

lbC066A1E	SUBQ.L	#4,lbL06650E
	RTS

;	RTS

lbC066A28	LEA	lbL06669C(PC),A0
	LEA	lbL066A94(PC),A1
	LEA	$DFF0A0,A4
	MOVEA.L	lbL06649C(PC),A3
	MOVEQ	#0,D7
lbC066A3C	MOVEA.L	(A0)+,A5
	TST.W	$20(A5)
	BEQ.S	lbC066A4A
	SUBQ.W	#1,$20(A5)
	BRA.S	lbC066A62

lbC066A4A	MOVE.W	$1E(A5),D0
	ASL.W	#2,D0
	MOVEA.L	0(A1,D0.W),A2
	MOVE.W	6(A5),D0
	ADD.W	D0,D0
	MOVEA.L	A3,A6
	ADDA.W	0(A3,D0.W),A6
	JSR	(A2)
lbC066A62	MOVEQ	#0,D0
	MOVE.W	$10(A5),D0
	MULU.W	$22(A5),D0
	LSR.W	#8,D0
	CMP.W	lbW0664BA(PC),D7
	BEQ.S	lbC066A86
	MOVE.W	lbW0664CC(PC),D1
	BTST	D7,D1
	BEQ.S	lbC066A86
	MULU.W	lbW0664CA(PC),D0
	LSR.W	#6,D0
;	MOVE.W	D0,8(A4)

	bsr.w	SetVoices_A4
	bsr.w	SetVol_A4

lbC066A86	LEA	$10(A4),A4
	ADDQ.W	#1,D7
	CMP.W	#4,D7
	BNE.S	lbC066A3C
	RTS

lbL066A94	dc.l	lbC066AA8
	dc.l	lbC066AD0
	dc.l	lbC066AFA
	dc.l	lbC066B08
	dc.l	lbC066B24

lbC066AA8	MOVEQ	#0,D0
	MOVE.B	$13(A6),D0
	ADD.W	D0,$22(A5)
	CMPI.W	#$100,$22(A5)
	BLT.S	lbC066AC4
	MOVE.W	#$100,$22(A5)
	ADDQ.W	#1,$1E(A5)
lbC066AC4	MOVEQ	#0,D0
	MOVE.B	$12(A6),D0
	MOVE.W	D0,$20(A5)
	RTS

lbC066AD0	MOVEQ	#0,D0
	MOVE.B	$15(A6),D0
	SUB.W	D0,$22(A5)
	MOVEQ	#0,D1
	MOVE.B	$17(A6),D1
	CMP.W	$22(A5),D1
	BLT.S	lbC066AEE
	MOVE.W	D1,$22(A5)
	ADDQ.W	#1,$1E(A5)
lbC066AEE	MOVEQ	#0,D0
	MOVE.B	$14(A6),D0
	MOVE.W	D0,$20(A5)
	RTS

lbC066AFA	CMPI.W	#$80,$24(A5)
	BNE.S	lbC066B06
	ADDQ.W	#1,$1E(A5)
lbC066B06	RTS

lbC066B08	MOVEQ	#0,D0
	MOVE.B	$19(A6),D0
	SUB.W	D0,$22(A5)
	BCC.S	lbC066B18
	CLR.W	$22(A5)
lbC066B18	MOVEQ	#0,D0
	MOVE.B	$18(A6),D0
	MOVE.W	D0,$20(A5)
	RTS

lbC066B24	RTS

;	MOVEM.L	D7/A0/A5,-(SP)
;	LEA	lbL06669C(PC),A0
;	MOVEQ	#3,D7
;lbC066B30	MOVEA.L	(A0)+,A5
;	CLR.L	(A5)
;	DBRA	D7,lbC066B30
;	MOVEM.L	(SP)+,D7/A0/A5
;	RTS

lbC066B3E	MOVEQ	#1,D4
	LEA	$DFF0A0,A4
	LEA	lbL06669C(PC),A0
	MOVEQ	#3,D7
lbC066B4C	MOVEA.L	(A0)+,A5
	CMPA.L	#0,A5
	BEQ.S	lbC066B60
	MOVEM.L	D0-D7/A0-A6,-(SP)
	BSR.S	lbC066B6C
	MOVEM.L	(SP)+,D0-D7/A0-A6
lbC066B60	ASL.W	#1,D4
	ADDA.W	#$10,A4
	DBRA	D7,lbC066B4C
	RTS

lbC066B6C	MOVE.L	lbL06648C(PC),D3
	MOVEA.L	(A5),A0
	CMPA.L	#0,A0
	BEQ.S	lbC066BBE
	LEA	lbL066BC0(PC),A2
lbC066B7E	TST.W	4(A5)
	BNE.S	lbC066BB8
	MOVEA.L	A0,A1
	MOVEM.W	(A0)+,D0/D5/D6
	BTST	#14,D0
	BEQ.S	lbC066B98
	MOVE.W	D5,D1
	ADD.W	D1,D1
	MOVE.W	$3A(A5,D1.W),D5
lbC066B98	BTST	#15,D0
	BEQ.S	lbC066BA6
	MOVE.W	D6,D1
	ADD.W	D1,D1
	MOVE.W	$3A(A5,D1.W),D6
lbC066BA6	AND.W	#$1F,D0
	ASL.W	#2,D0
	MOVEA.L	0(A2,D0.W),A3
	JSR	(A3)
	LEA	6(A1),A0
	BRA.S	lbC066B7E

lbC066BB8	SUBQ.W	#1,4(A5)
	MOVE.L	A0,(A5)
lbC066BBE	RTS

lbL066BC0	dc.l	lbC066C4C
	dc.l	lbC066C56
	dc.l	lbC066C90
	dc.l	lbC066C96
	dc.l	lbC066CA4
	dc.l	lbC066CC2
	dc.l	lbC066CD0
	dc.l	lbC066CF2
	dc.l	lbC066D02
	dc.l	lbC066D20
	dc.l	lbC066D3A
	dc.l	lbC066D52
	dc.l	lbC066D84
	dc.l	lbC066D90
	dc.l	lbC066D9C
	dc.l	lbC066D9E
	dc.l	lbC066E3C
	dc.l	lbC066E3C
	dc.l	lbC066E3C
	dc.l	lbC066E3C
	dc.l	lbC066E3C
	dc.l	lbC066E3C
	dc.l	lbC066E3C
	dc.l	lbC066E3C
	dc.l	lbC066E3C
	dc.l	lbC066E3C
	dc.l	lbC066E3C
	dc.l	lbC066E3C
	dc.l	lbC066E3C
	dc.l	lbC066E3C
	dc.l	lbC066E3C
	dc.l	lbC066E3C
lbL066C40	dc.l	lbC066DB0
	dc.l	lbC066DD8
	dc.l	lbC066E0E

lbC066C4C	SUBQ.L	#6,A1
	MOVE.W	#1,4(A5)
	RTS

lbC066C56	MOVE.W	D5,D1
	MOVE.W	D1,8(A5)
	ASL.W	#2,D1
	MOVEA.L	D3,A6
	ADDA.L	0(A6,D1.W),A6
	MOVE.L	A6,$16(A5)
	MOVE.W	$10(A6),$1A(A5)
	MOVE.W	12(A5),D4
	ADD.W	$2A(A6),D4
	MOVE.W	D4,14(A5)
	MOVEA.L	lbL066482(PC),A3
	ADD.W	D4,D4
	MOVE.W	0(A3,D4.W),10(A5)
	LEA	$40(A6),A6
	MOVE.L	A6,$12(A5)
	RTS

lbC066C90	MOVE.W	D5,4(A5)
	RTS

lbC066C96	MOVEA.L	$16(A5),A6
	LEA	$40(A6),A6
	ADDA.W	D5,A6
	MOVE.L	A6,(A4)
	RTS

lbC066CA4	MOVE.W	D5,D1
	MOVE.W	D1,8(A5)
	MOVEA.L	D3,A6
	ASL.W	#2,D1
	ADDA.L	0(A6,D1.W),A6
	MOVE.L	A6,$16(A5)
	LEA	$40(A6),A6
	MOVE.L	A6,(A4)
	MOVE.L	A6,$12(A5)
	RTS

lbC066CC2	MOVE.W	D5,D1
	MOVE.W	D1,$1A(A5)
	LSR.W	#1,D1
	MOVE.W	D1,4(A4)

	bsr.w	SetLen_A4

	RTS

lbC066CD0	MOVE.W	D5,D1
	MOVE.W	D1,8(A5)
	MOVEA.L	D3,A6
	ASL.W	#2,D1
	ADDA.L	0(A6,D1.W),A6
	MOVE.L	A6,$16(A5)
	MOVE.W	$10(A6),D1
	MOVE.W	D1,$1A(A5)
	LSR.W	#1,D1
	MOVE.W	D1,4(A4)

	bsr.w	SetLen_A4

	RTS

lbC066CF2	MOVE.W	10(A5),D1
	ADD.W	D5,D1
	MOVE.W	D1,6(A4)

	bsr.w	SetPer_A4

	MOVE.W	D1,10(A5)
	RTS

lbC066D02	MOVE.W	14(A5),D1
	ADD.W	D5,D1
	MOVE.W	D1,14(A5)
	ADD.W	D1,D1
	MOVEA.L	lbL066482(PC),A6
	MOVE.W	0(A6,D1.W),D1
	MOVE.W	D1,10(A5)
	MOVE.W	D1,6(A4)

	bsr.w	SetPer_A4

	RTS

lbC066D20	MOVE.W	$10(A5),D1
	ADD.W	D5,D1
	TST.W	D1
	BPL.S	lbC066D2C
	MOVEQ	#0,D1
lbC066D2C	CMP.W	#$40,D1
	BCS.S	lbC066D34
	MOVEQ	#$40,D1
lbC066D34	MOVE.W	D1,$10(A5)
	RTS

lbC066D3A	MOVEA.L	$26(A5),A6
	ADDQ.L	#4,A6
	MOVE.L	A0,(A6)
	SUBQ.L	#6,(A6)
	MOVE.L	A6,$26(A5)
	MOVE.W	D5,D1
	ADD.W	D1,D1
	MOVE.W	D6,$3A(A5,D1.W)
	RTS

lbC066D52	MOVEA.L	$26(A5),A6
	MOVEA.L	(A6),A6
	MOVE.W	2(A6),D1
	ADD.W	D1,D1
	MOVE.W	D6,D0
	ADD.W	D0,$3A(A5,D1.W)
	MOVE.W	D5,D0
	TST.W	D6
	BMI.S	lbC066D74
	CMP.W	$3A(A5,D1.W),D0
	BCS.S	lbC066D7E
	MOVEA.L	A6,A1
	RTS

lbC066D74	CMP.W	$3A(A5,D1.W),D0
	BCC.S	lbC066D7E
	MOVEA.L	A6,A1
	RTS

lbC066D7E	SUBQ.L	#4,$26(A5)
	RTS

lbC066D84	MOVE.W	D6,D0
	MOVE.W	D5,D1
	ADD.W	D1,D1
	ADD.W	D0,$3A(A5,D1.W)
	RTS

lbC066D90	MOVE.W	D6,D0
	MOVE.W	D5,D1
	ADD.W	D1,D1
	MOVE.W	D0,$3A(A5,D1.W)
	RTS

lbC066D9C	RTS

lbC066D9E	MOVE.W	$1C(A5),D1
	ADDQ.W	#4,$1C(A5)
	LEA	lbL066C40(PC),A3
	MOVEA.L	0(A3,D1.W),A3
	JMP	(A3)

lbC066DB0	MOVE.L	$12(A5),(A4)

	bsr.w	SetAdr_A4

	OR.W	#$8200,D4
	MOVE.W	D4,$DFF096
	AND.W	#15,D4
	MOVE.L	#$10001,4(A4)
	CLR.W	8(A4)
	MOVE.W	#1,4(A5)
	SUBQ.L	#6,A1
	RTS

lbC066DD8	MOVE.W	D4,$DFF096
	MOVE.W	10(A5),6(A4)

	move.l	D1,-(SP)
	move.w	10(A5),D1
	bsr.w	SetPer_A4
	move.l	(SP)+,D1

	MOVE.W	$1A(A5),D1
	LSR.W	#1,D1
	MOVE.W	D1,4(A4)

	bsr.w	SetLen_A4

	MOVEA.L	$16(A5),A6
	CLR.L	$40(A6)
	OR.W	#$8200,D4
	MOVE.W	D4,$DFF096
	AND.W	#15,D4
	MOVE.W	#1,4(A5)
	SUBQ.L	#6,A1
	RTS

lbC066E0E	CLR.W	$1C(A5)
	MOVEA.L	$16(A5),A6
	MOVE.W	$14(A6),D0
	BEQ.S	lbC066E34
	SUB.W	$12(A6),D0
	LSR.W	#1,D0
	MOVE.W	D0,4(A4)
	MOVE.W	$12(A6),D0
	LEA	$40(A6),A6
	ADDA.W	D0,A6
	MOVE.L	A6,(A4)
	RTS

lbC066E34	MOVE.W	#2,4(A4)
	RTS

lbC066E3C	RTS

	Section TableBuffer,BSS

Buffer
	ds.b	192

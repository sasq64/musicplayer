	*****************************************************
	****       TFMX ST replayer for EaglePlayer,     ****
	****	     all adaptions by Wanted Team	 ****
	****      DeliTracker compatible (?) version	 ****
	*****************************************************

	incdir	"dh2:include/"
	include 'misc/eagleplayer2.01.i'
	include	'hardware/custom.i'

	SECTION	Player_Code,CODE

	PLAYERHEADER Tags

	dc.b	'$VER: TFMX ST player module V1.0 (10 May 2007)',0
	even
Tags
	dc.l	DTP_PlayerVersion,1
	dc.l	EP_PlayerVersion,9
	dc.l	DTP_RequestDTVersion,DELIVERSION
	dc.l	DTP_PlayerName,PlayerName
	dc.l	DTP_Creator,Creator
	dc.l	DTP_Check2,Check2
	dc.l	DTP_ExtLoad,ExtLoad
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
	dc.l	EP_GetPositionNr,GetPosition
	dc.l	DTP_NextPatt,Next_Pattern
	dc.l	DTP_PrevPatt,BackPattern
	dc.l	EP_Flags,EPB_Volume!EPB_Balance!EPB_ModuleInfo!EPB_LoadFast!EPB_Voices!EPB_PrevPatt!EPB_NextPatt!EPB_Songend!EPB_Analyzer!EPB_NextSong!EPB_PrevSong!EPB_Packable!EPB_Restart
	dc.l	DTP_DeliBase,DeliBase
	dc.l	EP_EagleBase,Eagle2Base
	dc.l	0

PlayerName
	dc.b	'TFMX ST',0
Creator
	dc.b	'(c) 1991-92 by Chris Huelsbeck,',10
	dc.b	'adapted by Wanted Team',0
TFMXmdat
	dc.b	'mdat.',0
TFMXsmpl
	dc.b	'smpl.',0
	even
DeliBase
	dc.l	0
Eagle2Base
	dc.l	0
ModulePtr
	dc.l	0
EagleBase
	dc.l	0
SamplePtr
	dc.l	0
SubsongsTable
	ds.b	32
MacrosNr
	dc.w	0
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
***************************** DTP_EndSound ********************************
***************************************************************************

EndSound
	bsr.w	alloff
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
	movem.l	D1-D7/A0-A6,-(A7)

	lea	StructAdr(PC),A2
	st	UPS_Enabled(A2)
	clr.w	UPS_Voice1Per(A2)
	clr.w	UPS_Voice2Per(A2)
	clr.w	UPS_Voice3Per(A2)
	clr.w	UPS_Voice4Per(A2)
	move.w	#UPSB_Adr!UPSB_Len!UPSB_Per!UPSB_Vol,UPS_Flags(A2)

	lea	CHfield2(PC),A0
	cmp.b	#-1,patterns(A0)
	bne.b	Play
	addq.l	#4,A0
	cmp.b	#-1,patterns(A0)
	bne.b	Play
	addq.l	#4,A0
	cmp.b	#-1,patterns(A0)
	bne.b	Play
	addq.l	#4,A0
	cmp.b	#-1,patterns(A0)
	bne.b	Play
	addq.l	#4,A0
	cmp.b	#-1,patterns(A0)
	bne.b	Play
	addq.l	#4,A0
	cmp.b	#-1,patterns(A0)
	bne.b	Play
	addq.l	#4,A0
	cmp.b	#-1,patterns(A0)
	bne.b	Play
	addq.l	#4,A0
	cmp.b	#-1,patterns(A0)
	bne.b	Play

	move.l	EagleBase(PC),A5
	move.l	dtg_SongEnd(A5),A1
	jsr	(A1)
Play
	lea	lbL000E26(PC),A3
	bsr.w	irqin
	bsr.w	Play_Emu

	lea	StructAdr(PC),A2
	clr.w	UPS_Enabled(A2)

	movem.l	(A7)+,D1-D7/A0-A6
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
******************************* DTP_NextPatt ******************************
***************************************************************************

Next_Pattern
	move.w	LastUsed(PC),D0
	cmp.w	CurrentPos(PC),D0
	beq.b	MaxPos
	addq.w	#1,CurrentPos
	bsr.w	SongNumber
	bra.w	playcont
MaxPos
	rts

***************************************************************************
******************************* DTP_BackPatt ******************************
***************************************************************************

BackPattern
	move.w	FirstUsed(PC),D0
	cmp.w	CurrentPos(PC),D0
	beq.b	MinPos
	subq.w	#1,CurrentPos
	bsr.w	SongNumber
	bra.w	playcont
MinPos
	rts

***************************************************************************
********************************* EP_GetPosNr *****************************
***************************************************************************

GetPosition
	moveq	#0,D0
	move.w	CurrentPos(PC),D0
	sub.w	FirstUsed(PC),D0
	bpl.b	PosOK
	move.w	CurrentPos(PC),D0
PosOK
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

SubSongs	=	4
LoadSize	=	12
Songsize	=	20
Length		=	28
Samples		=	36
Calcsize	=	44
Pattern		=	52
Author		=	60

InfoBuffer
	dc.l	MI_SubSongs,0		;4
	dc.l	MI_LoadSize,0		;12
	dc.l	MI_Songsize,0		;20
	dc.l	MI_Length,0		;28
	dc.l	MI_Samples,0		;36
	dc.l	MI_Calcsize,0		;44
	dc.l	MI_Pattern,0		;52
	dc.l	MI_AuthorName,0		;60
	dc.l	MI_SpecialInfo,Header
	dc.l	MI_MaxSubSongs,32
	dc.l	MI_MaxPattern,128
	dc.l	MI_MaxLength,512
	dc.l	MI_Prefix,TFMXmdat
	dc.l	0

***************************************************************************
******************************* DTP_Check2 ********************************
***************************************************************************

Check2
	movea.l	dtg_ChkData(A5),A0
	moveq	#-1,D0

	cmp.l	#'TFMX',(A0)
	bne.w	Fault
	cmp.l	#'-SON',4(A0)
	bne.w	Fault
	cmp.w	#'G ',8(A0)
	bne.w	Fault
	move.l	464(A0),D1
	bne.b	OK2
	tst.w	12(A0)
	bne.w	Fault
	move.l	#2048,D1
OK2
	move.l	468(A0),D2
	beq.b	NoPack
	move.l	472(A0),D1
	move.l	(A0,D1.L),D1
	bra.b	CheckST
NoPack
	move.l	1536(A0),D1
	beq.b	Fault
	bmi.b	Fault
	btst	#0,D1
	bne.b	Fault
	move.l	2044(A0),D2
	beq.b	Fault
	bmi.b	Fault
	btst	#0,D2
	bne.b	Fault
CheckST
	lea	(A0,D2.L),A1
	lea	(A0,D1.L),A0

	moveq	#0,D1
	moveq	#0,D2
CheckForST
	cmp.b	#72,(A0)			; sample check
	bne.b	NoDigi
	addq.l	#1,D1
NoDigi
	cmp.b	#63,(A0)
	bhi.b	STMac				; here ST
Back1
	addq.l	#4,A0
	cmp.l	A0,A1
	bne.b	CheckForST
	tst.l	D2
	beq.b	Fault
	lea	InfoBuffer+Samples(PC),A0
	move.l	D1,(A0)
	moveq	#0,D0
Fault
	rts

STMac
	addq.l	#1,D2
	bra.b	Back1

***************************************************************************
******************************* DTP_ExtLoad *******************************
***************************************************************************

ExtLoad
	move.l	InfoBuffer+Samples(PC),D0
	beq.b	Fault
	movea.l	dtg_PathArrayPtr(A5),A0
	clr.b	(A0)
	movea.l	dtg_CopyDir(A5),A0
	jsr	(A0)
	bsr.s	CopyName
	movea.l	dtg_LoadFile(A5),A0
	jmp	(A0)

CopyName
	move.l	dtg_PathArrayPtr(a5),a0
loop	tst.b	(a0)+
	bne.s	loop
	subq.l	#1,a0
	lea	TFMXsmpl(pc),a1
smpl	move.b	(a1)+,(a0)+
	bne.s	smpl
	subq.l	#1,a0

	move.l	dtg_FileArrayPtr(a5),a1
	lea	TFMXmdat(pc),a2
mdat	move.b	(a2)+,d0
	beq.s	copy
	move.b	(a1)+,d1
	bset	#5,d1
	cmp.b	d0,d1
	beq.s	mdat

	move.l	dtg_FileArrayPtr(a5),a1
copy	move.b	(a1)+,(a0)+
	bne.s	copy
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
	lea	lbL001070,A0
	tst.l	(A0)
	bne.b	SampOK
	bsr.w	InitSamp
	move.l	#$B2B24D4D,(A0)
SampOK
	moveq	#0,D0
	movea.l	dtg_GetListData(A5),A0
	jsr	(A0)

	lea	ModulePtr(PC),A1
	move.l	A0,(A1)+			; songdata buffer
	move.l	A5,(A1)+			; EagleBase
	clr.l	(A1)				; SamplePtr

	lea	InfoBuffer(PC),A2	; A2 reserved for InfoBuffer
	move.l	D0,LoadSize(A2)

	lea	SubsongsTable(PC),A3
	move.l	A3,A4
	clr.b	(A3)+
	moveq	#0,D1			; subsongs check
	moveq	#30,D5
	move.l	A0,A1			; A0 reserved for later use
	lea	60(A1),A6
Next
	addq.l	#1,D1
	move.w	258(A1),D2
	move.w	322(A1),D3
	bne.b	NoZero
	tst.b	(A4)
	bne.b	NoSub
NoZero
	cmp.w	#$1FF,D2
	beq.b	NoSub

	cmp.l	A1,A6
	bgt.b	CheckLater
	cmp.w	320(A1),D3
	beq.b	NoSub
CheckLater
	cmp.w	324(A1),D3
	bne.b	NoLast
	cmp.w	260(A1),D2
	beq.b	ReallyLast
NoLast
	move.b	D1,(A3)+
NoSub
	subq.l	#1,D5
	addq.l	#2,A1
	tst.l	D5
	bmi.b	Exit
	bra.b	Next
ReallyLast
	tst.b	(A4)
	bne.b	SkipPrev
	st	(A4)
	cmp.w	320(A1),D3
	beq.b	NoSub
SkipPrev
	move.w	D3,D4
	sub.w	D2,D4
	beq.b	NoSub

	cmp.l	A1,A6
	bgt.b	NoSub

	cmp.w	326(A1),D3
	bne.b	NoLast
	bra.b	NoSub

Exit
	clr.b	(A4)
	sub.l	A4,A3
	move.l	A3,SubSongs(A2)

	move.l	A0,A4
	add.l	D0,A4

	move.l	464(A0),D2
	bne.w	Packed

	move.l	A0,A3			; calculate length of songdata
	lea	1024(A3),A1
	add.l	2044(A3),A3
FindEndMacro
	cmp.l	#$07000000,(A3)+
	beq.b	LastMacro
	cmp.l	A3,A4
	bgt.b	FindEndMacro
	moveq	#EPR_ModuleTooShort,D0		; error message
	rts
LastMacro
	sub.l	A0,A3
	move.l	A3,Songsize(A2)
	move.l	A3,Calcsize(A2)

	lea	512(A1),A4

	moveq	#127,D4			; calculate number of patterns
	moveq	#0,D5
CheckPattern
	tst.l	D4
	beq.b	LastPattern
	subq.l	#1,D4
NextPattern
	move.l	(A1)+,D1
	move.l	(A1),D2
	sub.l	D1,D2
	cmp.w	#8,D2
	beq.b	CheckPattern
	addq.l	#1,D5
	dbf	D4,NextPattern
LastPattern
	move.l	D5,Pattern(A2)
back1
	lea	16(A0),A3
	lea	Header,A1
	lea	248(A1),A0
	moveq	#5,D3
NextLine
	moveq	#39,D2
copy2
	move.b	(A3),(A0)+
	move.b	(A3)+,(A1)+
	dbf	D2,copy2
	move.b	#10,(A1)+	                 ; insert linefeeds
	clr.b	(A0)+
	dbf	D3,NextLine
	clr.w	(A1)
	clr.w	(A0)

	tst.l	Samples(A2)
	beq.b	NoConv

	moveq	#1,D0
	movea.l	dtg_GetListData(A5),A0
	jsr	(A0)

	lea	SamplePtr(PC),A1
	move.l	A0,(A1)				; sample buffer
	add.l	D0,LoadSize(A2)
	add.l	D0,Calcsize(A2)

	move.l	4(A0),D1
	and.l	#$F0F0F0F0,D1
	bne.b	NoConv
	lea	(A0,D0.L),A1			; samples end
	bsr.b	Conv
NoConv
	move.l	Eagle2Base(PC),D0
	bne.b	Eagle2
	move.l	DeliBase(PC),D0
	bne.b	NoName
Eagle2
	bsr.b	FindName
NoName
	movea.l	dtg_AudioAlloc(A5),A0
	jmp	(A0)

FindName
	lea	Header+248,A1			; A1 - begin sampleinfo
	move.l	A1,EPG_ARG1(A5)
	moveq	#41,D0				; D0 - length per one sampleinfo
	move.l	D0,EPG_ARG2(A5)
	moveq	#40,D0				; D0 - max. sample name
	move.l	D0,EPG_ARG3(A5)
	moveq	#6,D0				; D0 - max. samples number
	move.l	D0,EPG_ARG4(A5)
	moveq	#4,D0
	move.l	D0,EPG_ARGN(A5)
	jsr	ENPP_FindAuthor(A5)
	move.l	EPG_ARG1(A5),Author(A2)		; output
	rts

Conv
	lea	Bit8Table(PC),A3
NextByte
	move.b	(A0),D0
	and.w	#15,D0
	move.b	0(A3,D0.W),(A0)+
	cmp.l	A1,A0
	blt.b	NextByte
	rts

Bit8Table
	dc.b	0
	dc.b	$93
	dc.b	$A7
	dc.b	$BF
	dc.b	$CF
	dc.b	$DF
	dc.b	$EF
	dc.b	$FF
	dc.b	15
	dc.b	$1F
	dc.b	$2F
	dc.b	$3F
	dc.b	$4F
	dc.b	$5F
	dc.b	$6F
	dc.b	$7F

OneMacro
	move.l	D4,A3
FindStop3
	tst.b	(A3)
	bmi.b	back2
	subq.l	#4,A3
	bra.b	FindStop3
Packed
	move.l	468(A0),D1
	lea	(A0,D1.L),A3
	move.l	(A3),D2
FindStop1
	cmp.l	#$07000000,-(A3)
	bne.b	FindStop1
	move.l	A3,D4
FindStop2
	cmp.l	#'    ',(A3)
	beq.b	OneMacro
	cmp.l	#$07000000,-(A3)
	bne.b	FindStop2
back2
	addq.l	#4,A3
	sub.l	A0,A3
	move.l	472(A0),D3
	lea	(A0,D3.L),A1
	moveq	#0,D4
NextLong
	addq.l	#1,D4
	move.l	(A1)+,D1
	beq.b	Error
	bmi.b	Error
	cmp.l	D1,A3
	beq.b	EndLong
	cmp.l	A1,A4
	bgt.b	NextLong
Error
	moveq	#EPR_ModuleTooShort,D0		; error message
	rts
EndLong
	sub.l	A0,A1
	move.l	A1,Songsize(A2)
	move.l	A1,Calcsize(A2)

	sub.l	464(A0),D2
	lsr.l	#4,D2
	move.l	D2,Pattern(A2)
	move.w	D4,MacrosNr
	lea	(A0,D3.L),A4
	bra.w	back1

***************************************************************************
***************************** DTP_EndPlayer *******************************
***************************************************************************

EndPlayer
	movea.l	dtg_AudioFree(A5),A0
	jmp	(A0)

***************************************************************************
***************************** DTP_InitSound *******************************
***************************************************************************

SongNumber
	moveq	#0,D0
	move.w	dtg_SndNum(A5),D0
	lea	SubsongsTable(PC),A0
	move.b	(A0,D0.W),D0
	rts

InitSound
	lea	StructAdr(PC),A0
	lea	UPS_SizeOF(A0),A1
ClearUPS
	clr.w	(A0)+
	cmp.l	A0,A1
	bne.b	ClearUPS

	bsr.w	Init_Emu

	move.l	ModulePtr(PC),D0
	move.l	SamplePtr(PC),D1
	bsr.w	initdata
	bsr.b	SongNumber
	move.l	D0,D1
	move.l	ModulePtr(PC),A3
	lsl.l	#1,D1
	add.l	D1,A3
	move.w	320(A3),D6
	sub.w	256(A3),D6
	addq.w	#1,D6
	lea	InfoBuffer(PC),A1
	move.w	D6,Length+2(A1)
	bra.w	songplay

***************************************************************************
*************************** DTP_Volume DTP_Balance ************************
***************************************************************************

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
Exit2
	move.l	(A7)+,D1
	rts

*-------------------------------- Set Vol -------------------------------*

SetVol
	move.l	A0,-(SP)
	lea	StructAdr+UPS_Voice1Vol(PC),A0
	cmp.l	#$DFF0A0,A1
	beq.b	.SetVoice
	lea	StructAdr+UPS_Voice2Vol(PC),A0
	cmp.l	#$DFF0B0,A1
	beq.b	.SetVoice
	lea	StructAdr+UPS_Voice3Vol(PC),A0
	cmp.l	#$DFF0C0,A1
	beq.b	.SetVoice
	lea	StructAdr+UPS_Voice4Vol(PC),A0
.SetVoice
	move.w	D0,(A0)
	move.l	(SP)+,A0
	rts

*-------------------------------- Set Two -------------------------------*

SetTwo
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
	move.l	A2,(A0)
	move.w	D4,UPS_Voice1Len(A0)
	move.l	(SP)+,A0
	rts

*-------------------------------- Set Per -------------------------------*

SetPer
	move.l	A0,-(SP)
	lea	StructAdr+UPS_Voice1Per(PC),A0
	cmp.l	#$DFF0A0,A1
	beq.b	.SetVoice
	lea	StructAdr+UPS_Voice2Per(PC),A0
	cmp.l	#$DFF0B0,A1
	beq.b	.SetVoice
	lea	StructAdr+UPS_Voice3Per(PC),A0
	cmp.l	#$DFF0C0,A1
	beq.b	.SetVoice
	lea	StructAdr+UPS_Voice4Per(PC),A0
.SetVoice
	move.w	D0,(A0)
	move.l	(SP)+,A0
	rts

***************************************************************************
****************************** EP_Voices  *********************************
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
****************************** TFMX ST player *****************************
***************************************************************************

; TFMX-ROUTINE
;versionnum = $0892
;        by
;  Chris Huelsbeck
; last 18.9.92 time 1:25
;		opt	p+
;		opt 	o+,ow-
;		opt	d+ 		;--->for debugging
;
;	TFMX-OPTIONS (0=off,1=on)
;
;stassembly	= 1			;1=Atari ST assemblierung
;stsamples	= 1

;datafields	= 1
;infos		= 1
;
;trackq		= 8			;quantity of tracks (1-8)
;onmutes	= 1			;sequencer mute	0=off
;onpcont	= 1			;patterncont	0=off
;onpgoto	= 1			;pgosub/return	0=off
;onpfade	= 1			;pfade		0=off
;onpplay	= 1			;playsequence	0=off
;onpsend	= 1			;send flags	0=off
;onvibra	= 1			;vibrato	0=off
;onporta	= 1			;portamento	0=off
;onenvel	= 1			;envelope	0=off
;onsplit	= 1			;splitkey	0=off
;onriffs	= 1			;riffplaying	0=off
;onpsg		= 1			;ST Soundchip	1 !
;onmloop	= 1			;macroloops	0=off
;onlastn	= 1			;lastnotes	0=off
;onmgoto	= 1			;mgosub/return	0=off
;onmsetp	= 1			;set period	0=off
;onmsend	= 1			;send flags	0=off
;note_vol	= 1			;1=set addvolume+note
;
;randoms	= onriffs

;GISELECT	= $ff8800
;GIWRITE	= $ff8802

;
;
;tfmx
;		bra	alloff
;		bra.w	irqin		;+36 JSR from your irq
;		bra	alloff		;+40 clear all channels
;		bra	songplay	;+44 d0 = songnr.
;		bra	noteport	;+48 longword in d0
				;00000000
				;xx	 = note    00-3f
				;  xx	 = macro   00-7f
				;    x   = volume   0- f
				;     x  = channel  0- 3
				;      xx= detune  00-7f=pos / ff-80=neg
;		bra	initdata	;+52 mdatbase	in d0.l
					;    smplbase	in d1.l
					;    7voicebase in d2.l (1140 bytes)
					;    7voicerate in d3.w (0-22 KHz)
;		bra	alloff
;		bra	alloff
;		bra	channeloff	;+64 channelno. in d0
;		bra	songplay	;+68 (Editor)
;		bra	fade		;+72 longword in d0
				;00000000
				;xx	 = unused
				;  xx	 = counter
				;    xx  = unused
				;      xx= endvolume
;		bra	info		;+76
				;a0	   = pointer to data
				;data+0.w  = fade end
				;data+2.w  = errorflag 0=ok,1=loop,2=songend
				;data+16.l = uservbi vector (+2)
				;data+30.w = 4 words programmer flags
;		bra	alloff
;		bra	alloff
;		bra	alloff
;		bra	alloff
;		bra	playcont	;+96 d0.w = songnr.
;		bra	alloff
;		bra	alloff
;		bra	alloff
;		bra	alloff		;+112
;		bra	alloff
;		bra	alloff
;		bra	alloff
;		bra	alloff
irqin
;		movem.l	d0-d7/a0-a6,-(sp)
		lea	CHfield0(pc),a6
		move.l	help1(a6),-(sp)
		tst.b	allon(a6)
		bne.s	.cont
		bra	allout
.cont
		bsr	synthesizer

		tst.b	song(a6)
		bmi.s	.onlysynth
		bsr	sequencer
.onlysynth

allout
		move.l	(sp)+,help1(a6)
allout2
;		movem.l	(sp)+,d0-d7/a0-a6
;	move.w	#$777,COLOR00
;	move.w	#$40,$dff0d8
out5		rts
;
;
;
sequencer
		lea	CHfield2(pc),a5
		move.l	database(a6),a4
.count
		subq.w	#1,scount(a6)
		bpl	out5
		move.w	speed(a5),scount(a6)
		move.w	mutes(a4),muteflags(a5)
		move.w	mutes+2(a4),muteflags+4(a5)
		move.w	mutes+4(a4),muteflags+8(a5)
		move.w	mutes+6(a4),muteflags+12(a5)
		move.w	mutes+8(a4),muteflags+16(a5)
		move.w	mutes+10(a4),muteflags+20(a5)
		move.w	mutes+12(a4),muteflags+24(a5)
		move.w	mutes+14(a4),muteflags+28(a5)

patternplay
		move.l	a5,a0
		clr.b	newstep(a6)
		bsr.s	play1x
		tst.b	newstep(a6)
		bne.s	patternplay
		bsr.s	play1
		tst.b	newstep(a6)
		bne.s	patternplay
		bsr.s	play1
		tst.b	newstep(a6)
		bne.s	patternplay
		bsr.s	play1
		tst.b	newstep(a6)
		bne.s	patternplay
		bsr.s	play1
		tst.b	newstep(a6)
		bne.s	patternplay
		bsr.s	play1
		tst.b	newstep(a6)
		bne.s	patternplay
		bsr.s	play1
		tst.b	newstep(a6)
		bne.s	patternplay
		bsr.s	play1
		tst.b	newstep(a6)
		bne	patternplay
pplayout
		rts
;
play1
		addq.l	#4,a0
play1x
		cmp.b	#$90,patterns(a0)	;pattern-number
		bcs.s	.play			;<$90 then play it
		cmp.b	#$fe,patterns(a0)	;is it $fe
		bne.s	out6			;no then out
		st.b	patterns(a0)		;set flag (done it)
		move.b	patterns+1(a0),d0	;channel-number in d0
		tst.w	muteflags(a0)		;track mutet ?
		beq	channeloff		;yes then clear channel
		rts				;no - out
.play
		lea	infodat(pc),a1
		st.b	info_seqrun(a1)
		tst.b	pawait(a0)		;waitmode on ?
		beq.s	play2			;no then next note/states
		subq.b	#1,pawait(a0)		;wait-1 and out
out6		rts
play2
		move.w	pstep(a0),d0		;actual pattern-step
		add.w	d0,d0			;*2 (word)
		add.w	d0,d0			;*2 (longword)
		move.l	padress(a0),a1		;a1=patternadress

		move.l	(a1,d0.w),help1(a6)	;get note/statment
		move.b	help1(a6),d0
		cmp.b	#$f0,d0			;if first byte > $ef
		bcc.s	play3			;then it's a statement
		move.b	d0,d7
		cmp.b	#$c0,d0			;>$bf
		bcc.s	.nonotewait
		cmp.b	#$7f,d0			;>$7f
		bcs.s	.nonotewait
		move.b	help1+3(a6),pawait(a0)	;set wait len
		clr.b	help1+3(a6)
.nonotewait
		move.b	patterns+1(a0),d1	;it's a note
		add.b	d1,d0			;add transpose to note
		cmp.b	#$c0,d7			;>$c0
		bcc.s	.porta
		and.b	#$3f,d0
.porta
		move.b	d0,help1(a6)
		move.l	help1(a6),d0		;d0=note/macro/vol/chan/detune
		tst.w	muteflags(a0)		;track mutet ?
		bne.s	.noplay			;yes then play not
		bsr	noteport		;note to synthesizer
.noplay
		cmp.b	#$c0,d7			;$c0<=d7
		bcc.s	play4
		cmp.b	#$7f,d7			;$7f>d7
		bcs.s	play4
		bra	play5
play3
		and.w	#$f,d0			;statement number
		add.w	d0,d0			;extend to word pointer
		add.w	d0,d0			;extend to longword pointer
		jmp	.jumptable2(pc,d0.w)
.jumptable2
		bra.w	pend		;$f0
		bra.w	ploop		;$f1	
		bra.w	pcont		;$f2
		bra.w	pwait		;$f3
		bra.w	pstop		;$f4
		bra.w	pkeyup		;$f5
		bra.w	pportsp		;$f6
		bra.w	pportsp		;$f7
		bra.w	pgosub		;$f8
		bra.w	preturn		;$f9
		bra.w	pfade		;$fa
		bra.w	ppseq		;$fb
		bra.w	pportsp		;$fc
		bra.w	psendflag	;$fd
		bra.w	pstopcus	;$fe
;		bra.w	play4		;$ff
play4
		addq.w	#1,pstep(a0)		;pattern-step +1
		bra	play2			;next note/statment
;
pend						;stament $f0 (end)
		st.b	patterns(a0)		;stop playing pattern
.norm
		move.w	cstep(a5),d0		;current track-step
		cmp.w	lstep(a5),d0		;= last step
		bne.s	seq1			;no then next step
		move.w	fstep(a5),cstep(a5)	;set first step

	bsr.w	SongEnd

		bra.s	seq2			;continue playing
seq1
		addq.w	#1,cstep(a5)		;current step +1
seq2
		bsr	newtrack		;set new tracks
		st.b	newstep(a6)		;set return flag and out
		rts
ploop						;statment $f1 (loop)
		tst.b	ploopcount(a0)		;loopcounter and flag
		beq.s	.set			;=0   then set new loop
		subq.b	#1,ploopcount(a0)	;loopcounter -1
		beq	play4			;next patternstep
		move.w	help1+2(a6),pstep(a0)	;set step
		bra	play2			;continue playing
.set
		move.b	help1+1(a6),ploopcount(a0)
		move.w	help1+2(a6),pstep(a0)	;set step
		bra	play2			;continue playing
pcont						;statment $f2 (cont)
		move.b	help1+1(a6),d0		;get patternnumber
		move.b	d0,patterns(a0)		;store pattern
		add.w	d0,d0
		add.w	d0,d0			;extend to longword pointer
		move.l	pattnbase(a6),a1	;a1=patternbase
		move.l	(a1,d0.w),d0		;get patternadress
		add.l	a4,d0			;add database
		move.l	d0,padress(a0)		;store patternadress
		move.w	help1+2(a6),pstep(a0)	;and pattern-step
		bra	play2			;and play it
pwait						;statment $f3 (wait)
		move.b	help1+1(a6),pawait(a0);set wait len
play5
		addq.w	#1,pstep(a0)		;pattern-step +1
		rts				;out - next track
pstopcus
pstop						;statment $f4 (stop)
		st.b	patterns(a0)		;stop playing pattern
		rts				;on this track - out
pkeyup		;statment $f5 keyoff
		move.b	patterns+1(a0),d1	;it's a note
		add.b	d1,help1+1(a6)		;add transpose to note
pportsp		;statment $f5 keyoff/$f6 vibrato/$f7 envelope/$fc fxprio
		move.l	help1(a6),d0		;d0=$f5xxx/channel/xx
		tst.w	muteflags(a0)		;track mutet ?
		bne.s	.noplay			;yes, then no keyoff
		bsr	noteport		;to synthesizer
.noplay
		bra	play4			;continue playing
pgosub
		move.l	padress(a0),psubadr(a0)
		move.w	pstep(a0),psubstep(a0)

		move.b	help1+1(a6),d0		;get patternnumber
		move.b	d0,patterns(a0)		;store pattern
		add.w	d0,d0
		add.w	d0,d0			;extend to longword pointer
		move.l	pattnbase(a6),a1	;a1=patternbase
		move.l	(a1,d0.w),d0		;get patternadress
		add.l	a4,d0			;add database
		move.l	d0,padress(a0)		;store patternadress
		move.w	help1+2(a6),pstep(a0)	;and pattern-step
		bra	play2			;and play it
preturn
		move.l	psubadr(a5),padress(a5)
		move.w	psubstep(a5),pstep(a5)
		bra	play4
pfade
		lea	infodat(pc),a1
		tst.w	info_fade(a1)
		bne	play4
		move.w	#1,info_fade(a1)
		move.b	help1+3(a6),fadeend(a6)
		move.b	help1+1(a6),fadecount1(a6)
		move.b	help1+1(a6),fadecount2(a6)
		beq.s	.norm
		move.b	#1,fadeadd(a6)
		move.b	fadevol(a6),d0
		cmp.b	fadeend(a6),d0
		beq.s	.nofad
		bcs	play4
		neg.b	fadeadd(a6)
		bra	play4
.norm
		move.b	fadeend(a6),fadevol(a6)
.nofad
		clr.b	fadeadd(a6)
		clr.w	info_fade(a1)
		bra	play4
psendflag
		lea	infodat(pc),a1
		move.b	help1+1(a6),d0
		and.w	#$03,d0
		add.w	d0,d0
		move.w	help1+2(a6),info_flags(a1,d0.w)
		bra	play4
ppseq
		move.b	help1+2(a6),d1
		and.w	#$7,d1
		add.w	d1,d1
		add.w	d1,d1
		move.b	help1+1(a6),d0
		move.b	d0,patterns(a5,d1.w)
		move.b	help1+3(a6),patterns+1(a5,d1.w)
		and.w	#$7f,d0
		add.w	d0,d0		;*2
		add.w	d0,d0		;*2
		move.l	pattnbase(a6),a1	;a1=patternbase
		move.l	(a1,d0.w),d0	;get 1st patternadress
		add.l	a4,d0		;add database
		move.l	d0,padress(a5,d1.w)	;store pattern-adress
		clr.l	pstep(a5,d1.w)		;clear pattern-step
		sf.b	ploopcount(a5,d1.w)	;reset loops
		bra	play4
;
newtrack
	movem.l	a0-a1,-(sp)
back
		move.w	cstep(a5),d0		;current step
		lsl.w	#4,d0			;*16
		move.l	trackbase(a6),a0	;track-step-table
		add.w	d0,a0			;+step
		move.l	pattnbase(a6),a1	;pattern-adress-table

		move.w	(a0)+,d0	;get statment (? special)
		cmp.w	#$effe,d0	;if not equal $effe
		bne.s	cont		;to continue (normal step)
		move.w	(a0)+,d0	;get special-statment
		add.w	d0,d0
		add.w	d0,d0		;d0*4=pointer to adress of routine
		cmp.w	#efxx2,d0
		bcs.s	.ok
		moveq.l	#0,d0
.ok
		jmp	jumptable3(pc,d0.w)
jumptable3
		bra.w	stopsong	;$0000
		bra.w	loopsong	;$0001
		bra.w	speedsong	;$0002
		bra.w	set7freq	;$0003
		bra.w	fadesong	;$0004
efxx1
efxx2		= efxx1-jumptable3
cont
					;track 1
		move.w	d0,patterns(a5)	;store patternnumber/transpose
		bmi.s	.pp1		;play pattern ?
		clr.b	d0		;yes
		lsr.w	#6,d0		;*64
		move.l	(a1,d0.w),d0	;get 1st patternadress
		add.l	a4,d0		;add database
		move.l	d0,padress(a5)	;store pattern-adress
		clr.l	pstep(a5)	;clear pattern-step
		sf.b	ploopcount(a5)	;reset loops
.pp1
		movem.w	(a0)+,d0-d6
		move.w	d0,patterns+4(a5)
		bmi.s	.pp2
		clr.b	d0
		lsr.w	#6,d0
		move.l	(a1,d0.w),d0
		add.l	a4,d0
		move.l	d0,padress+4(a5)
		clr.l	pstep+4(a5)
		sf.b	ploopcount+4(a5)
.pp2
		move.w	d1,patterns+8(a5)
		bmi.s	.pp3
		clr.b	d1
		lsr.w	#6,d1
		move.l	(a1,d1.w),d0
		add.l	a4,d0
		move.l	d0,padress+8(a5)
		clr.l	pstep+8(a5)
		sf.b	ploopcount+8(a5)
.pp3
		move.w	d2,patterns+12(a5)
		bmi.s	.pp4
		clr.b	d2
		lsr.w	#6,d2
		move.l	(a1,d2.w),d0
		add.l	a4,d0
		move.l	d0,padress+12(a5)
		clr.l	pstep+12(a5)
		sf.b	ploopcount+12(a5)
.pp4
		move.w	d3,patterns+16(a5)
		bmi.s	.pp5
		clr.b	d3
		lsr.w	#6,d3
		move.l	(a1,d3.w),d0
		add.l	a4,d0
		move.l	d0,padress+16(a5)
		clr.l	pstep+16(a5)
		sf.b	ploopcount+16(a5)
.pp5
		move.w	d4,patterns+20(a5)
		bmi.s	.pp6
		clr.b	d4
		lsr.w	#6,d4
		move.l	(a1,d4.w),d0
		add.l	a4,d0
		move.l	d0,padress+20(a5)
		clr.l	pstep+20(a5)
		sf.b	ploopcount+20(a5)
.pp6
		move.w	d5,patterns+24(a5)
		bmi.s	.pp7
		clr.b	d5
		lsr.w	#6,d5
		move.l	(a1,d5.w),d0
		add.l	a4,d0
		move.l	d0,padress+24(a5)
		clr.l	pstep+24(a5)
		sf.b	ploopcount+24(a5)
.pp7
		move.w	d6,patterns+28(a5)
		bmi.s	.pp8
		clr.b	d6
		lsr.w	#6,d6
		move.l	(a1,d6.w),d0
		add.l	a4,d0
		move.l	d0,padress+28(a5)
		clr.l	pstep+28(a5)
		sf.b	ploopcount+28(a5)
.pp8
		movem.l	(sp)+,a0-a1
		rts
;
stopsong				;stat $effe 0000
		clr.b	allon(a6)
		movem.l	(sp)+,a0-a1	;jump out

	bsr.w	SongEnd

		rts
loopsong				;stat $effe 0001 xxxx (yyyy)
					;x=trackstep y=len (1-$7fff)
		tst.w	tloopcount(a6)
		beq.s	.pl1
		bmi.s	.pl2
		subq.w	#1,tloopcount(a6)
		bra.s	.pl3
.pl1
		move.w	#-1,tloopcount(a6)
		addq.w	#1,cstep(a5)	;current step +1
		bra	back		;continue playing
.pl2
		move.w	2(a0),d0

	bgt.s	.skip
	bsr.w	SongEnd
.skip

		subq.w	#1,d0
		move.w	d0,tloopcount(a6)
.pl3
		move.w	(a0),cstep(a5)	;set current step
		bra	back		;continue playing
speedsong				;stat $effe 0002 xxxx (yyyy zzzz)
					;x=speed/clicks y=BPM z=delay
		move.w	(a0),speed(a5)	;set new speed
		move.w	(a0),scount(a6)
.notim
		addq.w	#1,cstep(a5)	;current step +1
		bra	back		;continue playing
set7freq				;stat $effe 0003 xxxx yyyy
fadesong				;stat $effe 0004 xxxx xxxx
		addq.w	#1,cstep(a5)	;current step +1
		lea	infodat(pc),a1
		tst.w	info_fade(a1)
		bne	back
		move.w	#1,info_fade(a1)
		move.b	3(a0),fadeend(a6)
		move.b	1(a0),fadecount1(a6)
		move.b	1(a0),fadecount2(a6)
		beq.s	.norm

		move.b	#1,fadeadd(a6)
		move.b	fadevol(a6),d0
		cmp.b	fadeend(a6),d0
		beq.s	.nofad
		bcs	back
		neg.b	fadeadd(a6)
		bra	back
.norm
		move.b	fadeend(a6),fadevol(a6)
.nofad
		move.b	#0,fadeadd(a6)
		clr.w	info_fade(a1)
		bra	back
;
;
;
synthesizer
.psg
		lea	psgfield0(pc),a5
		bsr.s	specials
		lea	psgfield1(pc),a5
		bsr.s	specials
		lea	psgfield2(pc),a5
		bsr.s	specials
		lea	psgfield3(pc),a5
;		bsr.s	specials
;		rts

specials
		tst.b	mstatus(a5)
		beq	modulations
mac1
		tst.w	mawait(a5)
		beq.s	mac2
		subq.w	#1,mawait(a5)
out1
		bra	modulations
mac2
		move.l	madress(a5),a0
		move.w	mstep(a5),d0
		add.w	d0,d0		;*2
		add.w	d0,d0		;*2

		lea	(a0,d0.w),a0
		move.l	(a0),help1(a6)		;store complete statment
		moveq.l	#0,d0
		move.b	help1(a6),d0		;macro-statment
		clr.b	help1(a6)
		add.w	d0,d0			;*2
		add.w	d0,d0			;*2 Extent to lw-pointer
		cmp.w	#mxx2,d0		;<-- num of statments *****
		bcc	macadd
		jmp	jumptable1(pc,d0.w)
jumptable1
		bra.w	mac3		;$00
		bra.w	mac3		;$01
		bra.w	mac3		;$02
		bra.w	mac3		;$03
		bra.w	mwait		;$04
		bra.w	mloop		;$05 *onmloop
		bra.w	mcont		;$06 *onmgoto
		bra.w	mstop		;$07
		bra.w	maddnote	;$08
		bra.w	msetnote	;$09
		bra.w	mclear		;$0a *onmclrs
		bra.w	mporta		;$0b *onporta
		bra.w	mvibrato	;$0c *onvibra
		bra.w	maddvolume	;$0d
		bra.w	msetvolume	;$0e
		bra.w	menvelope	;$0f
		bra.w	mloopkey	;$10 *onmloop
		bra.w	mac3		;$11
		bra.w	mac3		;$12
		bra.w	mac3		;$13
		bra.w	mwaitkeyo	;$14
		bra.w	mgosub		;$15 *onmgoto
		bra.w	mreturn		;$16 *onmgoto
;		bra.w	mac3		;$17 *onmsetp

	bra.w	msetperiod

		bra.w	mac3		;$18
		bra.w	mac3		;$19
		bra.w	mac3		;$1a *onwwait
		bra.w	mriff		;$1b *onriffs
		bra.w	msplitk		;$1c *onsplit
		bra.w	msplitv		;$1d *onsplit
		bra.w	mriff2		;$1e
		bra.w	mlastnote	;$1f *onlastn
		bra.w	msendflag	;$20
		bra.w	mplaynote	;$21
		bra.w	mac3		;$22
		bra.w	mac3		;$23
		bra.w	mac3		;$24
		bra.w	mac3		;$25
		bra.w	mac3		;$26
		bra.w	mac3		;$27
		bra.w	mac3		;$28
		bra.w	mac3		;$29
		bra.w	mac3		;$2a
		bra.w	mac3		;$2b
		bra.w	mac3		;$2c
		bra.w	mac3		;$2d
		bra.w	mac3		;$2e
		bra.w	mac3		;$2f
		bra.w	mskip		;$30
		bra.w	mskeyup		;$31
		bra.w	maddword	;$32
		bra.w	mandword	;$33
		bra.w	mac3		;$34
		bra.w	mac3		;$35
		bra.w	mac3		;$36
		bra.w	mac3		;$37
		bra.w	mac3		;$38
		bra.w	mac3		;$39
		bra.w	mac3		;$3a
		bra.w	mac3		;$3b
		bra.w	mac3		;$3c
		bra.w	mac3		;$3d
		bra.w	mac3		;$3e
		bra.w	mac3		;$3f
;PSG
		bra.w	mpsgreset	;$40
		bra.w	mpsgwave	;$41
		bra.w	mpsgcenv	;$42
		bra.w	mpsgcean	;$43
		bra.w	mpsgnper	;$44
		bra.w	mpsgsetp	;$45
		bra.w	mac3		;$46
		bra.w	mpsgmixa	;$47
		bra.w	mpsgsample	;$48
		bra.w	mpsgsrate	;$49
		bra.w	mpsgsstop	;$4a
		bra.w	mac3		;$4b
		bra.w	mac3		;$4c
		bra.w	mac3		;$4d
		bra.w	mac3		;$4e
		bra.w	mac3		;$4f

mxx1
mxx2	= mxx1-jumptable1
macadd
		addq.w	#1,mstep(a5)
		bra	modulations
mac3
		addq.w	#1,mstep(a5)
		bra	mac2
;
mwait
		btst.b	#0,help1+1(a6)
		beq.s	.noriff
		tst.b	rifftrigg(a5)
		bne	out1
		move.b	#1,rifftrigg(a5)
		bra	mac3
.noriff
		move.w	help1+2(a6),mawait(a5)	;set wait
		bra	macadd
;
;
;
msplitk
		move.b	help1+1(a6),d0
		cmp.b	basenote+1(a5),d0		;note
		bhs	mac3
		move.w	help1+2(a6),mstep(a5)	;set jump step
		bra	mac2		
msplitv
		move.b	help1+1(a6),d0
		cmp.b	volume(a5),d0		;volume
		bhs	mac3
		move.w	help1+2(a6),mstep(a5)	;set jump step
		bra	mac2		
maddword
		move.w	help1(a6),d1
		add.w	d1,d1
		move.w	help1+2(a6),d0
		add.w	d0,(a0,d1.w)
		bra	mac3
mandword
		move.w	help1(a6),d1
		add.w	d1,d1
		move.w	help1+2(a6),d0
		and.w	d0,(a0,d1.w)
		bra	mac3
mriff
		move.b	help1+1(a6),riffmacro(a5)
		move.w	help1+2(a6),riffspeed(a5)
		move.w	#$0101,riffcount(a5)
		bsr	riffplay
		move.b	#1,rifftrigg(a5)
		bra	mac3
mriff2
		move.b	help1+1(a6),riffAND(a5)
		bra	mac3
;
mloopkey
		tst.b	keyflag(a5)		;keyflag=0 ?
		beq	mac3			;yes, then next macrostep
mloop
		tst.b	mloopcount(a5)
		beq.s	.set
		subq.b	#1,mloopcount(a5)
		beq	mac3
		move.w	help1+2(a6),mstep(a5)	;set loop step
		bra	mac2
.set
		move.b	help1+1(a6),mloopcount(a5)
		move.w	help1+2(a6),mstep(a5)	;set loop step
		bra	mac2
mstop
		clr.b	mstatus(a5)
		bra	modulations
maddvolume
		cmp.b	#$fe,help1+2(a6)
		bne.s	.no
		move.b	basenote+1(a5),d2	;note
		move.b	help1+3(a6),d3
		clr.w	help1+2(a6)
		lea	.back(pc),a1
		bra	mputnote
.back
		move.b	d3,help1+3(a6)
.no
		move.w	basevol(a5),d0
		add.w	d0,d0
		add.w	basevol(a5),d0
		add.w	help1+2(a6),d0
		move.b	d0,volume(a5)
		addq.w	#1,mstep(a5)
		bra	mac2
msetvolume
		cmp.b	#$fe,help1+2(a6)
		bne.s	.no
		move.b	basenote+1(a5),d2	;note
		move.b	help1+3(a6),d3
		clr.w	help1+2(a6)
		lea	.back(pc),a1
		bra.s	mputnote
.back
		move.b	d3,help1+3(a6)
.no
		move.b	help1+3(a6),volume(a5)
		addq.w	#1,mstep(a5)
		bra	mac2
mplaynote
		move.b	basenote+1(a5),help1(a6)
		move.b	basevol+1(a5),d0
		lsl.b	#4,d0
		or.b	d0,help1+2(a6)
		move.l	help1(a6),d0
		bsr	noteport
		bra	mac3
mskeyup
		move.b	#$f5,help1(a6)
		move.l	help1(a6),d0
		bsr	noteport
		bra	mac3
mlastnote
		move.b	basenote(a5),d2
		lea	macadd(pc),a1
		bra.s	mputnote
msetnote
		moveq.l	#0,d2
		lea	macadd(pc),a1
		bra.s	mputnote
maddnote
		move.b	basenote+1(a5),d2	;note
		lea	macadd(pc),a1
mputnote
		move.b	help1+1(a6),d0
		add.b	d2,d0
		and.b	#$3f,d0
		ext.w	d0
		add.w	d0,d0
		lea	PSG_nottab(pc),a0
		tst.b	psg_peroffs(a5)
		bpl	.psg
		lea	nottab(pc),a0		;note-periods		
.psg
		move.w	(a0,d0.w),d0
		move.w	detunes(a5),d1
		add.w	help1+2(a6),d1
		beq.s	.zero
		add.w	#256,d1
		mulu.w	d1,d0
		lsr.l	#8,d0
.zero
		move.w	d0,baseperiod(a5)
		tst.w	potime(a5)
		bne.s	.no
		move.b	psg_peroffs(a5),d2
		bmi.s	.nopsg

;		move.b	d2,GISELECT
;		move.b	d0,GIWRITE

	and.w	#15,D2
	add.w	D2,D2
	add.w	D2,D2
	move.b	D0,2(A3,D2.W)

		lsr.w	#8,d0
;		addq.b	#1,d2
;		move.b	d2,GISELECT
;		move.b	d0,GIWRITE

	move.b	D0,6(A3,D2.W)

;		jmp	(a1)
.nopsg
.no
		jmp	(a1)
msetperiod
		move.w	help1+2(a6),baseperiod(a5)
;		tst.w	potime(a5)
;		bne	mac3
		bra	mac3
mporta
		move.b	help1+1(a6),pospeed(a5)
		move.b	#1,pocount(a5)
		tst.w	potime(a5)
		bne.s	.noperiod
		move.w	baseperiod(a5),poperiod(a5)
.noperiod
		move.w	help1+2(a6),potime(a5)
		bra	mac3
mvibrato	
		move.b	help1+1(a6),d0
		move.b	d0,vibsize1(a5)
		lsr.b	#1,d0
		move.b	d0,vibsize2(a5)
		move.b	help1+3(a6),vibrate(a5)
		move.b	#1,vibcount(a5)

		tst.w	potime(a5)
		bne	mac3

		clr.w	vibperiod(a5)
		addq.w	#1,mstep(a5)
		bra	mac2
menvelope
		move.b	help1+2(a6),envelope(a5)
		move.b	help1+1(a6),envspeed(a5)
		move.b	help1+2(a6),envcount(a5)
		move.b	help1+3(a6),envolume(a5)
		addq.w	#1,mstep(a5)
		bra	mac2
mclear
		clr.b	riffstats(a5)

mpsgreset
		clr.b	envelope(a5)
		clr.b	vibsize1(a5)
		clr.w	potime(a5)
		clr.b	psg_ebit(a5)
		bra	mac3
mwaitkeyo
		tst.b	keyflag(a5)		;keyflag=0 ?
		beq	mac3			;yes, then next macrostep
		tst.b	mloopcount(a5)		;loopcount=0
		beq.s	.set			;yes, then set new counter
		subq.b	#1,mloopcount(a5)	;mloopcount-1
		beq	mac3			;now zero then next step
		bra	modulations		;go on
.set
		move.b	help1+3(a6),mloopcount(a5)	;wait to loopcount
		bra	modulations		;go on
mgosub
		move.l	madress(a5),msubadr(a5)
		move.w	mstep(a5),msubstep(a5)
mcont
		move.b	help1+1(a6),d0
		and.l	#$7f,d0
		move.l	macrobase(a6),a0
		add.w	d0,d0
		add.w	d0,d0
		adda.w	d0,a0
		move.l	(a0),d0			;get relative adress
		add.l	database(a6),d0		;+base
		move.l	d0,madress(a5)		;=macroadress
		move.w	help1+2(a6),mstep(a5)
		sf.b	mloopcount(a5)
		sf.b	mskipflag(a5)
		bra	mac2
mskip
		tst.b	mskipflag(a5)
		bne.s	.skip
;	move.w	#$fff,$dff180
		st.b	mskipflag(a5)
		bra	mac3
.skip
		move.w	help1+2(a6),mstep(a5)
		bra	mac2
mreturn
		move.l	msubadr(a5),madress(a5)
		move.w	msubstep(a5),mstep(a5)
		bra	mac3
msendflag
		move.b	help1+1(a6),d0
		and.w	#3,d0
		add.w	d0,d0
		lea	infodat(pc),a0
		move.w	help1+2(a6),info_flags(a0,d0.w)
		bra	mac3
mpsgwave
;		move.b	#7,GISELECT
		move.b	help1+1(a6),d0	;Pulse 0/1
		beq.s	.poff
		move.b	psg_pulseon(a5),d0
		and.b	d0,psgmix(a6)
;		move.b	psgmix(a6),GIWRITE

	move.b	psgmix(A6),7*4+2(A3)

		bra.s	.nois
.poff
		move.b	psg_pulsoff(a5),d0
		or.b	d0,psgmix(a6)
;		move.b	psgmix(a6),GIWRITE

	move.b	psgmix(A6),7*4+2(A3)

.nois
		move.b	help1+3(a6),d0	;Noise 0/1
		beq.s	.noff
		move.b	psg_noiseon(a5),d0
		and.b	d0,psgmix(a6)
;		move.b	psgmix(a6),GIWRITE

	move.b	psgmix(A6),7*4+2(A3)

		bra	mac3
.noff
		move.b	psg_noisoff(a5),d0
		or.b	d0,psgmix(a6)
;		move.b	psgmix(a6),GIWRITE

	move.b	psgmix(A6),7*4+2(A3)

		bra	mac3
mpsgcenv
;		move.b	#11,GISELECT
;		move.b	help1+3(a6),GIWRITE
;		move.b	#12,GISELECT
;		move.b	help1+2(a6),GIWRITE
;		move.b	#13,GISELECT
;		move.b	help1+1(a6),GIWRITE

	move.b	help1+3(A6),11*4+2(A3)
	move.b	help1+2(A6),12*4+2(A3)
	move.b	help1+1(A6),13*4+2(A3)

		move.b	#$10,psg_ebit(a5)
		bra	mac3
mpsgcean
		move.b	basenote+1(a5),d2	;note
		lea	mac3(pc),a1
mpsgcepn
		move.b	help1+1(a6),d0
		add.b	d2,d0
		and.b	#$3f,d0
		ext.w	d0
		add.w	d0,d0

		lea	PSG_nottab(pc),a0		;note-periods		
		move.w	(a0,d0.w),d0
		move.w	detunes(a5),d1
		add.w	help1+2(a6),d1
		beq.s	.zero
		add.w	#256,d1
		mulu.w	d1,d0
		lsr.l	#8,d0
.zero
		move.w	d0,baseperiod(a5)
		tst.w	potime(a5)
		bne.s	.no
;		move.b	#11,GISELECT
;		move.b	d0,GIWRITE

	move.b	D0,11*4+2(A3)

		lsr.w	#8,d0
;		move.b	#12,GISELECT
;		move.b	d0,GIWRITE
;		jmp	(a1)

	move.b	D0,12*4+2(A3)

.no
		jmp	(a1)
mpsgnper
		lea	psgfield3(pc),a0
		move.b	help1+1(a6),volume(a0)
		bra	mac3
mpsgmixa
;		move.b	#7,GISELECT
		move.b	psgmix(a6),d0
		and.b	help1+1(a6),d0
		or.b	help1+3(a6),d0
		move.b	d0,psgmix(a6)
;		move.b	d0,GIWRITE

	move.b	D0,7*4+2(A3)

		bra	mac3
mpsgsetp
		move.b	psg_peroffs(a5),d0
;		move.b	d0,GISELECT
;		move.b	help1+3(a6),GIWRITE
;		addq.b	#1,d0
;		move.b	d0,GISELECT
;		move.b	help1+2(a6),GIWRITE

	and.w	#15,D0
	add.w	D0,D0
	add.w	D0,D0
	move.b	help1+3(A6),2(A3,D0.W)
	move.b	help1+2(A6),6(A3,D0.W)

		move.w	help1+2(a6),baseperiod(a5)
		bra	mac3
mpsgsample
		move.b	psg_pulseon(a5),d0
		and.b	d0,psgmix(a6)
		move.b	psg_noisoff(a5),d0
		or.b	d0,psgmix(a6)
		move.b	psg_peroffs(a5),d0
;		move.b	d0,GISELECT
;		move.b	#0,GIWRITE
;		addq.b	#1,d0
;		move.b	d0,GISELECT
;		move.b	#0,GIWRITE
;		move.b	#7,GISELECT
;		move.b	psgmix(a6),GIWRITE

	and.w	#15,D0
	add.w	D0,D0
	add.w	D0,D0
	clr.b	2(A3,D0.W)
	clr.b	6(A3,D0.W)
	move.b	psgmix(A6),7*4+2(A3)

		move.w	#0,baseperiod(a5)
;		lea	kanal(pc),a0
;		move.w	#3,(a0)			;set channel
		move.l	help1(a6),d0
		and.l	#$fffff,d0
		add.l	samplebase(a6),d0	;+base
		lea	samadr(pc),a0
		move.l	d0,(a0)			;set adress
		lea	samlen(pc),a0
;		move.l	#10000,(a0)

	clr.w	(A0)				; CHECK length!!!

		st	psg_samflag(a5)
;		bsr	digisound

	move.w	#1,lbW0004C8

		bra	mac3
mpsgsrate

	move.w	help1+2(A6),lbW0004C4

		bra	mac3

mpsgsstop
;		lea	kanal(pc),a0
;		move.w	#3,(a0)			;set channel
;		lea	samlen(pc),a0
;		move.l	#0,(a0)
		sf	psg_samflag(a5)
;		bsr	digisound		;stop sample

	clr.w	lbW0004C8

		bra	mac3
;
modulations
		tst.b	modstatus(a5)
		bmi.s	.ms1			;negative = no mods
		bne.s	.ms2			;positive = do mods
		move.b	#1,modstatus(a5)	;0	  = one vbi wait
.ms1
		bra	fader
.ms2
;
;	Modulation
;
vibratos
		tst.b	vibsize1(a5)
		beq.s	glides

		move.b	vibrate(a5),d0
		ext.w	d0
		add.w	d0,vibperiod(a5)
		move.w	baseperiod(a5),d0
		move.w	vibperiod(a5),d1
		beq.s	.zero
		and.l	#$ffff,d0
		add.w	#2048,d1
		mulu.w	d1,d0
		lsl.l	#5,d0
		swap d0
.zero
		tst.w	potime(a5)
		bne.s	.glide
		move.b	psg_peroffs(a5),d2
		bmi.s	.nopsg
;		move.b	d2,GISELECT
;		move.b	d0,GIWRITE

	and.w	#15,D2
	add.w	D2,D2
	add.w	D2,D2
	move.b	D0,2(A3,D2.W)

		lsr.w	#8,d0
;		addq.b	#1,d2
;		move.b	d2,GISELECT
;		move.b	d0,GIWRITE
;		bra.s	.glide

	move.b	D0,6(A3,D2.W)

.nopsg
.glide
		subq.b	#1,vibsize2(a5)
		bne.s	glides
		move.b	vibsize1(a5),vibsize2(a5)

		eor.b	#$ff,vibrate(a5)
		addq.b	#1,vibrate(a5)
;
glides
		tst.w	potime(a5)
		beq	envelopes

		subq.b	#1,pocount(a5)
		bne.s	envelopes
		move.b	pospeed(a5),pocount(a5)

		move.w	baseperiod(a5),d1
		moveq.l	#0,d0
		move.w	poperiod(a5),d0
		cmp.w	d1,d0
		beq.s	.end
		bcs.s	.add

		move.w	#256,d2
		sub.w	potime(a5),d2
		mulu.w	d2,d0
		lsr.l	#8,d0
		cmp.w	d1,d0
		beq.s	.end
		bcc.s	.set
.end
		clr.w	potime(a5)
		move.w	baseperiod(a5),d0
.set
		and.w	#$07ff,d0
		move.w	d0,poperiod(a5)
		move.b	psg_peroffs(a5),d2
		bmi.s	.nopsg
;		move.b	d2,GISELECT
;		move.b	d0,GIWRITE

	and.w	#15,D2
	add.w	D2,D2
	add.w	D2,D2
	move.b	D0,2(A3,D2.W)

		lsr.w	#8,d0
;		addq.b	#1,d2
;		move.b	d2,GISELECT
;		move.b	d0,GIWRITE
;		bra.s	envelopes

	move.b	D0,6(A3,D2.W)

.nopsg
		bra.s	envelopes
.add
		move.w	potime(a5),d2
		add.w	#256,d2
		mulu.w	d2,d0
		lsr.l	#8,d0
		cmp.w	d1,d0
		beq.s	.end
		bcc.s	.end
		bra.s	.set
;
envelopes
		tst.b	envelope(a5)	;active ?
		beq.s	out4		;no then out
		tst.b	envcount(a5)	;delaycounter=0 ?
		beq.s	env1		;yes then do
		subq.b	#1,envcount(a5)	;delaycounter-1 and out
		bra.s	out4
env1
		move.b	envelope(a5),envcount(a5)	;set new delaycounter
		move.b	envolume(a5),d0	;endvolume of envelope
		cmp.b	volume(a5),d0	;compare with current volume
		bgt.s	.add		;endvolume greater - then add
		move.b	envspeed(a5),d1	;subvalue
		sub.b	d1,volume(a5)	;volume-subvalue
		bmi.s	.clr
		cmp.b	volume(a5),d0	;compare endvol with current volume
		bge.s	.clr		;
		bra.s	out4
.clr
		move.b	envolume(a5),volume(a5)
		clr.b	envelope(a5)
		bra.s	out4
.add
		move.b	envspeed(a5),d1
		add.b	d1,volume(a5)
		cmp.b	volume(a5),d0
		ble.s	.clr		
out4
;	timerfade
;
;	Ballblazer special routine
;
riffplay	
		tst.b	riffstats(a5)
		beq	fader
		bmi.s	.play
		move.b	riffmacro(a5),d0
		and.l	#$7f,d0
		move.l	macrobase(a6),a0
		add.w	d0,d0		;*2
		add.w	d0,d0		;*2
		adda.w	d0,a0
		move.l	(a0),d0			;relative adress
		add.l	database(a6),d0		;+base
		move.l	d0,riffadres(a5)
		clr.w	riffsteps(a5)
		move.b	#-1,riffstats(a5)
		btst.b	#0,riffrandm(a5)
		beq	.play
		bsr	.fchoose
.play
		subq.b	#1,riffcount(a5)
		bne	.askecho
		move.b	riffspeed(a5),riffcount(a5)
		move.l	riffadres(a5),a0
.loop
		move.w	riffsteps(a5),d0
		move.b	(a0,d0.w),d0
		move.b	d0,help1(a6)
		bne.s	.set
		tst.w	riffsteps(a5)
		beq	fader
		clr.w	riffsteps(a5)
		bra.s	.loop
.set
		add.b	basenote+1(a5),d0	;note
		and.w	#$3f,d0
		beq	.fchoose
		add.w	d0,d0

		lea	nottab(pc),a0		;note-periods		
		move.w	(a0,d0.w),d0
		move.w	detunes(a5),d1
		beq.s	.zero
		add.w	#256,d1
		mulu.w	d1,d0
		lsr.l	#8,d0
.zero
		btst.b	#0,riffrandm(a5)
		bne.s	.ballblazer
		move.w	d0,baseperiod(a5)
		tst.w	potime(a5)
		bne	fader
		move.b	psg_peroffs(a5),d2
		bmi.s	.nopsg
;		move.b	d2,GISELECT
;		move.b	d0,GIWRITE

	and.w	#15,D2
	add.w	D2,D2
	add.w	D2,D2
	move.b	D0,2(A3,D2.W)

		lsr.w	#8,d0
;		addq.b	#1,d2
;		move.b	d2,GISELECT
;		move.b	d0,GIWRITE
;		bra.s	.psg1

	move.b	D0,6(A3,D2.W)

.nopsg
.psg1
		btst.b	#7,help1(a6)
		beq.s	.noclw
		clr.b	rifftrigg(a5)
.noclw
		addq.w	#1,riffsteps(a5)
		bra	fader
.ballblazer
		bsr	randomize
		btst.b	#2,riffrandm(a5)
		bne.s	.plnote
		move.w	riffsteps(a5),d1
		and.w	#3,d1
		tst.w	d1
		bne.s	.plnote
		moveq.l	#16,d1
		cmp.b	random+1(a6),d1
		bcc.s	.nonote
.plnote
		btst.b	#7,help1(a6)
		beq.s	.noclw2
		clr.b	rifftrigg(a5)
.noclw2
		move.w	d0,baseperiod(a5)
		tst.w	potime(a5)
		bne	.nonote
		move.b	psg_peroffs(a5),d2
		beq.s	.nops1
;		move.b	d2,GISELECT
;		move.b	d0,GIWRITE

	and.w	#15,D2
	add.w	D2,D2
	add.w	D2,D2
	move.b	D0,2(A3,D2.W)

		lsr.w	#8,d0
;		addq.b	#1,d2
;		move.b	d2,GISELECT
;		move.b	d0,GIWRITE
;		bra.s	.nonote

	move.b	D0,6(A3,D2.W)

.nops1
.nonote
		addq.w	#1,riffsteps(a5)
		btst.b	#6,help1(a6)
		beq	fader
		bsr	randomize
		move.w	#6,d1
		cmp.b	random(a6),d1
		bcc	fader
.fchoose
		bsr	randomize
		moveq.l	#0,d1
		move.b	random+1(a6),d1
		and.b	riffAND(a5),d1
		move.w	d1,riffsteps(a5)
		bra	fader
.askecho
		btst.b	#1,riffrandm(a5)
		beq.s	fader
		moveq.l	#0,d0
		move.b	riffspeed(a5),d0
		mulu	#3,d0
		lsr.w	#3,d0
		cmp.b	riffcount(a5),d0
		bne.s	fader
		move.w	baseperiod(a5),d0
		moveq.l	#0,d1
		move.b	volume(a5),d1
		mulu	#5,d1
		lsr.w	#3,d1
		move.l	a5,-(sp)
		add.l	channadd(a5),a5
		move.l	audioadr(a5),a4
		move.b	d1,volume(a5)
		cmp.w	baseperiod(a5),d0
		beq.s	.nonot
		move.w	d0,baseperiod(a5)
		move.b	psg_peroffs(a5),d2
		beq.s	.nops2
;		move.b	d2,GISELECT
;		move.b	d0,GIWRITE

	and.w	#15,D2
	add.w	D2,D2
	add.w	D2,D2
	move.b	D0,2(A3,D2.W)

		lsr.w	#8,d0
;		addq.b	#1,d2
;		move.b	d2,GISELECT
;		move.b	d0,GIWRITE
;		bra.s	.psg2

	move.b	D0,6(A3,D2.W)

.nops2
.psg2
		btst.b	#7,help1(a6)
		beq.s	.nonot
		clr.b	rifftrigg(a5)
.nonot
		move.l	(sp)+,a5
		move.l	audioadr(a5),a4
;
;	fade in/out	! Must be the last routine of modulations !!
;
fader
		tst.b	fadeadd(a6)
		beq.s	.fade
		subq.b	#1,fadecount1(a6)
		bne.s	.fade
		move.b	fadecount2(a6),fadecount1(a6)
		move.b	fadeadd(a6),d0
		add.b	d0,fadevol(a6)
		move.b	fadeend(a6),d0
		cmp.b	fadevol(a6),d0
		bne.s	.fade
		clr.b	fadeadd(a6)
		lea	infodat(pc),a0
		clr.w	info_fade(a0)
.fade
		moveq.l	#0,d1
		move.b	fadevol(a6),d1
		moveq.l	#0,d0
		move.b	volume(a5),d0
		btst.l	#6,d1
		bne.s	.nofad
		add.w	d0,d0
		add.w	d0,d0
		mulu.w	d1,d0
		lsr.w	#8,d0
		tst.b	psg_voloffs(a5)
		bmi.s	.nofad
		clr.b	psg_ebit(a5)
.nofad
		move.b	psg_voloffs(a5),d2
		bmi.s	.nopsg
		tst.b	psg_samflag(a5)
		bne.s	.noset
;		move.b	d2,GISELECT
		lsr	#2,d0
		btst.l	#4,d0
		beq.s	.ok
		move.b	#$0f,d0
.ok
		or.b	psg_ebit(a5),d0
;		move.b	d0,GIWRITE
;		bra.s	.noset

	and.w	#15,D2
	add.w	D2,D2
	add.w	D2,D2
	move.b	D0,2(A3,D2.W)

.nopsg
.noset
		rts
randomize
		move.w	$dff006,d7
		eor.w	d7,random(a6)
		move.w	random(a6),d7
		add.l	#$57294335,d7
		move.w	d7,random(a6)
		rts
;
;
;
noteport
		movem.l	d0/a4-a6,-(sp)
		lea	CHfield0(pc),a6
		move.l	help1(a6),-(sp)
		lea	Synoffsets(pc),a5

		move.l	d0,help1(a6)
		move.b	help1+2(a6),d0
		and.w	#$f,d0
		add.w	d0,d0		;Extent to word pointer
		add.w	d0,d0		;Extent to longword pointer
		move.l	(a5,d0.w),a5

		move.b	help1(a6),d0
		tst.b	d0
		bpl	.noteonly
		cmp.b	#$f7,d0
		bne.s	.noenv
		move.b	help1+1(a6),envspeed(a5)
		move.b	help1+2(a6),d0
		lsr.b	#4,d0
		addq.b	#1,d0
		move.b	d0,envcount(a5)
		move.b	d0,envelope(a5)
		move.b	help1+3(a6),envolume(a5)
		bra	npout
.noenv
		cmp.b	#$f6,d0
		bne.s	.novib
		move.b	help1+1(a6),d0
		and.b	#$fe,d0
		move.b	d0,vibsize1(a5)
		lsr.b	#1,d0
		move.b	d0,vibsize2(a5)
		move.b	help1+3(a6),vibrate(a5)
		move.b	#1,vibcount(a5)
		clr.w	vibperiod(a5)
		bra	npout
.novib
		cmp.b	#$f5,d0
		bne.s	.keyon
		clr.b	keyflag(a5)
		bra.s	npout
.keyon
		cmp.b	#$bf,d0
		bcc.s	portnote
.noteonly
		move.b	help1+3(a6),d0
		ext.w	d0
		move.w	d0,detunes(a5)

		move.b	help1+2(a6),d0
		lsr.b	#4,d0
		and.w	#$f,d0		;!!and.w - Hibyte is zero
		move.b	d0,basevol+1(a5)

		move.b	help1+1(a6),d0
		move.b	basenote+1(a5),basenote(a5)
		move.b	help1(a6),basenote+1(a5)
		move.l	macrobase(a6),a4
		add.w	d0,d0		;!!Be careful - Hibyte must be zero
		add.w	d0,d0		;Extent to longword pointer
		adda.w	d0,a4
		move.l	(a4),a4
		add.l	database(a6),a4
		cmp.l	madress(a5),a4
		beq.s	.skip
		sf.b	mskipflag(a5)
.skip
		move.l	a4,madress(a5)
		clr.w	mstep(a5)
		clr.w	mawait(a5)
		clr.b	modstatus(a5)
		sf.b	mloopcount(a5)
		st.b	mstatus(a5)
		move.b	#1,keyflag(a5)
npout
		move.l	(sp)+,help1(a6)
		movem.l	(sp)+,d0/a4-a6
		rts
portnote
		move.b	help1+1(a6),pospeed(a5)
		move.b	#1,pocount(a5)
		tst.w	potime(a5)
		bne.s	.noperiod
		move.w	baseperiod(a5),poperiod(a5)
.noperiod
		clr.w	potime(a5)
		move.b	help1+3(a6),potime+1(a5)

		move.b	help1(a6),d0
		and.w	#$3f,d0
		move.b	d0,basenote+1(a5)
		add.w	d0,d0

		lea	nottab(pc),a4		;note-periods		
		move.w	(a4,d0.w),baseperiod(a5)
		bra.s	npout
;
channeloff
		move.l	a5,-(sp)
		lea	Synoffsets(pc),a5	;a5=synthesizervar.
		and.w	#$f,d0			;channelnumber
		add.w	d0,d0
		add.w	d0,d0			;extend to lw-pointer
		move.l	(a5,d0.w),a5		;get channelbase
		cmp.w	#$18,d0
		blt.s	.nopsg
		move.b	psg_pulsoff(a5),d0
		or.b	d0,psgmix(a6)
;		move.b	psgmix(a6),GIWRITE

	move.b	psgmix(A6),7*4+2(A3)

		move.b	psg_noisoff(a5),d0
		or.b	d0,psgmix(a6)
;		move.b	psgmix(a6),GIWRITE

	move.b	psgmix(A6),7*4+2(A3)

		clr.b	psg_ebit(a5)
.nopsg
		clr.b	mstatus(a5)		;stop macro
		clr.b	riffstats(a5)
.out
		move.l	(sp)+,a5
		rts
;
;
;fade
;		movem.l	a5/a6,-(sp)
;		lea	CHfield0(pc),a6
;		lea	infodat(pc),a5
;		move.w	#1,info_fade(a5)
;		move.b	d0,fadeend(a6)
;		swap	d0
;		move.b	d0,fadecount1(a6)
;		move.b	d0,fadecount2(a6)
;		beq.s	.norm
;		move.b	fadevol(a6),d0
;		move.b	#1,fadeadd(a6)
;		cmp.b	fadeend(a6),d0
;		beq.s	.nofad
;		bcs.s	.out
;		neg.b	fadeadd(a6)
;		bra.s	.out
;.norm
;		move.b	fadeend(a6),fadevol(a6)
;.nofad
;		clr.b	fadeadd(a6)
;		clr.w	info_fade(a5)
;.out
;		movem.l	(sp)+,a5/a6
;		rts
;info
;		lea	infodat(pc),a0
;		move.l	a1,-(sp)
;		lea	CHfield0(pc),a1
;		move.l	a1,info_ch0(a0)
;		lea	CHfield2(pc),a1
;		move.l	a1,info_ch2(a0)
;		move.l	(sp)+,a1
;		rts
aclear
		clr.b	mstatus(a6)		;stop macro
		sf.b	mskipflag(a6)
		clr.b	riffstats(a6)
		clr.b	psg_samflag(a6)
		rts
;
alloff
		move.l	a6,-(sp)
		lea	CHfield0(pc),a6
		clr.b	allon(a6)		;disable routine
		move.b	#$ff,psgmix(a6)
		lea	psgfield0(pc),a6
		bsr	aclear
		lea	psgfield1(pc),a6
		bsr	aclear
		lea	psgfield2(pc),a6
		bsr	aclear
		lea	psgfield3(pc),a6
		bsr	aclear
;		move.b	#7,GISELECT
;		move.b	#$ff,GIWRITE
;		move.b	#13,GISELECT
;		move.b	#0,GIWRITE


;;	lea	lbL000E26(PC),A6
;;	move.b	#$FF,7*4+2(A6)
;;	clr.b	13*4+2(A6)

		lea	infodat(pc),a6
		clr.b	info_seqrun(a6)
		move.l	(sp)+,a6
		rts
;
songplay
		movem.l	d1-d7/a0-a6,-(sp)
		lea	CHfield0(pc),a6
		move.b	d0,songfl+1(a6)
		bsr.s	songset
		movem.l	(sp)+,d1-d7/a0-a6
		rts
;
playcont
		movem.l	d1-d7/a0-a6,-(sp)
		lea	CHfield0(pc),a6
		or.w	#%100000000,d0
		move.w	d0,songfl(a6)
		bsr.s	songset
		movem.l	(sp)+,d1-d7/a0-a6
		rts
;		
;songset2
;		lea	CHfield0(pc),a6
songset
		bsr	alloff
		clr.b	allon(a6)		;disable routine
		move.l	database(a6),a4		;adress of musicdata
		move.b	songfl+1(a6),d0		;new songnumber
		and.w	#$1f,d0
		add.w	d0,d0			;extend to wordpointer
		adda.w	d0,a4			;add database

		lea	CHfield2(pc),a5		;a5=sequencervar.
		move.b	song(a6),d1		;old song number
		bmi	.nocont
		and.w	#$1f,d1
		add.w	d1,d1			;extend to wordpointer
		lea	songcont(pc),a0		;a0=contvar.
		adda.w	d1,a0
		move.w	cstep(a5),(a0)		;put current step to buffer
		move.b	speed+1(a5),65(a0)	;and songspeed
.nocont
		move.w	fsteps(a4),cstep(a5)	;set current step
		move.w	fsteps(a4),fstep(a5)	;set first   step
		move.w	lsteps(a4),lstep(a5)	;set last    step
		move.w	speeds(a4),d2		;set song speed
		btst.b	#0,songfl(a6)		;test cont flag
		beq.s	.norm1

		lea	songcont(pc),a0		;a0=contvar.
		adda.w	d0,a0
		move.w	(a0),cstep(a5)		;set old current step
		moveq.l	#0,d2
		move.b	65(a0),d2		;and songspeed
.norm1
.notim
		move.w	#28,d1
		lea	emptypatt(pc),a4
.loop
		move.l	a4,padress(a5,d1.w)
		move.w	#$ff00,patterns(a5,d1.w)
		clr.l	pstep(a5,d1.w)
		subq.w	#4,d1
		bpl.s	.loop
		move.w	d2,speed(a5)

		tst.b	songfl+1(a6)
		bmi.s	.noplay
		move.l	database(a6),a4		;a4=adress of musicdata
		bsr	newtrack
.noplay
		clr.b	newstep(a6)		;clr flag for endofpattern
		clr.w	scount(a6)		;clr sequencer speed counter
		st.b	tloopcount(a6)
		move.b	songfl+1(a6),song(a6)	;save new songnumber
		clr.b	songfl(a6)		;clr songmode
		lea	infodat(pc),a4
		clr.w	info_fade(a4)
		clr.b	info_seqrun(a4)
.out
		move.b	#1,allon(a6)		;enable routine
		rts
;
;
;
initdata
		movem.l	a2-a6,-(sp)
		lea	CHfield0(pc),a6
		move.l	#$40400000,fadevol(a6)
		clr.b	fadeadd(a6)		;clear fade
		move.l	d0,database(a6)
		move.l	d1,samplebase(a6)
		move.l	d0,a4
		tst.l	tracks(a4)
		beq.s	.oldversion
		move.l	tracks(a4),d1
		add.l	d0,d1
		move.l	d1,trackbase(a6)
		move.l	ptable(a4),d1
		add.l	d0,d1
		move.l	d1,pattnbase(a6)
		move.l	mtable(a4),d1
		add.l	d0,d1
		move.l	d1,macrobase(a6)
		bra.s	.goon
.oldversion
		move.l	#$800,d1
		add.l	d0,d1
		move.l	d1,trackbase(a6)
		move.l	#$400,d1
		add.l	d0,d1
		move.l	d1,pattnbase(a6)
		move.l	#$600,d1
		add.l	d0,d1
		move.l	d1,macrobase(a6)
.goon
		lea	CHfield2(pc),a5
		move.w	#5,speed(a5)
		lea	songcont(pc),a6
		move.w	#$1f,d0
.contset
		move.w	#5,64(a6)
		clr.w	128(a6)
		clr.w	(a6)+
		dbra	d0,.contset
		lea	CHfield0(pc),a6
		lea	Synoffsets(pc),a4

;		lea	Synoffsets+48(pc),a4		; PSG bugfix
		lea	psgfield0(pc),a5
		move.l	a5,(a4)+
		lea	psgfield1(pc),a5
		move.l	a5,(a4)+
		lea	psgfield2(pc),a5
		move.l	a5,(a4)+
		lea	psgfield3(pc),a5
		move.l	a5,(a4)+

	moveq.l	#11,d0					; PSG bugfix
.filfld
	move.l	-16(a4),(a4)+
	dbra	d0,.filfld

		movem.l	(sp)+,a2-a6
		rts

;
;	Variables
;
;	offsets datafile
fsteps		= 256
lsteps		= 320
speeds		= 384
mutes		= 448
fxtable		= 512
tracks		= $1d0
ptable		= $1d4
mtable		= $1d8
;***
	RSRESET
	EVEN
CHfield0
database	rs.l 1
	dc.l	0
samplebase	rs.l 1
	dc.l	0
		rs.b 1	;!O
	dc.b	0
newstep		rs.b 1	;!E
	dc.b	0
song		rs.b 1	;!O
	dc.b	0
fadeadd		rs.b 1	;!E
	dc.b	0
random		rs.w 1
	dc.w	0
help1		rs.l 1
	dc.l	0
scount		rs.w 1
	dc.w	0
allon		rs.b 1
	dc.b	0
fxflag		rs.b 1
	dc.b	0
songfl		rs.w 1
	dc.w	0
fadevol		rs.b 1	;!O
	dc.b	$40
fadeend		rs.b 1	;!E
	dc.b	$40
fadecount1	rs.b 1	;!O
	dc.b	0
fadecount2	rs.b 1	;!E
	dc.b	0
		rs.b 1	;!O
	dc.b	0
re_in_save	rs.b 1	;!E
	dc.b	0

tloopcount	rs.w 1
	dc.w	-1
trackbase	rs.l 1
	dc.l	0
pattnbase	rs.l 1
	dc.l	0
macrobase	rs.l 1
	dc.l	0
dmaconhelp	rs.l 1
	dc.l	0
psgmix		rs.b 1	;!O
xxs
	dc.b	$f0
		rs.b 1	;!E
	dc.b	0

;***
;	offsets for Synthfields (synthesizer)
;
Synoffsets
	ds.l	16
	RSRESET
;0
mstatus		rs.b	1	;	 **
modstatus	rs.b	1	;	**
offdma		rs.b	1	;	 **
mabcount1	rs.b	1	;	**
basenote	rs.w	1	;
irwait		rs.w	1	;
basevol 	rs.w	1	;
detunes 	rs.w	1	;
madress 	rs.l	1	;
;1
mstep		rs.w	1	;
mawait		rs.w	1	;
onbits		rs.w	1	;
offbits 	rs.w	1	;
volume		rs.b	1	;	 **
oldvol		rs.b	1	;	**
mloopcount	rs.b	1	;	 **
mabcount2	rs.b	1	;	**
envelope	rs.b	1	;	 **
envcount	rs.b	1	;	**
envolume	rs.b	1	;	 **
envspeed	rs.b	1	;	**
;2
vibrate 	rs.b	1	;	 **
vibcount	rs.b	1	;	**
pospeed 	rs.b	1	;	 **
pocount 	rs.b	1	;	**
vibperiod	rs.w	1	;
vibsize1	rs.b	1	;	 **
vibsize2	rs.b	1	;	**
baseperiod	rs.w	1	;
beginadd	rs.w	1	;
sbegin		rs.l	1	;
;3
potime		rs.w	1	;
poperiod	rs.w	1	;
samplen 	rs.w	1	;
keyflag 	rs.b	1	;	 **
riffAND 	rs.b	1	;	**
msubadr 	rs.l	1	;
;4
msubstep	rs.w	1	;		----
oldfx		rs.b	1	;	 **
ims_deltaold	rs.b	1	;	**
intbits 	rs.w	1	;
clibits 	rs.w	1	;
riffspeed	rs.b	1	;	 **	----
riffrandm	rs.b	1	;	**
riffcount	rs.b	1	;	 **
riffstats	rs.b	1	;	**
riffadres	rs.l	1	;		----
;5
riffsteps	rs.w	1	;		----
riffmacro	rs.b	1	;	 **
rifftrigg	rs.b	1	;	**
channadd	rs.l	1	;		----
audioadr	rs.l	1	;
mabadd		rs.l	1	;
period		rs.w	1	;
nwait		rs.b	1	;	 **
mskipflag	rs.b	1	;	**
psg_peroffs	rs.b	1	;	 **
psg_voloffs	rs.b	1	;	**
psg_pulseon	rs.b	1	;	 **
psg_pulsoff	rs.b	1	;	**
psg_noiseon	rs.b	1	;	 **
psg_noisoff	rs.b	1	;	**
psg_ebit	rs.b	1	;	 **
psg_samflag	rs.b	1	;	**
;10
;
	EVEN
;
psgfield0
;0
	dc.l	0		;
	dc.l	0		;
	dc.l	0		;
	dc.l	0		;
;1
	dc.l	0		;
	dc.l	$82010001	;dmabits(on/off)
	dc.l	0		;
	dc.l	0		;
;2
	dc.l	0		;
	dc.l	0		;
	dc.l	0		;
	dc.l	0		;
;3
	dc.l	0		;
	dc.l	0		;
	dc.l	0		;
;4
	dc.l	0		;
	dc.l	0		;irqbits
	dc.l	0		;
	dc.l	0		;
;5
	dc.l	0		;
	dc.l	0		;addchannel
	dc.l	$dff0a0		;audioadr
	dc.l	0		;
	dc.l	$0000ff00	;(period.w/nwait.b/mskipflag)
	dc.l	$0008fe01 ;(psg_peroffs.b/psg_voloffs.b/psg_pulseon.b/psg_pulsoff.b)
	dc.l	$f7080000 ;(psg_noiseon.b/psg_noisoff.b/psg_ebit.b/)

psgfield1
;0
	dc.l	0		;
	dc.l	0		;
	dc.l	0		;
	dc.l	0		;
;1
	dc.l	0		;
	dc.l	$82020002	;dmabits(on/off)
	dc.l	0		;
	dc.l	0		;
;2
	dc.l	0		;
	dc.l	0		;
	dc.l	0		;
	dc.l	0		;
;3
	dc.l	0		;
	dc.l	0		;
	dc.l	0		;
;4
	dc.l	0		;
	dc.l	0		;irqbits
	dc.l	0		;
	dc.l	0		;
;5
	dc.l	0		;
	dc.l	0		;addchannel
	dc.l	$dff0b0		;audioadr
	dc.l	0		;
	dc.l	$0000ff00	;(period.w/nwait.b/mskipflag)
	dc.l	$0209fd02
	dc.l	$ef100000

psgfield2
;0
	dc.l	0		;
	dc.l	0		;
	dc.l	0		;
	dc.l	0		;
;1
	dc.l	0		;
	dc.l	$82040004	;dmabits(on/off)
	dc.l	0		;
	dc.l	0		;
;2
	dc.l	0		;
	dc.l	0		;
	dc.l	0		;
	dc.l	0		;
;3
	dc.l	0		;
	dc.l	0		;
	dc.l	0		;
;4
	dc.l	0		;
	dc.l	0		;irqbits
	dc.l	0		;
	dc.l	0		;
;5
	dc.l	0		;
	dc.l	0		;addchannel
	dc.l	$dff0c0		;audioadr
	dc.l	0		;
	dc.l	$0000ff00	;(period.w/nwait.b/mskipflag)
	dc.l	$040afb04
	dc.l	$df200000

;(Only noise+Chipenvelopesound)
psgfield3
;0
	dc.l	0		;
	dc.l	0		;
	dc.l	0		;
	dc.l	0		;
;1
	dc.l	0		;
	dc.l	0		;dmabits
	dc.l	0		;
	dc.l	0		;
;2
	dc.l	0		;
	dc.l	0		;
	dc.l	0		;
	dc.l	0		;
;3
	dc.l	0		;
	dc.l	0		;
	dc.l	0		;
;4
	dc.l	0		;
	dc.l	0		;irqbits
	dc.l	0		;
	dc.l	0		;
;5
	dc.l	0		;
	dc.l	0		;addchannel
	dc.l	0		;audioadr
	dc.l	0		;
	dc.l	$0000ff00	;(period.w/nwait.b/mskipflag)
	dc.l	$0b06ff00
	dc.l	$ff000000

;***
;	offsets	for CHfield2 (sequencer)
;
fstep		= 0	;.w
lstep		= 2	;.w
cstep		= 4	;.w
speed		= 6	;.w
muteflags	= 8	;8*.w
padress		= 40	;8*.l
patterns	= 72	;8*.w
ploopcount	= 74	;8*.b
; ***		= 75	;8*.b
pstep		= 104	;8*.w
pawait		= 106	;8*.b
; ***		= 107	;8*.b
psubadr		= 136	;8*.l
psubstep	= 168	;8*.w
	EVEN
CHfield2
FirstUsed
 	dc.w	0	;fstep
LastUsed
 	dc.w	0	;lstep
CurrentPos
 	dc.w	0	;cstep
ActualSpeed
 	dc.w	6	;speed
;8
	dc.l	0,0,0,0,0,0,0,0	;(trackmutes.w//pstep.w)
;40
	dc.l	0,0,0,0,0,0,0,0 ;(patternadress.l)
;72
	dc.l	0,0,0,0,0,0,0,0 ;(patterns.w/ploopcount.b/)
;104
	dc.l	0,0,0,0,0,0,0,0 ;(pstep.w/pawait.b/) !Cleared by newtrack
;136
	dc.l	0,0,0,0,0,0,0,0	;(psubadr.l)
;168
	dc.l	0,0,0,0,0,0,0,0	;(psubstep.w/)
; ***
songcont
	ds.w 32	;contstep
;64
	ds.w 32	;/songspeed
;128
	ds.w 32	;timerspeed
;***
info_fade	= 0
info_error	= 2
info_ch0	= 4
info_ch1	= 8
info_ch2	= 12
info_uvbi	= 16
info_cliout	= 20
info_seqrun	= 21
info_rec	= 22
info_midi	= 26
info_flags	= 30
; ***
	EVEN
infodat
	dc.w	0	;fadeend		0
	dc.w	0	;errorflag		2
	dc.l	0	;adress CHfield0	4
	dc.l	0	;adress CHfield1	8
	dc.l	0	;adress CHfield2	12
	dc.l	0	;adress pointer to uservbi	16
	dc.b	0	;cliout flag		20
	dc.b	0	;sequencer running	21
	dc.l	0	;adress recfield	22
	dc.l	0	;adress midifield	26
	dc.w	0,0,0,0 ;Programmer flags       30-37  (set by macrostatment $20
		;				or patternstatment $fd !)

emptypatt
 dc.l	$f4000000,$f0000000
;		Note-table v1.0
; dc.w 3420,3228,3048,2876,2714,2562,2418,2282,2154,2034,1920,1816
nottab
	dc.w 1710,1614,1524,1438,1357,1281,1209,1141,1077,1017, 960, 908
	dc.w  856, 810, 764, 720, 680, 642, 606, 571, 539, 509, 480, 454
	dc.w  428, 404, 381, 360, 340, 320, 303, 286, 270, 254, 240, 227
	dc.w  214, 202, 191, 180, 170, 160, 151, 143, 135, 127, 120, 113
	dc.w  214, 202, 191, 180, 170, 160, 151, 143, 135, 127, 120, 113
	dc.w  214, 202, 191, 180

PSG_nottab
	dc.w 2703,2551,2407,2273,2145,2025,1911,1804,1703,1607,1517,1432
	dc.w 1351,1275,1203,1136,1072,1012, 955, 902, 851, 803, 758, 716
	dc.w  675, 637, 601, 568, 536, 506, 477, 451, 425, 401, 379, 358
	dc.w  337, 318, 300, 284, 268, 253, 238, 225, 212, 200, 189, 179
	dc.w  168, 159, 150, 142, 134, 126, 119, 112, 106, 100,  94,  89
	dc.w   84,  79,  75,  71



Voice
	dc.b	1			; left 1
	dc.b	8			; left 2
	dc.b	4			; right 2
	dc.b	2			; right 1
NotePlay
	lea	$dff000,A5			; load CustomBase

; Note: d2 must contain the DMA mask of the channels you want to stop,
;       and d3 the DMA mask of the channels you want to start.
;       The vhpos, vhposr, etc. definitions can be found in the
;       hardware/custom.i include file.
;       BTW - this routine cannot be used if a replay uses audio-interrupts
;       (because it uses the intreq/intreqr registers for waiting)!

	moveq	#0,D2
	move.b	Voice(PC,D5.W),D2

.StopDMA
	move.b	vhposr(A5),d1
.WaitLine1
	cmp.b	vhposr(A5),d1			; sync routine to start at linestart
	beq.s	.WaitLine1
.WaitDMA1
	cmp.b	#$16,vhposr+1(A5)		; wait til after Audio DMA slots
	bcs.s	.WaitDMA1
	move.w	#1,6(A1)

	move.w	dmaconr(A5),d0			; get active channels
	and.w	d2,d0
	move.w	d0,d1
	lsl.w	#7,d0
	move.w	d0,intreq(A5)			; clear requests
	move.w	d1,dmacon(A5)			; stop channels
.WaitStop
	move.w	intreqr(A5),d1			; wait until all channels are stopped
	and.w	d0,d1
	cmp.w	d0,d1
	bne.s	.WaitStop
.Skip

; Here you must set the oneshot-parts of the samples you stopped before

	move.l	A2,(A1)
	move.w	D4,4(A1)
	bsr.w	SetTwo
	swap	D4

; Because of the period = 1 trick used above, you must _always_ set the period
; of the stopped channels here, otherwise the output will sound wrong
; If you want to mute a channel, you can either turn it off, but not on again
; (by setting the channel's DMA bit in the d2 register, and clearing the channel's
; DMA bit in the d3 register), or you have to play a oneshot-nullsample and
; a loop-nullsample (smiliar to ProTracker)

	move.b	vhposr(A5),d1
.WaitLine2
	cmp.b	vhposr(A5),d1			; sync routine to start at linestart
	beq.s	.WaitLine2
.WaitDMA2
	cmp.b	#$16,vhposr+1(A5)		; wait til after Audio DMA slots
	bcs.s	.WaitDMA2
.StartDMA
	move.w	dmaconr(A5),d0			; get active channels
	not.w	d0
	and.w	D2,D0

	move.w	d0,d1
	or.w	#$8000,d1
	lsl.w	#7,d0
	move.w	d0,intreq(A5)			; clear requests
	move.w	d1,dmacon(A5)			; start channels
.WaitStart
	move.w	intreqr(A5),d1			; wait until all channels are running
	and.w	d0,d1
	cmp.w	d0,d1
	bne.s	.WaitStart

	move.b	vhposr(A5),d1
.WaitLine3
	cmp.b	vhposr(A5),d1			; sync routine to start at linestart
	beq.s	.WaitLine3
.WaitDMA3
	cmp.b	#$16,vhposr+1(A5)		; wait til after Audio DMA slots
	bcs.s	.WaitDMA3

; Here you must set the loop-parts of the samples. If a sample doesn't have
; a loop, then you have to play a nullsample of length 1 (similiar to ProTracker).

	move.l	A3,(A1)
	move.w	D4,4(A1)
.Done
	rts


Init_Emu
lbC000392	LEA	lbL000616(PC),A0
	MOVE.W	#0,10(A0)
	LEA	lbL000622(PC),A0
	MOVE.W	#0,10(A0)
	LEA	lbL00062E(PC),A0
	MOVE.W	#0,10(A0)
	LEA	lbL000E26(PC),A0
	MOVE.B	#$3B,$1E(A0)
	MOVE.B	#$10,$2A(A0)
	MOVE.B	#0,$26(A0)
	MOVE.B	#0,$22(A0)
	MOVE.B	#4,$16(A0)
	MOVE.B	#0,$12(A0)

	clr.b	11*4+2(A0)
	clr.b	12*4+2(A0)
	clr.b	13*4+2(A0)
	lea	lbW0004C4(PC),A0
	move.w	#$240,(A0)
	clr.w	4(A0)

	RTS

Play_Emu
	LEA	lbL000E26(PC),A6
	MOVE.B	$1E(A6),D7
	NOT.B	D7
	ANDI.W	#$3F,D7

	lea	$DFF0A0,A1

	LEA	lbL000616(PC),A0
	MOVEQ	#0,D5
	MOVEQ	#3,D6
	MOVE.B	6(A6),D4
	LSL.W	#8,D4
	MOVE.B	2(A6),D4
	MOVEQ	#0,D3
	MOVE.B	$22(A6),D3
	BSR.L	lbC0004DC

	lea	$DFF0D0,A1

	LEA	lbL000622(PC),A0
	MOVEQ	#1,D5
	MOVEQ	#4,D6
	MOVE.B	14(A6),D4
	LSL.W	#8,D4
	MOVE.B	10(A6),D4
	MOVEQ	#0,D3
	MOVE.B	$26(A6),D3
	BSR.L	lbC0004DC

	lea	$DFF0C0,A1

	LEA	lbL00062E(PC),A0
	MOVEQ	#2,D5
	MOVEQ	#5,D6
	MOVE.B	$16(A6),D4
	LSL.W	#8,D4
	MOVE.B	$12(A6),D4
	MOVEQ	#0,D3
	MOVE.B	$2A(A6),D3
	BSR.L	lbC0004DC

	moveq	#3,D5
	lea	$DFF0B0,A1

	TST.W	lbW0004C8
	BNE.S	lbC00046C

	lea	Empty,A2
	moveq	#1,D4

	BRA.S	lbC00048A

lbC00046C	CMPI.W	#1,lbW0004C8
	BNE.S	lbC0004BC
	MOVE.W	#2,lbW0004C8

	move.l	lbL0004BE(PC),A2
	move.w	lbW0004C2(PC),D4

lbC00048A
	swap	D4
	move.w	#1,D4
	swap	D4
	lea	Empty,A3
	bsr.w	NotePlay
	move.w	lbW0004C4(PC),D0
	move.w	D0,6(A1)
	bsr.w	SetPer
	move.w	lbW0004C6(PC),D0
	bsr.w	ChangeVolume
	bsr.w	SetVol
	move.w	D0,8(A1)

lbC0004BC	RTS

samadr
lbL0004BE	dc.l	Empty
samlen
lbW0004C2	dc.w	1
lbW0004C4	dc.w	$240
lbW0004C6	dc.w	$40
lbW0004C8	dc.w	0
lbB0004CA	dc.b	0
	dc.b	1
	dc.b	2
	dc.b	3
	dc.b	4
	dc.b	6
	dc.b	8
	dc.b	10
	dc.b	13
	dc.b	$10
	dc.b	$14
	dc.b	$18
	dc.b	$1E
	dc.b	$26
	dc.b	$30
	dc.b	$40
	dc.b	$20
	dc.b	$20
	dc.b	$20
	dc.b	$20
	dc.b	$20
	dc.b	$20
	dc.b	$20
	dc.b	$20
	dc.b	$20
	dc.b	$20
	dc.b	$20
	dc.b	$20
	dc.b	$20
	dc.b	$20
	dc.b	$20
	dc.b	$20

lbC0004DC

	and.w	#31,D3

	MOVE.B	lbB0004CA(PC,D3.W),1(A0)

	and.w	#$FFF,D4

	MULU.W	#7,D4

	addq.w	#1,D4

	MOVE.W	D4,2(A0)
	BTST	D5,D7
	BNE.L	lbC0005DA
	BTST	D6,D7
	BNE.L	lbC00054A

	lea	Empty,A2
	move.l	A2,A3
	move.l	#$10001,D4
	bsr.w	NotePlay

	MOVE.W	#0,0(A0)
	MOVE.W	#$100,2(A0)
	MOVE.W	#0,10(A0)
lbC000530
	move.w	(A0),D0
	bsr.w	ChangeVolume
	bsr.w	SetVol
	move.w	D0,8(A1)
	move.w	2(A0),D0
	move.w	D0,6(A1)
	bsr.w	SetPer

	RTS

lbC00054A	MOVE.W	10(A0),D0
	CMP.W	#2,D0
	BEQ.S	lbC000582
	MOVE.W	#2,10(A0)

	lea	lbL001070,A2
	move.l	A2,A3
	move.l	#$2000200,D4
	bsr.w	NotePlay

lbC000582	MOVEQ	#0,D0
	MOVE.B	$1A(A6),D0
	ANDI.W	#$1F,D0
	ADD.W	D0,D0
	MOVE.W	lbW00059A(PC,D0.W),D0
	MOVE.W	D0,2(A0)
	BRA.L	lbC000530

lbW00059A	dc.w	$280
	dc.w	$270
	dc.w	$260
	dc.w	$250
	dc.w	$240
	dc.w	$230
	dc.w	$220
	dc.w	$210
	dc.w	$200
	dc.w	$1F0
	dc.w	$1E0
	dc.w	$1D0
	dc.w	$1C0
	dc.w	$1B0
	dc.w	$1A0
	dc.w	$190
	dc.w	$180
	dc.w	$170
	dc.w	$160
	dc.w	$150
	dc.w	$140
	dc.w	$130
	dc.w	$120
	dc.w	$110
	dc.w	$100
	dc.w	$F0
	dc.w	$E0
	dc.w	$D0
	dc.w	$C0
	dc.w	$B0
	dc.w	$A0
	dc.w	$90

lbC0005DA	MOVE.W	10(A0),D0
	CMP.W	#1,D0
	BEQ.S	lbC000612
	MOVE.W	#1,10(A0)

	lea	lbL001478,A2
	move.l	A2,A3
	move.l	#$20002,D4
	bsr.w	NotePlay

lbC000612	BRA.L	lbC000530

lbL000616	dc.l	0
	dc.l	0
	dc.l	0
lbL000622	dc.l	0
	dc.l	0
	dc.l	0
lbL00062E	dc.l	0
	dc.l	0
	dc.l	0

InitSamp
	LEA	lbL001070,A0
	MOVE.W	#$3FF,D2
lbC000DD4	BSR.S	lbC000DE2
	MOVE.B	D0,(A0)+
	DBRA	D2,lbC000DD4
	RTS

lbL000DDE	dc.l	'HIPP'

lbC000DE2	MOVE.L	lbL000DDE,D0
	MOVE.L	D0,D1
	ASL.L	#3,D1
	SUB.L	D0,D1
	ASL.L	#3,D1
	ADD.L	D0,D1
	ADD.L	D1,D1
	ADD.L	D0,D1
	ASL.L	#4,D1
	SUB.L	D0,D1
	ADD.L	D1,D1
	SUB.L	D0,D1
	ADDI.L	#$E90,D0
	LSL.W	#4,D0
	ADD.L	D0,D1
	BCLR	#$1F,D1
	MOVE.L	D1,D0
	SUBQ.L	#1,D0
	MOVE.L	D0,lbL000DDE
	LSR.L	#8,D0
	RTS

lbL000E26
	dc.l	0		; YM-2149 LSB period base (canal A)
	dc.l	$1000000	; YM-2149 MSB period base (canal A)
	dc.l	$2000000	; YM-2149 LSB period base (canal B)
	dc.l	$3000000	; YM-2149 MSB period base (canal B)
	dc.l	$4000000	; YM-2149 LSB period base (canal C)
	dc.l	$5000000	; YM-2149 MSB period base (canal C)
	dc.l	$6000000	; Noise period
	dc.l	$700FF00	; Mixer control
	dc.l	$8000000	; YM-2149 volume base register (canal A)
	dc.l	$9000000	; YM-2149 volume base register (canal B)
	dc.l	$A000000	; YM-2149 volume base register (canal C)
				; envelope data (unsupported)
	dc.l	$B000000	; YM-2149 envelope LSB period
	dc.l	$C000000	; YM-2149 envelope MSB period
	dc.l	$D000000        ; YM-2149 envelope wave form

	Section	Buffy,BSS_C

lbL001070
	ds.b	1024
lbL001478
	ds.b	4
Empty
	ds.b	4

	Section BuffyHead,BSS
Header
	ds.b	248*2

	*****************************************************
	****        RJP replayer for EaglePlayer,	 ****
	****        all adaptions by Wanted Team	 ****
	****     DeliTracker (?) compatible version	 ****
	*****************************************************

	incdir	"dh2:include/"
	include 'misc/eagleplayer2.01.i'

	SECTION	Player_Code,CODE

	PLAYERHEADER Tags

	dc.b	'$VER: Richard Joseph Player V1.7A module replayer V1.1 (3 May 2001)',0
	even
Tags
	dc.l	DTP_PlayerVersion,2
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
	dc.l	DTP_EndSound,End
	dc.l	DTP_Interrupt,Interrupt
	dc.l	DTP_Volume,SetVolume
	dc.l	DTP_Balance,SetVolume
	dc.l	EP_Voices,SetVoices
	dc.l	EP_Get_ModuleInfo,GetInfos
	dc.l	EP_StructInit,StructInit
	dc.l	EP_GetPositionNr,GetPosition
	dc.l	EP_SampleInit,SampleInit
	dc.l	EP_Flags,EPB_Volume!EPB_Balance!EPB_ModuleInfo!EPB_Voices!EPB_SampleInfo!EPB_Songend!EPB_Analyzer!EPB_NextSong!EPB_PrevSong!EPB_Packable!EPB_Restart!EPB_LoadFast
	dc.l	0

PlayerName
	dc.b	'Richard Joseph Player',0
Creator
	dc.b	'(c) 1992-93 by Richard Joseph & Andi',10
	dc.b	'Smithers, adapted by Wanted Team',0
Prefix
	dc.b	'RJP.',0
SampleName
	dc.b	'SMP.set',0
	even

ModulePtr
	dc.l	0
SamplePtr
	dc.l	0
EagleBase
	dc.l	0
SongEnd
	dc.l	'WTWT'
SongEndTemp
	dc.l	0
CurrentPos
	dc.l	0
FirstUsed
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
Per_1
	dc.w	0
Per_2
	dc.w	0
Per_3
	dc.w	0
Per_4
	dc.w	0

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

	move.l	InfoBuffer+Voices(PC),D0
	bne.b	NoEnd
	move.l	EagleBase(PC),A5
	move.l	dtg_SongEnd(A5),A0
	jsr	(A0)
NoEnd
	bsr.w	Play

	lea	StructAdr(PC),A0
	clr.w	UPS_Enabled(A0)
	movem.l	(A7)+,D1-A6
	moveq	#0,D0
	rts

SongEndTest
	movem.l	A1/A5,-(A7)
	lea	SongEnd(PC),A1
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
	move.l	SongEndTemp(PC),(A1)
	move.l	EagleBase(PC),A5
	move.l	dtg_SongEnd(A5),A1
	jsr	(A1)
SkipEnd
	movem.l	(A7)+,A1/A5
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

	moveq	#0,D0
	move.w	18(A2),D0
	add.w	16(A2),D0
	add.l	D0,D0
	move.l	(A2),EPS_Adr(A3)		; sample address
	move.l	D0,EPS_Length(A3)		; sample length
	move.l	#64,EPS_Volume(A3)
	move.w	#USITY_RAW,EPS_Type(A3)
	move.w	#USIB_Playable!USIB_Saveable!USIB_8BIT,EPS_Flags(A3)
	lea	32(A2),A2
	dbf	D5,Next

	moveq	#0,D7
return
	move.l	D7,D0
	rts

***************************************************************************
********************************* EP_GetPosNr *****************************
***************************************************************************

GetPosition
	move.l	CurrentPos(PC),A0
	move.l	(A0),D0
	sub.l	FirstUsed(PC),D0
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
SamplesSize	=	44
Calcsize	=	52
Steps		=	60
Voices		=	68

InfoBuffer
	dc.l	MI_SubSongs,0		;4
	dc.l	MI_LoadSize,0		;12
	dc.l	MI_Songsize,0		;20
	dc.l	MI_Length,0		;28
	dc.l	MI_Samples,0		;36
	dc.l	MI_SamplesSize,0	;44
	dc.l	MI_Calcsize,0		;52
	dc.l	MI_Steps,0		;60
	dc.l	MI_Voices,0		;68
	dc.l	MI_MaxVoices,4
	dc.l	MI_MaxSubSongs,64
	dc.l	MI_MaxSteps,256
	dc.l	MI_MaxLength,128
	dc.l	MI_MaxSamples,256
	dc.l	MI_Prefix,Prefix
	dc.l	0

***************************************************************************
******************************* DTP_Check2 ********************************
***************************************************************************

Check2
	movea.l	dtg_ChkData(A5),A0
	moveq	#-1,D0
	move.l	(A0)+,D1
	clr.b	D1
	cmp.l	#$524A5000,D1
	bne.b	Fault
	cmp.l	#'SMOD',(A0)+
	bne.b	Fault
	addq.l	#4,A0
	tst.l	(A0)
	bne.b	Fault
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
	movea.l	A0,A3
	movea.l	dtg_FileArrayPtr(A5),A1
smp
	move.b	(A1)+,(A0)+
	bne.s	smp

	cmpi.b	#'R',(A3)
	beq.b	R_OK
	cmpi.b	#'r',(A3)
	bne.s	Suffix
R_OK
	cmpi.b	#'J',1(A3)
	beq.b	J_OK
	cmpi.b	#'j',1(A3)
	bne.s	Suffix
J_OK
	cmpi.b	#'P',2(A3)
	beq.b	P_OK
	cmpi.b	#'p',2(A3)
	bne.s	Suffix
P_OK
	cmpi.b	#'.',3(A3)
	bne.s	Suffix

	move.b	#'S',(A3)+
	move.b	#'M',(A3)+
	move.b	#'P',(A3)

	bra.b	ExtOK
ExtError
	clr.b	-2(A0)
ExtOK
	clr.b	-1(A0)
	rts

Suffix
loop2
	tst.b	(A3)+
	bne.s	loop2
	subq.l	#5,A3

	cmpi.b	#'.',(A3)+
	bne.s	ExtError

	cmpi.b	#'s',(A3)
	beq.b	s_OK
	cmpi.b	#'S',(A3)
	bne.s	ExtError
s_OK
	cmpi.b	#'n',1(A3)
	beq.b	n_OK
	cmpi.b	#'N',1(A3)
	bne.s	ExtError
n_OK
	cmpi.b	#'g',2(A3)
	beq.b	g_OK
	cmpi.b	#'G',2(A3)
	bne.s	ExtError
g_OK

	move.b	#'I',(A3)+
	move.b	#'N',(A3)+
	move.b	#'S',(A3)
	bra.b	ExtOK

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

	lea	ModulePtr(PC),A6
	move.l	A0,(A6)+			; songdata buffer

	lea	InfoBuffer(PC),A2	; A2 reserved for InfoBuffer
	move.l	D0,LoadSize(A2)

	move.l	ModulePtr(PC),A0
	move.l	A0,A1
	addq.l	#8,A1
	move.l	(A1)+,D1
	add.l	D1,A1
	lsr.l	#5,D1
	move.l	D1,Samples(A2)
	add.l	(A1)+,A1
	move.l	(A1)+,D0
	add.l	D0,A1
	lsr.l	#2,D0
	move.l	D0,SubSongs(A2)
	add.l	(A1)+,A1
	move.l	(A1)+,D0
	add.l	D0,A1
	lsr.l	#2,D0
	subq.l	#4,D0
	move.l	D0,Steps(A2)
	add.l	(A1)+,A1
	add.l	(A1)+,A1
	sub.l	A0,A1
	move.l	A1,Songsize(A2)
	move.l	A1,Calcsize(A2)
	move.l	A1,D0
	cmp.l	LoadSize(A2),D0
	ble.b	SizeOK
	moveq	#EPR_ModuleTooShort,D0		; error message
	rts
SizeOK	
	cmp.l	#9506,D0			; fix for Crazy Football title
	bne.b	NoFix1
	cmp.w	#2,2650(A0)
	bne.b	NoFix1
	clr.w	2650(A0)
NoFix1
	cmp.l	#2989,D0			; fix for Cannon Fodder 2 title
	bne.b	NoFix2
	cmp.l	#$08050706,1192(A0)
	bne.b	NoFix2
	clr.l	1192(A0)
NoFix2
	subq.l	#1,D1
	addq.l	#8,A0
	addq.l	#4,A0
	moveq	#0,D0
FindMax
	moveq	#0,D2
	move.w	18(A0),D2
	add.w	16(A0),D2
	lsl.l	#1,D2
	add.l	(A0),D2
	moveq	#0,D3
	move.w	26(A0),D3
	lsl.l	#1,D3
	add.l	4(A0),D3
	cmp.l	D3,D2
	bge.b	OKi
	move.l	D3,D2
OKi
	cmp.l	D2,D0
	bge.b	Max
	move.l	D2,D0
Max
	lea	32(A0),A0
	dbf	D1,FindMax
	addq.l	#4,D0
	move.l	D0,SamplesSize(A2)
	add.l	D0,Calcsize(A2)

	moveq	#1,D0
	movea.l	dtg_GetListData(A5),A0
	jsr	(A0)

	move.l	A0,(A6)+			; sample buffer
	add.l	D0,LoadSize(A2)

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
	lea	Interrupt(PC),A1
ClearUPS
	clr.w	(A0)+
	cmp.l	A0,A1
	bne.b	ClearUPS
	move.l	ModulePtr(PC),A0
	move.l	SamplePtr(PC),A1
	bsr.w	Init_Data
	moveq	#13,D0
	bsr.w	Init_Speed
	moveq	#$40,D1				; Volume
	moveq	#-1,D0
	bsr.w	Init_Volume
	move.w	dtg_SndNum(A5),D0
	move.w	D0,D2
	move.l	SubsongPtr(PC),A3
	move.l	StepPtr(PC),A4
	lea	SongEnd(PC),A6
	move.l	#'WTWT',(A6)
FindMaxLength
	moveq	#3,D4
	moveq	#0,D5
	lea	Info+78(PC),A1
NextLength
	move.l	PositionPtr(PC),A0
	moveq	#0,D3
	move.b	(A3)+,D3
	lsl.l	#2,D3
	move.l	ChannelPtr(PC),A2
	add.l	D3,A2
	move.l	(A2)+,D6
	move.l	(A2)+,D1
	cmp.l	A2,A4
	bne.b	NoLast
	move.l	-4(A0),D1
NoLast
	sub.l	D6,D1
	cmp.l	D1,D5
	bgt.b	MaxLength
	move.l	D1,D5
	add.l	D6,A0
	move.l	A0,FirstUsed
	move.l	A1,CurrentPos
MaxLength
	lea	$B0(A1),A1
	dbf	D4,NextLength
	dbf	D2,FindMaxLength

	lea	InfoBuffer(PC),A1
	move.l	D5,Length(A1)
	moveq	#4,D2
	bsr.w	Init_Song
	move.l	(A6)+,(A6)
	move.l	D2,Voices(A1)
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
	move.l	A2,D1
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
	move.w	D0,8(A2)
Exit2
	move.l	(A7)+,D1
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
	movem.l	D0/A1/A3,-(A7)
	lea	StructAdr+UPS_Voice1Adr(PC),A1
	lea	Per_1(PC),A3
	move.w	(A3)+,D0
	cmp.l	#$DFF0A0,(A0)
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice2Adr(PC),A1
	move.w	(A3)+,D0
	cmp.l	#$DFF0B0,(A0)
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice3Adr(PC),A1
	move.w	(A3)+,D0
	cmp.l	#$DFF0C0,(A0)
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice4Adr(PC),A1
	move.w	(A3)+,D0
.SetVoice
	move.w	D0,UPS_Voice1Per(A1)
	move.l	A4,(A1)
	move.w	$12(A2),UPS_Voice1Len(A1)
	movem.l	(A7)+,D0/A1/A3
	rts

*------------------------------- Put Per -------------------------------*

PutPer
	move.l	A0,-(A7)
	lea	Per_1(PC),A0
	cmp.l	#$DFF0A0,A2
	beq.s	.SetVoice
	addq.l	#2,A0
	cmp.l	#$DFF0B0,A2
	beq.s	.SetVoice
	addq.l	#2,A0
	cmp.l	#$DFF0C0,A2
	beq.s	.SetVoice
	addq.l	#2,A0
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
*********************** Richard Joseph Player V1.7A ***********************
***************************************************************************

; Player from game Ruff'n'Tumble

;	BRA.L	lbC0004D2			; Play

;	BRA.L	lbC0001A4			; Init 1
						; A0 - song
						; A1 - samples
;	BRA.L	lbC00014E

;	BRA.L	lbC0003D8			; Init 4

;	BRA.L	lbC00041E

;	BRA.L	lbC00035C			; Init 3

;	BRA.L	lbC000306			; End

;	BRA.L	lbC00039A			; Init 2

;	BRA.L	lbC0002C6

;	dc.b	0
;	dc.b	'$VER: RJ Replayer Version 1.7A (10.07.93)',$A,$D,0
;	dc.b	0

;lbC00014E	MOVE.L	A0,-(SP)
;	ANDI.W	#3,D0
;	LEA	lbW000160(PC),A0
;	MOVE.B	D1,0(A0,D0.W)
;	MOVEA.L	(SP)+,A0
;	RTS

;lbW000160	dc.w	0
;	dc.w	0
;	dc.w	0

;lbC000166	LEA	lbW000160(PC),A0
;	NOT.B	4(A0)
;	BEQ.S	lbC0001A2
;	MOVEQ	#0,D0
;	MOVEQ	#0,D1
;	MOVE.B	(A0)+,D1
;	BEQ.S	lbC00017C
;	BSR.L	lbC000486
;lbC00017C	MOVEQ	#1,D0
;	MOVEQ	#0,D1
;	MOVE.B	(A0)+,D1
;	BEQ.S	lbC000188
;	BSR.L	lbC000486
;lbC000188	MOVEQ	#2,D0
;	MOVEQ	#0,D1
;	MOVE.B	(A0)+,D1
;	BEQ.S	lbC000194
;	BSR.L	lbC000486
;lbC000194	MOVEQ	#3,D0
;	MOVEQ	#0,D1
;	MOVE.B	(A0)+,D1
;	BEQ.S	lbC0001A0
;	BSR.L	lbC000486
;lbC0001A0	CLR.L	-(A0)
;lbC0001A2	RTS

Init_Data
lbC0001A4	MOVEM.L	D0-D7/A0-A6,-(SP)
	LEA	lbL000F8A(PC),A5
	ADDQ.L	#4,A1
	MOVE.L	A1,(A5)
	MOVE.L	4(A0),-(SP)
	MOVE.L	#$4D4F4453,4(A0)
	ADDQ.L	#8,A0
	LEA	4(A5),A1
	MOVEQ	#6,D0
lbC0001C4	MOVE.L	(A0)+,D7
	MOVE.L	A0,(A1)+
	ADDA.L	D7,A0
	DBRA	D0,lbC0001C4
	MOVE.W	#$40,$20(A5)
	MOVE.B	#$40,$28(A5)
	MOVE.B	#$40,$29(A5)
	MOVE.B	#$40,$2A(A5)
	MOVE.B	#$40,$2B(A5)
	MOVE.W	#13,$22(A5)
	SF	$24(A5)
	SF	$25(A5)
	ST	$26(A5)
	ST	$27(A5)
	CMPI.L	#$4D4F4453,(SP)+
	BEQ.S	lbC000246
	MOVEA.L	(A5),A3
	MOVEA.L	4(A5),A2
	MOVE.L	-4(A2),D1
lbC000214	MOVE.L	(A2),D0
	ADD.L	A3,D0
	MOVE.L	D0,(A2)
	MOVE.L	4(A2),D0
	BEQ.S	lbC000222
	ADD.L	A3,D0
lbC000222	MOVE.L	D0,4(A2)
	MOVE.L	8(A2),D0
	BEQ.S	lbC00022E
	ADD.L	A3,D0
lbC00022E	MOVE.L	D0,8(A2)
	MOVE.W	$10(A2),D0
	ADD.W	D0,D0
	MOVE.W	D0,$10(A2)
	LEA	$20(A2),A2
	SUBI.W	#$20,D1
	BNE.S	lbC000214
lbC000246	LEA	lbL000CCA(PC),A0
	BSR.S	lbC0002B8
	MOVE.L	#$DFF0A0,(A0)
	MOVE.W	#1,$2E(A0)
	MOVE.W	#1,$86(A0)
	LEA	lbL000D7A(PC),A0
	BSR.S	lbC0002B8
	MOVE.L	#$DFF0B0,(A0)
	MOVE.W	#2,$2E(A0)
	MOVE.W	#2,$86(A0)
	LEA	lbL000E2A(PC),A0
	BSR.S	lbC0002B8
	MOVE.L	#$DFF0C0,(A0)
	MOVE.W	#4,$2E(A0)
	MOVE.W	#4,$86(A0)
	LEA	lbL000EDA(PC),A0
	BSR.S	lbC0002B8
	MOVE.L	#$DFF0D0,(A0)
	MOVE.W	#8,$2E(A0)
	MOVE.W	#8,$86(A0)
	LEA	$DFF000,A6
	MOVE.W	#15,$96(A6)
	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTS

lbC0002B8	MOVEA.L	A0,A1
	MOVEQ	#0,D0
	MOVEQ	#$57,D1
lbC0002BE	MOVE.W	D0,(A1)+
	DBRA	D1,lbC0002BE
	RTS

;lbC0002C6	MOVEM.L	D0/A0/A5/A6,-(SP)
;	LEA	$DFF000,A6
;	LEA	lbL000F8A(PC),A5
;	LEA	lbL000CCA(PC),A0
;	ADDQ.B	#1,$2E(A5)
;	MOVEQ	#3,D0
;lbC0002DE	CLR.L	$52(A0)
;	TST.L	$A8(A0)
;	BNE.S	lbC0002EE
;	MOVE.W	$2E(A0),$96(A6)
;lbC0002EE	LEA	$B0(A0),A0
;	DBRA	D0,lbC0002DE
;	ANDI.B	#$F0,$2C(A5)
;	SUBQ.B	#1,$2E(A5)
;	MOVEM.L	(SP)+,D0/A0/A5/A6
;	RTS

End
lbC000306	MOVEM.L	D0/A0/A5/A6,-(SP)
	LEA	lbL000F8A(PC),A5
	ADDQ.B	#1,$2E(A5)
	CLR.B	$2C(A5)
	CLR.W	$20(A5)
	LEA	lbL000CCA(PC),A0
	MOVEQ	#3,D0
lbC000320	CLR.B	$5B(A0)
	CLR.L	$52(A0)
	CLR.L	$A8(A0)
	LEA	$B0(A0),A0
	DBRA	D0,lbC000320
	LEA	$DFF000,A6
	MOVEQ	#0,D0
	MOVE.W	#15,$96(A6)
	MOVE.W	D0,$A8(A6)
	MOVE.W	D0,$B8(A6)
	MOVE.W	D0,$C8(A6)
	MOVE.W	D0,$D8(A6)
	SUBQ.B	#1,$2E(A5)
	MOVEM.L	(SP)+,D0/A0/A5/A6
	RTS

Init_Volume
lbC00035C	MOVEM.L	D0/D1/A0/A5,-(SP)
	LEA	lbL000F8A(PC),A5
	ADDQ.B	#1,$2E(A5)
	CMP.W	#$40,D1
	BEQ.S	lbC000372
	ANDI.W	#$3F,D1
lbC000372	TST.B	D0
	BMI.S	lbC000380
	ANDI.W	#3,D0
	MOVE.B	D1,$28(A5,D0.W)
	BRA.S	lbC000390

lbC000380	MOVE.B	D1,$28(A5)
	MOVE.B	D1,$29(A5)
	MOVE.B	D1,$2A(A5)
	MOVE.B	D1,$2B(A5)
lbC000390	SUBQ.B	#1,$2E(A5)
	MOVEM.L	(SP)+,D0/D1/A0/A5
	RTS

Init_Speed
lbC00039A	MOVEM.L	D0/A5,-(SP)
	LEA	lbL000F8A(PC),A5
	ADDQ.B	#1,$2E(A5)
	ANDI.W	#15,D0
	MOVE.W	D0,$22(A5)
	SF	$25(A5)
	ST	$26(A5)
	ST	$27(A5)
	BTST	#3,D0
	BNE.S	lbC0003C4
	SF	$26(A5)
lbC0003C4	BTST	#2,D0
	BNE.S	lbC0003CE
	SF	$27(A5)
lbC0003CE	SUBQ.B	#1,$2E(A5)
	MOVEM.L	(SP)+,D0/A5
	RTS

Init_Song
lbC0003D8	MOVEM.L	D0/D1/A0/A5,-(SP)
	ANDI.W	#$3F,D0
	LEA	lbL000F8A(PC),A5
	ADDQ.B	#1,$2E(A5)
	MOVEA.L	12(A5),A0
	ADD.W	D0,D0
	ADD.W	D0,D0
	ADDA.W	D0,A0
	MOVEQ	#0,D1
	MOVE.B	(A0)+,D1
	BEQ.S	lbC0003FC
	MOVEQ	#0,D0
	BSR.S	lbC00041E
	bra.b	SkipIt1
lbC0003FC
	clr.b	(A6)
	subq.l	#1,D2
SkipIt1
	MOVE.B	(A0)+,D1
	BEQ.S	lbC000404
	MOVEQ	#1,D0
	BSR.S	lbC00041E
	bra.b	SkipIt2
lbC000404
	clr.b	1(A6)
	subq.l	#1,D2
SkipIt2
	MOVE.B	(A0)+,D1
	BEQ.S	lbC00040C
	MOVEQ	#2,D0
	BSR.S	lbC00041E
	bra.b	SkipIt3
lbC00040C
	clr.b	2(A6)
	subq.l	#1,D2
SkipIt3
	MOVE.B	(A0)+,D1
	BEQ.S	lbC000414
	MOVEQ	#3,D0
	BSR.S	lbC00041E
	bra.b	SkipIt4
lbC000414
	clr.b	3(A6)
	subq.l	#1,D2
SkipIt4
	SUBQ.B	#1,$2E(A5)
	MOVEM.L	(SP)+,D0/D1/A0/A5
	RTS

lbC00041E	TST.W	D1
	BEQ.S	lbC000484
	MOVEM.L	D0/D1/A0-A2/A5,-(SP)
	LEA	lbL000F8A(PC),A5
	ADDQ.B	#1,$2E(A5)
	LEA	lbL000CCA(PC),A0
	BSET	D0,$2C(A5)
	MULU.W	#$B0,D0
	ADDA.W	D0,A0
	MOVEA.L	$10(A5),A1
	ADD.W	D1,D1
	ADD.W	D1,D1
	MOVEA.L	0(A1,D1.W),A1
	ADDA.L	$18(A5),A1
	MOVEQ	#0,D1
	MOVE.B	(A1)+,D1
	MOVE.L	A1,$4E(A0)
	ADD.W	D1,D1
	ADD.W	D1,D1
	MOVEA.L	$14(A5),A2
	MOVEA.L	0(A2,D1.W),A2
	ADDA.L	$1C(A5),A2
	MOVE.L	A2,$52(A0)
	MOVE.B	#6,$56(A0)
	MOVEQ	#1,D0
	MOVE.B	D0,$57(A0)
	MOVE.B	D0,$59(A0)
	ST	$5B(A0)
	SUBQ.B	#1,$2E(A5)
	MOVEM.L	(SP)+,D0/D1/A0-A2/A5
lbC000484	RTS

;lbC000486	MOVEM.L	D0/D1/A0/A1/A5,-(SP)
;	LEA	lbL000F8A(PC),A5
;	BTST	#2,$23(A5)
;	BEQ.S	lbC0004CC
;	LEA	lbL000CCA(PC),A0
;	ADDQ.W	#4,D0
;	BSET	D0,$2C(A5)
;	SUBQ.W	#4,D0
;	MULU.W	#$B0,D0
;	ADDA.W	D0,A0
;	ADD.W	D1,D1
;	ADD.W	D1,D1
;	MOVEA.L	$14(A5),A1
;	MOVEA.L	0(A1,D1.W),A1
;	ADDA.L	$1C(A5),A1
;	MOVE.L	A1,$A8(A0)
;	MOVE.B	#6,$AC(A0)
;	MOVEQ	#1,D0
;	MOVE.B	D0,$AD(A0)
;	MOVE.B	D0,$AF(A0)
;lbC0004CC	MOVEM.L	(SP)+,D0/D1/A0/A1/A5
;	RTS

Play
lbC0004D2	MOVEM.L	D1-D7/A0-A6,-(SP)
	LEA	$DFF000,A6
	LEA	lbL000F8A(PC),A5
	TST.B	$2E(A5)
	BNE.S	lbC00054A
;	BSR.L	lbC000166
	MOVE.W	$22(A5),D0
	ANDI.W	#3,D0
	BNE.S	lbC0004FC
	EORI.B	#1,$25(A5)
	MOVEQ	#1,D0
lbC0004FC	SUBQ.B	#1,D0
	MOVE.B	D0,$24(A5)
	MOVE.B	$28(A5),$21(A5)
	MOVE.B	#0,$2D(A5)
	LEA	lbL000CCA(PC),A0
	BSR.S	lbC000554
	MOVE.B	$29(A5),$21(A5)
	MOVE.B	#1,$2D(A5)
	LEA	lbL000D7A(PC),A0
	BSR.S	lbC000554
	MOVE.B	$2A(A5),$21(A5)
	MOVE.B	#2,$2D(A5)
	LEA	lbL000E2A(PC),A0
	BSR.S	lbC000554
	MOVE.B	$2B(A5),$21(A5)
	MOVE.B	#3,$2D(A5)
	LEA	lbL000EDA(PC),A0
	BSR.S	lbC000554
lbC00054A	MOVE.B	$2C(A5),D0
	MOVEM.L	(SP)+,D1-D7/A0-A6
	RTS

lbC000554	CLR.B	$99(A0)
	CLR.B	$41(A0)
	TST.L	$A8(A0)
	BEQ.S	lbC000580
	TST.B	$27(A5)
	BEQ.S	lbC000580
	BSR.L	lbC000938
	BSR.L	lbC000960
	BSR.S	lbC0005DE
	BSR.L	lbC00097A
	BSR.L	lbC000A30
	BSR.L	lbC000B40
	RTS

lbC000580	TST.B	$26(A5)
	BEQ.S	lbC00059A
	TST.B	$5B(A0)
	BEQ.S	lbC00059A
	BSR.S	lbC00059C
	BSR.S	lbC0005C4
	BSR.S	lbC0005DE
	BSR.L	lbC0006E0
	BSR.L	lbC0007F8
lbC00059A	RTS

lbC00059C	BCLR	#0,$39(A0)
	BEQ.S	lbC0005BC
	MOVEA.L	4(A0),A1
	MOVEQ	#0,D0
	MOVE.W	$16(A0),D0
	ADD.L	D0,D0
	ADDA.L	D0,A1
	MOVEA.L	(A0),A2
	MOVE.L	A1,(A2)
	MOVE.W	$18(A0),4(A2)
lbC0005BC	MOVEQ	#0,D7
	MOVE.B	$24(A5),D7
	RTS

lbC0005C4	BCLR	#0,$38(A0)
	BEQ.S	lbC0005DC
	ST	$39(A0)
	MOVE.W	#$8200,D0
	OR.W	$2E(A0),D0
	MOVE.W	D0,$96(A6)
lbC0005DC	RTS

lbC0005DE	MOVE.L	$52(A0),D0
	BEQ.S	lbC000628
	TST.B	$25(A5)
	BNE.S	lbC000628
	SUBQ.B	#1,$57(A0)
	BNE.S	lbC000628
	SUBQ.B	#1,$59(A0)
	BNE.S	lbC000622
	MOVEA.L	D0,A1
	BRA.S	lbC000600

lbC0005FA	ADD.B	D0,D0
	JMP	lbC00062E(PC,D0.W)

lbC000600	MOVEQ	#0,D0
	MOVE.B	(A1)+,D0
	BMI.S	lbC0005FA
	LEA	lbW000C82(PC),A2
	MOVE.W	0(A2,D0.W),D1
	TST.L	$A8(A0)
	BNE.S	lbC000618
	BSR.L	lbC000856
lbC000618	MOVE.L	A1,$52(A0)
	MOVE.B	$58(A0),$59(A0)
lbC000622	MOVE.B	$56(A0),$57(A0)
lbC000628	DBRA	D7,lbC0005DE
	RTS

lbC00062E	BRA.S	lbC000684

	BRA.S	lbC00063E

	BRA.S	lbC000644

	BRA.S	lbC00064A

	BRA.S	lbC000650

	BRA.S	lbC00065A

	BRA.S	lbC000664

	BRA.S	lbC000618

lbC00063E	BSR.L	lbC0007D0
	BRA.S	lbC000618

lbC000644	MOVE.B	(A1)+,$56(A0)
	BRA.S	lbC000600

lbC00064A	MOVE.B	(A1)+,$58(A0)
	BRA.S	lbC000600

lbC000650	MOVE.B	(A1)+,D0
	BEQ.S	lbC000658
	BSR.L	lbC0008C8
lbC000658	BRA.S	lbC000600

lbC00065A	MOVE.B	(A1)+,D0
	MOVE.W	D0,$30(A0)
	ADDQ.L	#1,A1
	BRA.S	lbC000600

lbC000664	ST	$41(A0)
	MOVE.B	(A1)+,$40(A0)
	MOVE.B	(A1)+,$42(A0)
	MOVE.B	(A1)+,$43(A0)
	MOVE.B	(A1)+,$44(A0)
	MOVE.B	(A1)+,$45(A0)
	CLR.L	$46(A0)
	BRA.L	lbC000600

lbC000684	MOVEA.L	$4E(A0),A2
	MOVE.B	#1,$58(A0)
lbC00068E	MOVEQ	#0,D0
	MOVE.B	(A2)+,D0
	BEQ.S	lbC0006AC
	MOVE.L	A2,$4E(A0)
	MOVEA.L	$14(A5),A1
	ADD.W	D0,D0
	ADD.W	D0,D0
	MOVEA.L	0(A1,D0.W),A1
	ADDA.L	$1C(A5),A1
	BRA.L	lbC000600

lbC0006AC
	bsr.w	SongEndTest

	MOVEQ	#0,D0
	MOVE.B	(A2),D0
	BEQ.S	lbC0006CE				; song end
	BMI.S	lbC0006B8				; song loop
	SUBA.W	D0,A2
	BRA.S	lbC00068E				; song restart

lbC0006B8	MOVE.B	1(A2),D0
	MOVEA.L	$10(A5),A2
	ADD.W	D0,D0
	ADD.W	D0,D0
	MOVEA.L	0(A2,D0.W),A2
	ADDA.L	$18(A5),A2
	BRA.S	lbC00068E

lbC0006CE	SUBA.L	A1,A1
	CLR.B	$5B(A0)
	MOVE.B	$2D(A5),D0
	BCLR	D0,$2C(A5)
	BRA.L	lbC000618

lbC0006E0	MOVEA.L	(A0),A2
	BSR.S	lbC000744
	BSR.S	lbC000712
	BSR.S	lbC0006EA
	RTS

lbC0006EA	MOVE.W	$32(A0),D0
	MULS.W	$30(A0),D0
	ASR.W	#6,D0
	MULS.W	$20(A5),D0
	ASR.W	#6,D0
	MOVE.W	D0,$32(A0)
	CMP.W	#$40,D0
	BLS.S	lbC00070C
	BGT.S	lbC00070A
	MOVEQ	#0,D0
	BRA.S	lbC00070C

lbC00070A	MOVEQ	#$40,D0
lbC00070C
	bsr.w	ChangeVolume
	bsr.w	SetVol
;	MOVE.W	D0,8(A2)
	RTS

lbC000712	MOVE.L	12(A0),D0
	BEQ.S	lbC000742
	MOVEA.L	D0,A1
	MOVE.L	$2A(A0),D0
	MOVE.B	0(A1,D0.L),D1
	EXT.W	D1
	MULS.W	$32(A0),D1
	ASR.W	#7,D1
	ADD.W	D1,$32(A0)
	ADDQ.L	#1,D0
	CMP.L	$26(A0),D0
	BNE.S	lbC00073E
	MOVEQ	#0,D0
	MOVE.W	$24(A0),D0
	ADD.L	D0,D0
lbC00073E	MOVE.L	D0,$2A(A0)
lbC000742	RTS

lbC000744	TST.B	$3A(A0)
	BEQ.S	lbC000786
	MOVE.W	#$FF,D2
	MOVE.B	$3B(A0),D0
	EXT.W	D0
	MOVE.B	$3C(A0),D1
	AND.W	D2,D1
	MULS.W	D1,D0
	MOVE.B	$3D(A0),D1

	beq.b	Fix1

	AND.W	D2,D1
	DIVS.W	D1,D0
FixUp1
	MOVEQ	#0,D1
	MOVE.B	$3E(A0),D1
	SUB.B	D0,D1
	MOVE.B	D1,$3F(A0)
	SUBQ.B	#1,$3C(A0)
	CMP.B	$3C(A0),D2
	BNE.S	lbC000786
	MOVEQ	#0,D0
	MOVE.B	$3A(A0),D0
	BMI.S	lbC00079E
	JSR	lbC000790(PC,D0.W)
lbC000786	MOVEQ	#0,D0
	MOVE.B	$3F(A0),D0
	MOVE.W	D0,$32(A0)
lbC000790	RTS

	BRA.S	lbC00079E

	BRA.S	lbC0007A4

Fix1
	moveq	#0,D0
	bra.b	FixUp1

	MOVE.W	#$40,$32(A0)
	RTS

lbC00079E	CLR.B	$3A(A0)
	RTS

lbC0007A4	MOVE.L	$10(A0),D0
	BEQ.S	lbC0007CE
	MOVEA.L	D0,A1
	MOVE.B	3(A1),D0
	MOVE.B	D0,$3E(A0)
	SUB.B	1(A1),D0
	MOVE.B	D0,$3B(A0)
	MOVE.B	4(A1),D0
	MOVE.B	D0,$3D(A0)
	MOVE.B	D0,$3C(A0)
	MOVE.B	#2,$3A(A0)
lbC0007CE	RTS

lbC0007D0	MOVE.L	$10(A0),D0
	BEQ.S	lbC0007F6
	MOVEA.L	D0,A2
	MOVEQ	#0,D0
	MOVE.B	D0,$3E(A0)
	SUB.B	$3F(A0),D0
	MOVE.B	D0,$3B(A0)
	MOVE.B	5(A2),D0
	MOVE.B	D0,$3D(A0)
	MOVE.B	D0,$3C(A0)
	ST	$3A(A0)
lbC0007F6	RTS

lbC0007F8	MOVE.L	8(A0),D0
	BEQ.S	lbC000832
	MOVEA.L	D0,A1
	MOVE.L	$20(A0),D0
	MOVE.B	0(A1,D0.L),D1
	EXT.W	D1
	MULS.W	$34(A0),D1
	ASR.L	#7,D1
	NEG.W	D1
	BPL.S	lbC000816
	ASR.W	#1,D1
lbC000816	ADD.W	$34(A0),D1
	MOVE.W	D1,$36(A0)
	ADDQ.L	#1,D0
	CMP.L	$1C(A0),D0
	BNE.S	lbC00082E
	MOVEQ	#0,D0
	MOVE.W	$1A(A0),D0
	ADD.L	D0,D0
lbC00082E	MOVE.L	D0,$20(A0)
lbC000832	MOVEA.L	(A0),A2
	TST.B	$40(A0)
	BEQ.S	lbC000846
	MOVE.L	$42(A0),D0
	ADD.L	D0,$46(A0)
	SUBQ.B	#1,$40(A0)
lbC000846	MOVEQ	#0,D0
	MOVE.W	$46(A0),D0
	ADD.W	$36(A0),D0
	MOVE.W	D0,6(A2)

	bsr.w	PutPer

	RTS

lbC000856	MOVE.L	$4A(A0),D0
	BEQ.S	lbC0008C6
	MOVEA.L	D0,A2
	MOVE.W	D1,$34(A0)
	MOVE.W	D1,$36(A0)
	TST.B	$41(A0)
	BNE.S	lbC000874
	CLR.L	$46(A0)
	CLR.B	$40(A0)
lbC000874	MOVEA.L	8(A5),A3
	ADDA.W	12(A2),A3
	MOVE.L	A3,$10(A0)
	MOVE.B	1(A3),D0
	MOVE.B	D0,$3E(A0)
	SUB.B	(A3),D0
	MOVE.B	D0,$3B(A0)
	MOVE.B	2(A3),D0
	MOVE.B	D0,$3D(A0)
	MOVE.B	D0,$3C(A0)
	MOVE.B	#4,$3A(A0)
	MOVE.W	$2E(A0),$96(A6)
	MOVEA.L	(A0),A3
	MOVEA.L	4(A0),A4
	MOVEQ	#0,D0
	MOVE.W	D0,10(A3)
	MOVE.W	$10(A2),D0
	ADDA.L	D0,A4
	CLR.W	(A4)
	MOVE.L	A4,(A3)
	MOVE.W	$12(A2),4(A3)

	bsr.w	SetAll

	ST	$38(A0)
lbC0008C6	RTS

lbC0008C8	CMP.B	$5A(A0),D0
	BEQ.S	lbC000936
	MOVE.B	D0,$5A(A0)
	MOVE.L	A2,-(SP)
	MOVEA.L	4(A5),A2
	ASL.W	#5,D0

	cmp.l	-4(A2),D0
	blt.b	NoFix3
	clr.w	D0				; use empty sample
NoFix3

	ADDA.W	D0,A2
	MOVE.L	A2,$4A(A0)
	MOVE.W	$12(A2),$14(A0)
	MOVE.W	$14(A2),$16(A0)
	MOVE.W	$16(A2),$18(A0)
	MOVE.W	14(A2),$30(A0)
	MOVE.W	$18(A2),$1A(A0)
	MOVEQ	#0,D0
	MOVE.L	D0,$20(A0)
	MOVE.W	$1A(A2),D0
	ADD.L	D0,D0
	MOVE.L	D0,$1C(A0)
	MOVE.W	$1C(A2),$24(A0)
	MOVEQ	#0,D0
	MOVE.L	D0,$2A(A0)
	MOVE.W	$1E(A2),D0
	ADD.L	D0,D0
	MOVE.L	D0,$26(A0)
	MOVE.L	(A2),4(A0)
	MOVE.L	4(A2),8(A0)
	MOVE.L	8(A2),12(A0)
	MOVEA.L	(SP)+,A2
lbC000936	RTS

lbC000938	BCLR	#0,$91(A0)
	BEQ.S	lbC000958
	MOVEA.L	$5C(A0),A1
	MOVEQ	#0,D0
	MOVE.W	$6E(A0),D0
	ADD.L	D0,D0
	ADDA.L	D0,A1
	MOVEA.L	(A0),A2
	MOVE.L	A1,(A2)
	MOVE.W	$70(A0),4(A2)
lbC000958	MOVEQ	#0,D7
	MOVE.B	$24(A5),D7
	RTS

lbC000960	BCLR	#0,$90(A0)
	BEQ.S	lbC000978
	ST	$91(A0)
	MOVE.W	#$8200,D0
	OR.W	$86(A0),D0
	MOVE.W	D0,$96(A6)
lbC000978	RTS

lbC00097A	BTST	#2,$23(A5)
	BEQ.S	lbC0009CA
	MOVE.L	$A8(A0),D0
	BEQ.S	lbC0009CA
	TST.B	$25(A5)
	BNE.S	lbC0009CA
	SUBQ.B	#1,$AD(A0)
	BNE.S	lbC0009CA
	SUBQ.B	#1,$AF(A0)
	BNE.S	lbC0009C4
	MOVEA.L	D0,A1
	BRA.S	lbC0009A4

lbC00099E	ADD.B	D0,D0
	JMP	lbC0009CC(PC,D0.W)

lbC0009A4	MOVEQ	#0,D0
	MOVE.B	(A1)+,D0
	BMI.S	lbC00099E
	LEA	lbW000C82(PC),A2
	MOVE.W	0(A2,D0.W),D1
	MOVE.B	$9A(A0),D0
	BSR.L	lbC000B9E
lbC0009BA	MOVE.L	A1,$A8(A0)
	MOVE.B	$AE(A0),$AF(A0)
lbC0009C4	MOVE.B	$AC(A0),$AD(A0)
lbC0009CA	RTS

lbC0009CC	BRA.S	lbC000A20

	BRA.S	lbC0009DC

	BRA.S	lbC0009E2

	BRA.S	lbC0009E8

	BRA.S	lbC0009EE

	BRA.S	lbC0009F8

	BRA.S	lbC000A02

	BRA.S	lbC0009BA

lbC0009DC	BSR.L	lbC000B1C
	BRA.S	lbC0009BA

lbC0009E2	MOVE.B	(A1)+,$AC(A0)
	BRA.S	lbC0009A4

lbC0009E8	MOVE.B	(A1)+,$AE(A0)
	BRA.S	lbC0009A4

lbC0009EE	MOVE.B	(A1)+,D0
	BEQ.S	lbC0009F6
	BSR.L	lbC000C10
lbC0009F6	BRA.S	lbC0009A4

lbC0009F8	MOVE.B	(A1)+,D0
	MOVE.W	D0,$88(A0)
	ADDQ.L	#1,A1
	BRA.S	lbC0009A4

lbC000A02	ST	$99(A0)
	MOVE.B	(A1)+,$98(A0)
	MOVE.B	(A1)+,$9C(A0)
	MOVE.B	(A1)+,$9D(A0)
	MOVE.B	(A1)+,$9E(A0)
	MOVE.B	(A1)+,$9F(A0)
	CLR.L	$A0(A0)
	BRA.S	lbC0009A4

lbC000A20	SUBA.L	A1,A1
	MOVE.B	$2D(A5),D0
	ADDQ.B	#4,D0
	BCLR	D0,$2C(A5)
	BRA.L	lbC0009BA

lbC000A30	MOVEA.L	(A0),A2
	BSR.S	lbC000A94
	BSR.S	lbC000A62
	BSR.S	lbC000A3A
	RTS

lbC000A3A	MOVE.W	$8A(A0),D0
	MULS.W	$88(A0),D0
	ASR.W	#6,D0
	MULS.W	$20(A5),D0
	ASR.W	#6,D0
	MOVE.W	D0,$8A(A0)
	CMP.W	#$40,D0
	BLS.S	lbC000A5C
	BGT.S	lbC000A5A
	MOVEQ	#0,D0
	BRA.S	lbC000A5C

lbC000A5A	MOVEQ	#$40,D0
lbC000A5C
	bsr.w	ChangeVolume
	bsr.w	SetVol
;	MOVE.W	D0,8(A2)
	RTS

lbC000A62	MOVE.L	$64(A0),D0
	BEQ.S	lbC000A92
	MOVEA.L	D0,A1
	MOVE.L	$82(A0),D0
	MOVE.B	0(A1,D0.L),D1
	EXT.W	D1
	MULS.W	$8A(A0),D1
	ASR.W	#7,D1
	ADD.W	D1,$8A(A0)
	ADDQ.L	#1,D0
	CMP.L	$7E(A0),D0
	BNE.S	lbC000A8E
	MOVEQ	#0,D0
	MOVE.W	$7C(A0),D0
	ADD.L	D0,D0
lbC000A8E	MOVE.L	D0,$82(A0)
lbC000A92	RTS

lbC000A94	TST.B	$92(A0)
	BEQ.S	lbC000AD6
	MOVE.W	#$FF,D2
	MOVE.B	$93(A0),D0
	EXT.W	D0
	MOVE.B	$94(A0),D1
	AND.W	D2,D1
	MULS.W	D1,D0
	MOVE.B	$95(A0),D1

	beq.b	Fix2

	AND.W	D2,D1
	DIVS.W	D1,D0
FixUp2
	MOVEQ	#0,D1
	MOVE.B	$96(A0),D1
	SUB.B	D0,D1
	MOVE.B	D1,$97(A0)
	SUBQ.B	#1,$94(A0)
	CMP.B	$94(A0),D2
	BNE.S	lbC000AD6
	MOVEQ	#0,D0
	MOVE.B	$92(A0),D0
	BMI.S	lbC000AEE
	JSR	lbC000AE0(PC,D0.W)
lbC000AD6	MOVEQ	#0,D0
	MOVE.B	$97(A0),D0
	MOVE.W	D0,$8A(A0)
lbC000AE0	RTS

	BRA.S	lbC000AEE

	BRA.S	lbC000AF4

Fix2	moveq	#0,D0
	bra.b	FixUp2

	MOVE.W	#$40,$8A(A0)
	RTS

lbC000AEE	CLR.B	$92(A0)
	RTS

lbC000AF4	MOVEA.L	$68(A0),A1
	MOVE.B	3(A1),D0
	MOVE.B	D0,$96(A0)
	SUB.B	1(A1),D0
	MOVE.B	D0,$93(A0)
	MOVE.B	4(A1),D0
	MOVE.B	D0,$95(A0)
	MOVE.B	D0,$94(A0)
	MOVE.B	#2,$92(A0)
	RTS

lbC000B1C	MOVEA.L	$68(A0),A2
	MOVEQ	#0,D0
	MOVE.B	D0,$96(A0)
	SUB.B	$97(A0),D0
	MOVE.B	D0,$93(A0)
	MOVE.B	5(A2),D0
	MOVE.B	D0,$95(A0)
	MOVE.B	D0,$94(A0)
	ST	$92(A0)
	RTS

lbC000B40	MOVE.L	$60(A0),D0
	BEQ.S	lbC000B7A
	MOVEA.L	D0,A1
	MOVE.L	$78(A0),D0
	MOVE.B	0(A1,D0.L),D1
	EXT.W	D1
	MULS.W	$8C(A0),D1
	ASR.L	#7,D1
	NEG.W	D1
	BPL.S	lbC000B5E
	ASR.W	#1,D1
lbC000B5E	ADD.W	$8C(A0),D1
	MOVE.W	D1,$8E(A0)
	ADDQ.L	#1,D0
	CMP.L	$74(A0),D0
	BNE.S	lbC000B76
	MOVEQ	#0,D0
	MOVE.W	$72(A0),D0
	ADD.L	D0,D0
lbC000B76	MOVE.L	D0,$78(A0)
lbC000B7A	MOVEA.L	(A0),A2
	TST.B	$98(A0)
	BEQ.S	lbC000B8E
	MOVE.L	$9C(A0),D0
	ADD.L	D0,$A0(A0)
	SUBQ.B	#1,$98(A0)
lbC000B8E	MOVEQ	#0,D0
	MOVE.W	$A0(A0),D0
	ADD.W	$8E(A0),D0
	MOVE.W	D0,6(A2)

	bsr.w	PutPer

	RTS

lbC000B9E	MOVE.L	$A4(A0),D0
	BEQ.S	lbC000C0E
	MOVEA.L	D0,A2
	MOVE.W	D1,$8C(A0)
	MOVE.W	D1,$8E(A0)
	TST.B	$99(A0)
	BNE.S	lbC000BBC
	CLR.L	$A0(A0)
	CLR.B	$98(A0)
lbC000BBC	MOVEA.L	8(A5),A3
	ADDA.W	12(A2),A3
	MOVE.L	A3,$68(A0)
	MOVE.B	1(A3),D0
	MOVE.B	D0,$96(A0)
	SUB.B	(A3),D0
	MOVE.B	D0,$93(A0)
	MOVE.B	2(A3),D0
	MOVE.B	D0,$95(A0)
	MOVE.B	D0,$94(A0)
	MOVE.B	#4,$92(A0)
	MOVE.W	$86(A0),$96(A6)
	MOVEA.L	(A0),A3
	MOVEA.L	$5C(A0),A4
	MOVEQ	#0,D0
	MOVE.W	D0,10(A3)
	MOVE.W	$10(A2),D0
	ADDA.L	D0,A4
	CLR.W	(A4)
	MOVE.L	A4,(A3)
	MOVE.W	$12(A2),4(A3)

	bsr.w	SetAll

	ST	$90(A0)
lbC000C0E	RTS

lbC000C10	CMP.B	$9A(A0),D0
	BNE.S	lbC000C18
	RTS

lbC000C18	MOVE.B	D0,$9A(A0)
	MOVE.L	A2,-(SP)
	MOVEA.L	4(A5),A2
	ASL.W	#5,D0

	cmp.l	-4(A2),D0
	blt.b	NoFix4
	clr.w	D0				; use empty sample
NoFix4
	ADDA.W	D0,A2
	MOVE.L	A2,$A4(A0)
	MOVE.W	$12(A2),$6C(A0)
	MOVE.W	$14(A2),$6E(A0)
	MOVE.W	$16(A2),$70(A0)
	MOVE.W	14(A2),$88(A0)
	MOVE.W	$18(A2),$72(A0)
	MOVEQ	#0,D0
	MOVE.L	D0,$78(A0)
	MOVE.W	$1A(A2),D0
	ADD.L	D0,D0
	MOVE.L	D0,$74(A0)
	MOVE.W	$1C(A2),$7C(A0)
	MOVEQ	#0,D0
	MOVE.L	D0,$82(A0)
	MOVE.W	$1E(A2),D0
	ADD.L	D0,D0
	MOVE.L	D0,$7E(A0)
	MOVE.L	(A2),$5C(A0)
	MOVE.L	4(A2),$60(A0)
	MOVE.L	8(A2),$64(A0)
	MOVEA.L	(SP)+,A2
	RTS

lbW000C82	dc.w	$1C5
	dc.w	$1E0
	dc.w	$1FC
	dc.w	$21A
	dc.w	$23A
	dc.w	$25C
	dc.w	$280
	dc.w	$2A6
	dc.w	$2D0
	dc.w	$2FA
	dc.w	$328
	dc.w	$358
	dc.w	$E2
	dc.w	$F0
	dc.w	$FE
	dc.w	$10D
	dc.w	$11D
	dc.w	$12E
	dc.w	$140
	dc.w	$153
	dc.w	$168
	dc.w	$17D
	dc.w	$194
	dc.w	$1AC
	dc.w	$71
	dc.w	$78
	dc.w	$7F
	dc.w	$87
	dc.w	$8F
	dc.w	$97
	dc.w	$A0
	dc.w	$AA
	dc.w	$B4
	dc.w	$BE
	dc.w	$CA
	dc.w	$D6
Info
lbL000CCA	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbL000D7A	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbL000E2A	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbL000EDA	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbL000F8A
FirstSamplePtr
	dc.l	0
SampleInfoPtr
	dc.l	0
VolumePtr
	dc.l	0
SubsongPtr
	dc.l	0
ChannelPtr
	dc.l	0
StepPtr
	dc.l	0
PositionPtr
	dc.l	0
FirstStepPtr
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	end

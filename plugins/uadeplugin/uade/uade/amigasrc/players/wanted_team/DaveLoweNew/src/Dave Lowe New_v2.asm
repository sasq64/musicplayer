	*****************************************************
	****    Dave Lowe New replayer for EaglePlayer,	 ****
	****         all adaptions by Wanted Team	 ****
	****      DeliTracker compatible (?) version	 ****
	*****************************************************

	incdir	"dh2:include/"
	include 'misc/eagleplayer2.01.i'

	SECTION	Player,CODE

	PLAYERHEADER Tags

	dc.b	'$VER: Dave Lowe New player module V1.1 (8 June 2001)',0
	even
Tags
	dc.l	DTP_PlayerVersion,2
	dc.l	EP_PlayerVersion,9
	dc.l	DTP_RequestDTVersion,DELIVERSION
	dc.l	DTP_PlayerName,PlayerName
	dc.l	DTP_Creator,Creator
	dc.l	DTP_Check2,Check2
	dc.l	DTP_Interrupt,Interrupt
	dc.l	DTP_SubSongRange,SubSongRange
	dc.l	DTP_InitPlayer,InitPlayer
	dc.l	DTP_EndPlayer,EndPlayer
	dc.l	DTP_InitSound,InitSound
	dc.l	DTP_EndSound,EndSound
	dc.l	EP_Get_ModuleInfo,GetInfos
	dc.l	EP_SampleInit,SampleInit
	dc.l	DTP_Volume,SetVolume
	dc.l	DTP_Balance,SetBalance
	dc.l	EP_Voices,SetVoices
	dc.l	EP_StructInit,StructInit
	dc.l	EP_GetPositionNr,GetPosition
	dc.l	EP_Flags,EPB_Volume!EPB_Balance!EPB_ModuleInfo!EPB_Voices!EPB_SampleInfo!EPB_Songend!EPB_Analyzer!EPB_NextSong!EPB_PrevSong!EPB_Packable!EPB_Restart
	dc.l	TAG_DONE
PlayerName
	dc.b	'Dave Lowe New',0
Creator
	dc.b	'(c) 1993-95 Dave Lowe from Uncle Art,',10
	dc.b	'adapted by Wanted Team',0
Prefix
	dc.b	'DLN.',0
	even
TempValue
	dc.l	0
Format
	dc.b	0
CurrentFormat
	dc.b	0
ModulePtr
	dc.l	0
SampleInfoPtr
	dc.l	0
EagleBase
	dc.l	0
SongEnd
	dc.b	'WTWT'
CurrentPos
	dc.l	0
Hardware
	dc.l	$00DF0000
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
********************************* EP_GetPosNr *****************************
***************************************************************************

GetPosition
	move.l	CurrentPos(PC),D0
	lsr.l	#2,D0
	rts

***************************************************************************
******************** DTP_Volume DTP_Balance *******************************
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

*------------------------------- Set Adr -------------------------------*

SetAdr
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
	move.l	A1,(A0)
	move.l	(A7)+,A0
	rts

*------------------------------- Set Len -------------------------------*

SetLen
	move.l	A0,-(A7)
	lea	StructAdr+UPS_Voice1Len(PC),A0
	cmp.l	#$DFF0A0,A2
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice2Len(PC),A0
	cmp.l	#$DFF0B0,A2
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice3Len(PC),A0
	cmp.l	#$DFF0C0,A2
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
	cmp.l	#$DFF0A0,A2
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice2Per(PC),A0
	cmp.l	#$DFF0B0,A2
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice3Per(PC),A0
	cmp.l	#$DFF0C0,A2
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice4Per(PC),A0
.SetVoice
	move.w	D0,(A0)
	move.l	(A7)+,A0
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
******************************* EP_StructInit *****************************
***************************************************************************

StructInit
	lea	StructAdr(PC),A0
	rts

***************************************************************************
******************************* EP_SampleInit *****************************
***************************************************************************

SampleInit
	moveq	#EPR_NotEnoughMem,D7
	lea	EPG_SampleInfoStructure(A5),A3
	move.l	SampleInfoPtr(PC),D0
	beq.b	return
	move.l	D0,A0

	move.l	InfoBuffer+Samples(PC),D5
	beq.b	return
	subq.l	#1,D5
	move.l	ModulePtr(PC),A2
hop
	jsr	ENPP_AllocSampleStruct(A5)
	move.l	D0,(A3)
	beq.b	return
	move.l	D0,A3

	moveq	#0,D0
	move.l	2(A0),D1
	beq.b	EmptySamp
	lea	0(A2,D1.L),A1
	move.w	6(A0),D0
	add.l	D0,D0
	move.l	A1,EPS_Adr(A3)			; sample address
EmptySamp
	move.l	D0,EPS_Length(A3)		; sample length
	move.l	#64,EPS_Volume(A3)
	move.w	#USITY_RAW,EPS_Type(A3)
	move.w	#USIB_Playable!USIB_Saveable!USIB_8BIT,EPS_Flags(A3)
	addq.l	#8,A0
	addq.l	#6,A0
	dbf	D5,hop

	moveq	#0,D7
return
	move.l	D7,D0
	rts

***************************************************************************
******************************* DTP_Check2 ********************************
***************************************************************************

Check2
	move.l	dtg_ChkData(A5),A0
	moveq	#-1,D0

	move.l	A0,A1
	cmp.w	#8,(A0)
	beq.b	Later
	cmp.w	#4,(A0)
	bne.b	fail
	tst.l	24(A0)
	bne.b	Later1
Later
	addq.l	#4,A1
Later1
	addq.l	#4,A1
	moveq	#3,D2
	move.l	A1,A2
FirstCheck
	tst.w	(A1)+
	bne.b	fail
	move.w	(A1)+,D1
	bmi.b	fail
	beq.b	fail
	btst	#0,D1
	bne.b	fail
	dbf	D2,FirstCheck
	moveq	#3,D3
SecondCheck
	move.l	(A2)+,D1
	lea	0(A0,D1.L),A1
	move.l	(A1),D2
	tst.w	(A1)+
	bne.b	fail
	move.w	(A1)+,D1
	bmi.b	fail
	beq.b	fail
	btst	#0,D1
	bne.b	fail
	lea	0(A0,D2.L),A1
	cmp.w	#$30,(A1)
	bne.b	Standard
	addq.l	#2,A1
Standard
	cmp.w	#12,(A1)
	bne.b	NextLong
	addq.l	#6,A1
	cmp.w	#4,(A1)+
	beq.b	Found
NextLong
	dbf	D2,SecondCheck
fail
	rts
Found
	lea	TempValue(PC),A2
	move.l	(A1),(A2)+
	st	(A2)
	tst.l	24(A0)
	bne.b	Later2
	clr.b	(A2)
Later2
	moveq	#0,D0
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

InfoBuffer
	dc.l	MI_SubSongs,0		;4
	dc.l	MI_LoadSize,0		;12
	dc.l	MI_Samples,0		;20
	dc.l	MI_Length,0		;28
	dc.l	MI_Prefix,Prefix
	dc.l	0

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

	lea	CurrentFormat(PC),A0
	tst.b	(A0)
	bne.b	Play1
	bsr.w	Play_2
	bra.b	SkipPlay
Play1
	bsr.w	Play
SkipPlay

	lea	StructAdr(PC),A0
	clr.w	UPS_Enabled(A0)

	movem.l	(SP)+,D1-A6
	moveq	#0,D0
	rts

SongEndTest
	movem.l	A1/A5,-(A7)
	lea	SongEnd(PC),A1
	cmp.l	#$DFF0A0,A2
	bne.b	test1
	tst.b	(A1)
	beq.b	test
	addq.b	#1,(A1)
	bra.b	test
test1
	cmp.l	#$DFF0B0,A2
	bne.b	test2
	tst.b	1(A1)
	beq.b	test
	addq.b	#1,1(A1)
	bra.b	test
test2
	cmp.l	#$DFF0C0,A2
	bne.b	test3
	tst.b	2(A1)
	beq.b	test
	addq.b	#1,2(A1)
	bra.b	test
test3
	cmp.l	#$DFF0D0,A2
	bne.b	test
	tst.b	3(A1)
	beq.b	test
	addq.b	#1,3(A1)
test
	tst.l	(A1)
	bne.b	SkipEnd
	move.l	#$FFFFFFFF,(A1)+
	clr.l	(A1)				; CurrentPos
	move.l	EagleBase(PC),A5
	move.l	dtg_SongEnd(A5),A1
	jsr	(A1)
SkipEnd
	movem.l	(A7)+,A1/A5
	rts

***************************************************************************
***************************** DTP_SubSongRange ****************************
***************************************************************************

SubSongRange	
	moveq	#1,D0
	move.l	InfoBuffer+SubSongs(PC),D1
	rts

***************************************************************************
***************************** DTP_InitPlayer ******************************
***************************************************************************

InitPlayer
	moveq	#0,D0
	movea.l	dtg_GetListData(A5),A0
	jsr	(A0)

	lea	TempValue(PC),A6
	move.l	(A6)+,D2
	move.b	(A6)+,(A6)+			; CurrentFormat
	move.l	A0,(A6)+			; module ptr
	lea	InfoBuffer(PC),A4
	move.l	D0,LoadSize(A4)
	moveq	#0,D0
	tst.b	-5(A6)
	bne.b	One
	move.l	A0,lbL009792
	move.w	2(A0),D0
	subq.l	#8,D0
	lsr.l	#5,D0
	bra.b	PutSub
One
	move.l	A0,lbB022DDE
	move.l	A0,A1
	add.w	(A1),A1
Next
	tst.w	(A1)+
	bne.b	LastSub
	move.w	(A1)+,D1
	beq.b	LastSub
	btst	#0,D1
	bne.b	LastSub
	addq.l	#1,D0
	bra.b	Next
LastSub
	lsr.l	#2,D0
PutSub
	move.l	D0,SubSongs(A4)

	lea	0(A0,D2.L),A1
	cmp.w	#1,(A1)
	bne.b	Wrong

FindFirst
	move.l	A1,A2
	subq.l	#6,A1
	subq.l	#8,A1
	cmp.w	#1,(A1)
	beq.b	FindFirst
	cmp.w	#8,-2(A2)
	beq.b	InfoOK
	tst.w	-2(A2)
	beq.b	InfoOK
	lea	14(A2),A2
InfoOK
	move.l	A2,(A6)+			; SampleInfoPtr
	moveq	#0,D0
CheckInfo
	cmp.w	#1,(A2)
	bne.b	Last
	addq.l	#1,D0
	lea	14(A2),A2
	bra.b	CheckInfo
Last
	move.l	D0,Samples(A4)

	move.l	A5,(A6)				; EagleBase

	cmp.w	#18,D0
	bne.b	NoFix
	cmp.w	#5,SubSongs+2(A4)
	bne.b	NoFix
	cmp.l	#$74,56(A0)
	bne.b	NoFix
	moveq	#1,D0
	lea	124(A0),A1
	clr.l	(A1)+
	move.l	D0,(A1)
	lea	188(A0),A1
	clr.l	(A1)+
	move.l	D0,(A1)
	lea	284(A0),A1
	clr.l	(A1)+
	move.l	D0,(A1)
NoFix
	movea.l	dtg_AudioAlloc(A5),A0
	jmp	(A0)
Wrong
	moveq	#EPR_UnknownFormat,D0
	rts

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
	lea	SongEnd(PC),A3
	move.l	#$FEFEFEFE,(A3)+
	clr.l	(A3)				; clearing CurrentPos
	lea	SubSongPtr+2(PC),A1
	lea	CurrentFormat(PC),A4
	tst.b	(A4)
	bne.b	Right
	lea	SubSongPtr_2+2(PC),A1
Right
	move.w	dtg_SndNum(A5),D2
	move.w	D2,(A1)
	subq.w	#1,D2
	move.l	ModulePtr(PC),A2
	move.w	(A2),D0
	lea	0(A2,D0.W),A0
	tst.b	(A4)
	bne.b	FindMaxLength
	addq.l	#4,A0
FindMaxLength
	moveq	#3,D3
	moveq	#0,D0
	move.w	#$F090,D4
NextLength
	addq.w	#8,D4
	addq.w	#8,D4
	move.l	(A0),D5
	lea	0(A2,D5.L),A1
	moveq	#-1,D1
FindZero
	addq.l	#1,D1
	tst.l	(A1)+
	bne.b	FindZero
	cmp.l	D1,D0
	bge.b	MaxLength
	move.l	D1,D0
	move.w	D4,6(A3)
MaxLength
	addq.l	#4,A0
	dbf	D3,NextLength
	tst.b	(A4)
	bne.b	Osemka
	addq.l	#8,A0
	addq.l	#8,A0
Osemka
	dbf	D2,FindMaxLength
	lea	InfoBuffer(PC),A3
	move.l	D0,Length(A3)

	tst.b	(A4)
	bne.w	Init
	bra.w	Init_2

***************************************************************************
***************************** DTP_EndSound ********************************
***************************************************************************

EndSound
	lea	CurrentFormat(PC),A0
	tst.b	(A0)
	bne.w	End
	bra.w	End_2

***************************************************************************
*********************** Dave Lowe New (1st format) player *****************
***************************************************************************

; Player from game Flink (c) 1993 by Psygnosis

;lbL022D98	dc.l	0
;lbL022D9C	dc.l	0
SubSongPtr
lbL022DA0	dc.l	1
lbW022DA4	dc.w	0
lbW022DA6	dc.w	0
lbW022DA8	dc.w	0
lbL022DAA	dc.l	0
lbL022DAE	dc.l	0
lbL022DB2	dc.l	0
lbL022DB6	dc.l	0
lbL022DBA	dc.l	0
lbL022DBE	dc.l	0
lbL022DC2	dc.l	0
lbL022DC6	dc.l	0
lbW022DCA	dc.w	0
lbW022DCC	dc.w	0
lbW022DCE	dc.w	0
lbW022DD0	dc.w	0
	dc.w	0
lbW022DD4	dc.w	0
lbW022DD6	dc.w	0
lbW022DD8	dc.w	0
	dc.w	0
lbW022DDC	dc.w	0
lbB022DDE	dc.l	0

;lbC022DE0	MOVE.L	A0,lbB022DDE
;	RTS

;	MOVEM.L	D5/A2,-(SP)
;	TST.L	lbL022DC6
;	BNE.L	lbC022E28
;	MOVE.W	#8,D5
;	LEA	$DFF0D0,A2
;	JSR	lbC0239A6
;	MOVE.L	lbL022D98,lbL022DB6
;	MOVE.L	lbL022D98,lbL022DC6
;	MOVE.L	#0,lbL022D98
;	BRA.L	lbC022ED8

;lbC022E28	TST.L	lbL022DC2
;	BNE.L	lbC022E64
;lbC022E32	MOVE.W	#4,D5
;	LEA	$DFF0C0,A2
;	JSR	lbC023986
;	MOVE.L	lbL022D98,lbL022DB2
;	MOVE.L	lbL022D98,lbL022DC2
;	MOVE.L	#0,lbL022D98
;	BRA.L	lbC022ED8

;lbC022E64	TST.L	lbL022DBE
;	BNE.L	lbC022EA0
;	MOVE.W	#2,D5
;	LEA	$DFF0B0,A2
;	JSR	lbC023966
;	MOVE.L	lbL022D98,lbL022DAE
;	MOVE.L	lbL022D98,lbL022DBE
;	MOVE.L	#0,lbL022D98
;	BRA.L	lbC022ED8

;lbC022EA0	TST.L	lbL022DBA
;	BNE.L	lbC022E32
;	MOVE.W	#1,D5
;	LEA	$DFF0A0,A2
;	JSR	lbC023946
;	MOVE.L	lbL022D98,lbL022DAA
;	MOVE.L	lbL022D98,lbL022DBA
;	MOVE.L	#0,lbL022D98
;lbC022ED8	MOVEM.L	(SP)+,D5/A2
;	RTS

;	MOVEM.L	D5/A2,-(SP)
;	MOVE.L	lbL022D9C,D5
;	CMP.L	lbL022DBA,D5
;	BNE.L	lbC022F06
;	MOVE.W	#1,D5
;	LEA	$DFF0A0,A2
;	JSR	lbC023946
;	BRA.L	lbC022F5C

;lbC022F06	CMP.L	lbL022DBE,D5
;	BNE.L	lbC022F24
;	MOVE.W	#2,D5
;	LEA	$DFF0B0,A2
;	JSR	lbC023966
;	BRA.L	lbC022F5C

;lbC022F24	CMP.L	lbL022DC2,D5
;	BNE.L	lbC022F42
;	MOVE.W	#4,D5
;	LEA	$DFF0C0,A2
;	JSR	lbC023986
;	BRA.L	lbC022F5C

;lbC022F42	CMP.L	lbL022DC6,D5
;	BNE.L	lbC022F5C
;	MOVE.W	#8,D5
;	LEA	$DFF0B0,A2
;	JSR	lbC0239A6
;lbC022F5C	CLR.L	lbL022D9C
;	MOVEM.L	(SP)+,D5/A2
;	RTS

End
lbC022F68
;	SF	lbB022AAE
	MOVE.W	#15,$DFF096
;	MOVE.L	lbL023070(pc),$DFF0A0
;	MOVE.L	lbL023070(pc),$DFF0B0
;	MOVE.L	lbL023070(pc),$DFF0C0
;	MOVE.L	lbL023070(pc),$DFF0D0

	move.l	#Empty,D0
	move.l	D0,$DFF0A0
	move.l	D0,$DFF0B0
	move.l	D0,$DFF0C0
	move.l	D0,$DFF0D0

	MOVE.W	#$10,$DFF0A4
	MOVE.W	#$10,$DFF0B4
	MOVE.W	#$10,$DFF0C4
	MOVE.W	#$10,$DFF0D4
	MOVE.W	#0,$DFF0A8
	MOVE.W	#0,$DFF0B8
	MOVE.W	#0,$DFF0C8
	MOVE.W	#0,$DFF0D8
	MOVE.W	#1,$DFF0A6
	MOVE.W	#1,$DFF0B6
	MOVE.W	#1,$DFF0C6
	MOVE.W	#1,$DFF0D6
	MOVE.L	#0,lbL022DAA
	MOVE.L	#0,lbL022DAE
	MOVE.L	#0,lbL022DB2
	MOVE.L	#0,lbL022DB6
	MOVE.W	#0,lbW022DCA
	MOVE.W	#0,lbW022DCC
	MOVE.W	#0,lbW022DCE
	MOVE.W	#0,lbW022DD0
	MOVE.L	#0,lbL022DBA
	MOVE.L	#0,lbL022DBE
	MOVE.L	#0,lbL022DC2
	MOVE.L	#0,lbL022DC6
	RTS

;lbL023070	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0

Init
lbC023098	MOVE.W	#1,lbW022DD6
	MOVEM.L	D0/D1/A0/A1,-(SP)
	MOVE.W	lbW022DA4(pc),lbW022DD4
	MOVE.W	#1,lbW022DA4
	JSR	lbC022F68
	CLR.L	D0
	MOVE.W	#$CC,D0
	LEA	lbL0239F2(pc),A0
lbC0230C8	CLR.W	(A0)+
	DBRA	D0,lbC0230C8
	TST.L	lbL022DA0
	BEQ.L	lbC02318A
	MOVE.L	lbL022DA0(pc),D1
	ADD.L	D1,D1
	ADD.L	D1,D1
	ADD.L	D1,D1
	ADD.L	D1,D1
	MOVEA.L	lbB022DDE(pc),A1
	MOVE.W	(A1),D0
	LEA	0(A1,D0.W),A1
	SUBA.L	#$10,A1
	ADDA.L	D1,A1
	MOVEA.L	lbB022DDE(pc),A2
	MOVE.L	(A1)+,D0
	ADDA.L	D0,A2
	MOVE.L	A2,lbL023A10
	MOVEA.L	lbB022DDE(pc),A2
	MOVE.L	(A1)+,D0
	ADDA.L	D0,A2
	MOVE.L	A2,lbL023A54
	MOVEA.L	lbB022DDE(pc),A2
	MOVE.L	(A1)+,D0
	ADDA.L	D0,A2
	MOVE.L	A2,lbL023A98
	MOVEA.L	lbB022DDE(pc),A2
	MOVE.L	(A1),D0
	ADDA.L	D0,A2
	MOVE.L	A2,lbL023ADC
	MOVE.L	#lbW0231E8,lbL023A08
	MOVE.L	#lbW0231E8,lbL023A4C
	MOVE.L	#lbW0231E8,lbL023A90
	MOVE.L	#lbW0231E8,lbL023AD4
	MOVE.L	#lbL0231E0,lbL023A0C
	MOVE.L	#lbL0231E0,lbL023A50
	MOVE.L	#lbL0231E0,lbL023A94
	MOVE.L	#lbL0231E0,lbL023AD8
lbC02318A	MOVE.W	#1,lbL0239F2
	MOVE.W	#2,lbL023A36
	MOVE.W	#3,lbL023A7A
	MOVE.W	#4,lbL023ABE
	MOVE.W	#6,lbW023BCE
	MOVE.W	#5,lbW023B8A
	MOVE.W	#7,lbW023B46
	MOVE.W	#8,lbW023B02
	MOVE.W	lbW022DD4(pc),lbW022DA4
	CLR.W	lbW022DD6
	MOVEM.L	(SP)+,D0/D1/A0/A1
	RTS

lbL0231E0	dc.l	0
	dc.l	1
lbW0231E8	dc.w	8

Play
lbC0231EA	TST.W	lbW022DD6
	BEQ.L	lbC0231F6
	RTS

lbC0231F6	MOVEM.L	D0-D6/A0-A6,-(SP)
	TST.W	lbW022DA6
	BNE.L	lbC023246
	TST.L	lbL022DAA
	BNE.L	lbC02322C
	TST.L	lbL022DBA
	BEQ.L	lbC023246
	BRA.L	lbC023232

lbC02321C	JSR	lbC02325A
	JSR	lbC0232AE
	BRA.L	lbC0232F6

lbC02322C	JSR	lbC023272
lbC023232	TST.W	lbW022DA4
	BEQ.L	lbC02321C
	JSR	lbC0232AE
	BRA.L	lbC0232F6

lbC023246	TST.W	lbW022DA4
	BNE.L	lbC0232F6
	JSR	lbC0232D2
	BRA.L	lbC0232F6

lbC02325A	LEA	lbL0239F2(pc),A0
	LEA	lbL023C24(pc),A2
	MOVE.W	#0,D5
	JSR	lbC0235EC
	RTS

lbC023272	MOVEA.L	lbB022DDE(pc),A1
	MOVE.W	2(A1),D0
	ADDA.W	D0,A1
	SUBA.L	#4,A1
	MOVE.L	lbL022DAA(pc),D0
	ADD.W	D0,D0
	ADD.W	D0,D0
	ADDA.L	D0,A1
	MOVE.L	(A1),D0
	MOVEA.L	lbB022DDE(pc),A1
	ADDA.L	D0,A1
	MOVE.L	A1,lbL023B18
	CLR.L	lbL022DAA
	CLR.W	lbL023B04
	RTS

lbC0232AE	LEA	lbW023B02(pc),A0
	LEA	$DFF0A0,A2
	MOVE.W	#1,D5
	MOVE.W	#$8001,D1
	MOVE.W	#1,lbW022DDC
	JSR	lbC0235EC
	RTS

lbC0232D2	LEA	lbL0239F2(pc),A0
	LEA	$DFF0A0,A2
	MOVE.W	#1,D5
	MOVE.W	#$8001,D1
	MOVE.W	#0,lbW022DDC
	JSR	lbC0235EC
	RTS

lbC0232F6	TST.W	lbW022DA6
	BNE.L	lbC023342
	TST.L	lbL022DAE
	BNE.L	lbC023328
	TST.L	lbL022DBE
	BEQ.L	lbC023342
	BRA.L	lbC02332E

lbC023318	JSR	lbC023356
	JSR	lbC0233AA
	BRA.L	lbC0233F2

lbC023328	JSR	lbC02336E
lbC02332E	TST.W	lbW022DA4
	BEQ.L	lbC023318
	JSR	lbC0233AA
	BRA.L	lbC0233F2

lbC023342	TST.W	lbW022DA4
	BNE.L	lbC0233F2
	JSR	lbC0233CE
	BRA.L	lbC0233F2

lbC023356	LEA	lbL023A36(pc),A0
	LEA	lbL023C24(pc),A2
	MOVE.W	#0,D5
	JSR	lbC0235EC
	RTS

lbC02336E	MOVEA.L	lbB022DDE(pc),A1
	MOVE.W	2(A1),D0
	ADDA.W	D0,A1
	SUBA.L	#4,A1
	MOVE.L	lbL022DAE(pc),D0
	ADD.W	D0,D0
	ADD.W	D0,D0
	ADDA.L	D0,A1
	MOVE.L	(A1),D0
	MOVEA.L	lbB022DDE(pc),A1
	ADDA.L	D0,A1
	MOVE.L	A1,lbL023B5C
	CLR.L	lbL022DAE
	CLR.W	lbL023B48
	RTS

lbC0233AA	LEA	lbW023B46(pc),A0
	LEA	$DFF0B0,A2
	MOVE.W	#2,D5
	MOVE.W	#$8002,D1
	MOVE.W	#1,lbW022DDC
	JSR	lbC0235EC
	RTS

lbC0233CE	LEA	lbL023A36(pc),A0
	LEA	$DFF0B0,A2
	MOVE.W	#2,D5
	MOVE.W	#$8002,D1
	MOVE.W	#0,lbW022DDC
	JSR	lbC0235EC
	RTS

lbC0233F2	TST.W	lbW022DA6
	BNE.L	lbC02343E
	TST.L	lbL022DB2
	BNE.L	lbC023424
	TST.L	lbL022DC2
	BEQ.L	lbC02343E
	BRA.L	lbC02342A

lbC023414	JSR	lbC023452
	JSR	lbC0234A6
	BRA.L	lbC0234EE

lbC023424	JSR	lbC02346A
lbC02342A	TST.W	lbW022DA4
	BEQ.L	lbC023414
	JSR	lbC0234A6
	BRA.L	lbC0234EE

lbC02343E	TST.W	lbW022DA4
	BNE.L	lbC0234EE
	JSR	lbC0234CA
	BRA.L	lbC0234EE

lbC023452	LEA	lbL023A7A(pc),A0
	LEA	lbL023C24(pc),A2
	MOVE.W	#0,D5
	JSR	lbC0235EC
	RTS

lbC02346A	MOVEA.L	lbB022DDE(pc),A1
	MOVE.W	2(A1),D0
	ADDA.W	D0,A1
	SUBA.L	#4,A1
	MOVE.L	lbL022DB2(pc),D0
	ADD.W	D0,D0
	ADD.W	D0,D0
	ADDA.L	D0,A1
	MOVE.L	(A1),D0
	MOVEA.L	lbB022DDE(pc),A1
	ADDA.L	D0,A1
	MOVE.L	A1,lbL023BA0
	CLR.L	lbL022DB2
	CLR.W	lbL023B8C
	RTS

lbC0234A6	LEA	lbW023B8A(pc),A0
	LEA	$DFF0C0,A2
	MOVE.W	#4,D5
	MOVE.W	#$8004,D1
	MOVE.W	#1,lbW022DDC
	JSR	lbC0235EC
	RTS

lbC0234CA	LEA	lbL023A7A(pc),A0
	LEA	$DFF0C0,A2
	MOVE.W	#4,D5
	MOVE.W	#$8004,D1
	MOVE.W	#0,lbW022DDC
	JSR	lbC0235EC
	RTS

lbC0234EE	TST.W	lbW022DA6
	BNE.L	lbC02353A
	TST.L	lbL022DB6
	BNE.L	lbC023520
	TST.L	lbL022DC6
	BEQ.L	lbC02353A
	BRA.L	lbC023526

lbC023510	JSR	lbC023550
	JSR	lbC0235A4
	BRA.L	lbC02354A

lbC023520	JSR	lbC023568
lbC023526	TST.W	lbW022DA4
	BEQ.L	lbC023510
	JSR	lbC0235A4
	BRA.L	lbC02354A

lbC02353A	TST.W	lbW022DA4
	BNE.L	lbC02354A
	JSR	lbC0235C8
lbC02354A	MOVEM.L	(SP)+,D0-D6/A0-A6
	RTS

lbC023550	LEA	lbL023ABE(pc),A0
	LEA	lbL023C24(pc),A2
	MOVE.W	#0,D5
	JSR	lbC0235EC
	RTS

lbC023568	MOVEA.L	lbB022DDE(pc),A1
	MOVE.W	2(A1),D0
	ADDA.W	D0,A1
	SUBA.L	#4,A1
	MOVE.L	lbL022DB6(pc),D0
	ADD.W	D0,D0
	ADD.W	D0,D0
	ADDA.L	D0,A1
	MOVE.L	(A1),D0
	MOVEA.L	lbB022DDE(pc),A1
	ADDA.L	D0,A1
	MOVE.L	A1,lbL023BE4
	CLR.L	lbL022DB6
	CLR.W	lbL023BD0
	RTS

lbC0235A4	LEA	lbW023BCE(pc),A0
	LEA	$DFF0D0,A2
	MOVE.W	#8,D5
	MOVE.W	#$8208,D1
	MOVE.W	#1,lbW022DDC
	JSR	lbC0235EC
	RTS

lbC0235C8	LEA	lbL023ABE(pc),A0
	LEA	$DFF0D0,A2
	MOVE.W	#8,D5
	MOVE.W	#$8208,D1
	MOVE.W	#0,lbW022DDC
	JSR	lbC0235EC
	RTS

lbC0235EC	TST.W	(A0)
	BNE.L	lbC0235F4
	RTS

lbC0235F4	TST.W	2(A0)
	BEQ.L	lbC023768
	CMPI.W	#1,2(A0)
	BEQ.L	lbC0237E0
	CMPI.W	#3,4(A0)
	BEQ.L	lbC023750
	SUBQ.W	#1,2(A0)
lbC023614	CLR.W	lbW022DD8
	MOVE.W	6(A0),D2
	TST.W	8(A0)
	BEQ.L	lbC023668
	TST.W	14(A0)
	BEQ.L	lbC023636
	SUBQ.W	#1,14(A0)
	BRA.L	lbC023668

lbC023636	ADDQ.W	#1,lbW022DD8
	MOVE.W	10(A0),D3
	MOVE.W	12(A0),D4
	CMPI.W	#1,8(A0)
	BEQ.L	lbC02365A
	SUB.W	D3,D2
	CMP.W	D2,D4
	BCS.L	lbC023668
	BRA.L	lbC023662

lbC02365A	ADD.W	D3,D2
	CMP.W	D2,D4
	BCC.L	lbC023668
lbC023662	MOVE.W	D4,D2
	CLR.W	8(A0)
lbC023668	TST.W	$10(A0)
	BEQ.L	lbC0236CE
	TST.W	$3A(A0)
	BEQ.L	lbC023680
	SUBQ.W	#1,$3A(A0)
	BRA.L	lbC0236CE

lbC023680	TST.W	$32(A0)
	BEQ.L	lbC023690
	SUBQ.W	#1,$32(A0)
	BRA.L	lbC0236CE

lbC023690	MOVE.W	$34(A0),$32(A0)
	ADDQ.W	#1,lbW022DD8
	CMPI.W	#3,$10(A0)
	BCC.L	lbC0236B4
	MOVE.W	$38(A0),D3
	SUB.W	D3,D2
	ADDQ.W	#1,$10(A0)
	BRA.L	lbC0236CE

lbC0236B4	MOVE.W	$36(A0),D3
	ADD.W	D3,D2
	ADDQ.W	#1,$10(A0)
	CMPI.W	#5,$10(A0)
	BNE.L	lbC0236CE
	MOVE.W	#1,$10(A0)
lbC0236CE	TST.W	lbW022DD8
	BEQ.L	lbC0236E0
	MOVE.W	D2,6(A0)
	MOVE.W	D2,6(A2)

	move.l	D0,-(A7)
	move.w	D2,D0
	bsr.w	SetPer
	move.l	(A7)+,D0

lbC0236E0	MOVEA.L	$12(A0),A1
	CMPI.W	#$FF,(A1)
	BEQ.L	lbC02372E
lbC0236EC	CLR.L	D0
	MOVE.W	(A1)+,D0
	TST.W	lbW022DDC
	BNE.L	lbC023708
	SUB.W	lbW022DA8(pc),D0
	BCC.L	lbC023708
	MOVE.W	#0,D0
lbC023708
;	MOVE.W	D0,8(A2)

	bsr.w	ChangeVolume
	bsr.w	SetVol

	MOVE.L	A1,$12(A0)
	RTS

;	SUB.W	lbW022DA8,D0
;	BCC.L	lbC023720
;	MOVE.W	#0,D0
;lbC023720	MOVE.W	D0,8(A2)
;	MOVE.W	(A1)+,8(A2)
;	MOVE.L	A1,$12(A0)
;	RTS

lbC02372E	SUBQ.L	#2,A1
	BRA.L	lbC0236EC

;	RTS

lbC023736	MOVE.W	#3,4(A0)
	MOVE.L	$26(A0),(A2)
	MOVE.W	$2A(A0),4(A2)

	movem.l	D0/A1,-(A7)
	move.l	$26(A0),A1
	bsr.w	SetAdr
	move.w	$2A(A0),D0
	bsr.w	SetLen
	movem.l	(A7)+,D0/A1

	MOVE.W	D1,$DFF096
	BRA.L	lbC0236E0

lbC023750	MOVE.L	$2C(A0),(A2)
	MOVE.W	$30(A0),4(A2)
	SUBQ.W	#1,2(A0)
	MOVE.W	#1,4(A0)
	BRA.L	lbC023614

lbC023768	MOVE.W	#0,$42(A0)
	MOVEA.L	$16(A0),A1
lbC023772	MOVE.W	(A1)+,D0
	CMPI.W	#$64,D0
	BLS.L	lbC0237F8
	MOVE.W	D0,6(A0)
	MOVE.W	D0,6(A2)

	bsr.w	SetPer

	MOVE.W	(A1)+,2(A0)
	SUBQ.W	#1,2(A0)
	MOVE.L	A1,$16(A0)
	MOVE.L	$22(A0),$12(A0)
	MOVE.W	$3C(A0),$3A(A0)
	TST.W	$10(A0)
	BEQ.L	lbC0237AA
	MOVE.W	#1,$10(A0)
lbC0237AA	CMPI.W	#0,4(A0)
	BEQ.L	lbC0237B8
	BRA.L	lbC023736

lbC0237B8	MOVE.W	D1,$DFF096
	BRA.L	lbC0236E0

lbC0237C2
;	MOVE.W	(A1)+,2(A0)

	move.w	(A1)+,D7
	bpl.b	OKi
	bsr.w	SongEndTest
OKi
	move.w	D7,2(A0)

	SUBQ.W	#1,2(A0)
	MOVE.L	A1,$16(A0)
	MOVE.L	#lbL023C12,$12(A0)
	MOVE.W	#0,8(A2)
	BRA.L	lbC0236E0

lbC0237E0	CMPI.W	#0,4(A0)
	BEQ.L	lbC0237F0
	MOVE.W	D5,$DFF096
lbC0237F0	SUBQ.W	#1,2(A0)
	BRA.L	lbC023614

lbC0237F8	MOVEA.L	#lbL023804,A3

	cmp.w	#60,D0
	bcs.b	.ok
	clr.w	D0
.ok
	MOVEA.L	0(A3,D0.W),A4
	JMP	(A4)

lbL023804	dc.l	lbC023840
	dc.l	lbC02386A
	dc.l	lbC0238C4
	dc.l	lbC0238E6
	dc.l	lbC0238FC
	dc.l	lbC023908
	dc.l	lbC02391E
	dc.l	lbC023926
	dc.l	lbC0237C2
	dc.l	lbC02392E
	dc.l	lbC02392E
	dc.l	lbC023852
	dc.l	lbC02385E
	dc.l	lbC0239C6
	dc.l	lbC023844

lbC023840	NOP
	RTS

lbC023844	MOVE.L	(A1),D0
	MOVEA.L	lbB022DDE(pc),A1
	ADDA.L	D0,A1
	BRA.L	lbC023772

lbC023852	BCLR	#1,$BFE001
	BRA.L	lbC023772

lbC02385E	BSET	#1,$BFE001
	BRA.L	lbC023772

lbC02386A	MOVE.L	(A1)+,D0
	MOVEA.L	lbB022DDE(pc),A3
	ADDA.L	D0,A3
	CMPI.W	#0,(A3)
	BNE.L	lbC023896
	MOVE.W	(A3)+,4(A0)
	MOVEA.L	lbB022DDE(pc),A6
	MOVE.L	(A3)+,D0
	ADDA.L	D0,A6
	MOVE.L	A6,(A2)
	MOVE.W	(A3),4(A2)

	movem.l	D0/A1,-(A7)
	move.l	A6,A1
	bsr.w	SetAdr
	move.w	(A3),D0
	bsr.w	SetLen
	movem.l	(A7)+,D0/A1

	JMP	lbC023772

lbC023896	MOVE.W	(A3)+,4(A0)
	MOVEA.L	lbB022DDE(pc),A6
	MOVE.L	(A3)+,D0
	ADDA.L	D0,A6
	MOVE.L	A6,$26(A0)
	MOVE.W	(A3)+,$2A(A0)
	MOVEA.L	lbB022DDE(pc),A6
	MOVE.L	(A3)+,D0
	ADDA.L	D0,A6
	MOVE.L	A6,$2C(A0)
	MOVE.W	(A3),$30(A0)
	JMP	lbC023772

lbC0238C4	MOVEA.L	$1A(A0),A1
	CMPI.L	#0,(A1)
	BEQ.L	lbC0239D0

	cmp.l	Hardware(PC),A2
	bne.b	Exit3
	move.l	$1A(A0),D0
	sub.l	$1E(A0),D0
	move.l	D0,CurrentPos
Exit3

	ADDQ.L	#4,$1A(A0)
	MOVE.L	(A1),D0
	MOVEA.L	lbB022DDE(pc),A1
	ADDA.L	D0,A1
	JMP	lbC023772

lbC0238E6	MOVE.L	(A1)+,D0
	MOVEA.L	lbB022DDE(pc),A4
	ADDA.L	D0,A4
	MOVE.L	(A4)+,$3E(A0)
	MOVE.L	A4,$22(A0)
	BRA.L	lbC023772

lbC0238FC	MOVE.L	(A1)+,8(A0)
	MOVE.L	(A1)+,12(A0)
	BRA.L	lbC023772

lbC023908	MOVE.W	#1,$10(A0)
	MOVE.L	(A1)+,$32(A0)
	MOVE.L	(A1)+,$36(A0)
	MOVE.L	(A1)+,$3A(A0)
	BRA.L	lbC023772

lbC02391E	CLR.W	8(A0)
	BRA.L	lbC023772

lbC023926	CLR.W	$10(A0)
	BRA.L	lbC023772

lbC02392E	CMPI.W	#6,(A0)
	BEQ.L	lbC0239A6
	CMPI.W	#5,(A0)
	BEQ.L	lbC023986
	CMPI.W	#7,(A0)
	BEQ.L	lbC023966
lbC023946	MOVE.W	D5,$DFF096
	MOVE.W	#1,$DFF0A6
	MOVE.W	#0,8(A2)
	MOVE.L	#0,lbL022DBA
	RTS

lbC023966	MOVE.W	D5,$DFF096
	MOVE.W	#1,$DFF0B6
	MOVE.W	#0,8(A2)
	MOVE.L	#0,lbL022DBE
	RTS

lbC023986	MOVE.W	D5,$DFF096
	MOVE.W	#1,$DFF0C6
	MOVE.W	#0,8(A2)
	MOVE.L	#0,lbL022DC2
	RTS

lbC0239A6	MOVE.W	D5,$DFF096
	MOVE.W	#1,$DFF0D6
	MOVE.W	#0,8(A2)
	MOVE.L	#0,lbL022DC6
	RTS

lbC0239C6	MOVE.W	#1,$42(A0)
	BRA.L	lbC023772

lbC0239D0	ADDQ.L	#4,A1
	MOVE.L	$1E(A0),$1A(A0)
	MOVEA.L	$1A(A0),A1
	ADDQ.L	#4,$1A(A0)

	bsr.w	SongEndTest

	MOVEA.L	lbB022DDE(pc),A6
	MOVE.L	(A1),D0
	ADDA.L	D0,A6
	MOVEA.L	A6,A1
	JMP	lbC023772

lbL0239F2	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
lbL023A08	dc.l	0
lbL023A0C	dc.l	0
lbL023A10	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
lbL023A36	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
lbL023A4C	dc.l	0
lbL023A50	dc.l	0
lbL023A54	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
lbL023A7A	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
lbL023A90	dc.l	0
lbL023A94	dc.l	0
lbL023A98	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
lbL023ABE	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
lbL023AD4	dc.l	0
lbL023AD8	dc.l	0
lbL023ADC	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
lbW023B02	dc.w	0
lbL023B04	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbL023B18	dc.l	0
	dc.l	0
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
lbW023B46	dc.w	0
lbL023B48	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbL023B5C	dc.l	0
	dc.l	0
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
lbW023B8A	dc.w	0
lbL023B8C	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbL023BA0	dc.l	0
	dc.l	0
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
lbW023BCE	dc.w	0
lbL023BD0	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbL023BE4	dc.l	0
	dc.l	0
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
lbL023C12	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	$FF
lbL023C24	dc.l	0
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
;lbL023E04	dc.l	$80048

***************************************************************************
*********************** Dave Lowe New (2nd format) player *****************
***************************************************************************

; Player from game Super Street Fighter II: TNC (c) 1995 by Freestyle/US Gold

;lbL00974A	dc.l	0
;lbB00974E	dc.b	0
;lbB00974F	dc.b	0
lbL009750	dc.l	0
SubSongPtr_2
lbL009754	dc.l	1
lbW009758	dc.w	0
lbW00975A	dc.w	0
lbW00975C	dc.w	0
lbL00975E	dc.l	0
lbL009762	dc.l	0
lbL009766	dc.l	0
lbL00976A	dc.l	0
lbL00976E	dc.l	0
lbL009772	dc.l	0
lbL009776	dc.l	0
lbL00977A	dc.l	0
lbW00977E	dc.w	0
lbW009780	dc.w	0
lbW009782	dc.w	0
lbW009784	dc.w	0
	dc.w	0
lbW009788	dc.w	0
lbW00978A	dc.w	0
lbW00978C	dc.w	0
	dc.w	0
lbW009790	dc.w	0
;ModulePtr
lbL009792	dc.l	0
lbL009796	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbL0097A6	dc.l	0
lbL0097AA	dc.l	0
lbL0097AE	dc.l	0
lbW0097B2	dc.w	0
lbW0097B4	dc.w	0
lbW0097B6	dc.w	0
lbW0097B8	dc.w	0
	dc.w	0
lbL0097BC	dc.l	0
lbL0097C0	dc.l	0
lbL0097C4	dc.l	0
lbL0097C8	dc.l	0
lbL0097CC	dc.l	0
lbL0097D0	dc.l	0
lbW0097D4	dc.w	0

;lbC0097D6	MOVE.W	#1,lbW00978A
;	MOVE.L	A0,lbL009792
;	CLR.W	lbW00978A
;	RTS

;lbC0097EC	MOVE.W	#1,lbW00978A
;	MOVE.L	A0,lbL009796
;	CLR.W	lbW00978A
;	RTS

;lbC009802	MOVE.W	#1,lbW00978A
;	MOVE.L	A0,lbL0097AA
;	CLR.W	lbW00978A
;	RTS

;lbC009818	MOVE.W	#1,lbW00978A
;	MOVE.L	A0,lbL0097AE
;	CLR.W	lbW00978A
;	RTS

;	MOVE.W	#1,lbW00978A
;	MOVE.L	A0,lbL009792
;	CLR.W	lbW00978A
;	RTS

;lbC009844	MOVE.W	#1,lbW00978A
;	MOVEM.L	D5/A2,-(SP)
;	TST.L	lbL00977A
;	BNE.L	lbC009890
;	MOVE.W	#8,D5
;	LEA	$DFF0D0,A2
;	JSR	lbC00A554
;	MOVE.L	lbL00974A(PC),lbL00976A
;	MOVE.L	lbL00974A(PC),lbL00977A
;	MOVE.W	lbB00974E(PC),lbW0097B8
;	MOVE.L	#0,lbL00974A
;	BRA.L	lbC00994A

;lbC009890	TST.L	lbL009776
;	BNE.L	lbC0098D0
;lbC00989A	MOVE.W	#4,D5
;	LEA	$DFF0C0,A2
;	JSR	lbC00A52C
;	MOVE.L	lbL00974A(PC),lbL009766
;	MOVE.L	lbL00974A(PC),lbL009776
;	MOVE.W	lbB00974E(PC),lbW0097B6
;	MOVE.L	#0,lbL00974A
;	BRA.L	lbC00994A

;lbC0098D0	TST.L	lbL009772
;	BNE.L	lbC009910
;	MOVE.W	#2,D5
;	LEA	$DFF0B0,A2
;	JSR	lbC00A504
;	MOVE.L	lbL00974A(PC),lbL009762
;	MOVE.L	lbL00974A(PC),lbL009772
;	MOVE.W	lbB00974E(PC),lbW0097B4
;	MOVE.L	#0,lbL00974A
;	BRA.L	lbC00994A

;lbC009910	TST.L	lbL00976E
;	BNE.S	lbC00989A
;	MOVE.W	#1,D5
;	LEA	$DFF0A0,A2
;	JSR	lbC00A4DC
;	MOVE.L	lbL00974A(PC),lbL00975E
;	MOVE.L	lbL00974A(PC),lbL00976E
;	MOVE.W	lbB00974E(PC),lbW0097B2
;	MOVE.L	#0,lbL00974A
;lbC00994A	MOVEM.L	(SP)+,D5/A2
;	CLR.W	lbW00978A
;	RTS

;	MOVEM.L	D5/A2,-(SP)
;	MOVE.L	lbL009750(PC),D5
;	CMP.L	lbL00976E(PC),D5
;	BNE.L	lbC00997A
;	MOVE.W	#1,D5
;	LEA	$DFF0A0,A2
;	JSR	lbC00A4DC
;	BRA.L	lbC0099CA

;lbC00997A	CMP.L	lbL009772(PC),D5
;	BNE.L	lbC009996
;	MOVE.W	#2,D5
;	LEA	$DFF0B0,A2
;	JSR	lbC00A504
;	BRA.L	lbC0099CA

;lbC009996	CMP.L	lbL009776(PC),D5
;	BNE.L	lbC0099B2
;	MOVE.W	#4,D5
;	LEA	$DFF0C0,A2
;	JSR	lbC00A52C
;	BRA.L	lbC0099CA

;lbC0099B2	CMP.L	lbL00977A(PC),D5
;	BNE.L	lbC0099CA
;	MOVE.W	#8,D5
;	LEA	$DFF0B0,A2
;	JSR	lbC00A554
;lbC0099CA	CLR.L	lbL009750
;	MOVEM.L	(SP)+,D5/A2
;	RTS

End_2
lbC0099D6	MOVE.W	#15,$DFF096
;	MOVE.L	lbL009AD8(pc),$DFF0A0
;	MOVE.L	lbL009AD8(pc),$DFF0B0
;	MOVE.L	lbL009AD8(pc),$DFF0C0
;	MOVE.L	lbL009AD8(pc),$DFF0D0

	move.l	#Empty,D0
	move.l	D0,$DFF0A0
	move.l	D0,$DFF0B0
	move.l	D0,$DFF0C0
	move.l	D0,$DFF0D0

	MOVE.W	#$10,$DFF0A4
	MOVE.W	#$10,$DFF0B4
	MOVE.W	#$10,$DFF0C4
	MOVE.W	#$10,$DFF0D4
	MOVE.W	#0,$DFF0A8
	MOVE.W	#0,$DFF0B8
	MOVE.W	#0,$DFF0C8
	MOVE.W	#0,$DFF0D8
	MOVE.W	#1,$DFF0A6
	MOVE.W	#1,$DFF0B6
	MOVE.W	#1,$DFF0C6
	MOVE.W	#1,$DFF0D6
	MOVE.L	#0,lbL00975E
	MOVE.L	#0,lbL009762
	MOVE.L	#0,lbL009766
	MOVE.L	#0,lbL00976A
	MOVE.W	#0,lbW00977E
	MOVE.W	#0,lbW009780
	MOVE.W	#0,lbW009782
	MOVE.W	#0,lbW009784
	MOVE.L	#0,lbL00976E
	MOVE.L	#0,lbL009772
	MOVE.L	#0,lbL009776
	MOVE.L	#0,lbL00977A
	RTS

;lbL009AD8	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0

;	BCLR	#1,$BFE001
;	RTS

;	BSET	#1,$BFE001
;	RTS

;lbC009B14	CLR.L	lbL009754
;	MOVE.W	#1,lbW009758
;	JSR	lbC009B30
;	CLR.W	lbW009758
;	RTS

Init_2
lbC009B30	MOVE.W	#1,lbW00978A
	MOVEM.L	D0/D1/A0-A2,-(SP)
	MOVE.W	lbW009758(PC),lbW009788
	MOVE.W	#1,lbW009758
	JSR	lbC0099D6(PC)
	CLR.L	D0
	MOVE.W	#$CC,D0
	LEA	lbL00A5A4(pc),A0
lbC009B5C	CLR.W	(A0)+
	DBRA	D0,lbC009B5C
	TST.L	lbL009754
	BEQ.L	lbC009C1E
	MOVE.L	lbL009754(PC),D1
	ADD.L	D1,D1
	ADD.L	D1,D1
	ADD.L	D1,D1
	ADD.L	D1,D1
	ADD.L	D1,D1
	MOVEA.L	lbL009792(PC),A1
	MOVE.W	(A1),D0
	LEA	0(A1,D0.W),A1
	SUBA.L	#$20,A1
	ADDA.L	D1,A1
	MOVEA.L	lbL009792(PC),A2
	MOVE.L	(A1)+,lbL0097D0
	MOVEA.L	lbL009792(PC),A2
	MOVE.L	(A1)+,D0
	ADDA.L	D0,A2
	MOVE.L	A2,lbL00A5C2
	MOVEA.L	lbL009792(PC),A2
	MOVE.L	(A1)+,D0
	ADDA.L	D0,A2
	MOVE.L	A2,lbL00A606
	MOVEA.L	lbL009792(PC),A2
	MOVE.L	(A1)+,D0
	ADDA.L	D0,A2
	MOVE.L	A2,lbL00A64A
	MOVEA.L	lbL009792(PC),A2
	MOVE.L	(A1),D0
	ADDA.L	D0,A2
	MOVE.L	A2,lbL00A68E
	MOVE.L	#lbW009C7A,lbL00A5BA
	MOVE.L	#lbW009C7A,lbL00A5FE
	MOVE.L	#lbW009C7A,lbL00A642
	MOVE.L	#lbW009C7A,lbL00A686
	MOVE.L	#lbL009C72,lbL00A5BE
	MOVE.L	#lbL009C72,lbL00A602
	MOVE.L	#lbL009C72,lbL00A646
	MOVE.L	#lbL009C72,lbL00A68A
lbC009C1E	MOVE.W	#1,lbL00A5A4
	MOVE.W	#2,lbL00A5E8
	MOVE.W	#3,lbL00A62C
	MOVE.W	#4,lbL00A670
	MOVE.W	#6,lbW00A780
	MOVE.W	#5,lbW00A73C
	MOVE.W	#7,lbW00A6F8
	MOVE.W	#8,lbW00A6B4
	MOVE.W	lbW009788(PC),lbW009758
	CLR.W	lbW00978A
	MOVEM.L	(SP)+,D0/D1/A0-A2
	RTS

lbL009C72	dc.l	0
	dc.l	1
lbW009C7A	dc.w	8

Play_2
lbC009C7C	TST.W	lbW00978A
	BEQ.L	lbC009C88
	RTS

lbC009C88	MOVEQ	#1,D0
	ADD.L	lbL0097CC(PC),D0
	MOVE.L	D0,lbL0097CC
	CMP.L	lbL0097D0(PC),D0
	BLS.L	lbC009CAA
	MOVE.W	#1,lbW0097D4
	CLR.L	lbL0097CC
lbC009CAA	MOVEM.L	D0-D6/A0-A6,-(SP)
	TST.W	lbW00975A
	BNE.L	lbC009CF8
	TST.L	lbL00975E
	BNE.L	lbC009CE0
	TST.L	lbL00976E
	BEQ.L	lbC009CF8
	BRA.L	lbC009CE6

lbC009CD0	JSR	lbC009D0C
	JSR	lbC009D76
	BRA.L	lbC009DDA

lbC009CE0	JSR	lbC009D38
lbC009CE6	TST.W	lbW009758
	BEQ.S	lbC009CD0
	JSR	lbC009D76
	BRA.L	lbC009DDA

lbC009CF8	TST.W	lbW009758
	BNE.L	lbC009DDA
	JSR	lbC009DA2
	BRA.L	lbC009DDA

lbC009D0C	TST.W	lbW0097D4
	BEQ.L	lbC009D18
	RTS

lbC009D18	MOVE.L	lbL009792(PC),lbL0097A6
	LEA	lbL00A5A4(pc),A0
	LEA	lbL00A7D6(pc),A2
	MOVE.W	#0,D5
	JSR	lbC00A186
	RTS

lbC009D38	MOVE.W	lbW0097B2(PC),D0
	JSR	lbC00A166
	MOVE.L	A1,lbL0097BC
	MOVE.L	A1,-(SP)
	MOVE.W	2(A1),D0
	ADDA.W	D0,A1
	SUBQ.L	#4,A1
	MOVE.L	lbL00975E(PC),D0
	ADD.W	D0,D0
	ADD.W	D0,D0
	ADDA.L	D0,A1
	MOVE.L	(A1),D0
	MOVEA.L	(SP)+,A1
	ADDA.L	D0,A1
	MOVE.L	A1,lbL00A6CA
	CLR.L	lbL00975E
	CLR.W	lbL00A6B6
	RTS

lbC009D76	MOVE.L	lbL0097BC(PC),lbL0097A6
	LEA	lbW00A6B4(pc),A0
	LEA	$DFF0A0,A2
	MOVE.W	#1,D5
	MOVE.W	#$8001,D1
	MOVE.W	#1,lbW009790
	JSR	lbC00A186
	RTS

lbC009DA2	TST.W	lbW0097D4
	BEQ.L	lbC009DAE
	RTS

lbC009DAE	MOVE.L	lbL009792(PC),lbL0097A6
	LEA	lbL00A5A4(pc),A0
	LEA	$DFF0A0,A2
	MOVE.W	#1,D5
	MOVE.W	#$8001,D1
	MOVE.W	#0,lbW009790
	JSR	lbC00A186
	RTS

lbC009DDA	TST.W	lbW00975A
	BNE.L	lbC009E24
	TST.L	lbL009762
	BNE.L	lbC009E0C
	TST.L	lbL009772
	BEQ.L	lbC009E24
	BRA.L	lbC009E12

lbC009DFC	JSR	lbC009E38
	JSR	lbC009EA2
	BRA.L	lbC009F06

lbC009E0C	JSR	lbC009E64
lbC009E12	TST.W	lbW009758
	BEQ.S	lbC009DFC
	JSR	lbC009EA2
	BRA.L	lbC009F06

lbC009E24	TST.W	lbW009758
	BNE.L	lbC009F06
	JSR	lbC009ECE
	BRA.L	lbC009F06

lbC009E38	TST.W	lbW0097D4
	BEQ.L	lbC009E44
	RTS

lbC009E44	MOVE.L	lbL009792(PC),lbL0097A6
	LEA	lbL00A5E8(pc),A0
	LEA	lbL00A7D6(pc),A2
	MOVE.W	#0,D5
	JSR	lbC00A186
	RTS

lbC009E64	MOVE.W	lbW0097B4(PC),D0
	JSR	lbC00A166
	MOVE.L	A1,lbL0097C0
	MOVE.L	A1,-(SP)
	MOVE.W	2(A1),D0
	ADDA.W	D0,A1
	SUBQ.L	#4,A1
	MOVE.L	lbL009762(PC),D0
	ADD.W	D0,D0
	ADD.W	D0,D0
	ADDA.L	D0,A1
	MOVE.L	(A1),D0
	MOVEA.L	(SP)+,A1
	ADDA.L	D0,A1
	MOVE.L	A1,lbL00A70E
	CLR.L	lbL009762
	CLR.W	lbL00A6FA
	RTS

lbC009EA2	MOVE.L	lbL0097C0(PC),lbL0097A6
	LEA	lbW00A6F8(pc),A0
	LEA	$DFF0B0,A2
	MOVE.W	#2,D5
	MOVE.W	#$8002,D1
	MOVE.W	#1,lbW009790
	JSR	lbC00A186
	RTS

lbC009ECE	TST.W	lbW0097D4
	BEQ.L	lbC009EDA
	RTS

lbC009EDA	MOVE.L	lbL009792(PC),lbL0097A6
	LEA	lbL00A5E8(pc),A0
	LEA	$DFF0B0,A2
	MOVE.W	#2,D5
	MOVE.W	#$8002,D1
	MOVE.W	#0,lbW009790
	JSR	lbC00A186
	RTS

lbC009F06	TST.W	lbW00975A
	BNE.L	lbC009F50
	TST.L	lbL009766
	BNE.L	lbC009F38
	TST.L	lbL009776
	BEQ.L	lbC009F50
	BRA.L	lbC009F3E

lbC009F28	JSR	lbC009F64
	JSR	lbC009FCE
	BRA.L	lbC00A032

lbC009F38	JSR	lbC009F90
lbC009F3E	TST.W	lbW009758
	BEQ.S	lbC009F28
	JSR	lbC009FCE
	BRA.L	lbC00A032

lbC009F50	TST.W	lbW009758
	BNE.L	lbC00A032
	JSR	lbC009FFA
	BRA.L	lbC00A032

lbC009F64	TST.W	lbW0097D4
	BEQ.L	lbC009F70
	RTS

lbC009F70	MOVE.L	lbL009792(PC),lbL0097A6
	LEA	lbL00A62C(pc),A0
	LEA	lbL00A7D6(pc),A2
	MOVE.W	#0,D5
	JSR	lbC00A186
	RTS

lbC009F90	MOVE.W	lbW0097B6(PC),D0
	JSR	lbC00A166
	MOVE.L	A1,lbL0097C4
	MOVE.L	A1,-(SP)
	MOVE.W	2(A1),D0
	ADDA.W	D0,A1
	SUBQ.L	#4,A1
	MOVE.L	lbL009766(PC),D0
	ADD.W	D0,D0
	ADD.W	D0,D0
	ADDA.L	D0,A1
	MOVE.L	(A1),D0
	MOVEA.L	(SP)+,A1
	ADDA.L	D0,A1
	MOVE.L	A1,lbL00A752
	CLR.L	lbL009766
	CLR.W	lbL00A73E
	RTS

lbC009FCE	MOVE.L	lbL0097C4(PC),lbL0097A6
	LEA	lbW00A73C(pc),A0
	LEA	$DFF0C0,A2
	MOVE.W	#4,D5
	MOVE.W	#$8004,D1
	MOVE.W	#1,lbW009790
	JSR	lbC00A186
	RTS

lbC009FFA	TST.W	lbW0097D4
	BEQ.L	lbC00A006
	RTS

lbC00A006	MOVE.L	lbL009792(PC),lbL0097A6
	LEA	lbL00A62C(pc),A0
	LEA	$DFF0C0,A2
	MOVE.W	#4,D5
	MOVE.W	#$8004,D1
	MOVE.W	#0,lbW009790
	JSR	lbC00A186
	RTS

lbC00A032	TST.W	lbW00975A
	BNE.L	lbC00A07C
	TST.L	lbL00976A
	BNE.L	lbC00A064
	TST.L	lbL00977A
	BEQ.L	lbC00A07C
	BRA.L	lbC00A06A

lbC00A054	JSR	lbC00A098
	JSR	lbC00A102
	BRA.L	lbC00A08C

lbC00A064	JSR	lbC00A0C4
lbC00A06A	TST.W	lbW009758
	BEQ.S	lbC00A054
	JSR	lbC00A102
	BRA.L	lbC00A08C

lbC00A07C	TST.W	lbW009758
	BNE.L	lbC00A08C
	JSR	lbC00A12E
lbC00A08C	CLR.W	lbW0097D4
	MOVEM.L	(SP)+,D0-D6/A0-A6
	RTS

lbC00A098	TST.W	lbW0097D4
	BEQ.L	lbC00A0A4
	RTS

lbC00A0A4	MOVE.L	lbL009792(PC),lbL0097A6
	LEA	lbL00A670(pc),A0
	LEA	lbL00A7D6(pc),A2
	MOVE.W	#0,D5
	JSR	lbC00A186
	RTS

lbC00A0C4	MOVE.W	lbW0097B8(PC),D0
	JSR	lbC00A166
	MOVE.L	A1,lbL0097C8
	MOVE.L	A1,-(SP)
	MOVE.W	2(A1),D0
	ADDA.W	D0,A1
	SUBQ.L	#4,A1
	MOVE.L	lbL00976A(PC),D0
	ADD.W	D0,D0
	ADD.W	D0,D0
	ADDA.L	D0,A1
	MOVE.L	(A1),D0
	MOVEA.L	(SP)+,A1
	ADDA.L	D0,A1
	MOVE.L	A1,lbL00A796
	CLR.L	lbL00976A
	CLR.W	lbL00A782
	RTS

lbC00A102	MOVE.L	lbL0097C8(PC),lbL0097A6
	LEA	lbW00A780(pc),A0
	LEA	$DFF0D0,A2
	MOVE.W	#8,D5
	MOVE.W	#$8208,D1
	MOVE.W	#1,lbW009790
	JSR	lbC00A186
	RTS

lbC00A12E	TST.W	lbW0097D4
	BEQ.L	lbC00A13A
	RTS

lbC00A13A	MOVE.L	lbL009792(PC),lbL0097A6
	LEA	lbL00A670(pc),A0
	LEA	$DFF0D0,A2
	MOVE.W	#8,D5
	MOVE.W	#$8208,D1
	MOVE.W	#0,lbW009790
	JSR	lbC00A186
	RTS

lbC00A166	TST.W	D0
	BEQ.L	lbC00A17A
	CMPI.W	#1,D0
	BEQ.L	lbC00A180
	MOVEA.L	lbL0097AE(PC),A1
	RTS

lbC00A17A	MOVEA.L	lbL009796(PC),A1
	RTS

lbC00A180	MOVEA.L	lbL0097AA(PC),A1
	RTS

lbC00A186	TST.W	(A0)
	BNE.L	lbC00A18E
	RTS

lbC00A18E	TST.W	2(A0)
	BEQ.L	lbC00A302
	CMPI.W	#1,2(A0)
	BEQ.L	lbC00A382
	CMPI.W	#3,4(A0)
	BEQ.L	lbC00A2EA
	SUBQ.W	#1,2(A0)
lbC00A1AE	CLR.W	lbW00978C
	MOVE.W	6(A0),D2
	TST.W	8(A0)
	BEQ.L	lbC00A202
	TST.W	14(A0)
	BEQ.L	lbC00A1D0
	SUBQ.W	#1,14(A0)
	BRA.L	lbC00A202

lbC00A1D0	ADDQ.W	#1,lbW00978C
	MOVE.W	10(A0),D3
	MOVE.W	12(A0),D4
	CMPI.W	#1,8(A0)
	BEQ.L	lbC00A1F4
	SUB.W	D3,D2
	CMP.W	D2,D4
	BCS.L	lbC00A202
	BRA.L	lbC00A1FC

lbC00A1F4	ADD.W	D3,D2
	CMP.W	D2,D4
	BCC.L	lbC00A202
lbC00A1FC	MOVE.W	D4,D2
	CLR.W	8(A0)
lbC00A202	TST.W	$10(A0)
	BEQ.L	lbC00A268
	TST.W	$3A(A0)
	BEQ.L	lbC00A21A
	SUBQ.W	#1,$3A(A0)
	BRA.L	lbC00A268

lbC00A21A	TST.W	$32(A0)
	BEQ.L	lbC00A22A
	SUBQ.W	#1,$32(A0)
	BRA.L	lbC00A268

lbC00A22A	MOVE.W	$34(A0),$32(A0)
	ADDQ.W	#1,lbW00978C
	CMPI.W	#3,$10(A0)
	BCC.L	lbC00A24E
	MOVE.W	$38(A0),D3
	SUB.W	D3,D2
	ADDQ.W	#1,$10(A0)
	BRA.L	lbC00A268

lbC00A24E	MOVE.W	$36(A0),D3
	ADD.W	D3,D2
	ADDQ.W	#1,$10(A0)
	CMPI.W	#5,$10(A0)
	BNE.L	lbC00A268
	MOVE.W	#1,$10(A0)
lbC00A268	TST.W	lbW00978C
	BEQ.L	lbC00A27A
	MOVE.W	D2,6(A0)
	MOVE.W	D2,6(A2)

	move.l	D0,-(A7)
	move.w	D2,D0
	bsr.w	SetPer
	move.l	(A7)+,D0

lbC00A27A	MOVEA.L	$12(A0),A1
	CMPI.W	#$FF,(A1)
	BEQ.L	lbC00A2C4
lbC00A286	CLR.L	D0
	MOVE.W	(A1)+,D0
	TST.W	lbW009790
	BNE.L	lbC00A2A0
	SUB.W	lbW00975C(PC),D0
	BCC.L	lbC00A2A0
	MOVE.W	#0,D0
lbC00A2A0
;	MOVE.W	D0,8(A2)

	bsr.w	ChangeVolume
	bsr.w	SetVol

	MOVE.L	A1,$12(A0)
	RTS

;	SUB.W	lbW00975C(PC),D0
;	BCC.L	lbC00A2B6
;	MOVE.W	#0,D0
;lbC00A2B6	MOVE.W	D0,8(A2)
;	MOVE.W	(A1)+,8(A2)
;	MOVE.L	A1,$12(A0)
;	RTS

lbC00A2C4	SUBQ.L	#2,A1
	BRA.S	lbC00A286

;	RTS

lbC00A2CA	MOVE.W	#3,4(A0)
	MOVE.L	$26(A0),(A2)
	MOVE.W	$2A(A0),4(A2)

	movem.l	D0/A1,-(A7)
	move.l	$26(A0),A1
	bsr.w	SetAdr
	move.w	$2A(A0),D0
	bsr.w	SetLen
	movem.l	(A7)+,D0/A1

	MOVE.W	D1,$DFF096
	MOVE.W	#$87E0,$DFF096
	BRA.S	lbC00A27A

lbC00A2EA	MOVE.L	$2C(A0),(A2)
	MOVE.W	$30(A0),4(A2)
	SUBQ.W	#1,2(A0)
	MOVE.W	#1,4(A0)
	BRA.L	lbC00A1AE

lbC00A302	MOVE.W	#0,$42(A0)
	MOVEA.L	$16(A0),A1
lbC00A30C	MOVE.W	(A1)+,D0
	CMPI.W	#$64,D0
	BLS.L	lbC00A3A2
	MOVE.W	D0,6(A0)
	MOVE.W	D0,6(A2)

	bsr.w	SetPer

	MOVE.W	(A1)+,2(A0)
	SUBQ.W	#1,2(A0)
	MOVE.L	A1,$16(A0)
	MOVE.L	$22(A0),$12(A0)
	MOVE.W	$3C(A0),$3A(A0)
	TST.W	$10(A0)
	BEQ.L	lbC00A344
	MOVE.W	#1,$10(A0)
lbC00A344	CMPI.W	#0,4(A0)
	BEQ.L	lbC00A352
	BRA.L	lbC00A2CA

lbC00A352	MOVE.W	D1,$DFF096
	MOVE.W	#$87E0,$DFF096
	BRA.L	lbC00A27A

lbC00A364
;	MOVE.W	(A1)+,2(A0)

	move.w	(A1)+,D7
	bpl.b	OK_1
	bsr.w	SongEndTest
OK_1
	move.w	D7,2(A0)

	SUBQ.W	#1,2(A0)
	MOVE.L	A1,$16(A0)
	MOVE.L	#lbL00A7C4,$12(A0)
	MOVE.W	#0,8(A2)
	BRA.L	lbC00A27A

lbC00A382	CMPI.W	#0,4(A0)
	BEQ.L	lbC00A39A
	MOVE.W	D5,$DFF096
	MOVE.W	#$87E0,$DFF096
lbC00A39A	SUBQ.W	#1,2(A0)
	BRA.L	lbC00A1AE

lbC00A3A2	MOVEA.L	#lbL00A3AE,A3

	cmp.w	#60,D0
	bcs.b	.ok
	clr.w	D0
.ok
	MOVEA.L	0(A3,D0.W),A4
	JMP	(A4)

lbL00A3AE	dc.l	lbC00A3EA
	dc.l	lbC00A412
	dc.l	lbC00A460
	dc.l	lbC00A47E
	dc.l	lbC00A492
	dc.l	lbC00A49E
	dc.l	lbC00A4B4
	dc.l	lbC00A4BC
	dc.l	lbC00A364
	dc.l	lbC00A4C4
	dc.l	lbC00A4C4
	dc.l	lbC00A3FA
	dc.l	lbC00A406
	dc.l	lbC00A57C
	dc.l	lbC00A3EE

lbC00A3EA	NOP
	RTS

lbC00A3EE	MOVE.L	(A1),D0
	MOVEA.L	lbL0097A6(PC),A1
	ADDA.L	D0,A1
	BRA.L	lbC00A30C

lbC00A3FA	BCLR	#1,$BFE001
	BRA.L	lbC00A30C

lbC00A406	BSET	#1,$BFE001
	BRA.L	lbC00A30C

lbC00A412	MOVE.L	(A1)+,D0
	MOVEA.L	lbL0097A6(PC),A3
	ADDA.L	D0,A3
	CMPI.W	#0,(A3)
	BNE.L	lbC00A438
	MOVE.W	(A3)+,4(A0)
	MOVEA.L	lbL0097A6(PC),A6
	MOVE.L	(A3)+,D0
	ADDA.L	D0,A6
	MOVE.L	A6,(A2)
	MOVE.W	(A3),4(A2)

	movem.l	D0/A1,-(A7)
	move.l	A6,A1
	bsr.w	SetAdr
	move.w	(A3),D0
	bsr.w	SetLen
	movem.l	(A7)+,D0/A1

	JMP	lbC00A30C(PC)

lbC00A438	MOVE.W	(A3)+,4(A0)
	MOVEA.L	lbL0097A6(PC),A6
	MOVE.L	(A3)+,D0
	ADDA.L	D0,A6
	MOVE.L	A6,$26(A0)
	MOVE.W	(A3)+,$2A(A0)
	MOVEA.L	lbL0097A6(PC),A6
	MOVE.L	(A3)+,D0
	ADDA.L	D0,A6
	MOVE.L	A6,$2C(A0)
	MOVE.W	(A3),$30(A0)
	JMP	lbC00A30C(PC)

lbC00A460	MOVEA.L	$1A(A0),A1
	CMPI.L	#0,(A1)
	BEQ.L	lbC00A586

	cmp.l	Hardware(PC),A2
	bne.b	Exit4
	move.l	$1A(A0),D0
	sub.l	$1E(A0),D0
	move.l	D0,CurrentPos
Exit4
	ADDQ.L	#4,$1A(A0)
	MOVE.L	(A1),D0
	MOVEA.L	lbL0097A6(PC),A1
	ADDA.L	D0,A1
	JMP	lbC00A30C(PC)

lbC00A47E	MOVE.L	(A1)+,D0
	MOVEA.L	lbL0097A6(PC),A4
	ADDA.L	D0,A4
	MOVE.L	(A4)+,$3E(A0)
	MOVE.L	A4,$22(A0)
	BRA.L	lbC00A30C

lbC00A492	MOVE.L	(A1)+,8(A0)
	MOVE.L	(A1)+,12(A0)
	BRA.L	lbC00A30C

lbC00A49E	MOVE.W	#1,$10(A0)
	MOVE.L	(A1)+,$32(A0)
	MOVE.L	(A1)+,$36(A0)
	MOVE.L	(A1)+,$3A(A0)
	BRA.L	lbC00A30C

lbC00A4B4	CLR.W	8(A0)
	BRA.L	lbC00A30C

lbC00A4BC	CLR.W	$10(A0)
	BRA.L	lbC00A30C

lbC00A4C4	CMPI.W	#6,(A0)
	BEQ.L	lbC00A554
	CMPI.W	#5,(A0)
	BEQ.L	lbC00A52C
	CMPI.W	#7,(A0)
	BEQ.L	lbC00A504
lbC00A4DC	MOVE.W	D5,$DFF096
	MOVE.W	#$87E0,$DFF096
	MOVE.W	#1,$DFF0A6
	MOVE.W	#0,8(A2)
	MOVE.L	#0,lbL00976E
	RTS

lbC00A504	MOVE.W	D5,$DFF096
	MOVE.W	#$87E0,$DFF096
	MOVE.W	#1,$DFF0B6
	MOVE.W	#0,8(A2)
	MOVE.L	#0,lbL009772
	RTS

lbC00A52C	MOVE.W	D5,$DFF096
	MOVE.W	#$87E0,$DFF096
	MOVE.W	#1,$DFF0C6
	MOVE.W	#0,8(A2)
	MOVE.L	#0,lbL009776
	RTS

lbC00A554	MOVE.W	D5,$DFF096
	MOVE.W	#$87E0,$DFF096
	MOVE.W	#1,$DFF0D6
	MOVE.W	#0,8(A2)
	MOVE.L	#0,lbL00977A
	RTS

lbC00A57C	MOVE.W	#1,$42(A0)
	BRA.L	lbC00A30C

lbC00A586	ADDQ.L	#4,A1
	MOVE.L	$1E(A0),$1A(A0)
	MOVEA.L	$1A(A0),A1
	ADDQ.L	#4,$1A(A0)

	bsr.w	SongEndTest

	MOVEA.L	lbL0097A6(PC),A6
	MOVE.L	(A1),D0
	ADDA.L	D0,A6
	MOVEA.L	A6,A1
	JMP	lbC00A30C(PC)

lbL00A5A4	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
lbL00A5BA	dc.l	0
lbL00A5BE	dc.l	0
lbL00A5C2	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
lbL00A5E8	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
lbL00A5FE	dc.l	0
lbL00A602	dc.l	0
lbL00A606	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
lbL00A62C	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
lbL00A642	dc.l	0
lbL00A646	dc.l	0
lbL00A64A	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
lbL00A670	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
lbL00A686	dc.l	0
lbL00A68A	dc.l	0
lbL00A68E	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
lbW00A6B4	dc.w	0
lbL00A6B6	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbL00A6CA	dc.l	0
	dc.l	0
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
lbW00A6F8	dc.w	0
lbL00A6FA	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbL00A70E	dc.l	0
	dc.l	0
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
lbW00A73C	dc.w	0
lbL00A73E	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbL00A752	dc.l	0
	dc.l	0
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
lbW00A780	dc.w	0
lbL00A782	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbL00A796	dc.l	0
	dc.l	0
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
lbL00A7C4	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	$FF
lbL00A7D6	dc.l	0
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

	Section	Buffer,BSS_C
Empty
	ds.b	32

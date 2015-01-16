	*****************************************************
	****   Maximum Effect replayer for EaglePlayer	 ****
	****        all adaptions by Wanted Team,	 ****
	****      DeliTracker compatible (?) version	 ****
	*****************************************************

	incdir	"dh2:include/"
	include 'misc/eagleplayer2.01.i'

	SECTION Player,CODE

	PLAYERHEADER Tags

	dc.b	'$VER: Maximum Effect player module V1.0 (22 Feb 2009)',0
	even
Tags
	dc.l	DTP_PlayerVersion,1
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
	dc.l	EP_Get_ModuleInfo,Get_ModuleInfo
	dc.l	DTP_ExtLoad,ExtLoad
	dc.l	DTP_Volume,SetVolume
	dc.l	DTP_Balance,SetBalance
	dc.l	EP_Voices,SetVoices
	dc.l	EP_StructInit,StructInit
	dc.l	EP_GetPositionNr,GetPosition
	dc.l	EP_SampleInit,SampleInit
	dc.l	EP_Flags,EPB_Volume!EPB_Balance!EPB_ModuleInfo!EPB_LoadFast!EPB_Voices!EPB_SampleInfo!EPB_Songend!EPB_Analyzer!EPB_NextSong!EPB_PrevSong!EPB_Packable!EPB_Restart
	dc.l	TAG_DONE
PlayerName
	dc.b	'Maximum Effect',0
Creator
	dc.b	"(c) 1993 by Jonathan Scarcliffe &",10
	dc.b	'Alastair Dukes, adapted by Wanted Team',0
Prefix
	dc.b	'MAX.',0
SampleName
	dc.b	'SMP.set',0
	even
ModulePtr
	dc.l	0
SamplesPtr
	dc.l	0
EagleBase
	dc.l	0
SongEnd
	dc.l	'WTWT'
SongEndTemp
	dc.l	0
Position
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
******************************* EP_SampleInit *****************************
***************************************************************************

SampleInit
	moveq	#EPR_NotEnoughMem,D7
	lea	EPG_SampleInfoStructure(A5),A3
	move.l	SamplesPtr(PC),D0
	beq.b	return
	move.l	D0,A2
	addq.l	#2,A2
	move.l	InfoBuffer+Samples(PC),D5
	subq.l	#1,D5
hop
	jsr	ENPP_AllocSampleStruct(A5)
	move.l	D0,(A3)
	beq.b	return
	move.l	D0,A3

	move.l	(A2),EPS_Adr(A3)		; sample address
	moveq	#0,D0
	move.w	4(A2),D0
	add.l	D0,D0
	move.l	D0,EPS_Length(A3)		; sample length
	move.l	#64,EPS_Volume(A3)
	move.w	#USITY_RAW,EPS_Type(A3)
	move.w	#USIB_Playable!USIB_Saveable!USIB_8BIT,EPS_Flags(A3)
	lea	16(A2),A2
	dbf	D5,hop

	moveq	#0,D7
return
	move.l	D7,D0
	rts

***************************************************************************
********************************* EP_GetPosNr *****************************
***************************************************************************

GetPosition
	moveq	#0,D0
	move.w	lbL0008B4+8(PC),D0
	divu.w	#6,D0
	rts

***************************************************************************
******************************* EP_StructInit *****************************
***************************************************************************

StructInit
	lea	StructAdr(PC),A0
	rts

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
	move.l	A6,D1
	cmp.w	#$F0A0,D1
	beq.s	Left1
	cmp.w	#$F0B0,D1
	beq.s	Right1
	cmp.w	#$F0C0,D1
	beq.s	Right2
	cmp.w	#$F0D0,D1
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
	move.w	D0,8(A6)
Exit
	move.l	(A7)+,D1
	rts

*-------------------------------- Set Vol -------------------------------*

SetVol
	move.l	A0,-(SP)
	lea	StructAdr+UPS_Voice1Vol(PC),A0
	cmp.l	#$DFF0A0,A6
	beq.b	.SetVoice
	lea	StructAdr+UPS_Voice2Vol(PC),A0
	cmp.l	#$DFF0B0,A6
	beq.b	.SetVoice
	lea	StructAdr+UPS_Voice3Vol(PC),A0
	cmp.l	#$DFF0C0,A6
	beq.b	.SetVoice
	lea	StructAdr+UPS_Voice4Vol(PC),A0
.SetVoice
	move.w	D0,(A0)
	move.l	(SP)+,A0
	rts

*-------------------------------- Set All -------------------------------*

SetAll
	move.l	A2,-(SP)
	lea	StructAdr+UPS_Voice1Adr(PC),A2
	cmp.l	#$DFF0A0,A6
	beq.b	.SetVoice
	lea	StructAdr+UPS_Voice2Adr(PC),A2
	cmp.l	#$DFF0B0,A6
	beq.b	.SetVoice
	lea	StructAdr+UPS_Voice3Adr(PC),A2
	cmp.l	#$DFF0C0,A6
	beq.b	.SetVoice
	lea	StructAdr+UPS_Voice4Adr(PC),A2
.SetVoice
	move.l	(A4,D1.W),(A2)
	move.w	4(A4,D1.W),UPS_Voice1Len(A2)
	move.w	$1C(A0),UPS_Voice1Per(A2)
	move.l	(SP)+,A2
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
******************************* DTP_Check2 ********************************
***************************************************************************

Check2
	movea.l	dtg_ChkData(A5),A0

	move.l	A0,A1
	move.l	(A1)+,D1
	beq.b	error
	moveq	#15,D2
	cmp.l	D1,D2
	bhi.b	error
	move.l	dtg_ChkSize(A5),D3
	move.l	(A1)+,D1
	beq.b	Zero1
	bmi.b	error
	btst	#0,D1
	bne.b	error
	cmp.l	D3,D1
	bgt.b	error
	subq.l	#2,D1
	beq.b	error
	divu.w	#18,D1
	swap	D1
	tst.w	D1
	bne.b	error
Zero1
	moveq	#2,D2
LongTest
	move.l	(A1)+,D0
	bmi.b	error
	beq.b	Zero2
	btst	#0,D0
	bne.b	error
	cmp.l	D3,D0
	bgt.b	error
	tst.l	-6(A0,D0.L)
	bne.b	error
	moveq	#1,D1
Zero2
	dbf	D2,LongTest
	tst.l	D1
	beq.b	error
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
	bsr.s	CopyName2
	move.l	dtg_LoadFile(A5),A0
	jsr	(A0)
	tst.l	D0
	beq.b	ExtLoadOK
	move.l	dtg_PathArrayPtr(A5),A0
	clr.b	(A0)
	move.l	dtg_CopyDir(A5),A0
	jsr	(A0)
	bsr.b	CopyName
	move.l	dtg_LoadFile(A5),A0
	jsr	(A0)
ExtLoadOK
	rts

CopyName
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

CopyName2
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

	cmpi.b	#'M',(A3)
	beq.b	M_OK
	cmpi.b	#'m',(A3)
	bne.s	ExtError
M_OK
	cmpi.b	#'A',1(A3)
	beq.b	A_OK
	cmpi.b	#'a',1(A3)
	bne.s	ExtError
A_OK
	cmpi.b	#'X',2(A3)
	beq.b	X_OK
	cmpi.b	#'x',2(A3)
	bne.s	ExtError
X_OK
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

SubSongs	=	4
LoadSize	=	12
Samples		=	20
Length		=	28
Voices		=	36
SamplesSize	=	44

InfoBuffer
	dc.l	MI_SubSongs,0		;4
	dc.l	MI_LoadSize,0		;12
	dc.l	MI_Samples,0		;20
	dc.l	MI_Length,0		;28
	dc.l	MI_Voices,0		;36
	dc.l	MI_SamplesSize,0	;44
	dc.l	MI_MaxVoices,4
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

	move.l	4(A0),D0
	subq.l	#2,D0
	divu.w	#18,D0
	move.l	D0,SubSongs(A4)
	bsr.w	InitSong

	moveq	#1,D0
	movea.l	dtg_GetListData(A5),A0
	jsr	(A0)

	move.l	A0,(A6)+			; SamplesPtr
	add.l	D0,LoadSize(A4)
	move.l	A5,(A6)				; EagleBase

	moveq	#1,D1
	add.w	(A0),D1
	move.l	D1,Samples(A4)
	move.l	2(A0),D2
	moveq	#0,D1
	move.w	-12(A0,D2.L),D1
	add.l	D1,D1
	add.l	-16(A0,D2.L),D1
	move.l	D1,SamplesSize(A4)
	sub.l	D1,D0
	bmi.b	Short
	bsr.w	InitSamp

	move.l	dtg_AudioAlloc(A5),A0
	jmp	(A0)

Short
	moveq	#EPR_ModuleTooShort,D0
	rts

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

	bsr.w	Play_1
	bsr.w	Play_2

	lea	StructAdr(PC),A0
	clr.w	UPS_Enabled(A0)

	movem.l	(SP)+,D1-A6
	moveq	#0,D0
	rts

SongEndTest
	movem.l	A1/A5,-(A7)
	lea	SongEnd(PC),A1
	cmp.l	#$DFF0A0,A6
	bne.b	test1
	clr.b	(A1)
	bra.b	test
test1
	cmp.l	#$DFF0B0,A6
	bne.b	test2
	clr.b	1(A1)
	bra.b	test
test2
	cmp.l	#$DFF0C0,A6
	bne.b	test3
	clr.b	2(A1)
	bra.b	test
test3
	cmp.l	#$DFF0D0,A6
	bne.b	test
	clr.b	3(A1)
test
	tst.l	(A1)+
	bne.b	SkipEnd
	move.l	(A1),-(A1)
	move.l	EagleBase(PC),A5
	move.l	dtg_SongEnd(A5),A1
	jsr	(A1)
SkipEnd
	movem.l	(A7)+,A1/A5
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
	move.l	ModulePtr(PC),A0
	move.l	SamplesPtr(PC),A1
	bsr.w	Init_1
	move.l	EagleBase(PC),A5
	move.w	dtg_SndNum(A5),D0

	move.w	D0,D1
	mulu.w	#18,D1
	move.l	ModulePtr(PC),A0
	lea	2(A0,D1.L),A1
	move.w	(A1)+,D1
	lea	SongEnd(PC),A3
	move.l	#'WTWT',(A3)
	moveq	#4,D4
	btst	#0,D1
	bne.b	Voice1On
	subq.l	#1,D4
	clr.b	(A3)
Voice1On
	btst	#1,D1
	bne.b	Voice2On
	subq.l	#1,D4
	clr.b	1(A3)
Voice2On
	btst	#2,D1
	bne.b	Voice3On
	subq.l	#1,D4
	clr.b	2(A3)
Voice3On
	btst	#3,D1
	bne.b	Voice4On
	subq.l	#1,D4
	clr.b	3(A3)
Voice4On
	move.l	(A3)+,(A3)			; SongEndTemp
	lea	InfoBuffer(PC),A4
	moveq	#0,D5
	move.l	D4,Voices(A4)
	beq.b	SkipLength
NextVox
	move.l	(A1)+,D1
	beq.b	SkipLength
	move.l	D1,A1
NextLen
	tst.l	(A1)
	beq.b	SkipLength
	addq.l	#1,D5
	addq.l	#6,A1
	bra.b	NextLen
SkipLength
	move.l	D5,Length(A4)
	moveq	#15,D1
	bra.w	Init_2

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
***************************** DTP_SubSongRange ****************************
***************************************************************************

SubSongRange	
	moveq	#0,D0
	move.l	InfoBuffer+SubSongs(PC),D1
	subq.l	#1,D1
	rts

***************************************************************************
************************** Maximum Effect player **************************
***************************************************************************

; Player from game "'Allo 'Allo!" (c) 1993 by Alternative Software

;Volume
;	dc.w	0			; fade value

;	BRA.L	lbC00002C		; 1st init A0 song, A1 samples

;	BRA.L	lbC000098		; 2nd init A0 song, A1 Samples, D0=$100 master volume

;	BRA.L	lbC0000EA

;	BRA.L	lbC00011E

;	BRA.L	lbC00024E		; get master volume

;	BRA.L	lbC00025C		; volume fade

;	BRA.L	lbC000298		; main interrupt $6C

;	BRA.L	lbC0006CA		; Audio Interrupt $70

;	BRA.L	lbC000776		; Timer Interrupt $78

;	BRA.L	lbC00054E

;	BRA.L	lbC00058E

;lbC00002C	MOVE.L	A1,-(SP)
;	BSR.L	lbC000038
;	MOVEA.L	(SP)+,A0
;	BRA.L	lbC00007E

InitSong
lbC000038	MOVE.L	A0,D7
	MOVE.W	(A0),D6
	BMI.S	lbC00006C
	MOVE.W	#$FFFF,(A0)+
lbC000042	MOVE.W	#3,D5
lbC000046	MOVEA.L	2(A0),A1
	CMPA.L	#0,A1
	BEQ.S	lbC00005C
	ADDA.L	D7,A1
	MOVE.L	A1,2(A0)
	BSR.L	lbC00006E
lbC00005C	LEA	4(A0),A0
	DBRA	D5,lbC000046
	LEA	2(A0),A0
	DBRA	D6,lbC000042
lbC00006C	RTS

lbC00006E	MOVE.L	(A1),D0
	BEQ.L	lbC0002BC
	ADD.L	D7,D0
	MOVE.L	D0,(A1)
	LEA	6(A1),A1
	BRA.S	lbC00006E

InitSamp
lbC00007E	MOVE.L	A0,D6
	MOVE.W	(A0),D7
	BMI.S	lbC000096
	MOVE.W	#$FFFF,(A0)+
lbC000088	ADD.L	D6,(A0)
	ADD.L	D6,8(A0)
	LEA	$10(A0),A0
	DBRA	D7,lbC000088
lbC000096	RTS

Init_1
lbC000098	LEA	lbL0008B4(PC),A5
	MOVE.L	A0,$B0(A5)
	LEA	2(A1),A1
	MOVE.L	A1,$AC(A5)
;	MOVE.W	D0,$AA(A5)
	LEA	$D0(A5),A0
	CLR.B	(A0)
	LEA	$A0(A5),A0
	MOVE.W	#9,D7
lbC0000BA	CLR.B	(A0)+
	DBRA	D7,lbC0000BA
;	MOVE.B	#8,$BFDE00
;	MOVE.B	#$80,$BFD400
;	MOVE.B	#1,$BFD500
;	MOVE.B	#$7F,$BFDD00
;	MOVE.B	#$81,$BFDD00
	RTS

;lbC0000EA	LEA	lbL0008B4(PC),A5
;	MOVE.W	#0,D7
;	LEA	$A0(A5),A1
;lbC0000F6	CMP.W	4(A1),D0
;	BEQ.S	lbC000106
;	LEA	$12(A1),A1
;	DBRA	D7,lbC0000F6
;	RTS

;lbC000106	MOVEQ	#0,D3
;	MOVE.B	1(A1),D3
;	MOVE.W	D3,$DFF096
;	NOT.B	D3
;	AND.B	D3,$D0(A5)
;	CLR.B	1(A1)
;	RTS

Init_2
lbC00011E	LEA	lbL0008B4(PC),A5
	MOVEA.L	$B0(A5),A0
	MULU.W	#$12,D0
	LEA	2(A0,D0.L),A0
;	TST.B	D1
;	BNE.L	lbC00017C
;	MOVE.W	#0,D7
;	LEA	$A0(A5),A1
;	MOVE.B	$D0(A5),D3
;	NOT.B	D3
;lbC000142	MOVE.B	(A0),D2
;	CMP.B	2(A1),D2
;	BCS.S	lbC00014E
;	OR.B	1(A1),D3
;lbC00014E	LEA	6(A1),A1
;	DBRA	D7,lbC000142
;	MOVE.B	D3,D1
;	BEQ.L	lbC0001D8
;	MOVE.B	1(A0),D2
;	CLR.W	D4
;	CLR.W	D5
;	MOVE.W	#3,D7
;lbC000168	LSR.B	#1,D3
;	BCC.S	lbC00016E
;	ADDQ.W	#1,D4
;lbC00016E	LSR.B	#1,D2
;	BCC.S	lbC000174
;	ADDQ.W	#1,D5
;lbC000174	DBRA	D7,lbC000168
;	CMP.W	D5,D4
;	BCS.S	lbC0001D8
lbC00017C	MOVE.W	#0,D7
	LEA	$A0(A5),A1
lbC000184	MOVE.B	1(A1),D2
	AND.B	D1,D2
	BEQ.S	lbC000194
	MOVE.B	(A0),D2
	CMP.B	2(A1),D2
	BCS.S	lbC0001D8
lbC000194	LEA	6(A1),A1
	DBRA	D7,lbC000184
	MOVE.W	#0,D7
	LEA	$A0(A5),A1
lbC0001A4	MOVE.B	1(A1),D2
	AND.B	D1,D2
	BEQ.S	lbC0001BA
	MOVE.B	1(A1),D2
	NOT.B	D2
	AND.B	D2,$D0(A5)
	CLR.B	1(A1)
lbC0001BA	LEA	6(A1),A1
	DBRA	D7,lbC0001A4
	MOVE.W	#0,D7
	LEA	$A0(A5),A3
lbC0001CA	TST.B	1(A3)
	BEQ.S	lbC0001DA
	LEA	6(A3),A3
	DBRA	D7,lbC0001CA
lbC0001D8	RTS

lbC0001DA	LEA	(A5),A1
	LEA	2(A0),A2
	MOVE.W	#4,D7
	MOVE.W	#4,D6
	MOVE.B	1(A0),D2
lbC0001EC	SUBQ.W	#1,D7
	BMI.S	lbC000212
	LSR.B	#1,D2
	BCS.S	lbC0001FA
lbC0001F4	LEA	4(A2),A2
	BRA.S	lbC0001EC

lbC0001FA	SUBQ.W	#1,D6
	BMI.S	lbC000212
	LSR.B	#1,D1
	MOVE.B	1(A3),D5
	ROXR.B	#1,D5
	MOVE.B	D5,1(A3)
	BMI.S	lbC00022E
	LEA	$28(A1),A1
	BRA.S	lbC0001FA

lbC000212	MOVE.B	(A0),2(A3)
	MOVE.B	1(A0),(A3)
	MOVE.B	1(A3),D0
	LSR.B	#4,D0
	MOVE.B	D0,1(A3)
	MOVE.B	1(A3),D1
	OR.B	D1,$D0(A5)
	RTS

lbC00022E	MOVE.W	D0,4(A3)
	MOVE.L	(A2),D5
	MOVE.L	D5,4(A1)
	MOVE.L	A3,(A1)
	CLR.W	8(A1)
	CLR.W	14(A1)
	MOVE.W	#$8000,$10(A1)
	LEA	$28(A1),A1
	BRA.S	lbC0001F4

;lbC00024E	MOVE.L	A5,-(SP)
;	LEA	lbL0008B4(PC),A5
;	MOVE.W	$AA(A5),D0
;	MOVEA.L	(SP)+,A5
;	RTS

;lbC00025C	MOVEM.L	D0-D7/A0-A6,-(SP)
;	LEA	lbL0008B4(PC),A5
;	MOVE.W	D0,$AA(A5)
;	LEA	(A5),A0
;	LEA	$DFF0A0,A6
;	MOVE.W	#3,D7
;lbC000274	TST.B	$26(A0)
;	BNE.S	lbC000286
;	MOVE.W	$1E(A0),D1
;	MULU.W	D0,D1
;	LSR.W	#8,D1
;	MOVE.W	D1,8(A6)
;lbC000286	LEA	$28(A0),A0
;	LEA	$10(A6),A6
;	DBRA	D7,lbC000274
;	MOVEM.L	(SP)+,D0-D7/A0-A6
;	RTS

Play_1
;lbC000298	MOVEM.L	D0-D7/A0-A6,-(SP)
	MOVE.W	#$8000,D7
	BSR.L	lbC0002BE
;	BSR.L	lbC0005AA			; SFX play
	LEA	lbL0008B4(PC),A5
	MOVE.W	D7,$A8(A5)
;	MOVE.B	#$19,$BFDE00
;	MOVEM.L	(SP)+,D0-D7/A0-A6
lbC0002BC	RTS

lbC0002BE	LEA	lbL0008B4(PC),A5
	MOVEA.L	$AC(A5),A4
	LEA	lbW00086C(PC),A3
	BTST	#0,$D0(A5)
	BEQ.S	lbC0002E2
	LEA	(A5),A0
	LEA	$DFF0A0,A6
	MOVE.W	#1,D6
	BSR.L	lbC000332
lbC0002E2	BTST	#1,$D0(A5)
	BEQ.S	lbC0002FC
	LEA	$28(A5),A0
	LEA	$DFF0B0,A6
	MOVE.W	#2,D6
	BSR.L	lbC000332
lbC0002FC	BTST	#2,$D0(A5)
	BEQ.S	lbC000316
	LEA	$50(A5),A0
	LEA	$DFF0C0,A6
	MOVE.W	#4,D6
	BSR.L	lbC000332
lbC000316	BTST	#3,$D0(A5)
	BEQ.S	lbC000330
	LEA	$78(A5),A0
	LEA	$DFF0D0,A6
	MOVE.W	#8,D6
	BSR.L	lbC000332
lbC000330	RTS

lbC000332	SUBQ.W	#1,$10(A0)
	BPL.S	lbC00034A
	MOVEA.L	$12(A0),A2
	CMPA.L	#0,A2
	BEQ.S	lbC000330
	JSR	(A2)
	BRA.L	lbC0003F6

lbC00034A	CLR.L	$12(A0)
	TST.W	14(A0)
	BNE.S	lbC00039C
	MOVEA.L	4(A0),A1
	MOVE.W	8(A0),D0
	MOVE.L	0(A1,D0.W),10(A0)
	BNE.S	lbC000392
	MOVEA.L	(A0),A2
	BTST	#4,(A2)
	BEQ.S	lbC000376
;	EOR.B	D6,$D0				; bug !!!

	eor.b	D6,$D0(A5)

	EOR.B	D6,1(A2)
	RTS

lbC000376	LEA	CMaximumEffec.MSG(PC),A2
	CMPI.L	#$4D617869,4(A2)
	BNE.S	lbC000392
	MOVE.W	4(A1,D0.W),D0
	MOVE.W	D0,8(A0)
	MOVE.L	0(A1,D0.W),10(A0)

	bsr.w	SongEndTest

lbC000392	MOVE.W	4(A1,D0.W),14(A0)
	ADDQ.W	#6,8(A0)
lbC00039C	MOVEA.L	10(A0),A1
	MOVE.W	(A1)+,D1
	BPL.S	lbC000412
	MOVE.W	D1,D2
	LSR.W	#4,D1
	ANDI.W	#$7F0,D1
	ANDI.W	#$FF,D2
	BCLR	#0,D2
	BNE.S	lbC0003BC
	MOVE.W	6(A4,D1.W),$1E(A0)
lbC0003BC	MOVE.W	0(A3,D2.W),$1C(A0)
;	TST.B	$26(A0)
;	BNE.S	lbC0003E6
	MOVE.W	D6,$DFF096			; DMA off
	OR.W	D6,D7
	MOVE.L	0(A4,D1.W),(A6)			; address
	MOVE.W	4(A4,D1.W),4(A6)		; length

	bsr.w	SetAll

	MOVE.L	8(A4,D1.W),$20(A0)
	MOVE.W	12(A4,D1.W),$24(A0)
lbC0003E6	MOVE.W	(A1)+,D1
	BPL.S	lbC000412
	MOVE.W	D1,$10(A0)
	MOVE.L	A1,10(A0)
	SUBQ.W	#1,14(A0)
lbC0003F6
;	TST.B	$26(A0)
;	BNE.S	lbC000410
	MOVE.W	$1C(A0),6(A6)		; period
	MOVE.W	$1E(A0),D0
;	MULU.W	$AA(A5),D0
;	LSR.W	#8,D0
;	MOVE.W	D0,8(A6)		; volume

	bsr.w	ChangeVolume
	bsr.w	SetVol

lbC000410	RTS

lbC000412	MOVE.W	D1,D2
	LSR.W	#6,D1
	ANDI.W	#$1FC,D1
	ANDI.W	#$FF,D2
	LEA	lbC0006A6(PC),A2
	JMP	0(A2,D1.W)

lbC000426
;	BSET	#1,$BFD000		; bug !!!

	bset	#1,$BFE001

	BRA.S	lbC0003E6

lbC000430
;	BCLR	#1,$BFD000		; bug !!!

	bclr	#1,$BFE001

	BRA.S	lbC0003E6

lbC00043A	MOVE.W	D2,$1E(A0)
	BRA.S	lbC0003E6

lbC000440	CLR.B	$17(A0)
lbC000444	LEA	lbC0004AE(PC),A2
	MOVE.L	A2,$12(A0)
	MOVE.B	D2,$18(A0)
	MOVE.B	(A1)+,$19(A0)
	MOVE.B	(A1)+,$16(A0)
	MOVE.W	$1C(A0),$1A(A0)
	BSR.L	lbC0004AE
	BRA.S	lbC0003E6

lbC000464	LEA	lbC0004D6(PC),A2
	MOVE.L	A2,$12(A0)
	MOVE.B	D2,$16(A0)
	BRA.L	lbC0003E6

lbC000474	LEA	lbC0004FA(PC),A2
	MOVE.L	A2,$12(A0)
	MOVE.B	D2,$17(A0)
	MOVE.B	(A1)+,$18(A0)
	MOVE.B	(A1)+,$16(A0)
	BSR.L	lbC0004FA
	BRA.L	lbC0003E6

lbC000490	LEA	lbC000528(PC),A2
	MOVE.L	A2,$12(A0)
	MOVE.B	D2,$16(A0)
	MOVE.B	(A1)+,$17(A0)
	MOVE.B	(A1)+,$18(A0)
	MOVE.B	#$FF,$19(A0)
	BRA.L	lbC0003E6

lbC0004AE	LEA	lbW0007EC(PC),A2
	MOVE.B	$17(A0),D2
	ANDI.W	#$7E,D2
	MOVE.B	$19(A0),D3
	MOVE.W	0(A2,D2.W),D4
	ASL.W	D3,D4
	ASR.W	#7,D4
	ADD.W	$1A(A0),D4
	MOVE.W	D4,$1C(A0)
	ADD.B	$18(A0),D2
	MOVE.B	D2,$17(A0)
lbC0004D6	MOVE.B	$16(A0),D2
	BEQ.S	lbC0004F8
	EXT.W	D2
	MOVE.W	$1E(A0),D3
	ADD.W	D2,D3
	BMI.S	lbC0004F2
	CMPI.W	#$40,D3
	BLS.S	lbC0004F4
	MOVE.W	#$40,D3
	BRA.S	lbC0004F4

lbC0004F2	CLR.W	D3
lbC0004F4	MOVE.W	D3,$1E(A0)
lbC0004F8	RTS

lbC0004FA	MOVE.W	$1C(A0),D5
	CLR.W	D2
	MOVE.B	$17(A0),D2
	MOVE.W	0(A3,D2.W),D2
	MOVE.B	$18(A0),D3
	EXT.W	D3
	BMI.S	lbC00051A
	ADD.W	D3,D5
	CMP.W	D2,D5
	BLE.S	lbC000522
	MOVE.W	D2,D5
	BRA.S	lbC000522

lbC00051A	ADD.W	D3,D5
	CMP.W	D2,D5
	BGE.S	lbC000522
	MOVE.W	D2,D5
lbC000522	MOVE.W	D5,$1C(A0)
	BRA.S	lbC0004D6

lbC000528	CLR.W	D5
	MOVE.B	$19(A0),D5
	ADDQ.B	#1,D5
	CMPI.B	#3,D5
	BCS.S	lbC000538
	CLR.B	D5
lbC000538	MOVE.B	D5,$19(A0)
	LEA	$16(A0),A1
	MOVE.B	0(A1,D5.W),D5
	MOVE.W	0(A3,D5.W),D5
	MOVE.W	D5,$1C(A0)
	RTS

;lbC00054E	LEA	lbL0008B4(PC),A5
;	MOVE.L	A0,$B6(A5)
;	LEA	$D0(A5),A1
;	MOVE.L	A1,$BC(A5)
;	MOVE.B	D0,$D1(A5)
;	CLR.W	$BA(A5)
;	CLR.B	$26(A5)
;	CLR.B	$4E(A5)
;	CLR.B	$76(A5)
;	CLR.B	$9E(A5)
;	ST	$27(A5)
;	ST	$4F(A5)
;	ST	$77(A5)
;	ST	$9F(A5)
;	MOVE.W	#$8000,$B4(A5)
;	RTS

;lbC00058E	MOVEM.L	A5/A6,-(SP)
;	LEA	lbL0008B4(PC),A5
;	MOVEA.L	$BC(A5),A6
;	MOVE.W	D0,-(A6)
;	MOVE.L	A6,$BC(A5)
;	ADDQ.W	#1,$BA(A5)
;	MOVEM.L	(SP)+,A5/A6
;	RTS

;lbC0005AA	LEA	lbL0008B4(PC),A5
;	MOVEA.L	$B6(A5),A0
;	MOVEA.L	$BC(A5),A6
;lbC0005B6	TST.W	$BA(A5)
;	BEQ.S	lbC000608
;	SUBQ.W	#1,$BA(A5)
;	BSR.L	lbC00060E
;	MOVE.W	(A6)+,D3
;	CMP.B	11(A0,D3.W),D1
;	BGE.S	lbC0005B6
;	OR.W	D2,D7
;	MOVE.W	D2,$DFF096
;	MOVE.L	0(A0,D3.W),(A2)
;	MOVE.W	4(A0,D3.W),4(A2)
;	MOVE.W	6(A0,D3.W),6(A2)
;	MOVE.W	8(A0,D3.W),8(A2)
;	MOVE.B	11(A0,D3.W),(A1)
;	MOVE.L	0(A0,D3.W),$20(A3)
;	MOVE.W	4(A0,D3.W),$24(A3)
;	MOVE.B	10(A0,D3.W),1(A1)
;	LSL.W	#7,D2
;	OR.W	D2,$B4(A5)
;	BRA.S	lbC0005B6

;lbC000608	MOVE.L	A6,$BC(A5)
;	RTS

;lbC00060E	LEA	$26(A5),A1
;	MOVE.B	#$7F,D1
;	BTST	#0,$D1(A5)
;	BEQ.S	lbC000638
;	CMP.B	$26(A5),D1
;	BLE.S	lbC000638
;	LEA	$26(A5),A1
;	LEA	$DFF0A0,A2
;	LEA	(A5),A3
;	MOVE.B	$26(A5),D1
;	MOVE.W	#1,D2
;lbC000638	BTST	#1,$D1(A5)
;	BEQ.S	lbC00065C
;	CMP.B	$4E(A5),D1
;	BLE.S	lbC00065C
;	LEA	$4E(A5),A1
;	LEA	$DFF0B0,A2
;	LEA	$28(A5),A3
;	MOVE.B	$4E(A5),D1
;	MOVE.W	#2,D2
;lbC00065C	BTST	#2,$D1(A5)
;	BEQ.S	lbC000680
;	CMP.B	$76(A5),D1
;	BLE.S	lbC000680
;	LEA	$76(A5),A1
;	LEA	$DFF0C0,A2
;	LEA	$50(A5),A3
;	MOVE.B	$76(A5),D1
;	MOVE.W	#4,D2
;lbC000680	BTST	#3,$D1(A5)
;	BEQ.S	lbC0006A4
;	CMP.B	$9E(A5),D1
;	BLE.S	lbC0006A4
;	LEA	$9E(A5),A1
;	LEA	$DFF0D0,A2
;	LEA	$78(A5),A3
;	MOVE.B	$9E(A5),D1
;	MOVE.W	#8,D2
;lbC0006A4	RTS

lbC0006A6	BRA.L	lbC0003E6

	BRA.L	lbC000426

	BRA.L	lbC000430

	BRA.L	lbC00043A

	BRA.L	lbC000440

	BRA.L	lbC000444

	BRA.L	lbC000464

	BRA.L	lbC000474

	BRA.L	lbC000490

;lbC0006CA	MOVEM.L	D0-D7/A0-A6,-(SP)
;	LEA	$DFF000,A6
;	LEA	lbL0008B4(PC),A5
;	MOVE.W	$1E(A6),D0
;	AND.W	$1C(A6),D0
;	ANDI.W	#$780,D0
;	BTST	#7,D0
;	BEQ.S	lbC000706
;	SUBQ.B	#1,$27(A5)
;	BPL.S	lbC000706
;	MOVE.W	#$80,$9A(A6)
;	ANDI.W	#$FF7F,$B4(A5)
;	MOVE.W	#1,$96(A6)
;	CLR.B	$26(A5)
;lbC000706	BTST	#8,D0
;	BEQ.S	lbC000728
;	SUBQ.B	#1,$4F(A5)
;	BPL.S	lbC000728
;	MOVE.W	#$100,$9A(A6)
;	ANDI.W	#$FEFF,$B4(A5)
;	MOVE.W	#2,$96(A6)
;	CLR.B	$4E(A5)
;lbC000728	BTST	#9,D0
;	BEQ.S	lbC00074A
;	SUBQ.B	#1,$77(A5)
;	BPL.S	lbC00074A
;	MOVE.W	#$200,$9A(A6)
;	ANDI.W	#$FDFF,$B4(A5)
;	MOVE.W	#4,$96(A6)
;	CLR.B	$76(A5)
;lbC00074A	BTST	#10,D0
;	BEQ.S	lbC00076C
;	SUBQ.B	#1,$9F(A5)
;	BPL.S	lbC00076C
;	MOVE.W	#$400,$9A(A6)
;	ANDI.W	#$FBFF,$B4(A5)
;	MOVE.W	#8,$96(A6)
;	CLR.B	$9E(A5)
;lbC00076C	MOVE.W	D0,$9C(A6)
;	MOVEM.L	(SP)+,D0-D7/A0-A6
;	RTS

Play_2
;lbC000776	MOVEM.L	A5/A6,-(SP)
	LEA	$DFF000,A6
	LEA	lbL0008B4(PC),A5
;	NOT.W	$A6(A5)
;	BEQ.S	lbC0007A4

	bsr.w	DMAWait

	MOVE.W	$A8(A5),$96(A6)			; DMA on
;	MOVE.W	$B4(A5),$9A(A6)
;	MOVE.B	#$19,$BFDE00
;	MOVEM.L	(SP)+,A5/A6
;	RTS

	bsr.w	DMAWait

lbC0007A4	MOVE.L	$20(A5),$A0(A6)		; repeat part
	MOVE.W	$24(A5),$A4(A6)
	MOVE.L	$48(A5),$B0(A6)
	MOVE.W	$4C(A5),$B4(A6)
	MOVE.L	$70(A5),$C0(A6)
	MOVE.W	$74(A5),$C4(A6)
	MOVE.L	$98(A5),$D0(A6)
	MOVE.W	$9C(A5),$D4(A6)
;	MOVEM.L	(SP)+,A5/A6
	RTS

CMaximumEffec.MSG	dc.b	'(C) Maximum Effect'
lbW0007EC	dc.w	0
	dc.w	$18
	dc.w	$31
	dc.w	$4A
	dc.w	$61
	dc.w	$78
	dc.w	$8D
	dc.w	$A1
	dc.w	$B4
	dc.w	$C5
	dc.w	$D4
	dc.w	$E0
	dc.w	$EB
	dc.w	$F4
	dc.w	$FA
	dc.w	$FD
	dc.w	$FF
	dc.w	$FD
	dc.w	$FA
	dc.w	$F4
	dc.w	$EB
	dc.w	$E0
	dc.w	$D4
	dc.w	$C5
	dc.w	$B4
	dc.w	$A1
	dc.w	$8D
	dc.w	$78
	dc.w	$61
	dc.w	$4A
	dc.w	$31
	dc.w	$18
	dc.w	0
	dc.w	$FFE8
	dc.w	$FFCF
	dc.w	$FFB6
	dc.w	$FF9F
	dc.w	$FF88
	dc.w	$FF73
	dc.w	$FF5F
	dc.w	$FF4C
	dc.w	$FF3B
	dc.w	$FF2C
	dc.w	$FF20
	dc.w	$FF15
	dc.w	$FF0C
	dc.w	$FF06
	dc.w	$FF03
	dc.w	$FF01
	dc.w	$FF03
	dc.w	$FF06
	dc.w	$FF0C
	dc.w	$FF15
	dc.w	$FF20
	dc.w	$FF2C
	dc.w	$FF3B
	dc.w	$FF4C
	dc.w	$FF5F
	dc.w	$FF73
	dc.w	$FF88
	dc.w	$FF9F
	dc.w	$FFB6
	dc.w	$FFCF
	dc.w	$FFE8
lbW00086C	dc.w	$358
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
lbL0008B4
	ds.b	210

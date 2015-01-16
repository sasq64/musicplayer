	****************************************************
	****     Jason Page replayer for EaglePlayer	****
	****        all adaptions by Wanted Team,       ****
	****      DeliTracker compatible (?) version    ****
	****************************************************

	incdir	"dh2:include/"
	include 'misc/eagleplayer2.01.i'

	SECTION	Player_Code,CODE

	PLAYERHEADER Tags

	dc.b	'$VER: Jason Page player module V1.3 (26 June 2001)',0
	even
Tags
	dc.l	DTP_PlayerVersion,4
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
	dc.l	DTP_Volume,Volume
	dc.l	DTP_Balance,Balance
	dc.l	EP_Get_ModuleInfo,GetInfos
	dc.l	EP_StructInit,StructInit
	dc.l	EP_SampleInit,SampleInit
	dc.l	EP_Voices,SetVoices
	dc.l	EP_GetPositionNr,GetPosNr
	dc.l	EP_Flags,EPB_Songend!EPB_Restart!EPB_NextSong!EPB_PrevSong!EPB_Volume!EPB_Balance!EPB_Analyzer!EPB_ModuleInfo!EPB_SampleInfo!EPB_Packable!EPB_LoadFast!EPB_Voices
	dc.l	0

PlayerName
	dc.b	'Jason Page',0
Creator
	dc.b	'(c) 1991-95 by Jason Page,',10
	dc.b	'adapted by Mr.Larmer/WT & PP/Union',0
Prefix
	dc.b	'JPN.',0
	even
ModulePtr
	dc.l	0
Format
	dc.b	0
FormatNow
	dc.b	0
SamplePtr
	dc.l	0
EagleBase
	dc.l	0
Songend
	dc.l	'WTWT'
CurrentWord
	dc.w	0
Words
	dc.w	$5A
	dc.w	$5E
	dc.w	$5A
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
SampleBuf
	ds.b	32*4

***************************************************************************
********************************* EP_GetPosNr *****************************
***************************************************************************

GetPosNr
	moveq	#0,D0
	lea	FormatNow(PC),A2
	cmp.b	#1,(A2)				; FormatNow
	bne.b	.Pos2
	move.w	CurrentPos1(PC),D0
	bra.b	.Pos
.Pos2
	cmp.b	#2,(A2)				; FormatNow
	bne.b	.Pos3
	move.w	CurrentPos2(PC),D0
	bra.b	.Pos
.Pos3
	move.w	CurrentPos3(PC),D0
.Pos
	lsr.w	#1,D0
	addq.w	#1,D0
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
	moveq	#0,D7
	move.l	ModulePtr(pc),D0
	beq.w	.return
	move.l	D0,A2

	cmp.b	#3,FormatNow
	beq.b	.old

	move.l	A2,A6
	clr.l	d7
	move.w	2(A2),d7
	add.l	d7,A2
	move.w	48(a6),d7
	add.l	d7,A6
	subq.l	#4,A6
	sub.l	A2,A6
	lea	SampleBuf(pc),A2
	lea	(A2,A6.l),A6
	bra.b	.ok2
.old
	lea	SampleBuf(pc),A2
	lea	124(A2),A6
	lea	4(A6),A1
.ok2
	move.l	SamplePtr(PC),A4
	moveq	#EPR_NotEnoughMem,D7
	lea	EPG_SampleInfoStructure(A5),A3
.l1
	jsr	ENPP_AllocSampleStruct(A5)
	move.l	D0,(A3)
	beq.w	.return
	move.l	D0,A3

	cmp.b	#3,FormatNow
	beq.b	.old2

	move.l	(A2)+,D0
	btst	#0,D0
	beq.b	.ok
	addq.l	#1,D0
	bra.b	.ok
.old2
	cmp.l	A2,A6
	beq.b	.ok3

	move.l	4(A2),D0
	sub.l	(A2)+,D0
	bra.b	.ok
.ok3
	move.l	#128,D0
	addq.l	#4,A2
.ok
	move.l	A4,EPS_Adr(A3)
	move.l	D0,EPS_Length(A3)
	move.l	#64,EPS_Volume(A3)
	move.w	#USITY_RAW,EPS_Type(A3)
	move.w	#USIB_Playable!USIB_Saveable!USIB_8BIT,EPS_Flags(A3)

	add.l	D0,A4

	cmp.b	#3,FormatNow
	beq.b	.old3

	cmp.l	A2,A6
	bne.b	.l1
	bra.b	.ok4
.old3
	cmp.l	A2,A1
	bne.w	.l1
.ok4
	moveq	#0,D7
.return
	move.l	D7,D0
	rts

***************************************************************************
******************************* DTP_Check2 ********************************
***************************************************************************

Check2
	movea.l	dtg_ChkData(A5),A0
	moveq	#-1,D0

	lea	Format(PC),A2
	cmpi.w	#2,(A0)
	bne.s	CheckAnother
	btst	#0,3(A0)
	bne.s	CheckAnother
	move.w	4(A0),D1
	btst	#0,D1
	bne.s	CheckAnother
	tst.w	0(A0,D1.W)
	bne.s	CheckAnother
	move.w	$30(A0),D0
	lea	2(A0),A1
	moveq	#$16,D1
NextWord
	tst.w	(A1)
	beq.s	CheckAnother
	btst	#0,1(A1)
	bne.s	CheckAnother
	cmp.w	(A1)+,D0
	ble.s	CheckAnother
	dbra	D1,NextWord

	moveq	#0,d0
	move.w	$2E(a0),d0
	add.l	d0,a0
	move.w	(a0),d0
	and.w	#$0f00,d0
	cmp.w	#$0f00,d0
	bne.b	NewFormat

	move.b	#1,(A2)					;Format

	bra.b	OldFormat
NewFormat
	move.b	#2,(A2)					;Format
OldFormat
	bra.b	Found

CheckAnother
	tst.w	(A0)
	bne.b	Fault
	tst.l	$80(A0)
	bne.b	Fault
	cmpi.l	#$00000CBE,$84(A0)
	bne.b	Fault
	cmpi.l	#$000308BE,$CB6(A0)
	bne.b	Fault
	cmpi.l	#$000309BE,$CBA(A0)
	bne.b	Fault

	move.b	#3,(A2)					;Format
Found
	moveq	#0,D0
Fault
	rts

***************************************************************************
***************************** EP_Get_ModuleInfo ***************************
***************************************************************************

GetInfos
	lea	InfoBuffer(pc),A0
	rts

SubSongs	=	4
LoadSize	=	12
Songsize	=	20
SamplesSize	=	28
Samples		=	36
Length		=	44
Calcsize	=	52

InfoBuffer
	dc.l	MI_SubSongs,0		;4
	dc.l	MI_LoadSize,0		;12
	dc.l	MI_Songsize,0		;20
	dc.l	MI_SamplesSize,0	;28
	dc.l	MI_Samples,0		;36
	dc.l	MI_Length,0		;44
	dc.l	MI_Calcsize,0		;52
	dc.l	MI_MaxSamples,32
	dc.l	MI_MaxSubSongs,16
	dc.l	MI_Prefix,Prefix
	dc.l	0

***************************************************************************
******************************* DTP_ExtLoad *******************************
***************************************************************************

ExtLoad
	movea.l	dtg_PathArrayPtr(A5),A0
	clr.b	(A0)
	movea.l	dtg_CopyDir(A5),A0
	jsr	(A0)
	bsr.s	CopyName
	movea.l	dtg_LoadFile(A5),A0
	jmp	(A0)

CopyName
	movea.l	dtg_PathArrayPtr(A5),A0
	movea.l	A0,A2
loop
	tst.b	(A0)+
	bne.s	loop
	subq.l	#1,A0
	movea.l	A0,A3
	movea.l	dtg_FileArrayPtr(A5),A1
smp
	move.b	(A1)+,(A0)+
	bne.s	smp

	cmpi.b	#'J',(A3)
	beq.b	J_OK
	cmpi.b	#'j',(A3)
	bne.s	ExtError
J_OK
	cmpi.b	#'P',1(A3)
	beq.b	P_OK
	cmpi.b	#'p',1(A3)
	bne.s	ExtError
P_OK
	cmpi.b	#'N',2(A3)
	beq.b	N_OK
	cmpi.b	#'n',2(A3)
	bne.s	ExtError
N_OK
	cmpi.b	#'D',3(A3)
	beq.b	D_OK
	cmpi.b	#'d',3(A3)
	bne.s	NewPrefix
D_OK
	move.b	#'S',3(A3)

	bra.s	ExtOK
NewPrefix
	cmpi.b	#'.',3(A3)
	bne.s	ExtError

	move.b	#'S',(A3)+
	move.b	#'M',(A3)+
	move.b	#'P',(A3)

	bra.s	ExtOK
ExtError
	clr.b	-2(A0)
ExtOK
	clr.b	-1(A0)
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

	lea	ModulePtr(PC),A6
	move.l	A0,(A6)+			; module buffer
	move.b	(A6)+,(A6)+			; copy FormatNow

	lea	InfoBuffer(PC),A4
	move.l	D0,LoadSize(A4)

	lea	SampleBuf(PC),A3

	cmp.b	#3,-1(A6)			;FormatNow
	beq.w	.old

	clr.l	d0
	move.w	48(A0),D0
	move.l	D0,Songsize(A4)

	cmp.l	#7452,D0
	bne.s	.nofix1
	move.b	#$FF,1956(A0)		; fix for EmpireSoccer94
.nofix1
	cmp.l	#7054,D0
	bne.s	.nofix2
	move.b	#$FF,3490(A0)		; fix for ViroCop 01
.nofix2
	cmp.l	#6736,D0
	bne.s	.nofix3
	move.b	#$FF,3604(A0)		; fix for ViroCop 03
.nofix3
	cmp.l	#6260,D0
	bne.s	.nofix4
	move.b	#$FF,4088(A0)		; fix for ViroCop 09
.nofix4
	move.l	A0,A2
	add.l	D0,A2
	subq.l	#4,A2
	move.w	2(a0),d0
	add.l	d0,A0

	move.l	A0,-(A7)
	move.l	A2,D0
	sub.l	A0,D0
	lsr.l	#2,D0
	subq.l	#1,D0
.copy
	move.l	(A0)+,(A3)+
	dbf	D0,.copy
	move.l	(A7)+,A0

	moveq	#0,D0
	moveq	#0,D1
.l1
	tst.l	(A0)+
	beq.b	.empty
	add.l	-4(A0),D1
	btst	#0,D1
	beq.b	.ok
	addq.l	#1,D1
.ok
	addq.l	#1,D0
.empty
	cmp.l	A0,A2
	bne.b	.l1

	move.l	D0,Samples(A4)
	move.l	D1,SamplesSize(A4)
	add.l	Songsize(A4),D1
	move.l	D1,Calcsize(A4)
	bra.b	.ok2

.old
	move.l	2234(A0),D3
	addq.l	#2,D3
	move.l	D3,Songsize(A4)

	move.l	A0,-(A7)
	moveq	#31,D0
.copy2
	move.l	(A0)+,(A3)+
	dbf	D0,.copy2
	move.l	(A7)+,A0

	moveq	#0,D1
	moveq	#0,D2
	lea	124(A0),A2
.l2
	move.l	4(A0),D0
	sub.l	(A0)+,D0
	beq.b	.ok3
	add.l	D0,D1
	addq.l	#1,D2
.ok3
	cmp.l	A0,A2
	bne.b	.l2
	addq.l	#1,D2
	move.l	D2,Samples(A4)
	add.l	#128,D1
	move.l	D1,SamplesSize(A4)
	add.l	Songsize(A4),D1
	move.l	D1,Calcsize(A4)
.ok2
	moveq	#1,D0
	movea.l	dtg_GetListData(A5),A0
	jsr	(A0)

	move.l	A0,(A6)+			; sample buffer
	add.l	D0,LoadSize(A4)

	move.l	ModulePtr(PC),A0
	cmp.b	#3,FormatNow
	bne.b	.next
	cmp.l	#7382,D3			; patch for Realms ingame
	bne.b	.NoPatch
	move.l	A0,A1
	move.l	A0,A3
	add.l	1726(A1),A1

.loop3	cmp.b	#$FC,(A1)
	beq.s	.patch
	cmp.b	#$FE,(A1)
	beq.s	.patch
	cmp.b	#$FD,(A1)
	beq.s	.patch
	cmp.w	#$FF00,(A1)
	beq.s	.NoPatch
.retry
	addq.l	#2,A1
	bra.b	.loop3
.patch
	moveq	#3,D2
.patch2	
	move.l	A1,A2
	sub.l	A0,A2
	addq.l	#2,A2
	move.l	A2,1730(A3)
	move.w	#$FF00,(A1)
	lea	194(A1),A1
	lea	128(A3),A3
	dbf	D2,.patch2
	lea	-776(A1),A1
	lea	-508(A3),A3
	bra.b	.retry

.NoPatch
	moveq	#0,D1
	lea	$6be(a0),a1
.loop	move.l	(a1)+,d0
	cmp.w	#$ff00,(a0,d0.l)
	beq.s	.ok4
	add.l	#1,d1
	bra.s	.loop

.next
	move.l	A0,A1
	add.w	$C(A0),A0
	addq.w	#2,A0
	add.w	$1C(A1),A1
	sub.l	A0,A1
	move.l	A1,D1
	lsr.l	#1,D1
.ok4
	move.l	D1,SubSongs(A4)

	lea	CurrentWord(PC),A2

	moveq	#0,D0
	move.b	FormatNow(PC),D0
	add.l	D0,D0
	move.w	(A2,D0.W),(A2)

	move.l	A5,(A6)				;EagleBase

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

	lea	Songend(PC),A0
	move.l	#'WTWT',(A0)

	move.l	ModulePtr(pc),a1
	move.l	SamplePtr(pc),a0

	lea	FormatNow(PC),A2

	cmp.b	#1,(A2)					;FormatNow
	bne.b	.next1

	bsr.w	Initialize_1_1

	moveq	#0,D0
	move.l	EagleBase(pc),a5
	move.w	dtg_SndNum(A5),D0

	bsr.b	.SongLength

	bsr.w	Initialize_1_2

	moveq	#-1,D0
	moveq	#-1,D1
	bra.w	Initialize_1_3

.SongLength
	move.l	D0,D2
	move.l	ModulePtr(PC),A2
	move.l	A2,A3
	move.l	A2,A4
	add.w	12(A2),A3
.next_2
	move.l	A4,A2
	add.w	28(A2),A2
	add.w	(A3),A2
	moveq	#0,D4
.jump
	cmp.b	#$FF,(A2)
	beq.s	.oki2
	cmp.b	#$FE,(A2)
	beq.b	.oki3

.jump1	addq.l	#2,A2
	addq.l	#1,D4
	bra.s	.jump
.oki3
	tst.b	1(A2)
	bne.b	.jump1
	addq.l	#1,D4
.oki2
	addq.l	#2,A3
	dbf	D2,.next_2

	lea	InfoBuffer(PC),A1
	move.l	D4,Length(A1)
	rts

.next1
	cmp.b	#2,(A2)					;FormatNow
	bne.b	.next2

	bsr.w	Initialize_2_1

	moveq	#0,D0
	move.l	EagleBase(pc),a5
	move.w	dtg_SndNum(A5),D0

	bsr.b	.SongLength

	bsr.w	Initialize_2_2

	moveq	#-1,D0
	moveq	#-1,D1
	bra.w	Initialize_2_3

.next2
	move.l	a1,lbL002D88
	move.l	a0,lbL002DC4

	tst.w	(A1)
	bne.s	.initdone
	bsr.w	Initialize_3_1
.initdone
	moveq	#0,D0
	move.l	EagleBase(pc),a5
	move.w	dtg_SndNum(A5),D0

	move.l	D0,D5
	move.l	ModulePtr(PC),A2
	move.l	A2,A3
.Retry
	moveq	#0,D4
	move.l	1726(A3),D3
	move.l	D3,A2
.loop2
	cmp.b	#$FF,(A2)
	beq.s	.oki
	addq.l	#2,A2
	addq.l	#1,D4
	bra.s	.loop2
.oki	
	addq.l	#4,A3
	dbf	D5,.Retry

	lea	InfoBuffer(PC),A1
	move.l	D4,Length(A1)

	bsr.w	Initialize_3_2

	moveq	#-1,D0
	moveq	#-1,D1
	bra.w	Initialize_3_3

***************************************************************************
***************************** DTP_EndSound ********************************
***************************************************************************

EndSound
	lea	FormatNow(PC),A2
	cmp.b	#1,(A2)				;FormatNow
	bne.b	.next1
	bra.w	End_1
.next1
	cmp.b	#2,(A2)				;FormatNow
	bne.b	.next2
	bra.w	End_2
.next2
	bra.w	End_3

***************************************************************************
***************************** DTP_Interrupt *******************************
***************************************************************************

Interrupt
	movem.l	d0-a6,-(a7)

	lea	StructAdr(PC),A5
	st	UPS_Enabled(A5)
	move.w	#UPSB_Adr!UPSB_Len!UPSB_Per!UPSB_Vol,UPS_Flags(a5)

	clr.w	UPS_Voice1Per(a5)
	clr.w	UPS_Voice2Per(a5)
	clr.w	UPS_Voice3Per(a5)
	clr.w	UPS_Voice4Per(a5)

	lea	FormatNow(PC),A2
	cmp.b	#1,(A2)				;FormatNow
	bne.b	.next10

	bsr.w	Play_1

	tst.w	lbW00008E
	bmi.b	.endmod1
	bra.b	.next12
.endmod1
	bsr.b	SongEnd
	bsr.w	InitSound

	bra.b	.next12
.next10
	cmp.b	#2,(A2)				; FormatNow
	bne.b	.next11

	bsr.w	Play_2

	tst.w	lbW001086
	bmi.b	.endmod2
	bra.b	.next12
.endmod2
	bsr.b	SongEnd
	bsr.w	InitSound

	bra.b	.next12
.next11
	bsr.w	Play_3

	tst.w	lbW002DE0
	bmi.b	.endmod3
	bra.b	.next12
.endmod3
	bsr.b	SongEnd
	bsr.w	InitSound
.next12
	lea	StructAdr(PC),A5
	clr.w	UPS_Enabled(A5)

	movem.l	(a7)+,d0-a6
	rts

SongEnd
	move.l	EagleBase(PC),A5
	move.l	dtg_SongEnd(A5),A1
	jsr	(A1)
	rts

SongEndTest
	movem.l	D0/A1/A3/A5,-(A7)
	lea	Songend(PC),A1
	move.w	CurrentWord(PC),D0
	lea	(A2,D0.W),A3
	tst.w	(A3)
	bne.b	test1
	clr.b	(A1)
	bra.b	test
test1
	cmp.w	#2,(A3)
	bne.b	test2
	clr.b	1(A1)
	bra.b	test
test2
	cmp.w	#4,(A3)
	bne.b	test3
	clr.b	2(A1)
	bra.b	test
test3
	cmp.w	#6,(A3)
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
	movem.l	(A7)+,D0/A1/A3/A5
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
******************** DTP_Volume DTP_Balance *******************************
***************************************************************************

Volume
Balance
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
	move.l	A0,D1
	cmp.w	#$F000,D1
	beq.s	Left1
	cmp.w	#$F010,D1
	beq.s	Right1
	cmp.w	#$F020,D1
	beq.s	Right2
	cmp.w	#$F030,D1
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
	move.l	(A7)+,D1
	rts

***************************************************************************
****************************** EP_Voices **********************************
***************************************************************************

SetVoices
	lea	Voice1(pc),a0
	lea	StructAdr(pc),a1
	move.w	#$ffff,d1
	move.w	d1,(a0)+			Voice1=0 setzen
	btst	#0,d0
	bne.s	.NoVoice1
	clr.w	-2(a0)
	clr.w	$dff0a8
	clr.w	UPS_Voice1Vol(a1)
.NoVoice1
	move.w	d1,(a0)+			Voice2=0 setzen
	btst	#1,d0
	bne.s	.NoVoice2
	clr.w	-2(a0)
	clr.w	$dff0b8
	clr.w	UPS_Voice2Vol(a1)
.NoVoice2
	move.w	d1,(a0)+			Voice3=0 setzen
	btst	#2,d0
	bne.s	.NoVoice3
	clr.w	-2(a0)
	clr.w	$dff0c8
	clr.w	UPS_Voice3Vol(a1)
.NoVoice3
	move.w	d1,(a0)+			Voice4=0 setzen
	btst	#3,d0
	bne.s	.NoVoice4
	clr.w	-2(a0)
	clr.w	$dff0d8
	clr.w	UPS_Voice4Vol(a1)
.NoVoice4
	move.w	d0,UPS_DMACon(a1)
	moveq	#0,d0
	rts

***************************************************************************
******************** Analyzer code ****************************************
***************************************************************************

lenoffset
	dc.l	0

;New analyzer code...vvv

analyzer:
	movem.l	d0/a1/a3,-(sp)
	move.l	a2,a3
	add.l	lenoffset,a3
	lea	StructAdr(pc),a1
	move.b	$2e(a2),d0
	lsr.b	#2,d0
	and.w	#$ff,d0
.ckv1	cmp.l	#$dff000,a0
 	bne.b	.ckv2
	and.w	Voice1(PC),d0
	move.w	d0,UPS_Voice1Vol(a1)
	move.l	d1,UPS_Voice1Adr(a1)
	move.w	(a3),UPS_Voice1Len(a1)
	move.w	$2a(a2),UPS_Voice1Per(a1)
	clr.w	UPS_Voice1Repeat(a1)
.ckv2	cmp.l	#$dff010,a0
	bne.b	.ckv3
	and.w	Voice2(PC),d0
	move.w	d0,UPS_Voice2Vol(a1)
	move.l	d1,UPS_Voice2Adr(a1)
	move.w	(a3),UPS_Voice2Len(a1)
	move.w	$2a(a2),UPS_Voice2Per(a1)
	clr.w	UPS_Voice2Repeat(a1)
.ckv3	cmp.l	#$dff020,a0
	bne.b	.ckv4
	and.w	Voice3(PC),d0
	move.w	d0,UPS_Voice3Vol(a1)
	move.l	d1,UPS_Voice3Adr(a1)
	move.w	(a3),UPS_Voice3Len(a1)
	move.w	$2a(a2),UPS_Voice3Per(a1)
	clr.w	UPS_Voice3Repeat(a1)
.ckv4	cmp.l	#$dff030,a0			;some safety here
	bne.b	.rangeout
	and.w	Voice4(PC),d0
	move.w	d0,UPS_Voice4Vol(a1)
	move.l	d1,UPS_Voice4Adr(a1)
	move.w	(a3),UPS_Voice4Len(a1)
	move.w	$2a(a2),UPS_Voice4Per(a1)
	clr.w	UPS_Voice4Repeat(a1)
.rangeout
	movem.l	(sp)+,d0/a1/a3
	rts
;End of new code...

analyzer_2:

;New analyzer code
	movem.l	d0/a1,-(sp)
	lea	StructAdr(pc),a1
	move.b	$2e(a2),d0
	lsr.b	#2,d0
	and.w	#$ff,d0
.ckv12	cmp.l	#$dff000,a0
	bne.b	.ckv22
	and.w	Voice1(PC),d0
	move.w	d0,UPS_Voice1Vol(a1)
	move.w	#1,UPS_Voice1Repeat(a1)
.ckv22	cmp.l	#$dff010,a0
	bne.b	.ckv32
	and.w	Voice2(PC),d0
	move.w	d0,UPS_Voice2Vol(a1)
	move.w	#1,UPS_Voice2Repeat(a1)
.ckv32	cmp.l	#$dff020,a0
	bne.b	.ckv42
	and.w	Voice3(PC),d0
	move.w	d0,UPS_Voice3Vol(a1)
	move.w	#1,UPS_Voice3Repeat(a1)
.ckv42	cmp.l	#$dff030,a0			;some safety here
	bne.b	.rangeout2
	and.w	Voice4(PC),d0
	move.w	d0,UPS_Voice4Vol(a1)
	move.w	#1,UPS_Voice4Repeat(a1)
.rangeout2
	movem.l	(sp)+,d0/a1

;	bsr.w	DMAWait

	move.w	#1,$A4(A0) 		;l
	move.l	lbL00007C(PC),$A0(A0) 	;a
	move.w	$2A(A2),$A6(A0) 	;p
	rts
;End of new code...

***************************************************************************
**************************** Jason Page player ****************************
***************************************************************************

; player from game Empire Soccer 94

lbL000000:
	dc.l	0,0,0
lbL00000C:
	dc.l	0
lbL000010:
	dc.l	0
lbL000014:
	dc.l	0
lbL000018:
	dc.l	0
lbL00001C:
	dc.l	0
lbL000020:
	dc.l	0
lbL000024:
	dc.l	0
lbL000028:
	dc.l	0
lbL00002C:
	dc.l	0
lbL000030:
	dc.l	0,0,0,0,0
lbL000044:
	dc.l	0
lbL000048:
	dc.l	0
lbL00004C:
	dc.l	0
lbL000050:
	dc.l	0,0,0,0,0
lbL000064:
	dc.l	0
lbL000068:
	dc.l	0
lbL00006C:
	dc.l	0
lbL000070:
	dc.l	0
lbL000074:
	dc.l	0
lbL000078:
	dc.l	0
lbL00007C:
	dc.l	Empty
lbW000080:
	dc.w	0
lbW000082:
	dc.w	$FFFF
lbW000084:
	dc.w	$FFFF
lbW000086:
	dc.w	$FFFF
lbW000088:
	dc.w	$FFFF
lbW00008A:
	dc.w	$FFFF
lbW00008C:
	dc.w	$FFFF
lbW00008E:
	dc.w	$FFFF
lbB000090:
	dc.b	0
lbB000091:
	dc.b	0
lbB000092:
	dc.b	0
lbB000093:
	dc.b	0
lbW000094:
	dc.w	0
lbW000096:
	dc.w	0
lbL000098:
	dc.l	lbW0000A8,lbW0000CA,lbW0000EC,lbW00010E
lbW0000A8:
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
lbW0000CA:
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
lbW0000EC:
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
lbW00010E:
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
lbW000130:
	dc.w	0
	dc.l	lbL000D0C,0,0,0,0,0,0,0,0,0,0,$8000000,0,0,0
	dc.l	$FFFF,0,$FFFFFFFF,$FFFFFFFF
	dc.w	0
CurrentPos1
	dc.w	0
	dc.l	0,$1010000,0
	dc.l	lbL000D0C,0,0,0,0,0,0,0,0,0,0,$9000000,0,0,0
	dc.l	$FFFF,0,$FFFFFFFF,$FFFFFFFF,0,0,$1010000,$20000
	dc.l	lbL000D0C,0,0,0,0,0,0,0,0,0,0,$A000000,0,0,0
	dc.l	$FFFF,0,$FFFFFFFF,$FFFFFFFF
	dc.w	0
	dc.w	0
	dc.l	0,$1010000,$40000
	dc.l	lbL000D0C,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.l	$FFFF,0,$FFFFFFFF,$FFFFFFFF,0,0,$1010000
	dc.w	6
lbW0002A0:
	dc.w	$EEE,$E17,$D4D,$C8E,$BD9,$B2F,$A8E,$9F7,$967,$8E0
	dc.w	$861,$7E8,$777,$70B,$6A6,$647,$5EC,$597,$547,$4FB
	dc.w	$4B3,$470,$430,$3F4,$3BB,$385,$353,$323,$2F6,$2CB
	dc.w	$2A3,$27D,$25A,$238,$218,$1FA,$1DD,$1C3,$1A9,$191
	dc.w	$17B,$165,$151,$13E,$12D,$11C,$10C,$FD,$EE,$E1
	dc.w	$D4,$C8,$BD,$B3,$A8,$9F,$96,$8E,$86,$7E,$77,$70
	dc.w	$6A,$64,$5E,$59,$54,$4F,$4B,$47,$43,$3F,$3B,$38
	dc.w	$35,$32,$2F,$2C,$2A,$27,$25,$23,$21,$1F

Play_1
	movem.l	D0/D1/D7/A0/A1,-(SP)
	bsr.w	lbC00074C
	bsr.w	lbC0008EE
	movem.l	(SP)+,D0/D1/D7/A0/A1
	rts
Initialize_1_1
	movem.l	A2/A3,-(SP)
	move.l	A0,lbL000068
	move.l	A1,lbL000000
	movea.l	A1,A0
	movea.l	A1,A2
	addq.w	#2,A0
	move.w	(A0)+,D0
	adda.w	D0,A1
	move.l	A1,lbL000064
	move.l	D0,-(SP)
	movea.l	A2,A1
	adda.w	(A0)+,A1
	move.l	A1,lbL00000C
	movea.l	A2,A1
	adda.w	(A0)+,A1
	move.l	A1,lbL000010
	movea.l	A2,A1
	adda.w	(A0)+,A1
	move.l	A1,lbL000014
	movea.l	A2,A1
	adda.w	(A0)+,A1
	move.l	A1,lbL000018
	lea	lbL000024,A3
	move.w	#7,D1
lbC0003AE:
	movea.l	A2,A1
	adda.w	(A0)+,A1
	move.l	A1,(A3)+
	dbra	D1,lbC0003AE
	lea	lbL000044,A3
	move.w	#7,D1
lbC0003C2:
	movea.l	A2,A1
	adda.w	(A0)+,A1
	move.l	A1,(A3)+
	dbra	D1,lbC0003C2
	movea.l	A2,A1
	adda.w	(A0)+,A1
	move.l	A1,lbL00001C
	movea.l	A2,A1
	adda.w	(A0)+,A1
	move.l	A1,lbL000020
	move.l	(SP)+,D0
	move.w	(A0),D1
	sub.w	D0,D1
	lsr.w	#2,D1
	move.w	D1,lbW000080
	bsr.b	lbC0003FC
	bsr.w	lbC0005A2
	movem.l	(SP)+,A2/A3
	rts

lbC0003FC:
	movea.l	lbL000000,A0
	bset	#7,(A0)
	bne.s	lbC000422
	movea.l	lbL000064(PC),A1
	movea.l	lbL000068(PC),A0
	move.w	lbW000080(PC),D0
	beq.s	lbC000422
	subq.w	#1,D0
lbC000418:
	move.l	(A1),D1
	move.l	A0,(A1)+
	adda.l	D1,A0
	dbra	D0,lbC000418
lbC000422:
	rts
Initialize_1_2
	move.l	D2,-(SP)
	move.w	D0,D2
	bclr	#7,D2
	beq.s	lbC000432
	bsr.w	lbC000562
lbC000432:
	move.w	#$FFFF,lbW00008E
	btst	#6,D2
	beq.s	lbC00044E
	bsr.w	lbC000512
	move.w	D0,D2
	bmi.s	lbC000490
	bsr.b	lbC00049A
	bra.s	lbC00048C

lbC00044E:
	bsr.b	lbC00049A
	moveq	#-1,D1
	lea	lbL000D0C(PC),A1
	moveq	#0,D7
	move.w	D2,D7
	lsr.w	#7,D7
	andi.w	#$FFFE,D7
	lea	lbW000130(PC),A0
	moveq	#3,D0
lbC000468:
	move.l	A1,2(A0)
	move.w	D7,$50(A0)
	clr.w	$52(A0)
	clr.w	$54(A0)
	clr.w	$56(A0)
	clr.w	$44(A0)
	move.w	D1,$40(A0)
	lea	$5C(A0),A0
	dbra	D0,lbC000468
lbC00048C:
	bsr.w	lbC0005A2
lbC000490:
	move.w	D2,lbW00008E
	move.l	(SP)+,D2
	rts

lbC00049A:
	move.w	#$FFFF,lbW000082
	andi.w	#15,D0
	add.w	D0,D0
	movea.l	lbL000014(PC),A0
	move.w	0(A0,D0.W),D1
	andi.w	#$FF,D1
	move.w	D1,lbW000096
	clr.w	lbW000094
	movea.l	lbL000024(PC),A0
	move.w	0(A0,D0.W),D1
	movea.l	lbL000044(PC),A0
	adda.w	D1,A0
	move.l	A0,lbL00006C
	movea.l	lbL000028(PC),A0
	move.w	0(A0,D0.W),D1
	movea.l	lbL000048(PC),A0
	adda.w	D1,A0
	move.l	A0,lbL000070
	movea.l	lbL00002C(PC),A0
	move.w	0(A0,D0.W),D1
	movea.l	lbL00004C(PC),A0
	adda.w	D1,A0
	move.l	A0,lbL000074
	movea.l	lbL000030(PC),A0
	move.w	0(A0,D0.W),D1
	movea.l	lbL000050(PC),A0
	adda.w	D1,A0
	move.l	A0,lbL000078
	rts

lbC000512:
	lsr.w	#2,D0
	andi.w	#12,D0
	lea	lbL000098,A0
	movea.l	0(A0,D0.W),A0
	lea	lbW000130(PC),A1
	moveq	#3,D0
lbC000528:
	move.w	(A0),$50(A1)
	move.w	2(A0),$52(A1)
	move.w	4(A0),(A1)
	move.w	6(A0),$56(A1)
	move.l	#lbL000D0C,2(A1)
	clr.w	$54(A0)
	clr.w	$44(A0)
	move.w	#$FFFF,$40(A0)
	lea	8(A0),A0
	lea	$5C(A1),A1
	dbra	D0,lbC000528
	move.w	(A0),D0
	rts

lbC000562:
	move.l	D0,-(SP)
	lsr.w	#2,D0
	andi.w	#12,D0
	lea	lbL000098,A0
	movea.l	0(A0,D0.W),A0
	lea	lbW000130(PC),A1
	moveq	#3,D0
lbC00057A:
	move.w	$50(A1),(A0)
	move.w	$52(A1),2(A0)
	move.w	(A1),4(A0)
	move.w	$56(A1),6(A0)
	lea	8(A0),A0
	lea	$5C(A1),A1
	dbra	D0,lbC00057A
	move.w	lbW00008E(PC),(A0)
	move.l	(SP)+,D0
	rts

lbC0005A2:
	rts
End_1
	movem.l	D3/A2,-(SP)
	clr.w	lbB000092
	clr.w	lbB000090
	moveq	#-1,D0
	move.w	D0,lbW00008E
	move.w	D0,lbW000086
	move.w	D0,lbW000088
	move.w	D0,lbW00008A
	move.w	D0,lbW00008C
	tst.l	lbL000000
	beq.s	lbC000600
	lea	lbW000130(PC),A2
	moveq	#0,D3
lbC0005E2:
	moveq	#0,D0
	bsr.w	lbC0006DE
	clr.w	$44(A2)
	lea	lbL000D0C(PC),A1
	move.l	A1,2(A2)
	lea	$5C(A2),A2
	addq.w	#1,D3
	cmpi.w	#4,D3
	blt.s	lbC0005E2
lbC000600:
	movem.l	(SP)+,D3/A2
	rts

;	andi.w	#$FF,D0
;	move.w	D0,lbB000090
;	move.w	D0,lbB000092
;	rts
Initialize_1_3
	move.b	D1,lbB000092
	move.b	D0,lbB000093
	rts

;	move.w	D0,lbW000096
;	bne.s	lbC000648
;	movea.l	lbL000014(PC),A0
;	moveq	#15,D0
;	and.w	lbW00008E(PC),D0
;	add.w	D0,D0
;	move.w	0(A0,D0.W),D0
;	andi.w	#$FF,D0
;	move.w	D0,lbW000096
;lbC000648:
;	clr.w	lbW000094
;	rts

;	movem.l	D2/D3,-(SP)
;	move.l	D0,D2
;	move.l	D1,D3
;	moveq	#0,D1
;	bsr.s	lbC000678
;	swap	D2
;	move.w	D2,D0
;	moveq	#1,D1
;	bsr.s	lbC000678
;	move.w	D3,D0
;	moveq	#2,D1
;	bsr.s	lbC000678
;	swap	D3
;	move.w	D3,D0
;	moveq	#3,D1
;	bsr.s	lbC000678
;	movem.l	(SP)+,D2/D3
;	rts

lbC000678:
	cmpi.b	#$FF,D0
	beq.s	lbC0006B8
	ext.w	D1
	add.w	D1,D1
	lea	lbW000130(PC),A0
	adda.w	lbW0006BC(PC,D1.W),A0
	movea.l	lbL000018(PC),A1
	moveq	#0,D1
	move.b	D0,D1
	add.b	D1,D1
	move.w	0(A1,D1.W),D1
	andi.w	#$FF,D1
	cmp.w	$44(A0),D1
	bcs.s	lbC0006B8
	move.w	D1,$44(A0)
	move.w	D0,D1
	lsr.w	#8,D1
	andi.w	#$FF,D0
	move.w	D0,$40(A0)
	move.w	D1,$42(A0)
	rts

lbC0006B8:
	moveq	#-1,D0
	rts

lbW0006BC:
	dc.w	0,$5C,$B8,$114

lbC0006C4:
	move.w	$42(A2),D0
	beq.s	lbC0006D2
	subq.w	#1,D0
	move.w	D0,$42(A2)
	rts

lbC0006D2:
	move.w	$40(A2),D0
	cmpi.b	#$FF,D0
	bne.s	lbC0006DE
	rts

lbC0006DE:
	move.l	D0,-(SP)
	bsr.w	lbC000B7E
	move.l	(SP)+,D0
	move.w	$5A(A2),D7
	lea	lbW000086,A0
	move.w	D0,0(A0,D7.W)
	clr.w	6(A2)
	clr.w	$2E(A2)
	clr.w	$24(A2)
	clr.w	$28(A2)
	clr.w	$26(A2)
	clr.w	$2C(A2)
	clr.w	8(A2)
	clr.w	10(A2)
	moveq	#-1,D1
	move.w	D1,$40(A2)
	move.w	D1,$46(A2)
	move.w	D1,$48(A2)
	move.w	D1,$4A(A2)
	move.w	D1,$4C(A2)
	andi.l	#$FF,D0
	add.w	D0,D0
	movea.l	lbL00000C(PC),A0
	move.w	0(A0,D0.W),D0
	movea.l	lbL000010(PC),A0
	adda.w	D0,A0
	move.l	A0,2(A2)
	moveq	#0,D0
	move.l	D0,$3C(A2)
	rts

lbC00074C:
	tst.w	lbW00008E
	bmi.s	lbC00075C
	subq.w	#1,lbW000094
	bmi.s	lbC00075E
lbC00075C:
	rts

lbC00075E:
	movem.l	D2/D3/A2/A3,-(SP)
	move.w	lbW000096(PC),lbW000094
	lea	lbW000130(PC),A2
	moveq	#0,D3
	move.w	lbW000082(PC),lbW000084
lbC000778:
	subq.b	#1,$56(A2)
	bpl.w	lbC0008DA
	move.b	$57(A2),$56(A2)
lbC000786:
	move.w	D3,D0
	add.w	D0,D0
	add.w	D0,D0
	lea	lbL00006C(PC),A0
	movea.l	0(A0,D0.W),A0
	move.w	$50(A2),D0
	move.w	0(A0,D0.W),D0
	move.b	D0,$53(A2)
	lsr.w	#8,D0
	cmpi.b	#$FF,D0
	bne.s	lbC0007B4
	move.w	#$FFFF,lbW00008E
	bra.w	lbC0008E8

lbC0007B4:
	cmpi.b	#$FE,D0
	bne.s	lbC0007CA
lbC0007BA:

		bsr.w	SongEndTest

	move.b	$53(A2),D0
lbC0007BE:
	andi.w	#$FF,D0
	add.w	D0,D0
	move.w	D0,$50(A2)
	bra.s	lbC000786

lbC0007CA:
	cmpi.b	#$FC,D0
	bne.s	lbC0007E4
	move.w	lbW000084(PC),D0
	cmpi.w	#$FFFF,D0
	beq.s	lbC0007BA
	move.w	#$FFFF,lbW000082
	bra.s	lbC0007BE

lbC0007E4:
	cmpi.b	#$FD,D0
	bne.s	lbC000804
	move.w	lbW000084(PC),D0
	cmpi.w	#$FFFF,D0
	beq.s	lbC0007FE
	move.w	#$FFFF,lbW000082
	bra.s	lbC0007BE

lbC0007FE:
	addq.w	#2,$50(A2)
	bra.W	lbC000786

lbC000804:
	add.w	D0,D0
	movea.l	lbL00001C(PC),A0
	move.w	0(A0,D0.W),D0
	movea.l	lbL000020(PC),A0
	adda.w	D0,A0
lbC000814:
	move.b	$52(A2),D0
	andi.w	#$FF,D0
	move.b	0(A0,D0.W),D0
	cmpi.b	#$F9,D0
	bcs.s	lbC00086E
	cmpi.b	#$FF,D0
	bne.s	lbC000838
	clr.b	$52(A2)
	addq.w	#2,$50(A2)
	bra.w	lbC000786

lbC000838:
	cmpi.b	#$F9,D0
	bne.s	lbC000846
	addq.b	#1,$52(A2)
	bra.w	lbC0008DA

lbC000846:
	cmpi.b	#$FE,D0
	bne.s	lbC00086E
	move.b	$52(A2),D0
	andi.w	#$FF,D0
	addq.w	#1,D0
	move.b	0(A0,D0.W),D1
	asl.w	#8,D1
	addq.w	#1,D0
	move.b	0(A0,D0.W),D1
	move.w	D1,$2C(A2)
	addq.b	#3,$52(A2)
	bra.b	lbC0008DA

lbC00086E:
	tst.b	D0
	bpl.s	lbC00087E
	andi.w	#$7F,D0
	move.w	D0,(A2)
	addq.b	#1,$52(A2)
	bra.s	lbC000814

lbC00087E:
	btst	#6,D0
	beq.s	lbC000898
	andi.w	#$3F,D0
	move.b	D0,$57(A2)
	move.b	D0,$56(A2)
	addq.b	#1,$52(A2)
	bra.b	lbC000814

lbC000898:
	andi.w	#$FF,D0
	move.w	D3,D1
	move.w	D0,D2
	move.w	(A2),D0
	cmpi.w	#$78,D0
	beq.s	lbC0008B2
	bsr.w	lbC000678
	cmpi.b	#$FF,D0
	beq.s	lbC0008D6
lbC0008B2:
	move.w	D2,D0
	add.b	$53(A2),D0
	cmpi.b	#$54,D0
	blt.s	lbC0008C0
	moveq	#$54,D0
lbC0008C0:
	move.w	D0,$54(A2)
	add.w	D0,D0
	lea	lbW0002A0(PC),A0
	andi.w	#$FF,D0
	move.w	0(A0,D0.W),D0
	move.w	D0,$2A(A2)
lbC0008D6:
	addq.b	#1,$52(A2)
lbC0008DA:
	lea	$5C(A2),A2
	addq.w	#1,D3
	cmpi.w	#4,D3
	blt.w	lbC000778
lbC0008E8:
	movem.l	(SP)+,D2/D3/A2/A3
	rts

lbC0008EE:
	movem.l	D2/D3/A2/A3,-(SP)
	moveq	#0,D0
	moveq	#0,D1
	moveq	#0,D7
	move.b	lbB000091(PC),D0
	move.b	lbB000093(PC),D7
	move.b	lbB000092(PC),D1
	beq.s	lbC000920
	cmp.w	D7,D0
	blt.s	lbC00091A
	sub.w	D1,D0
	cmp.w	D7,D0
	bgt.s	lbC000920
lbC000910:
	move.w	D7,D0
	clr.b	lbB000092
	bra.s	lbC000920

lbC00091A:
	add.w	D1,D0
	cmp.w	D7,D0
	bge.s	lbC000910
lbC000920:
	move.b	D0,lbB000091
	moveq	#0,D3
	lea	lbW000130(PC),A2
lbC00092C:
	bsr.w	lbC0006C4
	tst.w	6(A2)
	beq.s	lbC00093C
	subq.w	#1,6(A2)
	bne.s	lbC00095A
lbC00093C:
	movea.l	2(A2),A3
	moveq	#0,D2
lbC000942:
	move.w	(A3)+,D0
	andi.w	#$FF,D0
	add.w	D0,D0
	add.w	D0,D0
	movea.l	lbL00098A(PC,D0.W),A0
	jsr	(A0)
	tst.w	D2
	beq.s	lbC000942
	move.l	A3,2(A2)
lbC00095A:
	bsr.w	lbC000AF0
	bsr.w	lbC000A7A
	lea	$5C(A2),A2
	addq.w	#1,D3
	cmpi.w	#4,D3
	blt.s	lbC00092C
	moveq	#0,D3
	lea	lbW000130(PC),A2
lbC000974:
	bsr.b	lbC0009EA
	lea	$5C(A2),A2
	addq.w	#1,D3
	cmpi.w	#4,D3
	blt.s	lbC000974
	movem.l	(SP)+,D2/D3/A2/A3
	rts

lbL00098A:
	dc.l	lbC000C30,lbC000C30,lbC000BAC,lbC000BC4,lbC000BD4
	dc.l	lbC000BE4,lbC000BEC,lbC000C0A,lbC000C3E,lbC000C46
	dc.l	lbC000C50,lbC000C58,lbC000C60,lbC000C68,lbC000B46
	dc.l	lbC000B4C,lbC000B68,lbC000B7E,lbC000BE8,lbC000B52
	dc.l	lbC000B1A,lbC000B32,lbC000C82,lbC000CDE

lbC0009EA:
	moveq	#0,D1
	move.b	lbB000091(PC),D1
	lsr.b	#2,D1
	moveq	#0,D0
	move.b	$2E(A2),D0
	lsr.b	#2,D0
	cmp.b	D1,D0
	ble.s	lbC000A00
	move.b	D1,D0
lbC000A00:
	lea	$DFF000,A0
	move.w	D3,D7
	lsl.w	#4,D7
	adda.w	D7,A0
;	lsr.w	#1,D0

	bsr.w	ChangeVolume			; Inserted

	move.w	D0,$A8(A0)

	tst.l	$3C(A2)
	beq.w	lbC000A66

;		bsr.w	DMAWait

	moveq	#0,D0
	move.w	$38(A2),D0
	add.l	D0,D0
	move.l	$34(A2),D1
	add.l	D0,D1
	move.l	$3C(A2),D0
	sub.l	D0,D1
	move.l	D1,$A0(A0)
	move.w	$38(A2),$A4(A0)
	move.w	$2A(A2),$A6(A0)

	move.l	#$38,lenoffset
	bra.w	analyzer


lbC000A40:
	clr.w	$2E(A2)
	move.w	#$FFFF,$46(A2)
	move.w	#$FFFF,$48(A2)
	move.w	#$FFFF,$4A(A2)
	move.w	#$FFFF,$4C(A2)
	clr.l	$3C(A2)
	move.w	#0,$A8(A0)
lbC000A66:

	bra.w	analyzer_2

lbC000A7A:
	move.w	$4E(A2),D1
	move.w	$46(A2),D0
	cmpi.b	#$FF,D0
	beq.s	lbC000AA0
	subq.b	#1,$47(A2)
	andi.w	#$FF00,D0
	add.w	D0,D1
	bcc.s	lbC000AE6
	move.w	#$FF00,D1
	move.w	#$FFFF,$46(A2)
	bra.s	lbC000AE6

lbC000AA0:
	move.w	$48(A2),D0
	cmpi.b	#$FF,D0
	beq.s	lbC000AC0
	subq.b	#1,$49(A2)
	andi.w	#$FF00,D0
	sub.w	D0,D1
	bcc.s	lbC000AE6
	moveq	#0,D1
	move.w	#$FFFF,$48(A2)
	bra.s	lbC000AE6

lbC000AC0:
	move.w	$4A(A2),D0
	cmpi.w	#$FFFF,D0
	beq.s	lbC000AD0
	subq.w	#1,$4A(A2)
	bra.s	lbC000AE6

lbC000AD0:
	move.w	$4C(A2),D0
	cmpi.w	#$FFFF,D0
	beq.s	lbC000AEE
	sub.w	D0,D1
	bcc.s	lbC000AE6
	moveq	#0,D1
	move.w	#$FFFF,$4C(A2)
lbC000AE6:
	move.w	D1,$4E(A2)
	move.w	D1,$2E(A2)
lbC000AEE:
	rts

lbC000AF0:
	move.w	$28(A2),D0
	beq.s	lbC000B10
	add.w	D0,$2A(A2)
	move.w	$26(A2),D1
	beq.s	lbC000B04
	subq.w	#1,D1
	bra.s	lbC000B0C

lbC000B04:
	move.w	$24(A2),D1
	neg.w	$28(A2)
lbC000B0C:
	move.w	D1,$26(A2)
lbC000B10:
	move.w	$2C(A2),D0
	add.w	D0,$2A(A2)
	rts

lbC000B1A:
	move.w	(A3)+,D0
	andi.w	#$FF,D0
	move.w	D0,$54(A2)
	add.w	D0,D0
	lea	lbW0002A0(PC),A0
	move.w	0(A0,D0.W),$2A(A2)
	rts

lbC000B32:
	move.w	(A3)+,D0
	add.w	$54(A2),D0
	add.w	D0,D0
	lea	lbW0002A0(PC),A0
	move.w	0(A0,D0.W),$2A(A2)
	rts

lbC000B46:
	move.w	(A3)+,$2A(A2)
	rts

lbC000B4C:
	move.w	(A3)+,$2E(A2)
	rts

lbC000B52:
	move.w	(A3)+,$46(A2)
	move.w	(A3)+,$48(A2)
	move.w	(A3)+,$4A(A2)
	move.w	(A3)+,$4C(A2)
	clr.w	$4E(A2)
	rts

lbC000B68:
	move.w	D3,D0
	add.w	D0,D0

	bsr.w	DMAWait

	move.w	lbW000B76(PC,D0.W),$DFF096

	bsr.w	DMAWait

	rts

lbW000B76:
	dc.w	$8201,$8202,$8204,$8208

lbC000B7E:
	move.w	D3,D0
	add.w	D0,D0
	move.w	lbW000B9C(PC,D0.W),$DFF096
	lea	$DFF000,A0
	adda.w	lbW000BA4(PC,D0.W),A0
	bsr.w	lbC000A40
	moveq	#1,D2
	rts

lbW000B9C:
	dc.w	1,2,4,8
lbW000BA4:
	dc.w	0,$10,$20,$30

lbC000BAC:
	move.w	(A3)+,D0
	add.w	D0,D0
	add.w	D0,D0
	movea.l	lbL000064(PC),A0
	move.l	0(A0,D0.W),D0
	move.l	D0,$34(A2)
	move.l	D0,$30(A2)
	rts

lbC000BC4:
	moveq	#0,D0
	move.w	(A3)+,D0
	move.l	D0,$3C(A2)
	lsr.w	#1,D0
	move.w	D0,$38(A2)
	rts

lbC000BD4:
	move.l	(A3)+,D0
	move.l	D0,$3C(A2)
	beq.s	lbC000BE2
	lsr.w	#1,D0
	move.w	D0,$38(A2)
lbC000BE2:
	rts

lbC000BE4:
	move.w	(A3)+,6(A2)
lbC000BE8:
	moveq	#1,D2
	rts

lbC000BEC:
	move.w	8(A2),D1
	move.w	D1,10(A2)
	move.w	(A3)+,12(A2,D1.W)
	add.w	D1,D1
	move.l	A3,$14(A2,D1.W)
	addq.w	#2,8(A2)
	andi.w	#6,8(A2)
	rts

lbC000C0A:
	move.w	10(A2),D1
	move.w	12(A2,D1.W),D0
	beq.s	lbC000C1A
	subq.w	#1,12(A2,D1.W)
	beq.s	lbC000C22
lbC000C1A:
	add.w	D1,D1
	movea.l	$14(A2,D1.W),A3
	rts

lbC000C22:
	tst.w	D1
	beq.s	lbC000C2E
	subq.w	#2,8(A2)
	subq.w	#2,10(A2)
lbC000C2E:
	rts

lbC000C30:
	lea	lbL000D0C(PC),A3
	clr.w	$44(A2)
	bsr.w	lbC000B7E
	rts

lbC000C3E:
	move.l	(A3)+,D0
	add.l	D0,$34(A2)
	rts

lbC000C46:
	move.w	(A3)+,D0
	asr.w	#1,D0
	add.w	D0,$38(A2)
	rts

lbC000C50:
	move.l	(A3)+,D0
	add.l	D0,$3C(A2)
	rts

lbC000C58:
	move.w	(A3)+,D0
	add.w	D0,$2A(A2)
	rts

lbC000C60:
	move.w	(A3)+,D0
	add.w	D0,$2E(A2)
	rts

lbC000C68:
	moveq	#0,D1
	move.b	(A3),D1
	move.w	(A3)+,D0
	andi.w	#$FF,D0
	move.w	D1,$28(A2)
	move.w	D0,$24(A2)
	lsr.w	#1,D0
	move.w	D0,$26(A2)
	rts

lbC000C82:
	moveq	#0,D0
	move.b	(A3)+,D0
	add.w	D0,D0
	add.w	D0,D0
	movea.l	lbL000064(PC),A1
	movea.l	0(A1,D0.W),A0
	move.b	(A3)+,D0
	add.w	D0,D0
	add.w	D0,D0
	movea.l	0(A1,D0.W),A1
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	rts

lbC000CDE:
	move.w	(A3)+,D0
	add.w	D0,D0
	add.w	D0,D0
	movea.l	lbL000064(PC),A0
	movea.l	0(A0,D0.W),A0
	movea.l	$30(A2),A1
	moveq	#$7F,D0
lbC000CF2:
	cmpm.b	(A0)+,(A1)+
	bhi.s	lbC000D02
	beq.s	lbC000D06
	addq.b	#1,-1(A1)
	dbra	D0,lbC000CF2
	rts

lbC000D02:
	subq.b	#1,-1(A1)
lbC000D06:
	dbra	D0,lbC000CF2
	rts

lbL000D0C:
	dc.l	$F0000,$130000,0,6,$12,$70000

; player from game Virocop AGA

lbL001000:
	dc.l	0,0,0
lbL00100C:
	dc.l	0
lbL001010:
	dc.l	0
lbL001014:
	dc.l	0
lbL001018:
	dc.l	0
lbL00101C:
	dc.l	0
lbL001020:
	dc.l	0
lbL001024:
	dc.l	0
lbL001028:
	dc.l	0
lbL00102C:
	dc.l	0
lbL001030:
	dc.l	0,0,0,0,0
lbL001044:
	dc.l	0
lbL001048:
	dc.l	0
lbL00104C:
	dc.l	0
lbL001050:
	dc.l	0,0,0,0,0
lbL001064:
	dc.l	0
lbL001068:
	dc.l	0
lbL00106C:
	dc.l	0
lbL001070:
	dc.l	0
lbL001074:
	dc.l	0
lbW001078:
	dc.w	0
lbW00107A:
	dc.w	$FFFF
lbW00107C:
	dc.w	$FFFF
lbW00107E:
	dc.w	$FFFF
lbW001080:
	dc.w	$FFFF
lbW001082:
	dc.w	$FFFF
lbW001084:
	dc.w	$FFFF
lbW001086:
	dc.w	$FFFF
lbB001088:
	dc.b	0
lbB001089:
	dc.b	0
lbL00108A:
	dc.l	0
lbB00108E:
	dc.b	0
lbB00108F:
	dc.b	0
lbW001090:
	dc.w	0
lbW001092:
	dc.w	0
lbL001094:
	dc.l	lbW00122C,lbW00124E,lbW001270,lbW001292
lbW0010A4:
	dc.w	0
	dc.l	lbL001E68,0,0,0,0,0,0,0,0,0,0,$8000000,$9000900,0
	dc.l	0,0,0,$FF0000,$FFFFFFFF,$FFFFFFFF,0,0,$1010000,0
	dc.w	0
	dc.l	lbL001E68,0,0,0,0,0,0,0,0,0,0,$9000000,$9000900,0
	dc.l	0,0,0,$FF0000,$FFFFFFFF,$FFFFFFFF,0,0,$1010000
	dc.l	$20001
	dc.w	0
	dc.l	lbL001E68,0,0,0,0,0,0,0,0,0,0,$A000000,$9000900,0
	dc.l	0,0,0,$FF0000,$FFFFFFFF,$FFFFFFFF,0,0,$1010000
	dc.l	$40002
	dc.w	0
	dc.l	lbL001E68,0,0,0,0,0,0,0,0,0,0,0,$9000900,0,0,0,0
	dc.l	$FF0000,$FFFFFFFF,$FFFFFFFF
	dc.w	0
CurrentPos2
	dc.w	0
	dc.l	0,$1010000,$60003
lbW00122C:
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
lbW00124E:
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
lbW001270:
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
lbW001292:
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
lbL0012B4:
	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0
lbW001334:
	dc.w	$6B0,$650,$5F4,$5A0,$54C,$500,$4B8,$474,$434,$3F8
	dc.w	$3C0,$38A,$358,$328,$2FA,$2D0,$2A6,$280,$25C,$23A
	dc.w	$21A,$1FC,$1E0,$1C5,$1AC,$194,$17D,$168,$153,$140
	dc.w	$12E,$11D,$10D,$FE,$F0,$E2,$D6,$CA,$BE,$B4,$A9
	dc.w	$A0,$97,$8E,$86,$7F,$78,$71,$6B,$65,$5F,$5A,$54
	dc.w	$50,$4B,$47,$43,$3F,$3C,$38,$35,$32,$2F,$2D,$2A
	dc.w	$28,$25,$23,$21,$1F,$1E,$1C,$1A,$19,$17,$16,$15
	dc.w	$14,$12,$11,$10,15,15,14
Play_2
	movem.l	D0/D1/D7/A0/A1,-(SP)
	bsr.w	lbC001824
	bsr.w	lbC0019FA
	movem.l	(SP)+,D0/D1/D7/A0/A1
	rts
Initialize_2_1
	movem.l	A2/A3,-(SP)
	move.l	A0,lbL001064
	move.l	A1,lbL001000
	movea.l	A1,A2
	lea	2(A1),A0
	move.w	(A0)+,D0
	adda.w	D0,A1
	move.l	A1,lbL00108A
	move.l	D0,-(SP)
	movea.l	A2,A1
	adda.w	(A0)+,A1
	move.l	A1,lbL00100C
	movea.l	A2,A1
	adda.w	(A0)+,A1
	move.l	A1,lbL001010
	movea.l	A2,A1
	adda.w	(A0)+,A1
	move.l	A1,lbL001014
	movea.l	A2,A1
	adda.w	(A0)+,A1
	move.l	A1,lbL001018
	lea	lbL001024(PC),A3
	moveq	#7,D1
lbC00143E:
	movea.l	A2,A1
	adda.w	(A0)+,A1
	move.l	A1,(A3)+
	dbra	D1,lbC00143E
	lea	lbL001044(PC),A3
	moveq	#7,D1
lbC00144E:
	movea.l	A2,A1
	adda.w	(A0)+,A1
	move.l	A1,(A3)+
	dbra	D1,lbC00144E
	movea.l	A2,A1
	adda.w	(A0)+,A1
	move.l	A1,lbL00101C
	movea.l	A2,A1
	adda.w	(A0)+,A1
	move.l	A1,lbL001020
	move.l	(SP)+,D0
	move.w	(A0),D1
	sub.w	D0,D1
	lsr.w	#2,D1
	move.w	D1,lbW001078
	bsr.b	lbC0014A0
	bsr.w	lbC00165C
;	tst.l	lbL000FFC
;	bne.s	lbC00149A
;	move.w	#$10,D0
;	jsr	$782C4F7A
;	move.l	A0,lbL000FFC
lbC00149A:
	movem.l	(SP)+,A2/A3
	rts

lbC0014A0:
	movea.l	lbL00108A(PC),A1
	lea	lbL0012B4(PC),A0
	move.l	lbL001064(PC),D7
	move.w	lbW001078(PC),D0
	beq.s	lbC0014C6
	cmpi.w	#$20,D0
	ble.s	lbC0014BA
	moveq	#$20,D0
lbC0014BA:
	subq.w	#1,D0
lbC0014BC:
	move.l	(A1)+,D1
	move.l	D7,(A0)+
	add.l	D1,D7
	dbra	D0,lbC0014BC
lbC0014C6:
	lea	lbL0012B4(PC),A0
	move.l	A0,lbL00108A
	rts
Initialize_2_2
	bclr	#7,D0
	beq.s	lbC0014EC
	bsr.w	lbC00161C
	move.w	#$FFFF,lbW001086
	andi.w	#15,D0
	beq.s	lbC001542
	bra.s	lbC001500

lbC0014EC:
	btst	#6,D0
	beq.s	lbC001500
	bsr.w	lbC0015C6
	tst.w	D0
	bmi.s	lbC001546
	bsr.b	lbC001548
	bra.s	lbC001542

lbC001500:
	moveq	#0,D7
	move.w	D0,D7
	lsr.w	#7,D7
	andi.w	#$FFFE,D7
	bsr.b	lbC001548
	moveq	#-1,D1
	lea	lbL001E68(PC),A1
	lea	lbW0010A4(PC),A0
	moveq	#3,D0
lbC00151A:
	move.l	A1,2(A0)
	move.w	D7,$54(A0)
	clr.w	$56(A0)
	clr.w	$58(A0)
	clr.w	$5A(A0)
	clr.w	$48(A0)
	move.b	D1,$47(A0)
	move.w	D1,$32(A0)
	lea	$62(A0),A0
	dbra	D0,lbC00151A
lbC001542:
	bsr.w	lbC00165C
lbC001546:
	rts

lbC001548:
	move.w	#$FFFF,lbW00107A
	andi.w	#15,D0
	move.w	D0,lbW001086
	add.w	D0,D0
	movea.l	lbL001014(PC),A0
	move.w	0(A0,D0.W),D1
	andi.w	#$FF,D1
	move.w	D1,lbW001092
	clr.w	lbW001090
	movea.l	lbL001024(PC),A0
	move.w	0(A0,D0.W),D1
	movea.l	lbL001044(PC),A0
	adda.w	D1,A0
	move.l	A0,lbL001068
	movea.l	lbL001028(PC),A0
	move.w	0(A0,D0.W),D1
	movea.l	lbL001048(PC),A0
	adda.w	D1,A0
	move.l	A0,lbL00106C
	movea.l	lbL00102C(PC),A0
	move.w	0(A0,D0.W),D1
	movea.l	lbL00104C(PC),A0
	adda.w	D1,A0
	move.l	A0,lbL001070
	movea.l	lbL001030(PC),A0
	move.w	0(A0,D0.W),D1
	movea.l	lbL001050(PC),A0
	adda.w	D1,A0
	move.l	A0,lbL001074
	rts

lbC0015C6:
	lsr.w	#2,D0
	andi.w	#12,D0
	lea	lbL001094,A0
	movea.l	0(A0,D0.W),A0
	lea	lbW0010A4(PC),A1
	moveq	#3,D0
lbC0015DC:
	move.w	(A0),$54(A1)
	move.w	2(A0),$56(A1)
	move.w	4(A0),(A1)
	move.w	6(A0),$5A(A1)
	move.l	#lbL001E68,2(A1)
	clr.w	$58(A0)
	clr.w	$48(A0)
	move.b	#$FF,$47(A0)
	lea	8(A0),A0
	lea	$62(A1),A1
	dbra	D0,lbC0015DC
	move.w	(A0),D0
	move.w	D0,lbW001086
	rts

lbC00161C:
	move.l	D0,-(SP)
	lsr.w	#2,D0
	andi.w	#12,D0
	lea	lbL001094,A0
	movea.l	0(A0,D0.W),A0
	lea	lbW0010A4(PC),A1
	moveq	#3,D0
lbC001634:
	move.w	$54(A1),(A0)
	move.w	$56(A1),2(A0)
	move.w	(A1),4(A0)
	move.w	$5A(A1),6(A0)
	lea	8(A0),A0
	lea	$62(A1),A1
	dbra	D0,lbC001634
	move.w	lbW001086(PC),(A0)
	move.l	(SP)+,D0
	rts

lbC00165C:
	lea	$DFF000,A0
;	move.w	#$780,$9A(A0)
	move.w	#$FF,$9E(A0)
	moveq	#0,D0
	move.w	D0,$A8(A0)
	move.w	D0,$B8(A0)
	move.w	D0,$C8(A0)
	move.w	D0,$D8(A0)
	lea	$BFE001,A0
	bset	#1,(A0)
	rts
End_2
	movem.l	D3/A2,-(SP)
	clr.w	lbB00108E
	clr.w	lbB001088
	moveq	#-1,D0
	move.w	D0,lbW001086
	move.w	D0,lbW00107E
	move.w	D0,lbW001080
	move.w	D0,lbW001082
	move.w	D0,lbW001084
	tst.l	lbL001000
	beq.s	lbC0016DC
	lea	lbW0010A4(PC),A2
	moveq	#0,D3
lbC0016CA:
	moveq	#-1,D0
	bsr.b	lbC0017A2
	lea	$62(A2),A2
	addq.w	#1,D3
	cmpi.w	#4,D3
	blt.s	lbC0016CA
lbC0016DC:
	movem.l	(SP)+,D3/A2
	rts

;	andi.w	#$FF,D0
;	move.w	D0,lbB001088
;	move.w	D0,lbB00108E
;	rts
Initialize_2_3
	move.b	D1,lbB00108E
	move.b	D0,lbB00108F
	rts

;	move.w	D0,lbW001092
;	bne.s	lbC001724
;	moveq	#15,D0
;	and.w	lbW001086(PC),D0
;	add.w	D0,D0
;	movea.l	lbL001014(PC),A0
;	move.w	0(A0,D0.W),D0
;	andi.w	#$FF,D0
;	move.w	D0,lbW001092
;lbC001724:
;	rts

;	movem.l	D2/D3,-(SP)
;	move.l	D0,D2
;	move.l	D1,D3
;	moveq	#0,D1
;	bsr.s	lbC00174E
;	swap	D2
;	move.w	D2,D0
;	moveq	#1,D1
;	bsr.s	lbC00174E
;	move.w	D3,D0
;	moveq	#2,D1
;	bsr.s	lbC00174E
;	swap	D3
;	move.w	D3,D0
;	moveq	#3,D1
;	bsr.s	lbC00174E
;	movem.l	(SP)+,D2/D3
;	rts

lbC00174E:
	cmpi.b	#$FF,D0
	beq.s	lbC00177E
	add.w	D1,D1
	lea	lbW0010A4(PC),A0
	adda.w	lbW001782(PC,D1.W),A0
	movea.l	lbL001018(PC),A1
	move.b	D0,D1
	add.b	D1,D1
	move.w	0(A1,D1.W),D1
	andi.w	#$FF,D1
	cmp.w	$48(A0),D1
	bcs.s	lbC00177E
	move.w	D1,$48(A0)
	move.w	D0,$46(A0)
	rts

lbC00177E:
	moveq	#-1,D0
	rts

lbW001782:
	dc.w	0,$62,$C4,$126

lbC00178A:
	tst.b	$46(A2)
	beq.s	lbC001796
	subq.b	#1,$46(A2)
	rts

lbC001796:
	move.w	$46(A2),D0
	cmpi.b	#$FF,D0
	bne.s	lbC0017A2
	rts

lbC0017A2:
	move.l	D2,-(SP)
	move.l	D0,-(SP)
	bsr.w	lbC001CC8
	move.l	(SP)+,D0
	clr.w	6(A2)
	clr.w	$2E(A2)
	clr.w	$24(A2)
	clr.w	$28(A2)
	clr.w	$26(A2)
	clr.w	$2C(A2)
	clr.w	8(A2)
	clr.w	10(A2)
	moveq	#-1,D1
	move.b	D1,$47(A2)
	move.w	D1,$4A(A2)
	move.w	D1,$4C(A2)
	move.w	D1,$4E(A2)
	move.w	D1,$50(A2)
	move.w	D1,$34(A2)
	move.w	$5E(A2),D7
	lea	lbW00107E(PC),A0
	move.w	D0,0(A0,D7.W)
	bmi.s	lbC001816
	andi.w	#$FF,D0
	add.w	D0,D0
	movea.l	lbL00100C(PC),A0
	move.w	0(A0,D0.W),D0
	movea.l	lbL001010(PC),A0
	adda.w	D0,A0
	move.l	A0,2(A2)
	moveq	#-1,D0
	move.l	D0,$42(A2)
lbC001812:
	move.l	(SP)+,D2
	rts

lbC001816:
	clr.w	$48(A2)
	lea	lbL001E68(PC),A1
	move.l	A1,2(A2)
	bra.s	lbC001812

lbC001824:
	tst.w	lbW001086
	bmi.s	lbC001834
	subq.w	#1,lbW001090
	bmi.s	lbC001836
lbC001834:
	rts

lbC001836:
	movem.l	D2/D3/A2/A3,-(SP)
	move.w	lbW001092(PC),lbW001090
	lea	lbW0010A4(PC),A2
	moveq	#0,D3
	move.w	lbW00107A(PC),lbW00107C
lbC001850:
	subq.b	#1,$5A(A2)
	bpl.w	lbC0019E6
	move.b	$5B(A2),$5A(A2)
lbC00185E:
	lea	lbL001068(PC),A0
	movea.l	0(A0,D3.W),A0
	move.w	$54(A2),D0
	move.w	0(A0,D0.W),D0
	move.b	D0,$57(A2)
	lsr.w	#8,D0
	cmpi.b	#$FF,D0
	bne.s	lbC001886
	move.w	#$FFFF,lbW001086
	bra.w	lbC0019F4

lbC001886:
	cmpi.b	#$FE,D0
	bne.s	lbC00189C
lbC00188C:

		bsr.w	SongEndTest

	move.b	$57(A2),D0
lbC001890:
	andi.w	#$FF,D0
	add.w	D0,D0
	move.w	D0,$54(A2)
	bra.s	lbC00185E

lbC00189C:
	cmpi.b	#$FC,D0
	bne.s	lbC0018B6
	move.w	lbW00107C(PC),D0
	cmpi.w	#$FFFF,D0
	beq.s	lbC00188C
	move.w	#$FFFF,lbW00107A
	bra.s	lbC001890

lbC0018B6:
	cmpi.b	#$FD,D0
	bne.s	lbC0018D6
	move.w	lbW00107C(PC),D0
	cmpi.w	#$FFFF,D0
	beq.s	lbC0018D0
	move.w	#$FFFF,lbW00107A
	bra.s	lbC001890

lbC0018D0:
	addq.w	#2,$54(A2)
	bra.s	lbC00185E

lbC0018D6:
	add.w	D0,D0
	movea.l	lbL00101C(PC),A0
	move.w	0(A0,D0.W),D0
	movea.l	lbL001020(PC),A0
	adda.w	D0,A0
	move.b	$56(A2),D7
	andi.w	#$FF,D7
lbC0018EE:
	moveq	#0,D0
	move.b	0(A0,D7.W),D0
	cmpi.b	#$40,D0
	bcc.s	lbC00195C
	move.w	$60(A2),D1
	move.w	D0,D2
	move.w	(A2),D0
	cmpi.w	#$77,D0
	bcc.s	lbC001912
	bsr.w	lbC00174E
	cmpi.b	#$FF,D0
	beq.s	lbC001956
lbC001912:
	move.w	D2,D0
	add.b	$57(A2),D0
	cmpi.b	#$54,D0
	blt.s	lbC001920
	moveq	#$54,D0
lbC001920:
	move.w	D0,$58(A2)
	add.w	D0,D0
	lea	lbW001334(PC),A1
	andi.w	#$FF,D0
	move.w	0(A1,D0.W),D0
	cmpi.w	#$77,(A2)
	beq.s	lbC00193E
	move.w	D0,$2A(A2)
	bra.s	lbC001956

lbC00193E:
	move.w	D0,$30(A2)
	addq.w	#1,D7
	moveq	#0,D1
	move.b	0(A0,D7.W),D1
	sub.w	$2A(A2),D0
	bpl.s	lbC001952
	neg.w	D1
lbC001952:
	move.w	D1,$2C(A2)
lbC001956:
	addq.b	#1,D7
	bra.w	lbC0019E2

lbC00195C:
	cmpi.b	#$80,D0
	bcc.s	lbC001974
	andi.w	#$3F,D0
	move.b	D0,$5B(A2)
	move.b	D0,$5A(A2)
	addq.b	#1,D7
	bra.w	lbC0018EE

lbC001974:
	cmpi.b	#$F9,D0
	beq.s	lbC001988
	bcc.s	lbC00198E
	andi.w	#$7F,D0
	move.w	D0,(A2)
	addq.b	#1,D7
	bra.w	lbC0018EE

lbC001988:
	addq.b	#1,D7
	bra.b	lbC0019E2

lbC00198E:
	cmpi.b	#$FF,D0
	beq.s	lbC0019C4
	cmpi.b	#$FC,D0
	beq.s	lbC0019D2
	cmpi.b	#$FE,D0
	bne.s	lbC001988
	move.b	1(A0,D7.W),D1
	asl.w	#8,D1
	move.b	2(A0,D7.W),D1
	move.w	D1,$2C(A2)
	tst.w	D1
	bpl.s	lbC0019B6
	moveq	#0,D0
	bra.s	lbC0019BA

lbC0019B6:
	move.w	#$FFFF,D0
lbC0019BA:
	move.w	D0,$30(A2)
	addq.b	#3,D7
	bra.b	lbC0019E2

lbC0019C4:
	move.b	#0,$56(A2)
	addq.w	#2,$54(A2)
	bra.w	lbC00185E

lbC0019D2:
	move.b	1(A0,D7.W),D1
	asl.w	#8,D1
	move.w	D1,$32(A2)
	addq.b	#2,D7
	bra.w	lbC0019E2

lbC0019E2:
	move.b	D7,$56(A2)
lbC0019E6:
	lea	$62(A2),A2
	addq.w	#4,D3
	cmpi.w	#$10,D3
	blt.w	lbC001850
lbC0019F4:
	movem.l	(SP)+,D2/D3/A2/A3
	rts

lbC0019FA:
	movem.l	D2/D3/A2/A3,-(SP)
	moveq	#0,D0
	moveq	#0,D1
	moveq	#0,D7
	move.b	lbB001089(PC),D0
	move.b	lbB00108F(PC),D7
	move.b	lbB00108E(PC),D1
	beq.s	lbC001A2C
	cmp.w	D7,D0
	blt.s	lbC001A26
	sub.w	D1,D0
	cmp.w	D7,D0
	bgt.s	lbC001A2C
lbC001A1C:
	move.w	D7,D0
	clr.b	lbB00108E
	bra.s	lbC001A2C

lbC001A26:
	add.w	D1,D0
	cmp.w	D7,D0
	bge.s	lbC001A1C
lbC001A2C:
	move.b	D0,lbB001089
	moveq	#0,D3
	lea	lbW0010A4(PC),A2
lbC001A38:
	bsr.w	lbC00178A
	tst.w	6(A2)
	beq.s	lbC001A48
	subq.w	#1,6(A2)
	bne.s	lbC001A66
lbC001A48:
	movea.l	2(A2),A3
	moveq	#0,D2
lbC001A4E:
	move.w	(A3)+,D0
	andi.w	#$FF,D0
	add.w	D0,D0
	add.w	D0,D0
	movea.l	lbL001A96(PC,D0.W),A0
	jsr	(A0)
	tst.w	D2
	beq.s	lbC001A4E
	move.l	A3,2(A2)
lbC001A66:
	bsr.w	lbC001C0C
	bsr.w	lbC001B8E
	lea	$62(A2),A2
	addq.w	#1,D3
	cmpi.w	#4,D3
	blt.s	lbC001A38
	moveq	#0,D3
	lea	lbW0010A4(PC),A2
lbC001A80:
	bsr.b	lbC001AFA
	lea	$62(A2),A2
	addq.w	#1,D3
	cmpi.w	#4,D3
	blt.s	lbC001A80
	movem.l	(SP)+,D2/D3/A2/A3
	rts

lbL001A96:
	dc.l	lbC001D7E,lbC001D36,lbC001CFA,lbC001D12,lbC001D22
	dc.l	lbC001D32,lbC001D3A,lbC001D58,lbC001D9A,lbC001DA2
	dc.l	lbC001DAC,lbC001DB4,lbC001DBC,lbC001DC4,lbC001C84
	dc.l	lbC001C92,lbC001CAE,lbC001CC8,lbC001D36,lbC001C98
	dc.l	lbC001C58,lbC001C70,lbC001DDE,lbC001E3A,lbC001C8A

lbC001AFA:
	moveq	#0,D1
	move.b	lbB001089(PC),D1
	lsr.b	#2,D1
	moveq	#0,D0
	move.b	$2E(A2),D0
	lsr.b	#2,D0
	cmp.b	D1,D0
	ble.s	lbC001B10
	move.b	D1,D0
lbC001B10:
	lea	$DFF000,A0
	move.w	D3,D7
	lsl.w	#4,D7
	adda.w	D7,A0
;	lsr.w	#1,D0

	bsr.w	ChangeVolume		; inserted

	move.w	D0,$A8(A0)

	tst.l	$42(A2)
	beq.w	lbC001B76

;		bsr.w	DMAWait

	moveq	#0,D0
	move.w	$3E(A2),D0
	add.l	D0,D0
	move.l	$3A(A2),D1
	add.l	D0,D1
	move.l	$42(A2),D0
	sub.l	D0,D1
	move.l	D1,$A0(A0)
	move.w	$3E(A2),$A4(A0)
	move.w	$2A(A2),$A6(A0)

	move.l	#$3e,lenoffset
	bra.w	analyzer

lbC001B4E:
	move.w	#0,$2E(A2)
	move.w	#$FFFF,$4A(A2)
	move.w	#$FFFF,$4C(A2)
	move.w	#$FFFF,$4E(A2)
	move.w	#$FFFF,$50(A2)
	clr.l	$42(A2)
	move.w	#0,$A8(A0)

lbC001B76:

	bra.w	analyzer_2

lbC001B8E:
	move.w	$52(A2),D1
	move.w	$4A(A2),D0
	cmpi.b	#$FF,D0
	beq.s	lbC001BB4
	subq.b	#1,$4B(A2)
	andi.w	#$FF00,D0
	add.w	D0,D1
	bcc.s	lbC001C02
	move.w	#$FF00,D1
	move.w	#$FFFF,$4A(A2)
	bra.s	lbC001C02

lbC001BB4:
	move.w	$4C(A2),D0
	cmpi.b	#$FF,D0
	beq.s	lbC001BD4
	subq.b	#1,$4D(A2)
	andi.w	#$FF00,D0
	sub.w	D0,D1
	bcc.s	lbC001C02
	moveq	#0,D1
	move.w	#$FFFF,$4C(A2)
	bra.s	lbC001C02

lbC001BD4:
	cmpi.w	#$FFFF,$4E(A2)
	beq.s	lbC001BEC
	subq.w	#1,$4E(A2)
	move.w	$34(A2),D1
	cmp.w	$2E(A2),D1
	bcc.s	lbC001C0A
	bra.s	lbC001C02

lbC001BEC:
	move.w	$50(A2),D0
	cmpi.w	#$FFFF,D0
	beq.s	lbC001C0A
	sub.w	D0,D1
	bcc.s	lbC001C02
	moveq	#0,D1
	move.w	#$FFFF,$50(A2)
lbC001C02:
	move.w	D1,$52(A2)
	move.w	D1,$2E(A2)
lbC001C0A:
	rts

lbC001C0C:
	move.w	$28(A2),D0
	beq.s	lbC001C2C
	add.w	D0,$2A(A2)
	move.w	$26(A2),D1
	beq.s	lbC001C20
	subq.w	#1,D1
	bra.s	lbC001C28

lbC001C20:
	move.w	$24(A2),D1
	neg.w	$28(A2)
lbC001C28:
	move.w	D1,$26(A2)
lbC001C2C:
	move.w	$2C(A2),D0
	beq.s	lbC001C56
	bmi.s	lbC001C44
	add.w	$2A(A2),D0
	move.w	$30(A2),D1
	cmp.w	D1,D0
	bcs.s	lbC001C52
	move.w	D1,D0
	bra.s	lbC001C52

lbC001C44:
	add.w	$2A(A2),D0
	move.w	$30(A2),D1
	cmp.w	D1,D0
	bcc.s	lbC001C52
	move.w	D1,D0
lbC001C52:
	move.w	D0,$2A(A2)
lbC001C56:
	rts

lbC001C58:
	move.w	(A3)+,D0
	andi.w	#$FF,D0
	move.w	D0,$58(A2)
	add.w	D0,D0
	lea	lbW001334(PC),A0
	move.w	0(A0,D0.W),$2A(A2)
	rts

lbC001C70:
	move.w	(A3)+,D0
	add.w	$58(A2),D0
	add.w	D0,D0
	lea	lbW001334(PC),A0
	move.w	0(A0,D0.W),$2A(A2)
	rts

lbC001C84:
	move.w	(A3)+,$2A(A2)
	rts

lbC001C8A:
	move.w	$32(A2),$34(A2)
	rts

lbC001C92:
	move.w	(A3)+,$2E(A2)
	rts

lbC001C98:
	move.w	(A3)+,$4A(A2)
	move.w	(A3)+,$4C(A2)
	move.w	(A3)+,$4E(A2)
	move.w	(A3)+,$50(A2)
	clr.w	$52(A2)
	rts

lbC001CAE:
	move.w	D3,D0
	add.w	D0,D0
	lea	$DFF000,A0

	bsr.w	DMAWait

	move.w	lbW001CC0(PC,D0.W),$96(A0)

	bsr.w	DMAWait

	rts

lbW001CC0:
	dc.w	$8001,$8002,$8004,$8008

lbC001CC8:
	move.w	D3,D0
	add.w	D0,D0
	lea	$DFF000,A0
	adda.w	lbW001CF2(PC,D0.W),A0
	bsr.w	lbC001B4E
	lea	$DFF000,A0
	move.w	lbW001CEA(PC,D0.W),$96(A0)
	moveq	#1,D2
	rts

lbW001CEA:
	dc.w	1,2,4,8
lbW001CF2:
	dc.w	0,$10,$20,$30

lbC001CFA:
	move.w	(A3)+,D0
	add.w	D0,D0
	add.w	D0,D0
	movea.l	lbL00108A(PC),A0
	move.l	0(A0,D0.W),D0
	move.l	D0,$3A(A2)
	move.l	D0,$36(A2)
	rts

lbC001D12:
	moveq	#0,D0
	move.w	(A3)+,D0
	move.l	D0,$42(A2)
	lsr.w	#1,D0
	move.w	D0,$3E(A2)
	rts

lbC001D22:
	move.l	(A3)+,D0
	move.l	D0,$42(A2)
	beq.s	lbC001D30
	lsr.w	#1,D0
	move.w	D0,$3E(A2)
lbC001D30:
	rts

lbC001D32:
	move.w	(A3)+,6(A2)
lbC001D36:
	moveq	#1,D2
	rts

lbC001D3A:
	move.w	8(A2),D1
	move.w	D1,10(A2)
	move.w	(A3)+,12(A2,D1.W)
	add.w	D1,D1
	move.l	A3,$14(A2,D1.W)
	addq.w	#2,8(A2)
	andi.w	#6,8(A2)
	rts

lbC001D58:
	move.w	10(A2),D1
	move.w	12(A2,D1.W),D0
	beq.s	lbC001D68
	subq.w	#1,12(A2,D1.W)
	beq.s	lbC001D70
lbC001D68:
	add.w	D1,D1
	movea.l	$14(A2,D1.W),A3
	rts

lbC001D70:
	tst.w	D1
	beq.s	lbC001D7C
	subq.w	#2,8(A2)
	subq.w	#2,10(A2)
lbC001D7C:
	rts

lbC001D7E:
	lea	lbL001E68(PC),A3
	clr.w	$48(A2)
	bsr.w	lbC001CC8
	move.w	$5E(A2),D7
	lea	lbW00107E(PC),A0
	move.w	#$FFFF,0(A0,D7.W)
	rts

lbC001D9A:
	move.l	(A3)+,D0
	add.l	D0,$3A(A2)
	rts

lbC001DA2:
	move.w	(A3)+,D0
	asr.w	#1,D0
	add.w	D0,$3E(A2)
	rts

lbC001DAC:
	move.l	(A3)+,D0
	add.l	D0,$42(A2)
	rts

lbC001DB4:
	move.w	(A3)+,D0
	add.w	D0,$2A(A2)
	rts

lbC001DBC:
	move.w	(A3)+,D0
	add.w	D0,$2E(A2)
	rts

lbC001DC4:
	moveq	#0,D1
	move.b	(A3),D1
	move.w	(A3)+,D0
	andi.w	#$FF,D0
	move.w	D1,$28(A2)
	move.w	D0,$24(A2)
	lsr.w	#1,D0
	move.w	D0,$26(A2)
	rts

lbC001DDE:
	moveq	#0,D0
	move.b	(A3)+,D0
	add.w	D0,D0
	add.w	D0,D0
	movea.l	lbL00108A(PC),A1
	movea.l	0(A1,D0.W),A0
	move.b	(A3)+,D0
	add.w	D0,D0
	add.w	D0,D0
	movea.l	0(A1,D0.W),A1
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	rts

lbC001E3A:
	move.w	(A3)+,D0
	add.w	D0,D0
	add.w	D0,D0
	movea.l	lbL00108A(PC),A0
	movea.l	0(A0,D0.W),A0
	movea.l	$36(A2),A1
	moveq	#$7F,D0
lbC001E4E:
	cmpm.b	(A0)+,(A1)+
	bhi.s	lbC001E5E
	beq.s	lbC001E62
	addq.b	#1,-1(A1)
	dbra	D0,lbC001E4E
	rts

lbC001E5E:
	subq.b	#1,-1(A1)
lbC001E62:
	dbra	D0,lbC001E4E
	rts

lbL001E68:
	dc.l	$F0000,$130000,0,6,$12,$70000

; player from game Realms by Virgin Games

lbW002000:
	dc.w	$EEE,$E17,$D4D,$C8E,$BD9,$B2F,$A8E,$9F7,$967,$8E0
	dc.w	$861,$7E8,$777,$70B,$6A6,$647,$5EC,$597,$547,$4FB
	dc.w	$4B3,$470,$430,$3F4,$3BB,$385,$353,$323,$2F6,$2CB
	dc.w	$2A3,$27D,$25A,$238,$218,$1FA,$1DD,$1C3,$1A9,$191
	dc.w	$17B,$165,$151,$13E,$12D,$11C,$10C,$FD,$EE,$E1
	dc.w	$D4,$C8,$BD,$B3,$A8,$9F,$96,$8E,$86,$7E,$77,$70
	dc.w	$6A,$64,$5E,$59,$54,$4F,$4B,$47,$43,$3F,$3B,$38
	dc.w	$35,$32,$2F,$2C,$2A,$27,$25,$23,$21,$1F
Play_3
	movem.l	D0/D1/D7/A0/A1,-(SP)
	bsr.w	Play_3_2
	bsr.w	Play_3_3
	movem.l	(SP)+,D0/D1/D7/A0/A1
	rts

Initialize_3_1

	move.l	A2,-(SP)
	movea.l	lbL002D88(pc),A0
	movea.l	A0,A2
	movea.l	(A0),A1
	adda.l	A2,A1
	move.l	A1,lbL002DBC
	move.l	A0,lbL002D90
	lea	$84(A0),A0
	movea.l	(A0),A1
	adda.l	A2,A1
	move.l	A1,lbL002DB0
	move.l	A0,lbL002DAC
	lea	$3FC(A0),A0
	move.l	A0,lbL002D94
	lea	$40(A0),A0
	move.l	A0,lbL002DC0
	lea	$1FE(A0),A0
	movea.l	(A0),A1
	adda.l	A2,A1
	move.l	A1,lbL002DB8
	move.l	A0,lbL002D98
	lea	$80(A0),A0
	move.l	A0,lbL002D9C
	lea	$80(A0),A0
	move.l	A0,lbL002DA0
	lea	$80(A0),A0
	move.l	A0,lbL002DA4
	lea	$80(A0),A0
	movea.l	(A0),A1
	adda.l	A2,A1
	move.l	A1,lbL002DB4
	move.l	A0,lbL002DA8
	movea.l	lbL002D98(pc),A0
	move.w	#$7F,D0
lbC00211C:
	movea.l	(A0),A1
	adda.l	A2,A1
	move.l	A1,(A0)+
	dbra	D0,lbC00211C
	movea.l	lbL002DAC(pc),A0
	move.l	#$FE,D0
lbC002130:
	movea.l	(A0),A1
	adda.l	A2,A1
	move.l	A1,(A0)+
	dbra	D0,lbC002130
	movea.l	lbL002DA8(pc),A0
	move.l	#$FD,D0
lbC002144:
	movea.l	(A0),A1
	adda.l	A2,A1
	move.l	A1,(A0)+
	dbra	D0,lbC002144
	bsr.b	lbC002156
	movea.l	(SP)+,A2
	rts

lbC002156:
	movem.l	A2/A3,-(SP)
	movea.l	lbL002D90(pc),A1
	movea.l	lbL002DC4(pc),A3
	movea.l	(A1),A0
	moveq	#$1F,D0
lbC002166:
	movea.l	(A1),A2
	suba.l	A0,A2
	adda.l	A3,A2
	move.l	A2,(A1)+
	dbra	D0,lbC002166
	movem.l	(SP)+,A2/A3
	rts

;	movea.l	lbL002D88,A0
;	move.l	A0,lbL002D90
;	lea	$84(A0),A0
;	move.l	A0,lbL002DAC
;	lea	$3FC(A0),A0
;	move.l	A0,lbL002D94
;	lea	$40(A0),A0
;	move.l	A0,lbL002DC0
;	lea	$1FE(A0),A0
;	move.l	A0,lbL002D98
;	lea	$80(A0),A0
;	move.l	A0,lbL002D9C
;	lea	$80(A0),A0
;	move.l	A0,lbL002DA0
;	lea	$80(A0),A0
;	move.l	A0,lbL002DA4
;	lea	$80(A0),A0
;	move.l	A0,lbL002DA8
;	rts
Initialize_3_2
	move.w	D0,lbW002DD4
	moveq	#-1,D1
	add.w	D0,D0
	move.w	D1,lbW002DE0
	move.w	D1,lbW002DC8
	movea.l	lbL002D94(pc),A0
	move.w	0(A0,D0.W),lbW002DDE
	clr.w	lbW002DDC
	add.w	D0,D0
	movea.l	lbL002D98(pc),A0
	movea.l	0(A0,D0.W),A0
	move.l	A0,lbL0025A0
	movea.l	lbL002D9C(pc),A0
	movea.l	0(A0,D0.W),A0
	move.l	A0,lbL0025A4
	movea.l	lbL002DA0(pc),A0
	movea.l	0(A0,D0.W),A0
	move.l	A0,lbL0025A8
	movea.l	lbL002DA4(pc),A0
	movea.l	0(A0,D0.W),A0
	move.l	A0,lbL0025AC
	moveq	#3,D0
	lea	lbW003746(PC),A0
lbC002224:
	lea	lbL00373A(PC),A1
	move.l	A1,2(A0)
	clr.w	$50(A0)
	clr.b	$52(A0)
	clr.b	$53(A0)
	clr.w	$54(A0)
	clr.b	$56(A0)
	clr.b	$57(A0)
	clr.w	$44(A0)
	move.w	D1,$40(A0)
	lea	$5A+2(A0),A0
	dbra	D0,lbC002224
	bsr.s	lbC00227A
	clr.w	lbW002DE0
	rts

;	add.w	D0,D0
;	moveq	#3,D1
;	lea	lbW003746(PC),A0
;lbC002264:
;	move.w	D0,$50(A0)
;	clr.b	$52(A0)
;	clr.b	$56(A0)
;	lea	$5A(A0),A0
;	dbra	D1,lbC002264
;	rts

lbC00227A:
	lea	$DFF000,A0
;	move.w	#$780,$9A(A0)
	move.w	#$FF,$9E(A0)
	clr.w	$A8(A0)
	clr.w	$B8(A0)
	clr.w	$C8(A0)
	clr.w	$D8(A0)
	lea	$BFE001,A0
	bset	#1,(A0)
	rts
End_3
	movem.l	D3/A2,-(SP)
	clr.w	lbW002DDA
	clr.w	lbW002DD6
	move.w	#$FFFF,lbW002DE0
	lea	lbW003746(PC),A2
	moveq	#0,D3
lbC0022C2:
	bsr.w	lbC0023A0
	lea	lbL00373A(PC),A1
	move.l	A1,2(A2)
	lea	$5A+2(A2),A2
	addq.w	#1,D3
	cmpi.w	#4,D3
	blt.s	lbC0022C2
	movem.l	(SP)+,D3/A2
	rts

;	andi.w	#$FF,D0
;	move.w	D0,lbW002DD6
;	move.w	D0,lbW002DDA
;	rts
Initialize_3_3
	asl.w	#8,D1
	move.b	D0,D1
	move.w	D1,lbW002DDA
	rts

;	move.w	D0,lbW002DDE
;	bne.s	lbC00230A
;	add.w	D0,D0
;	movea.l	lbL002D94,A0
;	move.w	0(A0,D0.W),lbW002DDE
;lbC00230A:
;	clr.w	lbW002DDC
;	rts

;	movem.l	D2/D3,-(SP)
;	move.w	D0,D2
;	move.w	D1,D3
;	moveq	#0,D1
;	bsr.w	lbC002340
;	swap	D2
;	move.w	D2,D0
;	moveq	#1,D1
;	bsr.w	lbC002340
;	move.w	D3,D0
;	moveq	#2,D1
;	bsr.w	lbC002340
;	swap	D3
;	move.w	D3,D0
;	moveq	#3,D1
;	bsr.w	lbC002340
;	movem.l	(SP)+,D2/D3
;	rts

lbC002340:
	cmpi.b	#$FF,D0
	beq.s	lbC002382
	move.w	D1,D7
	add.w	D7,D7
	lea	lbL002DCC(pc),A0
	move.w	D0,0(A0,D7.W)
	mulu.w	#$5A+2,D1
	lea	lbW003746(PC),A0
	adda.w	D1,A0
	movea.l	lbL002DC0(pc),A1
	move.w	D0,D1
	add.w	D1,D1
	move.w	0(A1,D1.W),D1
	cmp.w	$44(A0),D1
	bcs.s	lbC002382
	move.w	D1,$44(A0)
	move.w	D0,D1
	lsr.w	#8,D1
	move.w	D1,$42(A0)
	move.w	D0,$40(A0)
	rts

lbC002382:
	moveq	#-1,D0
	rts

lbC002386:
	move.w	$42(A2),D0
	beq.s	lbC002394
	subq.w	#1,D0
	move.w	D0,$42(A2)
	rts

lbC002394:
	move.w	$40(A2),D0
	cmpi.b	#$FF,D0
	bne.s	lbC0023A0
	rts

lbC0023A0:
	clr.w	6(A2)
	clr.w	$2E(A2)
	clr.w	$24(A2)
	clr.w	$28(A2)
	clr.w	$26(A2)
	clr.w	$2C(A2)
	clr.w	8(A2)
	clr.w	10(A2)
	moveq	#-1,D1
	move.w	D1,$40(A2)
	move.w	D1,$46(A2)
	move.w	D1,$48(A2)
	move.w	D1,$4A(A2)
	move.w	D1,$4C(A2)
	andi.l	#$FFFF,D0
	add.w	D0,D0
	add.w	D0,D0
	movea.l	lbL002DAC(pc),A0
	cmpa.l	#0,a0
	beq.s	.ret
	move.l	0(A0,D0.W),D0
	move.l	D0,2(A2)
	move.l	#$FFFFFFFF,$3C(A2)
	bsr.w	lbC0035B0
.ret	rts
Play_3_2
	movem.l	D2-D6/A2-A6,-(SP)
	tst.w	lbW002DE0
	bmi.w	lbC00258E
	subq.w	#1,lbW002DDC
	bpl.w	lbC00258E
	move.w	lbW002DDE(pc),lbW002DDC
	lea	lbW003746(PC),A2
	moveq	#0,D3
	move.w	lbW002DC8(pc),lbW002DCA
lbC002424:
	subq.b	#1,$56(A2)
	bpl.w	lbC002580
	move.b	$57(A2),$56(A2)
lbC002432:
	move.w	D3,D0
	add.w	D0,D0
	add.w	D0,D0
	lea	lbL0025A0(PC),A0
	movea.l	0(A0,D0.W),A0
	move.w	$50(A2),D0
	move.w	0(A0,D0.W),D0
	move.b	D0,$53(A2)
	lsr.w	#8,D0
	cmpi.b	#$FF,D0
	bne.s	lbC00245E
	move.w	#$FFFF,lbW002DE0
	bra.w	lbC00258E

lbC00245E:
	cmpi.b	#$FE,D0
	bne.s	lbC002474
lbC002464:

		bsr.w	SongEndTest

	move.b	$53(A2),D0
lbC002468:
	andi.w	#$FF,D0
	add.w	D0,D0
	move.w	D0,$50(A2)
	bra.s	lbC002432

lbC002474:
	cmpi.b	#$FC,D0
	bne.s	lbC002490
	move.w	lbW002DCA(pc),D0
	cmpi.w	#$FFFF,D0
	beq.s	lbC002464
	move.w	#$FFFF,lbW002DC8
	bra.s	lbC002468

lbC002490:
	cmpi.b	#$FD,D0
	bne.s	lbC0024B2
	move.w	lbW002DCA(pc),D0
	cmpi.w	#$FFFF,D0
	beq.s	lbC0024AC
	move.w	#$FFFF,lbW002DC8
	bra.s	lbC002468

lbC0024AC:
	addq.w	#2,$50(A2)
	bra.W	lbC002432

lbC0024B2:
	add.w	D0,D0
	add.w	D0,D0
	movea.l	lbL002DA8(pc),A0
	cmpa.l	#0,a0
	beq.w	lbC002432
	movea.l	0(A0,D0.W),A0
lbC0024BE:
	move.b	$52(A2),D0
	andi.w	#$FF,D0
	move.b	0(A0,D0.W),D0
	cmpi.b	#$F9,D0
	bcs.s	lbC002518
	cmpi.b	#$FF,D0
	bne.s	lbC0024E2
	clr.b	$52(A2)
	addq.w	#2,$50(A2)
	bra.w	lbC002432

lbC0024E2:
	cmpi.b	#$F9,D0
	bne.s	lbC0024F0
	addq.b	#1,$52(A2)
	bra.w	lbC002580

lbC0024F0:
	cmpi.b	#$FE,D0
	bne.s	lbC002518
	move.b	$52(A2),D0
	andi.w	#$FF,D0
	addq.w	#1,D0
	move.b	0(A0,D0.W),D1
	asl.w	#8,D1
	addq.w	#1,D0
	move.b	0(A0,D0.W),D1
	move.w	D1,$2C(A2)
	addq.b	#3,$52(A2)
	bra.b	lbC002580

lbC002518:
	tst.b	D0
	bpl.s	lbC002528
	andi.w	#$7F,D0
	move.w	D0,(A2)
	addq.b	#1,$52(A2)
	bra.s	lbC0024BE

lbC002528:
	btst	#6,D0
	beq.s	lbC002542
	andi.w	#$3F,D0
	move.b	D0,$57(A2)
	move.b	D0,$56(A2)
	addq.b	#1,$52(A2)
	bra.b	lbC0024BE

lbC002542:
	andi.w	#$FF,D0
	move.w	D3,D1
	move.w	D0,D2
	move.w	(A2),D0
	cmpi.w	#$78,D0
	beq.s	lbC00255C
	bsr.w	lbC002340
	cmpi.b	#$FF,D0
	beq.s	lbC00257C
lbC00255C:
	move.w	D2,D0
	add.b	$53(A2),D0
	cmpi.b	#$54,D0
	blt.s	lbC00256A
	moveq	#$54,D0
lbC00256A:
	move.w	D0,$54(A2)
	add.w	D0,D0
	lea	lbW002000(PC),A0
	move.w	0(A0,D0.W),D0
	move.w	D0,$2A(A2)
lbC00257C:
	addq.b	#1,$52(A2)
lbC002580:
	lea	$5A+2(A2),A2
	addq.w	#1,D3
	cmpi.w	#4,D3
	blt.w	lbC002424
lbC00258E:
	movem.l	(SP)+,D2-D6/A2-A6
	rts

lbW002594:
	dc.w	1,2,4,8
lbL00259C:
	dc.l	0
lbL0025A0:
	dc.l	0
lbL0025A4:
	dc.l	0
lbL0025A8:
	dc.l	0
lbL0025AC:
	dc.l	0

;	dc.l	$2000000,$FC00FE,$FB0000,$FC00FE,$FBFE00,0,0,0
;	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
;	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
;	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
;	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
;	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
;	dc.l	$2000100,$400FE00,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
;	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
;	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
;	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
;	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
;	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,$200FE00,0,0,0,0,0,0,0,0
;	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
;	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
;	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
;	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
;	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$3000303
;	dc.l	$3050300,$FE000000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
;	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
;	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
;	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
;	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
;	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,$10B0220,$42B0324
;	dc.l	$82410915,$9150915,$915FF00,0,0,0,0,0,0,0,0,0,0,0
;	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
;	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
;	dc.l	0,0,$85,$472D4330,$32473547,$39473743,$35324734
;	dc.l	$43302FFF,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
;	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
;	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$5FF9F9FF,0
;	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
;	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
;	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,$402D7EFE,$1FF00,0,0,0
;	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
;	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
;	dc.l	0,0,0,0,0,0,0,0,0,0,$41,$86008900,$88008900
;	dc.l	$860088,$890086,$8800,$86008A00,$86008800
;	dc.l	$86004186,$890088,$890000,$86008800,$89008600
;	dc.l	$880086,$408800,$418600,$88008600,$FF000000,0,0,0
;	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
;	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
;	dc.l	0,0,0,0,0,0,0,0,0,0
;	dc.w	0
Play_3_3
	movem.l	D2-D6/A2-A6,-(SP)
	moveq	#0,D3
	lea	lbW003746(PC),A2
lbC00335C:
	bsr.w	lbC002386
	tst.w	6(A2)
	beq.s	lbC00336C
	subq.w	#1,6(A2)
	bne.s	lbC003382
lbC00336C:
	movea.l	2(A2),A3
lbC003370:
	move.w	(A3)+,D0
	movea.l	lbL0033A0(PC,D0.W),A0
	moveq	#0,D2
	jsr	(A0)
	tst.w	D2
	beq.s	lbC003370
	move.l	A3,2(A2)
lbC003382:
	bsr.w	lbC00351A
	bsr.w	lbC0034A4
	bsr.w	lbC003400
	lea	$5A+2(A2),A2
	addq.w	#1,D3
	cmpi.w	#4,D3
	blt.s	lbC00335C
	movem.l	(SP)+,D2-D6/A2-A6
	rts

lbL0033A0:
	dc.l	lbC00365A,lbC003612,lbC0035D4,lbC0035EC,lbC0035FC
	dc.l	lbC00360C,lbC003616,lbC003634,lbC003668,lbC003670
	dc.l	lbC00367A,lbC003682,lbC00368E,lbC003696,lbC003572
	dc.l	lbC003578,lbC003594,lbC0035B0,lbC003612,lbC00357E
	dc.l	lbC003542,lbC00355C,lbC0036B0,lbC00370C

lbC003400:
	move.b	lbB002DD7(pc),D0
	move.b	lbW002DDA(pc),D1
	move.b	lbB002DDB(pc),D7
	add.b	D1,D0
	tst.b	D1
	bpl.s	lbC003428
	cmp.b	D7,D0
	bhi.s	lbC00342C
lbC00341C:
	move.b	D7,D0
	move.b	#0,lbW002DDA
	bra.s	lbC00342C

lbC003428:
	cmp.b	D7,D0
	bcc.s	lbC00341C
lbC00342C:
	move.b	D0,lbB002DD7
	move.b	D0,lbB002DD9
	moveq	#0,D1
	move.b	lbB002DD7(pc),D1
	lsr.b	#2,D1
	move.w	$2E(A2),D0
	move.w	#10,D7
	lsr.w	D7,D0
	cmp.b	D1,D0
	ble.s	lbC003452
	move.b	D1,D0
lbC003452:
	lea	$DFF000,A0
	move.w	D3,D7
	lsl.w	#4,D7
	adda.w	D7,A0

	bsr.w	ChangeVolume		; inserted

	move.w	D0,$A8(A0)

	move.w	$2A(A2),D1
	move.w	D1,$A6(A0)
	move.l	$3C(A2),D0
	beq.W	lbC003494	;branch extended...

;		bsr.w	DMAWait

	moveq	#0,D0
	move.w	$38(A2),D0
	asl.l	#1,D0
	move.l	$34(A2),D1
	add.l	D0,D1
	move.l	D1,D7
	move.l	$3C(A2),D0
	sub.l	D0,D1
	move.l	D1,$A0(A0)
	move.w	$38(A2),D0
	move.w	D0,$A4(A0)

	move.l	#$38,lenoffset
	bra.w	analyzer

lbC003494:
	bra.w	analyzer_2

lbC0034A4:
	move.w	$4E(A2),D1
	move.w	$46(A2),D0
	cmpi.b	#$FF,D0
	beq.s	lbC0034CA
	subq.b	#1,$47(A2)
	andi.w	#$FF00,D0
	add.w	D0,D1
	bcc.s	lbC003510
	move.w	#$FF00,D1
	move.w	#$FFFF,$46(A2)
	bra.s	lbC003510

lbC0034CA:
	move.w	$48(A2),D0
	cmpi.b	#$FF,D0
	beq.s	lbC0034EA
	subq.b	#1,$49(A2)
	andi.w	#$FF00,D0
	sub.w	D0,D1
	bcc.s	lbC003510
	moveq	#0,D1
	move.w	#$FFFF,$48(A2)
	bra.s	lbC003510

lbC0034EA:
	move.w	$4A(A2),D0
	cmpi.w	#$FFFF,D0
	beq.s	lbC0034FA
	subq.w	#1,$4A(A2)
	bra.s	lbC003510

lbC0034FA:
	move.w	$4C(A2),D0
	cmpi.w	#$FFFF,D0
	beq.s	lbC003518
	sub.w	D0,D1
	bcc.s	lbC003510
	moveq	#0,D1
	move.w	#$FFFF,$4C(A2)
lbC003510:
	move.w	D1,$4E(A2)
	move.w	D1,$2E(A2)
lbC003518:
	rts

lbC00351A:
	move.w	$28(A2),D0
	add.w	D0,$2A(A2)
	move.w	$26(A2),D1
	beq.s	lbC00352C
	subq.w	#1,D1
	bra.s	lbC003534

lbC00352C:
	move.w	$24(A2),D1
	neg.w	$28(A2)
lbC003534:
	move.w	D1,$26(A2)
	move.w	$2C(A2),D0
	add.w	D0,$2A(A2)
	rts

lbC003542:
	move.w	(A3)+,D0
	andi.w	#$FF,D0
	move.w	D0,$54(A2)
	add.w	D0,D0
	lea	lbW002000(PC),A0
	move.w	0(A0,D0.W),D0
	move.w	D0,$2A(A2)
	rts

lbC00355C:
	move.w	(A3)+,D0
	add.w	$54(A2),D0
	add.w	D0,D0
	lea	lbW002000(PC),A0
	move.w	0(A0,D0.W),D0
	move.w	D0,$2A(A2)
	rts

lbC003572:
	move.w	(A3)+,$2A(A2)
	rts

lbC003578:
	move.w	(A3)+,$2E(A2)
	rts

lbC00357E:
	move.w	(A3)+,$46(A2)
	move.w	(A3)+,$48(A2)
	move.w	(A3)+,$4A(A2)
	move.w	(A3)+,$4C(A2)
	clr.w	$4E(A2)
	rts

lbC003594:
	lea	lbW002594(PC),A0
	move.w	D3,D0
	add.w	D0,D0
	move.w	0(A0,D0.W),D0
	ori.w	#$8000,D0
	lea	$DFF000,A0

	bsr.w	DMAWait

	move.w	D0,$96(A0)

	bsr.w	DMAWait

	rts

lbC0035B0:
	lea	lbW002594(PC),A0
	move.w	D3,D0
	add.w	D0,D0
	move.w	0(A0,D0.W),D0
	lea	$DFF000,A0
	move.w	D0,$96(A0)
	move.w	D3,D0
	asl.w	#4,D0
	adda.w	D0,A0
	bsr.w	lbC003494
	moveq	#1,D2
	rts

lbC0035D4:
	move.w	(A3)+,D0
	add.w	D0,D0
	add.w	D0,D0
	movea.l	lbL002D90(pc),A0
	move.l	0(A0,D0.W),D0
	move.l	D0,$34(A2)
	move.l	D0,$30(A2)
	rts

lbC0035EC:
	moveq	#0,D0
	move.w	(A3)+,D0
	move.l	D0,$3C(A2)
	lsr.w	#1,D0
	move.w	D0,$38(A2)
	rts

lbC0035FC:
	move.l	(A3)+,D0
	move.l	D0,$3C(A2)
	beq.s	lbC00360A
	lsr.w	#1,D0
	move.w	D0,$38(A2)
lbC00360A:
	rts

lbC00360C:
	move.w	(A3)+,D0
	move.w	D0,6(A2)
lbC003612:
	moveq	#1,D2
	rts

lbC003616:
	move.w	8(A2),D1
	move.w	D1,10(A2)
	move.w	(A3)+,12(A2,D1.W)
	add.w	D1,D1
	move.l	A3,$14(A2,D1.W)
	addq.w	#2,8(A2)
	andi.w	#6,8(A2)
	rts

lbC003634:
	move.w	10(A2),D1
	move.w	12(A2,D1.W),D0
	beq.s	lbC003644
	subq.w	#1,12(A2,D1.W)
	beq.s	lbC00364C
lbC003644:
	add.w	D1,D1
	movea.l	$14(A2,D1.W),A3
	rts

lbC00364C:
	tst.w	D1
	beq.s	lbC003658
	subq.w	#2,8(A2)
	subq.w	#2,10(A2)
lbC003658:
	rts

lbC00365A:
	lea	lbL00373A(PC),A3
	clr.w	$44(A2)
	bsr.w	lbC0035B0
	rts

lbC003668:
	move.l	(A3)+,D0
	add.l	D0,$34(A2)
	rts

lbC003670:
	move.w	(A3)+,D0
	asr.w	#1,D0
	add.w	D0,$38(A2)
	rts

lbC00367A:
	move.l	(A3)+,D0
	add.l	D0,$3C(A2)
	rts

lbC003682:
	move.w	(A3)+,D0
	add.w	$2A(A2),D0
	move.w	D0,$2A(A2)
	rts

lbC00368E:
	move.w	(A3)+,D0
	add.w	D0,$2E(A2)
	rts

lbC003696:
	moveq	#0,D1
	move.b	(A3),D1
	move.w	(A3)+,D0
	andi.w	#$FF,D0
	move.w	D1,$28(A2)
	move.w	D0,$24(A2)
	lsr.w	#1,D0
	move.w	D0,$26(A2)
	rts

lbC0036B0:
	moveq	#0,D0
	move.b	(A3)+,D0
	add.w	D0,D0
	add.w	D0,D0
	movea.l	lbL002D90(pc),A1
	movea.l	0(A1,D0.W),A0
	move.b	(A3)+,D0
	add.w	D0,D0
	add.w	D0,D0
	movea.l	0(A1,D0.W),A1
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	rts

lbC00370C:
	move.w	(A3)+,D0
	add.w	D0,D0
	add.w	D0,D0
	movea.l	lbL002D90(pc),A0
	movea.l	0(A0,D0.W),A0
	movea.l	$30(A2),A1
	moveq	#$7F,D0
lbC003720:
	cmpm.b	(A0)+,(A1)+
	bhi.s	lbC003730
	beq.s	lbC003734
	addq.b	#1,-1(A1)
	dbra	D0,lbC003720
	rts

lbC003730:
	subq.b	#1,-1(A1)
lbC003734:
	dbra	D0,lbC003720
	rts

lbL00373A:
	dc.l	$180000,$48001C,0
lbW003746:
	dc.w	0
	dc.l	lbL00373A,0,0,0,0,0,0,0,0,0,0,$8000000,0,0,0
	dc.l	$FFFF,0,$FFFFFFFF,$FFFFFFFF,0,0,$1010000

		dc.w	0

	dc.w	0
	dc.l	lbL00373A,0,0,0,0,0,0,0,0,0,0,$9000000,0,0,0
	dc.l	$FFFF,0,$FFFFFFFF,$FFFFFFFF
	DC.W	0
CurrentPos3
	DC.W	0
	DC.L	0,$1010000

		dc.w	2

	dc.w	0
	dc.l	lbL00373A,0,0,0,0,0,0,0,0,0,0,$A000000,0,0,0
	dc.l	$FFFF,0,$FFFFFFFF,$FFFFFFFF,0,0,$1010000

		dc.w	4

	dc.w	0
	dc.l	lbL00373A,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$FFFF,0
	dc.l	$FFFFFFFF,$FFFFFFFF,0,0,$1010000

		dc.w	6

lbL002D88
	dc.l	0
lbL002D8C
	dc.l	0
lbL002D90
	dc.l	0
lbL002D94
	dc.l	0
lbL002D98
	dc.l	0
lbL002D9C
	dc.l	0
lbL002DA0
	dc.l	0
lbL002DA4
	dc.l	0
lbL002DA8
	dc.l	0
lbL002DAC
	dc.l	0
lbL002DB0
	dc.l	0
lbL002DB4
	dc.l	0
lbL002DB8
	dc.l	0
lbL002DBC
	dc.l	0
lbL002DC0
	dc.l	0
lbL002DC4
	dc.l	0
lbW002DC8
	dc.w	-1
lbW002DCA
	dc.w	-1
lbL002DCC
	dc.l	0
;lbL002DD0
	dc.l	0
lbW002DD4
	dc.w	0
lbW002DD6
	dc.b	0
lbB002DD7
	dc.b	0
;lbB002DD8
	dc.b	0
lbB002DD9
	dc.b	0
lbW002DDA
	dc.b	0
lbB002DDB
	dc.b	0
lbW002DDC
	dc.w	0
lbW002DDE
	dc.w	0
lbW002DE0
	dc.w	-1

	Section Empty,BSS_C
Empty
	ds.b	4

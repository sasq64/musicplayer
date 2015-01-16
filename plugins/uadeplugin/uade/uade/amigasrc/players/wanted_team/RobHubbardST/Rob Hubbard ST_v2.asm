	******************************************************
	****   Rob Hubbard ST replayer for EaglePlayer    ****
	****        all adaptions by Wanted Team,         ****
	****     DeliTracker 2.32 compatible version      ****
	******************************************************

	incdir	"dh2:include/"
	include 'misc/eagleplayer2.01.i'

	SECTION	Player,CODE

	PLAYERHEADER Tags

	dc.b	'$VER: Rob Hubbard ST player module V1.1 (29 July 2001)',0
	even
Tags
	dc.l	DTP_PlayerVersion,2
	dc.l	EP_PlayerVersion,9
	dc.l	DTP_RequestDTVersion,'WT'
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
	dc.l	EP_ModuleChange,ModuleChange
	dc.l	EP_StructInit,StructInit
	dc.l	DTP_Volume,SetVolume
	dc.l	DTP_Balance,SetBalance
	dc.l	EP_Voices,SetVoices
	dc.l	EP_GetPositionNr,GetPosition
	dc.l	EP_SampleInit,SampleInit
	dc.l	EP_Flags,EPB_Songend!EPB_NextSong!EPB_PrevSong!EPB_Volume!EPB_Balance!EPB_Voices!EPB_Analyzer!EPB_ModuleInfo!EPB_SampleInfo!EPB_Packable!EPB_Restart
	dc.l	TAG_DONE
PlayerName
	dc.b	'Rob Hubbard ST',0
Creator
	dc.b	'(c) 1987-88 by Rob Hubbard and Steve',10
	dc.b	'Bak, adapted by Wanted Team',0
Prefix
	dc.b	'RHO.',0
	even
ModulePtr
	dc.l	0
PlayPtr
	dc.l	0
EndPtr
	dc.l	0
InitPtr
	dc.l	0
SongPtr
	dc.l	0
Change
	dc.w	0
EagleBase
	dc.l	0
TablePtr
	dc.l	0
CurrentPos
	dc.l	0
LongAddress
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
	move.l	ModulePtr(PC),D0
	beq.b	return
	move.l	D0,A2

	moveq	#3,D5

Synth	jsr	ENPP_AllocSampleStruct(A5)
	move.l	D0,(A3)
	beq.b	return
	move.l	D0,A3

	move.w	#USITY_AMSynth,EPS_Type(A3)
	dbf	D5,Synth

	moveq	#0,D7
return
	move.l	D7,D0
	rts

***************************************************************************
**************************** EP_GetPositionNr *****************************
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
**************************** EP_ModuleChange ******************************
***************************************************************************

ModuleChange
	move.w	Change(PC),D0
	bne.s	NoChange
	move.l	PlayPtr(PC),EPG_ARG1(A5)
	lea	PatchTable(PC),A1
	move.l	A1,EPG_ARG3(A5)
	move.l	#1600,D1
	move.l	D1,EPG_ARG2(A5)
	moveq	#-2,D0
	move.l	D0,EPG_ARG5(A5)		
	moveq	#1,D0
	move.l	D0,EPG_ARG4(A5)			;Search-Modus
	moveq	#5,D0
	move.l	D0,EPG_ARGN(A5)
	move.l	EPG_ModuleChange(A5),A0
	jsr	(A0)
NoChange
	move.w	#1,Change
	moveq	#0,D0
	rts

***************************************************************************
******************************* DTP_Check2 ********************************
***************************************************************************

Check2
	movea.l	dtg_ChkData(A5),A0
	moveq	#-1,D0

	cmp.l	#$00407F40,(A0)+
	bne.b	fail
	cmp.l	#$00C081C0,(A0)
	bne.b	fail
	cmp.l	#$41FAFFEE,52(A0)
	bne.b	fail
	moveq	#0,D0
fail
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
Calcsize	=	36
Step		=	44

InfoBuffer
	dc.l	MI_SubSongs,0		;4
	dc.l	MI_LoadSize,0		;12
	dc.l	MI_Songsize,0		;20
	dc.l	MI_Length,0		;28
	dc.l	MI_Calcsize,0		;36
	dc.l	MI_Steps,0		;44
	dc.l	MI_SynthSamples,4
	dc.l	MI_Voices,3
	dc.l	MI_MaxVoices,3
	dc.l	MI_Prefix,Prefix
	dc.l	0

***************************************************************************
***************************** DTP_Intterrupt ******************************
***************************************************************************

Interrupt	
	movem.l	D1-D7/A0-A6,-(SP)

	lea	StructAdr(PC),A4
	st	UPS_Enabled(A4)
	clr.w	UPS_Voice1Per(A4)
	clr.w	UPS_Voice2Per(A4)
	clr.w	UPS_Voice3Per(A4)
	move.w	#UPSB_Adr!UPSB_Len!UPSB_Per!UPSB_Vol,UPS_Flags(A4)

	lea	Buffer,A5
	move.l	PlayPtr(PC),A0
	jsr	(A0)			; play module

	clr.w	UPS_Enabled(A4)

	movem.l	(SP)+,D1-D7/A0-A6
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

	lea	InfoBuffer(PC),A4
	move.l	D0,LoadSize(A4)
	lea	Buffer,A0
	lea	5000(A0),A1
ClearBuffer
	clr.l	(A0)+
	cmp.l	A0,A1
	bne.b	ClearBuffer

	move.l	ModulePtr(PC),A0
	cmp.w	#$FB2C,320(A0)
	bne.b	SkipJP
	move.w	#$FEF4,320(A0)			; sample fix for Jupiter Probe
SkipJP
	lea	180(A0),A2

FindPlay
	cmp.w	#$4E75,(A2)+
	bne.b	FindPlay
	move.l	A2,(A6)+			; PlayPtr
FindEnd
	cmp.w	#$DFFC,(A2)+
	bne.b	FindEnd
	addq.l	#4,A2
	move.l	A2,(A6)+			; EndPtr
FindInit
	cmp.w	#$4E75,(A2)+
	bne.b	FindInit
	move.l	A2,(A6)+			; InitPtr
	cmp.w	#$46DF,-4(A2)
	bne.b	FindIt1
	move.w	#$4E71,-4(A2)			; SR patch
FindIt1
	cmp.w	#$7E02,(A2)+
	bne.b	FindIt1
	move.l	A2,A3
	add.w	2(A2),A3
	addq.l	#2,A3
	move.l	A3,(A6)+			; SongPtr
	clr.w	(A6)+				; clearing change flag

	move.l	A5,(A6)+			; EagleBase

	move.l	(A3),D0
	divu.w	#12,D0
	move.w	D0,SubSongs+2(A4)
	mulu.w	#3,D0
	subq.l	#1,D0
	moveq	#0,D5

NextStep
	move.l	SongPtr(PC),A1
	add.l	(A3)+,A1
NextLong
	move.l	(A1)+,D1
	beq.b	FoundZero
	cmp.l	D1,D5
	bgt.b	MaxStep
	move.l	D1,D5
MaxStep
	bra.b	NextLong
FoundZero
	dbf	D0,NextStep

	move.l	SongPtr(PC),A1
	add.l	D5,A1
FindLast
	cmp.b	#$87,(A1)+
	bne.b	FindLast
	move.l	A1,A3
	sub.l	A0,A1
	move.l	A1,Calcsize(A4)
	move.l	A1,Songsize(A4)
	moveq	#0,D0
	subq.l	#1,A3
TestIt
	cmp.b	#$87,(A3)
	beq.b	FindStep
	tst.b	(A3)
	bne.b	NoFirst
	tst.b	-1(A3)
	beq.b	FirstStep
	bra.b	NoFirst

FindStep
	addq.l	#1,D0
NoFirst
	subq.l	#1,A3
	bra.b	TestIt

FirstStep
	move.l	D0,Step(A4)

FindRTS
	cmp.w	#$4E75,(A2)+
	bne.b	FindRTS
	move.w	2(A2),Half+2
	move.w	#$FFF8,6(A2)			; branch patch
	cmp.w	#$46DF,-4(A2)
	bne.b	FindIt2
	move.w	#$4E71,-4(A2)			; SR patch
FindIt2
	cmp.l	#$08290003,(A2)
	beq.b	PatchIt
	addq.l	#2,A2
	bra.b	FindIt2
PatchIt
	move.w	#$FFF6,8(A2)			; branch patch

FindOP
	cmp.l	#$E548D1F0,(A0)
	beq.b	OK
	addq.l	#2,A0
	bra.b	FindOP
OK
	subq.l	#2,A0
	add.w	(A0),A0
	add.l	(A0),A0
	move.l	A0,(A6)				; TablePtr

	bsr.w	ModuleChange

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

	lea	CurrentPos(PC),A0
	clr.l	(A0)+
	moveq	#0,D0
	move.w	dtg_SndNum(A5),D0
	move.w	D0,D2
	move.l	SongPtr(PC),A3
FindMaxLength
	moveq	#2,D3
	moveq	#0,D5

NextLength
	move.l	SongPtr(PC),A2
	add.l	(A3)+,A2
	move.l	A2,D4
	moveq	#-1,D1
Zero
	addq.l	#1,D1
	tst.l	(A2)+
	bne.b	Zero
	cmp.l	D1,D5
	bgt.b	MaxLength
	move.l	D1,D5
	move.l	D4,(A0)				; LongAddress
MaxLength
	dbf	D3,NextLength
	dbf	D2,FindMaxLength

	lea	InfoBuffer(PC),A1
	move.l	D5,Length(A1)

	lea	Buffer,A5
	move.l	InitPtr(PC),A0
	jsr	(A0)
Half
	st	'WT'(A5)
	rts

***************************************************************************
***************************** DTP_EndSound ********************************
***************************************************************************

EndSound
	lea	Buffer,A5
	move.l	EndPtr(PC),A0
	jsr	(A0)
	move.w	#15,$DFF096
	rts

	*--------------- PatchTable for Rob Hubbard ST ------------------*

PatchTable
	dc.w	Code0-PatchTable,(Code0End-Code0)/2-1,Patch0-PatchTable
	dc.w	Code1-PatchTable,(Code1End-Code1)/2-1,Patch1-PatchTable
	dc.w	Code2-PatchTable,(Code2End-Code2)/2-1,Patch2-PatchTable
	dc.w	Code3-PatchTable,(Code3End-Code3)/2-1,Patch3-PatchTable
	dc.w	Code4-PatchTable,(Code4End-Code4)/2-1,Patch4-PatchTable
	dc.w	Code5-PatchTable,(Code5End-Code5)/2-1,Patch5-PatchTable
	dc.w	Code6-PatchTable,(Code6End-Code6)/2-1,Patch6-PatchTable
	dc.w	Code7-PatchTable,(Code7End-Code7)/2-1,Patch7-PatchTable
	dc.w	Code8-PatchTable,(Code8End-Code8)/2-1,Patch8-PatchTable
	dc.w	Code9-PatchTable,(Code9End-Code9)/2-1,Patch9-PatchTable
	dc.w	0

; SongEnd patch for Rob Hubbard ST modules

Code0
	ANDI.L	#$3F,D0
Code0End
Patch0
	cmp.b	#$8E,D0
	bne.b	SkipEnd2
	bsr.w	SongEnd

SkipEnd2
	andi.l	#$3F,D0
	rts

; SongEnd and Position Counter patch for Rob Hubbard ST modules

Code1
	MOVE.L	(A0),D0
	BNE.S	lbC000420
	MOVEA.L	8(A1),A0
	MOVE.L	#4,12(A1)
	MOVE.L	(A0),D0
lbC000420
Code1End
Patch1
	move.l	D1,-(A7)
	move.l	LongAddress(PC),D1
	move.l	(A0),D0
	bne.b	SkipEnd
	move.l	8(A1),A0
	cmp.l	8(A1),D1
	bne.b	Skip1
	bsr.w	SongEnd
Skip1
	move.l	#4,12(A1)
	move.l	(A0),D0
SkipEnd
	cmp.l	8(A1),D1
	bne.b	Skip2
	move.l	12(A1),CurrentPos
Skip2
	move.l	(A7)+,D1
	rts

; SR patch for Rob Hubbard ST modules

Code2
	MOVE.W	SR,-(SP)
	MOVE.W	#$2700,SR
Code2End
Patch2
	rts

; Volume patch for voice 2

Code3
	MOVE.W	D0,$DFF0B8
Code3End
Patch3
	bsr.w	Right1
	move.w	D0,$DFF0B8
	move.w	D0,UPS_Voice2Vol(A4)
	rts

; Address/period/length patch for voice 2

Code4
	MOVE.L	A1,$DFF0B0
	LSL.W	#2,D0
	MOVE.W	D0,$DFF0B6
	MOVE.W	D1,$DFF0B4
Code4End
Patch4
	move.l	A1,$DFF0B0
	move.l	A1,UPS_Voice2Adr(A4)
	lsl.w	#2,D0
	move.w	D0,$DFF0B6
	move.w	D0,UPS_Voice2Per(A4)
	move.w	D1,$DFF0B4
	move.w	D1,UPS_Voice2Len(A4)
	rts

; Volume patch for voice 3

Code5
	MOVE.W	D0,$DFF0C8
Code5End
Patch5
	bsr.w	Right2
	move.w	D0,$DFF0C8
	move.w	D0,UPS_Voice3Vol(A4)
	rts

; Address/period/length patch for voice 3

Code6
	MOVE.W	D0,$DFF0C6
Code6End
Patch6
	move.l	ModulePtr(PC),A1
	lea	$28(A1),A1
	move.l	A1,UPS_Voice3Adr(A4)
	move.w	D0,$DFF0C6
	move.w	D0,UPS_Voice3Per(A4)
	move.w	#4,UPS_Voice3Len(A4)
	rts

; Volume patch for voice 1

Code7
	MOVE.W	D0,$DFF0A8
Code7End
Patch7
	bsr.w	Left1
	move.w	D0,$DFF0A8
	move.w	D0,UPS_Voice1Vol(A4)
	rts

; Address/period/length patch for voice 1

Code8
	MOVE.W	D0,$DFF0A6
Code8End
Patch8
	move.l	ModulePtr(PC),A1
	addq.l	#8,A1
	move.l	A1,UPS_Voice1Adr(A4)
	move.w	D0,$DFF0A6
	move.w	D0,UPS_Voice1Per(A4)
	move.w	#4,UPS_Voice1Len(A4)
	rts

; Initialization patch for Rob Hubbard ST modules

Code9
	MOVE.L	A2,8(A1)
	MOVE.W	#1,$28(A1)
Code9End
Patch9
	move.l	A2,8(A1)
	move.w	#1,$28(A1)
	move.l	TablePtr(PC),$18(A1)
	move.l	TablePtr(PC),$14(A1)
	rts

	Section	RHO_Buffer,BSS
Buffer
	ds.b	5000
	end

	****************************************************
	****    Rob Hubbard replayer for Eagleplayer	****
	****    all adaptions by Eagleeye of DEFECT,	****
	****    small (?) updates done by Wanted Team	****
	****     DeliTracker 2.32 compatible version	****
	****************************************************

	incdir	"dh2:include/"
	include	'misc/Eagleplayer2.01.i'

	SECTION	Player,CODE

	PLAYERHEADER Tags

	dc.b	"$VER: Rob Hubbard player module V1.4 (7 July 2001)",0
	even
Tags
	dc.l	EP_PlayerVersion,9
	dc.l	DTP_PlayerVersion,6
	dc.l	DTP_RequestDTVersion,'WT'
	dc.l	DTP_PlayerName,PlayerName
	dc.l	DTP_Creator,Creator
	dc.l	DTP_Check2,Check2
	dc.l	DTP_Interrupt,Interrupt
	dc.l	DTP_InitPlayer,InitPlayer
	dc.l	DTP_InitSound,InitSound
	dc.l	DTP_EndPlayer,EndPlayer
	dc.l	DTP_EndSound,EndSound
	dc.l	DTP_Volume,SetVolume
	dc.l	DTP_Balance,SetBalance
	dc.l	EP_Voices,SetVoices
	dc.l	EP_StructInit,StructInit
	dc.l	EP_Get_ModuleInfo,GetInfos
	dc.l	EP_SampleInit,SampleInit
	dc.l	DTP_SubSongRange,SubSongRange
	dc.l	EP_GetPositionNr,GetPosition
	dc.l	EP_ModuleChange,ModuleChange
	dc.l	EP_Flags,EPB_Songend!EPB_NextSong!EPB_PrevSong!EPB_Volume!EPB_Balance!EPB_Voices!EPB_Analyzer!EPB_ModuleInfo!EPB_SampleInfo!EPB_Packable!EPB_Restart
	dc.l	0

PlayerName
	dc.b	"Rob Hubbard",0
Creator
	dc.b	"(c) 1989-91 by Rob Hubbard,",10
	dc.b	"adapted by Eagleeye/DFT & Wanted Team",0
Prefix
	dc.b	"RH.",0
	even
ModulePtr
	dc.l	0
Change
	dc.w	0
SamplePtr
	dc.l	0
address
	dc.l	0
EagleBase
	dc.l	0
SongEnd
	dc.l	'WTWT'
CurrentPos
	dc.l	0
Hardware
	dc.l	$00DF0000
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
***************************** DTP_EndPlayer *******************************
***************************************************************************

EndPlayer
	movea.l	dtg_AudioFree(A5),A0
	jmp	(A0)

***************************************************************************
***************************** DTP_EndSound ********************************
***************************************************************************

EndSound
	move.l	ModulePtr(PC),A0	; module buffer
	jmp	8(A0)

***************************************************************************
**************************** EP_GetPositionNr *****************************
***************************************************************************

GetPosition
	move.l	CurrentPos(PC),D0
	lsr.l	#2,D0
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
Steps		=	76
Length		=	84

InfoBuffer
	dc.l	MI_SubSongs,0		;4
	dc.l	MI_LoadSize,0		;12
	dc.l	MI_Songsize,0		;20
	dc.l	MI_SamplesSize,0	;28
	dc.l	MI_Samples,0		;36
	dc.l	MI_Calcsize,0		;44
	dc.l	MI_MaxSamples,13	;
	dc.l	MI_SynthSamples,3	;
	dc.l	MI_MaxSynthSamples,3	;
	dc.l	MI_Steps,0		;76
	dc.l	MI_Length,0		;84
	dc.l	MI_Prefix,Prefix
	dc.l	0

***************************************************************************
******************************* EP_SampleInit *****************************
***************************************************************************

SampleInit
	moveq	#EPR_NotEnoughMem,D7
	lea	EPG_SampleInfoStructure(A5),A3
	move.l	SamplePtr(PC),D0
	beq.b	return
	move.l	D0,A2

	move.l	InfoBuffer+Samples(PC),d5
	moveq	#13,D3
	sub.l	D5,D3
	subq.l	#1,D5

Normal
	jsr	ENPP_AllocSampleStruct(A5)
	move.l	D0,(A3)
	beq.b	return
	move.l	D0,A3

	move.l	(A2),D0
	addq.l	#6,D0
	move.l	A2,EPS_Adr(A3)			; sample address
	move.l	D0,EPS_Length(A3)		; sample length
	move.l	#64,EPS_Volume(A3)
	move.w	#USITY_RAW,EPS_Type(A3)
	move.w	#USIB_Playable!USIB_Saveable!USIB_8BIT,EPS_Flags(A3)
	add.l	D0,A2
	dbf	D5,Normal
	tst.l	D3
	beq.b	NoEmpty
	subq.l	#1,D3

Empty
	jsr	ENPP_AllocSampleStruct(A5)
	move.l	D0,(A3)
	beq.b	return
	move.l	D0,A3

	clr.l	EPS_Length(A3)
	move.w	#USITY_RAW,EPS_Type(A3)
	dbf	D3,Empty

NoEmpty
	moveq	#2,D5

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
******************************* EP_StructInit *****************************
***************************************************************************

StructInit
	lea	StructAdr(PC),A0
	rts

***************************************************************************
******************************* DTP_Check2 ********************************
***************************************************************************

Check2
	move.l	dtg_ChkData(A5),A0
	moveq	#-1,D0
	move.w	#$6000,D1
	cmp.w	(A0),D1
	bne.s	Return
	cmp.w	4(A0),D1
	bne.s	Return
	cmp.w	8(A0),D1
	bne.s	Return
	cmp.w	12(A0),D1
	bne.s	Return
	cmp.w	16(A0),D1
	bne.s	Return
	cmp.w	#$41FA,20(A0)
	bne.s	Return
	cmp.l	#$4E7541FA,28(A0)
	bne.s	Return
	moveq	#0,D0
Return
	rts					;Found

***************************************************************************
**************************** EP_ModuleChange ******************************
***************************************************************************

ModuleChange
	move.w	Change(PC),D0
	bne.s	NoChange
	move.l	ModulePtr(PC),EPG_ARG1(A5)
	lea	PatchTable(PC),A1
	move.l	A1,EPG_ARG3(A5)
	move.l	#900,D1
	move.l	D1,EPG_ARG2(A5)
	moveq	#-2,D0
	move.l	d0,EPG_ARG5(A5)		
	moveq	#1,D0
	move.l	d0,EPG_ARG4(A5)			;Search-Modus
	moveq	#5,D0
	move.l	d0,EPG_ARGN(A5)
	move.l	EPG_ModuleChange(A5),A0
	jsr	(A0)
NoChange
	move.w	#1,Change
	moveq	#0,D0
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
	move.l	dtg_GetListData(A5),A0
	jsr	(A0)

	lea	ModulePtr(PC),A6
	move.l	A0,(A6)+			; module buffer
	clr.w	(A6)+				; clearing change flag
	lea	InfoBuffer(PC),A1
	move.l	D0,LoadSize(A1)

	move.l	ModulePtr(PC),A3
	lea	64(A3),A2
	moveq	#7,D4
loop2
	cmp.w 	#$2418,(A2)+
	beq.b 	found2
	dbf	D4,loop2
	bra.b	Error
found2
	moveq	#0,D3
	move.b	-3(A2),D3
	move.l	D3,D6
	addq.l	#1,D6				; D6 = samples

	lea	54(A3),A2
	moveq	#4,D4
loop3
	cmp.w 	#$41FA,(A2)+
	beq.b 	found3
	dbf	D4,loop3
Error
	moveq	#EPR_CorruptModule,D0		; error message
	rts
found3
	moveq	#0,D4
	move.w	(A2),D4
	lea	(A2),A4
	add.w	D4,A2
	sub.l	A3,A2
	move.l	A2,D4
	addq.l	#2,D4				; end module NOP
	cmp.w	#$D1FC,2(A4)
	bne.b	hop2
	moveq	#64,D5
	add.l	D5,D4
hop2
	add.l	D4,A3
	subq.l	#2,A3				; end module NOP
	move.l	A3,(A6)+			; SamplePtr
	move.l	A3,A2
	moveq	#0,D5
loop4
	move.l	(A3),D1
	cmp.l	#$10000,D1
	bhi.b	Error
	addq.l	#6,D1
	add.l	D1,D5
	add.l	D1,A3
	dbf	D3,loop4
	cmp.w	#$4E71,(A3)
	bne.b	Error

	move.l	ModulePtr(PC),A3
	lea	130(A3),A0
	moveq	#9,D0
loop
	cmp.w 	#$41EB,(A0)+
	beq.b 	found
	dbf	D0,loop
	bra.b	Error
found
	moveq	#0,D1
	move.w	(A0),D2
	add.w	D2,A3
	move.l	A3,(A6)+			; address
hop
	lea	18(A3),A3
	addq.l	#1,D1
	tst.w	(A3)
	bne.b	hop

	moveq	#0,D0
	sub.l	A3,A2
	move.l	A2,D2
petla
	cmp.b	#$84,(A3)
	beq.b	step1
	cmp.b	#$85,(A3)
	beq.b	step2
	addq.l	#1,A3
	dbf	D2,petla
	bra.b	exit
step2
	move.b	#$84,(A3)			; SongEnd patch 
step1
	addq.l	#1,D0
	addq.l	#1,A3
	dbf	D2,petla

exit
	move.l	D4,SongSize(A1)			; D4 = song size
	move.l	D6,Samples(A1)			; D6 = samples
	move.l	D5,SamplesSize(A1)		; D5 = samples size
	add.l	D4,D5
	move.l	D5,CalcSize(A1)
	move.l	D1,SubSongs(A1)			; D1 = subsongs
	move.l	D0,Steps(A1)

	move.l	A5,(A6)				; EagleBase

	bsr.w	ModuleChange

	move.l	dtg_AudioAlloc(A5),A0		; allocate the audiochannels
	jmp	(A0)				; returncode is already set !

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
	moveq	#0,D0
	move.w	dtg_SndNum(A5),D0
	lea	SongEnd(PC),A1
	move.l	#'WTWT',(A1)+
	clr.l	(A1)+				; clearing CurrentPos

	move.w	D0,D2
	move.l	address(PC),A3
FindMaxLength
	addq.l	#2,A3
	moveq	#3,D3
	moveq	#0,D5
	move.w	#$EFF0,D4

NextLength
	move.l	ModulePtr(PC),A2
	add.l	(A3)+,A2
	addq.w	#8,D4
	addq.w	#8,D4
	moveq	#-1,D1
Zero2
	addq.l	#1,D1
	tst.l	(A2)+
	bne.b	Zero2
	cmp.l	D1,D5
	bgt.b	MaxLength
	move.l	D1,D5
	move.w	D4,2(A1)				; Hardware+2
MaxLength
	dbf	D3,NextLength
	dbf	D2,FindMaxLength

	lea	InfoBuffer(PC),A1
	move.l	D5,Length(A1)
	move.l	ModulePtr(PC),A0
	jmp	4(A0)

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

	move.l	ModulePtr(PC),A0
	jsr	(A0)

	lea	StructAdr(PC),A0
	clr.w	UPS_Enabled(A0)
	movem.l	(A7)+,D1-A6
	moveq	#0,D0
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
	lea	$DFF000,A6
SetNew
	move.w	(A1)+,D1
	bsr.b	ChangeVolume
	addq.l	#8,A6
	addq.l	#8,A6
	dbf	D0,SetNew
	rts

ChangeVolume
	and.w	#$7F,D1
	cmpa.l	#$DFF000,A6			;Left Volume
	bne.b	NoVoice1
	move.w	D1,OldVoice1
	tst.w	Voice1
	bne.b	Voice1On
	moveq	#0,D1
Voice1On
	mulu.w	LeftVolume(PC),D1
	bra.b	SetIt
NoVoice1
	cmpa.l	#$DFF010,A6			;Right Volume
	bne.b	NoVoice2
	move.w	D1,OldVoice2
	tst.w	Voice2
	bne.b	Voice2On
	moveq	#0,D1
Voice2On
	mulu.w	RightVolume(PC),D1
	bra.b	SetIt
NoVoice2
	cmpa.l	#$DFF020,A6			;Right Volume
	bne.b	NoVoice3
	move.w	D1,OldVoice3
	tst.w	Voice3
	bne.b	Voice3On
	moveq	#0,D1
Voice3On
	mulu.w	RightVolume(PC),D1
	bra.b	SetIt
NoVoice3
	move.w	D1,OldVoice4
	tst.w	Voice4
	bne.b	Voice4On
	moveq	#0,D1
Voice4On
	mulu.w	LeftVolume(PC),D1
SetIt
	lsr.w	#6,D1
	move.w	D1,$A8(A6)
	rts

*------------------------------- Set Vol -------------------------------*

SetVol
	move.l	A0,-(A7)
	lea	StructAdr+UPS_Voice1Vol(PC),A0
	cmp.l	#$DFF000,A6
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice2Vol(PC),A0
	cmp.l	#$DFF010,A6
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice3Vol(PC),A0
	cmp.l	#$DFF020,A6
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice4Vol(PC),A0
.SetVoice
	move.w	D1,(A0)
	move.l	(A7)+,A0
	rts

*------------------------------- Set Adr -------------------------------*

SetAdr
	move.l	a0,-(a7)
	lea	StructAdr+UPS_Voice1Adr(pc),a0
	cmp.l	#$dff000,a6
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice2Adr(pc),a0
	cmp.l	#$dff010,a6
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice3Adr(pc),a0
	cmp.l	#$dff020,a6
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice4Adr(pc),a0
.SetVoice
	move.l	a2,(a0)
	move.l	(a7)+,a0
	rts

*------------------------------- Set Len -------------------------------*

SetLen
	move.l	a0,-(a7)
	lea	StructAdr+UPS_Voice1Len(pc),a0
	cmp.l	#$dff000,a6
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice2Len(pc),a0
	cmp.l	#$dff010,a6
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice3Len(pc),a0
	cmp.l	#$dff020,a6
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice4Len(pc),a0
.SetVoice
	move.w	d1,(a0)
	move.l	(a7)+,a0
	rts

*------------------------------- Set Per -------------------------------*

SetPer
	move.l	a0,-(a7)
	lea	StructAdr+UPS_Voice1Per(pc),a0
	cmp.l	#$dff000,a6
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice2Per(pc),a0
	cmp.l	#$dff010,a6
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice3Per(pc),a0
	cmp.l	#$dff020,a6
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice4Per(pc),a0
.SetVoice
	move.w	d0,(a0)
	move.l	(a7)+,a0
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

	*--------------- PatchTable for Rob Hubbard ------------------*

PatchTable
	dc.w	Code1-PatchTable,(Code1End-Code1)/2-1,Patch1-PatchTable
	dc.w	Code2-PatchTable,(Code2End-Code2)/2-1,Patch2-PatchTable
	dc.w	Code3-PatchTable,(Code3End-Code3)/2-1,Patch3-PatchTable
	dc.w	Code4-PatchTable,(Code4End-Code4)/2-1,Patch4-PatchTable
	dc.w	Code5-PatchTable,(Code5End-Code5)/2-1,Patch5-PatchTable
	dc.w	Code6-PatchTable,(Code6End-Code6)/2-1,Patch6-PatchTable
	dc.w	Code9-PatchTable,(Code9End-Code9)/2-1,Patch9-PatchTable
	dc.w	CodeA-PatchTable,(CodeAEnd-CodeA)/2-1,Patch9-PatchTable
	dc.w	CodeB-PatchTable,(CodeBEnd-CodeB)/2-1,PatchB-PatchTable
	dc.w	CodeC-PatchTable,(CodeCEnd-CodeC)/2-1,PatchC-PatchTable
	dc.w	0

; Audio Interrupt patch for Rob Hubbard modules from 1989-1990

Code1
	dc.l	$41FA000C
	move.l	A0,$70.W
Code1End
Patch1
	rts

; Address, Length, Volume patch for Rob Hubbard modules from 1989-1990

Code2
	move.l	0(A5),$A0(A6)
	move.w	8(A5),$A4(A6)
	move.w	14(A5),$A8(A6)
Code2End
Patch2
	movem.l	D1/A2,-(A7)
	move.l	(A5),A2
	move.l	A2,$A0(A6)
	bsr.w	SetAdr
	move.w	8(A5),D1
	move.w	D1,$A4(A6)
	bsr.w	SetLen
	move.w	14(A5),D1
	bsr.w	ChangeVolume
	bsr.w	SetVol
	movem.l	(A7)+,D1/A2
	rts

; Address, Length, Volume patch for Rob Hubbard modules from 1990

Code3	
	move.l	0(A5),$A0(A6)
	move.w	8(A5),$A4(A6)
	move.w	14(A5),D0
	tst.w	$26(A0)
	beq.b	lbC000282
	move.w	$26(A0),D0
lbC000282
	move.w	D0,$A8(A6)
Code3End
Patch3
	movem.l	D1/A2,-(A7)
	move.l	(A5),A2
	move.l	A2,$A0(A6)
	bsr.w	SetAdr
	move.w	8(A5),D1
	move.w	D1,$A4(A6)
	bsr.w	SetLen
	move.w	14(A5),D0
	tst.w	$26(A0)
	beq.b	Jump
	move.w	$26(A0),D0
Jump
	move.w	D0,D1
	bsr.w	ChangeVolume
	bsr.w	SetVol
	movem.l	(A7)+,D1/A2
	rts

; Address, Length, Volume patch for Rob Hubbard modules from 1991

Code4
	move.l	0(A5),$A0(A6)
	move.w	8(A5),$A4(A6)
	clr.w	D0
	move.b	$26(A0),D0
	beq.b	lbC00027C
	move.w	D0,$A8(A6)
	bra.b	LbC000282
lbC00027C
	move.w	14(A5),$A8(A6)
LbC000282
	clr.w	D0
Code4End
Patch4
	movem.l	D1/A2,-(A7)
	move.l	(A5),A2
	move.l	A2,$A0(A6)
	bsr.w	SetAdr
	move.w	8(A5),D1
	move.w	D1,$A4(A6)
	bsr.w	SetLen
	clr.w	D0
	move.b	$26(A0),D0
	beq.b	Jump1
	move.w	D0,D1
	bsr.w	ChangeVolume
	bsr.w	SetVol
	bra.b	Jump2
Jump1
	move.w	14(A5),D1
	bsr.w	ChangeVolume
	bsr.w	SetVol
Jump2	
	clr.w	D0
	movem.l	(A7)+,D1/A2
	rts

; SongEnd and Position Counter patch for Rob Hubbard modules from 1989-1991

Code5
	tst.l	(A2)
	bne.b	lbC000230
	move.l	8(A0),A2
	moveq	#4,D0
lbC000230
	move.l	(A2),A1
Code5End
Patch5
	movem.l	A1/A5,-(A7)
	tst.l	(A2)
	bne.b	NoZero
	lea	SongEnd(PC),A1
	cmp.l	#$DFF000,A6
	bne.b	test1
	clr.b	(A1)
	bra.b	test
test1
	cmp.l	#$DFF010,A6
	bne.b	test2
	clr.b	1(A1)
	bra.b	test
test2
	cmp.l	#$DFF020,A6
	bne.b	test3
	clr.b	2(A1)
	bra.b	test
test3
	cmp.l	#$DFF030,A6
	bne.b	test
	clr.b	3(A1)
test
	tst.l	(A1)
	bne.b	SkipEnd
	move.l	#'WTWT',(A1)+
	clr.l	(A1)					; CurrentPos
	move.l	EagleBase(PC),A5
	move.l	dtg_SongEnd(A5),A1
	jsr	(A1)
SkipEnd
	move.l	8(A0),A2
	moveq	#4,D0
NoZero	
	cmp.l	Hardware(PC),A6
	bne.b	ExitPos
	move.l	12(A0),CurrentPos
ExitPos
	movem.l	(A7)+,A1/A5
	move.l	(A2),A1
	rts

; Address, Length patch for Rob Hubbard modules from 1989-1991

Code6
	move.l	A2,$A0(A6)
	move.w	D1,$A4(A6)
Code6End
Patch6
	move.l	A2,$A0(A6)
	bsr.w	SetAdr
	move.w	D1,$A4(A6)
	bsr.w	SetLen
	rts

; Period patch for Rob Hubbard modules from 1989-1991

Code9
	move.w	D0,$A6(A6)
	move.w	D0,$12(A0)
Code9End
Patch9
	move.w	D0,$12(A0)
	move.w	D0,$A6(A6)
	bsr.w	SetPer
	rts

; Period patch for Rob Hubbard modules from 1989-1991

CodeA
	move.w	D0,$12(A0)
	move.w	D0,$A6(A6)
CodeAEnd
PatchA							; used Patch9

; Period patch for Rob Hubbard modules from 1989-1991

CodeB
	add.w	D1,D2
	move.w	D2,$A6(A6)
CodeBEnd
PatchB
	add.w	D1,D2
	move.w	D2,$A6(A6)
	move.l	D0,-(A7)
	move.w	D2,D0
	bsr.w	SetPer
	move.l	(A7)+,D0
	rts

; Enforcer fix for Rob Hubbard modules from 1989-1991

CodeC
	MOVE.L	A0,8(A1)
	MOVE.L	#4,12(A1)
CodeCEnd
PatchC
	move.l	A0,8(A1)
	move.l	#4,12(A1)
	move.l	#Pusty,$18(A1)
	rts
Pusty
	ds.b	8

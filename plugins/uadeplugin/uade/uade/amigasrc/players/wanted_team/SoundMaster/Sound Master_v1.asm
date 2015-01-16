	****************************************************
	****      Sound Master 1.0-3.0 replayer for	****
	****  Eagleplayer all adaptions by Wanted Team, ****
	****    DeliTracker 2.32 compatible version     ****
	****************************************************

	incdir	"dh2:include/"
	include	'misc/Eagleplayer2.01.i'

	SECTION	Player,CODE

	PLAYERHEADER Tags

	dc.b	"$VER: Sound Master 1.0-3.0 player module V1.0 (25 Feb 2002)",0
	even
Tags
	dc.l	EP_PlayerVersion,9
	dc.l	DTP_PlayerVersion,1
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
	dc.b	"Sound Master",0
Creator
	dc.b	"(c) 1991-94 by Michiel J. Soede,",10
	dc.b	"adapted by Wanted Team",0
Prefix
	dc.b	"SM.",0
	even
ModulePtr
	dc.l	0
FormatReco
	dc.b	0
FormatNow
	dc.b	0
Change
	dc.w	0
EagleBase
	dc.l	0
PlayPtr
	dc.l	0
Format
	dc.w	0
Position
	dc.l	0
SampleInfoPtr
	dc.l	0
SamplePtr
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
**************************** EP_GetPositionNr *****************************
***************************************************************************

GetPosition
	moveq	#0,D0
	move.l	Position(PC),A0
	move.b	(A0),D0
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

InfoBuffer
	dc.l	MI_SubSongs,0		;4
	dc.l	MI_LoadSize,0		;12
	dc.l	MI_Songsize,0		;20
	dc.l	MI_SamplesSize,0	;28
	dc.l	MI_Samples,0		;36
	dc.l	MI_Calcsize,0		;44
	dc.l	MI_Length,0		;52
	dc.l	MI_MaxSamples,32
	dc.l	MI_MaxSubSongs,8
	dc.l	MI_MaxLength,64
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

	move.l	InfoBuffer+Samples(PC),D5
	beq.b	return
	subq.l	#1,D5
	move.l	SampleInfoPtr(PC),A1
	move.b	FormatNow(PC),D2
	bne.b	Normal
	lea	128(A1),A4

Normal
	jsr	ENPP_AllocSampleStruct(A5)
	move.l	D0,(A3)
	beq.b	return
	move.l	D0,A3

	tst.b	D2
	beq.b	OldSamp
	move.l	(A1)+,D0
	add.l	A2,D0
	moveq	#0,D1
	move.w	(A1),D1
	add.l	D1,D1
	addq.l	#6,A1
	bra.b	PutInfos
OldSamp
	move.l	(A1)+,D0
	add.l	A2,D0
	moveq	#0,D1
	move.w	(A4)+,D1
	add.l	D1,D1
PutInfos
	move.l	D0,EPS_Adr(A3)			; sample address
	move.l	D1,EPS_Length(A3)		; sample length
	move.l	#64,EPS_Volume(A3)
	move.w	#USITY_RAW,EPS_Type(A3)
	move.w	#USIB_Playable!USIB_Saveable!USIB_8BIT,EPS_Flags(A3)
	dbf	D5,Normal

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
	cmp.w	(A0)+,D1
	bne.s	Return
	move.l	A0,A1
	move.w	(A0)+,D2
	bmi.b	Return
	beq.b	Return
	btst	#0,D2
	bne.b	Return
	cmp.w	(A0)+,D1
	bne.s	Return
	move.w	(A0)+,D3
	bmi.b	Return
	beq.b	Return
	btst	#0,D3
	bne.b	Return
	cmp.w	(A0),D1
	bne.s	Return
	add.w	D2,A1
	lea	30(A1),A0
FindLea1
	cmp.w	#$47FA,(A1)
	beq.b	FindRTS
	addq.l	#2,A1
	cmp.l	A0,A1
	bne.b	FindLea1
	rts
FindRTS
	cmp.w	#$4E75,(A1)+
	bne.b	FindRTS

	moveq	#0,D1
	cmp.l	#$177C0000,-8(A1)
	bne.b	NoNew
	moveq	#-1,D1
	subq.l	#6,A1
NoNew
	cmp.l	#$BFE001,-6(A1)
	bne.b	Return
	lea	FormatReco(PC),A0
	move.b	D1,(A0)
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
	move.l	#2400,D1
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
	move.b	(A6)+,(A6)+			; copy format
	clr.w	(A6)+				; clearing change flag
	move.l	A5,(A6)+			; EagleBase
	lea	6(A0),A1
	add.w	(A1),A1
	move.l	A1,(A6)+			; PlayPtr
	clr.w	(A6)

	lea	InfoBuffer(PC),A4
	move.l	D0,LoadSize(A4)
	lea	2(A0),A1
	add.w	(A1),A1
	move.l	A1,D6
	moveq	#0,D0
	moveq	#1,D1
	cmp.w	#$1740,6(A1)
	beq.b	RackMe
	cmp.w	#$1740,4(A1)
	bne.b	NoDoof
RackMe
	move.w	#31,(A6)
	bra.b	Skip3
NoDoof
	cmp.w	#$3C00,(A1)
	beq.b	FindLea
	cmp.w	#$4A00,40(A1)
	bne.b	Skip3
	addq.l	#1,D1
	move.w	52(A1),D0
	bra.b	Skip3
FindLea
	cmp.w	#$47FA,(A1)+
	bne.b	FindLea
	move.l	A1,A3
	add.w	(A3),A3
	move.l	A3,A6
FindIt
	cmp.w	#$7600,(A1)+
	bne.b	FindIt
	add.w	-4(A1),A3			; songs ptr
	addq.l	#3,A3
	moveq	#6,D0
NextPos
	tst.b	(A3)
	bne.b	SubOK
	tst.b	1(A3)
	bne.b	SubOK
	cmp.b	#1,2(A3)
	beq.b	NoNext
SubOK
	addq.l	#3,A3
	addq.l	#1,D1
	dbf	D0,NextPos
NoNext
	moveq	#0,D0
	move.b	-1(A3),D0
	bra.b	SkipOld
Skip3
FindLea2
	cmp.w	#$47FA,(A1)+
	bne.b	FindLea2
	add.w	(A1),A1
	move.l	A1,A6
SkipOld
	move.l	D0,Length(A4)
	move.l	D1,SubSongs(A4)

	move.l	A0,A1
FindIt2
	cmp.w	#$1743,(A1)+
	bne.b	FindIt2
	move.l	A6,A3
	add.w	(A1),A6
	lea	Position(PC),A1
	move.l	A6,(A1)

	move.l	A0,A1
FindIt3
	cmp.w	#$5203,(A1)+
	bne.b	FindIt3
	cmp.w	#$177C,10(A1)
	bne.w	SkipPatch
	lea	SongEnd(PC),A6
	move.w	#$4EF9,4(A0)			; jmp to
	move.l	A6,6(A0)			; address
	lea	10(A1),A2
	move.l	(A2),(A6)+
	move.l	A2,D1
	move.l	#$4E716100,(A2)+		; nop + bsr.w
	move.w	(A2),(A6)
	move.l	A0,D2
	sub.l	D1,D2
	move.w	D2,(A2)
	move.l	A3,A6
	add.w	2(A1),A3
	tst.l	D0
	bne.b	LengthOK
	move.b	(A3),D0
	move.l	D0,Length(A4)
LengthOK
	move.l	D6,A2

	lea	SampleInfoPtr(PC),A1
	move.b	FormatNow(PC),D1
	beq.b	OldVer
FindOne
	cmp.w	#$41EB,(A2)+
	bne.b	FindOne
	move.l	A6,A3
	add.w	(A2),A6
	add.w	4(A2),A3
	add.l	(A3),A6
	move.l	A6,(A1)+			;SampleInfoPtr
	move.w	-2(A3),D0
	move.l	D0,D1
	add.l	A6,D1
	lea	(A6,D0.W),A2
	move.l	A2,(A1)				;SamplePtr

	moveq	#0,D0
	moveq	#0,D2

CheckInfos
	move.l	(A6)+,D3
	bmi.b	NoUsed
	moveq	#0,D4
	move.w	(A6),D4
	beq.b	NoUsed
	addq.l	#1,D0
	add.l	D4,D4
	add.l	D4,D3
	cmp.l	D3,D2
	bge.b	NoUsed
	move.l	D3,D2
NoUsed
	addq.l	#6,A6
	cmp.l	A6,A2
	bne.b	CheckInfos

	move.l	D0,Samples(A4)
	sub.l	A0,D1
	move.l	D1,SongSize(A4)
	move.l	D2,SamplesSize(A4)
	add.l	D1,D2
	move.l	D2,CalcSize(A4)
	bra.w	SkipOld2
OldVer
	cmp.w	#$3D70,(A2)+
	bne.b	OldVer
	move.w	-4(A2),Patch4+2
	move.w	-4(A2),Code4+2
FindTwo
	cmp.w	#$D5F0,(A2)+
	bne.b	FindTwo
	move.l	A6,A3
	add.w	-4(A2),A3
	add.l	(A3),A6
	move.l	A6,-(SP)
	add.w	-18(A2),A6
	move.l	A6,(A1)+			; SampleInfoPtr
	moveq	#31,D1
	moveq	#0,D0
	lea	128(A6),A3
	moveq	#0,D2
OldInfos
	cmp.w	#1,(A3)
	bhi.b	SampOK
	bra.b	SkipSamp
SampOK
	addq.l	#1,D0
	moveq	#0,D3
	move.w	(A3),D3
	add.l	D3,D3
	add.l	(A6),D3
	cmp.l	D3,D2
	bge.b	SkipSamp
	move.l	D3,D2
SkipSamp
	addq.l	#4,A6
	addq.l	#2,A3
	dbf	D1,OldInfos

	move.l	(SP)+,A6
	add.w	-8(A2),A6
	move.l	A6,(A1)				; SamplePtr

	sub.l	A0,A6
	move.l	A6,SongSize(A4)
	move.l	D2,SamplesSize(A4)
	add.l	A6,D2
	move.l	D2,CalcSize(A4)
	move.l	D0,Samples(A4)
	bra.b	SkipOld2

SkipPatch
	clr.l	Samples(A4)
	clr.l	SongSize(A4)
	clr.l	SamplesSize(A4)
	clr.l	CalcSize(A4)
SkipOld2
	move.l	A0,A3
FindVol
	cmp.l	#$3D4000A8,(A3)
	beq.b	VolFound
	addq.l	#2,A3
	bra.b	FindVol
VolFound
	bsr.w	ModuleChange

	move.w	#$4EF9,(A3)			; from jsr to jmp

	move.l	dtg_AudioAlloc(A5),A0		; allocate the audiochannels
	jmp	(A0)				; returncode is already set !

SongEnd
	dc.l	'WTWT'
	dc.w	'WT'
	movem.l	A1/A5,-(A7)
	move.l	EagleBase(PC),A5
	move.l	dtg_SongEnd(A5),A1
	jsr	(A1)
	movem.l	(A7)+,A1/A5
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
	lea	OldVoice1(PC),A0
	clr.l	(A0)+
	clr.l	(A0)
	move.w	Format(PC),D0
	bne.b	FormatOK
	move.w	dtg_SndNum(A5),D0
FormatOK
	move.l	ModulePtr(PC),A0
	jmp	(A0)

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

	move.l	PlayPtr(PC),A0
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
	moveq	#3,D1
	lea	$DFF000,A6
SetNew
	move.w	(A1)+,D0
	bsr.b	ChangeVolume
	lea	16(A6),A6
	dbf	D1,SetNew
	rts

ChangeVolume
	and.w	#$7F,D0
	cmpa.l	#$DFF000,A6			;Left Volume
	bne.b	NoVoice1
	move.w	D0,OldVoice1
	tst.w	Voice1
	bne.b	Voice1On
	moveq	#0,D0
Voice1On
	mulu.w	LeftVolume(PC),D0
	bra.b	SetIt
NoVoice1
	cmpa.l	#$DFF010,A6			;Right Volume
	bne.b	NoVoice2
	move.w	D0,OldVoice2
	tst.w	Voice2
	bne.b	Voice2On
	moveq	#0,D0
Voice2On
	mulu.w	RightVolume(PC),D0
	bra.b	SetIt
NoVoice2
	cmpa.l	#$DFF020,A6			;Right Volume
	bne.b	NoVoice3
	move.w	D0,OldVoice3
	tst.w	Voice3
	bne.b	Voice3On
	moveq	#0,D0
Voice3On
	mulu.w	RightVolume(PC),D0
	bra.b	SetIt
NoVoice3
	move.w	D0,OldVoice4
	tst.w	Voice4
	bne.b	Voice4On
	moveq	#0,D0
Voice4On
	mulu.w	LeftVolume(PC),D0
SetIt
	lsr.w	#6,D0
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
	move.w	D0,(A0)
	move.l	(A7)+,A0
	rts

*------------------------------- Set Two -------------------------------*

SetTwo
	movem.l	D0/A0,-(A7)
	lea	StructAdr+UPS_Voice1Adr(PC),A0
	cmp.l	#$DFF000,A6
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice2Adr(PC),A0
	cmp.l	#$DFF010,A6
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice3Adr(PC),A0
	cmp.l	#$DFF020,A6
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice4Adr(PC),A0
.SetVoice
	move.l	A2,(A0)
	move.w	$10(A5),D0
	lsr.w	#2,D0
	move.w	D0,UPS_Voice1Per(A0)
	movem.l	(A7)+,D0/A0
	rts

*------------------------------- Set Len -------------------------------*

SetLen
	move.l	A1,-(A7)
	lea	StructAdr+UPS_Voice1Len(PC),A1
	cmp.l	#$DFF000,A6
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice2Len(PC),A1
	cmp.l	#$DFF010,A6
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice3Len(PC),A1
	cmp.l	#$DFF020,A6
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice4Len(PC),A1
.SetVoice
	move.w	D0,(A1)
	move.l	(A7)+,A1
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

	*--------------- PatchTable for Sound Master ------------------*

PatchTable
	dc.w	Code1-PatchTable,(Code1End-Code1)/2-1,Patch1-PatchTable
	dc.w	Code2-PatchTable,(Code2End-Code2)/2-1,Patch2-PatchTable
	dc.w	Code3-PatchTable,(Code3End-Code3)/2-1,Patch3-PatchTable
	dc.w	Code4-PatchTable,(Code4End-Code4)/2-1,Patch4-PatchTable
	dc.w	Code5-PatchTable,(Code5End-Code5)/2-1,Patch5-PatchTable
	dc.w	Code6-PatchTable,(Code6End-Code6)/2-1,Patch6-PatchTable
	dc.w	0

; Volume patch for Sound Master modules

Code1
	MOVE.W	D0,$A8(A6)
	RTS
Code1End
Patch1
	bsr.w	ChangeVolume
	bsr.w	SetVol
	move.w	D0,$A8(A6)
	rts

; Address/period patch for Sound Master modules (v1.x)

Code2
	ADDA.L	0(A0,D0.L),A2
	MOVE.L	A2,$A0(A6)
Code2End
Patch2
	add.l	0(A0,D0.L),A2
	move.l	A2,$A0(A6)
	bsr.w	SetTwo
	rts

; Address/period patch for Sound Master modules (v2+)

Code3	
	MOVE.L	A0,$A0(A6)
	ADD.L	A0,D1
Code3End
Patch3
	move.l	A0,$A0(A6)
	add.l	A0,D1
	move.l	A2,-(SP)
	move.l	A0,A2
	bsr.w	SetTwo
	move.l	(SP)+,A2
	rts

; Length patch for Sound Master modules (v1.x)

Code4
	ADDA.L	$E2(A3),A0
	MOVE.W	0(A0,D0.L),$A4(A6)
Code4End
Patch4
	add.l	$E2(A3),A0
	move.w	0(A0,D0.L),$A4(A6)
	move.l	D0,-(SP)
	move.w	0(A0,D0.L),D0
	bsr.w	SetLen
	move.l	(SP)+,D0
	rts

; Length patch for Sound Master modules (v2.x)

Code5
	MOVE.W	4(A0,D0.W),$A4(A6)
	MOVE.W	8(A0,D0.W),$1A(A5)
Code5End
Patch5
	move.w	4(A0,D0.W),$A4(A6)
	move.w	8(A0,D0.W),$1A(A5)
	move.l	D0,-(SP)
	move.w	4(A0,D0.W),D0
	bsr.w	SetLen
	move.l	(SP)+,D0
	rts

; Length patch for Sound Master modules (v3.x)

Code6
	MOVE.W	4(A0,D0.L),$A4(A6)
	MOVE.W	8(A0,D0.L),$1A(A5)
Code6End
Patch6
	move.w	4(A0,D0.L),$A4(A6)
	move.w	8(A0,D0.L),$1A(A5)
	move.l	D0,-(SP)
	move.w	4(A0,D0.L),D0
	bsr.w	SetLen
	move.l	(SP)+,D0
	rts

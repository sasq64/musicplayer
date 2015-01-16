	******************************************************
	****     Core Design replayer for EaglePlayer,    ****
	****         all adaptions by Wanted Team	  ****
	****     DeliTracker 2.32 compatible version	  ****
	******************************************************

	incdir	"dh2:include/"
	include "misc/eagleplayer2.01.i"
	include "hardware/intbits.i"
	include "exec/exec_lib.i"
	include	"dos/dos_lib.i"

	SECTION	Player,CODE

	PLAYERHEADER Tags

	dc.b	'$VER: Core Design player module V1.0 (17 Feb 2004)',0
	even
Tags
	dc.l	DTP_PlayerVersion,1
	dc.l	EP_PlayerVersion,9
	dc.l	DTP_RequestDTVersion,'WT'
	dc.l	DTP_PlayerName,PlayerName
	dc.l	DTP_Creator,Creator
	dc.l	DTP_DeliBase,DeliBase
	dc.l	DTP_Check1,Check1
	dc.l	EP_Check3,Check3
	dc.l	DTP_Interrupt,Interrupt
	dc.l	DTP_SubSongRange,SubSongRange
	dc.l	DTP_InitPlayer,InitPlayer
	dc.l	DTP_EndPlayer,EndPlayer
	dc.l	DTP_InitSound,InitSound
	dc.l	DTP_EndSound,EndSound
	dc.l	EP_Get_ModuleInfo,GetInfos
	dc.l	EP_SampleInit,SampleInit
	dc.l	EP_ModuleChange,ModuleChange
	dc.l	DTP_Volume,SetVolume
	dc.l	DTP_Balance,SetBalance
	dc.l	EP_Voices,SetVoices
	dc.l	EP_StructInit,StructInit
	dc.l	EP_Flags,EPB_Volume!EPB_Balance!EPB_ModuleInfo!EPB_Voices!EPB_SampleInfo!EPB_Songend!EPB_Analyzer!EPB_NextSong!EPB_PrevSong!EPB_Restart
	dc.l	TAG_DONE
PlayerName
	dc.b	'Core Design',0
Creator
	dc.b	'(c) 1989-90 by Gremlin Graphics,',10
	dc.b	'adapted by Wanted Team',0
Prefix
	dc.b	'CORE.',0
	even
DeliBase
	dc.l	0
ModulePtr
	dc.l	0
PlayPtr
	dc.l	0
AudioPtr
	dc.l	0
InitSongPtr
	dc.l	0
EndSongPtr
	dc.l	0
SampleInfoPtr
	dc.l	0
EndSampleInfoPtr
	dc.l	0
EagleBase
	dc.l	0
Change
	dc.w	0
ChangeLen
	dc.l	0
SongEndFlag
	dc.w	0
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
**************************** EP_ModuleChange ******************************
***************************************************************************

ModuleChange
	move.w	Change(PC),D0
	bne.s	NoChange
	move.l	EndSongPtr(PC),EPG_ARG1(A5)
	lea	PatchTable(PC),A1
	move.l	A1,EPG_ARG3(A5)
	move.l	ChangeLen(PC),D1
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
	lea	$DFF000,A4
SetNew
	move.w	(A1)+,D0
	bsr.b	ChangeVolume
	lea	16(A4),A4
	dbf	D0,SetNew
	rts

ChangeVolume
	cmpa.l	#$DFF000,A4			;Left Volume
	bne.b	NoVoice1
	move.w	D0,OldVoice1
	tst.w	Voice1
	bne.b	Voice1On
	moveq	#0,D0
Voice1On
	mulu.w	LeftVolume(PC),D0
	bra.b	SetIt
NoVoice1
	cmpa.l	#$DFF010,A4			;Right Volume
	bne.b	NoVoice2
	move.w	D0,OldVoice2
	tst.w	Voice2
	bne.b	Voice2On
	moveq	#0,D0
Voice2On
	mulu.w	RightVolume(PC),D0
	bra.b	SetIt
NoVoice2
	cmpa.l	#$DFF020,A4			;Right Volume
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
	move.w	D0,$A8(A4)
	rts

*------------------------------- Set Vol -------------------------------*

SetVol
	move.l	A0,-(A7)
	lea	StructAdr+UPS_Voice1Vol(PC),A0
	cmp.l	#$DFF000,A4
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice2Vol(PC),A0
	cmp.l	#$DFF010,A4
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice3Vol(PC),A0
	cmp.l	#$DFF020,A4
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice4Vol(PC),A0
.SetVoice
	move.w	D0,(A0)
	move.l	(A7)+,A0
	rts

*------------------------------- Set All -------------------------------*

SetAll
	move.l	A0,-(A7)
	lea	StructAdr+UPS_Voice1Adr(PC),A0
	cmp.l	#$DFF000,A4
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice2Adr(PC),A0
	cmp.l	#$DFF010,A4
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice3Adr(PC),A0
	cmp.l	#$DFF020,A4
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice4Adr(PC),A0
.SetVoice
	move.l	14(A6),(A0)
	move.w	$12(A6),UPS_Voice1Len(A0)
	move.w	8(A6),UPS_Voice1Per(A0)
	move.l	(A7)+,A0
	rts

*------------------------------- Set Per -------------------------------*

SetPer
	move.l	A0,-(A7)
	lea	StructAdr+UPS_Voice1Per(PC),A0
	cmp.l	#$DFF000,A4
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice2Per(PC),A0
	cmp.l	#$DFF010,A4
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice3Per(PC),A0
	cmp.l	#$DFF020,A4
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice4Per(PC),A0
.SetVoice
	move.w	8(A6),(A0)
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
hop
	jsr	ENPP_AllocSampleStruct(A5)
	move.l	D0,(A3)
	beq.b	return
	move.l	D0,A3
	move.l	6(A0),A1
	moveq	#0,D0
	move.w	(A1)+,D0
	lsl.l	#1,D0
	move.l	A1,EPS_Adr(A3)			; sample address
	move.l	D0,EPS_Length(A3)		; sample length
	move.l	#64,EPS_Volume(A3)
	move.w	#USITY_RAW,EPS_Type(A3)
	move.w	#USIB_Playable!USIB_Saveable!USIB_8BIT,EPS_Flags(A3)
SkipInfo
	lea	14(A0),A0
	dbf	D5,hop

	moveq	#0,D7
return
	move.l	D7,D0
	rts

***************************************************************************
******************************** DTP_Check1 *******************************
***************************************************************************

Check1
	move.l	DeliBase(PC),D0
	beq.b	fail

***************************************************************************
******************************* EP_Check3 *********************************
***************************************************************************

Check3
	movea.l	dtg_ChkData(A5),A0
	cmp.l	#$000003F3,(A0)
	bne.b	fail
	tst.b	20(A0)				; loading into chip check
	beq.b	fail
	lea	32(A0),A0
	cmp.l	#$70FF4E75,(A0)+
	bne.b	fail
	cmp.l	#'S.PH',(A0)+
	bne.b	fail
	cmp.l	#'IPPS',(A0)+
	bne.b	fail
	tst.l	(A0)+				; Interrupt pointer check
	beq.b	fail
	tst.l	(A0)+				; Audio Interrupt pointer check
	beq.b	fail
	tst.l	(A0)+				; InitSong pointer check
	beq.b	fail
	tst.l	(A0)+				; EndSong pointer check
	beq.b	fail
	tst.l	(A0)				; Subsongs check
	beq.b	fail

	moveq	#0,D0
	rts
fail
	moveq	#-1,D0
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
SpecialInfo	=	52
AuthorName	=	60
SongName	=	68

InfoBuffer
	dc.l	MI_SubSongs,0		;4
	dc.l	MI_LoadSize,0		;12
	dc.l	MI_Songsize,0		;20
	dc.l	MI_SamplesSize,0	;28
	dc.l	MI_Samples,0		;36
	dc.l	MI_Calcsize,0		;44
	dc.l	MI_SpecialInfo,0	;52
	dc.l	MI_AuthorName,0		;60
	dc.l	MI_SongName,0		;68
	dc.l	MI_Prefix,Prefix
	dc.l	0

***************************************************************************
***************************** DTP_Intterrupt ******************************
***************************************************************************

Interrupt	
	movem.l	D1-D7/A0-A6,-(SP)

	lea	StructAdr(PC),A0
	st	UPS_Enabled(A0)
	clr.w	UPS_Voice1Per(A0)
	clr.w	UPS_Voice2Per(A0)
	clr.w	UPS_Voice3Per(A0)
	clr.w	UPS_Voice4Per(A0)
	move.w	#UPSB_Adr!UPSB_Len!UPSB_Per!UPSB_Vol,UPS_Flags(A0)

	move.l	PlayPtr(PC),A0
	jsr	(A0)				; play module

	lea	StructAdr(PC),A0
	clr.w	UPS_Enabled(A0)

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

SetAudioVector
	movem.l	D0/A1/A6,-(A7)
	movea.l	4.W,A6
	lea	StructInt(PC),A1
	moveq	#INTB_AUD0,D0
	jsr	_LVOSetIntVector(A6)		; SetIntVector
	move.l	D0,Channel0
	lea	StructInt(PC),A1
	moveq	#INTB_AUD1,D0
	jsr	_LVOSetIntVector(A6)
	move.l	D0,Channel1
	lea	StructInt(PC),A1
	moveq	#INTB_AUD2,D0
	jsr	_LVOSetIntVector(A6)
	move.l	D0,Channel2
	lea	StructInt(PC),A1
	moveq	#INTB_AUD3,D0
	jsr	_LVOSetIntVector(A6)
	move.l	D0,Channel3
	movem.l	(A7)+,D0/A1/A6
	rts

ClearAudioVector
	movea.l	4.W,A6
	movea.l	Channel0(PC),A1
	moveq	#INTB_AUD0,D0
	jsr	_LVOSetIntVector(A6)
	movea.l	Channel1(PC),A1
	moveq	#INTB_AUD1,D0
	jsr	_LVOSetIntVector(A6)
	movea.l	Channel2(PC),A1
	moveq	#INTB_AUD2,D0
	jsr	_LVOSetIntVector(A6)
	movea.l	Channel3(PC),A1
	moveq	#INTB_AUD3,D0
	jmp	_LVOSetIntVector(A6)

Channel0
	dc.l	0
Channel1
	dc.l	0
Channel2
	dc.l	0
Channel3
	dc.l	0
StructInt
	dc.l	0
	dc.l	0
	dc.w	$205
	dc.l	IntName
	dc.l	0
IntAddress
	dc.l	0
IntName
	dc.b	'Core Design Audio Interrupt',0,0
	even

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
	move.l	dtg_DOSBase(A5),A6
	move.l	dtg_PathArrayPtr(A5),D1
	jsr	_LVOLoadSeg(A6)
	lsl.l	#2,D0
	beq.w	InitFail
	addq.l	#4,D0

	move.l	D0,A0				; module address
	lea	InfoBuffer(PC),A2
	lea	ModulePtr(PC),A1
	move.l	D0,(A1)+
	addq.l	#8,A0
	addq.l	#4,A0
	move.l	(A0)+,(A1)+			; Play pointer
	move.l	(A0)+,(A1)+			; Audio Interrupt pointer
	move.l	(A0)+,(A1)+			; InitSong pointer
	move.l	(A0)+,(A1)+			; EndSong pointer
	move.l	(A0)+,SubSongs(A2)
	move.l	(A0)+,(A1)+			; SampleInfo pointer
	move.l	(A0)+,(A1)+			; EndSampleInfo pointer

	move.l	(A0)+,SongName(A2)
	move.l	(A0)+,AuthorName(A2)
	move.l	(A0)+,SpecialInfo(A2)
	move.l	(A0)+,LoadSize(A2)
	move.l	(A0)+,CalcSize(A2)
	move.l	(A0)+,SamplesSize(A2)
	move.l	(A0)+,SongSize(A2)

	move.l	EndSampleInfoPtr(PC),D1
	sub.l	SampleInfoPtr(PC),D1
	divu.w	#14,D1
	move.l	D1,Samples(A2)

	move.l	A5,(A1)+			; EagleBase
	clr.w	(A1)+				; Change

	move.l	EndSongPtr(PC),A2
	move.l	A2,A0
More
	cmp.l	#$3BC03865,(A2)
	beq.b	Note
	cmp.w	#$4E73,(A2)
	bne.b	NoRTE
	addq.w	#2,(A2)+
	bra.b	More
NoRTE
	cmp.w	#$46DF,(A2)
	bne.b	NoSR
	move.w	#$4E71,(A2)
NoSR
	addq.l	#2,A2
	bra.b	More
Note
	sub.l	A0,A2
	move.l	A2,(A1)				; ChangeLen

	move.l	AudioPtr(PC),A0
	lea	IntAddress(PC),A2
	move.l	A0,(A2)

	bsr.w	ModuleChange

	movea.l	dtg_AudioAlloc(A5),A0
	jmp	(A0)

InitFail
	moveq	#EPR_NotEnoughMem,D0
	rts

***************************************************************************
***************************** DTP_EndPlayer *******************************
***************************************************************************

EndPlayer
	move.l	dtg_DOSBase(A5),A6
	move.l	ModulePtr(PC),D1
	subq.l	#4,D1
	lsr.l	#2,D1
	jmp	_LVOUnLoadSeg(A6)

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
	moveq	#1,D1				; repeat on
	move.w	dtg_SndNum(A5),D0
	lea	SongEndFlag(PC),A1
	st	(A1)
	move.l	InitSongPtr(PC),A0
	jsr	(A0)
	lea	SongEndFlag(PC),A1
	clr.w	(A1)
	bra.w	SetAudioVector

***************************************************************************
***************************** DTP_EndSound ********************************
***************************************************************************

EndSound
	bsr.w	ClearAudioVector
	move.l	EndSongPtr(PC),A0
	jsr	(A0)
	lea	$DFF000,A0
	move.w	#15,$96(A0)
	moveq	#0,D0
	move.w	D0,$A8(A0)
	move.w	D0,$B8(A0)
	move.w	D0,$C8(A0)
	move.w	D0,$D8(A0)
	rts


	*----------------- PatchTable for Core Design -------------------*

PatchTable
	dc.w	Code0-PatchTable,(Code0End-Code0)/2-1,Patch0-PatchTable
	dc.w	Code1-PatchTable,(Code1End-Code1)/2-1,Patch1-PatchTable
	dc.w	Code2-PatchTable,(Code2End-Code2)/2-1,Patch2-PatchTable
	dc.w	Code3-PatchTable,(Code3End-Code3)/2-1,Patch3-PatchTable
	dc.w	Code4-PatchTable,(Code4End-Code4)/2-1,Patch4-PatchTable
	dc.w	Code5-PatchTable,(Code5End-Code5)/2-1,Patch5-PatchTable
	dc.w	Code6-PatchTable,(Code6End-Code6)/2-1,Patch6-PatchTable
	dc.w	0

; Audio Interrupt patch for Core Design modules

Code0
	MOVE.W	D0,$DFF09C
Code0End
Patch0
	move.w	D0,$DFF09A
	move.w	D0,$DFF09C
	rts

; Audio Interrupt patch for Core Design modules

Code1
	MOVE.W	D2,$DFF09C
Code1End
Patch1
	move.w	D2,$DFF09A
	move.w	D2,$DFF09C
	rts

; SR patch for Core Design modules

Code2
	MOVE.W	SR,-(SP)
	ORI.W	#$700,SR
Code2End
Patch2
	rts

; SongEnd patch for Core Design modules

Code3
	MOVEQ	#0,D2
	MOVE.B	D0,D2
	ASL.W	#3,D2
Code3End
Patch3
	moveq	#0,D2
	move.b	D0,D2
	asl.w	#3,D2
	tst.w	SongEndFlag
	bne.b	NoEnd
	bsr.w	SongEnd
NoEnd
	rts

; Period/length/address patch for Core Design modules

Code4
	MOVE.W	(A0)+,$12(A6)
	MOVE.L	A0,14(A6)
Code4End
Patch4
	move.w	(A0)+,$12(A6)
	move.l	A0,14(A6)
	bsr.w	SetAll
	rts

; Volume patch for Core Design modules

Code5
	LSR.W	#1,D0
	MOVE.W	D0,$A8(A4)
Code5End
Patch5
	lsr.w	#1,D0
	bsr.w	ChangeVolume
	bsr.w	SetVol
	rts

; Period/length/address patch for Core Design modules

Code6
	MOVE.W	0(A0,D0.W),8(A6)
Code6End
Patch6
	move.w	0(A0,D0.W),8(A6)
	bsr.w	SetPer
	rts

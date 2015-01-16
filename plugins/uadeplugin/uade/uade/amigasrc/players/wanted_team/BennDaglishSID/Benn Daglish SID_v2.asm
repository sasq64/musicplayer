	******************************************************
	****  Benn Daglish SID replayer for EaglePlayer,  ****
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

	dc.b	'$VER: Benn Daglish SID player module V1.1 (11 Mar 2004)',0
	even
Tags
	dc.l	DTP_PlayerVersion,2
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
	dc.l	EP_ModuleChange,ModuleChange
	dc.l	EP_StructInit,StructInit
	dc.l	EP_Flags,EPB_ModuleInfo!EPB_Songend!EPB_Analyzer!EPB_NextSong!EPB_PrevSong!EPB_Restart
	dc.l	TAG_DONE
PlayerName
	dc.b	'Benn Daglish SID',0
Creator
	dc.b	'(c) 1987-88 by Benn Daglish,',10
	dc.b	'adapted by Wanted Team',0
Prefix
	dc.b	'BDS.',0
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
EagleBase
	dc.l	0
Change
	dc.w	0
Vol1Ptr
	dc.l	0
Vol2Ptr
	dc.l	0
Vol3Ptr
	dc.l	0
SongEndFlag
	dc.w	0
A4_Base
	dc.l	0
StructAdr
	ds.b	UPS_SizeOF

***************************************************************************
**************************** EP_ModuleChange ******************************
***************************************************************************

ModuleChange
	move.w	Change(PC),D0
	bne.s	NoChange
	move.l	PlayPtr(PC),EPG_ARG1(A5)
	lea	PatchTable(PC),A1
	move.l	A1,EPG_ARG3(A5)
	move.l	#2600,D1
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
******************************* EP_StructInit *****************************
***************************************************************************

StructInit
	lea	StructAdr(PC),A0
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
	cmp.l	#'DAGL',(A0)+
	bne.b	fail
	cmp.l	#'ISH!',(A0)+
	bne.b	fail
	tst.l	(A0)+				; Interrupt pointer check
	beq.b	fail
	tst.l	(A0)+				; Audio Interrupt pointer check
	beq.b	fail
	tst.l	(A0)+				; InitSong pointer check
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
CalcSize	=	36
SpecialInfo	=	44
AuthorName	=	52
SongName	=	60

InfoBuffer
	dc.l	MI_SubSongs,0		;4
	dc.l	MI_LoadSize,0		;12
	dc.l	MI_Songsize,0		;20
	dc.l	MI_SamplesSize,0	;28
	dc.l	MI_Calcsize,0		;36
	dc.l	MI_SpecialInfo,0	;44
	dc.l	MI_AuthorName,0		;52
	dc.l	MI_SongName,0		;60
	dc.l	MI_Voices,3
	dc.l	MI_MaxVoices,3
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

	lea	StructAdr(PC),A1
	move.l	Vol1Ptr(PC),A2
	moveq	#0,D0
	move.b	(A2),D0
	rol.w	#2,D0
	move.w	D0,UPS_Voice1Vol(A1)
	move.l	Vol2Ptr(PC),A2
	moveq	#0,D0
	move.b	(A2),D0
	rol.w	#2,D0
	move.w	D0,UPS_Voice2Vol(A1)
	move.l	Vol3Ptr(PC),A2
	moveq	#0,D0
	move.b	(A2),D0
	rol.w	#2,D0
	move.w	D0,UPS_Voice3Vol(A1)

	move.l	A4_Base(PC),A0
	tst.b	$11(A0)
	bne.b	NoEnd
	bsr.w	EndSound
	move.l	EagleBase(PC),A5
	move.l	dtg_SongEnd(A5),A1
	jsr	(A1)
	bsr.w	InitSound
NoEnd
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

DMAWait
	movem.l	D0/D1,-(SP)
	moveq	#8,D0
.dma1	move.b	$DFF006,D1
.dma2	cmp.b	$DFF006,D1
	beq.b	.dma2
	dbeq	D0,.dma1
	movem.l	(SP)+,D0/D1
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
	dc.b	'Benn Daglish SID Audio Interrupt',0,0
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
	move.l	(A0)+,SubSongs(A2)
	move.l	(A0)+,SongName(A2)
	move.l	(A0)+,AuthorName(A2)
	move.l	(A0)+,SpecialInfo(A2)
	move.l	(A0)+,LoadSize(A2)
	move.l	(A0)+,CalcSize(A2)
	move.l	(A0)+,SamplesSize(A2)
	move.l	(A0)+,SongSize(A2)

	move.l	A5,(A1)+			; EagleBase
	clr.w	(A1)+				; Change

	move.l	AudioPtr(PC),A2
	lea	IntAddress(PC),A0
	move.l	A2,(A0)

NoRTE
	cmp.w	#$1239,(A2)
	bne.b	NoMove
	move.l	2(A2),(A1)+
NoMove
	cmp.w	#$4E73,(A2)+
	bne.b	NoRTE
	addq.w	#2,-2(A2)

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
	jsr	_LVOUnLoadSeg(A6)
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
	move.w	dtg_SndNum(A5),D0
	lea	SongEndFlag(PC),A1
	st	(A1)
	move.l	InitSongPtr(PC),A0
	jsr	(A0)
	lea	SongEndFlag(PC),A1
	clr.w	(A1)+
	move.l	A4,(A1)				;A4_Base
	bra.w	SetAudioVector

***************************************************************************
***************************** DTP_EndSound ********************************
***************************************************************************

EndSound
	bsr.w	ClearAudioVector
	lea	$DFF000,A0
	move.w	#15,$96(A0)
	moveq	#0,D0
	move.w	D0,$A8(A0)
	move.w	D0,$B8(A0)
	move.w	D0,$C8(A0)
	move.w	D0,$D8(A0)
	rts

*------------------ PatchTable for Benn Daglish SID --------------------*

PatchTable
	dc.w	Code0-PatchTable,(Code0End-Code0)/2-1,Patch0-PatchTable
	dc.w	Code1-PatchTable,(Code1End-Code1)/2-1,Patch1-PatchTable
	dc.w	Code2-PatchTable,(Code2End-Code2)/2-1,Patch2-PatchTable
	dc.w	Code3-PatchTable,(Code3End-Code3)/2-1,Patch3-PatchTable
	dc.w	Code4-PatchTable,(Code4End-Code4)/2-1,Patch4-PatchTable
	dc.w	0

; SongEnd patch for Benn Daglish SID modules

Code0
	MOVE.W	#15,$96(A5)
Code0End
Patch0
	move.w	#15,$96(A5)
	tst.w	SongEndFlag
	bne.b	NoEnd1
	bsr.w	SongEnd
NoEnd1
	rts

; Address/length (voice 1) patch for Benn Daglish SID modules

Code1
	MOVE.L	D4,$A0(A5)
	MOVE.W	D3,$A4(A5)
Code1End
Patch1
	move.l	D4,$A0(A5)
	move.w	D3,$A4(A5)
	move.l	A1,-(SP)
	lea	StructAdr(PC),A1
	move.l	D4,UPS_Voice1Adr(A1)
	move.w	D3,UPS_Voice1Len(A1)
	move.l	(SP)+,A1
	rts

; Address/length (voice 2) patch for Benn Daglish SID modules

Code2
	MOVE.L	D5,$B0(A5)
	MOVE.W	D2,$B4(A5)
Code2End
Patch2
	move.l	D5,$B0(A5)
	move.w	D2,$B4(A5)
	move.l	A1,-(SP)
	lea	StructAdr(PC),A1
	move.l	D5,UPS_Voice2Adr(A1)
	move.w	D2,UPS_Voice2Len(A1)
	move.l	(SP)+,A1
	rts

; Address/length (voice 3) patch for Benn Daglish SID modules

Code3
	MOVE.L	D6,$C0(A5)
	MOVE.W	D1,$C4(A5)
Code3End
Patch3
	move.l	D6,$C0(A5)
	move.w	D1,$C4(A5)
	move.l	A1,-(SP)
	lea	StructAdr(PC),A1
	move.l	D6,UPS_Voice3Adr(A1)
	move.w	D1,UPS_Voice3Len(A1)
	move.l	(SP)+,A1
	rts

; DMAWait patch for Benn Daglish SID modules

Code4
Wait	DBRA	D0,Wait
	MOVE.W	2(A5),D0
Code4End
	dc.l	0				; safety buffer ?
Patch4
	movem.l	A1/A2,-(SP)
	lea	StructAdr(PC),A1
	move.l	Vol1Ptr(PC),A2
	move.w	-2(A2),UPS_Voice1Per(A1)
	move.l	Vol2Ptr(PC),A2
	move.w	-2(A2),UPS_Voice2Per(A1)
	move.l	Vol3Ptr(PC),A2
	move.w	-2(A2),UPS_Voice3Per(A1)
	movem.l	(SP)+,A1/A2
	bsr.w	DMAWait
	move.w	2(A5),D0
	rts

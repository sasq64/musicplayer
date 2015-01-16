	******************************************************
	**** Janko Mrsic-Flogel replayer for EaglePlayer, ****
	****         all adaptions by Wanted Team	  ****
	****     DeliTracker 2.32 compatible version	  ****
	******************************************************

	incdir	"dh2:include/"
	include 'misc/eagleplayer2.01.i'
	include	'dos/dos_lib.i'

	SECTION	Player,CODE

	PLAYERHEADER Tags

	dc.b	'$VER: Janko Mrsic-Flogel player module V1.0 (25 Sep 2001)',0
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
	dc.b	'Janko Mrsic-Flogel',0
Creator
	dc.b	'(c) 1986-88 by Janko Mrsic-Flogel,',10
	dc.b	'adapted by Wanted Team',0
Prefix
	dc.b	'JMF.',0
	even
DeliBase
	dc.l	0
ModulePtr
	dc.l	0
PlayPtr
	dc.l	0
InitSongPtr
	dc.l	0
Change
	dc.w	0
EagleBase
	dc.l	0
SongEndFlag
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
**************************** EP_ModuleChange ******************************
***************************************************************************

ModuleChange
	move.w	Change(PC),D0
	bne.s	NoChange
	move.l	PlayPtr(PC),EPG_ARG1(A5)
	lea	PatchTable(PC),A1
	move.l	A1,EPG_ARG3(A5)
	move.l	#1200,D1
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
Exit2
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
	move.l	InfoBuffer+SynthSamples(PC),D5
	beq.b	return

	subq.l	#1,D5
hop
	jsr	ENPP_AllocSampleStruct(A5)
	move.l	D0,(A3)
	beq.b	return
	move.l	D0,A3

	move.w	#USITY_AMSynth,EPS_Type(A3)
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
	cmp.l	#'J.FL',(A0)+
	bne.b	fail
	cmp.l	#'OGEL',(A0)+
	bne.b	fail
	tst.l	(A0)+				; Interrupt pointer check
	beq.b	fail
	tst.l	(A0)+				; InitSong pointer check
	beq.b	fail
	tst.l	(A0)				; subsongs label check
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
CalcSize	=	44
SpecialInfo	=	52
AuthorName	=	60
SongName	=	68
SynthSamples	=	76

InfoBuffer
	dc.l	MI_SubSongs,0		;4
	dc.l	MI_LoadSize,0		;12
	dc.l	MI_Songsize,0		;20
	dc.l	MI_Voices,3
	dc.l	MI_MaxVoices,3
	dc.l	MI_Calcsize,0		;44
	dc.l	MI_SpecialInfo,0	;52
	dc.l	MI_AuthorName,0		;60
	dc.l	MI_SongName,0		;68
	dc.l	MI_SynthSamples,0	;76
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
	move.w	#UPSB_Adr!UPSB_Len!UPSB_Per!UPSB_Vol,UPS_Flags(A0)

	move.l	PlayPtr(PC),A0
	jsr	(A0)			; play module

	lea	StructAdr(PC),A0
	clr.w	UPS_Enabled(A0)

	movem.l	(SP)+,D1-D7/A0-A6
	moveq	#0,D0
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
	move.l	dtg_DOSBase(A5),A6
	move.l	dtg_PathArrayPtr(A5),D1
	jsr	_LVOLoadSeg(A6)
	lsl.l	#2,D0
	beq.w	InitFail
	addq.l	#4,D0

	move.l	D0,A0				; module address
	lea	ModulePtr(PC),A1
	move.l	D0,(A1)+
	addq.l	#8,A0
	addq.l	#4,A0
	move.l	(A0)+,(A1)+			; Play pointer
	move.l	(A0)+,(A1)+			; InitSong pointer

	lea	InfoBuffer(PC),A2
	move.l	(A0)+,SubSongs(A2)
	move.l	(A0)+,SynthSamples(A2)
	move.l	(A0)+,SongName(A2)
	move.l	(A0)+,AuthorName(A2)
	move.l	(A0)+,SpecialInfo(A2)
	move.l	(A0)+,LoadSize(A2)
	move.l	(A0),CalcSize(A2)

	clr.w	(A1)+				; Change
	move.l	A5,(A1)				; EagleBase

	move.l	PlayPtr(PC),A1
FindIt1
	cmp.l	#$DFF0AA,(A1)
	beq.b	ChangeIt1
	addq.l	#2,A1
	bra.b	FindIt1
ChangeIt1
	subq.l	#4,A1
	move.l	(A1),Code4+2
	move.l	(A1),Patch4+2
	move.l	(A1),Change1+2
	addq.l	#8,A1
FindIt2
	cmp.l	#$DFF0AA,(A1)
	beq.b	ChangeIt2
	addq.l	#2,A1
	bra.b	FindIt2
ChangeIt2
	subq.l	#4,A1
	move.l	(A1),Code5+2
	move.l	(A1),Patch5+2
	move.l	(A1),Change2+2
	addq.l	#8,A1
FindIt3
	cmp.l	#$DFF0BA,(A1)
	beq.b	ChangeIt3
	addq.l	#2,A1
	bra.b	FindIt3
ChangeIt3
	subq.l	#4,A1
	move.l	(A1),Code6+2
	move.l	(A1),Patch6+2
	move.l	(A1),Change3+2
	addq.l	#8,A1
FindIt4
	cmp.l	#$DFF0BA,(A1)
	beq.b	ChangeIt4
	addq.l	#2,A1
	bra.b	FindIt4
ChangeIt4
	subq.l	#4,A1
	move.l	(A1),Code7+2
	move.l	(A1),Patch7+2
	move.l	(A1),Change4+2
	addq.l	#8,A1
FindIt5
	cmp.l	#$DFF0CA,(A1)
	beq.b	ChangeIt5
	addq.l	#2,A1
	bra.b	FindIt5
ChangeIt5
	subq.l	#4,A1
	move.l	(A1),Code8+2
	move.l	(A1),Patch8+2
	move.l	(A1),Change5+2
	addq.l	#8,A1
FindIt6
	cmp.l	#$DFF0CA,(A1)
	beq.b	ChangeIt6
	addq.l	#2,A1
	bra.b	FindIt6
ChangeIt6
	subq.l	#4,A1
	move.l	(A1),Code9+2
	move.l	(A1),Patch9+2
	move.l	(A1),Change6+2

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
	lea	SongEndFlag(PC),A3
	st	(A3)
	move.l	InitSongPtr(PC),A0
	jsr	(A0)
	clr.w	(A3)
	rts

***************************************************************************
***************************** DTP_EndSound ********************************
***************************************************************************

EndSound
	lea	$DFF000,A0
	move.w	#15,$96(A0)
	clr.w	$A8(A0)
	clr.w	$B8(A0)
	clr.w	$C8(A0)
	clr.w	$D8(A0)
	rts

*----------------- PatchTable for Janko Mrsic-Flogel -------------------*

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

; SongEnd patch for Janko Mrsic-Flogel modules

Code0
	MOVE.W	#15,$DFF096
Code0End
Patch0
	tst.w	SongEndFlag
	bne.b	NoEnd
	movem.l	A1/A5,-(A7)
	move.l	EagleBase(PC),A5
	move.l	dtg_SongEnd(A5),A1
	jsr	(A1)
	movem.l	(A7)+,A1/A5
NoEnd
	move.w	#15,$DFF096
	rts

; Period (voice 1) patch for Janko Mrsic-Flogel modules

Code1
	MOVE.W	D1,$DFF0A6
Code1End
Patch1
	move.w	D1,$DFF0A6
	movem.l	A1/D0,-(SP)
	lea	StructAdr(PC),A1
	move.w	D1,UPS_Voice1Per(A1)
	moveq	#56,D0
	bsr.w	Left1
	move.w	D0,$DFF0A8
	move.w	D0,UPS_Voice1Vol(A1)
	movem.l	(SP)+,D0/A1
	rts

; Period (voice 2) patch for Janko Mrsic-Flogel modules

Code2
	MOVE.W	D1,$DFF0B6
Code2End
Patch2
	move.w	D1,$DFF0B6
	movem.l	A1/D0,-(SP)
	lea	StructAdr(PC),A1
	move.w	D1,UPS_Voice2Per(A1)
	moveq	#56,D0
	bsr.w	Right1
	move.w	D0,$DFF0B8
	move.w	D0,UPS_Voice2Vol(A1)
	movem.l	(SP)+,D0/A1
	rts

; Period (voice 3) patch for Janko Mrsic-Flogel modules

Code3
	MOVE.W	D1,$DFF0C6
Code3End
Patch3
	move.w	D1,$DFF0C6
	movem.l	A1/D0,-(SP)
	lea	StructAdr(PC),A1
	move.w	D1,UPS_Voice3Per(A1)
	moveq	#56,D0
	bsr.w	Right2
	move.w	D0,$DFF0C8
	move.w	D0,UPS_Voice3Vol(A1)
	movem.l	(SP)+,D0/A1
	rts

; Address/length (voice 1) patch for Janko Mrsic-Flogel modules

Code4
	MOVE.L	#'WTWT',$DFF0AA
	MOVE.W	#$10,$DFF0A4
Code4End
Patch4
	move.l	#'WTWT',$DFF0A0
	move.w	#$10,$DFF0A4
	movem.l	A1/D0,-(SP)
	lea	StructAdr(PC),A1
Change1
	move.l	#'WTWT',UPS_Voice1Adr(A1)
	moveq	#16,D0
	move.w	D0,UPS_Voice1Len(A1)
	movem.l	(SP)+,D0/A1
	rts

; Address/length (voice 1) patch for Janko Mrsic-Flogel modules

Code5
	MOVE.L	#'WTWT',$DFF0AA
Code5End
Patch5
	move.l	#'WTWT',$DFF0A0
	movem.l	A1/D0,-(SP)
	lea	StructAdr(PC),A1
Change2
	move.l	#'WTWT',UPS_Voice1Adr(A1)
	moveq	#4,D0
	move.w	D0,UPS_Voice1Len(A1)
	movem.l	(SP)+,D0/A1
	rts

; Address/length (voice 2) patch for Janko Mrsic-Flogel modules

Code6
	MOVE.L	#'WTWT',$DFF0BA
	MOVE.W	#$10,$DFF0B4
Code6End
Patch6
	move.l	#'WTWT',$DFF0B0
	move.w	#$10,$DFF0B4
	movem.l	A1/D0,-(SP)
	lea	StructAdr(PC),A1
Change3
	move.l	#'WTWT',UPS_Voice2Adr(A1)
	moveq	#16,D0
	move.w	D0,UPS_Voice2Len(A1)
	movem.l	(SP)+,D0/A1
	rts

; Address/length (voice 2) patch for Janko Mrsic-Flogel modules

Code7
	MOVE.L	#'WTWT',$DFF0BA
Code7End
Patch7
	move.l	#'WTWT',$DFF0B0
	movem.l	A1/D0,-(SP)
	lea	StructAdr(PC),A1
Change4
	move.l	#'WTWT',UPS_Voice2Adr(A1)
	moveq	#4,D0
	move.w	D0,UPS_Voice2Len(A1)
	movem.l	(SP)+,D0/A1
	rts

; Address/length (voice 3) patch for Janko Mrsic-Flogel modules

Code8
	MOVE.L	#'WTWT',$DFF0CA
	MOVE.W	#$10,$DFF0C4
Code8End
Patch8
	move.l	#'WTWT',$DFF0C0
	move.w	#$10,$DFF0C4
	movem.l	A1/D0,-(SP)
	lea	StructAdr(PC),A1
Change5
	move.l	#'WTWT',UPS_Voice3Adr(A1)
	moveq	#16,D0
	move.w	D0,UPS_Voice3Len(A1)
	movem.l	(SP)+,D0/A1
	rts

; Address/length (voice 3) patch for Janko Mrsic-Flogel modules

Code9
	MOVE.L	#'WTWT',$DFF0CA
Code9End
Patch9
	move.l	#'WTWT',$DFF0C0
	movem.l	A1/D0,-(SP)
	lea	StructAdr(PC),A1
Change6
	move.l	#'WTWT',UPS_Voice3Adr(A1)
	moveq	#4,D0
	move.w	D0,UPS_Voice3Len(A1)
	movem.l	(SP)+,D0/A1
	rts

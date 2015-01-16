	*****************************************************
	****         Steve Barrett replayer for	 	 ****
	****    EaglePlayer 2.00+ (Amplifier version),   ****
	****        all adaptions by Wanted Team	 ****
	*****************************************************

	incdir	"dh2:include/"
	include 'misc/eagleplayer2.01.i'
	include	'misc/eagleplayerengine.i'
	include	'exec/exec_lib.i'
	include	'exec/execbase.i'

	SECTION	Player,CODE

	EPPHEADER Tags

	dc.b	'$VER: Steve Barrett player module V2.0 (11 Dec 2002)',0
	even
Tags
	dc.l	DTP_PlayerVersion,2<<16!0
	dc.l	EP_PlayerVersion,11
	dc.l	DTP_PlayerName,PlayerName
	dc.l	DTP_Creator,Creator
	dc.l	EP_Check5,Check5
	dc.l	DTP_Interrupt,Interrupt
	dc.l	DTP_SubSongRange,SubSongRange
	dc.l	DTP_InitPlayer,InitPlayer
	dc.l	DTP_InitSound,InitSound
	dc.l	EP_NewModuleInfo,NewModuleInfo
	dc.l	EP_ModuleChange,ModuleChange
	dc.l	EP_GetPositionNr,GetPosition
	dc.l	EP_SampleInit,SampleInit
	dc.l	EP_InitAmplifier,InitAudstruct
	dc.l	EP_EagleBase,EagleBase
	dc.l	EP_Flags,EPB_Songend!EPB_ModuleInfo!EPB_SampleInfo!EPB_Packable!EPB_Restart!EPB_PrevSong!EPB_NextSong
	dc.l	TAG_DONE
PlayerName
	dc.b	'Steve Barrett',0
Creator
	dc.b	'(c) 1988-90 by Steve Barrett & Wally',10
	dc.b	'Beben, adapted by Wanted Team',0
Prefix
	dc.b	'SB.',0
Text
	dc.b	'Loaded module runs at 100Hz !!!',0
	even
ModulePtr
	dc.l	0
A4_Base
	dc.l	0
SamplesPtr
	dc.l	0
SongsPtr
	dc.l	0
VoicesPtr
	dc.l	0
BytePtr
	dc.l	0
Change
	dc.w	0
SongEnd
	dc.l	'WTWT'
Byte
	dc.w	0
EndFlag
	dc.w	0
TimerStore
	dc.w	0

*------------------------------ Amplifier Tags ---------------------------*
EagleBase	dc.l	0
AudTagliste	dc.l	EPAMT_NumStructs,4
		dc.l	EPAMT_AudioStructs,AudStruct0
		dc.l	EPAMT_Flags
Aud_NoteFlags	dc.l	0
AudStruct0	ds.b	AS_Sizeof*4

***************************************************************************
****************************** EP_InitAmplifier ***************************
***************************************************************************

InitAudstruct
	moveq	#EPAMB_WaitForStruct!EPAMB_Direct!EPAMB_8Bit,d7
	moveq	#0,d0
	jsr	ENPP_GetListData(a5)
	tst.l	d0
	beq.s	.Error

	move.l	a0,a1
	move.l	4,a6
	jsr	_LVOTypeOfMem(a6)
	btst	#1,d0
	beq.s	.NoChip
	or.w	#EPAMB_ChipRam,d7
.NoChip
	lea	AudStruct0,a0		;Audio Struktur vorbereiten
	move.l	d7,Aud_NoteFlags-AudStruct0(a0)
	lea	(a0),a1
	move.w	#AS_Sizeof*4-1,d0
.Clr
	clr.b	(a1)+
	dbf	d0,.Clr

	move.w	#01,AS_LeftRight(a0)			;1. Kanal links
	move.w	#-1,AS_LeftRight+AS_Sizeof*1(a0)	;2. Kanal rechts
	move.w	#-1,AS_LeftRight+AS_Sizeof*2(a0)	;3. Kanal rechts
	move.w	#01,AS_LeftRight+AS_Sizeof*3(a0)	;4. Kanal links

	lea	AudTagliste(pc),a0
	move.l	a0,EPG_AmplifierTagList(a5)
	moveq	#0,d0
	rts
.Error
	moveq	#EPR_NoModuleLoaded,d0
	rts

*---------------------------------------------------------------------------*
* Input		D0 = Address value
PokeAdr
	movem.l	D1/A5,-(SP)
	move.w	A5,D1		;F0A0/F0B0/F0C0/F0D0
	sub.w	#$F0A0,D1
	lsr.w	#4,D1		;Number the channel from 0-3
	move.l	EagleBase(PC),A5
	jsr	ENPP_PokeAdr(A5)
	movem.l	(SP)+,D1/A5
	rts

*---------------------------------------------------------------------------*
* Input		D0 = Length value
PokeLen
	movem.l	D1/A5,-(SP)
	move.w	A5,D1		;F0A4/F0B4/F0C4/F0D4
	sub.w	#$F0A4,D1
	lsr.w	#4,D1		;Number the channel from 0-3
	move.l	EagleBase(PC),A5
	and.l	#$FFFF,D0
	jsr	ENPP_PokeLen(A5)
	movem.l	(SP)+,D1/A5
	rts

*---------------------------------------------------------------------------*
* Input		D0 = Bitmask
PokeDMA
	movem.l	D1/A5,-(SP)
	move.w	D0,D1
	and.w	#$8000,D0	;D0.w neg=enable ; 0/pos=disable
	and.l	#15,D1		;D1 = Mask (LONG !!)
	move.l	EagleBase(PC),A5
	jsr	ENPP_DMAMask(A5)
	movem.l	(SP)+,D1/A5
	rts

***************************************************************************
******************************* EP_SampleInit *****************************
***************************************************************************

SampleInit
	moveq	#EPR_NotEnoughMem,D7
	lea	EPG_SampleInfoStructure(A5),A3
	move.l	SamplesPtr(PC),D0
	beq.b	return
	move.l	D0,A2

	move.l	InfoBuffer+Samples(PC),D5
	subq.l	#1,D5
	moveq	#104,D4
hop
	jsr	ENPP_AllocSampleStruct(A5)
	move.l	D0,(A3)
	beq.b	return
	move.l	D0,A3

	lea	48(A2),A1
	move.l	100(A2),D1
	move.l	A2,EPS_Adr(A3)			; sample address
	add.l	D4,D1
	move.l	D1,EPS_Length(A3)		; sample length
	move.l	A1,EPS_SampleName(A3)		; sample name
	move.l	#64,EPS_Volume(A3)
	move.w	#USITY_RAW,EPS_Type(A3)
	move.w	#20,EPS_MaxNameLen(A3)
	move.w	#USIB_Playable!USIB_Saveable!USIB_8BIT,EPS_Flags(A3)
	add.l	D1,A2
	dbf	D5,hop

	moveq	#0,D7
return
	move.l	D7,D0
	rts

***************************************************************************
**************************** EP_GetPositionNr *****************************
***************************************************************************

GetPosition
	moveq	#0,D0
	move.l	VoicesPtr(PC),A0
	add.w	Byte(PC),A0
	move.b	12(A0),D0
	rts

***************************************************************************
**************************** EP_ModuleChange ******************************
***************************************************************************

ModuleChange
	move.w	Change(PC),D0
	bne.s	NoChange
	move.l	ModulePtr(PC),EPG_ARG1(A5)
	lea	PatchTable(PC),A1
	move.l	A1,EPG_ARG3(A5)
	move.l	#2300,D1
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
******************************** EP_Check5 ********************************
***************************************************************************

Check5
	movea.l	dtg_ChkData(A5),A0
	moveq	#-1,D0

	move.l	A0,A1
	moveq	#3,D1
NextBranch
	cmp.w	#$6000,(A0)+
	bne.b	Fault
	move.w	(A0)+,D2
	btst	#0,D2
	bne.b	Fault
	dbf	D1,NextBranch
	lea	(A0,D2.W),A0
	cmp.w	#$2A7C,(A0)+
	bne.b	Fault
	cmp.l	#$00DFF0A8,(A0)
	bne.b	Fault
FindIt
	cmp.w	#$41FA,(A1)+
	bne.b	FindIt
	add.w	(A1),A1
	cmp.l	#'FORM',(A1)
	bne.b	Fault
	moveq	#0,D0
Fault
	rts

***************************************************************************
***************************** EP_NewModuleInfo ****************************
***************************************************************************

NewModuleInfo

SubSongs	=	4
LoadSize	=	12
SongSize	=	20
Samples		=	28
CalcSize	=	36
SamplesSize	=	44
SpecialInfo	=	52
Length		=	60
Extra		=	68

InfoBuffer
	dc.l	MI_SubSongs,0		;4
	dc.l	MI_LoadSize,0		;12
	dc.l	MI_Songsize,0		;20
	dc.l	MI_Samples,0		;28
	dc.l	MI_Calcsize,0		;36
	dc.l	MI_SamplesSize,0	;44
	dc.l	MI_SpecialInfo,0	;52
	dc.l	MI_Length,0		;60
	dc.l	MI_ExtraInfo,0		;68
	dc.l	MI_Prefix,Prefix
	dc.l	0

***************************************************************************
***************************** DTP_Intterrupt ******************************
***************************************************************************

Interrupt	
	movem.l	D1-D7/A0-A6,-(SP)

	move.l	ModulePtr(PC),A0
	jsr	8(A0)			; play module

	move.l	EagleBase(PC),A5
	jsr	ENPP_Amplifier(A5)

	movem.l	(SP)+,D1-D7/A0-A6
	moveq	#0,D0
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
	lea	ModulePtr(PC),A6
	move.l	A0,(A6)+			; module buffer

	movem.l	D0/A0/A5,-(SP)
	jsr	(A0)				; init samples
	move.l	A0,D1
	movem.l	(SP)+,D0/A0/A5
	lea	InfoBuffer(PC),A4
	move.l	D0,LoadSize(A4)
	sub.l	A0,D1
	addq.l	#4,D1
	move.l	D1,CalcSize(A4)
	move.l	A2,D2
	move.l	A0,A1
FindIt0
	cmp.w	#$41FA,(A1)+
	bne.b	FindIt0
	lea	-4(A1),A3
	add.w	(A3),A3
	move.l	A3,(A6)+			; A4 Base
	move.l	A1,A2
	add.w	(A1),A2
	move.l	A2,(A6)+			; Samples Ptr
	sub.l	A0,A2
	move.l	A2,SongSize(A4)
	sub.l	A2,D1
	move.l	D1,SamplesSize(A4)
	lea	4(A1),A2
	add.w	(A2),A2
	sub.l	A2,D2
	lsr.l	#3,D2
	move.l	D2,Samples(A4)
FindIt1
	cmp.l	#$E7404281,(A1)
	beq.b	OK1
	addq.l	#2,A1
	bra.b	FindIt1
OK1
	addq.l	#6,A1
	move.l	A1,A2
	add.w	(A1),A2
	move.l	A2,(A6)				; SongsPtr

FindIt5
	cmp.w	#$41FA,(A1)+
	bne.b	FindIt5
	move.l	A1,A2
	add.w	(A1),A2
	move.l	A2,D3
FindIt2
	cmp.l	#$D08043FA,(A1)
	beq.b	OK2
	addq.l	#2,A1
	bra.b	FindIt2
OK2
	addq.l	#4,A1
	move.l	A1,A2
	add.w	(A1),A2
	move.l	A2,D2
	sub.l	(A6)+,D2
	lsr.l	#3,D2
	move.l	D2,SubSongs(A4)
	move.l	D3,(A6)+			;VoicesPtr

FindIt3
	cmp.l	#$197C0003,(A1)
	beq.b	OK3
	addq.l	#2,A1
	bra.b	FindIt3
OK3
	addq.l	#4,A1
	add.w	(A1),A3
	move.l	A3,(A6)+			; Byte Ptr

	lea	16(A0),A0
	move.l	A0,SpecialInfo(A4)
FindT
	cmp.b	#$FA,(A0)
	beq.b	LeaFirst
	cmp.b	#'t',(A0)+
	bne.b	FindT
	cmp.b	#'t',(A0)+
	bne.b	FindT
	move.b	#10,(A0)+
FindLea
	cmp.b	#$FA,(A0)+
	bne.b	FindLea
	clr.b	-3(A0)
LeaFirst
	clr.w	(A6)				; Change

	bsr.w	ModuleChange
	moveq	#0,D0
	rts

***************************************************************************
***************************** DTP_InitSound *******************************
***************************************************************************

InitSound
	lea	InfoBuffer(PC),A0
	sub.l	A4,A4
	cmp.l	#62372,InfoBuffer+SamplesSize	; Adv. Ski Sim. speed fix
	bne.b	NormalSpeed
	lea	Text(PC),A4
	move.w	TimerStore(PC),D0
	bne.b	TimerOK
	move.w	dtg_Timer(A5),D0
	lsr.w	#1,D0
	move.w	D0,TimerStore
TimerOK
	move.w	D0,dtg_Timer(A5)
NormalSpeed
	move.l	A4,Extra(A0)
	lea	SongEnd(PC),A4
	move.l	#'WTWT',(A4)+
	move.w	dtg_SndNum(A5),D0
	move.w	D0,D1
	subq.w	#1,D1
	lsl.w	#3,D1
	move.l	SongsPtr(PC),A1
	lea	(A1,D1.W),A1
	move.l	A4_Base(PC),A3
	moveq	#3,D2
	moveq	#0,D4
	moveq	#-1,D5
NextPos
	addq.l	#1,D5
	move.w	(A1)+,D1
	lea	(A3,D1.W),A2
	moveq	#0,D3
FindEnd
	addq.l	#1,D3
	cmp.b	#$FF,(A2)+
	bne.b	FindEnd
	cmp.l	D3,D4
	bge.b	MaxLen
	move.l	D3,D4
	move.w	D5,(A4)				; Byte
MaxLen
	dbf	D2,NextPos
	clr.w	2(A4)
	move.l	D4,Length(A0)

	move.l	ModulePtr(PC),A0
	jmp	4(A0)				; init song

	*--------------- PatchTable for Steve Barrett ------------------*

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

; DMA patch for Steve Barrett modules

Code0
	MOVE.W	$DFF002,D0
	ANDI.W	#$5F0,D0
	OR.W	D0,D1
	MOVE.W	D1,$DFF096
	EORI.W	#$FFFF,D1
	MOVE.W	D1,$DFF096
Code0End
	dc.l	0				 ; safety buffer ?
Patch0
	or.w	#$8200,D1
	move.l	D0,-(SP)
	move.w	D1,D0
	bsr.w	PokeDMA
	eor.w	#$820F,D1
	move.w	D1,D0
	bsr.w	PokeDMA
	move.l	(SP)+,D0
	rts

; Volume patch for Steve Barrett modules

Code1
	MOVE.W	D0,(A2)
	MOVE.B	(A1)+,D0
	MOVE.W	D0,$10(A2)
	MOVE.B	(A1)+,D0
	MOVE.W	D0,$20(A2)
	MOVE.B	(A1),D0
	MOVE.W	D0,$30(A2)
Code1End
Patch1
	movem.l	D1/A5,-(A7)
	move.l	EagleBase(PC),A5
	moveq	#0,D1
	jsr	ENPP_PokeVol(A5)
	move.b	(A1)+,D0
	moveq	#1,D1
	jsr	ENPP_PokeVol(A5)
	move.b	(A1)+,D0
	moveq	#2,D1
	jsr	ENPP_PokeVol(A5)
	move.b	(A1),D0
	moveq	#3,D1
	jsr	ENPP_PokeVol(A5)
	movem.l	(A7)+,D1/A5
	rts

; Period patch for Steve Barrett modules

Code2
	MOVE.W	(A0)+,(A2)
	MOVE.W	(A0)+,$10(A2)
	MOVE.W	(A0)+,$20(A2)
	MOVE.W	(A0),$30(A2)
Code2End
Patch2
	movem.l	D0/D1/A5,-(A7)
	move.l	EagleBase(PC),A5
	move.w	(A0)+,D0
	moveq	#0,D1
	jsr	ENPP_PokePer(A5)
	move.w	(A0)+,D0
	moveq	#1,D1
	jsr	ENPP_PokePer(A5)
	move.w	(A0)+,D0
	moveq	#2,D1
	jsr	ENPP_PokePer(A5)
	move.w	(A0),D0
	moveq	#3,D1
	jsr	ENPP_PokePer(A5)
	movem.l	(A7)+,D0/D1/A5
	rts

; Address/length patch for Steve Barrett modules

Code3
	MOVE.W	(A1),(A5)
	ADDQ.L	#2,A1
	LEA	$DFF0A0,A5
	ADDA.L	D6,A5
	MOVE.L	(A1),(A5)
Code3End
Patch3
	move.l	D0,-(SP)
	move.w	(A1)+,D0
	bsr.w	PokeLen
	lea	$DFF0A0,A5
	add.l	D6,A5
	move.l	(A1),D0
	bsr.w	PokeAdr
	move.l	(SP)+,D0
	rts

; DMA patch for Steve Barrett modules

Code4
	MOVE.W	D5,$DFF096
Code4End
Patch4
	move.l	D0,-(SP)
	move.w	D5,D0
	bsr.w	PokeDMA
	move.l	(SP)+,D0
	rts

; SongEnd patch for Steve Barrett modules

Code5
	MOVE.B	12(A0),D0
	ADDQ.B	#1,12(A0)
	ADDA.L	D0,A1
Code5End
Patch5
	move.b	12(A0),D0
	addq.b	#1,12(A0)
	add.l	D0,A1
	cmp.b	#$FF,(A1)
	bne.b	NoEnd

	movem.l	A1/A2/A5,-(A7)
	move.l	BytePtr(PC),A2
	lea	SongEnd(PC),A1
	tst.b	(A2)
	bne.b	test1
	clr.b	(A1)
	bra.b	test
test1
	cmp.b	#1,(A2)
	bne.b	test2
	clr.b	1(A1)
	bra.b	test
test2
	cmp.b	#2,(A2)
	bne.b	test3
	clr.b	2(A1)
	bra.b	test
test3
	cmp.b	#3,(A2)
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
	movem.l	(A7)+,A1/A2/A5
NoEnd
	rts

; SongEnd (stop) patch for Wally Beben modules

Code6
	MOVE.W	D0,(A5)
	MOVE.W	D0,$10(A5)
	MOVE.W	D0,$20(A5)
	MOVE.W	D0,$30(A5)
Code6End
Patch6
	movem.l	D1/A5,-(A7)
	move.l	EagleBase(PC),A5
	moveq	#3,D1
ClearVolume
	jsr	ENPP_PokeVol(A5)
	dbf	D1,ClearVolume
	movem.l	(A7)+,D1/A5
	tst.w	EndFlag
	beq.b	NoEnd2
	movem.l	A1/A5,-(A7)
	move.l	EagleBase(PC),A5
	move.l	dtg_SongEnd(A5),A1
	jsr	(A1)
	movem.l	(A7)+,A1/A5
NoEnd2
	st	EndFlag
	rts

; Repeat sample offset fix for Wally Beben (old) modules

Code7
	ANDI.L	#$FFF,D6
Code7End
Patch7
	and.l	#$FFFF,D6
	rts

; Length patch for Steve Barrett modules

Code8
	LEA	$DFF0A4,A5
	ADDA.L	D4,A5
	MOVE.W	D0,(A5)
Code8End
Patch8
	lea	$DFF0A4,A5
	add.l	D4,A5
	bsr.w	PokeLen
	rts

; Address patch for Steve Barrett modules

Code9
	LEA	$DFF0A0,A5
	ADDA.L	D4,A5
	MOVE.L	D6,(A5)
Code9End
Patch9
	lea	$DFF0A0,A5
	add.l	D4,A5
	move.l	D0,-(SP)
	move.l	D6,D0
	bsr.w	PokeAdr
	move.l	(SP)+,D0
	rts

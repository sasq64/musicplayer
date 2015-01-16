	******************************************************
	****           Special FX replayer for     	  ****
	****    EaglePlayer 2.00+ (Amplifier version),    ****
	****         all adaptions by Wanted Team	  ****
	******************************************************

	incdir	"dh2:include/"
	include 'misc/eagleplayer2.01.i'
	include	'misc/eagleplayerengine.i'
	include	'exec/exec_lib.i'

	SECTION	Player,CODE

	EPPHEADER Tags

	dc.b	'$VER: Special FX player module V2.0 (25 Mar 2007)',0
	even
Tags
	dc.l	DTP_PlayerVersion,2<<16!0
	dc.l	EP_PlayerVersion,11
	dc.l	DTP_PlayerName,PlayerName
	dc.l	DTP_Creator,Creator
	dc.l	EP_Check5,Check5
	dc.l	DTP_SubSongRange,SubSongRange
	dc.l	DTP_InitPlayer,InitPlayer
	dc.l	DTP_InitSound,InitSound
	dc.l	DTP_EndSound,EndSound
	dc.l	DTP_Interrupt,Interrupt
	dc.l	EP_NewModuleInfo,NewModuleInfo
	dc.l	EP_SampleInit,SampleInit
	dc.l	EP_GetPositionNr,GetPosition
	dc.l	EP_ModuleChange,ModuleChange
	dc.l	EP_Flags,EPB_ModuleInfo!EPB_SampleInfo!EPB_Songend!EPB_NextSong!EPB_PrevSong!EPB_Packable!EPB_Restart
	dc.l	EP_EagleBase,EagleBase
	dc.l	EP_InitAmplifier,InitAudstruct
	dc.l	0

PlayerName
	dc.b	'Special FX',0
Creator
	dc.b	'(c) 1989-91 by Matthew Cannon &',10
	dc.b	'Jonathan Dunn, adapted by Wanted Team',0
Prefix
	dc.b	'JD.',0
	even
ModulePtr
	dc.l	0
InitPtr
	dc.l	0
PlayPtr
	dc.l	0
FirstCode
	dc.l	0
Origin
	dc.l	0
ChangeLen
	dc.l	0
Change
	dc.w	0
SongAdr
	dc.l	0
SamplesPtr
	dc.l	0
Position1
	dc.l	0
Songend
	dc.l	0
SongEndTemp
	dc.l	0
FirstOn
	dc.l	0
CurPos
	dc.l	0

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
* Input		D0 = Volume value
ClearVol
	movem.l	D1/A5,-(SP)
	move.w	A1,D1		;DFF0A8/B8/C8/D8
	sub.w	#$F0A8,D1
	lsr.w	#4,D1		;Number the channel from 0-3
	move.l	EagleBase(PC),A5
	jsr	ENPP_PokeVol(A5)
	movem.l	(SP)+,D1/A5
	rts

*---------------------------------------------------------------------------*
* Input		D0 = Bitmask
PokeDMA
	movem.l	D0/D1/A5,-(SP)
	move.w	D0,D1
	and.w	#$8000,D0	;D0.w neg=enable ; 0/pos=disable
	and.l	#15,D1		;D1 = Mask (LONG !!)
	move.l	EagleBase(PC),A5
	jsr	ENPP_DMAMask(a5)
	movem.l	(SP)+,D0/D1/A5
	rts

***************************************************************************
********************************* EP_GetPosNr *****************************
***************************************************************************

GetPosition
	move.l	CurPos(PC),A0
	move.l	6(A0),D0
	sub.l	FirstOn(PC),D0
	rts

***************************************************************************
****************************** EP_ModuleChange ****************************
***************************************************************************

ModuleChange
	move.w	Change(PC),D0
	bne.s	NoChange
	move.l	FirstCode(PC),EPG_ARG1(A5)
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
***************************** DTP_EndSound ********************************
***************************************************************************

EndSound
	moveq	#0,D0
	move.l	ModulePtr(PC),A0
	jmp	4(A0)

***************************************************************************
***************************** DTP_Interrupt *******************************
***************************************************************************

Interrupt
	movem.l	D1-D7/A0-A6,-(A7)

	move.l	InfoBuffer+Voices(PC),D1
	bne.b	Play
	move.l	EagleBase(PC),A5
	move.l	dtg_SongEnd(A5),A1
	jsr	(A1)
Play
	move.l	PlayPtr(PC),A0
	jsr	(A0)

	move.l	EagleBase(PC),A5
	jsr	ENPP_Amplifier(A5)

	movem.l	(A7)+,D1-D7/A0-A6
	moveq	#0,D0
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
	beq.b	return
	subq.l	#1,D5
hop
	jsr	ENPP_AllocSampleStruct(A5)
	move.l	D0,(A3)
	beq.b	return
	move.l	D0,A3

NextSamp
	cmp.l	#'FORM',(A2)
	beq.b	SampOK
	addq.l	#2,A2
	bra.b	NextSamp

SampOK
	move.l	A2,EPS_Adr(A3)			; sample address
	moveq	#8,D1
	cmp.l	#'NAME',40(A2)
	bne.b	NoName
	lea	46(A2),A1
	move.w	(A1)+,EPS_MaxNameLen(A3)
	move.l	A1,EPS_SampleName(A3)		; sample name
NoName
	addq.l	#4,A2
	add.l	(A2),D1
	add.l	(A2)+,A2
	move.l	D1,EPS_Length(A3)		; sample length
	move.l	#64,EPS_Volume(A3)
	move.w	#USITY_RAW,EPS_Type(A3)
	move.w	#USIB_Playable!USIB_Saveable!USIB_8BIT,EPS_Flags(A3)
	dbf	D5,hop

	moveq	#0,D7
return
	move.l	D7,D0
	rts

***************************************************************************
***************************** EP_NewModuleInfo ****************************
***************************************************************************

NewModuleInfo

SubSongs	=	4
LoadSize	=	12
Voices		=	20
SamplesSize	=	28
Samples		=	36
Length		=	44

InfoBuffer
	dc.l	MI_SubSongs,0		;4
	dc.l	MI_LoadSize,0		;12
	dc.l	MI_Voices,0		;20
	dc.l	MI_SamplesSize,0	;28
	dc.l	MI_Samples,0		;36
	dc.l	MI_Length,0		;44
	dc.l	MI_MaxVoices,4
	dc.l	MI_Prefix,Prefix
	dc.l	0

***************************************************************************
******************************** EP_Check5 ********************************
***************************************************************************

Check5
	movea.l	dtg_ChkData(A5),A0
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

	moveq	#2,D4
BranchTest
	cmp.w	(A0)+,D1
	bne.s	Return
	move.w	(A0)+,D3
	bmi.b	Return
	beq.b	Return
	btst	#0,D3
	bne.b	Return
	dbf	D4,BranchTest
	add.w	D2,A1
	cmp.w	(A0),D1
	bne.b	OldFor
	moveq	#2,D4
BranchTest2
	cmp.w	(A0)+,D1
	bne.s	Return
	move.w	(A0)+,D3
	bmi.b	Return
	beq.b	Return
	btst	#0,D3
	bne.b	Return
	dbf	D4,BranchTest2
	cmp.w	(A0),D1
	beq.b	Return
	bra.b	CheckLea
OldFor
	cmp.w	#$6100,(A1)
	bne.b	Return
	addq.l	#4,A1
CheckLea
	cmp.w	#$41F9,(A1)
	bne.b	Return
	addq.l	#6,A1
	cmp.w	#$43F9,(A1)
	bne.b	Return
	moveq	#0,D0
Return
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

	lea	ModulePtr(PC),A4
	move.l	A0,(A4)+			; module buffer
	lea	InfoBuffer(PC),A6		; A6 reserved for InfoBuffer
	move.l	D0,LoadSize(A6)

	move.l	A0,D6
	lea	16(A0),A1
	move.l	#$005F0166,D1			; old periods
	cmp.w	#$6000,(A1)
	beq.b	NewFormat
	cmp.l	#$F3EE,2418(A0)			; empty sample fix
	bne.b	NoZealand
	subq.l	#2,2418(A0)
NoZealand

	subq.l	#8,A1
	move.l	A1,(A4)+			; InitPtr
	addq.l	#4,A1
	move.l	A1,(A4)+			; PlayPtr

FindIt0
	cmp.w	#$48E7,(A1)+
	bne.b	FindIt0
	lea	-2(A1),A3
	bra.b	SkipNew1
NewFormat
	move.l	A1,(A4)+			; InitPtr
	addq.l	#8,A1
	move.l	A1,(A4)+			; PlayPtr
	lea	2(A0),A1
	add.w	(A1),A1
	move.l	A1,A3
	move.l	A3,A2
CheckPer
	cmp.w	#$77,(A2)+
	bne.b	CheckPer
	cmp.w	#$7E,-4(A2)
	bne.b	SkipNew1
	move.l	#$007701BF,D1			; new periods
SkipNew1
	move.l	A3,(A4)+			; FirstCode
FindIt1
	cmp.w	#$4BF9,(A1)+
	bne.b	FindIt1
	move.l	(A1)+,D7
FindPeriod
	cmp.w	(A1)+,D1
	bne.b	FindPeriod
	subq.l	#2,A1
	move.l	A1,A2
	sub.l	A0,A1
	sub.l	A1,D7				; origin
	move.l	D7,(A4)+
FindRTS
	cmp.w	#$4E75,-(A2)
	bne.b	FindRTS
	move.l	A2,A1
	sub.l	A3,A2
	move.l	A2,(A4)+			; ChangeLen
	clr.w	(A4)+				; Change

	move.l	A3,D5
	add.l	A2,D5
Back
	cmp.w	#$0279,(A3)			; and.w  #$xx,$Address
	beq.w	Reloc2
	cmp.w	#$13C0,(A3)			; move.b D0,$Address
	beq.w	Reloc1
	cmp.w	#$13FC,(A3)			; move.b #$x,$Address
	beq.w	Reloc2
	cmp.w	#$2079,(A3)			; move.l $Address,A0
	beq.w	Reloc1
	cmp.w	#$23C8,(A3)			; move.l A0,$Address
	beq.w	Reloc1
	cmp.w	#$3039,(A3)			; move.w $Address,D0
	beq.w	Reloc1
	cmp.w	#$3239,(A3)			; move.w $Address,D1
	beq.b	Reloc1
	cmp.w	#$33C7,(A3)			; move.w D7,$Address
	beq.b	Reloc1
	cmp.w	#$3439,(A3)			; move.w $Address,D2
	beq.b	Reloc1
	cmp.w	#$33FC,(A3)			; move.w #$xx,$Address
	beq.b	Reloc2
	cmp.w	#$41F9,(A3)			; lea    $Address,A0
	beq.b	Reloc1
	cmp.w	#$4279,(A3)			; clr.w  $Address
	beq.b	Reloc1
	cmp.w	#$42B9,(A3)			; clr.l  $Address
	beq.b	Reloc1
	cmp.w	#$43F8,(A3)			; lea    $Address.W,A1
	beq.w	Fix
	cmp.w	#$43F9,(A3)			; lea    $Address,A1
	beq.b	Reloc1
	cmp.w	#$45F9,(A3)			; lea    $Address,A2
	beq.b	Reloc1
	cmp.w	#$47F9,(A3)			; lea    $Address,A3
	beq.b	Reloc1
	cmp.w	#$49F9,(A3)			; lea    $Address,A4
	beq.b	Reloc1
	cmp.w	#$4A79,(A3)			; tst.w  $Address
	beq.b	Reloc1
	cmp.w	#$4BF9,(A3)			; lea    $Address,A5
	beq.b	Reloc1
	cmp.w	#$5279,(A3)			; addq.w #$x,$Address
	beq.b	Reloc1
	cmp.w	#$8179,(A3)			; or.w	 D0,$Address
	beq.b	Reloc1
	cmp.w	#$8379,(A3)			; or.w	 D1,$Address
	beq.b	Reloc1
	cmp.w	#$8F79,(A3)			; or.w	 D7,$Address
	beq.b	Reloc1
	cmp.w	#$B039,(A3)			; cmp.b  $Address,D0
	beq.b	Reloc1
	addq.l	#2,A3
	cmp.l	A3,D5
	bne.w	Back
	bra.b	Later

Reloc2
	addq.l	#2,A3
Reloc1
	addq.l	#2,A3
	cmp.w	#$00DF,(A3)			; hardware check
	beq.w	Back
	sub.l	D7,(A3)
	add.l	D6,(A3)+
	bra.w	Back
Later
	swap	D1
FindLast
	cmp.w	(A1)+,D1
	bne.b	FindLast

	lea	2(A0),A2
	add.w	(A2),A2
	cmp.w	#$6100,(A2)
	bne.b	NextFor
	addq.l	#4,A2
NextFor
	addq.l	#6,A2
	cmp.w	#$43F9,(A2)+
	bne.w	Error
	move.l	(A2),A2
NextSynth
	tst.l	2(A1)
	beq.b	NoRelo
	sub.l	D7,2(A1)
	add.l	D6,2(A1)
	tst.l	8(A1)
	beq.b	NoRelo
	sub.l	D7,8(A1)
	add.l	D6,8(A1)
NoRelo
	lea	16(A1),A1			; A1 for sample search
	cmp.l	A1,A2
	bne.b	NextSynth
NoMore

	move.l	InitPtr(PC),A2
	addq.l	#2,A2
	add.w	(A2),A2
FindSub
	cmp.w	#$6508,(A2)+
	bne.b	FindSub
	move.w	-4(A2),SubSongs+2(A6)
FindSong
	cmp.w	#$E740,(A2)+
	bne.b	FindSong
	move.l	-6(A2),(A4)+			; SongAdr
	clr.l	(A4)				; SamplesPtr

	clr.l	Samples(A6)
	clr.l	SamplesSize(A6)

	movem.l	A0/A1/A4/A5/A6,-(SP)

	bsr.w	ModuleChange

	move.l	ModulePtr(PC),A0
	jsr	(A0)				; init samples
	movem.l	(SP)+,A0/A1/A4/A5/A6
	move.l	#'FORM',D2
FindFirst
	cmp.l	(A1),D2
	beq.b	First
	addq.l	#2,A1
	bra.b	FindFirst
First
	move.l	A1,(A4)+			; SamplesPtr
	tst.l	Samples(A6)
	bne.b	NoRambo
	moveq	#0,D0
	moveq	#0,D1
	add.l	LoadSize(A6),A0
	subq.l	#8,A0
NextForm
	cmp.l	A1,A0
	ble.b	NoMoreSamp
	cmp.l	(A1),D2
	beq.b	SampFound
	addq.l	#2,A1
	bra.b	NextForm
SampFound
	addq.l	#4,A1
	addq.l	#1,D0
	add.l	(A1),D1
	addq.l	#8,D1
	add.l	(A1)+,A1
	bra.b	NextForm
NoMoreSamp
	move.l	D0,Samples(A6)
	move.l	D1,SamplesSize(A6)

NoRambo
	move.l	ModulePtr(PC),A0
	moveq	#8,D1
FindLala
	cmp.l	(A0),D1
	beq.b	Lala
	addq.l	#2,A0
	bra.b	FindLala
Lala
	lea	-340(A0),A0
	move.l	A0,(A4)				; Position1

	moveq	#0,D0
	rts

Fix
	cmp.w	#$A8,2(A3)
	bne.b	Error
	lea	InitFix(PC),A2
	move.w	#$4EF9,8(A0)			; jmp to
	move.l	A2,10(A0)			; address
	move.l	A0,D4
	sub.l	A3,D4
	move.w	#$6100,(A3)+			; bsr.w
	addq.w	#6,D4
	move.w	D4,(A3)+
	bra.w	Back

InitFix
	lea	$DFF0A8,A1
	rts

Error
	moveq	#EPR_ErrorInFile,D0
	rts

***************************************************************************
***************************** DTP_InitSound *******************************
***************************************************************************

InitSound
	move.w	dtg_SndNum(A5),D0
	move.w	D0,D1
	subq.w	#1,D1
	move.l	SongAdr(PC),A1
	lsl.w	#3,D1
	add.w	D1,A1
	moveq	#4,D1
	moveq	#0,D2
	lea	Songend(PC),A2
	move.l	#'WTWT',(A2)
	move.l	Position1(PC),A4
	move.w	(A1)+,D3
	bne.b	Voice1On
	subq.l	#1,D1
	clr.b	(A2)
	bra.b	Skip1
Voice1On
	lea	-2(A1,D3.W),A3
	move.l	A3,D2
	move.l	A4,D4
Skip1
	lea	$56(A4),A4
	move.w	(A1)+,D3
	bne.b	Voice2On
	subq.l	#1,D1
	clr.b	1(A2)
	bra.b	Skip2
Voice2On
	tst.l	D2
	bne.b	Skip2
	lea	-2(A1,D3.W),A3
	move.l	A3,D2
	move.l	A4,D4
Skip2
	lea	$56(A4),A4
	move.w	(A1)+,D3
	bne.b	Voice3On
	subq.l	#1,D1
	clr.b	2(A2)
	bra.b	Skip3
Voice3On
	tst.l	D2
	bne.b	Skip3
	lea	-2(A1,D3.W),A3
	move.l	A3,D2
	move.l	A4,D4
Skip3
	lea	$56(A4),A4
	move.w	(A1)+,D3
	bne.b	Voice4On
	subq.l	#1,D1
	clr.b	3(A2)
	bra.b	Skip4
Voice4On
	tst.l	D2
	bne.b	Skip4
	lea	-2(A1,D3.W),A3
	move.l	A3,D2
	move.l	A4,D4
Skip4
	move.l	(A2)+,(A2)+
	move.l	D2,(A2)+			; FirstOn
	move.l	D4,(A2)				; CurPos

	lea	InfoBuffer(PC),A1
	move.l	D1,Voices(A1)
	move.l	InitPtr(PC),A0
	jsr	(A0)

	moveq	#0,D0
	lea	InfoBuffer(PC),A1
	tst.l	Voices(A1)
	beq.b	One
	move.l	FirstOn(PC),A0
	moveq	#1,D0
Moretoo
	cmp.b	#$80,(A0)
	beq.b	One
	addq.l	#1,D0
	addq.l	#1,A0
	bra.b	Moretoo
One
	move.l	D0,Length(A1)
	rts

*---------------------- PatchTable for Special FX -----------------------*

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
	dc.w	CodeA-PatchTable,(CodeAEnd-CodeA)/2-1,PatchA-PatchTable
	dc.w	CodeB-PatchTable,(CodeBEnd-CodeB)/2-1,PatchB-PatchTable
	dc.w	CodeC-PatchTable,(CodeCEnd-CodeC)/2-1,PatchC-PatchTable
	dc.w	CodeD-PatchTable,(CodeDEnd-CodeD)/2-1,PatchD-PatchTable
	dc.w	CodeE-PatchTable,(CodeEEnd-CodeE)/2-1,PatchE-PatchTable
	dc.w	CodeF-PatchTable,(CodeFEnd-CodeF)/2-1,PatchF-PatchTable
	dc.w	CodeG-PatchTable,(CodeGEnd-CodeG)/2-1,PatchG-PatchTable
	dc.w	0

; DMA patch for Special FX modules

Code0
	MOVE.W	D0,$96(A6)
	MOVE.W	D0,D1
	LSL.W	#7,D1
	MOVE.W	D1,$9C(A6)
	MOVEQ	#0,D2
	MOVEQ	#1,D3
	BTST	#0,D0
	BEQ.S	lbC00081C
	MOVE.W	D3,$A6(A6)
	MOVE.W	D2,$AA(A6)
lbC00081C	BTST	#1,D0
	BEQ.S	lbC00082A
	MOVE.W	D3,$B6(A6)
	MOVE.W	D2,$BA(A6)
lbC00082A	BTST	#2,D0
	BEQ.S	lbC000838
	MOVE.W	D3,$C6(A6)
	MOVE.W	D2,$CA(A6)
lbC000838	BTST	#3,D0
	BEQ.S	lbC000846
	MOVE.W	D3,$D6(A6)
	MOVE.W	D2,$DA(A6)
lbC000846	MOVE.W	$1E(A6),D2
	AND.W	D1,D2
	CMP.W	D1,D2
	BNE.S	lbC000846
	MOVEQ	#2,D2
	MOVE.W	6(A6),D3
	ANDI.W	#$FF00,D3
lbC00085A	MOVE.W	6(A6),D4
	ANDI.W	#$FF00,D4
	CMP.W	D4,D3
	BEQ.S	lbC00085A
	MOVE.W	D4,D3
	DBRA	D2,lbC00085A
Code0End
	dc.l	0				; safety buffer ?
Patch0
	bsr.w	PokeDMA
	rts

; Samples patch for Special FX modules (Rambo III)

Code1
	ADDQ.L	#8,A0
	MOVE.L	A0,D0
	SUB.L	(A2),D0
Code1End
Patch1
	addq.l	#8,A0
	move.l	A0,D0
	sub.l	(A2),D0
	sub.l	Origin(PC),A0
	add.l	ModulePtr(PC),A0
	movem.l	D0/A1,-(SP)
	moveq	#8,D0
	lea	InfoBuffer(PC),A1
	add.l	4(A0),D0
	add.l	D0,SamplesSize(A1)
	addq.l	#1,Samples(A1)
	movem.l	(SP)+,D0/A1
	rts

; Volume & period (voice 1) patch for Special FX modules

Code2
	MOVE.W	D3,$A8(A6)
	MOVE.W	$4A(A0),$A6(A6)
Code2End
Patch2
	movem.l	D0/D1/A5,-(SP)
	moveq	#0,D1
	move.l	EagleBase(PC),A5
	move.w	D3,D0
	jsr	ENPP_PokeVol(A5)
	move.w	$4A(A0),D0
	jsr	ENPP_PokePer(A5)
	movem.l	(SP)+,D0/D1/A5
	rts

; Address & length (voice 1) patch for Special FX modules

Code3
	MOVE.W	$42(A0),$A4(A6)
	MOVE.L	$3E(A0),$A0(A6)
Code3End
Patch3
	movem.l	D0/D1/A5,-(SP)
	moveq	#0,D1
	move.l	EagleBase(PC),A5
	moveq	#0,D0
	move.w	$42(A0),D0
	jsr	ENPP_PokeLen(A5)
	move.l	$3E(A0),D0
	jsr	ENPP_PokeAdr(A5)
	movem.l	(SP)+,D0/D1/A5
	rts

; Volume & period (voice 2) patch for Special FX modules

Code4
	MOVE.W	D3,$B8(A6)
	MOVE.W	$4A(A0),$B6(A6)
Code4End
Patch4
	movem.l	D0/D1/A5,-(SP)
	moveq	#1,D1
	move.l	EagleBase(PC),A5
	move.w	D3,D0
	jsr	ENPP_PokeVol(A5)
	move.w	$4A(A0),D0
	jsr	ENPP_PokePer(A5)
	movem.l	(SP)+,D0/D1/A5
	rts

; Address & length (voice 2) patch for Special FX modules

Code5
	MOVE.W	$42(A0),$B4(A6)
	MOVE.L	$3E(A0),$B0(A6)
Code5End
Patch5
	movem.l	D0/D1/A5,-(SP)
	moveq	#1,D1
	move.l	EagleBase(PC),A5
	moveq	#0,D0
	move.w	$42(A0),D0
	jsr	ENPP_PokeLen(A5)
	move.l	$3E(A0),D0
	jsr	ENPP_PokeAdr(A5)
	movem.l	(SP)+,D0/D1/A5
	rts

; Volume & period (voice 3) patch for Special FX modules

Code6
	MOVE.W	D3,$C8(A6)
	MOVE.W	$4A(A0),$C6(A6)
Code6End
Patch6
	movem.l	D0/D1/A5,-(SP)
	moveq	#2,D1
	move.l	EagleBase(PC),A5
	move.w	D3,D0
	jsr	ENPP_PokeVol(A5)
	move.w	$4A(A0),D0
	jsr	ENPP_PokePer(A5)
	movem.l	(SP)+,D0/D1/A5
	rts

; Address & length (voice 3) patch for Special FX modules

Code7
	MOVE.W	$42(A0),$C4(A6)
	MOVE.L	$3E(A0),$C0(A6)
Code7End
Patch7
	movem.l	D0/D1/A5,-(SP)
	moveq	#2,D1
	move.l	EagleBase(PC),A5
	moveq	#0,D0
	move.w	$42(A0),D0
	jsr	ENPP_PokeLen(A5)
	move.l	$3E(A0),D0
	jsr	ENPP_PokeAdr(A5)
	movem.l	(SP)+,D0/D1/A5
	rts

; Volume & period (voice 4) patch for Special FX modules

Code8
	MOVE.W	D3,$D8(A6)
	MOVE.W	$4A(A0),$D6(A6)
Code8End
Patch8
	movem.l	D0/D1/A5,-(SP)
	moveq	#3,D1
	move.l	EagleBase(PC),A5
	move.w	D3,D0
	jsr	ENPP_PokeVol(A5)
	move.w	$4A(A0),D0
	jsr	ENPP_PokePer(A5)
	movem.l	(SP)+,D0/D1/A5
	rts

; Address & length (voice 4) patch for Special FX modules

Code9
	MOVE.W	$42(A0),$D4(A6)
	MOVE.L	$3E(A0),$D0(A6)
Code9End
Patch9
	movem.l	D0/D1/A5,-(SP)
	moveq	#3,D1
	move.l	EagleBase(PC),A5
	moveq	#0,D0
	move.w	$42(A0),D0
	jsr	ENPP_PokeLen(A5)
	move.l	$3E(A0),D0
	jsr	ENPP_PokeAdr(A5)
	movem.l	(SP)+,D0/D1/A5
	rts

; SongEnd patch for Special FX modules

CodeA
	MOVEA.L	2(A4),A3
	CMPA.W	#0,A3
CodeAEnd
PatchA
SongEndTest
	movem.l	A1/A5,-(A7)
	lea	Songend(PC),A1
	cmp.w	#1,$54(A4)
	bne.b	test1
	clr.b	(A1)
	bra.b	test
test1
	cmp.w	#2,$54(A4)
	bne.b	test2
	clr.b	1(A1)
	bra.b	test
test2
	cmp.w	#4,$54(A4)
	bne.b	test3
	clr.b	2(A1)
	bra.b	test
test3
	cmp.w	#8,$54(A4)
	bne.b	test
	clr.b	3(A1)
test
	tst.l	(A1)
	bne.b	SkipEnd
	move.l	SongEndTemp(PC),(A1)
	move.l	EagleBase(PC),A5
	move.l	dtg_SongEnd(A5),A1
	jsr	(A1)
SkipEnd
	movem.l	(A7)+,A1/A5
	move.l	2(A4),A3
	cmp.w	#0,A3
	rts

; Volume patch for Special FX modules

CodeB
	MOVE.W	#0,(A1)
	ADDA.W	#$56,A0
CodeBEnd
PatchB
	move.l	D0,-(SP)
	moveq	#0,D0
	bsr.w	ClearVol
	move.l	(SP)+,D0
	add.w	#$56,A0
	rts

; Address & length (voice 1) patch for Special FX modules

CodeC
	MOVE.W	$48(A0),$A4(A6)
	MOVE.L	$44(A0),$A0(A6)
CodeCEnd
PatchC
	movem.l	D0/D1/A5,-(SP)
	moveq	#0,D1
	move.l	EagleBase(PC),A5
	moveq	#0,D0
	move.w	$48(A0),D0
	jsr	ENPP_PokeLen(A5)
	move.l	$44(A0),D0
	jsr	ENPP_PokeAdr(A5)
	movem.l	(SP)+,D0/D1/A5
	rts

; Address & length (voice 2) patch for Special FX modules

CodeD
	MOVE.W	$48(A0),$B4(A6)
	MOVE.L	$44(A0),$B0(A6)
CodeDEnd
PatchD
	movem.l	D0/D1/A5,-(SP)
	moveq	#1,D1
	move.l	EagleBase(PC),A5
	moveq	#0,D0
	move.w	$48(A0),D0
	jsr	ENPP_PokeLen(A5)
	move.l	$44(A0),D0
	jsr	ENPP_PokeAdr(A5)
	movem.l	(SP)+,D0/D1/A5
	rts

; Address & length (voice 3) patch for Special FX modules

CodeE
	MOVE.W	$48(A0),$C4(A6)
	MOVE.L	$44(A0),$C0(A6)
CodeEEnd
PatchE
	movem.l	D0/D1/A5,-(SP)
	moveq	#2,D1
	move.l	EagleBase(PC),A5
	moveq	#0,D0
	move.w	$48(A0),D0
	jsr	ENPP_PokeLen(A5)
	move.l	$44(A0),D0
	jsr	ENPP_PokeAdr(A5)
	movem.l	(SP)+,D0/D1/A5
	rts

; Address & length (voice 4) patch for Special FX modules

CodeF
	MOVE.W	$48(A0),$D4(A6)
	MOVE.L	$44(A0),$D0(A6)
CodeFEnd
PatchF
	movem.l	D0/D1/A5,-(SP)
	moveq	#3,D1
	move.l	EagleBase(PC),A5
	moveq	#0,D0
	move.w	$48(A0),D0
	jsr	ENPP_PokeLen(A5)
	move.l	$44(A0),D0
	jsr	ENPP_PokeAdr(A5)
	movem.l	(SP)+,D0/D1/A5
	rts

; DMA patch for Special FX modules

CodeG
	ORI.W	#$8000,D0
	MOVE.W	D0,$96(A6)
CodeGEnd
PatchG
	or.w	#$8000,D0
	bsr.w	PokeDMA
	rts

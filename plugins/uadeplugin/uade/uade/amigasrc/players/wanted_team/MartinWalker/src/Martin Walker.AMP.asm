	*****************************************************
	****         Martin Walker replayer for	 	 ****
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

	dc.b	'$VER: Martin Walker player module V2.0 (20 July 2001)',0
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
	dc.l	EP_Flags,EPB_Songend!EPB_Restart!EPB_NextSong!EPB_PrevSong!EPB_ModuleInfo!EPB_SampleInfo!EPB_Packable
	dc.l	TAG_DONE
PlayerName
	dc.b	'Martin Walker',0
Creator
	dc.b	'(c) 1990-94 by Martin Walker,',10
	dc.b	'adapted by Wanted Team',0
Prefix
	dc.b	'MW.',0
Text
	dc.b	'Loaded module has incomplete replay!!!',0
	even
ModulePtr
	dc.l	0
InitPtr
	dc.l	0
FirstSubsongPtr
	dc.l	0
StepsPtr
	dc.l	0
PlayPtr
	dc.l	0
SamplesInfoPtr
	dc.l	0
SamplesPtr
	dc.l	0
EndSamplesInfoPtr
	dc.l	0
Change
	dc.w	0
ChangeLen
	dc.l	0
CurrentPos
	dc.w	0
SongEnd
	dc.l	'WTWT'
Format
	dc.w	0
TextPtr
	dc.l	Text

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
PokeVol
	movem.l	D1/A5,-(SP)
	move.w	D2,D1		;00/10/20/30
	lsr.w	#4,D1		;Number the channel from 0-3
	move.l	EagleBase(PC),A5
	jsr	ENPP_PokeVol(A5)
	movem.l	(SP)+,D1/A5
	rts

*---------------------------------------------------------------------------*
* Input		D0 = Address value
PokeAdr
	movem.l	D1/A5,-(SP)
	move.w	D2,D1		;00/10/20/30
	lsr.w	#4,D1		;Number the channel from 0-3
	move.l	EagleBase(PC),A5
	jsr	ENPP_PokeAdr(A5)
	movem.l	(SP)+,D1/A5
	rts

*---------------------------------------------------------------------------*
* Input		D0 = Length value
PokeLen
	movem.l	D1/A5,-(SP)
	move.w	D2,D1		;00/10/20/30
	lsr.w	#4,D1		;Number the channel from 0-3
	move.l	EagleBase(PC),A5
	and.l	#$FFFF,D0
	jsr	ENPP_PokeLen(A5)
	movem.l	(SP)+,D1/A5
	rts

*---------------------------------------------------------------------------*
* Input		D0 = Period value
PokePer
	movem.l	D1/A5,-(SP)
	move.w	D2,D1		;00/10/20/30
	lsr.w	#4,D1		;Number the channel from 0-3
	move.l	EagleBase(PC),A5
	jsr	ENPP_PokePer(A5)
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
	move.l	SamplesInfoPtr(PC),D0
	beq.w	return
	move.l	D0,A2

	move.l	EndSamplesInfoPtr(PC),A1
	subq.l	#4,A1
hop
	jsr	ENPP_AllocSampleStruct(A5)
	move.l	D0,(A3)
	beq.b	return
	move.l	D0,A3

	move.l	SamplesPtr(PC),A0
	move.l	(A2)+,D0
	add.l	D0,A0
	move.l	(A2),D1
	sub.l	D0,D1
	move.l	A0,EPS_Adr(A3)			; sample address
	move.l	D1,EPS_Length(A3)		; sample length
	move.l	#64,EPS_Volume(A3)
	move.w	#USITY_RAW,EPS_Type(A3)
	move.w	#USIB_Playable!USIB_Saveable!USIB_8BIT,EPS_Flags(A3)

	cmp.l	A1,A2
	bne.b	hop

	moveq	#0,D7
return
	move.l	D7,D0
	rts

***************************************************************************
**************************** EP_GetPositionNr *****************************
***************************************************************************

GetPosition
	moveq	#0,D0
	move.w	CurrentPos(PC),D0
	lsr.w	#1,D0
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
******************************** EP_Check5 ********************************
***************************************************************************

Check5
	movea.l	dtg_ChkData(A5),A0
	moveq	#-1,D0

	move.l	#$48E7FCFE,D1

	lea	Format(PC),A2

	cmp.l	(A0),D1			; 1st format (without SFX)
	beq.b	OK_1

	cmp.l	#$2F0841FA,(A0)		; 2nd format (with SFX) original ver.
	beq.b	OK_2

	cmp.l	28(A0),D1		; 2nd format (with SFX) ripped with ER
	beq.b	OK_3

	move.w	#$6000,D2
	cmp.w	(A0),D2
	beq.b	OK_4

	moveq	#4,D2
CheckIt1
	cmp.l	#$2F0841FA,28(A0)	; 3rd format (with SFX) ripped with ER
	beq.b	OK_5
	addq.l	#2,A0
	dbf	D2,CheckIt1
	rts
OK_5
	moveq	#75,D2
CheckIt2
	cmp.l	(A0),D1
	beq.b	loop_2
	addq.l	#2,A0
	dbf	D2,CheckIt2
	rts
OK_1
	cmp.w	#$45FA,220(A0)
	beq.b	fail
loop_1
	addq.l	#4,A0
	cmp.l	#$E9417000,(A0)+
	bne.b	fail
	cmp.w	#$41FA,(A0)
	bne.b	fail
	cmp.l	140(A0),D1
	beq.b	OK1
	cmp.l	156(A0),D1
	beq.b	OK1
	cmp.l	160(A0),D1
	bne.b	fail
OK1
	clr.w	(A2)
OK
	moveq	#0,D0
fail
	rts
OK_2
	addq.l	#4,A0
	add.w	(A0),A0
OK_3
	moveq	#28,D2
	add.l	D2,A0
	cmp.w	#$45FA,220(A0)
	bne.b	fail
	bra.b	loop_1
loop_2
	cmp.w	#$45FA,268(A0)
	beq.b	loop_1
	cmp.w	#$E942,274(A0)		; 4th format
	bne.b	fail
	bra.b	loop_1
OK_4
	cmp.w	4(A0),D2
	bne.b	fail
	cmp.w	8(A0),D2
	bne.b	fail
	cmp.w	12(A0),D2
	bne.b	fail
	cmp.w	16(A0),D2
	bne.b	fail
	cmp.w	20(A0),D2
	bne.b	fail
	cmp.w	24(A0),D2
	bne.b	fail
	cmp.w	28(A0),D2
	bne.b	fail
	cmp.w	32(A0),D2
	bne.b	NextCheck		; 3rd format (with SFX) original ver.
	cmp.w	36(A0),D2
	bne.b	fail
NextCheck
	addq.l	#8,A0
	addq.l	#6,A0
	move.l	A0,A1
	add.w	(A0),A0
	cmp.l	(A0),D1
	beq.b	loop_2
	addq.l	#8,A1
	addq.l	#4,A1
	add.w	(A1),A1
	cmp.l	(A1)+,D1		; 5th format
	bne.b	fail
	cmp.w	#$43FA,(A1)
	bne.b	fail
	st	(A2)
	bra.b	OK

***************************************************************************
***************************** EP_NewModuleInfo ****************************
***************************************************************************

NewModuleInfo

SubSongs	=	4
LoadSize	=	12
Songsize	=	20
Samples		=	28
Calcsize	=	36
SamplesSize	=	44
Length		=	52
ExtraInfo	=	60

InfoBuffer
	dc.l	MI_SubSongs,0		;4
	dc.l	MI_LoadSize,0		;12
	dc.l	MI_Songsize,0		;20
	dc.l	MI_Samples,0		;28
	dc.l	MI_Calcsize,0		;36
	dc.l	MI_SamplesSize,0	;44
	dc.l	MI_Length,0		;52
	dc.l	MI_ExtraInfo,0		;60
	dc.l	MI_Prefix,Prefix
	dc.l	0

***************************************************************************
***************************** DTP_Intterrupt ******************************
***************************************************************************

Interrupt	
	movem.l	D1-A6,-(SP)

	move.l	PlayPtr(PC),A0
	jsr	(A0)			; play module

	move.l	EagleBase(PC),A5
	jsr	ENPP_Amplifier(A5)

	movem.l	(SP)+,D1-A6
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
	moveq	#0,D0
	movea.l	dtg_GetListData(A5),A0
	jsr	(A0)
	lea	ModulePtr(PC),A1
	move.l	A0,(A1)+			; module buffer
	lea	Format(PC),A6
	move.l	ModulePtr(PC),A0
	move.l	A0,A2
	lea	InfoBuffer(PC),A4
	move.l	D0,LoadSize(A4)
	clr.l	ExtraInfo(A4)
	lea	TextPtr(PC),A3

	cmp.w	#$6000,(A2)
	bne.b	NotThis3
	addq.l	#8,A2
	addq.l	#6,A2
	move.l	A2,A3
	add.w	(A2),A2
	cmp.w	#$6000,32(A0)
	beq.b	CheckVer
	jsr	(A0)				; Init Player
Loop
	lea	1000(A2),A6
FindIt3
	cmp.l	#$20061A31,(A6)
	beq.b	OK3
	addq.l	#2,A6
	bra.b	FindIt3
CheckVer
	tst.w	(A6)
	beq.b	CheckInit
	addq.l	#8,A3
	move.l	A3,A2
	addq.l	#4,A3
	add.w	(A3),A3
	move.l	A3,PlayPtr
	add.w	(A2),A2
	bra.b	InitFound
OK3
	move.b	9(A6),D0
	move.b	D0,ChangeIt4+3
	move.b	D0,ChangeIt5+3
	bra.b	CheckInit
NotThis3
	cmp.w	#$2F08,(A2)
	bne.b	CheckInit
	jsr	(A0)				; Init Player
	addq.l	#4,A2
	add.w	(A2),A2
SkipIt3
	moveq	#28,D0
	add.l	D0,A2
CheckInit
	cmp.w	#$48E7,(A2)
	beq.b	Ok
	cmp.l	#$48E7FCFE,28(A2)
	bne.b	LastCheck
	move.l	(A3),ExtraInfo(A4)
	bra.b	SkipIt3
LastCheck
	moveq	#127,D0
FindIt7
	cmp.w	#$48E7,(A2)+
	beq.b	ok
	dbf	D0,FindIt7
	bra.b	Error
ok
	move.l	(A3),ExtraInfo(A4)
	subq.l	#2,A2
	bra.b	Loop
Ok
	move.l	A2,A3
InitFound
	move.l	A2,(A1)+			; InitPtr
FindIt5
	cmp.w	#$E941,(A3)+
	beq.b	OK8
	bra.b	FindIt5
OK8
	addq.l	#4,A3
	add.w	(A3),A3
	move.l	A3,(A1)+			; FirstSubsongPtr
FindIt1
	cmp.w	#$6100,(A2)+
	beq.b	Later2
	tst.l	(A2)
	beq.b	Error
	bra.b	FindIt1
Later2
	move.l	A2,A6
	add.w	(A2),A2
FindIt2
	cmp.w	#$49FA,(A2)+
	beq.b	Later3
	tst.l	(A2)
	beq.b	Error
	bra.b	FindIt2
Later3
	add.w	(A2),A2
	move.l	A2,(A1)+			; StepsPtr
	sub.l	A3,A2
	move.l	A2,D0
	lsr.l	#4,D0
	move.l	D0,SubSongs(A4)
	lea	Format(PC),A3
	tst.w	(A3)
	beq.b	FindPlay
	move.l	(A1)+,A6
	moveq	#120,D0
	add.l	D0,A6
	bra.b	SkipIt2
FindPlay
	cmp.w	#$4E75,(A6)+
	beq.b	Later4
	tst.l	(A6)
	beq.b	Error
	bra.b	FindPlay
Later4
	move.l	A6,(A1)+			; PlayPtr
SkipIt2
	moveq	#127,D0
FindIt6
	cmp.w	#$6532,(A6)+
	beq.b	OK9
	dbf	D0,FindIt6
Error
	moveq	#EPR_UnknownFormat,D0
	rts
OK9
	subq.l	#4,A6
	move.w	(A6),ChangeIt6+4
	move.w	(A6),ChangeIt7+4
	move.w	(A6),ChangeIt8+4

FindSample
	cmp.l	#$2A325000,(A6)
	beq.b	Later
	tst.l	(A6)
	beq.b	Error
	addq.l	#2,A6
	bra.b	FindSample
Later
	move.l	A6,A3
	subq.l	#2,A3
	add.w	(A3),A3
	move.l	A3,(A1)+			; SamplesInfoPtr
	move.l	A3,D1
	addq.l	#6,A6
	move.l	A6,A3
	add.w	(A3),A3
	move.l	A3,D3
	btst	#0,D3
	beq.b	OK7
	addq.l	#1,D3
	addq.l	#1,A3
OK7
	move.l	A3,(A1)+			; SamplesPtr
	sub.l	A0,D3
	move.l	D3,Songsize(A4)
	moveq	#10,D0
FindIt4
	cmp.w	#$CAFC,(A6)+
	beq.b	OK4
	dbf	D0,FindIt4
	move.l	PlayPtr(PC),A2
	moveq	#18,D0
	add.l	D0,A2
	bra.b	OK5
OK4
	addq.l	#4,A6
	move.l	A6,A2
OK5
	add.w	(A2),A2
	move.l	A2,D0
	sub.l	D1,D0
	lsr.l	#2,D0
	moveq	#32,D2
	cmp.l	D0,D2
	bge.b	OK6
	move.l	D2,D0
	lsl.l	#2,D2
	add.l	D2,D1
	move.l	D1,A2
OK6
	move.l	A2,(A1)+			; EndSamplesInfoPtr
	clr.w	(A1)+				; clearing Change
	subq.l	#4,A2
	add.l	(A2),A3
	addq.l	#1,A3
	sub.l	A0,A3
	move.l	A3,Calcsize(A4)
	sub.l	D3,A3
	move.l	A3,SamplesSize(A4)

	subq.l	#1,D0
	moveq	#-1,D1
	move.l	SamplesInfoPtr(PC),A2
NextSample
	move.l	(A2)+,D2
	sub.l	(A2),D2
	beq.b	NoSample
	addq.l	#1,D1
NoSample
	dbf	D0,NextSample

	move.l	D1,Samples(A4)

FindIt
	cmp.l	#$20043DB0,(A6)
	beq.b	OK2
	cmp.l	#$004C3DB0,(A6)
	beq.b	OK2
	tst.l	(A6)
	beq.b	SkipIt1
	addq.l	#2,A6
	bra.b	FindIt
OK2
	move.b	5(A6),D0
	move.b	D0,ChangeIt1+3
	move.b	D0,ChangeIt3+3

SkipIt1
	move.l	ModulePtr(PC),A0
FindWait
	cmp.w	#$069F,(A0)
	beq.b	EndScan
	cmp.l	#$51C8FFFE,(A0)
	bne.b	NoWait
	cmp.b	#$70,-2(A0)
	bne.b	LongWait
	move.b	#$20,-1(A0)
	bra.b	NoWait
LongWait
	move.w	#$00FF,-2(A0)
NoWait
	addq.l	#2,A0
	bra.b	FindWait
EndScan
	sub.l	ModulePtr(PC),A0
	lea	-250(A0),A0
	move.l	A0,(A1)				; ChangeLen

	bsr.w	ModuleChange

	moveq	#0,D0
	rts

***************************************************************************
***************************** DTP_InitSound *******************************
***************************************************************************

InitSound
	moveq	#0,D1
	move.w	dtg_SndNum(A5),D1
	move.l	D1,D0
	move.l	D1,D2
	lsl.l	#4,D2
	move.l	FirstSubsongPtr(PC),A0
	add.l	D2,A0
	move.w	4(A0),D2
	sub.w	2(A0),D2
	subq.w	#2,D2
	lsr.w	#1,D2
	lea	InfoBuffer(PC),A0
	move.w	D2,Length+2(A0)
	lea	CurrentPos(PC),A0
	clr.w	(A0)+
	move.l	#'WTWT',(A0)
	move.l	InitPtr(PC),A0
	jmp	(A0)

	*--------------- PatchTable for Martin Walker ------------------*

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
	dc.w	CodeH-PatchTable,(CodeHEnd-CodeH)/2-1,PatchH-PatchTable
	dc.w	0

; Address/length patch for Martin Walker modules

Code0
	MOVE.L	6(A0,D2.W),0(A6,D2.W)
	MOVE.W	10(A0,D2.W),4(A6,D2.W)
Code0End
Patch0
	move.l	D0,-(A7)
	move.l	6(A0,D2.W),D0
	bsr.w	PokeAdr
	move.w	10(A0,D2.W),D0
	bsr.w	PokeLen
	move.l	(A7)+,D0
	rts

; Period patch for Martin Walker modules

Code1
ChangeIt1
	MOVE.W	$64(A0,D1.W),6(A6,D2.W)
Code1End
Patch1
	move.l	D0,-(A7)
ChangeIt3
	move.w	$64(A0,D1.W),D0
	bsr.w	PokePer
	move.l	(A7)+,D0
	rts

; Volume patch for Martin Walker modules
; Priority before patch 3 !!!

Code2
	MOVE.W	D3,8(A6,D2.W)
	MOVE.W	$50(A0,D1.W),D5
Code2End
Patch2
	move.l	D0,-(A7)
	move.w	D3,D0
	bsr.w	PokeVol
	move.l	(SP)+,D0
	move.w	$50(A0,D1.W),D5
	rts

; Volume patch for Martin Walker modules
; Priority before patch 4 !!!

Code3
	DIVU.W	#$40,D3
	MOVE.W	D3,8(A6,D2.W)
Code3End
Patch3
	divu.w	#$40,D3
	move.l	D0,-(A7)
	move.w	D3,D0
	bsr.w	PokeVol
	move.l	(SP)+,D0
	rts

; Volume patch for Martin Walker modules
; Priority before patch 5 !!!

Code4
ChangeIt4
	CMP.B	$32(A1,D0.W),D5
	BHI.S	lbC0008D0
	MOVEQ	#0,D3
	BRA.S	lbC0008E0

lbC0008D0	MOVE.W	12(A0,D2.W),D3
	MULU.W	10(A1,D1.W),D3
	MULU.W	8(A1),D3
	DIVU.W	#$1000,D3
lbC0008E0	MOVE.W	D3,8(A6,D2.W)
Code4End
Patch4
ChangeIt5
	cmp.b	$32(A1,D0.W),D5
	bhi.b	NoZero
	moveq	#0,D3
	bra.b	ClearVol
NoZero
	move.w	12(A0,D2.W),D3
	mulu.w	10(A1,D1.W),D3
	mulu.w	8(A1),D3
	divu.w	#$1000,D3
ClearVol
	move.l	D0,-(A7)
	move.w	D3,D0
	bsr.w	PokeVol
	move.l	(SP)+,D0
	rts

; Volume patch for Martin Walker modules

Code5
	DIVU.W	#$1000,D3
	MOVE.W	D3,8(A6,D2.W)
Code5End
Patch5
	divu.w	#$1000,D3
	move.l	D0,-(A7)
	move.w	D3,D0
	bsr.w	PokeVol
	move.l	(SP)+,D0
	rts

; Address/length patch for Martin Walker modules

Code6
	MOVE.L	0(A0,D2.W),0(A6,D2.W)
	MOVE.W	4(A0,D2.W),4(A6,D2.W)
Code6End
Patch6
	move.l	D0,-(A7)
	move.l	0(A0,D2.W),D0
	bsr.w	PokeAdr
	move.w	4(A0,D2.W),D0
	bsr.w	PokeLen
	move.l	(A7)+,D0
	rts

; Period patch for Martin Walker modules

Code7
	MOVE.W	#$7E,6(A6,D2.W)
Code7End
Patch7
	move.l	D0,-(A7)
	moveq	#$7E,D0
	bsr.w	PokePer
	move.l	(A7)+,D0
	rts

; Volume patch for Martin Walker module (SS)

Code8
	MOVE.W	12(A0,D2.W),8(A6,D2.W)
Code8End
Patch8
	move.l	D0,-(A7)
	move.w	12(A0,D2.W),D0
	bsr.w	PokeVol
	move.l	(SP)+,D0
	rts

; Period patch for Martin Walker modules

Code9
	SUB.W	$58(A0,D1.W),D5
	MOVE.W	D5,6(A6,D2.W)
Code9End
Patch9
	sub.w	$58(A0,D1.W),D5
	move.l	D0,-(A7)
	move.w	D5,D0
	bsr.w	PokePer
	move.l	(A7)+,D0
	rts

; Address/length patch for Martin Walker modules

CodeA
	MOVE.L	A2,0(A6,D2.W)
	MOVEA.W	4(A0,D2.W),A2
	SUBA.W	D5,A2
	MOVE.W	A2,4(A6,D2.W)
CodeAEnd
PatchA
	move.l	D0,-(A7)
	move.l	A2,D0
	bsr.w	PokeAdr
	move.w	4(A0,D2.W),A2
	sub.w	D5,A2
	move.w	A2,D0
	bsr.w	PokeLen
	move.l	(A7)+,D0
	rts

; SongEnd/Volume/DMA patch for Martin Walker modules

CodeB
	CLR.W	$DFF0A8
	CLR.W	$DFF0B8
	CLR.W	$DFF0C8
	CLR.W	$DFF0D8
	MOVE.W	#15,$DFF096
CodeBEnd
PatchB
	movem.l	D0/A1/A5,-(A7)
	bsr.w	PatchE
	moveq	#15,D0
	bsr.w	PokeDMA
	move.l	EagleBase(PC),A5
	move.l	dtg_SongEnd(A5),A1
	jsr	(A1)
	bsr.w	InitSound
	movem.l	(A7)+,D0/A1/A5
	rts

; Position Counter patch for Martin Walker modules

CodeC
	ADDQ.B	#1,D5
ChangeIt6
	MOVE.B	0(A4,D5.W),$24(A1,D0.W)
CodeCEnd
PatchC
	addq.b	#1,D5
ChangeIt7
	move.b	0(A4,D5.W),$24(A1,D0.W)
	cmp.w	#$10,D2
	bne.b	Skip
	move.w	D5,CurrentPos
Skip
	rts

; SongEnd patch for Martin Walker modules

CodeD
	ASL.W	#1,D1
	ASL.W	#2,D3
	ASL.W	#4,D2
CodeDEnd
PatchD
	asl.w	#1,D1
	asl.w	#2,D3
	asl.w	#4,D2
ChangeIt8
	cmp.b	#$FF,$24(A1,D0.W)
	bne.b	NoEnd
	movem.l	A1/A5,-(A7)
	lea	SongEnd(PC),A1
	tst.w	D2
	bne.b	test1
	clr.b	(A1)
	bra.b	test
test1
	cmp.w	#$10,D2
	bne.b	test2
	clr.b	1(A1)
	bra.b	test
test2
	cmp.w	#$20,D2
	bne.b	test3
	clr.b	2(A1)
	bra.b	test
test3
	cmp.w	#$30,D2
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
	movem.l	(A7)+,A1/A5
NoEnd
	rts

; Volume patch for Martin Walker modules

CodeE
	CLR.W	$DFF0A8
	CLR.W	$DFF0B8
	CLR.W	$DFF0C8
	CLR.W	$DFF0D8
	MOVE.W	#$FF,$DFF09E
	BSET	#1,$BFE001
CodeEEnd
PatchE
	movem.l	D0/D2/D3,-(A7)
	moveq	#0,D0
	moveq	#3,D3
	moveq	#0,D2
ClearVoice
	bsr.w	PokeVol
	addq.l	#8,D2
	addq.l	#8,D2
	dbf	D3,ClearVoice
	movem.l	(A7)+,D0/D2/D3
	rts

; DMA patch for Martin Walker modules

CodeF
	MOVE.W	#$820F,$DFF096
CodeFEnd
PatchF
	move.l	D0,-(SP)
	move.w	#$820F,D0
	bsr.w	PokeDMA
	move.l	(SP)+,D0
	rts

; DMA patch for Martin Walker modules

CodeG
	MOVE.W	14(A0,D2.W),$DFF096
CodeGEnd
PatchG
	move.l	D0,-(SP)
	move.w	14(A0,D2.W),D0
	bsr.w	PokeDMA
	move.l	(SP)+,D0
	rts

; Period patch for Martin Walker modules

CodeH
	MOVE.W	#1,6(A6,D2.W)
CodeHEnd
PatchH
	move.l	D0,-(A7)
	moveq	#1,D0
	bsr.w	PokePer
	move.l	(A7)+,D0
	rts

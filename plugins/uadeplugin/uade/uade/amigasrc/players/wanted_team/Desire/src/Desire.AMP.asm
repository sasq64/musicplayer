	******************************************************
	****             Desire replayer for	  	  ****
	****    EaglePlayer 2.00+ (Amplifier version),    ****
	****         all adaptions by Wanted Team	  ****
	******************************************************

	incdir	"dh2:include/"
	include 'misc/eagleplayer2.01.i'
	include	'misc/eagleplayerengine.i'
	include	'exec/exec_lib.i'

	SECTION	Player_Code,CODE

	EPPHEADER Tags

	dc.b	'$VER: Desire player module V2.0 (30 Apr 2002)',0
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
	dc.l	DTP_Interrupt,Interrupt
	dc.l	EP_NewModuleInfo,NewModuleInfo
	dc.l	EP_SampleInit,SampleInit
	dc.l	EP_ModuleChange,ModuleChange
	dc.l	EP_InitAmplifier,InitAudstruct
	dc.l	EP_EagleBase,EagleBase
	dc.l	EP_Flags,EPB_ModuleInfo!EPB_SampleInfo!EPB_Songend!EPB_NextSong!EPB_PrevSong!EPB_Packable!EPB_Restart
	dc.l	0
PlayerName
	dc.b	'Desire',0
Creator
	dc.b	'(c) 1993-94 by Dentons,',10
	dc.b	'adapted by Wanted Team',0
Prefix
	dc.b	'DSR.',0
	even
ModulePtr
	dc.l	0
PlayPtr
	dc.l	0
Change
	dc.w	0
SamplesLengths
	dc.l	0
SamplesOffsets
	dc.l	0
Ruch
	dc.l	0
SongEnd
	dc.l	'WTWT'

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
	move.w	A1,D1		;DFF000/10/20/30
	sub.w	#$F000,D1
	lsr.w	#4,D1		;Number the channel from 0-3
	move.l	EagleBase(PC),A5
	jsr	ENPP_PokeVol(A5)
	movem.l	(SP)+,D1/A5
	rts

*---------------------------------------------------------------------------*
* Input		D0 = Address value
*		D1 = Number the channel
PokeAdr
	movem.l	D1/A5,-(SP)
	move.w	A1,D1		;DFF000/10/20/30
	sub.w	#$F000,D1
	lsr.w	#4,D1		;Number the channel from 0-3
	move.l	EagleBase(PC),A5
	jsr	ENPP_PokeAdr(A5)
	movem.l	(SP)+,D1/A5
	rts

*---------------------------------------------------------------------------*
* Input		D0 = Length value
*		D1 = Number the channel
PokeLen
	movem.l	D1/A5,-(SP)
	move.w	A1,D1		;DFF000/10/20/30
	sub.w	#$F000,D1
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
	move.w	A1,D1		;DFF000/10/20/30
	sub.w	#$F000,D1
	lsr.w	#4,D1		;Number the channel from 0-3
	move.l	EagleBase(PC),A5
	jsr	ENPP_PokePer(A5)
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
**************************** EP_ModuleChange ******************************
***************************************************************************

ModuleChange
	move.w	Change(PC),D0
	bne.s	NoChange
	move.l	PlayPtr(PC),EPG_ARG1(A5)
	lea	PatchTable(PC),A1
	move.l	A1,EPG_ARG3(A5)
	move.l	#2000,D1
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
***************************** DTP_Interrupt *******************************
***************************************************************************

Interrupt
	movem.l	D1-D7/A0-A6,-(A7)

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
	move.l	SamplesLengths(PC),D3
	beq.b	return
	move.l	D3,A2

	move.l	SamplesOffsets(PC),A4
	move.l	Ruch(PC),D6
hop
	jsr	ENPP_AllocSampleStruct(A5)
	move.l	D0,(A3)
	beq.b	return
	move.l	D0,A3

	moveq	#0,D1
	move.w	(A2)+,D1
	beq.b	NoSample
	add.l	D1,D1
	moveq	#0,D2
	move.w	(A4),D2
	lsl.l	D6,D2
	add.l	ModulePtr(PC),D2
	move.l	D2,A1
NextSamp
	move.l	A1,EPS_Adr(A3)			; sample address
	cmp.l	#'FORM',(A1)
	bne.b	NoFORM
	moveq	#8,D1
	cmp.l	#'NAME',40(A1)
	bne.b	NoName
	lea	46(A1),A0
	move.w	(A0)+,EPS_MaxNameLen(A3)
	move.l	A0,EPS_SampleName(A3)		; sample name
NoName
	addq.l	#4,A1
	add.l	(A1),D1
NoFORM
	move.l	D1,EPS_Length(A3)		; sample length
	move.l	#64,EPS_Volume(A3)
	move.w	#USITY_RAW,EPS_Type(A3)
	move.w	#USIB_Playable!USIB_Saveable!USIB_8BIT,EPS_Flags(A3)
NoSample
	addq.l	#2,A4
	cmp.l	D3,A4
	bne.b	hop

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
SongSize	=	20
SamplesSize	=	28
Samples		=	36
CalcSize	=	44

InfoBuffer
	dc.l	MI_SubSongs,0		;4
	dc.l	MI_LoadSize,0		;12
	dc.l	MI_Songsize,0		;20
	dc.l	MI_SamplesSize,0	;28
	dc.l	MI_Samples,0		;36
	dc.l	MI_Calcsize,0		;44
	dc.l	MI_Prefix,Prefix
	dc.l	0

***************************************************************************
******************************** EP_Check5 ********************************
***************************************************************************

Check5
	movea.l	dtg_ChkData(A5),A0
	moveq	#-1,D0

	cmp.l	#2500,dtg_ChkSize(A5)
	ble.b	Return

	move.l	A0,A2
	moveq	#3,D1
	addq.l	#8,A0
Next
	cmp.l	#$00010101,(A0)
	bne.b	Return
	lea	16(A0),A0
	dbf	D1,Next
	lea	400(A0),A1
CheckLea
	cmp.l	A0,A1
	beq.b	Return
	cmp.w	#$49FA,(A0)+
	bne.b	CheckLea
	addq.l	#2,A0
	cmp.l	#$45F900DF,(A0)+
	bne.b	Return
	cmp.l	#$F000357C,(A0)+
	bne.b	Return
	cmp.l	#$00FF009E,(A0)+
	bne.b	Return
	cmp.w	#$41FA,(A0)+
	bne.b	Return
	add.w	(A0),A0
	cmp.l	A0,A2
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
	lea	240(A0),A1
FindPlay
	cmp.w	#$49FA,(A1)+
	bne.b	FindPlay
	subq.l	#2,A1
	move.l	A1,(A4)+			; Play Ptr
	clr.w	(A4)+				; Change

FindSongs
	cmp.w	#$47FA,(A1)+
	bne.b	FindSongs
	lea	20(A1),A2
	add.w	(A1),A1
	moveq	#0,D0
	addq.l	#1,A1
CheckSongs
	move.b	(A1)+,D1
	beq.b	NoMore
	addq.l	#1,D0
	cmp.b	(A1),D1
	bne.b	CheckSongs
NoMore
	move.l	D0,SubSongs(A6)
FindFirst
	cmp.l	#$A84E75,(A2)
	beq.b	FirstOK
	addq.l	#2,A2
	bra.b	FindFirst
FirstOK
	move.w	-4(A2),Code7+2
	move.w	-4(A2),Patch7+2

Find1
	cmp.w	#$E341,(A2)+
	bne.b	Find1
Find2
	cmp.w	#$47FA,(A2)+
	bne.b	Find2
	move.l	A2,A1
	add.w	(A1),A1
	move.l	A1,(A4)+			; samples length
	move.l	A1,D3
Find3
	cmp.w	#$47FA,(A2)+
	bne.b	Find3
	move.l	A2,A3
	add.w	(A2),A2
	move.l	A2,(A4)+			; samples offsets
	move.l	A2,A0
	move.l	A1,D4
	sub.l	A2,D4
	lea	(A1,D4.L),A2
	moveq	#0,D1
NextS
	tst.w	(A1)+
	beq.b	NoSamp
	addq.l	#1,D1
NoSamp
	cmp.l	A1,A2
	bne.b	NextS
	move.l	D1,Samples(A6)
Find4
	cmp.w	#$47FA,(A3)+
	bne.b	Find4
	addq.l	#2,A3

	move.w	(A3),D6
	and.l	#$E00,D6
	bne.b	No8
	moveq	#8,D6
	bra.b	Skip8
No8
	lsr.l	#8,D6
	lsr.l	#1,D6
Skip8
	move.l	D6,(A4)				; Ruch

FindA
	cmp.w	#$4841,(A3)+
	bne.b	FindA
FindR
	cmp.w	#$4E75,-(A3)
	bne.b	FindR
	move.w	-4(A3),CodeA+2
	move.w	-4(A3),Two+2

	moveq	#0,D2
	move.w	(A0),D2
	move.l	D2,D1
	lsl.l	D6,D2
	move.l	D2,SongSize(A6)
	exg	D2,D1
	moveq	#0,D5
NextOff
	move.w	(A0)+,D0
	cmp.l	D0,D2
	bge.b	NoMax
	move.l	D0,D2
	move.w	-2(A0,D4.W),D5
NoMax
	cmp.l	A0,D3
	bne.b	NextOff

	lsl.l	D6,D2
	add.l	D5,D5
	add.l	D5,D2
	move.l	D2,CalcSize(A6)
	cmp.l	#58664,D2
	bne.b	NoPower
	move.l	ModulePtr(PC),A0
	cmp.w	#$FFE0,470(A0)
	bne.b	NoPower
	subq.w	#8,470(A0)
NoPower
	sub.l	D1,D2
	move.l	D2,SamplesSize(A6)

	bsr.w	ModuleChange

	moveq	#0,D0
	rts

***************************************************************************
***************************** DTP_InitSound *******************************
***************************************************************************

InitSound
	lea	SongEnd(PC),A0
	move.l	#'WTWT',(A0)
	moveq	#64,D0
	add.w	dtg_SndNum(A5),D0
	move.l	ModulePtr(PC),A0
	move.b	D0,(A0)
	move.b	D0,16(A0)
	move.b	D0,32(A0)
	move.b	D0,48(A0)
	rts

*---------------------- PatchTable for Desire -----------------------*

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
	dc.w	0

; Period patch for Desire modules

Code0
	LSR.W	#1,D1
	MOVE.W	D1,$A6(A1)
Code0End
Patch0
	lsr.w	#1,D1
	move.l	D0,-(SP)
	move.w	D1,D0
	bsr.w	PokePer
	move.l	(SP)+,D0
	rts

; Volume patch for Desire modules

Code1
	ANDI.W	#$FF,D1
	MOVE.W	D1,$A8(A1)
Code1End
Patch1
	and.w	#$FF,D1
	move.l	D0,-(SP)
	move.w	D1,D0
	bsr.w	PokeVol
	move.l	(SP)+,D0
	rts

; Length patch for Desire modules

Code2
	SUBI.W	#$80,D3
	MOVE.W	D3,$A4(A1)
Code2End
Patch2
	sub.w	#$80,D3
	move.l	D0,-(SP)
	move.w	D3,D0
	bsr.w	PokeLen
	move.l	(SP)+,D0
	rts

; Length patch for Desire modules

Code3
	MOVE.W	0(A3,D1.W),$A4(A1)
Code3End
Patch3
	move.l	D0,-(SP)
	move.w	0(A3,D1.W),D0
	bsr.w	PokeLen
	move.l	(SP)+,D0
	rts

; Address patch for Desire modules

Code4
	ADDI.L	#$80,D2
	MOVE.L	D2,$A0(A1)
Code4End
Patch4
	add.l	#$80,D2
	move.l	D0,-(SP)
	move.l	D2,D0
	bsr.w	PokeAdr
	move.l	(SP)+,D0
	rts

; Address patch for Desire modules

Code5
	ADD.L	A3,D2
	MOVE.L	D2,$A0(A1)
Code5End
Patch5
	add.l	A3,D2
	move.l	D0,-(SP)
	move.l	D2,D0
	bsr.w	PokeAdr
	move.l	(SP)+,D0
	rts

; SongEnd (stop) patch for Desire modules

Code6
	CLR.W	$A8(A1)
	MOVE.B	#$80,0(A0)
Code6End
Patch6
	move.b	#$80,(A0)
SongEndTest
	movem.l	D0/A0/A5,-(A7)
	moveq	#0,D0
	bsr.w	PokeVol
	lea	SongEnd(PC),A0
	cmp.l	#$DFF000,A1
	bne.b	test1
	clr.b	(A0)
	bra.b	test
test1
	cmp.l	#$DFF010,A1
	bne.b	test2
	clr.b	1(A0)
	bra.b	test
test2
	cmp.l	#$DFF020,A1
	bne.b	test3
	clr.b	2(A0)
	bra.b	test
test3
	cmp.l	#$DFF030,A1
	bne.b	test
	clr.b	3(A0)
test
	tst.l	(A0)
	bne.b	SkipEnd
	move.l	#'WTWT',(A0)
	move.l	EagleBase(PC),A5
	move.l	dtg_SongEnd(A5),A0
	jsr	(A0)
SkipEnd
	movem.l	(A7)+,D0/A0/A5
	rts

; Volume patch for Desire modules

Code7
	CLR.B	'WT'(A0)
	CLR.W	$A8(A1)
Code7End
Patch7
	clr.b	'WT'(A0)
	move.l	D0,-(SP)
	moveq	#0,D0
	bsr.w	PokeVol
	move.l	(SP)+,D0
	rts

; ADKCON patch for Desire modules

Code8
	MOVE.W	#$FF,$9E(A2)
Code8End
Patch8
	rts

; DMA patch for Desire modules

Code9
	ORI.W	#$8200,D1
	MOVE.W	D1,$96(A2)
Code9End
Patch9
	or.w	#$8200,D1
	move.l	D0,-(SP)
	move.l	D1,D0
	bsr.w	PokeDMA
	move.l	(SP)+,D0
	rts

; DMA patch for Desire modules

CodeA
	move.w	'WT'(A0),$96(A2)
CodeAEnd
PatchA
	move.l	D0,-(SP)
Two
	move.w	'WT'(A0),D0
	bsr.w	PokeDMA
	move.l	(SP)+,D0
	rts

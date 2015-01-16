	*****************************************************
	****          Soundfactory replayer for		 ****
	****    EaglePlayer 2.00+ (Amplifier version),   ****
	****         all adaptions by Wanted Team	 ****
	*****************************************************

	incdir	"dh2:include/"
	include 'misc/eagleplayer2.01.i'
	include	'misc/eagleplayerengine.i'
	include	'exec/exec_lib.i'

	SECTION	Player_Code,CODE

	EPPHEADER Tags

	dc.b	'$VER: Soundfactory 1.0 player module V2.0 (12 Aug 2001)',0
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
	dc.l	EP_InitAmplifier,InitAudstruct
	dc.l	EP_EagleBase,EagleBase
	dc.l	EP_Flags,EPB_Save!EPB_SampleInfo!EPB_ModuleInfo!EPB_Songend!EPB_Packable!EPB_Restart!EPB_PrevSong!EPB_NextSong
	dc.l	0

PlayerName
	dc.b	'Soundfactory',0
Creator
	dc.b	'(c) 1989 by Zuheir Urwani & Thomas',10
	dc.b	'Kolbe, adapted by Wanted Team',0
Prefix	dc.b	'PSF.',0
	even

ModulePtr
	dc.l	0
Songend
	dc.l	0
SongendTemp
	dc.l	0
SamplesPtr
	ds.b	32*4

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
	move.w	D4,D1		;00/10/20/30
	lsr.w	#4,D1		;Number the channel from 0-3
	move.l	EagleBase(PC),A5
	jsr	ENPP_PokeVol(A5)
	movem.l	(SP)+,D1/A5
	rts

*---------------------------------------------------------------------------*
* Input		D0 = Address value
PokeAdr
	movem.l	D1/A5,-(SP)
	move.w	D4,D1		;00/10/20/30
	lsr.w	#4,D1		;Number the channel from 0-3
	move.l	EagleBase(PC),A5
	jsr	ENPP_PokeAdr(A5)
	movem.l	(SP)+,D1/A5
	rts

*---------------------------------------------------------------------------*
* Input		D0 = Length value
PokeLen
	movem.l	D1/A5,-(SP)
	move.w	D4,D1		;00/10/20/30
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
	move.w	D4,D1		;00/10/20/30
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

LED_Off
	movem.l	D0/D1/A5,-(SP)
	moveq	#1,D0
	moveq	#0,D1
	move.l	EagleBase(PC),A5
	jsr	ENPP_PokeCommand(A5)
	movem.l	(SP)+,D0/D1/A5
	rts

LED_On
	movem.l	D0/D1/A5,-(SP)
	moveq	#1,D0
	moveq	#1,D1
	move.l	EagleBase(PC),A5
	jsr	ENPP_PokeCommand(A5)
	movem.l	(SP)+,D0/D1/A5
	rts

***************************************************************************
******************************* EP_SampleInit *****************************
***************************************************************************

SampleInit
	moveq	#EPR_NotEnoughMem,D7
	lea	EPG_SampleInfoStructure(A5),A3
	move.l	ModulePtr(PC),D0
	beq.b	ExitS

	moveq	#31,D5
	lea	SamplesPtr(PC),A2
hop
	jsr	ENPP_AllocSampleStruct(A5)
	move.l	D0,(A3)
	beq.b	ExitS
	move.l	D0,A3

	move.l	(A2)+,D0
	beq.b	NoS
	move.l	D0,A1
	moveq	#0,D0
	move.w	4(A1),D0
	add.l	D0,D0
	lea	38(A1),A1

	move.l	A1,EPS_Adr(A3)			; sample address
	move.l	D0,EPS_Length(A3)		; sample length
	move.l	#64,EPS_Volume(A3)
	move.w	#USITY_RAW,EPS_Type(A3)
	move.w	#USIB_Playable!USIB_Saveable!USIB_8BIT,EPS_Flags(A3)
NoS
	dbf	D5,hop

	moveq	#0,D7
ExitS
	move.l	D7,D0
	rts

***************************************************************************
******************************** EP_Check5 ********************************
***************************************************************************

Check5
	movea.l	dtg_ChkData(A5),A0
	moveq	#-1,D0

	moveq	#32,D1
	swap	D1
	move.l	(A0)+,D2
	cmp.l	D1,D2
	bhi.b	Fault
	moveq	#15,D2
	moveq	#15,D3
	moveq	#0,D4
NextByte
	move.b	(A0)+,D4
	cmp.l	D2,D4
	bhi.b	Fault
	dbf	D3,NextByte

	moveq	#63,D3
	move.l	(A0),D2
NextLong
	move.l	(A0)+,D4
	cmp.l	D1,D4
	bhi.b	Fault
	cmp.l	D4,D2
	ble.b	Lower
	move.l	D4,D2
Lower
	dbf	D3,NextLong

	cmp.l	#$00000114,D2
	bne.b	Fault

	moveq	#0,D0
Fault
	rts

***************************************************************************
***************************** DTP_SubSongRange ****************************
***************************************************************************

SubSongRange
	moveq	#1,D0
	move.l	InfoBuffer+SubSongs(PC),D1
	rts

***************************************************************************
***************************** EP_NewModuleInfo ****************************
***************************************************************************

NewModuleInfo	

SubSongs	=	4
LoadSize	=	12
CalcSize	=	20
Voices		=	28
SongSize	=	36
SamplesSize	=	44
Samples		=	52

InfoBuffer
	dc.l	MI_SubSongs,0		;4
	dc.l	MI_LoadSize,0		;12
	dc.l	MI_Calcsize,0		;20
	dc.l	MI_Voices,0		;28
	dc.l	MI_Songsize,0		;36
	dc.l	MI_SamplesSize,0	;44
	dc.l	MI_Samples,0		;52
	dc.l	MI_MaxSamples,32
	dc.l	MI_MaxVoices,4
	dc.l	MI_MaxSubSongs,16
	dc.l	MI_Prefix,Prefix
	dc.l	0

***************************************************************************
***************************** DTP_InitPlayer ******************************
***************************************************************************

InitPlayer
	moveq	#0,D0
	movea.l	dtg_GetListData(A5),A0
	jsr	(A0)

	lea	ModulePtr(PC),A4
	move.l	A0,(A4)			; module buffer

	lea	InfoBuffer(PC),A2
	move.l	D0,LoadSize(A2)

	cmp.l	(A0),D0
	bge.b	SizeOK
	moveq	#EPR_ModuleTooShort,D0
	rts
SizeOK
	move.l	(A0),D2
	move.l	D2,CalcSize(A2)

	lea	20(A0),A1
	moveq	#16,D1
FindLast
	tst.b	-(A1)
	bne.b	LastFound
	subq.l	#1,D1
	bra.b	FindLast
LastFound
	move.l	D1,SubSongs(A2)
	moveq	#31,D1
	lea	SamplesPtr(PC),A1
	move.l	A1,A3
ClearPtr
	clr.l	(A1)+
	dbf	D1,ClearPtr

	lea	276(A0),A1
	add.l	D2,A0
	subq.l	#8,A0
	moveq	#0,D0
	moveq	#0,D1
	moveq	#0,D3
	moveq	#38,D5

CheckNext
	cmp.b	#$84,(A1)
	bne.b	NoSamp
	cmp.b	#31,1(A1)
	bhi.b	NoSamp
	move.b	1(A1),D1
	lsl.l	#2,D1
	lea	(A3,D1.L),A4
	move.l	A1,(A4)
	moveq	#0,D4
	move.w	2(A1),D4
	add.l	D4,D4
	add.l	D4,D3
	sub.l	D5,D3
	add.l	D4,A1
	addq.l	#1,D0
	bra.b	TestAdr
NoSamp
	addq.l	#2,A1
TestAdr
	cmp.l	A1,A0
	bgt.b	CheckNext

	move.l	D0,Samples(A2)
	move.l	D3,SamplesSize(A2)
	sub.l	D3,D2
	move.l	D2,SongSize(A2)

	moveq	#0,D0
	rts

***************************************************************************
***************************** DTP_InitSound *******************************
***************************************************************************

InitSound
	lea	run(PC),A0
	lea	648(A0),A1
ClearVar
	clr.w	(A0)+
	cmp.l	A0,A1
	bne.b	ClearVar

	lea	Songend(PC),A6
	move.l	#'WTWT',(A6)

	move.l	ModulePtr(PC),A0
	move.w	dtg_SndNum(A5),D0
	move.b	3(A0,D0.W),D1
	moveq	#4,D2
	btst	#3,D1
	bne.b	VoiceOK
	subq.l	#1,D2
	clr.b	3(A6)
	btst	#2,D1
	bne.b	VoiceOK
	subq.l	#1,D2
	clr.b	2(A6)
	btst	#1,D1
	bne.b	VoiceOK
	subq.l	#1,D2
	clr.b	1(A6)
	btst	#0,D1
	bne.b	VoiceOK
	subq.l	#1,D2
	clr.b	(A6)
VoiceOK
	move.l	(A6)+,(A6)
	lea	InfoBuffer(PC),A2
	move.l	D2,Voices(A2)
	bra.w	InitSong

***************************************************************************
***************************** DTP_EndSound ********************************
***************************************************************************

EndSound
	bra.w	End

***************************************************************************
***************************** DTP_Interrupt *******************************
***************************************************************************

Interrupt
	movem.l	D1-A6,-(A7)

	move.l	InfoBuffer+Voices(PC),D0
	bne.b	NoEnd
	move.l	EagleBase(PC),A5
	move.l	dtg_SongEnd(A5),A0
	jsr	(A0)
NoEnd
	bsr.w	Play

	move.l	EagleBase(PC),A5
	jsr	ENPP_Amplifier(A5)

	movem.l	(A7)+,D1-A6
	moveq	#0,D0
	rts

SongEnd
	movem.l	A1/A5,-(A7)
	move.l	EagleBase(PC),A5
	move.l	dtg_SongEnd(A5),A1
	jsr	(A1)
	movem.l	(A7)+,A1/A5
	rts

SongEndTest
	movem.l	A1/A5,-(A7)
	lea	Songend(PC),A1
	tst.w	D5
	bne.b	test1
	clr.b	(A1)
	bra.b	test
test1
	cmp.w	#4,D5
	bne.b	test2
	clr.b	1(A1)
	bra.b	test
test2
	cmp.w	#8,D5
	bne.b	test3
	clr.b	2(A1)
	bra.b	test
test3
	cmp.w	#12,D5
	bne.b	test
	clr.b	3(A1)
test
	tst.l	(A1)
	bne.b	SkipEnd
	move.l	SongendTemp(PC),(A1)
	move.l	EagleBase(PC),A5
	move.l	dtg_SongEnd(A5),A1
	jsr	(A1)
SkipEnd
	movem.l	(A7)+,A1/A5
	rts

***************************************************************************
**************************** Soundfactory player **************************
***************************************************************************

; Player from Soundfactory editor

;	JMP	lbC00031A(PC)

;	JMP	lbC0003DA(PC)

;	JMP	lbC00042A(PC)

;	JMP	lbC000728(PC)

;	JMP	lbC0002D0(PC)

;	JMP	lbC0002E0(PC)

;	JMP	lbC0002EE(PC)

;	JMP	lbC0002FE(PC)

run
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
lbW000066	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
lbW0000E8	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
lbW000168	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
lbW0002A8	dc.w	$8400
	dc.w	$FFFF
	dc.w	1
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	$100
	dc.w	$401E
	dc.w	0
	dc.w	0
	dc.w	$100
	dc.w	$132
	dc.w	$200
	dc.w	0
	dc.w	0
	dc.w	$649C

;lbC0002D0	MOVE.L	A6,-(SP)
;	LEA	lbW000066(PC),A6
;	CLR.L	D0
;	MOVE.B	-$46(A6),D0
;	MOVEA.L	(SP)+,A6
;	RTS

;lbC0002E0	MOVE.L	A6,-(SP)
;	LEA	lbW000066(PC),A6
;	MOVE.B	D0,-$46(A6)
;	MOVEA.L	(SP)+,A6
;	RTS

;lbC0002EE	MOVE.L	A6,-(SP)
;	LEA	lbW000066(PC),A6
;	CLR.L	D0
;	MOVE.B	-$45(A6),D0
;	MOVEA.L	(SP)+,A6
;	RTS

;lbC0002FE	MOVE.L	A6,-(SP)
;	LEA	lbW000066(PC),A6
;	MOVE.B	D0,$7C(A6)
;	ANDI.W	#15,D0
;	EORI.B	#15,D0
;	MOVE.W	D0,$DFF096
;	MOVEA.L	(SP)+,A6
;	RTS

InitSong
lbC00031A	LEA	lbW000066(PC),A6
;	LEA	$DFF080,A5
	SUBQ.W	#1,D0
	ANDI.W	#15,D0
	MOVE.B	4(A0,D0.W),-$45(A6)
	MOVE.B	4(A0,D0.W),$7C(A6)
	MOVE.W	D0,D1
	LSL.W	#4,D1
	MOVE.L	A0,D0
	MOVEA.L	$20(A0,D1.W),A3
	MOVEA.L	$1C(A0,D1.W),A2
	MOVEA.L	$18(A0,D1.W),A1
	MOVEA.L	$14(A0,D1.W),A0
	ADDA.L	D0,A0
	ADDA.L	D0,A1
	ADDA.L	D0,A2
	ADDA.L	D0,A3
	MOVE.L	A0,-$44(A6)
	MOVE.L	A1,-$40(A6)
	MOVE.L	A2,-$3C(A6)
	MOVE.L	A3,-$38(A6)
	MOVE.L	A0,-$34(A6)
	MOVE.L	A1,-$30(A6)
	MOVE.L	A2,-$2C(A6)
	MOVE.L	A3,-$28(A6)
	MOVEQ	#1,D0
	MOVE.W	D0,-$24(A6)
	MOVE.W	D0,-$22(A6)
	MOVE.W	D0,-$20(A6)
	MOVE.W	D0,-$1E(A6)
	CLR.L	-$14(A6)
	CLR.L	-4(A6)
	CLR.L	-$1C(A6)
	CLR.L	$7E(A6)
	CLR.B	$58(A6)
	CLR.B	$5C(A6)
	CLR.B	$5A(A6)
	CLR.B	$59(A6)
	CLR.B	-$46(A6)
	CLR.L	$6E(A6)
	CLR.L	-$18(A6)
	LEA	lbW0002A8(PC),A0
	LEA	lbW0000E8(PC),A1
	MOVEQ	#$20,D0
lbC0003BC	MOVE.L	A0,(A1)+
	SUBQ.B	#1,D0
	BNE.S	lbC0003BC
;	MOVE.W	#$FF,$1E(A5)
;	MOVE.W	#15,$16(A5)
;	BCLR	#1,$BFE001
	CLR.W	$72(A6)

	rts
Play
lbC0003DA	LEA	lbW000066(PC),A6
;	LEA	$DFF080,A5
	TST.B	$5C(A6)
	BNE.S	lbC0003F0
	TST.B	$58(A6)
	BEQ.S	lbC00045E
lbC0003F0	MOVE.B	$59(A6),D0
	ADD.B	$5B(A6),D0
	MOVE.B	D0,D1
	ANDI.B	#3,D0
	MOVE.B	D0,$59(A6)
	LSR.B	#2,D1
	MOVE.B	$5A(A6),D0
	TST.B	$5C(A6)
	BEQ.S	lbC00041C
	ADD.B	D1,D0
	BCC.S	lbC00045A
	CLR.B	$5C(A6)
	CLR.B	$5A(A6)
	BRA.S	lbC00045E

lbC00041C	TST.B	D0
	BNE.S	lbC000424
	SUB.B	D1,D0
	BRA.S	lbC00045A

lbC000424	SUB.B	D1,D0
	BEQ.S	lbC00042A
	BCC.S	lbC00045A
End
lbC00042A	LEA	lbW000066(PC),A6
;	LEA	$DFF080,A5
	CLR.L	D0
	MOVE.B	D0,-$45(A6)
	MOVE.B	D0,$58(A6)
	MOVE.B	D0,$5C(A6)
;	MOVE.W	#15,$16(A5)
;	MOVE.W	D0,$28(A5)
;	MOVE.W	D0,$38(A5)
;	MOVE.W	D0,$48(A5)
;	MOVE.W	D0,$58(A5)
	RTS

lbC00045A	MOVE.B	D0,$5A(A6)
lbC00045E	MOVEQ	#3,D7
	MOVEQ	#6,D6
	MOVEQ	#12,D5
	MOVEQ	#$30,D4
	CLR.W	$72(A6)
lbC00046A	BTST	D7,-$45(A6)
	BEQ.S	lbC000474
	BSR.L	lbC000502
lbC000474	SUBI.B	#$10,D4
	SUBQ.B	#4,D5
	SUBQ.B	#2,D6
	SUBQ.B	#1,D7
	BPL.S	lbC00046A
	MOVE.W	#$8000,D1
	MOVE.B	$72(A6),D1
	AND.B	$7C(A6),D1
	BEQ.S	lbC000498
;	LEA	$DFF080,A5
;	MOVE.W	D1,$16(A5)

	move.w	D1,D0
	bsr.w	PokeDMA

lbC000498	RTS

;lbL00049A	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.b	'Profiteam-Soundfactory V1.0 !!',0,0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0

lbC000502
;	BTST	D7,$7C(A6)
;	BEQ.S	lbC000510
;	LEA	$DFF080,A5
;	BRA.S	lbC000514

;lbC000510	LEA	lbL00049A(PC),A5
lbC000514	BSR.L	lbC0005DC
	MOVE.B	8(A4),D3
	SUBQ.W	#1,-$24(A6,D6.W)
	BEQ.S	lbC000558
	CMPI.W	#1,-$24(A6,D6.W)
	BNE.L	lbC000A84
	CMPI.W	#$1AD,$74(A6,D6.W)
	BCS.L	lbC000A84
	MOVEA.L	-$34(A6,D5.W),A0
	CMPI.B	#$80,(A0)
	BEQ.L	lbC000A84
	BHI.S	lbC00054C
	TST.B	1(A0)
	BMI.L	lbC000A84
lbC00054C	CLR.W	D0
	BSET	D7,D0
;	MOVE.W	D0,$16(A5)

	bsr.w	PokeDMA

	BRA.L	lbC000A84

lbC000558	BSR.L	lbC0005BC
	TST.B	D0
	BPL.L	lbC000938
	LEA	lbW000582(PC),A1
	ANDI.B	#$7F,D0
	MOVE.B	D0,-(SP)
	LSL.B	#1,D0
	MOVE.W	0(A1,D0.W),D0
	JSR	0(A1,D0.W)
	MOVE.B	(SP)+,D0
	TST.B	D0
	BNE.S	lbC000558
	RTS

lbC00057E	MOVE.W	(SP)+,D0
	BRA.S	lbC000558

lbW000582	dc.w	lbC000654-lbW000582
	dc.w	lbC000674-lbW000582
	dc.w	lbC0006A4-lbW000582
	dc.w	lbC0006AE-lbW000582
	dc.w	lbC0006E8-lbW000582
	dc.w	lbC000778-lbW000582
	dc.w	lbC000756-lbW000582
	dc.w	lbC000740-lbW000582
	dc.w	lbC000782-lbW000582
	dc.w	lbC000794-lbW000582
	dc.w	lbC000724-lbW000582
	dc.w	lbC0006BC-lbW000582
	dc.w	lbC0006C6-lbW000582
	dc.w	lbC0006BE-lbW000582
	dc.w	lbC00070A-lbW000582
	dc.w	lbC0008E4-lbW000582
	dc.w	lbC0007B2-lbW000582
	dc.w	lbC0007EC-lbW000582
	dc.w	lbC0007F4-lbW000582
	dc.w	lbC0007FC-lbW000582
	dc.w	lbC0008C4-lbW000582
	dc.w	lbC000834-lbW000582
	dc.w	lbC00089C-lbW000582
	dc.w	lbC00086C-lbW000582
	dc.w	lbC000908-lbW000582
	dc.w	lbC00065E-lbW000582
	dc.w	lbC000688-lbW000582
	dc.w	lbC0006CC-lbW000582
	dc.w	lbC00067E-lbW000582

lbC0005BC	CLR.L	D0
	MOVEA.L	-$34(A6,D5.W),A0
	MOVE.B	(A0),D0
	ADDQ.L	#1,-$34(A6,D5.W)
	RTS

lbC0005CA	CLR.L	D1
	BSR.L	lbC0005BC
	MOVE.B	D0,D1
	LSL.W	#8,D1
	BSR.L	lbC0005BC
	OR.W	D1,D0
	RTS

lbC0005DC	CLR.L	D1
	LEA	lbW0000E8(PC),A4
	MOVE.B	-$1C(A6,D7.W),D1
	LSL.B	#2,D1
	MOVEA.L	0(A4,D1.W),A4
	RTS

lbC0005EE	LEA	lbW000168(PC),A0
	MOVE.L	D2,-(SP)
	MOVE.L	D7,D2
	LSL.W	#4,D2
	MOVE.W	D2,D1
	LSL.W	#2,D2
	ADD.W	D1,D2
	ADDA.L	D2,A0
	MOVE.L	(SP)+,D2
	RTS

lbC000604	BSR.L	lbC0005EE
	CLR.W	D1
	MOVE.B	-4(A6,D7.W),D1
	MOVE.B	D0,0(A0,D1.W)
	ADDQ.B	#2,-4(A6,D7.W)
	RTS

lbC000618	BSR.L	lbC0005EE
	CLR.W	D1
	MOVE.B	-4(A6,D7.W),D1
	MOVE.L	D0,0(A0,D1.W)
	ADDQ.B	#4,-4(A6,D7.W)
	RTS

lbC00062C	BSR.L	lbC0005EE
	SUBQ.B	#2,-4(A6,D7.W)
	CLR.W	D1
	MOVE.B	-4(A6,D7.W),D1
	MOVE.B	0(A0,D1.W),D0
	RTS

lbC000640	BSR.L	lbC0005EE
	SUBQ.B	#4,-4(A6,D7.W)
	CLR.W	D1
	MOVE.B	-4(A6,D7.W),D1
	MOVE.L	0(A0,D1.W),D0
	RTS

lbC000654	BSR.L	lbC0005CA
	MOVE.W	D0,-$24(A6,D6.W)
	RTS

lbC00065E	BSR.L	lbC0005CA
	MOVE.W	D0,-$24(A6,D6.W)
	CLR.W	D2
	BSET	D7,D2
;	MOVE.W	D2,$16(A5)

	move.l	D0,-(SP)
	move.w	D2,D0
	bsr.w	PokeDMA
	move.l	(SP)+,D0

	CLR.B	4(SP)
	RTS

lbC000674	BSR.L	lbC0005BC
	MOVE.B	D0,-$18(A6,D7.W)
	RTS

lbC00067E	BSR.L	lbC0005BC
	MOVE.B	D0,$7E(A6,D7.W)
	RTS

lbC000688	BSR.L	lbC0005BC
	TST.B	D0
	BEQ.S	lbC00069A
;	BCLR	#1,$BFE001

	bsr.w	LED_On

	RTS

lbC00069A
;	BSET	#1,$BFE001

	bsr.w	LED_Off

	RTS

lbC0006A4	BSR.L	lbC0005BC
	MOVE.B	D0,-$14(A6,D7.W)
	RTS

lbC0006AE	BSR.L	lbC0005BC
	MOVE.B	D0,-$1C(A6,D7.W)
	BSR.L	lbC0005DC
	RTS

lbC0006BC	RTS

lbC0006BE	MOVE.L	-$44(A6,D5.W),-$34(A6,D5.W)

	bsr.w	SongEndTest

	RTS

lbC0006C6	ADDQ.B	#1,-$46(A6)
	RTS

lbC0006CC	BSR.L	lbC0005BC
	CMP.B	-$46(A6),D0
	BNE.S	lbC0006D8
	RTS

lbC0006D8	SUBQ.L	#2,-$34(A6,D5.W)
	MOVE.W	#1,-$24(A6,D6.W)
	CLR.B	4(SP)
	RTS

lbC0006E8	BSR.L	lbC0005BC
	ASL.B	#2,D0
	MOVE.L	-$34(A6,D5.W),D2
	SUBQ.L	#2,D2
	LEA	lbW0000E8(PC),A0
	MOVE.L	D2,0(A0,D0.W)
	BSR.L	lbC0005CA
	LSL.L	#1,D0
	ADD.L	D0,D2
	MOVE.L	D2,-$34(A6,D5.W)
	RTS

lbC00070A	CLR.L	D0
	BSET	D7,D0
;	MOVE.W	D0,$16(A5)

	bsr.w	PokeDMA

;	CLR.W	$28(A5,D4.W)

	move.l	D0,-(SP)
	moveq	#0,D0
	bsr.w	PokeVol
	move.l	(SP)+,D0

	MOVEQ	#15,D1
	EOR.B	D1,D0
	AND.B	D0,-$45(A6)
	CLR.B	4(SP)

	bsr.w	SongEnd

	RTS

lbC000724	BSR.L	lbC0005BC
lbC000728	LEA	lbW000066(PC),A6
	MOVE.B	D0,$5B(A6)
	CLR.B	$5C(A6)
	CLR.B	$59(A6)
	MOVE.B	#1,$58(A6)
	RTS

lbC000740	BSR.L	lbC0005CA
	SWAP	D0
	MOVE.L	D0,-(SP)
	BSR.L	lbC0005CA
	OR.L	(SP),D0
	ADD.L	D0,-$34(A6,D5.W)
	MOVE.L	(SP)+,D0

	bsr.w	SongEndTest

	RTS

lbC000756	BSR.L	lbC0005CA
	SWAP	D0
	MOVE.L	D0,-(SP)
	BSR.L	lbC0005CA
	OR.L	(SP),D0
	MOVE.L	(SP)+,D2
	MOVE.L	D0,D2
	MOVE.L	-$34(A6,D5.W),D0
	ADD.L	D0,D2
	BSR.L	lbC000618
	MOVE.L	D2,-$34(A6,D5.W)
	RTS

lbC000778	BSR.L	lbC000640
	MOVE.L	D0,-$34(A6,D5.W)
	RTS

lbC000782	BSR.L	lbC0005BC
	BSR.L	lbC000604
	MOVE.L	-$34(A6,D5.W),D0
	BSR.L	lbC000618
	RTS

lbC000794	BSR.L	lbC000640
	MOVEA.L	D0,A3
	BSR.L	lbC00062C
	SUBQ.B	#1,D0
	BEQ.S	lbC0007B0
	MOVE.L	A3,-$34(A6,D5.W)
	BSR.L	lbC000604
	MOVE.L	A3,D0
	BSR.L	lbC000618
lbC0007B0	RTS

lbC0007B2	BSR.L	lbC0005BC
	MOVE.B	D0,$14(A4)
	BSR.L	lbC0005BC
	MOVE.B	D0,$15(A4)
	BSR.L	lbC0005BC
	MOVE.B	D0,$16(A4)
	BSR.L	lbC0005BC
	TST.B	D0
	BEQ.S	lbC0007DA
	ANDI.B	#$DF,8(A4)
	BRA.S	lbC0007E2

lbC0007DA	ORI.B	#$20,8(A4)
	RTS

lbC0007E2	BSR.L	lbC0005BC
	MOVE.B	D0,$17(A4)
	RTS

lbC0007EC	ORI.B	#1,8(A4)
	RTS

lbC0007F4	ANDI.B	#$FE,8(A4)
	RTS

lbC0007FC	BSR.L	lbC0005BC
	TST.B	D0
	BNE.S	lbC00080C
	ANDI.B	#$FD,8(A4)
	RTS

lbC00080C	ORI.B	#2,8(A4)
	BSR.L	lbC0005BC
	MOVE.B	D0,$10(A4)
	BSR.L	lbC0005BC
	MOVE.B	D0,$11(A4)
	BSR.L	lbC0005BC
	MOVE.B	D0,$12(A4)
	BSR.L	lbC0005BC
	MOVE.B	D0,$13(A4)
	RTS

lbC000834	BSR.L	lbC0005BC
	TST.B	D0
	BNE.S	lbC000844
	ANDI.B	#$F7,8(A4)
	RTS

lbC000844	ORI.B	#8,8(A4)
	BSR.L	lbC0005BC
	MOVE.B	D0,$18(A4)
	BSR.L	lbC0005BC
	MOVE.B	D0,$19(A4)
	BSR.L	lbC0005BC
	MOVE.B	D0,$1A(A4)
	BSR.L	lbC0005BC
	MOVE.B	D0,$1B(A4)
	RTS

lbC00086C	BSR.L	lbC0005BC
	TST.B	D0
	BNE.S	lbC00087C
	ANDI.B	#$BF,8(A4)
	RTS

lbC00087C	ORI.B	#$40,8(A4)
	BSR.L	lbC0005BC
	MOVE.B	D0,9(A4)
	BSR.L	lbC0005BC
	MOVE.B	D0,10(A4)
	BSR.L	lbC0005BC
	MOVE.B	D0,11(A4)
	RTS

lbC00089C	BSR.L	lbC0005BC
	TST.B	D0
	BNE.S	lbC0008AC
	ANDI.B	#$EF,8(A4)
	RTS

lbC0008AC	ORI.B	#$10,8(A4)
	BSR.L	lbC0005BC
	MOVE.B	D0,14(A4)
	BSR.L	lbC0005CA
	MOVE.W	D0,12(A4)
	RTS

lbC0008C4	BSR.L	lbC0005BC
	TST.B	D0
	BNE.S	lbC0008D4
	ANDI.B	#$FB,8(A4)
	RTS

lbC0008D4	ORI.B	#4,8(A4)
	BSR.L	lbC0005BC
	MOVE.B	D0,15(A4)
	RTS

lbC0008E4	BSR.L	lbC0005BC
	MOVE.B	D0,$5B(A6)
	MOVE.B	#1,$5C(A6)
	TST.B	$5A(A6)
	BNE.S	lbC0008FE
	MOVE.B	#1,$5A(A6)
lbC0008FE	CLR.B	$59(A6)
	CLR.B	$58(A6)
	RTS

lbC000908	BSR.L	lbC0005BC
	TST.B	D0
	BNE.S	lbC000918
	BCLR	#7,8(A4)
	RTS

lbC000918	BSET	#7,8(A4)
	BSR.L	lbC0005BC
	MOVE.B	D0,$1E(A4)
	BSR.L	lbC0005BC
	MOVE.B	D0,$1F(A4)
	BSR.L	lbC0005BC
	MOVE.B	D0,$20(A4)
	RTS

lbC000938	ADD.B	$7E(A6,D7.W),D0
	ANDI.B	#$7F,D0
	CLR.W	D2
	BSET	D7,D2
;	MOVE.W	D2,$16(A5)

	move.l	D0,-(SP)
	move.w	D2,D0
	bsr.w	PokeDMA
	move.l	(SP)+,D0

	MOVE.B	D0,-8(A6,D7.W)
	MOVE.B	8(A4),D3
	BTST	#4,D3
	BEQ.S	lbC000962
	MOVE.W	-$10(A6,D6.W),12(A6,D6.W)
	MOVE.B	#1,$14(A6,D7.W)
lbC000962	BSR.L	lbC000E2E
	MOVE.W	D0,-$10(A6,D6.W)
	BSR.L	lbC0005CA
	MOVE.W	D0,-(SP)
	ANDI.W	#$7FFF,D0
	BEQ.L	lbC00057E
	MOVE.W	D0,-$24(A6,D6.W)
	LSR.W	#1,D0
	MOVE.W	D0,$40(A6,D6.W)
	MOVE.B	#1,$6A(A6,D7.W)
	BTST	#2,D3
	BEQ.S	lbC000998
	CLR.B	$1C(A6,D7.W)
	MOVE.B	15(A4),$18(A6,D7.W)
lbC000998	BTST	#1,D3
	BEQ.S	lbC0009BC
	MOVE.B	$10(A4),$20(A6,D7.W)
	BNE.S	lbC0009BC
	MOVE.B	$12(A4),$30(A6,D7.W)
	CLR.W	$28(A6,D6.W)
	MOVE.B	$11(A4),$24(A6,D7.W)
	MOVE.B	$13(A4),$34(A6,D7.W)
lbC0009BC	BTST	#6,D3
	BEQ.S	lbC0009D6
	MOVE.B	#1,0(A6,D7.W)
	MOVE.B	10(A4),D0
	NEG.B	D0
	MOVE.B	D0,4(A6,D7.W)
	CLR.B	8(A6,D7.W)
lbC0009D6	MOVE.W	(SP)+,D0
	BMI.S	lbC000A18
	CLR.B	$3C(A6,D7.W)
	TST.B	$14(A4)
	BNE.S	lbC000A0E
	TST.B	$15(A4)
	BNE.S	lbC0009F8
lbC0009EA	MOVE.B	#2,$38(A6,D7.W)
	MOVE.B	$16(A4),$48(A6,D7.W)
	BRA.S	lbC000A18

lbC0009F8	CMPI.B	#$40,$16(A4)
	BEQ.S	lbC0009EA
	MOVE.B	#$40,$48(A6,D7.W)
	MOVE.B	#1,$38(A6,D7.W)
	BRA.S	lbC000A18

lbC000A0E	CLR.B	D0
	MOVE.B	D0,$48(A6,D7.W)
	MOVE.B	D0,$38(A6,D7.W)
lbC000A18	BTST	#3,D3
	BNE.S	lbC000A2C
	MOVE.L	A4,D0
	ADDI.L	#$26,D0
;	MOVE.L	D0,$20(A5,D4.W)

	bsr.w	PokeAdr

	BRA.S	lbC000A46

lbC000A2C	MOVE.B	$1A(A4),$4C(A6,D7.W)
	MOVE.B	$1B(A4),$50(A6,D7.W)
	MOVE.B	$18(A4),$54(A6,D7.W)
	BSR.L	lbC000DD2
;	MOVE.L	A1,$20(A5,D4.W)

	move.l	D0,-(SP)
	move.l	A1,D0
	bsr.w	PokeAdr
	move.l	(SP)+,D0

lbC000A46	BTST	#7,D3
	BEQ.S	lbC000A66
	MOVE.B	$20(A4),$5E(A6,D7.W)
	MOVE.B	$1E(A4),$62(A6,D7.W)
	MOVE.B	#1,$66(A6,D7.W)
	BSR.L	lbC000EEC
;	MOVE.L	A1,$20(A5,D4.W)

	move.l	D0,-(SP)
	move.l	A1,D0
	bsr.w	PokeAdr
	move.l	(SP)+,D0

lbC000A66	TST.L	$22(A4)
	BEQ.S	lbC000A74
;	MOVE.W	$24(A4),$24(A5,D4.W)

	move.l	D0,-(SP)
	move.w	$24(A4),D0
	bsr.w	PokeLen
	move.l	(SP)+,D0

	BRA.S	lbC000A7A

lbC000A74
;	MOVE.W	4(A4),$24(A5,D4.W)

	move.l	D0,-(SP)
	move.w	4(A4),D0
	bsr.w	PokeLen
	move.l	(SP)+,D0

lbC000A7A	BSR.L	lbC000D5A
	BSET	D7,$72(A6)
	RTS

lbC000A84	MOVE.B	8(A4),D3
	TST.B	$6E(A6,D7.W)
	BEQ.S	lbC000AD4
	CMPI.B	#2,$6E(A6,D7.W)
	BEQ.S	lbC000AA2
	TST.L	$22(A4)
	BNE.S	lbC000AB2
	BTST	#0,D3
	BEQ.S	lbC000AD4
lbC000AA2
;	MOVE.W	#1,$24(A5,D4.W)
;	LEA	lbW000E2C,A0				; was PC
;	MOVE.L	A0,$20(A5,D4.W)

	move.l	D0,-(SP)
	moveq	#1,D0
	bsr.w	PokeLen
	move.l	#lbW000E2C,D0
	bsr.w	PokeAdr
	move.l	(SP)+,D0

	BRA.S	lbC000AD4

lbC000AB2	MOVE.L	A4,D0
	ADDI.L	#$26,D0
	CLR.L	D1
	MOVE.W	$22(A4),D1
	LSL.L	#1,D1
	ADD.L	D1,D0
;	MOVE.L	D0,$20(A5,D4.W)

	bsr.w	PokeAdr

	MOVE.W	$24(A4),D0
	SUB.W	$22(A4),D0
;	MOVE.W	D0,$24(A5,D4.W)

	bsr.w	PokeLen

lbC000AD4	MOVE.B	$6A(A6,D7.W),$6E(A6,D7.W)
	CLR.B	$6A(A6,D7.W)
	BTST	#6,D3
	BEQ.S	lbC000B06
	SUBQ.B	#1,0(A6,D7.W)
	BNE.S	lbC000B06
	MOVE.B	9(A4),0(A6,D7.W)
	MOVE.B	4(A6,D7.W),D0
	ADD.B	D0,8(A6,D7.W)
	MOVE.B	11(A4),D0
	CMP.B	8(A6,D7.W),D0
	BCS.S	lbC000B06
	NEG.B	4(A6,D7.W)
lbC000B06	BTST	#4,D3
	BEQ.S	lbC000B4A
	MOVE.W	-$10(A6,D6.W),D0
	CMP.W	12(A6,D6.W),D0
	BEQ.S	lbC000B4A
	SUBQ.B	#1,$14(A6,D7.W)
	BNE.S	lbC000B4A
	MOVE.B	14(A4),$14(A6,D7.W)
	MOVE.W	12(A4),D2
	CMP.W	12(A6,D6.W),D0
	BCS.S	lbC000B3C
	ADD.W	D2,12(A6,D6.W)
	CMP.W	12(A6,D6.W),D0
	BCC.S	lbC000B4A
	MOVE.W	D0,12(A6,D6.W)
	BRA.S	lbC000B4A

lbC000B3C	SUB.W	D2,12(A6,D6.W)
	CMP.W	12(A6,D6.W),D0
	BCS.S	lbC000B4A
	MOVE.W	D0,12(A6,D6.W)
lbC000B4A	BTST	#2,D3
	BEQ.S	lbC000B62
	SUBQ.B	#1,$18(A6,D7.W)
	BNE.S	lbC000B62
	MOVE.B	15(A4),$18(A6,D7.W)
	MOVEQ	#1,D0
	EOR.B	D0,$1C(A6,D7.W)
lbC000B62	BTST	#1,D3
	BEQ.S	lbC000BBA
	TST.B	$20(A6,D7.W)
	BEQ.S	lbC000B8E
	SUBQ.B	#1,$20(A6,D7.W)
	BNE.S	lbC000BBA
	MOVE.B	#1,$24(A6,D7.W)
	MOVE.W	#0,$28(A6,D6.W)
	MOVE.B	$12(A4),$30(A6,D7.W)
	MOVE.B	$13(A4),$34(A6,D7.W)
	BRA.S	lbC000BBA

lbC000B8E	SUBQ.B	#1,$24(A6,D7.W)
	BNE.S	lbC000BBA
	MOVE.B	$11(A4),$24(A6,D7.W)
	CLR.W	D0
	MOVE.B	$30(A6,D7.W),D0
	EXT.W	D0
	ADD.W	D0,$28(A6,D6.W)
	SUBQ.B	#1,$34(A6,D7.W)
	BNE.S	lbC000BBA
	MOVE.B	$13(A4),D0
	LSL.B	#1,D0
	MOVE.B	D0,$34(A6,D7.W)
	NEG.B	$30(A6,D7.W)
lbC000BBA	CMPI.B	#3,$38(A6,D7.W)
	BNE.S	lbC000BF8
	TST.B	$48(A6,D7.W)
	BEQ.L	lbC000CD0
	MOVE.B	$16(A4),D0
	LSR.B	#1,D0
	BNE.S	lbC000BD4
	MOVEQ	#1,D0
lbC000BD4	ADD.B	D0,$3C(A6,D7.W)
	BCS.S	lbC000BE6
lbC000BDA	MOVE.B	$3C(A6,D7.W),D0
	CMP.B	$17(A4),D0
	BCS.L	lbC000CD0
lbC000BE6	MOVE.B	$17(A4),D2
	SUB.B	D2,$3C(A6,D7.W)
	SUBQ.B	#1,$48(A6,D7.W)
	BNE.S	lbC000BDA
	BRA.L	lbC000CD0

lbC000BF8	BTST	#5,D3
	BNE.S	lbC000C42
	TST.W	$40(A6,D6.W)
	BEQ.S	lbC000C08
	SUBQ.W	#1,$40(A6,D6.W)
lbC000C08	BNE.S	lbC000C42
	CMPI.B	#2,$38(A6,D7.W)
	BNE.S	lbC000C42
	MOVE.B	#3,$38(A6,D7.W)
	CLR.B	$3C(A6,D7.W)
	BTST	#0,D3
	BEQ.L	lbC000CD0
	TST.L	$22(A4)
	BEQ.L	lbC000CD0
	MOVE.W	4(A4),D0
	SUB.W	$22(A4),D0
;	MOVE.W	D0,$24(A5,D4.W)

	bsr.w	PokeLen

	MOVE.B	#2,$6A(A6,D7.W)
	BRA.L	lbC000CD0

lbC000C42	CMPI.B	#1,$38(A6,D7.W)
	BHI.L	lbC000CD0
	BNE.S	lbC000C84
	MOVE.B	#$40,D0
	SUB.B	$16(A4),D0
	ADD.B	D0,$3C(A6,D7.W)
lbC000C5A	MOVE.B	$3C(A6,D7.W),D0
	CMP.B	$15(A4),D0
	BCS.S	lbC000C72
	MOVE.B	$15(A4),D2
	SUB.B	D2,$3C(A6,D7.W)
	SUBQ.B	#1,$48(A6,D7.W)
	BNE.S	lbC000C5A
lbC000C72	MOVE.B	$16(A4),D0
	CMP.B	$48(A6,D7.W),D0
	BCS.S	lbC000CD0
lbC000C7C	MOVE.B	#2,$38(A6,D7.W)
	BRA.S	lbC000CD0

lbC000C84	MOVE.B	#$40,D1
	TST.B	$15(A4)
	BNE.S	lbC000C92
	MOVE.B	$16(A4),D1
lbC000C92	ADD.B	D1,$3C(A6,D7.W)
	BCS.S	lbC000CA2
lbC000C98	MOVE.B	$3C(A6,D7.W),D0
	CMP.B	$14(A4),D0
	BCS.S	lbC000CB2
lbC000CA2	MOVE.B	$14(A4),D2
	BEQ.S	lbC000CB2
	SUB.B	D2,$3C(A6,D7.W)
	ADDQ.B	#1,$48(A6,D7.W)
	BRA.S	lbC000C98

lbC000CB2	CMP.B	$48(A6,D7.W),D1
	BNE.S	lbC000CD0
	TST.B	$15(A4)
	BEQ.S	lbC000C7C
	CLR.B	$3C(A6,D7.W)
	CMPI.B	#$40,$16(A4)
	BEQ.S	lbC000C7C
	MOVE.B	#1,$38(A6,D7.W)
lbC000CD0	CLR.B	D1
	BTST	#3,D3
	BEQ.S	lbC000D12
	SUBQ.B	#1,$4C(A6,D7.W)
	BNE.S	lbC000D12
	MOVE.B	$1A(A4),$4C(A6,D7.W)
	CLR.L	D0
	MOVE.B	$54(A6,D7.W),D0
	MOVE.B	$50(A6,D7.W),D2
	EXT.W	D2
	ADD.W	D2,D0
	MOVE.B	D0,$54(A6,D7.W)
	TST.W	D0
	BMI.S	lbC000D0C
	CLR.W	D2
	MOVE.B	$19(A4),D2
	CMP.W	D2,D0
	BCC.S	lbC000D0C
	MOVE.B	$18(A4),D2
	CMP.W	D2,D0
	BHI.S	lbC000D10
lbC000D0C	NEG.B	$50(A6,D7.W)
lbC000D10	MOVEQ	#1,D1
lbC000D12	BTST	#7,D3
	BEQ.S	lbC000D42
	SUBQ.B	#1,$5E(A6,D7.W)
	BNE.S	lbC000D42
	MOVE.B	$20(A4),$5E(A6,D7.W)
	MOVE.B	$66(A6,D7.W),D0
	ADD.B	D0,$62(A6,D7.W)
	MOVE.B	$62(A6,D7.W),D0
	CMP.B	$1E(A4),D0
	BEQ.S	lbC000D3C
	CMP.B	$1F(A4),D0
	BNE.S	lbC000D40
lbC000D3C	NEG.B	$66(A6,D7.W)
lbC000D40	MOVEQ	#1,D1
lbC000D42	TST.B	D1
	BEQ.S	lbC000D5A
	BTST	#3,D3
	BEQ.S	lbC000D50
	BSR.L	lbC000DD2
lbC000D50	BTST	#7,D3
	BEQ.S	lbC000D5A
	BSR.L	lbC000EEC
lbC000D5A	CLR.W	D0
	CLR.W	D1
	MOVE.B	$48(A6,D7.W),D0
	BTST	#6,D3
	BEQ.S	lbC000D72
	MOVE.B	8(A6,D7.W),D1
	BEQ.S	lbC000D72
	MULU.W	D1,D0
	LSR.W	#8,D0
lbC000D72	MOVE.B	-$18(A6,D7.W),D1
	BEQ.S	lbC000D7C
	MULU.W	D1,D0
	LSR.W	#8,D0
lbC000D7C	TST.B	$58(A6)
	BNE.S	lbC000D88
	TST.B	$5C(A6)
	BEQ.S	lbC000D92
lbC000D88	MOVE.B	$5A(A6),D1
	BEQ.S	lbC000D92
	MULU.W	D1,D0
	LSR.W	#8,D0
lbC000D92
;	MOVE.W	D0,$28(A5,D4.W)

	bsr.w	PokeVol

	MOVE.W	-$10(A6,D6.W),D0
	BTST	#4,D3
	BEQ.S	lbC000DA4
	MOVE.W	12(A6,D6.W),D0
lbC000DA4	BTST	#1,D3
	BEQ.S	lbC000DB4
	TST.B	$20(A6,D7.W)
	BNE.S	lbC000DB4
	ADD.W	$28(A6,D6.W),D0
lbC000DB4	BTST	#2,D3
	BEQ.S	lbC000DC2
	TST.B	$1C(A6,D7.W)
	BEQ.S	lbC000DC2
	LSR.W	#1,D0
lbC000DC2	MOVE.B	-$14(A6,D7.W),D1
	ADD.W	D1,D0
;	MOVE.W	D0,$26(A5,D4.W)

	bsr.w	PokePer

	MOVE.W	D0,$74(A6,D6.W)
	RTS

lbC000DD2	MOVEM.L	D3/D4,-(SP)
	MOVE.W	4(A4),D4
	LSL.W	#1,D4
	MOVE.L	A4,D0
	ADDI.L	#$26,D0
	MOVEA.L	D0,A0
	CLR.L	D0
	MOVE.B	D7,D0
	LSL.W	#8,D0
	LEA	lbW000FCA,A1				; was PC
	ADD.L	A1,D0
	MOVEA.L	D0,A1
	CLR.W	D0
	MOVE.B	$54(A6,D7.W),D0
	MOVE.W	D4,D3
	SUB.W	D0,D3
	CLR.W	D2
lbC000E00	MOVE.B	0(A0,D3.W),D0
	MOVE.B	0(A0,D2.W),D1
	EXT.W	D0
	EXT.W	D1
	ADD.W	D1,D0
	LSR.W	#1,D0
	MOVE.B	D0,0(A1,D2.W)
	ADDQ.W	#1,D3
	CMP.W	D3,D4
	BNE.L	lbC000E1E
	CLR.W	D3
lbC000E1E	ADDQ.W	#1,D2
	CMP.W	D4,D2
	BNE.L	lbC000E00
	MOVEM.L	(SP)+,D3/D4
	RTS

;lbW000E2C	dc.w	0

lbC000E2E	CLR.L	D0
	MOVE.B	-8(A6,D7.W),D0
	DIVU.W	#12,D0
	MOVE.W	D0,D1
	CLR.W	D0
	SWAP	D0
	TST.W	6(A4)
	BNE.S	lbC000E7E
	LSL.W	#1,D0
	LEA	lbW000ED4(PC),A0
	MOVE.W	0(A0,D0.W),D0
	CMPI.B	#1,$1C(A4)
	BEQ.S	lbC000E5E
	CLR.L	D2
	MOVE.B	$1C(A4),D2
	MULU.W	D2,D0
lbC000E5E	CMPI.W	#1,4(A4)
	BEQ.S	lbC000E70
	DIVU.W	4(A4),D0
	ANDI.L	#$FFFF,D0
lbC000E70	TST.B	D1
	BEQ.S	lbC000E7A
	LSR.L	#1,D0
	SUBQ.B	#1,D1
	BNE.S	lbC000E70
lbC000E7A	LSL.W	#1,D0
	RTS

lbC000E7E	MOVE.L	D3,-(SP)
	MOVE.L	D4,-(SP)
	CLR.W	D2
	MOVE.B	D0,D2
	MOVE.W	6(A4),D0
	LSL.W	#1,D2
	LEA	lbW000EBC(PC),A0
	MOVE.W	0(A0,D2.W),D3
	MULU.W	D3,D0
	LSL.L	#1,D0
	SWAP	D0
	MOVE.B	$1D(A4),D4
lbC000E9E	CMP.B	D1,D4
	BEQ.S	lbC000EB0
	BCS.S	lbC000EAA
	LSL.W	#1,D0
	SUBQ.B	#1,D4
	BRA.S	lbC000E9E

lbC000EAA	LSR.W	#1,D0
	ADDQ.B	#1,D4
	BRA.S	lbC000E9E

lbC000EB0	ANDI.L	#$FFFF,D0
	MOVE.L	(SP)+,D4
	MOVE.L	(SP)+,D3
	RTS

lbW000EBC	dc.w	$8000
	dc.w	$78D1
	dc.w	$7209
	dc.w	$6BA3
	dc.w	$6598
	dc.w	$5FE5
	dc.w	$5A83
	dc.w	$556E
	dc.w	$50A3
	dc.w	$4C1C
	dc.w	$47D7
	dc.w	$43CF
lbW000ED4	dc.w	$D5C8
	dc.w	$C9C8
	dc.w	$BE75
	dc.w	$B3C4
	dc.w	$A9AD
	dc.w	$A027
	dc.w	$972A
	dc.w	$8EAE
	dc.w	$86AC
	dc.w	$7F1D
	dc.w	$77FB
	dc.w	$7124

lbC000EEC	MOVEM.L	D3-D7/A5,-(SP)
	MOVE.W	4(A4),D2
	LSL.W	#1,D2
	CLR.W	D1
	MOVE.B	$62(A6,D7.W),D1
	LSL.W	#8,D7
	LEA	lbW000FCA,A1				; was PC
	ADDA.L	D7,A1
	MOVEA.L	A4,A0
	ADDA.L	#$26,A0
	BTST	#3,8(A4)
	BEQ.S	lbC000F16
	MOVEA.L	A1,A0
lbC000F16	CMPI.B	#1,D1
	BNE.S	lbC000F36
	CMPA.L	A0,A1
	BEQ.S	lbC000F98
	MOVE.L	A1,-(SP)
	LSR.W	#2,D2
	CMPI.B	#$40,D2
	BEQ.S	lbC000F2C
	ADDQ.B	#1,D2
lbC000F2C	MOVE.L	(A0)+,(A1)+
	SUBQ.B	#1,D2
	BNE.S	lbC000F2C
	MOVEA.L	(SP)+,A1
	BRA.S	lbC000F98

lbC000F36	MOVE.W	D1,D3
	LSR.B	#1,D3
	SUBA.L	A5,A5
	CLR.L	D0
	BSR.L	lbC000F9E
lbC000F42	MOVE.W	D0,D4
	MOVE.W	D1,D0
	LSR.B	#1,D0
	ADD.W	D3,D0
	CMP.W	D2,D0
	BCS.S	lbC000F50
	SUB.W	D2,D0
lbC000F50	BSR.L	lbC000F9E
	MOVE.W	D0,D7
	SUB.W	D4,D7
	BMI.S	lbC000F60
	MOVE.W	#1,D5
	BRA.S	lbC000F66

lbC000F60	MOVE.W	#$FFFF,D5
	NEG.W	D7
lbC000F66	CLR.W	D6
	MOVE.W	D0,-(SP)
	MOVE.W	D1,D0
lbC000F6C	MOVE.B	D4,0(A1,D3.W)
	ADD.W	D7,D6
lbC000F72	CMP.W	D6,D1
	BHI.S	lbC000F7C
	SUB.W	D1,D6
	ADD.W	D5,D4
	BRA.S	lbC000F72

lbC000F7C	ADDQ.W	#1,D3
	CMP.W	D2,D3
	BCS.S	lbC000F8A
	SUB.W	D2,D3
	LEA	1,A5
lbC000F8A	SUBQ.B	#1,D0
	BNE.S	lbC000F6C
	MOVE.W	(SP)+,D0
	CMPA.W	#0,A5
	BEQ.L	lbC000F42
lbC000F98	MOVEM.L	(SP)+,D3-D7/A5
	RTS

lbC000F9E	MOVEM.L	D3/D4,-(SP)
	MOVE.W	D1,-(SP)
	CLR.W	D4
	CLR.W	D3
lbC000FA8	MOVE.B	0(A0,D0.W),D3
	EXT.W	D3
	ADD.W	D3,D4
	ADDQ.W	#1,D0
	CMP.W	D2,D0
	BNE.S	lbC000FB8
	CLR.W	D0
lbC000FB8	SUBQ.B	#1,D1
	BNE.S	lbC000FA8
	MOVE.W	(SP)+,D1
	EXT.L	D4
	DIVS.W	D1,D4
	MOVE.W	D4,D0
	MOVEM.L	(SP)+,D3/D4
	RTS

	Section	Buffer,BSS_C

lbW000FCA
	ds.b	1024
lbW000E2C
	ds.b	4

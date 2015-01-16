	*****************************************************
	****      Leggless Music Editor replayer for	 ****
	****    EaglePlayer 2.00+ (Amplifier version),   ****
	****         all adaptions by Wanted Team	 ****
	*****************************************************

	incdir "dh2:include/"
	include "misc/eagleplayer2.01.i"
	include	'misc/eagleplayerengine.i'
	include	'exec/exec_lib.i'

	SECTION	Player_Code,CODE

	EPPHEADER Tags

	dc.b	'$VER: Leggless Music Editor player module V2.0 (29 Sep 2003)',0
	even

Tags
	dc.l	DTP_PlayerVersion,2<<16!0
	dc.l	EP_PlayerVersion,11
	dc.l	DTP_PlayerName,PlayerName
	dc.l	DTP_Creator,Creator
	dc.l	EP_Check5,Check5
	dc.l	EP_NewModuleInfo,NewModuleInfo
	dc.l	DTP_SubSongRange,SubSongRange
	dc.l	DTP_InitPlayer,InitPlayer
	dc.l	DTP_InitSound,InitSound
	dc.l	DTP_Interrupt,Interrupt
	dc.l	EP_SampleInit,SampleInit
	dc.l	EP_GetPositionNr,GetPosition
	dc.l	EP_InitAmplifier,InitAudstruct
	dc.l	EP_EagleBase,EagleBase
	dc.l	EP_Flags,EPB_NextSong!EPB_PrevSong!EPB_Save!EPB_ModuleInfo!EPB_SampleInfo!EPB_Packable!EPB_Songend
	dc.l	0

PlayerName
	dc.b	'Leggless Music Editor',0
Creator
	dc.b	'(c) 1990 by Steve ''Leggless'' Hasler,',10
	dc.b	'adapted by Wanted Team',0
Prefix	dc.b	"LME.",0
	even
ModulePtr
	dc.l	0
Songend
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
PokeVol
	movem.l	D0/D1/A5,-(SP)
	move.w	A2,D1		;DFF0A0/B0/C0/D0
	sub.w	#$F0A0,D1
	lsr.w	#4,D1		;Number the channel from 0-3
	move.l	EagleBase(PC),A5
	jsr	ENPP_PokeVol(A5)
	movem.l	(SP)+,D0/D1/A5
	rts

*---------------------------------------------------------------------------*
* Input		D0 = Address value
PokeAdr
	movem.l	D0/D1/A5,-(SP)
	move.w	A2,D1		;DFF0A0/B0/C0/D0
	sub.w	#$F0A0,D1
	lsr.w	#4,D1		;Number the channel from 0-3
	move.l	EagleBase(PC),A5
	jsr	ENPP_PokeAdr(A5)
	movem.l	(SP)+,D0/D1/A5
	rts

*---------------------------------------------------------------------------*
* Input		D0 = Length value
PokeLen
	movem.l	D0/D1/A5,-(SP)
	move.w	A2,D1		;DFF0A0/B0/C0/D0
	sub.w	#$F0A0,D1
	lsr.w	#4,D1		;Number the channel from 0-3
	move.l	EagleBase(PC),A5
	and.l	#$FFFF,D0
	jsr	ENPP_PokeLen(A5)
	movem.l	(SP)+,D0/D1/A5
	rts

*---------------------------------------------------------------------------*
* Input		D0 = Period value
PokePer
	movem.l	D0/D1/A5,-(SP)
	move.w	A2,D1		;DFF0A0/B0/C0/D0
	sub.w	#$F0A0,D1
	lsr.w	#4,D1		;Number the channel from 0-3
	move.l	EagleBase(PC),A5
	jsr	ENPP_PokePer(A5)
	movem.l	(SP)+,D0/D1/A5
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
***************************** EP_GetPositionNr ****************************
***************************************************************************

GetPosition
	move.l	CurrentPos2(PC),D0
	sub.l	FirstPos2(PC),D0
	lsr.l	#1,D0
	rts

***************************************************************************
******************************* EP_SampleInit *****************************
***************************************************************************

SampleInit
	moveq	#EPR_NotEnoughMem,D7
	lea	EPG_SampleInfoStructure(A5),A3
	move.l	ModulePtr(pc),D0
	beq.b	return
	move.l	D0,A2

	move.l	40(A2),D2
	move.l	56(A2),D5
	sub.l	D2,D5
	divu.w	#58,D5			; total instruments
	subq.l	#1,D5
	move.l	A2,A4
	move.l	InfoBuffer+SongSize(pc),D4
	add.l	D4,A4
	lea	40(A2),A2
	add.l	D2,A2
	moveq	#3,D6

hop2
	tst.l	(A2)
	beq.b	Synth2

	cmp.l	(A2),D6
	bge.b	Retry2

	jsr	ENPP_AllocSampleStruct(A5)
	move.l	D0,(A3)
	beq.b	return
	move.l	D0,A3

	move.l	(A2),D6
	move.w	4(A2),D4
	lsl.l	#1,D4

	move.l	A4,EPS_Adr(A3)			; sample address
	move.l	D4,EPS_Length(A3)		; sample length
	move.l	#$40,EPS_Volume(A3)
	move.w	#USITY_RAW,EPS_Type(A3)
	move.w	#USIB_Playable!USIB_Saveable!USIB_8BIT,EPS_Flags(A3)

	add.l	D4,A4
	bra.b	Retry2

Synth2
	jsr	ENPP_AllocSampleStruct(A5)
	move.l	D0,(A3)
	beq.b	return
	move.l	D0,A3

	move.w	#USITY_AMSynth,EPS_Type(A3)
Retry2
	lea	58(A2),A2
	dbf	D5,hop2

	moveq	#0,D7
return
	move.l	D7,D0
	rts

***************************************************************************
***************************** DTP_InitPlayer ******************************
***************************************************************************

InitPlayer
	moveq	#0,D0
	movea.l	dtg_GetListData(A5),A0
	jsr	(A0)

	lea	ModulePtr(PC),A1
	move.l	A0,(A1)			; module buffer

	lea	InfoBuffer(PC),A4
	move.l	D0,LoadSize(A4)

	move.l	ModulePtr(PC),A3
	moveq	#44,D1
	add.l	52(A3),D1		; D1 = songsize
	move.l	40(A3),D2		; start sampleinfo
	move.l	56(A3),D3		; end sampleinfo
	sub.l	D2,D3
	divu.w	#58,D3			; total instruments
	subq.l	#1,D3
	lea	40(A3),A2
	add.l	D2,A2

	moveq	#0,D2			; synth
	moveq	#0,D4			; normal
	moveq	#0,D6			; samplessize
	moveq	#3,D7

hop
	tst.l	(A2)
	beq.b	Synth

	cmp.l	(A2),D7
	bge.b	Retry

	move.l	(A2),D7
	move.w	4(A2),D5
	lsl.l	#1,D5
	add.l	D5,D6
	addq.l	#1,D4
	bra.b	Retry
Synth
	addq.l	#1,D2
Retry
	lea	58(A2),A2
	dbf	D3,hop
	move.l	48(A3),D3
	sub.l	44(A3),D3
	lsr.l	#2,D3

	moveq	#-16,D0
	add.l	$28(A3),D0
	lsr.l	#4,D0
	move.l	D0,SubSongs(A4)
	move.w	D3,Steps+2(A4)			; D3 = steps
	move.l	D1,SongSize(A4)			; D1 = songsize
	move.w	D2,SynthSamples+2(A4)		; D2 = synth samples
	move.w	D4,Samples+2(A4)		; D4 = samples
	move.l	D6,SamplesSize(A4)		; D6 = samples size
	add.l	D1,D6
	move.l	D6,CalcSize(A4)

	cmp.l	LoadSize(A4),D6
	ble.b	SizeOK
	moveq	#EPR_ModuleTooShort,D0		; error message
	rts
SizeOK	
	lea	4(A3),A3
	move.l	A3,SpecialInfo(A4)

	moveq	#0,D0
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
SynthSamples	=	52
SpecialInfo	=	60
Steps		=	68
Length		=	76

InfoBuffer
	dc.l	MI_SubSongs,0		;4
	dc.l	MI_LoadSize,0		;12
	dc.l	MI_Songsize,0		;20
	dc.l	MI_SamplesSize,0	;28
	dc.l	MI_Samples,0		;36
	dc.l	MI_Calcsize,0		;44
	dc.l	MI_SynthSamples,0	;52
	dc.l	MI_SpecialInfo,0	;60
	dc.l	MI_Steps,0		;68
	dc.l	MI_Length,0		;76
	dc.l	MI_Prefix,Prefix
	dc.l	0

***************************************************************************
******************************** EP_Check5 ********************************
***************************************************************************

Check5
	movea.l	dtg_ChkData(A5),A0
	moveq	#-1,D0

	cmp.l	#'LME'<<8,(A0)
	bne.b	Fault
	tst.l	36(A0)
	bne.b	Fault

	moveq	#0,D0
Fault
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
***************************** DTP_InitSound *******************************
***************************************************************************

InitSound
	lea	Songend(PC),A0
	move.l	#'WTWT',(A0)

	moveq	#0,D0
	move.w	dtg_SndNum(A5),D0
	move.l	ModulePtr(PC),A3
	move.l	A3,lbL000AF6
	move.w	D0,D2
SongLen
	move.l	64(A3),D3
	sub.l	60(A3),D3
	lea	16(A3),A3
	dbf	D2,SongLen
	lsr.l	#1,D3
	subq.l	#1,D3
	lea	InfoBuffer(PC),A1
	move.l	D3,Length(A1)
	bra.w	Init

***************************************************************************
***************************** DTP_Interrupt *******************************
***************************************************************************

Interrupt
	movem.l	D1-A6,-(A7)

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

***************************************************************************
************************* Legless Music Editor player *********************
***************************************************************************

; player from game Punisher

Init
	lea	lbL000672(PC),A0
	lea	lbW000778(PC),A2
	move.l	A2,(A0)+
	move.l	A2,(A0)+
	move.l	A2,(A0)+
	move.l	A2,(A0)+
	lea	lbL000682(PC),A0
	lea	lbL000AEA(PC),A2

;	lea	lbL000B22(PC),A1

	move.l	lbL000AF6(PC),A1	; inserted
	lea	$28(A1),A1		; inserted

	movea.l	A1,A3
	asl.w	#4,D0
	moveq	#3,D2
lbC00002E:
	move.l	(A1)+,D1
	add.l	A3,D1
	move.l	D1,(A2)+
	move.l	12(A1,D0.W),D1
	add.l	A3,D1
	move.l	D1,(A0)+
	move.l	D1,12(A0)
	dbra	D2,lbC00002E
	lea	lbW00066A(PC),A2
;	move.w	#1,(A2)				; error in replayer :-(
	move.w	#1,(A2)+
	move.w	#1,(A2)+
	move.w	#1,(A2)+

		move.w	#1,(A2)				; fix

	lea	lbL0006C6(PC),A2
	clr.w	(A2)
	clr.w	8(A2)
	clr.w	$10(A2)
	clr.w	$18(A2)
	rts
;End
;	move.w	#15,$DFF096
;	rts
Play
;	bset	#1,$BFE001
	movea.l	#$DFF0A0,A1
	lea	lbL0006A6(PC),A0
	movea.l	lbL000AF6(PC),A2
	moveq	#3,D7
lbC00008E:
	tst.w	(A0)
	beq.s	lbC0000A0
	clr.w	(A0)+
;	move.l	(A0)+,(A1)				; address
;	move.w	(A0)+,4(A1)				; length

		movem.l	D0/A2,-(SP)
		move.l	A1,A2
		move.l	(A0)+,D0
		bsr.w	PokeAdr
		move.w	(A0)+,D0
		bsr.w	PokeLen
		movem.l	(SP)+,D0/A2

	adda.w	#$10,A1
	bra.s	lbC0000A6

lbC0000A0:
	addq.w	#8,A0
	adda.w	#$10,A1
lbC0000A6:
	dbra	D7,lbC00008E
	lea	lbW000668(PC),A0
	move.w	#$8000,(A0)
	bsr.w	lbC000370
	bsr.w	lbC000452
	bsr.w	lbC0003FE
	bsr.w	lbC0004C4
	bsr.w	lbC0005AA
	moveq	#3,D7
	moveq	#0,D0
	lea	lbW00066A(PC),A0
lbC0000CE:
	subq.w	#1,0(A0,D0.W)
	beq.s	lbC0000F0
lbC0000D4:
	addq.w	#2,D0
	dbra	D7,lbC0000CE
	bsr.w	lbC000532

;	move.w	#$B0,D0
;lbC0000E2:
;	dbra	D0,lbC0000E2
;	move.w	lbW000668(PC),$DFF096

		move.l	D0,-(SP)
		move.w	lbW000668(PC),D0
		bsr.w	PokeDMA
		move.l	(SP)+,D0

	rts

lbC0000F0:
	move.w	D0,D5
	move.w	D0,D6
	lsr.w	#1,D6
	asl.w	#1,D5
	lea	lbW0006EE(PC),A1
	move.w	0(A1,D0.W),D1
	lea	lbL0006F6(PC),A1
	clr.w	2(A1,D1.W)
	movea.l	lbL000AF2(PC),A6
	lea	lbL000672(PC),A1
	movea.l	0(A1,D5.W),A3
	move.w	(A3)+,D1
	bpl.s	lbC00015A
	lea	lbL000682(PC),A5
	movea.l	0(A5,D5.W),A4
	move.w	(A4)+,D2
	cmp.w	#$FFFF,D2
	bne.s	lbC000132

		lea	Songend(PC),A4
		tst.w	D0
		bne.b	test1
		clr.b	(A4)
		bra.b	test
test1
		cmp.w	#2,D0
		bne.b	test2
		clr.b	1(A4)
		bra.b	test
test2
		cmp.w	#4,D0
		bne.b	test3
		clr.b	2(A4)
		bra.b	test
test3
		cmp.w	#6,D0
		bne.b	test
		clr.b	3(A4)
test
		tst.l	(A4)
		bne.b	SkipEnd
		move.l	#'WTWT',(A4)
		bsr.w	SongEnd
SkipEnd

	lea	lbL000692(PC),A4
	movea.l	0(A4,D5.W),A4
	move.w	(A4)+,D2
lbC000132:
	lea	lbL000770(PC),A2
	clr.w	0(A2,D0.W)
	btst	#15,D2
	beq.s	lbC000148
	bclr	#15,D2
	move.w	(A4)+,0(A2,D0.W)
lbC000148:
	move.l	A4,0(A5,D5.W)
	movea.l	lbL000AEE(PC),A2
	asl.w	#2,D2
	movea.l	0(A2,D2.W),A3
	adda.l	A6,A3
	move.w	(A3)+,D1
lbC00015A:
	btst	#0,D1
	bne.w	lbC00028E
	btst	#1,D1
	bne.w	lbC0002B0
lbC00016A:
	btst	#4,D1
	bne.w	lbC0003B6
lbC000172:
	btst	#3,D1
	beq.s	lbC000182
	lea	lbW000766(PC),A2
	bset	#0,(A2)
	bra.s	lbC0001E2

lbC000182:
	lea	lbW00077A(PC),A4
	move.w	0(A4,D0.W),D3
	lea	lbL000768(PC),A4
	move.w	0(A4,D0.W),D2
	movea.l	lbL000AEA(PC),A4
	lea	lbW000782(PC),A2
	move.w	6(A4,D2.W),6(A2,D3.W)
	move.l	14(A4,D2.W),14(A2,D3.W)
	move.l	$12(A4,D2.W),$12(A2,D3.W)
	move.l	$16(A4,D2.W),$16(A2,D3.W)
	move.l	$1A(A4,D2.W),$1A(A2,D3.W)
	move.l	$1E(A4,D2.W),$1E(A2,D3.W)
	move.l	$22(A4,D2.W),$22(A2,D3.W)
	move.l	$26(A4,D2.W),$26(A2,D3.W)
	move.l	$2A(A4,D2.W),$2A(A2,D3.W)
	move.l	$2E(A4,D2.W),$2E(A2,D3.W)
	move.l	$32(A4,D2.W),$32(A2,D3.W)
	move.l	$36(A4,D2.W),$36(A2,D3.W)
lbC0001E2:
	moveq	#0,D4
	btst	#2,D1
	bne.w	lbC00031C
lbC0001EC:
	move.w	(A3)+,0(A0,D0.W)
	lea	lbW000660(PC),A2
	move.w	0(A2,D0.W),D2
	lea	lbL000650(PC),A2
	movea.l	0(A2,D5.W),A2
	move.w	(A3)+,D3
	lea	lbL000770(PC),A4
	add.w	0(A4,D0.W),D3
	asl.w	#1,D3
	lea	lbW000606(PC),A4
	move.w	0(A4,D3.W),D3
	lea	lbL0006E6(PC),A4
	move.w	D3,0(A4,D0.W)
	tst.w	D4
	bne.w	lbC00034E
lbC000222:
	lea	lbW000766(PC),A4
	tst.w	(A4)
	beq.s	lbC000238
	clr.w	(A4)
;	move.w	D3,6(A2)			; period

		move.l	D0,-(SP)
		move.w	D3,D0
		bsr.w	PokePer
		move.l	(SP)+,D0

	move.l	A3,0(A1,D5.W)
	bra.w	lbC0000D4

lbC000238:
	lea	lbW00077A(PC),A4
	move.w	0(A4,D0.W),D4
	lea	lbW000782(PC),A4
	movea.l	lbL000AF6(PC),A5
	lea	lbL0006A6(PC),A6
	move.w	D5,D1
	asl.w	#1,D1
	move.w	#1,0(A6,D1.W)
	adda.l	0(A4,D4.W),A5
;	move.w	D2,$DFF096
;	move.l	0(A4,D4.W),(A2)			; address
;	move.w	4(A4,D4.W),4(A2)		; length
;	move.w	D3,6(A2)			; period
;	move.w	6(A4,D4.W),8(A2)		; volume

		move.l	D0,-(SP)
		move.w	D2,D0
		bsr.w	PokeDMA
		move.l	0(A4,D4.W),D0
		bsr.w	PokeAdr
		move.w	4(A4,D4.W),D0
		bsr.w	PokeLen
		move.w	D3,D0
		bsr.w	PokePer
		move.w	6(A4,D4.W),D0
		bsr.w	PokeVol
		move.l	(SP)+,D0

	move.l	A3,0(A1,D5.W)
	move.l	8(A4,D4.W),2(A6,D1.W)
	move.w	12(A4,D4.W),6(A6,D1.W)
	lea	lbW000668(PC),A2
	or.w	D2,(A2)
	bra.w	lbC0000D4

lbC00028E:
	move.w	(A3)+,0(A0,D0.W)
	lea	lbW000660(PC),A2
;	move.w	0(A2,D0.W),$DFF096

		move.l	D0,-(SP)
		move.w	0(A2,D0.W),D0
		bsr.w	PokeDMA
		move.l	(SP)+,D0

	lea	lbL0006A2(PC),A2
	move.b	#1,0(A2,D6.W)
	move.l	A3,0(A1,D5.W)
	bra.w	lbC0000D4

lbC0002B0:
	lea	lbL000768(PC),A2
	move.w	(A3)+,D2
	asl.w	#1,D2
	move.w	D2,D3
	asl.w	#2,D2
	move.w	D2,D4
	asl.w	#1,D2
	move.w	D2,D6
	asl.w	#1,D2
	add.w	D3,D2
	add.w	D4,D2
	add.w	D6,D2
	move.w	D2,0(A2,D0.W)
	movea.l	lbL000AEA(PC),A2
	lea	lbW00077A(PC),A4
	move.w	0(A4,D0.W),D4
	lea	lbW000782(PC),A4
	adda.w	D4,A4
	adda.w	D2,A2
	movea.l	A4,A5
	move.w	#$2C,D3
lbC0002E8:
	move.w	(A2)+,(A4)+
	dbra	D3,lbC0002E8
	tst.w	$26(A5)
	bne.s	lbC000302
	move.l	lbL000AF6(PC),D2
	add.l	D2,(A5)
	add.l	D2,8(A5)
	bra.w	lbC00016A

lbC000302:
	lea	lbL0008EA,A2			; was PC
	move.w	D5,D2
	asl.w	#5,D2
	adda.w	D2,A2
	move.l	A2,(A5)
	move.l	A2,8(A5)
	move.w	4(A5),12(A5)
	bra.w	lbC00016A

lbC00031C:
	lea	lbL0006C6(PC),A4
	move.w	D5,D3
	asl.w	#1,D3
	move.w	(A3)+,D2
	lea	lbL000770(PC),A2
	add.w	0(A2,D0.W),D2
	lea	lbW000606(PC),A2
	move.w	(A3)+,2(A4,D3.W)
	asl.w	#1,D2
	move.w	0(A2,D2.W),D2
	move.w	D2,4(A4,D3.W)
	move.w	D2,0(A4,D3.W)
	move.w	(A3)+,6(A4,D3.W)
	moveq	#1,D4
	bra.w	lbC0001EC

lbC00034E:
	andi.l	#$FFFF,D3
	moveq	#0,D1
	lea	lbL0006C6(PC),A4
	move.w	D5,D4
	asl.w	#1,D4
	move.w	0(A4,D4.W),D1
	sub.l	D3,D1
	divs.w	2(A4,D4.W),D1
	move.w	D1,0(A4,D4.W)
	bra.w	lbC000222

lbC000370:
	moveq	#3,D7
	lea	lbL0006C6(PC),A0
	lea	lbL0006E6(PC),A1
	movea.l	#$DFF0A6,A2
lbC000380:
	tst.w	(A0)
	beq.s	lbC0003A8
	tst.w	6(A0)
	bmi.s	lbC000390
	subq.w	#1,6(A0)
	bpl.s	lbC0003A8
lbC000390:
	move.w	(A1),D0
	add.w	(A0),D0
;	move.w	D0,(A2)				; period

		move.l	A2,-(SP)
		subq.l	#6,A2
		bsr.w	PokePer
		move.l	(SP)+,A2

	move.w	D0,(A1)
	subq.w	#1,2(A0)
	bne.s	lbC0003A8
;	move.w	4(A0),(A2)			; period

		movem.l	D0/A2,-(SP)
		subq.l	#6,A2
		move.w	4(A0),D0
		bsr.w	PokePer
		movem.l	(SP)+,D0/A2

	move.w	4(A0),(A1)
	clr.w	(A0)
lbC0003A8:
	addq.w	#8,A0
	addq.w	#2,A1
	adda.w	#$10,A2
	dbra	D7,lbC000380
	rts

lbC0003B6:
	lea	lbL0006F6(PC),A2
	lea	lbW0006EE(PC),A4
	lea	lbL000770(PC),A5
	movea.w	0(A5,D0.W),A5
	move.w	0(A4,D0.W),D2
	lea	lbW000606(PC),A4
	move.w	(A3)+,D3
	clr.w	0(A2,D2.W)
	asl.w	#1,D3
	move.w	D3,2(A2,D2.W)
	lsr.w	#1,D3
	move.w	#1,4(A2,D2.W)
	move.w	(A3)+,6(A2,D2.W)
	subq.w	#2,D3
lbC0003E8:
	move.w	(A3)+,D4
	add.w	A5,D4
	asl.w	#1,D4
	move.w	0(A4,D4.W),10(A2,D2.W)
	addq.w	#2,D2
	dbra	D3,lbC0003E8
	bra.w	lbC000172

lbC0003FE:
	lea	lbL0006F6(PC),A0
	lea	lbL0006E6(PC),A1
	lea	lbW000782(PC),A3
	movea.l	#$DFF0A6,A2
	moveq	#3,D0
lbC000412:
	move.w	(A1)+,8(A0)
	tst.w	2(A0)
	beq.s	lbC000440
	subq.w	#1,4(A0)
	bne.s	lbC000440
	move.w	6(A0),4(A0)
	move.w	(A0),D1
	move.w	8(A0,D1.W),D2
	add.w	14(A3),D2
;	move.w	D2,(A2)				; period

		movem.l	D0/A2,-(SP)
		subq.l	#6,A2
		move.w	D2,D0
		bsr.w	PokePer
		movem.l	(SP)+,D0/A2

	addq.w	#2,D1
	move.w	D1,(A0)
	cmp.w	2(A0),D1
	bne.s	lbC000440
	clr.w	(A0)
lbC000440:
	adda.w	#$1C,A0
	adda.w	#$10,A2
	adda.w	#$5A,A3
	dbra	D0,lbC000412
	rts

lbC000452:
	lea	lbL000790(PC),A0
	lea	lbL0006E6(PC),A1
	movea.l	#$DFF0A6,A2
	lea	lbL0006F6(PC),A3
	moveq	#3,D0
lbC000466:
	tst.w	2(A0)
	beq.s	lbC0004B0
	tst.w	10(A0)
	bmi.s	lbC000478
	subq.w	#1,10(A0)
	bpl.s	lbC0004B0
lbC000478:
	move.w	(A0),D1
	tst.w	4(A0)
	bne.s	lbC000494
	add.w	2(A0),D1
	move.w	D1,(A0)
	cmp.w	6(A0),D1
	bne.s	lbC0004A6
	bset	#0,4(A0)
	bra.s	lbC0004A6

lbC000494:
	sub.w	2(A0),D1
	move.w	D1,(A0)
	cmp.w	8(A0),D1
	bne.s	lbC0004A6
	bclr	#0,4(A0)
lbC0004A6:
	tst.w	2(A3)
	bne.s	lbC0004B0
	add.w	(A1),D1
;	move.w	D1,(A2)				; period

		movem.l	D0/A2,-(SP)
		subq.l	#6,A2
		move.w	D1,D0
		bsr.w	PokePer
		movem.l	(SP)+,D0/A2

lbC0004B0:
	adda.w	#$5A,A0
	addq.w	#2,A1
	adda.w	#$10,A2
	adda.w	#$1C,A3
	dbra	D0,lbC000466
	rts

lbC0004C4:
	lea	lbW000782(PC),A0
	movea.l	#$DFF0A8,A1
	moveq	#3,D2
lbC0004D0:
	move.w	6(A0),D1
	move.w	$1A(A0),D0
	beq.s	lbC00051E
	cmp.w	#2,D0
	beq.s	lbC000500
	cmp.w	#3,D0
	beq.s	lbC00050C
	cmp.w	#1,D0
	bne.s	lbC00051E
	add.w	$1C(A0),D1
	cmp.w	$1E(A0),D1
	bmi.s	lbC00051E
	move.w	$1E(A0),D1
	addq.w	#1,$1A(A0)
	bra.s	lbC00051E

lbC000500:
	subq.w	#1,$20(A0)
	bpl.s	lbC00051E
	addq.w	#1,$1A(A0)
	bra.s	lbC00051E

lbC00050C:
	sub.w	$22(A0),D1
	cmp.w	$24(A0),D1
	bgt.s	lbC00051E
	move.w	$24(A0),D1
	addq.w	#1,$1A(A0)
lbC00051E:
;	move.w	D1,(A1)				; volume

		movem.l	D0/A2,-(SP)
		lea	-8(A1),A2
		move.w	D1,D0
		bsr.w	PokeVol
		movem.l	(SP)+,D0/A2

	move.w	D1,6(A0)
	adda.w	#$5A,A0
	adda.w	#$10,A1
	dbra	D2,lbC0004D0
	rts

lbC000532:
	lea	lbW000782(PC),A0
	moveq	#3,D0
lbC000538:
	tst.w	$26(A0)
	beq.s	lbC0005A0
	cmpi.w	#2,$26(A0)
	beq.s	lbC000560
	movea.l	(A0),A1
	move.w	$28(A0),D1
	add.w	$2A(A0),D1
	cmp.w	$2C(A0),D1
	bmi.s	lbC000578
	move.w	$2C(A0),D1
	addq.w	#1,$26(A0)
	bra.s	lbC000578

lbC000560:
	movea.l	(A0),A1
	move.w	$28(A0),D1
	sub.w	$2E(A0),D1
	cmp.w	$30(A0),D1
	bgt.s	lbC000578
	move.w	$30(A0),D1
	subq.w	#1,$26(A0)
lbC000578:
	move.w	D1,$28(A0)
	move.w	$32(A0),D2
	move.w	$34(A0),D3
	move.w	4(A0),D4
	asl.w	#1,D4
	sub.w	D1,D4
	subq.w	#2,D1
	bmi.s	lbC00059A
lbC000590:
	move.b	D2,(A1)+
	dbra	D1,lbC000590
	tst.w	D4
	bmi.s	lbC0005A0
lbC00059A:
	move.b	D3,(A1)+
	dbra	D4,lbC00059A
lbC0005A0:
	adda.w	#$5A,A0
	dbra	D0,lbC000538
	rts

lbC0005AA:
	lea	lbW000782(PC),A0
	lea	lbW000660(PC),A1
	lea	lbW000668(PC),A2
	movea.l	#$DFF0A0,A4
	lea	lbL0006A6(PC),A5
	moveq	#3,D0
lbC0005C2:
	move.w	(A1)+,D1
	tst.w	$38(A0)
	beq.s	lbC0005F6
	subq.w	#1,$36(A0)
	bne.s	lbC0005F6
	move.w	$38(A0),$36(A0)
	or.w	D1,(A2)
;	move.w	D1,$DFF096
;	move.l	(A0),(A4)			; address
;	move.w	4(A0),4(A4)			; length

		movem.l	D0/A2,-(SP)
		move.w	D1,D0
		bsr.w	PokeDMA
		move.l	A4,A2
		move.l	(A0),D0
		bsr.w	PokeAdr
		move.w	4(A0),D0
		bsr.w	PokeLen
		movem.l	(SP)+,D0/A2

	move.w	#1,(A5)
	move.l	8(A0),2(A5)
	move.w	12(A0),6(A5)
lbC0005F6:
	adda.w	#$5A,A0
	adda.w	#$10,A4
	addq.w	#8,A5
	dbra	D0,lbC0005C2
	rts

lbW000606:
	dc.w	$358,$328,$2FA,$2D0,$2A6,$280,$25C,$23A,$21A,$1FC
	dc.w	$1E0,$1C5,$1AC,$194,$17D,$168,$153,$140,$12E,$11D
	dc.w	$10D,$FE,$F0,$E2,$D6,$CA,$BE,$B4,$AA,$A0,$97,$8F
	dc.w	$87,$7F,$78,$71,$6B
lbL000650:
	dc.l	$DFF0A0,$DFF0B0,$DFF0C0,$DFF0D0
lbW000660:
	dc.w	1,2,4,8
lbW000668:
	dc.w	0
lbW00066A:
	dc.w	1,1,1,1
lbL000672:
	dc.l	0,0,0,0
lbL000682:
CurrentPos1
	dc.l	0
CurrentPos2
	dc.l	0
CurrentPos3
	dc.l	0
CurrentPos4
	dc.l	0
lbL000692:
FirstPos1
	dc.l	0
FirstPos2
	dc.l	0
FirstPos3
	dc.l	0
FirstPos4
	dc.l	0
lbL0006A2:
	dc.l	0
lbL0006A6:
	dc.l	0,0,0,0,0,0,0,0
lbL0006C6:
	dc.l	0,0,0,0,0,0,0,0
lbL0006E6:
	dc.l	0,0
lbW0006EE:
	dc.w	0,$1C,$38,$54
lbL0006F6:
	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0
lbW000766:
	dc.w	0
lbL000768:
	dc.l	0
	dc.l	0
lbL000770:
	dc.l	0,0
lbW000778:
	dc.w	$FFFF
lbW00077A:
	dc.w	0,$5A,$B4,$10E
lbW000782:
	dc.w	0,0,0,0,0,0,0
lbL000790:
	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0,0
	dc.w	0

lbL000AEA:
	dc.l	0
lbL000AEE:
	dc.l	0
lbL000AF2:
	dc.l	0
lbL000AF6:
	dc.l	0

	Section	Buffy,BSS_C

lbL0008EA:
	ds.b	512

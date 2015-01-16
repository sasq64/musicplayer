	*****************************************************
	****          Paul Summers replayer for 	 ****
	****    EaglePlayer 2.00+ (Amplifier version),   ****
	****         all adaptions by Wanted Team        ****
	*****************************************************

	incdir	"dh2:include/"
	include 'misc/eagleplayer2.01.i'
	include	'misc/eagleplayerengine.i'
	include	'exec/exec_lib.i'

	SECTION	Player_Code,CODE

	EPPHEADER Tags

	dc.b	'$VER: Paul Summers player module V2.0 (25 Jan 2002)',0
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
	dc.l	EP_InitAmplifier,InitAudstruct
	dc.l	EP_EagleBase,EagleBase
	dc.l	EP_Flags,EPB_ModuleInfo!EPB_Songend!EPB_NextSong!EPB_PrevSong!EPB_Packable!EPB_Restart
	dc.l	0

PlayerName
	dc.b	'Paul Summers',0
Creator
	dc.b	'(c) 1989-90 by Paul Summers & Mike',10
	dc.b	'Chilton, adapted by Wanted Team',0
Prefix
	dc.b	'SNK.',0
	even
ModulePtr
	dc.l	0
SamplesInfoPtr
	dc.l	0
SongPtr
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
	move.l	4.W,a6
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
	move.l	D1,-(SP)
	move.w	A3,D1		;DFF0A0/B0/C0/D0
	sub.w	#$F0A0,D1
	lsr.w	#4,D1		;Number the channel from 0-3
	jsr	ENPP_PokeVol(A5)
	move.l	(SP)+,D1
	rts

*---------------------------------------------------------------------------*
* Input		D0 = Address value
*		D1 = Number the channel
PokeAdr
	move.l	D1,-(SP)
	move.w	A3,D1		;DFF0A0/B0/C0/D0
	sub.w	#$F0A0,D1
	lsr.w	#4,D1		;Number the channel from 0-3
	jsr	ENPP_PokeAdr(A5)
	move.l	(SP)+,D1
	rts

*---------------------------------------------------------------------------*
* Input		D0 = Length value
*		D1 = Number the channel
PokeLen
	move.l	D1,-(SP)
	move.w	A3,D1		;DFF0A0/B0/C0/D0
	sub.w	#$F0A0,D1
	lsr.w	#4,D1		;Number the channel from 0-3
	and.l	#$FFFF,D0
	jsr	ENPP_PokeLen(A5)
	move.l	(SP)+,D1
	rts

*---------------------------------------------------------------------------*
* Input		D0 = Period value
PokePer
	move.l	D1,-(SP)
	move.w	A3,D1		;DFF0A0/B0/C0/D0
	sub.w	#$F0A0,D1
	lsr.w	#4,D1		;Number the channel from 0-3
	jsr	ENPP_PokePer(A5)
	move.l	(SP)+,D1
	rts

*---------------------------------------------------------------------------*
* Input		D0 = Bitmask
PokeDMA
	movem.l	D0/D1,-(SP)
	move.w	D0,D1
	and.w	#$8000,D0	;D0.w neg=enable ; 0/pos=disable
	and.l	#15,D1		;D1 = Mask (LONG !!)
	jsr	ENPP_DMAMask(a5)
	movem.l	(SP)+,D0/D1
	rts

***************************************************************************
***************************** DTP_Interrupt *******************************
***************************************************************************

Interrupt
	movem.l	D1-D7/A0-A6,-(A7)

	move.l	EagleBase(PC),A5
	bsr.w	Play
	jsr	ENPP_Amplifier(A5)

	movem.l	(A7)+,D1-D7/A0-A6
	moveq	#0,D0
	rts

SongEndTest
	move.l	A1,-(A7)
	lea	Songend(PC),A1
	cmp.l	#$DFF0A0,A3
	bne.b	test1
	clr.b	(A1)
	bra.b	test
test1
	cmp.l	#$DFF0B0,A3
	bne.b	test2
	clr.b	1(A1)
	bra.b	test
test2
	cmp.l	#$DFF0C0,A3
	bne.b	test3
	clr.b	2(A1)
	bra.b	test
test3
	cmp.l	#$DFF0D0,A3
	bne.b	test
	clr.b	3(A1)
test
	tst.l	(A1)
	bne.b	SkipEnd
	move.l	#'WTWT',(A1)
	move.l	dtg_SongEnd(A5),A1
	jsr	(A1)
SkipEnd
	movem.l	(A7)+,A1
	rts

***************************************************************************
***************************** EP_NewModuleInfo ****************************
***************************************************************************

NewModuleInfo

SubSongs	=	4
LoadSize	=	12
Voices		=	20

InfoBuffer
	dc.l	MI_SubSongs,0		;4
	dc.l	MI_LoadSize,0		;12
	dc.l	MI_Voices,0		;20
	dc.l	MI_MaxVoices,4
	dc.l	MI_MaxSubSongs,16
	dc.l	MI_Prefix,Prefix
	dc.l	0

***************************************************************************
******************************** EP_Check5 ********************************
***************************************************************************

Check5
	movea.l	dtg_ChkData(A5),A0
	moveq	#-1,D0

	cmp.l	#3000,dtg_ChkSize(A5)
	ble.b	Fault

	lea	650(A0),A1
	moveq	#9,D1
FindSR
	cmp.l	#$46FC2700,(A1)
	beq.b	CheckIt
	addq.l	#2,A1
	dbf	D1,FindSR
Fault
	rts
CheckIt
	tst.l	(A1)
	beq.b	Fault
	cmp.w	#$4E73,(A1)+
	bne.b	CheckIt
	cmp.w	#$41FA,(A1)+
	bne.b	CheckIt
FindLea
	cmp.w	#$41FA,(A1)+
	bne.b	FindLea
	move.w	(A1),D1
	lea	0(A1,D1.W),A1
	cmp.l	A0,A1
	bne.b	Fault
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

	lea	ModulePtr(PC),A4
	move.l	A0,(A4)+			; module buffer
	lea	InfoBuffer(PC),A6		; A6 reserved for InfoBuffer
	move.l	D0,LoadSize(A6)

	move.l	A0,A1
	cmp.l	#14000,D0
	ble.b	NoFix
	lea	13836(A0),A0
	cmp.w	#$F87F,(A0)
	bne.b	NoFix
	clr.w	(A0)				; Fighting Soccer fix
NoFix
FindIt1
	cmp.w	#$45FA,(A1)+
	bne.b	FindIt1
	move.l	A1,A2
	add.w	(A2),A2
	move.l	A2,(A4)+			; SamplesInfoPtr

FindIt2
	cmp.w	#$C0FC,(A1)+
	bne.b	FindIt2

	move.w	-8(A1),SubSongs+2(A6)
	addq.l	#4,A1
	add.w	(A1),A1

	move.l	A1,(A4)				; SongPtr

	moveq	#0,D0
	rts

***************************************************************************
***************************** DTP_InitSound *******************************
***************************************************************************

InitSound
	lea	lbL000000(PC),A0
	lea	Init(PC),A1
Clear
	clr.w	(A0)+
	cmp.l	A0,A1
	bne.b	Clear

	bsr.w	Init

	lea	Songend(PC),A0
	move.l	#'WTWT',(A0)

	lea	lbL000000(PC),A0
	move.w	dtg_SndNum(A5),D0
	move.w	D0,D1
	add.w	#$FF00,D0
	move.w	D0,(A0)
	mulu.w	#20,D1
	move.l	SongPtr(PC),A0
	lea	0(A0,D1.W),A0
	moveq	#0,D1
	moveq	#3,D2
NextVoice
	move.l	(A0)+,D0
	cmp.l	#$00001EF8,D0			; Fighting Soccer fix
	beq.b	NoVoice
	lea	0(A0,D0.L),A1
	cmp.l	ModulePtr(PC),A1
	ble.b	NoVoice
	addq.l	#1,D1
NoVoice
	dbf	D2,NextVoice
	lea	InfoBuffer(PC),A1
	move.l	D1,Voices(A1)
	move.l	(A0),D0
	move.w	D0,dtg_Timer(A5)
	rts

***************************************************************************
**************************** Paul Summers player **************************
***************************************************************************

; Player from game "Fighting Soccer" (c) 1990 Activision

lbL000000	ds.b	10
lbL00000A	ds.b	256
lbL00010A	ds.b	388

;lbC00028E	MOVE.W	#$2700,SR
;	MOVEM.L	D0-D3/A0-A3,-(SP)
;	MOVE.W	$DFF01C,D0
;	BTST	#14,D0
;	BEQ.L	lbC0002D0
;	AND.W	$DFF01E,D0
;	BTST	#13,D0
;	BEQ.L	lbC0002D0
;	MOVE.B	$BFDD00,D1
;	BTST	#0,D1
;	BEQ.L	lbC0002D0
;	MOVE.W	#$2000,$DFF09C
;	MOVE.W	#$2300,SR
;	BSR.L	lbC000408
;lbC0002D0	MOVEM.L	(SP)+,D0-D3/A0-A3
;	RTE

;lbC0002D6	MOVE.W	SR,-(SP)
;	MOVE.W	#$2700,SR
;	MOVEM.L	D0-D3/A0,-(SP)
;	MOVE.W	$DFF01C,D0
;	BTST	#14,D0
;	BEQ.L	lbC00035A
;	AND.W	$DFF01E,D0
;	ANDI.W	#$780,D0
;	MOVE.W	D0,D1
;	BEQ.L	lbC000354
;	LSR.W	#7,D1
;	AND.W	$DFF002,D1
;	BEQ.L	lbC000354
;	LEA	lbL000D20(PC),A0
;	BTST	#0,D1
;	BEQ.L	lbC00031E
;	MOVE.W	#1,$DFF0A4
;lbC00031E	BTST	#1,D1
;	BEQ.L	lbC00032E
;	MOVE.W	#1,$DFF0B4
;lbC00032E	BTST	#2,D1
;	BEQ.L	lbC00033E
;	MOVE.W	#1,$DFF0C4
;lbC00033E	BTST	#3,D1
;	BEQ.L	lbC00034E
;	MOVE.W	#1,$DFF0D4
;lbC00034E	MOVE.W	D0,$DFF09A
;lbC000354	MOVE.W	D0,$DFF09C
;lbC00035A	MOVEM.L	(SP)+,D0-D3/A0
;	MOVE.W	(SP)+,SR
;	RTE

Init
	LEA	lbL00000A(PC),A0
	MOVE.B	#$88,10(A0)
	MOVE.B	#$88,$2A(A0)
	MOVE.B	#$88,$4A(A0)
	MOVE.B	#$88,$6A(A0)
	LEA	lbL000000(PC),A0
	CLR.W	(A0)
	MOVE.W	#$4000,2(A0)
	MOVE.W	#$4000,4(A0)
	MOVE.W	#$4000,6(A0)
	MOVE.W	#$4000,8(A0)
;	MOVE.W	#15,$DFF096
;	BSR.L	lbC0003AA
	RTS

;lbC0003AA	MOVE.B	#$7F,$FFBFDD00
;	MOVE.B	#$44,$FFBFD400
;	MOVE.B	#$3A,$FFBFD500
;	MOVE.B	#$11,$FFBFDE00
;	MOVE.B	#$81,$FFBFDD00
;	LEA	lbC0002D6(PC),A0
;	MOVE.L	A0,$70
;	LEA	lbC00028E(PC),A0
;	MOVE.L	A0,$78
;	MOVE.W	#$E780,D0
;	MOVE.W	D0,$DFF09A
;	MOVE.W	#$2000,$DFF09C
;	RTS

;	MOVE.W	SR,-(SP)
;	MOVE.W	#$2700,SR
;	MOVE.W	#15,$DFF096
;	MOVE.W	(SP)+,SR
;	RTS

Play
lbC000408	MOVEM.L	D0-D5/A0-A3,-(SP)
	LEA	lbL000000(PC),A0
	MOVEQ	#0,D0
	MOVE.W	(A0),D0
	TST.W	(A0)
	BNE.L	lbC0004C2
	MOVE.W	#1,D4
	MOVEQ	#3,D5
	LEA	$DFF0A0,A1
lbC000426	ADDQ.L	#2,A0
	BCLR	#6,(A0)
	BEQ.S	lbC00043A
	MOVE.W	#$4000,(A0)
;	MOVE.W	D4,$DFF096

	move.l	D0,-(SP)
	move.w	D4,D0
	bsr.w	PokeDMA
	move.l	(SP)+,D0

	BRA.S	lbC0004B4

lbC00043A	BCLR	#7,(A0)
;	BEQ.S	lbC0004B4
;	MOVE.W	D4,$DFF096
;	MOVE.W	#$C8,D1
;lbC00044A	DBRA	D1,lbC00044A
;	BSET	#7,1(A0)
;	MOVE.W	(A0),D0
;	ANDI.W	#$3F,D0
;	ADDQ.W	#1,D0
;	MOVEQ	#0,D1
;	MOVE.B	(A0),D1
;	ANDI.W	#$3E,D1
;	ADD.W	D1,D1
;	ADD.W	D1,D1
;	MOVE.W	D1,$200
;	LEA	lbL000D24(PC),A2
;	LEA	0(A2,D1.W),A2
;	LEA	lbL000000(PC),A3
;	ADDA.L	(A2),A3				; SFX sample
;	MOVE.L	A3,(A1)				; address
;	MOVE.W	4(A2),4(A1)			; length
;	MOVE.W	6(A2),6(A1)			; period
;	MOVE.W	D0,8(A1)			; volume
;	MOVE.W	#$8200,D0
;	OR.W	D4,D0
;	MOVE.W	D0,$DFF096
;	BTST	#6,1(A0)
;	BNE.S	lbC0004B4
;	MOVE.W	#$12C,D1
;lbC0004A4	DBRA	D1,lbC0004A4
;	LEA	lbL000D20(PC),A2
;	MOVE.L	A2,(A1)
;	MOVE.W	#1,4(A1)
lbC0004B4	LEA	$10(A1),A1
	ADD.W	D4,D4
	DBRA	D5,lbC000426
	BRA.L	lbC000762

lbC0004C2	TST.W	(A0)
	BPL.L	lbC000582
;	MOVE.W	#15,$DFF096
	ANDI.W	#15,D0
	MOVE.W	D0,(A0)
;	CMP.W	#10,D0
;	BGE.L	lbC000582
	MULU.W	#$14,D0
;	LEA	lbL000E82(PC),A1

	move.l	SongPtr(PC),A1

	LEA	0(A1,D0.W),A1
	LEA	lbL00000A(PC),A2
	LEA	lbL00010A(PC),A0
	MOVE.L	A0,D3
	MOVE.W	#3,D1
lbC0004F8	MOVE.B	#$88,10(A2)
	MOVE.L	(A1)+,D0
	TST.L	D0
	BEQ.S	lbC000520

	cmp.l	#$00001EF8,D0			; Fighting Soccer fix
	beq.b	lbC000520

;	LEA	lbL000E82(PC),A0

	move.l	SongPtr(PC),A0

	LEA	0(A0,D0.L),A0

	cmp.l	ModulePtr(PC),A0
	ble.b	lbC000520

	MOVE.L	A0,(A2)
	MOVE.B	#1,10(A2)
	MOVE.W	#0,8(A2)
	MOVE.W	#0,12(A2)
lbC000520	MOVE.L	D3,4(A2)
	ADDI.L	#$80,D3
	LEA	$20(A2),A2
	DBRA	D1,lbC0004F8
;	MOVE.W	#0,$DFF0A8
;	MOVE.W	#0,$DFF0B8
;	MOVE.W	#0,$DFF0C8
;	MOVE.W	#0,$DFF0D8
;	MOVE.W	#15,$DFF096
;	MOVE.W	#$12C,D1
;lbC00055E	DBRA	D1,lbC00055E
;	MOVE.B	#0,$BFD00
;	MOVE.L	(A1),D0
;	MOVE.B	D0,$BFD400
;	LSR.W	#8,D0
;	MOVE.B	D0,$BFD500
;	MOVE.B	#$11,$BFD00
lbC000582	LEA	lbL00000A(PC),A2
	MOVEQ	#1,D3
	LEA	$DFF0A0,A3
lbC00058E	BTST	#7,10(A2)
	BEQ.S	lbC0005AA
	BSET	#6,10(A2)
	BNE.L	lbC000750
;	MOVE.W	D3,$DFF096

	move.l	D0,-(SP)
	move.w	D3,D0
	bsr.w	PokeDMA
	move.l	(SP)+,D0

	BRA.L	lbC000750

lbC0005AA	BTST	#5,10(A2)
	BNE.L	lbC00067C
lbC0005B4	BTST	#1,10(A2)
	BNE.L	lbC0005D4
;	MOVE.W	D3,$DFF096

	move.l	D0,-(SP)
	move.w	D3,D0
	bsr.w	PokeDMA
	move.l	(SP)+,D0

;	MOVE.W	D3,D0
;	ASL.W	#7,D0
;	MOVE.W	D0,$DFF09A
;	MOVE.W	D0,$DFF09C
lbC0005D4	BCLR	#0,10(A2)
	BCLR	#5,10(A2)
	BCLR	#1,10(A2)
lbC0005E6	MOVEA.L	(A2),A1
	MOVEQ	#0,D2
	MOVE.B	(A1)+,D2
	EXT.W	D2
	BMI.L	lbC000BA0
	MOVEA.L	$1C(A2),A0
	MOVEQ	#0,D0
	MOVE.W	(A0)+,D0
	BEQ.w	lbC000666
	SUBQ.W	#1,D0
lbC0005FE	CMP.W	10(A0),D2
	BLT.L	lbC00060C
	CMP.W	12(A0),D2
	BLE.S	lbC000616
lbC00060C	LEA	14(A0),A0
	DBRA	D0,lbC0005FE
	BRA.S	lbC000666

lbC000616	MOVEQ	#0,D0
	MOVE.W	8(A0),D0
	SUB.L	D0,D2
	MOVE.L	A1,-(SP)
	MOVE.L	D2,$18(A2)
	MOVE.L	(A0),D0
	LEA	0(A0,D0.L),A1
	MOVE.L	4(A0),D1
	MOVE.L	D2,D0
	MOVE.L	D1,D2
	BSR.L	lbC000768
	SWAP	D1
;	MOVE.L	A1,(A3)				; address
;	MOVE.W	D2,4(A3)			; length
;	MOVE.W	D1,6(A3)			; period

	move.l	D0,-(SP)
	move.l	A1,D0
	bsr.w	PokeAdr
	move.w	D2,D0
	bsr.w	PokeLen
	move.w	D1,D0
	bsr.w	PokePer
	move.l	(SP)+,D0

	MOVE.W	D3,D0
	ORI.W	#$8200,D0
;	MOVE.W	D0,$DFF096

	bsr.w	PokeDMA

;	ASL.W	#7,D0
;	ORI.W	#$C000,D0
;	MOVE.W	D0,$DFF09A
;	ANDI.W	#$8780,D0
;	MOVE.W	D0,$DFF09C

	lea	lbL000000(PC),A1
	move.w	D3,D0
	lsl.w	#1,D0
	add.w	D0,A1
	btst	#6,1(A1)
	bne.b	NoEmpty
	lea	lbL000D20,A1
	move.l	D0,-(SP)
	move.l	A1,D0
	bsr.w	PokeAdr
	moveq	#1,D0
	bsr.w	PokeLen
	move.l	(SP)+,D0
NoEmpty

	MOVEA.L	(SP)+,A1
lbC000666	MOVE.W	12(A2),D0
	CLR.W	12(A2)
	MOVE.B	(A1)+,D0
	MOVE.W	D0,8(A2)
	MOVE.L	A1,(A2)
	BSET	#5,10(A2)
lbC00067C	TST.W	8(A2)
	BEQ.L	lbC0005B4
	SUBQ.W	#1,8(A2)
	BNE.S	lbC0006A6
	ANDI.B	#$DC,10(A2)
;	MOVE.W	D3,$DFF096

	move.l	D0,-(SP)
	move.w	D3,D0
	bsr.w	PokeDMA
	move.l	(SP)+,D0

;	MOVE.W	D3,D0
;	ASL.W	#7,D0
;	MOVE.W	D0,$DFF09A
;	MOVE.W	D0,$DFF09C
lbC0006A6	BTST	#0,10(A2)
	BEQ.L	lbC000750
	TST.W	$12(A2)
	BEQ.S	lbC0006BE
	SUBQ.W	#1,$12(A2)
	BNE.L	lbC000750
lbC0006BE	MOVEQ	#0,D2
	MOVE.L	$18(A2),D0
	MOVE.B	$16(A2),D2
	SUB.L	D2,D0
	MOVE.B	$14(A2),D2
lbC0006CE	CMP.B	$17(A2),D2
	BLT.S	lbC0006DC
	SUB.B	$17(A2),D2
	ADDQ.L	#1,D0
	BRA.S	lbC0006CE

lbC0006DC	MOVE.L	D0,-(SP)
	MOVEQ	#0,D0
	MOVE.L	D0,D1
	MOVE.B	$16(A2),D0
lbC0006E6	ADD.W	D2,D1
	DBRA	D0,lbC0006E6
	SUB.W	D2,D1
	EXG	D1,D2
	MOVE.L	(SP)+,D0
	BSR.L	lbC000768
	MOVE.L	D1,-(SP)
	SUB.L	D1,D0
	MOVE.W	D0,D1
	MULU.W	D2,D1
	SWAP	D0
	MULU.W	D2,D0
	SWAP	D0
	CLR.W	D0
	ADD.W	D1,D0
	LSR.L	#6,D0
	MOVE.L	(SP)+,D1
	SUB.L	D0,D1
	SWAP	D1
;	MOVE.W	D1,6(A3)			; period

	move.l	D0,-(SP)
	move.w	D1,D0
	bsr.w	PokePer
	move.l	(SP)+,D0

	MOVEA.L	14(A2),A1
lbC000718	MOVEQ	#0,D0
	MOVE.B	(A1)+,D0
	CMP.B	#$F7,D0
	BNE.S	lbC00072C
	MOVE.B	(A1)+,D2
	ASL.W	#8,D2
	MOVE.W	D2,12(A2)
	BRA.S	lbC000718

lbC00072C	CMP.B	#$F8,D0
	BNE.S	lbC00074A
	MOVE.B	(A1)+,$14(A2)
	MOVE.W	12(A2),D2
	CLR.W	12(A2)
	MOVE.B	(A1)+,D2
	MOVE.W	D2,$12(A2)
	MOVE.L	A1,14(A2)
	BRA.S	lbC000750

lbC00074A	BCLR	#0,10(A2)
lbC000750	LEA	$20(A2),A2
	LEA	$10(A3),A3
	ADD.B	D3,D3
	CMPI.B	#$10,D3
	BNE.L	lbC00058E
lbC000762	MOVEM.L	(SP)+,D0-D5/A0-A3
	RTS

lbC000768	ADD.L	D0,D0
	ADD.L	D0,D0
	NEG.L	D0
	LEA	lbL00098C(PC),A0
	MOVE.L	0(A0,D0.L),D1
	MOVE.L	4(A0,D0.L),D0
	RTS

	dc.l	$1D20
	dc.l	$1EF2
	dc.l	$20C4
	dc.l	$2296
	dc.l	$2468
	dc.l	$2723
	dc.l	$28F5
	dc.l	$2BB0
	dc.l	$2E6B
	dc.l	$3126
	dc.l	$33E1
	dc.l	$369C
	dc.l	$3A40
	dc.l	$3DE4
	dc.l	$4188
	dc.l	$452C
	dc.l	$49B9
	dc.l	$4D5D
	dc.l	$52D3
	dc.l	$5760
	dc.l	$5CD6
	dc.l	$624C
	dc.l	$67C2
	dc.l	$6E21
	dc.l	$7480
	dc.l	$7BC8
	dc.l	$8310
	dc.l	$8A58
	dc.l	$9289
	dc.l	$9BA3
	dc.l	$A4BD
	dc.l	$AEC0
	dc.l	$B8C3
	dc.l	$C3AF
	dc.l	$CF84
	dc.l	$DC42
	dc.l	$E900
	dc.l	$F6A7
	dc.l	$10537
	dc.l	$114B0
	dc.l	$125FB
	dc.l	$13746
	dc.l	$1497A
	dc.l	$15D80
	dc.l	$17186
	dc.l	$18847
	dc.l	$19F08
	dc.l	$1B79B
	dc.l	$1D200
	dc.l	$1ED4E
	dc.l	$20B57
	dc.l	$22A49
	dc.l	$24B0D
	dc.l	$26DA3
	dc.l	$292F4
	dc.l	$2BA17
	dc.l	$2E3F5
	dc.l	$30FA5
	dc.l	$33E10
	dc.l	$3701F
	dc.l	$3A400
	dc.l	$3DB85
	dc.l	$415C5
	dc.l	$45492
	dc.l	$4961A
	dc.l	$4DC2F
	dc.l	$525E8
	dc.l	$5742E
	dc.l	$5C701
	dc.l	$61F4A
	dc.l	$67D09
	dc.l	$6DF55
	dc.l	$74800
	dc.l	$7B70A
	dc.l	$82C73
	dc.l	$8A83B
	dc.l	$92C34
	dc.l	$9B85E
	dc.l	$A4BD0
	dc.l	$AE945
	dc.l	$B8EEB
	dc.l	$C3E94
	dc.l	$CF929
	dc.l	$DBEAA
	dc.l	$E9000
	dc.l	$F6E14
	dc.l	$1058E6
	dc.l	$11515F
	dc.l	$125951
	dc.l	$1370BC
	dc.l	$149889
	dc.l	$15D1A1
	dc.l	$171DD6
	dc.l	$187E11
	dc.l	$19F252
	dc.l	$1B7D54
	dc.l	$1D2000
	dc.l	$1EDB3F
	dc.l	$20B0E3
	dc.l	$22A2BE
	dc.l	$24B1B9
	dc.l	$26E08F
	dc.l	$293029
	dc.l	$2BA342
	dc.l	$2E3BAC
	dc.l	$30FB39
	dc.l	$33E4A4
	dc.l	$36FAA8
	dc.l	$3A4000
	dc.l	$3DB67E
	dc.l	$4161C6
	dc.l	$45457C
	dc.l	$49645B
	dc.l	$4DC11E
	dc.l	$526052
	dc.l	$574684
	dc.l	$5C7758
	dc.l	$61F672
	dc.l	$67CA31
	dc.l	$6DF639
	dc.l	$748000
	dc.l	$7B6CFC
	dc.l	$82C475
	dc.l	$8A8AF8
	dc.l	$92C7CD
	dc.l	$9B823C
	dc.l	$A4C18D
	dc.l	$AE8DF1
	dc.l	$B8EEB0
	dc.l	$C3EDCD
	dc.l	$CF9462
	dc.l	$DBEC72
lbL00098C	dc.l	$E90000
	dc.l	$F6DAE1
	dc.l	$10588EA
	dc.l	$11515F0
	dc.l	$1258F9A
	dc.l	$1370478
	dc.l	$149831A
	dc.l	$15D1AF9
	dc.l	$171DD60
	dc.l	$187DB9A
	dc.l	$19F28C4
	dc.l	$1B7D7FB
	dc.l	$1D20000
	dc.l	$1EDB5C2
	dc.l	$20B10EB
	dc.l	$22A2BE0
	dc.l	$24B1F34
	dc.l	$26E08F0
	dc.l	$2930634
	dc.l	$2BA35F2
	dc.l	$2E3BAC0
	dc.l	$30FB734
	dc.l	$33E5188
	dc.l	$36FB0DF
	dc.l	$3A40000
	dc.l	$3DB6B84
	dc.l	$41622BF
	dc.l	$45457C0
	dc.l	$4963F51
	dc.l	$4DC11E0
	dc.l	$5260C68
	dc.l	$5746BE4
	dc.l	$5C77580
	dc.l	$61F6E68
	dc.l	$67CA227
	dc.l	$6DF61BE
	dc.l	$7480000
	dc.l	$7B6D708
	dc.l	$82C4495
	dc.l	$8A8AE97
	dc.l	$92C7DB9
	dc.l	$9B824A9
	dc.l	$A4C17E7
	dc.l	$AE8D7C8
	dc.l	$B8EEA17
	dc.l	$C3EDCD0
	dc.l	$CF94537
	dc.l	$DBEC37C
	dc.l	$E900000
	dc.l	$F6DAE10
	dc.l	$10588A13
	dc.l	$11515D2E
	dc.l	$1258FC5B
	dc.l	$13704869
	dc.l	$14982FCE
	dc.l	$15D1B079
	dc.l	$171DD517
	dc.l	$187DB9A0
	dc.l	$19F28A6E
	dc.l	$1B7D86F8
	dc.l	$1D200000
	dc.l	$1EDB5B37
	dc.l	$20B1133D
	dc.l	$22A2BA5C
	dc.l	$24B1F8B6
	dc.l	$26E090D2
	dc.l	$29306085
	dc.l	$2BA360F2
	dc.l	$2E3BA945
	dc.l	$30FB7257
	dc.l	$33E514DC
	dc.l	$36FB0DF0
	dc.l	$3A400000
	dc.l	$3DB6B66E
	dc.l	$41622763
	dc.l	$454574B8
	dc.l	$4963F16C
	dc.l	$4DC121A4
	dc.l	$5260C10A
	dc.l	$5746C0FB
	dc.l	$5C775373
	dc.l	$61F6E4AE
	dc.l	$67CA29B8
	dc.l	$6DF61BE0
	dc.l	$74800000
	dc.l	$7B6D6DC5
	dc.l	$82C44EC6
	dc.l	$8A8AE970
	dc.l	$92C7E2D8
	dc.l	$9B824348
	dc.l	$A4C1812B
	dc.l	$AE8D82DF
	dc.l	$B8EEA5FD
	dc.l	$C3EDCA45
	dc.l	$CF945370
	dc.l	$DBEC36D7
	dc.l	$E9000000
	dc.l	$F6DADAA1
	dc.l	$5889D8C
	dc.l	$1515D3C9
	dc.l	$258FC5B0
	dc.l	$37048779
	dc.l	$49830256
	dc.l	$5D1B04D5
	dc.l	$71DD4BFA
	dc.l	$87DB93A1
	dc.l	$9F28A6E0
	dc.l	$B7D86DAE
	dc.l	$D2000000
	dc.l	$EDB5B542
	dc.l	$B113B18
	dc.l	$2A2BA6A9
	dc.l	$4B1F8A77
	dc.l	$6E090E09
	dc.l	$930604AC
	dc.l	$BA3609AA
	dc.l	$E3BA97F4
	dc.l	$FB72742
	dc.l	$3E514DC0
	dc.l	$6FB0DB5C
	dc.l	$A3FFFF17
	dc.l	$DB6B699B
	dc.l	$16227547
	dc.l	$54574C69
	dc.l	$963F1405
	dc.l	$DC121A40
	dc.l	$260C086F
	dc.l	$746C126B
	dc.l	$C7752EFF
	dc.l	$1F6E4D9B
	dc.l	$7CA29A97
	dc.l	$DF61B4E6
	dc.l	$47FFFC5C

lbC000BA0	ANDI.W	#15,D2
	ASL.W	#2,D2
	EXT.L	D2
	LEA	lbL000BB4(PC),A0
	MOVE.L	0(A0,D2.W),D2
	JMP	0(A0,D2.L)

lbL000BB4
	dc.l	Label_1-lbL000BB4
	dc.l	Label_3-lbL000BB4
	dc.l	Label_4-lbL000BB4
	dc.l	Label_5-lbL000BB4
	dc.l	Label_6-lbL000BB4
	dc.l	Label_7-lbL000BB4
	dc.l	Label_8-lbL000BB4
	dc.l	Label_9-lbL000BB4
	dc.l	Label_2-lbL000BB4
	dc.l	Label_A-lbL000BB4
	dc.l	lbC0005E6-lbL000BB4
	dc.l	lbC0005E6-lbL000BB4
	dc.l	lbC0005E6-lbL000BB4
	dc.l	lbC0005E6-lbL000BB4
	dc.l	Label_B-lbL000BB4
	dc.l	Label_C-lbL000BB4

Label_1
	BSET	#1,10(A2)
;	MOVE.W	D3,$DFF096

	move.l	D0,-(SP)
	move.w	D3,D0
	bsr.w	PokeDMA
	move.l	(SP)+,D0

	BRA.L	lbC000666

Label_2
	BSET	#0,10(A2)
	BNE.S	lbC000C28
	MOVE.B	(A1)+,$14(A2)
	MOVE.W	12(A2),D2
	CLR.W	12(A2)
	MOVE.B	(A1)+,D2
	MOVE.W	D2,$12(A2)
	MOVE.L	A1,14(A2)
	MOVE.L	A1,(A2)
	BRA.L	lbC0005E6

lbC000C28	ADDQ.L	#2,A1
	MOVE.L	A1,(A2)
	BRA.L	lbC0005E6

Label_3
	MOVE.B	(A1)+,D2
	ASL.L	#8,D2
	MOVE.B	(A1)+,D2
	ASL.L	#8,D2
	MOVE.B	(A1)+,D2
	ASL.L	#8,D2
	MOVE.B	(A1)+,D2
	LEA	-4(A1,D2.L),A1
	MOVEM.L	A1,(A2)
	BRA.L	lbC0005E6

Label_4
	MOVEA.L	4(A2),A0
	MOVE.B	(A1)+,D2
	ASL.L	#8,D2
	MOVE.B	(A1)+,D2
	ASL.L	#8,D2
	MOVE.B	(A1)+,D2
	ASL.L	#8,D2
	MOVE.B	(A1)+,D2
	MOVE.L	A1,-(A0)
	MOVE.L	A0,4(A2)
	LEA	-4(A1,D2.L),A1
	MOVE.L	A1,(A2)
	BRA.L	lbC0005E6

Label_5
	MOVEA.L	4(A2),A0
	MOVEM.L	(A0)+,A1
	MOVE.L	A1,(A2)
	MOVE.L	A0,4(A2)
	BRA.L	lbC0005E6

Label_6
	MOVE.B	(A1)+,D2
	ASL.L	#8,D2
	MOVE.B	(A1)+,D2
	MOVEA.L	4(A2),A0
	MOVEM.L	D2/A1,-(A0)
	MOVEM.L	A1,(A2)
	MOVEM.L	A0,4(A2)
	BRA.L	lbC0005E6

Label_7
	MOVEA.L	4(A2),A0
	EXG	D0,A1
	MOVEM.L	(A0)+,D2/A1
	SUBQ.W	#1,D2
	BEQ.L	lbC000CB0
	MOVEM.L	D2/A1,-(A0)
	EXG	D0,A1
lbC000CB0	EXG	D0,A1
	MOVE.L	A1,(A2)
	MOVE.L	A0,4(A2)
	BRA.L	lbC0005E6

Label_8
	MOVE.B	(A1)+,D2
	ASL.L	#8,D2
	MOVE.B	(A1)+,D2
	ASL.L	#8,D2
	MOVE.B	(A1)+,D2
	ASL.L	#8,D2
	MOVE.B	(A1)+,D2
	MOVEM.L	A1,(A2)
	LEA	-4(A1,D2.L),A0
	MOVE.L	A0,$1C(A2)
	BRA.L	lbC0005E6

Label_9
	MOVE.B	(A1)+,D2
	ASL.W	#8,D2
	MOVE.W	D2,12(A2)
	MOVEM.L	A1,(A2)
	BRA.L	lbC0005E6

Label_A
	MOVEQ	#0,D2
	MOVE.B	(A1)+,D2
	MOVE.B	D2,$16(A2)
	BEQ.S	lbC000CFE
	MOVE.W	#$40,D1
	DIVU.W	D2,D1
	MOVE.B	D1,$17(A2)
lbC000CFE	MOVEM.L	A1,(A2)
	BRA.L	lbC0005E6

Label_B
	MOVEQ	#0,D2
	MOVE.B	(A1)+,D2
;	MOVE.B	D2,8(A3)				; volume

	move.l	D0,-(SP)
	move.w	D2,D0
	bsr.w	PokeVol
	move.l	(SP)+,D0

	MOVEM.L	A1,(A2)
	BRA.L	lbC0005E6

Label_C

	bsr.w	SongEndTest

	BSET	#7,10(A2)
	BRA.L	lbC000750


	Section	Empty,BSS_C

lbL000D20	ds.b	4

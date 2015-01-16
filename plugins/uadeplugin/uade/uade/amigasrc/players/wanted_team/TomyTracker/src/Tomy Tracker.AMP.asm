	******************************************************
	****           Tomy Tracker replayer for     	  ****
	****    EaglePlayer 2.00+ (Amplifier version),    ****
	****         all adaptions by Wanted Team	  ****
	******************************************************

	incdir	"dh2:include/"
	include 'misc/eagleplayer2.01.i'
	include	'misc/eagleplayerengine.i'
	include	'exec/exec_lib.i'

	SECTION	Player,CODE

	EPPHEADER Tags

	dc.b	'$VER: Tomy Tracker player module V2.0 (17 Jan 2003)',0
	even
Tags
	dc.l	DTP_PlayerVersion,2<<16!0
	dc.l	EP_PlayerVersion,11
	dc.l	DTP_PlayerName,PlayerName
	dc.l	DTP_Creator,Creator
	dc.l	EP_Check5,Check5
	dc.l	DTP_InitPlayer,InitPlayer
	dc.l	DTP_InitSound,InitSound
	dc.l	DTP_Interrupt,Interrupt
	dc.l	EP_NewModuleInfo,NewModuleInfo
	dc.l	EP_GetPositionNr,GetPosition
	dc.l	EP_SampleInit,SampleInit
	dc.l	DTP_NextPatt,Next_Pattern
	dc.l	DTP_PrevPatt,BackPattern
	dc.l	EP_PatternInit,PatternInit
	dc.l	EP_Flags,EPB_Save!EPB_ModuleInfo!EPB_SampleInfo!EPB_Songend!EPB_Packable!EPB_Restart!EPB_PrevPatt!EPB_NextPatt
	dc.l	EP_EagleBase,EagleBase
	dc.l	EP_InitAmplifier,InitAudstruct
	dc.l	0

PlayerName
	dc.b	'Tomy Tracker',0
Creator
	dc.b	"(c) 1992 by Tom 'Tomy' Pakarinen,",10
	dc.b	'adapted by Wanted Team',0
Prefix
	dc.b	'SG.',0
	even
ModulePtr
	dc.l	0
SamplesPtr
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
	movem.l	D1/A5,-(SP)
	move.w	A6,D1		;DFF0A0/B0/C0/D0
	sub.w	#$F0A0,D1
	lsr.w	#4,D1		;Number the channel from 0-3
	move.l	EagleBase(PC),A5
	jsr	ENPP_PokeVol(A5)
	movem.l	(SP)+,D1/A5
	rts

*---------------------------------------------------------------------------*
* Input		D0 = Address value
PokeAdr
	movem.l	D1/A5,-(SP)
	move.w	A6,D1		;DFF0A0/B0/C0/D0
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
	move.w	A6,D1		;DFF0A0/B0/C0/D0
	sub.w	#$F0A0,D1
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
	move.w	A6,D1		;DFF0A0/B0/C0/D0
	sub.w	#$F0A0,D1
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
****************************** EP_PatternInit *****************************
***************************************************************************

PATTERNINFO:
	DS.B	PI_Stripes	; This is the main structure

* Here you store the address of each "stripe" (track) for the current
* pattern so the PI engine can read the data for each row and send it
* to the CONVERTNOTE function you supply.  The engine determines what
* data needs to be converted by looking at the Pattpos and Modulo fields.

STRIPE1	DS.L	1
STRIPE2	DS.L	1
STRIPE3	DS.L	1
STRIPE4	DS.L	1

* More stripes go here in case you have more than 4 channels.


* Called at various and sundry times (e.g. StartInt, apparently)
* Return PatternInfo Structure in A0
PatternInit
	lea	PATTERNINFO(PC),A0
	moveq	#4,D0
	move.w	D0,PI_Voices(A0)	; Number of stripes (MUST be at least 4)
	move.l	#CONVERTNOTE,PI_Convert(A0)
	moveq	#16,D0
	move.l	D0,PI_Modulo(A0)	; Number of bytes to next row
	move.w	#64,PI_Pattlength(A0)	; Length of each stripe in rows
	move.w	InfoBuffer+Patterns+2(PC),PI_NumPatts(A0)	; Overall Number of Patterns
	clr.w	PI_Pattern(A0)		; Current Pattern (from 0)
	move.w	#6,PI_Speed(A0)		; Default Speed Value
	clr.w	PI_Pattpos(A0)		; Current Position in Pattern (from 0)
	clr.w	PI_Songpos(A0)		; Current Position in Song (from 0)
	move.w	InfoBuffer+Length+2(PC),PI_MaxSongPos(A0)	; Songlength

	move.w	#125,PI_BPM(A0)

	lea	STRIPE1(PC),A1
	clr.l	(A1)+
	clr.l	(A1)+
	clr.l	(A1)+
	clr.l	(A1)
	rts

* Called by the PI engine to get values for a particular row
CONVERTNOTE:


* The command string is a single character.  It is NOT ASCII, howver.
* The character mapping starts from value 0 and supports letters from A-Z

* $00 ~ '0'
* ...
* $09 ~ '9'
* $0A ~ 'A'
* ...
* $0F ~ 'F'
* $10 ~ 'G'
* etc.

	moveq	#0,D0		; Period? Note?
	moveq	#0,D1		; Sample number
	moveq	#0,D2		; Command string
	moveq	#0,D3		; Command argument
	move.b	(A0),D2
	lsr.w	#2,D2
	move.b	1(A0),D3
	move.b	2(A0),D1
	divu.w	#7,D1
	move.b	3(A0),D0
	beq.b	NoNote
	lea	Periods(PC),A1
	move.w	(A1,D0.W),D0
NoNote
	rts

PATINFO
	movem.l	D0/A0-A2,-(SP)
	lea	PATTERNINFO(PC),A0
	lea	lbW00490E(PC),A1
	move.w	2(A1),PI_Speed(A0)		; Speed Value
	move.w	4(A1),D0
	lsr.w	#4,D0
	move.w	D0,PI_Pattpos(A0)		; Current Position in Pattern
	move.l	6(A1),D0
	sub.l	#lbL004B10,D0
	lsr.l	#2,D0
	move.w	D0,PI_Songpos(A0)
	move.l	ModulePtr(PC),A2
	lea	448(A2),A2
	add.w	D0,D0
	move.b	(A2,D0.W),D0
	lsr.w	#2,D0
	move.w	D0,PI_Pattern(A0)	; Current Pattern
	move.l	6(A1),A1
	move.l	(A1),A1
	move.l	A1,PI_Stripes(A0)	; STRIPE1
	addq.l	#4,A1			; Distance to next stripe
	move.l	A1,PI_Stripes+4(A0)	; STRIPE2
	addq.l	#4,A1
	move.l	A1,PI_Stripes+8(A0)	; STRIPE3
	addq.l	#4,A1
	move.l	A1,PI_Stripes+12(A0)	; STRIPE4
	movem.l	(SP)+,D0/A0-A2
	rts

***************************************************************************
******************************* DTP_NextPatt ******************************
***************************************************************************

Next_Pattern
	lea	lbW00490E+6(PC),A0
	move.l	(A0),A1
	tst.l	4(A1)
	bmi.b	MaxPos
	addq.l	#4,(A0)
	clr.w	-2(A0)
MaxPos
	rts

***************************************************************************
******************************* DTP_BackPatt ******************************
***************************************************************************

BackPattern
	lea	lbW00490E+6(PC),A0
	move.l	(A0),A1
	cmp.w	#'WT',-2(A1)
	beq.b	MinPos
	subq.l	#4,(A0)
	clr.w	-2(A0)
MinPos
	rts

***************************************************************************
******************************* EP_SampleInit *****************************
***************************************************************************

SampleInit
	moveq	#EPR_NotEnoughMem,D7
	lea	EPG_SampleInfoStructure(A5),A3
	move.l	ModulePtr(PC),D0
	beq.b	return
	move.l	D0,A2

	lea	10(A2),A2
	move.l	SamplesPtr(PC),A1
	moveq	#30,D5
hop
	jsr	ENPP_AllocSampleStruct(A5)
	move.l	D0,(A3)
	beq.b	return
	move.l	D0,A3

	move.l	(A2)+,D1
	add.l	A1,D1
	moveq	#0,D0
	move.w	(A2)+,D0
	add.l	D0,D0
	move.l	D1,EPS_Adr(A3)			; sample address
	move.l	D0,EPS_Length(A3)		; sample length
	move.l	#64,EPS_Volume(A3)
	move.w	#USITY_RAW,EPS_Type(A3)
	move.w	#USIB_Playable!USIB_Saveable!USIB_8BIT,EPS_Flags(A3)
	addq.l	#8,A2
	dbf	D5,hop

	moveq	#0,D7
return
	move.l	D7,D0
	rts

***************************************************************************
***************************** EP_NewModuleInfo ****************************
***************************************************************************

NewModuleInfo

Patterns	=	4
LoadSize	=	12
Samples		=	20
Length		=	28
SamplesSize	=	36
SongSize	=	44
CalcSize	=	52

InfoBuffer
	dc.l	MI_Pattern,0		;4
	dc.l	MI_LoadSize,0		;12
	dc.l	MI_Samples,0		;20
	dc.l	MI_Length,0		;28
	dc.l	MI_SamplesSize,0	;36
	dc.l	MI_Songsize,0		;44
	dc.l	MI_Calcsize,0		;52
	dc.l	MI_MaxLength,128
	dc.l	MI_MaxSamples,31
	dc.l	MI_MaxPattern,64
	dc.l	MI_Prefix,Prefix
	dc.l	0

***************************************************************************
******************************** EP_Check5 ********************************
***************************************************************************

Check5
	movea.l	dtg_ChkData(A5),A0
	moveq	#-1,D0

	cmp.l	#704+1024,dtg_ChkSize(A5)
	ble.b	Fault
	move.l	(A0)+,D1
	beq.b	Fault
	cmp.l	#$200000,D1
	bhi.b	Fault
	btst	#0,D1
	bne.b	Fault
	move.l	(A0)+,D2
	cmp.l	D1,D2
	bhi.b	Fault
	btst	#0,D2
	bne.b	Fault
	sub.l	#704,D2
	divu.w	#1024,D2
	subq.l	#1,D2
	swap	D2
	tst.w	D2
	bne.b	Fault
	lea	436(A0),A0
	tst.b	(A0)+
	bne.b	Fault
	moveq	#0,D1
	move.b	(A0)+,D1
	bmi.b	Fault
	addq.l	#2,A0
	lsr.l	#6,D2
	subq.l	#1,D1
	moveq	#0,D3
NextPos
	cmp.w	(A0),D3
	bhi.b	Higher
	move.w	(A0),D3
Higher
	addq.l	#2,A0
	dbf	D1,NextPos
	cmp.l	D3,D2
	bne.b	Fault

	moveq	#0,D0
Fault
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

	lea	InfoBuffer(PC),A4
	move.l	D0,LoadSize(A4)

	moveq	#0,D5
	move.l	A4,-(SP)
	bsr.w	InitPlay
	move.l	(SP)+,A4

	move.l	D5,Samples(A4)

	move.l	(A0)+,D1
	move.l	D1,CalcSize(A4)
	cmp.l	LoadSize(A4),D1
	ble.b	SizeOK
	moveq	#EPR_ModuleTooShort,D0
	rts
SizeOK
	move.l	(A0)+,D2
	move.w	436(A0),Length+2(A4)
	add.l	D2,A0
	move.l	A0,(A6)				; SamplesPtr
	move.l	D2,SongSize(A4)
	sub.l	D2,D1
	move.l	D1,SamplesSize(A4)
	sub.l	#704,D2
	divu.w	#1024,D2
	move.l	D2,Patterns(A4)

	moveq	#0,D0
	rts

***************************************************************************
********************************* EP_GetPosNr *****************************
***************************************************************************

GetPosition
	move.l	lbW00490E+6(PC),D0
	lea	lbL004B10(PC),A0
	sub.l	A0,D0
	lsr.l	#2,D0
	rts

***************************************************************************
***************************** DTP_InitSound *******************************
***************************************************************************

InitSound
	lea	lbW00490E(PC),A0
	move.w	#1,(A0)+
	move.w	#6,(A0)+
	clr.w	(A0)+
	lea	lbL004B10(PC),A1
	move.l	A1,(A0)+
	clr.w	(A0)
	rts

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
***************************** Tomy Tracker player *************************
***************************************************************************

; Player from intro called "Inconvenient" (c) 1992 by The Special Brothers

InitPlay
;	LEA	lbW00490E(PC),A1
;	LEA	lbW00D89C,A0
	LEA	8(A0),A2
	MOVE.L	4(A0),D0
	ADD.L	A0,D0
	MOVEQ	#$1E,D7
	LEA	lbL004998(PC),A3
lbC0044CC	MOVE.W	(A2)+,(A3)+
	MOVE.L	(A2)+,D1
	ADD.L	D0,D1
	MOVE.L	D1,(A3)+

	tst.w	(A2)
	beq.b	NoSamp
	addq.l	#1,D5
NoSamp

	MOVE.W	(A2)+,(A3)+
	MOVE.L	(A2)+,D1
	ADD.L	D0,D1
	MOVE.L	D1,(A3)+
	MOVE.W	(A2)+,(A3)+
	DBRA	D7,lbC0044CC
	LEA	$1C0(A0),A2
	MOVE.W	-4(A2),D7
	MOVE.W	-6(A2),D6
	SUBQ.W	#1,D6
	ADD.W	D6,D6
	ADD.W	D6,D6
	LEA	$2C0(A0),A3
	LEA	lbL004B10(PC),A4
	SUBQ.W	#1,D7
lbC0044FE	MOVEQ	#0,D0
	MOVE.W	(A2)+,D0
	ADD.L	A3,D0
	MOVE.L	D0,(A4)+
	DBRA	D7,lbC0044FE
	LEA	lbL004B10(PC),A3
	ADDA.W	D6,A3
	MOVE.L	A3,D6
	SUBQ.L	#4,D6
	NEG.L	D6
	MOVE.L	D6,(A4)
;	MOVE.L	$78,$1FE(A1)
;	LEA	$DFF0A8,A5
;	MOVEQ	#0,D0
;	MOVE.W	D0,(A5)
;	MOVE.W	D0,$10(A5)
;	MOVE.W	D0,$20(A5)
;	MOVE.W	D0,$30(A5)
;	MOVE.W	#15,-$12(A5)
;	ORI.B	#2,$BFE001
;	LEA	$BFD000,A1
;	MOVE.B	#$7F,$D00(A1)
;	MOVE.B	D0,$E00(A1)
;	MOVE.B	D0,$400(A1)
;	MOVE.B	#2,$500(A1)
;	MOVE.B	#$81,$D00(A1)
;	MOVE.W	#$2000,-12(A5)
;	MOVE.W	#$E000,-14(A5)
	RTS

;End
;	LEA	$DFF000,A0
;	MOVEQ	#0,D0
;	MOVE.W	D0,$A8(A0)
;	MOVE.W	D0,$B8(A0)
;	MOVE.W	D0,$C8(A0)
;	MOVE.W	D0,$D8(A0)
;	MOVE.W	#15,$96(A0)
;	MOVE.L	lbL004B0C(PC),$78
;	MOVE.W	#$2000,$9A(A0)
;	RTS

Play
	MOVEQ	#0,D6
	LEA	lbW00490E(PC),A0
	SUBQ.W	#1,(A0)+
	BNE.L	lbC00475E
	LEA	lbW004F10(PC),A1
	LEA	$DFF0A0,A6
	MOVE.W	(A0)+,-4(A0)
	MOVE.W	(A0)+,D0
	MOVEA.L	(A0)+,A2
	MOVEA.L	(A2),A2
	ADDA.W	D0,A2
	MOVE.W	D6,(A0)
	MOVEQ	#1,D5
	MOVEQ	#3,D7
	BRA.S	lbC0045CC

lbC0045C6	ADD.W	D5,D5
;	ADDQ.L	#8,A6

	lea	16(A6),A6

	ADDQ.L	#5,A1
lbC0045CC	MOVEQ	#0,D1
	MOVEQ	#0,D2
	MOVEQ	#0,D3
	MOVE.B	(A2),D3
	MOVE.W	(A2)+,2(A1)
	MOVE.B	(A2)+,D1
	BNE.S	lbC0045E6
	MOVE.B	(A1)+,D1
	ADD.W	D1,D1
	LEA	$74(A0,D1.W),A3
	BRA.S	lbC0045F2

lbC0045E6	MOVE.B	D1,(A1)+
	ADD.W	D1,D1
	LEA	$72(A0,D1.W),A3
	MOVE.W	(A3)+,3(A1)
lbC0045F2	MOVE.B	(A2)+,D2
	MOVE.B	D2,$1C(A1)
	BEQ.S	lbC00462A
	MOVE.W	$36(A0,D2.W),D1
	SUBQ.W	#4,D3
	BEQ.S	lbC004638
	SUBQ.W	#4,D3
	BEQ.S	lbC004638
	MOVE.W	D1,$17(A1)
	MOVE.B	D2,(A1)
	OR.W	D5,(A0)
	MOVE.B	D6,$30(A1)
;	MOVE.L	(A3)+,(A6)+				; adress
;	MOVE.W	(A3)+,(A6)+				; length

	move.l	D0,-(SP)
	move.l	(A3)+,D0
	bsr.w	PokeAdr
	move.w	(A3)+,D0
	bsr.w	PokeLen
	move.l	(SP)+,D0

	MOVE.L	(A3)+,$47(A1)
	MOVE.W	(A3)+,$4B(A1)
	CMPI.W	#$1C,D3
	BMI.S	lbC00466C
	MOVEA.L	6(A0,D3.W),A3
	JMP	(A3)

lbC00462A
;	ADDQ.L	#6,A6
	CMPI.W	#$24,D3
	BMI.S	lbC00466C
	MOVEA.L	-2(A0,D3.W),A3
	JMP	(A3)

lbC004638
;	ADDQ.L	#8,A6
	MOVE.B	D6,$31(A1)
	MOVE.B	3(A1),$1B(A1)
	MOVE.W	D1,$19(A1)
	CMP.W	$17(A1),D1
	BEQ.S	lbC00465E
	BGE.S	lbC004662
	NOT.B	$31(A1)
;	MOVE.W	3(A1),(A6)				; volume

	move.l	D0,-(SP)
	move.w	3(A1),D0
	bsr.w	PokeVol
	move.l	(SP)+,D0

	DBRA	D7,lbC0045C6
	BRA.S	lbC004678

lbC00465E	MOVE.W	D6,$19(A1)
lbC004662
;	MOVE.W	3(A1),(A6)				; volume

	move.l	D0,-(SP)
	move.w	3(A1),D0
	bsr.w	PokeVol
	move.l	(SP)+,D0

	DBRA	D7,lbC0045C6
	BRA.S	lbC004678

lbC00466C
;	MOVE.W	$17(A1),(A6)+				; period
;	MOVE.W	3(A1),(A6)				; volume

	move.l	D0,-(SP)
	move.w	$17(A1),D0
	bsr.w	PokePer
	move.w	3(A1),D0
	bsr.w	PokeVol
	move.l	(SP)+,D0

	DBRA	D7,lbC0045C6
lbC004678
;	MOVE.W	(A0),$DFF096

	move.l	D0,-(SP)
	move.w	(A0),D0
	bsr.w	PokeDMA
	move.l	(SP)+,D0

	ORI.W	#$8000,(A0)
	ADDI.W	#$10,-6(A0)
;	MOVE.L	#lbC0048A4,$78
;	MOVE.B	#$19,$BFDE00
	CMPI.W	#$400,-6(A0)
	BNE.S	lbC0046BC
	MOVE.W	D6,-6(A0)
	MOVEA.L	-4(A0),A1
	TST.L	4(A1)
	BPL.S	lbC0046B8
	MOVE.L	4(A1),D0
	NEG.L	D0
	MOVE.L	D0,-4(A0)

	bsr.w	SongEnd

lbC0046B8	ADDQ.L	#4,-4(A0)
lbC0046BC

	bsr.w	PATINFO
	bra.w	lbC0048CC

;	RTS

lbC0046BE	BRA.S	lbC00466C

lbC0046C0	MOVE.B	2(A1),4(A1)
	BRA.S	lbC00466C

lbC0046C8	MOVE.W	#$3F0,-6(A0)
	BRA.S	lbC00466C

lbC0046D0
;	ANDI.B	#$FD,$BFE001
	MOVE.B	2(A1),D3
;	OR.B	D3,$BFE001

	btst	#1,D3
	beq.b	Filter_On
	bsr.w	LED_Off
	bra.b	Skip
Filter_On
	bsr.w	LED_On
Skip
	BRA.w	lbC00466C

lbC0046E4	MOVE.B	2(A1),-9(A0)
	MOVE.B	2(A1),-7(A0)
	BRA.L	lbC00466C

lbC0046F4	MOVE.B	(A1),D1
	BEQ.S	lbC0046FE
	MOVE.B	D1,$19(A1)
	MOVE.B	D6,(A1)
lbC0046FE	TST.W	$17(A1)
	BEQ.S	lbC004728
	MOVE.B	$19(A1),D1
	TST.B	$2F(A1)
	BNE.S	lbC00472A
	ADD.W	D1,$15(A1)
	MOVE.W	$17(A1),D1
	CMP.W	$15(A1),D1
	BGT.S	lbC004724
	MOVE.W	D1,$15(A1)
	MOVE.W	D6,$17(A1)
lbC004724
;	MOVE.W	$15(A1),(A6)				; period

	move.l	D0,-(SP)
	move.w	$15(A1),D0
	bsr.w	PokePer
	move.l	(SP)+,D0

lbC004728	BRA.S	lbC00477E

lbC00472A	SUB.W	D1,$15(A1)
	MOVE.W	$17(A1),D1
	CMP.W	$15(A1),D1
	BLT.S	lbC004724
	MOVE.W	D1,$15(A1)
	MOVE.W	D6,$17(A1)
;	MOVE.W	$15(A1),(A6)				; period

	move.l	D0,-(SP)
	move.w	$15(A1),D0
	bsr.w	PokePer
	move.l	(SP)+,D0

	BRA.S	lbC00477E

lbC004746	MOVE.B	(A1),D1
	NEG.W	D1
	ADD.W	$15(A1),D1
	CMPI.W	#$71,D1
	BPL.S	lbC004756
	MOVEQ	#$71,D1
lbC004756	MOVE.W	D1,$15(A1)
;	MOVE.W	D1,(A6)					; period

	move.l	D0,-(SP)
	move.w	D1,D0
	bsr.w	PokePer
	move.l	(SP)+,D0

	BRA.S	lbC00477E

lbC00475E
;	LEA	$DFF0A6,A6

	lea	$DFF0A0,A6

	LEA	lbL004F12(PC),A1
	MOVEQ	#0,D0
	MOVEQ	#3,D7
lbC00476C	MOVE.B	(A1)+,D0
	BEQ.S	lbC00477E
	CMPI.B	#$24,D0
	BGE.S	lbC00477E
	MOVEQ	#0,D1
	MOVEA.L	6(A0,D0.W),A2
	JMP	(A2)

lbC00477E	ADDA.W	#$10,A6
	ADDQ.L	#5,A1
	DBRA	D7,lbC00476C
	RTS

lbC00478A	MOVE.B	(A1),D1
	ADD.W	$15(A1),D1
	CMPI.W	#$358,D1
	BMI.S	lbC00479A
	MOVE.W	#$358,D1
lbC00479A	MOVE.W	D1,$15(A1)			; period
;	MOVE.W	D1,(A6)

	move.l	D0,-(SP)
	move.w	D1,D0
	bsr.w	PokePer
	move.l	(SP)+,D0

	BRA.S	lbC00477E

ascii.MSG1	dc.b	0
	dc.b	$18
	dc.b	'1Jax'
	dc.b	$8D
	dc.b	$A1
	dc.b	$B4
	dc.b	$C5
	dc.b	$D4
	dc.b	$E0
	dc.b	$EB
	dc.b	$F4
	dc.b	$FA
	dc.b	$FD
	dc.b	$FF
	dc.b	$FD
	dc.b	$FA
	dc.b	$F4
	dc.b	$EB
	dc.b	$E0
	dc.b	$D4
	dc.b	$C5
	dc.b	$B4
	dc.b	$A1
	dc.b	$8D
	dc.b	'xaJ1'
	dc.b	$18

lbC0047C2	MOVE.B	(A1),D1
	BEQ.S	lbC0047CA
	MOVE.B	D1,$2D(A1)
lbC0047CA	MOVE.B	$2E(A1),D1
	LSR.B	#2,D1
	ANDI.W	#$1F,D1
	MOVEQ	#0,D2
	MOVE.B	ascii.MSG1(PC,D1.W),D2
	MOVE.B	$2D(A1),D1
	ANDI.W	#15,D1
	MULU.W	D1,D2
	LSR.W	#7,D2
	MOVE.W	$15(A1),D1
	TST.B	$2E(A1)
	BMI.S	lbC0047F4
	ADD.W	D2,D1
	BRA.S	lbC0047F6

lbC0047F4	SUB.W	D2,D1
lbC0047F6
;	MOVE.W	D1,(A6)				; period ?

	move.l	D0,-(SP)
	move.w	D1,D0
	bsr.w	PokePer
	move.l	(SP)+,D0

	MOVE.B	$2D(A1),D1
	LSR.B	#2,D1
	ANDI.W	#$3C,D1
	ADD.B	D1,$2E(A1)
	CMPI.B	#$18,D0
	BNE.L	lbC00477E
lbC00480E	MOVE.B	(A1),D1
	MOVE.W	D1,D2
	ANDI.W	#15,D1
	BEQ.S	lbC00482C
	SUB.W	D1,1(A1)
	BPL.S	lbC004822
	MOVE.W	D6,1(A1)
lbC004822
;	MOVE.W	1(A1),2(A6)			; volume

	move.l	D0,-(SP)
	move.w	1(A1),D0
	bsr.w	PokeVol
	move.l	(SP)+,D0

	BRA.L	lbC00477E

lbC00482C	LSR.W	#4,D2
	ADD.W	D2,1(A1)
	CMPI.W	#$40,1(A1)
	BMI.S	lbC004840
	MOVE.W	#$40,1(A1)
lbC004840
;	MOVE.W	1(A1),2(A6)			; volume

	move.l	D0,-(SP)
	move.w	1(A1),D0
	bsr.w	PokeVol
	move.l	(SP)+,D0

	BRA.L	lbC00477E

lbW00484A	dc.w	1
	dc.w	$200
	dc.w	$102
	dc.w	1
	dc.w	$200
	dc.w	$102
	dc.w	1
	dc.w	$200
	dc.w	$102
	dc.w	1
	dc.w	$200
	dc.w	$102
	dc.w	1
	dc.w	$200
	dc.w	$102
	dc.w	1

lbC00486A	MOVE.B	(A1),D1
	MOVE.W	-2(A0),D2
	SUB.W	(A0),D2
	NEG.W	D2
	MOVE.B	lbW00484A(PC,D2.W),D2
	BEQ.S	lbC00489C
	SUBQ.B	#2,D2
	BEQ.S	lbC004882
	LSR.B	#4,D1
	BRA.S	lbC004886

lbC004882	ANDI.W	#15,D1
lbC004886	ADD.W	D1,D1
	ADD.B	-2(A1),D1
	CMPI.W	#$48,D1
	BLS.S	lbC004894
	MOVEQ	#$48,D1
lbC004894
;	MOVE.W	$3E(A0,D1.W),(A6)		; period

	move.l	D0,-(SP)
	move.w	$3E(A0,D1.W),D0
	bsr.w	PokePer
	move.l	(SP)+,D0

	BRA.L	lbC00477E

lbC00489C
;	MOVE.W	$15(A1),(A6)			; period

	move.l	D0,-(SP)
	move.w	$15(A1),D0
	bsr.w	PokePer
	move.l	(SP)+,D0

	BRA.L	lbC00477E

;lbC0048A4	TST.B	$BFDD00
;	MOVE.L	#lbC0048CC,$78
;	MOVE.B	#$19,$BFDE00
;	MOVE.W	lbW004918(PC),$DFF096
;	MOVE.W	#$2000,$DFF09C
;	RTE

lbC0048CC
;	TST.B	$BFDD00
;	MOVEM.L	A5/A6,-(SP)

	movem.l	D0/D1/D2,-(SP)
	move.w	(A0),D0
	bsr.w	PokeDMA

;	LEA	$DFF0A0,A5
	LEA	lbL004F58(PC),A6
;	MOVE.L	(A6)+,(A5)+
;	MOVE.W	(A6)+,(A5)
;	MOVE.L	(A6)+,12(A5)
;	MOVE.W	(A6)+,$10(A5)
;	MOVE.L	(A6)+,$1C(A5)
;	MOVE.W	(A6)+,$20(A5)
;	MOVE.L	(A6)+,$2C(A5)
;	MOVE.W	(A6)+,$30(A5)

	move.l	EagleBase(PC),A5
	moveq	#3,D2
	moveq	#0,D1
Next
	move.l	(A6)+,D0
	jsr	ENPP_PokeAdr(A5)
	moveq	#0,D0
	move.w	(A6)+,D0
	jsr	ENPP_PokeLen(A5)
	addq.l	#1,D1
	dbf	D2,Next
	movem.l	(SP)+,D0/D1/D2


;	MOVE.W	#$2000,-14(A5)
;	MOVEM.L	(SP)+,A5/A6
;	MOVE.L	lbL004B0C(PC),$78
;	RTE

	rts

lbW00490E	dc.w	1
	dc.w	6
	dc.w	0
	dc.l	lbL004B10
lbW004918	dc.w	0
	dc.l	lbC0046F4
	dc.l	lbC0046F4
	dc.l	lbC004746
	dc.l	lbC00478A
	dc.l	lbC0047C2
	dc.l	lbC0047C2
	dc.l	lbC00480E
	dc.l	lbC00486A
	dc.l	lbC0046BE
	dc.l	lbC0046C0
	dc.l	lbC0046C8
	dc.l	lbC0046D0
	dc.l	lbC0046E4
Periods
	dc.w	0
	dc.w	$358
	dc.w	$328
	dc.w	$2FA
	dc.w	$2D0
	dc.w	$2A6
	dc.w	$280
	dc.w	$25C
	dc.w	$23A
	dc.w	$21A
	dc.w	$1FC
	dc.w	$1E0
	dc.w	$1C5
	dc.w	$1AC
	dc.w	$194
	dc.w	$17D
	dc.w	$168
	dc.w	$153
	dc.w	$140
	dc.w	$12E
	dc.w	$11D
	dc.w	$10D
	dc.w	$FE
	dc.w	$F0
	dc.w	$E2
	dc.w	$D6
	dc.w	$CA
	dc.w	$BE
	dc.w	$B4
	dc.w	$AA
	dc.w	$A0
	dc.w	$97
	dc.w	$8F
	dc.w	$87
	dc.w	$7F
	dc.w	$78
	dc.w	$71
lbL004998
	ds.b	31*14			; bug !!!, was 31*12 only
;lbL004B0C	dc.l	0

	dc.w	'WT'			; + ID for PatternJump

lbL004B10	
	ds.b	128*4			; too many, was 256*4

	dc.l	'WTWT'		        ; safety buffer for mods
                                        ; with max. length value = 128
lbW004F10
	dc.w	0
lbL004F12
	ds.b	70
lbL004F58
	ds.b	4*6

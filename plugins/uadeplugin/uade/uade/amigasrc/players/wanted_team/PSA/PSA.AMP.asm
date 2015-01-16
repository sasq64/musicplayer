	******************************************************
	****               PSA replayer for	          ****
	****    EaglePlayer 2.00+ (Amplifier version),    ****
	****         all adaptions by Wanted Team	  ****
	******************************************************

	incdir	"dh2:include/"
	include 'misc/eagleplayer2.01.i'
	include	'misc/eagleplayerengine.i'
	include	'exec/exec_lib.i'

	SECTION	Player,CODE

	EPPHEADER Tags

	dc.b	'$VER: Professional Sound Artists player module V2.0 (21 Apr 2003)',0
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
	dc.l	DTP_NextPatt,Next_Pattern
	dc.l	DTP_PrevPatt,BackPattern
	dc.l	EP_PatternInit,PatternInit
	dc.l	EP_InitAmplifier,InitAudstruct
	dc.l	EP_EagleBase,EagleBase
	dc.l	EP_Flags,EPB_Save!EPB_ModuleInfo!EPB_SampleInfo!EPB_Songend!EPB_Packable!EPB_Restart!EPB_PrevPatt!EPB_NextPatt
	dc.l	0

PlayerName
	dc.b	'Professional Sound Artists',0
Creator
	dc.b	'(c) 1990 by Dave ''Sinbad'' Hasler,',10
	dc.b	'adapted by Wanted Team',0
Prefix	dc.b	"PSA.",0
	even
ModulePtr
	dc.l	0
FirstUsed
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
* Input		D0 = Volume value
PokeVol
	movem.l	D0/D1/A5,-(SP)
	move.w	A1,D1		;DFF0A0/B0/C0/D0
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
	move.w	A1,D1		;DFF0A0/B0/C0/D0
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
	move.w	A1,D1		;DFF0A0/B0/C0/D0
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
	move.w	A1,D1		;DFF0A0/B0/C0/D0
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
****************************** EP_PatternInit *****************************
***************************************************************************

PATTERNINFO:
	DS.B	PI_Stripes	; This is the main structure

* Here you store the address of each "stripe" (track) for the current
* pattern so the PI engine can read the data for each row and send it
* to the CONVERTNOTE functino you supply.  The engine determines what
* data needs to be converted by looking at the Pattpos and Modulo fields.

STRIPE1	DS.L	1
STRIPE2	DS.L	1
STRIPE3	DS.L	1
STRIPE4	DS.L	1

* More stripes go here in case you have more than 4 channels.


* Called at various and sundry times (e.g. StartInt, apparently)
* Return PatternInfo Structure in A0
PatternInit
	LEA	PATTERNINFO(PC),A0

	MOVE.W	#4,PI_Voices(A0)	; Number of stripes (MUST be at least 4)
	MOVE.L	#CONVERTNOTE,PI_Convert(A0)
	MOVEQ.L	#16,D0
	MOVE.L	D0,PI_Modulo(A0)	; Number of bytes to next row
	MOVE.W	#64,PI_Pattlength(A0)	; Length of each stripe in rows

	MOVE.W	InfoBuffer+Pattern+2(PC),PI_NumPatts(A0)	; Overall Number of Patterns
	CLR.W	PI_Pattern(A0)		; Current Pattern (from 0)
	CLR.W	PI_Pattpos(A0)		; Current Position in Pattern (from 0)
	CLR.W	PI_Songpos(A0)		; Current Position in Song (from 0)
	MOVE.W	InfoBuffer+Length+2(PC),PI_MaxSongPos(A0)	; Songlengh

	move.w	#125,PI_BPM(A0)
	MOVE.W	#6,PI_Speed(A0)		; Default Speed Value

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

	moveq	#0,D0	; Period? Note?
	moveq	#0,D1	; Sample number
	moveq	#0,D2	; Command string
	moveq	#0,D3	; Command argument

	move.b	2(A0),D2
	move.b	3(A0),D3
	move.b	(A0),D0
	beq.b	NoNote
	move.b	1(A0),D1
	addq.w	#1,D1
	subq.w	#1,D0
	add.w	D0,D0
	lea	lbL000862(PC),A1
	move.w	0(A1,D0.W),D0
NoNote
	and.b	#$7F,D2
	rts

* Sets some current values for the PatternInfo structure.
* Call this every time something changes (or at least every interrupt).
* You can move these elsewhere if necessary, it is only important that
* you make sure the structure fields are accurate and updated regularly.

PATINFO:
	movem.l	D0/D1/A0/A1,-(SP)
	lea	PATTERNINFO(PC),A0
	move.w	4(A5),D0
	move.l	$28(A5),A1
	moveq	#0,D1
	move.w	0(A1,D0.W),D1
	move.w	D1,PI_Pattern(A0)	; Current Pattern
	asl.l	#8,D1
	asl.l	#2,D1
	add.l	$2C(A5),D1
	move.l	D1,A1
	sub.w	FirstUsed(PC),D0
	lsr.w	#1,D0
	move.w	D0,PI_Songpos(A0)	; Position in Song
	move.b	3(A5),PI_Pattpos+1(A0)	; Current Position in Pattern
	move.l	A1,PI_Stripes(A0)	; STRIPE1
	addq.l	#4,A1			; Distance to next stripe
	move.l	A1,PI_Stripes+4(A0)	; STRIPE2
	addq.l	#4,A1
	move.l	A1,PI_Stripes+8(A0)	; STRIPE3
	addq.l	#4,A1
	move.l	A1,PI_Stripes+12(A0)	; STRIPE4
	move.b	2(A5),PI_Speed+1(A0)		; Speed Value
	movem.l	(SP)+,D0/D1/A0/A1
	rts

***************************************************************************
******************************* DTP_NextPatt ******************************
***************************************************************************

Next_Pattern
	lea	lbL0006C2(PC),A5
	move.b	#$3F,3(A5)
	bsr.w	SetPosition
	rts

***************************************************************************
******************************* DTP_BackPatt ******************************
***************************************************************************

BackPattern
	lea	lbL0006C2(PC),A5
	move.w	4(A5),D0
	cmp.w	FirstUsed(PC),D0
	beq.b	MinPos
	subq.w	#4,D0
	move.b	#$3F,3(A5)
	move.w	D0,4(A5)
	bsr.w	SetPosition
MinPos
	rts

***************************************************************************
***************************** EP_GetPositionNr ****************************
***************************************************************************

GetPosition
	moveq	#0,D0
	move.w	CurrentPos(PC),D0
	sub.w	FirstUsed(PC),D0
	lsr.l	#1,D0
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
Pattern		=	60
Length		=	68
SpecialInfo	=	76

InfoBuffer
	dc.l	MI_SubSongs,0		;4
	dc.l	MI_LoadSize,0		;12
	dc.l	MI_Songsize,0		;20
	dc.l	MI_SamplesSize,0	;28
	dc.l	MI_Samples,0		;36
	dc.l	MI_Calcsize,0		;44
	dc.l	MI_SynthSamples,0	;52
	dc.l	MI_Pattern,0
	dc.l	MI_Length,0
	dc.l	MI_SpecialInfo,0
	dc.l	MI_Prefix,Prefix
	dc.l	0

***************************************************************************
******************************* EP_SampleInit *****************************
***************************************************************************

SampleInit
	moveq	#EPR_NotEnoughMem,D7
	lea	EPG_SampleInfoStructure(A5),A3
	move.l	ModulePtr(PC),D0
	beq.w	return
	move.l	D0,A2

	move.l	40(A2),D2
	move.l	44(A2),D5
	sub.l	D2,D5			; total instruments
	lsr.l	#6,D5
	subq.l	#1,D5
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

	move.l	ModulePtr(pc),A1
	move.l	(A2),D6
	add.l	D6,A1
	move.w	4(A2),D4
	lsl.l	#1,D4
	lea	33(A2),A6

	MOVE.L	A6,EPS_SampleName(A3)		; sample name
	move.l	A1,EPS_Adr(A3)			; sample address
	move.l	D4,EPS_Length(A3)		; sample length
	move.l	#64,EPS_Volume(A3)
	move.w	#USITY_RAW,EPS_Type(A3)
	move.w	#30,EPS_MaxNameLen(A3)
	move.w	#USIB_Playable!USIB_Saveable!USIB_8BIT,EPS_Flags(A3)

	bra.b	Retry2

Synth2
	jsr	ENPP_AllocSampleStruct(A5)
	move.l	D0,(A3)
	beq.b	return
	move.l	D0,A3

	lea	33(A2),A6

	MOVE.L	A6,EPS_SampleName(A3)
	move.w	#30,EPS_MaxNameLen(A3)
	MOVE.W	#USITY_AMSynth,EPS_Type(A3)
Retry2
	lea	64(A2),A2
	dbf	D5,hop2

	moveq	#0,D7
return
	move.l	D7,D0
	rts

***************************************************************************
******************************** EP_Check5 ********************************
***************************************************************************

Check5
	movea.l	dtg_ChkData(A5),A0
	moveq	#-1,D0

	cmp.l	#$50534100,(A0)
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
***************************** DTP_InitPlayer ******************************
***************************************************************************

InitPlayer
	moveq	#0,D0
	movea.l	dtg_GetListData(A5),A0
	jsr	(A0)

	lea	ModulePtr(PC),A1
	move.l	A0,(A1)				; module buffer
	lea	InfoBuffer(PC),A1
	move.l	D0,LoadSize(A1)

	move.l	ModulePtr(PC),A2
	move.l	A2,A3
	move.l	40(A2),D2
	moveq	#-56,D1
	add.l	D2,D1
	lsr.l	#3,D1
	move.l	D1,SubSongs(A1)

	move.l	44(A2),D3
	move.l	48(A2),D0
	sub.l	D2,D3			; total instruments
	lsr.l	#6,D3
	subq.l	#1,D3
	add.l	D2,A2

	moveq	#0,D2			; synth
	moveq	#0,D4			; normal
	moveq	#0,D6
	moveq	#3,D7
hop
	tst.l	(A2)
	beq.b	Synth

	cmp.l	(A2),D7
	bge.b	Jump

	move.l	(A2),D7
	move.w	4(A2),D5
	lsl.l	#1,D5
	add.l	D5,D6
	addq.l	#1,D4
	bra.b	Jump

Synth
	addq.l	#1,D2
Jump
	lea	64(A2),A2
	dbf	D3,hop

	move.l	D2,SynthSamples(A1)		; D2 = synth samples
	move.l	D4,Samples(A1)			; D4 = samples
	move.l	D6,SamplesSize(A1)		; D6 = samples size
	move.l	36(A3),D7
	move.l	D7,CalcSize(A1)
	sub.l	D6,D7
	move.l	D7,SongSize(A1)			; D7 = songsize
	sub.l	D0,D7
	divu.w	#1024,D7
	move.l	D7,Pattern(A1)			; D7 = patterns
	lea	4(A3),A3
	move.l	A3,SpecialInfo(A1)

	moveq	#0,D0
	rts

***************************************************************************
***************************** DTP_InitSound *******************************
***************************************************************************

InitSound
	moveq	#0,D0
	move.w	dtg_SndNum(A5),D0
	
	move.l	ModulePtr(PC),A3
	move.l	D0,D2
	moveq	#0,D5
	lsl.l	#3,D2
	lea	0(A3,D2.L),A3
	lea	FirstUsed(PC),A0
	move.w	56(A3),D3
	move.w	D3,(A0)					; FirstUsed
	move.w	58(A3),D5
	sub.w	D3,D5
	lsr.l	#1,D5
	lea	InfoBuffer(PC),A1
	move.l	D5,Length(A1)
	bra.w	Init


***************************************************************************
***************************** DTP_Interrupt *******************************
***************************************************************************

Interrupt
	movem.l	D1-A6,-(A7)

	bsr.w	Play_1
	bsr.w	Play_2

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
********************* Professional Sound Artists player *******************
***************************************************************************

; player from game Punisher

;	dc.w	0
;	dc.w	12
;	dc.w	0
;	dc.w	$1E0
;	dc.w	0
;	dc.w	$192

Init	MOVEM.L	D0/D1/A0/A1/A5,-(A7)
	LEA	lbL0006C2(PC),A5
	MOVE.B	#6,2(A5)
	CLR.B	1(A5)
;	MOVE.W	#15,$DFF096		; wylacza DMA kanalow dzwiekowych
;	CLR.W	$DFF0A8			; zeruje glosnosc kanalu 0 
;	CLR.W	$DFF0B8			; kanalu 1
;	CLR.W	$DFF0C8			; 2
;	CLR.W	$DFF0D8			; 3
	MOVE.B	#1,0(A5)
;	LEA	PSA.MSG(PC),A0

	move.l	ModulePtr(PC),A0

	MOVEA.L	$28(A0),A1
	ADDA.L	A0,A1
	MOVE.L	A1,$24(A5)
	MOVEA.L	$2C(A0),A1
	ADDA.L	A0,A1
	MOVE.L	A1,$28(A5)		; song positions
	MOVEA.L	$30(A0),A1
	ADDA.L	A0,A1
	MOVE.L	A1,$2C(A5)		; first pattern
	ASL.W	#3,D0
	MOVE.W	$38(A0,D0.W),6(A5)
	MOVE.W	$3A(A0,D0.W),8(A5)
	MOVE.W	$3C(A0,D0.W),10(A5)
	MOVE.W	6(A5),4(A5)
	MOVEA.L	$28(A5),A0
	MOVE.W	4(A5),D0
	MOVEQ	#0,D1
	MOVE.W	0(A0,D0.W),D1
	ASL.L	#8,D1
	ASL.L	#2,D1
	ADD.L	$2C(A5),D1
	MOVE.L	D1,12(A5)
	CLR.B	3(A5)
	MOVE.W	#$8000,$14(A5)
;	TST.B	$17(A5)
;	BNE.S	lbC0000EC
;	MOVE.B	#1,$17(A5)
;	MOVE.W	#8,$DFF09A		; wylacza przerwania PORTS (porty wejscia/wyjscia (klawiatura) i zegary)
;	MOVE.L	$68,$20(A5)		; zapamietuje adres starego wektora przerwan PORTS
;	PEA	lbC0000F2(PC)		; adres nowego wektora przerwan PORTS
;
;	PEA odklada na stosie adres podany jako argument
;
;	MOVE.L	(A7)+,$68		; ustawia nowy wektor

;	SP=A7 (stack pointer)

;	MOVE.B	#$81,$BFED01		; wlacza przerwania zegara A
;	CLR.B	$BFE401			; wyzerowanie zegara A (mlodszy bajt zegara)
;	MOVE.B	#$7F,$BFEE01		; start zegara
;	MOVE.B	#$88,$BFEE01		; tryb pracy zegara
;	MOVE.W	#$8008,$DFF09A		; wlacza przerwania PORTS
lbC0000EC	MOVEM.L	(A7)+,D0/D1/A0/A1/A5
	RTS

Play_2
lbC0000F2
;	BTST	#0,$BFED01		; czy zegar A odliczyl do 0
;	beq.w	lbC000188		; 0 = nie ; 1 = tak
	MOVEM.L	D0/A5,-(A7)
	LEA	lbL0006C2(PC),A5
;	MOVE.W	$14(A5),$DFF096

	move.l	D0,-(SP)
	move.w	$14(A5),D0
	bsr.w	PokeDMA
	move.l	(SP)+,D0

	MOVE.W	#$8000,$14(A5)

;	MOVE.W	#$20,D0			; ta petla opozniajaca jest do bani
;lbC000118				; i dlatego masz takie zgrzyty
;	DBRA	D0,lbC000118		; w czasie odgrywania

	lea	$DFF0A0,A1

	TST.B	$18(A5)
	BEQ.S	lbC000136
	CLR.B	$18(A5)
;	MOVE.L	lbL0006F2(PC),$DFF0A0		; adres sampla dla kanalu 0
;	MOVE.W	lbL0006F6(PC),$DFF0A4		; dlugosc danych dla kan. 0

	move.l	lbL0006F2(PC),D0
	bsr.w	PokeAdr
	move.w	lbL0006F6(PC),D0
	bsr.w	PokeLen

lbC000136

	lea	16(A1),A1

	TST.B	$19(A5)
	BEQ.S	lbC000150
	CLR.B	$19(A5)
;	MOVE.L	lbL00074E(PC),$DFF0B0		; adres sampla dla kanalu 1
;	MOVE.W	lbL000752(PC),$DFF0B4		; dlugosc danych dla kan. 1

	move.l	lbL00074E(PC),D0
	bsr.w	PokeAdr
	move.w	lbL000752(PC),D0
	bsr.w	PokeLen

lbC000150

	lea	16(A1),A1

	TST.B	$1A(A5)
	BEQ.S	lbC00016A
	CLR.B	$1A(A5)
;	MOVE.L	lbL0007AA(PC),$DFF0C0		; jak wyzej dla 2
;	MOVE.W	lbL0007AE(PC),$DFF0C4		; 2

	move.l	lbL0007AA(PC),D0
	bsr.w	PokeAdr
	move.w	lbL0007AE(PC),D0
	bsr.w	PokeLen

lbC00016A

	lea	16(A1),A1

	TST.B	$1B(A5)
	BEQ.S	lbC000184
	CLR.B	$1B(A5)
;	MOVE.L	lbL000806(PC),$DFF0D0		; 3
;	MOVE.W	lbL00080A(PC),$DFF0D4		; 3

	move.l	lbL000806(PC),D0
	bsr.w	PokeAdr
	move.w	lbL00080A(PC),D0
	bsr.w	PokeLen

lbC000184	MOVEM.L	(A7)+,D0/A5
lbC000188
;	MOVE.W	#8,$DFF09C			; przerwanie PORTS zakonczone
;	RTE

	rts

; to wyglada na end song

End
lbC000192	MOVE.L	A5,-(A7)
	LEA	lbL0006C2(PC),A5
	CLR.B	0(A5)
;	TST.B	$17(A5)
;	BEQ.S	lbC0001BC
;	CLR.B	$17(A5)
;	MOVE.W	#8,$DFF09A		; wylacza przerwania PORTS
;	MOVE.L	$20(A5),$68		; przywraca stary wektor przerwan PORTS
;	MOVE.W	#$8008,$DFF09A		; wlacza przerwania PORTS
;lbC0001BC	MOVE.W	#15,$DFF096	; wylacza DMA kanalow dzwiekowych
;	CLR.W	$DFF0A8			; zeruje glosnosc kanalu 0
;	CLR.W	$DFF0B8
;	CLR.W	$DFF0C8
;	CLR.W	$DFF0D8

	movem.l	D0/D1/A1,-(SP)
	moveq	#15,D0
	bsr.w	PokeDMA
	moveq	#3,D1
	lea	$DFF0A0,A1
	moveq	#0,D0
ClearVol
	bsr.w	PokeVol
	lea	16(A1),A1
	dbf	D1,ClearVol
	movem.l	(SP)+,D0/D1/A1

	MOVEA.L	(A7)+,A5
	RTS

Play_1
;	BSET	#1,$BFE001		; wylacza filtry dzwiekowe
	MOVE.L	A5,-(A7)
	LEA	lbL0006C2(PC),A5
	TST.B	0(A5)
	BEQ.S	lbC0001F6
	BSR.S	lbC0001FA
lbC0001F6	MOVEA.L	(A7)+,A5
	RTS

lbC0001FA	MOVEM.L	D0-D7/A0-A6,-(A7)
	SUBQ.B	#1,1(A5)
	BPL.S	lbC000206
	BSR.S	lbC000254
lbC000206	MOVE.B	$16(A5),D7
	ADDQ.W	#1,D7
	CMP.B	#3,D7
	BNE.S	lbC000214
	MOVEQ	#0,D7
lbC000214	MOVE.B	D7,$16(A5)
	MOVEA.L	$10(A5),A0
	LEA	lbL0006F2(PC),A2
	LEA	$DFF0A0,A1
	BSR.W	lbC000464
	LEA	lbL00074E(PC),A2
	LEA	$10(A1),A1
	BSR.W	lbC000464
	LEA	lbL0007AA(PC),A2
	LEA	$10(A1),A1
	BSR.W	lbC000464
	LEA	lbL000806(PC),A2
	LEA	$10(A1),A1
	BSR.W	lbC000464
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS

lbC000254	MOVEA.L	12(A5),A0
	MOVE.L	A0,$10(A5)
	LEA	lbL000862(PC),A4
	MOVEQ	#1,D7
	LEA	$DFF0A0,A1
	LEA	lbL0006F2(PC),A2
	BSR.W	lbC0002F2
	MOVE.B	D6,$18(A5)
	LEA	$10(A1),A1
	LEA	lbL00074E(PC),A2
	BSR.S	lbC0002F2
	MOVE.B	D6,$19(A5)
	LEA	$10(A1),A1
	LEA	lbL0007AA(PC),A2
	BSR.S	lbC0002F2
	MOVE.B	D6,$1A(A5)
	LEA	$10(A1),A1
	LEA	lbL000806(PC),A2
	BSR.S	lbC0002F2
	MOVE.B	D6,$1B(A5)

;	MOVE.B	#5,$BFE501		; nowa wartosc dla zegara A (starszy bajt zegara)

SetPosition
	ADDQ.B	#1,3(A5)
	ANDI.B	#$3F,3(A5)
	BNE.S	lbC0002E6
	MOVEA.L	$28(A5),A2
	MOVE.W	4(A5),D0
	ADDQ.W	#2,D0
	CMP.W	8(A5),D0
	BNE.S	lbC0002D2

	bsr.w	SongEnd

	MOVE.W	10(A5),D0
	CMP.W	#$FFFF,D0		; sprawdzanie czy koniec modulu
	BNE.S	lbC0002D2

	bsr.w	SongEnd

	BSR.W	lbC000192		; koniec modulu

	BRA.S	lbC0002E6

lbC0002D2	MOVE.W	D0,4(A5)
	MOVEQ	#0,D1
	MOVE.W	0(A2,D0.W),D1
	ASL.L	#8,D1
	ASL.L	#2,D1
	ADD.L	$2C(A5),D1
	MOVEA.L	D1,A0
lbC0002E6	MOVE.L	A0,12(A5)
	MOVE.B	2(A5),1(A5)

	bsr.w	PATINFO

	RTS

lbC0002F2	MOVEQ	#0,D6
	MOVEQ	#0,D1
	MOVEQ	#0,D0
	MOVEQ	#0,D3
	MOVE.B	(A0)+,D0
	MOVE.B	(A0)+,D1
	MOVE.B	(A0)+,D2
	MOVE.B	(A0)+,D3
	TST.B	D0
	beq.w	lbC00042C
	TST.B	D2
	BMI.w	lbC000418
	CMP.B	#3,D2
	BNE.S	lbC000338
	SUBQ.W	#1,D0
	ADD.W	D0,D0
	MOVE.W	0(A4,D0.W),D0
	MOVE.W	D0,12(A2)
	CMP.W	6(A2),D0
	BPL.S	lbC00032E
	MOVE.W	D3,10(A2)
	BRA.W	lbC000460

lbC00032E	NEG.W	D3
	MOVE.W	D3,10(A2)
	BRA.W	lbC000460

lbC000338
;	MOVE.W	D7,$DFF096

	move.l	D0,-(SP)
	move.w	D7,D0
	bsr.w	PokeDMA
	move.l	(SP)+,D0

	OR.W	D7,$14(A5)
	ASL.W	#6,D1
	ADD.L	$24(A5),D1
	MOVEA.L	D1,A3
	MOVE.L	$16(A3),$22(A2)
	MOVE.L	$1A(A3),$26(A2)
	MOVE.L	$1E(A3),$2A(A2)
	MOVE.B	#1,$21(A2)
	MOVE.L	14(A3),$16(A2)
	MOVE.L	$12(A3),$1A(A2)
	TST.B	14(A3)
	BEQ.S	lbC0003C0
	CLR.B	$20(A2)
	MOVE.B	$19(A2),$1F(A2)
	MOVE.B	$1A(A2),$1E(A2)
	LEA	lbL0009AC,A6				; was PC
	MOVE.W	4(A3),D1
;	MOVE.W	D1,4(A1)

	move.l	D0,-(SP)
	move.l	D1,D0
	bsr.w	PokeLen
	move.l	(SP)+,D0

	ADD.W	D1,D1
	SUBA.W	D1,A6
	MOVE.L	A6,0(A2)
	MOVEQ	#0,D1
	MOVE.B	15(A3),D1
	ADDA.W	D1,A6

;	MOVE.L	A6,(A1)

	move.l	D0,-(SP)
	move.l	A6,D0
	bsr.w	PokeAdr
	move.l	(SP)+,D0

	CMP.B	#12,D2
	BNE.S	lbC0003B2
;	MOVE.W	D3,8(A1)

	move.l	D0,-(A7)
	move.l	D3,D0
	bsr.w	PokeVol
	move.l	(A7)+,D0

	MOVE.W	D3,14(A2)
	BRA.w	lbC000412

lbC0003B2	MOVE.W	12(A3),D4
;	MOVE.W	D4,8(A1)

	move.l	D0,-(A7)
	move.l	D4,D0
	bsr.w	PokeVol
	move.l	(A7)+,D0

	MOVE.W	D4,14(A2)
	BRA.S	lbC000412

lbC0003C0	MOVEQ	#1,D6
	MOVE.L	0(A3),D1
	MOVE.L	A5,-(A7)
;	LEA	PSA.MSG(PC),A5

	move.l	ModulePtr(PC),A5

	ADD.L	A5,D1
	MOVEA.L	(A7)+,A5
;	MOVE.L	D1,(A1)
;	MOVE.W	4(A3),4(A1)

	move.l	D0,-(SP)
	move.l	D1,D0
	bsr.w	PokeAdr
	move.w	4(A3),D0
	bsr.w	PokeLen
	move.l	(A7)+,D0

	CMP.B	#12,D2
	BNE.S	lbC0003E8
;	MOVE.W	D3,8(A1)

	move.l	D0,-(A7)
	move.l	D3,D0
	bsr.w	PokeVol
	move.l	(A7)+,D0

	MOVE.W	D3,14(A2)
	BRA.S	lbC0003F4

lbC0003E8	MOVE.W	12(A3),D4
;	MOVE.W	D4,8(A1)

	move.l	D0,-(A7)
	move.l	D4,D0
	bsr.w	PokeVol
	move.l	(A7)+,D0

	MOVE.W	D4,14(A2)
lbC0003F4	MOVE.L	6(A3),D1
	BNE.S	lbC000404
;	LEA	$1C(A5),A6
;	MOVE.L	A6,0(A2)

	move.l	#Empty,(A2)

	BRA.S	lbC000412

lbC000404	MOVE.L	A5,-(A7)
;	LEA	PSA.MSG(PC),A5

	move.l	ModulePtr(PC),A5

	ADD.L	A5,D1
	MOVEA.L	(A7)+,A5
	MOVE.L	D1,0(A2)
lbC000412	MOVE.W	10(A3),4(A2)
lbC000418	SUBQ.W	#1,D0
	MOVE.W	D0,8(A2)
	ADD.W	D0,D0
	MOVE.W	0(A4,D0.W),D0
;	MOVE.W	D0,6(A1)

	bsr.w	PokePer

	MOVE.W	D0,6(A2)
lbC00042C	CMP.B	#5,D2
	BNE.S	lbC000438
	MOVE.B	#1,$29(A2)
lbC000438	CMP.B	#12,D2
	BNE.S	lbC000448
;	MOVE.W	D3,8(A1)

	move.l	D0,-(A7)
	move.l	D3,D0
	bsr.w	PokeVol
	move.l	(A7)+,D0

	MOVE.W	D3,14(A2)
	BRA.S	lbC000460

lbC000448	CMP.B	#13,D2
	BNE.S	lbC000456
	MOVE.B	#$3F,3(A5)
	BRA.S	lbC000460

lbC000456	CMP.B	#15,D2
	BNE.S	lbC000460
	MOVE.B	D3,2(A5)
lbC000460	ADD.W	D7,D7
	RTS

lbC000464	MOVEQ	#0,D1
	MOVE.B	2(A0),D0
	ANDI.B	#$7F,D0
	MOVE.B	3(A0),D1
	BEQ.S	lbC0004B6
	TST.B	D0
	BNE.S	lbC0004B6
	TST.B	D7
	BEQ.S	lbC0004AC
	LEA	lbL000862(PC),A3
	MOVE.W	8(A2),D2
	CMP.B	#2,D7
	BEQ.S	lbC00049A
	LSR.B	#4,D1
	ADD.W	D1,D2
	ADD.W	D2,D2
;	MOVE.W	0(A3,D2.W),6(A1)		; okres dla kanalu ?

	move.l	D0,-(SP)
	move.w	0(A3,D2.W),D0
	bsr.w	PokePer
	move.l	(SP)+,D0

	BRA.W	lbC0005D4

lbC00049A	ANDI.B	#15,D1
	ADD.W	D1,D2
	ADD.W	D2,D2
;	MOVE.W	0(A3,D2.W),6(A1)		; okres dla kanalu ?

	move.l	D0,-(SP)
	move.w	0(A3,D2.W),D0
	bsr.w	PokePer
	move.l	(SP)+,D0

	BRA.W	lbC0005D4

lbC0004AC	
	move.l	D0,-(SP)
	move.w	6(A2),D0
	bsr.w	PokePer
	move.l	(SP)+,D0

;	MOVE.W	6(A2),6(A1)		; okres dla kanalu ?
	BRA.W	lbC0005D4

lbC0004B6	CMP.B	#4,D0
	BNE.S	lbC000512
	MOVE.B	1(A5),D2
	CMP.B	2(A5),D2
	BNE.S	lbC0004E8
	TST.B	D1
	BEQ.S	lbC0004E8
	MOVEQ	#0,D2
	MOVE.B	D1,D2
	LSR.B	#4,D2
	MOVE.W	D2,$10(A2)
	MOVE.B	D1,D2
	ANDI.B	#15,D2
	MOVE.B	D2,$14(A2)
	ADD.B	D2,D2
	MOVE.B	D2,$15(A2)
	CLR.W	$12(A2)
lbC0004E8	MOVE.W	$12(A2),D2
	ADD.W	$10(A2),D2
	MOVE.W	D2,$12(A2)
	ADD.W	6(A2),D2
;	MOVE.W	D2,6(A1)			; okres dla kanalu ?

	move.l	D0,-(SP)
	move.l	D2,D0
	bsr.w	PokePer
	move.l	(SP)+,D0

	SUBQ.B	#1,$14(A2)
	bne.w	lbC0005D4
	MOVE.B	$15(A2),$14(A2)
	NEG.W	$10(A2)
	BRA.W	lbC0005D4

lbC000512
	move.l	D0,-(SP)
	move.w	6(A2),D0
	bsr.w	PokePer
	move.l	(SP)+,D0

;	MOVE.W	6(A2),6(A1)		; okres dla kanalu ?
	CMP.B	#10,D0
	BNE.S	lbC000556
	TST.B	D1
	BMI.S	lbC00053E
	MOVE.W	14(A2),D2
	ADD.W	D1,D2
	CMP.B	#$40,D2
	BMI.S	lbC000532
	MOVE.B	#$40,D2
lbC000532
;	MOVE.W	D2,8(A1)		; glosnosc dla kanalu ?

	move.l	D0,-(A7)
	move.l	D2,D0
	bsr.w	PokeVol
	move.l	(A7)+,D0

	MOVE.W	D2,14(A2)
	BRA.W	lbC0005D4

lbC00053E	ANDI.W	#$7F,D1
	MOVE.W	14(A2),D2
	SUB.W	D1,D2
	BPL.S	lbC00054C
	MOVEQ	#0,D2
lbC00054C
;	MOVE.W	D2,8(A1)		; glosnosc dla kanalu ?

	move.l	D0,-(A7)
	move.l	D2,D0
	bsr.w	PokeVol
	move.l	(A7)+,D0

	MOVE.W	D2,14(A2)
	BRA.w	lbC0005D4

lbC000556	CMP.B	#1,D0
	BNE.S	lbC00056C
	MOVE.W	6(A2),D2
	SUB.W	D1,D2
;	MOVE.W	D2,6(A1)			; okres dla kanalu ?

	move.l	D0,-(SP)
	move.l	D2,D0
	bsr.w	PokePer
	move.l	(SP)+,D0

	MOVE.W	D2,6(A2)
	BRA.S	lbC0005D4

lbC00056C	CMP.B	#2,D0
	BNE.S	lbC000582
	MOVE.W	6(A2),D2
	ADD.W	D1,D2
;	MOVE.W	D2,6(A1)			; okres ?

	move.l	D0,-(SP)
	move.l	D2,D0
	bsr.w	PokePer
	move.l	(SP)+,D0

	MOVE.W	D2,6(A2)
	BRA.S	lbC0005D4

lbC000582	CMP.B	#3,D0
	BNE.S	lbC0005D4
	MOVE.W	10(A2),D1
	BEQ.S	lbC0005D4
	BMI.S	lbC0005AE
	MOVE.W	6(A2),D0
	SUB.W	D1,D0
	CMP.W	12(A2),D0
	BPL.S	lbC0005CC
;	MOVE.W	12(A2),6(A1)			; okres

	move.l	D0,-(SP)
	move.w	12(A2),D0
	bsr.w	PokePer
	move.l	(SP)+,D0

	MOVE.W	12(A2),6(A2)
	CLR.W	10(A2)
	BRA.S	lbC0005D4

lbC0005AE	MOVE.W	6(A2),D0
	SUB.W	D1,D0
	CMP.W	12(A2),D0
	BMI.S	lbC0005CC
;	MOVE.W	12(A2),6(A1)			; okres

	move.l	D0,-(SP)
	move.w	12(A2),D0
	bsr.w	PokePer
	move.l	(SP)+,D0

	MOVE.W	12(A2),6(A2)
	CLR.W	10(A2)
	BRA.S	lbC0005D4

lbC0005CC	
;	MOVE.W	D0,6(A1)		; okres

	bsr.w	PokePer

	MOVE.W	D0,6(A2)
lbC0005D4	TST.B	$16(A2)
	BEQ.S	lbC00062E
	SUBQ.B	#1,$1F(A2)
	BNE.S	lbC00062E
	MOVEQ	#0,D2
	MOVE.B	$17(A2),D2
	TST.B	$20(A2)
	BNE.S	lbC000608
	MOVE.B	$19(A2),$1F(A2)
	ADD.B	$18(A2),D2
	SUBQ.B	#1,$1E(A2)
	BNE.S	lbC000622
	MOVE.B	$1D(A2),$1E(A2)
	NOT.B	$20(A2)
	BRA.S	lbC000622

lbC000608	MOVE.B	$1C(A2),$1F(A2)
	SUB.B	$1B(A2),D2
	SUBQ.B	#1,$1E(A2)
	BNE.S	lbC000622
	MOVE.B	$1A(A2),$1E(A2)
	NOT.B	$20(A2)
lbC000622	MOVE.B	D2,$17(A2)
	MOVEA.L	0(A2),A6
	ADDA.W	D2,A6
;	MOVE.L	A6,(A1)				; adres poczatku sampla dla kanalu ?

	move.l	D0,-(SP)
	move.l	A6,D0
	bsr.w	PokeAdr
	move.l	(SP)+,D0

lbC00062E	MOVE.B	$22(A2),D2
	beq.w	lbC0006BE
	SUBQ.B	#1,$21(A2)
	bne.w	lbC0006BE
	MOVE.W	14(A2),D0
	CMP.B	#1,D2
	BEQ.S	lbC00066C
	CMP.B	#2,D2
	BEQ.S	lbC000682
	CMP.B	#3,D2
	BEQ.S	lbC000698
	MOVE.B	$2B(A2),$21(A2)
	SUB.B	$2A(A2),D0
	SUBQ.B	#1,$2C(A2)
	BNE.S	lbC0006B0
	MOVE.B	#0,$22(A2)
	BRA.S	lbC0006B0

lbC00066C	MOVE.B	$24(A2),$21(A2)
	ADD.B	$23(A2),D0
	SUBQ.B	#1,$25(A2)
	BNE.S	lbC0006B0
	ADDQ.B	#1,$22(A2)
	BRA.S	lbC0006B0

lbC000682	MOVE.B	$27(A2),$21(A2)
	SUB.B	$26(A2),D0
	SUBQ.B	#1,$28(A2)
	BNE.S	lbC0006B0
	ADDQ.B	#1,$22(A2)
	BRA.S	lbC0006B0

lbC000698	MOVE.B	#1,$21(A2)
	TST.B	$29(A2)
	BEQ.S	lbC0006BE
	SUBQ.B	#1,$29(A2)
	BNE.S	lbC0006BE
	ADDQ.B	#1,$22(A2)
	BRA.S	lbC0006BE

lbC0006B0	TST.B	D0
	BPL.S	lbC0006B6
	MOVEQ	#0,D0
lbC0006B6	MOVE.W	D0,14(A2)
;	MOVE.W	D0,8(A1)			; glosnosc dla kanalu ?

	bsr.w	PokeVol

lbC0006BE	ADDQ.W	#4,A0
	RTS

lbL0006C2	dc.w	0
SongSpeed
	dc.b	0
StepPos
	dc.b	0
CurrentPos
	dc.w	0
	dc.w	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
SampleInfoOffset
	dc.l	0
PositionOffset
	dc.l	0
PatternOffset
	dc.l	0
lbL0006F2	dc.l	0
lbL0006F6	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
lbL00074E	dc.l	0
lbL000752	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
lbL0007AA	dc.l	0
lbL0007AE	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
lbL000806	dc.l	0
lbL00080A	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
lbL000862	dc.l	$3580328,$2FA02D0,$2A60280,$25C023A,$21A01FC
	dc.l	$1E001C5,$1AC0194,$17D0168,$1530140,$12E011D
	dc.l	$10D00FE,$F000E2,$D600CA,$BE00B4,$AA00A0,$97008F
	dc.l	$87007F,$780071
	dc.w	$6B

	Section	Data,Data_C

	dc.w	$8080
	dc.l	$80808080,$80808080
	dc.l	$80808080,$80808080,$80808080,$80808080,$80808080
	dc.l	$80808080,$80808080,$80808080,$80808080,$80808080
	dc.l	$80808080,$80808080,$80808080,$80808080,$80808080
	dc.l	$80808080,$80808080,$80808080,$80808080,$80808080
	dc.l	$80808080,$80808080,$80808080,$80808080,$80808080
	dc.l	$80808080,$80808080,$80808080,$80808080,$80808080
	dc.l	$80808080,$80808080,$80808080,$80808080,$80808080
	dc.l	$80808080,$80808080,$80808080,$80808080,$80808080
	dc.l	$80808080,$80808080,$80808080,$80808080,$80808080
	dc.l	$80808080,$80808080,$80808080,$80808080,$80808080
	dc.l	$80808080,$80808080,$80808080,$80808080,$80808080
	dc.l	$80808080,$80808080,$80808080,$80808080,$80808080
	dc.l	$80808080
	dc.w	$8080
lbL0009AC	dc.l	$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F
	dc.l	$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F
	dc.l	$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F
	dc.l	$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F
	dc.l	$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F
	dc.l	$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F
	dc.l	$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F
	dc.l	$7F7F7F7F
	dc.l	$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F
	dc.l	$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F
	dc.l	$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F
	dc.l	$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F
	dc.l	$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F
	dc.l	$7F7F7F7F,$7F7F7F7F,$7F7F7F7F
;	PSA.MSG	dc.b	'PSA',0
Empty
	ds.b	4

	******************************************************
	****      Digital Sound Studio replayer for       ****
	****    EaglePlayer 2.00+ (Amplifier version),    ****
	****         all adaptions by Wanted Team	  ****
	******************************************************

	incdir	"dh2:include/"
	include 'misc/eagleplayer2.01.i'
	include	'misc/eagleplayerengine.i'
	include	'exec/exec_lib.i'

	SECTION	Player,CODE

	EPPHEADER Tags

	dc.b	'$VER: Digital Sound Studio 1.0-3.0 player module V2.0 (15 June 2002)',0
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
	dc.b	'Digital Sound Studio',0
Creator
	dc.b	'(c) 1991-94 by CIS,',10
	dc.b	'adapted by Wanted Team',0
Prefix
	dc.b	'DSS.',0
Text
	dc.b	'Loaded Digital Sound Studio v3.0 module !!!',0
	even
ModulePtr
	dc.l	0
SongValues
	dc.l	0
SamplesPtr
	dc.l	0
lbB0016AE
	dc.b	0
lbB0016AF
	dc.b	0
lbW001C42
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
	movem.l	D1/A5,-(SP)
	move.w	A1,D1		;DFF0A0/B0/C0/D0
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
	move.w	A1,D1		;DFF0A0/B0/C0/D0
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
	move.w	A1,D1		;DFF0A0/B0/C0/D0
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
	move.w	A1,D1		;DFF0A0/B0/C0/D0
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
	LEA	PATTERNINFO(PC),A0

	MOVE.W	#4,PI_Voices(A0)	; Number of stripes (MUST be at least 4)
	MOVE.L	#CONVERTNOTE,PI_Convert(A0)
	MOVEQ.L	#16,D0
	MOVE.L	D0,PI_Modulo(A0)	; Number of bytes to next row
	MOVE.W	#64,PI_Pattlength(A0)	; Length of each stripe in rows

	MOVE.W	InfoBuffer+Patterns+2(PC),PI_NumPatts(A0)	; Overall Number of Patterns
	CLR.W	PI_Pattern(A0)		; Current Pattern (from 0)
	CLR.W	PI_Pattpos(A0)		; Current Position in Pattern (from 0)
	CLR.W	PI_Songpos(A0)		; Current Position in Song (from 0)
	MOVE.W	InfoBuffer+Length+2(PC),PI_MaxSongPos(A0)	; Songlengh
	moveq	#125,D0
	move.w	D0,PI_BPM(A0)			; Beats Per Minute
	move.b	lbB0016AF(PC),PI_Speed+1(A0)	; Speed Value
	lea	STRIPE1(PC),A1
	clr.l	(A1)+
	clr.l	(A1)+
	clr.l	(A1)+
	clr.l	(A1)

	RTS

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
	move.b	(A0),D1
	lsr.b	#3,D1
	move.w	(A0),D0
	and.w	#$7FF,D0
	cmp.w	#$7FF,D0
	bne.b	VoiceOn
	moveq	#0,D0
VoiceOn
	move.b	2(A0),D2
	move.b	3(A0),D3
	rts

* Sets some current values for the PatternInfo structure.
* Call this every time something changes (or at least every interrupt).
* You can move these elsewhere if necessary, it is only important that
* you make sure the structure fields are accurate and updated regularly.
PATINFO:
	movem.l	D0/D1/A0/A1,-(SP)
	lea	PATTERNINFO(PC),A0
	moveq	#0,D0
	move.w	lbW000F42(PC),D0
	move.w	D0,PI_Songpos(A0)	; Position in Song
	move.l	ModulePtr(PC),A1
	lea	1438(A1),A1
	moveq	#0,D1
	move.b	(A1,D0.W),D1
	move.w	D1,PI_Pattern(A0)	; Current Pattern
	lea	128(A1),A1
	move.w	lbW000F44(PC),D0
	lsr.l	#4,D0
	move.w	D0,PI_Pattpos(A0)	; Current Position in Pattern
	moveq	#10,D0
	lsl.l	D0,D1
	add.l	D1,A1			; Current Pattern
	move.l	A1,PI_Stripes(A0)	; STRIPE1
	addq.l	#4,A1			; Distance to next stripe
	move.l	A1,PI_Stripes+4(A0)	; STRIPE2
	addq.l	#4,A1
	move.l	A1,PI_Stripes+8(A0)	; STRIPE3
	addq.l	#4,A1
	move.l	A1,PI_Stripes+12(A0)	; STRIPE4

* You could move this part into the SpeedChange command for example

	move.b	lbB0016AF(PC),PI_Speed+1(A0)	; Speed Value
	move.b	lbB0016AE(PC),D0
	beq.b	exit
	move.b	D0,PI_BPM+1(A0)			; Beats Per Minute
exit
	movem.l	(SP)+,D0/D1/A0/A1
	RTS

***************************************************************************
******************************* DTP_NextPatt ******************************
***************************************************************************

Next_Pattern
	lea	lbW000F42(PC),A0
	move.w	(A0),D0
	addq.w	#1,D0
	cmp.w	InfoBuffer+Length+2(PC),D0
	beq.b	MaxPos
	move.w	D0,(A0)+
	clr.w	(A0)
MaxPos
	rts

***************************************************************************
******************************* DTP_BackPatt ******************************
***************************************************************************

BackPattern
	lea	lbW000F42(PC),A0
	move.w	(A0),D0
	beq.b	MinPos
	subq.w	#1,D0
	move.w	D0,(A0)+
	clr.w	(A0)
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

	moveq	#0,D0
	move.w	34(A2),D0
	cmp.w	#1,40(A2)
	beq.b	Normal
	moveq	#0,D1
	move.w	40(A2),D1
	add.l	D1,D0
Normal
	add.l	D0,D0
	move.l	A1,EPS_Adr(A3)			; sample address
	move.l	D0,EPS_Length(A3)		; sample length
	move.l	#64,EPS_Volume(A3)
	move.l	A2,EPS_SampleName(A3)		; sample name
	move.w	#USITY_RAW,EPS_Type(A3)
	move.w	#30,EPS_MaxNameLen(A3)
	move.w	#USIB_Playable!USIB_Saveable!USIB_8BIT,EPS_Flags(A3)
	lea	46(A2),A2
	add.l	D0,A1
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
Author		=	60
Special		=	68

InfoBuffer
	dc.l	MI_Pattern,0		;4
	dc.l	MI_LoadSize,0		;12
	dc.l	MI_Samples,0		;20
	dc.l	MI_Length,0		;28
	dc.l	MI_SamplesSize,0	;36
	dc.l	MI_Songsize,0		;44
	dc.l	MI_Calcsize,0		;52
	dc.l	MI_AuthorName,0		;60
	dc.l	MI_SpecialInfo,0	;68
	dc.l	MI_MaxLength,128
	dc.l	MI_MaxSamples,31
	dc.l	MI_MaxPattern,128
	dc.l	MI_Prefix,Prefix
	dc.l	0

***************************************************************************
******************************** EP_Check5 ********************************
***************************************************************************

Check5
	movea.l	dtg_ChkData(A5),A0
	moveq	#-1,D0

	cmp.l	#'MMU2',(A0)+
	bne.b	Fault
	tst.b	(A0)
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
	move.w	8(A0),(A6)+			; timer and song speed
	move.w	1436(A0),D0
	move.w	D0,(A6)+			; song length
	move.w	D0,Length+2(A4)

	move.l	A0,A1
	move.l	A0,-(SP)
	bsr.w	Init_Player
	move.l	A0,A2
	move.l	(SP)+,A0

	sub.l	A0,A2
	cmp.l	LoadSize(A4),A2
	ble.b	SizeOK
	moveq	#EPR_ModuleTooShort,D0
	rts
SizeOK
	move.l	A2,CalcSize(A4)
	move.l	D3,(A6)				; Samples Ptr
	sub.l	A0,D3
	move.l	D3,SongSize(A4)
	sub.l	D3,A2
	move.l	A2,SamplesSize(A4)
	move.l	D4,Samples(A4)

	clr.l	Special(A4)
	tst.b	8(A0)
	beq.b	NoV3
	lea	Text(PC),A1
	move.l	A1,Special(A4)
NoV3
	bsr.b	FindName

	bsr.w	Init_Clear

	moveq	#0,D0
	rts

FindName
	lea	10(A0),A1			; A1 - begin sampleinfo
	move.l	A1,EPG_ARG1(A5)
	moveq	#46,D0				; D0 - length per one sampleinfo
	move.l	D0,EPG_ARG2(A5)
	moveq	#30,D0				; D0 - max. sample name
	move.l	D0,EPG_ARG3(A5)
	moveq	#31,D0				; D0 - max. samples number
	move.l	D0,EPG_ARG4(A5)
	moveq	#4,D0
	move.l	D0,EPG_ARGN(A5)
	jsr	ENPP_FindAuthor(A5)
	move.l	EPG_ARG1(A5),Author(A4)		; output
	rts

***************************************************************************
********************************* EP_GetPosNr *****************************
***************************************************************************

GetPosition
	moveq	#0,D0
	move.w	lbW000F42(PC),D0
	rts

***************************************************************************
***************************** DTP_InitSound *******************************
***************************************************************************

InitSound
	move.l	SongValues(PC),lbB0016AE
	lea	lbB000F40(PC),A0
	lea	lbW000F52(PC),A1
Clear
	clr.w	(A0)+
	cmp.l	A0,A1
	bne.b	Clear
	move.w	#3,(A0)
	bra.w	Init_Speed

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
***************************** DSS Tracker Player **************************
***************************************************************************

; Player from DSS 3.0 demo song called "Guitar Time" (c) 1994 by CIS

;	MOVEM.L	D1-D7/A0-A6,-(SP)
;	MOVEA.L	4,A6
;	SUBA.L	A1,A1
;	JSR	-$126(A6)
;	MOVE.L	D0,lbL000DEA
;	MOVEA.L	D0,A4
;	TST.L	$AC(A4)
;	BNE.S	lbC000034
;	LEA	$5C(A4),A0
;	JSR	-$180(A6)
;	LEA	$5C(A4),A0
;	JSR	-$174(A6)
;	MOVE.L	D0,lbL000DD4
;lbC000034	LEA	graphicslibra.MSG,A1
;	MOVEQ	#0,D0
;	JSR	-$228(A6)
;	MOVE.L	D0,lbL000DD8
;	BEQ.L	lbC0001EC
;	LEA	intuitionlibr.MSG,A1
;	MOVEQ	#0,D0
;	JSR	-$228(A6)
;	MOVE.L	D0,lbL000DDC
;	BEQ.L	lbC0001DC
;	LEA	ciabresource.MSG,A1
;	MOVEQ	#0,D0
;	JSR	-$1F2(A6)
;	MOVE.L	D0,lbL000DE0
;	BEQ.L	lbC0001CC
;	CMPI.B	#$32,$213(A6)
;	BEQ.S	lbC000086
;	MOVE.W	#4,lbW000DE8
;lbC000086	MOVEA.L	4,A6
;	MOVE.L	#$15A,D0
;	MOVE.L	#$10000,D1
;	JSR	-$C6(A6)
;	TST.L	D0
;	BEQ.S	lbC000112
;	MOVEA.L	D0,A2
;	MOVEA.L	lbL000DDC,A6
;	MOVEA.L	A2,A0
;	MOVE.L	#$15A,D0
;	MOVEQ	#1,D1
;	SUBA.L	A1,A1
;	JSR	-$1AA(A6)
;	TST.L	D0
;	BEQ.S	lbC000100
;	MOVEQ	#0,D0
;	MOVEA.L	A2,A0
;	MOVEA.L	$28(A2),A0
;	MOVE.W	4(A0),D0
;	ADDQ.W	#3,D0
;	MOVE.W	D0,lbW000E1C
;	MOVEA.L	lbL000DD8,A6
;	MOVEA.L	A2,A1
;	ADDA.L	#$54,A1
;	LEA	GVPsDSS1994CI.MSG,A0
;	MOVEQ	#$14,D0
;	JSR	-$36(A6)
;	ADD.W	lbW000E1A,D0
;	CMPI.W	#$258,D0
;	BLE.S	lbC0000FA
;	MOVE.W	#$258,D0
;lbC0000FA	MOVE.W	D0,lbW000E1A
;lbC000100	MOVEA.L	4,A6
;	MOVEA.L	A2,A1
;	MOVE.L	#$15A,D0
;	JSR	-$D2(A6)
;lbC000112	MOVEA.L	lbL000DDC,A6
;	LEA	lbW000E16,A0
;	JSR	-$CC(A6)
;	MOVE.L	D0,lbL000DE4
;	BSR.L	lbC000238
;	BSR.L	lbC0002B0
;	BSR.L	lbC000C9E
;	TST.L	D0
;	BEQ.S	lbC000140
;	BSR.L	lbC0002CC
;	TST.L	D0
;	BEQ.S	lbC000146
;lbC000140	BSR.L	lbC000210
;	BEQ.S	lbC0001B0
;lbC000146	TST.L	lbL000DE4
;	BEQ.S	lbC000182
;	MOVEA.L	lbL000DE4,A0
;	MOVEA.L	$56(A0),A2
;lbC000158	MOVEA.L	4,A6
;	MOVEA.L	A2,A0
;	JSR	-$180(A6)
;	MOVEA.L	A2,A0
;	JSR	-$174(A6)
;	TST.L	D0
;	BEQ.S	lbC000158
;	MOVEA.L	D0,A1
;	MOVE.L	$14(A1),D2
;	JSR	-$17A(A6)
;	CMPI.L	#$200,D2
;	BEQ.S	lbC0001AC
;	BRA.S	lbC000158

;lbC000182	MOVEA.L	lbL000DD8,A6
;	JSR	-$10E(A6)
;	JSR	-$10E(A6)
;	JSR	-$10E(A6)
;	BTST	#6,$BFE001
;	BEQ.S	lbC0001A0
;	BRA.S	lbC0001AA

;lbC0001A0	BTST	#10,$DFF016
;	BEQ.S	lbC0001AC
;lbC0001AA	BRA.S	lbC000182

;lbC0001AC	BSR.L	lbC000334
;lbC0001B0	BSR.L	lbC000CEA
;	TST.L	lbL000DE4
;	BEQ.S	lbC0001CC
;	MOVEA.L	lbL000DDC,A6
;	MOVEA.L	lbL000DE4,A0
;	JSR	-$48(A6)
;lbC0001CC	MOVEA.L	4,A6
;	MOVEA.L	lbL000DDC,A1
;	JSR	-$19E(A6)
;lbC0001DC	MOVEA.L	4,A6
;	MOVEA.L	lbL000DD8,A1
;	JSR	-$19E(A6)
;lbC0001EC	TST.L	lbL000DD4
;	BEQ.S	lbC000208
;	MOVEA.L	4,A6
;	JSR	-$84(A6)
;	MOVEA.L	lbL000DD4,A1
;	JSR	-$17A(A6)
;lbC000208	MOVEQ	#0,D0
;	MOVEM.L	(SP)+,D1-D7/A0-A6
;	RTS

;lbC000210	MOVEA.L	lbL000DDC,A6
;	SUBA.L	A0,A0
;	LEA	lbW000DEE,A1
;	SUBA.L	A2,A2
;	LEA	lbW000E02,A3
;	MOVEQ	#0,D0
;	MOVEQ	#0,D1
;	MOVE.L	#$140,D2
;	MOVEQ	#$40,D3
;	JSR	-$15C(A6)
;	RTS

Init_Player
lbC000238
;	LEA	MMU2.MSG,A1
	MOVEA.L	A1,A0
	ADDA.L	#$59C,A0
	MOVE.W	(A0)+,D0
	SUBQ.W	#1,D0
	MOVEQ	#0,D1
	MOVE.L	D1,D2
lbC00024E	MOVE.B	(A0)+,D2
	CMP.B	D2,D1
	BHI.S	lbC000256
	MOVE.B	D2,D1
lbC000256	DBRA	D0,lbC00024E
	ADDQ.W	#1,D1

	move.l	D1,Patterns(A4)

	MOVEQ	#10,D0
	LSL.L	D0,D1
	MOVEA.L	A1,A0
	ADDA.L	#$61E,A0
	ADDA.L	D1,A0

	move.l	A0,D3
	moveq	#0,D4

	MOVEA.L	A1,A2
	ADDA.L	#10,A2
	LEA	lbL00161E(pc),A3
	MOVEQ	#$1E,D0
lbC00027A	MOVEQ	#0,D1
	MOVE.W	$22(A2),D1
;	BEQ.S	lbC0002A2

	beq.b	Fix

	addq.l	#1,D4

	MOVE.L	A0,(A3)
	MOVEQ	#0,D2
	CMPI.W	#1,$28(A2)
	BEQ.S	lbC000294
	MOVE.W	$28(A2),D2
	ADD.L	D2,D1
lbC000294	ADD.L	D1,D1
	BCLR	#0,$21(A2)
	ADD.L	$1E(A2),D1
	ADDA.L	D1,A0
lbC0002A2	ADDQ.L	#4,A3
	ADDA.L	#$2E,A2
	DBRA	D0,lbC00027A
	RTS

Fix
	clr.l	(A3)
	bra.b	lbC0002A2

Init_Clear
lbC0002B0	LEA	lbL00161E(pc),A0	; clearing sample beginning
	MOVEQ	#$1E,D0
lbC0002B8	MOVE.L	(A0)+,D1
	BEQ.S	lbC0002C6
	MOVEA.L	D1,A1
	MOVEQ	#3,D2
lbC0002C0	CLR.B	(A1)+
	DBRA	D2,lbC0002C0
lbC0002C6	DBRA	D0,lbC0002B8
	RTS

Init_Speed
;lbC0002CC	BSR.L	lbC000374		; set timer speed
;	MOVEA.L	lbL000DE0,A6
;	LEA	lbL000F28,A1
;	MOVEQ	#1,D0
;	JSR	-6(A6)
;	TST.L	D0
;	BNE.S	lbC000332
;	MOVE.B	$BFDF00,D0
;	ANDI.B	#$80,D0
;	ORI.B	#1,D0
;	MOVE.B	D0,$BFDF00
;	MOVE.B	#$82,$BFDD00
;	LEA	lbW00169E,A0
;	MOVE.W	lbW000DE8,D0
;	MOVE.L	0(A0,D0.W),D0
;	MOVE.L	D0,lbL00169A

	move.l	lbL00169A(PC),D0
	bne.b	TimerOK
	move.w	dtg_Timer(A5),D0
	mulu.w	#125,D0
	move.l	D0,lbL00169A
TimerOK
	MOVEQ	#0,D1
	MOVE.B	lbB0016AE(pc),D1

	beq.b	NormalSpeed

	DIVU.W	D1,D0

	move.w	D0,dtg_Timer(A5)
NormalSpeed

;	MOVE.B	D0,$BFD600
;	LSR.W	#8,D0
;	MOVE.B	D0,$BFD700
;	MOVEQ	#0,D0
lbC000332	RTS

;lbC000334	BSR.S	lbC000352
;	MOVEA.L	lbL000DE0,A6
;	LEA	lbL000F28,A1
;	MOVEQ	#1,D0
;	JSR	-12(A6)
;	BCLR	#1,$BFE001
;	RTS


;lbC000352	CLR.W	$DFF0A8
;	CLR.W	$DFF0B8
;	CLR.W	$DFF0C8
;	CLR.W	$DFF0D8
;	MOVE.W	#15,$DFF096
;	RTS

;lbC000374	CLR.W	$DFF0A8
;	CLR.W	$DFF0B8
;	CLR.W	$DFF0C8
;	CLR.W	$DFF0D8
;	RTS

;lbC00038E	MOVEM.L	D1-D7/A0-A6,-(SP)
;	BSR.S	lbC00039C
;	MOVEM.L	(SP)+,D1-D7/A0-A6
;	MOVEQ	#0,D0
;	RTS

Play
lbC00039C	MOVEQ	#0,D0
	MOVE.B	lbB0016AF(pc),D0
	ADDQ.W	#1,lbB000F40
	CMP.W	lbB000F40(pc),D0
	BNE.S	lbC0003CA
	CLR.W	lbB000F40
	CLR.W	lbW000F52
	MOVE.W	#3,lbW000F54
	BRA.L	lbC00071A

lbC0003CA	LEA	lbL000F56(pc),A0
	LEA	$DFF0A0,A1
	MOVEQ	#3,D3
lbC0003D8	MOVE.W	(A0),D0
	ANDI.W	#$7FF,D0
	CMPI.W	#$7FF,D0
	BEQ.S	lbC0003E6
	BSR.S	lbC0003F6
lbC0003E6	ADDA.L	#$22,A0
	ADDA.W	#$10,A1
	DBRA	D3,lbC0003D8
	RTS

lbC0003F6	MOVE.B	2(A0),D0
	TST.B	3(A0)
	BEQ.S	lbC00045C
	TST.B	D0
	BEQ.S	lbC000466
	CMPI.B	#1,D0
	BEQ.L	lbC0004C0
	CMPI.B	#2,D0
	BEQ.L	lbC0004DE
	CMPI.B	#14,D0
	BEQ.L	lbC000520
	CMPI.B	#15,D0
	BEQ.L	lbC00053A
	CMPI.B	#$12,D0
	BEQ.L	lbC00055E
	CMPI.B	#$13,D0
	BEQ.L	lbC00057A
	CMPI.B	#$16,D0
	BEQ.L	lbC0005C4
	CMPI.B	#$17,D0
	BEQ.L	lbC000626
	CMPI.B	#$18,D0
	BEQ.L	lbC00065C
	CMPI.B	#$1C,D0
	BEQ.L	lbC0006E4
	CMPI.B	#$1D,D0
	BEQ.L	lbC0006EA
lbC00045C	CMPI.B	#$1B,D0
	BEQ.L	lbC000680
	RTS

lbC000466	MOVEQ	#0,D2
	MOVE.W	lbW000F54(pc),D2
	SUB.W	lbB000F40(pc),D2
	BEQ.S	lbC0004B0
	CMPI.W	#1,D2
	BEQ.S	lbC000484
	MOVE.B	3(A0),D2
	LSR.B	#4,D2
	BRA.S	lbC00048C

lbC000484	MOVE.B	3(A0),D2
	ANDI.B	#15,D2
lbC00048C	ADD.W	D2,D2
	MOVE.W	$12(A0),D1
	BSR.S	lbC00050E
	MULU.W	#$18,D0
	LEA	lbW000FDE(pc),A3
	ADDA.L	D0,A3
lbC0004A0	MOVE.W	0(A3,D2.W),D0
	CMP.W	2(A2),D0
	BEQ.S	lbC0004BA
	CMP.W	(A3)+,D1
	BNE.S	lbC0004A0
	BRA.S	lbC0004BA

lbC0004B0	ADDQ.W	#3,lbW000F54
	MOVE.W	$12(A0),D0
lbC0004BA
;	MOVE.W	D0,6(A1)			;period

	bsr.w	PokePer

	RTS

lbC0004C0	BSR.S	lbC00050E
	MOVEQ	#0,D0
	MOVE.B	3(A0),D0
	SUB.W	D0,$12(A0)
	MOVE.W	$12(A0),D0
	CMP.W	2(A2),D0
	BGE.S	lbC0004FA
	MOVE.W	2(A2),$12(A0)
	BRA.S	lbC0004FA

lbC0004DE	BSR.S	lbC00050E
	MOVEQ	#0,D0
	MOVE.B	3(A0),D0
	ADD.W	D0,$12(A0)
	MOVE.W	$12(A0),D0
	CMP.W	0(A2),D0
	BLE.S	lbC0004FA
	MOVE.W	0(A2),$12(A0)
lbC0004FA	MOVE.W	$12(A0),D0
	TST.B	$16(A0)
	BEQ.S	lbC000508
	BSR.L	lbC0006F0
lbC000508
;	MOVE.W	D0,6(A1)			;period

	bsr.w	PokePer

	RTS

lbC00050E	MOVEQ	#0,D0
	LEA	lbW0015DE(pc),A2
	MOVE.B	4(A0),D0
	LSL.W	#2,D0
	ADDA.L	D0,A2
	RTS

lbC000520	MOVEQ	#0,D0
	MOVE.B	3(A0),D0
lbC000526	ADD.B	D0,5(A0)
	CMPI.B	#$40,5(A0)
	BLE.S	lbC00054A
	MOVE.B	#$40,5(A0)
	BRA.S	lbC00054A

lbC00053A	MOVEQ	#0,D0
	MOVE.B	3(A0),D0
lbC000540	SUB.B	D0,5(A0)
	BGE.S	lbC00054A
	CLR.B	5(A0)
lbC00054A	MOVE.B	5(A0),D0
	SUB.W	lbB000F48(pc),D0
	BGE.S	lbC000558
	MOVEQ	#0,D0
lbC000558
;	MOVE.W	D0,8(A1)			; volume

	bsr.w	PokeVol

	RTS

lbC00055E	MOVEQ	#0,D0
	MOVE.B	3(A0),D0
lbC000564	SUB.W	D0,lbB000F48
	TST.W	lbB000F48
	BGE.S	lbC000598
	CLR.W	lbB000F48
	BRA.S	lbC000598

lbC00057A	MOVEQ	#0,D0
	MOVE.B	3(A0),D0
lbC000580	ADD.W	D0,lbB000F48
	CMPI.W	#$40,lbB000F48
	BLE.S	lbC000598
	MOVE.W	#$40,lbB000F48
lbC000598	MOVEQ	#0,D0
	MOVEM.L	A0/A1,-(SP)
	LEA	lbL000F56(pc),A0
	LEA	$DFF0A0,A1
	MOVEQ	#3,D1
lbC0005AC	BSR.S	lbC00054A
	ADDA.L	#$22,A0
	ADDA.L	#$10,A1
	DBRA	D1,lbC0005AC
	MOVEM.L	(SP)+,A0/A1
	RTS

lbC0005C4	MOVEQ	#0,D0
	MOVE.B	3(A0),D0
	CMP.B	lbB0016AF(pc),D0
	BGE.S	lbC000624
	TST.W	lbW000F52
	BNE.S	lbC0005E0
	MOVE.W	D0,lbW000F52
lbC0005E0	MOVE.W	lbB000F40(pc),D1
	CMP.W	lbW000F52(pc),D1
	BNE.S	lbC000624
	ADD.W	D0,lbW000F52
lbC0005F4	MOVE.W	$14(A0),D0
;	MOVE.W	D0,$DFF096
;	MOVE.L	6(A0),(A1)			; address
;	MOVE.W	10(A0),4(A1)			; length
;	BSR.L	lbC000834

	bsr.w	PokeDMA
	move.l	D0,-(SP)
	move.l	6(A0),D0
	bsr.w	PokeAdr
	move.w	10(A0),D0
	bsr.w	PokeLen
	move.l	(SP)+,D0

	ORI.W	#$8000,D0
;	MOVE.W	D0,$DFF096
;	BSR.L	lbC000834
;	MOVE.L	12(A0),(A1)			; address
;	MOVE.W	$10(A0),4(A1)			; length

	bsr.w	PokeDMA
	move.l	D0,-(SP)
	move.l	12(A0),D0
	bsr.w	PokeAdr
	move.w	$10(A0),D0
	bsr.w	PokeLen
	move.l	(SP)+,D0

lbC000624	RTS

lbC000626	MOVE.B	3(A0),D0
	CMP.B	lbB0016AF(pc),D0
	BLT.S	lbC000638
	CLR.W	2(A0)
	BRA.S	lbC00065A

lbC000638	CMP.B	lbB000F41(pc),D0
	BNE.S	lbC00065A
	MOVE.W	0(A0),D0
	BEQ.S	lbC00065A
	ANDI.W	#$7FF,D0
	BEQ.S	lbC0005F4
	BSR.L	lbC00087C
;	MOVE.W	D0,6(A1)			; period

	bsr.w	PokePer

	MOVE.W	D0,$12(A0)
	BRA.S	lbC0005F4			; bne.b ?

lbC00065A	RTS

lbC00065C	MOVE.B	3(A0),D0
	CMP.B	lbB0016AF(pc),D0
	BLT.S	lbC00066E
	CLR.W	2(A0)
	BRA.S	lbC00067E

lbC00066E	CMP.B	lbB000F41(pc),D0
	BNE.S	lbC00067E
	CLR.B	5(A0)
;	CLR.W	8(A1)				; volume

	move.l	D0,-(SP)
	moveq	#0,D0	
	bsr.w	PokeVol
	move.l	(SP)+,D0

lbC00067E	RTS

lbC000680	MOVE.B	3(A0),D0
	BEQ.S	lbC00068E
	MOVE.B	D0,$1F(A0)
	CLR.B	3(A0)
lbC00068E	TST.W	$20(A0)
	BEQ.S	lbC0006E2
	MOVEQ	#0,D0
	MOVE.B	$1F(A0),D0
	TST.B	$1E(A0)
	BNE.S	lbC0006BA
	ADD.W	D0,$12(A0)
	MOVE.W	$20(A0),D0
	CMP.W	$12(A0),D0
	BGT.S	lbC0006D2
	MOVE.W	$20(A0),$12(A0)
	CLR.W	$20(A0)
	BRA.S	lbC0006D2

lbC0006BA	SUB.W	D0,$12(A0)
	MOVE.W	$20(A0),D0
	CMP.W	$12(A0),D0
	BLT.S	lbC0006D2
	MOVE.W	$20(A0),$12(A0)
	CLR.W	$20(A0)
lbC0006D2	MOVE.W	$12(A0),D0
	TST.B	$17(A0)
	BEQ.S	lbC0006DE
	BSR.S	lbC0006F0
lbC0006DE
;	MOVE.W	D0,6(A1)			; period

	bsr.w	PokePer

lbC0006E2	RTS

lbC0006E4	BSR.S	lbC00068E
	BRA.L	lbC000520

lbC0006EA	BSR.S	lbC00068E
	BRA.L	lbC00053A

lbC0006F0	MOVEM.L	D1/A0,-(SP)
	MOVEQ	#0,D1
	MOVE.B	4(A0),D1
	LEA	lbW000FDE(pc),A0
	MULU.W	#$60,D1
	ADDA.L	D1,A0
	MOVEQ	#$2F,D1
lbC000708	CMP.W	(A0)+,D0
	BGE.S	lbC000710
	DBRA	D1,lbC000708
lbC000710	MOVE.W	-2(A0),D0
	MOVEM.L	(SP)+,D1/A0
	RTS

lbC00071A
;	LEA	lbW001CC4,A0
;	LEA	lbW001C44,A1

	move.l	ModulePtr(PC),A1
	lea	1566(A1),A0
	lea	1438(A1),A1

	MOVE.W	lbW000F42(pc),D0
	MOVE.W	D0,lbW000F4C
	MOVEQ	#0,D1
	MOVE.B	0(A1,D0.W),D1
	MOVEQ	#10,D0
	LSL.L	D0,D1
	MOVE.W	lbW000F44(pc),D0
	ADD.L	D0,D1
	CLR.W	lbW000F46
	LEA	$DFF0A0,A3
	LEA	lbL000F56(pc),A4
	MOVEQ	#3,D7
lbC000758	BSR.L	lbC0008D6
	ADDA.W	#$10,A3
	ADDA.L	#$22,A4
	DBRA	D7,lbC000758
	MOVE.W	lbW000F46(pc),D0
	ORI.W	#$8000,D0
;	MOVE.W	D0,$DFF096

	bsr.w	PokeDMA

;	BSR.L	lbC000834
	LEA	lbL000F56(pc),A0
	LEA	$DFF0A0,A1
	MOVEQ	#3,D0
lbC00078C	CMPI.B	#$17,2(A0)
	BEQ.S	lbC00079E
;	MOVE.L	12(A0),(A1)
;	MOVE.W	$10(A0),4(A1)

	move.l	D0,-(SP)
	move.l	12(A0),D0
	bsr.w	PokeAdr
	move.w	$10(A0),D0
	bsr.w	PokeLen
	move.l	(SP)+,D0

lbC00079E	ADDA.L	#$22,A0
	ADDA.W	#$10,A1
	DBRA	D0,lbC00078C
	TST.W	lbW000F4E
	BEQ.S	lbC0007C4
	MOVE.W	lbW000F50(pc),lbW000F44
	CLR.W	lbW000F4E
lbC0007C4	ADDI.W	#$10,lbW000F44
	CMPI.W	#$400,lbW000F44
	BLT.S	lbC000822
lbC0007D6	CLR.W	lbW000F44
	MOVE.W	#$FFFF,lbW000F6E
	MOVE.W	#$FFFF,lbW000F90
	MOVE.W	#$FFFF,lbW000FB2
	MOVE.W	#$FFFF,lbW000FD4
	MOVE.W	lbW000F4C(pc),lbW000F42
	ADDQ.W	#1,lbW000F42
	MOVE.W	lbW001C42(pc),D0
	MOVE.W	lbW000F42(pc),D1
	CMP.W	D0,D1
	BNE.S	lbC000822
	CLR.W	lbW000F42

	bsr.w	SongEnd

lbC000822	TST.W	lbW000F4A
	BEQ.S	lbC000832
	CLR.W	lbW000F4A
	BRA.S	lbC0007D6

lbC000832
	bsr.w	PATINFO

	RTS

;lbC000834	MOVEM.L	D0/D1,-(SP)
;	MOVE.B	$BFDE00,D1
;	MOVE.B	D1,D0
;	ANDI.B	#$C0,D0
;	ORI.B	#8,D0
;	MOVE.B	D0,$BFDE00
;	MOVE.B	#$2F,$BFD400
;	MOVE.B	#1,$BFD500
;lbC00085E	BTST	#0,$BFDE00
;	BNE.S	lbC00085E
;	MOVE.B	D1,$BFDE00
;	MOVE.B	#1,$BFDD00
;	MOVEM.L	(SP)+,D0/D1
;	RTS

lbC00087C	MOVEM.L	D1/D2/A0,-(SP)
	MOVEQ	#0,D1
	MOVE.B	4(A0),D1
	BEQ.S	lbC0008A0
	LEA	lbW000FDE(pc),A0
	MOVEQ	#$2F,D2
lbC000890	CMP.W	(A0)+,D0
	BEQ.S	lbC000898
	DBRA	D2,lbC000890
lbC000898	MULU.W	#$60,D1
	MOVE.W	-2(A0,D1.W),D0
lbC0008A0	MOVEM.L	(SP)+,D1/D2/A0
	RTS

lbC0008A6	MOVEM.L	D0/A0,-(SP)
	MOVE.W	D6,D0
	MOVEA.L	A4,A0
	BSR.S	lbC00087C
	MOVE.W	D0,$20(A4)
	CLR.B	$1E(A4)
	MOVE.W	$20(A4),D0
	CMP.W	$12(A4),D0
	BEQ.S	lbC0008CC
	BGE.S	lbC0008D0
	MOVE.B	#1,$1E(A4)
	BRA.S	lbC0008D0

lbC0008CC	CLR.W	$20(A4)
lbC0008D0	MOVEM.L	(SP)+,D0/A0
	RTS

lbC0008D6
;	LEA	Instrument1.MSG,A2

	move.l	ModulePtr(PC),A2
	lea	10(A2),A2

	MOVE.L	0(A0,D1.L),0(A4)
	ADDQ.L	#4,D1
	MOVEQ	#0,D0
	MOVE.B	0(A4),D0
	LSR.B	#3,D0
	TST.B	D0
	BEQ.S	lbC000932
	LEA	lbL00161E(pc),A5
	SUBQ.B	#1,D0
	MOVE.L	D0,D3
	LSL.W	#2,D0
	MULU.W	#$2E,D3
	ADDI.L	#$1E,D3
	ADDA.L	D3,A2
	MOVE.L	0(A5,D0.W),D4
	ADD.L	(A2)+,D4
	MOVE.L	D4,6(A4)
	BEQ.S	lbC000932
	MOVE.W	(A2)+,10(A4)
	MOVE.L	(A2)+,D5
	MOVE.W	(A2)+,D2
	BNE.S	lbC000922
	MOVEQ	#1,D2
	MOVEQ	#0,D5
lbC000922	MOVE.W	D2,$10(A4)
	ADD.L	6(A4),D5
	MOVE.L	D5,12(A4)
	MOVE.W	(A2),4(A4)
lbC000932	MOVE.W	0(A4),D6
	BEQ.L	lbC0009D2
	ANDI.W	#$7FF,D6
	BEQ.L	lbC0009D2
	CMPI.B	#$1B,2(A4)
	BEQ.S	lbC00095A
	CMPI.B	#$1C,2(A4)
	BEQ.S	lbC00095A
	CMPI.B	#$1D,2(A4)
	BNE.S	lbC000962
lbC00095A	BSR.L	lbC0008A6
	BRA.L	lbC000A68

lbC000962	MOVE.W	$14(A4),D0
;	MOVE.W	D0,$DFF096
;	BSR.L	lbC000834

	bsr.w	PokeDMA

	CMPI.W	#$7FF,D6
	BNE.S	lbC000982
;	CLR.W	8(A3)				; volume

	movem.l	D0/A1,-(SP)
	move.l	A3,A1
	moveq	#0,D0
	bsr.w	PokeVol
	movem.l	(SP)+,D0/A1

	OR.W	D0,lbW000F46
	RTS

lbC000982	CMPI.B	#$1A,2(A4)
	BNE.S	lbC000990
	BSR.L	lbC000C84
	BRA.S	lbC0009A6

lbC000990	CMPI.B	#$17,2(A4)
	BEQ.L	lbC000A68
	CMPI.B	#$19,2(A4)
	BNE.S	lbC0009A6
	BSR.L	lbC000C52
lbC0009A6
;	MOVE.L	6(A4),(A3)		; address

	movem.l	D0/A1,-(SP)
	move.l	A3,A1
	move.l	6(A4),D0
	bsr.w	PokeAdr
	movem.l	(SP)+,D0/A1
	tst.l	6(A4)

	BEQ.S	lbC0009D2
;	MOVE.W	10(A4),4(A3)			; length

	movem.l	D0/A1,-(SP)
	move.l	A3,A1
	move.w	10(A4),D0
	bsr.w	PokeLen
	movem.l	(SP)+,D0/A1

	MOVEM.L	D0/A0,-(SP)
	MOVE.W	D6,D0
	MOVEA.L	A4,A0
	BSR.L	lbC00087C
	MOVE.W	D0,D6
	MOVEM.L	(SP)+,D0/A0
;	MOVE.W	D6,6(A3)			; period

	movem.l	D0/A1,-(SP)
	move.l	A3,A1
	move.w	D6,D0
	bsr.w	PokePer
	movem.l	(SP)+,D0/A1

	MOVE.W	D6,$12(A4)
	OR.W	D0,lbW000F46
lbC0009D2	MOVE.B	2(A4),D0
	BEQ.L	lbC000A68
	CMPI.B	#4,D0
	BEQ.L	lbC000A82
	CMPI.B	#12,D0
	BEQ.L	lbC000B98
	CMPI.B	#13,D0
	BEQ.L	lbC000BB4
	CMPI.B	#$10,D0
	BEQ.L	lbC000BD0
	CMPI.B	#$11,D0
	BEQ.L	lbC000BEA
	BSR.S	lbC000A56
	CMPI.B	#5,D0
	BEQ.L	lbC000A94
	CMPI.B	#6,D0
	BEQ.L	lbC000AB6
	CMPI.B	#7,D0
	BEQ.L	lbC000AEC
	CMPI.B	#8,D0
	BEQ.L	lbC000B06
	CMPI.B	#9,D0
	BEQ.L	lbC000B2A
	CMPI.B	#10,D0
	BEQ.L	lbC000B4E
	CMPI.B	#11,D0
	BEQ.L	lbC000B56
	CMPI.B	#$14,D0
	BEQ.L	lbC000C04
	CMPI.B	#$15,D0
	BEQ.L	lbC000C14
	CMPI.B	#$1E,D0
	BEQ.L	lbC000C96
	RTS

lbC000A56	CMPI.B	#3,D0
	BNE.S	lbC000A68
	MOVEQ	#0,D2
	MOVE.B	3(A4),D2
	MOVE.B	D2,5(A4)
	BRA.S	lbC000A72

lbC000A68	TST.W	D6
	BEQ.S	lbC000A80
	MOVEQ	#0,D2
	MOVE.B	5(A4),D2
lbC000A72	SUB.W	lbB000F48(pc),D2
	BGE.S	lbC000A7C
	MOVEQ	#0,D2
lbC000A7C
;	MOVE.W	D2,8(A3)			; volume

	movem.l	D0/A1,-(SP)
	move.l	A3,A1
	move.w	D2,D0
	bsr.w	PokeVol
	movem.l	(SP)+,D0/A1

lbC000A80	RTS

lbC000A82	MOVEQ	#$40,D2
	MOVE.B	3(A4),D0
	SUB.B	D0,D2
	BLT.S	lbC000A92
	MOVE.B	D2,lbB000F49
lbC000A92	BRA.S	lbC000A68

lbC000A94	MOVE.B	3(A4),D0
	BEQ.S	lbC000AB4
	CLR.W	lbB000F40
	CLR.W	lbW000F52
	MOVE.W	#3,lbW000F54
	MOVE.B	D0,lbB0016AF
lbC000AB4	RTS

lbC000AB6	MOVEQ	#0,D0
	MOVE.B	3(A4),D0
	CMPI.W	#$FF,D0
	BEQ.S	lbC000AD8
	CMP.W	lbW001C42(pc),D0
	BGT.S	lbC000AEA
	TST.W	D0
	BEQ.S	lbC000AD8

	cmp.w	lbW000F42(PC),D0
	bgt.b	NoEnd
	bsr.w	SongEnd
NoEnd
	SUBQ.W	#2,D0
	MOVE.W	D0,lbW000F4C
	BRA.S	lbC000AE2

lbC000AD8	MOVE.W	lbW000F42(pc),lbW000F4C
lbC000AE2	MOVE.W	#1,lbW000F4A
lbC000AEA	RTS

lbC000AEC	MOVE.B	3(A4),D0
	BNE.S	lbC000AFC
;	BSET	#1,$BFE001

		bsr.w	LED_Off

	RTS

lbC000AFC
;	BCLR	#1,$BFE001

		bsr.w	LED_On

	RTS

lbC000B06	TST.B	3(A4)
	BEQ.S	lbC000B28
	MOVEM.L	A0-A2,-(SP)
	MOVEA.L	A4,A0
	MOVEA.L	A3,A1
	MOVE.W	$16(A0),-(SP)
	CLR.B	$16(A0)
	BSR.L	lbC0004C0
	MOVE.W	(SP)+,$16(A0)
	MOVEM.L	(SP)+,A0-A2
lbC000B28	RTS

lbC000B2A	TST.B	3(A4)
	BEQ.S	lbC000B4C
	MOVEM.L	A0-A2,-(SP)
	MOVEA.L	A4,A0
	MOVEA.L	A3,A1
	MOVE.W	$16(A0),-(SP)
	CLR.B	$16(A0)
	BSR.L	lbC0004DE
	MOVE.W	(SP)+,$16(A0)
	MOVEM.L	(SP)+,A0-A2
lbC000B4C	RTS

lbC000B4E	MOVE.B	3(A4),$16(A4)
	RTS

lbC000B56	MOVEQ	#0,D0
	MOVE.B	3(A4),D0
	CMPI.W	#$1C,D0
	BLT.S	lbC000B96
	MOVE.L	D1,-(SP)
	MOVE.B	D0,lbB0016AE
	MOVE.L	lbL00169A(pc),D1
	DIVU.W	D0,D1
;	MOVE.B	D1,$BFD600
;	LSR.W	#8,D1
;	MOVE.B	D1,$BFD700

	movem.l	A1/A5,-(SP)
	move.l	EagleBase(PC),A5
	move.w	D1,dtg_Timer(A5)
	move.l	dtg_SetTimer(A5),A1
	jsr	(A1)
	movem.l	(SP)+,A1/A5

	CLR.W	lbB000F40
	CLR.W	lbW000F52
	MOVE.W	#3,lbW000F54
	MOVE.L	(SP)+,D1
lbC000B96	RTS

lbC000B98	MOVEQ	#0,D0
	MOVE.B	3(A4),D0
	BEQ.S	lbC000BB0
	MOVEM.L	A0/A1,-(SP)
	MOVEA.L	A4,A0
	MOVEA.L	A3,A1
	BSR.L	lbC000526
	MOVEM.L	(SP)+,A0/A1
lbC000BB0	BRA.L	lbC000A68

lbC000BB4	MOVEQ	#0,D0
	MOVE.B	3(A4),D0
	BEQ.S	lbC000BCC
	MOVEM.L	A0/A1,-(SP)
	MOVEA.L	A4,A0
	MOVEA.L	A3,A1
	BSR.L	lbC000540
	MOVEM.L	(SP)+,A0/A1
lbC000BCC	BRA.L	lbC000A68

lbC000BD0	MOVEQ	#0,D0
	MOVE.B	3(A4),D0
	BEQ.S	lbC000BE6
	MOVEM.L	D1/A0,-(SP)
	MOVEA.L	A4,A0
	BSR.L	lbC000564
	MOVEM.L	(SP)+,D1/A0
lbC000BE6	BRA.L	lbC000A68

lbC000BEA	MOVEQ	#0,D0
	MOVE.B	3(A4),D0
	BEQ.S	lbC000C00
	MOVEM.L	D1/A0,-(SP)
	MOVEA.L	A4,A0
	BSR.L	lbC000580
	MOVEM.L	(SP)+,D1/A0
lbC000C00	BRA.L	lbC000A68

lbC000C04	TST.B	3(A4)
	BNE.S	lbC000C12
	MOVE.W	lbW000F44(pc),$18(A4)
lbC000C12	RTS

lbC000C14	MOVE.B	3(A4),D0
	BEQ.S	lbC000C4A
	TST.W	$18(A4)
	BMI.S	lbC000C50
	TST.B	$1A(A4)
	BNE.S	lbC000C2C
	MOVE.B	D0,$1A(A4)
	BRA.S	lbC000C32

lbC000C2C	SUBQ.B	#1,$1A(A4)
	BEQ.S	lbC000C4A
lbC000C32	MOVE.W	$18(A4),lbW000F50
	SUBI.W	#$10,lbW000F50
	MOVE.W	#1,lbW000F4E
lbC000C4A	MOVE.W	#$FFFF,$18(A4)
lbC000C50	RTS

lbC000C52	MOVE.L	D0,-(SP)
	MOVEQ	#0,D0
	MOVE.B	3(A4),D0
	BEQ.S	lbC000C62
	LSL.W	#7,D0
	MOVE.W	D0,$1C(A4)
lbC000C62	MOVE.W	$1C(A4),D0
	BEQ.S	lbC000C80
	CMP.W	10(A4),D0
	BGE.S	lbC000C7A
	SUB.W	D0,10(A4)
	ADD.W	D0,D0
	ADD.L	D0,6(A4)
	BRA.S	lbC000C80

lbC000C7A	MOVE.W	#1,10(A4)
lbC000C80	MOVE.L	(SP)+,D0
	RTS

lbC000C84	MOVE.L	D0,-(SP)
	MOVE.B	3(A4),D0
	ANDI.B	#15,D0
	MOVE.B	D0,4(A4)
	MOVE.L	(SP)+,D0
	RTS

lbC000C96	MOVE.B	3(A4),$17(A4)
	RTS

;lbC000C9E	MOVEM.L	D1-D7/A0-A6,-(SP)
;	LEA	DSSMP.MSG,A2
;	MOVEQ	#0,D0
;	BSR.S	lbC000D0E
;	TST.L	D0
;	BEQ.S	lbC000CE4
;	MOVEA.L	4,A6
;	LEA	lbL000ED8,A1
;	MOVE.L	lbL000F20,14(A1)
;	LEA	audiodevice.MSG,A0
;	MOVEQ	#0,D0
;	MOVEQ	#0,D1
;	JSR	-$1BC(A6)
;	MOVE.L	D0,lbL000F24
;	BEQ.S	lbC000CE2
;	BSR.L	lbC000D82
;	MOVEQ	#0,D0
;	BRA.S	lbC000CE4

;lbC000CE2	MOVEQ	#1,D0
;lbC000CE4	MOVEM.L	(SP)+,D1-D7/A0-A6
;	RTS

;lbC000CEA	MOVEM.L	D0-D7/A0-A6,-(SP)
;	TST.L	lbL000F24
;	BNE.S	lbC000D08
;	MOVEA.L	4,A6
;	LEA	lbL000ED8,A1
;	JSR	-$1C2(A6)
;	BSR.S	lbC000D82
;lbC000D08	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTS

;lbC000D0E	MOVEM.L	D1-D7/A0-A6,-(SP)
;	MOVEA.L	4,A6
;	MOVEQ	#-1,D0
;	JSR	-$14A(A6)
;	MOVE.L	D0,lbB000F1C
;	BMI.S	lbC000D76
;	MOVEQ	#$22,D0
;	MOVE.L	#$10001,D1
;	JSR	-$C6(A6)
;	MOVE.L	D0,lbL000F20
;	BEQ.S	lbC000D6C
;	MOVEA.L	D0,A0
;	MOVE.L	A2,10(A0)
;	MOVE.B	D2,9(A0)
;	MOVE.B	#4,8(A0)
;	MOVE.B	#0,14(A0)
;	MOVE.B	lbB000F1F,15(A0)
;	MOVE.L	lbL000DEA,$10(A0)
;	MOVEA.L	lbL000F20,A1
;	JSR	-$162(A6)
;	BRA.S	lbC000D7C

;lbC000D6C	MOVE.L	lbB000F1C,D0
;	JSR	-$150(A6)
;lbC000D76	MOVE.L	lbL000F20,D0
;lbC000D7C	MOVEM.L	(SP)+,D1-D7/A0-A6
;	RTS

;lbC000D82	MOVEM.L	D0-D7/A0-A6,-(SP)
;	TST.L	lbL000F20
;	BEQ.S	lbC000DCC
;	MOVEA.L	4,A6
;	MOVEA.L	lbL000F20,A2
;	TST.L	10(A2)
;	BEQ.S	lbC000DA6
;	MOVEA.L	A2,A1
;	JSR	-$168(A6)
;lbC000DA6	MOVE.L	#$FFFFFFFF,$10(A2)
;	MOVE.L	#$FFFFFFFF,$14(A2)
;	MOVE.L	lbB000F1C,D0
;	JSR	-$150(A6)
;	MOVEA.L	lbL000F20,A1
;	MOVEQ	#$22,D0
;	JSR	-$D2(A6)
;lbC000DCC	MOVEM.L	(SP)+,D0-D7/A0-A6
;	RTS

;	dc.w	0

;	SECTION	GuitarTimeRun000DD4,DATA,CHIP
;lbL000DD4	dc.l	0
;lbL000DD8	dc.l	0
;lbL000DDC	dc.l	0
;lbL000DE0	dc.l	0
;lbL000DE4	dc.l	0
;lbW000DE8	dc.w	0
;lbL000DEA	dc.l	0
;lbW000DEE	dc.w	1
;	dc.w	$100
;	dc.w	5
;	dc.w	9
;	dc.w	0
;	dc.w	0
;	dc.l	Playerinstall.MSG
;	dc.w	0
;	dc.w	0
;lbW000E02	dc.w	1
;	dc.w	$100
;	dc.w	6
;	dc.w	3
;	dc.w	0
;	dc.w	0
;	dc.l	OK.MSG
;	dc.w	0
;	dc.w	0
;lbW000E16	dc.w	$64
;	dc.w	0
;lbW000E1A	dc.w	$5A
;lbW000E1C	dc.w	10
;	dc.w	1
;	dc.w	0
;	dc.w	$200
;	dc.w	3
;	dc.w	$104E
;	dc.w	0
;	dc.w	0
;	dc.w	0
;	dc.w	0
;	dc.l	GVPsDSS1994CI.MSG
;	dc.w	0
;	dc.w	0
;	dc.w	0
;	dc.w	0
;	dc.w	$DC
;	dc.w	10
;	dc.w	$DC
;	dc.w	10
;	dc.w	1
;GVPsDSS1994CI.MSG	dc.b	'GVP''s DSS  '
;	dc.b	$A9
;	dc.b	'1994 CIS',0
;graphicslibra.MSG	dc.b	'graphics.library',0
;intuitionlibr.MSG	dc.b	'intuition.library',0
;ciabresource.MSG	dc.b	'ciab.resource',0
;DSSTrackerPla.MSG	dc.b	'DSS Tracker Player',0
;Playerinstall.MSG	dc.b	'Player installation has failed !',0
;OK.MSG	dc.b	'OK',0
;DSSMP.MSG	dc.b	'DSSMP',0
;audiodevice.MSG	dc.b	'audio.device',0
;lbW000ED6	dc.w	$F00
;lbL000ED8	dc.l	0
;	dc.l	0
;	dc.l	$57F0000
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	$204000
;	dc.w	0
;	dc.l	lbW000ED6
;	dc.w	0
;	dc.w	1
;	dc.w	0
;	dc.w	0
;	dc.w	0
;	dc.w	0
;	dc.w	0
;	dc.w	0
;	dc.w	0
;	dc.w	0
;	dc.w	0
;	dc.w	0
;	dc.w	0
;	dc.w	0
;	dc.w	0
;lbB000F1C	dc.b	0
;	dc.b	0
;	dc.b	0
;lbB000F1F	dc.b	0
;lbL000F20	dc.l	0
;lbL000F24	dc.l	$FFFFFFFF
;lbL000F28	dc.l	0
;	dc.l	0
;	dc.w	$2F6
;	dc.l	DSSTrackerPla.MSG
;	dc.w	0
;	dc.w	0
;	dc.l	lbC00038E
;	dc.w	0
lbB000F40	dc.b	0
lbB000F41	dc.b	0
lbW000F42	dc.w	0
lbW000F44	dc.w	0
lbW000F46	dc.w	0
lbB000F48	dc.b	0
lbB000F49	dc.b	0
lbW000F4A	dc.w	0
lbW000F4C	dc.w	0
lbW000F4E	dc.w	0
lbW000F50	dc.w	0
lbW000F52	dc.w	0
lbW000F54	dc.w	3
lbL000F56	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	$10000
lbW000F6E	dc.w	$FFFF
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	2
	dc.w	0
lbW000F90	dc.w	$FFFF
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	4
	dc.w	0
lbW000FB2	dc.w	$FFFF
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	8
	dc.w	0
lbW000FD4	dc.w	$FFFF
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
lbW000FDE	dc.w	$6B0
	dc.w	$650
	dc.w	$5F4
	dc.w	$5A0
	dc.w	$54C
	dc.w	$500
	dc.w	$4B8
	dc.w	$474
	dc.w	$434
	dc.w	$3F8
	dc.w	$3C0
	dc.w	$38A
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
	dc.w	$6A4
	dc.w	$644
	dc.w	$5EA
	dc.w	$596
	dc.w	$544
	dc.w	$4FA
	dc.w	$4B2
	dc.w	$46E
	dc.w	$42E
	dc.w	$3F2
	dc.w	$3BA
	dc.w	$384
	dc.w	$352
	dc.w	$322
	dc.w	$2F5
	dc.w	$2CB
	dc.w	$2A2
	dc.w	$27D
	dc.w	$259
	dc.w	$237
	dc.w	$217
	dc.w	$1F9
	dc.w	$1DD
	dc.w	$1C2
	dc.w	$1A9
	dc.w	$191
	dc.w	$17B
	dc.w	$165
	dc.w	$151
	dc.w	$13E
	dc.w	$12C
	dc.w	$11C
	dc.w	$10C
	dc.w	$FD
	dc.w	$EF
	dc.w	$E1
	dc.w	$D5
	dc.w	$C9
	dc.w	$BD
	dc.w	$B3
	dc.w	$A9
	dc.w	$9F
	dc.w	$96
	dc.w	$8E
	dc.w	$86
	dc.w	$7E
	dc.w	$77
	dc.w	$71
	dc.w	$698
	dc.w	$638
	dc.w	$5E0
	dc.w	$58A
	dc.w	$53C
	dc.w	$4F0
	dc.w	$4AA
	dc.w	$466
	dc.w	$428
	dc.w	$3EC
	dc.w	$3B4
	dc.w	$37E
	dc.w	$34C
	dc.w	$31C
	dc.w	$2F0
	dc.w	$2C5
	dc.w	$29E
	dc.w	$278
	dc.w	$255
	dc.w	$233
	dc.w	$214
	dc.w	$1F6
	dc.w	$1DA
	dc.w	$1BF
	dc.w	$1A6
	dc.w	$18E
	dc.w	$178
	dc.w	$163
	dc.w	$14F
	dc.w	$13C
	dc.w	$12A
	dc.w	$11A
	dc.w	$10A
	dc.w	$FB
	dc.w	$ED
	dc.w	$E0
	dc.w	$D3
	dc.w	$C7
	dc.w	$BC
	dc.w	$B1
	dc.w	$A7
	dc.w	$9E
	dc.w	$95
	dc.w	$8D
	dc.w	$85
	dc.w	$7D
	dc.w	$76
	dc.w	$70
	dc.w	$68C
	dc.w	$62E
	dc.w	$5D4
	dc.w	$580
	dc.w	$532
	dc.w	$4E8
	dc.w	$4A0
	dc.w	$45E
	dc.w	$420
	dc.w	$3E4
	dc.w	$3AC
	dc.w	$378
	dc.w	$346
	dc.w	$317
	dc.w	$2EA
	dc.w	$2C0
	dc.w	$299
	dc.w	$274
	dc.w	$250
	dc.w	$22F
	dc.w	$210
	dc.w	$1F2
	dc.w	$1D6
	dc.w	$1BC
	dc.w	$1A3
	dc.w	$18B
	dc.w	$175
	dc.w	$160
	dc.w	$14C
	dc.w	$13A
	dc.w	$128
	dc.w	$118
	dc.w	$108
	dc.w	$F9
	dc.w	$EB
	dc.w	$DE
	dc.w	$D1
	dc.w	$C6
	dc.w	$BB
	dc.w	$B0
	dc.w	$A6
	dc.w	$9D
	dc.w	$94
	dc.w	$8C
	dc.w	$84
	dc.w	$7D
	dc.w	$76
	dc.w	$6F
	dc.w	$680
	dc.w	$622
	dc.w	$5CA
	dc.w	$576
	dc.w	$528
	dc.w	$4DE
	dc.w	$498
	dc.w	$456
	dc.w	$418
	dc.w	$3DE
	dc.w	$3A6
	dc.w	$372
	dc.w	$340
	dc.w	$311
	dc.w	$2E5
	dc.w	$2BB
	dc.w	$294
	dc.w	$26F
	dc.w	$24C
	dc.w	$22B
	dc.w	$20C
	dc.w	$1EF
	dc.w	$1D3
	dc.w	$1B9
	dc.w	$1A0
	dc.w	$188
	dc.w	$172
	dc.w	$15E
	dc.w	$14A
	dc.w	$138
	dc.w	$126
	dc.w	$116
	dc.w	$106
	dc.w	$F7
	dc.w	$E9
	dc.w	$DC
	dc.w	$D0
	dc.w	$C4
	dc.w	$B9
	dc.w	$AF
	dc.w	$A5
	dc.w	$9C
	dc.w	$93
	dc.w	$8B
	dc.w	$83
	dc.w	$7C
	dc.w	$75
	dc.w	$6E
	dc.w	$674
	dc.w	$616
	dc.w	$5C0
	dc.w	$56C
	dc.w	$51E
	dc.w	$4D6
	dc.w	$490
	dc.w	$44E
	dc.w	$410
	dc.w	$3D6
	dc.w	$39E
	dc.w	$36A
	dc.w	$33A
	dc.w	$30B
	dc.w	$2E0
	dc.w	$2B6
	dc.w	$28F
	dc.w	$26B
	dc.w	$248
	dc.w	$227
	dc.w	$208
	dc.w	$1EB
	dc.w	$1CF
	dc.w	$1B5
	dc.w	$19D
	dc.w	$186
	dc.w	$170
	dc.w	$15B
	dc.w	$148
	dc.w	$135
	dc.w	$124
	dc.w	$114
	dc.w	$104
	dc.w	$F5
	dc.w	$E8
	dc.w	$DB
	dc.w	$CE
	dc.w	$C3
	dc.w	$B8
	dc.w	$AE
	dc.w	$A4
	dc.w	$9B
	dc.w	$92
	dc.w	$8A
	dc.w	$82
	dc.w	$7B
	dc.w	$74
	dc.w	$6D
	dc.w	$668
	dc.w	$60C
	dc.w	$5B4
	dc.w	$562
	dc.w	$516
	dc.w	$4CC
	dc.w	$488
	dc.w	$446
	dc.w	$408
	dc.w	$3CE
	dc.w	$398
	dc.w	$364
	dc.w	$334
	dc.w	$306
	dc.w	$2DA
	dc.w	$2B1
	dc.w	$28B
	dc.w	$266
	dc.w	$244
	dc.w	$223
	dc.w	$204
	dc.w	$1E7
	dc.w	$1CC
	dc.w	$1B2
	dc.w	$19A
	dc.w	$183
	dc.w	$16D
	dc.w	$159
	dc.w	$145
	dc.w	$133
	dc.w	$122
	dc.w	$112
	dc.w	$102
	dc.w	$F4
	dc.w	$E6
	dc.w	$D9
	dc.w	$CD
	dc.w	$C1
	dc.w	$B7
	dc.w	$AC
	dc.w	$A3
	dc.w	$9A
	dc.w	$91
	dc.w	$89
	dc.w	$81
	dc.w	$7A
	dc.w	$73
	dc.w	$6D
	dc.w	$65C
	dc.w	$600
	dc.w	$5AA
	dc.w	$558
	dc.w	$50C
	dc.w	$4C4
	dc.w	$47E
	dc.w	$43E
	dc.w	$402
	dc.w	$3C8
	dc.w	$392
	dc.w	$35E
	dc.w	$32E
	dc.w	$300
	dc.w	$2D5
	dc.w	$2AC
	dc.w	$286
	dc.w	$262
	dc.w	$23F
	dc.w	$21F
	dc.w	$201
	dc.w	$1E4
	dc.w	$1C9
	dc.w	$1AF
	dc.w	$197
	dc.w	$180
	dc.w	$16B
	dc.w	$156
	dc.w	$143
	dc.w	$131
	dc.w	$120
	dc.w	$110
	dc.w	$100
	dc.w	$F2
	dc.w	$E4
	dc.w	$D8
	dc.w	$CC
	dc.w	$C0
	dc.w	$B5
	dc.w	$AB
	dc.w	$A1
	dc.w	$98
	dc.w	$90
	dc.w	$88
	dc.w	$80
	dc.w	$79
	dc.w	$72
	dc.w	$6C
	dc.w	$716
	dc.w	$6B0
	dc.w	$650
	dc.w	$5F4
	dc.w	$5A0
	dc.w	$54C
	dc.w	$500
	dc.w	$4B8
	dc.w	$474
	dc.w	$434
	dc.w	$3F8
	dc.w	$3C0
	dc.w	$38B
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
	dc.w	$708
	dc.w	$6A4
	dc.w	$644
	dc.w	$5EA
	dc.w	$596
	dc.w	$546
	dc.w	$4F8
	dc.w	$4B2
	dc.w	$46E
	dc.w	$42E
	dc.w	$3F2
	dc.w	$3BA
	dc.w	$384
	dc.w	$352
	dc.w	$322
	dc.w	$2F5
	dc.w	$2CB
	dc.w	$2A3
	dc.w	$27C
	dc.w	$259
	dc.w	$237
	dc.w	$217
	dc.w	$1F9
	dc.w	$1DD
	dc.w	$1C2
	dc.w	$1A9
	dc.w	$191
	dc.w	$17B
	dc.w	$165
	dc.w	$151
	dc.w	$13E
	dc.w	$12C
	dc.w	$11C
	dc.w	$10C
	dc.w	$FD
	dc.w	$EE
	dc.w	$E1
	dc.w	$D4
	dc.w	$C8
	dc.w	$BD
	dc.w	$B3
	dc.w	$A9
	dc.w	$9F
	dc.w	$96
	dc.w	$8E
	dc.w	$86
	dc.w	$7E
	dc.w	$77
	dc.w	$6FC
	dc.w	$698
	dc.w	$638
	dc.w	$5E0
	dc.w	$58A
	dc.w	$53C
	dc.w	$4F0
	dc.w	$4AA
	dc.w	$466
	dc.w	$428
	dc.w	$3EC
	dc.w	$3B4
	dc.w	$37E
	dc.w	$34C
	dc.w	$31C
	dc.w	$2F0
	dc.w	$2C5
	dc.w	$29E
	dc.w	$278
	dc.w	$255
	dc.w	$233
	dc.w	$214
	dc.w	$1F6
	dc.w	$1DA
	dc.w	$1BF
	dc.w	$1A6
	dc.w	$18E
	dc.w	$178
	dc.w	$163
	dc.w	$14F
	dc.w	$13C
	dc.w	$12A
	dc.w	$11A
	dc.w	$10A
	dc.w	$FB
	dc.w	$ED
	dc.w	$DF
	dc.w	$D3
	dc.w	$C7
	dc.w	$BC
	dc.w	$B1
	dc.w	$A7
	dc.w	$9E
	dc.w	$95
	dc.w	$8D
	dc.w	$85
	dc.w	$7D
	dc.w	$76
	dc.w	$6EE
	dc.w	$68C
	dc.w	$62E
	dc.w	$5D4
	dc.w	$580
	dc.w	$532
	dc.w	$4E8
	dc.w	$4A0
	dc.w	$45E
	dc.w	$420
	dc.w	$3E4
	dc.w	$3AC
	dc.w	$377
	dc.w	$346
	dc.w	$317
	dc.w	$2EA
	dc.w	$2C0
	dc.w	$299
	dc.w	$274
	dc.w	$250
	dc.w	$22F
	dc.w	$210
	dc.w	$1F2
	dc.w	$1D6
	dc.w	$1BC
	dc.w	$1A3
	dc.w	$18B
	dc.w	$175
	dc.w	$160
	dc.w	$14C
	dc.w	$13A
	dc.w	$128
	dc.w	$118
	dc.w	$108
	dc.w	$F9
	dc.w	$EB
	dc.w	$DE
	dc.w	$D1
	dc.w	$C6
	dc.w	$BB
	dc.w	$B0
	dc.w	$A6
	dc.w	$9D
	dc.w	$94
	dc.w	$8C
	dc.w	$84
	dc.w	$7D
	dc.w	$76
	dc.w	$6E2
	dc.w	$680
	dc.w	$622
	dc.w	$5CA
	dc.w	$576
	dc.w	$528
	dc.w	$4DE
	dc.w	$498
	dc.w	$456
	dc.w	$418
	dc.w	$3DC
	dc.w	$3A6
	dc.w	$371
	dc.w	$340
	dc.w	$311
	dc.w	$2E5
	dc.w	$2BB
	dc.w	$294
	dc.w	$26F
	dc.w	$24C
	dc.w	$22B
	dc.w	$20C
	dc.w	$1EE
	dc.w	$1D3
	dc.w	$1B9
	dc.w	$1A0
	dc.w	$188
	dc.w	$172
	dc.w	$15E
	dc.w	$14A
	dc.w	$138
	dc.w	$126
	dc.w	$116
	dc.w	$106
	dc.w	$F7
	dc.w	$E9
	dc.w	$DC
	dc.w	$D0
	dc.w	$C4
	dc.w	$B9
	dc.w	$AF
	dc.w	$A5
	dc.w	$9C
	dc.w	$93
	dc.w	$8B
	dc.w	$83
	dc.w	$7B
	dc.w	$75
	dc.w	$6D6
	dc.w	$674
	dc.w	$616
	dc.w	$5C0
	dc.w	$56C
	dc.w	$51E
	dc.w	$4D6
	dc.w	$490
	dc.w	$44E
	dc.w	$410
	dc.w	$3D6
	dc.w	$39E
	dc.w	$36B
	dc.w	$33A
	dc.w	$30B
	dc.w	$2E0
	dc.w	$2B6
	dc.w	$28F
	dc.w	$26B
	dc.w	$248
	dc.w	$227
	dc.w	$208
	dc.w	$1EB
	dc.w	$1CF
	dc.w	$1B5
	dc.w	$19D
	dc.w	$186
	dc.w	$170
	dc.w	$15B
	dc.w	$148
	dc.w	$135
	dc.w	$124
	dc.w	$114
	dc.w	$104
	dc.w	$F5
	dc.w	$E8
	dc.w	$DB
	dc.w	$CE
	dc.w	$C3
	dc.w	$B8
	dc.w	$AE
	dc.w	$A4
	dc.w	$9B
	dc.w	$92
	dc.w	$8A
	dc.w	$82
	dc.w	$7B
	dc.w	$74
	dc.w	$6C8
	dc.w	$668
	dc.w	$60C
	dc.w	$5B4
	dc.w	$562
	dc.w	$516
	dc.w	$4CC
	dc.w	$488
	dc.w	$446
	dc.w	$408
	dc.w	$3CE
	dc.w	$398
	dc.w	$364
	dc.w	$334
	dc.w	$306
	dc.w	$2DA
	dc.w	$2B1
	dc.w	$28B
	dc.w	$266
	dc.w	$244
	dc.w	$223
	dc.w	$204
	dc.w	$1E7
	dc.w	$1CC
	dc.w	$1B2
	dc.w	$19A
	dc.w	$183
	dc.w	$16D
	dc.w	$159
	dc.w	$145
	dc.w	$133
	dc.w	$122
	dc.w	$112
	dc.w	$102
	dc.w	$F4
	dc.w	$E6
	dc.w	$D9
	dc.w	$CD
	dc.w	$C1
	dc.w	$B7
	dc.w	$AC
	dc.w	$A3
	dc.w	$9A
	dc.w	$91
	dc.w	$89
	dc.w	$81
	dc.w	$7A
	dc.w	$73
	dc.w	$6BC
	dc.w	$65C
	dc.w	$600
	dc.w	$5AA
	dc.w	$558
	dc.w	$50C
	dc.w	$4C4
	dc.w	$47E
	dc.w	$43E
	dc.w	$402
	dc.w	$3C8
	dc.w	$392
	dc.w	$35E
	dc.w	$32E
	dc.w	$300
	dc.w	$2D5
	dc.w	$2AC
	dc.w	$286
	dc.w	$262
	dc.w	$23F
	dc.w	$21F
	dc.w	$201
	dc.w	$1E4
	dc.w	$1C9
	dc.w	$1AF
	dc.w	$197
	dc.w	$180
	dc.w	$16B
	dc.w	$156
	dc.w	$143
	dc.w	$131
	dc.w	$120
	dc.w	$110
	dc.w	$100
	dc.w	$F2
	dc.w	$E4
	dc.w	$D8
	dc.w	$CB
	dc.w	$C0
	dc.w	$B5
	dc.w	$AB
	dc.w	$A1
	dc.w	$98
	dc.w	$90
	dc.w	$88
	dc.w	$80
	dc.w	$79
	dc.w	$72
lbW0015DE	dc.w	$6B0
	dc.w	$71
	dc.w	$6A4
	dc.w	$71
	dc.w	$698
	dc.w	$70
	dc.w	$68C
	dc.w	$6F
	dc.w	$680
	dc.w	$6E
	dc.w	$674
	dc.w	$6D
	dc.w	$668
	dc.w	$6D
	dc.w	$65C
	dc.w	$6C
	dc.w	$716
	dc.w	$78
	dc.w	$708
	dc.w	$77
	dc.w	$6FC
	dc.w	$76
	dc.w	$6EE
	dc.w	$76
	dc.w	$6E2
	dc.w	$75
	dc.w	$6D6
	dc.w	$74
	dc.w	$6C8
	dc.w	$73
	dc.w	$6BC
	dc.w	$72
lbL00161E	dc.l	0
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
lbL00169A
	dc.l	0

;lbW00169E	dc.w	$1B
;	dc.w	$F87
;	dc.w	$1B
;	dc.w	$4F4D
;MMU2.MSG	dc.b	'MMU2',0,0
;	dc.b	'r'
;	dc.b	$16
;lbB0016AE	dc.b	$7D
;lbB0016AF	dc.b	3
;Instrument1.MSG	dc.b	'Instrument1',0,0
;lbW001C42	dc.w	$1E
;lbW001C44	dc.w	1
;lbW001CC4	dc.w	$30D6

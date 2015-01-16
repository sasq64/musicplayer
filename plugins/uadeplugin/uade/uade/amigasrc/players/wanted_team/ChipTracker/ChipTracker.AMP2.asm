	******************************************************
	****           ChipTracker replayer for     	  ****
	****    EaglePlayer 2.00+ (Amplifier version),    ****
	****         all adaptions by Wanted Team	  ****
	******************************************************

	incdir	"dh2:include/"
	include 'misc/eagleplayer2.01.i'
	include	'misc/eagleplayerengine.i'
	include	'exec/exec_lib.i'

	SECTION	Player,CODE

	EPPHEADER Tags

	dc.b	'$VER: ChipTracker player module V2.1 (22 Feb 2007)',0
	even
Tags
	dc.l	DTP_PlayerVersion,2<<16!1
	dc.l	EP_PlayerVersion,11
	dc.l	DTP_PlayerName,PlayerName
	dc.l	DTP_Creator,Creator
	dc.l	EP_Check5,Check5
	dc.l	DTP_InitPlayer,InitPlayer
	dc.l	DTP_InitSound,InitSound
	dc.l	DTP_Interrupt,Interrupt
	dc.l	EP_NewModuleInfo,NewModuleInfo
	dc.l	DTP_SubSongRange,SubSongRange
	dc.l	EP_GetPositionNr,GetPosition
	dc.l	EP_SampleInit,SampleInit
	dc.l	DTP_NextPatt,Next_Pattern
	dc.l	DTP_PrevPatt,BackPattern
	dc.l	EP_PatternInit,PatternInit
	dc.l	EP_Flags,EPB_Save!EPB_ModuleInfo!EPB_SampleInfo!EPB_Songend!EPB_Packable!EPB_Restart!EPB_PrevSong!EPB_NextSong!EPB_PrevPatt!EPB_NextPatt
	dc.l	EP_EagleBase,EagleBase
	dc.l	EP_InitAmplifier,InitAudstruct
	dc.l	0

PlayerName
	dc.b	'ChipTracker',0
Creator
	dc.b	"(c) 1991 by Krister 'Kris' Wombell,",10
	dc.b	'adapted by Wanted Team',0
Prefix
	dc.b	'KRIS.',0
	even
ModulePtr
	dc.l	0
SamplesPtr
	dc.l	0
SongVal
	dc.w	0
SongTable
	ds.b	128

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
	lea	PATTERNINFO(PC),A0

	moveq	#4,D0
	move.w	D0,PI_Voices(A0)	; Number of stripes (MUST be at least 4)
	move.l	#CONVERTNOTE,PI_Convert(A0)
	move.l	D0,PI_Modulo(A0)	; Number of bytes to next row
	move.w	#64,PI_Pattlength(A0)	; Length of each stripe in rows

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

	move.b	1(A0),D1
	move.b	2(A0),D2
	move.b	3(A0),D3
	move.b	(A0),D0
	cmp.b	#$A8,D0
	beq.b	NoNote
	lea	lbW000628(PC),A1
	move.w	(A1,D0.W),D0
	rts
NoNote
	moveq	#0,D0
	rts

PATINFO
	movem.l	D0/A0-A2,-(SP)
	lea	PATTERNINFO(PC),A0
	move.w	2(A5),D0
	lsr.w	#2,D0
	move.w	D0,PI_Pattpos(A0)		; Current Position in Pattern
	move.w	6(A5),PI_Speed(A0)		; Speed Value
	move.w	(A5),D0
	move.w	D0,PI_Songpos(A0)
	move.l	ModulePtr(PC),A1
	lea	958(A1),A1
	lsl.w	#3,D0
	lea	(A1,D0.W),A1
	lea	STRIPE1(PC),A0
	lea	lbL0006BE(PC),A2
	moveq	#0,D0
	move.b	(A1),D0
	lsl.w	#2,D0
	move.l	(A2,D0.W),(A0)+
	addq.l	#2,A1
	moveq	#0,D0
	move.b	(A1),D0
	lsl.w	#2,D0
	move.l	(A2,D0.W),(A0)+
	addq.l	#2,A1
	moveq	#0,D0
	move.b	(A1),D0
	lsl.w	#2,D0
	move.l	(A2,D0.W),(A0)+
	addq.l	#2,A1
	moveq	#0,D0
	move.b	(A1),D0
	lsl.w	#2,D0
	move.l	(A2,D0.W),(A0)
	movem.l	(SP)+,D0/A0-A2
	rts

***************************************************************************
******************************* DTP_NextPatt ******************************
***************************************************************************

Next_Pattern
	lea	lbL000AAE(PC),A0
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
	lea	lbL000AAE(PC),A0
	move.w	(A0),D0
	beq.b	MinPos
	subq.w	#1,D0
	move.w	D0,(A0)+
	clr.w	(A0)
MinPos
	rts

***************************************************************************
***************************** DTP_SubSongRange ****************************
***************************************************************************

SubSongRange
	moveq 	#0,D0
	move.l	InfoBuffer+SubSongs(PC),D1
	subq.l	#1,D1
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

	lea	22(A2),A2
	move.l	SamplesPtr(PC),A1
	moveq	#30,D5
hop
	jsr	ENPP_AllocSampleStruct(A5)
	move.l	D0,(A3)
	beq.b	return
	move.l	D0,A3

	moveq	#0,D0
	move.w	22(A2),D0
	add.l	D0,D0
	move.l	A1,EPS_Adr(A3)			; sample address
	move.l	D0,EPS_Length(A3)		; sample length
	move.l	#64,EPS_Volume(A3)
	move.l	A2,EPS_SampleName(A3)		; sample name
	move.w	#USITY_RAW,EPS_Type(A3)
	move.w	#22,EPS_MaxNameLen(A3)
	move.w	#USIB_Playable!USIB_Saveable!USIB_8BIT,EPS_Flags(A3)
	lea	30(A2),A2
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

SubSongs	=	4
LoadSize	=	12
Samples		=	20
Length		=	28
SamplesSize	=	36
SongSize	=	44
CalcSize	=	52
SongName	=	60
Patterns	=	68
Author		=	76

InfoBuffer
	dc.l	MI_SubSongs,0		;4
	dc.l	MI_LoadSize,0		;12
	dc.l	MI_Samples,0		;20
	dc.l	MI_Length,0		;28
	dc.l	MI_SamplesSize,0	;36
	dc.l	MI_Songsize,0		;44
	dc.l	MI_Calcsize,0		;52
	dc.l	MI_SongName,0		;60
	dc.l	MI_Pattern,0		;68
	dc.l	MI_AuthorName,0		;76
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

	cmp.l	#1984+256,dtg_ChkSize(A5)
	ble.b	Fault

	cmp.l	#'KRIS',952(A0)
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

	movem.l	A0/A4/A5/A6,-(SP)
	bsr.w	InitPlay
	movem.l	(SP)+,A0/A4/A5/A6

	sub.l	A0,A1
	move.l	A1,CalcSize(A4)
	cmp.l	LoadSize(A4),A1
	ble.b	SizeOK
	moveq	#EPR_ModuleTooShort,D0
	rts
SizeOK
	move.l	D5,(A6)+			; SamplesPtr
	move.l	D4,Samples(A4)
	sub.l	A0,D5
	move.l	D5,SongSize(A4)
	sub.l	D5,A1
	move.l	A1,SamplesSize(A4)
	move.l	A0,SongName(A4)

	moveq	#0,D2
	move.b	956(A0),D2
	move.l	D2,Length(A4)
	move.w	956(A0),(A6)			; SongVal

	bsr.w	FindName

	subq.l	#1,D2
	moveq	#0,D0
	lea	958(A0),A1
	move.l	A1,D5
	lea	1984(A0),A2
	lea	SongTable+1(PC),A6
	moveq	#0,D4
NextPos
	move.l	D5,A1
	move.l	D4,D6
	lsl.l	#3,D6
	add.l	D6,A1
	moveq	#3,D6
NextPat
	moveq	#0,D1
	move.b	(A1)+,D1
	addq.l	#1,A1
	lsl.l	#8,D1					; * 256
	lea	(A2,D1.L),A0
	lea	256(A0),A3
	addq.l	#2,A0
NextPatPos
	cmp.b	#$0B,(A0)
	beq.b	SubFound
	addq.l	#4,A0
	cmp.l	A0,A3
	bgt.b	NextPatPos
	dbf	D6,NextPat

	addq.l	#1,D4
back
	dbf	D2,NextPos

	tst.l	D0
	bne.b	LoopOK
	moveq	#1,D0
	bra.b	SkipLoop
LoopOK
	move.b	-1(A6),D4
	cmp.l	Length(A4),D4
	beq.b	SkipLoop
	addq.l	#1,D0
SkipLoop
	move.l	D0,SubSongs(A4)

	moveq	#0,D0
	rts

SubFound
	addq.l	#1,D4
	move.b	D4,(A6)+
	addq.l	#1,D0
	bra.b	back

FindName
	lea	22(A0),A1			; A1 - begin sampleinfo
	move.l	A1,EPG_ARG1(A5)
	moveq	#30,D0				; D0 - length per one sampleinfo
	move.l	D0,EPG_ARG2(A5)
	moveq	#20,D0				; D0 - max. sample name
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
	move.w	lbL000AAE(PC),D0
	rts

***************************************************************************
***************************** DTP_InitSound *******************************
***************************************************************************

InitSound
	move.w	dtg_SndNum(A5),D0
	lea	SongTable(PC),A0
	move.b	(A0,D0.W),D0
	bsr.w	ClearData
	lea	lbL000AAE(PC),A0
	move.w	D0,0(A0)
	clr.w	2(A0)
	move.w	6(A0),D0
	subq.w	#1,D0
	move.w	D0,4(A0)
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
***************************** ChipTracker player **************************
***************************************************************************

; Player from demo called "Dentro" (c) 1991 by Anarchy

InitPlay
;	MOVEA.L	lbL000AC2,A0
	LEA	$7C0(A0),A1
	LEA	lbL0006BE(PC),A2
	MOVEQ	#$7F,D0
lbC000010	MOVE.L	A1,(A2)+
	LEA	$100(A1),A1
	DBRA	D0,lbC000010
	LEA	$3BE(A0),A1
	MOVEQ	#0,D0
	MOVE.B	$3BC(A0),D0
	ADD.W	D0,D0
	ADD.W	D0,D0
	SUBQ.W	#1,D0
	MOVEQ	#0,D1
lbC00002C	MOVE.B	(A1),D2
	CMP.B	D1,D2
	BLS.S	lbC000034
	MOVE.B	D2,D1
lbC000034	ADDQ.L	#2,A1
	DBRA	D0,lbC00002C
	ADDQ.W	#1,D1

	move.l	D1,Patterns(A4)

	MULU.W	#$100,D1
	LEA	$7C0(A0),A1
;	LEA	0(A1,D1.W),A1				; bug 

	lea	(A1,D1.L),A1
	move.l	A1,D5
	moveq	#0,D4

	LEA	$16(A0),A2
	LEA	lbL0008BE(PC),A3
	MOVEQ	#$1E,D0
lbC000052	MOVEA.L	A3,A4
	MOVE.L	A1,(A4)+
	MOVEQ	#0,D1
	MOVE.W	$16(A2),D1

	beq.b	NoSamp
	addq.l	#1,D4
NoSamp

	MOVE.W	D1,(A4)+
	ADD.L	D1,D1
	MOVE.L	#lbL000ABE,(A4)+
	MOVE.W	$1C(A2),(A4)+
	MOVE.W	$18(A2),(A4)+
	CMPI.W	#1,$1C(A2)
	BEQ.S	lbC000084
	MOVEQ	#0,D2
	MOVE.W	$1A(A2),D2
	LEA	0(A1,D2.L),A6
	MOVE.L	A6,-8(A4)
lbC000084	ADDA.L	D1,A1
	LEA	$1E(A2),A2
	LEA	$10(A3),A3
	DBRA	D0,lbC000052

	rts

ClearData
;	BSET	#1,$BFE001
	LEA	lbL000AAE(PC),A5
	CLR.L	0(A5)
	CLR.L	8(A5)
	CLR.L	4(A5)
	MOVE.W	#6,6(A5)
;	MOVE.W	#$E000,$DFF09A
;	MOVE.L	$78,12(A5)
;	MOVE.L	#lbC00048A,$78
;	MOVE.B	#$7F,$BFDD00
;	MOVE.B	#$81,$BFDD00
;	MOVE.B	#$B0,$BFD400
;	MOVE.B	#0,$BFD500
;	MOVE.B	#$48,$BFDE00
;	CLR.W	lbW000502
	RTS

;	MOVE.L	lbL000ABA(PC),$78
;	MOVE.W	#15,$DFF096
;	CLR.W	$DFF0A8
;	CLR.W	$DFF0B8
;	CLR.W	$DFF0C8
;	CLR.W	$DFF0D8
;	RTS

Play
;	MOVEM.L	D0-D2/D6/D7/A0-A3/A5,-(SP)
	LEA	lbL000AAE(PC),A5
	ADDQ.W	#1,4(A5)
	MOVE.W	6(A5),D0
	CMP.W	4(A5),D0
	BEQ.L	lbC000344
	LEA	$DFF0A0,A1
	LEA	lbL0005A0(pc),A2
	MOVEQ	#3,D7
lbC000144	BSR.S	lbC000158
	LEA	$10(A1),A1
	LEA	$22(A2),A2
	DBRA	D7,lbC000144
;	MOVEM.L	(SP)+,D0-D2/D6/D7/A0-A3/A5
	RTS

lbC000158	MOVEQ	#0,D0
	MOVE.B	$16(A2),D0
	ADD.W	D0,D0
	ADD.W	D0,D0
	JMP	lbC000166(PC,D0.W)

lbC000166	BRA.L	lbC0001A8

	BRA.L	lbC00020C

	BRA.L	lbC000230

	BRA.L	lbC000256

	BRA.L	lbC0002A6

	BRA.L	lbC000342

	BRA.L	lbC000342

	BRA.L	lbC000342

	BRA.L	lbC000342

	BRA.L	lbC000342

	BRA.L	lbC000310

	BRA.L	lbC000342

	BRA.L	lbC000342

	BRA.L	lbC000342

	BRA.L	lbC000342

	BRA.L	lbC000342

	RTS

lbC0001A8	TST.B	$17(A2)
	BNE.S	lbC0001B0
	RTS

lbC0001B0	MOVE.W	4(A5),D0
	MOVE.B	lbW0001EC(PC,D0.W),D0
	BEQ.L	lbC000342
	CMP.B	#2,D0
	BEQ.S	lbC0001CA
	MOVE.B	$17(A2),D0
	LSR.W	#4,D0
	BRA.S	lbC0001D2

lbC0001CA	MOVE.B	$17(A2),D0
	ANDI.W	#15,D0
lbC0001D2	LEA	lbW000628(PC),A0
	ADD.W	D0,D0
	MOVE.W	$18(A2),D1
	ADD.W	D0,D1
	MOVE.W	0(A0,D1.W),D0
;	MOVE.W	D0,6(A1)

	bsr.w	PokePer

	MOVE.W	D0,0(A2)
	RTS

lbW0001EC	dc.w	1
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

lbC00020C	MOVEQ	#0,D0
	MOVE.B	$17(A2),D0
	SUB.W	D0,0(A2)
	MOVE.W	0(A2),D0
	CMP.W	#$71,D0
	BCC.S	lbC00022A
	MOVE.W	#$71,0(A2)
	MOVE.W	#$71,D0
lbC00022A
;	MOVE.W	D0,6(A1)

	bsr.w	PokePer

	RTS

lbC000230	MOVEQ	#0,D0
	MOVE.B	$17(A2),D0
	ADD.W	D0,0(A2)
	MOVE.W	0(A2),D0
	CMP.W	#$358,D0
	BMI.S	lbC000250
	ANDI.W	#$F000,0(A2)
	ORI.W	#$358,0(A2)
lbC000250
;	MOVE.W	D0,6(A1)

	bsr.w	PokePer

	RTS

lbC000256	MOVE.B	$17(A2),D0
	BEQ.S	lbC000264
	MOVE.B	D0,$1B(A2)
	CLR.B	$17(A2)
lbC000264	TST.W	$1C(A2)
	BEQ.S	lbC0002A4
	MOVEQ	#0,D0
	MOVE.B	$1B(A2),D0
	TST.B	$1A(A2)
	BNE.S	lbC000286
	ADD.W	D0,0(A2)
	MOVE.W	$1C(A2),D0
	CMP.W	0(A2),D0
	BGT.S	lbC00029E
	BRA.S	lbC000294

lbC000286	SUB.W	D0,0(A2)
	MOVE.W	$1C(A2),D0
	CMP.W	0(A2),D0
	BLT.S	lbC00029E
lbC000294	MOVE.W	$1C(A2),0(A2)
	CLR.W	$1C(A2)
lbC00029E
;	MOVE.W	0(A2),6(A1)

	bsr.w	PokePer

lbC0002A4	RTS

lbC0002A6	MOVE.B	$17(A2),D0
	BEQ.S	lbC0002B0
	MOVE.B	D0,$1E(A2)
lbC0002B0	MOVE.B	$1F(A2),D0
	LSR.W	#2,D0
	ANDI.W	#$1F,D0
	MOVEQ	#0,D2
	MOVE.B	lbW0002F0(PC,D0.W),D2
	MOVE.B	$1E(A2),D0
	ANDI.W	#15,D0
	MULU.W	D0,D2
	LSR.W	#7,D2
	MOVE.W	0(A2),D0
	TST.B	$1F(A2)
	BMI.S	lbC0002DA
	ADD.W	D2,D0
	BRA.S	lbC0002DC

lbC0002DA	SUB.W	D2,D0
lbC0002DC
;	MOVE.W	D0,6(A1)

	bsr.w	PokePer

	MOVE.B	$1E(A2),D0
	LSR.W	#2,D0
	ANDI.W	#$3C,D0
	ADD.B	D0,$1F(A2)
	RTS

lbW0002F0	dc.w	$18
	dc.w	$314A
	dc.w	$6178
	dc.w	$8DA1
	dc.w	$B4C5
	dc.w	$D4E0
	dc.w	$EBF4
	dc.w	$FAFD
	dc.w	$FFFD
	dc.w	$FAF4
	dc.w	$EBE0
	dc.w	$D4C5
	dc.w	$B4A1
	dc.w	$8D78
	dc.w	$614A
	dc.w	$3118

lbC000310	MOVEQ	#0,D0
	MOVE.B	$17(A2),D0
	CMP.B	#$10,D0
	BCS.S	lbC00032C
	LSR.B	#4,D0
	ADD.W	2(A2),D0
	CMP.W	#$40,D0
	BMI.S	lbC00033A
	MOVEQ	#$40,D0
	BRA.S	lbC00033A

lbC00032C	ANDI.B	#15,D0
	NEG.W	D0
	ADD.W	2(A2),D0
	BPL.S	lbC00033A
	MOVEQ	#0,D0
lbC00033A	MOVE.W	D0,2(A2)
;	MOVE.W	D0,8(A1)

	bsr.w	PokeVol

lbC000342	RTS

lbC000344	CLR.W	4(A5)
;	MOVEA.L	lbL000AC2,A3

	move.l	ModulePtr(PC),A3

	LEA	$3BE(A3),A3
	MOVE.W	0(A5),D0
	LSL.W	#3,D0
	LEA	0(A3,D0.W),A3
	LEA	$DFF0A0,A1
	LEA	lbL0005A0(PC),A2
	CLR.W	8(A5)
	MOVEQ	#1,D7
	MOVEQ	#3,D6
lbC00036E	TST.W	$20(A2)
	BNE.L	lbC00042C
	MOVEQ	#0,D0
	MOVE.B	(A3),D0
	ADD.W	D0,D0
	ADD.W	D0,D0
	LEA	lbL0006BE(PC),A0
	MOVEA.L	0(A0,D0.W),A0
	ADDA.W	2(A5),A0
	MOVE.L	(A0),$14(A2)
	TST.B	$15(A2)
	BEQ.S	lbC0003BA
	MOVEQ	#0,D0
	MOVE.B	$15(A2),D0
	LSL.W	#4,D0
	LEA	lbL0008AE(pc),A0
	LEA	0(A0,D0.W),A0
	MOVE.L	(A0)+,6(A2)
	MOVE.W	(A0)+,10(A2)
	MOVE.L	(A0)+,12(A2)
	MOVE.W	(A0)+,$10(A2)
	MOVE.W	(A0),2(A2)
lbC0003BA
;	MOVE.W	2(A2),8(A1)

	move.w	2(A2),D0
	bsr.w	PokeVol

	MOVEQ	#0,D0
	MOVE.B	$14(A2),D0
	CMP.B	#$A8,D0
	BEQ.S	lbC000428
	LEA	lbW000628(PC),A0
	MOVE.B	1(A3),D1
	BEQ.S	lbC0003DC
	EXT.W	D1
	ADD.W	D1,D1
	ADD.W	D1,D0
lbC0003DC	MOVE.W	D0,$18(A2)
	MOVE.W	0(A0,D0.W),D0
	CMPI.B	#3,$16(A2)
	BNE.S	lbC000408
	MOVE.W	D0,$1C(A2)
	CLR.B	$1A(A2)
	CMP.W	0(A2),D0
	BEQ.S	lbC000402
	BGE.S	lbC000428
	ADDQ.B	#1,$1A(A2)
	BRA.S	lbC000428

lbC000402	CLR.W	$1C(A2)
	BRA.S	lbC000428

lbC000408
;	MOVE.W	D7,$DFF096

	move.l	D0,-(SP)
	move.w	D7,D0
	bsr.w	PokeDMA
	move.l	(SP)+,D0

;	MOVE.W	D0,6(A1)

	bsr.w	PokePer

	MOVE.W	D0,0(A2)
	CLR.B	$1F(A2)
	OR.W	D7,8(A5)
;	MOVE.L	6(A2),(A1)
;	MOVE.W	10(A2),4(A1)

	move.l	D0,-(SP)
	move.l	6(A2),D0
	bsr.w	PokeAdr
	move.w	10(A2),D0
	bsr.w	PokeLen
	move.l	(SP)+,D0

lbC000428	BSR.L	lbC000504
lbC00042C	LEA	$10(A1),A1
	LEA	$22(A2),A2
	ADDQ.L	#2,A3
	ADD.W	D7,D7
	DBRA	D6,lbC00036E
;	BSET	#0,$BFDE00
	TST.W	10(A5)
	BNE.S	lbC000456
	ADDQ.W	#4,2(A5)
	CMPI.W	#$100,2(A5)
	BNE.S	lbC000476
lbC000456	CLR.W	10(A5)
	CLR.W	2(A5)
	ADDQ.W	#1,0(A5)
;	MOVE.B	lbB000E7E,D0

	move.b	SongVal(PC),D0

	CMP.B	1(A5),D0
	BNE.S	lbC000476
;	MOVE.B	lbB000E7F,1(A5)				; repeat song

	move.b	SongVal+1(PC),1(A5)
	bsr.w	SongEnd

lbC000476	ORI.W	#$8200,8(A5)

	bsr.w	PATINFO

;	MOVEM.L	(SP)+,D0-D2/D6/D7/A0-A3/A5
;	MOVE.W	#0,$DFF180
;	RTS

;lbC00048A	TST.B	$BFDD00
;	MOVE.W	#$2000,$DFF09C
;	TST.W	lbW000502
;	BNE.S	lbC0004BA
;	MOVE.W	#1,lbW000502
;	MOVE.W	lbW000AB6(PC),$DFF096
;	BSET	#0,$BFDE00
;	RTE

;lbC0004BA	CLR.W	lbW000502
;	MOVEM.L	A1/A2,-(SP)

	move.l	D0,-(SP)
	move.w	8(A5),D0
	bsr.w	PokeDMA

	LEA	$DFF0A0,A1
	LEA	lbL0005A0(PC),A2
;	MOVE.L	12(A2),(A1)
;	MOVE.W	$10(A2),4(A1)
;	MOVE.L	$2E(A2),$10(A1)
;	MOVE.W	$32(A2),$14(A1)
;	MOVE.L	$50(A2),$20(A1)
;	MOVE.W	$54(A2),$24(A1)
;	MOVE.L	$72(A2),$30(A1)
;	MOVE.W	$76(A2),$34(A1)

	move.l	12(A2),D0
	bsr.w	PokeAdr
	move.w	$10(A2),D0
	bsr.w	PokeLen
	lea	16(A1),A1
	move.l	$2E(A2),D0
	bsr.w	PokeAdr
	move.w	$32(A2),D0
	bsr.w	PokeLen
	lea	16(A1),A1
	move.l	$50(A2),D0
	bsr.w	PokeAdr
	move.w	$54(A2),D0
	bsr.w	PokeLen
	lea	16(A1),A1
	move.l	$72(A2),D0
	bsr.w	PokeAdr
	move.w	$76(A2),D0
	bsr.w	PokeLen
	move.l	(SP)+,D0

;	MOVEM.L	(SP)+,A1/A2
;	RTE

	rts

;lbW000502	dc.w	0

lbC000504	MOVEQ	#0,D0
	MOVE.B	$16(A2),D0
	ADD.W	D0,D0
	ADD.W	D0,D0
	JMP	lbC000512(PC,D0.W)

lbC000512	BRA.L	lbC000342

	BRA.L	lbC000342

	BRA.L	lbC000342

	BRA.L	lbC000342

	BRA.L	lbC000342

	BRA.L	lbC000342

	BRA.L	lbC000342

	BRA.L	lbC000342

	BRA.L	lbC000342

	BRA.L	lbC000342

	BRA.L	lbC000342

	BRA.L	lbC00056C

	BRA.L	lbC000584

	BRA.L	lbC000578

	BRA.L	lbC000552

	BRA.L	lbC000594

lbC000552	MOVE.B	$17(A2),D0
	BEQ.S	lbC000562
;	BSET	#1,$BFE001

	bsr.w	LED_Off

	RTS

lbC000562
;	BCLR	#1,$BFE001

	bsr.w	LED_On

	RTS

lbC00056C	MOVEQ	#0,D0
	MOVE.B	$17(A2),D0

	cmp.w	(A5),D0
	bgt.b	NoEnd
	bsr.w	SongEnd
NoEnd

	SUBQ.B	#1,D0
	MOVE.W	D0,0(A5)				; song loop
lbC000578	MOVE.W	#1,10(A5)
	CLR.L	$14(A2)
	RTS

lbC000584	MOVEQ	#0,D0
	MOVE.B	$17(A2),D0
;	MOVE.W	D0,8(A1)

	bsr.w	PokeVol

	MOVE.W	D0,2(A2)
	RTS

lbC000594	MOVE.B	$17(A2),D0
	BEQ.S	lbC00059E
	MOVE.W	D0,6(A5)
lbC00059E	RTS

lbL0005A0	dc.l	0
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
	dc.l	0
	dc.l	0
	dc.l	0
lbW000628	dc.w	$1AC0
	dc.w	$1940
	dc.w	$17D0
	dc.w	$1680
	dc.w	$1530
	dc.w	$1400
	dc.w	$12E0
	dc.w	$11D0
	dc.w	$10D0
	dc.w	$FE0
	dc.w	$F00
	dc.w	$E28
	dc.w	$D60
	dc.w	$CA0
	dc.w	$BE8
	dc.w	$B40
	dc.w	$A98
	dc.w	$A00
	dc.w	$970
	dc.w	$8E8
	dc.w	$868
	dc.w	$7F0
	dc.w	$780
	dc.w	$714
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
	dc.w	0
	dc.w	0
	dc.w	0
lbL0006BE	dc.l	0
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
	dc.l	0
	dc.l	0
	dc.l	0
lbL0008AE	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbL0008BE	dc.l	0
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
	dc.l	0
	dc.l	0
	dc.l	0
lbL000AAE	dc.l	0
	dc.l	0
lbW000AB6	dc.w	0
	dc.w	0
lbL000ABA	dc.l	0

	Section	Empty,BSS_C

lbL000ABE	ds.b	4
;lbL000AC2	dc.l	DENTRO.MSG
;DENTRO.MSG	dc.b	'DENTRO',0,0
;lbB000E7E	dc.b	$4B
;lbB000E7F	dc.b	$52

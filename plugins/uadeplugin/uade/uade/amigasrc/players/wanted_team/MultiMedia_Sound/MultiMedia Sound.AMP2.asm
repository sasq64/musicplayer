	******************************************************
	****        MultiMedia Sound replayer for	  ****
	****    EaglePlayer 2.00+ (Amplifier version),    ****
	****         all adaptions by Wanted Team	  ****
	******************************************************

	incdir	"dh2:include/"
	include 'misc/eagleplayer2.01.i'
	include	'misc/eagleplayerengine.i'
	include	'exec/exec_lib.i'

	SECTION	Player,CODE

	EPPHEADER Tags

	dc.b	'$VER: MultiMedia Sound (MMS.library V6.4) player module V2.1 (20 Dec 2007)',0
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
	dc.l	EP_GetPositionNr,GetPosition
	dc.l	EP_SampleInit,SampleInit
	dc.l	DTP_NextPatt,NextPattern
	dc.l	DTP_PrevPatt,BackPattern
	dc.l	EP_PatternInit,PatternInit
	dc.l	EP_InitAmplifier,InitAudstruct
	dc.l	EP_EagleBase,EagleBase
	dc.l	DTP_SubSongRange,SubSongRange
	dc.l	EP_Flags,EPB_Save!EPB_ModuleInfo!EPB_SampleInfo!EPB_Songend!EPB_Packable!EPB_Restart!EPB_PrevPatt!EPB_NextPatt!EPB_PrevSong!EPB_NextSong
	dc.l	0

PlayerName
	dc.b	'MultiMedia Sound',0
Creator
	dc.b	"(c) 1991-93 by Christian Haller and",10
	dc.b	'Christian A. Weber, adapted by WT',0
Prefix
	dc.b	'MMS.',0
	even
ModulePtr
	dc.l	0
SamplesPtr
	dc.l	0
SongTable
	ds.b	128
StartPos
	dc.l	0
TimerValue
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
	movem.l	D1,-(SP)
	move.w	A4,D1		;DFF0A0/B0/C0/D0
	sub.w	#$F0A0,D1
	lsr.w	#4,D1		;Number the channel from 0-3
	jsr	ENPP_PokeVol(A5)
	movem.l	(SP)+,D1
	rts

*---------------------------------------------------------------------------*
* Input		D0 = Address value
PokeAdr
	move.l	D1,-(SP)
	move.w	A4,D1		;DFF0A0/B0/C0/D0
	sub.w	#$F0A0,D1
	lsr.w	#4,D1		;Number the channel from 0-3
	jsr	ENPP_PokeAdr(A5)
	move.l	(SP)+,D1
	rts

*---------------------------------------------------------------------------*
* Input		D0 = Length value
PokeLen
	move.l	D1,-(SP)
	move.w	A4,D1		;DFF0A0/B0/C0/D0
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

LED_Off
	moveq	#1,D0
	moveq	#0,D1
	jsr	ENPP_PokeCommand(A5)
	rts

LED_On
	moveq	#1,D0
	moveq	#1,D1
	jsr	ENPP_PokeCommand(A5)
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

	move.w	#4,PI_Voices(A0)	; Number of stripes (MUST be at least 4)
	move.l	#CONVERTNOTE,PI_Convert(A0)
	moveq	#16,D0
	move.l	D0,PI_Modulo(A0)	; Number of bytes to next row
	move.w	#64,PI_Pattlength(A0)	; Length of each stripe in rows


	move.w	InfoBuffer+Patterns+2(PC),PI_NumPatts(A0)	; Overall Number of Patterns
	clr.w	PI_Pattern(A0)		; Current Pattern (from 0)
	clr.w	PI_Pattpos(A0)		; Current Position in Pattern (from 0)
	clr.w	PI_Songpos(A0)		; Current Position in Song (from 0)
	move.w	InfoBuffer+Length+2(PC),PI_MaxSongPos(A0)	; Songlength

	move.w	Speed(PC),PI_Speed(A0)

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

	move.w	(A0),D0
	bpl.b	NoSpecial
	move.w	D0,D2
	not.w	D2
	add.w	#16,D2		; special commands
	clr.w	D0
	rts
NoSpecial
	move.b	2(A0),D1
	and.b	#$F0,D1
	lsr.b	#4,D1
	btst	#4,(A0)
	beq.b	No31
	add.b	#$10,D1
No31
	move.b	2(A0),D2
	and.b	#15,D2
	move.b	3(A0),D3
	rts

* Sets some current values for the PatternInfo structure.
* Call this every time something changes (or at least every interrupt).
* You can move these elsewhere if necessary, it is only important that
* you make sure the structure fields are accurate and updated regularly.
PATINFO:
	movem.l	D0/D1/A0/A1,-(SP)

	lea	PATTERNINFO(PC),A0
	move.l	TrackPos(PC),D0
	move.w	D0,PI_Songpos(A0)	; Position in Song

	move.l	ModulePtr(PC),A1
	lea	$434(A1),A1
	moveq	#0,D1
	move.b	(A1,D0.W),D1
	move.w	D1,PI_Pattern(A0)	; Current Pattern
	move.l	PosCounter(PC),D0
	lsr.l	#4,D0
	move.w	D0,PI_Pattpos(A0)	; Current Position in Pattern

	lea	128(A1),A1
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
	movem.l	(SP)+,D0/D1/A0/A1
	rts

***************************************************************************
******************************* DTP_NextPatt ******************************
***************************************************************************

NextPattern
	lea	TrackPos(PC),A0
	move.l	(A0),D0
	addq.l	#1,D0
	cmp.w	AnzPat(PC),D0
	beq.b	MaxPos
	move.l	D0,(A0)+
	clr.l	(A0)
MaxPos
	rts

***************************************************************************
******************************* DTP_BackPatt ******************************
***************************************************************************

BackPattern
	lea	TrackPos(PC),A0
	move.l	(A0),D0
	cmp.l	StartPos(PC),D0
	beq.b	MinPos
	subq.l	#1,D0
	move.l	D0,(A0)+
	clr.l	(A0)
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

	lea	144(A2),A4
	move.l	SamplesPtr(PC),A1
	moveq	#30,D5
hop
	jsr	ENPP_AllocSampleStruct(A5)
	move.l	D0,(A3)
	beq.b	return
	move.l	D0,A3

	move.l	(A2)+,D0
	move.l	A1,EPS_Adr(A3)			; sample address
	move.l	D0,EPS_Length(A3)		; sample length
	move.l	A4,EPS_SampleName(A3)		; sample name
	move.l	#64,EPS_Volume(A3)
	move.w	#USITY_RAW,EPS_Type(A3)
	move.w	#22,EPS_MaxNameLen(A3)
	move.w	#USIB_Playable!USIB_Saveable!USIB_8BIT,EPS_Flags(A3)
	add.l	D0,A1
	lea	30(A4),A4
	dbf	D5,hop

	moveq	#0,D7
return
	move.l	D7,D0
	rts

***************************************************************************
****************************** EP_NewModuleInfo ***************************
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
SubSongs	=	68

InfoBuffer
	dc.l	MI_Pattern,0		;4
	dc.l	MI_LoadSize,0		;12
	dc.l	MI_Samples,0		;20
	dc.l	MI_Length,0		;28
	dc.l	MI_SamplesSize,0	;36
	dc.l	MI_Songsize,0		;44
	dc.l	MI_Calcsize,0		;52
	dc.l	MI_AuthorName,0		;60
	dc.l	MI_SubSongs,0		;68
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

	moveq	#30,D1
	moveq	#2,D2
	swap	D2
NextInfo
	move.l	(A0)+,D3
	btst	#0,D3
	bne.b	Fault
	cmp.l	D3,D2
	bcs.b	Fault
	dbf	D1,NextInfo
	cmp.l	#'SO31',(A0)+
	bne.b	Fault
	tst.w	(A0)
	beq.b	Fault
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
	move.l	A0,A1
	moveq	#0,D3
	moveq	#30,D0
NextInfo1
	add.l	(A1)+,D3
	dbf	D0,NextInfo1
	move.l	D3,SamplesSize(A4)

	bsr.w	GetSongSize

	move.l	D2,Patterns(A4)
	move.l	A3,(A6)				; SamplesPtr
	lea	(A3,D3.L),A2
	sub.l	A0,A2
	cmp.l	LoadSize(A4),A2
	ble.b	SizeOK
	moveq	#EPR_ModuleTooShort,D0
	rts
SizeOK
	move.l	A2,CalcSize(A4)
	sub.l	D3,A2
	move.l	A2,SongSize(A4)
	move.w	AnzPat(PC),Length+2(A4)
	moveq	#0,D0

	bsr.w	InstallInstruments
	
	move.l	D0,Samples(A4)

	moveq	#0,D0
	cmp.l	#95688,CalcSize(A4)		; Working In The Mine fix
	beq.b	OnlyOne
	cmp.w	#$1BB6,128(A0)			; too fast BPM
	bls.b	OnlyOne
	move.l	Length(A4),D2
	subq.l	#1,D2
	beq.b	OnlyOne
	move.l	ModulePtr(PC),A0
	lea	$435(A0),A1
	add.l	A1,D2
	lea	$4B8(A0),A2
	lea	SongTable+1(PC),A6
	move.l	A1,D4
NextPos
	moveq	#0,D1
	move.b	(A1)+,D1
	lsl.l	#8,D1
	lsl.l	#2,D1
	lea	(A2,D1.L),A0
	lea	1024(A0),A3
NextPatPos
	cmp.l	#$FFFE0000,(A0)
	bne.b	NoStopCom
	addq.l	#4,A0
	bra.b	CheckAdr
NoStopCom
	tst.l	(A0)+
	bne.b	NoSub
CheckAdr
	cmp.l	A0,A3
	bne.b	NextPatPos
	cmp.l	A1,D2
	beq.b	NoMore
	moveq	#0,D1
	move.b	(A1)+,D1
	lsl.l	#8,D1
	lsl.l	#2,D1
	lea	(A2,D1.L),A0
	lea	1024(A0),A3
NextPatPos2
	tst.l	(A0)+
	bne.b	SubFound
	cmp.l	A0,A3
	bne.b	NextPatPos2
	bra.b	OnlyOne
NoSub
back
	cmp.l	A1,D2
	bne.b	NextPos
NoMore
	tst.l	D0
	bne.b	LoopOK
OnlyOne
	lea	SongTable+1(PC),A6
LoopOK
	move.b	AnzPat+1(PC),(A6)
	addq.l	#1,D0
	move.l	D0,SubSongs(A4)

	bsr.b	FindName

	moveq	#0,D0
	rts

SubFound
	move.l	A1,D5
	sub.l	D4,D5
	move.b	D5,(A6)+
	move.b	D5,(A6)+
	subq.b	#1,-2(A6)
	addq.l	#1,D0
	bra.b	back

FindName
	move.l	ModulePtr(PC),A0
	lea	144(A0),A1			; A1 - begin sampleinfo
	move.l	A1,EPG_ARG1(A5)
	moveq	#30,D0				; D0 - length per one sampleinfo
	move.l	D0,EPG_ARG2(A5)
	moveq	#22,D0				; D0 - max. sample name
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
	move.l	TrackPos(PC),D0
	rts

***************************************************************************
***************************** DTP_InitSound *******************************
***************************************************************************

InitSound
	lea	ChannelData0(PC),A0
	moveq	#3,D2
NextData
	bsr.b	ClearData
	addq.l	#2,A0
	bsr.b	ClearData2
	dbf	D2,NextData

	move.l	ModulePtr(PC),A0
	bsr.w	SetLED
	move.l	TimerValue(PC),D1
	bne.b	TimerOK
	move.w	dtg_Timer(A5),D1
	mulu.w	#125,D1
	move.l	D1,TimerValue
TimerOK
	move.w	128(A0),D0
	divu.w	D0,D1
	lea	PATTERNINFO(PC),A0
	move.w	D1,PI_BPM(A0)			; Beats Per Minute
	move.w	D0,dtg_Timer(A5)

	move.w	dtg_SndNum(A5),D0
	lsl.w	#1,D0
	lea	SongTable(PC),A0
	move.b	(A0,D0.W),StartPos+3
	move.b	1(A0,D0.W),AnzPat+1

	bra.w	PlayEnable

ClearData
	moveq	#4,D1
ClearChannel
	clr.l	(A0)+
	dbf	D1,ClearChannel
	rts

ClearData2
	moveq	#6,D1
ClearChannel2
	clr.w	(A0)+
	dbf	D1,ClearChannel2
	rts

***************************************************************************
***************************** DTP_Interrupt *******************************
***************************************************************************

Interrupt
	movem.l	D1-A6,-(A7)

	move.l	EagleBase(PC),A5

	bsr.w	Play

	jsr	ENPP_Amplifier(A5)

	movem.l	(A7)+,D1-A6
	moveq	#0,D0
	rts

SongEnd
	movem.l	A1,-(A7)
	move.l	dtg_SongEnd(A5),A1
	jsr	(A1)
	movem.l	(A7)+,A1
	rts

***************************************************************************
**************************** MultiMedia Sound player **********************
***************************************************************************

; Player routine ripped from from mms.library (v6.4) (c) 1991-93 by Tension

;mmslibrary.MSG	dc.b	'mms.library',0
;	dc.b	'$VER: '
;MultiMediaSou.MSG	dc.b	'MultiMedia Sound 6.4 (2.1.93) CHH and CHW',$D,$A,0
;doslibrary.MSG	dc.b	'dos.library',0
;	dc.b	'audio.device',0
;MultiMediaSou.MSG0	dc.b	'MultiMedia Sound was written 1991/92 by Chri'
;	dc.b	'stian Haller ',$A
;	dc.b	'and Christian A. Weber',$A,0

SetLED
	move.b	$433(A0),D0
	beq.w	LEDOff
	cmp.w	#$FF,D0
	beq.w	LEDOn
	clr.b	$433(A0)
	bra.w	LEDOff

GetSongSize
	moveq	#0,D2
	move.b	$432(A0),D2
	move.w	D2,AnzPat
	lea	$434(A0),A1
	subq.w	#1,D2
	moveq	#0,D1
	moveq	#0,D0
SongLenLoop
	move.b	(A1)+,D0
	cmp.b	D0,D1
	bhi.b	LenHigher
	move.b	D0,D1
LenHigher
	dbf	D2,SongLenLoop
	move.l	D1,D0
	addq.w	#1,D0

		move.l	D0,D2

	mulu.w	#$400,D0
	lea	$4B8(A0),A3
	add.l	D0,A3
	rts

InstallInstruments
	move.l	ModulePtr(PC),A2
	lea	Instruments(PC),A1
	moveq	#30,D7
InstallSamples
	tst.l	(A2)
	beq.b	NoSample
	clr.l	(A3)

		addq.l	#1,D0

NoSample
	move.l	A3,(A1)+
	add.l	(A2)+,A3
	dbf	D7,InstallSamples
	rts

PlayEnable
	move.w	#6,Speed			; default speed
	clr.w	DmaCon
	clr.w	Timer
	move.l	StartPos(PC),TrackPos
	clr.l	PosCounter
	clr.w	BreakPat
	rts

Play
	movem.l	D1-D7/A0-A6,-(SP)
	addq.w	#1,Timer
	move.w	Speed(PC),D0
	cmp.w	Timer(PC),D0
	bne.b	CheckEffects
	clr.w	Timer
	bsr.w	PlaySound
	movem.l	(SP)+,D1-D7/A0-A6
	rts

CheckEffects
	moveq	#3,D7
	lea	ChannelData0(PC),A6
	lea	$DFF0A0,A3
EffLoop
	bsr.b	MakeEffects
	add.w	#$10,A3
	add.w	#$24,A6
	dbf	D7,EffLoop
	movem.l	(SP)+,D1-D7/A0-A6
	rts

MakeEffects
	move.w	$16(A6),D0
	beq.b	NoStep
	bmi.b	StepItUp
	add.w	D0,$18(A6)
	move.w	$18(A6),D0
	move.w	D0,$10(A6)
	move.w	$1A(A6),D1
	cmp.w	D0,D1
	bhi.b	StepOk1
	clr.w	$16(A6)
	move.w	D1,D0
	move.w	D0,$10(A6)
StepOk1
;	move.w	D0,6(A3)

		bsr.w	PokePer

	move.w	D0,$18(A6)
	rts

StepItUp
	add.w	D0,$18(A6)
	move.w	$18(A6),D0
	move.w	D0,$10(A6)
	move.w	$1A(A6),D1
	cmp.w	D0,D1
	blt.b	StepOk2
	clr.w	$16(A6)
	move.w	D1,D0
	move.w	D0,$10(A6)
StepOk2
;	move.w	D0,6(A3)

		bsr.w	PokePer

	move.w	D0,$18(A6)
	rts

NoStep
	move.b	2(A6),D0
	and.w	#15,D0
	tst.w	D0
	beq.b	NoCommand
	subq.w	#1,D0
	lsl.w	#2,D0
	lea	TableCommand(PC),A0
	move.l	0(A0,D0.W),D0
	beq.b	NoCommand
	move.l	D0,A0
	jsr	(A0)
NoCommand
	rts

TableCommand
	dc.l	appreggiato
	dc.l	pitchbend
	dc.l	0
	dc.l	Command4
	dc.l	0
	dc.l	0
	dc.l	SetStepUp
	dc.l	SetStepDown
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	SetSpeed

LEDOn
;	bset	#1,$BFE001

		bsr.w	LED_Off

	rts

LEDOff
;	bclr	#1,$BFE001

		bsr.w	LEDOn

	rts

SetStepDown
	st	D4
	bra.b	StepFinder

SetStepUp
	moveq	#0,D4
StepFinder
	clr.w	$16(A6)
	move.w	$10(A6),$18(A6)
	move.b	3(A6),D2
	and.w	#15,D2
	tst.w	D4
	beq.b	NoNegIt
	neg.w	D2
NoNegIt
	move.w	D2,$16(A6)
	moveq	#0,D2
	move.b	3(A6),D2
	lsr.w	#4,D2
	move.w	$10(A6),D0
	lea	NoteTable(PC),A0
StepUpFindLoop
	move.w	(A0),D1
	cmp.w	#-1,D1
	beq.w	EndStepUpFind
	cmp.w	D1,D0
	beq.b	StepUpFound
	addq.w	#2,A0
	bra.b	StepUpFindLoop

StepUpFound
	add.w	D2,D2
	tst.w	D4
	bne.b	NoNegStep
	neg.w	D2
NoNegStep
	move.w	0(A0,D2.W),D0
	move.w	D0,$1A(A6)
	rts

EndStepUpFind
	move.w	D0,$1A(A6)
	rts

appreggiato
	lea	ArpeTable(PC),A0
	moveq	#0,D0
	move.w	Timer(PC),D0
	cmp.w	#4,D0
	bhi.w	Arpe1
	subq.w	#1,D0
	lsl.w	#2,D0
	move.l	0(A0,D0.W),A0
	jmp	(A0)

ArpeTable
	dc.l	Arpe1
	dc.l	Arpe2
	dc.l	Arpe3
	dc.l	Arpe2
	dc.l	Arpe1

Arpe4
	add.w	D0,D0
	move.w	$10(A6),D1
	lea	NoteTable(PC),A0
Arpe5
	move.w	0(A0,D0.L),D2
	tst.w	(A0)
	bmi.b	NoArpe
	cmp.w	(A0),D1
	beq.b	Arpe6
	addq.w	#2,A0
	bra.b	Arpe5

Arpe1
	moveq	#0,D0
	move.b	3(A6),D0
	lsr.b	#4,D0
	bra.b	Arpe4

Arpe2
	moveq	#0,D0
	move.b	3(A6),D0
	and.b	#15,D0
	bra.b	Arpe4

Arpe3
	move.w	$10(A6),D2
Arpe6
;	move.w	D2,6(A3)

		move.l	D0,-(SP)
		move.w	D2,D0
		bsr.w	PokePer
		move.l	(SP)+,D0

	rts

NoArpe
	rts

pitchbend
	moveq	#0,D0
	move.b	3(A6),D0
	lsr.b	#4,D0
	tst.b	D0
	beq.b	pitch2
	move.w	$10(A6),D1
	and.w	#$1000,D1
	and.w	#$EFFF,$10(A6)
	add.w	D0,$10(A6)
	move.w	$10(A6),D0
;	move.w	D0,6(A3)

		bsr.w	PokePer

	or.w	D1,$10(A6)
	rts

pitch2
	moveq	#0,D0
	move.b	3(A6),D0
	and.b	#15,D0
	tst.b	D0
	beq.b	pitch3
	move.w	$10(A6),D1
	and.w	#$1000,D1
	and.w	#$EFFF,$10(A6)
	sub.w	D0,$10(A6)
	move.w	$10(A6),D0
;	move.w	D0,6(A3)

		bsr.w	PokePer

	or.w	D1,$10(A6)
pitch3
	rts

Command4
	MOVEQ	#0,D0
	MOVE.B	3(A6),D0
	BEQ.S	lbC000886
	MOVE.B	D0,$22(A6)
lbC000886	MOVE.B	$23(A6),D0
	LSR.W	#2,D0
	ANDI.W	#$1F,D0
	MOVEQ	#0,D1
	MOVE.B	lbW0008C6(PC,D0.W),D1
	MOVE.B	$22(A6),D0
	ANDI.W	#15,D0
	MULU.W	D0,D1
	LSR.W	#7,D1
	MOVE.W	$10(A6),D0
	TST.B	$23(A6)
	BMI.S	lbC0008B0
	ADD.W	D1,D0
	BRA.S	lbC0008B2

lbC0008B0	SUB.W	D1,D0
lbC0008B2
;	MOVE.W	D0,6(A3)

		bsr.w	PokePer

	MOVE.B	$22(A6),D0
	LSR.W	#2,D0
	ANDI.W	#$3C,D0
	ADD.B	D0,$23(A6)
	RTS

lbW0008C6	dc.w	$18
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

SetSpeed
	moveq	#0,D2
	move.b	3(A6),D2
	and.w	#$1F,D2
	bne.b	SpeedOK
	moveq	#1,D2
SpeedOK
	move.w	D2,Speed
	rts

PlaySound
	move.l	ModulePtr(PC),A0
	lea	$434(A0),A2
	lea	$90(A0),A3
	lea	$4B8(A0),A0
	move.l	TrackPos(PC),D0
	moveq	#0,D1
	move.b	0(A2,D0.L),D1
	moveq	#10,D7
	lsl.l	D7,D1
	add.l	PosCounter(PC),D1
	clr.w	DmaCon
	lea	$DFF0A0,A4
	lea	ChannelData0(PC),A6
	moveq	#3,D7
SoundHandleLoop
	bsr.w	PlayNote
	add.w	#$10,A4
	add.w	#$24,A6
	dbf	D7,SoundHandleLoop
	move.w	DmaCon(PC),D0
	or.w	#$8000,D0
;	move.w	D0,$DFF096

		bsr.w	PokeDMA

	lea	ChannelData3(PC),A6
	lea	$DFF0D0,A4
	moveq	#3,D7
SetRegsLoop
;	move.l	10(A6),(A4)
;	move.w	14(A6),4(A4)

		move.l	D0,-(SP)
		move.l	10(A6),D0
		bsr.w	PokeAdr
		move.w	14(A6),D0
		bsr.w	PokeLen
		move.l	(SP)+,D0

	sub.w	#$24,A6
	sub.w	#$10,A4
	dbf	D7,SetRegsLoop

	tst.w	BreakPat
	beq.b	NoBreakPat
	move.l	#$3F0,PosCounter
	clr.w	BreakPat
NoBreakPat
	add.l	#$10,PosCounter
	cmp.l	#$400,PosCounter
	blt.b	NoEndPattern
	clr.l	PosCounter
	addq.l	#1,TrackPos
	move.w	AnzPat(PC),D0
	move.l	TrackPos(PC),D1
	cmp.w	D0,D1
	bne.b	NoEndPattern
	move.l	StartPos(PC),TrackPos

		bsr.w	SongEnd
NoEndPattern
		bsr.w	PATINFO
	rts

PlayNote
	tst.b	$14(A6)
	bne.b	NoGetNote
	clr.l	(A6)
	move.l	0(A0,D1.L),(A6)
NoGetNote
	addq.w	#4,D1
	moveq	#0,D2
	cmp.w	#-3,(A6)
	beq.w	NoInstr2
	tst.w	(A6)
	bmi.w	NoInstr2
	clr.b	$23(A6)
	move.b	2(A6),D2
	and.b	#$F0,D2
	lsr.b	#4,D2
	btst	#4,(A6)
	beq.b	Only15
	add.b	#$10,D2
Only15
	move.w	$12(A6),D3
	tst.b	D2
	beq.w	NoInstr
	lea	Instruments(PC),A1
	subq.w	#1,D2
	move.w	D2,D4
	lsl.w	#2,D2
	mulu.w	#$1E,D4
	move.l	0(A1,D2.W),4(A6)
	move.w	$16(A3,D4.L),8(A6)
	move.w	$18(A3,D4.L),$12(A6)
	moveq	#0,D3
	move.w	$1A(A3,D4.L),D3
	tst.w	D3
	beq.b	NoRepeat
	move.l	4(A6),D2
	add.l	D3,D2
	move.l	D2,10(A6)
	move.w	$1C(A3,D4.W),14(A6)
	move.w	$12(A6),D3
	bra.b	NoInstr

NoRepeat
	move.l	4(A6),D2
	add.l	D3,D2
	move.l	D2,10(A6)
	move.w	$1C(A3,D4.L),14(A6)
	move.w	$12(A6),D3
NoInstr
	move.b	2(A6),D2
	and.w	#15,D2
	cmp.b	#12,D2
	beq.w	SetVolume1
	cmp.b	#5,D2
	beq.b	ChangeUpVolume
	cmp.b	#6,D2
	bne.b	SetVolume2
	moveq	#0,D2
	move.b	3(A6),D2
	sub.w	D2,D3
	tst.w	D3
	bpl.b	SetVolume2
	clr.w	D3
	bra.b	SetVolume2

ChangeUpVolume
	moveq	#0,D2
	move.b	3(A6),D2
	add.w	D2,D3
	cmp.w	#$40,D3
	ble.b	SetVolume2
	moveq	#$40,D3
	bra.b	SetVolume2

SetVolume1
	moveq	#0,D3
	move.b	3(A6),D3
SetVolume2
;	move.w	D3,8(A4)

		move.l	D0,-(SP)
		move.l	D3,D0
		bsr.w	PokeVol
		move.l	(SP)+,D0

	move.w	D3,$12(A6)
NoInstr2
	cmp.w	#-3,(A6)
	bne.b	NoPic
	clr.w	2(A6)
	bra.b	NoSuper
NoPic
	cmp.w	#-5,(A6)
	beq.b	lbC000ADA
	cmp.w	#-4,(A6)
	bne.b	NoJump
	st	BreakPat
lbC000ADA
	clr.w	(A6)
	bra.w	NoNote

NoJump
	tst.w	(A6)
	beq.b	NoSuper
	clr.w	$16(A6)
	move.w	(A6),D0
	and.w	#$EFFF,D0
	move.w	D0,$10(A6)
	move.w	$14(A6),D0
	ext.w	D0
;	move.w	D0,$DFF096

		bsr.w	PokeDMA

	cmp.w	#-2,(A6)
	bne.b	NoStop
	clr.w	$12(A6)
;	move.w	#0,8(A4)

		move.l	D0,-(SP)
		moveq	#0,D0	
		bsr.w	PokeVol
		move.l	(SP)+,D0

	bra.b	Super

NoStop
;	move.l	4(A6),(A4)
;	move.w	8(A6),4(A4)
;	move.w	(A6),D0
;	and.w	#$EFFF,D0
;	move.w	D0,6(A4)

		movem.l	D0/A3,-(SP)
		move.l	4(A6),D0
		bsr.w	PokeAdr
		move.w	8(A6),D0
		bsr.w	PokeLen
		move.w	(A6),D0
		and.w	#$EFFF,D0
		move.l	A4,A3
		bsr.w	PokePer
		movem.l	(SP)+,D0/A3

Super
	move.w	$14(A6),D0
	ext.w	D0
	or.w	D0,DmaCon
NoSuper
	clr.b	$14(A6)
NoNote
	rts

Reserve
	dc.w	$434
	dc.w	$434
	dc.w	$434
	dc.w	$434
	dc.w	$434
	dc.w	$434
	dc.w	$434
	dc.w	$434
	dc.w	$434
	dc.w	$434
	dc.w	$434
	dc.w	$434
	dc.w	$434
	dc.w	$434
	dc.w	$434
	dc.w	$434
	dc.w	$434
	dc.w	$434
	dc.w	$434
	dc.w	$434
NoteTable
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
	dc.w	$71
	dc.w	$71
	dc.w	$71
	dc.w	$71
	dc.w	$71
	dc.w	$71
	dc.w	$71
	dc.w	$71
	dc.w	$71
	dc.w	$71
	dc.w	$71
	dc.w	$71
	dc.w	$71
	dc.w	$71
	dc.w	$71
	dc.w	$71
	dc.w	$71
	dc.w	$71
	dc.w	$71
	dc.w	$71
	dc.w	$71
	dc.w	$71
	dc.w	$71
	dc.w	$71
	dc.w	$71
	dc.w	$71
	dc.w	$FFFF

Instruments
	ds.l	31
TrackPos
	ds.l	1
PosCounter
	ds.l	1
Timer
	ds.w	1
Speed
	ds.w	1
DmaCon
	ds.w	1
BreakPat
	ds.w	1
AnzPat
	dc.w	1

ChannelData0
	ds.b	20
	dc.w	1
StepControl0
	ds.b	14
ChannelData1
	ds.b	20
	dc.w	2
StepControl1
	ds.b	14
ChannelData2
	ds.b	20
	dc.w	4
StepControl2
	ds.b	14
ChannelData3
	ds.b	20
	dc.w	8
StepControl3
	ds.b	14

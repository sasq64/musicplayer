	*****************************************************
	****           Blade Packer replayer for	 ****
	****    EaglePlayer 2.00+ (Amplifier version),   ****
	****         all adaptions by Wanted Team        ****
	*****************************************************

	incdir	"dh2:include/"
	include 'misc/eagleplayer2.01.i'
	include	'misc/eagleplayerengine.i'
	include	'exec/exec_lib.i'

	SECTION Player,CODE

	EPPHEADER Tags

	dc.b	'$VER: Blade Packer player module V2.0 (13 Nov 2002)',0
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
	dc.l	DTP_ExtLoad,ExtLoad
	dc.l	EP_GetPositionNr,GetPosition
	dc.l	EP_SampleInit,SampleInit
	dc.l	EP_Save,Save
	dc.l	EP_PatternInit,PatternInit
	dc.l	DTP_NextPatt,Next_Pattern
	dc.l	DTP_PrevPatt,BackPattern
	dc.l	EP_InitAmplifier,InitAudstruct
	dc.l	EP_EagleBase,EagleBase
	dc.l	EP_Flags,EPB_Save!EPB_ModuleInfo!EPB_SampleInfo!EPB_Songend!EPB_NextSong!EPB_PrevSong!EPB_Packable!EPB_Restart!EPB_PrevPatt!EPB_NextPatt
	dc.l	TAG_DONE
PlayerName
	dc.b	'Blade Packer',0
Creator
	dc.b	"(c) 1991-96 by Tord 'Blade' Jansson,",10
	dc.b	"adapted by Wanted Team",0
Prefix
	dc.b	'UDS.',0
SMP
	dc.b	'SMP.',0
	even
ModulePtr
	dc.l	0
SamplesAdr
	dc.l	0
SamplesPtr
	dc.l	0
SongTable
	ds.b	128
RepeatVal
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
* Input		D0 = Bitmask
PokeDMA
	movem.l	D1/A5,-(SP)
	move.w	D0,D1
	and.w	#$8000,D0	;D0.w neg=enable ; 0/pos=disable
	and.l	#15,D1		;D1 = Mask (LONG !!)
	move.l	EagleBase(PC),A5
	jsr	ENPP_DMAMask(a5)
	movem.l	(SP)+,D1/A5
	rts

***************************************************************************
******************************* DTP_NextPatt ******************************
***************************************************************************

Next_Pattern
	move.l	dtg_StopInt(A5),A0
	jsr	(A0)
	bsr.b	SetData
	move.l	dtg_StartInt(A5),A0
	jsr	(A0)
	rts

SetData
	move.l	lbL062FC2(PC),A0
	cmp.w	#$DD48,(A0)
	bne.b	NoEnd
	move.l	lbL062FC6(PC),A0
	bsr.w	SongEnd
NoEnd
	move.w	lbW062FC0(PC),D2
	subq.w	#1,D2
	move.w	lbW062FBE(PC),D1
	addq.l	#5,D1
	lea	lbL062FDC(PC),A1
	move.l	lbL062FCA(PC),D4
	lea	STRIPE1(PC),A2
NextChannel
	moveq	#0,D3
	move.b	(A0)+,D3
	rol.w	D1,D3
	add.l	D4,D3
	move.l	D3,(A1)+
	move.l	D3,(A2)+
	dbf	D2,NextChannel
	move.l	A0,lbL062FC2
	move.w	#$3F,lbW062FD6
	lea	lbW0348E8(PC),A0
	moveq	#0,D0
	move.l	D0,(A0)+
	move.l	D0,(A0)+
	move.l	D0,(A0)+
	move.l	D0,(A0)+
;	CLR.W	lbB062FDA
	rts

***************************************************************************
******************************* DTP_BackPatt ******************************
***************************************************************************

BackPattern
	move.l	ModulePtr(PC),A1
	move.l	lbL062FC2(PC),A3
	move.w	lbW062FC0(PC),D0
	addq.l	#8,A1
	lsl.w	#1,D0
	sub.w	D0,A3
	cmp.l	A1,A3
	blt.b	MinPos
	move.l	dtg_StopInt(A5),A0
	jsr	(A0)
	move.l	A3,lbL062FC2
	bsr.b	SetData
	move.l	dtg_StartInt(A5),A0
	jsr	(A0)
MinPos
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
STRIPE5 DS.L	1
STRIPE6 DS.L	1
STRIPE7 DS.L	1
STRIPE8 DS.L	1

* More stripes go here in case you have more than 4 channels.


* Called at various and sundry times (e.g. StartInt, apparently)
* Return PatternInfo Structure in A0
PatternInit
	lea	PATTERNINFO(PC),A0
	move.w	InfoBuffer+Voices+2(PC),PI_Voices(A0)	; Number of stripes (MUST be at least 4)
	move.l	#CONVERTNOTE,PI_Convert(A0)
	move.w	#64,PI_Pattlength(A0)	; Length of each stripe in rows

	move.w	#6,PI_Speed(A0)		; Default Speed Value
	clr.w	PI_Pattpos(A0)		; Current Position in Pattern (from 0)
	clr.w	PI_Songpos(A0)		; Current Position in Song (from 0)
	move.w	InfoBuffer+Length+2(PC),PI_MaxSongPos(A0)	; Songlength

	move.w	#125,PI_BPM(A0)
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

	moveq	#1,D0		; Period? Note?
	moveq	#0,D1		; Sample number
	moveq	#0,D2		; Command string
	moveq	#0,D3		; Command argument
	move.l	lbL062FCE(PC),A1
	cmp.w	lbW062FBE(PC),D0
	beq.b	ShortVer
	move.w	(A0),D0
	bra.b	SkipIt
ShortVer
	move.b	(A0),D0
SkipIt
	lsl.w	#2,D0
	add.w	D0,A1
	move.b	2(A1),D2
	lsr.w	#2,D2
	move.b	3(A1),D3
	move.b	1(A1),D1
	moveq	#0,D0
	move.b	(A1),D0
	beq.b	NoNote
	lea	lbB03523A(PC),A1
	move.w	(A1,D0.W),D0
NoNote
	rts

PATINFO
	movem.l	D0/A0-A2,-(SP)
	bsr.w	GetPosition
	lea	PATTERNINFO(PC),A0
	move.w	D0,PI_Songpos(A0)
	moveq	#1,D0
	add.w	lbB062FD8(PC),D0
	move.w	D0,PI_Speed(A0)			; Speed Value
	moveq	#64,D0
	sub.w	lbW062FD6(PC),D0
	move.w	D0,PI_Pattpos(A0)		; Current Position in Pattern
	movem.l	(SP)+,D0/A0-A2
	rts

***************************************************************************
********************************* EP_Save *********************************
***************************************************************************

	*------------------- Save Mem to Disk ----------------------*
	*---- ARG1 = StartAdr					----*
	*---- ARG2 = EndAdr					----*
	*---- ARG3 = PathAdr					----*

Save
	move.l	EPG_ARG1(A5),A2
	move.l	EPG_ARG2(A5),A3
	move.l	dtg_PathArrayPtr(A5),EPG_ARG3(A5)
	move.l	ModulePtr(PC),EPG_ARG1(A5)
	move.l	InfoBuffer+SongSize(PC),EPG_ARG2(A5)
	moveq	#-1,D0
	move.l	D0,EPG_ARG4(A5)
	clr.l	EPG_ARG5(A5)
	moveq	#5,D0
	move.l	D0,EPG_ARGN(A5)
	move.l	EPG_SaveMem(A5),A0
	jsr	(A0)
	bne.b	NoSave
	move.l	dtg_PathArrayPtr(A5),A0
	clr.b	(A0)
	move.l	A2,A0
	move.l	dtg_CopyString(A5),A1
	jsr	(A1)
	lea	SMP(PC),A0
	move.l	dtg_CopyString(A5),A1
	jsr	(A1)
	move.l	A3,A0
	addq.l	#4,A0
	move.l	dtg_CopyString(A5),A1
	jsr	(A1)
	move.l	dtg_PathArrayPtr(A5),EPG_ARG3(A5)
	move.l	SamplesAdr(PC),EPG_ARG1(A5)
	move.l	InfoBuffer+SamplesSize(PC),D0
	move.l	D0,EPG_ARG2(A5)
	moveq	#-1,D0
	move.l	D0,EPG_ARG4(A5)
	moveq	#2,D0
	move.l	D0,EPG_ARG5(A5)
	moveq	#5,D0
	move.l	D0,EPG_ARGN(A5)
	move.l	EPG_SaveMem(A5),A0
	jsr	(A0)
NoSave
	rts

***************************************************************************
******************************* EP_SampleInit *****************************
***************************************************************************

SampleInit
	moveq	#EPR_NotEnoughMem,D7
	lea	EPG_SampleInfoStructure(A5),A3
	move.l	SamplesPtr(PC),D0
	beq.b	return
	move.l	D0,A0

	move.l	A0,A1
	move.l	(A0),D5
	lsr.l	#4,D5
	subq.l	#1,D5
hop
	jsr	ENPP_AllocSampleStruct(A5)
	move.l	D0,(A3)
	beq.b	return
	move.l	D0,A3

	move.l	(A0)+,D0
	move.l	(A0)+,D1
	sub.l	D0,D1
	subq.l	#4,D0
	add.l	A1,D0
	move.l	D0,EPS_Adr(A3)			; sample address
	move.l	D1,EPS_Length(A3)		; sample length
	move.l	#64,EPS_Volume(A3)
	move.w	#USITY_RAW,EPS_Type(A3)
	move.w	#USIB_Playable!USIB_Saveable!USIB_8BIT,EPS_Flags(A3)
	addq.l	#8,A0
	dbf	D5,hop

	moveq	#0,D7
return
	move.l	D7,D0
	rts

***************************************************************************
********************************* EP_GetPosNr *****************************
***************************************************************************

GetPosition
	move.l	lbL062FC2(PC),D0
	move.l	ModulePtr(PC),A0
	sub.l	A0,D0
	subq.l	#8,D0
	lsr.l	#2,D0
	cmp.b	#$34,6(A0)
	beq.b	Cztery
	lsr.l	#1,D0
Cztery
	rts

***************************************************************************
******************************** EP_Check5 ********************************
***************************************************************************

Check5
	movea.l	dtg_ChkData(A5),A0
	moveq	#-1,D0

	cmp.l	#$538F4E47,(A0)+
	bne.b	error
	cmp.b	#$2E,(A0)
	bne.b	error
	moveq	#0,D0
error
	rts

***************************************************************************
******************************* DTP_ExtLoad *******************************
***************************************************************************

ExtLoad
	move.l	dtg_ChkData(A5),A1
	move.l	4.W,A6
	jsr	_LVOTypeOfMem(A6)
	moveq	#1,D6
	moveq	#0,D7
	btst	#1,D0
	beq.b	NoChip
	moveq	#2,D7
NoChip
	move.l	dtg_PathArrayPtr(A5),A0
	clr.b	(A0)
	move.l	dtg_CopyDir(A5),A0
	jsr	(A0)
	bsr.s	CopyName
	move.l	D7,EPG_ARG1(A5)
	move.l	D6,EPG_ARGN(A5)
	jmp	ENPP_NewLoadFile(A5)

CopyName
	move.l	dtg_PathArrayPtr(A5),A0
loop
	tst.b	(A0)+
	bne.s	loop
	subq.l	#1,A0
	move.l	A0,A3
	move.l	dtg_FileArrayPtr(A5),A1
smp
	move.b	(A1)+,(A0)+
	bne.s	smp

	cmpi.b	#'U',(A3)
	beq.b	U_OK
	cmpi.b	#'u',(A3)
	bne.s	ExtError
U_OK
	cmpi.b	#'D',1(A3)
	beq.b	D_OK
	cmpi.b	#'d',1(A3)
	bne.s	ExtError
D_OK
	cmpi.b	#'S',2(A3)
	beq.b	S_OK
	cmpi.b	#'s',2(A3)
	bne.s	ExtError
S_OK
	cmpi.b	#'.',3(A3)
	bne.s	ExtError

	move.b	#'S',(A3)+
	move.b	#'M',(A3)+
	move.b	#'P',(A3)

	bra.b	ExtOK
ExtError
	clr.b	-2(A0)
ExtOK
	clr.b	-1(A0)
	rts

***************************************************************************
***************************** EP_NewModuleInfo ****************************
***************************************************************************

NewModuleInfo

SubSongs	=	4
LoadSize	=	12
CalcSize	=	20
Pattern		=	28
Length		=	36
SamplesSize	=	44
SongSize	=	52
Samples		=	60
Voices		=	68

InfoBuffer
	dc.l	MI_SubSongs,0		;4
	dc.l	MI_LoadSize,0		;12
	dc.l	MI_Calcsize,0		;20
	dc.l	MI_Pattern,0		;28
	dc.l	MI_Length,0		;36
	dc.l	MI_SamplesSize,0	;44
	dc.l	MI_Songsize,0		;52
	dc.l	MI_Samples,0		;60
	dc.l	MI_Voices,0		;68
	dc.l	MI_MaxVoices,8
	dc.l	MI_MaxPattern,256
	dc.l	MI_MaxLength,128
	dc.l	MI_Prefix,Prefix
	dc.l	0

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
	move.l	A0,A2
	add.l	D0,A2

	moveq	#-4,D1
FindIt1
	cmp.w	#$DD48,(A1)
	beq.b	OK1
	addq.l	#1,D1
	addq.l	#2,A1
	cmp.l	A1,A2
	blt.w	Corrupt
	bra.b	FindIt1
OK1
	move.l	A1,D5
	moveq	#4,D0
	lsr.l	#1,D1
	cmp.b	#$38,6(A0)
	bne.b	NoHalf
	lsr.l	#1,D1
	moveq	#8,D0
NoHalf
	move.l	D1,Length(A4)
	move.l	D0,Voices(A4)
	move.l	D0,D7
	move.l	A1,A3

	addq.l	#2,A1
	moveq	#0,D0
FindIt2
	cmp.w	#$D8F1,(A1)
	beq.b	OK2
	cmp.b	#$42,5(A0)
	bne.b	NoShort
	cmp.b	(A1),D0
	bhi.b	NoMax1
	move.b	(A1),D0
NoMax1
	cmp.b	1(A1),D0
	bhi.b	NoMax
	move.b	1(A1),D0
	bra.b	NoMax
NoShort
	cmp.w	(A1),D0
	bhi.b	NoMax
	move.w	(A1),D0
NoMax
	addq.l	#2,A1
	cmp.l	A1,A2
	blt.w	Corrupt
	bra.b	FindIt2
OK2
	move.l	A1,D2
	sub.l	A3,D2
	subq.l	#2,D2
	lsr.l	#6,D2
	moveq	#1,D3
	cmp.b	#$42,5(A0)
	beq.b	Half
	lsr.l	#1,D2
	moveq	#2,D3
Half
	lea	PATTERNINFO(PC),A3
	move.l	D3,PI_Modulo(A3)	; Number of bytes to next row
	move.l	D2,Pattern(A4)
	addq.l	#2,A1
	move.l	A1,A3
	addq.l	#1,D0
	lsl.l	#2,D0
	add.l	D0,A1
	sub.l	A0,A1	
	cmp.l	LoadSize(A4),A1
	ble.b	SizeOK
	moveq	#EPR_ModuleTooShort,D0		; error message
	rts
SizeOK	
	move.l	A1,SongSize(A4)
	move.l	A1,CalcSize(A4)

	movem.l	A4/A5/A6,-(SP)
	moveq	#0,D0			; subsongs
	lea	8(A0),A5
	lea	SongTable+1(PC),A6
	move.l	D5,A2
	addq.l	#2,A2			; First Pattern
	moveq	#0,D4
NextPos
	move.l	D4,D1
	mulu.w	D7,D1
	lea	(A5,D1.W),A1
	cmp.l	A1,D5
	beq.b	ExitSub
	lea	(A1,D7.W),A0
	addq.l	#1,D4
	move.l	A0,D2
NextByte
	moveq	#0,D1
	move.b	(A1)+,D1
	lsl.l	#6,D1			; * 64
	btst	#0,D3
	bne.b	Single
	lsl.l	#1,D1
Single
	lea	(A2,D1.L),A0
	moveq	#63,D6
NextRow
	moveq	#0,D1
	btst	#0,D3
	beq.b	Double
	move.b	(A0)+,D1
	bra.b	SkipDouble
Double
	move.w	(A0)+,D1
SkipDouble
	lsl.l	#2,D1			; * 4
	lea	2(A3,D1.W),A4
	cmp.b	#$2C,(A4)		; jump command
	beq.b	SubFound
	cmp.b	#$20,(A4)		; special (?) pinball command
	beq.b	SubFound
	bra.b	SkipSub
SubFound
	move.b	D4,(A6)+
	addq.l	#1,D0
	bra.b	NextPos
SkipSub
	dbf	D6,NextRow
ExitRow
	cmp.l	A1,D2
	bne.b	NextByte
	bra.b	NextPos

ExitSub
	tst.l	D0
	bne.b	LoopOK
	moveq	#1,D0
LoopOK
	movem.l	(SP)+,A4/A5/A6
	move.l	D0,SubSongs(A4)

	moveq	#1,D0
	jsr	ENPP_GetListData(A5)

	move.l	A0,(A6)+			; SampleAdr
	moveq	#4,D5
	cmp.l	#$1F4,(A0)
	beq.b	NoHeader
	cmp.l	#'SPLS',(A0)+
	bne.b	Corrupt
	moveq	#0,D5
NoHeader
	move.l	(A0),D2
	lsr.l	#4,D2
	subq.l	#1,D2
	move.l	A0,(A6)				; SamplesPtr
	add.l	D0,LoadSize(A4)

	moveq	#0,D1
	moveq	#0,D3
NextInfo
	move.l	(A0)+,D0
	move.l	(A0),D4
	sub.l	(A0)+,D0
	beq.b	NoSample
	cmp.l	D4,D3
	bge.b	MaxLen
	move.l	D4,D3
MaxLen
	addq.l	#1,D1
NoSample
	addq.l	#8,A0
	dbf	D2,NextInfo
	move.l	D1,Samples(A4)
	sub.l	D5,D3
	move.l	D3,SamplesSize(A4)
	add.l	D3,CalcSize(A4)

	moveq	#0,D0
	rts

Corrupt
	moveq	#EPR_CorruptModule,D0
	rts

***************************************************************************
***************************** DTP_Intterrupt ******************************
***************************************************************************

Interrupt
	movem.l	D1-A6,-(SP)

	bsr.w	Play1
	bsr.w	Play2

	move.l	EagleBase(PC),A5
	jsr	ENPP_Amplifier(A5)

	movem.l	(SP)+,D1-A6
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
***************************** DTP_InitSound *******************************
***************************************************************************

InitSound
	lea	lbW062FB8(PC),A0
	lea	BufferEnd(PC),A1
Clear
	clr.w	(A0)+
	cmp.l	A0,A1
	bne.b	Clear

	move.l	ModulePtr(PC),A0
	move.l	SamplesPtr(PC),A1
	bsr.w	Init1
	bsr.w	Init2
	move.w	dtg_SndNum(A5),D0
	lea	SongTable(PC),A0
	move.b	(A0,D0.W),D0
	move.w	D0,lbW0351BA
	move.w	D0,RepeatVal
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
**************************** Blade Packer player **************************
***************************************************************************

; Player from preview of game Obsession (c) 1995 by Unique Development Sweden

;Init
;	LEA	lbL03A5F8,A0
;	LEA	lbL040C94,A1
;	JSR	lbC025560
;	JSR	lbC025550
;	MOVE.W	#$3D,lbW0351BA
;	rts

;Play
;	JSR	lbC0347DC
;	JSR	lbC02581A
;	JSR	lbC0261F4
;	RTS

Init2
	MOVE.W	#1,lbB03495A
	JSR	lbC0347E0
	RTS

Init1
	MOVE.L	A1,lbL062FD2
	MOVE.L	A0,lbL0357C8
	CLR.W	lbW062FB8
	MOVEQ	#-1,D0
	MOVE.L	D0,lbW062FBA
	LEA	lbL0631DC(pc),A3
	LEA	lbW0356BC(pc),A2
	MOVEQ	#15,D0
lbC025588	MOVE.L	A2,(A3)+
	DBRA	D0,lbC025588
	MOVE.B	5(A0),D0
	MOVE.W	#1,lbW062FBE
	CMP.B	#$42,D0
	BEQ.S	lbC0255A8
	MOVE.W	#2,lbW062FBE
lbC0255A8	MOVE.B	6(A0),D0
	MOVE.W	#4,lbW062FC0
	CMP.B	#$34,D0
	BEQ.S	lbC0255C2
	MOVE.W	#8,lbW062FC0
lbC0255C2	LEA	8(A0),A1
	MOVE.L	A1,lbL062FC2
	MOVEQ	#0,D0
	MOVE.B	7(A0),D0
	CMPI.B	#$7F,D0
	BNE.S	lbC0255DA
	MOVEQ	#0,D0
lbC0255DA	MOVE.W	lbW062FC0(pc),D1
	MULU.W	D1,D0
	LEA	8(A0,D0.W),A1
	MOVE.L	A1,lbL062FC6
	ADDQ.L	#8,A0
lbC0255EE	CMPI.W	#$DD48,(A0)+
	BNE.S	lbC0255EE
	MOVE.L	A0,lbL062FCA
lbC0255FA	CMPI.W	#$D8F1,(A0)+
	BNE.S	lbC0255FA
	MOVE.L	A0,lbL062FCE
	MOVE.W	#5,lbB062FD8
	MOVE.W	#0,lbB062FDA
	RTS

lbC025618
;	TST.W	lbW0351B4
;	BEQ.L	lbC025666
	LEA	lbW0348E8(pc),A0
	MOVEQ	#0,D0
	MOVE.L	D0,(A0)+
	MOVE.L	D0,(A0)+
	MOVE.L	D0,(A0)+
	MOVE.L	D0,(A0)+
	CLR.W	lbW062FD6
	CLR.W	lbB062FDA
	MOVE.L	lbL0357C8(pc),D2
	ADDQ.L	#8,D2
	MOVEQ	#0,D0
	MOVE.W	lbW0351BA(pc),D0
	MOVE.W	lbW062FC0(pc),D1
	MULU.W	D1,D0
	ADD.L	D0,D2
	MOVE.L	D2,lbL062FC2
	MOVE.W	#$FFFF,lbW0351BA
lbC025666	RTS

;lbC025668	LEA	lbW062FD6(pc),A0
;	LEA	lbL034DCA(pc),A1
;	MOVE.W	(A1)+,(A0)+
;	MOVE.L	(A1)+,(A0)+
;	MOVEQ	#7,D0
;lbC02567A	MOVE.L	(A1)+,(A0)+
;	MOVE.L	(A1)+,(A0)+
;	MOVE.L	(A1)+,(A0)+
;	MOVE.L	(A1)+,(A0)+
;	MOVE.L	(A1)+,(A0)+
;	MOVE.L	(A1)+,(A0)+
;	MOVE.L	(A1)+,(A0)+
;	MOVE.L	(A1)+,(A0)+
;	DBRA	D0,lbC02567A
;	LEA	lbL0631BC(pc),A0
;	MOVEQ	#5,D0
;lbC025696	MOVE.L	(A1)+,(A0)+
;	MOVE.L	(A1)+,(A0)+
;	MOVE.L	(A1)+,(A0)+
;	MOVE.L	(A1)+,(A0)+
;	DBRA	D0,lbC025696
;	LEA	lbW0347E8(pc),A0
;	MOVE.L	(A1)+,(A0)+
;	MOVE.L	(A1)+,(A0)+
;	MOVE.L	(A1)+,(A0)+
;	MOVE.L	(A1)+,(A0)+
;	LEA	lbL034828(pc),A0
;	MOVE.L	(A1)+,(A0)+
;	MOVE.L	(A1)+,(A0)+
;	MOVE.L	(A1)+,(A0)+
;	MOVE.L	(A1)+,(A0)+
;	LEA	lbL034868(pc),A0
;	MOVE.L	(A1)+,(A0)+
;	MOVE.L	(A1)+,(A0)+
;	MOVE.L	(A1)+,(A0)+
;	MOVE.L	(A1)+,(A0)+
;	LEA	lbL0348A8(pc),A0
;	MOVE.L	(A1)+,(A0)+
;	MOVE.L	(A1)+,(A0)+
;	MOVE.L	(A1)+,(A0)+
;	MOVE.L	(A1)+,(A0)+
;	LEA	lbW0348E8(pc),A0
;	MOVE.L	(A1)+,(A0)+
;	MOVE.L	(A1)+,(A0)+
;	MOVE.L	(A1)+,(A0)+
;	MOVE.L	(A1)+,(A0)+
;	MOVE.L	(A1)+,lbL062FC2
;	MOVE.W	(A1)+,lbB03495A
;	MOVE.W	#$FFFF,lbW0351B4
;	MOVE.W	#$FFFF,lbW0351B6
;	RTS

;lbC025706	TST.W	lbW0351B4
;	BEQ.L	lbC0257A2
;	LEA	lbW062FD6(pc),A0
;	LEA	lbL034DCA(pc),A1
;	MOVE.W	(A0)+,(A1)+
;	MOVE.L	(A0)+,(A1)+
;	MOVEQ	#7,D0
;lbC025722	MOVE.L	(A0)+,(A1)+
;	MOVE.L	(A0)+,(A1)+
;	MOVE.L	(A0)+,(A1)+
;	MOVE.L	(A0)+,(A1)+
;	MOVE.L	(A0)+,(A1)+
;	MOVE.L	(A0)+,(A1)+
;	MOVE.L	(A0)+,(A1)+
;	MOVE.L	(A0)+,(A1)+
;	DBRA	D0,lbC025722
;	LEA	lbL0631BC(pc),A0
;	MOVEQ	#5,D0
;lbC02573E	MOVE.L	(A0)+,(A1)+
;	MOVE.L	(A0)+,(A1)+
;	MOVE.L	(A0)+,(A1)+
;	MOVE.L	(A0)+,(A1)+
;	DBRA	D0,lbC02573E
;	LEA	lbW0347E8(pc),A0
;	MOVE.L	(A0)+,(A1)+
;	MOVE.L	(A0)+,(A1)+
;	MOVE.L	(A0)+,(A1)+
;	MOVE.L	(A0)+,(A1)+
;	LEA	lbL034828(pc),A0
;	MOVE.L	(A0)+,(A1)+
;	MOVE.L	(A0)+,(A1)+
;	MOVE.L	(A0)+,(A1)+
;	MOVE.L	(A0)+,(A1)+
;	LEA	lbL034868(pc),A0
;	MOVE.L	(A0)+,(A1)+
;	MOVE.L	(A0)+,(A1)+
;	MOVE.L	(A0)+,(A1)+
;	MOVE.L	(A0)+,(A1)+
;	LEA	lbL0348A8(pc),A0
;	MOVE.L	(A0)+,(A1)+
;	MOVE.L	(A0)+,(A1)+
;	MOVE.L	(A0)+,(A1)+
;	MOVE.L	(A0)+,(A1)+
;	LEA	lbW0348E8(pc),A0
;	MOVE.L	(A0)+,(A1)+
;	MOVE.L	(A0)+,(A1)+
;	MOVE.L	(A0)+,(A1)+
;	MOVE.L	(A0)+,(A1)+
;	MOVE.L	lbL062FC2(pc),(A1)+
;	MOVE.W	lbB03495A(pc),(A1)+
;	CLR.W	lbW0351B4
;lbC0257A2	LEA	lbW0348E8(pc),A0
;	MOVEQ	#0,D0
;	MOVE.L	D0,(A0)+
;	MOVE.L	D0,(A0)+
;	MOVE.L	D0,(A0)+
;	MOVE.L	D0,(A0)+
;	LEA	lbL0631DC(pc),A3
;	LEA	lbW0356BC(pc),A2
;	MOVEQ	#3,D0
;lbC0257C0	MOVE.L	A2,(A3)+
;	MOVE.L	A2,(A3)+
;	MOVE.L	A2,(A3)+
;	MOVE.L	A2,(A3)+
;	DBRA	D0,lbC0257C0
;	LEA	lbL0631BC(pc),A0
;	MOVEQ	#0,D0
;	MOVE.L	D0,(A0)+
;	MOVE.L	D0,(A0)+
;	MOVE.L	D0,(A0)+
;	MOVE.L	D0,(A0)+
;	CLR.W	lbW062FD6
;	CLR.W	lbB062FDA
;	MOVE.W	#5,lbB062FD8
;	MOVE.L	lbL0357C8(pc),D2
;	ADDQ.L	#8,D2
;	MOVEQ	#0,D0
;	MOVE.W	lbW0351B8(pc),D0
;	MOVE.W	lbW062FC0(pc),D1
;	MULU.W	D1,D0
;	ADD.L	D0,D2
;	MOVE.L	D2,lbL062FC2
;	MOVE.W	#$FFFF,lbW0351B8
;	RTS

Play2
;	TST.W	lbW0351B6
;	BMI.S	lbC025828
;	JSR	lbC025668
;lbC025828	TST.W	lbW0351B8
;	BMI.S	lbC02583E
;	TST.W	lbW034DC4
;	BNE.S	lbC02583E
;	JSR	lbC025706
lbC02583E	TST.W	lbW0351BA
	BMI.S	lbC02584C
	JSR	lbC025618
lbC02584C	MOVE.W	lbB062FDA(pc),D0
	DBRA	D0,lbC0259B8
	TST.W	lbW062FB8
	BEQ.S	lbC025898
	TST.W	lbW062FBA
	BPL.S	lbC02588E
	MOVEQ	#0,D0
	MOVE.W	lbW062FBE(pc),D0
	LEA	lbL062FDC(pc),A0
	SUB.L	D0,(A0)+
	SUB.L	D0,(A0)+
	SUB.L	D0,(A0)+
	SUB.L	D0,(A0)+
	SUB.L	D0,(A0)+
	SUB.L	D0,(A0)+
	SUB.L	D0,(A0)+
	SUB.L	D0,(A0)+
	MOVE.L	#$FFFF,lbW062FBA
lbC02588E	SUBQ.W	#1,lbW062FB8
	BRA.L	lbC02593C

lbC025898	TST.W	lbW062FBA
	BMI.S	lbC0258BE
	MOVEQ	#0,D0
	MOVE.W	lbW062FBE(pc),D0
	LEA	lbL062FDC(pc),A0
	ADD.L	D0,(A0)+
	ADD.L	D0,(A0)+
	ADD.L	D0,(A0)+
	ADD.L	D0,(A0)+
	ADD.L	D0,(A0)+
	ADD.L	D0,(A0)+
	ADD.L	D0,(A0)+
	ADD.L	D0,(A0)+
lbC0258BE	MOVEQ	#-1,D0
	MOVE.L	D0,lbW062FBA
	MOVE.W	lbW062FD6(pc),D0
	DBRA	D0,lbC025936
	MOVEA.L	lbL062FC2(pc),A0
	CMPI.W	#$DD48,(A0)
	BNE.S	lbC0258E2
	MOVEA.L	lbL062FC6(pc),A0

	bsr.w	SongEnd

lbC0258E2	MOVE.L	A0,D3
	SUB.L	lbL0357C8(pc),D3
	SUBQ.L	#8,D3
	DIVU.W	lbW062FC0(pc),D3
;	LEA	lbL040C48,A1
;	MOVE.B	0(A1,D3.W),D3

	clr.b	D3

	ADDQ.L	#1,D3
	MOVE.B	D3,lbB03495B
	MOVE.W	lbW062FC0(pc),D2
	SUBQ.W	#1,D2
	MOVE.W	lbW062FBE(pc),D1
	ADDQ.L	#5,D1
	LEA	lbL062FDC(pc),A1
	MOVE.L	lbL062FCA(pc),D4

	lea	STRIPE1(PC),A2

lbC025920	MOVEQ	#0,D3
	MOVE.B	(A0)+,D3
	ROL.W	D1,D3
	ADD.L	D4,D3
	MOVE.L	D3,(A1)+

	move.l	D3,(A2)+

	DBRA	D2,lbC025920
	MOVE.L	A0,lbL062FC2
	MOVEQ	#$3F,D0
lbC025936	MOVE.W	D0,lbW062FD6

	bsr.w	PATINFO

lbC02593C	MOVEQ	#3,D0
	LEA	lbL062FDC(pc),A0
	LEA	lbL0631BC(pc),A1
	LEA	lbL062FFC(pc),A2
	MOVEA.L	lbL062FCE(pc),A3
	MOVEA.L	lbL062FD2(pc),A4
	LEA	lbW0347E8(pc),A5
	MOVE.W	lbB062FD8(pc),lbB062FDA
lbC02596C	MOVEA.L	(A0),A6
	MOVEQ	#1,D1
	CMP.W	lbW062FBE(pc),D1
	BEQ.S	lbC02597C
	MOVE.W	(A6)+,D1
	BRA.S	lbC02597E

lbC02597C	MOVE.B	(A6)+,D1
lbC02597E	TST.W	lbW062FBA
	BPL.S	lbC025988
	MOVE.L	A6,(A0)
lbC025988	ADDQ.L	#4,A0
	ADD.L	D1,D1
	ADD.L	D1,D1
	MOVEQ	#0,D2
	MOVE.B	2(A3,D1.W),D2
	MOVE.L	0(A3,D1.W),D1
	AND.L	lbW062FBA(pc),D1
	LEA	lbL0351BC(pc),A6
	MOVEA.L	0(A6,D2.W),A6
	JSR	(A6)
	ADDQ.W	#4,A5
	LEA	$38(A2),A2
	DBRA	D0,lbC02596C
	MOVEQ	#-1,D7
	BRA.S	lbC0259FA

lbC0259B8	MOVE.W	D0,lbB062FDA
	LEA	lbL0631BC(pc),A0
	LEA	lbL062FFC(pc),A2
	LEA	lbW0347E8(pc),A3
	MOVEA.L	(A0)+,A1
	JSR	(A1)
	LEA	$38(A2),A2
	ADDQ.W	#4,A3
	MOVEA.L	(A0)+,A1
	JSR	(A1)
	LEA	$38(A2),A2
	ADDQ.W	#4,A3
	MOVEA.L	(A0)+,A1
	JSR	(A1)
	LEA	$38(A2),A2
	ADDQ.W	#4,A3
	MOVEA.L	(A0)+,A1
	JSR	(A1)
	LEA	$38(A2),A2
	ADDQ.W	#4,A3
	MOVEQ	#0,D7
lbC0259FA	LEA	lbL063000(pc),A0
	LEA	lbL0347EA(pc),A1
	LEA	lbL0631BC(pc),A3
	MOVE.L	#lbC025FAA,D6
	MOVE.W	lbW062FC0(pc),D1
	SUBQ.W	#1,D1
lbC025A1A	CMP.L	(A3)+,D6
	BEQ.S	lbC025A36
lbC025A1E	MOVE.W	$22(A0),D0
	BMI.S	lbC025A26
	BRA.S	lbC025A28

lbC025A26	MOVE.W	(A0),D0
lbC025A28	MOVE.W	D0,(A1)
	ADDQ.W	#4,A1
	LEA	$38(A0),A0
	DBRA	D1,lbC025A1A
	RTS

lbC025A36	TST.W	D7
	BMI.S	lbC025A1E
	MOVE.W	$1C(A0),(A1)
	ADDQ.W	#4,A1
	LEA	$38(A0),A0
	DBRA	D1,lbC025A1A
	RTS

lbC025A4A	MOVE.W	D1,D3
	BEQ.L	lbC025AE6
	BSR.L	lbC025F1E
	MOVE.L	#lbC025FAA,(A1)+
	LEA	$16(A2),A6
	MOVE.L	A6,$1A(A2)
	MOVEQ	#0,D3
	MOVEA.L	(A2),A6
	MOVE.B	$11(A6),D3
	MULU.W	#$48,D3
	LEA	lbB03523A(pc),A6
	ADDA.W	D3,A6
	CMP.B	#$10,D1
	BLT.S	lbC025AAA
	MOVE.B	D1,D3
	ANDI.B	#15,D3
	BEQ.S	lbC025AC8
	ADDA.W	$1E(A2),A6
	MOVE.W	(A6),$14(A2)
	MOVE.B	D1,D3
	ANDI.W	#$F0,D3
	ROR.W	#3,D3
	MOVE.W	0(A6,D3.W),$16(A2)
	MOVE.B	D1,D3
	ANDI.W	#15,D3
	ADD.W	D3,D3
	MOVE.W	0(A6,D3.W),$18(A2)
	RTS

lbC025AAA	ADDA.W	$1E(A2),A6
	MOVE.W	(A6),$14(A2)
	MOVE.B	D1,D3
	ANDI.W	#15,D3
	ADD.W	D3,D3
	MOVE.W	0(A6,D3.W),$16(A2)
	MOVE.W	#$FFFF,$18(A2)
	RTS

lbC025AC8	ADDA.W	$1E(A2),A6
	MOVE.W	(A6),$16(A2)
	MOVE.B	D1,D3
	ANDI.W	#$F0,D3
	ROR.W	#3,D3
	MOVE.W	0(A6,D3.W),$14(A2)
	MOVE.W	#$FFFF,$18(A2)
	RTS

lbC025AE6	MOVE.L	#lbC025FA8,(A1)+
	BRA.L	lbC025F1E

lbC025AF0	MOVEQ	#0,D3
	MOVE.B	D1,D3
	MOVE.W	D3,6(A2)
	MOVE.L	#lbC025FCA,(A1)+
	BRA.L	lbC025F1E

lbC025B02	MOVEQ	#0,D3
	MOVE.B	D1,D3
	MOVE.W	D3,6(A2)
	MOVE.L	#lbC025FE2,(A1)+
	BRA.L	lbC025F1E

lbC025B14	MOVE.L	D1,D3
	ROL.L	#8,D3
	ANDI.W	#$FF,D3
	TST.W	D3
	BEQ.S	lbC025B2C
	LEA	lbB03523A(pc),A6
	MOVE.W	0(A6,D3.W),$10(A2)
lbC025B2C	MOVE.B	D1,D3
	BEQ.S	lbC025B34
	MOVE.W	D3,$12(A2)
lbC025B34	MOVE.L	D1,D3
	SWAP	D3
	ANDI.W	#$FF,D3
	TST.W	D3
	BEQ.S	lbC025B50
	MOVEA.L	lbL062FD2(pc),A6
	SUBQ.W	#1,D3
	ROL.W	#4,D3
	MOVE.B	12(A6,D3.W),$102(A5)
lbC025B50	MOVE.W	#$FFFF,$26(A2)
	MOVE.B	#$FF,$36(A2)
	MOVE.L	#lbC025FFA,(A1)+
	RTS

lbC025B64	MOVE.W	$26(A2),-(SP)
	BSR.L	lbC025F1E
	MOVE.W	(SP)+,$26(A2)
	TST.B	$24(A2)
	BEQ.S	lbC025B84
	CLR.B	$22(A2)
	MOVE.W	#$FFFF,$26(A2)
	CLR.B	$24(A2)
lbC025B84	MOVE.L	#lbC026022,(A1)+
	TST.B	D1
	BEQ.S	lbC025BA4
	MOVE.W	D1,D3
	LSR.W	#4,D3
	ANDI.W	#15,D3
	MOVE.B	D3,$23(A2)
	MOVE.W	D1,D3
	ANDI.W	#15,D3
	MOVE.B	D3,$25(A2)
lbC025BA4	RTS

lbC025BA6	MOVE.L	#lbC026072,(A1)+
	BRA.L	lbC025C92

lbC025BB0	MOVE.L	#lbC026076,(A1)+
	MOVE.B	D1,D3
	ANDI.W	#15,D3
	MOVE.W	D3,12(A2)
	MOVE.B	D1,D3
	ANDI.W	#$F0,D3
	LSR.W	#4,D3
	MOVE.W	D3,14(A2)
	MOVE.W	$26(A2),-(SP)
	BSR.L	lbC025F1E
	MOVE.W	(SP)+,$26(A2)
	TST.B	$24(A2)
	BEQ.S	lbC025BEC
	CLR.B	$22(A2)
	MOVE.W	#$FFFF,$26(A2)
	CLR.B	$24(A2)
lbC025BEC	RTS

lbC025BEE	TST.B	$36(A2)
	BMI.S	lbC025C18
	BSR.L	lbC025F1E
	MOVE.L	D1,D3
	ANDI.L	#$FF000000,D3
	BEQ.S	lbC025C06
	CLR.B	$32(A2)
lbC025C06	MOVE.L	D1,D3
	ANDI.L	#$FF0000,D3
	BEQ.S	lbC025C26
	MOVE.B	$102(A5),$37(A2)
	BRA.S	lbC025C26

lbC025C18	CLR.B	$32(A2)
	BSR.L	lbC025F1E
	MOVE.B	$102(A5),$37(A2)
lbC025C26	MOVE.L	#lbC02607A,(A1)+
	CLR.B	$36(A2)
	TST.B	D1
	BEQ.S	lbC025C4A
	MOVE.W	D1,D3
	LSR.W	#4,D3
	ANDI.W	#15,D3
	MOVE.B	D3,$33(A2)
	MOVE.W	D1,D3
	ANDI.W	#15,D3
	MOVE.W	D3,$34(A2)
lbC025C4A	RTS

lbC025C4C	MOVE.L	#lbC025FA8,(A1)+
	BRA.L	lbC025F1E

lbC025C56	BSR.L	lbC025F1E
	MOVEQ	#0,D3
	MOVE.B	D1,D3
	ROL.W	#8,D3
	MOVEA.L	(A2),A6
	ADD.L	(A6),D3
	CMP.L	4(A6),D3
	BLT.S	lbC025C6C
	MOVE.L	(A6),D3
lbC025C6C	MOVE.L	D3,$2C(A2)
	ANDI.L	#$FF000000,D1
	BEQ.S	lbC025C84
	ADD.L	lbL062FD2(pc),D3
	SUBQ.L	#4,D3
	MOVE.L	D3,$40(A5)
lbC025C84	MOVE.L	#lbC025FA8,(A1)+
	RTS

lbC025C8C	MOVE.L	#lbC0260C0,(A1)+
lbC025C92	MOVE.B	D1,D3
	ANDI.W	#15,D3
	MOVE.W	D3,12(A2)
	MOVE.B	D1,D3
	ANDI.W	#$F0,D3
	LSR.W	#4,D3
	MOVE.W	D3,14(A2)
	BRA.L	lbC025F1E

lbC025CAC	CLR.W	lbW062FD6		; b command ($2C)
	MOVEQ	#0,D3
	MOVE.B	D1,D3
	MULU.W	lbW062FC0(pc),D3
	ADDQ.W	#8,D3
	ADD.L	lbL0357C8(pc),D3
	MOVE.L	D3,lbL062FC2

	bsr.w	SongEnd

	MOVE.L	#lbC025FA8,(A1)+
	BRA.L	lbC025F1E

lbC025CD4	BSR.L	lbC025F1E
	MOVE.B	D1,$102(A5)
	MOVE.L	#lbC025FA8,(A1)+
	RTS

lbC025CE4	TST.B	D1
	BNE.S	lbC025CF8
	CLR.W	lbW062FD6
	MOVE.L	#lbC025FA8,(A1)+
	BRA.L	lbC025F1E

lbC025CF8	MOVEQ	#$3F,D4
	SUB.B	D1,D4
	MOVE.W	D4,lbW062FD6
	MOVEQ	#0,D7
	MOVE.B	D1,D7
	MULU.W	lbW062FBE(pc),D7
	MOVEA.L	lbL062FC2(pc),A6
	CMPI.W	#$DD48,(A6)
	BNE.S	lbC025D1E
	MOVEA.L	lbL062FC6(pc),A6

	bsr.w	SongEnd

lbC025D1E	MOVE.L	A5,-(SP)
	MOVE.W	lbW062FC0(pc),D6
	SUBQ.W	#1,D6
	MOVE.W	lbW062FBE(pc),D5
	ADDQ.W	#5,D5
	LEA	lbL062FDC(pc),A5
	MOVE.L	lbL062FCA(pc),D4
	ADD.L	D7,D4
lbC025D3E	MOVEQ	#0,D3
	MOVE.B	(A6)+,D3
	ROL.W	D5,D3
	ADD.L	D4,D3
	MOVE.L	D3,(A5)+
	DBRA	D6,lbC025D3E
	MOVE.L	A6,lbL062FC2
	MOVEA.L	(SP)+,A5
	MOVE.L	#lbC025FA8,(A1)+
	BRA.L	lbC025F1E

lbC025D5E	LEA	lbL0351FC(pc),A6
	MOVE.L	D1,D3
	ANDI.W	#$F0,D3
	ROR.W	#2,D3
	MOVEA.L	0(A6,D3.W),A6
	JMP	(A6)

lbC025D72	SUBQ.W	#1,D1
	MOVE.B	D1,lbB062FD9
	MOVE.B	D1,lbB062FDB
	MOVE.L	#lbC025FA8,(A1)+
	BRA.L	lbC025F1E

lbC025D8A
;	CLR.W	lbW0351B6			; special pinball command

	bsr.w	SongEnd
	move.w	RepeatVal(PC),lbW0351BA

	BRA.L	lbC025F1E

lbC025D94	MOVE.L	#lbC025FA8,(A1)+
	BRA.L	lbC025F1E

lbC025D9E	MOVE.L	D1,D3
	ANDI.W	#15,D3
	BEQ.S	lbC025DBC
	CMP.B	#1,D3
	BEQ.S	lbC025DB4
	LEA	lbW0356FC(pc),A6
	BRA.S	lbC025DC2

lbC025DB4	LEA	lbL03573C(pc),A6
	BRA.S	lbC025DC2

lbC025DBC	LEA	lbW0356BC(pc),A6
lbC025DC2	MOVE.L	A6,$40(A1)
	MOVE.L	#lbC025FA8,(A1)+
	BRA.L	lbC025F1E

lbC025DD0	BSR.L	lbC025F1E
	MOVE.W	D1,D3
	ANDI.W	#15,D3
	MOVE.W	D3,$30(A2)
	MOVE.L	#lbC025FA8,(A1)+
	ANDI.L	#$FF000000,D1
	BRA.L	lbC025F1E

lbC025DEE	MOVE.L	D1,D3
	ANDI.W	#15,D3
	BEQ.S	lbC025E0C
	CMP.B	#1,D3
	BEQ.S	lbC025E04
	LEA	lbW0356FC(pc),A6
	BRA.S	lbC025E12

lbC025E04	LEA	lbL03573C(pc),A6
	BRA.S	lbC025E12

lbC025E0C	LEA	lbW0356BC(pc),A6
lbC025E12	MOVE.L	A6,$20(A1)
	MOVE.W	#$FFFF,$26(A2)
	MOVE.L	#lbC025FA8,(A1)+
	BRA.L	lbC025F1E

lbC025E26	MOVE.L	#lbC02611E,(A1)+
	MOVE.L	D1,$28(A2)
	BRA.L	lbC025F1E

lbC025E34	BSR.L	lbC025F1E
	MOVE.B	D1,D3
	ANDI.W	#15,D3
	ADD.W	4(A2),D3
	CMPI.W	#$38B,D3
	BLE.S	lbC025E4C
	MOVE.W	#$38B,D3
lbC025E4C	MOVE.W	D3,4(A2)
	MOVE.L	#lbC025FA8,(A1)+
	RTS

lbC025E58	BSR.L	lbC025F1E
	MOVE.B	D1,D3
	ANDI.W	#15,D3
	NEG.W	D3
	ADD.W	4(A2),D3
	CMPI.W	#$6C,D3
	BGE.S	lbC025E72
	MOVE.W	#$6C,D3
lbC025E72	MOVE.W	D3,4(A2)
	MOVE.L	#lbC025FA8,(A1)+
	RTS

lbC025E7E	BSR.L	lbC025F1E
	MOVE.B	D1,D3
	ANDI.B	#15,D3
	ADD.B	$102(A5),D3
	CMP.B	#$40,D3
	BLE.S	lbC025E96
	MOVE.B	#$40,D3
lbC025E96	MOVE.B	D3,$102(A5)
	MOVE.L	#lbC025FA8,(A1)+
	RTS

lbC025EA2	BSR.S	lbC025F1E
	MOVE.B	D1,D3
	ANDI.W	#15,D3
	NEG.W	D3
	ADD.B	$102(A5),D3
	TST.B	D3
	BPL.S	lbC025EB8
	MOVE.B	#0,D3
lbC025EB8	MOVE.B	D3,$102(A5)
	MOVE.L	#lbC025FA8,(A1)+
	RTS

lbC025EC4	BSR.S	lbC025F1E
	MOVE.B	D1,D3
	ANDI.W	#15,D3
	BEQ.S	lbC025EDA
	MOVE.W	D3,12(A2)
	MOVE.L	#lbC026164,(A1)+
	RTS

lbC025EDA	CLR.B	$102(A5)
	MOVE.L	#lbC025FA8,(A1)+
	RTS

lbC025EE6	MOVE.L	#lbC0260E2,(A1)+
	MOVE.L	D1,$28(A2)
	ANDI.L	#$FFFFFF,D1
	BRA.S	lbC025F1E

lbC025EF8	MOVE.L	#lbC025FA8,(A1)+
	TST.W	lbW062FBA
	BPL.S	lbC025F1E
	MOVE.B	D1,D3
	ANDI.W	#15,D3
	MOVE.W	D3,lbW062FB8
	BRA.S	lbC025F1E

lbC025F14	MOVE.L	#lbC025FA8,(A1)+
	BRA.L	lbC025F1E

lbC025F1E	MOVE.B	#$FF,$36(A2)
	MOVE.W	#$FFFF,$26(A2)
	MOVE.L	D1,D2
	SWAP	D2
	LSR.W	#8,D2
	ANDI.W	#$FF,D2
	BEQ.S	lbC025F3A
	MOVE.W	D2,$1E(A2)
lbC025F3A	MOVE.L	D1,D3
	SWAP	D3
	ANDI.W	#$FF,D3
	TST.W	D3
	BEQ.S	lbC025F60
	SUBQ.W	#1,D3
	ROL.W	#4,D3
	LEA	0(A4,D3.W),A6
	MOVE.L	A6,(A2)
	MOVE.L	(A6),$2C(A2)
	MOVE.B	12(A4,D3.W),$102(A5)
	MOVE.B	13(A6),$31(A2)
lbC025F60	TST.W	D2
	BEQ.S	lbC025FA6
	MOVE.B	#$FF,$24(A2)
	MOVEA.L	(A2),A6
	MOVE.L	lbL062FD2(pc),D4
	SUBQ.L	#4,D4
	MOVE.L	$2C(A2),D5
	ADD.L	D4,D5
	MOVE.L	D5,$40(A5)
	MOVE.L	4(A6),D5
	ADD.L	D4,D5
	MOVE.L	D5,$80(A5)
	MOVE.L	8(A6),$C0(A5)
	MOVE.W	$30(A2),D4
	LEA	lbB03523A(pc),A6
	MULU.W	#$48,D4
	ADD.W	D2,D4
	MOVE.W	0(A6,D4.W),D4
	MOVE.W	D4,4(A2)
lbC025FA6	RTS

lbC025FA8	RTS

lbC025FAA	LEA	$1A(A2),A5
	MOVEA.L	(A5),A4
	CMPA.L	A4,A5
	BNE.S	lbC025FB8
	LEA	$14(A2),A4
lbC025FB8	CMPI.W	#$FFFF,(A4)
	BNE.S	lbC025FC2
	LEA	$14(A2),A4
lbC025FC2	MOVE.W	(A4)+,$20(A2)
	MOVE.L	A4,(A5)
	RTS

lbC025FCA	MOVE.W	4(A2),D1
	SUB.W	6(A2),D1
	CMPI.W	#$6C,D1
	BGE.S	lbC025FDC
	MOVE.W	#$6C,D1
lbC025FDC	MOVE.W	D1,4(A2)
	RTS

lbC025FE2	MOVE.W	4(A2),D1
	ADD.W	6(A2),D1
	CMPI.W	#$38B,D1
	BLE.S	lbC025FF4
	MOVE.W	#$38B,D1
lbC025FF4	MOVE.W	D1,4(A2)
	RTS

lbC025FFA	MOVE.W	$10(A2),D1
	MOVE.W	4(A2),D2
	CMP.W	D1,D2
	BLT.S	lbC026014
	SUB.W	$12(A2),D2
	CMP.W	D1,D2
	BLT.S	lbC02601C
lbC02600E	MOVE.W	D2,4(A2)
	RTS

lbC026014	ADD.W	$12(A2),D2
	CMP.W	D1,D2
	BLT.S	lbC02600E
lbC02601C	MOVE.W	D1,4(A2)
	RTS

lbC026022	MOVEA.L	$1C(A0),A4
	MOVEQ	#0,D1
	MOVE.B	$22(A2),D1
	MOVEQ	#0,D2
	MOVE.B	0(A4,D1.W),D2
	MOVEQ	#0,D3
	MOVE.B	$25(A2),D3
	MULU.W	D3,D2
	LSR.L	#7,D2
	MOVE.W	4(A2),D3
	CMP.B	#$1F,D1
	BGE.S	lbC02604A
	ADD.W	D2,D3
	BRA.S	lbC02604C

lbC02604A	SUB.W	D2,D3
lbC02604C	CMP.W	#$38B,D3
	BLE.S	lbC026056
	MOVE.W	#$38B,D3
lbC026056	CMP.W	#$6C,D3
	BGE.S	lbC026060
	MOVE.W	#$6C,D3
lbC026060	MOVE.W	D3,$26(A2)
	ADD.B	$23(A2),D1
	ANDI.B	#$3F,D1
	MOVE.B	D1,$22(A2)
	RTS

lbC026072	BSR.S	lbC025FFA
	BRA.S	lbC0260C0

lbC026076	BSR.S	lbC026022
	BRA.S	lbC0260C0

lbC02607A	MOVEA.L	$3C(A0),A4
	MOVEQ	#0,D1
	MOVE.B	$32(A2),D1
	MOVEQ	#0,D2
	MOVE.B	0(A4,D1.W),D2
	MULU.W	$34(A2),D2
	LSR.W	#6,D2
	MOVE.B	$37(A2),D3
	CMP.B	#$1F,D1
	BGE.S	lbC02609E
	ADD.B	D2,D3
	BRA.S	lbC0260A0

lbC02609E	SUB.B	D2,D3
lbC0260A0	CMP.B	#$40,D3
	BLE.S	lbC0260A8
	MOVEQ	#$40,D3
lbC0260A8	TST.B	D3
	BPL.S	lbC0260AE
	MOVEQ	#0,D3
lbC0260AE	MOVE.B	D3,$102(A3)
	ADD.B	$33(A2),D1
	ANDI.B	#$3F,D1
	MOVE.B	D1,$32(A2)
	RTS

lbC0260C0	MOVEQ	#0,D1
	MOVE.B	$102(A3),D1
	ADD.W	14(A2),D1
	SUB.W	12(A2),D1
	CMPI.W	#$40,D1
	BLE.S	lbC0260D6
	MOVEQ	#$40,D1
lbC0260D6	TST.W	D1
	BPL.S	lbC0260DC
	MOVEQ	#0,D1
lbC0260DC	MOVE.B	D1,$102(A3)
	RTS

lbC0260E2	MOVEQ	#0,D1
	MOVE.B	$2B(A2),D1
	ANDI.B	#15,D1
	MOVE.W	lbB062FD8(pc),D2
	SUB.W	lbB062FDA(pc),D2
	BEQ.S	lbC02611C
	CMP.B	D2,D1
	BNE.S	lbC02611C
	MOVE.B	$28(A2),D1
	BEQ.S	lbC02611C
	MOVEM.L	D0-D7/A0-A6,-(SP)
	MOVE.L	$28(A2),D1
	MOVEA.L	A3,A5
	MOVEA.L	lbL062FD2(pc),A4
	BSR.L	lbC025F1E
	MOVEM.L	(SP)+,D0-D7/A0-A6
lbC02611C	RTS

lbC02611E	MOVEQ	#0,D1
	MOVE.B	$2B(A2),D1
	ANDI.W	#15,D1
	BEQ.S	lbC026162
	MOVEQ	#0,D2
	MOVE.W	lbB062FD8(pc),D2
	SUB.W	lbB062FDA(pc),D2
	BNE.S	lbC026142
	TST.B	$2B(A2)
	BNE.S	lbC026162
	MOVEQ	#0,D2
lbC026142	DIVU.W	D1,D2
	SWAP	D2
	TST.W	D2
	BNE.S	lbC026162
	MOVEM.L	D0-D7/A0-A6,-(SP)
	MOVE.L	$28(A2),D1
	MOVEA.L	A3,A5
	MOVEA.L	lbL062FD2(pc),A4
	BSR.L	lbC025F1E
	MOVEM.L	(SP)+,D0-D7/A0-A6
lbC026162	RTS

lbC026164	SUBI.W	#1,12(A2)
	BNE.S	lbC026170
	CLR.B	$102(A3)
lbC026170	RTS

;lbC026172	LEA	lbL03577C(pc),A0
;	LEA	lbL0357D0(pc),A1
;	MOVE.L	#$477F1C,D0
;	MOVE.W	#$24,D4
;lbC026188	MOVE.L	#3,D1
;	MOVEQ	#0,D2
;	MOVE.W	2(A0),D2
;	MOVEQ	#0,D3
;	MOVE.W	(A0),D3
;	SWAP	D3
;	SUB.W	(A0)+,D2
;	ROL.W	#8,D2
;	DIVU.W	D1,D2
;	ANDI.L	#$FFFF,D2
;	ROL.L	#8,D2
;	CMP.L	#$10000,D2
;	BGE.S	lbC0261BC
;	MOVE.L	#$10000,D2
;	MOVE.W	(A0),D1
;	SUB.W	-2(A0),D1
;lbC0261BC	SUBQ.W	#1,D1
;	BMI.S	lbC0261D8
;	SWAP	D3
;	MOVE.L	D0,D5
;	CLR.W	D5
;	SWAP	D5
;	DIVU.W	D3,D5
;	MOVE.W	D5,(A1)+
;	MOVE.W	D0,D5
;	DIVU.W	D3,D5
;	MOVE.W	D5,(A1)+
;	SWAP	D3
;	ADD.L	D2,D3
;	BRA.S	lbC0261BC

;lbC0261D8	DBRA	D4,lbC026188
;	MOVE.L	A1,D1
;	SUBI.L	#lbL0357D0,D1
;	ROR.L	#2,D1
;	MOVE.L	D1,lbL062FB4
;	MOVE.L	#$FFFFFFFF,(A1)+
;	RTS

Play3
;	TST.W	lbW034DC8
;	BEQ.S	lbC026214
;	TST.W	lbW0351B4
;	BEQ.S	lbC026214
;	LEA	lbW0348E8(pc),A0
;	MOVEQ	#0,D0
;	MOVE.L	D0,(A0)+
;	MOVE.L	D0,(A0)+
;	MOVE.L	D0,(A0)+
;	MOVE.L	D0,(A0)+
;lbC026214	TST.W	lbW026268
;	BEQ.S	lbC026260
;	TST.W	lbW034DC6
;	BNE.S	lbC026260
;	MOVEQ	#0,D0
;	MOVE.W	lbW026268(pc),D0
;	SUBQ.W	#1,D0
;	ROL.W	#4,D0
;	ADD.L	lbL062FD2(pc),D0
;	MOVEA.L	D0,A0
;	LEA	lbL034838(pc),A1
;	MOVE.L	(A0)+,D1
;	MOVE.L	lbL062FD2(pc),D0
;	SUBQ.L	#4,D0
;	ADD.L	D0,D1
;	MOVE.L	D1,(A1)
;	MOVE.L	(A0)+,D1
;	ADD.L	D0,D1
;	MOVE.L	D1,$40(A1)
;	CLR.L	$80(A1)
;	MOVE.W	lbW02626A(pc),$C2(A1)
;lbC026260	CLR.W	lbW026268
;	RTS

;lbW026268	dc.w	0
;lbW02626A	dc.w	0

lbC0347DC	BRA.L	lbC034A26

lbC0347E0	BRA.L	lbC0349A4

lbC0347E4	BRA.L	lbC034A1C

lbW0347E8	dc.w	0
lbL0347EA	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
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
lbL034828	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbL034838	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbL034868	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbL034878	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbL0348A8	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbW0348E8	dc.w	0
lbL0348EA	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
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
	dc.w	$6000
	dc.w	$F0
	dc.w	4
	dc.w	8
	dc.w	0
	dc.w	$7D00
	dc.w	$7D
	dc.w	$20
	dc.w	$6011
	dc.w	$BD20
	dc.w	$426C
	dc.w	$6164
	dc.w	$6520
	dc.w	$4465
	dc.w	$7665
	dc.w	$6C6F
	dc.w	$706D
	dc.w	$656E
	dc.w	$7400
lbB03495A	dc.b	0
lbB03495B	dc.b	0
lbW03495C	dc.w	0
lbW03495E	dc.w	0
lbL034960	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbL034978	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbL034990	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbL0349A0	dc.l	0

lbC0349A4	LEA	lbW0348E8(PC),A0
	CLR.L	(A0)+
	CLR.L	(A0)+
	CLR.L	(A0)+
	CLR.L	(A0)+
	CLR.L	(A0)+
	LEA	lbL034828(PC),A0
	LEA	lbL03A5F4,A1
	MOVE.L	A1,(A0)+
	MOVE.L	A1,(A0)+
	MOVE.L	A1,(A0)+
	MOVE.L	A1,(A0)+
	MOVE.L	A1,(A0)+
	LEA	lbL034868(PC),A0
	ADDQ.L	#2,A1
	MOVE.L	A1,(A0)+
	MOVE.L	A1,(A0)+
	MOVE.L	A1,(A0)+
	MOVE.L	A1,(A0)+
	MOVE.L	A1,(A0)+
	LEA	lbL0348A8(PC),A0
	CLR.L	(A0)+
	CLR.L	(A0)+
	CLR.L	(A0)+
	CLR.L	(A0)+
	CLR.L	(A0)+
	LEA	lbW0347E8(PC),A0
	MOVE.L	#$11C,D0
	MOVE.L	D0,(A0)+
	MOVE.L	D0,(A0)+
	MOVE.L	D0,(A0)+
	MOVE.L	D0,(A0)+
	MOVE.L	D0,(A0)+
;	LEA	lbC0347DC(PC),A6
;	CLR.W	$DFF0A8
;	CLR.W	$DFF0B8
;	CLR.W	$DFF0C8
;	CLR.W	$DFF0D8
;	ORI.B	#2,$BFE001
lbC034A1C
;	MOVE.W	#15,$DFF096
	RTS

Play1
lbC034A26	LEA	lbC0347DC(PC),A6
	CLR.W	lbW03495E
	LEA	lbL034960(PC),A0
	MOVEQ	#0,D0
	MOVE.L	D0,(A0)+
	MOVE.L	D0,(A0)+
	MOVE.L	D0,(A0)+
	MOVE.L	D0,(A0)+
	MOVE.L	D0,(A0)+
	MOVE.L	D0,(A0)+
	MOVE.L	D0,(A0)+
	MOVE.L	D0,(A0)+
	MOVE.L	D0,(A0)+
	MOVE.L	D0,(A0)+
	MOVE.L	D0,(A0)+
	MOVE.L	D0,(A0)+
	MOVE.L	lbL034838(PC),D0
	LEA	lbL03A5F4,A0
	CMP.L	A0,D0
	BEQ.S	lbC034A62
	CMP.L	lbL0349A0(PC),D0
	BEQ.S	lbC034A76
lbC034A62	MOVE.W	lbW03495C(PC),D0
	BEQ.S	lbC034A76
	LEA	lbL034990(PC),A0
	LSL.W	#2,D0
	CLR.L	-4(A0,D0.W)
	CLR.W	$180(A6)
lbC034A76	LEA	lbL03A5F4,A2
	LEA	lbL034828(PC),A0
	LEA	lbL034990(PC),A1
	MOVE.L	(A0),D0
	CMP.L	(A1)+,D0
	BEQ.S	lbC034ACC
	BCLR	#0,D0
	BSET	#0,$183(A6)
	MOVE.L	D0,$184(A6)
	NEG.L	D0
	ADD.L	$40(A0),D0
	LSR.L	#1,D0
	MOVE.W	D0,$188(A6)
	TST.L	$80(A0)
	BEQ.S	lbC034AC2
	MOVE.L	$40(A0),D0
	SUB.L	$80(A0),D0
	MOVE.L	D0,$19C(A6)
	MOVE.W	$82(A0),D0
	LSR.W	#1,D0
	MOVE.W	D0,$1A0(A6)
	BRA.S	lbC034ACC

lbC034AC2	MOVE.L	A2,$19C(A6)
	MOVE.W	#1,$1A0(A6)
lbC034ACC	ADDQ.L	#4,A0
	MOVE.L	(A0),D0
	CMP.L	(A1)+,D0
	BEQ.L	lbC034B18
	BCLR	#0,D0
	BSET	#1,$183(A6)
	MOVE.L	D0,$18A(A6)
	NEG.L	D0
	ADD.L	$40(A0),D0
	LSR.L	#1,D0
	MOVE.W	D0,$18E(A6)
	TST.L	$80(A0)
	BEQ.S	lbC034B0E
	MOVE.L	$40(A0),D0
	SUB.L	$80(A0),D0
	MOVE.L	D0,$1A2(A6)
	MOVE.W	$82(A0),D0
	LSR.W	#1,D0
	MOVE.W	D0,$1A6(A6)
	BRA.S	lbC034B18

lbC034B0E	MOVE.L	A2,$1A2(A6)
	MOVE.W	#1,$1A6(A6)
lbC034B18	ADDQ.L	#4,A0
	MOVE.L	(A0),D0
	CMP.L	(A1)+,D0
	BEQ.L	lbC034B64
	BCLR	#0,D0
	BSET	#3,$183(A6)
	MOVE.L	D0,$196(A6)
	NEG.L	D0
	ADD.L	$40(A0),D0
	LSR.L	#1,D0
	MOVE.W	D0,$19A(A6)
	TST.L	$80(A0)
	BEQ.S	lbC034B5A
	MOVE.L	$40(A0),D0
	SUB.L	$80(A0),D0
	MOVE.L	D0,$1AE(A6)
	MOVE.W	$82(A0),D0
	LSR.W	#1,D0
	MOVE.W	D0,$1B2(A6)
	BRA.S	lbC034B64

lbC034B5A	MOVE.L	A2,$1AE(A6)
	MOVE.W	#1,$1B2(A6)
lbC034B64	ADDQ.L	#4,A0
	MOVE.L	(A0),D0
	CMP.L	(A1)+,D0
	BEQ.L	lbC034BB0
	BCLR	#0,D0
	BSET	#2,$183(A6)
	MOVE.L	D0,$190(A6)
	NEG.L	D0
	ADD.L	$40(A0),D0
	LSR.L	#1,D0
	MOVE.W	D0,$194(A6)
	TST.L	$80(A0)
	BEQ.S	lbC034BA6
	MOVE.L	$40(A0),D0
	SUB.L	$80(A0),D0
	MOVE.L	D0,$1A8(A6)
	MOVE.W	$82(A0),D0
	LSR.W	#1,D0
	MOVE.W	D0,$1AC(A6)
	BRA.S	lbC034BB0

lbC034BA6	MOVE.L	A2,$1A8(A6)
	MOVE.W	#1,$1AC(A6)
lbC034BB0	MOVE.W	lbW03495C(PC),D0
	BEQ.S	lbC034BD4
	MOVE.W	D0,D1
	LEA	lbB03495A(PC),A0
	MULU.W	#6,D0
	ADDA.W	D0,A0
	CLR.L	(A0)+
	CLR.W	(A0)+
	LEA	$12(A0),A0
	CLR.L	(A0)+
	CLR.W	(A0)+
	SUBQ.L	#1,D1
	BCLR	D1,$183(A6)
lbC034BD4	MOVE.L	lbL034838(PC),D0
	CMP.L	lbL0349A0(PC),D0
	BEQ.S	lbC034C18
	MOVE.W	lbB03495A(PC),D0
	MOVE.W	D0,D1
	MOVE.W	D0,$180(A6)
	LEA	lbB03495A(PC),A0
	MULU.W	#6,D0
	ADDA.W	D0,A0
	MOVE.L	lbL034838(PC),D0
	MOVE.L	D0,(A0)+
	NEG.L	D0
	ADD.L	lbL034878(PC),D0
	LSR.L	#1,D0
	MOVE.W	D0,(A0)+
	LEA	$12(A0),A0
	LEA	lbL03A5F4,A1
	MOVE.L	A1,(A0)+
	MOVE.W	#1,(A0)+
	SUBQ.L	#1,D1
	BSET	D1,$183(A6)
lbC034C18
;	MOVE.W	lbW03495E(PC),$DFF096

	move.w	lbW03495E(PC),D0
	bsr.w	PokeDMA

	BSET	#7,$182(A6)
	LEA	lbL0347EA(PC),A0
;	LEA	$DFF0A6,A1
	LEA	lbL0348EA(PC),A2
;	LEA	$DFF0A8,A3
	MOVEQ	#0,D1
	MOVE.W	lbW03495C(PC),D0

	move.l	EagleBase(PC),A5

	CMP.W	#1,D0
	BEQ.S	lbC034C4E
;	MOVE.W	(A0),(A1)			; Voice 1 period
;	MOVE.B	(A2),D1
;	MOVE.W	D1,(A3)				; Voice 1 volume

	move.l	D0,-(SP)
	move.w	(A0),D0
	jsr	ENPP_PokePer(A5)
	moveq	#0,D0
	move.b	(A2),D0
	jsr	ENPP_PokeVol(A5)
	move.l	(SP)+,D0

	BRA.S	lbC034C58

lbC034C4E
;	MOVE.W	$10(A0),(A1)			; Voice 1 period
;	MOVE.B	$10(A2),D1
;	MOVE.W	D1,(A3)				; Voice 1 volume

	move.l	D0,-(SP)
	move.w	$10(A0),D0
	jsr	ENPP_PokePer(A5)
	moveq	#0,D0
	move.b	$10(A2),D0
	jsr	ENPP_PokeVol(A5)
	move.l	(SP)+,D0

lbC034C58
	moveq	#1,D1

	CMP.W	#2,D0
	BEQ.S	lbC034C6E
;	MOVE.W	4(A0),$10(A1)			; Voice 2 period
;	MOVE.B	4(A2),D1
;	MOVE.W	D1,$10(A3)			; Voice 2 volume

	move.l	D0,-(SP)
	move.w	4(A0),D0
	jsr	ENPP_PokePer(A5)
	moveq	#0,D0
	move.b	4(A2),D0
	jsr	ENPP_PokeVol(A5)
	move.l	(SP)+,D0

	BRA.S	lbC034C7C

lbC034C6E
;	MOVE.W	$10(A0),$10(A1)			; Voice 2 period
;	MOVE.B	$10(A2),D1
;	MOVE.W	D1,$10(A3)			; Voice 2 volume

	move.l	D0,-(SP)
	move.w	$10(A0),D0
	jsr	ENPP_PokePer(A5)
	moveq	#0,D0
	move.b	$10(A2),D0
	jsr	ENPP_PokeVol(A5)
	move.l	(SP)+,D0

lbC034C7C
	moveq	#2,D1

	CMP.W	#3,D0
	BEQ.S	lbC034C92
;	MOVE.W	12(A0),$20(A1)			; Voice 3 period
;	MOVE.B	12(A2),D1
;	MOVE.W	D1,$20(A3)			; Voice 3 volume

	move.l	D0,-(SP)
	move.w	12(A0),D0
	jsr	ENPP_PokePer(A5)
	moveq	#0,D0
	move.b	12(A2),D0
	jsr	ENPP_PokeVol(A5)
	move.l	(SP)+,D0

	BRA.S	lbC034CA0

lbC034C92
;	MOVE.W	$10(A0),$20(A1)			; Voice 3 period
;	MOVE.B	$10(A2),D1
;	MOVE.W	D1,$20(A3)			; Voice 3 volume

	move.l	D0,-(SP)
	move.w	$10(A0),D0
	jsr	ENPP_PokePer(A5)
	moveq	#0,D0
	move.b	$10(A2),D0
	jsr	ENPP_PokeVol(A5)
	move.l	(SP)+,D0

lbC034CA0
	moveq	#3,D1

	CMP.W	#4,D0
	BEQ.S	lbC034CB6
;	MOVE.W	8(A0),$30(A1)			; Voice 4 period
;	MOVE.B	8(A2),D1
;	MOVE.W	D1,$30(A3)			; Voice 4 volume

	move.l	D0,-(SP)
	move.w	8(A0),D0
	jsr	ENPP_PokePer(A5)
	moveq	#0,D0
	move.b	8(A2),D0
	jsr	ENPP_PokeVol(A5)
	move.l	(SP)+,D0

	BRA.S	lbC034CC4

lbC034CB6
;	MOVE.W	$10(A0),$30(A1)			; Voice 4 period
;	MOVE.B	$10(A2),D1
;	MOVE.W	D1,$30(A3)			; Voice 4 volume

	move.l	D0,-(SP)
	move.w	$10(A0),D0
	jsr	ENPP_PokePer(A5)
	moveq	#0,D0
	move.b	$10(A2),D0
	jsr	ENPP_PokeVol(A5)
	move.l	(SP)+,D0

lbC034CC4
;	MOVE.W	#$1F4,D0
;lbC034CC8	DBRA	D0,lbC034CC8
	LEA	lbL034960(PC),A0
;	LEA	$DFF0A0,A1
	MOVE.L	(A0),D0
	BEQ.S	lbC034CE2
;	MOVE.L	D0,(A1)				; Voice 1 address
;	MOVE.W	4(A0),4(A1)			; Voice 1 length

	moveq	#0,D1
	jsr	ENPP_PokeAdr(A5)
	moveq	#0,D0
	move.w	4(A0),D0
	jsr	ENPP_PokeLen(A5)

lbC034CE2	ADDQ.L	#6,A0
	MOVE.L	(A0),D0
	BEQ.S	lbC034CF2
;	MOVE.L	D0,$10(A1)			; Voice 2 address
;	MOVE.W	4(A0),$14(A1)			; Voice 2 length

	moveq	#1,D1
	jsr	ENPP_PokeAdr(A5)
	moveq	#0,D0
	move.w	4(A0),D0
	jsr	ENPP_PokeLen(A5)

lbC034CF2	ADDQ.L	#6,A0
	MOVE.L	(A0),D0
	BEQ.S	lbC034D02
;	MOVE.L	D0,$20(A1)			; Voice 3 address
;	MOVE.W	4(A0),$24(A1)			; Voice 3 length

	moveq	#2,D1
	jsr	ENPP_PokeAdr(A5)
	moveq	#0,D0
	move.w	4(A0),D0
	jsr	ENPP_PokeLen(A5)

lbC034D02	ADDQ.L	#6,A0
	MOVE.L	(A0),D0
	BEQ.S	lbC034D12
;	MOVE.L	D0,$30(A1)			; Voice 4 address
;	MOVE.W	4(A0),$34(A1)			; Voice 4 length

	moveq	#3,D1
	jsr	ENPP_PokeAdr(A5)
	moveq	#0,D0
	move.w	4(A0),D0
	jsr	ENPP_PokeLen(A5)

lbC034D12
;	MOVE.W	lbW03495E(PC),$DFF096
;	MOVE.W	#$1F4,D0
;lbC034D1E	DBRA	D0,lbC034D1E

	move.w	lbW03495E(PC),D0
	bsr.w	PokeDMA

	LEA	lbL034978(PC),A0
;	LEA	$DFF0A0,A1
	MOVE.L	(A0),D0
	BEQ.S	lbC034D38
;	MOVE.L	D0,(A1)				; Voice 1 address
;	MOVE.W	4(A0),4(A1)			; Voice 1 length

	moveq	#0,D1
	jsr	ENPP_PokeAdr(A5)
	moveq	#0,D0
	move.w	4(A0),D0
	jsr	ENPP_PokeLen(A5)

lbC034D38	ADDQ.L	#6,A0
	MOVE.L	(A0),D0
	BEQ.S	lbC034D48
;	MOVE.L	D0,$10(A1)			; Voice 2 address
;	MOVE.W	4(A0),$14(A1)			; Voice 2 length

	moveq	#1,D1
	jsr	ENPP_PokeAdr(A5)
	moveq	#0,D0
	move.w	4(A0),D0
	jsr	ENPP_PokeLen(A5)

lbC034D48	ADDQ.L	#6,A0
	MOVE.L	(A0),D0
	BEQ.S	lbC034D58
;	MOVE.L	D0,$20(A1)			; Voice 3 address
;	MOVE.W	4(A0),$24(A1)			; Voice 3 length

	moveq	#2,D1
	jsr	ENPP_PokeAdr(A5)
	moveq	#0,D0
	move.w	4(A0),D0
	jsr	ENPP_PokeLen(A5)

lbC034D58	ADDQ.L	#6,A0
	MOVE.L	(A0),D0
	BEQ.S	lbC034D68
;	MOVE.L	D0,$30(A1)			; Voice 4 address
;	MOVE.W	4(A0),$34(A1)			; Voice 4 length

	moveq	#3,D1
	jsr	ENPP_PokeAdr(A5)
	moveq	#0,D0
	move.w	4(A0),D0
	jsr	ENPP_PokeLen(A5)

lbC034D68
;	MOVE.W	lbW03495E(PC),$DFF096

	move.w	lbW03495E(PC),D0
	bsr.w	PokeDMA

	LEA	lbW0347E8(PC),A0
	LEA	lbL034828(PC),A1
	LEA	lbL034990(PC),A2
	LEA	lbL034868(PC),A3
	LEA	lbL0348A8(PC),A4
	LEA	lbL03A5F4,A5
	MOVEQ	#4,D2
lbC034D8C	MOVE.L	#$1151A,D0
	MOVE.L	(A0)+,D1
	BEQ.S	lbC034D9A
	DIVU.W	D1,D0
	EXT.L	D0
lbC034D9A	ADD.L	(A1),D0
	CMP.L	(A3)+,D0
	BLT.S	lbC034DB8
	MOVE.L	(A4),D1
	BEQ.S	lbC034DAE
lbC034DA4	SUB.L	D1,D0
	CMP.L	-4(A3),D0
	BGE.S	lbC034DA4
	BRA.S	lbC034DB8

lbC034DAE	MOVE.L	A5,D0
	MOVE.L	A5,-4(A3)
	ADDQ.L	#2,-4(A3)
lbC034DB8	ADDQ.L	#4,A4
	MOVE.L	D0,(A1)+
	MOVE.L	D0,(A2)+
	DBRA	D2,lbC034D8C
	RTS

;lbW034DC4	dc.w	0
;lbW034DC6	dc.w	0
;lbW034DC8	dc.w	0
;lbL034DCA	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.w	0
;lbW0351B4	dc.w	$FFFF
;lbW0351B6	dc.w	$FFFF
;lbW0351B8	dc.w	$FFFF
lbW0351BA	dc.w	$FFFF
lbL0351BC	dc.l	lbC025A4A
	dc.l	lbC025AF0
	dc.l	lbC025B02
	dc.l	lbC025B14
	dc.l	lbC025B64
	dc.l	lbC025BA6
	dc.l	lbC025BB0
	dc.l	lbC025BEE
	dc.l	lbC025D8A
	dc.l	lbC025C56
	dc.l	lbC025C8C
	dc.l	lbC025CAC
	dc.l	lbC025CD4
	dc.l	lbC025CE4
	dc.l	lbC025D5E
	dc.l	lbC025D72
lbL0351FC	dc.l	lbC025D94
	dc.l	lbC025E34
	dc.l	lbC025E58
	dc.l	lbC025D94
	dc.l	lbC025DEE
	dc.l	lbC025DD0
	dc.l	lbC025D94
	dc.l	lbC025D9E
	dc.l	lbC025C4C
	dc.l	lbC025E26
	dc.l	lbC025E7E
	dc.l	lbC025EA2
	dc.l	lbC025EC4
	dc.l	lbC025EE6
	dc.l	lbC025EF8
	dc.l	lbC025F14
lbB03523A	EQU	*-2
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
lbW0356BC	dc.w	$18
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
	dc.w	$18
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
lbW0356FC	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
lbL03573C	dc.l	$81018
	dc.l	$20283038
	dc.l	$40485058
	dc.l	$60687078
	dc.l	$80889098
	dc.l	$A0A8B0B8
	dc.l	$C0C8D0D8
	dc.l	$E0E8F0F8
	dc.l	$FFF8F0E8
	dc.l	$E0D8D0C8
	dc.l	$C0B8B0A8
	dc.l	$A0989088
	dc.l	$80787068
	dc.l	$60585048
	dc.l	$40383028
	dc.l	$20181008
lbL03577C	dc.l	$6C0071
	dc.l	$78007F
	dc.l	$87008F
	dc.l	$9700A0
	dc.l	$AA00B4
	dc.l	$BE00CA
	dc.l	$D600E2
	dc.l	$F000FE
	dc.l	$10D011D
	dc.l	$12E0140
	dc.l	$1530168
	dc.l	$17D0194
	dc.l	$1AC01C5
	dc.l	$1E001FC
	dc.l	$21A023A
	dc.l	$25C0280
	dc.l	$2A602D0
	dc.l	$2FA0328
	dc.l	$358038B
lbL0357C8	dc.l	0

;	dc.l	0
;lbL0357D0	ds.b	3200

;lbL03A5F8
;	incbin	ram:song

;lbL040C48
;	incbin	ram:data


;lbL040C94
;	incbin	ram:samp

;lbL062FB4	ds.l	1
lbW062FB8	ds.w	1
lbW062FBA	ds.w	2
lbW062FBE	ds.w	1
lbW062FC0	ds.w	1
lbL062FC2	ds.l	1
lbL062FC6	ds.l	1
lbL062FCA	ds.l	1
lbL062FCE	ds.l	1
lbL062FD2	ds.l	1
lbW062FD6	ds.w	1
lbB062FD8	ds.b	1
lbB062FD9	ds.b	1
lbB062FDA	ds.b	1
lbB062FDB	ds.b	1
lbL062FDC	ds.l	8
lbL062FFC	ds.l	1
lbL063000	ds.l	$6F
lbL0631BC	ds.l	8
lbL0631DC	ds.l	$10
BufferEnd

	Section	Empty,BSS_C

lbL03A5F4	ds.l	1

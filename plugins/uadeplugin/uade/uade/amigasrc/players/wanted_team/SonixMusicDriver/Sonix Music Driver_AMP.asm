	*****************************************************
	****       Sonix Music Driver replayer for       ****
	****    EaglePlayer 2.00+ (Amplifier version),   ****
	****         all adaptions by Wanted Team	 ****
	*****************************************************

	incdir	"dh2:include/"
	include 'misc/eagleplayer2.01.i'
	include	'misc/eagleplayerengine.i'
	include 'dos/dos_lib.i'
	include 'dos/dos.i'
	include 'exec/exec_lib.i'

	SECTION Player,Code

	EPPHEADER Tags

	dc.b	'$VER: Sonix Music Driver player module V2.0 (9 June 2004)',0
	even
Tags
	dc.l	DTP_PlayerVersion,2<<16!0
	dc.l	EP_PlayerVersion,11
	dc.l	DTP_PlayerName,PlayerName
	dc.l	DTP_Creator,Creator
	dc.l	EP_Check5,Check5
	dc.l	DTP_Interrupt,Interrupt
	dc.l	DTP_InitPlayer,InitPlayer
	dc.l	DTP_EndPlayer,EndPlayer
	dc.l	DTP_InitSound,InitSound
	dc.l	EP_NewModuleInfo,NewModuleInfo
	dc.l	DTP_ExtLoad,ExtLoad
	dc.l	EP_InitAmplifier,InitAudstruct
	dc.l	EP_EagleBase,EagleBase
	dc.l	EP_Flags,EPB_ModuleInfo!EPB_Songend!EPB_Packable!EPB_Restart
	dc.l	TAG_DONE
PlayerName
	dc.b	'Sonix Music Driver',0
Creator
	dc.b	"(c) 1987-91 by Mark Riley,",10
	dc.b	'adapted by Wanted Team',0
Prefix1
	dc.b	'SMUS.',0
Prefix2
	dc.b	'TINY.',0
Prefix3
	dc.b	'SNX.',0
Suffix
	dc.b	'.instr',0
Suffix2
	dc.b	'.ss',0
SamplesPath
	dc.b	'Instruments/',0
	even
ModulePtr
	dc.l	0
LoadSong
	dc.l	0
Temp
	dc.l	0
Format
	dc.b	0
FormatNow
	dc.b	0
Sizes
	ds.b	64*4
ShortName
	ds.b	6

ChipPtr
	dc.l	0
ChipLength
	dc.l	0
FastPtr
	dc.l	0
FastLength
	dc.l	0
Clock
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
	move.w	A2,D1		;DFF0A0/B0/C0/D0
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
	move.w	A2,D1		;DFF0A0/B0/C0/D0
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
	move.w	A2,D1		;DFF0A0/B0/C0/D0
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
	move.w	A2,D1		;DFF0A0/B0/C0/D0
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
	lea	Temp(PC),A4
	move.l	(A4),A3
	clr.l	(A4)
	tst.b	4(A4)
	bmi.w	SmusLoad
	move.l	dtg_ChkData(A5),A0
	cmp.b	#1,4(A4)
	beq.w	TinyLoad
	lea	20(A0),A2
	moveq	#3,D1
Dodaj
	add.l	(A0)+,A2
	dbf	D1,Dodaj
LoadNext
	bsr.b	LoadFile
	tst.l	D0
	bne.b	ExtError1
	addq.l	#1,(A4)
	tst.b	(A2)
	bne.b	LoadNext
ExtError1
	rts

LoadFile
	move.l	dtg_PathArrayPtr(A5),A0
	clr.b	(A0)
	move.l	dtg_CopyDir(A5),A0
	jsr	(A0)
	bsr.b	CopyName
	move.l	D7,EPG_ARG1(A5)
	move.l	D6,EPG_ARGN(A5)
	jmp	ENPP_NewLoadFile(A5)

CopyName
	move.l	dtg_PathArrayPtr(A5),A0
loop1
	tst.b	(A0)+
	bne.s	loop1
	subq.l	#1,A0
	lea	SamplesPath(PC),A1
smp1
	move.b	(A1)+,(A0)+
	bne.s	smp1
	subq.l	#1,A0
smp2
	move.b	(A2)+,(A0)+
	bne.s	smp2
	subq.l	#1,A0
	lea	Suffix(PC),A1
smp3
	move.b	(A1)+,(A0)+
	bne.s	smp3
	rts

TinyLoad
	lea	64(A0),A3
	moveq	#63,D2
LoadNext2
	lea	ShortName(PC),A2
	move.l	(A3)+,(A2)
	beq.b	NoSamp
	bsr.b	LoadFile
	tst.l	D0
	bne.b	ExtError2
	addq.l	#1,(A4)
NoSamp
	dbf	D2,LoadNext2
ExtError2
	rts

SmusLoad
	addq.l	#4,A3
	move.l	(A3)+,D1
	lea	4(A3),A2
	addq.l	#1,D1
	bclr	#0,D1
	add.l	D1,A3
	clr.b	(A3)
	bsr.b	LoadFile
	tst.l	D0
	bne.b	ExtError3
	move.b	#'I',(A3)
	addq.l	#1,(A4)
	cmp.w	#'AK',2(A3)
	bne.b	SmusLoad
	move.b	#'T',(A3)
ExtError3
	rts

***************************************************************************
******************************** EP_Check5 ********************************
***************************************************************************

Check5
	move.l	dtg_ChkData(A5),A0
	moveq	#-1,D0

	lea	Format(PC),A3
	move.l	dtg_ChkSize(A5),D4
	move.l	A0,A1
	cmp.l	#'FORM',(A0)
	beq.w	SmusCheck
	move.w	(A0),D1
	and.w	#$00F0,D1
	bne.b	TinyCheck
	moveq	#20,D3
	moveq	#3,D1
NextPos
	move.l	(A0)+,D2
	beq.b	fault
	bmi.b	fault
	btst	#0,D2
	bne.b	fault
	add.l	D2,D3
	dbf	D1,NextPos
	cmp.l	D4,D3
	bge.b	fault
	addq.l	#4,A0
	moveq	#3,D1
SecPass
	tst.b	(A0)
	bpl.b	fault
	cmp.w	#-1,(A0)
	beq.b	OK1
	cmp.b	#$84,(A0)
	bhi.b	fault
OK1
	add.l	(A1)+,A0
	dbf	D1,SecPass
	tst.b	(A0)
	beq.b	fault
	clr.b	(A3)
found
	moveq	#0,D0
fault
	rts


TinyCheck
	cmp.l	#332,D4
	ble.b	fault
	lea	48(A0),A1
	cmp.l	#$140,(A1)+
	bne.b	fault
	moveq	#2,D1
NextPos2
	move.l	(A1)+,D2
	beq.b	fault
	bmi.b	fault
	btst	#0,D2
	bne.b	fault
	cmp.l	D2,D4
	ble.b	fault
	lea	(A0,D2.L),A2
	cmp.w	#-1,(A2)
	beq.b	OK2
	tst.l	(A2)+
	bne.b	fault
	tst.w	(A2)+
	bne.b	fault
	tst.b	(A2)
	bpl.b	fault
	cmp.b	#$82,(A2)
	bhi.b	fault
OK2
	dbf	D1,NextPos2
	move.b	#1,(A3)
	bra.b	found


SmusCheck
	cmp.l	#'SMUS',8(A0)
	bne.b	fault
	cmp.l	#'SHDR',12(A0)
	tst.b	23(A0)
	beq.b	fault
	lea	24(A0),A1
	cmp.l	#'NAME',(A1)+
	bne.b	fault
	move.l	(A1)+,D1
	bmi.w	fault
	addq.l	#1,D1
	bclr	#0,D1
	add.l	D1,A1
	cmp.l	#'SNX1',(A1)+
	bne.w	fault
	move.l	(A1)+,D1
	bmi.w	fault
	addq.l	#1,D1
	bclr	#0,D1
	add.l	D1,A1
	move.l	A1,-4(A3)			; instruments info
	lea	RealSamples(PC),A2
MoreIns
	cmp.l	#'INS1',(A1)+
	bne.w	fault
	move.l	(A1)+,D1
	bmi.w	fault
	addq.l	#1,D1
	bclr	#0,D1
	cmp.b	#63,(A1)			; real sample number
	bhi.w	fault
	tst.b	1(A1)				; MIDI check
	bne.w	fault
	move.b	(A1),(A2)+			; copy sample position
	add.l	D1,A1
	cmp.l	#'TRAK',(A1)
	bne.b	MoreIns
	st	(A3)
	bra.w	found

***************************************************************************
****************************** EP_NewModuleInfo ***************************
***************************************************************************

NewModuleInfo

CalcSize	=	4
LoadSize	=	12
Samples		=	20
Voices		=	28
SamplesSize	=	36
SongSize	=	44
SynthSamples	=	52
Prefix		=	60
SongName	=	68

InfoBuffer
	dc.l	MI_Calcsize,0		;4
	dc.l	MI_LoadSize,0		;12
	dc.l	MI_Samples,0		;20
	dc.l	MI_Voices,0		;28
	dc.l	MI_SamplesSize,0	;36
	dc.l	MI_Songsize,0		;44
	dc.l	MI_SynthSamples,0	;52
	dc.l	MI_Prefix,0		;60
	dc.l	MI_SongName,0		;68
	dc.l	MI_MaxVoices,4
	dc.l	MI_MaxSamples,64
	dc.l	0

***************************************************************************
***************************** DTP_InitPlayer ******************************
***************************************************************************

InitPlayer
	moveq	#0,D0
	move.l	dtg_GetListData(A5),A0
	jsr	(A0)

	lea	ModulePtr(PC),A3
	move.l	A0,(A3)+			; module buffer
	move.l	D0,(A3)+			; loadsong

	lea	ChipLength(PC),A1
	clr.l	(A1)
	clr.l	8(A1)

	lea	InfoBuffer(PC),A4
	move.l	D0,LoadSize(A4)
	clr.l	SamplesSize(A4)
	clr.l	SongName(A4)

	move.l	(A3)+,D7			; Temp
	beq.w	Corrupt
	moveq	#64,D1
	cmp.l	D1,D7
	bgt.w	Corrupt
	move.b	(A3)+,(A3)+			; copy FormatNow
	lea	-1(A3),A2			; FormatNow

	move.l	D7,Samples(A4)
	moveq	#0,D5				; size of fast memory to alloc
	moveq	#0,D4				; size of chip memory to alloc
	moveq	#1,D6
NextFile
	move.l	D6,D0				; file number
	move.l	dtg_GetListData(A5),A0
	jsr	(A0)

	cmp.b	#1,(A2)
	bne.b	NoTiny
	cmp.l	#1,(A0)
	bne.b	No1
	cmp.l	#442,D0
	bne.w	Corrupt
	bra.w	Jump1
No1
	cmp.l	#2,(A0)
	bne.b	No2
	moveq	#32,D2
	cmp.l	D2,D0
	bne.w	Corrupt
	lea	ShortName(PC),A6
	move.l	4(A0),(A6)
	beq.w	InFile
	bra.w	Jump2
No2
	cmp.l	#3,(A0)
	bne.w	Corrupt
	bra.w	FileOK

NoTiny
	tst.b	(A0)
	beq.w	NoHead
	cmp.l	#'Samp',(A0)
	bne.b	NoSS
	cmp.l	#'ledS',4(A0)
	bne.w	Corrupt
	cmp.l	#'ound',8(A0)
	bne.w	Corrupt
	cmp.l	#128,D0
	bne.w	Corrupt
	lea	68(A0),A6
Jump2
	bsr.w	SetSampleName
	bsr.w	GetSize
	tst.l	D0
	bmi.w	ErrorExt
	moveq	#62+8,D2
	cmp.l	D2,D0
	blt.w	Corrupt
	btst	#0,D0
	beq.b	EvenSize
	addq.l	#1,D0
EvenSize
	add.l	D0,D4
	move.l	D0,(A3)+
	add.l	#128,D0
	cmp.b	#1,(A2)
	bne.w	FileOK
	moveq	#96,D2
	sub.l	D2,D0
	bra.b	FileOK
NoSS
	cmp.l	#'Synt',(A0)
	bne.b	NoSynth
	cmp.l	#'hesi',4(A0)
	bne.w	Corrupt
	cmp.w	#$7300,8(A0)
	bne.w	Corrupt
NoHead
	cmp.l	#502,D0
	bne.w	Corrupt
Jump1
	add.l	#8192,D5			; filter size
	bra.b	FileOK

NoSynth
	cmp.l	#'FORM',(A0)
	bne.b	NoForm
	cmp.l	#'AIFF',8(A0)
	beq.b	AV
	cmp.l	#'8SVX',8(A0)
	bne.w	Corrupt
	cmp.l	#'VHDR',12(A0)
	bne.w	Corrupt
	moveq	#62,D2
	bra.b	FormOK
NoForm
	cmp.l	#'LIST',(A0)
	bne.w	Corrupt
AV
	tst.b	(A2)
	bmi.w	Corrupt
	moveq	#44,D2
FormOK
	add.l	D2,D5
	moveq	#8,D1
	add.l	4(A0),D1
	cmp.l	D1,D0
	bne.w	Corrupt
FileOK
	add.l	D0,SamplesSize(A4)
	add.l	D0,LoadSize(A4)
	addq.l	#1,D6
	subq.l	#1,D7
	bne.w	NextFile

	move.l	4.W,A6				; exec base
	move.l	ModulePtr(PC),A1
	jsr	_LVOTypeOfMem(A6)
	move.l	#$10002,D1			; cleared chip memory ?
	moveq	#0,D3
	btst	#1,D0
	bne.b	Chip2
	bclr	#1,D1				; now cleared fast memory ?
	move.l	#1032,D3
	add.l	D3,D4
Chip2
	move.l	D4,D0
	beq.b	NoAllocChip
	jsr	_LVOAllocMem(A6)		; Alloc Mem
	lea	ChipPtr(PC),A3
	move.l	D0,(A3)+			; ChipPtr
	beq.w	NoMemory
	move.l	D4,(A3)				; ChipLength
	move.l	D0,D4				; chip memory pointer
NoAllocChip
	move.l	D5,D0
	beq.b	NoAllocFast
	move.l	#$10001,D1			; cleared fast memory ?
	jsr	_LVOAllocMem(A6)		; Alloc Mem
	lea	FastPtr(PC),A3
	move.l	D0,(A3)+			; FastPtr
	beq.w	NoMemory
	move.l	D5,(A3)				; FastLength
	move.l	D0,D5				; fast memory pointer
NoAllocFast

	move.l	Sonix(PC),A0			; Buffer
	move.l	A0,A3
	lea	Buffer2+132,A1
ClearBuf
	clr.w	(A0)+
	cmp.l	A0,A1
	bne.b	ClearBuf

	lea	Chip,A1
	tst.l	D3
	beq.b	NoFast
	move.l	D4,A1
	add.l	D3,D4
NoFast
	move.l	ModulePtr(PC),A0
	tst.b	(A2)
	beq.w	InstallSNX
	bpl.b	InstallTINY
	move.l	A1,$29A(A3)
	move.w	#$3F,$1CA(A3)
	move.w	#$FF,(A3)
	move.l	#$00800080,2(A3)
	lea	Prefix1(PC),A1
	move.l	A1,Prefix(A4)
	move.l	LoadSong(PC),D0
	moveq	#8,D1
	add.l	4(A0),D1
	cmp.l	D1,D0
	blt.w	Short
	move.l	D1,A1
	moveq	#0,D1
	move.b	23(A0),D1
	cmp.w	#4,D1
	ble.b	VoicesOK
	moveq	#4,D1
VoicesOK
	bsr.w	LoadSCORE
	lea	28(A0),A0
	move.l	(A0)+,D0
	move.l	A0,SongName(A4)
	add.l	D0,A0
	clr.b	(A0)
	bra.w	Jump4
InstallTINY
	move.l	A1,$106(A3)
	move.w	#$8000,$22(A3)
	move.w	#$3F,$36(A3)
	lea	Prefix2(PC),A1
	move.l	A1,Prefix(A4)
	lea	48(A0),A3
	moveq	#0,D0
	moveq	#3,D1
NextVoice
	move.l	(A3)+,D2
	lea	(A0,D2.L),A1
	cmp.w	#-1,(A1)
	beq.b	VoiceOff
	addq.l	#1,D0
VoiceOff
	dbf	D1,NextVoice
	move.l	D0,D1

	move.l	LoadSong(PC),D0
	bclr	#0,D0
	lea	(A0,D0.L),A3
FindEnd
	cmp.l	A1,A3
	ble.w	Short
	cmp.w	#-1,(A1)+
	bne.b	FindEnd
	bra.w	Jump3

InstallSNX
	move.l	#$00780080,(A3)
	move.l	A1,$3E2(A3)
	lea	Prefix3(PC),A1
	move.l	A1,Prefix(A4)
	bsr.w	InitScore
	move.l	D0,A1
Find0
	tst.b	(A1)+
	bne.b	Find0
	tst.b	(A1)+
	bne.b	Find0
Jump3
	sub.l	A0,A1
Jump4
	move.l	A1,SongSize(A4)
	move.l	SamplesSize(A4),CalcSize(A4)
	move.l	A1,D0
	add.l	D0,CalcSize(A4)
	move.l	D1,Voices(A4)
	move.l	Samples(A4),D7
	move.l	FastLength(PC),D0
	moveq	#13,D1
	lsr.l	D1,D0
	move.l	D0,SynthSamples(A4)
	sub.l	D0,Samples(A4)
	move.b	(A2),D3
	beq.b	Son
	lea	64(A0),A2
	bra.b	SkipSon
Son
	lea	Buffer+138,A4
	lea	Buffer2+42,A2
SkipSon
	lea	Sizes(PC),A3
	moveq	#1,D6
NextFile2
	move.l	D6,D0				; file number
	move.l	dtg_GetListData(A5),A0
	jsr	(A0)

	cmp.b	#1,D3
	bne.b	NoTin
NoInst
	tst.l	(A2)+
	beq.b	NoInst
	subq.l	#4,A2
	cmp.l	#1,(A0)
	bne.b	No01
	move.l	D5,A1
	move.b	#128,(A1)
	add.l	#8192,D5
	bra.b	InitInst
No01
	cmp.l	#2,(A0)
	bne.b	InitInst
	lea	ShortName(PC),A6
	move.l	4(A0),(A6)
	move.l	A0,-(SP)
	bsr.w	SetSampleName
	bsr.w	ReadFile
	move.l	(SP)+,A0
	move.l	D4,A1
	add.l	(A3)+,D4
InitInst
	move.l	A0,(A2)+			; to pointer
	bsr.w	INITINSTRUMENT
	bra.w	Skip1

NoTin
	tst.b	(A0)
	beq.b	NoHead2
	cmp.w	#'Sa',(A0)
	bne.b	NoSS2
	lea	68(A0),A6
	move.l	A0,-(SP)
	bsr.w	SetSampleName
	bsr.w	ReadFile
	move.l	(SP)+,A0
	lea	32(A0),A0
	lea	SSTech(PC),A1
	tst.b	D3
	bpl.b	NoS1
	lea	SStech(PC),A1
	bsr.w	InstallToReal
	bra.b	SkipS1
NoS1
	move.b	D6,(A2)+
SkipS1
	move.l	A1,(A0)
	move.l	D4,A1
	move.w	#1,30(A1)
	move.l	A1,68(A0)
	move.l	A0,(A4)+
	move.w	#1,(A4)+
	add.l	(A3)+,D4
	bra.w	Skip1
NoSS2
	cmp.w	#'Sy',(A0)
	bne.b	NoSynth2
NoHead2
	lea	32(A0),A0
	lea	SyntTech(PC),A1
	tst.b	D3
	bpl.b	NoS2
	lea	Synttech(PC),A1
	bsr.w	InstallToReal
	bra.b	SkipS2
NoS2
	move.b	D6,(A2)+
SkipS2
	move.l	A1,(A0)
	move.l	D5,-4(A0)
	move.l	A0,(A4)+
	move.w	#1,(A4)+
	lea	36(A0),A0
	move.l	D5,A1
	bsr.w	SetFilter
	add.l	#8192,D5
	bra.b	Skip1

NoSynth2
	cmp.w	#'FO',(A0)
	bne.b	AV2
	cmp.w	#'AI',8(A0)
	beq.b	AV2
	bsr.w	InstallIFF
	move.l	D5,A0
	moveq	#62,D2
	lea	IFFTech(PC),A1
	tst.b	D3
	bpl.b	NoS3
	lea	IFFtech(PC),A1
	bsr.w	InstallToReal
	bra.b	SkipS3
AV2
	bsr.w	InstallAIFF
	tst.l	D0
	bmi.b	Corrupt
	move.l	D5,A0
	lea	AIFFTech(PC),A1
	moveq	#44,D2
NoS3
	move.b	D6,(A2)+
SkipS3
	move.l	A1,(A0)
	move.l	A0,(A4)+
	move.w	#1,(A4)+
	add.l	D2,D5
Skip1
	addq.l	#1,D6
	subq.l	#1,D7
	bne.w	NextFile2

	moveq	#0,D0
	rts

Corrupt
	moveq	#EPR_CorruptModule,D0
	rts
Short
	moveq	#EPR_ModuleTooShort,D0
	rts
ErrorExt
	moveq	#EPR_ErrorExtLoad,D0
	rts
NoMemory
	moveq	#EPR_NotEnoughMem,D0
	rts
InFile
	moveq	#EPR_ErrorInFile,D0
	rts

InstallToReal
	moveq	#0,D1
	move.b	RealSamples-1(PC,D6.W),D1
	lea	Buffer+74,A4
	lea	Buffer2+64,A2
	add.w	D1,A2
	move.b	D1,(A2)
	addq.b	#1,(A2)
	mulu.w	#6,D1
	add.w	D1,A4
	rts

RealSamples
	ds.b	64

SetSampleName
	move.l	dtg_PathArrayPtr(A5),A0
	clr.b	(A0)
	move.l	dtg_CopyDir(A5),A0
	jsr	(A0)
	move.l	dtg_PathArrayPtr(A5),A0
	move.l	A0,D1				; file name ptr
NoZero
	tst.b	(A0)+
	bne.b	NoZero
	subq.l	#1,A0
	lea	SamplesPath(PC),A1
CopyPath
	move.b	(A1)+,(A0)+
	bne.s	CopyPath
	subq.l	#1,A0
CopyName1
	move.b	(A6)+,(A0)+
	bne.b	CopyName1
	lea	Suffix2(PC),A6
	subq.l	#1,A0
CopyName2
	move.b	(A6)+,(A0)+
	bne.b	CopyName2
	rts

GetSize
	move.l	dtg_DOSBase(A5),A6
	move.l	#MODE_OLDFILE,D2
	jsr	_LVOOpen(A6)
	move.l	D0,D1				; file handle
	beq.b	Err
	moveq	#0,D2
	moveq	#OFFSET_END,D3
	move.l	D1,-(SP)
	jsr	_LVOSeek(A6)			; seek file
	moveq	#OFFSET_BEGINNING,D3
	move.l	(SP),D1
	jsr	_LVOSeek(A6)			; seek file
	move.l	(SP)+,D1
	move.l	D0,-(SP)
	jsr	_LVOClose(A6)
	move.l	(SP)+,D0
	rts

Err
	moveq	#-1,D0
	rts

ReadFile
	move.l	dtg_DOSBase(A5),A6
	move.l	#MODE_OLDFILE,D2
	jsr	_LVOOpen(A6)
	move.l	D0,D1				; file handle
	movem.l	D0/D3,-(SP)
	move.l	D4,D2
	move.l	(A3),D3
	jsr	_LVORead(A6)
	movem.l	(SP)+,D1/D3
	jsr	_LVOClose(A6)
	rts

***************************************************************************
***************************** DTP_EndPlayer *******************************
***************************************************************************

EndPlayer
	move.l	4.W,A6
	move.l	ChipLength(PC),D0
	beq.b	SkipChip
	move.l	ChipPtr(PC),A1
	jsr	_LVOFreeMem(A6) 		     ; FreeMem
SkipChip
	move.l	FastLength(PC),D0
	beq.b	SkipFast
	move.l	FastPtr(PC),A1
	jsr	_LVOFreeMem(A6) 		     ; FreeMem
SkipFast
	moveq	#0,D0
	rts

***************************************************************************
***************************** DTP_Intterrupt ******************************
***************************************************************************

Interrupt
	movem.l	D1-A6,-(SP)

	move.l	Sonix(PC),A6
	move.b	FormatNow(PC),D1
	beq.b	Play_SNX
	bmi.b	Play_SMUS
	bsr.w	PlayTINY
	bra.b	SkipPlay
Play_SMUS
	bsr.w	PlaySMUS
	bra.b	SkipPlay
Play_SNX
	bsr.w	PlaySNX
SkipPlay
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
	move.l	Clock(PC),D7
	bne.b	Done
	move.w	dtg_Timer(A5),D7
	mulu.w	#125,D7
	lea	Clock(PC),A0
	move.l	D7,(A0)
Done
	move.l	Sonix(PC),A6
	lea	1336(A6),A0			; Buffer2
	moveq	#0,D0
	moveq	#-1,D1
	moveq	#-1,D2				; repeat mode on
	moveq	#0,D3
	move.b	FormatNow(PC),D6
	beq.b	InitSNX
	bpl.b	InitTINY
	bsr.w	PlaySCORE
	bra.b	SetTimer
InitTINY
	move.l	ModulePtr(PC),A0
	bsr.w	PLAYSCORE
SetTimer
	move.w	2(A6),D0
	lsr.w	#1,D0
	asl.w	#1,D0
	lea	lbW000CAE(PC),A0
	move.w	0(A0,D0.W),D7
	move.w	D7,D2
	moveq	#12,D0
	lsr.w	D0,D2
	asl.w	D0,D2
	swap	D7
	clr.w	D7
	lsr.l	#1,D7
	divu.w	D2,D7
	mulu.w	#$2E9C,D7
	moveq	#15,D0
	lsr.l	D0,D7
	bra.b	PutTimer
InitSNX
	moveq	#-1,D4
	bsr.w	PlayScore
	move.l	ModulePtr(PC),A0
	cmp.b	#$82,20(A0)
	bne.b	NoCom
	moveq	#0,D1
	move.b	21(A0),D1
	bra.b	Podziel
NoCom
	move.w	(A6),D1
Podziel
	divu.w	D1,D7
PutTimer
	move.w	D7,dtg_Timer(A5)		; fix for 060 cache
	rts

***************************************************************************
**************** Sonix Music Driver v2.3c player (SNX format) *************
***************************************************************************

; Player from game "Rise Of The Dragon" (c) 1991 by Dynamix

;lbL01DEFC	dc.l	0			; ext. alloc mem
;lbL01DF00	dc.l	0			; ext. free mem

;lbC01DF04	MOVEM.L	D0/D1/A1-A3/A6,-(SP)
;	MOVEA.L	SONIX(PC),A6
;	LEA	$3E6(A6),A3
;	MOVE.L	A0,-(SP)
;	TST.L	(SP)+
;	BEQ.S	lbC01DF32
;	MOVEQ	#$3A,D0				; ":"
;lbC01DF18	MOVE.B	D0,D1
;	MOVE.B	(A0)+,D0
;	MOVE.B	D0,(A3)+
;	BNE.S	lbC01DF18
;	SUBQ.L	#1,A3
;	CMPI.B	#$3A,D1				; ":"
;	BEQ.S	lbC01DF32
;	CMPI.B	#$2F,D1				; "/"
;	BEQ.S	lbC01DF32
;	MOVE.B	#$2F,(A3)+			; "/"
;lbC01DF32	MOVE.B	(A1)+,(A3)+
;	BNE.S	lbC01DF32
;	MOVE.L	A2,-(SP)
;	TST.L	(SP)+
;	BEQ.S	lbC01DF42
;	SUBQ.L	#1,A3
;lbC01DF3E	MOVE.B	(A2)+,(A3)+
;	BNE.S	lbC01DF3E
;lbC01DF42	LEA	$3E6(A6),A0
;	MOVEM.L	(SP)+,D0/D1/A1-A3/A6
;	RTS

;lbC01DF4C	MOVEM.L	D1/D2/A0/A1/A6,-(SP)
;	MOVE.L	A0,D1
;	MOVE.L	D0,D2
;	MOVEA.L	SONIX(PC),A6
;	MOVE.L	$16(A6),D0
;	BNE.S	lbC01DF70
;	MOVE.L	A6,-(SP)
;	MOVEA.L	DOS_Base(PC),A6
;	JSR	-$1E(A6)			; open file
;	MOVEA.L	(SP)+,A6
;lbC01DF6A	MOVEM.L	(SP)+,D1/D2/A0/A1/A6
;	RTS

;lbC01DF70	MOVEA.L	D0,A0			; ext. open file
;	JSR	(A0)
;	BRA.S	lbC01DF6A

;lbC01DF76	MOVEM.L	D1/A0/A1/A6,-(SP)
;	MOVE.L	D0,D1
;	MOVEA.L	SONIX(PC),A6
;	MOVE.L	$1A(A6),D0
;	BNE.S	lbC01DF98
;	MOVE.L	A6,-(SP)
;	MOVEA.L	DOS_Base(PC),A6
;	JSR	-$24(A6)			; close file
;	MOVEA.L	(SP)+,A6
;lbC01DF92	MOVEM.L	(SP)+,D1/A0/A1/A6
;	RTS

;lbC01DF98	MOVEA.L	D0,A0			; ext. close file
;	JSR	(A0)
;	BRA.S	lbC01DF92

;lbC01DF9E	MOVEM.L	D1-D3/A0/A1/A6,-(SP)
;	MOVE.L	D1,D3
;	MOVE.L	D0,D1
;	MOVE.L	A0,D2
;	MOVEA.L	SONIX(PC),A6
;	MOVE.L	$1E(A6),D0
;	BNE.S	lbC01DFC4
;	MOVE.L	A6,-(SP)
;	MOVEA.L	DOS_Base(PC),A6
;	JSR	-$2A(A6)			; read file
;	MOVEA.L	(SP)+,A6
;lbC01DFBE	MOVEM.L	(SP)+,D1-D3/A0/A1/A6
;	RTS

;lbC01DFC4	MOVEA.L	D0,A0			; ext. read file
;	JSR	(A0)
;	BRA.S	lbC01DFBE

;lbC01DFCA	MOVEM.L	D1/A0/A1/A6,-(SP)
;	MOVEA.L	SONIX(PC),A6
;	MOVE.L	$22(A6),D0
;	BNE.S	lbC01DFEA
;	MOVE.L	A6,-(SP)
;	MOVEA.L	DOS_Base(PC),A6
;	JSR	-$42(A6)			; seek file
;	MOVEA.L	(SP)+,A6
;lbC01DFE4	MOVEM.L	(SP)+,D1/A0/A1/A6
;	RTS

;lbC01DFEA	MOVEA.L	D0,A0			; ext. seek file
;	JSR	(A0)
;	BRA.S	lbC01DFE4

;INITINSTRUMENT	MOVEM.L	D1-D7/A0-A6,-(SP)
;	MOVEA.L	A1,A4
;	CLR.L	D2
;	BCLR	#6,$56(A6)
;	LEA	$8A(A6),A5
;	SUBA.L	A3,A3
;	MOVEQ	#$3F,D7
;lbC01E006	MOVE.L	0(A5),D0
;	BNE.S	lbC01E014
;	MOVE.L	A3,D0
;	BNE.S	lbC01E028
;	MOVEA.L	A5,A3
;	BRA.S	lbC01E028

;lbC01E014	MOVEA.L	D0,A2
;	LEA	4(A2),A2
;	MOVE.L	A0,-(SP)
;	MOVE.L	A2,-(SP)
;	BSR.L	lbC01FE44			; compare string
;	ADDQ.L	#8,SP
;	BEQ.L	lbC01E0C0
;lbC01E028	ADDQ.L	#6,A5
;	DBRA	D7,lbC01E006
;	MOVE.L	A3,D0
;	BEQ.L	lbC01E0CE
;	MOVEA.L	D0,A5
;	EXG	A0,A1
;	LEA	instr.MSG(PC),A2
;	MOVEA.L	A0,A3
;	BSR.L	lbC01DF04			; copy string
;	MOVE.L	#$3ED,D0
;	BSR.L	lbC01DF4C			; open file
;	MOVE.L	D0,D2
;	BNE.S	lbC01E06E
;	SUBA.L	A0,A0
;	BSR.L	lbC01DF04			; copy string
;	MOVE.L	#$3ED,D0
;	BSR.L	lbC01DF4C			; open file
;	MOVE.L	D0,D2
;	BNE.S	lbC01E06E
;	BSET	#6,$56(A6)
;	BRA.L	lbC01E0D4

;lbC01E06E	LEA	$472(A6),A0		; file ptr
;	MOVEQ	#$20,D1				; file size
;	BSR.L	lbC01DF9E			; read file
;	CMP.L	D1,D0
;	BNE.L	lbC01E0D4			; read error
;	LEA	SYNTTECH(PC),A4
;	TST.B	(A0)
;	BEQ.S	lbC01E0A2
;lbC01E086	MOVEA.L	A4,A2
;	ADDA.W	2(A4),A2
;	MOVE.L	A2,-(SP)
;	MOVE.L	A0,-(SP)
;	BSR.L	lbC01FE44			; compare string
;	ADDQ.L	#8,SP
;	BEQ.S	lbC01E0A2
;	MOVE.W	0(A4),D0
;	BEQ.S	lbC01E0D4
;	ADDA.W	D0,A4
;	BRA.S	lbC01E086

;lbC01E0A2	MOVEA.L	A3,A0
;	MOVE.L	D2,D0
;	JSR	4(A4)
;	MOVE.L	D0,D2
;	MOVE.L	A0,D0
;	BEQ.S	lbC01E0D4
;	MOVE.L	A4,0(A0)			; put tech
;	LEA	4(A0),A2
;lbC01E0B8	MOVE.B	(A1)+,(A2)+		; copy sample name
;	BNE.S	lbC01E0B8
;	MOVE.L	A0,0(A5)			; put info address
;lbC01E0C0	ADDQ.W	#1,4(A5)
;lbC01E0C4	MOVE.L	D2,D0
;	BEQ.S	lbC01E0CC
;	BSR.L	lbC01DF76			; close file
;lbC01E0CC	MOVE.L	A5,D0
;lbC01E0CE	MOVEM.L	(SP)+,D1-D7/A0-A6
;	RTS

;lbC01E0D4	SUBA.L	A5,A5
;	BRA.S	lbC01E0C4

; remove instrument routine

;lbC01E0D8	MOVEM.L	D0-D7/A0-A6,-(SP)
;	LEA	$8A(A6),A0
;	MOVEQ	#$3F,D7
;lbC01E0E2	CLR.W	4(A0)
;	BSR.S	lbC01E0F4
;	ADDQ.L	#6,A0
;	DBRA	D7,lbC01E0E2
;	MOVEM.L	(SP)+,D0-D7/A0-A6
;	RTS

;lbC01E0F4	MOVEM.L	D0-D7/A0-A6,-(SP)
;	MOVE.L	A0,D0
;	BEQ.S	lbC01E120
;	MOVEA.L	D0,A5
;	SUBQ.W	#1,4(A5)
;	BGT.S	lbC01E120
;	MOVE.L	0(A5),D0
;	BEQ.S	lbC01E11C
;	MOVEA.L	D0,A0
;	BSR.L	lbC01E126
;	MOVEA.L	0(A0),A1
;	JSR	8(A1)
;	CLR.L	0(A5)
;lbC01E11C	CLR.W	4(A5)
;lbC01E120	MOVEM.L	(SP)+,D0-D7/A0-A6
;	RTS

;lbC01E126	MOVEM.L	D0-D7/A0-A6,-(SP)
;	MOVE.L	A0,D0
;	BEQ.S	lbC01E152
;	LEA	$20A(A6),A1
;	CLR.B	D0
;lbC01E134	CMPI.B	#0,1(A1)
;	BEQ.S	lbC01E146
;	CMPA.L	4(A1),A0
;	BNE.S	lbC01E146
;	BSR.L	STOPNOTE
;lbC01E146	ADDA.W	#$54,A1
;	ADDQ.B	#1,D0
;	CMPI.B	#4,D0
;	BNE.S	lbC01E134
;lbC01E152	MOVEM.L	(SP)+,D0-D7/A0-A6
;	RTS

StartNote	MOVEM.L	D0-D2/D4/A0-A3,-(SP)
	MOVE.L	A0,D4
	BEQ.S	lbC01E1BA
	MOVE.L	0(A0),D4
	BEQ.S	lbC01E1BA
	MOVEA.L	D4,A0
	EXT.W	D0
	MOVE.W	D0,D4
	MULU.W	#$54,D4
	LEA	$20A(A6),A1
	ADDA.W	D4,A1
	CMPI.B	#0,1(A1)
	BEQ.S	lbC01E192
	MOVEA.L	0(A0),A2
	MOVEA.L	4(A1),A3
	MOVEA.L	0(A3),A3
	CMPA.L	A3,A2
	BEQ.S	lbC01E192
	BSR.L	StopNote
lbC01E192	MOVE.L	A0,4(A1)
	MOVE.W	D1,2(A1)
	ANDI.W	#$FF,D2
	MOVE.W	D2,8(A1)
	MOVE.B	D3,10(A1)
	CLR.W	D1
	BSR.L	lbC01E388
	MOVE.L	#$FFFFFFFF,$1C(A1)
	MOVE.B	#1,0(A1)
lbC01E1BA	MOVEM.L	(SP)+,D0-D2/D4/A0-A3
	RTS

;RELEASESOUND	MOVE.L	D0,-(SP)
;	CLR.L	$4A4(A6)
;	CLR.W	8(A6)
;	MOVEQ	#3,D0
;lbC01E1CC	BSR.S	RELEASENOTE
;	DBRA	D0,lbC01E1CC
;	MOVE.L	(SP)+,D0
;	RTS

ReleaseNote	MOVEM.L	D0/A1,-(SP)
	LEA	$20A(A6),A1
	EXT.W	D0
	MULU.W	#$54,D0
	ADDA.W	D0,A1
	CLR.B	0(A1)
	CMPI.B	#1,1(A1)
	BNE.S	lbC01E1F8
	MOVE.B	#2,0(A1)
lbC01E1F8	MOVEM.L	(SP)+,D0/A1
	RTS

;STOPSOUND	MOVE.L	D0,-(SP)
;	CLR.L	$4A4(A6)
;	CLR.W	8(A6)
;	MOVEQ	#3,D0
;lbC01E20A	BSR.S	STOPNOTE
;	DBRA	D0,lbC01E20A
;	MOVE.L	(SP)+,D0
;	RTS

StopNote	MOVEM.L	D0/D7/A0/A1,-(SP)
	EXT.W	D0
	MOVE.W	D0,D7
	LEA	$20A(A6),A1
	MULU.W	#$54,D0
	ADDA.W	D0,A1
	CLR.B	0(A1)
	CLR.L	$1C(A1)
	CMPI.B	#0,1(A1)
	BEQ.S	lbC01E240
	MOVE.B	#0,1(A1)
	BSR.L	lbC01EA46
lbC01E240	MOVEM.L	(SP)+,D0/D7/A0/A1
	RTS

;lbC01E246	BSR.L	StealTrack
;	BSET	D0,$57(A6)
;	BRA.L	StartNote

;StealTrack	BSET	D0,$58(A6)
;	BRA.S	StopNote

ResumeTrack	BCLR	D0,$58(A6)
	BCLR	D0,$57(A6)
	RTS

;lbC01E262	MOVEQ	#0,D0
;	MOVE.B	$57(A6),D0
;	ASL.B	#4,D0
;	OR.B	$59(A6),D0
;	RTS

;lbC01E270	MOVE.L	A1,-(SP)
;	EXT.W	D0
;	MULU.W	#$54,D0
;	LEA	$20A(A6),A1
;	ADDA.W	D0,A1
;	MOVE.L	$1C(A1),D0
;	MOVEA.L	(SP)+,A1
;	RTS

lbC01E286	MOVE.L	12(A1),D0
	BEQ.S	lbC01E29E
	CLR.L	12(A1)
;	MOVE.W	$10(A1),4(A2)			; length
;	MOVE.L	D0,0(A2)			; address

	move.l	D0,-(SP)
	move.w	$10(A1),D0
	bsr.w	PokeLen
	move.l	(SP)+,D0
	bsr.w	PokeAdr

	BSET	D7,D6
	BRA.S	lbC01E2B2

lbC01E29E	MOVE.L	$12(A1),D1
	BEQ.S	lbC01E2B2
	CLR.L	$12(A1)
;	MOVE.W	$16(A1),4(A2)			; length
;	MOVE.L	D1,0(A2)			; address

	move.l	D0,-(SP)
	move.w	$16(A1),D0
	bsr.w	PokeLen
	move.l	D1,D0
	bsr.w	PokeAdr
	move.l	(SP)+,D0

lbC01E2B2
;	MOVE.W	$18(A1),6(A2)			; period
;	MOVE.W	$1A(A1),8(A2)			; volume

	move.l	D0,-(SP)
	move.w	$18(A1),D0
	bsr.w	PokePer
	move.w	$1A(A1),D0
	bsr.w	PokeVol
	move.l	(SP)+,D0

	RTS

lbC01E2C0	MOVEM.L	D2/A2,-(SP)
	MOVEA.L	A0,A2
	MOVE.L	D0,D2
	ADD.L	D1,D2
	ADDA.L	D0,A0
	MOVE.L	D1,D0
	BNE.S	lbC01E2DA
	MOVEA.L	$3E2(A6),A0
	ADDA.W	#$400,A0
	MOVEQ	#8,D0
lbC01E2DA	BTST	#0,10(A1)
	BEQ.S	lbC01E2E6
	MOVEA.L	A0,A2
	MOVE.L	D0,D2
lbC01E2E6	TST.L	D1
	BNE.S	lbC01E2EE
	MOVE.L	D2,$1C(A1)
lbC01E2EE	MOVE.L	A2,12(A1)
	LSR.L	#1,D2
	MOVE.W	D2,$10(A1)
	MOVE.L	A0,$12(A1)
	LSR.L	#1,D0
	MOVE.W	D0,$16(A1)
	MOVEM.L	(SP)+,D2/A2
	RTS

lbC01E308	MOVE.L	D1,-(SP)
	MOVE.W	D7,D0
	BTST	D7,$58(A6)
	BEQ.S	lbC01E314
	ADDQ.W	#4,D0
lbC01E314	ADD.W	D0,D0
	MOVE.W	$5A(A6,D0.W),D0
	MOVE.W	8(A1),D1
	ADDQ.W	#1,D1
	MULU.W	D1,D0
	SWAP	D0
	MOVE.L	(SP)+,D1
	RTS

lbC01E328	MOVEM.L	D1/D7/A0,-(SP)
	ADD.W	D7,D7
	ADD.W	D7,D7
	MOVE.W	$48(A6,D7.W),D1
	BEQ.S	lbC01E33A
	MOVE.W	D1,D0
	BRA.S	lbC01E356

lbC01E33A	MOVE.W	$38(A6,D7.W),D1
	BEQ.S	lbC01E356
	ADDI.B	#$80,D1
	LSR.W	#2,D1
	ADD.W	D1,D1
	LEA	lbW01E3B2(PC),A0
	MOVE.W	0(A0,D1.W),D1
	MULU.W	D1,D0
	ADD.L	D0,D0
	SWAP	D0
lbC01E356	MOVEM.L	(SP)+,D1/D7/A0
	RTS

lbC01E35C	MOVEM.L	D1/D2,-(SP)
	MOVE.L	$1C(A1),D2
	BLE.S	lbC01E382
	MOVE.L	#$E90B,D1
	DIVU.W	D0,D1
	MULU.W	$32(A6),D1
	ADD.L	D1,D1
	CLR.W	D1
	SWAP	D1
	SUB.L	D1,D2
	BGE.S	lbC01E37E
	MOVEQ	#0,D2
lbC01E37E	MOVE.L	D2,$1C(A1)
lbC01E382	MOVEM.L	(SP)+,D1/D2
	RTS

lbC01E388	MOVEM.L	D0-D2,-(SP)
	EXT.W	D0
	ADD.W	D0,D0
	ADD.W	D0,D0
	TST.W	D1
	BEQ.S	lbC01E3A0
	MOVE.L	#$369E99,D2
	DIVU.W	D1,D2
	MOVE.W	D2,D1
lbC01E3A0	MOVE.W	D1,$48(A6,D0.W)
	MOVEM.L	(SP)+,D0-D2
	RTS

;instr.MSG	dc.b	'.instr',0,0
lbW01E3B2	dc.w	$C24D
	dc.w	$BFC8
	dc.w	$BD4C
	dc.w	$BAD8
	dc.w	$B86C
	dc.w	$B608
	dc.w	$B3AC
	dc.w	$B158
	dc.w	$AF0C
	dc.w	$ACC7
	dc.w	$AA8A
	dc.w	$A854
	dc.w	$A626
	dc.w	$A3FF
	dc.w	$A1DF
	dc.w	$9FC6
	dc.w	$9DB4
	dc.w	$9BA9
	dc.w	$99A4
	dc.w	$97A6
	dc.w	$95AF
	dc.w	$93BF
	dc.w	$91D5
	dc.w	$8FF1
	dc.w	$8E13
	dc.w	$8C3C
	dc.w	$8A6B
	dc.w	$88A0
	dc.w	$86DA
	dc.w	$851B
	dc.w	$8362
	dc.w	$81AE
	dc.w	$8000
	dc.w	$7E57
	dc.w	$7CB4
	dc.w	$7B16
	dc.w	$797E
	dc.w	$77EB
	dc.w	$765D
	dc.w	$74D4
	dc.w	$7351
	dc.w	$71D2
	dc.w	$7059
	dc.w	$6EE4
	dc.w	$6D74
	dc.w	$6C09
	dc.w	$6AA2
	dc.w	$6941
	dc.w	$67E4
	dc.w	$668B
	dc.w	$6537
	dc.w	$63E7
	dc.w	$629C
	dc.w	$6154
	dc.w	$6012
	dc.w	$5ED3
	dc.w	$5D98
	dc.w	$5C62
	dc.w	$5B2F
	dc.w	$5A01
	dc.w	$58D6
	dc.w	$57B0
	dc.w	$568D
	dc.w	$556E

InitScore
;	MOVEM.L	D1-D7/A0-A6,-(SP)
;	MOVE.L	SP,$496(A6)
;	SUBA.L	A5,A5
;	ANDI.B	#$3F,$56(A6)
;	MOVE.L	A1,$492(A6)
;	MOVEA.L	A0,A1
;	MOVE.L	#$72,D0
;	MOVE.L	#$10001,D1
;	BSR.L	lbC01FE82			; alloc mem
;	MOVE.L	A0,D0
;	BEQ.L	lbC01E4F4
;	MOVEA.L	A0,A5
;	MOVEA.L	A1,A0
;	MOVEQ	#1,D0
;	BSR.L	lbC01FEDE			; get size + read
;	MOVE.L	A0,$6E(A5)			; song ptr
;	BEQ.L	lbC01E4F4

	movem.l	D2-A6,-(SP)
	lea	Buffer2,A5
	moveq	#0,D1

	MOVEA.L	A0,A4
	MOVE.W	$10(A4),0(A5)
	MOVE.W	$12(A4),2(A5)
	MOVE.W	#$80,4(A5)
	MOVEA.L	A5,A0
	LEA	$14(A4),A1
	LEA	0(A4),A2
	MOVEQ	#3,D7
lbC01E490	MOVE.L	A1,$1A(A0)

	cmp.w	#-1,(A1)
	beq.b	NoV
	addq.l	#1,D1
NoV
	ADDA.L	(A2)+,A1
	MOVE.B	#$FF,13(A0)
	ADDQ.L	#4,A0
	DBRA	D7,lbC01E490

	move.l	A1,D0
	movem.l	(SP)+,D2-A6

;	MOVEA.L	A1,A2
;	LEA	$2A(A5),A3			; sample number
;lbC01E4A8	TST.B	(A2)
;	BEQ.S	lbC01E4DA
;	MOVEA.L	A2,A0
;	MOVEA.L	$492(A6),A1
;	BSR.L	INITINSTRUMENT			; load instrument
;	TST.L	D0
;	BNE.S	lbC01E4C4			; load OK
;	BSET	#7,$56(A6)
;	BRA.L	lbC01E4FA

;lbC01E4C4	LEA	$8A(A6),A0
;	SUB.L	A0,D0
;	DIVU.W	#6,D0
;	ADDQ.B	#1,D0
;	MOVE.B	D0,(A3)
;lbC01E4D2	TST.B	(A2)+
;	BNE.S	lbC01E4D2
;	ADDQ.L	#1,A3
;	BRA.S	lbC01E4A8

;lbC01E4DA	LEA	$4AC(A6),A0
;lbC01E4DE	MOVE.L	(A0),D0
;	BEQ.S	lbC01E4EA
;	MOVEA.L	D0,A0
;	LEA	$6A(A0),A0
;	BRA.S	lbC01E4DE

;lbC01E4EA	MOVE.L	A5,(A0)
;lbC01E4EC	MOVE.L	A5,D0
;	MOVEM.L	(SP)+,D1-D7/A0-A6
;	RTS

;lbC01E4F4	BSET	#6,$56(A6)
;lbC01E4FA	MOVEA.L	$496(A6),SP
;	MOVEA.L	A5,A0
;	BSR.L	lbC01E51E
;	SUBA.L	A5,A5
;	BRA.S	lbC01E4EC

;lbC01E508	MOVEM.L	D0-D7/A0-A6,-(SP)
;lbC01E50C	MOVE.L	$4AC(A6),D0
;	BEQ.S	lbC01E518
;	MOVEA.L	D0,A0
;	BSR.S	lbC01E51E
;	BRA.S	lbC01E50C

;lbC01E518	MOVEM.L	(SP)+,D0-D7/A0-A6
;	RTS

;lbC01E51E	MOVEM.L	D0-D7/A0-A6,-(SP)
;	MOVE.L	A0,D0
;	BEQ.L	lbC01E584
;	MOVEA.L	D0,A5
;	CMPA.L	4(A6),A5
;	BNE.S	lbC01E53C
;	BSR.L	STOPSCORE
;	CLR.L	4(A6)
;	CLR.W	$2E(A6)
;lbC01E53C	LEA	$2A(A5),A1
;	MOVEQ	#$3F,D7
;lbC01E542	MOVE.B	(A1)+,D0
;	BEQ.S	lbC01E558
;	SUBQ.B	#1,D0
;	LEA	$8A(A6),A0
;	EXT.W	D0
;	MULU.W	#6,D0
;	ADDA.W	D0,A0
;	BSR.L	lbC01E0F4
;lbC01E558	DBRA	D7,lbC01E542
;	MOVEA.L	$6E(A5),A0
;	BSR.L	lbC01FEB2			; free mem
;	MOVEA.L	$6A(A5),A1
;	LEA	$4AC(A6),A0
;lbC01E56C	MOVE.L	(A0),D0
;	BEQ.S	lbC01E57E
;	CMP.L	A5,D0
;	BEQ.S	lbC01E57C
;	MOVEA.L	D0,A0
;	LEA	$6A(A0),A0
;	BRA.S	lbC01E56C

;lbC01E57C	MOVE.L	A1,(A0)
;lbC01E57E	MOVEA.L	A5,A0
;	BSR.L	lbC01FEB2			; free mem
;lbC01E584	MOVEM.L	(SP)+,D0-D7/A0-A6
;	RTS

;RELEASESCORE	MOVEM.L	D0-D2,-(SP)
;	BSET	#0,$56(A6)
;	TST.W	D0
;	BNE.S	lbC01E59A
;	MOVEQ	#1,D0
;lbC01E59A	CLR.W	D1
;	MOVEQ	#15,D2
;	BSR.L	RAMPVOLUME
;	MOVEM.L	(SP)+,D0-D2
;	RTS

PlayScore	MOVEM.L	D0-D7/A0-A6,-(SP)
	MOVE.W	D2,D7
	BSR.L	StopScore
	MOVE.L	A0,D5
	BEQ.S	lbC01E5F4
	MOVEA.L	D5,A5
	CMP.L	D0,D1
	BEQ.S	lbC01E5F4
	BCS.S	lbC01E5F4
	MOVE.L	D0,10(A6)
	MOVE.L	D1,$12(A6)
	MOVE.W	2(A5),0(A6)
	MOVEA.L	A5,A0
	BSR.L	lbC01E632
	BSR.L	lbC01E6E2
	MOVE.L	A5,4(A6)
	CLR.W	$2E(A6)
	MOVEQ	#15,D2
	CLR.W	D0
	CLR.B	D1
	BSR.L	RampVolume
	MOVE.W	D3,D0
	MOVE.B	D4,D1
	BSR.L	RampVolume
	MOVE.W	D7,8(A6)
lbC01E5F4	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTS

StopScore
;	CLR.L	$4A4(A6)
lbC01E5FE	MOVEM.L	D0/A0,-(SP)
;	BCLR	#0,$56(A6)
	TST.W	8(A6)
	BEQ.S	lbC01E62C
	CLR.W	8(A6)
	MOVEQ	#0,D0
lbC01E614	BTST	D0,$58(A6)
	BNE.S	lbC01E61E
	BSR.L	ReleaseNote
lbC01E61E	ADDQ.B	#1,D0
	CMPI.B	#4,D0
	BNE.S	lbC01E614
;	ANDI.B	#$F0,$59(A6)
lbC01E62C	MOVEM.L	(SP)+,D0/A0
	RTS

lbC01E632	MOVEM.L	D0-D7/A0-A6,-(SP)
	CLR.W	$37C(A6)
	MOVE.B	#15,$37A(A6)
	MOVEA.L	A0,A3
	LEA	$37A(A6),A1
	MOVE.L	D0,D6
	CLR.B	D7
lbC01E64A	CLR.W	$14(A1)
	CLR.B	$24(A1)
	CLR.B	$26(A1)
	MOVE.B	#$FF,$25(A1)
	MOVE.L	$1A(A0),D0
	BEQ.S	lbC01E6C6
	MOVEA.L	D0,A2
	MOVE.L	D6,D5
lbC01E666	MOVE.L	A2,4(A1)
	MOVE.W	(A2)+,D0
	CMPI.W	#$FFFF,D0
	BEQ.S	lbC01E6C6
	TST.L	D5
	BLE.S	lbC01E6CE
	TST.W	D0
	BPL.S	lbC01E666
	CMPI.W	#$8100,D0
	BCS.S	lbC01E6AC
	CMPI.W	#$8200,D0
	BCS.S	lbC01E6B4
	CMPI.W	#$8300,D0
	BCS.S	lbC01E6BA
	CMPI.W	#$8400,D0
	BCS.S	lbC01E6C0
	CMPI.W	#$C000,D0
	BCS.S	lbC01E666
	ANDI.L	#$3FFF,D0
	SUB.L	D0,D5
	BPL.S	lbC01E666
	MOVE.W	D5,D0
	NEG.W	D0
	MOVE.W	D0,$14(A1)
	BRA.S	lbC01E666

lbC01E6AC	ADDQ.B	#1,D0
	MOVE.B	D0,$24(A1)
	BRA.S	lbC01E666

lbC01E6B4	MOVE.B	D0,$25(A1)
	BRA.S	lbC01E666

lbC01E6BA	MOVE.B	D0,$37D(A6)
	BRA.S	lbC01E666

lbC01E6C0	MOVE.B	D0,$26(A1)
	BRA.S	lbC01E666

lbC01E6C6	CLR.L	4(A1)
	BCLR	D7,$37A(A6)
lbC01E6CE	ADDQ.L	#4,A0
	ADDQ.L	#4,A1
	ADDQ.B	#1,D7
	CMPI.B	#4,D7
	BNE.L	lbC01E64A
	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTS

lbC01E6E2	MOVEM.L	D0-D7/A0-A6,-(SP)
	LEA	$37A(A6),A2
	LEA	$3AE(A6),A1
	MOVEQ	#$19,D7
lbC01E6F0	MOVE.W	(A2)+,(A1)+
	DBRA	D7,lbC01E6F0
	MOVE.W	$3B0(A6),D0
	BEQ.S	lbC01E700
	MOVE.W	D0,0(A6)
lbC01E700	MOVE.L	10(A6),14(A6)
	MOVEA.L	A0,A1
	MOVEA.L	A6,A4
	CLR.B	D7
lbC01E70C	BTST	D7,$58(A6)
	BNE.S	lbC01E718
	MOVE.B	D7,D0
	BSR.L	ReleaseNote
lbC01E718	CLR.L	D0
	MOVE.W	$3C2(A4),D0
	ADDQ.W	#1,D0
	MOVE.L	D0,$36A(A4)
	CLR.L	D0
	MOVE.B	$3D2(A4),D0
	BEQ.S	lbC01E744
	SUBQ.B	#1,D0
	LEA	$2A(A0),A3
	MOVE.B	0(A3,D0.W),D0
	BEQ.S	lbC01E744
	SUBQ.B	#1,D0
	MULU.W	#6,D0
	LEA	$8A(A6),A3
	ADD.L	A3,D0
lbC01E744	MOVE.L	D0,$35A(A4)
	MOVE.B	$3D3(A4),13(A1)
	MOVE.B	$3D4(A4),$39(A4)
	ADDQ.L	#4,A1
	ADDQ.L	#4,A4
	ADDQ.B	#1,D7
	CMPI.B	#4,D7
	BCS.S	lbC01E70C
;	MOVE.B	$3AE(A6),D0
;	OR.B	D0,$59(A6)
	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTS

;lbW01E76E	dc.w	$64

PlaySNX
;Interrupt	MOVEM.L	D0-D7/A0-A6,-(SP)
;	MOVEA.L	Sonix(PC),A6
;	MOVE.L	$2A(A6),D0
;	BEQ.S	lbC01E782
;	MOVEA.L	D0,A0
;	JSR	(A0)
lbC01E782	BSR.L	lbC01EAB8
	BSR.L	lbC01EB14
	BSR.L	lbC01E7DA
	BSR.L	lbC01E996
;	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTS

lbC01E798	MOVEM.L	D1/A0,-(SP)
	CMP.W	$30(A6),D0
	BEQ.S	lbC01E7D4
	MOVE.W	D0,$30(A6)
;	MOVE.L	#$1B4F4D,D1			; for NTSC timer

	move.l	Clock(PC),D1

	DIVU.W	D0,D1
;	MOVEA.L	$52C(A6),A0
;	MOVE.B	D1,(A0)
;	LSR.W	#8,D1
;	MOVE.B	D1,$100(A0)
;	MOVEA.L	$530(A6),A0
;	MOVE.B	#$11,(A0)

	movem.l	A1/A5,-(SP)
	move.l	EagleBase(PC),A5
	move.w	D1,dtg_Timer(A5)
	move.l	dtg_SetTimer(A5),A1
	jsr	(A1)
	movem.l	(SP)+,A1/A5

	MOVE.L	#$4B0000,D1
	DIVU.W	D0,D1
	MOVE.W	D1,$32(A6)
	MOVE.W	#1,$34(A6)
lbC01E7D4	MOVEM.L	(SP)+,D1/A0
	RTS

lbC01E7DA	TST.W	$2E(A6)
	BEQ.S	lbC01E7E8
	SUBQ.W	#1,$2E(A6)
	BNE.L	lbC01E8CC
lbC01E7E8	MOVE.W	0(A6),D0
	BSR.S	lbC01E798
	MOVE.W	$34(A6),$2E(A6)
	TST.W	8(A6)
	BEQ.L	lbC01E8CC
	MOVEA.L	4(A6),A2
	CLR.W	D6
lbC01E802	MOVEA.L	A2,A1
	MOVEA.L	A6,A5
	LEA	$20A(A6),A4
	CLR.B	D7
lbC01E80C	TST.L	$36A(A5)
	BEQ.S	lbC01E818
	SUBQ.L	#1,$36A(A5)
	BNE.S	lbC01E874
lbC01E818	MOVE.L	$3B2(A5),D0
	BEQ.S	lbC01E872
	MOVEA.L	D0,A0
lbC01E820	MOVE.W	(A0)+,D2
	BEQ.S	lbC01E820
	CMPI.W	#$FFFF,D2
	BEQ.S	lbC01E866
	MOVE.L	A0,$3B2(A5)
	CMPI.W	#$C000,D2
	BCC.L	lbC01E928
	MOVE.W	D2,D3
	LSR.W	#8,D2
	ANDI.W	#$FF,D3
	TST.B	D2
	BPL.L	lbC01E8E2
	CMPI.B	#$80,D2
	BEQ.L	lbC01E938
	CMPI.B	#$81,D2
	BEQ.L	lbC01E958
	CMPI.B	#$82,D2
	BEQ.L	lbC01E960
	CMPI.B	#$83,D2
	BEQ.L	lbC01E96E
	BRA.S	lbC01E820

lbC01E866	CLR.L	$3B2(A5)
;	BCLR	D7,$59(A6)
;	BSR.L	lbC01EB42
lbC01E872	ADDQ.W	#1,D6
lbC01E874	ADDQ.L	#4,A1
	ADDQ.L	#4,A5
	ADDA.W	#$54,A4
	ADDQ.B	#1,D7
	CMPI.B	#4,D7
	BNE.S	lbC01E80C
	MOVE.L	14(A6),D0
	ADDQ.L	#1,14(A6)
;	CMP.L	$4A8(A6),D0
;	BNE.S	lbC01E896
;	BSR.L	lbC01E976
lbC01E896	MOVE.L	$12(A6),D1
	BPL.S	lbC01E8A4
	CMPI.W	#4,D6
	BNE.S	lbC01E8CC
	BRA.S	lbC01E8A8

lbC01E8A4	CMP.L	D1,D0
	BNE.S	lbC01E8CC
lbC01E8A8
;	TST.W	8(A6)
;	BMI.S	lbC01E8C0
;	SUBQ.W	#1,8(A6)
;	BNE.S	lbC01E8C0
;	ANDI.B	#$F0,$59(A6)
;	BSR.L	lbC01EB42
;	BRA.S	lbC01E8CC

lbC01E8C0

	bsr.w	SongEnd

	MOVEA.L	A2,A0
	BSR.L	lbC01E6E2
	ADDQ.W	#1,D6
	BRA.L	lbC01E802

lbC01E8CC
;	TST.W	8(A6)
;	BNE.S	lbC01E8E0
;	TST.L	$4A4(A6)
;	BEQ.S	lbC01E8E0
;	BSR.L	lbC01E976
;	CLR.L	$4A4(A6)
lbC01E8E0	RTS

lbC01E8E2	BTST	D7,$58(A6)
	BNE.S	lbC01E8F2
	MOVE.B	D7,D0
	TST.B	D3
	BNE.S	lbC01E8F6
	BSR.L	ReleaseNote
lbC01E8F2	BRA.L	lbC01E820

lbC01E8F6	MOVE.L	$35A(A5),D1
	BNE.S	lbC01E902
	MOVE.L	6(A2),D1
	BEQ.S	lbC01E8F2
lbC01E902	MOVEA.L	D1,A0
	MOVE.W	4(A2),D1
	ASR.W	#4,D1
	SUBI.W	#8,D1
	ADD.W	D2,D1
	MOVE.W	12(A1),D2
	ADDQ.W	#1,D2
	ADD.W	D3,D3
	ADDQ.W	#1,D3
	MULU.W	D3,D2
	LSR.W	#8,D2
	MOVEQ	#0,D3
	BSR.L	StartNote
	BRA.L	lbC01E818

lbC01E928	ANDI.W	#$3FFF,D2
	BEQ.L	lbC01E820
	MOVE.W	D2,$36C(A5)
	BRA.L	lbC01E874

lbC01E938	CLR.L	D0
	LEA	$2A(A2),A3
	MOVE.B	0(A3,D3.W),D0
	BEQ.S	lbC01E950
	SUBQ.B	#1,D0
	MULU.W	#6,D0
	LEA	$8A(A6),A3
	ADD.L	A3,D0
lbC01E950	MOVE.L	D0,$35A(A5)
	BRA.L	lbC01E820

lbC01E958	MOVE.B	D3,13(A1)
	BRA.L	lbC01E820

lbC01E960	MOVE.W	D3,D0
	MOVE.W	D0,0(A6)
	BSR.L	lbC01E798
	BRA.L	lbC01E820

lbC01E96E	MOVE.B	D3,$39(A5)
	BRA.L	lbC01E820

;lbC01E976	MOVEM.L	D0/D1/A0/A1,-(SP)
;	MOVE.L	$4A4(A6),D0
;	BEQ.S	lbC01E990
;	MOVEA.L	$4A0(A6),A1
;	MOVE.L	A6,-(SP)
;	MOVEA.L	4,A6
;	JSR	-$144(A6)			; signal
;	MOVEA.L	(SP)+,A6
;lbC01E990	MOVEM.L	(SP)+,D0/D1/A0/A1
;	RTS

lbC01E996
;	BCLR	#1,$56(A6)
	LEA	$20A(A6),A1
	MOVEQ	#0,D7
lbC01E9A2	TST.B	0(A1)
	BNE.S	lbC01E9B0
	CMPI.B	#0,1(A1)
	BEQ.S	lbC01E9E4
lbC01E9B0	MOVE.L	4(A1),D0
	BEQ.S	lbC01E9DC
	MOVEA.L	D0,A4
	MOVEA.L	0(A4),A4
	MOVEM.L	D7/A1/A6,-(SP)
	JSR	12-12(A4)
	MOVEM.L	(SP)+,D7/A1/A6
	MOVEQ	#1,D0
	CMPI.B	#1,0(A1)
	BEQ.S	lbC01E9DC
	MOVEQ	#2,D0
	CMPI.B	#2,0(A1)
	BNE.S	lbC01E9E0
lbC01E9DC	MOVE.B	D0,1(A1)
lbC01E9E0	CLR.B	0(A1)
lbC01E9E4	ADDA.W	#$54,A1
	ADDQ.W	#1,D7
	CMPI.W	#4,D7
	BNE.S	lbC01E9A2
;	BTST	#1,$56(A6)
;	BEQ.S	lbC01EA0A
;	MOVE.W	lbW01E76E(PC),D2
;	MOVEA.L	$52C(A6),A0
;	MOVE.B	(A0),D0
;lbC01EA02	MOVE.B	D0,D1
;	SUB.B	(A0),D1
;	CMP.B	D2,D1
;	BCS.S	lbC01EA02
lbC01EA0A	LEA	$20A(A6),A1
	LEA	$DFF0A0,A2
	CLR.W	D7
	MOVE.W	#$8000,D6
lbC01EA1A	CMPI.B	#0,1(A1)
	BEQ.S	lbC01EA2E
	MOVEA.L	4(A1),A4
	MOVEA.L	0(A4),A4
	JSR	$10-12(A4)
lbC01EA2E	ADDA.W	#$10,A2
	ADDA.W	#$54,A1
	ADDQ.W	#1,D7
	CMPI.W	#4,D7
	BNE.S	lbC01EA1A
;	MOVE.W	D6,$DFF096			; DMA

	move.l	D0,-(SP)
	move.w	D6,D0
	bsr.w	PokeDMA
	move.l	(SP)+,D0

	RTS

lbC01EA46	CLR.W	D0
	BSET	D7,D0
;	MOVE.W	D0,$DFF096			; DMA

	bsr.w	PokeDMA

	MOVE.W	D7,D0
	ASL.W	#4,D0
	LEA	$DFF0A0,A0

	movem.l	D0/A2,-(SP)
	lea	(A0,D0.W),A2
	moveq	#2,D0
	bsr.w	PokePer
	movem.l	(SP)+,D0/A2

;	MOVE.W	#2,6(A0,D0.W)			; period
;	BSET	#1,$56(A6)
	RTS

;lbC01EA68	MOVEM.L	D0/D7/A0,-(SP)
;	MOVE.B	D0,D7
;	EXT.W	D7
;	BSR.S	lbC01EA46
;	MOVEM.L	(SP)+,D0/D7/A0
;	RTS

RampVolume	MOVEM.L	D1-D3/A5,-(SP)
	ASL.W	#8,D1
	MOVEA.L	A6,A5
lbC01EA80	TST.B	D2
	BEQ.S	lbC01EAB2
	LSR.B	#1,D2
	BCC.S	lbC01EAA8
	MOVEQ	#0,D3
	TST.W	D0
	BEQ.S	lbC01EAAC
	MOVE.W	D1,$6A(A5)
	MOVE.W	$5A(A5),D3
	SUB.W	D1,D3
	BCC.S	lbC01EA9C
	NEG.W	D3
lbC01EA9C	DIVU.W	D0,D3
	TST.W	D3
	BNE.S	lbC01EAA4
	MOVEQ	#1,D3
lbC01EAA4	MOVE.W	D3,$7A(A5)
lbC01EAA8	ADDQ.L	#2,A5
	BRA.S	lbC01EA80

lbC01EAAC	MOVE.W	D1,$5A(A5)
	BRA.S	lbC01EAA4

lbC01EAB2	MOVEM.L	(SP)+,D1-D3/A5
	RTS

lbC01EAB8	MOVEA.L	A6,A5
	MOVEQ	#7,D7
lbC01EABC	MOVE.W	$7A(A5),D0
	BEQ.S	lbC01EAE8
	MOVE.W	$5A(A5),D1
	MULU.W	$32(A6),D0
	ADD.L	D0,D0
	BCS.S	lbC01EB0A
	SWAP	D0
	MOVE.W	D0,D3
	MOVE.W	$6A(A5),D2
	SUB.W	D1,D2
	BCC.S	lbC01EADE
	NEG.W	D3
	NEG.W	D2
lbC01EADE	CMP.W	D2,D0
	BCC.S	lbC01EB0A
	ADD.W	D3,D1
lbC01EAE4	MOVE.W	D1,$5A(A5)
lbC01EAE8	ADDQ.L	#2,A5
	DBRA	D7,lbC01EABC
;	BTST	#0,$56(A6)
;	BEQ.S	lbC01EB08
;	LEA	$5A(A6),A0
;	MOVE.L	(A0)+,D0
;	OR.L	(A0)+,D0
;	BNE.S	lbC01EB08
;	BSR.L	lbC01E5FE
;	BSR.L	lbC01EB42
lbC01EB08	RTS

lbC01EB0A	CLR.W	$7A(A5)
	MOVE.W	$6A(A5),D1
	BRA.S	lbC01EAE4

lbC01EB14	LEA	$20A(A6),A1
	MOVEQ	#0,D7
lbC01EB1A	BTST	D7,$57(A6)
	BEQ.S	lbC01EB34
	TST.L	$1C(A1)
	BNE.S	lbC01EB34
	MOVE.B	D7,D0
	BSR.L	ReleaseNote
	BSR.L	ResumeTrack
;	BSR.L	lbC01EB42
lbC01EB34	ADDA.W	#$54,A1
	ADDQ.B	#1,D7
	CMPI.B	#4,D7
	BNE.S	lbC01EB1A
	RTS

;lbC01EB42	TST.L	$26(A6)
;	BEQ.S	lbC01EB56
;	MOVEM.L	D0-D7/A0-A6,-(SP)
;	MOVEA.L	$26(A6),A0
;	JSR	(A0)
;	MOVEM.L	(SP)+,D0-D7/A0-A6
;lbC01EB56	RTS

;lbW01EB58	dc.w	$8000
;	dc.w	$78D1
;	dc.w	$7209
;	dc.w	$6BA2
;	dc.w	$6598
;	dc.w	$5FE4
;	dc.w	$5A82
;	dc.w	$556E
;	dc.w	$50A3
;	dc.w	$4C1C
;	dc.w	$47D6
;	dc.w	$43CE
;	dc.w	$4000
SyntTech
;	dc.w	SSTech-SyntTech
;	dc.w	Synthesis.MSG-SyntTech

;	BRA.L	lbC01EB86

;	BRA.L	lbC01EBC6

	BRA.L	lbC01EC0E

	BRA.L	lbC01EBE8

;lbC01EB86	MOVEM.L	D0-D7/A1-A6,-(SP)
;	MOVE.L	D0,D3
;	MOVE.L	#$1DA,D0
;	MOVE.L	#$10001,D1
;	BSR.L	lbC01FE82			; alloc mem
;	MOVE.L	A0,D0
;	BEQ.S	lbC01EBBA
;	MOVE.L	D3,D0
;	MOVE.L	#$1D6,D1			; file size
;	BSR.L	lbC01DF9E			; read file
;	CMP.L	D1,D0
;	BNE.S	lbC01EBC0
;	BSR.L	SETFILTER
;	TST.L	$1D6(A0)
;	BEQ.S	lbC01EBC0
;lbC01EBBA	MOVEM.L	(SP)+,D0-D7/A1-A6
;	RTS

;lbC01EBC0	BSR.S	lbC01EBC6
;	SUBA.L	A0,A0
;	BRA.S	lbC01EBBA

;lbC01EBC6	MOVEM.L	D0-D7/A0-A6,-(SP)
;	MOVE.L	$1D6(A0),D0
;	BSR.L	lbC01FEB2			; free mem
;	TST.L	D0
;	BEQ.S	lbC01EBE2
;	MOVEA.L	D0,A0
;	SUBQ.W	#1,$2000(A0)
;	BNE.S	lbC01EBE2
;	BSR.L	lbC01FEB2			; free mem
;lbC01EBE2	MOVEM.L	(SP)+,D0-D7/A0-A6
;	RTS

lbC01EBE8
;	MOVE.L	12(A1),0(A2)			; address
;	MOVE.W	$10(A1),4(A2)			; length
;	MOVE.W	$18(A1),6(A2)			; period
;	MOVE.W	$1A(A1),8(A2)			; volume

	move.l	D0,-(SP)
	move.l	12(A1),D0
	bsr.w	PokeAdr
	move.w	$10(A1),D0
	bsr.w	PokeLen
	move.w	$18(A1),D0
	bsr.w	PokePer
	move.w	$1A(A1),D0
	bsr.w	PokeVol
	move.l	(SP)+,D0

	TST.B	10(A1)
	BEQ.S	lbC01EC0C
	CLR.B	10(A1)
	BSET	D7,D6
lbC01EC0C	RTS

lbC01EC0E	MOVEA.L	4(A1),A3
	LEA	$20(A1),A2
	MOVE.B	0(A1),D0
	BEQ.L	lbC01ED26
	CMPI.B	#1,D0
	BNE.L	lbC01ED1A
	CLR.L	D1
	MOVE.W	2(A1),D1
	CMPI.W	#$24,D1
	BGE.S	lbC01EC48
lbC01EC32	CLR.B	0(A1)
	CLR.L	$1C(A1)
	CMPI.B	#0,1(A1)
	BEQ.L	lbC01EFEE
	BRA.L	lbC01ED26

lbC01EC48	CMPI.W	#$6C,D1
	BGE.S	lbC01EC32
	SUBI.W	#$24,D1
	CMPI.B	#0,1(A1)
	BNE.S	lbC01EC5E
	CLR.L	12(A2)
lbC01EC5E	CMPI.B	#1,1(A1)
	BEQ.S	lbC01EC82
	CLR.W	10(A2)
	BTST	#0,10(A1)
	BEQ.S	lbC01EC82
	MOVE.W	#4,10(A2)
	MOVE.L	$1CA(A3),D0
	CLR.W	D0
	MOVE.L	D0,12(A2)
lbC01EC82	DIVU.W	#12,D1
	MOVE.W	D1,D2
	SWAP	D1
	ASL.W	#1,D1
	LEA	lbW01EB58(PC),A0
	MOVE.W	#$D5C8,D0
	MULU.W	0(A0,D1.W),D0
	ADDI.W	#$11,D2
	LSR.L	D2,D0
	TST.W	0(A2)
	BNE.S	lbC01ECAA
	CLR.W	2(A2)
	BRA.S	lbC01ECD2

lbC01ECAA	MOVE.W	D0,D1
	SUB.W	0(A2),D1
	EXT.L	D1
	MOVE.W	$1B2(A3),D2
	SWAP	D2
	CLR.W	D2
	LSR.L	#1,D2
	DIVU.W	$32(A6),D2
	LSR.W	#3,D2
	ADDQ.W	#1,D2
	MOVE.W	D2,2(A2)
	DIVS.W	D2,D1
	MOVE.W	D1,4(A2)
	MULU.W	D2,D1
	SUB.W	D1,D0
lbC01ECD2	MOVE.W	D0,0(A2)
	MOVE.W	#1,$18(A2)
	TST.W	$1C2(A3)
	BNE.S	lbC01ECE6
	CLR.W	$16(A2)
lbC01ECE6	CLR.W	$12(A2)
	TST.W	$1BE(A3)
	BEQ.S	lbC01ED12
	CLR.W	$10(A2)
	MOVE.W	$1C0(A3),D0
	SWAP	D0
	CLR.W	D0
	LSR.L	#1,D0
	DIVU.W	$32(A6),D0
	LSR.W	#2,D0
	MOVE.W	D0,$12(A2)
	MOVE.B	$A4(A3),D0
	EXT.W	D0
	MOVE.W	D0,$14(A2)
lbC01ED12	MOVE.B	#$FF,10(A1)
	BRA.S	lbC01ED26

lbC01ED1A	CMPI.B	#2,D0
	BNE.S	lbC01ED26
	MOVE.W	#6,10(A2)
lbC01ED26	TST.W	$12(A2)
	BMI.S	lbC01ED76
	BEQ.S	lbC01ED34
	SUBQ.W	#1,$12(A2)
	BRA.S	lbC01ED76

lbC01ED34	MOVE.W	$10(A2),D0
	MOVE.W	$1BC(A3),D1
	MULU.W	$32(A6),D1
	ASL.L	#6,D1
	SWAP	D1
	TST.W	$1BE(A3)
	BLE.S	lbC01ED60
	ADD.W	D1,D0
	BCS.S	lbC01ED54
	CMPI.W	#$FE00,D0
	BCS.S	lbC01ED62
lbC01ED54	MOVE.W	#$FFFF,$12(A2)
	MOVE.W	#$FE00,D0
	BRA.S	lbC01ED62

lbC01ED60	ADD.W	D1,D0
lbC01ED62	MOVE.W	D0,$10(A2)
	LSR.W	#8,D0
	LEA	$A4(A3),A0
	MOVE.B	0(A0,D0.W),D0
	EXT.W	D0
	MOVE.W	D0,$14(A2)
lbC01ED76	MOVE.W	10(A2),D0
	LEA	0(A3,D0.W),A0
	CLR.L	D1
	MOVE.W	$1C6(A0),D1
	SWAP	D1
	MOVE.L	12(A2),D2
	CLR.L	D3
	MOVE.W	$1CE(A0),D3
	MOVE.W	D3,D0
	LSR.W	#5,D0
	EORI.W	#7,D0
	ANDI.W	#$1F,D3
	ADDI.W	#$21,D3
	MULU.W	$32(A6),D3
	ASL.L	#3,D3
	LSR.L	D0,D3
	MOVE.L	D1,D0
	SUB.L	D2,D0
	BPL.S	lbC01EDB0
	NEG.L	D0
lbC01EDB0	CMP.L	D3,D0
	BGT.S	lbC01EDC8
	MOVE.L	D1,D2
	CMPI.W	#4,10(A2)
	BLT.S	lbC01EDC0
	BRA.S	lbC01EDD2

lbC01EDC0	ADDI.W	#2,10(A2)
	BRA.S	lbC01EDD2

lbC01EDC8	CMP.L	D1,D2
	BLT.S	lbC01EDD0
	SUB.L	D3,D2
	BRA.S	lbC01EDD2

lbC01EDD0	ADD.L	D3,D2
lbC01EDD2	MOVE.L	D2,12(A2)
	BNE.S	lbC01EDDC
	CLR.L	$1C(A1)
lbC01EDDC	MOVE.W	0(A2),D0
	MOVEQ	#5,D2
	TST.W	2(A2)
	BEQ.S	lbC01EDF4
	SUBQ.W	#1,2(A2)
	ADD.W	4(A2),D0
	MOVE.W	D0,0(A2)
lbC01EDF4	CMPI.W	#$1AC,D0
	BLE.S	lbC01EE00
	LSR.W	#1,D0
	SUBQ.W	#1,D2
	BRA.S	lbC01EDF4

lbC01EE00	MOVE.W	D2,8(A2)
	MOVEQ	#$40,D1
	LSR.W	D2,D1
	MOVE.W	D1,$10(A1)
	MOVE.W	$14(A2),D1
	MOVE.W	$1B4(A3),D2
	MULS.W	D2,D1
	ASR.W	#7,D1
	MOVE.W	2(A6),D2
	SUBI.W	#$80,D2
	SUB.W	D2,D1
	ADDI.W	#$1000,D1
	MULU.W	D1,D0
	MOVEQ	#12,D1
	LSR.L	D1,D0
	BSR.L	lbC01E328
	MOVE.W	D0,$18(A1)
	MOVE.W	$1AC(A3),D0
	MOVE.W	$1B0(A3),D2
	BEQ.S	lbC01EE4A
	MOVE.W	$14(A2),D1
	NEG.W	D1
	MULS.W	D2,D1
	ASR.W	#8,D1
	ADD.W	D1,D0
lbC01EE4A	TST.W	$1AE(A3)
	BEQ.S	lbC01EE5C
	MOVE.L	12(A2),D1
	SWAP	D1
	MULU.W	D1,D0
	LSR.W	#8,D0
	BRA.S	lbC01EE66

lbC01EE5C	CMPI.W	#6,10(A2)
	BNE.S	lbC01EE66
	CLR.W	D0
lbC01EE66	ANDI.W	#$FF,D0
	ADDQ.W	#1,D0
	MOVE.W	D0,D1
	BSR.L	lbC01E308
	MULU.W	D1,D0
	LSR.W	#8,D0
	ADDQ.W	#1,D0
	LSR.W	#2,D0
	MOVE.W	D0,$1A(A1)
	MOVE.W	$1B8(A3),D0
	MOVE.L	12(A2),D1
	SWAP	D1
	MULU.W	D0,D1
	LSR.W	#8,D1
	MOVE.W	$1B6(A3),D0
	EORI.W	#$FF,D0
	SUB.W	D1,D0
	MOVE.W	$14(A2),D1
	MOVE.W	$1BA(A3),D2
	MULS.W	D2,D1
	ASR.W	#8,D1
	ADD.W	D1,D0
	ANDI.W	#$FF,D0
	LSR.W	#2,D0
	ASL.W	#7,D0
;	MOVEA.L	$1D6(A3),A0			; here filter pointer

	move.l	-4(A3),A0

	MOVE.L	A0,D1
	BNE.S	lbC01EEBA
	LEA	$24(A3),A0
	CLR.W	D0
lbC01EEBA	ADDA.W	D0,A0
	MOVE.W	6(A2),D0
	EORI.W	#$80,D0
	MOVE.W	D0,6(A2)
	MOVEA.L	$3E2(A6),A4
	LEA	0(A4,D0.W),A4
	MOVE.W	D7,D0
	ASL.W	#8,D0
	ADDA.W	D0,A4
	MOVE.L	A4,12(A1)
	TST.W	$1C2(A3)
	BNE.S	lbC01EEFA
	MOVE.W	8(A2),D3
	MOVEQ	#0,D1
	BSET	D3,D1
	MOVE.W	#$80,D4
	LSR.W	D3,D4
lbC01EEEE	MOVE.B	(A0),(A4)+
	ADDA.W	D1,A0
	SUBQ.W	#1,D4
	BNE.S	lbC01EEEE
	BRA.L	lbC01EFEE

lbC01EEFA	TST.W	$1C4(A3)
	BNE.L	lbC01EF6C
	MOVE.W	8(A2),D3
	MOVEQ	#0,D1
	BSET	D3,D1
	MOVE.W	$10(A1),D2
	ASL.W	#1,D2
	SUBQ.W	#1,D2
	MOVE.W	$1C2(A3),D4
	MULU.W	$32(A6),D4
	MOVEQ	#13,D0
	LSR.L	D0,D4
	ADD.W	$16(A2),D4
	MOVE.W	D4,$16(A2)
	MOVEQ	#9,D0
	LSR.W	D0,D4
	LEA	0(A0,D4.W),A5
	LSR.W	D3,D4
	SUB.W	D4,D2
lbC01EF32	MOVE.B	(A0),D0
	EXT.W	D0
	MOVE.B	(A5),D3
	EXT.W	D3
	ADD.W	D3,D0
	ASR.W	#1,D0
	MOVE.B	D0,(A4)+
	ADDA.W	D1,A0
	ADDA.W	D1,A5
	DBRA	D2,lbC01EF32
	SUBA.W	#$80,A5
	SUBQ.W	#1,D4
	BMI.L	lbC01EFEE
lbC01EF52	MOVE.B	(A0),D0
	EXT.W	D0
	MOVE.B	(A5),D3
	EXT.W	D3
	ADD.W	D3,D0
	ASR.W	#1,D0
	MOVE.B	D0,(A4)+
	ADDA.W	D1,A0
	ADDA.W	D1,A5
	DBRA	D4,lbC01EF52
	BRA.L	lbC01EFEE

lbC01EF6C	MOVE.W	$1C2(A3),D0
	MULU.W	$32(A6),D0
	MOVEQ	#11,D1
	LSR.L	D1,D0
	MULS.W	$18(A2),D0
	ADD.W	$16(A2),D0
	BVC.S	lbC01EF92
	CMPI.W	#$8000,D0
	BNE.S	lbC01EF8C
	ADD.W	$18(A2),D0
lbC01EF8C	NEG.W	$18(A2)
	NEG.W	D0
lbC01EF92	MOVE.W	D0,$16(A2)
	MOVE.W	$1C4(A3),D1
	MULS.W	D1,D0
	MOVEQ	#$11,D1
	ADD.W	8(A2),D1
	ASR.L	D1,D0
	MOVE.W	$10(A1),D2
	MOVE.W	D2,D3
	ADD.W	D0,D2
	SUB.W	D0,D3
	MOVE.W	D2,D6
	BEQ.S	lbC01EFCE
	CLR.W	D0
	CLR.W	D1
	MOVEQ	#$40,D4
	DIVU.W	D2,D4
	MOVE.W	D4,D5
	SWAP	D4
lbC01EFBE	MOVE.B	0(A0,D0.W),(A4)+
	SUB.W	D4,D1
	BCC.S	lbC01EFC8
	ADD.W	D2,D1
lbC01EFC8	ADDX.W	D5,D0
	SUBQ.W	#1,D6
	BNE.S	lbC01EFBE
lbC01EFCE	MOVE.W	D3,D6
	BEQ.S	lbC01EFEE
	MOVEQ	#$40,D0
	CLR.W	D1
	MOVEQ	#$40,D4
	DIVU.W	D3,D4
	MOVE.W	D4,D5
	SWAP	D4
lbC01EFDE	MOVE.B	0(A0,D0.W),(A4)+
	SUB.W	D4,D1
	BCC.S	lbC01EFE8
	ADD.W	D3,D1
lbC01EFE8	ADDX.W	D5,D0
	SUBQ.W	#1,D6
	BNE.S	lbC01EFDE
lbC01EFEE	RTS

SetFilter	MOVEM.L	D0-D7/A0-A6,-(SP)
;	MOVEA.L	A0,A1
;	LEA	$8A(A6),A5
;	MOVEQ	#$3F,D7
;lbC01EFFC	MOVE.L	0(A5),D0
;	BEQ.S	lbC01F050
;	MOVEA.L	D0,A0
;	CMPA.L	A1,A0
;	BEQ.S	lbC01F050
;	LEA	SYNTTECH(PC),A3
;	CMPA.L	0(A0),A3
;	BNE.S	lbC01F050
;	TST.L	$1D6(A0)
;	BEQ.S	lbC01F050
;	LEA	$24(A0),A3
;	LEA	$24(A1),A4
;	MOVEQ	#$1F,D6
;lbC01F022	MOVE.L	(A3)+,D0
;	CMP.L	(A4)+,D0
;	BNE.S	lbC01F050
;	DBRA	D6,lbC01F022
;	MOVEA.L	A0,A2
;	MOVE.L	$1D6(A1),D0
;	BEQ.S	lbC01F040
;	MOVEA.L	D0,A0
;	SUBQ.W	#1,$2000(A0)
;	BNE.S	lbC01F040
;	BSR.L	lbC01FEB2			; free mem
;lbC01F040	MOVEA.L	$1D6(A2),A0
;	MOVE.L	A0,$1D6(A1)
;	ADDQ.W	#1,$2000(A0)
;	BRA.L	lbC01F0EE

;lbC01F050	ADDQ.L	#6,A5
;	DBRA	D7,lbC01EFFC
;	MOVE.L	$1D6(A1),D2
;	BEQ.S	lbC01F066
;	MOVEA.L	D2,A2
;	CMPI.W	#1,$2000(A2)
;	BEQ.S	lbC01F08C
;lbC01F066	MOVE.L	#$2002,D0
;	MOVE.L	#1,D1
;	BSR.L	lbC01FE82			; alloc mem
;	MOVE.L	A0,D0
;	BEQ.S	lbC01F08C
;	TST.L	D2
;	BEQ.S	lbC01F082
;	SUBQ.W	#1,$2000(A2)
;lbC01F082	MOVE.L	A0,$1D6(A1)
;	MOVE.W	#1,$2000(A0)
;lbC01F08C	MOVEA.L	A1,A2
;	MOVE.L	$1D6(A2),D0
;	BEQ.L	lbC01F0EE
;	MOVEA.L	D0,A1
;	LEA	$24(A2),A0

OneFilter
	LEA	lbW01F0FE(PC),A2
	CLR.W	D3
	MOVE.B	$7F(A0),D4
	EXT.W	D4
	ASL.W	#7,D4
	CLR.W	D0
lbC01F0AC	MOVE.W	(A2)+,D1
	MOVE.W	#$8000,D2
	SUB.W	D1,D2
	MULU.W	#$E666,D2
	SWAP	D2
	LSR.W	#1,D1
	CLR.W	D5
lbC01F0BE	MOVE.B	0(A0,D5.W),D6
	EXT.W	D6
	ASL.W	#7,D6
	SUB.W	D4,D6
	MULS.W	D1,D6
	ASL.L	#2,D6
	SWAP	D6
	ADD.W	D6,D3
	ADD.W	D3,D4
	ROR.W	#7,D4
	MOVE.B	D4,(A1)+
	ROL.W	#7,D4
	MULS.W	D2,D3
	ASL.L	#1,D3
	SWAP	D3
	ADDQ.W	#1,D5
	CMPI.W	#$80,D5
	BCS.S	lbC01F0BE
	ADDQ.W	#1,D0
	CMPI.W	#$40,D0
	BNE.S	lbC01F0AC
lbC01F0EE	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTS

;Synthesis.MSG	dc.b	'Synthesis',0
lbW01F0FE	dc.w	$8000
	dc.w	$7683
	dc.w	$6DBA
	dc.w	$6597
	dc.w	$5E10
	dc.w	$5717
	dc.w	$50A2
	dc.w	$4AA8
	dc.w	$451F
	dc.w	$4000
	dc.w	$3B41
	dc.w	$36DD
	dc.w	$32CB
	dc.w	$2F08
	dc.w	$2B8B
	dc.w	$2851
	dc.w	$2554
	dc.w	$228F
	dc.w	$2000
	dc.w	$1DA0
	dc.w	$1B6E
	dc.w	$1965
	dc.w	$1784
	dc.w	$15C5
	dc.w	$1428
	dc.w	$12AA
	dc.w	$1147
	dc.w	$1000
	dc.w	$ED0
	dc.w	$DB7
	dc.w	$CB2
	dc.w	$BC2
	dc.w	$AE2
	dc.w	$A14
	dc.w	$955
	dc.w	$8A3
	dc.w	$800
	dc.w	$768
	dc.w	$6DB
	dc.w	$659
	dc.w	$5E1
	dc.w	$571
	dc.w	$50A
	dc.w	$4AA
	dc.w	$451
	dc.w	$400
	dc.w	$3B4
	dc.w	$36D
	dc.w	$32C
	dc.w	$2F0
	dc.w	$2B8
	dc.w	$285
	dc.w	$255
	dc.w	$228
	dc.w	$200
	dc.w	$1DA
	dc.w	$1B6
	dc.w	$196
	dc.w	$178
	dc.w	$15C
	dc.w	$142
	dc.w	$12A
	dc.w	$114
	dc.w	$100
SSTech
;	dc.w	IFFTech-SSTech
;	dc.w	SampledSound.MSG-SSTech

;	BRA.L	lbC01F192

;	BRA.L	lbC01F252

	BRA.L	lbC01F276

	BRA.L	lbC01E286

;lbC01F192	MOVEM.L	D1-D7/A1-A6,-(SP)
;	MOVE.L	D0,D2
;	MOVEA.L	A0,A4
;	MOVEQ	#$60,D0
;	MOVE.L	#$10001,D1
;	BSR.L	lbC01FE82			; alloc mem
;	MOVE.L	A0,D0
;	BEQ.L	lbC01F242
;	MOVEA.L	A0,A3
;	MOVE.L	D2,D0
;	MOVEQ	#$60,D1
;	BSR.L	lbC01DF9E			; read file
;	CLR.L	$44(A3)
;	CMP.L	D1,D0
;	BNE.L	lbC01F24A
;	MOVE.L	D2,D0
;	BSR.L	lbC01DF76			; close file
;	CLR.L	D2
;	LEA	$24(A3),A0
;	LEA	$8A(A6),A5
;	MOVEQ	#$3F,D7
;lbC01F1D2	MOVE.L	0(A5),D0
;	BEQ.S	lbC01F202
;	MOVEA.L	D0,A1
;	LEA	SSTECH(PC),A2
;	CMPA.L	0(A1),A2
;	BNE.S	lbC01F202
;	LEA	$24(A1),A2
;	MOVE.L	A0,-(SP)
;	MOVE.L	A2,-(SP)
;	BSR.L	lbC01FE44			; compare string
;	ADDQ.L	#8,SP
;	BNE.S	lbC01F202
;	MOVEA.L	$44(A1),A2
;	MOVE.L	A2,$44(A3)
;	ADDQ.W	#1,$1E(A2)
;	BRA.S	lbC01F240

;lbC01F202	ADDQ.L	#6,A5
;	DBRA	D7,lbC01F1D2
;	MOVEA.L	A0,A1
;	MOVEA.L	A4,A0
;	LEA	ss.MSG(PC),A2
;	BSR.L	lbC01DF04			; copy string
;	MOVE.L	#3,D0
;	BSR.L	lbC01FEDE			; get size + read
;	MOVE.L	A0,D1
;	BNE.S	lbC01F236
;	BSR.L	lbC01DF04			; copy string
;	BSR.L	lbC01FEDE			; get size + read
;	MOVE.L	A0,D1
;	BNE.S	lbC01F236
;	BSET	#6,$56(A6)
;	BRA.S	lbC01F24A

;lbC01F236	MOVE.L	A0,$44(A3)
;	MOVE.W	#1,$1E(A0)
;lbC01F240	MOVEA.L	A3,A0
;lbC01F242	MOVE.L	D2,D0
;	MOVEM.L	(SP)+,D1-D7/A1-A6
;	RTS

;lbC01F24A	MOVEA.L	A3,A0
;	BSR.S	lbC01F252
;	SUBA.L	A0,A0
;	BRA.S	lbC01F242

;lbC01F252	MOVEM.L	D0-D7/A0-A6,-(SP)
;	MOVEA.L	A0,A1
;	MOVE.L	$44(A1),D0
;	BEQ.S	lbC01F26A
;	MOVEA.L	D0,A0
;	SUBQ.W	#1,$1E(A0)
;	BNE.S	lbC01F26A
;	BSR.L	lbC01FEB2			; free mem
;lbC01F26A	MOVEA.L	A1,A0
;	BSR.L	lbC01FEB2			; free mem
;	MOVEM.L	(SP)+,D0-D7/A0-A6
;	RTS

lbC01F276	MOVEA.L	4(A1),A3
	LEA	$3A(A1),A2
	MOVE.B	0(A1),D0
	BEQ.L	lbC01F368
	CMPI.B	#1,D0
	BNE.L	lbC01F35C
	MOVEA.L	$44(A3),A5
	CLR.L	D1
	MOVE.W	2(A1),D1
	CMPI.W	#$80,D1
	BCS.S	lbC01F2AC
	MOVE.L	#$369E990,D0
	DIVU.W	D1,D0
	MOVE.B	5(A5),D2
	BRA.S	lbC01F2EE

lbC01F2AC	DIVU.W	#12,D1
	MOVE.W	D1,D2
	SWAP	D1
	SUBI.W	#10,D2
	NEG.W	D2
	CMP.B	5(A5),D2
	BLE.S	lbC01F2D6
lbC01F2C0	CLR.B	0(A1)
	CLR.L	$1C(A1)
	CMPI.B	#0,1(A1)
	BEQ.L	lbC01F460
	BRA.L	lbC01F368

lbC01F2D6	CMP.B	4(A5),D2
	BLT.S	lbC01F2C0
	ASL.W	#1,D1
	LEA	lbW01EB58(PC),A0
	MOVE.W	#$1AB9,D0
	MULU.W	0(A0,D1.W),D0
	MOVEQ	#15,D1
	LSR.L	D1,D0
lbC01F2EE	MOVE.W	D0,0(A2)
	MOVEQ	#0,D0
	BSET	D2,D0
	MOVE.B	4(A5),D3
	MOVEQ	#0,D1
	BSET	D3,D1
	SUB.L	D1,D0
	MULU.W	0(A5),D0
	LEA	$3E(A5,D0.L),A0
	MOVEQ	#0,D0
	MOVE.W	2(A5),D0
	MOVEQ	#0,D1
	MOVE.W	0(A5),D1
	SUB.W	D0,D1
	ASL.L	D2,D0
	ASL.L	D2,D1
	BSR.L	lbC01E2C0
	CLR.L	4(A2)
	CLR.W	2(A2)
	BTST	#0,10(A1)
	BEQ.S	lbC01F33E
	MOVE.W	#4,2(A2)
	MOVE.L	$4E(A3),D0
	CLR.W	D0
	MOVE.L	D0,4(A2)
lbC01F33E	CLR.W	8(A2)
	MOVE.W	$5E(A3),D0
	SWAP	D0
	CLR.W	D0
	LSR.L	#1,D0
	DIVU.W	$32(A6),D0
	LSR.W	#1,D0
	MOVE.W	D0,10(A2)
	BSR.L	lbC01EA46
	BRA.S	lbC01F368

lbC01F35C	CMPI.B	#2,D0
	BNE.S	lbC01F368
	MOVE.W	#6,2(A2)
lbC01F368	TST.W	10(A2)
	BEQ.S	lbC01F376
	SUBI.W	#1,10(A2)
	BRA.S	lbC01F390

lbC01F376	MOVE.W	8(A2),D0
	MOVE.W	$5C(A3),D1
	MULU.W	$32(A6),D1
	ASL.L	#7,D1
	SWAP	D1
	ADDI.W	#$40,D1
	ADD.W	D1,D0
	MOVE.W	D0,8(A2)
lbC01F390	MOVE.W	8(A2),D0
	LSR.W	#7,D0
	ADDI.W	#$80,D0
	BTST	#8,D0
	BEQ.S	lbC01F3A4
	EORI.W	#$FF,D0
lbC01F3A4	EORI.W	#$80,D0
	EXT.W	D0
	NEG.W	D0
	MOVE.W	D0,12(A2)
	MOVE.W	2(A2),D0
	LEA	0(A3,D0.W),A0
	CLR.L	D1
	MOVE.W	$4A(A0),D1
	SWAP	D1
	MOVE.L	4(A2),D2
	CLR.L	D3
	MOVE.W	$52(A0),D3
	MOVE.W	D3,D0
	LSR.W	#5,D0
	EORI.W	#7,D0
	ANDI.W	#$1F,D3
	ADDI.W	#$21,D3
	MULU.W	$32(A6),D3
	ASL.L	#3,D3
	LSR.L	D0,D3
	MOVE.L	D1,D0
	SUB.L	D2,D0
	BPL.S	lbC01F3EA
	NEG.L	D0
lbC01F3EA	CMP.L	D3,D0
	BGT.S	lbC01F400
	MOVE.L	D1,D2
	CMPI.W	#4,2(A2)
	BGE.S	lbC01F40A
	ADDI.W	#2,2(A2)
	BRA.S	lbC01F40A

lbC01F400	CMP.L	D1,D2
	BLT.S	lbC01F408
	SUB.L	D3,D2
	BRA.S	lbC01F40A

lbC01F408	ADD.L	D3,D2
lbC01F40A	MOVE.L	D2,4(A2)
	BNE.S	lbC01F414
	CLR.L	$1C(A1)
lbC01F414	MOVE.W	0(A2),D0
	MOVE.W	12(A2),D1
	MOVE.W	$5A(A3),D2
	MULS.W	D2,D1
	ASR.W	#7,D1
	MOVE.W	2(A6),D2
	SUBI.W	#$80,D2
	SUB.W	D2,D1
	ADDI.W	#$1000,D1
	MULU.W	D1,D0
	MOVEQ	#$10,D1
	LSR.L	D1,D0
	BSR.L	lbC01E328
	MOVE.W	D0,$18(A1)
	BSR.L	lbC01E35C
	BSR.L	lbC01E308
	ADDQ.W	#1,D0
	MULU.W	$48(A3),D0
	LSR.W	#8,D0
	MOVE.L	4(A2),D1
	SWAP	D1
	MULU.W	D1,D0
	MOVEQ	#10,D1
	LSR.W	D1,D0
	MOVE.W	D0,$1A(A1)
lbC01F460	RTS

;SampledSound.MSG
;	dc.b	'SampledSound',0
;ss.MSG	dc.b	'.ss',0,0
IFFTech
;	dc.w	AIFFTech-IFFTech
;	dc.w	FORM.MSG-IFFTech

;	BRA.L	lbC01F488

;	BRA.L	lbC01F5EA

	BRA.L	lbC01F604

	BRA.L	lbC01E286

InstallIFF
;lbC01F488	CMPI.L	#'AIFF',$47A(A6)
;	BEQ.L	lbC01F73E
	MOVEM.L	D0-D7/A1-A6,-(SP)
;	LEA	$472(A6),A5
;	MOVEQ	#$20,D5
;	MOVE.L	D0,D2
;	MOVEA.L	SP,A4
;	MOVEQ	#$3E,D0
;	MOVE.L	#$10001,D1
;	BSR.L	lbC01FE82			; alloc mem
;	MOVE.L	A0,D0
;	BEQ.L	lbC01F59A
;	MOVEA.L	A0,A3
;	BSR.L	lbC01F5AC
;	CMPI.L	#'FORM',D0
;	BNE.L	lbC01F5A0
;	BSR.L	lbC01F5AC
;	MOVE.L	D0,D7
;	BSR.L	lbC01F5AC
;	CMPI.L	#'8SVX',D0
;	BNE.L	lbC01F5A0
;	SUBQ.L	#4,D7
;lbC01F4DA	TST.L	D7
;	BLE.L	lbC01F55A
;	BSR.L	lbC01F5AC
;	MOVE.L	D0,D1
;	BSR.L	lbC01F5AC
;	MOVE.L	D0,D6
;	SUBQ.L	#8,D7
;	CMPI.L	#'VHDR',D1
;	BEQ.L	lbC01F510
;	CMPI.L	#'BODY',D1
;	BEQ.L	lbC01F528
;lbC01F502	TST.L	D6
;	BLE.S	lbC01F4DA
;	BSR.L	lbC01F5B8
;	SUBQ.L	#2,D6
;	SUBQ.L	#2,D7
;	BRA.S	lbC01F502

;lbC01F510	LEA	$24(A3),A0
;	MOVEQ	#$14,D0
;	BSR.L	lbC01F5C4
;	TST.B	15(A0)
;	BNE.L	lbC01F5A0
;	SUB.L	D0,D6
;	SUB.L	D0,D7
;	BRA.S	lbC01F502

;lbC01F528	TST.L	$3A(A3)
;	BNE.L	lbC01F5A0
;	TST.B	$32(A3)
;	BEQ.L	lbC01F5A0
;	MOVE.L	D6,D0
;	ADDQ.L	#1,D0
;	ANDI.W	#$FFFE,D0
;	MOVE.L	#3,D1
;	BSR.L	lbC01FE82			;alloc mem
;	MOVE.L	A0,$3A(A3)
;	BEQ.L	lbC01F5A0
;	BSR.L	lbC01F5C4
;	SUB.L	D0,D7
;	BRA.S	lbC01F4DA

;lbC01F55A	TST.L	$3A(A3)
;	BEQ.L	lbC01F5A0

	lea	20(A0),A1
	move.l	D5,A3

	LEA	$24(A3),A0

	move.l	A0,A2
	moveq	#4,D0
CopyVHDR
	move.l	(A1)+,(A2)+
	dbf	D0,CopyVHDR
FindBody
	cmp.l	#'BODY',(A1)
	beq.b	BodyOK
	addq.l	#2,A1
	bra.b	FindBody
BodyOK
	addq.l	#8,A1
	move.l	A1,$3A(A3)

	MOVE.L	(A0)+,D2
	MOVE.L	(A0)+,D3
	MOVE.L	(A0)+,D4
	CLR.W	D1
lbC01F56E	LSR.L	#1,D2
	LSR.L	#1,D3
	LSR.L	#1,D4
	ADDQ.W	#1,D1
	MOVE.L	D2,D0
	OR.L	D3,D0
	BTST	#0,D0
	BNE.S	lbC01F594
	CMPI.L	#1,D4
	BEQ.S	lbC01F594
	MOVE.B	D1,D0
	ADD.B	$32(A3),D0
	CMPI.B	#8,D0
	BLT.S	lbC01F56E
lbC01F594	MOVE.W	D1,$38(A3)
;	MOVEA.L	A3,A0
lbC01F59A	MOVEM.L	(SP)+,D0-D7/A1-A6
	RTS

;lbC01F5A0	MOVEA.L	A4,SP
;	MOVEA.L	A3,A0
;	BSR.L	lbC01F5EA
;	SUBA.L	A0,A0
;	BRA.S	lbC01F59A

;lbC01F5AC	SUBQ.L	#4,SP
;	MOVEA.L	SP,A0
;	MOVEQ	#4,D0
;	BSR.S	lbC01F5C4
;	MOVE.L	(SP)+,D0
;	RTS

;lbC01F5B8	SUBQ.L	#2,SP
;	MOVEA.L	SP,A0
;	MOVEQ	#2,D0
;	BSR.S	lbC01F5C4
;	MOVE.W	(SP)+,D0
;	RTS

;lbC01F5C4	MOVEM.L	D0/D1/A0,-(SP)
;lbC01F5C8	TST.L	D0
;	BEQ.S	lbC01F5E4
;	TST.W	D5
;	BEQ.S	lbC01F5D8
;	MOVE.W	(A5)+,(A0)+
;	SUBQ.W	#2,D5
;	SUBQ.L	#2,D0
;	BRA.S	lbC01F5C8

;lbC01F5D8	MOVE.L	D0,D1
;	MOVE.L	D2,D0
;	BSR.L	lbC01DF9E			; read file
;	CMP.L	D1,D0
;	BNE.S	lbC01F5A0
;lbC01F5E4	MOVEM.L	(SP)+,D0/D1/A0
;	RTS

;lbC01F5EA	MOVEM.L	D0-D7/A0-A6,-(SP)
;	MOVEA.L	A0,A1
;	MOVEA.L	$3A(A1),A0
;	BSR.L	lbC01FEB2			; free mem
;	MOVEA.L	A1,A0
;	BSR.L	lbC01FEB2			; free mem
;	MOVEM.L	(SP)+,D0-D7/A0-A6
;	RTS

lbC01F604	MOVEA.L	4(A1),A3
	LEA	$48(A1),A2
	MOVE.B	0(A1),D0
	BEQ.L	lbC01F6B4
	CMPI.B	#1,D0
	BNE.L	lbC01F6A6
	CLR.L	D1
	MOVE.W	2(A1),D1
	CMPI.W	#$80,D1
	BCS.S	lbC01F638
	MOVE.L	#$369E99,D0
	DIVU.W	D1,D0
	MOVE.B	$32(A3),D2
	SUBQ.B	#1,D2
	BRA.S	lbC01F67A

lbC01F638	DIVU.W	#12,D1
	MOVE.W	D1,D2
	SWAP	D1
	ASL.W	#1,D1
	LEA	lbW01EB58(PC),A0
	MOVE.W	#$1AC,D0
	MULU.W	0(A0,D1.W),D0
	ADD.L	D0,D0
	SWAP	D0
	SUBI.W	#10,D2
	NEG.W	D2
	SUB.W	$38(A3),D2
	BPL.S	lbC01F674
lbC01F65E	CLR.B	0(A1)
	CLR.L	$1C(A1)
	CMPI.B	#0,1(A1)
	BEQ.L	lbC01F6EC
	BRA.L	lbC01F6B4

lbC01F674	CMP.B	$32(A3),D2
	BGE.S	lbC01F65E
lbC01F67A	MOVE.W	D0,0(A2)
	MOVEA.L	$3A(A3),A0
	MOVE.L	$24(A3),D0
	MOVE.L	$28(A3),D1
	SUBA.L	D0,A0
	SUBA.L	D1,A0
	ASL.L	D2,D0
	ASL.L	D2,D1
	ADDA.L	D0,A0
	ADDA.L	D1,A0
	BSR.L	lbC01E2C0
	MOVE.W	#1,2(A2)
	BSR.L	lbC01EA46
	BRA.S	lbC01F6B4

lbC01F6A6	CMPI.B	#2,D0
	BNE.S	lbC01F6B4
	CLR.W	2(A2)
	CLR.L	$1C(A1)
lbC01F6B4	MOVE.W	#$1080,D0
	SUB.W	2(A6),D0
	MULU.W	0(A2),D0
	ASL.L	#4,D0
	SWAP	D0
	BSR.L	lbC01E328
	MOVE.W	D0,$18(A1)
	BSR.L	lbC01E35C
	MOVE.W	2(A2),D0
	BEQ.S	lbC01F6E8
	BSR.L	lbC01E308
	ADDQ.W	#1,D0
	MOVE.L	$34(A3),D1
	LSR.L	#1,D1
	MULU.W	D1,D0
	SWAP	D0
	LSR.W	#1,D0
lbC01F6E8	MOVE.W	D0,$1A(A1)
lbC01F6EC	RTS

;FORM.MSG	dc.b	'FORM',0,0
AIFFTech
;	dc.w	0
;	dc.w	LIST.MSG-AIFFTech

;	BRA.L	lbC01F73E

;	BRA.L	lbC01F92A

	BRA.L	lbC01F944

	BRA.L	lbC01E286

lbC01F708	MOVE.L	D1,-(SP)
	CMPI.L	#4,4(A0)
	BLE.S	lbC01F722
lbC01F714	CMP.L	(A1),D0
	BEQ.S	lbC01F71E
	BSR.S	lbC01F726
	MOVE.L	A1,D1
	BNE.S	lbC01F714
lbC01F71E	MOVE.L	(SP)+,D1
	RTS

lbC01F722	SUBA.L	A1,A1
	BRA.S	lbC01F71E

lbC01F726	MOVE.L	D0,-(SP)
	ADDA.L	4(A1),A1
	MOVE.L	A1,D0
	ADDQ.L	#8,A1
	SUB.L	A0,D0
	CMP.L	4(A0),D0
	BCS.S	lbC01F73A
	SUBA.L	A1,A1
lbC01F73A	MOVE.L	(SP)+,D0
	RTS

InstallAIFF
;lbC01F73E	MOVEM.L	D1-D7/A1-A3/A5/A6,-(SP)
;	MOVE.L	#2,D1
;	BSR.L	lbC01FEF6
;	MOVEA.L	A0,A5
;	MOVE.L	A0,D0
;	BEQ.L	lbC01F7D2
;	MOVEQ	#$2C,D0
;	MOVE.L	#$10000,D1
;	BSR.L	lbC01FE82				;alloc mem
;	MOVEA.L	A0,A4
;	MOVE.L	A0,D0
;	BEQ.L	lbC01F7D2

	movem.l	D1-A6,-(SP)
	move.l	A0,A5
	move.l	D5,A4

	MOVE.L	A5,$24(A4)				; sample address
	CMPI.L	#'AIFF',8(A5)
	BNE.L	lbC01F7D2
	SUBA.L	A2,A2
	MOVE.L	(A5),D0
	CMPI.L	#'FORM',D0
	BEQ.S	lbC01F7B4
	MOVEA.L	A5,A0
	LEA	12(A0),A1
lbC01F78A	MOVE.L	#'FORM',D0
	BSR.L	lbC01F708
	MOVE.L	A1,D0
	BEQ.S	lbC01F7BE
	CMPI.L	#'AIFF',8(A1)
	BNE.S	lbC01F7D2
	BSR.L	lbC01F7E8
	TST.L	D0
	BNE.S	lbC01F7D2
	BSR.L	lbC01F726
	MOVE.L	A1,D0
	BEQ.S	lbC01F7BE
	BRA.S	lbC01F78A

lbC01F7B4	MOVEA.L	A5,A1
	BSR.L	lbC01F7E8
	TST.L	D0
	BNE.S	lbC01F7D2
lbC01F7BE
	TST.L	$28(A4)
	BEQ.S	lbC01F7D2
;	MOVEA.L	A4,A0
;lbC01F7C6	LEA	AIFFTech(PC),A4
;	CLR.L	D0
;	MOVEM.L	(SP)+,D1-D7/A1-A3/A5/A6

	moveq	#0,D0
exit	movem.l	(SP)+,D1-A6

	RTS

lbC01F7D2
	moveq	#-1,D0
	bra.b	exit

;	MOVE.L	A4,D0
;	BEQ.S	lbC01F7DE
;	MOVEA.L	D0,A0
;	BSR.L	lbC01F92A
;	BRA.S	lbC01F7E4

;lbC01F7DE	MOVEA.L	A5,A0
;	BSR.L	lbC01FEB2			; free mem
;lbC01F7E4	SUBA.L	A0,A0
;	BRA.S	lbC01F7C6

lbC01F7E8	MOVEM.L	D1-D7/A0/A1/A3-A5,-(SP)
	MOVEA.L	A1,A0
	LEA	12(A0),A1
	MOVE.L	#'COMM',D0
	BSR.L	lbC01F708
	MOVE.L	A1,D0
	BEQ.L	lbC01F8CA
	MOVEA.L	A1,A5
	LEA	12(A0),A1
	MOVE.L	#'SSND',D0
	BSR.L	lbC01F708
	MOVE.L	A1,D0
	BEQ.L	lbC01F8CA
	MOVE.L	A2,D0
	BNE.S	lbC01F822
	MOVE.L	A1,$28(A4)
	BRA.S	lbC01F826

lbC01F822	MOVE.L	A1,0(A2)
lbC01F826	MOVEA.L	A1,A2
	CLR.L	0(A2)
	MOVE.W	#$400E,D0
	SUB.W	$10(A5),D0
	MOVE.W	$12(A5),D1
	LSR.W	D0,D1
	MOVE.W	D1,12(A2)
	MOVE.L	10(A5),D0
	LSR.L	#1,D0
	MOVE.W	D0,14(A2)
	CLR.W	8(A2)
	CLR.W	10(A2)
	LEA	12(A0),A1
	MOVE.L	#'NAME',D0
	BSR.L	lbC01F708
	MOVE.L	A1,D0
	BEQ.S	lbC01F874
	ADDQ.L	#8,A1
	BSR.L	lbC01F902
	MOVE.W	D0,8(A2)
	BSR.L	lbC01F902
	MOVE.W	D0,10(A2)
lbC01F874	LEA	12(A0),A1
	MOVE.L	#'INST',D0
	BSR.L	lbC01F708
	MOVE.L	A1,4(A2)
	BEQ.S	lbC01F8C2
	MOVEA.L	A1,A3
	TST.W	$10(A3)
	BEQ.S	lbC01F8C2
	LEA	12(A0),A1
	MOVE.L	#'MARK',D0
	BSR.L	lbC01F708
	MOVE.L	A1,D0
	BEQ.S	lbC01F8CA
	MOVE.W	$12(A3),D0
	BSR.L	lbC01F8CE
	ASR.L	#1,D0
	BMI.S	lbC01F8CA
	MOVE.W	D0,$12(A3)
	MOVE.W	$14(A3),D0
	BSR.L	lbC01F8CE
	ASR.L	#1,D0
	BMI.S	lbC01F8CA
	MOVE.W	D0,$14(A3)
lbC01F8C2	MOVEQ	#0,D0
lbC01F8C4	MOVEM.L	(SP)+,D1-D7/A0/A1/A3-A5
	RTS

lbC01F8CA	MOVEQ	#-1,D0
	BRA.S	lbC01F8C4

lbC01F8CE	MOVEM.L	D1/D7/A1,-(SP)
	MOVE.W	8(A1),D7
	ADDA.W	#10,A1
lbC01F8DA	SUBQ.W	#1,D7
	BMI.S	lbC01F8FA
	CMP.W	0(A1),D0
	BNE.S	lbC01F8EA
	MOVE.L	2(A1),D0
	BRA.S	lbC01F8FC

lbC01F8EA	ADDA.W	#6,A1
	MOVE.B	(A1),D1
	ADDQ.B	#2,D1
	ANDI.W	#$FE,D1
	ADDA.W	D1,A1
	BRA.S	lbC01F8DA

lbC01F8FA	MOVEQ	#-1,D0
lbC01F8FC	MOVEM.L	(SP)+,D1/D7/A1
	RTS

lbC01F902	MOVE.L	D1,-(SP)
lbC01F904	CMPI.B	#$20,(A1)+
	BEQ.S	lbC01F904
	SUBQ.L	#1,A1
	CLR.W	D0
lbC01F90E	CLR.W	D1
	MOVE.B	(A1),D1
	SUBI.B	#$30,D1
	CMPI.B	#10,D1
	BCC.S	lbC01F926
	MULU.W	#10,D0
	ADD.W	D1,D0
	ADDQ.L	#1,A1
	BRA.S	lbC01F90E

lbC01F926	MOVE.L	(SP)+,D1
	RTS

;lbC01F92A	MOVEM.L	D0-D7/A0-A6,-(SP)
;	MOVEA.L	A0,A1
;	MOVEA.L	$24(A1),A0
;	BSR.L	lbC01FEB2			; free mem
;	MOVEA.L	A1,A0
;	BSR.L	lbC01FEB2			; free mem
;	MOVEM.L	(SP)+,D0-D7/A0-A6
;	RTS

lbC01F944	MOVEA.L	4(A1),A3
	LEA	$4C(A1),A2
	MOVE.B	0(A1),D0
	BEQ.L	lbC01FA6A
	CMPI.B	#1,D0
	BNE.L	lbC01FA60
	MOVEA.L	$28(A3),A5
lbC01F960	MOVEA.L	4(A5),A4
	MOVE.W	12(A5),D0
	MOVE.W	2(A1),D1
	BEQ.L	lbC01F9E4
	CMPI.W	#$80,D1
	BCC.L	lbC01F9E6
	MOVE.L	A4,D2
	BNE.S	lbC01F982
	SUBI.B	#$3C,D1
	BRA.S	lbC01F9B0

lbC01F982	CMP.B	11(A4),D1
	BHI.S	lbC01F98E
	CMP.B	10(A4),D1
	BCC.S	lbC01F9AC
lbC01F98E	MOVEA.L	0(A5),A5
	MOVE.L	A5,D2
	BNE.S	lbC01F960
lbC01F996	CLR.B	0(A1)
	CLR.L	$1C(A1)
	CMPI.B	#0,1(A1)
	BEQ.L	lbC01FAEA
	BRA.L	lbC01FA6A

lbC01F9AC	SUB.B	8(A4),D1
lbC01F9B0	BEQ.S	lbC01F9E4
	BPL.S	lbC01F9BE
lbC01F9B4	LSR.W	#1,D0
	ADDI.B	#12,D1
	BMI.S	lbC01F9B4
	BRA.S	lbC01F9CE

lbC01F9BE	CMPI.B	#12,D1
	BLT.S	lbC01F9CE
	ADD.W	D0,D0
	BCS.S	lbC01F996
	SUBI.B	#12,D1
	BRA.S	lbC01F9BE

lbC01F9CE	EXT.W	D1
	BEQ.S	lbC01F9E4
	ADD.W	D1,D1
	SWAP	D0
	CLR.W	D0
	LSR.L	#1,D0
	LEA	lbW01EB58(PC),A0
	DIVU.W	0(A0,D1.W),D0
	BVS.S	lbC01F996
lbC01F9E4	MOVE.W	D0,D1
lbC01F9E6	TST.W	D1
	BEQ.S	lbC01F996
	MOVE.L	#$369E99,D0
	DIVU.W	D1,D0
	MOVE.W	D0,0(A2)
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVE.W	14(A5),D0
	MOVE.L	A4,D2
	BEQ.S	lbC01FA12
	TST.W	$10(A4)
	BEQ.S	lbC01FA12
	MOVE.W	$12(A4),D0
	MOVE.W	$14(A4),D1
	SUB.W	D0,D1
lbC01FA12	ADD.L	D0,D0
	ADD.L	D1,D1
	LEA	$10(A5),A0
	BSR.L	lbC01E2C0
	CLR.W	D0
	BTST	#0,10(A1)
	BEQ.S	lbC01FA2C
	MOVE.W	#$FF00,D0
lbC01FA2C	MOVE.W	D0,2(A2)
	MOVE.W	8(A5),D1
	ADDQ.W	#1,D1
	MOVE.L	#$FF00,D0
	DIVU.W	D1,D0
	MOVE.W	D0,4(A2)
	MOVE.W	10(A5),D1
	ADDQ.W	#1,D1
	MOVE.L	#$FF00,D0
	DIVU.W	D1,D0
	MOVE.W	D0,6(A2)
	MOVE.B	#$FF,10(A1)
	BSR.L	lbC01EA46
	BRA.S	lbC01FA6A

lbC01FA60	CMPI.B	#2,D0
	BNE.S	lbC01FA6A
	CLR.B	10(A1)
lbC01FA6A	MOVE.W	#$1080,D0
	SUB.W	2(A6),D0
	MULU.W	0(A2),D0
	ASL.L	#4,D0
	SWAP	D0
	BSR.L	lbC01E328
	MOVE.W	D0,$18(A1)
	BSR.L	lbC01E35C
	MOVE.W	2(A2),D1
	TST.B	10(A1)
	BEQ.S	lbC01FAB2
	MOVE.W	#$FF00,D2
	CMP.W	D1,D2
	BEQ.S	lbC01FAD6
	MOVE.W	4(A2),D0
	MULU.W	$32(A6),D0
	ADD.L	D0,D0
	BCS.S	lbC01FACC
	SWAP	D0
	ADD.W	D0,D1
	BCS.S	lbC01FACC
	CMP.W	D2,D1
	BCC.S	lbC01FACC
	MOVE.W	D1,D2
	BRA.S	lbC01FACC

lbC01FAB2	CLR.W	D2
	TST.W	D1
	BEQ.S	lbC01FACC
	MOVE.W	6(A2),D0
	MULU.W	$32(A6),D0
	ADD.L	D0,D0
	BCS.S	lbC01FACC
	SWAP	D0
	SUB.W	D0,D1
	BCS.S	lbC01FACC
	MOVE.W	D1,D2
lbC01FACC	MOVE.W	D2,2(A2)
	BNE.S	lbC01FAD6
	CLR.L	$1C(A1)
lbC01FAD6	BSR.L	lbC01E308
	ADDQ.W	#1,D0
	MULU.W	2(A2),D0
	SWAP	D0
	ADDQ.W	#1,D0
	LSR.W	#2,D0
	MOVE.W	D0,$1A(A1)
lbC01FAEA	RTS

;LIST.MSG	dc.b	'LIST'
;	dc.w	0
;	dc.w	$880F
;	dc.w	$FC0C
;	dc.w	$F3F5
;	dc.w	$3544
;COPYRIGHT	dc.b	'Sonix Music Driver (C) Copyright 1987-91 Mar'
;	dc.b	'k Riley, All Rights Reserved.',0
;VERSION	dc.b	'Version 2.3c - January 9, 1991',0,0

;INITSONIX	MOVEM.L	D1-D7/A0-A6,-(SP)
;	LEA	SONIX(PC),A1
;	MOVE.L	(A1),D0
;	BNE.L	lbC01FCDC
;	MOVE.L	#$538,D0
;	MOVE.L	#$10001,D1
;	BSR.L	lbC01FE82			;alloc mem
;	MOVEA.L	A0,A6
;	MOVE.L	A0,(A1)
;	BEQ.L	lbC01FCE6
;	MOVE.L	#$408,D0
;	MOVE.L	#$10003,D1
;	BSR.L	lbC01FE82			;alloc mem
;	MOVE.L	A0,$3E2(A6)
;	BEQ.L	lbC01FCE6
;	LEA	doslibrary.MSG(PC),A1
;	MOVEQ	#0,D0
;	MOVE.L	A6,-(SP)
;	MOVEA.L	4,A6
;	JSR	-$228(A6)			; open library
;	MOVEA.L	(SP)+,A6
;	LEA	DOS_Base(PC),A0
;	MOVE.L	D0,(A0)
;	BEQ.L	lbC01FCE6
;	LEA	$4F4(A6),A2
;	MOVE.B	#4,8(A2)
;	MOVE.B	#0,14(A2)
;	MOVEQ	#-1,D0
;	MOVE.L	A6,-(SP)
;	MOVEA.L	4,A6
;	JSR	-$14A(A6)			; alloc signal
;	MOVEA.L	(SP)+,A6
;	MOVE.B	D0,15(A2)
;	SUBA.L	A1,A1
;	MOVE.L	A6,-(SP)
;	MOVEA.L	4,A6
;	JSR	-$126(A6)			; find task
;	MOVEA.L	(SP)+,A6
;	MOVE.L	D0,$10(A2)
;	LEA	$14(A2),A0
;	MOVE.L	A0,0(A0)
;	ADDQ.L	#4,0(A0)
;	CLR.L	4(A0)
;	MOVE.L	A0,8(A0)
;	LEA	$4B0(A6),A1
;	MOVE.B	#5,8(A1)
;	MOVE.L	A2,14(A1)
;	LEA	lbW01FF4A(PC),A0
;	MOVE.L	A0,$22(A1)
;	MOVEQ	#1,D0
;	MOVE.L	D0,$26(A1)
;	MOVE.B	#$7F,9(A1)
;	LEA	audiodevice.MSG(PC),A0
;	MOVEQ	#0,D0
;	MOVEQ	#0,D1
;	MOVE.L	A6,-(SP)
;	MOVEA.L	4,A6
;	JSR	-$1BC(A6)			; open device
;	MOVEA.L	(SP)+,A6
;	TST.L	D0
;	BNE.L	lbC01FCE6
;	LEA	ciabresource.MSG(PC),A1
;	MOVE.L	A6,-(SP)
;	MOVEA.L	4,A6
;	JSR	-$1F2(A6)			; open resource
;	MOVEA.L	(SP)+,A6
;	LEA	Resource_Base(PC),A0
;	MOVE.L	D0,(A0)
;	BEQ.L	lbC01FCE6
;	LEA	$516(A6),A2
;	LEA	$BFD400,A3
;	LEA	$BFDE00,A4
;	MOVEQ	#0,D7
;lbC01FC6E	LEA	INTERRUPT(PC),A0
;	MOVE.L	A0,$12(A2)
;	MOVEA.L	A2,A1
;	MOVE.L	D7,D0
;	MOVE.L	A6,-(SP)
;	MOVEA.L	Resource_Base(PC),A6
;	JSR	-6(A6)				; add ICR vector
;	MOVEA.L	(SP)+,A6
;	MOVE.L	D0,14(A2)
;	BEQ.S	lbC01FCA2
;	TST.L	D7
;	BNE.L	lbC01FCE6
;	LEA	$BFD600,A3
;	LEA	$BFDF00,A4
;	MOVEQ	#1,D7
;	BRA.S	lbC01FC6E

;lbC01FCA2	MOVE.L	A3,$52C(A6)
;	MOVE.L	A4,$530(A6)
;	MOVE.L	D7,$534(A6)
;	MOVE.W	#$80,2(A6)
;	MOVEQ	#$78,D0
;	MOVE.W	D0,0(A6)
;	BSR.L	lbC01E798
;	CLR.W	D0
;	MOVE.B	#$FF,D1
;	MOVE.B	#$FF,D2
;	BSR.L	RAMPVOLUME
;	MOVE.B	#$81,D0
;	MOVE.L	A6,-(SP)
;	MOVEA.L	Resource_Base(PC),A6
;	JSR	-$12(A6)			; able ICR
;	MOVEA.L	(SP)+,A6
;lbC01FCDC	MOVE.L	SONIX(PC),D0
;	MOVEM.L	(SP)+,D1-D7/A0-A6
;	RTS

;lbC01FCE6	BSR.S	lbC01FD0A
;	BRA.S	lbC01FCDC

;QUITSONIX	MOVEM.L	D0-D7/A0-A6,-(SP)
;	MOVE.L	SONIX(PC),D0
;	BEQ.S	lbC01FD04
;	MOVEA.L	D0,A6
;	BSR.L	STOPSOUND
;	BSR.L	lbC01E508
;	BSR.L	lbC01E0D8
;	BSR.S	lbC01FD0A
;lbC01FD04	MOVEM.L	(SP)+,D0-D7/A0-A6
;	RTS

; remove player routine

;lbC01FD0A	MOVEM.L	D0-D7/A0-A6,-(SP)
;	LEA	SONIX(PC),A1
;	MOVE.L	(A1),D0
;	BEQ.L	lbC01FDC4
;	MOVEA.L	D0,A6
;	CLR.L	(A1)
;	LEA	Resource_Base(PC),A3
;	TST.L	(A3)
;	BEQ.S	lbC01FD56
;	LEA	$516(A6),A2
;	TST.L	14(A2)
;	BNE.S	lbC01FD56
;	MOVE.B	#1,D0
;	MOVE.L	A6,-(SP)
;	MOVEA.L	Resource_Base(PC),A6
;	JSR	-$12(A6)			; able ICR
;	MOVEA.L	(SP)+,A6
;	MOVEA.L	$530(A6),A0
;	CLR.B	(A0)
;	MOVE.L	$534(A6),D0
;	MOVEA.L	A2,A1
;	MOVE.L	A6,-(SP)
;	MOVEA.L	Resource_Base(PC),A6
;	JSR	-12(A6)				; rem ICR vector
;	MOVEA.L	(SP)+,A6
;lbC01FD56	CLR.L	(A3)
;	LEA	$4B0(A6),A2
;	SUBA.L	A1,A1
;	MOVE.L	A6,-(SP)
;	MOVEA.L	4,A6
;	JSR	-$126(A6)			; find task
;	MOVEA.L	(SP)+,A6
;	MOVE.L	D0,$10(A2)
;	MOVE.L	$14(A2),D0
;	BEQ.S	lbC01FD86
;	ADDQ.L	#1,D0
;	BEQ.S	lbC01FD86
;	MOVEA.L	A2,A1
;	MOVE.L	A6,-(SP)
;	MOVEA.L	4,A6
;	JSR	-$1C2(A6)			; close device
;	MOVEA.L	(SP)+,A6
;lbC01FD86	LEA	$4F4(A6),A2
;	CLR.L	D0
;	MOVE.B	15(A2),D0
;	BEQ.S	lbC01FD9E
;	MOVE.L	A6,-(SP)
;	MOVEA.L	4,A6
;	JSR	-$150(A6)			; free signal
;	MOVEA.L	(SP)+,A6
;lbC01FD9E	LEA	DOS_Base(PC),A2
;	MOVE.L	(A2),D0
;	BEQ.S	lbC01FDB4
;	MOVEA.L	D0,A1
;	MOVE.L	A6,-(SP)
;	MOVEA.L	4,A6
;	JSR	-$19E(A6)			; close library
;	MOVEA.L	(SP)+,A6
;lbC01FDB4	CLR.L	(A2)
;	MOVEA.L	$3E2(A6),A0
;	BSR.L	lbC01FEB2
;	MOVEA.L	A6,A0
;	BSR.L	lbC01FEB2
;lbC01FDC4	MOVEM.L	(SP)+,D0-D7/A0-A6
;	RTS

;lbC01FDCA	MOVEM.L	D1/D2/A0/A1,-(SP)
;	MOVE.L	D1,-(SP)
;	MOVE.L	D0,-(SP)
;	MOVEQ	#-1,D0
;	MOVE.L	A6,-(SP)
;	MOVEA.L	4,A6
;	JSR	-$14A(A6)			; alloc signal
;	MOVEA.L	(SP)+,A6
;	MOVE.L	D0,D2
;	MOVE.L	(SP)+,D0
;	CLR.L	D1
;	BSET	D2,D1
;	BSR.S	lbC01FE18
;	MOVE.L	D1,D0
;	OR.L	(SP),D0
;	MOVE.L	A6,-(SP)
;	MOVEA.L	4,A6
;	JSR	-$13E(A6)			; wait
;	MOVEA.L	(SP)+,A6
;	AND.L	(SP)+,D0
;	MOVE.L	D0,-(SP)
;	CLR.L	D1
;	BSR.S	lbC01FE18
;	MOVE.L	D2,D0
;	MOVE.L	A6,-(SP)
;	MOVEA.L	4,A6
;	JSR	-$150(A6)			; free signal
;	MOVEA.L	(SP)+,A6
;	MOVE.L	(SP)+,D0
;	MOVEM.L	(SP)+,D1/D2/A0/A1
;	RTS

;lbC01FE18	MOVEM.L	D0-D2/A0/A1,-(SP)
;	CLR.L	$4A4(A6)
;	MOVE.L	D1,D2
;	BEQ.S	lbC01FE3E
;	MOVE.L	D0,$4A8(A6)
;	SUBA.L	A1,A1
;	MOVE.L	A6,-(SP)
;	MOVEA.L	4,A6
;	JSR	-$126(A6)			; find task
;	MOVEA.L	(SP)+,A6
;	MOVE.L	D0,$4A0(A6)
;	MOVE.L	D2,$4A4(A6)
;lbC01FE3E	MOVEM.L	(SP)+,D0-D2/A0/A1
;	RTS

; compare string routine

;lbC01FE44	MOVEM.L	D0/D1/A0/A1,-(SP)
;	MOVEA.L	$18(SP),A0
;	MOVEA.L	$14(SP),A1
;lbC01FE50	MOVE.B	(A0)+,D0
;	CMPI.B	#$61,D0
;	BCS.S	lbC01FE62
;	CMPI.B	#$7B,D0
;	BCC.S	lbC01FE62
;	ANDI.B	#$DF,D0
;lbC01FE62	MOVE.B	(A1)+,D1
;	CMPI.B	#$61,D1
;	BCS.S	lbC01FE74
;	CMPI.B	#$7B,D1
;	BCC.S	lbC01FE74
;	ANDI.B	#$DF,D1
;lbC01FE74	CMP.B	D0,D1
;	BNE.S	lbC01FE7C
;	TST.B	D0
;	BNE.S	lbC01FE50
;lbC01FE7C	MOVEM.L	(SP)+,D0/D1/A0/A1
;	RTS

; alloc memory routine

;lbC01FE82	MOVEM.L	D0-D3/A1/A6,-(SP)
;	ADDQ.L	#4,D0
;	MOVE.L	D0,D2
;	MOVE.L	lbL01DEFC(PC),D3
;	BNE.S	lbC01FEAC
;	MOVE.L	D2,D0
;	MOVE.L	A6,-(SP)
;	MOVEA.L	4,A6
;	JSR	-$C6(A6)			; alloc mem
;	MOVEA.L	(SP)+,A6
;lbC01FE9E	MOVEA.L	D0,A0
;	TST.L	D0
;	BEQ.S	lbC01FEA6
;	MOVE.L	D2,(A0)+
;lbC01FEA6	MOVEM.L	(SP)+,D0-D3/A1/A6
;	RTS

;lbC01FEAC	MOVEA.L	D3,A0
;	JSR	(A0)
;	BRA.S	lbC01FE9E

; free memory routine

;lbC01FEB2	MOVEM.L	D0/D1/A0/A1,-(SP)
;	MOVE.L	A0,D0
;	BEQ.S	lbC01FED2
;	SUBQ.L	#4,A0
;	MOVE.L	lbL01DF00(PC),D1
;	BNE.S	lbC01FED8
;	MOVEA.L	A0,A1
;	MOVE.L	(A1),D0
;	MOVE.L	A6,-(SP)
;	MOVEA.L	4,A6
;	JSR	-$D2(A6)			; free mem
;	MOVEA.L	(SP)+,A6
;lbC01FED2	MOVEM.L	(SP)+,D0/D1/A0/A1
;	RTS

;lbC01FED8	MOVEA.L	D1,A1
;	JSR	(A1)
;	BRA.S	lbC01FED2

;lbC01FEDE	MOVEM.L	D0/D1,-(SP)
;	MOVE.L	D0,D1
;	MOVE.L	#$3ED,D0
;	BSR.L	lbC01DF4C			; open file
;	BSR.S	lbC01FEF6
;	MOVEM.L	(SP)+,D0/D1
;	RTS

;lbC01FEF6	MOVEM.L	D0-D3/D5-D7,-(SP)
;	CLR.L	D5
;	MOVE.L	D0,D7
;	BEQ.S	lbC01FF36
;	MOVE.L	D1,D6
;	MOVE.L	D7,D1
;	MOVEQ	#0,D2
;	MOVEQ	#1,D3
;	BSR.L	lbC01DFCA			; seek file
;	MOVEQ	#-1,D3
;	BSR.L	lbC01DFCA			; seek file
;	TST.L	D0
;	BMI.S	lbC01FF30
;	MOVE.L	D6,D1
;	BSR.L	lbC01FE82			; alloc mem
;	MOVE.L	A0,D5
;	BEQ.S	lbC01FF30
;	MOVE.L	D0,D1
;	MOVE.L	D7,D0
;	BSR.L	lbC01DF9E			; read file
;	CMP.L	D1,D0
;	BEQ.S	lbC01FF30
;	BSR.S	lbC01FEB2			; free mem
;	CLR.L	D5
;lbC01FF30	MOVE.L	D7,D0
;	BSR.L	lbC01DF76			; close file
;lbC01FF36	MOVEA.L	D5,A0
;	MOVEM.L	(SP)+,D0-D3/D5-D7
;	RTS

Sonix
	dc.l	Buffer
;DOS_Base
;	dc.l	0
;Resource_Base
;	dc.l	0
;lbW01FF4A	dc.w	$F0F
;doslibrary.MSG	dc.b	'dos.library',0
;audiodevice.MSG	dc.b	'audio.device',0
;ciabresource.MSG	dc.b	'ciab.resource',0,0

;	JMP	INITSONIX

;	JMP	QUITSONIX

;	MOVE.L	A6,-(SP)
;	MOVEA.L	8(SP),A0
;	MOVE.L	12(SP),D0
;	MOVE.L	$10(SP),D1
;	MOVE.L	$14(SP),D2
;	MOVE.L	$18(SP),D3
;	MOVE.L	$1C(SP),D4
;	MOVEA.L	lbL033A60,A6
;	JSR	PLAYSCORE
;	MOVEA.L	(SP)+,A6
;	RTS

;	MOVE.L	A6,-(SP)
;	MOVE.L	8(SP),D0
;	MOVEA.L	lbL033A60,A6
;	JSR	RELEASESCORE
;	MOVEA.L	(SP)+,A6
;	RTS

;	MOVE.L	A6,-(SP)
;	MOVEA.L	lbL033A60,A6
;	JSR	STOPSCORE
;	MOVEA.L	(SP)+,A6
;	RTS

;	MOVE.L	A6,-(SP)
;	MOVEA.L	8(SP),A0
;	MOVE.L	12(SP),D0
;	MOVE.L	$10(SP),D1
;	MOVE.L	$14(SP),D2
;	MOVE.L	$18(SP),D3
;	MOVEA.L	lbL033A60,A6
;	JSR	STARTNOTE
;	MOVEA.L	(SP)+,A6
;	RTS

;	MOVE.L	A6,-(SP)
;	MOVE.L	8(SP),D0
;	MOVEA.L	lbL033A60,A6
;	JSR	RELEASENOTE
;	MOVEA.L	(SP)+,A6
;	RTS

;	MOVE.L	A6,-(SP)
;	MOVE.L	8(SP),D0
;	MOVEA.L	lbL033A60,A6
;	JSR	STOPNOTE
;	MOVEA.L	(SP)+,A6
;	RTS

;	MOVE.L	A6,-(SP)
;	MOVEA.L	lbL033A60,A6
;	JSR	RELEASESOUND
;	MOVEA.L	(SP)+,A6
;	RTS

;	MOVE.L	A6,-(SP)
;	MOVEA.L	lbL033A60,A6
;	JSR	STOPSOUND
;	MOVEA.L	(SP)+,A6
;	RTS

;	MOVE.L	A6,-(SP)
;	MOVE.L	8(SP),D0
;	MOVE.L	12(SP),D1
;	MOVE.L	$10(SP),D2
;	MOVEA.L	lbL033A60,A6
;	JSR	RAMPVOLUME
;	MOVEA.L	(SP)+,A6
;	RTS

;	MOVE.L	A6,-(SP)
;	MOVE.L	8(SP),D0
;	MOVEA.L	lbL033A60,A6
;	JSR	STEALTRACK
;	MOVEA.L	(SP)+,A6
;	RTS

;	MOVE.L	A6,-(SP)
;	MOVE.L	8(SP),D0
;	MOVEA.L	lbL033A60,A6
;	JSR	RESUMETRACK
;	MOVEA.L	(SP)+,A6
;	RTS

;	MOVE.L	A6,-(SP)
;	MOVEA.L	8(SP),A0
;	MOVEA.L	12(SP),A1
;	MOVEA.L	lbL033A60,A6
;	JSR	InitScore
;	MOVEA.L	(SP)+,A6
;	RTS

;	MOVE.L	A6,-(SP)
;	MOVEA.L	8(SP),A0
;	MOVEA.L	lbL033A60,A6
;	JSR	lbC01E51E
;	MOVEA.L	(SP)+,A6
;	RTS

;	MOVE.L	A6,-(SP)
;	MOVEA.L	lbL033A60,A6
;	JSR	lbC01E508
;	MOVEA.L	(SP)+,A6
;	RTS

;	MOVE.L	A6,-(SP)
;	MOVEA.L	8(SP),A0
;	MOVEA.L	12(SP),A1
;	MOVEA.L	lbL033A60,A6
;	JSR	INITINSTRUMENT
;	MOVEA.L	(SP)+,A6
;	RTS

;	MOVE.L	A6,-(SP)
;	MOVEA.L	8(SP),A0
;	MOVEA.L	lbL033A60,A6
;	JSR	lbC01E0F4
;	MOVEA.L	(SP)+,A6
;	RTS

;	MOVE.L	A6,-(SP)
;	MOVEA.L	lbL033A60,A6
;	JSR	lbC01E0D8
;	MOVEA.L	(SP)+,A6
;	RTS

;	MOVE.L	A6,-(SP)
;	MOVE.L	8(SP),D0
;	MOVE.L	12(SP),D1
;	MOVEA.L	lbL033A60,A6
;	JSR	lbC01FE18
;	MOVEA.L	(SP)+,A6
;	RTS

;	MOVE.L	A6,-(SP)
;	MOVE.L	8(SP),D0
;	MOVE.L	12(SP),D1
;	MOVEA.L	lbL033A60,A6
;	JSR	lbC01FDCA
;	MOVEA.L	(SP)+,A6
;	RTS

;	MOVE.L	A6,-(SP)
;	MOVEA.L	8(SP),A0
;	MOVEA.L	lbL033A60,A6
;	JSR	SETFILTER
;	MOVEA.L	(SP)+,A6
;	RTS

;	MOVE.L	A6,-(SP)
;	MOVE.L	8(SP),D0
;	MOVEA.L	lbL033A60,A6
;	JSR	lbC01EA68
;	MOVEA.L	(SP)+,A6
;	RTS

;lbC020176	MOVE.L	A6,-(SP)
;	MOVEA.L	lbL033A60,A6
;	JSR	lbC01E262
;	MOVEA.L	(SP)+,A6
;	RTS

;	MOVE.L	A6,-(SP)
;	MOVE.L	8(SP),D0
;	MOVE.L	12(SP),D1
;	MOVEA.L	lbL033A60,A6
;	JSR	lbC01E388
;	MOVEA.L	(SP)+,A6
;	RTS

;	MOVE.L	A6,-(SP)
;	MOVEA.L	8(SP),A0
;	MOVE.L	12(SP),D0
;	MOVE.L	$10(SP),D1
;	MOVE.L	$14(SP),D2
;	MOVE.L	$18(SP),D3
;	MOVEA.L	lbL033A60,A6
;	JSR	lbC01E246
;	MOVEA.L	(SP)+,A6
;	RTS

;	MOVE.L	A6,-(SP)
;	MOVE.L	8(SP),D0
;	MOVEA.L	lbL033A60,A6
;	JSR	lbC01E270
;	MOVEA.L	(SP)+,A6
;	RTS

;	dc.l	COPYRIGHT
;	dc.l	VERSION


;lbL033A60
;	dc.l	0

***************************************************************************
*************** Sonix Music Driver v2.0b player (TINY format) *************
***************************************************************************

; Player from game "Magic Johnson's Basketball" (c) 1989 by Melbourne House

;SONIXCODE	BRA.L	INTERRUPT

;	BRA.L	INITSONIX

;	BRA.L	QUITSONIX

;	BRA.L	PLAYSCORE

;	BRA.L	RELEASESCORE

;	BRA.L	STOPSCORE

;	BRA.L	STARTNOTE

;	BRA.L	RELEASENOTE

;	BRA.L	STOPNOTE

;	BRA.L	RELEASESOUND

;	BRA.L	STOPSOUND

;	BRA.L	RAMPVOLUME

;	BRA.L	STEALTRACK

;	BRA.L	RESUMETRACK

;	BRA.L	INITINSTRUMENT

;	BRA.L	QUITINSTRUMENT

;	BRA.L	SETFILTER

INITINSTRUMENT	MOVEM.L	D0-D7/A0-A6,-(SP)
	MOVE.L	0(A0),D0
	SUBQ.L	#1,D0
	BEQ.S	lbC00CE6E
	SUBQ.L	#1,D0
	BEQ.S	lbC00CE86
	SUBQ.L	#1,D0
	BEQ.S	lbC00CE90
lbC00CE68	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTS

lbC00CE6E	MOVE.L	A1,4(A0)
	CMPI.B	#$80,(A1)
	BNE.S	lbC00CE7C
	BSR.L	SETFILTER
lbC00CE7C	LEA	SYNTHTECH(PC),A2
lbC00CE80	MOVE.L	A2,0(A0)
	BRA.S	lbC00CE68

lbC00CE86	MOVE.L	A1,4(A0)
	LEA	SSTECH(PC),A2
	BRA.S	lbC00CE80

lbC00CE90	LEA	IFFTECH(PC),A2
	BRA.S	lbC00CE80

;QUITINSTRUMENT	MOVEM.L	D0-D7/A0-A6,-(SP)
;	MOVE.L	A0,D0
;	BEQ.S	lbC00CEC2
;	LEA	$3E(A6),A1
;	CLR.B	D0
;lbC00CEA4	CMPI.B	#0,1(A1)
;	BEQ.S	lbC00CEB6
;	CMPA.L	4(A1),A0
;	BNE.S	lbC00CEB6
;	BSR.L	STOPNOTE
;lbC00CEB6	ADDA.W	#$16,A1
;	ADDQ.B	#1,D0
;	CMPI.B	#4,D0
;	BNE.S	lbC00CEA4
;lbC00CEC2	MOVEM.L	(SP)+,D0-D7/A0-A6
;	RTS

;RELEASESCORE	MOVEM.L	D0/D1,-(SP)
;	CLR.W	$3C(A6)
;	BSET	#0,$1C(A6)
;	TST.W	D0
;	BNE.S	lbC00CEDC
;	MOVEQ	#1,D0
;lbC00CEDC	CLR.W	D1
;	BSR.L	RAMPVOLUME
;	MOVEM.L	(SP)+,D0/D1
;	RTS

PLAYSCORE	MOVEM.L	D0-D7/A0-A6,-(SP)
	BSR.L	STOPSCORE
	MOVE.L	A0,D4
	BEQ.S	lbC00CF44
	MOVEA.L	D4,A5
	CMP.L	D0,D1
	BEQ.S	lbC00CF44
	BCS.S	lbC00CF44
	MOVE.L	D0,12(A6)
	MOVE.L	D1,$14(A6)
	LEA	$20(A5),A0
	LEA	$26(A6),A1
	MOVEQ	#3,D7
lbC00CF0E	MOVE.L	(A0)+,(A1)+
	DBRA	D7,lbC00CF0E
	MOVEA.L	A5,A0
	BSR.L	lbC00CF7A
	BSR.L	lbC00CFEC
	CLR.W	$1E(A6)
	MOVE.L	A5,6(A6)
	CLR.W	0(A6)
	MOVE.W	2(A5),2(A6)
	MOVE.W	6(A5),4(A6)
	MOVE.W	0(A5),D1
	MOVE.W	D3,D0
	BSR.L	RAMPVOLUME
	MOVE.W	D2,10(A6)
lbC00CF44	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTS

STOPSCORE	BCLR	#0,$1C(A6)
lbC00CF50	MOVEM.L	D0/A0,-(SP)
	TST.W	10(A6)
	BEQ.S	lbC00CF74
	CLR.W	10(A6)
	LEA	$26(A6),A0
	CLR.B	D0
lbC00CF64	TST.L	(A0)+
	BEQ.S	lbC00CF6C
	BSR.L	RELEASENOTE
lbC00CF6C	ADDQ.B	#1,D0
	CMPI.B	#4,D0
	BNE.S	lbC00CF64
lbC00CF74	MOVEM.L	(SP)+,D0/A0
	RTS

lbC00CF7A	MOVEM.L	D0-D7/A0-A6,-(SP)
	MOVEA.L	A0,A3
	LEA	$C6(A6),A1
	MOVE.L	D0,D6
	CLR.B	D7
lbC00CF88	CLR.L	0(A1)
	CLR.B	$10(A1)
	CLR.B	$11(A1)
	MOVE.L	$30(A0),D0
	BEQ.S	lbC00CFDA
	ADD.L	A3,D0
	MOVEA.L	D0,A2
	MOVE.L	D6,D5
lbC00CFA0	MOVE.L	A2,0(A1)
	TST.L	D5
	BLE.S	lbC00CFDA
	MOVE.W	(A2)+,D0
	BEQ.S	lbC00CFA0
	CMPI.W	#$FFFF,D0
	BEQ.S	lbC00CFDA
	CMPI.W	#$8200,D0
	BCC.S	lbC00CFA0
	CMPI.W	#$8100,D0
	BCC.S	lbC00CFD2
	ANDI.L	#$FF,D0
	SUB.L	D0,D5
	BPL.S	lbC00CFA0
	MOVE.L	D5,D0
	NEG.L	D0
	MOVE.B	D0,$11(A1)
	BRA.S	lbC00CFA0

lbC00CFD2	ADDQ.B	#1,D0
	MOVE.B	D0,$10(A1)
	BRA.S	lbC00CFA0

lbC00CFDA	ADDQ.L	#4,A0
	ADDQ.L	#4,A1
	ADDQ.B	#1,D7
	CMPI.B	#4,D7
	BNE.S	lbC00CF88
	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTS

lbC00CFEC	MOVEM.L	D0-D7/A0-A6,-(SP)
	LEA	$C6(A6),A2
	LEA	$E6(A6),A1
	MOVEQ	#7,D7
lbC00CFFA	MOVE.L	(A2)+,(A1)+
	DBRA	D7,lbC00CFFA
	MOVE.L	12(A6),$10(A6)
	MOVEA.L	A6,A4
	CLR.B	D7
lbC00D00A	TST.L	$26(A4)
	BEQ.S	lbC00D016
	MOVE.B	D7,D0
	BSR.L	RELEASENOTE
lbC00D016	CLR.L	$A6(A4)
	CLR.L	D0
	MOVE.B	$F7(A4),D0
	ADDQ.B	#1,D0
	MOVE.L	D0,$B6(A4)
	MOVE.B	$F6(A4),D0
	BEQ.S	lbC00D038
	SUBQ.B	#1,D0
	LEA	$40(A0),A3
	ASL.W	#1,D0
	MOVE.L	0(A3,D0.W),D0
lbC00D038	MOVE.L	D0,$96(A4)
	ADDQ.L	#4,A0
	ADDQ.L	#4,A4
	ADDQ.B	#1,D7
	CMPI.B	#4,D7
	BCS.S	lbC00D00A
	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTS

PlayTINY
;INTERRUPT	MOVEM.L	D0-D7/A0-A6,-(SP)
;	MOVEA.L	SONIX(PC),A6
;	MOVE.L	$18(A6),D0
;	BEQ.S	lbC00D060
;	MOVEA.L	D0,A0
;	JSR	(A0)
lbC00D060	BSR.L	lbC00D430
	BSR.S	lbC00D070
	BSR.L	lbC00D1DE
;	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTS

lbC00D070	TST.W	$1E(A6)
	BEQ.S	lbC00D07E
	SUBQ.W	#1,$1E(A6)
	BNE.L	lbC00D1DC
lbC00D07E	MOVE.W	2(A6),D0
	LSR.W	#1,D0
	CMP.W	$20(A6),D0
	BEQ.S	lbC00D0CE
	MOVE.W	D0,$20(A6)
	ASL.W	#1,D0
	LEA	lbW00D4CC(PC),A0
	MOVE.W	0(A0,D0.W),D1
	MOVE.W	D1,D2
	MOVEQ	#12,D7
	LSR.W	D7,D2
	MOVE.W	D2,$24(A6)
	ASL.W	D7,D2
	SWAP	D1
	CLR.W	D1
	LSR.L	#1,D1
	DIVU.W	D2,D1
	MOVE.W	D1,$22(A6)
	MULU.W	#$2E9C,D1
	MOVEQ	#15,D7
	LSR.L	D7,D1
;	MOVE.B	D1,$BFE401
;	LSR.W	#8,D1
;	MOVE.B	D1,$BFE501
;	MOVE.B	#$11,$BFEE01

	movem.l	A1/A5,-(SP)
	move.l	EagleBase(PC),A5
	move.w	D1,dtg_Timer(A5)
	move.l	dtg_SetTimer(A5),A1
	jsr	(A1)
	movem.l	(SP)+,A1/A5

lbC00D0CE	TST.W	10(A6)
	BEQ.L	lbC00D1DC
	MOVE.W	$24(A6),$1E(A6)
	MOVEA.L	6(A6),A2
	CLR.W	D6
lbC00D0E2	MOVEA.L	A2,A1
	MOVEA.L	A6,A5
	CLR.B	D7
lbC00D0E8	TST.L	$A6(A5)
	BEQ.S	lbC00D104
	SUBQ.L	#1,$A6(A5)
	BNE.S	lbC00D100
	TST.L	$26(A5)
	BEQ.S	lbC00D100
	MOVE.B	D7,D0
	BSR.L	RELEASENOTE
lbC00D100	BRA.L	lbC00D19C

lbC00D104	TST.L	$B6(A5)
	BEQ.S	lbC00D110
	SUBQ.L	#1,$B6(A5)
	BNE.S	lbC00D100
lbC00D110	MOVE.L	$E6(A5),D0
	BNE.S	lbC00D11A
lbC00D116	ADDQ.W	#1,D6
	BRA.S	lbC00D100

lbC00D11A	MOVEA.L	D0,A0
lbC00D11C	MOVE.W	(A0)+,D2
	BEQ.S	lbC00D11C
	CMPI.W	#$FFFF,D2
	BEQ.S	lbC00D116
	MOVE.L	A0,$E6(A5)
	MOVE.W	D2,D3
	LSR.W	#8,D2
	ANDI.W	#$FF,D3
	TST.B	D2
	BPL.S	lbC00D156
	CMPI.B	#$80,D2
	BEQ.L	lbC00D198
	CMPI.B	#$81,D2
	BNE.S	lbC00D11C
	CLR.L	D0
	LEA	$40(A2),A3
	ASL.W	#2,D3
	MOVE.L	0(A3,D3.W),D0
	MOVE.L	D0,$96(A5)
	BRA.S	lbC00D11C

lbC00D156	TST.L	$26(A5)
	BEQ.S	lbC00D198
	MOVE.L	$96(A5),D0
	BNE.S	lbC00D168
	MOVE.L	12(A2),D0
	BEQ.S	lbC00D198
lbC00D168	MOVEA.L	D0,A0
	MOVE.W	4(A2),D1
	ASR.W	#4,D1
	SUBI.W	#8,D1
	ADD.W	D2,D1
	MOVE.B	D7,D0
	MOVE.W	$12(A1),D2
	CMPI.W	#1,$28(A5)
	BEQ.S	_STARTNOTE
	LSR.W	#1,D2
_STARTNOTE	BSR.L	STARTNOTE
	MOVE.W	D3,D0
	MULU.W	#$C000,D0
	SWAP	D0
	MOVE.W	D0,$A8(A5)
	SUB.W	D0,D3
lbC00D198	MOVE.W	D3,$B8(A5)
lbC00D19C	ADDQ.L	#4,A1
	ADDQ.L	#4,A5
	ADDQ.B	#1,D7
	CMPI.B	#4,D7
	BNE.L	lbC00D0E8
	MOVE.L	$10(A6),D0
	ADDQ.L	#1,$10(A6)
	MOVE.L	$14(A6),D1
	BPL.S	lbC00D1C0
	CMPI.W	#4,D6
	BNE.S	lbC00D1DC
	BRA.S	lbC00D1C4

lbC00D1C0	CMP.L	D1,D0
	BNE.S	lbC00D1DC
lbC00D1C4
;	TST.W	10(A6)
;	BMI.S	lbC00D1D0
;	SUBQ.W	#1,10(A6)
;	BEQ.S	lbC00D1DC
lbC00D1D0

	bsr.w	SongEnd

	MOVEA.L	A2,A0
	BSR.L	lbC00CFEC
	ADDQ.W	#1,D6
	BRA.L	lbC00D0E2

lbC00D1DC	RTS

lbC00D1DE	CLR.W	D6
	CLR.L	D7
	MOVEA.L	6(A6),A0
	LEA	$3E(A6),A1
lbC00D1EA	TST.B	0(A1)
	BNE.S	lbC00D1F8
	CMPI.B	#0,1(A1)
	BEQ.S	lbC00D216
lbC00D1F8	MOVE.L	4(A1),D0
	BEQ.S	lbC00D22A
	MOVEA.L	D0,A4
	MOVEA.L	0(A4),A4
	MOVEM.L	D6/D7/A0/A1/A6,-(SP)
	JSR	0(A4)
	MOVEM.L	(SP)+,D6/D7/A0/A1/A6
	TST.L	D0
	BEQ.S	lbC00D216
	BSET	D7,D6
lbC00D216	MOVEQ	#1,D0
	CMPI.B	#1,0(A1)
	BEQ.S	lbC00D22A
	MOVEQ	#2,D0
	CMPI.B	#2,0(A1)
	BNE.S	lbC00D22E
lbC00D22A	MOVE.B	D0,1(A1)
lbC00D22E	CLR.B	0(A1)
	ADDA.W	#$16,A1
	ADDQ.W	#1,D7
	CMPI.W	#4,D7
	BNE.S	lbC00D1EA
;	MOVE.W	D6,$DFF096

	move.l	D0,-(SP)
	move.w	D6,D0
	bsr.w	PokeDMA
	move.l	(SP)+,D0

	MOVE.W	#$8000,D6
	CLR.L	D7
	LEA	$3E(A6),A1
	LEA	$DFF0A0,A2
lbC00D254	CMPI.B	#0,1(A1)
	BEQ.S	lbC00D276
	MOVEA.L	4(A1),A4
	MOVEA.L	0(A4),A4
	MOVEM.L	D6/D7/A0-A2/A6,-(SP)
	JSR	4(A4)
	MOVEM.L	(SP)+,D6/D7/A0-A2/A6
	TST.L	D0
	BEQ.S	lbC00D276
	BSET	D7,D6
lbC00D276	ADDA.W	#$10,A2
	ADDA.W	#$16,A1
	ADDQ.W	#1,D7
	CMPI.W	#4,D7
	BNE.S	lbC00D254
;	MOVE.W	D6,$DFF096

	move.l	D0,-(SP)
	move.w	D6,D0
	bsr.w	PokeDMA
	move.l	(SP)+,D0

	RTS

lbC00D28E	CLR.W	D0
	BSET	D7,D0
;	MOVE.W	D0,$DFF096

	bsr.w	PokeDMA

	MOVE.W	D7,D0
	ASL.W	#4,D0
	LEA	$DFF0A0,A0
;	MOVE.W	#2,6(A0,D0.W)

	movem.l	D0/A2,-(SP)
	lea	(A0,D0.W),A2
	moveq	#2,D0
	bsr.w	PokePer
	movem.l	(SP)+,D0/A2

	RTS

STARTNOTE	MOVEM.L	D1-D7/A0-A6,-(SP)
	MOVE.L	A0,D3
	BEQ.L	lbC00D352
	MOVEA.L	D3,A0
	MOVEA.L	6(A6),A5
	LEA	$3E(A6),A1
	EXT.W	D0
	BPL.L	lbC00D310
	MOVE.B	#0,D5
	MOVEQ	#4,D7
lbC00D2CA	MOVE.W	D7,D6
	MOVE.W	$36(A6),D0
lbC00D2D0	ADDQ.W	#1,D0
	CMP.W	D7,D0
	BCS.S	lbC00D2D8
	CLR.W	D0
lbC00D2D8	MOVE.W	D0,D3
	MULU.W	#$16,D3
	TST.B	0(A1,D3.W)
	BNE.S	lbC00D2EA
	CMP.B	1(A1,D3.W),D5
	BEQ.S	lbC00D2FC
lbC00D2EA	SUBQ.W	#1,D6
	BNE.S	lbC00D2D0
	CMPI.B	#0,D5
	BNE.L	lbC00D352
	MOVE.B	#2,D5
	BRA.S	lbC00D2CA

lbC00D2FC	TST.W	10(A6)
	BEQ.S	lbC00D30C
	MOVE.W	D0,D3
	ASL.W	#2,D3
	TST.L	$26(A6,D3.W)
	BNE.S	lbC00D2EA
lbC00D30C	MOVE.W	D0,$36(A6)
lbC00D310	MOVE.W	D0,D3
	MULU.W	#$16,D3
	ADDA.W	D3,A1
	CMPI.B	#0,1(A1)
	BEQ.S	lbC00D334
	MOVEA.L	0(A0),A2
	MOVEA.L	4(A1),A3
	MOVEA.L	0(A3),A3
	CMPA.L	A3,A2
	BEQ.S	lbC00D334
	BSR.L	STOPNOTE
lbC00D334	MOVE.L	A0,4(A1)
	MOVE.B	D1,3(A1)
	ANDI.W	#$FF,D2
	MOVE.W	D2,8(A1)
	MOVE.B	#1,0(A1)
	EXT.L	D0
lbC00D34C	MOVEM.L	(SP)+,D1-D7/A0-A6
	RTS

lbC00D352	MOVEQ	#-1,D0
	BRA.S	lbC00D34C

;RELEASESOUND	MOVE.L	D0,-(SP)
;	CLR.W	10(A6)
;	MOVEQ	#3,D0
;lbC00D35E	BSR.S	RELEASENOTE
;	DBRA	D0,lbC00D35E
;	MOVE.L	(SP)+,D0
;	RTS

RELEASENOTE	MOVEM.L	D0/A1,-(SP)
	LEA	$3E(A6),A1
	EXT.W	D0
	MULU.W	#$16,D0
	ADDA.W	D0,A1
	CLR.B	0(A1)
	CMPI.B	#1,1(A1)
	BNE.S	lbC00D38A
	MOVE.B	#2,0(A1)
lbC00D38A	MOVEM.L	(SP)+,D0/A1
	RTS

;STOPSOUND	MOVE.L	D0,-(SP)
;	CLR.W	10(A6)
;	MOVEQ	#3,D0
;lbC00D398	BSR.S	STOPNOTE
;	DBRA	D0,lbC00D398
;	MOVE.L	(SP)+,D0
;	RTS

STOPNOTE	MOVEM.L	D0/D7/A0/A1,-(SP)
	MOVEA.L	6(A6),A0
	LEA	$3E(A6),A1
	EXT.W	D0
	MOVE.W	D0,D7
	MULU.W	#$16,D0
	ADDA.W	D0,A1
	CLR.B	0(A1)
	CMPI.B	#0,1(A1)
	BEQ.S	lbC00D3EC
	MOVE.B	#3,0(A1)
	MOVE.L	4(A1),D0
	BEQ.S	lbC00D3E2
	MOVEM.L	D0-D7/A0-A6,-(SP)
	MOVEA.L	D0,A4
	MOVEA.L	0(A4),A4
	JSR	0(A4)
	MOVEM.L	(SP)+,D0-D7/A0-A6
lbC00D3E2	MOVE.B	#0,1(A1)
	CLR.B	0(A1)
lbC00D3EC	MOVEM.L	(SP)+,D0/D7/A0/A1
	RTS

RAMPVOLUME	MOVEM.L	D1/D2/A0,-(SP)
	MOVEA.L	6(A6),A0
	CLR.W	$3C(A6)
	TST.W	D0
	BEQ.S	lbC00D42A
	MOVEQ	#0,D2
	MOVE.W	0(A6),D2
	ASL.W	#8,D2
	MOVE.W	D2,$38(A6)
	ASL.W	#8,D1
	SUB.W	D1,D2
	BCC.S	lbC00D416
	NEG.W	D2
lbC00D416	DIVU.W	D0,D2
	SWAP	D1
	MOVE.W	D2,D1
	BNE.S	lbC00D420
	ADDQ.W	#1,D1
lbC00D420	MOVE.L	D1,$3A(A6)
lbC00D424	MOVEM.L	(SP)+,D1/D2/A0
	RTS

lbC00D42A	MOVE.W	D1,0(A6)
	BRA.S	lbC00D424

lbC00D430	MOVE.W	$3C(A6),D0
	BEQ.S	lbC00D462
	MULU.W	$22(A6),D0
	ASL.L	#1,D0
	BCS.S	lbC00D464
	SWAP	D0
	MOVE.W	D0,D3
	MOVE.W	$38(A6),D1
	MOVE.W	$3A(A6),D2
	SUB.W	D1,D2
	BCC.S	lbC00D452
	NEG.W	D3
	NEG.W	D2
lbC00D452	CMP.W	D2,D0
	BCC.S	lbC00D464
	ADD.W	D3,D1
	MOVE.W	D1,$38(A6)
lbC00D45C	LSR.W	#8,D1
	MOVE.W	D1,0(A6)
lbC00D462	RTS

lbC00D464	MOVE.W	$3A(A6),D1
	BNE.S	lbC00D476
	BCLR	#0,$1C(A6)
	BEQ.S	lbC00D476
	BSR.L	lbC00CF50
lbC00D476	CLR.W	$3C(A6)
	BRA.S	lbC00D45C

;STEALTRACK	MOVEM.L	D1/A0,-(SP)
;	CLR.W	D1
;	MOVE.B	D0,D1
;	ASL.W	#2,D1
;	LEA	$28(A6,D1.W),A0
;	TST.W	(A0)
;	BEQ.S	lbC00D494
;	BSR.L	STOPNOTE
;	CLR.W	(A0)
;lbC00D494	MOVEM.L	(SP)+,D1/A0
;	RTS

;RESUMETRACK	MOVEM.L	D0/A0,-(SP)
;	EXT.W	D0
;	ASL.W	#2,D0
;	MOVEA.L	6(A6),A0
;	MOVE.W	$22(A0,D0.W),$28(A6,D0.W)
;	MOVEM.L	(SP)+,D0/A0
;	RTS

;lbW00D4B2	dc.w	$8000
;	dc.w	$78D1
;	dc.w	$7209
;	dc.w	$6BA2
;	dc.w	$6598
;	dc.w	$5FE4
;	dc.w	$5A82
;	dc.w	$556E
;	dc.w	$50A3
;	dc.w	$4C1C
;	dc.w	$47D6
;	dc.w	$43CE
;	dc.w	$4000
;lbW00D4CC	dc.w	$FA83
;	dc.w	$F525
;	dc.w	$EFE4
;	dc.w	$EAC0
;	dc.w	$E5B9
;	dc.w	$E0CC
;	dc.w	$DBFB
;	dc.w	$D744
;	dc.w	$D2A8
;	dc.w	$CE24
;	dc.w	$C9B9
;	dc.w	$C567
;	dc.w	$C12C
;	dc.w	$BD08
;	dc.w	$B8FB
;	dc.w	$B504
;	dc.w	$B123
;	dc.w	$AD58
;	dc.w	$A9A1
;	dc.w	$A5FE
;	dc.w	$A270
;	dc.w	$9EF5
;	dc.w	$9B8D
;	dc.w	$9837
;	dc.w	$94F4
;	dc.w	$91C3
;	dc.w	$8EA4
;	dc.w	$8B95
;	dc.w	$8898
;	dc.w	$85AA
;	dc.w	$82CD
;	dc.w	$8000
;	dc.w	$7D41
;	dc.w	$7A92
;	dc.w	$77F2
;	dc.w	$7560
;	dc.w	$72DC
;	dc.w	$7066
;	dc.w	$6DFD
;	dc.w	$6BA2
;	dc.w	$6954
;	dc.w	$6712
;	dc.w	$64DC
;	dc.w	$62B3
;	dc.w	$6096
;	dc.w	$5E84
;	dc.w	$5C7D
;	dc.w	$5A82
;	dc.w	$5891
;	dc.w	$56AC
;	dc.w	$54D0
;	dc.w	$52FF
;	dc.w	$5138
;	dc.w	$4F7A
;	dc.w	$4DC6
;	dc.w	$4C1B
;	dc.w	$4A7A
;	dc.w	$48E1
;	dc.w	$4752
;	dc.w	$45CA
;	dc.w	$444C
;	dc.w	$42D5
;	dc.w	$4166
;	dc.w	$4000
;	dc.w	$3EA0
;	dc.w	$3D49
;	dc.w	$3BF9
;	dc.w	$3AB0
;	dc.w	$396E
;	dc.w	$3833
;	dc.w	$36FE
;	dc.w	$35D1
;	dc.w	$34AA
;	dc.w	$3389
;	dc.w	$326E
;	dc.w	$3159
;	dc.w	$304B
;	dc.w	$2F42
;	dc.w	$2E3E
;	dc.w	$2D41
;	dc.w	$2C48
;	dc.w	$2B56
;	dc.w	$2A68
;	dc.w	$297F
;	dc.w	$289C
;	dc.w	$27BD
;	dc.w	$26E3
;	dc.w	$260D
;	dc.w	$253D
;	dc.w	$2470
;	dc.w	$23A9
;	dc.w	$22E5
;	dc.w	$2226
;	dc.w	$216A
;	dc.w	$20B3
;	dc.w	$2000
;	dc.w	$1F50
;	dc.w	$1EA4
;	dc.w	$1DFC
;	dc.w	$1D58
;	dc.w	$1CB7
;	dc.w	$1C19
;	dc.w	$1B7F
;	dc.w	$1AE8
;	dc.w	$1A55
;	dc.w	$19C4
;	dc.w	$1937
;	dc.w	$18AC
;	dc.w	$1825
;	dc.w	$17A1
;	dc.w	$171F
;	dc.w	$16A0
;	dc.w	$1624
;	dc.w	$15AB
;	dc.w	$1534
;	dc.w	$14BF
;	dc.w	$144E
;	dc.w	$13DE
;	dc.w	$1371
;	dc.w	$1306
;	dc.w	$129E
;	dc.w	$1238
;	dc.w	$11D4
;	dc.w	$1172
;	dc.w	$1113
;	dc.w	$10B5
;	dc.w	$1059
;	dc.w	$1000

SYNTHTECH	BRA.L	lbC00D5FE

	BRA.L	lbC00D5D4

lbC00D5D4	CLR.L	D0
	CMPI.W	#4,D7
	BGE.S	lbC00D5FC
;	MOVE.L	12(A1),0(A2)
;	MOVE.W	$10(A1),4(A2)
;	MOVE.W	$12(A1),6(A2)
;	MOVE.W	$14(A1),8(A2)

	move.l	D0,-(SP)
	move.l	12(A1),D0
	bsr.w	PokeAdr
	move.w	$10(A1),D0
	bsr.w	PokeLen
	move.w	$12(A1),D0
	bsr.w	PokePer
	move.w	$14(A1),D0
	bsr.w	PokeVol
	move.l	(SP)+,D0

	MOVE.W	10(A1),D0
	CLR.W	10(A1)
lbC00D5FC	RTS

lbC00D5FE	CMPI.W	#4,D7
	BGE.L	lbC00D9D0
	MOVEA.L	4(A1),A3
	LEA	$10A(A6),A2
	MOVE.W	D7,D0
	MULU.W	#$1A,D0
	ADDA.W	D0,A2
	MOVE.B	0(A1),D0
	BEQ.L	lbC00D71A
	CMPI.B	#1,D0
	BNE.L	lbC00D6FE
	CLR.L	D1
	MOVE.B	3(A1),D1
	CMPI.W	#$24,D1
	BGE.S	lbC00D644
lbC00D632	CLR.B	0(A1)
	CMPI.B	#0,1(A1)
	BEQ.L	lbC00D9D0
	BRA.L	lbC00D71A

lbC00D644	CMPI.W	#$6C,D1
	BGE.S	lbC00D632
	SUBI.W	#$24,D1
	CMPI.B	#0,1(A1)
	BNE.S	lbC00D65A
	CLR.L	12(A2)
lbC00D65A	CMPI.B	#1,1(A1)
	BEQ.S	lbC00D666
	CLR.W	10(A2)
lbC00D666	DIVU.W	#12,D1
	MOVE.W	D1,D2
	SWAP	D1
	ASL.W	#1,D1
	LEA	lbW00D4B2(PC),A0
	MOVE.W	#$D5C8,D0
	MULU.W	0(A0,D1.W),D0
	ADDI.W	#$11,D2
	LSR.L	D2,D0
	TST.W	0(A2)
	BNE.S	lbC00D68E
	CLR.W	2(A2)
	BRA.S	lbC00D6B6

lbC00D68E	MOVE.W	D0,D1
	SUB.W	0(A2),D1
	EXT.L	D1
	MOVE.W	$196(A3),D2
	SWAP	D2
	CLR.W	D2
	LSR.L	#1,D2
	DIVU.W	$22(A6),D2
	LSR.W	#3,D2
	ADDQ.W	#1,D2
	MOVE.W	D2,2(A2)
	DIVS.W	D2,D1
	MOVE.W	D1,4(A2)
	MULU.W	D2,D1
	SUB.W	D1,D0
lbC00D6B6	MOVE.W	D0,0(A2)
	MOVE.W	#1,$18(A2)
	TST.W	$1A6(A3)
	BNE.S	lbC00D6CA
	CLR.W	$16(A2)
lbC00D6CA	CLR.W	$12(A2)
	TST.W	$1A2(A3)
	BEQ.S	lbC00D6F6
	CLR.W	$10(A2)
	MOVE.W	$1A4(A3),D0
	SWAP	D0
	CLR.W	D0
	LSR.L	#1,D0
	DIVU.W	$22(A6),D0
	LSR.W	#2,D0
	MOVE.W	D0,$12(A2)
	MOVE.B	$88(A3),D0
	EXT.W	D0
	MOVE.W	D0,$14(A2)
lbC00D6F6	MOVE.W	#$FFFF,10(A1)
	BRA.S	lbC00D71A

lbC00D6FE	CMPI.B	#2,D0
	BNE.S	lbC00D70C
	MOVE.W	#6,10(A2)
	BRA.S	lbC00D71A

lbC00D70C	CMPI.B	#3,D0
	BNE.S	lbC00D71A
	BSR.L	lbC00D28E
	BRA.L	lbC00D9D0

lbC00D71A	TST.W	$12(A2)
	BMI.S	lbC00D760
	BEQ.S	lbC00D728
	SUBQ.W	#1,$12(A2)
	BRA.S	lbC00D760

lbC00D728	MOVE.W	$10(A2),D0
	MOVE.W	$1A0(A3),D1
	MULU.W	$22(A6),D1
	ASL.L	#6,D1
	SWAP	D1
	ADD.W	D1,D0
	BCC.S	lbC00D74C
	TST.W	$1A2(A3)
	BEQ.S	lbC00D74C
	BMI.S	lbC00D74C
	MOVE.W	#$FFFF,$12(A2)
	BRA.S	lbC00D760

lbC00D74C	MOVE.W	D0,$10(A2)
	LSR.W	#8,D0
	LEA	$88(A3),A0
	MOVE.B	0(A0,D0.W),D0
	EXT.W	D0
	MOVE.W	D0,$14(A2)
lbC00D760	MOVE.W	10(A2),D0
	LEA	0(A3,D0.W),A0
	CLR.L	D1
	MOVE.W	$1AA(A0),D1
	SWAP	D1
	MOVE.L	12(A2),D2
	CLR.L	D3
	MOVE.W	$1B2(A0),D3
	MOVE.W	D3,D0
	LSR.W	#5,D0
	EORI.W	#7,D0
	ANDI.W	#$1F,D3
	ADDI.W	#$21,D3
	MULU.W	$22(A6),D3
	ASL.L	#3,D3
	LSR.L	D0,D3
	MOVE.L	D1,D0
	SUB.L	D2,D0
	BPL.S	lbC00D79A
	NEG.L	D0
lbC00D79A	CMP.L	D3,D0
	BGT.S	lbC00D7B0
	MOVE.L	D1,D2
	CMPI.W	#4,10(A2)
	BGE.S	lbC00D7BA
	ADDI.W	#2,10(A2)
	BRA.S	lbC00D7BA

lbC00D7B0	CMP.L	D1,D2
	BLT.S	lbC00D7B8
	SUB.L	D3,D2
	BRA.S	lbC00D7BA

lbC00D7B8	ADD.L	D3,D2
lbC00D7BA	MOVE.L	D2,12(A2)
	MOVE.W	0(A2),D0
	MOVEQ	#5,D2
	TST.W	2(A2)
	BEQ.S	lbC00D7D6
	SUBQ.W	#1,2(A2)
	ADD.W	4(A2),D0
	MOVE.W	D0,0(A2)
lbC00D7D6	CMPI.W	#$1AC,D0
	BLE.S	lbC00D7E2
	LSR.W	#1,D0
	SUBQ.W	#1,D2
	BRA.S	lbC00D7D6

lbC00D7E2	MOVE.W	D2,8(A2)
	MOVEQ	#$40,D1
	LSR.W	D2,D1
	MOVE.W	D1,$10(A1)
	MOVE.W	$14(A2),D1
	MOVE.W	$198(A3),D2
	MULS.W	D2,D1
	ASR.W	#7,D1
	MOVE.W	4(A6),D2
	SUBI.W	#$80,D2
	SUB.W	D2,D1
	ADDI.W	#$1000,D1
	MULU.W	D1,D0
	MOVEQ	#12,D1
	LSR.L	D1,D0
	MOVE.W	D0,$12(A1)
	MOVE.W	$190(A3),D0
	MOVE.W	$14(A2),D1
	NEG.W	D1
	MOVE.W	$194(A3),D2
	MULS.W	D2,D1
	ASR.W	#8,D1
	ADD.W	D1,D0
	TST.W	$192(A3)
	BEQ.S	lbC00D838
	MOVE.L	12(A2),D1
	SWAP	D1
	MULU.W	D1,D0
	LSR.W	#8,D0
	BRA.S	lbC00D842

lbC00D838	CMPI.W	#6,10(A2)
	BNE.S	lbC00D842
	CLR.W	D0
lbC00D842	ANDI.W	#$FF,D0
	ADDQ.W	#1,D0
	MULU.W	0(A6),D0
	LSR.W	#8,D0
	ADDQ.W	#1,D0
	MULU.W	8(A1),D0
	LSR.W	#8,D0
	ADDQ.W	#1,D0
	LSR.W	#2,D0
	MOVE.W	D0,$14(A1)
	MOVE.W	$19C(A3),D0
	MOVE.L	12(A2),D1
	SWAP	D1
	MULU.W	D0,D1
	LSR.W	#8,D1
	MOVE.W	$19A(A3),D0
	EORI.W	#$FF,D0
	SUB.W	D1,D0
	MOVE.W	$14(A2),D1
	MOVE.W	$19E(A3),D2
	MULS.W	D2,D1
	ASR.W	#8,D1
	ADD.W	D1,D0
	ANDI.W	#$FF,D0
	LSR.W	#2,D0
	ASL.W	#7,D0
	MOVEA.L	4(A3),A0
	MOVE.L	A0,D1
	BNE.S	lbC00D89A
	LEA	8(A3),A0
	CLR.W	D0
lbC00D89A	ADDA.W	D0,A0
	MOVE.W	6(A2),D0
	EORI.W	#$80,D0
	MOVE.W	D0,6(A2)
	MOVEA.L	$106(A6),A4
	LEA	0(A4,D0.W),A4
	MOVE.W	#$100,D0
	MULU.W	D7,D0
	ADDA.W	D0,A4
	MOVE.L	A4,12(A1)
	TST.W	$1A6(A3)
	BNE.S	lbC00D8DC
	MOVE.W	8(A2),D3
	MOVEQ	#0,D1
	BSET	D3,D1
	MOVE.W	#$80,D4
	LSR.W	D3,D4
lbC00D8D0	MOVE.B	(A0),(A4)+
	ADDA.W	D1,A0
	SUBQ.W	#1,D4
	BNE.S	lbC00D8D0
	BRA.L	lbC00D9D0

lbC00D8DC	TST.W	$1A8(A3)
	BNE.L	lbC00D94E
	MOVE.W	8(A2),D3
	MOVEQ	#0,D1
	BSET	D3,D1
	MOVE.W	$10(A1),D2
	ASL.W	#1,D2
	SUBQ.W	#1,D2
	MOVE.W	$1A6(A3),D4
	MULU.W	$22(A6),D4
	MOVEQ	#13,D0
	LSR.L	D0,D4
	ADD.W	$16(A2),D4
	MOVE.W	D4,$16(A2)
	MOVEQ	#9,D0
	LSR.W	D0,D4
	LEA	0(A0,D4.W),A5
	LSR.W	D3,D4
	SUB.W	D4,D2
lbC00D914	MOVE.B	(A0),D0
	EXT.W	D0
	MOVE.B	(A5),D3
	EXT.W	D3
	ADD.W	D3,D0
	ASR.W	#1,D0
	MOVE.B	D0,(A4)+
	ADDA.W	D1,A0
	ADDA.W	D1,A5
	DBRA	D2,lbC00D914
	SUBA.W	#$80,A5
	SUBQ.W	#1,D4
	BMI.L	lbC00D9D0
lbC00D934	MOVE.B	(A0),D0
	EXT.W	D0
	MOVE.B	(A5),D3
	EXT.W	D3
	ADD.W	D3,D0
	ASR.W	#1,D0
	MOVE.B	D0,(A4)+
	ADDA.W	D1,A0
	ADDA.W	D1,A5
	DBRA	D4,lbC00D934
	BRA.L	lbC00D9D0

lbC00D94E	MOVE.W	$1A6(A3),D0
	MULU.W	$22(A6),D0
	MOVEQ	#11,D1
	LSR.L	D1,D0
	MULS.W	$18(A2),D0
	ADD.W	$16(A2),D0
	BVC.S	lbC00D974
	CMPI.W	#$8000,D0
	BNE.S	lbC00D96E
	ADD.W	$18(A2),D0
lbC00D96E	NEG.W	$18(A2)
	NEG.W	D0
lbC00D974	MOVE.W	D0,$16(A2)
	MOVE.W	$1A8(A3),D1
	MULS.W	D1,D0
	MOVEQ	#$11,D1
	ADD.W	8(A2),D1
	ASR.L	D1,D0
	MOVE.W	$10(A1),D2
	MOVE.W	D2,D3
	ADD.W	D0,D2
	SUB.W	D0,D3
	MOVE.W	D2,D6
	BEQ.S	lbC00D9B0
	CLR.W	D0
	CLR.W	D1
	MOVEQ	#$40,D4
	DIVU.W	D2,D4
	MOVE.W	D4,D5
	SWAP	D4
lbC00D9A0	MOVE.B	0(A0,D0.W),(A4)+
	SUB.W	D4,D1
	BCC.S	lbC00D9AA
	ADD.W	D2,D1
lbC00D9AA	ADDX.W	D5,D0
	SUBQ.W	#1,D6
	BNE.S	lbC00D9A0
lbC00D9B0	MOVE.W	D3,D6
	BEQ.S	lbC00D9D0
	MOVEQ	#$40,D0
	CLR.W	D1
	MOVEQ	#$40,D4
	DIVU.W	D3,D4
	MOVE.W	D4,D5
	SWAP	D4
lbC00D9C0	MOVE.B	0(A0,D0.W),(A4)+
	SUB.W	D4,D1
	BCC.S	lbC00D9CA
	ADD.W	D3,D1
lbC00D9CA	ADDX.W	D5,D0
	SUBQ.W	#1,D6
	BNE.S	lbC00D9C0
lbC00D9D0	CLR.L	D0
	RTS

SETFILTER	MOVEM.L	D0-D7/A0-A6,-(SP)
	MOVEA.L	4(A0),A1
	LEA	8(A0),A0

	bra.w	OneFilter

;	LEA	lbW00DA38(PC),A2
;	CLR.W	D3
;	MOVE.B	$7F(A0),D4
;	EXT.W	D4
;	ASL.W	#7,D4
;	CLR.W	D0
;lbC00D9F0	MOVE.W	(A2)+,D1
;	MOVE.W	#$8000,D2
;	SUB.W	D1,D2
;	MULU.W	#$E666,D2
;	SWAP	D2
;	LSR.W	#1,D1
;	CLR.W	D5
;lbC00DA02	MOVE.B	0(A0,D5.W),D6
;	EXT.W	D6
;	ASL.W	#7,D6
;	SUB.W	D4,D6
;	MULS.W	D1,D6
;	ASL.L	#2,D6
;	SWAP	D6
;	ADD.W	D6,D3
;	ADD.W	D3,D4
;	ROR.W	#7,D4
;	MOVE.B	D4,(A1)+
;	ROL.W	#7,D4
;	MULS.W	D2,D3
;	ASL.L	#1,D3
;	SWAP	D3
;	ADDQ.W	#1,D5
;	CMPI.W	#$80,D5
;	BCS.S	lbC00DA02
;	ADDQ.W	#1,D0
;	CMPI.W	#$40,D0
;	BNE.S	lbC00D9F0
;	MOVEM.L	(SP)+,D0-D7/A0-A6
;	RTS

;lbW00DA38	dc.w	$8000
;	dc.w	$7683
;	dc.w	$6DBA
;	dc.w	$6597
;	dc.w	$5E10
;	dc.w	$5717
;	dc.w	$50A2
;	dc.w	$4AA8
;	dc.w	$451F
;	dc.w	$4000
;	dc.w	$3B41
;	dc.w	$36DD
;	dc.w	$32CB
;	dc.w	$2F08
;	dc.w	$2B8B
;	dc.w	$2851
;	dc.w	$2554
;	dc.w	$228F
;	dc.w	$2000
;	dc.w	$1DA0
;	dc.w	$1B6E
;	dc.w	$1965
;	dc.w	$1784
;	dc.w	$15C5
;	dc.w	$1428
;	dc.w	$12AA
;	dc.w	$1147
;	dc.w	$1000
;	dc.w	$ED0
;	dc.w	$DB7
;	dc.w	$CB2
;	dc.w	$BC2
;	dc.w	$AE2
;	dc.w	$A14
;	dc.w	$955
;	dc.w	$8A3
;	dc.w	$800
;	dc.w	$768
;	dc.w	$6DB
;	dc.w	$659
;	dc.w	$5E1
;	dc.w	$571
;	dc.w	$50A
;	dc.w	$4AA
;	dc.w	$451
;	dc.w	$400
;	dc.w	$3B4
;	dc.w	$36D
;	dc.w	$32C
;	dc.w	$2F0
;	dc.w	$2B8
;	dc.w	$285
;	dc.w	$255
;	dc.w	$228
;	dc.w	$200
;	dc.w	$1DA
;	dc.w	$1B6
;	dc.w	$196
;	dc.w	$178
;	dc.w	$15C
;	dc.w	$142
;	dc.w	$12A
;	dc.w	$114
;	dc.w	$100

SSTECH	BRA.L	lbC00DB0A

	BRA.L	lbC00DAC0

lbC00DAC0	CLR.L	D0
	CMPI.W	#4,D7
	BGE.S	lbC00DB08
	TST.W	10(A1)
	BEQ.S	lbC00DAFC
	SUBQ.W	#1,10(A1)
	BEQ.S	lbC00DAE4
;	MOVE.W	$10(A1),4(A2)
;	MOVE.L	12(A1),0(A2)

	move.l	D0,-(SP)
	move.w	$10(A1),D0
	bsr.w	PokeLen
	move.l	12(A1),D0
	bsr.w	PokeAdr
	move.l	(SP)+,D0

	MOVEQ	#-1,D0
	BRA.S	lbC00DAFC

lbC00DAE4	LEA	$172(A6),A3
	MOVE.W	D7,D1
	MULU.W	#$14,D1
	ADDA.W	D1,A3
;	MOVE.W	4(A3),4(A2)
;	MOVE.L	0(A3),0(A2)

	move.l	D0,-(SP)
	move.w	4(A3),D0
	bsr.w	PokeLen
	move.l	(A3),D0
	bsr.w	PokeAdr
	move.l	(SP)+,D0

lbC00DAFC
;	MOVE.W	$12(A1),6(A2)
;	MOVE.W	$14(A1),8(A2)

	move.l	D0,-(SP)
	move.w	$12(A1),D0
	bsr.w	PokePer
	move.w	$14(A1),D0
	bsr.w	PokeVol
	move.l	(SP)+,D0

lbC00DB08	RTS

lbC00DB0A	CMPI.W	#4,D7
	BLT.S	lbC00DB14
	CLR.L	D0
	RTS

lbC00DB14	MOVEA.L	4(A1),A3
	LEA	$172(A6),A2
	MOVE.W	D7,D0
	MULU.W	#$14,D0
	ADDA.W	D0,A2
	MOVE.B	0(A1),D0
	BEQ.L	lbC00DC32
	CMPI.B	#1,D0
	BNE.L	lbC00DC16
	MOVEA.L	4(A3),A5
	CLR.L	D1
	MOVE.B	3(A1),D1
	DIVU.W	#12,D1
	MOVE.W	D1,D2
	SWAP	D1
	SUBI.W	#10,D2
	NEG.W	D2
	CMP.B	5(A5),D2
	BLE.S	lbC00DB64
lbC00DB52	CLR.B	0(A1)
	CMPI.B	#0,1(A1)
	BEQ.L	lbC00DD24
	BRA.L	lbC00DC32

lbC00DB64	CMP.B	4(A5),D2
	BLT.S	lbC00DB52
	CMPI.B	#0,1(A1)
	BNE.S	lbC00DB76
	CLR.L	10(A2)
lbC00DB76	CMPI.B	#1,1(A1)
	BEQ.S	lbC00DB82
	CLR.W	8(A2)
lbC00DB82	ASL.W	#1,D1
	LEA	lbW00D4B2(PC),A0
	MOVE.W	#$D5C8,D0
	MULU.W	0(A0,D1.W),D0
	MOVEQ	#15,D1
	LSR.L	D1,D0
	MOVE.W	D0,6(A2)
	MOVEQ	#1,D0
	ASL.L	D2,D0
	MOVE.L	D0,D4
	MOVEQ	#1,D1
	CLR.W	D3
	MOVE.B	4(A5),D3
	ASL.L	D3,D1
	SUB.L	D1,D0
	MULU.W	0(A5),D0
	LEA	$3E(A5,D0.L),A0
	MOVE.L	A0,12(A1)
	MOVE.W	0(A5),D0
	MULU.W	D4,D0
	LSR.L	#1,D0
	MOVE.W	D0,$10(A1)
	MOVEA.L	$106(A6),A0
	ADDA.W	#$400,A0
	MOVEQ	#4,D0
	MOVE.W	2(A5),D1
	CMP.W	0(A5),D1
	BEQ.S	lbC00DBEA
	MULU.W	D4,D1
	MOVEA.L	12(A1),A0
	ADDA.L	D1,A0
	MOVE.W	0(A5),D0
	SUB.W	2(A5),D0
	MULU.W	D4,D0
	LSR.L	#1,D0
lbC00DBEA	MOVE.L	A0,0(A2)
	MOVE.W	D0,4(A2)
	CLR.W	14(A2)
	MOVE.W	$1E(A3),D0
	SWAP	D0
	CLR.W	D0
	LSR.L	#1,D0
	DIVU.W	$22(A6),D0
	LSR.W	#1,D0
	MOVE.W	D0,$10(A2)
	MOVE.W	#2,10(A1)
	BSR.L	lbC00D28E
	BRA.S	lbC00DC32

lbC00DC16	CMPI.B	#2,D0
	BNE.S	lbC00DC24
	MOVE.W	#6,8(A2)
	BRA.S	lbC00DC32

lbC00DC24	CMPI.B	#3,D0
	BNE.S	lbC00DC32
	BSR.L	lbC00D28E
	BRA.L	lbC00DD24

lbC00DC32	TST.W	$10(A2)
	BEQ.S	lbC00DC40
	SUBI.W	#1,$10(A2)
	BRA.S	lbC00DC5A

lbC00DC40	MOVE.W	14(A2),D0
	MOVE.W	$1C(A3),D1
	MULU.W	$22(A6),D1
	ASL.L	#7,D1
	SWAP	D1
	ADDI.W	#$40,D1
	ADD.W	D1,D0
	MOVE.W	D0,14(A2)
lbC00DC5A	MOVE.W	14(A2),D0
	LSR.W	#7,D0
	ADDI.W	#$80,D0
	BTST	#8,D0
	BEQ.S	lbC00DC6E
	EORI.W	#$FF,D0
lbC00DC6E	EORI.W	#$80,D0
	EXT.W	D0
	NEG.W	D0
	MOVE.W	D0,$12(A2)
	MOVE.W	8(A2),D0
	LEA	0(A3,D0.W),A0
	CLR.L	D1
	MOVE.W	10(A0),D1
	SWAP	D1
	MOVE.L	10(A2),D2
	CLR.L	D3
	MOVE.W	$12(A0),D3
	MOVE.W	D3,D0
	LSR.W	#5,D0
	EORI.W	#7,D0
	ANDI.W	#$1F,D3
	ADDI.W	#$21,D3
	MULU.W	$22(A6),D3
	ASL.L	#3,D3
	LSR.L	D0,D3
	MOVE.L	D1,D0
	SUB.L	D2,D0
	BPL.S	lbC00DCB4
	NEG.L	D0
lbC00DCB4	CMP.L	D3,D0
	BGT.S	lbC00DCCA
	MOVE.L	D1,D2
	CMPI.W	#4,8(A2)
	BGE.S	lbC00DCD4
	ADDI.W	#2,8(A2)
	BRA.S	lbC00DCD4

lbC00DCCA	CMP.L	D1,D2
	BLT.S	lbC00DCD2
	SUB.L	D3,D2
	BRA.S	lbC00DCD4

lbC00DCD2	ADD.L	D3,D2
lbC00DCD4	MOVE.L	D2,10(A2)
	MOVE.W	6(A2),D0
	MOVE.W	$12(A2),D1
	MOVE.W	$1A(A3),D2
	MULS.W	D2,D1
	ASR.W	#7,D1
	MOVE.W	4(A6),D2
	SUBI.W	#$80,D2
	SUB.W	D2,D1
	ADDI.W	#$1000,D1
	MULU.W	D1,D0
	MOVEQ	#$13,D1
	LSR.L	D1,D0
	MOVE.W	D0,$12(A1)
	MOVE.W	0(A6),D0
	ADDQ.W	#1,D0
	MULU.W	8(A1),D0
	LSR.W	#8,D0
	ADDQ.W	#1,D0
	MULU.W	8(A3),D0
	LSR.W	#8,D0
	MOVE.L	10(A2),D1
	SWAP	D1
	MULU.W	D1,D0
	MOVEQ	#10,D1
	LSR.W	D1,D0
	MOVE.W	D0,$14(A1)
lbC00DD24	CLR.L	D0
	CMPI.W	#2,10(A1)
	BNE.S	lbC00DD30
	MOVEQ	#-1,D0
lbC00DD30	RTS

IFFTECH	BRA.L	lbC00DD88

	BRA.L	lbC00DD3A

lbC00DD3A	CLR.L	D0
	CMPI.W	#4,D7
	BGE.L	lbC00DD86
	TST.W	10(A1)
	BEQ.S	lbC00DD7A
	SUBI.W	#1,10(A1)
	BEQ.S	lbC00DD62
	MOVE.W	$10(A1),4(A2)
	MOVE.L	12(A1),0(A2)
	MOVEQ	#-1,D0
	BRA.S	lbC00DD7A

lbC00DD62	LEA	$1C2(A6),A3
	MOVE.W	D7,D1
	MULU.W	#10,D1
	ADDA.W	D1,A3
	MOVE.W	4(A3),4(A2)
	MOVE.L	0(A3),0(A2)
lbC00DD7A	MOVE.W	$12(A1),6(A2)
	MOVE.W	$14(A1),8(A2)
lbC00DD86	RTS

lbC00DD88	CMPI.W	#4,D7
	BLT.S	lbC00DD92
	CLR.L	D0
	RTS

lbC00DD92	MOVEA.L	4(A1),A3
	LEA	$1C2(A6),A2
	MOVE.W	D7,D0
	MULU.W	#10,D0
	ADDA.W	D0,A2
	MOVE.B	0(A1),D0
	BEQ.L	lbC00DE6E
	CMPI.B	#1,D0
	BNE.L	lbC00DE54
	LEA	$1A(A3),A5
	CLR.L	D1
	MOVE.B	3(A1),D1
	DIVU.W	#12,D1
	MOVE.W	D1,D2
	SWAP	D1
	ASL.W	#1,D1
	LEA	lbW00D4B2(PC),A0
	MOVE.W	#$D5C8,D0
	MULU.W	0(A0,D1.W),D0
	MOVEQ	#15,D1
	LSR.L	D1,D0
	MOVE.W	D0,6(A2)
	SUBI.W	#10,D2
	NEG.W	D2
	SUB.W	$18(A3),D2
	BPL.S	lbC00DDF8
lbC00DDE6	CLR.B	0(A1)
	CMPI.B	#0,1(A1)
	BEQ.L	lbC00DEA4
	BRA.L	lbC00DE6E

lbC00DDF8	CMP.B	$12(A3),D2
	BGE.S	lbC00DDE6
	MOVE.L	4(A3),D4
	MOVE.L	8(A3),D5
	MOVE.L	D4,D0
	ADD.L	D5,D0
	MOVE.L	D0,D1
	ASL.L	D2,D1
	SUB.L	D0,D1
	LEA	0(A5,D1.L),A0
	ASL.L	D2,D4
	ASL.L	D2,D5
	MOVE.W	D4,D0
	BNE.S	lbC00DE1E
	MOVE.W	D5,D0
lbC00DE1E	MOVE.L	A0,12(A1)
	LSR.W	#1,D0
	MOVE.W	D0,$10(A1)
	ADDA.W	D4,A0
	MOVE.W	D5,D0
	BNE.S	lbC00DE38
	MOVEA.L	$106(A6),A0
	ADDA.W	#$400,A0
	MOVEQ	#8,D0
lbC00DE38	MOVE.L	A0,0(A2)
	LSR.W	#1,D0
	MOVE.W	D0,4(A2)
	MOVE.W	#2,10(A1)
	BSR.L	lbC00D28E
	MOVE.W	#1,8(A2)
	BRA.S	lbC00DE6E

lbC00DE54	CMPI.B	#2,D0
	BNE.S	lbC00DE60
	CLR.W	8(A2)
	BRA.S	lbC00DE6E

lbC00DE60	CMPI.B	#3,D0
	BNE.S	lbC00DE6E
	BSR.L	lbC00D28E
	BRA.L	lbC00DEA4

lbC00DE6E	MOVE.W	#$1080,D0
	SUB.W	4(A6),D0
	MULU.W	6(A2),D0
	MOVEQ	#$13,D1
	LSR.L	D1,D0
	MOVE.W	D0,$12(A1)
	MOVE.W	0(A6),D0
	ADDQ.W	#1,D0
	MULU.W	8(A1),D0
	LSR.W	#8,D0
	ADDQ.W	#1,D0
	MOVE.L	$14(A3),D1
	LSR.L	#1,D1
	MULU.W	D1,D0
	MOVEQ	#$11,D1
	LSR.L	D1,D0
	MULU.W	8(A2),D0
	MOVE.W	D0,$14(A1)
lbC00DEA4	CLR.L	D0
	CMPI.W	#2,10(A1)
	BNE.S	lbC00DEB0
	MOVEQ	#-1,D0
lbC00DEB0	RTS

;	dc.w	$9D
;	dc.w	$FAFB
;	dc.w	$FFFD
;	dc.w	$FE02
;	dc.w	$DF1
;	dc.w	$112
;	dc.w	$144D
;COPYRIGHT	dc.b	'Sonix Music Driver (C) Copyright 1987 Mark R'
;	dc.b	'iley, All Rights Reserved.',0,0
;VERSION	dc.b	'Version 2.0b - July 19, 1988',0,0

;INITSONIX	MOVEM.L	D1-D7/A0-A6,-(SP)
;	LEA	SONIX(PC),A1
;	MOVE.L	(A1),D0
;	BNE.L	lbC00DF86
;	MOVE.L	A6,(A1)
;	MOVEA.L	A6,A1
;	MOVE.W	#$F4,D0
;lbC00DF3C	CLR.W	(A1)+
;	DBRA	D0,lbC00DF3C
;	MOVE.L	A0,$106(A6)
;	MOVE.W	#$203,D0
;lbC00DF4A	CLR.W	(A0)+
;	DBRA	D0,lbC00DF4A
;	MOVE.W	#$3F,$36(A6)
;	MOVE.W	#$8000,$22(A6)
;	MOVE.W	#$FF,0(A6)
;	MOVE.W	#$80,2(A6)
;	MOVE.W	#$80,4(A6)
;	MOVE.B	#$9C,$BFE401
;	MOVE.B	#$2E,$BFE501
;	MOVE.B	#$11,$BFEE01
;lbC00DF86	MOVE.L	SONIX(PC),D0
;	MOVEM.L	(SP)+,D1-D7/A0-A6
;	RTS

;QUITSONIX	MOVEM.L	D0-D7/A0-A6,-(SP)
;	MOVE.L	SONIX(PC),D0
;	BEQ.S	lbC00DFA2
;	MOVEA.L	D0,A6
;	BSR.L	STOPSOUND
;	BSR.S	lbC00DFA8
;lbC00DFA2	MOVEM.L	(SP)+,D0-D7/A0-A6
;	RTS

;lbC00DFA8	MOVEM.L	D0-D7/A0-A6,-(SP)
;	LEA	SONIX(PC),A0
;	MOVE.L	(A0),D0
;	BEQ.L	lbC00DFC0
;	MOVEA.L	D0,A6
;	CLR.L	(A0)
;	CLR.B	$BFEE01
;lbC00DFC0	MOVEM.L	(SP)+,D0-D7/A0-A6
;	RTS

;SONIX	dc.l	0

***************************************************************************
*************** Sonix Music Driver v2.0f player (SMUS format) *************
***************************************************************************

; Player from game "Vengeance Of Excalibur" (c) 1991 by Synergistic/Virgin

;	BRA.L	InitSONIX

;	BRA.L	QuitSONIX

;	BRA.L	PlaySCORE

;	BRA.L	ReleaseSCORE

;	BRA.L	StopSCORE

;	BRA.L	StartNOTE

;	BRA.L	ReleaseNOTE

;	BRA.L	StopNOTE

;	BRA.L	ReleaseSOUND

;	BRA.L	StopSOUND

;	BRA.L	RampVOLUME

;	BRA.L	StealTRACK

;	BRA.L	ResumeTRACK

;	BRA.L	LoadSCORE

;	BRA.L	PurgeSCORE

;	BRA.L	PurgeSCORES

;	BRA.L	LoadINSTRUMENT

;	BRA.L	PurgeINSTRUMENT

;	BRA.L	PurgeINSTRUMENTS

;	BRA.L	SonixLOAD

;	BRA.L	SonixALLOCATE

;	BRA.L	RELEASE

;	BRA.L	SonixSIGNAL

;	BRA.L	SonixWAIT

;	BRA.L	SetFILTER

;AllocatePATCH	dc.l	0
;ReleasePATCH	dc.l	0

;lbC00006C	MOVEM.L	D0/D1/A1-A3/A6,-(SP)
;	LEA	$29E(A6),A3
;	MOVE.L	A0,-(SP)
;	TST.L	(SP)+
;	BEQ.S	lbC000096
;	MOVEQ	#$3A,D0
;lbC00007C	MOVE.B	D0,D1
;	MOVE.B	(A0)+,D0
;	MOVE.B	D0,(A3)+
;	BNE.S	lbC00007C
;	SUBQ.L	#1,A3
;	CMPI.B	#$3A,D1
;	BEQ.S	lbC000096
;	CMPI.B	#$2F,D1
;	BEQ.S	lbC000096
;	MOVE.B	#$2F,(A3)+
;lbC000096	MOVE.B	(A1)+,(A3)+
;	BNE.S	lbC000096
;	MOVE.L	A2,-(SP)
;	TST.L	(SP)+
;	BEQ.S	lbC0000A6
;	SUBQ.L	#1,A3
;lbC0000A2	MOVE.B	(A2)+,(A3)+
;	BNE.S	lbC0000A2
;lbC0000A6	LEA	$29E(A6),A0
;	MOVEM.L	(SP)+,D0/D1/A1-A3/A6
;	RTS

;lbC0000B0	MOVEM.L	D1/D2/A0/A1/A6,-(SP)
;	MOVE.L	A0,D1
;	MOVE.L	D0,D2
;	MOVE.L	$18(A6),D0
;	BNE.S	lbC0000D0
;	MOVE.L	A6,-(SP)
;	MOVEA.L	$3EC(A6),A6
;	JSR	-$1E(A6)
;	MOVEA.L	(SP)+,A6
;lbC0000CA	MOVEM.L	(SP)+,D1/D2/A0/A1/A6
;	RTS

;lbC0000D0	MOVEA.L	D0,A0
;	JSR	(A0)
;	BRA.S	lbC0000CA

;lbC0000D6	MOVEM.L	D1/A0/A1/A6,-(SP)
;	MOVE.L	D0,D1
;	MOVE.L	$1C(A6),D0
;	BNE.S	lbC0000F4
;	MOVE.L	A6,-(SP)
;	MOVEA.L	$3EC(A6),A6
;	JSR	-$24(A6)
;	MOVEA.L	(SP)+,A6
;lbC0000EE	MOVEM.L	(SP)+,D1/A0/A1/A6
;	RTS

;lbC0000F4	MOVEA.L	D0,A0
;	JSR	(A0)
;	BRA.S	lbC0000EE

;lbC0000FA	MOVEM.L	D1-D3/A0/A1/A6,-(SP)
;	MOVE.L	D1,D3
;	MOVE.L	D0,D1
;	MOVE.L	A0,D2
;	MOVE.L	$20(A6),D0
;	BNE.S	lbC00011C
;	MOVE.L	A6,-(SP)
;	MOVEA.L	$3EC(A6),A6
;	JSR	-$2A(A6)
;	MOVEA.L	(SP)+,A6
;lbC000116	MOVEM.L	(SP)+,D1-D3/A0/A1/A6
;	RTS

;lbC00011C	MOVEA.L	D0,A0
;	JSR	(A0)
;	BRA.S	lbC000116

;lbC000122	MOVEM.L	D1/A0/A1/A6,-(SP)
;	MOVE.L	$24(A6),D0
;	BNE.S	lbC00013E
;	MOVE.L	A6,-(SP)
;	MOVEA.L	$3EC(A6),A6
;	JSR	-$42(A6)
;	MOVEA.L	(SP)+,A6
;lbC000138	MOVEM.L	(SP)+,D1/A0/A1/A6
;	RTS

;lbC00013E	MOVEA.L	D0,A0
;	JSR	(A0)
;	BRA.S	lbC000138

;LoadINSTRUMENT	MOVEM.L	D1-D7/A0-A6,-(SP)
;	MOVEA.L	A1,A4
;	CLR.L	D2
;	BCLR	#6,$30(A6)
;	LEA	$4A(A6),A5
;	SUBA.L	A3,A3
;	MOVEQ	#$3F,D7
;lbC00015A	MOVE.L	0(A5),D0
;	BNE.S	lbC000168
;	MOVE.L	A3,D0
;	BNE.S	lbC00017C
;	MOVEA.L	A5,A3
;	BRA.S	lbC00017C

;lbC000168	MOVEA.L	D0,A2
;	LEA	4(A2),A2
;	MOVE.L	A0,-(SP)
;	MOVE.L	A2,-(SP)
;	BSR.L	DOCMPSTR
;	ADDQ.L	#8,SP
;	BEQ.L	lbC000214
;lbC00017C	ADDQ.L	#6,A5
;	DBRA	D7,lbC00015A
;	MOVE.L	A3,D0
;	BEQ.L	lbC000222
;	MOVEA.L	D0,A5
;	EXG	A0,A1
;	LEA	instr.MSG(PC),A2
;	MOVEA.L	A0,A3
;	BSR.L	lbC00006C
;	MOVE.L	#$3ED,D0
;	BSR.L	lbC0000B0
;	MOVE.L	D0,D2
;	BNE.S	lbC0001C2
;	SUBA.L	A0,A0
;	BSR.L	lbC00006C
;	MOVE.L	#$3ED,D0
;	BSR.L	lbC0000B0
;	MOVE.L	D0,D2
;	BNE.S	lbC0001C2
;	BSET	#6,$30(A6)
;	BRA.L	lbC000228

;lbC0001C2	LEA	$32A(A6),A0
;	MOVEQ	#$20,D1
;	BSR.L	lbC0000FA
;	CMP.L	D1,D0
;	BNE.L	lbC000228
;	LEA	Synttech(PC),A4
;	TST.B	(A0)
;	BEQ.S	lbC0001F6
;lbC0001DA	MOVEA.L	A4,A2
;	ADDA.W	2(A4),A2
;	MOVE.L	A2,-(SP)
;	MOVE.L	A0,-(SP)
;	BSR.L	DOCMPSTR
;	ADDQ.L	#8,SP
;	BEQ.S	lbC0001F6
;	MOVE.W	0(A4),D0
;	BEQ.S	lbC000228
;	ADDA.W	D0,A4
;	BRA.S	lbC0001DA

;lbC0001F6	MOVEA.L	A3,A0
;	MOVE.L	D2,D0
;	JSR	4(A4)
;	MOVE.L	D0,D2
;	MOVE.L	A0,D0
;	BEQ.S	lbC000228
;	MOVE.L	A4,0(A0)
;	LEA	4(A0),A2
;lbC00020C	MOVE.B	(A1)+,(A2)+
;	BNE.S	lbC00020C
;	MOVE.L	A0,0(A5)
;lbC000214	ADDQ.W	#1,4(A5)
;lbC000218	MOVE.L	D2,D0
;	BEQ.S	lbC000220
;	BSR.L	lbC0000D6
;lbC000220	MOVE.L	A5,D0
;lbC000222	MOVEM.L	(SP)+,D1-D7/A0-A6
;	RTS

;lbC000228	SUBA.L	A5,A5
;	BRA.S	lbC000218

;PurgeINSTRUMENTS	MOVEM.L	D0-D7/A0-A6,-(SP)
;	LEA	$4A(A6),A0
;	MOVEQ	#$3F,D7
;lbC000236	CLR.W	4(A0)
;	BSR.S	PurgeINSTRUMENT
;	ADDQ.L	#6,A0
;	DBRA	D7,lbC000236
;	MOVEM.L	(SP)+,D0-D7/A0-A6
;	RTS

;PurgeINSTRUMENT	MOVEM.L	D0-D7/A0-A6,-(SP)
;	MOVE.L	A0,D0
;	BEQ.S	lbC000274
;	MOVEA.L	D0,A5
;	SUBQ.W	#1,4(A5)
;	BGT.S	lbC000274
;	MOVE.L	0(A5),D0
;	BEQ.S	lbC000270
;	MOVEA.L	D0,A0
;	BSR.L	lbC00027A
;	MOVEA.L	0(A0),A1
;	JSR	8(A1)
;	CLR.L	0(A5)
;lbC000270	CLR.W	4(A5)
;lbC000274	MOVEM.L	(SP)+,D0-D7/A0-A6
;	RTS

;lbC00027A	MOVEM.L	D0-D7/A0-A6,-(SP)
;	MOVE.L	A0,D0
;	BEQ.S	lbC0002A6
;	LEA	$1D2(A6),A1
;	CLR.B	D0
;lbC000288	CMPI.B	#0,1(A1)
;	BEQ.S	lbC00029A
;	CMPA.L	4(A1),A0
;	BNE.S	lbC00029A
;	BSR.L	StopNOTE
;lbC00029A	ADDA.W	#$16,A1
;	ADDQ.B	#1,D0
;	CMPI.B	#4,D0
;	BNE.S	lbC000288
;lbC0002A6	MOVEM.L	(SP)+,D0-D7/A0-A6
;	RTS

;instr.MSG	dc.b	'.instr',0,0

LoadSCORE	MOVEM.L	D1-D7/A0-A6,-(SP)
;	MOVE.L	SP,$34E(A6)
;	SUBA.L	A5,A5
;	ANDI.B	#$3F,$30(A6)
;	MOVE.L	A1,$34A(A6)
;	CLR.W	$35A(A6)
;	MOVE.L	#$3ED,D0
;	BSR.L	lbC0000B0
;	MOVE.L	D0,$352(A6)
;	BEQ.L	lbC00054E
;	MOVE.L	#$84,D0
;	MOVE.L	#$10001,D1
;	BSR.L	ALLOCATE
;	MOVE.L	A0,D0
;	BEQ.L	lbC00054E
;	MOVEA.L	A0,A5

	move.l	Sonix(PC),A6			; Buffer
	lea	1336(A6),A5			; Buffer2
	move.l	A0,A2

	LEA	$10(A5),A0
	MOVEQ	#3,D7
lbC0002FC	MOVE.W	#$FF,2(A0)
	ADDQ.L	#4,A0
	DBRA	D7,lbC0002FC
	BSR.L	lbC000562
;	CMPI.L	#'FORM',D0
;	BNE.L	lbC000554
	BSR.L	lbC000562
	SUBQ.L	#4,D0
	MOVE.L	D0,$356(A6)
	BSR.L	lbC000562
;	CMPI.L	#'SMUS',D0
;	BNE.L	lbC000554
lbC00032E	TST.L	$356(A6)
	BEQ.L	lbC000526
	BSR.L	lbC000562
	MOVE.L	D0,D7
	BSR.L	lbC000562
	ADDQ.L	#1,D0
	ANDI.W	#$FFFE,D0
	MOVE.L	D0,D6
	ADDQ.L	#8,D0
	SUB.L	D0,$356(A6)
	CMPI.L	#'SHDR',D7
	BEQ.S	lbC000388
	CMPI.L	#'INS1',D7
;	BEQ.L	lbC00041A

	beq.b	lbC00037C

	CMPI.L	#'TRAK',D7
	BEQ.L	lbC00048A
	CMPI.L	#'SNX1',D7
	BCS.S	lbC00037C
	CMPI.L	#'SNX:',D7
	BCS.L	lbC0003EC
lbC00037C	TST.L	D6
	BLE.S	lbC00032E
	BSR.L	lbC000576
	SUBQ.L	#1,D6
	BRA.S	lbC00037C

lbC000388	BSR.L	lbC00056C
	CMPI.W	#$E11,D0
	BCC.S	lbC000396
	CLR.W	D0
	BRA.S	lbC0003B4

lbC000396	MOVE.L	#$E100000,D1
	DIVU.W	D0,D1
	LEA	lbW000CAE(PC),A0
	CLR.W	D0
lbC0003A4	CMP.W	0(A0,D0.W),D1
	BCC.S	lbC0003B4
	ADDQ.W	#2,D0
	CMPI.W	#$100,D0
	BCS.S	lbC0003A4
	SUBQ.W	#1,D0
lbC0003B4	MOVE.W	D0,2(A5)
	BSR.L	lbC000576
	ANDI.W	#$FF,D0
	CMPI.W	#$80,D0
	BGE.S	lbC0003C8
	ASL.W	#1,D0
lbC0003C8	MOVE.W	D0,0(A5)
	LEA	$20(A5),A0
	BSR.L	lbC000576
	CMPI.B	#5,D0
	BCS.S	lbC0003DC
	MOVEQ	#4,D0
lbC0003DC	SUBQ.B	#1,D0
	BMI.S	lbC0003E8
	MOVE.L	#1,(A0)+
	BRA.S	lbC0003DC

lbC0003E8	SUBQ.L	#4,D6
	BRA.S	lbC00037C

lbC0003EC	BSR.L	lbC00056C
	MOVE.W	D0,4(A5)
	BSR.L	lbC00056C
	MOVE.W	D0,6(A5)
	BSR.L	lbC000562
	LEA	$20(A5),A0
	MOVEQ	#3,D7
lbC000406	BSR.L	lbC000562
	MOVE.L	D0,(A0)+
	DBRA	D7,lbC000406
	SUBI.L	#$18,D6
	BRA.L	lbC00037C

;lbC00041A	BSR.L	lbC000576
;	SUBQ.L	#1,D6
;	CMPI.B	#$40,D0
;	BCC.L	lbC00037C
;	LEA	$40(A5),A3
;	EXT.W	D0
;	ADDA.W	D0,A3
;	TST.B	(A3)
;	BNE.L	lbC00037C
;	BSR.L	lbC000576
;	SUBQ.L	#1,D6
;	TST.B	D0
;	BNE.L	lbC00037C
;	BSR.L	lbC00056C
;	SUBQ.L	#2,D6
;	LEA	$30A(A6),A0
;	MOVEQ	#$18,D7
;lbC00044E	BSR.L	lbC000576
;	MOVE.B	D0,(A0)+
;	SUBQ.L	#1,D6
;	BEQ.S	lbC00045C
;	DBRA	D7,lbC00044E
;lbC00045C	CLR.B	(A0)+
;	LEA	$30A(A6),A0
;	MOVEA.L	$34A(A6),A1
;	BSR.L	LoadINSTRUMENT
;	TST.L	D0
;	BNE.S	lbC000478
;	BSET	#7,$30(A6)
;	BRA.L	lbC000554

;lbC000478	LEA	$4A(A6),A0
;	SUB.L	A0,D0
;	DIVU.W	#6,D0
;	ADDQ.B	#1,D0
;	MOVE.B	D0,(A3)
;	BRA.L	lbC00037C

lbC00048A	MOVE.W	$35A(A6),D0
	CMPI.W	#4,D0
	BGE.L	lbC00037C
	ADDQ.W	#1,$35A(A6)
	ASL.W	#2,D0
	LEA	0(A5,D0.W),A4
;	MOVE.L	D6,D0
;	ADDQ.L	#2,D0
;	MOVE.L	#1,D1
;	BSR.L	ALLOCATE
;	MOVE.L	A0,$30(A4)
;	BEQ.L	lbC000554
;	MOVE.L	D6,D0
;	BSR.L	lbC00058C
;	MOVE.W	#$FFFF,0(A0,D0.L)
;	CLR.L	D6

	lea	-2(A2),A1
	move.l	A1,A0
	move.l	A1,$30(A4)
CopyTrack
	move.b	(A2)+,(A1)+
	subq.l	#1,D6
	bne.b	CopyTrack
	move.w	#-1,(A1)

lbC0004C4	MOVE.W	(A0),D0
	CMPI.W	#$FFFF,D0
	BEQ.L	lbC00037C
	MOVE.W	D0,D1
	ANDI.W	#$FF00,D1
	CMPI.W	#$8100,D1
	BEQ.S	lbC000522
	BCC.S	lbC0004EE
	LEA	lbW0007C2(PC),A1
	ANDI.W	#15,D0
	MOVE.B	0(A1,D0.W),D0
	BMI.S	lbC000520
	OR.W	D1,D0
	BRA.S	lbC000522

lbC0004EE	CMPI.W	#$8200,D1
	BNE.S	lbC000510
	MOVE.W	D0,D1
	LSR.W	#3,D1
	ANDI.W	#$1F,D1
	ADDQ.W	#1,D1
	MOVE.W	D1,8(A5)
	ANDI.W	#7,D0
	CLR.W	D1
	BSET	D0,D1
	MOVE.W	D1,10(A5)
	BRA.S	lbC000520

lbC000510	CMPI.W	#$8400,D1
	BNE.S	lbC000520
	ANDI.W	#$7F,D0
	ASL.W	#1,D0
	MOVE.W	D0,$12(A4)
lbC000520	CLR.W	D0
lbC000522	MOVE.W	D0,(A0)+
	BRA.S	lbC0004C4

lbC000526
;	LEA	$368(A6),A0
;lbC00052A	MOVE.L	(A0),D0
;	BEQ.S	lbC000536
;	MOVEA.L	D0,A0
;	LEA	$80(A0),A0
;	BRA.S	lbC00052A

;lbC000536	MOVE.L	A5,(A0)
;lbC000538	MOVE.L	$352(A6),D0
;	BEQ.S	lbC000546
;	BSR.L	lbC0000D6
;	CLR.L	$352(A6)
;lbC000546	MOVE.L	A5,D0
	MOVEM.L	(SP)+,D1-D7/A0-A6
	RTS

;lbC00054E	BSET	#6,$30(A6)
;lbC000554	MOVEA.L	$34E(A6),SP
;	MOVEA.L	A5,A0
;	BSR.L	PurgeSCORE
;	SUBA.L	A5,A5
;	BRA.S	lbC000538

lbC000562
;	MOVEQ	#4,D0
;	CLR.L	-(SP)
;	BSR.S	lbC000580
;	MOVE.L	(SP)+,D0

	move.l	(A2)+,D0

	RTS

lbC00056C
;	MOVEQ	#2,D0
;	CLR.W	-(SP)
;	BSR.S	lbC000580
;	MOVE.W	(SP)+,D0

	move.w	(A2)+,D0

	RTS

lbC000576
;	MOVEQ	#1,D0
;	CLR.B	-(SP)
;	BSR.S	lbC000580
;	MOVE.B	(SP)+,D0

	move.b	(A2)+,D0

	RTS

;lbC000580	MOVE.L	A0,-(SP)
;	LEA	8(SP),A0
;	BSR.S	lbC00058C
;	MOVEA.L	(SP)+,A0
;	RTS

;lbC00058C	MOVEM.L	D0/D1,-(SP)
;	MOVE.L	D0,D1
;	MOVE.L	$352(A6),D0
;	BSR.L	lbC0000FA
;	CMP.L	D1,D0
;	BNE.S	lbC000554
;	MOVEM.L	(SP)+,D0/D1
;	RTS

;PurgeSCORES	MOVEM.L	D0-D7/A0-A6,-(SP)
;lbC0005A8	MOVE.L	$368(A6),D0
;	BEQ.S	lbC0005B4
;	MOVEA.L	D0,A0
;	BSR.S	PurgeSCORE
;	BRA.S	lbC0005A8

;lbC0005B4	MOVEM.L	(SP)+,D0-D7/A0-A6
;	RTS

;PurgeSCORE	MOVEM.L	D0-D7/A0-A6,-(SP)
;	MOVE.L	A0,D0
;	BEQ.L	lbC000628
;	MOVEA.L	D0,A5
;	CMPA.L	6(A6),A5
;	BNE.S	lbC0005D8
;	BSR.L	StopSCORE
;	CLR.L	6(A6)
;	CLR.W	$32(A6)
;lbC0005D8	LEA	$40(A5),A1
;	MOVEQ	#$3F,D7
;lbC0005DE	MOVE.B	(A1)+,D0
;	BEQ.S	lbC0005F4
;	SUBQ.B	#1,D0
;	LEA	$4A(A6),A0
;	EXT.W	D0
;	MULU.W	#6,D0
;	ADDA.W	D0,A0
;	BSR.L	PurgeINSTRUMENT
;lbC0005F4	DBRA	D7,lbC0005DE
;	LEA	$30(A5),A1
;	MOVEQ	#3,D7
;lbC0005FE	MOVEA.L	(A1)+,A0
;	BSR.L	RELEASE
;	DBRA	D7,lbC0005FE
;	MOVEA.L	$80(A5),A1
;	LEA	$368(A6),A0
;lbC000610	MOVE.L	(A0),D0
;	BEQ.S	lbC000622
;	CMP.L	A5,D0
;	BEQ.S	lbC000620
;	MOVEA.L	D0,A0
;	LEA	$80(A0),A0
;	BRA.S	lbC000610

;lbC000620	MOVE.L	A1,(A0)
;lbC000622	MOVEA.L	A5,A0
;	BSR.L	RELEASE
;lbC000628	MOVEM.L	(SP)+,D0-D7/A0-A6
;	RTS

;ReleaseSCORE	MOVEM.L	D0/D1,-(SP)
;	CLR.W	$1D0(A6)
;	BSET	#0,$30(A6)
;	TST.W	D0
;	BNE.S	lbC000642
;	MOVEQ	#1,D0
;lbC000642	CLR.W	D1
;	BSR.L	RampVOLUME
;	MOVEM.L	(SP)+,D0/D1
;	RTS

PlaySCORE	MOVEM.L	D0-D7/A0-A6,-(SP)
	BSR.L	StopSCORE
	MOVE.L	A0,D4
	BEQ.S	lbC0006AA
	MOVEA.L	D4,A5
	CMP.L	D0,D1
	BEQ.S	lbC0006AA
	BCS.S	lbC0006AA
	MOVE.L	D0,12(A6)
	MOVE.L	D1,$14(A6)
	LEA	$20(A5),A0
	LEA	$3A(A6),A1
	MOVEQ	#3,D7
lbC000674	MOVE.L	(A0)+,(A1)+
	DBRA	D7,lbC000674
	MOVEA.L	A5,A0
	BSR.L	lbC0006E4
	BSR.L	lbC000754
	CLR.W	$32(A6)
	MOVE.L	A5,6(A6)
	CLR.W	0(A6)
	MOVE.W	2(A5),2(A6)
	MOVE.W	6(A5),4(A6)
	MOVE.W	0(A5),D1
	MOVE.W	D3,D0
	BSR.L	RampVOLUME
	MOVE.W	D2,10(A6)
lbC0006AA	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTS

StopSCORE	CLR.L	$360(A6)
	BCLR	#0,$30(A6)
lbC0006BA	MOVEM.L	D0/A0,-(SP)
	TST.W	10(A6)
	BEQ.S	lbC0006DE
	CLR.W	10(A6)
	LEA	$3A(A6),A0
	CLR.B	D0
lbC0006CE	TST.L	(A0)+
	BEQ.S	lbC0006D6
	BSR.L	ReleaseNOTE
lbC0006D6	ADDQ.B	#1,D0
	CMPI.B	#4,D0
	BNE.S	lbC0006CE
lbC0006DE	MOVEM.L	(SP)+,D0/A0
	RTS

lbC0006E4	MOVEM.L	D0-D7/A0-A6,-(SP)
	MOVEA.L	A0,A3
	LEA	$25A(A6),A1
	MOVE.L	D0,D6
	CLR.B	D7
lbC0006F2	CLR.L	0(A1)
	CLR.B	$10(A1)
	CLR.B	$11(A1)
	MOVE.L	$30(A0),D0
	BEQ.S	lbC000742
	MOVEA.L	D0,A2
	MOVE.L	D6,D5
lbC000708	MOVE.L	A2,0(A1)
	TST.L	D5
	BLE.S	lbC000742
	MOVE.W	(A2)+,D0
	BEQ.S	lbC000708
	CMPI.W	#$FFFF,D0
	BEQ.S	lbC000742
	CMPI.W	#$8200,D0
	BCC.S	lbC000708
	CMPI.W	#$8100,D0
	BCC.S	lbC00073A
	ANDI.L	#$FF,D0
	SUB.L	D0,D5
	BPL.S	lbC000708
	MOVE.L	D5,D0
	NEG.L	D0
	MOVE.B	D0,$11(A1)
	BRA.S	lbC000708

lbC00073A	ADDQ.B	#1,D0
	MOVE.B	D0,$10(A1)
	BRA.S	lbC000708

lbC000742	ADDQ.L	#4,A0
	ADDQ.L	#4,A1
	ADDQ.B	#1,D7
	CMPI.B	#4,D7
	BNE.S	lbC0006F2
	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTS

lbC000754	MOVEM.L	D0-D7/A0-A6,-(SP)
	LEA	$25A(A6),A2
	LEA	$27A(A6),A1
	MOVEQ	#7,D7
lbC000762	MOVE.L	(A2)+,(A1)+
	DBRA	D7,lbC000762
	MOVE.L	12(A6),$10(A6)
	MOVEA.L	A6,A4
	CLR.B	D7
lbC000772	TST.L	$3A(A4)
	BEQ.S	lbC00077E
	MOVE.B	D7,D0
	BSR.L	ReleaseNOTE
lbC00077E	CLR.L	$23A(A4)
	CLR.L	D0
	MOVE.B	$28B(A4),D0
	ADDQ.B	#1,D0
	MOVE.L	D0,$24A(A4)
	MOVE.B	$28A(A4),D0
	BEQ.S	lbC0007AC
	SUBQ.B	#1,D0
	LEA	$40(A0),A3
	MOVE.B	0(A3,D0.W),D0
	BEQ.S	lbC0007AC
	SUBQ.B	#1,D0
	MULU.W	#6,D0
	LEA	$4A(A6),A3
	ADD.L	A3,D0
lbC0007AC	MOVE.L	D0,$22A(A4)
	ADDQ.L	#4,A0
	ADDQ.L	#4,A4
	ADDQ.B	#1,D7
	CMPI.B	#4,D7
	BCS.S	lbC000772
	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTS

lbW0007C2	dc.w	$2010
	dc.w	$804
	dc.w	$2FF
	dc.w	$FFFF
	dc.w	$3018
	dc.w	$C06
	dc.w	$3FF
	dc.w	$FFFF

PlaySMUS
;lbC0007D2	MOVEM.L	D0-D7/A0-A6,-(SP)
;	MOVEA.L	A1,A6
;	MOVE.L	$2C(A6),D0
;	BEQ.S	lbC0007E2
;	MOVEA.L	D0,A0
;	JSR	(A0)
lbC0007E2	BSR.L	lbC000C12
	BSR.S	lbC000846
	BSR.L	lbC0009B0
;	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTS

lbC0007F2	MOVEM.L	D1/D2/A0,-(SP)
	LSR.W	#1,D0
	CMP.W	$34(A6),D0
	BEQ.S	lbC000840
	MOVE.W	D0,$34(A6)
	ASL.W	#1,D0
	LEA	lbW000CAE(PC),A0
	MOVE.W	0(A0,D0.W),D1
	MOVE.W	D1,D2
	MOVEQ	#12,D0
	LSR.W	D0,D2
	MOVE.W	D2,$38(A6)
	ASL.W	D0,D2
	SWAP	D1
	CLR.W	D1
	LSR.L	#1,D1
	DIVU.W	D2,D1
	MOVE.W	D1,$36(A6)
	MULU.W	#$2E9C,D1
	MOVEQ	#15,D0
	LSR.L	D0,D1
;	MOVEA.L	$3F0(A6),A0
;	MOVE.B	D1,(A0)
;	LSR.W	#8,D1
;	MOVE.B	D1,$100(A0)
;	MOVEA.L	$3F4(A6),A0
;	MOVE.B	#$11,(A0)

	movem.l	A1/A5,-(SP)
	move.l	EagleBase(PC),A5
	move.w	D1,dtg_Timer(A5)
	move.l	dtg_SetTimer(A5),A1
	jsr	(A1)
	movem.l	(SP)+,A1/A5

lbC000840	MOVEM.L	(SP)+,D1/D2/A0
	RTS

lbC000846	TST.W	$32(A6)
	BEQ.S	lbC000854
	SUBQ.W	#1,$32(A6)
	BNE.L	lbC00097C
lbC000854	MOVE.W	2(A6),D0
	BSR.S	lbC0007F2
	TST.W	10(A6)
	BEQ.L	lbC00097C
	MOVE.W	$38(A6),$32(A6)
	MOVEA.L	6(A6),A2
	CLR.W	D6
lbC00086E	MOVEA.L	A2,A1
	MOVEA.L	A6,A5
	CLR.B	D7
lbC000874	TST.L	$23A(A5)
	BEQ.S	lbC000890
	SUBQ.L	#1,$23A(A5)
	BNE.S	lbC00088C
	TST.L	$3A(A5)
	BEQ.S	lbC00088C
	MOVE.B	D7,D0
	BSR.L	ReleaseNOTE
lbC00088C	BRA.L	lbC000934

lbC000890	TST.L	$24A(A5)
	BEQ.S	lbC00089C
	SUBQ.L	#1,$24A(A5)
	BNE.S	lbC00088C
lbC00089C	MOVE.L	$27A(A5),D0
	BNE.S	lbC0008A6
lbC0008A2	ADDQ.W	#1,D6
	BRA.S	lbC00088C

lbC0008A6	MOVEA.L	D0,A0
lbC0008A8	MOVE.W	(A0)+,D2
	BEQ.S	lbC0008A8
	CMPI.W	#$FFFF,D2
	BEQ.S	lbC0008A2
	MOVE.L	A0,$27A(A5)
	MOVE.W	D2,D3
	LSR.W	#8,D2
	ANDI.W	#$FF,D3
	TST.B	D2
	BPL.S	lbC0008EE
	CMPI.B	#$80,D2
	BEQ.L	lbC000930
	CMPI.B	#$81,D2
	BNE.S	lbC0008A8
	CLR.L	D0
	LEA	$40(A2),A3
	MOVE.B	0(A3,D3.W),D0
	BEQ.S	lbC0008E8
	SUBQ.B	#1,D0
	MULU.W	#6,D0
	LEA	$4A(A6),A3
	ADD.L	A3,D0
lbC0008E8	MOVE.L	D0,$22A(A5)
	BRA.S	lbC0008A8

lbC0008EE	TST.L	$3A(A5)
	BEQ.S	lbC000930
	MOVE.L	$22A(A5),D0
	BNE.S	lbC000900
	MOVE.L	12(A2),D0
	BEQ.S	lbC000930
lbC000900	MOVEA.L	D0,A0
	MOVE.W	4(A2),D1
	ASR.W	#4,D1
	SUBI.W	#8,D1
	ADD.W	D2,D1
	MOVE.B	D7,D0
	MOVE.W	$12(A1),D2
	CMPI.W	#1,$3C(A5)
	BEQ.S	_StartNOTE
	LSR.W	#1,D2
_StartNOTE	BSR.L	StartNOTE
	MOVE.W	D3,D0
	MULU.W	#$C000,D0
	SWAP	D0
	MOVE.W	D0,$23C(A5)
	SUB.W	D0,D3
lbC000930	MOVE.W	D3,$24C(A5)
lbC000934	ADDQ.L	#4,A1
	ADDQ.L	#4,A5
	ADDQ.B	#1,D7
	CMPI.B	#4,D7
	BNE.L	lbC000874
	MOVE.L	$10(A6),D0
	ADDQ.L	#1,$10(A6)
;	CMP.L	$364(A6),D0
;	BNE.S	lbC000952
;	BSR.S	lbC000990
lbC000952	MOVE.L	$14(A6),D1
	BPL.S	lbC000960
	CMPI.W	#4,D6
	BNE.S	lbC00097C
	BRA.S	lbC000964

lbC000960	CMP.L	D1,D0
	BNE.S	lbC00097C
lbC000964
;	TST.W	10(A6)
;	BMI.S	lbC000970
;	SUBQ.W	#1,10(A6)
;	BEQ.S	lbC00097C
lbC000970

	bsr.w	SongEnd

	MOVEA.L	A2,A0
	BSR.L	lbC000754
	ADDQ.W	#1,D6
	BRA.L	lbC00086E

lbC00097C
;	TST.W	10(A6)
;	BNE.S	lbC00098E
;	TST.L	$360(A6)
;	BEQ.S	lbC00098E
;	BSR.S	lbC000990
;	CLR.L	$360(A6)
lbC00098E	RTS

;lbC000990	MOVEM.L	D0/D1/A0/A1,-(SP)
;	MOVE.L	$360(A6),D0
;	BEQ.S	lbC0009AA
;	MOVEA.L	$35C(A6),A1
;	MOVE.L	A6,-(SP)
;	MOVEA.L	4,A6
;	JSR	-$144(A6)
;	MOVEA.L	(SP)+,A6
;lbC0009AA	MOVEM.L	(SP)+,D0/D1/A0/A1
;	RTS

lbC0009B0	CLR.W	D6
	CLR.L	D7
	MOVEA.L	6(A6),A0
	LEA	$1D2(A6),A1
lbC0009BC	TST.B	0(A1)
	BNE.S	lbC0009CA
	CMPI.B	#0,1(A1)
	BEQ.S	lbC0009E8
lbC0009CA	MOVE.L	4(A1),D0
	BEQ.S	lbC0009FC
	MOVEA.L	D0,A4
	MOVEA.L	0(A4),A4
	MOVEM.L	D6/D7/A0/A1/A6,-(SP)
	JSR	12-12(A4)
	MOVEM.L	(SP)+,D6/D7/A0/A1/A6
	TST.L	D0
	BEQ.S	lbC0009E8
	BSET	D7,D6
lbC0009E8	MOVEQ	#1,D0
	CMPI.B	#1,0(A1)
	BEQ.S	lbC0009FC
	MOVEQ	#2,D0
	CMPI.B	#2,0(A1)
	BNE.S	lbC000A00
lbC0009FC	MOVE.B	D0,1(A1)
lbC000A00	CLR.B	0(A1)
	ADDA.W	#$16,A1
	ADDQ.W	#1,D7
	CMPI.W	#4,D7
	BNE.S	lbC0009BC
;	MOVE.W	D6,$DFF096

	move.l	D0,-(SP)
	move.w	D6,D0
	bsr.w	PokeDMA
	move.l	(SP)+,D0

	MOVE.W	#$8000,D6
	CLR.L	D7
	LEA	$1D2(A6),A1
	LEA	$DFF0A0,A2
lbC000A26	CMPI.B	#0,1(A1)
	BEQ.S	lbC000A48
	MOVEA.L	4(A1),A4
	MOVEA.L	0(A4),A4
	MOVEM.L	D6/D7/A0-A2/A6,-(SP)
	JSR	$10-12(A4)
	MOVEM.L	(SP)+,D6/D7/A0-A2/A6
	TST.L	D0
	BEQ.S	lbC000A48
	BSET	D7,D6
lbC000A48	ADDA.W	#$10,A2
	ADDA.W	#$16,A1
	ADDQ.W	#1,D7
	CMPI.W	#4,D7
	BNE.S	lbC000A26
;	MOVE.W	D6,$DFF096

	move.l	D0,-(SP)
	move.w	D6,D0
	bsr.w	PokeDMA
	move.l	(SP)+,D0

	RTS

lbC000A60	CLR.W	D0
	BSET	D7,D0
;	MOVE.W	D0,$DFF096

	bsr.w	PokeDMA

	MOVE.W	D7,D0
	ASL.W	#4,D0
	LEA	$DFF0A0,A0
;	MOVE.W	#2,6(A0,D0.W)

	movem.l	D0/A2,-(SP)
	lea	(A0,D0.W),A2
	moveq	#2,D0
	bsr.w	PokePer
	movem.l	(SP)+,D0/A2

	RTS

StartNOTE	MOVEM.L	D1-D7/A0-A6,-(SP)
	MOVE.L	A0,D3
	BEQ.L	lbC000B2C
	MOVE.L	0(A0),D3
	BEQ.L	lbC000B2C
	MOVEA.L	D3,A0
	MOVEA.L	6(A6),A5
	LEA	$1D2(A6),A1
	EXT.W	D0
	BPL.L	lbC000AEA
	MOVE.B	#0,D5
	MOVEQ	#4,D7
lbC000AA4	MOVE.W	D7,D6
	MOVE.W	$1CA(A6),D0
lbC000AAA	ADDQ.W	#1,D0
	CMP.W	D7,D0
	BCS.S	lbC000AB2
	CLR.W	D0
lbC000AB2	MOVE.W	D0,D3
	MULU.W	#$16,D3
	TST.B	0(A1,D3.W)
	BNE.S	lbC000AC4
	CMP.B	1(A1,D3.W),D5
	BEQ.S	lbC000AD6
lbC000AC4	SUBQ.W	#1,D6
	BNE.S	lbC000AAA
	CMPI.B	#0,D5
	BNE.L	lbC000B2C
	MOVE.B	#2,D5
	BRA.S	lbC000AA4

lbC000AD6	TST.W	10(A6)
	BEQ.S	lbC000AE6
	MOVE.W	D0,D3
	ASL.W	#2,D3
	TST.L	$3A(A6,D3.W)
	BNE.S	lbC000AC4
lbC000AE6	MOVE.W	D0,$1CA(A6)
lbC000AEA	MOVE.W	D0,D3
	MULU.W	#$16,D3
	ADDA.W	D3,A1
	CMPI.B	#0,1(A1)
	BEQ.S	lbC000B0E
	MOVEA.L	0(A0),A2
	MOVEA.L	4(A1),A3
	MOVEA.L	0(A3),A3
	CMPA.L	A3,A2
	BEQ.S	lbC000B0E
	BSR.L	StopNOTE
lbC000B0E	MOVE.L	A0,4(A1)
	MOVE.B	D1,3(A1)
	ANDI.W	#$FF,D2
	MOVE.W	D2,8(A1)
	MOVE.B	#1,0(A1)
	EXT.L	D0
lbC000B26	MOVEM.L	(SP)+,D1-D7/A0-A6
	RTS

lbC000B2C	MOVEQ	#-1,D0
	BRA.S	lbC000B26

;ReleaseSOUND	MOVE.L	D0,-(SP)
;	CLR.L	$360(A6)
;	CLR.W	10(A6)
;	MOVEQ	#3,D0
;lbC000B3C	BSR.S	ReleaseNOTE
;	DBRA	D0,lbC000B3C
;	MOVE.L	(SP)+,D0
;	RTS

ReleaseNOTE	MOVEM.L	D0/A1,-(SP)
	LEA	$1D2(A6),A1
	EXT.W	D0
	MULU.W	#$16,D0
	ADDA.W	D0,A1
	CLR.B	0(A1)
	CMPI.B	#1,1(A1)
	BNE.S	lbC000B68
	MOVE.B	#2,0(A1)
lbC000B68	MOVEM.L	(SP)+,D0/A1
	RTS

;StopSOUND	MOVE.L	D0,-(SP)
;	CLR.L	$360(A6)
;	CLR.W	10(A6)
;	MOVEQ	#3,D0
;lbC000B7A	BSR.S	StopNOTE
;	DBRA	D0,lbC000B7A
;	MOVE.L	(SP)+,D0
;	RTS

StopNOTE	MOVEM.L	D0/D7/A0/A1,-(SP)
	MOVEA.L	6(A6),A0
	LEA	$1D2(A6),A1
	EXT.W	D0
	MOVE.W	D0,D7
	MULU.W	#$16,D0
	ADDA.W	D0,A1
	CLR.B	0(A1)
	CMPI.B	#0,1(A1)
	BEQ.S	lbC000BCE
	MOVE.B	#3,0(A1)
	MOVE.L	4(A1),D0
	BEQ.S	lbC000BC4
	MOVEM.L	D0-D7/A0-A6,-(SP)
	MOVEA.L	D0,A4
	MOVEA.L	0(A4),A4
	JSR	12-12(A4)
	MOVEM.L	(SP)+,D0-D7/A0-A6
lbC000BC4	MOVE.B	#0,1(A1)
	CLR.B	0(A1)
lbC000BCE	MOVEM.L	(SP)+,D0/D7/A0/A1
	RTS

RampVOLUME	MOVEM.L	D1/D2/A0,-(SP)
	MOVEA.L	6(A6),A0
	CLR.W	$1D0(A6)
	TST.W	D0
	BEQ.S	lbC000C0C
	MOVEQ	#0,D2
	MOVE.W	0(A6),D2
	ASL.W	#8,D2
	MOVE.W	D2,$1CC(A6)
	ASL.W	#8,D1
	SUB.W	D1,D2
	BCC.S	lbC000BF8
	NEG.W	D2
lbC000BF8	DIVU.W	D0,D2
	SWAP	D1
	MOVE.W	D2,D1
	BNE.S	lbC000C02
	ADDQ.W	#1,D1
lbC000C02	MOVE.L	D1,$1CE(A6)
lbC000C06	MOVEM.L	(SP)+,D1/D2/A0
	RTS

lbC000C0C	MOVE.W	D1,0(A6)
	BRA.S	lbC000C06

lbC000C12	MOVE.W	$1D0(A6),D0
	BEQ.S	lbC000C44
	MULU.W	$36(A6),D0
	ASL.L	#1,D0
	BCS.S	lbC000C46
	SWAP	D0
	MOVE.W	D0,D3
	MOVE.W	$1CC(A6),D1
	MOVE.W	$1CE(A6),D2
	SUB.W	D1,D2
	BCC.S	lbC000C34
	NEG.W	D3
	NEG.W	D2
lbC000C34	CMP.W	D2,D0
	BCC.S	lbC000C46
	ADD.W	D3,D1
	MOVE.W	D1,$1CC(A6)
lbC000C3E	LSR.W	#8,D1
	MOVE.W	D1,0(A6)
lbC000C44	RTS

lbC000C46	MOVE.W	$1CE(A6),D1
	BNE.S	lbC000C58
	BCLR	#0,$30(A6)
	BEQ.S	lbC000C58
	BSR.L	lbC0006BA
lbC000C58	CLR.W	$1D0(A6)
	BRA.S	lbC000C3E

;StealTRACK	MOVEM.L	D1/A0,-(SP)
;	CLR.W	D1
;	MOVE.B	D0,D1
;	ASL.W	#2,D1
;	LEA	$3C(A6,D1.W),A0
;	TST.W	(A0)
;	BEQ.S	lbC000C76
;	BSR.L	StopNOTE
;	CLR.W	(A0)
;lbC000C76	MOVEM.L	(SP)+,D1/A0
;	RTS

;ResumeTRACK	MOVEM.L	D0/A0,-(SP)
;	EXT.W	D0
;	ASL.W	#2,D0
;	MOVEA.L	6(A6),A0
;	MOVE.W	$22(A0,D0.W),$3C(A6,D0.W)
;	MOVEM.L	(SP)+,D0/A0
;	RTS

lbW01EB58
lbW00D4B2
lbW000C94	dc.w	$8000
	dc.w	$78D1
	dc.w	$7209
	dc.w	$6BA2
	dc.w	$6598
	dc.w	$5FE4
	dc.w	$5A82
	dc.w	$556E
	dc.w	$50A3
	dc.w	$4C1C
	dc.w	$47D6
	dc.w	$43CE
	dc.w	$4000
lbW00D4CC
lbW000CAE	dc.w	$FA83
	dc.w	$F525
	dc.w	$EFE4
	dc.w	$EAC0
	dc.w	$E5B9
	dc.w	$E0CC
	dc.w	$DBFB
	dc.w	$D744
	dc.w	$D2A8
	dc.w	$CE24
	dc.w	$C9B9
	dc.w	$C567
	dc.w	$C12C
	dc.w	$BD08
	dc.w	$B8FB
	dc.w	$B504
	dc.w	$B123
	dc.w	$AD58
	dc.w	$A9A1
	dc.w	$A5FE
	dc.w	$A270
	dc.w	$9EF5
	dc.w	$9B8D
	dc.w	$9837
	dc.w	$94F4
	dc.w	$91C3
	dc.w	$8EA4
	dc.w	$8B95
	dc.w	$8898
	dc.w	$85AA
	dc.w	$82CD
	dc.w	$8000
	dc.w	$7D41
	dc.w	$7A92
	dc.w	$77F2
	dc.w	$7560
	dc.w	$72DC
	dc.w	$7066
	dc.w	$6DFD
	dc.w	$6BA2
	dc.w	$6954
	dc.w	$6712
	dc.w	$64DC
	dc.w	$62B3
	dc.w	$6096
	dc.w	$5E84
	dc.w	$5C7D
	dc.w	$5A82
	dc.w	$5891
	dc.w	$56AC
	dc.w	$54D0
	dc.w	$52FF
	dc.w	$5138
	dc.w	$4F7A
	dc.w	$4DC6
	dc.w	$4C1B
	dc.w	$4A7A
	dc.w	$48E1
	dc.w	$4752
	dc.w	$45CA
	dc.w	$444C
	dc.w	$42D5
	dc.w	$4166
	dc.w	$4000
	dc.w	$3EA0
	dc.w	$3D49
	dc.w	$3BF9
	dc.w	$3AB0
	dc.w	$396E
	dc.w	$3833
	dc.w	$36FE
	dc.w	$35D1
	dc.w	$34AA
	dc.w	$3389
	dc.w	$326E
	dc.w	$3159
	dc.w	$304B
	dc.w	$2F42
	dc.w	$2E3E
	dc.w	$2D41
	dc.w	$2C48
	dc.w	$2B56
	dc.w	$2A68
	dc.w	$297F
	dc.w	$289C
	dc.w	$27BD
	dc.w	$26E3
	dc.w	$260D
	dc.w	$253D
	dc.w	$2470
	dc.w	$23A9
	dc.w	$22E5
	dc.w	$2226
	dc.w	$216A
	dc.w	$20B3
	dc.w	$2000
	dc.w	$1F50
	dc.w	$1EA4
	dc.w	$1DFC
	dc.w	$1D58
	dc.w	$1CB7
	dc.w	$1C19
	dc.w	$1B7F
	dc.w	$1AE8
	dc.w	$1A55
	dc.w	$19C4
	dc.w	$1937
	dc.w	$18AC
	dc.w	$1825
	dc.w	$17A1
	dc.w	$171F
	dc.w	$16A0
	dc.w	$1624
	dc.w	$15AB
	dc.w	$1534
	dc.w	$14BF
	dc.w	$144E
	dc.w	$13DE
	dc.w	$1371
	dc.w	$1306
	dc.w	$129E
	dc.w	$1238
	dc.w	$11D4
	dc.w	$1172
	dc.w	$1113
	dc.w	$10B5
	dc.w	$1059
	dc.w	$1000
Synttech
;	dc.w	SStech-Synttech
;	dc.w	Synthesis.MSG-Synttech

;	BRA.L	lbC000DC2

;	BRA.L	lbC000E02

	BRA.L	lbC000E4E

	BRA.L	lbC000E24

;lbC000DC2	MOVEM.L	D0-D7/A1-A6,-(SP)
;	MOVE.L	D0,D3
;	MOVE.L	#$1DA,D0
;	MOVE.L	#$10001,D1
;	BSR.L	ALLOCATE
;	MOVE.L	A0,D0
;	BEQ.S	lbC000DF6
;	MOVE.L	D3,D0
;	MOVE.L	#$1D6,D1
;	BSR.L	lbC0000FA
;	CMP.L	D1,D0
;	BNE.S	lbC000DFC
;	BSR.L	SetFILTER
;	TST.L	$1D6(A0)
;	BEQ.S	lbC000DFC
;lbC000DF6	MOVEM.L	(SP)+,D0-D7/A1-A6
;	RTS

;lbC000DFC	BSR.S	lbC000E02
;	SUBA.L	A0,A0
;	BRA.S	lbC000DF6

;lbC000E02	MOVEM.L	D0-D7/A0-A6,-(SP)
;	MOVE.L	$1D6(A0),D0
;	BSR.L	RELEASE
;	TST.L	D0
;	BEQ.S	lbC000E1E
;	MOVEA.L	D0,A0
;	SUBQ.W	#1,$2000(A0)
;	BNE.S	lbC000E1E
;	BSR.L	RELEASE
;lbC000E1E	MOVEM.L	(SP)+,D0-D7/A0-A6
;	RTS

lbC000E24	CLR.L	D0
	CMPI.W	#4,D7
	BGE.S	lbC000E4C
;	MOVE.L	12(A1),0(A2)
;	MOVE.W	$10(A1),4(A2)
;	MOVE.W	$12(A1),6(A2)
;	MOVE.W	$14(A1),8(A2)

	move.l	D0,-(SP)
	move.l	12(A1),D0
	bsr.w	PokeAdr
	move.w	$10(A1),D0
	bsr.w	PokeLen
	move.w	$12(A1),D0
	bsr.w	PokePer
	move.w	$14(A1),D0
	bsr.w	PokeVol
	move.l	(SP)+,D0

	MOVE.W	10(A1),D0
	CLR.W	10(A1)
lbC000E4C	RTS

lbC000E4E	CMPI.W	#4,D7
	BGE.L	lbC001220
	MOVEA.L	4(A1),A3
	LEA	$3FC(A6),A2
	MOVE.W	D7,D0
	MULU.W	#$1A,D0
	ADDA.W	D0,A2
	MOVE.B	0(A1),D0
	BEQ.L	lbC000F6A
	CMPI.B	#1,D0
	BNE.L	lbC000F4E
	CLR.L	D1
	MOVE.B	3(A1),D1
	CMPI.W	#$24,D1
	BGE.S	lbC000E94
lbC000E82	CLR.B	0(A1)
	CMPI.B	#0,1(A1)
	BEQ.L	lbC001220
	BRA.L	lbC000F6A

lbC000E94	CMPI.W	#$6C,D1
	BGE.S	lbC000E82
	SUBI.W	#$24,D1
	CMPI.B	#0,1(A1)
	BNE.S	lbC000EAA
	CLR.L	12(A2)
lbC000EAA	CMPI.B	#1,1(A1)
	BEQ.S	lbC000EB6
	CLR.W	10(A2)
lbC000EB6	DIVU.W	#12,D1
	MOVE.W	D1,D2
	SWAP	D1
	ASL.W	#1,D1
	LEA	lbW000C94(PC),A0
	MOVE.W	#$D5C8,D0
	MULU.W	0(A0,D1.W),D0
	ADDI.W	#$11,D2
	LSR.L	D2,D0
	TST.W	0(A2)
	BNE.S	lbC000EDE
	CLR.W	2(A2)
	BRA.S	lbC000F06

lbC000EDE	MOVE.W	D0,D1
	SUB.W	0(A2),D1
	EXT.L	D1
	MOVE.W	$1B2(A3),D2
	SWAP	D2
	CLR.W	D2
	LSR.L	#1,D2
	DIVU.W	$36(A6),D2
	LSR.W	#3,D2
	ADDQ.W	#1,D2
	MOVE.W	D2,2(A2)
	DIVS.W	D2,D1
	MOVE.W	D1,4(A2)
	MULU.W	D2,D1
	SUB.W	D1,D0
lbC000F06	MOVE.W	D0,0(A2)
	MOVE.W	#1,$18(A2)
	TST.W	$1C2(A3)
	BNE.S	lbC000F1A
	CLR.W	$16(A2)
lbC000F1A	CLR.W	$12(A2)
	TST.W	$1BE(A3)
	BEQ.S	lbC000F46
	CLR.W	$10(A2)
	MOVE.W	$1C0(A3),D0
	SWAP	D0
	CLR.W	D0
	LSR.L	#1,D0
	DIVU.W	$36(A6),D0
	LSR.W	#2,D0
	MOVE.W	D0,$12(A2)
	MOVE.B	$A4(A3),D0
	EXT.W	D0
	MOVE.W	D0,$14(A2)
lbC000F46	MOVE.W	#$FFFF,10(A1)
	BRA.S	lbC000F6A

lbC000F4E	CMPI.B	#2,D0
	BNE.S	lbC000F5C
	MOVE.W	#6,10(A2)
	BRA.S	lbC000F6A

lbC000F5C	CMPI.B	#3,D0
	BNE.S	lbC000F6A
	BSR.L	lbC000A60
	BRA.L	lbC001220

lbC000F6A	TST.W	$12(A2)
	BMI.S	lbC000FB0
	BEQ.S	lbC000F78
	SUBQ.W	#1,$12(A2)
	BRA.S	lbC000FB0

lbC000F78	MOVE.W	$10(A2),D0
	MOVE.W	$1BC(A3),D1
	MULU.W	$36(A6),D1
	ASL.L	#6,D1
	SWAP	D1
	ADD.W	D1,D0
	BCC.S	lbC000F9C
	TST.W	$1BE(A3)
	BEQ.S	lbC000F9C
	BMI.S	lbC000F9C
	MOVE.W	#$FFFF,$12(A2)
	BRA.S	lbC000FB0

lbC000F9C	MOVE.W	D0,$10(A2)
	LSR.W	#8,D0
	LEA	$A4(A3),A0
	MOVE.B	0(A0,D0.W),D0
	EXT.W	D0
	MOVE.W	D0,$14(A2)
lbC000FB0	MOVE.W	10(A2),D0
	LEA	0(A3,D0.W),A0
	CLR.L	D1
	MOVE.W	$1C6(A0),D1
	SWAP	D1
	MOVE.L	12(A2),D2
	CLR.L	D3
	MOVE.W	$1CE(A0),D3
	MOVE.W	D3,D0
	LSR.W	#5,D0
	EORI.W	#7,D0
	ANDI.W	#$1F,D3
	ADDI.W	#$21,D3
	MULU.W	$36(A6),D3
	ASL.L	#3,D3
	LSR.L	D0,D3
	MOVE.L	D1,D0
	SUB.L	D2,D0
	BPL.S	lbC000FEA
	NEG.L	D0
lbC000FEA	CMP.L	D3,D0
	BGT.S	lbC001000
	MOVE.L	D1,D2
	CMPI.W	#4,10(A2)
	BGE.S	lbC00100A
	ADDI.W	#2,10(A2)
	BRA.S	lbC00100A

lbC001000	CMP.L	D1,D2
	BLT.S	lbC001008
	SUB.L	D3,D2
	BRA.S	lbC00100A

lbC001008	ADD.L	D3,D2
lbC00100A	MOVE.L	D2,12(A2)
	MOVE.W	0(A2),D0
	MOVEQ	#5,D2
	TST.W	2(A2)
	BEQ.S	lbC001026
	SUBQ.W	#1,2(A2)
	ADD.W	4(A2),D0
	MOVE.W	D0,0(A2)
lbC001026	CMPI.W	#$1AC,D0
	BLE.S	lbC001032
	LSR.W	#1,D0
	SUBQ.W	#1,D2
	BRA.S	lbC001026

lbC001032	MOVE.W	D2,8(A2)
	MOVEQ	#$40,D1
	LSR.W	D2,D1
	MOVE.W	D1,$10(A1)
	MOVE.W	$14(A2),D1
	MOVE.W	$1B4(A3),D2
	MULS.W	D2,D1
	ASR.W	#7,D1
	MOVE.W	4(A6),D2
	SUBI.W	#$80,D2
	SUB.W	D2,D1
	ADDI.W	#$1000,D1
	MULU.W	D1,D0
	MOVEQ	#12,D1
	LSR.L	D1,D0
	MOVE.W	D0,$12(A1)
	MOVE.W	$1AC(A3),D0
	MOVE.W	$14(A2),D1
	NEG.W	D1
	MOVE.W	$1B0(A3),D2
	MULS.W	D2,D1
	ASR.W	#8,D1
	ADD.W	D1,D0
	TST.W	$1AE(A3)
	BEQ.S	lbC001088
	MOVE.L	12(A2),D1
	SWAP	D1
	MULU.W	D1,D0
	LSR.W	#8,D0
	BRA.S	lbC001092

lbC001088	CMPI.W	#6,10(A2)
	BNE.S	lbC001092
	CLR.W	D0
lbC001092	ANDI.W	#$FF,D0
	ADDQ.W	#1,D0
	MULU.W	0(A6),D0
	LSR.W	#8,D0
	ADDQ.W	#1,D0
	MULU.W	8(A1),D0
	LSR.W	#8,D0
	ADDQ.W	#1,D0
	LSR.W	#2,D0
	MOVE.W	D0,$14(A1)
	MOVE.W	$1B8(A3),D0
	MOVE.L	12(A2),D1
	SWAP	D1
	MULU.W	D0,D1
	LSR.W	#8,D1
	MOVE.W	$1B6(A3),D0
	EORI.W	#$FF,D0
	SUB.W	D1,D0
	MOVE.W	$14(A2),D1
	MOVE.W	$1BA(A3),D2
	MULS.W	D2,D1
	ASR.W	#8,D1
	ADD.W	D1,D0
	ANDI.W	#$FF,D0
	LSR.W	#2,D0
	ASL.W	#7,D0
;	MOVEA.L	$1D6(A3),A0

	move.l	-4(A3),A0

	MOVE.L	A0,D1
	BNE.S	lbC0010EA
	LEA	$24(A3),A0
	CLR.W	D0
lbC0010EA	ADDA.W	D0,A0
	MOVE.W	6(A2),D0
	EORI.W	#$80,D0
	MOVE.W	D0,6(A2)
	MOVEA.L	$29A(A6),A4
	LEA	0(A4,D0.W),A4
	MOVE.W	#$100,D0
	MULU.W	D7,D0
	ADDA.W	D0,A4
	MOVE.L	A4,12(A1)
	TST.W	$1C2(A3)
	BNE.S	lbC00112C
	MOVE.W	8(A2),D3
	MOVEQ	#0,D1
	BSET	D3,D1
	MOVE.W	#$80,D4
	LSR.W	D3,D4
lbC001120	MOVE.B	(A0),(A4)+
	ADDA.W	D1,A0
	SUBQ.W	#1,D4
	BNE.S	lbC001120
	BRA.L	lbC001220

lbC00112C	TST.W	$1C4(A3)
	BNE.L	lbC00119E
	MOVE.W	8(A2),D3
	MOVEQ	#0,D1
	BSET	D3,D1
	MOVE.W	$10(A1),D2
	ASL.W	#1,D2
	SUBQ.W	#1,D2
	MOVE.W	$1C2(A3),D4
	MULU.W	$36(A6),D4
	MOVEQ	#13,D0
	LSR.L	D0,D4
	ADD.W	$16(A2),D4
	MOVE.W	D4,$16(A2)
	MOVEQ	#9,D0
	LSR.W	D0,D4
	LEA	0(A0,D4.W),A5
	LSR.W	D3,D4
	SUB.W	D4,D2
lbC001164	MOVE.B	(A0),D0
	EXT.W	D0
	MOVE.B	(A5),D3
	EXT.W	D3
	ADD.W	D3,D0
	ASR.W	#1,D0
	MOVE.B	D0,(A4)+
	ADDA.W	D1,A0
	ADDA.W	D1,A5
	DBRA	D2,lbC001164
	SUBA.W	#$80,A5
	SUBQ.W	#1,D4
	BMI.L	lbC001220
lbC001184	MOVE.B	(A0),D0
	EXT.W	D0
	MOVE.B	(A5),D3
	EXT.W	D3
	ADD.W	D3,D0
	ASR.W	#1,D0
	MOVE.B	D0,(A4)+
	ADDA.W	D1,A0
	ADDA.W	D1,A5
	DBRA	D4,lbC001184
	BRA.L	lbC001220

lbC00119E	MOVE.W	$1C2(A3),D0
	MULU.W	$36(A6),D0
	MOVEQ	#11,D1
	LSR.L	D1,D0
	MULS.W	$18(A2),D0
	ADD.W	$16(A2),D0
	BVC.S	lbC0011C4
	CMPI.W	#$8000,D0
	BNE.S	lbC0011BE
	ADD.W	$18(A2),D0
lbC0011BE	NEG.W	$18(A2)
	NEG.W	D0
lbC0011C4	MOVE.W	D0,$16(A2)
	MOVE.W	$1C4(A3),D1
	MULS.W	D1,D0
	MOVEQ	#$11,D1
	ADD.W	8(A2),D1
	ASR.L	D1,D0
	MOVE.W	$10(A1),D2
	MOVE.W	D2,D3
	ADD.W	D0,D2
	SUB.W	D0,D3
	MOVE.W	D2,D6
	BEQ.S	lbC001200
	CLR.W	D0
	CLR.W	D1
	MOVEQ	#$40,D4
	DIVU.W	D2,D4
	MOVE.W	D4,D5
	SWAP	D4
lbC0011F0	MOVE.B	0(A0,D0.W),(A4)+
	SUB.W	D4,D1
	BCC.S	lbC0011FA
	ADD.W	D2,D1
lbC0011FA	ADDX.W	D5,D0
	SUBQ.W	#1,D6
	BNE.S	lbC0011F0
lbC001200	MOVE.W	D3,D6
	BEQ.S	lbC001220
	MOVEQ	#$40,D0
	CLR.W	D1
	MOVEQ	#$40,D4
	DIVU.W	D3,D4
	MOVE.W	D4,D5
	SWAP	D4
lbC001210	MOVE.B	0(A0,D0.W),(A4)+
	SUB.W	D4,D1
	BCC.S	lbC00121A
	ADD.W	D3,D1
lbC00121A	ADDX.W	D5,D0
	SUBQ.W	#1,D6
	BNE.S	lbC001210
lbC001220	CLR.L	D0
	RTS

;SetFILTER	MOVEM.L	D0-D7/A0-A6,-(SP)
;	MOVEA.L	A0,A1
;	LEA	$4A(A6),A5
;	MOVEQ	#$3F,D7
;lbC001230	MOVE.L	0(A5),D0
;	BEQ.S	lbC001284
;	MOVEA.L	D0,A0
;	CMPA.L	A1,A0
;	BEQ.S	lbC001284
;	LEA	Synttech(PC),A3
;	CMPA.L	0(A0),A3
;	BNE.S	lbC001284
;	TST.L	$1D6(A0)
;	BEQ.S	lbC001284
;	LEA	$24(A0),A3
;	LEA	$24(A1),A4
;	MOVEQ	#$1F,D6
;lbC001256	MOVE.L	(A3)+,D0
;	CMP.L	(A4)+,D0
;	BNE.S	lbC001284
;	DBRA	D6,lbC001256
;	MOVEA.L	A0,A2
;	MOVE.L	$1D6(A1),D0
;	BEQ.S	lbC001274
;	MOVEA.L	D0,A0
;	SUBQ.W	#1,$2000(A0)
;	BNE.S	lbC001274
;	BSR.L	RELEASE
;lbC001274	MOVEA.L	$1D6(A2),A0
;	MOVE.L	A0,$1D6(A1)
;	ADDQ.W	#1,$2000(A0)
;	BRA.L	lbC001322

;lbC001284	ADDQ.L	#6,A5
;	DBRA	D7,lbC001230
;	MOVE.L	$1D6(A1),D2
;	BEQ.S	lbC00129A
;	MOVEA.L	D2,A2
;	CMPI.W	#1,$2000(A2)
;	BEQ.S	lbC0012C0
;lbC00129A	MOVE.L	#$2002,D0
;	MOVE.L	#1,D1
;	BSR.L	ALLOCATE
;	MOVE.L	A0,D0
;	BEQ.S	lbC0012C0
;	TST.L	D2
;	BEQ.S	lbC0012B6
;	SUBQ.W	#1,$2000(A2)
;lbC0012B6	MOVE.L	A0,$1D6(A1)
;	MOVE.W	#1,$2000(A0)
;lbC0012C0	MOVEA.L	A1,A2
;	MOVE.L	$1D6(A2),D0
;	BEQ.L	lbC001322
;	MOVEA.L	D0,A1
;	LEA	$24(A2),A0
;	LEA	lbW001332(PC),A2
;	CLR.W	D3
;	MOVE.B	$7F(A0),D4
;	EXT.W	D4
;	ASL.W	#7,D4
;	CLR.W	D0
;lbC0012E0	MOVE.W	(A2)+,D1
;	MOVE.W	#$8000,D2
;	SUB.W	D1,D2
;	MULU.W	#$E666,D2
;	SWAP	D2
;	LSR.W	#1,D1
;	CLR.W	D5
;lbC0012F2	MOVE.B	0(A0,D5.W),D6
;	EXT.W	D6
;	ASL.W	#7,D6
;	SUB.W	D4,D6
;	MULS.W	D1,D6
;	ASL.L	#2,D6
;	SWAP	D6
;	ADD.W	D6,D3
;	ADD.W	D3,D4
;	ROR.W	#7,D4
;	MOVE.B	D4,(A1)+
;	ROL.W	#7,D4
;	MULS.W	D2,D3
;	ASL.L	#1,D3
;	SWAP	D3
;	ADDQ.W	#1,D5
;	CMPI.W	#$80,D5
;	BCS.S	lbC0012F2
;	ADDQ.W	#1,D0
;	CMPI.W	#$40,D0
;	BNE.S	lbC0012E0
;lbC001322	MOVEM.L	(SP)+,D0-D7/A0-A6
;	RTS

;Synthesis.MSG	dc.b	'Synthesis',0
;lbW001332	dc.w	$8000
;	dc.w	$7683
;	dc.w	$6DBA
;	dc.w	$6597
;	dc.w	$5E10
;	dc.w	$5717
;	dc.w	$50A2
;	dc.w	$4AA8
;	dc.w	$451F
;	dc.w	$4000
;	dc.w	$3B41
;	dc.w	$36DD
;	dc.w	$32CB
;	dc.w	$2F08
;	dc.w	$2B8B
;	dc.w	$2851
;	dc.w	$2554
;	dc.w	$228F
;	dc.w	$2000
;	dc.w	$1DA0
;	dc.w	$1B6E
;	dc.w	$1965
;	dc.w	$1784
;	dc.w	$15C5
;	dc.w	$1428
;	dc.w	$12AA
;	dc.w	$1147
;	dc.w	$1000
;	dc.w	$ED0
;	dc.w	$DB7
;	dc.w	$CB2
;	dc.w	$BC2
;	dc.w	$AE2
;	dc.w	$A14
;	dc.w	$955
;	dc.w	$8A3
;	dc.w	$800
;	dc.w	$768
;	dc.w	$6DB
;	dc.w	$659
;	dc.w	$5E1
;	dc.w	$571
;	dc.w	$50A
;	dc.w	$4AA
;	dc.w	$451
;	dc.w	$400
;	dc.w	$3B4
;	dc.w	$36D
;	dc.w	$32C
;	dc.w	$2F0
;	dc.w	$2B8
;	dc.w	$285
;	dc.w	$255
;	dc.w	$228
;	dc.w	$200
;	dc.w	$1DA
;	dc.w	$1B6
;	dc.w	$196
;	dc.w	$178
;	dc.w	$15C
;	dc.w	$142
;	dc.w	$12A
;	dc.w	$114
;	dc.w	$100
SStech
;	dc.w	IFFtech-SStech
;	dc.w	SampledSound.MSG-SStech

;	BRA.L	lbC0013C6

;	BRA.L	lbC001486

	BRA.L	lbC0014F4

	BRA.L	lbC0014AA

;lbC0013C6	MOVEM.L	D1-D7/A1-A6,-(SP)
;	MOVE.L	D0,D2
;	MOVEA.L	A0,A4
;	MOVEQ	#$60,D0
;	MOVE.L	#$10001,D1
;	BSR.L	ALLOCATE
;	MOVE.L	A0,D0
;	BEQ.L	lbC001476
;	MOVEA.L	A0,A3
;	MOVE.L	D2,D0
;	MOVEQ	#$60,D1
;	BSR.L	lbC0000FA
;	CLR.L	$44(A3)
;	CMP.L	D1,D0
;	BNE.L	lbC00147E
;	MOVE.L	D2,D0
;	BSR.L	lbC0000D6
;	CLR.L	D2
;	LEA	$24(A3),A0
;	LEA	$4A(A6),A5
;	MOVEQ	#$3F,D7
;lbC001406	MOVE.L	0(A5),D0
;	BEQ.S	lbC001436
;	MOVEA.L	D0,A1
;	LEA	SStech(PC),A2
;	CMPA.L	0(A1),A2
;	BNE.S	lbC001436
;	LEA	$24(A1),A2
;	MOVE.L	A0,-(SP)
;	MOVE.L	A2,-(SP)
;	BSR.L	DOCMPSTR
;	ADDQ.L	#8,SP
;	BNE.S	lbC001436
;	MOVEA.L	$44(A1),A2
;	MOVE.L	A2,$44(A3)
;	ADDQ.W	#1,$1E(A2)
;	BRA.S	lbC001474

;lbC001436	ADDQ.L	#6,A5
;	DBRA	D7,lbC001406
;	MOVEA.L	A0,A1
;	MOVEA.L	A4,A0
;	LEA	ss.MSG(PC),A2
;	BSR.L	lbC00006C
;	MOVE.L	#3,D0
;	BSR.L	LoadCODE
;	MOVE.L	A0,D1
;	BNE.S	lbC00146A
;	BSR.L	lbC00006C
;	BSR.L	LoadCODE
;	MOVE.L	A0,D1
;	BNE.S	lbC00146A
;	BSET	#6,$30(A6)
;	BRA.S	lbC00147E

;lbC00146A	MOVE.L	A0,$44(A3)
;	MOVE.W	#1,$1E(A0)
;lbC001474	MOVEA.L	A3,A0
;lbC001476	MOVE.L	D2,D0
;	MOVEM.L	(SP)+,D1-D7/A1-A6
;	RTS

;lbC00147E	MOVEA.L	A3,A0
;	BSR.S	lbC001486
;	SUBA.L	A0,A0
;	BRA.S	lbC001476

;lbC001486	MOVEM.L	D0-D7/A0-A6,-(SP)
;	MOVEA.L	A0,A1
;	MOVE.L	$44(A1),D0
;	BEQ.S	lbC00149E
;	MOVEA.L	D0,A0
;	SUBQ.W	#1,$1E(A0)
;	BNE.S	lbC00149E
;	BSR.L	RELEASE
;lbC00149E	MOVEA.L	A1,A0
;	BSR.L	RELEASE
;	MOVEM.L	(SP)+,D0-D7/A0-A6
;	RTS

lbC0014AA	CLR.L	D0
	CMPI.W	#4,D7
	BGE.S	lbC0014F2
	TST.W	10(A1)
	BEQ.S	lbC0014E6
	SUBQ.W	#1,10(A1)
	BEQ.S	lbC0014CE
;	MOVE.W	$10(A1),4(A2)
;	MOVE.L	12(A1),0(A2)

	move.l	D0,-(SP)
	move.w	$10(A1),D0
	bsr.w	PokeLen
	move.l	12(A1),D0
	bsr.w	PokeAdr
	move.l	(SP)+,D0

	MOVEQ	#-1,D0
	BRA.S	lbC0014E6

lbC0014CE	LEA	$464(A6),A3
	MOVE.W	D7,D1
	MULU.W	#$14,D1
	ADDA.W	D1,A3
;	MOVE.W	4(A3),4(A2)
;	MOVE.L	0(A3),0(A2)

	move.l	D0,-(SP)
	move.w	4(A3),D0
	bsr.w	PokeLen
	move.l	(A3),D0
	bsr.w	PokeAdr
	move.l	(SP)+,D0

lbC0014E6
;	MOVE.W	$12(A1),6(A2)
;	MOVE.W	$14(A1),8(A2)

	move.l	D0,-(SP)
	move.w	$12(A1),D0
	bsr.w	PokePer
	move.w	$14(A1),D0
	bsr.w	PokeVol
	move.l	(SP)+,D0

lbC0014F2	RTS

lbC0014F4	CMPI.W	#4,D7
	BLT.S	lbC0014FE
	CLR.L	D0
	RTS

lbC0014FE	MOVEA.L	4(A1),A3
	LEA	$464(A6),A2
	MOVE.W	D7,D0
	MULU.W	#$14,D0
	ADDA.W	D0,A2
	MOVE.B	0(A1),D0
	BEQ.L	lbC00161C
	CMPI.B	#1,D0
	BNE.L	lbC001600
	MOVEA.L	$44(A3),A5
	CLR.L	D1
	MOVE.B	3(A1),D1
	DIVU.W	#12,D1
	MOVE.W	D1,D2
	SWAP	D1
	SUBI.W	#10,D2
	NEG.W	D2
	CMP.B	5(A5),D2
	BLE.S	lbC00154E
lbC00153C	CLR.B	0(A1)
	CMPI.B	#0,1(A1)
	BEQ.L	lbC00170E
	BRA.L	lbC00161C

lbC00154E	CMP.B	4(A5),D2
	BLT.S	lbC00153C
	CMPI.B	#0,1(A1)
	BNE.S	lbC001560
	CLR.L	10(A2)
lbC001560	CMPI.B	#1,1(A1)
	BEQ.S	lbC00156C
	CLR.W	8(A2)
lbC00156C	ASL.W	#1,D1
	LEA	lbW000C94(PC),A0
	MOVE.W	#$D5C8,D0
	MULU.W	0(A0,D1.W),D0
	MOVEQ	#15,D1
	LSR.L	D1,D0
	MOVE.W	D0,6(A2)
	MOVEQ	#1,D0
	ASL.L	D2,D0
	MOVE.L	D0,D4
	MOVEQ	#1,D1
	CLR.W	D3
	MOVE.B	4(A5),D3
	ASL.L	D3,D1
	SUB.L	D1,D0
	MULU.W	0(A5),D0
	LEA	$3E(A5,D0.L),A0
	MOVE.L	A0,12(A1)
	MOVE.W	0(A5),D0
	MULU.W	D4,D0
	LSR.L	#1,D0
	MOVE.W	D0,$10(A1)
	MOVEA.L	$29A(A6),A0
	ADDA.W	#$400,A0
	MOVEQ	#4,D0
	MOVE.W	2(A5),D1
	CMP.W	0(A5),D1
	BEQ.S	lbC0015D4
	MULU.W	D4,D1
	MOVEA.L	12(A1),A0
	ADDA.L	D1,A0
	MOVE.W	0(A5),D0
	SUB.W	2(A5),D0
	MULU.W	D4,D0
	LSR.L	#1,D0
lbC0015D4	MOVE.L	A0,0(A2)
	MOVE.W	D0,4(A2)
	CLR.W	14(A2)
	MOVE.W	$5E(A3),D0
	SWAP	D0
	CLR.W	D0
	LSR.L	#1,D0
	DIVU.W	$36(A6),D0
	LSR.W	#1,D0
	MOVE.W	D0,$10(A2)
	MOVE.W	#2,10(A1)
	BSR.L	lbC000A60
	BRA.S	lbC00161C

lbC001600	CMPI.B	#2,D0
	BNE.S	lbC00160E
	MOVE.W	#6,8(A2)
	BRA.S	lbC00161C

lbC00160E	CMPI.B	#3,D0
	BNE.S	lbC00161C
	BSR.L	lbC000A60
	BRA.L	lbC00170E

lbC00161C	TST.W	$10(A2)
	BEQ.S	lbC00162A
	SUBI.W	#1,$10(A2)
	BRA.S	lbC001644

lbC00162A	MOVE.W	14(A2),D0
	MOVE.W	$5C(A3),D1
	MULU.W	$36(A6),D1
	ASL.L	#7,D1
	SWAP	D1
	ADDI.W	#$40,D1
	ADD.W	D1,D0
	MOVE.W	D0,14(A2)
lbC001644	MOVE.W	14(A2),D0
	LSR.W	#7,D0
	ADDI.W	#$80,D0
	BTST	#8,D0
	BEQ.S	lbC001658
	EORI.W	#$FF,D0
lbC001658	EORI.W	#$80,D0
	EXT.W	D0
	NEG.W	D0
	MOVE.W	D0,$12(A2)
	MOVE.W	8(A2),D0
	LEA	0(A3,D0.W),A0
	CLR.L	D1
	MOVE.W	$4A(A0),D1
	SWAP	D1
	MOVE.L	10(A2),D2
	CLR.L	D3
	MOVE.W	$52(A0),D3
	MOVE.W	D3,D0
	LSR.W	#5,D0
	EORI.W	#7,D0
	ANDI.W	#$1F,D3
	ADDI.W	#$21,D3
	MULU.W	$36(A6),D3
	ASL.L	#3,D3
	LSR.L	D0,D3
	MOVE.L	D1,D0
	SUB.L	D2,D0
	BPL.S	lbC00169E
	NEG.L	D0
lbC00169E	CMP.L	D3,D0
	BGT.S	lbC0016B4
	MOVE.L	D1,D2
	CMPI.W	#4,8(A2)
	BGE.S	lbC0016BE
	ADDI.W	#2,8(A2)
	BRA.S	lbC0016BE

lbC0016B4	CMP.L	D1,D2
	BLT.S	lbC0016BC
	SUB.L	D3,D2
	BRA.S	lbC0016BE

lbC0016BC	ADD.L	D3,D2
lbC0016BE	MOVE.L	D2,10(A2)
	MOVE.W	6(A2),D0
	MOVE.W	$12(A2),D1
	MOVE.W	$5A(A3),D2
	MULS.W	D2,D1
	ASR.W	#7,D1
	MOVE.W	4(A6),D2
	SUBI.W	#$80,D2
	SUB.W	D2,D1
	ADDI.W	#$1000,D1
	MULU.W	D1,D0
	MOVEQ	#$13,D1
	LSR.L	D1,D0
	MOVE.W	D0,$12(A1)
	MOVE.W	0(A6),D0
	ADDQ.W	#1,D0
	MULU.W	8(A1),D0
	LSR.W	#8,D0
	ADDQ.W	#1,D0
	MULU.W	$48(A3),D0
	LSR.W	#8,D0
	MOVE.L	10(A2),D1
	SWAP	D1
	MULU.W	D1,D0
	MOVEQ	#10,D1
	LSR.W	D1,D0
	MOVE.W	D0,$14(A1)
lbC00170E	CLR.L	D0
	CMPI.W	#2,10(A1)
	BNE.S	lbC00171A
	MOVEQ	#-1,D0
lbC00171A	RTS

;SampledSound.MSG	dc.b	'SampledSound',0
;ss.MSG	dc.b	'.ss',0,0
IFFtech
;	dc.w	IFFtech-IFFtech
;	dc.w	FORM.MSG-IFFtech

;	BRA.L	lbC001742

;	BRA.L	lbC001898

	BRA.L	lbC001900

	BRA.L	lbC0018B2

;lbC001742	MOVEM.L	D0-D7/A1-A6,-(SP)
;	LEA	$32A(A6),A5
;	MOVEQ	#$20,D5
;	MOVE.L	D0,D2
;	MOVEA.L	SP,A4
;	MOVEQ	#$3E,D0
;	MOVE.L	#$10001,D1
;	BSR.L	ALLOCATE
;	MOVE.L	A0,D0
;	BEQ.L	lbC001848
;	MOVEA.L	A0,A3
;	BSR.L	lbC00185A
;	CMPI.L	#'FORM',D0
;	BNE.L	lbC00184E
;	BSR.L	lbC00185A
;	MOVE.L	D0,D7
;	BSR.L	lbC00185A
;	CMPI.L	#'8SVX',D0
;	BNE.L	lbC00184E
;	SUBQ.L	#4,D7
;lbC001788	TST.L	D7
;	BLE.L	lbC001808
;	BSR.L	lbC00185A
;	MOVE.L	D0,D1
;	BSR.L	lbC00185A
;	MOVE.L	D0,D6
;	SUBQ.L	#8,D7
;	CMPI.L	#'VHDR',D1
;	BEQ.L	lbC0017BE
;	CMPI.L	#'BODY',D1
;	BEQ.L	lbC0017D6
;lbC0017B0	TST.L	D6
;	BLE.S	lbC001788
;	BSR.L	lbC001866
;	SUBQ.L	#2,D6
;	SUBQ.L	#2,D7
;	BRA.S	lbC0017B0

;lbC0017BE	LEA	$24(A3),A0
;	MOVEQ	#$14,D0
;	BSR.L	lbC001872
;	TST.B	15(A0)
;	BNE.L	lbC00184E
;	SUB.L	D0,D6
;	SUB.L	D0,D7
;	BRA.S	lbC0017B0

;lbC0017D6	TST.L	$3A(A3)
;	BNE.L	lbC00184E
;	TST.B	$32(A3)
;	BEQ.L	lbC00184E
;	MOVE.L	D6,D0
;	ADDQ.L	#1,D0
;	ANDI.W	#$FFFE,D0
;	MOVE.L	#3,D1
;	BSR.L	ALLOCATE
;	MOVE.L	A0,$3A(A3)
;	BEQ.L	lbC00184E
;	BSR.L	lbC001872
;	SUB.L	D0,D7
;	BRA.S	lbC001788

;lbC001808	TST.L	$3A(A3)
;	BEQ.L	lbC00184E
;	LEA	$24(A3),A0
;	MOVE.L	(A0)+,D2
;	MOVE.L	(A0)+,D3
;	MOVE.L	(A0)+,D4
;	CLR.W	D1
;lbC00181C	LSR.L	#1,D2
;	LSR.L	#1,D3
;	LSR.L	#1,D4
;	ADDQ.W	#1,D1
;	MOVE.L	D2,D0
;	OR.L	D3,D0
;	BTST	#0,D0
;	BNE.S	lbC001842
;	CMPI.L	#1,D4
;	BEQ.S	lbC001842
;	MOVE.B	D1,D0
;	ADD.B	$32(A3),D0
;	CMPI.B	#8,D0
;	BLT.S	lbC00181C
;lbC001842	MOVE.W	D1,$38(A3)
;	MOVEA.L	A3,A0
;lbC001848	MOVEM.L	(SP)+,D0-D7/A1-A6
;	RTS

;lbC00184E	MOVEA.L	A4,SP
;	MOVEA.L	A3,A0
;	BSR.L	lbC001898
;	SUBA.L	A0,A0
;	BRA.S	lbC001848

;lbC00185A	SUBQ.L	#4,SP
;	MOVEA.L	SP,A0
;	MOVEQ	#4,D0
;	BSR.S	lbC001872
;	MOVE.L	(SP)+,D0
;	RTS

;lbC001866	SUBQ.L	#2,SP
;	MOVEA.L	SP,A0
;	MOVEQ	#2,D0
;	BSR.S	lbC001872
;	MOVE.W	(SP)+,D0
;	RTS

;lbC001872	MOVEM.L	D0/D1/A0,-(SP)
;lbC001876	TST.L	D0
;	BEQ.S	lbC001892
;	TST.W	D5
;	BEQ.S	lbC001886
;	MOVE.W	(A5)+,(A0)+
;	SUBQ.W	#2,D5
;	SUBQ.L	#2,D0
;	BRA.S	lbC001876

;lbC001886	MOVE.L	D0,D1
;	MOVE.L	D2,D0
;	BSR.L	lbC0000FA
;	CMP.L	D1,D0
;	BNE.S	lbC00184E
;lbC001892	MOVEM.L	(SP)+,D0/D1/A0
;	RTS

;lbC001898	MOVEM.L	D0-D7/A0-A6,-(SP)
;	MOVEA.L	A0,A1
;	MOVEA.L	$3A(A1),A0
;	BSR.L	RELEASE
;	MOVEA.L	A1,A0
;	BSR.L	RELEASE
;	MOVEM.L	(SP)+,D0-D7/A0-A6
;	RTS

lbC0018B2	CLR.L	D0
	CMPI.W	#4,D7
	BGE.L	lbC0018FE
	TST.W	10(A1)
	BEQ.S	lbC0018F2
	SUBI.W	#1,10(A1)
	BEQ.S	lbC0018DA
;	MOVE.W	$10(A1),4(A2)
;	MOVE.L	12(A1),0(A2)

	move.l	D0,-(SP)
	move.w	$10(A1),D0
	bsr.w	PokeLen
	move.l	12(A1),D0
	bsr.w	PokeAdr
	move.l	(SP)+,D0

	MOVEQ	#-1,D0
	BRA.S	lbC0018F2

lbC0018DA	LEA	$4B4(A6),A3
	MOVE.W	D7,D1
	MULU.W	#10,D1
	ADDA.W	D1,A3
;	MOVE.W	4(A3),4(A2)
;	MOVE.L	0(A3),0(A2)

	move.l	D0,-(SP)
	move.w	4(A3),D0
	bsr.w	PokeLen
	move.l	(A3),D0
	bsr.w	PokeAdr
	move.l	(SP)+,D0

lbC0018F2
;	MOVE.W	$12(A1),6(A2)
;	MOVE.W	$14(A1),8(A2)

	move.l	D0,-(SP)
	move.w	$12(A1),D0
	bsr.w	PokePer
	move.w	$14(A1),D0
	bsr.w	PokeVol
	move.l	(SP)+,D0

lbC0018FE	RTS

lbC001900	CMPI.W	#4,D7
	BLT.S	lbC00190A
	CLR.L	D0
	RTS

lbC00190A	MOVEA.L	4(A1),A3
	LEA	$4B4(A6),A2
	MOVE.W	D7,D0
	MULU.W	#10,D0
	ADDA.W	D0,A2
	MOVE.B	0(A1),D0
	BEQ.L	lbC0019E6
	CMPI.B	#1,D0
	BNE.L	lbC0019CC
	MOVEA.L	$3A(A3),A5
	CLR.L	D1
	MOVE.B	3(A1),D1
	DIVU.W	#12,D1
	MOVE.W	D1,D2
	SWAP	D1
	ASL.W	#1,D1
	LEA	lbW000C94(PC),A0
	MOVE.W	#$D5C8,D0
	MULU.W	0(A0,D1.W),D0
	MOVEQ	#15,D1
	LSR.L	D1,D0
	MOVE.W	D0,6(A2)
	SUBI.W	#10,D2
	NEG.W	D2
	SUB.W	$38(A3),D2
	BPL.S	lbC001970
lbC00195E	CLR.B	0(A1)
	CMPI.B	#0,1(A1)
	BEQ.L	lbC001A1C
	BRA.L	lbC0019E6

lbC001970	CMP.B	$32(A3),D2
	BGE.S	lbC00195E
	MOVE.L	$24(A3),D4
	MOVE.L	$28(A3),D5
	MOVE.L	D4,D0
	ADD.L	D5,D0
	MOVE.L	D0,D1
	ASL.L	D2,D1
	SUB.L	D0,D1
	LEA	0(A5,D1.L),A0
	ASL.L	D2,D4
	ASL.L	D2,D5
	MOVE.W	D4,D0
	BNE.S	lbC001996
	MOVE.W	D5,D0
lbC001996	MOVE.L	A0,12(A1)
	LSR.W	#1,D0
	MOVE.W	D0,$10(A1)
	ADDA.W	D4,A0
	MOVE.W	D5,D0
	BNE.S	lbC0019B0
	MOVEA.L	$29A(A6),A0
	ADDA.W	#$400,A0
	MOVEQ	#8,D0
lbC0019B0	MOVE.L	A0,0(A2)
	LSR.W	#1,D0
	MOVE.W	D0,4(A2)
	MOVE.W	#2,10(A1)
	BSR.L	lbC000A60
	MOVE.W	#1,8(A2)
	BRA.S	lbC0019E6

lbC0019CC	CMPI.B	#2,D0
	BNE.S	lbC0019D8
	CLR.W	8(A2)
	BRA.S	lbC0019E6

lbC0019D8	CMPI.B	#3,D0
	BNE.S	lbC0019E6
	BSR.L	lbC000A60
	BRA.L	lbC001A1C

lbC0019E6	MOVE.W	#$1080,D0
	SUB.W	4(A6),D0
	MULU.W	6(A2),D0
	MOVEQ	#$13,D1
	LSR.L	D1,D0
	MOVE.W	D0,$12(A1)
	MOVE.W	0(A6),D0
	ADDQ.W	#1,D0
	MULU.W	8(A1),D0
	LSR.W	#8,D0
	ADDQ.W	#1,D0
	MOVE.L	$34(A3),D1
	LSR.L	#1,D1
	MULU.W	D1,D0
	MOVEQ	#$11,D1
	LSR.L	D1,D0
	MULU.W	8(A2),D0
	MOVE.W	D0,$14(A1)
lbC001A1C	CLR.L	D0
	CMPI.W	#2,10(A1)
	BNE.S	lbC001A28
	MOVEQ	#-1,D0
lbC001A28	RTS

;FORM.MSG	dc.b	'FORM',0,0
;	dc.b	$9D
;	dc.b	$FA
;	dc.b	$F5
;	dc.b	1
;	dc.b	10
;	dc.b	2
;	dc.b	$F5
;	dc.b	13
;	dc.b	$F7
;	dc.b	$F5
;	dc.b	'&SSonix Music Driver (C) Copyright 1987-90 M'
;	dc.b	'ark Riley, All Rights Reserved.',0
;	dc.b	'Version 2.0f - January 14, 1990',0

;InitSONIX	MOVEM.L	D1-D7/A0-A6,-(SP)
;	SUBA.L	A6,A6
;	MOVE.L	#$4DC,D0
;	MOVE.L	#$10001,D1
;	BSR.L	ALLOCATE
;	MOVEA.L	A0,A6
;	MOVE.L	A6,D0
;	BEQ.L	lbC001C26
;	MOVE.L	#$1000,$28(A6)
;	MOVE.L	#$408,D0
;	MOVE.L	#$10003,D1
;	BSR.L	ALLOCATE
;	MOVE.L	A0,$29A(A6)
;	BEQ.L	lbC001C2E
;	LEA	doslibrary.MSG(PC),A1
;	MOVEQ	#0,D0
;	MOVE.L	A6,-(SP)
;	MOVEA.L	4,A6
;	JSR	-$228(A6)
;	MOVEA.L	(SP)+,A6
;	MOVE.L	D0,$3EC(A6)
;	BEQ.L	lbC001C2E
;	LEA	$3B0(A6),A2
;	MOVE.B	#4,8(A2)
;	MOVE.B	#0,14(A2)
;	MOVEQ	#-1,D0
;	MOVE.L	A6,-(SP)
;	MOVEA.L	4,A6
;	JSR	-$14A(A6)
;	MOVEA.L	(SP)+,A6
;	MOVE.B	D0,15(A2)
;	SUBA.L	A1,A1
;	MOVE.L	A6,-(SP)
;	MOVEA.L	4,A6
;	JSR	-$126(A6)
;	MOVEA.L	(SP)+,A6
;	MOVE.L	D0,$10(A2)
;	LEA	$14(A2),A0
;	MOVE.L	A0,0(A0)
;	ADDQ.L	#4,0(A0)
;	CLR.L	4(A0)
;	MOVE.L	A0,8(A0)
;	LEA	$36C(A6),A1
;	MOVE.B	#5,8(A1)
;	MOVE.L	A2,14(A1)
;	LEA	lbW001E9C(PC),A0
;	MOVE.L	A0,$22(A1)
;	MOVEQ	#1,D0
;	MOVE.L	D0,$26(A1)
;	MOVE.B	#$7F,9(A1)
;	LEA	audiodevice.MSG(PC),A0
;	MOVEQ	#0,D0
;	MOVEQ	#0,D1
;	MOVE.L	A6,-(SP)
;	MOVEA.L	4,A6
;	JSR	-$1BC(A6)
;	MOVEA.L	(SP)+,A6
;	TST.L	D0
;	BNE.L	lbC001C2E
;	LEA	ciabresource.MSG(PC),A1
;	MOVE.L	A6,-(SP)
;	MOVEA.L	4,A6
;	JSR	-$1F2(A6)
;	MOVEA.L	(SP)+,A6
;	MOVE.L	D0,$3E8(A6)
;	BEQ.L	lbC001C2E
;	LEA	$3D2(A6),A2
;	LEA	$BFD400,A3
;	LEA	$BFDE00,A4
;	MOVEQ	#0,D7
;lbC001BAC	LEA	lbC0007D2(PC),A0
;	MOVE.L	A0,$12(A2)
;	MOVE.L	A6,14(A2)
;	MOVEA.L	A2,A1
;	MOVE.L	D7,D0
;	MOVE.L	A6,-(SP)
;	MOVEA.L	$3E8(A6),A6
;	JSR	-6(A6)
;	MOVEA.L	(SP)+,A6
;	TST.L	D0
;	BEQ.S	lbC001BE6
;	CLR.L	$12(A2)
;	TST.L	D7
;	BNE.L	lbC001C2E
;	LEA	$BFD600,A3
;	LEA	$BFDF00,A4
;	MOVEQ	#1,D7
;	BRA.S	lbC001BAC

;lbC001BE6	MOVE.L	A3,$3F0(A6)
;	MOVE.L	A4,$3F4(A6)
;	MOVE.L	D7,$3F8(A6)
;	MOVE.W	#$3F,$1CA(A6)
;	MOVE.W	#$FF,0(A6)
;	MOVE.W	#$80,4(A6)
;	MOVE.W	#$80,D0
;	MOVE.W	D0,2(A6)
;	BSR.L	lbC0007F2
;	MOVE.L	$3F8(A6),D0
;	ADDQ.B	#1,D0
;	ORI.B	#$80,D0
;	MOVE.L	A6,-(SP)
;	MOVEA.L	$3E8(A6),A6
;	JSR	-$12(A6)
;	MOVEA.L	(SP)+,A6
;lbC001C26	MOVE.L	A6,D0
;	MOVEM.L	(SP)+,D1-D7/A0-A6
;	RTS

;lbC001C2E	BSR.S	lbC001C50
;	SUBA.L	A6,A6
;	BRA.S	lbC001C26

;QuitSONIX	MOVEM.L	D0-D7/A0-A6,-(SP)
;	MOVE.L	A6,D0
;	BEQ.S	lbC001C4A
;	BSR.L	StopSOUND
;	BSR.L	PurgeSCORES
;	BSR.L	PurgeINSTRUMENTS
;	BSR.S	lbC001C50
;lbC001C4A	MOVEM.L	(SP)+,D0-D7/A0-A6
;	RTS

;lbC001C50	MOVEM.L	D0-D7/A0-A6,-(SP)
;	MOVE.L	A6,D0
;	BEQ.L	lbC001CFC
;	TST.L	$3E8(A6)
;	BEQ.S	lbC001C94
;	LEA	$3D2(A6),A2
;	TST.L	$12(A2)
;	BEQ.S	lbC001C94
;	MOVE.L	$3F8(A6),D0
;	ADDQ.L	#1,D0
;	MOVE.L	A6,-(SP)
;	MOVEA.L	$3E8(A6),A6
;	JSR	-$12(A6)
;	MOVEA.L	(SP)+,A6
;	MOVEA.L	$3F4(A6),A0
;	CLR.B	(A0)
;	MOVE.L	$3F8(A6),D0
;	MOVEA.L	A2,A1
;	MOVE.L	A6,-(SP)
;	MOVEA.L	$3E8(A6),A6
;	JSR	-12(A6)
;	MOVEA.L	(SP)+,A6
;lbC001C94	LEA	$36C(A6),A2
;	SUBA.L	A1,A1
;	MOVE.L	A6,-(SP)
;	MOVEA.L	4,A6
;	JSR	-$126(A6)
;	MOVEA.L	(SP)+,A6
;	MOVE.L	D0,$10(A2)
;	MOVE.L	$14(A2),D0
;	BEQ.S	lbC001CC2
;	ADDQ.L	#1,D0
;	BEQ.S	lbC001CC2
;	MOVEA.L	A2,A1
;	MOVE.L	A6,-(SP)
;	MOVEA.L	4,A6
;	JSR	-$1C2(A6)
;	MOVEA.L	(SP)+,A6
;lbC001CC2	LEA	$3B0(A6),A2
;	CLR.L	D0
;	MOVE.B	15(A2),D0
;	BEQ.S	lbC001CDA
;	MOVE.L	A6,-(SP)
;	MOVEA.L	4,A6
;	JSR	-$150(A6)
;	MOVEA.L	(SP)+,A6
;lbC001CDA	MOVE.L	$3EC(A6),D0
;	BEQ.S	lbC001CEE
;	MOVEA.L	D0,A1
;	MOVE.L	A6,-(SP)
;	MOVEA.L	4,A6
;	JSR	-$19E(A6)
;	MOVEA.L	(SP)+,A6
;lbC001CEE	MOVEA.L	$29A(A6),A0
;	BSR.L	RELEASE
;	MOVEA.L	A6,A0
;	BSR.L	RELEASE
;lbC001CFC	MOVEM.L	(SP)+,D0-D7/A0-A6
;	RTS

;SonixWAIT	MOVEM.L	D1/D2/A0/A1,-(SP)
;	MOVE.L	D1,-(SP)
;	MOVE.L	D0,-(SP)
;	MOVEQ	#-1,D0
;	MOVE.L	A6,-(SP)
;	MOVEA.L	4,A6
;	JSR	-$14A(A6)
;	MOVEA.L	(SP)+,A6
;	MOVE.L	D0,D2
;	MOVE.L	(SP)+,D0
;	CLR.L	D1
;	BSET	D2,D1
;	BSR.S	SonixSIGNAL
;	MOVE.L	D1,D0
;	OR.L	(SP),D0
;	MOVE.L	A6,-(SP)
;	MOVEA.L	4,A6
;	JSR	-$13E(A6)
;	MOVEA.L	(SP)+,A6
;	AND.L	(SP)+,D0
;	MOVE.L	D0,-(SP)
;	CLR.L	D1
;	BSR.S	SonixSIGNAL
;	MOVE.L	D2,D0
;	MOVE.L	A6,-(SP)
;	MOVEA.L	4,A6
;	JSR	-$150(A6)
;	MOVEA.L	(SP)+,A6
;	MOVE.L	(SP)+,D0
;	MOVEM.L	(SP)+,D1/D2/A0/A1
;	RTS

;SonixSIGNAL	MOVEM.L	D0-D2/A0/A1,-(SP)
;	CLR.L	$360(A6)
;	MOVE.L	D1,D2
;	BEQ.S	lbC001D76
;	MOVE.L	D0,$364(A6)
;	SUBA.L	A1,A1
;	MOVE.L	A6,-(SP)
;	MOVEA.L	4,A6
;	JSR	-$126(A6)
;	MOVEA.L	(SP)+,A6
;	MOVE.L	D0,$35C(A6)
;	MOVE.L	D2,$360(A6)
;lbC001D76	MOVEM.L	(SP)+,D0-D2/A0/A1
;	RTS

;DOCMPSTR	MOVEM.L	D0/D1/A0/A1,-(SP)
;	MOVEA.L	$18(SP),A0
;	MOVEA.L	$14(SP),A1
;lbC001D88	MOVE.B	(A0)+,D0
;	CMPI.B	#$61,D0
;	BCS.S	lbC001D9A
;	CMPI.B	#$7B,D0
;	BCC.S	lbC001D9A
;	ANDI.B	#$DF,D0
;lbC001D9A	MOVE.B	(A1)+,D1
;	CMPI.B	#$61,D1
;	BCS.S	lbC001DAC
;	CMPI.B	#$7B,D1
;	BCC.S	lbC001DAC
;	ANDI.B	#$DF,D1
;lbC001DAC	CMP.B	D0,D1
;	BNE.S	lbC001DB4
;	TST.B	D0
;	BNE.S	lbC001D88
;lbC001DB4	MOVEM.L	(SP)+,D0/D1/A0/A1
;	RTS

;SonixALLOCATE	MOVE.L	A0,-(SP)
;	BSR.S	ALLOCATE
;	MOVE.L	A0,D0
;	MOVEA.L	(SP)+,A0
;	RTS

;ALLOCATE	MOVEM.L	D0-D3/A1/A6,-(SP)
;	ADDQ.L	#4,D0
;	MOVE.L	D0,D2
;	MOVE.L	AllocatePATCH(PC),D3
;	BNE.S	lbC001E0E
;	MOVE.L	D1,D3
;	MOVE.L	A6,D1
;	BEQ.S	lbC001DF0
;	MOVEQ	#1,D1
;	MOVE.L	A6,-(SP)
;	MOVEA.L	4,A6
;	JSR	-$D8(A6)
;	MOVEA.L	(SP)+,A6
;	SUB.L	D2,D0
;	SUBA.L	A0,A0
;	SUB.L	$28(A6),D0
;	BMI.S	lbC001E08
;lbC001DF0	MOVE.L	D2,D0
;	MOVE.L	D3,D1
;	MOVE.L	A6,-(SP)
;	MOVEA.L	4,A6
;	JSR	-$C6(A6)
;	MOVEA.L	(SP)+,A6
;lbC001E00	MOVEA.L	D0,A0
;	TST.L	D0
;	BEQ.S	lbC001E08
;	MOVE.L	D2,(A0)+
;lbC001E08	MOVEM.L	(SP)+,D0-D3/A1/A6
;	RTS

;lbC001E0E	MOVEA.L	D3,A0
;	JSR	(A0)
;	BRA.S	lbC001E00

;RELEASE	MOVEM.L	D0/D1/A0/A1,-(SP)
;	MOVE.L	A0,D0
;	BEQ.S	lbC001E34
;	SUBQ.L	#4,A0
;	MOVE.L	ReleasePATCH(PC),D1
;	BNE.S	lbC001E3A
;	MOVEA.L	A0,A1
;	MOVE.L	(A1),D0
;	MOVE.L	A6,-(SP)
;	MOVEA.L	4,A6
;	JSR	-$D2(A6)
;	MOVEA.L	(SP)+,A6
;lbC001E34	MOVEM.L	(SP)+,D0/D1/A0/A1
;	RTS

;lbC001E3A	MOVEA.L	D1,A1
;	JSR	(A1)
;	BRA.S	lbC001E34

;SonixLOAD	MOVE.L	A0,-(SP)
;	BSR.S	LoadCODE
;	MOVE.L	A0,D0
;	MOVEA.L	(SP)+,A0
;	RTS

;LoadCODE	MOVEM.L	D0-D7/A1-A6,-(SP)
;	MOVE.L	D0,D4
;	CLR.L	D6
;	MOVE.L	#$3ED,D0
;	BSR.L	lbC0000B0
;	MOVE.L	D0,D7
;	BEQ.S	lbC001E94
;	MOVE.L	D7,D1
;	MOVEQ	#0,D2
;	MOVEQ	#1,D3
;	BSR.L	lbC000122
;	MOVEQ	#-1,D3
;	BSR.L	lbC000122
;	TST.L	D0
;	BMI.S	lbC001E8E
;	MOVE.L	D4,D1
;	BSR.L	ALLOCATE
;	MOVE.L	A0,D6
;	BEQ.S	lbC001E8E
;	MOVE.L	D0,D1
;	MOVE.L	D7,D0
;	BSR.L	lbC0000FA
;	CMP.L	D1,D0
;	BEQ.S	lbC001E8E
;	BSR.S	RELEASE
;	CLR.L	D6
;lbC001E8E	MOVE.L	D7,D0
;	BSR.L	lbC0000D6
;lbC001E94	MOVEA.L	D6,A0
;	MOVEM.L	(SP)+,D0-D7/A1-A6
;	RTS

;lbW001E9C	dc.w	$F0F
;doslibrary.MSG	dc.b	'dos.library',0
;audiodevice.MSG	dc.b	'audio.device',0
;ciabresource.MSG	dc.b	'ciab.resource',0,0

	Section	Buffy,BSS
Buffer
	ds.b	1336
Buffer2
	ds.b	132

	Section	Hips,BSS_C
Chip
	ds.b	1024
Empty
	ds.b	8

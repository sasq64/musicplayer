	*****************************************************
	****        TME replayer for EaglePlayer	 ****
	****        all adaptions by Wanted Team,	 ****
	****      DeliTracker compatible (?) version	 ****
	*****************************************************

	incdir	"dh2:include/"
	include 'misc/eagleplayer2.01.i'

	SECTION	Player_Code,CODE

	PLAYERHEADER Tags

	dc.b	'$VER: The Musical Enlightenment 2.0 player module V1.2 (17 Feb 2002)',0
	even
Tags
	dc.l	DTP_PlayerVersion,3
	dc.l	EP_PlayerVersion,9
	dc.l	DTP_RequestDTVersion,DELIVERSION
	dc.l	DTP_PlayerName,PlayerName
	dc.l	DTP_Creator,Creator
	dc.l	DTP_Check2,Check2
	dc.l	EP_NewModuleInfo,NewModuleInfo
	dc.l	DTP_SubSongRange,SubSongRange
	dc.l	DTP_InitPlayer,InitPlayer
	dc.l	DTP_EndPlayer,EndPlayer
	dc.l	DTP_InitSound,InitSound
	dc.l	DTP_EndSound,EndSound
	dc.l	DTP_Interrupt,Interrupt
	dc.l	EP_SampleInit,SampleInit
	dc.l	EP_GetPositionNr,GetPosition
	dc.l	DTP_Volume,SetVolume
	dc.l	DTP_Balance,SetBalance
	dc.l	EP_Voices,SetVoices
	dc.l	DTP_NextPatt,NewTrack
	dc.l	DTP_PrevPatt,BackPattern
	dc.l	EP_StructInit,StructInit
	dc.l	EP_PatternInit,PatternInit
	dc.l	EP_Flags,EPB_Save!EPB_Volume!EPB_Balance!EPB_ModuleInfo!EPB_Voices!EPB_SampleInfo!EPB_Songend!EPB_Analyzer!EPB_Packable!EPB_Restart!EPB_PrevPatt!EPB_NextPatt!EPB_PrevSong!EPB_NextSong!EPB_CalcDuration
	dc.l	DTP_DeliBase,DeliBase
	dc.l	EP_EagleBase,Eagle2Base
	dc.l	DTP_Duration,CalcDuration
	dc.l	0

PlayerName
	dc.b	'The Musical Enlightenment',0
Creator
	dc.b	'(c) 1989-90 by N.J. Luuring jr,',10
	dc.b	'adapted by Wanted Team',0
Prefix	dc.b	'TME.',0
	even
DeliBase
	dc.l	0
Eagle2Base
	dc.l	0
ModulePtr
	dc.l	0
EagleBase
	dc.l	0
SamplesPtr
	dc.l	0
Interrupts
	dc.l	0
Voice1
	dc.w	1
Voice2
	dc.w	1
Voice3
	dc.w	1
Voice4
	dc.w	1
OldVoice1
	dc.w	0
OldVoice2
	dc.w	0
OldVoice3
	dc.w	0
OldVoice4
	dc.w	0
RightVolume
	dc.w	64
LeftVolume
	dc.w	64
StructAdr
	ds.b	UPS_SizeOF

***************************************************************************
******************************* DTP_Duration ******************************
***************************************************************************

CalcDuration
	move.l	Interrupts(PC),D0
	mulu.w	dtg_Timer(A5),D0
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
	moveq	#6,D0
	move.l	D0,PI_Modulo(A0)	; Number of bytes to next row
	move.w	#32,PI_Pattlength(A0)	; Length of each stripe in rows

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

	moveq	#0,D0		; Period? Note?
	moveq	#0,D1		; Sample number
	moveq	#0,D2		; Command string
	moveq	#0,D3		; Command argument

	move.b	(A0),D0
	and.b	#$7F,D0
	beq.b	SkipIt
	cmp.b	#$7F,D0
	bne.b	VoiceOn
ClearIt
	clr.b	D0
	bra.b	SkipIt
VoiceOn
	cmp.b	#$7E,D0
	beq.b	ClearIt
	subq.b	#1,D0
	bcs.b	ClearIt
	asl.l	#1,D0
	lea	NoteTable(PC),A1
	move.w	0(A1,D0.L),D0
SkipIt
	move.b	1(A0),D1
	move.b	4(A0),D2
	move.b	5(A0),D3
	rts

***************************************************************************
******************************* DTP_BackPatt ******************************
***************************************************************************

BackPattern
	move.l	#TRACKLEN,trkcount	; whole track must be done
	move.l	entry(PC),A1		; A1 is current entry
	lea	-24(A1),A1
	cmp.l	firstentry(PC),A1
	bgt.s	Skip
	move.l	firstentry(pc),A1
Skip
	bra.w	Go

***************************************************************************
******************************* EP_StructInit *****************************
***************************************************************************

StructInit
	lea	StructAdr(PC),A0
	rts

***************************************************************************
************************* DTP_Volume, DTP_Balance *************************
***************************************************************************
; Copy Volume and Balance Data to internal buffer

SetBalance
SetVolume
	move.w	dtg_SndLBal(A5),D0
	mulu.w	dtg_SndVol(A5),D0
	lsr.w	#6,D0				; durch 64
	move.w	D0,LeftVolume

	move.w	dtg_SndRBal(A5),D0
	mulu.w	dtg_SndVol(A5),D0
	lsr.w	#6,D0				; durch 64
	move.w	D0,RightVolume			; Right Volume

	lea	OldVoice1(PC),A0
	lea	$DFF0A0,A1
	moveq	#3,D1
SetNew
	move.w	(A0)+,D0
	bsr.b	ChangeVolume
	addq.l	#8,A1
	addq.l	#8,A1
	dbf	D1,SetNew
	rts

ChangeVolume
	and.w	#$7F,D0
	cmpa.l	#$DFF0A0,A1			;Left Volume
	bne.b	NoVoice1
	move.w	D0,OldVoice1
	tst.w	Voice1
	bne.b	Voice1On
	moveq	#0,D0
Voice1On
	mulu.w	LeftVolume(PC),D0
	bra.b	SetIt

NoVoice1
	cmpa.l	#$DFF0B0,A1			;Right Volume
	bne.b	NoVoice2
	move.w	D0,OldVoice2
	tst.w	Voice2
	bne.b	Voice2On
	moveq	#0,D0
Voice2On
	mulu.w	RightVolume(PC),D0
	bra.b	SetIt

NoVoice2
	cmpa.l	#$DFF0C0,A1			;Right Volume
	bne.b	NoVoice3
	move.w	D0,OldVoice3
	tst.w	Voice3
	bne.b	Voice3On
	moveq	#0,D0
Voice3On
	mulu.w	RightVolume(PC),D0
	bra.b	SetIt

NoVoice3
	move.w	D0,OldVoice4
	tst.w	Voice4
	bne.b	Voice4On
	moveq	#0,D0
Voice4On
	mulu.w	LeftVolume(PC),D0
SetIt
	lsr.w	#6,D0
	move.w	D0,8(A1)
	rts

*------------------------------- Set Vol -------------------------------*

SetVol
	move.l	A2,-(A7)
	lea	StructAdr+UPS_Voice1Vol(PC),A2
	cmp.l	#$DFF0A0,A1
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice2Vol(PC),A2
	cmp.l	#$DFF0B0,A1
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice3Vol(PC),A2
	cmp.l	#$DFF0C0,A1
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice4Vol(PC),A2
.SetVoice
	move.w	D0,(A2)
	move.l	(A7)+,A2
	rts

***************************************************************************
******************************* EP_Voices *********************************
***************************************************************************

;		d0 Bit 0-3 = Set Voices Bit=1 Voice on

SetVoices
	lea	Voice1(PC),A0
	lea	StructAdr(PC),A1
	moveq	#1,D1
	move.w	D1,(A0)+			Voice1=0 setzen
	btst	#0,D0
	bne.b	No_Voice1
	clr.w	-2(A0)
	clr.w	$DFF0A8
	clr.w	UPS_Voice1Vol(A1)
No_Voice1
	move.w	D1,(A0)+			Voice2=0 setzen
	btst	#1,D0
	bne.b	No_Voice2
	clr.w	-2(A0)
	clr.w	$DFF0B8
	clr.w	UPS_Voice2Vol(A1)
No_Voice2
	move.w	D1,(A0)+			Voice3=0 setzen
	btst	#2,D0
	bne.b	No_Voice3
	clr.w	-2(A0)
	clr.w	$DFF0C8
	clr.w	UPS_Voice3Vol(A1)
No_Voice3
	move.w	D1,(A0)+			Voice4=0 setzen
	btst	#3,D0
	bne.b	No_Voice4
	clr.w	-2(A0)
	clr.w	$DFF0D8
	clr.w	UPS_Voice4Vol(A1)
No_Voice4
	move.w	D0,UPS_DMACon(A1)	;Stimme an = Bit gesetzt
					;Bit 0 = Kanal 1 usw.
	moveq	#0,D0
	rts

***************************************************************************
***************************** EP_GetPositionNr ****************************
***************************************************************************

GetPosition
	move.l	entry(PC),D0
	sub.l	firstentry(PC),D0
	divu.w	#12,D0
	rts

***************************************************************************
***************************** EP_Get_ModuleInfo ***************************
***************************************************************************

NewModuleInfo

SubSongs	=	4
LoadSize	=	12
SongSize	=	20
SamplesSize	=	28
Samples		=	36
CalcSize	=	44
SongName	=	52
Length		=	60
Author		=	68
Duration	=	76
Patterns	=	84

InfoBuffer
	dc.l	MI_SubSongs,0		;4
	dc.l	MI_LoadSize,0		;12
	dc.l	MI_Songsize,0		;20
	dc.l	MI_SamplesSize,0	;28
	dc.l	MI_Samples,0		;36
	dc.l	MI_Calcsize,0		;44
	dc.l	MI_SongName,0		;52
	dc.l	MI_Length,0		;60
	dc.l	MI_AuthorName,0		;68
	dc.l	MI_Duration,0		;76
	dc.l	MI_Pattern,0		;84
	dc.l	MI_MaxSubSongs,16
	dc.l	MI_MaxSamples,32
	dc.l	MI_MaxLength,256
	dc.l	MI_MaxPattern,256
	dc.l	MI_Prefix,Prefix
	dc.l	0

***************************************************************************
******************************* EP_SampleInit *****************************
***************************************************************************

SampleInit
	moveq	#EPR_NotEnoughMem,D7
	lea	EPG_SampleInfoStructure(A5),A3
	move.l	ModulePtr(PC),D0
	beq.b	Exitn
	move.l	D0,A2

	moveq	#31,D5
	lea	74(A2),A2
	move.l	SamplesPtr(PC),A1
hop
	jsr	ENPP_AllocSampleStruct(A5)
	move.l	D0,(A3)
	beq.b	Exitn
	move.l	D0,A3

	moveq	#0,D0
	move.w	(A2),D0
	lea	18(A2),A0

	move.l	A0,EPS_SampleName(A3)		; sample name
	move.l	A1,EPS_Adr(A3)			; sample address
	move.l	D0,EPS_Length(A3)		; sample length
	move.l	#64,EPS_Volume(A3)
	move.w	#USITY_RAW,EPS_Type(A3)
	move.w	#30,EPS_MaxNameLen(A3)
	move.w	#USIB_Playable!USIB_Saveable!USIB_8BIT,EPS_Flags(A3)
	lea	128(A2),A2
	add.l	D0,A1
	dbf	D5,hop

	moveq	#0,D7
Exitn
	move.l	D7,D0
	rts

***************************************************************************
******************************* DTP_Check2 ********************************
***************************************************************************

Check2
	movea.l	dtg_ChkData(A5),A0
	moveq	#-1,D0

	tst.b	(A0)
	bne.b	Fault
	move.l	dtg_ChkSize(A5),D1
	cmp.l	#7000,D1
	blt.b	Fault
	move.l	(A0),D2
	beq.b	Fault

	cmp.l	#$0000050F,$3C(A0)
	bne.s	CheckAnother
	cmp.l	#$0000050F,$40(A0)
	bne.s	CheckAnother
	bra.b	TME_OK

CheckAnother
	cmp.l	#$00040B11,$1284(A0)
	bne.s	CheckSize
	cmp.l	#$181E2329,$1188(A0)
	bne.s	CheckSize
	cmp.l	#$2F363C41,$128C(A0)
	bne.s	CheckSize
TME_OK
	moveq	#0,D0
Fault
	rts

CheckSize
	bsr.b	GetSize
	cmp.l	D2,A2
	beq.b	TME_OK
	bra.b	Fault
GetSize
	move.l	A0,A1
	move.l	A0,A2
	lea	$1AAA(A2),A2
	move.w	$1A84(A1),D3
	mulu.w	#12,D3
	add.l	D3,A2
	move.w	$1A86(A1),D3
	mulu.w	#6,D3
	add.l	D3,A2
	moveq	#0,D1
NextInuc
	addq.l	#4,A2
	tst.b	-4(A2)
	bne.b	NextInuc
	addq.l	#4,D1
	cmp.l	#$400,D1
	blt.b	NextInuc
	moveq	#0,D1
	lea	$44(A1),A1
NextSamp	tst.b	$18(A1,D1.L)
	beq.b	NoSample
	add.l	4(A1,D1.L),A2
NoSample	add.l	#$80,D1
	cmp.l	#$1000,D1
	blt.b	NextSamp
	sub.l	A0,A2
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

	lea	ModulePtr(PC),A6
	move.l	A0,(A6)+			; module buffer
	move.l	A5,(A6)+			; EagleBase
	lea	InfoBuffer(PC),A4
	move.l	D0,LoadSize(A4)
	move.l	(A0),D5
	cmp.l	D0,D5
	ble.b	SizeOK
	moveq	#EPR_ModuleTooShort,D0
	rts
SizeOK
	bsr.w	GetSize
	move.l	A2,CalcSize(A4)

	lea	4(A0),A1
	moveq	#0,D1
subloop
	tst.w	(A1)
	beq.b	noMoreSubs
	addq.l	#1,D1
	addq.l	#4,A1
	cmp.w	#16,D1
	beq.b	noMoreSubs
	bra.b	subloop
noMoreSubs
	move.l	D1,SubSongs(A4)

	lea	6794(A0),A1
	move.l	A1,SongName(A4)

	lea	74(A0),A1
	moveq	#31,D1
	moveq	#0,D2
	moveq	#0,D3
	moveq	#0,D4
NextInfo
	move.w	(A1),D2
	beq.b	NoSamp
	add.l	D2,D3
	addq.l	#1,D4
NoSamp
	lea	128(A1),A1
	dbf	D1,NextInfo
	move.l	D4,Samples(A4)
	move.l	D3,SamplesSize(A4)
	sub.l	D3,A2
	move.l	A2,SongSize(A4)
	move.w	6790(A0),D4
	lsr.l	#5,D4
	move.l	D4,Patterns(A4)

	add.l	A2,A0
	move.l	A0,(A6)+			; SamplesPtr

	move.l	Eagle2Base(PC),D0
	bne.b	Eagle2
	move.l	DeliBase(PC),D0
	bne.b	NoName
Eagle2
	bsr.b	FindName
	move.l	ModulePtr(PC),A0
	addq.l	#4,A0
	moveq	#0,D1
	move.b	1(A0),D1
	sub.b	(A0),D1
	subq.l	#1,D1
	moveq	#1,D4
	add.b	2(A0),D4		; song speed
	mulu.w	D4,D1		
	mulu.w	#$376B,D1		; dtg_Timer
        move.l	#(709379-3)/32,D3	; PAL ex_EClockFrequency/number of rows
	divu.w	D3,D1
	move.w	D1,Duration+2(A4)
NoName
	move.l	ModulePtr(PC),A0
	addq.l	#4,A0
	moveq	#0,D1
	move.b	1(A0),D1
	sub.b	(A0),D1
	subq.l	#1,D1
	moveq	#1,D4
	add.b	2(A0),D4		; song speed
	mulu.w	D4,D1		
	mulu.w	#32,D1			; number of rows
	move.l	D1,(A6)			; interrupts

	movea.l	dtg_AudioAlloc(A5),A0
	jmp	(A0)

FindName
	move.l	ModulePtr(PC),A0
	lea	92(A0),A1			; A1 - begin sampleinfo
	move.l	A1,EPG_ARG1(A5)
	moveq	#128/2,D0
	lsl.l	#1,D0				; D0 - length per one sampleinfo
	move.l	D0,EPG_ARG2(A5)
	moveq	#30,D0				; D0 - max. sample name
	move.l	D0,EPG_ARG3(A5)
	moveq	#32,D0				; D0 - max. samples number
	move.l	D0,EPG_ARG4(A5)
	moveq	#4,D0
	move.l	D0,EPG_ARGN(A5)
	jsr	ENPP_FindAuthor(A5)
	move.l	EPG_ARG1(A5),Author(A4)		; output
	rts

***************************************************************************
***************************** DTP_EndPlayer *******************************
***************************************************************************

EndPlayer
	movea.l	dtg_AudioFree(A5),A0
	jmp	(A0)

***************************************************************************
***************************** DTP_InitSound *******************************
***************************************************************************

InitSound
	lea	StructAdr(PC),A0
	lea	UPS_SizeOF(A0),A1
ClearUPS
	clr.w	(A0)+
	cmp.l	A0,A1
	bne.b	ClearUPS

	move.l	ModulePtr(PC),A0
	move.l	A0,A2
	bsr.w	MUSIC_InitData
	
	moveq	#0,D0
	move.w	dtg_SndNum(A5),D0
	move.l	D0,D1
	lsl.w	#2,D1
	lea	4(A2,D1.W),A2
	moveq	#0,D1
	move.b	1(A2),D1
	sub.b	(A2),D1
	lea	InfoBuffer(PC),A1
	move.l	D1,Length(A1)
	moveq	#1,D2
	add.b	2(A2),D2
	lea	PATTERNINFO(PC),A1
	move.w	D2,PI_Speed(A1)		; Speed Value

	bra.w	MUSIC_Play

***************************************************************************
***************************** DTP_EndSound ********************************
***************************************************************************

EndSound
	bra.w	MUSIC_Stop

***************************************************************************
***************************** DTP_Interrupt *******************************
***************************************************************************

Interrupt
	movem.l	D1-A6,-(A7)

	lea	StructAdr(PC),A4
	st	UPS_Enabled(A4)
	clr.w	UPS_Voice1Per(A4)
	clr.w	UPS_Voice2Per(A4)
	clr.w	UPS_Voice3Per(A4)
	clr.w	UPS_Voice4Per(A4)
	move.w	#UPSB_Adr!UPSB_Len!UPSB_Per!UPSB_Vol,UPS_Flags(A4)

	bsr.w	MUSIC_Player

	lea	StructAdr(PC),A0
	clr.w	UPS_Enabled(A0)
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

DMAWait
	movem.l	D0/D1,-(SP)
	moveq	#8,D0
.dma1	move.b	$DFF006,D1
.dma2	cmp.b	$DFF006,D1
	beq.b	.dma2
	dbeq	D0,.dma1
	movem.l	(SP)+,D0/D1
	rts

***************************************************************************
********************** The Musical Enlightenment player *******************
***************************************************************************

***************************************************************************
*                                                                         *
* PLAY - module for Packed TME song-files      (DEVPAC version)           *
*                                                                         *
* Made by N.J.   (1/1/90)                                                 *
*                                                                         *
***************************************************************************
*                                                                         *
*                                                                         *
* MUSIC_Player   Is a routine to be added to your vertical-blank-handler  *
*                                                                         *
* MUSIC_InitData Can be called when the songdata is loaded/present.       *
*                This must be done before your vertical blank is going !! *
*                A0 must point to the song data (in CHIP_MEM !!)          *
*                                                                         *
* MUSIC_Stop     Must/can be called to (temporarily) stop the player      *
*                                                                         *
* MUSIC_Play     Can be called to start a tune.                           *
*                D0 is the number of the tune to be played.               * 
*                                                                         *
* MUSIC_Continue Can be called to continue a tune after MUSIC_Stop        *
*                                                                         *
* MUSIC_Times    Sets the number of times to play a tune.                 *
*                D0 is this number (0 means forever)                      *
*                                                                         *
***************************************************************************

;	SECTION	MUSIC


;	INCLUDE	playmodule.i

;	XDEF	MUSIC_Player
;	XDEF	MUSIC_InitData
;	XDEF	MUSIC_Stop
;	XDEF	MUSIC_Play
;	XDEF	MUSIC_Continue
;	XDEF	MUSIC_Times


;*******************************************
;*                                         *
;*              STRUCTURES                 *
;*                                         *
;*******************************************

STRLEN     equ  32
MAXTUNE    equ  16
MAXINSTR   equ  32
MAXFX      equ  256
ARPLEN     equ  9
MAXARPS    equ  64
MAXLFOS    equ  16
LFOLEN     equ  128
TRACKLEN   equ  32
VOICE_OFF  equ  127
RELEASE    equ  126

samp_start   equ  0
samp_len     equ  4
samp_stlen   equ  8
samp_restoff equ  12
samp_restlen equ  16
samp_offlen  equ  20
samp_flags   equ  22
samp_SIZE    equ  24

tune_start   equ  0
tune_end     equ  1
tune_speed   equ  2
tune_mask    equ  3
tune_SIZE    equ  4

inuc_ins   equ 0
inuc_value equ 1
inuc_time  equ 2
inuc_SIZE  equ 4

envl_rate  equ 0
envl_level equ 3
envl_SIZE  equ 6

even_note   equ 0
even_sample equ 1
even_fx     equ 2
even_vol    equ 3
even_flags  equ 4
even_par    equ 5
even_SIZE   equ 6

entr_v0track   equ 0
entr_v0instadd equ 1
entr_v0noteadd equ 2
entr_v1track   equ 3
entr_v1instadd equ 4
entr_v1noteadd equ 5
entr_v2track   equ 6
entr_v2instadd equ 7
entr_v2noteadd equ 8
entr_v3track   equ 9
entr_v3instadd equ 10
entr_v3noteadd equ 11
entr_SIZE      equ 12

inst_sample equ 0
inst_name   equ samp_SIZE
inst_volume equ samp_SIZE+STRLEN
inst_eg     equ inst_volume+2
inst_fxmem  equ inst_eg+envl_SIZE
inst_SIZE   equ inst_fxmem+inuc_SIZE*16

song_len          equ 0
song_tune         equ song_len+4
song_instr        equ song_tune+tune_SIZE*MAXTUNE
song_arpeggio     equ song_instr+inst_SIZE*MAXINSTR
song_lfo          equ song_arpeggio+MAXARPS*ARPLEN
song_tableentries equ song_lfo+MAXLFOS*LFOLEN
song_events       equ song_tableentries+2
song_instructions equ song_events+2
song_name         equ song_instructions+2
song_SIZE         equ song_name+STRLEN

audi_start  equ 0
audi_len    equ 4
audi_period equ 6
audi_volume equ 8
audi_data   equ 10
audi_pad    equ 12
audi_SIZE   equ 16

fxda_src        equ 0
fxda_dst        equ 2
fxda_tolevel    equ 4
fxda_level      equ 5
fxda_tospeed    equ 6
fxda_speed      equ 7
fxda_pointer    equ 8
fxda_levelcount equ 12
fxda_speedcount equ 14
fxda_lfo        equ 16
fxda_SIZE       equ 20

voic_shadow       equ 0
voic_vibrato      equ audi_SIZE
voic_tremolo      equ voic_vibrato+fxda_SIZE
voic_special      equ voic_tremolo+fxda_SIZE
voic_instr        equ voic_special+fxda_SIZE
voic_event        equ voic_instr+4
voic_insp         equ voic_event+4
voic_egphase      equ voic_insp+4
voic_startphase   equ voic_egphase+2
voic_arpat        equ voic_startphase+2
voic_fxcount      equ voic_arpat+2
voic_gldcount     equ voic_fxcount+2
voic_egcount      equ voic_gldcount+4
voic_toperiod     equ voic_egcount+4
voic_egvolume     equ voic_toperiod+2
voic_basevolume   equ voic_egvolume+2
voic_egtovolume   equ voic_basevolume+2
voic_simplegldadd equ voic_egtovolume+2
voic_dma          equ voic_simplegldadd+2
voic_add          equ voic_dma+2
voic_arpeggio     equ voic_add+4
voic_arplen       equ voic_arpeggio+4
voic_nouse        equ voic_arplen+2
voic_doarpeggio   equ voic_nouse+1
voic_arpblow      equ voic_doarpeggio+1
voic_waitforfx    equ voic_arpblow+1
voic_basearpnote  equ voic_waitforfx+1
voic_arpcount     equ voic_basearpnote+1
voic_arponce      equ voic_arpcount+1
voic_arpspeed     equ voic_arponce+1
voic_SIZE         equ voic_arpspeed+1


;*******************************************
;*                                         *
;*                DEFINES                  *
;*                                         *
;*******************************************

BIT_ARPEGGIO    equ 0
BIT_SIMPLEGLIDE equ 1
BIT_NONOTEADD   equ 2
BIT_NOINSTADD   equ 3
BIT_SUPERGLIDE  equ 4
BIT_ARPONCE     equ 5
BIT_ARPBLOW     equ 6

ATT_PHASE equ 0
DEC_PHASE equ 1
REL_PHASE equ 2
SUS_PHASE equ 3

STARTSAMPLE equ 2
REPSAMPLE   equ 1
KILLSAMPLE  equ 0

BIT_SPECIAL equ 0

tune        ds.l	1
firstentry  ds.l	1
lastentry   ds.l	1
entry       ds.l	1
spdcount    ds.l	1
trkcount    ds.l	1
times       ds.l	1
dmacon      ds.w	1
song        ds.l	1
tableentry  ds.l	1
event       ds.l	1
fx          ds.b	inuc_SIZE*MAXFX
voice       ds.b	voic_SIZE*4
NoteTable   dc.w	856,808,762,720,678,640,604,570,538,508,480,453
            dc.w	428,404,381,360,339,320,302,285,269,254,240,226
            dc.w	214,202,190,180,170,160,151,143,135,127,120,113
tabel       dc.w	1,2,1


***************************************************************************
*                                                                         *
* NEWTRACK    handles the jump over tracks, pointers are recalculated.    *
*                                                                         *
***************************************************************************

NewTrack
	move.l	#TRACKLEN,trkcount	; whole track must be done
	move.l	entry(PC),a1		; A1 is current entry
Go

		move.l	A3,-(SP)
		lea	PATTERNINFO+PI_Stripes(PC),A3

	lea	voice(PC),a0		; A0 is voice
	moveq.l	#3,d1
vloop5	moveq.l	#0,d0
	move.b	(a1)+,d0
	asl.l	#5,d0			; Put
	mulu.w	#6,d0			; track*6 << 5  +  event
	add.l	event(PC),d0		; into voicedata
	move.l	d0,voic_event(a0)	; and

		move.l	D0,(A3)+

	move.l	a1,voic_add(a0)		; address of add is copied
	addq.l	#2,a1
	add.l	#voic_SIZE,a0
	dbra	d1,vloop5

		move.l	(SP)+,A3

        cmp.l	lastentry(PC),a1
        bne.b	nstrt			; Is it the last

		bsr.w	SongEnd

        move.l	firstentry(PC),a1	;   then make first
;        sub.l	#1,times		;   and one less to play
nstrt   move.l	a1,entry		; store for next time
        rts

***************************************************************************
*                                                                         *
* NEWNOTES    handles the new notes, every time the spdcounter reaches 0  *
*                                                                         *
***************************************************************************

NewNotes
	movem.l	a2/a3/a5/a6,-(sp)
	lea	voice(PC),a2			; a2 is at current voicedata
	lea	NoteTable(PC),a5		; a5 is at NoteTable
	move.l	tune(PC),a0
	moveq.l	#0,d3
	move.b	tune_mask(a0),d3		; d3 is mask for voices
	moveq.l	#3,d2				; 4 voices (so dbra from 3)
vloop3	move.l	voic_event(a2),a3		; a3 is at current event
	move.l	voic_add(a2),a6			; a6 is at table-adds
	move.l	voic_instr(a2),a1		; a1 is at instrument
	add.l	#even_SIZE,voic_event(a2)
	tst.b	voic_nouse(a2)			; is it a superglide-dest ?
	beq.b	weluse				;   then next will be used
	clr.b	voic_nouse(a2)			;   and goto next voice
	bra.w	nxtv3
weluse	move.b	even_note(a3),d0		; d0 is (long) note
	and.l	#127,d0				; is it 0 ?
	beq.w	nxtv3				;   then try next voice
	cmp.b	#VOICE_OFF,d0
	bne.b	voicon				; is it VOICE_OFF ?
	move.w	voic_dma(a2),d0			;   then
	and.w	d3,d0				;   custom.dmacon=mask|dma
	move.w	d0,$dff096			;   and goto next voice
	bra.w	nxtv3
voicon	cmp.b	#RELEASE,d0			; is it RELEASE ?
	bne.b	norel				;   then set egphase
	move.w	#REL_PHASE,voic_egphase(a2)
	bra.w	nxtv3
norel	btst.b	#BIT_NONOTEADD,even_flags(a3)
	bne.b	noad1
	add.b	1(a6),d0			; try to add the noteadd
noad1	subq.b	#1,d0				; is the note not legal ?
	bcs.w	nxtv3				;   then try next voice
	move.b	d0,voic_basearpnote(a2)		; put in basearpnote
	asl.l	#1,d0				; get period from table
	move.w	(a5,d0.l),voic_vibrato+fxda_src(a2)
	moveq.l	#0,d0
	btst.b	#BIT_SIMPLEGLIDE,even_flags(a3)
	beq.b	pokeadd				; get simpleglide-add in D0
	move.b	even_par(a3),d0
	ext.w	d0
pokeadd	move.w	d0,voic_simplegldadd(a2)
	clr.b	voic_doarpeggio(a2)		; clear doarpeggio
	moveq.l	#0,d1
	move.b	even_par(a3),d1			; get unsigned par in D1
	btst.b	#BIT_SUPERGLIDE,even_flags(a3)
	beq.b	nosuper				; is it SUPERGLIDE ?
	move.b	even_SIZE+even_note(a3),d0	;   get next note
	and.l	#127,d0
	btst.b	#BIT_NONOTEADD,even_flags(a3)	;   and add
	bne.b	noadd2
	add.b	1(a6),d0
noadd2	subq.b	#1,d0				;   is note not legal ?
	bcs.w	clrgld				;   then no glide, no arp
	asl.l	#1,d0
	move.w	(a5,d0.l),voic_toperiod(a2)	;   get period
	addq.l	#1,d1
	move.l	d1,voic_gldcount(a2)		;   glidecount is par+1
	move.b	#1,voic_nouse(a2)		;   next note is not used
	bra.b	noarp
nosuper	btst.b	#BIT_ARPEGGIO,even_flags(a3)	; is it ARPEGGIO ?
	beq.b	clrgld				;   then
	clr.b	voic_arponce(a2)		;   get ARPONCE-value
	btst.b	#BIT_ARPONCE,even_flags(a3)	;   (1 when once)
	beq.b	notonce
	move.b	#1,voic_arponce(a2)
notonce	move.b	even_flags(a3),d0		;   get ARPBLOW-tstvalue
	and.b	#64,d0
	move.b	d0,voic_arpblow(a2)
	mulu.w	#ARPLEN,d1
	move.l	song(PC),a0
	add.l	#song_arpeggio+1,a0		;   get start of arpeggio
	add.l	d1,a0
	move.l	a0,voic_arpeggio(a2)
	move.b	-1(a0),d0			;   before this stands
	moveq.l	#0,d1				;   - len<<4|speed -
	move.b	d0,d1
	and.b	#15,d0
	move.b	d0,voic_arpspeed(a2)		;   get speed
	addq.b	#1,d0				;   for the  first:
	move.b	d0,voic_arpcount(a2)		;   count = speed + 1
	lsr.w	#4,d1
	bne.b	pokelen
	move.l	#8,d1				;   default len is 8
pokelen	move.w	d1,voic_arplen(a2)		;   poke len
	subq.w	#1,d1
	move.b	d1,voic_doarpeggio(a2)		;   doarpeggio is len-1
	clr.w	voic_arpat(a2)			;   start at begin of arp
clrgld	clr.l	voic_gldcount(a2)		;   no glide here
noarp	btst.b	#7,even_note(a3)
	bne.w	noblow				; is the note blown ?
	clr.w	voic_egphase(a2)		;   then
	clr.w	voic_egvolume(a2)		;   set new EG-values
	clr.l	voic_egcount(a2)		;   and sample-phase
	move.w	#STARTSAMPLE,voic_startphase(a2)
	moveq.l	#0,d0
	move.b	even_sample(a3),d0
	beq.b	samein				;   a new instrument ?
	subq.b	#1,d0				;     then
	btst.b	#BIT_NOINSTADD,even_flags(a3)	;     get instr-no
	bne.b	noadd3				;          (plus add)
	add.b	(a6),d0
	and.b	#$1f,d0				;     (ensure legality)
noadd3	asl.l	#7,d0
	move.l	song(PC),a1
	add.l	#song_instr,a1			;     to instr-pointer
	add.l	d0,a1				;     into A1
	move.l	a1,voic_instr(a2)		;     and the structure
samein	move.w	voic_dma(a2),d0
	and.w	d3,d0				;   clr custom.dmacon,
	or.w	d0,dmacon			;   and prepare to set
	move.w	d0,$dff096
	moveq.l	#0,d0
	move.b	even_fx(a3),d0			;   get fx-pointer
	beq.b	deffx
	asl.l	#2,d0				;   non-default is from
	lea	fx(PC),a0			;   the song structure
	move.l	(a0,d0.l),a0
	bra.b	pokefx				;   default comes from
deffx	lea	inst_fxmem(a1),a0		;   the instrument
pokefx	move.l	a0,voic_insp(a2)
	clr.b	voic_vibrato+fxda_level(a2)	;   clear all fx-levels
	clr.b	voic_vibrato+fxda_speed(a2)	;   and fx-speeds
	clr.b	voic_tremolo+fxda_level(a2)
	clr.b	voic_tremolo+fxda_speed(a2)
	clr.b	voic_special+fxda_level(a2)
	clr.b	voic_special+fxda_speed(a2)
	clr.l	voic_vibrato+fxda_pointer(a2)
	clr.l	voic_tremolo+fxda_pointer(a2)
	clr.l	voic_special+fxda_pointer(a2)	;   let TryNewFx do it...
	move.b	#1,voic_waitforfx(a2)		;   we are ready with waiting
	clr.w	voic_fxcount(a2)
noblow	move.b	inst_volume(a1),d0		; get instr-volume
	add.b	even_vol(a3),d0			; and add the volume-add
	ext.w	d0				; into the basevolume
	move.w	d0,voic_basevolume(a2)
nxtv3	add.l	#voic_SIZE,a2			; next voicedata
	dbra	d2,vloop3			; go again until all 4 voices
	movem.l	(sp)+,a2/a3/a5/a6		; are done
	rts

***************************************************************************
*                                                                         *
* TRYNEWFX    walks over the fx, every time the fxcounter reaches 0       *
*                                                                         *
***************************************************************************

TryNewFx
	movem.l	a2/a3,-(sp)
	lea	voice(PC),a2			; A2 is at voicedata
	move.l	song(PC),a1
	add.l	#song_lfo,a1			; A1 is at lfo
	moveq.l	#3,d3
vloop4	tst.b	voic_waitforfx(a2)		; are we waiting ?
	beq.b	nxtv4				;   if not then next voice
	subq.w	#1,voic_fxcount(a2)		;   dec fxcount
	bcc.b	nxtv4				;   if not ready then next
	move.l	voic_insp(a2),a3		;   A3 is instruction-pointer
iloop	move.b	inuc_ins(a3),d0
	and.l	#$f0,d0
	lsr.l	#3,d0				;   instruction in D0
	move.w	jmptab(pc,d0.w),d0		;   get jump-offset
jmpfrom	jmp	jmpfrom(pc,d0.w)		;   jump to right routine
nxtv4	add.l	#voic_SIZE,a2			;   get next voicedata
	dbra	d3,vloop4			;   for all 4 voices
	movem.l	(sp)+,a2/a3
	rts
jmptab	dc.w	stop-jmpfrom			; 0 = STOP
	dc.w	vlev-jmpfrom			; 1 = VIBRATO.level
	dc.w	vspd-jmpfrom			; 2 = VIBRATO.speed
	dc.w	tlev-jmpfrom			; 3 = TREMOLO.level
	dc.w	tspd-jmpfrom			; 4 = TREMOLO.speed
	dc.w	slev-jmpfrom			; 5 = SPECIAL.level
	dc.w	sspd-jmpfrom			; 6 = SPECIAL.speed
	dc.w	dela-jmpfrom			; 7 = DELAY
	dc.w	goto-jmpfrom			; 8 = GOTO
stop	clr.b	voic_waitforfx(a2)
	bra.b	nxtv4
vlev	move.b	inuc_value(a3),voic_vibrato+fxda_tolevel(a2)
	move.w	inuc_time(a3),voic_vibrato+fxda_levelcount(a2)
	addq.w	#1,voic_vibrato+fxda_levelcount(a2)
	move.b	inuc_ins(a3),d0
	and.l	#15,d0
	asl.l	#7,d0
	add.l	a1,d0
	move.l	d0,voic_vibrato+fxda_lfo(a2)
	add.l	#inuc_SIZE,a3
	bra.b	iloop
vspd	move.b	inuc_value(a3),voic_vibrato+fxda_tospeed(a2)
	move.w	inuc_time(a3),voic_vibrato+fxda_speedcount(a2)
	addq.w	#1,voic_vibrato+fxda_speedcount(a2)
	add.l	#inuc_SIZE,a3
	bra.w	iloop
tlev	move.b	inuc_value(a3),voic_tremolo+fxda_tolevel(a2)
	move.w	inuc_time(a3),voic_tremolo+fxda_levelcount(a2)
	addq.w	#1,voic_tremolo+fxda_levelcount(a2)
	move.b	inuc_ins(a3),d0
	and.l	#15,d0
	asl.l	#7,d0
	add.l	a1,d0
	move.l	d0,voic_tremolo+fxda_lfo(a2)
	add.l	#inuc_SIZE,a3
	bra.w	iloop
tspd	move.b	inuc_value(a3),voic_tremolo+fxda_tospeed(a2)
	move.w	inuc_time(a3),voic_tremolo+fxda_speedcount(a2)
	addq.w	#1,voic_tremolo+fxda_speedcount(a2)
	add.l	#inuc_SIZE,a3
	bra.w	iloop
slev	move.b	inuc_value(a3),voic_special+fxda_tolevel(a2)
	move.w	inuc_time(a3),voic_special+fxda_levelcount(a2)
	addq.w	#1,voic_special+fxda_levelcount(a2)
	move.b	inuc_ins(a3),d0
	and.l	#15,d0
	asl.l	#7,d0
	add.l	a1,d0
	move.l	d0,voic_special+fxda_lfo(a2)
	add.l	#inuc_SIZE,a3
	bra.w	iloop
sspd	move.b	inuc_value(a3),voic_special+fxda_tospeed(a2)
	move.w	inuc_time(a3),voic_special+fxda_speedcount(a2)
	addq.w	#1,voic_special+fxda_speedcount(a2)
	add.l	#inuc_SIZE,a3
	bra.w	iloop
dela	move.w	inuc_time(a3),voic_fxcount(a2)
	add.l	#inuc_SIZE,a3
	move.l	a3,voic_insp(a2)
	bra.w	nxtv4
goto	moveq.l	#0,d0
	move.b	inuc_value(a3),d0
	asl.l	#2,d0
	lea	fx(PC),a0
	move.l	(a0,d0.l),a3
	bra.w	iloop

***************************************************************************
*                                                                         *
* CALCFXDATA  calculates vibrato/tremolo fxvalues, every frame 3x         *
*                                                                         *
***************************************************************************

CalcFxData
	move.b	fxda_tolevel(a1),d0	; are we going somewhere ?
	beq.b	jcopy			; if not then just copy src to dst
	tst.w	fxda_levelcount(a1)
	beq.b	levred			; is level not yet OK ?
	sub.b	fxda_level(a1),d0	;   then get difference with tolevel
	ext.w	d0			;   into long
	ext.l	d0
	divs.w	fxda_levelcount(a1),d0	;   and part of it
	add.b	d0,fxda_level(a1)	;   must be added to the level
	subq.w	#1,fxda_levelcount(a1)	;   (less to go)
levred	tst.w	fxda_speedcount(a1)
	beq.b	spdred			; is speed not yet OK ?
	move.b	fxda_tospeed(a1),d0	;   then get difference from
	sub.b	fxda_speed(a1),d0	;   tospeed and speed
	ext.w	d0			;   into long
	ext.l	d0
	divs.w	fxda_speedcount(a1),d0	;   and part of it
	add.b	d0,fxda_speed(a1)	;   must be added to speed
	subq.w	#1,fxda_speedcount(a1)	;   (less to go)
spdred	move.l	fxda_pointer(a1),d1
	move.l	fxda_lfo(a1),a0
	move.b	(a0,d1.l),d0		; get current lfo-value
	ext.w	d0			; into word D0
	moveq.l	#0,d1
	move.b	fxda_level(a1),d1	; multiply
	muls.w	d1,d0			; with unsigned word-level
	lsr.l	d2,d0			; shift by second parameter
	add.w	fxda_src(a1),d0		; and add source to it
	move.w	d0,fxda_dst(a1)		; into destination
	move.b	fxda_speed(a1),d0	
	add.b	d0,fxda_pointer+3(a1)	; add speed to pointer
	and.l	#127,fxda_pointer(a1)	; keep it within range
	rts
jcopy	move.w	fxda_src(a1),fxda_dst(a1)
	rts

***************************************************************************
*                                                                         *
* CALCFX      calculates all (new) dma-values, every frame again          *
*                                                                         *
***************************************************************************

CalcFx
	movem.l	d5/a2/a3/a5/a6,-(sp)
	lea	voice(PC),a2			; A2 is at voicedata
	lea	NoteTable(PC),a5		; A5 is at NoteTable
	lea	tabel(PC),a6			; A6 is at phase-add table
	move.l	tune(PC),a0
	moveq.l	#0,d3
	move.b	tune_mask(a0),d3		; D3 is mask
	moveq.l	#3,d5

vloop1	move.l	voic_instr(a2),D0
	beq.w	nxtv1			; fix
	move.l	D0,a3			; A3 is at instrument

	move.w	voic_simplegldadd(a2),d0	; add simplegldadd
	add.w	d0,voic_vibrato+fxda_src(a2)	; to vibrato.src
	move.l	voic_gldcount(a2),d1
	beq.b	nogld
	moveq.l	#0,d0				; do we have SUPERGLIDE ?
	moveq.l	#0,d2				;   then
	move.w	voic_toperiod(a2),d0		;   get difference of
	move.w	voic_vibrato+fxda_src(a2),d2	;   unsigned values
	sub.l	d2,d0				;   and part of it
	divs.w	d1,d0				;   is added to the
	add.w	d0,voic_vibrato+fxda_src(a2)	;   vibrato.src
	subq.l	#1,voic_gldcount(a2)		;   (less to go)
	bra.b	dovibr				;   no arpeggio...
nogld	tst.b	voic_doarpeggio(a2)
	beq.b	dovibr				; do we have ARPEGGIO ?
	moveq.l	#0,d0				;   then
	move.w	voic_arpat(a2),d1		;   get pointer in D1
	subq.b	#1,voic_arpcount(a2)		;   switch to next arpnote ?
	bcc.b	hanarp				;     then
	addq.w	#1,d1				;     move pointer
	divu.w	voic_arplen(a2),d1		;     through arpeggio
	swap	d1				;     (MOD arplen)
	move.w	d1,voic_arpat(a2)
	move.b	voic_arpspeed(a2),voic_arpcount(a2)
	move.b	voic_arponce(a2),d0		;     reset counter
	sub.b	d0,voic_doarpeggio(a2)		;     (dec doarpeggio)
	tst.b	voic_arpblow(a2)
	beq.b	hanarp				;     should arp be blown ?
	move.w	#STARTSAMPLE,voic_startphase(a2);       then
	clr.w	voic_egphase(a2)		;       set startphase
	clr.l	voic_egcount(a2)		;       set new EG-values
	clr.w	voic_egvolume(a2)		;       and clr dmabit
	move.w	voic_dma(a2),d0			;       (prepare for set)
	and.w	d3,d0
	or.w	d0,dmacon
	move.w	d0,$dff096			;   and
hanarp	move.b	voic_basearpnote(a2),d0		;   Handle ARPEGGIO-period
	move.l	voic_arpeggio(a2),a0
	add.b	(a0,d1.w),d0
	asl.l	#1,d0
	move.w	(a5,d0.l),voic_vibrato+fxda_src(a2)
dovibr	moveq.l	#7,d2				; Calc vibrato with
	lea	voic_vibrato(a2),a1		; shift is 7
	bsr.w	CalcFxData
	move.w	voic_vibrato+fxda_dst(a2),d0
	cmp.w	#113,d0
	bge.b	okper
	move.w	#113,d0				; set period to minimum
okper	move.w	d0,voic_shadow+audi_period(a2)	; of 113
	move.l	voic_egcount(a2),d1
	beq.b	newpha				; busy in EG-phase ?
	moveq.l	#0,d0				;   then
	moveq.l	#0,d2				;   get difference of
	move.w	voic_egtovolume(a2),d0		;   unsigned values
	move.w	voic_egvolume(a2),d2		;   and add
	sub.l	d2,d0				;   part of it
	divs.w	d1,d0				;   to the current volume
	add.w	d0,voic_egvolume(a2)		;   (less to go)
	subq.l	#1,voic_egcount(a2)
	bra.b	nocha				;   else
newpha	move.w	voic_egphase(a2),d2		;   D2 is egphase
	cmp.l	#SUS_PHASE,d2			;   is it in SUSTAIN ?
	beq.b	nocha				;     then nothing changes
	moveq.l	#0,d0
	move.b	inst_eg+envl_rate(a3,d2.w),d0
	addq.l	#1,d0				;   egcount    := rate + 1
	move.l	d0,voic_egcount(a2)		;   egtovolume := level
	move.b	inst_eg+envl_level(a3,d2.w),voic_egtovolume+1(a2)
	asl.w	#1,d2				;   get next egphase
	move.w	(a6,d2.w),d1			;   with adds-tabel
	add.w	d1,voic_egphase(a2)
nocha	move.w	voic_basevolume(a2),d0
	muls.w	voic_egvolume(a2),d0		; get src-volume
	asr.w	#8,d0				; from base- and egvolume
	move.w	d0,voic_tremolo+fxda_src(a2)	; and calc the tremolo
	moveq.l	#9,d2				; with shift 9
	lea	voic_tremolo(a2),a1
	bsr.w	CalcFxData
	move.w	voic_tremolo+fxda_dst(a2),d0
	cmp.w	#64,d0
	ble.b	okvol				; maximize volume to 64
	moveq.l	#64,d0
okvol	move.w	d0,voic_shadow+audi_volume(a2)
	tst.w	voic_startphase(a2)		; get start and length
	beq.b	nxtv1				; according to current
	cmp.w	#STARTSAMPLE,voic_startphase(a2); startphase
	bne.b	repsam
	move.l	inst_sample+samp_start(a3),voic_shadow+audi_start(a2)
	move.w	inst_sample+samp_stlen+2(a3),voic_shadow+audi_len(a2)

		move.l	inst_sample+samp_start(A3),(A4)
		move.w	inst_sample+samp_len+2(A3),D0
		lsr.w	#1,D0
		move.w	D0,UPS_Voice1Len(A4)
		move.w	voic_shadow+audi_period(A2),UPS_Voice1Per(A4)

	move.w	#1,voic_startphase(a2)
	bra.b	nxtv1
repsam	move.l	inst_sample+samp_start(a3),voic_shadow+audi_start(a2)
	move.l	inst_sample+samp_restoff(a3),d0
	asl.l	#1,d0
	add.l	d0,voic_shadow+audi_start(a2)
	move.w	inst_sample+samp_restlen+2(a3),voic_shadow+audi_len(a2)
	clr.w	voic_startphase(a2)
nxtv1	add.l	#voic_SIZE,a2

		lea	UPS_Modulo(A4),A4

	dbra	d5,vloop1
	movem.l	(sp)+,d5/a2/a3/a5/a6
	rts


***************************************************************************
*                                                                         *
* GLOBAL routines                                                         *
*                                                                         *
***************************************************************************

MUSIC_Player
	movem.l	d4/a2,-(sp)
;	move.l	times,d0
;	beq	return			; if !times return (no play).
	move.l	tune(PC),a2		; A2 is at tune
	moveq.l	#0,d4			; D4 is mask
	move.b	tune_mask(a2),d4
	tst.w	dmacon
	beq.b	nodma			; must we set some bits ?
	move.w	dmacon(PC),d0		;   then
	or.w	#$8200,d0		;   set them
	move.w	d0,$dff096		;   (already masked)
	clr.w	dmacon

		bsr.w	DMAWait

nodma	subq.b	#1,spdcount		; time for new notes ?
	bcc.b	nonewno			;   then
	move.b	2(a2),spdcount		;   reset spdcount

		movem.l	D0/A0,-(SP)
		moveq	#32,D0
		sub.l	trkcount(PC),D0
		lea	PATTERNINFO(PC),A0
		move.w	D0,PI_Pattpos(A0)	; Current Position in Pattern
		move.l	entry(PC),D0
		sub.l	firstentry(PC),D0
		divu.w	#12,D0
		move.w	D0,PI_Songpos(A0)
		movem.l	(SP)+,D0/A0

	subq.l	#1,trkcount		;   time for new track ?
	bne.b	nonewtr
	bsr.w	NewTrack		;     then New Track
nonewtr	bsr.w	NewNotes		;   New Notes
nonewno	bsr.w	TryNewFx		; walk through fx
	bsr.w	CalcFx			; calc all dma-values
	moveq.l	#3,d1
	lea	voice(PC),a0		; A0 is at voicedata
	move.l	#$dff0a0,a1		; A1 is at hardware-audio
vloop2	move.w	d4,d0			; if mask is set ?
	and.w	voic_dma(a0),d0		;   then poke dma-values
	beq.b	nxtv2
	move.l	voic_shadow+audi_start(a0),audi_start(a1)
	move.w	voic_shadow+audi_len(a0),audi_len(a1)
	move.w	voic_shadow+audi_period(a0),audi_period(a1)
;	move.w	voic_shadow+audi_volume(a0),audi_volume(a1)

		move.l	D0,-(SP)
		move.w	voic_shadow+audi_volume(A0),D0
		bsr.w	ChangeVolume
		bsr.w	SetVol
		move.l	(SP)+,D0

nxtv2	add.l	#voic_SIZE,a0		; get next voicedata
	add.l	#audi_SIZE,a1		; and next audio-channel
	dbra	d1,vloop2		; until all voices are done
return	movem.l	(sp)+,d4/a2
	rts

MUSIC_InitData
	move.w	#255,$dff09e
	move.l	a0,song			; ->  Song structure
	move.l	a0,a1
	add.l	#song_SIZE,a0
	move.l	a0,tableentry		; ->  TableEntries
	move.w	song_tableentries(a1),d0
	mulu.w	#entr_SIZE,d0
	add.l	d0,a0
	move.l	a0,event		; ->  Events
	move.w	song_events(a1),d0
	mulu.w	#even_SIZE,d0
	add.l	d0,a0
	moveq.l	#0,d1
	lea	fx(PC),a1			; ->  Fx
fxloop	move.l	a0,(a1,d1.l)
inloop	add.l	#inuc_SIZE,a0
	tst.b	inuc_ins-inuc_SIZE(a0)
	bne.b	inloop
	add.l	#inuc_SIZE,d1
	cmp.l	#inuc_SIZE*MAXFX,d1
	blt.b	fxloop
	move.l	#0,d1
	move.l	song(PC),a1
	add.l	#song_instr,a1
instl	tst.b	inst_name(a1,d1.l)	; -> Sample Data
	beq.b	nextin
	move.l	a0,inst_sample+samp_start(a1,d1.l)
	add.l	inst_sample+samp_len(a1,d1.l),a0
nextin	add.l	#inst_SIZE,d1
	cmp.l	#inst_SIZE*MAXINSTR,d1
	blt.b	instl

MUSIC_Stop
;	move.l	#0,times		; no playing,
	move.w	#15,$dff096		; clear dma
	bclr    #1,$bfe001		; and LED on
	clr.w	dmacon
	rts

MUSIC_Play
	asl.l	#2,d0
	move.l	song(PC),a1
	add	#song_tune,a1
	add.l	d0,a1
	move.l	a1,tune			; get pointer to current tune
	bsr.b	MUSIC_Stop		; and stop the music
	move.b	tune_start(a1),d0
	or.b	tune_end(a1),d0
	bne.b	normal			; not from 0 to 0 ...
	rts
normal	moveq.l	#0,d0
	move.b	tune_start(a1),d0
	mulu.w	#entr_SIZE,d0
	add.l	tableentry(PC),d0
	move.l	d0,firstentry		; set first,
	moveq.l	#0,d0			; and lastentry
	move.b	tune_end(a1),d0
	mulu.w	#entr_SIZE,d0
	add.l	tableentry(PC),d0
	move.l	d0,lastentry
	move.w	#1,voice+voic_SIZE*0+voic_dma
	move.w	#2,voice+voic_SIZE*1+voic_dma
	move.w	#4,voice+voic_SIZE*2+voic_dma
	move.w	#8,voice+voic_SIZE*3+voic_dma
	move.w	#0,voice+voic_SIZE*0+voic_egtovolume
	move.w	#0,voice+voic_SIZE*1+voic_egtovolume
	move.w	#0,voice+voic_SIZE*2+voic_egtovolume
	move.w	#0,voice+voic_SIZE*3+voic_egtovolume
	move.l	firstentry(PC),d0
	add.l	#entr_SIZE,d0
	move.l	d0,entry		; entry is firstentry+1

MUSIC_Continue
	bsr.w	MUSIC_Stop		; first stop the music
	move.l	tune(PC),a0		; set new spdcount
	clr.l	spdcount
	move.b	tune_speed(a0),spdcount+3
	move.l	entry(PC),a0
	cmp.l	firstentry(PC),a0	; go back one entry
	bne.b	okentr
	move.l	lastentry(PC),a0
okentr	sub.l	#entr_SIZE,a0
	move.l	a0,entry
	bsr.w	NewTrack		; and prepare for this track
	addq.l	#1,trkcount
	move.l	tune(PC),a1
	btst.b	#4,tune_mask(a1)	; handle LED for this tune
	beq.b	ledon
	bset    #1,$bfe001
	bra.b	okled
ledon	bclr    #1,$bfe001
okled
;	move.l	#$ffffffff,times	; START play endlessly
	rts

;MUSIC_Times
;	tst.l	d0
;	bne	oktime
;	move.l	#$ffffffff,d0
;oktime	move.l	d0,times
;	rts

	*****************************************************
	****     PumaTracker replayer for EaglePlayer, 	 ****
	****	     all adaptions by Wanted Team	 ****
	****      DeliTracker compatible (?) version	 ****
	*****************************************************

	incdir	"dh2:include/"
	include 'misc/eagleplayer2.01.i'

	SECTION	Player_Code,CODE

	PLAYERHEADER Tags

	dc.b	'$VER: PumaTracker player module V1.0 (28 Dec 2001)',0
	even
Tags
	dc.l	DTP_PlayerVersion,1
	dc.l	EP_PlayerVersion,9
	dc.l	DTP_RequestDTVersion,DELIVERSION
	dc.l	DTP_PlayerName,PlayerName
	dc.l	DTP_Creator,Creator
	dc.l	DTP_Check2,Check2
	dc.l	DTP_InitPlayer,InitPlayer
	dc.l	DTP_Interrupt,Interrupt
	dc.l	DTP_EndPlayer,EndPlayer
	dc.l	DTP_InitSound,InitSound
	dc.l	DTP_EndSound,EndSound
	dc.l	DTP_Volume,SetVolume
	dc.l	DTP_Balance,SetBalance
	dc.l	EP_Voices,SetVoices
	dc.l	EP_StructInit,StructInit
	dc.l	EP_NewModuleInfo,NewModuleInfo
	dc.l	EP_GetPositionNr,GetPosition
	dc.l	EP_SampleInit,SampleInit
	dc.l	DTP_NextPatt,NextPattern
	dc.l	DTP_PrevPatt,PrevPattern
	dc.l	EP_PatternInit,PatternInit
	dc.l	EP_Flags,EPB_Volume!EPB_Balance!EPB_ModuleInfo!EPB_Voices!EPB_SampleInfo!EPB_Save!EPB_PrevPatt!EPB_NextPatt!EPB_Songend!EPB_Analyzer!EPB_Packable!EPB_Restart
	dc.l	DTP_Duration,CalcDuration
	dc.l	0

PlayerName
	dc.b	'PumaTracker',0
Creator
	dc.b	'(c) 1991 by Jean-Charles Meyrignac &',10
	dc.b	'Pierre-Eric Loriaux, adapted by WT',0
Prefix	dc.b	'PUMA.',0
	even
ModulePtr
	dc.l	0
EagleBase
	dc.l	0
Interrupts
	dc.l	0
RightVolume
	dc.w	64
LeftVolume
	dc.w	64
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

	moveq	#4,D0
	move.w	D0,PI_Voices(A0)	; Number of stripes (MUST be at least 4)
	move.l	#CONVERTNOTE,PI_Convert(A0)
	move.l	D0,PI_Modulo(A0)	; Number of bytes to next row
	move.w	#32,PI_Pattlength(A0)	; Length of each stripe in rows

	move.w	#2,PI_Speed(A0)		; Default Speed Value
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
	beq.b	NoNote
	lea	lbW00064E(PC),A1
	move.w	0(A1,D0.W),D0
	cmp.w	#$650,D0
	bls.b	NoNote
	move.w	#$650,D0
NoNote
	move.b	1(A0),D1
	and.b	#31,D1
	move.b	1(A0),D2
	lsr.w	#5,D2
	move.b	2(A0),D3
	rts

PATINFO
	move.l	A0,-(SP)
	lea	PATTERNINFO(PC),A0
	move.b	lbB00064B(PC),PI_Pattpos+1(A0)	; Current Position in Pattern
	move.b	lbB00064C(PC),PI_Songpos+1(A0)
	move.b	lbB0001F1(PC),PI_Speed+1(A0)	; Speed Value
	move.l	(SP)+,A0
	rts

***************************************************************************
******************************* DTP_NextPatt ******************************
***************************************************************************

NextPattern
	move.l	dtg_StopInt(A5),A0
	jsr	(A0)
	move.b	#$20,lbB00064B
	bsr.w	Play
	move.l	EagleBase(PC),A5
	move.l	dtg_StartInt(A5),A0
	jsr	(A0)
	rts

***************************************************************************
******************************* DTP_PrevPatt ******************************
***************************************************************************

PrevPattern
	move.l	dtg_StopInt(A5),A0
	jsr	(A0)
	tst.b	lbB00064C
	beq.b	MinPos
	subq.b	#2,lbB00064C
	bra.b	NoMinPos
MinPos
	st	lbB00064C
NoMinPos
	move.b	#$20,lbB00064B
	bsr.w	Play
	move.l	EagleBase(PC),A5
	move.l	dtg_StartInt(A5),A0
	jsr	(A0)
	rts

***************************************************************************
******************************* EP_SampleInit *****************************
***************************************************************************

SampleInit
	moveq	#EPR_NotEnoughMem,D7
	lea	EPG_SampleInfoStructure(A5),A3
	move.l	ModulePtr(PC),D0
	beq.w	return
	move.l	D0,A2

	moveq	#9,D5
	lea	20(A2),A0
	lea	60(A2),A1
Normal
	jsr	ENPP_AllocSampleStruct(A5)
	move.l	D0,(A3)
	beq.b	return
	move.l	D0,A3

	move.l	(A0)+,D0
	add.l	A2,D0
	moveq	#0,D1
	move.w	(A1)+,D1
	btst	#0,D1
	beq.b	even
	subq.l	#1,D1
even
	add.l	D1,D1
	move.l	D0,EPS_Adr(A3)			; sample address
	move.l	D1,EPS_Length(A3)		; sample length
	move.l	#64,EPS_Volume(A3)
	move.w	#USITY_RAW,EPS_Type(A3)
	move.w	#USIB_Playable!USIB_Saveable!USIB_8BIT,EPS_Flags(A3)
	dbf	D5,Normal

	move.l	InfoBuffer+SynthSamples(PC),D5
	beq.b	NoSynth
	subq.l	#1,D5
Synth
	jsr	ENPP_AllocSampleStruct(A5)
	move.l	D0,(A3)
	beq.b	return
	move.l	D0,A3

	move.w	#USITY_AMSynth,EPS_Type(A3)
	dbf	D5,Synth
NoSynth

	moveq	#0,D7
return
	move.l	D7,D0
	rts

***************************************************************************
***************************** EP_GetPositionNr ****************************
***************************************************************************

GetPosition
	moveq	#0,D0
	move.b	lbB00064C(PC),D0
	rts

***************************************************************************
****************************** EP_NewModuleInfo ***************************
***************************************************************************

NewModuleInfo

SynthSamples	=	4
LoadSize	=	12
CalcSize	=	20
SongName	=	28
Length		=	36
SamplesSize	=	44
SongSize	=	52
Samples		=	60
Pattern		=	68
Duration	=	76

InfoBuffer
	dc.l	MI_SynthSamples,0	;4
	dc.l	MI_LoadSize,0		;12
	dc.l	MI_Calcsize,0		;20
	dc.l	MI_SongName,0		;28
	dc.l	MI_Length,0		;36
	dc.l	MI_SamplesSize,0	;44
	dc.l	MI_Songsize,0		;52
	dc.l	MI_Samples,0		;60
	dc.l	MI_Pattern,0		;68
	dc.l	MI_Duration,0		;76
	dc.l	MI_MaxSamples,10
	dc.l	MI_MaxPattern,128
	dc.l	MI_MaxLength,256
	dc.l	MI_MaxSynthSamples,42
	dc.l	MI_Prefix,Prefix
	dc.l	0

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

SetVolume
SetBalance
	move.w	dtg_SndLBal(A5),D0
	mulu.w	dtg_SndVol(A5),D0
	lsr.w	#6,D0				; durch 64
	move.w	D0,LeftVolume

	move.w	dtg_SndRBal(A5),D0
	mulu.w	dtg_SndVol(A5),D0
	lsr.w	#6,D0				; durch 64
	move.w	D0,RightVolume			; Right Volume

	lea	OldVoice1(PC),A1
	moveq	#3,D0
	lea	$DFF0A8,A5
SetNew
	move.w	(A1)+,D6
	bsr.b	ChangeVolume
	lea	16(A5),A5
	dbf	D0,SetNew
	rts

ChangeVolume
	and.w	#$7F,D6
	cmpa.l	#$DFF0A8,A5			;Left Volume
	bne.b	NoVoice1
	move.w	D6,OldVoice1
	tst.w	Voice1
	bne.b	Voice1On
	moveq	#0,D6
Voice1On
	mulu.w	LeftVolume(PC),D6
	bra.b	SetIt
NoVoice1
	cmpa.l	#$DFF0B8,A5			;Right Volume
	bne.b	NoVoice2
	move.w	D6,OldVoice2
	tst.w	Voice2
	bne.b	Voice2On
	moveq	#0,D6
Voice2On
	mulu.w	RightVolume(PC),D6
	bra.b	SetIt
NoVoice2
	cmpa.l	#$DFF0C8,A5			;Right Volume
	bne.b	NoVoice3
	move.w	D6,OldVoice3
	tst.w	Voice3
	bne.b	Voice3On
	moveq	#0,D6
Voice3On
	mulu.w	RightVolume(PC),D6
	bra.b	SetIt
NoVoice3
	move.w	D6,OldVoice4
	tst.w	Voice4
	bne.b	Voice4On
	moveq	#0,D6
Voice4On
	mulu.w	LeftVolume(PC),D6
SetIt
	lsr.w	#6,D6
	move.w	D6,(A5)
	rts

*------------------------------- Set Vol -------------------------------*

SetVol
	move.l	A0,-(A7)
	lea	StructAdr+UPS_Voice1Vol(PC),A0
	cmp.l	#$DFF0A8,A5
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice2Vol(PC),A0
	cmp.l	#$DFF0B8,A5
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice3Vol(PC),A0
	cmp.l	#$DFF0C8,A5
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice4Vol(PC),A0
.SetVoice
	move.w	D6,(A0)
	move.l	(A7)+,A0
	rts

*------------------------------- Set All -------------------------------*

SetAll
	move.l	A1,-(A7)
	lea	StructAdr+UPS_Voice1Adr(PC),A1
	cmp.l	#$DFF0A0,(A6)
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice2Adr(PC),A1
	cmp.l	#$DFF0B0,(A6)
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice3Adr(PC),A1
	cmp.l	#$DFF0C0,(A6)
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice4Adr(PC),A1
.SetVoice
	move.l	4(A6),(A1)+
	move.l	8(A6),(A1)
	move.l	(A7)+,A1
	rts

***************************************************************************
**************************** EP_Voices ************************************
***************************************************************************

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
******************************* DTP_Check2 ********************************
***************************************************************************

Check2
	movea.l	dtg_ChkData(A5),A0
	moveq	#-1,D0

	move.l	dtg_ChkSize(A5),D1
	lea	(A0,D1.L),A1
	tst.b	12(A0)
	bne.b	Fault
	move.w	12(A0),D1
	lea	80(A0),A0
	addq.w	#1,D1
	mulu.w	#14,D1
	lea	(A0,D1.W),A0
	cmp.l	A0,A1
	blt.b	Fault
	cmp.l	#'patt',(A0)+
	bne.b	Fault
	moveq	#32,D1
	cmp.l	(A0)+,D1
	bne.b	Fault
	cmp.l	#'patt',(A0)
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
	move.l	A0,(A6)+		; module buffer
	move.l	A5,(A6)+		; EagleBase

	lea	InfoBuffer(PC),A4
	move.l	D0,LoadSize(A4)

	moveq	#0,D1
	move.w	12(A0),D1
	move.l	D1,Length(A4)
	move.w	14(A0),D1
	move.l	D1,Pattern(A4)
	move.w	16(A0),D1
	move.l	D1,SynthSamples(A4)
	move.l	A0,SongName(A4)

	moveq	#0,D5
	lea	20(A0),A1
	moveq	#9,D2
	moveq	#0,D4
NextSamp
	move.l	(A1)+,D1
	beq.b	NoSamp
	addq.l	#1,D5
	tst.l	D4
	beq.b	PutSize
	cmp.l	D1,D4
	blt.b	NoSamp
PutSize
	move.l	D1,D4
NoSamp
	dbf	D2,NextSamp

	move.l	D5,Samples(A4)

	move.l	A0,A1
	lea	(A0,D0.L),A2
	tst.l	D4
	bne.b	.Samples
	moveq	#0,D1
	move.w	16(A1),D1			; number of synth samples
	lea	80(A1),A1
.FindSample
	cmp.l	A1,A2
	ble.b	Error
	cmp.w	#'in',(A1)+
	bne.b	.FindSample
	cmp.w	#'st',(A1)+
	bne.b	.FindSample
	dbf	D1,.FindSample
	move.l	A1,D4
	sub.l	A0,D4				; calculated length
	move.l	D4,D0
	bra.b	SkipSamples

.Samples
	moveq	#9,D2				; max. 10 samples
	lea	60(A1),A2
	lea	20(A1),A1
	moveq	#0,D0
.FindSize
	move.l	(A1)+,D3			; sample offset
	moveq	#0,D1
	move.w	(A2)+,D1			; sample length (half)
	btst	#0,D1
	beq.b	.even
	subq.l	#1,D1
.even
	add.l	D1,D1				; * 2
	add.l	D3,D1
	cmp.l	D1,D0
	bge.b	.MaxSize
	move.l	D1,D0				; calculated length
.MaxSize
	dbf	D2,.FindSize
SkipSamples
	move.l	D0,CalcSize(A4)
	move.l	D4,SongSize(A4)
	cmp.l	LoadSize(A4),D0
	ble.b	SizeOK
Error
	moveq	#EPR_ModuleTooShort,D0		; error message
	rts
SizeOK
	sub.l	D4,D0
	move.l	D0,SamplesSize(A4)
	move.w	12(A0),D7
	moveq	#2,D1
	moveq	#0,D0
	moveq	#0,D2
	lea	92(A0),A0
NextSpeed
	move.b	(A0),D0
	beq.b	NoChange
	move.l	D0,D1
NoChange
	add.l	D1,D2
	lea	14(A0),A0
	dbf	D7,NextSpeed
	move.l	D2,D1
	mulu.w	#$376B,D1		; dtg_Timer
        move.l	#(709379-3)/32,D3	; PAL ex_EClockFrequency/number of rows
	divu.w	D3,D1
	move.w	D1,Duration+2(A4)

	lsl.l	#5,D2			; * 32
	move.l	D2,(A6)			; Interrupts

	move.l	ModulePtr(PC),A4
	move.l	A5,-(SP)
	bsr.w	InitPlay
	move.l	(SP)+,A5

	movea.l	dtg_AudioAlloc(A5),A0
	jmp	(A0)

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
	lea	OldVoice1(PC),A0
	clr.l	(A0)+
	clr.l	(A0)
	move.l	ModulePtr(PC),A4
	lea	PatternBuffer,A2
	lea	STRIPE1(PC),A3
	lea	80(A4),A1
	moveq	#3,D2
SetStart
	moveq	#0,D5
	move.b	(A1),D5
	lsl.w	#7,D5
	lea	(A2,D5.W),A1
	move.l	A1,(A3)+
	addq.l	#3,A1
	dbf	D2,SetStart
	move.l	#$00040200,lbW000106
	bra.w	InitSong

***************************************************************************
***************************** DTP_EndSound ********************************
***************************************************************************

EndSound
	lea	$DFF000,A0
	move.w	#15,$96(A0)
	moveq	#0,D0
	move.w	D0,$A8(A0)
	move.w	D0,$B8(A0)
	move.w	D0,$C8(A0)
	move.w	D0,$D8(A0)
	rts

***************************************************************************
***************************** DTP_Interrupt *******************************
***************************************************************************

Interrupt
	movem.l	D1-A6,-(A7)
	lea	StructAdr(PC),A0
	st	UPS_Enabled(A0)
	clr.w	UPS_Voice1Per(A0)
	clr.w	UPS_Voice2Per(A0)
	clr.w	UPS_Voice3Per(A0)
	clr.w	UPS_Voice4Per(A0)
	move.w	#UPSB_Adr!UPSB_Len!UPSB_Per!UPSB_Vol,UPS_Flags(A0)

	bsr.w	Play

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
**************************** PumaTracker player ***************************
***************************************************************************

; Player from game Elf (c) Ocean

lbW000106
	dc.w	4
lbB0001F1
	dc.w	200

InitSong
	LEA	lbC0002E0(PC),A2
	LEA	lbL00055A(PC),A0
	BCLR	#2,$22(A0)
	MOVE.B	#1,$12(A0)
	LEA	lbL000596(PC),A0
	BCLR	#2,$22(A0)
	MOVE.B	#1,$12(A0)
	LEA	lbL0005D2(PC),A0
	BCLR	#2,$22(A0)
	MOVE.B	#1,$12(A0)
	LEA	lbL00060E(PC),A0
	BCLR	#2,$22(A0)
	MOVE.B	#1,$12(A0)
	MOVE.L	A4,lbL000556-WT(A2)
	MOVE.W	12(A4),D0
	ADDQ.W	#1,D0
	MOVE.W	D0,lbW000106-WT(A2)
	ST	lbB00064C-WT(A2)
	MOVE.B	#1,lbB00064A-WT(A2)
	MOVE.B	#$20,lbB00064B-WT(A2)

	rts

InitPlay
	lea	PatternBuffer,A2

	MOVEQ	#9,D0
	LEA	$3C(A4),A0
	LEA	lbL000AC0(PC),A1
	LEA	$14(A4),A6
	LEA	lbL0009F0(PC),A3
lbC000074	MOVE.W	(A0)+,(A1)+
	MOVEA.L	(A6)+,A5
;	ADDA.L	lbL000556(PC),A5

	add.l	A4,A5

	MOVE.L	A5,(A3)+
	DBRA	D0,lbC000074
	MOVEQ	#$29,D0
	LEA	lbL000B28,A5				; was PC
lbC000088	MOVE.L	A5,(A3)+
	LEA	$20(A5),A5
	DBRA	D0,lbC000088
	MOVE.W	14(A4),D0
	LEA	$50(A4),A0
	MOVE.W	12(A4),D1
	ADDQ.W	#1,D1
	MULU.W	#14,D1
	SUBQ.W	#4,D1
	ADDA.W	D1,A0
	LEA	lbL0007F0(PC),A1
	MOVE.L	#'patt',D2
	ADDQ.W	#4,A0
lbC0000B4	CMP.L	(A0)+,D2
	BNE.S	lbC0000B4
	MOVE.L	A0,(A1)+

	tst.w	D0
	beq.b	SkipDepack
DepackPat
	move.l	(A0)+,D4
	move.l	D4,(A2)+
	subq.b	#1,D4
	beq.b	Last
Depack1
	clr.l	(A2)+
	subq.b	#1,D4
	bne.b	Depack1
Last
	cmp.l	(A0),D2
	bne.b	DepackPat
SkipDepack
	DBRA	D0,lbC0000B4
	LEA	lbL0006E8(PC),A1
	MOVE.L	#'inst',D2
	MOVE.L	#'insf',D1
	MOVE.W	$10(A4),D0
	SUBQ.W	#1,D0
	SUBQ.W	#2,A0
lbC0000D6	ADDQ.W	#2,A0
	CMP.L	(A0),D2
	BNE.S	lbC0000D6
	ADDQ.W	#4,A0
	MOVE.L	A0,(A1)+
	SUBQ.W	#2,A0
lbC0000E2	ADDQ.W	#2,A0
	CMP.L	(A0),D1
	BNE.S	lbC0000E2
	ADDQ.W	#4,A0
	MOVE.L	A0,(A1)+
	DBRA	D0,lbC0000D6
	RTS

Play
	LEA	lbC0002E0(PC),A2
	CMPI.B	#$20,lbB00064B-WT(A2)
	BNE.L	lbC0001E0
	ADDQ.B	#1,lbB00064C-WT(A2)
;	CMPI.B	#4,lbB00064C-WT(A2)
;lbW000106	EQU	*-4

	move.w	lbW000106-WT(A2),D0
	cmp.b	lbB00064C-WT(A2),D0

	BNE.S	lbC000110
	SF	lbB00064C-WT(A2)

	lea	lbL00055A(PC),A0	; restart module fixes
	bclr	#2,$22(A0)
	lea	60(A0),A0
	bclr	#2,$22(A0)
	lea	60(A0),A0
	bclr	#2,$22(A0)
	lea	60(A0),A0
	bclr	#2,$22(A0)
	bsr.w	SongEnd

lbC000110	SF	lbB00064B-WT(A2)
	MOVEQ	#0,D0
	MOVE.B	lbB00064C(PC),D0
	ADD.W	D0,D0
	MOVE.W	D0,D1
	LSL.W	#3,D0
	SUB.W	D1,D0
	MOVEA.L	lbL000556(PC),A5
	LEA	$50(A5),A5
	ADDA.W	D0,A5
	LEA	lbL0007F0(PC),A4
	LEA	lbL00055A(PC),A6
	ORI.B	#1,$14(A6)
	MOVEQ	#0,D1
	MOVE.B	(A5)+,D1

	lea	PatternBuffer,A0
	lea	STRIPE1(PC),A3
	move.l	D1,D5
	lsl.w	#7,D5
	lea	(A0,D5.W),A1
	move.l	A1,(A3)+

	ADD.W	D1,D1
	ADD.W	D1,D1
	MOVE.L	0(A4,D1.W),14(A6)
	SUBQ.L	#4,14(A6)
	MOVE.B	(A5)+,$18(A6)
	MOVE.B	(A5)+,$19(A6)
	MOVE.B	#1,$12(A6)
	LEA	lbL000596(PC),A6
	ORI.B	#1,$14(A6)
	MOVEQ	#0,D1
	MOVE.B	(A5)+,D1

	move.l	D1,D5
	lsl.w	#7,D5
	lea	(A0,D5.W),A1
	move.l	A1,(A3)+

	ADD.W	D1,D1
	ADD.W	D1,D1
	MOVE.L	0(A4,D1.W),14(A6)
	SUBQ.L	#4,14(A6)
	MOVE.B	(A5)+,$18(A6)
	MOVE.B	(A5)+,$19(A6)
	MOVE.B	#1,$12(A6)
	LEA	lbL0005D2(PC),A6
	ORI.B	#1,$14(A6)
	MOVEQ	#0,D1
	MOVE.B	(A5)+,D1

	move.l	D1,D5
	lsl.w	#7,D5
	lea	(A0,D5.W),A1
	move.l	A1,(A3)+

	ADD.W	D1,D1
	ADD.W	D1,D1
	MOVE.L	0(A4,D1.W),14(A6)
	SUBQ.L	#4,14(A6)
	MOVE.B	(A5)+,$18(A6)
	MOVE.B	(A5)+,$19(A6)
	MOVE.B	#1,$12(A6)
	LEA	lbL00060E(PC),A6
	ORI.B	#1,$14(A6)
	MOVEQ	#0,D1
	MOVE.B	(A5)+,D1

	move.l	D1,D5
	lsl.w	#7,D5
	lea	(A0,D5.W),A1
	move.l	A1,(A3)

	ADD.W	D1,D1
	ADD.W	D1,D1
	MOVE.L	0(A4,D1.W),14(A6)
	SUBQ.L	#4,14(A6)
	MOVE.B	(A5)+,$18(A6)
	MOVE.B	(A5)+,$19(A6)
	MOVE.B	#1,$12(A6)
	MOVE.B	(A5),D1
	BEQ.S	lbC0001E0
	MOVE.B	D1,lbB0001F1-WT(A2)
lbC0001E0	LEA	lbW00064E(PC),A1
	SUBQ.B	#1,lbB00064A-WT(A2)
	BNE.S	lbC000254
	ADDQ.B	#1,lbB00064B-WT(A2)
;	MOVE.B	#2,lbB00064A-WT(A2)
;lbB0001F1	EQU	*-3

	move.b	lbB0001F1-WT(A2),D1
	move.b	D1,lbB00064A-WT(A2)

	bsr.w	PATINFO

	LEA	lbL00055A(PC),A6
	SUBQ.B	#1,$12(A6)
	BNE.S	lbC00020C
	ADDQ.L	#4,14(A6)
	ANDI.B	#$DF,$14(A6)
	MOVEQ	#1,D1
	JSR	(A2)
lbC00020C	LEA	lbL000596(PC),A6
	SUBQ.B	#1,$12(A6)
	BNE.S	lbC000224
	ADDQ.L	#4,14(A6)
	ANDI.B	#$DF,$14(A6)
	MOVEQ	#2,D1
	JSR	(A2)
lbC000224	LEA	lbL0005D2(PC),A6
	SUBQ.B	#1,$12(A6)
	BNE.S	lbC00023C
	ADDQ.L	#4,14(A6)
	ANDI.B	#$DF,$14(A6)
	MOVEQ	#4,D1
	JSR	(A2)
lbC00023C	LEA	lbL00060E(PC),A6
	SUBQ.B	#1,$12(A6)
	BNE.S	lbC000254
	ADDQ.L	#4,14(A6)
	ANDI.B	#$DF,$14(A6)
	MOVEQ	#8,D1
	JSR	(A2)
lbC000254	MOVE.W	#$8000,D5
	LEA	lbL00055A(PC),A6
	MOVE.B	$22(A6),D7
	BTST	#2,D7
	BEQ.S	lbC000270
	ADDQ.B	#1,D5
	BSR.L	lbC000368
	MOVE.B	D7,$22(A6)
lbC000270	LEA	lbL000596(PC),A6
	MOVE.B	$22(A6),D7
	BTST	#2,D7
	BEQ.S	lbC000288
	ADDQ.B	#2,D5
	BSR.L	lbC000368
	MOVE.B	D7,$22(A6)
lbC000288	LEA	lbL0005D2(PC),A6
	MOVE.B	$22(A6),D7
	BTST	#2,D7
	BEQ.S	lbC0002A0
	ADDQ.B	#4,D5
	BSR.L	lbC000368
	MOVE.B	D7,$22(A6)
lbC0002A0	LEA	lbL00060E(PC),A6
	MOVE.B	$22(A6),D7
	BTST	#2,D7
	BEQ.S	lbC0002B8
	ADDQ.B	#8,D5
	BSR.L	lbC000368
	MOVE.B	D7,$22(A6)
lbC0002B8
;	MOVE.B	$DFF006,D0
;	ADDQ.B	#1,D0
;lbC0002C0	CMP.B	$DFF006,D0
;	BNE.S	lbC0002C0

	bsr.w	DMAWait

	MOVEQ	#15,D0
	AND.B	D5,D0
	NOT.W	D0
	ANDI.W	#15,D0
	MOVE.W	D0,$DFF096
	MOVE.W	D5,$DFF096
	RTS

WT
lbC0002E0	CLR.W	D0
	MOVEA.L	14(A6),A0
	MOVE.B	(A0)+,D0
	BEQ.S	lbC000316
	MOVE.W	D1,$DFF096
	ADD.B	$19(A6),D0
	MOVE.B	D0,$3A(A6)
	MOVE.B	(A0),D0
	ADD.B	$18(A6),D0
	LSL.B	#3,D0
	LEA	lbL0006E0(PC),A5
	ADDA.W	D0,A5
	MOVE.L	(A5)+,$1A(A6)
	MOVE.L	(A5),$1E(A6)
	MOVE.L	#$7000000,$22(A6)
lbC000316	MOVE.B	2(A0),$12(A6)
	MOVEQ	#-$20,D0
	AND.B	(A0)+,D0
	BNE.S	lbC00032E
	MOVE.B	#$40,$15(A6)
	CLR.W	$38(A6)
	RTS

lbC00032E	CMPI.B	#$60,D0
	BNE.S	lbC000346
	MOVEQ	#0,D0
	MOVE.B	(A0),D0
	NEG.W	D0
	MOVE.W	D0,$38(A6)
	MOVE.B	#$40,$15(A6)
	RTS

lbC000346	CMPI.B	#$40,D0
	BNE.S	lbC00035E
	MOVE.B	(A0),D0
	ANDI.W	#$FF,D0
	MOVE.W	D0,$38(A6)
	MOVE.B	#$40,$15(A6)
	RTS

lbC00035E	MOVE.B	(A0),$15(A6)
	CLR.W	$38(A6)
	RTS

lbC000368	CLR.W	D6
	MOVE.B	$24(A6),D6
lbC00036E	MOVEA.L	$1A(A6),A0
	ADDA.W	D6,A0
	MOVE.B	(A0)+,D1
	CMPI.B	#$A0,D1
	BEQ.S	lbC0003D2
	CMPI.B	#$C0,D1
	BEQ.S	lbC000398
	CMPI.B	#$B0,D1
	BEQ.S	lbC000394
	CLR.W	12(A6)
	BCLR	#2,D7
	BRA.L	lbC000438

lbC000394	MOVE.B	(A0),D6
	BRA.S	lbC00036E

lbC000398	CLR.W	D1
	MOVE.B	(A0)+,D1
	LEA	$34(A6),A5
	MOVE.B	(A0),(A5)+
	MOVE.B	(A0)+,(A5)+
	MOVE.B	(A0),(A5)+
	ADD.W	D1,D1
	LEA	lbL000AC0(PC),A0
	MOVE.W	0(A0,D1.W),D2
	MOVE.W	D2,8(A6)
	CMPI.W	#$50,D2
	BMI.S	lbC0003BE
	BSET	#3,D7
lbC0003BE	ADD.W	D1,D1
	LEA	lbL0009F0(PC),A0
	MOVE.L	0(A0,D1.W),4(A6)
	ADDQ.B	#4,D6
	BSET	#0,D7

	bsr.w	SetAll

	BRA.S	lbC00036E

lbC0003D2	BCLR	#0,D7
	BEQ.S	lbC00040C
	MOVE.B	(A0)+,D1
	MOVE.B	(A0)+,D2
	MOVE.B	(A0),$26(A6)
	ADDQ.B	#1,$26(A6)
	MOVE.B	D1,13(A6)
	SF	$27(A6)
	MOVE.B	#1,$2A(A6)
	SUB.B	D1,D2
	BCC.S	lbC0003FC
	NEG.B	D2
	ST	$2A(A6)
lbC0003FC	MOVE.B	D2,$28(A6)
	BRA.S	lbC000438

lbC000402	ADDQ.B	#4,D6
	BSET	#0,D7
	BRA.L	lbC00036E

lbC00040C	SUBQ.B	#1,$26(A6)
	BEQ.S	lbC000402
	MOVE.B	2(A0),D4
	MOVE.B	$27(A6),D1
	ADD.B	$28(A6),D1
	SUB.B	D4,D1
	BMI.S	lbC000432
	CLR.W	D2
	MOVE.B	$2A(A6),D3
lbC000428	ADD.B	D3,D2
	SUB.B	D4,D1
	BPL.S	lbC000428
	ADD.B	D2,13(A6)
lbC000432	ADD.B	D4,D1
	MOVE.B	D1,$27(A6)
lbC000438	MOVE.B	D6,$24(A6)
	MOVE.B	$25(A6),D6
lbC000440	MOVEA.L	$1E(A6),A0
	ADDA.W	D6,A0
	MOVE.B	(A0)+,D1
	CMPI.B	#$A0,D1
	BEQ.S	lbC00048C
	CMPI.B	#$D0,D1
	BEQ.S	lbC000460
	CMPI.B	#$B0,D1
	BNE.L	lbC0004FE
	MOVE.B	(A0),D6
	BRA.S	lbC000440

lbC000460	BCLR	#1,D7
	BNE.S	lbC000476
	SUBQ.B	#1,$29(A6)
	BNE.L	lbC0004FE
	BSET	#1,D7
	ADDQ.B	#4,D6
	BRA.S	lbC000440

lbC000476	CLR.W	D1
	MOVE.B	(A0),D1
	MOVE.B	2(A0),$29(A6)
	ADD.B	$3A(A6),D1
	MOVE.W	0(A1,D1.W),10(A6)
	BRA.S	lbC0004FE

lbC00048C	BCLR	#1,D7
	BEQ.S	lbC0004EA
	CLR.W	D0
	MOVE.B	(A0)+,D1
	MOVE.B	(A0)+,D2
	MOVE.B	(A0),$29(A6)
	MOVE.B	$3A(A6),D0
	MOVE.W	0(A1,D0.W),D0
	EXT.W	D1
	EXT.W	D2
	ADD.W	D0,D1
	ADD.W	D0,D2
	MOVE.W	D1,10(A6)
	MOVE.W	D1,$2C(A6)
	CLR.W	$2E(A6)
	SUB.W	D1,D2
	CLR.W	D1
	MOVE.B	$29(A6),D1
	EXT.L	D2
	ASL.L	#8,D2
	DIVS.W	D1,D2
	BVS.S	lbC0004D2
	EXT.L	D2
	ASL.L	#8,D2
	MOVE.L	D2,$30(A6)
	BRA.S	lbC0004FE

lbC0004D2	ASR.L	#8,D2
	DIVS.W	D1,D2
	SWAP	D2
	CLR.W	D2
	MOVE.L	D2,$30(A6)
	BRA.S	lbC0004FE

lbC0004E0	BSET	#1,D7
	ADDQ.B	#4,D6
	BRA.L	lbC000440

lbC0004EA	SUBQ.B	#1,$29(A6)
	BEQ.S	lbC0004E0
	MOVE.L	$30(A6),D1
	ADD.L	D1,$2C(A6)
	MOVE.W	$2C(A6),10(A6)
lbC0004FE	MOVE.B	D6,$25(A6)
	MOVE.W	$38(A6),D1
	ADD.W	D1,10(A6)
	LEA	(A6),A0
	MOVEA.L	(A0)+,A5
	MOVEA.L	(A0)+,A3
	MOVE.B	$34(A6),D0
	BEQ.S	lbC000534
	MOVE.B	$35(A6),D1
	BLE.S	lbC000522
	CMP.B	$36(A6),D1
	BMI.S	lbC000528
lbC000522	NEG.B	D0
	MOVE.B	D0,$34(A6)
lbC000528	ADD.B	D0,D1
	MOVE.B	D1,$35(A6)
	EXT.W	D1
	LSL.W	#5,D1
	ADDA.W	D1,A3
lbC000534	MOVE.L	A3,(A5)+
	MOVE.L	(A0),(A5)+
	BCLR	#3,D7
	BEQ.S	lbC000542
	MOVE.W	#1,(A0)
lbC000542	ADDQ.L	#4,A0
	MOVE.W	(A0),D6
	ADD.B	$15(A6),D6
	SUBI.B	#$40,D6
	BPL.S	lbC000552
	CLR.W	D6
lbC000552
;	MOVE.W	D6,(A5)

	bsr.w	ChangeVolume
	bsr.w	SetVol

	RTS

lbL000556	dc.l	0
lbL00055A	dc.l	$DFF0A0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbL000596	dc.l	$DFF0B0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbL0005D2	dc.l	$DFF0C0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbL00060E	dc.l	$DFF0D0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbB00064A	dc.b	3
lbB00064B	dc.b	0
lbB00064C	dc.b	0
	dc.b	0
lbW00064E	dc.w	0
	dc.w	$1AC0
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
lbL0006E0	dc.l	0
	dc.l	0
lbL0006E8
	ds.b	66*4
lbL0007F0
	ds.b	128*4+4				; patterns ptr
lbL0009F0	
	ds.b	52*4				; samples ptr

lbL000AC0	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	$100010
	dc.l	$100010
	dc.l	$100010
	dc.l	$100010
	dc.l	$100010
	dc.l	$100010
	dc.l	$100010
	dc.l	$100010
	dc.l	$100010
	dc.l	$100010
	dc.l	$100010
	dc.l	$100010
	dc.l	$100010
	dc.l	$100010
	dc.l	$100010
	dc.l	$100010
	dc.l	$100010
	dc.l	$100010
	dc.l	$100010
	dc.l	$100010
	dc.l	$100010

	Section	SynthSamples,Data_C

lbL000B28	dc.l	$C0C0D0D8
	dc.l	$E0E8F0F8
	dc.l	$F8F0E8
	dc.l	$E0D8D0C8
	dc.l	$3F372F27
	dc.l	$1F170F07
	dc.l	$FF070F17
	dc.l	$1F272F37
	dc.l	$C0C0D0D8
	dc.l	$E0E8F0F8
	dc.l	$F8F0E8
	dc.l	$E0D8D0C8
	dc.l	$C0372F27
	dc.l	$1F170F07
	dc.l	$FF070F17
	dc.l	$1F272F37
	dc.l	$C0C0D0D8
	dc.l	$E0E8F0F8
	dc.l	$F8F0E8
	dc.l	$E0D8D0C8
	dc.l	$C0B82F27
	dc.l	$1F170F07
	dc.l	$FF070F17
	dc.l	$1F272F37
	dc.l	$C0C0D0D8
	dc.l	$E0E8F0F8
	dc.l	$F8F0E8
	dc.l	$E0D8D0C8
	dc.l	$C0B8B027
	dc.l	$1F170F07
	dc.l	$FF070F17
	dc.l	$1F272F37
	dc.l	$C0C0D0D8
	dc.l	$E0E8F0F8
	dc.l	$F8F0E8
	dc.l	$E0D8D0C8
	dc.l	$C0B8B0A8
	dc.l	$1F170F07
	dc.l	$FF070F17
	dc.l	$1F272F37
	dc.l	$C0C0D0D8
	dc.l	$E0E8F0F8
	dc.l	$F8F0E8
	dc.l	$E0D8D0C8
	dc.l	$C0B8B0A8
	dc.l	$A0170F07
	dc.l	$FF070F17
	dc.l	$1F272F37
	dc.l	$C0C0D0D8
	dc.l	$E0E8F0F8
	dc.l	$F8F0E8
	dc.l	$E0D8D0C8
	dc.l	$C0B8B0A8
	dc.l	$A0980F07
	dc.l	$FF070F17
	dc.l	$1F272F37
	dc.l	$C0C0D0D8
	dc.l	$E0E8F0F8
	dc.l	$F8F0E8
	dc.l	$E0D8D0C8
	dc.l	$C0B8B0A8
	dc.l	$A0989007
	dc.l	$FF070F17
	dc.l	$1F272F37
	dc.l	$C0C0D0D8
	dc.l	$E0E8F0F8
	dc.l	$F8F0E8
	dc.l	$E0D8D0C8
	dc.l	$C0B8B0A8
	dc.l	$A0989088
	dc.l	$FF070F17
	dc.l	$1F272F37
	dc.l	$C0C0D0D8
	dc.l	$E0E8F0F8
	dc.l	$F8F0E8
	dc.l	$E0D8D0C8
	dc.l	$C0B8B0A8
	dc.l	$A0989088
	dc.l	$80070F17
	dc.l	$1F272F37
	dc.l	$C0C0D0D8
	dc.l	$E0E8F0F8
	dc.l	$F8F0E8
	dc.l	$E0D8D0C8
	dc.l	$C0B8B0A8
	dc.l	$A0989088
	dc.l	$80880F17
	dc.l	$1F272F37
	dc.l	$C0C0D0D8
	dc.l	$E0E8F0F8
	dc.l	$F8F0E8
	dc.l	$E0D8D0C8
	dc.l	$C0B8B0A8
	dc.l	$A0989088
	dc.l	$80889017
	dc.l	$1F272F37
	dc.l	$C0C0D0D8
	dc.l	$E0E8F0F8
	dc.l	$F8F0E8
	dc.l	$E0D8D0C8
	dc.l	$C0B8B0A8
	dc.l	$A0989088
	dc.l	$80889098
	dc.l	$1F272F37
	dc.l	$C0C0D0D8
	dc.l	$E0E8F0F8
	dc.l	$F8F0E8
	dc.l	$E0D8D0C8
	dc.l	$C0B8B0A8
	dc.l	$A0989088
	dc.l	$80889098
	dc.l	$A0272F37
	dc.l	$C0C0D0D8
	dc.l	$E0E8F0F8
	dc.l	$F8F0E8
	dc.l	$E0D8D0C8
	dc.l	$C0B8B0A8
	dc.l	$A0989088
	dc.l	$80889098
	dc.l	$A0A82F37
	dc.l	$C0C0D0D8
	dc.l	$E0E8F0F8
	dc.l	$F8F0E8
	dc.l	$E0D8D0C8
	dc.l	$C0B8B0A8
	dc.l	$A0989088
	dc.l	$80889098
	dc.l	$A0A8B037
	dc.l	$81818181
	dc.l	$81818181
	dc.l	$81818181
	dc.l	$81818181
	dc.l	$7F7F7F7F
	dc.l	$7F7F7F7F
	dc.l	$7F7F7F7F
	dc.l	$7F7F7F7F
	dc.l	$81818181
	dc.l	$81818181
	dc.l	$81818181
	dc.l	$81818181
	dc.l	$817F7F7F
	dc.l	$7F7F7F7F
	dc.l	$7F7F7F7F
	dc.l	$7F7F7F7F
	dc.l	$81818181
	dc.l	$81818181
	dc.l	$81818181
	dc.l	$81818181
	dc.l	$81817F7F
	dc.l	$7F7F7F7F
	dc.l	$7F7F7F7F
	dc.l	$7F7F7F7F
	dc.l	$81818181
	dc.l	$81818181
	dc.l	$81818181
	dc.l	$81818181
	dc.l	$8181817F
	dc.l	$7F7F7F7F
	dc.l	$7F7F7F7F
	dc.l	$7F7F7F7F
	dc.l	$81818181
	dc.l	$81818181
	dc.l	$81818181
	dc.l	$81818181
	dc.l	$81818181
	dc.l	$7F7F7F7F
	dc.l	$7F7F7F7F
	dc.l	$7F7F7F7F
	dc.l	$81818181
	dc.l	$81818181
	dc.l	$81818181
	dc.l	$81818181
	dc.l	$81818181
	dc.l	$817F7F7F
	dc.l	$7F7F7F7F
	dc.l	$7F7F7F7F
	dc.l	$81818181
	dc.l	$81818181
	dc.l	$81818181
	dc.l	$81818181
	dc.l	$81818181
	dc.l	$81817F7F
	dc.l	$7F7F7F7F
	dc.l	$7F7F7F7F
	dc.l	$81818181
	dc.l	$81818181
	dc.l	$81818181
	dc.l	$81818181
	dc.l	$81818181
	dc.l	$8181817F
	dc.l	$7F7F7F7F
	dc.l	$7F7F7F7F
	dc.l	$81818181
	dc.l	$81818181
	dc.l	$81818181
	dc.l	$81818181
	dc.l	$81818181
	dc.l	$81818181
	dc.l	$7F7F7F7F
	dc.l	$7F7F7F7F
	dc.l	$81818181
	dc.l	$81818181
	dc.l	$81818181
	dc.l	$81818181
	dc.l	$81818181
	dc.l	$81818181
	dc.l	$817F7F7F
	dc.l	$7F7F7F7F
	dc.l	$81818181
	dc.l	$81818181
	dc.l	$81818181
	dc.l	$81818181
	dc.l	$81818181
	dc.l	$81818181
	dc.l	$81817F7F
	dc.l	$7F7F7F7F
	dc.l	$81818181
	dc.l	$81818181
	dc.l	$81818181
	dc.l	$81818181
	dc.l	$81818181
	dc.l	$81818181
	dc.l	$8181817F
	dc.l	$7F7F7F7F
	dc.l	$81818181
	dc.l	$81818181
	dc.l	$81818181
	dc.l	$81818181
	dc.l	$81818181
	dc.l	$81818181
	dc.l	$81818181
	dc.l	$7F7F7F7F
	dc.l	$81818181
	dc.l	$81818181
	dc.l	$81818181
	dc.l	$81818181
	dc.l	$81818181
	dc.l	$81818181
	dc.l	$81818181
	dc.l	$817F7F7F
	dc.l	$80808080
	dc.l	$80808080
	dc.l	$80808080
	dc.l	$80808080
	dc.l	$80808080
	dc.l	$80808080
	dc.l	$80808080
	dc.l	$80807F7F
	dc.l	$80808080
	dc.l	$80808080
	dc.l	$80808080
	dc.l	$80808080
	dc.l	$80808080
	dc.l	$80808080
	dc.l	$80808080
	dc.l	$8080807F
	dc.l	$80808080
	dc.l	$80808080
	dc.l	$7F7F7F7F
	dc.l	$7F7F7F7F
	dc.l	$80808080
	dc.l	$8080807F
	dc.l	$7F7F7F7F
	dc.l	$7F7F7F7F
	dc.l	$80808080
	dc.l	$80807F7F
	dc.l	$7F7F7F7F
	dc.l	$7F7F7F7F
	dc.l	$80808080
	dc.l	$807F7F7F
	dc.l	$7F7F7F7F
	dc.l	$7F7F7F7F
	dc.l	$80808080
	dc.l	$7F7F7F7F
	dc.l	$7F7F7F7F
	dc.l	$7F7F7F7F
	dc.l	$8080807F
	dc.l	$7F7F7F7F
	dc.l	$7F7F7F7F
	dc.l	$7F7F7F7F
	dc.l	$80807F7F
	dc.l	$7F7F7F7F
	dc.l	$7F7F7F7F
	dc.l	$7F7F7F7F
	dc.l	$80807F7F
	dc.l	$7F7F7F7F
	dc.l	$7F7F7F7F
	dc.l	$7F7F7F7F
	dc.l	$80809098
	dc.l	$A0A8B0B8
	dc.l	$C0C8D0D8
	dc.l	$E0E8F0F8
	dc.l	$81018
	dc.l	$20283038
	dc.l	$40485058
	dc.l	$6068707F
	dc.l	$8080A0B0
	dc.l	$C0D0E0F0
	dc.l	$102030
	dc.l	$40506070
	dc.l	$4545797D
	dc.l	$7A777066
	dc.l	$6158534D
	dc.l	$2C201812
	dc.l	$4DBD3CD
	dc.l	$C6BCB5AE
	dc.l	$A8A39D99
	dc.l	$938E8B8A
	dc.l	$4545797D
	dc.l	$7A777066
	dc.l	$5B4B4337
	dc.l	$2C201812
	dc.l	$4F8E8DB
	dc.l	$CFC6BEB0
	dc.l	$A8A49E9A
	dc.l	$95948D83
	dc.l	$4060
	dc.l	$7F604020
	dc.l	$E0C0A0
	dc.l	$80A0C0E0
	dc.l	$4060
	dc.l	$7F604020
	dc.l	$E0C0A0
	dc.l	$80A0C0E0
	dc.l	$80809098
	dc.l	$A0A8B0B8
	dc.l	$C0C8D0D8
	dc.l	$E0E8F0F8
	dc.l	$81018
	dc.l	$20283038
	dc.l	$40485058
	dc.l	$6068707F
	dc.l	$8080A0B0
	dc.l	$C0D0E0F0
	dc.l	$102030
	dc.l	$40506070

	Section	Buffer,BSS

PatternBuffer
	ds.b	128*128

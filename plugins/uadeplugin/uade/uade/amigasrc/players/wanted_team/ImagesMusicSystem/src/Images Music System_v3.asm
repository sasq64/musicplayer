	******************************************************
	**** Images Music System replayer for EaglePlayer ****
	****        all adaptions by Wanted Team,	  ****
	****      DeliTracker compatible (?) version	  ****
	******************************************************

	incdir	"dh2:include/"
	include 'misc/eagleplayer2.01.i'

	SECTION	Player,CODE

	PLAYERHEADER Tags

	dc.b	'$VER: Images Music System player module V1.2 (18 Nov 2001)',0
	even
Tags
	dc.l	DTP_PlayerVersion,3
	dc.l	EP_PlayerVersion,9
	dc.l	DTP_RequestDTVersion,DELIVERSION
	dc.l	DTP_PlayerName,PlayerName
	dc.l	DTP_Creator,Creator
	dc.l	DTP_Check2,Check2
	dc.l	DTP_InitPlayer,InitPlayer
	dc.l	DTP_EndPlayer,EndPlayer
	dc.l	DTP_InitSound,InitSound
	dc.l	DTP_EndSound,EndSound
	dc.l	DTP_Interrupt,Interrupt
	dc.l	EP_Get_ModuleInfo,Get_ModuleInfo
	dc.l	DTP_SubSongRange,SubSongRange
	dc.l	DTP_Volume,SetVolume
	dc.l	DTP_Balance,SetBalance
	dc.l	EP_Voices,SetVoices
	dc.l	EP_StructInit,StructInit
	dc.l	EP_GetPositionNr,GetPosition
	dc.l	EP_SampleInit,SampleInit
	dc.l	DTP_NextPatt,NextPattern
	dc.l	DTP_PrevPatt,BackPattern
	dc.l	EP_PatternInit,PatternInit
	dc.l	EP_Flags,EPB_Save!EPB_Volume!EPB_Balance!EPB_ModuleInfo!EPB_Voices!EPB_SampleInfo!EPB_Songend!EPB_Analyzer!EPB_Packable!EPB_Restart!EPB_PrevSong!EPB_NextSong!EPB_PrevPatt!EPB_NextPatt
	dc.l	DTP_DeliBase,DeliBase
	dc.l	EP_EagleBase,Eagle2Base
	dc.l	0

PlayerName
	dc.b	'Images Music System',0
Creator
	dc.b	'(c) 1990 by Images Software,',10
	dc.b	'adapted by Wanted Team',0
Prefix
	dc.b	'IMS.',0
	even
DeliBase
	dc.l	0
Eagle2Base
	dc.l	0
ModulePtr
	dc.l	0
EagleBase
	dc.l	0
TablePtr
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
	moveq	#12,D0
	move.l	D0,PI_Modulo(A0)	; Number of bytes to next row
	move.w	#64,PI_Pattlength(A0)	; Length of each stripe in rows


	move.w	InfoBuffer+Patterns+2(PC),PI_NumPatts(A0)	; Overall Number of Patterns
	clr.w	PI_Pattern(A0)		; Current Pattern (from 0)
	clr.w	PI_Pattpos(A0)		; Current Position in Pattern (from 0)
	clr.w	PI_Songpos(A0)		; Current Position in Song (from 0)
	move.w	InfoBuffer+Length+2(PC),PI_MaxSongPos(A0)	; Songlength

	move.w	#6,PI_Speed(A0)		; Default Speed Value
	moveq	#125,D0
	move.w	D0,PI_BPM(A0)		; Beats Per Minute

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

	move.b	1(A0),D0
	lsr.w	#4,D0
	move.b	(A0),D1
	and.b	#$C0,D1
	lsr.b	#2,D1
	or.b	D0,D1
	move.b	(A0),D0
	cmp.b	#$3F,D0
	bne.b	NoClear
	clr.b	D0
	bra.b	SkipIt
NoClear
	and.b	#$3F,D0
	add.w	D0,D0
	lea	lbL0007CC(PC),A1
	move.w	0(A1,D0.W),D0
SkipIt
	move.b	1(A0),D2
	and.w	#15,D2
	move.b	2(A0),D3
	rts

* Sets some current values for the PatternInfo structure.
* Call this every time something changes (or at least every interrupt).
* You can move these elsewhere if necessary, it is only important that
* you make sure the structure fields are accurate and updated regularly.
PATINFO:
	movem.l	D0/D1/D2/A0/A1,-(SP)

	lea	PATTERNINFO(PC),A0
	moveq	#0,D0
	move.w	lbL000734+$14(PC),D0
	move.w	D0,PI_Songpos(A0)	; Position in Song

	move.l	ModulePtr(PC),A1
	lea	952(A1),A1
	moveq	#0,D1
	move.b	(A1,D0.W),D1
	move.w	D1,PI_Pattern(A0)	; Current Pattern
	move.w	lbL000734+$1A(PC),PI_Pattpos(A0)	; Current Position in Pattern

	lea	132(A1),A1
	move.w	D1,D2
	add.w	D2,D2
	add.w	D2,D1
	lsl.l	#8,D1
	add.l	D1,A1			; Current Pattern
	move.l	A1,PI_Stripes(A0)	; STRIPE1
	addq.l	#3,A1			; Distance to next stripe
	move.l	A1,PI_Stripes+4(A0)	; STRIPE2
	addq.l	#3,A1
	move.l	A1,PI_Stripes+8(A0)	; STRIPE3
	addq.l	#3,A1
	move.l	A1,PI_Stripes+12(A0)	; STRIPE4
	move.w	lbL000734+$1C(PC),PI_Speed(A0)		; Speed Value
	movem.l	(SP)+,D0/D1/D2/A0/A1
	rts

***************************************************************************
******************************* DTP_NextPatt ******************************
***************************************************************************

NextPattern
	lea	lbL000734(PC),A6
	move.w	$14(A6),D0
	addq.w	#1,D0
	cmp.w	InfoBuffer+Length+2(PC),D0
	beq.b	MaxPos
	bsr.b	SetThis
MaxPos
	rts

SetThis
	move.w	D0,$14(A6)
	move.l	4(A6),A0
	moveq	#0,D1
	move.b	0(A0,D0.W),D1
	move.w	D1,D2
	add.w	D2,D2
	add.w	D2,D1
	lsl.w	#8,D1
	add.l	8(A6),D1
	move.l	D1,12(A6)
	clr.w	$1A(A6)
	rts

***************************************************************************
******************************* DTP_BackPatt ******************************
***************************************************************************

BackPattern
	lea	lbL000734(PC),A6
	move.w	$14(A6),D0
	beq.b	MinPos
	subq.w	#1,D0
	bsr.b	SetThis
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

	move.l	A2,A1
	lea	20(A2),A2
	add.l	1080(A1),A1
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
	move.w	#20,EPS_MaxNameLen(A3)
	move.w	#USIB_Playable!USIB_Saveable!USIB_8BIT,EPS_Flags(A3)
	lea	30(A2),A2
	add.l	D0,A1
	dbf	D5,hop

	moveq	#0,D7
return
	move.l	D7,D0
	rts

***************************************************************************
***************************** EP_Get_ModuleInfo ***************************
***************************************************************************

Get_ModuleInfo
	lea	InfoBuffer(PC),A0
	rts

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
	dc.l	MI_MaxPattern,64
	dc.l	MI_Prefix,Prefix
	dc.l	0

***************************************************************************
******************************* DTP_Check2 ********************************
***************************************************************************

Check2
	movea.l	dtg_ChkData(A5),A0
	moveq	#-1,D0

	cmp.l	#1852,dtg_ChkSize(A5)
	ble.b	Fault
	tst.w	1080(A0)
	bne.b	Fault
	move.l	1080(A0),D1
	sub.l	#1084,D1
	bmi.b	Fault
	divu.w	#768,D1
	move.l	D1,D2
	swap	D1
	tst.w	D1
	bne.b	Fault
	lea	950(A0),A1
	move.b	(A1),D1
	bmi.b	Fault
	addq.l	#2,A1
	moveq	#0,D3
NextByte
	move.b	(A1)+,D4
	bmi.b	Fault
	cmp.b	D4,D3
	bge.b	MaxByte
	move.b	D4,D3
MaxByte
	dbf	D1,NextByte
	subq.l	#1,D2
	cmp.l	D2,D3
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

	lea	42(A0),A1
	moveq	#30,D0
	moveq	#0,D1
	moveq	#0,D2
	moveq	#0,D3
NextInfo
	move.w	(A1),D1
	beq.b	Empty
	addq.l	#1,D2
	add.l	D1,D3
Empty
	lea	30(A1),A1
	dbf	D0,NextInfo
	add.l	D3,D3
	move.l	D3,SamplesSize(A4)
	move.l	D2,Samples(A4)
	move.l	1080(A0),D1
	move.l	D1,SongSize(A4)
	add.l	D1,D3
	move.l	D3,CalcSize(A4)
	cmp.l	LoadSize(A4),D3
	ble.b	SizeOK
	moveq	#EPR_ModuleTooShort,D0
	rts
SizeOK
	cmp.l	#30652,D3			; am11 unused voice fix
	bne.b	NoFix
	cmp.l	#$000C7C15,1092(A0)
	bne.b	NoFix
	move.l	#$003F0000,1092(A0)
NoFix
	sub.l	#1084,D1
	divu.w	#768,D1
	move.l	D1,Patterns(A4)
	move.b	950(A0),D2
	move.l	D2,Length(A4)
	move.l	A0,SongName(A4)

	move.l	A5,(A6)				; EagleBase

	subq.l	#1,D2
	moveq	#0,D0
	lea	952(A0),A1
	lea	1084(A0),A2
	lea	SongTable+1(PC),A6
	moveq	#0,D4
NextPos
	moveq	#0,D1
	move.b	(A1)+,D1
	mulu.w	#768,D1
	lea	(A2,D1.L),A0
	lea	768(A0),A3
	addq.l	#1,A0
NextPatPos
	move.b	(A0),D1
	and.b	#$0F,D1
	cmp.b	#$0B,D1
	beq.b	SubFound
	addq.l	#3,A0
	cmp.l	A0,A3
	bgt.b	NextPatPos
	addq.l	#1,D4
back
	dbf	D2,NextPos

	tst.l	D0
	bne.b	LoopOK
	moveq	#1,D0
LoopOK
	lea	TablePtr(PC),A1
	lea	SongTable(PC),A2
	cmp.l	#41630,D3			; Beast Busters sub fix
	bne.b	NoBeast
	moveq	#11,D0
	lea	BeastTable(PC),A2
NoBeast
	move.l	A2,(A1)
	move.l	D0,SubSongs(A4)

	move.l	Eagle2Base(PC),D0
	bne.b	Eagle2
	move.l	DeliBase(PC),D0
	bne.b	NoName
Eagle2
	bsr.b	FindName
NoName
	movea.l	dtg_AudioAlloc(A5),A0
	jmp	(A0)

SubFound
	addq.l	#1,D4
	move.b	D4,(A6)+
	addq.l	#1,D0
	bra.b	back

FindName
	move.l	ModulePtr(PC),A0
	lea	20(A0),A1			; A1 - begin sampleinfo
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
***************************** DTP_EndPlayer *******************************
***************************************************************************

EndPlayer
	movea.l	dtg_AudioFree(A5),A0
	jmp	(A0)

***************************************************************************
********************************* EP_GetPosNr *****************************
***************************************************************************

GetPosition
	moveq	#0,D0
	move.w	lbL000734+20(PC),D0
	rts

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

	lea	StructAdr(PC),A3
	lea	OldVoice1(PC),A2
	moveq	#3,D1
	lea	$DFF0A0,A1
SetNew
	move.w	(A2)+,D0
	bsr.b	ChangeVolume
	addq.l	#8,A1
	addq.l	#8,A1
	dbf	D1,SetNew
	rts

ChangeVolume
	and.w	#$7F,D0
	cmpa.l	#$DFF0A0,A1			;Left Volume
	bne.b	NoVoice1
SetVoice1
	move.w	D0,OldVoice1
	tst.w	Voice1
	bne.b	Voice1On
	moveq	#0,D0
Voice1On
	mulu.w	LeftVolume(PC),D0
	lsr.w	#6,D0
	move.w	D0,8(A1)
	move.w	D0,UPS_Voice1Vol(A3)
	bra.b	SetIt
NoVoice1
	cmpa.l	#$DFF0B0,A1			;Right Volume
	bne.b	NoVoice2
SetVoice2
	move.w	D0,OldVoice2
	tst.w	Voice2
	bne.b	Voice2On
	moveq	#0,D0
Voice2On
	mulu.w	RightVolume(PC),D0
	lsr.w	#6,D0
	move.w	D0,8(A1)
	move.w	D0,UPS_Voice2Vol(A3)
	bra.b	SetIt
NoVoice2
	cmpa.l	#$DFF0C0,A1			;Right Volume
	bne.b	NoVoice3
SetVoice3
	move.w	D0,OldVoice3
	tst.w	Voice3
	bne.b	Voice3On
	moveq	#0,D0
Voice3On
	mulu.w	RightVolume(PC),D0
	lsr.w	#6,D0
	move.w	D0,8(A1)
	move.w	D0,UPS_Voice3Vol(A3)
	bra.b	SetIt
NoVoice3
	cmpa.l	#$DFF0D0,A1			;Left Volume
	bne.b	SetIt
SetVoice4
	move.w	D0,OldVoice4
	tst.w	Voice4
	bne.b	Voice4On
	moveq	#0,D0
Voice4On
	mulu.w	LeftVolume(PC),D0
	lsr.w	#6,D0
	move.w	D0,8(A1)
	move.w	D0,UPS_Voice4Vol(A3)
SetIt
	rts

SetAll
	move.l	A0,-(SP)
	lea	StructAdr+UPS_Voice1Adr(PC),A0
	cmp.l	#$DFF0A0,A1
	beq.b	.SetVoice
	lea	StructAdr+UPS_Voice2Adr(PC),A0
	cmp.l	#$DFF0B0,A1
	beq.b	.SetVoice
	lea	StructAdr+UPS_Voice3Adr(PC),A0
	cmp.l	#$DFF0C0,A1
	beq.b	.SetVoice
	lea	StructAdr+UPS_Voice4Adr(PC),A0
.SetVoice
	move.l	(A2),(A0)
	move.w	4(A2),UPS_Voice1Len(A0)
	move.w	D0,UPS_Voice1Per(A0)
	move.l	(SP)+,A0
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
	move.l	ModulePtr(PC),A0
	move.w	dtg_SndNum(A5),D0
	bra.w	Init

***************************************************************************
***************************** DTP_EndSound ********************************
***************************************************************************

EndSound
	bra.w	End

***************************************************************************
***************************** DTP_Interrupt *******************************
***************************************************************************

Interrupt
	movem.l	D1-A6,-(A7)

	lea	StructAdr(PC),A3
	st	UPS_Enabled(A3)
	clr.w	UPS_Voice1Per(A3)
	clr.w	UPS_Voice2Per(A3)
	clr.w	UPS_Voice3Per(A3)
	clr.w	UPS_Voice4Per(A3)
	move.w	#UPSB_Adr!UPSB_Len!UPSB_Per!UPSB_Vol,UPS_Flags(A3)

	bsr.w	Play

	clr.w	UPS_Enabled(A3)

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
	movem.l	A1/A5,-(A7)
	move.l	EagleBase(PC),A5
	move.l	dtg_WaitAudioDMA(A5),A1
	jsr	(A1)
	movem.l	(A7)+,A1/A5
	rts

***************************************************************************
************************* Images Music System player **********************
***************************************************************************

; Player from game "Hunt For Red October" (c) 1990 by Grandslam

;	BRA.L	lbC00007E

;	BRA.L	lbC000094

;	BRA.L	lbC0000C0

;	BRA.L	lbC0001DA

;	BRA.L	lbC0001B8

;lbC00007E	BSR.S	lbC0000C0
;	LEA	lbC0000BA(PC),A0
;	MOVE.L	$6C,2(A0)
;	LEA	lbC0000A4(PC),A0
;	MOVE.L	A0,$6C
;	RTS

;lbC000094	LEA	lbC0000BA(PC),A0
;	MOVE.L	2(A0),$6C
;	BSR.L	lbC0001B8
;	RTS

;lbC0000A4	MOVE.L	D0,-(SP)
;	MOVE.W	$DFF01E,D0
;	ANDI.W	#$20,D0
;	BEQ.L	lbC0000B8
;	BSR.L	lbC0001DA
;lbC0000B8	MOVE.L	(SP)+,D0
;lbC0000BA	JMP	$10000

Init
lbC0000C0	MOVEM.L	D0-D7/A0-A6,-(SP)

	move.l	D0,-(SP)

	LEA	lbL000734(PC),A6
	MOVE.L	A0,0(A6)
	MOVEA.L	A0,A1
	ADDA.L	$438(A0),A1
	LEA	$2A(A0),A2
	LEA	lbL0008AC(PC),A3
;	MOVE.W	#$1F,D7				; bug

	moveq	#30,D7

lbC0000DE
;	MOVEM.L	(lbW000198,PC),D0-D6

	moveq	#0,D0

	MOVE.W	0(A2),D0
	MOVE.W	2(A2),D1

	moveq	#0,D2

	MOVE.W	4(A2),D2
	MOVE.W	6(A2),D3
	MOVEA.L	A1,A4
	ADD.W	D2,D2
	ADDA.L	D2,A4
	MOVE.L	A1,(A3)+
	MOVE.W	D0,(A3)+
	MOVE.L	A4,(A3)+
	MOVE.W	D3,(A3)+
	MOVE.W	D1,(A3)+
	MOVE.W	#0,(A3)+
	ADD.W	D0,D0
	ADDA.L	D0,A1
	LEA	$1E(A2),A2
	DBRA	D7,lbC0000DE
	LEA	$3B8(A0),A1
	MOVE.L	A1,4(A6)
	LEA	$43C(A0),A1
	MOVE.L	A1,8(A6)
	MOVE.W	#0,$14(A6)
	MOVEQ	#0,D0
	MOVE.B	$3B6(A0),D0
	MOVE.W	D0,$16(A6)
	MOVEQ	#0,D0
	MOVE.B	$3B7(A0),D0
	MOVE.W	D0,$18(A6)
	MOVE.W	#0,$1A(A6)
	MOVE.W	#6,$1C(A6)
	MOVE.W	#0,$1E(A6)

	move.l	(SP)+,D0
	move.l	TablePtr(PC),A1
	move.b	0(A1,D0.W),D0
	and.l	#$FF,D0
	move.w	D0,$14(A6)

	MOVEA.L	4(A6),A1

	move.b	0(A1,D0.W),D0

;	MOVEQ	#0,D0
;	MOVE.B	(A1),D0
	MOVE.W	D0,D1
	ADD.W	D1,D1
	ADD.W	D1,D0
	LSL.W	#8,D0
	ADD.L	8(A6),D0
	MOVE.L	D0,12(A6)
	CLR.W	$24(A6)
	MOVE.W	#$FFFF,$26(A6)
	MOVE.W	#15,$DFF096
	CLR.W	$DFF0A8
	CLR.W	$DFF0B8
	CLR.W	$DFF0C8
	CLR.W	$DFF0D8
	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTS

;lbW000198	dc.w	0
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
;	dc.w	0
;	dc.w	0

End
lbC0001B8	MOVE.W	#15,$DFF096
	CLR.W	$DFF0A8
	CLR.W	$DFF0B8
	CLR.W	$DFF0C8
	CLR.W	$DFF0D8
	RTS

Play
lbC0001DA	MOVEM.L	D0-D7/A0-A6,-(SP)
	LEA	lbL000734(PC),A6
	LEA	lbL0007CC(PC),A4
	TST.W	$1E(A6)
	BNE.L	lbC000298
	LEA	lbL00082C(PC),A0
	MOVE.L	A0,$10(A6)
	MOVEA.L	12(A6),A5
;	LEA	lbL0008AC(PC),A3
	CLR.W	$22(A6)
	LEA	lbL00075C(PC),A0
	BSR.L	lbC0004B4
	ADDQ.L	#3,A5
	LEA	lbL000778(PC),A0
	BSR.L	lbC0004B4
	ADDQ.L	#3,A5
	LEA	lbL000794(PC),A0
	BSR.L	lbC0004B4
	ADDQ.L	#3,A5
	LEA	lbL0007B0(PC),A0
	BSR.L	lbC0004B4
	BSR.L	lbC000638
	ADDI.L	#12,12(A6)
	MOVE.W	$1C(A6),$1E(A6)
	TST.W	$24(A6)
	BEQ.S	lbC000256
	CLR.W	$24(A6)
	TST.W	$26(A6)
	BMI.S	lbC000264
	MOVE.W	$26(A6),D0
	MOVE.W	#$FFFF,$26(A6)

	bsr.w	SongEnd				 ; loop song

	BRA.S	lbC000276

lbC000256	ADDI.W	#1,$1A(A6)
	CMPI.W	#$40,$1A(A6)
	BNE.S	lbC000298
lbC000264	MOVEQ	#0,D0
	MOVE.W	$14(A6),D0
	ADDQ.W	#1,D0
	CMP.W	$16(A6),D0
	BNE.S	lbC000276
	MOVE.W	$18(A6),D0

	bsr.w	SongEnd				; repeat song

lbC000276	MOVE.W	D0,$14(A6)
	MOVEA.L	4(A6),A0
	MOVEQ	#0,D1
	MOVE.B	0(A0,D0.W),D1
	MOVE.W	D1,D2
	ADD.W	D2,D2
	ADD.W	D2,D1
	LSL.W	#8,D1
	ADD.L	8(A6),D1
	MOVE.L	D1,12(A6)
	CLR.W	$1A(A6)
lbC000298

	bsr.w	PATINFO

	LEA	lbL00075C(PC),A0
	TST.W	$16(A0)
	BEQ.S	lbC0002BC
	MOVE.L	$18(A0),D1
	MOVE.W	D1,D0
	SWAP	D1
	MOVE.L	D1,$18(A0)
	ADD.W	8(A0),D0
	ADD.W	D0,D0
	MOVE.W	0(A4,D0.W),D0
	MOVE.W	D0,10(A0)
lbC0002BC	LEA	lbL000778(PC),A0
	TST.W	$16(A0)
	BEQ.S	lbC0002E0
	MOVE.L	$18(A0),D1
	MOVE.W	D1,D0
	SWAP	D1
	MOVE.L	D1,$18(A0)
	ADD.W	8(A0),D0
	ADD.W	D0,D0
	MOVE.W	0(A4,D0.W),D0
	MOVE.W	D0,10(A0)
lbC0002E0	LEA	lbL000794(PC),A0
	TST.W	$16(A0)
	BEQ.S	lbC000304
	MOVE.L	$18(A0),D1
	MOVE.W	D1,D0
	SWAP	D1
	MOVE.L	D1,$18(A0)
	ADD.W	8(A0),D0
	ADD.W	D0,D0
	MOVE.W	0(A4,D0.W),D0
	MOVE.W	D0,10(A0)
lbC000304	LEA	lbL0007B0(PC),A0
	TST.W	$16(A0)
	BEQ.S	lbC000328
	MOVE.L	$18(A0),D1
	MOVE.W	D1,D0
	SWAP	D1
	MOVE.L	D1,$18(A0)
	ADD.W	8(A0),D0
	ADD.W	D0,D0
	MOVE.W	0(A4,D0.W),D0
	MOVE.W	D0,10(A0)
lbC000328	LEA	lbL00075C(PC),A0
	TST.W	$10(A0)
	BEQ.S	lbC000370
	BMI.S	lbC000356
	MOVE.W	12(A0),D0
	MOVE.W	$12(A0),D1
	ADD.W	D1,D0
	CMP.W	#$40,D0
	BLE.S	lbC000348
	MOVE.W	#$40,D0
lbC000348	MOVE.W	D0,12(A0)
	MOVEA.L	0(A0),A1
;	MOVE.W	D0,8(A1)			; voice 1 volume

	bsr.w	SetVoice1

	BRA.S	lbC000370

lbC000356	MOVE.W	12(A0),D0
	MOVE.W	$12(A0),D1
	SUB.W	D1,D0
	BPL.S	lbC000364
	CLR.W	D0
lbC000364	MOVE.W	D0,12(A0)
	MOVEA.L	0(A0),A1
;	MOVE.W	D0,8(A1)			; voice 1 volume

	bsr.w	SetVoice1

lbC000370	LEA	lbL000778(PC),A0
	TST.W	$10(A0)
	BEQ.S	lbC0003B8
	BMI.S	lbC00039E
	MOVE.W	12(A0),D0
	MOVE.W	$12(A0),D1
	ADD.W	D1,D0
	CMP.W	#$40,D0
	BLE.S	lbC000390
	MOVE.W	#$40,D0
lbC000390	MOVE.W	D0,12(A0)
	MOVEA.L	0(A0),A1
;	MOVE.W	D0,8(A1)			; voice 2 volume

	bsr.w	SetVoice2

	BRA.S	lbC0003B8

lbC00039E	MOVE.W	12(A0),D0
	MOVE.W	$12(A0),D1
	SUB.W	D1,D0
	BPL.S	lbC0003AC
	CLR.W	D0
lbC0003AC	MOVE.W	D0,12(A0)
	MOVEA.L	0(A0),A1
;	MOVE.W	D0,8(A1)			; voice 2 volume

	bsr.w	SetVoice2

lbC0003B8	LEA	lbL000794(PC),A0
	TST.W	$10(A0)
	BEQ.S	lbC000400
	BMI.S	lbC0003E6
	MOVE.W	12(A0),D0
	MOVE.W	$12(A0),D1
	ADD.W	D1,D0
	CMP.W	#$40,D0
	BLE.S	lbC0003D8
	MOVE.W	#$40,D0
lbC0003D8	MOVE.W	D0,12(A0)
	MOVEA.L	0(A0),A1
;	MOVE.W	D0,8(A1)			; voice 3 volume

	bsr.w	SetVoice3

	BRA.S	lbC000400

lbC0003E6	MOVE.W	12(A0),D0
	MOVE.W	$12(A0),D1
	SUB.W	D1,D0
	BPL.S	lbC0003F4
	CLR.W	D0
lbC0003F4	MOVE.W	D0,12(A0)
	MOVEA.L	0(A0),A1
;	MOVE.W	D0,8(A1)			; voice 3 volume

	bsr.w	SetVoice3

lbC000400	LEA	lbL0007B0(PC),A0
	TST.W	$10(A0)
	BEQ.S	lbC000448
	BMI.S	lbC00042E
	MOVE.W	12(A0),D0
	MOVE.W	$12(A0),D1
	ADD.W	D1,D0
	CMP.W	#$40,D0
	BLE.S	lbC000420
	MOVE.W	#$40,D0
lbC000420	MOVE.W	D0,12(A0)
	MOVEA.L	0(A0),A1
;	MOVE.W	D0,8(A1)			; voice 4 volume

	bsr.w	SetVoice4

	BRA.S	lbC000448

lbC00042E	MOVE.W	12(A0),D0
	MOVE.W	$12(A0),D1
	SUB.W	D1,D0
	BPL.S	lbC00043C
	CLR.W	D0
lbC00043C	MOVE.W	D0,12(A0)
	MOVEA.L	0(A0),A1
;	MOVE.W	D0,8(A1)			; voice 4 volume

	bsr.w	SetVoice4

lbC000448	LEA	lbL00075C(PC),A0
	MOVEA.L	0(A0),A1
	MOVE.W	10(A0),D0
	ADD.W	$14(A0),D0
	MOVE.W	D0,10(A0)
	MOVE.W	D0,6(A1)			; voice 1 period
	LEA	lbL000778(PC),A0
	MOVEA.L	0(A0),A1
	MOVE.W	10(A0),D0
	ADD.W	$14(A0),D0
	MOVE.W	D0,10(A0)
	MOVE.W	D0,6(A1)			; voice 2 period
	LEA	lbL000794(PC),A0
	MOVEA.L	0(A0),A1
	MOVE.W	10(A0),D0
	ADD.W	$14(A0),D0
	MOVE.W	D0,10(A0)
	MOVE.W	D0,6(A1)			; voice 3 period
	LEA	lbL0007B0(PC),A0
	MOVEA.L	0(A0),A1
	MOVE.W	10(A0),D0
	ADD.W	$14(A0),D0
	MOVE.W	D0,10(A0)
	MOVE.W	D0,6(A1)			; voice 4 period
	SUBI.W	#1,$1E(A6)
	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTS

lbC0004B4	MOVEQ	#0,D0
	MOVE.B	1(A5),D0
	LSR.W	#4,D0
	MOVE.B	(A5),D1
	ANDI.B	#$C0,D1
	LSR.B	#2,D1
	OR.B	D1,D0
	TST.W	D0
	BEQ.S	lbC0004D4
	CMP.W	6(A0),D0
	BEQ.S	lbC0004D4
	MOVE.W	D0,6(A0)
lbC0004D4	CLR.W	$14(A0)
	CLR.W	$16(A0)
	CLR.W	$10(A0)
	MOVE.B	1(A5),D0
	ANDI.W	#15,D0
	MOVEQ	#0,D1
	MOVE.B	2(A5),D1
	CMP.W	#15,D0
	BNE.S	lbC0004FC
	MOVE.W	D1,$1C(A6)
	BRA.L	lbC0005C4

lbC0004FC	MOVE.W	#$FFFF,14(A0)
	CMP.W	#12,D0
	BNE.S	lbC00051E
	CMP.W	#$40,D1
	BLE.S	lbC000512
	MOVE.W	#$40,D1
lbC000512	MOVE.W	D1,14(A0)
	MOVE.W	D1,12(A0)
	BRA.L	lbC0005C4

lbC00051E	CMP.W	#13,D0
	BNE.L	lbC000530
	MOVE.W	#$FFFF,$24(A6)
	BRA.L	lbC0005C4

lbC000530	CMP.W	#11,D0
	BNE.S	lbC000544
	MOVE.W	#$FFFF,$24(A6)
	MOVE.W	D1,$26(A6)
	BRA.L	lbC0005C4

lbC000544	CMP.W	#14,D0
	BNE.S	lbC000564
	BTST	#0,D1
	BNE.S	lbC00055A
	BCLR	#1,$BFE001
	BRA.S	lbC0005C4

lbC00055A	BSET	#1,$BFE001
	BRA.S	lbC0005C4

lbC000564	CMP.W	#1,D0
	BNE.S	lbC000572
	NEG.W	D1
	MOVE.W	D1,$14(A0)
	BRA.S	lbC0005C4

lbC000572	CMP.W	#2,D0
	BNE.S	lbC00057E
	MOVE.W	D1,$14(A0)
	BRA.S	lbC0005C4

lbC00057E	CMP.W	#10,D0
	BNE.S	lbC0005A6
	MOVE.W	#$FFFF,D7
	CMP.W	#$10,D1
	BLT.L	lbC000594
	MOVE.W	#1,D7
lbC000594	MOVE.W	D1,D2
	ANDI.W	#15,D1
	LSR.W	#4,D2
	OR.W	D2,D1
	MOVE.W	D1,$12(A0)
	MOVE.W	D7,$10(A0)
lbC0005A6	TST.W	D0
	BNE.S	lbC0005C4
	TST.W	D1
	BEQ.S	lbC0005C4
	MOVE.W	D1,D2
	ANDI.W	#15,D1
	LSR.W	#4,D2
	MOVE.W	D1,$18(A0)
	MOVE.W	D2,$1A(A0)
	MOVE.W	#$FFFF,$16(A0)
lbC0005C4	CMPI.B	#$3F,(A5)
	BEQ.S	lbC0005D4
	MOVEQ	#0,D0
	MOVE.B	(A5),D0
	ANDI.B	#$3F,D0
	BSR.S	lbC0005E0
lbC0005D4	MOVEA.L	0(A0),A1
;	MOVE.W	12(A0),8(A1)				; volume

	move.l	D0,-(SP)
	move.w	12(A0),D0
	bsr.w	ChangeVolume
	move.l	(SP)+,D0

	RTS

lbC0005E0	MOVE.W	D0,8(A0)
	ADD.W	D0,D0
	MOVE.W	0(A4,D0.W),D0
	MOVE.W	D0,10(A0)
	MOVEQ	#0,D1
;	MOVEA.L	A3,A2

	lea	lbL0008AC(PC),A2

	MOVE.W	6(A0),D1
	SUBQ.W	#1,D1
	LSL.W	#4,D1
	ADDA.L	D1,A2
	MOVE.W	12(A2),D1
	TST.W	14(A0)
	BMI.L	lbC00060C
	MOVE.W	14(A0),D1
lbC00060C	MOVE.W	D1,12(A0)
	MOVE.W	4(A0),D2
	OR.W	D2,$22(A6)
	MOVEA.L	$10(A6),A1
	MOVE.L	(A2),(A1)+
	MOVE.W	4(A2),(A1)+
	MOVE.L	6(A2),(A1)+
	MOVE.W	10(A2),(A1)+
	MOVE.L	A1,$10(A6)
	MOVEA.L	0(A0),A1
	MOVE.W	D0,6(A1)				; period

	bsr.w	SetAll

	RTS

lbC000638	MOVE.W	$22(A6),D6
	MOVE.W	D6,D7
	ORI.W	#$8000,D7
	LEA	lbL00082C(PC),A1
	MOVE.W	D6,$DFF096
	BTST	#0,D6
	BEQ.L	lbC000666
	MOVE.W	4(A1),$DFF0A4
	MOVE.L	(A1),$DFF0A0
	LEA	12(A1),A1
lbC000666	BTST	#1,D6
	BEQ.L	lbC000680
	MOVE.W	4(A1),$DFF0B4
	MOVE.L	(A1),$DFF0B0
	LEA	12(A1),A1
lbC000680	BTST	#2,D6
	BEQ.L	lbC00069A
	MOVE.W	4(A1),$DFF0C4
	MOVE.L	(A1),$DFF0C0
	LEA	12(A1),A1
lbC00069A	BTST	#3,D6
	BEQ.L	lbC0006B0
	MOVE.W	4(A1),$DFF0D4
	MOVE.L	(A1),$DFF0D0
lbC0006B0
;	MOVE.W	#$104,D0
;lbC0006B4	DBRA	D0,lbC0006B4

	bsr.w	DMAWait

	MOVE.W	D7,$DFF096
;	MOVE.W	#$50,D0
;lbC0006C2	DBRA	D0,lbC0006C2

	bsr.w	DMAWait

	LEA	lbL00082C(PC),A1
	LEA	6(A1),A1
	BTST	#0,D6
	BEQ.L	lbC0006E8
	MOVE.W	4(A1),$DFF0A4
	MOVE.L	(A1),$DFF0A0
	LEA	12(A1),A1
lbC0006E8	BTST	#1,D6
	BEQ.L	lbC000702
	MOVE.W	4(A1),$DFF0B4
	MOVE.L	(A1),$DFF0B0
	LEA	12(A1),A1
lbC000702	BTST	#2,D6
	BEQ.L	lbC00071C
	MOVE.W	4(A1),$DFF0C4
	MOVE.L	(A1),$DFF0C0
	LEA	12(A1),A1
lbC00071C	BTST	#3,D6
	BEQ.L	lbC000732
	MOVE.W	4(A1),$DFF0D4
	MOVE.L	(A1),$DFF0D0
lbC000732	RTS

lbL000734	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbL00075C	dc.l	$DFF0A0
	dc.l	$10000
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbL000778	dc.l	$DFF0B0
	dc.l	$20000
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbL000794	dc.l	$DFF0C0
	dc.l	$40000
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbL0007B0	dc.l	$DFF0D0
	dc.l	$80000
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbL0007CC	dc.l	$6B00650
	dc.l	$5F405A0
	dc.l	$54C0500
	dc.l	$4B80474
	dc.l	$43403F8
	dc.l	$3C0038A
	dc.l	$3580328
	dc.l	$2FA02D0
	dc.l	$2A60280
	dc.l	$25C023A
	dc.l	$21A01FC
	dc.l	$1E001C5
	dc.l	$1AC0194
	dc.l	$17D0168
	dc.l	$1530140
	dc.l	$12E011D
	dc.l	$10D00FE
	dc.l	$F000E2
	dc.l	$D600CA
	dc.l	$BE00B4
	dc.l	$AA00A0
	dc.l	$97008F
	dc.l	$87007F
	dc.l	$780071
lbL00082C
	ds.b	12*4
lbL0008AC
	ds.b	31*16

BeastTable
	dc.w	4
	dc.w	$507
	dc.w	$1617
	dc.w	$1F23
	dc.w	$2526
	dc.w	$2900

SongTable
	ds.b	128

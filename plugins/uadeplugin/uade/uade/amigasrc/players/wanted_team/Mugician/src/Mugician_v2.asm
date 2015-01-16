	*****************************************************
	****      Mugician replayer for EaglePlayer, 	 ****
	****	     all adaptions by Wanted Team	 ****
	****      DeliTracker compatible (?) version	 ****
	*****************************************************

	incdir	"dh2:include/"
	include 'misc/eagleplayer2.01.i'

	SECTION	Player_Code,CODE

	PLAYERHEADER Tags

	dc.b	'$VER: Mugician player module V1.1 (29 Nov 2001)',0
	even
Tags
	dc.l	DTP_PlayerVersion,2
	dc.l	EP_PlayerVersion,9
	dc.l	DTP_RequestDTVersion,DELIVERSION
	dc.l	DTP_PlayerName,PlayerName
	dc.l	DTP_Creator,Creator
	dc.l	DTP_Check2,Check2
	dc.l	DTP_SubSongRange,SubSongRange
	dc.l	DTP_InitPlayer,InitPlayer
	dc.l	DTP_Interrupt,Interrupt
	dc.l	DTP_EndPlayer,EndPlayer
	dc.l	DTP_InitSound,InitSound
	dc.l	DTP_EndSound,EndSound
	dc.l	DTP_Volume,SetVolume
	dc.l	DTP_Balance,SetBalance
	dc.l	EP_Voices,SetVoices
	dc.l	EP_StructInit,StructInit
	dc.l	EP_Get_ModuleInfo,ModuleInfo
	dc.l	EP_GetPositionNr,GetPosition
	dc.l	EP_SampleInit,SampleInit
	dc.l	DTP_NextPatt,NextPattern
	dc.l	DTP_PrevPatt,PrevPattern
	dc.l	EP_PatternInit,PatternInit
	dc.l	EP_Flags,EPB_Volume!EPB_Balance!EPB_ModuleInfo!EPB_Voices!EPB_SampleInfo!EPB_Save!EPB_PrevPatt!EPB_NextPatt!EPB_Songend!EPB_Analyzer!EPB_NextSong!EPB_PrevSong!EPB_Packable!EPB_Restart
	dc.l	0

PlayerName
	dc.b	'Mugician',0
Creator
	dc.b	'(c) 1990-94 Reinier ''Rhino'' van Vliet,',10
	dc.b	'adapted by Wanted Team',0
Prefix	dc.b	'MUG.',0
	even

ModulePtr
	dc.l	0
EagleBase
	dc.l	0
SampleInfoPtr
	dc.l	0
SongName
	ds.b	12
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

	moveq	#4,D0
	move.w	D0,PI_Voices(A0)	; Number of stripes (MUST be at least 4)
	move.l	#CONVERTNOTE,PI_Convert(A0)
	move.l	D0,PI_Modulo(A0)	; Number of bytes to next row
	move.w	#64,PI_Pattlength(A0)	; Length of each stripe in rows

	move.w	#5,PI_Speed(A0)		; Default Speed Value
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

	move.b	(A0),D0
	beq.b	NoNote
	lea	PeriodTable(PC),A1
	add.w	D0,D0
	move.w	0(A1,D0.W),D0
NoNote
	move.b	1(A0),D1
	move.b	2(A0),D2
	beq.b	SkipCom
	cmp.b	#$40,D2
	bcs.b	NoCommand
	sub.b	#$3E,D2
	bra.b	SkipCom
NoCommand
	moveq	#0,D2
SkipCom
	move.b	3(A0),D3
	rts

PeriodTable
	dc.w	$650
	dc.w	$650
	dc.w	$650
	dc.w	$650
	dc.w	$650
	dc.w	$650
	dc.w	$650
	dc.w	$650
	dc.w	$650
	dc.w	$650
	dc.w	$650
	dc.w	$650
	dc.w	$64A+6
	dc.w	$5F0+4
	dc.w	$59A+6
	dc.w	$54A+2
	dc.w	$4FE+2
	dc.w	$4B6+2
	dc.w	$473+1
	dc.w	$433+1
	dc.w	$3F6+2
	dc.w	$3BD+3
	dc.w	$388+2
	dc.w	$355+3
	dc.w	$325+3
	dc.w	$2F8+2
	dc.w	$2CD+3
	dc.w	$2A5+1
	dc.w	$27F+1
	dc.w	$25B+1
	dc.w	$239+1
	dc.w	$219+1
	dc.w	$1FB+1
	dc.w	$1DF+1
	dc.w	$1C4+1
	dc.w	$1AA+2
	dc.w	$193+1
	dc.w	$17C+1
	dc.w	$167+1
	dc.w	$152+1
	dc.w	$13F+1
	dc.w	$12E
	dc.w	$11D
	dc.w	$10D
	dc.w	$FE
	dc.w	$EF+1
	dc.w	$E2
	dc.w	$D5+1
	dc.w	$C9+1
	dc.w	$BE
	dc.w	$B3+1
	dc.w	$A9+1
	dc.w	$A0
	dc.w	$97
	dc.w	$8E+1
	dc.w	$86+1
	dc.w	$7F

PATINFO
	movem.l	D0/D1/A0-A3,-(SP)
	lea	PATTERNINFO(PC),A0
	move.w	8(A1),PI_Pattpos(A0)	; Current Position in Pattern
	move.w	6(A1),D1
	move.w	D1,PI_Songpos(A0)
	move.w	14(A1),D0
	and.w	#15,D0
	move.w	D0,PI_Speed(A0)		; Speed Value
	move.l	lbL008558(PC),A0
	lsl.w	#3,D1
	lea	(A0,D1.W),A0
	move.l	lbL008568(PC),A1
	lea	STRIPE1(PC),A3
	moveq	#0,D0
	move.b	(A0),D0
	addq.l	#2,A0
	lsl.l	#8,D0
	lea	(A1,D0.L),A2
	move.l	A2,(A3)+
	moveq	#0,D0
	move.b	(A0),D0
	addq.l	#2,A0
	lsl.l	#8,D0
	lea	(A1,D0.L),A2
	move.l	A2,(A3)+
	moveq	#0,D0
	move.b	(A0),D0
	addq.l	#2,A0
	lsl.l	#8,D0
	lea	(A1,D0.L),A2
	move.l	A2,(A3)+
	moveq	#0,D0
	move.b	(A0),D0
	addq.l	#2,A0
	lsl.l	#8,D0
	lea	(A1,D0.L),A2
	move.l	A2,(A3)
	movem.l	(SP)+,D0/D1/A0-A3
	rts

***************************************************************************
******************************* DTP_NextPatt ******************************
***************************************************************************

NextPattern
	lea	lbW0083EC(PC),A1
	clr.w	8(A1)
	move.w	#1,2(A1)
	addq.w	#1,6(A1)
	move.w	$10(A1),D5
	cmp.w	6(A1),D5
	bne.b	NoMaxPos
	bsr.w	SongEnd
	move.l	lbL008554(PC),A0
	move.b	1(A0),7(A1)
	clr.b	6(A1)
NoMaxPos
	rts

***************************************************************************
******************************* DTP_PrevPatt ******************************
***************************************************************************

PrevPattern
	lea	lbW0083EC(PC),A1
	tst.b	7(A1)
	beq.b	MinPos
	clr.w	8(A1)
	move.w	#1,2(A1)
	subq.w	#1,6(A1)
MinPos
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

	move.l	64(A2),D5
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
	move.l	68(A2),D5
	beq.b	NoNormal
	subq.l	#1,D5
	sub.l	72(A2),A2
	add.l	InfoBuffer+CalcSize(PC),A2
	lea	-256(A2),A2
	move.l	SampleInfoPtr(PC),A1
	move.l	A2,A0

Normal
	jsr	ENPP_AllocSampleStruct(A5)
	move.l	D0,(A3)
	beq.b	return
	move.l	D0,A3

	move.l	A0,A2
	move.l	4(A1),D1
	sub.l	(A1),D1
	add.l	(A1),A2

	move.l	A2,EPS_Adr(A3)			; sample address
	move.l	D1,EPS_Length(A3)		; sample length
	move.l	#64,EPS_Volume(A3)
	move.w	#USITY_RAW,EPS_Type(A3)
	move.w	#USIB_Playable!USIB_Saveable!USIB_8BIT,EPS_Flags(A3)
	lea	32(A1),A1
	dbf	D5,Normal

NoNormal
	moveq	#0,D7
return
	move.l	D7,D0
	rts

***************************************************************************
***************************** EP_GetPositionNr ****************************
***************************************************************************

GetPosition
	moveq	#0,D0
	move.w	CurrentPos(pc),D0
	rts

***************************************************************************
***************************** EP_Get_ModuleInfo ***************************
***************************************************************************

ModuleInfo	
		lea	InfoBuffer(PC),A0
		rts

SubSongs	=	4
LoadSize	=	12
CalcSize	=	20
Length		=	36
SamplesSize	=	44
SongSize	=	52
Samples		=	60
Pattern		=	68
SynthSamples	=	76

InfoBuffer
	dc.l	MI_SubSongs,0		;4
	dc.l	MI_LoadSize,0		;12
	dc.l	MI_Calcsize,0		;20
	dc.l	MI_SongName,SongName	;28
	dc.l	MI_Length,0		;36
	dc.l	MI_SamplesSize,0	;44
	dc.l	MI_Songsize,0		;52
	dc.l	MI_Samples,0		;60
	dc.l	MI_Pattern,0		;68
	dc.l	MI_SynthSamples,0	;76
	dc.l	MI_MaxSamples,32
	dc.l	MI_MaxPattern,256
	dc.l	MI_MaxLength,128
	dc.l	MI_MaxSynthSamples,32
	dc.l	MI_MaxSubSongs,8
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
	lea	$DFF0A0,A6
SetNew
	move.w	(A1)+,D1
	bsr.b	ChangeVolume
	addq.l	#8,A6
	addq.l	#8,A6
	dbf	D0,SetNew
	rts

ChangeVolume
	and.w	#$7F,D1
	cmpa.l	#$DFF0A0,A6			;Left Volume
	bne.b	NoVoice1
	move.w	D1,OldVoice1
	tst.w	Voice1
	bne.b	Voice1On
	moveq	#0,D1
Voice1On
	mulu.w	LeftVolume(PC),D1
	bra.b	SetIt
NoVoice1
	cmpa.l	#$DFF0B0,A6			;Right Volume
	bne.b	NoVoice2
	move.w	D1,OldVoice2
	tst.w	Voice2
	bne.b	Voice2On
	moveq	#0,D1
Voice2On
	mulu.w	RightVolume(PC),D1
	bra.b	SetIt
NoVoice2
	cmpa.l	#$DFF0C0,A6			;Right Volume
	bne.b	NoVoice3
	move.w	D1,OldVoice3
	tst.w	Voice3
	bne.b	Voice3On
	moveq	#0,D1
Voice3On
	mulu.w	RightVolume(PC),D1
	bra.b	SetIt
NoVoice3
	move.w	D1,OldVoice4
	tst.w	Voice4
	bne.b	Voice4On
	moveq	#0,D1
Voice4On
	mulu.w	LeftVolume(PC),D1
SetIt
	lsr.w	#6,D1
	move.w	D1,8(A6)
	rts

*------------------------------- Set Vol -------------------------------*

SetVol
	move.l	A0,-(A7)
	lea	StructAdr+UPS_Voice1Vol(PC),A0
	cmp.l	#$DFF0A0,A6
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice2Vol(PC),A0
	cmp.l	#$DFF0B0,A6
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice3Vol(PC),A0
	cmp.l	#$DFF0C0,A6
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice4Vol(PC),A0
.SetVoice
	move.w	D1,(A0)
	move.l	(A7)+,A0
	rts

*------------------------------- Set Adr -------------------------------*

SetAdr
	move.l	A0,-(A7)
	lea	StructAdr+UPS_Voice1Adr(PC),A0
	cmp.l	#$DFF0A0,A6
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice2Adr(PC),A0
	cmp.l	#$DFF0B0,A6
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice3Adr(PC),A0
	cmp.l	#$DFF0C0,A6
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice4Adr(PC),A0
.SetVoice
	move.l	D0,(A0)
	move.w	$10(A5),UPS_Voice1Per(A0)
	move.l	(A7)+,A0
	rts

*------------------------------- Set Len -------------------------------*

SetLen
	move.l	A0,-(A7)
	lea	StructAdr+UPS_Voice1Len(PC),A0
	cmp.l	#$DFF0A0,A6
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice2Len(PC),A0
	cmp.l	#$DFF0B0,A6
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice3Len(PC),A0
	cmp.l	#$DFF0C0,A6
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice4Len(PC),A0
.SetVoice
	move.w	D1,(A0)
	move.l	(A7)+,A0
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
	lea	text(PC),A1
	moveq	#$19,D6
test	move.b	(A1)+,D2
	cmp.b	(A0)+,D2
	bne.b	Fault
	dbra	D6,test	
	moveq	#0,D0
Fault
	rts
text
	dc.b	' MUGICIAN/SOFTEYES 1990 '
	dc.w	1

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
	move.l	A0,(A6)+		; module buffer
	move.l	A5,(A6)+		; EagleBase

	lea	InfoBuffer(PC),A4
	move.l	D0,LoadSize(A4)

	move.l	ModulePtr(PC),A0

	move.l	#460,D0
	lea	204(A0),A1
	moveq	#0,D1
	lea	26(A0),A0
	move.w	(A0)+,D1
	move.l	D1,Pattern(A4)
	move.l	A0,A3
	lsl.l	#8,D1
	add.l	D1,D0
	move.l	A1,A2
	moveq	#0,D1
	moveq	#7,D2
NextLength
	add.l	(A0)+,D1
	dbf	D2,NextLength
	lsl.l	#3,D1
	add.l	D1,D0
	add.l	D1,A2
	move.l	(A0)+,D1
	lsl.l	#4,D1
	add.l	D1,D0
	add.l	D1,A2
	move.l	(A0)+,D1
	move.l	D1,SynthSamples(A4)
	lsl.l	#7,D1
	add.l	D1,D0
	add.l	D1,A2
	move.l	A2,(A6)				; SampleInfoPtr
	move.l	(A0)+,D1
	move.l	D1,Samples(A4)
	lsl.l	#5,D1
	add.l	D1,D0
	move.l	D0,SongSize(A4)
	move.l	(A0),D1
	move.l	D1,SamplesSize(A4)
	add.l	D1,D0
	move.l	D0,CalcSize(A4)
	cmp.l	LoadSize(A4),D0
	ble.b	SizeOK
	moveq	#EPR_ModuleTooShort,D0		; error message
	rts
SizeOK	
	move.l	A1,A2
	moveq	#7,D2
	moveq	#0,D0
	moveq	#1,D3
	lea	-128(A1),A0
Dalej
	tst.l	(A0)
	beq.b	FoundSub
	cmp.l	(A3),D3
	bne.b	AddSub
	move.l	A2,A1
	tst.l	(A1)+
	bne.b	AddSub
	tst.l	(A1)
	beq.b	SkipIt
AddSub
	addq.l	#1,D0
SkipIt
	move.l	(A3)+,D1
	lsl.l	#3,D1
	add.l	D1,A2
	lea	16(A0),A0
	dbf	D2,Dalej
FoundSub
	move.l	D0,SubSongs(A4)

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

	moveq	#0,D0
	move.w	dtg_SndNum(A5),D0
	move.l	ModulePtr(PC),A0
	lea	28(A0),A1
	move.l	A1,A4
	lea	204(A0),A3
	moveq	#-1,D3
	moveq	#1,D2
Next
	cmp.l	(A4),D2
	bne.b	PosOK
	move.l	A3,A2
	tst.l	(A2)+
	bne.b	PosOK
	tst.l	(A2)
	bne.b	PosOK
	addq.l	#1,D3
	move.l	(A4)+,D1
	lsl.l	#3,D1
	add.l	D1,A3
	bra.b	Next
PosOK
	addq.l	#1,D3
	move.l	(A4)+,D1
	lsl.l	#3,D1
	add.l	D1,A3
	dbf	D0,Next

	move.l	D3,D0
	lea	80(A0),A0
	lea	SongName(PC),A2
NextSong
	move.l	(A1)+,D2
	move.l	(A0)+,(A2)
	move.l	(A0)+,4(A2)
	move.l	(A0)+,8(A2)
	addq.l	#4,A0
	dbf	D3,NextSong

	lea	InfoBuffer(PC),A4
	move.l	D2,Length(A4)
	bra.w	Init

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
**************************** Mugician player ******************************
***************************************************************************

; Modified version of the latest Mugician II player

lbC006D8A
	moveq	#0,D6

	MOVEQ	#0,D4
	MOVE.W	D0,D4
	MOVE.W	D4,D6
	ASL.W	#4,D6
;	LEA	mod+76,A4
;	LEA	mod,A5

	move.l	ModulePtr(PC),A5
	lea	76(A5),A4

	LEA	lbL008554(pc),A6
	MOVE.L	A4,(A6)
	ADD.L	D6,(A6)
	LEA	$80(A4),A4
	LEA	$1C(A5),A2
	MOVEQ	#0,D2
	MOVEQ	#7,D5
lbC006DD2	MOVE.L	(A2)+,D3
	ASL.L	#3,D3
	CMP.W	D2,D4
	BNE.L	lbC006DE0
	MOVE.L	A4,4(A6)
lbC006DE0
	ADDQ.W	#1,D2
	LEA	0(A4,D3.L),A4
	DBRA	D5,lbC006DD2
	MOVE.L	$3C(A5),D3
	ASL.L	#4,D3
	MOVE.L	A4,8(A6)
	LEA	0(A4,D3.L),A4
	MOVE.L	$40(A5),D3
	ASL.L	#7,D3
	MOVE.L	A4,$10(A6)
	LEA	0(A4,D3.L),A4
	MOVE.L	$44(A5),D3
	MOVE.L	A4,$18(A6)
	ASL.L	#5,D3
	LEA	0(A4,D3.L),A4
	MOVEQ	#0,D3
	MOVE.W	$1A(A5),D3
	ASL.L	#8,D3
	MOVE.L	A4,$14(A6)
	LEA	0(A4,D3.L),A4
	MOVE.L	A4,$1C(A6)
	MOVE.L	$48(A5),D3
	LEA	0(A4,D3.L),A4
	TST.W	$18(A5)
	BEQ.L	lbC006E4A
	MOVE.L	A4,12(A6)
	RTS

lbC006E4A	MOVE.L	A4,12(A6)
	MOVE.W	#$FF,D7
lbC006E52	CLR.B	(A4)+
	DBRA	D7,lbC006E52
	RTS

Init
lbC006E78	BSET	#1,$BFE001
	LEA	lbW0083F8(pc),A0
	MOVE.W	D0,(A0)
	BSR.L	lbC006D8A
	LEA	lbL008400(pc),A0

	moveq	#$2F,D7

lbC006EA2	CLR.L	(A0)+
	DBRA	D7,lbC006EA2
	LEA	lbW0083EC(pc),A0
	CLR.L	(A0)+
	CLR.W	(A0)+
	ADDQ.W	#2,A0
	CLR.L	(A0)+

	move.w	#$7C,$DFF0A4
	move.w	#$7C,$DFF0B4
	move.w	#$7C,$DFF0C4
	move.w	#$7C,$DFF0D4
	move.w	#0,$DFF0A8
	move.w	#0,$DFF0B8
	move.w	#0,$DFF0C8
	move.w	#0,$DFF0D8
	move.w	#15,$DFF096
	moveq	#3,D7

	LEA	lbL008400(pc),A0
	LEA	lbL008400(pc),A1
lbC006F48	MOVE.W	lbW0083F8(pc),D0
lbC006F62	MOVE.W	D0,(A0)+
	CLR.W	(A0)+
	CLR.W	(A0)+
	CLR.W	(A0)+
	CLR.W	(A0)+
	CLR.W	(A0)+
	CLR.W	(A0)+
	CLR.W	(A0)+
	CLR.W	(A0)+
	CLR.W	(A0)+
	CLR.W	(A0)+
	CLR.W	(A0)+
	CLR.W	(A0)+
	CLR.W	(A0)+
	CLR.W	(A0)+
	CLR.W	(A0)+
	CLR.W	(A0)+
	CLR.W	(A0)+
	CLR.W	(A0)+
	LEA	$30(A1),A1
	LEA	(A1),A0
	DBRA	D7,lbC006F48
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVEA.L	lbL008554(pc),A0
	MOVE.B	3(A0),D1
	MOVE.W	D1,lbW0083FC
	MOVE.B	2(A0),D1
	MOVE.W	D1,lbW0083EC
	MOVE.B	D1,D0
	ANDI.B	#15,D0
	ANDI.B	#15,D1
	ASL.B	#4,D0
	OR.B	D0,D1
	MOVE.W	D1,lbW0083FA
	MOVE.W	#1,lbW0083EE
	MOVE.W	#1,lbW0083F0
	MOVE.W	#$40,lbW0083FE
	CLR.W	lbW0083F4
	CLR.W	lbW0083F2
	RTS

Play
	MOVEM.L	D0-D7/A0-A6,-(SP)
	MOVE.L	#$80808080,lbL00782A
	MOVE.L	#lbL00782A,lbL007826
	BSR.L	lbC007E96
	LEA	lbW0083EC(pc),A1
	LEA	$DFF0A0,A6
	LEA	lbL008400(pc),A5
	MOVE.W	#1,10(A1)
	MOVEQ	#0,D6
	MOVEA.L	lbL008558(pc),A0
	BSR.L	lbC00752E
	LEA	$10(A6),A6
	LEA	$30(A5),A5
	MOVEQ	#2,D6
	MOVE.W	D6,10(A1)
	MOVEA.L	lbL008558(pc),A0
	BSR.L	lbC00752E
	LEA	$10(A6),A6
	LEA	$30(A5),A5
	MOVEQ	#4,D6
	MOVE.W	D6,10(A1)
	MOVEA.L	lbL008558(pc),A0
	BSR.L	lbC00752E
	LEA	$10(A6),A6
	LEA	$30(A5),A5
	MOVE.W	#8,10(A1)
	MOVEQ	#6,D6
	MOVEA.L	lbL008558(pc),A0
	BSR.L	lbC00752E
lbC007190	LEA	$DFF0A0,A6
	LEA	lbL008400(pc),A5
	BSR.L	lbC007832
	LEA	$10(A6),A6
	LEA	$30(A5),A5
	BSR.L	lbC007832
	LEA	$10(A6),A6
	LEA	$30(A5),A5
	BSR.L	lbC007832
	LEA	$10(A6),A6
	LEA	$30(A5),A5
	BSR.L	lbC007832
lbC0071C4	CLR.L	2(A1)
	SUBI.W	#1,(A1)
	BNE.L	lbC007252
	MOVE.W	14(A1),(A1)
	ANDI.W	#15,(A1)
	MOVE.W	14(A1),D5
	ANDI.W	#15,D5
	MOVE.W	14(A1),D0
	ANDI.W	#$F0,D0
	ASR.W	#4,D0
	ASL.W	#4,D5
	OR.W	D0,D5
	MOVE.W	D5,14(A1)
	MOVE.W	#1,4(A1)
	ADDI.W	#1,8(A1)
	MOVE.W	$12(A1),D5
	CMPI.W	#$40,8(A1)
	BEQ.L	lbC007214
	CMP.W	8(A1),D5
	BNE.L	lbC007252
lbC007214	CLR.W	8(A1)
	MOVE.W	#1,2(A1)
	ADDI.W	#1,6(A1)
	MOVE.W	$10(A1),D5
	CMP.W	6(A1),D5
	BNE.L	lbC007252

	bsr.w	SongEnd

	MOVEA.L	lbL008554(pc),A0
;	MOVEQ	#0,D0
;	TST.B	0(A0,D0.L)
;	MOVE.B	#0,7(A1)

	move.b	1(A0),7(A1)

	CLR.B	6(A1)

lbC007252

	bsr.w	DMAWait

	MOVE.W	#$800F,$DFF096

	bsr.w	PATINFO

	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTS

lbC00752E	MOVEQ	#0,D0
	TST.W	2(A1)
	BEQ.L	lbC007550
	MOVE.W	(A5),D0
	ROR.W	#6,D0
	MOVE.W	6(A1),D0
	ASL.W	#3,D0
	ADD.W	D0,D6
	MOVE.B	0(A0,D6.L),3(A5)
	MOVE.B	1(A0,D6.L),9(A5)
lbC007550	TST.W	4(A1)
	BEQ.L	lbC007778
	MOVEA.L	lbL008568(pc),A0
	MOVE.W	2(A5),D0
	ASL.W	#8,D0
	LEA	0(A0,D0.L),A0
	MOVE.W	8(A1),D0
	ASL.W	#2,D0
	TST.B	0(A0,D0.L)
	BEQ.L	lbC007778
	LEA	0(A0,D0.L),A0
	CMPI.B	#$4A,2(A0)
	BEQ.L	lbC0075AC
	MOVE.B	(A0),7(A5)
	TST.B	1(A0)
	BEQ.L	lbC0075AC
	MOVE.B	1(A0),5(A5)
	SUBI.B	#1,5(A5)
lbC0075AC	ANDI.B	#$3F,5(A5)
	CLR.B	15(A5)
	CMPI.B	#$40,2(A0)
	BCS.L	lbC0075D0
	MOVE.B	2(A0),15(A5)
	SUBI.B	#$3E,15(A5)
	BRA.L	lbC0075D6

lbC0075D0	MOVE.B	#1,15(A5)
lbC0075D6	MOVE.B	3(A0),13(A5)
	MOVEA.L	lbL00855C(pc),A4
	MOVE.W	4(A5),D0
	ASL.W	#4,D0
	LEA	0(A4,D0.L),A4
	MOVE.B	8(A4),$13(A5)
	CMPI.B	#12,15(A5)
	BEQ.L	lbC007638
	MOVE.B	2(A0),11(A5)
	CMPI.B	#1,15(A5)
	BNE.L	lbC007664
	LEA	lbL008982(pc),A2
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVE.B	11(A5),D1
	MOVE.W	8(A5),D0
	EXT.W	D0
	ADD.W	D0,D1
	MOVE.W	$12(A5),D0
	ASL.W	#7,D0
	LEA	0(A2,D0.L),A2
	ADD.W	D1,D1
	MOVE.W	0(A2,D1.L),$2A(A5)
	BRA.L	lbC007664

lbC007638	MOVE.B	(A0),11(A5)
	LEA	lbL008982(pc),A2
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVE.B	11(A5),D1
	MOVE.W	8(A5),D0
	EXT.W	D0
	ADD.W	D0,D1
	MOVE.W	$12(A5),D0
	ASL.W	#7,D0
	LEA	0(A2,D0.L),A2
	ADD.W	D1,D1
	MOVE.W	0(A2,D1.L),$2A(A5)
lbC007664	MOVEA.L	lbL00855C(pc),A4
	MOVE.W	4(A5),D0
	ASL.W	#4,D0
	LEA	0(A4,D0.L),A4
	MOVE.B	8(A4),$13(A5)
	CMPI.B	#11,15(A5)
	BNE.L	lbC007690
	MOVE.B	13(A5),4(A4)
	ANDI.B	#7,4(A4)
lbC007690	MOVEQ	#0,D1
	MOVEA.L	lbL008564(pc),A3
	MOVE.B	(A4),D1
	CMPI.B	#12,15(A5)
	BEQ.L	lbC00773E
	CMPI.B	#$20,D1
	BCC.L	lbC007E2A
	ASL.W	#7,D1
	LEA	0(A3,D1.L),A3
	MOVE.L	A3,(A6)

	move.l	D0,-(A7)
	move.l	A3,D0
	bsr.w	SetAdr
	move.l	(A7)+,D0

	MOVEQ	#0,D1
	MOVE.B	1(A4),D1
	MOVE.W	D1,4(A6)

	bsr.w	SetLen

	CMPI.B	#12,15(A5)
	BEQ.L	lbC0076DA
	CMPI.B	#10,15(A5)
	BEQ.L	lbC0076DA
	MOVE.W	10(A1),$DFF096
lbC0076DA
	TST.B	11(A4)
	BEQ.L	lbC00773E
	CMPI.B	#2,15(A5)
	BEQ.L	lbC00773E
	CMPI.B	#4,15(A5)
	BEQ.L	lbC00773E
	CMPI.B	#12,15(A5)
	BEQ.L	lbC00773E
	MOVEQ	#0,D0
	MOVE.B	12(A4),D0
	ASL.W	#7,D0
	MOVEA.L	lbL008564(pc),A3
	LEA	0(A3,D0.L),A3
	MOVEQ	#0,D0
	MOVE.B	(A4),D0
	ASL.W	#7,D0
	MOVEA.L	lbL008564(pc),A2
	LEA	0(A2,D0.L),A2
	CLR.B	6(A4)
	MOVEQ	#$1F,D7
lbC007732	MOVE.L	(A3)+,(A2)+
	DBRA	D7,lbC007732
	MOVE.B	14(A4),$29(A5)
lbC00773E	CMPI.B	#3,15(A5)
	BEQ.L	lbC007766
	CMPI.B	#4,15(A5)
	BEQ.L	lbC007766
	CMPI.B	#12,15(A5)
	BEQ.L	lbC007766
	MOVE.W	#1,$18(A5)
	CLR.W	$16(A5)
lbC007766	CLR.W	$2C(A5)
	MOVE.B	7(A4),$1D(A5)
	CLR.W	$1E(A5)
	CLR.W	$1A(A5)
lbC007778	CMPI.B	#5,15(A5)
	BEQ.L	lbC0077C0
	CMPI.B	#6,15(A5)
	BEQ.L	lbC0077DA
	CMPI.B	#7,15(A5)
	BEQ.L	lbC0077AC
	CMPI.B	#8,15(A5)
	BEQ.L	lbC0077B6
	CMPI.B	#13,15(A5)
	BEQ.L	lbC0077FE
	RTS

lbC0077AC	BCLR	#1,$BFE001
	RTS

lbC0077B6	BSET	#1,$BFE001
	RTS

lbC0077C0	MOVEQ	#0,D0
	MOVE.B	13(A5),D0
	TST.W	D0
	BEQ.L	lbC007A7A
	CMPI.W	#$40,D0
	BHI.L	lbC007A7A
	MOVE.W	D0,$12(A1)
	RTS

lbC0077DA	MOVEQ	#0,D0
	MOVE.B	13(A5),D0
	ANDI.W	#15,D0
	MOVE.B	D0,D1
	ASL.B	#4,D0
	OR.B	D1,D0
	TST.B	D1
	BEQ.L	lbC007A7A
	CMPI.B	#15,D1
	BHI.L	lbC007A7A
	MOVE.W	D0,14(A1)
	RTS

lbC0077FE	CLR.B	15(A5)
	MOVEQ	#0,D0
	MOVE.B	13(A5),D0
	MOVE.B	D0,D1
	ANDI.B	#15,D1
	TST.B	D1
	BEQ.L	lbC007A7A
	MOVE.B	D0,D1
	ANDI.B	#$F0,D1
	TST.B	D1
	BEQ.L	lbC007A7A
	MOVE.W	D0,14(A1)
	RTS

lbL007826	dc.l	0
lbL00782A	dc.l	0
	dc.l	0

lbC007832	CMPI.B	#9,15(A5)
	BNE.L	lbC007844
	BCHG	#1,$BFE001
lbC007844	MOVEQ	#0,D0
	MOVEA.L	lbL00855C(pc),A4
	MOVE.W	4(A5),D0
	ASL.W	#4,D0
	LEA	0(A4,D0.L),A4
	MOVEM.L	D0-D7/A0-A6,-(SP)
	TST.B	11(A4)
	BEQ.L	lbC0078E8
	CMPI.B	#$20,(A4)
	BCC.L	lbC0078E8
	MOVEA.L	lbL007826(pc),A2
	LEA	lbL00782A(pc),A3
	MOVEQ	#0,D0
	MOVE.B	5(A5),D0
	ADDQ.W	#1,D0
	CMP.B	(A3)+,D0
	BEQ.L	lbC0078E8
	CMP.B	(A3)+,D0
	BEQ.L	lbC0078E8
	CMP.B	(A3)+,D0
	BEQ.L	lbC0078E8
	CMP.B	(A3)+,D0
	BEQ.L	lbC0078E8
	MOVE.B	D0,(A2)+
	ADDI.L	#1,lbL007826
	TST.B	$29(A5)
	BNE.L	lbC0078E2
	MOVE.B	14(A4),$29(A5)
	LEA	lbL007A7C(pc),A2
	MOVEQ	#0,D0
	MOVE.B	11(A4),D0
	ASL.W	#2,D0
	MOVEA.L	0(A2,D0.L),A2
	MOVEA.L	lbL008564(pc),A3
	MOVEQ	#0,D3
	MOVE.B	(A4),D3
	ASL.W	#7,D3
	LEA	0(A3,D3.L),A3
	JSR	(A2)
	BRA.L	lbC0078E8

lbC0078E2	SUBI.B	#1,$29(A5)
lbC0078E8	MOVEM.L	(SP)+,D0-D7/A0-A6
lbC0078EC	TST.W	$18(A5)
	BEQ.L	lbC00795A
	SUBI.W	#1,$18(A5)
	TST.W	$18(A5)
	BNE.L	lbC00795A
	MOVE.B	3(A4),$19(A5)
	ADDI.W	#1,$16(A5)
	ANDI.W	#$7F,$16(A5)
	TST.W	$16(A5)
	BNE.L	lbC00792E
	BTST	#1,15(A4)
	BNE.L	lbC00792E
	CLR.W	$18(A5)
	BRA.L	lbC00795A

lbC00792E	MOVE.W	$16(A5),D0
	MOVEQ	#0,D1
	MOVEA.L	lbL008564(pc),A3
	MOVE.B	2(A4),D1
	ASL.W	#7,D1
	ADD.W	D0,D1
	LEA	0(A3,D1.L),A3
	MOVEQ	#0,D1
	MOVE.B	(A3),D1
	ADDI.B	#$81,D1
	NEG.B	D1
	ASR.W	#2,D1
;	MOVE.W	D1,8(A6)

	bsr.w	ChangeVolume
	bsr.w	SetVol

	MOVE.W	D1,$24(A5)
lbC00795A	LEA	lbL008982(pc),A2
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVE.W	6(A5),D1
	TST.B	4(A4)
	BEQ.L	lbC007994
	MOVEA.L	lbL008560(pc),A3
	MOVE.B	4(A4),D0
	ASL.W	#5,D0
	LEA	0(A3,D0.L),A3
	MOVE.W	$1A(A5),D0
	ADD.B	0(A3,D0.L),D1
	ADDI.W	#1,$1A(A5)
	ANDI.W	#$1F,$1A(A5)
lbC007994	MOVE.W	8(A5),D0
	EXT.W	D0
	ADD.W	D0,D1
	MOVE.W	$12(A5),D0
	ASL.W	#7,D0
	LEA	0(A2,D0.L),A2
	ADD.W	D1,D1
	MOVE.W	0(A2,D1.L),$10(A5)
	MOVE.W	$10(A5),D3
	CMPI.B	#12,15(A5)
	BEQ.L	lbC0079C6
	CMPI.B	#1,15(A5)
	BNE.L	lbC007A1E
lbC0079C6	MOVE.W	12(A5),D0
	EXT.W	D0
	NEG.W	D0
	ADD.W	D0,$2C(A5)
	MOVE.W	$10(A5),D1
	ADD.W	$2C(A5),D1
	MOVE.W	D1,$10(A5)
	TST.W	12(A5)
	BEQ.L	lbC007A1E
	BTST	#15,D0
	BEQ.L	lbC007A08
	CMP.W	$2A(A5),D1
	BHI.L	lbC007A1E
	MOVE.W	$2A(A5),D1
	SUB.W	D3,D1
	MOVE.W	D1,$2C(A5)
	CLR.W	12(A5)
	BRA.L	lbC007A1E

lbC007A08	CMP.W	$2A(A5),D1
	BCS.L	lbC007A1E
	MOVE.W	$2A(A5),D1
	SUB.W	D3,D1
	MOVE.W	D1,$2C(A5)
	CLR.W	12(A5)
lbC007A1E	TST.B	5(A4)
	BEQ.L	lbC007A74
	TST.B	$1D(A5)
	BEQ.L	lbC007A38
	SUBI.B	#1,$1D(A5)
	BRA.L	lbC007A74

lbC007A38	MOVEA.L	lbL008564(pc),A3
	MOVEQ	#0,D1
	MOVE.B	5(A4),D1
	ASL.W	#7,D1
	LEA	0(A3,D1.L),A3
	MOVE.W	$1E(A5),D1
	ADDI.W	#1,$1E(A5)
	ANDI.W	#$7F,$1E(A5)
	TST.W	$1E(A5)
	BNE.L	lbC007A68
	MOVE.B	9(A4),$1F(A5)
lbC007A68	MOVE.B	0(A3,D1.L),D1
	EXT.W	D1
	NEG.W	D1
	ADD.W	D1,$10(A5)
lbC007A74	MOVE.W	$10(A5),6(A6)
lbC007A7A	RTS

lbL007A7C
	dc.l	lbC007A7A
	dc.l	lbC007DCC
	dc.l	lbC007CA0
	dc.l	lbC007D86
	dc.l	lbC007D96
	dc.l	lbC007C46
	dc.l	lbC007C30
	dc.l	lbC007D2C
	dc.l	lbC007C60
	dc.l	lbC007CFE
	dc.l	lbC007DE4
	dc.l	lbC007AFC
	dc.l	lbC007B96
	dc.l	lbC007E0A
	dc.l	lbC007D50
	dc.l	lbC007DAA
	dc.l	lbC007A7A
	dc.l	lbC007A7A
	dc.l	lbC007A7A
	dc.l	lbC007A7A
	dc.l	lbC007A7A
	dc.l	lbC007A7A
	dc.l	lbC007A7A
	dc.l	lbC007A7A
	dc.l	lbC007A7A
	dc.l	lbC007A7A
	dc.l	lbC007A7A
	dc.l	lbC007A7A
	dc.l	lbC007A7A
	dc.l	lbC007A7A
	dc.l	lbC007A7A
	dc.l	lbC007A7A

lbC007AFC	MOVEQ	#0,D3
	MOVEA.L	lbL008564(pc),A0
	MOVE.B	12(A4),D3
	ASL.W	#7,D3
	LEA	0(A0,D3.L),A0
	MOVEQ	#0,D3
	MOVEA.L	lbL008564(pc),A2
	MOVE.B	13(A4),D3
	ASL.W	#7,D3
	LEA	0(A2,D3.L),A2
	ADDI.B	#1,6(A4)
	ANDI.B	#$7F,6(A4)
	MOVEQ	#0,D0
	MOVE.B	6(A4),D0
	CMPI.B	#$40,D0
	BCC.L	lbC007B66
	MOVE.L	D0,D3
	EORI.B	#$FF,D3
	ANDI.W	#$3F,D3
	MOVEQ	#0,D7
	MOVE.B	1(A4),D7
	ADD.B	D7,D7
	SUBQ.W	#1,D7
lbC007B4E	MOVE.B	(A0)+,D1
	MOVE.B	(A2)+,D2
	EXT.W	D1
	EXT.W	D2
	MULU.W	D0,D1
	MULU.W	D3,D2
	ADD.W	D1,D2
	ASR.W	#6,D2
	MOVE.B	D2,(A3)+
	DBRA	D7,lbC007B4E
	RTS

lbC007B66	MOVEQ	#0,D7
	MOVE.B	1(A4),D7
	ADD.B	D7,D7
	SUBQ.W	#1,D7
	MOVEQ	#$7F,D3
	SUB.L	D0,D3
	MOVE.L	D3,D0
	EORI.B	#$FF,D3
	ANDI.W	#$3F,D3
lbC007B7E	MOVE.B	(A0)+,D1
	MOVE.B	(A2)+,D2
	EXT.W	D1
	EXT.W	D2
	MULU.W	D0,D1
	MULU.W	D3,D2
	ADD.W	D1,D2
	ASR.W	#6,D2
	MOVE.B	D2,(A3)+
	DBRA	D7,lbC007B7E
	RTS

lbC007B96	MOVEQ	#0,D3
	MOVEA.L	lbL008564(pc),A0
	MOVE.B	12(A4),D3
	ASL.W	#7,D3
	LEA	0(A0,D3.L),A0
	MOVEQ	#0,D3
	MOVEA.L	lbL008564(pc),A2
	MOVE.B	13(A4),D3
	ASL.W	#7,D3
	LEA	0(A2,D3.L),A2
	ADDI.B	#1,6(A4)
	ANDI.B	#$1F,6(A4)
	MOVEQ	#0,D0
	MOVE.B	6(A4),D0
	CMPI.B	#$10,D0
	BCC.L	lbC007C00
	MOVE.L	D0,D3
	EORI.B	#$FF,D3
	ANDI.W	#15,D3
	MOVEQ	#0,D7
	MOVE.B	1(A4),D7
	ADD.B	D7,D7
	SUBQ.W	#1,D7
lbC007BE8	MOVE.B	(A0)+,D1
	MOVE.B	(A2)+,D2
	EXT.W	D1
	EXT.W	D2
	MULU.W	D0,D1
	MULU.W	D3,D2
	ADD.W	D1,D2
	ASR.W	#4,D2
	MOVE.B	D2,(A3)+
	DBRA	D7,lbC007BE8
	RTS

lbC007C00	MOVEQ	#0,D7
	MOVE.B	1(A4),D7
	ADD.B	D7,D7
	SUBQ.W	#1,D7
	MOVEQ	#$1F,D3
	SUB.L	D0,D3
	MOVE.L	D3,D0
	EORI.B	#$FF,D3
	ANDI.W	#15,D3
lbC007C18	MOVE.B	(A0)+,D1
	MOVE.B	(A2)+,D2
	EXT.W	D1
	EXT.W	D2
	MULU.W	D0,D1
	MULU.W	D3,D2
	ADD.W	D1,D2
	ASR.W	#4,D2
	MOVE.B	D2,(A3)+
	DBRA	D7,lbC007C18
	RTS

lbC007C30	LEA	(A3),A2
	LEA	$80(A3),A3
	LEA	$40(A2),A2
	MOVEQ	#$3F,D7
lbC007C3C	MOVE.B	-(A2),-(A3)
	MOVE.B	(A2),-(A3)
	DBRA	D7,lbC007C3C
	RTS

lbC007C46	LEA	(A3),A2
	LEA	(A2),A0
	MOVEQ	#$3F,D7
lbC007C4C	MOVE.B	(A2)+,(A3)+
	ADDQ.W	#1,A2
	DBRA	D7,lbC007C4C
	LEA	(A0),A2
	MOVEQ	#$3F,D7
lbC007C58	MOVE.B	(A2)+,(A3)+
	DBRA	D7,lbC007C58
	RTS

lbC007C60	ADDI.B	#1,6(A4)
	ANDI.B	#$7F,6(A4)
	MOVEQ	#0,D1
	MOVE.B	6(A4),D1
	MOVEQ	#0,D3
	MOVEA.L	lbL008564(pc),A0
	MOVE.B	13(A4),D3
	ASL.W	#7,D3
	LEA	0(A0,D3.L),A0
	MOVEQ	#0,D0
	MOVE.B	1(A4),D0
	ADD.B	D0,D0
	SUBQ.W	#1,D0
	MOVE.B	0(A0,D1.L),D2
	MOVE.B	#3,D1
lbC007C96	ADD.B	D1,(A3)+
	ADD.B	D2,D1
	DBRA	D0,lbC007C96
	RTS

lbC007CA0	MOVEQ	#0,D3
	MOVEA.L	lbL008564(pc),A0
	MOVE.B	12(A4),D3
	ASL.W	#7,D3
	LEA	0(A0,D3.L),A0
	MOVEQ	#0,D3
	MOVEA.L	lbL008564(pc),A2
	MOVE.B	13(A4),D3
	ASL.W	#7,D3
	LEA	0(A2,D3.L),A2
	MOVEQ	#0,D2
	MOVE.B	6(A4),D2
	ADDI.B	#1,6(A4)
	ANDI.B	#$7F,6(A4)
	MOVEQ	#0,D7
	MOVE.B	1(A4),D7
	ADD.B	D7,D7
	SUBQ.W	#1,D7
lbC007CE0	MOVE.B	(A0)+,D0
	MOVE.B	0(A2,D2.L),D1
	EXT.W	D0
	EXT.W	D1
	ADD.W	D0,D1
	ASR.W	#1,D1
	MOVE.B	D1,(A3)+
	ADDI.B	#1,D2
	ANDI.B	#$7F,D2
	DBRA	D7,lbC007CE0
	RTS

lbC007CFE	MOVEQ	#0,D3
	MOVEA.L	lbL008564(pc),A0
	MOVE.B	13(A4),D3
	ASL.W	#7,D3
	LEA	0(A0,D3.L),A0
	MOVEQ	#0,D7
	MOVE.B	1(A4),D7
	ADD.B	D7,D7
	SUBQ.W	#1,D7
lbC007D1A	MOVE.B	(A0)+,D0
	MOVE.B	(A3),D1
	EXT.W	D0
	EXT.W	D1
	ADD.W	D0,D1
	MOVE.B	D1,(A3)+
	DBRA	D7,lbC007D1A
	RTS

lbC007D2C	MOVEQ	#0,D0
	MOVE.B	6(A4),D0
	NEG.B	0(A3,D0.L)
	ADDI.B	#1,6(A4)
	MOVE.B	1(A4),D0
	ADD.B	D0,D0
	CMP.B	6(A4),D0
	BHI.L	lbC007A7A
	CLR.B	6(A4)
	RTS

lbC007D50	MOVEQ	#0,D0
	MOVE.B	6(A4),D0
	NEG.B	0(A3,D0.L)
	MOVE.B	1(A4),D1
	ADD.B	13(A4),D0
	ADD.B	D1,D1
	SUBQ.W	#1,D1
	AND.B	D1,D0
	NEG.B	0(A3,D0.L)
	ADDI.B	#1,6(A4)
	MOVE.B	1(A4),D0
	ADD.B	D0,D0
	CMP.B	6(A4),D0
	BHI.L	lbC007A7A
	CLR.B	6(A4)
	RTS

lbC007D86	MOVEQ	#$7E,D7
	MOVE.B	(A3),D0
lbC007D8A	MOVE.B	1(A3),(A3)+
	DBRA	D7,lbC007D8A
	MOVE.B	D0,(A3)+
	RTS

lbC007D96	MOVEQ	#$7E,D7
	LEA	$80(A3),A3
	MOVE.B	-(A3),D0
lbC007D9E	MOVE.B	-(A3),1(A3)
	DBRA	D7,lbC007D9E
	MOVE.B	D0,(A3)
	RTS

lbC007DAA	LEA	(A3),A2
	BSR.L	lbC007DCC
	LEA	(A2),A3
	ADDI.B	#1,6(A4)
	MOVE.B	6(A4),D0
	CMP.B	13(A4),D0
	BNE.L	lbC007A7A
	CLR.B	6(A4)
	BRA.L	lbC007C46

lbC007DCC	MOVEQ	#$7E,D7
lbC007DCE	MOVE.B	(A3),D0
	EXT.W	D0
	MOVE.B	1(A3),D1
	EXT.W	D1
	ADD.W	D0,D1
	ASR.W	#1,D1
	MOVE.B	D1,(A3)+
	DBRA	D7,lbC007DCE
	RTS

lbC007DE4	LEA	$7E(A3),A2
	MOVEQ	#$7D,D7
	CLR.W	D2
lbC007DEC	MOVE.B	(A3)+,D0
	EXT.W	D0
	MOVE.W	D0,D1
	ADD.W	D0,D0
	ADD.W	D1,D0
	MOVE.B	1(A3),D1
	EXT.W	D1
	ADD.W	D0,D1
	ASR.W	#2,D1
	MOVE.B	D1,(A3)
	ADDQ.W	#1,D2
	DBRA	D7,lbC007DEC
	RTS

lbC007E0A	LEA	$7E(A3),A2
	MOVEQ	#$7D,D7
	CLR.W	D2
lbC007E12	MOVE.B	(A3)+,D0
	EXT.W	D0
	MOVE.B	1(A3),D1
	EXT.W	D1
	ADD.W	D0,D1
	ASR.W	#1,D1
	MOVE.B	D1,(A3)
	ADDQ.W	#1,D2
	DBRA	D7,lbC007E12
	RTS

lbC007E2A	SUBI.W	#$20,D1
	ASL.W	#5,D1
	MOVEA.L	lbL00856C(pc),A3
	LEA	0(A3,D1.L),A3
	MOVE.L	A3,$20(A5)
	MOVE.W	#1,$14(A5)
	MOVEA.L	lbL008570(pc),A2
	LEA	(A2),A0
	ADDA.L	(A3),A0
	MOVE.L	A0,(A6)

	move.l	D0,-(A7)
	move.l	A0,D0
	bsr.w	SetAdr
	move.l	(A7)+,D0

	MOVE.L	4(A3),D1
	SUB.L	(A3),D1
	ASR.L	#1,D1
	MOVE.W	D1,4(A6)

	bsr.w	SetLen

	MOVE.W	10(A1),$DFF096
	BRA.L	lbC00773E

lbC007E96	MOVEA.L	lbL008570(pc),A2
	LEA	lbL0083E4,A4
	LEA	lbL008400(pc),A5
	LEA	$DFF0A0,A6
	MOVEQ	#3,D5
lbC007EBC	TST.W	$14(A5)
	BEQ.L	lbC007EEA
	CLR.W	$14(A5)
	MOVEA.L	$20(A5),A3
	TST.L	8(A3)
	BEQ.L	lbC007EF8
	LEA	(A2),A1
	ADDA.L	8(A3),A1
	MOVE.L	A1,(A6)

	move.l	D0,-(A7)
	move.l	A1,D0
	bsr.w	SetAdr
	move.l	(A7)+,D0

	MOVE.L	4(A3),D1
	SUB.L	8(A3),D1
	ASR.L	#1,D1
	MOVE.W	D1,4(A6)

	bsr.w	SetLen

lbC007EEA	LEA	$30(A5),A5
	LEA	$10(A6),A6
	DBRA	D5,lbC007EBC
	RTS

lbC007EF8	MOVE.L	A4,(A6)
	MOVE.W	#4,4(A6)
	LEA	$30(A5),A5
	LEA	$10(A6),A6
	DBRA	D5,lbC007EBC
	RTS

lbW0083EC	dc.w	0
lbW0083EE	dc.w	0
lbW0083F0	dc.w	0
CurrentPos
lbW0083F2	dc.w	0
lbW0083F4	dc.w	0
	dc.w	0
lbW0083F8	dc.w	0
lbW0083FA	dc.w	5
lbW0083FC	dc.w	1
lbW0083FE	dc.w	$40
lbL008400	ds.b	192

lbL008554	dc.l	0
lbL008558	dc.l	0
lbL00855C	dc.l	0
lbL008560	dc.l	0
lbL008564	dc.l	0
lbL008568	dc.l	0
lbL00856C	dc.l	0
lbL008570	dc.l	0

	dc.l	$12D911CA
	dc.l	$10CB0FD9
	dc.l	$EF60E1F
	dc.w	$D54
lbL008982	dc.l	$C940BE0
	dc.l	$B350A94
	dc.l	$9FC096C
	dc.l	$8E50865
	dc.l	$7ED077B
	dc.l	$70F06AA
	dc.l	$64A05F0
	dc.l	$59A054A
	dc.l	$4FE04B6
	dc.l	$4730433
	dc.l	$3F603BD
	dc.l	$3880355
	dc.l	$32502F8
	dc.l	$2CD02A5
	dc.l	$27F025B
	dc.l	$2390219
	dc.l	$1FB01DF
	dc.l	$1C401AA
	dc.l	$193017C
	dc.l	$1670152
	dc.l	$13F012E
	dc.l	$11D010D
	dc.l	$FE00EF
	dc.l	$E200D5
	dc.l	$C900BE
	dc.l	$B300A9
	dc.l	$A00097
	dc.l	$8E0086
	dc.l	$7F12EA
	dc.l	$11DB10DA
	dc.l	$FE80F03
	dc.l	$E2C0D60
	dc.l	$CA00BEB
	dc.l	$B3F0A9E
	dc.l	$A050975
	dc.l	$8ED086D
	dc.l	$7F40782
	dc.l	$71606B0
	dc.l	$65005F5
	dc.l	$5A0054F
	dc.l	$50304BB
	dc.l	$4770437
	dc.l	$3FA03C1
	dc.l	$38B0358
	dc.l	$32802FB
	dc.l	$2D002A7
	dc.l	$281025D
	dc.l	$23B021B
	dc.l	$1FD01E0
	dc.l	$1C501AC
	dc.l	$194017D
	dc.l	$1680154
	dc.l	$141012F
	dc.l	$11E010E
	dc.l	$FE00F0
	dc.l	$E300D6
	dc.l	$CA00BF
	dc.l	$B400AA
	dc.l	$A00097
	dc.l	$8F0087
	dc.l	$7F12FC
	dc.l	$11EB10EA
	dc.l	$FF70F11
	dc.l	$E390D6D
	dc.l	$CAC0BF6
	dc.l	$B4A0AA8
	dc.l	$A0E097E
	dc.l	$8F60875
	dc.l	$7FB0789
	dc.l	$71C06B6
	dc.l	$65605FB
	dc.l	$5A50554
	dc.l	$50704BF
	dc.l	$47B043A
	dc.l	$3FE03C4
	dc.l	$38E035B
	dc.l	$32B02FD
	dc.l	$2D202AA
	dc.l	$284025F
	dc.l	$23D021D
	dc.l	$1FF01E2
	dc.l	$1C701AE
	dc.l	$195017F
	dc.l	$1690155
	dc.l	$1420130
	dc.l	$11F010F
	dc.l	$FF00F1
	dc.l	$E400D7
	dc.l	$CB00BF
	dc.l	$B500AA
	dc.l	$A10098
	dc.l	$8F0087
	dc.l	$80130E
	dc.l	$11FC10F9
	dc.l	$10060F1F
	dc.l	$E460D79
	dc.l	$CB70C01
	dc.l	$B540AB1
	dc.l	$A180987
	dc.l	$8FE087D
	dc.l	$8030790
	dc.l	$72306BC
	dc.l	$65C0600
	dc.l	$5AA0559
	dc.l	$50C04C3
	dc.l	$47F043E
	dc.l	$40103C8
	dc.l	$392035E
	dc.l	$32E0300
	dc.l	$2D502AC
	dc.l	$2860262
	dc.l	$23F021F
	dc.l	$20101E4
	dc.l	$1C901AF
	dc.l	$1970180
	dc.l	$16B0156
	dc.l	$1430131
	dc.l	$1200110
	dc.l	$10000F2
	dc.l	$E400D8
	dc.l	$CB00C0
	dc.l	$B500AB
	dc.l	$A10098
	dc.l	$900088
	dc.l	$80131F
	dc.l	$120C1109
	dc.l	$10140F2D
	dc.l	$E530D85
	dc.l	$CC30C0C
	dc.l	$B5F0ABB
	dc.l	$A210990
	dc.l	$9060885
	dc.l	$80A0797
	dc.l	$72A06C3
	dc.l	$6620606
	dc.l	$5AF055E
	dc.l	$51104C8
	dc.l	$4830442
	dc.l	$40503CB
	dc.l	$3950361
	dc.l	$3310303
	dc.l	$2D802AF
	dc.l	$2880264
	dc.l	$2420221
	dc.l	$20301E6
	dc.l	$1CA01B1
	dc.l	$1980181
	dc.l	$16C0157
	dc.l	$1440132
	dc.l	$1210111
	dc.l	$10100F3
	dc.l	$E500D8
	dc.l	$CC00C1
	dc.l	$B600AC
	dc.l	$A20099
	dc.l	$900088
	dc.l	$811331
	dc.l	$121D1119
	dc.l	$10230F3B
	dc.l	$E610D92
	dc.l	$CCF0C17
	dc.l	$B690AC5
	dc.l	$A2B0998
	dc.l	$90F088C
	dc.l	$812079E
	dc.l	$73006C9
	dc.l	$667060B
	dc.l	$5B50563
	dc.l	$51504CC
	dc.l	$4870446
	dc.l	$40903CF
	dc.l	$3980364
	dc.l	$3340306
	dc.l	$2DA02B1
	dc.l	$28B0266
	dc.l	$2440223
	dc.l	$20401E7
	dc.l	$1CC01B2
	dc.l	$19A0183
	dc.l	$16D0159
	dc.l	$1450133
	dc.l	$1220112
	dc.l	$10200F4
	dc.l	$E600D9
	dc.l	$CD00C1
	dc.l	$B700AC
	dc.l	$A3009A
	dc.l	$910089
	dc.l	$811343
	dc.l	$122E1129
	dc.l	$10320F49
	dc.l	$E6E0D9E
	dc.l	$CDB0C22
	dc.l	$B740ACF
	dc.l	$A3409A1
	dc.l	$9170894
	dc.l	$81907A5
	dc.l	$73706CF
	dc.l	$66D0611
	dc.l	$5BA0568
	dc.l	$51A04D1
	dc.l	$48B044A
	dc.l	$40D03D2
	dc.l	$39B0368
	dc.l	$3370309
	dc.l	$2DD02B4
	dc.l	$28D0268
	dc.l	$2460225
	dc.l	$20601E9
	dc.l	$1CE01B4
	dc.l	$19B0184
	dc.l	$16E015A
	dc.l	$1460134
	dc.l	$1230113
	dc.l	$10300F5
	dc.l	$E700DA
	dc.l	$CE00C2
	dc.l	$B700AD
	dc.l	$A3009A
	dc.l	$910089
	dc.l	$821354
	dc.l	$123F1139
	dc.l	$10410F58
	dc.l	$E7B0DAB
	dc.l	$CE70C2D
	dc.l	$B7E0AD9
	dc.l	$A3D09AA
	dc.l	$91F089C
	dc.l	$82107AC
	dc.l	$73E06D6
	dc.l	$6730617
	dc.l	$5BF056D
	dc.l	$51F04D5
	dc.l	$490044E
	dc.l	$41003D6
	dc.l	$39F036B
	dc.l	$33A030B
	dc.l	$2E002B6
	dc.l	$28F026B
	dc.l	$2480227
	dc.l	$20801EB
	dc.l	$1CF01B5
	dc.l	$19D0186
	dc.l	$170015B
	dc.l	$1480135
	dc.l	$1240114
	dc.l	$10400F5
	dc.l	$E800DB
	dc.l	$CE00C3
	dc.l	$B800AE
	dc.l	$A4009B
	dc.l	$92008A
	dc.l	$821366
	dc.l	$12501149
	dc.l	$10500F66
	dc.l	$E890DB8
	dc.l	$CF30C39
	dc.l	$B890AE3
	dc.l	$A4709B3
	dc.l	$92808A4
	dc.l	$82807B3
	dc.l	$74406DC
	dc.l	$679061C
	dc.l	$5C50572
	dc.l	$52304DA
	dc.l	$4940452
	dc.l	$41403D9
	dc.l	$3A2036E
	dc.l	$33D030E
	dc.l	$2E202B9
	dc.l	$292026D
	dc.l	$24A0229
	dc.l	$20A01ED
	dc.l	$1D101B7
	dc.l	$19E0187
	dc.l	$171015C
	dc.l	$1490136
	dc.l	$1250115
	dc.l	$10500F6
	dc.l	$E900DB
	dc.l	$CF00C4
	dc.l	$B900AE
	dc.l	$A4009B
	dc.l	$92008A
	dc.l	$831378
	dc.l	$12611159
	dc.l	$105F0F74
	dc.l	$E960DC4
	dc.l	$CFF0C44
	dc.l	$B940AED
	dc.l	$A5009BC
	dc.l	$93008AC
	dc.l	$83007BA
	dc.l	$74B06E2
	dc.l	$67F0622
	dc.l	$5CA0577
	dc.l	$52804DE
	dc.l	$4980456
	dc.l	$41803DD
	dc.l	$3A60371
	dc.l	$3400311
	dc.l	$2E502BB
	dc.l	$294026F
	dc.l	$24C022B
	dc.l	$20C01EF
	dc.l	$1D301B9
	dc.l	$1A00188
	dc.l	$172015E
	dc.l	$14A0138
	dc.l	$1260116
	dc.l	$10600F7
	dc.l	$E900DC
	dc.l	$D000C4
	dc.l	$B900AF
	dc.l	$A5009C
	dc.l	$93008B
	dc.l	$83138A
	dc.l	$12721169
	dc.l	$106E0F82
	dc.l	$EA40DD1
	dc.l	$D0B0C4F
	dc.l	$B9E0AF7
	dc.l	$A5A09C5
	dc.l	$93908B4
	dc.l	$83707C1
	dc.l	$75206E9
	dc.l	$6850628
	dc.l	$5CF057C
	dc.l	$52D04E3
	dc.l	$49C045A
	dc.l	$41C03E1
	dc.l	$3A90374
	dc.l	$3430314
	dc.l	$2E802BE
	dc.l	$2960271
	dc.l	$24E022D
	dc.l	$20E01F0
	dc.l	$1D401BA
	dc.l	$1A1018A
	dc.l	$174015F
	dc.l	$14B0139
	dc.l	$1270117
	dc.l	$10700F8
	dc.l	$EA00DD
	dc.l	$D100C5
	dc.l	$BA00AF
	dc.l	$A6009C
	dc.l	$94008B
	dc.l	$83139C
	dc.l	$12831179
	dc.l	$107E0F91
	dc.l	$EB10DDE
	dc.l	$D170C5B
	dc.l	$BA90B02
	dc.l	$A6309CE
	dc.l	$94108BC
	dc.l	$83F07C8
	dc.l	$75906EF
	dc.l	$68B062D
	dc.l	$5D50581
	dc.l	$53204E7
	dc.l	$4A1045E
	dc.l	$41F03E4
	dc.l	$3AC0377
	dc.l	$3460317
	dc.l	$2EA02C0
	dc.l	$2990274
	dc.l	$250022F
	dc.l	$21001F2
	dc.l	$1D601BC
	dc.l	$1A3018B
	dc.l	$1750160
	dc.l	$14C013A
	dc.l	$1280118
	dc.l	$10800F9
	dc.l	$EB00DE
	dc.l	$D100C6
	dc.l	$BB00B0
	dc.l	$A6009D
	dc.l	$94008C
	dc.l	$8413AF
	dc.l	$12941189
	dc.l	$108D0F9F
	dc.l	$EBF0DEB
	dc.l	$D230C66
	dc.l	$BB40B0C
	dc.l	$A6D09D7
	dc.l	$94A08C4
	dc.l	$84607D0
	dc.l	$75F06F5
	dc.l	$6910633
	dc.l	$5DA0586
	dc.l	$53704EC
	dc.l	$4A50462
	dc.l	$42303E8
	dc.l	$3B0037B
	dc.l	$349031A
	dc.l	$2ED02C3
	dc.l	$29B0276
	dc.l	$2520231
	dc.l	$21201F4
	dc.l	$1D801BD
	dc.l	$1A4018D
	dc.l	$1760161
	dc.l	$14E013B
	dc.l	$1290119
	dc.l	$10900FA
	dc.l	$EC00DF
	dc.l	$D200C6
	dc.l	$BB00B1
	dc.l	$A7009D
	dc.l	$95008C
	dc.l	$8413C1
	dc.l	$12A51199
	dc.l	$109C0FAE
	dc.l	$ECC0DF8
	dc.l	$D2F0C72
	dc.l	$BBF0B16
	dc.l	$A7709E0
	dc.l	$95308CD
	dc.l	$84E07D7
	dc.l	$76606FC
	dc.l	$6980639
	dc.l	$5DF058B
	dc.l	$53B04F0
	dc.l	$4A90466
	dc.l	$42703EB
	dc.l	$3B3037E
	dc.l	$34C031C
	dc.l	$2F002C6
	dc.l	$29E0278
	dc.l	$2550233
	dc.l	$21401F6
	dc.l	$1DA01BF
	dc.l	$1A6018E
	dc.l	$1780163
	dc.l	$14F013C
	dc.l	$12A011A
	dc.l	$10A00FB
	dc.l	$ED00DF
	dc.l	$D300C7
	dc.l	$BC00B1
	dc.l	$A7009E
	dc.l	$95008D
	dc.l	$8513D3
	dc.l	$12B611A9
	dc.l	$10AC0FBC
	dc.l	$EDA0E05
	dc.l	$D3B0C7D
	dc.l	$BCA0B20
	dc.l	$A8009EA
	dc.l	$95B08D5
	dc.l	$85607DE
	dc.l	$76D0702
	dc.l	$69E063F
	dc.l	$5E50590
	dc.l	$54004F5
	dc.l	$4AE046A
	dc.l	$42B03EF
	dc.l	$3B70381
	dc.l	$34F031F
	dc.l	$2F202C8
	dc.l	$2A0027A
	dc.l	$2570235
	dc.l	$21501F8
	dc.l	$1DB01C1
	dc.l	$1A70190
	dc.l	$1790164
	dc.l	$150013D
	dc.l	$12B011B
	dc.l	$10B00FC
	dc.l	$EE00E0
	dc.l	$D400C8
	dc.l	$BD00B2
	dc.l	$A8009F
	dc.l	$96008D
	dc.l	$8513E5
	dc.l	$12C811BA
	dc.l	$10BB0FCB
	dc.l	$EE80E12
	dc.l	$D470C89
	dc.l	$BD50B2B
	dc.l	$A8A09F3
	dc.l	$96408DD
	dc.l	$85E07E5
	dc.l	$7740709
	dc.l	$6A40644
	dc.l	$5EA0595
	dc.l	$54504F9
	dc.l	$4B2046E
	dc.l	$42F03F3
	dc.l	$3BA0384
	dc.l	$3520322
	dc.l	$2F502CB
	dc.l	$2A3027D
	dc.l	$2590237
	dc.l	$21701F9
	dc.l	$1DD01C2
	dc.l	$1A90191
	dc.l	$17B0165
	dc.l	$151013E
	dc.l	$12C011C
	dc.l	$10C00FD
	dc.l	$EE00E1
	dc.l	$D400C9
	dc.l	$BD00B3
	dc.l	$A9009F
	dc.l	$96008E
	dc.w	$86

	SECTION	Extra,BSS_C

lbL0083E4	ds.b	8

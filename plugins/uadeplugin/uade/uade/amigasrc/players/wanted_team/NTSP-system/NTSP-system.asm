	******************************************************
	****     NTSP-system replayer for EaglePlayer     ****
	****         all adaptions by Wanted Team	  ****
	****      DeliTracker compatible (?) version      ****
	******************************************************

	incdir	"dh2:include/"
	include 'misc/eagleplayer2.01.i'
	include 'hardware/intbits.i'
	include 'exec/exec_lib.i'

	SECTION	Player,CODE

	PLAYERHEADER Tags

	dc.b	'$VER: NTSP-system player module V1.0 (21 July 2008)',0
	even
Tags
	dc.l	DTP_PlayerVersion,1
	dc.l	EP_PlayerVersion,9
	dc.l	DTP_RequestDTVersion,DELIVERSION
	dc.l	DTP_PlayerName,PlayerName
	dc.l	DTP_Creator,Creator
	dc.l	EP_Check3,Check3
	dc.l	DTP_InitPlayer,InitPlayer
	dc.l	DTP_EndPlayer,EndPlayer
	dc.l	DTP_InitSound,InitSound
	dc.l	DTP_EndSound,EndSound
	dc.l	DTP_StartInt,StartInt
	dc.l	DTP_StopInt,StopInt
	dc.l	DTP_Volume,SetVolume
	dc.l	EP_Get_ModuleInfo,Get_ModuleInfo
	dc.l	EP_Flags,EPB_Save!EPB_LoadFast!EPB_Volume!EPB_ModuleInfo!EPB_Songend!EPB_Packable!EPB_Restart!EPB_CalcDuration
	dc.l	DTP_Flags,PLYF_ANYMEM!PLYF_SONGEND
	dc.l	DTP_Check2,Check3
	dc.l	DTP_Duration,CalcDuration
	dc.l	0

PlayerName
	dc.b	'NTSP-system',0
Creator
	dc.b	"SP/Contraz & Nightraver/Contraz,",10
	dc.b	'adapted by Wanted Team',0
Prefix
	dc.b	'TWO.',0
	even
Data
	dc.l	1800			; length of buffer
BuffyPtr
	dc.l	Buffy_1			; buffer 1
	dc.l	Buffy_2			; buffer 2
MusicPtr
	dc.l	0			; music ptr
Length
	dc.l	0			; music length (depacked)
MusicTmp
	dc.l	0			; temp ptr
LengthTmp
	dc.l	0			; temp length
EagleBase
	dc.l	0
Interrupts
	dc.l	0
Audio0
	dc.l	0

***************************************************************************
******************************* DTP_Duration ******************************
***************************************************************************

CalcDuration
	move.l	Interrupts(PC),D0
	mulu.w	#$E268,D0		; timer=(length * period)/5
	rts

***************************************************************************
***************************** EP_Get_ModuleInfo ***************************
***************************************************************************

Get_ModuleInfo
	lea	InfoBuffer(PC),A0
	rts

LoadSize	=	4
CalcSize	=	12
Duration	=	20

InfoBuffer
	dc.l	MI_LoadSize,0		;4
	dc.l	MI_Calcsize,0		;12
	dc.l	MI_Duration,0		;20
	dc.l	MI_Prefix,Prefix
	dc.l	0

***************************************************************************
******************************** EP_Check3 ********************************
***************************************************************************

Check3
	movea.l	dtg_ChkData(A5),A0
	moveq	#-1,D0
	cmp.l	#'SPNT',(A0)+
	bne.b	Fault
	tst.l	(A0)
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

	lea	EagleBase(PC),A6
	move.l	A5,(A6)+		; EagleBase
	lea	InfoBuffer(PC),A4
	move.l	D0,LoadSize(A4)
	addq.l	#4,A0
	move.l	(A0)+,D0
	lea	MusicPtr(PC),A1
	move.l	A0,(A1)+
	move.l	D0,(A1)

	move.l	D0,D1
	move.l	D0,D2
	move.l	D0,D4
	lsl.l	#7,D0			; * 128
	lsl.l	#5,D1			; * 32
	add.l	D1,D0			; * 160
	add.l	D2,D0			; * 161 (default period = 22.2kHz)
	lsr.l	#6,D0			; / 64
	move.l	#(3546895-15)/64,D1	; (PAL clock/64)
	divu.w	D1,D0
	addq.w	#1,D0
	move.w	D0,Duration+2(A4)
	move.l	D2,D0
	add.l	D0,D0			; * 2
	add.l	D0,D0			; * 4
	add.l	D2,D0			; * 5
	divu.w	#1800,D2
	move.l	D2,(A6)			; Interrupts

	moveq	#9,D1
	move.w	D1,D3
	move.w	D0,D2
	clr.w	D0
	swap	D0
	divu.w	D3,D0
	move.l	D0,D1
	swap	D0
	move.w	D2,D1
	divu.w	D3,D1
	move.w	D1,D0

	addq.l	#8,D0
	move.l	D0,CalcSize(A4)
	sub.l	D0,D4
	bmi.b	Short
	movea.l	dtg_AudioAlloc(A5),A0
	jmp	(A0)
Short
	moveq	#EPR_ModuleTooShort,D0
	rts

***************************************************************************
***************************** DTP_EndPlayer *******************************
***************************************************************************

EndPlayer
	move.l	dtg_AudioFree(A5),A0
	jmp	(A0)

***************************************************************************
***************************** DTP_InitSound *******************************
***************************************************************************

InitSound
	bsr.b	SetVolume
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
****************************** DTP_Volume *********************************
***************************************************************************

SetVolume
	move.w	dtg_SndVol(A5),D0
	lea	$DFF000,A0
	move.w	D0,$A8(A0)
	move.w	D0,$B8(A0)
	move.w	D0,$C8(A0)
	move.w	D0,$D8(A0)
	rts

***************************************************************************
***************************** DTP_StartInt ********************************
***************************************************************************

StartInt
	movem.l	D0/A6,-(A7)
	lea	InterruptStruct(PC),A1
	moveq	#INTB_AUD0,D0
	move.l	4.W,A6			; baza biblioteki exec do A6
	jsr	_LVOSetIntVector(A6)
	move.l	D0,Audio0
	movem.l	(A7)+,D0/A6
	move.w	#$8080,$DFF09A
	move.w	#$800F,$DFF096
	rts

InterruptStruct
	dc.l	0
	dc.l	0
	dc.b	NT_INTERRUPT
	dc.b	5			; priority
	dc.l	Name			; ID string
	dc.l	Data
	dc.l	Interrupt
Name
	dc.b	'NTSP-system Aud0 Interrupt',0,0
	even

***************************************************************************
***************************** DTP_StopInt *********************************
***************************************************************************

StopInt
	lea	$DFF000,A0
	move.w	#1,$96(A0)
	move.w	#$80,$9A(A0)
	move.w	#$80,$9C(A0)
	moveq	#INTB_AUD0,D0
	move.l	Audio0(PC),A1
	move.l	A6,-(A7)
	move.l	4.W,A6
	jsr	_LVOSetIntVector(a6)
	move.l	(A7)+,A6
	rts

***************************************************************************
***************************** DTP_Interrupt *******************************
***************************************************************************

Interrupt
	movem.l	D1-A6,-(SP)
	move.w	#$80,$9A(A0)
	move.w	#$80,$9C(A0)
	bsr.w	Play_1
	bsr.w	Play_2
	move.w	#$8080,$9A(A0)
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
****************************** NTSP-system player *************************
***************************************************************************

; NTSP-system player reworked & bugfixed by Wanted Team

Init
	lea	Data(PC),A1
	move.l	Length-Data(A1),LengthTmp-Data(A1)
	move.l	MusicPtr-Data(A1),MusicTmp-Data(A1)
	move.l	BuffyPtr-Data(A1),A0
	move.l	#1800,D1			; long !
	bsr.w	Decompress
	bsr.w	Play_2
	move.w	#900,D0
	move.w	D0,$A4(A0)
	move.w	D0,$B4(A0)
	move.w	D0,$C4(A0)
	move.w	D0,$D4(A0)
	move.w	#$A1,D0
	move.w	D0,$A6(A0)
	move.w	D0,$B6(A0)
	move.w	D0,$C6(A0)
	move.w	D0,$D6(A0)
	rts

Play_2
	lea	BuffyPtr(PC),A0
	movem.l	(A0),D0/D1
	exg	D0,D1
	movem.l	D0/D1,(A0)
	lea	$DFF000,A0
	move.l	D1,$A0(A0)
	move.l	D1,$B0(A0)
	move.l	D1,$C0(A0)
	move.l	D1,$D0(A0)
	rts

Play_1
	move.l	BuffyPtr-Data(A1),A0
	move.l	(A1),D0
DepackCheck
	tst.l	D0
	beq.b	Done
	move.l	LengthTmp-Data(A1),D1
	beq.b	EndOfFile
	cmp.l	D0,D1
	bls.b	Shorty
	move.l	D0,D1
Shorty
	movem.l	D0/D1/A0/A1,-(SP)
	bsr.b	Decompress
	movem.l	(SP)+,D0/D1/A0/A1
	add.l	D1,A0
	sub.l	D1,D0
	bra.b	DepackCheck

EndOfFile
	subq.w	#1,D0
Clear
	clr.b	(A0)+
	dbf	D0,Clear
	move.l	MusicPtr-Data(A1),MusicTmp-Data(A1)
	move.l	Length-Data(A1),LengthTmp-Data(A1)
	bsr.w	SongEnd
Done
	rts

Decompress
	move.l	A1,A6
	move.l	A0,A1
	move.l	MusicTmp-Data(A6),A0
	sub.l	D1,LengthTmp-Data(A6)
	divu.w	#9,D1			; 9 bytes / loop
	move.w	D1,D5
	beq.b	skip			; check, if length was from 1 to 8
	subq.w	#1,D5			; dbf
	moveq	#15,D7
	moveq	#0,D6
loop
	move.b	(A0)+,D6
	move.l	D6,D0
	lsr.b	#5,D6
	move.l	D6,D4			; bug, was move.b only
	subq.b	#1,D4
	bpl.b	Plus
	moveq	#0,D4
Plus
	lsl.b	#3,D0
	asr.b	#3,D0
	lsl.b	D4,D0
	move.b	D0,(A1)+
	move.b	(A0)+,D0
	move.l	D0,D1
	asr.b	#4,D0
	and.w	D7,D1
	lsl.w	D6,D0
	move.b	D0,(A1)+
	lsl.b	#4,D1
	asr.b	#4,D1
	lsl.w	D6,D1
	move.b	D1,(A1)+
	move.b	(A0)+,D1
	move.l	D1,D0
	asr.b	#4,D1
	and.w	D7,D0
	lsl.w	D6,D1
	move.b	D1,(A1)+
	lsl.b	#4,D0
	asr.b	#4,D0
	lsl.w	D6,D0
	move.b	D0,(A1)+
	move.b	(A0)+,D0
	move.l	D0,D1
	asr.b	#4,D0
	and.w	D7,D1
	lsl.w	D6,D0
	move.b	D0,(A1)+
	lsl.b	#4,D1
	asr.b	#4,D1
	lsl.w	D6,D1
	move.b	D1,(A1)+
	move.b	(A0)+,D1
	move.l	D1,D0
	asr.b	#4,D1
	and.w	D7,D0
	lsl.w	D6,D1
	move.b	D1,(A1)+
	lsl.b	#4,D0
	asr.b	#4,D0
	lsl.w	D6,D0
	move.b	D0,(A1)+
	dbf	D5,loop
	move.l	A0,MusicTmp-Data(A6)
skip
	rts

	Section	Buffy,BSS_C
Buffy_1
	ds.b	1800
Buffy_2
	ds.b	1800

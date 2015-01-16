	*****************************************************
	****     Cinemaware replayer for EaglePlayer,    ****
	****	     all adaptions by Wanted Team	 ****
	****     DeliTracker 2.32 compatible version	 ****
	*****************************************************

	incdir	"dh2:include/"
	include 'misc/eagleplayer2.01.i'

	SECTION Player,Code

	PLAYERHEADER Tags

	dc.b	'$VER: Cinemaware player module V1.0 (24 Apr 2004)',0
	even
Tags
	dc.l	DTP_PlayerVersion,1
	dc.l	EP_PlayerVersion,9
	dc.l	DTP_RequestDTVersion,'WT'
	dc.l	DTP_PlayerName,PlayerName
	dc.l	DTP_Creator,Creator
	dc.l	DTP_Check2,Check2
	dc.l	DTP_Interrupt,Interrupt
	dc.l	DTP_InitPlayer,InitPlayer
	dc.l	DTP_EndPlayer,EndPlayer
	dc.l	DTP_InitSound,InitSound
	dc.l	DTP_EndSound,EndSound
	dc.l	EP_NewModuleInfo,NewModuleInfo
	dc.l	DTP_ExtLoad,ExtLoad
	dc.l	DTP_Volume,SetVolume
	dc.l	DTP_Balance,SetBalance
	dc.l	EP_Voices,SetVoices
	dc.l	EP_StructInit,StructInit
	dc.l	EP_GetPositionNr,GetPosition
	dc.l	EP_SampleInit,SampleInit
	dc.l	EP_Flags,EPB_Volume!EPB_Balance!EPB_ModuleInfo!EPB_Voices!EPB_SampleInfo!EPB_Songend!EPB_Analyzer!EPB_Packable!EPB_Restart!EPB_LoadFast
	dc.l	TAG_DONE
PlayerName
	dc.b	'Cinemaware',0
Creator
	dc.b	"(c) 1990 by Cinemaware,",10
	dc.b	'adapted by Wanted Team',0
Prefix
	dc.b	'CIN.',0
SamplesPath
	dc.b	'Instruments/',0
	even
ModulePtr
	dc.l	0
EagleBase
	dc.l	0
ASEQPtr
	dc.l	0
Timer
	dc.w	0
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

	lea	OldVoice1(PC),A2
	moveq	#3,D1
	lea	$DFF0A8,A0
SetNew
	move.w	(A2)+,D0
	bsr.b	ChangeVolume
	lea	16(A0),A0
	dbf	D1,SetNew
	rts

ChangeVolume
	move.l	A4,-(SP)
	lea	StructAdr(PC),A4
	and.w	#$7F,D0
	cmpa.l	#$DFF0A8,A0			;Left Volume
	bne.b	NoVoice1
	move.w	D0,OldVoice1
	tst.w	Voice1
	bne.b	Voice1On
	moveq	#0,D0
Voice1On
	mulu.w	LeftVolume(PC),D0
	lsr.w	#6,D0
	move.w	D0,(A0)
	move.w	D0,UPS_Voice1Vol(A4)
	bra.b	SetIt
NoVoice1
	cmpa.l	#$DFF0B8,A0			;Right Volume
	bne.b	NoVoice2
	move.w	D0,OldVoice2
	tst.w	Voice2
	bne.b	Voice2On
	moveq	#0,D0
Voice2On
	mulu.w	RightVolume(PC),D0
	lsr.w	#6,D0
	move.w	D0,(A0)
	move.w	D0,UPS_Voice2Vol(A4)
	bra.b	SetIt
NoVoice2
	cmpa.l	#$DFF0C8,A0			;Right Volume
	bne.b	NoVoice3
	move.w	D0,OldVoice3
	tst.w	Voice3
	bne.b	Voice3On
	moveq	#0,D0
Voice3On
	mulu.w	RightVolume(PC),D0
	lsr.w	#6,D0
	move.w	D0,(A0)
	move.w	D0,UPS_Voice3Vol(A4)
	bra.b	SetIt
NoVoice3
	cmpa.l	#$DFF0D8,A0			;Left Volume
	bne.b	SetIt
	move.w	D0,OldVoice4
	tst.w	Voice4
	bne.b	Voice4On
	moveq	#0,D0
Voice4On
	mulu.w	LeftVolume(PC),D0
	lsr.w	#6,D0
	move.w	D0,(A0)
	move.w	D0,UPS_Voice4Vol(A4)
SetIt
	move.l	(SP)+,A4
	rts

*------------------------------- Set Adr -------------------------------*

SetAdr
	move.l	A1,-(SP)
	lea	StructAdr+UPS_Voice1Adr(PC),A1
	cmp.l	#$DFF0A0,A0
	beq.b	.SetVoice
	lea	StructAdr+UPS_Voice2Adr(PC),A1
	cmp.l	#$DFF0B0,A0
	beq.b	.SetVoice
	lea	StructAdr+UPS_Voice3Adr(PC),A1
	cmp.l	#$DFF0C0,A0
	beq.b	.SetVoice
	lea	StructAdr+UPS_Voice4Adr(PC),A1
.SetVoice
	move.l	D0,(A1)
	move.l	(SP)+,A1
	rts

*------------------------------- Set Len -------------------------------*

SetLen
	move.l	A1,-(SP)
	lea	StructAdr+UPS_Voice1Len(PC),A1
	cmp.l	#$DFF0A0,A0
	beq.b	.SetVoice
	lea	StructAdr+UPS_Voice2Len(PC),A1
	cmp.l	#$DFF0B0,A0
	beq.b	.SetVoice
	lea	StructAdr+UPS_Voice3Len(PC),A1
	cmp.l	#$DFF0C0,A0
	beq.b	.SetVoice
	lea	StructAdr+UPS_Voice4Len(PC),A1
.SetVoice
	move.w	D0,(A1)
	move.l	(SP)+,A1
	rts

*------------------------------- Set Per -------------------------------*

SetPer
	move.l	A1,-(SP)
	lea	StructAdr+UPS_Voice1Per(PC),A1
	cmp.l	#$DFF0A6,A0
	beq.b	.SetVoice
	lea	StructAdr+UPS_Voice2Per(PC),A1
	cmp.l	#$DFF0B6,A0
	beq.b	.SetVoice
	lea	StructAdr+UPS_Voice3Per(PC),A1
	cmp.l	#$DFF0C6,A0
	beq.b	.SetVoice
	lea	StructAdr+UPS_Voice4Per(PC),A1
.SetVoice
	move.w	D0,(A1)
	move.l	(SP)+,A1
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
******************************* EP_StructInit *****************************
***************************************************************************

StructInit
	lea	StructAdr(PC),A0
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
	moveq	#0,D5
	move.b	4(A2),D5
	lea	66(A2),A2
	subq.l	#1,D5
hop
	move.l	A2,A4
	moveq	#2,D3
NextWave1
	jsr	ENPP_AllocSampleStruct(A5)
	move.l	D0,(A3)
	beq.b	return
	move.l	D0,A3

	move.l	A4,EPS_SampleName(A3)		; sample name
	move.w	#6,EPS_MaxNameLen(A3)
	move.l	6(A4),D0
	beq.b	NoWave1
	move.l	D0,EPS_Adr(A3)			; sample address
	move.l	22(A4),EPS_Length(A3)		; sample length
	move.l	#64,EPS_Volume(A3)
	move.w	#USITY_RAW,EPS_Type(A3)
	move.w	#USIB_Playable!USIB_Saveable!USIB_8BIT,EPS_Flags(A3)
NoWave1
	lea	26(A4),A4
	dbf	D3,NextWave1
	lea	138(A2),A2
	dbf	D5,hop

	moveq	#0,D7
return
	move.l	D7,D0
	rts

***************************************************************************
********************************* EP_GetPosNr *****************************
***************************************************************************

GetPosition
	move.l	lbL00EC90,D1
	sub.l	lbL00EC94,D1
	divu.w	#100,D1
	moveq	#0,D0
	move.w	D1,D0
	rts

***************************************************************************
******************************* DTP_ExtLoad *******************************
***************************************************************************

ExtLoad
	move.l	dtg_ChkData(A5),A0
	moveq	#0,D2
	move.b	4(A0),D2
	subq.l	#1,D2
	lea	66(A0),A2
LoadNextSample
	move.l	A2,A4
	moveq	#2,D3
NextWave
	tst.l	6(A4)
	beq.b	NoWave
	bsr.b	LoadFile
	tst.l	D0
	bne.b	ExtError2
NoWave
	lea	26(A4),A4
	dbf	D3,NextWave
	lea	138(A2),A2
	dbf	D2,LoadNextSample
ExtError2
	rts

LoadFile
	move.l	dtg_PathArrayPtr(A5),A0
	clr.b	(A0)
	move.l	dtg_CopyDir(A5),A0
	jsr	(A0)
	bsr.b	CopyName
	move.l	dtg_LoadFile(A5),A0
	jmp	(A0)

CopyName
	move.l	dtg_PathArrayPtr(A5),A0
loop1
	tst.b	(A0)+
	bne.s	loop1
	subq.l	#1,A0
	lea	SamplesPath(PC),A3
smp1
	move.b	(A3)+,(A0)+
	bne.s	smp1
	subq.l	#1,A0
	move.l	A4,A3
smp2
	move.b	(A3)+,(A0)+
	bne.s	smp2
CheckName
	cmp.b	#$20,-2(A0)
	bne.b	NameOK
	subq.l	#1,A0
	clr.b	-1(A0)
	bra.b	CheckName
NameOK
	rts

***************************************************************************
******************************** DTP_Check2 *******************************
***************************************************************************

Check2
	move.l	dtg_ChkData(A5),A0
	moveq	#-1,D0

	move.l	A0,A1
	cmp.l	#'IBLK',(A1)+
	bne.b	fault
	move.l	dtg_ChkSize(A5),D1
	moveq	#0,D2
	move.b	(A1),D2
	beq.b	fault
	cmp.b	#$80,D2
	bhi.b	fault
	mulu.w	#138,D2
	lea	(A0,D1.L),A0
	add.l	D2,A1
	lea	18(A1),A1
	lea	256(A1),A2
	cmp.l	A1,A2
	ble.b	fault
FindAseq
	cmp.l	#'ASEQ',(A1)
	beq.b	found
	addq.l	#2,A1
	cmp.l	A1,A2
	bne.b	FindAseq
fault
	rts
found
	moveq	#0,D0
	rts

***************************************************************************
****************************** EP_NewModuleInfo ***************************
***************************************************************************

NewModuleInfo

CalcSize	=	4
LoadSize	=	12
Samples		=	20
Length		=	28
SamplesSize	=	36
SongSize	=	44

InfoBuffer
	dc.l	MI_Calcsize,0		;4
	dc.l	MI_LoadSize,0		;12
	dc.l	MI_Samples,0		;20
	dc.l	MI_Length,0		;28
	dc.l	MI_SamplesSize,0	;36
	dc.l	MI_Songsize,0		;44
	dc.l	MI_MaxSamples,128*3
	dc.l	MI_Prefix,Prefix
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
	move.l	A5,(A3)+			; EagleBase

	lea	InfoBuffer(PC),A6
	move.l	D0,LoadSize(A6)

	lea	(A0,D0.L),A1
	clr.l	SamplesSize(A6)
	clr.l	CalcSize(A6)

	moveq	#1,D6
	lea	WT,A4
	bsr.w	InstallSamples
	tst.l	D0
	beq.b	Corrupt
	move.l	lbL00ECA6-WT(A4),A0
FindAss
	cmp.l	#'ASEQ',(A0)
	beq.b	AssOK
	addq.l	#2,A0
	bra.b	FindAss
AssOK
	addq.l	#4,A0
	move.l	A0,(A3)				; ASEQ Ptr
NextRow
	addq.l	#5,A0
	cmp.l	A0,A1
	blt.b	Short
	tst.b	-1(A0)
	bne.b	NextRow
	cmp.b	#$2F,-2(A0)
	bne.b	NextRow
	cmp.b	#$10,-3(A0)
	bne.b	NextRow
	move.l	A0,D0
	sub.l	(A3),D0
	divu.w	#100,D0
	move.w	D0,Length+2(A6)
	move.l	A0,D0
	sub.l	ModulePtr(PC),D0
	move.l	D0,SongSize(A6)
	add.l	D0,CalcSize(A6)

	subq.l	#1,D6
	move.l	D6,Samples(A6)

	move.l	dtg_AudioAlloc(A5),A0
	jmp	(A0)

Corrupt
	moveq	#EPR_CorruptModule,D0
	rts
Short
	moveq	#EPR_ModuleTooShort,D0
	rts

InstallBody
	moveq	#8,D3
	move.l	D6,D0				; file number
	move.l	EagleBase(PC),A5
	move.l	dtg_GetListData(A5),A0
	jsr	(A0)
	cmp.l	#'FORM',(A0)+
	bne.b	Err
	add.l	(A0)+,D3
	addq.l	#1,D6
	add.l	D0,LoadSize(A6)
	add.l	D3,SamplesSize(A6)
	add.l	D3,CalcSize(A6)
FindBody
	cmp.l	#'BODY',(A0)
	beq.b	BodyOK
	addq.l	#2,A0
	bra.b	FindBody
BodyOK
	addq.l	#8,A0
	move.l	A0,D0
	rts

Err
	moveq	#-1,D0
	rts

***************************************************************************
***************************** DTP_EndPlayer *******************************
***************************************************************************

EndPlayer
	move.l	dtg_AudioFree(A5),A0
	jmp	(A0)

***************************************************************************
***************************** DTP_Intterrupt ******************************
***************************************************************************

Interrupt
	movem.l	D1-A6,-(SP)

	lea	StructAdr(PC),A0
	st	UPS_Enabled(A0)
	move.w	#UPSB_Adr!UPSB_Len!UPSB_Per!UPSB_Vol,UPS_Flags(A0)
	clr.w	UPS_Voice1Per(A0)
	clr.w	UPS_Voice2Per(A0)
	clr.w	UPS_Voice3Per(A0)
	clr.w	UPS_Voice4Per(A0)

	lea	WT,A4
	bsr.w	Play

	lea	StructAdr(PC),A0
	clr.w	UPS_Enabled(A0)

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
	move.w	Timer(PC),D0
	bne.b	Done
	move.w	dtg_Timer(A5),D0
	mulu.w	#5,D0
	divu.w	#6,D0			; 60Hz
	move.w	D0,Timer
Done	move.w	D0,dtg_Timer(A5)
	lea	WT,A4
	lea	lbW00B9BE-WT(A4),A0
	move.w	#1,(A0)+
	clr.w	(A0)+
	move.w	#-1,(A0)
	move.l	ASEQPtr(PC),-(SP)
	bsr.w	Init
	addq.l	#4,SP
	rts

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
***************************** Cinemaware player ***************************
***************************************************************************

; Player from game Wings (c) Cinemaware

;lbC004406	LINK.W	A5,#0
;	MOVEM.L	D1-D7/A0-A6,-(SP)
;	JSR	lbC008E86(PC)
;	PEA	1
;	MOVE.L	lbL00EC7E-WT(A4),-(SP)
;	JSR	lbC00A116(PC)			; SetICR
;	ADDQ.W	#8,SP
;	MOVE.L	lbL00EC7A-WT(A4),-(SP)
;	JSR	lbC00A212(PC)			; Cause
;	ADDQ.W	#4,SP
;	JSR	lbC008E94(PC)
;	MOVEM.L	(SP)+,D1-D7/A0-A6
;	MOVEQ	#0,D0
;	UNLK	A5
;	RTS

Play
lbC004438	LINK.W	A5,#-$12
;	MOVEM.L	D4/D5/A2/A3,-(SP)
;	MOVEM.L	D1-D7/A0-A6,-(SP)
;	JSR	lbC008E86(PC)
	ADDQ.W	#1,lbW00B9C2-WT(A4)
	TST.W	lbW00B9C2-WT(A4)
	BNE.L	lbC0048C6
	TST.W	lbW00ECB0-WT(A4)
	BEQ.S	lbC00446A
	MOVE.W	#15,$DFF096				; DMA
	SUBQ.W	#1,lbW00ECB0-WT(A4)
	BRA.L	lbC0048C6

lbC00446A	TST.L	lbL00EC90-WT(A4)
	BEQ.S	lbC0044E0
lbC004470	TST.W	lbW00EC98-WT(A4)
	BGT.S	lbC0044C8
	MOVEA.L	lbL00EC90-WT(A4),A0
	MOVEQ	#0,D0
	MOVE.B	4(A0),D0
	MOVE.W	D0,-(SP)
	MOVEA.L	lbL00EC90-WT(A4),A0
	MOVEQ	#0,D0
	MOVE.B	3(A0),D0
	MOVE.W	D0,-(SP)
	MOVEA.L	lbL00EC90-WT(A4),A0
	MOVEQ	#0,D0
	MOVE.B	2(A0),D0
	MOVE.W	D0,-(SP)
	JSR	lbC00511A(PC)
	ADDQ.W	#6,SP
	TST.W	lbW00ECB0-WT(A4)
	BNE.L	lbC0048C6
	ADDQ.L	#5,lbL00EC90-WT(A4)
	MOVEA.L	lbL00EC90-WT(A4),A0
	MOVEQ	#0,D0
	MOVE.B	(A0),D0
	ASL.W	#8,D0
	MOVEA.L	lbL00EC90-WT(A4),A0
	MOVEQ	#0,D1
	MOVE.B	1(A0),D1
	OR.W	D1,D0
	MOVE.W	D0,lbW00EC98-WT(A4)
	BRA.S	lbC004470

lbC0044C8	SUBQ.W	#1,lbW00EC98-WT(A4)
	TST.W	lbW00EC98-WT(A4)
	BGE.S	lbC0044E0
	MOVE.W	#1,lbW00EC98-WT(A4)
	JSR	lbC0050AE(PC)
	BRA.L	lbC0048C6

lbC0044E0	TST.W	lbW00B9C0-WT(A4)
	BEQ.S	lbC004508
	ADDQ.W	#1,lbW00ECAC-WT(A4)
	MOVE.W	lbW00ECAC-WT(A4),D0
	CMP.W	lbW00ECAA-WT(A4),D0
	BLE.S	lbC004508
	CLR.W	lbW00B9C0-WT(A4)
	ADDQ.W	#1,lbW00ECAE-WT(A4)
	CMPI.W	#$3E,lbW00ECAE-WT(A4)
	BLE.S	lbC004508
	JSR	lbC00503E(PC)
lbC004508	MOVEQ	#0,D4
lbC00450A	MOVE.W	D4,D0
	MULS.W	#$1A,D0
	LEA	lbL00EC0E-WT(A4),A0
	MOVEA.L	D0,A3
	ADDA.L	A0,A3
	MOVE.B	(A3),D0
	EXT.W	D0
	MOVE.W	D0,D5
	TST.W	D0
	BLT.L	lbC0048BC
	TST.B	12(A3)
	BEQ.S	lbC00452E
	SUBQ.B	#1,12(A3)
lbC00452E	MOVE.B	13(A3),D0
	EXT.W	D0
	AND.W	#2,D0
	MOVE.W	D0,-14(A5)
	MOVE.B	2(A3),D0
	EXT.W	D0
	EXT.L	D0
	ASL.L	#2,D0
	LEA	lbL00ECB2-WT(A4),A0
	MOVEA.L	0(A0,D0.L),A2
	MOVE.B	11(A3),D0
	EXT.W	D0
	EXT.L	D0
	MOVEA.L	D0,A0
	ADDA.L	A2,A0
	MOVEQ	#0,D0
	MOVE.B	$34(A0),D0
	MOVE.W	D0,-2(A5)
	TST.W	-14(A5)
	BNE.S	lbC004576
	TST.W	-2(A5)
	BNE.S	lbC004576
	MOVE.W	#1,-2(A5)
lbC004576	MOVE.B	11(A3),D0
	EXT.W	D0
	EXT.L	D0
	MOVEA.L	D0,A0
	ADDA.L	A2,A0
	MOVEQ	#0,D0
	MOVE.B	$2C(A0),D0
	MOVE.W	D0,-4(A5)
	MOVE.W	8(A3),-6(A5)
	MOVE.W	-4(A5),D0
	CMP.W	-6(A5),D0
	BLE.S	lbC0045BA
	MOVE.W	-2(A5),D0
	ADD.W	D0,-6(A5)
	MOVE.W	-4(A5),D0
	CMP.W	-6(A5),D0
	BGT.S	lbC0045B8
	MOVE.W	-4(A5),-6(A5)
	ADDQ.B	#1,11(A3)
lbC0045B8	BRA.S	lbC0045E8

lbC0045BA	MOVE.W	-2(A5),D0
	SUB.W	D0,-6(A5)
	MOVE.W	-4(A5),D0
	CMP.W	-6(A5),D0
	BLT.S	lbC0045D6
	MOVE.W	-4(A5),-6(A5)
	ADDQ.B	#1,11(A3)
lbC0045D6	CMPI.W	#1,-6(A5)
	BGE.S	lbC0045E8
	MOVE.B	#$FF,(A3)
	ANDI.B	#1,13(A3)
lbC0045E8	MOVE.W	-6(A5),8(A3)
	TST.W	-14(A5)
	BEQ.S	lbC004602
	MOVE.B	11(A3),D0
	CMP.B	$2B(A2),D0
	BLE.S	lbC004602
	CLR.B	11(A3)
lbC004602	CMPI.B	#7,11(A3)
	BLE.S	lbC004612
	CLR.W	8(A3)
	MOVE.B	#$FF,(A3)
lbC004612	CMPI.B	#8,10(A3)
	BGE.L	lbC0046DA
	MOVE.B	10(A3),D0
	EXT.W	D0
	EXT.L	D0
	MOVEA.L	D0,A0
	ADDA.L	A2,A0
	MOVEQ	#0,D0
	MOVE.B	$1A(A0),D0
	CMP.W	6(A3),D0
	BLS.S	lbC00467E
	MOVE.B	10(A3),D0
	EXT.W	D0
	EXT.L	D0
	MOVEA.L	D0,A0
	ADDA.L	A2,A0
	MOVEQ	#0,D0
	MOVE.B	$22(A0),D0
	ADD.W	D0,6(A3)
	MOVE.B	10(A3),D0
	EXT.W	D0
	EXT.L	D0
	MOVEA.L	D0,A0
	ADDA.L	A2,A0
	MOVEQ	#0,D0
	MOVE.B	$1A(A0),D0
	CMP.W	6(A3),D0
	BHI.S	lbC00467C
	MOVE.B	10(A3),D0
	EXT.W	D0
	EXT.L	D0
	MOVEA.L	D0,A0
	ADDA.L	A2,A0
	MOVEQ	#0,D0
	MOVE.B	$1A(A0),D0
	MOVE.W	D0,6(A3)
	ADDQ.B	#1,10(A3)
lbC00467C	BRA.S	lbC0046C6

lbC00467E	MOVE.B	10(A3),D0
	EXT.W	D0
	EXT.L	D0
	MOVEA.L	D0,A0
	ADDA.L	A2,A0
	MOVEQ	#0,D0
	MOVE.B	$22(A0),D0
	SUB.W	D0,6(A3)
	MOVE.B	10(A3),D0
	EXT.W	D0
	EXT.L	D0
	MOVEA.L	D0,A0
	ADDA.L	A2,A0
	MOVEQ	#0,D0
	MOVE.B	$1A(A0),D0
	CMP.W	6(A3),D0
	BCS.S	lbC0046C6
	MOVE.B	10(A3),D0
	EXT.W	D0
	EXT.L	D0
	MOVEA.L	D0,A0
	ADDA.L	A2,A0
	MOVEQ	#0,D0
	MOVE.B	$1A(A0),D0
	MOVE.W	D0,6(A3)
	ADDQ.B	#1,10(A3)
lbC0046C6	TST.W	-14(A5)
	BEQ.S	lbC0046DA
	MOVE.B	10(A3),D0
	CMP.B	$19(A2),D0
	BLE.S	lbC0046DA
	CLR.B	10(A3)
lbC0046DA	MOVE.W	$16(A3),D0
	ADD.W	D0,$14(A3)
	TST.W	$14(A3)
	BGE.S	lbC0046F6
	CLR.W	$14(A3)
	MOVEQ	#0,D0
	MOVE.B	$16(A2),D0
	MOVE.W	D0,$16(A3)
lbC0046F6	MOVEQ	#0,D0
	MOVE.B	$15(A2),D0
	MOVE.W	$14(A3),D1
	CMP.W	D0,D1
	BLS.S	lbC00471A
	MOVEQ	#0,D0
	MOVE.B	$15(A2),D0
	MOVE.W	D0,$14(A3)
	MOVEQ	#0,D0
	MOVE.B	$16(A2),D0
	NEG.W	D0
	MOVE.W	D0,$16(A3)
lbC00471A	MOVE.B	2(A3),D0
	EXT.W	D0
	EXT.L	D0
	ASL.L	#2,D0
	LEA	lbL00ECB2-WT(A4),A0
	MOVEA.L	0(A0,D0.L),A1
	MOVEQ	#0,D0
	MOVE.B	$17(A1),D0
	CMP.W	#$FF,D0
	BNE.S	lbC00474C
	MOVE.B	$12(A2),D0
	EXT.W	D0
	ADD.W	#$3C,D0
	MULS.W	#$14,D0
	MOVE.W	D0,-10(A5)
	BRA.S	lbC004762

lbC00474C	MOVE.B	1(A3),D0
	EXT.W	D0
	MOVE.B	$12(A2),D1
	EXT.W	D1
	ADD.W	D1,D0
	MULS.W	#$14,D0
	MOVE.W	D0,-10(A5)
lbC004762	MOVE.W	$14(A3),D0
	EXT.L	D0
	DIVS.W	#5,D0
	ADD.W	D0,-10(A5)
	MOVE.W	6(A3),D0
	SUB.W	#$80,D0
	ASL.W	#2,D0
	ADD.W	D0,-10(A5)
	MOVE.W	D5,D0
	MULS.W	#6,D0
	LEA	lbB00EBAF-WT(A4),A0
	MOVEQ	#0,D1
	MOVE.B	0(A0,D0.L),D1
	SUB.W	#$40,D1
	MOVEQ	#0,D0
	MOVE.B	$17(A2),D0
	MULU.W	D0,D1
	MULU.W	#$14,D1
	ASR.W	#6,D1
	ADD.W	D1,-10(A5)
	MOVE.W	-10(A5),D0
	EXT.L	D0
	DIVS.W	#$F0,D0
	SWAP	D0
	EXT.L	D0
	ASL.L	#1,D0
;	LEA	lbW00B7DE-WT(A4),A0

	lea	lbW00B7DE(PC),A0

	MOVEQ	#0,D1
	MOVE.W	0(A0,D0.L),D1
	MOVE.W	-10(A5),D0
	EXT.L	D0
	DIVS.W	#$F0,D0
	EXT.L	D0
	ASL.L	D0,D1
	MOVE.L	D1,-$12(A5)
	TST.L	-$12(A5)
	BNE.S	lbC0047DE
	MOVE.L	#1,-$12(A5)
lbC0047DE	MOVEQ	#0,D0
	MOVE.W	4(A3),D0
	MOVEQ	#$14,D1
	ASL.L	D1,D0
	MOVE.L	-$12(A5),D1
	JSR	lbC009A4A(PC)
	MOVE.W	D4,D1
	EXT.L	D1
	ASL.L	#4,D1
	MOVEA.L	D1,A0
	ADDA.L	#$DFF0A6,A0
	MOVE.W	D0,(A0)					; period

	bsr.w	SetPer

	TST.W	$18(A3)
	BEQ.S	lbC004834
	SUBQ.W	#1,$18(A3)
	TST.W	$18(A3)
	BNE.S	lbC004834
	MOVE.W	D4,D0
	EXT.L	D0
	ASL.L	#4,D0
	MOVEA.L	D0,A0
	ADDA.L	#$DFF0A0,A0
	MOVE.L	14(A3),(A0)				; address

	move.l	D0,-(SP)
	move.l	14(A3),D0
	bsr.w	SetAdr
	move.l	(SP)+,D0

	MOVE.W	D4,D0
	EXT.L	D0
	ASL.L	#4,D0
	MOVEA.L	D0,A0
	ADDA.L	#$DFF0A4,A0
	MOVE.W	$12(A3),(A0)				; length

	move.l	D0,-(SP)
	move.w	$12(A3),D0
	bsr.w	SetLen
	move.l	(SP)+,D0

lbC004834	MOVE.B	3(A3),D0
	EXT.W	D0
	MOVEQ	#0,D1
	MOVE.B	$14(A2),D1
	ADD.W	D1,D0
	MOVE.W	D0,-8(A5)
	CMP.W	#$7F,D0
	BLE.S	lbC004852
	MOVE.W	#$7F,-8(A5)
lbC004852	MOVE.W	D5,D0
	MULS.W	#6,D0
	LEA	lbB00EBB1-WT(A4),A0
	MOVEQ	#0,D1
	MOVE.B	0(A0,D0.L),D1
	MULU.W	-8(A5),D1
	LSR.W	#7,D1
	MULU.W	8(A3),D1
	MOVEQ	#9,D0
	LSR.W	D0,D1
	MOVE.W	D1,-6(A5)
	TST.W	lbW00ECAE-WT(A4)
	BEQ.S	lbC00488C
	MOVE.W	lbW00ECAE-WT(A4),D0
	SUB.W	D0,-6(A5)
	TST.W	-6(A5)
	BGE.S	lbC00488C
	CLR.W	-6(A5)
lbC00488C	MOVE.W	D4,D0
	EXT.L	D0
	ASL.L	#4,D0
	MOVEA.L	D0,A0
	ADDA.L	#$DFF0A8,A0
;	MOVE.W	-6(A5),(A0)				; volume

	move.l	D0,-(SP)
	move.w	-6(A5),D0
	bsr.w	ChangeVolume
	move.l	(SP)+,D0

	TST.B	(A3)
	BGE.S	lbC0048AE
	MOVEQ	#1,D0
	ASL.W	D4,D0
	MOVE.W	D0,$DFF096				; DMA
	BRA.S	lbC0048BC

lbC0048AE	MOVEQ	#1,D0
	ASL.W	D4,D0
	OR.W	#$8200,D0

	bsr.w	DMAWait

	MOVE.W	D0,$DFF096				; DMA
lbC0048BC	ADDQ.W	#1,D4
	CMP.W	#4,D4
	BLT.L	lbC00450A
lbC0048C6	SUBQ.W	#1,lbW00B9C2-WT(A4)
;	JSR	lbC008E94(PC)
;	MOVEM.L	(SP)+,D1-D7/A0-A6
;	MOVEQ	#0,D0
;	MOVEM.L	(SP)+,D4/D5/A2/A3
	UNLK	A5
	RTS

lbC0048DC	LINK.W	A5,#-2
	MOVE.B	#15,lbB00EC8E-WT(A4)
	CLR.L	lbL00EC90-WT(A4)
	CLR.W	lbW00EC98-WT(A4)
;	CLR.L	lbL00EC9A-WT(A4)
	CLR.L	lbL00EC9E-WT(A4)
	CLR.B	lbB00ECA2-WT(A4)
	CLR.B	lbB00ECA3-WT(A4)
	CLR.B	lbB00ECA4-WT(A4)
	CLR.B	lbB00ECA5-WT(A4)
	CLR.W	lbW00ECAE-WT(A4)
	CLR.W	-2(A5)
lbC00490E	MOVE.W	-2(A5),D0
	MULS.W	#$1A,D0
	LEA	lbL00EC0E-WT(A4),A0
	MOVE.B	#$FF,0(A0,D0.L)
	MOVE.W	-2(A5),D0
	MULS.W	#$1A,D0
	LEA	lbB00EC1B-WT(A4),A0
	CLR.B	0(A0,D0.L)
	ADDQ.W	#1,-2(A5)
	CMPI.W	#4,-2(A5)
	BLT.S	lbC00490E
	UNLK	A5
	RTS

;lbC004940	LINK.W	A5,#0
;	CLR.L	lbL00EC76-WT(A4)
;	CLR.L	lbL00EC7A-WT(A4)
;	CLR.L	lbL00EC7E-WT(A4)
;	CLR.L	lbL00EC82-WT(A4)
;	CLR.L	lbL00EC86-WT(A4)
;	MOVE.L	#1,lbL00EC8A-WT(A4)
;	JSR	lbC0048DC(PC)
;	CLR.W	lbW00ECB0-WT(A4)
;	UNLK	A5
;	RTS

;lbC00496C	LINK.W	A5,#-4			; Install Player
;	BSR.S	lbC004940
;	JSR	lbC004B36(PC)
;	PEA	$10001
;	PEA	$44
;	JSR	lbC00A7D4-WT(A4)		; AllocMem
;	ADDQ.W	#8,SP
;	MOVE.L	D0,lbL00EC82-WT(A4)
;	PEA	$10001
;	PEA	$44
;	JSR	lbC00A7D4-WT(A4)		; AllocMem
;	ADDQ.W	#8,SP
;	MOVE.L	D0,lbL00EC86-WT(A4)
;	TST.L	lbL00EC82-WT(A4)
;	BEQ.L	lbC004AAC
;	TST.L	lbL00EC86-WT(A4)
;	BEQ.L	lbC004AAC
;	MOVEA.L	lbL00EC82-WT(A4),A0
;	MOVE.B	#$7F,9(A0)
;	MOVEA.L	lbL00EC82-WT(A4),A0
;	MOVE.W	#$20,$1C(A0)
;	MOVEA.L	lbL00EC82-WT(A4),A0
;	MOVE.B	#$41,$1E(A0)
;	MOVEA.L	lbL00EC82-WT(A4),A0
;	CLR.W	$20(A0)
;	LEA	lbB00EC8E-WT(A4),A0
;	MOVEA.L	lbL00EC82-WT(A4),A1
;	MOVE.L	A0,$22(A1)
;	MOVEA.L	lbL00EC82-WT(A4),A0
;	MOVE.L	#1,$26(A0)
;	CLR.L	-(SP)
;	MOVE.L	lbL00EC82-WT(A4),-(SP)
;	CLR.L	-(SP)
;	PEA	audiodevice.MSG-WT(A4)
;	JSR	lbC00A45A(PC)			; opendevice
;	LEA	$10(SP),SP
;	MOVE.L	D0,lbL00EC8A-WT(A4)
;	TST.L	lbL00EC8A-WT(A4)
;	BNE.L	lbC004AAC
;	MOVEA.L	lbL00EC86-WT(A4),A0
;	MOVEA.L	lbL00EC82-WT(A4),A1
;	MOVEQ	#$10,D0
;lbC004A16	MOVE.L	(A1)+,(A0)+
;	DBRA	D0,lbC004A16
;	CLR.L	-(SP)
;	PEA	lbC004406(PC)
;	CLR.L	-(SP)
;	PEA	SD_MusicInt.MSG-WT(A4)
;	JSR	lbC0054BC(PC)
;	LEA	$10(SP),SP
;	MOVE.L	D0,lbL00EC76-WT(A4)
;	BEQ.S	lbC004AAC
;	CLR.L	-(SP)
;	PEA	lbC004438(PC)
;	CLR.L	-(SP)
;	PEA	MusicInt.MSG-WT(A4)
;	JSR	lbC0054BC(PC)
;	LEA	$10(SP),SP
;	MOVE.L	D0,lbL00EC7A-WT(A4)
;	BEQ.S	lbC004AAC
;	CLR.L	-(SP)
;	PEA	ciabresource.MSG-WT(A4)
;	JSR	lbC00A484(PC)			; openresource
;	ADDQ.W	#8,SP
;	MOVE.L	D0,lbL00EC7E-WT(A4)
;	BEQ.S	lbC004AAC
;	MOVE.L	lbL00EC76-WT(A4),-(SP)
;	CLR.L	-(SP)
;	MOVE.L	lbL00EC7E-WT(A4),-(SP)
;	JSR	lbC00A0FC(PC)			; addICRVector
;	LEA	12(SP),SP
;	TST.L	D0
;	BNE.S	lbC004AAC
;	ANDI.B	#$FE,$BFDE00
;	PEA	1
;	MOVE.L	lbL00EC7E-WT(A4),-(SP)
;	JSR	lbC00A116(PC)			; SetICR
;	ADDQ.W	#8,SP
;	MOVE.B	#$9B,$BFD400			; NTSC 60Hz timer
;	MOVE.B	#$2E,$BFD500
;	BSET	#0,$BFDE00
;	MOVEQ	#10,D0
;lbC004AA8	UNLK	A5
;	RTS

;lbC004AAC	BSR.S	lbC004AB2		; initialization error
;	MOVEQ	#0,D0
;	BRA.S	lbC004AA8

;lbC004AB2	LINK.W	A5,#0
;	ANDI.B	#$FE,$BFDE00
;	TST.L	lbL00EC7E-WT(A4)
;	BEQ.S	lbC004AD6
;	MOVE.L	lbL00EC76-WT(A4),-(SP)
;	CLR.L	-(SP)
;	MOVE.L	lbL00EC7E-WT(A4),-(SP)
;	JSR	lbC00A10A(PC)
;	LEA	12(SP),SP
;lbC004AD6	TST.L	lbL00EC76-WT(A4)
;	BEQ.S	lbC004AE6
;	MOVE.L	lbL00EC76-WT(A4),-(SP)
;	JSR	lbC005500(PC)
;	ADDQ.W	#4,SP
;lbC004AE6	TST.L	lbL00EC7A-WT(A4)
;	BEQ.S	lbC004AF6
;	MOVE.L	lbL00EC7A-WT(A4),-(SP)
;	JSR	lbC005500(PC)
;	ADDQ.W	#4,SP
;lbC004AF6	TST.L	lbL00EC8A-WT(A4)
;	BNE.S	lbC004B06
;	MOVE.L	lbL00EC86-WT(A4),-(SP)
;	JSR	lbC00A21E(PC)
;	ADDQ.W	#4,SP
;lbC004B06	TST.L	lbL00EC82-WT(A4)
;	BEQ.S	lbC004B1A
;	PEA	$44
;	MOVE.L	lbL00EC82-WT(A4),-(SP)
;	JSR	lbC00A7E0-WT(A4)
;	ADDQ.W	#8,SP
;lbC004B1A	TST.L	lbL00EC86-WT(A4)
;	BEQ.S	lbC004B2E
;	PEA	$44
;	MOVE.L	lbL00EC86-WT(A4),-(SP)
;	JSR	lbC00A7E0-WT(A4)
;	ADDQ.W	#8,SP
;lbC004B2E	JSR	lbC004940(PC)
;	UNLK	A5
;	RTS

lbC004B36	LINK.W	A5,#0
	MOVE.L	D4,-(SP)
	MOVEQ	#0,D4
lbC004B3E	MOVE.W	D4,D0
	MULS.W	#6,D0
	LEA	lbB00EBAF-WT(A4),A0
	MOVE.B	#$40,0(A0,D0.L)
	MOVE.W	D4,D0
	MULS.W	#6,D0
	LEA	lbL00EBB2-WT(A4),A0
	CLR.B	0(A0,D0.L)
	MOVE.W	D4,D0
	MULS.W	#6,D0
	LEA	lbB00EBB0-WT(A4),A0
	CLR.B	0(A0,D0.L)
	MOVE.W	D4,D0
	MULS.W	#6,D0
	LEA	lbB00EBB1-WT(A4),A0
	MOVE.B	#$7F,0(A0,D0.L)
	MOVE.W	D4,D0
	MULS.W	#6,D0
	LEA	lbB00EBAE-WT(A4),A0
	MOVE.B	D4,0(A0,D0.L)
	ADDQ.W	#1,D4
	CMP.W	#$10,D4
	BLT.S	lbC004B3E
	CLR.W	lbW00B9C0-WT(A4)
	MOVE.L	(SP)+,D4
	UNLK	A5
	RTS

lbC004B9A	LINK.W	A5,#-$16
	MOVEM.L	D4-D6/A2/A3,-(SP)
	MOVE.W	#$FFFF,-$10(A5)
	CLR.W	-$12(A5)
	MOVEQ	#0,D0
	MOVE.B	11(A5),D0
	MOVE.W	D0,-$14(A5)
	CLR.W	-$16(A5)
	MOVEQ	#0,D0
	MOVE.B	$11(A5),D0
	MOVEA.L	lbL00ECA6-WT(A4),A0
	MOVEQ	#0,D1
	MOVE.B	0(A0,D0.L),D1
	MOVE.W	D1,D5
	CMP.W	#3,D1
	BLE.L	lbC004CAC
	CLR.W	-14(A5)
lbC004BD8	MOVE.W	-14(A5),D0
	MULS.W	#$1A,D0
	LEA	lbL00EC0E-WT(A4),A0
	MOVEA.L	D0,A3
	ADDA.L	A0,A3
	MOVEQ	#0,D6
	TST.B	(A3)
	BGE.S	lbC004BF8
	BSET	#4,D6
	MOVE.W	#1,-$16(A5)
lbC004BF8	BTST	#1,13(A3)
	BNE.S	lbC004C26
	BSET	#3,D6
	MOVE.W	#1,-$16(A5)
	MOVE.B	(A3),D0
	EXT.W	D0
	MOVEQ	#0,D1
	MOVE.B	$11(A5),D1
	CMP.W	D1,D0
	BNE.S	lbC004C26
	MOVEA.L	lbL00ECA6-WT(A4),A0
	TST.B	15(A0)
	BNE.S	lbC004C26
	OR.W	#$30,D6
lbC004C26	MOVE.B	(A3),D0
	EXT.W	D0
	MOVEQ	#0,D1
	MOVE.B	$11(A5),D1
	CMP.W	D1,D0
	BNE.S	lbC004C4C
	BSET	#2,D6
	MOVE.B	1(A3),D0
	EXT.W	D0
	MOVEQ	#0,D1
	MOVE.B	13(A5),D1
	CMP.W	D1,D0
	BNE.S	lbC004C4C
	BSET	#3,D6
lbC004C4C	MOVE.B	1(A3),D0
	EXT.W	D0
	MOVEQ	#0,D1
	MOVE.B	13(A5),D1
	CMP.W	D1,D0
	BNE.S	lbC004C60
	BSET	#1,D6
lbC004C60	MOVEQ	#0,D0
	MOVE.B	12(A3),D0
	CMP.W	-$14(A5),D0
	BCC.S	lbC004C7A
	MOVEQ	#0,D0
	MOVE.B	12(A3),D0
	MOVE.W	D0,-$14(A5)
	BSET	#0,D6
lbC004C7A	MOVE.W	-$12(A5),D0
	CMP.W	D6,D0
	BGE.S	lbC004C8C
	MOVE.W	D6,-$12(A5)
	MOVE.W	-14(A5),-$10(A5)
lbC004C8C	ADDQ.W	#1,-14(A5)
	CMPI.W	#4,-14(A5)
	BLT.L	lbC004BD8
	TST.W	-$10(A5)
	BGE.S	lbC004CA8
lbC004CA0	MOVEM.L	(SP)+,D4-D6/A2/A3
	UNLK	A5
	RTS

lbC004CA8	MOVE.W	-$10(A5),D5
lbC004CAC	MOVE.W	D5,D0
	MULS.W	#$1A,D0
	LEA	lbL00EC0E-WT(A4),A0
	MOVEA.L	D0,A3
	ADDA.L	A0,A3
	MOVEQ	#0,D4
lbC004CBC	MOVEQ	#0,D0
	MOVE.B	13(A5),D0
	MOVEQ	#0,D1
	MOVE.B	9(A5),D1
	ASL.L	#2,D1
	LEA	lbL00ECB2-WT(A4),A0
	MOVEA.L	0(A0,D1.L),A1
	MOVE.W	D4,D1
	MULS.W	#$1A,D1
	ADDA.L	D1,A1
	MOVE.B	$46(A1),D1
	EXT.W	D1
	CMP.W	D1,D0
	BCS.S	lbC004D0C
	MOVEQ	#0,D0
	MOVE.B	13(A5),D0
	MOVEQ	#0,D1
	MOVE.B	9(A5),D1
	ASL.L	#2,D1
	LEA	lbL00ECB2-WT(A4),A0
	MOVEA.L	0(A0,D1.L),A1
	MOVE.W	D4,D1
	MULS.W	#$1A,D1
	ADDA.L	D1,A1
	MOVE.B	$47(A1),D1
	EXT.W	D1
	CMP.W	D1,D0
	BLS.S	lbC004D16
lbC004D0C	ADDQ.W	#1,D4
	CMP.W	#3,D4
	BLT.S	lbC004CBC
	BRA.S	lbC004CA0

lbC004D16	MOVEQ	#0,D0
	MOVE.B	9(A5),D0
	ASL.L	#2,D0
	LEA	lbL00ECB2-WT(A4),A0
	MOVEA.L	0(A0,D0.L),A1
	MOVE.W	D4,D0
	MULS.W	#$1A,D0
	ADDA.L	D0,A1
	TST.L	$42(A1)
	BNE.S	lbC004D38
	BRA.L	lbC004CA0

lbC004D38	MOVE.B	#$FF,(A3)
	MOVE.W	D5,D0
	EXT.L	D0
	ASL.L	#4,D0
	MOVEA.L	D0,A0
	ADDA.L	#$DFF0A6,A0
	MOVE.W	#$80,(A0)				; period
	MOVEQ	#1,D0
	ASL.W	D5,D0
	MOVE.W	D0,$DFF096				; DMA
	MOVEQ	#0,D0
	MOVE.B	9(A5),D0
	ASL.L	#2,D0
	LEA	lbL00ECB2-WT(A4),A0
	MOVEA.L	0(A0,D0.L),A1
	MOVE.W	D4,D0
	MULS.W	#$1A,D0
	ADDA.L	D0,A1
	MOVE.L	$4A(A1),-4(A5)
	MOVEQ	#0,D0
	MOVE.B	9(A5),D0
	ASL.L	#2,D0
	LEA	lbL00ECB2-WT(A4),A0
	MOVEA.L	0(A0,D0.L),A1
	MOVE.W	D4,D0
	MULS.W	#$1A,D0
	ADDA.L	D0,A1
	MOVE.L	$4E(A1),-8(A5)
	MOVEQ	#0,D0
	MOVE.B	9(A5),D0
	ASL.L	#2,D0
	LEA	lbL00ECB2-WT(A4),A0
	MOVEA.L	0(A0,D0.L),A1
	MOVE.W	D4,D0
	MULS.W	#$1A,D0
	ADDA.L	D0,A1
	MOVE.L	$52(A1),-12(A5)
	MOVEQ	#0,D0
	MOVE.B	9(A5),D0
	ASL.L	#2,D0
	LEA	lbL00ECB2-WT(A4),A0
	MOVEA.L	0(A0,D0.L),A1
	MOVE.W	D4,D0
	MULS.W	#$1A,D0
	ADDA.L	D0,A1
	MOVEA.L	$42(A1),A2
	TST.L	-8(A5)
	BLT.S	lbC004DFA
	MOVEQ	#2,D1
	MOVE.L	-8(A5),D0
	JSR	lbC009A4A(PC)
	ASL.L	#1,D0
	ADD.L	A2,D0
	MOVE.L	D0,14(A3)
	MOVE.L	-12(A5),D0
	SUB.L	-8(A5),D0
	MOVEQ	#2,D1
	JSR	lbC009A4A(PC)
	MOVE.W	D0,$12(A3)
	BRA.S	lbC004E08

lbC004DFA
;	LEA	lbL00EC9A-WT(A4),A0

	lea	lbL00EC9A,A0

	MOVE.L	A0,14(A3)
	MOVE.W	#2,$12(A3)
lbC004E08	MOVE.W	#2,$18(A3)
	MOVE.B	13(A5),1(A3)
	MOVE.B	9(A5),2(A3)
	MOVE.B	15(A5),3(A3)
	MOVEQ	#0,D0
	MOVE.B	9(A5),D0
	ASL.L	#2,D0
	LEA	lbL00ECB2-WT(A4),A0
	MOVEA.L	0(A0,D0.L),A1
	MOVE.W	D4,D0
	MULS.W	#$1A,D0
	ADDA.L	D0,A1
	MOVE.W	$48(A1),4(A3)
	CLR.B	10(A3)
	MOVE.W	#$80,6(A3)
	CLR.B	11(A3)
	CLR.W	8(A3)
	MOVE.B	11(A5),12(A3)
	CLR.W	$14(A3)
	MOVEQ	#0,D0
	MOVE.B	9(A5),D0
	ASL.L	#2,D0
	LEA	lbL00ECB2-WT(A4),A0
	MOVEA.L	0(A0,D0.L),A1
	MOVEQ	#0,D0
	MOVE.B	$16(A1),D0
	MOVE.W	D0,$16(A3)
	MOVEQ	#0,D0
	MOVE.B	$11(A5),D0
	MOVEQ	#6,D1
;	JSR	lbC00A798-WT(A4)

	jsr	lbC00A798(PC)

	LEA	lbL00EBB2-WT(A4),A0
	TST.B	0(A0,D0.L)
	BLS.S	lbC004E8E
	MOVEQ	#1,D0
	BRA.S	lbC004E90

lbC004E8E	MOVEQ	#0,D0
lbC004E90	ADDQ.W	#2,D0
	MOVE.B	D0,13(A3)
	MOVE.B	$11(A5),(A3)
	MOVE.W	D5,D0
	EXT.L	D0
	ASL.L	#4,D0
	MOVEA.L	D0,A0
	ADDA.L	#$DFF0A8,A0
	CLR.W	(A0)					; volume
	MOVE.W	D5,D0
	EXT.L	D0
	ASL.L	#4,D0
	MOVEA.L	D0,A0
	ADDA.L	#$DFF0A0,A0
	MOVEQ	#2,D1
	MOVE.L	-4(A5),D0
	JSR	lbC009A4A(PC)
	ASL.L	#1,D0
	ADD.L	A2,D0
	MOVE.L	D0,(A0)					; address

	bsr.w	SetAdr

	MOVE.L	-12(A5),D0
	SUB.L	-4(A5),D0
	MOVEQ	#2,D1
	JSR	lbC009A4A(PC)
	MOVE.W	D5,D1
	EXT.L	D1
	ASL.L	#4,D1
	MOVEA.L	D1,A0
	ADDA.L	#$DFF0A4,A0
	MOVE.W	D0,(A0)					; length

	bsr.w	SetLen

	BRA.L	lbC004CA0

lbC004EEA	LINK.W	A5,#0
	MOVEM.L	D4/A2,-(SP)
	MOVEQ	#0,D4
lbC004EF4	MOVE.W	D4,D0
	MULS.W	#$1A,D0
	LEA	lbL00EC0E-WT(A4),A0
	MOVEA.L	D0,A2
	ADDA.L	A0,A2
	MOVE.B	(A2),D0
	EXT.W	D0
	MOVEQ	#0,D1
	MOVE.B	11(A5),D1
	CMP.W	D1,D0
	BNE.S	lbC004F48
	BTST	#1,13(A2)
	BEQ.S	lbC004F30
	ANDI.B	#2,13(A2)
	TST.B	9(A5)
	BLS.S	lbC004F28
	MOVEQ	#1,D0
	BRA.S	lbC004F2A

lbC004F28	MOVEQ	#0,D0
lbC004F2A	OR.B	D0,13(A2)
	BRA.S	lbC004F48

lbC004F30	TST.B	9(A5)
	BNE.S	lbC004F48
	BTST	#0,13(A2)
	BEQ.S	lbC004F48
	MOVE.W	D4,-(SP)
	BSR.S	lbC004FAC
	ADDQ.W	#2,SP
	CLR.B	13(A2)
lbC004F48	ADDQ.W	#1,D4
	CMP.W	#4,D4
	BLT.S	lbC004EF4
	MOVEM.L	(SP)+,D4/A2
	UNLK	A5
	RTS

lbC004F58	LINK.W	A5,#0
	MOVEM.L	D4/A2,-(SP)
	MOVEQ	#0,D4
lbC004F62	MOVE.W	D4,D0
	MULS.W	#$1A,D0
	LEA	lbL00EC0E-WT(A4),A0
	MOVEA.L	D0,A2
	ADDA.L	A0,A2
	MOVE.B	1(A2),D0
	EXT.W	D0
	MOVEQ	#0,D1
	MOVE.B	9(A5),D1
	CMP.W	D1,D0
	BNE.S	lbC004F9C
	MOVE.B	(A2),D0
	EXT.W	D0
	MOVEQ	#0,D1
	MOVE.B	11(A5),D1
	CMP.W	D1,D0
	BNE.S	lbC004F9C
	BTST	#1,13(A2)
	BEQ.S	lbC004F9C
	MOVE.W	D4,-(SP)
	BSR.S	lbC004FAC
	ADDQ.W	#2,SP
lbC004F9C	ADDQ.W	#1,D4
	CMP.W	#4,D4
	BLT.S	lbC004F62
	MOVEM.L	(SP)+,D4/A2
	UNLK	A5
	RTS

lbC004FAC	LINK.W	A5,#0
	MOVEM.L	D4/A2,-(SP)
	MOVE.W	8(A5),D4
	MOVE.W	D4,D0
	MULS.W	#$1A,D0
	LEA	lbL00EC0E-WT(A4),A0
	MOVEA.L	D0,A2
	ADDA.L	A0,A2
	MOVE.B	2(A2),D0
	EXT.W	D0
	EXT.L	D0
	ASL.L	#2,D0
	LEA	lbL00ECB2-WT(A4),A0
	MOVEA.L	0(A0,D0.L),A1
	MOVE.B	$2A(A1),11(A2)
	MOVE.B	2(A2),D0
	EXT.W	D0
	EXT.L	D0
	ASL.L	#2,D0
	LEA	lbL00ECB2-WT(A4),A0
	MOVEA.L	0(A0,D0.L),A1
	MOVE.B	$18(A1),10(A2)
	ANDI.B	#1,13(A2)
	MOVEM.L	(SP)+,D4/A2
	UNLK	A5
	RTS

Init
lbC005004	LINK.W	A5,#0
	JSR	lbC0048DC(PC)
	JSR	lbC004B36(PC)
	MOVE.L	8(A5),lbL00EC94-WT(A4)
	MOVE.L	8(A5),lbL00EC90-WT(A4)
	MOVEA.L	lbL00EC90-WT(A4),A0
	MOVEQ	#0,D0
	MOVE.B	(A0),D0
	ASL.W	#8,D0
	MOVEA.L	lbL00EC90-WT(A4),A0
	MOVEQ	#0,D1
	MOVE.B	1(A0),D1
	OR.W	D1,D0
	MOVE.W	D0,lbW00EC98-WT(A4)
	CLR.L	lbL00EC9E-WT(A4)
	UNLK	A5
	RTS

lbC00503E	LINK.W	A5,#-2
	CLR.W	lbW00ECB0-WT(A4)
	CLR.W	-(SP)
	JSR	lbC0050D2(PC)
	ADDQ.W	#2,SP
	CLR.W	-2(A5)
lbC005052	MOVE.W	-2(A5),-(SP)
	JSR	lbC004FAC(PC)
	ADDQ.W	#2,SP
	ADDQ.W	#1,-2(A5)
	CMPI.W	#4,-2(A5)
	BLT.S	lbC005052
	UNLK	A5
	RTS

lbC00506C	LINK.W	A5,#-4
	MOVE.W	#1,-2(A5)
lbC005076	TST.W	-2(A5)
	BEQ.S	lbC0050AA
	CLR.W	-2(A5)
	CLR.W	-4(A5)
lbC005084	MOVE.W	-4(A5),D0
	MULS.W	#$1A,D0
	LEA	lbL00EC0E-WT(A4),A0
	TST.B	0(A0,D0.L)
	BLT.S	lbC00509C
	MOVE.W	#1,-2(A5)
lbC00509C	ADDQ.W	#1,-4(A5)
	CMPI.W	#4,-4(A5)
	BLT.S	lbC005084
	BRA.S	lbC005076

lbC0050AA	UNLK	A5
	RTS

lbC0050AE	LINK.W	A5,#0
	TST.W	lbW00B9BE-WT(A4)
	BEQ.S	lbC0050CA

	bsr.w	SongEnd

	MOVE.W	#$19,lbW00ECB0-WT(A4)
	MOVE.L	lbL00EC94-WT(A4),-(SP)
	JSR	lbC005004(PC)
	ADDQ.W	#4,SP
	BRA.S	lbC0050CE

lbC0050CA	JSR	lbC00503E(PC)
lbC0050CE	UNLK	A5
	RTS

lbC0050D2	LINK.W	A5,#0
	TST.W	8(A5)
	BEQ.S	lbC0050FA
	MOVE.W	#1,lbW00B9C0-WT(A4)
	CLR.W	lbW00ECAC-WT(A4)
	CLR.W	lbW00ECAE-WT(A4)
	MOVE.W	8(A5),D0
	EXT.L	D0
	DIVS.W	#$3C,D0
	MOVE.W	D0,lbW00ECAA-WT(A4)
	BRA.S	lbC005102

lbC0050FA	CLR.L	lbL00EC90-WT(A4)
	CLR.L	lbL00EC9E-WT(A4)
lbC005102	UNLK	A5
	RTS

;	LINK.W	A5,#0
;	TST.L	lbL00EC90-WT(A4)
;	BNE.S	lbC005114
;	MOVEQ	#1,D0
;	BRA.S	lbC005116

;lbC005114	MOVEQ	#0,D0
;lbC005116	UNLK	A5
;	RTS

lbC00511A	LINK.W	A5,#-2
	MOVE.B	9(A5),D0
	AND.B	#15,D0
	MOVE.B	D0,-1(A5)
	ADDQ.L	#1,lbL00EC9E-WT(A4)
	MOVEQ	#0,D0
	MOVE.B	-1(A5),D0
	MOVEQ	#6,D1
;	JSR	lbC00A798-WT(A4)

	jsr	lbC00A798(PC)

	LEA	lbB00EBAE-WT(A4),A0
	MOVE.B	0(A0,D0.L),lbB00ECA5-WT(A4)
	MOVE.B	-1(A5),lbB00ECA2-WT(A4)
	MOVE.B	11(A5),lbB00ECA3-WT(A4)
	MOVE.B	13(A5),lbB00ECA4-WT(A4)
	MOVEQ	#0,D0
	MOVE.B	9(A5),D0
	LSR.W	#4,D0
	MOVE.W	D0,D1
	MOVEQ	#0,D0
	MOVE.W	D1,D0
	BRA.L	lbC0052A6

lbC005168	JSR	lbC0050AE(PC)
	BRA.L	lbC0052B8

lbC005170	MOVEQ	#0,D0
	MOVE.B	-1(A5),D0
	MOVE.W	D0,-(SP)
	MOVEQ	#0,D0
	MOVE.B	lbB00ECA3-WT(A4),D0
	MOVE.W	D0,-(SP)
	JSR	lbC004F58(PC)
	ADDQ.W	#4,SP
	BRA.L	lbC0052B8

lbC00518A	TST.B	lbB00ECA4-WT(A4)
	BNE.S	lbC0051A8
	MOVEQ	#0,D0
	MOVE.B	-1(A5),D0
	MOVE.W	D0,-(SP)
	MOVEQ	#0,D0
	MOVE.B	lbB00ECA3-WT(A4),D0
	MOVE.W	D0,-(SP)
	JSR	lbC004F58(PC)
	ADDQ.W	#4,SP
	BRA.S	lbC0051D4

lbC0051A8	MOVEQ	#0,D0
	MOVE.B	-1(A5),D0
	MOVE.W	D0,-(SP)
	MOVEQ	#0,D0
	MOVE.B	lbB00ECA4-WT(A4),D0
	MOVE.W	D0,-(SP)
	MOVEQ	#0,D0
	MOVE.B	lbB00ECA3-WT(A4),D0
	MOVE.W	D0,-(SP)
	MOVE.W	#$FF,-(SP)
	MOVEQ	#0,D0
	MOVE.B	lbB00ECA5-WT(A4),D0
	MOVE.W	D0,-(SP)
	JSR	lbC004B9A(PC)
	LEA	10(SP),SP
lbC0051D4	BRA.L	lbC0052B8

lbC0051D8	MOVEQ	#0,D0
	MOVE.B	11(A5),D0
	BRA.S	lbC005240

lbC0051E0	MOVEQ	#0,D0
	MOVE.B	-1(A5),D0
	MOVEQ	#6,D1
;	JSR	lbC00A798-WT(A4)

	jsr	lbC00A798(PC)

	LEA	lbB00EBB0-WT(A4),A0
	MOVE.B	lbB00ECA4-WT(A4),0(A0,D0.L)
	BRA.S	lbC005252

lbC0051F8	MOVEQ	#0,D0
	MOVE.B	-1(A5),D0
	MOVEQ	#6,D1
;	JSR	lbC00A798-WT(A4)

	jsr	lbC00A798(PC)

	LEA	lbB00EBB1-WT(A4),A0
	MOVE.B	lbB00ECA4-WT(A4),0(A0,D0.L)
	BRA.S	lbC005252

lbC005210	MOVEQ	#0,D0
	MOVE.B	-1(A5),D0
	MOVEQ	#6,D1
;	JSR	lbC00A798-WT(A4)

	jsr	lbC00A798(PC)

	LEA	lbL00EBB2-WT(A4),A0
	MOVE.B	lbB00ECA4-WT(A4),0(A0,D0.L)
	MOVEQ	#0,D0
	MOVE.B	-1(A5),D0
	MOVE.W	D0,-(SP)
	MOVEQ	#0,D0
	MOVE.B	lbB00ECA4-WT(A4),D0
	MOVE.W	D0,-(SP)
	JSR	lbC004EEA(PC)
	ADDQ.W	#4,SP
	BRA.S	lbC005252

lbC00523E	BRA.S	lbC005252

lbC005240	SUBQ.L	#1,D0
	BEQ.S	lbC0051E0
	SUBQ.L	#6,D0
	BEQ.S	lbC0051F8
	SUB.L	#$39,D0
	BEQ.S	lbC005210
	BRA.S	lbC00523E

lbC005252	BRA.S	lbC0052B8

lbC005254	MOVEQ	#0,D0
	MOVE.B	-1(A5),D0
	MOVEQ	#6,D1
;	JSR	lbC00A798-WT(A4)

	jsr	lbC00A798(PC)

	LEA	lbB00EBAE-WT(A4),A0
	MOVE.B	lbB00ECA3-WT(A4),0(A0,D0.L)
	BRA.S	lbC0052B8

lbC00526C	BRA.S	lbC0052B8

lbC00526E	MOVEQ	#0,D0
	MOVE.B	-1(A5),D0
	MOVEQ	#6,D1
;	JSR	lbC00A798-WT(A4)

	jsr	lbC00A798(PC)

	LEA	lbB00EBAF-WT(A4),A0
	MOVE.B	lbB00ECA4-WT(A4),0(A0,D0.L)
	BRA.S	lbC0052B8

lbC005286	BRA.S	lbC0052B8

lbW005288	dc.w	lbC005286-lbW0052B6
	dc.w	lbC005168-lbW0052B6
	dc.w	lbC005286-lbW0052B6
	dc.w	lbC005286-lbW0052B6
	dc.w	lbC005286-lbW0052B6
	dc.w	lbC005286-lbW0052B6
	dc.w	lbC005286-lbW0052B6
	dc.w	lbC005286-lbW0052B6
	dc.w	lbC005170-lbW0052B6
	dc.w	lbC00518A-lbW0052B6
	dc.w	lbC005286-lbW0052B6
	dc.w	lbC0051D8-lbW0052B6
	dc.w	lbC005254-lbW0052B6
	dc.w	lbC00526C-lbW0052B6
	dc.w	lbC00526E-lbW0052B6

lbC0052A6	CMP.L	#15,D0
	BCC.S	lbC005286
	ASL.L	#1,D0
	MOVE.W	lbW005288(PC,D0.W),D0
	JMP	lbW0052B6(PC,D0.W)
lbW0052B6	EQU	*-2

lbC0052B8	UNLK	A5
	RTS

InstallSamples
lbC0052BC	LINK.W	A5,#-8
;	MOVEM.L	D4/D5/A2,-(SP)
;	MOVE.W	12(A5),D0
;	MULS.W	#12,D0
;	MOVEA.L	D0,A0
;	ADDA.L	8(A5),A0
;	MOVE.L	$10(A0),-4(A5)

	move.l	A0,-4(A5)

	MOVEQ	#0,D4
lbC0052DA	MOVE.W	D4,D0
	EXT.L	D0
	ASL.L	#2,D0
	LEA	lbL00ECB2-WT(A4),A0		; clear sampleinfo ptr
	CLR.L	0(A0,D0.L)
	ADDQ.W	#1,D4
	CMP.W	#$80,D4
	BLT.S	lbC0052DA
;	PEA	4
;	PEA	IBLK.MSG-WT(A4)
;	MOVE.L	-4(A5),-(SP)
;	JSR	lbC00A786-WT(A4)
;	LEA	12(SP),SP
;	TST.W	D0
;	BNE.S	lbC00535E
	ADDQ.L	#4,-4(A5)
	MOVEA.L	-4(A5),A0
	ADDQ.L	#1,-4(A5)
	MOVEQ	#0,D0
	MOVE.B	(A0),D0
	MOVE.W	D0,-6(A5)
	MOVEA.L	-4(A5),A0
	ADDQ.L	#1,-4(A5)
	MOVEQ	#0,D0
	MOVE.B	(A0),D0
	MOVE.W	D0,-8(A5)
lbC00532C	MOVE.W	-6(A5),D0
	SUBQ.W	#1,-6(A5)
	TST.W	D0
	BEQ.S	lbC005356
	MOVEA.L	-4(A5),A2
	MOVE.B	(A2),D0
	EXT.W	D0
	EXT.L	D0
	ASL.L	#2,D0
	LEA	lbL00ECB2-WT(A4),A0		; install sampleinfo ptr
	MOVE.L	A2,0(A0,D0.L)
	ADDI.L	#$8A,-4(A5)
	BRA.S	lbC00532C

lbC005356	MOVE.L	-4(A5),lbL00ECA6-WT(A4)
	BRA.S	lbC005368

lbC00535E	MOVEQ	#0,D0
lbC005360
;	MOVEM.L	(SP)+,D4/D5/A2
	UNLK	A5
	RTS

lbC005368	MOVEQ	#0,D4
lbC00536A	MOVE.W	D4,D0
	EXT.L	D0
	ASL.L	#2,D0
	LEA	lbL00ECB2-WT(A4),A0
	MOVEA.L	0(A0,D0.L),A2
	MOVE.L	A2,D0
	BEQ.S	lbC0053B8
	MOVEQ	#0,D5
lbC00537E	MOVE.W	D5,D0
	MULS.W	#$1A,D0
	MOVEA.L	D0,A0
	ADDA.L	A2,A0
	TST.L	$42(A0)
	BEQ.S	lbC0053B0
;	MOVE.W	D5,D0
;	MULS.W	#$1A,D0
;	MOVEA.L	D0,A0
;	ADDA.L	A2,A0
;	PEA	$3C(A0)
;	JSR	lbC00566A(PC)
;	ADDQ.W	#4,SP
;	MOVE.W	D5,D1
;	MULS.W	#$1A,D1
;	MOVEA.L	D1,A0
;	ADDA.L	A2,A0

	movem.l	A0/A5,-(SP)
	bsr.w	InstallBody
	movem.l	(SP)+,A0/A5
	tst.l	D0
	bmi.b	lbC00535E			; error

	MOVE.L	D0,$42(A0)			; sample ptr BODY
lbC0053B0	ADDQ.W	#1,D5
	CMP.W	#3,D5
	BLT.S	lbC00537E
lbC0053B8	ADDQ.W	#1,D4
	CMP.W	#$80,D4
	BLT.S	lbC00536A
	MOVEQ	#1,D0
	BRA.S	lbC005360


lbC009560	MOVEM.L	D1-D3,-(SP)
	MOVE.W	D1,D2
	MULU.W	D0,D2
	MOVE.L	D1,D3
	SWAP	D3
	MULU.W	D0,D3
	SWAP	D3
	CLR.W	D3
	ADD.L	D3,D2
	SWAP	D0
	MULU.W	D1,D0
	SWAP	D0
	CLR.W	D0
	ADD.L	D2,D0
	MOVEM.L	(SP)+,D1-D3
	RTS


lbC009A4A	MOVEM.L	D1/D4,-(SP)
	CLR.L	D4
	TST.L	D0
	BPL.S	lbC009A58
	NEG.L	D0
	ADDQ.W	#1,D4
lbC009A58	TST.L	D1
	BPL.S	lbC009A62
	NEG.L	D1
	EORI.W	#1,D4
lbC009A62	BSR.S	lbC009AA2
lbC009A64	TST.W	D4
	BEQ.S	lbC009A6A
	NEG.L	D0
lbC009A6A	MOVEM.L	(SP)+,D1/D4
	TST.L	D0
	RTS


lbC009AA2	MOVEM.L	D2/D3,-(SP)
	SWAP	D1
	TST.W	D1
	BNE.S	lbC009ACC
	SWAP	D1
	MOVE.W	D1,D3
	MOVE.W	D0,D2
	CLR.W	D0
	SWAP	D0
	DIVU.W	D3,D0
	MOVE.L	D0,D1
	SWAP	D0
	MOVE.W	D2,D1
	DIVU.W	D3,D1
	MOVE.W	D1,D0
	CLR.W	D1
	SWAP	D1
	MOVEM.L	(SP)+,D2/D3
	RTS

lbC009ACC	SWAP	D1
	MOVE.L	D1,D3
	MOVE.L	D0,D1
	CLR.W	D1
	SWAP	D1
	SWAP	D0
	CLR.W	D0
	MOVEQ	#15,D2
lbC009ADC	ADD.L	D0,D0
	ADDX.L	D1,D1
	CMP.L	D1,D3
	BHI.S	lbC009AE8
	SUB.L	D3,D1
	ADDQ.W	#1,D0
lbC009AE8	DBRA	D2,lbC009ADC
	MOVEM.L	(SP)+,D2/D3
	RTS

lbC00A798	JMP	lbC009560


lbW00B7DE	dc.w	$8000
	dc.w	$805E
	dc.w	$80BD
	dc.w	$811D
	dc.w	$817C
	dc.w	$81DC
	dc.w	$823C
	dc.w	$829D
	dc.w	$82FD
	dc.w	$835E
	dc.w	$83C0
	dc.w	$8421
	dc.w	$8483
	dc.w	$84E5
	dc.w	$8548
	dc.w	$85AA
	dc.w	$860D
	dc.w	$8670
	dc.w	$86D4
	dc.w	$8738
	dc.w	$879C
	dc.w	$8800
	dc.w	$8865
	dc.w	$88CA
	dc.w	$892F
	dc.w	$8995
	dc.w	$89FB
	dc.w	$8A61
	dc.w	$8AC7
	dc.w	$8B2E
	dc.w	$8B95
	dc.w	$8BFD
	dc.w	$8C64
	dc.w	$8CCC
	dc.w	$8D34
	dc.w	$8D9D
	dc.w	$8E06
	dc.w	$8E6F
	dc.w	$8ED8
	dc.w	$8F42
	dc.w	$8FAC
	dc.w	$9017
	dc.w	$9081
	dc.w	$90EC
	dc.w	$9158
	dc.w	$91C3
	dc.w	$922F
	dc.w	$929B
	dc.w	$9308
	dc.w	$9375
	dc.w	$93E2
	dc.w	$9450
	dc.w	$94BD
	dc.w	$952C
	dc.w	$959A
	dc.w	$9609
	dc.w	$9678
	dc.w	$96E7
	dc.w	$9757
	dc.w	$97C7
	dc.w	$9837
	dc.w	$98A8
	dc.w	$9919
	dc.w	$998B
	dc.w	$99FC
	dc.w	$9A6E
	dc.w	$9AE1
	dc.w	$9B53
	dc.w	$9BC6
	dc.w	$9C3A
	dc.w	$9CAD
	dc.w	$9D21
	dc.w	$9D96
	dc.w	$9E0A
	dc.w	$9E7F
	dc.w	$9EF5
	dc.w	$9F6A
	dc.w	$9FE0
	dc.w	$A057
	dc.w	$A0CE
	dc.w	$A145
	dc.w	$A1BC
	dc.w	$A234
	dc.w	$A2AC
	dc.w	$A324
	dc.w	$A39D
	dc.w	$A416
	dc.w	$A490
	dc.w	$A50A
	dc.w	$A584
	dc.w	$A5FE
	dc.w	$A679
	dc.w	$A6F5
	dc.w	$A770
	dc.w	$A7EC
	dc.w	$A868
	dc.w	$A8E5
	dc.w	$A962
	dc.w	$A9E0
	dc.w	$AA5D
	dc.w	$AADC
	dc.w	$AB5A
	dc.w	$ABD9
	dc.w	$AC58
	dc.w	$ACD8
	dc.w	$AD58
	dc.w	$ADD8
	dc.w	$AE59
	dc.w	$AEDA
	dc.w	$AF5B
	dc.w	$AFDD
	dc.w	$B05F
	dc.w	$B0E2
	dc.w	$B165
	dc.w	$B1E8
	dc.w	$B26C
	dc.w	$B2F0
	dc.w	$B375
	dc.w	$B3FA
	dc.w	$B47F
	dc.w	$B504
	dc.w	$B58A
	dc.w	$B611
	dc.w	$B698
	dc.w	$B71F
	dc.w	$B7A7
	dc.w	$B82E
	dc.w	$B8B7
	dc.w	$B940
	dc.w	$B9C9
	dc.w	$BA52
	dc.w	$BADC
	dc.w	$BB67
	dc.w	$BBF1
	dc.w	$BC7D
	dc.w	$BD08
	dc.w	$BD94
	dc.w	$BE20
	dc.w	$BEAD
	dc.w	$BF3A
	dc.w	$BFC8
	dc.w	$C056
	dc.w	$C0E4
	dc.w	$C173
	dc.w	$C203
	dc.w	$C292
	dc.w	$C322
	dc.w	$C3B3
	dc.w	$C444
	dc.w	$C4D5
	dc.w	$C567
	dc.w	$C5F9
	dc.w	$C68B
	dc.w	$C71E
	dc.w	$C7B2
	dc.w	$C846
	dc.w	$C8DA
	dc.w	$C96F
	dc.w	$CA04
	dc.w	$CA99
	dc.w	$CB2F
	dc.w	$CBC6
	dc.w	$CC5D
	dc.w	$CCF4
	dc.w	$CD8C
	dc.w	$CE24
	dc.w	$CEBD
	dc.w	$CF56
	dc.w	$CFEF
	dc.w	$D089
	dc.w	$D124
	dc.w	$D1BE
	dc.w	$D25A
	dc.w	$D2F6
	dc.w	$D392
	dc.w	$D42E
	dc.w	$D4CC
	dc.w	$D569
	dc.w	$D607
	dc.w	$D6A6
	dc.w	$D744
	dc.w	$D7E4
	dc.w	$D884
	dc.w	$D924
	dc.w	$D9C5
	dc.w	$DA66
	dc.w	$DB08
	dc.w	$DBAA
	dc.w	$DC4D
	dc.w	$DCF0
	dc.w	$DD93
	dc.w	$DE37
	dc.w	$DEDC
	dc.w	$DF81
	dc.w	$E026
	dc.w	$E0CC
	dc.w	$E173
	dc.w	$E21A
	dc.w	$E2C1
	dc.w	$E369
	dc.w	$E411
	dc.w	$E4BA
	dc.w	$E564
	dc.w	$E60E
	dc.w	$E6B8
	dc.w	$E763
	dc.w	$E80E
	dc.w	$E8BA
	dc.w	$E966
	dc.w	$EA13
	dc.w	$EAC0
	dc.w	$EB6E
	dc.w	$EC1C
	dc.w	$ECCB
	dc.w	$ED7B
	dc.w	$EE2A
	dc.w	$EEDB
	dc.w	$EF8C
	dc.w	$F03D
	dc.w	$F0EF
	dc.w	$F1A1
	dc.w	$F254
	dc.w	$F308
	dc.w	$F3BC
	dc.w	$F470
	dc.w	$F525
	dc.w	$F5DB
	dc.w	$F691
	dc.w	$F747
	dc.w	$F7FE
	dc.w	$F8B6
	dc.w	$F96E
	dc.w	$FA27
	dc.w	$FAE0
	dc.w	$FB9A
	dc.w	$FC54
	dc.w	$FD0F
	dc.w	$FDCA
	dc.w	$FE86
	dc.w	$FF43
;lbW00B9BE	dc.w	1
;lbW00B9C0	dc.w	0
;lbW00B9C2	dc.w	$FFFF
;audiodevice.MSG	dc.b	'audio.device',0
;SD_MusicInt.MSG	dc.b	'SD_MusicInt',0
;MusicInt.MSG	dc.b	'MusicInt',0
;ciabresource.MSG	dc.b	'ciab.resource',0
;IBLK.MSG	dc.b	'IBLK',0,0
;FORM.MSG	dc.b	'FORM',0
;VHDR.MSG	dc.b	'VHDR',0
;NAME.MSG	dc.b	'NAME',0
;ANNO.MSG	dc.b	'ANNO',0
;BODY.MSG	dc.b	'BODY',0,0

	Section	Buffy,BSS
WT
lbW00B9BE	ds.w	1
lbW00B9C0	ds.w	1
lbW00B9C2	ds.w	1

lbB00EBAE	ds.b	1
lbB00EBAF	ds.b	1
lbB00EBB0	ds.b	1
lbB00EBB1	ds.b	1
lbL00EBB2	ds.l	$17
lbL00EC0E	ds.l	3
	ds.b	1
lbB00EC1B	ds.b	$5B
;lbL00EC76	ds.l	1
;lbL00EC7A	ds.l	1
;lbL00EC7E	ds.l	1
;lbL00EC82	ds.l	1
;lbL00EC86	ds.l	1
;lbL00EC8A	ds.l	1
lbB00EC8E	ds.b	2
lbL00EC90	ds.l	1
lbL00EC94	ds.l	1
lbW00EC98	ds.w	1
;lbL00EC9A	ds.l	1
lbL00EC9E	ds.l	1
lbB00ECA2	ds.b	1
lbB00ECA3	ds.b	1
lbB00ECA4	ds.b	1
lbB00ECA5	ds.b	1
lbL00ECA6	ds.l	1
lbW00ECAA	ds.w	1
lbW00ECAC	ds.w	1
lbW00ECAE	ds.w	1
lbW00ECB0	ds.w	1
lbL00ECB2	ds.l	$80

	Section	Empty,BSS_C

lbL00EC9A	ds.l	1

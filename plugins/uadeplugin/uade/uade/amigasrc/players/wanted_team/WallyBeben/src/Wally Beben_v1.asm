	*****************************************************
	****     Wally Beben replayer for EaglePlayer	 ****
	****        all adaptions by Wanted Team,	 ****
	****      DeliTracker 2.32 compatible version	 ****
	*****************************************************

	incdir	"dh2:include/"
	include 'misc/eagleplayer2.01.i'

	SECTION	Player,CODE

	PLAYERHEADER Tags

	dc.b	'$VER: Wally Beben player module V1.0 (15 Dec 2002)',0
	even
Tags
	dc.l	DTP_PlayerVersion,1
	dc.l	EP_PlayerVersion,9
	dc.l	DTP_RequestDTVersion,'WT'
	dc.l	DTP_PlayerName,PlayerName
	dc.l	DTP_Creator,Creator
	dc.l	DTP_Check2,Check2
	dc.l	DTP_Interrupt,Interrupt
	dc.l	DTP_SubSongRange,SubSongRange
	dc.l	DTP_InitPlayer,InitPlayer
	dc.l	DTP_EndPlayer,EndPlayer
	dc.l	DTP_InitSound,InitSound
	dc.l	DTP_EndSound,EndSound
	dc.l	EP_Get_ModuleInfo,GetInfos
	dc.l	EP_ModuleChange,ModuleChange
	dc.l	EP_StructInit,StructInit
	dc.l	DTP_Volume,SetVolume
	dc.l	DTP_Balance,SetBalance
	dc.l	EP_Voices,SetVoices
	dc.l	EP_GetPositionNr,GetPosition
	dc.l	EP_SampleInit,SampleInit
	dc.l	EP_Flags,EPB_Songend!EPB_Volume!EPB_Balance!EPB_Voices!EPB_Analyzer!EPB_ModuleInfo!EPB_SampleInfo!EPB_Packable!EPB_Restart!EPB_PrevSong!EPB_NextSong
	dc.l	TAG_DONE
PlayerName
	dc.b	'Wally Beben',0
Creator
	dc.b	'(c) 1988-90 by Wally ''Hagar'' Beben,',10
	dc.b	'adapted by Wanted Team',0
Prefix
	dc.b	'WB.',0
	even
ModulePtr
	dc.l	0
SubSongPtr
	dc.l	0
SongsPtr
	dc.l	0
VoicesPtr
	dc.l	0
SamplesPtr
	dc.l	0
PeriodBase
	dc.l	0
ChangeLen
	dc.l	0
Change
	dc.w	0
EagleBase
	dc.l	0
SamplesLen
	dc.l	0
SongEnd
	dc.l	'WTWT'
Byte
	dc.w	0
EndFlag
	dc.w	0
RightVolume
	dc.w	64
LeftVolume
	dc.w	64
Voice1
	dc.w	-1
Voice2
	dc.w	-1
Voice3
	dc.w	-1
Voice4
	dc.w	-1
StructAdr
	ds.b	UPS_SizeOF

***************************************************************************
******************************* EP_SampleInit *****************************
***************************************************************************

SampleInit
	moveq	#EPR_NotEnoughMem,D7
	lea	EPG_SampleInfoStructure(A5),A3
	move.l	SamplesPtr(PC),D0
	beq.b	return
	move.l	D0,A2

	move.l	SamplesLen(PC),A4
	move.l	InfoBuffer+Samples(PC),D5
	subq.l	#1,D5
hop
	jsr	ENPP_AllocSampleStruct(A5)
	move.l	D0,(A3)
	beq.b	return
	move.l	D0,A3

	moveq	#0,D1
	move.w	2(A4),D1
	move.l	(A2)+,EPS_Adr(A3)		; sample address
	move.l	D1,EPS_Length(A3)		; sample length
	move.l	#64,EPS_Volume(A3)
	move.w	#USITY_RAW,EPS_Type(A3)
	move.w	#USIB_Playable!USIB_Saveable!USIB_8BIT,EPS_Flags(A3)
	addq.l	#8,A4
	dbf	D5,hop

	moveq	#0,D7
return
	move.l	D7,D0
	rts

***************************************************************************
**************************** EP_GetPositionNr *****************************
***************************************************************************

GetPosition
	moveq	#0,D0
	move.l	VoicesPtr(PC),A0
	add.w	Byte(PC),A0
	move.b	12(A0),D0
	rts

***************************************************************************
******************** DTP_Volume DTP_Balance *******************************
***************************************************************************

SetVolume
SetBalance
	move.w	dtg_SndLBal(A5),D0
	mulu.w	dtg_SndVol(A5),D0
	lsr.w	#6,D0

	move.w	D0,LeftVolume

	move.w	dtg_SndRBal(A5),D0
	mulu.w	dtg_SndVol(A5),D0
	lsr.w	#6,D0

	move.w	D0,RightVolume
	moveq	#0,D0
	rts

Left2
	mulu.w	LeftVolume(PC),D0
	and.w	Voice4(PC),D0
	lsr.w	#6,D0
	move.w	D0,UPS_Voice4Vol(A0)
	bra.s	Ex
Left1
	mulu.w	LeftVolume(PC),D0
	and.w	Voice1(PC),D0
	lsr.w	#6,D0
	move.w	D0,UPS_Voice1Vol(A0)
	bra.s	Ex
Right1
	mulu.w	RightVolume(PC),D0
	and.w	Voice2(PC),D0
	lsr.w	#6,D0
	move.w	D0,UPS_Voice2Vol(A0)
	bra.s	Ex
Right2
	mulu.w	RightVolume(PC),D0
	and.w	Voice3(PC),D0
	lsr.w	#6,D0
	move.w	D0,UPS_Voice3Vol(A0)
Ex
	rts

SetAdr
	move.l	A0,-(A7)
	lea	StructAdr(PC),A0
	tst.w	D6
	bne.b	.no_A
	move.l	D0,UPS_Voice1Adr(A0)
.no_A
	cmp.w	#$10,D6
	bne.b	.no_B
	move.l	D0,UPS_Voice2Adr(A0)
.no_B
	cmp.w	#$20,D6
	bne.b	.no_C
	move.l	D0,UPS_Voice3Adr(A0)
.no_C
	cmp.w	#$30,D6
	bne.b	.no_D
	move.l	D0,UPS_Voice4Adr(A0)
.no_D
	move.l	(A7)+,A0
	rts

SetTwo
	movem.l	D0/A0/A2,-(A7)
	lsr.w	#1,D0
	lea	StructAdr(PC),A0
	move.l	PeriodBase(PC),A2
	tst.w	D6
	bne.b	.no_A
	move.w	D0,UPS_Voice1Len(A0)
	move.w	(A2),UPS_Voice1Per(A0)
.no_A
	addq.l	#2,A2
	cmp.w	#$10,D6
	bne.b	.no_B
	move.w	D0,UPS_Voice2Len(A0)
	move.w	(A2),UPS_Voice2Per(A0)
.no_B
	addq.l	#2,A2
	cmp.w	#$20,D6
	bne.b	.no_C
	move.w	D0,UPS_Voice3Len(A0)
	move.w	(A2),UPS_Voice3Per(A0)
.no_C
	addq.l	#2,A2
	cmp.w	#$30,D6
	bne.b	.no_D
	move.w	D0,UPS_Voice4Len(A0)
	move.w	(A2),UPS_Voice4Per(A0)
.no_D
	movem.l	(A7)+,D0/A0/A2
	rts

***************************************************************************
****************************** EP_Voices  *********************************
***************************************************************************

SetVoices
	lea	Voice1(PC),A0
	lea	StructAdr(PC),A1
	move.w	#$FFFF,D1
	move.w	D1,(A0)+			Voice1=0 setzen
	btst	#0,D0
	bne.s	.NoVoice1
	clr.w	-2(A0)
	clr.w	$DFF0A8
	clr.w	UPS_Voice1Vol(A1)
.NoVoice1
	move.w	D1,(A0)+			Voice2=0 setzen
	btst	#1,D0
	bne.s	.NoVoice2
	clr.w	-2(A0)
	clr.w	$DFF0B8
	clr.w	UPS_Voice2Vol(A1)
.NoVoice2
	move.w	D1,(A0)+			Voice3=0 setzen
	btst	#2,D0
	bne.s	.NoVoice3
	clr.w	-2(A0)
	clr.w	$DFF0C8
	clr.w	UPS_Voice3Vol(A1)
.NoVoice3
	move.w	D1,(A0)+			Voice4=0 setzen
	btst	#3,D0
	bne.s	.NoVoice4
	clr.w	-2(A0)
	clr.w	$DFF0D8
	clr.w	UPS_Voice4Vol(A1)
.NoVoice4
	move.w	D0,UPS_DMACon(A1)
	moveq	#0,D0
	rts

***************************************************************************
******************************* EP_StructInit *****************************
***************************************************************************

StructInit
	lea	StructAdr(PC),A0
	rts

***************************************************************************
**************************** EP_ModuleChange ******************************
***************************************************************************

ModuleChange
	move.w	Change(PC),D0
	bne.s	NoChange
	move.l	ModulePtr(PC),EPG_ARG1(A5)
	lea	PatchTable(PC),A1
	move.l	A1,EPG_ARG3(A5)
	move.l	ChangeLen(PC),D1
	move.l	D1,EPG_ARG2(A5)
	moveq	#-2,D0
	move.l	D0,EPG_ARG5(A5)		
	moveq	#1,D0
	move.l	D0,EPG_ARG4(A5)			;Search-Modus
	moveq	#5,D0
	move.l	D0,EPG_ARGN(A5)
	move.l	EPG_ModuleChange(A5),A0
	jsr	(A0)
NoChange
	move.w	#1,Change
	moveq	#0,D0
	rts

***************************************************************************
******************************* DTP_Check2 ********************************
***************************************************************************

Check2
	movea.l	dtg_ChkData(A5),A0
	moveq	#-1,D0

	cmp.w	#$6000,(A0)+
	bne.b	Fault
	move.w	(A0)+,D1
	beq.b	Fault
	bmi.b	Fault
	btst	#0,D1
	bne.b	Fault
	lea	-2(A0,D1.W),A1
	cmp.b	#$61,(A1)+
	bne.b	Fault
	tst.b	(A1)+
	bne.b	Short
	addq.l	#2,A1
Short
	cmp.w	#$4239,(A1)
	bne.b	Fault
	addq.l	#6,A1
	cmp.w	#$4239,(A1)
	bne.b	Fault
	addq.l	#6,A1
	cmp.w	#$4E75,(A1)
	bne.b	Fault
	cmp.l	#$48E7FFFE,(A0)+
	bne.b	Fault
	cmp.w	#$6100,(A0)+
	bne.b	Fault
	add.w	(A0),A0
	cmp.l	#$4CF900FF,(A0)+
	beq.b	Found
	cmp.w	#$1039,(A0)
	bne.b	Fault
Found
	moveq	#0,D0
Fault
	rts

***************************************************************************
***************************** EP_Get_ModuleInfo ***************************
***************************************************************************

GetInfos
	lea	InfoBuffer(PC),A0
	rts

SubSongs	=	4
LoadSize	=	12
SongSize	=	20
Samples		=	28
CalcSize	=	36
SamplesSize	=	44
SpecialInfo	=	52
Length		=	60
Steps		=	68

InfoBuffer
	dc.l	MI_SubSongs,0		;4
	dc.l	MI_LoadSize,0		;12
	dc.l	MI_Songsize,0		;20
	dc.l	MI_Samples,0		;28
	dc.l	MI_Calcsize,0		;36
	dc.l	MI_SamplesSize,0	;44
	dc.l	MI_SpecialInfo,0	;52
	dc.l	MI_Length,0		;60
	dc.l	MI_Steps,0		;68
	dc.l	MI_MaxSteps,192
	dc.l	MI_Prefix,Prefix
	dc.l	0

***************************************************************************
***************************** DTP_Intterrupt ******************************
***************************************************************************

Interrupt	
	movem.l	D1-D7/A0-A6,-(SP)

	lea	StructAdr(PC),A0
	st	UPS_Enabled(A0)
	clr.w	UPS_Voice1Per(A0)
	clr.w	UPS_Voice2Per(A0)
	clr.w	UPS_Voice3Per(A0)
	clr.w	UPS_Voice4Per(A0)
	move.w	#UPSB_Adr!UPSB_Len!UPSB_Per!UPSB_Vol,UPS_Flags(A0)

	move.l	ModulePtr(PC),A0
	jsr	4(A0)			; play module

	lea	StructAdr(PC),A0
	clr.w	UPS_Enabled(A0)

	movem.l	(SP)+,D1-D7/A0-A6
	moveq	#0,D0
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
***************************** DTP_SubSongRange ****************************
***************************************************************************

SubSongRange	
	moveq	#1,D0
	move.l	InfoBuffer+SubSongs(PC),D1
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
	moveq	#0,D4				; moveq format
	cmp.w	#$4CF9,20(A0)
	bne.b	MoveqFormat
	moveq	#1,D4				; new format
MoveqFormat
	move.l	A0,A1
	move.l	A0,D6
FindIt0
	cmp.w	#$4E75,(A1)+
	bne.b	FindIt0
	move.l	A1,(A6)+			; SubSongPtr
	move.l	A1,D0
FindIt1
	cmp.w	#$1039,(A1)+
	bne.b	FindIt1
	move.l	(A1),D7
	sub.l	A0,D0
	sub.l	D0,D7				; origin
FindIt2
	cmp.w	#$223C,(A1)+
	bne.b	FindIt2
	move.l	(A1),D0
	subq.l	#1,D0
	move.l	D0,SubSongs(A4)
	cmp.w	#6,D0
	bne.b	FindIt6
	cmp.l	#$9298,3090(A0)
	bne.b	FindIt6
	cmp.w	#$FA0,3128(A0)
	bne.b	FindIt6
	moveq	#80,D1
	sub.l	D1,3090(A0)			; Circus Games fixes
	sub.w	D1,3128(A0)
FindIt6
	cmp.w	#$41F9,(A1)+
	bne.b	FindIt6
	move.l	(A1)+,A3
	sub.l	D7,A3
	add.l	A0,A3
	move.l	A3,(A6)+			; SongsPtr
	sub.l	D7,(A3)
	add.l	D6,(A3)
	lsl.l	#4,D0
	lea	(A3,D0.W),A2
	move.l	(A3)+,D1
RelocSongs
	sub.l	D7,(A3)
	add.l	D6,(A3)
	cmp.l	(A3),D1
	blt.b	MinVal
	move.l	(A3),D1
MinVal
	addq.l	#4,A3
	cmp.l	A3,A2
	bne.b	RelocSongs
	moveq	#0,D0
RelocPos
	addq.l	#1,D0
	sub.l	D7,(A2)
	add.l	D6,(A2)+
	cmp.l	A2,D1
	bne.b	RelocPos
	move.l	D0,Steps(A4)
FindIt7
	cmp.w	#$D1C1,(A1)+
	bne.b	FindIt7
	move.l	-6(A1),D0
	sub.l	D7,D0
	add.l	D6,D0
	move.l	D0,(A6)+			; VoicesPtr
	tst.l	D4
	beq.b	FindIt4
FindIt5
	cmp.l	#$3C363000,(A1)
	beq.b	Ok1
	addq.l	#2,A1
	bra.b	FindIt5
Ok1
	move.l	6(A1),A3
	sub.l	D7,A3
	add.l	A0,A3
	sub.l	D7,(A3)				; reloc empty sample
	add.l	D6,(A3)
	move.l	#$2C164E71,10(A1)		; fix [move.l (A6),D6 + nop]
FindIt4
	cmp.w	#$E584,(A1)+
	bne.b	FindIt4
	move.l	-6(A1),A2
	sub.l	D7,A2
	add.l	A0,A2
	move.l	A2,(A6)+			; SamplesPtr
FindIt3
	cmp.l	#$03580328,(A1)			; period table
	beq.b	Back1
	addq.l	#2,A1
	bra.b	FindIt3
Back1
	cmp.w	#$4E75,-(A1)
	bne.b	Back1
	move.l	A1,D5
	sub.l	A0,D5
Back2
	cmp.w	#$3280,-(A1)
	bne.b	Back2
	move.w	#$7000,D2
	cmp.w	#$D3F9,-6(A1)
	beq.b	NewStyle
	move.w	#$4280,D2
NewStyle
	move.l	6(A1),D0
	sub.l	D7,D0
	add.l	D6,D0
	move.l	D0,(A6)+			; PeriodBase
	move.l	D5,(A6)+			; Change Len
	clr.w	(A6)+				; Change
	move.l	A5,(A6)+			; EagleBase
Back3
	cmp.w	-(A1),D2
	bne.b	Back3
	cmp.w	#$4E75,-2(A1)
	bne.b	Back3
FindLea
	cmp.w	#$43F9,(A1)+
	bne.b	FindLea
	move.l	(A1),A1
	sub.l	D7,A1
	add.l	D6,A1
	move.l	A1,(A6)				; SamplesLen
	tst.l	D4
	bne.b	RelocSamp
	move.l	A1,A3
RelocSamp
	sub.l	D7,(A2)				; reloc samples
	add.l	D6,(A2)+
	cmp.l	A2,A3
	bne.b	RelocSamp
	moveq	#0,D0
Next
	cmp.b	(A1),D0
	bne.b	Exit
	tst.w	2(A1)
	beq.b	Exit
	addq.l	#1,D0
	addq.l	#8,A1
	bra.b	Next
Exit
	move.l	D0,Samples(A4)
	subq.l	#1,D0
	move.l	SamplesPtr(PC),A1
	move.l	(A1),D2
	move.l	D2,D1
	moveq	#0,D3
NextPtr
	cmp.l	(A1),D2
	ble.b	MinPtr
	move.l	(A1),D2
MinPtr
	cmp.l	(A1),D1
	bge.b	MaxPtr
	move.l	(A1),D1
	move.l	D3,D4
MaxPtr
	addq.l	#1,D3
	addq.l	#4,A1
	dbf	D0,NextPtr
	lsl.l	#3,D4
	move.l	SamplesLen(PC),A1
	move.w	2(A1,D4.W),D4
	sub.l	D2,D1
	add.l	D4,D1
	move.l	D1,SamplesSize(A4)
	sub.l	A0,D2
	btst	#0,D2
	beq.b	SamplesOK
	addq.l	#1,D2
	move.l	InfoBuffer+Samples(PC),D3
	subq.l	#1,D3
	move.l	SamplesPtr(PC),A1
NextPtr1
	addq.l	#1,(A1)+
	dbf	D3,NextPtr1
SamplesOK
	move.l	D2,SongSize(A4)
	add.l	D1,D2
	move.l	D2,CalcSize(A4)
	move.l	A0,A3
	add.l	D6,D5
Back
	cmp.w	#$0079,(A3)			; or.w   #$xx,$Address
	beq.w	Reloc2
	cmp.w	#$0239,(A3)			; and.b  #$xx,$Address
	beq.w	Reloc2
	cmp.w	#$03B9,(A3)			; bclr   D1,$Address
	beq.w	Reloc1
	cmp.w	#$03F9,(A3)			; bset   D1,$Address
	beq.w	Reloc1
	cmp.w	#$1039,(A3)			; move.b $Address,D0
	beq.w	Reloc1
	cmp.w	#$1239,(A3)			; move.b $Address,D1
	beq.w	Reloc1
	cmp.w	#$13C0,(A3)			; move.b D0,$Address
	beq.w	Reloc1
	cmp.w	#$13C4,(A3)			; move.b D4,$Address
	beq.w	Reloc1
	cmp.w	#$13C7,(A3)			; move.b D7,$Address
	beq.w	Reloc1
	cmp.w	#$13D0,(A3)			; move.b (A0),$Address
	beq.w	Reloc1
	cmp.w	#$13D3,(A3)			; move.b (A3),$Address
	beq.w	Reloc1
	cmp.w	#$13E8,(A3)			; move.b $xx(A0),$Address
	beq.w	Reloc2
	cmp.w	#$13EA,(A3)			; move.b $xx(A2),$Address
	beq.w	Reloc2
	cmp.w	#$13F9,(A3)			; move.b $Address,$Address
	beq.w	Reloc3
	cmp.w	#$13FC,(A3)			; move.b #$x,$Address
	beq.w	Reloc2
	cmp.w	#$1839,(A3)			; move.b $Address,D4
	beq.w	Reloc1
	cmp.w	#$1C39,(A3)			; move.b $Address,D6
	beq.w	Reloc1
	cmp.w	#$1E39,(A3)			; move.b $Address,D7
	beq.w	Reloc1
	cmp.w	#$23C2,(A3)			; move.l D2,$Address
	beq.w	Reloc1
	cmp.w	#$23D1,(A3)			; move.l (A1),$Address
	beq.w	Reloc1
	cmp.w	#$2679,(A3)			; move.l $Address,A3
	beq.w	Reloc1
	cmp.w	#$3039,(A3)			; move.w $Address,D0
	beq.w	Reloc1
	cmp.w	#$33C0,(A3)			; move.w D0,$Address
	beq.w	Reloc1
	cmp.w	#$33C4,(A3)			; move.w D4,$Address
	beq.w	Reloc1
	cmp.w	#$33C6,(A3)			; move.w D6,$Address
	beq.w	Reloc1
	cmp.w	#$33C5,(A3)			; move.w D5,$Address
	beq.w	Reloc1
	cmp.w	#$33D1,(A3)			; move.w (A1),$Address
	beq.w	Reloc1
	cmp.w	#$3839,(A3)			; move.w $Address,D4
	beq.w	Reloc1
	cmp.w	#$3A39,(A3)			; move.w $Address,D5
	beq.w	Reloc1
	cmp.w	#$3C39,(A3)			; move.w $Address,D6
	beq.w	Reloc1
	cmp.w	#$41F9,(A3)			; lea    $Address,A0
	beq.w	Reloc1
	cmp.w	#$4239,(A3)			; clr.b  $Address
	beq.w	Reloc1
	cmp.w	#$43F9,(A3)			; lea    $Address,A1
	beq.b	Reloc1
	cmp.w	#$45F9,(A3)			; lea    $Address,A2
	beq.b	Reloc1
	cmp.w	#$4A39,(A3)			; tst.b  $Address
	beq.b	Reloc1
	cmp.w	#$4BF9,(A3)			; lea    $Address,A5
	beq.b	Reloc1
	cmp.w	#$4CF9,(A3)			; movem.l ($Address),D0-D7
	beq.b	Reloc2
	cmp.w	#$4DF9,(A3)			; lea    $Address,A6
	beq.b	Reloc1
	cmp.w	#$4EF9,(A3)			; jmp    $Address
	beq.b	Reloc1
	cmp.w	#$5239,(A3)			; addq.b #1,$Address
	beq.b	Reloc1
	cmp.w	#$5279,(A3)			; addq.w #1,$Address
	beq.b	Reloc1
	cmp.w	#$5339,(A3)			; subq.b #1,$Address
	beq.b	Reloc1
	cmp.w	#$9039,(A3)			; sub.b  $Address,D0
	beq.b	Reloc1
	cmp.w	#$9079,(A3)			; sub.w  $Address,D0
	beq.b	Reloc1
	cmp.w	#$B039,(A3)			; cmp.b  $Address,D0
	beq.b	Reloc1
	cmp.w	#$D039,(A3)			; add.b  $Address,D0
	beq.b	Reloc1
	cmp.w	#$D079,(A3)			; add.w  $Address,D0
	beq.b	Reloc1
	cmp.w	#$D3F9,(A3)			; add.l  $Address,A1
	beq.b	Reloc1
	cmp.w	#$D5F9,(A3)			; add.l  $Address,A2
	beq.b	Reloc1
	cmp.w	#$DBF9,(A3)			; add.l  $Address,A5
	beq.b	Reloc1
	cmp.w	#$DDF9,(A3)			; add.l  $Address,A6
	beq.b	Reloc1
	cmp.w	#$E2F9,(A3)			; lsr.w  $Address
	beq.b	Reloc1
	addq.l	#2,A3
	cmp.l	A3,D5
	bne.w	Back
	bra.b	Later

Reloc2
	addq.l	#2,A3
Reloc1
	addq.l	#2,A3
	cmp.w	#$00DF,(A3)			; hardware check
	beq.w	Back
	sub.l	D7,(A3)
	add.l	D6,(A3)+
	bra.w	Back

Reloc3
	addq.l	#2,A3
	cmp.w	#$00DF,(A3)			; hardware check
	bne.b	NoHard
	addq.l	#4,A3
	bra.w	NextLong
NoHard
	sub.l	D7,(A3)
	add.l	D6,(A3)+
NextLong
	cmp.w	#$00DF,(A3)			; hardware check
	beq.w	Back
	sub.l	D7,(A3)
	add.l	D6,(A3)+
	bra.w	Back
Later
FindText
	cmp.w	#$2863,(A0)
	beq.b	InfoFound
	addq.l	#2,A0
	cmp.l	A0,D5
	bne.b	FindText
	sub.l	A0,A0
InfoFound
	move.l	A0,SpecialInfo(A4)

	bsr.w	ModuleChange

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
	lea	SongEnd(PC),A4
	move.l	#'WTWT',(A4)+
	move.w	dtg_SndNum(A5),D0
	move.l	SubSongPtr(PC),A0
	move.b	D0,(A0)
	subq.w	#1,D0
	lsl.w	#4,D0
	move.l	SongsPtr(PC),A1
	lea	(A1,D0.W),A1
	moveq	#3,D2
	moveq	#0,D4
	moveq	#-1,D5
NextPos
	addq.l	#1,D5
	move.l	(A1)+,A2
	moveq	#0,D3
FindEnd
	addq.l	#1,D3
	cmp.b	#$FF,(A2)+
	bne.b	FindEnd
	cmp.l	D3,D4
	bge.b	MaxLen
	move.l	D3,D4
	move.w	D5,(A4)				; Byte
MaxLen
	dbf	D2,NextPos
	lea	InfoBuffer(PC),A0
	move.l	D4,Length(A0)
	clr.w	2(A4)
	move.l	ModulePtr(PC),A0
	jsr	(A0)
	lea	EndFlag(PC),A0
	clr.w	(A0)
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

	*--------------- PatchTable for Wally Beben ------------------*

PatchTable
	dc.w	Code0-PatchTable,(Code0End-Code0)/2-1,Patch0-PatchTable
	dc.w	Code1-PatchTable,(Code1End-Code1)/2-1,Patch1-PatchTable
	dc.w	Code2-PatchTable,(Code2End-Code2)/2-1,Patch2-PatchTable
	dc.w	Code3-PatchTable,(Code3End-Code3)/2-1,Patch3-PatchTable
	dc.w	Code4-PatchTable,(Code4End-Code4)/2-1,Patch4-PatchTable
	dc.w	Code5-PatchTable,(Code5End-Code5)/2-1,Patch5-PatchTable
	dc.w	Code6-PatchTable,(Code6End-Code6)/2-1,Patch6-PatchTable
	dc.w	Code7-PatchTable,(Code7End-Code7)/2-1,Patch7-PatchTable
	dc.w	Code8-PatchTable,(Code8End-Code8)/2-1,Patch8-PatchTable
	dc.w	Code9-PatchTable,(Code9End-Code9)/2-1,Patch9-PatchTable
	dc.w	0

; DMA fix for Wally Beben (old) modules

Code0
	ORI.L	#$8200,D1
	MOVE.W	$DFF002,D0
	ANDI.W	#$5F0,D0
	OR.W	D0,D1
	MOVE.W	D1,$DFF096
	EORI.W	#$FFFF,D1
Code0End
	dc.l	0				 ; safety buffer ?
Patch0
	bsr.w	DMAWait
	or.w	#$8200,D1
	move.w	D1,$DFF096
	eor.w	#$820F,D1
	rts

; Volume patch for Wally Beben modules

Code1
	MOVE.W	D0,(A2)
	MOVE.B	(A1)+,D0
	MOVE.W	D0,$10(A2)
	MOVE.B	(A1)+,D0
	MOVE.W	D0,$20(A2)
	MOVE.B	(A1),D0
	MOVE.W	D0,$30(A2)
Code1End
Patch1
	move.l	A0,-(A7)
	lea	StructAdr(PC),A0
	bsr.w	Left1
	move.w	D0,(A2)
	move.b	(A1)+,D0
	bsr.w	Right1
	move.w	D0,$10(A2)
	move.b	(A1)+,D0
	bsr.w	Right2
	move.w	D0,$20(A2)
	move.b	(A1),D0
	bsr.w	Left2
	move.w	D0,$30(A2)
	move.l	(A7)+,A0
	rts

; SongEnd (stop) patch for Wally Beben modules

Code2
	MOVE.W	D0,$10(A5)
	MOVE.W	D0,$20(A5)
Code2End
Patch2
	move.w	D0,$10(A5)
	move.w	D0,$20(A5)
	tst.w	EndFlag
	beq.b	NoEnd2
	movem.l	A1/A5,-(A7)
	move.l	EagleBase(PC),A5
	move.l	dtg_SongEnd(A5),A1
	jsr	(A1)
	lea	StructAdr(PC),A5
	lea	UPS_SizeOF(A5),A1
ClearUPS2
	clr.w	(A5)+
	cmp.l	A5,A1
	bne.b	ClearUPS2
	movem.l	(A7)+,A1/A5
NoEnd2
	st	EndFlag
	rts


; Length patch for Wally Beben modules

Code3
	ANDI.L	#$FF,D6
Code3End
Patch3
	and.l	#$FF,D6
	bsr.w	SetTwo
	rts

; DMA wait patch for Wally Beben (new) modules

Code4
	MOVE.W	D1,$DFF096
	EORI.W	#$820F,D1
	MOVE.W	D1,$DFF096
Code4End
Patch4
	bsr.w	DMAWait
	move.w	D1,$DFF096
	eor.w	#$820F,D1
	move.w	D1,$DFF096
	bsr.w	DMAWait
	rts

; SongEnd patch for Wally Beben modules

Code5
	MOVE.B	12(A0),D0
	ADDQ.B	#1,12(A0)
	ADDA.L	D0,A1
Code5End
Patch5
	move.b	12(A0),D0
	addq.b	#1,12(A0)
	add.l	D0,A1
	cmp.b	#$FF,(A1)
	bne.b	NoEnd
	movem.l	A1/A5,-(A7)
	lea	SongEnd(PC),A1
	tst.b	(A0)
	bne.b	test1
	clr.b	(A1)
	bra.b	test
test1
	cmp.b	#$10,(A0)
	bne.b	test2
	clr.b	1(A1)
	bra.b	test
test2
	cmp.b	#$20,(A0)
	bne.b	test3
	clr.b	2(A1)
	bra.b	test
test3
	cmp.b	#$30,(A0)
	bne.b	test
	clr.b	3(A1)
test
	tst.l	(A1)
	bne.b	SkipEnd
	move.l	#'WTWT',(A1)
	move.l	EagleBase(PC),A5
	move.l	dtg_SongEnd(A5),A1
	jsr	(A1)
SkipEnd
	movem.l	(A7)+,A1/A5
NoEnd
	rts

; DMA wait patch for Wally Beben (old) modules

Code6
	MOVE.W	D1,$DFF096
Code6End
Patch6
	move.w	D1,$DFF096
	bsr.w	DMAWait
	rts

; Address patch for Wally Beben (new) modules

Code7
	LEA	$DFF0A0,A5
	MOVE.L	0(A1,D4.W),0(A5,D6.W)
Code7End
Patch7
	lea	$DFF0A0,A5
	move.l	0(A1,D4.W),0(A5,D6.W)
	move.l	D0,-(SP)
	move.l	0(A1,D4.W),D0
	bsr.w	SetAdr
	move.l	(SP)+,D0
	rts

; Address patch for Wally Beben (old) modules

Code8
	LEA	$DFF0A0,A5
	ADDA.L	D6,A5
Code8End
Patch8
	lea	$DFF0A0,A5
	add.l	D6,A5
	move.l	D0,-(SP)
	move.l	(A1),D0
	bsr.w	SetAdr
	move.l	(SP)+,D0
	rts

; Repeat sample offset fix for Wally Beben (old) modules

Code9
	ANDI.L	#$FFF,D6
Code9End
Patch9
	and.l	#$FFFF,D6
	rts

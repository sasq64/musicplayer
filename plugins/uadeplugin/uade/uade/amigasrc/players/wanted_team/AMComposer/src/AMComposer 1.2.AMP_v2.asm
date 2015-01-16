	*****************************************************
	****  	  A. M. Composer V1.2 replayer for	 ****
	****    EaglePlayer 2.00+ (Amplifier version),   ****
	****         all adaptions by Wanted Team        ****
	*****************************************************

	incdir	"dh2:include/"
	include 'misc/eagleplayer2.01.i'
	include	'misc/eagleplayerengine.i'
	include	'exec/exec_lib.i'

	SECTION	Player_Code,CODE

	EPPHEADER Tags

	dc.b	'$VER: A.M.Composer 1.2 player module V2.1 (20 Oct 2001)',0
	even
Tags
	dc.l	DTP_PlayerVersion,2<<16!1
	dc.l	EP_PlayerVersion,11
	dc.l	DTP_PlayerName,PlayerName
	dc.l	DTP_Creator,Creator
	dc.l	EP_Check5,Check5
	dc.l	DTP_InitPlayer,InitPlayer
	dc.l	DTP_InitSound,InitSound
	dc.l	EP_SampleInit,SampleInit
	dc.l	EP_NewModuleInfo,NewModuleInfo
	dc.l	EP_GetPositionNr,GetPosition
	dc.l	DTP_Interrupt,Interrupt
	dc.l	EP_InitAmplifier,InitAudstruct
	dc.l	EP_EagleBase,EagleBase
	dc.l	EP_Flags,EPB_ModuleInfo!EPB_SampleInfo!EPB_Packable!EPB_Restart!EPB_Songend
	dc.l	0

PlayerName
	dc.b	'A.M.Composer 1.2',0
Creator
	dc.b	'(c) 1989 by Marc Hawlitzeck,',10
	dc.b	'adapted by Mr.Larmer/Wanted Team',0
Prefix
	dc.b	'AMC.',0
	even
ModulePtr
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
	move.l	4.W,a6
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
	movem.l	D0/D1,-(SP)
	move.w	D0,D1
	and.w	#$8000,d0	;D0.w neg=enable ; 0/pos=disable
	and.l	#15,D1		;D1 = Maske (LONG !!)
	jsr	ENPP_DMAMask(a5)
	movem.l	(SP)+,D0/D1
	rts

LED_Off
	movem.l	D0/D1,-(SP)
	moveq	#1,D0
	moveq	#0,D1
	jsr	ENPP_PokeCommand(A5)
	movem.l	(SP)+,D0/D1
	rts

LED_On
	movem.l	D0/D1,-(SP)
	moveq	#1,D0
	moveq	#1,D1
	jsr	ENPP_PokeCommand(A5)
	movem.l	(SP)+,D0/D1
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

	lea	72(A2),A2
	moveq	#-1,D5
	add.l	InfoBuffer+Samples(PC),D5
hop
	jsr	ENPP_AllocSampleStruct(A5)
	move.l	D0,(A3)
	beq.b	return
	move.l	D0,A3

	move.l	ModulePtr(PC),A1
	add.l	(A2),A1
	move.l	A1,EPS_Adr(A3)		; sample address
	moveq	#0,D0
	move.w	4(A2),D0
	lsl.l	#1,D0
	move.l	D0,EPS_Length(A3)		; sample length
	move.l	#64,EPS_Volume(A3)
	move.w	#USITY_RAW,EPS_Type(A3)
	move.w	#USIB_Playable!USIB_Saveable!USIB_8BIT,EPS_Flags(A3)

	addq.l	#8,A2
	addq.l	#8,A2

	dbf	D5,hop

	moveq	#0,D7
return
	move.l	D7,D0
	rts

***************************************************************************
***************************** EP_GetPositionNr ****************************
***************************************************************************

GetPosition
	move.l	CurrentPos1(PC),D0
	move.l	ModulePtr(PC),A0
	sub.l	24(A0),D0
	lsr.w	#7,D0
	rts

***************************************************************************
***************************** EP_NewModuleInfo ****************************
***************************************************************************

NewModuleInfo

LoadSize	=	4
CalcSize	=	12
Length		=	20
SamplesSize	=	28
SongSize	=	36
Samples		=	44
SpecialInfo	=	52

InfoBuffer
	dc.l	MI_LoadSize,0		;4
	dc.l	MI_Calcsize,0		;12
	dc.l	MI_Length,0		;20
	dc.l	MI_SamplesSize,0	;28
	dc.l	MI_Songsize,0		;36
	dc.l	MI_Samples,0		;44
	dc.l	MI_SpecialInfo,0	;56
	dc.l	MI_Prefix,Prefix
	dc.l	0

***************************************************************************
******************************** EP_Check5 ********************************
***************************************************************************

Check5
	movea.l	dtg_ChkData(A5),A0
	moveq	#-1,D0

	cmpi.l	#'AMC ',(A0)+
	bne.s	Fault

	cmpi.l	#'V1.2',(A0)+
	bne.s	Fault

	cmpi.l	#' REP',(A0)+
	bne.s	Fault

	cmpi.l	#'LAY!',(A0)+
	bne.s	Fault

	tst.w	8(A0)
	bne.s	Fault

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

	lea	ModulePtr(PC),A4
	move.l	A0,(A4)				; module ptr

	move.l	A0,lbL00059C

	lea	InfoBuffer(PC),A1
	move.l	D0,LoadSize(A1)
	clr.l	SpecialInfo(A1)

	move.l	ModulePtr(PC),A2
	move.l	A2,A3
	move.l	20(A2),D0
	move.l	D0,SongSize(A1)
	move.l	24(A2),D1
	add.l	D1,A3

	moveq	#0,D3
	lea	72(A2),A0
GetSize
	move.l	(A0)+,D2
	moveq	#0,D4
	move.w	(A0),D4
	add.l	D4,D4
	add.l	D4,D2
	cmp.l	D2,D3
	bge.b	MaxSize
	move.l	D2,D3
MaxSize
	lea	12(A0),A0
	cmp.l	A0,A3
	bne.b	GetSize
	move.l	28(A2),D2

	cmp.l	LoadSize(A1),D3
	beq.b	SizeOK
	cmp.l	LoadSize(A1),D3
	blt.b	ExtText
	moveq	#EPR_ModuleTooShort,D0		; error message
	rts
ExtText
	add.l	D3,A2
	cmp.b	#$20,39(A2)
	bne.b	SizeOK
	move.b	#10,39(A2)
	move.l	A2,SpecialInfo(A1)
	moveq	#62,D4
	add.l	D4,SongSize(A1)
	add.l	D4,D3
SizeOK
	move.l	D3,CalcSize(A1)
	sub.l	D0,D3
	move.l	D3,SamplesSize(A1)
	sub.l	D1,D2
	lsr.l	#4,D1
	subq.l	#4,D1
	move.l	D1,Samples(A1)
	lsr.l	#7,D2
	addq.l	#1,D2
	move.l	D2,Length(A1)

	moveq	#0,D0
	rts

***************************************************************************
***************************** DTP_InitSound *******************************
***************************************************************************

InitSound
	bsr.w	Init
	move.b	TimerH(PC),dtg_Timer(A5)
	clr.b	dtg_Timer+1(A5)
	rts

***************************************************************************
***************************** DTP_Intterrupt ******************************
***************************************************************************

Interrupt
	movem.l	D1-D7/A0-A6,-(SP)

	move.l	EagleBase(PC),A5

	bsr.w	Play

	jsr	ENPP_Amplifier(A5)

	movem.l	(SP)+,D1-D7/A0-A6
	moveq	#0,D0
	rts

***************************************************************************
************************** A. M. Composer V1.2 player *********************
***************************************************************************

; player from game Magic Jumper

Init
	movea.l	lbL00059C(PC),A4
	move.l	A4,D0
	cmp.l	$18(A4),D0
	bcs.s	lbC00002C
	add.l	D0,$18(A4)
	add.l	D0,$1C(A4)
	add.l	D0,$20(A4)
	add.l	D0,$24(A4)
	add.l	D0,$28(A4)
	add.l	D0,$2C(A4)
	add.l	D0,$30(A4)
	add.l	D0,$34(A4)
lbC00002C
	lea	lbL0005A0(pc),A1
	move.l	$18(A4),$54DA-$54DA(A1)
	move.l	$1C(A4),$54DE-$54DA(A1)
	move.l	$20(A4),$54E2-$54DA(A1)
	move.l	$24(A4),$54E6-$54DA(A1)
	move.l	$28(A4),$54EA-$54DA(A1)
	move.l	$2C(A4),$54EE-$54DA(A1)
	move.l	$30(A4),$54F2-$54DA(A1)
	move.l	$34(A4),$54F6-$54DA(A1)
	move.b	$39(A4),$550E-$54DA(A1)
	clr.w	$550A-$54DA(A1)
	clr.l	$54FA-$54DA(A1)
	clr.l	$54FE-$54DA(A1)
	clr.l	$5502-$54DA(A1)
	clr.l	$5506-$54DA(A1)
	clr.w	$5514-$54DA(A1)
	clr.w	$551E-$54DA(A1)
	clr.w	$5528-$54DA(A1)
	clr.w	$5532-$54DA(A1)
	clr.w	$553A-$54DA(A1)
	clr.w	$554E-$54DA(A1)
	clr.w	$5562-$54DA(A1)
	clr.w	$5576-$54DA(A1)
	rts

;StartTimer
;	lea	$DFF000,A6
;	move.w	#0,$A8(A6)
;	move.w	#0,$B8(A6)
;	move.w	#0,$C8(A6)
;	move.w	#0,$D8(A6)
;	move.w	#$800F,$96(A6)
;	move.b	lbB0005D4(PC),$BFD500
;	move.b	#0,$BFD400
;	move.b	#$7F,$BFDD00
;	move.b	#$81,$BFDD00
;	move.b	#$2F,$BFDE00
;	move.b	#$81,$BFDE00
;	rts
;StopTimer
;	move.b	#1,$BFDD00
;	lea	$DFF000,A6
;	move.w	#0,$A8(A6)
;	move.w	#0,$B8(A6)
;	move.w	#0,$C8(A6)
;	move.w	#0,$D8(A6)
;	move.w	#15,$96(A6)
;	rts

Play
;	lea	$DFF000,A6
	movea.l	lbL00059C(PC),A4
	lea	lbL00059C(PC),A1
	move.w	#$8000,D0
	or.b	lbB0005D2(PC),D0
;	move.w	D0,$96(A6)

	BSR.W	PokeDMA

	tst.w	$5DA-$59C(A1)
	beq.s	lbC00003A
	subq.w	#1,$5DA-$59C(A1)
	beq.s	lbC00003A
	subq.b	#1,$5DE-$59C(A1)
	bne.s	lbC00003A
	move.b	lbB0005DC(PC),$5DE-$59C(A1)
	move.w	lbW0005D8(PC),D0
	sub.w	D0,$5E0-$59C(A1)
;	move.w	lbW0005E0(PC),$A6(A6)

	MOVEQ	#0,D1					; channel 0
	MOVE.L	D0,-(A7)
	MOVE.W	lbW0005E0(PC),D0
	JSR	ENPP_PokePer(A5)
	MOVE.L	(A7)+,D0

lbC00003A
	tst.b	$600-$59C(A1)
	beq.s	lbC000060
	subq.b	#1,$600-$59C(A1)
	lea	lbL000604(PC),A3
	move.w	lbW000602(PC),D0
;	move.w	0(A3,D0.W),$A6(A6)

	MOVEQ	#0,D1					; channel 0
	MOVE.L	D0,-(A7)
	MOVE.W	0(A3,D0.W),D0
	JSR	ENPP_PokePer(A5)
	MOVE.L	(A7)+,D0

	addq.w	#2,D0
	cmpi.w	#$10,D0
	bne.s	lbC00005C
	moveq	#0,D0
lbC00005C
	move.w	D0,$602-$59C(A1)
lbC000060
	tst.w	$5E4-$59C(A1)
	beq.s	lbC000086
	subq.w	#1,$5E4-$59C(A1)
	beq.s	lbC000086
	subq.b	#1,$5E8-$59C(A1)
	bne.s	lbC000086
	move.b	lbB0005E6(PC),$5E8-$59C(A1)
	move.w	lbW0005E2(PC),D0
	sub.w	D0,$5EA-$59C(A1)
;	move.w	lbW0005EA(PC),$B6(A6)

	MOVEQ	#1,D1					; channel 1
	MOVE.L	D0,-(A7)
	MOVE.W	lbW0005EA(PC),D0
	JSR	ENPP_PokePer(A5)
	MOVE.L	(A7)+,D0

lbC000086
	tst.b	$614-$59C(A1)
	beq.s	lbC0000AC
	subq.b	#1,$614-$59C(A1)
	lea	lbL000618(PC),A3
	move.w	lbW000616(PC),D0
;	move.w	0(A3,D0.W),$B6(A6)

	MOVEQ	#1,D1					; channel 1
	MOVE.L	D0,-(A7)
	MOVE.W	0(A3,D0.W),D0
	JSR	ENPP_PokePer(A5)
	MOVE.L	(A7)+,D0

	addq.w	#2,D0
	cmpi.w	#$10,D0
	bne.s	lbC0000A8
	moveq	#0,D0
lbC0000A8
	move.w	D0,$616-$59C(A1)
lbC0000AC
	tst.w	$5EE-$59C(A1)
	beq.s	lbC0000D2
	subq.w	#1,$5EE-$59C(A1)
	beq.s	lbC0000D2
	subq.b	#1,$5F2-$59C(A1)
	bne.s	lbC0000D2
	move.b	lbB0005F0(PC),$5F2-$59C(A1)
	move.w	lbW0005EC(PC),D0
	sub.w	D0,$5F4-$59C(A1)
;	move.w	lbW0005F4(PC),$C6(A6)

	MOVEQ	#2,D1					; channel 2
	MOVE.L	D0,-(A7)
	MOVE.W	lbW0005F4(PC),D0
	JSR	ENPP_PokePer(A5)
	MOVE.L	(A7)+,D0

lbC0000D2
	tst.b	$628-$59C(A1)
	beq.s	lbC0000F8
	subq.b	#1,$628-$59C(A1)
	lea	lbL00062C(PC),A3
	move.w	lbW00062A(PC),D0
;	move.w	0(A3,D0.W),$C6(A6)

	MOVEQ	#2,D1					; channel 2
	MOVE.L	D0,-(A7)
	MOVE.W	0(A3,D0.W),D0
	JSR	ENPP_PokePer(A5)
	MOVE.L	(A7)+,D0

	addq.w	#2,D0
	cmpi.w	#$10,D0
	bne.s	lbC0000F4
	moveq	#0,D0
lbC0000F4
	move.w	D0,$62A-$59C(A1)
lbC0000F8
	tst.w	$5F8-$59C(A1)
	beq.s	lbC00011E
	subq.w	#1,$5F8-$59C(A1)
	beq.s	lbC00011E
	subq.b	#1,$5FC-$59C(A1)
	bne.s	lbC00011E
	move.b	lbB0005FA(PC),$5FC-$59C(A1)
	move.w	lbW0005F6(PC),D0
	sub.w	D0,$5FE-$59C(A1)
;	move.w	lbW0005FE(PC),$D6(A6)

	MOVEQ	#3,D1					; channel 3
	MOVE.L	D0,-(A7)
	MOVE.W	lbW0005FE(PC),D0
	JSR	ENPP_PokePer(A5)
	MOVE.L	(A7)+,D0

lbC00011E
	tst.b	$63C-$59C(A1)
	beq.s	lbC000144
	subq.b	#1,$63C-$59C(A1)
	lea	lbL000640(PC),A3
	move.w	lbW00063E(PC),D0
;	move.w	0(A3,D0.W),$D6(A6)

	MOVEQ	#3,D1					; channel 3
	MOVE.L	D0,-(A7)
	MOVE.W	0(A3,D0.W),D0
	JSR	ENPP_PokePer(A5)
	MOVE.L	(A7)+,D0

	addq.w	#2,D0
	cmpi.w	#$10,D0
	bne.s	lbC000140
	moveq	#0,D0
lbC000140
	move.w	D0,$63E-$59C(A1)
lbC000144
;	move.w	#$1F4,D0
;lbC000148
;	dbra	D0,lbC000148
	btst	#0,$5D2-$59C(A1)
	beq.s	lbC000164
	movea.l	lbL0005C0(PC),A3
	move.l	(A3)+,D0
	add.l	A4,D0
;	move.l	D0,$A0(A6)
;	move.w	(A3)+,$A4(A6)

	MOVEQ	#0,D1					; channel 0
	JSR	ENPP_PokeAdr(A5)
	MOVE.L	D0,-(A7)
	MOVEQ	#0,D0
	MOVE.W	(A3)+,D0
	JSR	ENPP_PokeLen(A5)
	MOVE.L	(A7)+,D0

lbC000164
	btst	#1,$5D2-$59C(A1)
	beq.s	lbC00017C
	movea.l	lbL0005C4(PC),A3
	move.l	(A3)+,D0
	add.l	A4,D0
;	move.l	D0,$B0(A6)
;	move.w	(A3)+,$B4(A6)

	MOVEQ	#1,D1					; channel 1
	JSR	ENPP_PokeAdr(A5)
	MOVE.L	D0,-(A7)
	MOVEQ	#0,D0
	MOVE.W	(A3)+,D0
	JSR	ENPP_PokeLen(A5)
	MOVE.L	(A7)+,D0

lbC00017C
	btst	#2,$5D2-$59C(A1)
	beq.s	lbC000194
	movea.l	lbL0005C8(PC),A3
	move.l	(A3)+,D0
	add.l	A4,D0
;	move.l	D0,$C0(A6)
;	move.w	(A3)+,$C4(A6)

	MOVEQ	#2,D1					; channel 2
	JSR	ENPP_PokeAdr(A5)
	MOVE.L	D0,-(A7)
	MOVEQ	#0,D0
	MOVE.W	(A3)+,D0
	JSR	ENPP_PokeLen(A5)
	MOVE.L	(A7)+,D0

lbC000194
	btst	#3,$5D2-$59C(A1)
	beq.s	lbC0001AC
	movea.l	lbL0005CC(PC),A3
	move.l	(A3)+,D0
	add.l	A4,D0
;	move.l	D0,$D0(A6)
;	move.w	(A3)+,$D4(A6)

	MOVEQ	#3,D1					; channel 3
	JSR	ENPP_PokeAdr(A5)
	MOVE.L	D0,-(A7)
	MOVEQ	#0,D0
	MOVE.W	(A3)+,D0
	JSR	ENPP_PokeLen(A5)
	MOVE.L	(A7)+,D0

lbC0001AC
	clr.w	$5D2-$59C(A1)
	addq.w	#1,$5D6-$59C(A1)
	cmpi.w	#4,$5D6-$59C(A1)
	bne.w	lbC00040A
	clr.w	$5D6-$59C(A1)
	addq.w	#1,$5D0-$59C(A1)
	move.w	lbW0005D0(PC),D4
	cmp.w	$10(A4),D4
	bne.s	lbC00020A

	MOVE.L	dtg_SongEnd(A5),A6
	JSR	(A6)

	move.l	$18(A4),$5A0-$59C(A1)
	move.l	$1C(A4),$5A4-$59C(A1)
	move.l	$20(A4),$5A8-$59C(A1)
	move.l	$24(A4),$5AC-$59C(A1)
	move.l	$28(A4),$5B0-$59C(A1)
	move.l	$2C(A4),$5B4-$59C(A1)
	move.l	$30(A4),$5B8-$59C(A1)
	move.l	$34(A4),$5BC-$59C(A1)
	clr.w	$5D0-$59C(A1)
	clr.w	$5D6-$59C(A1)
	moveq	#0,D4
lbC00020A
	movea.l	lbL0005A0(PC),A0
	cmp.w	(A0)+,D4
	bne.s	lbC000254
	clr.w	$600-$59C(A1)
	clr.w	$5DA-$59C(A1)
;	move.w	#1,$96(A6)

	MOVEQ	#1,D0
	BSR.W	PokeDMA

	bset	#0,$5D2-$59C(A1)
	lea	$48(A4),A3
	moveq	#0,D0
	move.b	(A0)+,D0
	subq.w	#1,D0
	lsl.w	#4,D0
	adda.l	D0,A3
	move.l	(A3)+,D0
	add.l	A4,D0
;	move.l	D0,$A0(A6)
;	move.w	(A3)+,$A4(A6)

	MOVEQ	#0,D1					; channel 0
	JSR	ENPP_PokeAdr(A5)
	MOVE.L	D0,-(A7)
	MOVEQ	#0,D0
	MOVE.W	(A3)+,D0
	JSR	ENPP_PokeLen(A5)
	MOVE.L	(A7)+,D0

	move.l	A3,$5C0-$59C(A1)
	moveq	#0,D0
	move.b	(A0)+,D0
;	move.w	D0,$A8(A6)
;	move.w	(A0)+,$A6(A6)

	JSR	ENPP_PokeVol(A5)
	MOVE.L	D0,-(A7)
	MOVE.W	(A0)+,D0
	JSR	ENPP_PokePer(A5)
	MOVE.L	(A7)+,D0

	move.l	A0,$5A0-$59C(A1)
lbC000254
	movea.l	lbL0005A4(PC),A0
	cmp.w	(A0)+,D4
	bne.s	lbC00029E
	clr.w	$614-$59C(A1)
	clr.w	$5E4-$59C(A1)
;	move.w	#2,$96(A6)

	MOVEQ	#2,D0
	BSR.W	PokeDMA

	bset	#1,$5D2-$59C(A1)
	lea	$48(A4),A3
	moveq	#0,D0
	move.b	(A0)+,D0
	subq.w	#1,D0
	lsl.w	#4,D0
	adda.l	D0,A3
	move.l	(A3)+,D0
	add.l	A4,D0
;	move.l	D0,$B0(A6)
;	move.w	(A3)+,$B4(A6)

	MOVEQ	#1,D1					; channel 1
	JSR	ENPP_PokeAdr(A5)
	MOVE.L	D0,-(A7)
	MOVEQ	#0,D0
	MOVE.W	(A3)+,D0
	JSR	ENPP_PokeLen(A5)
	MOVE.L	(A7)+,D0

	move.l	A3,$5C4-$59C(A1)
	moveq	#0,D0
	move.b	(A0)+,D0
;	move.w	D0,$B8(A6)
;	move.w	(A0)+,$B6(A6)

	JSR	ENPP_PokeVol(A5)
	MOVE.L	D0,-(A7)
	MOVE.W	(A0)+,D0
	JSR	ENPP_PokePer(A5)
	MOVE.L	(A7)+,D0

	move.l	A0,$5A4-$59C(A1)
lbC00029E
	movea.l	lbL0005A8(PC),A0
	cmp.w	(A0)+,D4
	bne.s	lbC0002E8
	clr.w	$628-$59C(A1)
	clr.w	$5EE-$59C(A1)
;	move.w	#4,$96(A6)

	MOVEQ	#4,D0
	BSR.W	PokeDMA

	bset	#2,$5D2-$59C(A1)
	lea	$48(A4),A3
	moveq	#0,D0
	move.b	(A0)+,D0
	subq.w	#1,D0
	lsl.w	#4,D0
	adda.l	D0,A3
	move.l	(A3)+,D0
	add.l	A4,D0
;	move.l	D0,$C0(A6)
;	move.w	(A3)+,$C4(A6)

	MOVEQ	#2,D1					; channel 2
	JSR	ENPP_PokeAdr(A5)
	MOVE.L	D0,-(A7)
	MOVEQ	#0,D0
	MOVE.W	(A3)+,D0
	JSR	ENPP_PokeLen(A5)
	MOVE.L	(A7)+,D0

	move.l	A3,$5C8-$59C(A1)
	moveq	#0,D0
	move.b	(A0)+,D0
;	move.w	D0,$C8(A6)
;	move.w	(A0)+,$C6(A6)

	JSR	ENPP_PokeVol(A5)
	MOVE.L	D0,-(A7)
	MOVE.W	(A0)+,D0
	JSR	ENPP_PokePer(A5)
	MOVE.L	(A7)+,D0

	move.l	A0,$5A8-$59C(A1)
lbC0002E8
	movea.l	lbL0005AC(PC),A0
	cmp.w	(A0)+,D4
	bne.s	lbC000332
	clr.w	$63C-$59C(A1)
	clr.w	$5F8-$59C(A1)
;	move.w	#8,$96(A6)

	MOVEQ	#8,D0
	BSR.W	PokeDMA

	bset	#3,$5D2-$59C(A1)
	lea	$48(A4),A3
	moveq	#0,D0
	move.b	(A0)+,D0
	subq.w	#1,D0
	lsl.w	#4,D0
	adda.l	D0,A3
	move.l	(A3)+,D0
	add.l	A4,D0
;	move.l	D0,$D0(A6)
;	move.w	(A3)+,$D4(A6)

	MOVEQ	#3,D1					; channel 3
	JSR	ENPP_PokeAdr(A5)
	MOVE.L	D0,-(A7)
	MOVEQ	#0,D0
	MOVE.W	(A3)+,D0
	JSR	ENPP_PokeLen(A5)
	MOVE.L	(A7)+,D0

	move.l	A3,$5CC-$59C(A1)
	moveq	#0,D0
	move.b	(A0)+,D0
;	move.w	D0,$D8(A6)
;	move.w	(A0)+,$D6(A6)

	JSR	ENPP_PokeVol(A5)
	MOVE.L	D0,-(A7)
	MOVE.W	(A0)+,D0
	JSR	ENPP_PokePer(A5)
	MOVE.L	(A7)+,D0

	move.l	A0,$5AC-$59C(A1)
lbC000332
	movea.l	lbL0005B0(PC),A0
	cmp.w	(A0)+,D4
	bne.s	lbC000368
	move.b	(A0)+,D0
	cmpi.b	#1,D0
	beq.w	lbC00040C
	cmpi.b	#2,D0
	beq.w	lbC000416
	cmpi.b	#3,D0
	beq.w	lbC00042E
	cmpi.b	#4,D0
	beq.w	lbC000438
	cmpi.b	#7,D0
	beq.w	lbC000456
lbC000364
	move.l	A0,$5B0-$59C(A1)
lbC000368
	movea.l	lbL0005B4(PC),A0
	cmp.w	(A0)+,D4
	bne.s	lbC00039E
	move.b	(A0)+,D0
	cmpi.b	#1,D0
	beq.w	lbC000470
	cmpi.b	#2,D0
	beq.w	lbC00047A
	cmpi.b	#3,D0
	beq.w	lbC000492
	cmpi.b	#4,D0
	beq.w	lbC00049C
	cmpi.b	#7,D0
	beq.w	lbC0004BA
lbC00039A
	move.l	A0,$5B4-$59C(A1)
lbC00039E
	movea.l	lbL0005B8(PC),A0
	cmp.w	(A0)+,D4
	bne.s	lbC0003D4
	move.b	(A0)+,D0
	cmpi.b	#1,D0
	beq.w	lbC0004D4
	cmpi.b	#2,D0
	beq.w	lbC0004DE
	cmpi.b	#3,D0
	beq.w	lbC0004F6
	cmpi.b	#4,D0
	beq.w	lbC000500
	cmpi.b	#7,D0
	beq.w	lbC00051E
lbC0003D0
	move.l	A0,$5B8-$59C(A1)
lbC0003D4
	movea.l	lbL0005BC(PC),A0
	cmp.w	(A0)+,D4
	bne.s	lbC00040A
	move.b	(A0)+,D0
	cmpi.b	#1,D0
	beq.w	lbC000538
	cmpi.b	#2,D0
	beq.w	lbC000542
	cmpi.b	#3,D0
	beq.w	lbC00055A
	cmpi.b	#4,D0
	beq.w	lbC000564
	cmpi.b	#7,D0
	beq.w	lbC000582
lbC000406
	move.l	A0,$5BC-$59C(A1)
lbC00040A
	rts

lbC00040C
	addq.l	#1,A0
;	move.w	(A0)+,$A6(A6)

	MOVEQ	#0,D1					; channel 0
	MOVE.L	D0,-(A7)
	MOVE.W	(A0)+,D0
	JSR	ENPP_PokePer(A5)
	MOVE.L	(A7)+,D0

	bra.w	lbC000364

lbC000416
	clr.w	$600-$59C(A1)
	move.b	(A0),$5DE-$59C(A1)
	move.b	(A0)+,$5DC-$59C(A1)
	move.l	(A0)+,$5D8-$59C(A1)
	move.w	(A0)+,$5E0-$59C(A1)
	bra.w	lbC000364

lbC00042E
	addq.l	#1,A0
;	move.w	(A0)+,$A8(A6)

	MOVEQ	#0,D1					; channel 0
	MOVE.L	D0,-(A7)
	MOVE.W	(A0)+,D0
	JSR	ENPP_PokeVol(A5)
	MOVE.L	(A7)+,D0

	bra.w	lbC000364

lbC000438
	clr.w	$5DA-$59C(A1)
	move.b	(A0)+,$600-$59C(A1)
	lea	lbL000604(PC),A3
	moveq	#7,D0
lbC000446
	move.w	(A0)+,(A3)+
	dbra	D0,lbC000446
	move.w	#2,$602-$59C(A1)
	bra.w	lbC000364

lbC000456
	tst.b	(A0)+
	bne.s	lbC000464
;	bset	#1,$BFE001

	BSR.W	LED_Off

	bra.s	lbC00046C

lbC000464
;	bclr	#1,$BFE001

	BSR.W	LED_On

lbC00046C
	bra.w	lbC000364

lbC000470
	addq.l	#1,A0
;	move.w	(A0)+,$B6(A6)

	MOVEQ	#1,D1					; channel 1
	MOVE.L	D0,-(A7)
	MOVE.W	(A0)+,D0
	JSR	ENPP_PokePer(A5)
	MOVE.L	(A7)+,D0

	bra.w	lbC00039A

lbC00047A
	clr.w	$614-$59C(A1)
	move.b	(A0),$5E8-$59C(A1)
	move.b	(A0)+,$5E6-$59C(A1)
	move.l	(A0)+,$5E2-$59C(A1)
	move.w	(A0)+,$5EA-$59C(A1)
	bra.w	lbC00039A

lbC000492
	addq.l	#1,A0
;	move.w	(A0)+,$B8(A6)

	MOVEQ	#1,D1					; channel 1
	MOVE.L	D0,-(A7)
	MOVE.W	(A0)+,D0
	JSR	ENPP_PokeVol(A5)
	MOVE.L	(A7)+,D0

	bra.w	lbC00039A

lbC00049C
	clr.w	$5E4-$59C(A1)
	move.b	(A0)+,$614-$59C(A1)
	lea	lbL000618(PC),A3
	moveq	#7,D0
lbC0004AA
	move.w	(A0)+,(A3)+
	dbra	D0,lbC0004AA
	move.w	#2,$616-$59C(A1)
	bra.w	lbC00039A

lbC0004BA
	tst.b	(A0)+
	bne.s	lbC0004C8
;	bset	#1,$BFE001

	BSR.W	LED_Off

	bra.s	lbC0004D0

lbC0004C8
;	bclr	#1,$BFE001

	BSR.W	LED_On

lbC0004D0
	bra.w	lbC00039A

lbC0004D4
	addq.l	#1,A0
;	move.w	(A0)+,$C6(A6)

	MOVEQ	#2,D1					; channel 2
	MOVE.L	D0,-(A7)
	MOVE.W	(A0)+,D0
	JSR	ENPP_PokePer(A5)
	MOVE.L	(A7)+,D0

	bra.w	lbC0003D0

lbC0004DE
	clr.w	$628-$59C(A1)
	move.b	(A0),$5F2-$59C(A1)
	move.b	(A0)+,$5F0-$59C(A1)
	move.l	(A0)+,$5EC-$59C(A1)
	move.w	(A0)+,$5F4-$59C(A1)
	bra.w	lbC0003D0

lbC0004F6
	addq.l	#1,A0
;	move.w	(A0)+,$C8(A6)

	MOVEQ	#2,D1					; channel 2
	MOVE.L	D0,-(A7)
	MOVE.W	(A0)+,D0
	JSR	ENPP_PokeVol(A5)
	MOVE.L	(A7)+,D0
	
	bra.w	lbC0003D0

lbC000500
	clr.w	$5EE-$59C(A1)
	move.b	(A0)+,$628-$59C(A1)
	lea	lbL00062C(PC),A3
	moveq	#7,D0
lbC00050E
	move.w	(A0)+,(A3)+
	dbra	D0,lbC00050E
	move.w	#2,$62A-$59C(A1)
	bra.w	lbC0003D0

lbC00051E
	tst.b	(A0)+
	bne.s	lbC00052C
;	bset	#1,$BFE001

	BSR.W	LED_Off

	bra.s	lbC000534

lbC00052C
;	bclr	#1,$BFE001

	BSR.W	LED_On

lbC000534
	bra.w	lbC0003D0

lbC000538
	addq.l	#1,A0
;	move.w	(A0)+,$D6(A6)

	MOVEQ	#3,D1					; channel 3
	MOVE.L	D0,-(A7)
	MOVE.W	(A0)+,D0
	JSR	ENPP_PokePer(A5)
	MOVE.L	(A7)+,D0

	bra.w	lbC000406

lbC000542
	clr.w	$63C-$59C(A1)
	move.b	(A0),$5FC-$59C(A1)
	move.b	(A0)+,$5FA-$59C(A1)
	move.l	(A0)+,$5F6-$59C(A1)
	move.w	(A0)+,$5FE-$59C(A1)
	bra.w	lbC000406

lbC00055A
	addq.l	#1,A0
;	move.w	(A0)+,$D8(A6)

	MOVEQ	#3,D1					; channel 3
	MOVE.L	D0,-(A7)
	MOVE.W	(A0)+,D0
	JSR	ENPP_PokeVol(A5)
	MOVE.L	(A7)+,D0

	bra.w	lbC000406

lbC000564
	clr.w	$5F8-$59C(A1)
	move.b	(A0)+,$63C-$59C(A1)
	lea	lbL000640(PC),A3
	moveq	#7,D0
lbC000572
	move.w	(A0)+,(A3)+
	dbra	D0,lbC000572
	move.w	#2,$63E-$59C(A1)
	bra.w	lbC000406

lbC000582
	tst.b	(A0)+
	bne.s	lbC000590
;	bset	#1,$BFE001

	BSR.W	LED_Off

	bra.s	lbC000598

lbC000590
;	bclr	#1,$BFE001

	BSR.W	LED_On

lbC000598
	bra.w	lbC000406

lbL00059C
	dc.l	0
CurrentPos1
lbL0005A0
	dc.l	0
lbL0005A4
	dc.l	0
lbL0005A8
	dc.l	0
lbL0005AC
	dc.l	0
lbL0005B0
	dc.l	0
lbL0005B4
	dc.l	0
lbL0005B8
	dc.l	0
lbL0005BC
	dc.l	0
lbL0005C0
	dc.l	0
lbL0005C4
	dc.l	0
lbL0005C8
	dc.l	0
lbL0005CC
	dc.l	0
lbW0005D0
	dc.w	0
lbB0005D2
	dc.b	0
	dc.b	0
TimerH
lbB0005D4
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	0
lbW0005D8
	dc.w	0
	dc.w	0
lbB0005DC
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	0
lbW0005E0
	dc.w	0
lbW0005E2
	dc.w	0
	dc.w	0
lbB0005E6
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	0
lbW0005EA
	dc.w	0
lbW0005EC
	dc.w	0
	dc.w	0
lbB0005F0
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	0
lbW0005F4
	dc.w	0
lbW0005F6
	dc.w	0
	dc.w	0
lbB0005FA
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	0
lbW0005FE
	dc.w	0
	dc.w	0
lbW000602
	dc.w	0
lbL000604
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
lbW000616
	dc.w	0
lbL000618
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
lbW00062A
	dc.w	0
lbL00062C
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
lbW00063E
	dc.w	0
lbL000640
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0


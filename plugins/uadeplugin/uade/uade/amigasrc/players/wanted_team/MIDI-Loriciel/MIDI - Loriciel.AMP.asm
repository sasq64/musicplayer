	******************************************************
	****         MIDI - Loriciel replayer for	  ****
	****    EaglePlayer 2.00+ (Amplifier version),    ****
	****         all adaptions by Wanted Team	  ****
	******************************************************

	incdir	"dh2:include/"
	include 'misc/eagleplayer2.01.i'
	include	'misc/eagleplayerengine.i'
	include	'exec/exec_lib.i'

	SECTION	Player_Code,CODE

	EPPHEADER Tags

	dc.b	'$VER: MIDI - Loriciel player module V2.0 (17 Mar 2008)',0
	even

Tags
	dc.l	DTP_PlayerVersion,2<<16!0
	dc.l	EP_PlayerVersion,11
	dc.l	DTP_PlayerName,PlayerName
	dc.l	DTP_Creator,Creator
	dc.l	EP_Check5,Check5
	dc.l	DTP_Interrupt,Interrupt
	dc.l	DTP_InitPlayer,InitPlayer
	dc.l	DTP_InitSound,InitSound
	dc.l	DTP_ExtLoad,ExtLoad
	dc.l	EP_NewModuleInfo,NewModuleInfo
	dc.l	EP_InitAmplifier,InitAudstruct
	dc.l	EP_EagleBase,EagleBase
	dc.l	EP_Flags,EPB_ModuleInfo!EPB_Songend!EPB_Packable!EPB_Restart
	dc.l	0

PlayerName
	dc.b	'MIDI - Loriciel',0
Creator
	dc.b	'(c) 1992-93 by Loriciel,',10
	dc.b	'adapted by Wanted Team',0
Prefix
	dc.b	"MIDI.",0
	even
ModulePtr
	dc.l	0
SamplesPtr
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
****************************** EP_NewModuleInfo ***************************
***************************************************************************

NewModuleInfo

LoadSize	=	4
SamplesSize	=	12
SongSize	=	20
CalcSize	=	28

InfoBuffer
	dc.l	MI_LoadSize,0		;4
	dc.l	MI_SamplesSize,0	;12
	dc.l	MI_Songsize,0		;20
	dc.l	MI_Calcsize,0		;28
	dc.l	MI_Prefix,Prefix
	dc.l	0

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
	movea.l	dtg_PathArrayPtr(A5),A0
	clr.b	(A0)
	movea.l	dtg_CopyDir(A5),A0
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

	cmpi.b	#'M',(A3)
	beq.b	M_OK
	cmpi.b	#'m',(A3)
	bne.s	Suffix
M_OK
	cmpi.b	#'I',1(A3)
	beq.b	I_OK
	cmpi.b	#'i',1(A3)
	bne.s	Suffix
I_OK
	cmpi.b	#'D',2(A3)
	beq.b	D_OK
	cmpi.b	#'d',2(A3)
	bne.s	Suffix
D_OK
	cmpi.b	#'I',3(A3)
	beq.b	i_OK
	cmpi.b	#'i',3(A3)
	bne.s	Suffix
i_OK
	cmpi.b	#'.',4(A3)
	bne.s	Suffix

	move.b	#'S',(A3)+
	move.b	#'M',(A3)+
	move.b	#'P',(A3)+
	move.b	#'L',(A3)

	bra.b	ExtOK
ExtError
	clr.b	-2(A0)
ExtOK
	clr.b	-1(A0)
	rts

Suffix
loop2
	tst.b	(A3)+
	bne.s	loop2
	subq.l	#5,A3

	cmpi.b	#'.',(A3)+
	bne.s	ExtError

	cmpi.b	#'m',(A3)
	beq.b	m_OK
	cmpi.b	#'M',(A3)
	bne.s	ExtError
m_OK
	cmpi.b	#'i',1(A3)
	beq.b	j_OK
	cmpi.b	#'I',1(A3)
	bne.s	ExtError
j_OK
	cmpi.b	#'d',2(A3)
	beq.b	d_OK
	cmpi.b	#'D',2(A3)
	bne.s	ExtError
d_OK
	move.b	#'B',(A3)+
	move.b	#'S',(A3)+
	move.b	#'P',(A3)
	bra.b	ExtOK

***************************************************************************
******************************** EP_Check5 ********************************
***************************************************************************

Check5
	movea.l	dtg_ChkData(A5),A0
	moveq	#-1,D0

	cmp.l	#'MThd',(A0)+
	bne.b	fail
	moveq	#6,D1
	cmp.l	(A0)+,D1
	bne.b	fail
	cmp.w	#1,(A0)+
	blt.b	fail
	tst.w	(A0)+
	beq.b	fail
	tst.w	(A0)+
	beq.b	fail
	cmp.l	#'MTrk',(A0)
	bne.b	fail

	moveq	#0,D0
fail
	rts

***************************************************************************
***************************** DTP_InitPlayer ******************************
***************************************************************************

InitPlayer
	moveq	#0,D0
	movea.l	dtg_GetListData(A5),A0
	jsr	(A0)

	lea	ModulePtr(PC),A3
	move.l	A0,(A3)+			; module buffer
	lea	InfoBuffer(PC),A4
	move.l	D0,LoadSize(A4)
	move.l	A0,A1
	bsr.w	Init_1
	tst.l	D0
	bne.b	Corrupt
	sub.l	A1,A0
	cmp.l	LoadSize(A4),A0
	bgt.b	Short
	move.l	A0,SongSize(A4)
	move.l	A0,CalcSize(A4)

	moveq	#1,D0
	movea.l	dtg_GetListData(A5),A0
	jsr	(A0)

	cmp.l	#'BNKS',(A0)
	bne.b	Corrupt
	move.l	A0,(A3) 			; Samples Ptr
	add.l	D0,LoadSize(A4)
	move.l	D0,D2
	move.l	A0,A6
	bsr.w	InitSamples
	add.l	4(A2),A3
	sub.l	A6,A3
	lea	InfoBuffer(PC),A4
	move.l	A3,D1
	move.l	D1,SamplesSize(A4)
	add.l	D1,CalcSize(A4)
	cmp.l	D2,D1
	bgt.b	Short

	moveq	#0,D0
	rts

Short
	moveq	#EPR_ModuleTooShort,D0
	rts

Corrupt
	moveq	#EPR_CorruptModule,D0
	rts

***************************************************************************
***************************** DTP_InitSound *******************************
***************************************************************************

InitSound
	move.l	ModulePtr(PC),A0
	bsr.w	Init_1
	bra.w	Init_2

***************************************************************************
***************************** DTP_Intterrupt ******************************
***************************************************************************

Interrupt
	movem.l	D1-D7/A0-A6,-(SP)

	bsr.w	Play
	move.l	EagleBase(PC),A5
	jsr	ENPP_Amplifier(A5)

	movem.l	(SP)+,D1-D7/A0-A6
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
*************************** MIDI - Loriciel player ************************
***************************************************************************

; Player from game "Entity" (intro music) (c) 1993 by Loriciel

;WT	BRA.L	lbC00048A			; unload player (Atari ST exe)

;	BRA.L	lbC0004A6			; nothing

;	BRA.L	lbC0004A8			; init song

;	BRA.L	lbC0004DC

;	BRA.L	lbC0004EA

;	BRA.L	lbC0004F8

;	BRA.L	lbC000506

Init_1
lbC00001C	MOVE.L	A0,lbL0005AC
;	MOVE.B	(A0)+,D0
;	LSL.W	#8,D0
;	MOVE.B	(A0)+,D0
;	SWAP	D0
;	MOVE.B	(A0)+,D0
;	LSL.W	#8,D0
;	MOVE.B	(A0)+,D0
;	CMP.L	#'MThd',D0
;	BNE.L	lbC0000D8
;	MOVE.B	(A0)+,D0
;	LSL.W	#8,D0
;	MOVE.B	(A0)+,D0
;	SWAP	D0
;	MOVE.B	(A0)+,D0
;	LSL.W	#8,D0
;	MOVE.B	(A0)+,D0
;	CMP.L	#6,D0
;	BNE.L	lbC0000D8

	addq.l	#8,A0

;	MOVE.B	(A0)+,D0
;	LSL.W	#8,D0
;	MOVE.B	(A0)+,D0
;	CMP.W	#2,D0
;	BGE.S	lbC0000D8
;	MOVE.B	(A0)+,D0
;	LSL.W	#8,D0
;	MOVE.B	(A0)+,D0
;	TST.W	D0
;	BEQ.S	lbC0000D8

	move.l	(A0)+,D0

	MOVE.B	(A0)+,D1
	LSL.W	#8,D1
	MOVE.B	(A0)+,D1
	BTST	#15,D1
	BNE.S	lbC000080
	MULU.W	#$2710,D1
	MOVE.L	D1,lbL00059A
	BRA.S	lbC000082

lbC000080
;	NOP

	move.l	#$C0*$2710,lbL00059A	; value set as default for safety

lbC000082	MOVE.W	D0,lbW0005B0
	LEA	lbL0005B2(pc),A6
	SUBQ.W	#1,D0
lbC000090	MOVE.B	(A0)+,D1
	LSL.W	#8,D1
	MOVE.B	(A0)+,D1
	SWAP	D1
	MOVE.B	(A0)+,D1
	LSL.W	#8,D1
	MOVE.B	(A0)+,D1
	CMP.L	#'MTrk',D1
	BNE.S	lbC0000D8
	MOVE.B	(A0)+,D1
	LSL.W	#8,D1
	MOVE.B	(A0)+,D1
	SWAP	D1
	MOVE.B	(A0)+,D1
	LSL.W	#8,D1
	MOVE.B	(A0)+,D1
	MOVE.L	A0,2(A6)
	MOVE.L	A0,6(A6)
	ADDA.L	D1,A0
	MOVE.L	A0,10(A6)
	ST	(A6)
	MOVE.L	#$FFFF8000,14(A6)
	LEA	$14(A6),A6
	DBRA	D0,lbC000090
	MOVEQ	#0,D0
	RTS

lbC0000D8	MOVEQ	#-1,D0
	RTS

lbC0000DC	MOVE.B	(A0)+,D0
	CMP.B	#$F0,D0
	BCS.S	lbC000100
	LEA	lbW00051C(pc),A1
lbC0000EA	CMPI.W	#$FFFF,(A1)
	BEQ.S	lbC000128
	MOVEA.L	2(A1),A2
	CMP.B	1(A1),D0
	BNE.S	lbC0000FC
	JMP	(A2)

lbC0000FC	ADDQ.L	#6,A1
	BRA.S	lbC0000EA

lbC000100	MOVE.B	D0,D1
	MOVEQ	#15,D1
	AND.B	D0,D1
	SUB.B	D1,D0
	MOVE.W	D1,$12(A6)
	LEA	lbW00052A(pc),A1
lbC000112	CMPI.W	#$FFFF,(A1)
	BEQ.S	lbC000128
	MOVEA.L	2(A1),A2
	CMP.B	1(A1),D0
	BNE.S	lbC000124
	JMP	(A2)

lbC000124	ADDQ.L	#6,A1
	BRA.S	lbC000112

lbC000128	ADDQ.L	#2,A0
	RTS

lbC00012C	MOVEQ	#0,D0
lbC00012E	MOVE.B	(A0)+,lbW000148
	BCLR	#7,lbW000148
	BEQ.S	lbC00014A
	OR.B	lbW000148(pc),D0
	LSL.L	#7,D0
	BRA.S	lbC00012E

lbW000148	dc.w	0

lbC00014A	OR.B	lbW000148(pc),D0
	ADDA.L	D0,A0
	RTS

lbC000154	MOVE.B	(A0)+,D0
	LEA	lbW00053E(pc),A1
lbC00015C	CMPI.W	#$FFFF,(A1)
	BEQ.S	lbC000174
	MOVEA.L	2(A1),A2
	CMP.B	1(A1),D0
	BNE.S	lbC00016E
	JMP	(A2)

lbC00016E	ADDQ.L	#6,A1
	BRA.S	lbC00015C

;	RTS

lbC000174	MOVEQ	#0,D0
lbC000176	MOVE.B	(A0)+,lbW000190
	BCLR	#7,lbW000190
	BEQ.S	lbC000192
	OR.B	lbW000190(pc),D0
	LSL.L	#7,D0
	BRA.S	lbC000176

lbW000190	dc.w	0

lbC000192	OR.B	lbW000190(pc),D0
	ADDA.L	D0,A0
	RTS

lbC00019C	ADDQ.L	#1,A0
	CLR.B	(A6)
	SUBQ.W	#1,lbW0005B0
	RTS

lbC0001A8	ADDQ.L	#1,A0
	MOVEQ	#0,D0
	MOVE.B	(A0)+,D0
	SWAP	D0
	MOVE.B	(A0)+,D0
	LSL.W	#8,D0
	MOVE.B	(A0)+,D0
	BSR.L	lbC00024C
	RTS

lbC0001BC	ADDQ.L	#1,A0
	MOVE.B	(A0)+,D0
	EXT.W	D0
	MOVE.W	D0,$12(A6)
	RTS

lbC0001C8	TST.B	1(A0)
	BEQ.S	lbC0001EA
	MOVE.W	#0,(A5)+
	MOVE.W	$12(A6),(A5)+
	MOVE.B	(A0)+,(A5)+
	MOVE.B	(A0)+,(A5)+
	LEA	lbL00070A(pc),A5
;	MOVEA.L	lbL0006F2,A1
;	JSR	(A1)

	bsr.w	lbC000970

	RTS

lbC0001EA	MOVE.W	#1,(A5)+
	MOVE.W	$12(A6),(A5)+
	MOVE.B	(A0)+,(A5)+
	MOVE.B	(A0)+,(A5)+
	LEA	lbL00070A(pc),A5
;	MOVEA.L	lbL0006F2,A1
;	JSR	(A1)

	bsr.w	lbC000970

	RTS

lbC000206	MOVE.W	#2,(A5)+
	MOVE.W	$12(A6),(A5)+
	MOVE.B	(A0)+,(A5)+
	LEA	lbL00070A(pc),A5
;	MOVEA.L	lbL0006F2,A1
;	JSR	(A1)

	bsr.w	lbC000970

	RTS

;lbC000220	BSR.L	lbC00043A
;	JSR	(A0)
;	MOVE.L	(A0)+,lbL0006F2
;	MOVE.L	(A0)+,lbL0006F6
;	MOVE.L	(A0)+,lbL0006FA
;	MOVE.L	(A0)+,lbL0006FE
;	MOVE.L	(A0)+,lbL000702
;	MOVE.L	(A0)+,lbL000706
;	RTS

lbC00024C
;	CLR.B	lbW0005A8
	DIVU.W	#$64,D0
	MOVE.L	lbL00059A(pc),D1
	DIVU.W	D0,D1
	MOVE.W	D1,D0
	LSR.W	#2,D0
	BSR.L	lbC0002F4
;	BSR.L	lbC00031A
	RTS

Init_2
lbC00026C
;	MOVEA.L	lbL0006FA,A1
;	JSR	(A1)

	bsr.w	lbC0009CA

	MOVE.L	#$7A120,D0
	BSR.L	lbC00024C
	RTS

;lbC000280	TST.W	lbW0005B0
;	BEQ.S	lbC00029A
;	BSR.L	lbC00033C
;	CLR.W	lbW0005B0
;	MOVEA.L	lbL0006FE,A0
;	JSR	(A0)
;lbC00029A	CLR.B	lbW0005A8
;	RTS

;lbC0002A2	ST	lbW0005A8
;	TST.W	lbW0005B0
;	BEQ.S	lbC0002CC
;	BSR.L	lbC00033C
;	MOVE.W	lbW0005B0,lbW0005AA
;	CLR.W	lbW0005B0
;	MOVEA.L	lbL000702,A0
;	JSR	(A0)
;lbC0002CC	RTS

;lbC0002CE	TST.B	lbW0005A8
;	BEQ.S	lbC0002F2
;	MOVE.W	lbW0005AA,lbW0005B0
;	CLR.B	lbW0005A8
;	BSR.L	lbC00031A
;	MOVEA.L	lbL000706,A0
;	JSR	(A0)
;lbC0002F2	RTS

lbC0002F4
;	BCLR	#0,$BFDE00
	BSR.L	lbC000356
;	MOVE.B	D0,$BFD400
;	LSR.W	#8,D0
;	MOVE.B	D0,$BFD500
;	MOVE.L	#lbC000362,$78

	movem.l	A1/A5,-(SP)
	move.l	EagleBase(PC),A5
	move.w	D0,dtg_Timer(A5)
	move.l	dtg_SetTimer(A5),A1
	jsr	(A1)
	movem.l	(SP)+,A1/A5

	RTS

;lbC00031A	MOVE.B	#$91,$BFDE00
;	MOVE.B	#$81,$BFDD00
;	MOVE.W	#$E000,$DFF09A
;	MOVE.W	#$2000,$DFF09C
;	RTS

;lbC00033C	BCLR	#0,$BFDE00			; stop timer
;	MOVE.B	#1,$BFDD00
;	MOVE.W	#$2000,$DFF09A
;	RTS

lbC000356	MOVE.L	#$AECE0,D3			; 715909 for NTSC
	DIVU.W	D0,D3
	MOVE.W	D3,D0
	RTS

Play
;lbC000362	MOVEM.L	D0-D4/A0-A2/A5/A6,-(SP)
;	MOVE.B	$BFDD00,D0
	LEA	lbL0005B2(pc),A6
	MOVE.W	lbW0005B0(pc),D4
	BEQ.L	lbC000406
	SUBQ.W	#1,D4
lbC00037E	TST.B	(A6)
	BEQ.L	lbC000432
	MOVEA.L	6(A6),A0
	CMPI.L	#$FFFF8000,14(A6)
	BEQ.S	lbC00039C
	SUBQ.L	#4,14(A6)
	BEQ.S	lbC0003C8
	BMI.S	lbC0003C8
	BRA.S	lbC0003E4

lbC00039C	CLR.L	14(A6)
lbC0003A0	MOVEQ	#0,D0
lbC0003A2	MOVE.B	(A0)+,lbW0003BC
	BCLR	#7,lbW0003BC
	BEQ.S	lbC0003BE
	OR.B	lbW0003BC(pc),D0
	LSL.L	#7,D0
	BRA.S	lbC0003A2

lbW0003BC	dc.w	0

lbC0003BE	OR.B	lbW0003BC(pc),D0
	TST.L	D0
	BNE.S	lbC0003D8
lbC0003C8	LEA	lbL00070A(pc),A5
	BSR.L	lbC0000DC
	TST.B	(A6)
	BEQ.S	lbC0003E4
	BRA.S	lbC0003A0

lbC0003D8	ADD.L	14(A6),D0
	MOVE.L	D0,14(A6)
	MOVE.L	A0,6(A6)
lbC0003E4	LEA	$14(A6),A6
	DBRA	D4,lbC00037E
lbC0003EC
;	MOVEA.L	lbL0006F6,A0
;	JSR	(A0)

	bsr.w	lbC000986

;	LEA	$DFF000,A0
;	MOVE.W	#$2000,$9C(A0)
;	MOVEM.L	(SP)+,D0-D4/A0-A2/A5/A6
;	RTE

	rts


lbC000406
;	SUBQ.W	#1,lbW0005A6			; repeat song counter
;	BNE.S	lbC00041C
;	BSR.L	lbC00033C
;	MOVEA.L	lbL0006FE,A0
;	JSR	(A0)
;	BRA.S	lbC0003EC

lbC00041C

	bsr.w	SongEnd

	MOVEA.L	lbL0005AC(pc),A0		; repeat song routine
	BSR.L	lbC00001C
;	MOVEA.L	lbL0005A2,A0
	BSR.L	lbC00026C
	BRA.S	lbC0003EC

lbC000432	LEA	$14(A6),A6
	BRA.L	lbC00037E

;lbC00043A	LEA	WT(PC),A0
;	LEA	-$1C(A0),A1
;	MOVEA.L	A0,A2
;	ADDA.L	2(A1),A0
;	ADDA.L	6(A1),A0
;	MOVE.L	10(A1),D0
;	BEQ.S	lbC000458
;lbC000452	CLR.B	(A0)+
;	SUBQ.L	#1,D0
;	BNE.S	lbC000452
;lbC000458	ADDA.L	14(A1),A0
;	MOVE.L	A2,D0
;	ADDA.L	(A0)+,A2
;lbC000460	MOVE.L	(A2),D1
;	ADD.L	D0,D1
;	MOVE.L	D1,(A2)
;lbC000466	MOVE.B	(A0)+,D1
;	BEQ.S	lbC00047E
;	CMP.B	#1,D1
;	BNE.S	lbC000476
;	LEA	$FE(A2),A2
;	BRA.S	lbC000466

;lbC000476	ANDI.W	#$FF,D1
;	ADDA.W	D1,A2
;	BRA.S	lbC000460

;lbC00047E	MOVE.L	A0,D0
;	ADDQ.L	#1,D0
;	BCLR	#0,D0
;	MOVEA.L	D0,A0
;	RTS

;lbC00048A	MOVEM.L	D2-D7/A2/A3/A5/A6,-(SP)
;	MOVE.B	lbL00071A(PC),D0
;	TST.B	D0
;	BNE.S	lbC0004A0
;	BSR.L	lbC000220
;	ST	lbL00071A
;lbC0004A0	MOVEM.L	(SP)+,D2-D7/A2/A3/A5/A6
;	RTS

;lbC0004A6	RTS

;lbC0004A8	LINK.W	A4,#0
;	MOVEM.L	D2-D7/A2/A3/A5/A6,-(SP)
;	MOVE.W	$10(A4),lbW0005A6
;	BEQ.S	lbC0004D4
;	MOVEA.L	8(A4),A0			; song ptr
;	BSR.L	lbC00001C
;	TST.W	D0				; init check
;	BNE.S	lbC0004D4
;	MOVEA.L	12(A4),A0			; samples ptr
;	MOVE.L	A0,lbL0005A2
;	BSR.L	lbC00026C			; init timer
;lbC0004D4	MOVEM.L	(SP)+,D2-D7/A2/A3/A5/A6
;	UNLK	A4
;	RTS

;lbC0004DC	MOVEM.L	D2-D7/A2/A3/A5/A6,-(SP)
;	BSR.L	lbC000280
;	MOVEM.L	(SP)+,D2-D7/A2/A3/A5/A6
;	RTS

;lbC0004EA	MOVEM.L	D2-D7/A2/A3/A5/A6,-(SP)
;	BSR.L	lbC0002A2
;	MOVEM.L	(SP)+,D2-D7/A2/A3/A5/A6
;	RTS

;lbC0004F8	MOVEM.L	D2-D7/A2/A3/A5/A6,-(SP)
;	BSR.L	lbC0002CE
;	MOVEM.L	(SP)+,D2-D7/A2/A3/A5/A6
;	RTS

;lbC000506	MOVEM.L	D2-D7/A2/A3/A5/A6,-(SP)
;	MOVE.W	lbW0005B0,D0
;	ADD.W	lbW0005A6,D0
;	MOVEM.L	(SP)+,D2-D7/A2/A3/A5/A6
;	RTS

lbW00051C	dc.w	$F0
	dc.l	lbC00012C
	dc.w	$FF
	dc.l	lbC000154
	dc.w	$FFFF
lbW00052A	dc.w	$90
	dc.l	lbC0001C8
	dc.w	$80
	dc.l	lbC0001EA
	dc.w	$C0
	dc.l	lbC000206
	dc.w	$FFFF
lbW00053E	dc.w	0
	dc.l	lbC000174
	dc.w	1
	dc.l	lbC000174
	dc.w	2
	dc.l	lbC000174
	dc.w	3
	dc.l	lbC000174
	dc.w	4
	dc.l	lbC000174
	dc.w	5
	dc.l	lbC000174
	dc.w	6
	dc.l	lbC000174
	dc.w	7
	dc.l	lbC000174
	dc.w	$20
	dc.l	lbC0001BC
	dc.w	$2F
	dc.l	lbC00019C
	dc.w	$51
	dc.l	lbC0001A8
	dc.w	$54
	dc.l	lbC000174
	dc.w	$58
	dc.l	lbC000174
	dc.w	$59
	dc.l	lbC000174
	dc.w	$7F
	dc.l	lbC000174
	dc.w	$FFFF
lbL00059A	dc.l	0
;	dc.l	0
;lbL0005A2	dc.l	0
;lbW0005A6	dc.w	0
;lbW0005A8	dc.w	0
;lbW0005AA	dc.w	0
lbL0005AC	dc.l	0
lbW0005B0	dc.w	0
lbL0005B2
	ds.b	320

;lbL0006F2	dc.l	lbC000970
;lbL0006F6	dc.l	lbC000986
;lbL0006FA	dc.l	lbC0009CA
;lbL0006FE	dc.l	lbC0009E0
;lbL000702	dc.l	lbC0009EE
;lbL000706	dc.l	lbC0009F4

lbL00070A
	ds.b	16

;lbL00071A	dc.l	$900000
;	dc.l	$1E5C0A
;	dc.l	$65C2822
;	dc.l	$8080C0C
;	dc.l	$2008080C
;	dc.l	$E3A0616
;	dc.l	$6140610
;	dc.l	$6060606
;	dc.l	$6080A16
;	dc.l	$140C0608
;	dc.l	$8060C04
;	dc.l	$6060A08
;	dc.l	$4060A24
;	dc.l	$5E063008
;	dc.l	$80C0A24
;	dc.l	$1A0C0A0A
;	dc.l	$74181840
;	dc.l	$60C0608
;	dc.l	$6060806
;	dc.l	$6060606
;	dc.l	$6060606
;	dc.l	$6060606
;	dc.w	$600

;	BRA.L	lbC000A0A

;	BRA.L	lbC000A14

lbC00077C	BSR.L	lbC000B30
	BSR.L	lbC000844
	BSR.L	lbC000904
	MOVE.L	A2,D0
	SUBI.L	#$DFF0A0,D0
	LSR.W	#4,D0
	MOVE.W	#$8000,D1
	BSET	D0,D1
;	LEA	$DFF000,A0
;	MOVE.W	D1,$96(A0)			; DMA on

	move.l	D0,-(SP)
	move.w	D1,D0
	bsr.w	PokeDMA
	move.l	(SP)+,D0

;	MOVE.W	#$200,D1
;lbC0007A6	NOP
;	DBRA	D1,lbC0007A6
	RTS

lbC0007AE	BSR.L	lbC000B66
	TST.W	D0
	BNE.S	lbC0007D8
	MOVE.L	A2,D0
	SUBI.L	#$DFF0A0,D0
	LSR.W	#4,D0
	MOVEQ	#0,D1
	BSET	D0,D1
;	LEA	$DFF000,A0
;	MOVE.W	D1,$96(A0)			; DMA off

	move.l	D0,-(SP)
	move.w	D1,D0
	bsr.w	PokeDMA
	move.l	(SP)+,D0

;	MOVE.W	#$200,D1
;lbC0007D2	NOP
;	DBRA	D1,lbC0007D2
lbC0007D8	RTS

lbC0007DA	MOVE.W	(A5)+,D0
	LEA	lbL000A64(PC),A1
	LSL.W	#3,D0
	ADDA.W	D0,A1
	MOVEA.L	lbL000840(PC),A0
	ADDQ.L	#8,A0
	MOVE.B	(A5)+,D1
	EXT.W	D1
	LSL.W	#2,D1
	MOVE.L	0(A0,D1.W),0(A1)
	RTS

InitSamples
lbC0007F8	MOVE.L	A0,lbL000840
	MOVEA.L	A0,A4
;	CMPI.L	#'INIT',(A0)+
;	BEQ.S	lbC00083E

	clr.l	(A0)+				; make empty sample

	MOVE.L	(A0)+,D0
	SUBQ.W	#1,D0
lbC00080C	MOVEA.L	(A0),A1
	ADDA.L	A4,A1
	MOVE.L	A1,(A0)+
	MOVE.W	(A1)+,D1
	SUBQ.W	#1,D1
lbC000816	MOVE.L	(A1),D3
	BPL.S	lbC00082E
	NEG.L	D3
	MOVEA.L	D3,A2
	ADDA.L	A4,A2
	MOVE.L	A2,(A1)
	MOVE.L	(A2),D3
	BPL.S	lbC00082E
	NEG.L	D3
	MOVEA.L	D3,A3
	ADDA.L	A4,A3
	MOVE.L	A3,(A2)
lbC00082E	ADDQ.L	#8,A1
	DBRA	D1,lbC000816
	DBRA	D0,lbC00080C
;	MOVE.L	#'INIT',(A4)
lbC00083E	RTS

lbL000840	dc.l	0

lbC000844	MOVE.B	(A5)+,D0
	EXT.W	D0
	MOVE.W	D0,D2
	LSL.W	#4,D2
	MOVEA.L	0(A1),A3
	MOVE.W	(A3)+,D1
	SUBQ.W	#1,D1
lbC000854	CMP.B	6(A3),D0
	BLE.S	lbC000860
	ADDQ.W	#8,A3
	DBRA	D1,lbC000854
lbC000860	MOVEQ	#0,D1
	MOVE.B	4(A3),D1
	EXT.W	D1
	LSL.W	#4,D1
	MOVEA.L	(A3),A3
	SUB.W	D1,D2
;	MOVE.L	(A3),(A2)			; address

	move.l	D0,-(SP)
	move.l	(A3),D0
	bsr.w	PokeAdr

	MOVE.W	6(A3),D0
	LSR.W	#1,D0
;	MOVE.W	D0,4(A2)			; length

	bsr.w	PokeLen

	LEA	lbW0008C6(PC),A3
	ANDI.W	#$FFF0,D2
	ASR.W	#3,D2
;	MOVE.W	0(A3,D2.W),6(A2)		; period

	move.w	0(A3,D2.W),D0
	bsr.w	PokePer
	move.l	(SP)+,D0

	RTS

	dc.w	$7C7
	dc.w	$75A
	dc.w	$6EC
	dc.w	$68E
	dc.w	$630
	dc.w	$5D3
	dc.w	$580
	dc.w	$531
	dc.w	$4E6
	dc.w	$4A0
	dc.w	$45D
	dc.w	$41F
	dc.w	$3E3
	dc.w	$3AC
	dc.w	$377
	dc.w	$345
	dc.w	$316
	dc.w	$2EA
	dc.w	$2C0
	dc.w	$298
	dc.w	$273
	dc.w	$250
	dc.w	$22F
	dc.w	$20F
	dc.w	$1F2
	dc.w	$1D6
	dc.w	$1BB
	dc.w	$1A3
	dc.w	$18B
lbW0008C6	dc.w	$175
	dc.w	$160
	dc.w	$14C
	dc.w	$13A
	dc.w	$128
	dc.w	$117
	dc.w	$108
	dc.w	$F9
	dc.w	$EB
	dc.w	$DE
	dc.w	$D1
	dc.w	$C6
	dc.w	$BA
	dc.w	$B0
	dc.w	$A6
	dc.w	$9D
	dc.w	$94
	dc.w	$8C
	dc.w	$84
	dc.w	$7C
	dc.w	$75
	dc.w	$6F
	dc.w	$69
	dc.w	$63
	dc.w	$5D
	dc.w	$58
	dc.w	$53
	dc.w	$4E
	dc.w	$4A
	dc.w	$46
	dc.w	$42

lbC000904	LEA	lbW000930(PC),A3
	MOVE.B	(A5)+,D1
	EXT.W	D1
	LSR.W	#1,D1
	MOVE.B	0(A3,D1.W),D1
;	EXT.W	D1
;	ADD.W	lbW000A24,D1
;	BPL.S	lbC000920
;	MOVEQ	#0,D1
;	BRA.S	lbC000928

;lbC000920	CMP.B	#$20,D1
;	BCS.S	lbC000928
;	MOVEQ	#$1F,D1
lbC000928	ADD.W	D1,D1
;	MOVE.W	D1,8(A2)				; volume

	move.l	D0,-(SP)
	move.w	D1,D0
	bsr.w	PokeVol
	move.l	(SP)+,D0

	RTS

lbW000930	dc.w	1
	dc.w	$203
	dc.w	$405
	dc.w	$607
	dc.w	$809
	dc.w	$A0B
	dc.w	$C0D
	dc.w	$E0F
	dc.w	$1010
	dc.w	$1111
	dc.w	$1212
	dc.w	$1313
	dc.w	$1414
	dc.w	$1515
	dc.w	$1616
	dc.w	$1717
	dc.w	$1818
	dc.w	$1818
	dc.w	$1919
	dc.w	$1919
	dc.w	$1A1A
	dc.w	$1A1A
	dc.w	$1B1B
	dc.w	$1B1B
	dc.w	$1C1C
	dc.w	$1C1C
	dc.w	$1D1D
	dc.w	$1D1D
	dc.w	$1E1E
	dc.w	$1E1E
	dc.w	$1F1F
	dc.w	$1F1F

lbC000970	MOVEM.L	D0-D7/A0-A6,-(SP)
	LEA	lbC0009FE(PC),A1
	MOVE.W	(A5)+,D0
	LSL.W	#2,D0
	JSR	0(A1,D0.W)
	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTS

lbC000986
;	MOVEM.L	D0/A2/A4,-(SP)
	LEA	$DFF0A0,A2
	LEA	lbL000B9A(PC),A4
	MOVEQ	#3,D0
lbC000996	TST.W	0(A4)
	BMI.S	lbC0009A8
;	MOVE.L	#lbL0009BA,(A2)				; address
;	MOVE.W	#8,4(A2)				; length

	move.l	D0,-(SP)
	move.l	lbL000840(PC),D0
	bsr.w	PokeAdr
	moveq	#2,D0
	bsr.w	PokeLen
	move.l	(SP)+,D0

lbC0009A8	LEA	10(A4),A4
	LEA	$10(A2),A2
	DBRA	D0,lbC000996
;	MOVEM.L	(SP)+,D0/A2/A4
	RTS

;lbL0009BA	dc.l	0				; empty sample
;	dc.l	0
;	dc.l	0
;	dc.l	0

lbC0009CA	MOVEM.L	D0-D7/A0-A6,-(SP)
;	BSR.L	lbC0007F8
	BSR.L	lbC000AE4
	BSR.L	lbC000A4A
	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTS

;lbC0009E0	MOVEM.L	D0-D7/A0-A6,-(SP)
;	BSR.L	lbC000AE4
;	MOVEM.L	(SP)+,D0-D7/A0-A6
;	RTS

;lbC0009EE	BSR.L	lbC000AE4
;	RTS

;lbC0009F4	BSR.L	lbC000AE4
;	BSR.L	lbC000A4A
;	RTS

lbC0009FE	BRA.L	lbC00077C

	BRA.L	lbC0007AE

	BRA.L	lbC0007DA

;lbC000A0A	BSR.L	lbC000A28
;	BSR.L	lbC000A2A
;	RTS

;lbC000A14	MOVE.W	4(SP),D0
;	SUBI.W	#$1F,D0
;	MOVE.W	D0,lbW000A24
;	RTS

;lbW000A24	dc.w	$FFFC
;	dc.w	0

;lbC000A28	RTS

;lbC000A2A	MOVEA.L	#lbL000A32,A0
;	RTS

;lbL000A32	dc.l	lbC000970
;	dc.l	lbC000986
;	dc.l	lbC0009CA
;	dc.l	lbC0009E0
;	dc.l	lbC0009EE
;	dc.l	lbC0009F4

lbC000A4A	LEA	lbL000A64(PC),A1
	MOVEQ	#15,D0
	MOVEA.L	lbL000840(PC),A0
	ADDQ.L	#8,A0
lbC000A56	MOVE.L	(A0),(A1)
	CLR.L	4(A1)
	ADDQ.L	#8,A1
	DBRA	D0,lbC000A56
	RTS

lbL000A64
	ds.b	128

lbC000AE4
;	LEA	$DFF000,A0
;	MOVE.W	#0,$A8(A0)
;	MOVE.W	#0,$B8(A0)
;	MOVE.W	#0,$C8(A0)
;	MOVE.W	#0,$D8(A0)
;	MOVE.W	#15,$96(A0)
;	MOVE.W	#$FF,$9E(A0)

	movem.l	D1/A5,-(SP)
	move.l	EagleBase(PC),A5
	moveq	#3,D1				; channel number
	moveq	#0,D0
NextChan
	jsr	ENPP_PokeVol(A5)
	dbf	D1,NextChan
	moveq	#15,D0
	bsr.w	PokeDMA
	movem.l	(SP)+,D1/A5

	MOVEQ	#3,D0
	LEA	lbL000B9A(PC),A0
	LEA	$DFF0A0,A1
lbC000B1A	MOVE.W	#$FFFF,(A0)
	MOVE.L	A1,6(A0)
	LEA	$10(A1),A1
	LEA	10(A0),A0
	DBRA	D0,lbC000B1A
	RTS

lbC000B30	MOVE.W	(A5)+,D2
	LEA	lbL000B9A(PC),A0
	MOVEA.L	A0,A1
	MOVEQ	#3,D0
lbC000B3A	MOVE.W	(A0),D1
	BMI.S	lbC000B4E
	CMP.W	D2,D1
	BNE.S	lbC000B44
	MOVEA.L	A0,A1
lbC000B44	LEA	10(A0),A0
	DBRA	D0,lbC000B3A
	MOVEA.L	A1,A0
lbC000B4E	MOVE.W	D2,(A0)
	MOVE.B	(A5),2(A0)
	LEA	lbL000A64(PC),A1
	LSL.W	#3,D2
	ADDA.W	D2,A1
	MOVE.L	A0,4(A1)
	MOVEA.L	6(A0),A2
	RTS

lbC000B66	MOVE.W	(A5)+,D1
	MOVE.W	D1,D0
	LSL.W	#3,D0
	LEA	lbL000A64(PC),A1
	ADDA.W	D0,A1
	MOVE.L	4(A1),D0
	BEQ.S	lbC000B96
	MOVEA.L	D0,A0
	CMP.W	(A0),D1
	BNE.S	lbC000B96
	MOVE.B	2(A0),D0
	CMP.B	(A5),D0
	BNE.S	lbC000B96
	MOVE.W	#$FFFF,(A0)
	CLR.L	4(A1)
	MOVEA.L	6(A0),A2
	MOVEQ	#0,D0
	RTS

lbC000B96	MOVEQ	#-1,D0
	RTS

lbL000B9A
	ds.b	40

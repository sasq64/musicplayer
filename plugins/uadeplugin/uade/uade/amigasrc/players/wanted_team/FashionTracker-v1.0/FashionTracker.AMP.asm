	******************************************************
	****         Fashion Tracker replayer for	  ****
	****    EaglePlayer 2.00+ (Amplifier version),    ****
	****         all adaptions by Wanted Team	  ****
	******************************************************

	incdir	"dh2:include/"
	include 'misc/eagleplayer2.01.i'
	include	'misc/eagleplayerengine.i'
	include	'exec/exec_lib.i'

	SECTION	Player_Code,CODE

	EPPHEADER Tags

	dc.b	'$VER: Fashion Tracker player module V2.0 (26 June 2004)',0
	even
Tags
	dc.l	DTP_PlayerVersion,2<<16!0
	dc.l	EP_PlayerVersion,11
	dc.l	DTP_PlayerName,PlayerName
	dc.l	DTP_Creator,Creator
	dc.l	EP_Check5,Check5
	dc.l	EP_NewModuleInfo,NewModuleInfo
	dc.l	DTP_InitPlayer,InitPlayer
	dc.l	DTP_InitSound,InitSound
	dc.l	DTP_Interrupt,Interrupt
	dc.l	EP_SampleInit,SampleInit
	dc.l	EP_GetPositionNr,GetPosition
	dc.l	DTP_NextPatt,NextPattern
	dc.l	DTP_PrevPatt,BackPattern
	dc.l	EP_PatternInit,PatternInit
	dc.l	EP_Flags,EPB_Save!EPB_ModuleInfo!EPB_SampleInfo!EPB_Songend!EPB_Packable!EPB_Restart!EPB_PrevPatt!EPB_NextPatt!EPB_CalcDuration
	dc.l	EP_EagleBase,EagleBase
	dc.l	EP_InitAmplifier,InitAudstruct
	dc.l	0

PlayerName
	dc.b	'Fashion Tracker',0
Creator
	dc.b	'(c) 1988 by Fashion,',10
	dc.b	'adapted by Wanted Team',0
Prefix
	dc.b	'EX.',0
Author
	dc.b	'Richard van der Veen',0
	even
ModulePtr
	dc.l	0
Origin
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
	move.w	A1,D1		;DFF000/10/20/30
	sub.w	#$F000,D1
	lsr.w	#4,D1		;Number the channel from 0-3
	move.l	EagleBase(PC),A5
	jsr	ENPP_PokeVol(A5)
	movem.l	(SP)+,D1/A5
	rts

*---------------------------------------------------------------------------*
* Input		D0 = Address value
PokeAdr
	movem.l	D1/A5,-(SP)
	move.w	A1,D1		;DFF000/10/20/30
	sub.w	#$F000,D1
	lsr.w	#4,D1		;Number the channel from 0-3
	move.l	EagleBase(PC),A5
	jsr	ENPP_PokeAdr(A5)
	movem.l	(SP)+,D1/A5
	rts

*---------------------------------------------------------------------------*
* Input		D0 = Length value
PokeLen
	movem.l	D1/A5,-(SP)
	move.w	A1,D1		;DFF000/10/20/30
	sub.w	#$F000,D1
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
	move.w	A1,D1		;DFF000/10/20/30
	sub.w	#$F000,D1
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
	moveq	#16,D0
	move.l	D0,PI_Modulo(A0)	; Number of bytes to next row
	move.w	#64,PI_Pattlength(A0)	; Length of each stripe in rows
	clr.w	PI_Pattern(A0)		; Current Pattern (from 0)
	clr.w	PI_Pattpos(A0)		; Current Position in Pattern (from 0)
	clr.w	PI_Songpos(A0)		; Current Position in Song (from 0)
	move.w	InfoBuffer+Length+2(PC),PI_MaxSongPos(A0)	; Songlength
	move.w	InfoBuffer+Patterns+2(PC),PI_NumPatts(A0)
	move.w	#125,PI_BPM(A0)		; Beats Per Minute
	move.w	#6,PI_Speed(A0)		; Default Speed Value
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
	move.w	(A0),D0
	beq.b	NoNote
	move.b	2(A0),D1
	and.b	#$F0,D1
	beq.b	NoNote
	lsr.w	#2,D1
	move.l	lbW000476(PC),A1
	move.w	(A1,D1.W),D1
	addq.w	#1,D1
NoNote
	move.b	2(A0),D2
	and.b	#15,D2
	move.b	3(A0),D3
	rts

* Sets some current values for the PatternInfo structure.
* Call this every time something changes (or at least every interrupt).
* You can move these elsewhere if necessary, it is only important that
* you make sure the structure fields are accurate and updated regularly.
PATINFO:
	movem.l	D0/D1/A0/A1,-(SP)
	lea	PATTERNINFO(PC),A0
	move.l	lbL0004FC(PC),D0
	move.w	D0,PI_Songpos(A0)	; Position in Song
	move.l	lbL002480(PC),A1
	moveq	#0,D1
	move.b	(A1,D0.W),D1
	move.w	D1,PI_Pattern(A0)	; Current Pattern
	move.w	lbW0004FA(PC),D0
	lsr.w	#4,D0
	move.w	D0,PI_Pattpos(A0)	; Current Position in Pattern
	move.l	lbL000FF0(PC),A1
	moveq	#10,D0
	lsl.l	D0,D1
	add.l	D1,A1			; Current Pattern
	move.l	A1,PI_Stripes(A0)	; STRIPE1
	addq.l	#4,A1			; Distance to next stripe
	move.l	A1,PI_Stripes+4(A0)	; STRIPE2
	addq.l	#4,A1
	move.l	A1,PI_Stripes+8(A0)	; STRIPE3
	addq.l	#4,A1
	move.l	A1,PI_Stripes+12(A0)	; STRIPE4
	movem.l	(SP)+,D0/D1/A0/A1
	rts

***************************************************************************
******************************* DTP_BackPatt ******************************
***************************************************************************

BackPattern
	lea	lbL0004FC(PC),A1
	move.l	(A1),D0
	beq.b	MinPos
	subq.l	#1,D0
	beq.b	MinPos
	subq.l	#1,D0
MinPos
	move.l	D0,(A1)
	lea	lbB0004D9(PC),A0
	move.b	#5,(A0)
	lea	lbW0004FA(PC),A0
	move.w	#$400,(A0)
	rts

***************************************************************************
******************************* DTP_NextPatt ******************************
***************************************************************************

NextPattern
	lea	lbB0004D9(PC),A0
	move.b	#5,(A0)
	lea	lbW0004FA(PC),A0
	move.w	#$400,(A0)
	rts

***************************************************************************
***************************** EP_GetPositionNr ****************************
***************************************************************************

GetPosition
	move.l	lbL0004FC(PC),D0
	rts

***************************************************************************
****************************** EP_NewModuleInfo ***************************
***************************************************************************

NewModuleInfo

Patterns	=	4
LoadSize	=	12
SongSize	=	20
SamplesSize	=	28
Samples		=	36
CalcSize	=	44
Duration	=	52
Length		=	60

InfoBuffer
	dc.l	MI_Pattern,0		;4
	dc.l	MI_LoadSize,0		;12
	dc.l	MI_Songsize,0		;20
	dc.l	MI_SamplesSize,0	;28
	dc.l	MI_Samples,0		;36
	dc.l	MI_Calcsize,0		;44
	dc.l	MI_Duration,0		;52
	dc.l	MI_Length,0		;60
	dc.l	MI_AuthorName,Author
	dc.l	MI_MaxSamples,15
	dc.l	MI_Prefix,Prefix
	dc.l	0

***************************************************************************
******************************* EP_SampleInit *****************************
***************************************************************************

SampleInit
	moveq	#EPR_NotEnoughMem,D7
	lea	EPG_SampleInfoStructure(A5),A3
	move.l	ModulePtr(PC),D0
	beq.b	Exit

	move.l	InfoBuffer+Samples(PC),D5
	beq.b	Exit
	subq.l	#1,D5
	move.l	lbL000412(PC),A2
	move.l	lbL000432(PC),A1
hop
	jsr	ENPP_AllocSampleStruct(A5)
	move.l	D0,(A3)
	beq.b	Exit
	move.l	D0,A3

	move.l	(A2)+,D0
	add.l	D0,D0
	move.l	(A1)+,D1
	sub.l	Origin(PC),D1
	add.l	ModulePtr(PC),D1
	move.l	D1,EPS_Adr(A3)			; sample address
	move.l	D0,EPS_Length(A3)		; sample length
	move.l	#64,EPS_Volume(A3)
	move.w	#USITY_RAW,EPS_Type(A3)
	move.w	#USIB_Playable!USIB_Saveable!USIB_8BIT,EPS_Flags(A3)
	dbf	D5,hop

	moveq	#0,D7
Exit
	move.l	D7,D0
	rts

***************************************************************************
******************************** EP_Check5 ********************************
***************************************************************************

Check5
	movea.l	dtg_ChkData(A5),A0
	moveq	#-1,D0

	cmp.l	#$13FC0040,(A0)
	bne.b	Fault
	cmp.l	#$4E710439,8(A0)
	bne.b	Fault
	cmp.w	#1,12(A0)
	bne.b	Fault
	cmp.l	#$66F44E75,18(A0)
	bne.b	Fault
	cmp.l	#$48E7FFFE,22(A0)
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

	lea	1000(A0),A1
	move.l	A0,A2
FindOri
	cmp.w	#$2379,(A2)
	beq.b	GetOri
	addq.l	#2,A2
	cmp.l	A1,A2
	bne.b	FindOri
Corrupt
	moveq	#EPR_CorruptModule,D0
	rts
GetOri
	move.l	-4(A2),D7
	move.l	D7,(A6)+			; Origin
	move.l	A0,A2
	lea	lbL000412(PC),A3
	moveq	#1,D1
GetValues
	cmp.w	#$23D1,(A2)
	bne.b	NoL
	move.l	8(A2),D6
	sub.l	D7,D6
	add.l	A0,D6
	move.l	D6,(A3)
	move.l	-6(A2),D6
	sub.l	D7,D6
	add.l	A0,D6
	move.l	D6,4(A3)
	move.l	24(A2),D6
	sub.l	D7,D6
	add.l	A0,D6
	move.l	D6,8(A3)
	move.l	-30(A2),D6
	sub.l	D7,D6
	add.l	A0,D6
	move.l	D6,12(A3)
	subq.l	#6,D1
	bra.b	NextW
NoL
	cmp.l	#$C0FC0400,(A2)
	bne.b	NoPa
	move.l	6(A2),D6
	sub.l	D7,D6
	add.l	A0,D6
	move.l	D6,16(A3)
	addq.l	#3,D1
	bra.b	NextW
NoPa
	cmp.l	#$0C790400,(A2)
	bne.b	NextW
	move.l	12(A2),D6
	sub.l	D7,D6
	add.l	A0,D6
	move.l	D6,20(A3)
	move.l	34(A2),Length(A4)
	addq.l	#2,D1
NextW
	addq.l	#2,A2
	cmp.l	A1,A2
	bne.b	GetValues
	tst.l	D1
	bne.w	Corrupt

	move.l	lbL000432(PC),A1
	move.l	(A1),D2
	sub.l	D7,D2
	move.l	D2,SongSize(A4)
	move.l	-4(A1),D0
	add.l	D0,D0
	move.l	lbL000412(PC),A2
	move.l	A1,D1
	sub.l	A2,D1
	add.l	D1,A1
	lsr.l	#2,D1
	move.l	D1,Samples(A4)
	move.l	-4(A1),D1
	sub.l	D7,D1
	add.l	D0,D1
	move.l	D1,CalcSize(A4)
	sub.l	D2,D1
	move.l	D1,SamplesSize(A4)

	move.l	Length(A4),D0
	move.l	lbL002480(PC),A1
	lea	(A1,D0.W),A2
	moveq	#0,D1
GetPat
	cmp.b	(A1),D1
	bhi.b	NoNew
	move.b	(A1),D1
NoNew
	addq.l	#1,A1
	cmp.l	A1,A2
	bne.b	GetPat
	addq.l	#1,D1
	move.l	D1,Patterns(A4)
	move.l	D0,D1
	subq.l	#1,D1
	moveq	#6,D4			; song speed
	mulu.w	D4,D1		
	mulu.w	#$376B,D1		; dtg_Timer
        move.l	#(709379-3)/64,D3	; PAL ex_EClockFrequency/number of rows
	divu.w	D3,D1
	move.w	D1,Duration+2(A4)
	moveq	#0,D0
	rts

***************************************************************************
***************************** DTP_InitSound *******************************
***************************************************************************

InitSound
	lea	lbL0004B6(PC),A0
	lea	lbL0004FC+4(PC),A1
ClearBuf
	clr.w	(A0)+
	cmp.l	A0,A1
	bne.b	ClearBuf
	lea	lbB0004D9(PC),A0
	move.b	#5,(A0)
	lea	lbW0004FA(PC),A0
	move.w	#$400,(A0)
	rts

***************************************************************************
***************************** DTP_Interrupt *******************************
***************************************************************************

Interrupt
	movem.l	D1-A6,-(A7)

	bsr.w	Play

	move.l	EagleBase(PC),A5
	jsr	ENPP_Amplifier(A5)

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

***************************************************************************
*************************** Fashion Tracker player ************************
***************************************************************************

;	MOVE.W	#15,$DFF096
;	MOVE.L	$6C,lbL000248
;	MOVE.L	#lbC000068,$6C
;lbC00001C	BTST	#6,$BFE001
;	BNE.S	lbC00001C
;	MOVE.L	lbL000248,$6C
;	MOVE.W	#15,$DFF096
;	CLR.W	$DFF0A8
;	CLR.W	$DFF0B8
;	CLR.W	$DFF0C8
;	CLR.W	$DFF0D8
;	RTS

;lbC000052	MOVE.B	#$40,lbB0004D8
;lbC00005A	NOP
;	SUBI.B	#1,lbB0004D8
;	BNE.S	lbC00005A
;	RTS

Play
;lbC000068	MOVEM.L	D0-D7/A0-A6,-(SP)
	ADDI.B	#1,lbB0004D9
	CMPI.B	#6,lbB0004D9
	BEQ.L	lbC000132
	MOVEA.L	lbL0004EC(pc),A0
	MOVE.L	#$DFF000,lbL0004F4
	CLR.L	lbL0004F0
lbC000096	CMPI.W	#0,(A0)
	BEQ.L	lbC0000B0
	MOVE.W	(A0),lbW0004F8
	JSR	lbC0000F4(pc)
	JMP	lbC0000C8(pc)

lbC0000B0	MOVEA.L	#lbL0004B6,A1
	ADDA.L	lbL0004F0(pc),A1
	MOVE.W	(A1),lbW0004F8
	JSR	lbC0000F4(pc)
lbC0000C8	ADDA.L	#4,A0
	ADDI.L	#$10,lbL0004F4
	ADDI.L	#2,lbL0004F0
	CMPI.L	#8,lbL0004F0
	BNE.S	lbC000096
	JMP	lbC000242(pc)

lbC0000F4	CMPI.B	#1,lbB0004D9
	BEQ.L	lbC000332
	CMPI.B	#2,lbB0004D9
	BEQ.L	lbC000352
	CMPI.B	#3,lbB0004D9
	BEQ.L	lbC000374
	CMPI.B	#4,lbB0004D9
	BEQ.L	lbC000332
	CMPI.B	#5,lbB0004D9
	BEQ.L	lbC000352
	RTS

lbC000132	CMPI.W	#$400,lbW0004FA
	BNE.S	lbC000182
;	MOVEA.L	#lbL002480,A1

	move.l	lbL002480(PC),A1

	ADDA.L	lbL0004FC(pc),A1
	ADDI.L	#1,lbL0004FC
;	CMPI.L	#12,lbL0004FC

	move.l	InfoBuffer+Length(PC),D0
	cmp.l	lbL0004FC(PC),D0

	BNE.S	lbC000164
	CLR.L	lbL0004FC

	bsr.w	SongEnd

lbC000164	CLR.L	D0
	MOVE.B	(A1),D0
	MULU.W	#$400,D0
;	MOVE.L	#lbL000FF0,lbL0004EC

	move.l	lbL000FF0(PC),lbL0004EC

	ADD.L	D0,lbL0004EC
	CLR.W	lbW0004FA
lbC000182	ADDI.L	#$10,lbL0004EC
	ADDI.W	#$10,lbW0004FA

	bsr.w	PATINFO

	MOVEA.L	lbL0004EC(pc),A0
	CLR.B	lbB0004D9
	CLR.L	lbL0004F0
	MOVE.L	#$DFF000,lbL0004DA
	MOVE.W	#1,lbW0004DE
lbC0001B8	CMPI.W	#0,(A0)
	BEQ.S	lbC000204
	JSR	lbC00024C(pc)
;	MOVE.W	lbW0004DE(pc),$DFF096

	move.l	D0,-(SP)
	move.w	lbW0004DE(PC),D0
	bsr.w	PokeDMA
	move.l	(SP)+,D0

	MOVEA.L	lbL0004DA(pc),A1
	JSR	lbC0002D2(pc)
	ADDI.W	#$8000,lbW0004DE
;	MOVE.W	lbW0004DE(pc),$DFF096

	move.l	D0,-(SP)
	move.w	lbW0004DE(PC),D0
	bsr.w	PokeDMA
	move.l	(SP)+,D0

	CMPI.B	#1,lbB0004EA
	BEQ.S	lbC0001FC
	JSR	lbC0002FA(pc)
lbC0001FC	SUBI.W	#$8000,lbW0004DE
lbC000204	CLR.L	D0
	MOVE.W	lbW0004DE(pc),D0
	MULU.W	#2,D0
	MOVE.W	D0,lbW0004DE
	ADDA.L	#4,A0
	ADDI.L	#$10,lbL0004DA
	ADDI.L	#2,lbL0004F0
	CMPI.L	#8,lbL0004F0
	BEQ.S	lbC000242
	JMP	lbC0001B8(pc)

lbC000242
;	MOVEM.L	(SP)+,D0-D7/A0-A6
;	JMP	0
;lbL000248	EQU	*-4

	rts

lbC00024C	CLR.L	D0
	MOVE.B	2(A0),D0
	ANDI.B	#$F0,D0
	DIVU.W	#4,D0
	CMPI.B	#0,D0
	BNE.S	lbC00026C
	JSR	lbC000310(pc)
	JMP	lbC000272(pc)

lbC00026C	JSR	lbC000322(pc)
lbC000272
;	MOVEA.L	#lbW000476,A1

	move.l	lbW000476(PC),A1

	ADDA.L	D0,A1
	CLR.L	D0
	MOVE.W	(A1),D0
	MOVE.W	2(A1),lbW0004D4
	MULU.W	#4,D0
;	MOVEA.L	#lbL000432,A1

	move.l	lbL000432(PC),A1

	ADDA.L	D0,A1
;	MOVE.L	(A1),lbL0004CE
;	MOVEA.L	#lbL000412,A1

	move.l	(A1),D7
	sub.l	Origin(PC),D7
	add.l	ModulePtr(PC),D7
	move.l	D7,lbL0004CE

	move.l	lbL000412(PC),A1

	ADDA.L	D0,A1
	MOVE.W	2(A1),lbW0004D2
;	MOVEA.L	#lbL000452,A1

	move.l	lbL000452(PC),A1

	ADDA.L	D0,A1
	MOVE.B	3(A1),lbB0004EA
	MOVE.W	(A0),lbW0004D6
	MOVEA.L	#lbL0004B6,A1
	ADDA.L	lbL0004F0(pc),A1
	MOVE.W	lbW0004D6(pc),(A1)
	RTS

lbC0002D2
;	JSR	lbC000052
;	MOVE.L	lbL0004CE(pc),$A0(A1)		; address
;	MOVE.W	lbW0004D2(pc),$A4(A1)		; length
;	MOVE.W	lbW0004D6(pc),$A6(A1)		; period
;	MOVE.W	lbW0004D4(pc),$A8(A1)		; volume

	move.l	D0,-(SP)
	move.l	lbL0004CE(PC),D0
	bsr.w	PokeAdr
	move.w	lbW0004D2(PC),D0
	bsr.w	PokeLen
	move.w	lbW0004D6(PC),D0
	bsr.w	PokePer
	move.w	lbW0004D4(PC),D0
	bsr.w	PokeVol
	move.l	(SP)+,D0

	RTS

lbC0002FA
;	JSR	lbC000052
;	MOVE.L	#lbL0004BE,$A0(A1)		; address
;	MOVE.W	#4,$A4(A1)			; length

	move.l	D0,-(SP)
	move.l	#lbL0004BE,D0
	bsr.w	PokeAdr
	moveq	#4,D0
	bsr.w	PokeLen
	move.l	(SP)+,D0

	RTS

lbC000310	MOVEA.L	#lbL0004E0,A2
	ADDA.W	lbW0004DE(pc),A2
	CLR.L	D0
	MOVE.B	(A2),D0
	RTS

lbC000322	MOVEA.L	#lbL0004E0,A2
	ADDA.W	lbW0004DE(pc),A2
	MOVE.B	D0,(A2)
	RTS

lbC000332	CLR.L	D0
	MOVE.B	2(A0),D0
	ANDI.B	#15,D0
	CMPI.B	#1,D0
	BNE.L	lbC0003C6
	CLR.L	D0
	MOVE.B	3(A0),D0
	LSR.B	#4,D0
	JMP	lbC000394(pc)

lbC000352	CLR.L	D0
	MOVE.B	2(A0),D0
	ANDI.B	#15,D0
	CMPI.B	#1,D0
	BNE.L	lbC0003C6
	CLR.L	D0
	MOVE.B	3(A0),D0
	ANDI.B	#15,D0
	JMP	lbC000394(pc)

lbC000374	CLR.L	D0
	MOVE.B	2(A0),D0
	ANDI.B	#15,D0
	CMPI.B	#1,D0
	BNE.L	lbC0003C6
	CLR.L	D0
	MOVE.W	lbW0004F8(pc),D0
	JMP	lbC0003BC(pc)

lbC000394	MULU.W	#2,D0
	MOVEA.L	#lbW0003C8,A1
	CLR.L	D1
	MOVE.W	lbW0004F8(pc),D1
lbC0003A6	CMP.W	(A1),D1
	BEQ.S	lbC0003B6
	ADDA.L	#2,A1
	JMP	lbC0003A6(pc)

lbC0003B6	ADDA.L	D0,A1
	CLR.L	D0
	MOVE.W	(A1),D0
lbC0003BC	MOVEA.L	lbL0004F4(pc),A1
;	MOVE.W	D0,$A6(A1)			; period

	bsr.w	PokePer

lbC0003C6	RTS

lbW0003C8	dc.w	$358
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
	dc.w	0
lbL000412					; sample length

	dc.l	0

;	dc.l	$1356
;	dc.l	$125C
;	dc.l	$7D0
;	dc.l	$5DC
;	dc.l	$2BC
;	dc.l	$D7A
;	dc.l	$F6E
;	dc.l	$1356
lbL000432

	dc.l	0				; sample address

;	dc.l	lbL002500
;	dc.l	lbL004C00
;	dc.l	lbL007100
;	dc.l	lbL008100
;	dc.l	lbL008D00
;	dc.l	lbL009300
;	dc.l	lbL00AE00
;	dc.l	lbL00CD00
lbL000452
	dc.l	0				; sample repeat
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
lbW000476					; sample number + volume
	dc.l	0

;	dc.w	0
;	dc.w	0
;	dc.w	0
;	dc.w	$40
;	dc.w	1
;	dc.w	$2B
;	dc.w	0
;	dc.w	0
;	dc.w	2
;	dc.w	$40
;	dc.w	3
;	dc.w	$35
;	dc.w	4
;	dc.w	$35
;	dc.w	5
;	dc.w	$35
;	dc.w	6
;	dc.w	$35
;	dc.w	0
;	dc.w	0
;	dc.w	0
;	dc.w	0
;	dc.w	7
;	dc.w	$40
;	dc.w	0
;	dc.w	0
;	dc.w	0
;	dc.w	0
;	dc.w	0
;	dc.w	0
;	dc.w	0
;	dc.w	0

lbL000FF0
	dc.l	0			; patterns

lbL002480
	dc.l	0			; song positions

lbL0004B6	dc.l	0
	dc.l	0
;lbL0004BE	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
lbL0004CE	dc.l	0
lbW0004D2	dc.w	0
lbW0004D4	dc.w	0
lbW0004D6	dc.w	0
lbB0004D8	dc.b	0
lbB0004D9	dc.b	5
lbL0004DA	dc.l	0
lbW0004DE	dc.w	0
lbL0004E0	dc.l	0
	dc.l	0
	dc.w	0
lbB0004EA	dc.b	0
	dc.b	0
lbL0004EC	dc.l	0
lbL0004F0	dc.l	0
lbL0004F4	dc.l	0
lbW0004F8	dc.w	0
lbW0004FA	dc.w	$400
lbL0004FC	dc.l	0			; current position

	Section	Buffy,BSS_C

lbL0004BE	ds.b	8

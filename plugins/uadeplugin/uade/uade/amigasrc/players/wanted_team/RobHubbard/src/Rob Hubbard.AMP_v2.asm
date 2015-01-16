	****************************************************
	****          Rob Hubbard replayer for 	        ****
	****    EaglePlayer 2.00+ (Amplifier version),  ****
	****         all adaptions by Wanted Team       ****
	****************************************************

	incdir	"dh2:include/"
	include	'misc/Eagleplayer2.01.i'
	include	'misc/eagleplayerengine.i'
	include	'exec/exec_lib.i'

	SECTION	Player,CODE

	EPPHEADER Tags

	dc.b	"$VER: Rob Hubbard player module V2.1 (7 July 2001)",0
	even
Tags
	dc.l	DTP_PlayerVersion,2<<16!1
	dc.l	EP_PlayerVersion,11
	dc.l	DTP_PlayerName,PlayerName
	dc.l	DTP_Creator,Creator
	dc.l	EP_Check5,Check5
	dc.l	DTP_Interrupt,Interrupt
	dc.l	DTP_InitPlayer,InitPlayer
	dc.l	DTP_InitSound,InitSound
	dc.l	DTP_EndSound,EndSound
	dc.l	EP_NewModuleInfo,NewModuleInfo
	dc.l	EP_SampleInit,SampleInit
	dc.l	DTP_SubSongRange,SubSongRange
	dc.l	EP_GetPositionNr,GetPosition
	dc.l	EP_ModuleChange,ModuleChange
	dc.l	EP_InitAmplifier,InitAudstruct
	dc.l	EP_EagleBase,EagleBase
	dc.l	EP_Flags,EPB_Songend!EPB_NextSong!EPB_PrevSong!EPB_ModuleInfo!EPB_SampleInfo!EPB_Packable!EPB_Restart
	dc.l	0

PlayerName
	dc.b	"Rob Hubbard",0
Creator
	dc.b	"(c) 1989-91 by Rob Hubbard,",10
	dc.b	"adapted by Wanted Team",0
Prefix
	dc.b	"RH.",0
	even
ModulePtr
	dc.l	0
Change
	dc.w	0
SamplePtr
	dc.l	0
address
	dc.l	0
SongEnd
	dc.l	'WTWT'
CurrentPos
	dc.l	0
Hardware
	dc.l	$00DF0000

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
	movem.l	d1/a5,-(sp)
	move.w	a6,d1		;DFF000/10/20/30
	sub.w	#$f000,d1
	lsr.w	#4,d1		;Number the channel from 0-3
	move.l	EagleBase(pc),a5
	jsr	ENPP_PokeVol(a5)
	movem.l	(sp)+,d1/a5
	rts

*---------------------------------------------------------------------------*
* Input		D0 = Address value
PokeAdr
	movem.l	d1/a5,-(sp)
	move.w	a6,d1		;DFF000/10/20/30
	sub.w	#$f000,d1
	lsr.w	#4,d1		;Number the channel from 0-3
	move.l	EagleBase(pc),a5
	jsr	ENPP_PokeAdr(a5)
	movem.l	(sp)+,d1/a5
	rts

*---------------------------------------------------------------------------*
* Input		D0 = Length value
PokeLen
	movem.l	d1/a5,-(sp)
	move.w	a6,d1		;DFF000/10/20/30
	sub.w	#$f000,d1
	lsr.w	#4,d1		;Number the channel from 0-3
	move.l	EagleBase(pc),a5
	and.l	#$ffff,d0
	jsr	ENPP_PokeLen(a5)
	movem.l	(sp)+,d1/a5
	rts

*---------------------------------------------------------------------------*
* Input		D0 = Period value
PokePer
	movem.l	d1/a5,-(sp)
	move.w	a6,d1		;DFF000/10/20/30
	sub.w	#$f000,d1
	lsr.w	#4,d1		;Number the channel from 0-3
	move.l	EagleBase(pc),a5
	jsr	ENPP_PokePer(a5)
	movem.l	(sp)+,d1/a5
	rts

*---------------------------------------------------------------------------*
* Input		D0 = Bitmask
PokeDMA
	movem.l	d0/d1/a5,-(sp)
	move.l	EagleBase(pc),a5
	move.w	d0,d1
	and.w	#$8000,d0	;D0.w neg=enable ; 0/pos=disable
	and.l	#15,d1		;D1 = Mask (LONG !!)
	jsr	ENPP_DMAMask(a5)
	movem.l	(sp)+,d0/d1/a5
	rts

***************************************************************************
***************************** DTP_EndSound ********************************
***************************************************************************

EndSound
	move.l	ModulePtr(PC),A0	; module buffer
	jmp	8(A0)

***************************************************************************
**************************** EP_GetPositionNr *****************************
***************************************************************************

GetPosition
	move.l	CurrentPos(PC),D0
	lsr.l	#2,D0
	rts

***************************************************************************
***************************** EP_NewModuleInfo ****************************
***************************************************************************

NewModuleInfo

SubSongs	=	4
LoadSize	=	12
SongSize	=	20
SamplesSize	=	28
Samples		=	36
CalcSize	=	44
Steps		=	76
Length		=	84

InfoBuffer
	dc.l	MI_SubSongs,0		;4
	dc.l	MI_LoadSize,0		;12
	dc.l	MI_Songsize,0		;20
	dc.l	MI_SamplesSize,0	;28
	dc.l	MI_Samples,0		;36
	dc.l	MI_Calcsize,0		;44
	dc.l	MI_MaxSamples,13	;
	dc.l	MI_SynthSamples,3	;
	dc.l	MI_MaxSynthSamples,3	;
	dc.l	MI_Steps,0		;76
	dc.l	MI_Length,0		;84
	dc.l	MI_Prefix,Prefix
	dc.l	0

***************************************************************************
******************************* EP_SampleInit *****************************
***************************************************************************

SampleInit
	moveq	#EPR_NotEnoughMem,D7
	lea	EPG_SampleInfoStructure(A5),A3
	move.l	SamplePtr(PC),D0
	beq.b	return
	move.l	D0,A2

	move.l	InfoBuffer+Samples(PC),d5
	moveq	#13,D3
	sub.l	D5,D3
	subq.l	#1,D5

Normal
	jsr	ENPP_AllocSampleStruct(A5)
	move.l	D0,(A3)
	beq.b	return
	move.l	D0,A3

	move.l	(A2),D0
	addq.l	#6,D0
	move.l	A2,EPS_Adr(A3)			; sample address
	move.l	D0,EPS_Length(A3)		; sample length
	move.l	#64,EPS_Volume(A3)
	move.w	#USITY_RAW,EPS_Type(A3)
	move.w	#USIB_Playable!USIB_Saveable!USIB_8BIT,EPS_Flags(A3)
	add.l	D0,A2
	dbf	D5,Normal
	tst.l	D3
	beq.b	NoEmpty
	subq.l	#1,D3

Empty
	jsr	ENPP_AllocSampleStruct(A5)
	move.l	D0,(A3)
	beq.b	return
	move.l	D0,A3

	clr.l	EPS_Length(A3)
	move.w	#USITY_RAW,EPS_Type(A3)
	dbf	D3,Empty

NoEmpty
	moveq	#2,D5

Synth	jsr	ENPP_AllocSampleStruct(A5)
	move.l	D0,(A3)
	beq.b	return
	move.l	D0,A3

	move.w	#USITY_AMSynth,EPS_Type(A3)
	dbf	D5,Synth

	moveq	#0,D7
return
	move.l	D7,D0
	rts

***************************************************************************
******************************** EP_Check5 ********************************
***************************************************************************

Check5
	move.l	dtg_ChkData(A5),A0
	moveq	#-1,D0
	move.w	#$6000,D1
	cmp.w	(A0),D1
	bne.s	Return
	cmp.w	4(A0),D1
	bne.s	Return
	cmp.w	8(A0),D1
	bne.s	Return
	cmp.w	12(A0),D1
	bne.s	Return
	cmp.w	16(A0),D1
	bne.s	Return
	cmp.w	#$41FA,20(A0)
	bne.s	Return
	cmp.l	#$4E7541FA,28(A0)
	bne.s	Return
	moveq	#0,D0
Return
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
	move.l	#900,D1
	move.l	D1,EPG_ARG2(A5)
	moveq	#-2,D0
	move.l	d0,EPG_ARG5(A5)		
	moveq	#1,D0
	move.l	d0,EPG_ARG4(A5)			;Search-Modus
	moveq	#5,D0
	move.l	d0,EPG_ARGN(A5)
	move.l	EPG_ModuleChange(A5),A0
	jsr	(A0)
NoChange
	move.w	#1,Change
	moveq	#0,D0
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
***************************** DTP_InitPlayer ******************************
***************************************************************************

InitPlayer
	moveq	#0,D0
	move.l	dtg_GetListData(A5),A0
	jsr	(A0)

	lea	ModulePtr(PC),A6
	move.l	A0,(A6)+			; module buffer
	clr.w	(A6)+				; clearing change flag

	lea	InfoBuffer(PC),A1
	move.l	D0,LoadSize(A1)
	move.l	ModulePtr(PC),A3
	lea	64(A3),A2
	moveq	#7,D4
loop2
	cmp.w 	#$2418,(A2)+
	beq.b 	found2
	dbf	D4,loop2
	bra.b	Error
found2
	moveq	#0,D3
	move.b	-3(A2),D3
	move.l	D3,D6
	addq.l	#1,D6				; D6 = samples

	lea	54(A3),A2
	moveq	#4,D4
loop3
	cmp.w 	#$41FA,(A2)+
	beq.b 	found3
	dbf	D4,loop3
Error
	moveq	#EPR_CorruptModule,D0		; error message
	rts
found3
	moveq	#0,D4
	move.w	(A2),D4
	lea	(A2),A4
	add.w	D4,A2
	sub.l	A3,A2
	move.l	A2,D4
	addq.l	#2,D4				; end module NOP
	cmp.w	#$D1FC,2(A4)
	bne.b	hop2
	add.w	#$40,D4
hop2
	add.l	D4,A3
	subq.l	#2,A3				; end module NOP
	move.l	A3,(A6)+			; SamplePtr
	move.l	A3,A2
	moveq	#0,D5

loop4
	move.l	(A3),D1
	cmp.l	#$10000,D1
	bhi.b	Error
	addq.l	#6,D1
	add.l	D1,D5
	add.l	D1,A3
	dbf	D3,loop4
	cmp.w	#$4E71,(A3)
	bne.b	Error

	move.l	ModulePtr(PC),A3
	lea	130(A3),A0
	moveq	#9,D0
loop
	cmp.w 	#$41EB,(A0)+
	beq.b 	found
	dbf	D0,loop
	bra.b	Error
found
	moveq	#0,D1
	move.w	(A0),D2
	add.w	D2,A3
	move.l	A3,(A6)				; address
hop
	lea	18(A3),A3
	addq.l	#1,D1
	tst.w	(A3)
	bne.b	hop

	moveq	#0,D0
	sub.l	A3,A2
	move.l	A2,D2
petla
	cmp.b	#$84,(A3)
	beq.b	step1
	cmp.b	#$85,(A3)
	beq.b	step2
	addq.l	#1,A3
	dbf	D2,petla
	bra.b	exit

step2
	move.b	#$84,(A3)			; SongEnd patch 
step1
	addq.l	#1,D0
	addq.l	#1,A3
	dbf	D2,petla
exit
	move.l	D4,SongSize(A1)			; D4 = song size
	move.l	D6,Samples(A1)			; D6 = samples
	move.l	D5,SamplesSize(A1)		; D5 = samples size
	add.l	D4,D5
	move.l	D5,CalcSize(A1)
	move.l	D1,SubSongs(A1)			; D1 = subsongs
	move.l	D0,Steps(A1)

	bsr.w	ModuleChange

	move.l	dtg_AudioAlloc(A5),A0		; allocate the audiochannels
	jmp	(A0)				; returncode is already set !

***************************************************************************
***************************** DTP_InitSound *******************************
***************************************************************************

InitSound
	moveq	#0,D0
	move.w	dtg_SndNum(A5),D0
	lea	SongEnd(PC),A1
	move.l	#'WTWT',(A1)+
	clr.l	(A1)+				; clearing CurrentPos
	addq.l	#2,A1

	move.w	D0,D2
	move.l	address(PC),A3
FindMaxLength
	addq.l	#2,A3
	moveq	#3,D3
	moveq	#0,D5
	move.w	#$EFF0,D4

NextLength
	move.l	ModulePtr(PC),A2
	add.l	(A3)+,A2
	addq.w	#8,D4
	addq.w	#8,D4
	moveq	#-1,D1
Zero2
	addq.l	#1,D1
	tst.l	(A2)+
	bne.b	Zero2
	cmp.l	D1,D5
	bgt.b	MaxLength
	move.l	D1,D5
	move.w	D4,(A1)					; Hardware+2
MaxLength
	dbf	D3,NextLength
	dbf	D2,FindMaxLength

	lea	InfoBuffer(PC),A1
	move.l	D5,Length(A1)
	move.l	ModulePtr(PC),A0
	jmp	4(A0)

***************************************************************************
***************************** DTP_Interrupt *******************************
***************************************************************************

Interrupt
	movem.l	D1-A6,-(A7)

	move.l	ModulePtr(PC),A0
	jsr	(A0)

	move.l	EagleBase(PC),A5
	jsr	ENPP_Amplifier(A5)

	movem.l	(A7)+,D1-A6
	moveq	#0,D0
	rts

	*--------------- PatchTable for Rob Hubbard ------------------*

PatchTable
	dc.w	Code1-PatchTable,(Code1End-Code1)/2-1,Patch1-PatchTable
	dc.w	Code2-PatchTable,(Code2End-Code2)/2-1,Patch2-PatchTable
	dc.w	Code3-PatchTable,(Code3End-Code3)/2-1,Patch3-PatchTable
	dc.w	Code4-PatchTable,(Code4End-Code4)/2-1,Patch4-PatchTable
	dc.w	Code5-PatchTable,(Code5End-Code5)/2-1,Patch5-PatchTable
	dc.w	Code6-PatchTable,(Code6End-Code6)/2-1,Patch6-PatchTable
	dc.w	Code7-PatchTable,(Code7End-Code7)/2-1,Patch7-PatchTable
	dc.w	Code8-PatchTable,(Code8End-Code8)/2-1,Patch8-PatchTable
	dc.w	Code9-PatchTable,(Code9End-Code9)/2-1,Patch9-PatchTable
	dc.w	CodeA-PatchTable,(CodeAEnd-CodeA)/2-1,Patch9-PatchTable
	dc.w	CodeB-PatchTable,(CodeBEnd-CodeB)/2-1,PatchB-PatchTable
	dc.w	CodeC-PatchTable,(CodeCEnd-CodeC)/2-1,PatchC-PatchTable
	dc.w	CodeD-PatchTable,(CodeDEnd-CodeD)/2-1,PatchD-PatchTable
	dc.w	CodeE-PatchTable,(CodeEEnd-CodeE)/2-1,PatchE-PatchTable
	dc.w	0

; Audio Interrupt patch for Rob Hubbard modules from 1989-1990

Code1
	dc.l	$41FA000C
	move.l	A0,$70.W
Code1End
Patch1
	rts

; Address/Length/Volume patch for Rob Hubbard modules from 1989-1990

Code2
	move.l	0(A5),$A0(A6)
	move.w	8(A5),$A4(A6)
	move.w	14(A5),$A8(A6)
Code2End
Patch2
	move.l	D0,-(A7)
	move.l	(A5),D0
	bsr.w	PokeAdr
	move.w	8(A5),D0
	bsr.w	PokeLen
	move.w	14(A5),D0
	bsr.w	PokeVol
	move.l	(A7)+,D0
	rts

; Address/Volume/Length patch for Rob Hubbard modules from 1990

Code3	
	move.l	0(A5),$A0(A6)
	move.w	8(A5),$A4(A6)
	move.w	14(A5),D0
	tst.w	$26(A0)
	beq.b	lbC000282
	move.w	$26(A0),D0
lbC000282
	move.w	D0,$A8(A6)
Code3End
Patch3
	move.l	D0,-(A7)
	move.l	(A5),D0
	bsr.w	PokeAdr
	move.w	8(A5),D0
	bsr.w	PokeLen
	move.l	(A7)+,D0
	move.w	14(A5),D0
	tst.w	$26(A0)
	beq.b	Jump
	move.w	$26(A0),D0
Jump
	bsr.w	PokeVol
	rts

; Address/Volume/Length patch for Rob Hubbard modules from 1991

Code4
	move.l	0(A5),$A0(A6)
	move.w	8(A5),$A4(A6)
	clr.w	D0
	move.b	$26(A0),D0
	beq.b	lbC00027C
	move.w	D0,$A8(A6)
	bra.b	LbC000282
lbC00027C
	move.w	14(A5),$A8(A6)
LbC000282
	clr.w	D0
Code4End
Patch4
	move.l	D0,-(A7)
	move.l	(A5),D0
	bsr.w	PokeAdr
	move.w	8(A5),D0
	bsr.w	PokeLen
	move.l	(A7)+,D0
	clr.w	D0
	move.b	$26(A0),D0
	beq.b	Jump1
	bsr.w	PokeVol
	bra.b	Jump2
Jump1
	move.w	14(A5),D0
	bsr.w	PokeVol
Jump2	
	clr.w	D0
	rts

; SongEnd and Position Counter patch for Rob Hubbard modules from 1989-1991

Code5
	tst.l	(A2)
	bne.b	lbC000230
	move.l	8(A0),A2
	moveq	#4,D0
lbC000230
	move.l	(A2),A1
Code5End
Patch5
	movem.l	A1/A5,-(A7)
	tst.l	(A2)
	bne.b	NoZero
	lea	SongEnd(PC),A1
	cmp.l	#$DFF000,A6
	bne.b	test1
	clr.b	(A1)
	bra.b	test
test1
	cmp.l	#$DFF010,A6
	bne.b	test2
	clr.b	1(A1)
	bra.b	test
test2
	cmp.l	#$DFF020,A6
	bne.b	test3
	clr.b	2(A1)
	bra.b	test
test3
	cmp.l	#$DFF030,A6
	bne.b	test
	clr.b	3(A1)
test
	tst.l	(A1)
	bne.b	SkipEnd
	move.l	#'WTWT',(A1)+
	clr.l	(A1)					; CurrentPos
	move.l	EagleBase(PC),A5
	move.l	dtg_SongEnd(A5),A1
	jsr	(A1)
SkipEnd
	move.l	8(A0),A2
	moveq	#4,D0
NoZero	
	cmp.l	Hardware(PC),A6
	bne.b	ExitPos
	move.l	12(A0),CurrentPos
ExitPos
	movem.l	(A7)+,A1/A5
	move.l	(A2),A1
	rts

; Address/Length patch for Rob Hubbard modules from 1989-1991

Code6
	move.l	A2,$A0(A6)
	move.w	D1,$A4(A6)
Code6End
Patch6
	move.l	D0,-(A7)
	move.l	A2,D0
	bsr.w	PokeAdr
	move.w	D1,D0
	bsr.w	PokeLen
	move.l	(A7)+,D0
	rts

; Address/Length patch (x2) for Rob Hubbard modules from 1990-1991

Code7
	move.l	A2,$A0(A6)
	move.w	#$20,$A4(A6)
Code7End
Patch7
	move.l	D0,-(A7)
	move.l	A2,D0
	bsr.w	PokeAdr
	moveq	#$20,D0
	bsr.w	PokeLen
	move.l	(A7)+,D0
	rts

; Analyzer patch (x2) for Rob Hubbard modules from 1989

Code8
	move.l	A2,$A0(A6)
	move.w	#$100,$A4(A6)
Code8End
Patch8
	move.l	D0,-(A7)
	move.l	A2,D0
	bsr.w	PokeAdr
	move.w	#$100,D0
	bsr.w	PokeLen
	move.l	(A7)+,D0
	rts

; Period patch for Rob Hubbard modules from 1989-1991

Code9
	move.w	D0,$A6(A6)
	move.w	D0,$12(A0)
Code9End
Patch9
	bsr.w	PokePer
	move.w	D0,$12(A0)
	rts

; Analyzer patch for Rob Hubbard modules from 1989-1991

CodeA
	move.w	D0,$12(A0)
	move.w	D0,$A6(A6)
CodeAEnd
PatchA							; used Patch9

; Period patch for Rob Hubbard modules from 1989-1991

CodeB
	add.w	D1,D2
	move.w	D2,$A6(A6)
CodeBEnd
PatchB
	add.w	D1,D2
	move.l	D0,-(A7)
	move.l	D2,D0
	bsr.w	PokePer
	move.l	(A7)+,D0
	rts

; DMA patch (x2) for Rob Hubbard modules from 1989-1991

CodeC
	MOVE.W	D1,$DFF096
CodeCEnd
PatchC
	move.l	D0,-(A7)
	move.l	D1,D0
	bsr.w	PokeDMA
	move.l	(A7)+,D0
	rts

; DMA patch for Rob Hubbard modules from 1989-1991

CodeD
	MOVE.W	#15,$DFF096
	MOVE.W	#$FF,$DFF09E
CodeDEnd
PatchD
	move.l	D0,-(A7)
	moveq	#15,D0
	bsr.w	PokeDMA
	move.l	(A7)+,D0
	rts

; Enforcer fix for Rob Hubbard modules from 1989-1991

CodeE
	MOVE.L	A0,8(A1)
	MOVE.L	#4,12(A1)
CodeEEnd
PatchE
	move.l	A0,8(A1)
	move.l	#4,12(A1)
	move.l	#Pusty,$18(A1)
	rts
Pusty
	ds.b	8

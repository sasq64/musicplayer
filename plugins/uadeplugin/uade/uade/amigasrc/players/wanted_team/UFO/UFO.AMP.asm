	******************************************************
	****               UFO replayer for		  ****
	****    EaglePlayer 2.00+ (Amplifier version),    ****
	****    all adaptions by meynaf & Wanted Team	  ****
	******************************************************

	incdir	"dh2:include/"
	include 'misc/eagleplayer2.01.i'
	include	'misc/eagleplayerengine.i'
	include	'exec/exec_lib.i'

	SECTION	Player_Code,CODE

	EPPHEADER Tags

	dc.b	'$VER: UFO player module V2.0 (13 Dec 2009)',0
	even
Tags
	dc.l	DTP_PlayerVersion,2<<16!0
	dc.l	EP_PlayerVersion,11
	dc.l	DTP_PlayerName,PlayerName
	dc.l	DTP_Creator,Creator
	dc.l	EP_Check5,Check5
	dc.l	DTP_ExtLoad,ExtLoad
	dc.l	DTP_InitPlayer,InitPlayer
	dc.l	DTP_InitSound,InitSound
	dc.l	DTP_Interrupt,Interrupt
	dc.l	EP_NewModuleInfo,NewModuleInfo
	dc.l	EP_SampleInit,SampleInit
	dc.l	EP_InitAmplifier,InitAudstruct
	dc.l	EP_EagleBase,EagleBase
	dc.l	EP_Flags,EPB_ModuleInfo!EPB_SampleInfo!EPB_Songend!EPB_Analyzer!EPB_Packable!EPB_Restart
	dc.l	0

PlayerName
	dc.b	'UFO',0
Creator
	dc.b	'(c) 1994 by MicroProse,',10
	dc.b	'adapted by meynaf & Wanted Team',0
Prefix
	dc.b	'.MUS',0
SampleName
	dc.b	'SMP.set',0
	even
ModulePtr
	dc.l	0
SamplePtr
	dc.l	0
Timer
	dc.w	0
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
	move.w	A3,D1		;DFF0A0/B0/C0/D0
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
	move.w	A3,D1		;DFF0A0/B0/C0/D0
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
	move.w	A3,D1		;DFF0A0/B0/C0/D0
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
***************************** DTP_Interrupt *******************************
***************************************************************************

Interrupt
	movem.l	D1-A6,-(A7)

	bsr.w	int
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
******************************* EP_SampleInit *****************************
***************************************************************************

SampleInit
	moveq	#EPR_NotEnoughMem,D7
	lea	EPG_SampleInfoStructure(A5),A3
	move.l	ModulePtr(PC),D0
	beq.b	return

	lea	v17b0,A2
	moveq	#39,D5
Next
	jsr	ENPP_AllocSampleStruct(A5)
	move.l	D0,(A3)
	beq.b	return
	move.l	D0,A3

	move.l	4(A2),EPS_Adr(A3)		; sample address
	move.l	12(A2),EPS_Length(A3)		; sample length
	move.l	#64,EPS_Volume(A3)
	move.w	#USITY_RAW,EPS_Type(A3)
	move.w	#USIB_Playable!USIB_Saveable!USIB_8BIT,EPS_Flags(A3)
	lea	22(A2),A2
	dbf	D5,Next

	moveq	#0,D7
return
	move.l	D7,D0
	rts

***************************************************************************
***************************** EP_NewModuleInfo ****************************
***************************************************************************

NewModuleInfo

LoadSize	=	4
Samples		=	12
CalcSize	=	20
SamplesSize	=	28
SongSize	=	36

InfoBuffer
	dc.l	MI_LoadSize,0		;4
	dc.l	MI_Samples,0		;12
	dc.l	MI_Calcsize,0		;20
	dc.l	MI_SamplesSize,0	;28
	dc.l	MI_Songsize,0		;36
	dc.l	MI_MaxSamples,40
	dc.l	MI_Prefix,Prefix
	dc.l	0

***************************************************************************
******************************** EP_Check5 ********************************
***************************************************************************

Check5
	movea.l	dtg_ChkData(A5),A0
	moveq	#-1,D0

	cmp.l	#'FORM',(A0)+
	bne.b	Fault
	addq.l	#4,A0
	cmp.l	#'DDAT',(A0)+
	bne.b	Fault
	cmp.l	#'BODY',(A0)+
	bne.b	Fault
	addq.l	#4,A0
	cmp.l	#'CHAN',(A0)
	bne.b	Fault
	moveq	#0,D0
Fault
	rts

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
	jsr	ENPP_NewLoadFile(A5)
	tst.l	D0
	beq.b	ExtLoadOK
	move.l	dtg_PathArrayPtr(A5),A0
	clr.b	(A0)
	move.l	dtg_CopyDir(A5),A0
	jsr	(A0)
	bsr.b	CopyName2
	move.l	D7,EPG_ARG1(A5)
	move.l	D6,EPG_ARGN(A5)
	jsr	ENPP_NewLoadFile(A5)
ExtLoadOK
	rts

CopyName2
	movea.l	dtg_PathArrayPtr(A5),A0
loop1
	tst.b	(A0)+
	bne.s	loop1
	subq.l	#1,A0
	lea	SampleName(PC),A3
smp2
	move.b	(A3)+,(A0)+
	bne.s	smp2
	rts

CopyName
	movea.l	dtg_PathArrayPtr(A5),A0
loop
	tst.b	(A0)+
	bne.s	loop
	subq.l	#1,A0
	movea.l	dtg_FileArrayPtr(A5),A1
smp
	move.b	(A1)+,(A0)+
	bne.s	smp
	subq.l	#5,A0

	cmpi.b	#'.',(A0)+
	bne.s	ExtError

	cmpi.b	#'m',(A0)
	beq.b	m_OK
	cmpi.b	#'M',(A0)
	bne.s	ExtError
m_OK
	cmpi.b	#'u',1(A0)
	beq.b	u_OK
	cmpi.b	#'U',1(A0)
	bne.s	ExtError
u_OK
	cmpi.b	#'s',2(A0)
	beq.b	s_OK
	cmpi.b	#'S',2(A0)
	bne.s	ExtError
s_OK
	move.b	#'B',(A0)+
	move.b	#'A',(A0)+
	move.b	#'N',(A0)+
	move.b	#'K',(A0)+
	clr.b	(A0)
	rts

ExtError
	clr.b	-2(A0)
	rts

***************************************************************************
***************************** DTP_InitPlayer ******************************
***************************************************************************

InitPlayer
	moveq	#0,D0
	movea.l	dtg_GetListData(A5),A0
	jsr	(A0)

	lea	ModulePtr(PC),A6
	move.l	A0,(A6)+			; songdata buffer
	lea	InfoBuffer(PC),A4		; A4 reserved for InfoBuffer
	move.l	D0,LoadSize(A4)
	moveq	#8,D1
	add.l	4(A0),D1
	sub.l	D1,D0
	bmi.b	Short
	move.l	D1,SongSize(A4)
	move.l	D1,CalcSize(A4)
	moveq	#1,D0
	movea.l	dtg_GetListData(A5),A0
	jsr	(A0)

	move.l	A0,(A6)				; SamplePtr
	add.l	D0,LoadSize(A4)

	cmp.l	#'FORM',(A0)
	bne.b	InFile
	clr.l	(A0)+				; make empty sample
	moveq	#8,D1
	add.l	(A0)+,D1
	sub.l	D1,D0
	bmi.b	Short
	move.l	D1,SamplesSize(A4)
	add.l	D1,CalcSize(A4)
	cmp.l	#'ADAT',(A0)+
	bne.b	InFile
	cmp.l	#'BODY',(A0)+
	bne.b	InFile
	addq.l	#4,A0				; on passe form/adat/body
	lea	vac88,A4
	bsr.w	initspl
	moveq	#0,D0
	rts

Short
	moveq	#EPR_ModuleTooShort,D0
	rts

InFile
	moveq	#EPR_ErrorInFile,D0
	rts

***************************************************************************
***************************** DTP_InitSound *******************************
***************************************************************************

InitSound
	move.w	Timer(PC),D0
	bne.b	Done
	move.w	dtg_Timer(A5),D0
	mulu.w	#5,D0
	divu.w	#6,D0			; 60Hz
	move.w	D0,Timer
Done	move.w	D0,dtg_Timer(A5)

	move.l	ModulePtr(PC),A0
	lea	$14(A0),A0		; on passe form/ddat/body
	lea	vac88,A4
	bsr.w	initsng

	moveq	#0,D1
	moveq	#39,D0
	lea	v17b0+12,A0
NextSam
	tst.l	(A0)
	beq.b	NoSamp
	addq.l	#1,D1
NoSamp
	lea	22(A0),A0
	dbf	D0,NextSam
	lea	InfoBuffer(PC),A0
	move.l	D1,Samples(A0)
	bra.w	init_2

***************************************************************************
******************************** UFO player *******************************
***************************************************************************

; Player from game UFO (AGA version) (c) 1994 by MicroProse

; custom module ziks x-com ufo aga
; (9 .mus mais 8 ziks car doublon story.mus=lose.mus)

; mc68020			; version aga utilise 020+

 basereg vac88,a4

; moveq #-1,d0
; rts
; dc.b "DELIRIUM"
; dc.l tags
;tags
; dc.l $80004455,1		; custom
; dc.l $80004456,17		; dt version
; dc.l $8000445e,int		; interrupt
; dc.l $80004462,songs		; subsong range
; dc.l $80004463,alloc		; alloc audio
; dc.l $80004464,free		; free audio
; dc.l $80004465,init		; init
; dc.l $80004466,nosnd		; stop
; dc.l $80004469,volume		; master volume
; dc.l $80004473,savea5		; delibase
; dc.l $80004474,3		; custom+songend
; dc.l 0



; routine volume, récupère dtvol
; (à voir : modif volume à la volée)
;volume
; move.w $2e(a5),dtvol
; rts

; alloc/free simplissimes...
;alloc move.l $4c(a5),-(a7)
; rts
;free move.l $50(a5),-(a7)
; rts

; songs : 1 à 8
;songs
; moveq #1,d0
; moveq #8,d1
; rts

; init song & samples (une ré-init n'est pas gênante)
;init
; move.w #$2e9b,$36(a5)		; timer val (donne un peu moins de 60 hz)
; lea vac88,a4
; lea spl+$14,a0			; on passe form/ddat/body
; bsr initspl			; ne modifie pas a5
; move.w $2c(a5),d0		; song# (base 1)
; subq.w #1,d0			; (base 0)
; lea sng(pc),a0
; add.w (a0,d0.w*2),a0
; lea $14(a0),a0			; on passe form/adat/body
; bsr initsng
; inline u5a38 ici

init_2
; move.l a5,-(a7)
 lea v170c(a4),a5
; bsr u5846			; déjà appelé par initsng
; je vire ce tab : toujours à 0
; lea $1d3a(a4),a1
; clr.l (a1)+
; clr.l (a1)+			; je réordonne ces clr
; clr.l (a1)+			; (pour + de lisibilité)
; clr.l (a1)+			; clr.l $1d46(a4)
; réécrit plus tard, mais pas relu
; lea $ea(a4),a0
; clr.b (a0)+
; clr.b (a0)+
; clr.b (a0)+
; clr.b (a0)+			; clr.b $ed(a4)
 moveq #0,d1
u5a60 move.b #$7f,1(a5)
 addq.l #1,d1
 adda.w #$a,a5
 moveq #$10,d0
 cmp.l d0,d1
 blt.s u5a60
; clr.b 1(a4)
; move.w #$40,dtvol(a4)		; maintenant on utilise volume depuis dt
 st play(a4)			; move.w #1,2(a4)
; movea.l (a7)+,a5
 rts

;nosnd
; lea vac88,a4			; ajout à moi
;u5846
; clr.b play(a4)			; clr.w 2(a4)
; bra.s u581a
; clr.w $dff0a8
; clr.w $dff0b8
; clr.w $dff0c8
; clr.w $dff0d8
; move.l $3e(a4),d0		; ? : j'ai 0008
; move.w d0,$dff096
; move.w #15,$dff096
; rts

initsng
 subq.w #8,a7
 movem.l d6-d7/a2-a3/a5-a6,-(a7)
 movea.l a0,a3
 move.l a0,$1c(a7)
; bsr.s u5846
 moveq #0,d1
 moveq #0,d6
 lea v1ba8(a4),a5
 suba.l a2,a2
 suba.l a0,a0
 move.l a0,$18(a7)
u586a moveq #$10,d0
 cmp.l d0,d1
 bge.s u5884
 lea v1b28(a4),a0
 move.l a2,0(a0,d6.l)
 lea v1b68(a4),a0
 move.l $18(a7),0(a0,d6.l)
 clr.w (a5)
u5884 addq.l #1,d1
 addq.l #4,d6
 addq.l #2,a5
 moveq #$28,d0
 cmp.l d0,d1
 blt.s u586a
 clr.l nblck(a4)
u5894
; moveq #3,d0
; movea.l a3,a0
; lea ud2e8,a1		; d2e8  buff tmp
;u589e move.b (a0)+,(a1)+
; dbf d0,u589e
 lea 4(a3),a5
; lea ud2e8,a0
; lea ud2ee,a1		; chan
; movea.l $5ec(a4),a6
; jsr -$a2(a6)			; utility.library/stricmp
 move.l (a3),d0
 cmpi.l #"CHAN",d0		; tst.l d0
 bne.s u5912
 moveq #0,d7
 move.b 5(a5),d7
 lea 6(a5),a0
 lea v1b28(a4),a1
;  move.l a0,0(a1,d7.l*4)

	add.w	D7,D7
	add.w	D7,D7
	move.l	A0,(A1,D7.L)
	lsr.w	#1,D7

 move.l a0,chan(a4)
 lea v1ba8(a4),a6
;  lea 0(a6,d7.l*2),a1

	lea	(A6,D7.L),A1

 movea.l a1,a3
 lea v1bc8(a4),a6
;  lea 0(a6,d7.l*2),a1

	lea	(A6,D7.L),A1

 movea.l a1,a2
 bsr u605e
 move.w d0,(a2)
 move.w d0,(a3)
 movea.l chan(a4),a0
 lea v1b68(a4),a1
;  move.l a0,0(a1,d7.l*4)

	add.w	D7,D7
	move.l	A0,(A1,D7.L)

 lea v1b28(a4),a0
;  move.l chan(a4),0(a0,d7.l*4)

	move.l	chan(a4),(A0,D7.L)

 movea.l a5,a0
 adda.l (a5),a0
 lea 4(a0),a3
 bra.s u5894
u5912
; lea ud2e8,a0
; lea ud2f4,a1		; drum
; jsr -$a2(a6)
 cmpi.l #"DRUM",d0	; tst.l d0
 bne.s u5936
; lea 4(a5),a0
; move.l a0,$1b24(a4)	; pas relu...
 lea $54(a5),a3
 bra u5894
u5936
; lea ud2e8,a0
; lea ud2fa,a1		; "bpm "
; jsr -$a2(a6)
 cmpi.l #"BPM ",d0	; tst.l d0
 bne.s u5958
 move.b 1(a5),bpm(a4)
 lea 2(a5),a3
 bra u5894
u5958
; lea ud2e8,a0
; lea ud300,a1		; blck
; jsr -$a2(a6)
 cmpi.l #"BLCK",d0	; tst.l d0
 bne.s u5988
 move.l nblck(a4),d0
 addq.l #1,nblck(a4)
 lea 4(a5),a0
 lea blck(a4),a1
;  move.l a0,0(a1,d0.l*4)

	add.l	D0,D0
	add.l	D0,D0
	move.l	A0,(A1,D0.L)

 movea.l a5,a3
 adda.l (a5),a3
 bra u5894
u5988
; lea ud2e8,a0
; lea ud306,a1		; inst
; jsr -$a2(a6)
 cmpi.l #"INST",d0	; tst.l d0
 bne.s u59fc
 moveq #0,d0
 lea 5(a5),a2
 move.b (a2)+,d0
 move.l d0,d1
 asl.l #2,d1		; *4
 sub.l d0,d1		; *3
 asl.l #2,d1		; *12
 sub.l d0,d1		; *11
 add.l d1,d1		; *22
 lea v17b0(a4),a3
 adda.l d1,a3
 move.l (a2)+,d0
 lea $c(a3),a6
 move.l d0,(a6)+
 movea.l (a2)+,a0
 move.l a0,4(a3)
 move.b #$63,(a6)+
 move.b $f(a5),(a6)+
 lea $10(a5),a1
 move.l a1,(a3)
 movea.l a5,a6
 adda.l d0,a6
 lea $10(a6),a1
 move.l a1,8(a3)
 move.l a0,d0
 beq.s u59f0
 moveq #1,d0
 move.l d0,$12(a3)
 move.l (a3),d0
 add.l d0,4(a3)
 bra.s u59f4
u59f0 clr.l $12(a3)
u59f4 movea.l a5,a3
 adda.l (a5),a3
 bra u5894
u59fc
; lea ud2e8,a0
; lea ud30c,a1		; "end "
; jsr -$a2(a6)
; le résultat n'était pas testé, je laisse
; cmpi.l #"END ",d0	; tst.l d0
 moveq #0,d0
 move.b bpm(a4),d0
 move.l d0,d1
 asl.l #2,d1			; *4
 sub.l d0,d1			; -*1 (*3)
 asl.l #3,d1			; *8 (*24)
; phxass assemble divsl.l, pas divs.l !!!
 divu #$3c,d1		;  divs.l #$3c,d1:d1		; /60 (*2/5)
 move.b d1,bpm(a4)
 moveq #0,d0
 move.b d1,d0
 move.l d0,count(a4)	; init compteur
 movem.l (a7)+,d6-d7/a2-a3/a5-a6
 addq.w #8,a7
 rts

u5a8e movem.l d5-d7/a5,-(a7)
 move.l d1,d6
 move.l d0,d7
 move.w $16(a7),d0
 swap d0
 clr.w d0			; high=0
 swap d0
 move.l d0,d1
 asl.l #3,d1			; *8
 sub.l d0,d1			; en fait *7
 add.l d1,d1			; *14
 lea v16d4(a4),a5
 adda.l d1,a5
; ces deux-là remplacent tout ce qui suit...
 move.w d6,d0
 mulu #$a,d0
; swap d6
; clr.w d6		; high=0
; swap d6
; move.l d6,d0
; asl.l #2,d0		; *4
; sub.l d6,d0		; en fait *3
; add.l d0,d0		; *6
; sub.l d6,d0		; en fait *5
; add.l d0,d0		; *10
 lea v170c(a4),a0
 move.b 2(a0,d0.l),d5
 bne.s u5ace
 move.w d7,d0
 bra.s u5afc
u5ace tst.b d5
 ble.s u5ae6
 move.b d5,d0
;  extb.l d0

	ext.w	D0
;	ext.l	D0

 moveq #0,d1
 move.w (a5),d1
;  muls.l d0,d1

	muls.w	D0,D1

 moveq #0,d0
 move.w d7,d0
 sub.l d1,d0
 bra.s u5afc
u5ae6 move.b d5,d0
 neg.b d0
;  extb.l d0

	ext.w	D0
;	ext.l	D0

 moveq #0,d1
 move.w 2(a5),d1
;  muls.l d0,d1

	muls.w	D0,D1

 moveq #0,d0
 move.w d7,d0
 add.l d1,d0
u5afc movem.l (a7)+,d5-d7/a5
 rts

u5b02 subq.w #8,a7
 movem.l d2-d3/d6-d7/a2-a3/a5,-(a7)
 move.l $30(a7),d6
 move.l $2c(a7),d7
 move.l d1,d2
 move.l d0,d3
 move.l d6,d1
 asl.l #3,d1
 sub.l d6,d1
 add.l d1,d1
 lea v16d4(a4),a5
 adda.l d1,a5
; lea $1d3a(a4),a0
;  tst.l 0(a0,d6.l*4)
; bne u5cd2			; pas possible qu'on y aille
 moveq #$18,d1
 sub.l d1,d2
 bra.s u5b38
u5b34 moveq #$c,d0
 add.l d0,d2
u5b38 tst.l d2
 bmi.s u5b34
 tst.l $28(a7)
 bne.s u5b8e
 moveq #0,d1
 lea v16d4(a4),a3
; lea $1d3a(a4),a2
u5b4c
; tst.l (a2)
; bne.s u5b7c			; idem
 move.w $a(a3),d0
 ext.l d0
 cmp.l d7,d0
 bne.s u5b7c
 move.w $c(a3),d0
 ext.l d0
 cmp.l d2,d0
 bne.s u5b7c
; lea vflg(a4),a0		; je me comporte comme s'il était toujours à 1
; tst.b 0(a0,d1.l)
; beq.s u5b7c
 move.b 5(a3),d0
 neg.b d0
 move.b d0,6(a3)
 clr.b 8(a3)
u5b7c addq.l #1,d1
 adda.w #$e,a3
; addq.l #4,a2			; plus la peine
 moveq #4,d0
 cmp.l d0,d1
 blt.s u5b4c
 bra u5cd2
u5b8e tst.l d2
 bmi u5cd2
 move.l d3,d0
 asl.l #2,d0
 sub.l d3,d0
 asl.l #2,d0
 sub.l d3,d0
 add.l d0,d0
 lea v17b0(a4),a2
 adda.l d0,a2
 moveq #1,d0		; lea $32(a4),a0
 lsl.l d6,d0		;  move.l 0(a0,d6.l*4),d0
; move.w d0,$dff096		; DMA off
; moveq #$f,d0
; jsr z58f8

	bsr.w	PokeDMA

 tst.l (a2)
 beq u5cd2
 move.w d2,$c(a5)
; même principe que $ea : à quoi bon écrire une var jamais relue ???
; lea $ee(a4),a0
;  move.w d3,0(a0,d6.l*2)
 move.w d7,$a(a5)
 moveq #$63,d0
 move.b d0,6(a5)
 move.b d0,4(a5)
 move.b $11(a2),5(a5)
 lea tbp(pc),a3			; lea $42(a4),a3
;  lea 0(a3,d2.l*2),a0

	add.l	D2,D2
	lea	(A3,D2.L),A0
;	lsr.l	#1,D2

 moveq #0,d1
 move.w 4(a0),d1
 moveq #0,d0
 move.w (a0),d0
 sub.l d1,d0
 asr.l #4,d0
 move.w d0,(a5)
 moveq #0,d0
 move.w (a0),d0
 moveq #0,d1
 move.w -4(a0),d1
 move.l d1,d3
 sub.l d0,d3
 asr.l #4,d3
 move.w d3,2(a5)
 move.l $28(a7),d2
 move.b d2,8(a5)
 move.l d7,d1
 mulu #10,d1		; asl.l #2,d1
; sub.l d7,d1
; add.l d1,d1
; sub.l d7,d1
; add.l d1,d1
 move.w (a0),d3
 lea v170c(a4),a3
 move.w d3,4(a3,d1.l)
 move.l d6,d1
 asl.l #4,d1
 lea $dff0a0,a3
 adda.l d1,a3
; move.l (a2),(a3)			; address

	move.l	D0,-(SP)
	move.l	(A2),D0
	bsr.w	PokeAdr
	move.l	(SP)+,D0

 moveq #0,d1
 move.w (a0),d1
 moveq #0,d3
 move.w d7,d3
 moveq #0,d0
 move.w d6,d0
 move.l d0,-(a7)
 move.l d1,d0
 move.l d3,d1
 bsr u5a8e
 addq.w #4,a7
; move.w d0,6(a3)			; period

	bsr.w	PokePer

 move.l 8(a2),d0
 sub.l (a2),d0
 bpl.s u5c60
 addq.l #1,d0
u5c60 asr.l #1,d0
; move.w d0,4(a3)			; length

	bsr.w	PokeLen

 moveq #$63,d0
 cmp.b 4(a5),d0			; à priori toujours $63
 beq.s u5c78
; clr.w 8(a3)				; volume

	movem.l	D0/A2,-(SP)
	moveq	#0,D0
	move.l	A3,A2
	bsr.w	PokeVol
	movem.l	(SP)+,D0/A2

 clr.b 7(a5)
 bra.s u5c8c
u5c78
; moveq #0,d0
; move.w dtvol(a4),d0
; muls.l d0,d2
; asr.l #6,d2
; move.w d2,8(a3)			; volume

	movem.l	D0/A2,-(SP)
	move.l	D2,D0
	move.l	A3,A2
	bsr.w	PokeVol
	movem.l	(SP)+,D0/A2

 move.b d2,7(a5)
u5c8c
 move.w #$8001,d0		; move.l #$8200,d0
; lea $32(a4),a0
 lsl.b d6,d0			;  add.l 0(a0,d6.l*4),d0
; move.w d0,$dff096		; DMA on
; moveq #5,d0
; jsr z58f8

	bsr.w	PokeDMA

 tst.l $12(a2)
 beq.s u5cc6
 move.l 8(a2),d0
 sub.l 4(a2),d0
 bpl.s u5cba
 addq.l #1,d0
u5cba asr.l #1,d0
; move.w d0,4(a3)			; length
; move.l 4(a2),(a3)			; address

	bsr.w	PokeLen
	move.l	D0,-(SP)
	move.l	4(A2),D0
	bsr.w	PokeAdr
	move.l	(SP)+,D0

 bra.s u5cd2
u5cc6
; move.w #2,4(a3)			; length
; move.l #w2078,(a3)			; address

	move.l	D0,-(SP)
	move.l	SamplePtr(PC),D0
	bsr.w	PokeAdr
	moveq	#2,D0
	bsr.w	PokeLen
	move.l	(SP)+,D0

u5cd2 movem.l (a7)+,d2-d3/d6-d7/a2-a3/a5
 addq.w #8,a7
 rts

u5cda movem.l d7/a2-a3/a5,-(a7)
 moveq #0,d7
 lea v16d4(a4),a5
; lea $1d3a(a4),a3
 lea $dff0a0,a2
u5cee
; tst.l (a3)
; bne.s u5d42			; pas possible
 lea 6(a5),a1
 move.b (a1)+,d0	; lit 6(a5)
;  extb.l d0

	ext.w	D0
	ext.l	D0

 move.b (a1),d1		; lit 7(a5)
;  extb.l d1

	ext.w	D1
	ext.l	D1

 add.l d1,d1
 add.l d0,d1
 asr.l #1,d1
 move.b d1,(a1)+	; écrit en 7(a5)
 move.b 6(a5),d0
 bpl.s u5d1c
 tst.b d1
 bpl.s u5d2c
 moveq #0,d0
 move.b d0,7(a5)
 move.b d0,6(a5)
 bra.s u5d2c
u5d1c move.b 8(a5),d0
 cmp.b d0,d1
 ble.s u5d2c
 move.b d0,7(a5)
 clr.b 6(a5)
u5d2c
 tst.b play(a4)		; tst.w 2(a4)
 beq.s u5d3e
 move.b 7(a5),d0
 ext.w d0
; leur master volume ne marchait pas : oubli ici...
; mulu dtvol(a4),d0
; lsr.w #6,d0
; move.w d0,8(a2)		; volume

	bsr.w	PokeVol

 bra.s u5d42
u5d3e
; clr.w 8(a2)		; volume

	move.l	D0,-(SP)
	moveq	#0,D0
	bsr.w	PokeVol
	move.l	(SP)+,D0

u5d42 addq.l #1,d7
 adda.w #$e,a5
; addq.l #4,a3		; devenu inutile
 adda.w #$10,a2
 moveq #4,d0
 cmp.l d0,d7
 blt.s u5cee
 movem.l (a7)+,d7/a2-a3/a5
 rts
u5d5a movem.l d7/a3/a5,-(a7)
; moveq #0,d1
; lea $1d3a(a4),a5		; var 1d3a virée, cette boucle devient inutile
;u5d64 move.l (a5),d0
; beq.s u5d76
; subq.l #1,(a5)
; bne.s u5d76
; lea vflg(a4),a0
; move.b #1,0(a0,d1.l)
;u5d76 addq.l #1,d1
; addq.l #4,a5
; moveq #4,d0
; cmp.l d0,d1
; blt.s u5d64
 tst.b play(a4)			; tst.w 2(a4)
 beq.s u5dec
 moveq #0,d0
 move.b bpm(a4),d0
 sub.l d0,count(a4)
 bgt.s u5dec
 moveq #$78,d0
 add.l d0,count(a4)
 moveq #0,d7
 lea v1b28(a4),a5
 lea v1ba8(a4),a3
u5da2 clr.l v1d4a(a4)
 tst.l (a5)
 beq.s u5de0
 tst.w (a3)
 bne.s u5dde
 move.l d7,d0
 bsr u5e78
 move.w d0,(a3)
 tst.l v1d4a(a4)
 beq.s u5dde
 moveq #$3f,d0
 lea v1b68(a4),a0
 lea v1b28(a4),a1
u5dc6 move.b (a0)+,(a1)+
 dbf d0,u5dc6
 moveq #$1f,d0
 lea v1bc8(a4),a0
 lea v1ba8(a4),a1
u5dd6 move.b (a0)+,(a1)+
 dbf d0,u5dd6
 bra.s u5dec
u5dde subq.w #1,(a3)
u5de0 addq.l #1,d7
 addq.l #4,a5
 addq.l #2,a3
 moveq #$10,d0
 cmp.l d0,d7
 blt.s u5da2
u5dec movem.l (a7)+,d7/a3/a5
 rts

int
; movem.l d0-d7/a0-a6,-(a7)		; par prudence
 lea vac88,a4
 bsr u5d5a
 bsr u5d5a
 bsr u5cda
; ajout : signaler songend (code recopié...)
; tst.b songendf
; bpl.s .no
; move.l savea5,a5
; move.l $5c(a5),a0
; jsr (a0)
; clr.b songendf
;.no
; movem.l (a7)+,d0-d7/a0-a6
 rts

u5e0a subq.w #4,a7
 movem.l d6-d7,-(a7)
 move.l d0,d7
 moveq #3,d1
 and.l d1,d7
; lea vflg(a4),a0		; à priori toujours à 01
; tst.b 0(a0,d7.l)
; bne.s u5e24
; moveq #-1,d0
; bra.s u5e70
;u5e24
; tst.b $10(a4)		; toujours 00 ?
; beq.s u5e6e
; zone jusqu'à 5e6e est virée

u5e6e move.l d7,d0
u5e70 movem.l (a7)+,d6-d7
 addq.w #4,a7
 rts

u5e78 subq.w #8,a7
 movem.l d2-d7/a3/a5,-(a7)
 move.l d0,d7
 mulu #10,d0		; asl.l #2,d0
; sub.l d7,d0
; add.l d0,d0
; sub.l d7,d0
; add.l d0,d0
 lea v170c(a4),a0
 adda.l d0,a0
 movea.l a0,a5
 move.l d7,d0
 moveq #3,d1
 and.l d1,d0
 lea v1b28(a4),a1
;  lea 0(a1,d7.l*4),a0

	add.l	D7,D7
	add.l	D7,D7
	lea	(A1,D7.L),A0
	lsr.l	#2,D7

 movea.l a0,a3
 move.l (a3),chan(a4)
 move.b d0,$24(a7)
u5eaa movea.l chan(a4),a0
 addq.l #1,chan(a4)
 move.b (a0),d5
 cmpi.b #$fe,d5
 bne.s u5ee8
 lea chan(a4),a1
 movea.l (a1),a0
 addq.l #1,(a1)
 move.b (a0),d0
 move.l (a1)+,6(a5)
 moveq #0,d1
 move.b d0,d1
 moveq #0,d0
 move.w d1,d0
 lea blck(a4),a0
;  move.l 0(a0,d0.l*4),chan(a4)

	add.l	D0,D0
	add.l	D0,D0
	move.l	(A0,D0.L),chan(a4)
;	lsr.l	#2,D0

 bsr u605e
 move.w d0,d6
 beq u604a
 bra u6050
u5ee8 cmpi.b #$fd,d5
 bne.s u5f06
 movea.l 6(a5),a0
 move.l a0,(a3)
 move.l a0,chan(a4)
 bsr u605e
 move.w d0,d6
 beq u604a
 bra u6050
u5f06 cmpi.b #$ff,d5
 bne.s u5f16
; st songendf(a4)		; songeng par arrêt complet (dans song#8)

	bsr.w	SongEnd

 clr.b play(a4)			; clr.w 2(a4)
 moveq #0,d0
 bra u6056
u5f16 cmpi.b #$80,d5
 bcs.s u5f2e
 lea v1d2a(a4),a0
 move.b d5,0(a0,d7.l)
 movea.l chan(a4),a1
 addq.l #1,chan(a4)
 move.b (a1),d5
u5f2e moveq #-$10,d0
 lea v1d2a(a4),a0
 and.b 0(a0,d7.l),d0
 moveq #0,d1
 move.b d0,d1
 subi.l #$80,d1
 beq.s u5fb0
 moveq #$10,d0
 sub.l d0,d1
 beq.s u5f64
 moveq #$20,d0
 sub.l d0,d1
 beq u5fe2
 moveq #$10,d0
 sub.l d0,d1
 beq.s u5fce
 moveq #$20,d0
 sub.l d0,d1
 beq u6030
 bra u6044
u5f64 movea.l chan(a4),a0
 addq.l #1,chan(a4)
 move.b (a0),d4
 move.l d7,d0
 bsr u5e0a
 move.l d0,$20(a7)
 moveq #-1,d1
 cmp.l d1,d0
 beq u6044
 moveq #0,d1
 move.b (a5),d1
 moveq #0,d2
 move.b d5,d2
 moveq #0,d3
 move.b 1(a5),d3
 moveq #0,d0
 move.b d4,d0
;  muls.l d3,d0

	mulu.w	D3,D0

 asr.l #8,d0
 move.l $20(a7),-(a7)
 move.l d7,-(a7)
 move.l d0,-(a7)
 move.l d1,d0
 move.l d2,d1
 bsr u5b02
 lea $c(a7),a7
 bra u6044
u5fb0 addq.l #1,chan(a4)
 moveq #0,d0
 move.b (a5),d0
 moveq #0,d1
 move.b d5,d1
 moveq #0,d2
 move.l d2,-(a7)
 move.l d7,-(a7)
 move.l d2,-(a7)
 bsr u5b02
 lea $c(a7),a7
 bra.s u6044
u5fce moveq #$7e,d0
 cmp.b d0,d5
 bne.s u5fde
; st songendf(a4)			; songend par retour au début

	bsr.w	SongEnd

 moveq #1,d0
 move.l d0,v1d4a(a4)
 moveq #0,d0
 bra.s u6056
u5fde move.b d5,(a5)
 bra.s u6044
u5fe2 movea.l chan(a4),a0
 addq.l #1,chan(a4)
 move.b (a0),d4
 moveq #0,d0
 move.b d5,d0
 tst.l d0
 beq.s u6000
 subq.l #7,d0
 beq.s u601a
 moveq #$d,d1
 sub.l d1,d0
 beq.s u6020
 bra.s u6044
u6000 moveq #0,d0
 move.b d4,d0
 move.l d0,d1
 asl.l #2,d1
 sub.l d0,d1
 asl.l #4,d1
 divu #$3c,d1			;  divs.l #$3c,d1:d1
 move.b d1,bpm(a4)
 bra.s u6044
u601a move.b d4,1(a5)
 bra.s u6044
u6020
; j'écris le truc ($ea,a4), mais jamais je le relis...
; moveq #0,d0
; move.b $24(a7),d0
; lea $ea(a4),a0
; move.b d4,0(a0,d0.w)
 bra.s u6044
u6030 move.b d5,d0
 subi.b #$10,d0
 move.b d0,2(a5)
 moveq #0,d1
 move.w d7,d1
 move.l d1,d0
 bsr u608c
u6044 bsr u605e
 move.w d0,d6
u604a tst.w d6
 beq u5eaa
u6050 move.l chan(a4),(a3)
 move.w d6,d0
u6056 movem.l (a7)+,d2-d7/a3/a5
 addq.w #8,a7
 rts

u605e movem.l d6-d7,-(a7)
 moveq #0,d7
u6064 movea.l chan(a4),a0
 addq.l #1,chan(a4)
 moveq #0,d6
 move.b (a0),d6
 move.w d6,d0
 andi.w #$7f,d0
 move.w d7,d1
 asl.w #7,d1
 add.w d0,d1
 move.l d1,d7
 btst #7,d6
 bne.s u6064
 move.w d7,d0
 movem.l (a7)+,d6-d7
 rts

u608c movem.l d2-d3/d7,-(a7)
 move.l d0,d7
 moveq #0,d0
; move.w d7,d0
; lea $1d3a(a4),a0
;  tst.l 0(a0,d0.l*4)
; bne.s u60ea			; plus possible
 move.w d7,d0		; swap d7
 mulu #10,d0		; clr.w d7
; swap d7
; move.l d7,d0
; asl.l #2,d0
; sub.l d7,d0
; add.l d0,d0
; sub.l d7,d0
; add.l d0,d0
 moveq #0,d1
 lea v170c(a4),a0
 move.w 4(a0,d0.l),d1
 moveq #0,d0
 move.w d7,d0
 move.w d7,d2
 andi.w #3,d2
 moveq #0,d3
 move.w d2,d3
 move.l d3,-(a7)
 exg d0,d1
 bsr u5a8e
 addq.w #4,a7
 move.w d7,d1
 andi.w #3,d1
 ext.l d1
 asl.l #4,d1
 lea $dff0a0,a0
 adda.l d1,a0
; move.w d0,6(a0)		; period

	move.l	A3,-(SP)
	move.l	A0,A3
	bsr.w	PokePer
	move.l	(SP)+,A3

u60ea movem.l (a7)+,d2-d3/d7
 rts

initspl
 movem.l d6-d7/a3/a5,-(a7)
 moveq #0,d7
 lea v17b0(a4),a3
u60fa move.l (a0),$c(a3)
 move.l 4(a0),d0
 beq.s u610c
 moveq #1,d1
 move.l d1,$12(a3)
 bra.s u6110
u610c clr.l $12(a3)
u6110 lea 4(a0),a5
 move.l (a5)+,4(a3)
 move.b (a5)+,$10(a3)
 move.b (a5)+,$11(a3)
 addq.l #1,d7
 adda.w #$16,a3
 adda.w #$a,a0
 moveq #$28,d0
 cmp.l d0,d7
 blt.s u60fa
; move.l a0,$1b24(a4)		; pas relu...
; movea.l $1b24(a4),a0		; vachement utile...
 adda.w #$54,a0
 move.l a0,d6
 moveq #0,d1
 lea v17b0(a4),a3
u6144 move.l $c(a3),d0
 beq.s u6156
 lea (a3),a5
 move.l d6,(a5)+
 add.l d6,(a5)+
 add.l $c(a3),d6
 move.l d6,(a5)+
u6156 addq.l #1,d1
 adda.w #$16,a3
 moveq #$28,d0
 cmp.l d0,d1
 blt.s u6144
 movem.l (a7)+,d6-d7/a3/a5
 rts

;z58f8
; movem.l d0-d2,-(a7)
; move.w $dff006,d1
; andi.w #$ff00,d1
;.re move.w $dff006,d2
; andi.w #$ff00,d2
; cmp.w d1,d2
; beq.s .re
; move.w d2,d1
; dbf d0,.re
; movem.l (a7)+,d0-d2
; rts


; 1009 m'a l'air d'un bug : je mets $0d09 à la place
tbp
 dc.w $0fbe,$0eee,$0df7,$0d09,$0c8c,$0bdc,$0b1a,$0a8f
 dc.w $09f4,$0969,$08d6,$0853,$07df,$0766,$070a,$069c
 dc.w $063a,$05e4,$058d,$053f,$04f2,$04ae,$046b,$0429
 dc.w $03ef,$03b7,$0381,$034e,$0320,$02f2,$02c8,$029f
 dc.w $027b,$0257,$0235,$0216,$01f7,$01db,$01c0,$01a7
 dc.w $0190,$0179,$0164,$0150,$013d,$012b,$011a,$010a
 dc.w $00fb,$00ed,$00e0,$00d3,$00c7,$00bc,$00b2,$00a8
 dc.w $009e,$0095,$008d,$0086,$00fb,$00ed,$00e0,$00d3
 dc.w $00c7,$00bc,$00b2,$00a8,$009e,$0095,$008d,$0086
 dc.w $00fb,$00ed,$00e0,$00d3,$00c7,$00bc,$00b2,$00a8
 dc.w $009e,$0095,$008d,$0086

; vars(a4)
; 0.b : bpm ($36)
; 1.b : ? (mis à 0 dans init, on n'en sait pas plus)
; 2.w : flag playing
; 4.l : compteur de blck ($47)
; $c-$f : 4 flags (prob. 1 par voie) - var vflg(a4) dans le code
; $10.b : juste testé (et à 0)
; $32.4l : 1,2,4,8 pour 096
; $42-$e9 : tab périodes
; $ea.4b : ? (juste écrit)
; $ee.4w : ? (juste écrit)
; $5ec.l : utility base
; $16d4 : tab de $e*4 .b
; $170c : tab de $a*16 .b
; $17ac.l : ptr dans zone "chan"
; $17b0 : $16*$28 .b, lié à samples
; $1b20.l : compteur lié à bpm
; $1b24.l : drum adr (peut-être pour sync effets visuels)
; $1b28 : tab $40
; $1b68 : tab $40 (save 1b28)
; $1ba8 : tab $20
; $1bc8 : tab $20 (save 1ba8)
; $1be8.w : master volume (deb $40)
; $1bea.$50l : tab des blck
; $1d2a.16b : tab 16 bytes
; $1d3a.4l : (tab voies - 1d46 est direct v3 - ceci reste à 0 ici)
; $1d4a.l : (non identifié)
; -> $c/$1d3a semble être en rapport avec les effets (adr, flag voie music)


; partitions
;sng
; dc.w s1-sng,s2-sng,s3-sng,s4-sng,s5-sng,s6-sng,s7-sng,s8-sng
;s1 incbin ram:story.mus		; lose.mus est identique avec celui-ci !!!
;s2 incbin ram:geo.mus
;s3 incbin ram:inter.mus
;s4 incbin ram:defend.mus
;s5 incbin ram:enbase.mus
;s6 incbin ram:mars.mus		; rien à voir avec mars : c'est fin mission !
;s7 incbin ram:newmars.mus
;s8 incbin ram:win.mus

; instruments
	Section	Data,data_c
;spl
; incbin ram:ufo.bank
;w2078
; dc.l 0			; silence


; variables
	Section	Buffy,bss
vac88			; vac88, 0000 ici
;savea5 ds.l 1		; ajouté
nblck ds.l 1		; 4
chan ds.l 1		; $17ac
count ds.l 1		; $1b20
v1d4a ds.l 1		; $1d4a
blck ds.l $50		; $1bea (ça va jusqu'en 1d2a)
v16d4 ds.b 14*4		; $16d4 (4 blocs de $e)
v170c ds.b $a0		; $170c ($10 blocs de $a)
v17b0 ds.b $16*40	; $17b0 ($16 blocs de $28, samples)
v1b28 ds.b $40		; $1b28
v1b68 ds.b $40		; $1b68 (recopié dans 1b28)
v1ba8 ds.b $20		; $1ba8
v1bc8 ds.b $20		; $1bc8 (recopié dans 1ba8)
v1d2a ds.b $10		; $1d2a
;dtvol ds.w 1		; $1be8
bpm ds.b 1		; 0
play ds.b 1		; 2 (changé en .b)
;songendf ds.b 1		; flag pour songend dt

	****************************************************
	****          Steve Turner replayer for 	****
	****    EaglePlayer 2.00+ (Amplifier version),  ****
	****         all adaptions by Wanted Team       ****
	****************************************************

	incdir	"dh2:include/"
	include 'misc/eagleplayer2.01.i'
	include	'misc/eagleplayerengine.i'
	include	'exec/exec_lib.i'

	SECTION	Player_Code,CODE

	EPPHEADER Tags

	dc.b	'$VER: Steve Turner player module V2.0 (17 June 2001)',0
	even
Tags
	dc.l	DTP_PlayerVersion,2<<16!0
	dc.l	EP_PlayerVersion,11
	dc.l	DTP_PlayerName,PlayerName
	dc.l	DTP_Creator,Creator
	dc.l	EP_Check5,Check5
	dc.l	DTP_SubSongRange,SubSongRange
	dc.l	DTP_InitPlayer,InitPlayer
	dc.l	DTP_InitSound,InitSound
	dc.l	DTP_EndSound,EndSound
	dc.l	DTP_Interrupt,Interrupt
	dc.l	EP_NewModuleInfo,NewModuleInfo
	dc.l	EP_Flags,EPB_ModuleInfo!EPB_Save!EPB_Songend!EPB_NextSong!EPB_PrevSong!EPB_SampleInfo!EPB_Packable!EPB_Restart
	dc.l	EP_SampleInit,SampleInit
	dc.l	EP_GetPositionNr,GetPosition
	dc.l	EP_InitAmplifier,InitAudstruct
	dc.l	EP_EagleBase,EagleBase
	dc.l	0

PlayerName
	dc.b	'Steve Turner',0
Creator
	dc.b	'(c) 1989-90 by Steve Turner,',10
	dc.b	'adapted by Mr.Larmer/Wanted Team',0
Prefix
	dc.b	'JPO.',0
	even

ModulePtr
	dc.l	0
FirstPos
	dc.l	0
StartPos
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
	sub.w	#$00A8,D1	;D1 = $A8/B8/C8/D8
	lsr.w	#4,D1		;Number the channel from 0-3
	move.l	EagleBase(PC),A5
	jsr	ENPP_PokeVol(A5)
	movem.l	(SP)+,D1/A5
	rts

*---------------------------------------------------------------------------*
* Input		Volume value is always 0
ClearVol
	movem.l	D0/D1/A5,-(SP)
	move.w	D0,D1		;D1 = $A8/B8/C8/D8
	sub.w	#$00A8,D1
	lsr.w	#4,D1		;Number the channel from 0-3
	moveq	#0,D0
	move.l	EagleBase(PC),A5
	jsr	ENPP_PokeVol(A5)
	movem.l	(SP)+,D0/D1/A5
	rts

*---------------------------------------------------------------------------*
* Input		A0 = Address value
PokeAdr
	movem.l	D0/D1/A5,-(SP)
	move.w	D0,D1		;D1 = $A0/B0/C0/D0
	sub.w	#$00A0,D1
	lsr.w	#4,D1		;Number the channel from 0-3
	move.l	A0,D0
	move.l	EagleBase(PC),A5
	jsr	ENPP_PokeAdr(A5)
	movem.l	(SP)+,D0/D1/A5
	rts

*---------------------------------------------------------------------------*
* Input		D1 = Length value
PokeLen
	movem.l	D0/D1/A5,-(SP)
	exg	D0,D1		;D1 = $A4/B4/C4/D4
	sub.w	#$00A4,D1
	lsr.w	#4,D1		;Number the channel from 0-3
	and.l	#$FFFF,D0
	move.l	EagleBase(PC),A5
	jsr	ENPP_PokeLen(A5)
	movem.l	(SP)+,D0/D1/A5
	rts

*---------------------------------------------------------------------------*
* Input		D1 = Period value
PokePer
	movem.l	D0/D1/A5,-(SP)
	exg	D0,D1		;D1 = $A6/B6/C6/D6
	sub.w	#$00A6,D1
	lsr.w	#4,D1		;Number the channel from 0-3
	move.l	EagleBase(PC),A5
	jsr	ENPP_PokePer(A5)
	movem.l	(SP)+,D0/D1/A5
	rts
	
*---------------------------------------------------------------------------*
* Input		D0 = Bitmask
PokeDMA
	movem.l	D0/D1/A5,-(SP)
	move.w	D0,D1
	and.w	#$8000,D0	;D0.w neg=enable ; 0/pos=disable
	and.l	#15,D1		;D1 = Mask (LONG !!)
	move.l	EagleBase(PC),A5
	jsr	ENPP_DMAMask(A5)
	movem.l	(SP)+,D0/D1/A5
	rts

***************************************************************************
***************************** EP_GetPositionNr ****************************
***************************************************************************

GetPosition
	move.l	CurrentPos(PC),D0
	sub.l	FirstPos(PC),D0
	sub.w	StartPos(PC),D0
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

	moveq	#20,D0
	add.l	26(A2),D0
	sub.l	2(A2),D0
	add.l	D0,A2
	move.l	(A2),D5
	lea	26(A2),A0			; SampleInfo
	move.l	A0,A1
	lsr.l	#2,D5
	subq.l	#1,D5
Sample
	jsr	ENPP_AllocSampleStruct(A5)
	move.l	D0,(A3)
	beq.b	return
	move.l	D0,A3

	move.l	(A0)+,D2
	moveq	#0,D1
	tst.l	D2
	beq.b	NoSample
	move.l	A1,A2
	add.l	D2,A2
	add.w	(A2),D1
	addq.l	#8,D1
	lea	-6(A2),A2
NoSample
	move.l	A2,EPS_Adr(A3)			; sample address
	move.l	D1,EPS_Length(A3)		; sample length
	move.l	#64,EPS_Volume(A3)
	move.w	#USITY_RAW,EPS_Type(A3)
	move.w	#USIB_Playable!USIB_Saveable!USIB_8BIT,EPS_Flags(A3)
	dbf	D5,Sample

	moveq	#0,D7
return
	move.l	D7,D0
	rts

***************************************************************************
******************************** EP_Check5 ********************************
***************************************************************************

Check5
	movea.l	dtg_ChkData(A5),A0
	moveq	#-1,D0

	cmpi.w	#$2B7C,(A0)
	bne.s	Fault

	cmpi.w	#$2B7C,8(A0)
	bne.s	Fault

	cmpi.w	#$2B7C,$10(A0)
	bne.s	Fault

	cmpi.w	#$2B7C,$18(A0)
	bne.s	Fault

	cmpi.l	#$303C00FF,$20(A0)
	bne.s	Fault

	cmpi.l	#$32004EB9,$24(A0)
	bne.s	Fault

	cmpi.w	#$4E75,$2C(A0)
	bne.s	Fault

	moveq	#0,D0
Fault
	rts

***************************************************************************
***************************** EP_NewModuleInfo ****************************
***************************************************************************

NewModuleInfo

SubSongs	=	4
Calcsize	=	12
LoadSize	=	20
Samples		=	28
Songsize	=	36
SamplesSize	=	44
Length		=	52
Steps		=	60

InfoBuffer
	dc.l	MI_SubSongs,0		;4
	dc.l	MI_Calcsize,0		;12
	dc.l	MI_LoadSize,0		;20
	dc.l	MI_Samples,0		;28
	dc.l	MI_Songsize,0		;36
	dc.l	MI_SamplesSize,0	;44
	dc.l	MI_Length,0		;52
	dc.l	MI_Steps,0		;60
	dc.l	MI_Prefix,Prefix
	dc.l	0

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

	lea	ModulePtr(PC),A1
	move.l	A0,(A1)			; module ptr

	lea	InfoBuffer(PC),A2
	move.l	D0,LoadSize(A2)

	lea	Table(PC),a1
	move.l	A0,D0
	add.l	#$2E,D0
	move.l	D0,$124A-$1242(a1)

	move.l	A0,D0
	add.l	10(A0),D0
	sub.l	2(A0),D0
	add.l	#$2E,D0
	move.l	D0,$1242-$1242(a1)

	move.l	a0,d0
	add.l	$12(a0),d0
	sub.l	2(a0),d0
	add.l	#$2e,d0
	move.l	d0,$1246-$1242(a1)

	move.l	d0,-(a7)

	move.l	a0,d0
	add.l	$1A(a0),d0
	sub.l	2(a0),d0
	add.l	#$2e,d0
	move.l	d0,$124E-$1242(a1)

	move.l	(a7),a1
	add.l	LoadSize(A2),A0
	moveq	#10,D1
.loop
	cmp.w	#$F0FF,(A1)
	beq.b	.ok
	move.w	(A1)+,d0
	cmp.w	D0,D1
	bcc.b	.low
	move.w	D0,D1
.low
	cmp.l	A0,A1
	bne.b	.loop
.ok
	move.l	(A7)+,A1
	add.w	D1,A1
.loop1
	cmp.b	#-1,(A1)+
	beq.b	.ok1
	cmp.l	A0,A1
	bne.b	.loop1
	bra.b	.ok2
.ok1
	sub.l	ModulePtr(PC),A1
	move.l	A1,Calcsize(A2)
	move.l	A1,D2
.ok2
	lea	Table(PC),A1
	lea	$1264-$1242(A1),A1
	lea	lbC000744(PC),A0

	moveq	#3,D0
loop
	move.l	A0,$26(A1)
	move.l	A0,$34(A1)
	move.l	A0,$38(A1)
	move.l	A0,$3C(A1)
	move.l	A0,$4C(A1)

	lea	$6C(A1),A1
	dbf	D0,loop

	move.l	ModulePtr(PC),A0
	move.l	10(A0),A1
	sub.l	2(A0),A1
	lea	$2E(A1),A1
	add.l	A0,A1
	moveq	#0,D1
loops
	move.w	(A1),D0
	and.w	#$FFF0,D0
	bne.b	nosub
	lea	12(A1),A1
	addq.l	#1,D1
	bra.b	loops
nosub
	cmp.l	#6802,D2			; fix for Rainbow Islands (15)
	bne.b	NoFix
	cmp.l	#$019F019F,3650(A0)
	bne.b	NoFix
	move.l	#$01A001A0,3650(A0)
	move.l	#$01A001A0,3654(A0)
NoFix
	cmp.l	#17213,D2
	bne.b	SubOK
	moveq	#5,D1
SubOK
	move.w	D1,SubSongs+2(A2)
	moveq	#20,D0
	add.l	26(A0),D0
	sub.l	2(A0),D0
	move.l	A0,A1
	add.l	D0,A0
	move.l	(A0),D1
	lsr.l	#2,D1
	subq.l	#1,D1
	move.l	4(A0),D0
	move.l	D0,SamplesSize(A2)
	sub.l	D0,D2
	move.l	D2,Songsize(A2)
	lea	26(A0),A0
	moveq	#0,D0
NextSamp
	tst.l	(A0)+
	beq.b	NoSamp
	addq.l	#1,D0
NoSamp
	dbf	D1,NextSamp

	move.w	D0,Samples+2(A2)
	moveq	#46,D1
	add.l	18(A1),D1
	sub.l	2(A1),D1
	add.l	D1,A1
	move.w	(A1),D0
	lsr.l	#1,D0
	move.l	D0,Steps(A2)

	movea.l	dtg_AudioAlloc(A5),A0
	jmp	(A0)

***************************************************************************
***************************** DTP_InitSound *******************************
***************************************************************************

InitSound
	move.w	#$1BC0,dtg_Timer(A5)

	move.l	A5,-(A7)
	lea	Table(pc),a5

	move.w	#$FF,D0
	move.w	D0,D1
	bsr.w	Initialize

	moveq	#0,D0
	move.l	(A7)+,A0
	move.w	dtg_SndNum(A0),D0
	move.w	D0,D2
	subq.w	#1,D2
	move.l	ModulePtr(PC),A0
	move.l	10(A0),A1
	sub.l	2(A0),A1
	lea	46(A1),A1
	add.l	A0,A1
	move.l	A1,FirstPos
NextLength
	move.l	A1,A0
	moveq	#0,D3
	move.w	4(A0),StartPos
	move.l	FirstPos(PC),A0
	add.w	StartPos(PC),A0
NextPos
	cmp.b	#$FF,(A0)+
	beq.b	Found
	addq.l	#1,D3
	bra.b	NextPos
Found
	lea	12(A1),A1
	dbf	D2,NextLength
	lea	InfoBuffer(PC),A2
	move.l	D3,Length(A2)

	bsr.w	Initialize2

	bsr.w	lbC000626			;+ for safety !!!

	rts

***************************************************************************
***************************** DTP_EndSound ********************************
***************************************************************************

EndSound
	lea	Table(PC),A5
	lea	$dff000,A2

	bsr.w	lbC0005C2

	rts

***************************************************************************
***************************** DTP_Interrupt *******************************
***************************************************************************

Interrupt
	movem.l	D1-D7/A0-A6,-(A7)

	lea	Table(PC),A5
	bsr.w	lbC0006BE
	bsr.w	lbC000626

	move.l	EagleBase(PC),A5
	jsr	ENPP_Amplifier(A5)

	movem.l	(A7)+,D1-D7/A0-A6
	moveq	#0,D0
	rts

***************************************************************************
**************************** Steve Turner player **************************
***************************************************************************

; player from game Off Road Racer

lbW000000:
	dc.w	$EEE4,$E17B,$D4D4,$C8E1,$BD9C,$B2F6,$A8EC,$9F71
	dc.w	$967D,$8E0B,$8612,$7E8C,$7772,$70BE,$6A6A,$6471
	dc.w	$5ECE,$597B,$5476,$4FB9,$4B3F,$4706,$4309,$3F46
	dc.w	$3BB9,$385F,$3535,$3239,$2F67,$2CBE,$2A3B,$27DD
	dc.w	$25A0,$2383,$2185,$1FA3,$1DDD,$1C30,$1A9B,$191D
	dc.w	$17B4,$165F,$151E,$13EF,$12D0,$11C2,$10C3,$FD2
	dc.w	$EEF,$E18,$D4E,$C8F,$BDA,$B30,$A8F,$9F8,$968,$8E1
	dc.w	$862,$7E9,$778,$70C,$6A7,$648,$5ED,$598,$548,$4FC
	dc.w	$4B4,$471,$431,$3F5,$3BC,$386,$354,$324,$2F7,$2CC
	dc.w	$2A4,$27E,$25A,$239,$219,$1FB
;	dc.w	$5353,$7C,0,$400
;	dc.w	$E0E0,$D8C0,$8080,$9FFF,$A0,$B7FF,$4C0,$8087
;	dc.w	$BFA0,$87FF,$1F37,$3418,$C0,$BFDF,$1704,$1710
;	dc.w	$FBE0,$8080,$87EF,$80,$8083,$D727,$293F,$5000
;	dc.w	$8087,$EFFF,$FC17,$4000,$8080,$81BD,$B2C7,$EDF1
;	dc.w	$C8A8,$A7E7,$ECE8,$C4BF,$DB1F,$5F67,$7172,$6C30
;	dc.w	$FF4F,$696F,$726C,$6400,$A0BF,$3F5C,$4E42,$3F65
;	dc.w	$6830,$B8FF,$5720,$888F,$2F5C,$10A0,$AF2F,$5F6E
;	dc.w	$685F,$6E6F,$6F60,$200F,$FB,$8D0,$8880,$8080
;	dc.w	$9F2F,$5A20,$C0DF,$4810,$C0AF,$EF08,$C0D7,$FFE8
;	dc.w	$A08F,$1F5B,$6000,$9BCF,$E6E0,$A89D,$AFEF,$3F30
;	dc.w	$D09F,$C7D3,$FB17,$2E47,$676A,$6400,$809F,$375F
;	dc.w	$58E0,$80BF,$4F48,$D0,$CAA0,$8081,$BF0B,$E8A2
;	dc.w	$B7BD,$EF2C,$F0B4,$A9D7,$F702,$EF0E,$E4,$B080
;	dc.w	$8080,$81AF,$FF3F,$656A,$5835,$5330,$B080,$8FCE
;	dc.w	$CBFF,$4408,$A88B,$BF4F,$656C,$5000,$C2CE,$C298
;	dc.w	$8080,$8095,$8080,$8780,$8080,$EF0C,$E0A0,$9F17
;	dc.w	$576F,$706A,$50E8,$FF57,$6764,$20D0,$B880,$8080
;	dc.w	$809F,$B080,$972F,$5400,$8097,$FF10,$B0BF,$D0DF
;	dc.w	$1F5F,$6858,$2812,$1F38,$2F5B,$6220,$8080,$8FFF
;	dc.w	$90,$8080,$DF4F,$6560,$424F,$40C8,$808F,$EF2F
;	dc.w	$4000,$8080,$8081,$DF4F,$6340,$D4B5,$B080,$8080
;	dc.w	$8097,$8080,$9FA0,$8080,$CF3F,$3000,$FF0C,$E8C5
;	dc.w	$FF57,$5800,$EF4F,$6660,$200D,$2F24,$D0B7,$FF57
;	dc.w	$6E72,$7270,$6F6A,$5857,$5B6B,$6A50,$5B69,$6820
;	dc.w	$C7FF,$3610,$91F,$341F,$8F0,$CAFF,$576A,$6964
;	dc.w	$4810,$FF4F,$6A6E,$6E6D,$6440,$4820,$92F,$5F40
;	dc.w	$C09D,$DF2F,$10EF,$3F58,$4840,$4F67,$6850,$E0BF
;	dc.w	$FF4F,$6760,$10C0,$8080,$8BEF,$3F63,$6010,$F8E0
;	dc.w	$C0B7,$1F54,$80,$871F,$40D0,$8080,$808F,$FF3A
;	dc.w	$3F53,$4A57,$5810,$F16,$4E0,$8881,$DFF9,$E0AA
;	dc.w	$DF20,$E8A0,$8FEF,$B0,$80AF,$F00,$C71F,$5F40
;	dc.w	$B09F,$1F5B,$6F70,$6A40,$E81F,$5F54,$2F4F,$5C30
;	dc.w	$D090,$8080,$AFD0,$A8BF,$3F67,$6768,$6F72,$7050
;	dc.w	$E087,$DF57,$6A6A,$5400,$B0BF,$3F5F,$6420,$8080
;	dc.w	$80DF,$E080,$8080,$9B8C,$9FCB,$C080,$8080,$87BF
;	dc.w	$2F5F,$6F6C,$676E,$6440,$576B,$5800,$D4DF,$E0C0
;	dc.w	$9080,$80BF,$1720,$D0FF,$5767,$6820,$C080,$80BF
;	dc.w	$F8C0,$8083,$CF19,$C0,$8880,$8088,$8080,$8097
;	dc.w	$E7E8,$B4D7,$18C0,$809F,$FF55,$444F,$6020,$D0BB
;	dc.w	$F730,$4F6,$FC0A,$F0D4,$B098,$97A6,$8080,$AFE6
;	dc.w	$C8DF,$3F67,$6F6D,$6E6D,$7173,$6D6A,$6F71,$7073
;	dc.w	$6000,$A08B,$BF1F,$465B,$6020,$B0EF,$4F40,$F0C9
;	dc.w	$D0A0,$808F,$FF30,$E0CF,$1F5B,$6A69,$5800,$A7CF
;	dc.w	$FF18,$730,$E5,$C084,$9FA7,$B7A8,$80BF,$110A,$2FF
;	dc.w	$1F00,$8080,$8080,$808F,$D7D8,$9080,$81DF,$3010
;	dc.w	$8E0,$A087,$CF3F,$3019,$1F47,$402F,$2C10,$A2F
;	dc.w	$5418,$E8DB,$1F5D,$636F,$6F6B,$48F0,$1F5F,$6B6B
;	dc.w	$6B40,$E0A0,$8080,$B71F,$80,$AF3F,$5000,$A7FF
;	dc.w	$4400,$A09F,$EF4F,$656F,$706E,$6832,$5362,$30C0
;	dc.w	$908E,$87AF,$FF08,$E4F7,$2200,$FF57,$696A,$5000
;	dc.w	$C0AF,$FF4F,$5C48,$D0,$DFFF,$D0,$8080,$979F,$D727
;	dc.w	$1080,$8080,$8FCB,$C6DF,$3B20,$1F10,$C894,$BF1F
;	dc.w	$30A0,$8080,$BFE4,$9080,$8080,$BF2F,$4010,$174F
;	dc.w	$5400,$A0CF,$2F52,$30D0,$97C7,$C0D7,$1F50,$30E0
;	dc.w	$A3EF,$20E0,$8080,$BF0C,$C080,$BF22,$E080,$BF4F
;	dc.w	$4800,$BBCF,$CAEF,$4F6B,$7070,$6F6F,$6C6C,$6234
;	dc.w	$3730,$D0AF,$FF08,$D0AF,$FF57,$6C6D,$706B,$6E71
;	dc.w	$6428,$1927,$4334,$A0,$A7A8,$96BF,$1F57,$4800
;	dc.w	$A5DF,$8E8,$E7F0,$E2C4,$8487,$8080,$8080,$B7FF
;	dc.w	$2004,$E088,$80BF,$10A0,$8080,$DF30,$E0B0,$A3CA
;	dc.w	$A883,$BF3F,$6569,$6E68,$4018,$4F9,$F0C,$1B21
;	dc.w	$3740,$80,$808F,$EBFF,$F0D8,$9080,$9F2F,$5E40
;	dc.w	$4E4,$DCC4,$DF33,$8D0,$97DF,$1F12,$F0A0,$9FAC
;	dc.w	$B7FF,$1800,$A880,$BF1B,$3744,$8C4

;	movem.l	D2/A2/A4,-(SP)
;	lea	$DFF000,A2
;	move.w	#$780,$9A(A2)
;	move.w	#$FF,$9E(A2)
;	bsr.w	lbC0005C2
;	lea	$BFE001,A0
;	clr.b	$E00(A0)
;	move.b	#$C0,$400(A0)
;	move.b	#$1B,$500(A0)
;	move.l	#lbC0006BE,$15D0-$1242(A5)
;	move.b	#$81,$D00(A0)
;	ori.b	#1,$1578-$1242(A5)
;	move.w	#$8008,$9A(A2)
;	move.b	#1,$E00(A0)
;	bset	#1,(A0)
;	lea	lbC000626(PC),A0
;	moveq	#-10,D0
;	movem.l	A4/A6,-(SP)
;	movea.l	$1648-$1242(A5),A6
;	movea.l	(A6),A4
;	move.w	$4A(A4),D7
;	jsr	0(A4,D7.W)
;	movem.l	(SP)+,A4/A6
;	movem.l	(SP)+,D2/A2/A4
;	rts

;	cmp.w	#4,D1
;	bcc.s	lbC00055C
;	mulu.w	#$6C,D1
;	lea	$1264-$1242(A5),A0
;	adda.l	D1,A0
;	move.b	D0,D1
;	beq.s	lbC00055C
;	ext.w	D1
;	subq.w	#1,D1
;	mulu.w	#$30,D1
;	movea.l	$124A-$1242(A5),A1
;	move.b	$1E(A1,D1.W),D0
;	cmp.b	$1B(A0),D0
;	bcs.s	lbC00055C
;	swap	D0
;	move.w	D1,D0
;	move.l	D0,$1A(A0)
;lbC00055C:
;	rts

;	movem.l	D2/D3,-(SP)
;	movea.l	$124A-$1242(A5),A0
;	lea	$1264-$1242(A5),A1
;	trap	#5
;	move.w	D0,D2
;	bsr.s	lbC000588
;	swap	D0
;	move.w	D0,D2
;	bsr.s	lbC000588
;	move.w	D1,D2
;	bsr.s	lbC000588
;	swap	D1
;	move.w	D1,D2
;	bsr.s	lbC000588
;	trap	#6
;	movem.l	(SP)+,D2/D3
;	rts

;lbC000588:
;	move.b	D2,D3
;	beq.s	lbC0005A6
;	ext.w	D3
;	subq.w	#1,D3
;	mulu.w	#$30,D3
;	move.b	$1E(A0,D3.W),D2
;	cmp.b	$1B(A1),D2
;	bcs.s	lbC0005A6
;	swap	D2
;	move.w	D3,D2
;	move.l	D2,$1A(A1)
;lbC0005A6:
;	lea	$6C(A1),A1
;	rts

Initialize2
	move.w	D0,$125C-$1242(A5)
	rts

;	move.b	D0,$1261-$1242(A5)
;	rts
Initialize
	move.w	D1,$125A-$1242(A5)
	move.w	D0,$1258-$1242(A5)
	rts

lbC0005C2:
	clr.b	$125E-$1242(A5)
	clr.b	$125F-$1242(A5)
	clr.w	$125C-$1242(A5)
	lea	$1264-$1242(A5),A4
	moveq	#3,D1
lbC0005D4:
	bsr.s	lbC0005F0
	lea	$6C(A4),A4
	dbra	D1,lbC0005D4
;	clr.w	$A8(A2)
;	clr.w	$B8(A2)
;	clr.w	$C8(A2)
;	clr.w	$D8(A2)

		moveq	#0,D0
		move.l	EagleBase(PC),A5
		moveq	#0,D1
		jsr	ENPP_PokeVol(A5)
		moveq	#1,D1
		jsr	ENPP_PokeVol(A5)
		moveq	#2,D1
		jsr	ENPP_PokeVol(A5)
		moveq	#3,D1
		jsr	ENPP_PokeVol(A5)

	rts

lbC0005F0:
	move.l	#$FFFF,D0
	move.l	D0,$1A(A4)
	move.l	D0,$1E(A4)
	move.l	D0,$22(A4)
	lea	lbC000744(PC),A0
	move.l	A0,$4C(A4)
	move.l	A0,$26(A4)
	move.l	A0,$38(A4)
	move.l	A0,$3C(A4)
	move.l	A0,$34(A4)
	clr.b	$5C(A4)
;	move.w	$62(A4),$96(A2)

		move.l	D0,-(SP)
		move.w	$62(A4),D0
		bsr.w	PokeDMA
		move.l	(SP)+,D0

	rts

lbC000626:
	movem.l	D2-D4/A2-A4,-(SP)
	lea	$DFF000,A2
	move.w	$1258-$1242(A5),D0
	sub.w	$1256-$1242(A5),D0
	beq.s	lbC000664
	movea.w	$125A-$1242(A5),A0
	bpl.s	lbC00065A
	neg.w	D0
	cmp.w	A0,D0
	ble.s	lbC00064E
	move.w	A0,D0
	sub.w	D0,$1256-$1242(A5)
	bra.s	lbC000664

lbC00064E:
	sub.w	D0,$1256-$1242(A5)
	bne.s	lbC000664
	bsr.w	lbC0005C2
	bra.s	lbC000664

lbC00065A:
	cmp.w	A0,D0
	ble.s	lbC000660
	move.w	A0,D0
lbC000660:
	add.w	D0,$1256-$1242(A5)
lbC000664:
	move.w	$125C-$1242(A5),D0
	beq.s	lbC000674
	bsr.w	lbC000746
	clr.w	$125C-$1242(A5)
	bra.s	lbC0006B6

lbC000674:
	lea	$1264-$1242(A5),A4
	moveq	#3,D2
lbC00067A:
	move.w	$1C(A4),D0
	bmi.s	lbC0006AE
	movea.l	$124A-$1242(A5),A0
	move.b	$1E(A0,D0.W),D1
	tst.b	$1A(A4)
	bne.s	lbC00069A
	cmp.b	$23(A4),D1
	bcs.s	lbC0006A6
	bsr.w	lbC0008D6
	bra.s	lbC0006A6

lbC00069A:
	cmp.b	$1F(A4),D1
	bcs.s	lbC0006A6
	move.l	$1A(A4),$1E(A4)
lbC0006A6:
	move.l	#$FFFF,$1A(A4)
lbC0006AE:
	lea	$6C(A4),A4
	dbra	D2,lbC00067A
lbC0006B6:
	movem.l	(SP)+,D2-D4/A2-A4
	moveq	#0,D0
	rts

lbC0006BE:
	movem.l	D0-D4/A0-A4,-(SP)
;	trap	#5
	lea	$DFF000,A2
	subq.b	#1,$1263-$1242(A5)
	lea	$1264-$1242(A5),A4
	moveq	#3,D2
lbC0006D4:
	subq.b	#1,$1E(A4)
	bne.s	lbC0006F6
	move.w	$20(A4),D0
	bmi.s	lbC0006F6
	move.b	$1F(A4),D1
	cmp.b	$23(A4),D1
	bcs.s	lbC0006EE
	bsr.w	lbC0008D6
lbC0006EE:
	move.l	#$FFFF,$1E(A4)
lbC0006F6:
	movea.l	$30(A4),A3
	move.w	$40(A4),D4
	move.w	$42(A4),D3
	movea.l	$4C(A4),A0
	jsr	(A0)
	movea.l	$26(A4),A0
	jsr	(A0)
	movea.l	$38(A4),A0
	jsr	(A0)
	movea.l	$3C(A4),A0
	jsr	(A0)
	movea.l	$34(A4),A0
	jsr	(A0)
	lea	$6C(A4),A4
	dbra	D2,lbC0006D4
	tst.b	$1263-$1242(A5)
	bne.s	lbC00073C
	move.b	$1261-$1242(A5),$1263-$1242(A5)
	bne.s	lbC00073C
	move.b	$1262-$1242(A5),$1263-$1242(A5)
lbC00073C:
;	trap	#6
	movem.l	(SP)+,D0-D4/A0-A4
	rts

lbC000744:
	rts

lbC000746:
	moveq	#$7F,D1
	and.b	D0,D1
	subq.w	#1,D1
	mulu.w	#12,D1
	add.l	$1242-$1242(A5),D1
	movea.l	D1,A1
	move.b	(A1)+,D1
	cmp.b	$125F-$1242(A5),D1
	bcs.s	lbC000790
	move.b	D0,$125E-$1242(A5)
	move.b	D1,$125F-$1242(A5)
	move.b	(A1)+,D0
	move.b	D0,$1262-$1242(A5)
	move.b	D0,$1263-$1242(A5)
	move.b	(A1)+,$1260-$1242(A5)
	addq.l	#1,A1
	lea	$1264-$1242(A5),A4
	moveq	#3,D2
lbC00077C:
	move.w	(A1)+,D0
	beq.s	lbC000788
	movea.l	$1242-$1242(A5),A0
	adda.w	D0,A0
	bsr.s	lbC000792
lbC000788:
	lea	$6C(A4),A4
	dbra	D2,lbC00077C
lbC000790:
	rts

lbC000792:
	move.l	A0,$50(A4)
	bsr.w	lbC0005F0
	move.l	#lbC0007A4,$4C(A4)
	rts

lbC0007A4:
	movea.l	$50(A4),A0
	clr.w	D0
	move.b	(A0)+,D0
	move.l	A0,$50(A4)
	cmp.b	#$FE,D0
	bcs.s	lbC0007F6
	cmp.b	#$FF,D0
	beq.s	lbC0007C6
	move.l	#lbC000744,$4C(A4)
	rts

lbC0007C6:
	lea	lbC000744(PC),A0
	move.l	A0,$12B0-$1242(A5)
	move.l	A0,$131C-$1242(A5)
	move.l	A0,$1388-$1242(A5)
	move.l	A0,$13F4-$1242(A5)
	clr.b	$125F-$1242(A5)
	clr.w	D0
	move.b	$125E-$1242(A5),D0
;	bmi.s	lbC0007EC				; restart music fix
;	move.b	$1260-$1242(A5),D0
;	beq.s	lbC0007F0
lbC0007EC:
	move.w	D0,$125C-$1242(A5)
lbC0007F0:
	clr.b	$125E-$1242(A5)

		movem.l	A1/A5,-(A7)
		move.l	EagleBase(PC),A5
		move.l	dtg_SongEnd(A5),A1
		jsr	(A1)
		movem.l	(A7)+,A1/A5

	rts

lbC0007F6:
	movea.l	$1246-$1242(A5),A0
	add.w	D0,D0
	adda.w	0(A0,D0.W),A0
	bra.s	lbC000806

lbC000802:
	movea.l	$54(A4),A0
lbC000806:
	clr.w	D0
	move.b	(A0)+,D0
	bpl.s	lbC000882
	cmp.b	#$B0,D0
	bcs.s	lbC00082E
	cmp.b	#$D0,D0
	bcs.s	lbC000862
	cmp.b	#$F0,D0
	bcs.s	lbC000842
	cmp.b	#$F9,D0
	bcs.s	lbC000838
	cmp.b	#$FE,D0
	beq.s	lbC00085C
	bra.w	lbC0007A4

lbC00082E:
	subi.b	#$7F,D0
	move.b	D0,$58(A4)
	bra.s	lbC000806

lbC000838:
	subi.b	#$F0,D0
	move.b	D0,$5C(A4)
	bra.s	lbC000806

lbC000842:
	subi.b	#$D0,D0
	ext.w	D0
	mulu.w	#$30,D0
	move.w	D0,$5E(A4)
	movea.l	$124A-$1242(A5),A1
	move.b	$1E(A1,D0.W),$5D(A4)
	bra.s	lbC000806

lbC00085C:
	move.l	A0,$54(A4)
	bra.s	lbC0008AC

lbC000862:
	move.l	A0,$54(A4)
	subi.b	#$B0,D0
	mulu.w	#$30,D0
	movea.l	$124A-$1242(A5),A1
	move.b	$1E(A1,D0.W),D1
	cmp.b	$23(A4),D1
	bcs.s	lbC0008AC
	bsr.w	lbC0008D6
	bra.s	lbC0008AC

lbC000882:
	move.l	A0,$54(A4)
	move.b	$5D(A4),D1
	cmp.b	$23(A4),D1
	bcs.s	lbC0008AC
	move.w	D0,-(SP)
	move.w	$5E(A4),D0
	bsr.w	lbC0008D6
	move.w	(SP)+,D0
	lea	lbW000000(PC),A0
	add.w	D0,D0
	move.w	0(A0,D0.W),D0
	bsr.w	lbC000C0E
	nop
lbC0008AC:
	move.b	$58(A4),$59(A4)
	move.l	#lbC0008BC,$4C(A4)
	rts

lbC0008BC:
	tst.b	$1263-$1242(A5)
	bne.s	lbC0008CC
	subq.b	#1,$59(A4)
	beq.w	lbC000802
	rts

lbC0008CC:
	tst.b	$59(A4)
	beq.w	lbC000802
	rts

lbC0008D6:
	move.w	D0,$24(A4)
	move.b	D1,$23(A4)
	moveq	#0,D1
	move.w	D0,D1
	divu.w	#$30,D1
	addq.w	#1,D1
	move.b	D1,$22(A4)
	movea.l	$124A-$1242(A5),A3
	adda.w	D0,A3
	move.l	A3,$30(A4)
	move.l	#lbC000942,$26(A4)
	lea	lbC000744(PC),A0
	move.l	A0,$38(A4)
	move.l	A0,$3C(A4)
	move.l	A0,$34(A4)
	move.b	$1F(A3),D0
	bpl.s	lbC00091A
	bsr.w	lbC000C5E
	bra.w	lbC00093C

lbC00091A:
	movea.l	$124E-$1242(A5),A0
	ext.w	D0
	add.w	D0,D0
	add.w	D0,D0
	adda.l	0(A0,D0.W),A0
	move.w	$6A(A4),D0
	move.w	(A0)+,D1
	lsr.w	#1,D1
;	move.w	D1,0(A2,D0.W)

		bsr.w	PokeLen

	move.w	$68(A4),D0
;	move.l	A0,0(A2,D0.W)
	
		bsr.w	PokeAdr

lbC00093C:
	bsr.w	lbC000AD0
	rts

lbC000942:
;	move.w	$62(A4),$96(A2)

		move.l	D0,-(SP)
		move.w	$62(A4),D0
		bsr.w	PokeDMA
		move.l	(SP)+,D0

	move.l	#lbC000952,$26(A4)
	rts

lbC000952:
	move.w	$64(A4),D0
;	clr.w	0(A2,D0.W)

		bsr.w	ClearVol

	move.w	$62(A4),D0
	ori.w	#$8000,D0
;	move.w	D0,$96(A2)

		bsr.w	PokeDMA

	move.b	$20(A3),D0
	move.b	D0,$18(A4)
	move.b	D0,$60(A4)
	bne.s	lbC00098C
	move.w	$1256-$1242(A5),D0
	move.w	D0,$2E(A4)
;	lsr.w	#3,D0

		lsr.w	#2,D0					; volume fix

	move.w	$64(A4),D1
;	move.w	D0,0(A2,D1.W)

		bsr.w	PokeVol

	addq.b	#1,$18(A4)
	bra.s	lbC000990

lbC00098C:
	clr.w	$2E(A4)
lbC000990:
	clr.w	$2A(A4)
	move.b	$21(A3),$2B(A4)
	move.b	$22(A3),$2C(A4)
	move.l	#lbC0009AA,$26(A4)
	rts

lbC0009AA:
	tst.b	$60(A4)
	bne.s	lbC0009C6
	move.w	$6A(A4),D0
;	move.w	#1,0(A2,D0.W)

		move.l	D1,-(SP)
		moveq	#1,D1
		bsr.w	PokeLen
		move.l	(SP)+,D1

	move.w	$68(A4),D0
;	move.l	#lbL0004B0,0(A2,D0.W)

		move.l	A0,-(SP)
		lea	lbL0004B0,A0
		bsr.w	PokeAdr
		move.l	(SP)+,A0

lbC0009C6:
	move.l	#lbC0009CE,$26(A4)
lbC0009CE:
	bsr.w	lbC000AA6
	subq.w	#1,$2A(A4)
	beq.s	lbC0009DA
	rts

lbC0009DA:
	move.b	$23(A3),$2B(A4)
	move.b	$24(A3),$2C(A4)
	move.l	#lbC0009F0,$26(A4)
	rts

lbC0009F0:
	bsr.w	lbC000AA6
	subq.w	#1,$2A(A4)
	beq.s	lbC0009FC
	rts

lbC0009FC:
	move.w	$26(A3),$2A(A4)
	move.b	$28(A3),$2C(A4)
	move.l	#lbC000A1C,$26(A4)
lbC000A10:
	move.b	$29(A3),$2D(A4)
	neg.b	$2C(A4)
	rts

lbC000A1C:
	bsr.w	lbC000AA6
	subq.w	#1,$2A(A4)
	beq.s	lbC000A2E
	subq.b	#1,$2D(A4)
	beq.s	lbC000A10
	rts

lbC000A2E:
	move.b	$2A(A3),$2C(A4)
	move.l	#lbC000A3E,$26(A4)
	rts

lbC000A3E:
	bsr.w	lbC000AA6
	tst.w	$2E(A4)
	beq.s	lbC000A4A
	rts

lbC000A4A:
	subq.b	#1,$18(A4)
	bne.w	lbC00098C
	move.b	$2F(A3),D0
	beq.s	lbC000A6E
	ext.w	D0
	subq.w	#1,D0
	mulu.w	#$30,D0
	movea.l	$124A-$1242(A5),A1
	move.b	$1E(A1,D0.W),D1
	bsr.w	lbC0008D6
	bra.s	lbC000AA4

lbC000A6E:
	move.w	$64(A4),D0
;	clr.w	0(A2,D0.W)

		bsr.w	ClearVol

;	move.w	$62(A4),$96(A2)

		move.l	D0,-(SP)
		move.w	$62(A4),D0
		bsr.w	PokeDMA
		move.l	(SP)+,D0

	move.l	#lbC000744,$26(A4)
	move.l	#lbC000744,$38(A4)
	move.l	#lbC000744,$3C(A4)
	move.l	#lbC000744,$34(A4)
	move.l	#$FFFF,$22(A4)
lbC000AA4:
	rts

lbC000AA6:
	move.b	$2C(A4),D0
	ext.w	D0
	add.w	$2E(A4),D0
	bpl.s	lbC000AB6
	clr.w	D0
	bra.s	lbC000AC0

lbC000AB6:
	cmp.w	$1256-$1242(A5),D0
	ble.s	lbC000AC0
	move.w	$1256-$1242(A5),D0
lbC000AC0:
	move.w	D0,$2E(A4)
;	lsr.w	#3,D0

		lsr.w	#2,D0				; volume fix

	move.w	$64(A4),D1
;	move.w	D0,0(A2,D1.W)

		bsr.w	PokeVol

	rts

lbC000AD0:
	move.b	$2C(A3),$48(A4)
	clr.b	$4A(A4)
	move.b	#1,$44(A4)
	clr.w	D4
	clr.w	D3
	clr.w	$40(A4)
	clr.w	$42(A4)
	lea	(A4),A0
	lea	(A3),A1
	clr.w	D0
	move.b	$2B(A3),D0
	bra.s	lbC000B14

lbC000AF8:
	move.w	(A1),D1
	move.w	D1,(A0)
	move.w	D1,2(A0)
	move.w	2(A1),4(A0)
	move.b	5(A1),6(A0)
	lea	8(A0),A0
	lea	10(A1),A1
lbC000B14:
	dbra	D0,lbC000AF8
	move.l	#lbC000B22,$38(A4)
	rts

lbC000B22:
	move.b	4(A3,D3.W),$46(A4)
lbC000B28:
	move.b	6(A4,D4.W),$45(A4)
lbC000B2E:
	move.b	6(A3,D3.W),$47(A4)
	move.l	#lbC000B3C,$38(A4)
lbC000B3C:
	bsr.w	lbC000BC4
	subq.b	#1,$47(A4)
	beq.s	lbC000B48
	rts

lbC000B48:
	move.l	#lbC000B52,$38(A4)
	rts

lbC000B52:
	move.w	4(A4,D4.W),D0
	add.w	D0,0(A4,D4.W)
	move.b	7(A3,D3.W),D0
	ext.w	D0
	add.w	D0,4(A4,D4.W)
	subq.b	#1,$45(A4)
	bne.s	lbC000B2E
	move.b	8(A3,D3.W),D1
	lsr.b	#1,D1
	bcc.s	lbC000B78
	move.w	2(A4,D4.W),0(A4,D4.W)
lbC000B78:
	lsr.b	#1,D1
	bcc.s	lbC000B80
	neg.w	4(A4,D4.W)
lbC000B80:
	lsr.b	#1,D1
	bcc.s	lbC000B90
	cmpi.b	#8,6(A4,D4.W)
	bls.s	lbC000B90
	subq.b	#1,6(A4,D4.W)
lbC000B90:
	subq.b	#1,$46(A4)
	bne.s	lbC000B28
	move.b	$44(A4),D0
	cmp.b	$2B(A3),D0
	bne.s	lbC000BAC
	move.b	#1,$44(A4)
	clr.w	D4
	clr.w	D3
	bra.s	lbC000BB8

lbC000BAC:
	addq.b	#1,$44(A4)
	addi.w	#8,D4
	addi.w	#10,D3
lbC000BB8:
	move.w	D4,$40(A4)
	move.w	D3,$42(A4)
	bra.w	lbC000B22

lbC000BC4:
	move.b	$2D(A3),D1
	beq.s	lbC000BFA
	tst.b	$48(A4)
	beq.s	lbC000BD6
	subq.b	#1,$48(A4)
	bra.s	lbC000BFA

lbC000BD6:
	move.b	$4A(A4),D0
	ext.w	D0
	add.w	D0,0(A4,D4.W)
	subq.b	#1,$49(A4)
	bne.s	lbC000BFA
	move.b	D1,$49(A4)
	neg.b	D0
	bmi.s	lbC000BF6
	cmp.b	$2E(A3),D0
	bge.s	lbC000BF6
	addq.b	#1,D0
lbC000BF6:
	move.b	D0,$4A(A4)
lbC000BFA:
	move.w	0(A4,D4.W),D1
	move.b	$25(A3),D0
	lsr.w	D0,D1
	move.w	$66(A4),D0
;	move.w	D1,0(A2,D0.W)

		bsr.w	PokePer

	rts

lbC000C0E:
	tst.b	$5C(A4)
	beq.s	lbC000C2A
	move.w	$5A(A4),(A4)
	move.w	D0,$5A(A4)
	move.l	#lbC000C3E,$3C(A4)
	move.w	D0,2(A4)
	rts

lbC000C2A:
	move.w	D0,$5A(A4)
	move.w	D0,(A4)
	move.w	D0,2(A4)
	move.l	#lbC000744,$3C(A4)
	rts

lbC000C3E:
	move.w	$5A(A4),D0
	sub.w	(A4),D0
	move.b	$5C(A4),D1
	asr.w	D1,D0
	beq.s	lbC000C50
	add.w	D0,(A4)
	rts

lbC000C50:
	move.w	$5A(A4),(A4)
	move.l	#lbC000744,$3C(A4)
	rts

lbC000C5E:
	rts				; RTS inserted

;	move.w	$6A(A4),D0
;	move.w	#$100,0(A2,D0.W)
;	move.l	#lbC000C70,$34(A4)
;lbC000C70:
;	bsr.w	lbC000C80
;	movea.l	$1252-$1242(A5),A0
;	andi.w	#$1FE,D0
;	adda.w	D0,A0
;	move.w	$68(A4),D0
;	move.l	A0,0(A2,D0.W)
;	rts

;lbC000C80:
;	addq.b	#2,$1573-$1242(A5)
;	move.w	$1572-$1242(A5),D0
;	movea.l	$156E-$1242(A5),A0
;	move.w	0(A0,D0.W),D0
;	rts

Table
	ds.b	$22
	ds.b	$26
	dc.l	lbC000744
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	lbC000744
	dc.l	lbC000744
	dc.l	lbC000744
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	lbC000744
CurrentPos
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
	dc.w	1
	dc.w	$A8
	dc.w	$A6
	dc.w	$A0
	dc.w	$A4

	ds.b	$26
	dc.l	lbC000744
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	lbC000744
	dc.l	lbC000744
	dc.l	lbC000744
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	lbC000744
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
	dc.w	2
	dc.w	$B8
	dc.w	$B6
	dc.w	$B0
	dc.w	$B4

	ds.b	$26
	dc.l	lbC000744
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	lbC000744
	dc.l	lbC000744
	dc.l	lbC000744
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	lbC000744
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
	dc.w	4
	dc.w	$C8
	dc.w	$C6
	dc.w	$C0
	dc.w	$C4

	ds.b	$26
	dc.l	lbC000744
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	lbC000744
	dc.l	lbC000744
	dc.l	lbC000744
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	lbC000744
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
	dc.w	8
	dc.w	$D8
	dc.w	$D6
	dc.w	$D0
	dc.w	$D4

	Section Empty,BSS_C

lbL0004B0:
	ds.b	4

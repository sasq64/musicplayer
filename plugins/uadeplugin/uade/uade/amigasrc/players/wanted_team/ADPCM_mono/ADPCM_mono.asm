	******************************************************
	****      ADPCM mono replayer for EaglePlayer     ****
	**** all adaptions by Wanted Team, MCoder, Meynaf ****
	****      DeliTracker compatible (?) version      ****
	******************************************************

	incdir	"dh2:include/"
	include 'misc/eagleplayer2.01.i'
	include 'hardware/intbits.i'
	include 'exec/exec_lib.i'

	SECTION	Player,CODE

	PLAYERHEADER Tags

	dc.b	'$VER: ADaptative Pulse Code Modulation player module V1.0 (21 July 2008)',0
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
	dc.l	EP_Flags,EPB_LoadFast!EPB_Volume!EPB_ModuleInfo!EPB_Songend!EPB_Packable!EPB_Restart!EPB_CalcDuration
	dc.l	DTP_Flags,PLYF_ANYMEM!PLYF_SONGEND
	dc.l	DTP_Check2,Check3
	dc.l	DTP_Duration,CalcDuration
	dc.l	0

PlayerName
	dc.b	'ADaptative Pulse Code Modulation',0
Creator
	dc.b	"ADPCM decompression routine written",10
	dc.b	'by MCoder, Meynaf and Wanted Team',0
Prefix
	dc.b	'.ADPCM',0
	even

Data
	dc.l	1024			; length of buffer
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
TempD4
	dc.w	0			; temp D4
TempD5
	dc.w	0			; temp D5
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
	mulu.w	#$6400,D0		; timer=(length * period)/5
	rts

***************************************************************************
***************************** EP_Get_ModuleInfo ***************************
***************************************************************************

Get_ModuleInfo
	lea	InfoBuffer(PC),A0
	rts

LoadSize	=	4
Duration	=	12

InfoBuffer
	dc.l	MI_LoadSize,0		;4
	dc.l	MI_Duration,0		;12
	dc.l	MI_Prefix,Prefix
	dc.l	0

***************************************************************************
******************************** EP_Check3 ********************************
***************************************************************************

Check3
	movea.l	dtg_ChkData(A5),A0
	cmp.l	#'ADPC',(A0)			; skip ADPCM2 & ADPCM3 files
	beq.b	Fault
	move.l	dtg_FileArrayPtr(A5),A0
loop
	tst.b	(A0)+
	bne.s	loop
	subq.l	#1,A0

	cmpi.b	#'m',-(A0)
	beq.b	M_OK
	cmpi.b	#'M',(A0)
	bne.s	Fault
M_OK
	cmpi.b	#'c',-(A0)
	beq.b	C_OK
	cmpi.b	#'C',(A0)
	bne.s	Fault
C_OK
	cmpi.b	#'p',-(A0)
	beq.b	C_OK
	cmpi.b	#'P',(A0)
	bne.s	Fault
P_OK
	cmpi.b	#'d',-(A0)
	beq.b	D_OK
	cmpi.b	#'D',(A0)
	bne.s	Fault
D_OK
	cmpi.b	#'a',-(A0)
	beq.b	A_OK
	cmpi.b	#'A',(A0)
	bne.s	Fault
A_OK
	cmpi.b	#'.',-(A0)
	bne.s	Fault

	moveq	#0,D0
	rts
Fault
	moveq	#-1,D0
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
	bclr	#0,D0			; odd byte is ignored
	add.l	D0,D0
	lea	MusicPtr(PC),A1
	move.l	A0,(A1)+
	move.l	D0,(A1)
	move.l	D0,D1
	lsl.l	#7,D0			; * 128
	sub.l	D1,D0			; * 127
	sub.l	D1,D0			; * 126
	sub.l	D1,D0			; * 125 (default period = 28.6kHz)
	move.l	D1,D2
	lsr.l	#6,D0			; / 64
	move.l	#(3546895-15)/64,D1	; (PAL clock/64)
	divu.w	D1,D0
	addq.w	#1,D0
	move.w	D0,Duration+2(A4)
	moveq	#10,D0
	lsr.l	D0,D2
	move.l	D2,(A6)			; Interrupts

	movea.l	dtg_AudioAlloc(A5),A0
	jmp	(A0)

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
	dc.b	'ADPCM Aud0 Interrupt',0,0
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
******************************* ADPCM mono player *************************
***************************************************************************

; ADPCM decompresion routine written by MCoder, Meynaf and Wanted Team

Init
	lea	Data(PC),A1
	move.l	Length-Data(A1),LengthTmp-Data(A1)
	move.l	MusicPtr-Data(A1),MusicTmp-Data(A1)
	clr.l	TempD4-Data(A1)			; TempD4+TempD5
	move.l	BuffyPtr-Data(A1),A0
	moveq	#64,D1
	lsl.w	#4,D1				; $400
	bsr.w	Decompress
	bsr.w	Play_2
	move.w	#$200,D0
	move.w	D0,$A4(A0)
	move.w	D0,$B4(A0)
	move.w	D0,$C4(A0)
	move.w	D0,$D4(A0)
	moveq	#$7D,D0
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
	lsr.w	#2,D0
	subq.w	#1,D0
Clear
	clr.l	(A0)+
	dbf	D0,Clear
	move.l	MusicPtr-Data(A1),MusicTmp-Data(A1)
	move.l	Length-Data(A1),LengthTmp-Data(A1)
	clr.l	TempD4-Data(A1)
	bsr.w	SongEnd
Done
	rts

Decompress
	move.l	a1,a6
	move.l	a0,a1
	move.l	MusicTmp-Data(a6),a0
	sub.l	d1,LengthTmp-Data(a6)
	move.w	TempD4-Data(a6),d4
	ext.l	d4
	move.w	TempD5-Data(a6),d5
	lea	Table1(pc),a3
	lea	Table2(pc),a4
	lsr.w	#2,d0			; 4 bytes / loop
	subq.w	#1,d0			; dbf
	move.w	#$58<<4,d6		; keep d5 (max $58) scaled up 4 bits
	move.w	#$7FFF,d7
.loop
	moveq	#0,d1			; need high(d1)=0
	move.b	(a0)+,d1		; byte 1/2
	moveq	#15,d2
	and.w	d1,d2
	lsr.w	#4,d1

; high part
	move.w	d5,d3
	or.w	d1,d3
	add.w	d3,d3
	move.w	(a4,d3.w),a5
	add.l	a5,d4
	add.w	d1,d1
	add.w	(a3,d1.w),d5
	cmp.w	d6,d5
	blo.b	.skip1
	spl	d5
	ext.w	d5			; d6=$580 -> .w
	and.w	d6,d5
.skip1
	move.w	d4,a5
	cmp.l	a5,d4
	beq.b	.inrange1
	add.l	d4,d4			; sign bit -> x
	subx.l	d4,d4			; x=0 -> d4=0, x=1 -> d4=-1
	eor.w	d7,d4			; 0->7fff, -1->ffff8000
.inrange1
	move.w	d4,d1

; low part
	move.w	d5,d3
	or.w	d2,d3
	add.w	d3,d3
	move.w	(a4,d3.w),a5
	add.l	a5,d4
	add.w	d2,d2
	add.w	(a3,d2.w),d5
	cmp.w	d6,d5
	blo.b	.skip2
	spl	d5
	ext.w	d5			; d6=$580 -> .w
	and.w	d6,d5
.skip2
	move.w	d4,a5
	cmp.l	a5,d4
	beq.b	.inrange2
	add.l	d4,d4			; sign bit -> x
	subx.l	d4,d4			; x=0 -> d4=0, x=1 -> d4=-1
	eor.w	d7,d4			; 0->7fff, -1->ffff8000
.inrange2
	move.w	d4,d2
	lsr.w	#8,d2
	move.b	d2,d1
	swap	d1
	move.b	(a0)+,d1		; byte 2/2
	moveq	#15,d2
	and.w	d1,d2
	lsr.w	#4,d1

; high part
	move.w	d5,d3
	or.w	d1,d3
	add.w	d3,d3
	move.w	(a4,d3.w),a5
	add.l	a5,d4
	add.w	d1,d1
	add.w	(a3,d1.w),d5
	cmp.w	d6,d5
	blo.b	.skip3
	spl	d5
	ext.w	d5			; d6=$580 -> .w
	and.w	d6,d5
.skip3
	move.w	d4,a5
	cmp.l	a5,d4
	beq.b	.inrange3
	add.l	d4,d4			; sign bit -> x
	subx.l	d4,d4			; x=0 -> d4=0, x=1 -> d4=-1
	eor.w	d7,d4			; 0->7fff, -1->ffff8000
.inrange3
	move.w	d4,d1

; low part
	move.w	d5,d3
	or.w	d2,d3
	add.w	d3,d3
	move.w	(a4,d3.w),a5
	add.l	a5,d4
	add.w	d2,d2
	add.w	(a3,d2.w),d5
	cmp.w	d6,d5
	blo.b	.skip4
	spl	d5
	ext.w	d5			; d6=$580 -> .w
	and.w	d6,d5
.skip4
	move.w	d4,a5
	cmp.l	a5,d4
	beq.b	.inrange4
	add.l	d4,d4			; sign bit -> x
	subx.l	d4,d4			; x=0 -> d4=0, x=1 -> d4=-1
	eor.w	d7,d4			; 0->7fff, -1->ffff8000
.inrange4
	move.w	d4,d2
	lsr.w	#8,d2
	move.b	d2,d1
	move.l	d1,(a1)+
	dbf	d0,.loop
	move.l	a0,MusicTmp-Data(a6)
	move.w	d4,TempD4-Data(a6)
	move.w	d5,TempD5-Data(a6)
	rts

Table1
	dc.w	$fff0	; $FFFF<<4
	dc.w	$fff0	; $FFFF<<4
	dc.w	$fff0	; $FFFF<<4
	dc.w	$fff0	; $FFFF<<4
	dc.w	2<<4
	dc.w	4<<4
	dc.w	6<<4
	dc.w	8<<4
	dc.w	$fff0	; $FFFF<<4
	dc.w	$fff0	; $FFFF<<4
	dc.w	$fff0	; $FFFF<<4
	dc.w	$fff0	; $FFFF<<4
	dc.w	2<<4
	dc.w	4<<4
	dc.w	6<<4
	dc.w	8<<4
Table2
	dc.l	2
	dc.l	$40006
	dc.l	$70009
	dc.l	$B000D
	dc.l	$FFFFFFFD
	dc.l	$FFFBFFF9
	dc.l	$FFF8FFF6
	dc.l	$FFF4FFF2
	dc.l	$10003
	dc.l	$50007
	dc.l	$9000B
	dc.l	$D000F
	dc.l	$FFFFFFFD
	dc.l	$FFFBFFF9
	dc.l	$FFF7FFF5
	dc.l	$FFF3FFF1
	dc.l	$10003
	dc.l	$50007
	dc.l	$A000C
	dc.l	$E0010
	dc.l	$FFFEFFFC
	dc.l	$FFFAFFF8
	dc.l	$FFF5FFF3
	dc.l	$FFF1FFEF
	dc.l	$10003
	dc.l	$60008
	dc.l	$B000D
	dc.l	$100012
	dc.l	$FFFEFFFC
	dc.l	$FFF9FFF7
	dc.l	$FFF4FFF2
	dc.l	$FFEFFFED
	dc.l	$10004
	dc.l	$60009
	dc.l	$C000F
	dc.l	$110014
	dc.l	$FFFEFFFB
	dc.l	$FFF9FFF6
	dc.l	$FFF3FFF0
	dc.l	$FFEEFFEB
	dc.l	$10004
	dc.l	$7000A
	dc.l	$D0010
	dc.l	$130016
	dc.l	$FFFEFFFB
	dc.l	$FFF8FFF5
	dc.l	$FFF2FFEF
	dc.l	$FFECFFE9
	dc.l	$10004
	dc.l	$8000B
	dc.l	$E0011
	dc.l	$150018
	dc.l	$FFFEFFFB
	dc.l	$FFF7FFF4
	dc.l	$FFF1FFEE
	dc.l	$FFEAFFE7
	dc.l	$10005
	dc.l	$8000C
	dc.l	$F0013
	dc.l	$16001A
	dc.l	$FFFEFFFA
	dc.l	$FFF7FFF3
	dc.l	$FFF0FFEC
	dc.l	$FFE9FFE5
	dc.l	$20006
	dc.l	$A000E
	dc.l	$120016
	dc.l	$1A001E
	dc.l	$FFFEFFFA
	dc.l	$FFF6FFF2
	dc.l	$FFEEFFEA
	dc.l	$FFE6FFE2
	dc.l	$20006
	dc.l	$A000E
	dc.l	$130017
	dc.l	$1B001F
	dc.l	$FFFDFFF9
	dc.l	$FFF5FFF1
	dc.l	$FFECFFE8
	dc.l	$FFE4FFE0
	dc.l	$20007
	dc.l	$B0010
	dc.l	$15001A
	dc.l	$1E0023
	dc.l	$FFFDFFF8
	dc.l	$FFF4FFEF
	dc.l	$FFEAFFE5
	dc.l	$FFE1FFDC
	dc.l	$20007
	dc.l	$D0012
	dc.l	$17001C
	dc.l	$220027
	dc.l	$FFFDFFF8
	dc.l	$FFF2FFED
	dc.l	$FFE8FFE3
	dc.l	$FFDDFFD8
	dc.l	$20008
	dc.l	$E0014
	dc.l	$19001F
	dc.l	$25002B
	dc.l	$FFFDFFF7
	dc.l	$FFF1FFEB
	dc.l	$FFE6FFE0
	dc.l	$FFDAFFD4
	dc.l	$30009
	dc.l	$F0015
	dc.l	$1C0022
	dc.l	$28002E
	dc.l	$FFFCFFF6
	dc.l	$FFF0FFEA
	dc.l	$FFE3FFDD
	dc.l	$FFD7FFD1
	dc.l	$3000A
	dc.l	$110018
	dc.l	$1F0026
	dc.l	$2D0034
	dc.l	$FFFCFFF5
	dc.l	$FFEEFFE7
	dc.l	$FFE0FFD9
	dc.l	$FFD2FFCB
	dc.l	$3000B
	dc.l	$13001B
	dc.l	$22002A
	dc.l	$32003A
	dc.l	$FFFCFFF4
	dc.l	$FFECFFE4
	dc.l	$FFDDFFD5
	dc.l	$FFCDFFC5
	dc.l	$4000C
	dc.l	$15001D
	dc.l	$26002E
	dc.l	$37003F
	dc.l	$FFFBFFF3
	dc.l	$FFEAFFE2
	dc.l	$FFD9FFD1
	dc.l	$FFC8FFC0
	dc.l	$4000D
	dc.l	$170020
	dc.l	$290032
	dc.l	$3C0045
	dc.l	$FFFBFFF2
	dc.l	$FFE8FFDF
	dc.l	$FFD6FFCD
	dc.l	$FFC3FFBA
	dc.l	$5000F
	dc.l	$190023
	dc.l	$2E0038
	dc.l	$42004C
	dc.l	$FFFAFFF0
	dc.l	$FFE6FFDC
	dc.l	$FFD1FFC7
	dc.l	$FFBDFFB3
	dc.l	$50010
	dc.l	$1C0027
	dc.l	$32003D
	dc.l	$490054
	dc.l	$FFFAFFEF
	dc.l	$FFE3FFD8
	dc.l	$FFCDFFC2
	dc.l	$FFB6FFAB
	dc.l	$60012
	dc.l	$1F002B
	dc.l	$380044
	dc.l	$51005D
	dc.l	$FFF9FFED
	dc.l	$FFE0FFD4
	dc.l	$FFC7FFBB
	dc.l	$FFAEFFA2
	dc.l	$60014
	dc.l	$220030
	dc.l	$3D004B
	dc.l	$590067
	dc.l	$FFF9FFEB
	dc.l	$FFDDFFCF
	dc.l	$FFC2FFB4
	dc.l	$FFA6FF98
	dc.l	$70016
	dc.l	$250034
	dc.l	$430052
	dc.l	$610070
	dc.l	$FFF8FFE9
	dc.l	$FFDAFFCB
	dc.l	$FFBCFFAD
	dc.l	$FF9EFF8F
	dc.l	$80018
	dc.l	$290039
	dc.l	$4A005A
	dc.l	$6B007B
	dc.l	$FFF7FFE7
	dc.l	$FFD6FFC6
	dc.l	$FFB5FFA5
	dc.l	$FF94FF84
	dc.l	$9001B
	dc.l	$2D003F
	dc.l	$520064
	dc.l	$760088
	dc.l	$FFF6FFE4
	dc.l	$FFD2FFC0
	dc.l	$FFADFF9B
	dc.l	$FF89FF77
	dc.l	$A001E
	dc.l	$320046
	dc.l	$5A006E
	dc.l	$820096
	dc.l	$FFF6FFE2
	dc.l	$FFCEFFBA
	dc.l	$FFA6FF92
	dc.l	$FF7EFF6A
	dc.l	$B0021
	dc.l	$37004D
	dc.l	$630079
	dc.l	$8F00A5
	dc.l	$FFF5FFDF
	dc.l	$FFC9FFB3
	dc.l	$FF9DFF87
	dc.l	$FF71FF5B
	dc.l	$C0024
	dc.l	$3C0054
	dc.l	$6D0085
	dc.l	$9D00B5
	dc.l	$FFF3FFDB
	dc.l	$FFC3FFAB
	dc.l	$FF92FF7A
	dc.l	$FF62FF4A
	dc.l	$D0028
	dc.l	$42005D
	dc.l	$780093
	dc.l	$AD00C8
	dc.l	$FFF2FFD7
	dc.l	$FFBDFFA2
	dc.l	$FF87FF6C
	dc.l	$FF52FF37
	dc.l	$E002C
	dc.l	$490067
	dc.l	$8400A2
	dc.l	$BF00DD
	dc.l	$FFF1FFD3
	dc.l	$FFB6FF98
	dc.l	$FF7BFF5D
	dc.l	$FF40FF22
	dc.l	$100030
	dc.l	$510071
	dc.l	$9200B2
	dc.l	$D300F3
	dc.l	$FFEFFFCF
	dc.l	$FFAEFF8E
	dc.l	$FF6DFF4D
	dc.l	$FF2CFF0C
	dc.l	$110035
	dc.l	$59007D
	dc.l	$A000C4
	dc.l	$E8010C
	dc.l	$FFEEFFCA
	dc.l	$FFA6FF82
	dc.l	$FF5FFF3B
	dc.l	$FF17FEF3
	dc.l	$13003A
	dc.l	$620089
	dc.l	$B000D7
	dc.l	$FF0126
	dc.l	$FFECFFC5
	dc.l	$FF9DFF76
	dc.l	$FF4FFF28
	dc.l	$FF00FED9
	dc.l	$150040
	dc.l	$6C0097
	dc.l	$C200ED
	dc.l	$1190144
	dc.l	$FFEAFFBF
	dc.l	$FF93FF68
	dc.l	$FF3DFF12
	dc.l	$FEE6FEBB
	dc.l	$170047
	dc.l	$7600A6
	dc.l	$D50105
	dc.l	$1340164
	dc.l	$FFE8FFB8
	dc.l	$FF89FF59
	dc.l	$FF2AFEFA
	dc.l	$FECBFE9B
	dc.l	$1A004E
	dc.l	$8200B6
	dc.l	$EB011F
	dc.l	$1530187
	dc.l	$FFE5FFB1
	dc.l	$FF7DFF49
	dc.l	$FF14FEE0
	dc.l	$FEACFE78
	dc.l	$1C0056
	dc.l	$8F00C9
	dc.l	$102013C
	dc.l	$17501AF
	dc.l	$FFE3FFA9
	dc.l	$FF70FF36
	dc.l	$FEFDFEC3
	dc.l	$FE8AFE50
	dc.l	$1F005E
	dc.l	$9E00DD
	dc.l	$11C015B
	dc.l	$19B01DA
	dc.l	$FFE0FFA1
	dc.l	$FF61FF22
	dc.l	$FEE3FEA4
	dc.l	$FE64FE25
	dc.l	$220068
	dc.l	$AE00F4
	dc.l	$139017F
	dc.l	$1C5020B
	dc.l	$FFDDFF97
	dc.l	$FF51FF0B
	dc.l	$FEC6FE80
	dc.l	$FE3AFDF4
	dc.l	$260073
	dc.l	$BF010C
	dc.l	$15901A6
	dc.l	$1F2023F
	dc.l	$FFD9FF8C
	dc.l	$FF40FEF3
	dc.l	$FEA6FE59
	dc.l	$FE0DFDC0
	dc.l	$2A007E
	dc.l	$D20126
	dc.l	$17B01CF
	dc.l	$2230277
	dc.l	$FFD5FF81
	dc.l	$FF2DFED9
	dc.l	$FE84FE30
	dc.l	$FDDCFD88
	dc.l	$2E008B
	dc.l	$E70144
	dc.l	$1A101FE
	dc.l	$25A02B7
	dc.l	$FFD1FF74
	dc.l	$FF18FEBB
	dc.l	$FE5EFE01
	dc.l	$FDA5FD48
	dc.l	$330099
	dc.l	$FF0165
	dc.l	$1CB0231
	dc.l	$29702FD
	dc.l	$FFCDFF67
	dc.l	$FF01FE9B
	dc.l	$FE35FDCF
	dc.l	$FD69FD03
	dc.l	$3800A8
	dc.l	$1180188
	dc.l	$1F90269
	dc.l	$2D90349
	dc.l	$FFC7FF57
	dc.l	$FEE7FE77
	dc.l	$FE06FD96
	dc.l	$FD26FCB6
	dc.l	$3D00B9
	dc.l	$13401B0
	dc.l	$22B02A7
	dc.l	$322039E
	dc.l	$FFC2FF46
	dc.l	$FECBFE4F
	dc.l	$FDD4FD58
	dc.l	$FCDDFC61
	dc.l	$4400CC
	dc.l	$15401DC
	dc.l	$26402EC
	dc.l	$37403FC
	dc.l	$FFBCFF34
	dc.l	$FEACFE24
	dc.l	$FD9CFD14
	dc.l	$FC8CFC04
	dc.l	$4A00E0
	dc.l	$175020B
	dc.l	$2A00336
	dc.l	$3CB0461
	dc.l	$FFB5FF1F
	dc.l	$FE8AFDF4
	dc.l	$FD5FFCC9
	dc.l	$FC34FB9E
	dc.l	$5200F6
	dc.l	$19B023F
	dc.l	$2E40388
	dc.l	$42D04D1
	dc.l	$FFADFF09
	dc.l	$FE64FDC0
	dc.l	$FD1BFC77
	dc.l	$FBD2FB2E
	dc.l	$5A010F
	dc.l	$1C40279
	dc.l	$32E03E3
	dc.l	$498054D
	dc.l	$FFA5FEF0
	dc.l	$FE3BFD86
	dc.l	$FCD1FC1C
	dc.l	$FB67FAB2
	dc.l	$63012A
	dc.l	$1F102B8
	dc.l	$37F0446
	dc.l	$50D05D4
	dc.l	$FF9CFED5
	dc.l	$FE0EFD47
	dc.l	$FC80FBB9
	dc.l	$FAF2FA2B
	dc.l	$6D0148
	dc.l	$22302FE
	dc.l	$3D904B4
	dc.l	$58F066A
	dc.l	$FF92FEB7
	dc.l	$FDDCFD01
	dc.l	$FC26FB4B
	dc.l	$FA70F995
	dc.l	$780169
	dc.l	$259034A
	dc.l	$43B052C
	dc.l	$61C070D
	dc.l	$FF87FE96
	dc.l	$FDA6FCB5
	dc.l	$FBC4FAD3
	dc.l	$F9E3F8F2
	dc.l	$84018D
	dc.l	$296039F
	dc.l	$4A805B1
	dc.l	$6BA07C3
	dc.l	$FF7BFE72
	dc.l	$FD69FC60
	dc.l	$FB57FA4E
	dc.l	$F945F83C
	dc.l	$9101B5
	dc.l	$2D803FC
	dc.l	$51F0643
	dc.l	$766088A
	dc.l	$FF6EFE4A
	dc.l	$FD27FC03
	dc.l	$FAE0F9BC
	dc.l	$F899F775
	dc.l	$A001E0
	dc.l	$3210461
	dc.l	$5A206E2
	dc.l	$8230963
	dc.l	$FF5FFE1F
	dc.l	$FCDEFB9E
	dc.l	$FA5DF91D
	dc.l	$F7DCF69C
	dc.l	$B00211
	dc.l	$37104D2
	dc.l	$6330794
	dc.l	$8F40A55
	dc.l	$FF4FFDEE
	dc.l	$FC8EFB2D
	dc.l	$F9CCF86B
	dc.l	$F70BF5AA
	dc.l	$C20246
	dc.l	$3CA054E
	dc.l	$6D20856
	dc.l	$9DA0B5E
	dc.l	$FF3EFDBA
	dc.l	$FC36FAB2
	dc.l	$F92EF7AA
	dc.l	$F626F4A2
	dc.l	$D50280
	dc.l	$42A05D5
	dc.l	$780092B
	dc.l	$AD50C80
	dc.l	$FF2AFD7F
	dc.l	$FBD5FA2A
	dc.l	$F87FF6D4
	dc.l	$F52AF37F
	dc.l	$EA02C0
	dc.l	$495066B
	dc.l	$8400A16
	dc.l	$BEB0DC1
	dc.l	$FF15FD3F
	dc.l	$FB6AF994
	dc.l	$F7BFF5E9
	dc.l	$F414F23E
	dc.l	$1020306
	dc.l	$50B070F
	dc.l	$9140B18
	dc.l	$D1D0F21
	dc.l	$FEFDFCF9
	dc.l	$FAF4F8F0
	dc.l	$F6EBF4E7
	dc.l	$F2E2F0DE
	dc.l	$11C0354
	dc.l	$58C07C4
	dc.l	$9FC0C34
	dc.l	$E6C10A4
	dc.l	$FEE4FCAC
	dc.l	$FA74F83C
	dc.l	$F604F3CC
	dc.l	$F194EF5C
	dc.l	$13803A9
	dc.l	$619088A
	dc.l	$AFB0D6C
	dc.l	$FDC124D
	dc.l	$FEC7FC56
	dc.l	$F9E6F775
	dc.l	$F504F293
	dc.l	$F023EDB2
	dc.l	$1570406
	dc.l	$6B60965
	dc.l	$C140EC3
	dc.l	$11731422
	dc.l	$FEA8FBF9
	dc.l	$F949F69A
	dc.l	$F3EBF13C
	dc.l	$EE8CEBDD
	dc.l	$17A046E
	dc.l	$7620A56
	dc.l	$D4A103E
	dc.l	$13321626
	dc.l	$FE86FB92
	dc.l	$F89EF5AA
	dc.l	$F2B6EFC2
	dc.l	$ECCEE9DA
	dc.l	$19F04DF
	dc.l	$81F0B5F
	dc.l	$E9E11DE
	dc.l	$151E185E
	dc.l	$FE60FB20
	dc.l	$F7E0F4A0
	dc.l	$F161EE21
	dc.l	$EAE1E7A1
	dc.l	$1C9055C
	dc.l	$8EF0C82
	dc.l	$101513A8
	dc.l	$173B1ACE
	dc.l	$FE36FAA3
	dc.l	$F710F37D
	dc.l	$EFEAEC57
	dc.l	$E8C4E531
	dc.l	$1F705E5
	dc.l	$9D40DC2
	dc.l	$11B1159F
	dc.l	$198E1D7C
	dc.l	$FE08FA1A
	dc.l	$F62BF23D
	dc.l	$EE4EEA60
	dc.l	$E671E283
	dc.l	$229067C
	dc.l	$ACF0F22
	dc.l	$137517C8
	dc.l	$1C1B206E
	dc.l	$FDD6F983
	dc.l	$F530F0DD
	dc.l	$EC8AE837
	dc.l	$E3E4DF91
	dc.l	$2600722
	dc.l	$BE410A6
	dc.l	$15671A29
	dc.l	$1EEB23AD
	dc.l	$FD9FF8DD
	dc.l	$F41BEF59
	dc.l	$EA98E5D6
	dc.l	$E114DC52
	dc.l	$29D07D9
	dc.l	$D141250
	dc.l	$178B1CC7
	dc.l	$2202273E
	dc.l	$FD62F826
	dc.l	$F2EBEDAF
	dc.l	$E874E338
	dc.l	$DDFDD8C1
	dc.l	$2E008A2
	dc.l	$E631425
	dc.l	$19E61FA8
	dc.l	$25692B2B
	dc.l	$FD1FF75D
	dc.l	$F19CEBDA
	dc.l	$E619E057
	dc.l	$DA96D4D4
	dc.l	$32A097F
	dc.l	$FD41629
	dc.l	$1C7E22D3
	dc.l	$29282F7D
	dc.l	$FCD5F680
	dc.l	$F02BE9D6
	dc.l	$E381DD2C
	dc.l	$D6D7D082
	dc.l	$37B0A72
	dc.l	$11691860
	dc.l	$1F57264E
	dc.l	$2D45343C
	dc.l	$FC84F58D
	dc.l	$EE96E79F
	dc.l	$E0A8D9B1
	dc.l	$D2BACBC3
	dc.l	$3D40B7D
	dc.l	$13271AD0
	dc.l	$22792A22
	dc.l	$31CC3975
	dc.l	$FC2BF482
	dc.l	$ECD8E52F
	dc.l	$DD86D5DD
	dc.l	$CE33C68A
	dc.l	$4360CA4
	dc.l	$15111D7F
	dc.l	$25EC2E5A
	dc.l	$36C73F35
	dc.l	$FBC9F35B
	dc.l	$EAEEE280
	dc.l	$DA13D1A5
	dc.l	$C938C0CA
	dc.l	$4A20DE7
	dc.l	$172D2072
	dc.l	$29B732FC
	dc.l	$3C424587
	dc.l	$FB5DF218
	dc.l	$E8D2DF8D
	dc.l	$D648CD03
	dc.l	$C3BDBA78
	dc.l	$5190F4B
	dc.l	$197E23B0
	dc.l	$2DE33815
	dc.l	$42484C7A
	dc.l	$FAE6F0B4
	dc.l	$E681DC4F
	dc.l	$D21CC7EA
	dc.l	$BDB7B385
	dc.l	$59B10D3
	dc.l	$1C0B2743
	dc.l	$327A3DB2
	dc.l	$48EA5422
	dc.l	$FA64EF2C
	dc.l	$E3F4D8BC
	dc.l	$CD85C24D
	dc.l	$B715ABDD
	dc.l	$62B1282
	dc.l	$1ED82B2F
	dc.l	$378643DD
	dc.l	$50335C8A
	dc.l	$F9D4ED7D
	dc.l	$E127D4D0
	dc.l	$C879BC22
	dc.l	$AFCCA375
	dc.l	$6C9145C
	dc.l	$21EE2F81
	dc.l	$3D144AA7
	dc.l	$583965CC
	dc.l	$F936EBA3
	dc.l	$DE11D07E
	dc.l	$C2EBB558
	dc.l	$A7C69A33
	dc.l	$7771665
	dc.l	$25533441
	dc.l	$4330521E
	dc.l	$610C6FFA
	dc.l	$F888E99A
	dc.l	$DAACCBBE
	dc.l	$BCCFADE1
	dc.l	$9EF39005
	dc.l	$83618A2
	dc.l	$290F397B
	dc.l	$49E85A54
	dc.l	$6AC17B2D
	dc.l	$F7C9E75D
	dc.l	$D6F0C684
	dc.l	$B617A5AB
	dc.l	$953E84D2
	dc.l	$9081B19
	dc.l	$2D2A3F3B
	dc.l	$514C635D
	dc.l	$756E7FFF
	dc.l	$F6F7E4E6
	dc.l	$D2D5C0C4
	dc.l	$AEB39CA2
	dc.l	$8A918000
	dc.l	$9EF1DCF
	dc.l	$31AE458E
	dc.l	$596D6D4D
	dc.l	$7FFF7FFF
	dc.l	$F610E230
	dc.l	$CE51BA71
	dc.l	$A69292B2
	dc.l	$80008000
	dc.l	$AEE20CA
	dc.l	$36A64C82
	dc.l	$625F783B
	dc.l	$7FFF7FFF
	dc.l	$F511DF35
	dc.l	$C959B37D
	dc.l	$9DA087C4
	dc.l	$80008000
	dc.l	$C052411
	dc.l	$3C1D5429
	dc.l	$6C347FFF
	dc.l	$7FFF7FFF
	dc.l	$F3FADBEE
	dc.l	$C3E2ABD6
	dc.l	$93CB8000
	dc.l	$80008000
	dc.l	$D3927AD
	dc.l	$42205C94
	dc.l	$77077FFF
	dc.l	$7FFF7FFF
	dc.l	$F2C6D852
	dc.l	$BDDFA36B
	dc.l	$88F88000
	dc.l	$80008000
	dc.l	$E8C2BA4
	dc.l	$48BD65D5
	dc.l	$7FFF7FFF
	dc.l	$7FFF7FFF
	dc.l	$F173D45B
	dc.l	$B7429A2A
	dc.l	$80008000
	dc.l	$80008000
	dc.l	$FFF2FFF
	dc.l	$4FFF6FFF
	dc.l	$7FFF7FFF
	dc.l	$7FFF7FFF
	dc.l	$F000D000
	dc.l	$B0009000
	dc.l	$80008000
	dc.l	$80008000

	Section	Buffy,BSS_C
Buffy_1
	ds.b	1024
Buffy_2
	ds.b	1024

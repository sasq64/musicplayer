	*****************************************************
	****     Quartet PSG replayer for EaglePlayer    ****
	****         all adaptions by Wanted Team,	 ****
	****      DeliTracker (?) compatible version	 ****
	*****************************************************

	incdir	"dh2:include/"
	include "misc/eagleplayer2.01.i"
	include	'hardware/custom.i'

	SECTION	Player,CODE

	PLAYERHEADER Tags

	dc.b	'$VER: Quartet PSG player module V1.0 (12 Feb 2007)',0
	even
Tags
	dc.l	DTP_PlayerVersion,1
	dc.l	EP_PlayerVersion,9
	dc.l	DTP_PlayerName,PlayerName
	dc.l	DTP_RequestDTVersion,DELIVERSION
	dc.l	DTP_Creator,Creator
	dc.l	DTP_Check2,Check2
	dc.l	DTP_Interrupt,Interrupt
	dc.l	DTP_InitPlayer,InitPlayer
	dc.l	DTP_EndPlayer,EndPlayer
	dc.l	DTP_InitSound,InitSound
	dc.l	DTP_EndSound,EndSound
	dc.l	DTP_SubSongRange,SubSongRange
	dc.l	EP_Get_ModuleInfo,GetInfos
	dc.l	DTP_Volume,SetVolume
	dc.l	DTP_Balance,SetBalance
	dc.l	EP_Voices,SetVoices
	dc.l	EP_StructInit,StructInit
	dc.l	EP_Flags,EPB_Volume!EPB_Balance!EPB_ModuleInfo!EPB_Voices!EPB_Songend!EPB_Analyzer!EPB_Packable!EPB_Restart!EPB_PrevSong!EPB_NextSong!EPB_LoadFast
	dc.l	TAG_DONE

PlayerName
	dc.b	'Quartet PSG',0
Creator
	dc.b	'(c) 1990 by Rob Povey & Steve',10
	dc.b	'Wetherill, adapted by Wanted Team',0
Prefix
	dc.b	'SQT.',0
	even
ModulePtr
	dc.l	0
EagleBase
	dc.l	0
Songend
	dc.l	'WTWT'
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
*************************** DTP_Volume DTP_Balance ************************
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

ChangeVolume
	move.l	D1,-(A7)
	move.l	A1,D1
	cmp.w	#$F0A0,D1
	beq.s	Left1
	cmp.w	#$F0B0,D1
	beq.s	Right1
	cmp.w	#$F0C0,D1
	beq.s	Right2
	cmp.w	#$F0D0,D1
	bne.s	Exit
Left2
	mulu.w	LeftVolume(PC),D0
	and.w	Voice4(PC),D0
	bra.s	Ex
Left1
	mulu.w	LeftVolume(PC),D0
	and.w	Voice1(PC),D0
	bra.s	Ex

Right1
	mulu.w	RightVolume(PC),D0
	and.w	Voice2(PC),D0
	bra.s	Ex
Right2
	mulu.w	RightVolume(PC),D0
	and.w	Voice3(PC),D0
Ex
	lsr.w	#6,D0
Exit
	move.l	(A7)+,D1
	rts

*-------------------------------- Set Vol -------------------------------*

SetVol
	move.l	A0,-(SP)
	lea	StructAdr+UPS_Voice1Vol(PC),A0
	cmp.l	#$DFF0A0,A1
	beq.b	.SetVoice
	lea	StructAdr+UPS_Voice2Vol(PC),A0
	cmp.l	#$DFF0B0,A1
	beq.b	.SetVoice
	lea	StructAdr+UPS_Voice3Vol(PC),A0
	cmp.l	#$DFF0C0,A1
	beq.b	.SetVoice
	lea	StructAdr+UPS_Voice4Vol(PC),A0
.SetVoice
	move.w	D0,(A0)
	move.l	(SP)+,A0
	rts

*-------------------------------- Set Two -------------------------------*

SetTwo
	move.l	A0,-(SP)
	lea	StructAdr+UPS_Voice1Adr(PC),A0
	cmp.l	#$DFF0A0,A1
	beq.b	.SetVoice
	lea	StructAdr+UPS_Voice2Adr(PC),A0
	cmp.l	#$DFF0B0,A1
	beq.b	.SetVoice
	lea	StructAdr+UPS_Voice3Adr(PC),A0
	cmp.l	#$DFF0C0,A1
	beq.b	.SetVoice
	lea	StructAdr+UPS_Voice4Adr(PC),A0
.SetVoice
	move.l	A2,(A0)
	move.w	D4,UPS_Voice1Len(A0)
	move.l	(SP)+,A0
	rts

*-------------------------------- Set Per -------------------------------*

SetPer
	move.l	A0,-(SP)
	lea	StructAdr+UPS_Voice1Per(PC),A0
	cmp.l	#$DFF0A0,A1
	beq.b	.SetVoice
	lea	StructAdr+UPS_Voice2Per(PC),A0
	cmp.l	#$DFF0B0,A1
	beq.b	.SetVoice
	lea	StructAdr+UPS_Voice3Per(PC),A0
	cmp.l	#$DFF0C0,A1
	beq.b	.SetVoice
	lea	StructAdr+UPS_Voice4Per(PC),A0
.SetVoice
	move.w	D0,(A0)
	move.l	(SP)+,A0
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
******************************* DTP_Check2 ********************************
***************************************************************************

Check2
	move.l	dtg_ChkData(A5),A0
	moveq	#-1,D0

	moveq	#3,D1
GoodBra
	cmp.w	#$6000,(A0)+
	bne.b	Fault
	move.w	(A0)+,D2
	bmi.b	Fault
	beq.b	Fault
	btst	#0,D2
	bne.b	Fault
	dbf	D1,GoodBra
	cmp.w	#$49FA,(A0)
	bne.b	Fault
	subq.l	#6,A0
	add.w	(A0),A0
	cmp.l	#$48E7FFFE,(A0)+
	bne.b	Fault
	cmp.w	#$4DFA,(A0)
	bne.b	Fault
	cmp.w	#$51EE,4(A0)
	bne.b	Fault
	cmp.w	#$6100,8(A0)
	bne.b	Fault
	moveq	#0,D0
Fault
	rts

***************************************************************************
***************************** EP_Get_ModuleInfo ***************************
***************************************************************************

GetInfos
	lea	InfoBuffer(PC),A0
	rts

LoadSize	=	4
CalcSize	=	12
SubSongs	=	20
SongSize	=	28

InfoBuffer
	dc.l	MI_LoadSize,0		;4
	dc.l	MI_Calcsize,0		;12
	dc.l	MI_SubSongs,0		;20
	dc.l	MI_Songsize,0		;28
	dc.l	MI_Voices,3
	dc.l	MI_MaxVoices,3
	dc.l	MI_Prefix,Prefix
	dc.l	0

***************************************************************************
***************************** DTP_SubSongRange ****************************
***************************************************************************

SubSongRange
	moveq	#0,D0
	move.l	InfoBuffer+SubSongs(PC),D1
	subq.l	#1,D1
	rts

***************************************************************************
***************************** DTP_Intterrupt ******************************
***************************************************************************

Interrupt	
	movem.l	D0-D7/A0-A6,-(SP)

	lea	StructAdr(PC),A0
	st	UPS_Enabled(A0)
	clr.w	UPS_Voice1Per(A0)
	clr.w	UPS_Voice2Per(A0)
	clr.w	UPS_Voice3Per(A0)
	clr.w	UPS_Voice4Per(A0)
	move.w	#UPSB_Adr!UPSB_Len!UPSB_Per!UPSB_Vol,UPS_Flags(A0)

	move.l	ModulePtr(PC),A0
	jsr	4(A0)
	bsr.w	Play_Emu

	lea	StructAdr(PC),A0
	clr.w	UPS_Enabled(A0)

	movem.l	(SP)+,D0-D7/A0-A6
	rts

SongEndTest
	move.l	$32(A4),A0
	movem.l	A1/A5,-(A7)
	lea	Songend(PC),A1
	cmp.b	#8,$3E(A4)
	bne.b	test1
	clr.b	(A1)
	bra.b	test
test1
	cmp.b	#10,$3E(A4)
	bne.b	test3
	clr.b	2(A1)
	bra.b	test
test3
	cmp.b	#9,$3E(A4)
	bne.b	test
	clr.b	3(A1)
test
	tst.l	(A1)
	bne.b	SkipEnd
	move.l	#$FF00FFFF,(A1)
	move.l	EagleBase(PC),A5
	move.l	dtg_SongEnd(A5),A1
	jsr	(A1)
SkipEnd
	movem.l	(A7)+,A1/A5
	rts

***************************************************************************
***************************** DTP_InitPlayer ******************************
***************************************************************************

InitPlayer
	lea	lbL001070,A0
	tst.l	(A0)
	bne.b	SampOK
	bsr.w	InitSamp
	move.l	#$B2B24D4D,(A0)
SampOK
	moveq	#0,D0
	movea.l	dtg_GetListData(A5),A0
	jsr	(A0)

	lea	ModulePtr(PC),A6
	move.l	A0,(A6)+			; module buffer
	move.l	A5,(A6)				; EagleBase
	lea	InfoBuffer(PC),A4
	move.l	D0,LoadSize(A4)

	move.l	A0,A1
	move.w	#$4E71,D1
Find1
	cmp.w	#$40C2,(A1)+
	bne.b	Find1
	subq.l	#2,A1
Nopuj1
	move.w	D1,(A1)+
	cmp.w	#$41FA,(A1)
	bne.b	Nopuj1

	addq.l	#6,A1
	move.l	A1,A2
	add.w	(A1)+,A2
Find1a
	cmp.w	#$43E9,(A1)+
	bne.b	Find1a
	add.w	(A1),A2
	add.w	(A1)+,A2
	move.l	A2,A3
	sub.l	A0,A2
	cmp.l	D0,A2
	bgt.b	Short
	move.l	A2,CalcSize(A4)

Find2
	cmp.l	#$206C0032,(A1)
	bne.b	NoTest
	addq.l	#8,A0
	move.l	A0,D2
	move.w	#$4EF9,(A0)+			; jmp
	lea	SongEndTest(PC),A2
	move.l	A2,(A0)				; to
	move.w	#$6100,(A1)+
	sub.l	A1,D2
	move.w	D2,(A1)+
NoTest
	cmp.l	#$8380007,(A1)
	beq.b	PK
	cmp.l	#$8390007,(A1)
	beq.b	PK
	addq.l	#2,A1
	bne.b	Find2
PK
	move.b	#$60,-8(A1)			; skip access to ST registers
Find3
	cmp.w	#$40C1,(A1)+
	bne.b	Find3
	move.w	#$4EB9,-2(A1)			; jsr
	lea	Patch(PC),A2
	move.l	A2,(A1)+			; to
Nopuj3
	move.w	D1,(A1)+
	cmp.w	#$4CDF,(A1)
	bne.b	Nopuj3

	moveq	#$56,D1
More
	cmp.l	(A1),D1
	beq.b	Later
	addq.l	#2,A1
	bra.b	More
Later
	moveq	#$46,D1
	moveq	#0,D0
Next
	cmp.w	(A1)+,D1
	bne.b	NoEnd
	addq.l	#1,D0
NoEnd
	cmp.l	A1,A3
	bne.b	Next
	lsr.l	#2,D0
	move.l	D0,SubSongs(A4)

	movea.l	dtg_AudioAlloc(A5),A0
	jmp	(A0)

Short
	moveq	#EPR_ModuleTooShort,D0
	rts

Patch
	lea	lbL000E26(PC),A0
	move.b	(A5)+,6(A0)
	move.b	(A5)+,2(A0)
	move.b	(A5)+,14(A0)
	move.b	(A5)+,10(A0)
	move.b	(A5)+,22(A0)
	move.b	(A5)+,18(A0)
	move.b	(A5)+,26(A0)
	move.b	(A5)+,30(A0)
	move.b	(A5)+,34(A0)
	move.b	(A5)+,38(A0)
	move.b	(A5)+,42(A0)
	rts

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

	bsr.w	Init_Emu
	lea	Songend(PC),A0
	move.l	#$FF00FFFF,(A0)
	move.w	dtg_SndNum(A5),D0
	move.l	ModulePtr(PC),A0
	jmp	(A0)

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
***************************************************************************
***************************************************************************

Voice
	dc.b	1			; left 1
	dc.b	8			; left 2
	dc.b	4			; right 2
	dc.b	2			; right 1
NotePlay
	lea	$dff000,A5			; load CustomBase

; Note: d2 must contain the DMA mask of the channels you want to stop,
;       and d3 the DMA mask of the channels you want to start.
;       The vhpos, vhposr, etc. definitions can be found in the
;       hardware/custom.i include file.
;       BTW - this routine cannot be used if a replay uses audio-interrupts
;       (because it uses the intreq/intreqr registers for waiting)!

	moveq	#0,D2
	move.b	Voice(PC,D5.W),D2

.StopDMA
	move.b	vhposr(A5),d1
.WaitLine1
	cmp.b	vhposr(A5),d1			; sync routine to start at linestart
	beq.s	.WaitLine1
.WaitDMA1
	cmp.b	#$16,vhposr+1(A5)		; wait til after Audio DMA slots
	bcs.s	.WaitDMA1
	move.w	#1,6(A1)

	move.w	dmaconr(A5),d0			; get active channels
	and.w	d2,d0
	move.w	d0,d1
	lsl.w	#7,d0
	move.w	d0,intreq(A5)			; clear requests
	move.w	d1,dmacon(A5)			; stop channels
.WaitStop
	move.w	intreqr(A5),d1			; wait until all channels are stopped
	and.w	d0,d1
	cmp.w	d0,d1
	bne.s	.WaitStop
.Skip

; Here you must set the oneshot-parts of the samples you stopped before

	move.l	A2,(A1)
	move.w	D4,4(A1)
	bsr.w	SetTwo
	swap	D4

; Because of the period = 1 trick used above, you must _always_ set the period
; of the stopped channels here, otherwise the output will sound wrong
; If you want to mute a channel, you can either turn it off, but not on again
; (by setting the channel's DMA bit in the d2 register, and clearing the channel's
; DMA bit in the d3 register), or you have to play a oneshot-nullsample and
; a loop-nullsample (smiliar to ProTracker)

	move.b	vhposr(A5),d1
.WaitLine2
	cmp.b	vhposr(A5),d1			; sync routine to start at linestart
	beq.s	.WaitLine2
.WaitDMA2
	cmp.b	#$16,vhposr+1(A5)		; wait til after Audio DMA slots
	bcs.s	.WaitDMA2
.StartDMA
	move.w	dmaconr(A5),d0			; get active channels
	not.w	d0
	and.w	D2,D0

	move.w	d0,d1
	or.w	#$8000,d1
	lsl.w	#7,d0
	move.w	d0,intreq(A5)			; clear requests
	move.w	d1,dmacon(A5)			; start channels
.WaitStart
	move.w	intreqr(A5),d1			; wait until all channels are running
	and.w	d0,d1
	cmp.w	d0,d1
	bne.s	.WaitStart

	move.b	vhposr(A5),d1
.WaitLine3
	cmp.b	vhposr(A5),d1			; sync routine to start at linestart
	beq.s	.WaitLine3
.WaitDMA3
	cmp.b	#$16,vhposr+1(A5)		; wait til after Audio DMA slots
	bcs.s	.WaitDMA3

; Here you must set the loop-parts of the samples. If a sample doesn't have
; a loop, then you have to play a nullsample of length 1 (similiar to ProTracker).

	move.l	A3,(A1)
	move.w	D4,4(A1)
.Done
	rts

Init_Emu
lbC000392	LEA	lbL000616(PC),A0
	MOVE.W	#0,10(A0)
	LEA	lbL000622(PC),A0
	MOVE.W	#0,10(A0)
	LEA	lbL00062E(PC),A0
	MOVE.W	#0,10(A0)
	LEA	lbL000E26(PC),A0
	MOVE.B	#$3B,$1E(A0)
	MOVE.B	#$10,$2A(A0)
	MOVE.B	#0,$26(A0)
	MOVE.B	#0,$22(A0)
	MOVE.B	#4,$16(A0)
	MOVE.B	#0,$12(A0)
	RTS

Play_Emu
	LEA	lbL000E26(PC),A6
	MOVE.B	$1E(A6),D7
	NOT.B	D7
	ANDI.W	#$3F,D7

	lea	$DFF0A0,A1

	LEA	lbL000616(PC),A0
	MOVEQ	#0,D5
	MOVEQ	#3,D6
	MOVE.B	6(A6),D4
	LSL.W	#8,D4
	MOVE.B	2(A6),D4
	MOVE.B	$22(A6),D3
	BSR.L	lbC0004DC

	lea	$DFF0D0,A1

	LEA	lbL000622(PC),A0
	MOVEQ	#1,D5
	MOVEQ	#4,D6
	MOVE.B	14(A6),D4
	LSL.W	#8,D4
	MOVE.B	10(A6),D4
	MOVE.B	$26(A6),D3
	BSR.L	lbC0004DC

	lea	$DFF0C0,A1

	LEA	lbL00062E(PC),A0
	MOVEQ	#2,D5
	MOVEQ	#5,D6
	MOVE.B	$16(A6),D4
	LSL.W	#8,D4
	MOVE.B	$12(A6),D4
	MOVE.B	$2A(A6),D3
	BSR.L	lbC0004DC
	RTS

lbB0004CA	dc.b	0
	dc.b	1
	dc.b	2
	dc.b	3
	dc.b	4
	dc.b	6
	dc.b	8
	dc.b	10
	dc.b	13
	dc.b	$10
	dc.b	$14
	dc.b	$18
	dc.b	$1E
	dc.b	$26
	dc.b	$30
	dc.b	$40
;	dc.b	$20
;	dc.b	0

lbC0004DC

	and.w	#15,D3

	MOVE.B	lbB0004CA(PC,D3.W),1(A0)
	MULU.W	#7,D4
	MOVE.W	D4,2(A0)
	BTST	D5,D7
	BNE.L	lbC0005DA
	BTST	D6,D7
	BNE.L	lbC00054A

	lea	lbL001470,A2
	move.l	A2,A3
	move.l	#$10001,D4
	bsr.w	NotePlay

	MOVE.W	#0,0(A0)
	MOVE.W	#$100,2(A0)
	MOVE.W	#0,10(A0)
lbC000530
	move.w	(A0),D0
	bsr.w	ChangeVolume
	bsr.w	SetVol
	move.w	D0,8(A1)
	move.w	2(A0),D0
	move.w	D0,6(A1)
	bsr.w	SetPer

	RTS

lbC00054A	MOVE.W	10(A0),D0
	CMP.W	#2,D0
	BEQ.S	lbC000582
	MOVE.W	#2,10(A0)

	lea	lbL001070,A2
	move.l	A2,A3
	move.l	#$2000200,D4
	bsr.w	NotePlay

lbC000582	MOVEQ	#0,D0
	MOVE.B	$1A(A6),D0
	ANDI.W	#$1F,D0
	ADD.W	D0,D0
	MOVE.W	lbW00059A(PC,D0.W),D0
	MOVE.W	D0,2(A0)
	BRA.L	lbC000530

lbW00059A	dc.w	$280
	dc.w	$270
	dc.w	$260
	dc.w	$250
	dc.w	$240
	dc.w	$230
	dc.w	$220
	dc.w	$210
	dc.w	$200
	dc.w	$1F0
	dc.w	$1E0
	dc.w	$1D0
	dc.w	$1C0
	dc.w	$1B0
	dc.w	$1A0
	dc.w	$190
	dc.w	$180
	dc.w	$170
	dc.w	$160
	dc.w	$150
	dc.w	$140
	dc.w	$130
	dc.w	$120
	dc.w	$110
	dc.w	$100
	dc.w	$F0
	dc.w	$E0
	dc.w	$D0
	dc.w	$C0
	dc.w	$B0
	dc.w	$A0
	dc.w	$90

lbC0005DA	MOVE.W	10(A0),D0
	CMP.W	#1,D0
	BEQ.S	lbC000612
	MOVE.W	#1,10(A0)

	lea	lbL001478,A2
	move.l	A2,A3
	move.l	#$20002,D4
	bsr.w	NotePlay

lbC000612	BRA.L	lbC000530

lbL000616	dc.l	0
	dc.l	0
	dc.l	0
lbL000622	dc.l	0
	dc.l	0
	dc.l	0
lbL00062E	dc.l	0
	dc.l	0
	dc.l	0

InitSamp
	LEA	lbL001070,A0
	MOVE.W	#$3FF,D2
lbC000DD4	BSR.S	lbC000DE2
	MOVE.B	D0,(A0)+
	DBRA	D2,lbC000DD4
	RTS

lbL000DDE	dc.l	'HIPP'

lbC000DE2	MOVE.L	lbL000DDE,D0
	MOVE.L	D0,D1
	ASL.L	#3,D1
	SUB.L	D0,D1
	ASL.L	#3,D1
	ADD.L	D0,D1
	ADD.L	D1,D1
	ADD.L	D0,D1
	ASL.L	#4,D1
	SUB.L	D0,D1
	ADD.L	D1,D1
	SUB.L	D0,D1
	ADDI.L	#$E90,D0
	LSL.W	#4,D0
	ADD.L	D0,D1
	BCLR	#$1F,D1
	MOVE.L	D1,D0
	SUBQ.L	#1,D0
	MOVE.L	D0,lbL000DDE
	LSR.L	#8,D0
	RTS

lbL000E26
	dc.l	0		; YM-2149 LSB period base (canal A)
	dc.l	$1000000	; YM-2149 MSB period base (canal A)
	dc.l	$2000000	; YM-2149 LSB period base (canal B)
	dc.l	$3000000	; YM-2149 MSB period base (canal B)
	dc.l	$4000000	; YM-2149 LSB period base (canal C)
	dc.l	$5000000	; YM-2149 MSB period base (canal C)
	dc.l	$6000000	; Noise period
	dc.l	$700FF00	; Mixer control
	dc.l	$8000000	; YM-2149 volume base register (canal A)
	dc.l	$9000000	; YM-2149 volume base register (canal B)
	dc.l	$A000000	; YM-2149 volume base register (canal C)

	Section	Buffy,BSS_C

lbL001070
	ds.b	1024
lbL001478
	ds.b	4
lbL001470
	ds.b	4

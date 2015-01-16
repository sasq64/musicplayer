***************************************************************************
**************************** EagleRipper V1.2 *****************************
************************ for Benn Daglish modules *************************
************************* adapted by Wanted Team **************************
***************************************************************************

	incdir	dh2:include/
	include	misc/eagleplayerripper.i
	include	exec/exec_lib.i
			
	RIPPERHEADER	BennDaglishTags

	dc.b	"Benn Daglish EagleRipper V1.2,",10
	dc.b	"done by Wanted Team (1 Apr 2004)",0
	even
BennDaglishTags
	dc.l	RPT_Formatname,.BennDaglish
	dc.l	RPT_Ripp1,BennDaglishRipp1
	dc.l	RPT_RequestRipper,1
	dc.l	RPT_Version,1<<16!2
	dc.l	RPT_Creator,.Creator
	dc.l	RPT_Playername,.BennDaglish
	dc.l	RPT_Prefix,.Prefix
	dc.l	0

.Creator
	dc.b	"Benn Daglish & Colin Dooley,",10
	dc.b    "adapted by Wanted Team",0
.BennDaglish
	dc.b	'Benn Daglish',0
.Prefix
	dc.b	'BD.',0
	even
*-----------------------------------------------------------------------------*
* Input: a0=Adr (start of memory)
*	 d0=Size (size of memory)
*	 a1=current adr
*	 d1=(a1.l)
* Output:d0=Error oder NULL
*	 d1=Size
*	 a0=Startadr (data)
*-----------------------------------------------------------------------------*
BennDaglishRipp1	
	lsr.l	#8,D1
	lsr.l	#8,D1
	cmpi.w	#$6000,D1
	beq.s	check
	rts

fault
	moveq	#-1,D0
	rts

check
	move.l	A1,A2
	addq.l	#2,A1
	move.l	A1,A0
	move.w	(A1)+,D1
	beq.b	fault
	bmi.b	fault
	btst	#0,D1
	bne.b	fault
	cmp.w	#$6000,(A1)+
	bne.s	fault
	move.w	(A1)+,D1
	beq.b	fault
	bmi.b	fault
	btst	#0,D1
	bne.b	fault
	addq.l	#2,A1
	cmp.w	#$6000,(A1)+
	bne.s	fault
	move.w	(A1),D1
	beq.b	fault
	bmi.b	fault
	btst	#0,D1
	bne.b	fault
	add.w	(A0),A0
	cmp.l	#$3F006100,(A0)
	bne.s	fault
	cmpi.w	#$3D7C,6(A0)
	bne.s	fault
	cmpi.w	#$41FA,12(A0)
	bne.s	fault

	moveq	#$7F,D0
.l6
	cmp.l	#$D040D040,(A0)			; add.w D0,D0 * 2
	beq.b	.ok4
	addq.l	#2,A0
	dbf	D0,.l6
	bra.w	fault
.ok4
	addq.l	#4,A0
	cmp.w	#$D040,(A0)			; add.w D0,D0
	bne.b	.l6
	cmp.w	#$41FA,2(A0)			; lea ..(pc),A0
	bne.b	.l6
	addq.l	#4,A0

	moveq	#$7F,D0
.l9
	cmp.w	#$41FA,(A0)+			; lea ..(pc),A0
	beq.b	.ok6
	dbf	D0,.l9
	bra.w	fault
.ok6
	movem.l	D3/D4/D5/A3/A4/A5,-(A7)
	move.l	A0,A1
	add.w	(A0),A1				; address 1 sample info
	move.l	A1,A3

	lea	12(A2),A0
	add.w	(A0),A0
	moveq	#$7F,D0
.l10
	cmp.l	#$D040D040,(A0)			; add.w D0,D0 * 2
	beq.b	.ok7
	addq.l	#2,A0
	dbf	D0,.l10
	bra.b	.ok7a
.ok7
	addq.l	#4,A0
	cmp.w	#$41FA,(A0)			; lea ..(pc),A0
	bne.b	.l10
	addq.l	#2,A0
	move.w	(A0),D0
	btst	#0,D0
	bne.b	.ok7a
	add.w	(A0),A0				; address 2 sample info
	tst.w	(A0)
	beq.b	.ok8
.ok7a
	sub.l	A0,A0				; or 0 if sample
.ok8
	move.l	A0,A4
	move.l	A3,A0

	bsr.b	com1

	sub.l	A3,D0
	move.l	D0,D1

	move.l	A4,D0
	move.l	D0,A0
	beq.b	.one_smp_info

	bsr.b	com1

	sub.l	A4,D0
.one_smp_info
	move.l	D0,D5

	moveq	#0,D2
	move.l	A3,A0
	bsr.b	Calc

	move.l	A4,D0
	move.l	D0,A0
	beq.b	.ok12
	move.l	D5,D1
	bsr.b	Calc

.ok12
	add.l	D2,A3
	sub.l	A2,A3

	movea.l	A2,A0
	moveq	#0,D0
	move.l	A3,D1
	movem.l	(A7)+,D3/D4/D5/A3/A4/A5
ok11
	rts

Calc
	moveq	#-4,D0
.l11
	addq.l	#4,D0

	cmp.l	D0,D1
	beq.b	ok11

	move.l	A0,A1
	add.l	(A0,D0.W),A1
	moveq	#0,D3
	move.w	8(A1),D3
	move.l	(A1),D4
	cmp.l	4(A1),D4
	beq.b	.NoS
	moveq	#0,D4
	move.w	10(A1),D4
	add.l	D4,D3
.NoS
	lsl.l	#1,D3
	add.l	(A1),D3
	cmp.l	D3,D2
	bge.b	.l11

	move.l	D3,D2
	bra.b	.l11

com1
	move.l	(A0),D2
	move.l	A0,D0
.New
	move.l	D0,A5
	add.l	D2,A5
.Next
	cmp.l	A0,A5
	beq.b	.Ex
	cmp.l	(A0)+,D2
	ble.b	.Next
	move.l	-4(A0),D2
	bra.b	.New
.Ex
	move.l	A0,D0
	rts

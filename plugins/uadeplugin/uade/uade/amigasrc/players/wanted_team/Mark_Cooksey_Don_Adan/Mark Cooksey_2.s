***************************************************************************
**************************** EagleRipper V1.0 *****************************
*********************** for Mark Cooksey modules, *************************
************************* adapted by Wanted Team **************************
***************************************************************************

	incdir	dh2:include/
	include	misc/eagleplayerripper.i
	include	misc/eagleplayer2.01.i
	include	exec/exec_lib.i
			
	RIPPERHEADER	MarkCookseyTags

	dc.b	"Mark Cooksey EagleRipper V1.1",10
	dc.b	"done by Wanted Team (13 Dec 2006)",0
	even

MarkCookseyTags
	dc.l	RPT_Formatname,FormatName
	dc.l	RPT_Ripp1,MarkCookseyRipp1
	dc.l	RPT_RequestRipper,1
	dc.l	RPT_Version,1<<16!1
	dc.l	RPT_Creator,Creator
	dc.l	RPT_Playername,FormatName
	dc.l	RPT_Prefix,OldPrefix
	dc.l	RPT_ExtRipp,ExtRipp
	dc.l	RPT_EagleBase,EagleBase
	dc.l	EP_PlayerVersion,Special		; trick (?)
	dc.l	RPT_Next,MarkCookseyNewTags
	dc.l	0

MarkCookseyNewTags
	dc.l	RPT_Formatname,FormatName
	dc.l	RPT_Ripp1,MarkCookseyRipp2
	dc.l	RPT_RequestRipper,1
	dc.l	RPT_Version,1<<16!0
	dc.l	RPT_Creator,Creator
	dc.l	RPT_Playername,FormatName
	dc.l	RPT_Prefix,Prefix
	dc.l	0

Creator
	dc.b	"Mark Cooksey & Richard Frankish, adapted by Wanted Team",0
FormatName
	dc.b	"Mark Cooksey",0
OldPrefix
	dc.b	'MCR.',0
SamplesPrefix
	dc.b	'MCS.',0
Prefix
	dc.b	'MC.',0
	even
EagleBase
	dc.l	0

*-----------------------------------------------------------------------------*
* Input: a0=Adr (start of memory)
*	 d0=Size (size of memory)
*	 a1=current adr
*	 d1=(a1.l)
* Output:d0=Error oder NULL
*	 d1=Size
*	 a0=Startadr (data)
*-----------------------------------------------------------------------------*

MarkCookseyRipp1
	lsr.l	#8,D1
	lsr.l	#8,D1
	cmp.w	#$601A,D1
	beq.b	check
	rts
check
	lea	StartMemory(PC),A2
	move.l	A0,(A2)+
	move.l	D0,(A2)
	move.l	A1,A0
	addq.l	#2,A1
	move.l	(A1)+,D1
	beq.b	error
	bmi.b	error
	btst	#0,D1
	bne.b	error
	tst.w	(A1)+
	bne.b	error
	moveq	#4,D2
ZeroCheck
	tst.l	(A1)+
	bne.b	error
	dbf	D2,ZeroCheck
	lea	2(A1),A2
	moveq	#3,D2
BranchCheck
	cmp.w	#$6000,(A1)+
	bne.b	error
	move.w	(A1)+,D0
	bmi.b	error
	btst	#0,D0
	bne.b	error
	dbf	D2,BranchCheck
	add.w	(A2),A2
	cmp.l	#$48E780F0,(A2)
	bne.b	error
	moveq	#28,D2
	add.l	D2,D1
	moveq	#0,D0
	rts
error
	moveq	#-1,D0
	rts

ExtRipp
	move.l	StartMemory(PC),A0
	move.l	SizeMemory(PC),D0
	move.l	A0,A1
NextWord
	cmp.w	#$601A,(A1)
	bne.b	FindIt
	addq.l	#2,A1
	move.l	(A1)+,D1
	beq.b	FindIt
	bmi.b	FindIt
	btst	#0,D1
	bne.b	FindIt
	tst.w	(A1)+
	bne.b	FindIt
	moveq	#4,D2
ZeroCheck2
	tst.l	(A1)+
	bne.b	FindIt
	dbf	D2,ZeroCheck2
	tst.w	8(A1)
	bne.b	FindIt
	moveq	#-8,D2
	add.l	8(A1),D2
	beq.b	FindIt
	bmi.b	FindIt
	btst	#0,D2
	bne.b	FindIt
	divu.w	#16,D2
	swap	D2
	tst.w	D2
	bne.b	FindIt
	swap	D2
	lsl.l	#2,D2
	addq.l	#1,D2
ZeroTest
	tst.w	(A1)+
	bne.b	FindIt
	addq.l	#2,A1
	dbf	D2,ZeroTest
	bra.b	OK
FindIt
	addq.l	#2,A0
	move.l	A0,A1
	subq.l	#2,D0
	bgt.b	NextWord
	bra.b	error
OK
	lea	DataAddress(PC),A1
	move.l	A0,(A1)+
	moveq	#28,D2
	add.l	D2,D1
	move.l	D1,(A1)
	move.l	D1,D0
	moveq	#0,D1
	sub.l	A1,A1
	move.l	EagleBase(PC),A5
	jsr	ENPP_SetListData(A5)
	move.l	D0,D1
	moveq	#0,D0
	rts

DataAddress
	dc.l	0
DataLength
	dc.l	0
StartMemory
	dc.l	0
SizeMemory
	dc.l	0
Special
	move.l	EagleBase(PC),A5
	move.l	A1,EPG_ARG3(A5)
	move.l	A1,A0
	jsr	ENPP_CalcStringSize(A5)
	lea	0(A0,D0.W),A1
	lea	SamplesPrefix(PC),A0
	moveq	#32,D1
	jsr	ENPP_StringCopy(A5)
	lea	4(A2),A0
	jsr	ENPP_StringCopy(A5)
	bsr.w	ExtRipp
	bne.b	Exit
	move.l	DataAddress(PC),EPG_ARG1(A5)
	move.l	DataLength(PC),EPG_ARG2(A5)
	moveq	#-1,D0
	move.l	D0,EPG_ARG4(A5)
	moveq	#7,D0
	move.l	D0,EPG_ARG5(A5)
	moveq	#5,D0
	move.l	D0,EPG_ARGN(A5)
	move.l	EPG_SaveMem(A5),A0
	jsr	(A0)
Exit
	rts

MarkCookseyRipp2
	cmp.l	#$D040D040,D1
	beq.b	OK2
	lsr.l	#8,D1
	lsr.l	#8,D1
	cmp.w	#$6000,D1
	beq.w	OK3
	rts
fail
	moveq	#-1,D0
	rts
OK2
	move.l	A1,A0
	cmp.w	#$4EFB,4(A0)
	bne.b	fail
	move.w	#$6000,D1
	cmp.w	8(A0),D1
	bne.b	fail
	cmp.w	12(A0),D1
	bne.b	fail
	cmp.w	16(A0),D1
	bne.b	fail
	cmp.w	20(A0),D1
	bne.b	fail
	cmp.w	#$43FA,40(A0)
	beq.b	Old
	cmp.w	24(A0),D1
	bne.b	fail
	cmp.w	#$43FA,150(A0)
	bne.b	fail
Old
FindIt5
	cmp.l	#$000041FA,(A1)
	beq.b	OK_3
	addq.l	#2,A1
	bra.b	FindIt5
OK_3
	addq.l	#4,A1

	movem.l	D3/D4/A3,-(SP)

	move.l	A1,A3
FindIt6
	cmp.w	#$43FA,(A3)+
	bne.b	FindIt6
	add.w	(A3),A3			; SamplesPtr

	add.w	(A1),A1			; SampleInfoPtr
	move.w	(A1),D1
	lsr.l	#1,D1
	subq.l	#1,D1
	moveq	#0,D3
	moveq	#0,D2
FindMax
	move.w	(A1),D0
	lea	0(A1,D0.W),A2
	addq.l	#2,A1
	move.l	(A2),D0
	bne.b	FirstAdr
	addq.l	#2,A2
	move.l	2(A2),D0
FirstAdr
	cmp.l	D0,D3
	bge.b	NoMax
	move.l	D0,D3
NoMax
	moveq	#0,D4
	move.w	16(A2),D4
	lsl.l	#1,D4
	add.l	D0,D4
	cmp.l	D4,D2
	bge.b	NotThis
	move.l	D4,D2
NotThis
	dbf	D1,FindMax
	move.l	A3,A1
	add.l	D3,A1
	tst.w	-6(A1)
	bne.b	BadSize
	add.l	-6(A1),A1
	sub.l	A0,A1
	move.l	A1,D1
	bra.b	SkipSize
BadSize
	add.l	D2,A3
	sub.l	A0,A3
	move.l	A3,D1
SkipSize
	movem.l	(SP)+,D3/D4/A3
	moveq	#0,D0
	rts

OK3
	move.l	A1,A0
	moveq	#1,D2
BranchCheck2
	cmp.w	#$6000,(A1)+
	bne.b	fail2
	move.w	(A1)+,D1
	bmi.b	fail2
	btst	#0,D1
	bne.b	fail2
	dbf	D2,BranchCheck2
	cmp.w	#$4DFA,(A1)+
	bne.b	fail2
	addq.l	#2,A1
	cmp.w	#$4A56,(A1)
	beq.b	Later
	cmp.w	#$4A16,(A1)
	bne.b	fail2
Later
	addq.l	#6,A1
	cmp.w	#$41F9,(A1)+
	bne.b	fail2
	cmp.l	#$DFF000,(A1)+
	bne.b	fail2
Troi
	cmp.l	#$161449FA,(A1)
	beq.b	TOK
	subq.l	#2,D0
	bmi.b	fail2
	addq.l	#2,A1
	bra.b	Troi
TOK
	addq.l	#4,A1
	add.w	(A1),A1
	move.l	A1,D1
	add.w	(A1),A1
	moveq	#0,D2
	move.w	-8(A1),D2
	add.l	D2,D1
	move.w	-6(A1),D2
	add.l	D2,D2
	add.l	D2,D1
	sub.l	A0,D1
	moveq	#0,D0
	rts
fail2
	moveq	#-1,D0
	rts

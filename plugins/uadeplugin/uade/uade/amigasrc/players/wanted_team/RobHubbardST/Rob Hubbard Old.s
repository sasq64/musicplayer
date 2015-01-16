***************************************************************************
**************************** EagleRipper V1.0 *****************************
********************** for Rob Hubbard Old modules, ***********************
************************* adapted by Wanted Team **************************
***************************************************************************

	incdir	dh2:include/
	include	misc/eagleplayerripper.i
			
	RIPPERHEADER	RobHubbardOldTags

	dc.b	"Rob Hubbard EagleRipper V1.0",10
	dc.b	"done by Wanted Team (19 Dec 1999)",0
	even

RobHubbardOldTags
	dc.l	RPT_Formatname,RobHubbardOld
	dc.l	RPT_Ripp1,RobHubbardOldRipp1
	dc.l	RPT_RequestRipper,1
	dc.l	RPT_Version,1<<16!0
	dc.l	RPT_Creator,Creator
	dc.l	RPT_Playername,RobHubbardOld
	dc.l	RPT_Prefix,Prefix
	dc.l	0

Creator
	dc.b	"Rob Hubbard and Steve Bak, adapted by Wanted Team",0
RobHubbardOld
	dc.b	"Rob Hubbard Old",0
Prefix
	dc.b	"RHO.",0
	even
SongPtr
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

RobHubbardOldRipp1
	cmp.l	#$00407F40,D1
	beq.b	check
	rts

check
	move.l	A1,A0
	cmp.l	#$00C081C0,4(A0)
	bne.b	error
	cmp.l	#$41FAFFEE,56(A0)
	bne.b	error

	lea	500(A0),A1
FindIt1
	tst.l	(A1)
	beq.b	error
	cmp.w	#$7E02,(A1)+
	bne.b	FindIt1
	addq.l	#2,A1
	add.w	(A1),A1				; SongPtr
	lea	SongPtr(PC),A2
	move.l	A1,(A2)
	move.l	A1,A2
	move.l	(A1),D0
	lsr.l	#2,D0
	subq.l	#1,D0
	moveq	#0,D2

NextStep
	move.l	SongPtr(PC),A1
	add.l	(A2)+,A1
NextLong
	move.l	(A1)+,D1
	beq.b	FoundZero
	cmp.l	D1,D2
	bgt.b	MaxStep
	move.l	D1,D2
MaxStep
	bra.b	NextLong
FoundZero
	dbf	D0,NextStep

	move.l	SongPtr(PC),A1
	add.l	D2,A1
FindLast
	cmp.b	#$87,(A1)+
	bne.b	FindLast

	sub.l	A0,A1
	moveq	#0,D0
	move.l	A1,D1
	rts
error
	moveq	#-1,D0
	rts

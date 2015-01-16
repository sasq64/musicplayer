***************************************************************************
**************************** EagleRipper V1.0 *****************************
************************ for Rob Hubbard modules, *************************
************************* adapted by Wanted Team **************************
***************************************************************************

	incdir	dh2:include/
	include	misc/eagleplayerripper.i
			
	RIPPERHEADER	RobHubbardTags

	dc.b	"Rob Hubbard EagleRipper V1.0",10
	dc.b	"done by Wanted Team (30 Jan 1999)",0
	even

RobHubbardTags:
	dc.l	RPT_Formatname,.RobHubbard
	dc.l	RPT_Ripp1,RobHubbardRipp1
	dc.l	RPT_RequestRipper,1
	dc.l	RPT_Version,1<<16!0
	dc.l	RPT_Creator,.Creator
	dc.l	RPT_Playername,.RobHubbard
	dc.l	RPT_Prefix,.Prefix
	dc.l	0

.Creator:
	dc.b	"Rob Hubbard, adapted by Wanted Team",0
.RobHubbard:
	dc.b	"Rob Hubbard",0
.Prefix:
	dc.b	"RH.",0
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

RobHubbardRipp1:	
	lsr.l	#8,D1
	lsr.l	#8,D1
	cmpi.w	#$6000,D1
	beq.b	check
	rts

check
	move.l	A1,A0
	cmp.w	#$6000,4(a0)
	bne.s	error
	cmp.w	#$6000,8(a0)
	bne.s	error
	cmp.w	#$6000,12(a0)
	bne.s	error
	cmp.w	#$6000,16(a0)
	bne.s	error
	cmp.w	#$41fa,20(a0)
	bne.s	error

	lea	64(A0),A1
	moveq	#7,D1
loop2
	cmp.w 	#$2418,(A1)+
	beq.b 	found2
	dbf	D1,loop2
	bra.b	error
found2
	move.b	-3(A1),D1		; D1=samples-1
	lea	54(A0),A1
	moveq	#4,D2
loop3
	cmp.w 	#$41FA,(A1)+
	beq.b 	found3
	dbf	D2,loop3
	bra.b	error
found3
	move.w	(A1),D2
	cmp.w	#$D1FC,2(A1)
	bne.b	hop2
	add.w	#$40,A1
hop2
	add.w	D2,A1
loop4
	add.l	(A1),A1
	addq.l	#6,A1
	dbf	D1,loop4
	addq.l	#2,A1			; end module NOP
	sub.l	A0,A1
	moveq	#0,D0
	move.l	A1,D1
	rts
error
	moveq	#-1,D0
	rts

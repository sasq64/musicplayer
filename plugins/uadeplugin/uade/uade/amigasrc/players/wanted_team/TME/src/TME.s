***************************************************************************
**************************** EagleRipper V1.0 *****************************
***************** for The Musical Enlightenment modules, ******************
************************* adapted by Wanted Team **************************
***************************************************************************

	incdir	dh2:include/
	include	misc/eagleplayerripper.i
			
	RIPPERHEADER	TMETags

	dc.b	"TME EagleRipper V1.0",10
	dc.b	"done by Wanted Team (28 June 2001)",0
	even

TMETags
	dc.l	RPT_Formatname,Formatname
	dc.l	RPT_Ripp1,TMERipp1
	dc.l	RPT_Ripp2,TMERipp2
	dc.l	RPT_RequestRipper,1
	dc.l	RPT_Version,1<<16!0
	dc.l	RPT_Creator,Creator
	dc.l	RPT_Playername,Playername
	dc.l	RPT_GetModuleName,GetModuleName
	dc.l	RPT_Prefix,Prefix
	dc.l	0

Creator
	dc.b	"N.J. Luuring jr, adapted by Wanted Team",0
Formatname
	dc.b	"The Musical Enlightenment",0
Playername
	dc.b	"TME",0
Prefix	
	dc.b	"TME.",0
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

TMERipp2
	cmp.l	#$00040B11,D1
	beq.b	check2
	rts
check2
	cmp.l	#$181E2329,4(A1)
	bne.s	error
	cmp.l	#$2F363C41,8(A1)
	bne.b	error
	lea	-4740(A1),A0
	bra.b	CheckSize
error
	moveq	#-1,D0
	rts

TMERipp1
	cmp.l	#$0000050F,D1
	beq.b	check1
	rts
check1
	cmp.l	#$0000050F,4(A1)
	beq.b	error
	lea	-64(A1),A0
CheckSize
	tst.b	(A0)
	bne.b	error
	move.l	(A0),D2
	beq.b	error
	move.l	A0,A1
	move.l	A0,A2
	lea	$1AAA(A2),A2
	move.w	$1A84(A1),D0
	mulu.w	#12,D0
	add.l	D0,A2
	move.w	$1A86(A1),D0
	mulu.w	#6,D0
	add.l	D0,A2
	moveq	#0,D1
NextInuc
	addq.l	#4,A2
	tst.b	-4(A2)
	bne.b	NextInuc
	addq.l	#4,D1
	cmp.l	#$400,D1
	blt.b	NextInuc
	moveq	#0,D1
	lea	$44(A1),A1
NextSamp	tst.b	$18(A1,D1.L)
	beq.b	NoSample
	add.l	4(A1,D1.L),A2
NoSample	add.l	#$80,D1
	cmp.l	#$1000,D1
	blt.b	NextSamp
	sub.l	A0,A2
	cmp.l	D2,A2
	beq.b	TME_OK
	addq.l	#4,D2
	cmp.l	D2,A2
	bne.b	error
TME_OK
	bsr.b	GetModuleName
	moveq	#0,D0
	move.l	D2,D1
	rts

*-----------------------------------------------------------------------------*
* Input: a0=Start of Modul
*	 d0=Size
* Output:d0=Ptr to name or NULL
*-----------------------------------------------------------------------------*

GetModuleName
	lea	6794(A0),A1
	move.l	A1,D0
	rts

***************************************************************************
**************************** EagleRipper V1.0 *****************************
******************* for Leggless Music Editor modules, ********************
************************* adapted by Wanted Team **************************
***************************************************************************

		incdir	dh2:include/
		include	misc/eagleplayerripper.i
		include	exec/exec_lib.i
			
		RIPPERHEADER	LMETags

	dc.b	"LME EagleRipper V1.0",10
	dc.b	"done by Wanted Team (1 Feb 1999)",0
	even

LMETags		dc.l	RPT_Formatname,Formatname
		dc.l	RPT_Ripp1,LMERipp1
		dc.l	RPT_RequestRipper,1
		dc.l	RPT_Version,1<<16!0
		dc.l	RPT_Creator,Creator
		dc.l	RPT_Playername,Playername
		dc.l	RPT_Prefix,Prefix
		dc.l	0

Creator		dc.b	"Steve 'Leggless' Hasler, adapted by Wanted Team",0
Formatname	dc.b	"Leggless Music Editor",0
Playername	dc.b	"LME",0
Prefix		dc.b	"LME.",0
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

LMERipp1
	cmp.l	#'LME'<<8,D1
	beq.b	check
	rts
check
	move.l	A1,A0
	tst.l	36(A0)
	bne.b	error

	move.l	52(A1),D2
	add.l	#44,D2			; D2 = songsize
	move.l	40(A1),D0		; start sampleinfo
	move.l	56(A1),D1		; end sampleinfo
	sub.l	D0,D1
	divu	#58,D1			; D1 = instruments
	subq.l	#1,D1
	lea	40(A1),A2
	add.l	D0,A2
	add.l	D2,A1

	moveq	#0,D2
	moveq	#3,D0
hop
	cmp.l	(A2),D0
	bge.b	Retry

	move.l	(A2),D0
	move.w	4(A2),D2
	lsl.l	#1,D2
	add.l	D2,A1
Retry
	add.l	#58,A2
	dbf	D1,hop

	sub.l	A0,A1
	moveq	#0,D0
	move.l	A1,D1
	rts
error
	moveq	#-1,D0
	rts

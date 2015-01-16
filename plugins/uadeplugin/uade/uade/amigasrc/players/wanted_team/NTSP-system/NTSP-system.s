***************************************************************************
**************************** EagleRipper V1.0 *****************************
************************ for NTSP-system modules, *************************
************************* adapted by Wanted Team **************************
***************************************************************************

		incdir	dh2:include/
		include	misc/eagleplayerripper.i
		include	exec/exec_lib.i
			
		RIPPERHEADER	Tags

	dc.b	"NTSP-system EagleRipper V1.0",10
	dc.b	"done by Wanted Team (22 July 2008)",0
	even

Tags		dc.l	RPT_Formatname,Formatname
		dc.l	RPT_Ripp1,Ripp1
		dc.l	RPT_RequestRipper,1
		dc.l	RPT_Version,1<<16!0
		dc.l	RPT_Creator,Creator
		dc.l	RPT_Playername,Playername
		dc.l	RPT_Prefix,Prefix
		dc.l	0

Creator		dc.b	"SP/Contraz & Nightraver/Contraz, adapted by Wanted Team",0
Formatname	dc.b	"NTSP-system",0
Playername	dc.b	"NTSP-system",0
Prefix		dc.b	"TWO.",0
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

Ripp1
	cmp.l	#'SPNT',D1
	beq.b	Check1
	rts

Check1
	move.l	4(A1),D0
	beq.b	Fault
	move.l	A1,A0
	move.l	D0,D2
	add.l	D0,D0		; * 2
	add.l	D0,D0		; * 4
	add.l	D2,D0		; * 5
	moveq	#9,D1
	move.l	D3,-(SP)
	move.w	D1,D3
	move.w	D0,D2
	clr.w	D0
	swap	D0
	divu.w	D3,D0
	move.l	D0,D1
	swap	D0
	move.w	D2,D1
	divu.w	D3,D1
	move.l	(SP)+,D3
	move.w	D1,D0
	addq.l	#8,D0
	move.l	D0,D1
	moveq	#0,D0
	rts
Fault
	moveq	#-1,D0
	rts

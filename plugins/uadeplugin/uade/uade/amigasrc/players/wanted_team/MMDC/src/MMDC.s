***************************************************************************
**************************** EagleRipper V1.0 *****************************
**************************** for MMDC modules, ****************************
************************* adapted by Wanted Team **************************
***************************************************************************

	incdir	"dh2:include/"
	include	'misc/eagleplayerripper.i'
			
	RIPPERHEADER	MMDCTags

	dc.b	"MMDC EagleRipper V1.0",10
	dc.b	"done by Wanted Team (19 May 2000)",0
	even
MMDCTags
	dc.l	RPT_Formatname,Formatname
	dc.l	RPT_Ripp1,MMDCRipp1
	dc.l	RPT_RequestRipper,1
	dc.l	RPT_Version,1<<16!0
	dc.l	RPT_Creator,Creator
	dc.l	RPT_Playername,Formatname
	dc.l	RPT_Prefix,Prefix
	dc.l	0

Creator	
	dc.b	"Antony 'Ratt' Crowther, adapted by Wanted Team",0
Formatname
	dc.b	"MED packer",0
Playername
	dc.b	"MMDC",0
Prefix
	dc.b	'MMDC.',0
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

MMDCRipp1
	cmp.l	#'MMDC',D1
	beq.s	check
	rts
check
	move.l	A1,A0
	tst.w	16(A1)
	bne.b	Fault
	move.w	18(A1),D1
	beq.b	Fault
	bmi.b	Fault
	btst	#0,D1
	bne.b	Fault
	lea	(A1,D1.W),A1
	tst.w	(A1)
	bne.b	Fault
	move.l	4(A0),D1
	moveq	#0,D0
Fault
	rts

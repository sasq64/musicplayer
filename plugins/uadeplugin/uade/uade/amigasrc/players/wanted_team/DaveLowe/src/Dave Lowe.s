***************************************************************************
********************* EagleRipper V1.0 (finder only) **********************
************************* for Dave Lowe modules, **************************
************************* adapted by Wanted Team **************************
***************************************************************************

		incdir	dh2:include/
		include	misc/eagleplayerripper.i
			
		RIPPERHEADER	DaveLoweTags

	dc.b	"Dave Lowe EagleRipper V1.0 (finder only)",10
	dc.b	"done by Wanted Team (13 Dec 1999)",0
	even

DaveLoweTags
		dc.l	RPT_Formatname,Formatname
		dc.l	RPT_Ripp1,DaveLoweRipp1
		dc.l	RPT_RequestRipper,1
		dc.l	RPT_Version,1<<16!0
		dc.l	RPT_Creator,Creator
		dc.l	RPT_Playername,Formatname
		dc.l	RPT_Prefix,Prefix
		dc.l	0

Creator		dc.b	"Dave 'Uncle Tom' Lowe, adapted by Wanted Team",0
Formatname	dc.b	"Dave Lowe",0
Prefix		dc.b	"DL.",0
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

DaveLoweRipp1
	cmp.l	#$21590032,D1
	beq.b	check
	rts
check
	move.l	A1,A0
	addq.l	#4,A0
	cmp.l	#$21590036,(A0)+
	bne.b	error
	cmp.l	#$2159003A,(A0)
	bne.b	error
	moveq	#0,D0
	moveq	#0,D1
	rts
error
	moveq	#-1,D0
	rts

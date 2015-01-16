***************************************************************************
**************************** EagleRipper V1.0 *****************************
**************** for Professional Sound Artists modules *******************
************************* adapted by Wanted Team **************************
***************************************************************************

		incdir	dh2:include/
		include	misc/eagleplayerripper.i
			
		RIPPERHEADER	PSATags

	dc.b	"PSA EagleRipper V1.0",10
	dc.b	"done by Wanted Team (3 Feb 1999)",0
	even

PSATags		dc.l	RPT_Formatname,Formatname
		dc.l	RPT_Ripp1,PSARipp1
		dc.l	RPT_RequestRipper,1
		dc.l	RPT_Version,1<<16!0
		dc.l	RPT_Creator,Creator
		dc.l	RPT_Playername,Playername
		dc.l	RPT_Prefix,Prefix
		dc.l	0

Creator		dc.b	"Dave 'Sinbad' Hasler, adapted by Wanted Team",0
Formatname	dc.b	"Professional Sound Artists",0
Playername	dc.b	"PSA",0
Prefix		dc.b	"PSA.",0
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

PSARipp1
	cmp.l	#'PSA'<<8,D1
	beq.b	OK
	rts
OK
	move.l	A1,A0
	moveq	#0,D0
	move.l	36(A0),D1
	rts

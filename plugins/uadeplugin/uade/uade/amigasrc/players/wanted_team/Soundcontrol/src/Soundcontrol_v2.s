***************************************************************************
**************************** EagleRipper V1.1 *****************************
*************** for Soundcontrol 3.0/3.2/4.0/5.0 modules, *****************
************************* adapted by Wanted Team **************************
***************************************************************************

	incdir	"dh2:include/"
	include	'misc/eagleplayerripper.i'
	include	'exec/exec_lib.i'
			
	RIPPERHEADER	SCTags

	dc.b	"Soundcontrol 3.0/3.2/4.0/5.0 EagleRipper V1.1",10
	dc.b	"done by Wanted Team (18 Mar 2000)",0
	even
SCTags
	dc.l	RPT_Formatname,Formatname
	dc.l	RPT_Ripp1,SCRipp1
	dc.l	RPT_RequestRipper,1
	dc.l	RPT_Version,1<<16!1
	dc.l	RPT_Creator,Creator
	dc.l	RPT_Playername,Formatname
	dc.l	RPT_GetModuleName,GetModuleName
	dc.l	RPT_Prefix,Prefix
	dc.l	0

Creator		dc.b	"Holger Gehrmann, adapted by Wanted Team",0
Formatname	dc.b	"Soundcontrol",0
Prefix		dc.b	'SCT.',0
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

SCRipp1
	lsr.l	#8,D1
	lsr.l	#8,D1
	cmp.w	#$0003,D1
	beq.s	check
	cmp.w	#$0002,D1
	beq.s	check2
	rts
check2
	tst.l	-4(A1)
	bne.b	error
check
	lea	-32(A1),A1
	move.l	A1,A0
	tst.w	16(A1)
	bne.b	error
	move.w	18(A1),D1
	bmi.b	error
	btst	#0,D1
	bne.b	error
	add.w	D1,A1
	cmp.w	#$FFFF,62(A1)
	bne.b	error
	cmp.l	#$00000400,64(A1)
	bne.b	error
	bsr.b	GetModuleName
	moveq	#64,D1
	add.w	18(A0),D1
	add.l	20(A0),D1
	add.w	26(A0),D1
	add.w	30(A0),D1
	moveq	#0,D0
	rts
*-----------------------------------------------------------------------------*
* Input: a0=Start of Modul
*	 d0=Size
* Output:d0=Ptr to name or NULL
*-----------------------------------------------------------------------------*

GetModuleName
	move.l	A0,D0
	rts
error
	moveq	#-1,D0
	rts

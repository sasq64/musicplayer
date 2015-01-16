***************************************************************************
**************************** EagleRipper V1.0 *****************************
******************** for Mugician/Mugician II modules *********************
************************* adapted by Wanted Team **************************
***************************************************************************

		incdir	dh2:include/
		include	misc/eagleplayerripper.i
		include	exec/exec_lib.i
			
		RIPPERHEADER	MugicianTags

	dc.b	"Mugician (II) EagleRipper V1.0",10
	dc.b	"done by Wanted Team (14 July 1999)",0
	even

MugicianTags
		dc.l	RPT_Formatname,Formatname
		dc.l	RPT_Ripp1,MugicianRipp1
		dc.l	RPT_RequestRipper,1
		dc.l	RPT_Version,1<<16!0
		dc.l	RPT_Creator,Creator
		dc.l	RPT_Playername,Formatname
		dc.l	RPT_GetModuleName,GetModuleName
		dc.l	RPT_Prefix,Prefix
		dc.l	RPT_Next,Mugician2Tags
		dc.l	0

Creator		dc.b	"Reinier 'Rhino' van Vliet, adapted by Wanted Team",0
Formatname	dc.b	"Mugician",0
Prefix		dc.b	"MUG.",0
ModuleName
		ds.b	13
		even

Mugician2Tags
		dc.l	RPT_Formatname,Formatname2
		dc.l	RPT_Ripp1,Mugician2Ripp1
		dc.l	RPT_RequestRipper,1
		dc.l	RPT_Version,1<<16!0
		dc.l	RPT_Creator,Creator
		dc.l	RPT_Playername,Formatname2
		dc.l	RPT_GetModuleName,GetModuleName
		dc.l	RPT_Prefix,Prefix2
		dc.l	0

Formatname2	dc.b	"Mugician II",0
Prefix2		dc.b	"MUG2.",0
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

MugicianRipp1
	cmp.l	#' MUG',D1
	beq.b	OK
	rts
OK
	lea	text(PC),A2
Check
	move.l	A1,A0
	lea	4(A0),A1
	moveq	#$15,D0
test
	move.b	(A2)+,D2
	cmp.b	(A1)+,D2
	bne.b	Fault
	dbra	D0,test

	move.l	#460,D1
	moveq	#0,D2
	move.w	(A1)+,D2
	lsl.l	#8,D2
	add.l	D2,D1
	moveq	#0,D2
	moveq	#7,D0
NextLength
	add.l	(A1)+,D2
	dbf	D0,NextLength
	lsl.l	#3,D2
	add.l	D2,D1
	move.l	(A1)+,D2
	lsl.l	#4,D2
	add.l	D2,D1
	move.l	(A1)+,D2
	lsl.l	#7,D2
	add.l	D2,D1
	move.l	(A1)+,D2
	lsl.l	#5,D2
	add.l	D2,D1
	move.l	(A1),D2
	add.l	D2,D1
	addq.l	#8,A1

	lea	ModuleName(PC),A2
	move.l	(A1)+,(A2)+
	move.l	(A1)+,(A2)+
	move.l	(A1),(A2)

	bsr.b	GetModuleName

	moveq	#0,D0
	rts
Fault
	moveq	#-1,D0
	rts

Mugician2Ripp1
	cmp.l	#' MUG',D1
	beq.b	OK2
	rts
OK2
	lea	text2(PC),A2
	bsr.b	Check
	rts

*-----------------------------------------------------------------------------*
* Input: a0=Start of Modul
*	 d0=Size
* Output:d0=Ptr to name or NULL
*-----------------------------------------------------------------------------*

GetModuleName
	lea	ModuleName(PC),A2
	move.l	A2,D0
	rts

text	dc.b	'ICIAN/SOFTEYES 1990 '
	dc.w	1
text2	dc.b	'ICIAN2/SOFTEYES 1990'
	dc.w	1

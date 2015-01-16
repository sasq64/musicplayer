***************************************************************************
**************************** EagleRipper V1.0 *****************************
*********************** for PumaTracker  modules, *************************
************************* adapted by Wanted Team **************************
***************************************************************************

	incdir	dh2:include/
	include	misc/eagleplayerripper.i
			
	RIPPERHEADER	PumaTags

	dc.b	"PumaTracker EagleRipper V1.0",10
	dc.b	"done by Wanted Team (30 Dec 2001)",0
	even

PumaTags
	dc.l	RPT_Formatname,Formatname
	dc.l	RPT_Ripp1,PumaRipp1
	dc.l	RPT_RequestRipper,1
	dc.l	RPT_Version,1<<16!0
	dc.l	RPT_Creator,Creator
	dc.l	RPT_Playername,Playername
	dc.l	RPT_GetModuleName,GetModuleName
	dc.l	RPT_Prefix,Prefix
	dc.l	0

Creator		dc.b	"Jean-Charles Meyrignac & Pierre-Eric Loriaux, adapted by Wanted Team",0
Formatname	dc.b	"PumaTracker",0
Playername	dc.b	"PumaTracker",0
Prefix		dc.b	"PUMA.",0
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

PumaRipp1
	cmp.l	#'patt',D1
	beq.b	check
	rts
check
	cmp.l	#$20,4(A1)
	bne.b	error
	cmp.l	#'patt',8(A1)
	bne.b	error
	lea	-3664(A1),A2			; 256*14+80
	cmp.l	A0,A2
	bgt.b	StartOK
	lea	-94(A1),A2
	cmp.l	A2,A0
	bgt.b	error
	move.l	A2,D2
	sub.l	A0,D2
	divu.w	#14,D2
	mulu.w	#14,D2
	sub.w	D2,A2
StartOK
	lea	-80(A1),A1
	cmp.l	A1,A0
	bgt.b	error
	lea	(A0,D0.L),A0
	move.l	A0,D2
	move.w	#255,D1
FindBegin
	cmp.l	A2,D2
	blt.b	error
	tst.b	12(A2)
	bne.b	Wrong
	tst.b	14(A2)
	bne.b	Wrong
	tst.b	16(A2)
	bne.b	Wrong
	move.w	12(A2),D0
	addq.w	#1,D0
	mulu.w	#14,D0
	lea	(A2,D0.L),A0
	cmp.l	A1,A0
	beq.b	Found
Wrong
	lea	14(A2),A2
	dbf	D1,FindBegin
error
	moveq	#-1,D0
	rts
Found
	move.l	A2,A0
	lea	20(A0),A1
	moveq	#9,D1
NextSamp
	tst.l	(A1)+
	bne.b	Samples
	dbf	D1,NextSamp
	move.w	16(A0),D1			; number of synth samples
	lea	80(A0),A1
FindSample
	cmp.l	A1,D2
	ble.b	error
	cmp.w	#'in',(A1)+
	bne.b	FindSample
	cmp.w	#'st',(A1)+
	bne.b	FindSample
	dbf	D1,FindSample
	move.l	A1,D1
	sub.l	A0,D1
	bra.b	SkipSamples
Samples
	moveq	#9,D2				; max. 10 samples
	lea	60(A0),A2
	lea	20(A0),A1
	moveq	#0,D1
FindSize
	moveq	#0,D0
	move.w	(A2)+,D0			; sample length (half)
	btst	#0,D0
	beq.b	even1
	subq.l	#1,D0
even1
	add.l	D0,D0				; * 2
	add.l	(A1)+,D0			; sample offset
	cmp.l	D0,D1
	bge.b	MaxSize
	move.l	D0,D1				; calculated length
MaxSize
	dbf	D2,FindSize
SkipSamples
	bsr.b	GetModuleName
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

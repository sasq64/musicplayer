	*****************************************************
	****  Jochen Hippel 7V replayer for EaglePlayer, ****
	****	     all adaptions by Wanted Team	 ****
	****      DeliTracker compatible (?) version	 ****
	****       					 ****
	**** 23/12/2001 - Codetapper			 ****
	****            - Added slider for mixing rate	 ****
	****            - Equates added for mixing rates ****
	****            - Save functions are *not* done	 ****
	*****************************************************

	incdir	"dh2:include/"
	include 'misc/eagleplayer2.01.i'
	include 'exec/interrupts.i'
	include 'hardware/intbits.i'
	include 'exec/exec_lib.i'
	include	'exec/execbase.i'
	include 'dos/dos_lib.i'
	include	'intuition/intuition.i'
	include	'intuition/intuition_lib.i'
	include	'intuition/screens.i'
	include 'libraries/gadtools.i'
	include 'libraries/gadtools_lib.i'

LOWEST_MIXING_RATE	equ	1
DEFAULT_MIXING_RATE	equ	16
HIGHEST_MIXING_RATE	equ	28

	SECTION	Player_Code,CODE

	PLAYERHEADER Tags

	dc.b	'$VER: Jochen Hippel 7V player module V1.1 (9 July 2009)',0
	even
Tags
	dc.l	DTP_PlayerVersion,2
	dc.l	EP_PlayerVersion,9
	dc.l	DTP_RequestDTVersion,DELIVERSION
	dc.l	DTP_PlayerName,PlayerName
	dc.l	DTP_Creator,Creator
	dc.l	DTP_Check2,Check2
	dc.l	DTP_SubSongRange,SubSongRange
	dc.l	DTP_InitPlayer,InitPlayer
	dc.l	DTP_EndPlayer,EndPlayer
	dc.l	DTP_InitSound,InitSound
	dc.l	DTP_EndSound,EndSound
	dc.l	DTP_StartInt,StartInt
	dc.l	DTP_StopInt,StopInt
	dc.l	DTP_Volume,SetVolume
	dc.l	DTP_Balance,SetBalance
	dc.l	EP_StructInit,StructInit
	dc.l	EP_Get_ModuleInfo,ModuleInfo
	dc.l	EP_GetPositionNr,GetPosition
	dc.l	EP_SampleInit,SampleInit
	dc.l	DTP_Config,Config
	dc.l	DTP_UserConfig,UserConfig
	dc.l	EP_Flags,EPB_Volume!EPB_Balance!EPB_ModuleInfo!EPB_SampleInfo!EPB_Save!EPB_Songend!EPB_Analyzer!EPB_NextSong!EPB_PrevSong!EPB_Packable!EPB_Restart
	dc.l	0

PlayerName
	dc.b	'Jochen Hippel 7V',0
Creator
	dc.b	'(c) 1990-91 Jochen ''Mad Max'' Hippel,',10
	dc.b	'adapted by Wanted Team',0
Prefix
	dc.b	'S7G.',0
AuthorName
	dc.b	'Jochen Hippel',0
CfgPath0
	dc.b	'/'				; necessary for load Config
CfgPath1
	dc.b	'Configs/EP-Hippel_7V.cfg',0
CfgPath2
	dc.b	'EnvArc:EaglePlayer/EP-Hippel_7V.cfg',0
CfgPath3
	dc.b	'Env:EaglePlayer/EP-Hippel_7V.cfg',0
	even

ModulePtr
	dc.l	0
EagleBase
	dc.l	0
SongPtr
	dc.l	0
SubSongsPtr
	dc.l	0
SampleInfoPtr
	dc.l	0
SamplesPtr
	dc.l	0
SpecialTxt
	ds.b	24
MixRate
	dc.w	DEFAULT_MIXING_RATE
CPUType
	dc.w	'WT'
Period4
	dc.w	0
RightVolume
	dc.w	64
LeftVolume
	dc.w	64
StructAdr
	ds.b	UPS_SizeOF

***************************************************************************
**************************** DTP_UserConfig *******************************
***************************************************************************

UserConfig
	tst.l	dtg_GadToolsBase(A5)
	beq.w	ExitCfg
	sub.l	A0,A0
	move.l	dtg_IntuitionBase(A5),A6
	jsr	_LVOLockPubScreen(A6)		; try to lock the default pubscreen
	move.l	D0,PubScrnPtr+4
	beq.w	ExitCfg				; couldn't lock the screen

	move.w	ib_MouseX(A6),D0
	sub.w	#150/2,D0
	bpl.s	SetLeftEdge
	moveq	#0,D0
SetLeftEdge
	move.w	D0,WindowTags+4+2		; Window-X

	move.l	dtg_IntuitionBase(A5),A6
	move.w	ib_MouseY(A6),D0
	sub.w	#63/2,D0
	move.l	PubScrnPtr+4(PC),A0
	move.l	sc_Font(A0),A0
	sub.w	ta_YSize(A0),D0
	bpl.s	SetTopEdge
	moveq	#0,D0
SetTopEdge
	move.w	D0,WindowTags+12+2		; Window-Y

	move.l	PubScrnPtr+4(PC),A0
	suba.l	A1,A1
	move.l	dtg_GadToolsBase(A5),A6
	jsr	_LVOGetVisualInfoA(A6)		; get vi
	move.l	D0,VisualInfo
	beq.w	RemLock

	lea	GadgetList+4(PC),A0		; create a place for context data
	jsr	_LVOCreateContext(A6)
	move.l	D0,D4
	beq.w	FreeVi

	lea	GadArray0(PC),A4		; list with gadget definitions
	sub.w	#gng_SIZEOF,SP
CreateGadLoop
	move.l	(A4)+,D0			; gadget kind
	bmi.b	CreateGadEnd			; end of Gadget List reached !
	move.l	D4,A0				; previous
	move.l	SP,A1				; newgad
	move.l	(A4)+,A2			; tagList
	clr.w	gng_GadgetID(A1)		; gadget ID
	move.l	PubScrnPtr+4(PC),A3
	moveq	#0,D1
	move.b	sc_WBorLeft(A3),D1
	add.w	(A4)+,D1
	move.w	D1,gng_LeftEdge(A1)		; x-pos
	move.l	PubScrnPtr+4(PC),A3
	moveq	#1,D1
	add.b	sc_WBorTop(A3),D1
	move.l	sc_Font(A3),A3
	add.w	ta_YSize(A3),D1
	add.w	(A4)+,D1
	move.w	D1,gng_TopEdge(A1)		; y-pos
	move.w	(A4)+,gng_Width(A1)		; width
	move.w	(A4)+,gng_Height(A1)		; height
	move.l	(A4)+,gng_GadgetText(A1)	; gadget label
	move.l	#Topaz8,gng_TextAttr(A1)	; font for gadget label
	move.l	(A4)+,gng_Flags(A1)		; gadget flags
	move.l	VisualInfo(PC),gng_VisualInfo(A1)	; VisualInfo
	move.l	(A4)+,gng_UserData(A1)		; gadget UserData
	move.l	dtg_GadToolsBase(A5),A6
	jsr	_LVOCreateGadgetA(A6)		; create the gadget
	move.l	D0,(A4)+			; store ^gadget
	move.l	D0,D4
	bne.s	CreateGadLoop			; Creation failed !
CreateGadEnd
	add.w	#gng_SIZEOF,SP
	tst.l	D4
	beq.w	FreeGads			; Gadget creation failed !

	lea	WindowTags(PC),A1		; ^Window
	suba.l	A0,A0
	move.l	dtg_IntuitionBase(A5),A6
	jsr	_LVOOpenWindowTagList(A6)	; Window sollte aufgehen (WA_AutoAdjust)
	move.l	D0,WindowPtr			; Window really open ?
	beq.s	FreeGads

	move.l	WindowPtr(PC),A0		; ^Window
	suba.l	A1,A1				; should always be NULL
	move.l	dtg_GadToolsBase(A5),A6
	jsr	_LVOGT_RefreshWindow(A6)	; refresh all GadTools gadgets

	move.w	#-1,QuitFlag			; kein Ende :-)

	move.w	MixRate(PC),RateTemp

*-----------------------------------------------------------------------*
;
; Hauptschleife

MainLoop
	moveq	#0,D0				; clear Mask
	move.l	WindowPtr(PC),A0		; WindowMask holen
	move.l	wd_UserPort(A0),A0
	move.b	MP_SIGBIT(A0),D1
	bset.l	D1,D0
	move.l	4.W,A6
	jsr	_LVOWait(A6)			; Schlaf gut
ConfigLoop
	move.l	WindowPtr(PC),A0		; WindowMask holen
	move.l	wd_UserPort(A0),A0
	move.l	dtg_GadToolsBase(A5),A6
	jsr	_LVOGT_GetIMsg(A6)
	tst.l	D0				; no further IntuiMsgs pending?
	beq.s	ConfigExit			; nope, exit
	move.l	D0,-(SP)
	move.l	D0,A1				; ^IntuiMsg
	bsr.s	ProcessEvents
	move.l	(SP)+,A1
	move.l	dtg_GadToolsBase(A5),A6
	jsr	_LVOGT_ReplyIMsg(A6)		; reply msg
	bra.s	ConfigLoop			; get next IntuiMsg

ConfigExit
	tst.w	QuitFlag			; end ?
	bne.s	MainLoop			; nope !

*-----------------------------------------------------------------------*
;
; Shutdown

CloseWin
	move.l	WindowPtr(PC),A0
	move.l	dtg_IntuitionBase(A5),A6
	jsr 	_LVOCloseWindow(A6)			; Window zu
FreeGads
	move.l	GadgetList+4(PC),A0
	move.l	dtg_GadToolsBase(A5),A6
	jsr	_LVOFreeGadgets(A6)		; free linked list of gadgets
	clr.l	GadgetList+4
FreeVi
	move.l	VisualInfo(PC),A0
	move.l	dtg_GadToolsBase(A5),A6
	jsr	_LVOFreeVisualInfo(A6)		; free vi
RemLock
	suba.l	A0,A0
	move.l	PubScrnPtr+4(PC),A1
	move.l	dtg_IntuitionBase(A5),A6
	jsr	_LVOUnlockPubScreen(A6)		; unlock the screen
ExitCfg
	moveq	#0,D0				; no error
	rts

*-----------------------------------------------------------------------*
;
; Events auswerten

ProcessEvents
	move.l	im_Class(A1),D0			; get class
	cmpi.l	#IDCMP_CLOSEWINDOW,D0		; Close ?
	beq.w	ExitConfig
	cmpi.l	#BUTTONIDCMP,D0			; Button-Gadget ?
	beq.s	DoGadget
	cmpi.l	#SLIDERIDCMP,D0			; Slider-Gadget ? (Codetapper)
	beq.s	DoGadget
	rts

DoGadget
	move.l	im_IAddress(A1),A0		; auslösendes Intuitionobjekt
	move.l	gg_UserData(A0),D0		; GadgetUserData ermitteln
	beq.s	DoGadgetEnd			; raus, falls nicht benutzt
	move.l	D0,A0				; Pointer kopieren
	jsr	(A0)				; Routine anspringen
DoGadgetEnd
	rts

*-----------------------------------------------------------------------*

SetMixRate					;Codetapper added (when user
	moveq	#0,D0				;moves the slider bar along)
	move.w	im_Code(A1),D0			;Get slider value and for
	cmp.w	#LOWEST_MIXING_RATE,D0		;safety, make sure that 
	blt.b	DefaultMix			;it's between 1 and 28
	cmp.w	#HIGHEST_MIXING_RATE,D0
	ble.b	PutMixRate
DefaultMix
	move.w	#DEFAULT_MIXING_RATE,D0		;Default mixing rate (16)
PutMixRate	
	move.w	D0,RateTemp
	rts

SaveConfig
	move.l	dtg_DOSBase(A5),A6
	moveq	#2,D5
NextPath
	cmp.w	#2,D5
	bne.b	NoPath3
	lea	CfgPath3(PC),A0
	bra.b	PutPath
NoPath3
	cmp.w	#1,D5
	bne.b	NoPath2
	lea	CfgPath2(PC),A0
	bra.b	PutPath
NoPath2
	lea	CfgPath1(PC),A0
PutPath
	move.l	A0,D1
	move.l	#1006,D2			; new file
	jsr	_LVOOpen(A6)
	move.l	D0,D1				; file handle
	beq.b	WrongPath
	move.l	D0,-(SP)
	lea	SaveBuf(PC),A0
	move.l	A0,D2
	moveq	#4,D3				; save size
	jsr	_LVOWrite(A6)
	move.l	(SP)+,D1
	jsr	_LVOClose(A6)
WrongPath
	dbf	D5,NextPath
UseConfig
	move.w	RateTemp(PC),MixRate
	move.w	RateTemp(PC),InitMixingRate+2
ExitConfig
	clr.w	QuitFlag			; quit config
	rts

VisualInfo
	dc.l	0
WindowPtr
	dc.l	0
SaveBuf
	dc.w	'WT'
RateTemp
	dc.w	0
QuitFlag
	dc.w	0

WindowTags
	dc.l	WA_Left,0
	dc.l	WA_Top,0
	dc.l	WA_InnerWidth,200		;Codetapper (made these
	dc.l	WA_InnerHeight,70		;a bit bigger)
GadgetList
	dc.l	WA_Gadgets,0
	dc.l	WA_Title,WindowName
	dc.l	WA_IDCMP,IDCMP_CLOSEWINDOW!BUTTONIDCMP!SLIDERIDCMP	;Codetapper
	dc.l	WA_Flags,WFLG_ACTIVATE!WFLG_DRAGBAR!WFLG_DEPTHGADGET!WFLG_CLOSEGADGET!WFLG_RMBTRAP
PubScrnPtr
	dc.l	WA_PubScreen,0
	dc.l	WA_AutoAdjust,1
	dc.l	TAG_DONE

GadArray0					;Save
	dc.l	BUTTON_KIND,0
	dc.w	134,45,58,14			;Codetapper (moved right 50 pixels)
	dc.l	GadText0,PLACETEXT_IN
	dc.l	SaveConfig
	dc.l	0

GadArray1					;Use
	dc.l	BUTTON_KIND,0
	dc.w	8,45,58,14
	dc.l	GadText1,PLACETEXT_IN
	dc.l	UseConfig
	dc.l	0

MixingRateArray
	dc.l	SLIDER_KIND,MixingRateTagList	;Add a slider gadget (Codetapper)
	dc.w	10,17,181,11	;11 //REMOVE
	dc.l	MixingRateText,PLACETEXT_ABOVE
	dc.l	SetMixRate
	dc.l	0

	dc.l -1				; end of gadgets definitions

MixingRateTagList					;Codetapper
	dc.l	GTSL_Min,LOWEST_MIXING_RATE		;Lowest value (1 kHz)
	dc.l	GTSL_Max,HIGHEST_MIXING_RATE		;Highest value (28 kHz)
	dc.l	GTSL_Level				;Current level of slider (defaults to 0). (V36)
InitMixingRate
	dc.l	DEFAULT_MIXING_RATE			;Initial value (16 kHz)
	dc.l	GTSL_MaxLevelLen,7			;Maximum length in characters of level string
	dc.l	GTSL_LevelFormat,MixingRateFormat	;C-Style formatting string for slider
	dc.l	GTSL_LevelPlace,PLACETEXT_BELOW		;indicating where the level indicator is to go relative to slider (default to PLACETEXT_LEFT).
	dc.l	PGA_Freedom,LORIENT_HORIZ		;Set to LORIENT_VERT or LORIENT_HORIZ to have a vertical or horizontal slider (defaults to LORIENT_HORIZ). (V36)
	dc.l	GA_RelVerify,1				;If you want to hear each slider IDCMP_GADGETUP event (defaults to FALSE). (V36)
	dc.l	GA_Immediate,1				;If you want to hear each slider IDCMP_GADGETDOWN event (defaults to FALSE). (V36)
	dc.l	TAG_DONE

Topaz8
	dc.l	TOPAZname
	dc.w	TOPAZ_EIGHTY
	dc.b	$00,$01

TOPAZname
	dc.b	'topaz.font',0

WindowName
	dc.b	'Jochen Hippel 7V',0

GadText0
	dc.b	'Save',0
GadText1
	dc.b	'Use',0

MixingRateFormat			;Format for slider update text
	dc.b	'%ld kHz ',0

MixingRateText				;Text for mixing rate slider
	dc.b	'Set Mixing Rate:',0
	even

***************************************************************************
******************************** DTP_Config *******************************
***************************************************************************

Config
	move.l	dtg_DOSBase(A5),A6
	moveq	#-1,D5
	lea	CfgPath3(PC),A0
	bra.b	SkipPath
SecondTry
	moveq	#0,D5
	lea	CfgPath0(PC),A0
SkipPath
	move.l	A0,D1
	move.l	#1005,D2			; old file
	jsr	_LVOOpen(A6)
	move.l	D0,D1				; file handle
	beq.b	Default
	move.l	D0,-(SP)
	lea	LoadBuf(PC),A4
	clr.l	(A4)
	move.l	A4,D2
	moveq	#4,D3				; load size
	jsr	_LVORead(A6)
	move.l	(SP)+,D1
	jsr	_LVOClose(A6)
	cmp.w	#'WT',(A4)+
	bne.b	Default
	move.w	(A4),D1
	beq.b	Default
	cmp.w	#28,D1
	bhi.b	Default
	bra.b	PutRate
Default
	tst.l	D5
	bne.b	SecondTry
	moveq	#16,D1				; default mixing rate
PutRate
	lea	MixRate(PC),A0
	move.w	D1,(A0)
	lea	InitMixingRate+2(PC),A0
	move.w	D1,(A0)
	moveq	#0,D0
	rts

LoadBuf
	dc.l	0

***************************************************************************
******************************* EP_SampleInit *****************************
***************************************************************************

SampleInit
	moveq	#EPR_NotEnoughMem,D7
	lea	EPG_SampleInfoStructure(A5),A3
	move.l	SampleInfoPtr(PC),D0
	beq.b	return
	move.l	D0,A2

	move.l	InfoBuffer+Samples(PC),D5
	subq.l	#1,D5
	move.l	SamplesPtr(PC),A1
Normal
	jsr	ENPP_AllocSampleStruct(A5)
	move.l	D0,(A3)
	beq.b	return
	move.l	D0,A3

	move.l	18(A2),D0
	lea	(A1,D0.L),A0
	moveq	#0,D1
	move.w	22(A2),D1
	add.l	D1,D1
	move.l	A2,EPS_SampleName(A3)		; sample name
	move.l	A0,EPS_Adr(A3)			; sample address
	move.l	D1,EPS_Length(A3)		; sample length
	move.l	#64,EPS_Volume(A3)
	move.w	#USITY_RAW,EPS_Type(A3)
	move.w	#18,EPS_MaxNameLen(A3)
	move.w	#USIB_Playable!USIB_Saveable!USIB_8BIT,EPS_Flags(A3)

	lea	30(A2),A2
	dbf	D5,Normal

NoNormal
	moveq	#0,D7
return
	move.l	D7,D0
	rts

***************************************************************************
***************************** EP_GetPositionNr ****************************
***************************************************************************

GetPosition
	moveq	#0,D0
	move.w	lbL000AD2+$3A(PC),D0
	divu.w	#28,D0
	rts

***************************************************************************
***************************** EP_Get_ModuleInfo ***************************
***************************************************************************

ModuleInfo	
	lea	InfoBuffer(PC),A0
	rts

SubSongs	=	4
LoadSize	=	12
CalcSize	=	20
Pattern		=	28
Length		=	36
SamplesSize	=	44
SongSize	=	52
Samples		=	60
PlayFrequency	=	68
Special		=	76

InfoBuffer
	dc.l	MI_SubSongs,0		;4
	dc.l	MI_LoadSize,0		;12
	dc.l	MI_Calcsize,0		;20
	dc.l	MI_Pattern,0		;28
	dc.l	MI_Length,0		;36
	dc.l	MI_SamplesSize,0	;44
	dc.l	MI_Songsize,0		;52
	dc.l	MI_Samples,0		;60
	dc.l	MI_PlayFrequency,0	;68
	dc.l	MI_SpecialInfo,0	;76
	dc.l	MI_AuthorName,AuthorName
	dc.l	MI_MaxVoices,7
	dc.l	MI_Voices,7
	dc.l	MI_Prefix,Prefix
	dc.l	0

***************************************************************************
******************************* EP_StructInit *****************************
***************************************************************************

StructInit
	lea	StructAdr(PC),A0
	rts

***************************************************************************
************************* DTP_Volume, DTP_Balance *************************
***************************************************************************
; Copy Volume and Balance Data to internal buffer

SetVolume
SetBalance
	move.w	dtg_SndLBal(A5),D0
	mulu.w	dtg_SndVol(A5),D0
	lsr.w	#6,D0

	move.w	D0,LeftVolume

	move.w	dtg_SndRBal(A5),D0
	mulu.w	dtg_SndVol(A5),D0
	lsr.w	#6,D0

	move.w	D0,RightVolume

	moveq	#0,D0
	rts

ChangeVolume
	move.l	D1,-(SP)
	move.w	D0,D1
	and.w	#$7F,D1
	mulu.w	LeftVolume(PC),D1
	lsr.w	#6,D1
	move.w	D1,D0
	move.l	(SP)+,D1
	rts

*-------------------------------- Set All -------------------------------*

SetAll
	move.l	A1,-(A7)
	lea	StructAdr+UPS_Voice1Adr(PC),A1
	cmp.l	#$DFF0A0,A3
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice2Adr(PC),A1
	cmp.l	#$DFF0B0,A3
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice3Adr(PC),A1
	cmp.l	#$DFF0C0,A3
	bne.s	Exit1
.SetVoice
	move.l	A2,(A1)
	move.w	$16(A4),UPS_Voice1Len(A1)
	move.w	$2E(A0),UPS_Voice1Per(A1)
Exit1
	move.l	(A7)+,A1
	rts

***************************************************************************
******************************* DTP_Check2 ********************************
***************************************************************************

Check2
	movea.l	dtg_ChkData(A5),A0
	moveq	#-1,D0

	cmp.w	#$6000,(A0)
	bne.b	Song
	addq.l	#2,A0
	move.w	(A0),D1
	beq.b	Fault
	bmi.b	Fault
	btst	#0,D1
	bne.b	Fault
	lea	(A0,D1.W),A0
	moveq	#10,D1
Find_1
	cmp.l	#$308141FA,(A0)
	beq.b	OK_1
	addq.l	#2,A0
	dbf	D1,Find_1
	rts
OK_1
	addq.l	#4,A0
	move.w	(A0),D1
	beq.b	Fault
	bmi.b	Fault
	btst	#0,D1
	bne.b	Fault
	lea	(A0,D1.W),A0
Song
	cmp.l	#'TFMX',(A0)+
	bne.b	Fault
	tst.b	(A0)
	bne.b	Fault
	moveq	#2,D1
	add.w	(A0)+,D1
	add.w	(A0)+,D1
	lsl.l	#6,D1
	moveq	#1,D2
	add.w	(A0)+,D2
	moveq	#1,D3
	add.w	(A0)+,D3
	mulu.w	#28,D3
	mulu.w	(A0)+,D2
	add.l	D2,D1
	add.l	D3,D1
	addq.l	#2,A0
	moveq	#1,D2
	add.w	(A0)+,D2
	lsl.l	#3,D2
	add.l	D2,D1
	moveq	#32,D2
	add.l	D2,D1
	add.l	D1,A0
	tst.l	(A0)+
	bne.b	Fault
	move.w	(A0),D2
	beq.b	Fault
	add.l	D2,D2
	cmp.l	26(A0),D2
	bne.b	Fault
	moveq	#0,D0
Fault
	rts

***************************************************************************
***************************** DTP_SubSongRange ****************************
***************************************************************************

SubSongRange
	moveq	#1,D0
	move.l	InfoBuffer+SubSongs(PC),D1
	rts

***************************************************************************
***************************** DTP_InitPlayer ******************************
***************************************************************************

InitPlayer
	moveq	#0,D0
	movea.l	dtg_GetListData(A5),A0
	jsr	(A0)

	lea	ModulePtr(PC),A6
	move.l	A0,(A6)+			; module buffer
	move.l	A5,(A6)+			; EagleBase

	lea	InfoBuffer(PC),A4
	move.l	D0,LoadSize(A4)

	move.l	A0,A1

	cmp.l	#'TFMX',(A0)
	beq.b	SkipFind
Find1
	cmp.w	#$3081,(A1)+
	bne.b	Find1
	addq.l	#2,A1
	add.w	(A1),A1
SkipFind
	move.l	A1,(A6)+			; song ptr

	move.w	16(A1),SubSongs+2(A4)
	moveq	#2,D0
	add.w	4(A1),D0
	add.w	6(A1),D0
	lsl.l	#6,D0
	moveq	#32,D1
	add.l	D1,D0
	moveq	#1,D1
	add.w	8(A1),D1
	move.l	D1,Pattern(A4)
	mulu.w	12(A1),D1
	add.l	D1,D0
	lea	4(A1,D0.L),A2
	clr.l	Special(A4)
	tst.b	(A2)
	beq.b	NoSpec
	lea	SpecialTxt(PC),A3
	move.l	A3,Special(A4)
	moveq	#5,D1
CopyInfo
	move.l	(A2)+,(A3)+
	dbf	D1,CopyInfo
NoSpec
	moveq	#1,D1
	add.w	10(A1),D1
	mulu.w	#28,D1
	add.l	D1,D0
	lea	(A1,D0.L),A2
	move.l	A2,(A6)+			; subsongs ptr
	moveq	#1,D1
	add.w	16(A1),D1
	lsl.l	#3,D1
	add.l	D1,D0
	lea	(A1,D0.L),A2
	move.l	A2,(A6)+			; sampleinfo ptr

	move.w	18(A1),D1
	move.l	D1,Samples(A4)
	mulu.w	#30,D1
	add.l	D1,D0

	lea	(A1,D0.L),A2
	move.l	A2,(A6)				; samples ptr

	moveq	#0,D0
	move.w	-8(A2),D0
	add.l	D0,D0
	add.l	-12(A2),D0
	move.l	D0,SamplesSize(A4)
	sub.l	A0,A2
	move.l	A2,SongSize(A4)
	add.l	A2,D0
	move.l	D0,CalcSize(A4)

	lea	lbW000DE8(PC),A1
	clr.w	(A1)

	move.l	4.W,A1				; exec base
	tst.b	$129(A1)			; CPU check
	beq.b	MC68000
	lea	CPUType(PC),A0
	clr.w	(A0)
MC68000
	movea.l	dtg_AudioAlloc(A5),A0
	jmp	(A0)

***************************************************************************
***************************** DTP_EndPlayer *******************************
***************************************************************************

EndPlayer
	movea.l	dtg_AudioFree(A5),A0
	jmp	(A0)

***************************************************************************
***************************** DTP_InitSound *******************************
***************************************************************************

InitSound
	lea	StructAdr(PC),A0
	lea	UPS_SizeOF(A0),A1
ClearUPS
	clr.w	(A0)+
	cmp.l	A0,A1
	bne.b	ClearUPS

	move.l	#$00040004,D0
	lea	lbW000EC4(PC),A0
	move.l	D0,(A0)+
	move.l	D0,(A0)

	move.l	SubSongsPtr(PC),A0
	move.w	dtg_SndNum(A5),D0
	move.w	D0,D1
	subq.w	#1,D1
	lsl.w	#3,D1
	move.w	2(A0,D1.W),D2
	sub.w	0(A0,D1.W),D2
	addq.w	#1,D2
	lea	InfoBuffer(PC),A0
	move.w	D2,Length+2(A0)

	move.w	MixRate(PC),D1			; D1 = mixing rate
	move.w	D1,PlayFrequency+2(A0)
	bra.w	Init

***************************************************************************
***************************** DTP_EndSound ********************************
***************************************************************************

EndSound
	lea	$DFF000,A0
	move.w	#15,$96(A0)
	moveq	#0,D0
	move.w	D0,$A8(A0)
	move.w	D0,$B8(A0)
	move.w	D0,$C8(A0)
	move.w	D0,$D8(A0)
	rts

***************************************************************************
***************************** DTP_StartInt ********************************
***************************************************************************

StartInt
	movem.l	D0/A6,-(A7)
	lea	InterruptStruct(PC),A1
	moveq	#INTB_AUD3,D0
	move.l	4.W,A6			; baza biblioteki exec do A6
	jsr	_LVOSetIntVector(A6)
	move.l	D0,Audio3
	movem.l	(A7)+,D0/A6
	move.w	#$8400,$DFF09A
	move.w	#$8008,$DFF096
	rts

InterruptStruct
	dc.l	0
	dc.l	0
	dc.b	NT_INTERRUPT
	dc.b	5			; priority
	dc.l	Name			; ID string
	dc.l	0
	dc.l	Interrupt
Name
	dc.b	'Jochen Hippel 7V Aud3 Interrupt',0,0
	even

Audio3
	dc.l	0

***************************************************************************
***************************** DTP_StopInt *********************************
***************************************************************************

StopInt
	lea	$DFF000,A0
	move.w	#8,$96(A0)
	move.w	#$400,$9A(A0)
	move.w	#$400,$9C(A0)
	moveq	#INTB_AUD3,D0
	move.l	Audio3(PC),A1
	move.l	A6,-(A7)
	move.l	4.W,A6
	jsr	_LVOSetIntVector(a6)
	move.l	(A7)+,A6
	rts

***************************************************************************
***************************** DTP_Interrupt *******************************
***************************************************************************

Interrupt
	movem.l	D1-A6,-(SP)

	lea	StructAdr(PC),A0
	st	UPS_Enabled(A0)
	clr.w	UPS_Voice1Per(A0)
	clr.w	UPS_Voice2Per(A0)
	clr.w	UPS_Voice3Per(A0)
	clr.w	UPS_Voice4Per(A0)
	move.w	#UPSB_Adr!UPSB_Len!UPSB_Per!UPSB_Vol,UPS_Flags(A0)

	bsr.w	Play
	move.w	RightVolume(PC),$DFF0D8

	lea	StructAdr(PC),A0
	move.w	RightVolume(PC),UPS_Voice4Vol(A0)
	move.w	Period4(PC),UPS_Voice4Per(A0)
	clr.w	UPS_Enabled(A0)

	movem.l	(SP)+,D1-A6
	moveq	#0,D0
	rts

SongEnd
	movem.l	A1/A5,-(A7)
	move.l	EagleBase(PC),A5
	move.l	dtg_SongEnd(A5),A1
	jsr	(A1)
	movem.l	(A7)+,A1/A5
	rts

DMAWait
	movem.l	D0/D1,-(SP)
	moveq	#8,D0
.dma1	move.b	$DFF006,D1
.dma2	cmp.b	$DFF006,D1
	beq.b	.dma2
	dbeq	D0,.dma1
	movem.l	(SP)+,D0/D1
	rts

***************************************************************************
************************* Jochen Hippel 7V player *************************
***************************************************************************

; Player from game "Amberstar" (outro music)

;	BRA.L	lbC00002C

;	dc.b	' **** Player by Jochen Hippel 1990 **** '

lbC000522
	dc.w	0

Init
lbC00002C	MOVEM.L	D0-D7/A0-A6,-(SP)
	TST.W	D1
	BMI.S	lbC00003C
	BEQ.S	lbC00003C
	LEA	lbC000522(PC),A0
	MOVE.W	D1,(A0)
lbC00003C
;	LEA	TFMX.MSG(PC),A0

	move.l	SongPtr(PC),A0

	MOVE.W	D0,-(SP)
	BSR.L	lbC000088
	MOVE.W	(SP)+,D0
	BEQ.S	lbC000072
	MOVEA.L	lbL000DE4(PC),A1
	ANDI.W	#$FF,D0
	SUBQ.W	#1,D0
	LSL.W	#3,D0
	ADDA.W	D0,A1
	MOVE.W	(A1)+,D0
	MOVE.W	(A1)+,D1
	LEA	lbW000AC4(PC),A6
	MOVE.W	2(A1),(A6)+
	MOVE.W	2(A1),(A6)+
	BSR.L	lbC0003F8
	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTS

lbC000072	MOVE.W	#$780,$DFF09A
	MOVE.W	#15,$DFF096
	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTS

lbC000088	LEA	lbW000DE8(PC),A1
	TST.B	(A1)
	BNE.L	lbC000116
	ST	(A1)
	BSET	#1,$BFE001
	LEA	$20(A0),A1
	LEA	lbL000DC0(PC),A2
	MOVE.L	A1,(A2)
	MOVE.W	4(A0),D0
	ADDQ.W	#1,D0
	ASL.W	#6,D0
	ADDA.W	D0,A1
	LEA	lbL000DC8(PC),A2
	MOVE.L	A1,(A2)
	MOVE.W	6(A0),D0
	ADDQ.W	#1,D0
	ASL.W	#6,D0
	ADDA.W	D0,A1
	LEA	lbL000DBC(PC),A2
	MOVE.L	A1,(A2)
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVE.W	8(A0),D0
	MOVE.W	12(A0),D1
	LEA	lbW000DBA(PC),A2
	MOVE.W	D1,(A2)
	ADDQ.W	#1,D0
	MULU.W	D1,D0
	ADDA.W	D0,A1
	LEA	lbL000DD0(PC),A2
	MOVE.L	A1,(A2)
	MOVE.W	10(A0),D0
	ADDQ.W	#1,D0
	MULU.W	#$1C,D0
	ADDA.W	D0,A1
	LEA	lbL000DE4(PC),A2
	MOVE.L	A1,(A2)
	MOVE.W	$10(A0),D0
	ADDQ.W	#1,D0
	LSL.W	#3,D0
	ADDA.W	D0,A1
	LEA	lbL000DD4(PC),A2
	MOVE.L	A1,(A2)
	MOVE.W	$12(A0),D0
	MULU.W	#$1E,D0
	ADDA.W	D0,A1
	LEA	lbL000DDC(PC),A2
	MOVE.L	A1,(A2)
lbC000116	RTS

lbC000118	MOVE.W	lbW000AC8(PC),D0
	BEQ.S	lbC000142
	MOVEQ	#0,D7
	MOVE.W	#15,$DFF096
	MOVE.W	D7,$DFF0A8
	MOVE.W	D7,$DFF0B8
	MOVE.W	D7,$DFF0C8
	MOVE.W	D7,$DFF0D8

	bsr.w	SongEnd

	RTS

lbC000142	LEA	lbW000ACC(PC),A5
	MOVEQ	#0,D5
	MOVEQ	#6,D6
	LEA	lbW000AC4(PC),A0
	SUBQ.W	#1,(A0)+
	BNE.S	lbC000174
	MOVE.W	(A0),-(A0)
	LEA	lbL000BD4(PC),A0
	BSR.L	lbC000290
	LEA	lbL000C2A(PC),A0
	BSR.L	lbC000290
	LEA	lbL000C80(PC),A0
	BSR.L	lbC000290
	LEA	lbL000CD6(PC),A0
	BSR.L	lbC000290
lbC000174	MOVE.W	D5,(A5)
	MOVEQ	#0,D7
	LEA	lbL000AD2(PC),A0
	BSR.L	lbC000534

	bsr.w	ChangeVolume
	move.w	D0,StructAdr+UPS_Voice1Vol

	MOVE.L	D0,$DFF0A6
	LEA	lbL000B28(PC),A0
	BSR.L	lbC000534

	bsr.w	ChangeVolume
	move.w	D0,StructAdr+UPS_Voice2Vol

	MOVE.L	D0,$DFF0B6
	LEA	lbL000B7E(PC),A0
	BSR.L	lbC000534

	bsr.w	ChangeVolume
	move.w	D0,StructAdr+UPS_Voice3Vol

	MOVE.L	D0,$DFF0C6
	LEA	lbL000BD4(PC),A0
	BSR.L	lbC000534
	LEA	lbL0075DC(PC),A0
	MOVE.L	D0,(A0)
	LEA	lbL000C2A(PC),A0
	BSR.L	lbC000534
	LEA	lbL0075EC(PC),A0
	MOVE.L	D0,(A0)
	LEA	lbL000C80(PC),A0
	BSR.L	lbC000534
	LEA	lbL0075FC(PC),A0
	MOVE.L	D0,(A0)
	LEA	lbL000CD6(PC),A0
	BSR.L	lbC000534
	LEA	lbL00760C(PC),A0
	MOVE.L	D0,(A0)
	BSR.L	lbC00749E
	LEA	lbB000ACE(PC),A0
	MOVE.W	2(A0),D0
	OR.W	D0,(A0)
	BSR.L	lbC00749E
	LEA	lbL0075D6(PC),A6
	MOVE.L	lbL000BE0(PC),(A6)+
	MOVE.W	lbL000C08(PC),(A6)
	LEA	lbL0075E6(PC),A6
	MOVE.L	lbL000C36(PC),(A6)+
	MOVE.W	lbL000C5E(PC),(A6)
	LEA	lbL0075F6(PC),A6
	MOVE.L	lbL000C8C(PC),(A6)+
	MOVE.W	lbL000CB4(PC),(A6)
	LEA	lbL007606(PC),A6
	MOVE.L	lbL000CE2(PC),(A6)+
	MOVE.W	lbL000D0A(PC),(A6)
	MOVE.W	lbW000ACC(PC),D7
	ORI.W	#$8000,D7
	MOVE.W	lbL000B06(PC),D0
	MOVEA.L	lbL000ADE(PC),A0
	MOVE.W	lbL000B5C(PC),D1
	MOVEA.L	lbL000B34(PC),A1
	MOVE.W	lbL000BB2(PC),D2
	MOVEA.L	lbL000B8A(PC),A2

	tst.w	CPUType
	bne.b	NoWait1
	bsr.w	DMAWait
NoWait1

	LEA	$DFF000,A6
	MOVE.W	D7,$96(A6)

	tst.w	CPUType
	bne.b	NoWait
	bsr.w	DMAWait
NoWait

	BSR.L	lbC00749E
	MOVE.L	A0,$A0(A6)
	MOVE.W	D0,$A4(A6)
	MOVE.L	A1,$B0(A6)
	MOVE.W	D1,$B4(A6)
	MOVE.L	A2,$C0(A6)
	MOVE.W	D2,$C4(A6)
	LEA	lbW000AC4(PC),A0
	LEA	2(A0),A1
	CMPM.W	(A0)+,(A1)+
	BNE.S	lbC00028E
	LEA	lbW000ACC(PC),A5
	MOVEQ	#0,D5
	MOVEQ	#6,D6
	LEA	lbL000AD2(PC),A0
	BSR.L	lbC000290
	LEA	lbL000B28(PC),A0
	BSR.L	lbC000290
	LEA	lbL000B7E(PC),A0
	BRA.L	lbC000290

lbC00028E	RTS

lbC000290	MOVE.W	lbW000DBA(PC),D7
	MOVEA.L	$18(A0),A1
	ADDA.W	$3C(A0),A1
	MOVE.B	(A1),D0
	ANDI.W	#$7F,D0
	CMP.W	#1,D0
	BEQ.S	lbC0002B0
	CMP.W	$3C(A0),D7
	BNE.L	lbC00035A
lbC0002B0	MOVEA.L	8(A0),A3
	MOVEA.L	4(A0),A2
	ADDA.W	$3A(A0),A2
	CMPA.L	A3,A2
	BNE.S	lbC0002C8

	bsr.w	SongEnd

	MOVE.W	D5,$3A(A0)
	MOVEA.L	4(A0),A2
lbC0002C8	MOVEQ	#0,D1
	MOVEQ	#0,D2
	MOVE.B	(A2),D1
	MOVE.B	1(A2),$4E(A0)
	MOVE.B	2(A2),$43(A0)
	MOVE.B	3(A2),D2
	MOVE.B	D2,D3
	LSR.W	#4,D3
	ANDI.W	#15,D3
	ANDI.W	#15,D2
	CMP.B	#13,D3
	BNE.S	lbC000304
	MOVE.B	7(A2),D2
	MOVEM.L	D0-D2/D6/A0/A1,-(SP)
	BSR.L	lbC007D22
	MOVEM.L	(SP)+,D0-D2/D6/A0/A1
	BRA.L	lbC000342

lbC000304	CMP.B	#15,D3
	BNE.S	lbC000324
	MOVEQ	#$64,D3
	TST.W	D2
	BEQ.S	lbC00031E
	MOVEQ	#15,D3
	SUB.W	D2,D3
	ADDQ.W	#1,D3
	ADD.W	D3,D3
	MOVE.W	D3,D2
	ADD.W	D3,D3
	ADD.W	D2,D3
lbC00031E	MOVE.B	D3,$51(A0)
	BRA.S	lbC000342

lbC000324	CMP.B	#8,D3
	BNE.S	lbC000332
	LEA	lbW000AC8(PC),A2
	ST	(A2)
	BRA.S	lbC000342

lbC000332	CMP.B	#14,D3
	BNE.S	lbC000342
	ANDI.W	#15,D2
	LEA	lbW000AC6(PC),A2
	MOVE.W	D2,(A2)
lbC000342	MOVE.W	D5,$3C(A0)
	MULU.W	D7,D1
	MOVEA.L	lbL000DBC(PC),A3
	ADDA.L	D1,A3
	MOVE.L	A3,$18(A0)
	ADDI.W	#$1C,$3A(A0)
	MOVEA.L	A3,A1
lbC00035A	MOVE.B	(A1)+,D0
	MOVE.B	D0,D1
	ANDI.W	#$7F,D1
	TST.W	D1
	BEQ.L	lbC0003F2
	MOVE.W	D5,$1C(A0)
	MOVE.B	D1,$41(A0)
	MOVEA.L	A1,A3
	TST.W	$3C(A0)
	BNE.S	lbC00037A
	ADDA.W	D7,A3
lbC00037A	MOVE.B	-2(A3),$4B(A0)
	MOVE.B	(A1),D1
	MOVE.B	D1,$42(A0)
	TST.B	D0
	BMI.S	lbC0003F2
	ANDI.W	#$1F,D1
	ADD.B	$43(A0),D1
	MOVEA.L	lbL000DC8(PC),A2
	LSL.W	D6,D1
	ADDA.W	D1,A2
	MOVE.W	D5,$38(A0)
	MOVE.B	(A2),$44(A0)
	MOVE.B	(A2)+,$45(A0)
	MOVEQ	#0,D1
	MOVE.B	(A2)+,D1
	MOVE.B	(A2)+,$48(A0)
	MOVEQ	#0,D0
	MOVE.B	#$40,$50(A0)
	MOVE.B	(A2)+,D0
	MOVE.B	D0,$49(A0)
	MOVE.B	D0,$40(A0)
	MOVE.B	(A2)+,$4A(A0)
	MOVE.L	A2,$10(A0)
	MOVE.B	D5,$46(A0)
	CMP.B	#$80,D1
	BEQ.S	lbC0003F2
	MOVEA.L	lbL000DC0(PC),A2
	BTST	#6,$42(A0)
	BEQ.S	lbC0003E2
	MOVE.B	$4B(A0),D1
lbC0003E2	LSL.W	D6,D1
	ADDA.W	D1,A2
	MOVE.L	A2,$14(A0)
	MOVE.W	D5,$36(A0)
	MOVE.B	D5,$47(A0)
lbC0003F2	ADDQ.W	#2,$3C(A0)
	RTS

lbC0003F8	LEA	lbL000D9A(PC),A6
	LEA	lbL0075D6(PC),A0
	LEA	lbL0075E6(PC),A1
	LEA	lbL0075F6(PC),A2
	LEA	lbL007606(PC),A3
	MOVE.L	A0,(A6)
	MOVE.L	A1,8(A6)
	MOVE.L	A2,$10(A6)
	MOVE.L	A3,$18(A6)
	MOVEQ	#0,D5
	LEA	$DFF000,A6
	MOVE.W	#15,$96(A6)
	MOVE.W	#$780,$9A(A6)
	MOVE.L	D0,D7
	MULU.W	#$1C,D7
	MOVE.L	D1,D6
	ADDQ.L	#1,D6
	MULU.W	#$1C,D6
	MOVEQ	#6,D0
	LEA	lbL000AD2(PC),A0
	LEA	lbW000AA6(PC),A1
	LEA	lbL000D82(PC),A2
	LEA	lbL000ABE(PC),A5
lbC00044E	SF	$52(A0)
	MOVE.L	A1,$10(A0)
	MOVE.L	A1,$14(A0)

	move.l	lbL000DBC(PC),$18(A0)

	MOVE.B	#1,$44(A0)
	MOVE.B	#1,$45(A0)
	SF	$46(A0)
	MOVE.W	D5,$38(A0)
	SF	$47(A0)
	SF	$48(A0)
	SF	$49(A0)
	SF	$32(A0)
	MOVE.B	D5,$40(A0)
	SF	$4A(A0)
	SF	$4B(A0)
	MOVE.B	#$64,$51(A0)
	ST	$4C(A0)
	MOVE.W	lbW000DBA(PC),$3C(A0)
	SF	$4D(A0)
	SF	$4F(A0)
	MOVE.W	D5,$36(A0)
	MOVE.W	D5,$1C(A0)
	MOVE.W	D5,$34(A0)
	MOVE.L	(A2)+,D1
	MOVE.L	(A2)+,D3
	LSR.W	#2,D3
	MOVEQ	#0,D4
	BSET	D3,D4
	MOVE.W	D4,$3E(A0)
	LSL.W	#2,D3
	ANDI.L	#$FF,D3
	MOVEA.L	D1,A4
	MOVE.L	A5,(A4)+
	MOVE.W	#1,(A4)+
	MOVE.W	D5,(A4)+
	MOVE.W	D5,(A4)+
	MOVE.L	D1,0(A0)
	MOVE.L	lbL000DD0(PC),4(A0)
	MOVE.L	lbL000DD0(PC),8(A0)
	ADD.L	D6,8(A0)
	ADD.L	D3,8(A0)
	ADD.L	D7,4(A0)
	ADD.L	D3,4(A0)
	MOVE.W	D5,$3A(A0)
	LEA	$56(A0),A0
	DBRA	D0,lbC00044E
	LEA	lbW000AC4(PC),A0
	MOVE.W	#1,(A0)
	MOVE.W	D5,4(A0)
	LEA	lbW000DEC(PC),A0
	CLR.W	(A0)
	MOVEA.L	lbL000DD0(PC),A0
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVEQ	#0,D2
	MOVEQ	#0,D3
;	MOVE.B	1(A0),D1
;	NOP
;	MOVE.W	#$12,D1
;lbC000522	EQU	*-2

	move.w	lbC000522(PC),D1

	MOVE.B	2(A0),D2
	EXT.W	D2
	EXT.L	D2
	MOVE.B	3(A0),D3
	BRA.L	lbC007C3C

lbC000534	TST.B	$47(A0)
	BEQ.S	lbC000542
	SUBQ.B	#1,$47(A0)
	BRA.L	lbC000888

lbC000542	MOVEA.L	$14(A0),A1
	ADDA.W	$36(A0),A1
lbC00054A	MOVEQ	#0,D0
	MOVE.B	(A1)+,D0
	CMP.W	#$E0,D0
	BLT.L	lbC000880
	SUBI.W	#$E0,D0
	ADD.W	D0,D0
	MOVE.W	lbW000564(PC,D0.W),D0
	JMP	lbC00057A(PC,D0.W)

lbW000564
	dc.w	lbC0005A0-lbC00057A
	dc.w	lbC000888-lbC00057A
	dc.w	lbC0007C0-lbC00057A
	dc.w	lbC000592-lbC00057A
	dc.w	lbC00083E-lbC00057A
	dc.w	lbC0006E8-lbC00057A
	dc.w	lbC000794-lbC00057A
	dc.w	lbC0005B0-lbC00057A
	dc.w	lbC000588-lbC00057A
	dc.w	lbC000634-lbC00057A
	dc.w	lbC00057A-lbC00057A

lbC00057A	MOVE.B	(A1)+,$53(A0)
	SF	$54(A0)
	ADDQ.W	#2,$36(A0)
	BRA.S	lbC00054A

lbC000588	MOVE.B	(A1)+,$47(A0)
	ADDQ.W	#2,$36(A0)
	BRA.S	lbC000534

lbC000592	ADDQ.W	#3,$36(A0)
	MOVE.B	(A1)+,$48(A0)
	MOVE.B	(A1)+,$49(A0)
	BRA.S	lbC00054A

lbC0005A0	MOVEQ	#0,D0
	MOVE.B	(A1)+,D0
	MOVE.W	D0,$36(A0)
	MOVEA.L	$14(A0),A1
	ADDA.W	D0,A1
	BRA.S	lbC00054A

lbC0005B0	MOVEQ	#0,D1
	MOVE.B	(A1)+,D1
	CMP.B	$4C(A0),D1
	BEQ.S	lbC00061E
	SF	$53(A0)
	MOVE.B	D1,$4C(A0)
	MOVE.W	D0,-(SP)
	MOVE.W	$3E(A0),D0
	LEA	lbL000BD4(PC),A4
	CMPA.L	A4,A0
	BLT.S	lbC0005DE
	LEA	lbB000ACE(PC),A4
	OR.W	D0,2(A4)
	NOT.W	D0
	AND.W	D0,(A4)
	BRA.S	lbC0005E6

lbC0005DE	OR.W	D0,(A5)
	MOVE.W	D0,$DFF096
lbC0005E6	MOVE.W	(SP)+,D0
	MOVEA.L	lbL000DD4(PC),A4
	MOVE.W	D1,D3
	LSL.W	#5,D1
	ADD.W	D3,D3
	SUB.W	D3,D1
	ADDA.W	D1,A4
	MOVEA.L	$12(A4),A2
	ADDA.L	lbL000DDC(PC),A2
	MOVEA.L	0(A0),A3

	bsr.w	SetAll

	MOVE.L	A2,(A3)+
	MOVE.W	$16(A4),(A3)+
	MOVE.W	#4,(A3)+
	MOVEQ	#0,D1
	MOVE.W	$1A(A4),D1
	ADDA.L	D1,A2
	MOVE.L	A2,12(A0)
	MOVE.W	$1C(A4),$34(A0)
lbC00061E	MOVE.W	D7,$38(A0)
	MOVE.B	#1,$44(A0)
	ADDQ.W	#2,$36(A0)
	SF	$32(A0)
	BRA.L	lbC00054A

lbC000634	SF	$53(A0)
	ST	$4C(A0)
	MOVE.W	D0,-(SP)
	MOVE.W	$3E(A0),D0
	LEA	lbL000BD4(PC),A4
	CMPA.L	A4,A0
	BLT.S	lbC000658
	LEA	lbB000ACE(PC),A4
	OR.W	D0,2(A4)
	NOT.W	D0
	AND.W	D0,(A4)
	BRA.S	lbC000660

lbC000658	OR.W	D0,(A5)
	MOVE.W	D0,$DFF096
lbC000660	MOVE.W	(SP)+,D0
	MOVEQ	#0,D1
	MOVE.B	(A1)+,D1
	MOVEA.L	lbL000DD4(PC),A4
	MOVE.W	D1,D3
	LSL.W	#5,D1
	ADD.W	D3,D3
	SUB.W	D3,D1
	ADDA.W	D1,A4
	MOVEA.L	$12(A4),A2
	ADDA.L	lbL000DDC(PC),A2
	MOVEQ	#0,D0
	MOVE.W	4(A2),D0
	MOVE.W	6(A2),D2
	LSL.W	#2,D2
	MULU.W	#$18,D0
	ADDQ.L	#8,A2
	MOVEA.L	A2,A4
	ADDA.L	D0,A2
	ADDA.W	D2,A2
	MOVEQ	#0,D1
	MOVE.B	(A1)+,D1
	MULU.W	#$18,D1
	ADDA.L	D1,A4
	MOVE.L	(A4)+,D1
	MOVE.L	(A4)+,D2
	ANDI.L	#$FFFFFFFE,D1
	ANDI.L	#$FFFFFFFE,D2
	SUB.L	D1,D2
	LSR.L	#1,D2
	ADD.L	A2,D1
	MOVEA.L	0(A0),A3
	MOVE.L	D1,(A3)+
	MOVE.W	D2,(A3)+
	MOVE.W	#4,(A3)
	MOVE.L	D1,12(A0)
	PEA	(A2)
	MOVEA.L	D1,A2
	MOVE.B	(A2)+,(A2)
	MOVEA.L	(SP)+,A2
	MOVEQ	#1,D1
	MOVE.W	D1,$34(A0)
	MOVE.W	D7,$38(A0)
	MOVE.B	#1,$44(A0)
	ADDQ.W	#3,$36(A0)
	SF	$32(A0)
	BRA.L	lbC00054A

lbC0006E8	SF	$53(A0)
	MOVE.W	D0,-(SP)
	MOVE.W	$3E(A0),D0
	LEA	lbL000BD4(PC),A4
	CMPA.L	A4,A0
	BLT.S	lbC000708
	LEA	lbB000ACE(PC),A4
	OR.W	D0,2(A4)
	NOT.W	D0
	AND.W	D0,(A4)
	BRA.S	lbC000710

lbC000708	OR.W	D0,(A5)
	MOVE.W	D0,$DFF096
lbC000710	MOVE.W	(SP)+,D0
	MOVEA.L	0(A0),A3
	MOVE.W	#4,6(A3)
	MOVEQ	#0,D1
	MOVE.B	(A1)+,D1
	MOVEA.L	lbL000DD4(PC),A4
	MOVE.W	D1,D3
	LSL.W	#5,D1
	ADD.W	D3,D3
	SUB.W	D3,D1
	ADDA.W	D1,A4
	MOVEA.L	$12(A4),A2
	MOVE.L	A2,$1E(A0)
	MOVEQ	#0,D0
	MOVE.W	$16(A4),D0
	MOVE.W	D0,D1
	ADD.L	D0,D0
	ADDA.L	D0,A2
	MOVE.L	A2,$22(A0)
	MOVE.B	(A1)+,-(SP)
	MOVE.W	(SP)+,D0
	MOVE.B	(A1)+,D0
	CMP.W	#$FFFF,D0
	BNE.S	lbC000754
	MOVE.W	D1,D0
lbC000754	MOVE.W	D0,$26(A0)
	MOVE.B	(A1)+,-(SP)
	MOVE.W	(SP)+,D0
	MOVE.B	(A1)+,D0
	MOVE.W	D0,$2A(A0)
	MOVE.B	(A1)+,-(SP)
	MOVE.W	(SP)+,D0
	MOVE.B	(A1)+,D0
	MOVE.W	D0,$28(A0)
	SF	$30(A0)
	MOVE.B	(A1)+,$31(A0)
	SF	$33(A0)
	SF	$2C(A0)
	ST	$32(A0)
	MOVE.W	D7,$38(A0)
	MOVE.B	#1,$44(A0)
	ADDI.W	#9,$36(A0)
	BRA.L	lbC00054A

lbC000794	MOVE.B	(A1)+,-(SP)
	MOVE.W	(SP)+,D0
	MOVE.B	(A1)+,D0
	MOVE.W	D0,$2A(A0)
	MOVE.B	(A1)+,-(SP)
	MOVE.W	(SP)+,D0
	MOVE.B	(A1)+,D0
	MOVE.W	D0,$28(A0)
	SF	$30(A0)
	MOVE.B	(A1)+,$31(A0)
	SF	$2C(A0)
	SF	$33(A0)
	ADDQ.W	#6,$36(A0)
	BRA.L	lbC00054A

lbC0007C0	SF	$53(A0)
	ST	$4C(A0)
	MOVE.W	D0,-(SP)
	MOVE.W	$3E(A0),D0
	LEA	lbL000BD4(PC),A4
	CMPA.L	A4,A0
	BLT.S	lbC0007E4
	LEA	lbB000ACE(PC),A4
	OR.W	D0,2(A4)
	NOT.W	D0
	AND.W	D0,(A4)
	BRA.S	lbC0007EC

lbC0007E4	OR.W	D0,(A5)
	MOVE.W	D0,$DFF096
lbC0007EC	MOVE.W	(SP)+,D0
	MOVEQ	#0,D1
	MOVE.B	(A1)+,D1
	MOVEA.L	lbL000DD4(PC),A4
	MOVE.W	D1,D3
	LSL.W	#5,D1
	ADD.W	D3,D3
	SUB.W	D3,D1
	ADDA.W	D1,A4
	MOVEA.L	$12(A4),A2
	ADDA.L	lbL000DDC(PC),A2
	MOVEA.L	0(A0),A3

	bsr.w	SetAll

	MOVE.L	A2,(A3)+
	MOVE.W	$16(A4),(A3)+
	MOVE.W	#4,(A3)
	MOVEQ	#0,D1
	MOVE.W	$1A(A4),D1
	ADDA.L	D1,A2
	MOVE.L	A2,12(A0)
	MOVE.W	$1C(A4),$34(A0)
	MOVE.W	D7,$38(A0)
	MOVE.B	#1,$44(A0)
	ADDQ.W	#2,$36(A0)
	SF	$32(A0)
	BRA.L	lbC00054A

lbC00083E	MOVEQ	#0,D1
	MOVE.B	(A1)+,D1
	MOVEA.L	lbL000DD4(PC),A4
	MOVE.W	D1,D3
	LSL.W	#5,D1
	ADD.W	D3,D3
	SUB.W	D3,D1
	ADDA.W	D1,A4
	MOVEA.L	$12(A4),A2
	ADDA.L	lbL000DDC(PC),A2
	MOVEA.L	0(A0),A3
	MOVE.L	A2,(A3)+
	MOVEQ	#0,D1
	MOVE.W	$1A(A4),D1
	ADDA.L	D1,A2
	MOVE.L	A2,12(A0)
	MOVE.W	$16(A4),(A3)
	MOVE.W	$1C(A4),$34(A0)
	ADDQ.W	#2,$36(A0)
	SF	$32(A0)
	BRA.L	lbC00054A

lbC000880	MOVE.B	D0,$4D(A0)
	ADDQ.W	#1,$36(A0)
lbC000888	TST.B	$32(A0)
	BEQ.L	lbC00090C
	TST.B	$33(A0)
	BNE.L	lbC00090C
	SUBQ.B	#1,$30(A0)
	BPL.L	lbC00090C
	MOVE.B	$31(A0),$30(A0)
	MOVEA.L	$1E(A0),A1
	MOVEA.L	$22(A0),A2
	MOVEQ	#0,D0
	MOVE.W	$26(A0),D0
	MOVE.W	$28(A0),D1
	MOVE.W	$2A(A0),D2
	TST.B	$2C(A0)
	BNE.S	lbC0008C8
	ST	$2C(A0)
	BRA.S	lbC0008F0

lbC0008C8	EXT.L	D1
	ADD.L	D1,D0
	BPL.S	lbC0008D6
	ST	$33(A0)
	SUB.L	D1,D0
	BRA.S	lbC0008F0

lbC0008D6	MOVEA.L	A1,A3
	MOVE.L	D0,D3
	ADD.L	D3,D3
	ADDA.L	D3,A3
	MOVEQ	#0,D3
	MOVE.W	D2,D3
	ADD.L	D3,D3
	ADDA.L	D3,A3
	CMPA.L	A2,A3
	BLE.S	lbC0008F0
	ST	$33(A0)
	SUB.L	D1,D0
lbC0008F0	MOVE.W	D0,$26(A0)
	ADDA.L	lbL000DDC(PC),A1
	ADD.L	D0,D0
	ADDA.L	D0,A1
	MOVE.W	D2,$34(A0)
	MOVE.L	A1,12(A0)
	MOVEA.L	0(A0),A2
	MOVE.L	A1,(A2)+
	MOVE.W	D2,(A2)+
lbC00090C	TST.B	$46(A0)
	BEQ.S	lbC000918
	SUBQ.B	#1,$46(A0)
	BRA.S	lbC000976

lbC000918	SUBQ.B	#1,$44(A0)
	BNE.S	lbC000976
	MOVE.B	$45(A0),$44(A0)
lbC000924	MOVEA.L	$10(A0),A1
	ADDA.W	$38(A0),A1
	MOVEQ	#0,D0
	MOVE.B	(A1)+,D0
	CMP.W	#$E0,D0
	BLT.S	lbC00096E
	SUBI.W	#$E0,D0
	ADD.W	D0,D0
	MOVE.W	lbW000944(PC,D0.W),D0
	JMP	lbC000956(PC,D0.W)

lbW000944
	dc.w	lbC000960-lbC000956
	dc.w	lbC00096C-lbC000956
	dc.w	lbC00096C-lbC000956
	dc.w	lbC00096C-lbC000956
	dc.w	lbC00096C-lbC000956
	dc.w	lbC00096C-lbC000956
	dc.w	lbC00096C-lbC000956
	dc.w	lbC00096C-lbC000956
	dc.w	lbC000956-lbC000956

lbC000956	MOVE.B	(A1),$46(A0)
	ADDQ.W	#2,$38(A0)
	BRA.S	lbC00090C

lbC000960	MOVEQ	#0,D0
	MOVE.B	(A1),D0
	SUBQ.W	#5,D0
	MOVE.W	D0,$38(A0)
	BRA.S	lbC000924

lbC00096C	BRA.S	lbC000976

lbC00096E	MOVE.B	D0,$4F(A0)
	ADDQ.W	#1,$38(A0)
lbC000976	MOVE.B	$4D(A0),D0
	BMI.S	lbC000984
	ADD.B	$41(A0),D0
	ADD.B	$4E(A0),D0
lbC000984	ANDI.W	#$7F,D0
	LEA	lbW000DEE(PC),A1
	ADD.W	D0,D0
	MOVE.W	0(A1,D0.W),D0
	MOVEQ	#10,D2
	TST.B	$4A(A0)
	BEQ.S	lbC0009A0
	SUBQ.B	#1,$4A(A0)
	BRA.S	lbC0009E8

lbC0009A0	MOVEQ	#0,D1
	MOVEQ	#0,D4
	MOVEQ	#0,D5
	MOVE.B	$50(A0),D6
	MOVE.B	$49(A0),D4
	MOVE.B	$48(A0),D5
	MOVE.B	$40(A0),D1
	BTST	#5,D6
	BNE.S	lbC0009C8
	SUB.W	D5,D1
	BPL.S	lbC0009D4
	BSET	#5,D6
	MOVEQ	#0,D1
	BRA.S	lbC0009D4

lbC0009C8	ADD.W	D5,D1
	CMP.W	D4,D1
	BLE.S	lbC0009D4
	BCLR	#5,D6
	MOVE.W	D4,D1
lbC0009D4	MOVE.B	D1,$40(A0)
	MOVE.B	D6,$50(A0)
	LSR.W	#1,D4
	SUB.W	D4,D1
	EXT.L	D1
	MULS.W	D0,D1
	ASR.L	D2,D1
	ADD.L	D1,D0
lbC0009E8	BTST	#5,$42(A0)
	BEQ.S	lbC000A18
	MOVEQ	#0,D1
	MOVE.B	$4B(A0),D1
	BMI.S	lbC000A08
	ADD.W	D1,$1C(A0)
	MOVE.W	$1C(A0),D1
	MULU.W	D0,D1
	LSR.L	D2,D1
	SUB.W	D1,D0
	BRA.S	lbC000A18

lbC000A08	NEG.B	D1
	ADD.W	D1,$1C(A0)
	MOVE.W	$1C(A0),D1
	MULU.W	D0,D1
	LSR.L	D2,D1
	ADD.W	D1,D0
lbC000A18	MOVE.W	D0,$2E(A0)
	TST.B	$52(A0)
	BEQ.S	lbC000A32
	MOVEA.L	0(A0),A3
	MOVE.W	#1,6(A3)
	MOVE.W	#0,10(A3)
lbC000A32	SWAP	D0
	MOVEQ	#0,D1
	MOVEQ	#0,D2
	MOVE.B	$4F(A0),D2
	LEA	lbL000D2C(PC),A1
	CMPA.L	A0,A1
	BEQ.S	lbC000A86
	MOVE.B	$51(A0),D1
	SUB.W	lbW000DEA(PC),D1
	MOVEQ	#0,D3
	MOVE.B	$53(A0),D3
	BEQ.S	lbC000A7A
	MOVEQ	#0,D4
	MOVE.B	$54(A0),D4
	BNE.S	lbC000A76
	SF	$53(A0)
	MOVE.W	D7,-(SP)
	BSR.L	lbC000A8A
	ANDI.W	#$FF,D7
	MULU.W	D7,D3
	DIVU.W	#$FF,D3
	MOVE.B	D3,$54(A0)
	MOVE.W	D3,D4
lbC000A76	SUB.W	D4,D1
	MOVE.W	(SP)+,D7
lbC000A7A	TST.W	D1
	BPL.S	lbC000A80
	MOVEQ	#0,D1
lbC000A80	MULU.W	D1,D2
	DIVU.W	#$64,D2
lbC000A86	MOVE.W	D2,D0
	RTS

lbC000A8A	PEA	(A0)
	MOVE.W	D6,-(SP)
	LEA	lbW000ACA(PC),A0
	MOVE.W	(A0),D7
	ADDI.W	#$4793,D7
	MOVE.W	D7,D6
	ROR.W	#6,D7
	EOR.W	D6,D7
	MOVE.W	D7,(A0)
	MOVE.W	(SP)+,D6
	MOVEA.L	(SP)+,A0
	RTS

lbW000AA6	dc.w	$100
	dc.w	0
	dc.w	0
	dc.w	$E1
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
lbL000ABE	dc.l	0
	dc.w	0
lbW000AC4	dc.w	0
lbW000AC6	dc.w	0
lbW000AC8	dc.w	0
lbW000ACA	dc.w	0
lbW000ACC	dc.w	0
lbB000ACE	dc.b	0
lbB000ACF	dc.b	0
	dc.w	0
lbL000AD2	dc.l	0
	dc.l	0
	dc.l	0
lbL000ADE	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbL000B06	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
lbL000B28	dc.l	0
	dc.l	0
	dc.l	0
lbL000B34	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbL000B5C	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
lbL000B7E	dc.l	0
	dc.l	0
	dc.l	0
lbL000B8A	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbL000BB2	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
lbL000BD4	dc.l	0
	dc.l	0
	dc.l	0
lbL000BE0	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbL000C08	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
lbL000C2A	dc.l	0
	dc.l	0
	dc.l	0
lbL000C36	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbL000C5E	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
lbL000C80	dc.l	0
	dc.l	0
	dc.l	0
lbL000C8C	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbL000CB4	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
lbL000CD6	dc.l	0
	dc.l	0
	dc.l	0
lbL000CE2	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbL000D0A	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
lbL000D2C	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
lbL000D82	dc.l	$DFF0A0
	dc.l	0
	dc.l	$DFF0B0
	dc.l	4
	dc.l	$DFF0C0
	dc.l	8
lbL000D9A	dc.l	0
	dc.l	12
	dc.l	0
	dc.l	$10
	dc.l	0
	dc.l	$14
	dc.l	0
	dc.l	$18
lbW000DBA	dc.w	$40
lbL000DBC	dc.l	0
lbL000DC0	dc.l	0
	dc.l	0
lbL000DC8	dc.l	0
	dc.l	0
lbL000DD0	dc.l	0
lbL000DD4	dc.l	0
	dc.l	0
lbL000DDC	dc.l	0
	dc.l	0
lbL000DE4	dc.l	0
lbW000DE8	dc.w	0
lbW000DEA	dc.w	0
lbW000DEC	dc.w	0
lbW000DEE	dc.w	$6B0
	dc.w	$650
	dc.w	$5F4
	dc.w	$5A0
	dc.w	$54C
	dc.w	$500
	dc.w	$4B8
	dc.w	$474
	dc.w	$434
	dc.w	$3F8
	dc.w	$3C0
	dc.w	$38A
	dc.w	$358
	dc.w	$328
	dc.w	$2FA
	dc.w	$2D0
	dc.w	$2A6
	dc.w	$280
	dc.w	$25C
	dc.w	$23A
	dc.w	$21A
	dc.w	$1FC
	dc.w	$1E0
	dc.w	$1C5
	dc.w	$1AC
	dc.w	$194
	dc.w	$17D
	dc.w	$168
	dc.w	$153
	dc.w	$140
	dc.w	$12E
	dc.w	$11D
	dc.w	$10D
	dc.w	$FE
	dc.w	$F0
	dc.w	$E2
	dc.w	$D6
	dc.w	$CA
	dc.w	$BE
	dc.w	$B4
	dc.w	$AA
	dc.w	$A0
	dc.w	$97
	dc.w	$8F
	dc.w	$87
	dc.w	$7F
	dc.w	$78
	dc.w	$71
	dc.w	$71
	dc.w	$71
	dc.w	$71
	dc.w	$71
	dc.w	$71
	dc.w	$71
	dc.w	$71
	dc.w	$71
	dc.w	$71
	dc.w	$71
	dc.w	$71
	dc.w	$71
	dc.w	$D60
	dc.w	$CA0
	dc.w	$BE8
	dc.w	$B40
	dc.w	$A98
	dc.w	$A00
	dc.w	$970
	dc.w	$8E8
	dc.w	$868
	dc.w	$7F0
	dc.w	$780
	dc.w	$714
lbL000E7E	dc.l	0
lbL000E82	dc.l	0
lbL000E86	dc.l	0
lbL000E8A	dc.l	0
;lbL000E8E	dc.l	0

;lbC000E92	MOVEA.L	lbL007600(PC),A2
;	SUB.W	lbW007604(PC),D2
;	BRA.S	lbC000F0E

;lbC000E9C	MOVEA.L	lbL007610(PC),A3
;	SUB.W	lbW007614(PC),D3
;	DBRA	D5,lbC000EBC
;	MOVEA.L	lbL000E8E(PC),SP
;	RTS

;lbC000EAE	LEA	lbL000E8E(PC),A6
;	MOVE.L	SP,(A6)
;	MOVEM.L	(lbL000E7E,PC),D6/D7/A5/A6
;	MOVEQ	#0,D4
;lbC000EBC	SWAP	D5		; 4
;	MOVE.B	0(A0,D0.W),D4		; 14
;	LEA	lbL0013B2(PC),SP	; 8
;lbW000EC4	EQU	*-2
;	MOVE.B	0(SP,D4.W),D4		; 14
;	MOVE.B	0(A1,D1.W),D5		; 14
;	LEA	lbL0013B2(PC),SP	; 8
;lbW000ED0	EQU	*-2
;	MOVE.B	0(SP,D5.W),D5		; 14
;	ADD.W	D5,D4			; 4
;	MOVE.B	0(A2,D2.W),D5		; 14
;	LEA	lbL0013B2(PC),SP	; 8
;lbW000EDE	EQU	*-2
;	MOVE.B	0(SP,D5.W),D5		; 14
;	ADD.W	D5,D4			; 4
;	MOVE.B	0(A3,D3.W),D5		; 14
;	LEA	lbL0013B2(PC),SP	; 8
;lbW000EEC	EQU	*-2
;	MOVE.B	0(SP,D5.W),D5		; 14
;	ADD.W	D5,D4			; 4
;	SWAP	D5			; 4
;	MOVE.B	lbL000F32(PC,D4.W),(A4)+; 18
;	MOVEQ	#0,D4			; 4
;	ADD.L	D6,D0			; 6
;	ADDX.W	D4,D0			; 4
;	BPL.S	lbC000F1E		; 8/12
;lbC000F02	ADD.L	D7,D1		; 6
;	ADDX.W	D4,D1			; 4
;	BPL.S	lbC000F28		; 8/12
;lbC000F08	ADD.L	A5,D2		; 6
;	ADDX.W	D4,D2			; 4
;	BPL.S	lbC000E92		; 8/12
;lbC000F0E	ADD.L	A6,D3		; 6
;	ADDX.W	D4,D3			; 4
;	BPL.S	lbC000E9C		; 8
;	DBRA	D5,lbC000EBC		; 10
;	MOVEA.L	lbL000E8E(PC),SP	; total minimum 268 cycles (32 commands)
;	RTS

;lbC000F1E	MOVEA.L	lbL0075E0(PC),A0
;	SUB.W	lbW0075E4(PC),D0
;	BRA.S	lbC000F02

;lbC000F28	MOVEA.L	lbL0075F0(PC),A1
;	SUB.W	lbW0075F4(PC),D1
;	BRA.S	lbC000F08

;lbL000F32	ds.b	1152

;lbL0013B2	ds.b	24576		; was 64*384

lbW000EC4
	dc.w	0
lbW000ED0
	dc.w	0
lbW000EDE
	dc.w	0
lbW000EEC
	dc.w	0
Play
lbC0073B2	MOVE.W	#$400,$DFF09A
	MOVE.W	#$400,$DFF09C
;	MOVE.W	#$2000,SR
	MOVE.L	lbL007620(PC),$DFF0D0
	MOVE.W	lbW007C0A(PC),$DFF0D4

	move.l	lbL007620(PC),StructAdr+UPS_Voice4Adr
	move.w	lbW007C0A(PC),StructAdr+UPS_Voice4Len

	MOVEM.L	D0-D7/A0-A6,-(SP)
	BSR.L	lbC000118
	BSR.L	lbC007416
	LEA	lbL007620(PC),A5
	LEA	lbL00761C(PC),A6
	MOVEA.L	(A5),A4
	MOVE.L	(A6),(A5)
	MOVE.L	A4,(A6)
	MOVEM.L	(lbW007824,PC),D0-D3/A0-A3
	MOVEQ	#0,D5
	MOVE.W	lbW007C08(PC),D5

	swap	D5
	moveq	#1,D4
	swap	D4
	move.l	lbW000EC4(PC),D6
	move.l	lbW000EDE(PC),D7
	move.l	lbL000E7E(PC),A5
	move.l	lbL000E82(PC),A6

	BSR.L	lbC000EAE
	LEA	lbW007824(PC),A6
	MOVEM.L	D0-D3/A0-A3,(A6)
	MOVEM.L	(SP)+,D0-D7/A0-A6
;	MOVE.W	#$C400,$DFF09A
;	RTE

	move.w	#$8400,$DFF09A
	rts

lbC007416	MOVEM.L	D0-D3/A0-A3,-(SP)
;	LEA	lbL0013B2(PC),A3
	MOVE.L	lbL007C04(PC),D3
	LEA	lbL0075D6(PC),A0
	LEA	lbW000EC4(PC),A1
	LEA	lbL000E7E(PC),A2
	BSR.L	lbC007468
	LEA	lbL0075E6(PC),A0
;	LEA	lbW000ED0(PC),A1

	addq.w	#2,A1

	LEA	lbL000E82(PC),A2
	BSR.L	lbC007468
	LEA	lbL0075F6(PC),A0
;	LEA	lbW000EDE(PC),A1

	addq.w	#2,A1

	LEA	lbL000E86(PC),A2
	BSR.L	lbC007468
	LEA	lbL007606(PC),A0
;	LEA	lbW000EEC(PC),A1

	addq.w	#2,A1

	LEA	lbL000E8A(PC),A2
	BSR.L	lbC007468
	MOVEM.L	(SP)+,D0-D3/A0-A3
	RTS

lbC007468
;	MOVEQ	#0,D2
	MOVE.W	6(A0),D0
	BEQ.S	lbC00749C
	MOVE.W	8(A0),D2
	ANDI.W	#$FF,D2
	CMP.W	#$40,D2
	BLT.S	lbC007480
	MOVEQ	#$3F,D2
lbC007480
;	MULU.W	#$180,D2

	addq.w	#4,D2		; skip v7con table
	lsl.w	#8,D2		; *256
	move.w	D2,(A1)

	MOVE.L	D3,D1
	DIVU.W	D0,D1
	ANDI.L	#$FFFF,D1
	LSL.L	#5,D1
	SWAP	D1
	MOVE.L	D1,(A2)
;	MOVEA.L	A3,A0
;	ADDA.L	D2,A0
;	SUBA.L	A1,A0
;	MOVE.W	A0,(A1)
lbC00749C	RTS

lbC00749E	MOVEM.L	D0/D1/A0-A4,-(SP)
	LEA	lbB000ACF(PC),A2
	MOVEQ	#3,D0
	LEA	lbL000E7E(PC),A3
	LEA	lbB007616(PC),A4
	LEA	lbW007824(PC),A1
	LEA	lbL0075D6(PC),A0
	BSR.L	lbC007504
	MOVEQ	#4,D0
	LEA	lbL000E82(PC),A3
	LEA	lbB007617(PC),A4
	LEA	lbL007828(PC),A1
	LEA	lbL0075E6(PC),A0
	BSR.L	lbC007504
	MOVEQ	#5,D0
	LEA	lbL000E86(PC),A3
	LEA	lbB007618(PC),A4
	LEA	lbL00782C(PC),A1
	LEA	lbL0075F6(PC),A0
	BSR.L	lbC007504
	MOVEQ	#6,D0
	LEA	lbL000E8A(PC),A3
	LEA	lbB007619(PC),A4
	LEA	lbL007830(PC),A1
	LEA	lbL007606(PC),A0
	BSR.L	lbC007504
	MOVEM.L	(SP)+,D0/D1/A0-A4
	RTS

lbC007504	BTST	D0,(A2)
	BNE.S	lbC00750E
	CLR.L	(A3)
	ST	(A4)
	RTS

lbC00750E	MOVE.L	(A0),D0
	MOVE.W	4(A0),D1
	ANDI.L	#$3FFF,D1
	CMP.W	#$10,D1
	BGT.S	lbC007534
	PEA	(A1)
	LEA	lbL007624(PC),A1
	MOVE.L	A1,D0
	MOVEA.L	(SP)+,A1
	MOVE.W	#$80,D1
	MOVE.W	D1,4(A0)
	MOVE.L	D0,(A0)
lbC007534	ADD.L	D1,D1
	ADD.L	D1,D0
	MOVE.L	D0,10(A0)
	MOVE.W	D1,14(A0)
	TST.B	(A4)
	BEQ.S	lbC00755E
	SF	(A4)
	MOVE.L	(A0),D1
	MOVE.W	4(A0),D0
	ANDI.L	#$3FFF,D0
	ADD.W	D0,D0
	ADD.L	D0,D1
	MOVE.L	D1,$10(A1)
	NEG.L	D0
	MOVE.L	D0,(A1)
lbC00755E	RTS

lbC007560
;	LEA	lbL000F32(PC),A0

	lea	v7contab(PC),A0

	MOVE.B	lbB00761B(PC),D0
	BEQ.S	lbC00758E
	MOVE.W	#$17F,D0
lbC00756E	MOVE.B	#$80,(A0)+
	MOVE.B	#$7F,$27F(A0)
	DBRA	D0,lbC00756E
	MOVE.W	#$FF,D0
	MOVE.B	#$80,D1
lbC007584	MOVE.B	D1,(A0)+
	ADDQ.B	#1,D1
	DBRA	D0,lbC007584
	RTS

lbC00758E	MOVE.W	#$FF,D0
	MOVE.B	#$80,D1
lbC007596	MOVE.B	D1,(A0)+
	MOVE.B	D1,(A0)+
	MOVE.B	D1,(A0)+
	MOVE.B	D1,(A0)+
	ADDQ.B	#1,D1
	DBRA	D0,lbC007596
	RTS

lbC0075A6
;	LEA	lbL0013B2(PC),A0

	lea	v7voltab(PC),A0

	MOVEQ	#0,D7
	MOVEQ	#$3F,D0
lbC0075AE	MOVEQ	#0,D6
	MOVE.W	#$FF,D1
lbC0075B4	MOVE.W	D6,D2
	EXT.W	D2
	MULS.W	D7,D2
	DIVS.W	#$3F,D2
	ADDI.B	#$80,D2
	MOVE.B	D2,(A0)+
	ADDQ.W	#1,D6
	DBRA	D1,lbC0075B4
;	LEA	$80(A0),A0
	ADDQ.W	#1,D7
	DBRA	D0,lbC0075AE
	RTS

lbL0075D6	dc.l	0
	dc.w	0
lbL0075DC	dc.l	0
lbL0075E0	dc.l	0
lbW0075E4	dc.w	0
lbL0075E6	dc.l	0
	dc.w	0
lbL0075EC	dc.l	0
lbL0075F0	dc.l	0
lbW0075F4	dc.w	0
lbL0075F6	dc.l	0
	dc.w	0
lbL0075FC	dc.l	0
lbL007600	dc.l	0
lbW007604	dc.w	0
lbL007606	dc.l	0
	dc.w	0
lbL00760C	dc.l	0
lbL007610	dc.l	0
lbW007614	dc.w	0
lbB007616	dc.b	0
lbB007617	dc.b	0
lbB007618	dc.b	0
lbB007619	dc.b	0
lbB00761A	dc.b	0
lbB00761B	dc.b	0
lbL00761C	dc.l	0
lbL007620	dc.l	0

lbL007624	ds.b	512

lbW007824	dc.w	0
	dc.w	0
lbL007828	dc.l	0
lbL00782C	dc.l	0
lbL007830	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0

lbL007C04	dc.l	0
lbW007C08	dc.w	0
lbW007C0A	dc.w	0

lbW007C0C
	dc.w	0

; original period values
;		Period value		 Mixing value	Hz value
	dc.w	3580			; 01		999	-> ~1kHz
	dc.w	1790			; 02		1999	-> ~2kHz
	dc.w	1193			; 03		3000	-> ~3kHz
	dc.w	895			; 04		3999	-> ~4kHz
	dc.w	716			; 05		4999	-> ~5kHz
	dc.w	597			; 06		5995	-> ~6kHz
	dc.w	511			; 07		7004	-> ~7kHz
	dc.w	447			; 08		8007	-> ~8kHz
	dc.w	398			; 09		8993	-> ~9kHz
	dc.w	358			; 10		9998	-> ~10kHz
	dc.w	325			; 11		11013	-> ~11kHz
	dc.w	298			; 12		12011	-> ~12kHz
	dc.w	275			; 13		13016	-> ~13kHz
	dc.w	256			; 14		13982	-> ~14kHz
	dc.w	239			; 15		14977	-> ~15kHz
	dc.w	224			; 16		15980	-> ~16kHz
	dc.w	211			; 17		16964	-> ~17kHz
	dc.w	199			; 18		17987	-> ~18kHz
	dc.w	188			; 19		19040	-> ~19kHz
	dc.w	179			; 20		19997	-> ~20kHz
	dc.w	170			; 21		21056	-> ~21kHz
	dc.w	163			; 22		21960	-> ~22kHz
	dc.w	156			; 23		22945	-> ~23kHz

; extended period values

	dc.w	149			; 24		24023	-> ~24kHz
	dc.w	143			; 25		25031	-> ~25kHz
	dc.w	138			; 26		25938	-> ~26kHz
	dc.w	133			; 27		26913	-> ~27kHz
	dc.w	128			; 28		27965	-> ~28kHz
;	dc.w	124			; 29		28867	-> Maximum

lbC007C3C	LEA	lbB00761B(PC),A1
	MOVE.B	D3,(A1)
	MOVE.W	#8,$DFF096
	BSR.L	lbC007D2A
	BSR.L	lbC007560
	LEA	lbB00761A(PC),A0
	TST.B	(A0)
	BNE.S	lbC007C60
	ST	(A0)
	BSR.L	lbC0075A6
lbC007C60	MOVE.L	#$D0,D0
	LEA	lbW0075E4(PC),A0
	LEA	lbW0075F4(PC),A1
	LEA	lbW007604(PC),A2
	LEA	lbW007614(PC),A3
	MOVE.W	D0,(A0)
	MOVE.W	D0,(A1)
	MOVE.W	D0,(A2)
	MOVE.W	D0,(A3)
	MOVEQ	#0,D0
	LEA	lbL000E7E(PC),A0
	MOVE.L	D0,(A0)+
	MOVE.L	D0,(A0)+
	MOVE.L	D0,(A0)+
	MOVE.L	D0,(A0)+
	LEA	lbB007616(PC),A0
	MOVE.L	D0,(A0)
	LEA	lbB000ACE(PC),A0
	CLR.W	(A0)
	MOVE.L	#$FFF0,D0
	MOVE.L	D0,D1
	MOVE.L	D0,D2
	MOVE.L	D0,D3
	LEA	lbW007824(PC),A0
	MOVEA.L	A0,A1
	MOVEA.L	A0,A2
	MOVEA.L	A0,A3
	LEA	lbL0075E0(PC),A4
	MOVE.L	A0,(A4)
	LEA	lbL0075F0(PC),A4
	MOVE.L	A0,(A4)
	LEA	lbL007600(PC),A4
	MOVE.L	A0,(A4)
	LEA	lbL007610(PC),A4
	MOVE.L	A0,(A4)
	LEA	lbW007824(PC),A4
	MOVEM.L	D0-D3/A0-A3,(A4)
	LEA	lbL00761C(PC),A0
	LEA	lbL007620(PC),A1
	LEA	lbL007844,A2			; was PC
	LEA	lbL007A24,A3			; was PC
	MOVE.L	A2,(A0)
	MOVE.L	A3,(A1)
	MOVEA.L	(A0),A5
	MOVEA.L	(A1),A6
	MOVE.W	lbW007C08(PC),D6
lbC007CEA	CLR.B	(A5)+
	CLR.B	(A6)+
	DBRA	D6,lbC007CEA
;	LEA	lbC0073B2(PC),A0
;	MOVE.L	A0,$70
	MOVE.W	#$40,$DFF0D8
	MOVE.L	A2,$DFF0D0
	MOVE.W	#2,$DFF0D4
;	MOVE.W	#$C400,$DFF09A
;	MOVE.W	#$8208,$DFF096
	RTS

lbC007D22	MOVE.W	lbW007D86(PC),D1
	EXT.W	D2
	EXT.L	D2
lbC007D2A	MOVE.L	D2,D6
	MOVE.W	D1,D0
;	ANDI.W	#$1F,D0
;	CMP.W	#$17,D0
;	BLE.S	lbC007D3A
;	MOVEQ	#$17,D0
lbC007D3A	LEA	lbW007D86(PC),A0
	MOVE.W	D0,(A0)
	MOVE.W	D0,D1
	MULU.W	#$64,D1
	DIVU.W	#5,D1
	ADDI.L	#$100,D2
	MULU.W	D2,D1
	LSR.L	#8,D1
	MOVE.W	D1,D2
	LSR.W	#1,D2
	LEA	lbW007C0A(PC),A0
	LEA	lbW007C08(PC),A1
	SUBQ.W	#1,D1
	MOVE.W	D2,(A0)
	MOVE.W	D1,(A1)
	LEA	lbW007C0C(PC),A0
	ADD.W	D0,D0
	MOVEQ	#0,D1
	MOVE.W	0(A0,D0.W),D1
	MOVE.L	D1,D2
	LSL.L	#8,D2
	LSL.L	#3,D2
	MOVE.W	D1,$DFF0D6

	lea	Period4(PC),A0
	move.w	D1,(A0)

	LEA	lbL007C04(PC),A0
	MOVE.L	D2,(A0)
	RTS

lbW007D86	dc.w	0

;	MOVE.W	#15,$DFF096
;	RTS

; Mixer - new mixing routine

clvc3
	move.l	lbL007600(PC),A2
	sub.w	lbW007604(PC),D2
	bra.s	cbk3
clvc4
	move.l	lbL007610(PC),A3
	sub.w	lbW007614(PC),D3
	sub.l	D4,D5
	bcc.b	calc1
	addq.w	#4,SP			; restore stack
	rts

lbC000EAE
	move.l	lbL000E86(PC),-(SP)
calc1
	swap	D6			; 4
	move.b	(A0,D0.W),D6		; 14 data 1
	move.b	v7contab(PC,D6.W),D4	; 14 volume 1
	swap	D6			; 4
	move.b	(A1,D1.W),D6		; 14 data 2
	move.b	v7contab(PC,D6.W),D5	; 14 volume 2
	add.w	D5,D4			; 4  mix 2 in 1
	swap	D7			; 4
	move.b	(A2,D2.W),D7		; 14 data 3
	move.b	v7contab(PC,D7.W),D5	; 14 volume 3
	add.w	D5,D4			; 4  mix 3 in 1/2
	swap	D7			; 4
	move.b	(A3,D3.W),D7		; 14 data 4
	move.b	v7contab(PC,D7.W),D5	; 14 volume 4
	add.w	D5,D4			; 4  mix 4 in 1/2/3
	move.b	v7contab(PC,D4.W),(A4)+	; 18 mixed byte in buffer
	clr.w	D4			; 4
	add.l	A5,D0			; 6
	addx.w	D4,D0			; 4
	bpl.s	clvc1			; 8/12
cbk1
	add.l	A6,D1			; 6
	addx.w	D4,D1			; 4
	bpl.s	clvc2			; 8/12
cbk2
	add.l	(SP),D2			; 14
	addx.w	D4,D2			; 4
	bpl.s	clvc3			; 8/12
cbk3
	add.l	lbL000E8A(PC),D3	; 18
	addx.w	D4,D3			; 4
	bpl.s	clvc4			; 8/12
	sub.l	D4,D5			; 6
	bcc.b	calc1			; 10
	addq.w	#4,SP			; restore stack
	rts				; total minimum 270 cycles (31 commands)
					; old ver. minimum 308 cycles (33 commands)

* if used
*	add.l	SP,D2			; 6   stack as simple register
*	add.l	#$xxxxxxxx,D3		; 14  selfmodyfiyng code here
* no-OS friendly version minimum 258 cycles (31 commands) is 10 cycles fastest
* per loop than original Mad Max mixing routine :-)

clvc1
	move.l	lbL0075E0(PC),A0
	sub.w	lbW0075E4(PC),D0
	bra.s	cbk1
clvc2
	move.l	lbL0075F0(PC),A1
	sub.w	lbW0075F4(PC),D1
	bra.s	cbk2

	Section	MixBuffer,Code_BSS

v7contab
	ds.b	4*256
v7voltab
	ds.b	64*256

	Section	PlayBuffer,BSS_C

lbL007844	ds.b	480+358			; extended buffer

lbL007A24	ds.b	480+358			; extended buffer

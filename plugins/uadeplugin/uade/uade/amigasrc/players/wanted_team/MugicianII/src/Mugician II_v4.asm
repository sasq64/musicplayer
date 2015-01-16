	*****************************************************
	****    Mugician II replayer for EaglePlayer, 	 ****
	****	     all adaptions by Wanted Team	 ****
	****      DeliTracker compatible (?) version	 ****
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

	dc.b	'$VER: Mugician II player module V1.3 (20 Sep 2002)',0
	even
Tags
	dc.l	DTP_PlayerVersion,4
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
	dc.l	DTP_NextPatt,NextPattern
	dc.l	DTP_PrevPatt,PrevPattern
	dc.l	EP_PatternInit,PatternInit
	dc.l	DTP_Config,Config
	dc.l	DTP_UserConfig,UserConfig
	dc.l	EP_Flags,EPB_Volume!EPB_Balance!EPB_ModuleInfo!EPB_SampleInfo!EPB_Save!EPB_PrevPatt!EPB_NextPatt!EPB_Songend!EPB_Analyzer!EPB_NextSong!EPB_PrevSong!EPB_Packable!EPB_Restart
	dc.l	0

PlayerName
	dc.b	'Mugician II',0
Creator
	dc.b	'(c) 1991-94 Reinier ''Rhino'' van Vliet,',10
	dc.b	'adapted by Wanted Team',0
Prefix	dc.b	'MUG2.',0
CfgPath1
	dc.b	'Configs/EP-Mugician_II.cfg',0
CfgPath2
	dc.b	'EnvArc:EaglePlayer/EP-Mugician_II.cfg',0
CfgPath3
	dc.b	'Env:EaglePlayer/EP-Mugician_II.cfg',0
	even
ModulePtr
	dc.l	0
EagleBase
	dc.l	0
SampleInfoPtr
	dc.l	0
SongName
	ds.b	12
MixRate
	dc.w	DEFAULT_MIXING_RATE
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
	dc.b	'Mugician II',0

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
	lea	CfgPath1(PC),A0
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
****************************** EP_PatternInit *****************************
***************************************************************************

PATTERNINFO:
	DS.B	PI_Stripes	; This is the main structure

* Here you store the address of each "stripe" (track) for the current
* pattern so the PI engine can read the data for each row and send it
* to the CONVERTNOTE function you supply.  The engine determines what
* data needs to be converted by looking at the Pattpos and Modulo fields.

STRIPE1	DS.L	1
STRIPE2	DS.L	1
STRIPE3	DS.L	1
STRIPE4	DS.L	1
STRIPE5	DS.L	1
STRIPE6	DS.L	1
STRIPE7	DS.L	1

* More stripes go here in case you have more than 4 channels.


* Called at various and sundry times (e.g. StartInt, apparently)
* Return PatternInfo Structure in A0
PatternInit
	lea	PATTERNINFO(PC),A0

	move.w	#7,PI_Voices(A0)	; Number of stripes (MUST be at least 4)
	move.l	#CONVERTNOTE,PI_Convert(A0)
	moveq	#4,D0
	move.l	D0,PI_Modulo(A0)	; Number of bytes to next row
	move.w	#64,PI_Pattlength(A0)	; Length of each stripe in rows

	move.w	#5,PI_Speed(A0)		; Default Speed Value
	clr.w	PI_Pattpos(A0)		; Current Position in Pattern (from 0)
	clr.w	PI_Songpos(A0)		; Current Position in Song (from 0)
	move.w	InfoBuffer+Length+2(PC),PI_MaxSongPos(A0)	; Songlength

	move.w	#125,PI_BPM(A0)

	lea	STRIPE1(PC),A1
	clr.l	(A1)+
	clr.l	(A1)+
	clr.l	(A1)+
	clr.l	(A1)+
	clr.l	(A1)+
	clr.l	(A1)+
	clr.l	(A1)
	rts

* Called by the PI engine to get values for a particular row
CONVERTNOTE:


* The command string is a single character.  It is NOT ASCII, howver.
* The character mapping starts from value 0 and supports letters from A-Z

* $00 ~ '0'
* ...
* $09 ~ '9'
* $0A ~ 'A'
* ...
* $0F ~ 'F'
* $10 ~ 'G'
* etc.

	moveq	#0,D0		; Period? Note?
	moveq	#0,D1		; Sample number
	moveq	#0,D2		; Command string
	moveq	#0,D3		; Command argument

	move.b	(A0),D0
	beq.b	NoNote
	lea	PeriodTable(PC),A1
	add.w	D0,D0
	move.w	0(A1,D0.W),D0
NoNote
	move.b	1(A0),D1
	move.b	2(A0),D2
	beq.b	SkipCom
	cmp.b	#$40,D2
	bcs.b	NoCommand
	sub.b	#$3E,D2
	bra.b	SkipCom
NoCommand
	moveq	#0,D2
SkipCom
	move.b	3(A0),D3
	rts

PeriodTable
	dc.w	$650
	dc.w	$650
	dc.w	$650
	dc.w	$650
	dc.w	$650
	dc.w	$650
	dc.w	$650
	dc.w	$650
	dc.w	$650
	dc.w	$650
	dc.w	$650
	dc.w	$650
	dc.w	$64A+6
	dc.w	$5F0+4
	dc.w	$59A+6
	dc.w	$54A+2
	dc.w	$4FE+2
	dc.w	$4B6+2
	dc.w	$473+1
	dc.w	$433+1
	dc.w	$3F6+2
	dc.w	$3BD+3
	dc.w	$388+2
	dc.w	$355+3
	dc.w	$325+3
	dc.w	$2F8+2
	dc.w	$2CD+3
	dc.w	$2A5+1
	dc.w	$27F+1
	dc.w	$25B+1
	dc.w	$239+1
	dc.w	$219+1
	dc.w	$1FB+1
	dc.w	$1DF+1
	dc.w	$1C4+1
	dc.w	$1AA+2
	dc.w	$193+1
	dc.w	$17C+1
	dc.w	$167+1
	dc.w	$152+1
	dc.w	$13F+1
	dc.w	$12E
	dc.w	$11D
	dc.w	$10D
	dc.w	$FE
	dc.w	$EF+1
	dc.w	$E2
	dc.w	$D5+1
	dc.w	$C9+1
	dc.w	$BE
	dc.w	$B3+1
	dc.w	$A9+1
	dc.w	$A0
	dc.w	$97
	dc.w	$8E+1
	dc.w	$86+1
	dc.w	$7F

PATINFO
	movem.l	D0/D1/A0-A3,-(SP)
	lea	PATTERNINFO(PC),A0
	move.w	8(A1),PI_Pattpos(A0)	; Current Position in Pattern
	move.w	6(A1),D1
	move.w	D1,PI_Songpos(A0)
	move.w	14(A1),D0
	and.w	#15,D0
	move.w	D0,PI_Speed(A0)		; Speed Value
	move.l	lbL010F98(PC),A0
	lsl.w	#3,D1
	lea	(A0,D1.W),A0
	move.l	lbL010FA8(PC),A1
	lea	STRIPE1(PC),A3
	moveq	#0,D0
	move.b	(A0),D0
	addq.l	#2,A0
	lsl.l	#8,D0
	lea	(A1,D0.L),A2
	move.l	A2,(A3)+
	moveq	#0,D0
	move.b	(A0),D0
	addq.l	#2,A0
	lsl.l	#8,D0
	lea	(A1,D0.L),A2
	move.l	A2,(A3)+
	moveq	#0,D0
	move.b	(A0),D0
	addq.l	#2,A0
	lsl.l	#8,D0
	lea	(A1,D0.L),A2
	move.l	A2,(A3)+

	move.l	lbL010F90(PC),A0
	lea	(A0,D1.W),A0
	moveq	#0,D0
	move.b	(A0),D0
	addq.l	#2,A0
	lsl.l	#8,D0
	lea	(A1,D0.L),A2
	move.l	A2,(A3)+
	moveq	#0,D0
	move.b	(A0),D0
	addq.l	#2,A0
	lsl.l	#8,D0
	lea	(A1,D0.L),A2
	move.l	A2,(A3)+
	moveq	#0,D0
	move.b	(A0),D0
	addq.l	#2,A0
	lsl.l	#8,D0
	lea	(A1,D0.L),A2
	move.l	A2,(A3)+
	moveq	#0,D0
	move.b	(A0),D0
	addq.l	#2,A0
	lsl.l	#8,D0
	lea	(A1,D0.L),A2
	move.l	A2,(A3)

	movem.l	(SP)+,D0/D1/A0-A3
	rts

***************************************************************************
******************************* DTP_NextPatt ******************************
***************************************************************************

NextPattern
	move.l	dtg_StopInt(A5),A0
	jsr	(A0)
	lea	lbW010E2C(PC),A1
	clr.w	8(A1)
	move.w	#1,2(A1)
	addq.w	#1,6(A1)
	move.w	$10(A1),D5
	cmp.w	6(A1),D5
	bne.b	NoMaxPos
	bsr.w	SongEnd
	move.l	lbL010F94(PC),A0
	move.b	1(A0),7(A1)
	clr.b	6(A1)
NoMaxPos
	move.l	dtg_StartInt(A5),A0
	jsr	(A0)
	rts

***************************************************************************
******************************* DTP_PrevPatt ******************************
***************************************************************************

PrevPattern
	lea	lbW010E2C(PC),A1
	tst.b	7(A1)
	beq.b	MinPos
	move.l	dtg_StopInt(A5),A0
	jsr	(A0)
	clr.w	8(A1)
	move.w	#1,2(A1)
	subq.w	#1,6(A1)
	move.l	dtg_StartInt(A5),A0
	jsr	(A0)
MinPos
	rts

***************************************************************************
******************************* EP_SampleInit *****************************
***************************************************************************

SampleInit
	moveq	#EPR_NotEnoughMem,D7
	lea	EPG_SampleInfoStructure(A5),A3
	move.l	ModulePtr(pc),D0
	beq.w	return
	move.l	D0,A2

	move.l	64(A2),D5
	beq.b	NoSynth
	subq.l	#1,D5
Synth
	jsr	ENPP_AllocSampleStruct(A5)
	move.l	D0,(A3)
	beq.b	return
	move.l	D0,A3

	MOVE.W	#USITY_AMSynth,EPS_Type(A3)

	dbf	D5,Synth
NoSynth
	move.l	68(A2),D5
	beq.b	NoNormal
	subq.l	#1,D5
	sub.l	72(A2),A2
	add.l	InfoBuffer+CalcSize(PC),A2
	lea	-256(A2),A2
	move.l	SampleInfoPtr(PC),A1
	move.l	A2,A0

Normal
	jsr	ENPP_AllocSampleStruct(A5)
	move.l	D0,(A3)
	beq.b	return
	move.l	D0,A3

	move.l	A0,A2
	move.l	4(A1),D1
	sub.l	(A1),D1
	add.l	(A1),A2

	move.l	A2,EPS_Adr(A3)			; sample address
	move.l	D1,EPS_Length(A3)		; sample length
	move.l	#64,EPS_Volume(A3)
	move.w	#USITY_RAW,EPS_Type(A3)
	move.w	#USIB_Playable!USIB_Saveable!USIB_8BIT,EPS_Flags(A3)

	lea	32(A1),A1
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
	move.w	CurrentPos(PC),D0
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
Length		=	36
SamplesSize	=	44
SongSize	=	52
Samples		=	60
Pattern		=	68
SynthSamples	=	76
PlayFrequency	=	84

InfoBuffer
	dc.l	MI_SubSongs,0		;4
	dc.l	MI_LoadSize,0		;12
	dc.l	MI_Calcsize,0		;20
	dc.l	MI_SongName,SongName	;28
	dc.l	MI_Length,0		;36
	dc.l	MI_SamplesSize,0	;44
	dc.l	MI_Songsize,0		;52
	dc.l	MI_Samples,0		;60
	dc.l	MI_Pattern,0		;68
	dc.l	MI_SynthSamples,0	;76
	dc.l	MI_PlayFrequency,0	;84
	dc.l	MI_MaxSamples,32
	dc.l	MI_MaxPattern,256
	dc.l	MI_MaxLength,128
	dc.l	MI_MaxSynthSamples,32
	dc.l	MI_MaxVoices,7
	dc.l	MI_Voices,7
	dc.l	MI_MaxSubSongs,4
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
	cmp.l	#lbL00FF7A,A6
	beq.b	Exit0
	and.w	#$7F,D1
	mulu.w	LeftVolume(PC),D1
	lsr.w	#6,D1
Exit0
	move.w	D1,8(A6)
	rts

*------------------------------- Set Vol -------------------------------*

SetVol
	move.l	A0,-(A7)
	lea	StructAdr+UPS_Voice1Vol(PC),A0
	cmp.l	#$DFF0A0,A6
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice2Vol(PC),A0
	cmp.l	#$DFF0B0,A6
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice3Vol(PC),A0
	cmp.l	#$DFF0C0,A6
	bne.s	Exit1
.SetVoice
	move.w	D1,(A0)
Exit1
	move.l	(A7)+,A0
	rts

*------------------------------- Set Adr -------------------------------*

SetAdr
	move.l	A0,-(A7)
	lea	StructAdr+UPS_Voice1Adr(PC),A0
	cmp.l	#$DFF0A0,A6
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice2Adr(PC),A0
	cmp.l	#$DFF0B0,A6
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice3Adr(PC),A0
	cmp.l	#$DFF0C0,A6
	bne.s	Exit2
.SetVoice
	move.l	D0,(A0)
	move.w	$10(A5),UPS_Voice1Per(A0)
Exit2
	move.l	(A7)+,A0
	rts

*------------------------------- Set Len -------------------------------*

SetLen
	move.l	A0,-(A7)
	lea	StructAdr+UPS_Voice1Len(PC),A0
	cmp.l	#$DFF0A0,A6
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice2Len(PC),A0
	cmp.l	#$DFF0B0,A6
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice3Len(PC),A0
	cmp.l	#$DFF0C0,A6
	bne.s	Exit3
.SetVoice
	move.w	D1,(A0)
Exit3
	move.l	(A7)+,A0
	rts

***************************************************************************
******************************* DTP_Check2 ********************************
***************************************************************************

Check2
	movea.l	dtg_ChkData(A5),A0
	moveq	#-1,D0

	lea	text(PC),A1
	moveq	#$19,D6
test	move.b	(A1)+,D2
	cmp.b	(A0)+,D2
	bne.b	Fault
	dbra	D6,test	
	moveq	#0,D0
Fault
	rts
text
	dc.b	' MUGICIAN2/SOFTEYES 1990'
	dc.w	1

***************************************************************************
***************************** DTP_SubSongRange ****************************
***************************************************************************

SubSongRange
	moveq	#0,D0
	move.l	InfoBuffer+SubSongs(PC),D1
	subq.l	#1,D1
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

	move.l	ModulePtr(PC),A0

	move.l	#460,D0
	lea	204(A0),A1
	moveq	#0,D1
	lea	26(A0),A0
	move.w	(A0)+,D1
	move.l	D1,Pattern(A4)
	lsl.l	#8,D1
	add.l	D1,D0
	moveq	#0,D1
	moveq	#7,D2
NextLength
	add.l	(A0)+,D1
	dbf	D2,NextLength
	lsl.l	#3,D1
	add.l	D1,D0
	add.l	D1,A1
	move.l	A1,A2
	move.l	(A0)+,D1
	lsl.l	#4,D1
	add.l	D1,D0
	add.l	D1,A2
	move.l	(A0)+,D1
	move.l	D1,SynthSamples(A4)
	lsl.l	#7,D1
	add.l	D1,D0
	add.l	D1,A2
	move.l	A2,(A6)				; SampleInfoPtr
	move.l	(A0)+,D1
	move.l	D1,Samples(A4)
	lsl.l	#5,D1
	add.l	D1,D0
	move.l	D0,SongSize(A4)
	move.l	(A0),D1
	move.l	D1,SamplesSize(A4)
	add.l	D1,D0
	move.l	D0,CalcSize(A4)
	cmp.l	LoadSize(A4),D0
	ble.b	SizeOK
	moveq	#EPR_ModuleTooShort,D0		; error message
	rts
SizeOK	
	moveq	#4,D0
Dalej
	lea	-16(A1),A2
	moveq	#3,D1
SubCheck
	tst.l	(A2)+
	bne.b	FoundSub
	dbf	D1,SubCheck
	subq.l	#1,D0
	lea	-16(A1),A1
	bra.b	Dalej
FoundSub
	move.l	D0,SubSongs(A4)

	bsr.w	lbC010B32			; init tables

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

	lea	lbW010AC8(PC),A0
	lea	lbC010B00(PC),A1
	moveq	#1,D0
	move.w	D0,(A0)+
	move.w	D0,(A0)+
	move.w	D0,(A0)+
	move.w	D0,(A0)+
Clear
	clr.l	(A0)+
	cmp.l	A0,A1
	bne.b	Clear

	moveq	#0,D0
	move.w	dtg_SndNum(A5),D0
	move.l	D0,D1
	lsl.w	#1,D0
	move.l	ModulePtr(PC),A0
	lea	28(A0),A1
	lea	80(A0),A0
	lea	SongName(PC),A2
NextSong
	move.l	(A1),D2
	move.l	(A0)+,(A2)
	move.l	(A0)+,4(A2)
	move.l	(A0)+,8(A2)
	lea	20(A0),A0
	addq.l	#8,A1
	dbf	D1,NextSong

	lea	InfoBuffer(PC),A4
	move.l	D2,Length(A4)
	move.w	MixRate(PC),D1			; D1 = mixing rate
	move.w	D1,PlayFrequency+2(A4)
	bsr.b	InitData
	bra.w	Init

InitData
	move.w	D1,D3
	mulu.w	#350,D1
	mulu.w	#1000,D1			; * 1kHz
	divu.w	#17633,D1
	addq.w	#1,D1
	bclr	#0,D1
	move.w	D1,D2
	lsr.w	#1,D2
	lea	MixLength(PC),A0
	lea	LoopCounter(PC),A1
	subq.w	#1,D1
	move.w	D2,(A0)
	move.w	D1,(A1)
	lea	PeriodsTable(PC),A0
	add.w	D3,D3
	move.w	0(A0,D3.W),D1
	lea	lbW010BD2(PC),A0		; period
	move.w	D1,(A0)
	rts

MixLength
	dc.w	0
LoopCounter
	dc.w	0

PeriodsTable
	dc.w	0
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
	dc.w	149			; 24		24023	-> ~24kHz
	dc.w	143			; 25		25031	-> ~25kHz
	dc.w	138			; 26		25938	-> ~26kHz
	dc.w	133			; 27		26913	-> ~27kHz
	dc.w	128			; 28		27965	-> ~28kHz
;	dc.w	124			; 29		28867	-> Maximum


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
	dc.b	'Mugician II Aud3 Interrupt',0,0
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

	move.w	#$400,$DFF09A
	move.w	#$400,$DFF09C
	move.l	lbL01097E(PC),$DFF0D0
	move.w	MixLength(PC),$DFF0D4
	move.l	lbL01097E(PC),UPS_Voice4Adr(A0)
	move.w	MixLength(PC),UPS_Voice4Len(A0)

	bsr.w	Play

	move.w	#$8400,$DFF09A
	move.w	RightVolume(PC),$DFF0D8

	lea	StructAdr(PC),A0
	move.w	RightVolume(PC),UPS_Voice4Vol(A0)
	move.w	lbW010BD2(PC),UPS_Voice4Per(A0)
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

***************************************************************************
*************************** Mugician II player ****************************
***************************************************************************

; Player from game "Clock Wiser"

;	BSR.W	lbC00F8C2			; Init
;	BSR.W	lbC00FB18			; Play
;	BSR.W	lbC00FAAE			; End

;lbW00F7D4	dc.w	1			; 0 for 4 voices player

lbC00F7D6
;	MOVEQ	#0,D7
;	LEA	MUGICIAN2SOFT.MSG0(PC),A0

;	move.l	ModulePtr(PC),A1

;	LEA	mod,A1
;	MOVEQ	#$17,D6
;lbC00F7E4	MOVE.B	(A0)+,D2
;	CMP.B	(A1)+,D2
;	BNE.W	lbC00F8A4
;	DBRA	D6,lbC00F7E4

	moveq	#0,D6

	MOVEQ	#0,D4
	MOVE.W	D0,D4
	MOVE.W	D4,D6
	ASL.W	#4,D6
;	LEA	mod+76,A4
;	LEA	mod,A5

	move.l	ModulePtr(PC),A5
	lea	76(A5),A4

	LEA	lbL010F94(PC),A6
	MOVE.L	A4,(A6)
	ADD.L	D6,(A6)
	LEA	$80(A4),A4
	LEA	$1C(A5),A2
	MOVEQ	#0,D2
	MOVE.W	D4,D1
	ADDQ.W	#1,D1
	MOVEQ	#7,D5
lbC00F81C	MOVE.L	(A2)+,D3
	ASL.L	#3,D3
	CMP.W	D2,D4
	BNE.W	lbC00F82A
	MOVE.L	A4,4(A6)
lbC00F82A	CMP.W	D2,D1
	BNE.W	lbC00F836
	MOVE.L	A4,lbL010F90
lbC00F836	ADDQ.W	#1,D2
	LEA	0(A4,D3.L),A4
	DBRA	D5,lbC00F81C
	MOVE.L	$3C(A5),D3
	ASL.L	#4,D3
	MOVE.L	A4,8(A6)
	LEA	0(A4,D3.L),A4
	MOVE.L	$40(A5),D3
	ASL.L	#7,D3
	MOVE.L	A4,$10(A6)
	LEA	0(A4,D3.L),A4
	MOVE.L	$44(A5),D3
	MOVE.L	A4,$18(A6)
	ASL.L	#5,D3
	LEA	0(A4,D3.L),A4
	MOVEQ	#0,D3
	MOVE.W	$1A(A5),D3
	ASL.L	#8,D3
	MOVE.L	A4,$14(A6)
	LEA	0(A4,D3.L),A4
	MOVE.L	A4,$1C(A6)
	MOVE.L	$48(A5),D3
	LEA	0(A4,D3.L),A4
	TST.W	$18(A5)
	BEQ.W	lbC00F894
	MOVE.L	A4,12(A6)
	RTS

lbC00F894	MOVE.L	A4,12(A6)
	MOVE.W	#$FF,D7
lbC00F89C	CLR.B	(A4)+
	DBRA	D7,lbC00F89C
	RTS

;lbC00F8A4	MOVEQ	#-1,D7
;	RTS

;MUGICIAN2SOFT.MSG0	dc.b	' MUGICIAN2/SOFTEYES 1990'

;lbC00F8C0	RTS

Init
lbC00F8C2
	BSET	#1,$BFE001
	LEA	lbW010E38(PC),A0
	MOVE.W	D0,(A0)
	BSR.W	lbC00F7D6
;	CMPI.W	#$FFFF,D7
;	BEQ.W	lbC00F8C0
;	JSR	lbC010B32
	LEA	lbL010E40(pc),A0
	MOVEQ	#$53,D7
lbC00F8EA	CLR.L	(A0)+
	DBRA	D7,lbC00F8EA
	LEA	lbW010E2C(PC),A0
	CLR.L	(A0)+
	CLR.W	(A0)+
	ADDQ.W	#2,A0
	CLR.L	(A0)+
	MOVE.W	#$7C,$DFF0A6
	MOVE.W	#$7C,$DFF0B6
	MOVE.W	#$7C,$DFF0C6
	MOVE.W	#2,$DFF0A4
	MOVE.W	#2,$DFF0B4
	MOVE.W	#2,$DFF0C4
;	MOVE.L	#lbL0111B4,$DFF0D0
;	MOVE.W	#$AF,$DFF0D4

	move.l	lbL01097A(PC),A0
	move.l	A0,$DFF0D0
	move.w	MixLength(PC),D7
	move.w	D7,$DFF0D4
	subq.w	#1,D7

	MOVE.W	lbW010BD2(pc),$DFF0D6
	MOVE.W	#$40,$DFF0D8
;	LEA	lbL0111B4,A0
;	MOVE.W	#$AE,D7
lbC00F95A	CLR.W	(A0)+
	DBRA	D7,lbC00F95A
	MOVE.W	#0,$DFF0A8
	MOVE.W	#0,$DFF0B8
	MOVE.W	#0,$DFF0C8
	MOVE.W	#15,$DFF096		; turn off DMA channels
	MOVEQ	#6,D7
	LEA	lbL010E40(pc),A0
	LEA	lbL010E40(pc),A1
lbC00F98E	MOVE.W	lbW010E38(pc),D0
	CMPI.W	#3,D7
	BHI.W	lbC00F9A8
;	TST.W	lbW00F7D4
;	BEQ.W	lbC00F9A8
	ADDQ.W	#1,D0
lbC00F9A8	MOVE.W	D0,(A0)+
	CLR.W	(A0)+
	CLR.W	(A0)+
	CLR.W	(A0)+
	CLR.W	(A0)+
	CLR.W	(A0)+
	CLR.W	(A0)+
	CLR.W	(A0)+
	CLR.W	(A0)+
	CLR.W	(A0)+
	CLR.W	(A0)+
	CLR.W	(A0)+
	CLR.W	(A0)+
	CLR.W	(A0)+
	CLR.W	(A0)+
	CLR.W	(A0)+
	CLR.W	(A0)+
	CLR.W	(A0)+
	CLR.W	(A0)+
	LEA	$30(A1),A1
	LEA	(A1),A0
	DBRA	D7,lbC00F98E
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVE.W	lbW010E38(pc),D0
	ASL.W	#4,D0
	MOVEA.L	lbL010F94(pc),A0
	MOVE.B	3(A0),D1
	MOVE.W	D1,lbW010E3C
	MOVE.B	2(A0),D1
	MOVE.W	D1,lbW010E2C
	MOVE.B	D1,D0
	ANDI.B	#15,D0
	ANDI.B	#15,D1
	ASL.B	#4,D0
	OR.B	D0,D1
	MOVE.W	D1,lbW010E3A
	MOVE.W	#1,lbW010E2E
	MOVE.W	#1,lbW010E30
	MOVE.W	#$40,lbW010E3E
	CLR.W	lbW010E34
	CLR.W	lbW010E32
;	TST.W	lbW00FA9C
;	BNE.W	lbC00FA5A
;	TST.W	lbW00F7D4
;	BNE.W	lbC00FA5C
;	MOVE.W	#15,$DFF096		; wylacza DMA kanalow dzwiekowych
;	MOVE.W	#1,lbW00FA9C
;lbC00FA5A	RTS

lbC00FA5C
;	LEA	lbC00FB18(PC),A0
;	LEA	lbW00FCC4(PC),A1
;	MOVE.L	$70,2(A1)	; zapamietuje old vector i skacze do niego
				; po wykonaniu aktualnego przerwania,
				; raczej napewno zbedne

;	MOVE.L	A0,$70		; nie mozna pod systemem zapisywac nowa wartosc
				; na stonie zerowej (adresy od 0 do $100),
				; trzeba zastapic to tak jak w Benn Daglish
				; przez SetIntVector ktora to funkcja uzywa struktury
				; IS (Interrupt Structure) i wyglada tak

; STRUCTURE  IS,LN_SIZE
;    APTR    IS_DATA
;    APTR    IS_CODE
;    LABEL   IS_SIZE

; jak widac struktura ta na poczatku zawiera rowniez strukture LN (list node)
; wygladajaca tak

;   STRUCTURE	LN,0	; List Node
;	APTR	LN_SUCC	; Pointer to next (successor)
;	APTR	LN_PRED	; Pointer to previous (predecessor)
;	UBYTE	LN_TYPE
;	BYTE	LN_PRI	; Priority, for sorting
;	APTR	LN_NAME	; ID string, null terminated
;	LABEL	LN_SIZE	; Note: word aligned

; czyli struktura IS dokladnie wyglada tak

;    STRUCTURE  IS,0
;	APTR	LN_SUCC	; Pointer to next (successor)
;	APTR	LN_PRED	; Pointer to previous (predecessor)
;	UBYTE	LN_TYPE
;	BYTE	LN_PRI	; Priority, for sorting
;	APTR	LN_NAME	; ID string, null terminated
;	APTR    IS_DATA
;	APTR    IS_CODE
;	LABEL   IS_SIZE

; jako LN_TYPE podajesz NT_INTERRUPT (ktore jest = 2, zobacz w asm Benn'a)

; IS_CODE musi wskazywac kod ktory normalnie byl zapisywany pod adres $70
; w tym przypadku

; czyli kod mogl by wygladac tak

;	movem.l	D0/A6,-(A7)
;	lea	InterruptStructAud3(PC),A1
;	moveq	#INTB_AUD3,D0
;	move.l	4.W,A6			; baza biblioteki exec do A6
;	jsr	_LVOSetIntVector(A6)
;	move.l	D0,OldIntVector
;	movem.l	(A7)+,D0/A6

; w ten sposob bardzo elegancko podczepisz nowe przerwanie pod system
; a nie tak brutalnie przez zapis pod $70. tak to sobie moze gra
; wywolywac przerwania, ale nie system.

;	MOVE.W	#15,$DFF096		; wylacza (15 bit skasowany) DMA kanalow dzwiekowych
;	MOVE.W	#1,lbW00FA9C
;	MOVE.W	#$8400,$DFF09A		; uaktywnia przerwanie AUD3
;	MOVE.W	#$380,$DFF09A		; wylacza przerwania AUD0-2 (dla kanalow 0-2)
;	MOVE.W	#$8008,$DFF096		; uaktywnia (bo 15 bit jest ustawiony) DMA dla kanalu 3
	RTS

;OldIntVector
;	dc.l	0

;InterruptStructAud3
;	dc.l	0
;	dc.l	0
;	dc.b	NT_INTERRUPT
;	dc.b	5			; priority
;	dc.l	NameAud3
;	dc.l	0
;	dc.l	InterruptAud3
;NameAud3
;	dc.b	'Mugician II Aud3 Interrupt',0
;	even			; oznacza ze nastepne dane rozpoczna sie od
				; parzystego adresu (mozna rowniez uzyc
				; CNOP 0,2 lub ALIGN cos tam)

;lbW00FA9C	dc.w	0
;	dc.w	0
;lbW00FAA0	dc.w	0			; Voice 1 on/off
;lbW00FAA2	dc.w	0			; Voice 2 on/off
;lbW00FAA4	dc.w	0			; Voice 3 on/off
;lbW00FAA6	dc.w	0			; Voice 4 on/off
;lbW00FAA8	dc.w	0			; Voice 5 on/off
;lbW00FAAA	dc.w	0			; Voice 6 on/off
;lbW00FAAC	dc.w	0			; Voice 7 on/off

;lbC00FAAE	MOVE.W	#15,$DFF096
;	TST.W	lbW00FA9C
;	BEQ.W	lbC00FADC
;	TST.W	lbW00F7D4
;	BNE.W	lbC00FAF4
;	CLR.W	lbW00FA9C
;	LEA	lbC00FCBC(PC),A1
;	MOVE.L	2(A1),$6C		; a to tu po co? zeby zgurowac system
					; raz a porzadnie ? na przerwaniu VLB
					; obslugiwany jest pointer myszy itp.

;lbC00FAF4	CLR.W	lbW00FA9C
;	MOVE.W	#$400,$DFF09A		; no tak, jak w ten sposob wylaczysz
;	MOVE.W	#$400,$DFF09C		; przerwanie AUD3 to system moze sie obrazic
;	MOVE.L	lbL00FCC6,$70		; przywrocenie old vectora przerwania AUDIO

; zamiast powyzszego nalezy uzyc

;	moveq	#INTB_AUD3,D0
;	move.l	OldIntVector(PC),A1
;	move.l	A6,-(A7)
;	move.l	4.W,A6
;	jsr	_LVOSetIntVector(a6)
;	move.l	(A7)+,A6

;	BRA.W	lbC00FADC

;lbC00FADC	LEA	lbL010E40,A0
;	MOVEQ	#$53,D7
;lbC00FAE4	CLR.L	(A0)+
;	DBRA	D7,lbC00FAE4
;	MOVE.W	#15,$DFF096
;	RTS


;InterruptAud3
;lbC00FB18	MOVE.W	#$780,$DFF09C
;	TST.W	lbW00F7D4
;	BNE.W	lbC00FCCE
;	MOVEM.L	D0-D7/A0-A6,-(SP)
;	MOVE.L	#$80808080,lbL010296
;	MOVE.L	#lbL010296,lbL010292
;	BSR.W	lbC010902
;	LEA	lbW010E2C,A1
;	LEA	$DFF0A0,A6
;	LEA	lbL010E40,A5
;	MOVE.W	#1,10(A1)
;	MOVEQ	#0,D6
;	TST.W	lbW00FAA0
;	BNE.W	lbC00FB74
;	MOVEA.L	lbL010F98(pc),A0
;	BSR.W	lbC00FF9A
;lbC00FB74	LEA	$10(A6),A6
;	LEA	$30(A5),A5
;	MOVEQ	#2,D6
;	MOVE.W	D6,10(A1)
;	TST.W	lbW00FAA2
;	BNE.W	lbC00FB96
;	MOVEA.L	lbL010F98(pc),A0
;	BSR.W	lbC00FF9A
;lbC00FB96	LEA	$10(A6),A6
;	LEA	$30(A5),A5
;	MOVEQ	#4,D6
;	MOVE.W	D6,10(A1)
;	TST.W	lbW00FAA4
;	BNE.W	lbC00FBB8
;	MOVEA.L	lbL010F98(pc),A0
;	BSR.W	lbC00FF9A
;lbC00FBB8	LEA	$10(A6),A6
;	LEA	$30(A5),A5
;	MOVE.W	#8,10(A1)
;	MOVEQ	#6,D6
;	TST.W	lbW00FAA6
;	BNE.W	lbC00FBDC
;	MOVEA.L	lbL010F98(pc),A0
;	BSR.W	lbC00FF9A
;lbC00FBDC	LEA	$DFF0A0,A6
;	LEA	lbL010E40,A5
;	BSR.W	lbC01029E
;	LEA	$10(A6),A6
;	LEA	$30(A5),A5
;	BSR.W	lbC01029E
;	LEA	$10(A6),A6
;	LEA	$30(A5),A5
;	BSR.W	lbC01029E
;	LEA	$10(A6),A6
;	LEA	$30(A5),A5
;	BSR.W	lbC01029E

Play
;lbC00FCCE	MOVEM.L	D0-D7/A0-A6,-(SP)
	MOVE.L	#$80808080,lbL010296
	MOVE.L	#lbL010296,lbL010292
	BSR.W	lbC010902
	LEA	lbW010E2C(pc),A1
	LEA	$DFF0A0,A6
	LEA	lbL010E40(pc),A5
	MOVE.W	#1,10(A1)
	MOVEQ	#0,D6
;	TST.W	lbW00FAA0
;	BNE.W	lbC00FD18
	MOVEA.L	lbL010F98(pc),A0
	BSR.W	lbC00FF9A
;lbC00FD18	MOVE.W	#$8008,$DFF096
	LEA	$10(A6),A6
	LEA	$30(A5),A5
	MOVEQ	#2,D6
	MOVE.W	D6,10(A1)
;	TST.W	lbW00FAA2
;	BNE.W	lbC00FD42
	MOVEA.L	lbL010F98(pc),A0
	BSR.W	lbC00FF9A
lbC00FD42	LEA	$10(A6),A6
	LEA	$30(A5),A5
	MOVEQ	#4,D6
	MOVE.W	D6,10(A1)
;	TST.W	lbW00FAA4
;	BNE.W	lbC00FD64
	MOVEA.L	lbL010F98(pc),A0
	BSR.W	lbC00FF9A
lbC00FD64	LEA	lbL00FF7A(pc),A6
	LEA	$30(A5),A5
;	MOVE.W	#0,10(A1)

	clr.w	10(A1)

	MOVEQ	#0,D6
	MOVE.L	#lbL00FF8E,lbL00FF8A
	CLR.L	lbL00FF8E
	CLR.L	lbL00FF92
	CLR.L	lbL00FF96
;	TST.W	lbW00FAA6
;	BNE.W	lbC00FDD6
	MOVEA.L	lbL010F90(pc),A0
	BSR.W	lbC00FF9A
	TST.L	lbL00FF8E
;	BEQ.W	lbC00FDD6

	beq.b	lbC00FDD6

	MOVE.L	lbL00FF8E(pc),lbL010AD0
	MOVE.L	lbL00FF92(pc),lbL010AE0
	MOVE.L	lbL00FF96(pc),lbL010AF0
;	MOVE.W	#0,lbW010AC8

	clr.w	lbW010AC8

lbC00FDD6	LEA	$30(A5),A5
;	MOVE.W	#0,10(A1)

	clr.w	10(A1)

	MOVEQ	#2,D6
	MOVE.L	#lbL00FF8E,lbL00FF8A
	CLR.L	lbL00FF8E
	CLR.L	lbL00FF92
	CLR.L	lbL00FF96
;	TST.W	lbW00FAA8
;	BNE.W	lbC00FE42
	MOVEA.L	lbL010F90(pc),A0
	BSR.W	lbC00FF9A
	TST.L	lbL00FF8E
;	BEQ.W	lbC00FE42

	beq.b	lbC00FE42

	MOVE.L	lbL00FF8E(pc),lbL010AD4
	MOVE.L	lbL00FF92(pc),lbL010AE4
	MOVE.L	lbL00FF96(pc),lbL010AF4
;	MOVE.W	#0,lbW010ACA

	clr.w	lbW010ACA

lbC00FE42	LEA	$30(A5),A5
;	MOVE.W	#0,10(A1)

	clr.w	10(A1)

	MOVEQ	#4,D6
	MOVE.L	#lbL00FF8E,lbL00FF8A
	CLR.L	lbL00FF8E
	CLR.L	lbL00FF92
	CLR.L	lbL00FF96
;	TST.W	lbW00FAAA
;	BNE.W	lbC00FEAE
	MOVEA.L	lbL010F90(pc),A0
	BSR.W	lbC00FF9A
	TST.L	lbL00FF8E
;	BEQ.W	lbC00FEAE

	beq.b	lbC00FEAE

	MOVE.L	lbL00FF8E(pc),lbL010AD8
	MOVE.L	lbL00FF92(pc),lbL010AE8
	MOVE.L	lbL00FF96(pc),lbL010AF8
;	MOVE.W	#0,lbW010ACC

	clr.w	lbW010ACC

lbC00FEAE	LEA	$30(A5),A5
;	MOVE.W	#0,10(A1)

	clr.w	10(A1)

	MOVEQ	#6,D6
	MOVE.L	#lbL00FF8E,lbL00FF8A
	CLR.L	lbL00FF8E
	CLR.L	lbL00FF92
	CLR.L	lbL00FF96
;	TST.W	lbW00FAAC
;	BNE.W	lbC00FF1A
	MOVEA.L	lbL010F90(pc),A0
	BSR.W	lbC00FF9A
	TST.L	lbL00FF8E
;	BEQ.W	lbC00FF1A

	beq.b	lbC00FF1A

	MOVE.L	lbL00FF8E(pc),lbL010ADC
	MOVE.L	lbL00FF92(pc),lbL010AEC
	MOVE.L	lbL00FF96(pc),lbL010AFC
;	MOVE.W	#0,lbW010ACE

	clr.w	lbW010ACE

lbC00FF1A	LEA	$DFF0A0,A6
	LEA	lbL010E40(pc),A5
	BSR.W	lbC01029E
	LEA	$10(A6),A6
	LEA	$30(A5),A5
	BSR.W	lbC01029E
	LEA	$10(A6),A6
	LEA	$30(A5),A5
	BSR.W	lbC01029E
	LEA	lbL00FF7A(pc),A6
	LEA	$30(A5),A5
	BSR.W	lbC01029E
	LEA	$30(A5),A5
	BSR.W	lbC01029E
	LEA	$30(A5),A5
	BSR.W	lbC01029E
	LEA	$30(A5),A5
	BSR.W	lbC01029E
	MOVEM.L	D0-D7/A0-A6,-(SP)
	BSR.W	lbC010982
	MOVEM.L	(SP)+,D0-D7/A0-A6
;	BRA.W	lbC00FC10

lbC00FC10	CLR.L	2(A1)
;	SUBI.W	#1,(A1)
;	BNE.W	lbC00FC9E

	subq.w	#1,(A1)
	bne.b	lbC00FC9E

	MOVE.W	14(A1),(A1)
	ANDI.W	#15,(A1)
	MOVE.W	14(A1),D5
	ANDI.W	#15,D5
	MOVE.W	14(A1),D0
	ANDI.W	#$F0,D0
	ASR.W	#4,D0
	ASL.W	#4,D5
	OR.W	D0,D5
	MOVE.W	D5,14(A1)
	MOVE.W	#1,4(A1)
;	ADDI.W	#1,8(A1)

	addq.w	#1,8(A1)

	MOVE.W	$12(A1),D5
	CMPI.W	#$40,8(A1)
;	BEQ.W	lbC00FC60

	beq.b	lbC00FC60

	CMP.W	8(A1),D5
;	BNE.W	lbC00FC9E

	bne.b	lbC00FC9E

lbC00FC60	CLR.W	8(A1)
	MOVE.W	#1,2(A1)
;	ADDI.W	#1,6(A1)

	addq.w	#1,6(A1)

	MOVE.W	$10(A1),D5
	CMP.W	6(A1),D5
;	BNE.W	lbC00FC9E

	bne.b	lbC00FC9E
	bsr.w	SongEnd

;	LEA	lbL010F94,A0
;	MOVEQ	#0,D0
;	TST.B	0(A0,D0.L)
;	MOVE.B	#2,7(A1)

	move.l	lbL010F94(PC),A0
	move.b	1(A0),7(A1)

	CLR.B	6(A1)
;	BRA.W	lbC00FC9E

;	BSR.W	lbC00FAAE
;	BRA.W	lbC00FCA6

lbC00FC9E
;	MOVE.W	#$800F,$DFF096

	bsr.w	PATINFO
	move.w	#$8007,$DFF096

;lbC00FCA6	MOVEM.L	(SP)+,D0-D7/A0-A6
;	TST.W	lbW00F7D4
;	BRA.W	lbC00FCC2

;	MOVE.L	lbL00FCC6,-(SP)		; po co to ?
	RTS

;lbC00FCBC	JMP	0		; a ten co tu robi ?

;lbC00FCC2	RTE			; przerwanie obslugiwane przez system
					; nie moze sie konczyc przez RTE,ale
					; zwyklym RTS

;lbW00FCC4	dc.w	0
;lbL00FCC6	dc.l	0
;	dc.w	0
;lbW00FCCC	dc.w	0

;lbW00FF78	dc.w	0
lbL00FF7A	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbL00FF8A	dc.l	lbL00FF8E
lbL00FF8E	dc.l	0
lbL00FF92	dc.l	0
lbL00FF96	dc.l	0

lbC00FF9A	MOVEQ	#0,D0
	TST.W	2(A1)
;	BEQ.W	lbC00FFBC

	beq.b	lbC00FFBC

	MOVE.W	(A5),D0
	ROR.W	#6,D0
	MOVE.W	6(A1),D0
	ASL.W	#3,D0
	ADD.W	D0,D6
	MOVE.B	0(A0,D6.L),3(A5)
	MOVE.B	1(A0,D6.L),9(A5)
lbC00FFBC	TST.W	4(A1)
	BEQ.W	lbC0101E4
	MOVEA.L	lbL010FA8(pc),A0
	MOVE.W	2(A5),D0
	ASL.W	#8,D0
;	LEA	0(A0,D0.L),A0

	add.l	D0,A0

	MOVE.W	8(A1),D0
	ASL.W	#2,D0
	TST.B	0(A0,D0.L)
	BEQ.W	lbC0101E4
;	MOVE.W	lbW00FF78,D1
;	OR.W	10(A1),D1
;	MOVE.W	D1,lbW00FF78
;	LEA	0(A0,D0.L),A0

	add.l	D0,A0

	CMPI.B	#$4A,2(A0)
;	BEQ.W	lbC010018

	beq.b	lbC010018

	MOVE.B	(A0),7(A5)
	TST.B	1(A0)
;	BEQ.W	lbC010018

	beq.b	lbC010018

	MOVE.B	1(A0),5(A5)
;	SUBI.B	#1,5(A5)

	subq.b	#1,5(A5)

lbC010018	ANDI.B	#$3F,5(A5)
	CLR.B	15(A5)
	CMPI.B	#$40,2(A0)
;	BCS.W	lbC01003C

	bcs.b	lbC01003C

	MOVE.B	2(A0),15(A5)
	SUBI.B	#$3E,15(A5)
;	BRA.W	lbC010042

	bra.b	lbC010042

lbC01003C	MOVE.B	#1,15(A5)
lbC010042	MOVE.B	3(A0),13(A5)
	MOVEA.L	lbL010F9C(pc),A4
	MOVE.W	4(A5),D0
	ASL.W	#4,D0
;	LEA	0(A4,D0.L),A4

	add.l	D0,A4

	MOVE.B	8(A4),$13(A5)
	CMPI.B	#12,15(A5)
;	BEQ.W	lbC0100A4

	beq.b	lbC0100A4

	MOVE.B	2(A0),11(A5)
	CMPI.B	#1,15(A5)
;	BNE.W	lbC0100D0

	bne.b	lbC0100D0

	LEA	lbL0113C2(pc),A2
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVE.B	11(A5),D1
	MOVE.W	8(A5),D0
	EXT.W	D0
	ADD.W	D0,D1
	MOVE.W	$12(A5),D0
	ASL.W	#7,D0
;	LEA	0(A2,D0.L),A2

	add.l	D0,A2

	ADD.W	D1,D1
	MOVE.W	0(A2,D1.L),$2A(A5)
;	BRA.W	lbC0100D0

	bra.b	lbC0100D0

lbC0100A4	MOVE.B	(A0),11(A5)
	LEA	lbL0113C2(pc),A2
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVE.B	11(A5),D1
	MOVE.W	8(A5),D0
	EXT.W	D0
	ADD.W	D0,D1
	MOVE.W	$12(A5),D0
	ASL.W	#7,D0
;	LEA	0(A2,D0.L),A2

	add.l	D0,A2

	ADD.W	D1,D1
	MOVE.W	0(A2,D1.L),$2A(A5)
lbC0100D0	MOVEA.L	lbL010F9C(pc),A4
	MOVE.W	4(A5),D0
	ASL.W	#4,D0
;	LEA	0(A4,D0.L),A4

	add.l	D0,A4

	MOVE.B	8(A4),$13(A5)
	CMPI.B	#11,15(A5)
;	BNE.W	lbC0100FC

	bne.b	lbC0100FC

	MOVE.B	13(A5),4(A4)
	ANDI.B	#7,4(A4)
lbC0100FC	MOVEQ	#0,D1
	MOVEA.L	lbL010FA4(pc),A3
	MOVE.B	(A4),D1
	CMPI.B	#12,15(A5)
	BEQ.W	lbC0101AA
	CMPI.B	#$20,D1
	BCC.W	lbC010896
	ASL.W	#7,D1
;	LEA	0(A3,D1.L),A3

	add.l	D1,A3

	MOVE.L	A3,(A6)

	move.l	D0,-(A7)
	move.l	A3,D0
	bsr.w	SetAdr
	move.l	(A7)+,D0

	MOVEQ	#0,D1
	MOVE.B	1(A4),D1
	MOVE.W	D1,4(A6)

	bsr.w	SetLen

	CMPI.B	#12,15(A5)
;	BEQ.W	lbC010146

	beq.b	lbC010146

	CMPI.B	#10,15(A5)
;	BEQ.W	lbC010146

	beq.b	lbC010146

	MOVE.W	10(A1),$DFF096
lbC010146
;	TST.W	lbW00FCCC
;	BNE.W	lbC0101AA
	TST.B	11(A4)
;	BEQ.W	lbC0101AA

	beq.b	lbC0101AA

	CMPI.B	#2,15(A5)
;	BEQ.W	lbC0101AA

	beq.b	lbC0101AA

	CMPI.B	#4,15(A5)
;	BEQ.W	lbC0101AA

	beq.b	lbC0101AA

	CMPI.B	#12,15(A5)
;	BEQ.W	lbC0101AA

	beq.b	lbC0101AA

	MOVEQ	#0,D0
	MOVE.B	12(A4),D0
	ASL.W	#7,D0
	MOVEA.L	lbL010FA4(pc),A3
;	LEA	0(A3,D0.L),A3

	add.l	D0,A3

	MOVEQ	#0,D0
	MOVE.B	(A4),D0
	ASL.W	#7,D0
	MOVEA.L	lbL010FA4(pc),A2
;	LEA	0(A2,D0.L),A2

	add.l	D0,A2

	CLR.B	6(A4)
	MOVEQ	#$1F,D7
lbC01019E	MOVE.L	(A3)+,(A2)+
	DBRA	D7,lbC01019E
	MOVE.B	14(A4),$29(A5)
lbC0101AA	CMPI.B	#3,15(A5)
;	BEQ.W	lbC0101D2

	beq.b	lbC0101D2

	CMPI.B	#4,15(A5)
;	BEQ.W	lbC0101D2

	beq.b	lbC0101D2

	CMPI.B	#12,15(A5)
;	BEQ.W	lbC0101D2

	beq.b	lbC0101D2

	MOVE.W	#1,$18(A5)
	CLR.W	$16(A5)
lbC0101D2	CLR.W	$2C(A5)
	MOVE.B	7(A4),$1D(A5)
	CLR.W	$1E(A5)
	CLR.W	$1A(A5)
lbC0101E4	CMPI.B	#5,15(A5)
;	BEQ.W	lbC01022C

	beq.b	lbC01022C

	CMPI.B	#6,15(A5)
;	BEQ.W	lbC010246

	beq.b	lbC010246

	CMPI.B	#7,15(A5)
;	BEQ.W	lbC010218

	beq.b	lbC010218

	CMPI.B	#8,15(A5)
;	BEQ.W	lbC010222

	beq.b	lbC010222

	CMPI.B	#13,15(A5)
;	BEQ.W	lbC01026A

	beq.b	lbC01026A

	RTS

lbC010218	BCLR	#1,$BFE001
	RTS

lbC010222	BSET	#1,$BFE001
	RTS

lbC01022C	MOVEQ	#0,D0
	MOVE.B	13(A5),D0
	TST.W	D0
	BEQ.W	lbC0104E6
	CMPI.W	#$40,D0
	BHI.W	lbC0104E6
	MOVE.W	D0,$12(A1)
	RTS

lbC010246	MOVEQ	#0,D0
	MOVE.B	13(A5),D0
	ANDI.W	#15,D0
	MOVE.B	D0,D1
	ASL.B	#4,D0
	OR.B	D1,D0
	TST.B	D1
	BEQ.W	lbC0104E6
	CMPI.B	#15,D1
	BHI.W	lbC0104E6
	MOVE.W	D0,14(A1)
	RTS

lbC01026A	CLR.B	15(A5)
	MOVEQ	#0,D0
	MOVE.B	13(A5),D0
	MOVE.B	D0,D1
	ANDI.B	#15,D1
	TST.B	D1
	BEQ.W	lbC0104E6
	MOVE.B	D0,D1
	ANDI.B	#$F0,D1
	TST.B	D1
	BEQ.W	lbC0104E6
	MOVE.W	D0,14(A1)
	RTS

lbL010292	dc.l	0
lbL010296	dc.l	0
	dc.l	0

lbC01029E	CMPI.B	#9,15(A5)
;	BNE.W	lbC0102B0

	bne.b	lbC0102B0

	BCHG	#1,$BFE001
lbC0102B0	MOVEQ	#0,D0
	MOVEA.L	lbL010F9C(pc),A4
	MOVE.W	4(A5),D0
	ASL.W	#4,D0
;	LEA	0(A4,D0.L),A4

	add.l	D0,A4

;	TST.W	lbW00FCCC
;	BNE.W	lbC010358
	MOVEM.L	D0-D7/A0-A6,-(SP)
	TST.B	11(A4)
	BEQ.W	lbC010354
	CMPI.B	#$20,(A4)
	BCC.W	lbC010354
	MOVEA.L	lbL010292(pc),A2
	LEA	lbL010296(pc),A3
	MOVEQ	#0,D0
	MOVE.B	5(A5),D0
	ADDQ.W	#1,D0
	CMP.B	(A3)+,D0
;	BEQ.W	lbC010354

	beq.b	lbC010354

	CMP.B	(A3)+,D0
;	BEQ.W	lbC010354

	beq.b	lbC010354

	CMP.B	(A3)+,D0
;	BEQ.W	lbC010354

	beq.b	lbC010354

	CMP.B	(A3)+,D0
;	BEQ.W	lbC010354

	beq.b	lbC010354

	MOVE.B	D0,(A2)+
;	ADDI.L	#1,lbL010292

	addq.l	#1,lbL010292

	TST.B	$29(A5)
;	BNE.W	lbC01034E

	bne.b	lbC01034E

	MOVE.B	14(A4),$29(A5)
	LEA	lbL0104E8(pc),A2
	MOVEQ	#0,D0
	MOVE.B	11(A4),D0
	ASL.W	#2,D0
	MOVEA.L	0(A2,D0.L),A2
	MOVEA.L	lbL010FA4(pc),A3
	MOVEQ	#0,D3
	MOVE.B	(A4),D3
	ASL.W	#7,D3
;	LEA	0(A3,D3.L),A3

	add.l	D3,A3

	JSR	(A2)
;	BRA.W	lbC010354

	bra.b	lbC010354

lbC01034E
;	SUBI.B	#1,$29(A5)

	subq.b	#1,$29(A5)

lbC010354	MOVEM.L	(SP)+,D0-D7/A0-A6
lbC010358	TST.W	$18(A5)
;	BEQ.W	lbC0103C6

	beq.b	lbC0103C6

;	SUBI.W	#1,$18(A5)

	subq.w	#1,$18(A5)

	TST.W	$18(A5)
;	BNE.W	lbC0103C6

	bne.b	lbC0103C6

	MOVE.B	3(A4),$19(A5)
;	ADDI.W	#1,$16(A5)

	addq.w	#1,$16(A5)

	ANDI.W	#$7F,$16(A5)
	TST.W	$16(A5)
;	BNE.W	lbC01039A

	bne.b	lbC01039A

	BTST	#1,15(A4)
;	BNE.W	lbC01039A

	bne.b	lbC01039A

	CLR.W	$18(A5)
;	BRA.W	lbC0103C6

	bra.b	lbC0103C6


lbC01039A	MOVE.W	$16(A5),D0
	MOVEQ	#0,D1
	MOVEA.L	lbL010FA4(pc),A3
	MOVE.B	2(A4),D1
	ASL.W	#7,D1
	ADD.W	D0,D1
;	LEA	0(A3,D1.L),A3

	add.l	D1,A3

	MOVEQ	#0,D1
	MOVE.B	(A3),D1
	ADDI.B	#$81,D1
	NEG.B	D1
	ASR.W	#2,D1
;	MOVE.W	D1,8(A6)

	bsr.w	ChangeVolume
	bsr.w	SetVol

	MOVE.W	D1,$24(A5)
lbC0103C6	LEA	lbL0113C2(pc),A2
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVE.W	6(A5),D1
	TST.B	4(A4)
;	BEQ.W	lbC010400

	beq.b	lbC010400

	MOVEA.L	lbL010FA0(pc),A3
	MOVE.B	4(A4),D0
	ASL.W	#5,D0
;	LEA	0(A3,D0.L),A3

	add.l	D0,A3

	MOVE.W	$1A(A5),D0
	ADD.B	0(A3,D0.L),D1
;	ADDI.W	#1,$1A(A5)

	addq.w	#1,$1A(A5)

	ANDI.W	#$1F,$1A(A5)
lbC010400	MOVE.W	8(A5),D0
	EXT.W	D0
	ADD.W	D0,D1
	MOVE.W	$12(A5),D0
	ASL.W	#7,D0
;	LEA	0(A2,D0.L),A2

	add.l	D0,A2

	ADD.W	D1,D1
	MOVE.W	0(A2,D1.L),$10(A5)
	MOVE.W	$10(A5),D3
	CMPI.B	#12,15(A5)
;	BEQ.W	lbC010432

	beq.b	lbC010432

	CMPI.B	#1,15(A5)
;	BNE.W	lbC01048A

	bne.b	lbC01048A

lbC010432	MOVE.W	12(A5),D0
	EXT.W	D0
	NEG.W	D0
	ADD.W	D0,$2C(A5)
	MOVE.W	$10(A5),D1
	ADD.W	$2C(A5),D1
	MOVE.W	D1,$10(A5)
	TST.W	12(A5)
;	BEQ.W	lbC01048A

	beq.b	lbC01048A

	BTST	#15,D0
;	BEQ.W	lbC010474

	beq.b	lbC010474

	CMP.W	$2A(A5),D1
;	BHI.W	lbC01048A

	bhi.b	lbC01048A

	MOVE.W	$2A(A5),D1
	SUB.W	D3,D1
	MOVE.W	D1,$2C(A5)
	CLR.W	12(A5)
;	BRA.W	lbC01048A

	bra.b	lbC01048A

lbC010474	CMP.W	$2A(A5),D1
;	BCS.W	lbC01048A

	bcs.b	lbC01048A

	MOVE.W	$2A(A5),D1
	SUB.W	D3,D1
	MOVE.W	D1,$2C(A5)
	CLR.W	12(A5)
lbC01048A	TST.B	5(A4)
;	BEQ.W	lbC0104E0

	beq.b	lbC0104E0

	TST.B	$1D(A5)
;	BEQ.W	lbC0104A4
;	SUBI.B	#1,$1D(A5)
;	BRA.W	lbC0104E0

	beq.b	lbC0104A4
	subq.b	#1,$1D(A5)
	bra.b	lbC0104E0

lbC0104A4	MOVEA.L	lbL010FA4(pc),A3
	MOVEQ	#0,D1
	MOVE.B	5(A4),D1
	ASL.W	#7,D1
;	LEA	0(A3,D1.L),A3

	add.l	D1,A3

	MOVE.W	$1E(A5),D1
;	ADDI.W	#1,$1E(A5)

	addq.w	#1,$1E(A5)

	ANDI.W	#$7F,$1E(A5)
	TST.W	$1E(A5)
;	BNE.W	lbC0104D4

	bne.b	lbC0104D4

	MOVE.B	9(A4),$1F(A5)
lbC0104D4	MOVE.B	0(A3,D1.L),D1
	EXT.W	D1
	NEG.W	D1
	ADD.W	D1,$10(A5)
lbC0104E0	MOVE.W	$10(A5),6(A6)
lbC0104E6	RTS

lbL0104E8
	dc.l	lbC0104E6
	dc.l	lbC010838
	dc.l	lbC01070C
	dc.l	lbC0107F2
	dc.l	lbC010802
	dc.l	lbC0106B2
	dc.l	lbC01069C
	dc.l	lbC010798
	dc.l	lbC0106CC
	dc.l	lbC01076A
	dc.l	lbC010850
	dc.l	lbC010568
	dc.l	lbC010602
	dc.l	lbC010876
	dc.l	lbC0107BC
	dc.l	lbC010816
	dc.l	lbC0104E6
	dc.l	lbC0104E6
	dc.l	lbC0104E6
	dc.l	lbC0104E6
	dc.l	lbC0104E6
	dc.l	lbC0104E6
	dc.l	lbC0104E6
	dc.l	lbC0104E6
	dc.l	lbC0104E6
	dc.l	lbC0104E6
	dc.l	lbC0104E6
	dc.l	lbC0104E6
	dc.l	lbC0104E6
	dc.l	lbC0104E6
	dc.l	lbC0104E6
	dc.l	lbC0104E6

lbC010568	MOVEQ	#0,D3
	MOVEA.L	lbL010FA4(pc),A0
	MOVE.B	12(A4),D3
	ASL.W	#7,D3
;	LEA	0(A0,D3.L),A0

	add.l	D3,A0

	MOVEQ	#0,D3
	MOVEA.L	lbL010FA4(pc),A2
	MOVE.B	13(A4),D3
	ASL.W	#7,D3
;	LEA	0(A2,D3.L),A2
;	ADDI.B	#1,6(A4)

	add.l	D3,A2
	addq.b	#1,6(A4)

	ANDI.B	#$7F,6(A4)
	MOVEQ	#0,D0
	MOVE.B	6(A4),D0
	CMPI.B	#$40,D0
;	BCC.W	lbC0105D2

	bcc.b	lbC0105D2

	MOVE.L	D0,D3
;	EORI.B	#$FF,D3

	not.b	D3

	ANDI.W	#$3F,D3
	MOVEQ	#0,D7
	MOVE.B	1(A4),D7
	ADD.B	D7,D7
	SUBQ.W	#1,D7
lbC0105BA	MOVE.B	(A0)+,D1
	MOVE.B	(A2)+,D2
	EXT.W	D1
	EXT.W	D2
	MULU.W	D0,D1
	MULU.W	D3,D2
	ADD.W	D1,D2
	ASR.W	#6,D2
	MOVE.B	D2,(A3)+
	DBRA	D7,lbC0105BA
	RTS

lbC0105D2	MOVEQ	#0,D7
	MOVE.B	1(A4),D7
	ADD.B	D7,D7
	SUBQ.W	#1,D7
	MOVEQ	#$7F,D3
	SUB.L	D0,D3
	MOVE.L	D3,D0
;	EORI.B	#$FF,D3

	not.b	D3

	ANDI.W	#$3F,D3
lbC0105EA	MOVE.B	(A0)+,D1
	MOVE.B	(A2)+,D2
	EXT.W	D1
	EXT.W	D2
	MULU.W	D0,D1
	MULU.W	D3,D2
	ADD.W	D1,D2
	ASR.W	#6,D2
	MOVE.B	D2,(A3)+
	DBRA	D7,lbC0105EA
	RTS

lbC010602	MOVEQ	#0,D3
	MOVEA.L	lbL010FA4(pc),A0
	MOVE.B	12(A4),D3
	ASL.W	#7,D3
;	LEA	0(A0,D3.L),A0

	add.l	D3,A0

	MOVEQ	#0,D3
	MOVEA.L	lbL010FA4(pc),A2
	MOVE.B	13(A4),D3
	ASL.W	#7,D3
;	LEA	0(A2,D3.L),A2
;	ADDI.B	#1,6(A4)

	add.l	D3,A2
	addq.b	#1,6(A4)

	ANDI.B	#$1F,6(A4)
	MOVEQ	#0,D0
	MOVE.B	6(A4),D0
	CMPI.B	#$10,D0
;	BCC.W	lbC01066C

	bcc.b	lbC01066C

	MOVE.L	D0,D3
;	EORI.B	#$FF,D3

	not.b	D3

	ANDI.W	#15,D3
	MOVEQ	#0,D7
	MOVE.B	1(A4),D7
	ADD.B	D7,D7
	SUBQ.W	#1,D7
lbC010654	MOVE.B	(A0)+,D1
	MOVE.B	(A2)+,D2
	EXT.W	D1
	EXT.W	D2
	MULU.W	D0,D1
	MULU.W	D3,D2
	ADD.W	D1,D2
	ASR.W	#4,D2
	MOVE.B	D2,(A3)+
	DBRA	D7,lbC010654
	RTS

lbC01066C	MOVEQ	#0,D7
	MOVE.B	1(A4),D7
	ADD.B	D7,D7
	SUBQ.W	#1,D7
	MOVEQ	#$1F,D3
	SUB.L	D0,D3
	MOVE.L	D3,D0
;	EORI.B	#$FF,D3

	not.b	D3

	ANDI.W	#15,D3
lbC010684	MOVE.B	(A0)+,D1
	MOVE.B	(A2)+,D2
	EXT.W	D1
	EXT.W	D2
	MULU.W	D0,D1
	MULU.W	D3,D2
	ADD.W	D1,D2
	ASR.W	#4,D2
	MOVE.B	D2,(A3)+
	DBRA	D7,lbC010684
	RTS

lbC01069C
;	LEA	(A3),A2

	move.l	A3,A2

	LEA	$80(A3),A3
	LEA	$40(A2),A2
	MOVEQ	#$3F,D7
lbC0106A8	MOVE.B	-(A2),-(A3)
	MOVE.B	(A2),-(A3)
	DBRA	D7,lbC0106A8
	RTS

lbC0106B2
;	LEA	(A3),A2
;	LEA	(A2),A0

	move.l	A3,A2
	move.l	A2,A0

	MOVEQ	#$3F,D7
lbC0106B8	MOVE.B	(A2)+,(A3)+
	ADDQ.W	#1,A2
	DBRA	D7,lbC0106B8
;	LEA	(A0),A2

	move.l	A0,A2

	MOVEQ	#$3F,D7
lbC0106C4	MOVE.B	(A2)+,(A3)+
	DBRA	D7,lbC0106C4
	RTS

lbC0106CC
;	ADDI.B	#1,6(A4)

	addq.b	#1,6(A4)

	ANDI.B	#$7F,6(A4)
	MOVEQ	#0,D1
	MOVE.B	6(A4),D1
	MOVEQ	#0,D3
	MOVEA.L	lbL010FA4(pc),A0
	MOVE.B	13(A4),D3
	ASL.W	#7,D3
;	LEA	0(A0,D3.L),A0

	add.l	D3,A0

	MOVEQ	#0,D0
	MOVE.B	1(A4),D0
	ADD.B	D0,D0
	SUBQ.W	#1,D0
	MOVE.B	0(A0,D1.L),D2
	MOVE.B	#3,D1
lbC010702	ADD.B	D1,(A3)+
	ADD.B	D2,D1
	DBRA	D0,lbC010702
	RTS

lbC01070C	MOVEQ	#0,D3
	MOVEA.L	lbL010FA4(pc),A0
	MOVE.B	12(A4),D3
	ASL.W	#7,D3
;	LEA	0(A0,D3.L),A0

	add.l	D3,A0

	MOVEQ	#0,D3
	MOVEA.L	lbL010FA4(pc),A2
	MOVE.B	13(A4),D3
	ASL.W	#7,D3
;	LEA	0(A2,D3.L),A2

	add.l	D3,A2

	MOVEQ	#0,D2
	MOVE.B	6(A4),D2
;	ADDI.B	#1,6(A4)

	addq.b	#1,6(A4)

	ANDI.B	#$7F,6(A4)
	MOVEQ	#0,D7
	MOVE.B	1(A4),D7
	ADD.B	D7,D7
	SUBQ.W	#1,D7
lbC01074C	MOVE.B	(A0)+,D0
	MOVE.B	0(A2,D2.L),D1
	EXT.W	D0
	EXT.W	D1
	ADD.W	D0,D1
	ASR.W	#1,D1
	MOVE.B	D1,(A3)+
;	ADDI.B	#1,D2

	addq.b	#1,D2

	ANDI.B	#$7F,D2
	DBRA	D7,lbC01074C
	RTS

lbC01076A	MOVEQ	#0,D3
	MOVEA.L	lbL010FA4(pc),A0
	MOVE.B	13(A4),D3
	ASL.W	#7,D3
;	LEA	0(A0,D3.L),A0

	add.l	D3,A0

	MOVEQ	#0,D7
	MOVE.B	1(A4),D7
	ADD.B	D7,D7
	SUBQ.W	#1,D7
lbC010786	MOVE.B	(A0)+,D0
	MOVE.B	(A3),D1
	EXT.W	D0
	EXT.W	D1
	ADD.W	D0,D1
	MOVE.B	D1,(A3)+
	DBRA	D7,lbC010786
	RTS

lbC010798	MOVEQ	#0,D0
	MOVE.B	6(A4),D0
	NEG.B	0(A3,D0.L)
;	ADDI.B	#1,6(A4)

	addq.b	#1,6(A4)

	MOVE.B	1(A4),D0
	ADD.B	D0,D0
	CMP.B	6(A4),D0
	BHI.W	lbC0104E6
	CLR.B	6(A4)
	RTS

lbC0107BC	MOVEQ	#0,D0
	MOVE.B	6(A4),D0
	NEG.B	0(A3,D0.L)
	MOVE.B	1(A4),D1
	ADD.B	13(A4),D0
	ADD.B	D1,D1
	SUBQ.W	#1,D1
	AND.B	D1,D0
	NEG.B	0(A3,D0.L)
;	ADDI.B	#1,6(A4)

	addq.b	#1,6(A4)

	MOVE.B	1(A4),D0
	ADD.B	D0,D0
	CMP.B	6(A4),D0
	BHI.W	lbC0104E6
	CLR.B	6(A4)
	RTS

lbC0107F2	MOVEQ	#$7E,D7
	MOVE.B	(A3),D0
lbC0107F6	MOVE.B	1(A3),(A3)+
	DBRA	D7,lbC0107F6
	MOVE.B	D0,(A3)+
	RTS

lbC010802	MOVEQ	#$7E,D7
	LEA	$80(A3),A3
	MOVE.B	-(A3),D0
lbC01080A	MOVE.B	-(A3),1(A3)
	DBRA	D7,lbC01080A
	MOVE.B	D0,(A3)
	RTS

lbC010816
;	LEA	(A3),A2
;	BSR.W	lbC010838
;	LEA	(A2),A3
;	ADDI.B	#1,6(A4)

	move.l	A3,A2
	bsr.b	lbC010838
	move.l	A2,A3
	addq.b	#1,6(A4)

	MOVE.B	6(A4),D0
	CMP.B	13(A4),D0
	BNE.W	lbC0104E6
	CLR.B	6(A4)
	BRA.W	lbC0106B2

lbC010838	MOVEQ	#$7E,D7
lbC01083A	MOVE.B	(A3),D0
	EXT.W	D0
	MOVE.B	1(A3),D1
	EXT.W	D1
	ADD.W	D0,D1
	ASR.W	#1,D1
	MOVE.B	D1,(A3)+
	DBRA	D7,lbC01083A
	RTS

lbC010850	LEA	$7E(A3),A2
	MOVEQ	#$7D,D7
	CLR.W	D2
lbC010858	MOVE.B	(A3)+,D0
	EXT.W	D0
	MOVE.W	D0,D1
	ADD.W	D0,D0
	ADD.W	D1,D0
	MOVE.B	1(A3),D1
	EXT.W	D1
	ADD.W	D0,D1
	ASR.W	#2,D1
	MOVE.B	D1,(A3)
	ADDQ.W	#1,D2
	DBRA	D7,lbC010858
	RTS

lbC010876	LEA	$7E(A3),A2
	MOVEQ	#$7D,D7
	CLR.W	D2
lbC01087E	MOVE.B	(A3)+,D0
	EXT.W	D0
	MOVE.B	1(A3),D1
	EXT.W	D1
	ADD.W	D0,D1
	ASR.W	#1,D1
	MOVE.B	D1,(A3)
	ADDQ.W	#1,D2
	DBRA	D7,lbC01087E
	RTS

lbC010896	SUBI.W	#$20,D1
	ASL.W	#5,D1
	MOVEA.L	lbL010FAC(pc),A3
;	LEA	0(A3,D1.L),A3

	add.l	D1,A3

	MOVE.L	A3,$20(A5)
	MOVE.W	#1,$14(A5)
	MOVEA.L	lbL010FB0(pc),A2
;	LEA	(A2),A0

	move.l	A2,A0

	ADDA.L	(A3),A0
	MOVE.L	A0,lbL00FF8E
	MOVE.L	A0,(A6)

	move.l	D0,-(A7)
	move.l	A0,D0
	bsr.w	SetAdr
	move.l	(A7)+,D0

	MOVE.L	4(A3),D1
	ADD.L	A2,D1
	MOVE.L	D1,lbL00FF92
	CLR.L	lbL00FF96
	MOVE.L	4(A3),D1
	TST.L	8(A3)
;	BEQ.W	lbC0108EA

	beq.b	lbC0108EA

	SUB.L	8(A3),D1
	MOVE.L	D1,lbL00FF96
lbC0108EA	MOVE.L	4(A3),D1
	SUB.L	(A3),D1
	ASR.L	#1,D1
	MOVE.W	D1,4(A6)

	bsr.w	SetLen

	MOVE.W	10(A1),$DFF096
	BRA.W	lbC0101AA

lbC010902	MOVEA.L	lbL010FB0(pc),A2
	LEA	lbL010E24,A4
	LEA	lbL010E40(pc),A5
	LEA	$DFF0A0,A6
;	MOVEQ	#3,D5
;	TST.W	lbW00F7D4
;	BEQ.W	lbC010928
	MOVEQ	#2,D5
lbC010928	TST.W	$14(A5)
;	BEQ.W	lbC010956

	beq.b	lbC010956

	CLR.W	$14(A5)
	MOVEA.L	$20(A5),A3
	TST.L	8(A3)
;	BEQ.W	lbC010964
;	LEA	(A2),A1

	beq.b	lbC010964
	move.l	A2,A1

	ADDA.L	8(A3),A1
	MOVE.L	A1,(A6)

	move.l	D0,-(A7)
	move.l	A1,D0
	bsr.w	SetAdr
	move.l	(A7)+,D0

	MOVE.L	4(A3),D1
	SUB.L	8(A3),D1
	ASR.L	#1,D1
	MOVE.W	D1,4(A6)

	bsr.w	SetLen

lbC010956	LEA	$30(A5),A5
	LEA	$10(A6),A6
	DBRA	D5,lbC010928
	RTS

lbC010964	MOVE.L	A4,(A6)
	MOVE.W	#4,4(A6)
	LEA	$30(A5),A5
	LEA	$10(A6),A6
	DBRA	D5,lbC010928
	RTS

lbL01097A	dc.l	lbL0111B4
lbL01097E	dc.l	lbL010FB4

lbC010982
;	MOVEA.L	lbL010AD0(pc),A0
;	MOVEA.L	lbL010AD4(pc),A1
;	MOVEA.L	lbL010AD8(pc),A2
;	MOVEA.L	lbL010ADC(pc),A3

	lea	EmptyBuffer,A4
	move.l	lbL010AD0(PC),D0
	bne.b	Ptr1OK
	move.l	A4,D0
Ptr1OK
	move.l	D0,A0
	move.l	lbL010AD4(PC),D0
	bne.b	Ptr2OK
	move.l	A4,D0
Ptr2OK
	move.l	D0,A1
	move.l	lbL010AD8(PC),D0
	bne.b	Ptr3OK
	move.l	A4,D0
Ptr3OK
	move.l	D0,A2
	move.l	lbL010ADC(PC),D0
	bne.b	Ptr4OK
	move.l	A4,D0
Ptr4OK
	move.l	D0,A3

	MOVE.L	lbL01097A(pc),D0
	MOVE.L	lbL01097E(pc),lbL01097A
	MOVE.L	D0,lbL01097E
	MOVEA.L	lbL01097A(pc),A4
;	MOVE.L	A4,$DFF0D0
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVE.W	lbW010BD2(pc),D0
	MOVE.W	lbL010EE0(pc),D1
	CMPI.W	#$7C,D1
;	BHI.W	lbC0109EA

	bhi.b	lbC0109EA

	MOVE.W	#1,lbW010AC8
;	MOVE.L	#0,lbL010BC2
;	BRA.W	lbC0109FE

	clr.l	lbL010BC2
	bra.b	lbC0109FE

lbC0109EA	BSR.W	lbC010B00
	MOVEQ	#0,D2
	MOVE.W	lbB010BC0(pc),D2
	ASL.L	#8,D2
	MOVE.L	D2,lbL010BC2
lbC0109FE	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVE.W	lbW010BD2(pc),D0
	MOVE.W	lbW010F10(pc),D1
	CMPI.W	#$7C,D1
;	BHI.W	lbC010A2C

	bhi.b	lbC010A2C

	MOVE.W	#1,lbW010ACA
;	MOVE.L	#0,lbL010BC6
;	BRA.W	lbC010A40

	clr.l	lbL010BC6
	bra.b	lbC010A40

lbC010A2C	BSR.W	lbC010B00
	MOVEQ	#0,D2
	MOVE.W	lbB010BC0(pc),D2
	ASL.L	#8,D2
	MOVE.L	D2,lbL010BC6
lbC010A40	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVE.W	lbW010BD2(pc),D0
	MOVE.W	lbW010F40(pc),D1
	CMPI.W	#$7C,D1
;	BHI.W	lbC010A6E

	bhi.b	lbC010A6E

	MOVE.W	#1,lbW010ACC
;	MOVE.L	#0,lbL010BCA
;	BRA.W	lbC010A82

	clr.l	lbL010BCA
	bra.b	lbC010A82

lbC010A6E	BSR.W	lbC010B00
	MOVEQ	#0,D2
	MOVE.W	lbB010BC0(pc),D2
	ASL.L	#8,D2
	MOVE.L	D2,lbL010BCA
lbC010A82	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVE.W	lbW010BD2(pc),D0
	MOVE.W	lbW010F70(pc),D1
	CMPI.W	#$7C,D1
;	BHI.W	lbC010AB0

	bhi.b	lbC010AB0

	MOVE.W	#1,lbW010ACE
;	MOVE.L	#0,lbL010BCE
;	BRA.W	lbC010AC4

	clr.l	lbL010BCE
	bra.b	lbC010AC4

lbC010AB0	BSR.W	lbC010B00
	MOVEQ	#0,D2
	MOVE.W	lbB010BC0(pc),D2
	ASL.L	#8,D2
	MOVE.L	D2,lbL010BCE
lbC010AC4	BRA.W	lbC010BD4

lbW010AC8	dc.w	1
lbW010ACA	dc.w	1
lbW010ACC	dc.w	1
lbW010ACE	dc.w	1
lbL010AD0	dc.l	0
lbL010AD4	dc.l	0
lbL010AD8	dc.l	0
lbL010ADC	dc.l	0
lbL010AE0	dc.l	0
lbL010AE4	dc.l	0
lbL010AE8	dc.l	0
lbL010AEC	dc.l	0
lbL010AF0	dc.l	0
lbL010AF4	dc.l	0
lbL010AF8	dc.l	0
lbL010AFC	dc.l	0

lbC010B00	TST.W	D0
	BEQ.W	lbC0104E6
	TST.W	D1
	BEQ.W	lbC0104E6
	ASL.L	#8,D1
	DIVU.W	D0,D1
	MOVE.L	#$100,D0
	DIVU.W	D1,D0
	MOVE.B	D0,lbB010BC0
	SWAP	D0
	ASL.L	#8,D0
	ANDI.L	#$FFFFFF,D0
	DIVU.W	D1,D0
	MOVE.B	D0,lbB010BC1
	RTS

lbC010B32	LEA	lbL011BB4,A0
	MOVE.W	#$80,D0
	MOVE.W	#$17F,D7
lbC010B40	MOVE.B	D0,(A0)+
	DBRA	D7,lbC010B40
	MOVE.W	#$FF,D7
lbC010B4A	MOVE.B	D0,(A0)+
;	ADDI.B	#1,D0

	addq.b	#1,D0

	DBRA	D7,lbC010B4A
;	SUBI.B	#1,D0

	subq.b	#1,D0

	MOVE.W	#$17F,D7
lbC010B5C	MOVE.B	D0,(A0)+
	DBRA	D7,lbC010B5C
	LEA	lbL011FB6,A0
	MOVEQ	#0,D0
	MOVEQ	#$3F,D7
lbC010B6C	MOVE.W	#$FF,D6
	MOVE.W	#$FF80,D5
	MOVE.W	#$80,D3
lbC010B78	MOVE.L	D5,D4
	MULS.W	D0,D4
	DIVS.W	#$3F,D4
	ADDI.B	#$80,D4
	MOVE.B	D4,0(A0,D3.W)
	CMPI.W	#$3F,D7
;	BEQ.W	lbC010BA4

	beq.b	lbC010BA4

	TST.W	D7
;	BEQ.W	lbC010BA4

	beq.b	lbC010BA4

	CMPI.W	#$80,D3
;	BCS.W	lbC010BA4
;	SUBI.B	#1,0(A0,D3.W)

	bcs.b	lbC010BA4
	subq.b	#1,0(A0,D3.W)

lbC010BA4	ADDQ.W	#1,D3
	ANDI.W	#$FF,D3
	ADDQ.W	#1,D5
	DBRA	D6,lbC010B78
	LEA	$100(A0),A0
	ADDQ.W	#1,D0
	DBRA	D7,lbC010B6C
	RTS

;lbL010BBC	dc.l	0
lbB010BC0	dc.b	0
lbB010BC1	dc.b	0
lbL010BC2	dc.l	0
lbL010BC6	dc.l	0
lbL010BCA	dc.l	0
lbL010BCE	dc.l	0
lbW010BD2	dc.w	$CB

lbC010BD4	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVEQ	#0,D2
	MOVEQ	#0,D3
	MOVEQ	#0,D4
	MOVEQ	#0,D5
;	MOVE.L	lbL010BC6(pc),lbL010D06
;	MOVE.L	lbL010BCA(pc),lbL010D10
;	MOVE.L	lbL010BCE(pc),lbL010D1A
	MOVE.W	lbL010EF4(pc),D0
	TST.W	lbW010AC8
;	BEQ.W	lbC010C10

	beq.b	lbC010C10

	MOVEQ	#0,D0
lbC010C10
;	ASL.L	#8,D0
;	LEA	lbL011FB6,A5
;	LEA	0(A5,D0.W),A5
;	SUBA.L	#lbL010CC4,A5
;	MOVE.W	A5,lbL010CC4

	asl.w	#8,D0
	lea	Base_A5(PC),A5
	move.w	D0,(A5)+

	MOVE.W	lbW010F24(pc),D0
	TST.W	lbW010ACA
;	BEQ.W	lbC010C3A

	beq.b	lbC010C3A

	MOVEQ	#0,D0
lbC010C3A
;	ASL.L	#8,D0
;	LEA	lbL011FB6,A5
;	LEA	0(A5,D0.W),A5
;	SUBA.L	#lbL010CD2,A5
;	MOVE.W	A5,lbL010CD2

	asl.w	#8,D0
	move.w	D0,(A5)+

	MOVE.W	lbW010F54(pc),D0
	TST.W	lbW010ACC
;	BEQ.W	lbC010C64

	beq.b	lbC010C64

	MOVEQ	#0,D0
lbC010C64
;	ASL.L	#8,D0
;	LEA	lbL011FB6,A5
;	LEA	0(A5,D0.W),A5
;	SUBA.L	#lbL010CE2,A5
;	MOVE.W	A5,lbL010CE2

	asl.w	#8,D0
	move.w	D0,(A5)+

	MOVE.W	lbW010F84(pc),D0
	TST.W	lbW010ACE
;	BEQ.W	lbC010C8E

	beq.b	lbC010C8E

	MOVEQ	#0,D0
lbC010C8E
;	ASL.L	#8,D0
;	LEA	lbL011FB6,A5
;	LEA	0(A5,D0.W),A5
;	SUBA.L	#lbL010CF0,A5
;	MOVE.W	A5,lbL010CF0
;	MOVE.L	SP,lbL010BBC
;	MOVEA.L	lbL010BC2(pc),SP
;	LEA	lbL011BB4,A5
;	MOVE.W	#$15D,D7
;	MOVEQ	#0,D6

	asl.w	#8,D0
	move.w	D0,(A5)+
	move.l	lbL010BC2(PC),D0
	swap	D0
	move.l 	D0,(A5)+
	move.l	lbL010BC6(PC),D0
	swap	D0
	move.l	D0,(A5)+
	move.l	lbL010BCA(PC),D0
	swap	D0
	move.l	D0,(A5)+
	move.l 	lbL010BCE(PC),D0
	swap	D0
	move.l	D0,(A5)+
	moveq	#0,D0
	lea	lbL011FB6,A6
	move.w	LoopCounter(PC),D7

lbC010CBE

	lea	-24(A5),A5
	move.w	(A5)+,D6

	MOVE.B	0(A0,D2.W),D6
;	LEA	lbL015EB6(PC),A6
;lbL010CC4	EQU	*-2
;	MOVEQ	#0,D0
	MOVE.B	0(A6,D6.W),D0

	move.l	D0,D1
	move.w	(A5)+,D6

	MOVE.B	0(A1,D3.W),D6
;	LEA	lbL015EB6(PC),A6
;lbL010CD2	EQU	*-2
;	MOVEQ	#0,D1
;	MOVE.B	0(A6,D6.W),D1

	move.b	0(A6,D6.W),D0

	ADD.W	D0,D1

	move.w	(A5)+,D6

	MOVE.B	0(A2,D4.W),D6
;	LEA	lbL015EB6(PC),A6
;lbL010CE2	EQU	*-2
	MOVE.B	0(A6,D6.W),D0
	ADD.W	D0,D1

	move.w	(A5)+,D6

	MOVE.B	0(A3,D5.W),D6
;	LEA	lbL015EB6(PC),A6
;lbL010CF0	EQU	*-2
	MOVE.B	0(A6,D6.W),D0
	ADD.W	D0,D1
;	MOVE.B	0(A5,D1.W),(A4)+
;	SWAP	D2
;	ADD.L	SP,D2

	move.b	lbL011BB4(PC,D1.W),(A4)+
	moveq	#0,D6
	add.l	(A5)+,D2
	addx.w	D6,D2

;	SWAP	D2
;	SWAP	D3
;	ADDI.L	#0,D3
;lbL010D06	EQU	*-4

	add.l	(A5)+,D3
	addx.w	D6,D3

;	SWAP	D3
;	SWAP	D4
;	ADDI.L	#0,D4
;lbL010D10	EQU	*-4

	add.l	(A5)+,D4
	addx.w	D6,D4

;	SWAP	D4
;	SWAP	D5
;	ADDI.L	#0,D5
;lbL010D1A	EQU	*-4
;	SWAP	D5

	add.l	(A5)+,D5
	addx.w	D6,D5

	DBRA	D7,lbC010CBE
;	MOVEA.L	lbL010BBC(pc),SP
;	LEA	0(A0,D2.W),A0
;	LEA	0(A1,D3.W),A1
;	LEA	0(A2,D4.W),A2
;	LEA	0(A3,D5.W),A3

	bra.w	SkipBuffer
lbL011BB4
	ds.b	1026
Base_A5
	ds.b	24

SkipBuffer
	add.w	D2,A0
	add.w	D3,A1
	add.w	D4,A2
	add.w	D5,A3

	MOVE.L	A0,lbL010AD0
	MOVE.L	A1,lbL010AD4
	MOVE.L	A2,lbL010AD8
	MOVE.L	A3,lbL010ADC
	CMPA.L	lbL010AE0(pc),A0
;	BCS.W	lbC010D7E

	bcs.b	lbC010D7E

;	TST.L	lbL010AF0
;	BEQ.W	lbC010D76


	MOVE.L	lbL010AF0(pc),D0

	beq.b	lbC010D76

	SUB.L	D0,lbL010AD0
;	BRA.W	lbC010D7E

	bra.b	lbC010D7E

lbC010D76	MOVE.W	#1,lbW010AC8
lbC010D7E	CMPA.L	lbL010AE4(pc),A1
;	BCS.W	lbC010DAA

	bcs.b	lbC010DAA

;	TST.L	lbL010AF4
;	BEQ.W	lbC010DA2


	MOVE.L	lbL010AF4(pc),D0

	beq.b	lbC010DA2

	SUB.L	D0,lbL010AD4
;	BRA.W	lbC010DAA

	bra.b	lbC010DAA

lbC010DA2	MOVE.W	#1,lbW010ACA
lbC010DAA	CMPA.L	lbL010AE8(pc),A2
;	BCS.W	lbC010DD6

	bcs.b	lbC010DD6

;	TST.L	lbL010AF8
;	BEQ.W	lbC010DCE

	MOVE.L	lbL010AF8(pc),D0

	beq.b	lbC010DCE

	SUB.L	D0,lbL010AD8
;	BRA.W	lbC010DD6

	bra.b	lbC010DD6


lbC010DCE	MOVE.W	#1,lbW010ACC
lbC010DD6	CMPA.L	lbL010AEC(pc),A3
;	BCS.W	lbC010E02

	bcs.b	lbC010E02

;	TST.L	lbL010AFC
;	BEQ.W	lbC010DFA

	MOVE.L	lbL010AFC(pc),D0

	beq.b	lbC010DFA

	SUB.L	D0,lbL010ADC
;	BRA.W	lbC010E02

	bra.b	lbC010E02

lbC010DFA	MOVE.W	#1,lbW010ACE
lbC010E02
;	LEA	$DFF000,A6
;	MOVE.W	#$AF,$D4(A6)
;	MOVE.W	lbW010BD2(pc),$D6(A6)
;	MOVE.W	#$40,$D8(A6)
;	MOVE.W	#$8008,$96(A6)
	RTS

lbW010E2C	dc.w	0
lbW010E2E	dc.w	0
lbW010E30	dc.w	0
CurrentPos
lbW010E32	dc.w	0
lbW010E34	dc.w	0
	dc.w	0
lbW010E38	dc.w	0
lbW010E3A	dc.w	5
lbW010E3C	dc.w	1
lbW010E3E	dc.w	$40
lbL010E40	dc.l	0
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
lbL010EE0	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbL010EF4	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbW010F10	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
lbW010F24	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
lbW010F40	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
lbW010F54	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
lbW010F70	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
lbW010F84	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
lbL010F90	dc.l	0
lbL010F94	dc.l	0
lbL010F98	dc.l	0
lbL010F9C	dc.l	0
lbL010FA0	dc.l	0
lbL010FA4	dc.l	0
lbL010FA8	dc.l	0
lbL010FAC	dc.l	0
lbL010FB0	dc.l	0
	dc.l	$12D911CA
	dc.l	$10CB0FD9
	dc.l	$EF60E1F
	dc.w	$D54
lbL0113C2	dc.l	$C940BE0
	dc.l	$B350A94
	dc.l	$9FC096C
	dc.l	$8E50865
	dc.l	$7ED077B
	dc.l	$70F06AA
	dc.l	$64A05F0
	dc.l	$59A054A
	dc.l	$4FE04B6
	dc.l	$4730433
	dc.l	$3F603BD
	dc.l	$3880355
	dc.l	$32502F8
	dc.l	$2CD02A5
	dc.l	$27F025B
	dc.l	$2390219
	dc.l	$1FB01DF
	dc.l	$1C401AA
	dc.l	$193017C
	dc.l	$1670152
	dc.l	$13F012E
	dc.l	$11D010D
	dc.l	$FE00EF
	dc.l	$E200D5
	dc.l	$C900BE
	dc.l	$B300A9
	dc.l	$A00097
	dc.l	$8E0086
	dc.l	$7F12EA
	dc.l	$11DB10DA
	dc.l	$FE80F03
	dc.l	$E2C0D60
	dc.l	$CA00BEB
	dc.l	$B3F0A9E
	dc.l	$A050975
	dc.l	$8ED086D
	dc.l	$7F40782
	dc.l	$71606B0
	dc.l	$65005F5
	dc.l	$5A0054F
	dc.l	$50304BB
	dc.l	$4770437
	dc.l	$3FA03C1
	dc.l	$38B0358
	dc.l	$32802FB
	dc.l	$2D002A7
	dc.l	$281025D
	dc.l	$23B021B
	dc.l	$1FD01E0
	dc.l	$1C501AC
	dc.l	$194017D
	dc.l	$1680154
	dc.l	$141012F
	dc.l	$11E010E
	dc.l	$FE00F0
	dc.l	$E300D6
	dc.l	$CA00BF
	dc.l	$B400AA
	dc.l	$A00097
	dc.l	$8F0087
	dc.l	$7F12FC
	dc.l	$11EB10EA
	dc.l	$FF70F11
	dc.l	$E390D6D
	dc.l	$CAC0BF6
	dc.l	$B4A0AA8
	dc.l	$A0E097E
	dc.l	$8F60875
	dc.l	$7FB0789
	dc.l	$71C06B6
	dc.l	$65605FB
	dc.l	$5A50554
	dc.l	$50704BF
	dc.l	$47B043A
	dc.l	$3FE03C4
	dc.l	$38E035B
	dc.l	$32B02FD
	dc.l	$2D202AA
	dc.l	$284025F
	dc.l	$23D021D
	dc.l	$1FF01E2
	dc.l	$1C701AE
	dc.l	$195017F
	dc.l	$1690155
	dc.l	$1420130
	dc.l	$11F010F
	dc.l	$FF00F1
	dc.l	$E400D7
	dc.l	$CB00BF
	dc.l	$B500AA
	dc.l	$A10098
	dc.l	$8F0087
	dc.l	$80130E
	dc.l	$11FC10F9
	dc.l	$10060F1F
	dc.l	$E460D79
	dc.l	$CB70C01
	dc.l	$B540AB1
	dc.l	$A180987
	dc.l	$8FE087D
	dc.l	$8030790
	dc.l	$72306BC
	dc.l	$65C0600
	dc.l	$5AA0559
	dc.l	$50C04C3
	dc.l	$47F043E
	dc.l	$40103C8
	dc.l	$392035E
	dc.l	$32E0300
	dc.l	$2D502AC
	dc.l	$2860262
	dc.l	$23F021F
	dc.l	$20101E4
	dc.l	$1C901AF
	dc.l	$1970180
	dc.l	$16B0156
	dc.l	$1430131
	dc.l	$1200110
	dc.l	$10000F2
	dc.l	$E400D8
	dc.l	$CB00C0
	dc.l	$B500AB
	dc.l	$A10098
	dc.l	$900088
	dc.l	$80131F
	dc.l	$120C1109
	dc.l	$10140F2D
	dc.l	$E530D85
	dc.l	$CC30C0C
	dc.l	$B5F0ABB
	dc.l	$A210990
	dc.l	$9060885
	dc.l	$80A0797
	dc.l	$72A06C3
	dc.l	$6620606
	dc.l	$5AF055E
	dc.l	$51104C8
	dc.l	$4830442
	dc.l	$40503CB
	dc.l	$3950361
	dc.l	$3310303
	dc.l	$2D802AF
	dc.l	$2880264
	dc.l	$2420221
	dc.l	$20301E6
	dc.l	$1CA01B1
	dc.l	$1980181
	dc.l	$16C0157
	dc.l	$1440132
	dc.l	$1210111
	dc.l	$10100F3
	dc.l	$E500D8
	dc.l	$CC00C1
	dc.l	$B600AC
	dc.l	$A20099
	dc.l	$900088
	dc.l	$811331
	dc.l	$121D1119
	dc.l	$10230F3B
	dc.l	$E610D92
	dc.l	$CCF0C17
	dc.l	$B690AC5
	dc.l	$A2B0998
	dc.l	$90F088C
	dc.l	$812079E
	dc.l	$73006C9
	dc.l	$667060B
	dc.l	$5B50563
	dc.l	$51504CC
	dc.l	$4870446
	dc.l	$40903CF
	dc.l	$3980364
	dc.l	$3340306
	dc.l	$2DA02B1
	dc.l	$28B0266
	dc.l	$2440223
	dc.l	$20401E7
	dc.l	$1CC01B2
	dc.l	$19A0183
	dc.l	$16D0159
	dc.l	$1450133
	dc.l	$1220112
	dc.l	$10200F4
	dc.l	$E600D9
	dc.l	$CD00C1
	dc.l	$B700AC
	dc.l	$A3009A
	dc.l	$910089
	dc.l	$811343
	dc.l	$122E1129
	dc.l	$10320F49
	dc.l	$E6E0D9E
	dc.l	$CDB0C22
	dc.l	$B740ACF
	dc.l	$A3409A1
	dc.l	$9170894
	dc.l	$81907A5
	dc.l	$73706CF
	dc.l	$66D0611
	dc.l	$5BA0568
	dc.l	$51A04D1
	dc.l	$48B044A
	dc.l	$40D03D2
	dc.l	$39B0368
	dc.l	$3370309
	dc.l	$2DD02B4
	dc.l	$28D0268
	dc.l	$2460225
	dc.l	$20601E9
	dc.l	$1CE01B4
	dc.l	$19B0184
	dc.l	$16E015A
	dc.l	$1460134
	dc.l	$1230113
	dc.l	$10300F5
	dc.l	$E700DA
	dc.l	$CE00C2
	dc.l	$B700AD
	dc.l	$A3009A
	dc.l	$910089
	dc.l	$821354
	dc.l	$123F1139
	dc.l	$10410F58
	dc.l	$E7B0DAB
	dc.l	$CE70C2D
	dc.l	$B7E0AD9
	dc.l	$A3D09AA
	dc.l	$91F089C
	dc.l	$82107AC
	dc.l	$73E06D6
	dc.l	$6730617
	dc.l	$5BF056D
	dc.l	$51F04D5
	dc.l	$490044E
	dc.l	$41003D6
	dc.l	$39F036B
	dc.l	$33A030B
	dc.l	$2E002B6
	dc.l	$28F026B
	dc.l	$2480227
	dc.l	$20801EB
	dc.l	$1CF01B5
	dc.l	$19D0186
	dc.l	$170015B
	dc.l	$1480135
	dc.l	$1240114
	dc.l	$10400F5
	dc.l	$E800DB
	dc.l	$CE00C3
	dc.l	$B800AE
	dc.l	$A4009B
	dc.l	$92008A
	dc.l	$821366
	dc.l	$12501149
	dc.l	$10500F66
	dc.l	$E890DB8
	dc.l	$CF30C39
	dc.l	$B890AE3
	dc.l	$A4709B3
	dc.l	$92808A4
	dc.l	$82807B3
	dc.l	$74406DC
	dc.l	$679061C
	dc.l	$5C50572
	dc.l	$52304DA
	dc.l	$4940452
	dc.l	$41403D9
	dc.l	$3A2036E
	dc.l	$33D030E
	dc.l	$2E202B9
	dc.l	$292026D
	dc.l	$24A0229
	dc.l	$20A01ED
	dc.l	$1D101B7
	dc.l	$19E0187
	dc.l	$171015C
	dc.l	$1490136
	dc.l	$1250115
	dc.l	$10500F6
	dc.l	$E900DB
	dc.l	$CF00C4
	dc.l	$B900AE
	dc.l	$A4009B
	dc.l	$92008A
	dc.l	$831378
	dc.l	$12611159
	dc.l	$105F0F74
	dc.l	$E960DC4
	dc.l	$CFF0C44
	dc.l	$B940AED
	dc.l	$A5009BC
	dc.l	$93008AC
	dc.l	$83007BA
	dc.l	$74B06E2
	dc.l	$67F0622
	dc.l	$5CA0577
	dc.l	$52804DE
	dc.l	$4980456
	dc.l	$41803DD
	dc.l	$3A60371
	dc.l	$3400311
	dc.l	$2E502BB
	dc.l	$294026F
	dc.l	$24C022B
	dc.l	$20C01EF
	dc.l	$1D301B9
	dc.l	$1A00188
	dc.l	$172015E
	dc.l	$14A0138
	dc.l	$1260116
	dc.l	$10600F7
	dc.l	$E900DC
	dc.l	$D000C4
	dc.l	$B900AF
	dc.l	$A5009C
	dc.l	$93008B
	dc.l	$83138A
	dc.l	$12721169
	dc.l	$106E0F82
	dc.l	$EA40DD1
	dc.l	$D0B0C4F
	dc.l	$B9E0AF7
	dc.l	$A5A09C5
	dc.l	$93908B4
	dc.l	$83707C1
	dc.l	$75206E9
	dc.l	$6850628
	dc.l	$5CF057C
	dc.l	$52D04E3
	dc.l	$49C045A
	dc.l	$41C03E1
	dc.l	$3A90374
	dc.l	$3430314
	dc.l	$2E802BE
	dc.l	$2960271
	dc.l	$24E022D
	dc.l	$20E01F0
	dc.l	$1D401BA
	dc.l	$1A1018A
	dc.l	$174015F
	dc.l	$14B0139
	dc.l	$1270117
	dc.l	$10700F8
	dc.l	$EA00DD
	dc.l	$D100C5
	dc.l	$BA00AF
	dc.l	$A6009C
	dc.l	$94008B
	dc.l	$83139C
	dc.l	$12831179
	dc.l	$107E0F91
	dc.l	$EB10DDE
	dc.l	$D170C5B
	dc.l	$BA90B02
	dc.l	$A6309CE
	dc.l	$94108BC
	dc.l	$83F07C8
	dc.l	$75906EF
	dc.l	$68B062D
	dc.l	$5D50581
	dc.l	$53204E7
	dc.l	$4A1045E
	dc.l	$41F03E4
	dc.l	$3AC0377
	dc.l	$3460317
	dc.l	$2EA02C0
	dc.l	$2990274
	dc.l	$250022F
	dc.l	$21001F2
	dc.l	$1D601BC
	dc.l	$1A3018B
	dc.l	$1750160
	dc.l	$14C013A
	dc.l	$1280118
	dc.l	$10800F9
	dc.l	$EB00DE
	dc.l	$D100C6
	dc.l	$BB00B0
	dc.l	$A6009D
	dc.l	$94008C
	dc.l	$8413AF
	dc.l	$12941189
	dc.l	$108D0F9F
	dc.l	$EBF0DEB
	dc.l	$D230C66
	dc.l	$BB40B0C
	dc.l	$A6D09D7
	dc.l	$94A08C4
	dc.l	$84607D0
	dc.l	$75F06F5
	dc.l	$6910633
	dc.l	$5DA0586
	dc.l	$53704EC
	dc.l	$4A50462
	dc.l	$42303E8
	dc.l	$3B0037B
	dc.l	$349031A
	dc.l	$2ED02C3
	dc.l	$29B0276
	dc.l	$2520231
	dc.l	$21201F4
	dc.l	$1D801BD
	dc.l	$1A4018D
	dc.l	$1760161
	dc.l	$14E013B
	dc.l	$1290119
	dc.l	$10900FA
	dc.l	$EC00DF
	dc.l	$D200C6
	dc.l	$BB00B1
	dc.l	$A7009D
	dc.l	$95008C
	dc.l	$8413C1
	dc.l	$12A51199
	dc.l	$109C0FAE
	dc.l	$ECC0DF8
	dc.l	$D2F0C72
	dc.l	$BBF0B16
	dc.l	$A7709E0
	dc.l	$95308CD
	dc.l	$84E07D7
	dc.l	$76606FC
	dc.l	$6980639
	dc.l	$5DF058B
	dc.l	$53B04F0
	dc.l	$4A90466
	dc.l	$42703EB
	dc.l	$3B3037E
	dc.l	$34C031C
	dc.l	$2F002C6
	dc.l	$29E0278
	dc.l	$2550233
	dc.l	$21401F6
	dc.l	$1DA01BF
	dc.l	$1A6018E
	dc.l	$1780163
	dc.l	$14F013C
	dc.l	$12A011A
	dc.l	$10A00FB
	dc.l	$ED00DF
	dc.l	$D300C7
	dc.l	$BC00B1
	dc.l	$A7009E
	dc.l	$95008D
	dc.l	$8513D3
	dc.l	$12B611A9
	dc.l	$10AC0FBC
	dc.l	$EDA0E05
	dc.l	$D3B0C7D
	dc.l	$BCA0B20
	dc.l	$A8009EA
	dc.l	$95B08D5
	dc.l	$85607DE
	dc.l	$76D0702
	dc.l	$69E063F
	dc.l	$5E50590
	dc.l	$54004F5
	dc.l	$4AE046A
	dc.l	$42B03EF
	dc.l	$3B70381
	dc.l	$34F031F
	dc.l	$2F202C8
	dc.l	$2A0027A
	dc.l	$2570235
	dc.l	$21501F8
	dc.l	$1DB01C1
	dc.l	$1A70190
	dc.l	$1790164
	dc.l	$150013D
	dc.l	$12B011B
	dc.l	$10B00FC
	dc.l	$EE00E0
	dc.l	$D400C8
	dc.l	$BD00B2
	dc.l	$A8009F
	dc.l	$96008D
	dc.l	$8513E5
	dc.l	$12C811BA
	dc.l	$10BB0FCB
	dc.l	$EE80E12
	dc.l	$D470C89
	dc.l	$BD50B2B
	dc.l	$A8A09F3
	dc.l	$96408DD
	dc.l	$85E07E5
	dc.l	$7740709
	dc.l	$6A40644
	dc.l	$5EA0595
	dc.l	$54504F9
	dc.l	$4B2046E
	dc.l	$42F03F3
	dc.l	$3BA0384
	dc.l	$3520322
	dc.l	$2F502CB
	dc.l	$2A3027D
	dc.l	$2590237
	dc.l	$21701F9
	dc.l	$1DD01C2
	dc.l	$1A90191
	dc.l	$17B0165
	dc.l	$151013E
	dc.l	$12C011C
	dc.l	$10C00FD
	dc.l	$EE00E1
	dc.l	$D400C9
	dc.l	$BD00B3
	dc.l	$A9009F
	dc.l	$96008E
	dc.w	$86

	Section	MixBuffer,BSS

lbL011FB6	ds.b	16128

lbL015EB6	ds.b	256

EmptyBuffer	ds.b	1024

	Section	PlayBuffer,BSS_C

lbL010E24	ds.b	8
lbL010FB4	ds.b	512+48			; extended buffer
lbL0111B4	ds.b	512+48			; extended buffer

	******************************************************
	****             Quartet replayer for	          ****
	****    EaglePlayer 2.00+ (Amplifier version),    ****
	****         all adaptions by Wanted Team	  ****
	******************************************************

	incdir	"dh2:include/"
	include 'misc/eagleplayer2.01.i'
	include	'misc/eagleplayerengine.i'
	include	'exec/exec_lib.i'

	SECTION	Player,CODE

	EPPHEADER Tags

	dc.b	'$VER: Quartet player module V2.0 (31 Dec 2006)',0
	even
Tags
	dc.l	DTP_PlayerVersion,2<<16!0
	dc.l	EP_PlayerVersion,11
	dc.l	DTP_PlayerName,PlayerName
	dc.l	DTP_Creator,Creator
	dc.l	EP_Check5,Check5
	dc.l	DTP_Interrupt,Interrupt
	dc.l	DTP_InitPlayer,InitPlayer
	dc.l	DTP_InitSound,InitSound
	dc.l	EP_NewModuleInfo,NewModuleInfo
	dc.l	DTP_ExtLoad,ExtLoad
	dc.l	EP_GetPositionNr,GetPosition
	dc.l	EP_SampleInit,SampleInit
	dc.l	EP_Flags,EPB_ModuleInfo!EPB_SampleInfo!EPB_Songend!EPB_Packable!EPB_Restart
	dc.l	EP_InitAmplifier,InitAudstruct
	dc.l	EP_EagleBase,EagleBase
	dc.l	TAG_DONE

PlayerName
	dc.b	'Quartet',0
Creator
	dc.b	'(c) 1990 by Dan Lennard,',10
	dc.b	'adapted by Wanted Team',0
Prefix
	dc.b	'QPA.',0
SampleName
	dc.b	'SMP.set',0
SMP
	dc.b	'SMP.',0
	even
ModulePtr
	dc.l	0
Tempo
	dc.w	0
MusicStart
	dc.l	0
Interrupts
	dc.l	0
SamplesPtr
	dc.l	0
LoopWord
	dc.w	0
Offsets
	dc.l	0

*------------------------------ Amplifier Tags ---------------------------*
EagleBase	dc.l	0
AudTagliste	dc.l	EPAMT_NumStructs,4
		dc.l	EPAMT_AudioStructs,AudStruct0
		dc.l	EPAMT_Flags
Aud_NoteFlags	dc.l	0
AudStruct0	ds.b	AS_Sizeof*4

***************************************************************************
****************************** EP_InitAmplifier ***************************
***************************************************************************

InitAudstruct
	moveq	#EPAMB_WaitForStruct!EPAMB_Direct!EPAMB_8Bit,d7
	moveq	#0,d0
	jsr	ENPP_GetListData(a5)
	tst.l	d0
	beq.s	.Error

	move.l	a0,a1
	move.l	4,a6
	jsr	_LVOTypeOfMem(a6)
	btst	#1,d0
	beq.s	.NoChip
	or.w	#EPAMB_ChipRam,d7
.NoChip
	lea	AudStruct0,a0		;Audio Struktur vorbereiten
	move.l	d7,Aud_NoteFlags-AudStruct0(a0)
	lea	(a0),a1
	move.w	#AS_Sizeof*4-1,d0
.Clr
	clr.b	(a1)+
	dbf	d0,.Clr

	move.w	#01,AS_LeftRight(a0)			;1. Kanal links
	move.w	#-1,AS_LeftRight+AS_Sizeof*1(a0)	;2. Kanal rechts
	move.w	#-1,AS_LeftRight+AS_Sizeof*2(a0)	;3. Kanal rechts
	move.w	#01,AS_LeftRight+AS_Sizeof*3(a0)	;4. Kanal links

	lea	AudTagliste(pc),a0
	move.l	a0,EPG_AmplifierTagList(a5)
	moveq	#0,d0
	rts
.Error
	moveq	#EPR_NoModuleLoaded,d0
	rts

*---------------------------------------------------------------------------*
* Input		D0 = Bitmask
PokeDMA
	movem.l	D0/D1,-(SP)
	move.w	D0,D1
	and.w	#$8000,D0	;D0.w neg=enable ; 0/pos=disable
	and.l	#15,D1		;D1 = Mask (LONG !!)
	jsr	ENPP_DMAMask(A5)
	movem.l	(SP)+,D0/D1
	rts

***************************************************************************
******************************* EP_SampleInit *****************************
***************************************************************************

SampleInit
	moveq	#EPR_NotEnoughMem,D7
	lea	EPG_SampleInfoStructure(A5),A3
	move.l	SamplesPtr(PC),D0
	beq.b	return
	move.l	D0,A2

	lea	SampleBase(PC),A1

	moveq	#15,D5
	moveq	#50,D2
Normal
	jsr	ENPP_AllocSampleStruct(A5)
	move.l	D0,(A3)
	beq.b	return
	move.l	D0,A3

	cmp.l	#'lock',4(A2)
	bne.b	NoBlock
	lea	16(A2),A2
NoBlock
	move.l	(A1)+,EPS_Adr(A3)			; sample address
	move.l	(A1)+,D1
	cmp.l	D2,D1
	bne.b	NoZero
	moveq	#0,D1
NoZero
	add.l	D1,D1
	move.l	D1,EPS_Length(A3)		; sample length
	move.l	#64,EPS_Volume(A3)
	move.l	A2,EPS_SampleName(A3)		; sample name
	move.w	#16,EPS_MaxNameLen(A3)
	move.w	#USITY_RAW,EPS_Type(A3)
	move.w	#USIB_Playable!USIB_Saveable!USIB_8BIT,EPS_Flags(A3)

	lea	16(A2),A2
	dbf	D5,Normal

	moveq	#0,D7
return
	move.l	D7,D0
	rts

***************************************************************************
******************************* DTP_ExtLoad *******************************
***************************************************************************

ExtLoad
	move.l	dtg_ChkData(A5),A1
	move.l	4.W,A6
	jsr	_LVOTypeOfMem(A6)
	moveq	#1,D6
	moveq	#0,D7
	btst	#1,D0
	beq.b	NoChip
	moveq	#2,D7
NoChip
	move.l	dtg_PathArrayPtr(A5),A0
	clr.b	(A0)
	move.l	dtg_CopyDir(A5),A0
	jsr	(A0)
	bsr.s	CopyName2
	move.l	D7,EPG_ARG1(A5)
	move.l	D6,EPG_ARGN(A5)
	jsr	ENPP_NewLoadFile(A5)
	tst.l	D0
	beq.b	ExtLoadOK
	move.l	dtg_PathArrayPtr(A5),A0
	clr.b	(A0)
	move.l	dtg_CopyDir(A5),A0
	jsr	(A0)
	bsr.b	CopyName
	move.l	D7,EPG_ARG1(A5)
	move.l	D6,EPG_ARGN(A5)
	jmp	ENPP_NewLoadFile(A5)

ExtLoadOK
	rts

CopyName
	movea.l	dtg_PathArrayPtr(A5),A0
loop1
	tst.b	(A0)+
	bne.s	loop1
	subq.l	#1,A0
	lea	SampleName(PC),A3
smp2
	move.b	(A3)+,(A0)+
	bne.s	smp2
	rts

CopyName2
	move.l	dtg_PathArrayPtr(A5),A0
loop
	tst.b	(A0)+
	bne.s	loop
	subq.l	#1,A0
	move.l	A0,A3
	move.l	dtg_FileArrayPtr(A5),A1
smp
	move.b	(A1)+,(A0)+
	bne.s	smp

	cmpi.b	#'Q',(A3)
	beq.b	Q_OK
	cmpi.b	#'q',(A3)
	bne.s	ExtError
Q_OK
	cmpi.b	#'P',1(A3)
	beq.b	P_OK
	cmpi.b	#'p',1(A3)
	bne.s	ExtError
P_OK
	cmpi.b	#'A',2(A3)
	beq.b	A_OK
	cmpi.b	#'a',2(A3)
	bne.s	ExtError
A_OK
	cmpi.b	#'.',3(A3)
	bne.s	ExtError

	move.b	#'S',(A3)+
	move.b	#'M',(A3)+
	move.b	#'P',(A3)

	bra.b	ExtOK
ExtError
	clr.b	-2(A0)
ExtOK
	clr.b	-1(A0)
	rts

***************************************************************************
********************************* EP_GetPosNr *****************************
***************************************************************************

GetPosition
	move.l	AudPos(PC),D0
	sub.l	MusicStart(PC),D0	
	lsr.l	#8,D0
	rts

***************************************************************************
******************************** EP_Check5 ********************************
***************************************************************************

Check5
	move.l	dtg_ChkData(A5),A0
	cmp.b	#$50,1(A0)
	bne.b	Fault
	cmp.b	#30,(A0)
	bhi.b	Fault
	moveq	#0,D1
	move.b	(A0),D1
	beq.b	Fault
	move.l	#3000,D2			; max. tempo
	divu.w	D1,D2
	swap	D2
	tst.w	D2
	bne.b	Fault
	move.l	dtg_ChkSize(A5),D2
	bclr	#0,D2
	add.l	D2,A0
	moveq	#15,D2
	moveq	#-1,D3
NextEnd
	move.w	-(A0),D1
	beq.b	Zero
	cmp.w	D3,D1
	beq.b	CheckEnd
Fault
	moveq	#-1,D0
	rts
Zero
	dbf	D2,NextEnd
	bra.b	Fault
CheckEnd
	cmp.l	-2(A0),D3
	bne.b	Fault
	cmp.l	-6(A0),D3
	bne.b	Fault
	moveq	#0,D0
	rts

***************************************************************************
***************************** EP_NewModuleInfo ****************************
***************************************************************************

NewModuleInfo

LoadSize	=	4
Length		=	12
SamplesSize	=	20
SongSize	=	28
Samples		=	36
CalcSize	=	44
Duration	=	52

InfoBuffer
	dc.l	MI_LoadSize,0		;4
	dc.l	MI_Length,0		;12
	dc.l	MI_SamplesSize,0	;20
	dc.l	MI_Songsize,0		;28
	dc.l	MI_Samples,0		;36
	dc.l	MI_Calcsize,0		;44
	dc.l	MI_Duration,0		;52
	dc.l	MI_MaxSamples,16
	dc.l	MI_Prefix,Prefix
	dc.l	0

***************************************************************************
***************************** DTP_Intterrupt ******************************
***************************************************************************

Interrupt	
	movem.l	D0-D7/A0-A6,-(SP)

	move.l	EagleBase(PC),A5
	bsr.w	DoPlay
	jsr	ENPP_Amplifier(A5)

	movem.l	(SP)+,D0-D7/A0-A6
	rts

SongEnd
	move.l	A1,-(A7)
	move.l	dtg_SongEnd(A5),A1
	jsr	(A1)
	move.l	(A7)+,A1
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
	lea	InfoBuffer(PC),A4
	move.l	D0,LoadSize(A4)
	move.l	A0,D1
	move.w	(A0)+,(A6)+			; Tempo
	move.l	A0,(A6)+			; MusicStart
	moveq	#-1,D0
FindEnd
	cmp.l	(A0)+,D0
	bne.b	FindEnd
	move.l	A0,D0
	sub.l	D1,D0
	addq.l	#4,D0

	move.l	D0,SongSize(A4)
	move.l	D0,CalcSize(A4)

	subq.l	#2,D0
	move.l	D0,D1
	lsr.l	#8,D0
	addq.l	#1,D0
	move.l	D0,Length(A4)

	moveq	#0,D0
	move.b	Tempo(PC),D0
	lsr.l	#3,D1
	move.l	D1,D2
	mulu.w	D0,D2
	move.l	D2,(A6)+			; Interrupts

	mulu.w	#$376B,D2			; dtg_Timer
	lsr.l	#4,D2
        move.l	#(709379-3)/16,D3		; PAL ex_EClockFrequency (in word size)
	divu.w	D3,D2
	move.w	D2,Duration+2(A4)

	moveq	#1,D0
	movea.l	dtg_GetListData(A5),A0
	jsr	(A0)

	cmp.l	#450,D0
	ble.b	Short
	btst	#0,D0
	bne.b	Corrupt
	cmp.l	#'lock',4(A0)
	bne.b	Corrupt

	move.l	A0,(A6)+			; SamplesPtr
	add.l	D0,LoadSize(A4)
	move.w	336(A0),(A6)+			; LoopWord
	lea	354(A0),A1
	move.l	A1,D1
	add.l	D0,A0
	lea	-64(A0),A0
	move.l	A0,(A6)				; Offsets
	lea	-32(A0),A1
	move.l	A1,A2
	moveq	#15,D2
	moveq	#0,D3
	moveq	#0,D4
	moveq	#0,D5
Next
	move.w	(A2)+,D3
	beq.b	NoSamp
	add.l	D3,D4
	addq.l	#2,D4
	addq.l	#1,D5
NoSamp
	dbf	D2,Next
	add.l	D4,D4
	subq.l	#2,D4
	add.l	#450,D4
	cmp.l	D0,D4
	bne.b	Short
	move.l	D5,Samples(A4)
	move.l	D4,SamplesSize(A4)
	add.l	D4,CalcSize(A4)

	bsr.w	SampleAddressMake

	moveq	#0,D0
	rts

Short
	moveq	#EPR_ModuleTooShort,D0
	rts

Corrupt
	moveq	#EPR_CorruptModule,D0
	rts

***************************************************************************
***************************** DTP_InitSound *******************************
***************************************************************************

InitSound
	bra.w	Init

***************************************************************************
****************************** Quartet player *****************************
***************************************************************************

; a few optimized replay source from Quartet editor (Amiga version)

***********  PLAY MODULE **********
******** ©1990 Dan Lennard ********     

; This is the source code for the Play routine. Once you have
; loaded your samples and music, use ' jsr Play ' to start
; your music running. Once 'Play' has been called the music is
; maintained by the Vertical Blanking interrupt. Music files are
; terminated with $ffff words and the routine below turns the music
; off when this point is reached. Since the $ffff words are placed
; right after the last note, you should terminate your final
; note with a dummy zero volume note. This should be placed far 
; enough away from the final note, so that it does not effect the
; final note's duration. So, if the final note of the music lasts
; for about three time periods, the dummy note would be placed
; three time periods after it. I've provided an alternative 
; 'TurnOffMusic' subroutine which loops the music; to use this
; remove all the semi-colons from the subroutine and remove the
; original 'TurnOffMusic' subroutine. 


; INSTRUCTIONS:
;
; To incorporate the Play subroutine in your program:
;
; Music: Firstly, change the Tempo and MusicStart Registers to
; reflect where you have loaded your music.
;
; Set: if you're using a Quartet  'Set', you need only change
; the contents of 'SetPointer' to the address where you have
; loaded your set (low 512K!), the 'LoopWord' to this
; address + 336, and 'Offsets' to this address + 140384.
;
;
; If not using a Quartet 'Set' then change the components of the
; SampleBase table to the start addresses of your samples and
; their respective lengths in words. Also remove the indicated
; lines of the subroutines 'GNNote0, GNNote1, GnNote2, GNNote3';
; these subroutines take care of sample loops, start offsets
; and special lengths made by Quartet's sample editor. Also,
; remove the call to 'SampleAddressMake' in the 'Play' routine.
;
; 'LoopWord' is the sample looping control word. Each bit (0-15)
; controls whether that sample should loop or not. Within
; a Quartet set it is the word with offset 336. You'll need
; to set up your own LoopWord if not using a set.
; e.g.
;	LoopWord:	dc.l 0		; No Loops
; 
;
;
;
; For those interested: In a Quartet created 'Set', the first sample
; starts 352 bytes after the address where you load the
; set; this is due to the set header. Then comes 140K of sample
; space. The length of the samples within this space
; (in words) is specified by the sixteen words following
; Setstart + 140352. The subroutine 'SampleAddressMake',
; calculates the sample addresses from these lengths, the samples
; being stored contiguously. The final sixteen long words in the
; set are two words for each sample, specifying the start offset
; and the special length (0 if no special length) of that sample.
; 
;
;
; Calling the Play subroutine starts the interrupt driven music.
; Firstly it installs the interrupts, including the Vertical
; Blanking interrupt Server.
; If you have an existing Vertical Blanking interrupt in your code,
; delete the indicated lines in the 'InterruptsSetup' and
; 'UnLoadInterrupts' subroutines, and call 'GetNextBeat' from your
; interrupt.
;
; The subroutine 'GetNextBeat' is enabled by bit 0 of 'PlaySignal',
; clearing this bit will disenable the routine and thus suspend the
; music. To terminate the music completely, call the 'UnLoadInterrupts'
; routine.
;
; From Assemblers:
; Once you've loaded a set and some music (use Monam's 'Load Binary
; File' or Seka's 'ri'), you can call 'Start' from DevPac2 by selecting
; the Run option, and from Seka with 'g Start (BreakPoint = end)'.
;
; From Programs:
; Sets and music can be read in with the dos library Open() and Read()
; routines. See the source code for the demo if in doubt. Call the
; 'Play' subroutine to start the music.
;
; The 'Start' subroutine is for test purposes. It starts the music
; by calling 'Play' and then waits until you press the mouse button
; or the music reaches its specified end, whereupon the subroutine
; 'UnLoadInterrupts' is executed.
;
;
; In summary, assuming you don't have another Vert-Blank interrupt, just
; call the 'Play' subroutine to start the music (having loaded your
; samples and music). Call 'UnLoadInterrupts' to turn off the music.


; For the interested, each note is stored as two consecutive bytes:

;			01 111111    0001 0003 
;			/    |         |    \
;		  Octave   Volume    Sample  Note Value
;		  (0-2)    (1-63)    (0-15)   (1-12 = F#-G)
;
;
; Notes succeeded by a XX000000 11111110 word are slide notes.




*        ------------------------------------------------	 *
*			CODE STARTS HERE			 * 
*        ------------------------------------------------	 *


;	bra	Start	; This is for the benefit of a DevPac2 Run.

***** MUSIC *****

;Tempo = $5d000		; This should be set to the music start
			; address, since the tempo is Stored
			; in the first byte of the music file.

;MusicStart:
;	dc.l $5d002	; This long word should contain the music
			; start address + 2.


*****  SET  *****

;SetPointer:
;	dc.l $3a560	; Contains address of set start point.

;LoopWord = $3a6b0	; Should set to the above + 336.

;Offsets = $5c9c0	; Should be set to the above + 140384

SampleBase:
;***         Block 1          ***
;	dc.l $3a6c2,4998	; Address and length of blk1 smpl 1
;	dc.l $3cdd2,4998	; Address and length of blk1 smpl 2
;	dc.l $3f4e2,4998	; etc ..
;	dc.l $41bf2,4998	; etc ...
;***         Block 2          ***
;	dc.l $44302,4998
;	dc.l $46a12,4998
;	dc.l $49122,4998
;	dc.l $4b832,4998
;***         Block 3          ***
;	dc.l $4df42,4998
;	dc.l $50652,4998
;	dc.l $52d62,4998
;	dc.l $55472,4998
;***         Block 4          ***
;	dc.l $57b82,2498
;	dc.l $58f0a,2498
;	dc.l $5a292,2498
;	dc.l $5b61a,2498

		DS.B	16*8

;Play:	
;	bsr	InterruptsSetup
;	bsr	SampleAddressMake	; Use only with Quartet Sets.

** The following 8 instructions force the sound channels
** to their idling state, ready to be re-started.
Init
;	move.w	#$000f,$dff096
;	move.w	#12,$dff0a6
;	move.w	#12,$dff0b6
;	move.w	#12,$dff0c6
;	move.w	#12,$dff0d6
;	move.w	#$8780,$dff09c
;	move.w	#$8780,$dff09a
	
	move.w	#288,ChZeroPer		; Initialize Sound
	move.w	#288,ChOnePer		; variables.
	move.w	#288,ChTwoPer
	move.w	#288,ChThreePer
	clr.w	ChZeroVol
	clr.w	ChOneVol
	clr.w	ChTwoVol
	clr.w	ChThreeVol
		
	move.l	MusicStart(PC),AudPos	; Initialize Music Pointer.	
			
;	move.w	#$800f,$dff096		; Enable audio DMA.

	move.b	Tempo(PC),TempoCounter	; Initialize counter.
;	bset	#0,PlaySignal		; Enable 'GetNextBeat'.
	rts


;InterruptsSetup:		; Sets up sound and Vert-Blank
;	move.w	#$0780,$dff09a	; interrupts.
;	move.l	$004,a6
;	move.l	#7,d0		; Channel 0 int number.
;	lea	Data0,a1	; Channel 0 int data.
;	jsr	-162(a6)	; SetIntVector().
;	move.l	#8,d0		; Channel 1 int number.
;	lea	Data1,a1	; etc etc.
;	jsr	-162(a6)
;	move.l	#9,d0
;	lea	Data2,a1
;	jsr	-162(a6)
;	move.l	#10,d0
;	lea	Data3,a1
;	jsr	-162(a6)
;	move.l	#5,d0		; REMOVE THESE THREE LINES
;	lea	Data4,a1	; IF USING EXISTING VERT-BLANKING
;	jsr	-168(a6)	; INTERRUPT.
;	rts

; The Interrupt Data.	

;Data0:
;	dc.l $00000902
;	dc.w 0,0,0,0,0,0,0
;	dc.l AudIntZero

;Data1:
;	dc.l $00000902,0,0,0
;	dc.w 0
;	dc.l AudIntOne

;Data2:
;	dc.l $00000902,0,0,0
;	dc.w 0
;	dc.l AudIntTwo

;Data3:
;	dc.l $00000902,0,0,0
;	dc.w 0
;	dc.l AudIntThree

;Data4:
;	dc.l $00000902,0,0,0
;	dc.w 0
;	dc.l GetNextBeat

TempoCounter:
	dc.b	1,0

	even

;GetNextBeat:			; This subroutine should be called
;	move.w	#$0020,$dff09c	; once every Vertical Blank.
;	btst	#0,PlaySignal
;	bne	DoPlay
;	rts
DoPlay:	
	tst.b	SlideSignals
	beq.B	NoSlides
	Bsr.W	SlideServicer
NoSlides:
	subq.b	#1,TempoCounter
	beq.B	NextNotePeriod
	rts

NextNotePeriod:
;	movem.l	a3/a1/a0/d7/d3/d0,-(a7)
	move.l	AudPos(PC),a1
	cmpi.w	#$ffff,(a1)	; Have we reached end of music?
	beq.W	TurnOffMusic
	cmpi.w	#$ffff,2(a1)
	beq.W	TurnOffMusic
	cmpi.w	#$ffff,4(a1)
	beq.W	TurnOffMusic
	cmpi.w	#$ffff,6(a1)
	beq.W	TurnOffMusic
PlayNotes:
	move.b	Tempo(PC),TempoCounter	; Reset Tempo counter.

TryNewNoteCh0:
	tst.b	(a1)
	beq.W	TryNewNoteCh1
	cmpi.b	#$fe,1(a1)
	beq.B	TryNewNoteCh1	
;	move.w	#2,$dff0a6
;	move.w	#$0001,$dff096
;	move.w	#$8080,$dff09c

	MOVEQ	#1,D0
	BSR.W	PokeDMA

	bsr	GNNote0
;	bclr	#0,SignalCh0
;	move.l	ChZeroLoc(PC),$dff0a0
;	move.w	ChZeroLen(PC),$dff0a4
;	move.w	ChZeroPer(PC),$dff0a6
;	move.w	ChZeroVol(PC),$dff0a8
;	move.w	#$8001,$dff096

	MOVEQ	#0,D1				; channel number
	MOVE.L	ChZeroLoc(PC),D0
	JSR	ENPP_PokeAdr(A5)
	MOVEQ	#0,D0
	MOVE.W	ChZeroLen(PC),D0
	JSR	ENPP_PokeLen(A5)
	MOVE.W	ChZeroPer(PC),D0
	JSR	ENPP_PokePer(A5)
	MOVE.W	ChZeroVol(PC),D0
	JSR	ENPP_PokeVol(A5)
	MOVE.W	#$8001,D0
	BSR.W	PokeDMA
	MOVE.L	Loop1Adr(PC),D0
	JSR	ENPP_PokeAdr(A5)
	MOVEQ	#0,D0
	MOVE.W	Loop1Len(PC),D0
	JSR	ENPP_PokeLen(A5)

	cmpi.b	#$fe,9(a1)
	bne.B	TryNewNoteCh1
	Bsr.W	MakeSlideCh0

TryNewNoteCh1:
	tst.b	2(a1)
	beq.W	TryNewNoteCh2
	cmpi.b	#$fe,3(a1)
	beq.B	TryNewNoteCh2	
;	move.w	#2,$dff0b6
;	move.w	#$0002,$dff096
;	move.w	#$8100,$dff09c

	MOVEQ	#2,D0
	BSR.W	PokeDMA

	bsr	GNNote1
;	bclr	#0,SignalCh1
;	move.l	ChOneLoc(PC),$dff0b0
;	move.w	ChOneLen(PC),$dff0b4
;	move.w	ChOnePer(PC),$dff0b6
;	move.w	ChOneVol(PC),$dff0b8
;	move.w	#$8002,$dff096

	MOVEQ	#1,D1				; channel number
	MOVE.L	ChOneLoc(PC),D0
	JSR	ENPP_PokeAdr(A5)
	MOVEQ	#0,D0
	MOVE.W	ChOneLen(PC),D0
	JSR	ENPP_PokeLen(A5)
	MOVE.W	ChOnePer(PC),D0
	JSR	ENPP_PokePer(A5)
	MOVE.W	ChOneVol(PC),D0
	JSR	ENPP_PokeVol(A5)
	MOVE.W	#$8002,D0
	BSR.W	PokeDMA
	MOVE.L	Loop2Adr(PC),D0
	JSR	ENPP_PokeAdr(A5)
	MOVEQ	#0,D0
	MOVE.W	Loop2Len(PC),D0
	JSR	ENPP_PokeLen(A5)

	cmpi.b	#$fe,11(a1)
	bne.B	TryNewNoteCh2
	Bsr.W	MakeSlideCh1

TryNewNoteCh2:
	tst.b	4(a1)
	beq.W	TryNewNoteCh3 
	cmpi.b	#$fe,5(a1)
	beq.B	TryNewNoteCh3	
;	move.w	#2,$dff0c6
;	move.w	#$0004,$dff096
;	move.w	#$8200,$dff09c

	MOVEQ	#4,D0
	BSR.W	PokeDMA

	bsr	GNNote2
;	move.l	ChTwoLoc(PC),$dff0c0
;	move.w	ChTwoLen(PC),$dff0c4
;	move.w	ChTwoPer(PC),$dff0c6
;	move.w	ChTwoVol(PC),$dff0c8
;	bclr	#0,SignalCh2
;	move.w	#$8004,$dff096

	MOVEQ	#2,D1				; channel number
	MOVE.L	ChTwoLoc(PC),D0
	JSR	ENPP_PokeAdr(A5)
	MOVEQ	#0,D0
	MOVE.W	ChTwoLen(PC),D0
	JSR	ENPP_PokeLen(A5)
	MOVE.W	ChTwoPer(PC),D0
	JSR	ENPP_PokePer(A5)
	MOVE.W	ChTwoVol(PC),D0
	JSR	ENPP_PokeVol(A5)
	MOVE.W	#$8004,D0
	BSR.W	PokeDMA
	MOVE.L	Loop3Adr(PC),D0
	JSR	ENPP_PokeAdr(A5)
	MOVEQ	#0,D0
	MOVE.W	Loop3Len(PC),D0
	JSR	ENPP_PokeLen(A5)

	cmpi.b	#$fe,13(a1)
	bne.B	TryNewNoteCh3
	Bsr.W	MakeSlideCh2

TryNewNoteCh3:
	tst.b	6(a1)
	beq.W	Vertblend
	cmpi.b	#$fe,7(a1)
	beq.B	Vertblend	
;	move.w	#2,$dff0d6
;	move.w	#$0008,$dff096
;	move.w	#$8400,$dff09c

	MOVEQ	#8,D0
	BSR.W	PokeDMA

	bsr	GNNote3
;	move.l	ChThreeLoc(PC),$dff0d0
;	move.w	ChThreeLen(PC),$dff0d4
;	move.w	ChThreePer(PC),$dff0d6
;	move.w	ChThreeVol(PC),$dff0d8
;	bclr	#0,SignalCh3
;	move.w	#$8008,$dff096

	MOVEQ	#3,D1				; channel number
	MOVE.L	ChThreeLoc(PC),D0
	JSR	ENPP_PokeAdr(A5)
	MOVEQ	#0,D0
	MOVE.W	ChThreeLen(PC),D0
	JSR	ENPP_PokeLen(A5)
	MOVE.W	ChThreePer(PC),D0
	JSR	ENPP_PokePer(A5)
	MOVE.W	ChThreeVol(PC),D0
	JSR	ENPP_PokeVol(A5)
	MOVE.W	#$8008,D0
	BSR.W	PokeDMA
	MOVE.L	Loop4Adr(PC),D0
	JSR	ENPP_PokeAdr(A5)
	MOVEQ	#0,D0
	MOVE.W	Loop4Len(PC),D0
	JSR	ENPP_PokeLen(A5)

	cmpi.b	#$fe,15(a1)
	bne.B	Vertblend
	Bsr.W	MakeSlideCh3
Vertblend:
	addq.l	#8,AudPos
;	movem.l	(a7)+,a3/a1/a0/d7/d3/d0
	rts

;TurnOffMusic:
;	clr.w	$dff0a8
;	clr.w	$dff0b8
;	clr.w	$dff0c8
;	clr.w	$dff0d8
;	move.w	#$000f,$dff096
;	move.w	#$0780,$dff09a
;	move.w	#$0780,$dff09c
;	bclr	#0,PlaySignal
;	bra	Vertblend

TurnOffMusic:			; USE THIS SUBROUTINE FOR LOOPING MUSIC.

	BSR.W	SongEnd
	CMP.W	#2,InfoBuffer+Length+2
	BGT.B	Loop
	RTS
Loop
	move.l	MusicStart(PC),AudPos	
	move.l	AudPos(PC),a1
	bra.W	PlayNotes

;AudIntZero:			; Interrupt for Channel 0.
;	move.w	#$0080,$dff09c
;	btst	#0,SignalCh0
;	beq.B	donowt0
;	clr.w	$dff0a8
;donowt0:
;	bset	#0,SignalCh0
;	rts

;AudIntOne:			; Interrupt for Channel 0.
;	move.w	#$0100,$dff09c
;	btst	#0,SignalCh1
;	beq.B	donowt1
;	clr.w	$dff0b8
;donowt1:
;	bset	#0,SignalCh1
;	rts

;AudIntTwo:			; Interrupt for Channel 0.
;	move.w	#$0200,$dff09c
;	btst	#0,SignalCh2
;	beq.B	donowt2
;	clr.w	$dff0c8
;donowt2:
;	bset	#0,SignalCh2
;	rts

;AudIntThree:			; Interrupt for Channel 0.
;	move.w	#$0400,$dff09c
;	btst	#0,SignalCh3
;	beq.B	donowt3
;	clr.w	$dff0d8
;donowt3:
;	bset	#0,SignalCh3
;	rts

;SignalCh0:
;	dc.b 0
;SignalCh1:
;	dc.b 0
;SignalCh2:
;	dc.b 0
;SignalCh3:
;	dc.b 0

;Delay:
;	move.w	#$150,d0
;Delay2:
;	dbf	d0,Delay2
;	rts

GetNextNoteChannel0:
;	bsr	Delay
	bclr	#0,SlideSignals
	moveq	#0,d0
	move.b	(a1),d7		; a1 contains AudPos
	andi.l	#$3f,d7
	addq.b	#1,d7
	move.w	d7,ChZeroVol
	move.b	1(a1),d7
	andi.l	#$f0,d7		; Extract Sample Number.
	lsr.b	#1,d7
	lea	SampleBase(PC),a3
	move.l	(a3,d7.W),ChZeroLoc
	move.w	6(a3,d7.W),ChZeroLen
	move.b	1(a1),d7
	and.b	#$0f,d7		; Extract note.
	subq.b	#1,d7
	asl.b	#1,d7
	lea	PeriodBase(PC),a3
	move.w	(a3,d7.W),d3	; D3 contains Period.
	move.b	(a1),d7
	lsr.b	#6,d7		; Extract Octave.
	btst	#1,d7
	beq.B	lat0
	lsr.w	#1,d3
lat0:	
	tst.b	d7
	bne.B	Leave0
	asl.w	#1,d3
Leave0:
	move.w	d3,ChZeroPer	; Octave modulated Period.
	rts

GetNextNoteChannel1:
;	bsr	Delay
	bclr	#1,SlideSignals
	moveq	#2,d0
	move.b	(a1,d0.W),d7
	andi.l	#$3f,d7
	addq.b	#1,d7
	move.w	d7,ChOneVol
	move.b	1(a1,d0.W),d7
	andi.l	#$f0,d7		; Extract Sample.
	lsr.b	#1,d7
	lea	SampleBase(PC),a3
	move.l	(a3,d7),ChOneLoc
	move.w	6(a3,d7),ChOneLen
	move.b	1(a1,d0),d7
	and.b	#$0f,d7		; Extract note.
	subq.b	#1,d7
	asl.b	#1,d7
	lea	PeriodBase(PC),a3
	move.w	(a3,d7),d3	; D3 contains Period.
	move.b	(a1,d0),d7
	lsr.b	#6,d7		; Extract Octave.
	btst	#1,d7
	beq.B	lat1
	lsr.w	#1,d3
lat1:	
	tst.b	d7
	bne.B	Leave1
	asl.w	#1,d3
Leave1:
	move.w	d3,ChOnePer	; Octave modulated Period.
	rts


GetNextNoteChannel2:
;	bsr	Delay
	bclr	#2,SlideSignals
	moveq	#4,d0
	move.b	(a1,d0.W),d7
	andi.l	#$3f,d7
	addq.b	#1,d7
	move.w	d7,ChTwoVol
	move.b	1(a1,d0.W),d7
	andi.l	#$f0,d7		; Extract Sample.
	lsr.b	#1,d7
	lea	SampleBase(PC),a3
	move.l	(a3,d7),ChTwoLoc
	move.w	6(a3,d7),ChTwoLen
	move.b	1(a1,d0),d7
	and.b	#$0f,d7		; Extract note.
	subq.b	#1,d7
	asl.b	#1,d7
	lea	PeriodBase(PC),a3
	move.w	(a3,d7),d3	; D3 contains Period.
	move.b	(a1,d0),d7
	lsr.b	#6,d7		; Extract Octave.
	btst	#1,d7
	beq.B	lat2
	lsr.w	#1,d3
lat2:	
	tst.w	d7
	bne.B	Leave2
	asl.w	#1,d3
Leave2:
	move.w	d3,ChTwoPer	; Octave modulated Period.
	rts

GetNextNoteChannel3:
;	bsr	Delay
	bclr	#3,SlideSignals
	moveq	#6,d0
	move.b	(a1,d0.W),d7
	andi.l	#$3f,d7
	addq.b	#1,d7
	move.w	d7,ChThreeVol
	move.b	1(a1,d0.W),d7
	andi.l	#$f0,d7		; Extract Sample.
	lsr.b	#1,d7
	lea	SampleBase(PC),a3
	move.l	(a3,d7.W),ChThreeLoc
	move.w	6(a3,d7.W),ChThreeLen
	move.b	1(a1,d0.W),d7
	and.b	#$0f,d7		; Extract note.
	subq.b	#1,d7
	asl.b	#1,d7
	lea	PeriodBase(PC),a3
	move.w	(a3,d7),d3	; D3 contains Period.
	move.b	(a1,d0),d7
	lsr.b	#6,d7		; Extract Octave.
	btst	#1,d7
	beq.B	lat3
	lsr.w	#1,d3
lat3:	
	tst.w	d7
	bne.B	Leave3
	asl.w	#1,d3
Leave3:
	move.w	d3,ChThreePer	; Octave modulated Period.
	rts

PeriodBase:
	dc.w 204,216,229,242,257,272,288,305,323,343,363,384
	dc.b 102,108,114,121,128,136,144,153,162,171,181,192
AudPos:
	dc.l 0
ChZeroLoc:
	dc.l 0
ChZeroLen:
	dc.w 0
ChZeroPer:
	dc.w 0
ChZeroVol:
	dc.w 0
ChOneLoc:
	dc.l 0
ChOneLen:
	dc.w 0
ChOnePer:
	dc.w 0
ChOneVol:	
	dc.w 0
ChTwoLoc:
	dc.l 0
ChTwoLen:
	dc.w 0
ChTwoPer:
	dc.w 0
ChTwoVol:
	dc.w 0
ChThreeLoc:
	dc.l 0
ChThreeLen:
	dc.w 0
ChThreePer:
	dc.w 0
ChThreeVol:
	dc.w 0

ChZeroLocStore:
	dc.l 0
ChZeroLenStore:
	dc.w 0
ChZeroPerStore:
	dc.w 0
ChZeroVolStore:
	dc.w 0
ChOneLocStore:
	dc.l 0
ChOneLenStore:
	dc.w 0
ChOnePerStore:
	dc.w 0
ChOneVolStore:	
	dc.w 0
ChTwoLocStore:
	dc.l 0
ChTwoLenStore:
	dc.w 0
ChTwoPerStore:
	dc.w 0
ChTwoVolStore:
	dc.w 0
ChThreeLocStore:
	dc.l 0
ChThreeLenStore:
	dc.w 0
ChThreePerStore:
	dc.w 0
ChThreeVolStore:
	dc.w 0
;PlaySignal:
;	dc.b 0,0

	
NextNoteGet:
	moveq	#0,d3
	moveq	#1,d0
FindLoop:
	addq.b	#1,d0
	addq.l	#8,a3
	move.b	(a3),d3
	andi.b	#$3f,d3
	bne.B	NextNoteFound
	cmpi.b	#36,d0
	blt.B	FindLoop
	move.w	#0,d0
	rts
NextNoteFound:
	move.b	1(a3),d3
	andi.b	#$0f,d3
	subq.b	#1,d3
	asl.b	#1,d3
	lea	PeriodBase(PC),a0
	move.w	(a0,d3.W),d7
	move.b	(a3),d3
	lsr.b	#6,d3
	btst	#0,d3
	bne.B	MulTempo
	btst	#1,d3
	beq.B	Loct
	lsr.w	#1,d7
	bra.B	MulTempo
Loct:
	asl.w	#1,d7
MulTempo:
	move.b	Tempo(PC),d3
	muls	d3,d0
	rts

MakeSlideCh0:
	lea	8(a1),a3
	Bsr.W	NextNoteGet
	tst.w	d0
	beq.B	ExitSlide
	bset	#0,SlideSignals
	move.w	#1,SecondaryIncCh0
	sub.w	ChZeroPer(PC),d7
	bgt.B	PosIncCh0
	move.w	#-1,SecondaryIncCh0 
PosIncCh0:
	move.w	d7,d3
	ext.l	d3
	divs	d0,d3
	move.w	d3,BaseIncCh0
	swap	d3
	move.w	d3,RemCh0
	bge.B	nonNeg0
	neg.w	RemCh0
nonNeg0:
	move.w	d0,NumberOfVBsCh0
	clr.w	RemCountCh0
ExitSlide:
	rts

MakeSlideCh1:
	lea	10(a1),a3
	Bsr.W	NextNoteGet
	tst.w	d0
	beq.B	ExitSlide
	bset	#1,SlideSignals
	move.w	#1,SecondaryIncCh1
	sub.w	ChOnePer(PC),d7
	bgt.B	PosIncCh1
	move.w	#-1,SecondaryIncCh1 
PosIncCh1:
	move.w	d7,d3
	ext.l	d3
	divs.w	d0,d3
	move.w	d3,BaseIncCh1
	swap	d3
	move.w	d3,RemCh1
	bge.B	nonNeg1
	neg.w	RemCh1
nonNeg1:
	move.w	d0,NumberOfVBsCh1
	clr.w	RemCountCh1
	rts

MakeSlideCh2:
	lea	12(a1),a3
	Bsr.W	NextNoteGet
	tst.w	d0
	beq.B	ExitSlide
	bset	#2,SlideSignals
	move.w	#1,SecondaryIncCh2
	sub.w	ChTwoPer(PC),d7
	bgt.B	PosIncCh2
	move.w	#-1,SecondaryIncCh2 
PosIncCh2:
	move.w	d7,d3
	ext.l	d3
	divs	d0,d3
	move.w	d3,BaseIncCh2
	swap	d3
	move.w	d3,RemCh2
	bge.B	NonNeg2
	neg.w	RemCh2
NonNeg2:
	move.w	d0,NumberOfVBsCh2
	clr.w	RemCountCh2
	rts

MakeSlideCh3:
	lea	14(a1),a3
	Bsr.W	NextNoteGet
	tst.w	d0
	beq.W	 ExitSlide
	bset	#3,SlideSignals
	move.w	#1,SecondaryIncCh3
	sub.w	ChThreePer(PC),d7
	bgt.B	PosIncCh3
	move.w	#-1,SecondaryIncCh3 
PosIncCh3:
	move.w	d7,d3
	ext.l	d3
	divs	d0,d3
	move.w	d3,BaseIncCh3
	swap	d3
	move.w	d3,RemCh3
	bge.B	nonNeg3
	neg.w	RemCh3
nonNeg3:
	move.w	d0,NumberOfVBsCh3
	clr.w	RemCountCh3
	rts


SlideServicer:
	btst	#0,SlideSignals
	beq.B	NoSlideOnCh0
	bsr	DoSlideCh0
NoSlideOnCh0:
	btst	#1,SlideSignals
	beq.B	NoSlideOnCh1
	bsr	DoSlideCh1
NoSlideOnCh1:
	btst	#2,SlideSignals
	beq.B	NoSlideOnCh2
	bsr	DoSlideCh2
NoSlideOnCh2:
	btst	#3,SlideSignals
	beq.B	NoSlideOnCh3
	bsr	DoSlideCh3
NoSlideOnCh3:
	rts

DoSlideCh0:
	movem.l	d4/d3,-(a7)
	move.w	BaseIncCh0(PC),d3
	add.w	d3,ChZeroPer
	move.w	RemCountCh0(PC),d3
	add.w	RemCh0(PC),d3
	cmp.w	NumberOfVBsCh0(PC),d3
	blt.B	NoExtraCh0
	move.w	SecondaryIncCh0(PC),d4
	add.w	d4,ChZeroPer
	sub.w	NumberOfVBsCh0(PC),d3
NoExtraCh0:
	move.w	d3,RemCountCh0
;	move.w	ChZeroPer(PC),$dff0a6

	MOVEQ	#0,D1
	MOVE.W	ChZeroPer(PC),D0
	JSR	ENPP_PokePer(A5)

	movem.l	(a7)+,d4/d3
	rts
	
DoSlideCh1:
	movem.l	d4/d3,-(a7)
	move.w	BaseIncCh1(PC),d3
	add.w	d3,ChOnePer
	move.w	RemCountCh1(PC),d3
	add.w	RemCh1(PC),d3
	cmp.w	NumberOfVBsCh1(PC),d3
	blt.B	NoExtraCh1
	move.w	SecondaryIncCh1(PC),d4
	add.w	d4,ChOnePer
	sub.w	NumberOfVBsCh1(PC),d3
NoExtraCh1:
	move.w	d3,RemCountCh1
;	move.w	ChOnePer(PC),$dff0b6

	MOVEQ	#1,D1
	MOVE.W	ChOnePer(PC),D0
	JSR	ENPP_PokePer(A5)

	movem.l	(a7)+,d4/d3
	rts	

DoSlideCh2:
	movem.l	d4/d3,-(a7)
	move.w	BaseIncCh2(PC),d3
	add.w	d3,ChTwoPer
	move.w	RemCountCh2(PC),d3
	add.w	RemCh2(PC),d3
	cmp.w	NumberOfVBsCh2(PC),d3
	blt.B	NoExtraCh2
	move.w	SecondaryIncCh2(PC),d4
	add.w	d4,ChTwoPer
	sub.w	NumberOfVBsCh2(PC),d3
NoExtraCh2:
	move.w	d3,RemCountCh2
;	move.w	ChTwoPer(PC),$dff0c6

	MOVEQ	#2,D1
	MOVE.W	ChTwoPer(PC),D0
	JSR	ENPP_PokePer(A5)

	movem.l	(a7)+,d4/d3
	rts	

DoSlideCh3:
	movem.l	d4/d3,-(a7)
	move.w	BaseIncCh3(PC),d3
	add.w	d3,ChThreePer
	move.w	RemCountCh3(PC),d3
	add.w	RemCh3(PC),d3
	cmp.w	NumberOfVBsCh3(PC),d3
	blt.B	NoExtraCh3
	move.w	SecondaryIncCh3(PC),d4
	add.w	d4,ChThreePer
	sub.w	NumberOfVBsCh3(PC),d3
NoExtraCh3:
	move.w	d3,RemCountCh3
;	move.w	ChThreePer(PC),$dff0d6

	MOVEQ	#3,D1
	MOVE.W	ChThreePer(PC),D0
	JSR	ENPP_PokePer(A5)

	movem.l	(a7)+,d4/d3
	rts	

SlideSignals:
	dc.b 0,0
RemCh0:
	dc.w 0
RemCountCh0:
	dc.w 0
BaseIncCh0:
	dc.w 0
SecondaryIncCh0:
	dc.w 0


RemCh1:
	dc.w 0
RemCountCh1:
	dc.w 0
BaseIncCh1:
	dc.w 0
SecondaryIncCh1:
	dc.w 0

RemCh2:
	dc.w 0
RemCountCh2:
	dc.w 0
BaseIncCh2:
	dc.w 0
SecondaryIncCh2:
	dc.w 0

RemCh3:
	dc.w 0
RemCountCh3:
	dc.w 0
BaseIncCh3:
	dc.w 0
SecondaryIncCh3:
	dc.w 0

NumberOfVBsCh0:
	dc.w 0
NumberOfVBsCh1:
	dc.w 0
NumberOfVBsCh2:
	dc.w 0
NumberOfVBsCh3:
	dc.w 0


GNNote0:
; If not using a Quartet Set remove all the following 
; asterisked lines to disable the start offset and special
; length functions.

;	move.w	#$8080,$dff09a
	Bsr.W	GetNextNoteChannel0

	movem.l	a2/d1,-(a7)	;*
	move.b	1(a1),d7			
	andi.l	#$f0,d7		
	lsr.b	#2,d7		
	clr.l	d1		;*
;	lea	Offsets,a2	;*

	MOVE.L	Offsets(PC),A2

	move.w	(a2,d7),d1	;*
	add.l	d1,ChZeroLoc	;*
	move.w	2(a2,d7),d1	;*
	beq.B	NoSpecLength0	;*	
	move.w	d1,ChZeroLen	;*
NoSpecLength0:			;*
	movem.l (a7)+,a2/d1	;*

	lsr.b	#2,d7
	move.w	LoopWord(PC),d0
	btst	d7,d0
	beq.B	LeaveIntOn0
;	move.w	#$0080,$dff09a

	MOVE.L	ChZeroLoc(PC),Loop1Adr
	MOVE.W	ChZeroLen(PC),Loop1Len
	RTS

LeaveIntOn0:
	MOVE.L	#Empty,Loop1Adr
	MOVE.W	#1,Loop1Len

	rts

GNNote1:
;	move.w	#$8100,$dff09a
	Bsr.W	GetNextNoteChannel1

	movem.l	a2/d1,-(a7)	;*
	move.b	3(a1),d7
	andi.l	#$f0,d7
	lsr.b	#2,d7
	clr.l	d1		;*
;	lea	Offsets,a2	;*

	MOVE.L	Offsets(PC),A2

	move.w	(a2,d7.W),d1	;*
	add.l	d1,ChOneLoc	;*
	move.w	2(a2,d7.W),d1	;*
	beq.B	NoSpecLength1	;*
	move.w	d1,ChOneLen	;*
NoSpecLength1:			;*
	movem.l	(a7)+,a2/d1	;*

	lsr.b	#2,d7	
	move.w	LoopWord(PC),d0
	btst	d7,d0
	beq.B	LeaveIntOn1
;	move.w	#$0100,$dff09a

	MOVE.L	ChOneLoc(PC),Loop2Adr
	MOVE.W	ChOneLen(PC),Loop2Len
	RTS

LeaveIntOn1:
	MOVE.L	#Empty,Loop2Adr
	MOVE.W	#1,Loop2Len

	rts

GNNote2:
;	move.w	#$8200,$dff09a
	Bsr.W	GetNextNoteChannel2

	movem.l	a2/d1,-(a7)	;*
	move.b	5(a1),d7
	andi.l	#$f0,d7
	lsr.b	#2,d7
	clr.l	d1		;*
;	lea	Offsets,a2	;*

	MOVE.L	Offsets(PC),A2

	move.w	(a2,d7.W),d1	;*
	add.l	d1,ChTwoLoc	;*
	move.w	2(a2,d7.W),d1	;*
	beq.B	NoSpecLength2	;*
	move.w	d1,ChTwoLen	;*
NoSpecLength2:			;*
	movem.l	(a7)+,a2/d1	;*

	lsr.b	#2,d7
	move.w	LoopWord(PC),d0
	btst	d7,d0
	beq.B	LeaveIntOn2
;	move.w	#$0200,$dff09a

	MOVE.L	ChTwoLoc(PC),Loop3Adr
	MOVE.W	ChTwoLen(PC),Loop3Len
	RTS

LeaveIntOn2:
	MOVE.L	#Empty,Loop3Adr
	MOVE.W	#1,Loop3Len

	rts


GNNote3:
;	move.w	#$8400,$dff09a
	Bsr.W	GetNextNoteChannel3

	movem.l	a2/d1,-(a7)	;*
	move.b	7(a1),d7
	andi.l	#$f0,d7
	lsr.b	#2,d7
	clr.l	d1		;*
;	lea	Offsets,a2	;*

	MOVE.L	Offsets(PC),A2

	move.w	(a2,d7.W),d1	;*
	add.l	d1,ChThreeLoc	;*
	move.w	2(a2,d7.W),d1	;*
	beq.B	NoSpecLength3	;*
	move.w	d1,ChThreeLen	;*
NoSpecLength3:			;*
	movem.l	(a7)+,a2/d1	;*

	lsr.b	#2,d7
	move.w	LoopWord(PC),d0
	btst	d7,d0
	beq.B	LeaveIntOn3
;	move.w	#$0400,$dff09a

	MOVE.L	ChThreeLoc(PC),Loop4Adr
	MOVE.W	ChThreeLen(PC),Loop4Len
	RTS

LeaveIntOn3:
	MOVE.L	#Empty,Loop4Adr
	MOVE.W	#1,Loop4Len

	rts


Loop1Adr
	dc.l	0
Loop1Len
	dc.w	0
Loop2Adr
	dc.l	0
Loop2Len
	dc.w	0
Loop3Adr
	dc.l	0
Loop3Len
	dc.w	0
Loop4Adr
	dc.l	0
Loop4Len
	dc.w	0

SampleAddressMake:
;	lea	$5c9a0,a1
	lea	SampleBase(PC),a2
	move.b	#16,d0
;	move.l	#$3a6c2,d1
	clr.l	d2
MSBLoop:
	move.l	d1,(a2)+
	move.w	(a1)+,d2
	cmp.l	#50,d2
	ble.B	MakeFifty
	move.l	d2,(a2)+
	addq.w	#2,d2
	asl.w	#1,d2
	add.l	d2,d1
MFBack:
	subq.b	#1,d0
	bne.B	MSBLoop
	rts
MakeFifty:
	move.l	#50,(a2)+
	bra.B	MFBack


;UnLoadInterrupts:
;	bclr	#0,PlaySignal
;	move.w	#$000f,$dff096		; Turn-off Audio DMA.
;	move.w	#$0780,$dff09a		; Disable Sound Interrupts.

;	move.l	$04,a6			; **  DELETE THESE 4
;	move.l	#5,d0			; LINES IF USING
;	lea	Data4,a1			; EXISTING VERT-BLANKING
;	jsr	-174(a6)		; INTERRUPT  **

;end:
;	rts

;Start:	
;	bsr Play
;Waitbutton:	
;	btst #0,PlaySignal
;	beq UnLoadInterrupts
;	btst #6,$bfe0ff			; Is mouse button pressed.
;	bne Waitbutton			; If not loop.
;	bra UnLoadInterrupts		; If so then Exit.

	Section	Buffy,BSS_C
Empty
	ds.b	4

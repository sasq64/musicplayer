;*---------------------------------------------------------------------------
; Program:	UnrealRipper.s
; Contents:	Slave for ripping files from "Unreal" (c) 1990 Ubisoft
; Author:	Codetapper of Action
; History:	22.10.01 - v1.0
;		         - Full load from HD
;		         - Rips all files from both PAL and NTSC version
; Requires:	WHDLoad 10+
; Copyright:	Public Domain
; Language:	68000 Assembler
; Translator:	Barfly
; Info:		This WHDLoad slave needs to be put in the same directory
;		as the disk images (Disk.1, Disk.2, Disk.3) and run. It
;		will output files named File.XY where X is the disk the 
;		file came from and Y is the file number on that disk.
;		It works with both the PAL and NTSC versions of the game.
;---------------------------------------------------------------------------*

		INCDIR	include:
		INCLUDE	whdload.i
		INCLUDE	whdmacros.i

		IFD BARFLY
		OUTPUT	"UnrealRipper.slave"
		BOPT	O+			;enable optimizing
		BOPT	OG+			;enable optimizing
		BOPT	ODd-			;disable mul optimizing
		BOPT	ODe-			;disable mul optimizing
		BOPT	w4-			;disable 64k warnings
		BOPT	wo-			;disable warnings
		SUPER				;disable supervisor warnings
		ENDC

;======================================================================

_base		SLAVE_HEADER			;ws_Security + ws_ID
		dc.w	10			;ws_Version
		dc.w	WHDLF_NoError|WHDLF_EmulTrap	;ws_flags
		dc.l	$eb000			;ws_BaseMemSize
		dc.l	0			;ws_ExecInstall
		dc.w	_Start-_base		;ws_GameLoader
		dc.w	0			;ws_CurrentDir
		dc.w	0			;ws_DontCache
_keydebug	dc.b	0			;ws_keydebug
_keyexit	dc.b	$59			;ws_keyexit = F10
_expmem		dc.l	0			;ws_ExpMem
		dc.w	_name-_base		;ws_name
		dc.w	_copy-_base		;ws_copy
		dc.w	_info-_base		;ws_info

;============================================================================
		IFND	.passchk
		DOSCMD	"WDate >T:date"
.passchk
		ENDC

_name		dc.b	"Unreal Ripper",0
_copy		dc.b	"1990 Ubisoft",0
_info		dc.b	"Installed by Codetapper/Action!",10
		dc.b	"Version 1.0 "
		INCBIN	"T:date"
		dc.b	-1,"Greetings to Don Adan/Wanted Team!"
		dc.b	0
_DiskX		dc.b	"Disk."
_DiskNumber	dc.b	"1",0
_DestName	dc.b	"File."
_DestNameNumber	dc.b	"00",0
		EVEN

;======================================================================
_Start						;a0 = resident loader
;======================================================================

		lea	_resload(pc),a1
		move.l	a0,(a1)			;save for later use

_restart	lea	_DiskX(pc),a0		;Check which version we have
		sub.l	a1,a1			;Address
		moveq	#$10,d0			;Size
		moveq	#0,d1			;Offset
		move.l	_resload(pc),a2
		jsr	resload_LoadFileOffset(a2)
		
		lea	_PAL(pc),a3
		cmp.b	#$b0,$f
		beq	.Rip3Disks

		lea	_NTSC(pc),a3
		cmp.b	#$90,$f
		bne	_wrongver

.Rip3Disks	moveq	#0,d4			;Disk number
.GoAgain	addq	#1,d4
		bsr	_RipUntilEnd
		cmp.l	#3,d4
		bne	.GoAgain
		bra	_exit

_RipUntilEnd	lea	_DiskNumber(pc),a0
		move.b	d4,(a0)
		add.b	#'0',(a0)
		lea	_DiskX(pc),a0
		sub.l	a1,a1
		move.l	_resload(pc),a2
		jsr	resload_LoadFileDecrunch(a2)

		move.l	d4,d6
		mulu	#10,d6			;d6 = File number to save

.DecryptNext	move.l	(a3)+,a1		;Offset
		move.l	(a3)+,a2		;End address
		move.l	(a3)+,d0		;Length
		move.l	(a3)+,d3		;Decrypt Key
		cmp.l	#'END!',d3
		beq	.DecryptDone

		move.l	d0,d5
		move.l	a1,a0

.DecryptLoop	eor.l	d3,(a0)+
		sub.l	#4,d5
		bne	.DecryptLoop

		lea	_DestNameNumber(pc),a0
		addq	#1,d6
		move.l	d6,d7
		divu.w	#10,d7
		add.b	#'0',d7
		move.b	d7,(a0)+
		swap	d7
		add.b	#'0',d7
		move.b	d7,(a0)+

		movem.l	d0-d1/a0-a2,-(sp)
		lea	_DestName(pc),a0
		move.l	_resload(pc),a2
		jsr	resload_SaveFile(a2)
		movem.l	(sp)+,d0-d1/a0-a2

		bra	.DecryptNext		

.DecryptDone	rts

;======================================================================
_resload	dc.l	0		;address of resident loader
;======================================================================

_exit		pea	TDREASON_OK
		bra	_end
_wrongver	pea	TDREASON_WRONGVER
_end		move.l	(_resload),-(a7)
		add.l	#resload_Abort,(a7)
		rts

;======================================================================
; Format is offset, end address, length, XOR encryption key

_PAL		dc.l	$00000004,$00014df0,$00014dec,$23a153bc
		dc.l	$00014df0,$000489a0,$00033bb0,$2d2f9a6b
		dc.l	$000489a0,$0009fca8,$00057308,$905a08fe
		dc.l	$0009fca8,$000a57b8,$00005b10,$280ad2fc
		dc.l	$000a57b8,$000d0c2c,$0002b474,$fe5889ff
		dc.l	$000d0c2c,$000e4604,$000139d8,$a57ef0ad
		dc.l	'END!','END!','END!','END!'
		dc.l	$00000004,$000254bc,$000254b8,$4abc6e9a
		dc.l	$000254bc,$0002b088,$00005bcc,$12590ad7
		dc.l	$0002b088,$00064f68,$00039ee0,$a4e489ff
		dc.l	$00064f68,$0006aa78,$00005b10,$cdfa5a9e
		dc.l	$0006aa78,$0009a32c,$0002f8b4,$df2689ff
		dc.l	$0009a32c,$000d4df8,$0003aacc,$df2689ff
		dc.l	'END!','END!','END!','END!'
		dc.l	$00000004,$0003893c,$00038938,$cdfa89ff
		dc.l	$0003893c,$0003e448,$00005b0c,$1de5a9c9
		dc.l	$0003e448,$00069628,$0002b1e0,$2a3989ff
		dc.l	$00069628,$0006f1bc,$00005b94,$a05c5a4d
		dc.l	$0006f1bc,$000a6950,$00037794,$cd2589ff
		dc.l	$000a6950,$000dab28,$000341d8,$a54c89ff
		dc.l	'END!','END!','END!','END!'

;======================================================================
; Format is offset, end address, length, XOR encryption key

_NTSC		dc.l	$00000004,$000117f8,$000117f4,$23a153bc
		dc.l	$000117f8,$000453a8,$00033bb0,$2d2f9a6b
		dc.l	$000453a8,$0009c6b0,$00057308,$905a08fe
		dc.l	$0009c6b0,$000a21c0,$00005b10,$280ad2fc
		dc.l	$000a21c0,$000cd5fc,$0002b43c,$fe5889ff
		dc.l	$000cd5fc,$000e0fe4,$000139e8,$a57ef0ad
		dc.l	'END!','END!','END!','END!'
		dc.l	$00000004,$000231cc,$000231c8,$4abc6e9a
		dc.l	$000231cc,$00028d98,$00005bcc,$12590ad7
		dc.l	$00028d98,$00062c78,$00039ee0,$a4e489ff
		dc.l	$00062c78,$00068788,$00005b10,$cdfa5a9e
		dc.l	$00068788,$00097fc4,$0002f83c,$df2689ff
		dc.l	$00097fc4,$000d2a80,$0003aabc,$df2689ff
		dc.l	'END!','END!','END!','END!'
		dc.l	$00000004,$00038940,$0003893c,$cdfa89ff
		dc.l	$00038940,$0003e450,$00005b10,$1de5a9c9
		dc.l	$0003e450,$000695ec,$0002b19c,$2a3989ff
		dc.l	$000695ec,$0006f180,$00005b94,$a05c5a4d
		dc.l	$0006f180,$000a6914,$00037794,$cd2589ff
		dc.l	$000a6914,$000daaf0,$000341dc,$a54c89ff
		dc.l	'END!','END!','END!','END!'

		END

/***************************************************************************
 *   Copyright (C) 2004 by David Banz                                      *
 *   neko@netcologne.de                                                    *
 *   GPL'ed                                                                *
 ***************************************************************************/

#ifndef __TFMX_H
#define __TFMX_H

#include "config.h"

#define PATHNAME_LENGTH 1024

#define DEBUGLVL 0
#define DEBUG(x) if (x<DEBUGLVL)

/* arch-dependent stuff here */

typedef unsigned int U32;
typedef unsigned short U16;
typedef unsigned char U8;
typedef int S32;
typedef short S16;
typedef char S8;

/* For your architecture, with 0x12345678 in l, we need to have;
 * w0=0x1234, w1=0x5678, b0=0x12, b1=0x34, b2=0x56, b3=0x78.  This is
 * currently set up for Intel-style little-endian.  VAX and Motorola (among
 * others) will probably have to change this
 */

typedef union
{
	U32 l;
/* byteorder... */
#ifdef WORDS_BIGENDIAN
	struct {U16 w0,w1;} w;
	struct {U8 b0,b1,b2,b3;} b;
#else
	struct {U16 w1,w0;} w;
	struct {U8 b3,b2,b1,b0;} b;
#endif

} UNI;

extern char outf[PATHNAME_LENGTH];
extern U32 editbuf[];
extern U8 *smplbuf;
extern int *patterns,*macros;
extern int multimode;
extern U32 eClocks,outRate,stereo;

#endif

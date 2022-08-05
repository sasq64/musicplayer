/***************************************************************************
 *   Copyright (C) 2004 by David Banz                                      *
 *   neko@netcologne.de                                                    *
 *   GPL'ed                                                                *
 ***************************************************************************/

#include "tfmxplay.h"

struct Hdr
{
	char magic[10];
	char pad[6];
	char text[6][40];
	unsigned short start[32],end[32],tempo[32];
	short mute[8];
	unsigned int trackstart,pattstart,macrostart;
	char pad2[36];
};

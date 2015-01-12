/*
 * Adplug - Replayer for many OPL2/OPL3 audio file formats.
 * Copyright (C) 1999 - 2005 Simon Peter, <dn.tlp@gmx.net>, et al.
 * 
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 * 
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 * dbemuopl.h - Emulated OPL using Sjoerd van der Berg's emulator,
 *              by Chris Moeller <kode54@gmail.com>
 */

#ifndef H_ADPLUG_DBEMUOPL
#define H_ADPLUG_DBEMUOPL

#include <opl.h>
#include <stdlib.h>
#include "dbopl.h"

#define clip(s) if ( (s) != (short)(s) ) (s) = (((s) >> 31) ^ 0x7FFF)

class DBemuopl: public Copl
{
public:
	DBemuopl(int rate, bool stereo)
		: usestereo( stereo )
	{
		chip.Setup( rate );
		currType = TYPE_OPL3;
	};

	~DBemuopl()
	{
	}

	void update(short *buf, int total)
	{
		Bit32s buffer[256 * 2];
		while (total > 0)
		{
			unsigned int samples = total;
			if ( samples > 256 ) samples = 256;
			if ( !chip.opl3Active )
			{
				chip.GenerateBlock2( samples, buffer );
				if ( ! usestereo )
				{
					for ( unsigned i = 0; i < samples; i++ )
					{
						int sample = buffer [i] << 1;
						clip(sample);
						buf [i] = sample;
					}
				}
				else
				{
					for ( unsigned i = 0; i < samples; i++ )
					{
						int sample = buffer [i] << 1;
						clip(sample);
						buf [i * 2 + 0] = sample;
						buf [i * 2 + 1] = sample;
					}
				}
			}
			else
			{
				chip.GenerateBlock3( samples, buffer );
				if ( usestereo )
				{
					for ( unsigned i = 0, j = samples * 2; i < j; i++ )
					{
						int sample = buffer [i] << 1;
						clip(sample);
						buf [i] = sample;
					}
				}
				else
				{
					for ( unsigned i = 0; i < samples; i++ )
					{
						int sample = ( buffer [i * 2 + 0] + buffer [i * 2 + 1] ) /* / 2*/;
						clip(sample);
						buf [i] = sample;
					}
				}
			}
			total -= samples;
			if ( usestereo ) buf += samples * 2;
			else buf += samples;
		}
	}

	// template methods
	void write(int reg, int val)
	{
		chip.WriteReg( currChip * 0x100 + reg, val );
	};

	void init() {};

	void settype(ChipType type)
	{
		currType = type;
	}

private:
	bool usestereo;
	DBOPL::Chip chip;
};

#endif

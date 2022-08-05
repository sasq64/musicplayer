/*
	Audio Overload SDK - SSF file format engine

	Copyright (c) 2007 R. Belmont and Richard Bannister.

	All rights reserved.

	Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

	* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
	* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
	* Neither the names of R. Belmont and Richard Bannister nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
	"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
	LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
	A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
	CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
	EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
	PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
	PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
	LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
	NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
	SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

/*

Sega driver commands:

00 - NOP
01 - SEQUENCE_START
02 - SEQUENCE_STOP
03 - SEQUENCE_PAUSE
04 - SEQUENCE_CONTINUE
05 - SEQUENCE_VOLUME
06 - SEQUENCE_ALLSTOP
07 - SEQUENCE_TEMPO
08 - SEQUENCE_MAP
09 - HOST_MIDI
0A - VOLUME_ANALYZE_START
0B - VOLUME_ANALYZE_STOP
0C - DSP CLEAR
0D - ALL OFF
0E - SEQUENCE PAN
0F - N/A
10 - SOUND INITIALIZE
11 - Yamaha 3D check (8C)
12 - QSound check (8B)
13 - Yamaha 3D init (8D)
80 - CD level
81 - CD pan
82 - MASTER VOLUME
83 - EFFECT_CHANGE
84 - NOP
85 - PCM stream play start
86 - PCM stream play end
87 - MIXER_CHANGE
88 - Mixer parameter change
89 - Hardware check
8A - PCM parameter change
8B - QSound check
8C - Yamaha 3D check
8D - Yamaha 3D init

*/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "ao.h"
#include "eng_protos.h"
#include "corlett.h"
#include "sat_hw.h"
#include "scsp.h"

#define DEBUG_LOADER	(0)

static corlett_t	*c = NULL;
static char 		psfby[256];
static uint32		decaybegin, decayend, total_samples;

void *scsp_start(const void *config);
void SCSP_Update(void *param, INT16 **inputs, INT16 **buf, int samples);

int32 ssf_start(uint8 *buffer, uint32 length)
{
	uint8 *file, *lib_decoded, *lib_raw_file;
	uint32 offset, plength, lengthMS, fadeMS;
	uint64 file_len, lib_len, lib_raw_length;
	corlett_t *lib;
	char *libfile;
	int i;

	// clear Saturn work RAM before we start scribbling in it
	memset(sat_ram, 0, 512*1024);

	// Decode the current SSF
	if (corlett_decode(buffer, length, &file, &file_len, &c) != AO_SUCCESS)
	{
		return AO_FAIL;
	}

	#if DEBUG_LOADER
	printf("%d bytes decoded\n", file_len);
	#endif

	// Get the library file, if any
	for (i=0; i<9; i++) 
	{
		libfile = i ? c->libaux[i-1] : c->lib;
		if (libfile[0] != 0)
		{
			uint64 tmp_length;
	
			#if DEBUG_LOADER	
			printf("Loading library: %s\n", c->lib);
			#endif
			if (ao_get_lib(libfile, &lib_raw_file, &tmp_length) != AO_SUCCESS)
			{
				return AO_FAIL;
			}
			lib_raw_length = tmp_length;
		
			if (corlett_decode(lib_raw_file, lib_raw_length, &lib_decoded, &lib_len, &lib) != AO_SUCCESS)
			{
				free(lib_raw_file);
				return AO_FAIL;
			}
				
			// Free up raw file
			free(lib_raw_file);

			// patch the file into ram
			offset = lib_decoded[0] | lib_decoded[1]<<8 | lib_decoded[2]<<16 | lib_decoded[3]<<24;

			// guard against invalid data
			if ((offset + (lib_len-4)) > 0x7ffff)
			{
				lib_len = 0x80000-offset+4;
			}
			memcpy(&sat_ram[offset], lib_decoded+4, lib_len-4);

			// Dispose the corlett structure for the lib - we don't use it
			free(lib);
		}
	}

	// now patch the file into RAM over the libraries
	offset = file[3]<<24 | file[2]<<16 | file[1]<<8 | file[0];

	// guard against invalid data
	if ((offset + (file_len-4)) > 0x7ffff)
	{
		file_len = 0x80000-offset+4;
	}

	memcpy(&sat_ram[offset], file+4, file_len-4);

	free(file);
	
	// Finally, set psfby tag
	strcpy(psfby, "n/a");
	if (c)
	{
		for (i = 0; i < MAX_UNKNOWN_TAGS; i++)
		{
			if (!strcasecmp(c->tag_name[i], "psfby"))
				strcpy(psfby, c->tag_data[i]);
		}
	}

	#if DEBUG_LOADER && 1
	{
		FILE *f;

		f = fopen("satram.bin", "wb");
		fwrite(sat_ram, 512*1024, 1, f);
		fclose(f);
	}
	#endif

	// now flip everything (this makes sense because he's using starscream)
	for (i = 0; i < 512*1024; i+=2)
	{
		uint8 temp;

		temp = sat_ram[i];
		sat_ram[i] = sat_ram[i+1];
		sat_ram[i+1] = temp;
	}

	sat_hw_init();

	// now figure out the time in samples for the length/fade
	lengthMS = psfTimeToMS(c->inf_length);
	fadeMS = psfTimeToMS(c->inf_fade);
	total_samples = 0;

	if (lengthMS == 0)
	{
		lengthMS = ~0;
	}

	if (lengthMS == ~0)
	{
		decaybegin = lengthMS;
	}
	else
	{
		lengthMS = (lengthMS * 441) / 10;
		fadeMS = (fadeMS * 441) / 10;

		decaybegin = lengthMS;
		decayend = lengthMS + fadeMS;
	}

	return AO_SUCCESS;
}

int32 ssf_gen(int16 *buffer, uint32 samples)
{	
	int i;
	int16 output[65536], output2[65536];
	int16 *stereo[2];
	int16 *outp = buffer;
	int opos;

	opos = 0;
	for (i = 0; i < samples; i++)
	{
		m68k_execute((11300000/60)/735);
		stereo[0] = &output[opos];
		stereo[1] = &output2[opos];
		SCSP_Update(NULL, NULL, stereo, 1);
		opos++;		
	}

	for (i = 0; i < samples; i++)
	{
		// process the fade tags
		if (total_samples >= decaybegin)
		{
			if (total_samples >= decayend)
			{
				// song is done here, call out as necessary to make your player stop
				output[i] = 0;
				output2[i] = 0;
			}
			else
			{
				int32 fader = 256 - (256*(total_samples - decaybegin)/(decayend-decaybegin));
				output[i] = (output[i] * fader)>>8;
				output2[i] = (output2[i] * fader)>>8;

				total_samples++;
			}
		}
		else
		{
			total_samples++;
		}

		*outp++ = output[i];
		*outp++ = output2[i];
	}

	return AO_SUCCESS;
}

int32 ssf_stop(void)
{
	return AO_SUCCESS;
}

int32 ssf_command(int32 command, int32 parameter)

{
	switch (command)
	{
		case COMMAND_RESTART:
			return AO_SUCCESS;
		
	}
	return AO_FAIL;
}

int32 ssf_fill_info(ao_display_info *info)
{
	if (c == NULL)
		return AO_FAIL;
		
	strcpy(info->title[1], "Name: ");
	sprintf(info->info[1], "%s", c->inf_title);

	strcpy(info->title[2], "Game: ");
	sprintf(info->info[2], "%s", c->inf_game);
	
	strcpy(info->title[3], "Artist: ");
	sprintf(info->info[3], "%s", c->inf_artist);

	strcpy(info->title[4], "Copyright: ");
	sprintf(info->info[4], "%s", c->inf_copy);

	strcpy(info->title[5], "Year: ");
	sprintf(info->info[5], "%s", c->inf_year);

	strcpy(info->title[6], "Length: ");
	sprintf(info->info[6], "%s", c->inf_length);

	strcpy(info->title[7], "Fade: ");
	sprintf(info->info[7], "%s", c->inf_fade);

	strcpy(info->title[8], "Ripper: ");
	sprintf(info->info[8], "%s", psfby);

	return AO_SUCCESS;
}

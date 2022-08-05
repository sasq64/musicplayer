/*
	YAPE - Yet Another Plus/4 Emulator

	The program emulates the Commodore 264 family of 8 bit microcomputers

	This program is free software, you are welcome to distribute it,
	and/or modify it under certain conditions. For more information,
	read 'Copying'.

	(c) 2000, 2001, 2004, 2007 Attila Gr�sz
*/
#ifndef _TEDMEM_H
#define _TEDMEM_H

#define RAMSIZE 65536
#define ROMSIZE 16384
#define SCR_HSIZE 456
#define SCR_VSIZE 312
#define TED_SOUND_CLOCK (221680)

#include "types.h"
#include "mem.h"
//#include "serial.h"

#include <stdio.h>
#include <string.h>

class CPU;
class KEYS;
class TAP;
class Filter;
class SIDsound;

class TED : public MemoryHandler {
  public:
  	TED();
  	~TED();
	KEYS *keys;
	TAP	*tap;
	virtual void UpdateSerialState(unsigned char portval);
	virtual void Reset();
	// read memory through memory decoder
  	virtual unsigned char Read(unsigned int addr);
  	virtual void Write(unsigned int addr, unsigned char value);
	// read memory directly
	unsigned char readDMA(unsigned int addr) { return Ram[addr]; }
	// same as above but with writing
	void wrtDMA(unsigned int addr, unsigned char value) { Ram[addr]=value; }
	void setRamMask(unsigned int value) { RAMMask=value;}
	unsigned int getRamMask(void) { return RAMMask;}
	// are the ROMs disabled?
  	bool RAMenable;
	// indicates whether 256K RAM is on
	bool bigram, bramsm;
	// /ram/rom path/load variables
	void loadroms(void);
	void loadloromfromfile(int nr, char fname[256]);
	void loadhiromfromfile(int nr, char fname[256]);
	char romlopath[4][256];
	char romhighpath[4][256];
	// this is for the FRE support
  	void dump(void *img);
	void memin(void *img);
	// screen rendering
	// raster co-ordinates and boundaries
	unsigned int beamx, beamy;
	unsigned char screen[SCR_HSIZE*(SCR_VSIZE*2)];
	bool render_ok;
	void texttoscreen(int x,int y, const char *scrtxt);
	void chrtoscreen(int x,int y, char scrchr);
	// cursor stuff
	unsigned int crsrpos;
	int crsrphase;
	bool crsrblinkon;
	// is joy emulated?
	bool joyemu;
	// CPU class pointer
	CPU	*cpuptr;
	// TED process (main loop of emulation)
	void ted_process(short *buffer, unsigned int count);
	void setDS( void *ds);

 	unsigned char Ram[RAMSIZE];
  	unsigned char RomHi[4][ROMSIZE];
	void ChangeMemBankSetup(bool romoff);

	// timer stuff
	bool t1on, t2on, t3on;
	unsigned int timer1, timer2, timer3, t1start;

	ClockCycle GetClockCount();
	static TED *instance() { return instance_; };
	void forcedReset();
	// PSID support
	void setMasterVolume(unsigned int shift);
	void setSampleRate(unsigned int value);
	void setFilterOrder(unsigned int value);
	void initFilter(unsigned int sampleRate_, unsigned int filterOrder_);
	unsigned int getSampleRate() { return sampleRate; };
	void injectCodeToRAM(unsigned int address, unsigned char *from, size_t len);
	void oscillatorInit();
	void oscillatorReset();
	void setPsidPlayAddress(unsigned int addr) { psidReplayAddr = addr; };
	unsigned int getPsidPlayAddress() { return psidReplayAddr; };
	void setPsid(bool isPsidFormat) { psidFormat = isPsidFormat; };
	unsigned int isPsid() { return psidFormat; };
	void selectWaveForm(unsigned int channel, unsigned int wave);
	unsigned int getWaveForm(unsigned int channel) { return waveForm[channel]; }
	void writeProtectedPlayerMemory(unsigned int addr, unsigned char *byte, unsigned int len) {
		for(unsigned int i = 0; i < len; i++)
			protectedPlayerMemory[(addr + i) & 0xfff] = *byte++;
	}
	void setplaybackSpeed(unsigned int speed);
	void enableChannel(unsigned int channel, bool enable);
	bool isChannelEnabled(unsigned int channel) {
		return channelMask[channel % 3] != 0;
	}
	void storeToBuffer(short *buffer,unsigned int count = 1);
	void copyToKbBuffer(char *bufferString, unsigned int bufferLength = -1);
	unsigned int getTimeSinceLastReset();
	void resetCycleCounter() { lastResetCycle = CycleCounter; }
	SIDsound *getSidCard() { return sidCard; };
	void enableSidCard(bool enable, unsigned int disableMask);
	static unsigned int masterVolume;
	
	// matrix[row*8+col];
	int matrix[8*8] = {0};
	
	
	int getKey(int x) {
		//printf("Get key %x\n", x);
		if(currentKey >= 0) {
			unsigned char res = 0;
			for(int i=0; i<8; i++) {
				if((x & (1<<i)) == 0) {
					// Check this column
					for(int j=0; j<8; j++) {
						if(matrix[j+8*i])
							res |= (1<<j);
					}
				}
			}
			return ~res;
		}
		
		return 0xff;
	}
	
	void putKey(int x) {
		if(keyPos < 16)
			keyBuffer[keyPos++] = x;	
	}
	
	void miscUpdate() {
		
		memset(matrix, 0, 8*8*4);
		currentKey = -1;
		
		if(keyPos > 0) {
			currentKey = keyBuffer[0];
			
			//printf("Pushing key %02x\n", currentKey);
			
			switch(currentKey) {
			case '1':
				matrix[0+8*7] = 1; // 1
				break;
			case '2':
				matrix[3+8*7] = 1; // 2
				break;
			case '3':
				matrix[0+8*1] = 1;
				break;
			case '4':
				matrix[3+8*2] = 1;
				break;
			case '5':
				matrix[0+8*2] = 1;
				break;
			case '6':
				matrix[3+8*3] = 1;
				break;
			case '7':
				matrix[0+8*3] = 1;
				break;
			case 0:
				matrix[4+8*7] = 1; // SPACE
				break;
			case 1:
				matrix[0+8*7] = 1; // 1
				matrix[4+8*0] = 1; // F1
				break;
			case 2:
				matrix[3+8*7] = 1;
				matrix[5+8*0] = 1;
				break;
			case 3:
				matrix[0+8*1] = 1;
				matrix[6+8*0] = 1;
				break;
			case 4:
				matrix[3+8*2] = 1;
				break;
			case 5:
				matrix[0+8*2] = 1;
				break;
			case 6:
				matrix[3+8*3] = 1;
				break;
			case 7:
				matrix[0+8*3] = 1;
				break;
			}
			
			        
			//printf("Found key %d", k);
			memcpy(keyBuffer, keyBuffer + sizeof(int), keyPos * sizeof(int));
			keyPos--;
		}
		
		
	}

  private:
	
	int keyBuffer[16];
	int keyPos = 0;
	int currentKey = 0;
	
	
	static TED *instance_;
    Filter *filter;
	// memory variables
  	unsigned char RomLo[4][ROMSIZE];
	unsigned char *actromlo, *actromhi;
	unsigned char *mem_8000_bfff, *mem_c000_ffff, *mem_fc00_fcff;
  	unsigned int RAMMask;
	unsigned char RamExt[4][RAMSIZE];	// Ram slots for 256 K RAM
	unsigned char *actram;
	unsigned char prp, prddr;
	unsigned char pio1;
	// indicates if screen blank is off
	bool scrblank;
	// for vertical/horizontal smooth scroll
	unsigned int hshift, vshift;
	unsigned int nrwscr, fltscr;
	// char/color buffers
	unsigned char DMAbuf[64*3];
	unsigned char *chrbuf, *clrbuf, *tmpClrbuf;
	int cposy;
	// rendering functions
	void	(TED::*scrmode)();
	inline void	hi_text();
	void	mc_text();
	void 	mc_text_rvs();
	void	ec_text();
	void	mcec();
	void	rv_text();
	void	hi_bitmap();
	void	mc_bitmap();
	void	illegalbank();
	bool	charrom;
	int		rvsmode, grmode, ecmode;
	int		scrattr, charbank;

	// border color
	unsigned int framecol;
	// various memory pointers
	unsigned char *colorbank, *charrombank, *charrambank;
	unsigned char *grbank;
	unsigned char *scrptr, *endptr, *ramptr;
	const char *DMAptr;
	unsigned int fastmode, irqline;
	unsigned char hcol[2], mcol[4], ecol[4], bmmcol[4], *cset;
	static ClockCycle CycleCounter;
	ClockCycle lastResetCycle;
	//
	void DoDMA( unsigned char *Buf, unsigned int Offset  );
	//
	void setFreq(unsigned int channel, int freq);
	void writeSoundReg(unsigned int reg, unsigned char value);
	void renderSound(unsigned int nrsamples, short *buffer);
	unsigned int psidReplayAddr;
	bool psidFormat;
	unsigned int waveForm[2];
	unsigned int getWaveSample(unsigned int channel, unsigned int wave);
	unsigned int waveSquare(unsigned int channel);
	unsigned int waveSawTooth(unsigned int channel);
	unsigned int waveTriangle(unsigned int channel);
	unsigned char protectedPlayerMemory[0x1000];
	unsigned int playbackSpeed;
	unsigned int channelMask[3];
	unsigned int sampleRate;
	unsigned int filterOrder;
	SIDsound *sidCard;
};

const short HUE[16] = { 0, 0,
/*RED*/	103, /*CYAN	*/ 283,
/*MAGENTA*/	53,/*GREEN*/ 241, /*BLUE*/347,
/*YELLOW*/ 167,/*ORANGE*/123, /*BROWN*/	148,
/*YLLW-GRN*/ 195, /*PINK*/ 83, /*BLU-GRN*/ 265,
/*LT-BLU*/ 323, /*DK-BLU*/ /*23 original, but wrong...*/ 355, /*LT-GRN	*/ 213
};

const double luma[9] = {
/*
	Luminancia Voltages
*/
	2.00, 2.4, 2.55, 2.7, 2.9, 3.3, 3.6, 4.1, 4.8 };

#endif //_TEDMEM_H

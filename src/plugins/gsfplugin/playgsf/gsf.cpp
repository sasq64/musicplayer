#include "./VBA/System.h"
#include "./VBA/Sound.h"
#include "./VBA/Util.h"
#include "./VBA/GBA.h"


#include "./VBA/unzip.h"

#include <string.h>

#include <stdio.h>

#include <stdarg.h>

int emulating = 0;


struct EmulatedSystem emulator;

bool debugger = false;
bool systemSoundOn = false;

#ifdef MMX
extern "C" bool cpu_mmx;
#endif

extern "C" void writeSound(void);


void systemMessage(int number, const char *defaultMsg, ...)
{

}

void systemSoundShutdown()
{

}

void systemSoundPause()
{

}

void systemSoundReset()
{

}

void systemSoundResume()
{

}

void systemWriteDataToSoundBuffer()			//this one actually outputs the sound, I do believe
{
	writeSound();
}

bool systemCanChangeSoundQuality()
{
  return true;
}



extern "C"
{

int GSFRun(const char *);

int	soundInitialized = false;

int GSFRun(const char *filename)
{
  char tempName[2048];
//  char file[2048];

  if(rom != NULL) {
    CPUCleanUp();
	//remoteCleanUp(); 
    emulating = false;   
  }

  
  //utilGetBaseName(theApp.szFile, tempName);
  utilGetBaseName(filename, tempName);

  //_fullpath(file, tempName, 1024);		//NO CLUE WHAT THIS DOES
  
  
  //theApp.filename = file;

  //int index = theApp.filename.ReverseFind('.');
  //if(index != -1)
  //  theApp.filename = theApp.filename.Left(index);

  //if(!theApp.dir.GetLength()) {
  //  int index = theApp.filename.ReverseFind('\\');
  //  if(index != -1) {
  //    theApp.dir = theApp.filename.Left(index-1);
  //  }
  //}

  //IMAGE_TYPE type = utilFindType(theApp.szFile);
  IMAGE_TYPE type = utilFindType(filename);

  if(type == IMAGE_UNKNOWN) {
	  fprintf(stderr,"Unsupported\n");
 //   systemMessage(IDS_UNSUPPORTED_FILE_TYPE,
 //                 "Unsupported file type: %s", theApp.szFile);
    return false;
  }

  //theApp.cartridgeType = (int)type;
 {
    //int size = CPULoadRom(theApp.szFile);
	int size = CPULoadRom(filename);
	//DisplayError("size = %X", size);
    if(!size)
      return false;

    //theApp.romSize = size;

    char *p = strrchr(tempName, '\\');
    if(p)
      *p = 0;
	
	{
	    char buffer[5];
	    strncpy(buffer, (const char *)&rom[0xac], 4);
	    buffer[4] = 0;

	    strcat(tempName, "\\vba-over.ini");
	}
    //theApp.emulator = GBASystem;

  }
    
  if(soundInitialized) {
      soundReset();
  } else {
    if(!soundOffFlag)
      soundInit();
	soundInitialized = true;
  }

  if(type == IMAGE_GBA) {
    //skipBios = theApp.skipBiosFile ? true : false;
    //CPUInit((char *)(LPCTSTR)theApp.biosFileName, theApp.useBiosFile ? true : false);
	CPUInit((char *)NULL, false);				//don't use bios file
    CPUReset();
  }
 
  emulating = true;
  
  return true;
}


void GSFClose(void) 
{
  if(rom != NULL /*|| gbRom != NULL*/) {
    soundPause();
    CPUCleanUp();
    //remoteCleanUp();
  }
  emulating = 0;
}


#define EMU_COUNT 250000

bool EmulationLoop(void) 
{
  if(emulating /*&& !paused*/) {
    for(int i = 0; i < 2; i++) {
		CPULoop(EMU_COUNT);
 
	    return true;
	}
  }
  return false;

}


bool IsValidGSF ( uint8_t Test[4] ) {
	if ( *((uint32_t *)&Test[0]) == 0x22465350 ) { return true; }
	return false;
}

bool IsTagPresent ( uint8_t Test[5] ) {
	if ( *((uint32_t *)&Test[0]) == 0x4741545b && Test[4]==0x5D) {return true;}
	return false;
}


extern int sndBitsPerSample;
extern int sndSamplesPerSec;
extern int sndNumChannels;

}


void setupSound(void)
{
  sndNumChannels = 2;

  switch(soundQuality) {
  case 2:
    sndSamplesPerSec = 22050;
    soundBufferLen = 736*2;
    //soundBufferTotalLen = 7360*2;
    break;
  case 4:
    sndSamplesPerSec = 11025;
    soundBufferLen = 368*2;
    //soundBufferTotalLen = 3680*2;
    break;
  default:
    soundQuality = 1;
    sndSamplesPerSec = 44100;
    //soundBufferLen = 1470*2;
	soundBufferLen = 576*2*2;
    //soundBufferTotalLen = 14700*2;
	//soundBufferTotalLen = 576*2*10*2;
  }
  sndBitsPerSample = 16; 

  systemSoundOn = true;
}

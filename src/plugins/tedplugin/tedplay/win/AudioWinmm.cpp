#include "AudioWinmm.h"
#include <mmsystem.h>
#include "tedmem.h"
#include "cpu.h"

// some good values for block size and count
#define BLOCK_SIZE 8192
#define BLOCK_COUNT 20

static CRITICAL_SECTION waveCriticalSection;
static WAVEHDR* waveBlocks;
static volatile int waveFreeBlockCount;
static int waveCurrentBlock;

HWAVEOUT hWaveOut; /* device handle */
HANDLE hFile;/* file handle */
WAVEFORMATEX wfx; /* look this up in your documentation */
char buffer[1024]; /* intermediate buffer for reading */

//struct WaveProcData{
	TED *ted;
	HANDLE semaph;
//};
//static WaveProcData wpd;

static WAVEHDR *allocateBlocks(int size, int count)
{
	unsigned char *buffer;
	int i;
	WAVEHDR* blocks;
	DWORD totalBufferSize = (size + sizeof(WAVEHDR)) * count;

	// allocate memory for the entire set in one go
	if((buffer = (unsigned char *) HeapAlloc(GetProcessHeap(), 
			HEAP_ZERO_MEMORY, totalBufferSize)) == NULL) {
		fprintf(stderr, "Memory allocation error\n");
		ExitProcess(1);
	}
	// and set up the pointers to each bit
	blocks = (WAVEHDR*) buffer;
	buffer += sizeof(WAVEHDR) * count;
	for(i = 0; i < count; i++) {
		blocks[i].dwBufferLength = size;
		blocks[i].lpData = (LPSTR) buffer;
		buffer += size;
	}
	return blocks;
}

static void freeBlocks(WAVEHDR* blockArray)
{
	// and this is why allocateBlocks works the way it does
	HeapFree(GetProcessHeap(), 0, blockArray);
}

void CALLBACK AudioWinmm::sndCallbackFunc(HANDLE wout, UINT msg,
								  DWORD user, DWORD dw1, DWORD dw2)
{
	//pointer to free block counter
	DWORD *freeBlockCounter = (DWORD *) user;

	if (msg == WOM_DONE) {
		EnterCriticalSection(&waveCriticalSection);
		(*freeBlockCounter)++;
		LeaveCriticalSection(&waveCriticalSection);
		if (ted) {
			//ted->ted_process((short*) stream, len / 2);
		}
	}
}

AudioWinmm::AudioWinmm(void *userData, unsigned int sampleFrq_) : Audio(sampleFrq_)
{
	MMRESULT mRes;
	unsigned int i;
	ted = reinterpret_cast<TED *>(userData);

	// Find a usable waveOut device and open it 
	for(i = 0; i < waveOutGetNumDevs(); i++) { 
		if(i == waveOutGetNumDevs()) {// Error (very probably no free devices found) 
//			MessageBox(NULL,L"No audio device found!",L"ERROR",MB_OK);
			return;
		}
	}

	// initialise the module variables
	waveBlocks = allocateBlocks(BLOCK_SIZE, BLOCK_COUNT);
	waveFreeBlockCount = BLOCK_COUNT;
	waveCurrentBlock = 0;
	InitializeCriticalSection(&waveCriticalSection);

	wfx.wFormatTag = WAVE_FORMAT_PCM;
	wfx.nChannels = 1;
	wfx.nSamplesPerSec = sampleFrq_;
	wfx.wBitsPerSample = 16;
	wfx.nBlockAlign = wfx.nChannels * wfx.wBitsPerSample / 8; 
	wfx.nAvgBytesPerSec = wfx.nSamplesPerSec * wfx.nBlockAlign;
	wfx.cbSize = 0;
	if ( (mRes = waveOutOpen(&hWaveOut, WAVE_MAPPER, &wfx,
			(DWORD_PTR) sndCallbackFunc, (DWORD_PTR)&waveFreeBlockCount, CALLBACK_FUNCTION))
			!= MMSYSERR_NOERROR) {
		TCHAR errMsg[100];
		//wsprintf(errMsg, TEXT("Cannot open waveout device.\rError code: %0X."),mRes);
//		MessageBox(NULL,errMsg,L"ERROR",MB_OK);
		return;
	}
	play();
}

void AudioWinmm::reset()
{
	if (hWaveOut)
		waveOutReset(hWaveOut);
}

void AudioWinmm::pause()
{
	paused = true;
	if (hWaveOut) {
		waveOutPause(hWaveOut);
	}
}

void AudioWinmm::play()
{
	paused = false;
	if (hWaveOut) {
		waveOutRestart(hWaveOut);
	}
}

void AudioWinmm::stop()
{
	paused = true;
	if (hWaveOut) {
		waveOutReset(hWaveOut);
		waveOutPause(hWaveOut);
	}
}

void AudioWinmm::write(HWAVEOUT hWaveOut, LPSTR data, int size)
{
	WAVEHDR *current;
	int remain;
	current = &waveBlocks[waveCurrentBlock];

	while(size > 0) {
		// first make sure the header we're going to use is unprepared
		if(current->dwFlags & WHDR_PREPARED) 
			waveOutUnprepareHeader(hWaveOut, current, sizeof(WAVEHDR));
		if(size < (int)(BLOCK_SIZE - current->dwUser)) {
			memcpy(current->lpData + current->dwUser, data, size);
			current->dwUser += size;
			break;
		}
		remain = BLOCK_SIZE - current->dwUser;
		memcpy(current->lpData + current->dwUser, data, remain);
		size -= remain;
		data += remain;
		current->dwBufferLength = BLOCK_SIZE;
		waveOutPrepareHeader(hWaveOut, current, sizeof(WAVEHDR));
		waveOutWrite(hWaveOut, current, sizeof(WAVEHDR));
		EnterCriticalSection(&waveCriticalSection);
		waveFreeBlockCount--;
		LeaveCriticalSection(&waveCriticalSection);
		// wait for a block to become free
		while(!waveFreeBlockCount)
			Sleep(0);
		// point to the next block
		waveCurrentBlock++;
		waveCurrentBlock %= BLOCK_COUNT;
		current = &waveBlocks[waveCurrentBlock];
		current->dwUser = 0;
	}
}

AudioWinmm::~AudioWinmm()
{
	// unprepare any blocks that are still prepared
	for(int i = 0; i < waveFreeBlockCount; i++) 
		if(waveBlocks[i].dwFlags & WHDR_PREPARED)
			waveOutUnprepareHeader(hWaveOut, &waveBlocks[i], sizeof(WAVEHDR));

	DeleteCriticalSection(&waveCriticalSection);
	if (hWaveOut) {
		waveOutReset(hWaveOut);
		waveOutClose(hWaveOut);
		hWaveOut = NULL;
	}
	freeBlocks(waveBlocks);
}

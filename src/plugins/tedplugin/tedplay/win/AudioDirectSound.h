#if _MSC_VER > 1000
#pragma once
#endif

#include <dsound.h>
#include <atlmisc.h>
#include "Audio.h"

#pragma comment(lib,"dxguid.lib")

typedef	HRESULT	(WINAPI *LPGETAUDIOSAMPLES_PROGRESS)(LPBYTE lpDesBuf, const DWORD dwRequiredSamples, DWORD &dwRetSamples, LPVOID lpData);

class AudioDirectSound : public Audio
{
public:

	AudioDirectSound(void *userData, unsigned int origFreq, unsigned int sampleFrq_, unsigned int bufDurInMsec);
	virtual ~AudioDirectSound();

	void SetFormat(WAVEFORMATEX WFE);
	void SetCallback(LPGETAUDIOSAMPLES_PROGRESS Function_Callback, LPVOID lpData);
	virtual void play();
	virtual void pause();
	virtual void stop();
	virtual void sleep(unsigned int msec) { ::Sleep(msec); };
	virtual void lock();
	virtual void unlock();
	DWORD GetSamplesPlayed();	
	void TimerCallback();

private:
	static CRITICAL_SECTION cs;
	//<DirectSound>
	WAVEFORMATEX m_WFE;
	LPDIRECTSOUND m_lpDS;
	LPDIRECTSOUNDBUFFER m_lpDSB;
	HANDLE m_pHEvent[2];
	//</DirectSound>

	//<Audio Buffer>
	LPBYTE m_lpAudioBuf;
	LPGETAUDIOSAMPLES_PROGRESS m_lpGETAUDIOSAMPLES;
	LPVOID m_lpData;
	//</Audio Buffer>

	//<Playing>
	MMRESULT m_timerID;
	DWORD m_dwCircles1;
	DWORD m_dwCircles2;
	int m_iDB;	
	//</Playing>
	static HRESULT WINAPI cb(LPBYTE lpDesBuf, const DWORD dwRequiredSamples, DWORD &dwRetSamples, LPVOID lpData);

	//<Error Information>
	//CString m_strLastError;
	CString m_strLastError;
	//</Error Information>
	unsigned int bufDurationInMsec;
	UINT wTimerRes;
};
//</AudioDirectSound  >
#include "stdafx.h"
#include <cstdio>
#include <mmsystem.h>
#include "AudioDirectSound.h"

#ifndef TIME_KILL_SYNCHRONOUS
#define TIME_KILL_SYNCHRONOUS 0x0100
#endif

static void CALLBACK TimerProcess(UINT uTimerID, UINT uMsg, DWORD_PTR dwUser, DWORD dw1, DWORD dw2)
{
	AudioDirectSound *pDDS = (AudioDirectSound *)dwUser;
	pDDS->TimerCallback();	
}

HRESULT WINAPI AudioDirectSound::cb(LPBYTE lpDesBuf, const DWORD dwRequiredSamples, DWORD &dwRetSamples, LPVOID lpData)
{
	audioCallback(lpData, lpDesBuf, dwRequiredSamples);
	dwRetSamples = dwRequiredSamples / 2;
	return 0;
}

AudioDirectSound::AudioDirectSound(void *userData, unsigned int origFreq, unsigned int sampleFrq_, 
				   unsigned int bufDurInMsec = 40) : Audio(sampleFrq_)
{
	//<DirectSound>
	ZeroMemory(&m_WFE, sizeof(m_WFE));
	m_lpDS = NULL;
	m_lpDSB = NULL;
	m_pHEvent[0] = CreateEvent(NULL, FALSE, FALSE, _T("Direct_Sound_Buffer_Notify_0"));
	m_pHEvent[1] = CreateEvent(NULL, FALSE, FALSE, _T("Direct_Sound_Buffer_Notify_1"));	
	//</DirectSound>

	//<Audio Buffer>
	m_lpAudioBuf = NULL;
	m_lpGETAUDIOSAMPLES = NULL;
	m_lpData = NULL;
	//</Audio Buffer>

	//<Playing>
	m_dwCircles1 = 0;
	m_dwCircles2 = 0;
	//</Playing>

	//
	bufDurationInMsec = bufDurInMsec;
	unsigned int fragsPerSec = 1000 / bufDurInMsec;
	unsigned int bufSize1kbChunk = (sampleFrq_ / fragsPerSec / 1024) * 1024;
	if (!bufSize1kbChunk) bufSize1kbChunk = 512;
	bufferLength = bufSize1kbChunk;
	unsigned int bfSize = origFreq / fragsPerSec; //(bufferLength * TED_SOUND_CLOCK + sampleFrq_ / 2) / sampleFrq_;
	// double length ring buffer, dividable by 8
	ringBufferSize = (bfSize / 8 + 1) * 16;
	ringBuffer = new short[ringBufferSize];
	// trigger initial buffer fill
	ringBufferIndex = ringBufferSize-1;

	// Initialize
	m_WFE.wFormatTag = WAVE_FORMAT_PCM;
	m_WFE.nChannels = 1;
	m_WFE.nSamplesPerSec = sampleFrq_;
	m_WFE.wBitsPerSample = 16;
	m_WFE.nBlockAlign = m_WFE.nChannels * m_WFE.wBitsPerSample / 8; 
	m_WFE.nAvgBytesPerSec = m_WFE.nSamplesPerSec * m_WFE.nBlockAlign;
	m_WFE.cbSize = 0;
	SetFormat(m_WFE);
	SetCallback( cb, userData);
}
//</AudioDirectSound>

AudioDirectSound::~AudioDirectSound()
{
	stop();
	if (NULL != m_lpAudioBuf) {
		delete []m_lpAudioBuf;
		m_lpAudioBuf = NULL;
	}
	timeEndPeriod(wTimerRes);
}
//</~AudioDirectSound>

void AudioDirectSound::SetFormat(WAVEFORMATEX WFE)
{
	m_WFE = WFE;	

	//Create DirectSound
	if ( FAILED(DirectSoundCreate(NULL, &m_lpDS, NULL)) ) {
		OutputDebugString(_T("Create DirectSound Failed!"));
		m_strLastError = _T("MyDirectSound SetFormat Failed!");
		return;
	}

	//Set Cooperative Level
	HWND hWnd = GetForegroundWindow();
	if (hWnd == NULL) {
		hWnd = GetDesktopWindow();
	}

	if ( FAILED(m_lpDS->SetCooperativeLevel(hWnd, DSSCL_PRIORITY)) ) {
		OutputDebugString(_T("SetCooperativeLevel Failed"));
		m_strLastError = _T("MyDirectSound SetFormat Failed!");
		return;
	}

	//Create Primary Buffer 
	DSBUFFERDESC dsbd;
	ZeroMemory(&dsbd, sizeof(dsbd));
	dsbd.dwSize = sizeof(DSBUFFERDESC);
	dsbd.dwFlags = DSBCAPS_PRIMARYBUFFER;
	dsbd.dwBufferBytes = 0;
	dsbd.lpwfxFormat = NULL;

	LPDIRECTSOUNDBUFFER lpDSB = NULL;
	if ( FAILED(m_lpDS->CreateSoundBuffer(&dsbd, &lpDSB, NULL)) ) {
		OutputDebugString(_T("Create Primary Sound Buffer Failed!"));
		m_strLastError = _T("MyDirectSound SetFormat Failed!");
		return;
	}

	//Set Primary Buffer Format
	if ( FAILED(lpDSB->SetFormat(&m_WFE)) ) {
		OutputDebugString(_T("Set Primary Format Failed!"));
		m_strLastError = _T("MyDirectSound SetFormat Failed!");
		return;
	}

	//Create Second Sound Buffer
	dsbd.dwFlags = DSBCAPS_GETCURRENTPOSITION2| DSBCAPS_CTRLPOSITIONNOTIFY | DSBCAPS_GLOBALFOCUS;
	dsbd.dwBufferBytes = 2 * 2 * bufferLength; //2 bytes per sample twice
	dsbd.lpwfxFormat = &m_WFE;

	if ( FAILED(m_lpDS->CreateSoundBuffer(&dsbd, &m_lpDSB, NULL)) ) {
		OutputDebugString(_T("Create Second Sound Buffer Failed!"));
		m_strLastError = _T("MyDirectSound SetFormat Failed!");
		return;
	}

	//Query DirectSoundNotify
	LPDIRECTSOUNDNOTIFY lpDSBNotify;
	if ( FAILED(m_lpDSB->QueryInterface(IID_IDirectSoundNotify, (LPVOID *)&lpDSBNotify)) ) {
		OutputDebugString(_T("QueryInterface DirectSoundNotify Failed!"));
		m_strLastError = _T("QueryInterface IID_IDirectSoundNotify Failed!");
		return;
	}
	
	//Set Direct Sound Buffer Notify Position
	DSBPOSITIONNOTIFY pPosNotify[2];
	pPosNotify[0].dwOffset = bufferLength - 1;
	pPosNotify[1].dwOffset = 3 * bufferLength - 1;		
	pPosNotify[0].hEventNotify = m_pHEvent[0];
	pPosNotify[1].hEventNotify = m_pHEvent[1];	

	if ( FAILED(lpDSBNotify->SetNotificationPositions(2, pPosNotify)) ) {
		OutputDebugString(_T("Set NotificationPosition Failed!"));
		m_strLastError = _T("SetNotificationPositions Failed!");
		return;
	}	

	//New audio buffer
	if (NULL != m_lpAudioBuf) {
		delete []m_lpAudioBuf;
		m_lpAudioBuf = NULL;		
	}
	m_lpAudioBuf = new unsigned char[bufferLength * 2 * 2];
	//Init Audio Buffer
	memset(m_lpAudioBuf, 0, bufferLength * 2 * 2);

	// performance measurement
	TIMECAPS		tc;

	// set timer resolution to 1 msec
	const int TARGET_RESOLUTION = 1; // 1-millisecond target resolution
	if (timeGetDevCaps(&tc, sizeof(TIMECAPS)) != TIMERR_NOERROR) {
		OutputDebugString(_T("Oops... couldn't get timer resolution.\n"));
	}
	wTimerRes = TARGET_RESOLUTION < tc.wPeriodMin ? tc.wPeriodMin : TARGET_RESOLUTION;
	timeBeginPeriod(wTimerRes);
}
//</SetFormat>

void AudioDirectSound::play()
{
	//Check if the DirectSound was created successfully
	if (NULL == m_lpDS) {
		m_strLastError = _T("DirectSound was not created!");
		OutputDebugString(m_strLastError);		
		return;
	}

	//Check if the callback function is valid
	if (NULL == m_lpGETAUDIOSAMPLES) {
		m_strLastError = _T("Callback Function is NULL!");
		OutputDebugString(m_strLastError);		
		return;
	}

	//Check if SetFormat successful
	if ( !m_strLastError.CompareNoCase(_T("MyDirectSound SetFormat Failed!")) ) {
		OutputDebugString(m_strLastError);
		return;
	}
	paused = false;
	// Start playing
	m_lpDSB->Play(0, 0, DSBPLAY_LOOPING);
	m_timerID = timeSetEvent(5, 5, (LPTIMECALLBACK) TimerProcess, 
		(DWORD_PTR)this, TIME_PERIODIC | TIME_CALLBACK_FUNCTION | TIME_KILL_SYNCHRONOUS);
}
//</Play>

void AudioDirectSound::pause()
{
	paused = true;
	if (NULL != m_lpDSB) {
		m_lpDSB->Stop(); // FIXME clicks... :(
		timeKillEvent(m_timerID);
	}
}
//</Pause>

void AudioDirectSound::stop()
{
	paused = true;
	if (NULL != m_lpDSB) {

		m_lpDSB->Stop();
		timeKillEvent(m_timerID);

		//Empty the buffer
		LPVOID lpvAudio1 = NULL;
		DWORD dwBytesAudio1 = 0;
		HRESULT hr = m_lpDSB->Lock(0, 0, &lpvAudio1, &dwBytesAudio1, NULL, NULL, DSBLOCK_ENTIREBUFFER);
		if ( FAILED(hr) ) {
			m_strLastError = _T("Lock entirebuffer failed! Stop Failed!");
			OutputDebugString(m_strLastError);
			return;
		}
		memset(lpvAudio1, 0, dwBytesAudio1);
		m_lpDSB->Unlock(lpvAudio1, dwBytesAudio1, NULL, NULL);

		//Move the current play position to begin
		m_lpDSB->SetCurrentPosition(0);	

		//Reset Event
		ResetEvent(m_pHEvent[0]);
		ResetEvent(m_pHEvent[1]);

		//Set Circles1 and Circles2 0
		m_dwCircles1 = 0;
		m_dwCircles2 = 0;
	}
}
//</Stop>

void AudioDirectSound::lock()
{
	//
}
void AudioDirectSound::unlock()
{
	//
}

DWORD AudioDirectSound::GetSamplesPlayed()
{
	if (NULL == m_lpDSB) {
		return 0;
	}

	//Get current play position
	DWORD dwCurPlayPos = 0, dwCurPlaySample = 0;
	m_lpDSB->GetCurrentPosition(&dwCurPlayPos, NULL);
	dwCurPlaySample = dwCurPlayPos/m_WFE.nBlockAlign;

	//Caculate the samples played
	DWORD dwSamplesPlayed = 0;
	if (m_dwCircles2 < 1) {
		return dwCurPlaySample;
	}

	dwSamplesPlayed = (m_dwCircles2 - 1) * bufferLength * 2 + 3 * bufferLength / 2;		
	if (dwCurPlaySample > (3 * bufferLength / 2)) {
		if (m_dwCircles2 < m_dwCircles1) {
			dwSamplesPlayed = (m_dwCircles1-1) * 2 * bufferLength + 3 * bufferLength / 2;
		}
		dwSamplesPlayed += dwCurPlaySample - 3 * bufferLength / 2 + 1;				
	} else {
		dwSamplesPlayed += dwCurPlaySample + bufferLength / 2;
	}

	CString strSamplesPlayed;
	strSamplesPlayed.Format(_T("Samples Played: %d \n"), dwSamplesPlayed);
	OutputDebugString(strSamplesPlayed);

	return dwSamplesPlayed;
}
//</GetSamplePlaying>

void AudioDirectSound::SetCallback(LPGETAUDIOSAMPLES_PROGRESS Function_Callback, LPVOID lpData)
{
	m_lpGETAUDIOSAMPLES = Function_Callback;
	m_lpData = lpData;
}
//</SetCallback>

void AudioDirectSound::TimerCallback()
{
	LPVOID lpvAudio1 = NULL, lpvAudio2 = NULL;
	DWORD dwBytesAudio1 = 0, dwBytesAudio2 = 0;
	DWORD dwRetSamples = 0, dwRetBytes = 0;

	HRESULT hr = WaitForMultipleObjects(2, m_pHEvent, FALSE, 0);
	if(WAIT_OBJECT_0 == hr) {

		m_dwCircles1++;

		//Lock DirectSoundBuffer Second Part
		HRESULT hr = m_lpDSB->Lock(bufferLength * 2, bufferLength * 2, 
			&lpvAudio1, &dwBytesAudio1, &lpvAudio2, &dwBytesAudio2, 0);
		if ( FAILED(hr) ) {
			m_strLastError = _T("Lock DirectSoundBuffer Failed!");
			OutputDebugString(m_strLastError);
			return;
		}		
	} else if (WAIT_OBJECT_0 + 1 == hr) {		

		m_dwCircles2++;

		//Lock DirectSoundBuffer First Part
		HRESULT hr = m_lpDSB->Lock(0, bufferLength * 2, &lpvAudio1, &dwBytesAudio1, 
			&lpvAudio2, &dwBytesAudio2, 0);
		if ( FAILED(hr) ) {
			m_strLastError = _T("Lock DirectSoundBuffer Failed!");
			OutputDebugString(m_strLastError);
			return;
		}		
	} else {
		return;
	}

	// Fill audio buffer via callback function
	m_lpGETAUDIOSAMPLES(m_lpAudioBuf, bufferLength * 2, dwRetSamples, m_lpData);

	//Copy AudioBuffer to DirectSoundBuffer
	if (NULL == lpvAudio2) {
		memcpy(lpvAudio1, m_lpAudioBuf, dwBytesAudio1);
	} else {
		memcpy(lpvAudio1, m_lpAudioBuf, dwBytesAudio1);
		memcpy(lpvAudio2, m_lpAudioBuf + dwBytesAudio1, dwBytesAudio2);
	}

	//Unlock DirectSoundBuffer
	m_lpDSB->Unlock(lpvAudio1, dwBytesAudio1, lpvAudio2, dwBytesAudio2);
}
//</TimerCallback>

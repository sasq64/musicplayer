// WtlTedPlay.cpp : main source file for WtlTedPlay.exe
//

#include "stdafx.h"
#include <atlframe.h>
#include <atlctrls.h>
#include <atldlgs.h>

#include "resource.h"
#include "MainFrm.h"
#include "PlayList.h"
#include "registry.h"

#include "tedmem.h"
#include "tedplay.h"

#ifdef HAVE_SDL
#include <SDL.h>
#include "AudioSDL.h"
#else
#include "AudioDirectSound.h"
#endif

CAppModule _Module;

// make sure the message loop is destroyed before CoUninitialize gets called
static int Run(LPTSTR /*lpstrCmdLine*/ = NULL, int nCmdShow = SW_SHOWDEFAULT)
{
	CMessageLoop theLoop;
	_Module.AddMessageLoop(&theLoop);

	CMainFrame dlgMain;
	dlgMain.Create(NULL);

	unsigned int defaultSampleRate = 0;
	getRegistryValue(_T("SampleRate"), defaultSampleRate);
	if (!defaultSampleRate || defaultSampleRate > 192000) {
		defaultSampleRate = 48000;
		setRegistryValue(_T("SampleRate"), defaultSampleRate);
	}

	unsigned int bufferLengthInMsec = 0;
	getRegistryValue(_T("BufferLengthInMsec"), bufferLengthInMsec);
	if (!bufferLengthInMsec || bufferLengthInMsec > 1000) {
		bufferLengthInMsec = 200;
		setRegistryValue(_T("BufferLengthInMsec"), bufferLengthInMsec);
	}

	unsigned int filterOrder = 0;
	getRegistryValue(_T("FilterOrder"), filterOrder);
	if (!filterOrder || filterOrder > 1024 || filterOrder < 4) {
		filterOrder = 12;
		setRegistryValue(_T("FilterOrder"), filterOrder);
	}

	try {
#ifdef HAVE_SDL
		int retval = tedplayMain( __argv[1], new AudioSDL(machineInit(defaultSampleRate, filterOrder), defaultSampleRate,
			bufferLengthInMsec));
#else
		int retval = tedplayMain( __argv[1], 
			new AudioDirectSound(machineInit(defaultSampleRate, filterOrder), 
				TED_SOUND_CLOCK, defaultSampleRate, bufferLengthInMsec));
#endif
		// Read settings
		// probably no race condition yet...
		unsigned int regVal = 0;
		if (getRegistryValue(_T("DisableSID"), regVal) && regVal) {
			tedPlaySidEnable(false, 0);
			::CheckMenuItem(dlgMain.GetMenu(), ID_TOOLS_DISABLESID, MF_CHECKED);
		}
		regVal = 0;
		// read waveform settings
		if (getRegistryValue(_T("TedChannel1WaveForm"), regVal) && regVal) {
			tedPlaySetWaveform(0, regVal);
		} else {
			regVal = 1;
			tedPlaySetWaveform(0, 1);
		}
		::CheckMenuItem(dlgMain.GetMenu(), ID_TEDCHANNEL1_SQUAREWAVE + regVal - 1, MF_CHECKED);
		regVal = 0;
		if (getRegistryValue(_T("TedChannel2WaveForm"), regVal) && regVal) {
			tedPlaySetWaveform(1, regVal);
		} else {
			regVal = 1;
			tedPlaySetWaveform(1, 1);
		}
		::CheckMenuItem(dlgMain.GetMenu(), ID_TEDCHANNEL2_SQUAREWAVE + regVal - 1, MF_CHECKED);
		
		// if playing a song specified in the command line, update the window title
		if (::PathFileExists(__argv[1])) {
			dlgMain.UpdateSubsong();
		}
	} catch (_TCHAR *str) {
		MessageBox(NULL, str, _T("Exception occured."), MB_OK | MB_ICONERROR);
	}
	int nRet = dlgMain.ShowWindow(SW_NORMAL);
	nRet = theLoop.Run();
	tedplayClose();
	
	_Module.RemoveMessageLoop();
	return nRet;
}

int WINAPI _tWinMain(HINSTANCE hInstance, HINSTANCE /*hPrevInstance*/, LPTSTR lpstrCmdLine, int nCmdShow)
{
#if _DEBUG // start memory leak checker
	/*_CrtSetDbgFlag( _CRTDBG_ALLOC_MEM_DF | _CRTDBG_CHECK_ALWAYS_DF |
		  _CRTDBG_LEAK_CHECK_DF );*/
#endif
	HRESULT hRes = ::CoInitialize(NULL);
// If you are running on NT 4.0 or higher you can use the following call instead to 
// make the EXE free threaded. This means that calls come in on a random RPC thread.
	//HRESULT hRes = ::CoInitializeEx(NULL, COINIT_MULTITHREADED);
	ATLASSERT(SUCCEEDED(hRes));

	HANDLE m_hMutex = ::CreateMutex(NULL, FALSE, _T("WinTedPlayInstance"));
	if( m_hMutex != NULL ) { // indicates running instance
		if(::GetLastError() == ERROR_ALREADY_EXISTS)
			return FALSE;   // forbid further processing
	}

	// this resolves ATL window thunking problem when Microsoft Layer for Unicode (MSLU) is used
	::DefWindowProc(NULL, 0, 0, 0L);

	AtlInitCommonControls(ICC_COOL_CLASSES | ICC_BAR_CLASSES
		| ICC_WIN95_CLASSES
		);	// add flags to support other controls

	hRes = _Module.Init(NULL, hInstance);
	ATLASSERT(SUCCEEDED(hRes));

	int nRet = Run(lpstrCmdLine, nCmdShow);

	_Module.Term();
	::CoUninitialize();

	if (m_hMutex)
		::CloseHandle(m_hMutex);

	return nRet;
}

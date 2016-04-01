// MainFrm.cpp : implmentation of the CMainFrame class
//
/////////////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "resource.h"

#include <string>
#include <sstream>
#include "Aboutdlg.h"
#include "MainFrm.h"
#include "PlayList.h"
#include "CFileOpenDialog.h"
#include "PropertiesDlg.h"
#include "PropSheet.h"

#include "Audio.h"
#include "Psid.h"
#include "TedPlay.h"

#include "registry.h"

#define APPNAME _T("WinTedPlay")
#define UPDATE_FREQ_MS 10

//Get EXE directory.
void CMainFrame::MakePathName(LPTSTR lpFileName)
{
   int length;

   length = ::GetModuleFileName( NULL, lpFileName, MAX_PATH);
   while (length > 0) {
		if (lpFileName[length] == TEXT('\\'))
			break;

        lpFileName[length] = TEXT('\0');
        length--;
   }
}

void CMainFrame::getDefaultPlayListPath(_TCHAR *sFullPath)
{
	_TCHAR dir[MAX_PATH];

	MakePathName(dir);
	::PathCombine(sFullPath, dir, _T("default.pls"));
}

LRESULT CMainFrame::OnInitDialog(UINT /*uMsg*/, WPARAM /*wParam*/, LPARAM /*lParam*/, BOOL& /*bHandled*/)
{
    //Bind keys...
    m_haccelerator = AtlLoadAccelerators(IDR_ACCELERATORS);
	//
	SetWindowText(APPNAME);
	CenterWindow();
	//
	HINSTANCE inst = _Module.GetResourceInstance();
	// load application icons
	HICON hIcon = (HICON)::LoadImage(inst, MAKEINTRESOURCE(IDI_APPICON), 
		IMAGE_ICON, ::GetSystemMetrics(SM_CXICON), ::GetSystemMetrics(SM_CYICON), LR_DEFAULTCOLOR);
	SetIcon(hIcon, TRUE);
	HICON hIconSmall = (HICON)::LoadImage(inst, MAKEINTRESOURCE(IDI_APPICON), 
		IMAGE_ICON, ::GetSystemMetrics(SM_CXSMICON), ::GetSystemMetrics(SM_CYSMICON), LR_DEFAULTCOLOR);
	SetIcon(hIconSmall, FALSE);
	// load menu
	HMENU hmenu = ::LoadMenu(inst, MAKEINTRESOURCE(IDR_MENU));
	menu.Attach(hmenu);
	SetMenu(menu);

	// set icons
	//HICON hicon = (HICON) ::LoadImage(inst, MAKEINTRESOURCE(IDI_ICON_PLAY), 
	//	IMAGE_ICON, 16, 16, LR_DEFAULTCOLOR | LR_LOADTRANSPARENT);
	//btnTemp.Attach(GetDlgItem(IDC_BUTTON_TEST));
	//btnTemp.SetIcon(hicon);

	// Edit controls
	stTitle.Attach(GetDlgItem(IDC_EDIT_MODULE));
	stAuthor.Attach(GetDlgItem(IDC_EDIT_AUTHOR3));
	stCopyright.Attach(GetDlgItem(IDC_EDIT_COPYRIGHT));
	stSubsong.Attach(GetDlgItem(IDC_EDIT_SUBSONG));
	stTime.Attach(GetDlgItem(IDC_EDIT_TIME));
	// Buttons
	btnPrev.Attach(GetDlgItem(IDC_BUTTON_PREV));
	btnNext.Attach(GetDlgItem(IDC_BUTTON_NEXT));
	btnPlay.Attach(GetDlgItem(IDC_BUTTON_PLAY));
	btnPause.Attach(GetDlgItem(IDC_BUTTON_PAUSE));
	btnStop.Attach(GetDlgItem(IDC_BUTTON_STOP));
	// Trackbars/sliders
	trackBars[TB_VOLUME].Attach(GetDlgItem(IDC_SLIDER_VOLUME));
	trackBars[TB_VOLUME].SetRange(0, 10, TRUE);
	trackBars[TB_VOLUME].SetTic(8);
	//trackBars[TB_VOLUME].SetTicFreq(1);
	trackBars[TB_VOLUME].SetPos(8);
	trackBars[TB_SPEED].Attach(GetDlgItem(IDC_SLIDER_SPEED));
	trackBars[TB_SPEED].SetRange(1, 5, TRUE);
	trackBars[TB_SPEED].SetTic(1);
	trackBars[TB_SPEED].SetPos(3);
	DoDataExchange();
	// checkboxes
	cbChannels[0].Attach(GetDlgItem(IDC_CHECK1));
	cbChannels[1].Attach(GetDlgItem(IDC_CHECK2));
	cbChannels[2].Attach(GetDlgItem(IDC_CHECK3));
	cbChannels[0].SetCheck(1);
	cbChannels[1].SetCheck(1);
	cbChannels[2].SetCheck(1);

	// fire up the playlist
	EnableMenuItem(GetMenu(), IDM_VIEW_PLAYLIST, MF_ENABLED);
	playListViewDialog.Create(m_hWnd); //, rc, 0);
	// I needed this because GetParent wouldn't work...
	playListViewDialog.setParent(m_hWnd);

	// get the playlist
	_TCHAR plPath[MAX_PATH];
	getDefaultPlayListPath(plPath);
	playListViewDialog.loadPlaylist(plPath);
	// the control buttons
	enableButtons(0);
	// set focus to the volume control so no caret is shown
	trackBars[TB_VOLUME].SetFocus();

	// register object for message filtering and idle updates
	CMessageLoop* pLoop = _Module.GetMessageLoop();
	ATLASSERT(pLoop != NULL);
	pLoop->AddMessageFilter(this);
	pLoop->AddIdleHandler(this);
	//
		
	// Read settings
	unsigned int regVal = 0;
	if (getRegistryValue(_T("ShowPlayList"), regVal) && regVal) {
		playListViewDialog.ShowWindow(SW_NORMAL);
		::CheckMenuItem(GetMenu(), IDM_VIEW_PLAYLIST, MF_CHECKED);
	}
	if (getRegistryValue(_T("ShowWavePlotter"), regVal) && !regVal) {
		::CheckMenuItem(GetMenu(), ID_VIEW_SHOWWAVEPLOTTER, MF_UNCHECKED);
		::ShowWindow(GetDlgItem(IDC_WAVEOUT), SW_HIDE);
	}
	else
		::CheckMenuItem(GetMenu(), ID_VIEW_SHOWWAVEPLOTTER, MF_CHECKED);
	regVal = vAutoSkipInterval = 0;
	if (getRegistryValue(_T("AutoSkipInterval"), regVal) && regVal) {
		vAutoSkipInterval = regVal;
		SetTimer(0, regVal * 1000);
	}

	return 0;
}

LRESULT CMainFrame::OnDestroy(UINT /*uMsg*/, WPARAM /*wParam*/, LPARAM /*lParam*/, BOOL& bHandled)
{
	// finish recording if applicable
	if (::GetMenuState(GetMenu(), IDM_FILE_CREATEWAV, MF_BYCOMMAND) == MF_CHECKED)
		tedPlayCloseWav();
	// save waveforms
	setRegistryValue(_T("TedChannel1WaveForm"), tedPlayGetWaveform(0));
	setRegistryValue(_T("TedChannel2WaveForm"), tedPlayGetWaveform(1));
	setRegistryValue(_T("AutoSkipInterval"), vAutoSkipInterval);
	// stop playing
	tedplayStop();
	// save the playlist
	_TCHAR plPath[MAX_PATH];
	getDefaultPlayListPath(plPath);
	playListViewDialog.savePlaylist(plPath);
	// unregister message filtering and idle updates
	CMessageLoop* pLoop = _Module.GetMessageLoop();
	ATLASSERT(pLoop != NULL);
	pLoop->RemoveMessageFilter(this);
	pLoop->RemoveIdleHandler(this);
	// save settings
	LONG regVal = playListViewDialog.IsWindowVisible();
	setRegistryValue(_T("ShowPlayList"), regVal);
	regVal = ::IsWindowVisible(GetDlgItem(IDC_WAVEOUT));
	setRegistryValue(_T("ShowWavePlotter"), regVal);
	regVal = GetMenuState(GetMenu(), ID_TOOLS_DISABLESID, MF_BYCOMMAND) == MF_CHECKED;
	setRegistryValue(_T("DisableSID"), regVal);
	//
	bHandled = FALSE;
	DestroyWindow();
	::PostQuitMessage(0);
	return 1;
}

LRESULT CMainFrame::OnMoving(UINT /*uMsg*/, WPARAM wParam, LPARAM lParam, BOOL& bHandled)
{
	LPRECT newRect = (LPRECT) lParam;
	// Move along playlist window
	//if (playListViewDialog.IsWindowVisible()) 
	{
		RECT rc;
		GetWindowRect(&rc);
        // get how much we moved
		int  newXdelta   = newRect->left - rc.left;
        int  newYdelta   = newRect->top - rc.top;
		// now get the playlist window's metrics
		::GetWindowRect(playListViewDialog.m_hWnd, &rc);
		int  width  = rc.right - rc.left;
        int  height = rc.bottom - rc.top;
		// Move along with the main window
		::MoveWindow(playListViewDialog.m_hWnd, 
			rc.left + newXdelta, rc.top + newYdelta, width, height, TRUE);
	}
	return 0;
}

LRESULT CMainFrame::OnTrackBar(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled)
{
	int value;

	bHandled = FALSE;
	for(int i = 0; i < TB_COUNT; i++) {
		if ((HWND) lParam == trackBars[i].m_hWnd) {

			switch ((int)LOWORD(wParam)) {
				case SB_THUMBTRACK:
				case SB_THUMBPOSITION:
					value = (short)HIWORD(wParam);
					bHandled = TRUE;
					break;
				case SB_ENDSCROLL:
				case SB_LINELEFT:
				case SB_LINERIGHT:
				case SB_PAGELEFT:
				case SB_PAGERIGHT:
					value = trackBars[i].GetPos();
					bHandled = TRUE;
					break;
				default:
					break;
			} // end switch
			switch (i) {
				case 0:
					if (tedPlayGetState()) {
						tedplayPause();
						tedPlaySetVolume(value);
						tedplayPlay();
					} else {
						tedPlaySetVolume(value);
					}
					break;
				case 1:
					if (tedPlayGetState()) {
						tedplayPause();
						tedPlaySetSpeed(value);
						tedplayPlay();
					} else {
						tedPlaySetSpeed(value);
					}
					break;
				default: ;
			}
			break;
		}
	}
	if (bHandled) {
	} // end if
	return bHandled;
}

LRESULT CMainFrame::OnTimer(UINT /*uMsg*/, WPARAM wParam, LPARAM lParam, BOOL& bHandled)
{
	switch (wParam) {
		case 0:
			if (tedPlayGetState() == 1)
				playListViewDialog.OnBnClickedBtnNextModule(0, 0, 0, bHandled);
			break;
		case 1:
			{
				static unsigned int prevSecs = -1;
				unsigned int secs = tedplayGetSecondsPlayed();
				if (prevSecs != secs) {
					prevSecs = secs;
					unsigned int hour = secs / 3600;
					unsigned int minute = (secs - hour * 60) / 60;
					unsigned int sec = secs - hour * 3600 - minute * 60;
					_TCHAR txt[64];
					_stprintf(txt, _T("%02u:%02u:%02u"), hour, minute, sec);
					stTime.SetWindowText(txt);
				}
				if (::IsWindowVisible(GetDlgItem(IDC_WAVEOUT)))
					updateWaveOutWindow(true);
			}
			break;
	}
	return 0L;
}

LRESULT CMainFrame::OnPaint(UINT /*uMsg*/, WPARAM wParam, LPARAM lParam, BOOL& bHandled)
{
	PAINTSTRUCT ps; 
    HDC hdc;

	hdc = BeginPaint(&ps);
	//::FillRect(hdc, &rc, (HBRUSH) GetStockObject(BLACK_BRUSH));
	updateWaveOutWindow(false);
	EndPaint(&ps);
	return 0L;
}

void CMainFrame::updateWaveOutWindow(bool updatePosition)
{
	RECT rc;
	static unsigned int sampPos = 0;
	static unsigned int wWidth = -1;
	static unsigned int wHeight = -1;
	static short *sampHist = NULL;
	HWND uwHwnd = GetDlgItem(IDC_WAVEOUT);
	HDC hdc = ::GetDC(uwHwnd);

	// get window metrics
	::GetClientRect(uwHwnd, &rc);
	wWidth = rc.right - rc.left;
	wHeight = rc.bottom - rc.top;
	// fill with black
	int r = ::FillRect(hdc, &rc, (HBRUSH) GetStockObject(DKGRAY_BRUSH));
	// set up
	if (wWidth == -1 || !sampHist) {
		if (sampHist) {
			delete [] sampHist;
		}
		sampHist = new short[wWidth + 1];
		// pre-fill with silence
		for(unsigned int i = 0; i <= wWidth; i++)
			sampHist[i] = wHeight / 2;
		sampPos = 0;
	}
	// update sample history, convert to coordinate
	if (updatePosition && tedPlayGetState()) {
		unsigned int i;
		int sample = ((tedPlayGetLastSample() + 8192) * wHeight) / 16384;
		sample = sample <= 0 ? 1 : (sample >= (int)wHeight ? wHeight - 2 : sample);

		sampHist[sampPos] = (short) sample;
		sampPos = (sampPos + 1) % wWidth;
		// create pen
		COLORREF qLineColor = RGB(0, 255, 0);
		HPEN hLinePen = ::CreatePen(PS_SOLID, 1, qLineColor);
		::SelectObject(hdc, GetStockObject(COLOR_WINDOW + 1));
		// draw wave
		unsigned int plotPos = sampPos;
		::MoveToEx(hdc, 0, sampHist[plotPos], NULL);
		for(i = 0; i < wWidth; i++) {
			short s = sampHist[plotPos];
			plotPos = (plotPos + 1) % wWidth;
			::LineTo(hdc, i, s);
		}
		// last plot
		//HPEN hPenOld = (HPEN) ::SelectObject(hdc, hLinePen);
		LineTo(hdc, wWidth, sampHist[plotPos]);
		//::SetPixel(hdc, wWidth, sampHist[plotPos], RGB(0, 255, 0));
		//::SelectObject(hdc, hPenOld);
		//
		::DeleteObject(hLinePen);
	}
	// clean up
	::ReleaseDC(uwHwnd, hdc);
}

LRESULT CMainFrame::OnResetAutoSkipTimerFromChildWnd(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled)
{
	if (vAutoSkipInterval) {
		KillTimer(0);
		SetTimer(0, vAutoSkipInterval * 1000);
		// reset the time
		stTime.SetWindowText(_T("00:00:00"));
		tedPlayResetCycleCounter();
	}
	return 0L;
}

LRESULT CMainFrame::OnFileExit(WORD /*wNotifyCode*/, WORD /*wID*/, HWND /*hWndCtl*/, BOOL& /*bHandled*/)
{
	DestroyWindow();
	::PostQuitMessage(0);
	return 0L;
}

LRESULT CMainFrame::OnFileNew(WORD /*wNotifyCode*/, WORD /*wID*/, HWND /*hWndCtl*/, BOOL& /*bHandled*/)
{
	static unsigned int selFilter = 0;
	_TCHAR szFilter[] = _T("All suported formats (*.c8m;*.prg;*.sid)\0"
						   "*.c8m;*.prg;*.sid\0"
						   "TED tunes (*.c8m;*.prg)\0"
						   "*.c8m;*.prg\0"
						   "SID tunes (*.sid)\0*.sid\0"
						   "All Files (*.*)\0*.*\0\0");
	WTL::CFileDialog wndFileDialog ( TRUE, NULL, NULL, 
		OFN_FILEMUSTEXIST | OFN_HIDEREADONLY | OFN_EXPLORER, 
		szFilter, m_hWnd );

	wndFileDialog.m_ofn.nFilterIndex = selFilter;
	if (IDOK == wndFileDialog.DoModal() ) {
		_TCHAR tmp[MAX_PATH];

		_tcscpy(tmp, wndFileDialog.m_szFileName);
		selFilter = wndFileDialog.m_ofn.nFilterIndex;
		stTime.SetWindowText(_T("00:00:00"));
		tedplayMain(tmp, NULL);
		UpdateSubsong();
	}

	//CFileOpenDialog dialog;
	//if (IDOK == dialog.DoModal()) {
	//	CString filePath;
	//	COM_VERIFY(dialog.GetFilePath(filePath));
	//	// Use file here...
	//}
	return 0L;
}

LRESULT CMainFrame::OnFileSaveToWav(WORD /*wNotifyCode*/, WORD /*wID*/, HWND /*hWndCtl*/, BOOL& /*bHandled*/)
{
	_TCHAR szFilter[] = _T("WAV files (*.wav)\0"
						   "*.wav\0"
						   "All Files (*.*)\0*.*\0\0");
	WTL::CFileDialog wndFileDialog( FALSE, NULL, NULL, 
		OFN_HIDEREADONLY | OFN_EXPLORER, 
		szFilter, m_hWnd);
	bool isChecked = ::GetMenuState(GetMenu(), 
		IDM_FILE_CREATEWAV, MF_BYCOMMAND) == MF_CHECKED;
	if (!isChecked) {
		bool wasPlaying = tedPlayGetState() == 1;
		if (wasPlaying) tedplayPause();
		if (IDOK == wndFileDialog.DoModal() ) {
			std::string filename = wndFileDialog.m_szFileName;
			PTSTR ext = ::PathFindExtension(filename.c_str()); 
			if (!*ext)
				filename += _T(".wav");
			if (tedPlayCreateWav(filename.c_str()))
				CheckMenuItem(GetMenu(), IDM_FILE_CREATEWAV, MF_CHECKED);
		}
		if (wasPlaying) tedplayPlay();
	} else {
		tedPlayCloseWav();
		CheckMenuItem(GetMenu(), IDM_FILE_CREATEWAV, MF_UNCHECKED);
	}
	return 0L;
}

LRESULT CMainFrame::OnFileProperties(WORD /*wNotifyCode*/, WORD /*wID*/, HWND /*hWndCtl*/, BOOL& /*bHandled*/)
{
	CPropertiesDlg dlg;
	dlg.DoModal();
	return 0;
}

LRESULT CMainFrame::OnViewPlaylist(WORD /*wNotifyCode*/, WORD /*wID*/, HWND /*hWndCtl*/, BOOL& /*bHandled*/)
{
	if (!playListViewDialog.IsWindowVisible()) {
		playListViewDialog.ShowWindow(SW_SHOWNOACTIVATE);
		::CheckMenuItem(GetMenu(), IDM_VIEW_PLAYLIST, MF_CHECKED);
	} else {
		playListViewDialog.ShowWindow(SW_HIDE);
		::CheckMenuItem(GetMenu(), IDM_VIEW_PLAYLIST, MF_UNCHECKED);
	}
	return 0;
}

LRESULT CMainFrame::OnDropFiles(UINT /*uMsg*/, WPARAM wParam, LPARAM /*lParam*/, BOOL& bHandled)
{
	HDROP hDrop = (HDROP) wParam;
	_TCHAR namebuffer[MAX_PATH];

	::DragQueryFile(hDrop, 0, namebuffer, MAX_PATH);
	if (tedplayMain(namebuffer, NULL)) 
		return 1;
	UpdateSubsong();
	::DragFinish(hDrop);
	::SetForegroundWindow(m_hWnd);
	return 0;
}

LRESULT CMainFrame::OnUpdateSongFromChildWnd(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled)
{
	UpdateSubsong();
	return 0;
}

LRESULT CMainFrame::OnAppAbout(WORD /*wNotifyCode*/, WORD /*wID*/, HWND /*hWndCtl*/, BOOL& /*bHandled*/)
{
	CAboutDlg dlg;
	dlg.DoModal();
	return 0;
}

void CMainFrame::enableButtons(unsigned int mask)
{
	btnPrev.EnableWindow(mask & 1);
	btnNext.EnableWindow(mask & 2);
	btnPlay.EnableWindow(mask & 4);
	btnPause.EnableWindow(mask & 8);
	btnStop.EnableWindow(mask & 0x10);
}

unsigned int CMainFrame::getButtonStates()
{
	unsigned int state;
	state = btnPrev.IsWindowEnabled() & 1;
	state |= (btnNext.IsWindowEnabled() << 1) & 2;
	state |= (btnPlay.IsWindowEnabled() << 2) & 4;
	state |= (btnPause.IsWindowEnabled() << 3) & 8;
	state |= (btnStop.IsWindowEnabled() << 4) & 0x10;
	return state;
}

void CMainFrame::UpdateSubsong()
{
	unsigned int c, t;
	_TCHAR txt[512];

	PsidHeader psid = getPsidHeader();

	_tcscpy(txt, psid.fileName.c_str());
	// strip path from file name
	PathStripPath(txt);
	// prepare window title
	std::string title(APPNAME);
	title += " - ";
	title += txt;
	SetWindowText(title.c_str());

	stAuthor.SetWindowText(psid.author);
	stTitle.SetWindowText(psid.title);
	stCopyright.SetWindowText(psid.copyright);

	tedPlayGetSongs(c, t);
	if (t) {
		_stprintf(txt, _T("%u of %u"), c, t);
		stSubsong.SetWindowText(txt);
		SetTimer(1, UPDATE_FREQ_MS);
	} else {
		stSubsong.SetWindowText(_T(""));
		stTime.SetWindowText(_T(""));
		KillTimer(1);
	}
	if (getPsidHeader().tracks > 1)
		enableButtons(0x1f - 4);
	else
		enableButtons(0x1c - 4);
}

LRESULT CMainFrame::OnClickedPrev(WORD /*wNotifyCode*/, WORD /*wID*/, HWND /*hWndCtl*/, BOOL& bHandled)
{
	tedplayPause();
	if (psidChangeTrack(-1)) {
		UpdateSubsong();
		OnResetAutoSkipTimerFromChildWnd(0, 0, 0, bHandled);
	}
	tedplayPlay();
	return 0L;
}

LRESULT CMainFrame::OnClickedNext(WORD /*wNotifyCode*/, WORD /*wID*/, HWND /*hWndCtl*/, BOOL& bHandled)
{
	tedplayPause();
	if (psidChangeTrack(+1)) {
		UpdateSubsong();
		OnResetAutoSkipTimerFromChildWnd(0, 0, 0, bHandled);
	}
	tedplayPlay();
	return 0L;
}

LRESULT CMainFrame::OnClickedPlay(WORD /*wNotifyCode*/, WORD /*wID*/, HWND /*hWndCtl*/, BOOL& /*bHandled*/)
{
	tedplayPlay();
	UpdateSubsong();
	unsigned int bmask = getButtonStates() & ~(4 + 8);
	enableButtons(bmask | 8);

	// restart auto-skip timer
	KillTimer(0);
	if (vAutoSkipInterval)
		SetTimer(0, vAutoSkipInterval * 1000);
	return 0L;
}

LRESULT CMainFrame::OnClickedPause(WORD /*wNotifyCode*/, WORD /*wID*/, HWND /*hWndCtl*/, BOOL& /*bHandled*/)
{
	tedplayPause();
	unsigned int bmask = getButtonStates() & ~(4 + 8);
	enableButtons(bmask | 4);
	return 0L;
}

LRESULT CMainFrame::OnClickedStop(WORD /*wNotifyCode*/, WORD /*wID*/, HWND /*hWndCtl*/, BOOL& /*bHandled*/)
{
	tedplayStop();
	unsigned int bmask = getButtonStates() & ~(4 + 8 + 0x10);
	enableButtons(bmask | 4);
	// reset the time
	stTime.SetWindowText(_T("00:00:00"));
	tedPlayResetCycleCounter();
	return 0L;
}

LRESULT CMainFrame::OnCheckBox1Clicked(WORD wNotifyCode, WORD wID, HWND hWndCtl, BOOL& bHandled)
{
	unsigned int enabled = cbChannels[0].GetCheck();
	bool wasPlaying = tedPlayGetState() == 1;
	if (wasPlaying) tedplayPause();
	tedPlayChannelEnable(0, !!enabled);
	if (wasPlaying) tedplayPlay();
	bHandled = TRUE;
	return 0L;
}

LRESULT CMainFrame::OnCheckBox2Clicked(WORD wNotifyCode, WORD /*wID*/, HWND hWndCtl, BOOL& bHandled)
{
	unsigned int enabled = cbChannels[1].GetCheck();
	bool wasPlaying = tedPlayGetState() == 1;
	if (wasPlaying) tedplayPause();
	tedPlayChannelEnable(1, !!enabled);
	if (wasPlaying) tedplayPlay();
	bHandled = TRUE;
	return 0L;
}

LRESULT CMainFrame::OnBnClickedCheck3(WORD /*wNotifyCode*/, WORD /*wID*/, HWND /*hWndCtl*/, BOOL& bHandled)
{
	unsigned int enabled = cbChannels[2].GetCheck();
	bool wasPlaying = tedPlayGetState() == 1;
	if (wasPlaying) tedplayPause();
	tedPlayChannelEnable(2, !!enabled);
	if (wasPlaying) tedplayPlay();
	bHandled = TRUE;
	return 0;
}

LRESULT CMainFrame::OnFileMemDump(WORD /*wNotifyCode*/, WORD /*wID*/, HWND /*hWndCtl*/, BOOL& /*bHandled*/)
{
	static unsigned int s = 0;
	_TCHAR name[256];
	_stprintf(name, _T("dump%04X.bin"), s++);
	dumpMem(name);
	return 0L;
}

LRESULT CMainFrame::OnToolsResetplayer(WORD /*wNotifyCode*/, WORD /*wID*/, HWND /*hWndCtl*/, BOOL& bHandled)
{
	tedplayPlay();
	machineReset();
	machineDoSomeFrames(25);
	OnClickedStop(0, 0, 0, bHandled);
	UpdateSubsong();
	return 0;
}

LRESULT CMainFrame::OnToolsDisablesid(WORD /*wNotifyCode*/, WORD /*wID*/, HWND /*hWndCtl*/, BOOL& /*bHandled*/)
{
	bool wasPlaying = tedPlayGetState() == 1;
	if (wasPlaying) tedplayPause();
	if (!GetMenuState(GetMenu(), ID_TOOLS_DISABLESID, MF_BYCOMMAND)) {
		tedPlaySidEnable(false, 0);
		::CheckMenuItem(GetMenu(), ID_TOOLS_DISABLESID, MF_CHECKED);
	} else {
		unsigned int enabled = cbChannels[0].GetCheck();
		enabled = enabled|(cbChannels[1].GetCheck() << 1);
		enabled = enabled|(cbChannels[2].GetCheck() << 2);
		tedPlaySidEnable(true, ~enabled);
		::CheckMenuItem(GetMenu(), ID_TOOLS_DISABLESID, MF_UNCHECKED);
	}
	if (wasPlaying) tedplayPlay();
	return 0;
}

LRESULT CMainFrame::OnToolsOptions(WORD /*wNotifyCode*/, WORD /*wID*/, HWND /*hWndCtl*/, BOOL& /*bHandled*/)
{
	static unsigned int lastPage = 0;
	CPropSheet cos(_T("Options"), lastPage);
	
	unsigned int audioLatency = cos.propPageAudio.vLatency;
	unsigned int audioSamplingRate = cos.propPageAudio.vSamplingRate;
	unsigned int audioFilterOrder = cos.propPageAudio.vFilterOrder;

	bool wasPlaying = tedPlayGetState() == 1;
	if (wasPlaying) tedplayPause();

	cos.propPageAudio.vAutoSkipInterval = vAutoSkipInterval;
	if (IDOK == cos.DoModal()) {
		bool restartReqd = (audioLatency != cos.propPageAudio.vLatency) 
			|| (audioSamplingRate != cos.propPageAudio.vSamplingRate);
		// filter order changed, update registry, reinit filter kernel
		if (audioFilterOrder != cos.propPageAudio.vFilterOrder) {
			audioFilterOrder = cos.propPageAudio.vFilterOrder;
			setRegistryValue(_T("FilterOrder"), audioFilterOrder);
			tedPlaySetFilterOrder(audioFilterOrder);
		}
		if (audioSamplingRate != cos.propPageAudio.vSamplingRate) {
			audioSamplingRate = cos.propPageAudio.vSamplingRate;
			setRegistryValue(_T("SampleRate"), audioSamplingRate);
		}
		if (audioLatency != cos.propPageAudio.vLatency) {
			audioLatency = cos.propPageAudio.vLatency;
			setRegistryValue(_T("BufferLengthInMsec"), audioLatency);
		}
		if (vAutoSkipInterval != cos.propPageAudio.vAutoSkipInterval) {
			vAutoSkipInterval = cos.propPageAudio.vAutoSkipInterval;
			KillTimer(0);
			if (vAutoSkipInterval)
				SetTimer(0, vAutoSkipInterval * 1000);
		}
		if (restartReqd) {
			MessageBox(_T("For the changes to take effect you have restart the application!"), _T("Warning!"), 
				MB_OK | MB_ICONINFORMATION);
		} else {
			//
		}
	}
	if (wasPlaying) tedplayPlay();
	return 0L;
}

LRESULT CMainFrame::OnTedchannel1waveformSquarewave(WORD /*wNotifyCode*/, WORD wID, HWND /*hWndCtl*/, BOOL& /*bHandled*/)
{
	CheckMenuItem(GetMenu(), ID_TEDCHANNEL1_SQUAREWAVE + tedPlayGetWaveform(0) - 1, MF_UNCHECKED);
	bool wasPlaying = tedPlayGetState() == 1;
	if (wasPlaying) tedplayPause();
	tedPlaySetWaveform(0, wID - ID_TEDCHANNEL1_SQUAREWAVE + 1);
	if (wasPlaying) tedplayPlay();
	CheckMenuItem(GetMenu(), wID, MF_CHECKED);
	return 0;
}

LRESULT CMainFrame::OnTedchannel2Squarewave(WORD /*wNotifyCode*/, WORD wID, HWND /*hWndCtl*/, BOOL& /*bHandled*/)
{
	CheckMenuItem(GetMenu(), ID_TEDCHANNEL2_SQUAREWAVE + tedPlayGetWaveform(1) - 1, MF_UNCHECKED);
	bool wasPlaying = tedPlayGetState() == 1;
	if (wasPlaying) tedplayPause();
	tedPlaySetWaveform(1, wID - ID_TEDCHANNEL2_SQUAREWAVE + 1);
	if (wasPlaying) tedplayPlay();
	CheckMenuItem(GetMenu(), wID, MF_CHECKED);
	return 0;
}

LRESULT CMainFrame::OnViewShowwaveplotter(WORD /*wNotifyCode*/, WORD /*wID*/, HWND /*hWndCtl*/, BOOL& /*bHandled*/)
{
	HWND wpHwnd = GetDlgItem(IDC_WAVEOUT);
	BOOL wasVisible = ::IsWindowVisible(wpHwnd);
	// TODO: Add your command handler code here
	if (wasVisible) {
		::ShowWindow(wpHwnd, SW_HIDE);
	} else {
		::ShowWindow(wpHwnd, SW_SHOWNA);
	}
	::CheckMenuItem(GetMenu(), ID_VIEW_SHOWWAVEPLOTTER, wasVisible ? MF_UNCHECKED : MF_CHECKED);
	return 0;
}

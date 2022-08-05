// MainFrm.h : interface of the CMainFrame class
//
/////////////////////////////////////////////////////////////////////////////
#pragma once

#include <atldlgs.h>
#include <atlddx.h>
//#include "ddxext.h"

#include "PlayList.h"

class CMainFrame : public CDialogImpl<CMainFrame>, public CUpdateUI<CMainFrame>,
	public CMessageFilter, public CIdleHandler
	//,public CWinDataExchangeEx<CMainFrame>
{
public:

	enum { IDD = IDD_FORMVIEW };

	CMainFrame() {
		m_haccelerator = NULL;
	}
	virtual BOOL PreTranslateMessage(MSG* pMsg) {
		// Check shortcut keys first...
		if(m_haccelerator != NULL) {
			if(::TranslateAccelerator(m_hWnd, m_haccelerator, pMsg))
				return TRUE;
		}
		BOOL retval = CWindow::IsDialogMessage(pMsg);
		return retval;
	}
	virtual BOOL OnIdle() {
		return FALSE;
	}

	BEGIN_UPDATE_UI_MAP(CMainFrame)
	END_UPDATE_UI_MAP()

	BEGIN_DDX_MAP(CMainFrame)
		//DDX_CHECK(IDC_CHECK1, channelOn[0])
		//DDX_CHECK(IDC_CHECK1, channelOn[1])
	END_DDX_MAP()

	BEGIN_MSG_MAP(CMainFrame)
		MESSAGE_HANDLER(WM_INITDIALOG, OnInitDialog)
		MESSAGE_HANDLER(WM_HSCROLL, OnTrackBar)
		MESSAGE_HANDLER(WM_CLOSE, OnDestroy)
		MESSAGE_HANDLER(WM_DROPFILES, OnDropFiles)
		MESSAGE_HANDLER(WM_MOVING, OnMoving)
		MESSAGE_HANDLER(WM_TIMER, OnTimer)
		MESSAGE_HANDLER(WM_PAINT, OnPaint)
		// user messages
		MESSAGE_HANDLER(WM_USER + 1, OnUpdateSongFromChildWnd)
		MESSAGE_HANDLER(WM_USER + 2, OnResetAutoSkipTimerFromChildWnd)
		/*MESSAGE_HANDLER(WM_GETMINMAXINFO, OnGetMinMaxInfo)*/
        
		COMMAND_HANDLER(IDC_CHECK1, BN_CLICKED, OnCheckBox1Clicked)
		COMMAND_HANDLER(IDC_CHECK2, BN_CLICKED, OnCheckBox2Clicked)

		COMMAND_HANDLER(IDC_BUTTON_PREV, BN_CLICKED, OnClickedPrev)
		COMMAND_HANDLER(IDC_BUTTON_NEXT, BN_CLICKED, OnClickedNext)
		COMMAND_HANDLER(IDC_BUTTON_PLAY, BN_CLICKED, OnClickedPlay)
		COMMAND_HANDLER(IDC_BUTTON_PAUSE, BN_CLICKED, OnClickedPause)
		COMMAND_HANDLER(IDC_BUTTON_STOP, BN_CLICKED, OnClickedStop)
		COMMAND_ID_HANDLER(ID_CONTROL_PREVIOUSSUBTUNE, OnClickedPrev)
		COMMAND_ID_HANDLER(ID_CONTROL_NEXTSUBTUNE, OnClickedNext)
		COMMAND_ID_HANDLER(ID_CONTROL_PLAY, OnClickedPlay)
		COMMAND_ID_HANDLER(ID_CONTROL_PAUSE, OnClickedPause)
		COMMAND_ID_HANDLER(ID_CONTROL_STOP, OnClickedStop)
		COMMAND_HANDLER(IDC_CHECK3, BN_CLICKED, OnBnClickedCheck3)
		
		COMMAND_ID_HANDLER(IDM_FILE_EXIT, OnFileExit)
		COMMAND_ID_HANDLER(IDM_FILE_OPEN, OnFileNew)
		COMMAND_ID_HANDLER(IDM_FILE_CREATEWAV, OnFileSaveToWav)
		COMMAND_ID_HANDLER(ID_FILE_MEMORYDUMP, OnFileMemDump)
		COMMAND_ID_HANDLER(IDM_FILE_PROPERTIES, OnFileProperties)
		COMMAND_ID_HANDLER(IDM_VIEW_PLAYLIST, OnViewPlaylist)
		COMMAND_ID_HANDLER(IDM_HELP_ABOUT, OnAppAbout)
		COMMAND_ID_HANDLER(IDM_TOOLS_OPTIONS, OnToolsOptions)
		COMMAND_ID_HANDLER(ID_TOOLS_RESETPLAYER, OnToolsResetplayer)
		COMMAND_ID_HANDLER(ID_TOOLS_DISABLESID, OnToolsDisablesid)
		COMMAND_RANGE_HANDLER(ID_TEDCHANNEL1_SQUAREWAVE, ID_TEDCHANNEL1_SQUSAWTRIAN, 
			OnTedchannel1waveformSquarewave)
		COMMAND_RANGE_HANDLER(ID_TEDCHANNEL2_SQUAREWAVE, ID_TEDCHANNEL2_SQUSAWTRIAN, 
			OnTedchannel2Squarewave)
			CHAIN_MSG_MAP(CUpdateUI<CMainFrame>)
		COMMAND_ID_HANDLER(ID_VIEW_SHOWWAVEPLOTTER, OnViewShowwaveplotter)
	END_MSG_MAP()

	LRESULT OnInitDialog(UINT /*uMsg*/, WPARAM /*wParam*/, LPARAM /*lParam*/, BOOL& /*bHandled*/);
	LRESULT OnDestroy(UINT /*uMsg*/, WPARAM /*wParam*/, LPARAM /*lParam*/, BOOL& bHandled);
	LRESULT OnDropFiles(UINT /*uMsg*/, WPARAM wParam, LPARAM lParam, BOOL& bHandled);
	LRESULT OnMoving(UINT /*uMsg*/, WPARAM wParam, LPARAM lParam, BOOL& bHandled);
	LRESULT OnTimer(UINT /*uMsg*/, WPARAM wParam, LPARAM lParam, BOOL& bHandled);
	LRESULT OnPaint(UINT /*uMsg*/, WPARAM wParam, LPARAM lParam, BOOL& bHandled);
	//LRESULT OnGetMinMaxInfo(UINT /*uMsg*/, WPARAM wParam, LPARAM lParam, BOOL& bHandled);
	LRESULT OnTrackBar(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled);
	LRESULT OnUpdateSongFromChildWnd(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled);
	LRESULT OnResetAutoSkipTimerFromChildWnd(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled);

	LRESULT OnFileExit(WORD /*wNotifyCode*/, WORD /*wID*/, HWND /*hWndCtl*/, BOOL& /*bHandled*/);
	LRESULT OnFileNew(WORD /*wNotifyCode*/, WORD /*wID*/, HWND /*hWndCtl*/, BOOL& /*bHandled*/);
	LRESULT OnFileSaveToWav(WORD /*wNotifyCode*/, WORD /*wID*/, HWND /*hWndCtl*/, BOOL& /*bHandled*/);
	LRESULT OnFileMemDump(WORD /*wNotifyCode*/, WORD /*wID*/, HWND /*hWndCtl*/, BOOL& /*bHandled*/);

	LRESULT OnFileProperties(WORD /*wNotifyCode*/, WORD /*wID*/, HWND /*hWndCtl*/, BOOL& /*bHandled*/);
	LRESULT OnViewPlaylist(WORD /*wNotifyCode*/, WORD /*wID*/, HWND /*hWndCtl*/, BOOL& /*bHandled*/);
	LRESULT OnAppAbout(WORD /*wNotifyCode*/, WORD /*wID*/, HWND /*hWndCtl*/, BOOL& /*bHandled*/);
	LRESULT OnToolsOptions(WORD /*wNotifyCode*/, WORD /*wID*/, HWND /*hWndCtl*/, BOOL& /*bHandled*/);

	LRESULT OnClickedPrev(WORD /*wNotifyCode*/, WORD /*wID*/, HWND /*hWndCtl*/, BOOL& /*bHandled*/);
	LRESULT OnClickedNext(WORD /*wNotifyCode*/, WORD /*wID*/, HWND /*hWndCtl*/, BOOL& /*bHandled*/);
	LRESULT OnClickedPlay(WORD /*wNotifyCode*/, WORD /*wID*/, HWND /*hWndCtl*/, BOOL& /*bHandled*/);
	LRESULT OnClickedPause(WORD /*wNotifyCode*/, WORD /*wID*/, HWND /*hWndCtl*/, BOOL& /*bHandled*/);
	LRESULT OnClickedStop(WORD /*wNotifyCode*/, WORD /*wID*/, HWND /*hWndCtl*/, BOOL& /*bHandled*/);
	LRESULT OnCheckBox1Clicked(WORD /*wNotifyCode*/, WORD /*wID*/, HWND /*hWndCtl*/, BOOL& /*bHandled*/);
	LRESULT OnCheckBox2Clicked(WORD /*wNotifyCode*/, WORD /*wID*/, HWND /*hWndCtl*/, BOOL& /*bHandled*/);
	void UpdateSubsong();

protected:
	CMenu menu;
	CEdit stAuthor, stTitle, stCopyright, stSubsong, stTime; // CContainedWindowT<CStatic>
	CButton btnPrev, btnNext, btnPlay, btnPause, btnStop, btnTemp; // CContainedWindowT<CButton> 
	enum { TB_VOLUME = 0, TB_SPEED, TB_COUNT };
	CTrackBarCtrl trackBars[2];
	CButton cbChannels[3];
	void enableButtons(unsigned int mask);
	unsigned int getButtonStates();
	CPlayList playListViewDialog;
	unsigned int vAutoSkipInterval;
	
private:
	HACCEL    m_haccelerator;
public:
	LRESULT OnToolsResetplayer(WORD /*wNotifyCode*/, WORD /*wID*/, HWND /*hWndCtl*/, BOOL& /*bHandled*/);
	//Get EXE directory.
	static void MakePathName(LPTSTR lpFileName);
	static void getDefaultPlayListPath(_TCHAR *sFullPath);
	LRESULT OnBnClickedCheck3(WORD /*wNotifyCode*/, WORD /*wID*/, HWND /*hWndCtl*/, BOOL& /*bHandled*/);
	LRESULT OnToolsDisablesid(WORD /*wNotifyCode*/, WORD /*wID*/, HWND /*hWndCtl*/, BOOL& /*bHandled*/);
	LRESULT OnTedchannel1waveformSquarewave(WORD /*wNotifyCode*/, WORD /*wID*/, HWND /*hWndCtl*/, BOOL& /*bHandled*/);
	LRESULT OnTedchannel2Squarewave(WORD /*wNotifyCode*/, WORD /*wID*/, HWND /*hWndCtl*/, BOOL& /*bHandled*/);
	void updateWaveOutWindow(bool updatePosition);
	LRESULT OnViewShowwaveplotter(WORD /*wNotifyCode*/, WORD /*wID*/, HWND /*hWndCtl*/, BOOL& /*bHandled*/);
};

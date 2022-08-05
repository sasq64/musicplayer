#pragma once

#include <atldlgs.h>
#include <atlddx.h>
//#include "ddxext.h"

class CPlayList :
	public CDialogImpl<CPlayList>, public CUpdateUI<CPlayList>,
	public CMessageFilter, public CIdleHandler
	//,public CWinDataExchangeEx<CPlayList>
	,public CDialogResize<CPlayList>
{
public:
	enum { IDD = IDD_DLG_PLAYLIST };

	CPlayList() : m_iSortColumn(-1), m_bSortDescending(false) {
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

	BEGIN_UPDATE_UI_MAP(CPlayList)
	END_UPDATE_UI_MAP()

	BEGIN_DDX_MAP(CPlayList)
	END_DDX_MAP()

	BEGIN_MSG_MAP(CPlayList)
		MESSAGE_HANDLER(WM_CLOSE, OnDestroy)
		MESSAGE_HANDLER(WM_DROPFILES, OnDropFiles)
		MESSAGE_HANDLER(WM_GETMINMAXINFO, OnGetMinMaxInfo)
		MESSAGE_HANDLER(WM_INITDIALOG, OnInitDialog)
		MESSAGE_HANDLER(WM_SIZING, OnResizing)
		MESSAGE_HANDLER(WM_HOTKEY, OnHotkey)
		MESSAGE_RANGE_HANDLER(WM_MOUSEFIRST, WM_MOUSELAST, OnMouseMessage)
		NOTIFY_HANDLER(IDC_LSV1, LVN_COLUMNCLICK, OnLvnColumnclickLsv)
		NOTIFY_HANDLER(IDC_LSV1, NM_DBLCLK, OnNMDblclkLsv)
		NOTIFY_HANDLER(IDC_LSV1, LVN_KEYDOWN, OnLvnKeydownLsv1)
		COMMAND_ID_HANDLER(ID_PLAYLIST_SELECTALL, OnSelectAll)
		COMMAND_HANDLER(IDC_BTN_ADD, BN_CLICKED, OnBnClickedBtnAdd)
		COMMAND_HANDLER(IDC_BTN_REMOVE, BN_CLICKED, OnBnClickedBtnRemove)
		COMMAND_HANDLER(IDC_BTN_ADDFOLDER, BN_CLICKED, OnBnClickedBtnAddfolder)
		COMMAND_HANDLER(IDC_PLAY_TUNE, BN_CLICKED, OnPlayTune)
		NOTIFY_HANDLER(IDC_LSV1, NM_RCLICK, OnNMRclickLsv1)
		NOTIFY_HANDLER(IDC_LSV1, NM_RETURN, OnLvReturn)
		COMMAND_ID_HANDLER(ID_ROOT_OPENFILELOCATION, OnRootOpenfilelocation)
		COMMAND_HANDLER(IDC_BTN_LOADPL, BN_CLICKED, OnBnClickedBtnLoadpl)
		COMMAND_HANDLER(IDC_BTN_SAVEPL, BN_CLICKED, OnBnClickedBtnSavepl)
		COMMAND_HANDLER(IDC_BTN_NEXTMODULE, BN_CLICKED, OnBnClickedBtnNextModule)
		COMMAND_HANDLER(IDC_BTN_PLAYSELECTION, BN_CLICKED, OnBnClickedBtnPlayselection)
		COMMAND_HANDLER(IDC_BTN_PREVMODULE, BN_CLICKED, OnBnClickedBtnPrevmodule)
		CHAIN_MSG_MAP(CDialogResize<CPlayList>)
		CHAIN_MSG_MAP(CUpdateUI<CPlayList>)
	END_MSG_MAP()

	BEGIN_DLGRESIZE_MAP(CPlayList)
		DLGRESIZE_CONTROL(IDC_LSV1, DLSZ_SIZE_X | DLSZ_SIZE_Y)
		DLGRESIZE_CONTROL(IDC_BTN_ADD, DLSZ_MOVE_Y)
		DLGRESIZE_CONTROL(IDC_BTN_REMOVE, DLSZ_MOVE_Y)
		DLGRESIZE_CONTROL(IDC_BTN_ADDFOLDER, DLSZ_MOVE_Y)
		DLGRESIZE_CONTROL(IDC_BTN_LOADPL, DLSZ_MOVE_Y)
		DLGRESIZE_CONTROL(IDC_BTN_SAVEPL, DLSZ_MOVE_Y)
		DLGRESIZE_CONTROL(IDC_BTN_PREVMODULE, DLSZ_MOVE_Y | DLSZ_MOVE_X)
		DLGRESIZE_CONTROL(IDC_BTN_PLAYSELECTION, DLSZ_MOVE_Y | DLSZ_MOVE_X)
		DLGRESIZE_CONTROL(IDC_BTN_NEXTMODULE, DLSZ_MOVE_Y | DLSZ_MOVE_X)
    END_DLGRESIZE_MAP()

	int savePlaylist(_TCHAR * plName);
	int loadPlaylist(_TCHAR * plName);
	bool EnumerateFolder(LPCTSTR lpcszFolder, LPTSTR ext, int nLevel = 0);
	void setParent(HWND parent) { m_hwndParent = parent; };

protected:
	enum {
		LV_FIELD_FILENAME = 0,
		LV_FIELD_TITLE,
		LV_FIELD_AUTHOR,
		LV_FIELD_RELEASED,
		LV_FIELD_PATH,
		LV_FIELD_STATUS,
		LV_FIELD_TYPE,
		LV_FIELD_LOAD_ADDRESS,
		LV_FIELD_INDEX
	};
	CListViewCtrl playListView;
	HWND m_hwndParent;
	CButton btnAdd, btnRemove, btnAddFolder, btnLoadPlayList, btnSavePlayList;
	CButton btnPrevMod, btnPlayMod, btnNextMod;
	CToolTipCtrl m_wndToolTip[3];
	BOOL AddFileToPlaylist(_TCHAR *fullPath);
	
	// data members to handle sorting
	int m_iSortColumn; //initialize this to -1
	bool m_bSortDescending; //initialize this to false
	BOOL SortList(int iColumn, bool bDescending = false);
	void reIndex(int fromCol, int toCol);
	// this is called by SortList
	int GetColumnCount() { return playListView.GetHeader() ? playListView.GetHeader().GetItemCount() : 0; }
	//
	LRESULT OnInitDialog(UINT /*uMsg*/, WPARAM /*wParam*/, LPARAM /*lParam*/, BOOL& /*bHandled*/);
	LRESULT OnDestroy(UINT /*uMsg*/, WPARAM /*wParam*/, LPARAM /*lParam*/, BOOL& bHandled);
	LRESULT OnDropFiles(UINT /*uMsg*/, WPARAM wParam, LPARAM lParam, BOOL& bHandled);
	LRESULT OnHotkey(UINT /*uMsg*/, WPARAM wParam, LPARAM lParam, BOOL& bHandled);
	LRESULT OnLvReturn(int /*idCtrl*/, LPNMHDR pNMHDR, BOOL& /*bHandled*/);
	LRESULT OnGetMinMaxInfo(UINT /*uMsg*/, WPARAM wParam, LPARAM lParam, BOOL& bHandled);
	LRESULT OnResizing(UINT /*uMsg*/, WPARAM wParam, LPARAM lParam, BOOL& bHandled);
	LRESULT OnMouseMessage(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled);
	LRESULT OnSelectAll(WORD /*wNotifyCode*/, WORD /*wID*/, HWND /*hWndCtl*/, BOOL& /*bHandled*/);
	LRESULT OnPlayTune(WORD /*wNotifyCode*/, WORD /*wID*/, HWND /*hWndCtl*/, BOOL& /*bHandled*/);
	int stepPlayList(int direction);
public:
	LRESULT OnLvnColumnclickLsv(int /*idCtrl*/, LPNMHDR pNMHDR, BOOL& /*bHandled*/);
	LRESULT OnNMDblclkLsv(int idCtrl, LPNMHDR pNMHDR, BOOL& /*bHandled*/);
	LRESULT OnBnClickedBtnAdd(WORD /*wNotifyCode*/, WORD /*wID*/, HWND /*hWndCtl*/, BOOL& /*bHandled*/);
	LRESULT OnBnClickedBtnRemove(WORD /*wNotifyCode*/, WORD /*wID*/, HWND /*hWndCtl*/, BOOL& /*bHandled*/);
	LRESULT OnLvnKeydownLsv1(int /*idCtrl*/, LPNMHDR pNMHDR, BOOL& bHandled);
private:
	HACCEL    m_haccelerator;
public:
	LRESULT OnBnClickedBtnAddfolder(WORD /*wNotifyCode*/, WORD /*wID*/, HWND /*hWndCtl*/, BOOL& /*bHandled*/);
	LRESULT OnNMRclickLsv1(int /*idCtrl*/, LPNMHDR pNMHDR, BOOL& /*bHandled*/);
	LRESULT OnRootOpenfilelocation(WORD /*wNotifyCode*/, WORD /*wID*/, HWND /*hWndCtl*/, BOOL& /*bHandled*/);
	LRESULT OnBnClickedBtnLoadpl(WORD /*wNotifyCode*/, WORD /*wID*/, HWND /*hWndCtl*/, BOOL& /*bHandled*/);
	LRESULT OnBnClickedBtnSavepl(WORD /*wNotifyCode*/, WORD /*wID*/, HWND /*hWndCtl*/, BOOL& /*bHandled*/);
	LRESULT OnBnClickedBtnNextModule(WORD /*wNotifyCode*/, WORD /*wID*/, HWND /*hWndCtl*/, BOOL& bHandled);
	LRESULT OnBnClickedBtnPlayselection(WORD /*wNotifyCode*/, WORD /*wID*/, HWND /*hWndCtl*/, BOOL& /*bHandled*/);
	LRESULT OnBnClickedBtnPrevmodule(WORD /*wNotifyCode*/, WORD /*wID*/, HWND /*hWndCtl*/, BOOL& /*bHandled*/);
};

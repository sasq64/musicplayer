#pragma once

#include "Psid.h"

class CPropertiesDlg : public CDialogImpl<CPropertiesDlg>
{
public:
	enum { IDD = IDD_DIALOG_PROPERTIES };

	BEGIN_MSG_MAP(CPropertiesDlg)
		MESSAGE_HANDLER(WM_INITDIALOG, OnInitDialog)
		MESSAGE_HANDLER(WM_CLOSE, OnWmClose)
		COMMAND_ID_HANDLER(IDOK, OnCloseCmd)
		COMMAND_ID_HANDLER(IDCANCEL, OnCloseCmd)
	END_MSG_MAP()

	// Handler prototypes (uncomment arguments if needed):
	//	LRESULT MessageHandler(UINT /*uMsg*/, WPARAM /*wParam*/, LPARAM /*lParam*/, BOOL& /*bHandled*/)
	//	LRESULT CommandHandler(WORD /*wNotifyCode*/, WORD /*wID*/, HWND /*hWndCtl*/, BOOL& /*bHandled*/)
	//	LRESULT NotifyHandler(int /*idCtrl*/, LPNMHDR /*pnmh*/, BOOL& /*bHandled*/)

	LRESULT OnInitDialog(UINT /*uMsg*/, WPARAM /*wParam*/, LPARAM /*lParam*/, BOOL& /*bHandled*/)
	{
		CenterWindow(GetParent());
		SetWindowText(_T("Currently playing..."));
		properties.Attach(GetDlgItem(IDC_EDIT_PROPERTIES));
		properties.SetFont((HFONT) GetStockObject(OEM_FIXED_FONT), FALSE);
		_TCHAR txt[1024] = "Nothing";
		getPsidProperties(getPsidHeader(), txt);
		properties.AppendText(txt, TRUE);
		return TRUE;
	}
	LRESULT OnWmClose(UINT /*uMsg*/, WPARAM /*wParam*/, LPARAM /*lParam*/, BOOL& /*bHandled*/)
	{
		EndDialog(IDD_DIALOG_PROPERTIES);
		return 0;
	}
	LRESULT OnCloseCmd(WORD /*wNotifyCode*/, WORD wID, HWND /*hWndCtl*/, BOOL& /*bHandled*/)
	{
		EndDialog(wID);
		return 0;
	}
protected:
	CEdit properties;
};
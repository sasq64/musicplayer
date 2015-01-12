#include "stdafx.h"
#include <prsht.h>
#include <atlmisc.h>
#include <atlddx.h>

#include "resource.h"
#include "MainFrm.h"
#include "PropSheet.h"

//////////////////////////////////////////////////////////////////////
// Construction

CPropSheet::CPropSheet (_U_STRINGorID title, UINT uStartPage,
                               HWND hWndParent ) :
	CPropertySheetImpl<CPropSheet> (title, uStartPage, hWndParent ), m_bCentered(false), lastPage(0)
{
	m_psh.dwFlags |= 
		PSH_NOAPPLYNOW | 
		PSH_NOCONTEXTHELP;

	//AddPage(propPageMachine);
	AddPage(propPageAudio);
}

LRESULT CPropSheet::OnDestroy(UINT /*uMsg*/, WPARAM /*wParam*/, LPARAM /*lParam*/, BOOL& bHandled)
{
	lastPage = GetActiveIndex();
	return 0;
}

LRESULT CPropSheet::OnShowWindow(UINT /*uMsg*/, WPARAM wParam, LPARAM /*lParam*/, BOOL& bHandled)
{
	BOOL bShowing = (BOOL) wParam;
	if (bShowing && !m_bCentered) {
		m_bCentered = true;
		CenterWindow(m_psh.hwndParent);
	}
	PostMessage(DM_SETDEFID, IDOK);
	return 0;
}

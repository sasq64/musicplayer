#ifndef _PROPSHEET_H
#define _PROPSHEET_H

#if _MSC_VER >= 1000
#pragma once
#endif

//#include "PropPageMachine.h"
#include "PropPageAudio.h"

class CPropSheet : public CPropertySheetImpl<CPropSheet>
{
public:
    // Construction
    CPropSheet ( _U_STRINGorID title = (LPCTSTR) NULL, 
                    UINT uStartPage = 0, HWND hWndParent = NULL );

    // Maps
    BEGIN_MSG_MAP(CPropSheet)
		MESSAGE_HANDLER(WM_SHOWWINDOW, OnShowWindow)
		MESSAGE_HANDLER(WM_DESTROY, OnDestroy)
        CHAIN_MSG_MAP(CPropertySheetImpl<CPropSheet>)
    END_MSG_MAP()

    // Message handlers
	LRESULT OnDestroy(UINT /*uMsg*/, WPARAM /*wParam*/, LPARAM /*lParam*/, BOOL& bHandled);
    LRESULT OnShowWindow(UINT /*uMsg*/, WPARAM /*wParam*/, LPARAM /*lParam*/, BOOL& bHandled);

    // Property pages
//    CPropPageMachine propPageMachine;
	CPropPageAudio propPageAudio;

    // Implementation
	UINT lastPage;
protected:
    bool m_bCentered;
};

#endif // _PROPSHEET_H

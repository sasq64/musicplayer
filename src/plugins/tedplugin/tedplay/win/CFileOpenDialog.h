#pragma once

#include "stdafx.h"

class CFileOpenDialog 
	//: public CShellFileOpenDialogImpl<CFileOpenDialog>
{
public:

   // CFileOpenDialog() {
   //     COMDLG_FILTERSPEC fileTypes[] = 
   //     {
   //         { L"TED Music modules", L"*.ted" },
			//{ L"TED program files", L"*.prg" },
   //         { L"All Files", L"*.*" }
   //     };

   //     COM_VERIFY(GetPtr()->SetFileTypes(_countof(fileTypes),
   //                                       fileTypes));
   // }
   // HRESULT OnFileOk()
   // {
   //     CString filePath;
   //     COM_VERIFY(GetFilePath(filePath));

   //     // Validate file here...
   //     bool acceptable = ...

   //     return acceptable ? S_OK : S_FALSE;
   // }
};

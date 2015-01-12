#include "resource.h"
#include "stdafx.h"
#include "registry.h"
#include <prsht.h>

#include "PropPageAudio.h"

CPropPageAudio::CPropPageAudio(void)
{
	m_psp.dwFlags |= PSP_USEICONID;
	m_psp.pszIcon = MAKEINTRESOURCE(IDI_PROPPAGEAUDIO);
	m_psp.hInstance = _Module.GetResourceInstance();

	// grab current settings from registry
	vSamplingRate = 0;
	getRegistryValue(_T("SampleRate"), vSamplingRate);
	if (!vSamplingRate || vSamplingRate > 192000) vSamplingRate = 48000;

	vFilterOrder = 0;
	getRegistryValue(_T("FilterOrder"), vFilterOrder);
	if (!vFilterOrder || vFilterOrder > 128 || vFilterOrder < 4) vFilterOrder = 12;

	vLatency = 0;
	getRegistryValue(_T("BufferLengthInMsec"), vLatency);
	if (!vLatency || vLatency > 1000) vLatency = 400;

	vAutoSkipInterval = 0;
	getRegistryValue(_T("AutoSkipInterval"), vAutoSkipInterval);
	if (vAutoSkipInterval > 3600) vAutoSkipInterval = 0;
}

LPARAM CPropPageAudio::OnInitDialog(UINT /*uMsg*/, WPARAM /*wParam*/, LPARAM /*lParam*/, BOOL& bHandled)
{
	if (!ebLatency.m_hWnd) {
		ebLatency.Attach(GetDlgItem(IDC_EDIT_BUFLEN));
	}
	if (!sbLatency.m_hWnd)
		sbLatency.Attach(GetDlgItem(IDC_SPIN_BUFLEN));
	sbLatency.SetRange(40, 500);
	//
	if (!ebFilterOrder.m_hWnd) {
		ebFilterOrder.Attach(GetDlgItem(IDC_EDIT_FILTERORDER));
	}
	if (!sbFilterOrder.m_hWnd)
		sbFilterOrder.Attach(GetDlgItem(IDC_SPIN_FILTERORDER));
	//
	if (!ebAutoSkip.m_hWnd) {
		ebAutoSkip.Attach(GetDlgItem(IDC_EDIT_AUTOSKIPTIME));
	}
	if (!sbAutoSkip.m_hWnd)
		sbAutoSkip.Attach(GetDlgItem(IDC_SPIN_AUTOSKIPTIME));
	//
	if (!cbSamplingRate.m_hWnd)
		cbSamplingRate.Attach(GetDlgItem(IDC_COMBO_SAMPLEFREQ));
	//
	cbSamplingRate.AddString(_T("192000"));
	cbSamplingRate.AddString(_T("110840"));
	cbSamplingRate.AddString(_T("96000"));
	cbSamplingRate.AddString(_T("55420"));
	cbSamplingRate.AddString(_T("48000"));
	cbSamplingRate.AddString(_T("44100"));
	cbSamplingRate.AddString(_T("22050"));
	
	_TCHAR txt[64];
	_stprintf(txt, _T("%u"), vSamplingRate);
	cbSamplingRate.SetWindowText(txt);
	//
	_stprintf(txt, _T("%u"), vFilterOrder);
	ebFilterOrder.SetWindowText(txt);
	//
	_stprintf(txt, _T("%u"), vLatency);
	ebLatency.SetWindowText(txt);
	//	
	_stprintf(txt, _T("%u"), vAutoSkipInterval);
	ebAutoSkip.SetWindowText(txt);

	sbLatency.SetRange(40, 1000);
	sbFilterOrder.SetRange(4, 128);
	sbAutoSkip.SetRange(0, 3600);

	return 0;
}

LRESULT CPropPageAudio::OnDefaultClick(WORD wNotifyCode, WORD wID, HWND hwndCtl, BOOL& bHandled)
{
	_TCHAR txt[64];

	vSamplingRate = 48000;
	_stprintf(txt, _T("%u"), vSamplingRate);
	cbSamplingRate.SetWindowText(txt);

	vFilterOrder = 12;
	_stprintf(txt, _T("%u"), vFilterOrder);
	ebFilterOrder.SetWindowText(txt);

	vLatency = 400;
	_stprintf(txt, _T("%u"), vLatency);
	ebLatency.SetWindowText(txt);

	vAutoSkipInterval = 0;
	_stprintf(txt, _T("%u"), vAutoSkipInterval);
	ebAutoSkip.SetWindowText(txt);

	return 0;
}

int CPropPageAudio::OnApply()
{
	BOOL retval = DoDataExchange(true);
	return retval;// ? PSNRET_INVALID : PSNRET_NOERROR;
}

LRESULT CPropPageAudio::OnSpinButton(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled)
{
	bHandled = FALSE;
	return bHandled;
}

LRESULT CPropPageAudio::OnDestroy(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled)
{
	vLatency = GetDlgItemInt(IDC_EDIT_BUFLEN);
	vSamplingRate = GetDlgItemInt(IDC_COMBO_SAMPLEFREQ);
	vFilterOrder = GetDlgItemInt(IDC_EDIT_FILTERORDER);
	vAutoSkipInterval = GetDlgItemInt(IDC_EDIT_AUTOSKIPTIME);
	return 0L;
}

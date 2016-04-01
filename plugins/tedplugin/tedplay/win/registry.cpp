#include <windows.h>
#include <tchar.h>

#define REGKEYPATH _T("Software\\Gaia\\WinTedPlay")
#define KEY_STANDARD_ACCESS (KEY_QUERY_VALUE | KEY_SET_VALUE | KEY_CREATE_SUB_KEY)

bool getRegistryValue(_TCHAR *keyName, unsigned int &value)
{
	// Read settings
	HKEY appKey;
	DWORD keyLength = 4;
	LONG regVal = -1;
	LONG s = ::RegCreateKeyEx(HKEY_CURRENT_USER, REGKEYPATH, 0, 0, 
		REG_OPTION_NON_VOLATILE, KEY_STANDARD_ACCESS, 0, &appKey, 0);
	if (s == ERROR_SUCCESS) {
		s = ::RegQueryValueEx(appKey, keyName, 0, 
			NULL, (LPBYTE) &regVal, (LPDWORD) &keyLength);
		if (s == ERROR_SUCCESS && regVal != -1) {
			value = regVal;
		}
		::RegCloseKey(appKey);
		return true;
	}
	return false;
}

bool setRegistryValue(_TCHAR *keyName, unsigned int value)
{
	HKEY appKey;
	LONG s = ::RegCreateKeyEx(HKEY_CURRENT_USER, REGKEYPATH, 0, 0, 
		REG_OPTION_NON_VOLATILE, KEY_STANDARD_ACCESS, 0, &appKey, 0);
	if (s == ERROR_SUCCESS) {
		s = ::RegSetValueEx(appKey, keyName, 0, 
			REG_DWORD, (CONST BYTE *) &value, sizeof(value));
		::RegCloseKey(appKey);
		return true;
	}
	return false;
}

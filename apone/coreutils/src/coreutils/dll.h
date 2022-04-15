#include "log.h"

#ifdef _WIN32
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
using LibHandle = HMODULE;
#define SO_EXT ".dll"
#else
#include <dlfcn.h>
using LibHandle = void*;
#ifdef __APPLE__
#define SO_EXT ".dylib"
#else
#define SO_EXT ".so"
#endif
#endif

namespace utils {

struct Symbol
{
	Symbol(LibHandle handle, const char* name) : handle(handle), name(name) {}
	template <typename T> operator T()
	{
#ifdef _WIN32
		void* ptr = (void*)GetProcAddress(handle, name);
		if (!ptr) {
			DWORD e = GetLastError();
			//Log("HANDLE %x ERROR %x", handle, e);
		}
#else
		void* ptr = dlsym(handle, name);
#endif
		return (T)ptr;
	}
	LibHandle handle;
	const char* name;
};

struct DLL
{
	DLL() : handle(nullptr) {}
	DLL(DLL&& dll)
	{
		handle = dll.handle;
		dll.handle = nullptr;
	}

	void close()
	{
		if (handle)
#ifdef _WIN32
			FreeLibrary(handle);
#else
			dlclose(handle);
#endif
		handle = nullptr;
	}

	DLL& operator=(DLL&& dll)
	{
		close();
		handle = dll.handle;
		dll.handle = nullptr;
		return *this;
	}

	DLL(const std::string& name)
	{
#ifdef _WIN32
		DWORD e;
		handle = LoadLibraryA(name.c_str());
		if (!handle) {
			e = GetLastError();
			//Log("HANDLE %x ERROR %x", handle, e);
		}
#else
		handle = dlopen(name.c_str(), RTLD_LAZY | RTLD_LOCAL);
#endif
	}

	~DLL() { close(); }

	Symbol load(const char* name) { return Symbol(handle, name); }

	explicit operator bool() { return handle != nullptr; }

	LibHandle handle;
};

} // namespace utils


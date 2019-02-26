#ifndef APONE_THREAD_H
#define APONE_THREAD_H

#ifdef OLD_MINGW_OR_SOMETHING
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#undef ERROR
#include "mingw-std-threads/mingw.thread.h"
#include <mutex>
#include "mingw-std-threads/mingw.mutex.h"
#include "mingw-std-threads/mingw.condition_variable.h"
#else
#include <mutex>
#include <thread>
#include <condition_variable>
#endif

#endif // APONE_THREAD_H

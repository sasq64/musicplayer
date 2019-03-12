//	$Id: file.cpp,v 1.6 1999/12/28 11:14:05 cisc Exp $

#include <errno.h>
#include "headers.h"
#include "file.h"

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

#ifdef _WIN32
#include <fileapi.h>
#include <io.h>
#else
#include <unistd.h>
#endif

// ---------------------------------------------------------------------------
//	構築/消滅
// ---------------------------------------------------------------------------

FileIO::FileIO()
{
	flags = 0;
}

FileIO::FileIO(const char* filename, uint flg)
{
	flags = 0;
	Open(filename, flg);
}

FileIO::~FileIO()
{
	Close();
}

// ---------------------------------------------------------------------------
//	ファイルを開く
// ---------------------------------------------------------------------------

bool FileIO::Open(const char* filename, uint flg)
{
	Close();

	snprintf(path, sizeof path, "%s", filename);

	uint32 access = (flg & readonly ? 0 : O_WRONLY) | O_RDONLY;
	uint32 creation = flg & create ? (O_CREAT | O_TRUNC) : 0;

	hfile = ::open(filename, access | creation, 0644);
	
	flags = (flg & readonly) | (hfile == -1 ? 0 : open);
	if (!(flags & open))
	{
		switch (errno)
		{
		case ENOENT:		error = file_not_found; break;
		case EACCES:	error = sharing_violation; break;
		default: error = unknown; break;
		}
	}
	SetLogicalOrigin(0);

	return !!(flags & open);
}

// ---------------------------------------------------------------------------
//	ファイルがない場合は作成
// ---------------------------------------------------------------------------

bool FileIO::CreateNew(char* filename)
{
	Close();

	snprintf(path, sizeof path, "%s", filename);

	uint32 access = O_RDWR;
	uint32 creation = O_TRUNC | O_CREAT;

	hfile = ::open(filename, access | creation, 0644);
	
	flags = (hfile == -1 ? 0 : open);
	SetLogicalOrigin(0);

	return !!(flags & open);
}

// ---------------------------------------------------------------------------
//	ファイルを作り直す
// ---------------------------------------------------------------------------

bool FileIO::Reopen(uint flg)
{
	if (!(flags & open)) return false;
	if ((flags & readonly) && (flg & create)) return false;

	if (flags & readonly) flg |= readonly;

	Close();

	uint32 access = (flg & readonly ? 0 : O_WRONLY) | O_RDONLY;
	uint32 creation = flg & create ? (O_TRUNC | O_CREAT) : 0;

	hfile = ::open(path, access |creation, 0644);
	
	flags = (flg & readonly) | (hfile == -1 ? 0 : open);
	SetLogicalOrigin(0);

	return !!(flags & open);
}

// ---------------------------------------------------------------------------
//	ファイルを閉じる
// ---------------------------------------------------------------------------

void FileIO::Close()
{
	if (GetFlags() & open)
	{
		::close(hfile);
		flags = 0;
	}
}

// ---------------------------------------------------------------------------
//	ファイル殻の読み出し
// ---------------------------------------------------------------------------

int32 FileIO::Read(void* dest, int32 size)
{
	if (!(GetFlags() & open))
		return -1;
	
	int32 readsize;
	if ((readsize = ::read(hfile, dest, size)) < 0)
		return -1;
	return readsize;
}

// ---------------------------------------------------------------------------
//	ファイルへの書き出し
// ---------------------------------------------------------------------------

int32 FileIO::Write(const void* dest, int32 size)
{
	if (!(GetFlags() & open) || (GetFlags() & readonly))
		return -1;
	
	int32 writtensize;
	if ((writtensize = ::write(hfile, dest, size)) < 0)
		return -1;
	return writtensize;
}

// ---------------------------------------------------------------------------
//	ファイルをシーク
// ---------------------------------------------------------------------------

bool FileIO::Seek(int32 pos, SeekMethod method)
{
	if (!(GetFlags() & open))
		return false;
	
	uint32 wmethod;
	switch (method)
	{
	case begin:	
		wmethod = SEEK_SET; pos += lorigin;
		break;
	case current:	
		wmethod = SEEK_CUR;
		break;
	case end:		
		wmethod = SEEK_END;
		break;
	default:
		return false;
	}

	return 0xffffffff != ::lseek(hfile, pos, wmethod);
}

// ---------------------------------------------------------------------------
//	ファイルの位置を得る
// ---------------------------------------------------------------------------

int32 FileIO::Tellp()
{
	if (!(GetFlags() & open))
		return 0;

	return ::lseek(hfile, 0, SEEK_CUR) - lorigin;
}

// ---------------------------------------------------------------------------
//	現在の位置をファイルの終端とする
// ---------------------------------------------------------------------------

bool FileIO::SetEndOfFile()
{
	if (!(GetFlags() & open))
		return false;
#ifdef _WIN32
	// TODO: Truncate file
	//::SetEndOfFile(hfile);
#else
	return ::ftruncate(hfile, Tellp()) == 0;
#endif
}

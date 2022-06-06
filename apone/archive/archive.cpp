
#include "archive.h"

#define MINIZ_HEADER_FILE_ONLY
extern "C"
{
#include <miniz/miniz.c>
}

#include <coreutils/log.h>
#include <cstring>
#include <vector>
#ifdef _WIN32
#    include <windows.h>
#endif
#include "unrar/dll.hpp"

using namespace std;

namespace utils {

/*
class ExtArchive : public Archive {
    File extract(const string &name) {
        system("lha x " + name);
    }
};*/

class ZipFile : public Archive
{
public:
    ZipFile(const string& fileName, const string& workDir = ".")
        : workDir(workDir)
    {
        // zipFile = zip_open(fileName.c_str(), 0, NULL);
        memset(&zipArchive, 0, sizeof(zipArchive));
        if (!mz_zip_reader_init_file(&zipArchive, fileName.c_str(), 0))
            throw archive_exception("Could not open zip file");
    }

    ~ZipFile() { close(); }

    void close() { mz_zip_reader_end(&zipArchive); }

    fs::path extract(const string& name) override
    {

        fs::path file(workDir + "/" + name);
        mz_zip_reader_extract_file_to_file(&zipArchive, name.c_str(),
                                           workDir.c_str(), 0);
        return file;
    }
    void extractAll(const string&) override
    {
        throw std::exception();
    }

    string nameFromPosition(int pos) const override
    {
        mz_zip_archive_file_stat file_stat;
        if (mz_zip_reader_file_stat(const_cast<mz_zip_archive*>(&zipArchive),
                                     pos, &file_stat) == 0) {
        }
        return file_stat.m_filename;
    }

    int totalFiles() const override
    {
        return mz_zip_reader_get_num_files(
            const_cast<mz_zip_archive*>(&zipArchive));
    }

private:
    mz_zip_archive zipArchive;
    string workDir;
};

class RarFile : public Archive
{
public:
    RarFile(const string& fileName, const string& workDir = ".")
        : workDir(workDir)
    {
        // fprintf(stderr, "CONSTR");
        // fflush(stderr);
        RAROpenArchiveDataEx archiveInfo;
        memset(&archiveInfo, 0, sizeof(archiveInfo));
        archiveInfo.CmtBuf = NULL;
        archiveInfo.OpenMode = RAR_OM_EXTRACT;
        archiveInfo.ArcName = (char*)fileName.c_str();
        rarFile = RAROpenArchiveEx(&archiveInfo);
        if (archiveInfo.OpenResult != 0) {
            throw archive_exception("Bad RAR");
        };
        currentPos = 0;
        //RHCode = RARReadHeaderEx(rarFile, &fileInfo);
    }

    ~RarFile()
    {
        // fprintf(stderr, "DESTR");
        // fflush(stderr);
        RARCloseArchive(rarFile);
    }

    void extractAll(const string& targetDir) override
    {
        RARHeaderDataEx fileInfo;
        while (true) {
            RHCode = RARReadHeaderEx(rarFile, &fileInfo);
            if (RHCode == ERAR_END_ARCHIVE) {
                break;
            }
           // LOGI("Extracting %s", fileInfo.FileName);
            int PFCode = RARProcessFile(rarFile, RAR_EXTRACT,
                                        (char*)targetDir.c_str(), NULL);
        }
    }

    fs::path extract(const string& name) override
    {
        // RARHeaderDataEx fileInfo;
        // int RHCode = RARReadHeaderEx(rarFile, &fileInfo);

        // int RHCode = RARReadHeaderEx(rarFile, &fileInfo);
        // LOGD("RHCode %d %s", RHCode, fileInfo.FileName);
        // if(RHCode !=0)
        //	return File();

        int PFCode =
            RARProcessFile(rarFile, RAR_EXTRACT, (char*)workDir.c_str(), NULL);

        // LOGD("extract %d", PFCode);

        RHCode = RARReadHeaderEx(rarFile, &fileInfo);

        currentPos++;

        fs::path f{workDir + "/" + fileInfo.FileName};

        return f;
    }

    string nameFromPosition(int pos) const override
    {

        // LOGD("POS %d vs %d", pos , currentPos);
        while (currentPos < pos) {
            int PFCode = RARProcessFile(rarFile, RAR_SKIP, NULL, NULL);
            // LOGD("PFCode %d", PFCode);

            RHCode = RARReadHeaderEx(rarFile, &fileInfo);

            currentPos++;
        }

        if (RHCode != 0)
            return "";

        // int RHCode = RARReadHeaderEx(rarFile, &fileInfo);
        // LOGD("pos %d %s", currentPos, fileInfo.FileName);
        // if(RHCode !=0)
        //	return "";
        return fileInfo.FileName;
    }

    int totalFiles() const override { return -1; }

private:
    HANDLE rarFile;
    mutable int currentPos;
    // struct zip *zipFile;
    mutable RARHeaderDataEx fileInfo;
    mutable int RHCode;
    string workDir;
};

Archive* Archive::open(const std::string& fileName,
                       const std::string& targetDir, int type)
{
    if (type == TYPE_ZIP || utils::endsWith(fileName, ".zip"))
        return new ZipFile(fileName, targetDir);
    else if (type == TYPE_RAR || utils::endsWith(fileName, ".rar"))
        return new RarFile(fileName, targetDir);
    return nullptr;
}

bool Archive::canHandle(const std::string& name)
{
    return utils::endsWith(name, ".zip");
}

} // namespace utils

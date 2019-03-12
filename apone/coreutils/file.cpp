#include "file.h"
#include "split.h"

#include <sys/stat.h>

//#include "log.h"
#define LOGD(x, ...)
#ifdef _WIN32
#    include <windows.h>
#    include <direct.h>
#    include <experimental/filesystem>
	namespace fs = std::experimental::filesystem;
#endif
#include <iomanip>
#include <sstream>
#include <stdlib.h>
//#include <unistd.h>
#ifdef APPLE
#    include <mach-o/dyld.h>
#endif

#include <mutex>

#ifndef PATH_MAX
#    define PATH_MAX 4096
#endif

namespace utils {

using namespace std;

const char File::PathSeparator = ':';

const File File::NO_FILE;

File File::appDir("/usr/share/" APP_NAME_STR);
File File::userDir;
File File::cacheDir;
File File::configDir;
File File::exeDir;
File File::homeDir;
File File::tempDir;

static mutex fm;

File::File() : size(-1), writeFP(nullptr), readFP(nullptr) {}

static std::string fstrip(const std::string& t)
{
    if (t.length() == 0)
        return t;
    int i = t.length() - 1;
    while (t[i] == '/')
        i--;
    if (i != t.length() - 1)
        return t.substr(0, i + 1);
    else
        return t;
}

File::File(const string& name, const Mode mode)
    : fileName(fstrip(name)), size(-1), writeFP(nullptr), readFP(nullptr)
{
    if (mode != NONE)
        open(mode);
}

File::File(const string& parent, const string& name, const Mode mode)
    : size(-1), writeFP(nullptr), readFP(nullptr)
{
    if (parent == "")
        fileName = fstrip(name);
    else
        fileName = fstrip(parent) + "/" + fstrip(name);
    if (mode != NONE)
        open(mode);
}

#ifdef _WIN32

static void _listFiles(const std::string& dirName,
                const std::function<void(const std::string& path)>& f)
{
    for (const auto& p : fs::directory_iterator(dirName)) {
        auto&& path = p.path().string();
        if (path[0] == '.' &&
            (path[1] == 0 || (path[1] == '.' && path[2] == 0)))
            continue;
        if (fs::is_directory(p.status()))
            _listFiles(path, f);
        else
            f(path);
    }
}

vector<File> File::listFiles() const
{
	vector<File> result;
    _listFiles(fileName, [&](const std::string& name) {
		result.emplace_back(name);
	});
	return result;
}

#else

#include <dirent.h>

vector<File> File::listFiles() const
{
    vector<File> rc;
    DIR* dir;
    struct dirent* ent;
    if ((dir = opendir(fileName.c_str())) != nullptr) {
        while ((ent = readdir(dir)) != nullptr) {
            char* p = ent->d_name;
            if (p[0] == '.' && (p[1] == 0 || (p[1] == '.' && p[2] == 0)))
                continue;
            rc.emplace_back(fileName + "/" + ent->d_name);
        }
        closedir(dir);
    }
    return rc;
}

void File::listRecursive(const File& root, vector<File>& result,
                         bool includeDirs)
{
    DIR* dir;
    struct dirent* ent;
    if ((dir = opendir(root.getName().c_str())) != nullptr) {
        while ((ent = readdir(dir)) != nullptr) {
            char* p = ent->d_name;
            if (p[0] == '.' && (p[1] == 0 || (p[1] == '.' && p[2] == 0)))
                continue;
            File f{root / ent->d_name};
#ifdef _WIN32
            if (f.isDir()) {
#else
            if (ent->d_type == DT_DIR) {
#endif
                if (includeDirs)
                    result.push_back(f);
                listRecursive(f, result, includeDirs);
            } else
                result.push_back(f);
        }
        closedir(dir);
    }
} // namespace utils

vector<File> File::listRecursive(bool includeDirs) const
{
    vector<File> rc;
    listRecursive(*this, rc, includeDirs);
    return rc;
}
#endif

vector<uint8_t> File::readAll()
{
    vector<uint8_t> data;
    seek(0);
    data.resize((size_t)getSize());
    if (!data.empty()) {
        int rc = read(&data[0], data.size());
        if (rc != data.size())
            throw io_exception{};
    }
    return data;
}

void File::open(const Mode mode)
{
    if (mode == READ) {
        if (!readFP) {
#ifdef _WIN32
			if (fopen_s(&readFP, fileName.c_str(), "rb") !=0)
#else
			readFP = fopen(fileName.c_str(), "rb");
			if (!readFP)
#endif
				throw file_not_found_exception(fileName);
        }
    } else if (mode == WRITE) {
        if (!writeFP) {
            // makedirs(fileName);
#ifdef _WIN32
			if (fopen_s(&writeFP, fileName.c_str(), "wb") !=0)
#else
			writeFP = fopen(fileName.c_str(), "wb");
			if (!writeFP)
#endif
                throw io_exception{"Could not open file'"s + fileName +
                                   "' for writing"s};
        }
    } else
        throw io_exception{"Can't open file with no mode"};
}

bool File::isChildOf(const File& f) const
{
    string myPath = resolvePath(getName());
    string parentPath = resolvePath(f.getName());
    return (myPath.find(parentPath) == 0);
}

void File::seek(int64_t where)
{
    open(READ);
    if (!readFP)
        throw file_not_found_exception(fileName);
#ifdef _WIN32
    _fseeki64(readFP, where, SEEK_SET);
#else
    fseek(readFP, where, SEEK_SET);
#endif
}
int64_t File::tell()
{
    open(READ);
    if (!readFP)
        throw file_not_found_exception(fileName);
    return ftell(readFP);
}

vector<string> File::getLines()
{
    vector<string> lines;
    auto data = readAll();
    if (data.size() == 0)
        return lines;
    string source{reinterpret_cast<char*>(&data[0]), (unsigned int)data.size()};
    stringstream ss(source);
    string to;

    while (getline(ss, to)) {
        auto l = to.length();
        while (l > 0 && (to[l - 1] == 10 || to[l - 1] == 13))
            l--;
        lines.push_back(to.substr(0, l));
    }
    return lines;
}

void File::write(const uint8_t* data, const int size)
{
    open(WRITE);
    fwrite(data, 1, size, writeFP);
}

void File::write(const string& data)
{
    open(WRITE);
    fwrite(data.c_str(), 1, data.length(), writeFP);
}

void File::copyFrom(File& otherFile)
{
    open(WRITE);
    const auto data = otherFile.readAll();
    fwrite(&data[0], 1, data.size(), writeFP);
    close();
}

void File::copyFrom(const string& other)
{
    File f{other};
    copyFrom(f);
    f.close();
    close();
}

void File::close()
{
    if (writeFP)
        fclose(writeFP);
    else if (readFP)
        fclose(readFP);
    writeFP = readFP = nullptr;
}

bool File::exists() const
{
    struct stat ss;
    return (stat(fileName.c_str(), &ss) == 0);
}

bool File::exists(const string& fileName)
{
    struct stat ss;
    return (stat(fileName.c_str(), &ss) == 0);
}

string File::makePath(vector<File> files, bool resolve)
{
    string path = "";
    string sep = "";
    for (const File& f : files) {
        if (resolve)
            path = path + sep + f.resolve().getName();
        else
            path = path + sep + f.getName();
        sep = string(1, PathSeparator);
    }
    return path;
}

File File::findFile(const string& path, const string& name)
{
    LOGD("Find '%s'", name);
    if (name == "")
        return NO_FILE;
    auto parts = split(path, PathSeparator);
    for (string p : parts) {
        if (p.length() > 0) {
            if (p[p.length() - 1] != '/')
                p += "/";
            LOGD("...in path %s", p);
            File f{p + name};
            if (f.exists())
                return f;
        }
    }
    return NO_FILE;
}

const File& File::getHomeDir()
{
    if (!homeDir) {
#ifdef _WIN32
        char *path;
		size_t len;
		_dupenv_s(&path, &len, "HOMEPATH");
        string h = path;
		free(path);
        if (h[0] == '\\') {
            h = string("C:") + h;
            replace_char(h, '\\', '/');
        }
        homeDir = File(h);
#else
        homeDir = File(getenv("HOME"));
#endif
    }
    return homeDir;
}

static std::string getHome()
{
    return File::getHomeDir().getName();
}

/* #ifdef APP_NAME */
/* static const char* appName = APP_NAME_STR; */
/* #else */
/* static const char* appName = "apone"; */
/* #endif */

const File& File::getCacheDir()
{
    lock_guard<mutex> lock(fm);
    if (!cacheDir) {
        string home = getHome();
#ifdef _WIN32
        replace_char(home, '\\', '/');
#endif
        auto d = home + "/.cache/" APP_NAME_STR;
        LOGD("CACHE: %s", d);
        if (!exists(d))
            utils::makedirs(d);
        cacheDir = File(d);
    }
    return cacheDir;
}

const File& File::getConfigDir()
{
    lock_guard<mutex> lock(fm);
    if (!configDir) {
        std::string home = getHome();
#ifdef _WIN32
        replace_char(home, '\\', '/');
#endif
        auto d = home + "/.config/" APP_NAME_STR;
        LOGD("CACHE: %s", d);
        if (!exists(d))
            utils::makedirs(d);
        configDir = File(d);
    }
    return configDir;
}

uint64_t File::getModified() const
{
    struct stat ss;
    if (stat(fileName.c_str(), &ss) != 0)
        throw io_exception{"Could not stat file"};
    return (uint64_t)ss.st_mtime;
}

uint64_t File::getModified(const std::string& fileName)
{
    struct stat ss;
    if (stat(fileName.c_str(), &ss) != 0)
        throw io_exception{"Could not stat file"};
    return (uint64_t)ss.st_mtime;
}

int64_t File::getSize() const
{
    if (size < 0) {
        struct stat ss;
        int rc = -1;
        LOGD("FN: '%s' %p", fileName, writeFP);
        if (fileName != "") {
            rc = stat(fileName.c_str(), &ss);
        } else if (writeFP != nullptr) {
#ifdef _WIN32
            rc = fstat(_fileno(writeFP), &ss);
#else
            rc = fstat(fileno(writeFP), &ss);
#endif
            LOGD("RC %d", rc);
        }
        if (rc != 0)
            throw io_exception{"Could not stat file"};
        size = (uint64_t)ss.st_size;
    }
    return size;
}

#ifndef _WIN32
bool File::isDir() const
{
    struct stat ss;
    if (stat(fileName.c_str(), &ss) != 0)
        throw io_exception{"Could not stat file"};
    return S_ISDIR(ss.st_mode);
}
#endif

void File::remove()
{
    close();
    if (std::remove(fileName.c_str()) != 0)
        throw io_exception{"Could not delete file"};
}

void File::rename(const std::string& newName)
{
    if (std::rename(fileName.c_str(), newName.c_str()) != 0)
        throw io_exception{"Could not rename file"};
    fileName = newName;
}

void File::remove(const std::string& fileName)
{
    if (std::remove(fileName.c_str()) != 0)
        throw io_exception{"Could not delete file"};
}

std::string File::read()
{
    open(READ);
    auto data = readAll();
    return std::string(reinterpret_cast<const char*>(&data[0]),
                       (unsigned long)data.size());
}

void File::copy(const std::string& from, const std::string& to)
{
    File f0{from};
    File f1{to};
    f1.copyFrom(f0);
}

std::string File::resolvePath(const std::string& fileName)
{
    char temp[PATH_MAX];
#ifdef _WIN32
    // if(GetFullPathNameA(fileName.c_str(), PATH_MAX, temp, NULL) > 0)
    if (_fullpath(temp, fileName.c_str(), PATH_MAX)) {
        replace_char(temp, '\\', '/');
        return std::string(temp);
    }
#else
    if (::realpath(fileName.c_str(), temp))
        return std::string(temp);
#endif
    return fileName;
}

File File::resolve() const
{
    char temp[PATH_MAX];
#ifdef _WIN32
    if (_fullpath(temp, fileName.c_str(), PATH_MAX)) {
        replace_char(temp, '\\', '/');
        return File(temp);
    }
#else
    if (::realpath(fileName.c_str(), temp)) {
        return File(temp);
    }
#endif
    else
        return File("");
}

File File::cwd()
{
    char temp[PATH_MAX];
#ifdef _WIN32
    if (_getcwd(temp, sizeof(temp))) {
        replace_char(temp, '\\', '/');
#else
    if (getcwd(temp, sizeof(temp))) {
#endif
        return File(temp);
    }
    throw io_exception{"Could not get current directory"};
}

File::~File()
{
    if (readFP)
        fclose(readFP);
    if (writeFP)
        fclose(writeFP);
}

const File& File::getExeDir()
{
    lock_guard<mutex> lock(fm);

    if (!exeDir) {
        static char buf[1024];
#if defined _WIN32
        GetModuleFileName(nullptr, buf, sizeof(buf) - 1);
        replace_char(buf, '\\', '/');
        char* ptr = &buf[strlen(buf) - 1];
        while (ptr > buf && *ptr != '/')
            *ptr-- = 0;
        *ptr = 0;
        exeDir = File(buf);
#elif defined APPLE
        uint32_t size = sizeof(buf);
        if (_NSGetExecutablePath(buf, &size) == 0) {
            exeDir = File(path_directory(buf));
        }
#elif defined UNIX
        int rc = readlink("/proc/self/exe", buf, sizeof(buf) - 1);
        if (rc >= 0) {
            buf[rc] = 0;
            exeDir = File(path_directory(buf));
        }
#endif
    }
    LOGD("EXEDIR:%s", exeDir.getName());
    exeDir.resolve();
    return exeDir;
}

void File::setAppDir(const std::string& a)
{
    lock_guard<mutex> lock(fm);
    LOGD("Setting appdir to %s", a);
    appDir = File(a);
}

File File::getTempDir()
{
    char buffer[maxPath];
#ifdef _WIN32
    if (GetTempPathA(sizeof(buffer), buffer) == 0)
        throw io_exception{"Could not get temporary directory"};
#else
    const char* tmpdir = getenv("TMPDIR");
    if (!tmpdir)
        tmpdir = P_tmpdir;
    if (!tmpdir)
        tmpdir = "/tmp/";
    strcpy(buffer, tmpdir);
#endif
    return File{buffer};
}

const File& File::getAppDir()
{
    lock_guard<mutex> lock(fm);
    if (!appDir) {
        if (APP_NAME_STR != "")
#ifdef __APPLE
            appDir = (getExeDir() / ".." / "Resources").resolve();
#elif (defined _WIN32)
            appDir = getExeDir();
#else
            appDir = File("/usr/share/" APP_NAME_STR);
#endif
        else
            throw io_exception("No appDir specified");
    }
    return appDir;
}

void File::writeln(const std::string& line)
{
    write(line + "\n");
}

File File::changeSuffix(const std::string& ext)
{
    auto dot = fileName.find_last_of('.');
    if (dot != string::npos)
        return File(fileName.substr(0, dot) + ext);
    return File(fileName + ext);
}

std::string File::suffix() const
{

    auto dot = fileName.find_last_of('.');
    if (dot != string::npos)
        return fileName.substr(dot);
    return "";
}

} // namespace utils

#ifdef UNIT_TEST

#    include "catch.hpp"

TEST_CASE("utils::File", "File operations")
{

    using namespace utils;
    using namespace std;

    // Delete to be safe
    std::remove("temp.text");

    // File
    File file{"temp.text"};

    REQUIRE(file.getName() == "temp.text");

    file.write("First line\nSecond line");
    file.close();
    REQUIRE(file.exists());
    REQUIRE(file.getSize() > 5);
    REQUIRE(file.getSize() < 50);

    file = File{"temp.text"};

    auto data = file.readAll();
    REQUIRE(data.size() > 0);

    vector<string> lines = file.getLines();

    REQUIRE(lines.size() == 2);

    file.remove();

    REQUIRE(!file.exists());
}

#endif

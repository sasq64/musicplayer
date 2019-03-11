#pragma once

#include "utils.h"
#include <cstdint>
#include <cstdio>
#include <string>
#include <vector>

#include "newfile.h"

#ifdef USE_EXFS
#    include <experimental/filesystem>
namespace fs = std::experimental::filesystem;
#endif

namespace utils {

class io_exception : public std::exception
{
public:
    io_exception(const std::string& m = "IO Exception") : msg(m) {}
    virtual const char* what() const throw() { return msg.c_str(); }

private:
    std::string msg;
};

class file_not_found_exception : public std::exception
{
public:
    file_not_found_exception(const std::string& fileName = "")
        : msg(std::string("File not found: ") + fileName)
    {}
    virtual const char* what() const throw() { return msg.c_str(); }

private:
    std::string msg;
};

//#define THROW(e, args...) throw e(args, __FILE__, __LINE__)

#define XSF(x) SF(x)
#define SF(x) #x
#define APP_NAME_STR XSF(APP_NAME)

class File
{
public:
    enum Mode
    {
        NONE = 0,
        READ = 1,
        WRITE = 2
    };

#ifdef _WIN32

    static const char SLASH = '\\';
    static constexpr const char* SLASH_STR = "\\";
    static const char DIR_SEPARATOR = '\\';
    static const char PathSeparator;
    static constexpr const char* PathSeparator_STR = ";";
    static constexpr int maxPath = 8192;
    static int Fileno(FILE* fp) { return _fileno(fp); }
    static FILE* Fopen(const char* name, const char* mode)
    {
        FILE* fp = nullptr;
        auto e = fopen_s(&fp, name, mode);
        if (e != 0)
            fp = nullptr;
        return fp;
    }
#else
#    ifdef __APPLE__
#    else
#        include <linux/limits.h>
#    endif
    static const char SLASH = '/';
    static const char DIR_SEPARATOR = '/';
    static constexpr const char* SLASH_STR = "/";
    static const char PathSeparator;
    static constexpr const char* PathSeparator_STR = ":";
    static constexpr int maxPath = PATH_MAX;
    static int Fileno(FILE* fp) { return fileno(fp); }
    static FILE* Fopen(const char* name, const char* mode)
    {
        return fopen(name, mode);
    }
#endif

    static bool exists(const std::string& fileName);
    static void copy(const std::string& from, const std::string& to);
    static std::string resolvePath(const std::string& fileName);
    static File cwd();
    static void remove(const std::string& fileName);
    static void listRecursive(const File& root, std::vector<File>& result,
                              bool includeDirs);

    /** User specific writable cache dir, normall $HOME/.config/$APPNAME */
    static const File& getCacheDir();
    /** User specific config dir, normally $HOME/.config/$APPNAME */
    static const File& getConfigDir();
    /** The application data directory. Normally $EXEDIR/../Resources on OSX or
     * /usr/share/$APPNAME on *nix */
    static const File& getAppDir();
    /** $HOME dir */
    static const File& getHomeDir();
    /** Directory of the running executable */
    static const File& getExeDir();

    static File getTempDir();

    static File getTempFile()
    {
        File f = getTempDir() / "XXXXXXXXXX";
        // mkstemp(&f.fileName[0]);
        return f;
    }

    static void setAppDir(const std::string& a);
    static File findFile(const std::string& path, const std::string& name);
    static uint64_t getModified(const std::string& fileName);

    static std::string makePath(std::vector<File> files, bool resolve = false);

    inline static bool isAbsolutePath(std::string& fname)
    {
        return fname[0] == PathSeparator;
    }

    /*
        template <typename F0> static std::string makePath(const F0& f0) {
            return f0.getName();
        }
        template <typename F0, typename ... F> static std::string makePath(const
       F0& f0, const F& ... f) { return f0.getName() + ":" + makePath(f...);
        }

        template <typename F0, typename ... Fn> combinePath(F0 f, T...t) {

        }



        template <typename F0, typename ... Fn> File(F0 f, T...t) {
            compinePath(t...);
        }
    */

    File();
    explicit File(const std::string& name, const Mode mode = NONE);
    File(const std::string& parent, const std::string& name,
         const Mode mode = NONE);
    ~File();
#ifdef USE_EXFS
    explicit File(fs::path const& path) : File(path.string()) {}
#endif

    explicit File(const char* name, const Mode mode = NONE)
        : File(std::string(name), mode)
    {}

    File operator+(const std::string& suffix) const
    {
        return File(fileName + suffix);
    }

    bool operator==(const File& f) { return f.fileName == fileName; }

    bool operator!=(const File& f) { return f.fileName != fileName; }

    explicit operator bool() const { return fileName != ""; }

    operator std::string() const { return getName(); }
#ifdef USE_EXFS
    operator fs::path() const { return fs::path(fileName); }
#endif

    template <typename F> File operator/(const F& f) const
    {
        return File(*this, f);
    }

    void write(const uint8_t* data, int size);

    template <typename T> void write(const std::vector<T>& t)
    {
        write(&t[0], t.size());
    }

    void write(const std::string& text);

    template <typename T> void write(const T& t)
    {
        open(WRITE);
        if (fwrite(&t, sizeof(T), 1, writeFP) > 0)
            return;
        throw io_exception{"Write failed"};
    }

    void writeln(const std::string& line);

    void open(Mode mode);
    void close();

    // read elements
    template <typename T> int read(T* const target, const int count)
    {
        open(READ);
        int rc = fread(target, sizeof(T), (size_t)count, readFP);
        if (rc <= 0 && ferror(readFP))
            throw io_exception{std::string("Read failed on ") + fileName};
        return rc;
    }

    // Read (little endian) data type directly
    template <typename T> T read()
    {
        open(READ);
        T temp;
        if (fread(&temp, sizeof(T), 1, readFP) > 0)
            return temp;
        throw io_exception{std::string("Read failed on ") + fileName};
    }

    std::string readString(int maxlen = -1)
    {
        open(READ);
        std::vector<char> data;
        int c = 0;
        while ((int)data.size() != maxlen) {
            c = fgetc(readFP);
            if (c == 0 || c == EOF)
                break;
            data.push_back(c);
        }

        return std::string(data.begin(), data.end());
    }

    std::string read();

    std::vector<uint8_t> readAll();

    std::vector<std::string> getLines();

    std::vector<File> listFiles() const;
    std::vector<File> listRecursive(bool includeDirs = false) const;

    bool exists() const;

    const std::string& getName() const { return fileName; }

    const std::string getDirectory() const
    {
        return path_directory(resolvePath(fileName));
    }

    const std::string getFileName() const { return path_filename(fileName); }

    File changeSuffix(const std::string& ext);

    int64_t getSize() const;
    uint64_t getModified() const;

    bool isDir() const;
    File resolve() const;
    void remove();

    bool tryRemove()
    {
        close();
        return (std::remove(fileName.c_str()) == 0);
    }

    void rename(const std::string& newName);

    void copyFrom(File& otherFile);
    void copyFrom(const std::string& other);

    bool isChildOf(const File& f) const;

    int64_t tell();

    void seek(int64_t where);

    bool eof()
    {
        open(READ);
        return feof(readFP) != 0;
    }

    std::string suffix() const;

    static const File NO_FILE;

private:
    static File appDir;
    static File userDir;
    static File cacheDir;
    static File configDir;
    static File exeDir;
    static File homeDir;
    static File tempDir;

    std::string fileName;
    mutable int64_t size;

    FILE* writeFP;
    FILE* readFP;
};

} // namespace utils


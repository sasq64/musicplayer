#ifndef ARCHIVE_H
#define ARCHIVE_H

#include <filesystem>
namespace fs = std::filesystem;

#include <coreutils/utils.h>
//#include <coreutils/file.h>

namespace utils {

class archive_exception : public std::exception {
public:
    archive_exception(const char *ptr = "Archive Exception") : msg(ptr) {
    }
    const char *what() const noexcept override { return msg; }
 private:
    const char *msg;
};

class Archive {
public:

    enum {
        TYPE_ANY,
        TYPE_ZIP,
        TYPE_RAR
    };

    virtual ~Archive() = default;
    //virtual extractAll() = 0;
    virtual fs::path extract(const std::string &name) = 0;
    virtual std::string nameFromPosition(int pos) const = 0;
    virtual int totalFiles() const = 0;

    virtual void extractAll(const std::string &targetDir) = 0;

    static Archive *open(const std::string &fileName, const std::string &targetDir = ".", int type = TYPE_ANY);
    static bool canHandle(const std::string &name);

};

} // namespace

#endif // ARCHIVE_H

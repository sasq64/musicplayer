#include "utils.h"
#include "log.h"

#include <sys/stat.h>
#include <atomic>
#include <chrono>
#include <cstdlib>
#include <cstring>
#include <mutex>
#include <thread>
#include <unordered_map>

#ifdef USE_EXFS
#include <experimental/filesystem>
namespace fs = std::experimental::filesystem;
#endif

#ifdef _WIN32
#include <windows.h>
#include <ShellApi.h>
#include <direct.h>
#else
#include <fcntl.h>
#include <signal.h>
#include <sys/time.h>
#include <sys/wait.h>
#include <unistd.h>
#endif

#ifdef EMSCRIPTEN
#include <emscripten.h>
#endif

#include "jis.h"

namespace utils {

// using namespace std;

std::string rstrip(const std::string& x, char c) {
    auto l = x.length();
    if (c == 10) {
        while (l > 1 && (x[l - 1] == 10 || x[l - 1] == 13)) l--;
    } else {
        while (l > 1 && x[l - 1] == c) l--;
    }
    if (l == x.length()) return x;
    return x.substr(0, l);
}

std::string lstrip(const std::string& x, char c) {
    size_t l = 0;
    while (x[l] && x[l] == c) l++;
    if (l == 0) return x;
    return x.substr(l);
}

std::string lrstrip(const std::string& x, char c) {
    size_t l = 0;
    while (x[l] && x[l] == c) l++;
    size_t r = l;
    while (x[r] && x[r] != c) r++;
    return x.substr(l, r - l);
}

std::vector<std::string> text_wrap(const std::string& t, int width,
                                   int initialWidth) {
    std::vector<std::string> lines;
    size_t start = 0;
    size_t end = width;
    int subseqWidth = width;
    if (initialWidth >= 0) width = initialWidth;

    std::string text = t;
    for (auto& c : text) {
        if (c == 0xa) c = ' ';
    }

    // Find space from right
    while (true) {
        if (end > text.length()) {
            lines.push_back(text.substr(start));
            break;
        }
        auto pos = text.rfind(' ', end);
        if (pos != std::string::npos && pos > start) {
            lines.push_back(text.substr(start, pos - start));
            start = pos + 1;
        } else {
            lines.push_back(text.substr(start, width));
            start += width;
        }
        width = subseqWidth;
        end = start + width;
    }
    return lines;
}
std::wstring jis2unicode(uint8_t* text) {
    static uint16_t jis_table[65536];
    static bool init = false;
    if (!init) {
        memset(jis_table, 0, 65536 * 2);
        for (int i = 0; i < 0xff; i++) jis_table[i] = i;
        for (int i = 0; i < sizeof(jis_map) / 4; i += 2) {
            jis_table[jis_map[i]] = jis_map[i + 1];
        }
        jis_table[0x5c] = 0xa5;
        jis_table[0x7e] = 0x203e;
        init = true;
    }
    uint8_t* p = text;
    std::wstring result;
    while (*p) {
        uint16_t c = *p++;
        if ((c >= 0x81 && c <= 0x9f) || (c >= 0xe0)) {
            c <<= 8;
            c |= *p++;
        }
        result.push_back(jis_table[c]);
    }
    return result;
}

static uint16_t decode(const std::string& symbol) {
    static std::unordered_map<std::string, uint16_t> codes = {
        {"amp", '&'}, {"gt", '>'}, {"lt", '<'}};

    uint16_t code = strtol(symbol.c_str(), nullptr, 10);
    if (code > 0) return code;

    if (codes.count(symbol)) return codes[symbol];
    return '?';
}

std::string htmldecode(const std::string& s, bool stripTags) {
    char target[8192];
    auto* ptr = (unsigned char*)target;
    char symbol[32];
    char* sptr;
    bool inTag = false;

    for (unsigned i = 0; i < s.length(); i++) {
        uint16_t c = s[i];
        if (inTag) {
            if (c == '>') {
                inTag = false;
            }
            continue;
        }
        if (stripTags && c == '<') {
            inTag = true;
            continue;
        }

        if (c == '&') {
            sptr = symbol;
            int saved = i;
            i++;
            if (s[i] == '#') i++;
            while (isalnum(s[i])) *sptr++ = s[i++];
            *sptr = 0;
            if (s[i] == ';') {
                c = decode(symbol);
            } else
                i = saved;

            if (c <= 0x7f)
                *ptr++ = c;
            else if (c < 0x800) {
                *ptr++ = (0xC0 | (c >> 6));
                *ptr++ = (0x80 | (c & 0x3F));
            } else /*if (c < 0x10000) */ {
                *ptr++ = (0xE0 | (c >> 12));
                *ptr++ = (0x80 | ((c >> 6) & 0x3f));
                *ptr++ = (0x80 | (c & 0x3F));
            }
            continue;
        }
        *ptr++ = c;
    }
    *ptr = 0;
    return std::string(target);
}

std::string urlencode(const std::string& s, const std::string& chars) {
    char target[8192];
    char* ptr = target;
    for (unsigned i = 0; i < s.length(); i++) {
        auto c = s[i];
        if (chars.find(c) != std::string::npos) {
            sprintf(ptr, "%%%02x", c);
            ptr += 3;
        } else
            *ptr++ = c;
    }
    *ptr = 0;
    return std::string(target);
}

std::string urldecode(const std::string& s, const std::string& chars) {
    char target[8192];
    char* ptr = target;
    for (unsigned i = 0; i < s.length(); i++) {
        auto c = s[i];
        if (c == '%') {
            *ptr++ = strtol(s.substr(i + 1, 2).c_str(), nullptr, 16);
            i += 2;
        } else
            *ptr++ = c;
    }
    *ptr = 0;
    return std::string(target);
}

void sleepms(unsigned ms) {
    std::this_thread::sleep_for(std::chrono::milliseconds(ms));
}

void sleepus(unsigned us) {
    std::this_thread::sleep_for(std::chrono::microseconds(us));
}

#ifndef _WIN32
uint64_t getms() {
#ifdef EMSCRIPTEN
    return (uint64_t)emscripten_get_now();
#else
    timeval tv;
    gettimeofday(&tv, nullptr);
    return (tv.tv_sec * 1000000 + tv.tv_usec) / 1000;
#endif
}

uint64_t getus() {
    timeval tv;
    gettimeofday(&tv, nullptr);
    return (uint64_t)tv.tv_sec * 1000000 + (uint64_t)tv.tv_usec;
}
#endif

bool isalpha(const std::string& s) {
    for (const auto& c : s) {
        if (!::isalpha(c)) return false;
    }
    return true;
}

//float clamp(float x, float a0, float a1) {
//    return std::min(std::max(x, a0), a1);
//}

void makedir(const std::string& name) {
#ifdef _WIN32
    _mkdir(name.c_str());
#else
    mkdir(name.c_str(), 07777);
#endif
}

void makedirs(const std::string& path) {
    int start = 0;
    while (true) {
        auto pos = path.find_first_of("/\\", start);
        if (pos != std::string::npos) {
            makedir(path.substr(0, pos));
            start = pos + 1;
        } else {
            makedir(path);
            break;
        }
    }
}

bool endsWith(const std::string& name, const std::string& ext) {
    auto pos = name.rfind(ext);
    return (pos != std::string::npos && pos == name.length() - ext.length());
}

bool startsWith(const std::string& name, const std::string& pref) {
    auto pos = name.find(pref);
    return (pos == 0);
}

void makeLower(std::string& s) {
    for (auto& c : s) c = tolower(c);
}

std::string toLower(const std::string& s) {
    std::string s2 = s;
    makeLower(s2);
    return s2;
}

std::string path_basename(const std::string& name) {
    auto slashPos = name.rfind(path_separator);
    if (slashPos == std::string::npos)
        slashPos = 0;
    else
        slashPos++;
    auto dotPos = name.rfind('.');
    // LOGD("%s : %d %d", name, slashPos, dotPos);
    if (dotPos == std::string::npos || dotPos < slashPos)
        return name.substr(slashPos);
    return name.substr(slashPos, dotPos - slashPos);
}

std::string path_directory(const std::string& name) {
    // return fs::path(name).parent_path().string();
    auto slashPos = name.rfind(path_separator);
    if (slashPos == std::string::npos) slashPos = 0;
    return name.substr(0, slashPos);
}

std::string path_filename(const std::string& name) {
    // return fs::path(name).filename().string();
    auto slashPos = name.find_last_of("/\\");
    if (slashPos == std::string::npos)
        slashPos = 0;
    else
        slashPos++;
    return name.substr(slashPos);
}

std::string path_extension(const std::string& name) {
    auto dotPos = name.rfind('.');
    auto slashPos = name.rfind(path_separator);
    if (slashPos == std::string::npos)
        slashPos = 0;
    else
        slashPos++;
    if (dotPos == std::string::npos || dotPos < slashPos) return "";
    return name.substr(dotPos + 1);
}

std::string path_suffix(const std::string& name) {
    return path_extension(name);
}

std::string path_prefix(const std::string& name) {
    auto slashPos = name.rfind(path_separator);
    auto dotPos = name.find('.', slashPos);
    if (slashPos == std::string::npos)
        slashPos = 0;
    else
        slashPos++;
    if (dotPos == std::string::npos || dotPos < slashPos) return "";
    return name.substr(slashPos, dotPos - slashPos);
}

// Copyright (c) 2008-2009 Bjoern Hoehrmann <bjoern@hoehrmann.de>
// See http://bjoern.hoehrmann.de/utf-8/decoder/dfa/ for details.

#define UTF8_ACCEPT 0
#define UTF8_REJECT 1

static const uint8_t utf8d[] = {
    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,  // 00..1f
    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,  // 20..3f
    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,  // 40..5f
    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,  // 60..7f
    1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,
    1,   1,   1,   1,   1,   9,   9,   9,   9,   9,   9,
    9,   9,   9,   9,   9,   9,   9,   9,   9,   9,  // 80..9f
    7,   7,   7,   7,   7,   7,   7,   7,   7,   7,   7,
    7,   7,   7,   7,   7,   7,   7,   7,   7,   7,   7,
    7,   7,   7,   7,   7,   7,   7,   7,   7,   7,  // a0..bf
    8,   8,   2,   2,   2,   2,   2,   2,   2,   2,   2,
    2,   2,   2,   2,   2,   2,   2,   2,   2,   2,   2,
    2,   2,   2,   2,   2,   2,   2,   2,   2,   2,  // c0..df
    0xa, 0x3, 0x3, 0x3, 0x3, 0x3, 0x3, 0x3, 0x3, 0x3, 0x3,
    0x3, 0x3, 0x4, 0x3, 0x3,  // e0..ef
    0xb, 0x6, 0x6, 0x6, 0x5, 0x8, 0x8, 0x8, 0x8, 0x8, 0x8,
    0x8, 0x8, 0x8, 0x8, 0x8,  // f0..ff
    0x0, 0x1, 0x2, 0x3, 0x5, 0x8, 0x7, 0x1, 0x1, 0x1, 0x4,
    0x6, 0x1, 0x1, 0x1, 0x1,  // s0..s0
    1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,
    1,   1,   1,   1,   1,   1,   0,   1,   1,   1,   1,
    1,   0,   1,   0,   1,   1,   1,   1,   1,   1,  // s1..s2
    1,   2,   1,   1,   1,   1,   1,   2,   1,   2,   1,
    1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,
    1,   2,   1,   1,   1,   1,   1,   1,   1,   1,  // s3..s4
    1,   2,   1,   1,   1,   1,   1,   1,   1,   2,   1,
    1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,
    1,   3,   1,   3,   1,   1,   1,   1,   1,   1,  // s5..s6
    1,   3,   1,   1,   1,   1,   1,   3,   1,   3,   1,
    1,   1,   1,   1,   1,   1,   3,   1,   1,   1,   1,
    1,   1,   1,   1,   1,   1,   1,   1,   1,   1,  // s7..s8
};

uint32_t inline decode(uint32_t* state, uint32_t* codep, uint32_t byte) {
    uint32_t type = utf8d[byte];

    *codep = (*state != UTF8_ACCEPT) ? (byte & 0x3fu) | (*codep << 6)
                                     : (0xff >> type) & (byte);

    *state = utf8d[256 + *state * 16 + type];
    return *state;
}

int utf8_decode(const std::string& utf8, uint32_t* target) {
    uint32_t codepoint;
    uint32_t state = 0;
    auto* ptr = target;

    for (auto s : utf8) {
        if (!decode(&state, &codepoint, s)) {
            if (codepoint <= 0xffff) *ptr++ = codepoint;
        }
    }
    return ptr - target;
}

std::wstring utf8_decode(const std::string& txt) {
    std::wstring result;

    uint32_t codepoint;
    uint32_t state = 0;

    for (auto s : txt) {
        if (!decode(&state, &codepoint, s)) {
            if (codepoint <= 0xffff) result.push_back(codepoint);
        }
    }
    return result;
}

std::string utf8_encode(const std::string& txt) {
    std::string out;
    const uint8_t* s = (uint8_t*)txt.c_str();
    for (int i = 0; i < txt.length(); i++) {
        uint8_t c = s[i];
        if (c <= 0x7f)
            out.push_back(c);
        else {
            out.push_back(0xC0 | (c >> 6));
            out.push_back(0x80 | (c & 0x3F));
        }
    }
    return out;
}

std::string utf8_encode(const std::wstring& s) {
    std::string out;
    for (uint16_t c : s) {
        if (c <= 0x7f)
            out.push_back(c);
        else if (c < 0x800) {
            out.push_back(0xC0 | (c >> 6));
            out.push_back(0x80 | (c & 0x3F));
        } else /*if (c < 0x10000) */ {
            out.push_back(0xE0 | (c >> 12));
            out.push_back(0x80 | ((c >> 6) & 0x3f));
            out.push_back(0x80 | (c & 0x3F));
        }
    }
    return out;
}

void replace_char(std::string& s, char c, char r) { replace_char(&s[0], c, r); }

void replace_char(char* s, char c, char r) {
    while (*s) {
        if (*s == c) *s = r;
        s++;
    }
}

#ifdef _WIN32
ExecPipe::ExecPipe(const std::string& cmd) {
    SECURITY_ATTRIBUTES saAttr = {sizeof(SECURITY_ATTRIBUTES)};
    saAttr.bInheritHandle = TRUE;  // Pipe handles are inherited by child
                                   // process.
    saAttr.lpSecurityDescriptor = NULL;

    auto c = std::string("cmd.exe /C ") + cmd;

    // Create a pipe to get results from child's stdout.
    if (!CreatePipe(&hPipeRead, &hPipeWrite, &saAttr, 0)) return;

    PROCESS_INFORMATION pi = {0};

    STARTUPINFO si = {sizeof(STARTUPINFO)};
    si.dwFlags = STARTF_USESHOWWINDOW | STARTF_USESTDHANDLES;
    si.hStdOutput = hPipeWrite;
    si.hStdError = NULL;
    si.wShowWindow = SW_HIDE;  // Prevents cmd window from flashing. Requires
                               // STARTF_USESHOWWINDOW in dwFlags.

    BOOL fSuccess = CreateProcessA(NULL, (LPSTR)c.c_str(), NULL, NULL, TRUE,
                                   CREATE_NEW_CONSOLE, NULL, NULL, &si, &pi);
    if (!fSuccess) {
        LOGD("FAILED %d", GetLastError());
        CloseHandle(hPipeWrite);
        CloseHandle(hPipeRead);
        hProcess = 0;
    }
    hProcess = pi.hProcess;
}

int ExecPipe::read(uint8_t* target, int size) {
    DWORD dwRead = 0;
    DWORD dwAvail = 0;
    int total = 0;

    while (size > 0) {
        if (!::PeekNamedPipe(hPipeRead, NULL, 0, NULL, &dwAvail, NULL))
            return -2;

        if (!dwAvail)  // no data available, return
            break;

        if (dwAvail > size) dwAvail = size;

        if (!::ReadFile(hPipeRead, target, dwAvail, &dwRead, NULL) || !dwRead)
            // error, the child process might ended
            return -2;
        sleepms(1);
        size -= dwRead;
        total += dwRead;
        target += dwRead;
    }

    if (total == 0) return -1;

    return total;
}

int ExecPipe::write(uint8_t* source, int size) { return 0; }

ExecPipe& ExecPipe::operator=(ExecPipe&& other) noexcept {
    hPipeRead = other.hPipeRead;
    hPipeWrite = other.hPipeWrite;
    hProcess = other.hProcess;
    other.hProcess = 0;
    return *this;
}

bool ExecPipe::hasEnded() {
    if (hProcess == 0) return true;
    if (WaitForSingleObject(hProcess, 50) == WAIT_OBJECT_0) {
        hProcess = 0;
        return true;
    }
    return false;
}

ExecPipe::~ExecPipe() {}

void ExecPipe::Kill() {
    LOGD("KILL %d", hProcess);
    if (hProcess != 0) {
        if (TerminateProcess(hProcess, 0) == 0) {
            LOGD("Could not kill process: %d", GetLastError());
        }
        CloseHandle(hProcess);
    }
}

#else


pid_t popen2(const char* command, int* infp, int* outfp) {
    enum { READ, WRITE };
    int p_stdin[2], p_stdout[2];
    pid_t pid;

    if (pipe(p_stdin) != 0 || pipe(p_stdout) != 0) return -1;

    pid = fork();

    if (pid < 0) return pid;
    if (pid == 0) {
        close(p_stdin[WRITE]);
        dup2(p_stdin[READ], READ);
        close(p_stdout[READ]);
        dup2(p_stdout[WRITE], WRITE);

        execl("/bin/sh", "sh", "-c", command, NULL);
        perror("execl");
        exit(1);
    }

    if (infp == nullptr)
        close(p_stdin[WRITE]);
    else
        *infp = p_stdin[WRITE];

    if (outfp == nullptr)
        close(p_stdout[READ]);
    else
        *outfp = p_stdout[READ];

    return pid;
}

ExecPipe::ExecPipe(const std::string& cmd) {
    pid = popen2(cmd.c_str(), &infd, &outfd);
    fcntl(outfd, F_SETFL, O_NONBLOCK);
}

ExecPipe::~ExecPipe() {
    int result;
    if (pid != -1) {
        LOGD("Waiting");
        waitpid(pid, &result, 0);
        LOGD("RESULT %d", result);
    }
}

ExecPipe& ExecPipe::operator=(ExecPipe&& other) noexcept {
    pid = other.pid;
    outfd = other.outfd;
    infd = other.infd;
    other.pid = -1;
    return *this;
}

void ExecPipe::Kill() {
    if (pid != -1) {
        int result;
        kill(pid, SIGKILL);
        waitpid(pid, &result, 0);
        pid = -1;
    }
}

// 0 = Done, -1 = Still data left, -2 = error
int ExecPipe::read(uint8_t* target, int size) {
    int rc = ::read(outfd, target, size);
    if (rc == -1 && errno != EAGAIN) rc = -2;
    return rc;
}

int ExecPipe::write(uint8_t* source, int size) {
    int rc = ::write(outfd, source, size);
    return rc;
}

bool ExecPipe::hasEnded() {
    if (pid == -1) return true;
    int rc;
    if (waitpid(pid, &rc, WNOHANG) == pid) {
        LOGD("PID ended %d %d", pid, rc);
        pid = -1;
        return true;
    }
    return false;
}

#endif

ExecPipe::operator std::string() {
    char buf[1024];
    std::string result;
    bool ended = false;
    while (true) {
        int sz = read(reinterpret_cast<uint8_t*>(&buf[0]), sizeof(buf));
        if (sz > 0) {
            result += std::string(buf, 0, sz);
        } else if (sz != -1 || ended)
            return result;
        ended = hasEnded();
        sleepms(100);
    }
    return result;
}

int shellExec(const std::string& cmd, const std::string& binDir) {
#ifdef _WIN32
    auto cmdLine = utils::format("/C %s", cmd);
    SHELLEXECUTEINFO ShExecInfo = {0};
    ShExecInfo.cbSize = sizeof(SHELLEXECUTEINFO);
    ShExecInfo.fMask = SEE_MASK_NOCLOSEPROCESS;
    ShExecInfo.hwnd = NULL;
    ShExecInfo.lpVerb = NULL;
    ShExecInfo.lpFile = "cmd.exe";

    ShExecInfo.lpParameters = cmdLine.c_str();
    if (binDir != "") ShExecInfo.lpDirectory = binDir.c_str();
    ShExecInfo.nShow = SW_HIDE;
    ShExecInfo.hInstApp = NULL;
    ShellExecuteEx(&ShExecInfo);
    WaitForSingleObject(ShExecInfo.hProcess, INFINITE);
    return 0;
#else
    return system((binDir + "/" + cmd).c_str());
#endif
}

static const uint32_t crctab[] = {
    0x0,        0x04c11db7, 0x09823b6e, 0x0d4326d9, 0x130476dc, 0x17c56b6b,
    0x1a864db2, 0x1e475005, 0x2608edb8, 0x22c9f00f, 0x2f8ad6d6, 0x2b4bcb61,
    0x350c9b64, 0x31cd86d3, 0x3c8ea00a, 0x384fbdbd, 0x4c11db70, 0x48d0c6c7,
    0x4593e01e, 0x4152fda9, 0x5f15adac, 0x5bd4b01b, 0x569796c2, 0x52568b75,
    0x6a1936c8, 0x6ed82b7f, 0x639b0da6, 0x675a1011, 0x791d4014, 0x7ddc5da3,
    0x709f7b7a, 0x745e66cd, 0x9823b6e0, 0x9ce2ab57, 0x91a18d8e, 0x95609039,
    0x8b27c03c, 0x8fe6dd8b, 0x82a5fb52, 0x8664e6e5, 0xbe2b5b58, 0xbaea46ef,
    0xb7a96036, 0xb3687d81, 0xad2f2d84, 0xa9ee3033, 0xa4ad16ea, 0xa06c0b5d,
    0xd4326d90, 0xd0f37027, 0xddb056fe, 0xd9714b49, 0xc7361b4c, 0xc3f706fb,
    0xceb42022, 0xca753d95, 0xf23a8028, 0xf6fb9d9f, 0xfbb8bb46, 0xff79a6f1,
    0xe13ef6f4, 0xe5ffeb43, 0xe8bccd9a, 0xec7dd02d, 0x34867077, 0x30476dc0,
    0x3d044b19, 0x39c556ae, 0x278206ab, 0x23431b1c, 0x2e003dc5, 0x2ac12072,
    0x128e9dcf, 0x164f8078, 0x1b0ca6a1, 0x1fcdbb16, 0x018aeb13, 0x054bf6a4,
    0x0808d07d, 0x0cc9cdca, 0x7897ab07, 0x7c56b6b0, 0x71159069, 0x75d48dde,
    0x6b93dddb, 0x6f52c06c, 0x6211e6b5, 0x66d0fb02, 0x5e9f46bf, 0x5a5e5b08,
    0x571d7dd1, 0x53dc6066, 0x4d9b3063, 0x495a2dd4, 0x44190b0d, 0x40d816ba,
    0xaca5c697, 0xa864db20, 0xa527fdf9, 0xa1e6e04e, 0xbfa1b04b, 0xbb60adfc,
    0xb6238b25, 0xb2e29692, 0x8aad2b2f, 0x8e6c3698, 0x832f1041, 0x87ee0df6,
    0x99a95df3, 0x9d684044, 0x902b669d, 0x94ea7b2a, 0xe0b41de7, 0xe4750050,
    0xe9362689, 0xedf73b3e, 0xf3b06b3b, 0xf771768c, 0xfa325055, 0xfef34de2,
    0xc6bcf05f, 0xc27dede8, 0xcf3ecb31, 0xcbffd686, 0xd5b88683, 0xd1799b34,
    0xdc3abded, 0xd8fba05a, 0x690ce0ee, 0x6dcdfd59, 0x608edb80, 0x644fc637,
    0x7a089632, 0x7ec98b85, 0x738aad5c, 0x774bb0eb, 0x4f040d56, 0x4bc510e1,
    0x46863638, 0x42472b8f, 0x5c007b8a, 0x58c1663d, 0x558240e4, 0x51435d53,
    0x251d3b9e, 0x21dc2629, 0x2c9f00f0, 0x285e1d47, 0x36194d42, 0x32d850f5,
    0x3f9b762c, 0x3b5a6b9b, 0x0315d626, 0x07d4cb91, 0x0a97ed48, 0x0e56f0ff,
    0x1011a0fa, 0x14d0bd4d, 0x19939b94, 0x1d528623, 0xf12f560e, 0xf5ee4bb9,
    0xf8ad6d60, 0xfc6c70d7, 0xe22b20d2, 0xe6ea3d65, 0xeba91bbc, 0xef68060b,
    0xd727bbb6, 0xd3e6a601, 0xdea580d8, 0xda649d6f, 0xc423cd6a, 0xc0e2d0dd,
    0xcda1f604, 0xc960ebb3, 0xbd3e8d7e, 0xb9ff90c9, 0xb4bcb610, 0xb07daba7,
    0xae3afba2, 0xaafbe615, 0xa7b8c0cc, 0xa379dd7b, 0x9b3660c6, 0x9ff77d71,
    0x92b45ba8, 0x9675461f, 0x8832161a, 0x8cf30bad, 0x81b02d74, 0x857130c3,
    0x5d8a9099, 0x594b8d2e, 0x5408abf7, 0x50c9b640, 0x4e8ee645, 0x4a4ffbf2,
    0x470cdd2b, 0x43cdc09c, 0x7b827d21, 0x7f436096, 0x7200464f, 0x76c15bf8,
    0x68860bfd, 0x6c47164a, 0x61043093, 0x65c52d24, 0x119b4be9, 0x155a565e,
    0x18197087, 0x1cd86d30, 0x029f3d35, 0x065e2082, 0x0b1d065b, 0x0fdc1bec,
    0x3793a651, 0x3352bbe6, 0x3e119d3f, 0x3ad08088, 0x2497d08d, 0x2056cd3a,
    0x2d15ebe3, 0x29d4f654, 0xc5a92679, 0xc1683bce, 0xcc2b1d17, 0xc8ea00a0,
    0xd6ad50a5, 0xd26c4d12, 0xdf2f6bcb, 0xdbee767c, 0xe3a1cbc1, 0xe760d676,
    0xea23f0af, 0xeee2ed18, 0xf0a5bd1d, 0xf464a0aa, 0xf9278673, 0xfde69bc4,
    0x89b8fd09, 0x8d79e0be, 0x803ac667, 0x84fbdbd0, 0x9abc8bd5, 0x9e7d9662,
    0x933eb0bb, 0x97ffad0c, 0xafb010b1, 0xab710d06, 0xa6322bdf, 0xa2f33668,
    0xbcb4666d, 0xb8757bda, 0xb5365d03, 0xb1f740b4};

#define COMPUTE(var, ch) (var) = (var) << 8 ^ crctab[(var) >> 24 ^ (ch)]

uint32_t crc32(const uint32_t* data, int size) {
    uint32_t crc = 0;
    while (size--) {
        uint32_t v = *data++;
        COMPUTE(crc, v & 0xFF);
        COMPUTE(crc, (v >> 8) & 0xFF);
        COMPUTE(crc, (v >> 16) & 0xFF);
        COMPUTE(crc, (v >> 24) & 0xFF);
    }
    crc = ~crc;
    return crc;
}

uint32_t crc32_area(const uint32_t* data, int width, int height, int pitch) {
    uint32_t crc = 0;
    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            uint32_t v = *data++;
            COMPUTE(crc, v & 0xFF);
            COMPUTE(crc, (v >> 8) & 0xFF);
            COMPUTE(crc, (v >> 16) & 0xFF);
            COMPUTE(crc, (v >> 24) & 0xFF);
        }
        data += (pitch - width);
    }
    crc = ~crc;
    return crc;
}
static std::atomic<bool> performCalled(false);
thread_local static std::atomic<bool> inPerform(false);
static std::mutex callbackMutex;
static std::vector<std::function<void()>> callbacks;

void schedule_callback(const std::function<void()>& f) {
    if (!performCalled || inPerform)
        f();
    else {
        std::lock_guard<std::mutex> guard(callbackMutex);
        callbacks.push_back(f);
    }
}

void perform_callbacks() {
    performCalled = true;
    inPerform = true;
    std::lock_guard<std::mutex> guard(callbackMutex);
    for (const auto& f : callbacks) {
        LOGD("Calling cb");
        f();
    }
    callbacks.clear();
}

}  // namespace utils

#ifdef UNIT_TEST

#include "catch.hpp"

TEST_CASE("utils::text", "Text operations") {
    using namespace utils;
    using namespace std;

    std::string text =
        "This is a journey into sound. Stereophonic sound. Stereophonic sound "
        "with mounds of boundless hounds rounding the ground.";

    auto lines = text_wrap(text, 25);
    REQUIRE(lines.size() == 6);
    for (const auto& l : lines) {
        REQUIRE(l.length() <= 25);
    }
    std::string fullText = join(lines, "\n");

    auto lines2 = split(fullText, "\n");
    REQUIRE(lines2.size() == 6);
    for (int i = 0; i < 6; i++) {
        REQUIRE(lines[i] == lines2[i]);
    }

    // std::vector<std::string> linev = splitLines(lines);
}

TEST_CASE("utils::path", "Path name operations") {
    using namespace utils;
    using namespace std;

    const std::string test1 = "c:/path/to/my/file.ext";
    const std::string test2 = "file.ext.gz";
    const std::string test3 = "/my/pa.th/";

    REQUIRE(path_basename(test1) == "file");
    REQUIRE(path_directory(test1) == "c:/path/to/my");
    REQUIRE(path_filename(test1) == "file.ext");
    REQUIRE(path_extension(test1) == "ext");

    REQUIRE(path_extension(test2) == "gz");
    REQUIRE(path_basename(test2) == "file.ext");

    REQUIRE(path_directory(test2) == "");
    REQUIRE(path_filename(test3) == "");
    REQUIRE(path_extension(test3) == "");
    REQUIRE(path_basename(test3) == "");
    REQUIRE(path_directory(test3) == "/my/pa.th");
}

#endif

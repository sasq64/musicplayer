
#include <chrono>
#include <mutex>
#include <string>
#include <thread>
#include <unordered_map>

#include <coreutils/file.h>

namespace trace {

using clock = std::chrono::high_resolution_clock;
using time_point = clock::time_point;
using duration = clock::duration;

struct Tracer
{
    struct Scope
    {
        Tracer& tracer_;
        char const* name_;
        time_point start_;
        int tid_;

        Scope(Tracer& tracer, char const* name, int tid = -1)
            : tracer_{tracer}, name_{name}, start_{clock::now()}, tid_(tid)
        {}

        ~Scope() { tracer_.log_duration(name_, start_, clock::now(), tid_); }
    };

    std::mutex m;
    time_point start_;
    std::unordered_map<std::thread::id, int> thread_map;
    std::vector<std::string> names;
    int thread_counter{1000};


    Tracer(std::string const& file_name = "trace.json") : start_{clock::now()}
    {
        out = utils::File(file_name, utils::File::Mode::Write);
        out.writeString("{\"traceEvents\":[\n");
    }

    static Tracer& getInstance()
    {
        static Tracer t;
        return t;
    }

    static Scope scope(const char* name, int tid = -1) { return {getInstance(), name, tid}; }

    ~Tracer() { out.writeString("\n]}\n"); }

    // void start(const char* name) {}

    // void stop(const char* name) {}

    static uint64_t to_us(duration d)
    {
        return std::chrono::duration_cast<std::chrono::microseconds>(d).count();
    };

    int register_thread(std::string const& name) {

        names.push_back(name);
        char temp[2048];
        int pid = 0;
        if (!first)
            out.writeString(",\n");
        first = false;
        sprintf(temp,
            R"({"cat":"","pid":%d,"tid":%d,"ts":0,"ph":"M","name":"thread_name","args":{"name":"%s"}})",
            pid, (int)(names.size()-1), names.back().c_str());
        out.writeString(temp);
        return names.size() - 1;

    }

    void log_duration(const char* name, time_point const& start,
                      time_point const& stop, int tid = -1)
    {
        uint64_t start_us = to_us(start - start_);
        uint64_t duration_us = to_us(stop - start);

        char temp[2048];
        std::string category = "test";

        char ph = 'X';
        int pid = 0;

        std::lock_guard<std::mutex> lock(m);

        if (tid == -1) {
            tid = thread_map[std::this_thread::get_id()];
            if (tid == 0) {
                tid = thread_counter++;
                thread_map[std::this_thread::get_id()] = tid;
            }
        }

        if (!first)
            out.writeString(",\n");
        first = false;

        sprintf(
            temp,
            R"({"cat":"%s","pid":%d,"tid":%d,"ts":%llu,"ph":"%c","name":"%s","args":{},"dur":%llu})",
            category.c_str(), pid, tid, start_us, ph, name, duration_us);

        out.writeString(temp);
    }

    utils::File out;
    bool first{true};
};

} // namespace trace

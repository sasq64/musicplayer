#pragma once

#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <functional>
#include <string>
#include <unordered_map>
#include <vector>

namespace musix {

class player_exception : public std::exception
{
public:
    explicit player_exception(const std::string& msg = "") : msg(msg) {}
    const char* what() const noexcept override { return msg.c_str(); }

private:
    std::string msg;
};

class ChipPlayer
{
public:
    using Callback =
        std::function<void(const std::vector<std::string>& meta, ChipPlayer*)>;

    virtual ~ChipPlayer() = default;
    virtual int getSamples(int16_t* target, int size) = 0;

    virtual bool setParameter(const std::string& /*name*/, int32_t /*value*/)
    {
        return false;
    }
    virtual bool setParameter(const std::string& /*name*/,
                              const std::string& /*value*/)
    {
        return false;
    }

    virtual std::string getMeta(const std::string& what)
    {
        return metaData[what];
    };

    virtual bool couldHandle() { return true; }

    int getMetaInt(const std::string& what)
    {
        const std::string& data = getMeta(what);
        if (data == "")
            return -1;
        return atoi(data.c_str());
    };

    void setMeta()
    {
        for (const auto& cb : callbacks) {
            cb(changedMeta, this);
        }
        changedMeta.clear();
    }

    template <typename... A>
    void setMeta(const std::string& what, int value, const A&... args)
    {
        metaData[what] = std::to_string(value);
        changedMeta.push_back(what);
        setMeta(args...);
    }

    template <typename... A>
    void setMeta(const std::string& what, const std::string& value,
                 const A&... args)
    {
        metaData[what] = value;
        changedMeta.push_back(what);
        setMeta(args...);
    }

    template <typename... A>
    void setMeta(const std::string& what, const char* value, const A&... args)
    {
        metaData[what] = std::string(value);
        changedMeta.push_back(what);
        setMeta(args...);
    }

    virtual bool seekTo(int song, int seconds = -1) { return false; }

    void onMeta(const Callback& callback)
    {
        callbacks.push_back(callback);
        std::vector<std::string> meta;
        for (auto& md : metaData) {
            meta.push_back(md.first);
        }
        callback(meta, this);
    }

protected:
    std::unordered_map<std::string, std::string> metaData;
    std::vector<Callback> callbacks;
    std::vector<std::string> changedMeta;
};

} // namespace musix

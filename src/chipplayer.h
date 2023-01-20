#pragma once

#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <functional>
#include <stdexcept>
#include <string>
#include <unordered_map>
#include <variant>
#include <vector>

namespace musix {

using MetaVar = std::variant<std::string, double, uint32_t>;

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
        std::function<void(const std::vector<std::string>& meta)>;

    virtual ~ChipPlayer() = default;
    virtual int getSamples(int16_t* target, int size) = 0;

    virtual int getHZ() { return 44100; }

    virtual bool setParameter(const std::string& /*name*/, int32_t /*value*/)
    {
        return false;
    }
    virtual bool setParameter(const std::string& /*name*/,
                              const std::string& /*value*/)
    {
        return false;
    }

    MetaVar const& meta(std::string const& what) { return metaData[what]; }

    void setMeta()
    {
        if (!changedMeta.empty()) {
            for (const auto& cb : callbacks) {
                cb(changedMeta);
            }
            changedMeta.clear();
        }
    }

    template <typename T, typename... A,
              typename = typename std::enable_if<std::is_integral_v<T>>::type>
    void setMeta(const std::string& what, T value, const A&... args)
    {
        metaData[what] = static_cast<uint32_t>(value);
        changedMeta.push_back(what);
        setMeta(args...);
    }

    template <typename... A>
    void setMeta(const std::string& what, double value, const A&... args)
    {
        metaData[what] = value;
        changedMeta.push_back(what);
        setMeta(args...);
    }

    template <typename... A>
    void setMeta(const std::string& what, const MetaVar& value,
                 const A&... args)
    {
        metaData[what] = value;
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

    virtual bool seekTo(int  /*song*/, int  /*seconds*/ = -1) { return false; }

    void onMeta(const Callback& callback)
    {
        callbacks.push_back(callback);
        std::vector<std::string> meta;
        meta.reserve(metaData.size());
        for (auto& md : metaData) {
            meta.push_back(md.first);
        }
        callback(meta);
    }

protected:
    std::unordered_map<std::string, MetaVar> metaData;
    std::vector<Callback> callbacks;
    std::vector<std::string> changedMeta;
};

} // namespace musix

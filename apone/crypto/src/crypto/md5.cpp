#include "md5.h"

MD5::MD5(int flags) : flags(flags)
{
    solMD5_Init(&ctx);
}

void MD5::add(std::vector<uint8_t> const& data, int offset)
{
    solMD5_Update(&ctx, &data[offset], data.size() - offset);
}

std::vector<uint8_t> MD5::get()
{
    std::vector<uint8_t> result(16);
    solMD5_Final(result.data(), &ctx);
    return result;
}

uint64_t MD5::hash(std::string const& text)
{
    MD5_CTX ctx;
    std::vector<uint8_t> result(16);
    solMD5_Init(&ctx);
    solMD5_Update(&ctx, text.c_str(), text.length());
    solMD5_Final(result.data(), &ctx);
    return *(reinterpret_cast<uint64_t*>(&result[0]));
}

std::vector<uint8_t> MD5::calc(std::vector<uint8_t> const& data)
{
    MD5_CTX ctx;
    std::vector<uint8_t> result(16);
    solMD5_Init(&ctx);
    solMD5_Update(&ctx, data.data(), data.size());
    solMD5_Final(result.data(), &ctx);
    return result;
}

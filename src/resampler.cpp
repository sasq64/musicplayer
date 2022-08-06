#include <cstdlib>
#include <cstring>
#define _USE_MATH_DEFINES
#include <cmath>

#ifndef M_PI
#    define M_PI 3.14159265358979323846
#endif

#include "resampler.h"

static const uint16_t RESAMPLE_LUT[64 * 4] = {
    0x0c39, 0x66ad, 0x0d46, 0xffdf, 0x0b39, 0x6696, 0x0e5f, 0xffd8, 0x0a44,
    0x6669, 0x0f83, 0xffd0, 0x095a, 0x6626, 0x10b4, 0xffc8, 0x087d, 0x65cd,
    0x11f0, 0xffbf, 0x07ab, 0x655e, 0x1338, 0xffb6, 0x06e4, 0x64d9, 0x148c,
    0xffac, 0x0628, 0x643f, 0x15eb, 0xffa1, 0x0577, 0x638f, 0x1756, 0xff96,
    0x04d1, 0x62cb, 0x18cb, 0xff8a, 0x0435, 0x61f3, 0x1a4c, 0xff7e, 0x03a4,
    0x6106, 0x1bd7, 0xff71, 0x031c, 0x6007, 0x1d6c, 0xff64, 0x029f, 0x5ef5,
    0x1f0b, 0xff56, 0x022a, 0x5dd0, 0x20b3, 0xff48, 0x01be, 0x5c9a, 0x2264,
    0xff3a, 0x015b, 0x5b53, 0x241e, 0xff2c, 0x0101, 0x59fc, 0x25e0, 0xff1e,
    0x00ae, 0x5896, 0x27a9, 0xff10, 0x0063, 0x5720, 0x297a, 0xff02, 0x001f,
    0x559d, 0x2b50, 0xfef4, 0xffe2, 0x540d, 0x2d2c, 0xfee8, 0xffac, 0x5270,
    0x2f0d, 0xfedb, 0xff7c, 0x50c7, 0x30f3, 0xfed0, 0xff53, 0x4f14, 0x32dc,
    0xfec6, 0xff2e, 0x4d57, 0x34c8, 0xfebd, 0xff0f, 0x4b91, 0x36b6, 0xfeb6,
    0xfef5, 0x49c2, 0x38a5, 0xfeb0, 0xfedf, 0x47ed, 0x3a95, 0xfeac, 0xfece,
    0x4611, 0x3c85, 0xfeab, 0xfec0, 0x4430, 0x3e74, 0xfeac, 0xfeb6, 0x424a,
    0x4060, 0xfeaf, 0xfeaf, 0x4060, 0x424a, 0xfeb6, 0xfeac, 0x3e74, 0x4430,
    0xfec0, 0xfeab, 0x3c85, 0x4611, 0xfece, 0xfeac, 0x3a95, 0x47ed, 0xfedf,
    0xfeb0, 0x38a5, 0x49c2, 0xfef5, 0xfeb6, 0x36b6, 0x4b91, 0xff0f, 0xfebd,
    0x34c8, 0x4d57, 0xff2e, 0xfec6, 0x32dc, 0x4f14, 0xff53, 0xfed0, 0x30f3,
    0x50c7, 0xff7c, 0xfedb, 0x2f0d, 0x5270, 0xffac, 0xfee8, 0x2d2c, 0x540d,
    0xffe2, 0xfef4, 0x2b50, 0x559d, 0x001f, 0xff02, 0x297a, 0x5720, 0x0063,
    0xff10, 0x27a9, 0x5896, 0x00ae, 0xff1e, 0x25e0, 0x59fc, 0x0101, 0xff2c,
    0x241e, 0x5b53, 0x015b, 0xff3a, 0x2264, 0x5c9a, 0x01be, 0xff48, 0x20b3,
    0x5dd0, 0x022a, 0xff56, 0x1f0b, 0x5ef5, 0x029f, 0xff64, 0x1d6c, 0x6007,
    0x031c, 0xff71, 0x1bd7, 0x6106, 0x03a4, 0xff7e, 0x1a4c, 0x61f3, 0x0435,
    0xff8a, 0x18cb, 0x62cb, 0x04d1, 0xff96, 0x1756, 0x638f, 0x0577, 0xffa1,
    0x15eb, 0x643f, 0x0628, 0xffac, 0x148c, 0x64d9, 0x06e4, 0xffb6, 0x1338,
    0x655e, 0x07ab, 0xffbf, 0x11f0, 0x65cd, 0x087d, 0xffc8, 0x10b4, 0x6626,
    0x095a, 0xffd0, 0x0f83, 0x6669, 0x0a44, 0xffd8, 0x0e5f, 0x6696, 0x0b39,
    0xffdf, 0x0d46, 0x66ad, 0x0c39};

enum
{
    RESAMPLER_SHIFT = 16
};
enum
{
    RESAMPLER_RESOLUTION = 1 << RESAMPLER_SHIFT
};

enum
{
    resampler_buffer_size = 64 * 4
};

struct resampler
{
    int write_pos, write_filled;
    int read_pos, read_filled;
    unsigned phase;
    unsigned phase_inc;
    signed char delay_added;
    signed char delay_removed;
    int16_t buffer_in[2][resampler_buffer_size * 2];
    int16_t buffer_out[resampler_buffer_size * 2];
};

resampler* rs_create()
{
    auto* r = new resampler;

    r->write_pos = 1;
    r->write_filled = 0;
    r->read_pos = 0;
    r->read_filled = 0;
    r->phase = 0;
    r->phase_inc = 0;
    r->delay_added = -1;
    r->delay_removed = -1;
    memset(r->buffer_in, 0, sizeof(r->buffer_in));
    memset(r->buffer_out, 0, sizeof(r->buffer_out));

    return r;
}

void rs_delete(resampler* r)
{
    delete r;
}

resampler* rs_dup(const resampler* r)
{
    auto* r_out = new resampler;
    rs_dup_inplace(r_out, r);
    return r_out;
}

void rs_dup_inplace(resampler* r_out, const resampler* r_in)
{
    r_out->write_pos = r_in->write_pos;
    r_out->write_filled = r_in->write_filled;
    r_out->read_pos = r_in->read_pos;
    r_out->read_filled = r_in->read_filled;
    r_out->phase = r_in->phase;
    r_out->phase_inc = r_in->phase_inc;
    r_out->delay_added = r_in->delay_added;
    r_out->delay_removed = r_in->delay_removed;
    memcpy(r_out->buffer_in, r_in->buffer_in, sizeof(r_in->buffer_in));
    memcpy(r_out->buffer_out, r_in->buffer_out, sizeof(r_in->buffer_out));
}

int rs_get_free_count(resampler* r)
{
    return resampler_buffer_size - r->write_filled;
}

static int rs_min_filled(resampler*)
{
    return 4;
}

static int rs_input_delay(resampler*)
{
    return 1;
}

static int rs_output_delay(resampler*)
{
    return 0;
}

int rs_ready(resampler* r)
{
    return r->write_filled > rs_min_filled(r);
}

void rs_clear(resampler* r)
{
    r->write_pos = 1;
    r->write_filled = 0;
    r->read_pos = 0;
    r->read_filled = 0;
    r->phase = 0;
    r->delay_added = -1;
    r->delay_removed = -1;
}

void rs_set_rate(resampler* r, double new_factor)
{
    r->phase_inc = new_factor * RESAMPLER_RESOLUTION;
}

void rs_write_sample(resampler* r, int16_t ls, int16_t rs)
{
    if (r->delay_added < 0) {
        r->delay_added = 0;
        r->write_filled = rs_input_delay(r);
    }

    if (r->write_filled < resampler_buffer_size) {
        r->buffer_in[0][r->write_pos] = ls;
        r->buffer_in[0][r->write_pos + resampler_buffer_size] = ls;

        r->buffer_in[1][r->write_pos] = rs;
        r->buffer_in[1][r->write_pos + resampler_buffer_size] = rs;

        ++r->write_filled;

        r->write_pos = (r->write_pos + 1) % resampler_buffer_size;
    }
}

static int rs_run_cubic(resampler* r, int16_t** out_, int16_t const* out_end)
{
    int in_size = r->write_filled;
    int in_offset = resampler_buffer_size + r->write_pos - r->write_filled;
    int16_t const* inl_ = r->buffer_in[0] + in_offset;
    int16_t const* inr_ = r->buffer_in[1] + in_offset;
    int used = 0;
    in_size -= 4;
    if (in_size > 0) {
        int16_t* out = *out_;
        int16_t const* inl = inl_;
        int16_t const* inr = inr_;
        int16_t const* const in_end = inl + in_size;
        unsigned phase = r->phase;
        unsigned phase_inc = r->phase_inc;

        do {
            int samplel, sampler;

            if (out >= out_end) break;

            const int16_t* lut =
                (int16_t*)RESAMPLE_LUT + ((phase & 0xfc00u) >> 8u);

            samplel = ((inl[0] * lut[0]) >> 15) + ((inl[1] * lut[1]) >> 15) +
                      ((inl[2] * lut[2]) >> 15) + ((inl[3] * lut[3]) >> 15);
            sampler = ((inr[0] * lut[0]) >> 15) + ((inr[1] * lut[1]) >> 15) +
                      ((inr[2] * lut[2]) >> 15) + ((inr[3] * lut[3]) >> 15);

            if ((samplel + 0x8000) & 0xffff0000)
                samplel = 0x7fff ^ (samplel >> 31);
            if ((sampler + 0x8000) & 0xffff0000)
                sampler = 0x7fff ^ (sampler >> 31);

            *out++ = (int16_t)samplel;
            *out++ = (int16_t)sampler;

            phase += phase_inc;

            inl += (phase >> 16u);
            inr += (phase >> 16u);

            phase &= 0xFFFFu;
        } while (inl < in_end);

        r->phase = phase;
        *out_ = out;

        used = (int)(inl - inl_);

        r->write_filled -= used;
    }

    return used;
}

static void rs_fill(resampler* r)
{
    int min_filled = rs_min_filled(r);
    while (r->write_filled > min_filled &&
           r->read_filled < resampler_buffer_size) {
        int write_pos = (r->read_pos + r->read_filled) % resampler_buffer_size;
        int write_size = resampler_buffer_size - write_pos;
        int16_t* out = r->buffer_out + write_pos * 2;
        if (write_size > (resampler_buffer_size - r->read_filled))
            write_size = resampler_buffer_size - r->read_filled;
        rs_run_cubic(r, &out, out + write_size * 2);
        r->read_filled += (out - r->buffer_out - write_pos * 2) / 2;
    }
}

static void rs_fill_and_remove_delay(resampler* r)
{
    rs_fill(r);
    if (r->delay_removed < 0) {
        int delay = rs_output_delay(r);
        r->delay_removed = 0;
        while (delay--)
            rs_remove_sample(r);
    }
}

int rs_get_sample_count(resampler* r)
{
    if (r->read_filled < 1) rs_fill_and_remove_delay(r);
    return r->read_filled;
}

void rs_get_sample(resampler* r, int16_t* ls, int16_t* rs)
{
    if (r->read_filled < 1 && r->phase_inc) rs_fill_and_remove_delay(r);
    if (r->read_filled < 1) {
        *ls = 0;
        *rs = 0;
    } else {
        *ls = r->buffer_out[r->read_pos * 2 + 0];
        *rs = r->buffer_out[r->read_pos * 2 + 1];
    }
}

void rs_remove_sample(resampler* r)
{
    if (r->read_filled > 0) {
        --r->read_filled;
        r->read_pos = (r->read_pos + 1) % resampler_buffer_size;
    }
}

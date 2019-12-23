#include <stdlib.h>
#include <string.h>
#define _USE_MATH_DEFINES
#include <math.h>

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

#include "resampler.h"

//#include "rsp_hle/audio.h"
static const int16_t RESAMPLE_LUT[64 * 4] = {
    (int16_t)0x0c39, (int16_t)0x66ad, (int16_t)0x0d46, (int16_t)0xffdf,
    (int16_t)0x0b39, (int16_t)0x6696, (int16_t)0x0e5f, (int16_t)0xffd8,
    (int16_t)0x0a44, (int16_t)0x6669, (int16_t)0x0f83, (int16_t)0xffd0,
    (int16_t)0x095a, (int16_t)0x6626, (int16_t)0x10b4, (int16_t)0xffc8,
    (int16_t)0x087d, (int16_t)0x65cd, (int16_t)0x11f0, (int16_t)0xffbf,
    (int16_t)0x07ab, (int16_t)0x655e, (int16_t)0x1338, (int16_t)0xffb6,
    (int16_t)0x06e4, (int16_t)0x64d9, (int16_t)0x148c, (int16_t)0xffac,
    (int16_t)0x0628, (int16_t)0x643f, (int16_t)0x15eb, (int16_t)0xffa1,
    (int16_t)0x0577, (int16_t)0x638f, (int16_t)0x1756, (int16_t)0xff96,
    (int16_t)0x04d1, (int16_t)0x62cb, (int16_t)0x18cb, (int16_t)0xff8a,
    (int16_t)0x0435, (int16_t)0x61f3, (int16_t)0x1a4c, (int16_t)0xff7e,
    (int16_t)0x03a4, (int16_t)0x6106, (int16_t)0x1bd7, (int16_t)0xff71,
    (int16_t)0x031c, (int16_t)0x6007, (int16_t)0x1d6c, (int16_t)0xff64,
    (int16_t)0x029f, (int16_t)0x5ef5, (int16_t)0x1f0b, (int16_t)0xff56,
    (int16_t)0x022a, (int16_t)0x5dd0, (int16_t)0x20b3, (int16_t)0xff48,
    (int16_t)0x01be, (int16_t)0x5c9a, (int16_t)0x2264, (int16_t)0xff3a,
    (int16_t)0x015b, (int16_t)0x5b53, (int16_t)0x241e, (int16_t)0xff2c,
    (int16_t)0x0101, (int16_t)0x59fc, (int16_t)0x25e0, (int16_t)0xff1e,
    (int16_t)0x00ae, (int16_t)0x5896, (int16_t)0x27a9, (int16_t)0xff10,
    (int16_t)0x0063, (int16_t)0x5720, (int16_t)0x297a, (int16_t)0xff02,
    (int16_t)0x001f, (int16_t)0x559d, (int16_t)0x2b50, (int16_t)0xfef4,
    (int16_t)0xffe2, (int16_t)0x540d, (int16_t)0x2d2c, (int16_t)0xfee8,
    (int16_t)0xffac, (int16_t)0x5270, (int16_t)0x2f0d, (int16_t)0xfedb,
    (int16_t)0xff7c, (int16_t)0x50c7, (int16_t)0x30f3, (int16_t)0xfed0,
    (int16_t)0xff53, (int16_t)0x4f14, (int16_t)0x32dc, (int16_t)0xfec6,
    (int16_t)0xff2e, (int16_t)0x4d57, (int16_t)0x34c8, (int16_t)0xfebd,
    (int16_t)0xff0f, (int16_t)0x4b91, (int16_t)0x36b6, (int16_t)0xfeb6,
    (int16_t)0xfef5, (int16_t)0x49c2, (int16_t)0x38a5, (int16_t)0xfeb0,
    (int16_t)0xfedf, (int16_t)0x47ed, (int16_t)0x3a95, (int16_t)0xfeac,
    (int16_t)0xfece, (int16_t)0x4611, (int16_t)0x3c85, (int16_t)0xfeab,
    (int16_t)0xfec0, (int16_t)0x4430, (int16_t)0x3e74, (int16_t)0xfeac,
    (int16_t)0xfeb6, (int16_t)0x424a, (int16_t)0x4060, (int16_t)0xfeaf,
    (int16_t)0xfeaf, (int16_t)0x4060, (int16_t)0x424a, (int16_t)0xfeb6,
    (int16_t)0xfeac, (int16_t)0x3e74, (int16_t)0x4430, (int16_t)0xfec0,
    (int16_t)0xfeab, (int16_t)0x3c85, (int16_t)0x4611, (int16_t)0xfece,
    (int16_t)0xfeac, (int16_t)0x3a95, (int16_t)0x47ed, (int16_t)0xfedf,
    (int16_t)0xfeb0, (int16_t)0x38a5, (int16_t)0x49c2, (int16_t)0xfef5,
    (int16_t)0xfeb6, (int16_t)0x36b6, (int16_t)0x4b91, (int16_t)0xff0f,
    (int16_t)0xfebd, (int16_t)0x34c8, (int16_t)0x4d57, (int16_t)0xff2e,
    (int16_t)0xfec6, (int16_t)0x32dc, (int16_t)0x4f14, (int16_t)0xff53,
    (int16_t)0xfed0, (int16_t)0x30f3, (int16_t)0x50c7, (int16_t)0xff7c,
    (int16_t)0xfedb, (int16_t)0x2f0d, (int16_t)0x5270, (int16_t)0xffac,
    (int16_t)0xfee8, (int16_t)0x2d2c, (int16_t)0x540d, (int16_t)0xffe2,
    (int16_t)0xfef4, (int16_t)0x2b50, (int16_t)0x559d, (int16_t)0x001f,
    (int16_t)0xff02, (int16_t)0x297a, (int16_t)0x5720, (int16_t)0x0063,
    (int16_t)0xff10, (int16_t)0x27a9, (int16_t)0x5896, (int16_t)0x00ae,
    (int16_t)0xff1e, (int16_t)0x25e0, (int16_t)0x59fc, (int16_t)0x0101,
    (int16_t)0xff2c, (int16_t)0x241e, (int16_t)0x5b53, (int16_t)0x015b,
    (int16_t)0xff3a, (int16_t)0x2264, (int16_t)0x5c9a, (int16_t)0x01be,
    (int16_t)0xff48, (int16_t)0x20b3, (int16_t)0x5dd0, (int16_t)0x022a,
    (int16_t)0xff56, (int16_t)0x1f0b, (int16_t)0x5ef5, (int16_t)0x029f,
    (int16_t)0xff64, (int16_t)0x1d6c, (int16_t)0x6007, (int16_t)0x031c,
    (int16_t)0xff71, (int16_t)0x1bd7, (int16_t)0x6106, (int16_t)0x03a4,
    (int16_t)0xff7e, (int16_t)0x1a4c, (int16_t)0x61f3, (int16_t)0x0435,
    (int16_t)0xff8a, (int16_t)0x18cb, (int16_t)0x62cb, (int16_t)0x04d1,
    (int16_t)0xff96, (int16_t)0x1756, (int16_t)0x638f, (int16_t)0x0577,
    (int16_t)0xffa1, (int16_t)0x15eb, (int16_t)0x643f, (int16_t)0x0628,
    (int16_t)0xffac, (int16_t)0x148c, (int16_t)0x64d9, (int16_t)0x06e4,
    (int16_t)0xffb6, (int16_t)0x1338, (int16_t)0x655e, (int16_t)0x07ab,
    (int16_t)0xffbf, (int16_t)0x11f0, (int16_t)0x65cd, (int16_t)0x087d,
    (int16_t)0xffc8, (int16_t)0x10b4, (int16_t)0x6626, (int16_t)0x095a,
    (int16_t)0xffd0, (int16_t)0x0f83, (int16_t)0x6669, (int16_t)0x0a44,
    (int16_t)0xffd8, (int16_t)0x0e5f, (int16_t)0x6696, (int16_t)0x0b39,
    (int16_t)0xffdf, (int16_t)0x0d46, (int16_t)0x66ad, (int16_t)0x0c39
};


enum { RESAMPLER_SHIFT = 16 };
enum { RESAMPLER_RESOLUTION = 1 << RESAMPLER_SHIFT };

enum { resampler_buffer_size = 64 * 4 };

typedef struct resampler
{
    int write_pos, write_filled;
    int read_pos, read_filled;
    int phase;
    int phase_inc;
    signed char delay_added;
    signed char delay_removed;
    short buffer_in[2][resampler_buffer_size * 2];
    short buffer_out[resampler_buffer_size * 2];
} resampler;

void * rs_create(void)
{
    resampler * r = ( resampler * ) malloc( sizeof(resampler) );
    if ( !r ) return 0;

    r->write_pos = 1;
    r->write_filled = 0;
    r->read_pos = 0;
    r->read_filled = 0;
    r->phase = 0;
    r->phase_inc = 0;
    r->delay_added = -1;
    r->delay_removed = -1;
    memset( r->buffer_in, 0, sizeof(r->buffer_in) );
    memset( r->buffer_out, 0, sizeof(r->buffer_out) );

    return r;
}

void rs_delete(void * _r)
{
    free( _r );
}

void * rs_dup(const void * _r)
{
    void * r_out = malloc( sizeof(resampler) );
    if ( !r_out ) return 0;

    rs_dup_inplace(r_out, _r);

    return r_out;
}

void rs_dup_inplace(void *_d, const void *_s)
{
    const resampler * r_in = ( const resampler * ) _s;
    resampler * r_out = ( resampler * ) _d;

    r_out->write_pos = r_in->write_pos;
    r_out->write_filled = r_in->write_filled;
    r_out->read_pos = r_in->read_pos;
    r_out->read_filled = r_in->read_filled;
    r_out->phase = r_in->phase;
    r_out->phase_inc = r_in->phase_inc;
    r_out->delay_added = r_in->delay_added;
    r_out->delay_removed = r_in->delay_removed;
    memcpy( r_out->buffer_in, r_in->buffer_in, sizeof(r_in->buffer_in) );
    memcpy( r_out->buffer_out, r_in->buffer_out, sizeof(r_in->buffer_out) );
}

int rs_get_free_count(void *_r)
{
    resampler * r = ( resampler * ) _r;
    return resampler_buffer_size - r->write_filled;
}

static int rs_min_filled(resampler *r)
{
    return 4;
}

static int rs_input_delay(resampler *r)
{
    return 1;
}

static int rs_output_delay(resampler *r)
{
    return 0;
}

int rs_ready(void *_r)
{
    resampler * r = ( resampler * ) _r;
    return r->write_filled > rs_min_filled(r);
}

void rs_clear(void *_r)
{
    resampler * r = ( resampler * ) _r;
    r->write_pos = 1;
    r->write_filled = 0;
    r->read_pos = 0;
    r->read_filled = 0;
    r->phase = 0;
    r->delay_added = -1;
    r->delay_removed = -1;
}

void rs_set_rate(void *_r, double new_factor)
{
    resampler * r = ( resampler * ) _r;
    r->phase_inc = new_factor * RESAMPLER_RESOLUTION;
}

void rs_write_sample(void *_r, short ls, short rs)
{
    resampler * r = ( resampler * ) _r;

    if ( r->delay_added < 0 )
    {
        r->delay_added = 0;
        r->write_filled = rs_input_delay( r );
    }
    
    if ( r->write_filled < resampler_buffer_size )
    {
        r->buffer_in[ 0 ][ r->write_pos ] = ls;
        r->buffer_in[ 0 ][ r->write_pos + resampler_buffer_size ] = ls;

        r->buffer_in[ 1 ][ r->write_pos ] = rs;
        r->buffer_in[ 1 ][ r->write_pos + resampler_buffer_size ] = rs;
        
        ++r->write_filled;

        r->write_pos = ( r->write_pos + 1 ) % resampler_buffer_size;
    }
}

static int rs_run_cubic(resampler * r, short ** out_, short * out_end)
{
    int in_size = r->write_filled;
    int in_offset = resampler_buffer_size + r->write_pos - r->write_filled;
    short const* inl_ = r->buffer_in[0] + in_offset;
    short const* inr_ = r->buffer_in[1] + in_offset;
    int used = 0;
    in_size -= 4;
    if ( in_size > 0 )
    {
        short* out = *out_;
        short const* inl = inl_;
        short const* inr = inr_;
        short const* const in_end = inl + in_size;
        int phase = r->phase;
        int phase_inc = r->phase_inc;

        do
        {
            int samplel, sampler;
            
            if ( out >= out_end )
                break;

            const int16_t* lut = RESAMPLE_LUT + ((phase & 0xfc00) >> 8);
            
            samplel = ((inl[0] * lut[0]) >> 15) + ((inl[1] * lut[1]) >> 15)
                    + ((inl[2] * lut[2]) >> 15) + ((inl[3] * lut[3]) >> 15);
            sampler = ((inr[0] * lut[0]) >> 15) + ((inr[1] * lut[1]) >> 15)
                    + ((inr[2] * lut[2]) >> 15) + ((inr[3] * lut[3]) >> 15);
            
            if ((samplel + 0x8000) & 0xffff0000) samplel = 0x7fff ^ (samplel >> 31);
            if ((sampler + 0x8000) & 0xffff0000) sampler = 0x7fff ^ (sampler >> 31);
            
            *out++ = (short)samplel;
            *out++ = (short)sampler;

            phase += phase_inc;

            inl += (phase >> 16);
            inr += (phase >> 16);

            phase &= 0xFFFF;
        }
        while ( inl < in_end );

        r->phase = phase;
        *out_ = out;

        used = (int)(inl - inl_);

        r->write_filled -= used;
    }

    return used;
}

static void rs_fill(resampler * r)
{
    int min_filled = rs_min_filled(r);
    while ( r->write_filled > min_filled &&
            r->read_filled < resampler_buffer_size )
    {
        int write_pos = ( r->read_pos + r->read_filled ) % resampler_buffer_size;
        int write_size = resampler_buffer_size - write_pos;
        short * out = r->buffer_out + write_pos * 2;
        if ( write_size > ( resampler_buffer_size - r->read_filled ) )
            write_size = resampler_buffer_size - r->read_filled;
        rs_run_cubic( r, &out, out + write_size * 2 );
        r->read_filled += ( out - r->buffer_out - write_pos * 2 ) / 2;
    }
}

static void rs_fill_and_remove_delay(resampler * r)
{
    rs_fill( r );
    if ( r->delay_removed < 0 )
    {
        int delay = rs_output_delay( r );
        r->delay_removed = 0;
        while ( delay-- )
            rs_remove_sample( r );
    }
}

int rs_get_sample_count(void *_r)
{
    resampler * r = ( resampler * ) _r;
    if ( r->read_filled < 1 )
        rs_fill_and_remove_delay( r );
    return r->read_filled;
}

void rs_get_sample(void *_r, short * ls, short * rs)
{
    resampler * r = ( resampler * ) _r;
    if ( r->read_filled < 1 && r->phase_inc )
        rs_fill_and_remove_delay( r );
    if ( r->read_filled < 1 )
    {
        *ls = 0;
        *rs = 0;
    }
    else
    {
        *ls = r->buffer_out[ r->read_pos * 2 + 0 ];
        *rs = r->buffer_out[ r->read_pos * 2 + 1 ];
    }
}

void rs_remove_sample(void *_r)
{
    resampler * r = ( resampler * ) _r;
    if ( r->read_filled > 0 )
    {
        --r->read_filled;
        r->read_pos = ( r->read_pos + 1 ) % resampler_buffer_size;
    }
}

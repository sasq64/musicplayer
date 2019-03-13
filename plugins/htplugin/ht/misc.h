
#include "ht/satsound.h"
#include "ht/sega.h"
#include "ht/dcsound.h"
#include <psf/psflib.h>
#include "ht/yam.h" 


static void * psf_file_fopen( const char * uri );
static void * psf_file_fopen( const char * uri );
static int psf_file_fseek( void * handle, int64_t offset, int whence );
static int psf_file_fclose( void * handle );
static size_t psf_file_fread( void * buffer, size_t size, size_t count, void * handle );
static long psf_file_ftell( void * handle );

inline unsigned get_be16( void const* p )
{
    return  (unsigned) ((unsigned char const*) p) [0] << 8 |
            (unsigned) ((unsigned char const*) p) [1];
}

inline unsigned get_le32( void const* p )
{
    return  (unsigned) ((unsigned char const*) p) [3] << 24 |
            (unsigned) ((unsigned char const*) p) [2] << 16 |
            (unsigned) ((unsigned char const*) p) [1] <<  8 |
            (unsigned) ((unsigned char const*) p) [0];
}

inline unsigned get_be32( void const* p )
{
    return  (unsigned) ((unsigned char const*) p) [0] << 24 |
            (unsigned) ((unsigned char const*) p) [1] << 16 |
            (unsigned) ((unsigned char const*) p) [2] <<  8 |
            (unsigned) ((unsigned char const*) p) [3];
}

inline void set_le32( void* p, unsigned n )
{
    ((unsigned char*) p) [0] = (unsigned char) n;
    ((unsigned char*) p) [1] = (unsigned char) (n >> 8);
    ((unsigned char*) p) [2] = (unsigned char) (n >> 16);
    ((unsigned char*) p) [3] = (unsigned char) (n >> 24);
} 

typedef struct {
	uint32_t pc0;
	uint32_t gp0;
	uint32_t t_addr;
	uint32_t t_size;
	uint32_t d_addr;
	uint32_t d_size;
	uint32_t b_addr;
	uint32_t b_size;
	uint32_t s_ptr;
	uint32_t s_size;
	uint32_t sp,fp,gp,ret,base;
} exec_header_t;

typedef struct {
	char key[8];
	uint32_t text;
	uint32_t data;
	exec_header_t exec;
	char title[60];
} psxexe_hdr_t;

struct sdsf_loader_state
{
	void *emu;
	void *yam;
	size_t version;
	uint8_t * data;
    size_t data_size;

}; 

const psf_file_callbacks psf_file_system =
{
	"\\/|:",
	psf_file_fopen,
	psf_file_fread,
	psf_file_fseek,
	psf_file_fclose,
	psf_file_ftell
};

static void * psf_file_fopen( const char * uri )
{
	FILE *f;

    fprintf(stderr, "OPEN %s\n", uri);

	f = fopen(uri, "rb");

    // ANTI WINDOWS HACK - Try the lower case version of the filename if it can't be found
    if(!f) {
        static char temp[2048];
        strncpy(temp, uri, sizeof(temp));
        char *p = strrchr(temp, '/');
        if(!p) p = temp;
        while(*p) {
            *p = tolower(*p);
            p++;
        }
        f = fopen(temp, "rb");
    }

	return f;
}

static size_t psf_file_fread( void * buffer, size_t size, size_t count, void * handle )
{
	size_t bytes_read = fread(buffer,size,count,(FILE*)handle);
	return bytes_read / size;
}

static int psf_file_fseek( void * handle, int64_t offset, int whence )
{
	int result = fseek((FILE*)handle, offset, whence);
	return result;
}

static int psf_file_fclose( void * handle )
{
	fclose((FILE*)handle);
	return 0;
}

static long psf_file_ftell( void * handle )
{
	long pos = ftell((FILE*) handle);
	return pos;
}

int sdsf_loader(void * context, const uint8_t * exe, size_t exe_size,
                                  const uint8_t * reserved, size_t reserved_size)
{
    if ( exe_size < 4 ) return -1;

    struct sdsf_loader_state * state = ( struct sdsf_loader_state * ) context;

    uint8_t * dst = state->data;

    if ( state->data_size < 4 ) {
        state->data = dst = ( uint8_t * ) malloc( exe_size );
        state->data_size = exe_size;
        memcpy( dst, exe, exe_size );
        return 0;
    }

    uint32_t dst_start = get_le32( dst );
    uint32_t src_start = get_le32( exe );
    dst_start &= 0x7fffff;
    src_start &= 0x7fffff;
    uint32_t dst_len = state->data_size - 4;
    uint32_t src_len = exe_size - 4;
    if ( dst_len > 0x800000 ) dst_len = 0x800000;
    if ( src_len > 0x800000 ) src_len = 0x800000;

    if ( src_start < dst_start )
    {
        uint32_t diff = dst_start - src_start;
        state->data_size = dst_len + 4 + diff;
        state->data = dst = ( uint8_t * ) realloc( dst, state->data_size );
        memmove( dst + 4 + diff, dst + 4, dst_len );
        memset( dst + 4, 0, diff );
        dst_len += diff;
        dst_start = src_start;
        set_le32( dst, dst_start );
    }
    if ( ( src_start + src_len ) > ( dst_start + dst_len ) )
    {
        uint32_t diff = ( src_start + src_len ) - ( dst_start + dst_len );
        state->data_size = dst_len + 4 + diff;
        state->data = dst = ( uint8_t * ) realloc( dst, state->data_size );
        memset( dst + 4 + dst_len, 0, diff );
    }

    memcpy( dst + 4 + ( src_start - dst_start ), exe + 4, src_len );

    return 0;
} 

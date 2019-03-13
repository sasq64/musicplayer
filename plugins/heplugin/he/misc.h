
#include <psf/psflib.h>
#include "psf2fs.h"
#include "bios.h"
#include "psx.h"
#include "iop.h"
#include "spu.h"
#include "mkhebios.h"
#include "r3000.h"

#ifdef _MSC_VER
#define strcasecmp _stricmp
#define strncasecmp _strnicmp
#endif

#include <coreutils/utils.h>
#include <coreutils/file.h>
#include <coreutils/log.h>

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

struct psf1_load_state
{
	void * emu;
	void * psf2fs;
	bool first;
	unsigned refresh;
	int version;
	
};

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


struct psf_info_meta_state
{
	
	void * info;

	void * name;
	
	bool utf8;

	int tag_song_ms;
	int tag_fade_ms;

	psf_info_meta_state()
		: info( 0 ), utf8( false ), tag_song_ms( 0 ), tag_fade_ms( 0 )
	{
	}
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

static int EMU_CALL virtual_readfile(void *context, const char *path, int offset, char *buffer, int length)
{
        //fprintf(stderr, "V READFILE %s %d %d\n", path, offset, length);
    return psf2fs_virtual_readfile(context, path, offset, buffer, length);
} 

static void * psf_file_fopen( const char * uri )
{
	FILE *f;

        //fprintf(stderr, "PSF OPEN %s\n", uri);
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

int psf1_info(void * context, const char * name, const char * value)
{
    psf1_load_state * state = ( psf1_load_state * ) context;

    if ( !state->refresh && !strcasecmp( name, "_refresh" ) )
    {
        char * moo;
        state->refresh = strtoul( value, &moo, 10 );
    }

    return 0;
} 

int psf1_load(void * context, const uint8_t * exe, size_t exe_size,
                                  const uint8_t * reserved, size_t reserved_size)
{
    psf1_load_state * state = ( psf1_load_state * ) context;

    psxexe_hdr_t *psx = (psxexe_hdr_t *) exe;

    if ( exe_size < 0x800 ) return -1;

    uint32_t addr = get_le32( &psx->exec.t_addr );
    uint32_t size = exe_size - 0x800;

    addr &= 0x1fffff;
    if ( ( addr < 0x10000 ) || ( size > 0x1f0000 ) || ( addr + size > 0x200000 ) ) return -1;

    void * pIOP = psx_get_iop_state( state->emu );
    iop_upload_to_ram( pIOP, addr, exe + 0x800, size );

    if ( !state->refresh )
    {
        if (!strncasecmp((const char *) exe + 113, "Japan", 5)) state->refresh = 60;
        else if (!strncasecmp((const char *) exe + 113, "Europe", 6)) state->refresh = 50;
        else if (!strncasecmp((const char *) exe + 113, "North America", 13)) state->refresh = 60;
    }

    if ( state->first )
    {
        void * pR3000 = iop_get_r3000_state( pIOP );
        r3000_setreg(pR3000, R3000_REG_PC, get_le32( &psx->exec.pc0 ) );
        r3000_setreg(pR3000, R3000_REG_GEN+29, get_le32( &psx->exec.s_ptr ) );
        state->first = false;
    }

    return 0;
}

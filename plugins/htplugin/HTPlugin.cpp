
#include "HTPlugin.h"

#include "ht/misc.h"

#include <psf/PSFFile.h>
#include "../../chipplayer.h"

#include <coreutils/utils.h>
#include <set>
#include <unordered_map>

using namespace std;

namespace musix {

class HTPlayer : public ChipPlayer {
public:

	HTPlayer(const std::string &fileName) {



		PSFFile psf { fileName };
		if(psf.valid()) {
			auto &tags = psf.tags();

			auto lib = tags["_lib"];

			int seconds = psf.songLength();

			setMeta("composer", tags["artist"],
				"sub_title", tags["title"],
				"game", tags["game"],
//				"format", "Dreamcast",
				"length", seconds
			);
		}

		int version;
	    	
		sdsf_loader_state lstate;
		memset( &lstate, 0, sizeof(lstate) ); 

		sdsf_loader_state *sdsfinfo = (sdsf_loader_state*)malloc(sizeof(sdsf_loader_state));

		int init_result = sega_init();
		
		//const char *filename = env->GetStringUTFChars(fname, NULL);
		
		char temp[1024];
		strcpy(temp, fileName.c_str());
		
		version = psf_load(temp, &psf_file_system,0,0,0,0,0,0);

		int load_result = psf_load( temp, &psf_file_system, version, sdsf_loader, &lstate, 0, 0, 0 );
		if (load_result < 0)
		{
			throw player_exception();
		}

		void * sega_state = malloc( sega_get_state_size( version - 0x10 ) ); 

		sega_clear_state( sega_state, version - 0x10);

	    sega_enable_dry( sega_state, 1 );
	    sega_enable_dsp( sega_state, 1 );
		
		int dynarec = 1;
		
		sega_enable_dsp_dynarec( sega_state, 1 );
		
		void *yam = 0;
	    if ( dynarec )
	    {
			
	        if ( version == 0x12 )
	        {
	            void * dcsound = sega_get_dcsound_state( sega_state );
	            yam = dcsound_get_yam_state( dcsound );
	        }
	        else
	        {
	            void * satsound = sega_get_satsound_state( sega_state );
	            yam = satsound_get_yam_state( satsound );
	        }
	        if ( yam ) yam_prepare_dynacode( yam );
	    }

	    uint32_t start  = *(uint32_t*) lstate.data;
	    uint32_t length = lstate.data_size;
	    const uint32_t max_length = ( version == 0x12 ) ? 0x800000 : 0x80000;
	    if ( ( start + ( length - 4 ) ) > max_length )
		{
	        length = max_length - start + 4;
	    }
	    	
		sega_upload_program( sega_state, lstate.data, length );
		free( lstate.data);
		
		sdsfinfo->emu = sega_state;
		sdsfinfo->yam = yam;
		sdsfinfo->version = version;

		this->state = sdsfinfo;
	}

	~HTPlayer() {
		if ( state->yam != 0 )
		{
			yam_unprepare_dynacode( state->yam );
		} 
		
		free(state->emu);
	}

	virtual int getSamples(int16_t *target, int noSamples) override {

		
		int ret = 0;			
		
		uint32_t samples_cnt = noSamples / 2; // samples_cnt in frames, 1 frame == 2 samples == 4 bytes
		
		ret = sega_execute( (void*)state->emu, 0x7fffffff, target, &samples_cnt ); 		
				
		if (samples_cnt < (noSamples / 2))
		{
			noSamples = samples_cnt * 2;
		}
			
		return noSamples;
	}

private:
	sdsf_loader_state *state;
};


static const set<string> supported_ext { "ssf", "dsf", "minissf" , "minidsf" };

bool HTPlugin::canHandle(const std::string &name) {
	auto ext = utils::path_extension(name);
	return supported_ext.count(utils::path_extension(name)) > 0;
}

ChipPlayer *HTPlugin::fromFile(const std::string &fileName) {
	try {
		return new HTPlayer { fileName };
	} catch(player_exception &e) {
		return nullptr;
	}
};

}

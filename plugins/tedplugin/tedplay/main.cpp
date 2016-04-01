#ifdef _WIN32
#include <SDL/SDL.h>
#else
#include <SDL2/SDL.h>
#endif
#include <iostream>
#include "AudioSDL.h"
#include "psid.h"
#include "Tedmem.h"
#include "tedplay.h"

using namespace std;

static AudioSDL *player;

static void loop()
{
	char c;
	int quit = 0;

	do {
		SDL_Delay(50);
		c = getchar();
		switch (c) {
			default:
				if (isalpha(c)) {
					cerr << "Unknown command!" << endl;
					cerr << "Valid commands are:" << endl;
				} else
					break;
			case 'h':
			case '?':
				cerr << "1\t toggle channel 1" << endl;
				cerr << "2\t toggle channel 2" << endl;
				cerr << "3\t toggle channel 3" << endl;
				cerr << "b\t skip back one track" << endl;
				cerr << "f\t skip forward one track" << endl;
				cerr << "h or ?\t this help" << endl;
				cerr << "i\t print info" << endl;
				cerr << "p\t toggle pause/resume" << endl;
				cerr << "q or x\t quit tedplay" << endl;
				break;

			case '1':
			case '2':
			case '3':
				tedPlayChannelEnable(c - '1', !tedPlayIsChannelEnabled(c - '1'));
				cerr << "Channel " << int(c - '0') << (tedPlayIsChannelEnabled(c - '0') ? " enabled." : " muted.") << endl;
				break;
			case 'b':
				psidChangeTrack(-1);
				cout << "Playing track #" << int(getPsidHeader().current) << endl;
				break;
			case 'f':
				psidChangeTrack(+1);
				cout << "Playing track #" << int(getPsidHeader().current) << endl;
				break;
			case 'i':
				printPsidInfo(getPsidHeader());
				if (!player->isPaused())
					cerr << "Playing track #" << int(getPsidHeader().current) << endl;
				break;
			case 'p':
				if (!player->isPaused()) {
					player->pause();
					cerr << "Player suspended." << endl;
				} else {
					player->play();
					cerr << "Player resumed." << endl;
				}
				break;
			case 's':
				break;
			case 'x':
			case 'q':
				cerr << "Exiting." << endl;
				quit = 1;
				break;
		}
	} while(!quit && c != EOF);
}

static void printUsage()
{
    cout << "tedplay - a (mostly) Commodore 264 family media player" << endl;
    cout << "Copyright 2012,2015 Attila Grosz" << endl;
    cout << "Usage:" << endl;
    cout << "tedplay filename" << endl;
}

int main(int argc, char *argv[])
{
    if (argc < 2) {
        printUsage();
        return -1;
    }
	unsigned int defaultFreq = 48000;
	int retval = tedplayMain(argv[1],
		player = new AudioSDL((void *) machineInit(defaultFreq, 24), defaultFreq, 100));
	if (0 == retval) {
		printPsidInfo(getPsidHeader());
		loop();
		tedplayClose();
	}
    return retval;
}

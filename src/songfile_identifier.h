#ifndef SONG_FILE_IDENTIFIER_H
#define SONG_FILE_IDENTIFIER_H

#include "songinfo.h"
#include <string>

bool identify_song(SongInfo& info, std::string ext = "");

#endif // SONG_FILE_IDENTIFIER_H

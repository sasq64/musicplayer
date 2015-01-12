#ifndef VICE_PLAYER_H
#define VICE_PLAYER_H

#include "../../chipplugin.h"

#include <string>
#include <vector>

namespace chipmachine {

class VicePlugin : public ChipPlugin {
public:
	virtual std::string name() const override { return "VicePlugin"; }
	VicePlugin(const std::string &dataDir);
	VicePlugin(const unsigned char *data);
	virtual ~VicePlugin();
	virtual bool canHandle(const std::string &name) override;
	virtual ChipPlayer *fromFile(const std::string &fileName) override;

	static void readLengths();
	static void readSTIL();
	static std::vector<uint16_t> findLengths(uint32_t key);

//private:
	static std::vector<uint8_t> mainHash;
	static std::vector<uint16_t> extraLengths;	

	struct STIL {
		int subsong;
		int seconds;
		std::string title;
		std::string name;
		std::string artist;
		std::string author;
		std::string comment;
	};

	struct STILSong {
		STILSong() {}
		STILSong(const std::vector<STIL> songs, const std::string &c) : songs(songs), comment(c) {}
		std::vector<STIL> songs;
		std::string comment;
	};

	static std::unordered_map<std::string, STILSong> stilSongs;

};

}

#endif // VICE_PLAYER_H
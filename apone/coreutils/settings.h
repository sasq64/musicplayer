#pragma once

#include "var.h"
#include "log.h"
#include <unordered_map>
namespace utils {

class Settings {
public:
	Settings() {}
	Settings(Settings && s) : variables(std::move(s.variables)) {}

	template <typename T> void set(const std::string &val, const T& t) {
		LOGV("Setting %s", val);
		variables[val] = t;
	}

	template <typename T> T get(const std::string &val, const T& def) {
		LOGV("Getting %s", val);
		if(!variables[val].defined())
			return def;
		return variables[val];
	}

	static Settings& getGroup(const std::string &name) {
		static std::unordered_map<std::string, Settings> groups;
		return groups[name];
	}

	static Settings& getDefault() {
		static Settings settings;
		return settings;
	}
private:
	std::unordered_map<std::string, var> variables;

};

} // namespace

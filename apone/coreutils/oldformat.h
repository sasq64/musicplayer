#ifndef COREUTILS_FORMAT_H
#define COREUTILS_FORMAT_H

#include <stdint.h>
#include <stdlib.h>
#include <cstdio>
#include <string>
#include <sstream>
#include <iostream>
#include <vector>

namespace utils {

char parse_format(std::stringstream &ss, std::string &fmt);

template <class T> void format_stream(std::stringstream &ss, std::string &fmt, const T *arg) {
	if(parse_format(ss, fmt))
		ss << arg;
}

template<template <typename, typename> class Container, class V, class A> void format_stream(std::stringstream &ss, std::string &fmt, Container<V, A> const& arg) {
	if(parse_format(ss, fmt)) {
		bool first = true;
		int w = (int)ss.width();
		for(auto b : arg) {
			if(!first) ss << ss.fill();
			ss.width(w);
			ss << b;
			first = false;
		}
	}
}

template<template <typename, typename> class Container, class A> void format_stream(std::stringstream &ss, std::string &fmt, Container<char, A> const& arg) {
	char letter;
	if((letter = parse_format(ss, fmt))) {
		bool first = true;
		int w = (int)ss.width();
		for(auto b : arg) {
			if(!first) ss << ss.fill();
			ss.width(w);
			if(letter == 'd' || letter == 'x')
				ss << (int)(b&0xff);
			else {
				ss << b;
			}
			first = false;
		}
	}
}

template<template <typename, typename> class Container, class A> void format_stream(std::stringstream &ss, std::string &fmt, Container<unsigned char, A> const& arg) {
	char letter;
	if((letter = parse_format(ss, fmt))) {
		bool first = true;
		int w = (int)ss.width();
		for(auto b : arg) {
			if(!first) ss << ss.fill();
			ss.width(w);
			if(letter == 'd' || letter == 'x')
				ss << (int)(b&0xff);
			else {
				ss << b;
			}
			first = false;
		}
	}
}

template<template <typename, typename> class Container, class A> void format_stream(std::stringstream &ss, std::string &fmt, Container<signed char, A> const& arg) {
	char letter;
	if((letter = parse_format(ss, fmt))) {
		bool first = true;
		int w = (int)ss.width();
		for(auto b : arg) {
			if(!first) ss << ss.fill();
			ss.width(w);
			if(letter == 'd' || letter == 'x')
				ss << (int)(b&0xff);
			else {
				ss << b;
			}
			first = false;
		}
	}
}

void format_stream(std::stringstream &ss, std::string &fmt);
void format_stream(std::stringstream &ss, std::string &fmt, const char arg);
void format_stream(std::stringstream &ss, std::string &fmt, const unsigned char arg);
void format_stream(std::stringstream &ss, std::string &fmt, const signed char arg);


template <class T> void format_stream(std::stringstream &ss, std::string &fmt, const T& arg) {
	char letter;
	if((letter = parse_format(ss, fmt))) {
		ss << arg;
	}
}

template <class A, class... B>
void format_stream(std::stringstream &ss, std::string &fmt, const A &head, const B& ... tail)
{
	format_stream(ss, fmt, head);
	format_stream(ss, fmt, tail...);
}

std::string format(const std::string &fmt);

template <class... A> std::string format(const std::string &fmt, const A& ... args)
{
	std::string fcopy = fmt;
	std::stringstream ss;
	ss << std::boolalpha;
	format_stream(ss, fcopy, args...);
	ss << fcopy;
	return ss.str();
}

template <class... A> void print_fmt(const std::string &fmt, const A& ... args) {
	std::string fcopy = fmt;
	std::stringstream ss;
	ss << std::boolalpha;
	format_stream(ss, fcopy, args...);
	ss << fcopy;
	fputs(ss.str().c_str(), stdout);
}

void print_fmt(const std::string &fmt);

inline void format_stream(std::stringstream &ss, std::string &fmt, const char arg) {
	char letter;
	if((letter = parse_format(ss, fmt))) {
		if(letter == 'd' || letter == 'x')
			ss << (int)(arg&0xff);
		else {
			ss << arg;
		}
	}
}

inline void format_stream(std::stringstream &ss, std::string &fmt, const unsigned char arg) {
	char letter;
	if((letter = parse_format(ss, fmt))) {
		if(letter == 'd' || letter == 'x')
			ss << (int)(arg&0xff);
		else {
			ss << arg;
		}
	}
}

inline void format_stream(std::stringstream &ss, std::string &fmt, const signed char arg) {
	char letter;
	if((letter = parse_format(ss, fmt))) {
		if(letter == 'd' || letter == 'x')
			ss << (int)(arg&0xff);
		else {
			ss << arg;
		}
		}
}

inline void format_stream(std::stringstream &ss, std::string &fmt, const std::vector<int8_t> &bytes) {
	if(parse_format(ss, fmt)) {
		bool first = true;
		int w = ss.width();
		for(auto b : bytes) {
			if(!first) ss << " ";
			ss.width(w);
			ss << (b & 0xff);
			first = false;
		}
	}
}

inline void format_stream(std::stringstream &ss, std::string &fmt, const std::vector<uint8_t> &bytes) {
	if(parse_format(ss, fmt)) {
		bool first = true;
		int w = ss.width();
		for(auto b : bytes) {
			if(!first) ss << " ";
			ss.width(w);
			ss << (b & 0xff);
			first = false;
		}
	}
}

inline void format_stream(std::stringstream &ss, std::string &fmt) {
	printf("Why are we here '%s'\n", fmt.c_str());
	ss << fmt;
}

inline char parse_format(std::stringstream &ss, std::string &fmt) {

	size_t pos = 0;

	// Find next format string while replacing %% with %
	while(true) {
		pos = fmt.find_first_of('%', pos);
		if(pos != std::string::npos && pos < fmt.length()-1) {
			if(fmt[pos+1] == '%') {
				fmt.replace(pos, 2, "%");
				pos++;
			} else
				break;
		} else
			return 0;
	}

	// Put everything before the format string on the stream
	ss << fmt.substr(0, pos);

	char *end = &fmt[fmt.length()];
	char *ptr = &fmt[pos+1];

	if(ptr >= end)
		return 0;
	ss.fill(' ');
	switch(*ptr++) {
	case '0':
		ss.fill('0');
		break;
	case ' ':
		ss.fill(' ');
		break;
	case ',':
		ss.fill(',');
		break;
	case '>':
		ss.fill('\t');
		break;
	case '-':
		ss << std::left;
		break;
	default:
		ptr--;
		break;
	}

	if(ptr >= end)
		return 0;

	char *endPtr;
	int width = strtol(ptr, &endPtr, 10);

	if(endPtr != nullptr && endPtr > ptr) {
		ss.width(width);
		ptr = endPtr;
	}

	if(ptr >= end)
		return 0;

	char letter = *ptr++;
	if(letter == 'x')
		ss << std::hex;
	else
		ss << std::dec;

	// Set the format string to the remainder of the string
	fmt = ptr;

	return letter;
}

inline void print_fmt(const std::string &ss) {
	fputs(ss.c_str(), stdout);
}



inline std::string format(const std::string &fmt) {
	std::string fcopy = fmt;
	return fcopy;
}



}

#endif // COREUTILS_FORMAT_H

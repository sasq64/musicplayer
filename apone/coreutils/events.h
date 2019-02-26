#ifndef COREUTILS_EVENTS_H
#define COREUTILS_EVENTS_H

#include <deque>

template <typename T> std::deque<T>& getEventList() {
	static std::deque<T> events;
	return events;
}

template <typename T> bool hasEvents() { 
	return getEventList<T>().size() > 0;
}

template <typename T> void putEvent(const T &t) {
	auto &eventList = getEventList<T>();
	eventList.push_back(t);
}

template <typename T> T getEvent() {
	auto &eventList = getEventList<T>();
	const T t = eventList.front();
	eventList.pop_front();
	return t;
}


#endif // COREUTILS_EVENTS_H

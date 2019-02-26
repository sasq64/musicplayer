#ifndef VAR_H
#define VAR_H

#include <string>
#include <exception>
#include <functional>
#include <memory>
#include <cstring>

namespace utils {

class var_not_set_exception : public std::exception {
public:
	virtual const char *what() const throw() { return "Variable is not set"; }
};

class illegal_conversion_exception : public std::exception {
public:
	virtual const char *what() const throw() { return "Illegal conversion"; }
};

class Holder {
public:
	virtual ~Holder() = default;
	virtual const std::type_info& getType() = 0;
	virtual void *getValue() = 0;
	//virtual void *getValue(int index) = 0;
};

template <class T> class VHolder : public Holder {
public:
	VHolder(const T &t) : value(t) {}

	virtual const std::type_info &getType() {
		return typeid(value);
	}

	virtual void *getValue() {
		return (void*)&value;
	}

	//virtual void *getValue(int index) {		
	//	return (void*)&value[index];
	//}

private:
	T value;
};

template <> class VHolder<const char *> : public Holder {
public:
	VHolder(const char *t) : value(t) {
	}

	virtual const std::type_info &getType() {
		return typeid(value);
	}

	virtual void *getValue() {
		return (void*)&value;
	}

	//virtual void *getValue(int index) {		
	//	return (void*)&value[index];
	//}

private:
	std::string value;
};


class var {
public:

	var() : holder(nullptr) {
	}

	var(var&& other) : holder { std::move(other.holder) } {
	}

	template <typename T> var& operator=(T t) {
		holder = std::unique_ptr<Holder>(new VHolder<T>(t));
		return *this;
	}

	template <typename T> operator T&() {
		if(!holder)
			throw var_not_set_exception();
		if(holder->getType() == typeid(T)) {
			T &t = *((T*)holder->getValue());
			return t;
		}
		throw illegal_conversion_exception();
	}

	bool defined() const { return holder != nullptr; }

	//template <typename S> const S& operator [](const int &index) {
	//	S &s = *((S*)holder->getValue(index));
	//	return s;
	//}

	operator int() {
		if(!holder)
			throw var_not_set_exception();
		if(holder->getType() == typeid(int)) {
			return *((int*)holder->getValue());
		} else if(holder->getType() == typeid(std::string)) {
			const std::string &s = *((std::string*)holder->getValue());
			return stol(s);
		}
		throw illegal_conversion_exception();
	}

	operator std::string() {
		if(!holder)
			throw var_not_set_exception();
		if(holder->getType() == typeid(std::string)) {
			return *((std::string*)holder->getValue());
		} else if(holder->getType() == typeid(int)) {
			int i = *((int*)holder->getValue());
			return std::to_string(i);
		}
		throw illegal_conversion_exception();	
	}

private:
	std::unique_ptr<Holder> holder;
};

}

#endif // VAR_H

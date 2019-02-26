```c++
string rstrip(const string &text, char c = ' ')
```
Remove trailing instances of the character *c* from the string *text*.

```c++
string lstrip(const string &text, char c = ' ')
```
Remove leading instances of the character *c* from the string *text*.

```c++
vector<string> text_wrap(const string &text, int width)
vector<string> text_wrap(const string &text, int width, int initialWidth)
```
Wrap `text` to fit a screen of `width` characters. if `initialWidth` is
specified, it gives the width of the *first* line of every paragraph.

```c++
string urlencode(const string &url, const string &chars)
```


```c++
string urldecode(const string &url, const string &chars)
```


```c++
void sleepms(uint ms)
```


```c++
uint64_t getms()
```


```c++
bool isalpha(const string &s)
```


```c++
float clamp(float x, float a0, float a1)
```


```c++
void makedir(const string &name)
```


```c++
void makedirs(const string &path)
```


```c++
bool endsWith(const string &name, const string &ext)
```


```c++
bool startsWith(const string &name, const string &pref)
```


```c++
void makeLower(string &s)
```


```c++
string toLower(const string &s)
```


```c++
string path_basename(const string &name)
```


```c++
string path_directory(const string &name)
```


```c++
string path_filename(const string &name)
```


```c++
string path_extension(const string &name)
```


```c++
string path_suffix(const string &name)
```


```c++
string path_prefix(const string &name)
```


```c++
wstring utf8_decode(const string &
```


```c++
string utf8_encode(const string &s)
```


```c++
string utf8_encode(const wstring &s)
```


```c++
string current_exe_path()
```


```c++
void schedule_callback(function<void()> f)
```


```c++
void perform_callbacks()
```




### File

A class for manipulating files. Somewhat inspired by javas *File* class, except it also does reading and writing.

```c++
File f { "myfile.txt" };
for(const auto &line : f.getLines()) {
}
f.close();
```

```c++
uint64_t userid = 0x123456789abcdef;
File f { "userid.dat" };
if(f.exists())
	userid = f.read<uint64_t>();
else
	f.write(userid);
f.close();
```

```c++
for(const auto &f : root.listFiles()) {
	auto name = f.getName();
	if(path_extension(name) == "txt") {
	}
}
```

### Format


Variadic template version of printf, inspired by javas *format()* function.

### Log

```c++
#include <coreutils/log.h>
LOGD("User %s logged in" , userName);
```
	
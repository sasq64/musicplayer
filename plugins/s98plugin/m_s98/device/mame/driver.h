#pragma once

#ifndef __DRIVER_H__
#define __DRIVER_H__

namespace mame {

#define HAS_YM3812 1
#define HAS_YM3526 0
#define HAS_Y8950  0
#define HAS_YMF262 1

#define INLINE static

#define logerror(x,y,z)
typedef signed int stream_sample_t;

} // namespace

#endif	/* __DRIVER_H__ */

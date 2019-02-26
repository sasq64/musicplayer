cmake_minimum_required(VERSION 2.8.4)
project(cpp-mods.coreutils)

include_guard(GLOBAL)

add_subdirectory(fmt/fmt)

set(SOURCE_FILES file.cpp format.cpp log.cpp utils.cpp)

FILE(GLOB_RECURSE IncFiles "*.h")
add_custom_target(utilsincfiles SOURCES ${IncFiles})

if(APPLE)
	add_definitions(-DAPPLE)
endif()

if(UNIX)
	add_definitions(-DUNIX)
endif()

add_library(coreutils ${SOURCE_FILES})
target_link_libraries(coreutils PRIVATE fmt)
target_include_directories(coreutils INTERFACE ${CMAKE_CURRENT_SOURCE_DIR}/../)
set_property(TARGET coreutils PROPERTY POSITION_INDEPENDENT_CODE ON)

# add_executable(testing path.t.cpp)
# set_property(TARGET testing PROPERTY CXX_STANDARD 17)
# set_property(TARGET testing PROPERTY CXX_STANDARD_REQUIRED ON)
# target_link_libraries(testing coreutils pthread)
# target_include_directories(testing PRIVATE ../mods ..)



set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR arm)

# set toolchain path
# to get the path for the sysroot use arm-none-linux-gnueabihf-gcc-print-sysroot
set(sysroot_target /usr/local/arago-x86_64/sysroots/armv7at2hf-neon-linux-gnueabi) # ! this is temp
set(tools /usr/bin/)
set(CMAKE_C_COMPILER ${tools}arm-none-linux-gnueabihf-gcc)
set(CMAKE_CXX_COMPILER ${tools}arm-none-linux-gnueabihf-g++)

# set(CMAKE_BUILD_TYPE Debug) ## added

# is optional, and may be specified if a sysroot is available.
set(CMAKE_SYSROOT ${sysroot_target})

# SET(CMAKE_CXX_FLAGS " -mcpu=cortex-a72+crc+crypto -Og -pipe -g --sysroot=${sysroot_target}")
set(GCCFLAGS
    -c
    -g
    -O
    #-fno-pie
    #-ggdb
    #-pedantic
    #-Wall
    #-Wextra
    #--sysroot=${sysroot_target}
)

set(_CXXFLAGS ${GCCFLAGS}
    #-x c++
    -std=c++17
    -fno-rtti
    #-fno-exceptions
    #-Weffc++
    # suppress warning
    #-Wno-non-virtual-dtor
)
string(REPLACE ";" " " CXXFLAGS "${_CXXFLAGS}")

# need to add these flags to the set(CXXFLAGS)
#SET(CMAKE_CXX_FLAGS "${CXXFLAGS}" CACHE STRING "" FORCE)
SET(CMAKE_CXX_FLAGS "-g -Wall -ggdb -fno-rtti -fno-exceptions -pedantic -Weffc++ --sysroot=${sysroot_target} -Wno-non-virtual-dtor -Wextra -std=c++17 -fno-pie")
SET(CMAKE_C_FLAGS ${CMAKE_CXX_FLAGS})
SET(CMAKE_EXE_LINKER_FLAGS "--sysroot=${sysroot_target}")

# These lines are necessary to let cmake know to only look in the
# beaglebone for the libraries instead of looking in host pc.
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
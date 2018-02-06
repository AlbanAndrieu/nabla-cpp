#!/bin/bash
#set -xv

#rm CMakeCache.txt

#-DCMAKE_COLOR_MAKEFILE=0FF
#-DCMAKE_C_COMPILER=i686-pc-cygwin-gcc-3.4.4 -DCMAKE_CXX_COMPILER=i686-pc-cygwin-g++-3
#-DCMAKE_C_COMPILER=/usr/bin/clang -DCMAKE_CXX_COMPILER=/usr/bin/clang++
#-DCMAKE_INSTALL_PREFIX=/target/install/${ARCH}/debug
#-DECLIPSE_CDT4_GENERATE_SOURCE_PROJECT=TRUE

cmake -G"Eclipse CDT4 - Unix Makefiles" -DCMAKE_BUILD_TYPE=debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON ../microsoft

exit 0

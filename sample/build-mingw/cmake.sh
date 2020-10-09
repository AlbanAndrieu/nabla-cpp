#!/bin/bash
#set -xv

#rm CMakeCache.txt

#-DCMAKE_COLOR_MAKEFILE=0FF
#-DCMAKE_C_COMPILER=/usr/bin/clang -DCMAKE_CXX_COMPILER=/usr/bin/clang++
#-DCMAKE_C_COMPILER=i686-w64-mingw32-gcc -DCMAKE_CXX_COMPILER=i686-w64-mingw32-g++

#['CC'] = 'i686-w64-mingw32-gcc'
#['CXX'] = 'i686-w64-mingw32-g++'
#['RANLIB'] = 'i686-w64-mingw32-ranlib'
#['LD'] = 'i686-w64-mingw32-ld'
#['LINK'] = 'i686-w64-mingw32-g++'
#['AR'] = 'i686-w64-mingw32-ar'
#['AS'] = 'i686-w64-mingw32-as'

#-DCMAKE_INSTALL_PREFIX=/target/install/${ARCH}/debug
#-DECLIPSE_CDT4_GENERATE_SOURCE_PROJECT=TRUE

#MSYS Makefiles
cmake -G"MinGW Makefiles" -DCMAKE_BUILD_TYPE=debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_C_COMPILER=/mingw64/bin/gcc -DCMAKE_CXX_COMPILER=/mingw64/bin/g++ ../microsoft
#cmake -G"Eclipse CDT4 - Ninja " -DCMAKE_BUILD_TYPE=debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON ../microsoft

exit 0

#!/bin/bash
#set -xv

rm -Rf CMakeCache.txt CMakeFiles/

#-DCMAKE_COLOR_MAKEFILE=0FF
#-DCMAKE_C_COMPILER=i686-pc-cygwin-gcc-3.4.4 -DCMAKE_CXX_COMPILER=i686-pc-cygwin-g++-3
#-DCMAKE_C_COMPILER=/usr/bin/clang -DCMAKE_CXX_COMPILER=/usr/bin/clang++
#-DCMAKE_INSTALL_PREFIX=/target/install/${ARCH}/debug
#-DECLIPSE_CDT4_GENERATE_SOURCE_PROJECT=TRUE

echo "Using GCC"

echo cmake -G"Eclipse CDT4 - Unix Makefiles" -DCMAKE_BUILD_TYPE=debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON ../microsoft

echo "Using Clang"

#Eclipse CDT4 - Unix Makefiles
#Eclipse CDT4 - Ninja
#MSYS Makefiles
cmake -G"Eclipse CDT4 - Unix Makefiles" -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_C_COMPILER=/usr/bin/clang -DCMAKE_CXX_COMPILER=/usr/bin/clang++ -DCMAKE_CROSSCOMPILING=True --config Debug --target Continuous -j10 --graphviz=graphviz.dot "$@" -S ../microsoft -B ./
dot -Tpng graphviz.dot -o graphviz.png

echo "sudo make install"
echo "make tests"

echo "Using Ninja"

echo "rm -Rf CMakeCache.txt CMakeFiles/"
echo "CC='clang' CXX='clang++' cmake -G Ninja Multi-Config ../microsoft"
echo "ninja"

echo "objdump -d  /usr/local/bin/run_tests"

# See https://vector-of-bool.github.io/docs/vscode-cmake-tools/settings.html#conf-cmake-generator
# for .vscode/settings.json

# - tasks.json (compiler build settings)
# - launch.json (debugger settings)
# - c_cpp_properties.json (compiler path and IntelliSense settings)

# https://code.visualstudio.com/docs/cpp/cmake-linux

exit 0

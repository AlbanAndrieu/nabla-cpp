#!/bin/bash
#set -xv

WORKING_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}"  )" && pwd  )"

if [ -z "${WORKSPACE}" ]; then
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : WORKSPACE ${NC}"
  export WORKSPACE=${WORKING_DIR}/../..
fi

echo "WORKSPACE ${WORKSPACE}"

if [ -n "${ENABLE_CLANG}" ]; then
    echo -e "${green} ENABLE_CLANG is defined ${happy_smiley} ${NC}"
    #AddressSanitizer to sanitize your code!
    export ASAN_SYMBOLIZER_PATH=/usr/bin/llvm-symbolizer-10
    export ASAN_OPTIONS=alloc_dealloc_mismatch=0,symbolize=1
fi

if [ -z "${PROJECT_SRC}" ]; then
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : PROJECT_SRC ${NC}"
  export PROJECT_SRC=${WORKSPACE}
fi


# shellcheck source-path=SCRIPTDIR
# shellcheck disable=SC1090
source ${PROJECT_SRC}/scripts/step-2-0-0-build-env.sh || exit 1

# shellcheck source=/dev/null

echo -e "${cyan} ${double_arrow} Environment ${NC}"

rm -Rf CMakeCache.txt CMakeFiles/

if [ -n "${MODE_RELEASE}" ]; then
    echo -e "${green} MODE_RELEASE is defined ${happy_smiley} ${NC}"
    export CMAKE_INSTALL_PREFIX=/usr/local
else
    export CMAKE_INSTALL_PREFIX=${PROJECT_SRC}/install/debug
fi

#-DCMAKE_ECLIPSE_GENERATE_SOURCE_PROJECT=TRUE
#-DIWYU_LLVM_ROOT_PATH=/usr/lib/llvm-3.8

if [ "${ENABLE_NINJA}" == "true" ]; then
    echo -e "${magenta} cmake -G\"Ninja\" -DCMAKE_BUILD_TYPE=Debug ${PROJECT_SRC}/sample/microsoft ${NC}"
    export CMAKE_GENERATOR="Ninja"
fi

export CMAKE_GENERATOR=${CMAKE_GENERATOR:-"Eclipse CDT4 - Unix Makefiles"}

#-DCMAKE_COLOR_MAKEFILE=0FF
#-DCMAKE_INSTALL_PREFIX=/target/install/${ARCH}/debug
#-DECLIPSE_CDT4_GENERATE_SOURCE_PROJECT=TRUE

if [ "${ENABLE_CLANG}" == "true" ]; then
    #-DCMAKE_C_COMPILER=/usr/bin/clang -DCMAKE_CXX_COMPILER=/usr/bin/clang++
    echo -e "${magenta} cmake -G\"Eclipse CDT4 - Unix Makefiles\" -DCMAKE_BUILD_TYPE=debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -S ${PROJECT_SRC}/microsoft -B ./ ${NC}"
elif [ "${ENABLE_MINGW_64}" == "true" ]; then
    #-DCMAKE_C_COMPILER=i686-pc-cygwin-gcc-3.4.4 -DCMAKE_CXX_COMPILER=i686-pc-cygwin-g++-3
    #-DCMAKE_C_COMPILER=i686-w64-mingw32-gcc -DCMAKE_CXX_COMPILER=i686-w64-mingw32-g++
    #echo -e "${magenta} cmake -G\"Eclipse CDT4 - Unix Makefiles\" -DBUILD_SHARED_LIBS=OFF -DBUILD_CLAR=OFF -DTHREADSAFE=ON -DCMAKE_SYSTEM_NAME=Windows -DCMAKE_C_COMPILER=x86_64-w64-mingw32-gcc -DCMAKE_RC_COMPILER="$(which x86_64-w64-mingw32-windres)" -DDLLTOOL="$(which x86_64-w64-mingw32-dlltool)" -DCMAKE_FIND_ROOT_PATH=/usr/x86_64-w64-mingw32 -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY -S ../microsoft -B ./ ${NC}"
    echo -e "${magenta} cmake -DCMAKE_TOOLCHAIN_FILE=${PROJECT_SRC}/sample/Toolchain-cross-mingw32-linux.cmake -S ${PROJECT_SRC}/microsoft -B ./ ${NC}"

    #['CC'] = 'i686-w64-mingw32-gcc'
    #['CXX'] = 'i686-w64-mingw32-g++'
    #['RANLIB'] = 'i686-w64-mingw32-ranlib'
    #['LD'] = 'i686-w64-mingw32-ld'
    #['LINK'] = 'i686-w64-mingw32-g++'
    #['AR'] = 'i686-w64-mingw32-ar'
    #['AS'] = 'i686-w64-mingw32-as'
fi

#Eclipse CDT4 - Unix Makefiles
#Eclipse CDT4 - Ninja
#MSYS Makefiles
#-DCMAKE_CROSSCOMPILING=True
#-DENABLE_TESTING=true # for Dart
#-DCMAKE_CXX_INCLUDE_WHAT_YOU_USE="/usr/bin/iwyu"
#-D_ECLIPSE_VERSION=4.4
if [ "${ENABLE_MINGW_64}" == "true" ]; then
    echo -e "${magenta} cmake -G\"${CMAKE_GENERATOR}\" -DCMAKE_BUILD_TYPE=debug -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX} -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_TOOLCHAIN_FILE=${PROJECT_SRC}/sample/Toolchain-cross-mingw32-linux.cmake ${PROJECT_SRC}/sample/microsoft ${NC}"
    cmake -G"${CMAKE_GENERATOR}" -DCMAKE_BUILD_TYPE=debug -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX} -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_TOOLCHAIN_FILE=${PROJECT_SRC}/sample/Toolchain-cross-mingw32-linux.cmake --config Debug --target Continuous -j10 --graphviz=graphviz.dot "$@" -S ${PROJECT_SRC}/sample/microsoft -B ${PROJECT_SRC}/sample/build-${ARCH}
else
    echo -e "${magenta} ${CLANG_SCAN} cmake -G\"${CMAKE_GENERATOR}\" -DCMAKE_BUILD_TYPE=debug -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX} -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_C_COMPILER=${CC} -DCMAKE_CXX_COMPILER=${CXX} ${PROJECT_SRC}/sample/microsoft ${NC}"
    # TODO ${CLANG_SCAN}
    cmake -G"${CMAKE_GENERATOR}" -DCMAKE_BUILD_TYPE=debug -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX} -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_C_COMPILER=${CC} -DCMAKE_CXX_COMPILER=${CXX} --config Debug --target Continuous -j10 --graphviz=graphviz.dot "$@" -S ${PROJECT_SRC}/sample/microsoft -B ${PROJECT_SRC}/sample/build-${ARCH}
fi

cmake_res=$?
if [[ ${cmake_res} -ne 0 ]]; then
    echo -e "${red} ---> CMake failed : ${cmake_res} ${NC}"
    exit 1
fi

dot -Tpng graphviz.dot -o graphviz.png

echo -e "${magenta} NEXT : ${USE_SUDO} make install ${NC}"
echo -e "${magenta} cd ${PROJECT_SRC}/sample/build-${ARCH} ${NC}"
echo -e "${magenta} NEXT : make tests ${NC}"

if [ "${ENABLE_NINJA}" == "true" ]; then
    echo -e "${magenta} Using Ninja ${NC}"
    echo -e "${magenta} rm -Rf CMakeCache.txt CMakeFiles/ ${NC}"
    echo -e "${magenta} CC='clang' CXX='clang++' cmake -G Ninja Multi-Config ../microsoft ${NC}"
    echo -e "${magenta} ninja ${NC}"
fi

echo -e "${magenta} NEXT : objdump -d  /usr/local/bin/run_tests ${NC}"

# See https://vector-of-bool.github.io/docs/vscode-cmake-tools/settings.html#conf-cmake-generator
# for .vscode/settings.json

# - tasks.json (compiler build settings)
# - launch.json (debugger settings)
# - c_cpp_properties.json (compiler path and IntelliSense settings)

# https://code.visualstudio.com/docs/cpp/cmake-linux

exit 0

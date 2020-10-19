#!/bin/bash
#set -xv

WORKING_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}"  )" && pwd  )"

if [ -z "$WORKSPACE" ]; then
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : WORKSPACE ${NC}"
  export WORKSPACE=${WORKING_DIR}/../..
fi

echo "WORKSPACE ${WORKSPACE}"

source ${PROJECT_SRC}/scripts/step-2-0-0-build-env.sh || exit 1

echo -e "${cyan} ${double_arrow} Environment ${NC}"

rm -Rf CMakeCache.txt CMakeFiles/

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
export ENABLE_MINGW_64=true

#MSYS Makefiles
if [ "${ENABLE_MINGW_64}" == "true" ]; then
    cmake -G"Eclipse CDT4 - Unix Makefiles" -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_TOOLCHAIN_FILE=../Toolchain-cross-mingw32-linux.cmake --config Debug --target Continuous -j10 --graphviz=graphviz.dot "$@" -S ../microsoft -B ./
else
    cmake -G"Eclipse CDT4 - Unix Makefiles" -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_C_COMPILER=${CC} -DCMAKE_CXX_COMPILER=${CXX} --config Debug --target Continuous -j10 --graphviz=graphviz.dot "$@" -S ../microsoft -B ./
fi
dot -Tpng graphviz.dot -o graphviz.png

exit 0

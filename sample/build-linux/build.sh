#!/bin/bash
#set -xv

red='\e[0;31m'
green='\e[0;32m'
NC='\e[0m' # No Color

export PATH=/usr/lib/dart/bin:$PATH

echo "WORKSPACE ${WORKSPACE}"

#In Hudson
#Extract trunk/cpp in Google Code (automatic configuration)
#Batch Windows command : %WORKSPACE%\sample\build-cygwin\cmake.bat
#export PROJECT_SRC=${WORKSPACE}
#export PROJECT_TARGET_PATH=/target

export PROJECT_TARGET_PATH=${WORKSPACE}/target

echo "PROJECT_SRC : $PROJECT_SRC - PROJECT_TARGET_PATH : $PROJECT_TARGET_PATH"

cd $PROJECT_SRC/sample/build-${ARCH}

rm -f CMakeCache.txt
rm -f DartConfiguration.tcl

#cmake -G Ninja -DCMAKE_BUILD_TYPE=Debug ..

#-DCMAKE_C_COMPILER=i686-pc-cygwin-gcc-3.4.4 -DCMAKE_CXX_COMPILER=i686-pc-cygwin-g++-3
#-DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_C_COMPILER=/usr/bin/clang -DCMAKE_CXX_COMPILER=/usr/bin/clang++ 
#-DCMAKE_ECLIPSE_GENERATE_SOURCE_PROJECT=TRUE
#-DCMAKE_INSTALL_PREFIX=${PROJECT_TARGET_PATH}
cmake -G"Eclipse CDT4 - Unix Makefiles" -DCMAKE_BUILD_TYPE=debug -DCMAKE_INSTALL_PREFIX=$PROJECT_SRC/install/${MACHINE}/debug -DDART_ROOT=/usr/lib/dart/ ../microsoft
#-DCMAKE_INSTALL_PREFIX=${PROJECT_TARGET_PATH}/install/${MACHINE}/debug
#-DENABLE_TESTING=true

#http://clang.llvm.org/docs/HowToSetupToolingForLLVM.html
#clang-format -dump-config
#make check-all
#clang-tidy -dump-config

#PROCESSOR=`uname -m`
PROCESSOR="x86-32"

/workspace/build-wrapper-linux-x86/build-wrapper-linux-${PROCESSOR} --out-dir ${WORKSPACE}/bw-outputs make -B clean install test DoxygenDoc package
#~/build-wrapper-linux-x86/build-wrapper-linux-${PROCESSOR} --out-dir ${WORKSPACE}/bw-outputs make -B clean install DoxygenDoc

ctest -N
 
#ctest -D Experimental
#cd ${WORKSPACE}/sample/build-linux/src/test/cpp
#ctest .. -R circular_queueTest
#cd src/test/app/
ctest --force-new-ctest-process --no-compress-output -T Test -O Test.xml || /bin/true

#ctest -j4 -DCTEST_MEMORYCHECK_COMMAND="/usr/bin/valgrind" -DMemoryCheckCommand="/usr/bin/valgrind" --output-on-failure -T memcheck
#ctest -T memcheck

cd $PROJECT_SRC/sample/build-${ARCH}
make package

make tests

#make Experimental

#http://clang-analyzer.llvm.org/installation.html
#http://clang-analyzer.llvm.org/scan-build.html
#scan-build make
#scan-view

#Objective C
#xcodebuild | xcpretty
#scan-build xcodebuild

#sudo -k checkinstall \
#--install=no  
#--pkgsource="https://github.com/AlbanAndrieu/nabla-cpp" \
#--pkglicense="GPL2" \
#--deldesc=no \
#--pkgrelease="SNAPSHOT" \
#--maintainer="Alban Andrieu \\<alban.andrieu@free.fr\\>" \
#--requires="libc6 \(\>= 2.4\),libgcc1 \(\>= 1:4.1.1\),libncurses5 \(\>= 5.5-5~\),libstdc++6 \(\>= 4.1.1\),libboost-thread-dev,libboost-date-time-dev,libboost-system-dev" \
#--pkgname=nabla-microsoft --pkggroup=nabla --pkgversion=1.0.0
#
##sudo dpkg -r nabla-microsoft

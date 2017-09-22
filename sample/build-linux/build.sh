#!/bin/bash
#set -xv

bold="\033[01m"
underline="\033[04m"
blink="\033[05m"

black="\033[30m"
red="\033[31m"
green="\033[32m"
yellow="\033[33m"
blue="\033[34m"
magenta="\033[35m"
cyan="\033[36m"
ltgray="\033[37m"

NC="\033[0m"

#double_arrow='\u00BB'
double_arrow='\xC2\xBB'
#head_skull='\u2620'
head_skull='\xE2\x98\xA0'
#happy_smiley='\u263A'
happy_smiley='\xE2\x98\xBA'
nabla_logo='\xE2\x88\x87'

echo "WORKSPACE ${WORKSPACE}"

#In Hudson
#Extract trunk/cpp in Google Code (automatic configuration)
#Batch Windows command : %WORKSPACE%\sample\build-cygwin\cmake.bat
#export PROJECT_SRC=${WORKSPACE}
#export PROJECT_TARGET_PATH=/target

export PROJECT_TARGET_PATH=${WORKSPACE}/target

echo "PROJECT_SRC : $PROJECT_SRC - PROJECT_TARGET_PATH : $PROJECT_TARGET_PATH"

../../clean.sh

cd $PROJECT_SRC/sample/build-${ARCH}

rm -f CMakeCache.txt
#rm -f DartConfiguration.tcl

echo -e "${green} CMake ${NC}"

#cmake -G Ninja -DCMAKE_BUILD_TYPE=Debug ..

#-DCMAKE_C_COMPILER=i686-pc-cygwin-gcc-3.4.4 -DCMAKE_CXX_COMPILER=i686-pc-cygwin-g++-3
#-DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_C_COMPILER=/usr/bin/clang -DCMAKE_CXX_COMPILER=/usr/bin/clang++ 
#-DCMAKE_ECLIPSE_GENERATE_SOURCE_PROJECT=TRUE
#-DCMAKE_INSTALL_PREFIX=${PROJECT_TARGET_PATH}
cmake -G"Eclipse CDT4 - Unix Makefiles" -DCMAKE_BUILD_TYPE=debug -DCMAKE_INSTALL_PREFIX=$PROJECT_SRC/install/${MACHINE}/debug ../microsoft
#-DCMAKE_INSTALL_PREFIX=${PROJECT_TARGET_PATH}/install/${MACHINE}/debug
#-DENABLE_TESTING=true

#http://clang.llvm.org/docs/HowToSetupToolingForLLVM.html
#clang-format -dump-config
#make check-all
#clang-tidy -dump-config

echo -e "${green} Building : CMake ${NC}"

#PROCESSOR=`uname -m`
PROCESSOR="x86-32"

/workspace/build-wrapper-linux-x86/build-wrapper-linux-${PROCESSOR} --out-dir ${WORKSPACE}/bw-outputs make -B clean install test DoxygenDoc package
#~/build-wrapper-linux-x86/build-wrapper-linux-${PROCESSOR} --out-dir ${WORKSPACE}/bw-outputs make -B clean install DoxygenDoc

echo -e "${green} Testing : CTest ${NC}"

ctest -N
 
#ctest -D Experimental
#cd ${WORKSPACE}/sample/build-linux/src/test/cpp
#ctest .. -R circular_queueTest
#cd src/test/app/
#ctest -V -C Debug
ctest --force-new-ctest-process --no-compress-output -T Test -O Test.xml || /bin/true

#ctest -j4 -DCTEST_MEMORYCHECK_COMMAND="/usr/bin/valgrind" -DMemoryCheckCommand="/usr/bin/valgrind" --output-on-failure -T memcheck
#ctest -T memcheck

#make tests

make Experimental

echo -e "${green} Packaging : checkinstall ${NC}"

cd $PROJECT_SRC/sample/build-${ARCH}
make package

if [ `uname -s` == "Linux" ]; then
	checkinstall --version
	
	sudo dpkg -r nabla-microsoft || true
	
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
fi

echo -e "${green} Reporting : Junit ${NC}"

if [ `uname -s` == "Linux" ]; then
	xsltproc CTest2JUnit.xsl Testing/`head -n 1 < Testing/TAG`/Test.xml > JUnitTestResults.xml
fi

#http://clang-analyzer.llvm.org/installation.html
#http://clang-analyzer.llvm.org/scan-build.html
#scan-build make
#scan-view

#Objective C
#xcodebuild | xcpretty
#scan-build xcodebuild

echo "http://192.168.0.28/cdash/user.php"
echo "http://maven.nabla.mobi/cpp/microsoft/index.html"

exit 0

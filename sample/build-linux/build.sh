#!/bin/bash
#set -xv

cd ../../

./step-2-0-0-build-env.sh || exit 1

echo -e "${cyan} ${double_arrow} Environment ${NC}"

echo "WORKSPACE ${WORKSPACE}"

pwd

#See https://github.com/fffaraz/awesome-cpp#static-code-analysis

#In Hudson
#Extract trunk/cpp in Google Code (automatic configuration)
#Batch Windows command : %WORKSPACE%\sample\build-cygwin\cmake.bat
#export PROJECT_SRC=${WORKSPACE}
#export PROJECT_TARGET_PATH=/target

export PROJECT_TARGET_PATH=${WORKSPACE}/target
#export MAKE=make
export MAKE=colormake
export ASAN_SYMBOLIZER_PATH=/usr/bin/llvm-symbolizer-3.8
export ASAN_OPTIONS=alloc_dealloc_mismatch=0,symbolize=1
export ENABLE_MEMCHECK=true
export UNIT_TESTS=true
export CHECK_FORMATTING=true
export ENABLE_CLANG=true
export ENABLE_EXPERIMENTAL=true

echo "PROJECT_SRC : $PROJECT_SRC - PROJECT_TARGET_PATH : $PROJECT_TARGET_PATH"

./clean.sh

#cd $PROJECT_SRC/sample/microsoft

#wget https://cppan.org/client/cppan-master-Linux-client.deb
#sudo dpkg -i cppan-master-Linux-client.deb
#cppan

cd "$PROJECT_SRC/sample/build-${ARCH}"

rm -f CMakeCache.txt
rm -f compile_commands.json
#rm -f DartConfiguration.tcl

echo -e "${green} CMake ${NC}"

#cmake -G Ninja -DCMAKE_BUILD_TYPE=Debug ..

#-DCMAKE_C_COMPILER=i686-pc-cygwin-gcc-3.4.4 -DCMAKE_CXX_COMPILER=i686-pc-cygwin-g++-3
#-DCMAKE_ECLIPSE_GENERATE_SOURCE_PROJECT=TRUE
#-DCMAKE_INSTALL_PREFIX=${PROJECT_TARGET_PATH}
#-DIWYU_LLVM_ROOT_PATH=/usr/lib/llvm-3.8

if [[ "${ENABLE_CLANG}" == "true" ]]; then
    export CC="/usr/bin/clang"
    export CXX="/usr/bin/clang++"
else
    export CC="/usr/bin/gcc-6"
    export CXX="/usr/bin/g++-6"
fi

#-DCMAKE_CXX_INCLUDE_WHAT_YOU_USE="/usr/bin/iwyu"
cmake -G"Eclipse CDT4 - Unix Makefiles" -DCMAKE_BUILD_TYPE=debug -DCMAKE_INSTALL_PREFIX=$PROJECT_SRC/install/${MACHINE}/debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_C_COMPILER=${CC} -DCMAKE_CXX_COMPILER=${CXX} ../microsoft
#-DCMAKE_INSTALL_PREFIX=${PROJECT_TARGET_PATH}/install/${MACHINE}/debug
#-DENABLE_TESTING=true
cmake_res=$?
if [[ $cmake_res -ne 0 ]]; then
    echo -e "${red} ---> CMake failed : $cmake_res ${NC}"
    exit 1
fi

echo -e "${green} Clang format ${NC}"

#http://clang.llvm.org/docs/HowToSetupToolingForLLVM.html
#clang-format -dump-config
#${MAKE} check-all
#clang-tidy -dump-config

if [[ -f ../microsoft/compile_commands.json ]]; then
    rm ../microsoft/compile_commands.json
    ln -s $PWD/compile_commands.json ../microsoft/
fi

echo -e "${green} Building : CMake ${NC}"

${SONAR_CMD} ${MAKE} -B clean install test DoxygenDoc package
#~/build-wrapper-linux-x86/build-wrapper-linux-${PROCESSOR} --out-dir ${WORKSPACE}/bw-outputs ${MAKE} -B clean install DoxygenDoc
build_res=$?
if [[ $build_res -ne 0 ]]; then
    echo -e "${red} ---> Build failed : $build_res ${NC}"
    exit 1
fi

if [ `uname -s` == "Linux" ]; then
    echo -e "${green} Checking include : IWYU ${NC}"

    iwyu_tool.py -p .
fi

echo -e "${green} Testing : CTest ${NC}"

if [[ "${UNIT_TESTS}" == "true" ]]; then

    if [[ "${ENABLE_MEMCHECK}" == "true" ]]; then

      if [ `uname -s` == "Linux" ]; then
         echo -e "${green} Checking memory leak : CTest ${NC}"

         #ctest -T memcheck
         ctest --output-on-failure -j2 -N -D ExperimentalMemCheck
      fi

    else
      ctest --output-on-failure -j2
    fi

    #ctest -D Experimental
    #cd ${WORKSPACE}/sample/build-linux/src/test/cpp
    #ctest .. -R circular_queueTest
    #cd src/test/app/
    #ctest -V -C Debug
    ctest --force-new-ctest-process --no-compress-output -T Test -O Test.xml || /bin/true

    #ctest -j4 -DCTEST_MEMORYCHECK_COMMAND="/usr/bin/valgrind" -DMemoryCheckCommand="/usr/bin/valgrind" --output-on-failure -T memcheck

#${MAKE} tests
fi

if [ `uname -s` == "Linux" ]; then
    echo -e "${green} Fixing include : IWYU ${NC}"

    ${MAKE} clean
    ${MAKE} -k CXX=/usr/bin/iwyu  2> /tmp/iwyu.out
    fix_includes.py < /tmp/iwyu.out
fi

if [[ "${ENABLE_EXPERIMENTAL}" == "true" ]]; then

    echo -e "${green} Experimental : CMake ${NC}"

    ${MAKE} Experimental

fi

echo -e "${green} Packaging : CPack ${NC}"

#cmake --help-module CPackDeb
#cpack

cd $PROJECT_SRC/sample/build-${ARCH}
${MAKE} package
# To use this:
# ${MAKE} package
# sudo dpkg -i MICROSOFT-10.02-Linux.deb

if [ `uname -s` == "Linux" ]; then
    echo -e "${green} Packaging : checkinstall ${NC}"

    checkinstall --version

    #sudo dpkg -r nabla-microsoft || true

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

if [ `uname -s` == "Linux" ]; then
    echo -e "${green} Reporting : Junit ${NC}"

    xsltproc CTest2JUnit.xsl Testing/`head -n 1 < Testing/TAG`/Test.xml > JUnitTestResults.xml
fi

if [ `uname -s` == "Linux" ]; then
    echo -e "${green} Reporting : Clang analyzer ${NC}"

    #http://clang-analyzer.llvm.org/installation.html
    #http://clang-analyzer.llvm.org/scan-build.html
    scan-build make
    #scan-view
fi

echo -e "${green} Reporting : Coverage ${NC}"

find ../.. -name '*.gcda'

#xml
gcovr --branches --xml-pretty -r .
#html
gcovr --branches -r . --html --html-details -o gcovr-report.html

sudo perf record -g -- /usr/bin/git --version
sudo perf script | c++filt | gprof2dot -f perf | dot -Tpng -o output.png
#eog output.png

#Objective C
#xcodebuild | xcpretty
#scan-build xcodebuild

cmake --graphviz=test.dot .

if [[ "${CHECK_FORMATTING}" == "true" ]]; then

     cd ../../sample/microsoft
     ./cpplint.sh

     # Find non-ASCII characters in headers
     hpps=$(find ../.. -name \*\.h)
     cpps=$(find ../.. -name \*\.cpp)
     pcregrep --color='auto' -n "[\x80-\xFF]" ${hpps} ${cpps}
     if [[ $? -ne 1 ]]; then exit 1; fi
     # F001: Source files should not use the '\r' (CR) character
     # L001: No trailing whitespace at the end of lines
     # L002: Don't use tab characters
     find ../.. -name \*\.h | vera++ --rule F001 --rule L001 --rule L002 --error
fi

echo "http://192.168.0.28/cdash/user.php"
echo "http://maven.nabla.mobi/cpp/microsoft/index.html"

exit 0

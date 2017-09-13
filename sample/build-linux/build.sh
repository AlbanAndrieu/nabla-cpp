
echo "WORKSPACE ${WORKSPACE}"

#In Hudson
#Extract trunk/cpp in Google Code (automatic configuration)
#Batch Windows command : %WORKSPACE%\sample\build-cygwin\cmake.bat
#export PROJECT_SRC=${WORKSPACE}
#export PROJECT_TARGET_PATH=/target

echo "PROJECT_SRC : $PROJECT_SRC - PROJECT_TARGET_PATH : $PROJECT_TARGET_PATH"

cd $PROJECT_SRC/sample/build-${ARCH}

rm -f CMakeCache.txt

#-DCMAKE_C_COMPILER=i686-pc-cygwin-gcc-3.4.4 -DCMAKE_CXX_COMPILER=i686-pc-cygwin-g++-3
cmake -G"Eclipse CDT4 - Unix Makefiles" -DCMAKE_BUILD_TYPE=debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_C_COMPILER=/usr/bin/clang -DCMAKE_CXX_COMPILER=/usr/bin/clang++ -DCMAKE_ECLIPSE_GENERATE_SOURCE_PROJECT=TRUE -DCMAKE_INSTALL_PREFIX=${PROJECT_TARGET_PATH} ../microsoft
#-DCMAKE_INSTALL_PREFIX=${PROJECT_TARGET_PATH}/install/${MACHINE}/debug
#-DENABLE_TESTING=true

#http://clang.llvm.org/docs/HowToSetupToolingForLLVM.html
clang-format -dump-config
#make check-all
clang-tidy -dump-config

make -B clean install test DoxygenDoc package
#make test_all
#cd src
#ctest -D Experimental
#cd ~/cpp/sample/build-linux/src/test/cpp
#ctest .. -R circular_queueTest
cd src/test/cpp/
ctest --force-new-ctest-process --no-compress-output -T Test || /bin/true

#http://clang-analyzer.llvm.org/installation.html
#http://clang-analyzer.llvm.org/scan-build.html
#scan-build make
#scan-view

#Objective C
#xcodebuild | xcpretty
#scan-build xcodebuild

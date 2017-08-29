#!/bin/bash
#set -xv

red='\e[0;31m'
green='\e[0;32m'
NC='\e[0m' # No Color

./step-2-0-0-build-env.sh || exit 1

#TODO check https://en.wikipedia.org/wiki/List_of_tools_for_static_code_analysis
#sudo apt-get install clang flawfinder cppcheck ggcov gperf doxygen complexity findbugs
#rats

#TODO
#sudo nano /proc/sys/kernel/perf_event_paranoid
#-1

find . -name 'target' -type d | xargs rm -Rf
find . -name 'CMakeFiles' -type d | xargs rm -Rf
rm -Rf sample/build-linux/MICROSOFT-10.02-Linux*
rm -Rf sample/build-linux/Makefile
rm -Rf sample/build-linux/_CPack_Packages/
rm -Rf nabla-*
#rm -Rf nabla-*.tar.gz
#rm -Rf buildcache-*
#rm -Rf scons-signatures-*.dblite

#scons opt=True
~/build-wrapper-linux-x86/build-wrapper-linux-x86-64 --out-dir bw-outputs scons target=local --cache-disable gcc_version=5 package 2>&1 > scons.log

hardening-check target/bin/x86Linux/run_app

#complexity --histogram --score --thresh=3 `ls sample/microsoft/src/main/*/*.c`

shellcheck *.sh -f checkstyle > checkstyle-result.xml || true


sourcePath="./sample/microsoft"
coverageSourcePath="$sourcePath/src/main/app/"

# ------------------------------------------------------------------------
# Do we have something to do ?
# ------------------------------------------------------------------------
gcdacount=$(find $coverageSourcePath -name "*.gcda" | wc -c )

if [ $gcdacount -eq 0 ]
then 
    echo "No new LCOV report to generate. Bye."
    exit 0
fi

# ------------------------------------------------------------------------
#cd $sourcePath
#mkdir coverage
#cd coverage

# Capture
lcov --quiet --capture --directory $coverageSourcePath --output-file coverage.info

# Remove useless stuffs
#lcov --remove coverage.info "/Applications/Xcode.app/*" --output-file coverage.info
#lcov --remove coverage.info "$coverageSourcePath/*" --output-file coverage.info

# Generate Report
genhtml coverage.info --title "Nabla during UT" --output-directory "Nabla"

exit 0

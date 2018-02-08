#!/bin/bash
set -e
#set -xv

export PROJECT_TARGET_PATH=${WORKSPACE}/target
#export ENABLE_MEMCHECK=true
export UNIT_TESTS=true
export CHECK_FORMATTING=true
export ENABLE_CLANG=true
#export ENABLE_EXPERIMENTAL=true
#export SONAR_CMD=""

if [ -n "${ENABLE_CLANG}" ]; then
    echo -e "${green} ENABLE_CLANG is defined ${happy_smiley} ${NC}"
    #AddressSanitizer to sanitize your code!
    export ASAN_SYMBOLIZER_PATH=/usr/bin/llvm-symbolizer-3.8
    export ASAN_OPTIONS=alloc_dealloc_mismatch=0,symbolize=1
fi

source ./step-2-0-0-build-env.sh || exit 1

if [ -n "${SCONS_OPTS}" ]; then
  echo -e "${green} SCONS_OPTS is defined ${happy_smiley} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : SCONS_OPTS, use default one ${NC}"

  if [ "$(uname -s)" == "Linux" ]; then
    SCONS_OPTS="target=local --cache-disable gcc_version=5 CC="${CC}" CXX="${CXX}" color=True package"
  else
    SCONS_OPTS="--cache-disable opt=True"
  fi
  #-j32 --cache-disable gcc_version=4.8.5 opt=True
  #--debug=time,explain
  #count, duplicate, explain, findlibs, includes, memoizer, memory, objects, pdb, prepare, presub, stacktrace, time
  export SCONS_OPTS
fi

echo -e "${cyan} ${double_arrow} Environment ${NC}"

echo "WORKSPACE ${WORKSPACE}"

pwd

#clang-format -style=llvm -dump-config > .clang-format

#TODO check https://en.wikipedia.org/wiki/List_of_tools_for_static_code_analysis
#./install.sh

#TODO
#sudo nano /proc/sys/kernel/perf_event_paranoid
#-1

./clean.sh

echo -e "${green} Building : scons ${NC}"

#cd /workspace
#wget https://sonarcloud.io/projects/static/cpp/build-wrapper-linux-x86.zip
echo -e "${magenta} ${SONAR_CMD} ${SCONS} ${SCONS_OPTS} ${NC}"
${SONAR_CMD} ${SCONS} ${SCONS_OPTS} 2>&1 > scons.log

echo -e "${green} Security : hardening-check ${NC}"

echo -e "${magenta} hardening-check target/bin/x86Linux/run_app ${NC}"
hardening-check target/bin/x86Linux/run_app

#complexity --histogram --score --thresh=3 `ls sample/microsoft/src/main/*/*.c`

echo -e "${green} Quality : shellcheck ${NC}"

echo -e "${magenta} shellcheck *.sh -f checkstyle > checkstyle-result.xml ${NC}"
shellcheck *.sh -f checkstyle > checkstyle-result.xml || true

echo -e "${green} Quality : Coverage ${NC}"

sourcePath="./sample/microsoft"
coverageSourcePath="$sourcePath/src/main/app/"

# ------------------------------------------------------------------------
# Do we have something to do ?
# ------------------------------------------------------------------------
echo -e "${magenta} gcdacount=$(find $coverageSourcePath -name "*.gcda" | wc -c ) ${NC}"
gcdacount=$(find $coverageSourcePath -name "*.gcda" | wc -c )

if [ $gcdacount -eq 0 ]; then
    echo "No new LCOV report to generate. Bye."
    exit 0
fi

# ------------------------------------------------------------------------
#cd $sourcePath
#mkdir coverage
#cd coverage

# Capture
echo -e "${magenta} lcov --quiet --capture --directory $coverageSourcePath --output-file coverage.info ${NC}"
lcov --quiet --capture --directory $coverageSourcePath --output-file coverage.info

# Remove useless stuffs
#lcov --remove coverage.info "/Applications/Xcode.app/*" --output-file coverage.info
#lcov --remove coverage.info "$coverageSourcePath/*" --output-file coverage.info

# Generate Report
echo -e "${magenta} genhtml coverage.info --title \"Nabla during UT\" --output-directory \"Nabla\" ${NC}"
genhtml coverage.info --title "Nabla during UT" --output-directory "Nabla"

#xml
echo -e "${magenta} gcovr --branches --xml-pretty -r . 2>&1 > gcovr.xml ${NC}"
gcovr --branches --xml-pretty -r . 2>&1 > gcovr.xml
#html
echo -e "${magenta} gcovr --branches -r . --html --html-details -o gcovr-report.html ${NC}"
gcovr --branches -r . --html --html-details -o gcovr-report.html

#gprof exampleapp gmon.out > gprof_output.txt

exit 0

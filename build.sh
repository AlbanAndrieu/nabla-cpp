#!/bin/bash
#set -xv
#set -eu

WORKING_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}"  )" && pwd  )"

# shellcheck source=/dev/null
source "${WORKING_DIR}/scripts/step-0-color.sh"

echo "python -m pip install --trusted-host pypi.python.org --trusted-host files.pythonhosted.org --trusted-host pypi.org --upgrade pip"
#Successfully installed pip-20.2.4

unset SCONS
echo -e "${red} ${double_arrow} unset SCONS ${head_skull} : SCONS : ${SCONS} ${NC}"
unalias scons
echo -e "${red} ${double_arrow} unalias scons ${head_skull}${NC}"

export PROJECT_TARGET_PATH=${WORKSPACE}/target
#export ENABLE_MEMCHECK=true
export UNIT_TESTS=${UNIT_TESTS:-"true"}
export CHECK_FORMATTING=${CHECK_FORMATTING:-"true"}
export ENABLE_CLANG=${ENABLE_CLANG:-"true"}
#export ENABLE_EXPERIMENTAL=true
#export SONAR_CMD=""

if [ "${ENABLE_CLANG}" == "true" ]; then
    echo -e "${green} ENABLE_CLANG is defined ${happy_smiley} ${NC}"
    #AddressSanitizer to sanitize your code!
    export ASAN_SYMBOLIZER_PATH=/usr/bin/llvm-symbolizer-3.8
    export ASAN_OPTIONS=alloc_dealloc_mismatch=0,symbolize=1
fi

export WORKSPACE="${WORKING_DIR}"

source "${WORKING_DIR}/scripts/step-2-0-0-build-env.sh" || exit 1
WORKING_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}"  )" && pwd  )"

if [ -n "${SCONS_OPTS}" ]; then
  echo -e "${green} SCONS_OPTS is defined ${happy_smiley} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : SCONS_OPTS, use default one ${NC}"

  if [ "$(uname -s)" == "Linux" ]; then
    SCONS_OPTS="target=local --enable-virtualenv --cache-disable color=True package"
    # gcc_version=9.2.1 CC="${CC}" CXX="${CXX}"
  else
    SCONS_OPTS="--cache-disable opt=True"
  fi
  #-j32 --cache-disable gcc_version=4.8.5 opt=True
  #--debug=time,explain
  #count, duplicate, explain, findlibs, includes, memoizer, memory, objects, pdb, prepare, presub, stacktrace, time
  export SCONS_OPTS
fi

echo -e "${cyan} ${double_arrow} Environment ${NC}"

echo -e "${cyan} ${double_arrow} Python install ${NC}"

#sudo pip3.6 freeze > requirements-current-3.6.txt
#sudo pip3.6 install -r requirements-current-3.6.txt
#/opt/ansible/env35/bin/pip install hacking

echo "WORKSPACE ${WORKSPACE}"

pwd

#TODO check https://en.wikipedia.org/wiki/List_of_tools_for_static_code_analysis
#./install.sh

#TODO
#sudo nano /proc/sys/kernel/perf_event_paranoid
#-1

${WORKING_DIR}/clean.sh

echo -e "${magenta} Upgrade python from 2 to 3 : 2to3 -w SConstruct ${NC}"

if [ "$(uname -s)" == "Linux" ]; then
    gcc --version
    g++ --version
    gdb --version
#elif [ "$(uname -s)" == "MINGW64_NT-10.0-17763" ]; then
else
    # See https://www3.ntu.edu.sg/home/ehchua/programming/howto/Cygwin_HowTo.html
    # 32-bit Windows
    i686-w64-mingw32-gcc --version
    i686-w64-mingw32-g++ --version

    # 64-bit Windows
    x86_64-w64-mingw32-gcc --version
    x86_64-w64-mingw32-g++ --version
fi

export CONAN_GENERATOR=${CONAN_GENERATOR:-"scons"}

#${WORKING_DIR}/conan.sh

echo -e "${green} Building : scons ${NC}"

#cd /workspace
#wget https://sonarcloud.io/projects/static/cpp/build-wrapper-linux-x86.zip
echo -e "${magenta} ${SONAR_CMD} ${SCONS} ${SCONS_OPTS} ${NC}"
${SONAR_CMD} ${SCONS} ${SCONS_OPTS} 2>&1 > scons.log
RC=$?
if [ ${RC} -ne 0 ]; then
  echo ""
  # shellcheck disable=SC2154
  echo -e "${red} ${head_skull} Sorry, build failed. ${NC}"
  exit 1
else
  echo -e "${green} The build completed successfully. ${NC}"
fi

echo -e "${green} Security : hardening-check ${NC}"

echo -e "${magenta} hardening-check target/bin/x86Linux/run_app ${NC}"
hardening-check target/bin/x86Linux/run_app

#complexity --histogram --score --thresh=3 `ls sample/microsoft/src/main/*/*.c`

#See https://blog.sideci.com/about-style-guide-of-python-and-linter-tool-pep8-pyflakes-flake8-haking-pyling-7fdbe163079d
echo -e "${green} Quality : python style check pep8/pycodestyle ${NC}"

echo -e "${magenta} pycodestyle --first ./config/Project.py ${NC}"
pycodestyle --first ./config/Project.py

echo -e "${green} Quality : python logistic check pyflakes ${NC}"

#echo -e "${magenta} pyflakes ./config/Project.py ${NC}"
#pyflakes ./config/Project.py

#Simply speaking flake8 is “the wrapper which verifies pep8, pyflakes and circular complexity “.
echo -e "${magenta} flake8 ./config/Project.py ${NC}"
flake8 ./config/Project.py

echo -e "${green} Quality : python module check pylint ${NC}"

echo -e "${magenta} pylint ./config/Project.py ${NC}"
pylint ./config/Project.py

echo -e "${green} Quality : python pep8/pycodestyle statistics ${NC}"

echo -e "${magenta} pycodestyle --statistics -qq ./config/ ${NC}"
pycodestyle --statistics -qq ./config/

echo -e "${green} Quality : Coverage ${NC}"

echo -e "${magenta} find ../.. -name '*.gcda' ${NC}"
find ../.. -name '*.gcda'
find ../.. -name '*.gcno'
find ../.. -name '*.gcov' # for sonar.cfamily.gcov.reportsPath
find ../.. -name '*.info'

sourcePath="./sample/microsoft"
coverageSourcePath="$sourcePath/src/main/app/"

# ------------------------------------------------------------------------
# Do we have something to do ?
# ------------------------------------------------------------------------
echo -e "${magenta} gcdacount=$(find $coverageSourcePath -name "*.gcda" | wc -c ) ${NC}"
gcdacount=$(find $coverageSourcePath -name "*.gcda" | wc -c )

if [ $gcdacount -eq 0 ]; then
    echo "No new LCOV report to generate. Bye."
    exit 1
fi

# ------------------------------------------------------------------------
#cd $sourcePath

## Capture
#echo -e "${magenta} lcov --quiet --capture --directory $coverageSourcePath --output-file coverage.info ${NC}"
#lcov --quiet --capture --directory $coverageSourcePath --output-file coverage.info
#
## Remove useless stuffs
##lcov --remove coverage.info "/Applications/Xcode.app/*" --output-file coverage.info
##lcov --remove coverage.info "$coverageSourcePath/*" --output-file coverage.info
#
## Generate Report
#echo -e "${magenta} genhtml coverage.info --title \"Nabla during UT\" --output-directory \"Nabla\" ${NC}"
#genhtml coverage.info --title "Nabla during UT" --output-directory "Nabla"

mkdir "${WORKSPACE}/reports"

#xml
echo -e "${magenta} gcovr --branches --xml-pretty -r . 2>&1 > ${WORKSPACE}/reports/gcovr-report.xml ${NC}"
gcovr --branches --xml-pretty -r . 2>&1 > ${WORKSPACE}/reports/gcovr-report.xml
#html
echo -e "${magenta} gcovr --branches -r . --html --html-details -o ${WORKSPACE}/reports/gcovr-report.html ${NC}"
gcovr --branches -r . --html --html-details -o ${WORKSPACE}/reports/gcovr-report.html

echo -e "${magenta} gcovr -r ../ . --sonarqube --output ${WORKSPACE}/reports/coverage.xml ${NC}"
gcovr -r ../ . --sonarqube --output ${WORKSPACE}/reports/coverage.xml

#gprof exampleapp gmon.out > gprof_output.txt

echo -e "${magenta} X-compile : scons use_mingw=True use_static=True use_xcompil=True use_conan=False ${NC}"
echo -e "${magenta} X-compile : scripts/run-wine.sh ${NC}"

exit 0

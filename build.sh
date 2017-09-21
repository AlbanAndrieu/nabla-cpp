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

./step-2-0-0-build-env.sh || exit 1

#clang-format -style=llvm -dump-config > .clang-format

#TODO check https://en.wikipedia.org/wiki/List_of_tools_for_static_code_analysis
#./install.sh

#TODO
#sudo nano /proc/sys/kernel/perf_event_paranoid
#-1

./clean.sh

echo -e "${green} Building : scons ${NC}"

#scons opt=True
#cd /workspace
#wget https://sonarcloud.io/projects/static/cpp/build-wrapper-linux-x86.zip
~/build-wrapper-linux-x86/build-wrapper-linux-x86-64 --out-dir ${WORKSPACE}/bw-outputs scons target=local --cache-disable gcc_version=5 package 2>&1 > scons.log
#/workspace/build-wrapper-linux-x86/build-wrapper-linux-x86-32 --out-dir ${WORKSPACE}/bw-outputs

echo -e "${green} Security : hardening-check ${NC}"

hardening-check target/bin/x86Linux/run_app

#complexity --histogram --score --thresh=3 `ls sample/microsoft/src/main/*/*.c`

echo -e "${green} Quality : shellcheck ${NC}"

shellcheck *.sh -f checkstyle > checkstyle-result.xml || true

echo -e "${green} Quality : Coverage ${NC}"

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

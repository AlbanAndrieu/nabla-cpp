#!/bin/bash
#set -xv

WORKING_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}"  )" && pwd  )"

# shellcheck source=/dev/null
source "${WORKING_DIR}/scripts/step-0-color.sh"

echo -e "${cyan} ${double_arrow} Cleaning started ${NC}"

rm -f DartConfiguration.tcl

find . -name 'target' -type d | xargs rm -Rf
find . -name '*.cpp.*r.*' -type f | xargs rm -Rf
#Coverage
find . -name '*.gcno' -type f | xargs rm -Rf
find . -name '*.gcna' -type f | xargs rm -Rf
#CMake
find . -name 'CMakeFiles' -type d | xargs rm -Rf
rm -f sample/build-linux/Makefile
rm -Rf sample/build-linux/_CPack_Packages/
rm -f sample/build-linux/MICROSOFT*.deb
rm -f sample/build-${ARCH}/conan*
#rm -Rf sample/build-linux/nabla_*_amd64.deb
#Scons
#rm -Rf buildcache-*
#rm -Rf scons-signatures-*.dblite
#rm -f sample/microsoft/conanbuildinfo.*
rm -f conanbuildinfo.*

echo -e "${magenta} ${double_arrow} scons clean ${NC}"
scons clean

#git clean --quiet -fdx --exclude="*.tgz" --exclude="*md5" --exclude="*VERSION.TXT"
#git checkout -f .

#Other
rm -Rf nabla-*
#rm -Rf nabla-*.tar.gz
rm -Rf Nabla*
rm -Rf target
rm -Rf bin
rm -Rf include
rm -Rf Testing/

echo -e "${magenta} ${double_arrow} Cleaning DONE ${NC}"

exit 0

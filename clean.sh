#!/bin/bash
#set -xv

source ./step-0-color.sh

echo -e "${cyan} ${double_arrow} Cleaning started ${NC}"

rm -f DartConfiguration.tcl

find . -name 'target' -type d | xargs rm -Rf
find . -name '*.cpp.*r.*' -type f | xargs rm -Rf
#Coverage
find . -name '*.gcno' -type f | xargs rm -Rf
find . -name '*.gcna' -type f | xargs rm -Rf
#CMake
find . -name 'CMakeFiles' -type d | xargs rm -Rf
rm -Rf sample/build-linux/Makefile
rm -Rf sample/build-linux/_CPack_Packages/
rm -Rf sample/build-linux/MICROSOFT*.deb
#rm -Rf sample/build-linux/nabla_*_amd64.deb
#Scons
#rm -Rf buildcache-*
#rm -Rf scons-signatures-*.dblite
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

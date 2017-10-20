#!/bin/bash
#set -xv

source ./step-0-color.sh

echo -e "${red} ${double_arrow} Cleaning started ${NC}"

rm -f DartConfiguration.tcl

find . -name 'target' -type d | xargs rm -Rf
find . -name 'CMakeFiles' -type d | xargs rm -Rf
rm -Rf sample/build-linux/MICROSOFT-10.02-Linux*
rm -Rf sample/build-linux/Makefile
rm -Rf sample/build-linux/_CPack_Packages/
rm -Rf nabla-*
#rm -Rf nabla-*.tar.gz
#rm -Rf buildcache-*
#rm -Rf scons-signatures-*.dblite
rm -Rf Nabla*
rm -Rf target
rm -Rf bin
rm -Rf include
rm -Rf Testing/

exit 0

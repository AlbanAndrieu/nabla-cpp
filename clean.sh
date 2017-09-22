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

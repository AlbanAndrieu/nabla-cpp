#!/bin/sh

scons --version

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
scons target=local gcc_version=5 package 2>&1 > scons.log

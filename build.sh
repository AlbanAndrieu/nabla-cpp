#!/bin/sh

scons --version

#sudo apt-get install clang flawfinder cppcheck ggcov gperf doxygen
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

shellcheck *.sh -f checkstyle > checkstyle-result.xml || true

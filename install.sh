#!/bin/bash
#set -xv

sudo apt-get install colormake
sudo apt-get install cppcheck
sudo apt-get install rats
#sudo apt-get install findbugs
sudo apt-get install flawfinder
#sudo apt-get install cppncss complexity
sudo apt-get install clang flawfinder cppcheck ggcov gcovr gperf doxygen
sudo apt-get install ninja-build

sudo apt-get install texlive-latex-extra texlive-xetex
sudo apt-get install gnuplot latex2html biber 
sudo apt-get install zlib1g-dbg

sudo apt install libxml2-dev libxml2-utils
sudo apt install xsltproc
#sudo apt-get install xscreensaver

sudo apt-get install checkinstall

#See https://github.com/include-what-you-use/include-what-you-use
sudo apt-get install libclang-dev llvm-3.8-dev

llvm-config --version
clang --version
 
sudo apt-get install iwyu 

sudo apt-get install valgrind gawk kcachegrind valkyrie
sudo apt-get install perf linux-tools-generic linux-cloud-tools-generic
 
exit 0

#!/bin/bash
#set -xv

sudo apt-get install cppcheck
sudo apt-get install rats
#sudo apt-get install findbugs
sudo apt-get install flawfinder
#sudo apt-get install cppncss complexity
sudo apt-get install clang flawfinder cppcheck ggcov gperf doxygen
sudo apt-get install ninja-build

sudo apt-get install texlive-latex-extra texlive-xetex
sudo apt-get install gnuplot latex2html biber 
sudo apt-get install zlib1g-dbg

sudo apt install libxml2-dev libxml2-utils
sudo apt install xsltproc
#sudo apt-get install xscreensaver

sudo apt-get install checkinstall

#https://www.dartlang.org/guides/testing
#sudo apt-get update
#sudo apt-get install apt-transport-https
## Get the Google Linux package signing key.
#sudo sh -c 'curl https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -'
## Set up the location of the stable repository.
#sudo sh -c 'curl https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_stable.list > /etc/apt/sources.list.d/dart_stable.list'
#sudo apt-get update
#
#sudo apt-get install dart

exit 0

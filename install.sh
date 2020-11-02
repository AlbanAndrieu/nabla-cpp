#!/bin/bash
#set -xv

#sudo apt-get install rats
wget https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/rough-auditing-tool-for-security/rats-2.4.tgz
tar -xzvf rats-2.4.tgz
cd rats-2.4
./configure && make && sudo make install
./rats
ls -lrta /usr/local/bin/rats

sudo apt install g++-8

sudo apt-get install scons scons-doc
sudo apt-get install colormake
#sudo apt-get install findbugs
#sudo apt-get install cppncss complexity
sudo apt-get install clang clang-tools clang-tidy
sudo apt-get install flawfinder cppcheck ggcov gcovr gperf doxygen
sudo apt-get install ninja-build
ninja --version

sudo apt-get install texlive-latex-extra texlive-xetex
sudo apt-get install gnuplot latex2html biber
sudo apt-get install zlib1g-dbg

sudo apt install libxml2-dev libxml2-utils
sudo apt install xsltproc
#sudo apt-get install xscreensaver

sudo apt-get install checkinstall

#for hardening-check
sudo apt-get install devscripts

#See https://github.com/include-what-you-use/include-what-you-use
sudo apt-get install libclang-dev llvm-dev #llvm-3.8-dev

llvm-config --version
clang --version

sudo apt-get install iwyu

sudo apt-get install valgrind gawk kcachegrind #valkyrie
#sudo apt-get install linux-tools-4.13.0-26-generic linux-cloud-tools-4.13.0-26-generic linux-tools-generic linux-cloud-tools-generic perf
sudo apt-get install linux-tools-generic linux-cloud-tools-generic

#sudo apt-get install libboost-all-dev
#sudo apt-get install libboost-filesystem-dev libboost-thread-dev
sudo apt-get install libboost-filesystem1.67-dev libboost-system1.67-dev libboost-thread1.67-dev # ubuntu 19
sudo apt-get install libcppunit-dev
#Below do not work
#git clone https://github.com/tomtom-international/cpp-dependencies.git
#cd cpp-dependencies
#cmake .
#make

sudo apt-get install vera++
sudo apt-get install pcregrep

sudo apt-get install sparse
#sudo yum install sparse
sudo apt-get install splint
#sudo yum install splint

#For windows
# /c/Python27/Scripts/pip2.7.exe install --trusted-host pypi.python.org --trusted-host files.pythonhosted.org --trusted-host pypi.org pywin32==227 distro==1.5.0 conan==1.31.0
# /c/Python38/Scripts/pip3.8.exe install --trusted-host pypi.python.org --trusted-host files.pythonhosted.org --trusted-host pypi.org pywin32==227 distro==1.5.0 conan==1.31.0
# For linux
python -m pip install --trusted-host pypi.python.org --trusted-host files.pythonhosted.org --trusted-host pypi.org --upgrade pip
pip install --trusted-host pypi.python.org --trusted-host files.pythonhosted.org --trusted-host pypi.org distro==1.5.0 conan==1.31.0

#See https://github.com/jrfonseca/gprof2dot
pip install gprof2dot
pip install cpplint


#sudo pip2.7 install -r requirements-current-2.7.txt
#sudo pip3.6 install -r requirements-current-3.6.txt

#sudo pip install conan==1.5.1
sudo pip install conan
#sudo pip install conan_package_tools==0.18.2
sudo pip install termcolor

sudo apt-get install vera++ gcovr perl lua5.3 tcl tk

exit 0

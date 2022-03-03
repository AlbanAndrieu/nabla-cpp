#!/bin/bash
#set -xv

WORKING_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}"  )" && pwd  )"

#cd ${WORKING_DIR}/..

valgrind --version

echo -e "${magenta} valgrind --tool=memcheck --leak-check=full target/bin/x86Linux/run_app ${NC}"
valgrind --tool=memcheck --leak-check=full target/bin/x86Linux/run_app
echo -e "${magenta} valgrind --tool=dhat target/bin/x86Linux/run_app ${NC}"
valgrind --tool=dhat target/bin/x86Linux/run_app

echo -e "${green} file:///usr/libexec/valgrind/dh_view.html ${NC}"

exit 0

#!/bin/bash
#set -xv

WORKING_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}"  )" && pwd  )"

#cd ${WORKING_DIR}/..

cppcheck --version

reports_directory="reports"
report_filename="cppcheck-result"
if [ ! -e "${WORKING_DIR}/../${reports_directory}" ]; then
    mkdir "${WORKING_DIR}/../${reports_directory}"
fi

# -suppressions-list=cppcheck-suppressions.txt --inline-suppr
# -j 4 --enable=style --std=c++03 --platform=unix64
echo -e "${magenta} cppcheck -j 4 --std=c++03 --platform=unix64 --enable=all ---inconclusive --xml --xml-version=2 -I${WORKING_DIR}/../sample/microsoft sample/microsoft 2> ${WORKING_DIR}/../${reports_directory}/${report_filename}.xml ${NC}"
cppcheck -j 4 --std=c++03 --platform=unix64 --enable=all --inconclusive --xml --xml-version=2 -I${WORKING_DIR}/../sample/microsoft sample/microsoft 2> ${WORKING_DIR}/../${reports_directory}/${report_filename}.xml

#cppcheck --enable=all --inconclusive --html sample/microsoft 2> ${WORKING_DIR}/../${reports_directory}/${report_filename}.html

#mv ${WORKING_DIR}/../${report_filename}* ${WORKING_DIR}/../${reports_directory}

exit 0

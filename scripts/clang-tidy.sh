#!/bin/bash
#set -xv

WORKING_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}"  )" && pwd  )"

#cd ${WORKING_DIR}/..

clang-tidy --version

reports_directory="reports"
report_filename="clang-tidy-result"
if [ ! -e "${WORKING_DIR}/../${reports_directory}" ]; then
    mkdir "${WORKING_DIR}/../${reports_directory}"
fi

#http://clang.llvm.org/docs/HowToSetupToolingForLLVM.html
##clang-format -style=llvm -dump-config > .clang-format
#clang-format -dump-config
#${MAKE} check-all
#clang-tidy -dump-config
echo "clang-tidy --checks='*' --header-filter=*^include* ${WORKING_DIR}/../sample/microsoft sample/microsoft/src/main/app/run_app.cpp > ${WORKING_DIR}/../${reports_directory}/${report_filename}.txt"
clang-tidy --checks='*' --header-filter=*^include* ${PROJECT_SRC}/sample/microsoft/src/main/app/run_app.cpp > ${WORKING_DIR}/../${reports_directory}/${report_filename}.txt

exit 0

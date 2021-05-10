#!/bin/bash
#set -xv

WORKING_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}"  )" && pwd  )"

#cd ${WORKING_DIR}/..

shellcheck --version

reports_directory="reports"
report_filename=" shellcheck-result"
if [ ! -e "${WORKING_DIR}/../${reports_directory}" ]; then
    mkdir "${WORKING_DIR}/../${reports_directory}"
fi

echo -e "${magenta} shellcheck *.sh -f checkstyle > ${reports_directory}/shellcheck-result.xml ${NC}"
shellcheck *.sh -f checkstyle > ${reports_directory}/shellcheck-result.xml || true

exit 0

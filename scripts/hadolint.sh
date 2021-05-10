#!/bin/bash
#set -xv
WORKING_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}"  )" && pwd  )"

echo -e "${red} hadolint ${NC}"

hadolint --version

reports_directory="reports"
report_filename="hadolint-report"
if [ ! -e "${WORKING_DIR}/../${reports_directory}" ]; then
    mkdir "${WORKING_DIR}/../${reports_directory}"
fi

echo -e "${magenta} hadolint -f checkstyle ${WORKING_DIR}/../Dockerfile > ${WORKING_DIR}/../${reports_directory}/${report_filename}.xml ${NC}"
hadolint -f checkstyle ${WORKING_DIR}/../Dockerfile > ${WORKING_DIR}/../${reports_directory}/${report_filename}.xml

exit 0

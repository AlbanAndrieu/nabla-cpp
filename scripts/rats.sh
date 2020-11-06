#!/bin/bash
#set -xv

WORKING_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}"  )" && pwd  )"

#cd ${WORKING_DIR}/..

#rats --version

reports_directory="reports"
report_filename="rats-result"
if [ ! -e "${WORKING_DIR}/../${reports_directory}" ]; then
    mkdir "${WORKING_DIR}/../${reports_directory}"
fi

echo "rats -w 3 --xml ${WORKING_DIR}/../sample/microsoft > ${WORKING_DIR}/../${reports_directory}/${report_filename}.xml"
rats -w 3 --xml ${WORKING_DIR}/../sample/microsoft > ${WORKING_DIR}/../${reports_directory}/${report_filename}.xml

rats --warning 1 --html ${WORKING_DIR}/../sample/microsoft > ${WORKING_DIR}/../${reports_directory}/${report_filename}.html

#mv ${WORKING_DIR}/../${report_filename}* ${WORKING_DIR}/../${reports_directory}

exit 0

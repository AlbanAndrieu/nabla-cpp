#!/bin/bash
#set -xv

WORKING_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}"  )" && pwd  )"

# shellcheck source=/dev/null
source "${WORKING_DIR}/step-0-color.sh"

echo -e "${red} Flawfinder ${NC}"

flawfinder --version

reports_directory="reports"
report_filename="flawfinder-result"
if [ ! -e "${WORKING_DIR}/../${reports_directory}" ]; then
    mkdir "${WORKING_DIR}/../${reports_directory}"
fi

echo "flawfinder  --quiet --context --falsepositive --html --minlevel=3 ${WORKING_DIR}/../sample/microsoft > ${WORKING_DIR}/../${reports_directory}/${report_filename}.html"
flawfinder \
 --quiet \
 --context \
 --falsepositive \
 --html \
 --minlevel=3 \
 ${WORKING_DIR}/../sample/microsoft \
 > "${WORKING_DIR}/../${reports_directory}/${report_filename}.html"

flawfinder \
 --quiet \
 --context \
 --falsepositive \
 --minlevel=3 \
 ${WORKING_DIR}/../sample/microsoft

#mv "${WORKSPACE}/${report_filename}.html" "${WORKING_DIR}/../${reports_directory}"

exit 0

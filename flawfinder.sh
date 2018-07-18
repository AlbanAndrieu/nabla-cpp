#!/bin/bash
#set -xv

source ./step-0-color.sh

echo -e "${red} Flawfinder ${NC}"

flawfinder --version

reports_directory="reports"
report_filename="flawfinder-result"
if [ ! -e "${reports_directory}" ]; then
    mkdir "${reports_directory}"
fi

flawfinder \
 --quiet \
 --context \
 --falsepositive \
 --html \
 --minlevel=3 \
 sample/microsoft \
 > "${WORKSPACE}/${report_filename}.html"

mv "${WORKSPACE}/${report_filename}.html" "${reports_directory}"

exit 0

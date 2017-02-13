#!/bin/sh -e

flawfinder --version

reports_directory="flawfinder-reports"
report_filename="flawfinder-result-SAMPLE"
if [ ! -e ${reports_directory} ]; then
    mkdir ${reports_directory}
fi

flawfinder \
 --quiet \
 --context \
 --falsepositive \
 --html \
 --minlevel=3 \
 sample/microsoft \
 > ${WORKSPACE}/${report_filename}.html

mv ${report_filename}* ${reports_directory}

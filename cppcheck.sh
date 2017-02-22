#!/bin/sh -e

cppcheck --version

reports_directory="cppcheck-reports"
report_filename="cppcheck-result-SAMPLE"
if [ ! -e ${reports_directory} ]; then
    mkdir ${reports_directory}
fi

cppcheck --enable=all --inconclusive --xml --xml-version=2 sample/microsoft 2> ${report_filename}.xml

#cppcheck --enable=all --inconclusive --html sample/microsoft 2> ${report_filename}.html

mv ${report_filename}* ${reports_directory}

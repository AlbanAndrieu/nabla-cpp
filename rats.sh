#!/bin/bash

#rats --version

reports_directory="reports"
report_filename="rats-result-SAMPLE"
if [ ! -e ${reports_directory} ]; then
    mkdir ${reports_directory}
fi

rats -w 3 --xml sample/microsoft > ${report_filename}.xml

rats --warning 1 --html sample/microsoft > ${report_filename}.html

mv ${report_filename}* ${reports_directory}

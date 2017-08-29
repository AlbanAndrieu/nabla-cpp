#!/bin/sh -e

findbugs --version

reports_directory="findbugs-reports"
report_filename="findbugs-result-SAMPLE"
if [ ! -e ${reports_directory} ]; then
    mkdir ${reports_directory}
fi

findbugs --enable=all -textui -high -projectName Nabla -xml -output ${report_filename}.xml \
-auxclasspath $WORKSPACE/lib \
-sourcepath $WORKSPACE/src/main/java \

mv ${report_filename}* ${reports_directory}

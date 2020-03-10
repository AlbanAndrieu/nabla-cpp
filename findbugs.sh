#!/bin/bash
#set -xv

WORKING_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}"  )" && pwd  )"

# shellcheck source=/dev/null
source "${WORKING_DIR}/step-0-color.sh"

echo -e "${red} Findbugs ${NC}"

findbugs --version

reports_directory="findbugs-reports"
report_filename="findbugs-result-SAMPLE"
if [ ! -e "${reports_directory}" ]; then
    mkdir "${reports_directory}"
fi

findbugs --enable=all -textui -high -projectName Nabla -xml -output "${report_filename}.xml" \
-auxclasspath $WORKSPACE/lib \
-sourcepath $WORKSPACE/src/main/java \

mv "${report_filename}*" "${reports_directory}"

exit 0

#!/bin/bash
#set -xv

WORKING_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}"  )" && pwd  )"

# shellcheck source=/dev/null
source "${WORKING_DIR}/step-0-color.sh"

echo -e "${red} Findbugs ${NC}"

#cd ${WORKING_DIR}/..

findbugs -version

reports_directory="reports"
report_filename="findbugs-result-SAMPLE"
if [ ! -e "${WORKING_DIR}/../${reports_directory}" ]; then
    mkdir "${WORKING_DIR}/../${reports_directory}"
fi

#findbugs --enable=all -textui -high
echo "findbugs -textui -high -project Nabla -xml -output \"${WORKING_DIR}/${report_filename}.xml\" -auxclasspath ${WORKING_DIR}/../sample/build-linux/lib -sourcepath ${WORKING_DIR}/../sample/microsoft/src/main/java "
findbugs -textui -high -projectName Nabla -xml -output "${WORKING_DIR}/../${report_filename}.xml" \
-auxclasspath $WORKING_DIR/../sample/build-linux/lib \
-sourcepath $WORKING_DIR/../sample/microsoft/src/main/java \

mv ${WORKING_DIR}/../${report_filename}* "${WORKING_DIR}/../${reports_directory}"

exit 0

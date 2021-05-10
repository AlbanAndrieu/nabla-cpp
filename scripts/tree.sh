#!/bin/bash
#set -xv

WORKING_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}"  )" && pwd  )"

cd ${WORKING_DIR}/..

reports_directory="reports"
report_filename="deps-result"
if [ ! -e "${WORKING_DIR}/../${reports_directory}" ]; then
    mkdir "${WORKING_DIR}/../${reports_directory}"
fi

/opt/ansible/env38/bin/python /opt/ansible/env38/bin/scons --tree=prune
#/opt/ansible/env38/bin/python /opt/ansible/env38/bin/scons --tree=prune binaries

/opt/ansible/env38/bin/python /opt/ansible/env38/bin/scons --tree=derived,prune target -n | ${WORKING_DIR}/scons2dot.py --save --outfile ${WORKING_DIR}/../${reports_directory}/${report_filename}.pdf

tree -L 2

exit 0

#!/bin/bash
#set -xv

WORKING_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}"  )" && pwd  )"

cd ${WORKING_DIR}/..

/opt/ansible/env38/bin/python /opt/ansible/env38/bin/scons --tree=prune
#/opt/ansible/env38/bin/python /opt/ansible/env38/bin/scons --tree=prune binaries

/opt/ansible/env38/bin/python /opt/ansible/env38/bin/scons --tree=derived,prune target -n | ${WORKING_DIR}/scons2dot.py --save --outfile ${WORKING_DIR}/deps.pdf

exit 0

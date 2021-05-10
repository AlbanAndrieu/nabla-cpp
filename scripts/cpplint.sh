#!/bin/bash
#set -xv
WORKING_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}"  )" && pwd  )"

#cd ${WORKING_DIR}/..

cpplint --version

echo -e "${magenta} find ${WORKING_DIR}/../sample/microsoft/src -regextype posix-extended -iregex '.*[.](h|cpp)' ! -iregex '.*/model/.*' | xargs $WORKING_DIR/cpplint.py --filter=+legal,+build,+readability,+runtime,+whitespace,-whitespace/blank_line,-runtime/printf || true ${NC}"
find ${WORKING_DIR}/../sample/microsoft/src -regextype posix-extended -iregex '.*[.](h|cpp)' ! -iregex '.*/model/.*' | xargs $WORKING_DIR/cpplint.py --filter=+legal,+build,+readability,+runtime,+whitespace,-whitespace/blank_line,-runtime/printf || true
#find . -regextype posix-extended -iregex '.*[.](h|cpp)' -iregex '.*/model/.*' ! -iregex '.*/generated/.*' | xargs $PROJECT_SRC/cpplint.py --filter=-legal,+build,+readability,+runtime,+whitespace,-whitespace/blank_line,-runtime/printf || true
#find . -regextype posix-extended -iregex '.*[.](h|cpp)' -iregex '.*/model/.*' -iregex '.*/generated/.*' | xargs $PROJECT_SRC/cpplint.py --filter=-legal,+build,+readability,+runtime,+whitespace,-whitespace/blank_line,-whitespace/line_length,-runtime/printf || true

exit 0

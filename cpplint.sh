#!/bin/bash
#set -xv

find . -regextype posix-extended -iregex '.*[.](h|cpp)' ! -iregex '.*/model/.*' | xargs $PROJECT_SRC/cpplint.py --project=cormo --filter=+legal,+build,+readability,+runtime,+whitespace,-whitespace/blank_line,-runtime/printf
#find . -regextype posix-extended -iregex '.*[.](h|cpp)' -iregex '.*/model/.*' ! -iregex '.*/generated/.*' | xargs $PROJECT_SRC/cpplint.py --project=cormo --filter=-legal,+build,+readability,+runtime,+whitespace,-whitespace/blank_line,-runtime/printf
#find . -regextype posix-extended -iregex '.*[.](h|cpp)' -iregex '.*/model/.*' -iregex '.*/generated/.*' | xargs $PROJECT_SRC/cpplint.py --project=cormo --filter=-legal,+build,+readability,+runtime,+whitespace,-whitespace/blank_line,-whitespace/line_length,-runtime/printf

exit 0

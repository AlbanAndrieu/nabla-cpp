#!/bin/sh -e

cppcheck --version

cppcheck --enable=all --inconclusive --xml --xml-version=2 sample/microsoft 2> cppcheck.xml

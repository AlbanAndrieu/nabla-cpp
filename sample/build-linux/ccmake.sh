#!/bin/bash
set -xv

ccmake -DCMAKE_BUILD_TYPE=debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON ../microsoft

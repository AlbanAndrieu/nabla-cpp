#!/bin/sh

scons --version

#scons opt=True
scons target=local gcc_version=5 package 2>&1 > scons.log

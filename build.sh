#!/bin/sh

scons --version

#scons opt=True 
scons target=local package 2>&1 > scons.log

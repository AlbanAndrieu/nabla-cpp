#!/bin/sh

scons --tree=prune
#scons --tree=prune binaries

scons --tree=all -n | ./scons2dot.py --save --outfile deps.pdf

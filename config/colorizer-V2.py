#!/usr/bin/env python3.7
# -*- coding: utf-8 -*-
import os
import re
import select
import subprocess
import sys

from . import ProjectMacro

c_underline = '\033[04m'
c_blink = '\033[05m'
c_norm = '\033[00m'

# Normal
c_black = '\033[0;30m'
c_red = '\033[0;31m'
c_green = '\033[0;32m'
c_yellow = '\033[0;33m'
c_blue = '\033[0;34m'
c_purple = '\033[0;35m'
c_cyan = '\033[0;36m'
c_white = '\033[0;37m'

# Bold
cb_black = '\033[1;30m'
cb_red = '\033[1;31m'
cb_green = '\033[1;32m'
cb_yellow = '\033[1;33m'
cb_blue = '\033[1;34m'
cb_purple = '\033[1;35m'
cb_cyan = '\033[1;36m'
cb_white = '\033[1;37m'

# BackGround
cback_blue = '\033[1;44m'
cback_white = '\033[1;47m'
cback_black = '\033[1;45m'

# ------------------------------------------------------------------------------
# regexps and what they will be replaced with
# ------------------------------------------------------------------------------
colorPatterns = [
    (
        re.compile(r'(.*: [Ww]arning[:,].*)'),
        r'%s[Warning] %s\1%s' % (cb_red, cb_yellow, c_norm),
    ),
    (
        re.compile(r'(.*: [Ee]rror[:,].*)'),
        r'%s[Error] \1%s' % (cb_red, c_norm),
    ),
    (
        re.compile(r'\[(CC|CXX|UIC|MOC|Q2K|RCC|RAN|LNK)\](.*?)([^/]+)$'),
        r'%s[\1]%s\2%s\3%s' % (c_blue, c_purple, cb_purple, c_norm),
    ),
    (
        re.compile(r'\[(INST)\](.*)$'), r'%s[\1]%s\2%s' %
        (cb_green, c_green, c_norm),
    ),
    # verbose mode
    (
        re.compile(r'(Install file:)(.*)$'),
        r'%s[\1]%s\2%s' % (cb_green, c_green, c_norm),
    ),
    (re.compile(r'^(ranlib|Removed)(.*)$'), r'%s\1%s\2' % (cb_cyan, c_norm)),
    (
        re.compile(r'^(CC|cc|gcc|g\+\+|ar) ([^\s]+) ([^\s]+)(.*)$'),
        r'%s\1%s \2 %s\3%s\4' % (cb_cyan, c_norm, c_cyan, c_norm),
    ),
]

# ------------------------------------------------------------------------------
# Colorize a line according to defined patterns
# ------------------------------------------------------------------------------


def colorize(line):
    for regexp, replacement in colorPatterns:
        line = regexp.sub(replacement, line)

    return line


# ------------------------------------------------------------------------------
# Allows to hijack default stdout and stderr to colorize them
# ------------------------------------------------------------------------------
class Colorizer(object):
    def __init__(self, redirected):
        self.buf = ''
        self.redirected = redirected

    def isatty(self):
        return self.redirected.isatty()

    def fileno(self):
        return self.redirected.fileno()

    def flush(self):
        if self.buf:
            self.redirected.write(colorize(self.buf))
            self.buf = ''
        return self.redirected.flush()

    def write(self, msg):
        if self.buf:
            msg = self.buf + msg
            self.buf = ''
        line, sep, msg = msg.partition('\n')
        while sep:
            self.redirected.write(colorize(line) + '\n')
            line, sep, msg = msg.partition('\n')
        if line:
            self.buf = line

    def __del__(self):
        if self.buf:
            self.redirected.write(colorize(self.buf))


# ------------------------------------------------------------------------------
# Asynchroneously stream subprocess stdout/stderr to our own stdout/stderr
# ------------------------------------------------------------------------------
def colorizeSpawn(shell, escape, cmd, args, env):
    proc = subprocess.Popen(
        ' '.join(args),
        stderr=subprocess.PIPE, stdout=subprocess.PIPE,
        shell=True, env=env,
    )
    monitoredStreams = [proc.stdout, proc.stderr]
    while monitoredStreams:
        rsig, wsig, xsig = select.select(monitoredStreams, [], [])

        if proc.stdout in rsig:
            data = os.read(proc.stdout.fileno(), 1024)
            if data:
                sys.stdout.write(data)
            else:
                proc.stdout.close()
                monitoredStreams.remove(proc.stdout)

        if proc.stderr in rsig:
            data = os.read(proc.stderr.fileno(), 1024)
            if data:
                sys.stderr.write(data)
            else:
                proc.stderr.close()
                monitoredStreams.remove(proc.stderr)

    ret = proc.poll()
    return ret


# ------------------------------------------------------------------------------
# Initialize the colorizer
# ------------------------------------------------------------------------------
def generate(env, **kw):

    Arch = ProjectMacro.getArch()

    if Arch != 'winnt' and env['color']:
        if type(sys.stdout) == file and sys.stdout.isatty():
            env['SPAWN'] = colorizeSpawn
            sys.stdout = Colorizer(sys.stdout)
        if type(sys.stderr) == file and sys.stderr.isatty():
            env['SPAWN'] = colorizeSpawn
            sys.stderr = Colorizer(sys.stderr)


def exists(env):
    return 1

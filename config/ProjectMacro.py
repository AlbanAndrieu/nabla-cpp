#!/usr/bin/env python3.7
# -*- coding: utf-8 -*-
# Helper functions for the scons build
# inspired from SconsBuilder.py
import sys
import fnmatch
import glob
import os
import platform
import re
import string
import time

import SCons.Scanner.IDL

######################################################


def getEnvVariable(aVariableName, aDefaultValue):
    if aVariableName in os.environ:
        return os.environ[aVariableName]
    else:
        return aDefaultValue

######################################################


def listDirectories(path, skip=[]):
    dirs = []
    if path == '':
        path = '.'
    dirlist = sorted(
        [
            item for item in os.listdir(path)
            if os.path.isdir(os.path.join(path, item))
        ],
    )
    for npath in dirlist:
        dirs.append(npath)
        name = os.path.basename(npath)
        for check in skip:
            match = fnmatch.fnmatch(name, check)
            if match:
                try:
                    dirs.remove(npath)
                except:
                    pass
    return dirs

#####################################################


def mkdir(newdir):
    """
                    - already exists, silently complete
                    - regular file in the way, raise an exception
                    - parent directory(ies) does not exist, make them as well
    """
    if os.path.isdir(newdir):
        pass
    elif os.path.isfile(newdir):
        raise OSError(
            'a file with the same name as the desired '
            "dir, '%s', already exists." % newdir,
        )
    else:
        head, tail = os.path.split(newdir)
        if head and not os.path.isdir(head):
            mkdir(head)
        if tail:
            os.mkdir(newdir)

#####################################


def getFileNodesRecursively(aPath, aSconsEnv, aListOfPatterns, aListOfFoldersToSkip=['.svn', 'unittest']):
    """ returns a list of nodes scanning recursively a given path """
    theNodeList = []
    for thePattern in aListOfPatterns:
        theNodeList += aSconsEnv.Glob(os.path.join(aPath, thePattern))
    theFolderList = listDirectories(
        aSconsEnv.Dir(
            aPath,
        ).srcnode().abspath, aListOfFoldersToSkip,
    )
#   theFolderList = listDirectories(aPath, aListOfFoldersToSkip)
    for theFolder in theFolderList:
        theNodeList.extend(
            getFileNodesRecursively(
                os.path.join(
                    aPath, theFolder,
                ), aSconsEnv, aListOfPatterns, aListOfFoldersToSkip,
            ),
        )
    return theNodeList


#####################################
# generates the list of files generated by the IDL tool of TAO
def idl2many_emitter(target, source, env):
    new_t = []
    fls = source[0]
    flt = target[0]
    if str(fls).endswith('.idl'):
        for suf in ['.hh', '.cc', '.i', '_s.hh', '_s.cc', '_s.i']:
            new_t.append(str(flt) + suf)
    return (new_t, source)

#####################################
# gather .cc files generated by the IDL


def idl2cc_bld(env, target, source):
    idl_res = env.CorbaIdl(source)
    cpp = []
    for fl in idl_res:
        if str(fl).endswith('.cc'):
            cpp.append(fl)
    return cpp

#####################################
# gather .hh files generated by the IDL


def idl2hh_bld(env, target, source):
    idl_res = env.CorbaIdl(source)
    hh = []
    for fl in idl_res:
        if str(fl).endswith('.hh') or str(fl).endswith('.i'):
            hh.append(fl)
    return hh

#####################################
# Add IDL builders to the scons environment


def registerIDLBuilders(env, thirdPartyDir, arch):
    # IDL generation builder function
    idl2many_bld = SCons.Builder.Builder(
        action=SCons.Action.Action(
            '$IDL $IDLFLAGS -I$KTPPIncludesDir ${SOURCE} -o ${TARGET.dir}', '$IDLCOMSTR',
        ),
        src_suffix='.idl',
        emitter=idl2many_emitter,
        source_scanner=SCons.Scanner.IDL.IDLScan(),
        single_source=1,
    )

    env['ENV']['LD_LIBRARY_PATH'] = os.path.join(
        thirdPartyDir, 'tao', arch, 'ACE_wrappers', 'lib',
    )
    env['ENV']['TAO_ROOT'] = os.path.join(thirdPartyDir, 'tao', arch)
    env['ENV']['ACE_ROOT'] = os.path.join(
        thirdPartyDir, 'tao', arch, 'ACE_wrappers',
    )

    env.Append(
        IDL=os.path.join(thirdPartyDir, 'tao', arch, 'bin', 'opt', 'tao_idl'),
        TAO_ROOT=os.path.join(thirdPartyDir, 'tao', arch),
        ACE_ROOT=os.path.join(thirdPartyDir, 'tao', arch, 'ACE_wrappers'),
        IDLFLAGS='-hc .hh -hs _s.hh -cs .cc -ss _s.cc -sT _st.cc -si _s.i -ci .i -hT _st.hh',
    )

    # auto-react with idl2many_bld when building *.idl files
    static_obj, shared_obj = SCons.Tool.createObjBuilders(env)
    static_obj.src_builder.append(idl2many_bld)
    shared_obj.src_builder.append(idl2many_bld)

    env.Append(
        BUILDERS={
            'CorbaIdl': idl2many_bld,
            'CorbaGetCCFiles': idl2cc_bld,
            'CorbaGetHHFiles': idl2hh_bld,
        },
    )


###################################
# functions to register build failures
def bf_to_str(bf):
    """Convert an element of GetBuildFailures() to a string
    in a useful way."""
    import SCons.Errors
    if bf is None:  # unknown targets product None in list
        return '(unknown tgt)'
    elif isinstance(bf, SCons.Errors.StopError):
        return str(bf)
    elif bf.node:
        return str(bf.node) + ': ' + bf.errstr
    elif bf.filename:
        return bf.filename + ': ' + bf.errstr
    return 'unknown failure: ' + bf.errstr


def build_status():
    """Convert the build status to a 2-tuple, (status, msg)."""
    from SCons.Script import GetBuildFailures
    bf = GetBuildFailures()
    if bf:
        # bf is normally a list of build failures; if an element is None,
        # it's because of a target that scons doesn't know anything about.
        status = 'failed'
        failures_message = '\n'.join([
            'Failed building %s' % bf_to_str(x)
            for x in bf if x is not None
        ])
    else:
        # if bf is None, the build completed successfully.
        status = 'ok'
        failures_message = ''
    return (status, failures_message)


def display_build_status(env):
    if env['color']:
        from termcolor import colored, cprint
    """Display the build status.  Called by atexit.
    Here you could do all kinds of complicated things."""
    status, failures_message = build_status()
    if status == 'failed':
        if env['color']:
            cprint('FAILED!!!!', 'red', attrs=['bold'], file=sys.stderr)
        else:
            print('FAILED!!!!')  # could display alert, ring bell, etc.
    elif status == 'ok':
        if env['color']:
            print(colored('Build succeeded.', 'green'))
        else:
            print('Build succeeded.')

    if env['color']:
        print(
            colored(
                '[Timestamp] FINISH SCONS AT %s' %
                time.strftime('%H:%M:%S'), 'red',
            ),
        )
    else:
        print(failures_message)


def registerBuildFailuresAtExit(env):
    import atexit
    atexit.register(display_build_status(env))

##############################################################################
# defined env verbosity


def reduceBuildVerbosity(env):
    env['CCCOMSTR'] = 'Compiling $TARGET'
    env['CXXCOMSTR'] = 'Compiling $SOURCE'
    env['LINKCOMSTR'] = 'Linking $TARGET'
    env['IDLCOMSTR'] = 'IDL Generation for: ${SOURCE}'

################################################################
# define the arch
def getDistribution():
  try:
    with open("/etc/os-release") as osr:
      osReleaseLines = osr.readlines()
    hasOsRelease = True
  except (IOError,OSError):
    osReleaseLines = []
    hasOsRelease = False
  try:
    import platform
    if platform.system() == "Darwin":
      return "osx_x86-64"
  except:
    pass
  try:
    import platform, distro
    # print(sys.version_info)
    if sys.version_info<(3,5,0):
        dist = platform.dist() # Deprecated since version 3.5, will be removed in version 3.8
    else :
        if sys.platform == 'win32':
            dist = ["unknown", "", ""]
        else:
            import distro        
            dist = distro.linux_distribution()
    return dist
  except:
    return ["unknown", "", ""]

def getArch():
    thePlatform = platform.platform()
    # print("platform : " + thePlatform)
    theArch = 'unkown'
    if thePlatform.startswith('Linux'):
        theArch = 'x86Linux'
    elif thePlatform.startswith('Windows'):
        theArch = 'winnt'
    elif thePlatform.startswith('CYGWIN'):
        theArch = 'cygwin'
    elif thePlatform.startswith('MINGW') or thePlatform.startswith('MSYS'):
        theArch = 'mingw'
    elif thePlatform.startswith('SunOS'):
        if platform.machine() == 'sun4u' or platform.machine() == 'sun4v':
            theArch = 'sun4sol'
        elif platform.machine() == 'i86pc':
            theArch = 'x86sol'
    return theArch

################################################################
# See https://github.com/brave/brave-browser/issues/7328
class ourSpawn:
    def ourspawn(self, sh, escape, cmd, args, env):
        newargs = ' '.join(args[1:])
        cmdline = cmd + " " + newargs
        startupinfo = subprocess.STARTUPINFO()
        startupinfo.dwFlags |= subprocess.STARTF_USESHOWWINDOW
        proc = subprocess.Popen(cmdline, stdin=subprocess.PIPE, stdout=subprocess.PIPE,
            stderr=subprocess.PIPE, startupinfo=startupinfo, shell = False, env = env)
        data, err = proc.communicate()
        rv = proc.wait()
        if rv:
            print("=====")
            print(err)
            print("=====")
        return rv

def SetupSpawn( env ):
    if sys.platform == 'win32':
        buf = ourSpawn()
        buf.ourenv = env
        env['SPAWN'] = buf.ourspawn
        
# ---------------------------------------------------------------------------------------

def fixArguments(args):

    newArgs = []
    for arg in args:
        newArgs.append(arg.replace('\\', '/'))
    return newArgs

def myWin32Spawn(sh, escape, cmd, args, env):

    import SCons.Platform.win32

    args = fixArguments(args)
    mystring = string.join(args)

    #print("spawning " + SCons.Platform.win32.escape(mystring))

    if len(mystring) > 10000:
        filename = tempfile.mktemp()
        newFile = open(filename, "w")
        newFile.write(mystring)
        newFile.close()

        return SCons.Platform.win32.exec_spawn([sh, filename], env)

    return SCons.Platform.win32.exec_spawn([sh, "-c", SCons.Platform.win32.escape(mystring)], env)

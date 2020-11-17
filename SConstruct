#!/usr/bin/env python3.7
# -*- coding: utf-8 -*-
#################
# Scons build script
######################

import os
import shutil
import re
import platform
import subprocess
import time
import SCons
import sys

from config import ProjectMacro

EnsureSConsVersion(3, 1, 2)
EnsurePythonVersion(3, 6)

# Hack to ensure that .svn changes don't trigger rebuild where using DirScanner
SCons.Scanner.Dir.skip_entry['.svn'] = 1

#In Eclipse add to scons
#--cache-disable --warn=no-dependency gcc_version=5.4.1 CC=clang CXX=clang++ color=False
#TERM xterm-256color

# To be retrieved automatically
Arch = ProjectMacro.getArch()
print("Arch :", Arch)
ProjectMacro.getConfiguration(ARGUMENTS.get('PLATFORM', str(ARGUMENTS.get('OS', Platform()))))

Help('''
Type 'scons' to build and run all the available test cases.
It will automatically detect your platform and C compiler and
build appropriately.
You can modify the behavious using following options:
CC          Name of C compiler
CXX         Name of C++ compiler
CCFLAGS     Flags to pass to the C compiler
CXXFLAGS    Flags to pass to the C++ compiler
For example, for a clang build, use:
scons CC=clang CXX=clang++
''')

def get_option(name):
    return GetOption(name)

def find_nabla_custom_variables():
    files = []
    paths = [path for path in sys.path if 'site_scons' in path]
    for path in paths:
        probe = os.path.join(path, 'nabla_custom_variables.py')
        if os.path.isfile(probe):
            files.append(probe)
    return files

# Apply the default variables files, and walk the provided
# arguments. Interpret any falsy argument (like the empty string) as
# resetting any prior state. This makes the argument
# --variables-files= destructive of any prior variables files
# arguments, including the default.
#variables_files_args = get_option('variables-files')
variables_files_args = ""
variables_files = find_nabla_custom_variables()
for variables_file in variables_files_args:
    if variables_file:
        variables_files.append(variables_file)
    else:
        variables_files = []
for vf in variables_files:
    if not os.path.isfile(vf):
        fatal_error(None, f"Specified variables file '{vf}' does not exist")
    print(f"Using variable customization file {vf}")


# Command line variables definition
vars = Variables(variables_files, args=ARGUMENTS) # you can store your defaults in this file
vars.AddVariables(
    BoolVariable('debug', 'Set to true to build without opt flags', True), # Not yet use except in atom targets.ini
    BoolVariable('release', 'Set to true to build with opt flags', False),
    BoolVariable('use_clang', 'On linux only: replace gcc by clang', False),
    BoolVariable('use_clangsa', 'On linux only: replace gcc by whatever clang scan-build provided', False),
    BoolVariable('use_cpp11', 'On linux only: ask to compile using C++11', True),
    BoolVariable('use_pthread', 'On linux only: ask to compile using pthread', True),
    BoolVariable('use_gcov', 'On linux only: build with gcov flags', False),
    BoolVariable('use_asan', 'On linux only and clang: build with address sanitize', False),
    BoolVariable('use_xcompil', 'X compile (for clang)', False),
    BoolVariable('use_mingw', 'X compile using mingw', False),
    BoolVariable('use_conan', 'Use conan (Not working on mingw)', True),
    BoolVariable('use_static', 'Build static libs and binaries', False),
    BoolVariable('color', 'Set to true to build with colorizer', True),
    ('gcc_version', 'Set gcc version to use', '10'),
    ('install_path', 'Set install path', 'install'),
    ('cache_path', 'Set scons cache path', os.path.join(Dir("#").abspath, 'buildcache')),
    ('bom', 'bom location of additional 3rdparties.', ''),
#    ('CC', 'Set C compiler : gcc, clang', 'gcc'),
#    ('CXX', 'Set C++ compiler : g++, clang++', 'g++'),
    ('version', 'The version of the component you build', '1.0.0'),
    ('target_bits', '32/64 bits', '64'),
    ('tar', 'tar binary', 'tar'),
    EnumVariable('target', 'Target platform', 'local', ['default', 'local'])
)

vars.Add('VERBOSE',
    help='Control build verbosity (auto, on/off true/false 1/0)',
    default='auto',
)

# Assuming you store your defaults in a file
msvcver = vars.args.get('vc', '14')

# Check command args to force one Microsoft Visual Studio version
if msvcver == '14' or msvcver == '16' or msvcver == '17':
  env = Environment(MSVC_VERSION=msvcver+'.0', TARGET_ARCH="x86_64", MSVC_BATCH=False, variables = vars)
else:
  env = Environment(variables = vars)

env = Environment(variables = vars)

Command('/opt/ansible/env38/', None, 'virtualenv $TARGET; source $TARGET/bin/activate; cd $TARGET; pip install termcolor')

print('Xcompil :', env['use_xcompil'])
print('Mingw :', env['use_mingw'])

if not ('help' in COMMAND_LINE_TARGETS or GetOption('help')) and not ('clean' in COMMAND_LINE_TARGETS or GetOption('clean')) and env['use_conan']: #  and Arch not in ['mingw', 'cygwin', 'winnt']
    # Import Conan
    from conans.client.conan_api import ConanAPIV1 as conan_api
    from conans import __version__ as conan_version

    conan, _, _ = conan_api.factory()

    build_directory = os.path.join(os.getcwd(), "sample", "build-scons")
    if not os.path.exists(build_directory):
        os.makedirs(build_directory)

    src_directory = os.path.join(os.getcwd(), "sample", "microsoft")
    #build_hello_directory = os.path.join(src_directory, "hello.c")

    conanfile_path = os.path.join(os.getcwd(), src_directory, "conanfile.txt")

    # See https://git.ircad.fr/conan/conan-boost/blob/fc812a583a6e88ee7dc378ac2cc47ed1055fb37a/conanfile.py

    conan.install(conanfile_path,\
            generators=["scons"],\
            install_folder=build_directory)

ProjectMacro.SetupSpawn(env)

if env['use_mingw'] or Arch in ['mingw', 'cygwin', 'winnt']:
    #env['use_mingw'] = True
    #print('Ovverride mingw : ', env['use_mingw'])
    target_tools = ['default', 'mingw']

    #print("MSVSSolution")

#env.MSVSSolution(target = 'Microsoft' + env['MSVSSOLUTIONSUFFIX'],
#                 projects = ['Microsoft' + env['MSVSPROJECTSUFFIX']],
#                 variant = 'Release')

if env['use_mingw'] == True and Arch in ['mingw', 'cygwin', 'winnt', 'x86Linux']:
    target_tools = ['default', 'mingw']
else:
    if Arch in ['x86sol','sun4sol']:
        target_tools = ['default', 'suncc', 'sunc++', 'sunlink']
    elif env['use_clang'] == False and Arch in ['mingw', 'cygwin', 'winnt']:
        target_tools = ['default', 'msvc']
    else:
        if env['use_clang']:
            target_tools = ['default', 'clang', 'clangxx']
        else:
            target_tools = ['default', 'gcc', 'gnulink']

#if Arch in ['winnt']:
    #c:\tools\msys64\mingw64\bin> mklink mingw32-gcc.exe gcc.exe
    #env = Environment(platform = 'cygwin')
    #env = Environment(platform = 'win32')
#env = DefaultEnvironment(tools = ['msvc'])
# FIXME: Compiler, version, arch are hardcoded, not parametrized
#env = Environment(MSVC_VERSION="14.0", TARGET_ARCH="x86_64")

#if Arch in ['x86sol','sun4sol']:
#    env = Environment(ENV = os.environ, variables = vars, tools=['suncc', 'sunc++', 'sunlink', 'packaging', 'Project', 'colorizer-V1'], toolpath = ['config'])

print('Target tools : ', target_tools)

#'eclipse'
env = Environment(ENV = os.environ, variables = vars, tools = target_tools + ['packaging', 'Project', 'colorizer-V1'], toolpath = ['config'])

#print('Mingw : ', env['use_mingw'])

if env['color']:
    from termcolor import colored, cprint
    print(colored('ENV TOOLS :', 'magenta'), colored(env['TOOLS'], 'cyan'))

if not ('help' in COMMAND_LINE_TARGETS or GetOption('help')) and not ('clean' in COMMAND_LINE_TARGETS or GetOption('clean')) and env['use_conan']: # and Arch not in ['mingw', 'cygwin', 'winnt']:
    conan_flags = SConscript('{}/SConscript_conan'.format(build_directory))
    if not conan_flags:
        print("File `SConscript_conan` is missing.")
        print("It should be generated by running `conan install sample/microsoft/ --build missing`.")
        sys.exit(1)
    flags = conan_flags["conan"]
    #version = flags.pop("VERSION")
    #print("Version :", version)

    print("Conan flags :", flags)
    env.MergeFlags(flags)

if env['color']:
    from termcolor import colored, cprint
    cprint("SCONSTRUCT!", 'red', attrs=['bold'], file=sys.stderr)

system = platform.system()

print("System :", system)
if system == 'Linux' or system.startswith('CYGWIN') or system.startswith('MSYS'):
    if 'TERM' in os.environ:
        env['ENV']['TERM'] = os.environ['TERM']
    if 'PATH' in os.environ:
        env['ENV']['PATH'] = os.environ['PATH']
    if 'HOME' in os.environ:
        env['ENV']['HOME'] = os.environ['HOME']

machine = platform.machine()
print("Machine :", machine)

print("ENV PATH :", env['ENV']['PATH'])

# Allow overriding the compiler with scons CC=???
if 'CC' in ARGUMENTS: env.Replace(CC = ARGUMENTS['CC'])
if 'CXX' in ARGUMENTS: env.Replace(CXX = ARGUMENTS['CXX'])
if 'CCFLAGS' in ARGUMENTS: env.Append(CCFLAGS = ARGUMENTS['CCFLAGS'])
if 'CXXFLAGS' in ARGUMENTS: env.Append(CXXFLAGS = ARGUMENTS['CXXFLAGS'])

ProjectMacro.CheckVars(env)

vars.Update(env)
Help(vars.GenerateHelpText(env))
unknown = vars.UnknownVariables()
if unknown:
    if env['color']:
        print(colored("Unknown variables:", 'red'), colored(list(unknown.keys()), 'red'))
    else:
        print("Unknown variables :", list(unknown.keys()))
    Exit(1)

if env.Verbose():
    if env['color']:
        print(colored("vars :", 'green'), colored(vars.GenerateHelpText(env), 'green'))
    else:
        print("vars :", vars.GenerateHelpText(env))

# Save variables
vars.Save('variables.py', env)

# SCons configuration
SetOption('max_drift', '1') # We are using a local disk
Decider('MD5-timestamp')

AddOption('--createtar', action="store_true",
          help='Trigger the creation of a tar after the build. Must be run with package')

# Paths deduced from sandbox location
env['sandbox'] = Dir("#").srcnode().abspath
if env.Verbose() and env['color']:
    print(colored("sandbox:", 'magenta'), colored(env['sandbox'], 'cyan'))

if 'WORKSPACE' in os.environ:
    env['ENV']['WORKSPACE'] = os.environ['WORKSPACE']
else:
    env['ENV']['WORKSPACE'] = env['sandbox']

try: # /dev/tty not accessible from jenkins
    screen = open('/dev/tty', 'w')
    Progress('$TARGET\r', overwrite=True, file=screen)
except:
    pass

# Ensure no warning is added
def TreatWarningsAsErrors(env): # params: list of archs for which warnings must be treated as errors
    if Arch in ['x86Linux'] and env['gcc_version'] >= '4.6' and not env['use_clang'] and not env['use_clangsa']:
        env.Append(CCFLAGS = ['-Werror'])
        if env['gcc_version'] >= '4.8':
            env.Append(CCFLAGS = ['-Wno-error=maybe-uninitialized'])
    elif Arch in ['sun4sol', 'x86sol']:
        print("Solaris TreatWarningsAsErrors not handled yet")
    elif Arch in ['winnt', 'win']:
        print("Windows TreatWarningsAsErrors not handled yet")

# Disable a warning on a given architecture
# (please, do not abuse of this function and use it with caution)
def DisableWarning(env, arch, warning): # params: - the architecture on which the warning must be removed
                                        #         - the warning to remove
    if arch in ['x86Linux'] and env['gcc_version'] >= '4.6':
        env.Append(CCFLAGS = ['-Wno-' + warning])
    elif arch in ['sun4sol', 'x86sol']:
        print("Solaris DisableWarning not handled yet")
    elif arch in ['winnt']:
        print("Windows DisableWarning not handled yet")

env.AddMethod(DisableWarning, "DisableWarning")

env.AddMethod(TreatWarningsAsErrors, "TreatWarningsAsErrors")

#
# Environment extraction
#########################
# Default values setted when no environment defined (like jenkins)
if env['target'] == 'local':
  DEV_SOURCE_DIR = env['sandbox']
  DEV_BINARY_DIR = os.path.join(env['sandbox'], 'target')
else:
  DEV_SOURCE_DIR = ProjectMacro.getEnvVariable('PROJECT_SRC', os.path.dirname(env['sandbox']))
  DEV_BINARY_DIR = os.path.join(ProjectMacro.getEnvVariable('PROJECT_TARGET_PATH', os.path.dirname(env['sandbox'])), 'sample')

#if re.search('dev\/', DEV_BINARY_DIR):
#  DEV_BINARY_DIR = re.sub(r'dev\/', 'dev_target/', DEV_BINARY_DIR)

if env.Verbose() and env['color']:
    print(colored("DEV_BINARY_DIR:", 'grey'), colored(DEV_BINARY_DIR, 'cyan'))

if env['target'] == 'local':
    PROJECT_THIRDPARTY_PATH = os.path.join(env['sandbox'], 'thirdparty')
else:
    PROJECT_THIRDPARTY_PATH = ProjectMacro.getEnvVariable('PROJECT_THIRDPARTY_PATH', 'thirdparty')

if env.Verbose() and env['color']:
    print(colored("PROJECT_THIRDPARTY_PATH:", 'grey'), colored(PROJECT_THIRDPARTY_PATH, 'cyan'))

# might not WORK in eclipse (hard code it)
PROJECT_JAVA_PATH = ProjectMacro.getEnvVariable('JAVA_HOME', PROJECT_THIRDPARTY_PATH + 'java' + Arch)
if env.Verbose() and env['color']:
    print(colored("PROJECT_JAVA_PATH:", 'grey'), colored(PROJECT_JAVA_PATH, 'cyan'))

env['cache_dir'] = env['cache_path'] + '-' + Arch
if env.Verbose() and env['color']:
    print(colored("env['cache_dir']:", 'magenta'), colored(env['cache_dir'], 'cyan'))
CacheDir(env['cache_dir'])
SConsignFile(os.path.join(DEV_BINARY_DIR, 'scons-signatures' + '-' + Arch))

if env['release'] == 'True':
    if env['color']:
        print(colored("Optimized mode activated", 'blue'))
    theOptDbgFolder = 'opt'+env['Suffix64']
    env.Prepend(CCFLAGS = env['opt_flags'])
    env.Prepend(CCFLAGS = '-DNDEBUG')
    #env.Prepend(CPPDEFINES="NDEBUG")
    if Arch in ['sun4sol','x86sol']:
        env.Prepend(CCFLAGS = '-xlibmil')
        env.Prepend(CCFLAGS = '-xlibmopt')
else:
    if env['color']:
        print(colored("Debug mode activated", 'blue'))
    theOptDbgFolder = 'debug'+env['Suffix64']
    env.Prepend(CCFLAGS = env['debug_flags'])
    env.Prepend(CCFLAGS = '-DDEBUG')

#binaries directory
thePath=os.path.join(DEV_BINARY_DIR, 'bin', Arch)
ProjectMacro.mkdir(thePath)
PROJECT_BINARY_DIR = os.path.abspath(thePath)
#target directories
thePath=os.path.join(DEV_BINARY_DIR, 'target', Arch)
ProjectMacro.mkdir(os.path.join(thePath, theOptDbgFolder))
thePath=os.path.join(DEV_BINARY_DIR, 'include', Arch)
ProjectMacro.mkdir(thePath)
PROJECT_INCLUDE_DIR = os.path.abspath(thePath)
#lib directories
thePath=os.path.join(DEV_BINARY_DIR, 'lib', Arch,theOptDbgFolder)
ProjectMacro.mkdir(thePath)
LIBRARY_STATIC_OUTPUT_PATH = Dir(thePath).srcnode().abspath
thePath=os.path.join(LIBRARY_STATIC_OUTPUT_PATH, 'shared')
ProjectMacro.mkdir(thePath)
LIBRARY_OUTPUT_PATH = Dir(thePath).srcnode().abspath

#if env['target'] == 'local':
#  PROJECT_BINARY_DIR = '.'
#else:
#  PROJECT_BINARY_DIR = os.path.abspath(os.path.join(thePath,theOptDbgFolder))
#  VariantDir(os.path.join(PROJECT_BINARY_DIR,'sample'), 'sample', duplicate=0)

env['LIBRARY_STATIC_OUTPUT_PATH'] = LIBRARY_STATIC_OUTPUT_PATH
env['LIBRARY_OUTPUT_PATH'] = LIBRARY_OUTPUT_PATH
env['PROJECT_BINARY_DIR'] = PROJECT_BINARY_DIR
env['PROJECT_INCLUDE_DIR'] = PROJECT_INCLUDE_DIR

if env.Verbose() and env['color']:
    print(colored("static lib dir:", 'magenta'), colored(LIBRARY_STATIC_OUTPUT_PATH, 'cyan'))
    print(colored("shared lib dir:", 'magenta'), colored(LIBRARY_OUTPUT_PATH, 'cyan'))
    print(colored("bin dir:", 'magenta'), colored(PROJECT_BINARY_DIR, 'cyan'))
    print(colored("include dir:", 'magenta'), colored(PROJECT_INCLUDE_DIR, 'cyan'))

env['CPPPATH'] = [
#    '.',
# published headers
    PROJECT_INCLUDE_DIR,
# 3rd parties
#   os.path.join(PROJECT_THIRDPARTY_PATH,'cppunit',Arch,'include'),
#   os.path.join(PROJECT_THIRDPARTY_PATH,'boost',Arch,'include'),
#   os.path.join(PROJECT_THIRDPARTY_PATH,'zlib',Arch,'include'),
#   os.path.join(PROJECT_THIRDPARTY_PATH,'xerces',Arch,'include'),
#   os.path.join(PROJECT_THIRDPARTY_PATH,'log4cxx',Arch,'include'),
#   os.path.join(PROJECT_THIRDPARTY_PATH,'tao',Arch,'ACE_wrappers'),
#   os.path.join(PROJECT_THIRDPARTY_PATH,'tao',Arch,'ACE_wrappers','TAO'),
#   os.path.join(PROJECT_THIRDPARTY_PATH,'tao',Arch,'ACE_wrappers','TAO','orbsvcs'),
#   os.path.join(PROJECT_THIRDPARTY_PATH,'openssl',Arch,'include'),
# Java path
#    os.path.join(PROJECT_JAVA_PATH, 'include'),
#    os.path.join(PROJECT_JAVA_PATH, 'include',['linux','solaris'][Arch!='x86Linux']),
]

# -L parameter
##############
env["LIBPATH"] = [
#    LIBRARY_STATIC_OUTPUT_PATH,
    LIBRARY_OUTPUT_PATH,
#   os.path.join(PROJECT_THIRDPARTY_PATH,'boost', Arch, 'lib',['','opt/shared'][Arch!='x86Linux']),
#   os.path.join(PROJECT_THIRDPARTY_PATH,'tao', Arch, 'ACE_wrappers','lib'),
#   os.path.join(PROJECT_JAVA_PATH, 'jre','lib',env['java_arch'],'server'),
]

#print "LIBPATH :", env['LIBPATH']
#LD_LIBRARY_PATH=':'.join([os.path.abspath(x) for x in env['LIBPATH']])
#print("LD_LIBRARY_PATH :", LD_LIBRARY_PATH)
textfile = open('path.sh','w')
textfile.writelines('#!/bin/sh\n')
textfile.writelines('#Generated by scons\n')
#textfile.writelines('export LIBPATH=' + LD_LIBRARY_PATH + '\n')
#textfile.writelines('echo LIBPATH : $LIBPATH \n')
#textfile.writelines('exit 0\n')
textfile.close()

env['TAO'] = [
    'ACE',
    'ACE_RMCast',
    'TAO',
    'TAO_BiDirGIOP',
    'TAO_DynamicAny',
    'TAO_DynamicInterface',
    'TAO_IDL_BE',
    'TAO_IDL_FE',
    'TAO_IFR_Client',
    'TAO_IORManip',
    'TAO_IORTable',
    'TAO_Messaging',
    'TAO_PortableServer',
    'TAO_RTCORBA',
    'TAO_RTPortableServer',
    'TAO_SmartProxies',
    'TAO_Strategies',
    'TAO_TypeCodeFactory',
    'TAO_Utils',
    'TAO_CosNaming',
    'TAO_Codeset',
]

#####################################
# 3rd parties versions suffixes
#
Versions = dict([
    ('test_1', '01'),
    ('test_2', '02'),
])
#
#####################################

#### Lists of libs for link
env['MORELibs'] = [
#   'Todo1' + Versions['test_1'],
#   'Todo2' + Versions['test_2'],
    'tibrv'+env['Suffix64'],
    'tibrvcm'+env['Suffix64'],
    'tibrvcmq'+env['Suffix64'],
    'tibrvft'+env['Suffix64'],
    'tibrvcpp'+env['Suffix64'],
    'crypto',
    'xml2',
]

if 'package' in COMMAND_LINE_TARGETS:
    print("Remove nabla-1.2.3 directory")
    env.Execute("rm -Rf nabla-1.2.3")

if env.Verbose() and env['color']:
    print(colored("env: ", 'magenta'), colored(env.Dump(), 'cyan'))

# Clean
Clean('.', 'target')

# mrproper target
def mrproper(env, directory=''):
    scmDataDir = env.Dir('#').path
    scm = None
    while not scm:
        if os.path.exists(scmDataDir+'/.svn'):
            scm = 'svn'
        elif os.path.exists(scmDataDir+'/.git'):
            scm = 'git'
        else:
            up = os.path.dirname(scmDataDir)
            if up != scmDataDir:
                scmDataDir = up
            else:
                print("Looks like this is neither a svn nor a git workspace. I can't mrproper")
                Exit(1)

    launchDir = env.GetLaunchDir()
    directory = os.path.join(launchDir, directory)
    if os.path.exists(directory):
        print("Clean " + directory)
        if scm == 'git':
            subprocess.check_call(['git', 'clean', '-fdxq', directory])
        else:
            for line in subprocess.check_output(['svn', 'status', '--no-ignore', directory], universal_newlines=True).split('\n'):
                match = re.match(r'(?:I|\?)\s+(.*)', line)
                if match:
                    toRemove = match.group(1)
                    try:
                        os.remove(toRemove)
                    except OSError as e:
                        if e.errno == errno.EISDIR or e.errno == errno.EPERM: # Is a directory (on Solaris Sparc & x86: EPERM is thrown on directories)
                            shutil.rmtree(toRemove)
                        elif e.errno == errno.EACCES: # Permission denied
                            if (os.path.isdir(toRemove)): # This stupid windows sends a permission denied when trying to delete a dir
                                import winerror # let's assume we can reach here only on winnt
                                def onRmtreeError(fct, path, excinfo):
                                    e = excinfo[1]
                                    if e.winerror == winerror.ERROR_ACCESS_DENIED:
                                        os.chmod(path, os.stat(path).st_mode | stat.S_IWRITE)
                                        os.remove(path)
                                    else:
                                        raise e
                                shutil.rmtree(toRemove, onerror = onRmtreeError)
                            else:
                                os.chmod(toRemove, os.stat(toRemove).st_mode | stat.S_IWRITE)
                                os.remove(toRemove)
                        else:
                            raise
                    except WindowsError as e:
                        print(e.errno)
    else:
        print("This path does not exist: '%s'" % directory)

env.AddMethod(mrproper, "MrProper")

# remove target
if not ('help' in COMMAND_LINE_TARGETS or GetOption('help')) and ('clean' in COMMAND_LINE_TARGETS or GetOption('clean')):
    if env['color']:
        print(colored("Cache/3rdparties cleaning STARTED:", 'blue'))
    shutil.rmtree(os.path.join(env['sandbox'], '3rdparties'), ignore_errors=True)
    shutil.rmtree(os.path.join(env['sandbox'], 'nabla-1.2.3'), ignore_errors=True)
    shutil.rmtree(os.path.join(env['sandbox'], 'target'), ignore_errors=True)
    shutil.rmtree(os.path.join(env['sandbox'], 'install'), ignore_errors=True)
    shutil.rmtree(env['cache_dir'], ignore_errors=True)
    env.Execute("rm -Rf variables.py " + os.path.join(env['ENV']['WORKSPACE'], "download3rdparties-cache*") + " " + "scons-signatures*.dblite *.tgz *.zip" + " ")
    if env['color']:
        print(colored("Cache/3rdparties cleaning DONE:", 'green'))
    SetOption("clean", 1)
    #Exit(0)

# Initialize KGR build dependencies
if not ('help' in COMMAND_LINE_TARGETS or GetOption('help')) and not ('clean' in COMMAND_LINE_TARGETS or GetOption('clean')):
    if env['color']:
        print(colored("Downloading 3rdparties STARTED:", 'blue'))
    target_dir = os.path.join("3rdparties", Arch)
    from config import download3rdparties
    shutil.rmtree(os.path.join(env['sandbox'], '3rdparties', Arch, 'nabla'), ignore_errors=True)

    if env['bom'] != '':
        print(('python ' + os.path.join('.', 'config', 'download3rdparties.py') + ' --arch=' + Arch + ' --bom=' + os.path.join(os.sep, env['sandbox'], env['bom'])  + ' --third_parties_dir=' + target_dir + ' --color=' + 'True' if env['color'] else 'False'))
        download3rdparties.download(Arch, 64, '', 'http://albandrieu.com/download/cpp-old/', 'http://albandrieu.com/download/cpp/', os.path.join(os.sep, env['sandbox'], env['bom']), target_dir, '', 'True' if env['color'] else 'False')
    if env['color']:
        print(colored("Downloading 3rdparties DONE:", 'green'))
    #Exit(0)

#additional libs for link
env['OSDependentLibs']=[]
if Arch in ['x86sol','sun4sol']:
    env['OSDependentLibs'].extend([ 'posix4','pthread','thread','socket'])

#register the idl builder
ProjectMacro.registerIDLBuilders(env,PROJECT_THIRDPARTY_PATH,Arch)

# Variables visible to SConscripts
Export('env', 'Versions')

#Sconscript calls
if not ('help' in COMMAND_LINE_TARGETS or GetOption('help')) and not ('clean' in COMMAND_LINE_TARGETS or GetOption('clean')):
    env.SConscript([
        'sample/microsoft/src/main/cpp/SConscript',
        'sample/microsoft/src/main/app/SConscript',
        #os.path.join(DEV_SOURCE_DIR, 'sample/microsoft/src/main/cpp/SConscript'),
        #os.path.join(DEV_SOURCE_DIR, 'sample/microsoft/src/main/app/SConscript'),
    ])

# Disable cppunit on Linux for mingw as we do not have mingw librairies of cppunit
if not env['use_mingw'] and not platform.platform().startswith('Linux'):
    env.SConscript(os.path.join(DEV_SOURCE_DIR, 'sample/microsoft/src/test/cpp/SConscript'))
    env.SConscript(os.path.join(DEV_SOURCE_DIR, 'sample/microsoft/src/test/app/SConscript'))

# post build stuff

def finish(target, source, env):
    if GetOption('createtar'):
        import glob
        name = 'nabla'
        arch = Arch
        #if env['legacy_install']:
        arch = {
            'x86Linux' : 'x86Linux',
            'lin'      : 'x86Linux',
            'x86sol'   : 'x86sol',
            'sol'      : 'x86sol',
            'sun4sol'  : 'sun4sol',
            'solsparc' : 'sun4sol',
            'winnt'    : 'winnt',
            'win'      : 'winnt',
        }[arch]
        for tgz in glob.glob('%s*_%s.tgz' % (name, arch)):
            print('Delete old tar ' + tgz)
            os.remove(tgz)
        if 'SVN_REVISION' in env['ENV']:
           rev = 'r%s'%env['ENV']['SVN_REVISION']
        elif 'GIT_COMMIT'  in env['ENV']:
           rev = env['ENV']['GIT_COMMIT']
        else:
            rev = 'rev'
        ver = '_%s'%env['version'] if 'version' in env else ''
        ProjectMacro.createTar(env['tar'], os.path.join('nabla-1.2.3', 'target'), '%s%s_%s_%s.tgz' % (name, ver, rev, arch))

#finishCommand = env.Command('/finish', None, Action(finish, "Starting post build actions"))
#BUILD_TARGETS += finishCommand
#if COMMAND_LINE_TARGETS:
#    Depends(finishCommand, COMMAND_LINE_TARGETS)
#else:
#    Depends(finishCommand, env.GetLaunchDir())

#if 'debian' in COMMAND_LINE_TARGETS:
#    SConscript("config/SConscript")

if 'package' in COMMAND_LINE_TARGETS:
    env.Package( NAME           = 'nabla',
                 VERSION        = '1.2.3',
                 #VERSION        = env['version'],
                 PACKAGEVERSION = 0,
                 PACKAGETYPE    = 'targz',
                 source=[LIBRARY_OUTPUT_PATH, PROJECT_BINARY_DIR],
                 LICENSE        = 'GPL',
                 SUMMARY        = 'Nabla (Backend)',
                 DESCRIPTION    = 'Nabla (Backend)',
                 X_RPM_GROUP    = 'Application/nabla',
                 SOURCE_URL     = 'https://home.nabla.mobi/nabla-1.2.3.tar.gz'
                 #SOURCE_URL     = 'https://home.nabla.mobi/nabla-' + env['version'] + '.tar.gz'
            )

#See http://google-styleguide.googlecode.com/
#os.system('./cpplint.sh')

#TODO : http://v8.googlecode.com/svn/trunk/SConstruct

if not env.Verbose():
   ProjectMacro.reduceBuildVerbosity(env)
else:
   if env['color']:
       print(colored("DEFAULT_TARGETS:", 'magenta'), colored(list(map(str, DEFAULT_TARGETS)), 'cyan'))

#registering function to handle builderrors correctly
#ProjectMacro.registerBuildFailuresAtExit(env)

#Exit(0)

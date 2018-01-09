#################
# Scons build script
######################

import os
import shutil
import re
import platform
import time

from config import ProjectMacro

EnsureSConsVersion(2, 3, 5)
EnsurePythonVersion(2, 7)

#In Eclipse add to scons
#--cache-disable --warn=no-dependency use_system_thirdparties=True gcc_version=5.4.1 CC=clang CXX=clang++ color=True

# To be retrieved automatically
Arch = ProjectMacro.getArch()
print "Arch :", Arch

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

# Command line variables definition
vars = Variables('variables.py') # you can store your defaults in this file
vars.AddVariables(
    BoolVariable('opt', 'Set to true to build with opt flags', True),
    BoolVariable('use_clang', 'On linux only: replace gcc by clang', True),
    BoolVariable('use_clangsa', 'On linux only: replace gcc by whatever clang scan-build provided', False),
    BoolVariable('use_cpp11', 'On linux only: ask to compile using C++11', False),
    BoolVariable('use_gcov', 'On linux only: build with gcov flags', False),
    BoolVariable('color', 'Set to true to build with colorizer', True),
    ('gcc_version', 'Set gcc version to use', '4.8.4'),
    ('install_path', 'Set install path', 'install'),
    ('cache_path', 'Set scons cache path', Dir("#").abspath + '/../../buildcache'),
    ('bom', 'bom location of additional 3rdparties.', ''),
    ('CC', 'Set C compiler', 'gcc'),
    ('CXX', 'Set C++ compiler', 'g++'),
    EnumVariable('target', 'Target platform', 'local', ['default', 'local'])
)
env = DefaultEnvironment(tools = ['gcc', 'gnulink'], CC = '/usr/local/bin/gcc')

if Arch in ['x86sol','sun4sol']:
    env = Environment(tools=['suncc', 'sunc++', 'sunlink'])
    
#'eclipse'
env = Environment(ENV = os.environ, variables = vars, tools = ['default', 'packaging', 'Project', 'colorizer'], toolpath = ['config'])

if env['color']:
    from colorizer import colorizer
    col = colorizer()
    col.colorize(env)
    
system = platform.system()
machine = platform.machine()

print "Platform :", platform.platform()
print ("System : ", system)
print ("Machine : ",machine)

if system == 'Linux' or system == 'CYGWIN_NT-5.1':
    env['ENV']['TERM'] = os.environ['TERM']
    env['ENV']['PATH'] = os.environ['PATH']
    env['ENV']['HOME'] = os.environ['HOME']

#print "ENV PATH :", env['ENV']['PATH']

# Allow overriding the compiler with scons CC=???
if 'CC' in ARGUMENTS: env.Replace(CC = ARGUMENTS['CC'])
if 'CXX' in ARGUMENTS: env.Replace(CXX = ARGUMENTS['CXX'])
if 'CCFLAGS' in ARGUMENTS: env.Append(CCFLAGS = ARGUMENTS['CCFLAGS'])
if 'CXXFLAGS' in ARGUMENTS: env.Append(CXXFLAGS = ARGUMENTS['CXXFLAGS'])

print "ENV TOOLS :", env['TOOLS']
#print "dump whole env :", env.Dump()
print "ENV ENV :", env['ENV']
vars.Update(env)
Help(vars.GenerateHelpText(env))
unknown = vars.UnknownVariables()
if unknown:
    print "Unknown variables :", unknown.keys()
    Exit(1)

print "vars :", vars.GenerateHelpText(env)
# Save variables
vars.Save('variables.py', env)

# SCons configuration
SetOption('max_drift', '1') # We are using a local disk
Decider('MD5-timestamp')

# Paths deduced from sandbox location
env['sandbox'] = Dir("#").srcnode().abspath
print "sandbox :", env['sandbox']
if 'WORKSPACE' in os.environ:
    env['ENV']['WORKSPACE'] = os.environ['WORKSPACE']
else:
	env['ENV']['WORKSPACE'] = env['sandbox']
	
print "CXXVERSION :", env['CXXVERSION']

# Ensure no warning is added
def TreatWarningsAsErrors(env): # params: list of archs for which warnings must be treated as errors
    if Arch in ['x86Linux'] and env['gcc_version'] >= '4.6' and not env['use_clang'] and not env['use_clangsa']:
        env.Append(CCFLAGS = ['-Werror'])
        if env['gcc_version'] >= '4.8':
            env.Append(CCFLAGS = ['-Wno-error=maybe-uninitialized'])
    elif Arch in ['sun4sol', 'x86sol']:
        print "Solaris TreatWarningsAsErrors not handled yet"
    elif Arch in ['winnt', 'win']:
        print "Windows TreatWarningsAsErrors not handled yet"

# Disable a warning on a given architecture
# (please, do not abuse of this function and use it with caution)
def DisableWarning(env, arch, warning): # params: - the architecture on which the warning must be removed
                                        #         - the warning to remove
    if arch in ['x86Linux'] and env['gcc_version'] >= '4.6':
        env.Append(CCFLAGS = ['-Wno-' + warning])
    elif arch in ['sun4sol', 'x86sol']:
        print "Solaris DisableWarning not handled yet"
    elif arch in ['winnt']:
        print "Windows DisableWarning not handled yet"

env.AddMethod(DisableWarning, "DisableWarning")

env.AddMethod(TreatWarningsAsErrors, "TreatWarningsAsErrors")

#
# Environment extraction
#########################
# Default values setted when no environment defined (like jenkins)
if env['target'] == 'local':
  DEV_SOURCE_DIR = env['sandbox']
  DEV_BINARY_DIR = env['sandbox'] + '/target'
else:
  DEV_SOURCE_DIR = ProjectMacro.getEnvVariable('PROJECT_SRC',os.path.dirname(env['sandbox']))
  DEV_BINARY_DIR = ProjectMacro.getEnvVariable('PROJECT_TARGET_PATH',os.path.dirname(env['sandbox'])) + '/sample'

#if re.search('dev\/', DEV_BINARY_DIR):
#  DEV_BINARY_DIR = re.sub(r'dev\/', 'dev_target/', DEV_BINARY_DIR)

print "DEV_BINARY_DIR :", DEV_BINARY_DIR

if env['target'] == 'local':
    PROJECT_THIRDPARTY_PATH = env['sandbox'] + '/thirdparty'
else:
    PROJECT_THIRDPARTY_PATH = ProjectMacro.getEnvVariable('PROJECT_THIRDPARTY_PATH','/thirdparty')

print "PROJECT_THIRDPARTY_PATH :", PROJECT_THIRDPARTY_PATH

# might not WORK in eclipse (hard code it)
PROJECT_JAVA_PATH = ProjectMacro.getEnvVariable('JAVA_HOME', PROJECT_THIRDPARTY_PATH + 'java' + Arch)
print "PROJECT_JAVA_PATH :", PROJECT_JAVA_PATH

#env['cache_path'] = DEV_BINARY_DIR + '/buildcache-' + Arch
print "env['cache_path'] :", env['cache_path']
CacheDir(env['cache_path']+ Arch)
SConsignFile(DEV_BINARY_DIR + '/scons-signatures' + Arch)

#registering function to handle builderrors correctly
ProjectMacro.registerBuildFailuresAtExit()

if env['opt'] == 'True':
    print "opt mode activated"
    theOptDbgFolder = 'opt'+env['Suffix64']
    env.Prepend(CCFLAGS = env['opt_flags'])
    env.Prepend(CCFLAGS = '-DNDEBUG')
    if Arch in ['sun4sol','x86sol']:
        env.Prepend(CCFLAGS = '-xlibmil')
        env.Prepend(CCFLAGS = '-xlibmopt')
else:
    theOptDbgFolder = 'debug'+env['Suffix64']
    env.Prepend(CCFLAGS = env['debug_flags'])
    env.Prepend(CCFLAGS = '-DDEBUG')

#binaries directory
thePath=os.path.join(DEV_BINARY_DIR,'bin',Arch)
ProjectMacro.mkdir(thePath)
PROJECT_BINARY_DIR = os.path.abspath(thePath)
#target directories
thePath=os.path.join(DEV_BINARY_DIR,'target',Arch)
ProjectMacro.mkdir(os.path.join(thePath,theOptDbgFolder))
thePath=os.path.join(DEV_BINARY_DIR,'include',Arch)
ProjectMacro.mkdir(thePath)
PROJECT_INCLUDE_DIR = os.path.abspath(thePath)
#lib directories
thePath=os.path.join(DEV_BINARY_DIR,'lib',Arch,theOptDbgFolder)
ProjectMacro.mkdir(thePath)
LIBRARY_STATIC_OUTPUT_PATH = Dir(thePath).srcnode().abspath
thePath=os.path.join(LIBRARY_STATIC_OUTPUT_PATH,'shared')
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

print "static lib dir :", LIBRARY_STATIC_OUTPUT_PATH
print "shared lib dir :", LIBRARY_OUTPUT_PATH
print "bin dir :", PROJECT_BINARY_DIR
print "include dir :", PROJECT_INCLUDE_DIR

env['CPPPATH'] = [
    '.',
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
    os.path.join(PROJECT_JAVA_PATH,'include'),
    os.path.join(PROJECT_JAVA_PATH,'include',['linux','solaris'][Arch!='x86Linux']),
]

# -L parameter
##############
env["LIBPATH"]     = [
    LIBRARY_STATIC_OUTPUT_PATH,
    LIBRARY_OUTPUT_PATH,
#   os.path.join(PROJECT_THIRDPARTY_PATH,'boost', Arch, 'lib',['','opt/shared'][Arch!='x86Linux']),
#   os.path.join(PROJECT_THIRDPARTY_PATH,'xerces', Arch, 'lib'),
#   os.path.join(PROJECT_THIRDPARTY_PATH,'libxml2', Arch, 'lib'),
#   os.path.join(PROJECT_THIRDPARTY_PATH,'tao', Arch, 'ACE_wrappers','lib'),
#   os.path.join(PROJECT_THIRDPARTY_PATH,'openssl',Arch,'lib'),
#   os.path.join(PROJECT_THIRDPARTY_PATH,'rv', Arch, 'lib'),
#   os.path.join(PROJECT_THIRDPARTY_PATH,'apr',Arch,'lib'),
#   os.path.join(PROJECT_THIRDPARTY_PATH,'apr-util',Arch,'lib'),
#   os.path.join(PROJECT_THIRDPARTY_PATH,'log4cxx', Arch, 'lib'),
#   os.path.join(PROJECT_THIRDPARTY_PATH,'cppunit',Arch,'lib'),
    os.path.join(PROJECT_JAVA_PATH, 'jre','lib',env['java_arch'],'server'),

# 3rd parties
]

#print "LIBPATH :", env['LIBPATH']
LD_LIBRARY_PATH=':'.join([os.path.abspath(x) for x in env['LIBPATH']])
print "LD_LIBRARY_PATH :", LD_LIBRARY_PATH
textfile = file('path.sh','w')
textfile.writelines('#!/bin/sh\n')
textfile.writelines('#Generated by scons\n')
textfile.writelines('export LIBPATH=' + LD_LIBRARY_PATH + '\n')
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
    print "Remove nabla-1.2.3 directory"
    env.Execute("rm -Rf nabla-1.2.3")

# Clean
Clean('.', 'target')

print "sandbox:", env['sandbox']

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
                print "Looks like this is neither a svn nor a git workspace. I can't mrproper"
                Exit(1)

    launchDir = env.GetLaunchDir()
    directory = os.path.join(launchDir, directory)
    if os.path.exists(directory):
        print "Clean " + directory
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
                        print e.errno
    else:
        print "This path does not exist: '%s'" % directory

env.AddMethod(mrproper, "MrProper")

# remove target
if 'clean' in COMMAND_LINE_TARGETS:
    shutil.rmtree(env['sandbox'] + '/3rdparties', ignore_errors=True)
    shutil.rmtree(env['sandbox'] + '/nabla-1.2.3', ignore_errors=True)
    shutil.rmtree(env['sandbox'] + '/target', ignore_errors=True)
    shutil.rmtree(env['sandbox'] + '/install', ignore_errors=True)
    shutil.rmtree(env['ENV']['WORKSPACE'] + '/../buildcache' + Arch, ignore_errors=True)
    env.Execute("rm -Rf " + env['ENV']['WORKSPACE'] + "/download3rdparties-cache* scons-signatures-x86Linux.dblite *.tgz *.zip /tmp/*-kgr-buildinit/ " + env['ENV']['WORKSPACE'] + '/../buildcache' + Arch)
    SetOption("clean", 1)
    #Exit(0)

# Initialize KGR build dependencies
if not GetOption('help') and not GetOption('clean'):
    target_dir = "3rdparties/" + Arch + "/nabla"
    from config import download3rdparties
    shutil.rmtree(env['sandbox'] + '/3rdparties/' + Arch + '/nabla', ignore_errors=True)

    print ("./config/download3rdparties.py" + ' --arch ' + Arch  + ' --bom=' + env['bom']  + ' --third_parties_dir=3rdparties/' + target_dir)
    if env['bom'] != '':    
        download3rdparties.download(Arch, 64, '', 'http://home.nabla.mobi:7072/download/cpp-old/', 'http://home.nabla.mobi:7072/download/cpp/', os.path.join(os.sep, env['sandbox'], env['bom']), target_dir, '')    
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
if not GetOption('help'):
    env.SConscript([
            DEV_SOURCE_DIR+'/sample/microsoft/src/main/cpp/SConscript',
        DEV_SOURCE_DIR+'/sample/microsoft/src/main/app/SConscript',
    ])

SConscript(DEV_SOURCE_DIR+'/sample/microsoft/src/test/cpp/SConscript')
SConscript(DEV_SOURCE_DIR+'/sample/microsoft/src/test/app/SConscript')

#if 'debian' in COMMAND_LINE_TARGETS:
#    SConscript("config/SConscript")

if 'package' in COMMAND_LINE_TARGETS:
    env.Package( NAME           = 'nabla',
                 VERSION        = '1.2.3',
                 PACKAGEVERSION = 0,
                 PACKAGETYPE    = 'targz',
                 source=[LIBRARY_OUTPUT_PATH, PROJECT_BINARY_DIR],
                 LICENSE        = 'misys',
                 SUMMARY        = 'Nabla (Backend)',
                 DESCRIPTION    = 'Nabla (Backend)',
                 X_RPM_GROUP    = 'Application/nabla',
                 SOURCE_URL     = 'https://home.nabla.mobi/nabla-1.2.3.tar.gz'
            )

print "DEFAULT_TARGETS", map(str, DEFAULT_TARGETS)

#See http://google-styleguide.googlecode.com/
#os.system('./cpplint.sh')

#TODO : http://v8.googlecode.com/svn/trunk/SConstruct

print "[Timestamp] FINISH SCONS AT %s" % time.strftime('%H:%M:%S')


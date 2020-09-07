#!/usr/bin/env python3.7
# -*- coding: utf-8 -*-
# SCons tool set-arch.py
import os
import platform
import sys

import ProjectMacro
import SCons.Tool.MSCommon.vc

def generate(env, **kw):

    if env['color']:
        from termcolor import colored, cprint
        cprint('COMPILING OPTIONS!', 'red', attrs=['bold'], file=sys.stderr)

    system = platform.system()
    machine = platform.machine()
    #dist = platform.dist()

    Arch = ProjectMacro.getArch()

    #env['ENV']['SCONS_BUILD'] = '1'
    if env['color']:
        print(colored('Arch :', 'magenta'), colored(Arch, 'cyan'))

    if Arch in ['x86Linux']: # 'cygwin'
        if not 'gcc_version' in env:
            env['gcc_version'] = '8'
            env['gcc_version'] = subprocess.check_output(
                ['gcc', '-dumpversion'],
            )[:3]
        #env['debug_flags'] = '-g'
        #env['debug_flags'] = '-gdwarf-3'
        # Without the '-O0' flag (= do not optimize), we won t be able to print the content of some variables under 'gdb'
        env['debug_flags'] = '-g3'
        env['opt_flags'] = '-O0'
        env['ENV']['PATH'] = '/bin:/usr/bin'
        env['ENV']['LD_LIBRARY_PATH'] = ''

        if 'CLANG' in os.environ:  # set by scan-build
            env['ENV'].update(
                x for x in list(os.environ.items()) if (
                    x[0].startswith('CCC_') or x[0].startswith('CLANG')
                )
            )
            env['use_clangsa'] = True
        if 'use_clangsa' in env and env['use_clangsa']:
            env['CC'] = os.environ.get('CC')
            env['CXX'] = os.environ.get('CXX')
        elif 'use_clang' in env and env['use_clang']:
            env['CC'] = 'clang'
            env['CXX'] = 'clang++'
        else:
            if os.path.exists('/usr/bin/gcc-' + env['gcc_version']):
                env['CC'] = 'gcc-' + env['gcc_version']
            else:
                env['CC'] = 'gcc'
            if os.path.exists('/usr/bin/g++-' + env['gcc_version']):
                env['CXX'] = 'g++-' + env['gcc_version']
            else:
                env['CXX'] = 'g++'

        if Arch == 'x86Linux':
            env['Suffix64'] = '64'
            env['output_folder'] = 'opt64'
            env['java_arch'] = 'amd64'
        else:
            env['Suffix64'] = ''
            env['output_folder'] = 'opt'
            env['java_arch'] = ''

    elif Arch in ['x86sol', 'sun4sol']:
        env['debug_flags'] = '-g0'
        env['opt_flags'] = '-fast'
        if Arch == 'x86sol':
            env['cc_path'] = '/sunpro/sun-studio-12.x86sol_2/SUNWspro/bin'
        else:
            env['cc_path'] = '/sunpro/sun-studio-12/SUNWspro/bin'
        # /opt/SUNWspro/bin:/usr/sfw/bin
        env['ENV']['PATH'] = env['cc_path'] + \
            ':/usr/bin:/usr/sbin:/usr/ccs/bin:/usr/local/bin'
        env['ENV']['LD_LIBRARY_PATH'] = ''
        env['CC'] = 'cc'
        env['CXX'] = 'CC'
        env['Suffix64'] = ''
        env['output_folder'] = 'opt'
        if Arch == 'x86sol':
            env['java_arch'] = 'i386'
        else:
            env['java_arch'] = 'sparc'

    if Arch == 'x86Linux':
        env['CCFLAGS'] = [
            '-g',
            # '-Werror', #Turns all warnings into errors.
            '-Wall',  # Turn on all warnings
            '-fdiagnostics-show-option',  # sonar cxx
            #'-Wl,-z,relro,now',  # Full RELRO
            '-Wformat',
            # Warn about uses of format functions that represent possible security problems
            '-Wformat-security',
            '-Wno-unused-parameter',
            '-Wextra',  # Turn on all extra warnings
            '-Wconversion',
            '-Wsign-conversion',
            '-Wpedantic',
            # '-mmitigate-rop'
            # '-Wunreacheable-code',
            '-ansi',
            '-O3',
            '-fomit-frame-pointer',
            # '-fno-rtti',
            '-fexceptions',
            # '-Wno-deprecated',
            # '-Wno-ctor-dtor-privacy',
            '-Dlinux',
            '-DNDEBUG',  # assert
            '-pedantic',
            '-pedantic-errors',
            # '-fstrict-aliasing',
            '-DACE_HAS_EXCEPTIONS',
            #'-DuseTao',
            '-fPIC',
            # '-D_TEMPLATES_ENABLE_',
            # '-include','/usr/include/stdio.h',
            # '-include','/usr/include/stdlib.h',
            #'-include','/usr/include/c++/' + env['gcc_version'] + '/cstring',
            #'-include','/usr/include/c++/' + env['gcc_version'] + '/typeinfo',
            # '-include','/usr/include/c++/' + env['gcc_version'] + '/memory',    #for auto_ptr
            # '-include','/usr/include/c++/' + env['gcc_version'] + '/algorithm', #for "sort"
        ]

        # If not set, -l order on command lines matter
        env['LINKFLAGS'] = [
            #    '-Wl,--no-as-needed',
            '-Wl,--as-needed',
            '-Wl,--no-allow-shlib-undefined',
        ]

        # export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

        # if env['gcc_version'] >= '4.6' and 'use_cpp11' in env and env['use_cpp11']:
        #    env['CCFLAGS'] += ['-std=c++0x', '-DCPLUSPLUS11']

            # '-std=gnu++98',
            # '-std=gnu++11',
            # '-std=gnu++0x',
            # '-std=c++0x',

        # NOK if env['gcc_version'] >= '4.9' and env['gcc_version'] <= '6':
        if env['gcc_version'] >= '4.9':
            env['LINKFLAGS'] += ['-fdiagnostics-color=always']

        if env['gcc_version'] >= '4.6':
            # not supported yet in gcc 4.1
            env['CCFLAGS'] += ['-Werror=return-type']

        # if env['gcc_version'] >= '4.6' and not env['use_clang'] and not env['use_clangsa']:
        #    env['CCFLAGS'] += ['-Werror']

        # export ASAN_SYMBOLIZER_PATH=/usr/bin/llvm-symbolizer-3.8
        # export ASAN_OPTIONS=alloc_dealloc_mismatch=0,symbolize=1

        # Do not deliver binaries witj use_asan (-fsanitize)

        # Warning mingw do not have asan
        if env['use_clang'] and env['use_asan']:
            env['CCFLAGS'] += ['-fsanitize=address']
            env['LINKFLAGS'] += ['-fsanitize=address', '-lasan']

        if env['gcc_version'] >= '4.8':
            env['CCFLAGS'] += [
                '-D_FORTIFY_SOURCE=2',
                # '-fstack-protector', # Gives warnings
                # '-fstack-protector-strong', # Gives warnings
                '-fstack-protector-all',
                #'-Wno-error=maybe-uninitialized',
                '-Wno-unused-local-typedefs',
                '-Wno-conversion-null',
                '-Wno-invalid-offsetof',
                # '-fmudflap', #http://gcc.gnu.org/wiki/Mudflap_Pointer_Debugging
                # '-pie -fPIE', # For ASLR
            ]

        if not env['use_asan']:
            env['LINKFLAGS'] += ['-Wl,--no-undefined']

        # if env['gcc_version'] >= '5.2':
        #    env['CCFLAGS'] += ['-D_GLIBCXX_USE_CXX11_ABI=0']

        # Activate for debug purpose (when we integrate and we have error with symbols resolutions)
        #env['LINKFLAGS'] = ['-Wl,-z,defs']

        env.Append(CORECFLAGS='-Wextra')

        if 'use_gcov' in env and env['use_gcov']:
            # '-fprofile-generate',
            # '-fprofile-arcs',
            # '-ftest-coverage',
            env['CCFLAGS'] += ['-fprofile-arcs', '-ftest-coverage']
            env['LINKFLAGS'] += ['-lgcov', '--coverage']
            #env['LINKFLAGS'] += ['-g --coverage']

        #env.Append(LINKFLAGS = '-g --coverage')
    elif Arch in ['x86sol', 'sun4sol']:
        env['CCFLAGS'] = [
            '-features=no%conststrings,no%localfor',
            '-DOWTOOLKIT_WARNING_DISABLED',
            '-DP100',
            '-xildoff',
            '-DSYSV',
            '-DSVR4',
            '-Dsolaris',
            '-DANSI_C',
            '-D_TEMPLATES_ENABLE_',
            '-mt',
            '-D_POSIX_THREADS',
            '-D_REENTRANT',
            '-DuseTao',
            '-DACE_HAS_EXCEPTIONS',
        ]
        # If not set, -l order on command lines matter for static librairies
        env['LINKFLAGS'] = [
            '-zrescan',
        ]

    elif Arch in ['mingw', 'cygwin']:
        env['use_mingw'] = True
        #print('Ovverride mingw : ', env['use_mingw'])

    elif Arch in ['winnt']:
        #if not 'gcc_version' in env:
        #    env['gcc_version'] = '10'
        #env['CC'] = 'x86_64-w64-mingw32-gcc.exe'
        env['CC'] = '"C:\\Program Files (x86)\\Microsoft Visual Studio\\2017\\BuildTools\\VC\\Tools\\MSVC\\14.16.27023\\bin\\Hostx86\\x86\\cl.exe"'
        #env['CXX'] = 'x86_64-w64-mingw32-g++.exe'
        env['CXX'] = '"C:\\Program Files (x86)\\Microsoft Visual Studio\\2017\\BuildTools\\VC\Tools\\MSVC\\14.16.27023\\bin\\Hostx86\\x86\\cl.exe"'
        env['LINK'] = '"C:\\Program Files (x86)\\Microsoft Visual Studio\\2017\\Professional\\VC\\Tools\\MSVC\\14.10.24728\\bin\\HostX86\\x86\\link.exe"'

        #if env['opt'] == 'True':
        #    env.Prepend(CPPDEFINES="NDEBUG")
        #    env.Append(CXXFLAGS = '/MD /O2')
        #else:
        #    env.Append(CXXFLAGS = '/MDd /Zi')
        #    env.Append(LINKFLAGS = '/DEBUG:FASTLINK')
        #env['debug_flags'] = [
        #    '/Zd',
        #    '/MDd',
        #]
        #env['opt_flags'] = [
        #    '/O2',
        #    '/GL',
        #    '/MD',
        #]
        env['ENV']['PATH'] = env['ENV']['PATH'] + \
            ';C:\\Program Files\\7-Zip;C:\\tools\\msys64\\mingw64\\bin;'
            #';C:\\Program Files\\7-Zip;C:\\Program Files\\Java\\jre1.8.0_251\\bin;C:\\tools\\msys64\\mingw64\\bin;'

        #env['CCFLAGS'] = [
        #    '/nologo',
        #    '/W3',
        #    '/GX',
        #    '/GR',
        #    '-DWIN',
        #    '-DWIN32',
        #    '-DWINNT',
        #    '-D_WINDOWS',
        #]
        env['LINKFLAGS'] = [
            '-static',
        #    '/nologo',
        #    '/opt:ref',
        #    '/nodefaultlib:libcmt.lib',
        #    '/nodefaultlib:libc.lib',
        #    '/nodefaultlib:libcd.lib',
        #    '/nodefaultlib:libcmtd.lib',
        ]

    if env['use_mingw']:
        #env['target_bits'] = '32'
        #print('Ovverride target_bits :' + env['target_bits'])

        if env['color']:
            print(
                colored('Targetting : ', 'magenta'),
                colored(platform.platform(), 'cyan'),
            )
        else:
            print('Targetting : ' + platform.platform())

        if 'target_bits' in env and env['target_bits'] == '32':
            env['CC'] = 'i686-w64-mingw32-gcc'  # apt-get install gcc-mingw-w64-i686
            env['CXX'] = 'i686-w64-mingw32-g++'  # apt-get install g++-mingw-w64-i686
            env['RANLIB'] = 'i686-w64-mingw32-ranlib'
            env['LD'] = 'i686-w64-mingw32-ld'
            env['LINK'] = 'i686-w64-mingw32-g++'
            env['AR'] = 'i686-w64-mingw32-ar'
            env['AS'] = 'i686-w64-mingw32-as'
            #env['YACC'] = getScriptsPathFromEnv(env) + '/FixedBison.sh'
            if platform.platform() == 'linux':
                env['RC'] = 'i686-w64-mingw32-windres'
                env['RCFLAGS'] = '-I/usr/i686-w64-mingw32/include/' # This is pointing to /usr/share/mingw-w64/include
            #env['RCCOM'] = env['RCCOM'] + ' -DALM_MAJOR=%s -DALM_MIDDLE=%s -DALM_MINOR=%s -DALM_MICRO=%s -DALM_REVISION=%s -DALM_BUILD_YEAR=%s -DALM_BUILD_DATE="%s"' % (
            #    env['ENV']['AF_BUILD_MAJOR_VERSION'],
            #    env['ENV']['AF_BUILD_MIDDLE_VERSION'],
            #    env['ENV']['AF_BUILD_MINOR_VERSION'],
            #    env['ENV']['AF_BUILD_MICRO_VERSION'],
            #    env['ENV']['AF_BUILD_SVN_REVISION'],
            #    env['ENV']['AF_BUILD_YEAR'],
            #    env['ENV']['AF_BUILD_DATE'],
            #    )
        else:
            env['CC'] = 'x86_64-w64-mingw32-gcc'   # apt-get install gcc-mingw-w64-x86-64
            env['CXX'] = 'x86_64-w64-mingw32-g++'   # apt-get install g++-mingw-w64-x86-64
            env['RANLIB'] = 'x86_64-w64-mingw32-ranlib'
            env['LD'] = 'x86_64-w64-mingw32-ld'
            env['LINK'] = 'x86_64-w64-mingw32-g++'
            env['AR'] = 'x86_64-w64-mingw32-ar'
            env['AS'] = 'x86_64-w64-mingw32-as'
            #env['YACC'] = getScriptsPathFromEnv(env) + '/FixedBison.sh'
            # ---------------------------------------------------------------------------------------
            env['RC'] = 'x86_64-w64-mingw32-windres'

            #env.Append(LIBPATH = ['/mingw64/lib'])

    #if 'use_static' in env:
    #    env.Append(LINKFLAGS = "-static")

    #'-mthreads',
    env['CXXFLAGS'] += ['-pthread']
    env['LINKFLAGS'] += ['-pthread']

    if 'use_cpp11' in env and env['use_cpp11']: #env['gcc_version'] >= '8'
        env['LINKFLAGS'] += ['-std=c++11']
        env['CCFLAGS'] += ['-std=c++11']

    if 'target_bits' in env and env['target_bits'] == '32':
        env['CCFLAGS'] += ['-m32']
        env['LINKFLAGS'] += ['-m32']
        # Compile in 32 bits
        #localenv.Prepend(CCFLAGS = ['-m32'])
        #localenv.Prepend(LINKFLAGS = ['-m32'])
    #else:
    #    env['CCFLAGS'] += ['-m64']

    if not 'Suffix64' in env:
        env['Suffix64'] = ''
    if not 'java_arch' in env:
        env['java_arch'] = ''
    if not 'output_folder' in env:
        env['output_folder'] = 'opt'

    if not 'debug_flags' in env:
        env['debug_flags'] = ''
    if not 'opt_flags' in env:
        env['opt_flags'] = ''

    if not 'CXXVERSION' in env:
        env['CXXVERSION'] = env['gcc_version']

    if env['color']:

        print(
            colored('Platform :', 'magenta'),
            colored(platform.platform(), 'cyan'),
        )
        print(colored('System :', 'magenta'), colored(system, 'cyan'))
        print(colored('Machine :', 'magenta'), colored(machine, 'cyan'))
        #print(colored('Dist :', 'magenta'), colored(dist, 'cyan'))
        #print(colored('Dist-Os :', 'magenta'), colored(dist[0], 'cyan'))

        print(colored('ENV TOOLS :', 'magenta'), colored(env['TOOLS'], 'cyan'))
        # print "dump whole env :", env.Dump()
        if env['verbose']:
            print(colored('ENV ENV :', 'magenta'), colored(env['ENV'], 'cyan'))

        if 'TERM' in env:
            print(
                colored('ENV TERM :', 'magenta'),
                colored(env['ENV']['TERM'], 'cyan'),
            )
        print(
            colored('ENV PATH :', 'magenta'),
            colored(env['ENV']['PATH'], 'cyan'),
        )
        if 'HOME' in env:
            print(
                colored('ENV HOME :', 'magenta'),
                colored(env['ENV']['HOME'], 'cyan'),
            )
        print(
            colored('CXXVERSION :', 'magenta'),
            colored(env['CXXVERSION'], 'cyan'),
        )
        print(colored('CC :', 'magenta'), colored(env['CC'], 'cyan'))
        print(colored('CXX :', 'magenta'), colored(env['CXX'], 'cyan'))
        print(
            colored('CCCOM :', 'magenta'),
            colored(env.subst('$CCCOM'), 'cyan'),
        )


def exists(env):
    return 1

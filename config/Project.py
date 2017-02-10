# SCons tool set-arch.py
import os
import ProjectMacro

def generate(env, **kw):
    Arch = ProjectMacro.getArch()

    #env['ENV']['SCONS_BUILD'] = '1'

    if Arch in ['x86Linux','cygwin']:
        if not 'gcc_version' in env:
            env['gcc_version'] = '4.6.3'
        env['debug_flags'] = '-g'
        env['opt_flags'] = '-O'
        env['ENV']['PATH'] = '/bin:/usr/bin'
        env['ENV']['LD_LIBRARY_PATH'] = ''
        if os.path.exists("/usr/bin/gcc-" + env['gcc_version']):
            env['CC'] = 'gcc-' + env['gcc_version']
        else:
            env['CC'] = 'gcc'
        if os.path.exists("/usr/bin/g++-" + env['gcc_version']):
            env['CXX'] = 'g++-' + env['gcc_version']
        else:
            env['CXX'] = 'g++'
        env['CXXVERSION'] = env['gcc_version']
        if Arch=='x86Linux':
            env['Suffix64']='64'
            env['output_folder'] = 'opt64'
            env['java_arch'] = 'amd64'
        else:
            env['Suffix64']=''
            env['output_folder'] = 'opt'
            env['java_arch'] = ''
    elif Arch in ['x86sol','sun4sol']:
        env['debug_flags'] = '-g0'
        env['opt_flags'] = '-fast'
        if Arch=='x86sol':
            env['cc_path'] = '/sunpro/sun-studio-12.x86sol_2/SUNWspro/bin'
        else:
            env['cc_path'] = '/sunpro/sun-studio-12/SUNWspro/bin'
        #/opt/SUNWspro/bin:/usr/sfw/bin
        env['ENV']['PATH'] = env['cc_path'] + ':/usr/bin:/usr/sbin:/usr/ccs/bin:/usr/local/bin'
        env['ENV']['LD_LIBRARY_PATH'] = ''
        env['CC'] = 'cc'
        env['CXX'] = 'CC'
        env['Suffix64']=''
        env['output_folder'] = 'opt'
        if Arch=='x86sol':
            env['java_arch'] = 'i386'
        else:
            env['java_arch'] = 'sparc'
    print "CC is:", env['CC']
    print "CXX is:", env['CXX']

    if Arch == 'x86Linux':
        env['CCFLAGS'] = [
            '-pthread',
            '-g',
            '-Wall',
            #'-Werror',
            '-ansi',
            '-O3',
            #'-fomit-frame-pointer',
            #'-Wno-deprecated',
            #'-Wno-ctor-dtor-privacy',
            '-Dlinux',
            #'-std=gnu++98',
            '-std=gnu++11',
            '-pedantic',
            '-pedantic-errors',
            #'-fprofile-generate',
            #'--coverage',
            #'-fstrict-aliasing',
            '-DACE_HAS_EXCEPTIONS',
            '-DuseTao',
            #'-fPIC',
            #'-D_TEMPLATES_ENABLE_',
            #'-include','/usr/include/stdio.h',
            #'-include','/usr/include/stdlib.h',
            #'-include','/usr/include/c++/' + env['gcc_version'] + '/cstring',
            #'-include','/usr/include/c++/' + env['gcc_version'] + '/typeinfo',
            #'-include','/usr/include/c++/' + env['gcc_version'] + '/memory',    #for auto_ptr
            #'-include','/usr/include/c++/' + env['gcc_version'] + '/algorithm', #for "sort"
        ]
        #Activate for debug purpose (when we integrate and we have error with symbols resolutions)
        #env['LINKFLAGS'] = ['-Wl,-z,defs']
        # If not set, -l order on command lines matter for static librairies
        #env['LINKFLAGS'] = [
        #    '-Wl,--no-as-needed',
        #]
        env.Append(CORECFLAGS = '-Wextra')
        env.Append(LINKFLAGS = '-g --coverage')
    elif Arch in ['x86sol','sun4sol']:
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

    if Arch == 'winnt':
        env['debug_flags'] = [
            '/Zd',
            '/MDd',
        ]
        env['opt_flags'] = [
            '/O2',
            '/GL',
            '/MD',
        ]
        env['ENV']['PATH'] = env['ENV']['PATH'] + ';C:\\Program Files\\7-Zip;C:\\Program Files\\Java\\jre6\\bin'
        env['CCFLAGS'] = [
            '/nologo',
            '/W3',
            '/GX',
            '/GR',
            '-DWIN',
            '-DWIN32',
            '-DWINNT',
            '-D_WINDOWS',
        ]
        env['LINKFLAGS'] = [
            '/nologo',
            '/opt:ref',
            '/nodefaultlib:libcmt.lib',
            '/nodefaultlib:libc.lib',
            '/nodefaultlib:libcd.lib',
            '/nodefaultlib:libcmtd.lib',
        ]

    print "CCCOM is:", env.subst('$CCCOM')

def exists(env):
    return 1

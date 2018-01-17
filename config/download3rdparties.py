#!/usr/bin/env python2.7
# -*- coding: utf-8 -*-
import argparse
import contextlib
import getpass
import glob
import hashlib
import os
import platform
import re
import shutil
import subprocess
import sys
import tempfile
import time
import urllib
import urllib2
import urlparse

sandbox = os.path.abspath(os.path.dirname(os.path.dirname(__file__)))
thirdPartyRoot = '%s/3rdparties' % sandbox

#==============================================================================
# Lock class
#==============================================================================

from contextlib import contextmanager
if os.name == 'nt':
    @contextmanager
    def Lock(lock_file):
        import msvcrt
        import ctypes
        from ctypes.wintypes import BOOL, DWORD, HANDLE

        LOCK_EX = 0x2  # LOCKFILE_EXCLUSIVE_LOCK

        # --- the code is taken from pyserial project ---
        # detect size of ULONG_PTR
        def is_64bit(): return ctypes.sizeof(
            ctypes.c_ulong,
        ) != ctypes.sizeof(ctypes.c_void_p)
        if is_64bit():
            ULONG_PTR = ctypes.c_int64
        else:
            ULONG_PTR = ctypes.c_ulong

        PVOID = ctypes.c_void_p

        # --- Union inside Structure by stackoverflow:3480240 ---
        class _OFFSET(ctypes.Structure):
            _fields_ = [('Offset', DWORD), ('OffsetHigh', DWORD)]

        class _OFFSET_UNION(ctypes.Union):
            _anonymous_ = ['_offset']
            _fields_ = [('_offset', _OFFSET), ('Pointer', PVOID)]

        class OVERLAPPED(ctypes.Structure):
            _anonymous_ = ['_offset_union']
            _fields_ = [
                ('Internal', ULONG_PTR), ('InternalHigh', ULONG_PTR),
                ('_offset_union', _OFFSET_UNION), ('hEvent', HANDLE),
            ]

        LPOVERLAPPED = ctypes.POINTER(OVERLAPPED)

        # --- Define function prototypes for extra safety ---
        LockFileEx = ctypes.windll.kernel32.LockFileEx
        LockFileEx.restype = BOOL
        LockFileEx.argtypes = [
            HANDLE, DWORD,
            DWORD, DWORD, DWORD, LPOVERLAPPED,
        ]
        UnlockFileEx = ctypes.windll.kernel32.UnlockFileEx
        UnlockFileEx.restype = BOOL
        UnlockFileEx.argtypes = [HANDLE, DWORD, DWORD, DWORD, LPOVERLAPPED]

        handle = open(lock_file, 'w')
        hfile = msvcrt.get_osfhandle(handle.fileno())
        LockFileEx(
            hfile, LOCK_EX, 0, 0, 0xFFFF0000,
            ctypes.byref(OVERLAPPED()),
        )
        try:
            yield
        finally:
            UnlockFileEx(hfile, 0, 0, 0xFFFF0000, ctypes.byref(OVERLAPPED()))
            handle.close()

else:
    import fcntl

    @contextmanager
    def Lock(lock_file):
        handle = open(lock_file, 'w')
        fcntl.flock(handle, fcntl.LOCK_EX)
        try:
            yield
        finally:
            fcntl.flock(handle, fcntl.LOCK_UN)
            handle.close()

# Set unbuffered stdout for progress messages
sys.stdout = os.fdopen(sys.stdout.fileno(), 'w', 0)

#==============================================================================


class ThirdParty:

    #--------------------------------------------------------------------------
    def __init__(self, arch, serial, base_url, base_url_old, sandbox_dir, third_parties_dir):
        self._arch = arch
        self._serial = serial
        self._base_url = base_url
        self._base_url_old = base_url_old
        self._sandbox_dir = sandbox_dir
        self._third_parties_dir = third_parties_dir
        user_str = '' if os.name == 'nt' else '-' + getpass.getuser()
        self._cache_dir = '%s/%s-cache%s' % (
            os.getenv(
                'WORKSPACE', tempfile.gettempdir(
                ),
            ), os.path.splitext(os.path.basename(__file__))[0], user_str,
        )
        self.expandLatestKeywords()

    #--------------------------------------------------------------------------
    def info(self, serial=None):
        if not serial:
            serial = self._serial
        serial_as_list = serial.split('/')
        # If the version is 'latest', set the digest as'latest' too
        if serial_as_list[1] == 'latest':
            if len(serial_as_list) == 4:
                serial_as_list[3] = 'latest'
            else:
                # even and especially if it is not explicitly defined
                serial_as_list.append('latest')

        return tuple(serial_as_list)

    #--------------------------------------------------------------------------
    def serial(self, *infos):
        return '/'.join(infos)

    #--------------------------------------------------------------------------
    def expandLatestKeywords(self):
        name, version, pkg_arch, digest = self.info()
        isExpanded = False
        if version == 'latest':
            # C=N;O=D sort on decreasing names -> the first one is want we want
            with contextlib.closing(urllib.urlopen('%s/%s/?C=N;O=D' % (self._base_url, name))) as page:
                for line in page:
                    match = re.search(r'href="([^/]+)/"', line)
                    if match:
                        isExpanded = True
                        version = match.group(1)
                        break
            if version == 'latest':
                raise SystemExit(
                    'Couldn\'t find any existing version for %s' % self._serial,
                )

        if digest == 'latest':
            timestamp = None
            # C=M;O=D sort on decreasing dates -> the first one is want we want
            with contextlib.closing(urllib.urlopen('%s/%s/%s/%s/?C=M;O=D' % (self._base_url, name, version, pkg_arch))) as page:
                for line in page:
                    match = re.search(
                        r'href="([a-f0-9]{32})".*(\d\d-\w\w\w-20\d\d \d\d:\d\d)', line,
                    )
                    if match:
                        isExpanded = True
                        timestamp = time.mktime(time.strptime(
                            match.group(2), '%d-%b-%Y %H:%M',
                        ))
                        digest = match.group(1)
                        break
            if not timestamp:
                raise SystemExit(
                    'Couldn\'t find any matching artifact for %s' % self._serial,
                )

            if isExpanded:
                print self._serial,
                self._serial = self.serial(name, version, pkg_arch, digest)
                print '=> %s (%s)' % (self._serial, time.strftime('%d/%m/%Y %H:%M', time.localtime(timestamp)))

    #--------------------------------------------------------------------------
    def get_serial_from_file(self, filepath):
        with open(filepath) as fic:
            serial = fic.read().strip()
        return serial

    #--------------------------------------------------------------------------
    def download(self):
        name, version, pkg_arch, digest = self.info()

        # Remove old cached file(s)
        for cached in glob.glob('%s/%s-*-%s-*' % (self._cache_dir, name, pkg_arch)):
            if self._arch == 'winnt' or self._arch == 'win':
                # workaround because there is permission issue on winnt
                shutil.rmtree(cached, ignore_errors=True)
            else:
                os.remove(cached)

        # Create directories if needed
        if not os.path.isdir(self._cache_dir):
            os.mkdir(self._cache_dir)
        unchecked_dir = '%s/unchecked' % (self._cache_dir)
        if not os.path.isdir(unchecked_dir):
            os.mkdir(unchecked_dir)

        scheme = urlparse.urlparse(self._base_url)[0]

        download_ok = False
        download_count = 0
        try_number = 3
        pkg = '%s/%s-%s-%s-%s' % (
            self._cache_dir,
            name, version, pkg_arch, digest,
        )
        #pkg           = '%s/%s-%s-%s'%(self._cache_dir, name, version, digest)
        unchecked_pkg = '%s/%s-%s-%s-%s' % (
            unchecked_dir,
            name, version, pkg_arch, digest,
        )
        #unchecked_pkg = '%s/%s-%s-%s'%(unchecked_dir,   name, version, digest)
        while not download_ok:
            print '-> download',
            download_count += 1
            base_urls = [self._base_url, self._base_url_old]
            for base_url in base_urls:
                print 'downloading %s/%s' % (base_url, self._serial)
                name, header = urllib.urlretrieve(
                    '%s/%s' % (base_url, self._serial), unchecked_pkg,
                )
                no_error = True
                # There is no Content-Type when the 3rd party exists
                if (scheme != 'file') and ('Content-Type' in header):
                    error = '-> download failed'
                    # Search in the HTML response what is the error (in the <title> tag)
                    with open(unchecked_pkg) as fic:
                        content = fic.read()
                    match = re.search(r'<title>(.*)</title>', content)
                    if match:
                        print '-> download failed (%s)' % match.group(1)
                        download_ok = False
                        no_error = False
                if no_error:
                    # check that downloaded file has the expected digest
                    with open(unchecked_pkg, 'rb') as fic:
                        content = fic.read()
                    computed_digest = hashlib.md5(content).hexdigest()
                    download_ok = (computed_digest == digest)
                    if not download_ok:
                        print '-> bad md5 (%s)' % computed_digest,
                if download_ok:
                    break
            if not download_ok and download_count >= try_number:
                print '-> ABORT'
                raise SystemExit('Tried to downloaded package %s %s %d times without success' % (
                    name, version, try_number,
                ))

        # package is ok, move it out of unchecked dir
        os.rename(unchecked_pkg, pkg)

    #--------------------------------------------------------------------------
    def get(self):
        name, version, pkg_arch, digest = self.info()
        thirdPartyRoot = '%s/%s' % (self._sandbox_dir, self._third_parties_dir)

        # Create directories if needed
        if not os.path.isdir(thirdPartyRoot):
            os.makedirs(thirdPartyRoot)

        # A previously downloaded package exists and is active. We have to check serial and upgrade it if needed
        name = name.strip()  # Sanity check
        if not name:        # Sanity check
            raise SystemExit('name not defined or empty')
        installed_thirdPartyPath = '%s/%s' % (thirdPartyRoot, name)
        installed_serial_file = '%s/serial' % (installed_thirdPartyPath)
        if os.path.isdir(installed_thirdPartyPath):
            prev_serial = ''
            # Test the serial
            if not os.path.isfile(installed_serial_file):
                print '%s %s: found with missing serial -> remove' % (name, version),
            else:
                prev_serial = self.get_serial_from_file(installed_serial_file)
                if prev_serial == self._serial:
                    return  # package ok, nothing to do
                print '%s %s: found with bad serial -> remove' % (name, version),

            shutil.rmtree(installed_thirdPartyPath)
        else:
            print '%s %s: missing' % (name, version),

        # Nothing to do if a previously downloaded package is available in the right version.
        # If not, have to download it
        #pkg = '%s/%s-%s-%s'%(self._cache_dir, name, version, digest)
        # with Lock('%s-%s'%(self._cache_dir, name)):
        pkg = '%s/%s-%s-%s-%s' % (
            self._cache_dir,
            name, version, pkg_arch, digest,
        )
        with Lock('%s-lock-%s-%s' % (self._cache_dir, name, pkg_arch)):
            if not os.path.exists(pkg):
                self.download()
            else:
                print '-> in cache',
        # Then, create directory and extract
        os.makedirs(installed_thirdPartyPath)
        print '-> extract',
        os.chdir(installed_thirdPartyPath)
        print '-> tar_cmd (%s)' % tar_cmd(),
        if(self._arch == 'winnt' or self._arch == 'win'):
            pkg_dir = '%s_dir' % (pkg)
            if os.path.exists(pkg_dir):
                shutil.rmtree(pkg_dir, ignore_errors=True)
            subprocess.check_call(
                [tar_cmd(), '-y', '-o%s' % (pkg_dir), 'e', pkg], shell=False,
            )
            pkg = '%s/*' % (pkg_dir)
            subprocess.check_call([tar_cmd(), '-y', 'x', pkg], shell=False)
        else:
            subprocess.check_call(
                [tar_cmd(), '-x', '-z', '-f', pkg], shell=False,
            )
        print '-> create serial',
        # and create the serial file
        with open(installed_serial_file, 'w') as fic:
            fic.write(self._serial + '\n')
        print '-> done'


#==============================================================================

#------------------------------------------------------------------------------
def getCurrentArch():
    arch = None
    system = platform.system()
    machine = platform.machine()
    if system == 'Linux':
        arch = 'lin'
    elif system == 'SunOS':
        if machine == 'i86pc':
            arch = 'sol'
        else:
            arch = 'solsparc'
    elif system == 'Windows':
        arch = 'win'
    else:
        raise Exception("Can't find out on which architecture I'm running")
    return arch

#------------------------------------------------------------------------------


def tar_cmd():
    return {
        'x86Linux': '/bin/tar',
        'x86sol': '/usr/sfw/bin/gtar',
        'sun4sol': '/usr/sfw/bin/gtar',
        'winnt': '7z',
        'lin': '/bin/tar',
        'sol': '/usr/sfw/bin/gtar',
        'solsparc': '/usr/sfw/bin/gtar',
        'win': '7z',
        #'win'      : 'bsdtar',
    }[getCurrentArch()]

#------------------------------------------------------------------------------


def getSerialList(bom, arch, bit, compiler, serials):
    serials = serials[:] if serials else []

    print '%s: serials' % (serials)

    # Hack to do as if we were already called with a new arch name
    arch = {
        'x86Linux': 'lin',
        'x86sol': 'sol',
        'sun4sol': 'solsparc',
        'winnt': 'win',
        'lin': 'lin',
        'sol': 'sol',
        'solsparc': 'solsparc',
        'win': 'win',
    }[arch]

    if bom:
        legacy_arch = {  # Stay compatible with serial using old architecture names
            'lin': 'x86Linux',  # 64 bit
            'sol': 'x86sol',  # 32 bit
            'solsparc': 'sun4sol',  # 32 bit
            'win': 'winnt',  # 32 bit
            # TODO: remove when passing new arch names to this prog
            'x86Linux': 'x86Linux',
            'x86sol': 'x86sol',
            'sun4sol': 'sun4sol',
            'winnt': 'winnt',
        }[arch]

        migration_arch = {  # Stay compatible with serial using old architecture names
            'lin': 'x86Linux',  # 64 bit
            'sol': 'x86sol64',  # for migration
            'solsparc': 'sun4sol64',  # for migration
            'win': 'winnt64',  # for migration
            'winnt': 'winnt64',  # for migration
        }[arch]

        print 'bom: %s' % (bom)
        with open(bom) as fic:
            for line in fic:
                if re.match(r'^\s*#', line):
                    pass  # comment: do nothing
                elif re.match(r'^\s*$', line):
                    pass  # empty lines: do nothing
                elif re.search(r'/(%s)/' % legacy_arch, line):
                    line = re.sub(r'#.*', '', line)
                    serials.append(line.strip())
                    print 'serials : %s' % (serials)
                elif re.search(r'/(%s)/' % migration_arch, line):
                    line = re.sub(r'#.*', '', line)
                    serials.append(line.strip())
                    print 'serials : %s' % (serials)
                else:
                    print 'arch : %s' % (arch),
                    match = re.search(
                        r'/(%s|noarch)(-[^_]+)?(_[^/]+)?/' % arch, line,
                    )
                    if match:
                        #serialCompiler = match.group(1)
                        targetArch = match.group(1)
                        print '(match ) targetArch : %s' % (targetArch),
                        serialCompiler = match.group(
                            2,
                        )[1:] if match.group(2) else None
                        print '- serialCompiler : %s' % (serialCompiler),
                        serialDetails = match.group(3).split(
                            '_',
                        )[1:] if match.group(3) else None
                        print '- serialDetails : %s' % (serialDetails)
                        foundBitDetail = False
                        if serialDetails:
                            keepIt = True
                            for serialDetail in serialDetails:
                                if serialDetail in ['32', '64']:
                                    foundBitDetail = True
                                    if bit != serialDetail and not ('32' in serialDetails and '64' in serialDetails):
                                        keepIt = False
                                        break
                            if not keepIt:
                                continue
                        if match.group(1) != 'noarch' and not foundBitDetail:
                            # default means 64 bit
                            if bit == '32':
                                continue
                        if serialCompiler and compiler not in serialCompiler:
                            continue
                        line = re.sub(r'#.*', '', line)
                        serials.append(line.strip())
                    else:
                        print '  (no match) : %s' % (line),
    # Check there is no conflict (same package listed more than once)
    count = {}
    for serial in serials:
        name = serial.split('/')[0]
        count[name] = count[name] + 1 if name in count else 1
    multiple = []
    for name in count:
        if count[name] > 1:
            multiple.append(name)
    if multiple:
        raise SystemExit('ERROR: The following packages are listed more than once in %s: %s\nPlease correct.\n' % (
            bom, ', '.join(sorted(multiple)),
        ))
    return serials

#------------------------------------------------------------------------------


def writeArchBom(serials):
    if not os.path.isdir(thirdPartyRoot):
        os.mkdir(thirdPartyRoot)
    with open('%s/bom' % thirdPartyRoot, 'w') as bom:
        for serial in sorted(serials):
            bom.write(serial + '\n')

#==============================================================================


def generate(env, **kw):
    args = kw.get('args')
    main(args)


def exists(env):
    return 1


def download(arch, bit, compiler, base_url_old, base_url, bom, third_parties_dir, serials):
    # run with already parsed arguments

    # Strangly, the path set by scons is not transfered to os.environ['PATH'], even if it is visible from subprocess.call('set', shell=True)
    if os.name == 'nt':
        # for 64 bit Windows
        os.environ['PATH'] += ';C:\\Program Files (x86)\\GnuWin32\\bin'
        # for 32 bit Windows
        os.environ['PATH'] += ';C:\\Program Files\\GnuWin32\\bin'

    print 'BOM file: %s - %s' % (sandbox, bom)
    if bom != '' and bom != sandbox + '/':
        print 'Initializing build dependencies'
        serials = getSerialList(bom, arch, bit, compiler, serials)
        for serial in serials:
            ThirdParty(
                arch, serial, base_url, base_url_old,
                sandbox, third_parties_dir,
            ).get()
        writeArchBom(serials)
        print 'Build dependencies initialized'


def main(args):
    parser = argparse.ArgumentParser(
        description='Download and expand third parties defined in a .bom file',
    )
    parser.add_argument(
        '--arch',     choices=[
            'lin', 'sol', 'solsparc', 'win', 'x86sol',
            'x86Linux', 'sun4sol', 'winnt',
        ], help='arch on which the build is done', required=True,
    )
    parser.add_argument(
        '--bit',      default='64',
        choices=['32', '64'], help='32 or 64 bit', required=False,
    )
    parser.add_argument(
        '--compiler', default='',
        help='compiler name and version (gcc4, st12, vc11, ...)', required=False,
    )
    parser.add_argument(
        '--base_url_old', default='http://home.nabla.mobi:7072/download/cpp-old/',
        help='Base URL where to download third parties from. Use file:// for using a local ESCROW repository', required=False,
    )
    parser.add_argument(
        '--base_url', default='http://home.nabla.mobi:7072/download/cpp/',
        help='Base URL where to download third parties from. Use file:// for using a local ESCROW repository', required=False,
    )
    parser.add_argument(
        '--bom',      default=None,
        help='file listing serials of third parties to download', required=True,
    )
    parser.add_argument(
        '--third_parties_dir', default='3rdparties',
        help='directory where third parties will be stored', required=False,
    )
    parser.add_argument(
        '--serials',  action='append',
        help='directly specify some serials (multiple uses are possible', required=False,
    )

    args = parser.parse_args(args)
    if args.third_parties_dir == parser.get_default('third_parties_dir'):
        args.third_parties_dir = '%s/%s' % (args.third_parties_dir, args.arch)

    # parse sys.argv[1:] using optparse or argparse or what have you
    download(
        args.arch, args.bit, args.compiler, args.base_url_old,
        args.base_url, args.bom, args.third_parties_dir, args.serials,
    )


if __name__ == '__main__':
    import sys
    main(sys.argv[1:])

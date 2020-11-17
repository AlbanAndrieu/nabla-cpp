#!/bin/bash
#set -xv
shopt -s extglob

#set -ueo pipefail
set -eo pipefail

WORKING_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}"  )" && pwd  )"

# shellcheck source=/dev/null
source "${WORKING_DIR}/../step-0-color.sh"

#sudo apt-get install q4wine winbind winetricks playonlinux wine-binfmt dosbox exe-thumbnailer | kio-extras wine64-preloader
#sudo apt-get install wine32

/usr/bin/wine --version

#deleting current prefix
#rm -rf ~/.wine
#Or
#WINEPREFIX=newlocation winecfg

/usr/bin/wine notepad
winepath c:\\
#wine target/bin/x86Linux/run_app.exe

#find /usr -iname "gdi32.dll.so"

#wine reg add HKCU\\Environment /v PATH /d "z:\\usr\\$PRE\\bin;z:\\usr\\local\\$PRE\\bin" /f with PRE=x86_64-w64-mingw32
#
# If you want your MinGW-generated windows binaries to work under wine out-of-the-box
# (and they are not statically linked), you can instruct wine
# to automatically search for dll-s by running:
#     wine regedit
# Nagivate to:
#     [HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment]
# or
#     [HKEY_CURRENT_USER\Environment]
# and add
#     Z:\usr\lib\gcc\x86_64-w64-mingw32\9.3-posix\
# to the 'PATH' variable.

WINEDEBUG=-all wine target/bin/x86Linux/run_app.exe

winecfg
#add a drive W with
/workspace/users/albandrieu30
# Test it
winepath -w target/bin/x86Linux
#/home/albandrieu/.wine/dosdevices/w:/nabla-cpp/target/bin/x86Linux
WINEPATH=anything\\it//willNotBeParsed wine cmd
echo %PATH%
wine Z:\\workspace\\users\\albandrieu30\\nabla-cpp\\target\\bin\\x86Linux\\run_app

WINEPREFIX=target/bin/x86Linux/ WINEARCH=win32 wine target/bin/x86Linux/run_app.exe
WINEPREFIX=target/bin/x86Linux/ winecfg
WINEPREFIX=target/bin/x86Linux/ wine control
WINEPREFIX=target/bin/x86Linux/ winetricks

exit 0

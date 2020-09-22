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
#wine Almonde.exe

#find /usr -iname "gdi32.dll.so"

exit 0

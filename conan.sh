#!/bin/bash
#set -xv
#set -eu

WORKING_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}"  )" && pwd  )"

# shellcheck source=/dev/null
source "${WORKING_DIR}/scripts/step-0-color.sh"

source "${WORKING_DIR}/scripts/step-2-0-0-build-env.sh" || exit 1
WORKING_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}"  )" && pwd  )"

#rm -Rf /home/albandrieu/.conan/data/boost_system/

echo -e "${cyan} ${double_arrow} Conan install ${NC}"

conan user
conan remote add nabla https://api.bintray.com/conan/bincrafters/public-conan || true
conan user -r nabla albanandrieu

#conan profile new test --detect
conan profile new nabla --detect

echo -e "${green} Using CONAN ${happy_smiley} ${NC}"

#conan profile remove settings.compiler.libcxx nabla

#libstdc++: Old ABI.
#libstdc++11: New ABI.
echo -e "${magenta} conan profile update settings.compiler.libcxx=libstdc++11 nabla ${NC}"
conan profile update settings.compiler.libcxx=libstdc++11 nabla
conan profile show nabla

conan profile list

#See https://conan.io/
#See https://bintray.com/bincrafters/public-conan

if [ "${ENABLE_CLANG}" == "true" ]; then

    if [ "$(uname -s)" == "Linux" ]; then

        case $(uname -m) in
        x86_64)
            echo -e "${green} ENABLE_CLANG is undefined, using CONAN ${happy_smiley} ${NC}"

            #conan install ../microsoft/ -s os="Linux" -s compiler="gcc"
            ##conan install ../microsoft/ -s os="Linux" -s compiler="clang"
            ##conan install ../microsoft/ boost/1.67.0@conan/stable -s compiler.version=8
            conan profile update settings.compiler=clang nabla

            ;;
        i*86)
            ;;
        *)
            # leave ARCH as-is
            ;;
        esac

    fi
elif [ "${ENABLE_MINGW_64}" == "true" ]; then

    if [ "$(uname -s)" == "Linux" ]; then
        # See https://docs.conan.io/en/latest/systems_cross_building/cross_building.html
        #conan profile new nabla_msys2_mingw

        #conan install ../microsoft/ --build=boost*@conan/stable -pr ../nabla_msys2_mingw_linux
        echo -e "${magenta} See profile : ${WORKING_DIR}/sample/nabla_msys2_mingw_linux ${NC}"

    elif [ "$(uname -s)" == "MINGW64_NT-10.0-17763" ]; then
        conan install mingw_installer/1.0@conan/stable -if ./sample/build-${ARCH}
        #conan install mingw_installer/1.0@conan/stable -s settings.compiler.libcxx=libc++  -s settings.compiler=gcc -s build_type=Debug
        #conan install mingw_installer/1.0@conan/stable -s compiler=gcc -s compiler.version=10
    fi
else  # GCC

    if [ "$(uname -s)" == "MINGW64_NT-10.0-17763" ]; then
        # See https://docs.conan.io/en/latest/systems_cross_building/windows_subsystems.html
        conan profile new nabla_msys2_mingw --detect
    	# Windows
    	#conan profile update settings.compiler="Visual Studio" nabla
    	#conan profile update settings.compiler.runtime=MD nabla
    	#conan profile update settings.compiler.version=15 nabla
    	conan profile update settings.compiler=gcc nabla_msys2_mingw
    	conan profile update settings.compiler.version=10 nabla_msys2_mingw
    elif [ "$(uname -s)" == "Linux" ]; then
    	conan profile update settings.compiler=gcc nabla
    	echo -e "${magenta} conan profile update settings.compiler.version=8 nabla ${NC}"
    	conan profile update settings.compiler.version=8 nabla
    fi

fi

if [ "$(uname -s)" == "Linux" ]; then
	#ls -lrta $HOME/.conan/profiles
	echo -e "${magenta} conan profile update settings.compiler.version=8 default ${NC}"
	conan profile update settings.compiler.version=8 default
	echo -e "${magenta} conan profile update settings.compiler.libcxx=libstdc++11 default ${NC}"
	conan profile update settings.compiler.libcxx=libstdc++11 default
fi
conan profile show default

export CONAN_GENERATOR=${CONAN_GENERATOR:-"scons"}
echo -e "${green} Using CONAN_GENERATOR : ${CONAN_GENERATOR} ${happy_smiley} ${NC}"

if [ "$(uname -s)" == "MINGW64_NT-10.0-17763" ]; then
    case $(uname -m) in
    x86_64)
        echo -e "${magenta} conan install ${WORKING_DIR}/sample/microsoft/ --build -g ${CONAN_GENERATOR} -if ./sample/build-${ARCH} ${NC}"
        echo -e "${magenta} conan install ${WORKING_DIR}/sample/microsoft/ --build boost -g ${CONAN_GENERATOR} -if ./sample/build-${ARCH} ${NC}"
        echo -e "${magenta} conan install ${WORKING_DIR}/sample/microsoft/ --build missing -g ${CONAN_GENERATOR} -if ./sample/build-${ARCH} ${NC}"
        conan install ${WORKING_DIR}/sample/microsoft/ --build missing -g ${CONAN_GENERATOR} -if ./sample/build-${ARCH}

        ;;
    i*86)
        ;;
    *)
        # leave ARCH as-is
        ;;
    esac
elif [ "${ENABLE_MINGW_64}" == "true" ]; then
    if [ "$(uname -s)" == "Linux" ]; then
        # See https://docs.conan.io/en/latest/systems_cross_building/cross_building.html
        #conan profile new nabla_msys2_mingw

        #conan install ../microsoft/ --build=boost*@conan/stable -pr ../nabla_msys2_mingw_linux
        echo -e "${magenta} conan install ${WORKING_DIR}/sample/microsoft/ --build=missing -pr ${WORKING_DIR}/sample/nabla_msys2_mingw_linux -if ./sample/build-${ARCH} ${NC}"
        conan install ${WORKING_DIR}/sample/microsoft/ --build=boost -pr ${WORKING_DIR}/sample/nabla_msys2_mingw_linux -if ./sample/build-${ARCH}
        #-s zlib:compiler="MinGW"
    fi
elif [ "$(uname -s)" == "Linux" ]; then

    case $(uname -m) in
    x86_64)
        echo -e "${green} Using CONAN ${happy_smiley} ${NC}"
        #conan remote add nabla https://api.bintray.com/conan/bincrafters/public-conan || true
        #conan user -p 24809e026911e16eaa40b63acbf05eaec557d963 -r nabla albanandrieu

        #conan install ../microsoft/ -s os="Linux" -s compiler="gcc"
        ##conan install ../microsoft/ boost/1.67.0@conan/stable -s compiler.version=6.4
        #conan install boost_system/1.66.0@bincrafters/stable --build boost_system
        echo -e "${magenta} conan install ${WORKING_DIR}/sample/microsoft/ --build -g ${CONAN_GENERATOR} -if ./sample/build-${ARCH} ${NC}"
        echo -e "${magenta} conan install ${WORKING_DIR}/sample/microsoft/ --build boost -g ${CONAN_GENERATOR} -if ./sample/build-${ARCH} ${NC}"
        #conan install ${WORKING_DIR}/sample/microsoft/ --build boost_system
        echo -e "${magenta} conan install ${WORKING_DIR}/sample/microsoft/ --build missing -g ${CONAN_GENERATOR} -if ./sample/build-${ARCH} ${NC}"
        conan install ${WORKING_DIR}/sample/microsoft/ --build missing -g ${CONAN_GENERATOR} -if ./sample/build-${ARCH}
        # below you can download it IF available
        #conan install ${WORKING_DIR}/sample/microsoft/
        #conan info${WORKING_DIR}/sample/microsoft/ --graph=file.html

        ;;
    i*86)
        ;;
    *)
        # leave ARCH as-is
        ;;
    esac

fi

conan_res=$?
if [[ $conan_res -ne 0 ]]; then
    echo -e "${red} ---> Conan failed : $conan_res ${NC}"
    exit 1
fi

conan profile list
conan config home

echo -e "${magenta} conan configuration : ${NC}"
find . -name conanfile.txt

echo -e "${magenta} conan generated files : ${NC}"
find . -name conaninfo.txt
#ls -lrta sample/microsoft/conaninfo.txt
find . -name conanbuildinfo.cmake
#ls -lrta sample/build-linux/conanbuildinfo.cmake

exit 0

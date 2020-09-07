#!/bin/bash
#set -xv
#set -eu

WORKING_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}"  )" && pwd  )"

# shellcheck source=/dev/null
source "${WORKING_DIR}/step-0-color.sh"

#rm -Rf /home/albandrieu/.conan/data/boost_system/

echo -e "${cyan} ${double_arrow} Conan install ${NC}"

conan user
conan remote add nabla https://api.bintray.com/conan/bincrafters/public-conan || true
conan user -r nabla albanandrieu

#conan profile new test --detect
conan profile new nabla --detect

#conan profile remove settings.compiler.libcxx nabla

#conan install mingw_installer/1.0@conan/stable
#conan install mingw_installer/1.0@conan/stable -s settings.compiler.libcxx=libc++  -s settings.compiler=gcc -s build_type=Debug
#conan install mingw_installer/1.0@conan/stable -s compiler=gcc -s compiler.version=10

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
	conan profile update settings.compiler.version=8 nabla
fi

#libstdc++: Old ABI.
#libstdc++11: New ABI.
echo -e "${magenta} conan profile update settings.compiler.libcxx=libstdc++11 default ${NC}"
conan profile update settings.compiler.libcxx=libstdc++11 nabla
conan profile show nabla

conan profile list

#echo -e "${magenta} conan profile update settings.compiler.libcxx=libstdc++11 default ${NC}"
echo -e "${magenta} conan profile update settings.compiler.version=8 default ${NC}"

if [ "$(uname -s)" == "Linux" ]; then
	#ls -lrta $HOME/.conan/profiles
	conan profile update settings.compiler.version=8 default
fi

conan profile show default

#See https://conan.io/
#See https://bintray.com/bincrafters/public-conan

if [ -n "${ENABLE_CLANG}" ]; then

    if [ "$(uname -s)" == "Linux" ]; then

        case $(uname -m) in
        x86_64)
            echo -e "${green} ENABLE_CLANG is undefined, using CONAN ${happy_smiley} ${NC}"

            #conan install ../microsoft/ -s os="Linux" -s compiler="gcc"
            ##conan install ../microsoft/ -s os="Linux" -s compiler="clang"
            ##conan install ../microsoft/ boost/1.67.0@conan/stable -s compiler.version=8

            ;;
        i*86)
            ;;
        *)
            # leave ARCH as-is
            ;;
        esac

    fi

fi

export CONAN_GENERATOR=${CONAN_GENERATOR:-"scons"}
echo -e "${green} Using CONAN_GENERATOR : ${CONAN_GENERATOR} ${happy_smiley} ${NC}"

if [ "$(uname -s)" == "MINGW64_NT-10.0-17763" ]; then
    case $(uname -m) in
    x86_64)
        echo -e "${green} Using CONAN ${happy_smiley} ${NC}"
        conan profile list
        conan profile update settings.compiler.libcxx=libstdc++11 default

        echo -e "${magenta} conan install ${WORKING_DIR}/sample/microsoft/ --build boost_system -g ${CONAN_GENERATOR} ${NC}"
        #conan install ${WORKING_DIR}/sample/microsoft/ --build boost_system
        echo -e "${magenta} conan install ${WORKING_DIR}/sample/microsoft/ --build missing -g ${CONAN_GENERATOR} ${NC}"
        conan install ${WORKING_DIR}/sample/microsoft/ --build missing -g ${CONAN_GENERATOR}

        ;;
    i*86)
        ;;
    *)
        # leave ARCH as-is
        ;;
    esac

elif [ "$(uname -s)" == "Linux" ]; then

    case $(uname -m) in
    x86_64)
        echo -e "${green} Using CONAN ${happy_smiley} ${NC}"
        #conan remote add nabla https://api.bintray.com/conan/bincrafters/public-conan || true
        #conan user -p 24809e026911e16eaa40b63acbf05eaec557d963 -r nabla albanandrieu

        #conan install ../microsoft/ -s os="Linux" -s compiler="gcc"
        ##conan install ../microsoft/ boost/1.67.0@conan/stable -s compiler.version=6.4
        #conan install boost_system/1.66.0@bincrafters/stable --build boost_system
        echo -e "${magenta} conan install ${WORKING_DIR}/sample/microsoft/ --build boost_system -g ${CONAN_GENERATOR} ${NC}"
        #conan install ${WORKING_DIR}/sample/microsoft/ --build boost_system
        echo -e "${magenta} conan install ${WORKING_DIR}/sample/microsoft/ --build missing -g ${CONAN_GENERATOR} ${NC}"
        conan install ${WORKING_DIR}/sample/microsoft/ --build missing -g ${CONAN_GENERATOR}
        # below you can download it IF available
        #conan install ${WORKING_DIR}/sample/microsoft/
        #conan info${WORKING_DIR}/sample/microsoft/ --graph=file.html

        conan profile list
        conan profile update settings.compiler.libcxx=libstdc++11 default

        ;;
    i*86)
        ;;
    *)
        # leave ARCH as-is
        ;;
    esac

fi

conan config home

ls -lrta sample/microsoft/conaninfo.txt
ls -lrta sample/build-linux/conanbuildinfo.cmake

exit 0

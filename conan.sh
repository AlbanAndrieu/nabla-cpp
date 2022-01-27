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
#conan create . user/channel --build missing
echo -e "${cyan} conan config install https://github.com/conan-io/conanclientcert.git ${NC}"
# See deprecated https://docs.conan.io/en/latest/uploading_packages/remotes.html#conancenter
echo -e "${cyan} conan remote add conan-center https://center.conan.io ${NC}"
echo -e "${cyan} conan remote add conan-community https://api.bintray.com/conan/conan-community/conan ${NC}"
#conan search Boost* -r=conan-community
echo -e "${cyan} conan search boost* -r=conan-center ${NC}"
echo -e "${cyan} conan search \"boost/1.71.0\" -r=all ${NC}"
echo -e "${magenta} Upgrade boost ${NC}"
# See https://github.com/conan-io/conan-center-index/issues/799
echo -e "${magenta} conan install ../microsoft/ --build=boost/1.71.0 ${NC}"
#conan remote add nabla https://api.bintray.com/conan/bincrafters/public-conan || true
#conan remote remove nabla
#conan remote update bincrafters https://bincrafters.jfrog.io/artifactory/api/conan/public-conan || true
echo -e "${cyan} conan upload \"*\" -r nabla --all ${NC}"
conan user -r nabla albanandrieu

#conan profile new test --detect
conan profile new default --detect
conan profile show default

echo -e "${green} Using CONAN profile nabla ${happy_smiley} ${NC}"

conan profile new nabla --detect
conan profile show nabla

echo -e "${green} Lising CONAN profile before change ${happy_smiley} ${NC}"

conan profile list

if [ "$OSTYPE" == "linux" ]; then
  #libstdc++: Old ABI.
  #libstdc++11: New ABI.
  echo -e "${magenta} conan profile update settings.compiler.libcxx=libstdc++11 nabla ${NC}"
  conan profile update settings.compiler.libcxx=libstdc++11 nabla
fi

if [ "${ENABLE_CLANG}" == "true" ]; then

  if [ "$(uname -s)" == "Linux" ]; then

    case $(uname -m) in
    x86_64)
      echo -e "${green} ENABLE_CLANG is undefined, using CONAN ${happy_smiley} ${NC}"

      #conan install ../microsoft/ -s os="Linux" -s compiler="gcc"
      ##conan install ../microsoft/ -s os="Linux" -s compiler="clang"
      ##conan install ../microsoft/ boost/1.69.0@conan/stable -s compiler.version=8
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
    #conan profile update settings.compiler.version=16 nabla
    conan profile update settings.compiler=gcc nabla_msys2_mingw
    conan profile update settings.compiler.version=10 nabla_msys2_mingw
  elif [ "$(uname -s)" == "Linux" ]; then
    echo -e "${magenta} conan profile update settings.compiler=gcc default ${NC}"
    #conan profile remove settings.compiler.libcxx nabla
    conan profile update settings.compiler=gcc default
    echo -e "${magenta} conan profile update settings.compiler=gcc nabla ${NC}"
    conan profile update settings.compiler=gcc nabla
    echo -e "${magenta} conan profile update settings.compiler.version=8 default ${NC}"
    conan profile update settings.compiler.version=8 default
    echo -e "${magenta} conan profile update settings.compiler.version=8 nabla ${NC}"
    conan profile update settings.compiler.version=8 nabla
    echo -e "${magenta} conan profile update settings.compiler.libcxx=libstdc++11 default ${NC}"
    conan profile update settings.compiler.libcxx=libstdc++11 default
  fi

fi

#if [ "$(uname -s)" == "Linux" ]; then
if [ "$OSTYPE" == "linux" ]; then
  echo -e "${green} Using CONAN linux ${happy_smiley} ${NC}"
  #ls -lrta $HOME/.conan/profiles
  #conan profile update settings.compiler=clang nabla
  echo -e "${magenta} conan profile update settings.compiler.version=8 default ${NC}"
  conan profile update settings.compiler.version=8 default
  echo -e "${magenta} conan profile update settings.compiler.libcxx=libstdc++11 default ${NC}"
  #conan profile update settings.compiler.libcxx=libstdc++11 default
elif [ "$OSTYPE" == "msys" ]; then
  echo -e "${green} Using CONAN msys ${happy_smiley} ${NC}"
  echo -e "${magenta} conan profile update settings.compiler=\"Visual Studio\" default ${NC}"
  conan profile update settings.compiler="Visual Studio" default
  echo -e "${magenta} conan profile update settings.runtime=MD default ${NC}"
  conan profile update settings.compiler.runtime=MD default
  echo -e "${magenta} conan profile update settings.compiler.version=16 default ${NC}"
  conan profile update settings.compiler.version=16 default
fi

echo -e "${green} Lising CONAN profile after change ${happy_smiley} ${NC}"

conan profile list
conan profile show default
conan profile show nable

export CONAN_GENERATOR=${CONAN_GENERATOR:-"scons"}
echo -e "${green} Using CONAN_GENERATOR : ${CONAN_GENERATOR} ${happy_smiley} ${NC}"

#if [ "$(uname -s)" == "MINGW64_NT-10.0-17763" -o "$(uname -s)" == "MSYS_NT-10.0-17763" ]; then
if [ "$OSTYPE" == "msys" ]; then
  echo -e "${green} Using CONAN install msys ${happy_smiley} ${NC}"
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
  echo -e "${green} Using CONAN install mingw ${happy_smiley} ${NC}"
  if [ "$(uname -s)" == "Linux" ]; then
    # See https://docs.conan.io/en/latest/systems_cross_building/cross_building.html
    #conan profile new nabla_msys2_mingw

    #conan install ../microsoft/ --build=boost*@conan/stable -pr ../nabla_msys2_mingw_linux
    echo -e "${magenta} conan install ${WORKING_DIR}/sample/microsoft/ --build=missing -pr ${WORKING_DIR}/sample/nabla_msys2_mingw_linux -if ./sample/build-${ARCH} ${NC}"
    conan install ${WORKING_DIR}/sample/microsoft/ --build=boost -pr ${WORKING_DIR}/sample/nabla_msys2_mingw_linux -if ./sample/build-${ARCH}
    #-s zlib:compiler="MinGW"
  fi
elif [ "$(uname -s)" == "Linux" ]; then
  echo -e "${green} Using CONAN install Linux ${happy_smiley} ${NC}"
  case $(uname -m) in
  x86_64)
    #conan remote add nabla https://api.bintray.com/conan/bincrafters/public-conan || true
    #conan user -p 24809e026911e16eaa40b63acbf05eaec557d963 -r nabla albanandrieu

    #conan install ../microsoft/ -s os="Linux" -s compiler="gcc"
    ##conan install ../microsoft/ boost/1.69.0@conan/stable -s compiler.version=6.4
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

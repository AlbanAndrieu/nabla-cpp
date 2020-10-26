#!/bin/bash
#set -xv

if [ "$0" = "${BAHS_SOURCE[0]}" ]; then
    echo "This script has to be sourced and not executed..."
    exit 1
fi

WORKING_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}"  )" && pwd  )"

# shellcheck source=/dev/null
source "${WORKING_DIR}/step-0-color.sh"

# shellcheck disable=SC2154
echo -e "${yellow} ${bold} WELCOME ${nabla_logo} ${NC}"

# shellcheck disable=SC2154
echo -e "${ltgray} HOSTNAME : ${HOSTNAME} ${NC}"
# shellcheck disable=SC2154
echo -e "${cyan} SHELL : ${SHELL} ${NC}"
echo -e "${cyan} TERM : ${TERM} ${NC}"
echo -e "${cyan} HOME : ${HOME} ${NC}"
echo -e "${cyan} USER : ${USER} ${NC}"
# shellcheck disable=SC2154
echo -e "${blue} PATH : ${PATH} ${NC}"

# shellcheck disable=SC2154
echo -e "${green} ARCH : ${ARCH} ${NC}"
echo -e "${green} WORKSPACE_SUFFIX : ${WORKSPACE_SUFFIX} ${NC}"
echo -e "${green} GIT_BRANCH_NAME : ${GIT_BRANCH_NAME} ${NC}"
echo -e "${green} GIT_BRANCH : ${GIT_BRANCH} ${NC}"
echo -e "${green} GIT_COMMIT : ${GIT_COMMIT} ${NC}"

# shellcheck disable=SC2154
echo -e "${magenta} ${underline}PARAMETERS ${NC}"

# shellcheck source=./step-1-os.sh
source "${WORKING_DIR}/step-1-os.sh"

# shellcheck source=/dev/null
if [ -z "${HOME}/run-python.sh" ]; then
  source "${HOME}/run-python.sh"
fi

WORKING_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}"  )" && pwd  )"

#DRY_RUN is used on UAT in order to avoid TAGING or DEPLOYING to production
if [ -n "${DRY_RUN}" ]; then
  # shellcheck disable=SC2154
  echo -e "${green} DRY_RUN is defined ${happy_smiley} : ${DRY_RUN} ${NC}"
else
  # shellcheck disable=SC2154
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : DRY_RUN, please override ${NC}"
fi

if [ -z "$PATH" ]; then
  if [ "$(uname -s)" == "SunOS" ]; then
    echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : PATH, use default one ${NC}"
    #Please do not enable NFS share on build server.
    #In case of NFS share issue we will not be able to perform an HF
    #/opt/SUNWspro/bin
    #mount
    #PATH=/usr/local/bin:/usr/sbin:/usr/bin:/bin:/usr/ccs/bin:${SUNSTUDIO_HOME}/bin:/usr/sfw/bin:/opt/csw/bin; export PATH
    exit 1
  fi
fi

if [ -z "$TMPDIR" ]; then
    TMPDIR="/var/tmp/"
    export TMPDIR
    echo -e "${magenta} TMPDIR : ${TMPDIR} ${NC}"
fi

if [ -z "$SUNSTUDIO_HOME" ]; then
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : SUNSTUDIO_HOME, use default one ${NC}"
  if [ "$(uname -s)" == "SunOS" ]; then
    #SUNSTUDIO_HOME="/opt/solarisstudio12.3"
    #SUNSTUDIO_HOME="/rms/sunpro/sun-studio-12/SUNWspro"
    SUNSTUDIO_HOME="/opt/SUNWspro"
    export SUNSTUDIO_HOME
    echo -e "${magenta} SUNSTUDIO_HOME : ${SUNSTUDIO_HOME} ${NC}"
  fi
fi

if [ "$(uname -s)" == "SunOS" ]; then
  PATH=/opt/csw/bin:/usr/local/bin:/usr/sbin:/usr/bin:/bin:/usr/ccs/bin:/usr/sfw/bin
  if [[ -d ${SUNSTUDIO_HOME} ]]; then
    PATH=${SUNSTUDIO_HOME}/bin:${PATH}
  fi
  export PATH
  echo -e "${magenta} PATH : ${PATH} ${NC}"
elif [ "$(uname -s)" == "Linux" ]; then
  #For RedHat add /usr/sbin
  PATH=${PATH}:/usr/sbin;
  export PATH
  echo -e "${magenta} PATH : ${PATH} ${NC}"
elif [ "$(uname -s)" == "Darwin" ]; then
  PATH=${PATH}:/usr/local/bin;
  export PATH
  echo -e "${magenta} PATH : ${PATH} ${NC}"
fi

if [ -n "${WORKSPACE}" ]; then
  if [ "${SYSTEM}" == "MSYS" -o "${SYSTEM}" == "Cygwin" ]; then
      WORKSPACE=$(cygpath -u "${WORKSPACE}")
      export WORKSPACE
  fi
  echo -e "${green} WORKSPACE is defined ${happy_smiley} : ${WORKSPACE} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : WORKSPACE ${NC}"
  #echo -e "${magenta} WORKSPACE : ${WORKSPACE} ${NC}"
fi

#if [ -n "${GIT_BRANCH_NAME}" ]; then
#  echo -e "${green} GIT_BRANCH_NAME is defined ${happy_smiley} ${NC}"
#else
#  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : GIT_BRANCH_NAME, use the default one ${NC}"
#  export GIT_BRANCH_NAME="develop"
#fi

if [ -n "${WORKSPACE_SUFFIX}" ]; then
  echo -e "${green} WORKSPACE_SUFFIX is defined ${happy_smiley} : ${WORKSPACE_SUFFIX} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : WORKSPACE_SUFFIX, use default one ${NC}"
  WORKSPACE_SUFFIX="TEST"
  export WORKSPACE_SUFFIX
  echo -e "${magenta} WORKSPACE_SUFFIX : ${WORKSPACE_SUFFIX} ${NC}"
fi

if [ -n "${ARCH}" ]; then
  echo -e "${green} ARCH is defined ${happy_smiley} : ${ARCH} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : ARCH, use default one ${NC}"

  if [ "$(uname -s)" == "SunOS" ]; then
    case $(uname -m) in
    sun4v)
        ARCH=sun4sol
        ;;
    i*86*)
        ARCH=x86sol
        ;;
    *)
        # leave ARCH as-is
        ;;
    esac
  elif [ "$(uname -s)" == "Linux" ]; then
    case $(uname -m) in
    x86_64)
        ARCH=linux  # or AMD64 or Intel64 or whatever
        ;;
    i*86)
        ARCH=x86Linux  # or IA32 or Intel32 or whatever
        ;;
    *)
        # leave ARCH as-is
        ;;
    esac
  elif [ "$(uname -s)" == "FreeBSD" ]; then
    case $(uname -m) in
    amd64)
        ARCH=freebsd  # or AMD64 or Intel64 or whatever
        ;;
    *)
        # leave ARCH as-is
        ;;
    esac
  else
    ARCH="$(uname -m)"
  fi
  export ARCH
  echo -e "${magenta} ARCH : ${ARCH} ${NC}"
fi

if [ "${OS}" == "Debian" ]; then
    echo -e "${green} CPP flags : ${NC}"

    dpkg-buildflags

    #CPPFLAGS=$(dpkg-buildflags --get CPPFLAGS)
    #CFLAGS=$(dpkg-buildflags --get CFLAGS)
    #CXXFLAGS=$(dpkg-buildflags --get CXXFLAGS)
    #LDFLAGS=$(dpkg-buildflags --get LDFLAGS)
fi

if [ -n "${BITS}" ]; then
  echo -e "${green} BITS is defined ${happy_smiley} : ${BITS} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : BITS, use default one ${NC}"
  case $(uname -m) in
  x86_64)
      BITS=64
      ;;
  i*86)
      BITS=32
      ;;
  *)
      BITS="?"
      ;;
  esac
  export BITS
  #echo -e "${yellow} Override BITS ${BITS} upon you choice ${NC}"
  echo -e "${magenta} BITS : ${BITS} ${NC}"
fi

if [ "${ENABLE_MINGW_64}" == "true" ]; then
  echo -e "${green} ENABLE_MINGW_64 is defined ${happy_smiley} ${NC}"
  export CC="x86_64-w64-mingw32-gcc"
  export CXX="x86_64-w64-mingw32-g++"
elif [ "${ENABLE_MINGW_32}" == "true" ]; then
  echo -e "${green} ENABLE_MINGW_32 is defined ${happy_smiley} ${NC}"
  export CC="i686-w64-mingw32-gcc"
  export CXX="i686-w64-mingw32-g++"
elif [ "${ENABLE_CLANG}" == "true" ]; then
  echo -e "${green} ENABLE_CLANG is defined ${happy_smiley} ${NC}"
  export CC="/usr/bin/clang"
  export CXX="/usr/bin/clang++"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : ENABLE_CLANG, use default one ${NC}"
  if [ "$(uname -s)" == "SunOS" ]; then
    export CC="cc"
    export CXX="CC"
  elif [ "$(uname -s)" == "Linux" ]; then
    export CC="/usr/bin/gcc-8"
    export CXX="/usr/bin/g++-8"
  else
    export CC="/usr/bin/gcc"
    export CXX="/usr/bin/g++"
  fi
fi

if [ "${ENABLE_CLANG_SCAN}" == "true" ]; then
  echo -e "${green} ENABLE_CLANG_SCAN is defined ${happy_smiley} : ${ENABLE_CLANG_SCAN} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : ENABLE_CLANG_SCAN, use default one ${NC}"
  export CLANG_SCAN="scan-build -o ${WORKSPACE}/reports/clangScanBuildReports -v -v --use-cc clang --use-analyzer=/usr/bin/clang"
  echo -e "${magenta} ENABLE_CLANG_SCAN : ${ENABLE_CLANG_SCAN} ${NC}"
fi

if [ "${ENABLE_NINJA}" == "true" ]; then
  echo -e "${green} ENABLE_NINJA is defined ${happy_smiley} : ${ENABLE_NINJA} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : ENABLE_NINJA, use default one ${NC}"
  export ENABLE_NINJA=false
  echo -e "${magenta} ENABLE_NINJA : ${ENABLE_NINJA} ${NC}"
fi

if [ -n "${COMPILER}" ]; then
  echo -e "${green} COMPILER is defined ${happy_smiley} : ${COMPILER} ${CC} ${CXX} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : COMPILER, use default one ${NC}"
  export COMPILER=${CXX}
  echo -e "${magenta} COMPILER : ${COMPILER} ${NC}"
fi

if [ -n "${ANSIBLE_CMD}" ]; then
  echo -e "${green} ANSIBLE_CMD is defined ${happy_smiley} : ${ANSIBLE_CMD} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : ANSIBLE_CMD, use the default one ${NC}"
  export ANSIBLE_CMD="/usr/local/bin/ansible"
  echo -e "${magenta} ANSIBLE_CMD : ${ANSIBLE_CMD} ${NC}"
fi

if [ -n "${ANSIBLE_CMBD_CMD}" ]; then
  echo -e "${green} ANSIBLE_CMBD_CMD is defined ${happy_smiley} : ${ANSIBLE_CMBD_CMD} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : ANSIBLE_CMBD_CMD, use the default one ${NC}"
  export ANSIBLE_CMBD_CMD="/usr/local/bin/ansible-cmdb"
  echo -e "${magenta} ANSIBLE_CMBD_CMD : ${ANSIBLE_CMBD_CMD} ${NC}"
fi

if [ -n "${ANSIBLE_GALAXY_CMD}" ]; then
  echo -e "${green} ANSIBLE_GALAXY_CMD is defined ${happy_smiley} : ${ANSIBLE_GALAXY_CMD} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : ANSIBLE_GALAXY_CMD, use the default one ${NC}"
  export ANSIBLE_GALAXY_CMD="/usr/local/bin/ansible-galaxy"
  echo -e "${magenta} ANSIBLE_GALAXY_CMD : ${ANSIBLE_GALAXY_CMD} ${NC}"
fi

if [ -n "${ANSIBLE_PLAYBOOK_CMD}" ]; then
  echo -e "${green} ANSIBLE_PLAYBOOK_CMD is defined ${happy_smiley} : ${ANSIBLE_PLAYBOOK_CMD} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : ANSIBLE_PLAYBOOK_CMD, use the default one ${NC}"
  export ANSIBLE_PLAYBOOK_CMD="/usr/local/bin/ansible-playbook"
  echo -e "${magenta} ANSIBLE_PLAYBOOK_CMD : ${ANSIBLE_PLAYBOOK_CMD} ${NC}"
fi

if [ -n "${SONAR_PROCESSOR}" ]; then
  echo -e "${green} SONAR_PROCESSOR is defined ${happy_smiley} : ${SONAR_PROCESSOR} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : SONAR_PROCESSOR, use default one ${NC}"
  SONAR_PROCESSOR=$(uname -m | sed 's/_/-/g')  # x86_64 -> x86-64
  if [ "$(uname -s)" == "Linux" ]; then
    case $(uname -m) in
    x86_64)
        SONAR_PROCESSOR=x86-64  # or AMD64 or Intel64 or whatever
        ;;
    i*86)
        SONAR_PROCESSOR=x86-32  # or IA32 or Intel32 or whatever
        ;;
    *)
        # leave SONAR_PROCESSOR as-is
        ;;
    esac
  else  # [ "$(uname -s)" == "SunOS" ]; then # does not cover osx
    SONAR_PROCESSOR=$(uname -m)  # i86pc
  fi
  export SONAR_PROCESSOR
  echo -e "${magenta} SONAR_PROCESSOR : ${SONAR_PROCESSOR} ${NC}"
fi

if [ -n "${SONAR_CMD}" ]; then
  echo -e "${green} SONAR_CMD is defined ${happy_smiley} : ${SONAR_CMD} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : SONAR_CMD, use default one ${NC}"
  echo -e "${magenta} ${double_arrow} /usr/local/sonar-build-wrapper/build-wrapper-linux-${SONAR_PROCESSOR} ${NC}"
  #if [ -f "/usr/local/sonar-build-wrapper/build-wrapper-linux-${SONAR_PROCESSOR}" ]; then
  #  SONAR_CMD="/usr/local/sonar-build-wrapper/build-wrapper-linux-${SONAR_PROCESSOR} --out-dir ${WORKSPACE}/bw-outputs/"
  #else
  #  echo -e "${red} ${double_arrow} Undefined directory ${head_skull} : SONAR_CMD failed ${NC}"
  #fi
  #export SONAR_CMD
  echo -e "${magenta} SONAR_CMD : ${SONAR_CMD} ${NC}"
fi

if [ -n "${MAKE}" ]; then
  echo -e "${green} MAKE is defined ${happy_smiley} : ${MAKE} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : MAKE, use default one ${NC}"
  if [ "$(uname -s)" == "Linux" ]; then
    #MAKE="colormake"
    MAKE="make"
  else
    MAKE="make"
  fi
  export MAKE
  echo -e "${magenta} MAKE : ${MAKE} ${NC}"
fi

if [ -n "${SCONS}" ]; then
  echo -e "${green} SCONS is defined ${happy_smiley} : ${SCONS} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : SCONS, use default one ${NC}"
  if [ "$(uname -s)" == "SunOS" ]; then
    SCONS="/usr/local/bin/scons"
  elif [ "$(uname -s)" == "Darwin" ]; then
    SCONS="/usr/local/bin/scons"
  else
    #SCONS="/usr/bin/python2.7 /usr/bin/scons"
    #SCONS="python3 /usr/bin/scons"
    #SCONS="python3 /usr/local/bin/scons"
    SCONS="/opt/ansible/env38/bin/python3.8 /opt/ansible/env38/bin/scons"
  fi
  export SCONS
  echo -e "${magenta} SCONS : ${SCONS} ${NC}"
fi

if [ -n "${SCONS_OPTS}" ]; then
  echo -e "${green} SCONS_OPTS is defined ${happy_smiley} : ${SCONS_OPTS} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : SCONS_OPTS, use default one ${NC}"

  if [ "$(uname -s)" == "SunOS" ]; then
    #SCONS_OPTS="-j8 opt=True"
    SCONS_OPTS="-Q"
  elif [ "$(uname -s)" == "Linux" ]; then
    #SCONS_OPTS="-j32 opt=True"
    SCONS_OPTS="-Q"
  else
    #SCONS_OPTS="--cache-disable"
    SCONS_OPTS="-Q"
  fi
  #-j32 --cache-disable gcc_version=4.8.5 opt=True
  #--debug=time,explain
  #count, duplicate, explain, findlibs, includes, memoizer, memory, objects, pdb, prepare, presub, stacktrace, time
  export SCONS_OPTS
  echo -e "${magenta} SCONS_OPTS : ${SCONS_OPTS} ${NC}"
fi

if [ -n "${GIT_CMD}" ]; then
  echo -e "${green} GIT_CMD is defined ${happy_smiley} : ${GIT_CMD} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : GIT_CMD, use the default one ${NC}"
  GIT_CMD="/usr/bin/git"
  if [ "$(uname -s)" == "SunOS" ]; then
    GIT_CMD="/usr/local/bin/git"
  fi
  export GIT_CMD
  echo -e "${magenta} GIT_CMD : ${GIT_CMD} ${NC}"
fi

if [ -n "${SONAR_BRANCH}" -o "${SONAR_BRANCH}" == "null" ]; then
  echo -e "${green} SONAR_BRANCH is defined ${happy_smiley} : ${SONAR_BRANCH} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : SONAR_BRANCH, use the default one ${NC}"
  if [ -n "${GIT_BRANCH}" ]; then
    echo -e "${green} GIT_BRANCH is defined ${happy_smiley} : ${GIT_BRANCH} ${NC}"
    # shellcheck disable=SC2086
    SONAR_BRANCH="$(printf '%s' ${GIT_BRANCH} | cut -d'/' -f 2-)"
  else
    echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : GIT_BRANCH, use the default one ${NC}"
    if [ -n "${GIT_BRANCH_NAME}" ]; then
      echo -e "${green} GIT_BRANCH_NAME is defined ${happy_smiley} : ${GIT_BRANCH_NAME} ${NC}"
      # shellcheck disable=SC2086
      SONAR_BRANCH="$(printf '%s' ${GIT_BRANCH_NAME} | cut -d'/' -f 2-)"
    else
      echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : GIT_BRANCH_NAME, use the default one ${NC}"
      SONAR_BRANCH="develop"
    fi
  fi
  export SONAR_BRANCH
  echo -e "${magenta} SONAR_BRANCH : ${SONAR_BRANCH} ${NC}"
fi

if [ -n "${TAR}" ]; then
  echo -e "${green} TAR is defined ${happy_smiley} : ${TAR} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : TAR, use default one ${NC}"
  if [ "$(uname -s)" == "SunOS" ]; then
    TAR="/usr/sfw/bin/gtar"
  elif [ "$(uname -s)" == "Darwin" ]; then
    TAR="/opt/local/bin/gnutar"
  elif [ "$(uname -s)" == "FreeBSD" ]; then
    TAR="/usr/bin/tar"
  elif [ "$(uname -s)" == "Linux" ]; then
    TAR="tar"
  elif [ "$(uname -s | cut -c 1-7)" == "MSYS_NT" ]; then
    TAR="tar"
  else
    TAR="7z"
  fi
  export TAR
  echo -e "${magenta} TAR : ${TAR} ${NC}"
fi

if [ -n "${WGET}" ]; then
  echo -e "${green} WGET is defined ${happy_smiley} : ${WGET} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : WGET, use default one ${NC}"
  if [ "$(uname -s)" == "SunOS" ]; then
    WGET="/opt/csw/bin/wget"
    #/usr/sfw/bin/wget
  elif [ "$(uname -s)" == "Darwin" ]; then
    WGET="/opt/local/bin/wget"
  elif [ "$(uname -s)" == "Linux" ]; then
    WGET="wget"
  elif [ "$(uname -s | cut -c 1-7)" == "MSYS_NT" ]; then
    WGET="wget"
  else
    WGET="wget"
  fi
  export WGET
  echo -e "${magenta} WGET : ${WGET} ${NC}"
fi

if [ -n "${WGET_OPTIONS}" ]; then
  echo -e "${green} WGET_OPTIONS is defined ${happy_smiley} : ${WGET_OPTIONS} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : WGET_OPTIONS, use default one ${NC}"
  WGET_OPTIONS="--no-check-certificate"
  export WGET_OPTIONS
  echo -e "${magenta} WGET_OPTIONS : ${WGET_OPTIONS} ${NC}"
fi

if [ -n "${CURL}" ]; then
  echo -e "${green} CURL is defined ${happy_smiley} : ${CURL} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : CURL, use default one ${NC}"
  if [ "$(uname -s)" == "SunOS" ]; then
    CURL="/usr/local/bin/curl"
  elif [ "$(uname -s)" == "Darwin" ]; then
    CURL="/opt/local/bin/curl"
  elif [ "$(uname -s)" == "Linux" ]; then
    CURL="/usr/bin/curl"
  elif [ "$(uname -s | cut -c 1-7)" == "MSYS_NT" ]; then
    CURL="curl"
  else
    CURL="curl"
  fi
  export CURL
  echo -e "${magenta} CURL : ${CURL} ${NC}"
fi

if [ -n "${CURL_OPTIONS}" ]; then
  echo -e "${green} CURL_OPTIONS is defined ${happy_smiley} : ${CURL_OPTIONS} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : CURL_OPTIONS, use default one ${NC}"
  CURL_OPTIONS="-k"
  export CURL_OPTIONS
  echo -e "${magenta} CURL_OPTIONS : ${CURL_OPTIONS} ${NC}"
fi

if [ -n "${XARGS_OPTIONS}" ]; then
  echo -e "${green} XARGS_OPTIONS is defined ${happy_smiley} : ${XARGS_OPTIONS} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : XARGS_OPTIONS, use default one ${NC}"
  if [ "$(uname -s)" != "Darwin" ]; then
    XARGS_OPTIONS+=" -r " # No run on OSX
    export XARGS_OPTIONS
  fi
  echo -e "${magenta} XARGS_OPTIONS : ${XARGS_OPTIONS} ${NC}"
fi

if [ -n "${MD5SUM}" ]; then
  echo -e "${green} MD5SUM is defined ${happy_smiley} : ${MD5SUM} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : MD5SUM, use default one ${NC}"
  if [ "$(uname -s)" == "SunOS" ]; then
    MD5SUM="/usr/bin/digest -a md5"
  elif [ "$(uname -s)" == "Darwin" ]; then
    MD5SUM="/usr/local/bin/md5sum"
  elif [ "$(uname -s)" == "Linux" ]; then
    MD5SUM="md5sum"
  elif [ "$(uname -s | cut -c 1-7)" == "MSYS_NT" ]; then
    MD5SUM="md5sum"
  else
    MD5SUM="md5sum"
  fi
  export MD5SUM
  echo -e "${magenta} MD5SUM : ${MD5SUM} ${NC}"
fi

if [ -n "${TIBCO_HOME}" ]; then
  echo -e "${green} TIBCO_HOME is defined ${happy_smiley} : ${TIBCO_HOME} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : TIBCO_HOME, use default one ${NC}"
  if [ "$(uname -s)" == "Linux" ]; then
    TIBCO_HOME="/opt/tibco"
  else
    TIBCO_HOME=""
  fi
  export TIBCO_HOME
  echo -e "${magenta} TIBCO_HOME : ${TIBCO_HOME} ${NC}"
fi

if [ -n "${TIBRV_VERSION}" ]; then
  echo -e "${green} TIBRV_VERSION is defined ${happy_smiley} : ${TIBRV_VERSION} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : TIBRV_VERSION, use default one ${NC}"
  TIBRV_VERSION="8.4"
  export TIBRV_VERSION
  echo -e "${magenta} TIBRV_VERSION : ${TIBRV_VERSION} ${NC}"
fi

if [ -n "${TIBRV_HOME}" ]; then
  echo -e "${green} TIBRV_HOME is defined ${happy_smiley} : ${TIBRV_HOME} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : TIBRV_HOME, use default one ${NC}"
  if [ "$(uname -s)" == "Linux" ]; then
    TIBRV_HOME="${TIBCO_HOME}/tibrv/${TIBRV_VERSION}"
  else
    TIBRV_HOME=""
  fi
  export TIBRV_HOME
  echo -e "${magenta} TIBRV_HOME : ${TIBRV_HOME} ${NC}"
fi

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$TIBRV_HOME/lib

#========================================= JAVA

if [ -n "${JAVA_SSL_OPTS}" ]; then
  echo -e "${green} JAVA_SSL_OPTS is defined ${happy_smiley} : ${JAVA_SSL_OPTS} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : JAVA_SSL_OPTS, please override ${NC}"
  #JAVA_SSL_OPTS="-Djavax.net.ssl.trustStore=/usr/local/share/ca-certificates/ca.crt"
  #export JAVA_SSL_OPTS
fi

if [ -n "${JAVA_TOOL_OPTIONS}" ]; then
  echo -e "${green} JAVA_TOOL_OPTIONS is defined ${happy_smiley} : ${JAVA_TOOL_OPTIONS} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : JAVA_TOOL_OPTIONS, please override ${NC}"
  #JAVA_TOOL_OPTIONS="-Dfile.encoding=UTF-8"
  #export JAVA_TOOL_OPTIONS
fi

if [ -n "${JAVA_HOME}" ]; then
  echo -e "${green} JAVA_HOME is defined ${happy_smiley} : ${JAVA_HOME} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : JAVA_HOME, use the default one ${NC}"
  #JAVA_HOME="/usr"
  if [ "$(uname -s)" == "SunOS" ]; then
    JAVA_HOME="/usr/jdk/instances/jdk1.8.0_131"
  elif [ "$(uname -s)" == "Darwin" ]; then
    JAVA_HOME=""
  fi
  if [[ -d /dpool/jdk ]]; then
    JAVA_HOME="/dpool/jdk"
  fi
  if [[ -d /usr/lib/jvm/java-1.8.0-openjdk-amd64 ]]; then
    JAVA_HOME="/usr/lib/jvm/java-1.8.0-openjdk-amd64"
  fi
  if [[ -d /usr/lib/jvm/java-8-oracle ]]; then
    JAVA_HOME="/usr/lib/jvm/java-8-oracle"
  fi
  export JAVA_HOME
  echo -e "${magenta} JAVA_HOME : ${JAVA_HOME} ${NC}"
fi

if [ "$(uname -s)" == "SunOS" ]; then
  PATH=$JAVA_HOME/bin:$PATH;
  export PATH
  echo -e "${magenta} PATH : ${PATH} ${NC}"
fi

if [ -n "${MAVEN_PATH}" ]; then
  echo -e "${green} MAVEN_PATH is defined ${happy_smiley} : ${MAVEN_PATH} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : MAVEN_PATH, use the default one ${NC}"
  MAVEN_PATH="/usr/local/apache-maven-3.2.1"
  export MAVEN_PATH
  echo -e "${magenta} MAVEN_PATH : ${MAVEN_PATH} ${NC}"
fi

if [ -n "${MAVEN_OPTS}" ]; then
  echo -e "${green} MAVEN_OPTS is defined ${happy_smiley} : ${MAVEN_OPTS} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : MAVEN_OPTS, use the default one ${NC}"
  #MAVEN_OPTS="-XX:MaxPermSize=512m"
  MAVEN_OPTS="-Xmx3072m -Djava.awt.headless=true -XX:+PrintGCDetails -XX:+PrintGCDateStamps -Xloggc:gc.log -XX:+HeapDumpOnOutOfMemoryError -Dsun.zip.disableMemoryMapping=true -Djava.io.tmpdir=${WORKSPACE}/target/tmp"
  export MAVEN_OPTS
  echo -e "${magenta} MAVEN_OPTS : ${MAVEN_OPTS} ${NC}"
fi

#export PATH="${JAVA_HOME}/bin:/usr/kerberos/bin:/usr/local/bin:/bin:/usr/bin:/usr/X11R6/bin:/kgr/dev/kgr_maven/nexus/bin/jsw/linux-x86-64:/kgr-mvn/hudson/etc/init.d:/home/kgr_mvn/bin"
export M2_HOME=""

if [ -n "${USE_SUDO}" ]; then
  echo -e "${green} USE_SUDO is defined ${happy_smiley} : ${USE_SUDO} ${NC}"
  if [ "${USE_SUDO}" == "false" ]; then
    unset USE_SUDO
    echo -e "${green} USE_SUDO is disabled ${happy_smiley} : ${USE_SUDO} ${NC}"
  fi
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : USE_SUDO, use the default one ${NC}"
  if [ "${OS}" == "Ubuntu" ]; then
    USE_SUDO="sudo"
  else
    USE_SUDO=""
  fi
  export USE_SUDO
  echo -e "${magenta} USE_SUDO : ${USE_SUDO} ${NC}"
fi

if [ -n "${RELEASE_VERSION}" ]; then
  echo -e "${green} RELEASE_VERSION is defined ${happy_smiley} : ${RELEASE_VERSION} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : RELEASE_VERSION, use the default one ${NC}"
  RELEASE_VERSION="1.0.0"
  export RELEASE_VERSION
  echo -e "${magenta} RELEASE_VERSION : ${RELEASE_VERSION} ${NC}"
fi

if [ -n "${MVN_RELEASE_VERSION}" ]; then
  echo -e "${green} MVN_RELEASE_VERSION is defined ${happy_smiley} : ${MVN_RELEASE_VERSION} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : MVN_RELEASE_VERSION, use the default one ${NC}"
  MVN_RELEASE_VERSION=${RELEASE_VERSION}
  export MVN_RELEASE_VERSION
  echo -e "${magenta} MVN_RELEASE_VERSION : ${MVN_RELEASE_VERSION} ${NC}"
fi

if [ -n "${HTTP_PROTOCOL}" ]; then
  echo -e "${green} HTTP_PROTOCOL is defined ${happy_smiley} : ${HTTP_PROTOCOL} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : HTTP_PROTOCOL, use the default one ${NC}"
  export HTTP_PROTOCOL="https://"
  echo -e "${magenta} HTTP_PROTOCOL : ${HTTP_PROTOCOL} ${NC}"
fi

if [ -n "${TARGET_PROJECT}" ]; then
  echo -e "${green} TARGET_PROJECT is defined ${happy_smiley} : ${TARGET_PROJECT} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : TARGET_PROJECT, use the default one ${NC}"
  TARGET_PROJECT="${JOB_NAME}"
  export TARGET_PROJECT
  echo -e "${magenta} TARGET_PROJECT : ${TARGET_PROJECT} ${NC}"
fi

if [ -n "${TARGET_TAG}" ]; then
  echo -e "${green} TARGET_TAG is defined ${happy_smiley} ; ${TARGET_TAG} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : TARGET_TAG, use the default one ${NC}"
  export TARGET_TAG="LATEST_SUCCESSFULL"
  echo -e "${magenta} TARGET_TAG : ${TARGET_TAG} ${NC}"
fi

if [ -n "${TARGET_USER}" ]; then
  echo -e "${green} TARGET_USER is defined ${happy_smiley} : ${TARGET_USER} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : TARGET_USER, use the default one ${NC}"
  export TARGET_USER="jenkins"
  echo -e "${magenta} TARGET_USER : ${TARGET_USER} ${NC}"
fi

if [ -n "${TARGET_HOST}" ]; then
  echo -e "${green} TARGET_HOST is defined ${happy_smiley} : ${TARGET_HOST} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : TARGET_HOST, use the default one ${NC}"
  export TARGET_HOST=${TARGET_HOST:-"albandrieu.com"}
  export SERVER_HOST=${SERVER_HOST:-"albandrieu.com"} #TODO TARGET_HOST and SERVER_HOST are duplicated
  echo -e "${magenta} TARGET_HOST : ${TARGET_HOST} ${NC}"
fi

if [ -n "${INSTALLER_PATH}" ]; then
  echo -e "${green} INSTALLER_PATH is defined ${happy_smiley} : ${INSTALLER_PATH} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : INSTALLER_PATH, use the default one ${NC}"
  export INSTALLER_PATH="1.0.0"
  echo -e "${magenta} INSTALLER_PATH : ${INSTALLER_PATH} ${NC}"
fi

if [ -n "${TARGET_SHARE_DIR}" ]; then
  echo -e "${green} TARGET_SHARE_DIR is defined ${happy_smiley} : ${TARGET_SHARE_DIR} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : TARGET_SHARE_DIR, use default one ${NC}"
  export TARGET_SHARE_DIR="${TARGET_USER}@${TARGET_HOST}:/var/www/release/todo/${INSTALLER_PATH}/"
  # shellcheck disable=SC2154
  echo -e "${magenta} TARGET_SHARE_DIR : ${TARGET_SHARE_DIR} ${NC}"
fi

if [ -n "${TARGET_DIR}" ]; then
  echo -e "${green} TARGET_DIR is defined ${happy_smiley} : ${TARGET_DIR} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : TARGET_DIR, use default one ${NC}"
  export TARGET_DIR="${TARGET_USER}@${SERVER_HOST}:/var/www/~devel/${JOB_NAME}/todo"
  # shellcheck disable=SC2154
  echo -e "${magenta} TARGET_DIR : ${TARGET_DIR} ${NC}"
fi

if [ -n "${SERVER_HOST}" ]; then
  echo -e "${green} SERVER_HOST is defined ${happy_smiley} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : SERVER_HOST, use the default one ${NC}"
  SERVER_HOST="albandrieu"
  export SERVER_HOST
  echo -e "${magenta} SERVER_HOST : ${SERVER_HOST} ${NC}"
fi

if [ -n "${SERVER_CONTEXT}" ]; then
  echo -e "${green} SERVER_CONTEXT is defined ${happy_smiley} : ${SERVER_CONTEXT} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : SERVER_CONTEXT, use the default one ${NC}"
  SERVER_CONTEXT="/test/#/"
  export SERVER_CONTEXT
  echo -e "${magenta} SERVER_CONTEXT : ${SERVER_CONTEXT} ${NC}"
fi

if [ -n "${SERVER_URL}" ]; then
  echo -e "${green} SERVER_URL is defined ${happy_smiley} : ${SERVER_URL} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : SERVER_URL, use the default one ${NC}"
  SERVER_URL=${HTTP_PROTOCOL}${SERVER_HOST}${SERVER_CONTEXT}
  export SERVER_URL
  echo -e "${magenta} SERVER_URL : ${SERVER_URL} ${NC}"
fi

if [ -n "${ZAP_PORT}" ]; then
  echo -e "${green} ZAP_PORT is defined ${happy_smiley} : ${ZAP_PORT} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : ZAP_PORT, use the default one ${NC}"
  ZAP_PORT=8090
  export ZAP_PORT
  echo -e "${magenta} ZAP_PORT : ${ZAP_PORT} ${NC}"
fi

if [ -n "${JBOSS_PORT}" ]; then
  echo -e "${green} JBOSS_PORT is defined ${happy_smiley} : ${JBOSS_PORT} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : JBOSS_PORT, use the default one ${NC}"
  JBOSS_PORT=8180
  export TOMCAT_PORT
  echo -e "${magenta} TOMCAT_PORT : ${TOMCAT_PORT} ${NC}"
fi

if [ -n "${TOMCAT_PORT}" ]; then
  echo -e "${green} TOMCAT_PORT is defined ${happy_smiley} : ${TOMCAT_PORT} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : TOMCAT_PORT, use the default one ${NC}"
  TOMCAT_PORT=8280
  export TOMCAT_PORT
  echo -e "${magenta} TOMCAT_PORT : ${TOMCAT_PORT} ${NC}"
fi

if [ -n "${JETTY_PORT}" ]; then
  echo -e "${green} JETTY_PORT is defined ${happy_smiley} : ${JETTY_PORT} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : JETTY_PORT, use the default one ${NC}"
  JETTY_PORT=9090
  export JETTY_PORT
  echo -e "${magenta} JETTY_PORT : ${JETTY_PORT} ${NC}"
fi

if [ -n "${CARGO_RMI_PORT}" ]; then
  echo -e "${green} CARGO_RMI_PORT is defined ${happy_smiley} : ${CARGO_RMI_PORT} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : CARGO_RMI_PORT, use the default one ${NC}"
  CARGO_RMI_PORT=44447
  export CARGO_RMI_PORT
  echo -e "${magenta} CARGO_RMI_PORT : ${CARGO_RMI_PORT} ${NC}"
fi

if [ -n "${CARGO_RMI_REGISTRY_PORT}" ]; then
  echo -e "${green} CARGO_RMI_REGISTRY_PORT is defined ${happy_smiley} : ${CARGO_RMI_REGISTRY_PORT} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : CARGO_RMI_REGISTRY_PORT, use the default one ${NC}"
  CARGO_RMI_REGISTRY_PORT=1099
  export CARGO_RMI_REGISTRY_PORT
  echo -e "${magenta} CARGO_RMI_REGISTRY_PORT : ${CARGO_RMI_REGISTRY_PORT} ${NC}"
fi

if [ -n "${CARGO_HTTP_PORT}" ]; then
  echo -e "${green} CARGO_HTTP_PORT is defined ${happy_smiley} : ${CARGO_HTTP_PORT} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : CARGO_HTTP_PORT, use the default one ${NC}"
  CARGO_HTTP_PORT=8181
  export CARGO_HTTP_PORT
  echo -e "${magenta} CARGO_HTTP_PORT : ${CARGO_HTTP_PORT} ${NC}"
fi

if [ -n "${CARGO_TELNET_PORT}" ]; then
  echo -e "${green} CARGO_TELNET_PORT is defined ${happy_smiley} : ${CARGO_TELNET_PORT} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : CARGO_TELNET_PORT, use the default one ${NC}"
  CARGO_TELNET_PORT=8001
  export CARGO_TELNET_PORT
  echo -e "${magenta} CARGO_TELNET_PORT : ${CARGO_TELNET_PORT} ${NC}"
fi

if [ -n "${CARGO_SSH_PORT}" ]; then
  echo -e "${green} CARGO_SSH_PORT is defined ${happy_smiley} : ${CARGO_SSH_PORT} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : CARGO_SSH_PORT, use the default one ${NC}"
  CARGO_SSH_PORT=8444
  export CARGO_SSH_PORT
  echo -e "${magenta} CARGO_SSH_PORT : ${CARGO_SSH_PORT} ${NC}"
fi

if [ -n "${CARGO_AJP_PORT}" ]; then
  echo -e "${green} CARGO_AJP_PORT is defined ${happy_smiley} : ${CARGO_AJP_PORT} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : CARGO_AJP_PORT, use the default one ${NC}"
  CARGO_AJP_PORT=9009
  export CARGO_AJP_PORT
  echo -e "${magenta} CARGO_AJP_PORT : ${CARGO_AJP_PORT} ${NC}"
fi

if [ -n "${ECLIPSE_DEBUG_PORT}" ]; then
  echo -e "${green} ECLIPSE_DEBUG_PORT is defined ${happy_smiley} : ${ECLIPSE_DEBUG_PORT} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : ECLIPSE_DEBUG_PORT, use the default one ${NC}"
  ECLIPSE_DEBUG_PORT=2924
  export ECLIPSE_DEBUG_PORT
  echo -e "${magenta} ECLIPSE_DEBUG_PORT : ${ECLIPSE_DEBUG_PORT} ${NC}"
fi

if [ -n "${CARGO_DEBUG_PORT}" ]; then
  echo -e "${green} CARGO_DEBUG_PORT is defined ${happy_smiley} : ${CARGO_DEBUG_PORT} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : CARGO_DEBUG_PORT, use the default one ${NC}"
  CARGO_DEBUG_PORT=5005
  export CARGO_DEBUG_PORT
  echo -e "${magenta} CARGO_DEBUG_PORT : ${CARGO_DEBUG_PORT} ${NC}"
fi

if [ -n "${REDIS_PORT}" ]; then
  echo -e "${green} REDIS_PORT is defined ${happy_smiley} : ${REDIS_PORT} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : REDIS_PORT, use the default one ${NC}"
  REDIS_PORT=6379
  export REDIS_PORT
  echo -e "${magenta} REDIS_PORT : ${REDIS_PORT} ${NC}"
fi

if [ -n "${H2_PORT}" ]; then
  echo -e "${green} H2_PORT is defined ${happy_smiley} : ${H2_PORT} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : H2_PORT, use the default one ${NC}"
  H2_PORT=5055
  export H2_PORT
  echo -e "${magenta} H2_PORT : ${H2_PORT} ${NC}"
fi

ENV_FILENAME="${WORKSPACE}/ENV_${ARCH}_VERSION.TXT"

echo -e "${NC}"

# shellcheck source=./step-2-0-1-build-env-info.sh
"${WORKING_DIR}/step-2-0-1-build-env-info.sh" > "${ENV_FILENAME}"

# shellcheck disable=SC2154
echo -e "${black} ${blink} DONE ${NC}"

#exit 0

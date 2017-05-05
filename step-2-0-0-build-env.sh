#!/bin/bash
#set -xv

red='\e[0;31m'
green='\e[0;32m'
NC='\e[0m' # No Color

echo "SCONS : ${SCONS} - ${SCONS_OPTS}"
echo "ARCH : ${ARCH} - ${TAR}"
echo "WORKSPACE_SUFFIX : ${WORKSPACE_SUFFIX}"
echo "SHELL : ${SHELL}"

if [ -z "$SUNSTUDIO_HOME" ]; then
  echo -e "${red} \u00BB Undefined build parameter: SUNSTUDIO_HOME, use default one ${NC}"
  if [ `uname -s` == "SunOS" ]; then    
    #SUNSTUDIO_HOME="/opt/solarisstudio12.3"
    #SUNSTUDIO_HOME="/rms/sunpro/sun-studio-12/SUNWspro"
    SUNSTUDIO_HOME="/opt/SUNWspro"
    export SUNSTUDIO_HOME
  fi 
fi

if [ -z "$PATH" ]; then  
  if [ `uname -s` == "SunOS" ]; then
    echo -e "${red} \u00BB Undefined build parameter: PATH, use default one ${NC}"
    #/opt/SUNWspro/bin is a link to /rms/sunpro 
    #ln -s /rms/sunpro/sun-studio-12/SUNWspro /opt/SUNWspro
    #old nount in /etc/vfstab 
    #/mnt/kgr/COMPKGR /mnt/EXPORTS/kgrweb.COMPKGR/kgr_36
    #mount    
    #/rms/sunpro on fr1svmnas13-nfs:/fr1svmnas13_sas_multi_vol1_b01/kplusdev/_dat/rms/sunpro remote/read/write/setuid/devices/intr/soft/xattr/dev=5440009 on Wed May  3 17:32:00 2017    
    #PATH=/usr/local/bin:/usr/sbin:/usr/bin:/bin:/usr/ccs/bin:${SUNSTUDIO_HOME}/bin:/usr/sfw/bin:/opt/csw/bin; export PATH
    PATH=${SUNSTUDIO_HOME}/bin:/opt/csw/bin:/usr/local/bin:/usr/sbin:/usr/bin:/bin:/usr/ccs/bin:/usr/sfw/bin; export PATH
    #TODO check /home/rms/bin/sun4sol/top
  fi
fi

if [ -z "$WORKSPACE" ]; then
  echo -e "${red} \u00BB Undefined build parameter: WORKSPACE ${NC}"
  exit 1
fi

#if [ -n "${GIT_BRANCH_NAME}" ]; then
#  echo "GIT_BRANCH_NAME is defined \u061F"
#else
#  echo -e "${red} \u00BB Undefined build parameter: GIT_BRANCH_NAME, use the default one ${NC}"
#  export GIT_BRANCH_NAME="develop"
#fi

if [ -z "$WORKSPACE_SUFFIX" ]; then
  echo -e "${red} \u00BB Undefined build parameter: WORKSPACE_SUFFIX, use default one ${NC}"
  export WORKSPACE_SUFFIX="cmr/CMR"
fi

if [ -z "$ARCH" ]; then
  echo -e "${red} \u00BB Undefined build parameter: ARCH, use default one ${NC}"
  export ARCH="x86sol"
fi

if [ -z "$COMPILER" ]; then
  echo -e "${red} \u00BB Undefined build parameter: COMPILER, use default one ${NC}"
  if [ `uname -s` == "SunOS" ]; then
    COMPILER="CC"
  else 
    COMPILER="gcc"
  fi  
  export COMPILER
fi

if [ -z "$SCONS" ]; then
  echo -e "${red} \u00BB Undefined build parameter: SCONS, use default one ${NC}"
  if [ `uname -s` == "SunOS" ]; then
    SCONS="/usr/local/bin/scons"
  else 
    SCONS="/usr/bin/scons"
  fi  
  export SCONS
fi

if [ -z "$SCONS_OPTS" ]; then
  echo -e "${red} \u00BB Undefined build parameter: SCONS_OPTS, use default one ${NC}"
  
  if [ `uname -s` == "SunOS" ]; then
    SCONS_OPTS="-j8 opt=True"    
  elif [ `uname -s` == "Linux" ]; then
    SCONS_OPTS="-j32 opt=True"    
  else 
    SCONS_OPTS="-j8 --cache-disable gcc_version=4.1.2 opt=True"
  fi
  #-j32 --cache-disable gcc_version=4.8.5 opt=True
  #--debug=time,explain
  #count, duplicate, explain, findlibs, includes, memoizer, memory, objects, pdb, prepare, presub, stacktrace, time
  export SCONS_OPTS
fi

if [ -n "${JAVA_HOME}" ]; then
  echo "JAVA_HOME is defined \u061F"
else
  echo -e "${red} \u00BB Undefined build parameter: JAVA_HOME, use the default one ${NC}"
  JAVA_HOME=/kgr-mvn/jdk
  if [ `uname -s` == "SunOS" ]; then
    JAVA_HOME=/usr/jdk/instances/jdk1.8.0_131/
  fi
  if [[ -d /dpool/jdk ]]; then
    JAVA_HOME=/dpool/jdk
  fi
  export JAVA_HOME
fi

if [ -n "${GIT_CMD}" ]; then
  echo -e "GIT_CMD is defined \u061F"
else
  echo -e "${red} \u00BB Undefined build parameter: GIT_CMD, use the default one ${NC}"
  GIT_CMD="/usr/bin/git"
  if [ `uname -s` == "SunOS" ]; then
    GIT_CMD="/usr/local/bin/git"
  fi
  export GIT_CMD
fi

if [ -z "$TAR" ]; then
  echo -e "${red} \u00BB Undefined build parameter: TAR, use default one ${NC}"
  if [ `uname -s` == "SunOS" ]; then
    TAR="/usr/sfw/bin/gtar"
  else 
    TAR="tar"
  fi  
  export TAR
fi

if [ -z "$TIBCO_HOME" ]; then
  echo -e "${red} \u00BB Undefined build parameter: TIBCO_HOME, use default one ${NC}"
  if [ `uname -s` == "Linux" ]; then
    TIBCO_HOME="/opt/tibco"
  else 
    TIBCO_HOME=""
  fi  
  export TIBCO_HOME
fi

if [ -z "$TIBRV_VERSION" ]; then
  echo -e "${red} \u00BB Undefined build parameter: TIBRV_VERSION, use default one ${NC}"
  TIBRV_VERSION="8.4"
  export TIBRV_VERSION
fi

if [ -z "$TIBRV_HOME" ]; then
  echo -e "${red} \u00BB Undefined build parameter: TIBRV_HOME, use default one ${NC}"
  if [ `uname -s` == "Linux" ]; then
    TIBRV_HOME="${TIBCO_HOME}/tibrv/${TIBRV_VERSION}"
  else
    TIBRV_HOME=""
  fi  
  export TIBRV_HOME
fi

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$TIBRV_HOME/lib

if [ `uname -s` == "SunOS" ]; then
  PATH=$JAVA_HOME/bin:$PATH; export PATH
fi

ENV_FILENAME="${WORKSPACE}/${WORKSPACE_SUFFIX}/ENV_${ARCH}_VERSION.TXT"

echo "========== OS =========="  > ${ENV_FILENAME}
echo "Operating system name, release, version, node name, hardware name, and processor type"  >> ${ENV_FILENAME}
uname -a 2>&1 >> ${ENV_FILENAME}
hostid 2>&1 >> ${ENV_FILENAME}
if [ `uname -s` == "SunOS" ]; then
  psrinfo -v 2>&1 >> ${ENV_FILENAME}
  isalist 2>&1 >> ${ENV_FILENAME}
  showrev 2>&1 >> ${ENV_FILENAME}
  #shorew -p | grep 138411
  cat /etc/release 2>&1 >> ${ENV_FILENAME}
elif [ `uname -s` == "Linux" ]; then
  lsb_release  2>&1 >> ${ENV_FILENAME}
fi
echo "========== COMPILER =========="  >> ${ENV_FILENAME}
${SCONS} --version 2>&1 >> ${ENV_FILENAME}
if [ `uname -s` == "SunOS" ]; then
  type cc 2>&1 >> ${ENV_FILENAME}
  cc -V 2>&1 >> ${ENV_FILENAME}
  type CC 2>&1 >> ${ENV_FILENAME}
  CC -V 2>&1 >> ${ENV_FILENAME}
else 
  gcc --version 2>&1 >> ${ENV_FILENAME}
fi
echo "PATH : $PATH" 2>&1 >> ${ENV_FILENAME}
echo "LD_LIBRARY_PATH : $LD_LIBRARY_PATH" 2>&1 >> ${ENV_FILENAME}
echo "LIBPATH : $LIBPATH" 2>&1 >> ${ENV_FILENAME}

echo "========== PERL =========="  >> ${ENV_FILENAME}
perl --version 2>&1 >> ${ENV_FILENAME}
perl -V 2>&1 >> ${ENV_FILENAME}
echo "========== PYTHON =========="  >> ${ENV_FILENAME}
python -V 2>&1 >> ${ENV_FILENAME}
pip -V 2>&1 >> ${ENV_FILENAME}
echo "========== JAVA =========="  >> ${ENV_FILENAME}
java -version 2>&1 >> ${ENV_FILENAME}
echo "========== MISC =========="  >> ${ENV_FILENAME}
${TAR} --version 2>&1 >> ${ENV_FILENAME}
${GIT_CMD} --version 2>&1 >> ${ENV_FILENAME}
mvn --version 2>&1 >> ${ENV_FILENAME}
echo "========== TIBCO =========="  >> ${ENV_FILENAME}
echo "TIBCO_HOME : $TIBCO_HOME" 2>&1 >> ${ENV_FILENAME}
echo "TIBRV_HOME : $TIBRV_HOME" 2>&1 >> ${ENV_FILENAME}
echo "========== ENV =========="  >> ${ENV_FILENAME}
env 2>&1 >> ${ENV_FILENAME}

exit 0


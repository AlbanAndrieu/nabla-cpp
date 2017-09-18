#!/bin/bash
#set -xv

bold="\033[01m"
underline="\033[04m"
blink="\033[05m"

black="\033[30m"
red="\033[31m"
green="\033[32m"
yellow="\033[33m"
blue="\033[34m"
magenta="\033[35m"
cyan="\033[36m"
ltgray="\033[37m"

NC="\033[0m"

#double_arrow='\u00BB'
double_arrow='\xC2\xBB'
#head_skull='\u2620'
head_skull='\xE2\x98\xA0'
#happy_smiley='\u263A'
happy_smiley='\xE2\x98\xBA'
nabla_logo='\xE2\x88\x87'

#========================================= CPP

echo -e "${green} WELCOME ${nabla_logo} ${NC}"

echo -e "${green} HOSTNAME : ${HOSTNAME} ${NC}"
echo -e "${green} SHELL : ${SHELL} ${NC}"
echo -e "${green} TERM : ${TERM} ${NC}"
echo -e "${green} HOME : ${HOME} ${NC}"
echo -e "${green} USER : ${USER} ${NC}"
echo -e "${green} PATH : ${PATH} ${NC}"

echo -e "${green} SCONS : ${SCONS} ${NC}"
echo -e "${green} SCONS_OPTS : ${SCONS_OPTS} ${NC}"
echo -e "${green} ARCH : ${ARCH} ${NC}"
echo -e "${green} WORKSPACE_SUFFIX : ${WORKSPACE_SUFFIX} ${NC}"
echo -e "${green} GIT_BRANCH_NAME : ${GIT_BRANCH_NAME} ${NC}"

#DRY_RUN is used on UAT in order to avoid TAGING or DEPLOYING to production
if [ -n "${DRY_RUN}" ]; then
  echo -e "${green} DRY_RUN is defined ${happy_smiley} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : DRY_RUN, please override ${NC}"
fi

if [ -z "$PATH" ]; then  
  if [ `uname -s` == "SunOS" ]; then
    echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : PATH, use default one ${NC}"
    #Please do not enable NFS share on build server.
    #In case of NFS share issue we will not be able to perform an HF    
    #/opt/SUNWspro/bin 
    #mount    
    #PATH=/usr/local/bin:/usr/sbin:/usr/bin:/bin:/usr/ccs/bin:${SUNSTUDIO_HOME}/bin:/usr/sfw/bin:/opt/csw/bin; export PATH
    exit 1
  fi
fi

if [ -z "$SUNSTUDIO_HOME" ]; then
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : SUNSTUDIO_HOME, use default one ${NC}"
  if [ `uname -s` == "SunOS" ]; then    
    #SUNSTUDIO_HOME="/opt/solarisstudio12.3"
    #SUNSTUDIO_HOME="/rms/sunpro/sun-studio-12/SUNWspro"
    SUNSTUDIO_HOME="/opt/SUNWspro"
    export SUNSTUDIO_HOME
  fi 
fi

if [ `uname -s` == "SunOS" ]; then
  PATH=/opt/csw/bin:/usr/local/bin:/usr/sbin:/usr/bin:/bin:/usr/ccs/bin:/usr/sfw/bin
  if [[ -d ${SUNSTUDIO_HOME} ]]; then
    PATH=${SUNSTUDIO_HOME}/bin:${PATH}
  fi
  export PATH
fi
      
if [ -z "$WORKSPACE" ]; then
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : WORKSPACE ${NC}"
  exit 1
fi

#if [ -n "${GIT_BRANCH_NAME}" ]; then
#  echo "${green} GIT_BRANCH_NAME is defined ${happy_smiley} ${NC}"
#else
#  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : GIT_BRANCH_NAME, use the default one ${NC}"
#  export GIT_BRANCH_NAME="develop"
#fi

if [ -n "${WORKSPACE_SUFFIX}" ]; then
  echo -e "${green} WORKSPACE_SUFFIX is defined ${happy_smiley} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : WORKSPACE_SUFFIX, use default one ${NC}"
  export WORKSPACE_SUFFIX="CMR"
fi

if [ -n "${ARCH}" ]; then
  echo -e "${green} ARCH is defined ${happy_smiley} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : ARCH, use default one ${NC}"
  export ARCH="x86sol"
fi

if [ -n "${COMPILER}" ]; then
  echo -e "${green} COMPILER is defined ${happy_smiley} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : COMPILER, use default one ${NC}"
  if [ `uname -s` == "SunOS" ]; then
    COMPILER="CC"
  else 
    COMPILER="gcc"
  fi  
  export COMPILER
fi

if [ -n "${SCONS}" ]; then
  echo -e "${green} SCONS is defined ${happy_smiley} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : SCONS, use default one ${NC}"
  if [ `uname -s` == "SunOS" ]; then
    SCONS="/usr/local/bin/scons"
  else 
    SCONS="/usr/bin/scons"
  fi  
  export SCONS
fi

if [ -n "${SCONS_OPTS}" ]; then
  echo -e "${green} SCONS_OPTS is defined ${happy_smiley} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : SCONS_OPTS, use default one ${NC}"
  
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

if [ -n "${GIT_CMD}" ]; then
  echo -e "${green} GIT_CMD is defined ${happy_smiley} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : GIT_CMD, use the default one ${NC}"
  GIT_CMD="/usr/bin/git"
  if [ `uname -s` == "SunOS" ]; then
    GIT_CMD="/usr/local/bin/git"
  fi
  export GIT_CMD
fi

if [ -n "${TAR}" ]; then
  echo -e "${green} TAR is defined ${happy_smiley} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : TAR, use default one ${NC}"
  if [ `uname -s` == "SunOS" ]; then
    TAR="/usr/sfw/bin/gtar"
  elif [ `uname -s` == "Darwin" ]; then  
    TAR="/opt/local/bin/gnutar"  
  elif [ `uname -s` == "Linux" ]; then
    TAR="tar"  
  else 
    TAR="7z"  
  fi
  export TAR
fi

if [ -n "${WGET}" ]; then
  echo -e "${green} WGET is defined ${happy_smiley} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : WGET, use default one ${NC}"
  if [ `uname -s` == "SunOS" ]; then
    WGET="/opt/csw/bin/wget"
  elif [ `uname -s` == "Darwin" ]; then  
    WGET="/opt/local/bin/wget"  
  elif [ `uname -s` == "Linux" ]; then
    WGET="wget"  
  else 
    WGET="wget"  
  fi
  export WGET
fi

if [ -n "${TIBCO_HOME}" ]; then
  echo -e "${green} TIBCO_HOME is defined ${happy_smiley} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : TIBCO_HOME, use default one ${NC}"
  if [ `uname -s` == "Linux" ]; then
    TIBCO_HOME="/opt/tibco"
  else 
    TIBCO_HOME=""
  fi  
  export TIBCO_HOME
fi

if [ -n "${TIBRV_VERSION}" ]; then
  echo -e "${green} TIBRV_VERSION is defined ${happy_smiley} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : TIBRV_VERSION, use default one ${NC}"
  TIBRV_VERSION="8.4"
  export TIBRV_VERSION
fi

if [ -n "${TIBRV_HOME}" ]; then
  echo -e "${green} TIBRV_HOME is defined ${happy_smiley} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : TIBRV_HOME, use default one ${NC}"
  if [ `uname -s` == "Linux" ]; then
    TIBRV_HOME="${TIBCO_HOME}/tibrv/${TIBRV_VERSION}"
  else
    TIBRV_HOME=""
  fi  
  export TIBRV_HOME
fi

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$TIBRV_HOME/lib

#========================================= JAVA

if [ -n "${JAVA_SSL_OPTS}" ]; then
  echo -e "${green} JAVA_SSL_OPTS is defined ${happy_smiley} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : JAVA_HOME, please override ${NC}"
  #JAVA_SSL_OPTS="-Djavax.net.ssl.trustStore=/usr/local/share/ca-certificates/ca.crt"
  #export JAVA_SSL_OPTS
fi

if [ -n "${JAVA_TOOL_OPTIONS}" ]; then
  echo -e "${green} JAVA_TOOL_OPTIONS is defined ${happy_smiley} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : JAVA_TOOL_OPTIONS, please override ${NC}"
  #JAVA_TOOL_OPTIONS="-Dfile.encoding=UTF-8"
  #export JAVA_TOOL_OPTIONS
fi

if [ -n "${JAVA_HOME}" ]; then
  echo -e "${green} JAVA_HOME is defined ${happy_smiley} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : JAVA_HOME, use the default one ${NC}"
  JAVA_HOME=/usr/lib/jvm/java-8-oracle/
  if [ `uname -s` == "SunOS" ]; then
    JAVA_HOME=/usr/jdk/instances/jdk1.8.0_131/
  fi
  if [[ -d /dpool/jdk ]]; then
    JAVA_HOME=/dpool/jdk
  fi
  export JAVA_HOME
fi

if [ `uname -s` == "SunOS" ]; then
  PATH=$JAVA_HOME/bin:$PATH; export PATH
fi

if [ -n "${RELEASE_VERSION}" ]; then
  echo -e "${green} RELEASE_VERSION is defined ${happy_smiley} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : RELEASE_VERSION, use the default one ${NC}"
  RELEASE_VERSION="1.0.0"
  export RELEASE_VERSION
fi

if [ -n "${MVN_RELEASE_VERSION}" ]; then
  echo -e "${green} MVN_RELEASE_VERSION is defined ${happy_smiley} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : MVN_RELEASE_VERSION, use the default one ${NC}"
  MVN_RELEASE_VERSION=${RELEASE_VERSION}
  export MVN_RELEASE_VERSION
fi

if [ -n "${ZAP_PORT}" ]; then
  echo -e "${green} ZAP_PORT is defined ${happy_smiley} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : ZAP_PORT, use the default one ${NC}"
  ZAP_PORT=8090
  export ZAP_PORT
fi

if [[ -n "${HTTP_PROTOCOL}" ]]; then
  echo -e "${green} HTTP_PROTOCOL is defined ${happy_smiley} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : HTTP_PROTOCOL, use the default one ${NC}"
  export HTTP_PROTOCOL="https://"
fi

if [ -n "${SERVER_HOST}" ]; then
  echo -e "${green} SERVER_HOST is defined ${happy_smiley} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : SERVER_HOST, use the default one ${NC}"
  SERVER_HOST="albandri"
  export SERVER_HOST
fi

if [ -n "${SERVER_CONTEXT}" ]; then
  echo -e "${green} SERVER_URL is defined ${happy_smiley} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : SERVER_CONTEXT, use the default one ${NC}"
  SERVER_CONTEXT="/test"
  export SERVER_CONTEXT
fi

if [ -n "${SERVER_URL}" ]; then
  echo -e "${green} SERVER_URL is defined ${happy_smiley} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : SERVER_URL, use the default one ${NC}"
  SERVER_URL=${HTTP_PROTOCOL}${SERVER_HOST}${SERVER_CONTEXT}
  export SERVER_URL
fi

if [ -n "${ZAP_PORT}" ]; then
  echo -e "${green} ZAP_PORT is defined ${happy_smiley} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : ZAP_PORT, use the default one ${NC}"
  ZAP_PORT=8090
  export ZAP_PORT
fi

if [ -n "${JBOSS_PORT}" ]; then
  echo -e "${green} JBOSS_PORT is defined ${happy_smiley} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : JBOSS_PORT, use the default one ${NC}"
  JBOSS_PORT=8180
  export TOMCAT_PORT
fi

if [ -n "${TOMCAT_PORT}" ]; then
  echo -e "${green} TOMCAT_PORT is defined ${happy_smiley} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : TOMCAT_PORT, use the default one ${NC}"
  TOMCAT_PORT=8280
  export TOMCAT_PORT
fi

if [ -n "${JETTY_PORT}" ]; then
  echo -e "${green} JETTY_PORT is defined ${happy_smiley} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : JETTY_PORT, use the default one ${NC}"
  JETTY_PORT=9090
  export JETTY_PORT
fi

if [ -n "${CARGO_RMI_PORT}" ]; then
  echo -e "${green} CARGO_RMI_PORT is defined ${happy_smiley} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : CARGO_RMI_PORT, use the default one ${NC}"
  CARGO_RMI_PORT=44447
  export CARGO_RMI_PORT
fi

if [ -n "${CARGO_RMI_REGISTRY_PORT}" ]; then
  echo -e "${green} CARGO_RMI_REGISTRY_PORT is defined ${happy_smiley} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : CARGO_RMI_REGISTRY_PORT, use the default one ${NC}"
  CARGO_RMI_REGISTRY_PORT=1099
  export CARGO_RMI_REGISTRY_PORT
fi

if [ -n "${CARGO_HTTP_PORT}" ]; then
  echo -e "${green} CARGO_HTTP_PORT is defined ${happy_smiley} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : CARGO_HTTP_PORT, use the default one ${NC}"
  CARGO_HTTP_PORT=8181
  export CARGO_HTTP_PORT
fi

if [ -n "${CARGO_TELNET_PORT}" ]; then
  echo -e "${green} CARGO_TELNET_PORT is defined ${happy_smiley} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : CARGO_TELNET_PORT, use the default one ${NC}"
  CARGO_TELNET_PORT=8001
  export CARGO_TELNET_PORT
fi

if [ -n "${CARGO_SSH_PORT}" ]; then
  echo -e "${green} CARGO_SSH_PORT is defined ${happy_smiley} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : CARGO_SSH_PORT, use the default one ${NC}"
  CARGO_SSH_PORT=8444
  export CARGO_SSH_PORT
fi

if [ -n "${CARGO_AJP_PORT}" ]; then
  echo -e "${green} CARGO_AJP_PORT is defined ${happy_smiley} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : CARGO_AJP_PORT, use the default one ${NC}"
  CARGO_AJP_PORT=9009
  export CARGO_AJP_PORT
fi

if [ -n "${ECLIPSE_DEBUG_PORT}" ]; then
  echo -e "${green} ECLIPSE_DEBUG_PORT is defined ${happy_smiley} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : ECLIPSE_DEBUG_PORT, use the default one ${NC}"
  ECLIPSE_DEBUG_PORT=2924
  export ECLIPSE_DEBUG_PORT
fi

if [ -n "${CARGO_DEBUG_PORT}" ]; then
  echo -e "${green} CARGO_DEBUG_PORT is defined ${happy_smiley} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : CARGO_DEBUG_PORT, use the default one ${NC}"
  CARGO_DEBUG_PORT=5005
  export CARGO_DEBUG_PORT
fi

if [ -n "${REDIS_PORT}" ]; then
  echo -e "${green} REDIS_PORT is defined ${happy_smiley} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : REDIS_PORT, use the default one ${NC}"
  REDIS_PORT=6379
  export REDIS_PORT
fi

if [ -n "${H2_PORT}" ]; then
  echo -e "${green} H2_PORT is defined ${happy_smiley} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : H2_PORT, use the default one ${NC}"
  H2_PORT=5055
  export H2_PORT
fi

ENV_FILENAME="${WORKSPACE}/ENV_${ARCH}_VERSION.TXT"

echo -e "${NC}"

./step-2-0-1-build-env-info.sh > ${ENV_FILENAME}

#exit 0
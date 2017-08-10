#!/bin/bash
#set -xv

red='\e[0;31m'
green='\e[0;32m'
NC='\e[0m' # No Color

#========================================= CPP

echo "HOSTNAME : ${HOSTNAME}"
echo "SHELL : ${SHELL}"
echo "TERM : ${TERM}"
echo "HOME : ${HOME}"
echo "USER : ${USER}"
echo "PATH : ${PATH}"
echo "SCONS : ${SCONS} - ${SCONS_OPTS}"
echo "ARCH : ${ARCH}"

echo "WORKSPACE_SUFFIX : ${WORKSPACE_SUFFIX}"
echo "GIT_BRANCH_NAME : ${GIT_BRANCH_NAME}"

if [ -z "$PATH" ]; then  
  if [ `uname -s` == "SunOS" ]; then
    echo -e "${red} \u00BB Undefined build parameter \u2620 : PATH, use default one ${NC}"
    #Please do not enable NFS share on build server.
    #In case of NFS share issue we will not be able to perform an HF    
    #/opt/SUNWspro/bin 
    #mount    
    #PATH=/usr/local/bin:/usr/sbin:/usr/bin:/bin:/usr/ccs/bin:${SUNSTUDIO_HOME}/bin:/usr/sfw/bin:/opt/csw/bin; export PATH
    exit 1
  fi
fi

if [ -z "$SUNSTUDIO_HOME" ]; then
  echo -e "${red} \u00BB Undefined build parameter \u2620 : SUNSTUDIO_HOME, use default one ${NC}"
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
  echo -e "${red} \u00BB Undefined build parameter \u2620 : WORKSPACE ${NC}"
  exit 1
fi

#if [ -n "${GIT_BRANCH_NAME}" ]; then
#  echo "GIT_BRANCH_NAME is defined \u263A"
#else
#  echo -e "${red} \u00BB Undefined build parameter \u2620 : GIT_BRANCH_NAME, use the default one ${NC}"
#  export GIT_BRANCH_NAME="develop"
#fi

if [ -z "$WORKSPACE_SUFFIX" ]; then
  echo -e "${red} \u00BB Undefined build parameter \u2620 : WORKSPACE_SUFFIX, use default one ${NC}"
  export WORKSPACE_SUFFIX="cmr/CMR"
fi

if [ -z "$ARCH" ]; then
  echo -e "${red} \u00BB Undefined build parameter \u2620 : ARCH, use default one ${NC}"
  export ARCH="x86sol"
fi

if [ -z "$COMPILER" ]; then
  echo -e "${red} \u00BB Undefined build parameter \u2620 : COMPILER, use default one ${NC}"
  if [ `uname -s` == "SunOS" ]; then
    COMPILER="CC"
  else 
    COMPILER="gcc"
  fi  
  export COMPILER
fi

if [ -z "$SCONS" ]; then
  echo -e "${red} \u00BB Undefined build parameter \u2620 : SCONS, use default one ${NC}"
  if [ `uname -s` == "SunOS" ]; then
    SCONS="/usr/local/bin/scons"
  else 
    SCONS="/usr/bin/scons"
  fi  
  export SCONS
fi

if [ -z "$SCONS_OPTS" ]; then
  echo -e "${red} \u00BB Undefined build parameter \u2620 : SCONS_OPTS, use default one ${NC}"
  
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
  echo -e "GIT_CMD is defined \u263A"
else
  echo -e "${red} \u00BB Undefined build parameter \u2620 : GIT_CMD, use the default one ${NC}"
  GIT_CMD="/usr/bin/git"
  if [ `uname -s` == "SunOS" ]; then
    GIT_CMD="/usr/local/bin/git"
  fi
  export GIT_CMD
fi

if [ -z "$TAR" ]; then
  echo -e "${red} \u00BB Undefined build parameter \u2620 : TAR, use default one ${NC}"
  if [ `uname -s` == "SunOS" ]; then
    TAR="/usr/sfw/bin/gtar"
  else 
    TAR="tar"
  fi  
  export TAR
fi

if [ -z "$TIBCO_HOME" ]; then
  echo -e "${red} \u00BB Undefined build parameter \u2620 : TIBCO_HOME, use default one ${NC}"
  if [ `uname -s` == "Linux" ]; then
    TIBCO_HOME="/opt/tibco"
  else 
    TIBCO_HOME=""
  fi  
  export TIBCO_HOME
fi

if [ -z "$TIBRV_VERSION" ]; then
  echo -e "${red} \u00BB Undefined build parameter \u2620 : TIBRV_VERSION, use default one ${NC}"
  TIBRV_VERSION="8.4"
  export TIBRV_VERSION
fi

if [ -z "$TIBRV_HOME" ]; then
  echo -e "${red} \u00BB Undefined build parameter \u2620 : TIBRV_HOME, use default one ${NC}"
  if [ `uname -s` == "Linux" ]; then
    TIBRV_HOME="${TIBCO_HOME}/tibrv/${TIBRV_VERSION}"
  else
    TIBRV_HOME=""
  fi  
  export TIBRV_HOME
fi

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$TIBRV_HOME/lib

#========================================= JAVA

if [ -n "${JAVA_HOME}" ]; then
  echo -e "JAVA_HOME is defined \u263A"
else
  echo -e "${red} \u00BB Undefined build parameter \u2620 : JAVA_HOME, use the default one ${NC}"
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

if [ -n "${ZAP_PORT}" ]; then
  echo -e "ZAP_PORT is defined \u263A"
else
  echo -e "${red} \u00BB Undefined build parameter \u2620 : ZAP_PORT, use the default one ${NC}"
  ZAP_PORT=8090
  export ZAP_PORT
fi

if [[ -n "${HTTP_PROTOCOL}" ]]; then
  echo -e "HTTP_PROTOCOL is defined \u263A"
else
  echo -e "${red} \u00BB Undefined build parameter \u2620 : HTTP_PROTOCOL, use the default one ${NC}"
  export HTTP_PROTOCOL="https://"
fi

if [ -n "${SERVER_HOST}" ]; then
  echo -e "SERVER_HOST is defined \u263A"
else
  echo -e "${red} \u00BB Undefined build parameter \u2620 : SERVER_HOST, use the default one ${NC}"
  SERVER_HOST="albandri"
  export SERVER_HOST
fi

if [ -n "${SERVER_CONTEXT}" ]; then
  echo -e "SERVER_URL is defined \u263A"
else
  echo -e "${red} \u00BB Undefined build parameter \u2620 : SERVER_CONTEXT, use the default one ${NC}"
  SERVER_CONTEXT="/test"
  export SERVER_CONTEXT
fi

if [ -n "${SERVER_URL}" ]; then
  echo -e "SERVER_URL is defined \u263A"
else
  echo -e "${red} \u00BB Undefined build parameter \u2620 : SERVER_URL, use the default one ${NC}"
  SERVER_URL=${HTTP_PROTOCOL}${SERVER_HOST}${SERVER_CONTEXT}
  export SERVER_URL
fi

if [ -n "${ZAP_PORT}" ]; then
  echo -e "ZAP_PORT is defined \u263A"
else
  echo -e "${red} \u00BB Undefined build parameter \u2620 : ZAP_PORT, use the default one ${NC}"
  ZAP_PORT=8090
  export ZAP_PORT
fi

if [ -n "${JBOSS_PORT}" ]; then
  echo -e "JBOSS_PORT is defined \u263A"
else
  echo -e "${red} \u00BB Undefined build parameter \u2620 : JBOSS_PORT, use the default one ${NC}"
  JBOSS_PORT=8180
  export TOMCAT_PORT
fi

if [ -n "${TOMCAT_PORT}" ]; then
  echo -e "TOMCAT_PORT is defined \u263A"
else
  echo -e "${red} \u00BB Undefined build parameter \u2620 : TOMCAT_PORT, use the default one ${NC}"
  TOMCAT_PORT=8280
  export TOMCAT_PORT
fi

if [ -n "${JETTY_PORT}" ]; then
  echo -e "JETTY_PORT is defined \u263A"
else
  echo -e "${red} \u00BB Undefined build parameter \u2620 : JETTY_PORT, use the default one ${NC}"
  JETTY_PORT=9090
  export JETTY_PORT
fi

if [ -n "${CARGO_RMI_PORT}" ]; then
  echo -e "CARGO_RMI_PORT is defined \u263A"
else
  echo -e "${red} \u00BB Undefined build parameter \u2620 : CARGO_RMI_PORT, use the default one ${NC}"
  CARGO_RMI_PORT=44447
  export CARGO_RMI_PORT
fi

if [ -n "${CARGO_RMI_REGISTRY_PORT}" ]; then
  echo -e "CARGO_RMI_REGISTRY_PORT is defined \u263A"
else
  echo -e "${red} \u00BB Undefined build parameter \u2620 : CARGO_RMI_REGISTRY_PORT, use the default one ${NC}"
  CARGO_RMI_REGISTRY_PORT=1099
  export CARGO_RMI_REGISTRY_PORT
fi

if [ -n "${CARGO_HTTP_PORT}" ]; then
  echo -e "CARGO_HTTP_PORT is defined \u263A"
else
  echo -e "${red} \u00BB Undefined build parameter \u2620 : CARGO_HTTP_PORT, use the default one ${NC}"
  CARGO_HTTP_PORT=8181
  export CARGO_HTTP_PORT
fi

if [ -n "${CARGO_TELNET_PORT}" ]; then
  echo -e "CARGO_TELNET_PORT is defined \u263A"
else
  echo -e "${red} \u00BB Undefined build parameter \u2620 : CARGO_TELNET_PORT, use the default one ${NC}"
  CARGO_TELNET_PORT=8001
  export CARGO_TELNET_PORT
fi

if [ -n "${CARGO_SSH_PORT}" ]; then
  echo -e "CARGO_SSH_PORT is defined \u263A"
else
  echo -e "${red} \u00BB Undefined build parameter \u2620 : CARGO_SSH_PORT, use the default one ${NC}"
  CARGO_SSH_PORT=8444
  export CARGO_SSH_PORT
fi

if [ -n "${CARGO_AJP_PORT}" ]; then
  echo -e "CARGO_AJP_PORT is defined \u263A"
else
  echo -e "${red} \u00BB Undefined build parameter \u2620 : CARGO_AJP_PORT, use the default one ${NC}"
  CARGO_AJP_PORT=9009
  export CARGO_AJP_PORT
fi

if [ -n "${ECLIPSE_DEBUG_PORT}" ]; then
  echo -e "ECLIPSE_DEBUG_PORT is defined \u263A"
else
  echo -e "${red} \u00BB Undefined build parameter \u2620 : ECLIPSE_DEBUG_PORT, use the default one ${NC}"
  ECLIPSE_DEBUG_PORT=2924
  export ECLIPSE_DEBUG_PORT
fi

if [ -n "${CARGO_DEBUG_PORT}" ]; then
  echo -e "CARGO_DEBUG_PORT is defined \u263A"
else
  echo -e "${red} \u00BB Undefined build parameter \u2620 : CARGO_DEBUG_PORT, use the default one ${NC}"
  CARGO_DEBUG_PORT=5005
  export CARGO_DEBUG_PORT
fi

if [ -n "${REDIS_PORT}" ]; then
  echo -e "REDIS_PORT is defined \u263A"
else
  echo -e "${red} \u00BB Undefined build parameter \u2620 : REDIS_PORT, use the default one ${NC}"
  REDIS_PORT=6379
  export REDIS_PORT
fi

if [ -n "${H2_PORT}" ]; then
  echo -e "H2_PORT is defined \u263A"
else
  echo -e "${red} \u00BB Undefined build parameter \u2620 : H2_PORT, use the default one ${NC}"
  H2_PORT=5055
  export H2_PORT
fi

if [ `uname -s` == "Linux" ]; then
  #browser version
  /usr/bin/firefox  -V || true
  /usr/lib/firefox/firefox -V || true
  /usr/bin/chromium-browser --version || true
  /opt/google/chrome/chrome --version || true
  #javascript version
  phantomjs --version || true
  nodejs --version || true
  node --version || true
  bower --version || true
  npm --version || true
  grunt --version || true
  yarn --version || true
  mvn --version || true
  #tools version
  docker --version || true
  git --version || true
  git config --global --list || true
  svn --version || true
  #cpp version
  clang --version || true
  ps-gen || true
  openssl version || true
fi

#=========================================

ENV_FILENAME="${WORKSPACE}/ENV_${ARCH}_VERSION.TXT"

echo "========== OS =========="  > ${ENV_FILENAME}
echo "Operating system name, release, version, node name, hardware name, and processor type"  >> ${ENV_FILENAME}
uname -a 2>&1 >> ${ENV_FILENAME}
hostid 2>&1 >> ${ENV_FILENAME}
if [ `uname -s` == "SunOS" ]; then
  #/usr/sbin/psrinfo -v 2>&1 >> ${ENV_FILENAME}
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
echo "PATH : ${PATH}" 2>&1 >> ${ENV_FILENAME}
echo "LD_LIBRARY_PATH : ${LD_LIBRARY_PATH}" 2>&1 >> ${ENV_FILENAME}
echo "LIBPATH : ${LIBPATH}" 2>&1 >> ${ENV_FILENAME}

echo "========== PERL =========="  >> ${ENV_FILENAME}
perl --version 2>&1 >> ${ENV_FILENAME}
perl -V 2>&1 >> ${ENV_FILENAME}
echo "========== PYTHON =========="  >> ${ENV_FILENAME}
python -V 2>&1 >> ${ENV_FILENAME}
pip -V 2>&1 >> ${ENV_FILENAME}
echo "========== MISC =========="  >> ${ENV_FILENAME}
${TAR} --version 2>&1 >> ${ENV_FILENAME}
${GIT_CMD} --version 2>&1 >> ${ENV_FILENAME}
mvn --version 2>&1 >> ${ENV_FILENAME}
echo "========== TIBCO =========="  >> ${ENV_FILENAME}
echo "TIBCO_HOME : ${TIBCO_HOME}" 2>&1 >> ${ENV_FILENAME}
echo "TIBRV_HOME : ${TIBRV_HOME}" 2>&1 >> ${ENV_FILENAME}

echo "========== JAVA =========="  >> ${ENV_FILENAME}
java -version 2>&1 >> ${ENV_FILENAME}
echo "JAVA_HOME ${JAVA_HOME}"  >> ${ENV_FILENAME}
echo "NODE_PATH ${NODE_PATH}"  >> ${ENV_FILENAME}
echo "========== MAVEN =========="  >> ${ENV_FILENAME}
echo "DISPLAY ${DISPLAY}"  >> ${ENV_FILENAME}
echo "BUILD_NUMBER: ${BUILD_NUMBER}"  >> ${ENV_FILENAME}
echo "BUILD_ID: ${BUILD_ID}"  >> ${ENV_FILENAME}
echo "IS_M2RELEASEBUILD: ${IS_M2RELEASEBUILD}"  >> ${ENV_FILENAME}
echo "========== SERVER =========="  >> ${ENV_FILENAME}
echo "SERVER_HOST : ${SERVER_HOST}"  >> ${ENV_FILENAME}
echo "SERVER_CONTEXT: ${SERVER_CONTEXT}"  >> ${ENV_FILENAME}
echo "SERVER_URL: ${SERVER_URL}"  >> ${ENV_FILENAME}
echo "========== ZAP =========="  >> ${ENV_FILENAME}
echo "ZAP_PORT : ${ZAP_PORT}"  >> ${ENV_FILENAME}
echo "ZAPROXY_HOME : ${ZAPROXY_HOME}"  >> ${ENV_FILENAME}
echo "========== PORT =========="  >> ${ENV_FILENAME}
echo "TOMCAT_PORT : ${TOMCAT_PORT}"  >> ${ENV_FILENAME}
echo "JETTY_PORT : ${JETTY_PORT}"  >> ${ENV_FILENAME}
echo "CARGO_RMI_PORT : ${CARGO_RMI_PORT}"  >> ${ENV_FILENAME}

echo "========== ENV =========="  >> ${ENV_FILENAME}
#env 2>&1 >> ${ENV_FILENAME}

exit 0

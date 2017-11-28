#!/bin/bash
#set -xv

#=========================================

echo -e "========== OS =========="
echo -e "Operating system name, release, version, node name, hardware name, and processor type"
echo "$(uname -a)" 2>&1
echo -e "========== HOSTID =========="
hostid 2>&1
echo -e "========== OSTYPE =========="
echo "OSTYPE : ${OSTYPE}"
case "$OSTYPE" in
  linux*)   echo "LINUX" ;;
  darwin*)  echo "OSX" ;;
  win*)     echo "Windows" ;;
  cygwin*)  echo "Cygwin" ;;
  msys*)    echo "MSYS" ;;
  bsd*)     echo "BSD" ;;
  solaris*) echo "SOLARIS" ;;
  *)        echo "unknown: $OSTYPE" ;;
esac
echo -e "========== RELEASE =========="
if [ "$(uname -s)" == "SunOS" ]; then
  #/usr/sbin/psrinfo -v 2>&1
  isalist 2>&1 || true
  showrev 2>&1 || true 
  #shorew -p | grep 138411
  cat /etc/release 2>&1 || true
elif [ "$(uname -s)" == "Darwin" ]; then
  sw_vers -productVersion 2>&1 || true
elif [ "$(uname -s)" == "FreeBSD" ]; then
  freebsd-version 2>&1 || true 
elif [ "$(uname -s)" == "Linux" ]; then
  #pinguin
  echo -e "\U1F427"
  lsb_release 2>&1 || true 
fi

ENV_FILE="jenkins-env.groovy"
echo "========== COMPILER =========="
if [ -n "${SCONS}" ]; then
  "${SCONS}" --version 2>&1 || true
fi
if [ "$(uname -s)" == "SunOS" ]; then
  type cc 2>&1 || true
  cc -V 2>&1 || true
  type CC 2>&1 || true
  CC -V 2>&1 || true
elif [ "$(uname -s)" == "FreeBSD" ]; then
  type cc 2>&1 || true
  cc -V 2>&1 || true
  type CC 2>&1 || true
  CC -V 2>&1 || true
elif [ "$(uname -s)" == "Darwin" ]; then
  xcodebuild -version 2>&1 || true
  port version 2>&1 || true
elif [ "$(uname -s)" == "Linux" ]; then
  gcc --version 2>&1 || true
  #cpp version
  clang --version  2>&1 || true
  #cl
#elif [ "$(uname -s)" == "MINGW64_NT-6.1" || "$(uname -s)" == "CYGWIN_NT-6.1" || "$(uname -s)" == "MSYS_NT-6.1" ]; then
elif [ "$(echo $(uname -s) | cut -c 1-10)" == "MINGW32_NT" ]; then
  echo "========== MINGW 32 =========="
  echo "MSYSTEM : ${MSYSTEM}"
  gcc --version 2>&1 || true
elif [ "$(echo $(uname -s) | cut -c 1-10)" == "MINGW64_NT" ]; then
  echo "========== MINGW 64 =========="
  echo "MSYSTEM : ${MSYSTEM}"
  gcc --version 2>&1 || true
elif [ "$(echo $(uname -s) | cut -c 1-7)" == "MSYS_NT" ]; then
  echo "========== MSYS =========="
  echo "MSYSTEM : ${MSYSTEM}"
  gcc --version 2>&1 || true
elif [ "$(echo $(uname -s) | cut -c 1-9)" == "CYGWIN_NT" ]; then
  echo "========== CYGWIN =========="
  echo "MSYSTEM : ${MSYSTEM}"
  gcc --version 2>&1 || true
fi

echo "PATH : ${PATH}" 2>&1
echo "LD_LIBRARY_PATH : ${LD_LIBRARY_PATH}" 2>&1
echo "TMPDIR : ${TMPDIR}" 2>&1
echo "LIBPATH : ${LIBPATH}" 2>&1
echo "LOCALE : ${LANG}" 2>&1
echo "========== PERL =========="
perl --version 2>&1 || true
perl -V 2>&1 || true
echo "========== PYTHON =========="
python -V 2>&1 || true 
pip -V 2>&1 || true
echo "========== ANSIBLE =========="
ansible --version 2>&1 || true
ansible-galaxy --version 2>&1 || true
echo "========== MISC =========="
if [ -n "${TAR}" ]; then
  "${TAR}" --version 2>&1 || true
fi
if [ -n "${GIT_CMD}" ]; then
  "${GIT_CMD}" --version 2>&1 || true
fi
mvn --version 2>&1 || true
brew --version 2>&1 || true
echo "env.MSVC_VERSION=\"${MSVC_VERSION}\"" > ${ENV_FILE}
echo "========== TIBCO =========="
echo "TIBCO_HOME : ${TIBCO_HOME}" 2>&1
echo "TIBRV_HOME : ${TIBRV_HOME}" 2>&1
echo "========== DATABASE =========="
sqlplus -V 2>&1 || true
isql --version 2>&1 || true
odbcinst --version 2>&1 || true
which tsql 2>&1 || true
which osql 2>&1 || true

echo "========== JAVA =========="
java -version 2>&1 || true
echo "JAVA_HOME ${JAVA_HOME}"
echo "NODE_PATH ${NODE_PATH}"
echo "========== MAVEN =========="
echo "DISPLAY ${DISPLAY}"
echo "BUILD_NUMBER: ${BUILD_NUMBER}"
echo "BUILD_ID: ${BUILD_ID}"
echo "GIT_BRANCH_NAME : ${GIT_BRANCH_NAME}"
echo "GIT_BRANCH : ${GIT_BRANCH}"
echo "GIT_COMMIT : ${GIT_COMMIT}"
echo "IS_M2RELEASEBUILD: ${IS_M2RELEASEBUILD}"
echo "env.IS_M2RELEASEBUILD=\"${IS_M2RELEASEBUILD}\"" >> ${ENV_FILE}
echo "========== SERVER =========="
echo "SERVER_HOST : ${SERVER_HOST}"
echo "env.SERVER_HOST=\"${SERVER_HOST}\"" >> ${ENV_FILE}
echo "SERVER_CONTEXT: ${SERVER_CONTEXT}"
echo "env.SERVER_CONTEXT=\"${SERVER_CONTEXT}\"" >> ${ENV_FILE}
echo "SERVER_URL: ${SERVER_URL}"
echo "env.SERVER_URL=\"${SERVER_URL}\"" >> ${ENV_FILE}
echo "========== ZAP =========="
echo "ZAP_PORT : ${ZAP_PORT}"
echo "env.ZAP_PORT=\"${ZAP_PORT}\"" >> ${ENV_FILE}
echo "ZAPROXY_HOME : ${ZAPROXY_HOME}"
echo "env.ZAPROXY_HOME=\"${ZAPROXY_HOME}\"" >> ${ENV_FILE}
echo "========== PORT =========="
echo "TOMCAT_PORT : ${TOMCAT_PORT}"
echo "JETTY_PORT : ${JETTY_PORT}"
echo "CARGO_RMI_PORT : ${CARGO_RMI_PORT}"

echo "========== TOOLS =========="

if [ "$(uname -s)" == "Linux" ]; then
  echo "========== BROWSER =========="
  /usr/bin/firefox  -V || true
  /usr/lib/firefox/firefox -V || true
  /usr/bin/chromium-browser --version || true
  /opt/google/chrome/chrome --version || true
  echo "========== JAVASCRIPT =========="
  phantomjs --version || true
  nodejs --version || true
  node --version || true
  bower --version || true
  npm --version || true
  grunt --version || true
  yarn --version || true
  echo "========== BUILD TOOLS =========="
  mvn --version || true
  docker --version || true
  echo "========== SCM =========="
  git --version || true
  git config --global --list || true
  svn --version || true
  echo "========== CPP TOOLS =========="
  openssl version || true
  echo "========== TOOLS =========="
  /sbin/ldconfig -p | grep stdc++ || true
fi

echo "========== ENV =========="
#env is already displayed in jenkins
printenv
#env 2>&1

echo "env.SONAR_BRANCH=\"$(printf '%s' $GIT_BRANCH | cut -d'/' -f 2-)\"" >> ${ENV_FILE}
echo "env.RELEASE_VERSION=\"${RELEASE_VERSION}\"" >> ${ENV_FILE}
echo "env.MVN_RELEASE_VERSION=\"${MVN_RELEASE_VERSION}\"" >> ${ENV_FILE}

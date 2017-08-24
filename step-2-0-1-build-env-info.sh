#!/bin/bash
#set -xv

#=========================================

echo -e "========== OS =========="
echo -e "Operating system name, release, version, node name, hardware name, and processor type"
echo "$(uname -a)" 2>&1
echo -e "========== HOSTID =========="
hostid 2>&1
echo -e "========== RELEASE =========="
if [ `uname -s` == "SunOS" ]; then
  #/usr/sbin/psrinfo -v 2>&1
  isalist 2>&1 || true
  showrev 2>&1 || true 
  #shorew -p | grep 138411
  cat /etc/release 2>&1 || true
elif [ `uname -s` == "Linux" ]; then
  lsb_release 2>&1 || true 
fi
echo "========== COMPILER =========="
${SCONS} --version 2>&1 || true 
if [ `uname -s` == "SunOS" ]; then
  type cc 2>&1 || true
  cc -V 2>&1 || true
  type CC 2>&1 || true
  CC -V 2>&1 || true
elif [ `uname -s` == "Darwin" ]; then  
  xcodebuild -version 2>&1 || true
  port version 2>&1 || true
elif [ `uname -s` == "Linux" ]; then
  gcc --version 2>&1 || true
fi

echo "PATH : ${PATH}" 2>&1
echo "LD_LIBRARY_PATH : ${LD_LIBRARY_PATH}" 2>&1
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
${TAR} --version 2>&1 || true
${GIT_CMD} --version 2>&1 || true
mvn --version 2>&1 || true
brew --version 2>&1 || true
echo "========== TIBCO =========="
echo "TIBCO_HOME : ${TIBCO_HOME}" 2>&1
echo "TIBRV_HOME : ${TIBRV_HOME}" 2>&1

echo "========== JAVA =========="
java -version 2>&1 || true
echo "JAVA_HOME ${JAVA_HOME}"
echo "NODE_PATH ${NODE_PATH}"
echo "========== MAVEN =========="
echo "DISPLAY ${DISPLAY}"
echo "BUILD_NUMBER: ${BUILD_NUMBER}"
echo "BUILD_ID: ${BUILD_ID}"
echo "IS_M2RELEASEBUILD: ${IS_M2RELEASEBUILD}"
echo IS_M2RELEASEBUILD=${IS_M2RELEASEBUILD} > jenkins-env
echo "========== SERVER =========="
echo "SERVER_HOST : ${SERVER_HOST}"
echo SERVER_HOST=${SERVER_HOST} >> jenkins-env
echo "SERVER_CONTEXT: ${SERVER_CONTEXT}"
echo SERVER_CONTEXT=${SERVER_CONTEXT} >> jenkins-env
echo "SERVER_URL: ${SERVER_URL}"
echo SERVER_URL=${SERVER_URL} >> jenkins-env
echo "========== ZAP =========="
echo "ZAP_PORT : ${ZAP_PORT}"
echo ZAP_PORT=${ZAP_PORT} >> jenkins-env
echo "ZAPROXY_HOME : ${ZAPROXY_HOME}"
echo ZAPROXY_HOME=${ZAPROXY_HOME} >> jenkins-env
echo "========== PORT =========="
echo "TOMCAT_PORT : ${TOMCAT_PORT}"
echo "JETTY_PORT : ${JETTY_PORT}"
echo "CARGO_RMI_PORT : ${CARGO_RMI_PORT}"

echo "========== TOOLS =========="

if [ `uname -s` == "Linux" ]; then
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
  #cpp version
  clang --version || true
  ps-gen || true
  openssl version || true
  echo "========== TOOLS =========="
  /sbin/ldconfig -p | grep stdc++ || true
fi

echo "========== ENV =========="
#env is already displayed in jenkins
#env 2>&1

echo SONAR_BRANCH=$(printf '%s' $GIT_BRANCH | cut -d'/' -f 2-) >> jenkins-env
echo RELEASE_VERSION=${RELEASE_VERSION} >> jenkins-env
echo MVN_RELEASE_VERSION=${MVN_RELEASE_VERSION} >> jenkins-env

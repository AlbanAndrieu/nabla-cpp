#!/bin/bash
#set -xv
shopt -s extglob

#set -ueo pipefail
set -eo pipefail

WORKING_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}"  )" && pwd  )"

export DOCKER_NAME=${DOCKER_NAME:-"nabla-cpp"}
#export DOCKER_FILE="../docker/ubuntu18/Dockerfile"
export DOCKER_FILE="../Dockerfile"

# shellcheck source=/dev/null
source "${WORKING_DIR}/docker-env.sh"

echo -e "${green} Validating Docker ${NC}"
echo -e "${magenta} hadolint ${WORKING_DIR}/${DOCKER_FILE} ${NC}"
hadolint "${WORKING_DIR}/${DOCKER_FILE}" || true | tee -a docker-hadolint.log
echo -e "${magenta} dockerfile_lint --json --verbose --dockerfile ${WORKING_DIR}/${DOCKER_FILE} ${NC}"
dockerfile_lint --json --verbose --dockerfile "${WORKING_DIR}/${DOCKER_FILE}"|| true | tee -a docker-dockerfilelint.log

# shellcheck source=/dev/null
#source "${WORKING_DIR}/run-ansible.sh"
WORKING_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}"  )" && pwd  )"
"${WORKING_DIR}/../clean.sh"

if [ -n "${DOCKER_BUILD_ARGS}" ]; then
  echo -e "${green} DOCKER_BUILD_ARGS is defined ${happy_smiley} : ${DOCKER_BUILD_ARGS} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : DOCKER_BUILD_ARGS, use the default one ${NC}"
  export DOCKER_BUILD_ARGS="--pull"
  #export DOCKER_BUILD_ARGS="--build-arg --no-cache --target runtime"
  echo -e "${magenta} DOCKER_BUILD_ARGS : ${DOCKER_BUILD_ARGS} ${NC}"
fi

echo -e "${green} Building docker image ${NC}"
echo -e "${magenta} time docker build ${DOCKER_BUILD_ARGS} -f ${WORKING_DIR}/${DOCKER_FILE} -t \"$DOCKER_ORGANISATION/$DOCKER_NAME\" -t \"${DOCKER_ORGANISATION}/${DOCKER_NAME}:${DOCKER_TAG}\" ${WORKING_DIR}/../ ${NC}"
time docker build ${DOCKER_BUILD_ARGS} -f ${WORKING_DIR}/${DOCKER_FILE} -t "${DOCKER_ORGANISATION}/${DOCKER_NAME}" -t "${DOCKER_ORGANISATION}/${DOCKER_NAME}:${DOCKER_TAG}" ${WORKING_DIR}/../ | tee docker.log
RC=$?
if [ ${RC} -ne 0 ]; then
  echo ""
  # shellcheck disable=SC2154
  echo -e "${red} ${head_skull} Sorry, build failed. ${NC}"
  exit 1
else
  echo -e "${green} The build completed successfully. ${NC}"
  echo -e "${magenta} Running docker history to docker history ${NC}"
  echo -e "    docker history --no-trunc ${DOCKER_ORGANISATION}/${DOCKER_NAME}:latest > docker-history.log"
  docker history --no-trunc ${DOCKER_ORGANISATION}/${DOCKER_NAME}:latest > docker-history.log
  echo -e "${magenta} Running dive ${NC}"
  echo -e "    dive ${DOCKER_ORGANISATION}/${DOCKER_NAME}:latest"
  CI=true dive "${DOCKER_ORGANISATION}/${DOCKER_NAME}:latest" || true | tee -a docker-dive.log
  RC=$?
  if [ ${RC} -ne 0 ]; then
    echo ""
    echo -e "${red} ${head_skull} Sorry, dive failed ${NC}"
    #exit 1
  fi

  echo -e "${green} Tagging the image. ${NC}"
  docker tag "${DOCKER_ORGANISATION}/${DOCKER_NAME}:latest" "${DOCKER_REGISTRY}${DOCKER_ORGANISATION}/${DOCKER_NAME}:${DOCKER_TAG}"
fi

echo -e ""
echo -e "${green} This image is a trusted docker Image. ${happy_smiley} ${NC}"
echo -e ""
echo -e "To push it"
echo -e "    docker login ${DOCKER_REGISTRY} --username ${DOCKER_USERNAME} --password password"
echo -e "    docker tag ${DOCKER_ORGANISATION}/${DOCKER_NAME}:latest ${DOCKER_REGISTRY}${DOCKER_ORGANISATION}/${DOCKER_NAME}:${DOCKER_TAG}"
echo -e "    docker push ${DOCKER_REGISTRY}${DOCKER_ORGANISATION}/${DOCKER_NAME}"
echo -e ""
echo -e "To pull it"
echo -e "    docker pull ${DOCKER_REGISTRY}${DOCKER_ORGANISATION}/${DOCKER_NAME}:${DOCKER_TAG}"
echo -e ""
echo -e "To use this docker:"
echo -e "    docker run -d -P ${DOCKER_ORGANISATION}/${DOCKER_NAME}"
echo -e " - to attach your container directly to the host's network interfaces"
echo -e "    docker run --net host -d -P ${DOCKER_ORGANISATION}/${DOCKER_NAME}"
echo -e ""
echo -e "To run in interactive mode for debug:"
echo -e "    docker run -it --entrypoint /bin/bash ${DOCKER_ORGANISATION}/${DOCKER_NAME}:latest"
echo -e "    docker run -it -d --name sandbox ${DOCKER_ORGANISATION}/${DOCKER_NAME}:latest"
echo -e "    docker exec -it sandbox /bin/bash"
echo -e ""

echo -e "docker build -t ${DOCKER_ORGANISATION}/${DOCKER_NAME}:latest --pull -f ${WORKING_DIR}/${DOCKER_FILE} ./"
echo -e "docker run -p 8080:8080 -t ${DOCKER_ORGANISATION}/${DOCKER_NAME}:latest --version"
echo -e "docker run -p 8080:8080 -t ${DOCKER_ORGANISATION}/${DOCKER_NAME}:latest /home/jenkins/test.war"
echo -e ""

export CST_CONFIG="config.yaml"

"${WORKING_DIR}/docker-test.sh" "${DOCKER_NAME}"

exit 0

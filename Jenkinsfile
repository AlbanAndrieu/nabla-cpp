#!/usr/bin/env groovy
@Library(value='jenkins-pipeline-scripts@master', changelog=false) _

String DOCKER_REGISTRY_HUB=env.DOCKER_REGISTRY_HUB ?: "registry.hub.docker.com".toLowerCase().trim() // registry.hub.docker.com
String DOCKER_ORGANISATION_HUB="nabla".trim()
String DOCKER_IMAGE_TAG=env.DOCKER_IMAGE_TAG ?: "latest".trim()
//String DOCKER_USERNAME="nabla"
String DOCKER_NAME="ansible-jenkins-slave-docker".trim()

String DOCKER_REGISTRY_HUB_URL=env.DOCKER_REGISTRY_HUB_URL ?: "https://${DOCKER_REGISTRY_HUB}".trim()
String DOCKER_REGISTRY_HUB_CREDENTIAL=env.DOCKER_REGISTRY_HUB_CREDENTIAL ?: "hub-docker-nabla".trim()
String DOCKER_IMAGE="${DOCKER_ORGANISATION_HUB}/${DOCKER_NAME}:${DOCKER_IMAGE_TAG}".trim()

String DOCKER_OPTS_BASIC = getDockerOpts()
String DOCKER_OPTS_COMPOSE = getDockerOpts(isDockerCompose: true, isLocalJenkinsUser: false)

String DOCKER_NAME_BUILD="ansible-jenkins-slave-test".trim()
String DOCKER_BUILD_TAG=dockerTag("temp").trim()
String DOCKER_BUILD_IMG="${DOCKER_ORGANISATION_HUB}/${DOCKER_NAME_BUILD}:${DOCKER_BUILD_TAG}".trim()
String DOCKER_RUNTIME_TAG="latest".trim()
String DOCKER_RUNTIME_NAME="nabla-servers-bower-sample-test".trim()
String DOCKER_RUNTIME_IMG="${DOCKER_ORGANISATION_HUB}/${DOCKER_RUNTIME_NAME}:${DOCKER_RUNTIME_TAG}".trim()

String RELEASE_VERSION=""
//String GIT_COMMIT_REV=""

def NODES_USED = []

String ARTIFACTS = ['*_VERSION.TXT',
                '**/target/*.log',
                //'**/target/*.jar',
                '**/target/dependency/jetty-runner.jar',
                '**/target/test.war',
                //'**/target/*.zip',
                'reports/*',
                '**/MD5SUMS.md5',
                'package-lock.json',
                'yarn.lock',
                'Jenkinsfile*',
                'Dockerfile*',
                '*.tar.gz'
                ].join(', ')

pipeline {
    //agent none
    //agent {
    //    label 'ubuntu'
    //}
	agent {
		docker {
			image DOCKER_IMAGE
			alwaysPull true
			reuseNode true
			registryUrl DOCKER_REGISTRY_HUB_URL
			registryCredentialsId DOCKER_REGISTRY_HUB_CREDENTIAL
			args DOCKER_OPTS_BASIC
			label 'ubuntu'
		}
	}
    //agent {
    //    // Equivalent to "docker build -f Dockerfile-jenkins-slave-ubuntu:16.04 --build-arg FILEBEAT_VERSION=6.3.0 ./build/
    //    dockerfile {
    //        //filename 'Dockerfile'
    //        //dir 'build'
    //        label 'molecule'
    //        additionalBuildArgs ' --build-arg JENKINS_USER_HOME=/home/jenkins --label "version=1.0.1" --label "maintaner=Alban Andrieu <alban.andrieu@gmail.com>" '
    //    }
    //}
    parameters {
        string(defaultValue: 'master', description: 'Default git branch to override', name: 'GIT_BRANCH_NAME', trim: true)
        string(defaultValue: '44447', description: 'Default cargo rmi port to override', name: 'CARGO_RMI_PORT', trim: true)
        string(defaultValue: '', description: 'Default workspace suffix to override', name: 'WORKSPACE_SUFFIX', trim: true)
        string(defaultValue: 'http://localhost:9190', description: 'Default URL used by deployment tests', name: 'SERVER_URL', trim: true)
        string(defaultValue: '/test/#/', description: 'Default context', name: 'SERVER_CONTEXT', trim: true)
        string(defaultValue: 'LATEST_SUCCESSFULL', description: 'Create a TAG', name: 'TARGET_TAG', trim: true)
        string(defaultValue: 'jenkins', description: 'User', name: 'TARGET_USER', trim: true)
        booleanParam(defaultValue: false, description: 'Dry run', name: 'DRY_RUN')
        booleanParam(defaultValue: false, description: 'Clean before run', name: 'CLEAN_RUN')
        booleanParam(defaultValue: false, description: 'Debug run', name: 'DEBUG_RUN')
        booleanParam(defaultValue: false, description: 'Debug mvnw', name: 'MVNW_VERBOSE')
        booleanParam(defaultValue: false, name: "RELEASE", description: "Perform release-type build.")
        string(defaultValue: "", name: "RELEASE_BASE", description: "Commit tag or branch that should be checked-out for release", trim: true)
        string(defaultValue: "", name: "RELEASE_VERSION", description: "Release version for artifacts", trim: true)
    }
    environment {
        GIT_BRANCH_NAME = "${params.GIT_BRANCH_NAME}".trim()
        //BRANCH_JIRA = "${env.BRANCH_NAME}".replaceAll("feature/","")
        //PROJECT_BRANCH = "${env.GIT_BRANCH}".replaceFirst("origin/","")
        CARGO_RMI_PORT = "${params.CARGO_RMI_PORT}"
        //WORKSPACE_SUFFIX = "${params.WORKSPACE_SUFFIX}"
        //echo "JOB_NAME: ${env.JOB_NAME} : ${env.JOB_BASE_NAME}"
        //TARGET_PROJECT = sh(returnStdout: true, script: "echo ${env.JOB_NAME} | cut -d'/' -f -1").trim()
        //BRANCH_NAME = "${env.BRANCH_NAME}".replaceAll("feature/","")
        BUILD_ID = "${env.BUILD_ID}"
        DRY_RUN = "${params.DRY_RUN}".toBoolean()
        CLEAN_RUN = "${params.CLEAN_RUN}".toBoolean()
        DEBUG_RUN = "${params.DEBUG_RUN}".toBoolean()
        MVNW_VERBOSE = "${params.MVNW_VERBOSE}".toBoolean()
        SERVER_URL = "${params.SERVER_URL}"
        SERVER_CONTEXT = "${params.SERVER_CONTEXT}"
        RELEASE = "${params.RELEASE}".toBoolean()
        RELEASE_BASE = "${params.RELEASE_BASE}"
        RELEASE_VERSION = "${params.RELEASE_VERSION}"
        GIT_PROJECT = "nabla"
        GIT_BROWSE_URL = "https://github.com/AlbanAndrieu/${GIT_PROJECT}/"
        GIT_URL = "ssh://git@github.com/AlbanAndrieu/${GIT_PROJECT}.git"
        DOCKER_TAG = dockerTag()
    }
    options {
        skipDefaultCheckout()
        disableConcurrentBuilds()
        skipStagesAfterUnstable()
        parallelsAlwaysFailFast()
        ansiColor('xterm')
        timeout(time: 120, unit: 'MINUTES', activity: true)
        timestamps()
    }
    stages {
        //stage('Preparation') { // for display purposes
        //   // Get some code from a Git repository
        //   checkout([$class: 'GitSCM', branches: [[name: '*/master']], browser: [$class: 'Stash', repoUrl: 'https://github.com/AlbanAndrieu/nabla-cpp/browse'], doGenerateSubmoduleConfigurations: false, extensions: [[$class: 'CloneOption', depth: 0, noTags: false, reference: '', shallow: true, timeout: 30]], gitTool: 'git-latest', submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'nabla', url: 'https://github.com/AlbanAndrieu/nabla-cpp.git']]])
        //   //dir('Scripts/ansible') {
        //   //    sh 'ansible-galaxy install -r requirements.yml -p ./roles/ --ignore-errors'
        //   //    // check quality
        //   //    sh returnStatus: true, script: 'ansible-lint jenkins-slave.yml || true'
        //   //    // check syntax
        //   //    ansiblePlaybook colorized: true, extras: '-c local -vvvv --syntax-check', installation: 'ansible-2.2.0.0', inventory: 'hosts', limit: 'albandri', playbook: 'jenkins-slave.yml', sudoUser: null
        //   //    //ansiblePlaybook colorized: true, extras: '-c local', installation: 'ansible-2.2.0.0', inventory: 'hosts', limit: 'albandri', playbook: 'jenkins-slave.yml', sudoUser: null
        //   //}
        //}
        stage('Build') {
            steps {
                script {
                    sh "#!/bin/bash \n" +
                       "ls -lrta /opt/ansible/ \n" +
                       "source /opt/ansible/env38/bin/activate \n" +
                       "python -V \n" +
                       "python3 -V \n" +
                       "python3.8 -V \n" +
                       "pip -V \n" +
                       "pip list \n" +
                       "pip3 install conan \n" +
                       "which conan"

                    tee("python.log") {
                      sh "#!/bin/bash \n" +
                         "whoami \n" +
                         "source ./scripts/run-python.sh\n" +
                         "pre-commit run -a || true"
                    } // tee

                    sh "#!/bin/bash \n" +
                       "conan remove --system-reqs '*'"

                    docker.withRegistry('https://index.docker.io/v1', 'docker-login') {
                        def DOCKER_REGISTRY_URI="index.docker.io/v1"
                        //withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: 'docker-login', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD']]) {
                        //sh "docker login --password=${PASSWORD} --username=${USERNAME} ${DOCKER_REGISTRY_URI}"
                        //git '…'
                        def ansible = docker.build 'nabla/jenkins-slave-ubuntu:latest'
                        ansible.inside {
                          sh 'echo test'
                        }
                        ansible.push()  // record this latest (optional)
                        //stage 'Test image'
                        stage('Test image') {
                         //docker run -i -t --entrypoint /bin/bash ${myImg.imageName()}
                           docker.image('nabla/jenkins-slave-ubuntu:latest').withRun {c ->
                           sh "docker logs ${c.id}"
                          }
                        }
                        // run some tests on it (see below), then if everything looks good:
                        //stage 'Approve image'
                        ansible.push 'latest'
                        //def myImg = docker.image('nabla/jenkins-slave-ubuntu:latest')
                        //sh "docker push ${myImg.imageName()}"
                        //} // withCredentials
                    } // withRegistry
               } // script
           } // steps
        } // stage Build
        stage('SonarQube analysis') {
            environment {
                SONAR_SCANNER_OPTS = "-Xmx1g"
            }
            steps {
                sh "pwd"
                sh "/usr/local/sonar-runner/bin/sonar-scanner -D sonar-project.properties"
            }
        } // stage SonarQube
        //stage('Approve image') {
        // sshagent(['jenkins-ssh']) {
        ////   def myImg = docker.image('nabla/nabla-cpp:latest')
        ////   sh "docker run -it --rm -v /var/run/docker.sock:/var/run/docker.sock nate/dockviz ${myImg.imageName()}"
         //    sh returnStdout: true, script: 'sudo docker run -it --net host --pid host --cap-add audit_control -v /var/lib:/var/lib -v /var/run/docker.sock:/var/run/docker.sock -v /usr/lib/systemd:/usr/lib/systemd -v /etc:/etc --label docker_bench_security docker/docker-bench-security'
         //}
        //}
    } // stages
	post {
	  always {
		recordIssues enabledForFailure: true, filters: [
		  excludeFile('.*qrc_icons\\.cpp.*'),
		  excludeMessage('.*tmpnam.*')],
		  tools: [gcc4(name: 'GCC-GUI', id: 'gcc4-gui',
				  pattern: 'build/build*.log'),
				  gcc4(name: 'Doxygen', id: 'doxygen',
				  pattern: 'build/DoxygenWarnings.log')
				  ],
		  unstableTotalAll: 1

		recordIssues enabledForFailure: true,
		  tools: [cppCheck(pattern: 'build/cppcheck.log')]
	  }
	  success { archiveArtifacts 'build/*.tar.gz,build/conaninfo.txt' }
	} // post
} // pipeline

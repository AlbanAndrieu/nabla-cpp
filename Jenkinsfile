#!/usr/bin/env groovy
@Library(value='jenkins-pipeline-scripts@master', changelog=false) _

String DOCKER_REGISTRY_HUB = env.DOCKER_REGISTRY_HUB ?: 'index.docker.io'.toLowerCase().trim() // registry.hub.docker.com
String DOCKER_ORGANISATION_HUB = 'nabla'.trim()
String DOCKER_IMAGE_TAG = env.DOCKER_IMAGE_TAG ?: 'latest'.trim()
//String DOCKER_USERNAME="nabla"
String DOCKER_NAME = 'ansible-jenkins-slave-docker'.trim()

String DOCKER_REGISTRY_HUB_URL = env.DOCKER_REGISTRY_HUB_URL ?: "https://${DOCKER_REGISTRY_HUB}".trim()
String DOCKER_REGISTRY_HUB_CREDENTIAL = env.DOCKER_REGISTRY_HUB_CREDENTIAL ?: 'hub-docker-nabla'.trim()
String DOCKER_IMAGE = "${DOCKER_ORGANISATION_HUB}/${DOCKER_NAME}:${DOCKER_IMAGE_TAG}".trim()

String DOCKER_OPTS_COMPOSE = getDockerOpts(isDockerCompose: true, isLocalJenkinsUser: false)

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
      args DOCKER_OPTS_COMPOSE
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
    string(defaultValue: '', description: 'Default workspace suffix to override', name: 'WORKSPACE_SUFFIX', trim: true)
    string(defaultValue: 'jenkins', description: 'User', name: 'TARGET_USER', trim: true)
    booleanParam(defaultValue: false, description: 'Dry run', name: 'DRY_RUN')
    booleanParam(defaultValue: false, description: 'Clean before run', name: 'CLEAN_RUN')
    booleanParam(defaultValue: false, description: 'Debug run', name: 'DEBUG_RUN')
    booleanParam(defaultValue: false, name: 'RELEASE', description: 'Perform release-type build.')
    string(defaultValue: '', name: 'RELEASE_BASE', description: 'Commit tag or branch that should be checked-out for release', trim: true)
    string(defaultValue: '', name: 'RELEASE_VERSION', description: 'Release version for artifacts', trim: true)
    booleanParam(defaultValue: false, description: 'Build only to have package. no test / no docker', name: 'BUILD_ONLY')
    booleanParam(defaultValue: true, description: 'Run acceptance tests', name: 'BUILD_TEST')
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
    SERVER_URL = "${params.SERVER_URL}"
    SERVER_CONTEXT = "${params.SERVER_CONTEXT}"
    GIT_PROJECT = 'nabla'
    GIT_BROWSE_URL = "https://github.com/AlbanAndrieu/${GIT_PROJECT}/"
    GIT_URL = "ssh://git@github.com/AlbanAndrieu/${GIT_PROJECT}.git"
    DOCKER_TAG = dockerTag()
    ARCH = 'linux'
    USE_SUDO = 'false'
  }
  options {
    //skipDefaultCheckout()
    disableConcurrentBuilds()
    skipStagesAfterUnstable()
    parallelsAlwaysFailFast()
    ansiColor('xterm')
    timeout(time: 120, unit: 'MINUTES', activity: true)
    timestamps()
  }
  stages {
    stage('Build-Docker') {
      when {
        expression { BRANCH_NAME ==~ /release\/.+|master|develop|PR-.*|feature\/.*|bugfix\/.*/ }
        expression { params.BUILD_ONLY.toBoolean() == false }
      }
      steps {
        script {
          tee('python.log') {
            sh '#!/bin/bash \n' +
              "cd $WORKSPACE \n" +
              'ls -lrta /opt/ansible/ \n' +
              '. /opt/ansible/env38/bin/activate \n' +
              'python -V \n' +
              'python3 -V \n' +
              'python3.8 -V \n' +
              'pip -V \n' +
              'pip list \n' +
              'pip3.8 install conan pre-commit \n' +
              'which conan \n' +
              "conan remove --system-reqs '*' \n" +
              'whoami \n' +
              'bash ./scripts/cppcheck.sh\n' +
              'source ./scripts/run-python.sh\n' +
              '. ./scripts/run-python.sh\n' +
              'pre-commit run -a || true'
          } // tee

          tee('build-docker.log') {
            //sh "#!/bin/bash \n" +
            //   "conan remove --system-reqs '*'"

            docker.withRegistry(DOCKER_REGISTRY_HUB_URL, DOCKER_REGISTRY_HUB_CREDENTIAL) {
              def ansible = docker.build 'nabla/jenkins-slave-ubuntu:latest'
              //ansible.inside {
              //  sh 'echo test'
              //}
              //ansible.push()  // record this latest (optional)
              //stage 'Test image'
              stage('Test image') {
                //docker run -i -t --entrypoint /bin/bash ${myImg.imageName()}
                docker.image('nabla/jenkins-slave-ubuntu:latest').withRun { c ->
                  sh "docker logs ${c.id}"
                }
              }
              // run some tests on it (see below), then if everything looks good:
              //stage 'Approve image'
              //ansible.push 'latest'
            //def myImg = docker.image('nabla/jenkins-slave-ubuntu:latest')
            //sh "docker push ${myImg.imageName()}"
            //} // withCredentials
            } // withRegistry
          } // tee
       } // script
      } // steps
    } // stage Build-Dcoker
    stage('Build-Scons') {
      steps {
        script {
          tee('build-scons.log') {
            sh '#!/bin/bash \n' +
              "cd $WORKSPACE \n" +
              'ls -lrta /opt/ansible/ \n' +
              '. /opt/ansible/env38/bin/activate \n' +
              'python -V \n' +
              'python3 -V \n' +
              'python3.8 -V \n' +
              'pip -V \n' +
              'pip list \n' +
              'pip3.8 install conan pre-commit cmake \n' +
              'which conan \n' +
              "conan remove --system-reqs '*' \n" +
              'whoami \n' +
              'bash ./scripts/cppcheck.sh\n' +
              'bash ./scripts/flawfinder.sh\n' +
              'bash ./scripts/clang-tidy.sh\n' +
              'source ./scripts/run-python.sh\n' +
              'rm -Rf /home/jenkins/.conan/\n' +
              //"pre-commit run -a || true\n" +
              'bash ./build.sh'
          } // tee

          publishHTML (target: [
            allowMissing: true,
            alwaysLinkToLastBuild: false,
            keepAll: true,
            reportDir: 'reports/',
            reportFiles: 'gcovr-report.html',
            reportName: 'GCov Report'
          ])
        } // script
      } // steps
    } // stage Build-CMake
    stage('Build-CMake') {
      when {
        expression { BRANCH_NAME ==~ /release\/.+|master|develop|PR-.*|feature\/.*|bugfix\/.*/ }
      //expression { params.BUILD_TEST.toBoolean() == true && params.BUILD_ONLY.toBoolean() == false }
      }
      steps {
        script {
          tee('build-cmake.log') {
            //sh "#!/bin/bash \n" +
            //   "cd $WORKSPACE \n" +
            //   "ls -lrta /opt/ansible/ \n" +
            //   ". /opt/ansible/env38/bin/activate \n" +
            //   "python -V \n" +
            //   "python3 -V \n" +
            //   "python3.8 -V \n" +
            //   "pip -V \n" +
            //   "pip list \n" +
            //   "pip3.8 install conan pre-commit cmake \n" +
            //   "which conan \n" +
            //   "conan remove --system-reqs '*' \n" +
            //   "whoami \n" +
            //   "bash ./scripts/cppcheck.sh\n" +
            //   "source ./scripts/run-python.sh\n"

            dir('sample/build-linux') {
                sh '#!/bin/bash \n' +
                   //"source ../../scripts/run-python.sh\n" +
                   '. /opt/ansible/env38/bin/activate \n' +
                   'rm -Rf /home/jenkins/.conan/\n' +
                   'export USE_SUDO=false\n' +
                   "export UNIT_TESTS=${BUILD_TEST}\n" +
                   //"export ENABLE_MEMCHECK=true\n" +
                   'bash ./build.sh\n' +
                   'make cppcheck\n' +
                   'make clangtidy\n'
                   //"make sonarqube\n" +
                   //"make valgrind\n" +
                   //"make DoxygenDoc\n" +
                   //"make tests\n" +

            //sh 'ctest -T test --no-compress-output'
            } // dir
          } // tee

          publishHTML (target: [
            allowMissing: true,
            alwaysLinkToLastBuild: false,
            keepAll: true,
            reportDir: 'sample/build-linux/coverage/',
            reportFiles: 'index.html',
            reportName: 'Coverage Report'
          ])
          publishHTML (target: [
            allowMissing: true,
            alwaysLinkToLastBuild: false,
            keepAll: true,
            reportDir: 'sample/build-linux/check/',
            reportFiles: 'index.html',
            reportName: 'Cppcheck Report'
          ])
          publishHTML (target: [
            allowMissing: true,
            alwaysLinkToLastBuild: false,
            keepAll: true,
            reportDir: 'sample/build-linux/doc/html/',
            reportFiles: 'index.html',
            reportName: 'Doxygen Report'
          ])
          publishHTML (target: [
            allowMissing: true,
            alwaysLinkToLastBuild: false,
            keepAll: true,
            reportDir: 'reports/',
            reportFiles: 'flawfinder-result.html',
            reportName: 'Flawfinder Report'
          ])
          publishHTML (target: [
            allowMissing: true,
            alwaysLinkToLastBuild: false,
            keepAll: true,
            reportDir: 'reports/',
            reportFiles: 'rats-result.html',
            reportName: 'Rats Report'
          ])

          dockerHadoLint(dockerFilePath: '.', skipDockerLintFailure: true, dockerFileId: '1')
         } // script
       } // steps
     } // stage Build-CMake
    stage('SonarQube analysis') {
      when {
        expression { BRANCH_NAME ==~ /release\/.+|master|develop|PR-.*|feature\/.*|bugfix\/.*/ }
        expression { params.BUILD_ONLY.toBoolean() == false }
      }
      environment {
        SONAR_SCANNER_OPTS = '-Xmx1g'
      }
      steps {
        sh '/usr/local/sonar-runner/bin/sonar-scanner -D sonar-project.properties'
      }
     } // stage SonarQube
  //stage('Approve image') {
  // sshagent(['jenkins-ssh']) {
  ////   def myImg = docker.image('nabla/jenkins-slave-ubuntu:latest')
  ////   sh "docker run -it --rm -v /var/run/docker.sock:/var/run/docker.sock nate/dockviz ${myImg.imageName()}"
  //    sh returnStdout: true, script: 'sudo docker run -it --net host --pid host --cap-add audit_control -v /var/lib:/var/lib -v /var/run/docker.sock:/var/run/docker.sock -v /usr/lib/systemd:/usr/lib/systemd -v /etc:/etc --label docker_bench_security docker/docker-bench-security'
  //}
  //}
  } // stages
  post {
    always {
      recordIssues enabledForFailure: true,
        tools: [cppCheck(pattern: 'reports/cppcheck-result.xml'),
                junitParser(pattern: 'sample/build-linux/Testing/JUnitTestResults.xml'),
                //sonarQube(pattern: '**/sonar-report.json'),
                // NOK sonarQube(pattern: '.scannerwork/report-task.txt'),
                gcc(),
                cmake(),
                doxygen(),
                //clang(),
                //clangAnalyzer(),
                clangTidy(), //**/clang-tidy-result.txt
                //dockerLint(),
                flawfinder(),
                taskScanner()
        ]

      archiveArtifacts artifacts: '**/conaninfo.txt, , *.log, sample/build*/CMakeFiles/CMakeOutput.log, sample/build*/CMakeFiles/CMakeError.log, bw-outputs/build-wrapper.log, bw-outputs/build-wrapper-dump.json', excludes: null, fingerprint: false, onlyIfSuccessful: false

      // Archive the CTest xml output
      archiveArtifacts (
        artifacts: 'sample/build-linux/Testing/**/*.xml, sample/build-linux/Testing/Temporary/*',
        fingerprint: true, onlyIfSuccessful: false
      )

      // Process the CTest xml output with the xUnit plugin
      xunit (
        testTimeMargin: '3000',
        thresholdMode: 1,
        thresholds: [
          skipped(failureThreshold: '0'),
          failed(failureThreshold: '0')
        ],
        tools: [CTest(
          pattern: 'sample/build-linux/Testing/**/Test.xml',
          deleteOutputFiles: true,
          failIfNotNew: false,
          skipNoTestFiles: true,
          stopProcessingIfError: true
        )]
      )
    } // always
    success {
      archiveArtifacts '**/*.tar.gz, *.log, conaninfo.txt, sample/build-linux/DartConfiguration.tcl, sample/build-linux/install_manifest.txt, sample/build-linux/CMakeCache.txt, sample/build-linux/graphviz.png, sample/build-linux/iwyu.out, sample/build-linux/bin/*, sample/build-linux/lib/*, sample/build-linux/_CPack_Packages/Linux/DEB/*'
    } // success
  } // post
} // pipeline

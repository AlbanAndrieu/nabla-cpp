node ('albandri'){
   stage('Preparation') { // for display purposes
      // Get some code from a Git repository
      checkout([$class: 'GitSCM', branches: [[name: '*/master']], browser: [$class: 'Stash', repoUrl: 'https://github.com/AlbanAndrieu/nabla-cpp/browse'], doGenerateSubmoduleConfigurations: false, extensions: [[$class: 'CloneOption', depth: 0, noTags: false, reference: '', shallow: true, timeout: 30]], gitTool: 'git-latest', submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'nabla', url: 'https://github.com/AlbanAndrieu/nabla-cpp.git']]])
      dir('Scripts/ansible') {
          sh 'ansible-galaxy install -r requirements.yml -p ./roles/ --ignore-errors'
          // check quality
          sh returnStatus: true, script: 'ansible-lint jenkins-slave.yml || true'
          // check syntax
          ansiblePlaybook colorized: true, extras: '-c local -vvvv --syntax-check', installation: 'ansible-2.2.0.0', inventory: 'hosts', limit: 'albandri', playbook: 'jenkins-slave.yml', sudoUser: null
          //ansiblePlaybook colorized: true, extras: '-c local', installation: 'ansible-2.2.0.0', inventory: 'hosts', limit: 'albandri', playbook: 'jenkins-slave.yml', sudoUser: null
      }
   }
   stage('Build') {
      dir('Scripts/ansible') {
        docker.withRegistry('https://registry.nabla.mobi', 'docker-login') {
          def DOCKER_REGISTRY_URI="registry.nabla.mobi"
          withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: 'docker-login', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD']]) {
            sh "docker login --password=${PASSWORD} --username=${USERNAME} ${DOCKER_REGISTRY_URI}"
             //git '…'
             def ansible = docker.build 'nabla/jenkins-slave-ubuntu:snapshot'
             ansible.inside {
               sh 'echo test'
             }
             ansible.push()  // record this snapshot (optional)
             //stage 'Test image'
             stage('Test image') {
              //docker run -i -t --entrypoint /bin/bash ${myImg.imageName()}
                docker.image('nabla/jenkins-slave-ubuntu:snapshot').withRun {c ->
                sh "docker logs ${c.id}"
             }
            }
             // run some tests on it (see below), then if everything looks good:
             //stage 'Approve image'
             ansible.push 'latest'
             //def myImg = docker.image('nabla/jenkins-slave-ubuntu:snapshot')
             //sh "docker push ${myImg.imageName()}"
        }
        }
      }
   }

   stage('SonarQube analysis') {
       environment {
           SONAR_SCANNER_OPTS = "-Xmx1g"
       }
       steps {
           sh "pwd"
           sh "/usr/local/sonar-runner/bin/sonar-scanner -D sonar-project.properties"
       }
   }
   //stage('Approve image') {
   // sshagent(['jenkins-ssh']) {
   ////   def myImg = docker.image('nabla/nabla-cpp:snapshot')
   ////   sh "docker run -it --rm -v /var/run/docker.sock:/var/run/docker.sock nate/dockviz ${myImg.imageName()}"
    //    sh returnStdout: true, script: 'sudo docker run -it --net host --pid host --cap-add audit_control -v /var/lib:/var/lib -v /var/run/docker.sock:/var/run/docker.sock -v /usr/lib/systemd:/usr/lib/systemd -v /etc:/etc --label docker_bench_security docker/docker-bench-security'
    //}
   //}
}

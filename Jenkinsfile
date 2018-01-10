pipeline {
  agent {
    docker {
      image 'debian:stretch'
      // XXX could you do most operations as normal user?
      args '-u root --mount type=bind,source=/etc/jenkins-docker-config,destination=/etc/jenkins-docker-config,readonly --env-file=/etc/jenkins-docker-config/environment'
    }
  }

  stages {
    stage('Prepare for build') {
      steps {
        sh '''
          apt-get update
          apt-get -y dist-upgrade
          apt-get install -y apt-utils devscripts dpkg-dev make puppet
          make setup-buildhost
        '''
        // We can treat a docker container as if it is a puavo-os system
        // so package builds can proceed:
        sh 'ln -fns "$(pwd)" /puavo-os'
      }
    }

    stage('Install deb-package build dependencies') {
      steps { sh 'make install-build-deps' }
    }

    stage('Install (cloud) deb-package build dependencies') {
      steps { sh 'make -C debs install-build-deps-cloud' }
    }

    stage('Build puavo-os deb-packages') {
      steps { sh 'make build-debs-parts' }
    }

    stage('Build custom deb-packages used in puavo-os') {
      // DEB_BUILD_OPTIONS=nocheck is needed for the grub2-build in
      // a docker environment.  It makes the build quite a bit faster as
      // well, but this means that some grub-regressions will not be caught
      // by Jenkins builds (they are enabled for image builds).
      steps { sh 'env DEB_BUILD_OPTIONS=nocheck make build-debs-ports' }
    }

    stage('Build puavo-os cloud deb-packages') {
      // These are packages not needed by puavo-os image.
      steps { sh 'make build-debs-cloud' }
    }

    stage('Upload deb-packages') {
      steps {
        sh '''
          install -o root -g root -m 644 /etc/jenkins-docker-config/dput.cf \
            /etc/dput.cf
          install -o root -g root -m 644 \
            /etc/jenkins-docker-config/ssh_known_hosts \
            /etc/ssh/ssh_known_hosts
          install -d -o root -g root -m 700 ~/.ssh
          install -o root -g root -m 600 \
            /etc/jenkins-docker-config/sshkey_puavo_deb_upload \
            ~/.ssh/id_rsa
        '''

        sh 'make upload-debs'
      }
    }
  }

  post {
    always {
      cleanWs()
    }
  }
}

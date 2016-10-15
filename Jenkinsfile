// check out code
stage name: 'check-out-code'

node('slave') {
    dir('src') {
        checkout scm
    }
    stash 'src'
}


// run tests
stage name: 'test'

node('slave') {
    unstash 'src'
    dir('src') {
        sh 'make test'
    }
}


// deploy to prod
if (env.BRANCH_NAME == 'master') {
    stage name: 'deploy-to-prod'

    def version = new Date().format("yyyy-MM-dd-'T'HH-mm-ss")
    withEnv(["DOCKER_TAG=docker-push.ocf.berkeley.edu/rt:${version}"]) {
        // build image
        node('slave') {
            unstash 'src'
            dir('src') {
                sh 'make cook-image'
            }
        }

        // push to Docker registry
        node('deploy') {
            unstash 'src'
            dir('src') {
                sh 'make push-image'
            }
        }
    }

    // deploy to marathon
    build job: 'marathon-deploy-app', parameters: [
        [$class: 'StringParameterValue', name: 'app', value: 'app'],
        [$class: 'StringParameterValue', name: 'version', value: version],
    ]
}


// vim: ft=groovy

try {
    stage name: 'clean-workspace'
    node('slave') {
        step([$class: 'WsCleanup'])
    }


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
        def version = new Date().format("yyyy-MM-dd-'T'HH-mm-ss")
        withEnv(["DOCKER_TAG=docker-push.ocf.berkeley.edu/rt:${version}"]) {
            stage name: 'build-prod-image'
            node('slave') {
                unstash 'src'
                dir('src') {
                    sh 'make cook-image'
                }
            }

            stage name: 'push-to-registry'
            node('deploy') {
                unstash 'src'
                dir('src') {
                    sh 'make push-image'
                }
            }
        }

        stage name: 'deploy-to-prod'
        build job: 'marathon-deploy-app', parameters: [
            [$class: 'StringParameterValue', name: 'app', value: 'rt'],
            [$class: 'StringParameterValue', name: 'version', value: version],
        ]
    }
} catch (err) {
    def subject = "${env.JOB_NAME} - Build #${env.BUILD_NUMBER} - Failure!"
    def message = "${env.JOB_NAME} (#${env.BUILD_NUMBER}) failed: ${env.BUILD_URL}"

    if (env.BRANCH_NAME == 'master') {
        slackSend color: '#FF0000', message: message
        mail to: 'root@ocf.berkeley.edu', subject: subject, body: message
    } else {
        mail to: emailextrecipients([
            [$class: 'CulpritsRecipientProvider'],
            [$class: 'DevelopersRecipientProvider']
        ]), subject: subject, body: message
    }

    throw err
}

// vim: ft=groovy

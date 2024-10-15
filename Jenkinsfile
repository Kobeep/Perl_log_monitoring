pipeline {
    agent any

    stages {
        stage('Install dependencies and build Ubuntu Container') {
            steps {
                script {
                    sh 'sudo apt-get update'
                    sh 'sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common'
                    sh 'curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -'
                    sh 'sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"'
                    sh 'sudo apt-get update'
                    sh 'sudo apt-get install -y docker-ce'
                    sh 'docker --version'

                }
                script {
                    sh 'docker build -t ubuntu-kobee .'
                }
            }
        }

        stage('Test') {
            steps {

                script {
                    docker.image('ubuntu-kobee').inside {
                        sh 'cd tmp/'
                        sh 'perl log_monitor.pl'
                    }
                }
            }
        }

        stage('Cleanup') {
            steps {
                script {
                    sh 'docker system prune -af'
                }
            }
        }
    }

    post {
        always {
            // Faza post-cleanup, gdyby coś jeszcze pozostało
            cleanWs()  // Czyści workspace agenta Jenkinsa
        }
    }
}

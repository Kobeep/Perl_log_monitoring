pipeline {
    agent any

    stages {
        stage('Install dependencies and build Ubuntu Container') {
            steps {
                script {
                    sh '
                    apt-get update
                    apt-get install ca-certificates curl
                    install -m 0755 -d /etc/apt/keyrings
                    curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
                    chmod a+r /etc/apt/keyrings/docker.asc'

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

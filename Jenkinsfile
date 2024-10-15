pipeline {
    agent any

    stages {
        stage('Build Ubuntu Container') {
            steps {
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

pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                // Pobieranie repozytorium z GIT
                git branch: 'feature/Perl', url: 'https://github.com/Kobeep/Perl_log_monitoring.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh 'docker build -t perl_log_monitoring .'
                }
            }
        }
        stage('Run Docker Container') {
            steps {
                script {
                    sh 'docker run --rm perl_log_monitoring'
                }
            }
        }

        stage('Run Perl Script') {
            steps {
                // Uruchomienie skryptu Perla
                sh 'perl log_monitor.pl'
            }
        }
    }

    post {
        always {
            // Czyszczenie środowiska
            cleanWs()
        }

        success {
            echo 'Build zakończony sukcesem!'
        }

        failure {
            echo 'Build nie powiódł się.'
        }
    }
}

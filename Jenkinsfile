pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                // Pobieranie repozytorium z GIT
                git branch: 'feature/Perl', url: 'https://github.com/Kobeep/Perl_log_monitoring.git'
            }
        }

        stage('Install Perl and dependencies') {
            steps {
                script {
                    // Rozpoznawanie systemu i instalacja Perla
                    if (isUnix()) {
                        if (sh(script: 'cat /etc/os-release | grep -i redhat', returnStatus: true) == 0) {
                            // Instalacja Perl na RedHat/CentOS/Fedora
                            sh 'sudo yum install -y perl'
                        } else if (sh(script: 'cat /etc/os-release | grep -i debian', returnStatus: true) == 0 ||
                                   sh(script: 'cat /etc/os-release | grep -i ubuntu', returnStatus: true) == 0) {
                            // Instalacja Perl na Debian/Ubuntu
                            sh 'sudo apt-get update && sudo apt-get install -y perl'
                        }
                    }
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

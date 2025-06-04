pipeline {
    agent {
	label 'docker'
    }

    environment {
        NGINX_IMAGE_NAME = "iceloka/my-nginx"
        APACHE_IMAGE_NAME = "iceloka/my-apache"
        DOCKER_CREDENTIALS_ID = "docker-credentials-id" // Jenkins credentials
        SSH_CREDENTIALS_ID = "ssh-credentials-id"
    }

    stages {
        stage('Init') {
             steps {
                echo 'Initializing..'
                script {
                            echo "Running ${env.BUILD_ID} on ${env.JENKINS_URL}"
                            echo "Current branch: ${env.BRANCH_NAME}"
                        }
                withCredentials([usernamePassword(credentialsId: "${DOCKER_CREDENTIALS_ID}", usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh 'echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin'
                }
             }
         }
        stage('Build Nginx Docker Image') {
            steps {
                script {
                    dockerNginxImage = docker.build("${NGINX_IMAGE_NAME}:${env.BRANCH_NAME}_${env.BUILD_ID}", "nginx")
                    sh "docker tag ${NGINX_IMAGE_NAME}:${env.BRANCH_NAME}_${env.BUILD_ID} ${NGINX_IMAGE_NAME}:latest"

                }
            }
        }
        stage('Build Apache Docker Image') {
            steps {
                script {
                    dockerApacheImage = docker.build("${APACHE_IMAGE_NAME}:${env.BRANCH_NAME}_${env.BUILD_ID}", "apache")
                    sh "docker tag ${APACHE_IMAGE_NAME}:${env.BRANCH_NAME}_${env.BUILD_ID} ${APACHE_IMAGE_NAME}:latest"

                }
            }
        }

        stage('Push to Registry') {
            steps {
                script {
                    dockerApacheImage.push("${env.BRANCH_NAME}_${env.BUILD_ID}")
                    dockerApacheImage.push("latest")
                    dockerNginxImage.push("${env.BRANCH_NAME}_${env.BUILD_ID}")
                    dockerNginxImage.push("latest")
                }
            }
        }
    stage('Deploy') {
        steps {
            script {
                def servers = []
                if (env.BRANCH_NAME == 'dev') {
                    servers = ['ubuntu@100.26.107.66']
                } else if (env.BRANCH_NAME == 'main') {
                    servers = ['ubuntu@54.163.15.99']
                } else {
                    error "Unsupported branch for deployment: ${env.BRANCH_NAME}"
                }

                withCredentials([
                    file(credentialsId: 'certificate-credentials-id', variable: 'CERT_PEM')
                ]) {
                    sshagent([env.SSH_CREDENTIALS_ID]) {
                        for (server in servers) {
                            echo "Deploying to ${server}"


                            sh """
                                scp -o StrictHostKeyChecking=no $CERT_PEM ${server}:/home/ubuntu/cert.pem
                            """

                            // Запускаем контейнеры, монтируя сертификат туда, где nginx ожидает его
                            sh """
                                ssh -o StrictHostKeyChecking=no ${server} '
                                    sudo chmod 644 /home/ubuntu/cert.pem

                                    docker network create mynet || true &&

                                    # Остановить и удалить старые контейнеры apache и nginx, если они есть
                                    docker rm -f apache nginx || true &&

                                    # Очистить неиспользуемые образы старше 24 часов
                                    docker image prune -a --filter "until=24h" -f || true

                                    # Запустить новые контейнеры
                                    docker run --name apache --network mynet -d -p 8080:8080 ${APACHE_IMAGE_NAME}:${env.BRANCH_NAME}_${env.BUILD_ID} &&
                                    docker run --name nginx --network mynet -d -p 80:80 -v /home/ubuntu/cert.pem:/etc/letsencrypt/live/testxeyl.online/cert.pem:ro -p 443:443 ${NGINX_IMAGE_NAME}:${env.BRANCH_NAME}_${env.BUILD_ID}
                                '
                            """
                        }
                    }
                }
            }
        }

    }
}


    post {
        always {
            cleanWs()
        }
    }
}


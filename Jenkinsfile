pipeline {
    agent {
	label 'docker'
    }

    environment {
        NGINX_IMAGE_NAME = "iceloka/my-nginx"
        APACHE_IMAGE_NAME = "iceloka/my-apache"
        DOCKER_CREDENTIALS_ID = "docker-credentials-id" // Jenkins credentials
        DEPLOY_SERVER = "user@your-server"
        DEPLOY_PATH = "/path/to/deployment"
        SSH_CREDENTIALS_ID = "fab1f3fd-1663-4b61-82b0-c0d6040f89a7"
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
        stage('Checkout') {
            steps {
                checkout scm
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
                        servers = ['54.163.15.99']
                    } else if (env.BRANCH_NAME == 'main') {
                        servers = ['54.163.15.99']
                    } else {
                        error "Unsupported branch for deployment: ${env.BRANCH_NAME}"
                    }

                    sshagent([SSH_CREDENTIALS_ID]) {
                        for (server in servers) {
                            echo "Deploying to ${server}"

                            sh """
                            ssh -o StrictHostKeyChecking=no ${server} '
                                docker network create mynet || true &&
                                docker run --rm --name apache --network mynet -p 8080:8080 ${APACHE_IMAGE_NAME}:${env.BRANCH_NAME}_${env.BUILD_ID} &
                                docker run --rm --name nginx --network mynet -p 80:80 -p 443:443 -v /host/path/nginx/conf:/etc/nginx/conf.d ${NGINX_IMAGE_NAME}:${env.BRANCH_NAME}_${env.BUILD_ID}
                            '
                            """
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


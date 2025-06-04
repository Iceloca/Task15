pipeline {
    agent {
	label 'docker'
    }

    environment {
        IMAGE_NAME = "iceloka/my-nginx"
        DOCKER_CREDENTIALS_ID = "docker-credentials-id" // Jenkins credentials
        DEPLOY_SERVER = "user@your-server"
        DEPLOY_PATH = "/path/to/deployment"
        GIT_COMMIT_SHORT = "${env.GIT_COMMIT.take(7)}"
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
                    dockerImage = docker.build("${IMAGE_NAME}:${GIT_COMMIT_SHORT}", "nginx")
                    sh "docker tag ${IMAGE_NAME}:${GIT_COMMIT_SHORT} ${IMAGE_NAME}:latest"

                }
            }
        }

        stage('Push to Registry') {
            steps {
                script {
                    docker.withRegistry("https://${REGISTRY}", "${DOCKER_CREDENTIALS_ID}") {
                    dockerImage.push("${GIT_COMMIT_SHORT}")
                    dockerImage.push("latest")
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


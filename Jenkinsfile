pipeline {
    agent {
	label 'docker'
    }

    environment {
        REGISTRY = "https://index.docker.io/v1/"
        IMAGE_NAME = "iceloka/my-nginx"
        DOCKER_CREDENTIALS_ID = "docker-credentials-id" // Jenkins credentials
        DEPLOY_SERVER = "user@your-server"
        DEPLOY_PATH = "/path/to/deployment"
        GIT_COMMIT_SHORT = "${env.GIT_COMMIT.take(7)}"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        stage('Build Nginx Docker Image') {
            steps {
                script {
                    dockerImage = docker.build("${REGISTRY}/${IMAGE_NAME}:${GIT_COMMIT_SHORT}", "nginx")
                    sh "docker tag ${REGISTRY}/${IMAGE_NAME}:${GIT_COMMIT_SHORT} ${REGISTRY}/${IMAGE_NAME}:latest"

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


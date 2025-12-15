pipeline {
    agent { label 'MySlaveConfigServer' }

    environment {
        // 🔴 CHANGE #1
        IMAGE_NAME = "eklavya2117/static-website"

        // Auto-generated build number
        TAG = "${BUILD_NUMBER}"

        // 🔴 CHANGE #2
        LAMP_SERVER = "13.62.228.20"
    }

    stages {

        stage('Checkout Code') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/eklavya2117/static-website.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${IMAGE_NAME}:${TAG}")
                }
            }
        }

        stage('Docker Login & Push Image') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker push ${IMAGE_NAME}:${TAG}
                        docker tag ${IMAGE_NAME}:${TAG} ${IMAGE_NAME}:latest
                        docker push ${IMAGE_NAME}:latest
                    '''
                }
            }
        }

        stage('Deploy to LAMP EC2') {
            steps {
                sshagent(['lamp-ec2-key']) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ec2-user@${LAMP_SERVER} '
                          docker pull ${IMAGE_NAME}:latest
                          docker stop website || true
                          docker rm website || true
                          docker run -d \
                            --name website \
                            -p 80:80 \
                            ${IMAGE_NAME}:latest
                        '
                    """
                }
            }
        }
    }

    post {
        success {
            echo "✅ Website deployed successfully!"
        }
        failure {
            echo "❌ Deployment failed!"
        }
    }
}


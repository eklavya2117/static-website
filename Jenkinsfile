pipeline {
    agent { label 'MySlaveConfigServer' }

    environment {
        IMAGE_NAME = "eklavya2117/static-website"
        TAG = "${BUILD_NUMBER}"
        LAMP_SERVER = "16.170.217.58"
    }

    stages {

        stage('Checkout Code') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/eklavya2117/static-website.git'
            }
        }

        stage('Build Application') {
            steps {
                echo "Building static website..."
                sh '''
                    rm -rf dist
                    mkdir dist
                    cp index.html dist/
                    tar -czf static-website-build-${BUILD_NUMBER}.tar.gz dist
                '''
            }
        }

        stage('Archive Build Artifacts') {
            steps {
                archiveArtifacts artifacts: 'static-website-build-*.tar.gz',
                                 fingerprint: true
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
                        ssh -o StrictHostKeyChecking=no ubuntu@${LAMP_SERVER} '
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
            echo " Website deployed successfully!"
        }
        failure {
            echo " Deployment failed!"
        }
    }
}

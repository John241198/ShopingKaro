pipeline {
    agent any
    tools {
        jdk 'jdk21'
        nodejs 'node16'
        terraform 'terraform'   // Add Terraform tool in Jenkins Global Tools
    }
    environment {
        SCANNER_HOME = tool 'sonar-scanner'
        AWS_DEFAULT_REGION = 'ap-south-1'
    }
    stages {
        stage('Checkout from Git') {
            steps {
                git branch: 'master', url: 'https://github.com/John241198/ShopingKaro.git'
            }
        }
        stage('Install Dependencies') {
            steps {
                sh "npm install"
            }
        }
        stage("Sonarqube Analysis ") {
            steps {
                withSonarQubeEnv('sonar-server') {
                    sh ''' $SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=nodejs \
                    -Dsonar.projectKey=nodejs '''
                }
            }
        }
        stage("Quality Gate") {
            steps {
                script {
                    waitForQualityGate abortPipeline: false, credentialsId: 'Sonar-token'
                }
            }
        }
        stage('Trivy FS Scan') {
            steps {
                sh "trivy fs . > trivyfs.json"
            }
        }
        stage("Docker Build & Push") {
            steps {
                script {
                    withDockerRegistry(credentialsId: 'docker', toolName: 'docker') {
                        sh "docker build -t nodejs ."
                        sh "docker tag nodejs jsnov24/nodejs:latest"
                        sh "docker push jsnov24/nodejs:latest"
                    }
                }
            }
        }
        stage("Trivy Image Scan") {
            steps {
                sh "trivy image jsnov24/nodejs:latest > trivy.json"
            }
        }
        stage('Provision EC2 with Terraform') {
            steps {
                dir('infra') { // keep Terraform files inside infra/ folder in repo
                    sh """
                        terraform init
                        terraform apply -auto-approve
                    """
                }
            }
        }
        stage('Deploy to EC2') {
            steps {
                script {
                    // Extract EC2 public IP from Terraform output
                    def ec2_ip = sh(
                        script: "cd infra && terraform output -raw public_ip",
                        returnStdout: true
                    ).trim()

                    sshagent (credentials: ['ec2-ssh-key']) {
                        sh """
                        ssh -o StrictHostKeyChecking=no ec2-user@${ec2_ip} '
                            docker stop nodejs || true &&
                            docker rm nodejs || true &&
                            docker pull jsnov24/nodejs:latest &&
                            docker run -d --name nodejs -p 3000:3000 jsnov24/nodejs:latest
                        '
                        """
                    }
                }
            }
        }
    }
}

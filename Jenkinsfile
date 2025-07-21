
pipeline {
  agent any

  environment {
    SONAR_SCANNER_HOME = "/opt/sonar-scanner/sonar-scanner/bin"
    SONAR_TOKEN = credentials('sonarqube-token')
    ARTIFACTORY_URL = "https://heenak98.jfrog.io/artifactory"
    ARTIFACTORY_REPO = "docker-devops"
  }

  tools {
    maven 'Maven 3.9.6'
  }

  stages {

    stage('Checkout') {
      steps {
        echo "Checking out source code..."
        git branch: 'main', url: 'https://github.com/heena98/fulldevops.git'
      }
    }

    stage('Build with Maven') {
      steps {
        echo "Building project with Maven..."
        sh 'cd demo-app && mvn clean install'
      }
    }

    stage('SonarQube Analysis') {
      steps {
        echo "Running SonarQube analysis..."
        withSonarQubeEnv('SonarQube') {
          sh '''
            cd demo-app
            mvn clean install
            mvn dependency:copy-dependencies
            sonar-scanner -Dsonar.token=$SONAR_TOKEN
          '''
        }
      }
    }

    stage('Quality Gate') {
      steps {
        echo "Waiting for SonarQube quality gate..."
        timeout(time: 5, unit: 'MINUTES') {
          waitForQualityGate abortPipeline: true
        }
      }
    }

    stage('Docker Build & Push') {
      steps {
        echo "Building and pushing Docker image..."
        withCredentials([usernamePassword(credentialsId: 'jfrog-username-password', usernameVariable: 'ARTIFACTORY_USER', passwordVariable: 'ARTIFACTORY_PASS')]) {
          script {
            try {
              sh '''
                mkdir -p /tmp/.docker
                export DOCKER_CONFIG=/tmp/.docker

                docker build -t java-devops-app:4.0 .
                docker tag java-devops-app:4.0 heenak98.jfrog.io/docker-devops/java-devops-app:4.0
                echo $ARTIFACTORY_PASS | docker login -u $ARTIFACTORY_USER --password-stdin heenak98.jfrog.io
                docker push heenak98.jfrog.io/docker-devops/java-devops-app:4.0
              '''
            } catch (Exception e) {
              echo "Docker push failed: ${e.getMessage()}"
              currentBuild.result = 'FAILURE'
              error("Stopping pipeline due to Docker push failure.")
            }
          }
        }
      }
    }

    stage('Configure kubeconfig') {
      steps {
        echo "Configuring kubeconfig for AWS EKS..."
        withCredentials([
          usernamePassword(
            credentialsId: 'aws-static-creds',
            usernameVariable: 'AWS_ACCESS_KEY_ID',
            passwordVariable: 'AWS_SECRET_ACCESS_KEY'
          )
        ]) {
          sh '''
            export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
            export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
            aws eks update-kubeconfig --name my-eks-cluster-new9 --region us-east-1
            kubectl config use-context arn:aws:eks:us-east-1:381491874932:cluster/my-eks-cluster-new9
          '''
        }
      }
    }

    stage('Deploy to Kubernetes') {
      steps {
        echo "Deploying to Kubernetes..."
        withEnv(["KUBECONFIG=/root/.kube/config"]){
          sh '''
            kubectl apply -f k8s/namespace.yaml
            kubectl apply -f k8s/deployment.yaml
            kubectl apply -f k8s/service.yaml
          '''
        }
      }
    }

    stage('Port Forward & Test') {
      steps {
        echo "Running port-forward and testing service..."
        script {
          sh 'kubectl port-forward svc/java-devops-service 8081:80 -n dev &'
          sleep 5
          sh 'curl http://localhost:8081/health'
        }
      }
      post {
        always {
          echo "Cleaning up background port-forward process..."
          sh 'pkill -f "kubectl port-forward" || true'
        }
      }
    }
  }
}

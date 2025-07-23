pipeline {
  agent any

  environment {
    SONAR_SCANNER_HOME = "/opt/sonar-scanner/sonar-scanner/bin"
    SONAR_TOKEN = credentials('sonarqube-token')
    ARTIFACTORY_URL = "https://heenak.jfrog.io/artifactory"
    ARTIFACTORY_REPO = "docker-devops"
    KUBECONFIG = "/home/codespace/.kube/config"
  }

  tools {
    maven 'Maven 3.9.6'
  }

  stages {

    stage('Checkout') {
      steps {
        echo "Checking out source code..."
        git branch: 'main', url: 'https://github.com/heenak98/fulldevops.git'
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
        dir('demo-app') {
          withSonarQubeEnv('SonarQube') {
            sh 'mvn clean verify sonar:sonar'
          }
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

                docker build -t java-devops-app:5.0 .
                docker tag java-devops-app:5.0 heenak.jfrog.io/docker-devops/java-devops-app:5.0
                echo $ARTIFACTORY_PASS | docker login -u $ARTIFACTORY_USER --password-stdin heenak.jfrog.io
                docker push heenak.jfrog.io/docker-devops/java-devops-app:5.0
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
            mkdir -p /home/codespace/.kube
            aws eks update-kubeconfig --name my-eks-cluster-new14 --region us-east-1 --kubeconfig /home/codespace/.kube/config
          '''
        }
      }
    }

    stage('Deploy to Kubernetes') {
      steps {
        echo "Deploying to Kubernetes..."

        // Debug cluster access
        sh 'kubectl config current-context'
        sh 'kubectl get nodes'

        // Apply namespace
        sh 'kubectl apply -f k8s/namespace.yaml --validate=false'

        // Create image pull secret
        withCredentials([usernamePassword(credentialsId: 'jfrog-username-password', usernameVariable: 'ARTIFACTORY_USER', passwordVariable: 'ARTIFACTORY_PASS')]) {
          sh '''
            kubectl create secret docker-registry jfrog-creds \
              --docker-server=heenak.jfrog.io \
              --docker-username=$ARTIFACTORY_USER \
              --docker-password=$ARTIFACTORY_PASS \
              --docker-email=heenakausarshaikh99@gmail.com \
              --namespace=dev || true
          '''
        }

        // Apply deployment and service
        sh '''
          kubectl apply -f k8s/deployment.yaml
          kubectl apply -f k8s/service.yaml
        '''
      }
    }

    stage('Port Forward & Test') {
      steps {
        echo "Running port-forward and testing service..."
        script {
          sh 'kubectl get pods -n dev -o wide'
          sh 'kubectl describe pod -l app=java-devops-app -n dev || true'
          sh 'kubectl get events -n dev --sort-by=.metadata.creationTimestamp || true'

          sh 'kubectl wait --for=condition=ready pod -l app=java-devops-app -n dev --timeout=120s'
          sh 'kubectl port-forward svc/java-devops-service 8081:80 -n dev --address=0.0.0.0 &'
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

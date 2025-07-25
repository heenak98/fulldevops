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
    
    stage('Clean Workspace') {
      steps {
        echo "Cleaning Jenkins workspace..."
        deleteDir()
        }
      }


    stage('Checkout') {
      steps {
        echo "Checking out source code..."
        git branch: 'main', url: 'https://github.com/heenak98/fulldevops.git'
      }
    }

    stage('Build with Maven') {
      steps {
        echo "Building project with Maven..."
        dir('demo-app') {
          sh 'mvn clean install'
        }
      }
    }

    stage('Build SonarQube Exporter Plugin') {
      steps {
        echo "Building SonarQube Prometheus exporter plugin..."
        dir('sonarqube-prometheus-exporter') {
          sh 'mvn clean package -DskipTests'
        }
      }
    }

    stage('Push Plugin to Artifactory') {
      steps {
        echo "Uploading plugin JAR to JFrog Artifactory..."
        withCredentials([usernamePassword(credentialsId: 'jfrog-username-password', usernameVariable: 'ARTIFACTORY_USER', passwordVariable: 'ARTIFACTORY_PASS')]) {
          sh '''
            curl -u $ARTIFACTORY_USER:$ARTIFACTORY_PASS \
            -T sonarqube-prometheus-exporter/target/sonar-prometheus-exporter-1.0.0-SNAPSHOT.jar \
            "https://heenak.jfrog.io/artifactory/docker-devops/sonar-prometheus-exporter-1.0.0-SNAPSHOT.jar"
          '''
        }
      }
    }
    
    stage('Deploy SonarQube with Plugin') {
      steps {
        echo "Applying updated SonarQube deployment..."
        sh 'kubectl apply -f k8s/sonarqube-deployment.yaml --validate=false'
      }
    }

    stage('Restart SonarQube Deployment') {
      steps {
        echo "Restarting SonarQube deployment in Kubernetes..."
        sh '''
        kubectl rollout restart deployment sonarqube -n dev
        kubectl wait --for=condition=available deployment/sonarqube -n dev --timeout=120s
        '''
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
            def version = new Date().format("yyyyMMddHHmm")
            def imageTag = "java-devops-app:${version}"
            def fullImage = "heenak.jfrog.io/docker-devops/${imageTag}"

            sh """
              mkdir -p /tmp/.docker
              export DOCKER_CONFIG=/tmp/.docker

              docker build -t ${imageTag} .
              docker tag ${imageTag} ${fullImage}
              echo \$ARTIFACTORY_PASS | docker login -u \$ARTIFACTORY_USER --password-stdin heenak.jfrog.io
              docker push ${fullImage}
            """
          }
        }
      }
    }

    stage('Configure kubeconfig') {
      steps {
        echo "Configuring kubeconfig for AWS EKS..."
        withCredentials([usernamePassword(credentialsId: 'aws-static-creds', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
          sh '''
            mkdir -p /home/codespace/.kube
            aws eks update-kubeconfig --name my-eks-cluster-new16 --region us-east-1 --kubeconfig /home/codespace/.kube/config
          '''
        }
      }
    }

    stage('Deploy to Kubernetes') {
      steps {
        echo "Deploying to Kubernetes..."
        sh 'kubectl apply -f k8s/namespace.yaml --validate=false'

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

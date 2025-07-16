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
        git branch: 'main', url: 'https://github.com/heena98/fulldevops.git'
      }
    }

    stage('Build with Maven') {
      steps {
        sh 'cd demo-app && mvn clean install'
      }
    }

    stage('SonarQube Analysis') {
      steps {
        withSonarQubeEnv('SonarQube') {
            sh '''
            sonar-scanner -Dsonar.login=$SONAR_TOKEN
            '''
            }
      }
    }

    //stage('Quality Gate') {
     //steps {
      // timeout(time: 5, unit: 'MINUTES') {
       //   waitForQualityGate abortPipeline: true
        //}
      //}
    //}
    
    stage('Docker Build & Push') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'jfrog-username-password', usernameVariable: 'ARTIFACTORY_USER', passwordVariable: 'ARTIFACTORY_PASS')]) {
        sh '''
        mkdir -p /tmp/.docker
        export DOCKER_CONFIG=/tmp/.docker

        # Step 1: Build the Docker image
        docker build -t java-devops-app:3.0 .
        
        # Step 2: Tag the image for your JFrog Artifactory Docker repo
        docker tag java-devops-app:3.0 heenak98.jfrog.io/docker-devops/java-devops-app:3.0
        
        # Step 3: Log in to your JFrog Artifactory Docker repo
        echo $ARTIFACTORY_PASS | docker login -u $ARTIFACTORY_USER --password-stdin heenak98.jfrog.io

        # Step 4: Push the image
        docker push heenak98.jfrog.io/docker-devops/java-devops-app:3.0
        '''
        }
        }
      }
      
    stage("deploy to kubernetes"){
      steps{
        sh '''
        kubectl apply -f k8s/deployment.yaml
        kubectl apply -f k8s/service.yaml
        '''
      }
    }

    stage('Port Forward & Test') {
      steps {
        script {
          // Run port-forward in background
          sh 'kubectl port-forward svc/java-devops-service 8081:80 -n dev &'
          // Wait for port-forward to be ready
          sleep 5
          // Run tests against localhost:8081
          sh 'curl http://localhost:8081/health'
        }
      }
    }

      
}
}

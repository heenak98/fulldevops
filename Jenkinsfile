pipeline {
  agent any

  environment {
    SONAR_SCANNER_HOME = "/opt/sonar-scanner/sonar-scanner/bin"
    SONAR_TOKEN = credentials('sonarqube-token')
    ARTIFACTORY_URL = "https://heena98.jfrog.io/artifactory"
    ARTIFACTORY_REPO = "libs-release-local"
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
          sh "$SONAR_SCANNER_HOME/sonar-scanner -Dsonar.login=$SONAR_TOKEN"
        }
      }
    }

    stage('Upload to JFrog') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'jfrog-token', usernameVariable: 'JFROG_USER', passwordVariable: 'JFROG_PASS')]) {
          sh '''
            curl -u $JFROG_USER:$JFROG_PASS -T target/*.jar \
            "$ARTIFACTORY_URL/$ARTIFACTORY_REPO/java-devops-demo/1.0/java-devops-demo-1.0.jar"
          '''
        }
      }
    }
  }
}

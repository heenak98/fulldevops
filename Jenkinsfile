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
            sh '''
            sonar-scanner -Dsonar.login=$SONAR_TOKEN
            '''
            }
      }
    }

    stage('Quality Gate') {
      steps {
        timeout(time: 5, unit: 'MINUTES') {
          waitForQualityGate abortPipeline: true
        }
      }
    }

    stage('Upload to JFrog') {
      steps {
        withCredentials([string(credentialsId: 'jfrog-token', variable: 'JFROG_TOKEN')]) {
          sh '''
            curl -H "Authorization: Bearer ${JFROG_TOKEN}" \
                 -X PUT "https://heena98.jfrog.io/artifactory/libs-release-local/com/heena/devops/demo-app/1.0-SNAPSHOT/demo-app-1.0-SNAPSHOT.jar" \
                 -T demo-app/target/demo-app-1.0-SNAPSHOT.jar
          '''
        }
      }
    }
  }
}

pipeline {
    agent any
    tools {
        maven "MAVEN3"
        jdk "OracleJDK11"
    }
    environment {
        registryCredential = 'ecr:us-east-1:awscreds'
        appRegistry = "945430175090.dkr.ecr.us-east-1.amazonaws.com/vprofileappimg"
        vprofileRegistry = "https://945430175090.dkr.ecr.us-east-1.amazonaws.com"
        cluster = "vprofile_cluster"
        service = "vprofileappsvc"
    }
    stages {
        stage('fetch_code') {
            steps {
                git branch: 'docker', url: 'https://github.com/hkhcoder/vprofile-project.git'
            }
        }
        stage('build') {
            steps {
                sh 'mvn install -DskipTests'
            }
            post {
                success {
                    echo 'Now archiving it'
                    archiveArtifacts artifacts: '**/target/*.war'
                }
            }
        }
        stage('unit_test') {
            steps {
                sh 'mvn test'
            }
        }
        stage('checkstyle_analysis') {
            steps {
                sh 'mvn checkstyle:checkstyle'
            }
        }
        stage('sonar_analysis') {
            environment {
                scannerHome = tool 'sonar4.7'
            }
            steps {
                withSonarQubeEnv('sonar') {
                    sh '''${scannerHome}/bin/sonar-scanner \
                          -Dsonar.projectKey=vprofile \
                          -Dsonar.projectName=vprofile \
                          -Dsonar.projectVersion=1.0 \
                          -Dsonar.sources=src/ \
                          -Dsonar.java.binaries=target/classes/ \
                          -Dsonar.junit.reportsPath=target/surefire-reports/ \
                          -Dsonar.jacoco.reportPaths=target/jacoco.exec \
                          -Dsonar.java.checkstyle.reportPaths=target/checkstyle-result.xml
                    '''
                }
            }
        }
        stage('quality_gate') {
            steps {
                timeout(time: 1, unit: 'HOURS') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }
        stage('build_app_image') {
            steps {
                script {
                    dockerImage = docker.build( appRegistry + ":$BUILD_NUMBER", "./Docker-files/app/multistage/")
                }
            }
        }
        stage('upload_app_image') {
            steps {
                script {
                    docker.withRegistry( vprofileRegistry, registryCredential ) {
                        dockerImage.push("$BUILD_NUMBER")
                        dockerImage.push('latest')
                    }
                }
            }
        }
        stage('Deploy to ecs') {
            steps {
                withAWS(credentials: 'awscreds', region: 'us-east-1') {
                    sh 'aws ecs update-service --cluster ${cluster} --service ${service} --force-new-deployment'
                }
            }
        }
    }
}


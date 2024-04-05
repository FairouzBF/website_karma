pipeline {
    environment {
       ID_DOCKER = "${ID_DOCKER_PARAMS}"
       IMAGE_NAME = "website_karma"
       IMAGE_TAG = "latest"
    }
    agent none
    stages {
        stage('Build') {
            steps {
                script {
                  sh 'docker build -t ${ID_DOCKER}/$IMAGE_NAME:$IMAGE_TAG .'
                }
            }
        }
        stage('Test') {
            agent any
            steps {
                script {
                    sh '''
                        curl jenkins-docker | grep -q "Hello world!"
                    '''
                }
           }
        }
        stage ('Artifact') {
            agent any
            environment {
                DOCKERHUB_PASSWORD  = credentials('dockerhub')
            }
            steps {
                script {
                    sh '''
                    docker push ${ID_DOCKER}/$IMAGE_NAME:$IMAGE_TAG
                    '''
                }
            }
        }   
        stage('Push image in staging and deploy it') {
            when {
                expression { GIT_BRANCH == 'origin/master' }
                }
            agent any
            environment {
                RENDER_STAGING_DEPLOY_HOOK = credentials('render_api_key')
            }  
            steps {
                script {    
                    sh '''
                    echo "Staging"
                    echo $RENDER_STAGING_DEPLOY_HOOK
                    curl $RENDER_STAGING_DEPLOY_HOOK
                    '''
                }
            }
        }
    }
}

/* import shared library */
/* testing 3 git hook */
@Library('shared-library')_

pipeline {
    environment {
        ID_DOCKER = "${ID_DOCKER_PARAMS}"
        IMAGE_NAME = "website-karma"
        IMAGE_TAG = "latest"
        DEFAULT_RECIPIENTS = "fairouz.benfraj@ynov.com"
    }
    agent none
    stages {
        stage('Build image') {
            agent any
            steps {
                script {
                    sh 'docker build -t ${ID_DOCKER}/$IMAGE_NAME:$IMAGE_TAG .'
                }
            }
        }
        stage('Run container based on builded image') {
            agent any
            steps {
                script {
                    sh '''
                    echo "Clean Environment"
                    docker rm -f $IMAGE_NAME || echo "container does not exist"
                    docker run --name $IMAGE_NAME -d -p ${PORT_EXPOSED}:80 -e PORT=80 ${ID_DOCKER}/$IMAGE_NAME:$IMAGE_TAG
                    sleep 5
                    '''
                }
            }
        }
        stage('Test image') {
            agent any
            steps {
                script {
                    sh '''
                    curl http://localhost:${PORT_EXPOSED} | grep -q "Deals of the Week"
                    '''
                }
            }
        }
        stage('Clean Container') {
            agent any
            steps {
                script {
                    sh '''
                    docker stop $IMAGE_NAME
                    docker rm $IMAGE_NAME
                    '''
                }
            }
        }
        stage ('Login and Push Image on docker hub') {
            agent any
            environment {
                DOCKERHUB_PASSWORD  = credentials('159e35f1-8092-4d4b-bd1a-d66088a6d6e0')
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
                RENDER_STAGING_DEPLOY_HOOK = credentials('render_karma_key')
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
    post {
        always {
            script {
                emailNotifier currentBuild.result
            }
        }
    }
}

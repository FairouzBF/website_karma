/* Import de la bibliothèque partagée */
@Library('shared-library')_

pipeline {
    environment {
        // Définition des variables d'environnement
        ID_DOCKER = "${ID_DOCKER_PARAMS}" // ID Docker
        IMAGE_NAME = "website-karma" // Nom de l'image
        IMAGE_TAG = "latest" // Tag de l'image
    }
    agent none // Aucun agent spécifié au niveau global, sera défini au niveau des étapes individuelles
    stages {
        stage('Build image') {
            agent any // Tout agent disponible
            steps {
                script { // Étape de construction de l'image Docker
                    sh 'docker build -t ${ID_DOCKER}/$IMAGE_NAME:$IMAGE_TAG .' // Commande Docker pour construire l'image
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
                    ''' // Attendre quelques secondes
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
                DOCKERHUB_PASSWORD  = credentials('159e35f1-8092-4d4b-bd1a-d66088a6d6e0') // Récupération du mot de passe Docker Hub
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
                expression { GIT_BRANCH == 'origin/master' } // Condition pour exécuter cette étape seulement si la branche est master
            }
            agent any
            environment {
                RENDER_STAGING_DEPLOY_HOOK = credentials('render_karma_key') // Récupération de la clé de déploiement staging
            }
            steps {
                script {
                    sh '''
                    echo "Staging"
                    echo $RENDER_STAGING_DEPLOY_HOOK
                    curl $RENDER_STAGING_DEPLOY_HOOK
                    ''' // Déployer l'image sur le staging
                }
            }
        }
    }
    post {
        always {
            script {
                emailNotifier currentBuild.result // Appel à la fonction pour notifier par email
            }
        }
    }
}

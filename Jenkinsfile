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
        stage('Construction de l'image') {
            agent any // Tout agent disponible
            steps {
                script {
                    // Étape de construction de l'image Docker
                    sh 'docker build -t ${ID_DOCKER}/$IMAGE_NAME:$IMAGE_TAG .' // Commande Docker pour construire l'image
                }
            }
        }
        stage('Exécution du conteneur basé sur l'image construite') {
            agent any // Tout agent disponible
            steps {
                script {
                    sh '''
                    echo "Nettoyer l'environnement"
                    docker rm -f $IMAGE_NAME || echo "Le conteneur n'existe pas"
                    docker run --name $IMAGE_NAME -d -p ${PORT_EXPOSED}:80 -e PORT=80 ${ID_DOCKER}/$IMAGE_NAME:$IMAGE_TAG
                    sleep 5 // Attendre quelques secondes
                    '''
                }
            }
        }
        stage('Test de l\'image') {
            agent any // Tout agent disponible
            steps {
                script {
                    sh '''
                    curl http://localhost:${PORT_EXPOSED} | grep -q "Deals of the Week" // Test de l'image avec curl
                    '''
                }
            }
        }
        stage('Nettoyer le conteneur') {
            agent any // Tout agent disponible
            steps {
                script {
                    sh '''
                    docker stop $IMAGE_NAME // Arrêter le conteneur Docker
                    docker rm $IMAGE_NAME // Supprimer le conteneur Docker
                    '''
                }
            }
        }
        stage ('Connexion et envoi de l'image sur Docker Hub') {
            agent any // Tout agent disponible
            environment {
                DOCKERHUB_PASSWORD  = credentials('159e35f1-8092-4d4b-bd1a-d66088a6d6e0') // Récupération du mot de passe Docker Hub
            }
            steps {
                script {
                    sh '''
                    docker push ${ID_DOCKER}/$IMAGE_NAME:$IMAGE_TAG // Commande pour pousser l'image sur Docker Hub
                    '''
                }
            }
        }    
        stage('Pousser l'image en staging et le déployer') {
            when {
                expression { GIT_BRANCH == 'origin/master' } // Condition pour exécuter cette étape seulement si la branche est master
            }
            agent any // Tout agent disponible
            environment {
                RENDER_STAGING_DEPLOY_HOOK = credentials('render_karma_key') // Récupération de la clé de déploiement staging
            }
            steps {
                script {
                    sh '''
                    echo "Staging"
                    echo $RENDER_STAGING_DEPLOY_HOOK
                    curl $RENDER_STAGING_DEPLOY_HOOK // Déployer l'image sur le staging
                    '''
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

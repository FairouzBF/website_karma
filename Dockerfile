FROM nginx:1.23.1-alpine

# Copie de tous les fichiers et dossiers du répertoire local courant dans le répertoire /usr/share/nginx/html de l'image
COPY ./ /usr/share/nginx/html

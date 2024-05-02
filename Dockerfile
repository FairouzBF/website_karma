FROM amd64/nginx

# Copie de tous les fichiers et dossiers du répertoire local courant dans le répertoire /usr/share/nginx/html de l'image
COPY ./ /usr/share/nginx/html

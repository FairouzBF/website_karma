FROM --platform=linux/amd64 nginx:1.23.1-alpine AS build

RUN compile --target=linux/amd64 -o /out/mybinary

# Copie de tous les fichiers et dossiers du répertoire local courant dans le répertoire /usr/share/nginx/html de l'image
COPY ./ /usr/share/nginx/html

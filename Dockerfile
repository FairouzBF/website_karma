# Utilisez une image de base avec Apache et PHP
FROM php:apache

# Copiez les fichiers nécessaires dans le conteneur
COPY . /var/www/html/

# Exposez le port sur lequel Apache écoute
EXPOSE 80

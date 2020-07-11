#!/bin/bash

# Descobrindo Ip Public da Instancia:

#IP_Private=`curl -s http://169.254.169.254/latest/meta-data/local-ipv4`
IP_Public=`curl -s http://169.254.169.254/latest/meta-data/public-ipv4`

# Intalando pacotes necessários para intalar o WordPress:

sudo apt -y update

sudo apt -y install php-curl php-gd php-mbstring php-xml php-xmlrpc

sudo apt-get -y install mysql-server

sudo apt -y install apache2

sudo apt -y install php libapache2-mod-php php-mysql


#Criando o Banco de Dados do WordPress:

sudo mysql <<EOF

CREATE DATABASE wordpress;

CREATE USER `wp_admin`@`localhost` IDENTIFIED BY 'root';

GRANT ALL ON wordpress.* TO `wp_admin`@`localhost`;

FLUSH PRIVILEGES;
EOF

# Baixando e Configurando o WordPress:

sudo wget https://wordpress.org/latest.tar.gz

sudo mv latest.tar.gz /var/www/

cd /var/www/

sudo tar xpf latest.tar.gz

sudo chown -R www-data:www-data /var/www/wordpress

sudo cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/wordpress.conf


sudo sed -i '10s/^/        ServerName '$IP_Public'/' /etc/apache2/sites-available/wordpress.conf
 
sudo sed -i '12s/html/wordpress/' /etc/apache2/sites-available/wordpress.conf

sudo sed -i '13s/^/        ServerAlias www.acsigt.com/' /etc/apache2/sites-available/wordpress.conf

sudo a2ensite wordpress.conf

sudo systemctl reload apache2




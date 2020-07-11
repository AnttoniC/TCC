#!/bin/bash

IP_PUBLIC=`curl -s http://169.254.169.254/latest/meta-data/public-ipv4`
#IP_PRIVATE=`curl -s http://169.254.169.254/latest/meta-data/local-ipv4`

# Intalando pacotes neceesarios para Instalar o WordPress

sudo apt -y update

sudo apt -y install php-curl php-gd php-mbstring php-xml php-xmlrpc php libapache2-mod-php php-mysql

sudo apt -y install apache2

sudo apt -y install mysql-client

# Baixando e Configurando o WordPress

wget -c http://wordpress.org/latest.tar.gz

sudo mv latest.tar.gz /var/www/

cd /var/www/

sudo tar -xzvf latest.tar.gz

sudo chown -R www-data:www-data /var/www/wordpress
sudo chmod -R 755 /var/www/wordpress/

sudo mv /var/www/wordpress/wp-config-sample.php /var/www/wordpress/wp-config.php

sudo sed -i 's/database_name_here/wordpress/g' /var/www/wordpress/wp-config.php

sudo sed -i 's/username_here/wp_admin/g' /var/www/wordpress/wp-config.php

sudo sed -i 's/password_here/root/g' /var/www/wordpress/wp-config.php

#IP_BD é o ip privado do servidor Banco de Dados onde está o serviço do banco do wordpress

sudo sed -i 's/localhost/'$IP_BD'/g' /var/www/wordpress/wp-config.php


#Configurando arquivo install.php para criar usuario do WP

sudo sed -i '49s/0/2/' /var/www/wordpress/wp-admin/install.php
sudo sed -i '299s/=.*;/="pt_BR";/' /var/www/wordpress/wp-admin/install.php
sudo sed -i '359s/:.*;/:"acsigt.com.br";/' /var/www/wordpress/wp-admin/install.php
sudo sed -i '360s/:.*;/:"'$USER'";/' /var/www/wordpress/wp-admin/install.php
sudo sed -i '361s/:.*;/:"'$PASSWORD'";/' /var/www/wordpress/wp-admin/install.php
sudo sed -i '362s/:.*;/:"'$PASSWORD'";/' /var/www/wordpress/wp-admin/install.php
sudo sed -i '363s/:.*;/:"acigt22@gmail.com";/' /var/www/wordpress/wp-admin/install.php

sudo cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/wordpress.conf

sudo sed -i '10s/^/        ServerName '$IP_PUBLIC'/' /etc/apache2/sites-available/wordpress.conf

sudo sed -i '12s/html/wordpress/' /etc/apache2/sites-available/wordpress.conf

sudo sed -i '13s/^/        ServerAlias www.acsigt.com/' /etc/apache2/sites-available/wordpress.conf

sudo a2enmod rewrite

sudo a2ensite wordpress.conf

sudo systemctl reload apache2


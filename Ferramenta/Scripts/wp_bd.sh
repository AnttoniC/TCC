#!/bin/bash 

#IP_PRIVATE=`curl -s http://169.254.169.254/latest/meta-data/local-ipv4`

#Criando o Banco de Dados do WordPress
sudo apt -y update

sudo apt-get -y install mysql-server

sudo sed -i '43s/127.0.0.1/0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf
#sudo sed -i '43s/^/#/' /etc/mysql/mysql.conf.d/mysqld.cnf

sudo service mysql restart

sudo mysql <<EOF

CREATE DATABASE wordpress;

CREATE USER `wp_admin`@`$IP_WEB` IDENTIFIED BY 'root';

GRANT ALL ON wordpress.* TO `wp_admin`@`$IP_WEB`;

GRANT ALL ON *.* TO 'root'@'$IP_WEB' IDENTIFIED BY 'root' WITH GRANT OPTION;

FLUSH PRIVILEGES;
EOF


#!/bin/bash 

#IP_PRIVATE=`curl -s http://169.254.169.254/latest/meta-data/local-ipv4`

#Criando o Banco de Dados do WordPress
sudo apt -y update

sudo apt-get -y install mysql-server

sudo sed -i '43s/127.0.0.1/0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf
#sudo sed -i '43s/^/#/' /etc/mysql/mysql.conf.d/mysqld.cnf

sudo service mysql restart

#IP_WEB é o ip privado do servidor web onde está o serviço do wordpress

sudo mysql <<EOF
CREATE DATABASE wordpress;
#GRANT ALL ON wordpress.* TO 'wp_admin'@'$IP_WEB' IDENTIFIED BY 'root' WITH GRANT OPTION;
GRANT ALL ON wordpress.* TO 'wp_admin'@'%' IDENTIFIED BY 'root' WITH GRANT OPTION;
FLUSH PRIVILEGES;
\q;
EOF






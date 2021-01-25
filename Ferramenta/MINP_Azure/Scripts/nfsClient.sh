#!/bin/bash

#  Instalando NFS no Cliente

sudo apt -y update

sudo apt -y install nfs-common

#   Montando a pasta no Cliente
#criando diretorio para /home para receber os arquivos compatilhado
sudo mkdir -p /home

#Compartilhando o diretorio /home com os Clients no diretorio /home
sudo mount 10.0.0.6:/home /home

#  verificando montagem da pasta

df -h

#Compartilhando IP_Private com o Master para acessar os 

ip=`hostname -I | cut -f1 -d' '`
echo $ip >> /home/ubuntu/IPs.txt

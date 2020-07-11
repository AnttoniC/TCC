#!/bin/bash

#  Instalando NFS no Cliente

sudo apt -y update

sudo apt -y install nfs-common

#   Montando a pasta no Cliente
#criando diretorio para /nfs/home para receber os arquivos compatilhado
sudo mkdir -p /nfs/home

#Compartilhando o diretorio /home com os Clients no diretorio /nfs/home
sudo mount $ipS:/home /nfs/home

#  verificando montagem da pasta

df -h

#Compartilhando IP_Private com o Master para acessar os 
ip_private=`curl -s http://169.254.169.254/latest/meta-data/local-ipv4`
echo $ip_private >> /nfs/home/ubuntu/IPs.txt

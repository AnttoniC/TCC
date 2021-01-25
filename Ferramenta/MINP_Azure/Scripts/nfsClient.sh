#!/bin/bash

#  Instalando NFS no Cliente

sudo apt -y update

sudo apt -y install nfs-common

#   Montando a pasta no Cliente
#criando diretorio para /nfs/home para receber os arquivos compatilhado
sudo mkdir -p /home

#Compartilhando o diretorio /home com os Clients no diretorio /nfs/home
sudo mount 10.0.0.6:/home /home

#  verificando montagem da pasta

df -h

#Compartilhando IP_Private com o Master para acessar os 
sudo apt -y install jq
ip=`curl -s -H Metadata:true http://169.254.169.254/metadata/instance?api-version=2017-04-02 | jq -r .network.interface[].ipv4.ipAddress[].publicIpAddress)`
echo $ip >> /home/ubuntu/IPs.txt
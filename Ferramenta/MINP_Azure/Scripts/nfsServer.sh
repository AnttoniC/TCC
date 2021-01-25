#!/bin/bash
#Pegado ip private e colocando no arquivo IPs.txt

ipS=`hostname -I | cut -f1 -d' '`
touch /home/ubuntu/IPs.txt
echo $ipS >> /home/ubuntu/IPs.txt

#   Instalando NFS no Servidor
sudo apt-get -y update

sudo apt-get -y install nfs-kernel-server

#   Configurando a exportação do NFS no Servidor

sudo chmod 777 /etc/exports

sudo echo /home       10.0.0.0/16'(rw,sync,no_root_squash,no_subtree_check)' >> /etc/exports

sudo chmod 644 /etc/exports
sudo systemctl restart nfs-kernel-server

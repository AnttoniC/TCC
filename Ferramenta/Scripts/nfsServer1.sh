#!/bin/bash

#ipC1_private=`curl -s http://169.254.169.254/latest/meta-data/local-ipv4`
#ipS_private=`curl -s http://169.254.169.254/latest/meta-data/local-ipv4`

#   Instalando NFS no Servidor

sudo apt-get -y update

sudo apt-get -y install nfs-kernel-server

#   Configurando a exportação do NFS no Servidor

chmod 777 /etc/exports

echo /home       $ipSub'(rw,sync,no_root_squash,no_subtree_check)' >> /etc/exports

chmod 644 /etc/exports
systemctl restart nfs-kernel-server

#!/bin/bash

az vm create --generate-ssh-keys -n mac05 -g SG --image UbuntuLTS

az vm create -n mac06 -g SG --image UbuntuLTS

#criando grupo de recursos
az group create --name mySG --location eastus

#criar VM
az vm create \
  --resource-group mySG \
  --name myVM \
  --image UbuntuLTS \
  --admin-username acsuser \
  --generate-ssh-keys


# Habilitar porta para determinada VM

az vm open-port --port 2049 --resource-group myRG --name myVM

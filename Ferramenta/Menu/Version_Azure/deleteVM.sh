#!/bin/bash

# deletando todas as VMs de um grupo de recursos

az vm delete --ids $(az vm list -g SG --query "[].id" -o tsv)

# Delenteando uma VM especifica 
# -g expecifica o grupo de recursos
# -n nome da VM ex: mac01

az vm delete -g SG -n mac01 --yes

# listar id de VMs de um grupo
az vm list -g SG --query "[].id" -o tsv

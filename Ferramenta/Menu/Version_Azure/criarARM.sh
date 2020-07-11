#!/bin/bash

#Implementando modelo de Armazenamento pelo Azure Cli usando o grupo de recurso SG
az group deployment create --resource-group SG --template-file "Criar_Conta_Armazenamento.json"



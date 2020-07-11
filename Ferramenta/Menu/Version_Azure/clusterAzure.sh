#!/bin/bash

x="iniciar"
menu ()
{
while true $x != "iniciar"
do
clear



echo "############                   Menu De Implatação de Cluster Na Azure                 ###############"
echo "#                                                                                                   #"
echo "#  opção 1 para Criar um Cluster com grupo de seguraça                                              #"
echo "#  opção 2 para Criar um Maquina Virtual(VM)                                                        #"
echo "#  opção 3 para Criar um Grupo de Recursos(RG)                                                      #"
echo "#  opção 4 para Criar Regras em Grupo de Segurança de uma determinada VM                            #"
echo "#  opção 5 para deletar todas as VMs de um grupo de recursos                                        #"
echo "#  opção 6 Sair do Menu                                                                             #"
echo "#                                                                                                   #"
echo "#####################################################################################################"

echo "Digite a opção desejada:"
read x
echo "Opção informada ($x)"


case $x in
	#1)
	#read -p "Digite o nome da chave(aws_key): " KEY_AWS
	#read -p "Digite o nome da Maquina Virtual: " VM
	#read -p "Digite o nome do grupo Recursos: " GR
	#az vm create -n $VM -g $RG --image UbuntuLTS
	#;;
	2)
	
	#read -p "Digite o nome da chave(aws_key): " KEY_AWS
	read -p "Digite o nome da Chave(azureKey.pub): " KEY_AZURE
	read -p "Digite o nome da Maquina Virtual: " VM
	read -p "Digite o nome do Usuario da VM: " USER
	read -p "Digite o nome do grupo Recursos(GP_Azure): " GR
	az vm create -n $VM -g $GR --admin-username $USER --image UbuntuLTS --ssh-key-values $KEY_AZURE
	#az vm create -g MyResourceGroup -n MyVm --image debian --custom-data MyCloudInitScript.yml
	;;
	3)
	read -p "Digite o Nome do grupo de recursos: " NAME_GR
	az group create -l centralus -n $NAME_GR
	;;
	4)
	read -p "Digite o Nome da VM: " VM
	read -p "Digite o Nome do Grupo de Recurso(GP_Azure): " GR
	read -p "Digite a Porta que quer add no Grupo de Recursos da VM: " PORTA
	az vm open-port --port $PORTA --resource-group $GR --name $VM
	;;
	5)
	az vm delete --ids $(az vm list -g $GR --query "[].id" -o tsv)
	;;
	6)
    echo "saindo..."
    sleep 1
    clear;
    exit;
	;;
	*)
	echo "Opção desconhecida"
esac



done

}
menu


#!/bin/bash


x="iniciar"
menu ()
{
while true $x != "iniciar"
do
clear



echo "###################   Menu AWS  ##########################"
echo "#                                                        #"
echo "#  opção 1 Implantar Cluster na AWS                      #"
echo "#  opção 2 Criar Cluster na AWS                          #"
echo "#  opção 3 Deletar Cluster na AWS                        #"
echo "#  opção 4 Listar nomes das Stacks na AWS                #"
echo "#  opção 5 Sair do Menu                                  #"
echo "#                                                        #"
echo "##########################################################"

echo "Digite a opção desejada [1-5]:"
read x
echo "Opção informada ($x)"


case $x in 
	1)
	#Implantação de um cluster já definido.
	echo " ex (/home/acsigt/TCC2/template/AWS/Cluster_teste01.json)"
	read -p "Digite caminho do template: " CAMINHO
	echo "Caminho do template para Impantação : $CAMINHO"
	read -p "Digite nome da Stack: " STACKNAME
	echo "Nome da stack : $STACKNAME"
	aws cloudformation deploy --template-file $CAMINHO --stack-name $STACKNAME
	;;
	2)
	#Criação de cluster e template do zero!!
	bash create_template.sh
	;;
	3)
	#Deletar Stack criada no cloudFormation
	read -p "Digite o nome da Stack para DELETAR: " DEL_STACK 
	echo "Nome da stack : $DEL_STACK"
	echo "Aperte [enter] duas vezes para finalizar o cluster."
	read -p "Primeira vez."
	read -p "Segunda vez."
	aws cloudformation delete-stack --stack-name $DEL_STACK
	;;
	4)
	#Listar Stack do cloudformation
	aws cloudformation list-stacks --stack-status-filter CREATE_COMPLETE > STACKNAME.txt
	cat STACKNAME.txt | grep "StackName"
	rm -rf STACKNAME.txt
	;;
	5)
	echo "saindo..."
         sleep 1
         clear;
         exit;	
	;;
	*)
	echo "Opcao desconhecida"

esac

done

}
menu


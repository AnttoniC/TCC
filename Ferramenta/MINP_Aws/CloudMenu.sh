#!/bin/bash


x="iniciar"
menu ()
{
while true $x != "iniciar"
do
clear



echo "######### Menu de Implantação de em Nuvens Publica   ########"
echo "#                                                           #"
echo "#  opção 1 Menu AWS                                         #"
echo "#  opção 2 Menu Azure                                       #"
echo "#  opção 3 Sair do Menu                                     #"
echo "#                                                           #"
echo "#############################################################"

echo "Digite a opção desejada [1-3]:"
read x
echo "Opção informada ($x)"


case $x in 
	1)
	bash ClusterAWS.sh
	;;
	2)
	#bash ClusterAzure.sh
	echo "Opção Indisponivel no Momento"
	;;
	3)
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


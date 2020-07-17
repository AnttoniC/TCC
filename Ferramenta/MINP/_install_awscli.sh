#!/bin/bash

#!/bin/bash


x="iniciar"
menu ()
{
while true $x != "iniciar"
do
clear



echo "#########    Instalaçõs do AWS-CLI Versão 1       ########"
echo "#                                                        #"
echo "#  opção 1 Linux                                         #"
echo "#  opção 2 macOS                                         #"
echo "#  opção 3 Sair do Menu                                  #"
echo "#                                                        #"
echo "##########################################################"

echo "Digite a opção desejada [1-3]:"
read x
echo "Opção informada ($x)"


case $x in 
	1)
	sudo apt install -y curl
	curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
	unzip awscli-bundle.zip
	sudo ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws

	aws --version
	;;
	2)
	curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
	unzip awscli-bundle.zip
	sudo ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
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

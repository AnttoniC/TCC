#!/bin/bash


id=""

read -p "Digite o Id da Instancia: " id
aws ec2 describe-instances --filters "Name=instance-id,Values=$id" --query 'Reservations[].Instances[*].{tag:Tags}' --output text > dados.txt

tr '\t' ':' < dados.txt > name.txt

name=`cut -d: -f3 name.txt`



x="iniciar"
menu ()
{
while true $x != "iniciar"
do
clear



echo "############ Menu Iniciando Instancia AWS ###############"
echo "#                                                       #"
echo "#  opção 1 para iniciar a intancia                      #"
echo "#  opção 2 para desligar a intancia                     #"
echo "#  opção 3 para eliminar a intancia                     #"
echo "#  opção 4 Sair do Menu                                 #"
echo "#                                                       #"
echo "#########################################################"

echo "Digite a opção desejada:"
read x
echo "Opção informada ($x)"


#IP_PUBLIC=$(aws ec2 describe-instances --instance-ids $id --query "Reservations[0].Instances[0].PublicIpAddress" --output text)

case $x in
	1)
	aws ec2 start-instances --instance-ids $id
	echo "Iniciando a instancia $name"
	aws ec2 wait instance-running --instance-ids $id
	IP_PUBLIC=$(aws ec2 describe-instances --instance-ids $id --query "Reservations[0].Instances[0].PublicIpAddress" --output text)
	echo "ssh -i aws_key.pem ubuntu@$IP_PUBLIC"
	;;
	2)
	aws ec2 stop-instances --instance-ids $id
        echo "Parando a instancia $name"
	;;
	3)
	aws ec2 terminate-instances --instance-ids $id
        echo "Inciaando a instancia $name"
	;;
	#4)
	#bash createInstancia.sh
	#;;
	4)
         echo "saindo..."
         sleep 1
         clear;
         exit;
	 ;;
	*)
	echo "Opção desconhecida"
esac

#rm -rf dados.txt name.txt


done

}
menu


#!/bin/bash


x="iniciar"
menu ()
{
while true $x != "iniciar"
do
clear



echo "######### Menu Listar Dados das Instancias AWS ########"
echo "#                                                     #"
echo "#  opção 1 Listar IPs Public das Intancias            #"
echo "#  opção 2 Listar images id das Intancias             #"
echo "#  opção 3 Listar IPs Private das Intancias           #"
echo "#  opção 4 Listar nomes das Intancias                 #"
echo "#  opção 5 Listar images ids das Intancias Ubuntu     #"
echo "#  opção 6 Listar dados da subredes das Intancias     #"
echo "#  opção 7 Listar instances ids e nomes das Intancias #"
echo "#  opção 8 Sair do Menu                               #"
echo "#                                                     #"
echo "#######################################################"

echo "Digite a opção desejada:"
read x
echo "Opção informada ($x)"


case $x in 
	1)
	# Listar IPs Public das Intancias
        #aws ec2 describe-instances --instance-ids --query Reservations[].Instances[].PublicIpAddress	
	aws ec2 describe-instances --filters "Name=tag:Name,Values=*" --query 'Reservations[].Instances[*].{tag:Tags,ip:PublicIpAddress}' --output text
	echo "IPs Publicos das intancias do ec2"
	;;
	2)
	# Listar images id das Intancias
	aws ec2 describe-instances --filters Name=tag:Name,Values=* --query Reservations[].Instances[].ImageId
	echo "Images Ids de todas as intancias do ec2"
	;;
	3)
	# Listar IPs Private das Intancias
	aws ec2 describe-instances --filters Name=tag:Name,Values=* --query Reservations[].Instances[].PrivateIpAddress
	echo "IPs Privados das intancias do ec2"
	;;
	4)
	# Listar nomes das Intancias
	aws ec2 describe-instances --filters Name=tag:Name,Values=* --query Reservations[].Instances[].Tags
	echo "Nomes das intancias do ec2"
	;;
	5)
	# Listar images ids das Intancias Ubuntu
	aws ec2 describe-images --filters "Name=name,Values=ubuntu" --query 'Images[*].{ID:ImageId,DS:description}' --output text
	echo "Images Ids das intancias Ubuntu do ec2"
	;;
	6)
	# Listar dados da subredes das Intancias
	aws ec2 describe-subnets --filters "Name=cidr,Values=*"
	echo "Dados das subredes das intancias do ec2"
	;;
	7)
        # Listar instances ids e nomes das Intancias
        aws ec2 describe-instances --filters "Name=tag:Name,Values=*" --query 'Reservations[].Instances[*].{ID:InstanceId,tag:Tags}' --output text
        echo "Instances Ids e nomes das intancias do ec2"
	;;
	#8)
	#bash menuIniciarInsta.sh
	#;;
 	8)
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


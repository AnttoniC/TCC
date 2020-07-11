#!/bin/bash +x

echo "Digite a Chave para Intancia:"
read KEY_AWS
echo "A chave informada ($KEY_AWS)"

echo "Digite o Nome da Intancia:"
read name
echo "O nome informado ($name)"

#criando instancia unbuntu 18.04 em uma determinda Subrede  

ID_INSTANCIA=$(aws ec2 run-instances --image-id ami-07ebfd5b3428b6f4d --count 1 --instance-type t2.micro --key-name $KEY_AWS --security-group-ids sg-0c1bfdbd112ec1073 --subnet-id subnet-04dd013e1d5212f0f --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value='$name'}]' --query "Instances[0].InstanceId" --output text)

#criando instancia unbuntu 18.04  
#ID_INSTANCIA=$(aws ec2 run-instances --image-id ami-07ebfd5b3428b6f4d --count 1 --instance-type t2.micro --key-name $KEY_AWS --security-groups SG-Docker --query "Instances[0].InstanceId" --output text)

echo "Aguardando a criação da instância $ID_INSTANCIA..."
aws ec2 wait instance-running --instance-ids $ID_INSTANCIA

# Recuperando endereço público da instância
IP_PUBLIC=$(aws ec2 describe-instances --instance-ids $ID_INSTANCIA --query "Reservations[0].Instances[0].PublicIpAddress" --output text)

echo "Conexões SSH permitidas na instância $ID_INSTANCIA no endereço $IP_PUBLIC."
echo "Abra outro terminal e execute:"
echo "ssh -i $KEY_AWS.pem ubuntu@$IP_PUBLIC"
#echo "Ou acess a página:"
#echo "http://$IP_PUBLIC"
#read -p "Aperte [Enter] para finalizar a instância..."

# Finalizando a instância
#aws ec2 terminate-instances --instance-ids $ID_INSTANCIA

#!/bin/bash -e

#Quantidade Nós no Cluster.
#NOS=""
#read -p "Digite a quantidade de NÓS do Cluster: " NOS
#echo "Quantidade de nos do Cluster: $NOS"
#tipo de isntancias da AWS mais comuns
echo "[t2.micro,t2.medium,t2.xlarge]"
read -p "Digite o tipo de instancia dos NÓS do Cluster: " INSTANCETYPE
INSTANCETYPE=""
echo "Tipo de Instancia a ser utilizado: $INSTANCETYPE"


# Nome da chave que deseja usar
KEYNAME=vall_key
echo "Chave a ser utilizada: $KEYNAME"

# Recupera o ID de uma rede
VPCID=$(aws ec2 describe-vpcs --filter "Name=tag:Name, Values=VPC-DEV" --query "Vpcs[0].VpcId" --output text)
echo "ID do VPC: $VPCID"

# Recupera o ID da subrede padrão do VPC
SUBNETID=$(aws ec2 describe-subnets --filter "Name=vpc-id, Values=$VPCID" --query "Subnets[0].SubnetId" --output text)
echo "ID da Subnet: $SUBNETID"

# Gera nome único para a pilha
STACKNAME="cluster"`date +%H%M%S`



aws cloudformation create-stack --stack-name "$STACKNAME" --template-body file://ClusterNFS.json --parameters \
ParameterKey=InstanceType,ParameterValue=$INSTANCETYPE \
ParameterKey=KeyName,ParameterValue=$KEYNAME \
ParameterKey=VPC,ParameterValue=$VPCID \
ParameterKey=Subnet,ParameterValue=$SUBNETID 

STATUS=$(aws cloudformation describe-stacks --stack-name "$STACKNAME" --query 'Stacks[*].StackStatus' --output text)
while [ "$STATUS" != "CREATE_COMPLETE" ]
do
    STATUS=$(aws cloudformation describe-stacks --stack-name "$STACKNAME" --query 'Stacks[*].StackStatus' --output text)
    echo "Cluster em criação..."
    sleep 10
done

PUBLICIP=$(aws cloudformation describe-stacks --stack-name "$STACKNAME"  --query 'Stacks[*].Outputs[*].OutputValue' --output text)

#HOSTS=1
#while [ "$HOSTS" -eq 1 ]
#do
#    HOSTS=$(ssh -oStrictHostKeyChecking=no -i "$KEYNAME".pem ubuntu@"$PUBLICIP" wc -l /home/hostfile | awk '{print $1}')
#    echo "Estabelecendo ligação entre os nós..."
#    sleep 10
#done

echo "Cluster criado."
echo "Acesse em outro terminal por:"
echo "ssh -i $KEYNAME.pem ubuntu@$PUBLICIP"

echo "Aperte [enter] duas vezes para finalizar o cluster."
read -p "Primeira vez."
read -p "Segunda vez."
aws cloudformation delete-stack --stack-name $STACKNAME

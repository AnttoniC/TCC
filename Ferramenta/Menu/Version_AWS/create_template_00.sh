#!/bin/bash

touch cluster_template.json

read -p "Digite a quantidade de NÓS do Cluster: " N
echo "[t2.micro,t2.small,t2.medium]"
read -p "Digite o tipo de instancia dos NÓS do Cluster: " INSTANCETYPE
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

cat << EOF >> cluster_template.json
{
    "AWSTemplateFormatVersion": "2010-09-09",
    "Description": "Criacao de um cluster",
    "Parameters": {
        "KeyName": {
            "Description": "Nome do par de chaves",
            "Type": "AWS::EC2::KeyPair::KeyName",
            "Default": "vall_key"    
        },
        "VPC": {
            "Description": "O VPC a ser utilizado",
			"Type": "AWS::EC2::VPC::Id",
			"Default": "vpc-0af6b63fc583890ee"
        },
        "Subnet": {
            "Description": "Subrede a ser utilizada",
			"Type": "AWS::EC2::Subnet::Id",
			"Default": "subnet-04dd013e1d5212f0f"
        },
        "InstanceType": {
            "Description": "Tipo de instancia",
            "Type": "String",
            "Default": "t2.micro",
            "AllowedValues": [
                "t2.micro",
                "t2.small",
                "t2.medium"
            ]
        }
    }
    ,
    "Resources": {
        "GrupoDeSeguranca": {
            "Type": "AWS::EC2::SecurityGroup",
            "Properties": {
                "GroupDescription": "Grupo de Seguranca",
                "VpcId": {
                    "Ref": "VPC"
                },
                "SecurityGroupIngress": [
                    {
                        "CidrIp": "0.0.0.0/0",
                        "FromPort": 22,
                        "IpProtocol": "tcp",
                        "ToPort": 22
                    }
                ]
            }
        },
        "Master": {
            "Type": "AWS::EC2::Instance",
            "Properties": {
                "Tags": [
                    {
                        "Key": "Name",
                        "Value": "Master"
                    }
                ],
                "ImageId": "ami-024a64a6685d05041",
                "InstanceType": {
                    "Ref": "InstanceType"
                },
                "KeyName": {
                    "Ref": "KeyName"
                },
                "SecurityGroupIds": [
                    {
                        "Ref": "GrupoDeSeguranca"
                    }
                ],
                "SubnetId": {
                    "Ref": "Subnet"
                }
        }
    }
EOF

for i in $(seq 1 $N);
  do
  i=$((i+0))
  SlaveName=Salve$i
  cat  << EOF >> cluster_template.json
  ,
  "$SlaveName": {
            "Type": "AWS::EC2::Instance",
            "Properties": {
                "Tags": [
                    {
                        "Key": "Name",
                        "Value": "$SlaveName"
                    }
                ],
                "ImageId": "ami-024a64a6685d05041",
                "InstanceType": {
                    "Ref": "InstanceType"
                },
                "KeyName": {
                    "Ref": "KeyName"
                },
                "SecurityGroupIds": [
                    {
                        "Ref": "GrupoDeSeguranca"
                    }
                ],
                "SubnetId": {
                    "Ref": "Subnet"
                }
        }
    }
EOF
  done

cat << EOF >> cluster_template.json
   },
    "Outputs": {
        "EnderecoPublicoMaster": {
            "Value": {
                "Fn::GetAtt": [
                    "Master",
                    "PublicIp"
                ]
            },
            "Description": "Endereco para acessar o Master"
        }
    }
  }

EOF

aws cloudformation create-stack --stack-name "$STACKNAME" --template-body file://cluster_template.json --parameters \
ParameterKey=InstanceType,ParameterValue=$INSTANCETYPE \
ParameterKey=KeyName,ParameterValue=$KEYNAME \
ParameterKey=VPC,ParameterValue=$VPCID \
ParameterKey=Subnet,ParameterValue=$SUBNETID 
rm -rf cluster_template.json
STATUS=$(aws cloudformation describe-stacks --stack-name "$STACKNAME" --query 'Stacks[*].StackStatus' --output text)
while [ "$STATUS" != "CREATE_COMPLETE" ]
do
    STATUS=$(aws cloudformation describe-stacks --stack-name "$STACKNAME" --query 'Stacks[*].StackStatus' --output text)
    echo "Cluster em criação..."
    sleep 10
done

PUBLICIP=$(aws cloudformation describe-stacks --stack-name "$STACKNAME"  --query 'Stacks[*].Outputs[*].OutputValue' --output text)

echo "Cluster criado."
echo "Acesse em outro terminal por:"
echo "ssh -i $KEYNAME.pem ubuntu@$PUBLICIP"

echo "Aperte [enter] duas vezes para finalizar o cluster."
read -p "Primeira vez."
read -p "Segunda vez."
aws cloudformation delete-stack --stack-name $STACKNAME
#rm -rf cluster_template.json

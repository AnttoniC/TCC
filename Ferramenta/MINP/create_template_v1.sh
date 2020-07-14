#!/bin/bash

touch cluster_template.json

read -p "Digite a quantidade de NÓS do Cluster: " N

read -p "Qual a chave a ser usada: " KEYNAME
aws ec2 create-key-pair --key-name $KEYNAME --query 'KeyMaterial' --output text > $KEYNAME.pem
chmod 400 $KEYNAME.pem
echo "A chave informada é: $KEYNAME"

echo "[t2.micro,t2.small,t2.medium]"
read -p "Digite o tipo de instancia dos NÓS do Cluster: " INSTANCETYPE
echo "Tipo de Instancia a ser utilizado: $INSTANCETYPE"


# Nome da chave que deseja usar
#KEYNAME=vall_key
#echo "Chave a ser utilizada: $KEYNAME"

# Recupera o ID de uma rede
#VPCID=$(aws ec2 describe-vpcs --filter "Name=tag:Name, Values=ClusterVPC" --query "Vpcs[0].VpcId" --output text)
#echo "ID do VPC: $VPCID"

# Recupera o ID da subrede padrão do VPC
#SUBNETID=$(aws ec2 describe-subnets --filter "Name=vpc-id, Values=$VPCID" --query "Subnets[0].SubnetId" --output text)
#echo "ID da Subnet: $SUBNETID"

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
            "Default": "$KEYNAME"    
        },
        
        "FaixaIPVPC": {
            "Description": "Faixa IP Utilizada no VPC",
            "Type": "String",
            "Default": "10.0.0.0/16",
            "AllowedValues": [
                "10.0.0.0/16",
                "172.16.0.0/16",
                "192.168.0.0/16"
            ]
        },
        "FaixaIPSubrede": {
            "Description": "Faixa IP Utilizada na Subrede",
            "Type": "String",
            "Default": "10.0.10.0/24",
            "AllowedValues": [
                "10.0.10.0/24",
                "172.16.10.0/24",
                "192.168.10.0/24"
            ]
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

        "VPC": {
            "Type": "AWS::EC2::VPC",
            "Properties": {
                "CidrBlock": {
                    "Ref": "FaixaIPVPC"
                },
                "Tags": [
                    {
                        "Key": "Name",
                        "Value": "ClusterVPC"
                    }
                ]

            }
        },
        "Subnet": {
            "Type": "AWS::EC2::Subnet",
            "Properties": {
                "VpcId": {
                    "Ref": "VPC"
                },
                "CidrBlock": {
                    "Ref": "FaixaIPSubrede"
                },
                "MapPublicIpOnLaunch" : "true"
            }
        },
        "RoteadorInternet": {
            "Type": "AWS::EC2::InternetGateway"
            
        },
        
        "LigacaoRoteadorVPC": {
            "Type": "AWS::EC2::VPCGatewayAttachment",
            "Properties": {
                "InternetGatewayId": {
                    "Ref": "RoteadorInternet"
                },
                "VpcId": {
                    "Ref": "VPC"
                }
            }
        },

        "TabelaRoteamento": {
            "Type": "AWS::EC2::RouteTable",
            "Properties": {
                "VpcId": {
                    "Ref": "VPC"
                }
                
            }
        },
        "EntradaTabelaRoteamento": {
            "Type": "AWS::EC2::Route",
            "Properties": {
                "GatewayId": {
                    "Ref": "RoteadorInternet"
                },
                "DestinationCidrBlock": "0.0.0.0/0",
                "RouteTableId": {
                    "Ref": "TabelaRoteamento"
                }
            }
        },
        "LigacaoTabelaSubRede": {
            "Type": "AWS::EC2::SubnetRouteTableAssociation",
            "Properties": {
                "SubnetId": {
                    "Ref": "Subnet"
                },
                "RouteTableId": {
                    "Ref": "TabelaRoteamento"
                }
            }
        },

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
                    },
                    {
                        "CidrIp": "0.0.0.0/0",
                        "FromPort": 2049,
                        "IpProtocol": "tcp",
                        "ToPort": 2049
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
                },
                 "UserData": {
                    "Fn::Base64": {
                        "Fn::Join": [
                            "",
                            [
								"#!/bin/bash -ex \n",
                                "curl -s https://raw.githubusercontent.com/AnttoniC/TAR/master/CF/nfsServer.sh | bash -ex \n"
                            ]
                        ]
                    }
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
                },
                "UserData": {
                    "Fn::Base64": {
                        "Fn::Join": [
                            "",
                            [
                                "#!/bin/bash -ex \n",
                                "export ipS=\"",{"Fn::GetAtt": ["Master","PrivateIp"]},"\" \n",
                                "curl -s https://raw.githubusercontent.com/AnttoniC/TAR/master/CF/nfsClient.sh | bash -ex \n"
                            ]
                        ]
                    }
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
ParameterKey=FaixaIPVPC,ParameterValue="10.0.0.0/16" \
ParameterKey=FaixaIPSubrede,ParameterValue="10.0.10.0/24"

STATUS_1=CREATE_COMPLETE
STATUS_2=ROLLBACK_IN_PROGRESS
STATUS=$(aws cloudformation describe-stacks --stack-name "$STACKNAME" --query 'Stacks[*].StackStatus' --output text)
#echo $STATUS_1
#echo $STATUS_2
#echo $STATUS
#while [ $STATUS != $STATUS_1 -o $STATUS != $STATUS_2 ]
while [ $STATUS != "CREATE_COMPLETE" ] 
do   
STATUS=$(aws cloudformation describe-stacks --stack-name "$STACKNAME" --query 'Stacks[*].StackStatus' --output text)
echo "Cluster em criação..."
sleep 10
echo "Status atual do cluster em: $STATUS"
done

if [ $STATUS = "CREATE_COMPLETE" ];
   then
   echo "Cluster criado."
elif [ $STATUS = "ROLLBACK_IN_PROGRESS" ];
    then
    echo "Erro ao criado cluster."
else
echo "Algo deu errado na execução" 
fi

PUBLICIP=$(aws cloudformation describe-stacks --stack-name "$STACKNAME"  --query 'Stacks[*].Outputs[*].OutputValue' --output text)

echo "Acesse em outro terminal por:"
echo "ssh -A $KEYNAME.pem ubuntu@$PUBLICIP"

echo "Aperte [enter] duas vezes para finalizar o cluster."
read -p "Primeira vez."
read -p "Segunda vez."
aws cloudformation delete-stack --stack-name $STACKNAME
aws ec2 delete-key-pair --key-name $KEYNAME
rm -rf cluster_template.json
rm -rf $KEYNAME.pem

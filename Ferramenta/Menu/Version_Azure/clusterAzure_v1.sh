#!/bin/bash
read -p "Digite o nome do grupo de recursos: " ResourceGroup
# A conta de armazenamento deve ser única. 
StorageAccount="storage"`date +%H%M%S`
# criando grupo de recursos na região Centro-Sul dos EUA (southcentralus).
az group create --name $ResourceGroup --location southcentralus

# criando conta de armazenamento para implantar recursos na mesma região (southcentralus).
az storage account create -n $StorageAccount -g $ResourceGroup -l southcentralus --sku Standard_LRS

#deletando grupo de recursos.
#az group delete -n $ResourceGroup

touch vmscript.json

S='$schema'

cat << EOF >> vmscript.json


{
  "$S": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",

  "parameters": {
    "vmName": {
      "defaultValue": "vmScript",
      "type": "string",
      "minLength": 1
    },
    "vmAdminUserName": {
      "defaultValue": "ubuntu",
      "type": "string",
      "minLength": 1
    },
    "authenticationType": {
      "type": "string",
      "defaultValue": "sshPublicKey",
      "allowedValues": [
        "sshPublicKey",
        "password"
      ]

    },
    "vmAdminPasswordorKey": {
      "defaultValue": "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDZ6LS/i0hmmQuhx9fDHcEsB3jEyuZCydkwMUGJ66d/LLbadbiIhBZO0HVWTUO9QaLXSSHaah7pRHyK0TvmcLlgoBIP4VZQpdynDRXU+4P69wxGA9xctenCgfKci1jI33DRsksA41BelEmFb1h3oKI+n9s0EJzEhnXAOxkcu9+XNKe4lprGvFSk58LlHjwjqepVSlIpR89YR7GaD1jlEpVOzjQUEL2AHB83YT6WtkWUvcYU/vtRd9alsXZvycT3j516vj/vIGt0+t60GT7o+d94hRucIMB5K7cbIQIC2598w6PCjhsfHSgSMCt/4Hv1My5C4V2SWUHC0494jrpagBKz acsigt@acsigt-Win",
      "type": "securestring"
    },

    "vmUbuntuOSVersion": {
      "type": "string",
      "defaultValue": "18.04-LTS",
      "allowedValues": [
        "12.04.5-LTS",
        "14.04.2-LTS",
        "16.04.0-LTS",
        "18.04-LTS"
      ]
    },


    "vmSize": {
      "defaultValue": "Standard_F1",
      "type": "string",
      "allowedValues": [
        "Standard_F1",
        "Standard_F3",
        "Standard_F4",
        "Standard_D1_v2",
        "Standard_D2_v2",
        "Standard_D3_v2",
        "Standard_D4_v2 "
      ],
      "metadata": {
        "description": "Size of vm"
      }
    },
    "networkSecurityGroupName": {
      "type": "string",
      "defaultValue": "vmSecGroupNet"
    },

    "storageAccountName": {
      "type": "string",
      "defaultValue": "$StorageAccount"
    },
    "storageAccountResourceGroup": {
      "type": "string",
      "defaultValue": "$ResourceGroup"
    },
    "ipPublicDnsName": {
      "defaultValue": "dnsip",
      "type": "string",
      "minLength": 1
    },
    "_artifactsLocation": {
      "defaultValue": "https://raw.githubusercontent.com/AnttoniC/Cloud-Computing/master/Azure",
      "type": "string"

    }
  },
  "variables": {
    "vNetPrefix": "10.0.0.0/16",
    "vNetSubnet1Name": "Subnet-1",
    "vNetSubnet1Prefix": "10.0.0.0/24",
    "vNetSubnet2Name": "Subnet-2",
    "vNetSubnet2Prefix": "10.0.1.0/24",
    "vmImagePublisher": "Canonical",
    "vmImageOffer": "UbuntuServer",
    "vmOSDiskName": "vmOSDisk",
    "vmVnetID": "[resourceId('Microsoft.Network/virtualNetworks', 'vNet')]",
    "vmSubnetRef": "[concat(variables('vmVnetID'), '/subnets/', variables('vNetSubnet1Name'))]",
    "vmStorageAccountContainerName": "vhds",
    "vmNicName": "[concat(parameters('vmName'), 'NetworkInterface')]",
    "ipPublicName": "ipPublic",
    "linuxConfiguration": {
      "disablePasswordAuthentication": true,
      "ssh": {
        "publicKeys": [
          {
            "path": "[concat('/home/', parameters('vmAdminUserName'), '/.ssh/authorized_keys')]",
            "keyData": "[parameters('vmadminPasswordOrKey')]"
          }
        ]
      }
    }
  },
  "resources": [
    {
      "name": "vNet",
      "type": "Microsoft.Network/virtualNetworks",
      "location": "[resourceGroup().location]",
      "apiVersion": "2016-03-30",
      "dependsOn": [],
      "tags": {
        "displayName": "vNet"
      },
      "properties": {
        "addressSpace": {
          "addressPrefixes": [
            "[variables('vNetPrefix')]"
          ]
        },
        "subnets": [
          {
            "name": "[variables('vNetSubnet1Name')]",
            "properties": {
              "addressPrefix": "[variables('vNetSubnet1Prefix')]"
            }
          },
          {
            "name": "[variables('vNetSubnet2Name')]",
            "properties": {
              "addressPrefix": "[variables('vNetSubnet2Prefix')]"
            }
          }
        ]
      }
    },

    {
      "name": "[parameters('networkSecurityGroupName')]",
      "apiVersion": "2016-03-30",
      "type": "Microsoft.Network/networkSecurityGroups",
      "location": "[resourceGroup().location]",
      "properties": {
        "securityRules": [
          {
            "name": "SSH",
            "properties": {
              "priority": 1000,
              "protocol": "TCP",
              "access": "Allow",
              "direction": "Inbound",
              "sourceAddressPrefix": "*",
              "sourcePortRange": "*",
              "destinationAddressPrefix": "*",
              "destinationPortRange": "22"
            }
          }
        ]
      }

    },

    {
      "name": "[variables('vmNicName')]",
      "type": "Microsoft.Network/networkInterfaces",
      "location": "[resourceGroup().location]",
      "apiVersion": "2016-03-30",
      "dependsOn": [
        "[resourceId('Microsoft.Network/networkSecurityGroups/', parameters('networkSecurityGroupName'))]",
        "[resourceId('Microsoft.Network/virtualNetworks', 'vNet')]",
        "[resourceId('Microsoft.Network/publicIPAddresses', variables('ipPublicName'))]"
      ],
      "tags": {
        "displayName": "vmNic"
      },
      "properties": {
        "ipConfigurations": [
          {
            "name": "ipconfig1",
            "properties": {
              "privateIPAllocationMethod": "Dynamic",
              "subnet": {
                "id": "[variables('vmSubnetRef')]"
              },
              "publicIPAddress": {
                "id": "[resourceId('Microsoft.Network/publicIPAddresses', variables('ipPublicName'))]"
              },
              "networkSecurityGroup": {
                "id": "[resourceId('Microsoft.Network/networkSecurityGroups',parameters('networkSecurityGroupName'))]"
              }
            }
          }
        ]
      }
    },

    {
      "name": "[parameters('vmName')]",
      "type": "Microsoft.Compute/virtualMachines",
      "location": "southcentralus",
      "apiVersion": "2015-06-15",
      "dependsOn": [
        "[resourceId('Microsoft.Network/networkInterfaces', variables('vmNicName'))]"
      ],
      "tags": {
        "displayName": "vm"
      },
      "properties": {
        "hardwareProfile": {
          "vmSize": "[parameters('vmSize')]"
        },
        "osProfile": {
          "computerName": "[parameters('vmName')]",
          "adminUsername": "[parameters('vmAdminUsername')]",
          "adminPassword": "[parameters('vmAdminPasswordorKey')]",
          "linuxConfiguration": "[if(equals(parameters('authenticationType'), 'password'), json('null'), variables('linuxConfiguration'))]"
        },
        "storageProfile": {
          "imageReference": {
            "publisher": "[variables('vmImagePublisher')]",
            "offer": "[variables('vmImageOffer')]",
            "sku": "[parameters('vmUbuntuOSVersion')]",
            "version": "latest"
          },
          "osDisk": {
            "name": "vmOSDisk",
            "vhd": {
              "uri": "[concat(reference(resourceId(parameters('storageAccountResourceGroup'), 'Microsoft.Storage/storageAccounts', parameters('storageAccountName')), '2016-01-01').primaryEndpoints.blob, variables('vmStorageAccountContainerName'), '/', variables('vmOSDiskName'), '.vhd')]"
            },
            "caching": "ReadWrite",
            "createOption": "FromImage"
          }
        },
        "networkProfile": {
          "networkInterfaces": [
            {
              "id": "[resourceId('Microsoft.Network/networkInterfaces', variables('vmNicName'))]"
            }
          ]
        }
      }
    },

    {
      "type": "Microsoft.Compute/virtualMachines/extensions",
      "name": "[concat(parameters('vmName'),'/installcustomscript')]",
      "apiVersion": "2015-05-01-preview",
      "location": "[resourceGroup().location]",
      "dependsOn": [
        "[concat('Microsoft.Compute/virtualMachines/', parameters('vmName'))]"
      ],
      "properties": {
        "publisher": "Microsoft.Azure.Extensions",
        "type": "CustomScript",
        "typeHandlerVersion": "2.0",
        "autoUpgradeMinorVersion": true,
        "settings": {
          "fileUris": [
            "[concat(parameters('_artifactsLocation'), '/Scripts/InstallApache2.sh')]"
          ],
          "commandToExecute": "bash InstallApache2.sh"
        }
      }
    },

    {
      "name": "[variables('ipPublicName')]",
      "type": "Microsoft.Network/publicIPAddresses",
      "location": "[resourceGroup().location]",
      "apiVersion": "2016-03-30",
      "dependsOn": [],
      "tags": {
        "displayName": "ipPublic"
      },
      "properties": {
        "publicIPAllocationMethod": "Dynamic",
        "dnsSettings": {
          "domainNameLabel": "[parameters('ipPublicDnsName')]"
        }
      }
    }
  ],
  "outputs": {}

}


EOF

az deployment group create --resource-group $ResourceGroup --template-file /home/acsigt/azure/vmscript.json
echo "Aperte [enter] duas vezes para finalizar o Grupo de Recursos."
read -p "Primeira vez."
read -p "Segunda vez."
echo "deletando $ResourceGroup ..."
az group delete -n $ResourceGroup

#
# +-------------------------------------------------------------------+
# | Azure-VM-Deploy                                                   |
# | Create an Azure virtual machine with resources using PowerShell   |
# |-------------------------------------------------------------------|
# | File Name:  Script.ps1                                             |
# | Program Version:  0.1-alpha - Code Name: INSZURE                  |
# | Website:  https://www.insentrica.net                              |
# | Author:  Valikahn <giti@insentrica.net>                           |
# | Copyright (C) 2020 - 2021 Valikahn <git@insentrica.net>           |
# | Licensed under the GPLv3 License.                                 |
# +-------------------------------------------------------------------+
# | Last Updated on May 2, 2021 by Valikahn                           |
# | Website:  https://www.insentrica.net                              |
# | Github:   https://github.com/Valikahn                             |
# | GPLv3 Licence:  https://www.gnu.org/licenses/gpl-3.0.en.html      |
# +-------------------------------------------------------------------+
#

## Login to Azure Environment
Connect-AzAccount

## Variables
####
Write-Output -InputObject "Loading variables"
Start-Sleep -s 5

	$Location = "ukwest"
	$RGName = "Insentrica-DevOps"
	$HDDName = "INSStorage02082021".ToLower()
	$SAName = "INSBlobStorage02082021".ToLower()
	$SubnetName = "INSSubnet001"
	$SubnetRange = "10.11.1.0/24"
	$VNetName = "INSVirNetwork"
	$VNetRange = "10.11.0.0/16"
	$PublicIPName = "INSPublicIP"
	$PublicDNS = "valikahnpubdns"
	$NSGName = "INSNSG001"
	$NSGNameRuleSSH = "SSHPortRule22"
	$NSGNameRuleWeb = "WebPortRule80"
	$NICName = "INSNIC001"
	$AVSet = "INSAVSet"
	$VMName = "INSAZIT001"
	$VMImage = "UbuntuLTS"
	$VMSize = "Standard_B1ls"
	$DiskSku = "Standard_LRS"
	$OSDiskSize = "120"  ##  In Gigabytes (GB)
	$DataDiskSize = "250"  ##  In Gigabytes (GB)

Read-Host -Prompt 'Completed...Press Enter to continue'
cls

## Create resource group
####
Write-Output -InputObject "Create a resource group"
	az group create --name $RGName --location $Location
	cls

# Create a new storage account
Write-Output -InputObject "Creating storage account"
    $StorageAccount = New-AzStorageAccount -Location $Location -ResourceGroupName $RGName -Type "Standard_LRS" -Name $SAName
	cls

## Create Virtual Network and Subnet
####
Write-Output -InputObject "Create Virtual Network and Subnet"
	az network vnet create --resource-group $RGName --name $VNetName --address-prefix $VNetRange --subnet-name $SubnetName --subnet-prefix $SubnetRange
	cls

## Create Public IP and DNS Address
####
Write-Output -InputObject "Create Public IP and DNS Address"
	az network public-ip create --resource-group $RGName --name $PublicIPName --dns-name $PublicDNS
	cls

## Create Network Security Group
####
Write-Output -InputObject "Create Network Security Group"
	az network nsg create --resource-group $RGName --name $NSGName
	cls
	
## Create Network Security Group Policy for SSH Port 22
####
	Write-Output -InputObject "Create Network Security Group Policy for SSH Port 22"
	az network nsg rule create --resource-group $RGName --nsg-name $NSGName --name $NSGNameRuleSSH --protocol tcp --priority 1000 --destination-port-range 22 --access allow
	cls

## Create Network Security Group Policy for SSH Port 80
####
	Write-Output -InputObject "Create Network Security Group Policy for SSH Port 80"
	az network nsg rule create --resource-group $RGName --nsg-name $NSGName --name $NSGNameRuleWeb --protocol tcp --priority 1001 --destination-port-range 80 --access allow
	cls
			
## Apply Network Security Group Policies
####
	Write-Output -InputObject "Apply Network Security Group Policies"
	az network nsg show --resource-group $RGName --name $NSGName
	cls

## Create Network Interface Card
####
Write-Output -InputObject "Create Network Interface Card"
	az network nic create --resource-group $RGName --name $NICName --vnet-name $VNetName --subnet $SubnetName --public-ip-address $PublicIPName --network-security-group $NSGName
	cls

## Create Availability Set for Resource Group
####
Write-Output -InputObject "Create Availability Set for Resource Group"
	az vm availability-set create --resource-group $RGName --name $AVSet
	cls

## Create Virtual Machine
####
Write-Output -InputObject "Create Virtual Machine"
    $Username = 'Insentrica'.ToLower()
    $Password = '!n$entrICA2021!' | ConvertTo-SecureString -Force -AsPlainText
	az vm create --resource-group $RGName --name $VMName --storage-sku $DiskSku --os-disk-size-gb $OSDiskSize --location $Location --availability-set $AVSet --nics $NICName --image $VMImage --size $VMSize --admin-username $Username --admin-password $Password
	az vm disk attach -g $RGName --vm-name $VMName --name $HDDName --new --size-gb $DataDiskSize --sku $DiskSku
#	Read-Host -Prompt 'Completed...Press Enter to continue'
	cls

## Success Message
####
Write-Output -InputObject "Virtual machine created successfully"
	Read-Host -Prompt “Press Enter to exit”

#  
#  
#  
#  
#  
#####################   
##  End of Script  ##
#####################

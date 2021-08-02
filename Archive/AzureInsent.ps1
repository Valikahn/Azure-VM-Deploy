#
# +-------------------------------------------------------------------+
# | Azure-VM-Deploy                                                   |
# | Create an Azure virtual machine with resources using PowerShell   |
# |-------------------------------------------------------------------|
# | File Name:  Azure.ps1                                             |
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

# Start message Message
Read-Host -Prompt 'Press Enter to continue'


## Create SSH key pair
## Write-Output -InputObject "Create SSH key pair"
## ssh-keygen -t rsa -b 4096
## Read-Host -Prompt 'Press Enter to continue'
cls

## Create a resource group
####
Write-Output -InputObject "Create a resource group"
New-AzResourceGroup -Name "myResourceGroup" -Location "UK West"
Read-Host -Prompt 'Press Enter to continue'
cls

##Create virtual network resources
####
# Create a subnet configuration
Write-Output -InputObject "Create virtual network resources"
$subnetConfig = New-AzVirtualNetworkSubnetConfig `
  -Name "mySubnet" `
  -AddressPrefix 192.168.1.0/24
Read-Host -Prompt 'Press Enter to continue'
cls

# Create a virtual network
Write-Output -InputObject "Create a virtual network"
$vnet = New-AzVirtualNetwork `
  -ResourceGroupName "myResourceGroup" `
  -Location "UK West" `
  -Name "myVNET" `
  -AddressPrefix 192.168.0.0/16 `
  -Subnet $subnetConfig
Read-Host -Prompt 'Press Enter to continue'
cls

# Create a public IP address and specify a DNS name
Write-Output -InputObject "Create a public IP address and specify a DNS name"
$pip = New-AzPublicIpAddress `
  -ResourceGroupName "myResourceGroup" `
  -Location "UK West" `
  -AllocationMethod Static `
  -IdleTimeoutInMinutes 4 `
  -Name "mypublicdns$(Get-Random)"
Read-Host -Prompt 'Press Enter to continue'
cls

# Create an inbound network security group rule for port 22
Write-Output -InputObject "Create an inbound network security group rule for port 22"
$nsgRuleSSH = New-AzNetworkSecurityRuleConfig `
  -Name "myNetworkSecurityGroupRuleSSH"  `
  -Protocol "Tcp" `
  -Direction "Inbound" `
  -Priority 1000 `
  -SourceAddressPrefix * `
  -SourcePortRange * `
  -DestinationAddressPrefix * `
  -DestinationPortRange 22 `
  -Access "Allow"
Read-Host -Prompt 'Press Enter to continue'
cls

# Create an inbound network security group rule for port 80
Write-Output -InputObject "Create an inbound network security group rule for port 80"
$nsgRuleWeb = New-AzNetworkSecurityRuleConfig `
  -Name "myNetworkSecurityGroupRuleWWW"  `
  -Protocol "Tcp" `
  -Direction "Inbound" `
  -Priority 1001 `
  -SourceAddressPrefix * `
  -SourcePortRange * `
  -DestinationAddressPrefix * `
  -DestinationPortRange 80 `
  -Access "Allow"
Read-Host -Prompt 'Press Enter to continue'
cls

# Create a network security group
Write-Output -InputObject "Create a network security group"
$nsg = New-AzNetworkSecurityGroup `
  -ResourceGroupName "myResourceGroup" `
  -Location "UK West" `
  -Name "myNetworkSecurityGroup" `
  -SecurityRules $nsgRuleSSH,$nsgRuleWeb
Read-Host -Prompt 'Press Enter to continue'
cls

# Create a virtual network card and associate with public IP address and NSG
Write-Output -InputObject "Create a virtual network card and associate with public IP address and NSG"
$nic = New-AzNetworkInterface `
  -Name "myNic" `
  -ResourceGroupName "myResourceGroup" `
  -Location "UK West" `
  -SubnetId $vnet.Subnets[0].Id `
  -PublicIpAddressId $pip.Id `
  -NetworkSecurityGroupId $nsg.Id
Read-Host -Prompt 'Press Enter to continue'
cls

# Define a credential object to store the username and password for the virtual machine
Write-Output -InputObject "Creating Credentials for Virtual Machine"
    $Username = "Insentrica"
    $Password = 'Ma6t0gr6d!' | ConvertTo-SecureString -Force -AsPlainText
    $Credential = New-Object -TypeName PSCredential -ArgumentList ($Username, $Password)
Read-Host -Prompt 'Press Enter to continue'
cls

# Create availability set
Write-Output -InputObject "Creating Availability Set"
az vm availability-set create --resource-group myResourceGroup --name myAvailabilitySet
Read-Host -Prompt 'Press Enter to continue'
cls

# Create a virtual machine configuration
Write-Output -InputObject "Create a virtual machine configuration"
$vmConfig = New-AzVMConfig `
  -VMName "myVM" `
  -VMSize "Standard_D1" | `
Set-AzVMOperatingSystem `
  -Linux `
  -ComputerName "myVM" `
  -Credential $Credential `
  -DisablePasswordAuthentication | `
Set-AzVMSourceImage `
  -image UbuntuLTS | `
Add-AzVMNetworkInterface `
  -Id $nic.Id
Read-Host -Prompt 'Press Enter to continue'
cls

# az vm create --resource-group myResourceGroup --name myVM --location ukwest --availability-set myAvailabilitySet --nics myNic --image UbuntuLTS --admin-username azureuser --generate-ssh-keys

# Configure the SSH key
## Write-Output -InputObject "Configure the SSH key"
## $sshPublicKey = cat ~/.ssh/id_rsa.pub
## Add-AzVMSshPublicKey `
##   -VM $vmconfig `
##   -KeyData $sshPublicKey `
##   -Path "/home/azureuser/.ssh/authorized_keys"

New-AzVM `
  -ResourceGroupName "myResourceGroup" `
  -Location ukwest -VM -availability-set myAvailabilitySet $vmConfig
Read-Host -Prompt 'Press Enter to continue'
cls

# Success Message
Write-Output -InputObject "Virtual machine created successfully"
Read-Host -Prompt “Press Enter to exit”
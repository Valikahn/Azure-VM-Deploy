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


## Create a resource group
####
Write-Output -InputObject "Virtual machine created successfully"
New-AzResourceGroup -Name "myResourceGroup" -Location "UK West"
Read-Host -Prompt 'Press Enter to continue'


##Create virtual network resources
####
# Create a subnet configuration
Write-Output -InputObject "Virtual machine created successfully"
$subnetConfig = New-AzVirtualNetworkSubnetConfig `
  -Name "mySubnet" `
  -AddressPrefix 192.168.1.0/24

Read-Host -Prompt 'Press Enter to continue'

# Create a virtual network
Write-Output -InputObject "Virtual machine created successfully"
$vnet = New-AzVirtualNetwork `
  -ResourceGroupName "myResourceGroup" `
  -Location "UK West" `
  -Name "myVNET" `
  -AddressPrefix 192.168.0.0/16 `
  -Subnet $subnetConfig

Read-Host -Prompt 'Press Enter to continue'

# Create a public IP address and specify a DNS name
Write-Output -InputObject "Virtual machine created successfully"
$pip = New-AzPublicIpAddress `
  -ResourceGroupName "myResourceGroup" `
  -Location "UK West" `
  -AllocationMethod Static `
  -IdleTimeoutInMinutes 4 `
  -Name "mypublicdns$(Get-Random)"

Read-Host -Prompt 'Press Enter to continue'

# Create an inbound network security group rule for port 22
Write-Output -InputObject "Virtual machine created successfully"
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

# Create an inbound network security group rule for port 80
Write-Output -InputObject "Virtual machine created successfully"
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

# Create a network security group
Write-Output -InputObject "Virtual machine created successfully"
$nsg = New-AzNetworkSecurityGroup `
  -ResourceGroupName "myResourceGroup" `
  -Location "UK West" `
  -Name "myNetworkSecurityGroup" `
  -SecurityRules $nsgRuleSSH,$nsgRuleWeb

Read-Host -Prompt 'Press Enter to continue'

# Create a virtual network card and associate with public IP address and NSG
Write-Output -InputObject "Virtual machine created successfully"
$nic = New-AzNetworkInterface `
  -Name "myNic" `
  -ResourceGroupName "myResourceGroup" `
  -Location "UK West" `
  -SubnetId $vnet.Subnets[0].Id `
  -PublicIpAddressId $pip.Id `
  -NetworkSecurityGroupId $nsg.Id

Read-Host -Prompt 'Press Enter to continue'

## Create a virtual machine
####
# Define a credential object
Write-Output -InputObject "Virtual machine created successfully"
$securePassword = ConvertTo-SecureString ' ' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ("azureuser", $securePassword)

Read-Host -Prompt 'Press Enter to continue'

# Create a virtual machine configuration
Write-Output -InputObject "Virtual machine created successfully"
$vmConfig = New-AzVMConfig `
  -VMName "myVM" `
  -VMSize "Standard_D1" | `
Set-AzVMOperatingSystem `
  -Linux `
  -ComputerName "myVM" `
  -Credential $cred `
  -DisablePasswordAuthentication | `
Set-AzVMSourceImage `
  -PublisherName "Focal Fossa" `
  -Offer "UbuntuServer" `
  -Skus "20.04-LTS" `
  -Version "latest" | `
Add-AzVMNetworkInterface `
  -Id $nic.Id

Read-Host -Prompt 'Press Enter to continue'

# Configure the SSH key
Write-Output -InputObject "Virtual machine created successfully"
$sshPublicKey = cat ~/.ssh/id_rsa.pub
Add-AzVMSshPublicKey `
  -VM $vmconfig `
  -KeyData $sshPublicKey `
  -Path "/home/azureuser/.ssh/authorized_keys"

Read-Host -Prompt 'Press Enter to continue'
  
New-AzVM `
  -ResourceGroupName "myResourceGroup" `
  -Location ukwest -VM $vmConfig


# Success Message
Write-Output -InputObject "Virtual machine created successfully"
Read-Host -Prompt “Press Enter to exit”
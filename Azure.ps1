# Copyright (C) 2020 - 2021 Valikahn <git@insentrica.net>
# Program v0.1-alpha - Code Name: INSZURE
# Licensed under the GPLv3 License.

# Website:  https://www.insentrica.net
# Github:   https://github.com/Valikahn/lamp
# GPLv3 Licence:  https://www.gnu.org/licenses/gpl-3.0.en.html 

# Initialise environment and variables

## Login
Connect-AzAccount

# Input Variables
$Location = "ukwest"
$RGName = "Insentrica-VM"
$SAName = "INSStorage31072021".ToLower()
$SubnetName = "INSSubnet001"
$SubnetRange = "10.11.1.0/24"
$VNetName = "INSVirNetwork"
$VNetRange = "10.11.0.0/16"
$PublicIPName = "INSPublicIP"
$NSGName = "INSNSG001"
$NICName = "INSNIC001"
$ComputerName = "INS-AZ-IT-001"
$VMName = "INSAZIT001"
$VMSize = "Standard_B1ls"
$VMImage = "*/Ubuntu/Skus/20.04-LTS"

# Create a new resource group
Write-Output -InputObject "Creating resource group"
New-AzResourceGroup -Name $RGName -Location $Location

## Create storage resources

# Create a new storage account
Write-Output -InputObject "Creating storage account"
$StorageAccount = New-AzStorageAccount -Location $Location -ResourceGroupName $RGName -Type "Standard_LRS" -Name $SAName

## Create network resources

# Create a subnet configuration
Write-Output -InputObject "Creating virtual network"
$SubnetConfig = New-AzVirtualNetworkSubnetConfig -Name $SubnetName -AddressPrefix $SubnetRange

# Create a virtual network
$VirtualNetwork = New-AzVirtualNetwork -ResourceGroupName $RGName -Location $Location -Name $VNetName -AddressPrefix $VNetRange -Subnet $SubnetConfig

# Create a public IP address
Write-Output -InputObject "Creating public IP address"
$PublicIP = New-AzPublicIpAddress -ResourceGroupName $RGName -Location $Location -AllocationMethod "Dynamic" -Name $PublicIPName

# Create network security group rule (SSH or RDP)
Write-Output -InputObject "Creating SSH/RDP network security rule"
$SecurityGroupRule = switch ("-Linux") {
    "-Linux" { New-AzNetworkSecurityRuleConfig -Name "SSH-Rule" -Description "Allow SSH" -Access "Allow" -Protocol "TCP" -Direction "Inbound" -Priority 100 -DestinationPortRange 22 -SourceAddressPrefix "*" -SourcePortRange "*" -DestinationAddressPrefix "*" }
    "-Windows" { New-AzNetworkSecurityRuleConfig -Name "RDP-Rule" -Description "Allow RDP" -Access "Allow" -Protocol "TCP" -Direction "Inbound" -Priority 100 -DestinationPortRange 3389 -SourceAddressPrefix "*" -SourcePortRange "*" -DestinationAddressPrefix "*" }
}

# Create a network security group
Write-Output -InputObject "Creating network security group"
$NetworkSG = New-AzNetworkSecurityGroup -ResourceGroupName $RGName -Location $Location -Name $NSGName -SecurityRules $SecurityGroupRule

# Create a virtual network card and associate it with the public IP address and NSG
Write-Output -InputObject "Creating network interface card"
$NetworkInterface = New-AzNetworkInterface -Name $NICName -ResourceGroupName $RGName -Location $Location -SubnetId $VirtualNetwork.Subnets[0].Id -PublicIpAddressId $PublicIP.Id -NetworkSecurityGroupId $NetworkSG.Id

## Create the virtual machine

# Define a credential object to store the username and password for the virtual machine
$Username = "Insentrica"
$Password = 'Ma6t0gr6d!' | ConvertTo-SecureString -Force -AsPlainText
$Credential = New-Object -TypeName PSCredential -ArgumentList ($Username, $Password)

# Create the virtual machine configuration object
$VirtualMachine = New-AzVMConfig -VMName $VMName -VMSize $VMSize

# Set the VM Size and Type
$VirtualMachine = Set-AzVMOperatingSystem -VM $VirtualMachine -Linux -ComputerName $ComputerName -Credential $Credential

# Enable the provisioning of the VM Agent
if ($VirtualMachine.OSProfile.WindowsConfiguration) {
    $VirtualMachine.OSProfile.WindowsConfiguration.ProvisionVMAgent = $true
}

# Get the VM Source Image
$Image = Get-AzVMImagePublisher -Location $Location | Get-AzVMImageOffer | Get-AzVMImageSku | Where-Object -FilterScript { $_.Id -like $VMImage }

# Set the VM Source Image
$VirtualMachine = Set-AzVMSourceImage -VM $VirtualMachine -PublisherName $Image.PublisherName -Offer $Image.Offer -Skus $Image.Skus -Version "latest"

# Add Network Interface Card
$VirtualMachine = Add-AzVMNetworkInterface -Id $NetworkInterface.Id -VM $VirtualMachine

# Set the OS Disk properties
$OSDiskName = "OsDisk"
$OSDiskUri = "{0}vhds/{1}-{2}.vhd" -f $StorageAccount.PrimaryEndpoints.Blob.ToString(), $VMName.ToLower(), $OSDiskName

# Applies the OS disk properties
$VirtualMachine = Set-AzVMOSDisk -VM $VirtualMachine -Name $OSDiskName -VhdUri $OSDiskUri -CreateOption "FromImage"

# Create the virtual machine.
Write-Output -InputObject "Creating virtual machine"
$NewVM = New-AzVM -ResourceGroupName $RGName -Location $Location -VM $VirtualMachine
$NewVM
Write-Output -InputObject "Virtual machine created successfully"

#
# +-------------------------------------------------------------------+
# | Azure-VM-Deploy                                                   |
# | Create an Azure virtual machine with resources using PowerShell   |
# |-------------------------------------------------------------------|
# | File Name:  Azure.ps1                                             |
# | Program Version:  0.2-alpha - Code Name: INSZURE                  |
# | Website:  https://www.insentrica.net                              |
# | Author:  Valikahn <giti@insentrica.net>                           |
# | Copyright (C) 2020 - 2021 Valikahn <git@insentrica.net>           |
# | Licensed under the GPLv3 License.                                 |
# +-------------------------------------------------------------------+
# | Last Updated on August 2, 2021 by Valikahn                        |
# | Website:  https://www.insentrica.net                              |
# | Github:   https://github.com/Valikahn                             |
# | GPLv3 Licence:  https://www.gnu.org/licenses/gpl-3.0.en.html      |
# +-------------------------------------------------------------------+
#

# Declare endpoint
# $ArmEndpoint = "https://management.region.insentrica.net"

## Login to Azure Environment
Connect-AzAccount

# Get location
# $Location = Get-AzLocation | Where-Object {($_.Location -Like 'uk*')}

# Input Variables
$Location = "UK West"
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
$VMSize = "Standard_B1s"
$VMImage = "Canonical"
#$VMOffer = "UbuntuServer"
$VMOffer = "0001-com-ubuntu-server-hirsute"
$Skus = "21_04"


# Start message Message
Write-Output -InputObject "Azure-VM-Deploy script is about to start."
write-host "`n"
Read-Host -Prompt �Press Enter to Continue�
cls

# Create a new resource group
Write-Output -InputObject "Creating resource group"
    New-AzResourceGroup -Name $RGName -Location $Location
	Read-Host -Prompt �Press Enter to Continue�
	cls

## Create storage resources

# Create a new storage account
Write-Output -InputObject "Creating storage account"
    $StorageAccount = New-AzStorageAccount -Location $Location -ResourceGroupName $RGName -Type "Standard_LRS" -Name $SAName
	Read-Host -Prompt �Press Enter to Continue�
	cls

## Create network resources

# Create a subnet configuration
Write-Output -InputObject "Creating virtual network"
    $SubnetConfig = New-AzVirtualNetworkSubnetConfig -Name $SubnetName -AddressPrefix $SubnetRange
	Read-Host -Prompt �Press Enter to Continue�
	cls

# Create a virtual network
Write-Output -InputObject "Creating virtual subnet "
	$VirtualNetwork = New-AzVirtualNetwork -ResourceGroupName $RGName -Location $Location -Name $VNetName -AddressPrefix $VNetRange -Subnet $SubnetConfig
	Read-Host -Prompt �Press Enter to Continue�
	cls

# Create a public IP address
Write-Output -InputObject "Creating public IP address"
    $PublicIP = New-AzPublicIpAddress -ResourceGroupName $RGName -Location $Location -AllocationMethod "Dynamic" -Name $PublicIPName
	Read-Host -Prompt �Press Enter to Continue�
	cls

# Create network security group rule (SSH or RDP)
Write-Output -InputObject "Creating SSH/RDP network security rule"
    $SecurityGroupRule = switch ("-Linux") {
        "-Linux" { New-AzNetworkSecurityRuleConfig -Name "SSH-Rule" -Description "Allow SSH" -Access "Allow" -Protocol "TCP" -Direction "Inbound" -Priority 100 -DestinationPortRange 22 -SourceAddressPrefix "*" -SourcePortRange "*" -DestinationAddressPrefix "*" }
        "-Windows" { New-AzNetworkSecurityRuleConfig -Name "RDP-Rule" -Description "Allow RDP" -Access "Allow" -Protocol "TCP" -Direction "Inbound" -Priority 100 -DestinationPortRange 3389 -SourceAddressPrefix "*" -SourcePortRange "*" -DestinationAddressPrefix "*" }
}
Read-Host -Prompt �Press Enter to Continue�
cls

# Create a network security group
Write-Output -InputObject "Creating network security group"
    $NetworkSG = New-AzNetworkSecurityGroup -ResourceGroupName $RGName -Location $Location -Name $NSGName -SecurityRules $SecurityGroupRule
	Read-Host -Prompt �Press Enter to Continue�
	cls

# Create a virtual network card and associate it with the public IP address and NSG
Write-Output -InputObject "Creating network interface card"
    $NetworkInterface = New-AzNetworkInterface -Name $NICName -ResourceGroupName $RGName -Location $Location -SubnetId $VirtualNetwork.Subnets[0].Id -PublicIpAddressId $PublicIP.Id -NetworkSecurityGroupId $NetworkSG.Id
	Read-Host -Prompt �Press Enter to Continue�
	cls

## Create the virtual machine

# Define a credential object to store the username and password for the virtual machine
Write-Output -InputObject "Creating Credentials for Virtual Machine"
    $Username = "Insentrica"
    $Password = 'InSeNtRiCa2021' | ConvertTo-SecureString -Force -AsPlainText
    $Credential = New-Object -TypeName PSCredential -ArgumentList ($Username, $Password)
	Read-Host -Prompt �Press Enter to Continue�
	cls

# Create the virtual machine configuration object
Write-Output -InputObject "Creating Virtual Machine Config Object"
    $VirtualMachine = New-AzVMConfig -VMName $VMName -VMSize $VMSize
	Read-Host -Prompt �Press Enter to Continue�
	cls

# Set the VM Size and Type
Write-Output -InputObject "Set the Virtual Machine Size and Type"
    $VirtualMachine = Set-AzVMOperatingSystem -VM $VirtualMachine -Linux -ComputerName $ComputerName -Credential $Credential
	Read-Host -Prompt �Press Enter to Continue�
	cls

# Enable the provisioning of the VM Agent
Write-Output -InputObject "Provisioning Agent"
    if ($VirtualMachine.OSProfile.WindowsConfiguration) {
        $VirtualMachine.OSProfile.WindowsConfiguration.ProvisionVMAgent = $true
    }
Read-Host -Prompt �Press Enter to Continue�
cls

# Get the VM Source Image
#Write-Output -InputObject "Get Virtual Machine Source Image"
    # $Image = Get-AzVMImagePublisher -Location $Location | Get-AzVMImageOffer | Get-AzVMImageSku | Where-Object -FilterScript { $_.Id -like $VMImage }
	# $Image = Get-AzVMImageSku -Location $Location -PublisherName $VMImage -Offer $VMOffer | Where-Object -FilterScript {($_.Offer -eq $VMOffer)}
	# Read-Host -Prompt �Press Enter to Continue�
	# cls
	
# Set the VM Source Image
Write-Output -InputObject "Setting Virtual Machine Source Image"
	$VirtualMachine = Set-AzVMSourceImage -VM $VirtualMachine -PublisherName $VMImage -Offer $VMOffer -Skus $Skus -Version "latest"
	#$VirtualMachine = Set-AzVMSourceImage -VM $VirtualMachine -PublisherName $Image.PublisherName -Offer $Image.Offer -Skus $Image.Skus -Version "latest"
	#$VirtualMachine = Set-AzVMSourceImage -VM $VirtualMachine -PublisherName "Canonical" -Offer "UbuntuServer" -Skus "*" -Version "latest"
	Read-Host -Prompt �Press Enter to Continue�
	cls

# Add Network Interface Card
Write-Output -InputObject "Adding Network Interface Card to Virtual Machine"
    $VirtualMachine = Add-AzVMNetworkInterface -Id $NetworkInterface.Id -VM $VirtualMachine
	Read-Host -Prompt �Press Enter to Continue�
	cls

# Set the OS Disk properties
Write-Output -InputObject "Setting the Operating System Disk Configurations"
    $OSDiskName = "OsDisk"
    $OSDiskUri = "{0}vhds/{1}-{2}.vhd" -f $StorageAccount.PrimaryEndpoints.Blob.ToString(), $VMName.ToLower(), $OSDiskName
	Read-Host -Prompt �Press Enter to Continue�
	cls

# Applies the OS disk properties
Write-Output -InputObject "Applying the Operating System Disk Configurations"
    $VirtualMachine = Set-AzVMOSDisk -VM $VirtualMachine -Name $OSDiskName -VhdUri $OSDiskUri -CreateOption "FromImage"
	Read-Host -Prompt �Press Enter to Continue�
	cls

# Create the virtual machine.
Write-Output -InputObject "Creating virtual machine"
    $NewVM = New-AzVM -ResourceGroupName $RGName -Location $Location -VM $VirtualMachine
    $NewVM
	Read-Host -Prompt �Press Enter to Continue�
	cls

# Success Message
Write-Output -InputObject "Virtual machine created successfully"
Read-Host -Prompt �Press Enter to exit�
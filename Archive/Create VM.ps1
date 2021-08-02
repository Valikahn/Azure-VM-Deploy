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

$resourceGoupName = 'skylinespsdemo'
$azureRegion = 'East US'
$vmName = 'MYVM'

#region Create the resource group
New-AzResourceGroup -Name $resourceGoupName -Location $azureRegion
#endregion

#region Create the vNet for the VM
$newSubnetParams = @{
    'Name'          = 'MySubnet'
    'AddressPrefix' = '10.0.1.0/24'
}
$subnet = New-AzVirtualNetworkSubnetConfig @newSubnetParams

$newVNetParams = @{
    'Name'              = 'MyNetwork'
    'ResourceGroupName' = $resourceGoupName
    'Location'          = $azureRegion
    'AddressPrefix'     = '10.0.0.0/16'
}
$vNet = New-AzVirtualNetwork @newVNetParams -Subnet $subnet
#endregion

#region Create the storage account
$newStorageAcctParams = @{
    'Name'              = 'skylinesdemo1' ## Must be globally unique and all lowercase
    'ResourceGroupName' = $resourceGoupName
    'Type'              = 'Standard_LRS'
    'Location'          = $azureRegion
}
$storageAccount = New-AzStorageAccount @newStorageAcctParams
#endregion

#region Create the public IP address
$newPublicIpParams = @{
    'Name'              = 'MyNIC'
    'ResourceGroupName' = $resourceGoupName
    'AllocationMethod'  = 'Dynamic' ## Dynamic or Static
    'DomainNameLabel'   = 'test-domain'
    'Location'          = $azureRegion
}
$publicIp = New-AzPublicIpAddress @newPublicIpParams
#endregion

#region Create the vNic and assign to the soon-to-be created VM
$newVNicParams = @{
    'Name'              = 'MyNic'
    'ResourceGroupName' = $resourceGoupName
    'Location'          = $azureRegion
}
$vNic = New-AzNetworkInterface @newVNicParams -SubnetId $vNet.Subnets[0].Id -PublicIpAddressId $publicIp.Id
#endregion

#region Config the OS settings
$newConfigParams = @{
    'VMName' = $vmName
    'VMSize' = 'Standard_A3'
}
$vmConfig = New-AzVMConfig @newConfigParams

$newVmOsParams = @{
    'Windows'          = $true
    'ComputerName'     = $vmName
    'Credential'       = (Get-Credential -Message 'Type the name and password of the local administrator account.')
    'ProvisionVMAgent' = $true
    'EnableAutoUpdate' = $true
}
$vm = Set-AzVMOperatingSystem @newVmOsParams -VM $vmConfig
#endregion

#region Define the OS disk image

## Find the OS offer
# $offer = Get-AzVMImageOffer -Location eastus -PublisherName MicrosoftWindowsServer | where { $_.Offer -eq 'WindowsServer' }

## Fimd the OS SKU
## Get-AzVMImageSku -Location 'east us' -PublisherName 'MIcrosoftWindowsServer' -Offer WindowsServer

$newSourceImageParams = @{
    'PublisherName' = 'MicrosoftWindowsServer'
    'Version'       = 'latest'
    'Skus'          = '2019-Datacenter'
}
 
$vm = Set-AzVMSourceImage @newSourceImageParams -VM $vm -Offer 'WindowsServer'
#endregion

#region Add the vNic created earlier
$vm = Add-AzVMNetworkInterface -VM $vm -Id $vNic.Id
#endregion

#region Create the OS disk
$osDiskName = 'myDisk'
$osDiskUri = $storageAccount.PrimaryEndpoints.Blob.ToString() + "vhds/" + $vmName + $osDiskName + ".vhd"
 
$newOsDiskParams = @{
    'Name'         = 'OSDisk'
    'CreateOption' = 'fromImage'
}
 
$vm = Set-AzVMOSDisk @newOsDiskParams -VM $vm -VhdUri $osDiskUri
#endregion

#region Bring all of the work together to create the $vm variable and create the VM
New-AzVM -VM $vm -ResourceGroupName $resourceGoupName -Location $azureRegion
#endregion

#region Stop the VM to not cost us
Stop-AzVM -ResourceGroupName $resourceGoupName -Name $vmName
#endregion

#region Clean up the resource group
Remove-AzResourceGroup -Name $resourceGoupName -Force
#endregion

# Success Message
Write-Output -InputObject "Virtual machine created successfully"
Read-Host -Prompt “Press Enter to exit”
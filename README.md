## Script Description
Azure Virtual Machine Deploy

With Microsoft Cloud, you can leverage the power of Microsoft Azure to create virtual machines (VMs) for whatever requiementment you may have.<br /><br />
UK-sovereign multi-cloud platform, those applications can work alongside other cloud platforms, such as Oracle, VMware and OpenStack, and benefit from native connectivity to non-cloud workloads in Crown Hosting and government community networks, including PSN, HSCN and RLI.<br /><br />
Before creating the virtual machine, it is necessary to create storage and networking resources for the the VM to use, this is included in the script to create a blob storage.


## Script Commands
####  Connect-AzAccount
To list all the Azure regions, first logion to Azure using the following command. (Note: If you are on macOS or Linux, run pwsh to start PowerShell).
Connect to Azure with an authenticated account for use with cmdlets from the Az PowerShell modules.<br />
https://docs.microsoft.com/en-us/powershell/module/az.accounts/connect-azaccount?view=azps-6.2.1

```
Connect-AzAccount
```

####  Get-AzLocation
To list all the available regions run the following command.<br />
https://docs.microsoft.com/en-us/powershell/module/az.resources/get-azlocation?view=azps-6.2.1
```
get-azlocation | select displayname,location
```

####  az vm image list
List the VM/VMSS images available in the Azure Marketplace.<br />
https://docs.microsoft.com/en-us/cli/azure/vm/image?view=azure-cli-latest#az_vm_image_list
```
az vm image list --output table

```

####  az vm list-sizes
List the available VM sizes in the UK West region.<br />
https://docs.microsoft.com/en-us/cli/azure/vm?view=azure-cli-latest#az_vm_list_sizes
```
az vm list-sizes --location ukwest --output table
```

## Prerequisites
Before you begin, ensure your PowerShell environment is set up, all "Input Variables" need to be set. (Like Below)


### Input Variables
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


## Deploy the virtual machine
Rich-click the Script.ps1 file and run with PowerShell and the script will run and prompt where required.


## Note!
The Scrip may stop at times, please let the script complete.<br />
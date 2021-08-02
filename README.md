## Script Description
Azure Virtual Machine Deploy

With UKCloud for Microsoft Azure, you can leverage the power of Microsoft Azure to create virtual machines (VMs) for your on-premises applications.<br /><br />
As UKCloud for Microsoft Azure is built on UKCloud's assured, UK-sovereign multi-cloud platform, those applications can work alongside other cloud platforms, such as Oracle, VMware and OpenStack, and benefit from native connectivity to non-cloud workloads in Crown Hosting and government community networks, including PSN, HSCN and RLI.<br /><br />
Before creating the virtual machine, it is necessary to create storage and networking resources for the the VM to use.


## Prerequisites
Before you begin, ensure your PowerShell environment is set up, all "Input Variables" need to be set. (Like Below)

### Input Variables
	$Location = "ukwest"<br />
	$RGName = "Insentrica-DevOps"<br />
	$HDDName = "INSStorage02082021".ToLower()<br />
	$SAName = "INSBlobStorage02082021".ToLower()<br />
	$SubnetName = "INSSubnet001"<br />
	$SubnetRange = "10.11.1.0/24"<br />
	$VNetName = "INSVirNetwork"<br />
	$VNetRange = "10.11.0.0/16"<br />
	$PublicIPName = "INSPublicIP"<br />
	$PublicDNS = "valikahnpubdns"<br />
	$NSGName = "INSNSG001"<br />
	$NSGNameRuleSSH = "SSHPortRule22"<br />
	$NSGNameRuleWeb = "WebPortRule80"<br />
	$NICName = "INSNIC001"<br />
	$AVSet = "INSAVSet"<br />
	$VMName = "INSAZIT001"<br />
	$VMImage = "UbuntuLTS"<br />
	$VMSize = "Standard_B1ls"<br />
	$DiskSku = "Standard_LRS"<br />
	$OSDiskSize = "120"  ##  In Gigabytes (GB)<br />
	$DataDiskSize = "250"  ##  In Gigabytes (GB)<br />


## Deploy the virtual machine
Rich-click the Azure.ps1 file and run with PowerShell and the script will run and prompt where required.


## Note!
The Scrip may stop at times, please let the script complete.<br />
At times it will be building a resource and deploying a VM or VNIC.
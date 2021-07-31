## Script Description
Azure Virtual Machine Deploy

With UKCloud for Microsoft Azure, you can leverage the power of Microsoft Azure to create virtual machines (VMs) for your on-premises applications.<br />
As UKCloud for Microsoft Azure is built on UKCloud's assured, UK-sovereign multi-cloud platform, those applications can work alongside other cloud platforms, such as Oracle, VMware and OpenStack, and benefit from native connectivity to non-cloud workloads in Crown Hosting and government community networks, including PSN, HSCN and RLI.<br />
Before creating the virtual machine, it is necessary to create storage and networking resources for the the VM to use.


## Prerequisites
Before you begin, ensure your PowerShell environment is set up, all "Input Variables" need to be set. (Like Below)

# Input Variables
$RGName = "MyResourceGroup"
$SAName = "MyStorageAccount46735022".ToLower()
$SubnetName = "MySubnet"
$SubnetRange = "192.168.1.0/24"
$VNetName = "MyVNetwork"
$VNetRange = "192.168.0.0/16"
$PublicIPName = "MyPublicIP"
$NSGName = "MyNSG"
$NICName = "MyNIC"
$ComputerName = "MyComputer"
$VMName = "MyVM"
$VMSize = "Standard_DS1_v2"
$VMImage = "*/CentOS/Skus/7.5"


## Deploy the virtual machine
Rich-click the Azure.ps1 file and run with PowerShell and the script will run and prompt where required.


## Note
The Scrip may stop at times, please let the script complete.
At times it will be building a resource and deploying a VM or VNIC.


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

Remove-AzResourceGroup -Name "myResourceGroup"
Remove-AzResourceGroup -Name "NetworkWatcherRG"

# Success Message
Write-Output -InputObject "Clean up complete"
Read-Host -Prompt “Press Enter to exit”
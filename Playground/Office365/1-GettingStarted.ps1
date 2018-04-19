# https://docs.microsoft.com/en-us/office365/enterprise/powershell/connect-to-office-365-powershell

# Microsoft Azure Active Directory
Install-Module MSOnline

# Connect to Azure Active Directory

$UserCredential = Get-Credential
Connect-MsolService -Credential $UserCredential



# Connect to all services in a single window
# https://docs.microsoft.com/en-us/office365/enterprise/powershell/connect-to-all-office-365-services-in-a-single-windows-powershell-window


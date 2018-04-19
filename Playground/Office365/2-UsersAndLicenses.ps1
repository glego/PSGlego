
# View information about licensing plans and the available licenses
# https://docs.microsoft.com/en-us/office365/enterprise/powershell/view-licenses-and-services-with-office-365-powershell
# https://docs.microsoft.com/en-us/powershell/module/msonline

cd "C:\Users\glenn\OneDrive\Projects\Github\psglego\Playground\Office365"

# Connect to Microsoft Online
Connect-MsolService

# Licenses
Get-MsolAccountSku

# Create New User
New-MsolUser -DisplayName "Fred Flintstone" `
    -FirstName "Fred" `
    -LastName "Flintstone" `
    -UserPrincipalName "fred.flintstone@glego.xyz" `
    -UsageLocation "DE" `
    -LicenseAssignment "glego:ENTERPRISEPACK"

# View User Licenses
Get-MsolUser -UserPrincipalName "fred.flintstone@glego.xyz" | 
    Select-Object -Property UserPrincipalName, DisplayName, Licenses
    
# Remove License
Set-MsolUserLicense -UserPrincipalName "fred.flintstone@glego.xyz" -RemoveLicenses "glego:ENTERPRISEPACK"

# Add License
Set-MsolUserLicense -UserPrincipalName "fred.flintstone@glego.xyz" -AddLicenses "glego:ENTERPRISEPACK"

# Remove User
Remove-MsolUser -UserPrincipalName "fred.flintstone@glego.xyz"



# User CSV Template
$Property= [ordered]@{
    DisplayName = "Fred Flintstone"
    FirstName = "Fred"
    LastName = "Flintstone"
    UserPrincipalName = "fred.flintstone@glego.xyz"
    UsageLocation = "DE"
    LicenseAssignment = "glego:ENTERPRISEPACK"
}

$MsolUserTemplate = New-Object -TypeName PSObject -Property $Property

$MsolUserTemplate | Export-Csv -Path ".\MsolUserTemplate.csv" -Encoding UTF8 -Delimiter "," 
Get-Content -Path ".\MsolUserTemplate.csv"

# Get all existing users
Get-MsolUser

# Import New Users
Get-Content -Path ".\MsolUserGlego.csv"
$MsolUser = Import-Csv -Path ".\MsolUserGlego.csv" -Encoding UTF8 -Delimiter ","
$MsolUser | Format-Table *

# Creating new users
$MsolUser | New-MsolUser | Tee-Object -Variable MsolUserCreated
$MsolUserCreated

# Export new users
$MsolUserCreated | Select-Object -Property UserPrincipalName, Password, DisplayName, isLicensed |Export-Csv -Path ".\MsolUserGlegoCreated.csv" -Encoding UTF8 -Delimiter "," 
Get-Content -Path ".\MsolUserGlegoCreated.csv"

# Remove users
$MsolUser | Remove-MsolUser -Force



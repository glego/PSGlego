# https://docs.microsoft.com/en-us/windows/device-security/auditing/create-a-basic-audit-policy-settings-for-an-event-category

Get-EventLog -LogName Security | Where-Object -Property EventID -eq 628

$AllLocalAccounts = Get-WmiObject -Class Win32_UserAccount

$ComputerName=$Env:COMPUTERNAME

Foreach($LocalAccount in $AllLocalAccounts)
{

    $rawPWAge = ([adsi]"WinNT://$computer/$($LocalAccount.Name),user").PasswordAge.Value
    $rawPWAge
}
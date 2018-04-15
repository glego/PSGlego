function Get-Ntp () {
    <#
    .SYNOPSIS
        Get the Ntp Server and Client Settings

    .DESCRIPTION
        Get the Ntp Server and Client Settings

    .EXAMPLE
        Get-Ntp

    .LINK
        https://github.com/glego/PSGlego/Glego.PSSystem

    #>
    $Property = @{
        'Config' =  Get-ItemProperty HKLM:\SYSTEM\CurrentControlSet\services\W32Time\Config | Select-Object * -ExcludeProperty PSPath, PSParentPath, PSChildName, PSDrive, PSProvider
        'NtpServer' = Get-ItemProperty HKLM:\SYSTEM\CurrentControlSet\services\W32Time\TimeProviders\NtpServer | Select-Object * -ExcludeProperty PSPath, PSParentPath, PSChildName, PSDrive, PSProvider
        'NtpClient' =  Get-ItemProperty HKLM:\SYSTEM\CurrentControlSet\services\W32Time\TimeProviders\NtpClient | Select-Object * -ExcludeProperty PSPath, PSParentPath, PSChildName, PSDrive, PSProvider
    }

    $Ntp = New-Object PSObject -Property $Property
    $Ntp.PSObject.TypeNames.Insert(0, "Glego.PSSystem.Ntp")
    Write-Output $Ntp

}
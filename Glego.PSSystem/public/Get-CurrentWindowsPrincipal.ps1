function Get-CurrentWindowsPrincipal () {
    <#
    .SYNOPSIS
        Get the windows principal identity

    .DESCRIPTION
        Get the windows principal identity

    .EXAMPLE
        Get-CurrentWindowsPrincipal

    .LINK
        https://github.com/glego/PSGlego/Glego.PSSystem

    #>
    [CmdletBinding()]
    [OutputType([Security.Principal.WindowsPrincipal])]

    $CurrentWindowsPrincipal = New-Object -TypeName Security.Principal.WindowsPrincipal -ArgumentList $([Security.Principal.WindowsIdentity]::GetCurrent())

    Write-Output $CurrentWindowsPrincipal
}
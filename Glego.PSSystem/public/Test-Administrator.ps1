function Test-Administrator () {
<#
    .SYNOPSIS
        Test if the current Windows identity has administrator rights.

    .DESCRIPTION
         Test if the current Windows identity has administrator rights.

    .EXAMPLE
        Test-Administrator

    .LINK
        https://github.com/glego/PSGlego/Glego.PSSystem

    .NOTES
        Used for backwards compatibility...
    #>
    
    $IsInRole = Test-WindowsPrincipalRole -WindowsPrincipal $(Get-CurrentWindowsPrincipal) -WindowsBuiltinRole Administrator

    Write-Output $IsInRole
}
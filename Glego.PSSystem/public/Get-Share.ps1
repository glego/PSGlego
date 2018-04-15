function Get-Share () {
    <#
    .SYNOPSIS
        Get the Share information

    .DESCRIPTION
        Get the Share information

        Gets share name and location

    .EXAMPLE
        Get-Share

    .LINK
        https://github.com/glego/PSGlego/Glego.PSSystem

    #>

    $Share = Get-WmiObjectFiltered -Class Win32_Share
    
    $Share.PSObject.TypeNames.Insert(0, "Glego.PSSystem.Share")
    Write-Output $Share
}
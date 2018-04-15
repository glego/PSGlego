function Get-OperatingSystem () {
    <#
    .SYNOPSIS
        Get the Operating System information

    .DESCRIPTION
        Get the Operating System information

        Gets OS Version and attributes

    .EXAMPLE
        Get-OperatingSystem

    .LINK
        https://github.com/glego/PSGlego/Glego.PSSystem

    #>

    $OperatingSystem = Get-WmiObjectFiltered -Class Win32_OperatingSystem 

    $OperatingSystem.PSObject.TypeNames.Insert(0, "Glego.PSSystem.OperatingSystem")
    Write-Output $OperatingSystem

}

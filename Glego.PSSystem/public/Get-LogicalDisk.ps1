function Get-LogicalDisk () {
    <#
    .SYNOPSIS
        Get the logical disk information

    .DESCRIPTION
        Get the logical disk information

        Gets all the volumes and disks attached to 
          the volumes.

    .EXAMPLE
        Get-LogicalDisk

    .LINK
        https://github.com/glego/PSGlego/Glego.PSSystem

    #>
    $LogicalDisk = Get-WmiObjectFiltered -Class Win32_LogicalDisk

    $LogicalDisk.PSObject.TypeNames.Insert(0, "Glego.PSSystem.LogicalDisk")
    Write-Output $LogicalDisk
}

function Get-ComputerSystem () {
    <#
    .SYNOPSIS
        Get the computer system information 

    .DESCRIPTION
        Get the computer system information 

        Gets the complete system information into 
          single PS Object.

    .EXAMPLE
        Get-ComputerSystemInfo

    .LINK
        https://github.com/glego/PSGlego/Glego.PSSystem

    #>
    $Property = [ordered]@{
        'OperatingSystem' = Get-OperatingSystem
        'Processor' = Get-Processor
        'LogicalDisk' = Get-LogicalDisk
        'Share' = Get-Share
        'Ntp' = Get-Ntp
        'Environment' = Get-Environment
        'PhysicalMemory' = Get-PhysicalMemory
        'SoundDevice' = Get-SoundDevice
        'VideoController' = Get-VideoController
    } 

    $ComputerSystem = New-Object PSObject -Property $Property
    $ComputerSystem.PSObject.TypeNames.Insert(0, "Glego.PSSystem.ComputerSystem")
    Write-Output $ComputerSystem

}

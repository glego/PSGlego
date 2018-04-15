function Get-VideoController () {
    <#
   .SYNOPSIS
       Get the system video controller information

   .DESCRIPTION
       Get the system video controller information

       Not required to provide any parameters
   .EXAMPLE
       Get-VideoController

   .LINK
       https://github.com/glego/PSGlego/Glego.PSSystem

   #>
   $Win32_VideoController = Get-WmiObjectFiltered -Class Win32_VideoController

   $VideoControllers = @()

   foreach ($Row in $Win32_VideoController) {
       $Property = [ordered]@{
           # Description
           'VideoControllerDeviceID' = $Row.DeviceID
           'VideoControllerDescription' = $Row.Description
           'VideoControllerDriverDate' = $Row.DriverDate
           'VideoControllerDriverVersion' = $Row.DriverVersion
           'VideoControllerInstalledDisplayDrivers' = $Row.InstalledDisplayDrivers
           'VideoControllerPNPDeviceID' = $Row.PNPDeviceID
           'VideoControllerVideoModeDescription' = $Row.VideoModeDescription
           'VideoControllerVideoProcessor' = $Row.VideoProcessor
       }
       
       $VideoController = New-Object PSObject -Property $Property
       $VideoController.PSObject.TypeNames.Insert(0, "Glego.PSSystem.VideoController")

       $VideoControllers += $VideoController
   }

   Write-Output $VideoControllers
}

 

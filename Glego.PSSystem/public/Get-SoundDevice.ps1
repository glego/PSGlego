function Get-SoundDevice () {
    <#
   .SYNOPSIS
       Get the system sound device information

   .DESCRIPTION
       Get the system sound device information

       Not required to provide any parameters
   .EXAMPLE
       Get-SoundDevice

   .LINK
       https://github.com/glego/PSGlego/Glego.PSSystem

   #>
   $Win32_SoundDevice = Get-WmiObjectFiltered -Class Win32_SoundDevice

   $SoundDevices = @()

   foreach ($Row in $Win32_SoundDevice) {
       $Property = [ordered]@{
           # Description
           'SoundDeviceDeviceID' = $Row.DeviceID
           'SoundDeviceDescription' = $Row.Description
           'SoundDeviceStatus' = $Row.Status
           'SoundDevicePNPDeviceID' = $Row.PNPDeviceID
           'SoundDeviceConfigManagerErrorCode' = $Row.ConfigManagerErrorCode
           'SoundDeviceManufacturer' = $Row.Manufacturer
        }
       
       $SoundDevice = New-Object PSObject -Property $Property
       $SoundDevice.PSObject.TypeNames.Insert(0, "Glego.PSSystem.SoundDevice")

       $SoundDevices += $SoundDevice
   }
   
   Write-Output $SoundDevices
}

 

function Get-PhysicalMemory () {
    <#
   .SYNOPSIS
       Get the system memory information

   .DESCRIPTION
       Get the system memory information

       Not required to provide any parameters
   .EXAMPLE
       Get-PhysicalMemory

   .LINK
       https://github.com/glego/PSGlego/Glego.PSSystem

   #>
   $Win32_PhysicalMemory = Get-WmiObjectFiltered -Class Win32_PhysicalMemory

   $PhysicalMemories = @()

   foreach ($Row in $Win32_PhysicalMemory) {
       $Property = [ordered]@{
           # Description
           'PhysicalMemoryBankLabel' = $Row.BankLabel
           'PhysicalMemoryAttributes' = $Row.Attributes
           'PhysicalMemoryCapacity' = $Row.Capacity
           'PhysicalMemorySpeed' = $Row.Speed
           'PhysicalMemoryConfiguredClockSpeed' = $Row.ConfiguredClockSpeed
           'PhysicalMemoryDeviceLocator' = $Row.DeviceLocator
           'PhysicalMemoryFormFactor' = $Row.FormFactor
           'PhysicalMemoryManufacturer' = $Row.Manufacturer
           'PhysicalMemoryMemoryType' = $Row.MemoryType
           'PhysicalMemoryPartNumber' = $Row.PartNumber
           'PhysicalMemorySerialNumber' = $Row.SerialNumber
       }
       
       $PhysicalMemory = New-Object PSObject -Property $Property
       $PhysicalMemory.PSObject.TypeNames.Insert(0, "Glego.PSSystem.PhysicalMemory")

       $PhysicalMemories += $PhysicalMemory
   }

   Write-Output $PhysicalMemories
}

 

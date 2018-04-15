function Get-Processor () {
     <#
    .SYNOPSIS
        Get the system processor information

    .DESCRIPTION
        Get the system processor information

        Not required to provide any parameters
    .EXAMPLE
        Get-Processor

    .LINK
        https://github.com/glego/PSGlego/Glego.PSSystem

    #>
    $Win32_Processor = Get-WmiObjectFiltered -Class Win32_Processor

    $Processors = @()

    foreach ($Row in $Win32_Processor) {
        $Property = [ordered]@{
            # Description
            'ProcessorProcessorId'                      = $Row.ProcessorId
            'ProcessorName'                             = $Row.Name
            'ProcessorManufacturer'                     = $Row.Manufacturer
            'ProcessorDeviceID'                         = $Row.DeviceID
            'ProcessorStatus'                           = $Row.Status
            'ProcessorStatusInfo'                       = $Row.StatusInfo
            'ProcessorSocketDesignation'                = $Row.SocketDesignation
            'ProcessorRevision'                         = $Row.Revision
            'ProcessorDescription'                      = $Row.Description
            'ProcessorL2CacheSize'                      = $Row.L2CacheSize
            'ProcessorL3CacheSize'                      = $Row.L3CacheSize
            'ProcessorMaxClockSpeed'                    = $Row.MaxClockSpeed
            'ProcessorNumberOfCores'                    = $Row.NumberOfCores
            'ProcessorNumberOfEnabledCore'              = $Row.NumberOfEnabledCore
            'ProcessorThreadCount'                      = $Row.ThreadCount
            'ProcessorVirtualizationFirmwareEnabled'    = $Row.VirtualizationFirmwareEnabled
            'ProcessorVMMonitorModeExtensions'          = $Row.VMMonitorModeExtensions
        }
        
        $Processor = New-Object PSObject -Property $Property
        $Processor.PSObject.TypeNames.Insert(0, "Glego.PSSystem.Processor")

        $Processors += $Processor
    }
    
    Write-Output $Processors
 }
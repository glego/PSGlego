function Get-ServiceExtended () {
    <#
    .SYNOPSIS
        Get the service extended information

    .DESCRIPTION
        Get the service extended information

        Not required to provide any parameters
    .EXAMPLE
        Get-ServiceExtended

    .LINK
        https://github.com/glego/PSGlego/Glego.PSSystem

    #>

    $Services = Get-Service

    $ExtendedServices = @()
    foreach ($Row in $Services) {
        $ServiceName = $Row.ServiceName
                            
        $ServiceProperties = Get-RegistryItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\$ServiceName"
        $ServiceParameters = Get-RegistryItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\$ServiceName\Parameters"

        $Property = [ordered]@{ 
            'ServiceExtendedName'                   = $Row.Name
            'ServiceExtendedServiceName'            = $Row.ServiceName
            'ServiceExtendedDisplayName'            = $Row.DisplayName
            'ServiceExtendedStatus'                 = $Row.Status
            'ServiceExtendedStartType'              = $Row.StartType
            'ServiceExtendedRequiredServices'       = $Row.RequiredServices
            'ServiceExtendedDependentServices'      = $Row.DependentServices
            'ServiceExtendedServicesDependedOn'     = $Row.ServicesDependedOn
            'ServiceExtendedCanPauseAndContinue'    = $Row.CanPauseAndContinue
            'ServiceExtendedCanShutdown'            = $Row.CanShutdown
            'ServiceExtendedCanStop'                = $Row.CanStop
            'ServiceExtendedProperties'             = $ServiceProperties
            'ServiceExtendedParameters'             = $ServiceParameters
        }
        
        $ExtendedService = New-Object PSObject -Property $Property
        $ExtendedService.PSObject.TypeNames.Insert(0, "Glego.PSSystem.ServiceExtended")
 
        $ExtendedServices += $ExtendedService
     }                       
                    
    Write-Output $ExtendedServices

}
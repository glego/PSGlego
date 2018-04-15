function Get-WmiObjectFiltered() {
    <#
    .SYNOPSIS
        Get all WMI Objects without the system management attributes

    .DESCRIPTION
        Get all WMI Objects without the system management attributes

    .PARAMETER Class
        Specify the name of a WMI class.

    .EXAMPLE
        Get-WmiObjectFiltered

    .LINK
        https://github.com/glego/PSGlego/Glego.PSSystem
    
    .LINK
        https://msdn.microsoft.com/en-us/library/aa394388(v=vs.85).aspx
    #>
    [CmdletBinding()]
    Param
    (
        [parameter(ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
        [string]$Class
    )

    $ExcludeProperty = @("__GENUS", "__CLASS", "__SUPERCLASS", "__DYNASTY", "__RELPATH",
        "__PROPERTY_COUNT", "__DERIVATION", "__SERVER", "__NAMESPACE", "__PATH", "Scope",
        "Path", "Options", "ClassPath", "Properties", "SystemProperties", "Qualifiers", "Site", "Container")

    $WmiObject = Get-WmiObject -Class $Class | 
        Select-Object -ExcludeProperty $ExcludeProperty -Property * 

    Write-Output $WmiObject
}
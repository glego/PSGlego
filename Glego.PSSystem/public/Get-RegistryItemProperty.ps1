function Get-RegistryItemProperty () {
    <#
    .SYNOPSIS
        Get the service extended information

    .DESCRIPTION
        Get the service extended information

        Not required to provide any parameters
    .EXAMPLE
        Get-RegistryItemProperty

    .LINK
        https://github.com/glego/PSGlego/Glego.PSSystem

    #>
    [CmdletBinding()]
        Param(
            [parameter(Mandatory = $true)]
            [string] $Path
        )
        
        if(( Test-Path $Path ) -eq $false) { Write-Verbose "Path '$Path' does not exist."} else {
    
            $RegistryItemProperty =  Get-ItemProperty $Path | Select-Object * -ExcludeProperty PSChildName, 
                                                                        PSDrive, 
                                                                        PSParentPath, 
                                                                        PSPath, 
                                                                        PSPRovider
            Write-Output $RegistryItemProperty
        }
    }
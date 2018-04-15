function Get-Environment () {
    <#
    .SYNOPSIS
        Get Environment Information

    .DESCRIPTION
        Get Environment Information

    .PARAMETER Class
        Specify the name of a WMI class.

        Examples: https://msdn.microsoft.com/en-us/library/aa394388(v=vs.85).aspx

    .EXAMPLE
        Get-Environment

        Will provide all the environment variables of the current process

    .EXAMPLE
        Get-Environment -Variable Path

        Will provide the Path variable of the current process

    .EXAMPLE 
        Get-Environment -Variable Path -Target Machine

        Will provide the Path variable of the Machine

    .LINK
        https://github.com/glego/PSGlego/Glego.PSSystem

    #>
    [CmdletBinding()]
    Param
    (
        [parameter(ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
        [string]$Variable,

        [parameter(ValueFromPipelineByPropertyName=$True)]
        [ValidateSet('Machine','User','Process')]
        [string]$Target="Process"
    )

    Write-Verbose "Variable: $Variable"
    Write-Verbose "Target: $Target"

    $EnvironmentVariables = @{}
    
    if ($Variable) {
        $EnvironmentVariables = @{
            $Variable = $([System.Environment]::GetEnvironmentVariable($Variable, [System.EnvironmentVariableTarget]::$Target))
        }
    }

    if (!$Variable) {
        $EnvironmentVariables = $([System.Environment]::GetEnvironmentVariables([System.EnvironmentVariableTarget]::$Target))
    }

    $Environment = New-Object PSObject -Property $EnvironmentVariables
    $Environment.PSObject.TypeNames.Insert(0, "Glego.PSSystem.Environment")
    Write-Output $Environment
}
function Set-Environment () {
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

    .LINK
        https://github.com/glego/PSGlego/Glego.PSSystem

    #>
    [CmdletBinding()]
    Param
    (
        [parameter(ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
        [string]$Variable="Path",

        [parameter(ValueFromPipelineByPropertyName=$True)]
        [ValidateSet('Machine','Process','User', 'All')]
        [string]$Target="Machine",

        [string]$Value="Machine",

        [switch]$Append=$false
    )

    # Add Python and Python Scripts to path
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)
    $PythonPath = "C:\Python27"
    $PythonScriptsPath = "C:\Python27\Scripts"

    if ($env:Path -notlike "*$PythonPath*") {
        $env:Path = $env:Path + ";$PythonPath"
    }

    if ($env:Path -notlike "*$PythonScriptsPath*") {
        $env:Path = $env:Path + ";$PythonScriptsPath"
    }

    # Save to machine path
    [Environment]::SetEnvironmentVariable( "Path", $env:Path, [System.EnvironmentVariableTarget]::Machine )

    # Check machine path
    [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)

}
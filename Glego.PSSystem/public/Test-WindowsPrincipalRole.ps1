function Test-WindowsPrincipalRole () {
    <#
    .SYNOPSIS
        Test if the Windows principal is in role

    .DESCRIPTION
        Test if the Windows principal is in role

    .PARAMETER WindowsPrincipal
        Provide the Windows principal

    .PARAMETER WindowsBuiltinRole
        Provide the Windows build-in role

    .EXAMPLE
        Test-WindowsPrincipalRole -WindowsPrincipal $(Get-CurrentWindowsPrincipal) -WindowsBuiltinRole Administrator

    .LINK
        https://github.com/glego/PSGlego/Glego.PSSystem

    #>
    [CmdletBinding()]
    [OutputType([bool])]
    Param
    (
        [Parameter(ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
        [System.Security.Principal.WindowsPrincipal]$WindowsPrincipal=$(Get-CurrentWindowsPrincipal),

        [Parameter()]
        [ValidateSet('AccountOperator','Administrator','BackupOperator','Guest',
            'PowerUser','PrintOperator','Replicator','SystemOperator','User')]
        [string]$WindowsBuiltinRole
    )

    $IsInRole = $WindowsPrincipal.IsInRole([Security.Principal.WindowsBuiltinRole]::$WindowsBuiltinRole)

    Write-Output $IsInRole
}
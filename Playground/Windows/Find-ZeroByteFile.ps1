Function Find-ZeroByteFile () {
<#
.Synopsis
   Find files with 0 bytes

.DESCRIPTION
   Find files with 0 bytes

.EXAMPLE
   Example of how to use this cmdlet

#>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [string]$Path
    )
    $ZeroBytesFiles = Get-ChildItem -Path $Path -Recurse -File | Where-Object Length -eq 0

    Write-Output $ZeroBytesFiles
}
<#
.SYNOPSIS
Gets the meta data from all the pictures and moves it to a new location.

.DESCRIPTION
Gets all pictures from a directory with all properties

.PARAMETER directory
The full path of a directory to find pictures.

.PARAMETER pictureExtensions
Picture extentions pictures.

#>
#Requires -Version 4
[CmdletBinding()]
Param(
    [Parameter(Mandatory=$false, Position=0)]
    [String[]]$FilePath = "E:\Pics\Organized",

    [Parameter(Mandatory=$false, Position=1)]
    [String[]]$Extension = @(".jpeg";".jpg"),

    [Parameter(Mandatory=$false, Position=1)]
    [String[]]$Destination = "E:\Pics\Organized"

)

$ErrorActionPreference = "Stop"

Write-Verbose "Loading script variables"

$thisScript 					= @{}
$thisScript.Name 				= $MyInvocation.MyCommand.Name
$thisScript.Definition 			= $MyInvocation.MyCommand.Definition
$thisScript.Directory 			= (Split-Path (Resolve-Path $MyInvocation.MyCommand.Definition) -Parent)
$thisScript.StartDir			= (Get-Location -PSProvider FileSystem).ProviderPath
$thisScript.WinOS				= (get-WmiObject -Class Win32_OperatingSystem | Select-Object -Property Caption).Caption
$thisScript.WinVer				= (get-WmiObject -Class Win32_OperatingSystem | Select-Object -Property Version).Version
$thisScript.PSVersion			= $PSVersionTable.PSVersion.Major
$thisScript.StartDate			= (Get-Date).ToString("o")


$JsonReadOutputFilePath = "$FilePath\PictureOrganizer$($thisScript.StartDate.Replace(":","."))_read.json"
$JsonMovedOutputFilePath = "$FilePath\PictureOrganizer$($thisScript.StartDate.Replace(":","."))_moved.json"

Write-Verbose "Dot sourceing scripts ...";
$PictureTools = ($thisScript.Directory + "\" + "PictureTools.ps1");
. $PictureTools;


Write-Verbose "Getting pictures from $FilePath";
$Images = @()

$Images = Get-FileMetaData -FilePath $FilePath -Extension $Extension -Verbose
$Images = Get-FileMetaDataPictureDate -FileMetaData $Images -Verbose

#output all to file
$Images | ConvertTo-Json -Compress | Out-File -FilePath $JsonReadOutputFilePath

$Images = Move-FileMetaDataPictureDate -Images $Images

$Images | ConvertTo-Json -Compress | Out-File -FilePath $JsonMovedOutputFilePath
Remove-Item -Path $JsonReadOutputFilePath -Force -ErrorAction Ignore

# export what to do

#$jsonImages = Get-Content -Path $JsonReadOutputFilePath | ConvertFrom-Json

#$jsonImages = Get-Content -Path $JsonMovedOutputFilePath | ConvertFrom-Json

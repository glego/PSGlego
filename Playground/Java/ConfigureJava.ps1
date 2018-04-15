<#
.SYNOPSIS
Configuration settings for SQLServer 2008R2 Express

.DESCRIPTION
Configuration settings for SQLServer 2008R2 Express

Developed for Powershell 2.0 or higher
#>
Write-Output "Setting variables..."
#
# -- Version History -    
#           XX.XXX         YYYYMMDD Author        Description
#           ------         -------- ------------- -----------------------------------------
$version = "01.000-BETA" # 20150428 Glenn         First Release
#

# Global variables
$thisScript 					= @{}
$thisScript.Name 				= $MyInvocation.MyCommand.Name
$thisScript.Definition 			= $MyInvocation.MyCommand.Definition
$thisScript.Directory 			= (Split-Path (Resolve-Path $MyInvocation.MyCommand.Definition) -Parent)
$thisScript.StartDir			= (Get-Location -PSProvider FileSystem).ProviderPath
$thisScript.WinOS				= (get-WmiObject -Class Win32_OperatingSystem | Select-Object -Property Caption).Caption
$thisScript.WinVer				= (get-WmiObject -Class Win32_OperatingSystem | Select-Object -Property Version).Version
$thisScript.PSVersion			= $PSVersionTable.PSVersion.Major


function main()
{
    # Get JavaHome path from HKLM JavaSoft registry
    $JavaHome 				= (Get-ItemProperty 'HKLM:\SOFTWARE\JavaSoft\Java Development Kit\1.6.0_45').JavaHome 
    
    # Check if not null
    If (!$JavaHome) {return "JavaHome path not found..."}
    
    # Get JavaHome binary directory
    $JavaHomeBin = ($JavaHome + '\bin\')
    
    # Set system environments for JAVA_HOME and PATH
    [Environment]::SetEnvironmentVariable("JAVA_HOME", $JavaHome, "Machine")
    add-env-path -AddedFolder $JavaHomeBin
}

Function Add-Env-Path ([String]$AddedFolder) {

    # Get the current search path 
    $OldPath=[System.Environment]::GetEnvironmentVariable("Path","Machine")

    # See if a new folder has been supplied.

    IF (!$AddedFolder)
    { Return "No Folder Supplied. $ENV:PATH Unchanged"}

    # See if the new folder exists on the file system.

    IF (!(TEST-PATH $AddedFolder))
    { Return "Folder Does not Exist, Cannot be added to $ENV:PATH" }

    # See if the new Folder is already in the path.

    IF ($OldPath | Select-String -SimpleMatch $AddedFolder)
    { Return 'Folder already within $ENV:PATH' }

    # Set the New Path

    $NewPath=$OldPath+$AddedFolder

    [Environment]::SetEnvironmentVariable("Path", $NewPath, "Machine")

    # Show our results back to the world
    # Reload Path
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine")

    Return $env:Path
}

try 
{
	Start-Transcript -Path ($thisScript.Directory + '\' + $thisScript.Name + '.log')
    main
    
}
catch
{
	$eMessage = $_.Exception.Message
	$eType = $_.Exception.GetType().Fullname
	$eLineNr = $_.InvocationInfo.ScriptLineNumber
	$eOffsetInLine = $_.InvocationInfo.OffsetInLine
	$eScriptName = $_.InvocationInfo.ScriptName
	Write-Host -ForegroundColor Red -Backgroundcolor black  ("Error: " + $eMessage + "`n" +
															$eScriptName + " Line: " + $eLineNr + " Char: " + $eOffsetInLine + "`n" +
															"Type: " +$eType)
	Start-Sleep -Seconds 30;
	break;
}
finally
{
    Write-Host 'Done...'
}
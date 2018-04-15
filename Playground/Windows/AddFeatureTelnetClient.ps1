<#
.SYNOPSIS
Unattended Installer for SQLServer 2008R2 Express

.DESCRIPTION
This install wrapper will check prerequisits and SQLServer 2008R2 Express


Developed for Powershell 2.0 or higher
#>
echo "Setting variables..."
#
# -- Version History -    
#           XX.XXX         YYYYMMDD Author        Description
#           ------         -------- ------------- -----------------------------------------
$version = "01.000-BETA" # 20150424 Glenn         First Release
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


function main(){
	$OSInfo = get-WmiObject -Class Win32_OperatingSystem | 
									Select-Object -Property Caption,
														OSArchitecture,
														CSDVersion,
														Version, 
														BuildNumber

	Write-Host 'Versions Detected:'
	$OSInfo.Caption
	
	switch -Wildcard ($OSInfo.Caption) {
		"*Windows 7*" {Install-TelnetClientWin7}
		"*Windows Server 2008 R2*" {Install-TelnetClientWin2k8}
		default  {Write-Host 'No compatible OS found...'}
	}
}

function Install-TelnetClientWin7(){

Write-Host 'Enable Telnet Feature Windows 7.'

$ps		= ($thisScript.Directory + '\AddFeatureTelnetClient-w7.bat')
$SP 	= (Start-Process -FilePath $ps -NoNewWindow -Wait)
Write-Host ('Process exited with code: ' + $SP.ExitCode)
	
}

function Install-TelnetClientWin2k8(){

# Starting SQL Installation
Write-Host 'Enable Telnet Feature Windows Server 2008 R2.'

$ps		= ($thisScript.Directory + '\AddFeatureTelnetClient-w2k8.bat')
$SP 	= (Start-Process -FilePath $ps -NoNewWindow -Wait)
Write-Host ('Process exited with code: ' + $SP.ExitCode)
	
}

try {
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
	sleep 30;
	break;
}
finally
{
    Write-Host 'Done...'
}
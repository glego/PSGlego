<#
.SYNOPSIS
Configuration settings for SQLServer 2008R2 Express

.DESCRIPTION
Configuration settings for SQLServer 2008R2 Express

Developed for Powershell 2.0 or higher
#>
echo "Setting variables..."
#
# -- Version History -    
#           XX.XXX         YYYYMMDD Author        Description
#           ------         -------- ------------- -----------------------------------------
$version = "01.000-BETA" # 20150424 Glenn         First Release
$version = "01.001-BETA" # 20150428 Glenn         Added Functions SetSQLLoginModeMixed, SetSQLInstanceMemory
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


function main(
    [string]$sqlServerTcpPort = '1433')
{
	# Check if SQLServer is Installed
	$SQLServerService = Get-Service | Where-Object {$_.Name -like '*MSSQL$SQLSAMESL'}
	Write-Host 'Versions Detected:'
	$SQLServerService | Out-String
	
	if (!$SQLServerService) 
    {
		Write-Host 'Configuration Skipped...'
		Write-Host 'SQL Server with instance SQLSAMESL not installed.'
		
	} ELSE 
    {
	    # Get SQL Service Instance Name
    	$sqlServerInstanceName			=   'SQLSAMESL'
		$sqlServiceInstance = ('MSSQL$' + $sqlServerInstanceName)
        $localComputerName = (get-item env:\computername).Value
        
        # Create SQL Server filter string to query wmi TCP Port settings
		$sqlServerFilterString = "InstanceName='$sqlServerInstanceName' AND IpAddressName='IPAll' AND ProtocolName='Tcp' AND PropertyName='TcpPort'"
		$sqlServerInfo = get-wmiobject ServerNetworkProtocolProperty -namespace "root\Microsoft\SqlServer\ComputerManagement10" -filter $sqlServerFilterString | 
						Select-Object -Property InstanceName,
											PropertyName,
											PropertyStrVal		
		
        # Configure SQL Server TCP IP Port
        if ($sqlServerInfo.PropertyStrVal  -eq $sqlServerTcpPort) {
        Write-Host ("SQLServer already configured on TcpPort: " + $sqlServerTcpPort)
        } ELSE {
    							  
    		$sqlServerFilterString = "InstanceName='$sqlServerInstanceName' AND IpAddressName='IPAll' AND ProtocolName='Tcp' AND PropertyName='TcpPort'"
    		$sqlServerInstanceList = get-wmiobject ServerNetworkProtocolProperty -namespace "root\Microsoft\SqlServer\ComputerManagement10" -filter $sqlServerFilterString
    		 foreach ($sqlServerInstance in $sqlServerInstanceList) {
    			if ($sqlServerInstance -ne $null) {
    				$sqlServerInstance.SetStringValue($sqlServerTcpPort	)
    			}
    		 }

		}
        
        # Enable TCP IP on Instance
        SetSQLTcpIpEnabled -sqlServerName $localComputerName -sqlServerInstance $sqlServerInstanceName
		 
        # Restart SQL Server Instance
        Restart-Service -Name $sqlServiceInstance -Force
        
        # Configure Login and Instance Memory
        $sqlServerName = ("(local)" + "," + $sqlServerTcpPort)
        SetSQLLoginModeMixed -sqlServerName $sqlServerName
        SetSQLInstanceMemory -sqlServerName $sqlServerName -minMem 0 -maxMem 1024
       	CreateNewLogin -sqlServerName $sqlServerName -sqlLoginName 'user' -sqlLoginPassword 'pass'
        
        # Restart SQL Server Instance
        Restart-Service -Name $sqlServiceInstance -Force
		
	}
	
}

function CreateNewLogin(
    [string]$sqlServerName,
    [string]$sqlLoginName,
    [string]$sqlLoginPassword)
{
    
    [reflection.assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo") | Out-Null
    $srv = new-object -TypeName Microsoft.SQLServer.Management.Smo.Server -ArgumentList $sqlServerName
    
    # Check if login exists
    if ($srv.Logins.Contains($sqlLoginName))  
    {   
        Write-Host ('Login already exists with name: ' + $sqlLoginName)
       
    } ELSE {
        # Create new login
        Write-Host ($sqlServerName + '/' + $sqlLoginName + '/' + $sqlLoginPassword)
        $login = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Login -ArgumentList $srv, $sqlLoginName
        $login.LoginType = [Microsoft.SqlServer.Management.Smo.LoginType]::SqlLogin
        $login.PasswordExpirationEnabled = $false
	    $login.PasswordPolicyEnforced = $false
        $login.Create($sqlLoginPassword)
        
	    $srv.Logins[$sqlLoginName].AddToRole('sysadmin')
        
        Write-Host("Login $loginName created successfully.")
        
    }
    
}
function SetSQLTcpIpEnabled(
    [string]$sqlServerName,
    [string]$sqlServerInstance) 
{
    # From: http://technet.microsoft.com/en-us/library/dd206997.aspx
    [reflection.assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo") | Out-Null
    [reflection.assembly]::LoadWithPartialName("Microsoft.SqlServer.SqlWmiManagement") | Out-Null
    
    $smo = 'Microsoft.SqlServer.Management.Smo.'
    $wmi = new-object ($smo + 'Wmi.ManagedComputer').

    # List the object properties, including the instance names.
    $Wmi

    # Enable the TCP protocol on the default instance.
    $uri = "ManagedComputer[@Name='"+$sqlServerName+"']/ ServerInstance[@Name='"+$sqlServerInstance+"']/ServerProtocol[@Name='Tcp']"
    $Tcp = $wmi.GetSmoObject($uri)
    $Tcp.IsEnabled = $true
    $Tcp.Alter()
    $Tcp

}

function SetSQLLoginModeMixed(
    [string]$sqlServerName = ".") 
{

  
    [reflection.assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo") | Out-Null
    $srv = new-object ('Microsoft.SQLServer.Management.Smo.Server') $sqlServerName
    
    # Default connection via Windows Authentication
    # $true = Windows Authentication
    # $false = SQL Authentication
    # $sqlServer.ConnectionContext.set_Login("user"); 
    # $sqlServer.ConnectionContext.set_Password("pass")  
    $srv.ConnectionContext.LoginSecure = $true
    
    # Login Mode
    # Integrated - Windows Authentication
    # Mixed - Mixed Mode
    # Normal - SQL Server Only Authentication
    # Unknown - Undefined (and no, I haven't tried it.)
    #
    $srv.Settings.LoginMode = "Mixed"
    $srv.Settings.Alter()
}

function SetSQLInstanceMemory ( 
    [string]$sqlServerName = ".", 
    [int]$maxMem = $null, 
    [int]$minMem = $null) 
{
    Write-Host 'Setting SQL Instance Memory'
    Write-Host ('sqlServerName: ' + $sqlServerName)
    Write-Host ('maxMem: ' + $maxMem)
    Write-Host ('minMem: ' + $minMem)
    
    [reflection.assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo") | Out-Null
    $srv = new-object ('Microsoft.SQLServer.Management.Smo.Server') $sqlServerName
    
    
    # Default connection via Windows Authentication
    # $true = Windows Authentication
    # $false = SQL Authentication
    # $sqlServer.ConnectionContext.set_Login("user"); 
    # $sqlServer.ConnectionContext.set_Password("pass")  
    
    $srv.ConnectionContext.LoginSecure = $true

    $srv.Configuration.MaxServerMemory.ConfigValue = $maxMem
    $srv.Configuration.MinServerMemory.ConfigValue = $minMem
    
    $srv.Configuration.Alter()
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
	sleep 30;
	break;
}
finally
{
    Write-Host 'Done...'
}
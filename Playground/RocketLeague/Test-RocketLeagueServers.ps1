$MyDocuments = [environment]::getfolderpath("mydocuments")
$RocketLeagueRelativePath = "My Games\Rocket League\TAGame\Logs\Launch.log"
$RocketLeagueFilePath = Join-Path -Path $MyDocuments -ChildPath $RocketLeagueRelativePath
if (!(Test-Path $RocketLeagueFilePath)) { Write-Error "Could not find Rocket League log file '$RocketLeagueFilePath'" }

$Servers = @()

$a = Get-Content $RocketLeagueFilePath | 
    Select-String -Pattern ".*CheckReservation.*ip(\d+-\d+-\d+-\d+).* (.*) .*" | 
    ForEach-Object {

        $ServerIP = $_.Matches.Groups[1].Value
        $ServerIP = $ServerIP.replace("-",".")
        $ServerName= $_.Matches.Groups[2].Value

        $Server = @{}
        $Server.Add("IP",$ServerIP)
        $Server.Add("Name",$ServerName)
        $Servers += [pscustomobject]$Server
    }

foreach ($Server in $Servers) {
    $ServerConnection = Test-Connection -ComputerName $Server.IP | Measure-Object -Property ResponseTime -Average
    
    Write-Output "Server $($Server.Name) ($($Server.IP)) has an average ping of $($ServerConnection.Average) ms / $($ServerConnection.Count) pings"
}
# Uninstall OneDrive

Get-Process "OneDrive" | Stop-Process -Force
if (Test-Path -Path "$env:SystemRoot\System32\OneDriveSetup.exe") {
    Start-Process -FilePath "$env:SystemRoot\System32\OneDriveSetup.exe" -ArgumentList "/uninstall" -Wait
} elseif (Test-Path -Path "$env:SystemRoot\SysWOW64\OneDriveSetup.exe") {
    Start-Process -FilePath "$env:SystemRoot\SysWOW64\OneDriveSetup.exe" -ArgumentList "/uninstall" -Wait
} else {
    Write-Error "Could not find OneDriveSetup file" -ErrorAction Stop
}

# Unlock onedrive dll files and remove onedrive folder
Get-Process "explorer" | Stop-Process -Force 
Get-Process "filecoauth" | Stop-Process -Force

Remove-Item "$env:LOCALAPPDATA\Microsoft\OneDrive\" -Force -Recurse

# Install OneDrive

# $url = "https://oneclient.sfx.ms/Win/Prod/18.025.0204.0009/OneDriveSetup.exe"
$url = "https://go.microsoft.com/fwlink/p/?LinkId=248256" # latest
$setup = "OneDriveSetup.exe"
Invoke-WebRequest -Uri $url -OutFile $setup

& ".\$setup"
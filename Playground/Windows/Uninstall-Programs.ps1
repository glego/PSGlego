$Software = Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall, 
    HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall | 
    Get-ItemProperty | 
    Where-Object {$_.DisplayName -match "Docker" } | 
    Select-Object -Property DisplayName, UninstallString

if ($Software.UninstallString -match "msiexec.exe") {
    $Uninstall = $Software.UninstallString -replace "msiexec.exe /i", "msiexec.exe /x" `
                                            -replace "{", " `"{" `
                                            -replace "}", "}`" /qr"
} else {
    $Uninstall = $Software.UninstallString
}
Write-Host "$Uninstall"
Invoke-Expression -Command "& $Uninstall"
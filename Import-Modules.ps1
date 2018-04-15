
$Modules = Get-ChildItem -Path "Glego*"

foreach ($Module in $Modules) {
    Try
    {
        Import-Module $Module.FullName -Force
    }
    Catch
    {
        Write-Error -Message "Failed to import function $($Module.FullName): $_"
    }
}
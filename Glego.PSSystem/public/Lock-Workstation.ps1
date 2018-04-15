Function Lock-Workstation {
     <#
    .SYNOPSIS
        Lock the current workstation
    .DESCRIPTION
        Lock the current workstation

        Not required to provide any parameters.
    .EXAMPLE
        Lock-Workstation
    .LINK
        https://github.com/glego/PSGlego/Glego.PSSystem
    #>
    $MethodDefinition = @"
        [DllImport("user32.dll")] 
        public static extern bool LockWorkStation(); 
"@
    $LockWorkStation = Add-Type -memberDefinition $MethodDefinition -name "Win32LockWorkStation" -namespace Win32Functions -passthru 
    $LockWorkStation::LockWorkStation() | Out-Null 
}
<#
    Dependency Walker is a free utility that scans any 
    32-bit or 64-bit Windows module (exe, dll, ocx, sys, etc.)

    For each module found, it lists all the functions that are exported by that module, 
    and which of those functions are actually being called by other modules. 
    Another view displays the minimum set of required files, along with detailed 
    information about each file including a full path to the file, base address,
    version numbers, machine type, debug information, and more.

    Links:
    * http://www.dependencywalker.com/
#>

Invoke-WebRequest -Uri "http://www.dependencywalker.com/depends22_x64.zip" -OutFile "Depends_x64.zip"
Expand-Archive -Path "./Depends_x64.zip" -OutputPath "./" -ShowProgress
./depends /?

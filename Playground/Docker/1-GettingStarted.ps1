
<# 
    Docker for Windows - Getting Started

    Windows Nano Server
        * Headless Server Operating System and requires to be managed remotely (No terminal, gui, ect...) 
        * Use case: App Containers, Scale Out File Server (SOFS)
        * Fixed Roles (cannot have multiple roles)
        * Limited CLR (Common Language Runtime) limit .NET framework
            * CoreCLR / .NET Core
            * ASP.NET 5
        * No support for WOW64 (32bit apps), MSI, .NET Framework 

    Windows Server Core
        * Fully supported CLR (Common Language Runtime)
        * Supports all and multiple roles
        * Supports WOW64, MSI, ect..
        * No client stack in container

    License:
        * For developement Docker for Windows is Licensed from the host level, in my particular case Windows 10.
        * For production Docker for Windows is Licensed by the host Windows Server 2016 License.

    Links:
        * https://hub.docker.com/u/microsoft/
#>

docker run -d --name core microsoft/windowsservercore:10.0.14393.2248 ping 127.0.0.1 /t # Run Server Core in the background
docker exec -ti core powershell # Start PowerShell within the new Server Core

docker run -ti --name nano microsoft/nanoserver:10.0.14393.2248
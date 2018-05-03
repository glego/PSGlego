#!/bin/bash
set -e # Error Sensitive Mode, which will break out of the script in case of unexpected errors.

# PSCore on ARM https://docs.microsoft.com/en-us/powershell/scripting/setup/powershell-core-on-arm?view=powershell-6
# PSCore Raspbian https://docs.microsoft.com/en-us/powershell/scripting/setup/installing-powershell-core-on-linux?view=powershell-6#raspbian

# Install prerequisites
sudo apt-get install libunwind8

# Grab the latest tar.gz
wget https://github.com/PowerShell/PowerShell/releases/download/v6.0.2/powershell-6.0.2-linux-arm32.tar.gz

# Make folder to put powershell
mkdir ~/powershell

# Unpack the tar.gz file
tar -xvf ./powershell-6.0.2-linux-arm32.tar.gz -C ~/powershell

# Start PowerShell
~/powershell/pwsh

# Start PowerShell from bash with sudo to create a symbolic link
sudo ~/powershell/pwsh -c New-Item -ItemType SymbolicLink -Path "/usr/bin/pwsh" -Target "\$PSHOME/pwsh" -Force

# alternatively you can run following to create a symbolic link
# sudo ln -s ~/powershell/pwsh /usr/bin/pwsh

# Now to start PowerShell you can just run "pwsh"
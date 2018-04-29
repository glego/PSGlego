# Make sure to start PowerShell as Administrator

# Install Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

choco feature enable -n allowGlobalConfirmation
choco feature disable -n allowGlobalConfirmation

# Packages
choco install 7zip.install

choco install cutepdf
choco install pdfcreator
choco install teamviewer
choco install dropbox
choco install googledrive
choco install autohotkey.install

choco install audacity
choco install teracopy # Pro License

choco install notepadplusplus.install
choco install visualstudiocode
choco install boostnote

choco install git
choco install python2
choco install phantomjs

choco install crystaldiskinfo
choco install sysinternals
choco install windirstat
choco install ccleaner

choco install googlechrome
choco install firefox
choco install chromium

choco install fscapture

choco install inkscape
choco install gimp
choco install ghostscript.app

choco install vlc 
choco install eac
choco install youtube-dl
choco install ffmpeg
choco install avidemux
choco install makemkv # Beta License Key: https://www.makemkv.com/forum2/viewtopic.php?f=5&t=1053

choco install poweriso
choco install imgburn

choco install docker
choco install winlogbeat 

choco install sql-server-management-studio
choco install sql-server-express         # SQL Server Express Latest 
choco install mssqlserver2014express     # SQL Server Express 2014
choco install mssqlserver2012express     # SQL Server Express 2012

choco install pgadmin3
choco install postgresql     # PostgreSQL Latest
choco install postgresql93   # PostgreSQL 9.3

choco install mobaxterm # Have a professional license
choco install innosetup
choco install windows10-media-creation-tool

choco install wireshark
choco install microsoft-message-analyzer
choco install nmap

choco install etcher

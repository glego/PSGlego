
# Install chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Accept all licenses
choco feature enable -n allowGlobalConfirmation

# Install git and openssh
choco install git
choco install openssh

# Disable Global Confirmation
choco feature disable -n allowGlobalConfirmation

# Create new key
# https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"

# Print out Public SSH Key
cat "$home\.ssh\id_rsa.pub"
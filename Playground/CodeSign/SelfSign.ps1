#
# Sign a PowerShell file with a Self Signed Certificate Authority
#

## Open Local Machine Certificate Management Console
# certlm.msc

## Open Current User Certificate Management Console
# certmgr.msc

## Links: 
#    - https://docs.microsoft.com/en-us/powershell/module/pkiclient/new-selfsignedcertificate?view=win10-ps
#    - https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.security/providers/get-childitem-for-certificate?view=powershell-6
#    - https://infiniteloop.io/powershell-self-signed-certificate-via-self-signed-root-ca/
#    - http://woshub.com/how-to-create-self-signed-certificate-with-powershell/
#    - https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2012-R2-and-2012/dn265983(v=ws.11)

$ErrorActionPreference = "Stop"

$CertificateAuthorityName = "Glego CA Test"
$CodeSignName = "CodeSign Glenn"
$CertificateStore = "Cert:\CurrentUser"
$MyCertificatePath = Join-Path -Path $CertificateStore -ChildPath "My"
$RootCertificatePath = Join-Path -Path $CertificateStore -ChildPath "Root"

# Create root certificate
$Parameters = @{
    DnsName = "$CertificateAuthorityName"
    KeyLength = 2048
    KeyAlgorithm = "RSA"
    HashAlgorithm = "SHA256"
    KeyExportPolicy = "Exportable"
    NotAfter = (Get-Date).AddYears(5)           # Create Certificate  5 Years
    CertStoreLocation = "$MyCertificatePath"
    KeyUsage = @("CertSign","CRLSign", "DigitalSignature")
    TextExtension="2.5.29.37={text}1.3.6.1.5.5.7.3.3" # Code Signing
}

$RootCA = New-SelfSignedCertificate @Parameters

$Parameters = @{
    Subject = "$CodeSignName"
    Type = "CodeSigningCert"
    CertStoreLocation = "$MyCertificatePath"
    Signer = $RootCA
}

$CodeSignCertificate = New-SelfSignedCertificate @Parameters

# Install the Self Signed Certificate as Trusted Root CA
Move-Item -Path (Join-Path -Path $MyCertificatePath -ChildPath $RootCA.Thumbprint) -Destination $RootCertificatePath 
$RootCA = Get-ChildItem -Path (Join-Path -Path $RootCertificatePath -ChildPath $RootCA.Thumbprint) 

# Prepare file
$FilePath = Join-Path -Path $PSScriptRoot -ChildPath "samples\Hello_Unsigned.ps1"
$SignedFilePath = Join-Path -Path $PSScriptRoot -ChildPath "samples\Hello_SelfSign.ps1"
Copy-Item -Path $FilePath -Destination $SignedFilePath -Force

# Remove certificate from the store (test)
# remove-item "$MyCertificatePath\$($Certificate.Thumbprint)"

# Sign code
Set-AuthenticodeSignature -Cert $CodeSignCertificate -TimeStampServer http://timestamp.verisign.com/scripts/timestamp.dll -FilePath $SignedFilePath

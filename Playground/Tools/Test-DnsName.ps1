function Test-DnsName (){
    <#
    .SYNOPSIS
        Test different DNS types for discrepancies

    .DESCRIPTION
        Test different DNS types for discrepancies

    .PARAMETER DomainName
        Provide the Second Level Domain (SLD) to test the DNS records e.g. example.com.

    .EXAMPLE
        Test-DnsName -DomainName "example.com"

    .LINK
        https://github.com/glego/PSGlego/PSUtility

    .NOTES
        Related articles
        * https://sid-500.com/2017/07/10/the-new-nslookup-resolve-dnsname/
        * https://github.com/mmessano/PowerShell/blob/master/Test-EnterpriseDnsHealth.ps1
        * http://www.peerwisdom.org/2013/05/15/dns-understanding-the-soa-record/
        * https://en.wikipedia.org/wiki/SOA_record
        * https://serverfault.com/questions/576670/what-is-the-syntax-of-email-address-with-a-dot-behind-it-in-dns-zone-file-soa
        * https://mxtoolbox.com/NetworkTools.aspx
    #>
    [CmdletBinding()]
    Param
    (
        [ValidateNotNull()]
        [parameter(Mandatory=$true,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
        [string]$DomainName
    )

    # Let's start with a Clean DNS Cache
    Clear-DnsClientCache

    # All the results will be stored in this hash table
    $DnsResult = [ordered]@{}

    Write-Verbose "Resolving DNS Type State of Authority (SOA) for '$DomainName'"
    $DnsRecord_SOA = Resolve-DnsName -Name $DomainName -Type SOA 
    $DnsResult.Add("SOA", (ConvertTo-Hashtable -InputObject $DnsRecord_SOA))
    $DnsResult.SOA.Add("TimeToZoneRefreshString", (ConvertTo-TimeSpanString -TimeSpan (New-TimeSpan -Seconds $DnsResult.SOA.TimeToZoneRefresh)))
    $DnsResult.SOA.Add("TimeToZoneFailureRetryString", (ConvertTo-TimeSpanString -TimeSpan (New-TimeSpan -Seconds $DnsResult.SOA.TimeToZoneFailureRetry)))
    $DnsResult.SOA.Add("TimeToExpirationString", (ConvertTo-TimeSpanString -TimeSpan (New-TimeSpan -Seconds $DnsResult.SOA.TimeToExpiration)))
    $DnsResult.SOA.Add("DefaultTTLString", (ConvertTo-TimeSpanString -TimeSpan (New-TimeSpan -Seconds $DnsResult.SOA.DefaultTTL)))
    $DnsResult.SOA.Add("TTLString", (ConvertTo-TimeSpanString -TimeSpan (New-TimeSpan -Seconds $DnsResult.SOA.TTL)))
    $DnsResult.SOA.Add("AdministratorEmail", (ConvertTo-DnsSoaEmailAddress -DnsSoaAdministator $DnsResult.SOA.Administrator))

    Write-Verbose "Resolving DNS Type A for '$DomainName'"
    $DnsRecord_A       = Resolve-DnsName -Name $DomainName -Type A
    $DnsResult.Add("A", (ConvertTo-Hashtable -InputObject $DnsRecord_A))
    $DnsResult.A.Add("TTLString", (ConvertTo-TimeSpanString -TimeSpan (New-TimeSpan -Seconds $DnsResult.A.TTL)))

    Write-Verbose "Resolving DNS Type AAAA for '$DomainName'"
    $DnsRecord_AAAA       = Resolve-DnsName -Name $DomainName -Type AAAA
    $DnsResult.Add("AAAA", (ConvertTo-Hashtable -InputObject $DnsRecord_AAAA))
    $DnsResult.AAAA.Add("TTLString", (ConvertTo-TimeSpanString -TimeSpan (New-TimeSpan -Seconds $DnsResult.AAAA.TTL)))

    Write-Verbose "Resolving DNS Type AAAA for '$DomainName'"
    $DnsRecord_MX      = Resolve-DnsName -Name $DomainName -Type MX
    $DnsResult.Add("MX", (ConvertTo-Hashtable -InputObject $DnsRecord_MX))

    Write-Output $DnsResult
    <#
    # Get the IPV4 and IPV6 addresses
    Write-Verbose "Resolving Type A and AAAA for '$DomainName'"
    $DnsRecord_A       = Resolve-DnsName -Name $DomainName -Type A
    Resolve-DnsName -Name ($_.IPAddress) -Type PTR
    $DnsRecord_AAAA    = Resolve-DnsName -Name $DomainName -Type AAAA

    

    # Get the mail exchange addresses
    Write-Verbose "Resolving Type MX for '$DomainName'"
    $DnsRecord_MX      = Resolve-DnsName -Name $DomainName -Type MX
    $DnsRecord_MX_IP   = Resolve-DnsName -Name $DnsRecord_MX.NameExchange -Type A

   


    # Resolve-DnsName -Name $DomainName -Type NS -DnsOnly
    # Resolve-DnsName -Name $DomainName -Type MX
    # Resolve-DnsName -Name $DomainName -Type TXT
    # Resolve-DnsName -Name $DomainName -Type SOA
    # Resolve-DnsName -Name $DomainName -Type PTR
    # Resolve-DnsName -Name $DomainName -Type CNAME
    # Resolve-DnsName -Name $DomainName -Type PTR
    #>
}

Function Test-DnsNamePtr () {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [String]$IPAddress,
        [String]$DomainName
    )

    $DnsRecord_PTR = Resolve-DnsName -Name ($IPAddress) -Type PTR



}

Function Test-DnsRecordTestPtr (){
    [CmdletBinding()]
    [OutputType([Glego.PSUtility.DnsRecordTestPtr])]
    Param(
        [Parameter(Mandatory=$true)]
        [Microsoft.DnsClient.Commands.DnsRecord_A]
        $DnsRecord
    )
    
    $DnsRecordTestPtrs = @()

    $DnsRecord | ForEach-Object {
        $DomainName = $_.Name
        $DomainIPAddress = $_.IPAddress
    
        $DnsRecord_PTR = Resolve-DnsName -Name ($_.IPAddress) -Type PTR
    
        if ($DnsRecord_PTR.Count -gt 0) {
            $PtrDomainName = $DnsRecord_PTR[0].NameHost
            if ($PtrDomainName -like "*$DomainName") {
                $PtrMatch = $true
            } else {
                $PtrMatch = $false
            }
        } else {
            $PtrMatch = $false
        }
    
       $Parameter = [Ordered]@{
            DomainName = $DomainName
            DomainIP = $DomainIPAddress
            PtrMatch = $PtrMatch
            PtrDomainName = $PtrDomainName
        }
    
        $DnsRecordTestPtr = New-Object -TypeName PSObject -Property $Parameter
        $DnsRecordTestPtr.PSObject.TypeNames.Insert(0, "Glego.PSUtility.DnsRecordTestPtr")
    
        $DnsRecordTestPtrs += $DnsRecordTestPtr
        
    }

    Write-Output $DnsRecordTestPtrs
}


function ConvertTo-TimeSpanString
{
    <#
    .Synopsis
       Convert TimeSpan to String

    .DESCRIPTION
       Convert TimeSpan to String

    .EXAMPLE
       ConvertTo-TimeSpanString -TimeSpan (New-TimeSpan -Seconds 604800)
    .EXAMPLE
       Another example of how to use this cmdlet
    #>
    [CmdletBinding()]
    [Alias()]
    [OutputType([string])]
    Param
    (
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [System.TimeSpan]$TimeSpan
    )

    $Result = ""

    if ($TimeSpan.Days -gt 0) {
        $Result += "$($TimeSpan.Days) Day"
        if ($TimeSpan.Days -gt 1) { $Result += "s" }
    } 

    if ($TimeSpan.Hours -gt 0) {
        if ($Result) {$Result += ", "}
        $Result += "$($TimeSpan.Hours) Hour"
        if ($TimeSpan.Hours -gt 1) { $Result += "s" }
    }

    if ($TimeSpan.Minutes -gt 0) {
        if ($Result) {$Result += ", "}
        $Result += "$($TimeSpan.Minutes) Minute"
        if ($TimeSpan.Minutes -gt 1) { $Result += "s" }
    }

    if ($TimeSpan.Seconds -gt 0) {
        if ($Result) {$Result += ", "}
        $Result += "$($TimeSpan.Seconds) Second"
        if ($TimeSpan.Seconds -gt 1) { $Result += "s" }
    }

    if ($TimeSpan.Milliseconds -gt 0) {
        if ($Result) {$Result += ", "}
        $Result += "$($TimeSpan.Milliseconds) Millisecond"
        if ($TimeSpan.Milliseconds -gt 1) { $Result += "s" }
    }

    Write-Output $Result
}

function ConvertTo-Hashtable () {
    <#
   .Synopsis
      Convert Object Properties into a Hashtable

   .DESCRIPTION
      Convert Object Properties into a Hashtable

   .EXAMPLE
      ConvertTo-Hashtable (Get-Process | Select-Object -First 1 -Property ProcessName, Id)
   .EXAMPLE
      Another example of how to use this cmdlet
   #>
   [CmdletBinding()]
   [Alias()]
   [OutputType([System.Collections.Hashtable])]
   Param
   (
       [Parameter(Mandatory=$true,
                  ValueFromPipelineByPropertyName=$true,
                  Position=0)]
       [Object]$InputObject
   )

   $HashTables = @()
   foreach ($Object in $InputObject) {
       $HashTable = [ordered]@{}

       $Object.PSObject.Properties |
       ForEach-Object {
           $HashTable.Add($_.Name, $_.Value)
       }

       $HashTables += $HashTable
   }
   Write-Output $HashTables
}

function ConvertTo-DnsSoaEmailAddress () {
    <#
   .Synopsis
      Convert DNS SOA Administrator to an E-Mail Address

   .DESCRIPTION
      Convert DNS SOA Administrator to an E-Mail Address

   .EXAMPLE
      ConvertTo-DnsSoaEmailAddress (Resolve-DnsName -Name google.com -Type SOA).Administrator
   #>
   [CmdletBinding()]
   [Alias()]
   [OutputType([String])]
   Param
   (
       [Parameter(Mandatory=$true,
                  ValueFromPipelineByPropertyName=$true,
                  Position=0)]
       [String]$DnsSoaAdministator
   )

    [regex]$Pattern = "\."
    $Result = $Pattern.replace($DnsSoaAdministator, "@", 1) 

    Write-Output $Result 
}

$ErrorActionPreference = "Stop"





Function Change-NetworkAddress{ 
    Param( 
        [ValidateSet("Static","DHCP")] 
        [String] $Addressing,
        [String] $AdapterName,
        [String] $StaticIP,
        [String] $CIDR,
        [String] $Gateway,
        [String] $DNS
    )

    $ipv4 = "IPv4"
    $NetAdapter = Get-NetAdapter -Name "$AdapterName"

    # Check is status is enabled
    if ($NetAdapter.Status -eq "Disabled") {
        $NetAdapter | Enable-NetAdapter
    }

    # Scriptblock for Static Network Addressing
    if ($Addressing -eq "Static") {
        
        # Remove any existing IP or Network Gateway
        if (($NetAdapter | Get-NetIPConfiguration).IPv4Address.IPAddress) {
            Write-Verbose "Removing existing IP's"
            $NetAdapter | Remove-NetIPAddress -AddressFamily "$ipv4 " -Confirm:$false
        }

        if (($NetAdapter | Get-NetIPConfiguration).Ipv4DefaultGateway) {
            Write-Verbose "Removing existing gateway"
            $NetAdapter | Remove-NetRoute -AddressFamily "$ipv4" -Confirm:$false
        }

        # Set static IP Address
        Write-Verbose "Adding new ipv4 addresses '$StaticIP', '$CIDR', '$Gateway'"
        $NetAdapter | New-NetIPAddress `
            -AddressFamily "$ipv4" `
            -IPAddress "$StaticIP" `
            -PrefixLength "$CIDR"`
            -DefaultGateway "$Gateway"

        # Set DNS Client Server
        Write-Verbose "Adding new DNS Client Address '$DNS'"
        $NetAdapter | Set-DnsClientServerAddress -ServerAddresses "$DNS"

    }

    # Scriptblock for DHCP Network Addressing
    if ($Addressing -eq "DHCP") {

      # Get Network Interface
      $NetInterface = $NetAdapter | Get-NetIPInterface -AddressFamily "$ipv4"

      # Enable DHCP
      if ($NetInterface.Dhcp -eq "Disabled") {
        if (($NetInterface | Get-NetIPConfiguration).Ipv4DefaultGateway) {
            $NetInterface | Remove-NetRoute -Confirm:$false
        }

          $NetInterface | Set-NetIPInterface -DHCP Enabled
          $NetInterface | Set-DnsClientServerAddress -ResetServerAddresses
      } 

    }

    # Restart Network Adapter to apply settings
    $NetAdapter | Restart-NetAdapter
}

# Set Network Address Static
Change-NetworkAddress -Addressing Static `
                        -AdapterName "WiFi" `                        -StaticIP "192.168.10.11"`                        -CIDR 24`                        -Gateway "192.168.10.10"`                        -DNS "192.168.10.10"Change-NetworkAddress -Addressing DHCP -AdapterName "WiFi"                       
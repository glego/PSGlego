function Enable-InterfaceDHCP(){

    $NetAdapterName = "Ethernet"
    $IPType = "IPv4"

    $Adapter = Get-NetAdapter -Name $NetAdapterName | Select-Object -First 1
    $Interface = $adapter | Get-NetIPInterface -AddressFamily $IPType | Select-Object -First 1

    if ($Interfaces.Dhcp -eq "Disabled"){
        # Remove Gateways
        if (($interface | Get-NetIPConfiguration).Ipv4DefaultGateway){
            $interface | Remove-NetRoute -Confirm:$false
        }
        # Enable DHCP
        $interface | Set-NetIPInterface -DHCP Enabled

        # Configure the  DNS Servers automatically
        $interface | Set-DnsClientServerAddress -ResetServerAddresses
    }
}

function Enable-StatisInterface (){

    
    $NetAdapterName = "Ethernet"
    $IP = "192.168.10.5"
    $MaskBits = 24 # This means subnet mask = 255.255.255.0
    #$Gateway = "192.168.10.1"
    $Dns = "8.8.8.8"
    $IPType = "IPv4"

    # Retrieve the network adapter that you want to configure
    $adapter = Get-NetAdapter -Name $NetAdapterName | Select-Object -First 1

    # Remove any existing IP, gateway from our ipv4 adapter
    If (($adapter | Get-NetIPConfiguration).IPv4Address.IPAddress) {
        $adapter | Remove-NetIPAddress -AddressFamily $IPType -Confirm:$false
    }

    If (($adapter | Get-NetIPConfiguration).Ipv4DefaultGateway) {
        $adapter | Remove-NetRoute -AddressFamily $IPType -Confirm:$false
    }

     # Configure the IP address and default gateway
    $adapter | New-NetIPAddress `
        -AddressFamily $IPType `
        -IPAddress $IP `
        -PrefixLength $MaskBits `
     #   -DefaultGateway $Gateway

    # Configure the DNS client server IP addresses
    $adapter | Set-DnsClientServerAddress -ServerAddresses $DNS

}


Enable-InterfaceDHCP

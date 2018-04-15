$ErrorActionPreference = "stop"

# https://docs.microsoft.com/en-us/azure/azure-stack/user/azure-stack-quick-create-vm-windows-powershell

function main () {
[CmdletBinding()]
    Param
    (
        
    )

    ##
    ## Create a resource group
    ##
    # Logical container into which Azure Stack resources are deployed and managed
    $location = "westeurope"
    $ResourceGroupName = "myResourceGroup"

    Write-Verbose "Creating new resource group $ResourceGroupName in $location"
    New-AzureRmResourceGroup `
        -Name $ResourceGroupName `
        -Location $location

    ##
    ## Storage
    ##
    # Create variables to store the storage account name and the storage account SKU information
    $StorageAccountName = "mystorage$(-join ((97..122) + (48..57) | Get-Random -Count 10 | ForEach-Object {[char]$_}))" # 10 random characters and numbers
    $SkuName = "Standard_LRS"

    Write-Verbose "Creating new storage account $StorageAccountName with sku $SkuName"
    $StorageAccount = New-AzureRMStorageAccount `
      -Location $location `
      -ResourceGroupName $ResourceGroupName `
      -Type $SkuName `
      -Name $StorageAccountName
    
    Set-AzureRmCurrentStorageAccount `
      -StorageAccountName $StorageAccountName `
      -ResourceGroupName $resourceGroupName

    ##
    ## Network
    ##
    # Create a subnet configuration
    $subnetName = "mySubnet"
    $subnetPrefix = "192.168.1.0/24"

    Write-Verbose "Creating new subnet $subnetName with prefix $subnetPrefix"
    $subnetConfig = New-AzureRmVirtualNetworkSubnetConfig `
      -Name $subnetName `
      -AddressPrefix $subnetPrefix

    # Create a virtual network

    $virtualNetworkName = "myVnet"
    $virtualNetworkPrefix = "192.168.0.0/16"

    Write-Verbose "Creating new virtual network $virtualNetworkName with prefix $virtualNetworkPrefix"
    $vnet = New-AzureRmVirtualNetwork `
      -ResourceGroupName $ResourceGroupName `
      -Location $location `
      -Name $virtualNetworkName `
      -AddressPrefix $virtualNetworkPrefix `
      -Subnet $subnetConfig

    # Create a public IP address and specify a DNS name
    $publicIpName = "mypublicdns$(-join ((97..122) + (48..57) | Get-Random -Count 23 | ForEach-Object {[char]$_}))" # 10 random characters and numbers

    Write-Verbose "Creating new public ip $publicIpName"
    $pip = New-AzureRmPublicIpAddress `
      -ResourceGroupName $ResourceGroupName `
      -Location $location `
      -AllocationMethod Static `
      -IdleTimeoutInMinutes 4 `
      -Name $publicIpName

    ## Network security group + rule
    # Create an inbound network security group rule for port 3389

    Write-Verbose "Creating new security rule for rdp (3389)"
    $nsgRuleRDP = New-AzureRmNetworkSecurityRuleConfig `
      -Name myNetworkSecurityGroupRuleRDP `
      -Protocol Tcp `
      -Direction Inbound `
      -Priority 1000 `
      -SourceAddressPrefix * `
      -SourcePortRange * `
      -DestinationAddressPrefix * `
      -DestinationPortRange 3389 `
      -Access Allow

    # Create an inbound network security group rule for port 80
    Write-Verbose "Creating new security rule for http (80)"
    $nsgRuleWeb = New-AzureRmNetworkSecurityRuleConfig `
      -Name myNetworkSecurityGroupRuleWWW `
      -Protocol Tcp `
      -Direction Inbound `
      -Priority 1001 `
      -SourceAddressPrefix * `
      -SourcePortRange * `
      -DestinationAddressPrefix * `
      -DestinationPortRange 80 `
      -Access Allow

    # Create a network security group
    $securityGroupName = "myNetworkSecurityGroup"
    Write-Verbose "Create new network security group $securityGroupName"
    $nsg = New-AzureRmNetworkSecurityGroup `
      -ResourceGroupName $ResourceGroupName `
      -Location $location `
      -Name myNetworkSecurityGroup `
      -SecurityRules $nsgRuleRDP,$nsgRuleWeb 

    ## Network card
    # Create a virtual network card and associate it with public IP address and NSG
    $networkInterfaceName = "myNic"

    Write-Verbose "Create new network interface $networkInterfaceName"
    $nic = New-AzureRmNetworkInterface `
      -Name myNic `
      -ResourceGroupName $ResourceGroupName `
      -Location $location `
      -SubnetId $vnet.Subnets[0].Id `
      -PublicIpAddressId $pip.Id `
      -NetworkSecurityGroupId $nsg.Id 

    ## Create virtual machine
    # Define a credential object to store the username and password for the virtual machine
    $UserName='demoglego'
    $Password='HelloGlenn@1234'| ConvertTo-SecureString -Force -AsPlainText
    $Credential=New-Object PSCredential($UserName,$Password)

    # Create the virtual machine configuration object
    $VmName = "myVirtualMachinec"
    $VmSize = "Standard_A1"
    $VmComputerName = "MyComputer"
    $VmSourcePublisherName = "MicrosoftWindowsServer"
    $VmSourceOffer = "WindowsServer"
    $VmSourceSkus = "2016-Datacenter"
    $VmSourceVersion = "latest"

    Write-Verbose "New VM config $VmName, $VmSize"
    $VirtualMachine = New-AzureRmVMConfig `
      -VMName $VmName `
      -VMSize $VmSize 

    Write-Verbose "Set OS to Windows,user $UserName and computer name $VmComputerName"
    $VirtualMachine = Set-AzureRmVMOperatingSystem `
      -VM $VirtualMachine `
      -Windows `
      -ComputerName $VmComputerName `
      -Credential $Credential 

    Write-Verbose "Set source image $VmSourcePublisherName, $VmSourceOffer, $VmSourceSkus $VmSourceVersion"
    $VirtualMachine = Set-AzureRmVMSourceImage `
      -VM $VirtualMachine `
      -PublisherName $VmSourcePublisherName `
      -Offer $VmSourceOffer `
      -Skus $VmSourceSkus `
      -Version $VmSourceVersion

    $osDiskName = "OsDisk"
    $osDiskUri = '{0}vhds/{1}-{2}.vhd' -f `
      $StorageAccount.PrimaryEndpoints.Blob.ToString(),`
      $vmName.ToLower(), `
      $osDiskName

    Write-Verbose "Set new Disk $osDiskName"
    # Sets the operating system disk properties on a virtual machine. 
    $VirtualMachine = Set-AzureRmVMOSDisk `
      -VM $VirtualMachine `
      -Name $osDiskName `
      -VhdUri $OsDiskUri `
      -CreateOption FromImage | `
      Add-AzureRmVMNetworkInterface -Id $nic.Id 

    # Create the virtual machine.
    Write-Verbose "Create new VM $VirtualMachine"
    New-AzureRmVM `
      -ResourceGroupName $ResourceGroupName `
      -Location $location `
      -VM $VirtualMachine

    # Get public ip address
    Write-Verbose "Get public IP"
    Get-AzureRmPublicIpAddress `
      -ResourceGroupName $ResourceGroupName | Select-Object IpAddress

    <#
    - mstsc /v IP

    - Install IIS
    Install-WindowsFeature -name Web-Server -IncludeManagementTools

    - Remove the whole virtual machine

    Remove-AzureRmResourceGroup `
        -Name "myResourceGroup"
    #>
    # mstsc /v $MyPublicI
}

main -Verbose
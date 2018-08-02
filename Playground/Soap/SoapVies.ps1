
# https://scotthelme.co.uk/how-the-eu-made-our-website-slow/

Function Get-ViesVatNumber {
[CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,
                   Position=0)]
        $CountryCode,

        [Parameter(Mandatory=$true,
                   Position=1)]
        $VatNumber
    )

    $Vies = New-WebServiceProxy -Uri "http://ec.europa.eu/taxation_customs/vies/checkVatService.wsdl" -Class "checkVat"

    $Valid = $false
    $Name = ""
    $Address = ""

    $DateChecked = $Vies.checkVat([ref]$CountryCode, [ref]$VatNumber, [ref]$Valid, [ref]$Name, [ref]$Address)

    $Properties = @{
        'CountryCode'   = $CountryCode
        'VatNumber'     = $VatNumber
        'Valid'         = $Valid
        'Name'          = $Name
        'Address'       = $Address
        'DateChecked'   = $DateChecked
    }

    $Company = New-Object -TypeName PSCustomObject -Property $Properties
    
    Write-Output $Company
}
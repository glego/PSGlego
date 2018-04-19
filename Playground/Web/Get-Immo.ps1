# This tool will scrape immo websites for new 

# https://github.com/kbrammer/kevinbrammer.azurewebsites.net/wiki/Using-HtmlAgilityPack-With-Powershell
# https://github.com/zzzprojects/html-agility-pack
# https://www.nuget.org/packages/HtmlAgilityPack/

# Init
$FilePath = (Get-ChildItem ".\lib\htmlagilitypack.1.8.0\Net45\HtmlAgilityPack.dll").FullName
[Reflection.Assembly]::LoadFile("$FilePath")
[HtmlAgilityPack.HtmlWeb]$web = @{}
$web.OverrideEncoding = [System.Text.Encoding]::UTF8

Function Invoke-ParseImmoWeltExpose () {
    [CmdletBinding()]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [string]$Url
    )
    
    [HtmlAgilityPack.HtmlDocument]$doc = $web.Load("$Url")

    [HtmlAgilityPack.HtmlNodeCollection]$nodes = $doc.DocumentNode.SelectNodes("//div[@class='js-object   listitem_wrap ']")

    # $node = $nodes | select-object -first 1

    $Exposes = @()

    foreach ($node in $nodes) {
        $Property = [Ordered]@{}

        $Link = ""
        $Link = $node.SelectNodes(".//a[@href]") | Where-Object OuterHTML -Like "*expose*" | ForEach-Object {$_.Attributes["href"].value}
        $Link = "https://www.immowelt.de" + $Link

        $Property.Add("Link", $Link)
        $Property.Add("Image", $node.SelectNodes(".//picture/source").GetAttributeValue("data-srcset", ""))
        $Property.Add("Titel", $node.SelectNodes(".//h2[@class='ellipsis']").InnerText)
        $Property.Add("Abstand", $node.SelectNodes(".//strong[@class='distance']").InnerText.trim())
        $Property.Add("Ort", $node.SelectNodes(".//div[@class='listlocation ellipsis']").InnerText.trim().replace("  ","").replace("`r`n"," "))
        $Property.Add("Merkmale", $node.SelectNodes(".//div[@class='listmerkmale ellipsis']").InnerText.trim())
        $Property.Add("Preis", $node.SelectNodes(".//div[@class='hardfact price_sale']/strong").InnerText.trim())
        $Property.Add("Zimmer", $node.SelectNodes(".//div[@class='hardfact rooms']").InnerText.trim().replace("  ","").replace("`r`n"," "))

        $Facts = ""
        $Facts = $node.SelectNodes(".//div[@class='hardfact ']")
        $Facts | ForEach-Object {
            $FactEncoded = $_.Innertext.trim().replace("  ","").replace("`r`n"," ")
            $Fact = [System.Web.HttpUtility]::HtmlDecode($FactEncoded)
            if ($Fact -like "*Wohnfläche*") {
                $Property.Add("Wohnflaeche", $Fact)
            }

            if ($Fact -like "*Grundstück*") {
                $Property.Add("Grundstuekflaeche", $Fact)
            }
        }

        $Immowelt = New-Object -TypeName PSObject -Property $Property
        $Immowelt.PSObject.TypeNames.Insert(0, "Glego.Immo.Immowelt")

        $Exposes += $Immowelt

    }

    Write-Output $Exposes


}

Function Get-ImmoWeltExpose () {
      [CmdletBinding()]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [string]$Url
    )
    
    $HasMorePages = $true
    $Exposes = @()
        
    while ($HasMorePages) {
        
        Write-Verbose "Opening page $Url"
        [HtmlAgilityPack.HtmlDocument]$doc = $web.Load("$Url")
        [HtmlAgilityPack.HtmlNodeCollection]$Nodes = $doc.DocumentNode.SelectNodes("//div[@class='js-object   listitem_wrap ']")

        $Header = [System.Web.HttpUtility]::HtmlDecode($doc.DocumentNode.SelectNodes(".//h1[@class='ellipsis margin_none']").InnerText.trim().replace("  ","").replace("`r`n"," "))
        Write-Verbose "Header: $Header"
        
        $Exposes += New-Expose -Nodes $Nodes -ErrorAction SilentlyContinue

        [HtmlAgilityPack.HtmlNodeCollection]$Nodes = $doc.DocumentNode.SelectNodes("//div[@id='pnlPaging']")
        try {
            $Url = ""
            $Url = $nodes.SelectNodes(".//a[@id='nlbPlus']").GetAttributeValue("href","")
            $Url = [System.Web.HttpUtility]::HtmlDecode("https://www.immowelt.de" + $Url)
            Write-Verbose "Next page $Url"
        } catch {
            Write-Verbose "No more pages..."
            $HasMorePages = $false
        }
    }

    Write-Output $Exposes
    
    
}

Function New-Expose () {
[CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [HtmlAgilityPack.HtmlNodeCollection]$Nodes
    )
    
    Write-Verbose "Processing $($nodes.count) exposes"
        foreach ($node in $nodes) {
            $Property = [Ordered]@{}

            $Link = ""
            $Link = $node.SelectNodes("./div/a[@href]").GetAttributeValue("data-srcset", "")
            $Link = "https://www.immowelt.de" + $Link

            $Property.Add("Link", [System.Web.HttpUtility]::HtmlDecode($Link))
            $Property.Add("Image", [System.Web.HttpUtility]::HtmlDecode($node.SelectNodes(".//picture/source").GetAttributeValue("data-srcset", "")))
            $Property.Add("Titel", [System.Web.HttpUtility]::HtmlDecode($node.SelectNodes(".//h2[@class='ellipsis']").InnerText))
            $Property.Add("Abstand", [System.Web.HttpUtility]::HtmlDecode($node.SelectNodes(".//strong[@class='distance']").InnerText.trim()))
            $Property.Add("Ort", [System.Web.HttpUtility]::HtmlDecode($node.SelectNodes(".//div[@class='listlocation ellipsis']").InnerText.trim().replace("  ","").replace("`r`n"," ")))
            $Property.Add("Merkmale", [System.Web.HttpUtility]::HtmlDecode($node.SelectNodes(".//div[@class='listmerkmale ellipsis']").InnerText.trim()))
            $Property.Add("Preis", [System.Web.HttpUtility]::HtmlDecode($node.SelectNodes(".//div[@class='hardfact price_sale']/strong").InnerText.trim()))
            $Property.Add("Zimmer", [System.Web.HttpUtility]::HtmlDecode($node.SelectNodes(".//div[@class='hardfact rooms']").InnerText.trim().replace("  ","").replace("`r`n"," ")))

            $Facts = ""
            $Facts = $node.SelectNodes(".//div[@class='hardfact ']")
            $Facts | ForEach-Object {
                $FactEncoded = $_.Innertext.trim().replace("  ","").replace("`r`n"," ")
                $Fact = [System.Web.HttpUtility]::HtmlDecode($FactEncoded)

                if ($Fact -like "*Wohnfläche*") {
                    $Property.Add("Wohnflaeche", [System.Web.HttpUtility]::HtmlDecode($Fact))
                }

                if ($Fact -like "*Grundstück*") {
                    $Property.Add("Grundstuekflaeche", [System.Web.HttpUtility]::HtmlDecode($Fact))
                }
            }

            $Immowelt = New-Object -TypeName PSObject -Property $Property
            $Immowelt.PSObject.TypeNames.Insert(0, "Glego.Immo.Immowelt")

            Write-Output $Immowelt
        }
}

## Not really an option as you need to merge the hashtables afterwards...

function Add-HtmlEncodedValue
{
    [CmdletBinding()]
    [Alias()]
    Param
    (
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [System.Collections.Specialized.OrderedDictionary]$Property,

        [string]$Name,
        [string]$EncodedValue
    )

        $Property.Add($Name, [System.Web.HttpUtility]::HtmlDecode($EncodedValue))
        Write-Output $Property
}

Function Merge-Hashtables([ScriptBlock]$Operator) {
    $Output = @{}
    ForEach ($Hashtable in $Input) {
        If ($Hashtable -is [Hashtable]) {
            ForEach ($Key in $Hashtable.Keys) {$Output.$Key = If ($Output.ContainsKey($Key)) {@($Output.$Key) + $Hashtable.$Key} Else  {$Hashtable.$Key}}
        }
    }
    If ($Operator) {ForEach ($Key in @($Output.Keys)) {$_ = @($Output.$Key); $Output.$Key = Invoke-Command $Operator}}
    $Output
}
$Exposes = Get-ImmoWeltExpose -Url "https://www.immowelt.de/liste/bad-vilbel/haeuser/kaufen?lat=50.1825&lon=8.73849&sr=5&sort=createdate%2Bdesc" -Verbose
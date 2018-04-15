[CmdletBinding()]
Param(
	[Parameter(Position=0,mandatory=$true)]
	[string]$TagsFilePath = ""	
)

[System.Reflection.Assembly]::LoadWithPartialName("System.Web.Extensions")

Function DeserializeJSON() {
 Param(
        [string]$json = ""
     )
	 
try
{
	$ser = New-Object System.Web.Script.Serialization.JavaScriptSerializer
	$obj = $ser.DeserializeObject($json)
}
finally
{
    if ($null -ne $streamWriter) { $streamWriter.Dispose() }
    if ($null -ne $requestStream) { $requestStream.Dispose() }
	if ($null -ne $obj) { Write-Output $obj } 
}

}

Function SerializeJSON() {
 Param(
        [object]$Obj
     )

try
{
	$ser = New-Object System.Web.Script.Serialization.JavaScriptSerializer
	$json = $ser.Serialize($Obj)
}
finally
{
    if ($null -ne $streamWriter) { $streamWriter.Dispose() }
    if ($null -ne $requestStream) { $requestStream.Dispose() }
	if ($null -ne $json) { Write-Output $json } 
}

}

Function PostWebRequest([String] $url, [String] $data, [int] $timeout) {    
	 
	 Write-Verbose "Posting data to $url"
     $buffer = [System.Text.Encoding]::UTF8.GetBytes($data)
     [System.Net.HttpWebRequest] $webRequest = [System.Net.WebRequest]::Create($url)
     $webRequest.Timeout = $timeout
     $webRequest.Method = "POST"
     $webRequest.ContentType = "application/json"
     $webRequest.ContentLength = $buffer.Length;


     $requestStream = $webRequest.GetRequestStream()
     $requestStream.Write($buffer, 0, $buffer.Length)
     $requestStream.Flush()
     $requestStream.Close()


     [System.Net.HttpWebResponse] $webResponse = $webRequest.GetResponse()
     $streamReader = New-Object System.IO.StreamReader($webResponse.GetResponseStream())
     $result = $streamReader.ReadToEnd()
     Write-Output $result
 }

Function PostAssignOneProduct() {
[CmdletBinding()]
 Param([parameter(Mandatory = $false)]
         [string] $LayoutId = 0,

         [parameter(Mandatory = $true)]
         [string] $ItemId,
		 
		 [parameter(Mandatory = $true)]
         [string] $TagId,
		
		 [parameter(Mandatory = $false)]
         [string] $StoreCode = "1038",
		
		 [parameter(Mandatory = $false)]
         [string] $Url = "http://localhost/inf/pda/assign/oneProduct"
		 )
		
	$RequestTime = (Get-Date).ToString("yyyyMMddhhmmss")
	$ClientID = "PowerShell"
	$ServiceID = "Assign"
	$TagInch = ""

	$Assign 			= @{}
	$Assign.Header 	= @{
	'StoreCode' 			= $StoreCode
	'RequestTime'			= $RequestTime
	'RequestType'			= "Request"
	'ClientID' 				= $ClientID
	'ServiceID'				= $ServiceID
	}

	$Assign.Body 		= @{}

	$Assign.Body.LAYOUT = @{
	'LAYOUT_ID' 			= $LayoutId
	}

	$Assign.Body.PRODUCT = @{
	'ITEM_ID' 			= $ItemId
	}

	$Assign.Body.TAG = @{
	'TAG_ID' 			= $TagId
	'TAG_INCH' 			= $TagInch
	}

	$JsonRequest = SerializeJSON -Obj $Assign
	Write-Verbose $JsonRequest

	$JsonReponse = PostWebRequest -URL $Url -data $JsonRequest -timeout 60000
	Write-Verbose $JsonReponse
	
	$Response = DeserializeJSON -json $JsonReponse
	if ($Response.Header.ResultCode -eq "00") {
		Write-Output ("Success: " + $TagId + ";" + $ItemId + ";" + $StoreCode + " ResultCode='" + $Response.Header.ResultCode + "'")
	}else{
		Write-Output ("Error: " + $TagId + ";" + $ItemId + ";" + $StoreCode + " ResultCode='" + $Response.Header.ResultCode + "' Message='" + $Response.Header.Message + "'")
	}

}

$Tags = Import-Csv -Path $TagsFilePath -Delimiter ";" -Header Mac,Item,Store

foreach ($Tag in $Tags){
	PostAssignOneProduct -ItemId $Tag.Item -TagId $Tag.Mac -StoreCode $Tag.Store
}
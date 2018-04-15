[CmdletBinding()]
Param(
	[Parameter(Position=0,mandatory=$true)]
	[string]$TagsFilePath	= ""	
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

Function PostUnAssignOneProduct() {
[CmdletBinding()]
 Param(
		 [parameter(Mandatory = $true)]
         [string] $TagId,
		
		 [parameter(Mandatory = $false)]
         [string] $StoreCode = "1038",
		
		 [parameter(Mandatory = $false)]
         [string] $Url = "http://localhost/inf/pda/unassign/tag"
		 )
		
	$RequestTime = (Get-Date).ToString("yyyyMMddhhmmss")
	$ClientID = "PowerShell"
	$ServiceID = "UnassignTag"
	
	$UnAssign 			= @{}
	$UnAssign.Header 	= @{
	'StoreCode' 			= $StoreCode
	'RequestTime'			= $RequestTime
	'RequestType'			= "Request"
	'ClientID' 				= $ClientID
	'ServiceID'				= $ServiceID
	}

	$UnAssign.Body 		= @{
	'TAG_ID' 				= $TagId
	}

	$JsonRequest = SerializeJSON -Obj $UnAssign
	Write-Verbose $JsonRequest

	$JsonReponse = PostWebRequest -URL $Url -data $JsonRequest -timeout 60000
	Write-Verbose $JsonReponse
	
	$Response = DeserializeJSON -json $JsonReponse
	if ($Response.Header.ResultCode -eq "00") {
		Write-Output ("Success: " + $TagId + ";" + $StoreCode + " ResultCode='" + $Response.Header.ResultCode + "'")
	}else{
		Write-Output ("Error: " + $TagId + ";" + $StoreCode + " ResultCode='" + $Response.Header.ResultCode + "' Message='" + $Response.Header.Message + "'")
	}

}

$ItemTags = Import-Csv -Path $TagsFilePath -Delimiter ";" -Header Mac,Store

foreach ($ItemTag in $ItemTags){
	PostUnAssignOneProduct -TagId $ItemTag.Mac -StoreCode $ItemTag.Store
}
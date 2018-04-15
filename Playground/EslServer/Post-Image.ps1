[CmdletBinding()]
Param(
	[Parameter(Position=0,mandatory=$true)]
	[string]$InputPath,

    [Parameter(Position=1,mandatory=$true)]
	[string]$OutputPath,

	[Parameter(Position=2,mandatory=$false)]
	[string]$BatchID,
	
	[Parameter(Position=3,mandatory=$false)]
	[string]$Url = "http://localhost/inf/updateImage"

	
    
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
	if ($null -ne $obj) { write-output $obj } 
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
	if ($null -ne $json) { write-output $json } 
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
     write-output $result
 }

Function Post-Image() {
[CmdletBinding()]
 Param(
		[Parameter(Position=0,mandatory=$true)]
		[string]$LabelId,
		
		[Parameter(Position=1,mandatory=$true)]
		[string]$ImageFilePath,
		
		[Parameter(Position=2,mandatory=$true)]
		[string]$LabelPage,
		
		[Parameter(Position=3,mandatory=$true)]
		[string]$BatchID)
			
	$PostImage 			= @{}
	$PostImage.Header 	= @{
		'RequestType'			= "Request"
	}

	$PostImage.Body 		= @{
		'CUST_BATCH_ID' 		= $BatchID
	}
    $PostImage.Body.TAG = @()
	$PostImage.Body.TAG += @{
		'TAG_ID'				= $LabelId
		'IMAGE'					= $ImageFilePath
		'PAGE'					= $LabelPage
	}

	$JsonRequest = SerializeJSON -Obj $PostImage
	Write-Verbose $JsonRequest

	$JsonReponse = PostWebRequest -URL $Url -data $JsonRequest -timeout 60000
	Write-Verbose $JsonReponse
	
	$Response = DeserializeJSON -json $JsonReponse
	if ($Response.Body.RESULT_CODE -eq "00") {
		Write-Output ("Success: " + $LabelId + ";" + " ResultCode='" + $Response.Body.RESULT_CODE + "'")
	}else{
		Write-Output ("Error: " + $LabelId + ";" + " ResultCode='" + $Response.Body.RESULT_CODE + "' Message='" + $Response.Body.RESULT + "'")
	}

}

Write-Verbose "Adding BatchID when BatchID is Empty..."
if ($BatchID -eq "") {$BatchID = get-date -Format "PSyyyyMMddhhmmss"}

#Write-Verbose "Adding double backslash for ImageFilePath when it doesn't exist..."
#if ($ImageFilePath.Contains("\\") -eq $false) { $ImageFilePath = $ImageFilePath.Replace("\","\\") }

$Images = Get-ChildItem -Path $InputPath

ForEach ($Image in $Images) {
    
    $ImageName = $Image.Name
    $ImageNameSplit = $Image.BaseName.Split("-")

    $LabelId = $ImageNameSplit[0]
    $LabelPage = "1"
    $ImageBaseName = ($ImageNameSplit[0] + "-1")
    $ImageExtension = $Image.Extension
    $ImageFilePath = $Image.FullName
    
    Write-Verbose "Copying image '$ImageName' to output folder '$OutputPath'..."
    $ImageOutputFilePath = ($OutputPath + "\" + $ImageBaseName + "-progress")
    Copy-Item -Path $Image.FullName -Destination $ImageOutputFilePath

    Write-Verbose "Posting Image: $LabelId, $LabelPage , $ImageFilePath, $BatchID"
    $PostImage = Post-Image -LabelId $LabelId -ImageFilePath $ImageFilePath -LabelPage $LabelPage -BatchID $BatchID
    
    if ($PostImage -like "*Success*") 
    { Move-Item -Path $ImageOutputFilePath -Destination ($OutputPath + "\" + $ImageBaseName + "-" +  (get-date -Format "yyyyMMddHHmmss") + "-success" + $ImageExtension) -Force }  
    else 
    { Move-Item -Path $ImageOutputFilePath -Destination ($OutputPath + "\" + $ImageBaseName + "-" +  (get-date -Format "yyyyMMddHHmmss") + "-failed" + $ImageExtension) -Force
      Remove-Item -Path $Image.FullName}

    Write-Output $PostImage 
}


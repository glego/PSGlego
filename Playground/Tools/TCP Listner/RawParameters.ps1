$rawUrl = "/test.html?parameter1=xxx&parameter2=yyy"

$Parameters = @{}
$rawUrl = $rawUrl.Split("?")
$Path = $rawUrl[0]
$rawParameters = $rawUrl[1]
$rawParameters = $rawParameters.Split("&")

foreach ($rawParameter in $rawParameters) {
    $Parameter = $rawParameter.Split("=")
    
    $Parameters.Add($Parameter[0], $Parameter[1])
}


$Path 
$Parameters

Write-Output "Path is $Path"
foreach ($Parameter in $Parameters.GetEnumerator()) {
    Write-Output "$($Parameter.Name) is equal to $($Parameter.Value)"
}
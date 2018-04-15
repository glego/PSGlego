
$computer = "34.248.201.199"

$scheme = "http"
$port = "80"
$http = $scheme + "://" + $computer + ":" + $port

$scheme = "https"
$port = "443"
$https = $scheme + "://" + $computer + ":" + $port

# User Info
$neuronApplicationId = "473dbb8da506cd8d84238370dd86f257cd3a3cf9"
$neuronApplicationKey = "5"

# Datasets
$dataset1 = "bean_pro_espresso_demo"

Function Get-AboutVersionInfo () {
    # Get the About Version from Thingworx
    $resource = "/about/versioninfo"

    $headers = @{}
    $headers.Add("accept","application/json")
    $headers.Add("neuron-application-id",$neuronApplicationId)
    $headers.Add("neuron-application-key",$neuronApplicationKey)

    $uri = $http + $resource
    $response = Invoke-WebRequest -Uri $uri -Headers $headers -Method Get -ContentType "application/json"
    $response
}

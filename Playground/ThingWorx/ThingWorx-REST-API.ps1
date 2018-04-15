
# https://developer.thingworx.com/resources/guides/thingworx-rest-api-quickstart

$computer = "localhost"

$scheme = "http"
$port = "8080"
$http = $scheme + "://" + $computer + ":" + $port

# User Info
$appKey = "653dad19-8824-4ab8-ad15-5c1b7a9f2d2c"

# Things
Function New-Thing () {
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [string]
        $name,

        [Parameter(Mandatory=$true,
                   Position=1)]
        [string]
        $templateName
    )
      Begin
    {
        $resource = "/Thingworx/Resources/EntityServices/Services/CreateThing"
        $headers = @{}
        $body = @{}

    }
    Process
    {
        $headers.Add("accept","application/json")
        $headers.Add("appKey",$appKey)

        $body.Add("name", $name)
        $body.Add("thingTemplateName", $templateName)

        $json = ConvertTo-Json $body

        $uri = $http + $resource

        Write-Verbose "Invoking Webrequest to $uri"
        $response = Invoke-WebRequest -Uri $uri -Headers $headers -Body $json -Method Post -ContentType "application/json"

    }
    End
    {
        Write-Output $response
    }

}

Function Enable-Thing () {
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [string]
        $name
    )
      Begin
    {
        
        $headers = @{}

    }
    Process
    {
        $resource = "/Thingworx/Things/$name/Services/EnableThing"
        $headers.Add("accept","application/json")
        $headers.Add("appKey",$appKey)

        $uri = $http + $resource

        $response = Invoke-WebRequest -Uri $uri -Headers $headers -Method Post -ContentType "application/json"

    }
    End
    {
        Write-Output $response
    }
    



   



}

Function Restart-Thing () {
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [string]
        $name
    )
      Begin
    {
        
        $headers = @{}

    }
    Process
    {
        $resource = "/Thingworx/Things/$name/Services/RestartThing"
        $headers.Add("accept","application/json")
        $headers.Add("appKey",$appKey)

        $uri = $http + $resource

        $response = Invoke-WebRequest -Uri $uri -Headers $headers -Method Post -ContentType "application/json"

    }
    End
    {
        Write-Output $response
    }

}

Function New-ThingProperty () {
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [string]
        $name,

        [Parameter(Mandatory=$true,
                   Position=1)]
        [string]
        $propertyName,

        [Parameter(Mandatory=$true,
                   Position=2)]
        [string]
        $type
    )
      Begin
    {
        $resource = "/Thingworx/Things/$name/Services/AddPropertyDefinition"
        $headers = @{}
        $body = @{}

    }
    Process
    {
        $headers.Add("accept","application/json")
        $headers.Add("appKey",$appKey)

        $body.Add("name", $propertyName)
        $body.Add("type", $type)

        $json = ConvertTo-Json $body

        $uri = $http + $resource

        Write-Verbose "Invoking Webrequest to $uri"
        $response = Invoke-WebRequest -Uri $uri -Headers $headers -Body $json -Method Post -ContentType "application/json"

    }
    End
    {
        Write-Output $response
    }
    



   



}

Function Set-ThingProperty () {
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [string]
        $name,

        [Parameter(Mandatory=$true,
                   Position=1)]
        [string]
        $propertyName,

        [Parameter(Mandatory=$true,
                   Position=2)]
        [object]
        $value
    )
      Begin
    {
        $resource = "/Thingworx/Things/$name/Properties/$propertyName"
        $headers = @{}
        $body = @{}

    }
    Process
    {
        $headers.Add("accept","application/json")
        $headers.Add("appKey",$appKey)

        $body.Add("$propertyName", $value)

        $json = ConvertTo-Json $body

        $uri = $http + $resource

        Write-Verbose "$json"
        $response = Invoke-WebRequest -Uri $uri -Headers $headers -Body $json -Method Put -ContentType "application/json"

    }
    End
    {
        Write-Output $response
    }
    



   



}

Function Get-ThingProperty () {
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [string]
        $name,

        [Parameter(Mandatory=$true,
                   Position=1)]
        [string]
        $propertyName
    )
      Begin
    {
        $resource = "/Thingworx/Things/$name/Properties/$propertyName"
        $headers = @{}

    }
    Process
    {
        $headers.Add("accept","application/json")
        $headers.Add("appKey",$appKey)

        $uri = $http + $resource

        Write-Verbose "$json"
        $response = Invoke-WebRequest -Uri $uri -Headers $headers -Body $json -Method Get -ContentType "application/json"

    }
    End
    {
        Write-Output $response
    }
    



   



}

Function Get-Thing () {
    $resource = "/Thingworx/Things"

    $headers = @{}
    $headers.Add("accept","application/json")
    $headers.Add("appKey",$appKey)

    $uri = $http + $resource
    $response = Invoke-WebRequest -Uri $uri -Headers $headers -Method Get -ContentType "application/json"

    Write-Output $response
}

<#


Response Code	Definition
401 - Unauthorized	appKey is incorrect or missing
403 - Forbidden	Content-Type request header is not set to application/json
Sometimes returned instead of a 404
A Property with that name already exists on the platform
404 - Not Found	Incorrect URL or API endpoint
Thing or Property has not been created
Incorrect ThingTemplate name
Required parameter missing from request
405 - Invalid Request	Incorrect request verb; for example a GET was used instead of PUT or POST
406 - Not Acceptable	Invalid JSON in PUT or POST request
Thing [ Thing name ] already exists: A Thing with that name already exists on the platform
500 - Internal Server Error	Content-Type request header is not set for a service execution POST, required even without a POST body
Content-Type request header is not set for DELETE request, required despite the fact that DELETE does not send any content
503 - Service Unavailable	Thing [] is not running
RestartThing endpoint must be called
Thing [] is not enabled
EnableThing endpoint must be called

#>
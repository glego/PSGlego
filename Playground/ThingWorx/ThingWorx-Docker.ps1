
function Start-ThingWorx () {
        [CmdletBinding()]
        Param
        (
            [Parameter(Mandatory=$false,
                       ValueFromPipelineByPropertyName=$true,
                       Position=0)]
            [string]
            $label = "TWX"
        )
    docker start @(docker ps -aq --filter "label=$label")
}

function Stop-ThingWorx () {
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [string]
        $label = "TWX"
    )
    
    docker stop @(docker ps -aq --filter "label=$label")
}

function Get-ThingWorx () {
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [string]
        $label = "TWX"
    )
    
    docker ps -a --filter "label=$label"
}

function Restart-ThingWorx () {
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [string]
        $label = "TWX"
    )
    
    docker restart @(docker ps -aq --filter "label=$label")
}


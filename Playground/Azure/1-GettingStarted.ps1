
## Install from PowerShell Gallery
# Install Azure cmdlets
Install-Module Azure
Install-Module AzureRM

## Connect
# Connect to azure
Connect-AzureRmAccount

# Non-interactive login - you will need to use a service principal
Connect-AzureRmAccount -ServicePrincipal -ApplicationId "http://my-app" -Credential $PSCredential -TenantId $TenantId

# Log into a specific cloud - in this case, the Azure China cloud
Connect-AzureRmAccount -Environment AzureChinaCloud

## Context
# Get the context you are currently using
Get-AzureRmContext

# List all available contexts in the current session
Get-AzureRmContext -ListAvailable


## Subscription
# Get all of the subscriptions in your current tenant
Get-AzureRmSubscription

# Get all of the subscriptions in a specific tenant
Get-AzureRmSubscription -TenantId $TenantId

# Set the context to a specific subscription
Set-AzureRmContext -Subscription $SubscriptionName -Name "MyContext"

# Set the context using piping
Get-AzureRmSubscription -SubscriptionName $SubscriptionName | Set-AzureRmContext -Name "MyContext"


## Discovery
# View all cmdlets in the AzureRM.Profile module
Get-Command -Module AzureRM.Profile

# View all cmdlets that contain "VirtualNetwork"
Get-Command -Name "*VirtualNetwork*"

# View all cmdlets that contain "VM" in the AzureRM.Compute module
Get-Command -Module AzureRM.Compute -Name "*VM*"



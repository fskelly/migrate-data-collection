function Log-ErrorToFile {
    param (
        [string]$Message
    )
    $dateTimestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
    $errorLogPath = Join-Path -Path $HOME -ChildPath ("errorLog_" + $dateTimestamp + ".txt")
    $Message | Out-File -FilePath $errorLogPath -Append
}

# Get all subscriptions
$subscriptions = Get-AzSubscription

# Initialize an array to hold resource group objects
$resourceGroupObjects = @()

foreach ($subscription in $subscriptions) {
    try {
        # Select the subscription
        Set-AzContext -SubscriptionId $subscription.Id

        # Get resource groups in the current subscription
        $resourceGroups = Get-AzResourceGroup

        foreach ($resourceGroup in $resourceGroups) {
            # Create a custom object for the current resource group
            $resourceGroupObject = [PSCustomObject]@{
                SubscriptionId = $subscription.Id
                SubscriptionName = $subscription.Name
                ResourceGroupName = $resourceGroup.ResourceGroupName
                Location = $resourceGroup.Location
            }

            # Append the resource group object to the array
            $resourceGroupObjects += $resourceGroupObject
        }
    } catch {
        # Write the error to a log file and continue with the script
        Log-ErrorToFile "An unexpected error occurred: $_"
    }
}

# $resourceGroupObjects now contains all resource group information
# You can output or process $resourceGroupObjects as needed

# Initialize an array to hold resources from all resource groups
$allResources = @()

foreach ($resourceGroupObject in $resourceGroupObjects) {
    try {
        # Retrieve resources for the current resource group
        $rgName = $resourceGroupObject.ResourceGroupName
        $resources = Get-AzResource -ResourceGroupName $rgName -ErrorVariable resourceCheck -ErrorAction SilentlyContinue

        if ($resourceCheck) {
            Write-Error "An error occurred while retrieving the Resources in : $rgName in subscription: $($resourceGroupObject.SubscriptionName)"
            Log-ErrorToFile "An error occurred while retrieving the Resources in : $rgName in subscription: $($resourceGroupObject.SubscriptionName)"
            #return
        }

        foreach ($resource in $resources) {
            Write-Output "Processing resource group: $rgName in subscription: $($resourceGroupObject.SubscriptionName)"
            # Optional: Create a custom object for each resource with desired details
            $resourceObject = [PSCustomObject]@{
                ResourceId = $resource.ResourceId
                ResourceName = $resource.Name
                ResourceType = $resource.ResourceType
                Location = $resource.Location
            }

            # Add the resource object to the array
            $allResources += $resourceObject
        }
    } catch {
        # Write the error to a log file and continue with the script
        $_ | Out-File -FilePath $errorLogPath -Append
    }
}

# $allResources now contains information about all resources in all resource groups
# You can output or process $allResources as needed
# Generate a date timestamp string
$dateTimestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"

# Define a universal file path for the error log with a date timestamp
$errorLogPath = Join-Path -Path $HOME -ChildPath ("errorLog_" + $dateTimestamp + ".txt")

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
        $_ | Out-File -FilePath $errorLogPath -Append
    }
}

# $resourceGroupObjects now contains all resource group information
# You can output or process $resourceGroupObjects as needed

# Define a universal file path for the error log
$errorLogPath = Join-Path -Path $HOME -ChildPath "errorLog.txt"

# Write the error to the log file and continue with the script
$_ | Out-File -FilePath $errorLogPath -Append
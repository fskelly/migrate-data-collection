function Write-ErrorToFile {
    param (
        [string]$Message
    )
    $dateTimestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
    $errorLogPath = Join-Path -Path $HOME -ChildPath ("errorLog_" + $dateTimestamp + ".txt")
    $Message | Out-File -FilePath $errorLogPath -Append
}

# Get all subscriptions

$subscriptions = Get-AzSubscription -ErrorVariable subscriptionCheck -ErrorAction SilentlyContinue

if ($subscriptionCheck) {
    Write-Error "An error occurred while retrieving the subscriptions: $subscriptionCheck"
    Write-ErrorToFile "An error occurred while retrieving the subscriptions: $subscriptionCheck"
    #return
}

# Initialize an array to hold resource group objects
$vnetObjects = @()

foreach ($subscription in $subscriptions) {
    try {
        # Select the subscription
        Set-AzContext -SubscriptionId $subscription.Id

        write-output "Processing subscription: $($subscription.Name)"

        # Get resource groups in the current subscription
        $virtualNetworks = Get-AzVirtualNetwork 

        # Check if the count of vnets is 0 and skip to the next subscription if so
        if ($virtualNetworks.Count -eq 0) {
            Write-Warning "No vnets found in subscription: $($subscription.Name), skipping..."
            continue
        }else{
            Write-Output "Found $($virtualNetworks.Count) vnets in subscription: $($subscription.Name)"
        }

        #Write-Output "Processing vnets in subscription: $($subscription.Name)"

        foreach ($virtualNetwork in $virtualNetworks) {
            Write-Output "Processing vnet: $($virtualNetwork.Name) in subscription: $($subscription.Name)"
            # Create a custom object for the current virtual network
            $vnetObject = [PSCustomObject]@{
                VirtualNetworkID = $virtualNetwork.Id
                VirtualNetworkName = $virtualNetwork.Name
                ResourceGroupName = $virtualNetwork.ResourceGroupName
                Location = $virtualNetwork.Location
                SubscriptionName = $subscription.Name
            }

            # Append the resource group object to the array
            $vnetObjects += $vnetObject
        }
    } catch {
        # Write the error to a log file and continue with the script
        Write-ErrorToFile "An unexpected error occurred: $_"
    }
}

$vnetObjects

## get connected vnet items
$result=Get-AzVirtualNetwork -Name $vnetObject.VirtualNetworkName  -ResourceGroupName $vnetObject.ResourceGroupName -ExpandResource 'subnets/ipConfigurations' 
$result.Subnets[0].IpConfigurations

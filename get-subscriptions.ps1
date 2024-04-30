function Write-ErrorToFile {
    param (
        [string]$Message
    )
    $dateTimestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
    $errorLogPath = Join-Path -Path $HOME -ChildPath ("errorLog_" + $dateTimestamp + ".txt")
    $Message | Out-File -FilePath $errorLogPath -Append
}

## if management Group does not work

# Login to Azure Account
Connect-AzAccount

Update-AzConfig -DisplayBreakingChangeWarning $false #until change happens

$subscriptions = Get-AzSubscription -ErrorVariable subscriptionCheck -ErrorAction SilentlyContinue

if ($subscriptionCheck) {
    Write-Error "An error occurred while retrieving the subscriptions: $subscriptionCheck"
    Write-ErrorToFile "An error occurred while retrieving the subscriptions: $subscriptionCheck"
    #return
}

# Initialize an array to hold subscription objects
$subscriptionObjects = @()

try {
    foreach ($subscription in $subscriptions) {
        $subscriptionId = $subscription.Id
        $subscriptionName = $subscription.Name
        $subscriptionState = $subscription.State
        $tenantId = $subscription.TenantId
        
        # Create a custom object for the current subscription
        $subscriptionObject = [PSCustomObject]@{
            SubscriptionId = $subscriptionId
            SubscriptionName = $subscriptionName
            State = $subscriptionState
            TenantId = $tenantId
        }
        
        # Append the subscription object to the array
        $subscriptionObjects += $subscriptionObject
        
        Write-Output "SubscriptionId: $subscriptionId, SubscriptionName: $subscriptionName, State: $subscriptionState, TenantId: $tenantId"
    }
}
catch {
    Write-Error "An error occurred: $_"
}

# $subscriptionObjects now contains all subscription information
# You can output or process $subscriptionObjects as needed
$subscriptionObjects


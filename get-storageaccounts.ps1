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

# Initialize an array to hold storage account objects
$storageAccountObjects = @()

foreach ($subscription in $subscriptions) {
    # Select the subscription
    Set-AzContext -Subscription $subscription

    # Get all storage accounts in the subscription
    $storageAccounts = Get-AzStorageAccount -ErrorVariable storageAccountCheck -ErrorAction SilentlyContinue

    if ($storageAccountCheck) {
        Write-Error "An error occurred while retrieving the storage accounts: $storageAccountCheck"
        Write-ErrorToFile "An error occurred while retrieving the storage accounts: $storageAccountCheck"
        #return
    }

    # Add the storage accounts to the array
    foreach ($account in $storageAccounts) {
        $accountObject = New-Object PSObject -Property @{
            AccountName = $account.StorageAccountName
            ResourceGroupName = $account.ResourceGroupName
            Location = $account.Location
            SubscriptionId = $subscription.Id
        }
        $storageAccountObjects += $accountObject
    }
}

# Output the storage account objects
return $storageAccountObjects
function Write-ErrorToFile {
    param (
        [string]$Message
    )
    $dateTimestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
    $errorLogPath = Join-Path -Path $HOME -ChildPath ("errorLog_" + $dateTimestamp + ".txt")
    $Message | Out-File -FilePath $errorLogPath -Append
}

# PowerShell script to list all Azure Management Groups

# Login to Azure Account
Connect-AzAccount

Update-AzConfig -DisplayBreakingChangeWarning $false #until change happens

$mgmtGroups = Get-AzManagementGroup -ErrorVariable mgmtcheck -ErrorAction SilentlyContinue

if ($mgmtcheck) {
    Write-Error "An error occurred while retrieving the management groups: $mgmtcheck"
    Write-ErrorToFile "An error occurred while retrieving the management groups: $mgmtCheck"
    #return
}

try {

    foreach ($mgmtGroup in $mgmtGroups)                                          
    {
        Get-AzManagementGroupSubscription -GroupName $mgmtGroup.Name | ForEach-Object {
            #$subscription = $_
            $subscriptionInfo = (Get-AzSubscription -SubscriptionName ${subscriptionName})
            #$subscriptionInfo
            $subscriptionId = $subscriptionInfo.Id
            #$subscriptionId = $subscription.SubscriptionId
            $subscriptionName = $subscriptionInfo.Name
            #$subscriptionState = $subscription.State
            $subscriptionState = $subscriptionInfo.State
            $tenantId = $subscriptionInfo.TenantId
            $managementGroupName = $mgmtGroup.Name
            Write-Output "SubscriptionId: $subscriptionId, SubscriptionName: $subscriptionName, State: $subscriptionState, Management Group: $managementGroupName, TenantId: $tenantId"
        }
    }
}
catch {
    Write-Error "An error occurred: $_"
}

##==========================================
function Write-ErrorToFile {
    param (
        [string]$Message
    )
    $dateTimestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
    $errorLogPath = Join-Path -Path $HOME -ChildPath ("errorLog_" + $dateTimestamp + ".txt")
    $Message | Out-File -FilePath $errorLogPath -Append
}
# PowerShell script to list all Azure Management Groups

# Login to Azure Account
Connect-AzAccount

Update-AzConfig -DisplayBreakingChangeWarning $false #until change happens

$mgmtGroups = Get-AzManagementGroup -ErrorVariable mgmtcheck -ErrorAction SilentlyContinue

if ($mgmtcheck) {
    Write-ErrorToFile "An error occurred while retrieving the management groups: $mgmtCheck"
    #return
}
# Initialize an array to hold management group objects
$managementGroupObjects = @()

try {
    foreach ($mgmtGroup in $mgmtGroups)                                          
    {
        # Initialize an array to hold subscription objects for the current management group
        $subscriptionObjects = @()

        Get-AzManagementGroupSubscription -GroupName $mgmtGroup.Name | ForEach-Object {
            #$subscription = $_
            $subscriptionInfo = (Get-AzSubscription -SubscriptionName ${subscription.Name})
            # Create a custom object for the current subscription
            $subscriptionObject = [PSCustomObject]@{
                SubscriptionId = $subscriptionInfo.Id
                SubscriptionName = $subscriptionInfo.Name
                State = $subscriptionInfo.State
                TenantId = $subscriptionInfo.TenantId
            }
            # Append the subscription object to the array
            $subscriptionObjects += $subscriptionObject
        }

        # Create a custom object for the current management group with its subscriptions
        $managementGroupObject = [PSCustomObject]@{
            ManagementGroupName = $mgmtGroup.Name
            Subscriptions = $subscriptionObjects
        }

        # Append the management group object to the array
        $managementGroupObjects += $managementGroupObject
    }
}
catch {
    Write-Error "An error occurred: $_"
}

# $managementGroupObjects now contains all management group information along with their subscriptions
# You can output or process $managementGroupObjects as needed
$managementGroupObjects
## ($managementGroupObjects[2].Subscriptions).SubscriptionId - example
## ($managementGroupObjects[2].Subscriptions).State - example
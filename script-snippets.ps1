# PowerShell script to list all Azure Management Groups

# Login to Azure Account
Connect-AzAccount

$mgmtGroups = Get-AzManagementGroup
foreach ($mgmtGroup in $mgmtGroups)
{
    Get-AzManagementGroupSubscription -GroupName $mgmtGroup.Name | ForEach-Object {
        $subscription = $_
        #$subscriptionId = $subscription.SubscriptionId
        $subscriptionName = $subscription.DisplayName
        $subscriptionState = $subscription.State
        Write-Output "SubscriptionId: $subscriptionId, SubscriptionName: $subscriptionName, State: $subscriptionState"
    }
}

$subscription = Get-AzSubscription -SubscriptionName ${subscriptionName}
Select-AzSubscription -SubscriptionId $subscription.Id

# List all management groups
$mgmtGroups = Get-AzManagementGroup

foreach ($mgmtGroup in $mgmtGroups)
{
    $subscriptions = Get-AzSubscription -ManagementGroupId $mgmtGroup.Id
}

# Continue from the existing script

foreach ($mgmtGroup in $mgmtGroups)
{
    $topLvlMgmtGrp = "17ca67c9-6ef2-4396-89dd-c8a769cc1991"          # Name of the top level management group
    $subscriptions = @() 
    $mgmtGroups = Get-AzManagementGroup -GroupId $topLvlMgmtGrp -Expand -Recurse
    $mgmtGroups


$children = $true
while ($children) {
    $children = $false
    $firstrun = $true
    foreach ($entry in $mgmtGroups) {
        if ($firstrun) {Clear-Variable mgmtGroups ; $firstrun = $false}
        if ($entry.Children.length -gt 0) {
            # Add management group to data that is being looped throught
            $children       = $true
            $mgmtGroups    += $entry.Children
        }
        elseif ($entry.type -ne "Microsoft.Management/managementGroups") {
            # Add subscription to output object
            $subscriptions += New-Object -TypeName psobject -Property ([ordered]@{'DisplayName'=$entry.DisplayName;'SubscriptionID'=$entry.Name})
        }
    }
}

$subscriptions 
}


##==================================================================================================

$topLvlMgmtGrp = "CHANGETHIS"          # Name of the top level management group
$subscriptions = @()                   # Output array

# Collect data from managementgroups
$mgmtGroups = Get-AzManagementGroup -GroupId $topLvlMgmtGrp -Expand -Recurse

$children = $true
while ($children) {
    $children = $false
    $firstrun = $true
    foreach ($entry in $mgmtGroups) {
        if ($firstrun) {Clear-Variable mgmtGroups ; $firstrun = $false}
        if ($entry.Children.length -gt 0) {
            # Add management group to data that is being looped throught
            $children       = $true
            $mgmtGroups    += $entry.Children
        }
        elseif ($entry.type -ne "Microsoft.Management/managementGroups") {
            # Add subscription to output object
            $subscriptions += New-Object -TypeName psobject -Property ([ordered]@{'DisplayName'=$entry.DisplayName;'SubscriptionID'=$entry.Name})
        }
    }
}

$subscriptions
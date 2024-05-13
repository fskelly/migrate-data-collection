# Define the path to the scripts
# If the script is being called from another script, $MyInvocation.MyCommand.Definition will contain the path
# If the script is being run directly, $PSScriptRoot will contain the path
# If neither of the above are true (unlikely), $pwd (present working directory) will be used
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
if ("" -eq $scriptPath) {
    $scriptPath = $PSScriptRoot
}
if ("" -eq $scriptPath) {
    $scriptPath = $pwd
}

# Call the Get-Subscriptions script and capture the returned object
# The dot sourcing operator (.) is used to call the script in the current scope and keep the returned object
$subscriptions = . (Join-Path -Path $scriptPath -ChildPath "get-subscriptions.ps1")
write-host "subscriptions: $subscriptions"
$subscriptions
# Now, $subscriptions contains the object returned from get-subscriptions.ps1

# Call the Get-ResourceGroups script and capture the returned object
$resourceGroups = . (Join-Path -Path $scriptPath -ChildPath "Get-resourcegroups.ps1")

# Call the get-vngexrgatewayandpips.ps1 script and capture the returned array or object
$gatewayResults = . (Join-Path -Path $scriptPath -ChildPath "get-vngexrgatewayandpips.ps1")

# Call the get-resourcesInRG.ps1 script and capture the returned array or object
$resources = . (Join-Path -Path $scriptPath -ChildPath "get-resourcesInRG.ps1")

# Call the get-vnetAndConnectedItems.ps1 script and capture the returned array or object
$vnetsubnets = . (Join-Path -Path $scriptPath -ChildPath "get-vnetAndConnectedItems.ps1")

# Call the get-azuremigrationprojects.ps1 script and capture the returned array or object
$azureMigrateProjects = . (Join-Path -Path $scriptPath -ChildPath "get-azuremigrationprojects.ps1")

# Call the get-storageaccounts.ps1 script and capture the returned array or object
$storageAccounts = . (Join-Path -Path $scriptPath -ChildPath "get-storageaccounts.ps1")

# Remove empty or null items from the arrays
$vnetObjects = $gatewayResults.vnetObjects | Where-Object { $_ -ne $null -and $_ -ne '' }
$subnetObjects = $gatewayResults.SubnetObjects | Where-Object { $_ -ne $null -and $_ -ne '' }
$gwIPObjects = $gatewayResults.GatewayIPObjects | Where-Object { $_ -ne $null -and $_ -ne '' }
$gwObjects = $gatewayResults.GatewayObjects | Where-Object { $_ -ne $null -and $_ -ne '' }
$subnetInfoObjects = $vnetsubnets.subnetObjects | Where-Object { $_ -ne $null -and $_ -ne '' }



foreach ($item in $vnetObjects)
{
    write-host "Vnet Name: $($item.VirtualNetworkName)"
    write-host "Vnet RG: $($item.ResourceGroupName)"
    write-host "Vnet Location: $($item.Location)"
    write-host "Vnet ID: $($item.VirtualNetworkID)"
}
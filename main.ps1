# Main.ps1

# Define the path to the scripts
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
if ("" -eq $scriptPath) {
    $scriptPath = $PSScriptRoot
}
if ("" -eq $scriptPath) {
    $scriptPath = $pwd
}

# Call the Get-Subscriptions script and capture the returned object
$subscriptions = . (Join-Path -Path $scriptPath -ChildPath "get-subscriptions.ps1")
write-host "subscriptions: $subscriptions"
$subscriptions
# Now, $subscriptions contains the object returned from get-subscriptions.ps1

# Call the Get-ResourceGroups scriptcls
$resourceGroups = . (Join-Path -Path $scriptPath -ChildPath "Get-resourcegroups.ps1")

# Call the script and capture the returned array or object
$gatewayResults = . (Join-Path -Path $scriptPath -ChildPath "get-vngexrgatewayandpips.ps1")

# Call the script and capture the returned array or object
$resources = . (Join-Path -Path $scriptPath -ChildPath "get-resourcesInRG.ps1")

$vnetsubnets = . (Join-Path -Path $scriptPath -ChildPath "get-vnetAndConnectedItems.ps1")

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
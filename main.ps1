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
$resourceGroups
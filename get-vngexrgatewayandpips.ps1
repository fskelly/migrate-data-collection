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

# Initialize an array to hold gateway objects
$gwObjects = @()

foreach ($subscription in $subscriptions) {
    try {
        # Select the subscription
        Set-AzContext -SubscriptionId $subscription.Id
        # Get resource groups in the current subscription
        $resourceGroups = Get-AzResourceGroup

        foreach ($resourceGroup in $resourceGroups) {
            Get-AzVirtualNetworkGateway -ResourceGroupName $resourceGroup.ResourceGroupName | ForEach-Object {
                $gwObject = [PSCustomObject]@{
                    GatewayName = $_.Name
                    GatewayType = $_.GatewayType
                    GatewaySKU = $_.Sku.Name
                    GatewayLocation = $_.Location
                    ResourceGroupName = $resourceGroup.ResourceGroupName
                    SubscriptionName = $subscription.Name
                    PublicIPAddressIDs = $_.IpConfigurations.PublicIpAddress
                }
                $gwObjects += $gwObject
            }
        }
    } catch {
    # Write the error to a log file and continue with the script
    Write-ErrorToFile "An unexpected error occurred: $_"
    }
}
try {
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


## $vnetObjects
$subnetObjects = @()
## get connected vnet items
foreach ($vnetObject in $vnetObjects) {
    Write-Output "Processing vnet: $($vnetObject.VirtualNetworkName) in subscription: $($vnetObject.SubscriptionName)"
    $vnet = Get-AzVirtualNetwork -Name $vnetObject.VirtualNetworkName -ResourceGroupName $vnetObject.ResourceGroupName -ExpandResource 'subnets/ipConfigurations'
    # Retrieve subnets for the current VNet
    $subnets = $vnet.Subnets
    $subnets

    # Check if there are multiple subnets
    if ($subnets.Count -gt 1) {
        Write-Output "Multiple subnets found in VNet: $($vnet.Name)"

        # Example action for multiple subnets
        foreach ($subnet in $subnets) {
            Write-Host "Processing subnet: $($subnet.Name)"
            # Add your processing logic here

            # Create a PSObject for the current subnet
            $subnetObject = New-Object PSObject -Property @{
            VirtualNetworkName = $vnet.Name
            Name = $subnet.Name
            AddressPrefix = $subnet.AddressPrefix
            IpConfigurationsCount = ($subnet.IpConfigurations | Measure-Object).Count
            # Add more properties as needed
        }

        # Add the subnet object to the array
        $subnetObjects += $subnetObject

            if ($subnet.IpConfigurations -and $subnet.IpConfigurations.Count -gt 0 -and $subnet.IpConfigurations[0].PrivateIpAddress) {
                Write-Output "Private IP Address is populated: $($subnet.IpConfigurations[0].PrivateIpAddress)"
            } else {
                Write-Warning "Private IP Address is not populated or the IpConfigurations array is empty."
            }

        }
    } elseif ($subnets.Count -eq 1) {
        Write-Host "Single subnet found in VNet: $($vnet.Name)"
        # Processing for a single subnet
        # Add your processing logic here
        $subnet = $subnets[0]

        # Create a PSObject for the current subnet
        $subnetObject = New-Object PSObject -Property @{
            VirtualNetworkName = $vnet.Name
            Name = $subnet.Name
            AddressPrefix = $subnet.AddressPrefix
            IpConfigurationsCount = ($subnet.IpConfigurations | Measure-Object).Count
            # Add more properties as needed
        }

        # Add the subnet object to the array
        $subnetObjects += $subnetObject

        if ($subnet.IpConfigurations -and $subnet.IpConfigurations.Count -gt 0 -and $subnet.IpConfigurations[0].PrivateIpAddress) {
            Write-Output "Private IP Address is populated: $($subnet.IpConfigurations[0].PrivateIpAddress)"
        } else {
            Write-Warning "Private IP Address is not populated or the IpConfigurations array is empty."
        }
    } else {
        Write-Warning "No subnets found in VNet: $($virtualNetwork.Name)"
        # Handle the case where no subnets are present
        # Add your processing logic here
    }
}
$subnetObjects

# Create an empty array to store the new objects
$gatewayIPObjects = @()

# Iterate over the gwObjects array
foreach ($gwObject in $gwObjects) {
    # Get the public IP addresses of the current gateway
    $publicIPAddressIDs = $gwObject.PublicIPAddressIDs

    # Check if the gateway has any public IP addresses
    if ($publicIPAddressIDs -and $publicIPAddressIDs.Count -gt 0) {
        # Iterate over the public IP addresses
        foreach ($publicIPAddressID in $publicIPAddressIDs) {
            $publicIPAddressInfo = Get-AzPublicIpAddress -Name ($publicIPAddressID.id.split("/")[8]) -ResourceGroupName ($publicIPAddressID.id.split("/")[4])
            # Create a new object that contains the gateway name and the public IP address
            $gatewayIPObject = [PSCustomObject]@{
                GatewayName = $gwObject.GatewayName
                PublicIPAddress = $publicIPAddressInfo.IpAddress
            }

            # Add the new object to the array
            $gatewayIPObjects += $gatewayIPObject
        }
    } else {
        Write-Warning "No public IP addresses found for gateway: $($gwObject.GatewayName)"
    }
}

# Output the new objects
$gatewayIPObjects
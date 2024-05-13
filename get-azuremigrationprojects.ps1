# Initialize an array to hold Azure Migrate project objects
$azureMigrateProjectObjects = @()

foreach ($subscription in $subscriptions) {
    # Select the subscription
    Set-AzContext -Subscription $subscription

    # Get all Azure Migrate projects in the subscription
    $azureMigrateProjects = Get-AzResource -ResourceType "Microsoft.Migrate/migrateProjects" -ErrorVariable azureMigrateProjectCheck -ErrorAction SilentlyContinue

    if ($azureMigrateProjectCheck) {
        Write-Error "An error occurred while retrieving the Azure Migrate projects: $azureMigrateProjectCheck"
        Write-ErrorToFile "An error occurred while retrieving the Azure Migrate projects: $azureMigrateProjectCheck"
        #return
    }

    # Add the Azure Migrate projects to the array
    foreach ($project in $azureMigrateProjects) {
        $projectObject = New-Object PSObject -Property @{
            ProjectName = $project.Name
            ResourceGroupName = $project.ResourceGroupName
            Location = $project.Location
            SubscriptionId = $subscription.Id
        }
        $azureMigrateProjectObjects += $projectObject
    }
}

# Output the Azure Migrate project objects
return $azureMigrateProjectObjects
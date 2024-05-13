
# Initialize an array to hold Azure Migrate project objects
$azureMigrateProjectObjects = @()

foreach ($subscription in $subscriptions) {
    # Select the subscription
    Set-AzContext -Subscription $subscription

    # Get all Azure Migrate projects in the subscription
    # Define the query
    $query = "where type == 'microsoft.migrate/migrateprojects' | project name, resourceGroup, location, subscriptionId"

    # Run the query
    $azureMigrateProjects = Search-AzGraph -Query $query -ErrorVariable azureMigrateProjectCheck -ErrorAction SilentlyContinue
    
    # Check if an error occurred while retrieving the Azure Migrate projects
    if ($azureMigrateProjectCheck) {
        Write-Error "An error occurred while retrieving the Azure Migrate projects: $azureMigrateProjectCheck"
        Write-ErrorToFile "An error occurred while retrieving the Azure Migrate projects: $azureMigrateProjectCheck"
        #return
    }

    # Add the Azure Migrate projects to the array
    foreach ($project in $azureMigrateProjects) {
        $projectObject = New-Object PSObject -Property @{
            ProjectName = $project.Name
            ResourceGroupName = $project.ResourceGroup
            Location = $project.Location
            SubscriptionId = $subscription.Id
        }
        $azureMigrateProjectObjects += $projectObject
    }
}

# Output the Azure Migrate project objects
return $azureMigrateProjectObjects
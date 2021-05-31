###
### Change these properties. They are required
### 

# Azure subscription where the policy and a collection of Azure resources would
# be deployed to test the behavior of the policy.
$subscriptionId = "b53326a7-7584-414c-8f60-8fc2df57cee3"

$storageAccountName = "pepolicysaapal"

# Add a short prefix to avoid name collisions with other people using the same 
# script for testing.
$deploymentPrefix = "yxz"

### 
### Optional properties. Modify them if needed.
### 

$ErrorActionPreference = "Stop"

# Not all resources are avaiable on all regions. West Europe or West Central US
# are good locations to evaluate most of them without any issue.
$location = "West Europe"

$networkingResourceGroupName = "pe-net-rg"
$scriptDeploymentResourceGroupName = "pe-temp-rg"
$resourcesResourceGroupName = "pe-res-rg"

$virtualNetworkName = "pe-vnet"
$virtualNetworkAddressPrefix = "10.0.0.0/24" 

$policyName = "Deploy Private Endpoint for supported services"
$policyDisplayName = "Deploy Private Endpoint for supported services"

$resourcesTemplate = ".\common\private-enabled-services.json"
$policyDefinitionFile = ".\2. Deploy Private Endpoint if not exists\Single subscription\dine-privateEndpoint-singleSubscription-policy.json"

$managedIdentityName = "pe-identity"

### 
### Deployment script. Not modify.
### 

Remove-AzPolicyAssignment -Name $policyName -Scope $(Get-AzResourceGroup -Name $resourcesResourceGroupName).ResourceId `

Remove-AzPolicyDefinition -Name $policyName 

Remove-AzRoleAssignment -ObjectId $assignment.Identity.principalId -Scope "/subscriptions/$subscriptionId"

Remove-AzRoleAssignment -ObjectId $identity.PrincipalId -Scope "/subscriptions/$subscriptionId"

Remove-AzUserAssignedIdentity -ResourceGroupName $scriptDeploymentResourceGroupName -Name $managedIdentityName

Remove-AzStorageAccount -ResourceGroupName $scriptDeploymentResourceGroupName -Name $storageAccountName 

Remove-AzVirtualNetwork -ResourceGroupName $networkingResourceGroupName -Name $virtualNetworkName 

Remove-AzResourceGroup -Name $networkingResourceGroupName  -Force
Remove-AzResourceGroup -Name $resourcesResourceGroupName  -Force
Remove-AzResourceGroup -Name $scriptDeploymentResourceGroupName -Force

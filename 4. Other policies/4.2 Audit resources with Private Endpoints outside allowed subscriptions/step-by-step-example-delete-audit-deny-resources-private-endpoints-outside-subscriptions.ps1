###
### Change these properties. They are required
### 

# Azure subscription where the policy and a collection of Azure resources would
# be deployed to test the behavior of the policy.
$subscriptionId = "b53326a7-7584-414c-8f60-8fc2df57cee3"

$storageAccountName = "pepolicysaapal"

# Add a short prefix to avoid name collisions with other people using the same 
# script for testing.
$deploymentPrefix = "zok"

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

$policyName = "Audit resource with Private Endpoint not allowed subscription"
$policyDisplayName = "Audit resource with Private Endpoint not allowed subscription"
$policyDefinitionFile = ".\4. Other policies\4.2 Audit resources with Private Endpoints outside allowed subscriptions\audit-deny-resources-private-endpoints-outside-subscriptions.json"

$policyNamePe = "Deploy Private Endpoint for supported services"
$policyDisplayNamePe = "Deploy Private Endpoint for supported services"
$policyDefinitionFilePe = ".\2. Deploy Private Endpoint if not exists\Single subscription\dine-privateEndpoint-singleSubscription-policy.json"


$resourcesTemplate = ".\common\private-enabled-services.json"
$policyDefinitionFile = ".\2. Deploy Private Endpoint if not exists\Single subscription\dine-privateEndpoint-singleSubscription-policy.json"

$managedIdentityName = "pe-identity"

### 
### Deployment script. Not modify.
### 


$identity = Get-AzUserAssignedIdentity -ResourceGroupName $scriptDeploymentResourceGroupName -Name $managedIdentityName
Remove-AzRoleAssignment -ObjectId $identity.PrincipalId -Scope "/subscriptions/$subscriptionId" -RoleDefinitionName "Reader"

$assignment = Get-AzPolicyAssignment -Name $policyNamePe -Scope $(Get-AzResourceGroup -Name $resourcesResourceGroupName).ResourceId 

Remove-AzRoleAssignment -ObjectId $assignment.Identity.principalId -Scope "/subscriptions/$subscriptionId" -RoleDefinitionName "Contributor"

Remove-AzPolicyAssignment -Name $policyNamePe -Scope $(Get-AzResourceGroup -Name $resourcesResourceGroupName).ResourceId

Remove-AzPolicyDefinition -Name $policyNamePe -Force

Remove-AzPolicyAssignment -Name $policyName -Scope $(Get-AzResourceGroup -Name $networkingResourceGroupName).ResourceId

Remove-AzPolicyDefinition -Name $policyName -Force

Remove-AzUserAssignedIdentity -ResourceGroupName $scriptDeploymentResourceGroupName -Name $managedIdentityName -Force
Remove-AzStorageAccount -ResourceGroupName $scriptDeploymentResourceGroupName -Name $storageAccountName -Force

Remove-AzResourceGroup -Name $networkingResourceGroupName  -Force
Remove-AzResourceGroup -Name $resourcesResourceGroupName  -Force
Remove-AzResourceGroup -Name $scriptDeploymentResourceGroupName -Force

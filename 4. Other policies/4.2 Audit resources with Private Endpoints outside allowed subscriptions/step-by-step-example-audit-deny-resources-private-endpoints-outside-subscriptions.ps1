###
### Change these properties. They are required
### 

# Azure subscription where the policy and a collection of Azure resources would
# be deployed to test the behavior of the policy.
$subscriptionId = "b53326a7-7584-414c-8f60-8fc2df57cee3"

$storageAccountName = "pepolicysapol"

# Add a short prefix to avoid name collisions with other people using the same 
# script for testing.
$deploymentPrefix = "wxz"

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
$policyDisplayName = "Audit resource with Private Endpoint not allowed subscription - 2"
$policyDefinitionFile = ".\4. Other policies\4.2 Audit resources with Private Endpoints outside allowed subscriptions\audit-deny-resources-private-endpoints-outside-subscriptions.json"

$policyNamePe = "Deploy Private Endpoint for supported services"
$policyDisplayNamePe = "Deploy Private Endpoint for supported services"
$policyDefinitionFilePe = ".\2. Deploy Private Endpoint if not exists\Single subscription\dine-privateEndpoint-singleSubscription-policy.json"

$resourcesTemplate = ".\common\private-enabled-services.json"

$managedIdentityName = "pe-identity"

### 
### Deployment script. Not modify.
### 
New-AzResourceGroup -Name $networkingResourceGroupName -Location $location -Force
New-AzResourceGroup -Name $resourcesResourceGroupName -Location $location -Force
New-AzResourceGroup -Name $scriptDeploymentResourceGroupName -Location $location -Force

$subnetConfig = New-AzVirtualNetworkSubnetConfig -Name default -AddressPrefix $virtualNetworkAddressPrefix -PrivateEndpointNetworkPoliciesFlag "Disabled"
New-AzVirtualNetwork -ResourceGroupName $networkingResourceGroupName -Name $virtualNetworkName -Location $location -AddressPrefix $virtualNetworkAddressPrefix -Subnet $subnetConfig

$storageAccount = New-AzStorageAccount -ResourceGroupName $scriptDeploymentResourceGroupName -Name $storageAccountName -SkuName Standard_LRS -Location $location -Kind "Storagev2" -AccessTier "Hot"

$identity = New-AzUserAssignedIdentity -ResourceGroupName $scriptDeploymentResourceGroupName -Name $managedIdentityName
Start-Sleep -Seconds 60
New-AzRoleAssignment -ObjectId $identity.PrincipalId -RoleDefinitionName "Reader" -Scope "/subscriptions/$subscriptionId"

$policyDefinition = New-AzPolicyDefinition -Name $policyNamePe -DisplayName $policyDisplayNamePe -Policy $policyDefinitionFilePe

$assignment = New-AzPolicyAssignment -Name $policyNamePe -DisplayName $policyDisplayNamePe `
                       -Scope $(Get-AzResourceGroup -Name $resourcesResourceGroupName).ResourceId `
                       -PolicyDefinition $policyDefinition `
                       -privateEndpointSubnetId (Get-AzVirtualNetwork -Name $virtualNetworkName -ResourceGroupName $networkingResourceGroupName).Subnets[0].Id `
                       -scriptDeploymentManagedIdentityId $identity.Id `
                       -scriptDeploymentStorageAccountId $storageAccount.Id `
                       -privateEndpointResourceGroupName $networkingResourceGroupName `
                       -scriptDeploymentResourceGroupName $scriptDeploymentResourceGroupName `
                       -AssignIdentity -Location $location

Start-Sleep -Seconds 120
New-AzRoleAssignment -ObjectId $assignment.Identity.principalId -RoleDefinitionName "Contributor" -Scope "/subscriptions/$subscriptionId"

$policyDefinition = New-AzPolicyDefinition -Name $policyName -DisplayName $policyDisplayName -Policy $policyDefinitionFile

$assignment = New-AzPolicyAssignment -Name $policyName -DisplayName $policyDisplayName `
                      -Scope $(Get-AzResourceGroup -Name $resourcesResourceGroupName).ResourceId `
                      -PolicyDefinition $policyDefinition `
                      -allowedSubscriptions @($subscriptionId) `
                      -Location $location


New-AzResourceGroupDeployment -Name ResourceDeploymentForPolicyTesting -ResourceGroupName $resourcesResourceGroupName -TemplateFile $resourcesTemplate -deploymentPrefix $deploymentPrefix -Verbose

Start-AzPolicyRemediation -Name 'RemediationTask' -PolicyAssignmentId "$($assignment.PolicyAssignmentId)" -ResourceGroupName $resourcesResourceGroupName

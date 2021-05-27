### Change these properties. They are required
$subscriptionId = "b53326a7-7584-414c-8f60-8fc2df57cee3"
$storageAccountName = "pepolicysapol"
$deploymentPrefix = "yxz"

### Optional properties
$ErrorActionPreference = "Stop"
$location = "West Europe"

$policyDefinitionFile = ".\dine-pe.json"
$policyName = "Deploy Private Endpoint for supported services"
$policyDisplayName = "Deploy Private Endpoint for supported services"

$resourcesTemplate = ".\private-enabled-services.json"

$networkingResourceGroupName = "pe-net-rg"
$scriptDeploymentResourceGroupName = "pe-temp-rg"
$resourcesResourceGroupName = "pe-res-rg"

$virtualNetworkName = "pe-vnet"
$virtualNetworkAddressPrefix = "10.0.0.0/24" 

$managedIdentityName = "pe-identity"



### Deployment Script

New-AzResourceGroup -Name $networkingResourceGroupName -Location $location
New-AzResourceGroup -Name $resourcesResourceGroupName -Location $location
New-AzResourceGroup -Name $scriptDeploymentResourceGroupName -Location $location

$subnetConfig = New-AzVirtualNetworkSubnetConfig -Name default -AddressPrefix $virtualNetworkAddressPrefix -PrivateEndpointNetworkPoliciesFlag "Disabled"
New-AzVirtualNetwork -ResourceGroupName $networkingResourceGroupName -Name $virtualNetworkName -Location $location -AddressPrefix $virtualNetworkAddressPrefix -Subnet $subnetConfig

$storageAccount = New-AzStorageAccount -ResourceGroupName $scriptDeploymentResourceGroupName -Name $storageAccountName -SkuName Standard_LRS -Location $location -Kind "Storagev2" -AccessTier "Hot"

$identity = New-AzUserAssignedIdentity -ResourceGroupName $scriptDeploymentResourceGroupName -Name $managedIdentityName
Start-Sleep -Seconds 60
New-AzRoleAssignment -ObjectId $identity.PrincipalId -RoleDefinitionName "Reader" -Scope "/subscriptions/$subscriptionId"

$policyDefinition = New-AzPolicyDefinition -Name $policyName -DisplayName $policyDisplayName -Policy $policyDefinitionFile

$assignment = New-AzPolicyAssignment -Name $policyName -DisplayName $policyDisplayName `
                       -Scope $(Get-AzResourceGroup -Name $resourcesResourceGroupName).ResourceId `
                       -PolicyDefinition $policyDefinition `
                       -privateEndpointSubnetId "/subscriptions/474c9bf8-e183-4997-ab26-6920b1169f92/resourceGroups/test-policy-vnet/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/default" `
                       -scriptDeploymentManagedIdentityId $identity.Id `
                       -scriptDeploymentStorageAccountId $storageAccount.Id `
                       -privateEndpointResourceGroupName $networkingResourceGroupName `
                       -scriptDeploymentResourceGroupName $scriptDeploymentResourceGroupName `
                       -subnetManagementGroup "jangelfdez" -subnetSubscriptionId "474c9bf8-e183-4997-ab26-6920b1169f92" `
                       -AssignIdentity -Location $location

Start-Sleep -Seconds 120
New-AzRoleAssignment -ObjectId $assignment.Identity.principalId -RoleDefinitionName "Contributor" -Scope "/subscriptions/$subscriptionId"

New-AzResourceGroupDeployment -Name ResourceDeploymentForPolicyTesting -ResourceGroupName $resourcesResourceGroupName -TemplateFile $resourcesTemplate -deploymentPrefix $deploymentPrefix -Verbose

Start-AzPolicyRemediation -Name 'RemediationTask' -PolicyAssignmentId "$($assignment.PolicyAssignmentId)" -ResourceGroupName $resourcesResourceGroupName


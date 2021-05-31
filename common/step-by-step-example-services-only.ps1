###
### Change these properties. They are required
### 

# Azure subscription where the policy and a collection of Azure resources would
# be deployed to test the behavior of the policy.
$subscriptionId = "b53326a7-7584-414c-8f60-8fc2df57cee3"

$storageAccountName = "pepolicysapol"

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

$resourcesTemplate = ".\common\private-enabled-services.json"

$managedIdentityName = "pe-identity"

### 
### Deployment script. Not modify.
### 

New-AzResourceGroup -Name $networkingResourceGroupName -Location $location
New-AzResourceGroup -Name $resourcesResourceGroupName -Location $location
New-AzResourceGroup -Name $scriptDeploymentResourceGroupName -Location $location

$subnetConfig = New-AzVirtualNetworkSubnetConfig -Name default -AddressPrefix $virtualNetworkAddressPrefix -PrivateEndpointNetworkPoliciesFlag "Disabled"
New-AzVirtualNetwork -ResourceGroupName $networkingResourceGroupName -Name $virtualNetworkName -Location $location -AddressPrefix $virtualNetworkAddressPrefix -Subnet $subnetConfig

$storageAccount = New-AzStorageAccount -ResourceGroupName $scriptDeploymentResourceGroupName -Name $storageAccountName -SkuName Standard_LRS -Location $location -Kind "Storagev2" -AccessTier "Hot"

$identity = New-AzUserAssignedIdentity -ResourceGroupName $scriptDeploymentResourceGroupName -Name $managedIdentityName
Start-Sleep -Seconds 60
New-AzRoleAssignment -ObjectId $identity.PrincipalId -RoleDefinitionName "Reader" -Scope "/subscriptions/$subscriptionId"

New-AzResourceGroupDeployment -Name ResourceDeploymentForPolicyTesting -ResourceGroupName $resourcesResourceGroupName -TemplateFile $resourcesTemplate -deploymentPrefix $deploymentPrefix -Verbose

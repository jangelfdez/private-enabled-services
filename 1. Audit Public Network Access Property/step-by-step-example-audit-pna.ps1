###
### Change these properties. They are required
### 

# Azure subscription where the policy and a collection of Azure resources would
# be deployed to test the behavior of the policy.
$subscriptionId = "b53326a7-7584-414c-8f60-8fc2df57cee3"

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

$policyName = "Audit services with Public Network Access enabled"
$policyDisplayName = "Audit services with Public Network Access enabled"

$resourcesResourceGroupName = "pe-res-rg"

$resourcesTemplate = ".\common\private-enabled-services.json"
$policyDefinitionFile = ".\1. Audit Public Network Access Property\audit-deny-publicNetworkAccess-policy.json"

$resourcesResourceGroupName = "pe-res-rg"

### 
### Deployment script. Not modify.
### 

New-AzResourceGroup -Name $resourcesResourceGroupName -Location $location -Force

$policyDefinition = New-AzPolicyDefinition -Name $policyName -DisplayName $policyDisplayName -Policy $policyDefinitionFile

New-AzPolicyAssignment -Name $policyName -DisplayName $policyDisplayName `
                       -Scope $(Get-AzResourceGroup -Name $resourcesResourceGroupName).ResourceId `
                       -PolicyDefinition $policyDefinition `
                       -Location $location

New-AzResourceGroupDeployment -Name ResourceDeploymentForPolicyTesting -ResourceGroupName $resourcesResourceGroupName -TemplateFile $resourcesTemplate -deploymentPrefix $deploymentPrefix -Verbose

Start-AzPolicyComplianceScan -ResourceGroupName $resourcesResourceGroupName -Verbose
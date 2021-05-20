### Change these properties. They are required
$subscriptionId = "b53326a7-7584-414c-8f60-8fc2df57cee3"
$deploymentPrefix = "yxz"

### Optional properties
$ErrorActionPreference = "Stop"
$location = "West Europe"

$policyDefinitionFile = ".\audit-pna.json"
$policyName = "Audit Public Network Access for supported services"
$policyDisplayName = "Audit Public Network Access for supported services"
$resourcesTemplate = ".\private-enabled-services.json"

$resourcesResourceGroupName = "pe-res-rg"

### Deployment Script
New-AzResourceGroup -Name $resourcesResourceGroupName -Location $location


$policyDefinition = New-AzPolicyDefinition -Name $policyName -DisplayName $policyDisplayName -Policy $policyDefinitionFile

$assignment = New-AzPolicyAssignment -Name $policyName -DisplayName $policyDisplayName `
                       -Scope $(Get-AzResourceGroup -Name $resourcesResourceGroupName).ResourceId `
                       -PolicyDefinition $policyDefinition `
                       -AssignIdentity -Location $location

Start-Sleep -Seconds 120
New-AzRoleAssignment -ObjectId $assignment.Identity.principalId -RoleDefinitionName "Contributor" -Scope "/subscriptions/$subscriptionId"

New-AzResourceGroupDeployment -Name ResourceDeploymentForPolicyTesting -ResourceGroupName $resourcesResourceGroupName -TemplateFile $resourcesTemplate -deploymentPrefix $deploymentPrefix -Verbose

Start-AzPolicyComplianceScan -ResourceGroupName $resourcesResourceGroupName -Verbose
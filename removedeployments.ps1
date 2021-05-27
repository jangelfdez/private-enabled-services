$deployments = Get-AzResourceGroupDeployment -ResourceGroupName ja-one-policy-storage
$deployments | ForEach-Object -Parallel { Remove-AzResourceGroupDeployment -ResourceGroupName ja-one-policy-storage -Name $_.DeploymentName -Verbose} -ThrottleLimit 90


New-AzPolicyDefinition -Name "All PE Policy v2" -Policy ".\dine-pe.json"


New-AzResourceGroupDeployment -Name Private-Endpoints-Test -ResourceGroupName ja-one-policy -TemplateFile '.\private-enabled-services copy.json' -Verbose
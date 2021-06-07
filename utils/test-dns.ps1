$resourcesTest = @("/subscriptions/b53326a7-7584-414c-8f60-8fc2df57cee3/resourcegroups/pe-res-rg/providers/Microsoft.Batch/batchAccounts/aplbatchaccount")
$groupId = "batchAccount"
foreach ($resource in $resourcesTest) {

    $resourceId = $resource

    $apiVersionPath = "/subscriptions/$($resourceId.Split('/')[2])/resourceGroups/$($resourceId.Split('/')[4])/providers/Microsoft.Network/locations/westcentralus/availablePrivateEndpointTypes?api-version=2019-02-01"
    $apiVersion = ((ConvertFrom-Json (Invoke-AzRestMethod -Path $apiVersionPath -Method GET).content).value  | Where-Object resourcename -like "$($resourceId.Split('/')[6])/$($resourceId.Split('/')[7])" | Select apiVersion).apiVersion


    $path = $resourceId + '/privateLinkResources?api-version=' + $apiVersion
    $DeploymentScriptOutputs = @{} 
    $DeploymentScriptOutputs['zoneNames'] = [array]((ConvertFrom-Json (Invoke-AzRestMethod -Path $path -Method GET).Content).value | Where-Object name -EQ $groupId | Select -ExpandProperty Properties).requiredZoneNames

    [array](ConvertFrom-Json (Invoke-AzRestMethod -Path $path -Method GET).Content).value | fl
    Write-Output $DeploymentScriptOutputs['zoneNames']
}
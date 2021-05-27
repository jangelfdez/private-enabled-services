$resourcesTest = @("/subscriptions/b53326a7-7584-414c-8f60-8fc2df57cee3/resourceGroups/ja-one-policy/providers/Microsoft.AppConfiguration/configurationStores/pe-testing-app-config-store")

foreach ($resource in $resourcesTest) {

    $resourceId = $resource

    $apiVersionPath = "/subscriptions/$($resourceId.Split('/')[2])/resourceGroups/$($resourceId.Split('/')[4])/providers/Microsoft.Network/locations/westcentralus/availablePrivateEndpointTypes?api-version=2019-02-01"
    $apiVersion = ((ConvertFrom-Json (Invoke-AzRestMethod -Path $apiVersionPath -Method GET).content).value  | Where-Object resourcename -like "$($resourceId.Split('/')[6])/$($resourceId.Split('/')[7])" | Select apiVersion).apiVersion


    $path = $resourceId + '/privateLinkResources?api-version=' + $apiVersion
    $DeploymentScriptOutputs = @{} 
    $DeploymentScriptOutputs['groupId'] = [array](ConvertFrom-Json (Invoke-AzRestMethod -Path $path -Method GET).Content).value.properties.groupId 

    Write-Output $apiVersionPath
    Write-Output $apiVersion
    Write-Output $path
    Write-Output (Invoke-AzRestMethod -Path $path -Method GET).Content
}

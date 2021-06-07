<# 
Include all resource DNS zones available in our documentation for
services that support Private Endpoints.

 https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-dns#azure-services-dns-zone-configuration

#>

$privateDnsZones = @(
  "privatelink.azure-automation.net",
  "privatelink.database.windows.net",
  "privatelink.sql.azuresynapse.net",
  "privatelink.blob.core.windows.net",
  "privatelink.table.core.windows.net",
  "privatelink.queue.core.windows.net",
  "privatelink.file.core.windows.net",
  "privatelink.web.core.windows.net",
  "privatelink.dfs.core.windows.net",
  "privatelink.documents.azure.com",
  "privatelink.mongo.cosmos.azure.com",
  "privatelink.cassandra.cosmos.azure.com",
  "privatelink.gremlin.cosmos.azure.com",
  "privatelink.table.cosmos.azure.com",
  "privatelink.postgres.database.azure.com",
  "privatelink.mysql.database.azure.com",
  "privatelink.mariadb.database.azure.com",
  "privatelink.vaultcore.azure.net",
  # privatelink.{region}.azmk8s.io",
  "privatelink.search.windows.net",
  "privatelink.azurecr.io",
  "privatelink.azconfig.io",
  # privatelink.{region}.backup.windowsazure.com",
  # {region}.privatelink.siterecovery.windowsazure.com",
  "privatelink.servicebus.windows.net",
  "privatelink.azure-devices.net",
  "privatelink.eventgrid.azure.net",
  "privatelink.azurewebsites.net",
  "privatelink.api.azureml.ms",
  "privatelink.notebooks.azure.net",
  "privatelink.service.signalr.net",
  "privatelink.monitor.azure.com",
  "privatelink.oms.opinsights.azure.com",
  "privatelink.ods.opinsights.azure.com",
  "privatelink.agentsvc.azure-automation.net",
  "privatelink.cognitiveservices.azure.com",
  "privatelink.afs.azure.net",
  "privatelink.datafactory.azure.net",
  "privatelink.adf.azure.com",
  "privatelink.redis.cache.windows.net",
  "privatelink.azure-devices-provisioning.net",
  "privatelink.digitaltwins.azure.net",
  "privatelink.prod.migration.windowsazure.com"
)

$resources = New-Object -TypeName "System.Collections.ArrayList"

foreach ($privateDnsZone in $privateDnsZones) {

  $resource = @"
    {
      "type": "Microsoft.Network/privateDnsZones",
      "apiVersion": "2020-06-01",
      "name": "$privateDnsZone",
      "location": "global",
    }
"@

  $resources.Add($(ConvertFrom-Json -Depth 5 $resource))
}

$template = @"
{
  "`$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "resources": 
    $(ConvertTo-Json -Depth 10 $resources)
  
}
"@

Out-File -FilePath ".\3. Configure Private Endpoint DNS\private-dns-zones-private-enabled-services.json" -Encoding utf8 -InputObject $template
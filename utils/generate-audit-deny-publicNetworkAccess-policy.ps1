
$supportedServices = @(
  "Microsoft.AppConfiguration/configurationStores",
  "Microsoft.Automation/automationAccounts",
  "Microsoft.Batch/batchAccounts",
  "Microsoft.Cache/Redis",
  "Microsoft.CognitiveServices/accounts",
  "Microsoft.ContainerRegistry/registries",
  "Microsoft.DataFactory/factories",
  "Microsoft.DBforMariaDB/servers",
  "Microsoft.DBForMySql/flexibleServers",
  "Microsoft.DBforMySQL/servers",
  "Microsoft.DBForPostgreSql/flexibleServers",
  "Microsoft.DBforPostgreSQL/servers",
  "Microsoft.Devices/IotHubs",
  "Microsoft.Devices/provisioningServices",
  "Microsoft.DigitalTwins/digitalTwinsInstances",
  "Microsoft.DocumentDB/databaseAccounts",
  "Microsoft.EventGrid/domains",
  "Microsoft.EventGrid/topics",
  "Microsoft.HealthcareApis/services",
  "Microsoft.HybridCompute/privateLinkScopes",
  "Microsoft.Migrate/assessmentProjects",
  "Microsoft.Purview/accounts",
  "Microsoft.Search/searchServices",
  "Microsoft.SignalRService/webPubSub",
  "Microsoft.Sql/servers",
  "Microsoft.Synapse/workspaces",
  "Microsoft.Web/sites/config",
  "Microsoft.Web/sites/slots/config"
)

$anyOf = New-Object -TypeName "System.Collections.ArrayList"

foreach ($service in $supportedServices) {

  $condition1 = New-Object -TypeName psobject
  $condition1 | Add-Member -MemberType NoteProperty -Name "field" -Value "type"
  $condition1 | Add-Member -MemberType NoteProperty -Name "equals" -Value $service -Force

  $condition2 = New-Object -TypeName psobject
  $condition2 | Add-Member -MemberType NoteProperty -Name "field" -Value "$service/publicNetworkAccess"
  $condition2 | Add-Member -MemberType NoteProperty -Name "equals" -Value "Enabled" -Force
  
  $allOf = New-Object -TypeName psobject
  $allOf | Add-Member -MemberType NoteProperty -Name "allOf" -Value @($condition1, $condition2)
  
  $anyOf.Add($allOf)
}

$policyJson = @"
{
	"mode": "All",
	"policyRule": {
		"if": {
			"anyOf": $(ConvertTo-Json -Depth 5 $anyOf)
		},
		"then": {
			"effect": "[parameters('effect')]"
		}
	},
	"parameters": {
		"effect":{
			"type": "String",
			"metadata": {
				"displayName": "Select the effect of this policy",
				"description": "Configures the effect of this policy. Default value is Audit."
			},
			"defaultValue": "Audit",
			"allowedValues": [
				"Audit",
				"Disabled"
			]
		}
	}
}
"@

Out-File -FilePath ".\audit-deny-publicNetworkAccess.json" -Encoding utf8 -InputObject $policyJson
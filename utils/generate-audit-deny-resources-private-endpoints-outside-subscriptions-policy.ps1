
$supportedServices = @(
	"Microsoft.AppConfiguration/configurationStores",
	"Microsoft.Automation/automationAccounts",
	"Microsoft.Batch/batchAccounts",
	"Microsoft.Cache/Redis",
	"Microsoft.Cache/redisEnterprise",
	"Microsoft.CognitiveServices/accounts",
	"Microsoft.Compute/diskAccesses",
	"Microsoft.ContainerRegistry/registries",
	"Microsoft.ContainerService/managedClusters",
	"Microsoft.DataFactory/factories",
	"Microsoft.DBforMariaDB/servers",
	"Microsoft.DBforMySQL/servers",
	"Microsoft.DBforPostgreSQL/servers",
	"Microsoft.Devices/IotHubs",
	"Microsoft.Devices/ProvisioningServices",
	"Microsoft.DigitalTwins/digitalTwinsInstances",
	"Microsoft.DocumentDB/databaseAccounts",
	"Microsoft.EventGrid/domains",
	"Microsoft.EventGrid/topics",
	"Microsoft.EventHub/namespaces",
	"Microsoft.HealthcareApis/services",
	"Microsoft.Insights/privateLinkScopes",
	"Microsoft.KeyVault/vaults",
	"Microsoft.MachineLearningServices/workspaces",
	"Microsoft.Migrate/assessmentProjects",
	"Microsoft.Migrate/migrateProjects",
	"Microsoft.Network/applicationgateways",
	"Microsoft.Network/privateLinkServices",
	"Microsoft.OffAzure/mastersites",
	"Microsoft.PowerBI/privateLinkServicesForPowerBI",
	"Microsoft.Purview/accounts",
	"Microsoft.RecoveryServices/vaults",
	"Microsoft.Relay/namespaces",
	"Microsoft.Search/searchServices",
	"Microsoft.ServiceBus/namespaces",
	"Microsoft.SignalRService/SignalR",
	"Microsoft.Sql/servers",
	"Microsoft.Storage/storageAccounts",
	"Microsoft.StorageSync/storageSyncServices",
	"Microsoft.Synapse/privateLinkHubs",
	"Microsoft.Synapse/workspaces",
	"Microsoft.TimeSeriesInsights/environments",
	"Microsoft.Web/hostingEnvironments",
	"Microsoft.Web/sites"
)

$anyOf = New-Object -TypeName "System.Collections.ArrayList"

foreach ($service in $supportedServices) {

	$condition = @"
		{	"allOf": [
				{
					"field": "type",
					"equals": "$service"
				},
				{
					"anyOf": [
						{
							"value": "[split('field($service/privateLinkServiceConnections[*].privateLinkServiceId'), '/')[2]]",
							"notIn": "[parameters('allowedSubscriptions')]"
						},
						{
							"value": "[split('field($service/manualPrivateLinkServiceConnections[*].privateLinkServiceId'), '/')[2]]",
							"notIn": "[parameters('allowedSubscriptions')]"
						}
					]
				}
			]}
"@
	$anyOf.Add($(ConvertFrom-Json -Depth 10 $condition))
}

$policyJson = @"
{
	"mode": "All",
	"policyRule": {
		"if": {
			"anyOf": $(ConvertTo-Json -Depth 10 $anyOf)
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
				"Deny",
				"Disabled"
			]
		},
		"allowedSubscriptions": {
			"type": "Array",
			"metadata": {
				"displayName": "Allowed subscriptions",
				"description": "List of subscriptions that contain resources allowed as a target for a Private Endpoint"
			}
		}
	}
}
"@

Out-File -FilePath ".\audit-deny-resources-private-endpoints-outside-subscriptions.json" -Encoding utf8 -InputObject $policyJson
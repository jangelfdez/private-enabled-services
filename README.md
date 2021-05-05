# Private Endpoint - Deploy if not exist policy

This policy provides support to automatically create private endpoints for all the services that support it inside your environment.

## Pre-requisities

- A subnet where the private endpoints would be deployed.
- A resource group where private endpoints and their associated NIC objects would be created.
- A resource group where the resources associated with the Azure Deployment Script included in this policy would be temporarily created.
- A User Managed Identity with Read access at the scope where the policy would be applied (i.e. Subscription Reader)
- A storage account where temporal resources would be created by the Azure Deployment Script included in this policy.

## Important considerations

- Managed Identity created automatically by Azure Policy for the remediation tasks has only access to the scope where the policy is being applied. You should assign this managed identity access to the subscription as a contributor to be able to deploy the resources cross-resource group if the Policy scope is not assigned at the subscription level.
- Resource group where the resources associated with the Azure Deployment Script are deployed should be excluded from the policy evaluation. It could generate an inifinite loop of deployments of this policy.

## Step-by-step scenario

You can deploy a reference scenario from scratch using the [step-by-step-example.ps1](step-by-step-example.ps1) script. It  follows the next steps:

1. Create three resources group to:
    - Group all networking resources.
    - Deploy required resources for the policy.
    - Deploy every resource that support Private Endpoint to evaluate the policy.
2. Create a virtual network with a default subnet with *privateEndpointNetworkPolicies* property disabled.
3. Create a storage account and a managed identity used by the policy.
4. Create the policy an assigment with a scope associated to the resource group where Azure services are deployed.
5. Assign the proper RBAC permissions to managed identitys.
6. Deploy the resources.

After that, you should wait till the Policy is trigerred and your private endpoints would be created in your networking resource group.

## Policy configuration

### Required parameters

- *privateEndpointResourceGroupName*
  - "type": "string",
  - "displayName": "Resource group where private endpoints would be created",
  - "description": "Private endpoints and their associate network interfaces would be deployed inside this specific resource group."

- *privateEndpointSubnetId*
  - "type": "String",
  - "displayName": "Private endpoint subnet id where Private Endpoints would be created",
  - "description": "Subnet where all resources associated with the private endpoint would be created. Subnet should have the private endpoint network policies property disabled.",
  - "strongType": "Microsoft.Network/virtualNetworks/subnets"

- *excludedPrivateEndpointResourceTypes*
  - "type": "Array",
  - "displayName": "Group Ids excluded from private endpoint creation",
  - "description": "A list of the group ids that you are not interested in creating a private endpoint automatically"

- *scriptDeploymentResourceGroupName*
  - "type": "string",
  - "displayName": "Resource group where temporary resources would be created",
  - "description": "Deployment Scripts associated resources would be deployed inside this specific resource group."

- *scriptDeploymentStorageAccountName*
  - "type": "String",
  - "displayName": "Storage account where required scripts by this policy would be stored.",
  - "description": "This policy uses Azure Resource Manager Deployment Scripts to automatically configure your private endpoints associated with the resources defined by parameter  privateLinkAvailableResourceTypes. Deployment Scripts requires an storage account to store its temporal data.",
  - "strongType": "Microsoft.Storage/storageaccounts"

- *scriptDeploymentManagedIdentityId*
  - "type": "String",
  - "displayName": "Managed Identity resource id required to deploy your private endpoints",
  - "description": "Your managed identity is used to query the required information in your subscription to automatically configure your private endpoints associated with the resources defiined by parameter privateLinkAvailableResourceTypes. It should be defined in the following format /subscriptions/[Subscription Id]/resourceGroups/[Resource Group]/providers/Microsoft.ManagedIdentity/userAssignedIdentities/[UserManagedIdentityName]"

### Optional parameters

- *privateEndpointNamePrefix*
  - "type": "String",
  - "displayName": "Private Endpoint Name Prefix",
  - "description": "A prefix used to configure the private endpoint name. Suffix is automatically generated as a combination of the resource group and subnet name"

- *privateLinkAvailableResourceTypes*
  - "type": "Array",
  - "displayName": "Resource types available to be evaluated",
  - "description": "Collection of resource types that would be automatically configured with a private endpoint using this policy if is not in the exclude list defined by parameter excludedPrivateEndpointResourceTypes"

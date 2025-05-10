targetScope = 'managementGroup'

param appName string = 'policy'
param environment string
param subscriptionId string

var policyResourceGroupName = '${appName}-${environment}'
var azureRoles = loadJsonContent('../../AzureRoleDefinitions.json')

module policyResourceGroup 'modules/resourceGroup.bicep' = {
  scope: subscription(subscriptionId)
  name: '${appName}-resourceGroup'
  params: {
    location: deployment().location
    resourceGroupName: policyResourceGroupName
  }
}

module uami 'modules/userAssignedManagedIdentity.bicep' = {
  scope: resourceGroup(subscriptionId, policyResourceGroupName)
  dependsOn: [
    policyResourceGroup
  ]
  name: '${appName}-identity'
  params: {
    environment: environment
    appName: appName
    location: deployment().location
  }
}

module rbac 'modules/roleAssignment.bicep' = {
  name: '${appName}-identity-rbac'
  params: {
    principlesId: uami.outputs.principalId
    roleDefinitions: [
      azureRoles.Contributor
    ]
  }
}

output GitHubRepositoryVariables object = {
  POLICY_IDENTITY_RESOURCE_ID: uami.outputs.resourceId
}

output tmp object = {
  foo: 'bar'
  foobar: 42
}

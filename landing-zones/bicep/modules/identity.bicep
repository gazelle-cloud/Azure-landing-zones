targetScope = 'subscription'

param appName string
param environment string
param location string
param githubOrganizationName string
param githubRepoName string
param landingzoneResourceGroupName string
param appEngineerEntraGroupId string
param appEngineerRoleDefinitionId string

module identity 'br/public:avm/res/managed-identity/user-assigned-identity:0.2.1' = {
  scope: az.resourceGroup(landingzoneResourceGroupName)
  name: 'lz-serviceConnection'
  params: {
    name: 'id-${appName}-${environment}'
    location: location
    federatedIdentityCredentials: [
      {
        name: 'landingzoneOwner'
        audiences: [
          'api://AzureADTokenExchange'
        ]
        issuer: 'https://token.actions.githubusercontent.com'
        subject: 'repo:${githubOrganizationName}/${githubRepoName}:environment:${environment}'
      }
    ]
  }
}

module rbacLandingzoneOwner 'base/roleAssignments-subscription.bicep' = {
  name: 'lz-rbac-serviceConnection'
  params: {
    principalId: identity.outputs.principalId
    roleDefinitionId: roleDefinitions('Owner').id
    principleType: 'ServicePrincipal'
  }
}

module rbacApplicationReader 'base/roleAssignments-subscription.bicep' = {
  name: 'lz-rbac-applicationReader'
  params: {
    principalId: appEngineerEntraGroupId
    roleDefinitionId: appEngineerRoleDefinitionId
    principleType: 'Group'
  }
}

output clientId string = identity.outputs.clientId
output principalId string = identity.outputs.principalId
output resourceId string = identity.outputs.resourceId

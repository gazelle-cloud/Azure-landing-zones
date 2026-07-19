using '../bicep/accessControl.bicep'

param topLevelManagementGroupName = readEnvironmentVariable('TOP_LEVEL_MANAGEMENT_GROUP_NAME', '')
param azurePlatformEngineerGroupId = readEnvironmentVariable('AZURE_PLATFORM_ENGINEER_GROUP_ID', '')
param azurePlatformOwnerGroupId = readEnvironmentVariable('AZURE_PLATFORM_OWNER_GROUP_ID', '')
param subscriptionBankName = readEnvironmentVariable('SUBSCRIPTION_BANK_NAME', '')
param applicationEngineersGroupId = readEnvironmentVariable('APPLICATION_ENGINEERS_GROUP_ID', '')
param appEngineerRoleActions = [
  '*/read'
]
param accessControlMgmtLevel = [
  {
    roleName: 'Platform Engineer'
    actions: [
      '*/read'
      'Microsoft.App/jobs/*/action'
      'Microsoft.Insights/actiongroups/*/action'
      'microsoft.policyinsights/remediations/write'
      'Microsoft.Insights/alertRules/*'
      'Microsoft.Resources/deployments/*'
      'Microsoft.Resources/deploymentStacks/*'
    ]
    principalId: azurePlatformEngineerGroupId
    scope: topLevelManagementGroupName
  }
  {
    roleName: 'Platform Owner'
    actions: [
      '*'
    ]
    principalId: azurePlatformOwnerGroupId
    scope: topLevelManagementGroupName
  }
]
param subscriptionBankReader = [
  applicationEngineersGroupId
  azurePlatformEngineerGroupId
]

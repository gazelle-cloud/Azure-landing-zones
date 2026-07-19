param jobName string
param location string
param environment string
param environmentId string
param GitHubOrganizationName string
param userAssignedIdentityResourceId string
param userAssignedIdentityClientId string
param containerEnvironmentVariables containerEnv
param cronExpression string = '0 3 * * *'

var image = 'ghcr.io/${GitHubOrganizationName}/automation:${environment}'
var automationJob = toLower(jobName)

var vars = union(containerEnvironmentVariables, [
  {
    name: 'identityClientId'
    value: userAssignedIdentityClientId
  }
  {
    name: 'subscriptionId'
    value: subscription().subscriptionId
  }
])

resource job 'Microsoft.App/jobs@2026-01-01' = {
  name: 'cron-${automationJob}'
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentityResourceId}': {}
    }
  }
  properties: {
    environmentId: environmentId
    workloadProfileName: 'Consumption'
    configuration: {
      replicaTimeout: 300
      triggerType: 'Schedule'
      scheduleTriggerConfig: {
        cronExpression: cronExpression
        parallelism: 1
        replicaCompletionCount: 1
      }
    }
    template: {
      containers: [
        {
          image: image
          name: automationJob
          args: [
            '${jobName}.ps1'
          ]
          resources: {
            cpu: json('0.5')
            memory: '1Gi'
          }
          env: vars
        }
      ]
    }
  }
}

type containerEnv = envObjects[]

type envObjects = {
  name: string
  value: string
}

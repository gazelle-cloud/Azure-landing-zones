param jobName string
param location string
param environment string
param environmentId string
param userAssignedIdentityResourceId string
param image string = 'ghcr.io/gazelle-cloud/automation:${environment}'
param containerEnvironmentVariables env?
param cronExpression string = '0 3 * * *'

var pwshScriptName = '${jobName}.ps1'

resource job 'Microsoft.App/jobs@2024-10-02-preview' = {
  name: jobName
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
          imageType: 'ContainerImage'
          name: jobName
          args: [
            pwshScriptName
          ]
          resources: {
            cpu: json('0.5')
            memory: '1Gi'
          }
          env: containerEnvironmentVariables
        }
      ]
    }
  }
}

type env = envObjects[]

type envObjects = {
  name: string
  value: string
}

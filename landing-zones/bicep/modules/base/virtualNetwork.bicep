param appName string
param environment string
param location string
param vnetAddressSpace array
param GitHubOrganizationDatabaseId string

var extractIp = first(split(vnetAddressSpace[0],'/'))
var GitHubRunnersSubnet = '${extractIp}/28'

resource vnet 'Microsoft.Network/virtualNetworks@2025-07-01' = {
  name: 'vnet-${appName}-${environment}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: vnetAddressSpace
    }
  }
}

resource GithubRunnersSubnet 'Microsoft.Network/virtualNetworks/subnets@2025-07-01' = {
  name: 'github-runners'
  parent: vnet
  properties: {
    addressPrefixes: [
      GitHubRunnersSubnet
    ]
    serviceEndpoints: [
      {
        locations: [
          location
        ]
        service: 'Microsoft.Storage'
      }
    ]
    delegations: [
      {
        name: 'github-runners'
        properties: {
          serviceName: 'GitHub.Network/networkSettings'
        }
      }
    ]
  }
}

resource GitHubRunnersNetwork 'GitHub.Network/networkSettings@2024-04-02' = {
  name: '${appName}-${environment}'
  location: location
  properties: {
    subnetId: GithubRunnersSubnet.id
    businessId: GitHubOrganizationDatabaseId
  }
}

output resourceId string = vnet.id
output GitHubNetworkId string = GitHubRunnersNetwork.tags.GitHubId
output GitHubSubnetResourceId string = GithubRunnersSubnet.id

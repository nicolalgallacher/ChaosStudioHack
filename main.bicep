//
//
//
//

targetScope ='subscription'

param location string = deployment().location
var resourceGroupName = 'ChaosHack'

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
}

param vNetName string = 'vNet1'
param addressPrefix string = '10.0.0.0/16'
param subnets array

module vNetSetup 'vNet_subnets.bicep' = {
  scope: resourceGroup
  name: 'vNetNameDeploy'
  params: {
    vNetName: vNetName
    addressPrefixes: addressPrefix
    subnets: subnets
    location: location
  }
}



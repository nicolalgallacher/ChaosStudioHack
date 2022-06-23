//
//  
//

param vNetName string
param addressPrefixes string

param subnets array
param location string

param lbSubnetName string

resource vNet 'Microsoft.Network/virtualNetworks@2021-08-01' = {
  name: vNetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefixes
      ]
    }
  }
}
  
@batchSize(1)
resource Subnets 'Microsoft.Network/virtualNetworks/subnets@2021-08-01' = [for (sn, index) in subnets : {
  parent: vNet
  name: sn.name
  properties: {
    addressPrefix: sn.subnetPrefix
  } 
  //dependsOn: [vNet]
}]

output lbSubnetID string = resourceId('Microsoft.Network/VirtualNetworks/subnets', vNetName, lbSubnetName)

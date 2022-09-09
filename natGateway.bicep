
//
// Not currently in use but tested to create a NAT Gateway 
// with assosicated public IP
//
//

param location string

resource natGwIP 'Microsoft.Network/publicIPAddresses@2022-01-01' = {
  name: 'natgatewayIP' 
  location: location
   sku: {
     name: 'Standard'
   }
    properties: {
       publicIPAddressVersion: 'IPv4'
        publicIPAllocationMethod: 'Static'
        idleTimeoutInMinutes: 4
    }

}

resource natgateway 'Microsoft.Network/natGateways@2021-05-01' = {
  name: 'natgatewayChaos'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    idleTimeoutInMinutes: 4
    publicIpAddresses: [
      {
        id: natGwIP.id
      }
    ]
  }
}

output natgatewayID string = natgateway.id

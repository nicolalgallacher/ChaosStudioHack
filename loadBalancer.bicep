//
//
//

param location string 
param loadBalancerName string
var lbSku = 'Standard'

//param vNetName string
//param lbSubnetName string

var lbpublicIPname = 'lbpublicIP'
var backendPoolName = 'webAppsPool'

//param lbSubnetID string 

resource publicIP 'Microsoft.Network/publicIPAddresses@2021-08-01' = {
  name: lbpublicIPname 
  location: location
  sku: {
    name: lbSku
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
}

resource loadBalancer 'Microsoft.Network/loadBalancers@2021-08-01' = {
  name: loadBalancerName
  location: location
  sku: {
    name:lbSku
  }
  properties: {
    frontendIPConfigurations: [
      {
        properties:{
          publicIPAddress: {
            id: publicIP.id
          }
        }
        name: 'loadBalancerFrontEnd'
      }
    ]
    backendAddressPools: [
      {
        name: backendPoolName 
      }
    ]
    loadBalancingRules: [
      {
        name: 'defaultRule'
        properties: {
          frontendIPConfiguration: {
            id: publicIP.id
          }
          backendAddressPool: {
            id:  resourceId('Microsoft.Network/loadBalancers/backendAddressPools', loadBalancerName, backendPoolName)
          }
          frontendPort: 80
          protocol: 'Tcp'
        }
      }
    ]
    probes: [
      {
        properties: {
          port: 80
          protocol: 'Tcp'
        }
        name: 'lbProbe'
      }
    ]
  }
  dependsOn: [
    publicIP
  ]
}

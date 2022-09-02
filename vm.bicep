//
//
//

//param vmName string
param location string 


param vmSize string
param imagePublisher string
param imageOffer string
param imageSku string

param poolSubnetID string

var vmNicName = 'nic1' 

var adminPass = 'Chaos999!'
var adminUser = 'AzureAdmin'

var vmName = 'vmchaos'



@batchSize(1)
resource vmNic 'Microsoft.Network/networkInterfaces@2021-08-01' = [for i in range(0,3): {
  name: '${vmNicName}-${i}'
  location: location
  properties: {
    ipConfigurations: [
       {
        name: '${vmNicName}-${i}IPconfig'
         properties: {
          privateIPAddress: '10.0.2.${i+5}'
          privateIPAddressVersion: 'IPv4'
          privateIPAllocationMethod: 'Static'
          subnet: {
             id: poolSubnetID
          }
        }
       }
    ]
  }
}]

@batchSize(1)
resource virtualMachine 'Microsoft.Compute/virtualMachines@2022-03-01' = [for i in range(0,3): {
  name: '${vmName}-${i}'
  location: location 
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    } 
    storageProfile: {
      imageReference: {
        publisher: imagePublisher
        offer: imageOffer
        sku: imageSku
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
       }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: resourceId('Microsoft.Network/networkInterfaces', '${vmNicName}-${i}')
        }
      ]
    }
    osProfile: {
      computerName: vmName
      adminPassword: adminPass
      adminUsername: adminUser
    }
    
    // windowsConfiguration: {
    //   enableAutomaticUpdates: true
    //   provisionVMAgent: true
    // }
  }
  dependsOn: [
    vmNic
  ]
}]


////

// resource projectName_vm_1 'Microsoft.Compute/virtualMachines@2020-06-01' = [for i in range(0, 3): {
//   name: '${projectName}-vm${(i + 1)}'
//   location: location
//   zones: [
//     (i + 1)
//   ]
//   properties: {
//     hardwareProfile: {
//       vmSize: vmSize
//     }
//     storageProfile: {
//       imageReference: {
//         publisher: 'MicrosoftWindowsServer'
//         offer: 'WindowsServer'
//         sku: '2019-Datacenter'
//         version: 'latest'
//       }
//       osDisk: {
//         createOption: 'FromImage'
//         managedDisk: {
//           storageAccountType: vmStorageAccountType
//         }
//       }
//     }
//     networkProfile: {
//       networkInterfaces: [
//         {
//           id: resourceId('Microsoft.Network/networkInterfaces', '${projectName}-vm${(i + 1)}-networkInterface')
//         }
//       ]
//     }
//     osProfile: {
//       computerName: '${projectName}-vm${(i + 1)}'
//       adminUsername: adminUsername
//       adminPassword: adminPassword
//       windowsConfiguration: {
//         enableAutomaticUpdates: true
//         provisionVMAgent: true
//       }
//     }
//   }
//   dependsOn: [
//     projectName_vm_1_networkInterface
//   ]
// }]

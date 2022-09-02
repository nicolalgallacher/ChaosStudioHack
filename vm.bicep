//
//
//

//param vmName string
param location string 


param vmSize string
param imagePublisher string
param imageOffer string
param imageSku string

param backendPoolID string
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
          //I feel this should be changed out into an if statement to make it more resusable
          loadBalancerBackendAddressPools: [
             {
               id: backendPoolID
             }
          ]
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


@batchSize(1)
resource InstallWebServer 'Microsoft.Compute/virtualMachines/extensions@2021-11-01' = [for i in range(0, 3): {
  name: '${vmName}-${i}/InstallWebServer'
  location: location
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.7'
    autoUpgradeMinorVersion: true
    settings: {
      commandToExecute: 'powershell.exe Install-WindowsFeature -name Web-Server -IncludeManagementTools && powershell.exe remove-item \'C:\\inetpub\\wwwroot\\iisstart.htm\' && powershell.exe Add-Content -Path \'C:\\inetpub\\wwwroot\\iisstart.htm\' -Value $(\'Hello World from \' + $env:computername)'
    }
  }
  dependsOn: [
    virtualMachine
    vmNic
  ]
}]

////


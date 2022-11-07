#PowerCLIインストール
#本件証はver12.7
#https://www.powershellgallery.com/packages/VMware.PowerCLI/12.7.0.20091289
#Install-Module -Name VMware.PowerCLI -Force -SkipPublisherCheck

#変数宣言
$Report = New-Object System.Collections.ArrayList
$DateTime = $((Get-Date).ToString('yyyy-MM-dd_hh-mm-ss'))

#初期パラメータ
$csvpath = 'C:\Users\moikawa\Documents\GitHub\Powershell\vSphere\esxi-param_'+"$DateTime"+'.csv'
$vcip = 'xxx.xx.xx.xx'
$vcadmin = 'administrator@vsphere.local'
$vcpass = 'xxxxxxxxxxxxxxxx'

Connect-VIServer -Server $vcip -Protocol https -User $vcadmin -Password $vcpass -Force







#GetHostList
$DC = Get-Datacenter | Select-Object Name
$ListOfVMHosts = Get-Datacenter $DC.Name | Get-VMHost | Sort-Object Name

# ホスト情報の入手
$Count = $ListOfVMHosts.Count
$Counter = 1

Foreach($VMHost in $ListOfVMHosts) {    
    $HostNetwork = $VMHost |  Get-VMHostNetwork
    $HostNetworkvMotionAdapter = $VMHost |  Get-VMHostNetworkAdapter -VMKernel |  Where-Object { $_.VMotionEnabled -eq $true }
    $HostNetworkManagementTrafficAdapter = $VMHost |  Get-VMHostNetworkAdapter -VMKernel |  Where-Object { $_.ManagementTrafficEnabled -eq $true }
    $HostNetworkvSANTrafficAdapter = $VMHost |  Get-VMHostNetworkAdapter -VMKernel |  Where-Object { $_.VsanTrafficEnabled -eq $true }
    $MemoryTotalGB = [math]::Round($VMHost.MemoryTotalGB)
    $NTP = $VMHost | Get-VMHostNtpServer
    $Hoststorages = $VMHost | Get-VMHostStorage
    $Hostdatastore = $Hoststorages.FileSystemVolumeInfo
    
    $Object = [PSCustomObject]@{
                vCenter          = $VMHost.Uid.Substring($VMHost.Uid.IndexOf('@') + 1).Split(":")[0]
                DataCenter       = ($VMHost | Get-Datacenter)
                Cluster          = $VMHost.Parent
                HostName         = $VMHost.Name
                Manufacturer     = $VMHost.Manufacturer
                Model            = $VMHost.Model
                Processor        = $VMHost.ProcessorType
                MemoryGB         = $MemoryTotalGB
                ESXVersion       = $VMHost.ExtensionData.Summary.Config.Product.FullName
                ESXLicenseKey    = $VMHost.LicenseKey
                DNS1             = $HostNetwork.DnsAddress[0]
                DNS2             = $HostNetwork.DnsAddress[1]
                Gateway          = $HostNetwork.VMKernelGateway
                ManagementDevice = $HostNetworkManagementTrafficAdapter.name
                ManagementIP     = $HostNetworkManagementTrafficAdapter.ip
                ManagementMTU    = $HostNetworkManagementTrafficAdapter.mtu
                vMotionDevice    = $HostNetworkvMotionAdapter.name
                vMotionIP        = $HostNetworkvMotionAdapter.ip
                vMotionMTU       = $HostNetworkvMotionAdapter.mtu
                vSANDevice       = $HostNetworkvSANTrafficAdapter.name
                vSANIP           = $HostNetworkvSANTrafficAdapter.ip
                vSANMTU          = $HostNetworkvSANTrafficAdapter.mtu
                NTP              = $NTP
                DSName           = $Hostdatastore.Name[0]
                DSCapacity       = $Hostdatastore.CapacityGB[0]
                DSPath           = $Hostdatastore.Path[0]
                DSName1           = $Hostdatastore.Name[1]
                DSCapacity1       = $Hostdatastore.CapacityGB[1]
                DSPath1           = $Hostdatastore.Path[1]
                DSName2           = $Hostdatastore.Name[2]
                DSCapacity2       = $Hostdatastore.CapacityGB[2]
                DSPath2           = $Hostdatastore.Path[2]
                DSName3           = $Hostdatastore.Name[3]
                DSCapacity3       = $Hostdatastore.CapacityGB[3]
                DSPath3           = $Hostdatastore.Path[3]
                DSName4           = $Hostdatastore.Name[4]
                DSCapacity4       = $Hostdatastore.CapacityGB[4]
                DSPath4           = $Hostdatastore.Path[4]

            }

    $Report.add($Object) | Out-Null    
    } 
    $Counter++
#$Report

$Report | Export-Csv $csvpath -NoTypeInformation -UseCulture

$DefaultVIServers | Disconnect-VIServer -Confirm:$false

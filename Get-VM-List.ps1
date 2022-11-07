#PowerCLIインストール
#本件証はver12.7
#https://www.powershellgallery.com/packages/VMware.PowerCLI/12.7.0.20091289
#Install-Module -Name VMware.PowerCLI -Force -SkipPublisherCheck

#変数宣言
$Report = New-Object System.Collections.ArrayList
$DateTime = $((Get-Date).ToString('yyyy-MM-dd_hh-mm-ss'))

#初期パラメータ
$logpath = 'C:\Users\moikawa\Documents\GitHub\Powershell\vSphere\log'+"$DateTime"+'.txt'
$csvpath = 'C:\Users\moikawa\Documents\GitHub\Powershell\vSphere\VM-List_'+"$DateTime"+'.csv'
$vcip = 'xx.xx.xx.xx'
$vcadmin = 'xxxxxx@vsphere.local'
$vcpass = 'xxxxxxxxxxx'

Connect-VIServer -Server $vcip -Protocol https -User $vcadmin -Password $vcpass -Force

#log取得の開始と、出力先の指定
Start-Transcript $logpath


#Get VM List
$ListOfVMs = Get-VM | Sort-Object -Property Name

$Count = $ListOfVMs.Count
$Counter = 1

ForEach ($VM in $ListOfVMs ){
    try {
        Write-Host "Processing VM - [$Counter/$Count] -" $VM.name

        $VMView = $VM | Get-View -ErrorAction Ignore
        $VMNICs = Get-NetworkAdapter -VM $VM -ErrorAction Ignore
        $VMDisks = Get-HardDisk -VM $VM -ErrorAction Ignore

        $Object = [PSCustomObject]@{
        Name                = $VM.Name
        PowerState          = $VM.PowerState
        HardwareVersion     = $VM.HardwareVersion
        vCenter             = $VM.Uid.Substring($VM.Uid.IndexOf('@') + 1).Split(":")[0]
        Host                = $VM.VMHost.Name
        Cluster             = $VM.VMHost.Parent.name
        ToolsStatus         = $VMView.Guest.ToolsStatus
        GuestOS             = (Get-VMGuest -VM $VM).OSFullName
        NumCPU              = $VM.NumCpu
        CpuHotAddEnabled    = $VM.ExtensionData.config.CpuHotAddEnabled
        CPUReservation      = $VM.ExtensionData.Config.CPUAllocation.Reservation
        MemGB               = $VM.MemoryGB
        MemoryHotAddEnabled = $VM.ExtensionData.config.MemoryHotAddEnabled
        MemoryAllReserved   = $VM.ExtensionData.Config.MemoryReservationLockedToMax
        MemoryReservation   = $VM.ExtensionData.Config.MemoryAllocation.Reservation
        NumDisks            = $VMDisks.Count
        Disk1SizeGb         = $VMDisks.CapacityGb[0]
        Disk2SizeGb         = $VMDisks.CapacityGb[1]
        Disk3SizeGb         = $VMDisks.CapacityGb[2]
        Disk4SizeGb         = $VMDisks.CapacityGb[3]
        NumNICs             = $VMNICs.Count
        Nic0_Type           = $VMNICs.Type[0]
        NIC0_IP             = $VM.Guest.IPAddress[0]
        NIC0_Mac            = $VMNICs.MacAddress[0]
        Nic1_Type           = $VMNICs.Type[1]
        NIC1_IP             = $VM.Guest.IPAddress[1]
        NIC1_Mac            = $VMNICs.MacAddress[1]
        Nic2_Type           = $VMNICs.Type[2]
        NIC2_IP             = $VM.Guest.IPAddress[2]
        NIC2_Mac            = $VMNICs.MacAddress[2]
        Folder              = $VM.Folder.Name
        BootDelay           = $VM.ExtensionData.Config.BootOptions.BootDelay
        # LoggingEnabled  = $VM.ExtensionData.Config.Flags.EnableLogging
        }

        $Report.add($Object) | Out-Null
    } Catch {} Finally {
        $Counter++
    }
}

$Report | Export-Csv $csvpath -NoTypeInformation -UseCulture
$DefaultVIServers | Disconnect-VIServer -Confirm:$false

#log取得の終了
Stop-Transcript


#Moduleの確認。Nugetのインストールを求められる場合もある。
Find-Module -Name VMware.PowerCLI

#既存のPowerCLIのUpdate
Install-Module -Name VMware.PowerCLI

#SSL証明書エラー
Set-PowerCLIConfiguration -Scope User -InvalidCertificateAction Ignore -Confirm:$false

Connect-VIServer -Server 172.20.2.11 -User Administrator@vsphere.local -Password xxxxx
$TargetHost =  Get-VMhost -name lab-esxi03.lab.local
$TargetDatastore = Get-Datastore -name E2700_02

#VMの確認
Get-VM -Name mo-win2016

#新規VMの作成
New-VM -Name 'mo-win2016' -vmhost $TargetHost -Datastore $TargetDatastore -NumCpu 1 -DiskMB (1024*50) -MemoryMB (1024*4) -DiskStorageFormat 'thin' -GuestID 'windows9Server64Guest' -NetworkName 'VM Network' -ResourcePool 'moikawa'

#作成したVMのパラメータ確認
Get-VM -Name mo-win2016 |Select-Object Name,NumCpu,MemoryGB,ProvisionedSpaceGB,GuestID |Format-Table -AutoSize

#10台新規作成
$TargetHost =  Get-VMhost -name lab-esxi03.lab.local
$TargetDatastore = Get-Datastore -name E2700_02
foreach($n in 1..10) {
    New-VM -Name mo-win2016-$n -vmhost $TargetHost -Datastore $TargetDatastore -NumCpu 1 -DiskMB (1024*50) -MemoryMB (1024*4) -DiskStorageFormat 'thin' -GuestID 'windows9Server64Guest' -NetworkName 'VM Network' -ResourcePool 'moikawa'
}

#VMの削除
remove-vm mo-win2016 -DeletePermanently

#まとめてVMの削除
remove-vm mo-win2016* -DeletePermanently


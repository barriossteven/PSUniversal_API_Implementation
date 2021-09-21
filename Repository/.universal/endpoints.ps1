New-PSUEndpoint -Url "/EP_Get-AD" -Endpoint {
import-module "activedirectory"
$Computers = Get-ADComputer -Filter 'name -like $Prefix' -Properties canonicalname | Where-Object{$_.CANONICALNAME -LIKE "OU goes here if you want to narrow field of search*"}


$Computers | convertto-jsonex -EnumsAsStrings
} 
New-PSUEndpoint -Url "/EP_Get-PVS" -Endpoint {
# Enter your script to process requests.
Import-Module "C:\Program Files\Citrix\Provisioning Services Console\Citrix.PVS.SnapIn.dll" 

set-pvsconnection $ProvisioningServer
#write-output "$((get-pvsconnection).server)"
Get-PvsDeviceInfo | convertto-jsonex -EnumsAsStrings
} 
New-PSUEndpoint -Url "/EP_Get-Broker" -Description "Citrix Broker Inventory" -Endpoint {
# Enter your script to process requests.
get-brokermachine -adminaddress $Controller -hypervisorconnectionname $vCenter -sessionsupport "SingleSession" -desktopkind "Shared" -maxrecordcount 100000 | convertto-jsonex -EnumsAsStrings
} 
New-PSUEndpoint -Url "/EP_Get-Inventory" -Endpoint {
# Enter your script to process requests.
  param(
      [Parameter(Mandatory)]$Controller, $ProvisioningServer, $vCenter,$VM_Prefix,
      [Parameter(Mandatory=$false)][string]$Update_vCenter
  )
#Wait-Debugger
if($Update_vCenter -eq "true"){
    #user requesting to update vcenter cached info from API request
    $cache:cachedvcenteritems.remove(($vCenter + ".Willkie.com"))
} 
     

#Getting VMs from Broker
$BrokerMachines = Invoke-RestMethod http://localhost:5000/EP_Get-Broker -METHOD GET -Body @{ 
    Controller = $Controller
    vCenter = $vCenter
}

#Getting VMs from PVS
$PVSDevices = (Invoke-RestMethod http://localhost:5000/EP_Get-PVS?ProvisioningServer=$ProvisioningServer)

#Getting VMs from AD
$ADComputers = Invoke-RestMethod -Uri "http://localhost:5000/EP_Get-AD?Prefix=$VM_Prefix" -Method GET

#Getting VMs from vCenter

#<#
$vCenterVMs = Invoke-RestMethod http://localhost:5000/EP_Get-vCenter -METHOD GET -Body @{ 
    vCenter = $vCenter + ".domain.com"
    vm_prefix = $VM_Prefix
}

#>



#hashtable housing all computer objects
$VM_Table = @{}
$BrokerMachines | ForEach-Object { $VM_Table[$_.hostedmachinename] = $_ }

#<#
foreach($device in $PVSDevices){
    $VM_Table[$device.devicename] | Add-Member -notepropertymembers @{
        PVS_Collectionname = $device.collectionname
        PVS_Disklocatorname = $device.disklocatorname
        PVS_Diskversion = $device.diskversion
        PVS_Servername = $device.servername
    } 
}


#>

#<#
foreach($computer in $ADComputers){
    $VM_Table[$computer.name] | Add-Member -notepropertymembers @{
        AD_Canonicalname = $computer.canonicalname
    } 
}

#>


#<#
foreach($VM in $vCenterVMs){
    $VM_Table[$VM.name] | Add-Member -notepropertymembers @{
        VC_Host = $VM.vc_host
        VC_Disk = $VM.vc_disk
        VC_Vlan = $VM.vc_vlan
    } 
}


#>



$VM_table.values | convertto-jsonex -EnumsAsStrings
} 
New-PSUEndpoint -Url "/EP_Get-vCenter" -Endpoint {
# Enter your script to process requests.
#import-module "vmware.vimautomation.core"
#Wait-Debugger

if($Cache:CachedvCenterItems -eq $null){
    #"table does not exist"
    #create table
    $Cache:CachedvCenterItems = @{}
    #run update table
    $vCenterVMs = Invoke-RestMethod http://localhost:5000/EP_Update-vCenter -METHOD GET -Body @{ 
        vCenter = $vcenter
        vm_prefix = $vm_prefix
    } 
    $vCenterVMs = $vCenterVMs | Select-Object name , @{Name="VC_Host";Expression={$_.runtime.linkedview.host.name}},  @{Name="VC_Disk";Expression={$_.linkedview.datastore.name}},  @{Name="VC_Vlan";Expression={$_.linkedview.network.name}}
    $Cache:CachedvCenterItems[$vcenter] = $vCenterVMs
    return ($Cache:CachedvCenterItems[$vcenter] | convertto-jsonex -EnumsAsStrings -Depth 1)
}else{
    #check if key exists and return values
    if($Cache:CachedvCenterItems.contains($vcenter)){
        return ($Cache:CachedvCenterItems[$vcenter] | convertto-jsonex -EnumsAsStrings -depth 1)
    }else{
        #key not exist
        #run update
        $vCenterVMs = Invoke-RestMethod http://localhost:5000/EP_Update-vCenter -METHOD GET -Body @{ 
        vCenter = $vcenter
        vm_prefix = $vm_prefix
        }
        $vCenterVMs = $vCenterVMs | Select-Object name , @{Name="VC_Host";Expression={$_.runtime.linkedview.host.name}},  @{Name="VC_Disk";Expression={$_.linkedview.datastore.name}},  @{Name="VC_Vlan";Expression={$_.linkedview.network.name}}
        $Cache:CachedvCenterItems[$vcenter] = $vCenterVMs
        return ($Cache:CachedvCenterItems[$vcenter] | convertto-jsonex -EnumsAsStrings -Depth 1)
    }
   
    #if key does not exist, run update table


}
#return $Cache:vcenterVMs
} 
New-PSUEndpoint -Url "/EP_Update-vCenter" -Endpoint {
$Var_VC = Connect-VIServer -Server $vCenter -User "svc_acc" -WarningAction SilentlyContinue 

    $Var_VMs = Get-View -ViewType VirtualMachine -Server $Var_VC | Where-Object {$_.name -like $vm_prefix}
    $Var_VMs.updateviewdata("runtime.host.name", "datastore.name","network.name")
    return $Var_VMs
} 
New-PSUEndpoint -Url "/EP_Clear-vCenter" -Description "Clears cached items for specified vcenter" -Endpoint {
# Enter your script to process requests.
    #Wait-Debugger
    $cache:cachedvcenteritems.remove($vCenter)
}
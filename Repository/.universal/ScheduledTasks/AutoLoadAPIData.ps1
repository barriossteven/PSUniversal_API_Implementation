function Update-APIData {
    [cmdletbinding()]
    Param (
        [string[]]$Controllers,$PVSServers,
        [string]$vCenter,$VM_Prefix
    )

    Invoke-RestMethod http://localhost:5000/EP_Get-Inventory -Method get -Body @{ 
    Controller = $($Controllers | get-random)
    ProvisioningServer = $($PVSServers | get-random)
    vCenter = $vcenter
    VM_Prefix = $VM_Prefix
    Update_vCenter = "true" 
    }

}

$ServerJson = Get-Content -Raw -Path "C:\ProgramData\UniversalAutomation\Repository\.universal\Servers.json"| ConvertFrom-Json

$Sites = @("LAB","SITE_A","SITE_B","SITE_C")

$Sites | %{

    
         Update-APIData `
        -Controllers $($ServerJson.$_.Controllers | get-random) `
        -PVSServers $($ServerJson.$_.Provisioning | get-random) `
        -vCenter $ServerJson.$_.vcenter `
        -VM_Prefix $ServerJson.$_.vm_prefix | Out-Null
   
}




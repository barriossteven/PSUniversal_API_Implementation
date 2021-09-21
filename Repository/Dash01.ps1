

$page1 = New-UDPage -Name "Page1" -Content {

    
    new-udcard  -Title "VM Inventory" -Content {

#<#
        $inventory = Invoke-RestMethod http://localhost:5000/EP_Get-Inventory -Method get -Body @{ 
            Controller = ""
            ProvisioningServer = ""
            vCenter = ""
            VM_Prefix = "*"
        } 
        
        $inventory = $inventory | Sort-Object catalogname | select hostedmachinename,catalogname,pvs_disklocatorname,vc_disk

        $Columns = @(  
            New-UDTableColumn -Property hostedmachinename 
            New-UDTableColumn -Property catalogname 
            New-UDTableColumn -Property pvs_disklocatorname 
            New-UDTableColumn -Property vc_disk 
        )   

        New-UDTable -Id 'inventory' -Data  $inventory -ShowSearch -paging -PageSize 10 -showsort

    }



    


}

$Theme = @{
    palette = @{
        primary = @{
            main = '#876a38'
        }
        background = @{
            default = '#876a38'
        }
    }
}


#New-UDDashboard -Title "Hello, World!" -Pages @($Page1) -Theme $Theme 
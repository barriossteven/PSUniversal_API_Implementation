
$Pages = @()

#<#
$Pages += New-UDPage -Name "AllSites" -Content {

    $Session:Site = "LAB" #Default site to show when page is loaded
    $Session:ServerJson = Get-Content -Raw -Path "C:\ProgramData\UniversalAutomation\Repository\.universal\Servers.json"| ConvertFrom-Json

    New-UDGrid -Container -Content {
        New-UDGrid -Item -SmallSize 3 -Content {
            New-UDCard -Title "Site Selection" -Content {
                New-UDRadioGroup -Label "Site" -Content {
                    New-UDRadio -Label Site1 -Value 'Site1'
                    New-UDRadio -Label Site2 -Value 'Site2'
                    New-UDRadio -Label Site3 -Value 'Site3'
                    New-UDRadio -Label LAB -Value 'LAB' 
                } -OnChange {   
                    $Session:Site = $eventdata
                    Sync-UDElement -Id 'table'
              } -value LAB #default selection for radio
            }
        }  
        New-UDGrid -Item -SmallSize 3 -Content {
            New-UDCard -Title "Update Citrix/AD information" -Content {
                New-UDTypography -Text "Broker, PVS, and AD information gets automatically refreshed upon reloading table. Select button to refresh data." -Paragraph
                New-UDButton -Text 'Update Citrix/AD Info' -OnClick {
                    Sync-UDElement -Id 'table'
                }
            }
        }
        New-UDGrid -Item -SmallSize 3 -Content {
            New-UDCard -Title "Update vCenter Information" -Content {
                    New-UDTypography -Text "Vcenter information for each region is not updated on table refresh unlike PVS/Broker/AD. 
                    Vcenter Information will need to be manually updated using the following button. Table will automatically refresh.
                    " -Paragraph

                    New-UDButton -Text 'Update vCenter Info' -OnClick {
            
                    Invoke-RestMethod -Uri "http://localhost:5000/EP_Clear-vCenter" -Method GET -Body @{
                        vcenter = "$($Session:ServerJson.$Session:Site.vcenter).domain.com"
                    }
                        #syncud element table
                        Sync-UDElement -Id 'table'
                    }          

            }
        }
    }

    New-UDDynamic -Id 'table' -Content {

        $Controllers = $Session:ServerJson.$Session:Site.Controllers
        $PVSServers = $Session:ServerJson.$Session:Site.Provisioning
        $vCenter = $Session:ServerJson.$Session:Site.vcenter
        $VM_Prefix = $Session:ServerJson.$Session:Site.vm_prefix

        $Properties = @("Hostedmachinename","Catalogname","DesktopGroupName","ipaddress","sessionusername","sessionstate","sessionclientname","powerstate","InMaintenanceMode","registrationstate","pvs_disklocatorname","pvs_diskversion","PVS_Servername","vc_host","vc_disk")

        $inventory = Invoke-RestMethod http://localhost:5000/EP_Get-Inventory -Method get -Body @{ 
            Controller = $($Controllers | get-random)
            ProvisioningServer = $($PVSServers | get-random)
            vCenter = $vcenter
            VM_Prefix = $VM_Prefix
        } 

        $SelectObjectParams = @{
            Property = $properties
        }

        $inventory = $inventory | Select-Object @SelectObjectParams

        $Columns =  $properties | ForEach-Object{
            New-UDTableColumn -Property $_ -IncludeInExport -includeinsearch 
        }

        New-UDTable -Id 'inventory' -Data  $inventory -ShowSearch -paging -PageSize 10 -showsort -columns $Columns -Dense -Export 

    } -LoadingComponent {
        #"Loading"
        New-UDProgress
    }

}



$Pages += New-UDPage -Name "LAB" -Content {
      
        $ServerJson = Get-Content -Raw -Path "C:\ProgramData\UniversalAutomation\Repository\.universal\Servers.json"| ConvertFrom-Json
        
        New-UDGrid -Container -Content {
            New-UDGrid -Item -SmallSize 3 -Content {
                New-UDCard -Title "Installation" -Content {
                    New-UDTypography -Text "$Cache:CachedvCenterItems[0]" -Paragraph
                }
                
            }  
            New-UDGrid -Item -SmallSize 3 -Content {
                New-UDCard -Title "Installation" -Content {
                   New-UDTypography -Text "$($ServerJson.lab.vcenter)" -Paragraph
                    
                    
                }
            }
            New-UDGrid -Item -SmallSize 3 -Content {
                New-UDCard -Title "Update vCenter Information" -Content {
                    New-UDTypography -Text "Vcenter information for each region is not updated on table refresh unlike PVS/Broker/AD. 
                                        Vcenter Information will need to be manually updated using the following button and the table then needs to be freshed.
                                        " -Paragraph
                    New-UDButton -Text 'Update vCenter Info' -OnClick {
                        #Wait-Debugger
                        Invoke-RestMethod -Uri "http://localhost:5000/EP_Clear-vCenter" -Method GET -Body @{
                            vcenter = "vcenter.domain.com"
                        }
                        #syncud element table
                        Sync-UDElement -Id 'table'
                    }          
                }
            }
        }

        New-UDButton -Text 'Update Broker/PVS/AD Info' -OnClick {
            Sync-UDElement -Id 'table'
        }

        New-UDDynamic -Id 'table' -Content {

            $Controllers = $ServerJson.lab.Controllers
            $PVSServers = $ServerJson.lab.Provisioning
            $vCenter = $ServerJson.lab.vcenter
            $VM_Prefix = $ServerJson.lab.vm_prefix
    
            $Properties = @("Hostedmachinename","Catalogname","DesktopGroupName","ipaddress","sessionusername","sessionstate","sessionclientname","powerstate","InMaintenanceMode","registrationstate","pvs_disklocatorname","pvs_diskversion","PVS_Servername","vc_host","vc_disk")
      
            $inventory = Invoke-RestMethod http://localhost:5000/EP_Get-Inventory -Method get -Body @{ 
                Controller = $($Controllers | get-random)
                ProvisioningServer = $($PVSServers | get-random)
                vCenter = $vcenter
                VM_Prefix = $VM_Prefix
            } 
    
            $SelectObjectParams = @{
                Property = $properties
            }
    
            $inventory = $inventory | Select-Object @SelectObjectParams
    
            $Columns =  $properties | ForEach-Object{
                New-UDTableColumn -Property $_ -IncludeInExport -includeinsearch 
            }
    
            New-UDTable -Id 'inventory' -Data  $inventory -ShowSearch -paging -PageSize 10 -showsort -columns $Columns -Dense -Export 

        } -LoadingComponent {
            #"Loading"
            New-UDProgress
        }

}

$Pages += New-UDPage -Name "API Source Code" -Content {

    New-UDRadioGroup -Label "Site" -Content {
        New-UDRadio -Label Site1 -Value 'Site1'
        New-UDRadio -Label Site2 -Value 'Site2'
        New-UDRadio -Label Site3 -Value 'Site3'
        New-UDRadio -Label LAB -Value 'LAB'

    } -OnChange {  
         
$code = 
'$Controllers = @(
    "var_controller"
)
$PVSServers = @(
    "var_pvs"
)
$vCenter = "Var_vcenter"
$VM_Prefix = "var_vm_prefix"
$inventory = Invoke-RestMethod http://localhost:5000/EP_Get-Inventory -Method get -Body @{ 
    Controller = $($Controllers | get-random)
    ProvisioningServer = $($PVSServers | get-random)
    vCenter = $vcenter
    VM_Prefix = $VM_Prefix
    Update_vCenter = "False" 
} '
        $ServerJson = Get-Content -Raw -Path "C:\ProgramData\UniversalAutomation\Repository\.universal\Servers.json" | ConvertFrom-Json
        $controller = $($ServerJson.$eventdata.controllers | get-random)
        $pvs = $($ServerJson.$eventdata.Provisioning | get-random)
        $vcenter = $($ServerJson.$eventdata.vCenter)
        $vm_prefix = $($ServerJson.$eventdata.VM_Prefix)
        $code = $code.Replace("var_controller",$controller)
        $code = $code.Replace("var_pvs",$pvs)
        $code = $code.Replace("Var_vcenter",$vcenter)
        $code = $code.Replace("var_vm_prefix",$vm_prefix)
        Set-UDElement -Id 'codeEditor' -Properties @{
          code = $code        } 
    }
   

    New-UDCodeEditor -Id 'codeEditor' -Theme 'vs-dark' -Height 300 -Language 'powershell' -ReadOnly -code '#Select which site you want to display'

               
   
}


$Theme = @{
    palette = @{
        primary = @{
            main = '#646475'
        }
        background = @{
            default = '#646475'
        }
    }
}

New-UDDashboard -Theme $Theme -Title "Citrix Inventory" -Pages $Pages
New-PSUEnvironment -Name "5.1.19041.1023" -Path "C:\WINDOWS\System32\WindowsPowerShell\v1.0\powershell.exe" -Variables @('*') 
New-PSUEnvironment -Name "Integrated" -Path "C:\Program Files (x86)\Universal\Universal.Server.exe" -Variables @('*') 
New-PSUEnvironment -Name "powershell.exe" -Path "C:\WINDOWS\System32\WindowsPowerShell\v1.0\powershell.exe" -Variables @('*') -PSModulePath @(
    ‘C:\WINDOWS\system32\WindowsPowerShell\v1.0\Modules\ActiveDirectory\ActiveDirectory.psd1’,
    'C:\Program Files\Citrix\PowerShellModules\Citrix.Broker.Commands\Citrix.Broker.Commands.psd1',
    'C:\Program Files\Citrix\Provisioning Services Console\Citrix.PVS.SnapIn.dll',
    'vmware.vimautomation.core'
    )
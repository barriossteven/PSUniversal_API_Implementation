Dim shell,command
command = "powershell.exe -nologo -command ""C:\ProgramData\UniversalAutomation\Repository\.universal\ScheduledTasks\AutoLoadAPIData_test.ps1"""
Set shell = CreateObject("WScript.Shell")
shell.Run command,0
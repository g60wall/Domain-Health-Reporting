function Write-HTML{
<#

.SYNOPSIS
    Creates an HTML file on the Desktop of the local machine full of detailed system information.
.DESCRIPTION
    Write-HTML utilizes WMI to retrieve information related to the physical hardware of the machine(s), the available `
    disk space, when the machine(s) last restarted and bundles all that information up into a colored HTML report.
.EXAMPLE
   Write-HTML -Computername localhost, SRV-2012R2, DC-01, DC-02
   This will create an HTML file on your desktop with information gathered from as many computers as you can access remotely
#>
[CmdletBinding(SupportsShouldProcess=$True)]
param( [Parameter(Mandatory=$false,
ValueFromPipeline=$true)]
[string]$FilePath = "\\nas\it\james\outfile\Write-HTML.html",
[string[]]$Computername = $env:COMPUTERNAME,
$Css='<style>table{margin:auto; width:98%}
     Body{background-color:Orange; Text-align:Center;}
     th{background-color:black; color:white;}
     td{background-color:Grey; color:Black; Text-align:Center;} </style>' )
Begin{Write-Verbose "HTML report will be saved $FilePath"}
Process{$Hardware=Get-WmiObject -class Win32_ComputerSystem -ComputerName $Computername | 
     Select-Object Name,Domain,Manufacturer,Model,NumberOfLogicalProcessors,
     @{ Name = "Installed Memory (GB)" ; Expression = { "{0:N0}" -f( $_.TotalPhysicalMemory / 1gb ) } } |
     ConvertTo-Html -Fragment -As Table -PreContent "<h2>Hardware</h2>" | Out-String
$PercentFree=Get-WmiObject Win32_LogicalDisk -ComputerName $Computername | 
     Where-Object { $_.DriveType -eq "3" } | Select-Object SystemName,VolumeName,DeviceID,
     @{ Name = "Size (GB)" ; Expression = { "{0:N1}" -f( $_.Size / 1gb) } },
     @{ Name = "Free Space (GB)" ; Expression = {"{0:N1}" -f( $_.Freespace / 1gb ) } },
     @{ Name = "Percent Free" ; Expression = { "{0:P0}" -f( $_.FreeSpace / $_.Size ) } } |
     ConvertTo-Html -Fragment -As Table -PreContent "<h2>Available Disk Space</h2>" | Out-String
$Restarted=Get-WmiObject -Class Win32_OperatingSystem -ComputerName $Computername | Select-Object Caption,CSName,
     @{ Name = "Last Restarted On" ; Expression = { $_.Converttodatetime($_.LastBootUpTime) } } |
     ConvertTo-Html -Fragment -As Table -PreContent "<h2>Last Boot Up Time</h2>" | Out-String
$Stopped=Get-WmiObject -Class Win32_Service -ComputerName $Computername | 
     Where-Object { ($_.StartMode -eq "Auto") -and ($_.State -eq "Stopped") } |
     Select-Object SystemName, DisplayName, Name, StartMode, State, Description |
     ConvertTo-Html -Fragment -PreContent "<h2>Services currently stopped that are set to autostart</h2>" | Out-String
$Report=ConvertTo-Html -Title "$Computername" `
     -Head "<h1>PowerShell Reporting<br><br>$Computername</h1><br>This report was ran: $(Get-Date)" `
     -Body "$Hardware $PercentFree $Restarted $Services $Stopped $Css" }
End{$Report | Out-File $Filepath ; Invoke-Expression $FilePath } }


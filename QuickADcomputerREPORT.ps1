##Created by: James A. Wall
## powershell.org  In particular Curtis Smith
## $$$$$$$$$$$$$$$$$$$$$$$$$$
##Table Formating
$Header = @"
<style>
TABLE {border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}
TH {border-width: 1px;padding: 3px;border-style: solid;border-color: black;background-color: #6495ED;}
TD {border-width: 1px;padding: 3px;border-style: solid;border-color: black;}
TR:Nth-Child(Even) {Background-Color: #dddddd;}
TR:Hover TD {Background-Color: #C1D5F8;}
</style>
<title>
DOMAIN INVENTORY
</title>
"@
$Properties = @(
    'name'
    'dnshostname'
    'operatingsystem'
    'ipv4address'
    'lastlogondate'
    'logoncount'
    @{
        label = 'PingResults' 
        Expression = { 
            tnc $_.IPv4Address -InformationLevel Quiet }
    }
    @{
        label = 'Mac Address'
        Expression={
            (Get-WmiObject Win32_NetworkAdapter -ComputerName $_.name).MacAddress -ne $null
        }
    }
    @{
        label = 'HDD About to Fail'
        Expression={
            Get-WmiObject -ComputerName $_.name -namespace root\wmi –class MSStorageDriver_FailurePredictStatus -ErrorAction Silentlycontinue | 
                Select-Object -Property PredictFailure
        }
    }
     @{
        label = 'Display Adapter'
        Expression={
           (Get-WmiObject Win32_DisplayControllerConfiguration -ComputerName $_.name).name

        }}
)
$Properties1 = @(
    'name'
    'dnshostname'
    'operatingsystem'
    'ipv4address'
    'lastlogondate'
    'logoncount'
    @{
        label = 'PingResults' 
        Expression = { 
            "Not Alive" }
    }
)
$reportname = (get-date).DayOfWeek
$results =@()
$computerlist = Get-ADComputer -filter * -Property *

Import-Module ActiveDirectory




ForEach ($computer in $computerlist) {
	if ($computer.ipv4address -eq $null) 
         {
		  $results += $computer | Select-Object -Property $Properties1
	     } 
    else {
          $results += $computer | Select-Object -Property $Properties
	}
}
$results | sort lastlogondate -Descending | ConvertTo-Html -head $header -Title "Domain Inventory" | Out-File c:\QUICKad$reportname.html

c:\QUICKad$reportname.html
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
<<<<<<< HEAD
## standard Properties


$reportname = (get-date).DayOfWeek
=======

##Set location of Report
##$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

$location = c:\DomainDump.html

>>>>>>> origin/master
Import-Module ActiveDirectory
$results =@()
$computerlist = Get-ADComputer -filter * -Property *


ForEach ($computer in $computerlist) {
	if ($computer.ipv4address -eq $null) {
		$results += $computer | Select-Object name, dnshostname, operatingsystem,ipv4address, lastlogondate, logoncount, @{ label = "PingResults"; Expression = { "Not Alive" } }
	} else {
		$results += $computer | Select-Object name, dnshostname, operatingsystem,ipv4address, lastlogondate, logoncount, @{ label = "PingResults"; Expression = { tnc $_.ipv4address -InformationLevel Quiet }},@{ label = "Mac Address"; Expression={(Get-WmiObject win32_networkadapter -ComputerName $_.name).macaddress -ne $null}},@{ label = "HDD About to Fail"; Expression={Get-WmiObject -ComputerName $_.name -namespace root\wmi –class MSStorageDriver_FailurePredictStatus -ErrorAction Silentlycontinue |  Select  PredictFailure}}  
	}
}
<<<<<<< HEAD
$results | sort lastlogondate -Descending | ConvertTo-Html -head $header -Title "Domain Inventory" | Out-File c:\QUICKad$reportname.html
=======
$results | sort lastlogondate -Descending | ConvertTo-Html -head $header -Title "Domain Inventory" | Out-File $localtion
>>>>>>> origin/master

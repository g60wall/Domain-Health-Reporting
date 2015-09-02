##Created by: James A. Wall
## $$$$$$$$$$$$$$$$$$$$$$$$$$

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
Import-Module ActiveDirectory
$computerlist = Get-ADComputer -filter * -Property *
$results =@()
ForEach ($computer in $computerlist) {
	if ($computer.ipv4address -eq $null) {
		$results += $computer | Select-Object name, dnshostname, operatingsystem, operatingsystemservicepack, ipv4address, lastlogondate, logoncount, @{ label = "PingResults"; Expression = { "Not Alive" } }
	} else {
		$results += $computer | Select-Object name, dnshostname, operatingsystem, operatingsystemservicepack, ipv4address, lastlogondate, logoncount, @{ label = "PingResults"; Expression = { tnc $_.ipv4address -InformationLevel Quiet }},@{ label = "Mac Address"; Expression={(Get-WmiObject win32_networkadapter -ComputerName $_.name).macaddress -ne $null}}  
	}
}
$results | sort lastlogondate -Descending | ConvertTo-Html -head $header -Title "Domain Inventory" | Out-File \\nas\it\james\OUTFILE\DomainInventory.html
$Header = @"
<style>
TABLE {border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}
TH {border-width: 1px;padding: 3px;border-style: solid;border-color: black;background-color: #6495ED;}
TD {border-width: 1px;padding: 3px;border-style: solid;border-color: black;}
TR:Nth-Child(Even) {Background-Color: #dddddd;}
TR:Hover TD {Background-Color: #C1D5F8;}
</style>
<title>
$Title
</title>
"@



$b = Get-ADComputer -filter * | select-object -ExpandProperty Name

Get-WmiObject -namespace root\wmi –class MSStorageDriver_FailurePredictStatus -ComputerName $b -ErrorAction SilentlyContinue  |  Select pscomputername,InstanceName, PredictFailure, Reason | ConvertTo-Html -head $header | Out-File C:\DomainDriveHealth.html



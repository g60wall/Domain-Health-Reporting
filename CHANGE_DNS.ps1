## Will only change Workstations with this IP set as gateway
$oldgateway = "ENTER IP OF GATEWAY TO CHANGE"
## will change the IP of mention IP above to the IP set Below
$newgateway = "ENTER NEW GATEWAY"

$domainHost = Get-ADComputer -Filter * -Properties CN | select CN
foreach ($item in $domainHost)
{
    $n2 = Get-WMIObject win32_NetworkAdapterConfiguration -computer tfell -filter "IPEnabled = True and DHCPEnabled = False" | where-object {$_.defaultIPGateway -eq $oldgateway}
    $n2 | ForEach-Object { [PSCustomObject]@{ ComputerName = $item.CN; IPAddress = $_.IPaddress; SubnetMask = $_.IPSubnet; Gateway = $_.defaultIPGateWay } }
    #$n2.SetGateways($newgateway)   ###Un-comment this line before you run
}
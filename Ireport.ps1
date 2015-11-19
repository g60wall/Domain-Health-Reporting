
$today = Get-Date
$cutoffdate = $today.AddDays(-30)
$que = Get-ADComputer  -Properties * -Filter {LastLogonDate -gt $cutoffdate}|Select -Expand cn  

foreach($q in $que){
if((Test-NetConnection -ComputerName $q -InformationLevel Quiet) -match "true"){
        $hostinfo = Get-ADComputer $q -Properties *
        $cpu    = Get-WmiObject -ComputerName $q  win32_processor
        $os     = Get-WmiObject -ComputerName $q  win32_operatingsystem
        $disk   = Get-WmiObject -ComputerName $q  win32_logicaldisk
        $memory = Get-WmiObject -ComputerName $q  win32_physicalmemory
                                                            $system =  [PSCustomObject]@{
                                                            hostname = $os.PSComputerName
                                                            IPv4Address = $hostinfo.IPv4Address
                                                            IPv6Address = $hostinfo.IPv6Address
                                                            OUlocation = $hostinfo.CanonicalName
                                                            OperatingSystem = $os.Caption
                                                            OSarch = $os.OSArchitecture 
                                                            LastReformat = $hostinfo.whenCreated 
                                                            CPU = $cpu.name
                                                            CPUamount = ($cpu | Measure-Object).Count
                                                            HDsize = (($disk.size | Measure-Object -Sum).Sum)/1GB
                                                            HDfreeSpace =  (($disk.freespace | Measure-Object -Sum).Sum)/1GB
                                                            RAMtotal = (($memory.capacity  | Measure-Object -sum).sum)/1gb 
                                                            RAMspeed = if((($memory.speed | Measure-Object -Average).Average) -eq $null) `
                                                                        {"VHD"} else {($memory.speed | Measure-Object -Average).Average}
                                                            }
            $system | Export-Csv C:\DIReport.csv -Append -NoTypeInformation} `
                    else{ Get-ADComputer $q -Properties * | select CN | Export-csv c:\DIReportOFF.csv -Append -NoTypeInformation}}

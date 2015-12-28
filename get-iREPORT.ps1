function Get-iREPORT ()
{
  <#
  .SYNOPSIS
  Display Vital Workstation stats
  TESTED in Powershell v4 ++
  .DESCRIPTION
  Allow quick retrieval of domain workstation ( via WMI) vital signs 
  HostName
  IPv4Address
  IPv6Address
  DefaultGateway
  OUlocation = Active Directory locationg of Workstation
  Operating System
  OS architecture
  Last Reformat Date
  CPU type
  CPU Count
  HDsize = Hard Drive Size
  HDfreespace = Free Hard Drive Space
  RAMtotal = Total amount of ram 
  RAMspeed = Ram clock Speed

  .EXAMPLE
  Get-iReport
   This will display a report of shell parent workstation
  .EXAMPLE
  Get-iReport -computername SQL
  This will display a report of computer named SQL properties
  .PARAMETER computerName
  This is where you define name of machine, if left blank the local host will be queried
  #>
  [CmdletBinding()]   # Elevating to ADVANCED FUNCTION
  param (  # Define Parameter
         [Parameter( Mandatory = $false,
                     ValuefromPipeline=$true,
                     HelpMessage = 'Input folder location in filesystem'
                     )]
         [string[]] $computername = "$env:COMPUTERNAME"
        )  # End the parameter block

  begin   { Filter ConvertTo-KMG 
                {
                     <#
                     .Synopsis
                      Converts byte counts to Byte\KB\MB\GB\TB\PB format
                     .DESCRIPTION
                      Accepts an [int64] byte count, and converts to Byte\KB\MB\GB\TB\PB format
                      with decimal precision of 2
                     .EXAMPLE
                     3000 | convertto-kmg
                     #>

                     $bytecount = $_
                        switch ([math]::truncate([math]::log($bytecount,1024))) 
                        {
                            0 {"$bytecount Bytes"}
                            1 {"{0:n2} KB" -f ($bytecount / 1kb)}
                            2 {"{0:n2} MB" -f ($bytecount / 1mb)}
                            3 {"{0:n2} GB" -f ($bytecount / 1gb)}
                            4 {"{0:n2} TB" -f ($bytecount / 1tb)}
                            Default {"{0:n2} PB" -f ($bytecount / 1pb)}
                        }
                } }

  process { ## Code that is executed


            $hostinfo = Get-ADComputer -Identity "$computerName" -Properties * -EA SilentlyContinue
            $network  = Get-WmiObject -ComputerName $computerName Win32_NetworkAdapterConfiguration -EA SilentlyContinue
            $cpu      = Get-WmiObject -ComputerName $computerName  win32_processor
            $os       = Get-WmiObject -ComputerName $computerName  win32_operatingsystem
            $disk     = Get-WmiObject -ComputerName $computerName  win32_logicaldisk
            $memory   = Get-WmiObject -ComputerName $computerName  win32_physicalmemory
            $HD       = Get-WmiObject -ComputerName $computername Win32_diskdrive
            $WQLFilter="NOT SID = 'S-1-5-18' AND NOT SID = 'S-1-5-19' AND NOT SID = 'S-1-5-20'" 
            $Win32User = Get-WmiObject -Class Win32_UserProfile -Filter $WQLFilter -ComputerName $computername 
            $lastusetime = $Win32User | Sort-Object -Property LastUseTime -Descending | Select-Object -First 1 
            $cpusys = Get-WmiObject win32_computersystem -ComputerName $computername
                            

                        $system =  [PSCustomObject]@{
                        hostname = $os.PSComputerName
                        IPv4Address = $hostinfo.IPv4Address 
                        IPv6Address = $hostinfo.IPv6Address
                        DefaultGateway = $network.defaultIPgateway |  select -First 1
                        OUlocation = $hostinfo.CanonicalName
                        OperatingSystem = $os.Caption
                        LastLogonTime =  ([WMI]'').ConvertToDateTime($LastUsetime.LastUseTime) 
                        OSarch = $os.OSArchitecture 
                        LastReformat = $hostinfo.whenCreated 
                        CPU = $cpu.name | select -First 1
                        CPUcount = ($cpu | Measure-Object).Count
                        HDmodel  = $hd.caption
                        CPUcores = (($cpu).numberofcores | Measure-Object -Sum).sum  
                        HDsize = (($disk.size | Measure-Object -Sum).Sum)| ConvertTo-KMG
                        HDfreeSpace =  (($disk.freespace | Measure-Object -Sum).Sum)| ConvertTo-KMG
                        RAMtotal =  (($memory.capacity | Measure-Object -sum).sum) | ConvertTo-KMG
                        RAMlocation = $memory.devicelocator.GetType() 
                        RAMspeed = if((($memory.speed | Measure-Object -Average).Average) -eq $null) `
                                    {"VHD"} else {($memory.speed | Measure-Object -Average).Average}
                        Manufactuer = $cpusys.Manufacturer
                        Model = $cpusys.model
                        }
                        $system}
                    
  

  end    {Write-Host "Done Scanning Host:$computername" }

}


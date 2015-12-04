
    Function Get-ComputerAssetInformation
{
    <#
    .SYNOPSIS
       Get inventory data for specified computer systems.
    .DESCRIPTION
       Gather inventory data for one or more systems using wmi. Data proccessing utilizes multiple runspaces
       and supports custom timeout parameters in case of wmi problems. You can optionally include 
       drive, memory, and network information in the results. You can view verbose information on each 
       runspace thread in realtime with the -Verbose option.
    .PARAMETER ComputerName
       Specifies the target computer for data query.
    .PARAMETER IncludeMemoryInfo
       Include information about the memory arrays and the installed memory within them. (_Memory and _MemoryArray)
    .PARAMETER IncludeDiskInfo
       Include disk partition and mount point information. (_Disks)
    .PARAMETER IncludeNetworkInfo
       Include general network configuration for enabled interfaces. (_Network)
    .PARAMETER ThrottleLimit
       Specifies the maximum number of systems to inventory simultaneously 
    .PARAMETER Timeout
       Specifies the maximum time in second command can run in background before terminating this thread.
    .PARAMETER ShowProgress
       Show progress bar information
    .PARAMETER PromptForCredential
       Prompt for remote system credential prior to processing request.
    .PARAMETER Credential
       Accept alternate credential (ignored if the localhost is processed)
    .EXAMPLE
       PS > Get-ComputerAssetInformation -ComputerName test1
     
            ComputerName        : TEST1
            IsVirtual           : False
            Model               : ProLiant DL380 G7
            ChassisModel        : Rack Mount Unit
            OperatingSystem     : Microsoft Windows Server 2008 R2 Enterprise 
            OSServicePack       : 1
            OSVersion           : 6.1.7601
            OSSKU               : Enterprise Server Edition
            OSArchitecture      : x64
            SystemArchitecture  : x64
            PhysicalMemoryTotal : 12.0 GB
            PhysicalMemoryFree  : 621.7 MB
            VirtualMemoryTotal  : 24.0 GB
            VirtualMemoryFree   : 5.7 GB
            CPUCores            : 24
            CPUSockets          : 2
            SystemTime          : 08/04/2013 20:33:47
            LastBootTime        : 07/16/2013 07:42:01
            InstallDate         : 07/02/2011 17:52:34
            Uptime              : 19 days 12 hours 51 minutes
     
       Description
       -----------
       Query and display basic information ablout computer test1
    .EXAMPLE
       PS > $cred = Get-Credential
       PS > $b = Get-ComputerAssetInformation -ComputerName Test1 -Credential $cred -IncludeMemoryInfo 
       PS > $b | Select MemorySlotsTotal,MemorySlotsUsed | fl
       MemorySlotsTotal : 18
       MemorySlotsUsed  : 6
       
       PS > $b._Memory | Select DeviceLocator,@{n='MemorySize'; e={$_.Capacity/1Gb}}
       DeviceLocator                                                                   MemorySize
       -------------                                                                   ----------
       PROC 1 DIMM 3A                                                                           2
       PROC 1 DIMM 6B                                                                           2
       PROC 1 DIMM 9C                                                                           2
       PROC 2 DIMM 3A                                                                           2
       PROC 2 DIMM 6B                                                                           2
       PROC 2 DIMM 9C                                                                           2
       
       Description
       -----------
       Query information about computer test1 using alternate credentials, including detailed memory information. Return
       physical memory slots available and in use. Then display the memory location and size.
    .EXAMPLE
        PS > $a = Get-ComputerAssetInformation -IncludeDiskInfo -IncludeMemoryInfo -IncludeNetworkInfo
        PS > $a._MemorySlots | ft
        Label      Bank        Detail           FormFactor      Capacity
        -----      ----        ------           ----------      --------
        BANK 0     Bank 1      Synchronous      SODIMM              4096
        BANK 2     Bank 2      Synchronous      SODIMM              4096
        
       Description
       -----------
       Query local computer for all information, store the results in $a, then show the memory slot utilization in further
       detail in tabular form.
    .EXAMPLE
        PS > (Get-ComputerAssetInformation -IncludeDiskInfo)._Disks
        Drive            : C:
        DiskType         : Partition
        Description      : Installable File System
        VolumeName       : 
        PercentageFree   : 10.64
        Disk             : \\.\PHYSICALDRIVE0
        SerialNumber     :       0SGDENZA091227
        FreeSpace        : 6.3 GB
        PrimaryPartition : True
        DiskSize         : 59.6 GB
        Model            : SAMSUNG SSD PM800 TH 64G
        Partition        : Disk #0, Partition #0
        Description
        -----------
        Query information about computer, include disk information, and immediately display it.
    .NOTES
       Originally posted at: http://learn-powershell.net/2013/05/08/scripting-games-2013-event-2-favorite-and-not-so-favorite/
       Author: Zachary Loeber
       Props To: David Lee (www.linkedin.com/pub/david-lee/2/686/482/) - Helped to troubleshoot and resolve numerous aspects of this script
       Site: http://www.the-little-things.net/
       Requires: Powershell 2.0
       Info: WMI prefered over CIM as there no speed advantage using cimsessions in multithreading against old systems. Starting
             around line 263 you can modify the WMI_<Property>Props arrays to include extra wmi data for each element should you
             require information I may have missed. You can also change the default display properties by modifying $defaultProperties.
             Keep in mind that including extra elements like the drive space and network information will increase the processing time per
             system. You may need to increase the timeout parameter accordingly.
       
       Version History
       1.2.1 - 9/09/2013
        - Fixed a regression bug for os and system architecture detection (based on processor addresslength and width)       
       1.2.0 - 9/05/2013
        - Got rid of the embedded add-member scriptblock for converting to kb/mb/gb format in
          favor of a filter. This results in string object proeprties being returned instead
          of uint64 which can cause bizzare issues with excel when importing data.
       1.1.8 - 8/30/2013
        - Included the system serial number in the default general results
       1.1.7 - 8/29/2013
        - Fixed incorrect installdate in general information
        - Prefixed all warnings and verbose messages with function specific verbage
        - Forced STA apartement state before opening a runspace
        - Added memory speed to Memory section
       1.1.6 - 8/19/2013
        - Refactored the date/time calculations to be less region specific.
        - Added PercentPhysicalMemoryUsed to general info section
       1.1.5 - 8/16/2013
        - Fixed minor powershell 2.0 compatibility issue with empty array detection in the mountpoint calculation area.
       1.1.4 - 8/15/2013
        - Fixed cpu architecture determination logic (again).
        - Included _MemorySlots in the memory results option. This includes an array of objects describing the memory
          array, which slots are utilized, and what type of ram is utilizing them.
        - Added RAM lookup tables for memory model and  details.
       1.1.3 - 8/13/2013
        - Fixed improper variable assignment for virtual platform detection
        - Changed network connection results to simply include all adapters, connected or not and include a new derived property called 
          'ConnectionStatus'. This fixes a backwards compatibility issue with pre-2008 servers  and network detection.
        - Added nic promiscuous mode detection for adapters. 
            (http://praetorianprefect.com/archives/2009/09/whos-being-promiscuous-in-your-active-directory/)
       1.1.2 - 8/12/2013
        - Fixed a backward compatibility bug with SystemArchitecture and OSArchitecture properties
        - Added the actual network adapter display name to the _Network results.
        - Added another example in the comment based help   
       1.1.1 - 8/7/2013
        - Added wmi BIOS information to results (as _BIOS)
        - Added IsVirtual and VirtualType to default result properties
       1.1.0 - 8/3/2013
        - Added several parameters
        - Removed parameter sets in favor of arrays of custom object as note properties
        - Removed ICMP response requirements
        - Included more verbose runspace logging    
       1.0.2 - 8/2/2013
        - Split out system and OS architecture (changing how each it determined)
       1.0.1 - 8/1/2013
        - Updated to include several more bits of information and customization variables
       1.0.0 - ???
        - Discovered original script on the internet and totally was blown away at how awesome it is.
    #>
    [CmdletBinding()]
    PARAM
    (
        [Parameter(ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [ValidateNotNullOrEmpty()]
        [Alias('DNSHostName','PSComputerName')]
        [string[]]
        $ComputerName=$env:computername,
        
        [Parameter()]
        [switch]
        $IncludeMemoryInfo,
 
        [Parameter()]
        [switch]
        $IncludeDiskInfo,
 
        [Parameter()]
        [switch]
        $IncludeNetworkInfo,
       
        [Parameter()]
        [ValidateRange(1,65535)]
        [int32]
        $ThrottleLimit = 32,
 
        [Parameter()]
        [ValidateRange(1,65535)]
        [int32]
        $Timeout = 120,
 
        [Parameter()]
        [switch]
        $ShowProgress,
        
        [Parameter()]
        [switch]
        $PromptForCredential,
        
        [Parameter()]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )

    BEGIN
    {
        # Gather possible local host names and IPs to prevent credential utilization in some cases
        Write-Verbose -Message 'Remote Asset Information: Creating local hostname list'
        $IPAddresses = [net.dns]::GetHostAddresses($env:COMPUTERNAME) | Select-Object -ExpandProperty IpAddressToString
        $HostNames = $IPAddresses | ForEach-Object {
            try {
                [net.dns]::GetHostByAddress($_)
            } catch {
                # We do not care about errors here...
            }
        } | Select-Object -ExpandProperty HostName -Unique
        $LocalHost = @('', '.', 'localhost', $env:COMPUTERNAME, '::1', '127.0.0.1') + $IPAddresses + $HostNames
 
        Write-Verbose -Message 'Remote Asset Information: Creating initial variables'
        $runspacetimers       = [HashTable]::Synchronized(@{})
        $runspaces            = New-Object -TypeName System.Collections.ArrayList
        $bgRunspaceCounter    = 0
        
        if ($PromptForCredential)
        {
            $Credential = Get-Credential
        }
        
        Write-Verbose -Message 'Remote Asset Information: Creating Initial Session State'
        $iss = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()
        foreach ($ExternalVariable in ('runspacetimers', 'Credential', 'LocalHost'))
        {
            Write-Verbose -Message "Remote Asset Information: Adding variable $ExternalVariable to initial session state"
            $iss.Variables.Add((New-Object -TypeName System.Management.Automation.Runspaces.SessionStateVariableEntry -ArgumentList $ExternalVariable, (Get-Variable -Name $ExternalVariable -ValueOnly), ''))
        }
        
        Write-Verbose -Message 'Remote Asset Information: Creating runspace pool'
        $rp = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspacePool(1, $ThrottleLimit, $iss, $Host)
        $rp.ApartmentState = 'STA'
        $rp.Open()
 
        # This is the actual code called for each computer
        Write-Verbose -Message 'Remote Asset Information: Defining background runspaces scriptblock'
        $ScriptBlock = 
        {
            [CmdletBinding()]
            Param
            (
                [Parameter(Position=0)]
                [string]
                $ComputerName,
 
                [Parameter(Position=1)]
                [int]
                $bgRunspaceID,
          
                [Parameter()]
                [switch]
                $IncludeMemoryInfo,
         
                [Parameter()]
                [switch]
                $IncludeDiskInfo,
         
                [Parameter()]
                [switch]
                $IncludeNetworkInfo
            )
            $runspacetimers.$bgRunspaceID = Get-Date
            
            try
            {
                Write-Verbose -Message ('Remote Asset Information: Runspace {0}: Start' -f $ComputerName)
                $WMIHast = @{
                    ComputerName = $ComputerName
                    ErrorAction = 'Stop'
                }
                if (($LocalHost -notcontains $ComputerName) -and ($Credential -ne $null))
                {
                    $WMIHast.Credential = $Credential
                }

                Filter ConvertTo-KMG 
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
                }

                #region GeneralInfo
                Write-Verbose -Message ('Remote Asset Information: Runspace {0}: General asset information' -f $ComputerName)
                ## Lookup arrays
                $SKUs   = @("Undefined","Ultimate Edition","Home Basic Edition","Home Basic Premium Edition","Enterprise Edition",`
                            "Home Basic N Edition","Business Edition","Standard Server Edition","DatacenterServer Edition","Small Business Server Edition",`
                            "Enterprise Server Edition","Starter Edition","Datacenter Server Core Edition","Standard Server Core Edition",`
                            "Enterprise ServerCoreEdition","Enterprise Server Edition for Itanium-Based Systems","Business N Edition","Web Server Edition",`
                            "Cluster Server Edition","Home Server Edition","Storage Express Server Edition","Storage Standard Server Edition",`
                            "Storage Workgroup Server Edition","Storage Enterprise Server Edition","Server For Small Business Edition","Small Business Server Premium Edition")
                $ChassisModels = @("PlaceHolder","Maybe Virtual Machine","Unknown","Desktop","Thin Desktop","Pizza Box","Mini Tower","Full Tower","Portable",`
                                   "Laptop","Notebook","Hand Held","Docking Station","All in One","Sub Notebook","Space-Saving","Lunch Box","Main System Chassis",`
                                   "Lunch Box","SubChassis","Bus Expansion Chassis","Peripheral Chassis","Storage Chassis" ,"Rack Mount Unit","Sealed-Case PC")
                $NetConnectionStatus = @('Disconnected','Connecting','Connected','Disconnecting','Hardware not present','Hardware disabled','Hardware malfunction',`
                                         'Media disconnected','Authenticating','Authentication succeeded','Authentication failed','Invalid address','Credentials required')
                $MemoryModels = @("Unknown","Other","SIP","DIP","ZIP","SOJ","Proprietary","SIMM","DIMM","TSOP","PGA","RIMM",`
                                  "SODIMM","SRIMM","SMD","SSMP","QFP","TQFP","SOIC","LCC","PLCC","BGA","FPBGA","LGA")
                $MemoryDetail = @{
                    '1' = 'Reserved'
                    '2' = 'Other'
                    '4' = 'Unknown'
                    '8' = 'Fast-paged'
                    '16' = 'Static column'
                    '32' = 'Pseudo-static'
                    '64' = 'RAMBUS'
                    '128' = 'Synchronous'
                    '256' = 'CMOS'
                    '512' = 'EDO'
                    '1024' = 'Window DRAM'
                    '2048' = 'Cache DRAM'
                    '4096' = 'Nonvolatile'
                }

                # Modify this variable to change your default set of display properties
                $defaultProperties = @('ComputerName','IsVirtual','Model','ChassisModel','SerialNumber','OperatingSystem','OSServicePack','OSVersion','OSSKU', `
                                       'OSArchitecture','SystemArchitecture','PhysicalMemoryTotal','PhysicalMemoryFree','VirtualMemoryTotal', `
                                       'VirtualMemoryFree','CPUCores','CPUSockets','SystemTime','LastBootTime','InstallDate','Uptime')
                # WMI Properties
                $WMI_OSProps = @('BuildNumber','Version','SerialNumber','ServicePackMajorVersion','CSDVersion','SystemDrive',`
                                 'SystemDirectory','WindowsDirectory','Caption','TotalVisibleMemorySize','FreePhysicalMemory',`
                                 'TotalVirtualMemorySize','FreeVirtualMemory','OSArchitecture','Organization','LocalDateTime',`
                                 'RegisteredUser','OperatingSystemSKU','OSType','LastBootUpTime','InstallDate')
                $WMI_ProcProps = @('Name','Description','MaxClockSpeed','CurrentClockSpeed','AddressWidth','NumberOfCores','NumberOfLogicalProcessors', `
                                   'DataWidth')
                $WMI_CompProps = @('DNSHostName','Domain','Manufacturer','Model','NumberOfLogicalProcessors','NumberOfProcessors','PrimaryOwnerContact', `
                                   'PrimaryOwnerName','TotalPhysicalMemory','UserName')
                $WMI_ChassisProps = @('ChassisTypes','Manufacturer','SerialNumber','Tag','SKU')
                $WMI_BIOSProps = @('Version','SerialNumber')
                
                # WMI data
                $wmi_compsystem = Get-WmiObject @WMIHast -Class Win32_ComputerSystem | select $WMI_CompProps
                $wmi_os = Get-WmiObject @WMIHast -Class Win32_OperatingSystem | select $WMI_OSProps
                $wmi_proc = Get-WmiObject @WMIHast -Class Win32_Processor | select $WMI_ProcProps
                $wmi_chassis = Get-WmiObject @WMIHast -Class Win32_SystemEnclosure | select $WMI_ChassisProps
                $wmi_bios = Get-WmiObject @WMIHast -Class Win32_BIOS | select $WMI_BIOSProps

                ## Calculated properties
                # CPU count
                if (@($wmi_proc)[0].NumberOfCores) #Modern OS
                {
                    $Sockets = @($wmi_proc).Count
                    $Cores = ($wmi_proc | Measure-Object -Property NumberOfLogicalProcessors -Sum).Sum
                    $OSArchitecture = "x" + $(@($wmi_proc)[0]).AddressWidth
                    $SystemArchitecture = "x" + $(@($wmi_proc)[0]).DataWidth
                }
                else #Legacy OS
                {
                    $Sockets = @($wmi_proc | Select-Object -Property SocketDesignation -Unique).Count
                    $Cores = @($wmi_proc).Count
                    $OSArchitecture = "x" + ($wmi_proc | Select-Object -First 1 -Property AddressWidth).AddressWidth
                    $SystemArchitecture = "x" + ($wmi_proc | Select-Object -First 1 -Property DataWidth).DataWidth
                }
                
                # OperatingSystemSKU is not availble in 2003 and XP
                if ($wmi_os.OperatingSystemSKU -ne $null)
                {
                    $OS_SKU = $SKUs[$wmi_os.OperatingSystemSKU]
                }
                else
                {
                    $OS_SKU = 'Not Available'
                }
               
                $temptime = ([wmi]'').ConvertToDateTime($wmi_os.LocalDateTime)
                $System_Time = "$($temptime.ToShortDateString()) $($temptime.ToShortTimeString())"

                $temptime = ([wmi]'').ConvertToDateTime($wmi_os.LastBootUptime)
                $OS_LastBoot = "$($temptime.ToShortDateString()) $($temptime.ToShortTimeString())"
                
                $temptime = ([wmi]'').ConvertToDateTime($wmi_os.InstallDate)
                $OS_InstallDate = "$($temptime.ToShortDateString()) $($temptime.ToShortTimeString())"
                
                $Uptime = New-TimeSpan -Start $OS_LastBoot -End $System_Time
                $IsVirtual = $false
                $VirtualType = ''
                if ($wmi_bios.Version -match "VIRTUAL") 
                {
                    $IsVirtual = $true
                    $VirtualType = "Virtual - Hyper-V"
                }
                elseif ($wmi_bios.Version -match "A M I") 
                {
                    $IsVirtual = $true
                    $VirtualType = "Virtual - Virtual PC"
                }
                elseif ($wmi_bios.Version -like "*Xen*") 
                {
                    $IsVirtual = $true
                    $VirtualType = "Virtual - Xen"
                }
                elseif ($wmi_bios.SerialNumber -like "*VMware*")
                {
                    $IsVirtual = $true
                    $VirtualType = "Virtual - VMWare"
                }
                elseif ($wmi_compsystem.manufacturer -like "*Microsoft*")
                {
                    $IsVirtual = $true
                    $VirtualType = "Virtual - Hyper-V"
                }
                elseif ($wmi_compsystem.manufacturer -like "*VMWare*")
                {
                    $IsVirtual = $true
                    $VirtualType = "Virtual - VMWare"
                }
                elseif ($wmi_compsystem.model -like "*Virtual*")
                {
                    $IsVirtual = $true
                    $VirtualType = "Unknown Virtual Machine"
                }
                $ResultProperty = @{
                    ### Defaults
                    'PSComputerName' = $ComputerName
                    'IsVirtual' = $IsVirtual
                    'VirtualType' = $VirtualType 
                    'Model' = $wmi_compsystem.Model
                    'ChassisModel' = $ChassisModels[$wmi_chassis.ChassisTypes[0]]
                    'SerialNumber' = $wmi_bios.SerialNumber
                    'ComputerName' = $wmi_compsystem.DNSHostName                        
                    'OperatingSystem' = $wmi_os.Caption
                    'OSServicePack' = $wmi_os.ServicePackMajorVersion
                    'OSVersion' = $wmi_os.Version
                    'OSSKU' = $OS_SKU
                    'OSArchitecture' = $OSArchitecture
                    'SystemArchitecture' = $SystemArchitecture
                    'PercentPhysicalMemoryUsed' = [math]::round(((($wmi_os.TotalVisibleMemorySize - $wmi_os.FreePhysicalMemory)/$wmi_os.TotalVisibleMemorySize) * 100),2)
                    'PhysicalMemoryTotal' = ($wmi_os.TotalVisibleMemorySize * 1024) | ConvertTo-KMG
                    'PhysicalMemoryFree' = ($wmi_os.FreePhysicalMemory * 1024) | ConvertTo-KMG
                    'VirtualMemoryTotal' = ($wmi_os.TotalVirtualMemorySize * 1024) | ConvertTo-KMG
                    'VirtualMemoryFree' = ($wmi_os.FreeVirtualMemory * 1024) | ConvertTo-KMG
                    'CPUCores' = $Cores
                    'CPUSockets' = $Sockets
                    'LastBootTime' = $OS_LastBoot
                    'InstallDate' = $OS_InstallDate
                    'SystemTime' = $System_Time
                    'Uptime' = "$($Uptime.days) days $($Uptime.hours) hours $($Uptime.minutes) minutes"
                    '_BIOS' = $wmi_bios
                    '_OS' = $wmi_os
                    '_System' = $wmi_compsystem
                    '_Processor' = $wmi_proc
                    '_Chassis' = $wmi_chassis
                }
                #endregion GeneralInfo
                
                #region Memory
                if ($IncludeMemoryInfo)
                {
                    Write-Verbose -Message ('Remote Asset Information: Runspace {0}: Memory information' -f $ComputerName)
                    $WMI_MemProps = @('BankLabel','DeviceLocator','Capacity','PartNumber','Speed','Tag','FormFactor','TypeDetail')
                    $WMI_MemArrayProps = @('Tag','MemoryDevices','MaxCapacity')
                    $wmi_memory = Get-WmiObject @WMIHast -Class Win32_PhysicalMemory | select $WMI_MemProps
                    $wmi_memoryarray = Get-WmiObject @WMIHast -Class Win32_PhysicalMemoryArray | select $WMI_MemArrayProps
                    
                    # Memory Calcs
                    $Memory_Slotstotal = 0
                    $Memory_SlotsUsed = (@($wmi_memory)).Count                
                    @($wmi_memoryarray) | % {$Memory_Slotstotal = $Memory_Slotstotal + $_.MemoryDevices}
                    
                    # Add to the existing property set
                    $ResultProperty.MemorySlotsTotal = $Memory_Slotstotal
                    $ResultProperty.MemorySlotsUsed = $Memory_SlotsUsed
                    $ResultProperty._MemoryArray = $wmi_memoryarray
                    $ResultProperty._Memory = $wmi_memory
                    
                    # Add a few of these properties to our default property set
                    $defaultProperties += 'MemorySlotsTotal'
                    $defaultProperties += 'MemorySlotsUsed'
                    
                    # Add a more detailed memory slot utilization object array (cause I'm nice)
                    $membankcounter = 1
                    $MemorySlotOutput = @()
                    foreach ($obj1 in $wmi_memoryarray)
                    {
                        $slots = $obj1.MemoryDevices + 1
                            
                        foreach ($obj2 in $wmi_memory)
                        {
                            if($obj2.BankLabel -eq "")
                            {
                                $MemLabel = $obj2.DeviceLocator
                            }
                            else
                            {
                                $MemLabel = $obj2.BankLabel
                            }       
                            $slotprops = @{
                                'Bank' = "Bank " + $membankcounter
                                'Label' = $MemLabel
                                'Capacity' = $obj2.Capacity/1024/1024
                                'Speed' = $obj2.Speed
                                'FormFactor' = $MemoryModels[$obj2.FormFactor]
                                'Detail' = $MemoryDetail[[string]$obj2.TypeDetail]
                            }
                            $MemorySlotOutput += New-Object PSObject -Property $slotprops
                            $membankcounter = $membankcounter + 1
                        }
                        while($membankcounter -lt $slots)
                        {
                            $slotprops = @{
                                'Bank' = "Bank " + $membankcounter
                                'Label' = "EMPTY"
                                'Capacity' = ''
                                'Speed' = ''
                                'FormFactor' = "EMPTY"
                                'Detail' = "EMPTY"
                            }
                            $MemorySlotOutput += New-Object PSObject -Property $slotprops
                            $membankcounter = $membankcounter + 1
                        }
                    }
                    $ResultProperty._MemorySlots = $MemorySlotOutput
                }
                #endregion Memory
                
                #region Network
                if ($IncludeNetworkInfo)
                {
                    Write-Verbose -Message ('Remote Asset Information: Runspace {0}: Network information' -f $ComputerName)
                    $wmi_netadapters = Get-WmiObject @WMIHast -Class Win32_NetworkAdapter
                    $alladapters = @()
                    ForEach ($adapter in $wmi_netadapters)
                    {  
                        $wmi_netconfig = Get-WmiObject @WMIHast -Class Win32_NetworkAdapterConfiguration `
                                                                -Filter "Index = '$($Adapter.Index)'"
                        $wmi_promisc = Get-WmiObject @WMIHast -Class MSNdis_CurrentPacketFilter `
                                                              -Namespace 'root\WMI' `
                                                              -Filter "InstanceName = '$($Adapter.Name)'"
                        $promisc = $False
                        if ($wmi_promisc.NdisCurrentPacketFilter -band 0x00000020)
                        {
                            $promisc = $True
                        }
                        
                        $NetConStat = ''
                        if ($adapter.NetConnectionStatus -ne $null)
                        {
                            $NetConStat = $NetConnectionStatus[$adapter.NetConnectionStatus]
                        }
                        $alladapters += New-Object PSObject -Property @{
                              NetworkName = $adapter.NetConnectionID
                              AdapterName = $adapter.Name
                              ConnectionStatus = $NetConStat
                              Index = $wmi_netconfig.Index
                              IpAddress = $wmi_netconfig.IpAddress
                              IpSubnet = $wmi_netconfig.IpSubnet
                              MACAddress = $wmi_netconfig.MACAddress
                              DefaultIPGateway = $wmi_netconfig.DefaultIPGateway
                              Description = $wmi_netconfig.Description
                              InterfaceIndex = $wmi_netconfig.InterfaceIndex
                              DHCPEnabled = $wmi_netconfig.DHCPEnabled
                              DHCPServer = $wmi_netconfig.DHCPServer
                              DNSDomain = $wmi_netconfig.DNSDomain
                              DNSDomainSuffixSearchOrder = $wmi_netconfig.DNSDomainSuffixSearchOrder
                              DomainDNSRegistrationEnabled = $wmi_netconfig.DomainDNSRegistrationEnabled
                              WinsPrimaryServer = $wmi_netconfig.WinsPrimaryServer
                              WinsSecondaryServer = $wmi_netconfig.WinsSecondaryServer
                              PromiscuousMode = $promisc
                       }
                    }
                    $ResultProperty._Network = $alladapters
                }                    
                #endregion Network
                
                #region Disk
                if ($IncludeDiskInfo)
                {
                    Write-Verbose -Message ('Remote Asset Information: Runspace {0}: Disk information' -f $ComputerName)
                    $WMI_DiskPartProps    = @('DiskIndex','Index','Name','DriveLetter','Caption','Capacity','FreeSpace','SerialNumber')
                    $WMI_DiskVolProps     = @('Name','DriveLetter','Caption','Capacity','FreeSpace','SerialNumber')
                    $WMI_DiskMountProps   = @('Name','Label','Caption','Capacity','FreeSpace','Compressed','PageFilePresent','SerialNumber')
                    
                    # WMI data
                    $wmi_diskdrives = Get-WmiObject @WMIHast -Class Win32_DiskDrive | select $WMI_DiskDriveProps
                    $wmi_mountpoints = Get-WmiObject @WMIHast -Class Win32_Volume -Filter "DriveType=3 AND DriveLetter IS NULL" | select $WMI_DiskMountProps
                    
                    $AllDisks = @()
                    foreach ($diskdrive in $wmi_diskdrives) 
                    {
                        $partitionquery = "ASSOCIATORS OF {Win32_DiskDrive.DeviceID=`"$($diskdrive.DeviceID.replace('\','\\'))`"} WHERE AssocClass = Win32_DiskDriveToDiskPartition"
                        $partitions = @(Get-WmiObject @WMIHast -Query $partitionquery)
                        foreach ($partition in $partitions)
                        {
                            $logicaldiskquery = "ASSOCIATORS OF {Win32_DiskPartition.DeviceID=`"$($partition.DeviceID)`"} WHERE AssocClass = Win32_LogicalDiskToPartition"
                            $logicaldisks = @(Get-WmiObject @WMIHast -Query $logicaldiskquery)
                            foreach ($logicaldisk in $logicaldisks)
                            {
                               $diskprops = @{
                                               Disk = $diskdrive.Name
                                               Model = $diskdrive.Model
                                               Partition = $partition.Name
                                               Description = $partition.Description
                                               PrimaryPartition = $partition.PrimaryPartition
                                               VolumeName = $logicaldisk.VolumeName
                                               Drive = $logicaldisk.Name
                                               DiskSize = $logicaldisk.Size | ConvertTo-KMG
                                               FreeSpace = $logicaldisk.FreeSpace | ConvertTo-KMG
                                               PercentageFree = [math]::round((($logicaldisk.FreeSpace/$logicaldisk.Size)*100), 2)
                                               DiskType = 'Partition'
                                               SerialNumber = $diskdrive.SerialNumber
                                             }
                                $AllDisks += New-Object psobject -Property $diskprops
                            }
                        }
                    }
                    # Mountpoints are wierd so we do them seperate.
                    if ($wmi_mountpoints)
                    {
                        foreach ($mountpoint in $wmi_mountpoints)
                        {                    
                            $diskprops = @{
                                   Disk = $mountpoint.Name
                                   Model = ''
                                   Partition = ''
                                   Description = $mountpoint.Caption
                                   PrimaryPartition = ''
                                   VolumeName = ''
                                   VolumeSerialNumber = ''
                                   Drive = [Regex]::Match($mountpoint.Caption, "^.:\\").Value
                                   DiskSize = $mountpoint.Capacity  | ConvertTo-KMG
                                   FreeSpace = $mountpoint.FreeSpace  | ConvertTo-KMG
                                   PercentageFree = [math]::round((($mountpoint.FreeSpace/$mountpoint.Capacity)*100), 2)
                                   DiskType = 'MountPoint'
                                   SerialNumber = $mountpoint.SerialNumber
                                 }
                            $AllDisks += New-Object psobject -Property $diskprops
                        }
                    }
                    $ResultProperty._Disks = $AllDisks
                }
                #endregion Disk
                
                # Final output
                $ResultObject = New-Object -TypeName PSObject -Property $ResultProperty

                # Setup the default properties for output
                $ResultObject.PSObject.TypeNames.Insert(0,'My.Asset.Info')
                $defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet(‘DefaultDisplayPropertySet’,[string[]]$defaultProperties)
                $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
                $ResultObject | Add-Member MemberSet PSStandardMembers $PSStandardMembers

                Write-Output -InputObject $ResultObject
            }
            catch
            {
                Write-Warning -Message ('Remote Asset Information: {0}: {1}' -f $ComputerName, $_.Exception.Message)
            }
            Write-Verbose -Message ('Remote Asset Information: Runspace {0}: End' -f $ComputerName)
        }
 
        function Get-Result
        {
            [CmdletBinding()]
            Param 
            (
                [switch]$Wait
            )
            do
            {
                $More = $false
                foreach ($runspace in $runspaces)
                {
                    $StartTime = $runspacetimers[$runspace.ID]
                    if ($runspace.Handle.isCompleted)
                    {
                        Write-Verbose -Message ('Remote Asset Information: Thread done for {0}' -f $runspace.IObject)
                        $runspace.PowerShell.EndInvoke($runspace.Handle)
                        $runspace.PowerShell.Dispose()
                        $runspace.PowerShell = $null
                        $runspace.Handle = $null
                    }
                    elseif ($runspace.Handle -ne $null)
                    {
                        $More = $true
                    }
                    if ($Timeout -and $StartTime)
                    {
                        if ((New-TimeSpan -Start $StartTime).TotalSeconds -ge $Timeout -and $runspace.PowerShell)
                        {
                            Write-Warning -Message ('Timeout {0}' -f $runspace.IObject)
                            $runspace.PowerShell.Dispose()
                            $runspace.PowerShell = $null
                            $runspace.Handle = $null
                        }
                    }
                }
                if ($More -and $PSBoundParameters['Wait'])
                {
                    Start-Sleep -Milliseconds 100
                }
                foreach ($threat in $runspaces.Clone())
                {
                    if ( -not $threat.handle)
                    {
                        Write-Verbose -Message ('Remote Asset Information: Removing {0} from runspaces' -f $threat.IObject)
                        $runspaces.Remove($threat)
                    }
                }
                if ($ShowProgress)
                {
                    $ProgressSplatting = @{
                        Activity = 'Remote Asset Information: Getting asset info'
                        Status = '{0} of {1} total threads done' -f ($bgRunspaceCounter - $runspaces.Count), $bgRunspaceCounter
                        PercentComplete = ($bgRunspaceCounter - $runspaces.Count) / $bgRunspaceCounter * 100
                    }
                    Write-Progress @ProgressSplatting
                }
            }
            while ($More -and $PSBoundParameters['Wait'])
        }
    }
    PROCESS
    {
        foreach ($Computer in $ComputerName)
        {
            $bgRunspaceCounter++
            $psCMD = [System.Management.Automation.PowerShell]::Create().AddScript($ScriptBlock)
            $null = $psCMD.AddParameter('bgRunspaceID',$bgRunspaceCounter)
            $null = $psCMD.AddParameter('ComputerName',$Computer)
            $null = $psCMD.AddParameter('IncludeMemoryInfo',$IncludeMemoryInfo)
            $null = $psCMD.AddParameter('IncludeDiskInfo',$IncludeDiskInfo)
            $null = $psCMD.AddParameter('IncludeNetworkInfo',$IncludeNetworkInfo)
            $null = $psCMD.AddParameter('Verbose',$VerbosePreference)               # Passthrough the hidden verbose option so write-verbose works within the runspaces
            $psCMD.RunspacePool = $rp
 
            Write-Verbose -Message ('Remote Asset Information: Starting {0}' -f $Computer)
            [void]$runspaces.Add(@{
                Handle = $psCMD.BeginInvoke()
                PowerShell = $psCMD
                IObject = $Computer
                ID = $bgRunspaceCounter
                })
           Get-Result
        }
    }
 
    End
    {
        Get-Result -Wait
        if ($ShowProgress)
        {
            Write-Progress -Activity 'Remote Asset Information: Getting asset info' -Status 'Done' -Completed
        }
        Write-Verbose -Message "Remote Asset Information: Closing runspace pool"
        $rp.Close()
        $rp.Dispose()
    }
}



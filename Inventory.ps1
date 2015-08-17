

$Header = @"
<style>
TABLE {border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}
TH {border-width: 1px;padding: 3px;border-style: solid;border-color: black;background-color: #6495ED;}
TD {border-width: 1px;padding: 3px;border-style: solid;border-color: black;}
TR:Nth-Child(Even) {Background-Color: #dddddd;}
TR:Hover TD {Background-Color: #C1D5F8;}
</style>
<title>
DNS Phonebook By Mac and Hostname
</title>
"@


$today = Get-Date
$cutoffdate = $today.AddDays(-15)

Get-ADComputer  -Properties * -Filter {LastLogonDate -gt $cutoffdate}|Select -Expand DNSHostName  | out-file C:\All-Computers.txt
$ComputerList = get-content "C:\All-Computers.txt"
$Amount = $ComputerList.count
$a=0

foreach ($hosts in $ComputerList) 
        {
                        $Ping = Test-Path "\\$hosts\C$" -ErrorAction SilentlyContinue
                        if ($Ping -eq "True") 
                           {
                                echo $hosts >> "C:\Online-Computers.txt"
                                  $a++
                                    Write-Progress -Activity "Working..." -CurrentOperation "$a complete of $Amount"  -Status "Please wait testing connections" 

                                
                           }

        }

$allhost = get-content "C:\Online-Computers.txt"
"Hostname,MAC Address,Serial Number" >> C:\Inventory.csv
$a=0
$OnlineAmount = $allhost.count

foreach ($computer in $allhost) {

$Networks = Get-WmiObject Win32_NetworkAdapterConfiguration -ComputerName $computer | ? {$_.IPEnabled}
   foreach ($Network in $Networks) {
    $IsDHCPEnabled = $false
    If($Network.DHCPEnabled) {
     $IsDHCPEnabled = $true
         }
          $mac = $Network.MACAddress
         }

      $enclosure = Get-WmiObject -Class win32_systemenclosure -ComputerName $computer
        $serial = $enclosure.SerialNumber
          $output = $computer + "," + $mac + "," + $serial
            $output >> C:\Inventory.csv
               $a++
                    
                         
          Write-Progress -Activity "Working..." -CurrentOperation "$a complete of $OnlineAmount"  -Status "Please wait testing connections"
    }


        Del "C:\Online-Computers.txt"
           Del "C:\All-Computers.txt"

          Import-Csv C:\Inventory.csv | ConvertTo-Html -Head $Header | Out-File \\nas\it\james\OUTFILE\Inventory.html


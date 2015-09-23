$server = "sql"
$today = get-date -Format "MM.dd.yy"
$yesterday = (get-date) - (New-TimeSpan -day 1)
$ns = @{e = "http://schemas.microsoft.com/win/2004/08/events/event"}
$out = @()
$evts = Get-WinEvent -ComputerName $server -FilterHashtable @{logname="security";id="4663"} -oldest
    foreach($evt in $evts)
        {        
        $xml = [xml]$evt.ToXml()
        $SubjectUserName = Select-Xml -Xml $xml -Namespace $ns -XPath "//e:Data[@Name='SubjectUserName']/text()" | Select-Object -ExpandProperty Node | Select-Object -ExpandProperty Value
        $ObjectName = Select-Xml -Xml $xml -Namespace $ns -XPath "//e:Data[@Name='ObjectName']/text()" | Select-Object -ExpandProperty Node | Select-Object -ExpandProperty Value
        $AccessMask = (Select-Xml -Xml $xml -Namespace $ns -XPath "//e:Data[@Name='AccessMask']/text()" | Select-Object -ExpandProperty Node | Select-Object -ExpandProperty Value)-replace "0x100000", "Write Access (Synchronize)" ` -replace "0x80000", "Change Ownership" ` -replace "0x40000", "Modify Security" ` -replace "0x20000", "Read Access (Security)" ` -replace "0x10000", "Delete operation" ` -replace "0x100", "Write Access (Attributes)" ` -replace "0x80", "Read Access (Attributes)" ` -replace "0x40","Delete operation" ` -replace "0x20", "Read operation" ` -replace "0x10", "Write operation (Attributes)" ` -replace "0x8", "Read operation (Attributes)" ` -replace "0x4", "Write operation (Append)" ` -replace "0x2", "Write operation" ` -replace "0x1", "Write operation" ` -replace "0x0", "Read operation"
        $AccessEvent = New-Object System.Object
        $AccessEvent | Add-Member -type NoteProperty -Name UserName -Value $SubjectUserName
        $AccessEvent | Add-Member -type NoteProperty -Name Object -Value $ObjectName
        $AccessEvent | Add-Member -type NoteProperty -Name AccessType -Value $AccessMask
        $AccessEvent | Add-Member -type NoteProperty -Name Time -Value $evt.TimeCreated
        if($AccessEvent.UserName -eq "$server$"){$AccessEvent = $null} #avoid default logged events from c:\windows
        $out += $AccessEvent
        }
$out | where-object {$_} | Export-CSV -path C:\$today.csv -UseCulture -NoTypeInformation
 
$count = Import-Csv C:\$today.csv | Measure-Object | select -ExpandProperty count
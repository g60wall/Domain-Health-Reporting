$Header = @"
<style>
TABLE {border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}
TH {border-width: 1px;padding: 3px;border-style: solid;border-color: black;background-color: #6495ED;}
TD {border-width: 1px;padding: 3px;border-style: solid;border-color: black;}
TR:Nth-Child(Even) {Background-Color: #dddddd;}
TR:Hover TD {Background-Color: #C1D5F8;}
</style>
<title>
Last 7 Days EVENT LOG ERRORS
</title>
"@
$pre = "Last 7 days"
$servers = 'pdc','mail','sql','dcx','cn2','cn4'

$winEventErrors = Invoke-Command -ComputerName $Servers -ScriptBlock {$startDate = (Get-date).AddDays(-7); try{Get-WinEvent -FilterHashtable @{LogName="System";StartTime=$startDate;Level=2} -ErrorAction STOP}catch{Write-Warning -Message ('{0}->{1}' -f $env:ComputerName,$_.exception.message)} }
$winEventErrors | Group-Object -Property Id,MachineName,message | select @{n='ComputerName';e={ $_.Name.split(',')[1].trim() }},@{n='EventId';e={ $_.Name.split(',')[0].Trim()}},@{n='Message';e={ $_.Name.split(',')[2].trim() }},Count | sort count -Descending | ConvertTo-Html -Head $Header -precontent $pre | Out-File \\nas\it\james\OUTFILE\DomainERRORlog.html
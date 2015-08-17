$Header = @"
<style>
TABLE {border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}
TH {border-width: 1px;padding: 3px;border-style: solid;border-color: black;background-color: #6495ED;}
TD {border-width: 1px;padding: 3px;border-style: solid;border-color: black;}
TR:Nth-Child(Even) {Background-Color: #dddddd;}
TR:Hover TD {Background-Color: #C1D5F8;}
</style>
<title>
Domain Computer Details
</title>
"@

$ADComputerProperties = @(`
"Operatingsystem",
"OperatingSystemServicePack",
"Created",
"Enabled",
"LastLogonDate",
"IPv4Address",
"CanonicalName"
)
 
$SelectADComputerProperties = @(`
"Name",
"OperatingSystem",
"OperatingSystemServicePack",
"Created",
"Enabled",
"LastLogonDate",
"IPv4Address",
"CanonicalName"
)

Get-ADComputer -Filter * -Properties $ADComputerProperties  |  select $SelectADComputerProperties | ConvertTo-Html -Head $Header  | Out-File \\nas\it\james\OUTFILE\DIAGdomain.html


$restartCPU =Read-Host "Type Computer Name"
$reciever =Read-Host "Email Recipient"

Get-WinEvent -ComputerName $restartCPU -FilterHashtable @{logname='System'; id=1074}  | ForEach-Object {
$rv = New-Object PSObject | Select-Object Date, User, Action, Process, Reason, ReasonCode, Comment
$rv.Date = $_.TimeCreated
$rv.User = $_.Properties[6].Value
$rv.Process = $_.Properties[0].Value
$rv.Action = $_.Properties[4].Value
$rv.Reason = $_.Properties[2].Value
$rv.ReasonCode = $_.Properties[3].Value
$rv.Comment = $_.Properties[5].Value
$rv
} | Select-Object Date, Action, Reason, User | ConvertTo-Html | Out-File \\nas\it\james\OUTFILE\lastrestart.html

Send-MailMessage -From "administrator@braenstone.com" -To "$reciever" -Subject "Last Restart" -Body "Boom" -Attachments \\nas\it\james\OUTFILE\lastrestart.html -SmtpServer mail
########################################################################################################################################################
$From = "backupgmailaccount@gmail.com"          ########################################################################################################
$To = "youremail@gmail.com "        ####################################################################################################################
$Cc = "anotheremail@gmail.com"    ######################################################################################################################
$Subject = "CHECK Mail Server"     #####################################################################################################################
$Body = "Port 25 is not responding Check it out"  ######################################################################################################
$SMTPServer = "smtp.gmail.com"   #######################################################################################################################
$SMTPPort = "587"     ##################################################################################################################################
$credentials = new-object Management.Automation.PSCredential “backupgmailaccount@gmail.com”, (“password” | ConvertTo-SecureString -AsPlainText -Force) #
########################################################################################################################################################


#######Created by: James Wall and Curtis Smith #################################
########### START OF TEST ######################################################

$result = Test-NetConnection -ComputerName 8.8.8.8 -Port 25 -InformationLevel Quiet ## Aquire test result, assign var

    if ($result -match 'true') {
            start-sleep -Seconds 30 ## IF port is alive Wait 30 Second Before retest
            } else {
                    $failurestart = Get-Date
                    $emailsent = $false
                    do {
                        $outage = New-TimeSpan -Start $failurestart -End (Get-Date)
                        If ($outage.Minutes -ge 5)  ## If port is not Responding for more than 5 minutes Send Email
                                {
                                 if($emailsent -eq $false)
                                        {
                                        Send-MailMessage -From $From -to $To -cc $cc -Subject $Subject -Body $Body -SmtpServer $SMTPServer -port $SMTPPort -UseSsl -Credential $Credentials
                                        $emailsent = $true
                                        } 
                                }
                        Start-Sleep -Seconds 5
                        $result = Test-NetConnection -ComputerName 8.8.8.8 -Port 25 -InformationLevel Quiet ## Aquire test result, assign var
                        } Until ($result -match 'true') }
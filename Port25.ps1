########################################################################################################################################################
$From = "FromYourEmail@gmail.com"          #############################################################################################################
$To = "RecipiantEmail@gmail.com "        ###############################################################################################################
$Subject = "CHECK YourDomain"       ####################################################################################################################
$Body = "Port 25 is not responding Check it out"  ######################################################################################################
$SMTPServer = "smtp.gmail.com"   #######################################################################################################################
$SMTPPort = "587"     ##################################################################################################################################
$credentials = new-object Management.Automation.PSCredential “youremail@gmail.com”, (“yourpassword” | ConvertTo-SecureString -AsPlainText -Force) ##
########################################################################################################################################################

### Change 8.8.8.8 to your hostname/IP address
### This will need 3 and half minutes of none success before it send an email


 $fail = 0
for($i = 0; $i -lt 10; $i++){
	if(Test-NetConnection 8.8.8.8 -Port 25 -InformationLevel Quiet){"Port Open"}
	else{
		$fail ++
		if ($fail -eq 10){
			Send-MailMessage -From $From -to $To -Cc $Cc -Subject $Subject -Body $Body -SmtpServer $SMTPServer -port $SMTPPort -UseSsl -Credential $Credentials
		}
	}
}

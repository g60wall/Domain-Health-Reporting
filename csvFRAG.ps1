##################################################################################################################################################################################
$From = "youremail@gmail.com" ############################################################################################################################################
$To = "whoyouarsending@gmail.com "        ################################################################################################################################################
$Cc = "whoelseyouraresending@gmail.com"    ################################################################################################################################################
$Subject = "Cluster Defrag Warning"     ##########################################################################################################################################
$Body = "Cluster Shared Volume `n the drive is $fragmentation% fragmented  `n Copy and Run this command on Cluster Node 2 `ndefrag C:\ClusterStorage\Volume1"  ###################
$SMTPServer = "smtp.gmail.com"   #################################################################################################################################################
$SMTPPort = "587"     ############################################################################################################################################################
$credentials = new-object Management.Automation.PSCredential “haledonbraenstone@gmail.com”, (“yourpassword” | ConvertTo-SecureString -AsPlainText -Force) ############################
##################################################################################################################################################################################
$csvloc = "c:\clusterstorage\Volume1"
$chk = defrag $csvloc /A 
[int]$fragmentation = ((($chk | Select-String 'Total fragmented space') -split '=') -replace '%','').trim()[1]

if($fragmentation -gt 8)
  {
   Send-MailMessage -From $From -to $To -cc $cc -Subject $Subject -Body $Body -SmtpServer $SMTPServer -port $SMTPPort -UseSsl -Credential $Credentials
  }else{}
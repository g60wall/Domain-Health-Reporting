######Script Start######
#load Active Directory module#
import-module ActiveDirectory  
####Customizable Variables####
#Location of HTML File#
$report = ".\ADReport.html"
#Various Variables#
#This is used for designating the domain. This filler example would search under the SOMETHING.COM domain#
$searchCriteria = "DC=Braenstone, DC=Local"
$inactiveDate = (Get-Date).AddDays(-30)
$createdDate = (Get-Date).AddDays(-7)
$tableCoding = {
<table width='100%'>  
<tr bgcolor='#CCCCCC'>
<td width='15%' align='center'>Identifier</td>  
<td width='15%' align='center'>Name</td>  
<td width='15%' align='center'>Last Modified</td>   
<td width='55%' align='center'>Description</td>   
</tr>}
##Queries AD for Information##
$DisabledUsers = Get-ADUser -filter {(Enabled -eq $False)} -Searchbase $searchCriteria -Searchscope Subtree -Properties Name,SID,Enabled,LastLogonDate,Modified,info,description 
$DisabledComputers = Get-ADComputer -filter {(Enabled -eq $False)} -Searchbase $searchCriteria -Searchscope Subtree -Properties Name,SID,Enabled,LastLogonDate,Modified,info,description 
$LockedAccounts = Search-ADAccount -Searchbase $searchCriteria -Searchscope Subtree -LockedOut | select Name,Modified,description
$EnterpriseAdmins = Get-ADGroupMember -identity "Enterprise Admins" | select Name,Modified,description
$RegularAdmins = Get-ADGroupMember -identity "Administrators" | select Name,Modified,description
$DomainAdmins = Get-ADGroupMember -identity "Domain Admins" | select Name,Modified,description
$EmptyGroups = Get-ADGroup -filter {GroupCategory -eq 'Security'} | ?{@(Get-ADGroupMember $_).Length -eq 0} | Select Name
$MissingEmail = Get-ADUser -filter {Enabled -eq $True -and -not mail -like "*"} -Searchbase $searchCriteria -Searchscope Subtree -Properties Name,SID,Enabled,LastLogonDate,Modified,info,description 
$InactiveUsers = Get-ADUser -Searchbase $searchCriteria -Searchscope Subtree -filter * -Properties lastlogondate,Modified,description  | Where-Object {($_.lastlogondate -le $inactiveDate -or $_.lastlogondate -notlike "*") -and ($_.Enabled -eq $True)}
$InactiveComputers = Get-ADComputer -Searchbase $searchCriteria -Searchscope Subtree -filter * -Properties lastlogondate,Modified,description  | Where-Object {($_.lastlogondate -le $inactiveDate -or $_.lastlogondate -notlike "*") -and ($_.Enabled -eq $True)}
$RecentNewUsers = Get-ADUser -Filter {whenCreated -ge $createdDate} -Properties whenCreated,Name,Modified,Description
$NeverLoggedOn = Get-ADUser -Searchbase $searchCriteria -Searchscope Subtree -filter * -Properties lastlogondate,Modified,description  | Where-Object {($_.lastlogondate -notlike "*")}               
##Clears the report in case there is data in it##
Clear-Content $report 
##Builds the headers and formatting for the HTML Document##
Add-Content $report "<html>"  
Add-Content $report "<head>"  
Add-Content $report "<meta http-equiv='Content-Type' content='text/html; charset=iso-8859-1'>"  
Add-Content $report '<title>Active Directory Report</title>'  
add-content $report '<STYLE TYPE="text/css">'  
add-content $report "<!--"  
add-content $report "td {"  
add-content $report "font-family: Verdana;"  
add-content $report "font-size: 12px;"  
add-content $report "border-top: 1px solid #999999;"  
add-content $report "border-right: 1px solid #999999;"  
add-content $report "border-bottom: 1px solid #999999;"  
add-content $report "border-left: 1px solid #999999;"  
add-content $report "padding-top: 0px;"  
add-content $report "padding-right: 0px;"  
add-content $report "padding-bottom: 0px;"  
add-content $report "padding-left: 0px;"  
add-content $report "}"  
add-content $report "body {"  
add-content $report "margin-left: 5px;"  
add-content $report "margin-top: 5px;"  
add-content $report "margin-right: 0px;"  
add-content $report "margin-bottom: 10px;"  
add-content $report ""  
add-content $report "table {"  
add-content $report "border: thin solid #000000;"  
add-content $report "}"  
add-content $report "-->"  
add-content $report "</style>"  
Add-Content $report "</head>"  
add-Content $report "<body>"  
##This section adds tables to the report with individual content##
##Table for Locked Out Users##
if ($LockedAccounts -ne $null) {  
	Add-content $report  "$tableCoding"
    foreach ($Name in $LockedAccounts) {
        $ID = "Locked Out"   
        $AccountName = $name.name
        $LastChgd = $name.modified
        $UserDesc = $name.description 
        Add-Content $report "<tr>"
        Add-Content $report "<td><b>$ID</b></td>"  
        Add-Content $report "<td>$AccountName</td>"  
        Add-Content $report "<td>$LastChgd</td>"  
        add-Content $report "<td>$UserDesc</td>" 
        Add-Content $report "</tr>"
	}
	Add-content $report  "</table>"
}
##Table for Users without Emails##
if ($MissingEmail -ne $null) {
	Add-content $report  "$tableCoding"
    foreach ($Name in $MissingEmail) {
        $ID = "Missing Email"   
        $AccountName = $name.name
        $LastChgd = $name.modified
        $UserDesc = $name.description 
        Add-Content $report "<tr>"
        Add-Content $report "<td><b>$ID</b></td>"   
        Add-Content $report "<td>$AccountName</td>"  
        Add-Content $report "<td>$LastChgd</td>"  
        add-Content $report "<td>$UserDesc</td>" 
        Add-Content $report "</tr>"
	}
	Add-content $report  "</table>"
}
##Table for Domain Admins##
if ($DomainAdmins -ne $null) {  
	Add-content $report  "$tableCoding"
    foreach ($Name in $DomainAdmins) {
        $ID = "Domain Admin"   
        $AccountName = $name.name
        $LastChgd = $name.modified
        $UserDesc = $name.description 
        Add-Content $report "<tr>"
        Add-Content $report "<td><b>$ID</b></td>"  
        Add-Content $report "<td>$AccountName</td>"  
        Add-Content $report "<td>$LastChgd</td>"  
        add-Content $report "<td>$UserDesc</td>" 
        Add-Content $report "</tr>"
	}
	Add-content $report  "</table>"
}
##Table for Admins##
if ($RegularAdmins -ne $null) {  
	Add-content $report  "$tableCoding"
    foreach ($Name in $RegularAdmins) {
        $ID = "Regular Admin"   
        $AccountName = $name.name
        $LastChgd = $name.modified
        $UserDesc = $name.description 
        Add-Content $report "<tr>"
        Add-Content $report "<td><b>$ID</b></td>"  
        Add-Content $report "<td>$AccountName</td>"  
        Add-Content $report "<td>$LastChgd</td>"  
        add-Content $report "<td>$UserDesc</td>" 
        Add-Content $report "</tr>"
	}
	Add-content $report  "</table>"
}
##Table for Enterprise Admins##
if ($EnterpriseAdmins -ne $null) { 
	Add-content $report  "$tableCoding"
    foreach ($Name in $EnterpriseAdmins) {
        $ID = "Enterprise Admin"   
        $AccountName = $name.name
        $LastChgd = $name.modified
        $UserDesc = $name.description 
        Add-Content $report "<tr>"
        Add-Content $report "<td><b>$ID</b></td>"  
        Add-Content $report "<td>$AccountName</td>"  
        Add-Content $report "<td>$LastChgd</td>"  
        add-Content $report "<td>$UserDesc</td>" 
        Add-Content $report "</tr>"
	}
	Add-content $report  "</table>"
}
##Table for Disabled Users##
if ($DisabledUsers -ne $null) {  
	Add-content $report  "$tableCoding"
    foreach ($Name in $DisabledUsers ){
        $ID = "Disabled User"   
        $AccountName = $name.name
        $LastChgd = $name.modified
        $UserDesc = $name.description 
        Add-Content $report "<tr>"
        Add-Content $report "<td><b>$ID</b></td>"   
        Add-Content $report "<td>$AccountName</td>"  
        Add-Content $report "<td>$LastChgd</td>"  
        add-Content $report "<td>$UserDesc</td>" 
        Add-Content $report "</tr>"
	}
	Add-content $report  "</table>"
}
##Table for Disabled Computers##
if ($DisabledComputers -ne $null) {  
	Add-content $report  "$tableCoding"
    foreach ($Name in $DisabledComputers) {
        $ID = "Disabled Computer"   
        $AccountName = $name.name
        $LastChgd = $name.modified
        $UserDesc = $name.description 
        Add-Content $report "<tr>"
        Add-Content $report "<td><b>$ID</b></td>"   
        Add-Content $report "<td>$AccountName</td>"  
        Add-Content $report "<td>$LastChgd</td>"  
        add-Content $report "<td>$UserDesc</td>" 
        Add-Content $report "</tr>"
	}
	Add-content $report  "</table>"
}
##Table for Inactive Users##
if ($InactiveUsers -ne $null) {  
	Add-content $report  "$tableCoding"
    foreach ($Name in $InactiveUsers) {
        $ID = "Inactive User"   
        $AccountName = $name.name
        $LastChgd = $name.modified
        $UserDesc = $name.description 
        Add-Content $report "<tr>"
        Add-Content $report "<td><b>$ID</b></td>"   
        Add-Content $report "<td>$AccountName</td>"  
        Add-Content $report "<td>$LastChgd</td>"  
        add-Content $report "<td>$UserDesc</td>" 
        Add-Content $report "</tr>"
	}
	Add-content $report  "</table>"
}
##Table for Inactive Computers##
if ($InactiveComputers -ne $null) {  
	Add-content $report  "$tableCoding"
    foreach ($Name in $InactiveComputers) {
        $ID = "Inactive Computer"   
        $AccountName = $name.name
        $LastChgd = $name.modified
        $UserDesc = $name.description 
        Add-Content $report "<tr>"
        Add-Content $report "<td><b>$ID</b></td>"   
        Add-Content $report "<td>$AccountName</td>"  
        Add-Content $report "<td>$LastChgd</td>"  
        add-Content $report "<td>$UserDesc</td>" 
        Add-Content $report "</tr>"
	}
	Add-content $report  "</table>"
}
##Table for New Users##
if ($RecentNewUsers -ne $null) {  
	Add-content $report  "$tableCoding"
    foreach ($Name in $RecentNewUsers) {
        $ID = "New User"   
        $AccountName = $name.name
        $LastChgd = $name.modified
        $UserDesc = $name.description 
        Add-Content $report "<tr>"
        Add-Content $report "<td><b>$ID</b></td>"   
        Add-Content $report "<td>$AccountName</td>"  
        Add-Content $report "<td>$LastChgd</td>"  
        add-Content $report "<td>$UserDesc</td>" 
        Add-Content $report "</tr>"
	}
	Add-content $report  "</table>"
}
##Table for Users Never Logged On##
if ($NeverLoggedOn -ne $null) { 
	Add-content $report  "$tableCoding"
    foreach ($Name in $NeverLoggedOn) {
        $ID = "Never Logged On"   
        $AccountName = $name.name
        $LastChgd = $name.modified
        $UserDesc = $name.description 
        Add-Content $report "<tr>"
        Add-Content $report "<td><b>$ID</b></td>"   
        Add-Content $report "<td>$AccountName</td>"  
        Add-Content $report "<td>$LastChgd</td>"  
        add-Content $report "<td>$UserDesc</td>" 
        Add-Content $report "</tr>"
	}
	Add-content $report  "</table>"
} 
##Table for Empty Groups##
if ($EmptyGroups -ne $null) {
	Add-content $report  "$tableCoding" 
    foreach ($Name in $EmptyGroups) {
        $ID = "Empty Group"   
        $AccountName = $name.name
        $LastChgd = $name.modified
        $UserDesc = $name.description 
        Add-Content $report "<tr>"
        Add-Content $report "<td><b>$ID</b></td>"   
        Add-Content $report "<td>$AccountName</td>"  
        Add-Content $report "<td>$LastChgd</td>"  
        add-Content $report "<td>$UserDesc</td>" 
        Add-Content $report "</tr>"}
	Add-content $report  "</table>"
}
##This section closes the report formatting##
Add-Content $report "</body>"  
Add-Content $report "</html>" 
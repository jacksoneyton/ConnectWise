##This script will check the $email mailbox to make sure there are no emails older than 10 min.
## If there are messages more than 10 min old it will restart the connectwise email connector
## Requires Exchange Web Services Managed API 1.2

$email = "support@arrc.com"

# Credentials
$username = 'User'
$password ='Password'
$domain = 'Domain'

# load the assembly
if ($(Test-Path "C:\Program Files\Microsoft\Exchange\Web Services\1.2\Microsoft.Exchange.WebServices.dll") -eq $False){
 Write-Host "Requires Exchange Web Services Managed API 1.2 be installed on computer running script."
 EXIT 1
}
[void] [Reflection.Assembly]::LoadFile("C:\Program Files\Microsoft\Exchange\Web Services\1.2\Microsoft.Exchange.WebServices.dll")

$s = New-Object Microsoft.Exchange.WebServices.Data.ExchangeService
$s.Credentials = New-Object Net.NetworkCredential($username, $password, $domain)
# discover the url from your email address
$s.AutodiscoverUrl($email)

# get a handle to the inbox
$inbox = [Microsoft.Exchange.WebServices.Data.Folder]::Bind($s,[Microsoft.Exchange.WebServices.Data.WellKnownFolderName]::Inbox)

#create a property set (to let us access the body & other details not available from the FindItems call)
$psPropertySet = new-object Microsoft.Exchange.WebServices.Data.PropertySet([Microsoft.Exchange.WebServices.Data.BasePropertySet]::FirstClassProperties)
$psPropertySet.RequestedBodyType = [Microsoft.Exchange.WebServices.Data.BodyType]::Text;

$items = $inbox.FindItems(100)
if ($inbox.TotalCount -ne "0") {

 foreach ($item in $items.Items) {
 #load the property set
 $item.load($psPropertySet)
 
 if ($item.DateTimeCreated -lt (Get-Date).AddMinutes(-10)) {
 Write-Host "Messages older than 10 min. Restarting EmailRobot Service"
 $service = Get-Service -Name 'EmailRobot'
 $service.Stop()
 $service.WaitForStatus('Stopped','00:00:10')
 if ($service.Status -ne 'Stopped') {Get-Process -Name 'emailrobot' | Stop-Process -Force}
 Start-Service "EmailRobot"
 Write-Host "Services restarted."
 EXIT
 }
 Else {Write-Host "Email less than 10min old. $($item.DateTimeCreated)"}
 }
}
Else {Write-Host "There are no messages in the mailbox"}
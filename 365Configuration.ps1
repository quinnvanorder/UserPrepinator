#======================================================================================================
# Written By Quinn Van Order, 2018
# Office 365 Configuration Script
# This script will loop until the user in question has synced into the cloud, assigns licencing, loops until mailbox is provisioned, and then assigns any needed post provisioing settings. 
#======================================================================================================

#VARIABLE INPUT FROM FILE
#======================================================================================================
#Note: For the sake of simplicity, all portions use the same code. This results in some variables being created that are not used. 
$file = [IO.File]::ReadAllText("C:\Temp\vars.txt")
foreach ($Data in $file)
  {
  $Data = $Data -split ' +(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)' -replace '"', ""
  }
$FName = $Data[0]
$LName = $Data[1]
$Domain = $Data[2]
$Street = $Data[3] 
$City = $Data[4] 
$State = $Data[5] 
$Zip = $Data[6] 
$Country = $Data[7] 
$Phone = $Data[8] 
$Title = $Data[9] 
$Department = $Data[10] 
$Company = $Data[11] 
$Manager = $Data[12] 
$DUser = $Data[13] 
$UPath = $Data[14] 
$UPass = $Data[15] 
$O365UN = $Data[16] 
$O365PW = $Data[17] 
$DLicence = $Data[18] 
$DC = $Data[19] 
$DirSync = $Data[20] 
$PrepServ = $Data[21]
#======================================================================================================

#LOCAL VARIABLES
#======================================================================================================
$Password = ConvertTo-SecureString $O365PW -AsPlainText -Force
$LiveCred = New-Object System.Management.Automation.PSCredential $O365UN, $Password
$UName = $FName + "." + $LName
$EMail = $UName + "@" + $Domain
$TZone = "Pacific Standard Time"
#======================================================================================================

function DirSyncWatch
{
$SyncCheck = $Null
do {
       $SyncCheck = Get-MsolUser -UserPrincipalName $EMail -erroraction silentlycontinue
       #DIAGNOSTIC CODE
       Add-Content -Path "C:\Temp\DirSyncWatch.txt" -Value "Waiting" -Force
       Sleep 15
   }
While ($SyncCheck -eq $Null)
}

function O365Config
{
#Set Country
Set-MsolUser –UserPrincipalName $EMail –UsageLocation $Country
#Assign Licence 
Set-MsolUserLicense –UserPrincipalName $EMail –AddLicenses $DLicence
#Wait for mailbox to be provisioned
$checkifmailboxexists = $Null
do {
       $checkifmailboxexists = get-mailbox $EMail -erroraction silentlycontinue
       Add-Content -Path "C:\Temp\BoxProvisioning.txt" -Value "Waiting" -Force
       Sleep 15
}
While ($checkifmailboxexists -eq $Null)
#Set Time Zone
set-MailboxRegionalConfiguration -identity $EMail -TimeZone $TZone
#Its possible the timezone is not being set properly, need to assess further, but not exactly my highest priority at this juncture
#May have to also set cal timezone seperately, unsure at this juncture
}

#DIAL IN
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell/ -Credential $LiveCred -Authentication Basic -AllowRedirection
Import-Module (Import-PSSession $Session -AllowClobber -Warningaction SilentlyContinue) -Global -WarningAction SilentlyContinue 2>&1 | Out-Null
Connect-MsolService -Credential $LiveCred | Out-Null

#FUNCTION CALLS
DirSyncWatch
O365Config

#DIAGNOSTIC CODE
Add-Content -Path "C:\Temp\Complete.txt" -Value "Complete" -Force
Remove-PSSession $Session


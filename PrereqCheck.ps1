#======================================================================================================
# Written By Quinn Van Order, 2018
# ERROR HANDLING SCRIPT
# This script checks several critical components, all of which would break the next step if wrong. Logs results to txt file,  will be assessed by Kaseya before it executes the next phase. 
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
$UName = $FName + "." + $LName
$EMail = $UName + "@" + $Domain
$Password = ConvertTo-SecureString $O365PW -AsPlainText -Force
$LiveCred = New-Object System.Management.Automation.PSCredential $O365UN, $Password
#======================================================================================================

#FUNCTIONS
#======================================================================================================
function TestO365Creds
{
try {$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell/ -Credential $LiveCred -Authentication Basic -AllowRedirection -EA Stop
Add-Content -Path "C:\Temp\Errors.txt" -Value "O365 Password Is Correct = TRUE" -Force
Remove-PSSession $Session}
catch {Add-Content -Path "C:\Temp\Errors.txt" -Value "O365 Password Is Correct = FALSE" -Force; exit}
}

function CheckForFreeLicense
{
$LTotal = (Get-MsolAccountSku | where {$_.AccountSkuId -eq $DLicence}).ActiveUnits #run Get-MsolAccountSku to see list and exact names of target license.
$LUsed = (Get-MsolAccountSku | where {$_.AccountSkuId -eq $DLicence}).ConsumedUnits
if ($LTotal -gt $LUsed) {Add-Content -Path "C:\Temp\Errors.txt" -Value "Target License Is Free = TRUE" -Force} else {Add-Content -Path "C:\Temp\Errors.txt" -Value "Target License Is Free = FALSE" -Force}
}

function CheckIfManagerExists
{
$ManagerPresence =  Get-Recipient $Manager -ErrorAction SilentlyContinue
If($ManagerPresence -eq $null) {Add-Content -Path "C:\Temp\Errors.txt" -Value "Target Manager Exists = FALSE" -Force} Else {Add-Content -Path "C:\Temp\Errors.txt" -Value "Target Manager Exists = TRUE" -Force}
}

function CheckIfEmailConflicts
{
$TargetEmailFree =  Get-Recipient $Email -ErrorAction SilentlyContinue
If($TargetEmailFree -eq $null) {Add-Content -Path "C:\Temp\Errors.txt" -Value "Target Email Is Free = TRUE" -Force} Else {Add-Content -Path "C:\Temp\Errors.txt" -Value "Target Email Is Free = FALSE" -Force}
}
#======================================================================================================

#FUNCTION CALLS
TestO365Creds
write-host "Creds Check Complete"

#DIAL IN 
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell/ -Credential $LiveCred -Authentication Basic -AllowRedirection
Import-Module (Import-PSSession $Session -AllowClobber -Warningaction SilentlyContinue) -Global -WarningAction SilentlyContinue 2>&1 | Out-Null
Connect-MsolService -Credential $LiveCred | Out-Null

#FUNCTION CALLS
CheckForFreeLicense
write-host "Licence Check Complete"
CheckIfManagerExists
write-host "Manager Check Complete"
CheckIfEmailConflicts
write-host "Conflict Check Complete"
#DISCONNECT
Remove-PSSession $Session
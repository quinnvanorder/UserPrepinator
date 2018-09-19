#======================================================================================================
# Written By Quinn Van Order, 2018
# ERROR HANDLING SCRIPT
# This script checks several critical components, all of which would break the next step if wrong. Logs results to txt file,  will be assessed by Kaseya before it executes the next phase. 
#======================================================================================================


#STATUS: For now, I am considering this check script done, in that it does what I currently need it to do. I suspect the PDC check may not be needed, will revisit. 

#VARIABLE INPUT
param([string]$Username,[string]$PW,[string]$LicenceType,[string]$ManagerEmail,[string]$TargetEmail)

$Password = ConvertTo-SecureString $PW -AsPlainText -Force
$LiveCred = New-Object System.Management.Automation.PSCredential $Username, $Password

#FUNCTION JUNCTION WHATS YOUR FUNCTION
function CheckPDC #Verifies if script is running on the Primary Domain Controller, realistically what actually matters is the ability to run import-module activedirectory, so long term this function may not be used
{
$CompConfig = Get-WmiObject Win32_ComputerSystem
foreach ($ObjItem in $CompConfig) {$Role = $ObjItem.DomainRole}
#There are 6 possible roles, we want 5 for Primary DC, the other values are 0: 'Standalone Workstation', 1: 'Member Workstation', 2: 'Standalone Server', 3: 'Member Server', 4: 'Backup Domain Controller", 5: 'Primary Domain Controller"
if ($Role -eq "5"){Set-Content -Path ".\Errors.txt" -Value "Is Primary DC = TRUE" -Force}
Else { Set-Content -Path ".\Errors.txt" -Value "Is Primary DC = FALSE" -Force }
}

function TestO365Creds #Verifies provided password will authenticate into O365
{
try {$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell/ -Credential $LiveCred -Authentication Basic -AllowRedirection -EA Stop
Add-Content -Path ".\Errors.txt" -Value "O365 Password Is Correct = TRUE" -Force
Remove-PSSession $Session}
catch {Add-Content -Path ".\Errors.txt" -Value "O365 Password Is Correct = FALSE" -Force; exit}
}

function CheckForFreeLicense
{
$LTotal = (Get-MsolAccountSku | where {$_.AccountSkuId -eq $LicenceType}).ActiveUnits #run Get-MsolAccountSku to see list and exact names of target license. For now, assumption is E3, will be hardcoded variable on VSA site. 
$LUsed = (Get-MsolAccountSku | where {$_.AccountSkuId -eq $LicenceType}).ConsumedUnits
if ($LTotal -gt $LUsed) {Add-Content -Path ".\Errors.txt" -Value "Target License Is Free = TRUE" -Force} else {Add-Content -Path ".\Errors.txt" -Value "Target License Is Free = FALSE" -Force}
}

function CheckIfManagerExists
{
$ManagerPresence =  Get-Recipient $ManagerEmail -ErrorAction SilentlyContinue
If($ManagerPresence -eq $null) {Add-Content -Path ".\Errors.txt" -Value "Target Manager Exists = FALSE" -Force} Else {Add-Content -Path ".\Errors.txt" -Value "Target Manager Exists = TRUE" -Force}
}

function CheckIfEmailConflicts
{
$TargetEmailFree =  Get-Recipient $TargetEmail -ErrorAction SilentlyContinue
If($TargetEmailFree -eq $null) {Add-Content -Path ".\Errors.txt" -Value "Target Email Is Free = TRUE" -Force} Else {Add-Content -Path ".\Errors.txt" -Value "Target Email Is Free = FALSE" -Force}
}


#FUNCTION CALLS
CheckPDC
TestO365Creds


#DIAL IN 
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell/ -Credential $LiveCred -Authentication Basic -AllowRedirection
Import-Module (Import-PSSession $Session -AllowClobber -Warningaction SilentlyContinue) -Global -WarningAction SilentlyContinue 2>&1 | Out-Null
Connect-MsolService -Credential $LiveCred | Out-Null


#FUNCTION CALLS
CheckForFreeLicense
CheckIfManagerExists
CheckIfEmailConflicts

#DISCONNECT
Remove-PSSession $Session
write-host "SUCCESS"



#NOTES
<#
Server Reqs:
Requires Latest WMF
Requires .net 3.5
Requires latest Nuget, will be prompted with other install module commands, but realistically that should be its own command
Install-Module -Name AzureRM -allowclobber (not 100% that I need this, will circle back)
Install-Module -Name AzureAD -allowclobber
Install-Module -Name MSOnline
#>
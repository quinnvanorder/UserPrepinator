#======================================================================================================
# Written By Quinn Van Order, 2018
# ERROR HANDLING SCRIPT
# This script checks several critical components, all of which would break the next step if wrong. Logs results to txt file,  will be assessed by Kaseya before it executes the next phase. 
#======================================================================================================

##NOTE: A lot of the functions here have duplicitive login code. This is a testing remnant, wont be final product


function CheckPDC #Verifies if script is running on the Primary Domain Controller
{
$CompConfig = Get-WmiObject Win32_ComputerSystem
foreach ($ObjItem in $CompConfig) {$Role = $ObjItem.DomainRole}
#There are 6 possible roles, we want 5 for Primary DC, the other values are 0: 'Standalone Workstation', 1: 'Member Workstation', 2: 'Standalone Server', 3: 'Member Server', 4: 'Backup Domain Controller", 5: 'Primary Domain Controller"
if ($Role -eq "5"){Set-Content -Path ".\Errors.txt" -Value "Is Primary DC = TRUE" -Force}
Else {
Set-Content -Path ".\Errors.txt" -Value "Is Primary DC = FALSE" -Force
#No point in continuing, requires PDC
exit
}
}

function TestO365Creds #Verifies provided password will authenticate into O365
{
$Username = "username" #For now, passwords are hardcoded for easy testing. Long term plan is to pass into script as variable. Looking into secure way to do this
$Password = ConvertTo-SecureString "password" -AsPlainText -Force
$LiveCred = New-Object System.Management.Automation.PSCredential $Username, $Password
try 
{$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell/ -Credential $LiveCred -Authentication Basic -AllowRedirection -EA Stop
Add-Content -Path ".\Errors.txt" -Value "O365 Password Is Correct = TRUE" -Force
Remove-PSSession $Session}
catch {Add-Content -Path ".\Errors.txt" -Value "O365 Password Is Correct = FALSE" -Force}
}

function CheckForFreeLicense
{
$Username = "username" #For now, passwords are hardcoded for easy testing. Long term plan is to pass into script as variable. Looking into secure way to do this
$Password = ConvertTo-SecureString "password" -AsPlainText -Force
$LiveCred = New-Object System.Management.Automation.PSCredential $Username, $Password
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell/ -Credential $LiveCred -Authentication Basic -AllowRedirection
Import-Module (Import-PSSession $Session -AllowClobber -Warningaction SilentlyContinue) -Global -WarningAction SilentlyContinue 2>&1 | Out-Null
Connect-MsolService -Credential $LiveCred | Out-Null #enables msol connector features
$LTotal = (Get-MsolAccountSku | where {$_.AccountSkuId -eq "COMPANYNAME:ENTERPRISEPACK"}).ActiveUnits #run Get-MsolAccountSku to see list and exact names of target license. For now, assumption is E3, will be hardcoded variable on VSA site. 
$LUsed = (Get-MsolAccountSku | where {$_.AccountSkuId -eq "COMPANYNAME:ENTERPRISEPACK"}).ConsumedUnits
if ($LTotal -gt $LUsed) {Add-Content -Path ".\Errors.txt" -Value "Target License Is Free = TRUE" -Force} else {Add-Content -Path ".\Errors.txt" -Value "Target License Is Free = FALSE" -Force}
Remove-PSSession $Session
}

function CheckMSOLComponents
{
#Skipping for now. With the initial proof of concept, I will just configure the server as needed, I will circle back once this is prooved out to add a function to configure the server as needed. 
#Requires MSOnline Sign in Assistant
#Requires Azure AD Module, this can be imported instead of installed if we need a super light footprint, but odds are I will want the target servers to have these persistantly. 
#Will also need to add an update handler to this function. At the end of the day, this may spiral into a whole seperate "server prepinator" script to put all the pieces in place
#Requires .net 3.5
#Requires WMF5.1
#Requires latest Nuget (Install-Module -Name AzureRM will trigger it if out of date, but probably want to do seperately)
#Install-Module -Name AzureRM (not 100% that I need this, will circle back)
#Install-Module -Name AzureAD
#Install-Module -Name MSOnline
#Rough check logic: Is WMF installed? If no, do that!, then set execution to bypass, update nuget, install azurerm, azuread, and msonline. The MSOnline installer appeared to do jack squat, need to test if thats a "need it installed and then use cli install" or if this is a "yeah that msi is outdated, dont do that." Tests for the future!
}

function CheckIfManagerExists
{

}

function CheckIfEmailConflicts #cant use an email that is already present!
{ #looks like I can simply run Get-Recipient user@domain.com in a basic if... if present, will display. 
}

function CheckDirSyncPresence
#{Also skipping for now, as this will probably be its own whole adventure. In short, I want to use the dirsync client to force a sync, but frankly with the massive variety in configurations, it may be easier to just check for sync every few minutes until the user object passes, code for that already built in old master, will port across. If that does not cut it by itself, will revisit this function
}

function Attach365 #Currently not referenced. This code will install the az module if missing, and finish the dial in started with the code in the previous function. Reworked to use the new AzureADPreview module. Eventually will have to rename once they finalize and kill off the old MSOL, but by using the new commands, this 'future proofs' this script for hopefully a few years
{
Import-PSSession $Session -AllowClobber
#Check for missing module, if missing will install
if (Get-Module -ListAvailable -Name AzureADPreview) 
{Connect-AzureAD -Credential $LiveCred}
else 
{Install-Module AzureADPreview -force
Connect-AzureAD -Credential $LiveCred}
}


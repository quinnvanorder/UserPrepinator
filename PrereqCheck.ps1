#======================================================================================================
# Written By Quinn Van Order, 2018
# ERROR HANDLING SCRIPT
# This script checks several critical components, all of which would break the next step if wrong. Logs results to txt file,  will be assessed by Kaseya before it executes the next phase. 
#======================================================================================================

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
catch {Add-Content -Path ".\Errors.txt" -Value "O365 Password Is Correct = FALSE" -Force
exit}
}

function CheckForFreeLicense
{
}

function CheckMSOLComponents
{
}

function CheckIfManagerExists
{
}

function CheckDirSyncPresence
{
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

CheckPDC 
TestO365Creds 

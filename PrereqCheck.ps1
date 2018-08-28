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
$Username = "Username"
$Password = ConvertTo-SecureString "Password" -AsPlainText -Force
$LiveCred = New-Object System.Management.Automation.PSCredential $Username, $Password
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell/ -Credential $LiveCred -Authentication Basic -AllowRedirection
Import-PSSession $Session -AllowClobber
Connect-MsolService –Credential $LiveCred
If ($?)
{Add-Content -Path ".\Errors.txt" -Value "O365 Password Is Correct = TRUE" -Force}
Else
{Add-Content -Path ".\Errors.txt" -Value "O365 Password Is Correct = FALSE" -Force}
Remove-PSSession $Session
}

CheckPDC 
TestO365Creds 
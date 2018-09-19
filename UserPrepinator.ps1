#======================================================================================================
# Written By Quinn Van Order, 2018
# USER CREATION SCRIPT
# This script assumes all checks have passed, and creates the user with provided input
#======================================================================================================

#Import AD Module
Import-Module activedirectory

#TESTING VARIABLES
#################################################################################################################################################################
#Note, all testing variables are omitted, as they would expose sensitive info. Final version will take all variables as arguments to pass into this script. 
#################################################################################################################################################################

#WORKING VARIABLES
$Cal = $EMail + ":\calendar"  #Will be used later to assign cal perms

#FUNCTIONS
function CreateUser
{
new-aduser -userPrincipalName $EMail -SamAccountName $UName -name $DName -givenname $FName -surname $LName -emailaddress $EMail -DisplayName $DName -Title $Title -AccountPassword $Password -Company $Company -OfficePhone $Phone -StreetAddress $Street -City $City -State $State -Country $Country -Department $Department -PostalCode $Zip  -Enabled $true -Path $UPath -HomePage $WebPage -Manager $ManagerSAM.SamAccountName
}

function CopyADGroups
{
Get-ADUser -Identity $DefaultUser -Properties memberof | Select-Object -ExpandProperty memberof | Add-ADGroupMember -Members $UName
}

function DirSyncWatch #One alternate that would still use this code would be to have it stop here and pass back to Kasyea. Then we can have per client super basic procedures that know which command to fire against which server. Then, we can have this looping code pick up in the second half of this before setting up the 365 side. That way, the script is insulated against the failure of the dirsync script, but if it works this will complete faster. Best of both worlds!
{
$SyncCheck = $Null
do {
       $SyncCheck = Get-MsolUser -UserPrincipalName $EMail -erroraction silentlycontinue
       Sleep 15
   }
While ($SyncCheck -eq $Null)
}


#FUNCTION CALLS
CreateUser
CopyADGroups

#DIAL IN
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell/ -Credential $LiveCred -Authentication Basic -AllowRedirection
Import-Module (Import-PSSession $Session -AllowClobber -Warningaction SilentlyContinue) -Global -WarningAction SilentlyContinue 2>&1 | Out-Null
Connect-MsolService -Credential $LiveCred | Out-Null

#FUNCTION CALLS
DirSyncWatch


#DISCONNECT
Remove-PSSession $Session
write-host "Complete"
#======================================================================================================
# Written By Quinn Van Order, 2018
# USER CREATION SCRIPT
# This script assumes all checks have passed, and creates the user with provided input
#======================================================================================================

#Import AD Module
Import-Module activedirectory

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
$DName = $FName + " " + $LName #Display Name
$EMail = $UName + "@" + $Domain
$Password = ConvertTo-SecureString $UPass -AsPlainText -Force
$ManagerSAM = get-aduser -filter {mail -eq $Manager}
#======================================================================================================

#FUNCTIONS
function CreateUser
{
new-aduser -userPrincipalName $EMail -SamAccountName $UName -name $DName -givenname $FName -surname $LName -emailaddress $EMail -DisplayName $DName -Title $Title -AccountPassword $Password -Company $Company -OfficePhone $Phone -StreetAddress $Street -City $City -State $State -Country $Country -Department $Department -PostalCode $Zip  -Enabled $true -Path $UPath -HomePage $Domain -Manager $ManagerSAM.SamAccountName
}

function CopyADGroups
{
Get-ADUser -Identity $DUser -Properties memberof | Select-Object -ExpandProperty memberof | Add-ADGroupMember -Members $UName
}

#FUNCTION CALLS
CreateUser
CopyADGroups

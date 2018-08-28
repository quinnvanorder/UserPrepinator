# UserPrepinator
This is my first project, and is meant to be both a learning experience, and eventually a tool to create new users for clients of a MSP. Very green at the moment, so the initial commits will be the standard "hello world" fare. This description will be updated when this becomes more of a viable tool instead of the training ground / sandbox it will be initially. 

The primary component to create users for a MSP, the idea being to use a tool such as kaseya to deploy the script and pass variables as needed to build users for clients without interaction



################################## SCRATCH SPACE, MAPPING OUT PLAN#############################
Have Kaseya pass down the PS1(s?) to target DC
Execute PS1(s?) while passing variables needed for user setup, log results to txt file
Have Kaseya pull contents of Txt file and email to engineer assigned to create user
Delete all component files in working directory (by redeploying PS1 each time, it ensures that the latest version is deployed. Not sure if this is the way to go at scale, will revisit.)


##########VARIABLES
Engineer Email = Prompted for by kaseya, not an input to pass to script. Kaseya will email logs to said engineer to review
First Name
Last Name
Middle name / initial = not sure if needed
Override Email Address / email format = To have this script work for any client, it needs to be able to handle various schemas, such as "first letter of first name, and whole last name" and so on. The idea is to have that be a hardcoded variable within the kaseya procedure per client. Need to have an option to override the format, however for standardization, would love to force clients to pick and stick with one schema. 
Address info = Various fields, all hardcoded in Kaseya procedure. The idea being to populate AD object with relevant info of the site they work at. To handle multiple sites, clone Kaseya front end script, and alter these variables. 
Start Date
Assigned Computer (may be needed to rename computer)
Office Phone Number = Hardcoded
Personal Phone number (could be DID or cell)
Job title
Supervisor
OU = hardcoded into kaseya procedure, should have a good 'general users bucket'
Timezone = probably should be hardcoded
Target Clone User = hardcoded. Need to create a 'default user' per client to copy from when making AD object. Said user will have all the most basic permissions and group assignments need to function in company
Profile creation? Can code, but thinking approaching this from the AD perspective may be better... more research needed
Dirsync Client Location = Used to force sync to 365
o365 Admin Username
o365 Admin Password
Licence = hardcoded within kaseya, specific o365 licence to assign
Litigation hold timeframe = hardcoded in kaseya, used to specify duration
Default Cal permissions level to assign
Manager Cal permissions



############################### INITIAL ERROR HANDLING
at first run of script, several critical components need to be checked before beginning to avoid a "half setup" user. 

Things that must be present / correct
Admin U/P for 365, sign in and confirm access
Licences, ensure there is a free one to assign before beginning. 
Supervisor, ensure able to resolve if provided
Server status: Need to make sure that the procedure is executed against a DC
DerpSync presence, need to ensure that the dirsync client is on the target server to force replication if this is a client with dirsynced o365


############################# ROUGH MAPPING

Procedure will deploy a "prereq check" script which will check all items listed in error handling. It will write status to a txt file and terminate. Kaseya will check, and if failed will report back, otherwise will move to next step
Procedure will deploy a "user creation" script, which will create the user from a target default user, populate informational fields
Procedure will deploy a "cloud setup" script, which will force dirsync, assign licences, verify mailbox creation, assign timezone, set various holds and cal / mailbox perms as needed. 

Finally, all logs will be scraped by Kaseya, sent back to the engineer in question, and all ps1's and other components will be wiped. 
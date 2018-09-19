# UserPrepinator
<br>This is my first project, and is meant to be both a learning experience, and eventually a tool to create new users for clients of a MSP. Very green at the moment, so the initial commits will be the standard "hello world" fare. This description will be updated when this becomes more of a viable tool instead of the training ground / sandbox it will be initially.<br/>
<br>The primary component to create users for a MSP, the idea being to use a tool such as kaseya to deploy the script and pass variables as needed to build users for clients without interaction<br/>



################################## SCRATCH SPACE, MAPPING OUT PLAN#############################
<br>Have Kaseya pass down the PS1(s?) to target DC<br/>
<br>Execute PS1(s?) while passing variables needed for user setup, log results to txt file<br/>
<br>Have Kaseya pull contents of Txt file and email to engineer assigned to create user<br/>
<br>Delete all component files in working directory (by redeploying PS1 each time, it ensures that the latest version is deployed. Not sure if this is the way to go at scale, will revisit.)<br/>


##########VARIABLES (hardcoding to be done in container variables, not procedure variables)
<br>Engineer Email = Prompted for by kaseya, not an input to pass to script. Kaseya will email logs to said engineer to review<br/>
<br>First Name<br/>
<br>Last Name<br/>
<br>Middle name / initial = not sure if needed<br/>
<br>Address info = Various fields, all hardcoded in Kaseya procedure. The idea being to populate AD object with relevant info of the site they work at. To handle multiple sites, clone Kaseya front end script, and alter these variables. <br/>
<br>Start Date<br/>
<br>Assigned Computer (may be needed to rename computer)<br/>
<br>Office Phone Number = Hardcoded<br/>
<br>Personal Phone number (could be DID or cell)<br/>
<br>Job title<br/>
<br>Supervisor<br/>
<br>OU = hardcoded, should have a good 'general users bucket'<br/>
<br>Timezone = probably should be hardcoded<br/>
<br>Target Clone User = hardcoded. Need to create a 'default user' per client to copy from when making AD object. Said user will have all the most basic permissions and group assignments need to function in company<br/>
<br>o365 Admin Username<br/>
<br>o365 Admin Password<br/>
<br>Licence = hardcoded, currently also hardcoded in the ps1, will alter that to pull from passed variable down the road, specific o365 licence to assign<br/>
<br>Litigation hold timeframe = hardcoded, used to specify duration<br/>
<br>Default Cal permissions level to assign<br/>
<br>Manager Cal permissions<br/>


<br>Things that will be added later, but wont be built in v1 <br/>
<br><br/>
<br>Override Email Address / email format = To have this script work for any client, it needs to be able to handle various schemas, such as "first letter of first name, and whole last name" and so on. The idea is to have that be a hardcoded variable within the kaseya procedure per client. Need to have an option to override the format, however for standardization, would love to force clients to pick and stick with one schema. <br/>
<br>Profile creation? Can code, but thinking approaching this from the AD perspective may be better... more research needed<br/>
<br>Dirsync Client Location = Used to force sync to 365<br/>

############################### INITIAL ERROR HANDLING
<br>at first run of script, several critical components need to be checked before beginning to avoid a "half setup" user. <br/>

<br>Server status: Need to make sure that the procedure is executed against a DC - COMPLETED<br/>
<br>Admin U/P for 365, sign in and confirm access - COMPLETED<br/>
<br>Licences, ensure there is a free one to assign before beginning. - COMPLETED <br/>
<br>Does provided manager exist?<br/>
<br>Does user email to be generated conflict with an existing address? <br/>

<br>Things that will be added later, but wont be built in v1 <br/>
<br><br/>
<br>All software needed for this script to function is currently assumed to be present for v1. Once I have a working proof of concept, I will circle back and build a script to setup the server as needed for this to work<br/>
<br>DerpSync presence, need to ensure that the dirsync client is on the target server to force replication if this is a client with dirsynced o365. Suspect I will end up having a master script for dirsynced AD, and one for on prem.<br/>
############################# ROUGH MAPPING

<br>Procedure will deploy a "prereq check" script which will check all items listed in error handling. It will write status to a txt file and terminate. Kaseya will check, and if failed will report back, otherwise will move to next step<br/>
<br>Procedure will deploy a "user creation" script, which will create the user from a target default user, populate informational fields<br/>
<br>Procedure will deploy a "cloud setup" script, which will force dirsync, assign licences, verify mailbox creation, assign timezone, set various holds and cal / mailbox perms as needed. One alternate to this layout would be to not force dirsync, and spin in a loop waiting for user to show up before continuing. With the complexity and variability of dirsync, this may be the best option. Plus the 'delay' incurred by waiting patiently is hidden when the procedure is doing all the work<br/>

<br>Finally, all logs will be scraped by Kaseya, sent back to the engineer in question, and all ps1's and other components will be wiped. <br/>


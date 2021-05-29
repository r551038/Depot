Program will add and remove users from the local administrators group
Files
AdminControl.vbs is the core of the PAM solution. Please that it's a fully functional solution, however as it stands its lacking automation
in regards to tasks and importing datasources, this are currently flat files that require manual creation as noted.

AccessAuditv3.bat generates an exception report for accounts that were added but were not issued  remove request.

In current development state AdminControl.vbs requires to be manually run from the command prompt with an account that has the required privilages for both account additions and removals.

As a POC data sources are flat files that must populated
domainname-NoZoneServers.lst [contains servers that due to regulations that should be access by a subset of staff)
Authuser.lst [contains the system administrators that can be added or removed, SA not on the list can not be added)
ticketnumber-server.lst [contains a server list associated with said ticket]

With further development both Authuser.lst and ticketnumber-server.lst data could be extracted
from the the ticketing system and instead of manually entering the accounts to be added the would then be extracted from the ticketing system based on who accepted the task and removal would be based on when the open ticket ends.


 


run from command prompt
as AdminControl.vbs add or remove  domain ticket number
example to add to the nam domain with itcket number 12345678
cscript  AdminControl.vbs add nam 12345678

prereq:
files
ticketnumber-server.lst: will contains server to which account will add/removed from local admin group
domain-NoZoneServers.lst can be blank otherwise contains servers that should not have accounts added or removed
Authuser.lst: contains a list of authorized users that can be add or removed.
users that are not on this list can not be added or removed. security measure

additional notes
users to be added or removed are entered during runtime
administrator name and domain are taken from environment only the password must be supplied during runtime
this is to prevent unanthorized account modifications incase pc was left unattended
This portion should be modified to extract the account and password from a vault.
account additions and removals are also noted in the event logs of the host action was performed on

output
tickectnumber-action-domain-user.lst: contains users
AdminAdd-del.log: contains actions by whom, type and errors
example of AdminAdd-del.log
Actioned by:ntgroup:RFC or VT# for action:12345678:12345678
Actioned by:ntgroup:Failure Server:oneserver:is in No fly zone:nam-NoZoneServers.lst
Actioned by:ntgroup:Issue connecting to server:twoserver:-Can't connect to Server
Actioned by:ntgroup:work-pc:add User:testuser1:Error :-User doesn't exist on domain
Actioned by:ntgroup:work-pc:add User:testuser2:Error :-User doesn't exist on domain
Actioned by:ntgroup:RFC or VT# for action:12345678:12345678
Actioned by:ntgroup:Failure Server:oneserver:is in No fly zone:nam-NoZoneServers.lst
Actioned by:ntgroup:Issue connecting to server:twoserver:-Can't connect to Server
Actioned by:ntgroup:work-pc:add User:testuser1:Error :-User doesn't exist on domain
Actioned by:ntgroup:RFC or VT# for action:12345678:12345678
Actioned by:ntgroup:Issue connecting to server:oneserver:-Can't connect to Server
Actioned by:ntgroup:Failure Server:twoserver:is in No fly zone:work-pc-NoZoneServers.lst
Actioned by:ntgroup:work-pc:add User:testuser1:Error :-SA doesn't have suffient rights to perform action
Actioned by:ntgroup:work-pc:add User:testuser2:Error :-SA doesn't have suffient rights to perform action
Actioned by:ntgroup:work-pc:add User:testuser3:failed; user is not authorized list



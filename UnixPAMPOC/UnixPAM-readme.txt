This is a proof of concept that demonstrates the ability
of a team to control the various services of a distributed
application, without the need for elevated privileges.

No actual commands will executed till cdmd3.sh is modified.
Instead commands that would be issued are stored under file log/commanddebug3.log.
This allows you to verify that the command desired is running against
appropiate host prior to going live!
Audit log log/cdmenulog.log will contains user who issued request, action performed,component target and environment.
  
 

There are two main components the user interface and the demon service.

The front end provides three functions.
One is submitting the request for processing on behalf of the user.
The second, if user is authorized it creates an xterm ssh session with host that is specified or
user can select to connect to an entire subset of servers for a particular component.
Third is editing of server service type grouping by environment and server type.

The Demon services will process the front-end requests that were submitted.
Message consists of an action, environment and entire subset of type server/s.

Front end files
cdmain.sh: launches menu for front end.
servacc.sh: used to access server/s, help menu, view status of last query and control of services.
manyserv.sh: used to open xterm to all servers of a type for and environment.
multicon.sh: called on by manyserv.sh
actcdmd3.sh: menu for services control selection, creation of audit trail and of placing messages. 
editcd.sh (this is used to edit the files)

Back-end files
The service demon consists of cdinterface.sh and cdmd3.sh
cdinterface.sh is a utility used to manage the service. It will avoid
additional copies of the service from starting.
Options are start, stop, query log. status of service is stored under file cdmd3status.log

Front end process will place requests to /cdque/testmsg.q (NFS share secured with proper permissions)
message consists of Action (stop, start query) server type(app, web , db) and environment.

Backend Process
Demon(cdmd3.sh) checks for messages under cdque/testmsg.q
reads message (action, server type and environment) 
Then it will map actual service command required for that server type
example
webapp server type will map to "/export/opt/YourApplication/scripts/websphere/"$action"_WebService.ksh"
while balmq server type will map to "/export/opt/YourApplication/scripts/websphere/"$action"_BalanceMqService.ksh"


required files 
demon requires directory /cdque where testmsg.q will reside
For each menu under accdmd3.sh there should be a files created with the name consisting environment name combined with the server type under the extension.cdl.
This allows flexibility of using the same program to control different environments without alteration.
you may have a production environment across various regions or (not advisable) a uat and prod environment you wish to control from the a central location). You could also create combinations of environment type and region.
Say you have a 3-tiered application consisting of a front-end of 2 servers(web), application(myapp)  3 servers and a database(dB) tier of 4 servers. Application Prod site is North America and COB is APAC.
This configuration would require 6 files as noted below
files
naprodweb.cdl (all web tier servers in NA site)
apaccobweb.cdl (all web tier servers in APACT site)
naprodmyapp.cdl( all application tier  servers in NA)
apacprodmyapp.cdl (etc,etc,etc)
naproddb.cdl (etc,etc)
apacproddb.cdl(etc)

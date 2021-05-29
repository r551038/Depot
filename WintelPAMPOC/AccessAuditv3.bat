@echo off
if exist Admindel.log del Admindel.log /q
if exist Adminadd.log del Adminadd.log /q
if exist AccessValidate.log del AccessValidate.log /q
if exist Accessaudit.log del Accessaudit.log /q
if exist AccessConsolidation.log del AccessConsolidation.log /q
if exist AccessAuditChk.log del AccessAuditChk.log
for /F %%t in (Authuser.lst) do type AdminAdd-del.log |find /i "%%t"  | find /v /i  "Error" | find /v /i "failed" |  find /c /i "add User" | tr -d [\\n] >> Adminadd.log && echo  %%t #added   >> Adminadd.log
for /F %%t in (Authuser.lst) do type AdminAdd-del.log | find /i "%%t" |  find /v /i "Error" | find /v /i "failed" | find /c /i "remove User" | tr -d [\\n] >> Admindel.log && echo  %%t #removed >> Admindel.log
for /F %%t in (Authuser.lst) do type Adminadd.log | grep -i "%%t"  | tr -d [\\n] >> AccessValidate.log  && type Admindel.log | find /i "%%t"   >> AccessValidate.log 
echo users with mismatch of adds and removes # indicates times added verses times removed >> AccessConsolidation.log
awk "{print $2,$1 - $4}" AccessValidate.log >> AccessConsolidation.log
type AccessConsolidation.log | awk " $2 != 0 {print $0}" >> AccessAuditChk.log
echo Number of attempts to access No Fly Zone Servers: | tr -d [\\n] >> AccessAuditChk.log
type AdminAdd-del.log | find /c /i "No fly zone" >> AccessAuditChk.log
echo Number of attempts to add/remove unathorized users: | tr -d [\\n] >> AccessAuditChk.log
type AdminAdd-del.log | find /c /i "user is not authorized" >> AccessAuditChk.log
echo Number of errors connecting to servers: | tr -d [\\n] >> AccessAuditChk.log
type AdminAdd-del.log | find /c /i "Issue" >> AccessAuditChk.log
echo Number of errors adding-removing Administrators: | tr -d [\\n] >> AccessAuditChk.log
type AdminAdd-del.log | find /i "Error" | find /i /c "User:"    >> AccessAuditChk.log
if exist Admindel.log del Admindel.log /q
if exist Adminadd.log del Adminadd.log /q
if exist AccessValidate.log del AccessValidate.log /q
if exist Accessaudit.log del Accessaudit.log /q
if exist AccessConsolidation.log del AccessConsolidation.log
notepad AccessAuditChk.log
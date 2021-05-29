' script name: CompdiagPerfdiag.vbs
' created: Jan 3 2011
' author: Ismael Rivera
' version 1.00
' ****************************************************************
' purpose:
' provides the following info on server
' returns data on processes that are consuming over 5%, including handles,vmemory,io bytes,etc and
' any services associated with these pids
' returns free memory,
' check network status for errors
' disk status for disks under 10%free and or long disk queues
' devices with issues'
' uptime of server in days and hours
'*****************************************************************
'Input:
' from command line servers are separated by spaces
' from file
' from within progam execution if no input at command or serverlist file is found
'*****************************************************************
'Known Issues:
'doesn't work on win2k or on servers that don't run unsigned scripts
'requires cscript as the default engine or run as cscript SrvQDiag.vbs
'*****************************************************************
Set args = Wscript.Arguments
On Error Resume Next
dim Servername,fpath,strLine,CmdlnI,stcomp
dim GServer
dim Updays
dim Uphrs
dim Udhrs
Const ForWriting = 2
Set WshShl = WScript.CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")
strPath = WshShl.CurrentDirectory 
fpath=strPath & "\" & "server.lst"
dim Frepo
Const ForReading = 1
Const StrScptnam = "CompPerfdiag.vbs"

Const wbemFlagReturnImmediately = &h10
Const wbemFlagForwardOnly = &h20

StrIfilemsg = ("Script running in batchmode using Server.lst as source" & vbcrlf & "Will Autostart in 15 seconds Otherwise press Cancel"  & vbcrlf & "and delete Server.lst before running again")

If objFSO.FileExists(fPath) Then
    Frepo = WshShl.Popup (StrIfilemsg,15,StrScptnam,1)
    if Frepo = 2 then
    Wscript.Quit
    end if
    Set objFile = objFSO.OpenTextFile(fpath, ForReading)
       Do Until objFile.AtEndOfStream
        strLine = objFile.ReadLine
        Progmain (strLine)
       Loop
    objFile.Close
    Wscript.Quit
 Else
  if args.count > 0 then
    for CmdlnI = 0 to args.count
     ProgMain (args.Item(CmdlnI))
    next 
   Else
      WshShl.Popup "Script can be run in Noninteractive as CompPerfdiag.vbs server-name or" & vbcrlf & "create file server.lst with the names of the servers",10,StrScptnam,0
      Gserver = (InputBox (" One or Mulitple Servers can be added here. " & vbCrLf & _
                 "Separate servers by comma ,","Manual Server List Input Box","Add servers here"))
      Sarray = Split(Gserver,",")
       for CmdlnI = LBound(Sarray) to UBound(Sarray)
        ProgMain (Sarray(CmdlnI))
       next 
   End if
End if

Wscript.Quit()
function Progmain(Servername)
strComputer = Servername
WScript.Echo "Running DIAG on " & Servername
 lpath=strPath & "\" & strComputer & "-Diag.log"
Set objLogFile = objFSO.OpenTextFile(lpath, ForWriting,"true")   
Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\CIMV2")

Set colItemsLgdisk = objWMIService.ExecQuery("SELECT * FROM Win32_PerfFormattedData_PerfDisk_LogicalDisk", "WQL",wbemFlagReturnImmediately + wbemFlagForwardOnly)
' Set colItemsCPU = objWMIService.ExecQuery("SELECT * FROM Win32_PerfFormattedData_PerfProc_Process Where Name <> 'wmiprvse' ", "WQL",wbemFlagReturnImmediately + wbemFlagForwardOnly)
Set colItemsCPU = objWMIService.ExecQuery("SELECT * FROM Win32_PerfFormattedData_PerfProc_Process", "WQL",wbemFlagReturnImmediately + wbemFlagForwardOnly)
Set colItemsMEM = objWMIService.ExecQuery("SELECT * FROM Win32_PerfFormattedData_PerfOS_Memory", "WQL",wbemFlagReturnImmediately + wbemFlagForwardOnly)
Set colItemsNet = objWMIService.ExecQuery("SELECT * FROM Win32_PerfFormattedData_PerfNet_Redirector", "WQL",wbemFlagReturnImmediately + wbemFlagForwardOnly)
Set ColTime = objWMIService.ExecQuery("SELECT SystemUpTime  FROM Win32_PerfFormattedData_PerfOS_System", "WQL", wbemFlagReturnImmediately + wbemFlagForwardOnly)
Set colSrvs = objWMIService.ExecQuery("SELECT * FROM Win32_Service where StartMode = 'Auto' and State <> 'Running'", "WQL",wbemFlagReturnImmediately + wbemFlagForwardOnly)
Set colItemsPro = objWMIService.ExecQuery("SELECT * FROM Win32_Process")
Set ColSrvsrvc =  objWMIService.ExecQuery("SELECT * FROM Win32_Service")
Set colItemsDev = objWMIService.ExecQuery( "SELECT * FROM Win32_PnPEntity where Status <> 'OK' and Status <> '' and status <> 'Degraded'  ",,48)
if Err.Number = 0 then
dim SVCPID()
cpuloop = 0
 objLogFile.writeline( "==========================================")
objLogFile.writeline( "Computer: " & strComputer)                  
For Each objItem In colItemsCPU
    SrvRam = int ((objItem.VirtualBytes/1024)/1024)
       if objItem.PercentProcessorTime > 5 and objItem.IDProcess <> 0 and objItem.Name <> "wmiprvse" and objItem.IDProcess <> 4 then 
          objLogFile.writeline( "*Processes using more then 5% PID Name: " & objItem.Name & ",PID#: " & objItem.IDProcess & ",CPU%: " & objItem.PercentProcessorTime & ",MBytes: " & SrvRam)
          objLogFile.writeline("------------------------------------------")
          objLogFile.writeline( "#Detailed Info for PID:" & objItem.IDProcess )
         ReDim Preserve SVCPID(cpuloop) 
         SVCPID(cpuloop) = objItem.IDProcess
          cpuloop = cpuloop + 1
          tosubro = objItem.IDProcess
          for each objItemp in colItemsPro
              if objItemp.ProcessId = tosubro then
              objLogFile.writeline( vbTAB & "#CreationDate: " & WMIDateStringToDate(objItemp.CreationDate))
              objLogFile.writeline( vbTAB & "#Caption: " & objItemp.Caption)
              objLogFile.writeline( vbTAB & "#CommandLine: " & objItemp.CommandLine)
              objLogFile.writeline( vbTAB & "#VirtualSize:" & int(objItemp.VirtualSize/1024/1024) & " MBytes")
              objLogFile.writeline( vbTAB & "#ThreadCount: " & objItemp.ThreadCount )
              objLogFile.writeline( vbTAB & "#Handle count: " & objItemp.HandleCount)
              objLogFile.writeline( vbTAB & "#ReadTransferCount: " & objItemp.ReadTransferCount)
              objLogFile.writeline( vbTAB & "#WriteTransferCount: " & objItemp.WriteTransferCount )
              objLogFile.writeline( vbTAB & "#ExecutionState: " & objItemp.ExecutionState)
              objLogFile.writeline("------------------------------------------"    )
             end if
           next             
              
           end if
Next
          if cpuloop > 0 then    
             objLogFile.writeline("------------------------------------------" )
            objLogFile.writeline( "PIDS consuming more then 5% CPU that are Services")
            for svcloop = LBound(SVCPID) to UBound(SVCPID)
                              svctest = int (SVCPID (Svcloop) )
                              for Each ObjItemcs in ColSrvsrvc
                                    if ObjItemcs.ProcessId = SVCPID (Svcloop) then
                                        objLogFile.writeline( vbTAB & "# PID:" & SVCPID (Svcloop) & " Associated with  Service:" & ObjItemcs.Name & " Start Mode set to: " & ObjItemcs.StartMode)
                                   end if
                               next
             next
          end if 
objLogFile.writeline("------------------------------------------"  )
if cpuloop = 0 then
   objLogFile.writeline( "CPU is AOK No process are consuming above 5% CPU" )
end if   


For Each objItem In colItemsMEM
    if objItem.AvailableMBytes < 64 then
       objLogFile.writeline( "*Memory below 64Mbytes Free: " & objItem.AvailableMBytes)
    else
       objLogFile.writeline( "Memory is AOK more then 65MB free: Current Free RAM " & objItem.AvailableMBytes & " MBytes")
    end if
next

For Each objItem In colSrvs
      
      objLogFile.writeline( "*Auto Services down:" & "Name: " & objItem.Name & ",DisplayName: " & objItem.DisplayName & ",State: " & objItem.State & ",Status: " & objItem.Status)
next



For Each objItem In colItemsNet
    if objItem.NetworkErrorsPersec > 0 then
        objLogFile.writeline( "*detailed network info")
       objLogFile.writeline( vbTAB & "#Network Errors > 0 per second")
       objLogFile.writeline( vbTAB & "#BytesTotalPersec: " & objItem.BytesTotalPersec)
       objLogFile.writeline( vbTAB & "#NetworkErrorsPersec: " & objItem.NetworkErrorsPersec)
       objLogFile.writeline( vbTAB & "#ReadsDeniedPersec: " & objItem.ReadsDeniedPersec)
       objLogFile.writeline( vbTAB & "#ReadsLargePersec: " & objItem.ReadsLargePersec)
       objLogFile.writeline( vbTAB & "#ServerDisconnects: " & objItem.ServerDisconnects)
       objLogFile.writeline( vbTAB & "#ServerReconnects: " & objItem.ServerReconnects)
       objLogFile.writeline( vbTAB & "#ServerSessions: " & objItem.ServerSessions)
       objLogFile.writeline( vbTAB & "#ServerSessionsHung: " & objItem.ServerSessionsHung)
       objLogFile.writeline( vbTAB & "#WritesDeniedPersec: " & objItem.WritesDeniedPersec)
       objLogFile.writeline( vbTAB & "#WritesLargePersec: " & objItem.WritesLargePersec)
     else
       objLogFile.writeline( "Network performance is AOK no errors above 1 per sec" )
     end if
Next

For Each objItem In colItemsLgdisk
    if objItem.PercentFreeSpace < 10 or objItem.CurrentDiskQueueLength > 1 then
       objLogFile.writeline( "*DISK Detailed has < 10% Free or queue length > 1" )
       objLogFile.writeline(  vbTAB & "#Drive " & objItem.Name)
       objLogFile.writeline( vbTAB & "#AvgDiskQueueLength: " & objItem.AvgDiskQueueLength)
       objLogFile.writeline( vbTAB & "#CurrentDiskQueueLength: " & objItem.CurrentDiskQueueLength)
       objLogFile.writeline( vbTAB & "#DiskTransfersPersec: " & objItem.DiskTransfersPersec)
       objLogFile.writeline( vbTAB & "#FreeMegabytes: " & objItem.FreeMegabytes)
       objLogFile.writeline( vbTAB & "#PercentDiskTime: " & objItem.PercentDiskTime)
       objLogFile.writeline( vbTAB & "#PercentFreeSpace: " & objItem.PercentFreeSpace)
     else
           objLogFile.writeline( "Disk " & objItem.Name  & "is AOK. Free Storage is above 10% and queue is <0")
     end if
   Next
 For Each objItem in colItemsDev
    objLogFile.writeline( "-----------------------------------")
    objLogFile.writeline( "Devices with issues")
    objLogFile.writeline( "-----------------------------------")
    objLogFile.writeline( "Description: " & objItem.Description)
    objLogFile.writeline( "ErrorDescription: " & objItem.ErrorDescription)
    objLogFile.writeline( "LastErrorCode: " & objItem.LastErrorCode)
    objLogFile.writeline( "Manufacturer: " & objItem.Manufacturer)
    objLogFile.writeline( "Name: " & objItem.Name)
    objLogFile.writeline( "Status: " & objItem.Status)
    objLogFile.writeline("SystemName: " & objItem.SystemName)
Next

For Each objItem In ColTime
Uphrs = int (objItem.SystemUpTime/3600)
Updays = int (Uphrs/24)
Udhrs =  Uphrs mod  24  

objLogFile.writeline( "Up Time for Server " & Servername & " Days:" & Updays & " Hrs:" & Udhrs )
Next
objLogFile.writeline( "==========================================")
WScript.Echo
else 
 lpath=strPath & "\" & strComputer & "-Diag-err.log"
Set objLogFile = objFSO.OpenTextFile(lpath, ForWriting,"true")   
objLogFile.writeline( "==========================================")
objLogFile.writeline (strComputer & ":Error:" & Err.Description)
objLogFile.writeline( "==========================================")
WScript.Echo strComputer & ":Error:" & Err.Description
WScript.Echo
ERR.Clear
objLogFile.Close()
'objFile.Close

'objFile.Close
objLogFile.Close()
ERR.Clear
end if
End Function


Function WMIDateStringToDate(dtmDate)
WScript.Echo dtm: 
	WMIDateStringToDate = CDate(Mid(dtmDate, 5, 2) & "/" & _
	Mid(dtmDate, 7, 2) & "/" & Left(dtmDate, 4) _
	& " " & Mid (dtmDate, 9, 2) & ":" & Mid(dtmDate, 11, 2) & ":" & Mid(dtmDate,13, 2))
End Function

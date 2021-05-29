' script name: Hardwarediag.vbs
' created: Jan 26 2011
' author: Ismael Rivera 
' version 1.00
' ****************************************************************
' purpose:
' provides the hardware info on server
' uptime of server in days and hours
'*****************************************************************
'Input:
' from command line servers are separated by spaces
' from file
' from within progam execution if no input at command or serverlist file is found
'*****************************************************************
'Known Issues:
'doesn't work on servers that don't run unsigned scripts
'requires cscript as the default engine or run as cscript HWRpt.vbs
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
Const StrScptnam = "Hardwarediag.vbs"

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
      WshShl.Popup "Script can be run in Noninteractive as Hardwarediag.vbs server-name or" & vbcrlf & "create file server.lst with the names of the servers",10,StrScptnam,0
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
WScript.Echo "Retriving hardware info for " & Servername
 lpath=strPath & "\" & strComputer & "-HWRpt.log"
Set objLogFile = objFSO.OpenTextFile(lpath, ForWriting,"true")   
Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\CIMV2")
Nodev= "(Standard system devices)"
NoUsb="(Standard USB Host Controller)"
NoMicro = "Microsoft"
Const adVarChar = 200
Const Maxcharacters = 255
Set DataList = CreateObject ("ADOR.Recordset")
DataList.Fields.Append "DName", adVarchar, MaxCharacters
DataList.Fields.Append "DMfg", adVarchar, MaxCharacters
DataList.Fields.Append "DStat", adVarchar, MaxCharacters
DataList.Open

Set colItemsbas = objWMIService.ExecQuery("SELECT * FROM Win32_ComputerSystem",,48)
Set colItemsMem = objWMIService.ExecQuery(  "SELECT * FROM Win32_PhysicalMemory",,48) 
Set colItemsDSK = objWMIService.ExecQuery( "SELECT * FROM Win32_LogicalDisk where DriveType <> 5 ",,48) 
Set colItemsNb = objWMIService.ExecQuery( "SELECT * FROM Win32_NetworkAdapter where Manufacturer <> 'Microsoft'",,48) 
Set colItemsBio = objWMIService.ExecQuery("SELECT * FROM Win32_BIOS",,48) 
Set colItemsHDev = objWMIService.ExecQuery( "SELECT * FROM Win32_PnPEntity where Manufacturer <>  '" &  Nodev & "' and Manufacturer <>  '" &  NoUsb & "'  and Manufacturer <>  '"&  NoMicro & "'",,48)
Set ColTime = objWMIService.ExecQuery("SELECT SystemUpTime  FROM Win32_PerfFormattedData_PerfOS_System", "WQL", wbemFlagReturnImmediately + wbemFlagForwardOnly)
dim SVCPID()
cpuloop = 0


For Each objItem in colItemsbas
     objLogFile.writeline( "Computer: " & strComputer & " Model: " & objItem.Model  & " Manufacturer: " & objItem.Manufacturer & " PartOfDomain: " & objItem.PartOfDomain &  " Domain: " & objItem.Domain & " DomainRole: " & objItem.DomainRole )
    objLogFile.writeline( "Hardwareinfo " & " NumberOfProcessors: " & objItem.NumberOfProcessors & " TotalPhysicalMemory: " & (objItem.TotalPhysicalMemory/1048576) & "MB")
    'objLogFile.writeline( "SystemStartupOptions: " & Join(objItem.SystemStartupOptions, ",") )
    'objLogFile.writeline( "SystemStartupSetting: " & objItem.SystemStartupSetting)
    objLogFile.writeline( "SystemType: " & objItem.SystemType)
   Next

For Each objItem in colItemsBio 
   objLogFile.writeline( "Bios info" & " Manufacturer: " & objItem.Manufacturer & " Name: " & objItem.Name & " SerialNumber: " & objItem.SerialNumber & " SMBIOSPresent: " & objItem.SMBIOSPresent & " SMBIOSBIOSVersion: " & objItem.SMBIOSBIOSVersion)
Next
objLogFile.writeline( "Physical Memory**")
For Each objItem in colItemsMem 
    objLogFile.writeline( "Location: " & objItem.DeviceLocator & " Capacity: " & (objItem.Capacity/1048576) &  "MB" & " Speed: " & objItem.Speed)
Next
objLogFile.writeline( "Logical Disks**")

For Each objItem in colItemsDSK
       objLogFile.writeline( "Drive Letter " & objItem.Name  & " Size: " & (objItem.Size/1073741824) & "GB" &" FreeSpace: " & (objItem.FreeSpace/1073741824) & "GB" )
Next
objLogFile.writeline( "NetworkAdapters**")
For Each objItem in colItemsNb 
    objLogFile.writeline( objItem.Name & " Manufacturer: " & objItem.Manufacturer &  " AutoSense: " & objItem.AutoSense &  " MACAddress: " & objItem.MACAddress &   " Speed: " & objItem.Speed)
      
Next
objLogFile.writeline( "Hardware Devices**")
 For Each objItem in colItemsHDev
       Mfgchk = Len(objItem.Manufacturer)
       if Mfgchk > 0   and  objItem.Name <> "EMC SYMMETRIX SCSI Disk Device" and objItem.Name <> "PowerDevice by PowerPath" then 
       DataList.AddNew
        DataList ("DName") = objItem.Name 
        DataList ("DMfg") = objItem.Manufacturer
        DataList ("DStat")= objItem.Status
      DataList.Update
      end if 
Next
ByGone="firstone"
DataList.Sort  =  "DName"
DataList.MoveFirst
Do Until DataList.EOF
if DataList.Fields.Item ("DName") <>   ByGone or DataList.Fields.Item("DStat") <> "OK"  and  DataList.Fields.Item("DStat") <> "" then
   objLogFile.writeline( DataList.Fields.Item ("DName") & " Manufacturer: " & DataList.Fields.Item("DMfg") & " Status: " & DataList.Fields.Item("DStat") )
end if
ByGone = DataList.Fields.Item ("DName")
DataList.MoveNext
loop

For Each objItem In ColTime
Uphrs = int (objItem.SystemUpTime/3600)
Updays = int (Uphrs/24)
Udhrs =  Uphrs mod  24
objLogFile.writeline( "==========================================")  
objLogFile.writeline( "Up Time for Server " & Servername & " Days:" & Updays & " Hrs:" & Udhrs )
Next

objLogFile.writeline( "==========================================")
objLogFile.Close()
End Function

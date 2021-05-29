' script name: AdminControl.vbs
' created: May 20 2012
' author: Ismael Rivera 
' version 1.b
' ****************************************************************
' purpose:
' add or delete users from/to local administator group
'  users inputed during runtime separated by commas
'*****************************************************************
'Input:
' for servers from file Authserver.lst 
'  users inputed during runtime separated by commas
'*****************************************************************
'Known Issues:
'Must be ru from windows (2008,XP,Vista)
' Bug for nonexistent user may appear as already present or not present
' in AdminAdd-del.log, no action however is performed for that account
'*****************************************************************
Set args = Wscript.Arguments
On Error Resume Next

' non runtime Variables and constants definitions
dim Servername,fpath,strLine,CmdlnI,stcomp
dim Gusers
dim Updays
dim Uphrs
dim Udhrs
uplim = 0
noflyind = 0
dim refnum,refDesc
Dim Ucheck
Dim ArrScheck()
dim Frepo
Dim bPasswordBoxWait
Dim evtuser
Dim EvtComputer
Dim EvtMsg
StrAudmsg = " "
Const ForWriting = 2
Const ForAppend = 8
Const ForReading = 1
Const StrScpt = "AdminControl"
Const wbemFlagReturnImmediately = &h10
Const wbemFlagForwardOnly = &h20
const toadd = "add"
const todel = "remove"
Const ADS_SECURE_AUTHENTICATION = &H1
Const ADS_USE_ENCRYPTION = &H2


' non runtime objects initialization
Set WshShl = WScript.CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")
Set objNet = CreateObject("WScript.Network" )
CurrentSA = objNet.UserName
StrPamhelp = "add or remove must be specified at commandline" & vbCrLf & "Domain of accounts and RFC/VT#"

' verification of arguments
if  args.count < 3 then
        Nopara = WshShl.Popup (StrPamhelp,15,StrScptnam,1)
           Wscript.Quit
end If

' Parameter dependent variables initation
tocomp = lcase(args.Item(0))
strNetBIOSDomain = args.Item(1)
strPath = WshShl.CurrentDirectory
fpath=strPath & "\" & args.Item(2) & "-server.lst"
UseStr = strPath & "\" & args.Item(2) & "-" & tocomp & "-" & strNetBIOSDomain & "-user.lst"
Noflpath = strPath & "\" & strNetBIOSDomain & "-NoZoneServers.lst"
NoflpathMsg = strNetBIOSDomain & "-NoZoneServers.lst"
' Strings definitions
StrScptnam = "CitiGroup CTS " & StrScpt & " " & tocomp
Uspath=strPath & "\" & "Authuser.lst"
lpath=strPath & "\" & "AdminAdd-del.log"
Srvfilemsg = args.Item(2) & "-server.lst"
StrIfilemsg = (Srvfilemsg & " is source for Servers" & vbcrlf & "Will Autostart in 15 seconds Otherwise press Cancel"  & vbcrlf & "and update Authserver.lst before running again")
NoSrvlstmsg = (Srvfilemsg & " Server list file not presesnt" & vbcrlf & "Please create " & fpath & "and populate with Server names")
Ufilemsg = ("Authuser.lst is source for Authorized Admins" & vbcrlf & "Will Autostart in 5 seconds Otherwise press Cancel"  & vbcrlf & "and update Authuser.lst before running again")
NoUstmsg = ("Authorized user list file not presesnt" & vbcrlf & "Please create Authuser.lst and populate with authorized Adminstrators")
Noflmsg =  (NoflpathMsg & " file not presesnt" & vbcrlf & "Please create  " & NoflpathMsg & " and populate with prohibted servers")
flmsg = (NoflpathMsg &  " is source for prohibted servers"& vbcrlf & "Will Autostart in 5 seconds Otherwise press Cancel")

' Standard error messages string definitions
StrErCnsrv= "Can't connect to Server"
StrErDNsrv = "Server is on a diffent domain"
StrErNosrv = "Server Not Detected"
StrErSaRts = "SA doesn't have suffient rights to perform action"
StrErNoUsr = "User doesn't exist on domain"
StrErAAusr = "User can't be added.Already in local Admin group"
StrErARusr = "User can't be removed.Was not present in local Admin group"

WScript.Echo 
' start of program
' verifiaction of actio  argument
If (tocomp <> toadd) then
        if (tocomp <> todel) then
        Nopara = WshShl.Popup ("add or remove must be specified at commandline" & vbCrLf & "along with full domain",15,StrScptnam,1)
        Wscript.Quit
        end if
end if

'test for required files, info on files and warnings
' test for file of server list is present
If objFSO.FileExists(fPath) Then
    Frepo = WshShl.Popup (StrIfilemsg,15,StrScptnam,1)
    if Frepo = 2 then
    Wscript.Quit
    end if
 Else
noSRvlst = WshShl.Popup (NoSrvlstmsg,15,StrScptnam,1) 
Wscript.Quit
End if

' test for file of authorized users list is present
If objFSO.FileExists(Uspath) Then
    Frepo2 = WshShl.Popup (Ufilemsg,3,StrScptnam,1)
    if Frepo2 = 2 then
    Wscript.Quit
    end if
 Else
noUslst = WshShl.Popup (NoUstmsg,15,StrScptnam,1) 
Wscript.Quit
End if

' test for file of prohibited serverslist is present
If objFSO.FileExists(Noflpath) Then
    Frepo2 = WshShl.Popup (flmsg,3,StrScptnam,1)
    if Frepo2 = 2 then
    Wscript.Quit
    end if
 Else
noUslst = WshShl.Popup (Noflmsg,15,StrScptnam,1) 
Wscript.Quit
End if



' input of VT or RFC short description
do while len(refnum)  < 10  
  refDesc = (InputBox ("Please enter RFC/VT#" & args.Item(2)& " Short Description" & vbCrLf & "or Exit"))
  if Ucase(refDesc) = "EXIT" then
     Wscript.Quit
     end if
  refnum = args.Item(2) & ":" & refDesc
loop 

' input of users 
WshShl.Popup "Users are to be"  & " " & tocomp & "ed" & "  local Administrators group" & vbcrlf ,10,StrScptnam,0
Gusers = (InputBox ("Please enter one or mulitple Users to be " & " " & tocomp & "ed" & " here. " & vbCrLf & _
                 "Separate users by comma ,if more than one"))

' save users to be add to rfc/vt userfile
Set objUserRFCFile = objFSO.OpenTextFile(UseStr, ForWriting,"true")
objUserRFCFile.WriteLine(Gusers)
' initialize run time array of users
Sarray = Split(Gusers,",")

' testing exit if no users are supplied
if (UBound(Sarray) < 0) then
   Nousers = WshShl.Popup ("No Users entered; script will exit",15,StrScptnam,1)
   Wscript.Quit
end if

' initialize run time array of for authorized users test
uplim1 = UBound(Sarray)
reDim Ucheck(uplim1)

' set flag for authourized users
for UCmdlnI = LBound(Ucheck) to UBound(Ucheck)
    set objufile = objFSO.OpenTextFile(Uspath, ForReading)
    Do Until objufile.AtEndOfStream 
             strLine = objufile.ReadLine
             if Ucase(Sarray(UCmdlnI)) = Ucase(strLine) then
                Ucheck(UCmdlnI) = 1
             end if 
    Loop       
next
' set flag for no fly zone servers
Set objFile = objFSO.OpenTextFile(fpath, ForReading)
noflyind = 0
   Do Until objFile.AtEndOfStream
       ReDim Preserve ArrScheck(noflyind)
       strLine = Ucase(objFile.ReadLine)
       set ObjfileNfly = objFSO.OpenTextFile(Noflpath, ForReading)         
           Do Until ObjfileNfly.AtEndOfStream  
              Noflyline = Ucase(ObjfileNfly.ReadLine)
              if Ucase(Noflyline) = Ucase(strLine) then
                 ArrScheck(noflyind) = "1"
              end if
           loop
       noflyind = noflyind +1
   Loop

' opening of log file for appending and write to log file of VT/RFC for action 
Set objLogFile = objFSO.OpenTextFile(lpath, ForAppend,"true") 
objLogFile.writeline ("Actioned by:" & CurrentSA & ":RFC or VT# for action:" & refnum)


'admin performing work 
MstrUser = CurrentSA

' get admin password must be at least 7 chars log
do while len(MstrPassword)  < 6
MstrPassword = PasswordBox("Enter your password")
loop

' main execution of program against server list
objFile.Close
Set objFile = objFSO.OpenTextFile(fpath, ForReading)
noflyind = 0
    Do Until objFile.AtEndOfStream
          strLine = objFile.ReadLine
'         Verify Server is not in the no fly zone prior to attempting to add/remove
          if ArrScheck(noflyind) = 0 then
             Progmain (strLine)
          else
             WScript.Echo "Actioned by:" & CurrentSA & ":Failure Server:" & strLine & ":is in No fly zone:" & NoflpathMsg  
             objLogFile.writeline("Actioned by:" & CurrentSA & ":Failure Server:" & strLine & ":is in No fly zone:" & NoflpathMsg)
          end if
    noflyind = noflyind +1          
    Loop

' closing of files and exit        
objFile.Close
objLogFile.Close()
objufile.Close()
objUserRFCFile.Close()
Wscript.Quit()



'function section
function Progmain(Servername)
On Error Resume Next
strComputer = Servername




WScript.Sleep 10
Set objNS = GetObject("WinNT:")
' checking connectivity prior to adding if conx failes return to main and get next server
 
Set objGroup = objNS.OpenDSObject("WinNT://" & strComputer & "/Administrators,group",MstrUser, MstrPassword,ADS_SECURE_AUTHENTICATION Or ADS_USE_ENCRYPTION )

' error checking, handling and transaltion for connectivity 
   if Err.Number <> 0 then
       Select Case  Err.Number
                 Case -2147024843 StrAudmsg = StrErCnsrv
                 Case 70         StrAudmsg = StrErDNsrv
                 Case Else
                      StrAudmsg = Err.Number
               End Select
       objLogFile.writeline ("Actioned by:" & CurrentSA & ":Issue connecting to server:" & strComputer & ":-" & StrAudmsg)
       WScript.Echo "Error encountered while connecting to:" & strComputer
       ERR.Clear
       return 1

    Else
     
        WScript.Sleep 5
        for CmdlnI = LBound(Sarray) to UBound(Sarray)
        strUser =  Sarray(CmdlnI)
        
' verify that user is on authorized list, if not skip add-remove and log unathorized attempt.
        if Ucheck(CmdlnI) = 1 then
            ERR.Clear()
            Set objUser = objNS.OpenDSObject("WinNT://" & strNetBIOSDomain & "/" & strUser & ",user",MstrUser, MstrPassword,ADS_SECURE_AUTHENTICATION Or ADS_USE_ENCRYPTION  )      
            if tocomp = "add" then 
               objGroup.add(objUser.ADsPath)
               else
                   objGroup.remove(objUser.ADsPath)
            end if    
            if Err.Number = 0 then
               evtuser = evtuser & vbcrlf & strUser
               WScript.Echo "Actioned by:" & CurrentSA & ":" & strComputer & ":" & tocomp & " " & "User:" & strUser
               objLogFile.writeline ("Actioned by:" & CurrentSA & ":" & strComputer & ":" & tocomp & " " & "User:" & strUser )
               else 
               Select Case  Err.Number
                 Case  424        StrAudmsg = StrErNoUsr
                 Case -2147023518 StrAudmsg = StrErAAusr
                 Case -2147023519 StrAudmsg = StrErARusr
                 Case -2147024843 StrAudmsg = StrErNosrv
                 Case -2147024891 StrAudmsg = StrErSaRts
'                 Case -2147024843 StrAudmsg = StrErCnsrv
'                 Case 70         StrAudmsg = StrErDNsrv
                 Case Else
                      StrAudmsg = Err.Number
                 End Select
                WScript.Echo "Actioned by:" & CurrentSA & ":" & strComputer & ":" & tocomp & " " & "User:" & strUser & ":Error " & ":-" & StrAudmsg 
               objLogFile.writeline ("Actioned by:" & CurrentSA & ":" & strComputer & ":" & tocomp & " " & "User:" & strUser & ":Error " & ":-" & StrAudmsg )
            ERR.Clear
            StrAudmsg = " "    
            end if
        else
            objLogFile.writeline ("Actioned by:" & CurrentSA & ":" & strComputer & ":" & tocomp & " " & "User:" & strUser & ":" & "failed; user is not authorized list" )
        end if   
ERR.Clear
Next

EvtComputer= "\\" & strComputer
EvtMsg = tocomp & ":Sa-local Admin group:" & "by:" & CurrentSA &  vbcrlf & ":RFC/VT#:" & refnum & vbcrlf & evtuser
' write to event log as informational
WshShl.LogEvent 4,EvtMsg ,EvtComputer
evtuser = " "
    end if
end Function

Function PasswordBox(sTitle) 
  set oIE = CreateObject("InternetExplorer.Application") 
  With oIE 
    .FullScreen = False 
    .ToolBar   = False : .RegisterAsDropTarget = False 
    .StatusBar = False : .Navigate("about:blank") 
    While .Busy : WScript.Sleep 100 : Wend 
    With .document 
      With .ParentWindow 
        .resizeto 225,150
        .moveto .screen.width/2-200, .screen.height/2-50
      End With 
      .WriteLn("<html><body bgColor=Silver><center>") 
'      .WriteLn("[b]" & sTitle & "[b]")
 
      .WriteLn("Input Admin Password <input type=password id=pass>  " & _ 
               "<button id=but0>Submit</button>") 
      .WriteLn("</center></body></html>") 
      With .ParentWindow.document.body 
        .scroll="no" 
        .style.borderStyle = "outset" 
        .style.borderWidth = "3px" 
      End With 
      .all.but0.onclick = getref("PasswordBox_Submit") 
      .all.pass.focus 
      oIE.Visible = True 
      bPasswordBoxOkay = False : bPasswordBoxWait = True 
      On Error Resume Next 
      While bPasswordBoxWait 
        WScript.Sleep 100 
        if oIE.Visible Then bPasswordBoxWait = bPasswordBoxWait 
        if Err Then bPasswordBoxWait = False 
      Wend 
      PasswordBox = .all.pass.value 
    End With ' document 
    .Visible = False 
  End With   ' IE 
End Function 


Sub PasswordBox_Submit() 
  bPasswordBoxWait = False 
End Sub
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=epvp.ico
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_Res_Description=Elitepvpers Extern Shoutbox
#AutoIt3Wrapper_Res_Fileversion=1.0.3.0
#AutoIt3Wrapper_Res_LegalCopyright=by Der-Eddy
#AutoIt3Wrapper_Res_Language=1031
#AutoIt3Wrapper_Run_Obfuscator=y
#Obfuscator_Parameters=/striponlyincludes /om
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
;~ #Include <Array.au3>
#Include <Crypt.au3>
#Include <GuiButton.au3>
#Include <File.au3>
#include <GDIPlus.au3>
#include <IE.au3>
#include <GuiRichEdit.au3>
#include <String.au3>
#include "Include\GetHWID.au3" ; Danke an KillerDeluxe
#include "Include\_Ani.au3" ; Danke an Mass Spammer! von autoitscript.com - Bearbeitete Version
#Obfuscator_Off
#include "Include\WebTcp.au3" ; Danke an AMrK von autoitbot.de
#Obfuscator_On

Local $dll32 = DllOpen("user32.dll")
AdlibRegister("_hotkey", 250)

Global $image, $msg, $pic, $hImage, $hGraphic, $hBmp, $STM_SETIMAGE, $i, $ig, $old, $oldtext, $naughtymode, $traynotify, $highlightown, $indent, $error, $timeinput, $time, $statsDN, $statsN, $statsS, $Messages, $topchat, $Source_n, $Benutzer, $PWs
Global $Gui, $GUI1, $Form1, $Button1, $Labela, $Labeli, $input, $Input1, $Input2, $Checkbox1, $hwid, $t, $name, $group, $oHTTP, $pass, $password, $ani, $sb, $Edit, $ignorecheck, $secondnew, $thirdnew, $time, $timeinput, $bID, $bPW, $channel, $ch
Global $source, $page, $oWebTCP, $bLoggedIn, $securitytoken
Global $version = "1.0.3"
Global $MP = 0
Global $MPG = 0
Global $skip = False
Global $skipold = False
Global $naughty = False
Global $Traydo = False
Global $debug = False
Global Const $_hwid = _GetHWID()
Global Const $passwort = _StringReverse(_GetHWID())
Global Const $starke = "2"
Global Const $temp = @AppDataDir & "\UserCP\"
Global Const $smiliesdir = @AppDataDir & "\UserCP\Smilies\"
Global Const $file = @AppDataDir & "\UserCP\data.ini"
Global Const $prev = True
Global $smilies_count = 10
Global $smilies[11] = ["smile", "redface", "biggrin", "wink", "tongue", "cool", "rolleyes", "mad", "eek", "frown", "awesome"]
Global $first[15]
Global $second[23]
Global $third[15]
Global $ignore[50]
Global $version2[1]

If @Compiled And $CmdLine[0] > 0 Then
	If $CmdLine[1] = "Debug" Then $debug = True
EndIf
If NOT @Compiled Then $debug = True
If $debug = True Then
	FileDelete("first.html")
	FileDelete("second.html")
EndIf
If IniRead($file, "Shoutbox", "Naughty", "4") <> 4 Then $naughty = True

Opt("GUIOnEventMode", 1)
Opt("MustDeclareVars", 1)
;Opt("TrayMenuMode",3)
;Opt("TrayOnEventMode",1)
;Opt("TrayIconHide", 0)
Opt("GUICloseOnESC",1)
Opt("GUIEventOptions",1)

DirCreate($temp)
FileInstall(".\yuno.png", $temp & "yuno.png")
DirCreate($smiliesdir)
If NOT FileExists($temp & "progress.gif") Then InetGet("http://www.elitepvpers.com/forum/images/misc/progress.gif", $temp & "progress.gif")
For $i = 0 To $smilies_count
	If NOT FileExists($smiliesdir & $smilies[$i] & ".gif") Then InetGet("http://www.elitepvpers.com/forum/images/smilies/" & $smilies[$i] &  ".gif", $smiliesdir & $smilies[$i] &  ".gif")
Next

$Source_n = BinaryToString(InetRead("http://www.elitepvpers.com/forum/blogs/984054-der-eddy/10162-shoutbox-tool.html", 1))
If @error <> 0 Then
	MsgBox(48, "Error", "Es konnte keine Verbindung zu Elitepvpers aufgebaut werden!")
	Exit 1
EndIf
$version2 = StringRegExp($Source_n, "&lt;Version&gt;(.*?)&lt;/Version&gt;", 1)
If NOT @Compiled And $version2[0] <> $version And $prev Then $version &= " Preview"
If @Compiled And $version2[0] <> $version And NOT $debug Then _Update()
If $debug = True Then $version &= " Debug"

$Form1 = GUICreate("Elitepvpers Zugangsdaten", 246, 194, -1, -1, BitOR($WS_MINIMIZEBOX, $WS_SYSMENU))
GUISetOnEvent($GUI_EVENT_CLOSE, "_Exit")
GUICtrlCreateLabel("Benutzername:", 16, 16, 75, 17)
GUICtrlCreateLabel("Passwort:", 16, 41, 50, 17)
GUICtrlCreateLabel("Channel:", 16, 66, 50, 17)
GUICtrlSetCursor(-1, 4)
GUICtrlSetTip(-1, "Kann jederzeit geändert werden!")
$Input1 = GUICtrlCreateInput("", 96, 13, 137, 21)
$Input2 = GUICtrlCreateInput("", 96, 38, 137, 21, $ES_PASSWORD)
$channel = GUICtrlCreateCombo("Deutsch", 96, 63, 137, 21)
GUICtrlSetData(-1, "English")
$Labeli = GUICtrlCreateLabel("Deine HWID: (?)", 16, 89, 100, 17)
GUICtrlSetCursor(-1, 4)
GUICtrlSetTip(-1, "Solltest du Premium User oder Moderator sein ist es empfehlenswert die Hardware ID einzutragen" & @LF & 'Einfach auf "Profil bearbeiten" bzw. "Edit Your Details" und ganz nach unten scrollen und dort kannst du sie dann eintragen' & @LF & "Die HWID wird auch zum verschlüsseln deines Passwortes benutzt wenn du es speicherst", "HWID", 1, 1)
$Labela = GUICtrlCreateLabel("Profil bearbeiten", 138, 90, 100, 17)
GUICtrlSetTip(-1, "Ganz unten eintragen")
GUICtrlSetOnEvent(-1, "Profil")
GUICtrlSetFont(-1, 8, 800, 4)
GUICtrlSetColor(-1, 0x0000FF)
GUICtrlSetCursor(-1, 0)
GUICtrlCreateInput($_hwid, 16, 109, 215, 21, BitOR($ES_READONLY, $ES_CENTER))
$Checkbox1 = GUICtrlCreateCheckbox("Passwort speichern?", 16, 137, 129, 17)
GUICtrlSetState(-1, $GUI_CHECKED)
$Button1 = GUICtrlCreateButton("OK", 144, 134, 89, 25, $BS_DEFPUSHBUTTON)
GUICtrlSetOnEvent(-1, "Eintrag")
HotKeySet("{ENTER}", "Eintrag")
GUISetState(@SW_HIDE)

If NOT FileExists($file) Then
	$hwid = BinaryToString(InetRead("http://www.elitepvpers.de/api/hwid.php?hash=" & $_hwid, 1))
	$name = StringRegExp($hwid, '<username>(.*?)</username>', 1)
	$group = StringRegExp($hwid, '<usergroup>(.*?)</usergroup>', 1)
	If $name[0] = "" Then
		MsgBox(48, "Fehler", "HWID ist falsch oder nicht angegeben", 10)
	EndIf
	GUISetState(@SW_SHOW, $Form1)
	GUICtrlSetData($Input1, $name[0])
	Do
		Sleep (1)
	Until $GUI1 = 1
Else
	GUIDelete($Form1)
	$oHTTP = ObjCreate("winhttp.winhttprequest.5.1")
	$oHTTP.Open("GET","http://www.elitepvpers.de/api/hwid.php?hash=" & IniRead($file, "Benutzerdaten", "HWID", ""))
	$oHTTP.Send()
	$hwid = $oHTTP.Responsetext
	$group = _StringBetween($hwid, "<usergroup>", "</usergroup>")
	IniWrite($file, "Benutzerdaten", "Group", $group[0])
EndIf

If IniRead($file, "Benutzerdaten", "ID", "") = "" Then
	MsgBox(48, "Error", "Einstellungsdatei ist fehlerhaft!" & @CRLF & $file & " wird nun gelöscht und das Tool neugestartet")
	FileDelete($file)
	If @Compiled = 1 Then
		Run( FileGetShortName(@ScriptFullPath))
	Else
		Run( FileGetShortName(@AutoItExe) & " " & FileGetShortName(@ScriptFullPath))
	EndIf
	_Exit(1)
EndIf

If IniRead($file, "Benutzerdaten", "PW", "0") = 0 Then
	$password = InputBox("Password Abfrage", "Bitte geben sie Ihr Elitepvpers Passwort ein!", "", "*", Default, 130)
	If @error = 1 Then
		MsgBox(48, "Error", "Sie haben kein Passwort eingegeben!")
		Exit 2
	EndIf
Else
	$password = _StringEncrypt(0, IniRead($file, "Benutzerdaten", "PW", ""), $passwort, $starke)
EndIf

$Benutzer = IniRead($file, "Benutzerdaten", "ID", "default")

$pass = StringLower(StringTrimLeft(_Crypt_HashData($password, $CALG_MD5), 2))

_WebTcp_Startup()
_GDIPlus_StartUp()

If $naughty = False Then
	$MP = 190
	$MPG = 240
	$Gui = GUICreate("Elitepvpers Shoutbox Tool", 990 - $MP, 660)
Else
	$Gui = GUICreate("Elitepvpers Shoutbox Tool", 990 - $MP, 660)
	$hImage   = _GDIPlus_ImageLoadFromFile($temp & "yuno.png")
	$hGraphic = _GDIPlus_GraphicsCreateFromHWND($GUI)
	GUIRegisterMsg($WM_PAINT, "MY_WM_PAINT")
EndIf
For $i = 0 To $smilies_count
	GUICtrlCreatePic($smiliesdir & $smilies[$i] & ".gif", 200 - $MP + $i * 19, 40, 16, 16, $SS_NOTIFY)
	GUICtrlSetOnEvent(-1, "_" & $smilies[$i])
	GUICtrlSetCursor(-1, 0)
Next
GUISetOnEvent($GUI_EVENT_CLOSE, "_Exit")
GUISetOnEvent($GUI_EVENT_MINIMIZE, "_mimimize")
GUISetOnEvent($GUI_EVENT_RESTORE, "_restore")
$input = GUICtrlCreateInput("", 200 - $MP, 15, 620, 20)
GUICtrlCreateButton("Send", 830 - $MP, 13, 70, 22)
GUICtrlSetOnEvent(-1, "_Post")
GUICtrlCreateButton("Refresh", 910 - $MP, 13, 70, 22)
GUICtrlSetOnEvent(-1, "_Refresh")
GUICtrlCreateLabel("Channel:", 823 - $MP, 43)
$channel = GUICtrlCreateCombo("Deutsch", 870 - $MP, 40, 80, 21)
GUICtrlSetData(-1, "English", IniRead($file, "Shoutbox", "Channel", "Deutsch"))
GUICtrlSetOnEvent(-1, "Settings")

$Edit = _GUICtrlRichEdit_Create($Gui, "Shoutbox wird geladen ...", 200 - $MP, 65, 780, 390, BitOR($ES_MULTILINE, $WS_VSCROLL, $ES_AUTOVSCROLL, $ES_READONLY))
_GUICtrlRichEdit_AutoDetectURL($Edit, True)
;~ GUISetBkColor(0xE1E1E1, $Gui)
;~ _GUICtrlRichEdit_SetBkColor($Edit, 0xE3E3E3)
GUICtrlCreateGroup("Einstellungen", 200 - $MP, 460, 300, 170)
GUICtrlCreateLabel("In einem Intervall von", 260 - $MPG, 484)
$timeinput = GUICtrlCreateInput(IniRead($file, "Shoutbox", "Time", "20"), 367 - $MPG, 481, 42)
GUICtrlSetLimit(-1, 3)
GUICtrlCreateUpdown($timeinput)
GUICtrlSetLimit(-1, 999, 10)
$time = GUICtrlRead($timeinput) * 1000
GUICtrlCreateLabel(" sec. suchen", 412 - $MPG, 484)
$ignorecheck = GUICtrlCreateCheckbox("Ignorierte User ausblenden", 260 - $MPG, 510, -1, -1, $WS_DISABLED)
GUICtrlSetOnEvent(-1, "Settings")
Switch IniRead($file, "Benutzerdaten", "Group", "Level One")
Case "Banned Users"
	MsgBox(64, "Banned", "Du bist in Elitepvpers gebannt! Dieses Tool schließt sich automatisch")
	Exit 0
Case "Moderators", "Global Moderators", "Co-Administrators", "Administrators"
	GUICtrlSetState($ignorecheck, $GUI_ENABLE)
EndSwitch
$highlightown = GUICtrlCreateCheckbox("Eigene Shouts hervorheben", 260 - $MPG, 530)
GUICtrlSetOnEvent(-1, "Settings")
$traynotify = GUICtrlCreateCheckbox("Traybenachrichtigungen", 260 - $MPG, 550)
GUICtrlSetState(-1, $GUI_CHECKED)
GUICtrlSetOnEvent(-1, "Settings")
$indent = GUICtrlCreateCheckbox("Shouts einrücken", 260 - $MPG, 570, -1, -1, $WS_DISABLED)
GUICtrlSetState(-1, $GUI_CHECKED)
GUICtrlSetOnEvent(-1, "Settings")
$naughtymode = GUICtrlCreateCheckbox("Naughty Mode", 260 - $MPG, 590)
;~ GUICtrlSetState(-1, $GUI_CHECKED)
GUICtrlSetOnEvent(-1, "Settings")
GUICtrlCreateGroup("Statistiken", 520 - $MP, 460, 190, 170)
GUICtrlCreateLabel("Deine Nachrichten:", 530 - $MP, 484)
$statsDN = GUICtrlCreateLabel("-", 650 - $MP, 484, 50)
GUICtrlCreateLabel("Nachrichten:", 530 - $MP, 504)
$statsN = GUICtrlCreateLabel("-", 650 - $MP, 504, 50)
GUICtrlCreateLabel("Seiten:", 530 - $MP, 524)
$statsS = GUICtrlCreateLabel("-", 650 - $MP, 524, 50)
GUICtrlCreateGroup("Top Chatter", 730 - $MP, 460, 250, 170)
GUICtrlCreateLabel("MGC Chatbox Evo - Parser by Der-Eddy in AutoIT", 200 - $MP, 640)
If StringInStr($version, "Preview") Or StringInStr($version, "Debug") Then
	GUICtrlCreateLabel("Version: " & $version, 880 - $MP, 640)
Else
	GUICtrlCreateLabel("Version: " & $version, 910 - $MP, 640)
EndIf
If IniRead($file, "Shoutbox", "Ignore", "4") <> 4 Then GUICtrlSetState($ignorecheck, $GUI_CHECKED)
If IniRead($file, "Shoutbox", "Highlight", "4") <> 4 Then GUICtrlSetState($highlightown, $GUI_CHECKED)
If IniRead($file, "Shoutbox", "Tray", "1") <> 4 Then GUICtrlSetState($traynotify, $GUI_CHECKED)
If IniRead($file, "Shoutbox", "Indent", "1") <> 4 Then GUICtrlSetState($indent, $GUI_CHECKED)
If IniRead($file, "Shoutbox", "Naughty", "4") <> 4 Then GUICtrlSetState($naughtymode, $GUI_CHECKED)
GUISetState(@SW_SHOW)

If GUICtrlRead($channel) = "English" Then
		$ch = 1
	Else
		$ch = 0
EndIf
Ueberpruefung(2, $ch)
While 1
	IniWrite($file, "Shoutbox", "Time", GUICtrlRead($timeinput))
	Ueberpruefung(1, $ch)
	Sleep($time)
WEnd

Func Ueberpruefung($page, $ch = 0)
	;GUICtrlCreateGif($Gui, $temp & "progress.gif", 960, 40, 16, 16)
	$ani = GUICtrlCreateGifEx($Gui, $temp & "progress.gif", 960 - $MP, 40)
	$oWebTCP = _WebTcp_Create(False, False)
	$oWebTCP.Navigate("http://www.elitepvpers.com/")
	$bLoggedIn = _Login($oWebTCP)
	If $bLoggedIn Then $oWebTCP.Navigate("http://www.elitepvpers.com/forum/mgc_cb_evo.php?do=view_archives&page=" & $page & "&langid=2&channel_id=" & $ch)
	$source = $oWebTCP.Body
	If NOT StringInStr($source, '<style type="text/css" id="vbulletin_css">') Then
		MsgBox(48, "Error", "Es konnte keine Verbindung zu Elitepvpers hergestellt werden!")
		_Exit(2)
	EndIf
	If StringInStr($source, "* Style: 'epvp (obsolete)'; Style ID: 3") Then
		MsgBox(48, "Error", "Fehler beim Login")
		_Exit(2)
	EndIf
	If $page = 2 And IniRead($file, "Shoutbox", "Ignore", "4") <> 4 Then
		If $bLoggedIn Then $oWebTCP.Navigate("http://www.elitepvpers.com/forum/profile.php?do=ignorelist")
		$ignore = StringRegExp($oWebTCP.Body, '.html">(.*?)</a><input type="hidden" name="listbits', 3)
	EndIf
	$securitytoken = StringRegExp($source, 'var SECURITYTOKEN = "(.*?)";', 1)
	If $debug = True Then FileWrite("first.html", $source)
	$source = _StringBetween($source, '/mgc_cb_evo_archives.js"></script>', '<div align="center">MGC Chatbox Evo')
	If NOT IsArray($source) Then
		MsgBox(48, "Error", "Ein Fehler beim auslesen der Shoutbox ist aufgetreten!", 10)
		Exit 2
	EndIf
	If $debug = True Then FileWrite("second.html", $source[0])
	$source = StringReplace($source[0], '<img width="16" height="16" src="images/smilies/frown.gif" border="0" alt="" title="Frown" class="inlineimg" />', ':o')
	$source = StringReplace($source, '<img width="16" height="16" src="images/smilies/smile.gif" border="0" alt="" title="Smile" class="inlineimg" />', ':)')
	$source = StringReplace($source, '<img width="16" height="16" src="images/smilies/biggrin.gif" border="0" alt="" title="Big Grin" class="inlineimg" />', ':D')
	$source = StringReplace($source, '<img width="16" height="16" src="images/smilies/tongue.gif" border="0" alt="" title="Stick Out Tongue" class="inlineimg" />', ':P')
	$source = StringReplace($source, '<img width="16" height="16" src="images/smilies/wink.gif" border="0" alt="" title="Wink" class="inlineimg" />', ';)')
	$source = StringRegExpReplace($source, '<img width="(.*?)" height="(.*?)" src="images/smilies/(.*?).gif" border="0" alt="" title="(.*?)" class="inlineimg" />', '*$3*')
	$source = StringReplace($source, "&#8203;", "")
	$source = StringReplace($source, "&#8364;", "€")
	$source = StringReplace($source, "&quot;", '"')
	$source = StringReplace($source, "&#1091;", 'y')
	$source = StringReplace($source, "&#945;", 'a')
	$source = StringReplace($source, "&#953;", 'i')
	$source = StringReplace($source, "&gt;x&gt;'D A |R Iu S'&lt;x&lt;'", ">x>'D A |R Iu S'<x<'")
	$source = StringRegExpReplace($source, '<a(.+)href="(.+)" target=(.*)</a>', "$2")
	$first = _StringBetween($source, '<span class="smallfont">', '</span>')
	$second = StringReplace($source, "''", '""')
;~ 	FileWrite("shit.html", $source)
	$second = StringRegExpReplace($second, '<a style="text-decoration: none" href="http://www.elitepvpers.com/forum/members/(.*?)-(.*?).html">&lt;<span style="color:(.*?)">(.*?)</span>&gt;</a>', '<a style="text-decoration: none" href="http://www.elitepvpers.de/forum/members/$1-$2.html">&lt;<span style="color:$3">$4</span>&gt;</a>')
	$second = StringRegExpReplace($second, '<a style="text-decoration: none" href="http://www.elitepvpers.com/forum/members/(.*?)-(.*?).html">&lt;(.*?)&gt;</a>', '<a style="text-decoration: none" href="http://www.elitepvpers.de/forum/members/$1-$2.html">&lt;<span style="color:black">$3</span>&gt;</a>')
	$second = StringRegExp($second, '<a style="text-decoration: none" href="http://www.elitepvpers.de/forum/members/(.*?)-(.*?).html">&lt;<span style="color:(.*?)">(.*?)</span>&gt;</a>', 3)
	$third = _StringBetween($source, '<span class="smallfont"  align="left">', '</span>')
	$Messages = StringRegExp($source, '<td class="alt1" align="center" nowrap>(.*?)</td>', 3)
	GUICtrlSetData($statsDN, $Messages[2])
	GUICtrlSetData($statsN, $Messages[0])
	GUICtrlSetData($statsS, Ceiling($Messages[0] / 15))
;~ 	$topchat = StringRegExpReplace($source, '<tr><td class="alt2" width="100%" align="left"><a style="text-decoration: none"  href="members/(.*?)-(.*?).html"><span style="color:(.*?)">(.*?)</span></a></td><td class="alt1" align="center">(.*?)</td></tr>', '<tr><td class="alt2" width="100%" align="left"><a style="text-decoration: none"  href="http://www.elitepvpers.de/forum/members/$1-$2.html"><span style="color:$3">$4</span></a></td><td class="alt1" align="center">$5</td></tr')
;~ 	$topchat = StringRegExpReplace($topchat, '<tr><td class="alt2" width="100%" align="left"><a style="text-decoration: none"  href="members/(.*?)-(.*?).html">(.*?)</a></td><td class="alt1" align="center">(.*?)</td></tr>', '<tr><td class="alt2" width="100%" align="left"><a style="text-decoration: none"  href="http://www.elitepvpers.de/forum/members/$1-$2.html"><span style="color:black">$3</span></a></td><td class="alt1" align="center">$4</td></tr>')
;~ 	$topchat = StringRegExp($topchat, '<tr><td class="alt2" width="100%" align="left"><a style="text-decoration: none"  href="http://www.elitepvpers.de/forum/members/(.*?)-(.*?).html"><span style="color:(.*?)">(.*?)</span></a></td><td class="alt1" align="center">(.*?)</td></tr>', 3)
;~ 	_ArrayDisplay($topchat)
	For $i = 14 To 0 Step -1
		$t = ($i + 1) * 4 - 1
		If $third[$i] = $oldtext Then
			$skipold = True
			$oldtext = ""
		EndIf
		If $third[$i] <> $oldtext And $oldtext <> "" Then
			$skipold = True
		EndIf
		If $i = 0 And $page = 1 Then
			$oldtext = $third[0]
		EndIf
		If $skipold = False Then
		_GUICtrlRichEdit_GotoCharPos($Edit, 0)
		If IniRead($file, "Shoutbox", "Ignore", "4") <> 4 Then
			For $ig = 0 To UBound($ignore) -1 Step 1
				If $second[$t] = $ignore[$ig] Then
					$sb = StringReplace("(" & StringRight(StringReplace($first[$i], ' ', ''), 7) & ") Shout eines ignorierten Benutzers", @CRLF, '') & @CRLF
					_GUICtrlRichEdit_InsertText($Edit, $sb)
					$skip = True
					ExitLoop
				EndIf
			Next
		EndIf
		If $skip = False Then
		$secondnew = StringReplace(StringReplace($second[$t], "&lt;", '<'), "&gt;", '>')
		$thirdnew = StringReplace(StringReplace(StringReplace($third[$i], " ", "", 8), "&lt;", '<'), "&gt;", '>')
		If $Traydo = True And IniRead($file, "Shoutbox", "Tray", "1") <> 4 And $secondnew <> IniRead($file, "Benutzerdaten", "ID", "") And WinGetState("Elitepvpers Shoutbox Tool") <> 15 Then
			TrayTip("Neuer Shout von " & $secondnew & " um " &  StringRight(StringReplace($first[$i], ' ', ''), 7), $thirdnew, 5, 1)
		EndIf
		$sb = StringReplace("(" & StringRight(StringReplace($first[$i], ' ', ''), 7) & ") <" & StringReplace(StringReplace($secondnew, "&lt;", '<'), "&gt;", '>') & ">: " & $thirdnew, @CRLF, '') & @CRLF
		_GUICtrlRichEdit_InsertText($Edit, $sb)
		_GUICtrlRichEdit_SetSel($Edit, 9, 9 + StringLen($secondnew), True)
		Switch $second[$t - 1]
		Case "red"
			_GUICtrlRichEdit_SetCharColor($Edit, 255)
		Case "orange"
			_GUICtrlRichEdit_SetCharColor($Edit, 3525375)
		Case "green"
			_GUICtrlRichEdit_SetCharColor($Edit, 3309617)
		Case "#0099ff"
			_GUICtrlRichEdit_SetCharColor($Edit, 16750848)
		Case "#a800aa"
			_GUICtrlRichEdit_SetCharColor($Edit, 11141288)
		Case "#6666FF"
			_GUICtrlRichEdit_SetCharColor($Edit, 16737894)
		Case "#ff3399"
			_GUICtrlRichEdit_SetCharColor($Edit, 10040319)
		Case "black"
			_GUICtrlRichEdit_SetCharColor($Edit, 0)
		EndSwitch
		If IniRead($file, "Shoutbox", "Highlight", "4") <> 4 And $secondnew = IniRead($file, "Benutzerdaten", "ID", $Benutzer) Then
			_GUICtrlRichEdit_SetSel($Edit, 13 + StringLen($secondnew), 9 + StringLen($secondnew) + StringLen($thirdnew), False)
			Switch $second[$t - 1]
			Case "red"
				_GUICtrlRichEdit_SetCharColor($Edit, 255)
			Case "orange"
				_GUICtrlRichEdit_SetCharColor($Edit, 3525375)
			Case "green"
				_GUICtrlRichEdit_SetCharColor($Edit, 3309617)
			Case "#0099ff"
				_GUICtrlRichEdit_SetCharColor($Edit, 16750848)
			Case "#a800aa"
				_GUICtrlRichEdit_SetCharColor($Edit, 11141288)
			Case "#6666FF"
				_GUICtrlRichEdit_SetCharColor($Edit, 16737894)
			Case "#ff3399"
				_GUICtrlRichEdit_SetCharColor($Edit, 10040319)
			Case "black"
				_GUICtrlRichEdit_SetCharColor($Edit, 16750848)
			EndSwitch
		EndIf
		Else
			$skip = False
		EndIf
		Else
			$skipold = False
		EndIf
	Next
	_GUICtrlRichEdit_GotoCharPos($Edit, 0)
	_Ani_DeleteAnimation($ani)
	If $page = 1 Then $Traydo = True
EndFunc ;==>Ueberpruefung

Func _Login($oWebTCP) ; Danke an AMrK von autoitbot.de
	$oWebTCP.Navigate("http://www.elitepvpers.com/forum/login.php?do=login", "vb_login_username="&$Benutzer&"&vb_login_password=&cookieuser=1&s=&securitytoken=guest&do=login&vb_login_md5password="&$pass&"&vb_login_md5password_utf="&$pass)
;~ 	FileWrite(@ScriptDir & '\login.html', $oWebTCP.Body)
	If StringInStr($oWebTCP.Body, 'vBulletin-Systemmitteilung') Then
		Return False
	Else
		Return True
	EndIf
EndFunc ;==>_Login

Func _Post($ch = 0)
;~ 	$oWebTCP = _WebTcp_Create()
;~ 	$oWebTCP.Navigate("http://www.elitepvpers.com/")
;~ 	$bLoggedIn = _Login($oWebTCP)
	If GUICtrlRead($channel) = "English" Then
		$ch = 1
	Else
		$ch = 0
	EndIf
	If $bLoggedIn Then $oWebTCP.Navigate("http://www.elitepvpers.com/forum/mgc_cb_evo_ajax.php", "do=ajax_chat&channel_id=" & $ch & "&chat=" & StringReplace(StringReplace(GUICtrlRead($input), " ", "%20"), ":", "%3A") & "&securitytoken=" & $securitytoken[0] & "&securitytoken=" & $securitytoken[0] & "&s=")
	GUICtrlSetData($input, "")
EndFunc

Func _smile()
	GUICtrlSetData($input, GUICtrlRead($input) & " :)")
EndFunc

Func _redface()
	GUICtrlSetData($input, GUICtrlRead($input) & " :o")
EndFunc

Func _biggrin()
	GUICtrlSetData($input, GUICtrlRead($input) & " :D")
EndFunc

Func _wink()
	GUICtrlSetData($input, GUICtrlRead($input) & " ;)")
EndFunc

Func _tongue()
	GUICtrlSetData($input, GUICtrlRead($input) & " :p")
EndFunc

Func _cool()
	GUICtrlSetData($input, GUICtrlRead($input) & " :cool:")
EndFunc

Func _rolleyes()
	GUICtrlSetData($input, GUICtrlRead($input) & " :rolleyes:")
EndFunc

Func _mad()
	GUICtrlSetData($input, GUICtrlRead($input) & " :mad:")
EndFunc

Func _eek()
	GUICtrlSetData($input, GUICtrlRead($input) & " :eek:")
EndFunc

Func _frown()
	GUICtrlSetData($input, GUICtrlRead($input) & " :(")
EndFunc

Func _awesome()
	GUICtrlSetData($input, GUICtrlRead($input) & " :awesome:")
EndFunc

Func MY_WM_PAINT($hWnd, $Msg, $wParam, $lParam)
    _WinAPI_RedrawWindow($GUI, 0, 0, $RDW_UPDATENOW)
    _GDIPlus_GraphicsDrawImage($hGraphic, $hImage, 0, 0)
    _WinAPI_RedrawWindow($GUI, 0, 0, $RDW_VALIDATE)
    Return $GUI_RUNDEFMSG
EndFunc

Func Eintrag() ; Speichert Einloggdaten nach erstem Aufrufen
	$bID = GUICtrlRead($Input1)
	$bPW = GUICtrlRead($Input2)
	$PWs = GUICtrlRead($Checkbox1)
	IniWrite($file, "Benutzerdaten", "ID", $bID)
	If $PWs = 1 Then
		IniWrite($file, "Benutzerdaten", "PW", _StringEncrypt(1, $bPW, $passwort, $starke))
	Else
		IniWrite($file, "Benutzerdaten", "PW", 0)
	EndIf
	IniWrite($file, "Benutzerdaten", "HWID", $_hwid)
	IniWrite($file, "Benutzerdaten", "Group", $group[0])
	IniWrite($file, "Shoutbox", "Channel", GUICtrlRead($channel))
	GUIDelete($Form1)
	HotKeySet("{ENTER}")
	$GUI1 = 1
EndFunc ;==>Eintrag

Func Settings()
	IniWrite($file, "Shoutbox", "Ignore", GUICtrlRead($ignorecheck))
	IniWrite($file, "Shoutbox", "Highlight", GUICtrlRead($highlightown))
	IniWrite($file, "Shoutbox", "Tray", GUICtrlRead($traynotify))
	IniWrite($file, "Shoutbox", "Indent", GUICtrlRead($indent))
	IniWrite($file, "Shoutbox", "Naughty", GUICtrlRead($naughtymode))
	If (GUICtrlRead($naughtymode) <> 4 And $naughty = False) Or (GUICtrlRead($naughtymode) = 4 And $naughty = True) Then
		If @Compiled = 1 Then
			Run(FileGetShortName(@ScriptFullPath))
		Else
			Run(FileGetShortName(@AutoItExe) & " " & FileGetShortName(@ScriptFullPath))
		EndIf
		_Exit(1)
	EndIf
	If GUICtrlRead($channel) <> IniRead($file, "Shoutbox", "Channel", "Deutsch") Then
		IniWrite($file, "Shoutbox", "Channel", GUICtrlRead($channel))
		If @Compiled = 1 Then
			Run(FileGetShortName(@ScriptFullPath))
		Else
			Run(FileGetShortName(@AutoItExe) & " " & FileGetShortName(@ScriptFullPath))
		EndIf
		_Exit(1)
	EndIf
	_GUICtrlRichEdit_SetText($Edit, "Shoutbox wird geladen ...")
	$Traydo = False
	If GUICtrlRead($channel) = "English" Then
		$ch = 1
	Else
		$ch = 0
	EndIf
	Ueberpruefung(2, $ch)
	Ueberpruefung(1, $ch)
EndFunc

Func _mimimize()
	GUISetState(@SW_MINIMIZE, $Gui)
EndFunc

Func _restore()
	GUISetState(@SW_RESTORE, $Gui)
EndFunc

Func Profil()
	ShellExecute("http://www.elitepvpers.com/forum/profile.php?do=editprofile")
EndFunc ;==>Profil

Func _Update()
	MsgBox(64, "Neue Version", "Es gibt eine neue Version zum downloaden!")
	ShellExecute("http://www.elitepvpers.com/forum/premium-releases-sharing/2090399-premium-staff-extern-shoutbox-tool.html")
EndFunc

Func _Refresh()
	If GUICtrlRead($channel) = "English" Then
		$ch = 1
	Else
		$ch = 0
	EndIf
	Ueberpruefung(1, $ch)
EndFunc

Func _hotkey()
	If _IsPressed("1B", $dll32) and _IsPressed("10", $dll32) Then _Exit() ; 1B = Esc / 10 = Shift
	If WinGetState("Elitepvpers Shoutbox Tool") = 15 and _IsPressed("0D", $dll32) Then _Post()
EndFunc ;==>_hoteky

Func _Exit($error = 0)
	GUIDelete()
	If $naughty Then
		_WinAPI_DeleteObject($hBmp)
		_GDIPlus_ImageDispose($hImage)
	EndIf
	_GUICtrlRichEdit_Destroy($Edit)
	_GDIPlus_Shutdown()
	_WebTcp_Shutdown()
	DllClose($dll32)
	Exit $error
EndFunc ;==>_Exit
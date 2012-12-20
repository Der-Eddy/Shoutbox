#include "AutoItObject.au3"
#include-once

#region Copyright & Lizenz
;¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯;
;																														;
;		Copyright																										;
;																														;
;	Copyleft (C) 2010 Alexander Mattis																					;
;																														;
;	Erscheinung:	01.11.2010																							;
;	Version:		0.40																								;
;																														;
;																														;
;		Debug-Mode																										;
;																														;
;	Der Debug-Mode kann beim Erstellen eines WebTcp-Objektes eingeschaltet werden, indem man als Parameter "TRUE"		;
;	übergibt. Er kann zu jeder Zeit per $oObject.DebugeModeEnable / $oObject.DebugModeDisable ein- oder ausgeschaltet	;
;	werden.																												;
;																														;
;	Jeder Funktionsaufruf wird durch eine Blaue Zeile (beginnend mit ">") in der Console eingeleitet. Das beenden einer	;
;	Funktion wird durch eine grüne Zeile (beginnend mit "+"), falls die Funktion fehlerfrei ausgeführt wurde, oder		;
;	eine rote Zeile (beginnend mit "!"), falls ein Fehler auftritt, dargestellt. Wichtige Zwischenergebnisse und		;
;	Aktionen werden mithilfe einer gelben Zeie (beginnend mit "-") dargestellt.											;
;																														;
;																														;
;		Lizenz																											;
;																														;
;	GNU Generel Public License																							;
;	This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public	;
;	License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any		;
;	later version. This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without	;
;	even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public		;
;	License for more details. You should have received a copy of the GNU General Public License along with this			;
;	program; if not, see <http://www.gnu.org/licenses/>.																;
;																														;
;																														;
;		Externe Scripte																									;
;																														;
;	AutoItObject.au3 und AutoItObject_X64.dll und AutoItObject.dll sind veröffentlichte Opensource (ausschließlich		;
;	der AutoItObject_X64.dll und der AutoItObject.dll) Quellen von:														;
;	http://autoit.de/index.php?page=Thread&postID=139454#post139454														;
;	Special thanks an die Ersteller:																					;
;		Andreas Karlsson (monoceres)																					;
;		Dragana R. (trancexx)																							;
;		Dave Bakker (Kip)																								;
;		Andreas Bosch (progandy, Prog@ndy)																				;
;																														;
;	Die 7z.exe ist eine veröffentlichte Opensource Software, welche unter der GNU LGPL steht und somit frei verwendet	;
;	werden darf (Autor: Igor Pavlov).																					;
;_______________________________________________________________________________________________________________________;
#endregion Copyright & Lizenz

#region Init/Creation
Func _WebTcp_Startup()
	TCPStartup()
	_AutoItObject_Startup()
EndFunc

Func _WebTcp_Shutdown()
	_AutoItObject_Shutdown()
	TCPShutdown()
EndFunc

Func _WebTcp_Create($bCheckUpdate = True, $bDebugMode = True)
	Local $oWebTcp, $oCookies, $oHeader, $aNewerVersion
	If $bDebugMode Then ConsoleWrite(@CRLF & '> _WebTcp_Create($bCheckUpdate = ' & $bCheckUpdate & ', $bDebugMode = ' & $bDebugMode & ')' & @CRLF)

	$oCookies = _AutoItObject_Create()
	_AutoItObject_AddProperty($oCookies, "Key", $ELSCOPE_PUBLIC, ObjCreate("System.Collections.ArrayList"))
	_AutoItObject_AddProperty($oCookies, "Value", $ELSCOPE_PUBLIC, ObjCreate("System.Collections.ArrayList"))
	_AutoItObject_AddProperty($oCookies, "Expireration", $ELSCOPE_PUBLIC, 0)
	_AutoItObject_AddProperty($oCookies, "MaxLifeTime", $ELSCOPE_PUBLIC, 0)
	_AutoItObject_AddProperty($oCookies, "Count", $ELSCOPE_PUBLIC, 0)
	_AutoItObject_AddProperty($oCookies, "DebugMode", $ELSCOPE_PUBLIC, $bDebugMode)
	_AutoItObject_AddMethod($oCookies, "Refresh", "_WebTcp_Cookies_Refresh")
	_AutoItObject_AddMethod($oCookies, "Clear", "_WebTcp_Cookies_Clear")
	_AutoItObject_AddMethod($oCookies, "Add", "_WebTcp_Cookies_Add")
	_AutoItObject_AddMethod($oCookies, "Remove", "_WebTcp_Cookies_Remove")
	_AutoItObject_AddMethod($oCookies, "Get", "_WebTcp_Cookies_Get")
	_AutoItObject_AddMethod($oCookies, "Set", "_WebTcp_Cookies_Set")
	_AutoItObject_AddMethod($oCookies, "ToString", "_WebTcp_Cookies_ToString")
	_AutoItObject_AddMethod($oCookies, "GetIndex", "_WebTcp_Cookies_GetIndex")
	_AutoItObject_AddMethod($oCookies, "SplitFirstChar", "_WebTcp_SplitFirstChar")
	_AutoItObject_AddDestructor($oCookies, "_WebTcp_Cookies_Destructor")
	If $oCookies = 0 Then
		If $bDebugMode Then ConsoleWrite('! Cookie-Objekt wurde nicht erfolgreich erstellt ' & @CRLF & @CRLF)
		Return SetError(1, 0, 0)
	EndIf
	If $bDebugMode Then ConsoleWrite('- Cookie-Objekt wurde erfolgreich erstellt ' & @CRLF)

	$oHeader = _AutoItObject_Create()
	_AutoItObject_AddProperty($oHeader, "Content", $ELSCOPE_PUBLIC, "")
	_AutoItObject_AddProperty($oHeader, "DebugMode", $ELSCOPE_PUBLIC, $bDebugMode)
	_AutoItObject_AddProperty($oHeader, "ServerIP", $ELSCOPE_PUBLIC, "")
	_AutoItObject_AddMethod($oHeader, "GetHTTPVersion", "_WebTcp_Header_GetHTTPVersion")
	_AutoItObject_AddMethod($oHeader, "GetStatusText", "_WebTcp_Header_GetStatusText")
	_AutoItObject_AddMethod($oHeader, "GetStatusID", "_WebTcp_Header_GetStatusID")
	_AutoItObject_AddMethod($oHeader, "GetServerDate", "_WebTcp_Header_GetServerDate")
	_AutoItObject_AddMethod($oHeader, "GetServerOS", "_WebTcp_Header_GetServerOS")
	_AutoItObject_AddMethod($oHeader, "GetCookie", "_WebTcp_Header_GetCookie")
	_AutoItObject_AddMethod($oHeader, "GetExpireration", "_WebTcp_Header_GetExpireration")
	_AutoItObject_AddMethod($oHeader, "GetLastModification", "_WebTcp_Header_GetLastModification")
	_AutoItObject_AddMethod($oHeader, "GetCacheControl", "_WebTcp_Header_GetCacheControl")
	_AutoItObject_AddMethod($oHeader, "GetPragma", "_WebTcp_Header_GetPragma")
	_AutoItObject_AddMethod($oHeader, "GetContentEncoding", "_WebTcp_Header_GetContentEncoding")
	_AutoItObject_AddMethod($oHeader, "GetConnection", "_WebTcp_Header_GetConnection")
	_AutoItObject_AddMethod($oHeader, "GetTransferEncoding", "_WebTcp_Header_GetTransferEncoding")
	_AutoItObject_AddMethod($oHeader, "GetContenttype", "_WebTcp_Header_GetContentype")
	_AutoItObject_AddMethod($oHeader, "GetLocation", "_WebTcp_Header_GetLocation")
	_AutoItObject_AddMethod($oHeader, "GetContentLength", "_WebTcp_Header_GetContentLength")
	_AutoItObject_AddMethod($oHeader, "GetAcceptRanges", "_WebTcp_Header_getAcceptRanges")
	_AutoItObject_AddMethod($oHeader, "GetEtag", "_WebTcp_Header_GetEtag")
	_AutoItObject_AddMethod($oHeader, "GetPHPVersion", "_WebTcp_Header_GetPHPVersion")
	If $oHeader = 0 Then
		If $bDebugMode Then ConsoleWrite('! Header-Objekt wurde nicht erfolgreich erstellt ' & @CRLF & @CRLF)
		Return SetError(2, 0, 0)
	EndIf
	If $bDebugMode Then ConsoleWrite('- Header-Objekt wurde erfolgreich erstellt ' & @CRLF)

	$oWebTcp = _AutoItObject_Create()
	_AutoItObject_AddProperty($oWebTcp, "Useragent", $ELSCOPE_PUBLIC, "User-Agent: Mozilla/5.0 (Windows; U; Windows NT 5.1; de; rv:1.9.2.3) Gecko/20100401 Firefox/3.6.3 ( .NET CLR 3.5.30729)")
	_AutoItObject_AddProperty($oWebTcp, "Referer", $ELSCOPE_PUBLIC, "")
	_AutoItObject_AddProperty($oWebTcp, "RefererBuffer", $ELSCOPE_PUBLIC, "")
	_AutoItObject_AddProperty($oWebTcp, "PacketAdd", $ELSCOPE_PUBLIC, "")
	_AutoItObject_AddProperty($oWebTcp, "Cookies", $ELSCOPE_PUBLIC, $oCookies)
	_AutoItObject_AddProperty($oWebTcp, "Header", $ELSCOPE_PUBLIC, $oHeader)
	_AutoItObject_AddProperty($oWebTcp, "Body", $ELSCOPE_PUBLIC, "")
	_AutoItObject_AddProperty($oWebTcp, "DebugMode", $ELSCOPE_PUBLIC, $bDebugMode)
	_AutoItObject_AddProperty($oWebTcp, "ProxyIP", $ELSCOPE_PUBLIC, "")
	_AutoItObject_AddProperty($oWebTcp, "ProxyPort", $ELSCOPE_PUBLIC, "")
	_AutoItObject_AddProperty($oWebTcp, "TimeOut", $ELSCOPE_PUBLIC, 60*1000)
	_AutoItObject_AddMethod($oWebTcp, "IsHex", "_WebTcp_IsHex")
	_AutoItObject_AddMethod($oWebTcp, "GetHexLength", "_WebTcp_GetHexLength")
	_AutoItObject_AddMethod($oWebTcp, "HexToDec", "_WebTcp_HexToDec")
	_AutoItObject_AddMethod($oWebTcp, "ReturnErrorMessage", "_WebTcp_ReturnErrorMessage")
	_AutoItObject_AddMethod($oWebTcp, "CreatePacket", "_WebTcp_CreatePacket")
	_AutoItObject_AddMethod($oWebTcp, "SendPacket", "_WebTcp_SendPacket")
	_AutoItObject_AddMethod($oWebTcp, "Navigate", "_WebTcp_Navigate")
	_AutoItObject_AddMethod($oWebTcp, "UrlToName", "_WebTcp_URLToName")
	_AutoItObject_AddMethod($oWebTcp, "SetProxy", "_WebTcp_SetProxy")
	_AutoItObject_AddMethod($oWebTcp, "DebugModeEnable", "_WebTcp_DebugModeEnable")
	_AutoItObject_AddMethod($oWebTcp, "DebugModeDisable", "_WebTcp_DebugModeDisable")
	If $oWebTcp = 0 Then
		If $bDebugMode Then ConsoleWrite('! WebTcp-Objekt wurde nicht erfolgreich erstellt ' & @CRLF & @CRLF)
		Return SetError(3, 0, 0)
	EndIf
	If $bDebugMode Then ConsoleWrite('- WebTcp-Objekt wurde erfolgreich erstellt ' & @CRLF & @CRLF)

	If (Not @Compiled) And $bCheckUpdate Then
		If $bDebugMode Then ConsoleWrite("- Überprüfe WebTcp auf Updates!" & @CRLF)
		$oWebTcp.Navigate("http://www.autoitbot.de/index.php?page=DatabaseItem&id=76")
		$aNewerVersion = StringRegExp($oWebTcp.Body, '\<input id\=\"WebTcpVersion\" type\=\"hidden\" value\=\"(.*?)\"\>', 3)
		If Not @error Then
			If (Number(StringReplace($aNewerVersion[0], '.', '')) > 40) Then
				If $bDebugMode Then ConsoleWrite("+ Update gefunden: " & $aNewerVersion[0] & @CRLF & _
									"+ http://www.autoitbot.de/index.php?page=DatabaseItem&id=76" & @CRLF & @CRLF)
				MsgBox(270400, "WebTcp Update " & $aNewerVersion[0], "Lieber " & @UserName & "," & @CRLF & _
				"Es ist eine neue Version von WebTcp verfügbar!" & @CRLF & _
				"Du kannst sie unter http://www.autoitbot.de/index.php?page=DatabaseItem&id=76 downloaden." & @CRLF & @CRLF & _
				"Diese Nachricht kannst du unterdrücken, indem du als ersten Parameter bei _WebTcp_Create ein False angibst." & @CRLF & _
				"Sobald das Script kompiliert ist wird diese Nachricht nicht mehr angezeigt." & @CRLF & @CRLF & _
				"Mir freundlichen Grüßen AMrK")
			Else
				If $bDebugMode Then ConsoleWrite("+ Keine Updates gefunden!" & @CRLF)
			EndIf
		Else
			If $bDebugMode Then ConsoleWrite("! Fehler beim Überprüfen auf Updates!" & @CRLF)
		EndIf
	EndIf

	If $bDebugMode Then ConsoleWrite('+ _WebTcp_Create returns ' & $oWebTcp & @CRLF & @CRLF)
	Return $oWebTcp
EndFunc   ;==>_WebTcp_Create
#endregion Init/Creation

#region Cookies
Func _WebTcp_Cookies_ToString($oSelf, $sTrenner = '; ')
	Local $sString, $iIndex
	If $oSelf.DebugMode Then ConsoleWrite('> _WebTcp_Cookies_ToString()' & @CRLF)
	$sString = ""
	If $oSelf.Count > 0 Then
		For $iIndex = 0 To $oSelf.Count - 1
			$sString &= $oSelf.Key.Item($iIndex) & '=' & $oSelf.Value.Item($iIndex) & $sTrenner
		Next
		$sString = StringTrimRight($sString, stringlen($sTrenner))
	EndIf
	If $oSelf.DebugMode Then ConsoleWrite('+ _WebTcp_Cookies_ToString returns ' & $sString & @CRLF & @CRLF)
	Return $sString
EndFunc   ;==>_WebTcp_Cookies_ToString

Func _WebTcp_Cookies_Refresh($oSelf, $aCookies, $bZeroIndexContainsBound = False)
	Local $iIndex, $iStart, $iEnd, $aCookieSplitted, $iFoundIndex
	If $oSelf.DebugMode Then ConsoleWrite('> _WebTcp_Cookies_Refresh(Array, ' & $bZeroIndexContainsBound & ')' & @CRLF)
	If $bZeroIndexContainsBound Then
		$iStart = 1
		$iEnd = $aCookies[0]
	Else
		$iStart = 0
		$iEnd = UBound($aCookies) - 1
	EndIf
	For $iIndex = $iStart To $iEnd
		$aCookieSplitted = $oSelf.SplitFirstChar($aCookies[$iIndex])
		If $aCookieSplitted[0] = 2 Then
			$iFoundIndex = $oSelf.GetIndex($aCookieSplitted[1])
			If $iFoundIndex >= 0 Then
				$oSelf.Set($aCookieSplitted[1], $aCookieSplitted[2])
			Else
				$oSelf.Add($aCookieSplitted[1], $aCookieSplitted[2])
			EndIf
		EndIf
	Next
	If $oSelf.DebugMode Then ConsoleWrite('+ _WebTcp_Cookies_Refresh has no return value' & @CRLF & @CRLF)
EndFunc   ;==>_WebTcp_Cookies_Refresh

Func _WebTcp_Cookies_Clear($oSelf)
	If $oSelf.DebugMode Then ConsoleWrite('> _WebTcp_Cookies_Clear()' & @CRLF)
	$oSelf.Key.Clear
	$oSelf.Value.Clear
	$oSelf.Count = 0
	If $oSelf.DebugMode Then ConsoleWrite('+ _WebTcp_Cookies_Clear has no return value' & @CRLF & @CRLF)
EndFunc   ;==>_WebTcp_Cookies_Clear

Func _WebTcp_Cookies_Add($oSelf, $sKey, $sValue)
	If $oSelf.DebugMode Then ConsoleWrite('> _WebTcp_Cookies_Add(' & $sKey & ', ' & $sValue & ')' & @CRLF)
	$oSelf.Key.Add($sKey)
	$oSelf.Value.Add($sValue)
	$oSelf.Count = $oSelf.Count + 1
	If $oSelf.DebugMode Then ConsoleWrite('+ _WebTcp_Cookies_Add has no return value' & @CRLF & @CRLF)
EndFunc   ;==>_WebTcp_Cookies_Add

Func _WebTcp_Cookies_Remove($oSelf, $sKey)
	Local $iIndex
	If $oSelf.DebugMode Then ConsoleWrite('> _WebTcp_Cookies_Remove(' & $sKey & ')' & @CRLF)
	$iIndex = $oSelf.GetIndex($sKey)
	If $oSelf.DebugMode Then ConsoleWrite('- $oSelf.GetIndex(' & $sKey & ') returned ' & $iIndex & @CRLF)
	If $iIndex >= 0 Then
		$oSelf.Key.RemoveAt($iIndex)
		$oSelf.Value.RemoveAt($iIndex)
		$oSelf.Count = $oSelf.Count - 1
		If $oSelf.DebugMode Then ConsoleWrite('+ _WebTcp_Cookies_Remove returns True' & @CRLF & @CRLF)
		Return True
	Else
		If $oSelf.DebugMode Then ConsoleWrite('+ _WebTcp_Cookies_Remove returns False' & @CRLF & @CRLF)
		Return SetError(4, 0, False)
	EndIf
EndFunc   ;==>_WebTcp_Cookies_Remove

Func _WebTcp_Cookies_Get($oSelf, $sKey)
	Local $iIndex
	If $oSelf.DebugMode Then ConsoleWrite('> _WebTcp_Cookies_Get(' & $sKey & ')' & @CRLF)
	$iIndex = $oSelf.GetIndex($sKey)
	If $oSelf.DebugMode Then ConsoleWrite('- $oSelf.GetIndex(' & $sKey & ') returned ' & $iIndex & @CRLF)
	If $iIndex >= 0 Then
		If $oSelf.DebugMode Then ConsoleWrite('+ _WebTcp_Cookies_Get returns ' & $oSelf.Value.Item($iIndex) & @CRLF & @CRLF)
		Return $oSelf.Value.Item($iIndex)
	Else
		If $oSelf.DebugMode Then ConsoleWrite('+ _WebTcp_Cookies_Get returns ""' & @CRLF & @CRLF)
		Return SetError(4, 0, False)
	EndIf
EndFunc   ;==>_WebTcp_Cookies_Get

Func _WebTcp_Cookies_Set($oSelf, $sKey, $sValue)
	Local $iIndex
	If $oSelf.DebugMode Then ConsoleWrite('> _WebTcp_Cookies_Set(' & $sKey & ', ' & $sValue & ')' & @CRLF)
	$iIndex = $oSelf.GetIndex($sKey)
	If $oSelf.DebugMode Then ConsoleWrite('- $oSelf.GetIndex(' & $sKey & ') returned ' & $iIndex & @CRLF)
	If $iIndex >= 0 Then
		$oSelf.Value.Item($iIndex) = $sValue
		If $oSelf.DebugMode Then ConsoleWrite('+ _WebTcp_Cookies_Set returns True' & @CRLF & @CRLF)
		Return True
	Else
		If $oSelf.DebugMode Then ConsoleWrite('+ _WebTcp_Cookies_Set returns False' & @CRLF & @CRLF)
		Return SetError(4, 0, False)
	EndIf
EndFunc   ;==>_WebTcp_Cookies_Set

Func _WebTcp_Cookies_GetIndex($oSelf, $sKey)
	Local $iIndex, $bGefunden
	If $oSelf.DebugMode Then ConsoleWrite('> _WebTcp_Cookies_GetIndex(' & $sKey & ')' & @CRLF)
	$iIndex = 0
	$bGefunden = False
	While ($iIndex <= ($oSelf.Key.Count - 1)) And (Not $bGefunden)
		If $oSelf.Key.Item($iIndex) = $sKey Then
			$bGefunden = True
		Else
			$iIndex += 1
		EndIf
	WEnd
	If $bGefunden Then
		If $oSelf.DebugMode Then ConsoleWrite('+ _WebTcp_Cookies_GetIndex returns ' & $iIndex & @CRLF & @CRLF)
		Return $iIndex
	Else
		If $oSelf.DebugMode Then ConsoleWrite('+ _WebTcp_Cookies_GetIndex returns -1' & @CRLF & @CRLF)
		Return SetError(4, 0, -1)
	EndIf
EndFunc   ;==>_WebTcp_Cookies_GetIndex

Func _WebTcp_Cookies_Destructor($oSelf)
	$oSelf.Clear
EndFunc   ;==>_WebTcp_Cookies_Destructor
#endregion Cookies

#region Header
Func _WebTcp_Header_GetHTTPVersion($oSelf)
	Local $aRegExp
	If $oSelf.DebugMode Then ConsoleWrite('> _WebTcp_Header_GetHTTPVersion()' & @CRLF)
	$aRegExp = StringRegExp($oSelf.Content, '(?m)^HTTP\/((\d|\.|\w)*) ', 3)
	If @error Then
		If $oSelf.DebugMode Then ConsoleWrite('+ _WebTcp_Header_GetHTTPVersion returns ""' & @CRLF & @CRLF)
		Return SetError(5, 0, False)
	Else
		If $oSelf.DebugMode Then ConsoleWrite('+ _WebTcp_Header_GetHTTPVersion returns ' & $aRegExp[0] & @CRLF & @CRLF)
		Return $aRegExp[0]
	EndIf
EndFunc   ;==>_WebTcp_Header_GetHTTPVersion

Func _WebTcp_Header_GetStatusText($oSelf)
	Local $aRegExp
	If $oSelf.DebugMode Then ConsoleWrite('> _WebTcp_Header_GetStatusText()' & @CRLF)
	$aRegExp = StringRegExp($oSelf.Content, '(?m)^HTTP\/((\d|\.|\w)*) ((\d)*)', 3)
	If @error Then
		Return SetError(6, 0, False)
	ElseIf UBound($aRegExp) >= 2 Then
		If $oSelf.DebugMode Then ConsoleWrite('+ _WebTcp_Header_GetStatusText returns ' & $aRegExp[0] & @CRLF & @CRLF)
		Return $aRegExp[2]
	Else
		If $oSelf.DebugMode Then ConsoleWrite('+ _WebTcp_Header_GetStatusText returns ""' & @CRLF & @CRLF)
		Return ""
	EndIf
EndFunc   ;==>_WebTcp_Header_GetStatusText

Func _WebTcp_Header_GetStatusID($oSelf)
	Local $aRegExp
	If $oSelf.DebugMode Then ConsoleWrite('> _WebTcp_Header_GetStatusID()' & @CRLF)
	$aRegExp = StringRegExp($oSelf.Content, '(?m)^HTTP\/((\d|\.|\w)*) ((\d)*) (.*)$', 3)
	If @error Then
		Return SetError(7, 0, False)
	ElseIf UBound($aRegExp) >= 4 Then
		If $oSelf.DebugMode Then ConsoleWrite('+ _WebTcp_Header_GetStatusID returns ' & $aRegExp[0] & @CRLF & @CRLF)
		Return StringTrimRight($aRegExp[4], 1)
	Else
		If $oSelf.DebugMode Then ConsoleWrite('+ _WebTcp_Header_GetStatusID returns ""' & @CRLF & @CRLF)
		Return ""
	EndIf
EndFunc   ;==>_WebTcp_Header_GetStatusID

Func _WebTcp_Header_GetServerDate($oSelf)
	Local $aRegExp
	If $oSelf.DebugMode Then ConsoleWrite('> _WebTcp_Header_GetServerDate()' & @CRLF)
	$aRegExp = StringRegExp($oSelf.Content, '(?m)^Date\: (.*)$', 3)
	If @error Then
		If $oSelf.DebugMode Then ConsoleWrite('+ _WebTcp_Header_GetServerDate returns ""' & @CRLF & @CRLF)
		Return SetError(8, 0, False)
	Else
		If $oSelf.DebugMode Then ConsoleWrite('+ _WebTcp_Header_GetServerDate returns ' & StringTrimRight($aRegExp[0], 1) & @CRLF & @CRLF)
		Return StringTrimRight($aRegExp[0], 1)
	EndIf
EndFunc   ;==>_WebTcp_Header_GetServerDate

Func _WebTcp_Header_GetServerOS($oSelf)
	Local $aRegExp
	If $oSelf.DebugMode Then ConsoleWrite('> _WebTcp_Header_GetServerOS()' & @CRLF)
	$aRegExp = StringRegExp($oSelf.Content, '(?m)^Server\: (.*)$', 3)
	If @error Then
		If $oSelf.DebugMode Then ConsoleWrite('+ _WebTcp_Header_GetServerOS returns ""' & @CRLF & @CRLF)
		Return SetError(9, 0, False)
	Else
		If $oSelf.DebugMode Then ConsoleWrite('+ _WebTcp_Header_GetServerOS returns ' & $aRegExp[0] & @CRLF & @CRLF)
		Return StringTrimRight($aRegExp[0], 1)
	EndIf
EndFunc   ;==>_WebTcp_Header_GetServerOS
Func _WebTcp_Header_GetCookie($oSelf)
	Local $aRegExp
	If $oSelf.DebugMode Then ConsoleWrite('> _WebTcp_Header_GetCookie()' & @CRLF)
	$aRegExp = StringRegExp($oSelf.Content, '(?m)^Set\-Cookie\: (.*?)[\;|'&@CRLF&']', 3)
	If @error Then
		If $oSelf.DebugMode Then ConsoleWrite('+ _WebTcp_Header_GetCookie returns ""' & @CRLF & @CRLF)
		Return SetError(10, 0, False)
	Else
		If $oSelf.DebugMode Then ConsoleWrite('+ _WebTcp_Header_GetCookie returns ' & $aRegExp & @CRLF & @CRLF)
		Return $aRegExp
	EndIf
EndFunc   ;==>_WebTcp_Header_GetCookie

Func _WebTcp_Header_GetExpireration($oSelf)
	Local $aRegExp
	If $oSelf.DebugMode Then ConsoleWrite('> _WebTcp_Header_GetExpireration()' & @CRLF)
	$aRegExp = StringRegExp($oSelf.Content, '(?m)^Expires\: (.*?)\;', 3)
	If @error Then
		If $oSelf.DebugMode Then ConsoleWrite('+ _WebTcp_Header_GetExpireration returns ""' & @CRLF & @CRLF)
		Return SetError(11, 0, False)
	Else
		If $oSelf.DebugMode Then ConsoleWrite('+ _WebTcp_Header_GetExpireration returns ' & StringTrimLeft($aRegExp[0], 1) & @CRLF & @CRLF)
		Return StringTrimLeft($aRegExp[0], 1)
	EndIf
EndFunc   ;==>_WebTcp_Header_GetExpireration

Func _WebTcp_Header_GetLastModification($oSelf)
	Local $aRegExp
	If $oSelf.DebugMode Then ConsoleWrite('> _WebTcp_Header_GetLastModification()' & @CRLF)
	$aRegExp = StringRegExp($oSelf.Content, '(?m)^Last\-Modified\: (.*?)\;', 3)
	If @error Then
		If $oSelf.DebugMode Then ConsoleWrite('+ _WebTcp_Header_GetLastModification returns ""' & @CRLF & @CRLF)
		Return SetError(12, 0, False)
	Else
		If $oSelf.DebugMode Then ConsoleWrite('+ _WebTcp_Header_GetLastModification returns ' & StringTrimLeft($aRegExp[0], 1) & @CRLF & @CRLF)
		Return StringTrimLeft($aRegExp[0], 1)
	EndIf
EndFunc   ;==>_WebTcp_Header_GetLastModification

Func _WebTcp_Header_GetCacheControl($oSelf)
	Local $aRegExp
	If $oSelf.DebugMode Then ConsoleWrite('> _WebTcp_Header_GetCacheControl()' & @CRLF)
	$aRegExp = StringRegExp($oSelf.Content, '(?m)^Cache\-Control\: (.*)$', 3)
	If @error Then
		If $oSelf.DebugMode Then ConsoleWrite('+ _WebTcp_Header_GetCacheControl returns ""' & @CRLF & @CRLF)
		Return SetError(13, 0, False)
	Else
		If $oSelf.DebugMode Then ConsoleWrite('+ _WebTcp_Header_GetCacheControl returns ' & StringTrimRight($aRegExp[0], 1) & @CRLF & @CRLF)
		Return StringTrimRight($aRegExp[0], 1)
	EndIf
EndFunc   ;==>_WebTcp_Header_GetCacheControl

Func _WebTcp_Header_GetPragma($oSelf)
	Local $aRegExp
	If $oSelf.DebugMode Then ConsoleWrite('> _WebTcp_Header_GetPragma()' & @CRLF)
	$aRegExp = StringRegExp($oSelf.Content, '(?m)^Pragma\: (.*)$', 3)
	If @error Then
		If $oSelf.DebugMode Then ConsoleWrite('+ _WebTcp_Header_GetPragma returns ""' & @CRLF & @CRLF)
		Return SetError(14, 0, False)
	Else
		If $oSelf.DebugMode Then ConsoleWrite('+ _WebTcp_Header_GetPragma returns ' & StringTrimRight($aRegExp[0], 1) & @CRLF & @CRLF)
		Return StringTrimRight($aRegExp[0], 1)
	EndIf
EndFunc   ;==>_WebTcp_Header_GetPragma

Func _WebTcp_Header_GetContentEncoding($oSelf)
	Local $aRegExp
	If $oSelf.DebugMode Then ConsoleWrite('> _WebTcp_Header_GetContentEncoding()' & @CRLF)
	$aRegExp = StringRegExp($oSelf.Content, '(?m)^Content\-Encoding\: (.*)$', 3)
	If @error Then
		If $oSelf.DebugMode Then ConsoleWrite('+ _WebTcp_Header_GetContentEncoding returns ""' & @CRLF & @CRLF)
		Return SetError(15, 0, False)
	Else
		If $oSelf.DebugMode Then ConsoleWrite('+ _WebTcp_Header_GetContentEncoding returns ' & StringTrimRight($aRegExp[0], 1) & @CRLF & @CRLF)
		Return StringTrimRight($aRegExp[0], 1)
	EndIf
EndFunc   ;==>_WebTcp_Header_GetContentEncoding

Func _WebTcp_Header_GetConnection($oSelf)
	Local $aRegExp
	If $oSelf.DebugMode Then ConsoleWrite('> _WebTcp_Header_GetConnection()' & @CRLF)
	$aRegExp = StringRegExp($oSelf.Content, '(?m)^Connection\: (.*)$', 3)
	If @error Then
		If $oSelf.DebugMode Then ConsoleWrite('+ _WebTcp_Header_GetConnection returns ""' & @CRLF & @CRLF)
		Return SetError(16, 0, False)
	Else
		If $oSelf.DebugMode Then ConsoleWrite('+ _WebTcp_Header_GetConnection returns ' & StringTrimRight($aRegExp[0], 1) & @CRLF & @CRLF)
		Return StringTrimRight($aRegExp[0], 1)
	EndIf
EndFunc   ;==>_WebTcp_Header_GetConnection

Func _WebTcp_Header_GetTransferEncoding($oSelf)
	Local $aRegExp
	If $oSelf.DebugMode Then ConsoleWrite('> _WebTcp_Header_GetTransferEncoding()' & @CRLF)
	$aRegExp = StringRegExp($oSelf.Content, '(?m)^transfer\-encoding\: (.*)$', 3)
	If @error Then
		If $oSelf.DebugMode Then ConsoleWrite('+ _WebTcp_Header_GetTransferEncoding returns ""' & @CRLF & @CRLF)
		Return SetError(17, 0, False)
	Else
		If $oSelf.DebugMode Then ConsoleWrite('+ _WebTcp_Header_GetTransferEncoding returns ' & StringTrimRight($aRegExp[0], 1) & @CRLF & @CRLF)
		Return StringTrimRight($aRegExp[0], 1)
	EndIf
EndFunc   ;==>_WebTcp_Header_GetTransferEncoding

Func _WebTcp_Header_GetContentype($oSelf)
	Local $aRegExp
	If $oSelf.DebugMode Then ConsoleWrite('> _WebTcp_Header_GetContentype()' & @CRLF)
	$aRegExp = StringRegExp($oSelf.Content, '(?m)^Content\-Type\: (.*)$', 3)
	If @error Then
		If $oSelf.DebugMode Then ConsoleWrite('+ _WebTcp_Header_GetContentype returns ""' & @CRLF & @CRLF)
		Return SetError(18, 0, False)
	Else
		If $oSelf.DebugMode Then ConsoleWrite('+ _WebTcp_Header_GetContentype returns ' & StringTrimRight($aRegExp[0], 1) & @CRLF & @CRLF)
		Return StringTrimRight($aRegExp[0], 1)
	EndIf
EndFunc   ;==>_WebTcp_Header_GetContentype

Func _WebTcp_Header_GetLocation($oSelf)
	Local $aRegExp
	If $oSelf.DebugMode Then ConsoleWrite('> _WebTcp_Header_GetLocation()' & @CRLF)
	$aRegExp = StringRegExp($oSelf.Content, '(?m)^Location\: (.*)$', 3)
	If @error Then
		If $oSelf.DebugMode Then ConsoleWrite('+ _WebTcp_Header_GetLocation returns ""' & @CRLF & @CRLF)
		Return SetError(19, 0, False)
	Else
		If $oSelf.DebugMode Then ConsoleWrite('+ _WebTcp_Header_GetLocation returns ' & StringTrimRight($aRegExp[0], 1) & @CRLF & @CRLF)
		Return StringTrimRight($aRegExp[0], 1)
	EndIf
EndFunc   ;==>_WebTcp_Header_GetLocation

Func _WebTcp_Header_GetContentLength($oSelf)
	Local $aRegExp
	If $oSelf.DebugMode Then ConsoleWrite('> _WebTcp_Header_GetContentLength()' & @CRLF)
	$aRegExp = StringRegExp($oSelf.Content, '(?m)^Content-Length\: (.*)$', 3)
	If @error Then
		If $oSelf.DebugMode Then ConsoleWrite('+ _WebTcp_Header_GetContentLength returns ""' & @CRLF & @CRLF)
		Return SetError(20, 0, False)
	Else
		If $oSelf.DebugMode Then ConsoleWrite('+ _WebTcp_Header_GetContentLength returns ' & StringTrimRight($aRegExp[0], 1) & @CRLF & @CRLF)
		Return StringTrimRight($aRegExp[0], 1)
	EndIf
EndFunc   ;==>_WebTcp_Header_GetContentLength

Func _WebTcp_Header_getAcceptRanges($oSelf)
	Local $aRegExp
	If $oSelf.DebugMode Then ConsoleWrite('> _WebTcp_Header_getAcceptRanges()' & @CRLF)
	$aRegExp = StringRegExp($oSelf.Content, '(?m)^Accept\-Ranges\: (.*)$', 3)
	If @error Then
		If $oSelf.DebugMode Then ConsoleWrite('+ _WebTcp_Header_getAcceptRanges returns ""' & @CRLF & @CRLF)
		Return SetError(21, 0, False)
	Else
		If $oSelf.DebugMode Then ConsoleWrite('+ _WebTcp_Header_getAcceptRanges returns ' & StringTrimRight($aRegExp[0], 1) & @CRLF & @CRLF)
		Return StringTrimRight($aRegExp[0], 1)
	EndIf
EndFunc   ;==>_WebTcp_Header_getAcceptRanges

Func _WebTcp_Header_GetEtag($oSelf)
	Local $aRegExp
	If $oSelf.DebugMode Then ConsoleWrite('> _WebTcp_Header_GetEtag()' & @CRLF)
	$aRegExp = StringRegExp($oSelf.Content, '(?m)^Etag\: (.*)$', 3)
	If @error Then
		If $oSelf.DebugMode Then ConsoleWrite('+ _WebTcp_Header_GetEtag returns ""' & @CRLF & @CRLF)
		Return SetError(22, 0, False)
	Else
		If $oSelf.DebugMode Then ConsoleWrite('+ _WebTcp_Header_GetEtag returns ' & StringTrimRight($aRegExp[0], 1) & @CRLF & @CRLF)
		Return StringTrimRight($aRegExp[0], 1)
	EndIf
EndFunc   ;==>_WebTcp_Header_GetEtag

Func _WebTcp_Header_GetPHPVersion($oSelf)
	Local $aRegExp
	If $oSelf.DebugMode Then ConsoleWrite('> _WebTcp_Header_GetPHPVersion()' & @CRLF)
	$aRegExp = StringRegExp($oSelf.Content, '(?m)^X\-Powered\-By\:.*PHP\/((\d|\.|\w)*)', 3)
	If @error Then
		If $oSelf.DebugMode Then ConsoleWrite('+ _WebTcp_Header_GetPHPVersion returns ""' & @CRLF & @CRLF)
		Return SetError(23, 0, False)
	Else
		If $oSelf.DebugMode Then ConsoleWrite('+ _WebTcp_Header_GetPHPVersion returns ' & $aRegExp[0] & @CRLF & @CRLF)
		Return $aRegExp[0]
	EndIf
EndFunc   ;==>_WebTcp_Header_GetPHPVersion
#endregion Header

#region Main
Func _WebTcp_SetProxy($oSelf, $sIP, $sPort)
	If $oSelf.DebugMode Then ConsoleWrite('> _WebTcp_SetProxy(' & $sIP & ', ' & $sPort & ')' & @CRLF)
	$oSelf.ProxyIP = $sIP
	$oSelf.ProxyPort = $sPort
	If $oSelf.DebugMode Then ConsoleWrite('+ _WebTcp_SetProxy has no return value' & @CRLF & @CRLF)
EndFunc   ;==>_WebTcp_SetProxy

Func _WebTcp_URLToName($oSelf, $sUrl)
	Local $aHost
	If $oSelf.DebugMode Then ConsoleWrite('> _WebTcp_URLToName(' & $sUrl & ')' & @CRLF)
	If StringLeft($sUrl, 7) = 'http://' Then $sUrl = StringTrimLeft($sUrl, 7)
	$aHost = StringSplit($sUrl, '/')
	If $oSelf.DebugMode Then ConsoleWrite('+ _WebTcp_URLToName returns ' & $aHost[1] & @CRLF & @CRLF)
	Return $aHost[1]
EndFunc   ;==>_WebTcp_URLToName

Func _WebTcp_CreatePacket($oSelf, $sUrl, $sPost = "", $sPostType = "application/x-www-form-urlencoded")
	Local $sHost, $sPacket, $aCookies, $iIndex, $sCookies, $sPage
	If $oSelf.DebugMode Then ConsoleWrite('> _WebTcp_CreatePacket(' & $sUrl & ', ' & $sPost & ', ' & $sPostType & ')' & @CRLF)

	$oSelf.RefererBuffer = $sUrl
	If StringLeft($sUrl, 7) = 'http://' Then $sUrl = StringTrimLeft($sUrl, 7)
	$sHost = $oSelf.UrlToName($sUrl)
	If $oSelf.ProxyIP = "" Or $oSelf.ProxyPort = "" Then
		$sPage = StringTrimLeft($sUrl, StringLen($sHost) + 1)
		While StringLeft($sPage, 1) = '/'
			$sPage = StringTrimLeft($sPage, 1)
		WEnd
		$sPage = '/' & $sPage
	Else
		$sPage = "http://" & $sUrl
	EndIf
	If $sPost = "" Then
		$sPacket = "GET " & $sPage & " HTTP/1.1" & @CRLF
	Else
		$sPacket = "POST " & $sPage & " HTTP/1.1" & @CRLF
	EndIf
	$sPacket &= "Host: " & $sHost & @CRLF
	$sPacket &= "User-Agent: " & $oSelf.UserAgent & @CRLF
	$sPacket &= "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" & @CRLF
	$sPacket &= "Accept-Language: de-de,de;q=0.8,en-us;q=0.5,en;q=0.3" & @CRLF
	$sPacket &= "Accept-Charset: ISO-8859-1,utf-8;q=0.7,*;q=0.7" & @CRLF
	$sPacket &= "Keep-Alive: 115" & @CRLF
	If $oSelf.ProxyIP <> "" And $oSelf.ProxyPort <> "" Then
		$sPacket &= "Proxy-Connection: keep-alive" & @CRLF
	Else
		$sPacket &= "Connection: keep-alive" & @CRLF
	EndIf
	$aCookies = $oSelf.Cookies.ToString
	If $aCookies <> "" Then
		$sPacket &= "Cookie: " & $aCookies & @CRLF
	EndIf
	If $oSelf.Referer <> "" Then $sPacket &= "Referer: " & $oSelf.Referer & @CRLF
	If $oSelf.PacketAdd <> "" Then $sPacket &= $oSelf.PacketAdd & @CRLF
	If $sPost <> "" Then
		$sPacket &= "Content-Type: " & $sPostType & @CRLF
		$sPacket &= "Content-Length: " & StringLen($sPost) & @CRLF & @CRLF & $sPost
	Else
		$sPacket &= @CRLF
	EndIf
	If $oSelf.DebugMode Then ConsoleWrite('- Packet was created and can be found as file: ' & _WebTcp_DebugCreatePacketFile($sPacket) & @CRLF)
	If $oSelf.DebugMode Then ConsoleWrite('+ _WebTcp_CreatePacket returns the Packet' & @CRLF & @CRLF)
	Return $sPacket
EndFunc   ;==>_WebTcp_CreatePacket

Func _WebTcp_DebugCreatePacketFile($sPacket)
	Local $iCounter, $hFile
	$iCounter = 1
	While FileExists(@TempDir & '\WebTcp-Packet_No' & $iCounter & '.txt')
		$iCounter += 1
	WEnd
	$hFile = FileOpen(@TempDir & '\WebTcp-Packet_No' & $iCounter & '.txt', 1)
	FileWrite($hFile, $sPacket)
	FileClose($hFile)
	Return @TempDir & '\WebTcp-Packet_No' & $iCounter & '.txt'
EndFunc   ;==>_WebTcp_DebugCreatePacketFile

Func _WebTcp_SendPacket($oSelf, $sHost, $sPacket, $iPort = 80, $bBinary = False)
	Local $iTimer, $aSplit, $sIP, $iSocket, $sRecv, $iPartLaenge, $iGesamtLaenge, $sLaengeRecv, $aCookies, $iContentLength, $iBytes, $iProxyRecv, $sLastRecv, $sTempRecv, $hFile
	If $oSelf.DebugMode Then ConsoleWrite('> _WebTcp_SendPacket(' & $sHost & ', Packet, ' & $iPort & ', ' & $bBinary & ')' & @CRLF)


	If $oSelf.ProxyIP <> "" And $oSelf.ProxyPort <> "" Then
		If $oSelf.DebugMode Then ConsoleWrite('- Proxy was found: ' & $oSelf.ProxyIP & ':' & $oSelf.ProxyPort & @CRLF)
		$sIP = TCPNameToIP($oSelf.ProxyIP)
		$oSelf.Header.ServerIP = ""
		If @error Then
			If $oSelf.DebugMode Then ConsoleWrite('! TCPNameToIP failed with ProxyIP' & @CRLF & @CRLF)
			Return SetError(24, 0, "")
		EndIf
		$iSocket = TCPConnect($sIP, $oSelf.ProxyPort)
		If @error Then
			If $oSelf.DebugMode Then ConsoleWrite('! TCPConnect failed with ProxyPort' & @CRLF & @CRLF)
			Return SetError(25, 0, "")
		EndIf
	Else
		$aSplit = StringSplit($sHost, ':')
		If $aSplit[0] = 2 Then
			If $oSelf.DebugMode Then ConsoleWrite('- Script found an IP including Port as Host' & @CRLF)
			$sHost = $aSplit[1]
			$iPort = Number($aSplit[2])
		EndIf
		$sIP = TCPNameToIP($sHost)
		$oSelf.Header.ServerIP = $sIP

		If @error Then
			If $oSelf.DebugMode Then ConsoleWrite('! TCPNameToIP failed with Host' & @CRLF & @CRLF)
			Return SetError(26, 0, "")
		EndIf
		$iSocket = TCPConnect($sIP, $iPort)
		If @error Then
			If $oSelf.DebugMode Then ConsoleWrite('! TCPConnect failed with Port' & @CRLF & @CRLF)
			Return SetError(27, 0, "")
		EndIf
	EndIf

	$iBytes = TCPSend($iSocket, $sPacket)
	If @error Then
		TCPCloseSocket($iSocket)
		If $oSelf.DebugMode Then ConsoleWrite('! TCPSend failed' & @CRLF & @CRLF)
		Return SetError(28, 0, "")
	EndIf
	If $oSelf.DebugMode Then ConsoleWrite('- Bytes sended: ' & $iBytes & @CRLF)

	$sRecv = ""
	$iTimer = TimerInit()
	Do
		$sRecv &= StringTrimLeft(TCPRecv($iSocket, 1, 1), 2)
	Until StringInStr($sRecv, StringTrimLeft(StringToBinary(@CRLF & @CRLF), 2)) Or (TimerDiff($iTimer) > 60*1000)

	If (TimerDiff($iTimer) > $oSelf.TimeOut) Then
		If $oSelf.DebugMode Then ConsoleWrite('! Server timed out (' & $oSelf.TimeOut & ' MS)' & @CRLF & @CRLF)
		Return SetError(29, 0, "")
	Else
		$oSelf.Header.Content = BinaryToString("0x" & $sRecv)
		$sRecv = ""

		If $oSelf.ProxyIP <> "" And $oSelf.ProxyPort <> "" Then
			If $oSelf.DebugMode Then ConsoleWrite('- Recv via Proxy ' & @CRLF)
			$iProxyRecv = 0
			$sLastRecv = ""
			Do
				$sRecv &= TCPRecv($iSocket, 1)
				$iProxyRecv += 1
				If $sLastRecv <> $sRecv Then
					$sLastRecv = $sRecv
					$iProxyRecv = 0
				EndIf
			Until $iProxyRecv >= 10000
		Else
			$iContentLength = $oSelf.Header.GetContentLength
			If $iContentLength <> "" Then
				If $oSelf.DebugMode Then ConsoleWrite('- Recv via Content-Length: ' & $iContentLength & @CRLF)
				While (StringLen($sRecv)/2) < $iContentLength
					$sRecv &= StringTrimLeft(TCPRecv($iSocket, 1, 1), 2)
				WEnd
				$sRecv = "0x" & $sRecv
				If Not $bBinary Then $sRecv = BinaryToString($sRecv)
			Else
				If $oSelf.DebugMode Then ConsoleWrite('- Recv via HexBody ' & @CRLF)

				While 1
					$sTempRecv = ""
					Do
						$sTempRecv &= BinaryToString(TCPRecv($iSocket, 1, 1))
					Until StringInStr($sTempRecv, @CRLF)
					$sTempRecv = StringTrimRight($sTempRecv, StringLen(@CRLF))

					$iPartLaenge = $oSelf.HexToDec($sTempRecv)

					If $iPartLaenge = 0 Then ExitLoop

					$sTempRecv = ""
					Do
						$sTempRecv &= BinaryToString(TCPRecv($iSocket, 1, 1))
					Until StringLen($sTempRecv) = $iPartLaenge
					$sRecv &= $sTempRecv

					$sTempRecv = ""
					Do
						$sTempRecv &= BinaryToString(TCPRecv($iSocket, 1, 1))
					Until StringInStr($sTempRecv, @CRLF)
				WEnd

				If $bBinary Then $sRecv = BinaryToString($sRecv)
			EndIf
		EndIf
		TCPCloseSocket($iSocket)

		If $oSelf.Header.getContentEncoding = "gzip" Then
			If $oSelf.DebugMode Then ConsoleWrite('- Body ist gZipped ' & @CRLF)
			If $bBinary Then
				If FileExists(@TempDir & '\body.gz') Then FileDelete(@TempDir & '\body.gz')
				If FileExists(@TempDir & '\body') Then FileDelete(@TempDir & '\body')
				$hFile = FileOpen(@TempDir & '\body.gz', 17)
				FileWrite($hFile, $sRecv)
				FileClose($hFile)
				If $oSelf.DebugMode Then ConsoleWrite('- Entpacke Body ' & @CRLF)
				RunWait('"' & @ScriptDir & '\7z.exe" e body.gz', @TempDir, @SW_HIDE)
				$hFile = FileOpen(@TempDir & '\body')
				$sRecv = FileRead($hFile)
				FileClose($hFile)
			Else
				If FileExists(@TempDir & '\body.gz') Then FileDelete(@TempDir & '\body.gz')
				If FileExists(@TempDir & '\body') Then FileDelete(@TempDir & '\body')
				$hFile = FileOpen(@TempDir & '\body.gz', 1)
				FileWrite($hFile, $sRecv)
				FileClose($hFile)
				If $oSelf.DebugMode Then ConsoleWrite('- Entpacke Body ' & @CRLF)
				RunWait('"' & @ScriptDir & '\7z.exe" e body.gz', @TempDir, @SW_HIDE)
				$hFile = FileOpen(@TempDir & '\body')
				$sRecv = FileRead($hFile)
				FileClose($hFile)
			EndIf
			If $oSelf.DebugMode Then ConsoleWrite('- Body wurde entpackt ' & @CRLF)
		EndIf

		$oSelf.Body = $sRecv
		$oSelf.Referer = $oSelf.RefererBuffer
		$aCookies = $oSelf.Header.GetCookie
		If IsArray($aCookies) Then $oSelf.Cookies.Refresh($aCookies)
		If $oSelf.DebugMode Then ConsoleWrite('+ _WebTcp_SendPacket returns the Body' & @CRLF & @CRLF)
		Return $sRecv
	EndIf
EndFunc   ;==>_WebTcp_SendPacket

Func _WebTcp_Navigate($oSelf, $sUrl, $sPost = "", $sPostType = "application/x-www-form-urlencoded", $iPort = 80, $bBinary = False)
	Local $sPacket, $sHost
	If $oSelf.DebugMode Then ConsoleWrite('> _WebTcp_Navigate(' & $sUrl & ', ' & $sPost & ', ' & $sPostType & ', ' & $iPort & ', ' & $bBinary & ')' & @CRLF)
	$sPacket = $oSelf.CreatePacket($sUrl, $sPost, $sPostType)
	$sHost = $oSelf.UrlToName($sUrl)
	If $oSelf.DebugMode Then ConsoleWrite('+ _WebTcp_Navigate returns the Body' & @CRLF & @CRLF)
	Return $oSelf.SendPacket($sHost, $sPacket, $iPort, $bBinary)
EndFunc   ;==>_WebTcp_Navigate

Func _WebTcp_DebugModeEnable($oSelf)
	$oSelf.DebugMode = True
	$oSelf.Header.DebugMode = True
	$oSelf.Cookies.DebugMode = True
EndFunc   ;==>_WebTcp_DebugModeEnable

Func _WebTcp_DebugModeDisable($oSelf)
	$oSelf.DebugMode = False
	$oSelf.Header.DebugMode = False
	$oSelf.Cookies.DebugMode = False
EndFunc   ;==>_WebTcp_DebugModeDisable

Func _WebTcp_ReturnErrorMessage($oSelf, $iErrorID)
	Switch $iErrorID
		case 1
			Return "Cookie-Objekt konnte nicht erstellt werden!"
		Case 2
			Return "Header-Objekt konnte nicht erstellt werden!"
		Case 3
			Return "WebTcp-Objekt konnte nicht erstellt werden!"
		Case 4
			Return "Cookie nicht gefunden!"
		Case 5
			Return "HTTP Version nicht gefunden!"
		Case 6
			Return "Statustext nicht gefunden!"
		Case 7
			Return "StatusID nicht gefunden!"
		Case 8
			Return "ServerDate nicht gefunden!"
		Case 9
			Return "ServerOS nicht gefunden!"
		Case 10
			Return "Cookies nicht gefunden!"
		Case 11
			Return "Expireration nicht gefunden!"
		Case 12
			Return "Last Modification nicht gefunden!"
		Case 13
			Return "Cache Control nicht gefunden!"
		Case 14
			Return "Pragma nicht gefunden!"
		Case 15
			Return "Content Encoding nicht gefunden!"
		Case 16
			Return "Connection nicht gefunden!"
		Case 17
			Return "Transfer Encoding nicht gefunden!"
		Case 18
			Return "ContenType nicht gefunden!"
		Case 19
			Return "Location nicht gefunden!"
		Case 20
			Return "Content Length nicht gefunden!"
		Case 21
			Return "Accept Ranges nicht gefunden!"
		Case 22
			Return "Etag nicht gefunden!"
		Case 23
			Return "PHP Version nicht gefunden!"
		Case 24
			Return "TCPNameToIP mit Proxy ist fehlgeschlagen (Proxy Offline?)!"
		Case 25
			Return "Verbindung zum Proxy fehlgeschlagen (Proxy Offline?)!"
		Case 26
			Return "TCPNameToIP mit dem Host fehlgeschlagen (Host Offline?)!"
		Case 27
			Return "Verbindung zum Host fehlgeschlagen (Host Offline?)!"
		Case 28
			Return "TCPSend fehlgeschlagen! Es konnten keine Daten gesendet werden!"
		Case 29
			Return "Server timed out! Zu lange keine Antwort erhalten!"
		Case Else
			Return "Keine Beschreibung für den Fehler gefunden!"
	EndSwitch
EndFunc

Func _WebTcp_IsHex($oSelf, $sString)
	Local $iPosition, $sChar
	$iPosition = 1
	While StringLen($sString) >= $iPosition
		$sChar = StringMid($sString, $iPosition, 1)
		If	Not( ($sChar = "1") Or ($sChar = "2") Or ($sChar = "3") Or ($sChar = "4") Or ($sChar = "5") Or ($sChar = "6") Or ($sChar = "7") Or ($sChar = "8") Or _
			($sChar = "9") Or ($sChar = "0") Or ($sChar = "A") Or ($sChar = "B") Or ($sChar = "C") Or ($sChar = "D") Or ($sChar = "E") Or ($sChar = "F") ) Then
			Return False
		Else
			$iPosition += 1
		EndIf
	WEnd
	Return True
EndFunc

Func _WebTcp_GetHexLength($oSelf, $sString)
	Select
		Case $oSelf.IsHex($sString)
			Return $oSelf.HexToDec($sString)
		Case StringLeft($sString,2) = "0x" And $oSelf.IsHex(StringTrimLeft($sString,2))
			Return $oSelf.HexToDec(StringTrimLeft($sString,2))
		Case Else
			Return -1
	EndSelect
EndFunc

Func _WebTcp_HexToDec($oSelf, $sNumber)
	Local $iIndex, $iResult = 0
	If StringLen($sNumber) Then
		For $iIndex = 1 To StringLen($sNumber)
			Switch StringLeft(StringRight(StringUpper($sNumber), $iIndex), 1)
				Case '0'
					$iResult += 16^($iIndex-1) * 0
				Case '1'
					$iResult += 16^($iIndex-1) * 1
				Case '2'
					$iResult += 16^($iIndex-1) * 2
				Case '3'
					$iResult += 16^($iIndex-1) * 3
				Case '4'
					$iResult += 16^($iIndex-1) * 4
				Case '5'
					$iResult += 16^($iIndex-1) * 5
				Case '6'
					$iResult += 16^($iIndex-1) * 6
				Case '7'
					$iResult += 16^($iIndex-1) * 7
				Case '8'
					$iResult += 16^($iIndex-1) * 8
				Case '9'
					$iResult += 16^($iIndex-1) * 9
				Case 'A'
					$iResult += 16^($iIndex-1) * 10
				Case 'B'
					$iResult += 16^($iIndex-1) * 11
				Case 'C'
					$iResult += 16^($iIndex-1) * 12
				Case 'D'
					$iResult += 16^($iIndex-1) * 13
				Case 'E'
					$iResult += 16^($iIndex-1) * 14
				Case 'F'
					$iResult += 16^($iIndex-1) * 15
			EndSwitch
		Next
	EndIf
	Return $iResult
EndFunc

Func _WebTcp_SplitFirstChar($oSelf, $sString, $sTrimmer = "=")
	Local $iPosition
	$iPosition = StringInStr($sString, $sTrimmer, 1)
	If $iPosition Then
		Local $aArray[3]
		$aArray[0] = 2
		$aArray[1] = StringLeft($sString, $iPosition-1)
		$aArray[2] = StringTrimLeft($sString, $iPosition)
	Else
		Local $aArray[2]
		$aArray[0] = 1
		$aArray[1] = $sString
	EndIf
	Return $aArray
EndFunc
#endregion Main

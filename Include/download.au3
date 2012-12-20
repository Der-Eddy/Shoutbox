Func _download($dUrl, $dPath, $dText = "Download ...")
	$size = InetGetSize($dUrl)
	If $size = 0 Then
		MsgBox(48, "Error", "Ausgewählte Datei existiert nicht oder ist fehlerhaft!")
		Exit 2
	EndIf
	$downgui = GUICreate("Downloading...", 396, 250, 195, 125, $WS_DLGFRAME)
	$dProgress = GUICtrlCreateProgress(16, 32, 362, 25)
	GUICtrlCreateLabel($dText, 16, 8, 265, 20)
	GUICtrlSetFont(-1, 11, 800, 0, "MS Sans Serif")
	$LabelProzent = GUICtrlCreateLabel("%", 16, 60, 268, 17)
	GUICtrlCreateLabel("Download von:", 16, 78, 76, 17)
	GUICtrlCreateLabel($dUrl, 16, 94)
	GUICtrlCreateLabel("Größe:", 16, 118, 36, 17)
	GUICtrlCreateLabel(Round($size / 1000, 2) & ' KiloBytes', 16, 134)
	GUICtrlCreateLabel("Bisher kopiert:", 16, 158, 71, 17)
	$Labelcopy = GUICtrlCreateLabel("", 16, 174, 277, 17)
	GUICtrlCreateLabel("Geschwindigkeit:", 16, 198, 85, 17)
	$Labelspeed = GUICtrlCreateLabel("", 16, 222, 277, 17)
	GUISetState(@SW_SHOW)
	$prozentold = 0
	$ddownload = InetGet($dUrl, $dPath, 0, 1)
	$timer = TimerInit()
	Do
		$Prozent = Round(InetGetInfo($ddownload,0) / $size * 100, 0)
		If $prozentold <> $Prozent Then
			If StringIsAlNum($Prozent) Then
				GUICtrlSetData($LabelProzent, $Prozent & '%')
				GUICtrlSetData($dProgress, $Prozent)
				$prozentold = $Prozent
			EndIf
		EndIf
		GUICtrlSetData($Labelcopy, Round(InetGetInfo($ddownload,0) / 1034, 2) & ' KiloBytes von ' & $size & ' KiloBytes')
		GUICtrlSetData($Labelspeed, Round((InetGetInfo($ddownload,0) / 1024) / (TimerDiff($timer) / 1024), 2) & ' kbytes/sek')
		Sleep (50)
	Until InetGetInfo($ddownload,2) = True
	Return 1
EndFunc ;==>_download
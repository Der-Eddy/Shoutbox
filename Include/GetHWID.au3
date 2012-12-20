#include-once
;=================================================================================================
; Function:			_MD5($Data)
; Description:		Returns the MD5 hashed data.
; Return Value(s):	On Success - Returns the MD5 hashed data.
;					On Failure - Returns false
;					@Error - 1 = Failed to open 'Advapi32.dll'.
;							 2 = Failed to aquire crypt context.
;							 3 = Failed to create hash object.
;							 4 = Failed to hash the data.
;							 5 = Failed to get the hash param.
; Author(s):		KillerDeluxe
;=================================================================================================
Func _MD5($Data)
	$hProv 	=  	DllStructCreate("ULONG_PTR")
	$hHash 	=  	DllStructCreate("ULONG_PTR")
	$cbHash	= 	DllStructCreate("ULONG_PTR")
				DllStructSetData($cbHash, 1, 16)
	$Hash 	= 	DllStructCreate("BYTE[" & StringLen($Data) + 1 & "]")
				DllStructSetData($Hash, 1, $Data)
	$digit	=	DllStructCreate("char[16]")
				DllStructSetData($digit, 1, "0123456789abcdef")
	$fHash	=	DllStructCreate("char[32]")

	$Advapi32 = DllOpen("Advapi32.dll")
	If @error Then Return SetError(1, "", False)

	DllCall($Advapi32, "BOOL", "CryptAcquireContextA", "ptr", DllStructGetPtr($hProv), "int", 0, "int", 0, "DWORD", 1, "DWORD", 0xF0000000)
	If @error Then Return SetError(2, "", False)

	DllCall($Advapi32, "BOOL", "CryptCreateHash", "ULONG_PTR", DllStructGetData($hProv, 1), "UINT", BitOR(BitShift(4, -13), 3), "int", 0, "int", 0, "ptr", DllStructGetPtr($hHash))
	If @error Then Return SetError(3, "", False)

	DllCall($Advapi32, "BOOL", "CryptHashData", "ULONG_PTR", DllStructGetData($hHash, 1), "ptr", DllStructGetPtr($Hash), "DWORD", StringLen($Data), "int", 0)
	If @error Then Return SetError(4, "", False)

	$Hash = DllStructCreate("BYTE[16]")
	DllCall($Advapi32, "BOOL", "CryptGetHashParam", "ULONG_PTR", DllStructGetData($hHash, 1), "DWORD", 2, "ptr", DllStructGetPtr($Hash), "DWORD*", DllStructGetPtr($cbHash), "int", 0)
	If @error Then Return SetError(5, "", False)

	$l = 1
	For $i = 1 To DllStructGetData($cbHash, 1)
		DllStructSetData($fHash, 1, DllStructGetData($digit, 1, BitShift(DllStructGetData($Hash, 1, $i), 4) + 1), $l)
		$l += 1
		DllStructSetData($fHash, 1, DllStructGetData($digit, 1, BitAND(DllStructGetData($Hash, 1, $i), 0xF) + 1), $l)
		$l += 1
	Next

	DllCall($Advapi32, "BOOL", "CryptDestroyHash", "ULONG_PTR", DllStructGetData($hHash, 1))
	DllCall($Advapi32, "BOOL", "CryptReleaseContext", "ULONG_PTR", DllStructGetData($hProv, 1), "int", 0)

	DllStructSetData($fHash, 1, 0, 33)
	Return DllStructGetData($fHash, 1)
EndFunc


;=================================================================================================
; Function:			_GetHWID()
; Description:		Returns the MD5 hashed HWID.
; Return Value(s):	On Success - Returns the MD5 hashed HWID.
;					On Failure - Returns false
;					@Error - 1 = Failed to get 'HwProfileGuid'.
;							 2 = Failed to get the drive serial.
;							 3 = Failed to hash the data.
; Author(s):		KillerDeluxe
;=================================================================================================
Func _GetHWID()
	Local $HW_PROFILE_INFO = DllStructCreate("dword;char[39];char[80]")
	DllCall("Advapi32.dll", "int", "GetCurrentHwProfileA", "ptr", DllStructGetPtr($HW_PROFILE_INFO))
	If @error Then Return SetError(1, "", False)

	$GUID = DllStructGetData($HW_PROFILE_INFO, 2)
	$HDDSerial = DriveGetSerial(@HomeDrive)
	If @error Then Return SetError(2, "", False)

	$ReturnData = StringLower(_MD5(DllStructGetData($HW_PROFILE_INFO, 2) & $HDDSerial))
	If @error Then Return SetError(3, "", False)

	Return $ReturnData
EndFunc
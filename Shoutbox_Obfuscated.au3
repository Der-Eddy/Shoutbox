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
Global Const $BS_DEFPUSHBUTTON = 0x0001
Global Const $ES_CENTER = 1
Global Const $ES_MULTILINE = 4
Global Const $ES_PASSWORD = 32
Global Const $ES_AUTOVSCROLL = 64
Global Const $ES_AUTOHSCROLL = 128
Global Const $ES_READONLY = 2048
Global Const $ES_WANTRETURN = 4096
Global Const $EM_SETSEL = 0xB1
Global Const $__EDITCONSTANT_WS_VSCROLL = 0x00200000
Global Const $__EDITCONSTANT_WS_HSCROLL = 0x00100000
Global Const $GUI_SS_DEFAULT_EDIT = BitOR($ES_WANTRETURN, $__EDITCONSTANT_WS_VSCROLL, $__EDITCONSTANT_WS_HSCROLL, $ES_AUTOVSCROLL, $ES_AUTOHSCROLL)
Global Const $GUI_EVENT_CLOSE = -3
Global Const $GUI_EVENT_MINIMIZE = -4
Global Const $GUI_EVENT_RESTORE = -5
Global Const $GUI_RUNDEFMSG = 'GUI_RUNDEFMSG'
Global Const $GUI_CHECKED = 1
Global Const $SS_NOTIFY = 0x0100
Global Const $WS_MINIMIZEBOX = 0x00020000
Global Const $WS_SYSMENU = 0x00080000
Global Const $WS_VSCROLL = 0x00200000
Global Const $WS_CAPTION = 0x00C00000
Global Const $WS_DISABLED = 0x08000000
Global Const $WS_POPUP = 0x80000000
Global Const $WM_PAINT = 0x000F
Global Const $RDW_VALIDATE = 0x0008
Global Const $RDW_UPDATENOW = 0x0100
Global Const $GUI_SS_DEFAULT_GUI = BitOR($WS_MINIMIZEBOX, $WS_CAPTION, $WS_POPUP, $WS_SYSMENU)
;~ #Include <Array.au3>
Global Const $PROV_RSA_FULL = 0x1
Global Const $PROV_RSA_AES = 24
Global Const $CRYPT_VERIFYCONTEXT = 0xF0000000
Global Const $HP_HASHSIZE = 0x0004
Global Const $HP_HASHVAL = 0x0002
Global Const $CRYPT_USERDATA = 1
Global Const $CALG_MD5 = 0x00008003
Global $__g_aCryptInternalData[3]
Func _Crypt_Startup()
If __Crypt_RefCount() = 0 Then
Local $hAdvapi32 = DllOpen("Advapi32.dll")
If @error Then Return SetError(1, 0, False)
__Crypt_DllHandleSet($hAdvapi32)
Local $aRet
Local $iProviderID = $PROV_RSA_AES
If @OSVersion = "WIN_2000" Then $iProviderID = $PROV_RSA_FULL
$aRet = DllCall(__Crypt_DllHandle(), "bool", "CryptAcquireContext", "handle*", 0, "ptr", 0, "ptr", 0, "dword", $iProviderID, "dword", $CRYPT_VERIFYCONTEXT)
If @error Or Not $aRet[0] Then
DllClose(__Crypt_DllHandle())
Return SetError(2, 0, False)
Else
__Crypt_ContextSet($aRet[1])
EndIf
EndIf
__Crypt_RefCountInc()
Return True
EndFunc
Func _Crypt_Shutdown()
__Crypt_RefCountDec()
If __Crypt_RefCount() = 0 Then
DllCall(__Crypt_DllHandle(), "bool", "CryptReleaseContext", "handle", __Crypt_Context(), "dword", 0)
DllClose(__Crypt_DllHandle())
EndIf
EndFunc
Func _Crypt_HashData($vData, $iALG_ID, $fFinal = True, $hCryptHash = 0)
Local $iError
Local $vReturn = 0
Local $iHashSize
Local $aRet
Local $hBuff = 0
_Crypt_Startup()
Do
If $hCryptHash = 0 Then
$aRet = DllCall(__Crypt_DllHandle(), "bool", "CryptCreateHash", "handle", __Crypt_Context(), "uint", $iALG_ID, "ptr", 0, "dword", 0, "handle*", 0)
If @error Or Not $aRet[0] Then
$iError = 1
$vReturn = -1
ExitLoop
EndIf
$hCryptHash = $aRet[5]
EndIf
$hBuff = DllStructCreate("byte[" & BinaryLen($vData) & "]")
DllStructSetData($hBuff, 1, $vData)
$aRet = DllCall(__Crypt_DllHandle(), "bool", "CryptHashData", "handle", $hCryptHash, "struct*", $hBuff, "dword", DllStructGetSize($hBuff), "dword", $CRYPT_USERDATA)
If @error Or Not $aRet[0] Then
$iError = 2
$vReturn = -1
ExitLoop
EndIf
If $fFinal Then
$aRet = DllCall(__Crypt_DllHandle(), "bool", "CryptGetHashParam", "handle", $hCryptHash, "dword", $HP_HASHSIZE, "dword*", 0, "dword*", 4, "dword", 0)
If @error Or Not $aRet[0] Then
$iError = 3
$vReturn = -1
ExitLoop
EndIf
$iHashSize = $aRet[3]
$hBuff = DllStructCreate("byte[" & $iHashSize & "]")
$aRet = DllCall(__Crypt_DllHandle(), "bool", "CryptGetHashParam", "handle", $hCryptHash, "dword", $HP_HASHVAL, "struct*", $hBuff, "dword*", DllStructGetSize($hBuff), "dword", 0)
If @error Or Not $aRet[0] Then
$iError = 4
$vReturn = -1
ExitLoop
EndIf
$iError = 0
$vReturn = DllStructGetData($hBuff, 1)
Else
$vReturn = $hCryptHash
EndIf
Until True
If $hCryptHash <> 0 And $fFinal Then DllCall(__Crypt_DllHandle(), "bool", "CryptDestroyHash", "handle", $hCryptHash)
_Crypt_Shutdown()
Return SetError($iError, 0, $vReturn)
EndFunc
Func __Crypt_RefCount()
Return $__g_aCryptInternalData[0]
EndFunc
Func __Crypt_RefCountInc()
$__g_aCryptInternalData[0] += 1
EndFunc
Func __Crypt_RefCountDec()
If $__g_aCryptInternalData[0] > 0 Then $__g_aCryptInternalData[0] -= 1
EndFunc
Func __Crypt_DllHandle()
Return $__g_aCryptInternalData[1]
EndFunc
Func __Crypt_DllHandleSet($hAdvapi32)
$__g_aCryptInternalData[1] = $hAdvapi32
EndFunc
Func __Crypt_Context()
Return $__g_aCryptInternalData[2]
EndFunc
Func __Crypt_ContextSet($hCryptContext)
$__g_aCryptInternalData[2] = $hCryptContext
EndFunc
Func _SendMessage($hWnd, $iMsg, $wParam = 0, $lParam = 0, $iReturn = 0, $wParamType = "wparam", $lParamType = "lparam", $sReturnType = "lresult")
Local $aResult = DllCall("user32.dll", $sReturnType, "SendMessageW", "hwnd", $hWnd, "uint", $iMsg, $wParamType, $wParam, $lParamType, $lParam)
If @error Then Return SetError(@error, @extended, "")
If $iReturn >= 0 And $iReturn <= 4 Then Return $aResult[$iReturn]
Return $aResult
EndFunc
Global Const $tagPOINT = "struct;long X;long Y;endstruct"
Global Const $tagRECT = "struct;long Left;long Top;long Right;long Bottom;endstruct"
Global Const $tagSYSTEMTIME = "struct;word Year;word Month;word Dow;word Day;word Hour;word Minute;word Second;word MSeconds;endstruct"
Global Const $tagNMHDR = "struct;hwnd hWndFrom;uint_ptr IDFrom;INT Code;endstruct"
Global Const $tagCOMBOBOXEXITEM = "uint Mask;int_ptr Item;ptr Text;int TextMax;int Image;int SelectedImage;int OverlayImage;" & _
"int Indent;lparam Param"
Global Const $tagNMCOMBOBOXEX = $tagNMHDR & ";uint Mask;int_ptr Item;ptr Text;int TextMax;int Image;" & _
"int SelectedImage;int OverlayImage;int Indent;lparam Param"
Global Const $tagDTPRANGE = "word MinYear;word MinMonth;word MinDOW;word MinDay;word MinHour;word MinMinute;" & _
"word MinSecond;word MinMSecond;word MaxYear;word MaxMonth;word MaxDOW;word MaxDay;word MaxHour;" & _
"word MaxMinute;word MaxSecond;word MaxMSecond;bool MinValid;bool MaxValid"
Global Const $tagEVENTLOGRECORD = "dword Length;dword Reserved;dword RecordNumber;dword TimeGenerated;dword TimeWritten;dword EventID;" & _
"word EventType;word NumStrings;word EventCategory;word ReservedFlags;dword ClosingRecordNumber;dword StringOffset;" & _
"dword UserSidLength;dword UserSidOffset;dword DataLength;dword DataOffset"
Global Const $tagGDIPSTARTUPINPUT = "uint Version;ptr Callback;bool NoThread;bool NoCodecs"
Global Const $tagGDIPIMAGECODECINFO = "byte CLSID[16];byte FormatID[16];ptr CodecName;ptr DllName;ptr FormatDesc;ptr FileExt;" & _
"ptr MimeType;dword Flags;dword Version;dword SigCount;dword SigSize;ptr SigPattern;ptr SigMask"
Global Const $tagLVITEM = "struct;uint Mask;int Item;int SubItem;uint State;uint StateMask;ptr Text;int TextMax;int Image;lparam Param;" & _
"int Indent;int GroupID;uint Columns;ptr pColumns;ptr piColFmt;int iGroup;endstruct"
Global Const $tagNMLISTVIEW = $tagNMHDR & ";int Item;int SubItem;uint NewState;uint OldState;uint Changed;" & _
"struct;long ActionX;long ActionY;endstruct;lparam Param"
Global Const $tagNMLVCUSTOMDRAW = "struct;" & $tagNMHDR & ";dword dwDrawStage;handle hdc;" & $tagRECT & _
";dword_ptr dwItemSpec;uint uItemState;lparam lItemlParam;endstruct" & _
";dword clrText;dword clrTextBk;int iSubItem;dword dwItemType;dword clrFace;int iIconEffect;" & _
"int iIconPhase;int iPartId;int iStateId;struct;long TextLeft;long TextTop;long TextRight;long TextBottom;endstruct;uint uAlign"
Global Const $tagNMITEMACTIVATE = $tagNMHDR & ";int Index;int SubItem;uint NewState;uint OldState;uint Changed;" & _
$tagPOINT & ";lparam lParam;uint KeyFlags"
Global Const $tagMCHITTESTINFO = "uint Size;" & $tagPOINT & ";uint Hit;" & $tagSYSTEMTIME & _
";" & $tagRECT & ";int iOffset;int iRow;int iCol"
Global Const $tagMCMONTHRANGE = "word MinYear;word MinMonth;word MinDOW;word MinDay;word MinHour;word MinMinute;word MinSecond;" & _
"word MinMSeconds;word MaxYear;word MaxMonth;word MaxDOW;word MaxDay;word MaxHour;word MaxMinute;word MaxSecond;" & _
"word MaxMSeconds;short Span"
Global Const $tagMCRANGE = "word MinYear;word MinMonth;word MinDOW;word MinDay;word MinHour;word MinMinute;word MinSecond;" & _
"word MinMSeconds;word MaxYear;word MaxMonth;word MaxDOW;word MaxDay;word MaxHour;word MaxMinute;word MaxSecond;" & _
"word MaxMSeconds;short MinSet;short MaxSet"
Global Const $tagMCSELRANGE = "word MinYear;word MinMonth;word MinDOW;word MinDay;word MinHour;word MinMinute;word MinSecond;" & _
"word MinMSeconds;word MaxYear;word MaxMonth;word MaxDOW;word MaxDay;word MaxHour;word MaxMinute;word MaxSecond;" & _
"word MaxMSeconds"
Global Const $tagNMSELCHANGE = $tagNMHDR & _
";struct;word BegYear;word BegMonth;word BegDOW;word BegDay;word BegHour;word BegMinute;word BegSecond;word BegMSeconds;endstruct;" & _
"struct;word EndYear;word EndMonth;word EndDOW;word EndDay;word EndHour;word EndMinute;word EndSecond;word EndMSeconds;endstruct"
Global Const $tagTVITEM = "struct;uint Mask;handle hItem;uint State;uint StateMask;ptr Text;int TextMax;int Image;int SelectedImage;" & _
"int Children;lparam Param;endstruct"
Global Const $tagNMTREEVIEW = $tagNMHDR & ";uint Action;" & _
"struct;uint OldMask;handle OldhItem;uint OldState;uint OldStateMask;" & _
"ptr OldText;int OldTextMax;int OldImage;int OldSelectedImage;int OldChildren;lparam OldParam;endstruct;" & _
"struct;uint NewMask;handle NewhItem;uint NewState;uint NewStateMask;" & _
"ptr NewText;int NewTextMax;int NewImage;int NewSelectedImage;int NewChildren;lparam NewParam;endstruct;" & _
"struct;long PointX;long PointY;endstruct"
Global Const $tagNMTVCUSTOMDRAW = "struct;" & $tagNMHDR & ";dword DrawStage;handle HDC;" & $tagRECT & _
";dword_ptr ItemSpec;uint ItemState;lparam ItemParam;endstruct" & _
";dword ClrText;dword ClrTextBk;int Level"
Global Const $tagMENUITEMINFO = "uint Size;uint Mask;uint Type;uint State;uint ID;handle SubMenu;handle BmpChecked;handle BmpUnchecked;" & _
"ulong_ptr ItemData;ptr TypeData;uint CCH;handle BmpItem"
Global Const $tagREBARBANDINFO = "uint cbSize;uint fMask;uint fStyle;dword clrFore;dword clrBack;ptr lpText;uint cch;" & _
"int iImage;hwnd hwndChild;uint cxMinChild;uint cyMinChild;uint cx;handle hbmBack;uint wID;uint cyChild;uint cyMaxChild;" & _
"uint cyIntegral;uint cxIdeal;lparam lParam;uint cxHeader;" & $tagRECT & ";uint uChevronState"
Global Const $tagNMRBAUTOSIZE = $tagNMHDR & ";bool fChanged;" & _
"struct;long TargetLeft;long TargetTop;long TargetRight;long TargetBottom;endstruct;" & _
"struct;long ActualLeft;long ActualTop;long ActualRight;long ActualBottom;endstruct"
Global Const $tagNMREBARCHILDSIZE = $tagNMHDR & ";uint uBand;uint wID;" & _
"struct;long CLeft;long CTop;long CRight;long CBottom;endstruct;" & _
"struct;long BLeft;long BTop;long BRight;long BBottom;endstruct"
Global Const $tagNMTOOLBAR = $tagNMHDR & ";int iItem;" & _
"struct;int iBitmap;int idCommand;byte fsState;byte fsStyle;dword_ptr dwData;int_ptr iString;endstruct" & _
";int cchText;ptr pszText;" & $tagRECT
Global Const $tagOPENFILENAME = "dword StructSize;hwnd hwndOwner;handle hInstance;ptr lpstrFilter;ptr lpstrCustomFilter;" & _
"dword nMaxCustFilter;dword nFilterIndex;ptr lpstrFile;dword nMaxFile;ptr lpstrFileTitle;dword nMaxFileTitle;" & _
"ptr lpstrInitialDir;ptr lpstrTitle;dword Flags;word nFileOffset;word nFileExtension;ptr lpstrDefExt;lparam lCustData;" & _
"ptr lpfnHook;ptr lpTemplateName;ptr pvReserved;dword dwReserved;dword FlagsEx"
Global Const $tagBITMAPINFO = "struct;dword Size;long Width;long Height;word Planes;word BitCount;dword Compression;dword SizeImage;" & _
"long XPelsPerMeter;long YPelsPerMeter;dword ClrUsed;dword ClrImportant;endstruct;dword RGBQuad"
Global Const $tagSCROLLBARINFO = "dword cbSize;" & $tagRECT & ";int dxyLineButton;int xyThumbTop;" & _
"int xyThumbBottom;int reserved;dword rgstate[6]"
Global Const $tagLOGFONT = "long Height;long Width;long Escapement;long Orientation;long Weight;byte Italic;byte Underline;" & _
"byte Strikeout;byte CharSet;byte OutPrecision;byte ClipPrecision;byte Quality;byte PitchAndFamily;wchar FaceName[32]"
Global Const $tagSTARTUPINFO = "dword Size;ptr Reserved1;ptr Desktop;ptr Title;dword X;dword Y;dword XSize;dword YSize;dword XCountChars;" & _
"dword YCountChars;dword FillAttribute;dword Flags;word ShowWindow;word Reserved2;ptr Reserved3;handle StdInput;" & _
"handle StdOutput;handle StdError"
Global Const $tagTEXTMETRIC = "long tmHeight;long tmAscent;long tmDescent;long tmInternalLeading;long tmExternalLeading;" & _
"long tmAveCharWidth;long tmMaxCharWidth;long tmWeight;long tmOverhang;long tmDigitizedAspectX;long tmDigitizedAspectY;" & _
"wchar tmFirstChar;wchar tmLastChar;wchar tmDefaultChar;wchar tmBreakChar;byte tmItalic;byte tmUnderlined;byte tmStruckOut;" & _
"byte tmPitchAndFamily;byte tmCharSet"
Global $__gaInProcess_WinAPI[64][2] = [[0, 0]]
Global Const $HGDI_ERROR = Ptr(-1)
Global Const $INVALID_HANDLE_VALUE = Ptr(-1)
Global Const $DEFAULT_GUI_FONT = 17
Global Const $KF_EXTENDED = 0x0100
Global Const $KF_ALTDOWN = 0x2000
Global Const $KF_UP = 0x8000
Global Const $LLKHF_EXTENDED = BitShift($KF_EXTENDED, 8)
Global Const $LLKHF_ALTDOWN = BitShift($KF_ALTDOWN, 8)
Global Const $LLKHF_UP = BitShift($KF_UP, 8)
Global Const $tagMEMORYSTATUSEX = "dword Length;dword MemoryLoad;" & _
"uint64 TotalPhys;uint64 AvailPhys;uint64 TotalPageFile;uint64 AvailPageFile;" & _
"uint64 TotalVirtual;uint64 AvailVirtual;uint64 AvailExtendedVirtual"
Func _WinAPI_CreateWindowEx($iExStyle, $sClass, $sName, $iStyle, $iX, $iY, $iWidth, $iHeight, $hParent, $hMenu = 0, $hInstance = 0, $pParam = 0)
If $hInstance = 0 Then $hInstance = _WinAPI_GetModuleHandle("")
Local $aResult = DllCall("user32.dll", "hwnd", "CreateWindowExW", "dword", $iExStyle, "wstr", $sClass, "wstr", $sName, "dword", $iStyle, "int", $iX, _
"int", $iY, "int", $iWidth, "int", $iHeight, "hwnd", $hParent, "handle", $hMenu, "handle", $hInstance, "ptr", $pParam)
If @error Then Return SetError(@error, @extended, 0)
Return $aResult[0]
EndFunc
Func _WinAPI_DeleteObject($hObject)
Local $aResult = DllCall("gdi32.dll", "bool", "DeleteObject", "handle", $hObject)
If @error Then Return SetError(@error, @extended, False)
Return $aResult[0]
EndFunc
Func _WinAPI_DestroyWindow($hWnd)
Local $aResult = DllCall("user32.dll", "bool", "DestroyWindow", "hwnd", $hWnd)
If @error Then Return SetError(@error, @extended, False)
Return $aResult[0]
EndFunc
Func _WinAPI_GetClassName($hWnd)
If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)
Local $aResult = DllCall("user32.dll", "int", "GetClassNameW", "hwnd", $hWnd, "wstr", "", "int", 4096)
If @error Then Return SetError(@error, @extended, False)
Return SetExtended($aResult[0], $aResult[2])
EndFunc
Func _WinAPI_GetDlgCtrlID($hWnd)
Local $aResult = DllCall("user32.dll", "int", "GetDlgCtrlID", "hwnd", $hWnd)
If @error Then Return SetError(@error, @extended, 0)
Return $aResult[0]
EndFunc
Func _WinAPI_GetModuleHandle($sModuleName)
Local $sModuleNameType = "wstr"
If $sModuleName = "" Then
$sModuleName = 0
$sModuleNameType = "ptr"
EndIf
Local $aResult = DllCall("kernel32.dll", "handle", "GetModuleHandleW", $sModuleNameType, $sModuleName)
If @error Then Return SetError(@error, @extended, 0)
Return $aResult[0]
EndFunc
Func _WinAPI_GetParent($hWnd)
Local $aResult = DllCall("user32.dll", "hwnd", "GetParent", "hwnd", $hWnd)
If @error Then Return SetError(@error, @extended, 0)
Return $aResult[0]
EndFunc
Func _WinAPI_GetStockObject($iObject)
Local $aResult = DllCall("gdi32.dll", "handle", "GetStockObject", "int", $iObject)
If @error Then Return SetError(@error, @extended, 0)
Return $aResult[0]
EndFunc
Func _WinAPI_GetWindowThreadProcessId($hWnd, ByRef $iPID)
Local $aResult = DllCall("user32.dll", "dword", "GetWindowThreadProcessId", "hwnd", $hWnd, "dword*", 0)
If @error Then Return SetError(@error, @extended, 0)
$iPID = $aResult[2]
Return $aResult[0]
EndFunc
Func _WinAPI_InProcess($hWnd, ByRef $hLastWnd)
If $hWnd = $hLastWnd Then Return True
For $iI = $__gaInProcess_WinAPI[0][0] To 1 Step -1
If $hWnd = $__gaInProcess_WinAPI[$iI][0] Then
If $__gaInProcess_WinAPI[$iI][1] Then
$hLastWnd = $hWnd
Return True
Else
Return False
EndIf
EndIf
Next
Local $iProcessID
_WinAPI_GetWindowThreadProcessId($hWnd, $iProcessID)
Local $iCount = $__gaInProcess_WinAPI[0][0] + 1
If $iCount >= 64 Then $iCount = 1
$__gaInProcess_WinAPI[0][0] = $iCount
$__gaInProcess_WinAPI[$iCount][0] = $hWnd
$__gaInProcess_WinAPI[$iCount][1] =($iProcessID = @AutoItPID)
Return $__gaInProcess_WinAPI[$iCount][1]
EndFunc
Func _WinAPI_IsClassName($hWnd, $sClassName)
Local $sSeparator = Opt("GUIDataSeparatorChar")
Local $aClassName = StringSplit($sClassName, $sSeparator)
If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)
Local $sClassCheck = _WinAPI_GetClassName($hWnd)
For $x = 1 To UBound($aClassName) - 1
If StringUpper(StringMid($sClassCheck, 1, StringLen($aClassName[$x]))) = StringUpper($aClassName[$x]) Then Return True
Next
Return False
EndFunc
Func _WinAPI_RedrawWindow($hWnd, $tRect = 0, $hRegion = 0, $iFlags = 5)
Local $aResult = DllCall("user32.dll", "bool", "RedrawWindow", "hwnd", $hWnd, "struct*", $tRect, "handle", $hRegion, "uint", $iFlags)
If @error Then Return SetError(@error, @extended, False)
Return $aResult[0]
EndFunc
Func _WinAPI_SetFocus($hWnd)
Local $aResult = DllCall("user32.dll", "hwnd", "SetFocus", "hwnd", $hWnd)
If @error Then Return SetError(@error, @extended, 0)
Return $aResult[0]
EndFunc
Global Const $_UDF_GlobalIDs_OFFSET = 2
Global Const $_UDF_GlobalID_MAX_WIN = 16
Global Const $_UDF_STARTID = 10000
Global Const $_UDF_GlobalID_MAX_IDS = 55535
Global $_UDF_GlobalIDs_Used[$_UDF_GlobalID_MAX_WIN][$_UDF_GlobalID_MAX_IDS + $_UDF_GlobalIDs_OFFSET + 1]
Func __UDF_GetNextGlobalID($hWnd)
Local $nCtrlID, $iUsedIndex = -1, $fAllUsed = True
If Not WinExists($hWnd) Then Return SetError(-1, -1, 0)
For $iIndex = 0 To $_UDF_GlobalID_MAX_WIN - 1
If $_UDF_GlobalIDs_Used[$iIndex][0] <> 0 Then
If Not WinExists($_UDF_GlobalIDs_Used[$iIndex][0]) Then
For $x = 0 To UBound($_UDF_GlobalIDs_Used, 2) - 1
$_UDF_GlobalIDs_Used[$iIndex][$x] = 0
Next
$_UDF_GlobalIDs_Used[$iIndex][1] = $_UDF_STARTID
$fAllUsed = False
EndIf
EndIf
Next
For $iIndex = 0 To $_UDF_GlobalID_MAX_WIN - 1
If $_UDF_GlobalIDs_Used[$iIndex][0] = $hWnd Then
$iUsedIndex = $iIndex
ExitLoop
EndIf
Next
If $iUsedIndex = -1 Then
For $iIndex = 0 To $_UDF_GlobalID_MAX_WIN - 1
If $_UDF_GlobalIDs_Used[$iIndex][0] = 0 Then
$_UDF_GlobalIDs_Used[$iIndex][0] = $hWnd
$_UDF_GlobalIDs_Used[$iIndex][1] = $_UDF_STARTID
$fAllUsed = False
$iUsedIndex = $iIndex
ExitLoop
EndIf
Next
EndIf
If $iUsedIndex = -1 And $fAllUsed Then Return SetError(16, 0, 0)
If $_UDF_GlobalIDs_Used[$iUsedIndex][1] = $_UDF_STARTID + $_UDF_GlobalID_MAX_IDS Then
For $iIDIndex = $_UDF_GlobalIDs_OFFSET To UBound($_UDF_GlobalIDs_Used, 2) - 1
If $_UDF_GlobalIDs_Used[$iUsedIndex][$iIDIndex] = 0 Then
$nCtrlID =($iIDIndex - $_UDF_GlobalIDs_OFFSET) + 10000
$_UDF_GlobalIDs_Used[$iUsedIndex][$iIDIndex] = $nCtrlID
Return $nCtrlID
EndIf
Next
Return SetError(-1, $_UDF_GlobalID_MAX_IDS, 0)
EndIf
$nCtrlID = $_UDF_GlobalIDs_Used[$iUsedIndex][1]
$_UDF_GlobalIDs_Used[$iUsedIndex][1] += 1
$_UDF_GlobalIDs_Used[$iUsedIndex][($nCtrlID - 10000) + $_UDF_GlobalIDs_OFFSET] = $nCtrlID
Return $nCtrlID
EndFunc
Func __UDF_FreeGlobalID($hWnd, $iGlobalID)
If $iGlobalID - $_UDF_STARTID < 0 Or $iGlobalID - $_UDF_STARTID > $_UDF_GlobalID_MAX_IDS Then Return SetError(-1, 0, False)
For $iIndex = 0 To $_UDF_GlobalID_MAX_WIN - 1
If $_UDF_GlobalIDs_Used[$iIndex][0] = $hWnd Then
For $x = $_UDF_GlobalIDs_OFFSET To UBound($_UDF_GlobalIDs_Used, 2) - 1
If $_UDF_GlobalIDs_Used[$iIndex][$x] = $iGlobalID Then
$_UDF_GlobalIDs_Used[$iIndex][$x] = 0
Return True
EndIf
Next
Return SetError(-3, 0, False)
EndIf
Next
Return SetError(-2, 0, False)
EndFunc
Func __UDF_DebugPrint($sText, $iLine = @ScriptLineNumber, $err = @error, $ext = @extended)
ConsoleWrite( _
"!===========================================================" & @CRLF & _
"+======================================================" & @CRLF & _
"-->Line(" & StringFormat("%04d", $iLine) & "):" & @TAB & $sText & @CRLF & _
"+======================================================" & @CRLF)
Return SetError($err, $ext, 1)
EndFunc
Func __UDF_ValidateClassName($hWnd, $sClassNames)
__UDF_DebugPrint("This is for debugging only, set the debug variable to false before submitting")
If _WinAPI_IsClassName($hWnd, $sClassNames) Then Return True
Local $sSeparator = Opt("GUIDataSeparatorChar")
$sClassNames = StringReplace($sClassNames, $sSeparator, ",")
__UDF_DebugPrint("Invalid Class Type(s):" & @LF & @TAB & "Expecting Type(s): " & $sClassNames & @LF & @TAB & "Received Type : " & _WinAPI_GetClassName($hWnd))
Exit
EndFunc
Global $ghGDIPDll = 0
Global $giGDIPRef = 0
Global $giGDIPToken = 0
Func _GDIPlus_GraphicsCreateFromHWND($hWnd)
Local $aResult = DllCall($ghGDIPDll, "int", "GdipCreateFromHWND", "hwnd", $hWnd, "ptr*", 0)
If @error Then Return SetError(@error, @extended, 0)
Return SetExtended($aResult[0], $aResult[2])
EndFunc
Func _GDIPlus_GraphicsDispose($hGraphics)
Local $aResult = DllCall($ghGDIPDll, "int", "GdipDeleteGraphics", "handle", $hGraphics)
If @error Then Return SetError(@error, @extended, False)
Return $aResult[0] = 0
EndFunc
Func _GDIPlus_GraphicsDrawImage($hGraphics, $hImage, $iX, $iY)
Local $aResult = DllCall($ghGDIPDll, "int", "GdipDrawImageI", "handle", $hGraphics, "handle", $hImage, "int", $iX, "int", $iY)
If @error Then Return SetError(@error, @extended, False)
Return $aResult[0] = 0
EndFunc
Func _GDIPlus_ImageDispose($hImage)
Local $aResult = DllCall($ghGDIPDll, "int", "GdipDisposeImage", "handle", $hImage)
If @error Then Return SetError(@error, @extended, False)
Return $aResult[0] = 0
EndFunc
Func _GDIPlus_ImageLoadFromFile($sFileName)
Local $aResult = DllCall($ghGDIPDll, "int", "GdipLoadImageFromFile", "wstr", $sFileName, "ptr*", 0)
If @error Then Return SetError(@error, @extended, -1)
Return SetExtended($aResult[0], $aResult[2])
EndFunc
Func _GDIPlus_Shutdown()
If $ghGDIPDll = 0 Then Return SetError(-1, -1, False)
$giGDIPRef -= 1
If $giGDIPRef = 0 Then
DllCall($ghGDIPDll, "none", "GdiplusShutdown", "ptr", $giGDIPToken)
DllClose($ghGDIPDll)
$ghGDIPDll = 0
EndIf
Return True
EndFunc
Func _GDIPlus_Startup()
$giGDIPRef += 1
If $giGDIPRef > 1 Then Return True
$ghGDIPDll = DllOpen("GDIPlus.dll")
If $ghGDIPDll = -1 Then
$giGDIPRef = 0
Return SetError(1, 2, False)
EndIf
Local $tInput = DllStructCreate($tagGDIPSTARTUPINPUT)
Local $tToken = DllStructCreate("ulong_ptr Data")
DllStructSetData($tInput, "Version", 1)
Local $aResult = DllCall($ghGDIPDll, "int", "GdiplusStartup", "struct*", $tToken, "struct*", $tInput, "ptr", 0)
If @error Then Return SetError(@error, @extended, False)
$giGDIPToken = DllStructGetData($tToken, "Data")
Return $aResult[0] = 0
EndFunc
#region Header
#endregion Header
#region Global Variables and Constants
#endregion Global Variables and Constants
#region Core functions
#endregion Core functions
#region Frame Functions
#endregion Frame Functions
#region Link functions
#endregion Link functions
#region Image functions
#endregion Image functions
#region Form functions
#endregion Form functions
#region Table functions
#endregion Table functions
#region Read/Write functions
#endregion Read/Write functions
#region Utility functions
#endregion Utility functions
#region General
#endregion General
#region Internal functions
#endregion Internal functions
#region ProtoType Functions
#endregion ProtoType Functions
Func _ClipBoard_RegisterFormat($sFormat)
Local $aResult = DllCall("user32.dll", "uint", "RegisterClipboardFormatW", "wstr", $sFormat)
If @error Then Return SetError(@error, @extended, 0)
Return $aResult[0]
EndFunc
Global Const $__RICHEDITCONSTANT_WM_USER = 0x400
Global Const $EM_AUTOURLDETECT = $__RICHEDITCONSTANT_WM_USER + 91
Global Const $EM_EXGETSEL = $__RICHEDITCONSTANT_WM_USER + 52
Global Const $EM_GETTEXTLENGTHEX = $__RICHEDITCONSTANT_WM_USER + 95
Global Const $EM_HIDESELECTION = $__RICHEDITCONSTANT_WM_USER + 63
Global Const $EM_SETCHARFORMAT = $__RICHEDITCONSTANT_WM_USER + 68
Global Const $EM_SETOLECALLBACK = $__RICHEDITCONSTANT_WM_USER + 70
Global Const $EM_SETTEXTEX = $__RICHEDITCONSTANT_WM_USER + 97
Global Const $ST_DEFAULT = 0
Global Const $ST_SELECTION = 2
Global Const $GTL_CLOSE = 4
Global Const $GTL_DEFAULT = 0
Global Const $GTL_NUMBYTES = 16
Global Const $GTL_PRECISE = 2
Global Const $GTL_USECRLF = 1
Global Const $CP_ACP = 0
Global Const $CP_UNICODE = 1200
Global Const $CFE_SUBSCRIPT = 0x00010000
Global Const $CFE_SUPERSCRIPT = 0x00020000
Global Const $CFM_COLOR = 0x40000000
Global Const $CFE_AUTOCOLOR = $CFM_COLOR
Global Const $SCF_SELECTION = 0x1
Global Const $SCF_ALL = 0x4
Global Const $PFM_RTLPARA = 0x10000
Global Const $PFM_KEEP = 0x20000
Global Const $PFM_KEEPNEXT = 0x40000
Global Const $PFM_PAGEBREAKBEFORE = 0x80000
Global Const $PFM_NOLINENUMBER = 0x100000
Global Const $PFM_NOWIDOWCONTROL = 0x200000
Global Const $PFM_DONOTHYPHEN = 0x400000
Global Const $PFM_SIDEBYSIDE = 0x800000
Global Const $PFE_RTLPARA = BitShift($PFM_RTLPARA, 16)
Global Const $PFE_KEEP = BitShift($PFM_KEEP, 16)
Global Const $PFE_KEEPNEXT = BitShift($PFM_KEEPNEXT, 16)
Global Const $PFE_PAGEBREAKBEFORE = BitShift($PFM_PAGEBREAKBEFORE, 16)
Global Const $PFE_NOLINENUMBER = BitShift($PFM_NOLINENUMBER, 16)
Global Const $PFE_NOWIDOWCONTROL = BitShift($PFM_NOWIDOWCONTROL, 16)
Global Const $PFE_DONOTHYPHEN = BitShift($PFM_DONOTHYPHEN, 16)
Global Const $PFE_SIDEBYSIDE = BitShift($PFM_SIDEBYSIDE, 16)
Global Const $tagCHOOSECOLOR = "dword Size;hwnd hWndOwnder;handle hInstance;dword rgbResult;ptr CustColors;dword Flags;lparam lCustData;" & _
"ptr lpfnHook;ptr lpTemplateName"
Global Const $tagCHOOSEFONT = "dword Size;hwnd hWndOwner;handle hDC;ptr LogFont;int PointSize;dword Flags;dword rgbColors;lparam CustData;" & _
"ptr fnHook;ptr TemplateName;handle hInstance;ptr szStyle;word FontType;int SizeMin;int SizeMax"
Func _Iif($fTest, $vTrueVal, $vFalseVal)
If $fTest Then
Return $vTrueVal
Else
Return $vFalseVal
EndIf
EndFunc
Func _IsPressed($sHexKey, $vDLL = 'user32.dll')
Local $a_R = DllCall($vDLL, "short", "GetAsyncKeyState", "int", '0x' & $sHexKey)
If @error Then Return SetError(@error, @extended, False)
Return BitAND($a_R[0], 0x8000) <> 0
EndFunc
Global $Debug_RE = False
Global $_GRE_sRTFClassName, $h_GUICtrlRTF_lib, $_GRE_Version, $_GRE_TwipsPeSpaceUnit = 1440
Global $_GRE_hUser32dll, $_GRE_CF_RTF, $_GRE_CF_RETEXTOBJ
Global $_GRC_StreamFromFileCallback = DllCallbackRegister("__GCR_StreamFromFileCallback", "dword", "long_ptr;ptr;long;ptr")
Global $_GRC_StreamFromVarCallback = DllCallbackRegister("__GCR_StreamFromVarCallback", "dword", "long_ptr;ptr;long;ptr")
Global $_GRC_StreamToFileCallback = DllCallbackRegister("__GCR_StreamToFileCallback", "dword", "long_ptr;ptr;long;ptr")
Global $_GRC_StreamToVarCallback = DllCallbackRegister("__GCR_StreamToVarCallback", "dword", "long_ptr;ptr;long;ptr")
Global $_GRC_sStreamVar
Global $gh_RELastWnd
Global $pObj_RichComObject = DllStructCreate("ptr pIntf; dword  Refcount")
Global $pCall_RichCom, $pObj_RichCom
Global $hLib_RichCom_OLE32 = DllOpen("OLE32.DLL")
Global $__RichCom_Object_QueryInterface = DllCallbackRegister("__RichCom_Object_QueryInterface", "long", "ptr;dword;dword")
Global $__RichCom_Object_AddRef = DllCallbackRegister("__RichCom_Object_AddRef", "long", "ptr")
Global $__RichCom_Object_Release = DllCallbackRegister("__RichCom_Object_Release", "long", "ptr")
Global $__RichCom_Object_GetNewStorage = DllCallbackRegister("__RichCom_Object_GetNewStorage", "long", "ptr;ptr")
Global $__RichCom_Object_GetInPlaceContext = DllCallbackRegister("__RichCom_Object_GetInPlaceContext", "long", "ptr;dword;dword;dword")
Global $__RichCom_Object_ShowContainerUI = DllCallbackRegister("__RichCom_Object_ShowContainerUI", "long", "ptr;long")
Global $__RichCom_Object_QueryInsertObject = DllCallbackRegister("__RichCom_Object_QueryInsertObject", "long", "ptr;dword;ptr;long")
Global $__RichCom_Object_DeleteObject = DllCallbackRegister("__RichCom_Object_DeleteObject", "long", "ptr;ptr")
Global $__RichCom_Object_QueryAcceptData = DllCallbackRegister("__RichCom_Object_QueryAcceptData", "long", "ptr;ptr;dword;dword;dword;ptr")
Global $__RichCom_Object_ContextSensitiveHelp = DllCallbackRegister("__RichCom_Object_ContextSensitiveHelp", "long", "ptr;long")
Global $__RichCom_Object_GetClipboardData = DllCallbackRegister("__RichCom_Object_GetClipboardData", "long", "ptr;ptr;dword;ptr")
Global $__RichCom_Object_GetDragDropEffect = DllCallbackRegister("__RichCom_Object_GetDragDropEffect", "long", "ptr;dword;dword;dword")
Global $__RichCom_Object_GetContextMenu = DllCallbackRegister("__RichCom_Object_GetContextMenu", "long", "ptr;short;ptr;ptr;ptr")
Global Const $__RICHEDITCONSTANT_WS_VISIBLE = 0x10000000
Global Const $__RICHEDITCONSTANT_WS_CHILD = 0x40000000
Global Const $__RICHEDITCONSTANT_WS_TABSTOP = 0x00010000
Global Const $__RICHEDITCONSTANT_WM_SETFONT = 0x0030
Global Const $_GCR_S_OK = 0
Global Const $_GCR_E_NOTIMPL = 0x80004001
Global Const $tagCHARFORMAT = "struct;uint cbSize;dword dwMask;dword dwEffects;long yHeight;long yOffset;dword crCharColor;" & _
"byte bCharSet;byte bPitchAndFamily;wchar szFaceName[32];endstruct"
Global Const $tagCHARFORMAT2 = $tagCHARFORMAT & ";word wWeight;short sSpacing;dword crBackColor;dword lcid;dword dwReserved;" & _
"short sStyle;word wKerning;byte bUnderlineType;byte bAnimation;byte bRevAuthor;byte bReserved1"
Global Const $tagCHARRANGE = "struct;long cpMin;long cpMax;endstruct"
Global Const $tagGETTEXTLENGTHEX = "dword flags;uint codepage"
Global Const $tagPARAFORMAT = "uint cbSize;dword dwMask;word wNumbering;word wEffects;long dxStartIndent;" _
& "long dxRightIndent;long dxOffset;word wAlignment;short cTabCount;long rgxTabs[32]"
Global Const $tagPARAFORMAT2 = $tagPARAFORMAT _
& ";long dySpaceBefore;long dySpaceAfter;long dyLineSpacing;short sStyle;byte bLineSpacingRule;" _
& "byte bOutlineLevel;word wShadingWeight;word wShadingStyle;word wNumberingStart;word wNumberingStyle;" _
& "word wNumberingTab;word wBorderSpace;word wBorderWidth;word wBorders"
Global Const $tagSETTEXTEX = "dword flags;uint codepage"
Func _GUICtrlRichEdit_AppendText($hWnd, $sText)
If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, False)
Local $iLength = _GUICtrlRichEdit_GetTextLength($hWnd)
_GUICtrlRichEdit_SetSel($hWnd, $iLength, $iLength)
Local $tSetText = DllStructCreate($tagSETTEXTEX)
DllStructSetData($tSetText, 1, $ST_SELECTION)
Local $iRet
If StringLeft($sText, 5) <> "{\rtf" And StringLeft($sText, 5) <> "{urtf" Then
DllStructSetData($tSetText, 2, $CP_UNICODE)
$iRet = _SendMessage($hWnd, $EM_SETTEXTEX, $tSetText, $sText, 0, "struct*", "wstr")
Else
DllStructSetData($tSetText, 2, $CP_ACP)
$iRet = _SendMessage($hWnd, $EM_SETTEXTEX, $tSetText, $sText, 0, "struct*", "STR")
EndIf
If Not $iRet Then Return SetError(700, 0, False)
Return True
EndFunc
Func _GUICtrlRichEdit_AutoDetectURL($hWnd, $fState)
If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, False)
If Not IsBool($fState) Then Return SetError(102, 0, False)
If _SendMessage($hWnd, $EM_AUTOURLDETECT, $fState) Then Return SetError(700, 0, False)
Return True
EndFunc
Func _GUICtrlRichEdit_Create($hWnd, $sText, $iLeft, $iTop, $iWidth = 150, $iHeight = 150, $iStyle = -1, $iExStyle = -1)
If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(1, 0, 0)
If Not IsString($sText) Then Return SetError(2, 0, 0)
If Not __GCR_IsNumeric($iLeft, ">=0") Then Return SetError(103, 0, 0)
If Not __GCR_IsNumeric($iTop, ">=0") Then Return SetError(104, 0, 0)
If Not __GCR_IsNumeric($iWidth, ">0,-1") Then Return SetError(105, 0, 0)
If Not __GCR_IsNumeric($iHeight, ">0,-1") Then Return SetError(106, 0, 0)
If Not __GCR_IsNumeric($iStyle, ">=0,-1") Then Return SetError(107, 0, 0)
If Not __GCR_IsNumeric($iExStyle, ">=0,-1") Then Return SetError(108, 0, 0)
If $iWidth = -1 Then $iWidth = 150
If $iHeight = -1 Then $iHeight = 150
If $iStyle = -1 Then $iStyle = BitOR($ES_WANTRETURN, $ES_MULTILINE)
If BitAND($iStyle, $ES_MULTILINE) <> 0 Then $iStyle = BitOR($iStyle, $ES_WANTRETURN)
If $iExStyle = -1 Then $iExStyle = 0x200
$iStyle = BitOR($iStyle, $__RICHEDITCONSTANT_WS_CHILD, $__RICHEDITCONSTANT_WS_VISIBLE)
If BitAND($iStyle, $ES_READONLY) = 0 Then $iStyle = BitOR($iStyle, $__RICHEDITCONSTANT_WS_TABSTOP)
Local $nCtrlID = __UDF_GetNextGlobalID($hWnd)
If @error Then Return SetError(@error, @extended, 0)
__GCR_Init()
Local $hRichEdit = _WinAPI_CreateWindowEx($iExStyle, $_GRE_sRTFClassName, "", $iStyle, $iLeft, $iTop, $iWidth, _
$iHeight, $hWnd, $nCtrlID)
If $hRichEdit = 0 Then Return SetError(700, 0, False)
__GCR_SetOLECallback($hRichEdit)
_SendMessage($hRichEdit, $__RICHEDITCONSTANT_WM_SETFONT, _WinAPI_GetStockObject($DEFAULT_GUI_FONT), True)
_GUICtrlRichEdit_AppendText($hRichEdit, $sText)
Return $hRichEdit
EndFunc
Func _GUICtrlRichEdit_Deselect($hWnd)
If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, False)
_SendMessage($hWnd, $EM_SETSEL, -1, 0)
Return True
EndFunc
Func _GUICtrlRichEdit_Destroy(ByRef $hWnd)
If $Debug_RE Then __UDF_ValidateClassName($hWnd, $_GRE_sRTFClassName)
If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(2, 2, False)
Local $Destroyed = 0
If IsHWnd($hWnd) Then
If _WinAPI_InProcess($hWnd, $gh_RELastWnd) Then
Local $nCtrlID = _WinAPI_GetDlgCtrlID($hWnd)
Local $hParent = _WinAPI_GetParent($hWnd)
$Destroyed = _WinAPI_DestroyWindow($hWnd)
Local $iRet = __UDF_FreeGlobalID($hParent, $nCtrlID)
If Not $iRet Then
EndIf
Else
Return SetError(1, 1, False)
EndIf
Else
$Destroyed = GUICtrlDelete($hWnd)
EndIf
If $Destroyed Then $hWnd = 0
Return $Destroyed <> 0
EndFunc
Func _GUICtrlRichEdit_GetTextLength($hWnd, $fExact = True, $fChars = False)
If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, 0)
If Not IsBool($fExact) Then Return SetError(102, 0, 0)
If Not IsBool($fChars) Then Return SetError(103, 0, 0)
Local $tGetTextLen = DllStructCreate($tagGETTEXTLENGTHEX)
Local $iFlags = BitOR($GTL_USECRLF, _Iif($fExact, $GTL_PRECISE, $GTL_CLOSE))
$iFlags = BitOR($iFlags, _Iif($fChars, $GTL_DEFAULT, $GTL_NUMBYTES))
DllStructSetData($tGetTextLen, 1, $iFlags)
DllStructSetData($tGetTextLen, 2, _Iif($fChars, $CP_ACP, $CP_UNICODE))
Local $iRet = _SendMessage($hWnd, $EM_GETTEXTLENGTHEX, $tGetTextLen, 0, 0, "struct*")
Return $iRet
EndFunc
Func _GUICtrlRichEdit_GetSel($hWnd)
If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, 0)
Local $tCharRange = DllStructCreate($tagCHARRANGE)
_SendMessage($hWnd, $EM_EXGETSEL, 0, $tCharRange, 0, "wparam", "struct*")
Local $aRet[2]
$aRet[0] = DllStructGetData($tCharRange, 1)
$aRet[1] = DllStructGetData($tCharRange, 2)
Return $aRet
EndFunc
Func _GUICtrlRichEdit_GotoCharPos($hWnd, $iCharPos)
_GUICtrlRichEdit_SetSel($hWnd, $iCharPos, $iCharPos)
If @error Then Return SetError(@error, 0, False)
Return True
EndFunc
Func _GUICtrlRichEdit_InsertText($hWnd, $sText)
If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, False)
If $sText = "" Then Return SetError(102, 0, False)
Local $tSetText = DllStructCreate($tagSETTEXTEX)
DllStructSetData($tSetText, 1, $ST_SELECTION)
_GUICtrlRichEdit_Deselect($hWnd)
Local $iRet
If StringLeft($sText, 5) <> "{\rtf" And StringLeft($sText, 5) <> "{urtf" Then
DllStructSetData($tSetText, 2, $CP_UNICODE)
$iRet = _SendMessage($hWnd, $EM_SETTEXTEX, $tSetText, $sText, 0, "struct*", "wstr")
Else
DllStructSetData($tSetText, 2, $CP_ACP)
$iRet = _SendMessage($hWnd, $EM_SETTEXTEX, $tSetText, $sText, 0, "struct*", "STR")
EndIf
If Not $iRet Then Return SetError(103, 0, False)
Return True
EndFunc
Func _GUICtrlRichEdit_SetCharColor($hWnd, $iColor = Default)
If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, False)
Local $tCharFormat = DllStructCreate($tagCHARFORMAT)
DllStructSetData($tCharFormat, 1, DllStructGetSize($tCharFormat))
If IsKeyword($iColor) Then
DllStructSetData($tCharFormat, 3, $CFE_AUTOCOLOR)
$iColor = 0
Else
If BitAND($iColor, 0xff000000) Then Return SetError(1022, 0, False)
EndIf
DllStructSetData($tCharFormat, 2, $CFM_COLOR)
DllStructSetData($tCharFormat, 6, $iColor)
Local $ai = _GUICtrlRichEdit_GetSel($hWnd)
If $ai[0] = $ai[1] Then
Return _SendMessage($hWnd, $EM_SETCHARFORMAT, $SCF_ALL, $tCharFormat, 0, "wparam", "struct*") <> 0
Else
Return _SendMessage($hWnd, $EM_SETCHARFORMAT, $SCF_SELECTION, $tCharFormat, 0, "wparam", "struct*") <> 0
EndIf
EndFunc
Func _GUICtrlRichEdit_SetSel($hWnd, $iAnchor, $iActive, $fHideSel = False)
If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, False)
If Not __GCR_IsNumeric($iAnchor, ">=0,-1") Then Return SetError(102, 0, False)
If Not __GCR_IsNumeric($iActive, ">=0,-1") Then Return SetError(103, 0, False)
If Not IsBool($fHideSel) Then Return SetError(104, 0, False)
_SendMessage($hWnd, $EM_SETSEL, $iAnchor, $iActive)
If $fHideSel Then _SendMessage($hWnd, $EM_HIDESELECTION, $fHideSel)
_WinAPI_SetFocus($hWnd)
Return True
EndFunc
Func _GUICtrlRichEdit_SetText($hWnd, $sText)
If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, False)
Local $tSetText = DllStructCreate($tagSETTEXTEX)
DllStructSetData($tSetText, 1, $ST_DEFAULT)
DllStructSetData($tSetText, 2, $CP_ACP)
Local $iRet
If StringLeft($sText, 5) <> "{\rtf" And StringLeft($sText, 5) <> "{urtf" Then
DllStructSetData($tSetText, 2, $CP_UNICODE)
$iRet = _SendMessage($hWnd, $EM_SETTEXTEX, $tSetText, $sText, 0, "struct*", "wstr")
Else
$iRet = _SendMessage($hWnd, $EM_SETTEXTEX, $tSetText, $sText, 0, "struct*", "STR")
EndIf
If Not $iRet Then Return SetError(700, 0, False)
Return True
EndFunc
Func __GCR_Init()
$h_GUICtrlRTF_lib = DllCall("kernel32.dll", "ptr", "LoadLibraryW", "wstr", "MSFTEDIT.DLL")
If $h_GUICtrlRTF_lib[0] <> 0 Then
$_GRE_sRTFClassName = "RichEdit50W"
$_GRE_Version = 4.1
Else
$h_GUICtrlRTF_lib = DllCall("kernel32.dll", "ptr", "LoadLibraryW", "wstr", "RICHED20.DLL")
$_GRE_Version = FileGetVersion(@SystemDir & "\riched20.dll", "ProductVersion")
Switch $_GRE_Version
Case 3.0
$_GRE_sRTFClassName = "RichEdit20W"
Case 5.0
$_GRE_sRTFClassName = "RichEdit50W"
Case 6.0
$_GRE_sRTFClassName = "RichEdit60W"
EndSwitch
EndIf
$_GRE_CF_RTF = _ClipBoard_RegisterFormat("Rich Text Format")
$_GRE_CF_RETEXTOBJ = _ClipBoard_RegisterFormat("Rich Text Format with Objects")
EndFunc
Func __GCR_StreamFromFileCallback($hFile, $pBuf, $iBuflen, $ptrQbytes)
Local $tQbytes = DllStructCreate("long", $ptrQbytes)
DllStructSetData($tQbytes, 1, 0)
Local $tBuf = DllStructCreate("char[" & $iBuflen & "]", $pBuf)
Local $buf = FileRead($hFile, $iBuflen - 1)
If @error <> 0 Then Return 1
DllStructSetData($tBuf, 1, $buf)
DllStructSetData($tQbytes, 1, StringLen($buf))
Return 0
EndFunc
Func __GCR_StreamFromVarCallback($dwCookie, $pBuf, $iBuflen, $ptrQbytes)
#forceref $dwCookie
Local $tQbytes = DllStructCreate("long", $ptrQbytes)
DllStructSetData($tQbytes, 1, 0)
Local $tCtl = DllStructCreate("char[" & $iBuflen & "]", $pBuf)
Local $sCtl = StringLeft($_GRC_sStreamVar, $iBuflen - 1)
If $sCtl = "" Then Return 1
DllStructSetData($tCtl, 1, $sCtl)
Local $iLen = StringLen($sCtl)
DllStructSetData($tQbytes, 1, $iLen)
$_GRC_sStreamVar = StringMid($_GRC_sStreamVar, $iLen + 1)
Return 0
EndFunc
Func __GCR_StreamToFileCallback($hFile, $pBuf, $iBuflen, $ptrQbytes)
Local $tQbytes = DllStructCreate("long", $ptrQbytes)
DllStructSetData($tQbytes, 1, 0)
Local $tBuf = DllStructCreate("char[" & $iBuflen & "]", $pBuf)
Local $s = DllStructGetData($tBuf, 1)
FileWrite($hFile, $s)
DllStructSetData($tQbytes, 1, StringLen($s))
Return 0
EndFunc
Func __GCR_StreamToVarCallback($dwCookie, $pBuf, $iBuflen, $ptrQbytes)
$dwCookie = $dwCookie
Local $tQbytes = DllStructCreate("long", $ptrQbytes)
DllStructSetData($tQbytes, 1, 0)
Local $tBuf = DllStructCreate("char[" & $iBuflen & "]", $pBuf)
Local $s = DllStructGetData($tBuf, 1)
$_GRC_sStreamVar &= $s
Return 0
EndFunc
Func __GCR_IsNumeric($vN, $sRange = "")
If Not(IsNumber($vN) Or StringIsInt($vN) Or StringIsFloat($vN)) Then Return False
Switch $sRange
Case ">0"
If $vN <= 0 Then Return False
Case ">=0"
If $vN < 0 Then Return False
Case ">0,-1"
If Not($vN > 0 Or $vN = -1) Then Return False
Case ">=0,-1"
If Not($vN >= 0 Or $vN = -1) Then Return False
EndSwitch
Return True
EndFunc
Func __GCR_SetOLECallback($hWnd)
If Not IsHWnd($hWnd) Then Return SetError(101, 0, False)
If Not $pObj_RichCom Then
$pCall_RichCom = DllStructCreate("ptr[20]")
DllStructSetData($pCall_RichCom, 1, DllCallbackGetPtr($__RichCom_Object_QueryInterface), 1)
DllStructSetData($pCall_RichCom, 1, DllCallbackGetPtr($__RichCom_Object_AddRef), 2)
DllStructSetData($pCall_RichCom, 1, DllCallbackGetPtr($__RichCom_Object_Release), 3)
DllStructSetData($pCall_RichCom, 1, DllCallbackGetPtr($__RichCom_Object_GetNewStorage), 4)
DllStructSetData($pCall_RichCom, 1, DllCallbackGetPtr($__RichCom_Object_GetInPlaceContext), 5)
DllStructSetData($pCall_RichCom, 1, DllCallbackGetPtr($__RichCom_Object_ShowContainerUI), 6)
DllStructSetData($pCall_RichCom, 1, DllCallbackGetPtr($__RichCom_Object_QueryInsertObject), 7)
DllStructSetData($pCall_RichCom, 1, DllCallbackGetPtr($__RichCom_Object_DeleteObject), 8)
DllStructSetData($pCall_RichCom, 1, DllCallbackGetPtr($__RichCom_Object_QueryAcceptData), 9)
DllStructSetData($pCall_RichCom, 1, DllCallbackGetPtr($__RichCom_Object_ContextSensitiveHelp), 10)
DllStructSetData($pCall_RichCom, 1, DllCallbackGetPtr($__RichCom_Object_GetClipboardData), 11)
DllStructSetData($pCall_RichCom, 1, DllCallbackGetPtr($__RichCom_Object_GetDragDropEffect), 12)
DllStructSetData($pCall_RichCom, 1, DllCallbackGetPtr($__RichCom_Object_GetContextMenu), 13)
DllStructSetData($pObj_RichComObject, 1, DllStructGetPtr($pCall_RichCom))
DllStructSetData($pObj_RichComObject, 2, 1)
$pObj_RichCom = DllStructGetPtr($pObj_RichComObject)
EndIf
Local Const $EM_SETOLECALLBACK = 0x400 + 70
If _SendMessage($hWnd, $EM_SETOLECALLBACK, 0, $pObj_RichCom) = 0 Then Return SetError(700, 0, False)
Return True
EndFunc
Func __RichCom_Object_QueryInterface($pObject, $REFIID, $ppvObj)
#forceref $pObject, $REFIID, $ppvObj
Return $_GCR_S_OK
EndFunc
Func __RichCom_Object_AddRef($pObject)
Local $data = DllStructCreate("ptr;dword", $pObject)
DllStructSetData($data, 2, DllStructGetData($data, 2) + 1)
Return DllStructGetData($data, 2)
EndFunc
Func __RichCom_Object_Release($pObject)
Local $data = DllStructCreate("ptr;dword", $pObject)
If DllStructGetData($data, 2) > 0 Then
DllStructSetData($data, 2, DllStructGetData($data, 2) - 1)
Return DllStructGetData($data, 2)
EndIf
EndFunc
Func __RichCom_Object_GetInPlaceContext($pObject, $lplpFrame, $lplpDoc, $lpFrameInfo)
#forceref $pObject, $lplpFrame, $lplpDoc, $lpFrameInfo
Return $_GCR_E_NOTIMPL
EndFunc
Func __RichCom_Object_ShowContainerUI($pObject, $fShow)
#forceref $pObject, $fShow
Return $_GCR_E_NOTIMPL
EndFunc
Func __RichCom_Object_QueryInsertObject($pObject, $lpclsid, $lpstg, $cp)
#forceref $pObject, $lpclsid, $lpstg, $cp
Return $_GCR_S_OK
EndFunc
Func __RichCom_Object_DeleteObject($pObject, $lpoleobj)
#forceref $pObject, $lpoleobj
Return $_GCR_E_NOTIMPL
EndFunc
Func __RichCom_Object_QueryAcceptData($pObject, $lpdataobj, $lpcfFormat, $reco, $fReally, $hMetaPict)
#forceref $pObject, $lpdataobj, $lpcfFormat, $reco, $fReally, $hMetaPict
Return $_GCR_S_OK
EndFunc
Func __RichCom_Object_ContextSensitiveHelp($pObject, $fEnterMode)
#forceref $pObject, $fEnterMode
Return $_GCR_E_NOTIMPL
EndFunc
Func __RichCom_Object_GetClipboardData($pObject, $lpchrg, $reco, $lplpdataobj)
#forceref $pObject, $lpchrg, $reco, $lplpdataobj
Return $_GCR_E_NOTIMPL
EndFunc
Func __RichCom_Object_GetDragDropEffect($pObject, $fDrag, $grfKeyState, $pdwEffect)
#forceref $pObject, $fDrag, $grfKeyState, $pdwEffect
Return $_GCR_E_NOTIMPL
EndFunc
Func __RichCom_Object_GetContextMenu($pObject, $seltype, $lpoleobj, $lpchrg, $lphmenu)
#forceref $pObject, $seltype, $lpoleobj, $lpchrg, $lphmenu
Return $_GCR_E_NOTIMPL
EndFunc
Func __RichCom_Object_GetNewStorage($pObject, $lplpstg)
#forceref $pObject
Local $sc = DllCall($hLib_RichCom_OLE32, "dword", "CreateILockBytesOnHGlobal", "hwnd", 0, "int", 1, "ptr*", 0)
Local $lpLockBytes = $sc[3]
$sc = $sc[0]
If $sc Then Return $sc
$sc = DllCall($hLib_RichCom_OLE32, "dword", "StgCreateDocfileOnILockBytes", "ptr", $lpLockBytes, "dword", BitOR(0x10, 2, 0x1000), "dword", 0, "ptr*", 0)
Local $lpstg = DllStructCreate("ptr", $lplpstg)
DllStructSetData($lpstg, 1, $sc[4])
$sc = $sc[0]
If $sc Then
Local $obj = DllStructCreate("ptr", $lpLockBytes)
Local $iUnknownFuncTable = DllStructCreate("ptr[3]", DllStructGetData($obj, 1))
Local $lpReleaseFunc = DllStructGetData($iUnknownFuncTable, 3)
Call("MemoryFuncCall" & "", "long", $lpReleaseFunc, "ptr", $lpLockBytes)
If @error = 1 Then ConsoleWrite("!> Needs MemoryDLL.au3 for correct release of ILockBytes" & @CRLF)
EndIf
Return $sc
EndFunc
Func _StringBetween($s_String, $s_Start, $s_End, $v_Case = -1)
Local $s_case = ""
If $v_Case = Default Or $v_Case = -1 Then $s_case = "(?i)"
Local $s_pattern_escape = "(\.|\||\*|\?|\+|\(|\)|\{|\}|\[|\]|\^|\$|\\)"
$s_Start = StringRegExpReplace($s_Start, $s_pattern_escape, "\\$1")
$s_End = StringRegExpReplace($s_End, $s_pattern_escape, "\\$1")
If $s_Start = "" Then $s_Start = "\A"
If $s_End = "" Then $s_End = "\z"
Local $a_ret = StringRegExp($s_String, "(?s)" & $s_case & $s_Start & "(.*?)" & $s_End, 3)
If @error Then Return SetError(1, 0, 0)
Return $a_ret
EndFunc
Func _StringEncrypt($i_Encrypt, $s_EncryptText, $s_EncryptPassword, $i_EncryptLevel = 1)
If $i_Encrypt <> 0 And $i_Encrypt <> 1 Then
SetError(1, 0, '')
ElseIf $s_EncryptText = '' Or $s_EncryptPassword = '' Then
SetError(1, 0, '')
Else
If Number($i_EncryptLevel) <= 0 Or Int($i_EncryptLevel) <> $i_EncryptLevel Then $i_EncryptLevel = 1
Local $v_EncryptModified
Local $i_EncryptCountH
Local $i_EncryptCountG
Local $v_EncryptSwap
Local $av_EncryptBox[256][2]
Local $i_EncryptCountA
Local $i_EncryptCountB
Local $i_EncryptCountC
Local $i_EncryptCountD
Local $i_EncryptCountE
Local $v_EncryptCipher
Local $v_EncryptCipherBy
If $i_Encrypt = 1 Then
For $i_EncryptCountF = 0 To $i_EncryptLevel Step 1
$i_EncryptCountG = ''
$i_EncryptCountH = ''
$v_EncryptModified = ''
For $i_EncryptCountG = 1 To StringLen($s_EncryptText)
If $i_EncryptCountH = StringLen($s_EncryptPassword) Then
$i_EncryptCountH = 1
Else
$i_EncryptCountH += 1
EndIf
$v_EncryptModified = $v_EncryptModified & Chr(BitXOR(Asc(StringMid($s_EncryptText, $i_EncryptCountG, 1)), Asc(StringMid($s_EncryptPassword, $i_EncryptCountH, 1)), 255))
Next
$s_EncryptText = $v_EncryptModified
$i_EncryptCountA = ''
$i_EncryptCountB = 0
$i_EncryptCountC = ''
$i_EncryptCountD = ''
$i_EncryptCountE = ''
$v_EncryptCipherBy = ''
$v_EncryptCipher = ''
$v_EncryptSwap = ''
$av_EncryptBox = ''
Local $av_EncryptBox[256][2]
For $i_EncryptCountA = 0 To 255
$av_EncryptBox[$i_EncryptCountA][1] = Asc(StringMid($s_EncryptPassword, Mod($i_EncryptCountA, StringLen($s_EncryptPassword)) + 1, 1))
$av_EncryptBox[$i_EncryptCountA][0] = $i_EncryptCountA
Next
For $i_EncryptCountA = 0 To 255
$i_EncryptCountB = Mod(($i_EncryptCountB + $av_EncryptBox[$i_EncryptCountA][0] + $av_EncryptBox[$i_EncryptCountA][1]), 256)
$v_EncryptSwap = $av_EncryptBox[$i_EncryptCountA][0]
$av_EncryptBox[$i_EncryptCountA][0] = $av_EncryptBox[$i_EncryptCountB][0]
$av_EncryptBox[$i_EncryptCountB][0] = $v_EncryptSwap
Next
For $i_EncryptCountA = 1 To StringLen($s_EncryptText)
$i_EncryptCountC = Mod(($i_EncryptCountC + 1), 256)
$i_EncryptCountD = Mod(($i_EncryptCountD + $av_EncryptBox[$i_EncryptCountC][0]), 256)
$i_EncryptCountE = $av_EncryptBox[Mod(($av_EncryptBox[$i_EncryptCountC][0] + $av_EncryptBox[$i_EncryptCountD][0]), 256)][0]
$v_EncryptCipherBy = BitXOR(Asc(StringMid($s_EncryptText, $i_EncryptCountA, 1)), $i_EncryptCountE)
$v_EncryptCipher &= Hex($v_EncryptCipherBy, 2)
Next
$s_EncryptText = $v_EncryptCipher
Next
Else
For $i_EncryptCountF = 0 To $i_EncryptLevel Step 1
$i_EncryptCountB = 0
$i_EncryptCountC = ''
$i_EncryptCountD = ''
$i_EncryptCountE = ''
$v_EncryptCipherBy = ''
$v_EncryptCipher = ''
$v_EncryptSwap = ''
$av_EncryptBox = ''
Local $av_EncryptBox[256][2]
For $i_EncryptCountA = 0 To 255
$av_EncryptBox[$i_EncryptCountA][1] = Asc(StringMid($s_EncryptPassword, Mod($i_EncryptCountA, StringLen($s_EncryptPassword)) + 1, 1))
$av_EncryptBox[$i_EncryptCountA][0] = $i_EncryptCountA
Next
For $i_EncryptCountA = 0 To 255
$i_EncryptCountB = Mod(($i_EncryptCountB + $av_EncryptBox[$i_EncryptCountA][0] + $av_EncryptBox[$i_EncryptCountA][1]), 256)
$v_EncryptSwap = $av_EncryptBox[$i_EncryptCountA][0]
$av_EncryptBox[$i_EncryptCountA][0] = $av_EncryptBox[$i_EncryptCountB][0]
$av_EncryptBox[$i_EncryptCountB][0] = $v_EncryptSwap
Next
For $i_EncryptCountA = 1 To StringLen($s_EncryptText) Step 2
$i_EncryptCountC = Mod(($i_EncryptCountC + 1), 256)
$i_EncryptCountD = Mod(($i_EncryptCountD + $av_EncryptBox[$i_EncryptCountC][0]), 256)
$i_EncryptCountE = $av_EncryptBox[Mod(($av_EncryptBox[$i_EncryptCountC][0] + $av_EncryptBox[$i_EncryptCountD][0]), 256)][0]
$v_EncryptCipherBy = BitXOR(Dec(StringMid($s_EncryptText, $i_EncryptCountA, 2)), $i_EncryptCountE)
$v_EncryptCipher = $v_EncryptCipher & Chr($v_EncryptCipherBy)
Next
$s_EncryptText = $v_EncryptCipher
$i_EncryptCountG = ''
$i_EncryptCountH = ''
$v_EncryptModified = ''
For $i_EncryptCountG = 1 To StringLen($s_EncryptText)
If $i_EncryptCountH = StringLen($s_EncryptPassword) Then
$i_EncryptCountH = 1
Else
$i_EncryptCountH += 1
EndIf
$v_EncryptModified &= Chr(BitXOR(Asc(StringMid($s_EncryptText, $i_EncryptCountG, 1)), Asc(StringMid($s_EncryptPassword, $i_EncryptCountH, 1)), 255))
Next
$s_EncryptText = $v_EncryptModified
Next
EndIf
Return $s_EncryptText
EndIf
EndFunc
Func _StringReverse($s_String)
Local $i_len = StringLen($s_String)
If $i_len < 1 Then Return SetError(1, 0, "")
Local $t_chars = DllStructCreate("char[" & $i_len + 1 & "]")
DllStructSetData($t_chars, 1, $s_String)
Local $a_rev = DllCall("msvcrt.dll", "ptr:cdecl", "_strrev", "struct*", $t_chars)
If @error Or $a_rev[0] = 0 Then Return SetError(2, 0, "")
Return DllStructGetData($t_chars, 1)
EndFunc
Func _MD5($Data)
$hProv = DllStructCreate("ULONG_PTR")
$hHash = DllStructCreate("ULONG_PTR")
$cbHash = DllStructCreate("ULONG_PTR")
DllStructSetData($cbHash, 1, 16)
$Hash = DllStructCreate("BYTE[" & StringLen($Data) + 1 & "]")
DllStructSetData($Hash, 1, $Data)
$digit = DllStructCreate("char[16]")
DllStructSetData($digit, 1, "0123456789abcdef")
$fHash = DllStructCreate("char[32]")
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
#AutoIt3Wrapper_AU3Check_Parameters= -d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6
Global $_Timers_aTimerIDs[1][3]
Func _Timer_KillTimer($hWnd, $iTimerID)
Local $aResult[1] = [0], $hCallBack = 0, $iUBound = UBound($_Timers_aTimerIDs) - 1
For $x = 1 To $iUBound
If $_Timers_aTimerIDs[$x][0] = $iTimerID Then
If IsHWnd($hWnd) Then
$aResult = DllCall("user32.dll", "bool", "KillTimer", "hwnd", $hWnd, "uint_ptr", $_Timers_aTimerIDs[$x][1])
Else
$aResult = DllCall("user32.dll", "bool", "KillTimer", "hwnd", $hWnd, "uint_ptr", $_Timers_aTimerIDs[$x][0])
EndIf
If @error Or $aResult[0] = 0 Then Return SetError(@error, @extended, False)
$hCallBack = $_Timers_aTimerIDs[$x][2]
If $hCallBack <> 0 Then DllCallbackFree($hCallBack)
For $i = $x To $iUBound - 1
$_Timers_aTimerIDs[$i][0] = $_Timers_aTimerIDs[$i + 1][0]
$_Timers_aTimerIDs[$i][1] = $_Timers_aTimerIDs[$i + 1][1]
$_Timers_aTimerIDs[$i][2] = $_Timers_aTimerIDs[$i + 1][2]
Next
ReDim $_Timers_aTimerIDs[UBound($_Timers_aTimerIDs - 1)][3]
$_Timers_aTimerIDs[0][0] -= 1
ExitLoop
EndIf
Next
Return $aResult[0] <> 0
EndFunc
Func _Timer_SetTimer($hWnd, $iElapse = 250, $sTimerFunc = "", $iTimerID = -1)
Local $aResult[1] = [0], $pTimerFunc = 0, $hCallBack = 0, $iIndex = $_Timers_aTimerIDs[0][0] + 1
If $iTimerID = -1 Then
ReDim $_Timers_aTimerIDs[$iIndex + 1][3]
$_Timers_aTimerIDs[0][0] = $iIndex
$iTimerID = $iIndex + 1000
For $x = 1 To $iIndex
If $_Timers_aTimerIDs[$x][0] = $iTimerID Then
$iTimerID = $iTimerID + 1
$x = 0
EndIf
Next
If $sTimerFunc <> "" Then
$hCallBack = DllCallbackRegister($sTimerFunc, "none", "hwnd;int;uint_ptr;dword")
If $hCallBack = 0 Then Return SetError(-1, -1, 0)
$pTimerFunc = DllCallbackGetPtr($hCallBack)
If $pTimerFunc = 0 Then Return SetError(-1, -1, 0)
EndIf
$aResult = DllCall("user32.dll", "uint_ptr", "SetTimer", "hwnd", $hWnd, "uint_ptr", $iTimerID, "uint", $iElapse, "ptr", $pTimerFunc)
If @error Or $aResult[0] = 0 Then Return SetError(@error, @extended, 0)
$_Timers_aTimerIDs[$iIndex][0] = $aResult[0]
$_Timers_aTimerIDs[$iIndex][1] = $iTimerID
$_Timers_aTimerIDs[$iIndex][2] = $hCallBack
Else
For $x = 1 To $iIndex - 1
If $_Timers_aTimerIDs[$x][0] = $iTimerID Then
If IsHWnd($hWnd) Then $iTimerID = $_Timers_aTimerIDs[$x][1]
$hCallBack = $_Timers_aTimerIDs[$x][2]
If $hCallBack <> 0 Then
$pTimerFunc = DllCallbackGetPtr($hCallBack)
If $pTimerFunc = 0 Then Return SetError(-1, -1, 0)
EndIf
$aResult = DllCall("user32.dll", "uint_ptr", "SetTimer", "hwnd", $hWnd, "uint_ptr", $iTimerID, "int", $iElapse, "ptr", $pTimerFunc)
If @error Or $aResult[0] = 0 Then Return SetError(@error, @extended, 0)
ExitLoop
EndIf
Next
EndIf
Return $aResult[0]
EndFunc
_GDIPlus_Startup()
#Region
Global Const $tagGifGraphicsControlExtension = 'byte Introducer;' & _
'byte Label;' & _
'byte BlockSize;' & _
'byte Packed;' & _
'ushort DelayTime;' & _
'byte ColorIndex;' & _
'byte Terminator;' & _
''
Global Const $tagGifLogicalScreenDescriptor = 'ushort ScreenWidth;' & _
'ushort ScreenHeight;' & _
'byte Packed;' & _
'byte BackgroundColor;' & _
'byte AspectRatio;' & _
''
Global Const $tagGifImageDescriptor = 'byte Separator;' & _
'ushort Left;' & _
'ushort Top;' & _
'ushort Width;' & _
'ushort Height;' & _
'byte Packed;' & _
''
Global Const $tagANIHeader = 'dword cbSizeOf;' & _
'dword cFrames;' & _
'dword cSteps;' & _
'dword cx;' & _
'dword cy;' & _
'dword cBitCount;' & _
'dword cPlanes;' & _
'dword JifRate;' & _
'dword flags' & _
''
Global Const $FOURCC_RIFF = 'RIFF'
Global Const $FOURCC_anih = 'anih'
Global Const $FOURCC_rate = 'rate'
Global Const $FOURCC_seq = 'seq '
Global Const $FOURCC_fram = 'fram'
Global Const $FOURCC_icon = 'icon'
Global Const $_ani_Callback = '__Ani_GetTimer'
Global Const $_ani_Separator = Chr(0x21) & Chr(0xF9) & Chr(0x04)
Global Const $_ani_ExitOpt = OnAutoItExitRegister('__Ani_OnAutoItExit')
Global Const $_ani_TempDir = @TempDir & '\_ani.au3\' & @AutoItPID & '_'
Global $_ani_Array[12][1], $_ani_Data[1][1][2], $_ani_Instance, $_ani_Steps = 1
#EndRegion
#Region
Func GUICtrlCreateGifEx($hWnd, $hfile, $x, $y, $hspeed = 1)
If FileExists($hfile) = 0 Or IsHWnd($hWnd) = 0 Then Return
Local $hctrl = _GDIPlus_GraphicsCreateFromHWND($hWnd)
Local $id = __Ani_GetInstance($hctrl)
If __Ani_SplitAni($id, $hfile, 0, $hWnd, $hctrl, $hspeed) = 0 Then Return 0 * _GDIPlus_GraphicsDispose($hctrl)
$_ani_Array[6][$id] = '__Ani_SetObjectAni'
$_ani_Array[10][$id] = $x
$_ani_Array[11][$id] = $y
Call($_ani_Array[6][$id], $id, $_ani_Data[$id][$_ani_Array[3][$id]][0])
Return $hctrl
EndFunc
Func _Ani_DeleteAnimation($hWnd = 'Tray')
Local $id = __Ani_GetInstance($hWnd, 1)
If $id = -1 Then Return
Local $ret = 1 * _Timer_KillTimer($_ani_Array[0][$id], $_ani_Array[5][$id])
$_ani_Array[5][$id] -= 1000
Return $ret
EndFunc
#EndRegion
#Region
Func __Ani_GetInstance($hctrl, $hmode = 0)
For $i = 0 To $_ani_Instance - 1
If $_ani_Array[1][$i] = $hctrl Then Return $i
Next
If $hmode Then Return -1
$_ani_Instance += 1
ReDim $_ani_Array[12][$_ani_Instance], $_ani_Data[$_ani_Instance][$_ani_Steps][2]
$_ani_Array[5][$_ani_Instance - 1] = -1
Return $_ani_Instance - 1
EndFunc
Func __Ani_SplitAni($id, $hfile, $hslow = 0, $hWnd = -1, $hctrl = 0, $hspeed = 1)
Local $read = FileRead($hfile)
If $hspeed = 0 Then $hspeed = 1
If StringLeft($read, 4) <> $FOURCC_RIFF Then Return __Ani_SplitGif($id, $read, $hWnd, $hctrl, $hspeed, $hslow)
If StringInStr($read, $FOURCC_fram & $FOURCC_icon) = 0 Then Return
Local $a = StringSplit($read, $FOURCC_anih, 1)
If $a[0] < 2 Then Return
Local $tBinary = DllStructCreate('byte[36]')
DllStructSetData($tBinary, 1, $a[2])
Local $tResource = DllStructCreate($tagANIHeader, DllStructGetPtr($tBinary) + 4)
Local $cFrames = DllStructGetData($tResource, 'cFrames')
If $hWnd = 0 And $hctrl > $cFrames Then Return
If $hWnd = -1 Then Return $cFrames
Local $cSteps = DllStructGetData($tResource, 'cSteps')
Local $JifRate = DllStructGetData($tResource, 'JifRate')
Local $b = StringSplit(StringMid($read, StringInStr($read, $FOURCC_fram & $FOURCC_icon) + 8), $FOURCC_icon, 1)
For $i = 1 To $cFrames
If IsHWnd($hWnd) Or $hctrl = $i Then
Local $gBinary = BinaryMid($b[$i], 5)
Local $write = FileOpen($_ani_TempDir & $id & '_' & $i - 1, 26)
If $write = 0 Then Return
FileWrite($write, $gBinary)
FileClose($write)
If $hWnd = 0 Then Return 1
EndIf
Next
If $cSteps > $_ani_Steps Then __Ani_SetSteps($cSteps)
Local $rate = StringSplit($read, $FOURCC_rate, 1)
Local $seq = StringSplit($read, $FOURCC_seq, 1)
For $i = 0 To $cSteps - 1
$_ani_Data[$id][$i][0] = $i
If $seq[0] > 1 Then $_ani_Data[$id][$i][0] = Dec(Hex(BinaryMid($seq[2],($i + 1) * 4 + 1, 1)))
$_ani_Data[$id][$i][1] = $JifRate
If $rate[0] > 1 Then $_ani_Data[$id][$i][1] = Dec(Hex(BinaryMid($rate[2],($i + 1) * 4 + 1, 1)))
Next
Return __Ani_SetArray($id, $hWnd, $hctrl, $cSteps, $hspeed)
EndFunc
Func __Ani_SplitGif($id, $read, $hWnd, $hctrl, $hspeed, $hslow)
If StringLeft($read, 6) <> 'GIF89a' Or StringInStr($read, $_ani_Separator) = 0 Or $hslow Then Return __Ani_SplitGifEx($id, $read, $hWnd, $hctrl, $hspeed)
Local $a = StringSplit($read, $_ani_Separator, 1)
If $hWnd = -1 Then Return $a[0] - 1
If $a[0] < 3 Or($hWnd = 0 And $hctrl > $a[0] - 1) Then Return
If $hWnd <> 0 And $a[0] - 1 > $_ani_Steps Then __Ani_SetSteps($a[0] - 1)
For $i = 2 To $a[0]
If IsHWnd($hWnd) Or $hctrl = $i - 1 Then
Local $write = FileOpen($_ani_TempDir & $id & '_' & $i - 2, 26)
If $write = 0 Then Return
FileWrite($write, StringTrimRight($a[1] & $_ani_Separator & $a[$i] & Chr(0x3B), $i = $a[0]))
FileClose($write)
If $hWnd = 0 Then Return 1
$_ani_Data[$id][$i - 2][0] = $i - 2
Local $temp =(Dec(Hex(BinaryMid($a[$i], 2, 1))) + Dec(Hex(BinaryMid($a[$i], 3, 1))) * 256) * 3 / 5
$_ani_Data[$id][$i - 2][1] = $temp + 6 *($temp = 0)
EndIf
Next
Return __Ani_SetArray($id, $hWnd, $hctrl, $a[0] - 1, $hspeed)
EndFunc
Func __Ani_SplitGifEx($id, $read, $hWnd, $hctrl, $hspeed)
If StringLeft($read, 6) <> 'GIF87a' And StringLeft($read, 6) <> 'GIF89a' Then Return
Local $sseparator = '002C'
If StringLeft($read, 6) = 'GIF89a' And StringInStr($read, $_ani_Separator) Then $sseparator = '0021F904'
Local $binary = StringToBinary($read)
Local $x = StringInStr($binary, $sseparator)
If $x = 0 Then Return
Local $gifheader = StringLeft($binary, $x + 1), $count = 0, $i, $write
$binary = StringMid($binary, $x + 2)
If $sseparator = '0021F904' And IsHWnd($hWnd) Then Local $temp[1] = [3 / 5 *(Dec(StringMid($binary, 9, 2)) + 256 * Dec(StringMid($binary, 11, 2))) ]
While 1
$i = 0
Do
$i += 1
$x = StringInStr($binary, $sseparator, 2, $i)
If $x = 0 Then
If $hWnd = -1 Then Return $count + 1
If $hWnd = 0 And $hctrl > $count + 1 Then Return
$write = FileOpen($_ani_TempDir & $id & '_' & $count, 26)
If $write = 0 Then Return
FileWrite($write, BinaryToString($gifheader & $binary))
FileClose($write)
If $hWnd = 0 Then Return 1
If $count + 1 > $_ani_Steps Then __Ani_SetSteps($count + 1)
For $i = 0 To $count
$_ani_Data[$id][$i][0] = $i
$_ani_Data[$id][$i][1] = 6
If $sseparator = '0021F904' And $temp[$i] > 0 Then $_ani_Data[$id][$i][1] = $temp[$i]
Next
Return __Ani_SetArray($id, $hWnd, $hctrl, $count + 1, $hspeed)
EndIf
Until Mod($x, 2)
If IsHWnd($hWnd) Or $hctrl = $count + 1 Then
$write = FileOpen($_ani_TempDir & $id & '_' & $count, 26)
If $write = 0 Then Return
FileWrite($write, BinaryToString($gifheader & StringLeft($binary, $x + 1) & '3B'))
FileClose($write)
If $hWnd = 0 Then Return 1
EndIf
$binary = StringMid($binary, $x + 2)
$count += 1
If $sseparator = '0021F904' And IsHWnd($hWnd) Then
ReDim $temp[$count + 1]
$temp[$count] = 3 / 5 *(Dec(StringMid($binary, 9, 2)) + 256 * Dec(StringMid($binary, 11, 2)))
EndIf
WEnd
EndFunc
Func __Ani_SetArray($id, $hWnd, $hctrl, $hcount, $hspeed)
$_ani_Array[0][$id] = $hWnd
$_ani_Array[1][$id] = $hctrl
$_ani_Array[2][$id] = $hctrl
$_ani_Array[3][$id] = 0
$_ani_Array[4][$id] = $hcount
$_ani_Array[7][$id] = Abs($hspeed)
$_ani_Array[8][$id] = $hspeed / $_ani_Array[7][$id]
$_ani_Array[5][$id] = _Timer_SetTimer($hWnd, $_ani_Data[$id][0][1] / 6 * 100 / $_ani_Array[7][$id], $_ani_Callback, $_ani_Array[5][$id])
If $_ani_Array[5][$id] Then Return 1
EndFunc
Func __Ani_SetSteps($hsteps)
$_ani_Steps = $hsteps
ReDim $_ani_Data[$_ani_Instance][$hsteps][2]
EndFunc
Func __Ani_OnAutoItExit()
Call($_ani_ExitOpt)
For $i = 0 To $_ani_Instance - 1
If IsNumber($_ani_Array[10][$i]) Then _GDIPlus_GraphicsDispose($_ani_Array[1][$i])
Next
FileDelete($_ani_TempDir & '*')
_GDIPlus_Shutdown()
EndFunc
#EndRegion
#Obfuscator_Off
; #INDEX# =======================================================================================================================
; Title .........: AutoItObject
; AutoIt Version : 3.3
; Language ......: English (language independent)
; Description ...: Brings Objects to AutoIt.
; Author(s) .....: monoceres, trancexx, Kip, Prog@ndy
; Copyright .....: Copyright (C) The AutoItObject-Team. All rights reserved.
; License .......: Artistic License 2.0, see Artistic.txt
;
; This file is part of AutoItObject.
;
; AutoItObject is free software; you can redistribute it and/or modify
; it under the terms of the Artistic License as published by Larry Wall,
; either version 2.0, or (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
; See the Artistic License for more details.
;
; You should have received a copy of the Artistic License with this Kit,
; in the file named "Artistic.txt".  If not, you can get a copy from
; <http://www.perlfoundation.org/artistic_license_2_0> OR
; <http://www.opensource.org/licenses/artistic-license-2.0.php>
;
; ------------------------ AutoItObject CREDITS: ------------------------
; Copyright (C) by:
; The AutoItObject-Team:
; 	Andreas Karlsson (monoceres)
; 	Dragana R. (trancexx)
; 	Dave Bakker (Kip)
; 	Andreas Bosch (progandy, Prog@ndy)
;
; ===============================================================================================================================
#AutoIt3Wrapper_Au3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6


; #CURRENT# =====================================================================================================================
;_AutoItObject_VariantRead
;_AutoItObject_VariantSet
;_AutoItObject_VariantCopy
;_AutoItObject_VariantClear
;_AutoItObject_VariantFree
;_AutoItObject_Startup
;_AutoItObject_Shutdown
;_AutoItObject_WrapperCreate
;_AutoItObject_WrapperAddMethod
;_AutoItObject_Class
;_AutoItObject_Create
;_AutoItObject_AddMethod
;_AutoItObject_AddProperty
;_AutoItObject_AddDestructor
;_AutoItObject_AddEnum
;_AutoItObject_RemoveMember
;_AutoItObject_IUnknownAddRef
;_AutoItObject_CLSIDFromString
;_AutoItObject_CoCreateInstance
;_AutoItObject_PtrToIDispatch
;_AutoItObject_IDispatchToPtr
;_AutoItObject_VariantCopy
;_AutoItObject_VariantClear

; ===============================================================================================================================

; #INTERNAL_NO_DOC# =============================================================================================================
;__Au3Obj_OleUninitialize()
;__Au3Obj_IUnknown_AddRef
;__Au3Obj_GetMethods
;__Au3Obj_VariantInit
;__Au3Obj_SafeArrayCreate
;__Au3Obj_SafeArrayDestroy
;__Au3Obj_SafeArrayAccessData
;__Au3Obj_SafeArrayUnaccessData
;__Au3Obj_SafeArrayGetUBound
;__Au3Obj_SafeArrayGetLBound
;__Au3Obj_SafeArrayGetDim
;__Au3Obj_CreateSafeArrayVariant
;__Au3Obj_ReadSafeArrayVariant
;__Au3Obj_CoTaskMemAlloc
;__Au3Obj_CoTaskMemFree
;__Au3Obj_CoTaskMemRealloc
;__Au3Obj_GlobalAlloc
;__Au3Obj_GlobalFree
;__Au3Obj_SysAllocString
;__Au3Obj_SysCopyString
;__Au3Obj_SysReAllocString
;__Au3Obj_SysFreeString
;__Au3Obj_SysStringLen
;__Au3Obj_SysReadString
;__Au3Obj_PtrStringLen
;__Au3Obj_PtrStringRead
;__Au3Obj_FunctionProxy
;__Au3Obj_WrapFunctionProxy
;__Au3Obj_EnumFunctionProxy
;__Au3Obj_Object_Create
;__Au3Obj_Object_AddMethod
;__Au3Obj_Object_AddProperty
;__Au3Obj_Object_AddDestructor
;__Au3Obj_Object_AddEnum
;__Au3Obj_Object_RemoveMember
;__Au3Obj_ObjStructGetElements
;__Au3Obj_ObjStructMethod
;__Au3Obj_ObjStructDestructor
;__Au3Obj_PointerCall
;__Au3Obj_Mem_DllOpen
;__Au3Obj_Mem_FixReloc
;__Au3Obj_Mem_FixImports
;__Au3Obj_Mem_LoadLibraryEx
;__Au3Obj_Mem_FreeLibrary
;__Au3Obj_Mem_GetAddress
;__Au3Obj_Mem_VirtualProtect
;__Au3Obj_Mem_BinDll
;__Au3Obj_Mem_BinDll_X64
; ===============================================================================================================================

;--------------------------------------------------------------------------------------------------------------------------------------
#region Variable definitions

Global Const $gh_AU3Obj_kernel32dll = DllOpen("kernel32.dll")
Global Const $gh_AU3Obj_oleautdll = DllOpen("oleaut32.dll")
Global Const $gh_AU3Obj_ole32dll = DllOpen("ole32.dll")

Global Const $__Au3Obj_X64 = @AutoItX64

Global Const $__Au3Obj_VT_EMPTY = 0
Global Const $__Au3Obj_VT_NULL = 1
Global Const $__Au3Obj_VT_I2 = 2
Global Const $__Au3Obj_VT_I4 = 3
Global Const $__Au3Obj_VT_R4 = 4
Global Const $__Au3Obj_VT_R8 = 5
Global Const $__Au3Obj_VT_CY = 6
Global Const $__Au3Obj_VT_DATE = 7
Global Const $__Au3Obj_VT_BSTR = 8
Global Const $__Au3Obj_VT_DISPATCH = 9
Global Const $__Au3Obj_VT_ERROR = 10
Global Const $__Au3Obj_VT_BOOL = 11
Global Const $__Au3Obj_VT_VARIANT = 12
Global Const $__Au3Obj_VT_UNKNOWN = 13
Global Const $__Au3Obj_VT_DECIMAL = 14
Global Const $__Au3Obj_VT_I1 = 16
Global Const $__Au3Obj_VT_UI1 = 17
Global Const $__Au3Obj_VT_UI2 = 18
Global Const $__Au3Obj_VT_UI4 = 19
Global Const $__Au3Obj_VT_I8 = 20
Global Const $__Au3Obj_VT_UI8 = 21
Global Const $__Au3Obj_VT_INT = 22
Global Const $__Au3Obj_VT_UINT = 23
Global Const $__Au3Obj_VT_VOID = 24
Global Const $__Au3Obj_VT_HRESULT = 25
Global Const $__Au3Obj_VT_PTR = 26
Global Const $__Au3Obj_VT_SAFEARRAY = 27
Global Const $__Au3Obj_VT_CARRAY = 28
Global Const $__Au3Obj_VT_USERDEFINED = 29
Global Const $__Au3Obj_VT_LPSTR = 30
Global Const $__Au3Obj_VT_LPWSTR = 31
Global Const $__Au3Obj_VT_RECORD = 36
Global Const $__Au3Obj_VT_INT_PTR = 37
Global Const $__Au3Obj_VT_UINT_PTR = 38
Global Const $__Au3Obj_VT_FILETIME = 64
Global Const $__Au3Obj_VT_BLOB = 65
Global Const $__Au3Obj_VT_STREAM = 66
Global Const $__Au3Obj_VT_STORAGE = 67
Global Const $__Au3Obj_VT_STREAMED_OBJECT = 68
Global Const $__Au3Obj_VT_STORED_OBJECT = 69
Global Const $__Au3Obj_VT_BLOB_OBJECT = 70
Global Const $__Au3Obj_VT_CF = 71
Global Const $__Au3Obj_VT_CLSID = 72
Global Const $__Au3Obj_VT_VERSIONED_STREAM = 73
Global Const $__Au3Obj_VT_BSTR_BLOB = 0xfff
Global Const $__Au3Obj_VT_VECTOR = 0x1000
Global Const $__Au3Obj_VT_ARRAY = 0x2000
Global Const $__Au3Obj_VT_BYREF = 0x4000
Global Const $__Au3Obj_VT_RESERVED = 0x8000
Global Const $__Au3Obj_VT_ILLEGAL = 0xffff
Global Const $__Au3Obj_VT_ILLEGALMASKED = 0xfff
Global Const $__Au3Obj_VT_TYPEMASK = 0xfff

Global Const $__Au3Obj_tagVARIANT = "word vt;word r1;word r2;word r3;ptr data; ptr"

Global Const $__Au3Obj_tagVARIANT_SIZE = DllStructGetSize(DllStructCreate($__Au3Obj_tagVARIANT, 1))
Global Const $__Au3Obj_tagPTR_SIZE = DllStructGetSize(DllStructCreate('ptr', 1))
Global Const $__Au3Obj_tagSAFEARRAYBOUND = "ulong cElements; long lLbound;"

Global $ghAutoItObjectDLL = -1, $giAutoItObjectDLLRef = 0

#endregion Variable definitions
;--------------------------------------------------------------------------------------------------------------------------------------


;--------------------------------------------------------------------------------------------------------------------------------------
#region Misc

DllCall($gh_AU3Obj_ole32dll, 'long', 'OleInitialize', 'ptr', 0)
OnAutoItExitRegister("__Au3Obj_OleUninitialize")
Func __Au3Obj_OleUninitialize()
	; Author: Prog@ndy
	DllCall($gh_AU3Obj_ole32dll, 'long', 'OleUninitialize')
	_AutoItObject_Shutdown(True)
EndFunc   ;==>__Au3Obj_OleUninitialize

Func __Au3Obj_IUnknown_AddRef($hObj)
	; Author: trancexx
	; modified: prog@ndy
	Local $pObj = $hObj
	If IsObj($hObj) Then $pObj = _AutoItObject_IDispatchToPtr($hObj)
	; Adjusted VARIANT structure
	Local Static $tVAR_DWORD = DllStructCreate("word VarType; word Reserved1; word Reserved2; word Reserved3; dword Data; ptr Record;") ; static is faster ;)
	DllStructSetData($tVAR_DWORD, "VarType", $__Au3Obj_VT_UINT)
	; Actual call
	Local $aCall = DllCall($gh_AU3Obj_oleautdll, "int", "DispCallFunc", _
			"ptr", $pObj, _
			"dword", $__Au3Obj_tagPTR_SIZE, _ ; offset (4 for x86, 8 for x64)
			"dword", 4, _ ; CC_STDCALL
			"dword", $__Au3Obj_VT_UINT, _;$__Au3Obj_VT_UINT, _
			"dword", 0, _ ; number of function parameters
			"ptr", 0, _ ; parameters related
			"ptr", 0, _ ; parameters related
			"ptr", DllStructGetPtr($tVAR_DWORD))
	If @error Or $aCall[0] Then Return SetError(1, 0, 0)
	; Collect returned
	Return DllStructGetData($tVAR_DWORD, "Data")
EndFunc   ;==>__Au3Obj_IUnknown_AddRef

Func __Au3Obj_GetMethods($tagInterface)
	Local $sMethods = StringReplace(StringRegExpReplace($tagInterface, "\h*(\w+)\h*(\w+)\h*(\((.*?)\))\h*(;|;*\z)", "$1\|$2;$4" & @LF), ";" & @LF, @LF)
	If $sMethods = $tagInterface Then $sMethods = StringReplace(StringRegExpReplace($tagInterface, "\h*(\w+)\h*(;|;*\z)", "$1\|" & @LF), ";" & @LF, @LF)
	Return StringTrimRight($sMethods, 1)
EndFunc   ;==>__Au3Obj_GetMethods

Func __Au3Obj_ObjStructGetElements($sTag, ByRef $sAlign)
	Local $sAlignment = StringRegExpReplace($sTag, "\h*(align\h+\d+)\h*;.*", "$1")
	If $sAlignment <> $sTag Then
		$sAlign = $sAlignment
		$sTag = StringRegExpReplace($sTag, "\h*(align\h+\d+)\h*;", "")
	EndIf
	; Return StringRegExp($sTag, "\h*\w+\h*(\w+)\h*", 3) ; DO NOT REMOVE THIS LINE
	Return StringTrimRight(StringRegExpReplace($sTag, "\h*\w+\h*(\w+)\h*(\[\d+\])*\h*(;|;*\z)\h*", "$1;"), 1)
EndFunc   ;==>__Au3Obj_ObjStructGetElements

#endregion Misc
;--------------------------------------------------------------------------------------------------------------------------------------


;--------------------------------------------------------------------------------------------------------------------------------------
#region Variant

; #FUNCTION# ====================================================================================================================
; Name...........: _AutoItObject_VariantRead
; Description ...: Reads he value of a VARIANT
; Syntax.........: _AutoItObject_VariantRead($pVariant)
; Parameters ....: $pVariant    - Pointer to VARaINT-structure
; Return values .: Success      - value of the VARIANT
;                  Failure      - 0
; Author ........: monoceres, Prog@ndy
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........;
; Example .......;
; ===============================================================================================================================
Func _AutoItObject_VariantRead($pVariant)
	; Author: monoceres, Prog@ndy
	Local $var = DllStructCreate($__Au3Obj_tagVARIANT, $pVariant), $data
	; Translate the vt id to a autoit dllcall type
	Local $VT = DllStructGetData($var, "vt"), $type
	Switch $VT
		Case $__Au3Obj_VT_I1, $__Au3Obj_VT_UI1
			$type = "byte"
		Case $__Au3Obj_VT_I2
			$type = "short"
		Case $__Au3Obj_VT_I4
			$type = "int"
		Case $__Au3Obj_VT_I8
			$type = "int64"
		Case $__Au3Obj_VT_R4
			$type = "float"
		Case $__Au3Obj_VT_R8
			$type = "double"
		Case $__Au3Obj_VT_UI2
			$type = 'word'
		Case $__Au3Obj_VT_UI4
			$type = 'uint'
		Case $__Au3Obj_VT_UI8
			$type = 'uint64'
		Case $__Au3Obj_VT_BSTR
			Return __Au3Obj_SysReadString(DllStructGetData($var, "data"))
		Case $__Au3Obj_VT_BOOL
			$type = 'short'
		Case BitOR($__Au3Obj_VT_ARRAY, $__Au3Obj_VT_UI1)
			Local $pSafeArray = DllStructGetData($var, "data")
			Local $bound, $pData, $lbound
			If 0 = __Au3Obj_SafeArrayGetUBound($pSafeArray, 1, $bound) Then
				__Au3Obj_SafeArrayGetLBound($pSafeArray, 1, $lbound)
				$bound += 1 - $lbound
				If 0 = __Au3Obj_SafeArrayAccessData($pSafeArray, $pData) Then
					Local $tData = DllStructCreate("byte[" & $bound & "]", $pData)
					$data = DllStructGetData($tData, 1)
					__Au3Obj_SafeArrayUnaccessData($pSafeArray)
				EndIf
			EndIf
			Return $data
		Case BitOR($__Au3Obj_VT_ARRAY, $__Au3Obj_VT_VARIANT)
			Return __Au3Obj_ReadSafeArrayVariant(DllStructGetData($var, "data"))
		Case $__Au3Obj_VT_DISPATCH
			Return _AutoItObject_PtrToIDispatch(DllStructGetData($var, "data"))
		Case $__Au3Obj_VT_PTR
			Return DllStructGetData($var, "data")
		Case $__Au3Obj_VT_ERROR
			Return Default
		Case Else
			_AutoItObject_VariantClear($pVariant)
			Return SetError(1, 0, '')
	EndSwitch

	$data = DllStructCreate($type, DllStructGetPtr($var, "data"))

	Switch $VT
		Case $__Au3Obj_VT_BOOL
			Return DllStructGetData($data, 1) <> 0
	EndSwitch
	Return DllStructGetData($data, 1)

EndFunc   ;==>_AutoItObject_VariantRead

; #FUNCTION# ====================================================================================================================
; Name...........: _AutoItObject_VariantSet
; Description ...: sets the valkue of a varaint or creates a new one.
; Syntax.........: _AutoItObject_VariantSet($pVar, $vVal, $iSpecialType = 0)
; Parameters ....: $pVar        - Pointer to the VARIANT to modify (0 if you want to create it new)
;                  $vVal        - Value of the VARIANT
;                  $iSpecialType - [optional] Modify the automatic type. NOT FOR GENERAL USE!
; Return values .: Success      - Pointer to the VARIANT
;                  Failure      - 0
; Author ........: monoceres, Prog@ndy
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........;
; Example .......;
; ===============================================================================================================================
Func _AutoItObject_VariantSet($pVar, $vVal, $iSpecialType = 0)
	; Author: monoceres, Prog@ndy
	If Not $pVar Then
		$pVar = __Au3Obj_CoTaskMemAlloc($__Au3Obj_tagVARIANT_SIZE)
		__Au3Obj_VariantInit($pVar)
	Else
		_AutoItObject_VariantClear($pVar)
	EndIf
	Local $tVar = DllStructCreate($__Au3Obj_tagVARIANT, $pVar)
	Local $iType = $__Au3Obj_VT_EMPTY, $vDataType = ''

	Switch VarGetType($vVal)
		Case "Int32"
			$iType = $__Au3Obj_VT_I4
			$vDataType = 'int'
		Case "Int64"
			$iType = $__Au3Obj_VT_I8
			$vDataType = 'int64'
		Case "String", 'Text'
			$iType = $__Au3Obj_VT_BSTR
			$vDataType = 'ptr'
			$vVal = __Au3Obj_SysAllocString($vVal)
		Case "Double"
			$vDataType = 'double'
			$iType = $__Au3Obj_VT_R8
		Case "Float"
			$vDataType = 'float'
			$iType = $__Au3Obj_VT_R4
		Case "Bool"
			$vDataType = 'short'
			$iType = $__Au3Obj_VT_BOOL
			If $vVal Then
				$vVal = 0xffff
			Else
				$vVal = 0
			EndIf
		Case 'Ptr'
			If $__Au3Obj_X64 Then
				$iType = $__Au3Obj_VT_UI8
			Else
				$iType = $__Au3Obj_VT_UI4
			EndIf
			$vDataType = 'ptr'
		Case 'Object'
			$vVal = _AutoItObject_IDispatchToPtr($vVal)
			;__Au3Obj_IUnknown_AddRef($vVal)
			DllCall($ghAutoItObjectDLL, "int", "IUnknownAddRef", "ptr", $vVal)
			$vDataType = 'ptr'
			$iType = $__Au3Obj_VT_DISPATCH
		Case "Binary"
			; ARRAY OF BYTES !
			Local $tSafeArrayBound = DllStructCreate($__Au3Obj_tagSAFEARRAYBOUND)
			DllStructSetData($tSafeArrayBound, 1, BinaryLen($vVal))
			Local $pSafeArray = __Au3Obj_SafeArrayCreate($__Au3Obj_VT_UI1, 1, DllStructGetPtr($tSafeArrayBound))
			Local $pData
			If 0 = __Au3Obj_SafeArrayAccessData($pSafeArray, $pData) Then
				Local $tData = DllStructCreate("byte[" & BinaryLen($vVal) & "]", $pData)
				DllStructSetData($tData, 1, $vVal)
				__Au3Obj_SafeArrayUnaccessData($pSafeArray)
				$vVal = $pSafeArray
				$vDataType = 'ptr'
				$iType = BitOR($__Au3Obj_VT_ARRAY, $__Au3Obj_VT_UI1)
			EndIf
		Case "Array"
			$vDataType = 'ptr'
			$vVal = __Au3Obj_CreateSafeArrayVariant($vVal)
			$iType = BitOR($__Au3Obj_VT_ARRAY, $__Au3Obj_VT_VARIANT)
		Case Else ;"Keyword" ; all keywords and unknown Vartypes will be handled as "default"
			$iType = $__Au3Obj_VT_ERROR
			$vDataType = 'int'
	EndSwitch
	If $vDataType Then
		DllStructSetData(DllStructCreate($vDataType, DllStructGetPtr($tVar, 'data')), 1, $vVal)

		If @NumParams = 3 Then $iType = $iSpecialType
		DllStructSetData($tVar, 'vt', $iType)
	EndIf
	Return $pVar
EndFunc   ;==>_AutoItObject_VariantSet

; #FUNCTION# ====================================================================================================================
; Name...........: _AutoItObject_VariantCopy
; Description ...: Copies a VARIANT to another
; Syntax.........: _AutoItObject_VariantCopy($pvargDest, $pvargSrc)
; Parameters ....: $pvargDest   - Destionation variant
;                  $pvargSrc    - Source variant
; Return values .: Success      - 0
;                  Failure      - nonzero
; Author ........: Prog@ndy
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........; @@MsdnLink@@ VariantCopy
; Example .......;
; ===============================================================================================================================
Func _AutoItObject_VariantCopy($pvargDest, $pvargSrc)
	; Author: Prog@ndy
	Local $aCall = DllCall($gh_AU3Obj_oleautdll, "long", "VariantCopy", "ptr", $pvargDest, 'ptr', $pvargSrc)
	If @error Then Return SetError(1, 0, 1)
	Return $aCall[0]
EndFunc   ;==>_AutoItObject_VariantCopy

; #FUNCTION# ====================================================================================================================
; Name...........: _AutoItObject_VariantClear
; Description ...: Clears the value of a variant
; Syntax.........: _AutoItObject_VariantClear($pvarg)
; Parameters ....: $pvarg       - the VARIANT to clear
; Return values .: Success      - 0
;                  Failure      - nonzero
; Author ........: Prog@ndy
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........; @@MsdnLink@@ VariantClear
; Example .......;
; ===============================================================================================================================
Func _AutoItObject_VariantClear($pvarg)
	; Author: Prog@ndy
	Local $aCall = DllCall($gh_AU3Obj_oleautdll, "long", "VariantClear", "ptr", $pvarg)
	If @error Then Return SetError(1, 0, 1)
	Return $aCall[0]
EndFunc   ;==>_AutoItObject_VariantClear

; #FUNCTION# ====================================================================================================================
; Name...........: _AutoItObject_VariantFree
; Description ...: Frees a variant created by _AutoItObject_VariantSet
; Syntax.........: _AutoItObject_VariantFree($pvarg)
; Parameters ....: $pvarg       - the VARIANT to free
; Return values .: Success      - 0
;                  Failure      - nonzero
; Author ........: Prog@ndy
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........;
; Example .......;
; ===============================================================================================================================
Func _AutoItObject_VariantFree($pvarg)
	; Author: Prog@ndy
	Local $aCall = DllCall($gh_AU3Obj_oleautdll, "long", "VariantClear", "ptr", $pvarg)
	If @error Then Return SetError(1, 0, 1)
	If $aCall[0] = 0 Then __Au3Obj_CoTaskMemFree($pvarg)
	Return $aCall[0]
EndFunc   ;==>_AutoItObject_VariantFree


Func __Au3Obj_VariantInit($pvarg)
	; Author: Prog@ndy
	Local $aCall = DllCall($gh_AU3Obj_oleautdll, "long", "VariantInit", "ptr", $pvarg)
	If @error Then Return SetError(1, 0, 1)
	Return $aCall[0]
EndFunc   ;==>__Au3Obj_VariantInit
#endregion Variant
;--------------------------------------------------------------------------------------------------------------------------------------


;--------------------------------------------------------------------------------------------------------------------------------------
#region SafeArray
Func __Au3Obj_SafeArrayCreate($vType, $cDims, $rgsabound)
	; Author: Prog@ndy
	Local $aCall = DllCall($gh_AU3Obj_oleautdll, "ptr", "SafeArrayCreate", "dword", $vType, "uint", $cDims, 'ptr', $rgsabound)
	If @error Then Return SetError(1, 0, 0)
	Return $aCall[0]
EndFunc   ;==>__Au3Obj_SafeArrayCreate

Func __Au3Obj_SafeArrayDestroy($pSafeArray)
	; Author: Prog@ndy
	Local $aCall = DllCall($gh_AU3Obj_oleautdll, "int", "SafeArrayDestroy", "ptr", $pSafeArray)
	If @error Then Return SetError(1, 0, 1)
	Return $aCall[0]
EndFunc   ;==>__Au3Obj_SafeArrayDestroy

Func __Au3Obj_SafeArrayAccessData($pSafeArray, ByRef $pArrayData)
	; Author: Prog@ndy
	Local $aCall = DllCall($gh_AU3Obj_oleautdll, "int", "SafeArrayAccessData", "ptr", $pSafeArray, 'ptr*', 0)
	If @error Then Return SetError(1, 0, 1)
	$pArrayData = $aCall[2]
	Return $aCall[0]
EndFunc   ;==>__Au3Obj_SafeArrayAccessData

Func __Au3Obj_SafeArrayUnaccessData($pSafeArray)
	; Author: Prog@ndy
	Local $aCall = DllCall($gh_AU3Obj_oleautdll, "int", "SafeArrayUnaccessData", "ptr", $pSafeArray)
	If @error Then Return SetError(1, 0, 1)
	Return $aCall[0]
EndFunc   ;==>__Au3Obj_SafeArrayUnaccessData

Func __Au3Obj_SafeArrayGetUBound($pSafeArray, $iDim, ByRef $iBound)
	; Author: Prog@ndy
	Local $aCall = DllCall($gh_AU3Obj_oleautdll, "int", "SafeArrayGetUBound", "ptr", $pSafeArray, 'uint', $iDim, 'long*', 0)
	If @error Then Return SetError(1, 0, 1)
	$iBound = $aCall[3]
	Return $aCall[0]
EndFunc   ;==>__Au3Obj_SafeArrayGetUBound

Func __Au3Obj_SafeArrayGetLBound($pSafeArray, $iDim, ByRef $iBound)
	; Author: Prog@ndy
	Local $aCall = DllCall($gh_AU3Obj_oleautdll, "int", "SafeArrayGetLBound", "ptr", $pSafeArray, 'uint', $iDim, 'long*', 0)
	If @error Then Return SetError(1, 0, 1)
	$iBound = $aCall[3]
	Return $aCall[0]
EndFunc   ;==>__Au3Obj_SafeArrayGetLBound

Func __Au3Obj_SafeArrayGetDim($pSafeArray)
	Local $aResult = DllCall($gh_AU3Obj_oleautdll, "uint", "SafeArrayGetDim", "ptr", $pSafeArray)
	If @error Then Return SetError(1, 0, 0)
	Return $aResult[0]
EndFunc   ;==>__Au3Obj_SafeArrayGetDim

Func __Au3Obj_CreateSafeArrayVariant(ByRef Const $aArray)
	; Author: Prog@ndy
	Local $iDim = UBound($aArray, 0), $pData, $pSafeArray, $bound, $subBound, $tBound
	Switch $iDim
		Case 1
			$bound = UBound($aArray) - 1
			$tBound = DllStructCreate($__Au3Obj_tagSAFEARRAYBOUND)
			DllStructSetData($tBound, 1, $bound + 1)
			$pSafeArray = __Au3Obj_SafeArrayCreate($__Au3Obj_VT_VARIANT, 1, DllStructGetPtr($tBound))
			If 0 = __Au3Obj_SafeArrayAccessData($pSafeArray, $pData) Then
				For $i = 0 To $bound
					__Au3Obj_VariantInit($pData + $i * $__Au3Obj_tagVARIANT_SIZE)
					_AutoItObject_VariantSet($pData + $i * $__Au3Obj_tagVARIANT_SIZE, $aArray[$i])
				Next
				__Au3Obj_SafeArrayUnaccessData($pSafeArray)
			EndIf
			Return $pSafeArray
		Case 2
			$bound = UBound($aArray, 1) - 1
			$subBound = UBound($aArray, 2) - 1
			$tBound = DllStructCreate($__Au3Obj_tagSAFEARRAYBOUND & $__Au3Obj_tagSAFEARRAYBOUND)
			DllStructSetData($tBound, 3, $bound + 1)
			DllStructSetData($tBound, 1, $subBound + 1)
			$pSafeArray = __Au3Obj_SafeArrayCreate($__Au3Obj_VT_VARIANT, 2, DllStructGetPtr($tBound))
			If 0 = __Au3Obj_SafeArrayAccessData($pSafeArray, $pData) Then
				For $i = 0 To $bound
					For $j = 0 To $subBound
						__Au3Obj_VariantInit($pData + ($j + $i * ($subBound + 1)) * $__Au3Obj_tagVARIANT_SIZE)
						_AutoItObject_VariantSet($pData + ($j + $i * ($subBound + 1)) * $__Au3Obj_tagVARIANT_SIZE, $aArray[$i][$j])
					Next
				Next
				__Au3Obj_SafeArrayUnaccessData($pSafeArray)
			EndIf
			Return $pSafeArray
		Case Else
			Return 0
	EndSwitch
EndFunc   ;==>__Au3Obj_CreateSafeArrayVariant

Func __Au3Obj_ReadSafeArrayVariant($pSafeArray)
	; Author: Prog@ndy
	Local $iDim = __Au3Obj_SafeArrayGetDim($pSafeArray), $pData, $lbound, $bound, $subBound
	Switch $iDim
		Case 1
			__Au3Obj_SafeArrayGetLBound($pSafeArray, 1, $lbound)
			__Au3Obj_SafeArrayGetUBound($pSafeArray, 1, $bound)
			$bound -= $lbound
			Local $array[$bound + 1]
			If 0 = __Au3Obj_SafeArrayAccessData($pSafeArray, $pData) Then
				For $i = 0 To $bound
					$array[$i] = _AutoItObject_VariantRead($pData + $i * $__Au3Obj_tagVARIANT_SIZE)
				Next
				__Au3Obj_SafeArrayUnaccessData($pSafeArray)
			EndIf
			Return $array
		Case 2
			__Au3Obj_SafeArrayGetLBound($pSafeArray, 2, $lbound)
			__Au3Obj_SafeArrayGetUBound($pSafeArray, 2, $bound)
			$bound -= $lbound
			__Au3Obj_SafeArrayGetLBound($pSafeArray, 1, $lbound)
			__Au3Obj_SafeArrayGetUBound($pSafeArray, 1, $subBound)
			$subBound -= $lbound
			Local $array[$bound + 1][$subBound + 1]
			If 0 = __Au3Obj_SafeArrayAccessData($pSafeArray, $pData) Then
				For $i = 0 To $bound
					For $j = 0 To $subBound
						$array[$i][$j] = _AutoItObject_VariantRead($pData + ($j + $i * ($subBound + 1)) * $__Au3Obj_tagVARIANT_SIZE)
					Next
				Next
				__Au3Obj_SafeArrayUnaccessData($pSafeArray)
			EndIf
			Return $array
		Case Else
			Return 0
	EndSwitch
EndFunc   ;==>__Au3Obj_ReadSafeArrayVariant

#endregion SafeArray
;--------------------------------------------------------------------------------------------------------------------------------------


;--------------------------------------------------------------------------------------------------------------------------------------
#region Memory

Func __Au3Obj_CoTaskMemAlloc($iSize)
	; Author: Prog@ndy
	Local $aCall = DllCall($gh_AU3Obj_ole32dll, "ptr", "CoTaskMemAlloc", "uint_ptr", $iSize)
	If @error Then Return SetError(1, 0, 0)
	Return $aCall[0]
EndFunc   ;==>__Au3Obj_CoTaskMemAlloc

Func __Au3Obj_CoTaskMemFree($pCoMem)
	; Author: Prog@ndy
	DllCall($gh_AU3Obj_ole32dll, "none", "CoTaskMemFree", "ptr", $pCoMem)
	If @error Then Return SetError(1, 0, 0)
EndFunc   ;==>__Au3Obj_CoTaskMemFree

Func __Au3Obj_CoTaskMemRealloc($pCoMem, $iSize)
	; Author: Prog@ndy
	Local $aCall = DllCall($gh_AU3Obj_ole32dll, "ptr", "CoTaskMemRealloc", 'ptr', $pCoMem, "uint_ptr", $iSize)
	If @error Then Return SetError(1, 0, 0)
	Return $aCall[0]
EndFunc   ;==>__Au3Obj_CoTaskMemRealloc

Func __Au3Obj_GlobalAlloc($iSize, $iFlag)
	Local $aCall = DllCall($gh_AU3Obj_kernel32dll, "ptr", "GlobalAlloc", "dword", $iFlag, "dword_ptr", $iSize)
	If @error Or Not $aCall[0] Then Return SetError(1, 0, 0)
	Return $aCall[0]
EndFunc   ;==>__Au3Obj_GlobalAlloc

Func __Au3Obj_GlobalFree($pPointer)
	Local $aCall = DllCall($gh_AU3Obj_kernel32dll, "ptr", "GlobalFree", "ptr", $pPointer)
	If @error Or $aCall[0] Then Return SetError(1, 0, 0)
	Return 1
EndFunc   ;==>__Au3Obj_GlobalFree

#endregion Memory
;--------------------------------------------------------------------------------------------------------------------------------------


;--------------------------------------------------------------------------------------------------------------------------------------
#region SysString

Func __Au3Obj_SysAllocString($str)
	; Author: monoceres
	Local $aCall = DllCall($gh_AU3Obj_oleautdll, "ptr", "SysAllocString", "wstr", $str)
	If @error Then Return SetError(1, 0, 0)
	Return $aCall[0]
EndFunc   ;==>__Au3Obj_SysAllocString
Func __Au3Obj_SysCopyString($pBSTR)
	; Author: Prog@ndy
	If Not $pBSTR Then Return SetError(2, 0, 0)
	Local $aCall = DllCall($gh_AU3Obj_oleautdll, "ptr", "SysAllocStringLen", "ptr", $pBSTR, "uint", __Au3Obj_SysStringLen($pBSTR))
	If @error Then Return SetError(1, 0, 0)
	Return $aCall[0]
EndFunc   ;==>__Au3Obj_SysCopyString

Func __Au3Obj_SysReAllocString(ByRef $pBSTR, $str)
	; Author: Prog@ndy
	If Not $pBSTR Then Return SetError(2, 0, 0)
	Local $aCall = DllCall($gh_AU3Obj_oleautdll, "int", "SysReAllocString", 'ptr*', $pBSTR, "wstr", $str)
	If @error Then Return SetError(1, 0, 0)
	$pBSTR = $aCall[1]
	Return $aCall[0]
EndFunc   ;==>__Au3Obj_SysReAllocString

Func __Au3Obj_SysFreeString($pBSTR)
	; Author: Prog@ndy
	If Not $pBSTR Then Return SetError(2, 0, 0)
	DllCall($gh_AU3Obj_oleautdll, "none", "SysFreeString", "ptr", $pBSTR)
	If @error Then Return SetError(1, 0, 0)
EndFunc   ;==>__Au3Obj_SysFreeString

Func __Au3Obj_SysStringLen($pBSTR)
	; Author: Prog@ndy
	If Not $pBSTR Then Return SetError(2, 0, 0)
	Local $aCall = DllCall($gh_AU3Obj_oleautdll, "uint", "SysStringLen", "ptr", $pBSTR)
	If @error Then Return SetError(1, 0, 0)
	Return $aCall[0]
EndFunc   ;==>__Au3Obj_SysStringLen

Func __Au3Obj_SysReadString($pBSTR, $iLen = -1)
	; Author: Prog@ndy
	If Not $pBSTR Then Return SetError(2, 0, '')
	If $iLen < 1 Then $iLen = __Au3Obj_SysStringLen($pBSTR)
	If $iLen < 1 Then Return SetError(1, 0, '')
	Return DllStructGetData(DllStructCreate("wchar[" & $iLen & "]", $pBSTR), 1)
EndFunc   ;==>__Au3Obj_SysReadString

Func __Au3Obj_PtrStringLen($pStr)
	; Author: Prog@ndy
	Local $aResult = DllCall($gh_AU3Obj_kernel32dll, 'int', 'lstrlenW', 'ptr', $pStr)
	If @error Then Return SetError(1, 0, 0)
	Return $aResult[0]
EndFunc   ;==>__Au3Obj_PtrStringLen

Func __Au3Obj_PtrStringRead($pStr, $iLen = -1)
	; Author: Prog@ndy
	If $iLen < 1 Then $iLen = __Au3Obj_PtrStringLen($pStr)
	If $iLen < 1 Then Return SetError(1, 0, '')
	Return DllStructGetData(DllStructCreate("wchar[" & $iLen & "]", $pStr), 1)
EndFunc   ;==>__Au3Obj_PtrStringRead

#endregion SysString
;--------------------------------------------------------------------------------------------------------------------------------------


;--------------------------------------------------------------------------------------------------------------------------------------
#region Proxy Functions

Func __Au3Obj_FunctionProxy($FuncName, $oSelf) ; allows binary code to call autoit functions
	Local $arg = $oSelf.__params__ ; fetch params, first two entries are empty.
	$arg[0] = "CallArgArray" ; first entry for CallArgArray
	$arg[1] = $oSelf ; Second entry for object
	Local $ret = Call($FuncName, $arg) ; Call
	If @error = 0xDEAD And @extended = 0xBEEF Then Return 0
	$oSelf.__error__ = @error ; set error
	$oSelf.__result__ = $ret ; set result
	Return 1
EndFunc   ;==>__Au3Obj_FunctionProxy

Func __Au3Obj_WrapFunctionProxy($FuncPtr, $pObject, $sVarTypes, $oSelf, $ArgCount, $pVarResult)
	#forceref $pVarResult
	; Author: Prog@ndy
	Local $aArgs
	If $sVarTypes Then
		$sVarTypes = StringSplit($sVarTypes, ";", 2)
		If (UBound($sVarTypes) - 1) <> $ArgCount Then Return False
		$aArgs = $oSelf.__params__
		$aArgs[0] = "CallArgArray"
		$aArgs[1] = $sVarTypes[0]
		$aArgs[2] = $FuncPtr
		$aArgs[3] = 'ptr'
		$aArgs[4] = $pObject
		If $ArgCount Then
			; Fetch all arguments
			$ArgCount -= 1
			For $i = 0 To $ArgCount
				; Save the values backwards (that's how COM does it)
				$aArgs[5 + ($ArgCount - $i) * 2] = $sVarTypes[$i + 1]
			Next
		EndIf
	Else ; paramtypes have to given as parameters, return type is first param
		If Mod($ArgCount, 2) <> 1 Then Return False
		$aArgs = $oSelf.__params__
		$aArgs[0] = "CallArgArray"
		$aArgs[1] = $aArgs[4]
		$aArgs[2] = $FuncPtr
		$aArgs[3] = 'ptr'
		$aArgs[4] = $pObject
	EndIf
	Local $ret = Call("__Au3Obj_PointerCall", $aArgs)
	For $i = 0 To UBound($ret) - 1
		If IsPtr($ret[$i]) Then $ret[$i] = Number($ret[$i])
	Next
	$oSelf.__result__ = $ret
	Return True
EndFunc   ;==>__Au3Obj_WrapFunctionProxy

Func __Au3Obj_EnumFunctionProxy($iAction, $FuncName, $oSelf, $pVarCurrent, $pVarResult)
	Local $Current, $ret
	Switch $iAction
		Case 0 ; Next
			$Current = $oSelf.__bridge__(Number($pVarCurrent))
			$ret = Execute($FuncName & "($oSelf, $Current)")
			If @error Then Return False
			$oSelf.__bridge__(Number($pVarCurrent)) = $Current
			$oSelf.__bridge__(Number($pVarResult)) = $ret
			Return 1
		Case 1 ;Skip
			Return False
		Case 2 ; Reset
			$Current = $oSelf.__bridge__(Number($pVarCurrent))
			$ret = Execute($FuncName & "($oSelf, $Current)")
			If @error Or Not $ret Then Return False
			$oSelf.__bridge__(Number($pVarCurrent)) = $Current
			Return True
	EndSwitch
EndFunc   ;==>__Au3Obj_EnumFunctionProxy

#endregion Proxy Functions
;--------------------------------------------------------------------------------------------------------------------------------------


;--------------------------------------------------------------------------------------------------------------------------------------
#region Call Pointer

Func __Au3Obj_PointerCall($sRetType, $pAddress, $sType1 = "", $vParam1 = 0, $sType2 = "", $vParam2 = 0, $sType3 = "", $vParam3 = 0, $sType4 = "", $vParam4 = 0, $sType5 = "", $vParam5 = 0, $sType6 = "", $vParam6 = 0, $sType7 = "", $vParam7 = 0, $sType8 = "", $vParam8 = 0, $sType9 = "", $vParam9 = 0, $sType10 = "", $vParam10 = 0, $sType11 = "", $vParam11 = 0, $sType12 = "", $vParam12 = 0, $sType13 = "", $vParam13 = 0, $sType14 = "", $vParam14 = 0, $sType15 = "", $vParam15 = 0, $sType16 = "", $vParam16 = 0, $sType17 = "", $vParam17 = 0, $sType18 = "", $vParam18 = 0, $sType19 = "", $vParam19 = 0, $sType20 = "", $vParam20 = 0)
	; Author: Ward, Prog@ndy, trancexx
	Local Static $pHook, $hPseudo, $tPtr, $sFuncName = "MemoryCallEntry"
	If $pAddress Then
		If Not $pHook Then
			Local $sDll = "AutoItObject.dll"
			If $__Au3Obj_X64 Then $sDll = "AutoItObject_X64.dll"
			$hPseudo = DllOpen($sDll)
			If $hPseudo = -1 Then
				$sDll = "kernel32.dll"
				$sFuncName = "GlobalFix"
				$hPseudo = DllOpen($sDll)
			EndIf
			Local $aCall = DllCall($gh_AU3Obj_kernel32dll, "ptr", "GetModuleHandleW", "wstr", $sDll)
			If @error Or Not $aCall[0] Then Return SetError(7, @error, 0) ; Couldn't get dll handle
			Local $hModuleHandle = $aCall[0]
			$aCall = DllCall($gh_AU3Obj_kernel32dll, "ptr", "GetProcAddress", "ptr", $hModuleHandle, "str", $sFuncName)
			If @error Then Return SetError(8, @error, 0) ; Wanted function not found
			$pHook = $aCall[0]
			$aCall = DllCall($gh_AU3Obj_kernel32dll, "bool", "VirtualProtect", "ptr", $pHook, "dword", 7 + 5 * $__Au3Obj_X64, "dword", 64, "dword*", 0)
			If @error Or Not $aCall[0] Then Return SetError(9, @error, 0) ; Unable to set MEM_EXECUTE_READWRITE
			If $__Au3Obj_X64 Then
				DllStructSetData(DllStructCreate("word", $pHook), 1, 0xB848)
				DllStructSetData(DllStructCreate("word", $pHook + 10), 1, 0xE0FF)
			Else
				DllStructSetData(DllStructCreate("byte", $pHook), 1, 0xB8)
				DllStructSetData(DllStructCreate("word", $pHook + 5), 1, 0xE0FF)
			EndIf
			$tPtr = DllStructCreate("ptr", $pHook + 1 + $__Au3Obj_X64)
		EndIf
		DllStructSetData($tPtr, 1, $pAddress)
		Local $aRet
		Switch @NumParams
			Case 2
				$aRet = DllCall($hPseudo, $sRetType, $sFuncName)
			Case 4
				$aRet = DllCall($hPseudo, $sRetType, $sFuncName, $sType1, $vParam1)
			Case 6
				$aRet = DllCall($hPseudo, $sRetType, $sFuncName, $sType1, $vParam1, $sType2, $vParam2)
			Case 8
				$aRet = DllCall($hPseudo, $sRetType, $sFuncName, $sType1, $vParam1, $sType2, $vParam2, $sType3, $vParam3)
			Case 10
				$aRet = DllCall($hPseudo, $sRetType, $sFuncName, $sType1, $vParam1, $sType2, $vParam2, $sType3, $vParam3, $sType4, $vParam4)
			Case 12
				$aRet = DllCall($hPseudo, $sRetType, $sFuncName, $sType1, $vParam1, $sType2, $vParam2, $sType3, $vParam3, $sType4, $vParam4, $sType5, $vParam5)
			Case 14
				$aRet = DllCall($hPseudo, $sRetType, $sFuncName, $sType1, $vParam1, $sType2, $vParam2, $sType3, $vParam3, $sType4, $vParam4, $sType5, $vParam5, $sType6, $vParam6)
			Case 16
				$aRet = DllCall($hPseudo, $sRetType, $sFuncName, $sType1, $vParam1, $sType2, $vParam2, $sType3, $vParam3, $sType4, $vParam4, $sType5, $vParam5, $sType6, $vParam6, $sType7, $vParam7)
			Case 18
				$aRet = DllCall($hPseudo, $sRetType, $sFuncName, $sType1, $vParam1, $sType2, $vParam2, $sType3, $vParam3, $sType4, $vParam4, $sType5, $vParam5, $sType6, $vParam6, $sType7, $vParam7, $sType8, $vParam8)
			Case 20
				$aRet = DllCall($hPseudo, $sRetType, $sFuncName, $sType1, $vParam1, $sType2, $vParam2, $sType3, $vParam3, $sType4, $vParam4, $sType5, $vParam5, $sType6, $vParam6, $sType7, $vParam7, $sType8, $vParam8, $sType9, $vParam9)
			Case 22
				$aRet = DllCall($hPseudo, $sRetType, $sFuncName, $sType1, $vParam1, $sType2, $vParam2, $sType3, $vParam3, $sType4, $vParam4, $sType5, $vParam5, $sType6, $vParam6, $sType7, $vParam7, $sType8, $vParam8, $sType9, $vParam9, $sType10, $vParam10)
			Case 24
				$aRet = DllCall($hPseudo, $sRetType, $sFuncName, $sType1, $vParam1, $sType2, $vParam2, $sType3, $vParam3, $sType4, $vParam4, $sType5, $vParam5, $sType6, $vParam6, $sType7, $vParam7, $sType8, $vParam8, $sType9, $vParam9, $sType10, $vParam10, $sType11, $vParam11)
			Case 26
				$aRet = DllCall($hPseudo, $sRetType, $sFuncName, $sType1, $vParam1, $sType2, $vParam2, $sType3, $vParam3, $sType4, $vParam4, $sType5, $vParam5, $sType6, $vParam6, $sType7, $vParam7, $sType8, $vParam8, $sType9, $vParam9, $sType10, $vParam10, $sType11, $vParam11, $sType12, $vParam12)
			Case 28
				$aRet = DllCall($hPseudo, $sRetType, $sFuncName, $sType1, $vParam1, $sType2, $vParam2, $sType3, $vParam3, $sType4, $vParam4, $sType5, $vParam5, $sType6, $vParam6, $sType7, $vParam7, $sType8, $vParam8, $sType9, $vParam9, $sType10, $vParam10, $sType11, $vParam11, $sType12, $vParam12, $sType13, $vParam13)
			Case 30
				$aRet = DllCall($hPseudo, $sRetType, $sFuncName, $sType1, $vParam1, $sType2, $vParam2, $sType3, $vParam3, $sType4, $vParam4, $sType5, $vParam5, $sType6, $vParam6, $sType7, $vParam7, $sType8, $vParam8, $sType9, $vParam9, $sType10, $vParam10, $sType11, $vParam11, $sType12, $vParam12, $sType13, $vParam13, $sType14, $vParam14)
			Case 32
				$aRet = DllCall($hPseudo, $sRetType, $sFuncName, $sType1, $vParam1, $sType2, $vParam2, $sType3, $vParam3, $sType4, $vParam4, $sType5, $vParam5, $sType6, $vParam6, $sType7, $vParam7, $sType8, $vParam8, $sType9, $vParam9, $sType10, $vParam10, $sType11, $vParam11, $sType12, $vParam12, $sType13, $vParam13, $sType14, $vParam14, $sType15, $vParam15)
			Case 34
				$aRet = DllCall($hPseudo, $sRetType, $sFuncName, $sType1, $vParam1, $sType2, $vParam2, $sType3, $vParam3, $sType4, $vParam4, $sType5, $vParam5, $sType6, $vParam6, $sType7, $vParam7, $sType8, $vParam8, $sType9, $vParam9, $sType10, $vParam10, $sType11, $vParam11, $sType12, $vParam12, $sType13, $vParam13, $sType14, $vParam14, $sType15, $vParam15, $sType16, $vParam16)
			Case 36
				$aRet = DllCall($hPseudo, $sRetType, $sFuncName, $sType1, $vParam1, $sType2, $vParam2, $sType3, $vParam3, $sType4, $vParam4, $sType5, $vParam5, $sType6, $vParam6, $sType7, $vParam7, $sType8, $vParam8, $sType9, $vParam9, $sType10, $vParam10, $sType11, $vParam11, $sType12, $vParam12, $sType13, $vParam13, $sType14, $vParam14, $sType15, $vParam15, $sType16, $vParam16, $sType17, $vParam17)
			Case 38
				$aRet = DllCall($hPseudo, $sRetType, $sFuncName, $sType1, $vParam1, $sType2, $vParam2, $sType3, $vParam3, $sType4, $vParam4, $sType5, $vParam5, $sType6, $vParam6, $sType7, $vParam7, $sType8, $vParam8, $sType9, $vParam9, $sType10, $vParam10, $sType11, $vParam11, $sType12, $vParam12, $sType13, $vParam13, $sType14, $vParam14, $sType15, $vParam15, $sType16, $vParam16, $sType17, $vParam17, $sType18, $vParam18)
			Case 40
				$aRet = DllCall($hPseudo, $sRetType, $sFuncName, $sType1, $vParam1, $sType2, $vParam2, $sType3, $vParam3, $sType4, $vParam4, $sType5, $vParam5, $sType6, $vParam6, $sType7, $vParam7, $sType8, $vParam8, $sType9, $vParam9, $sType10, $vParam10, $sType11, $vParam11, $sType12, $vParam12, $sType13, $vParam13, $sType14, $vParam14, $sType15, $vParam15, $sType16, $vParam16, $sType17, $vParam17, $sType18, $vParam18, $sType19, $vParam19)
			Case 42
				$aRet = DllCall($hPseudo, $sRetType, $sFuncName, $sType1, $vParam1, $sType2, $vParam2, $sType3, $vParam3, $sType4, $vParam4, $sType5, $vParam5, $sType6, $vParam6, $sType7, $vParam7, $sType8, $vParam8, $sType9, $vParam9, $sType10, $vParam10, $sType11, $vParam11, $sType12, $vParam12, $sType13, $vParam13, $sType14, $vParam14, $sType15, $vParam15, $sType16, $vParam16, $sType17, $vParam17, $sType18, $vParam18, $sType19, $vParam19, $sType20, $vParam20)
			Case Else
				If Mod(@NumParams, 2) Then Return SetError(4, 0, 0) ; Bad number of parameters
				Return SetError(5, 0, 0) ; Max number of parameters exceeded
		EndSwitch
		Return SetError(@error, @extended, $aRet) ; All went well. Error description and return values like with DllCall()
	EndIf
	Return SetError(6, 0, 0) ; Null address specified
EndFunc   ;==>__Au3Obj_PointerCall

#endregion Call Pointer
;--------------------------------------------------------------------------------------------------------------------------------------


;--------------------------------------------------------------------------------------------------------------------------------------
#region Embedded DLL

Func __Au3Obj_Mem_DllOpen($bBinaryImage = 0, $sSubrogor = "cmd.exe")
	If Not $bBinaryImage Then
		If $__Au3Obj_X64 Then
			$bBinaryImage = __Au3Obj_Mem_BinDll_X64()
		Else
			$bBinaryImage = __Au3Obj_Mem_BinDll()
		EndIf
	EndIf
	; Make structure out of binary data that was passed
	Local $tBinary = DllStructCreate("byte[" & BinaryLen($bBinaryImage) & "]")
	DllStructSetData($tBinary, 1, $bBinaryImage) ; fill the structure
	; Get pointer to it
	Local $pPointer = DllStructGetPtr($tBinary)
	; Start processing passed binary data. 'Reading' PE format follows.
	Local $tIMAGE_DOS_HEADER = DllStructCreate("char Magic[2];" & _
			"word BytesOnLastPage;" & _
			"word Pages;" & _
			"word Relocations;" & _
			"word SizeofHeader;" & _
			"word MinimumExtra;" & _
			"word MaximumExtra;" & _
			"word SS;" & _
			"word SP;" & _
			"word Checksum;" & _
			"word IP;" & _
			"word CS;" & _
			"word Relocation;" & _
			"word Overlay;" & _
			"char Reserved[8];" & _
			"word OEMIdentifier;" & _
			"word OEMInformation;" & _
			"char Reserved2[20];" & _
			"dword AddressOfNewExeHeader", _
			$pPointer)
	; Move pointer
	$pPointer += DllStructGetData($tIMAGE_DOS_HEADER, "AddressOfNewExeHeader") ; move to PE file header
	$pPointer += 4 ; size of skipped $tIMAGE_NT_SIGNATURE structure
	; In place of IMAGE_FILE_HEADER structure
	Local $tIMAGE_FILE_HEADER = DllStructCreate("word Machine;" & _
			"word NumberOfSections;" & _
			"dword TimeDateStamp;" & _
			"dword PointerToSymbolTable;" & _
			"dword NumberOfSymbols;" & _
			"word SizeOfOptionalHeader;" & _
			"word Characteristics", _
			$pPointer)
	; Get number of sections
	Local $iNumberOfSections = DllStructGetData($tIMAGE_FILE_HEADER, "NumberOfSections")
	; Move pointer
	$pPointer += 20 ; size of $tIMAGE_FILE_HEADER structure
	; Determine the type
	Local $tMagic = DllStructCreate("word Magic;", $pPointer)
	Local $iMagic = DllStructGetData($tMagic, 1)
	Local $tIMAGE_OPTIONAL_HEADER
	If $iMagic = 267 Then ; x86 version
		If $__Au3Obj_X64 Then Return SetError(1, 0, -1) ; incompatible versions
		$tIMAGE_OPTIONAL_HEADER = DllStructCreate("word Magic;" & _
				"byte MajorLinkerVersion;" & _
				"byte MinorLinkerVersion;" & _
				"dword SizeOfCode;" & _
				"dword SizeOfInitializedData;" & _
				"dword SizeOfUninitializedData;" & _
				"dword AddressOfEntryPoint;" & _
				"dword BaseOfCode;" & _
				"dword BaseOfData;" & _
				"dword ImageBase;" & _
				"dword SectionAlignment;" & _
				"dword FileAlignment;" & _
				"word MajorOperatingSystemVersion;" & _
				"word MinorOperatingSystemVersion;" & _
				"word MajorImageVersion;" & _
				"word MinorImageVersion;" & _
				"word MajorSubsystemVersion;" & _
				"word MinorSubsystemVersion;" & _
				"dword Win32VersionValue;" & _
				"dword SizeOfImage;" & _
				"dword SizeOfHeaders;" & _
				"dword CheckSum;" & _
				"word Subsystem;" & _
				"word DllCharacteristics;" & _
				"dword SizeOfStackReserve;" & _
				"dword SizeOfStackCommit;" & _
				"dword SizeOfHeapReserve;" & _
				"dword SizeOfHeapCommit;" & _
				"dword LoaderFlags;" & _
				"dword NumberOfRvaAndSizes", _
				$pPointer)
		; Move pointer
		$pPointer += 96 ; size of $tIMAGE_OPTIONAL_HEADER
	ElseIf $iMagic = 523 Then ; x64 version
		If Not $__Au3Obj_X64 Then Return SetError(1, 0, -1) ; incompatible versions
		$tIMAGE_OPTIONAL_HEADER = DllStructCreate("word Magic;" & _
				"byte MajorLinkerVersion;" & _
				"byte MinorLinkerVersion;" & _
				"dword SizeOfCode;" & _
				"dword SizeOfInitializedData;" & _
				"dword SizeOfUninitializedData;" & _
				"dword AddressOfEntryPoint;" & _
				"dword BaseOfCode;" & _
				"uint64 ImageBase;" & _
				"dword SectionAlignment;" & _
				"dword FileAlignment;" & _
				"word MajorOperatingSystemVersion;" & _
				"word MinorOperatingSystemVersion;" & _
				"word MajorImageVersion;" & _
				"word MinorImageVersion;" & _
				"word MajorSubsystemVersion;" & _
				"word MinorSubsystemVersion;" & _
				"dword Win32VersionValue;" & _
				"dword SizeOfImage;" & _
				"dword SizeOfHeaders;" & _
				"dword CheckSum;" & _
				"word Subsystem;" & _
				"word DllCharacteristics;" & _
				"uint64 SizeOfStackReserve;" & _
				"uint64 SizeOfStackCommit;" & _
				"uint64 SizeOfHeapReserve;" & _
				"uint64 SizeOfHeapCommit;" & _
				"dword LoaderFlags;" & _
				"dword NumberOfRvaAndSizes", _
				$pPointer)
		; Move pointer
		$pPointer += 112 ; size of $tIMAGE_OPTIONAL_HEADER
	Else
		Return SetError(1, 0, -1) ; incompatible versions
	EndIf
	; Extract data
	Local $iEntryPoint = DllStructGetData($tIMAGE_OPTIONAL_HEADER, "AddressOfEntryPoint") ; if loaded binary image would start executing at this address
	Local $pOptionalHeaderImageBase = DllStructGetData($tIMAGE_OPTIONAL_HEADER, "ImageBase") ; address of the first byte of the image when it's loaded in memory
	$pPointer += 8 ; skipping IMAGE_DIRECTORY_ENTRY_EXPORT
	; Import Directory
	Local $tIMAGE_DIRECTORY_ENTRY_IMPORT = DllStructCreate("dword VirtualAddress; dword Size", $pPointer)
	; Collect data
	Local $pAddressImport = DllStructGetData($tIMAGE_DIRECTORY_ENTRY_IMPORT, "VirtualAddress")
	Local $iSizeImport = DllStructGetData($tIMAGE_DIRECTORY_ENTRY_IMPORT, "Size")
	$pPointer += 8 ; size of $tIMAGE_DIRECTORY_ENTRY_IMPORT
	$pPointer += 24 ; skipping IMAGE_DIRECTORY_ENTRY_RESOURCE, IMAGE_DIRECTORY_ENTRY_EXCEPTION, IMAGE_DIRECTORY_ENTRY_SECURITY
	; Base Relocation Directory
	Local $tIMAGE_DIRECTORY_ENTRY_BASERELOC = DllStructCreate("dword VirtualAddress; dword Size", $pPointer)
	; Collect data
	Local $pAddressNewBaseReloc = DllStructGetData($tIMAGE_DIRECTORY_ENTRY_BASERELOC, "VirtualAddress")
	Local $iSizeBaseReloc = DllStructGetData($tIMAGE_DIRECTORY_ENTRY_BASERELOC, "Size")
	$pPointer += 8 ; size of IMAGE_DIRECTORY_ENTRY_BASERELOC
	$pPointer += 40 ; skipping IMAGE_DIRECTORY_ENTRY_DEBUG, IMAGE_DIRECTORY_ENTRY_COPYRIGHT, IMAGE_DIRECTORY_ENTRY_GLOBALPTR, IMAGE_DIRECTORY_ENTRY_TLS, IMAGE_DIRECTORY_ENTRY_LOAD_CONFIG
	$pPointer += 40 ; five more generally unused data directories
	; Load the victim
	Local $pBaseAddress = __Au3Obj_Mem_LoadLibraryEx($sSubrogor, 1) ; "lighter" loading, DONT_RESOLVE_DLL_REFERENCES
	If @error Then
		Return SetError(2, 0, -1) ; Couldn't load subrogor
	EndIf
	Local $pHeadersNew = DllStructGetPtr($tIMAGE_DOS_HEADER) ; starting address of binary image headers
	Local $iOptionalHeaderSizeOfHeaders = DllStructGetData($tIMAGE_OPTIONAL_HEADER, "SizeOfHeaders") ; the size of the MS-DOS stub, the PE header, and the section headers
	; Set proper memory protection for writting headers (PAGE_READWRITE)
	If Not __Au3Obj_Mem_VirtualProtect($pBaseAddress, $iOptionalHeaderSizeOfHeaders, 4) Then Return SetError(3, 0, -1) ; Couldn't set proper protection for headers
	; Write NEW headers
	DllStructSetData(DllStructCreate("byte[" & $iOptionalHeaderSizeOfHeaders & "]", $pBaseAddress), 1, DllStructGetData(DllStructCreate("byte[" & $iOptionalHeaderSizeOfHeaders & "]", $pHeadersNew), 1))
	; Dealing with sections. Will write them.
	Local $tIMAGE_SECTION_HEADER
	Local $iSizeOfRawData, $pPointerToRawData
	Local $iVirtualSize, $iVirtualAddress
	Local $tImpRaw, $tRelocRaw
	For $i = 1 To $iNumberOfSections
		$tIMAGE_SECTION_HEADER = DllStructCreate("char Name[8];" & _
				"dword UnionOfVirtualSizeAndPhysicalAddress;" & _
				"dword VirtualAddress;" & _
				"dword SizeOfRawData;" & _
				"dword PointerToRawData;" & _
				"dword PointerToRelocations;" & _
				"dword PointerToLinenumbers;" & _
				"word NumberOfRelocations;" & _
				"word NumberOfLinenumbers;" & _
				"dword Characteristics", _
				$pPointer)
		; Collect data
		$iSizeOfRawData = DllStructGetData($tIMAGE_SECTION_HEADER, "SizeOfRawData")
		$pPointerToRawData = $pHeadersNew + DllStructGetData($tIMAGE_SECTION_HEADER, "PointerToRawData")
		$iVirtualAddress = DllStructGetData($tIMAGE_SECTION_HEADER, "VirtualAddress")
		$iVirtualSize = DllStructGetData($tIMAGE_SECTION_HEADER, "UnionOfVirtualSizeAndPhysicalAddress")
		If $iVirtualSize And $iVirtualSize < $iSizeOfRawData Then $iSizeOfRawData = $iVirtualSize
		; Set MEM_EXECUTE_READWRITE for sections (PAGE_EXECUTE_READWRITE for all for simplicity)
		If Not __Au3Obj_Mem_VirtualProtect($pBaseAddress + $iVirtualAddress, $iVirtualSize, 64) Then
			$pPointer += 40 ; size of $tIMAGE_SECTION_HEADER structure
			ContinueLoop
		EndIf
		; Clean the space
		DllStructSetData(DllStructCreate("byte[" & $iVirtualSize & "]", $pBaseAddress + $iVirtualAddress), 1, DllStructGetData(DllStructCreate("byte[" & $iVirtualSize & "]"), 1))
		; If there is data to write, write it
		If $iSizeOfRawData Then
			DllStructSetData(DllStructCreate("byte[" & $iSizeOfRawData & "]", $pBaseAddress + $iVirtualAddress), 1, DllStructGetData(DllStructCreate("byte[" & $iSizeOfRawData & "]", $pPointerToRawData), 1))
		EndIf
		; Relocations
		If $iVirtualAddress <= $pAddressNewBaseReloc And $iVirtualAddress + $iSizeOfRawData > $pAddressNewBaseReloc Then
			$tRelocRaw = DllStructCreate("byte[" & $iSizeBaseReloc & "]", $pPointerToRawData + ($pAddressNewBaseReloc - $iVirtualAddress))
		EndIf
		; Imports
		If $iVirtualAddress <= $pAddressImport And $iVirtualAddress + $iSizeOfRawData > $pAddressImport Then
			$tImpRaw = DllStructCreate("byte[" & $iSizeImport & "]", $pPointerToRawData + ($pAddressImport - $iVirtualAddress))
			__Au3Obj_Mem_FixImports($tImpRaw, $pBaseAddress) ; fix imports in place
		EndIf
		; Move pointer
		$pPointer += 40 ; size of $tIMAGE_SECTION_HEADER structure
	Next
	; Fix relocations
	If $pAddressNewBaseReloc And $iSizeBaseReloc Then __Au3Obj_Mem_FixReloc($tRelocRaw, $pBaseAddress, $pOptionalHeaderImageBase, $iMagic = 523)
	; Entry point address
	Local $pEntryFunc = $pBaseAddress + $iEntryPoint
	; DllMain simulation
	__Au3Obj_PointerCall("bool", $pEntryFunc, "ptr", $pBaseAddress, "dword", 1, "ptr", 0) ; DLL_PROCESS_ATTACH
	; Get pseudo-handle
	Local $hPseudo = DllOpen($sSubrogor)
	__Au3Obj_Mem_FreeLibrary($pBaseAddress) ; decrement reference count
	Return $hPseudo
EndFunc   ;==>__Au3Obj_Mem_DllOpen

Func __Au3Obj_Mem_FixReloc($tData, $pAddressNew, $pAddressOld, $fImageX64)
	Local $iDelta = $pAddressNew - $pAddressOld ; dislocation value
	Local $iSize = DllStructGetSize($tData) ; size of data
	Local $pData = DllStructGetPtr($tData) ; addres of the data structure
	Local $tIMAGE_BASE_RELOCATION, $iRelativeMove
	Local $iVirtualAddress, $iSizeofBlock, $iNumberOfEntries
	Local $tEnries, $iData, $tAddress
	Local $iFlag = 3 + 7 * $fImageX64 ; IMAGE_REL_BASED_HIGHLOW = 3 or IMAGE_REL_BASED_DIR64 = 10
	While $iRelativeMove < $iSize ; for all data available
		$tIMAGE_BASE_RELOCATION = DllStructCreate("dword VirtualAddress; dword SizeOfBlock", $pData + $iRelativeMove)
		$iVirtualAddress = DllStructGetData($tIMAGE_BASE_RELOCATION, "VirtualAddress")
		$iSizeofBlock = DllStructGetData($tIMAGE_BASE_RELOCATION, "SizeOfBlock")
		$iNumberOfEntries = ($iSizeofBlock - 8) / 2
		$tEnries = DllStructCreate("word[" & $iNumberOfEntries & "]", DllStructGetPtr($tIMAGE_BASE_RELOCATION) + 8)
		; Go through all entries
		For $i = 1 To $iNumberOfEntries
			$iData = DllStructGetData($tEnries, 1, $i)
			If BitShift($iData, 12) = $iFlag Then ; check type
				$tAddress = DllStructCreate("ptr", $pAddressNew + $iVirtualAddress + BitAND($iData, 0xFFF)) ; the rest of $iData is offset
				DllStructSetData($tAddress, 1, DllStructGetData($tAddress, 1) + $iDelta) ; this is what's this all about
			EndIf
		Next
		$iRelativeMove += $iSizeofBlock
	WEnd
	Return 1 ; all OK!
EndFunc   ;==>__Au3Obj_Mem_FixReloc

Func __Au3Obj_Mem_FixImports($tData, $hInstance)
	Local $pImportDirectory = DllStructGetPtr($tData)
	Local $hModule, $tFuncName, $sFuncName, $pFuncAddress
	Local $tIMAGE_IMPORT_MODULE_DIRECTORY, $tModuleName
	Local $tBufferOffset2, $iBufferOffset2
	Local $iInitialOffset, $iInitialOffset2, $iOffset
	While 1
		$tIMAGE_IMPORT_MODULE_DIRECTORY = DllStructCreate("dword RVAOriginalFirstThunk;" & _
				"dword TimeDateStamp;" & _
				"dword ForwarderChain;" & _
				"dword RVAModuleName;" & _
				"dword RVAFirstThunk", _
				$pImportDirectory)
		If Not DllStructGetData($tIMAGE_IMPORT_MODULE_DIRECTORY, "RVAFirstThunk") Then ExitLoop ; the end
		$tModuleName = DllStructCreate("char Name[64]", $hInstance + DllStructGetData($tIMAGE_IMPORT_MODULE_DIRECTORY, "RVAModuleName"))
		$hModule = __Au3Obj_Mem_LoadLibraryEx(DllStructGetData($tModuleName, "Name")) ; load the module, full load
		$iInitialOffset = $hInstance + DllStructGetData($tIMAGE_IMPORT_MODULE_DIRECTORY, "RVAFirstThunk")
		$iInitialOffset2 = $hInstance + DllStructGetData($tIMAGE_IMPORT_MODULE_DIRECTORY, "RVAOriginalFirstThunk")
		If $iInitialOffset2 < $iInitialOffset Then $iInitialOffset2 = $iInitialOffset
		$iOffset = 0 ; back to 0
		While 1
			$tBufferOffset2 = DllStructCreate("ptr", $iInitialOffset2 + $iOffset)
			$iBufferOffset2 = DllStructGetData($tBufferOffset2, 1) ; value at that address
			If Not $iBufferOffset2 Then ExitLoop ; zero value is the end
			If Number(BinaryMid($iBufferOffset2, $__Au3Obj_tagPTR_SIZE, 1)) Then ; MSB is set for imports by ordinal, otherwise not
				$pFuncAddress = __Au3Obj_Mem_GetAddress($hModule, BitAND($iBufferOffset2, 0xFFFFFF)) ; the rest is ordinal value
			Else
				$tFuncName = DllStructCreate("word Ordinal; char Name[64]", $hInstance + $iBufferOffset2)
				$sFuncName = DllStructGetData($tFuncName, "Name")
				$pFuncAddress = __Au3Obj_Mem_GetAddress($hModule, $sFuncName)
			EndIf
			DllStructSetData(DllStructCreate("ptr", $iInitialOffset + $iOffset), 1, $pFuncAddress) ; and this is what's this all about
			$iOffset += $__Au3Obj_tagPTR_SIZE ; size of $tBufferOffset2
		WEnd
		$pImportDirectory += 20 ; size of $tIMAGE_IMPORT_MODULE_DIRECTORY
	WEnd
	Return 1 ; all OK!
EndFunc   ;==>__Au3Obj_Mem_FixImports

Func __Au3Obj_Mem_LoadLibraryEx($sModule, $iFlag = 0)
	Local $aCall = DllCall($gh_AU3Obj_kernel32dll, "handle", "LoadLibraryExW", "wstr", $sModule, "handle", 0, "dword", $iFlag)
	If @error Or Not $aCall[0] Then Return SetError(1, 0, 0)
	Return $aCall[0]
EndFunc   ;==>__Au3Obj_Mem_LoadLibraryEx

Func __Au3Obj_Mem_FreeLibrary($hModule)
	Local $aCall = DllCall($gh_AU3Obj_kernel32dll, "bool", "FreeLibrary", "handle", $hModule)
	If @error Or Not $aCall[0] Then Return SetError(1, 0, 0)
	Return 1
EndFunc   ;==>__Au3Obj_Mem_FreeLibrary

Func __Au3Obj_Mem_GetAddress($hModule, $vFuncName)
	Local $sType = "str"
	If IsNumber($vFuncName) Then $sType = "int" ; if ordinal value passed
	Local $aCall = DllCall($gh_AU3Obj_kernel32dll, "ptr", "GetProcAddress", "handle", $hModule, $sType, $vFuncName)
	If @error Or Not $aCall[0] Then Return SetError(1, 0, 0)
	Return $aCall[0]
EndFunc   ;==>__Au3Obj_Mem_GetAddress

Func __Au3Obj_Mem_VirtualProtect($pAddress, $iSize, $iProtection)
	Local $aCall = DllCall($gh_AU3Obj_kernel32dll, "bool", "VirtualProtect", "ptr", $pAddress, "dword_ptr", $iSize, "dword", $iProtection, "dword*", 0)
	If @error Or Not $aCall[0] Then Return SetError(1, 0, 0)
	Return 1
EndFunc   ;==>__Au3Obj_Mem_VirtualProtect

Func __Au3Obj_Mem_BinDll()
	Local $bBinary = "0x4D5A90000300000004000000FFFF0000B800000000000000400000000000000000000000000000000000000000000000000000000000000000000000D80000000E1FBA0E00B409CD21B8014CCD21546869732070726F6772616D2063616E6E6F742062652072756E20696E20444F53206D6F64652E0D0D0A24000000000000007D90769639F118C539F118C539F118C51E3763C53CF118C539F119C523F118C5308992C533F118C530898AC538F118C530898CC538F118C5308989C538F118C55269636839F118C500000000000000000000000000000000504500004C01050084D9D94B0000000000000000E00002210B01090000160000000E000000000000A122000000100000003000000000001000100000000200000500000000000000050000000000000000700000000400000000000002004005000010000010000000001000001000000000000010000000E032000082010000C03100003C0000000050000080030000000000000000000000000000000000000060000008010000603000001C0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000300000540000000000000000000000000000000000000000000000000000002E74657874000000A8150000001000000016000000040000000000000000000000000000200000602E72646174610000" & _
			"BB0400000030000000060000001A0000000000000000000000000000400000402E646174610000000C000000004000000000000000000000000000000000000000000000400000C02E7273726300000080030000005000000004000000200000000000000000000000000000400000402E72656C6F6300007001000000600000000200000024000000000000000000000000000040000042000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" & _
			"832600836618008D460850FF153C3000108BC6C38B0685C0740750E858150000598B4424048D5002668B0840406685C975F62BC2D1F833C96A02405AF7E20F90C1F7D90BC851E8191500008B5424085989060FB70A426689084240406685C975F1C204008B442404FF40048B4004C20400568B742408FF4E048B460475268D461850C7067C300010FF15443000108B46088B0850FF51088366080056E8D71400005933C05EC20400558BEC83EC2033C0568B750C33C95766894DF466894DF666894DE466894DE66A04598D7DF033D28945F0C645F8C08845F98845FA8845FB8845FC8845FD8845FEC645FF46F3A7C745E004040200C645E8C08845E98845EA8845EB8845EC8845ED8845EEC645EF46741B8B750C6A04598D7DE033D2F3A7740C8B4D108901B802400080EB108B45088B4D1089018B0850FF510433C05F5EC9C20C00FF74240C8B4424088D481851FF7008FF700C6A00FF15004000108B4C2410890133C985C00F94C18BC1C210008B4424046A008D481851FF7008FF70146A01FF1500400010F7D81BC040C208008B4424046A008D481851FF7008FF70106A02FF1500400010F7D81BC040C20400538BD8568B353C3000105733FFC70354310010897B04897B08897B0C897B10897B148D432850897B18897B1C897B20897B24FFD68D433850FFD68D434850FFD68D435850FFD66A20E869130000593BC7740B"
	$bBinary &= "8BF0E8F9FDFFFF8BF0EB0233F66898300010897E18C7461C02000000E8F3FDFFFF56E8350A00005F5E8BC35BC3558BEC5151538BD833C0894304894308C7035431001089430C894310894314568B353C30001089431889431C8943208943248D432850FFD68D433850FFD68D434850FFD68D435850FFD68365F800837F1000765F6A20E8DC1200005985C0740C8BF0E86CFDFFFF8945FCEB078365FC008B45FC8B4F0C8B55F88B34918B4E188948188D4E085183C00850FF15403000108B4E1C8B45FC89481CFF368BF0E845FDFFFF56E887090000FF45F88B45F83B471072A18B471885C0740EFF77208BF3FF771C50E8DF0900005E8BC35BC9C35333DB56C70754310010395F1076158B470C8B349885F67405E869000000433B5F1072EBFF770CE8511200008B354430001083670C008367100083671400598D472850FFD68D474850FFD68D473850FFD68B47185E5B85C0740750E81D120000598B471C85C0740750E80F120000598B472085C0740750E80112000059FF770CE8F811000059C38B0685C0740750E8EA110000598D460850FF154430001056E8D9110000598BC6C3558BEC5151578B7D08FF4F048B47040F85BA000000833D04400010000F849F000000568D772856FF15443000108365FC008D45F8506A016A0CC745F802000000FF1534300010FF4708FF4704894730B80C2000006689068B77104E744B" & _
			"538B470C8B1CB08B03B9B0300010668B11663B10751E6685D27415668B5102663B5002750F83C10483C0046685D275DE33C0EB051BC083D8FF85C0750A57FF7310FF15044000104E75B75B8B3544300010FF4F048D474850FFD68D472850FFD6FF4F085EE892FEFFFF57E8091100005933C05FC9C20400558BEC568B7510FF3668B4300010E8BE100000595985C075108B451CC700FCFFFFFF33C05E5DC21800FF3668C8300010E89C100000595985C0750B8B451CC7007CFCFFFFEBDCFF3668E0300010E87F100000595985C0750B8B451CC7007BFCFFFFEBBFFF3668F8300010E862100000595985C0750B8B451CC7007AFCFFFFEBA2FF36680C310010E845100000595985C0750B8B451CC70079FCFFFFEB85FF366824310010E828100000595985C0750E8B451CC70078FCFFFFE965FFFFFFFF366840310010E808100000595985C0750E8B451CC70077FCFFFFE945FFFFFFFF368B7508E8B20C00008B4D1C890183F8FF0F852DFFFFFFB806000280E925FFFFFF558BEC8B55188B450C83EC14538BCA83E10156570F85C2000000F6C2020F85B9000000F6C20C0F84010200003D7CFCFFFF756D8B751C837E08020F859A0600008B460433DB8338FD0F94C333C085DB0F95C08BF88B06C1E70403C70FB70883F915741983F914741483F91A741B83F913741683F9037411E9920000006A136A005050FF152C3000108B36" & _
			"33C085DB0F94C0C1E00403C650FF743E08E98C0000003D7AFCFFFF75188B4508837808000F842606000083C0388B4D1CFF3150EB6D3D79FCFFFF0F85630100008B4508837808000F840306000083C048EBDB3D7CFCFFFF75568B751C837E08010F85EA0500008B060FB70883F915741E83F914741983F91A742083F913741B83F9037416B805000280E9C70500006A136A005050FF152C3000108B06FF7008FF7520FF154030001033C0E9A60500003D7BFCFFFF75138B4508837808000F848D05000083C02850EBD63D7AFCFFFF75088B450883C038EBEE3D78FCFFFF75128B4508837808000F846405000083C058EBD53D77FCFFFF752B8B7D08837F08000F844B0500008B752056FF15443000106A0858668906FF7724FF1548300010894608EB8583F8FC757B8B7D08837F18000F841B0500008B5D2053FF15443000106A0D586A28668903E8180E00008BF05985F674408B471C8B5F208945088B47188366040089451CC7067C300010897E088B0757FF50048B451C89460C8B45088946108D461850895E14FF153C3000108B5D20EB0233F68973088B0656FF5004E905FFFFFF33DB3BC30F8CA30400008B75088B7E10473BC70F8D940400008B7E0C8B3C87663BCB0F852D020000F6C2020F8524020000F6C20C0F8473040000395F1C7409395E080F84650400008B4718480F8446010000480F85540400008B751C8B"
	$bBinary &= "460883F8027573B80C200000663947080F8510010000FF7710FF153030001083F8010F85FE0000008B460433C98338FD8B060F94C133DB6A0385C90F95C3894D2059C1E30403C3663B08740B516A005050FF152C3000108B3633C03945200F94C0C1E00403C6508D44330850FF7710FF1520300010E91F02000083F8030F85A3000000B80C200000663947080F8594000000FF7710FF153030001083F8020F85820000008B46048B0E33DB8338FD6A030F94C38BC3F7D81BC083E002C1E00403C159663B08740B516A005050FF152C3000108B066A0383C01059663B08740B516A005050FF152C3000108B3633C085DB0F95C0C1E0048B4430088945F833C085DB0F95C040C1E0048B443008F7DB1BDB83E3FE4343C1E30403DE8945FC538D45F8E945FFFFFF837E08010F8508020000FF3683C70857E967FDFFFFFF46088B078B1D443000108946248D462850FFD38D464850FFD38B451C8B40088365F00089450883C0028945EC8D45EC506A016A0CFF15343000108D4DF451508945FCFF153830001085C0754B8B4D0885C97E3B8BC1C1E004C7450820000000894518894D0C8B451C8B008B4D188D4408F08B4D08508B45F403C150FF154030001083450810836D1810FF4D0C75D7FF75FCFF154C3000108B45FC894630B80C200000668946286A0358668946588B4660C7466001000000E9160200008B4718480F844901" & _
			"0000480F8547020000837F1C027509395E080F84380200008B751C8B460883F8010F8580000000B80C200000663947080F85FD000000FF7710FF153030001083F8010F85EB0000008B066A0359663B08740A51535050FF152C3000108B368D46088338FF75268B752056FF15443000106A035866890683C608566A01FF7710FF1524300010FF06E91CFCFFFFFF752050FF7710FF1528300010F7D81BC02509000280E9AE01000083F8020F8583000000B80C200000663947087578FF7710FF153030001083F802756A8B068B1D2C3000106A0359663B087407516A005050FFD38B066A0383C01059663B087407516A005050FFD38B368B46088945F88B76188975FC83FEFF75248B752056FF15443000106A035866890683C60833C0837DF802560F95C04050E951FFFFFF8D45F8E959FFFFFF395E08740AB80E000280E91301000083C70857E954FBFFFF395F1C7409395E080F84F7000000FF46088B078B1D443000108946248D462850FFD38D464850FFD38B451C8B40088365F00089450883C0028945EC8D45EC506A016A0CFF15343000108D4DF451508945FCFF153830001085C0754B8B4D0885C97E3B8BC1C1E004C7450820000000894518894D0C8B451C8B008B4D188D4408F08B4D08508B45F403C851FF154030001083450810836D1810FF4D0C75D7FF75FCFF154C3000108B45FC894630B80C20000066894628" & _
			"6A0358668946588B46608366600056FF771089451CFF15044000108D7E4857FF75208945088B451C894660FF15403000108D462850FFD357FFD3FF4E088B4508F7D81BC025FDFFFD7F0503000280EB05B8030002805F5E5BC9C2240056578B7C240CFF378BF3E8A505000083F8FF74568B0FBEB0300010668B16663B11751E6685D27415668B5602663B5102750F83C60483C1046685D275DE33C9EB051BC983D9FF85C974208BF88B430CC1E7028B340785F67405E8C8F6FFFF8B430C8B4C240C890C07EB09578D730CE8720500005F5EC20400558BEC8B461885C0740750E894080000598B4508576A028D50025F668B0803C76685C975F62BC2D1F833C9408BD7F7E20F90C1F7D90BC851E8530800008B5508598946180FB70A66890803D703C76685C975F18B461C85C0740750E844080000598B450C8D5002668B0803C76685C975F62BC2D1F833C9408BD7F7E20F90C1F7D90BC851E8070800008B550C5989461C0FB70A66890803D703C76685C975F18B462085C0740750E8F8070000598B45108D5002668B0803C76685C975F62BC2D1F833C9408BD7F7E20F90C1F7D90BC851E8BB0700008B5510598946200FB70A66890803D703C76685C975F15F5DC20C008B460485C0740750E8A7070000598B4424048D5002668B0840406685C975F62BC2D1F833C96A02405AF7E20F90C1F7D90BC851E8680700008B542408"
	$bBinary &= "598946040FB70A426689084240406685C975F1C20400558BEC83EC1033C053894704894708C707803100108D5F0C568B353C30001089038943048943088D472050FFD68D473050FFD68B45088B550C8365F800836508008947188BC28955F48D4802668B3040406685F675F62BC1D1F833F68945F08975FC8D04720FB7086683F97C750E33C96689088D4472028945F8EB5A6683F90A74056685C9754F33C96A0C668908E8BB06000033F6593BC6740B834808FF89308970048BF0FF75F4E851F1FFFFFF75F8E8F9FEFFFF8B4508894608568BF3E8680300008B450C8B4DFCFF45088B550C8D4448028945F48B75FC468975FC3B75F076805E8BC75BC9C208008B0685C0740750E86C060000598B460485C0740750E85E0600005956E857060000598BC6C3578B7C2408FF4F048B47047507E80600000033C05FC204005333DBC70780310010395F107617568B470C8B349885F67405E8A5FFFFFF433B5F1072EB5EFF770CE80E06000083670C0083671000836714008B4718598B0850FF5108FF770CE8F005000057E8EA05000059598BC75BC3B802400080C20C00B801400080C20800B801400080C21000558BEC568B7510FF366870310010E889050000595985C075108B451CC700DCFCFFFF33C05E5DC21800FF3668E0300010E867050000595985C0750B8B451CC7007BFCFFFFEBDCFF36680C310010E84A0500005959" & _
			"85C0750B8B451CC70079FCFFFFEBBFFF368B7508E8F70100008B4D1C890183F8FF75ABB806000280EBA6558BEC8B55188B450C83EC18538BCA83E10156577529F6C2027524F6C20C74693D79FCFFFF75628B4508837808000F84A60100008B4D1CFF3183C03050EB423DDCFCFFFF75208B752056FF15443000106A13586689068B45088B401889460833C0E9790100003D7BFCFFFF751C8B4508837808000F846001000083C02050FF7520FF1540300010EBD685C00F8C490100008B75083B46100F8D3D0100008B7E0C8B1C87895DF46685C97509F6C2020F84260100008B46188B008B3D443000108945F08D462050FFD78D463050FFD78B451C8B48088B43048365EC008D5002894D18895508668B1040406685D275F62B45086A00D1F8580F95C040410FAFC88945088D45E8506A0183C1036A0C894DE8FF15343000108D4DFC515089450CFF153830001085C075603945187E528B45088B5D18C1E0048945F833C0837D08020F94C08D440004C1E0048945088B4518C1E3048945188B451C8B008B4D088D4418F0508B45FC03C851FF15403000108B45F801450883EB10FF4D1875D98B5DF4FF750CFF154C3000108B450CFF7520FF46088946288D4620B90C2000006689088B4DF08945088B451CFF70088B430856FF7304FF7618FF3481FF15084000108D5E3053FF7520FF1540300010FF7508FF4E08FFD753FFD7E9" & _
			"85FEFFFFB8030002805F5E5BC9C224005733FF397E10761E8B460C8B04B88B00FF74240850E862030000595985C0740D473B7E1072E283C8FF5FC204008BC7EBF88B46048D48013B4E0876465733C96A048D4400025AF7E20F90C1F7D90BC851E8FF0200008BF833C059394604760E8B0E8B0C81890C87403B460472F2FF36E8F40200008B4604598D4C0002893E894E085F8B0E8B542404891481FF4604C2040033C040C20C006A68E8B60200005985C07405E9F6EEFFFF33C0C36A68E8A20200005985C0740D578B7C2408E85CEFFFFF5FEB0233C0C204008B442404A3044000108B442408A300400010C208005356576A20E86C0200005985C0740B8BF0E8FCECFFFF8BF0EB0233F68B44241CFF742414C746180100000089461CE8F3ECFFFF8D7E0866833F00740757FF15443000106A0858FF742418668907FF15483000108B5C241056894610E80EF9FFFF5F5E5BC21000558BEC56578B7D08FF750C8BF7E8AAFEFFFF83F8FF89450C7E2A538BD88B470CC1E3028B340385F67405E8FFEFFFFFFF4F108B471039450C73098B7F0C8B048789041F5B5F5E5DC2080056FF7424148B74240CFF742414FF742414E820F9FFFF5EC21000558BEC53566A20E8A00100005985C0740B8BF0E830ECFFFF8BF0EB0233F6837D1400C7461802000000740DFF75148D460850FF15403000108B4510FF750C89461CE816ECFFFF8B5D"
	$bBinary &= "0856E855F8FFFF5E5B5DC210008B442404A308400010C20400566A40E8430100008BF033C0593BF07432894604894608C7068031001089460C8946108946148B442408578B3D3C3000108946188D462050FFD78D463050FFD78BC65F5EC204006A40E8FD0000005985C0741357FF74240C8BF8FF74240CE89AF9FFFF5FEB0233C0C20800558BEC56576A0CE8D400000033FF593BC7740B834808FF89388978048BF8FF750C8BF7E868EBFFFF8B4514FF7510894708E80AF9FFFFFF378B7508E84CFDFFFF83F8FF750B5783C60CE86FFDFFFFEB21538BD88BC68B400CC1E3028B340385F67405E815FAFFFF8B45088B400C893C035B5F5E5DC21000558BEC817D08ADDE00007530817D0CEFBE00007527566AF5FF150C3000106A008BF08D4508506A22689C31001056FF150030001056FF15083000105E5DC208008B4424048B0850FF5104C204006AFFFF74240C6AFFFF7424106A006800080000FF15043000104848C3FF7424046A00FF151030001050FF1518300010C3FF7424046A00FF151030001050FF1514300010C36AFFFF74240C6AFFFF7424106A016800080000FF15043000104848C300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" & _
			"503200005C3200006E32000082320000C6320000BA320000AE320000000000001A00008013000080190000800C000080110000800F00008017000080080000800A000080090000800200008018000080000000000000000000000000000000000000000084D9D94B00000000020000005700000064340000641E0000A81000106410001071100010421100106E1100108E1100109C1F00105F005F00640065006600610075006C0074005F005F0000007E0000005F004E006500770045006E0075006D00000000005F005F006200720069006400670065005F005F00000000005F005F0070006100720061006D0073005F005F00000000005F005F006500720072006F0072005F005F0000005F005F0072006500730075006C0074005F005F00000000005F005F00700072006F007000630061006C006C005F005F00000000005F005F006E0061006D0065005F005F0000000000941F001064100010A31300109C1F0010A41F001077140010761500105F005F007000740072005F005F000000941F001064100010251F00109C1F0010A41F0010AC1F00102A2000104C6F6C2E20596F7520666F756E6420746865206561737465722D6567672E200D0A000000FC310000000000000000000092320000003000001C3200000000000000000000A032000020300000000000000000000000000000000000000000000050320000" & _
			"5C3200006E32000082320000C6320000BA320000AE320000000000001A00008013000080190000800C000080110000800F00008017000080080000800A000080090000800200008018000080000000008D04577269746546696C65005500436F6D70617265537472696E675700004101466C75736846696C654275666665727300003B0247657453746448616E646C6500004B45524E454C33322E646C6C00004F4C4541555433322E646C6C00009D0248656170416C6C6F6300A10248656170467265650000230247657450726F6365737348656170000000000000000000000000000083D9D94B000000008A330000010000000D0000000D000000083300003C330000703300009E230000EE220000B8230000BB220000A722000019240000602400003B250000D92200000D240000FB24000054230000842400009B330000A3330000AD330000B9330000CB330000DE330000F233000008340000173400002234000034340000443400005134000000000100020003000400050006000700080009000A000B000C004175746F49744F626A6563742E646C6C00416464456E756D004164644D6574686F640041646450726F706572747900436C6F6E654175746F49744F626A656374004372656174654175746F49744F626A65637400437265617465577261707065724F626A65637400437265617465577261707065724F"
	$bBinary &= "626A65637445780049556E6B6E6F776E41646452656600496E697469616C697A6500496E697469616C697A6557726170706572004D656D6F727943616C6C456E7472790052656D6F76654D656D62657200577261707065724164644D6574686F640000005253445346BEC1591B85574299A3279E3DB68FA201000000633A5C55736572735C7472616E636578785C4465736B746F705C4175746F49744F626A656374325C7472756E6B5C4175746F49744F626A6563742E7064620000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" & _
			"000000000000000000000000000001001000000018000080000000000000000000000000000001000100000030000080000000000000000000000000000001000904000048000000605000002003000000000000000000000000000000000000200334000000560053005F00560045005200530049004F004E005F0049004E0046004F0000000000BD04EFFE0000010001000100000000000100010000000000000000000000000004000000020000000000000000000000000000007E020000010053007400720069006E006700460069006C00650049006E0066006F0000005A0200000100300034003000390030003400420030000000300008000100460069006C006500560065007200730069006F006E000000000031002E0031002E0030002E0030000000340008000100500072006F006400750063007400560065007200730069006F006E00000031002E0031002E0030002E00300000007A0029000100460069006C0065004400650073006300720069007000740069006F006E0000000000500072006F007600690064006500730020006F0062006A006500630074002000660075006E006300740069006F006E0061006C00690074007900200066006F00720020004100750074006F0049007400000000003A000D000100500072006F0064007500630074004E0061006D006500000000004100750074006F00" & _
			"490074004F0062006A00650063007400000000005E001D0001004C006500670061006C0043006F0070007900720069006700680074000000280043002900200062007900200054006800650020004100750074006F00490074004F0062006A006500630074002D005400650061006D00000000004A00110001004F0072006900670069006E0061006C00460069006C0065006E0061006D00650000004100750074006F00490074004F0062006A006500630074002E0064006C006C00000000007A002300010054006800650020004100750074006F00490074004F0062006A006500630074002D005400650061006D00000000006D006F006E006F00630065007200650073002C0020007400720061006E0063006500780078002C0020004B00690070002C002000500072006F00670041006E006400790000000000440000000100560061007200460069006C00650049006E0066006F00000000002400040000005400720061006E0073006C006100740069006F006E00000000000904B0040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
	$bBinary &= "00100000940000000D3084308A3058318231A231B431BD310E323F324F32B932013329339533BA33CC33E5330A3443344D348134A334C034DD34FA3417353735FA359636A4360B371A373B3768378A371B38533871389738CE38E638423972398039B939CF393B3A583A6C3A813A953AC03ACD3A0D3B603B903B9E3BD73BED3B173C2D3C733C273E313E423FB63FD83FF53F000000200000400000007630AD30E5303B3149319331AD31E331F031DE32E7322D333D33EC33123432344634153524352B3532355D356C35733580358735A135000000300000340000007C308030843088308C3090309430543158315C316031643168316C318031843188318C3190319431983100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
	Return Binary($bBinary)
EndFunc   ;==>__Au3Obj_Mem_BinDll

Func __Au3Obj_Mem_BinDll_X64()
	Local $bBinary = "0x4D5A90000300000004000000FFFF0000B800000000000000400000000000000000000000000000000000000000000000000000000000000000000000E00000000E1FBA0E00B409CD21B8014CCD21546869732070726F6772616D2063616E6E6F742062652072756E20696E20444F53206D6F64652E0D0D0A2400000000000000C9CCEE978DAD80C48DAD80C48DAD80C4AA6BFBC488AD80C48DAD81C497AD80C493FF0AC487AD80C493FF12C48CAD80C484D514C48CAD80C493FF11C48CAD80C4526963688DAD80C4000000000000000000000000000000000000000000000000504500006486060068D9D94B0000000000000000F00022200B020900001E0000001200000000000068280000001000000000008001000000001000000002000005000200000000000500020000000000008000000004000000000000020040010000100000000000001000000000000000001000000000000010000000000000000000001000000090350000860100001C3400003C0000000060000080030000005000008C01000000000000000000000070000034000000B03000001C0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000300000A80000000000000000000000000000000000000000000000000000002E74657874000000EF1C000000100000001E000000040000" & _
			"000000000000000000000000200000602E7264617461000016070000003000000008000000220000000000000000000000000000400000402E6461746100000018000000004000000000000000000000000000000000000000000000400000C02E706461746100008C0100000050000000020000002A0000000000000000000000000000400000402E72737263000000800300000060000000040000002C0000000000000000000000000000400000402E72656C6F63000066000000007000000002000000300000000000000000000000000000400000420000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" & _
			"48895C240848896C24104889742418574883EC20488BF1488B0933ED488BDA483BCD7405E8A31C00004983C8FF33C0488BFB498BC866F2AF418D400348F7D148F7E1490F40C0488BC8E85A1C00004889060FB70B4883C3026689084883C002663BCD75ED488B5C2430488B6C2438488B7424404883C4205FC3CCCCCC40534883EC20834108FF488BD9752F488D053E2000004889014883C130FF15E91F0000488B4B10488B01FF50104883631000488BCBE8161C000033C0EB038B41084883C4205BC3CC488BC44883EC484C8B124533DB4C8BC9488D48D8C640E0C0C640E746448958D866448958DC66448958DE448858E1448858E2448858E3448858E4448858E5448858E6C740E80404020066448958EC66448958EEC640F0C0448858F1448858F2448858F3448858F4448858F5448858F6C640F7464C3B11750F4C8B52084C3B51087505418BC3EB051BC083D8FF413BC37430488B0A488D442430483B08750F488B4A08483B48087505418BC3EB051BC083D8FF413BC3740A4D8918B802400080EB0E4D8908498B01498BC9FF500833C04883C448C340534883EC30488B51184C894424204C8B4110498BD94C8D493033C9FF15462E000033C93BC189030F94C18BC14883C4305BC3CC40534883EC304C8B4110488B512833DB4C8D49308D4B0148895C2420FF15122E00003BC30F94C38BC34883C4305BC3CC40534883"
	$bBinary &= "EC304C8B4110488B512033DB4C8D49308D4B0248895C2420FF15E22D00003BC30F94C38BC34883C4305BC3CC48895C24084889742410574883EC2033F6488D05941F0000488BF948890189710889710C4889711089711889711C488971204889712848897130488971384883C140FF15041E0000488D4F58FF15FA1D0000488D4F70FF15F01D0000488D8F88000000FF15E31D00008D4E28E80B1A0000488BD8483BC67412488D4808488930897020FF15C31D0000EB03488BDE488D15471E0000488BCB897320C7432402000000E82DFDFFFF488BD3488BCFE8560D0000488B5C2430488B742438488BC74883C4205FC3CCCCCC488BC4488958084889681048897018488978204154415541564883EC204533F6488D05BD1E0000488BF9488901448971084489710C4C897110448971184489711C4C8971204C8971284C8971304C8971384883C140488BEAFF15261D0000488D4F58FF151C1D0000488D4F70FF15121D0000488D8F88000000FF15051D0000458BEE4439751876724D8BE6B928000000E81F190000488BF0493BC67413488D48084C893044897020FF15D61C0000EB03498BF6488B4510488D4E08498B1C048B4320488D5308894620FF15BD1C0000448B5B2444895E24488B13488BCEE82AFCFFFF488BD6488BCFE8530C000041FFC54983C408443B6D187291488B5520493BD674104C8B4D304C8B452848" & _
			"8BCFE8250D0000488B5C2440488B6C2448488B742450488BC7488B7C24584883C420415E415D415CC3CCCCCCFF41088B4108C3CC48895C241048896C241856574154415541564883EC204183CEFF488BD9440171080F85BB00000048833DA52B0000000F849C0000004883C140FF15151C00008364245400B90C0000004C8D4424508D51F5C744245002000000FF15D51B0000448B6318FF430CFF430848894348B80C2000004183EC01668943404963EC743648C1E503488B4310488D355E1C0000B9020000004C8B0428498B3866F3A7750D498B4810488BD3FF15282B00004883ED084503E675CE44017308488D4B70FF15911B0000488D4B40FF15871B00004401730CBA01000000488BCBE81E00000033C0EB038B4108488B5C2458488B6C24604883C420415E415D415C5F5EC348895C240848896C24104889742418574883EC20488D058D1C000033F6488BD9488901397118763A33FF488B4310488B2C074885ED7420488B4D004885C97405E857170000488D4D08FF15091B0000488BCDE845170000FFC64883C7083B731872C8488B4B10E83117000048836310008363180083631C00488D4B40FF15D61A0000488D4B70FF15CC1A0000488D4B58FF15C21A0000488B4B204885C97405E8F8160000488B4B284885C97405E8EA160000488B4B304885C97405E8DC160000488B4B10E8D3160000488BCBE8CB1600" & _
			"00488B6C2438488B742440488BC3488B5C24304883C4205FC3CCCCCCB802400080C3CCCC48895C2408574883EC20498B10488BF9488D0DED1A0000498BD8E83916000085C07518488B442458C700FCFFFFFF33C0488B5C24304883C4205FC3488B13488D0DD71A0000E80E16000085C0750D488B442458C7007CFCFFFFEBD3488B13488D0DCF1A0000E8EE15000085C0750D488B442458C7007BFCFFFFEBB3488B13488D0DC71A0000E8CE15000085C0750D488B442458C7007AFCFFFFEB93488B13488D0DBF1A0000E8AE15000085C07510488B442458C70079FCFFFFE970FFFFFF488B13488D0DB41A0000E88B15000085C07510488B442458C70078FCFFFFE94DFFFFFF488B13488D0DB11A0000E86815000085C07510488B442458C70077FCFFFFE92AFFFFFF488B13488BCFE889080000488B4C2458890183F8FF0F850FFFFFFFB806000280E907FFFFFFCCCCCC48895C240848896C241048897424185741544155415641574883EC40440FB784249000000041B9080000004C8BE1458D71F9450FB7D0458D69FA664523D60F85ED0000004584C50F85E400000041F6C00475094584C10F846502000081FA7CFCFFFF0F8585000000488B9C249800000044396B100F85CF070000488B430833ED8338FD488BC58BF5400F94C63BF50F95C04C8D2440488B034A8D0CE00FB70183F813741B8D7D033BC7741483F81A7421"
	$bBinary &= "83F815741C83F8147417E9AF00000041B9150000004533C0488BD1FF1537180000488B0B3BF5400F94C5488D446D00488D14C14A8B4CE108E9AC00000081FA7AFCFFFF751F33ED39690C0F84490700004883C158488B942498000000488B12E98500000081FA79FCFFFF0F85A101000033ED39690C0F841E0700004883C170EBD381FA7CFCFFFF756D488B9C2498000000443973100F85FE060000488B0B0FB70183F8137422BF030000003BC7741983F81A742683F815742183F814741CB805000280E9D606000041B9150000004533C0488BD1FF157E170000488B13488B5208488B8C24A0000000FF159117000033C0E9A806000081FA7BFCFFFF751133ED39690C0F8490060000488D5140EBD281FA7AFCFFFF7506488D5158EBC481FA78FCFFFF751433ED39690C0F8469060000488D9188000000EBA881FA77FCFFFF753833ED39690C0F844D060000488B9C24A0000000488BCBFF152B170000448D4D086644890B498B4C2438FF152017000048894308E976FFFFFF83FAFC0F858F00000033ED483969200F840B0600004C8BB424A0000000498BCEFF15E9160000448D5D0D8D4D486645891EE8F91200004C8BE8483BC57444498B742430498B7C2428498B5C2420488D050317000041896D084D89651049894500498B1424498BCCFF5208498D4D3049895D1849897D2049897528FF157F160000EB034C8BED4D89" & _
			"6E08498B4500498BCDFF5008E9DEFEFFFF33ED3BD50F8C7E0500008B41184103C63BD00F8D70050000498B4424108BCA488B34C866443BD50F85910200004584C50F858802000041F6C00475094584C10F8443050000396E24740B41396C240C0F84330500008B4E20412BCE0F8489010000413BCE0F851E050000488B9C249800000044396B100F8585000000B80C200000663946080F8549010000488B4E10FF15BA150000413BC60F8536010000488B4308448BE5BF030000008338FD488BC5410F94C4443BE50F95C04C8D2C40488B034A8D0CE8663B39740F448BCF4533C0488BD1FF156E150000488B0B488BC5443BE50F94C04A8D54E908488D04404C8D04C1488B4E10FF1533150000E97F020000BF03000000397B100F85C5000000B80C200000663946080F85B6000000488B4E10FF1527150000413BC50F85A3000000488B4308448BE58338FD410F94C4418BC4F7D8488B03481BC94923CD488D0C49488D0CC8663B39740F448BCF4533C0488BD1FF15DE140000488B0B4883C118663B39740F448BCF4533C0488BD1FF15C3140000488B13443BE5488BC50F95C0488D04408B4CC208418BC4F7D8894C2420481BC948F7D94903CE41F7DC488D04498B4CC208481BC048F7D0894C24244923C5488D04404C8D04C2488D542420E91EFFFFFF443973100F8559020000488B13488D4E08E9EEFCFFFF450174240C" & _
			"488B06498D5C2440488BCB4989442438FF1572140000498D4C2470FF15671400004C8BBC24980000004C8D442428458B6F10B90C000000418BD6418D4502896C242C89442428FF151C140000488D542430488BC84C8BF0FF15131400003BC5754D443BED7E3F418D4DFFBB30000000498BED4863D1488D3C5248C1E703498B07488B4C2430488D14074803CBFF15EE1300004883EF184883C3184883ED0175DD498D5C2440498BCEFF15EA130000B80C200000668903418B9C249000000041C784249000000001000000E9650200008B4E20412BCE0F8480010000413BCE0F85B502000044396E24750B41396C240C0F84A4020000488B9C2498000000443973100F859A000000B80C200000663946080F852D010000488B4E10FF1540130000413BC60F851A010000488B0BBF03000000663B39740F448BCF4533C0488BD1FF1513130000488B134883C208833AFF752E488B9C24A0000000488BCBFF1526130000418BD666893B488B4E104C8D4308FF15D212000044017308E970FBFFFF4C8B8424A0000000488B4E10FF15BF1200002BE8F7DD1BC02509000280E9FD01000044396B100F8598000000B80C200000663946080F8589000000488B4E10FF159C120000413BC5757A488B0BBF03000000663B39740F448BCF4533C0488BD1FF1573120000488B0B4883C118663B39740F448BCF4533C0488BD1FF1558120000"
	$bBinary &= "488B0B8B4108894424208B41208944242483F8FF7523488B9C24A0000000488BCBFF156112000044396C2420400F95C5418D142EE92CFFFFFF488D542420E93CFFFFFF396B10740AB80E000280E94C010000488D5608E986FAFFFF396E24740B41396C240C0F842E010000450174240C488B06498D5C2440488BCB4989442438FF1502120000498D4C2470FF15F71100004C8BBC24980000004C8D442428458B6F10B90C000000418BD6418D4502896C242C89442428FF15AC110000488D542430488BC84C8BF0FF15A31100003BC5754B443BED7E3D418D4DFFBB300000004863D1488D3C5248C1E703498B07488D1407488B442430488D0C03FF15801100004883EF184883C3184983ED0175DC498D5C2440498BCEFF157C110000B80C200000668903418B9C24900000004189AC24900000004D89742448BF03000000498BD4664189BC2488000000488B4E10FF15B4200000488B8C24A0000000498D5424708BF841899C2490000000FF150F110000498D4C2440FF150C110000498D4C2470FF150111000041FF4C240CF7DF1BC0F7D02503000280EB05B8030002804C8D5C2440498B5B30498B6B38498B7340498BE3415F415E415D415C5FC348895C240848896C24104889742418574883EC3033DB488BEA488BF1395918763B488BFB488B4610834C2428FF4183C9FF488B0C07418D510248896C24204C8B01B90008" & _
			"0000FF150010000083F8027423FFC34883C7083B5E1872C883C8FF488B5C2440488B6C2448488B7424504883C4305FC38BC3EBE748895C240848896C24104889742418574883EC20488BEA488B12488BD9E866FFFFFF4983C8FF413BC0744E488B7D00488D35B6100000418D480366F3A7743A8BF0488B4310488B3CF033C0483BF8741F4839077408488B0FE83B0C0000488D4F08FF15ED0F0000488BCFE8290C0000488B431048892CF0EB698B4B188D41013B431C76538D4C0902B80800000048F7E1490F40C0488BC8E8D80B0000488BF033C0394318761A488BF8488B4B10FFC0488B140F488914374883C7083B431872E9488B4B10E8CF0B00008B4B18488973108D44090289431C488B431048892CC8FF4318488B5C2430488B6C2438488B7424404883C4205FC3CC48895C240848896C241048897424185741544155415641574883EC20488BF1488B49204533F6498BD94D8BE0488BEA493BCE7405E8670B000033C04983CFFF488BFD448D6802498BCF66F2AF498BC548F7D148F7E1490F40C7488BC8E81B0B0000488946200FB74D004903ED6689084903C566413BCE75ED488B4E28493BCE7405E81A0B000033C0498BCF498BFC66F2AF498BC548F7D148F7E1490F40C7488BC8E8D60A000048894628410FB70C244D03E56689084903C566413BCE75EC488B4E30493BCE7405E8D40A000033C0498BCF488BFB" & _
			"66F2AF498BC548F7D148F7E1490F40C7488BC8E8900A0000488946300FB70B4903DD6689084903C566413BCE75EE488B5C2450488B6C2458488B7424604883C420415F415E415D415C5FC3CC48895C240848896C24104889742418574883EC20488BF1488B490833ED488BDA483BCD7405E8560A00004983C8FF33C0488BFB498BC866F2AF418D400348F7D148F7E1490F40C0488BC8E80D0A0000488946080FB70B4883C3026689084883C002663BCD75ED488B5C2430488B6C2438488B7424404883C4205FC3CC48895C241848894C240855565741544155415641574883EC2033DB488D05360F0000488BE9488901488D411089590889590C4883C1284D8BE8488BFA488944246848891889580889580CFF15600D0000488D4D40FF15560D000048897D204883C9FF33C0498BFD4C8BF366F2AF448BFB8D730148F7D1498BDD498BED448BE133C966833B7C750C8BC666890B4D8D744500EB6566833B0A740566390B755A66890BB918000000E835090000488BF833C0483BF8740D834F10FF48890748894708EB03488BF8488BD5488BCFE868ECFFFF498BD6488BCFE8A9FEFFFF488B4C2468488BD744897F10E81C0400008BC641FFC733C9498D6C4500FFC64883C3024983EC010F8579FFFFFF488B442460488B5C24704883C420415F415E415D415C5F5E5DC3CCCC48895C240848896C24104889742418574883EC20"
	$bBinary &= "834108FF488BD90F8583000000488D050C0E000033FF488901397918763D33ED488B4310488B34284885F67423488B0E4885C97405E892080000488B4E084885C97405E884080000488BCEE87C080000FFC74883C5083B7B1872C5488B4B10E86808000048836310008363180083631C00488B4B20488B01FF5010488B4B10E848080000488BCBE84008000033C0EB038B4108488B5C2430488B6C2438488B7424404883C4205FC3B801400080C3CCCC48895C2408574883EC20498B10488BF9488D0D490D0000498BD8E8AD07000085C07518488B442458C700DCFCFFFF33C0488B5C24304883C4205FC3488B13488D0D630C0000E88207000085C0750D488B442458C7007BFCFFFFEBD3488B13488D0D730C0000E86207000085C0750D488B442458C70079FCFFFFEBB3488B13488BCFE886FAFFFF488B4C2458890183F8FF759CB806000280EB97CCCCCC48895C240848896C241048897424185741544155415641574883EC500FB7BC24A0000000BD04000000488BD9448D7DFD440FB7C7664523C7753540F6C702752F4084FD750640F6C708747D81FA79FCFFFF757533F639710C0F8403020000488B9424A80000004883C140488B12EB5181FADCFCFFFF752A488BBC24B0000000488BCFFF15B40A000041BB150000006644891F488B43204889470833C0E9C501000081FA7BFCFFFF751F33F639710C0F84AD010000" & _
			"488D5128488B8C24B0000000FF156E0A0000EBD233F63BD60F8C8F0100003B51180F8D86010000488B43108BCA4C8B24C866443BC6750A40F6C7020F846C010000488B4320488D4B28488B004889442440FF15310A0000488D4B40FF15270A0000498B7C24084C8BB424A8000000458B6E1033C04883C9FF8974243466F2AF8BFE48F7D1418D45014C8D442430493BCFB90C000000418BD7400F95C74103FF89BC24A00000000FAFC783C00389442430FF15B2090000488D542438488BC84C8BF8FF15A90900003BC67574443BEE7E6683FF02B806000000480F44E848638424A00000004C8D3440418D45FF488D7C6D004863C8498BED4C8BAC24A8000000488D344948C1E70349C1E60348C1E603498B4500488D1406488B442438488D0C07FF155A0900004883EE184903FE4883ED0175DC4D8BF5498BCFFF1559090000FF430C488BBC24B0000000488B53204C897B30B80C20000048897C242866894328418B4610418B4C24104D8B44240889442420488B442440488B0CC84C8BCBFF158C180000488D5340488BCFFF15EF080000FF4B0C488D4B28FF15EA080000488D4B40FF15E0080000E939FEFFFFB8030002804C8D5C2450498B5B30498B6B38498B7340498BE3415F415E415D415C5FC348895C24084889742410574883EC20488BD98B4908488BF28D41013B430C765C448D44090248C7C1FFFFFFFFB8080000" & _
			"0049F7E0480F40C1488BC8E8980400004533C9488BF844394B08761B4D8BC1488B0B41FFC1498B1408498914004983C008443B4B0872E8488B0BE88D0400008B4B0848893B8D44090289430C488B03488934C8FF4308488B5C2430488B7424384883C4205FC3CCCCB801000000C3CCCC4883EC28B9A0000000E82A040000488BC833C0483BC87405E89FE9FFFF4883C428C3CCCC40534883EC20488BD9B9A0000000E801040000488BC833C0483BC87408488BD3E83BEAFFFF4883C4205BC3CC48890D4117000048891532170000C3CC48895C240848896C2410488974241857415441554883EC204C8BE1B928000000418BF9498BE8488BF2E8AA0300004533ED488BD8493BC57413488D48084C892844896820FF155E070000EB03498BDD488BD6488BCBC7432001000000897B24E8CCE6FFFF6644396B08740A488D4B08FF1543070000B808000000488BCD66894308FF1539070000488BD3498BCC48894310488B5C2440488B6C2448488B7424504883C420415D415C5FE9B6F6FFFFCCCC48895C240848896C24104889742418574883EC20488BD9E820F6FFFF83F8FF8BF07E43488B5310488B3CF24885FF741F488B0F4885C97405E80F030000488D4F08FF15C1060000488BCFE8FD020000FF4B183B7318730F488B53108B4318488B0CC248890CF2488B5C2430488B6C2438488B7424404883C4205FC3CCE92BF7FF"
	$bBinary &= "FFCCCCCC488BC44889580848896810488970184889782041544883EC204C8BE1B928000000498BF9418BF0488BEAE875020000488BD84885C074144883200083602000488D4808FF152B060000EB0233DBC74320020000004885FF740D488D4B08488BD7FF1516060000488BD5488BCB897324E888E5FFFF488BD3498BCC488B5C2430488B6C2438488B742440488B7C24484883C420415CE997F5FFFFCCCCCC48890D69150000C348895C2408574883EC20488BF9B958000000E8E901000033C9488BD8483BC17434894B08894B0C488D054A07000048890348894B10894B18894B1C488D4B2848897B20FF1587050000488D4B40FF157D050000EB03488BD9488BC3488B5C24304883C4205FC3CCCC48895C2408574883EC20488BF9B958000000488BDAE87E010000488BC833C0483BC8740B4C8BC3488BD7E889F7FFFF488B5C24304883C4205FC3CCCC488BC44889580848896810488970184889782041544883EC20488BF1B918000000418BF9498BE84C8BE2E82D010000488BD84885C0740F488320004883600800834810FFEB0233DB498BD4488BCBE861E4FFFF488BD5488BCB897B10E89FF6FFFF488B13488BCEE804F4FFFF83F8FF750E488D4E10488BD3E807FCFFFFEB3A8BE8488B4610488B3CE84885FF7423488B0F4885C97405E8E5000000488B4F084885C97405E8D7000000488BCFE8CF000000488B46" & _
			"1048891CE8488B5C2430488B6C2438488B742440488B7C24484883C420415CC381F9ADDE0000754A534883EC3081FAEFBE00007538B9F5FFFFFFFF15D80300004883642420004C8D4C2440488D1506060000488BC841B822000000488BD8FF159C030000488BCBFF15A30300004883C4305BC3CC488B0148FF6008CC4883EC384183C9FF4C8BC1B90008000044894C2428488954242033D2FF156A03000083E8024883C438C3CCCC40534883EC20488BD9FF15690300004C8BC3488BC833D24883C4205B48FF2565030000CC40534883EC20488BD9FF15450300004C8BC3488BC833D24883C4205B48FF2539030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" & _
			"00350000000000000C350000000000001E35000000000000323500000000000076350000000000006A350000000000005E3500000000000000000000000000001A00000000000080130000000000008019000000000000800C0000000000008011000000000000800F00000000000080170000000000008008000000000000800A00000000000080090000000000008002000000000000801800000000000080000000000000000000000000000000000000000068D9D94B00000000020000005B0000007C3200007C24000000000000C4100080010000002C140080010000007C100080010000009811008001000000CC11008001000000FC11008001000000A8240080010000005F005F00640065006600610075006C0074005F005F0000007E000000000000005F004E006500770045006E0075006D0000000000000000005F005F006200720069006400670065005F005F00000000005F005F0070006100720061006D0073005F005F00000000005F005F006500720072006F0072005F005F000000000000005F005F0072006500730075006C0074005F005F00000000005F005F00700072006F007000630061006C006C005F005F0000000000000000005F005F006E0061006D0065005F005F0000000000000000001C160080010000002C140080010000003414008001000000A824008001000000A824008001000000"
	$bBinary &= "241600800100000050170080010000005F005F007000740072005F005F0000001C160080010000002C14008001000000EC23008001000000A824008001000000A824008001000000B0240080010000004C250080010000004C6F6C2E20596F7520666F756E6420746865206561737465722D6567672E200D0A00000052534453C3FB1BF8ADF0FE40A329A5C95CC5E3A901000000633A5C55736572735C7472616E636578785C4465736B746F705C4175746F49744F626A656374325C7472756E6B5C4175746F49744F626A6563745F5836342E70646200000104010004620000010D02000D520930010F06000F6407000F3406000F320B70011C0C001C640C001C540B001C340A001C3218F016E014D012C010700106020006520230011C0C001C6412001C5411001C3410001C9218F016E014D012C010700114080014640A00145409001434080014521070011C0C001C6410001C540F001C340E001C7218F016E014D012C01070010A04000A3406000A320670010602000632023001190A0019340E00193215F013E011D00FC00D700C600B50011408001464080014540700143406001432107001160A0016540C0016340B00163212E010D00EC00C700B60011D0C001D740B001D640A001D5409001D3408001D3219E017D015C0010701000782000001190A0019740900196408001954070019340600193215C001180A00" & _
			"18640A001854090018340800183214D012C01070010401000442000058340000000000000000000042350000003000009834000000000000000000005035000040300000000000000000000000000000000000000000000000350000000000000C350000000000001E35000000000000323500000000000076350000000000006A350000000000005E3500000000000000000000000000001A00000000000080130000000000008019000000000000800C0000000000008011000000000000800F00000000000080170000000000008008000000000000800A0000000000008009000000000000800200000000000080180000000000008000000000000000009104577269746546696C65005500436F6D70617265537472696E675700004201466C75736846696C654275666665727300003B0247657453746448616E646C6500004B45524E454C33322E646C6C00004F4C4541555433322E646C6C00009D0248656170416C6C6F6300A10248656170467265650000230247657450726F6365737348656170000000000000000000000000000067D9D94B000000003A360000010000000D0000000D000000B8350000EC35000020360000FC290000D0280000042A00009428000070280000A82A0000102B0000742C0000C0280000A02A0000202C0000802900004C2B00004F36000057360000613600006D3600007F360000" & _
			"92360000A6360000BC360000CB360000D6360000E8360000F83600000537000000000100020003000400050006000700080009000A000B000C004175746F49744F626A6563745F5836342E646C6C00416464456E756D004164644D6574686F640041646450726F706572747900436C6F6E654175746F49744F626A656374004372656174654175746F49744F626A65637400437265617465577261707065724F626A65637400437265617465577261707065724F626A65637445780049556E6B6E6F776E41646452656600496E697469616C697A6500496E697469616C697A6557726170706572004D656D6F727943616C6C456E7472790052656D6F76654D656D62657200577261707065724164644D6574686F6400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
	$bBinary &= "0010000079100000943300007C100000C310000074330000C410000098110000DC33000098110000CB11000014330000CC110000FB11000014330000FC1100002B120000143300002C120000F1120000E8320000F412000029140000C03300003414000030150000A8330000301500001916000094330000241600004D1700006833000050170000BC1F00004C330000BC1F00003420000038330000342000002B210000943300002C2100004B220000F83200004C220000C722000094330000C8220000EA2300007C330000EC230000A824000094330000B024000049250000683300004C250000D02700001C330000D027000066280000E832000070280000922800001434000094280000BF28000074330000D02800007E290000FC33000080290000FB29000094330000042A00009D2A0000E4330000A82A00000E2B000068330000102B00004A2B0000683300004C2B0000202C0000E4330000202C0000732C0000E03200007C2C0000A62C0000D8320000A82C0000CB2C000074330000CC2C0000EF2C0000743300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" & _
			"000000000000000000000000000001001000000018000080000000000000000000000000000001000100000030000080000000000000000000000000000001000904000048000000606000002003000000000000000000000000000000000000200334000000560053005F00560045005200530049004F004E005F0049004E0046004F0000000000BD04EFFE0000010001000100000000000100010000000000000000000000000004000000020000000000000000000000000000007E020000010053007400720069006E006700460069006C00650049006E0066006F0000005A0200000100300034003000390030003400420030000000300008000100460069006C006500560065007200730069006F006E000000000031002E0031002E0030002E0030000000340008000100500072006F006400750063007400560065007200730069006F006E00000031002E0031002E0030002E00300000007A0029000100460069006C0065004400650073006300720069007000740069006F006E0000000000500072006F007600690064006500730020006F0062006A006500630074002000660075006E006300740069006F006E0061006C00690074007900200066006F00720020004100750074006F0049007400000000003A000D000100500072006F0064007500630074004E0061006D006500000000004100750074006F00" & _
			"490074004F0062006A00650063007400000000005E001D0001004C006500670061006C0043006F0070007900720069006700680074000000280043002900200062007900200054006800650020004100750074006F00490074004F0062006A006500630074002D005400650061006D00000000004A00110001004F0072006900670069006E0061006C00460069006C0065006E0061006D00650000004100750074006F00490074004F0062006A006500630074002E0064006C006C00000000007A002300010054006800650020004100750074006F00490074004F0062006A006500630074002D005400650061006D00000000006D006F006E006F00630065007200650073002C0020007400720061006E0063006500780078002C0020004B00690070002C002000500072006F00670041006E006400790000000000440000000100560061007200460069006C00650049006E0066006F00000000002400040000005400720061006E0073006C006100740069006F006E00000000000904B0040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
	$bBinary &= "0030000034000000D0A0D8A0E0A0E8A0F0A0F8A000A1D8A1E0A1E8A1F0A1F8A100A208A220A228A230A238A240A248A250A2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
	Return Binary($bBinary)
EndFunc   ;==>__Au3Obj_Mem_BinDll_X64

#endregion Embedded DLL
;--------------------------------------------------------------------------------------------------------------------------------------


;--------------------------------------------------------------------------------------------------------------------------------------
#region COM Wrapper

Func __Au3Obj_Object_Create($oSelf, $oParent = 0)
	#forceref $oSelf
	Local $oObject = _AutoItObject_Create($oParent)
	$oSelf.Object = $oObject
	Return $oObject
EndFunc   ;==>__Au3Obj_Object_Create

Func __Au3Obj_Object_AddMethod($oSelf, $sName, $sAutoItFunc, $fPrivate = False)
	Local $oObject = $oSelf.Object
	_AutoItObject_AddMethod($oObject, $sName, $sAutoItFunc, $fPrivate)
EndFunc   ;==>__Au3Obj_Object_AddMethod

Func __Au3Obj_Object_AddProperty($oSelf, $sProperty, $iFlags = 0, $vData = "")
	Local $oObject = $oSelf.Object
	_AutoItObject_AddProperty($oObject, $sProperty, $iFlags, $vData)
EndFunc   ;==>__Au3Obj_Object_AddProperty

Func __Au3Obj_Object_AddDestructor($oSelf, $sAutoItFunc)
	Local $oObject = $oSelf.Object
	_AutoItObject_AddDestructor($oObject, $sAutoItFunc)
EndFunc   ;==>__Au3Obj_Object_AddDestructor

Func __Au3Obj_Object_AddEnum($oSelf, $sNextFunc, $sResetFunc, $sSkipFunc = '')
	Local $oObject = $oSelf.Object
	_AutoItObject_AddEnum($oObject, $sNextFunc, $sResetFunc, $sSkipFunc)
EndFunc   ;==>__Au3Obj_Object_AddEnum

Func __Au3Obj_Object_RemoveMember($oSelf, $sMember)
	Local $oObject = $oSelf.Object
	_AutoItObject_RemoveMember($oObject, $sMember)
EndFunc   ;==>__Au3Obj_Object_RemoveMember

#endregion COM Wrapper
;--------------------------------------------------------------------------------------------------------------------------------------


;--------------------------------------------------------------------------------------------------------------------------------------
#region DllStructCreate Wrapper

Func __Au3Obj_ObjStructMethod($oSelf, $vParam1 = 0, $vParam2 = 0)
	Local $sMethod = $oSelf.__name__
	Local $tStructure = DllStructCreate($oSelf.__tag__, $oSelf())
	Local $vOut
	Switch @NumParams
		Case 1
			$vOut = DllStructGetData($tStructure, $sMethod)
		Case 2
			If $oSelf.__propcall__ Then
				$vOut = DllStructSetData($tStructure, $sMethod, $vParam1)
			Else
				$vOut = DllStructGetData($tStructure, $sMethod, $vParam1)
			EndIf
		Case 3
			$vOut = DllStructSetData($tStructure, $sMethod, $vParam2, $vParam1)
	EndSwitch
	If IsPtr($vOut) Then $vOut = Number($vOut)
	Return $vOut
EndFunc   ;==>__Au3Obj_ObjStructMethod

Func __Au3Obj_ObjStructDestructor($oSelf)
	If $oSelf.__new__ Then __Au3Obj_GlobalFree($oSelf())
EndFunc   ;==>__Au3Obj_ObjStructDestructor

#endregion DllStructCreate Wrapper
;--------------------------------------------------------------------------------------------------------------------------------------


;--------------------------------------------------------------------------------------------------------------------------------------
#region Public UDFs

Global Enum $ELTYPE_NOTHING, $ELTYPE_METHOD, $ELTYPE_PROPERTY
Global Enum $ELSCOPE_PUBLIC, $ELSCOPE_READONLY, $ELSCOPE_PRIVATE

; #FUNCTION# ====================================================================================================================
; Name...........: _AutoItObject_Startup
; Description ...: Initializes AutoItObject
; Syntax.........: _AutoItObject_Startup( [$fLoadDLL = False [, $sDll = "AutoitObject.dll"]] )
; Parameters ....: $fLoadDLL    - [optional] specifies whether an external DLL-file should be used (default: False)
;                  $sDLL        - [optional] the path to the external DLL (default: AutoitObject.dll or AutoitObject_X64.dll)
; Return values .: Success      - True
;                  Failure      - False
; Author ........: trancexx, Prog@ndy
; Modified.......:
; Remarks .......: automatically switches between 32bit and 64bit mode if no special DLL is specified
; Related .......: _AutoItObject_Shutdown
; Link ..........;
; Example .......; Yes
; ===============================================================================================================================
Func _AutoItObject_Startup($fLoadDLL = False, $sDll = "AutoitObject.dll")
	Local Static $__Au3Obj_FunctionProxy = DllCallbackGetPtr(DllCallbackRegister("__Au3Obj_FunctionProxy", "int", "wstr;idispatch"))
	Local Static $__Au3Obj_EnumFunctionProxy = DllCallbackGetPtr(DllCallbackRegister("__Au3Obj_EnumFunctionProxy", "int", "dword;wstr;idispatch;ptr;ptr"))
	Local Static $__Au3Obj_WrapFunctionProxy = DllCallbackGetPtr(DllCallbackRegister("__Au3Obj_WrapFunctionProxy", "int", "ptr;ptr;wstr;idispatch;dword;ptr"))
	If $ghAutoItObjectDLL = -1 Then
		If $fLoadDLL Then
			If $__Au3Obj_X64 And @NumParams = 1 Then $sDll = "AutoItObject_X64.dll"
			$ghAutoItObjectDLL = DllOpen($sDll)
		Else
			$ghAutoItObjectDLL = __Au3Obj_Mem_DllOpen()
		EndIf
		If $ghAutoItObjectDLL = -1 Then Return SetError(1, 0, False)
	EndIf
	If $giAutoItObjectDLLRef <= 0 Then
		$giAutoItObjectDLLRef = 0
		DllCall($ghAutoItObjectDLL, "ptr", "Initialize", "ptr", $__Au3Obj_FunctionProxy, "ptr", $__Au3Obj_EnumFunctionProxy)
		If @error Then
			DllClose($ghAutoItObjectDLL)
			$ghAutoItObjectDLL = -1
			Return SetError(2, 0, False)
		EndIf
		DllCall($ghAutoItObjectDLL, "ptr", "InitializeWrapper", "ptr", $__Au3Obj_WrapFunctionProxy)
		If @error Then
			DllClose($ghAutoItObjectDLL)
			$ghAutoItObjectDLL = -1
			Return SetError(3, 0, False)
		EndIf
	EndIf
	$giAutoItObjectDLLRef += 1
	Return True
EndFunc   ;==>_AutoItObject_Startup

; #FUNCTION# ====================================================================================================================
; Name...........: _AutoItObject_Shutdown
; Description ...: frees the AutoItObject DLL
; Syntax.........: _AutoItObject_Shutdown()
; Parameters ....: $fFinal    - [optional] Force shutdown of the library? (Default: False)
; Return values .: Remaining reference count (one for each call to _AutoItObject_Startup)
; Author ........: Prog@ndy
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........;
; Example .......; Yes
; ===============================================================================================================================
Func _AutoItObject_Shutdown($fFinal = False)
	; Author: Prog@ndy
	If $giAutoItObjectDLLRef <= 0 Then Return 0
	$giAutoItObjectDLLRef -= 1
	If $fFinal Then $giAutoItObjectDLLRef = 0
	If $giAutoItObjectDLLRef = 0 Then DllCall($ghAutoItObjectDLL, "ptr", "Initialize", "ptr", 0, "ptr", 0)
	Return $giAutoItObjectDLLRef
EndFunc   ;==>_AutoItObject_Shutdown

; #FUNCTION# ====================================================================================================================
; Name...........: _AutoItObject_WrapperCreate
; Description ...: Creates an IDispatch-Object for COM-Interfaces normally not supportting it.
; Syntax.........: _AutoItObject_WrapperCreate($pUnknown, ByRef $tagInterface)
; Parameters ....: $pUnknown     - Pointer to an IUnknown-Interface not supporting IDispatch
;                  $tagInterface - String defining the methods of the Interface, see Remarks for details
; Return values .: Success      - Dispatch-Object
;                  Failure      - 0, @error set to 1
; Author ........: Prog@ndy
; Modified.......:
; Remarks .......: $tagInterface can be a string in the following format:
;                  "FunctionName ReturnType(ParamType1;ParamType2);FunctionName2 ..."
;                  -FunctionName is the name of the function you want to call later
;                  -ReturnType is the return type (like DLLCall)
;                  -ParamType is the type of the parameter (like DLLCall) [do not include the THIS-param]
;+
;                  alternative Format:
;                  "FunctionName;FunctionName2;..."
;                  This results in an other format for calling the functions later. You must specify the datatypes in the call then
;                  $oObject.function("returntype", "firstparamtype", $firstparam, "2ndtype", $2ndparam, ...)
;+
;                  The reuturn value of a call is always an array (except an error occured, then it is 0):
;                  $array[0] - containts the return value
;                  $array[1] - containts the pointer to the original object
;                  $array[n] - containts the n-1 parameter
; Related .......: _AutoItObject_WrapperAddMethod
; Link ..........;
; Example .......; Yes
; ===============================================================================================================================
Func _AutoItObject_WrapperCreate($pUnknown, ByRef $tagInterface)
	Local $sMethods = __Au3Obj_GetMethods($tagInterface)
	Local $aResult
	If $sMethods Then
		$aResult = DllCall($ghAutoItObjectDLL, "idispatch", "CreateWrapperObjectEx", 'ptr', $pUnknown, 'wstr', $sMethods)
	Else
		$aResult = DllCall($ghAutoItObjectDLL, "idispatch", "CreateWrapperObject", 'ptr', $pUnknown)
	EndIf
	If @error Then Return SetError(1, @error, 0)
	Return $aResult[0]
EndFunc   ;==>_AutoItObject_WrapperCreate

; #FUNCTION# ====================================================================================================================
; Name...........: _AutoItObject_WrapperAddMethod
; Description ...: Adds additional methods to the Wrapper-Object, e.g if you want alternative parameter types
; Syntax.........: _AutoItObject_WrapperAddMethod(ByRef $oWrapper, $sReturnType, $sName, $sParamTypes, $ivtableIndex)
; Parameters ....: $oWrapper     - The Object you want to modify
;                  $sReturnType  - the return type of the function
;                  $sName        - The name of the function
;                  $sParamTypes  - the parameter types
;                  $ivTableIndex - Index of the function in the object's vTable
; Return values .: Success      - True
;                  Failure      - 0
; Author ........: Prog@ndy
; Modified.......:
; Remarks .......:
; Related .......: _AutoItObject_WrapperCreate
; Link ..........;
; Example .......;
; ===============================================================================================================================
Func _AutoItObject_WrapperAddMethod(ByRef $oWrapper, $sReturnType, $sName, $sParamTypes, $ivtableIndex)
	; Author: Prog@ndy
	If Not IsObj($oWrapper) Then Return SetError(2, 0, 0)
	DllCall($ghAutoItObjectDLL, "none", "WrapperAddMethod", 'idispatch', $oWrapper, 'wstr', $sName, "wstr", StringRegExpReplace($sReturnType & ';' & $sParamTypes, "\s|(;+\Z)", ''), 'dword', $ivtableIndex)
	If @error Then Return SetError(1, @error, 0)
	Return True
EndFunc   ;==>_AutoItObject_WrapperAddMethod

; #FUNCTION# ====================================================================================================================
; Name...........: _AutoItObject_Class
; Description ...: AutoItObject COM wrapper function
; Syntax.........: _AutoItObject_Class()
; Parameters ....:
; Return values .: Success      - object AutoItObject with defined;
;                  |methods:
;                  |	Create([$oParent = 0]) - creates object
;                  |	AddMethod($sName, $sAutoItFunc [, $fPrivate = False]) - adds new method
;                  |	AddProperty($sName, $iFlags = $ELSCOPE_PUBLIC, $vData = 0) - adds new property
;                  |	AddDestructor($sAutoItFunc) - adds destructor
;                  |	AddEnum($sNextFunc, $sResetFunc [, $sSkipFunc = '']) - adds enum
;                  |	RemoveMember($sMember) - removes member
;                  |properties:
;                  |	Object - readonly property representing the last created object
; Author ........: trancexx
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........;
; Example .......;
; ===============================================================================================================================
Func _AutoItObject_Class()
	Local $oObj = _AutoItObject_Create()
	_AutoItObject_AddMethod($oObj, "Create", "__Au3Obj_Object_Create")
	_AutoItObject_AddMethod($oObj, "AddMethod", "__Au3Obj_Object_AddMethod")
	_AutoItObject_AddMethod($oObj, "AddProperty", "__Au3Obj_Object_AddProperty")
	_AutoItObject_AddMethod($oObj, "AddDestructor", "__Au3Obj_Object_AddDestructor")
	_AutoItObject_AddMethod($oObj, "AddEnum", "__Au3Obj_Object_AddEnum")
	_AutoItObject_AddMethod($oObj, "RemoveMember", "__Au3Obj_Object_RemoveMember")
	_AutoItObject_AddProperty($oObj, "Object", $ELSCOPE_READONLY)
	Return $oObj
EndFunc   ;==>_AutoItObject_Class

; #FUNCTION# ====================================================================================================================
; Name...........: _AutoItObject_Create
; Description ...: Creates an AutoIt-object
; Syntax.........: _AutoItObject_Create( [$oParent = 0] )
; Parameters ....: $oParent     - [optional] an AutoItObject whose methods & properties are copied. (default: 0)
; Return values .: Success      - AutoIt-Object
;                  Failure      - 0
; Author ........: Prog@ndy
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........;
; Example .......; Yes
; ===============================================================================================================================
Func _AutoItObject_Create($oParent = 0)
	; Author: Prog@ndy
	Local $aResult
	Switch IsObj($oParent)
		Case True
			$aResult = DllCall($ghAutoItObjectDLL, "idispatch", "CloneAutoItObject", 'idispatch', $oParent)
		Case Else
			$aResult = DllCall($ghAutoItObjectDLL, "idispatch", "CreateAutoItObject")
	EndSwitch
	If @error Then Return SetError(1, @error, 0)
	Return $aResult[0]
EndFunc   ;==>_AutoItObject_Create

; #FUNCTION# ====================================================================================================================
; Name...........: _AutoItObject_AddMethod
; Description ...: Adds a method to an AutoIt-object
; Syntax.........: _AutoItObject_AddMethod(ByRef $oObject, $sName, $sAutoItFunc [, $fPrivate = False])
; Parameters ....: $oObject     - the object to modify
;                  $sName       - the name of the method to add
;                  $sAutoItFunc - the AutoIt-function wich represents this method.
;                  $fPrivate    - [optional] Specifies whether the function can only be called from within the object. (default: False)
; Return values .: Success      - True
;                  Failure      - 0
; Author ........: Prog@ndy
; Modified.......:
; Remarks .......: The first parameter of the AutoIt-function is always a reference to the object. ($oSelf)
;                  This parameter will automatically be added and must not be given in the call.
;                  The function called '__default__' is accesible without a name using brackets ($return = $oObject())
; Related .......: _AutoItObject_AddProperty, _AutoItObject_AddEnum, _AutoItObject_RemoveMember
; Link ..........;
; Example .......; Yes
; ===============================================================================================================================
Func _AutoItObject_AddMethod(ByRef $oObject, $sName, $sAutoItFunc, $fPrivate = False)
	; Author: Prog@ndy
	If Not IsObj($oObject) Then Return SetError(2, 0, 0)
	Local $iFlags = 0
	If $fPrivate Then $iFlags = $ELSCOPE_PRIVATE
	DllCall($ghAutoItObjectDLL, "none", "AddMethod", "idispatch", $oObject, "wstr", $sName, "wstr", $sAutoItFunc, 'dword', $iFlags)
	If @error Then Return SetError(1, @error, 0)
	Return True
EndFunc   ;==>_AutoItObject_AddMethod


; #FUNCTION# ====================================================================================================================
; Name...........: _AutoItObject_AddProperty
; Description ...: Adds a property to an AutoIt-object
; Syntax.........: _AutoItObject_AddProperty(ByRef $oObject, $sName, $iFlags = $ELSCOPE_PUBLIC, $vData = 0)
; Parameters ....: $oObject     - the object to modify
;                  $sName       - the name of the property to add
;                  $iFlags      - Specifies the access to the property. This parameter can be one of the following values:
;                  |$ELSCOPE_PUBLIC   - The Property has public access.
;                  |$ELSCOPE_READONLY - The property is read-only and can only be changed from within the object.
;                  |$ELSCOPE_PRIVATE  - The property is private and can only be accessed from within the object.
; Return values .: Success      - True
;                  Failure      - 0
; Author ........: Prog@ndy
; Modified.......:
; Remarks .......: The property called '__default__' is accesible without a name using brackets ($value = $oObject())
; Related .......: _AutoItObject_AddMethod, _AutoItObject_AddEnum, _AutoItObject_RemoveMember
; Link ..........;
; Example .......; Yes
; ===============================================================================================================================
Func _AutoItObject_AddProperty(ByRef $oObject, $sName, $iFlags = $ELSCOPE_PUBLIC, $vData = 0)
	; Author: Prog@ndy
	Local Static $tStruct = DllStructCreate($__Au3Obj_tagVARIANT)
	If Not IsObj($oObject) Then Return SetError(2, 0, 0)
	Local $pData = 0
	If @NumParams = 4 Then
		$pData = DllStructGetPtr($tStruct)
		__Au3Obj_VariantInit($pData)
		$oObject.__bridge__(Number($pData)) = $vData
	EndIf
	DllCall($ghAutoItObjectDLL, "none", "AddProperty", "idispatch", $oObject, "wstr", $sName, 'dword', $iFlags, 'ptr', $pData)
	Local $error = @error
	If $pData Then _AutoItObject_VariantClear($pData)
	If $error Then Return SetError(1, $error, 0)
	Return True
EndFunc   ;==>_AutoItObject_AddProperty

; #FUNCTION# ====================================================================================================================
; Name...........: _AutoItObject_AddDestructor
; Description ...: Adds a destructor to an AutoIt-object
; Syntax.........: _AutoItObject_AddDestructor(ByRef $oObject,$sAutoItFunc)
; Parameters ....: $oObject     - the object to modify
;                  $sAutoItFunc - the AutoIt-function wich represents this destructor.
; Return values .: Success      - True
;                  Failure      - 0
; Author ........: monoceres (Andreas Karlsson)
; Modified.......:
; Remarks .......: Adding a method that will be called on object destruction. Can be called multiple times.
; Related .......: _AutoItObject_AddProperty, _AutoItObject_AddEnum, _AutoItObject_RemoveMember, _AutoItObject_AddMethod
; Link ..........;
; Example .......; Yes
; ===============================================================================================================================
Func _AutoItObject_AddDestructor(ByRef $oObject, $sAutoItFunc)
	Return _AutoItObject_AddMethod($oObject, "~", $sAutoItFunc, True)
EndFunc   ;==>_AutoItObject_AddDestructor

; #FUNCTION# ====================================================================================================================
; Name...........: _AutoItObject_AddEnum
; Description ...: Adds an Enum to an AutoIt-object
; Syntax.........: _AutoItObject_AddEnum(ByRef $oObject, $sNextFunc, $sResetFunc [, $sSkipFunc = ''])
; Parameters ....: $oObject     - the object to modify
;                  $sNextFunc   - The function to be called to get the next entry
;                  $sResetFunc  - The function to be called to reset the enum
;                  $sSkipFunc   - [optional] The function to be called to skip elements (not supported by AutoIt)
; Return values .: Success      - True
;                  Failure      - 0
; Author ........: Prog@ndy
; Modified.......:
; Remarks .......:
; Related .......: _AutoItObject_AddMethod, _AutoItObject_AddProperty, _AutoItObject_RemoveMember
; Link ..........;
; Example .......;
; ===============================================================================================================================
Func _AutoItObject_AddEnum(ByRef $oObject, $sNextFunc, $sResetFunc, $sSkipFunc = '')
	; Author: Prog@ndy
	If Not IsObj($oObject) Then Return SetError(2, 0, 0)
	DllCall($ghAutoItObjectDLL, "none", "AddEnum", "idispatch", $oObject, "wstr", $sNextFunc, "wstr", $sResetFunc, "wstr", $sSkipFunc)
	If @error Then Return SetError(1, @error, 0)
	Return True
EndFunc   ;==>_AutoItObject_AddEnum

; #FUNCTION# ====================================================================================================================
; Name...........: _AutoItObject_RemoveMember
; Description ...: Removes a property or a function from an AutoIt-object
; Syntax.........: _AutoItObject_RemoveMember(ByRef $oObject, $sMember)
; Parameters ....: $oObject     - the object to modify
;                  $sMember     - the name of the member to remove
; Return values .: Success      - True
;                  Failure      - 0
; Author ........: Prog@ndy
; Modified.......:
; Remarks .......:
; Related .......: _AutoItObject_AddMethod, _AutoItObject_AddProperty, _AutoItObject_AddEnum
; Link ..........;
; Example .......; Yes
; ===============================================================================================================================
Func _AutoItObject_RemoveMember(ByRef $oObject, $sMember)
	; Author: Prog@ndy
	If Not IsObj($oObject) Then Return SetError(2, 0, 0)
	If $sMember = '__default__' Then Return SetError(3, 0, 0)
	DllCall($ghAutoItObjectDLL, "none", "RemoveMember", "idispatch", $oObject, "wstr", $sMember)
	If @error Then Return SetError(1, @error, 0)
	Return True
EndFunc   ;==>_AutoItObject_RemoveMember

; #FUNCTION# ====================================================================================================================
; Name...........: _AutoItObject_IUnknownAddRef
; Description ...: Increments the refrence count of an IUnknown-Object
; Syntax.........: _AutoItObject_IUnknownAddRef(ByRef $pUnknown)
; Parameters ....: $pUnknown    - IUnkown-pointer
; Return values .: Success      - True
;                  Failure      - 0
; Author ........: Prog@ndy
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........;
; Example .......;
; ===============================================================================================================================
Func _AutoItObject_IUnknownAddRef(Const $pUnknown)
	; Author: Prog@ndy
	DllCall($ghAutoItObjectDLL, "none", "IUnknownAddRef", "ptr", $pUnknown)
	If @error Then Return SetError(1, @error, 0)
	Return True
EndFunc   ;==>_AutoItObject_IUnknownAddRef

; #FUNCTION# ====================================================================================================================
; Name...........: _AutoItObject_CLSIDFromString
; Description ...: Converts a string to a CLSID-Struct (GUID-Struct)
; Syntax.........: _AutoItObject_CLSIDFromString($sString, ByRef $tCLSID)
; Parameters ....: $sString     - The string to convert
; Return values .: Success      - DLLStruct in format $tagGUID
;                  Failure      - 0
; Author ........: Prog@ndy
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........; @@MsdnLink@@ CLSIDFromString
; Example .......; Yes
; ===============================================================================================================================
Func _AutoItObject_CLSIDFromString($sString)
	Local $tCLSID = DllStructCreate("dword;word;word;byte[8]")
	Local $aResult = DllCall($gh_AU3Obj_ole32dll, 'long', 'CLSIDFromString', 'wstr', $sString, 'ptr', DllStructGetPtr($tCLSID))
	If @error Then Return SetError(1, @error, 0)
	If $aResult[0] <> 0 Then Return SetError(2, $aResult[0], 0)
	Return $tCLSID
EndFunc   ;==>_AutoItObject_CLSIDFromString

; #FUNCTION# ====================================================================================================================
; Name...........: _AutoItObject_CoCreateInstance
; Description ...: Creates a single uninitialized object of the class associated with a specified CLSID.
; Syntax.........: _AutoItObject_CoCreateInstance($rclsid, $pUnkOuter, $dwClsContext, $riid, ByRef $ppv)
; Parameters ....: $rclsid       - [in] The CLSID associated with the data and code that will be used to create the object.
;                  $pUnkOuter    - [in] If NULL, indicates that the object is not being created as part of an aggregate.
;                  +If non-NULL, pointer to the aggregate object's IUnknown interface (the controlling IUnknown).
;                  $dwClsContext - [in] Context in which the code that manages the newly created object will run.
;                  +The values are taken from the enumeration CLSCTX.
;                  $riid         - [in] A reference to the identifier of the interface to be used to communicate with the object.
;                  $ppv          - [out] Address of pointer variable that receives the interface pointer requested in riid.
;                  +Upon successful return, *ppv contains the requested interface pointer. Upon failure, *ppv contains NULL.
; Return values .: Success      - True
;                  Failure      - 0
; Author ........: Prog@ndy
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........; @@MsdnLink@@ CoCreateInstance
; Example .......; Yes
; ===============================================================================================================================
Func _AutoItObject_CoCreateInstance($rclsid, $pUnkOuter, $dwClsContext, $riid, ByRef $ppv)
	$ppv = 0
	Local $aResult = DllCall($gh_AU3Obj_ole32dll, 'long', 'CoCreateInstance', 'ptr', $rclsid, 'ptr', $pUnkOuter, 'dword', $dwClsContext, 'ptr', $riid, 'ptr*', 0)
	If @error Then Return SetError(1, @error, 0)
	$ppv = $aResult[5]
	Return SetError($aResult[0], 0, $aResult[0] = 0)
EndFunc   ;==>_AutoItObject_CoCreateInstance

; #FUNCTION# ====================================================================================================================
; Name...........: _AutoItObject_PtrToIDispatch
; Description ...: Converts IDispatch pointer to AutoIt's object type
; Syntax.........: _AutoItObject_PtrToIDispatch($pIDispatch)
; Parameters ....: $pIDispatch  - IDispatch pointer
; Return values .: Success      - object type
;                  Failure      - 0
; Author ........: monoceres, trancexx
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........; @@MsdnLink@@ RtlMoveMemory
; Example .......;
; ===============================================================================================================================
Func _AutoItObject_PtrToIDispatch($pIDispatch)
	Local $aCall = DllCall($gh_AU3Obj_kernel32dll, "none", "RtlMoveMemory", "idispatch*", 0, "ptr*", $pIDispatch, "dword", $__Au3Obj_tagPTR_SIZE)
	If @error Then Return SetError(1, 0, 0)
	Return $aCall[1]
EndFunc   ;==>_AutoItObject_PtrToIDispatch

; #FUNCTION# ====================================================================================================================
; Name...........: _AutoItObject_IDispatchToPtr
; Description ...: Returns pointer to AutoIt's object type
; Syntax.........: _AutoItObject_IDispatchToPtr(ByRef $oIDispatch)
; Parameters ....: $oIDispatch  - Object
; Return values .: Success      - Pointer to object
;                  Failure      - 0
; Author ........: monoceres, trancexx
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........; @@MsdnLink@@ RtlMoveMemory
; Example .......; Yes
; ===============================================================================================================================
Func _AutoItObject_IDispatchToPtr(ByRef $oIDispatch)
	Local $aCall = DllCall($gh_AU3Obj_kernel32dll, "none", "RtlMoveMemory", "ptr*", 0, "idispatch*", $oIDispatch, "dword", $__Au3Obj_tagPTR_SIZE)
	If @error Then Return SetError(1, 0, 0)
	Return $aCall[1]
EndFunc   ;==>_AutoItObject_IDispatchToPtr

; #FUNCTION# ====================================================================================================================
; Name...........: _AutoItObject_DllStructCreate
; Description ...: Object wrapper for DllStructCreate and related functions
; Syntax.........: _AutoItObject_DllStructCreate($sTag [, $vParam = 0])
; Parameters ....: $sTag     - A string representing the structure to create (same as with DllStructCreate)
;                  $vParam   - [optional] If this parameter is DLLStruct type then it will be copied to newly allocated space and maintained during lifetime of the object.
;                  + If this parameter is not suplied needed memory allocation is done but content is initialized to zero.
;                  + In all other cases function will not allocate memory but use parameter supplied as the pointer (same as DllStructCreate)
; Return values .: Success      - Object-structure
;                  Failure      - 0
;                  @error is set to error value of DllStructCreate() function.
; Author ........: trancexx
; Modified.......:
; Remarks .......: AutoIt can't handle pointers properly when passed to or returned from object methods. Use Number() function on pointers before using them with this function.
;                  Every element of structure must be named. Values are accessed through their names.
;                  Created object exposes:
;                  |- set of dynamic methods in names of elements of the structure
;                  |- readonly properties:
;                  |	__tag__ - a string representing the object-structure
;                  |	__size__ - the size of the struct in bytes
;                  |	__alignment__ - alignment string (e.g. "align 2")
;                  |	__count__ - number of elements of structure
;                  |	__elements__ - string made of element names separated by semicolon (";")
; Related .......:
; Link ..........;
; Example .......; Yes
; ===============================================================================================================================
Func _AutoItObject_DllStructCreate($sTag, $vParam = 0)
	Local $oObj = _AutoItObject_Create()
	Local $fNew = False
	Local $tSubStructure = DllStructCreate($sTag)
	If @error Then Return SetError(@error, 0, 0)
	Local $iSize = DllStructGetSize($tSubStructure)
	Local $pPointer = $vParam
	Select
		Case @NumParams = 1
			$pPointer = __Au3Obj_GlobalAlloc($iSize, 64) ; GPTR
			If @error Then Return SetError(3, 0, 0)
			$fNew = True
		Case IsDllStruct($vParam)
			$pPointer = __Au3Obj_GlobalAlloc($iSize, 64) ; GPTR
			If @error Then Return SetError(3, 0, 0)
			$fNew = True
			DllStructSetData(DllStructCreate("byte[" & $iSize & "]", $pPointer), 1, DllStructGetData(DllStructCreate("byte[" & $iSize & "]", DllStructGetPtr($vParam)), 1))
		Case @NumParams = 2 And $vParam = 0
			Return SetError(3, 0, 0)
	EndSelect
	Local $sAlignment
	Local $sNamesString = __Au3Obj_ObjStructGetElements($sTag, $sAlignment)
	Local $aElements = StringSplit($sNamesString, ";", 2)
	For $i = 0 To UBound($aElements) - 1
		_AutoItObject_AddMethod($oObj, $aElements[$i], "__Au3Obj_ObjStructMethod")
	Next
	_AutoItObject_AddProperty($oObj, "__tag__", $ELSCOPE_READONLY, $sTag)
	_AutoItObject_AddProperty($oObj, "__size__", $ELSCOPE_READONLY, $iSize)
	_AutoItObject_AddProperty($oObj, "__alignment__", $ELSCOPE_READONLY, $sAlignment)
	_AutoItObject_AddProperty($oObj, "__count__", $ELSCOPE_READONLY, UBound($aElements))
	_AutoItObject_AddProperty($oObj, "__elements__", $ELSCOPE_READONLY, $sNamesString)
	_AutoItObject_AddProperty($oObj, "__new__", $ELSCOPE_PRIVATE, $fNew)
	_AutoItObject_AddProperty($oObj, "__default__", $ELSCOPE_READONLY, Number($pPointer))
	_AutoItObject_AddDestructor($oObj, "__Au3Obj_ObjStructDestructor")
	Return $oObj
EndFunc   ;==>_AutoItObject_DllStructCreate

#endregion Public UDFs
;--------------------------------------------------------------------------------------------------------------------------------------

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
#Obfuscator_On
#Obfuscator_On
#Obfuscator_On
#Obfuscator_On
#Obfuscator_On
#Obfuscator_On
#Obfuscator_On
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
Global $ignore[100]
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

Switch IniRead($file, "Benutzerdaten", "Group", "Level One")
Case "Banned Users"
MsgBox(64, "Banned", "Du bist in Elitepvpers gebannt! Dieses Tool schließt sich automatisch")
Exit 0
;Case "Moderators", "Global Moderators", "Co-Administrators", "Administrators"
EndSwitch

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
$ignorecheck = GUICtrlCreateCheckbox("Ignorierte User ausblenden", 260 - $MPG, 510)
GUICtrlSetOnEvent(-1, "Settings")
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
If (GUICtrlRead($naughtymode) <> 4 And $naughty = False) Or (GUICtrlRead($naughtymode) = 4 And $naughty = True) Or GUICtrlRead($channel) <> IniRead($file, "Shoutbox", "Channel", "Deutsch") Then
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

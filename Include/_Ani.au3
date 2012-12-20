#AutoIt3Wrapper_AU3Check_Parameters= -d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6

#cs
    ;#=#INDEX#==========================================================================================
==================================#
    ;#  Title .........: _Ani.au3
    ;#  Description ...: Animated Controls (.ani/.gif) for AutoIt.
    ;#  Date ..........: 31.05.09
    ;#  Version .......: 1.6 (some minor bugs fixed, added _Ani_SetGifExFrame)
    ;#  History .......: 26.05.09 v 1.5 (added GDIplus based functions - now all GIFs should be working ! smile.gif , using controlhandles instead of control IDs, bug fixing)
    ;#           23.05.05 v 1.4 (added _Ani_GetGifInfo(), some errors fixed, accelerated decoding, code cleaning)
    ;#           22.05.09 v 1.3 (GIF87a support, slow mode for problematic gifs, minor improvements)
    ;#           21.05.09 v 1.2 (improved timer handling, negative speed, immediate speed reaction, functions added, reduced number of callbacks, minor corrections, code designed)
    ;#           20.05.09 v 1.1 (added gif support, included timer functions, minor corrections)
    ;#           19.05.09 v 1.0
    ;#  Author ........: jennico (jennicoattminusonlinedotde)  ©  2009 by jennico
    ;#  AutoIt Version : written in v 3.2.12.1
    ;#  Remarks .......: Both gif formats, "GIF87a" and "GIF89a" now supported.
    ;#           The fastest decoding works for "GIF89a" formatted gifs with Graphic Context Extension (GCE) block. This is true for 98% of the animated gif files.
    ;#           If the display of the animation fails, try to use GUICtrlCreateGif / GUICtrlSetAni / GUICtrlSetFrame / _Ani_GetFrames with the 'hslow' flag set to 1. This may work with some exotic animated gifs.
    ;#           "Slow Mode" does NOT mean that the animation is slower, it means that the initialization (splitting) of the gif file is more precise and therefore slower. The animation speed is the same !
    ;#           If animation still fails, try GUICtrlCreateGifEx(). This uses GDIplus and seems to be able to display all kinds of gifs correctly.
    ;#  Main Functions : GUISetAni( $hfile, $hWnd [, $hspeed ] )  Sets an animated GUI Icon.
    ;#           GUISetFrame( $hfile, $iframe, $hWnd )  Sets the specified frame Icon of an ani file to the GUI caption.
    ;#           TraySetAni( $hfile, $hWnd [, $hspeed ] )  Sets an animated Tray Icon.
    ;#           TraySetFrame( $hfile, $iframe )  Sets the specified frame Icon of an ani file to the Tray.
    ;#           GUICtrlCreateGif( $hWnd, $hfile, $x, $y [, $w [, $h [, $istyle [, $iexstyle [, $hspeed [, $hslow ]]]]]] )  Creates an animated .gif based GUI Control.
    ;#           GUICtrlCreateGifEx( $hWnd, $hfile, $x, $y [, $hspeed ] )  Creates an animated .gif based GUI Control GDIplus style.
    ;#           GUICtrlCreateAni( $hWnd, $hfile, $x, $y [, $w [, $h [, $istyle [, $iexstyle [, $hspeed ]]]]] )  Creates an animated .ani based GUI Control.
    ;#           GUICtrlSetAni( $hWnd, $hctrl, $hfile [, $hspeed [, $hslow ]] )  Sets an animated Icon (.ani) to an Ani / Icon control resp. an animated Gif (.gif) to a Gif / Pic control.
    ;#           GUICtrlSetFrame( $hctrl, $hfile, $iframe [, $hslow ] )  Sets the specified frame image of an ani file to an Ani / Icon control resp. of an animated .gif file to a Gif / Pic control.
    ;#           _Ani_SetGifExFrame( $hctrl, $iframe )  Displays the specified frame image of an animated .gif file the GDIplus way.
    ;#           _Ani_DeleteAnimation( [$hWnd] )  Stops an animation.
    ;#           _Ani_PauseAnimation( $paused [, $hWnd ] )  Sets the animation speed.
    ;#           _Ani_SetAnimationSpeed( $hspeed [, $hWnd ] )  Sets the animation speed.
    ;#           _Ani_GetFrames( $hfile [, $hslow ] )  Retrieves the number of frames in a gif or ani file.
    ;#           _Ani_GetGifSize( $hfile )  Retrieves the size of a gif (GIF89a format) file.
    ;#           _Ani_GetGifInfo( $hfile [, $idisplay ] )  Retrieves advanced information of a gif file (only GIF89a format with Graphic Control Extension (GCE) block).
    ;#  Internal ......: __Ani_GetInstance($hctrl [, $hmode ])
    ;#           __Ani_SplitAni($id, $hfile [, $hslow [, $hWnd [, $hctrl [, $hspeed ]]]])
    ;#           __Ani_SplitGif($id, $hfile, $hWnd, $hctrl, $hspeed, $hslow)
    ;#           __Ani_SplitGifEx($id, $read, $hWnd, $hctrl, $hspeed)
    ;#           __Ani_SetArray($id, $hWnd, $hctrl, $hcount, $hspeed)
    ;#           __Ani_SetSteps($hsteps)
    ;#           __Ani_GetTimer($hWnd, $Msg, $iIDTimer, $dwTime)
    ;#           __Ani_SetAni($id)
    ;#           __Ani_SetObjectAni($id, $hcount)
    ;#           __Ani_SetCtrlAni($id, $hcount)
    ;#           __Ani_SetGUIAni($id, $hcount)
    ;#           __Ani_SetTrayAni($id, $hcount)
    ;#           __Ani_OnAutoItExit()
    ;#==================================================================================================
==================================#
#ce

;#include <GDIPlus.au3>
#Include <Timers.au3>

_GDIPlus_Startup ()

#Region;--------------------------Global declarations

Global Const $tagGifGraphicsControlExtension = 'byte Introducer;' & _ ; /* Extension Introducer (always 21h) */
        'byte Label;' & _ ; /* Graphic Control Label (always F9h) */
        'byte BlockSize;' & _ ; /* Size of remaining fields (always 04h) */
        'byte Packed;' & _ ; /* Method of graphics disposal to use */
        'ushort DelayTime;' & _ ; /* Hundredths of seconds to wait   */
        'byte ColorIndex;' & _ ; /* Transparent Color Index */
        'byte Terminator;' & _ ; /* Block Terminator (always 0) */
        ''
Global Const $tagGifLogicalScreenDescriptor = 'ushort ScreenWidth;' & _ ; /* Width of Display Screen in Pixels */   ;2 byte = ushort
        'ushort ScreenHeight;' & _ ; /* Height of Display Screen in Pixels */
        'byte Packed;' & _ ; /* Screen and Color Map Information */
        'byte BackgroundColor;' & _ ; /* Background Color Index */
        'byte AspectRatio;' & _ ; /* Pixel Aspect Ratio */
        ''
;   Local Image Descriptor
Global Const $tagGifImageDescriptor = 'byte Separator;' & _ ; /* Image Descriptor identifier */  2C
        'ushort Left;' & _ ; /* X position of image on the display */
        'ushort Top;' & _ ; /* Y position of image on the display */
        'ushort Width;' & _; /* Width of the image in pixels */
        'ushort Height;' & _ ; /* Height of the image in pixels */
        'byte Packed;' & _; /* Image and Color Table Data Information */
        '';

Global Const $tagANIHeader = 'dword cbSizeOf;' & _ ; // Num bytes in AniHeader (36 bytes)
        'dword cFrames;' & _ ; // Number of unique Icons in this cursor
        'dword cSteps;' & _ ; // Number of Blits before the animation cycles = frames, if no seq chunk
        'dword cx;' & _ ; // reserved, must be zero.
        'dword cy;' & _ ; // reserved, must be zero.
        'dword cBitCount;' & _ ; // reserved, must be zero.
        'dword cPlanes;' & _ ; // reserved, must be zero.{ 1 Jiffy = 1/60 sec }
        'dword JifRate;' & _ ; // Default Jiffies (1/60th of a second) if rate chunk not present.
        'dword flags' & _ ; // Animation Flag (see AF_ constants)
        ''

;Global Const $AF_ICON     = 0x00000001;
;Global Const $AF_SEQUENCE = 0x00000002;
;Global Const $FOURCC_ACON = 'ACON';
Global Const $FOURCC_RIFF = 'RIFF'
;Global Const $FOURCC_INFO = 'INFO';
Global Const $FOURCC_INAM = 'INAM'
Global Const $FOURCC_IART = 'IART'
;Global Const $FOURCC_LIST = 'LIST';
Global Const $FOURCC_anih = 'anih'
Global Const $FOURCC_rate = 'rate'
Global Const $FOURCC_seq = 'seq '
Global Const $FOURCC_fram = 'fram'
Global Const $FOURCC_icon = 'icon'

Global Const $_ani_Callback = '__Ani_GetTimer'
Global Const $_ani_Separator = Chr(0x21) & Chr(0xF9) & Chr(0x04)
;~ Global Const $_ani_ExitOpt = Opt('OnExitFunc', '__Ani_OnAutoItExit')
Global Const $_ani_ExitOpt = OnAutoItExitRegister('__Ani_OnAutoItExit')
Global Const $_ani_TempDir = @TempDir & '\_ani.au3\' & @AutoItPID & '_'

Global $_ani_Array[12][1], $_ani_Data[1][1][2], $_ani_Instance, $_ani_Steps = 1

#EndRegion;--------------------------Global declarations
#Region;--------------------------Main Functions

#cs
    ;#=#Function#================================================#
    ;#  Name ..........: GUISetAni( $hfile, $hWnd [, $hspeed ] )
    ;#  Description ...: Sets an animated GUI Icon.
    ;#  Parameters ....: $hfile = The .ani file to be set.
    ;#           $hWnd = The GUI handle as returned by GuiCreate().
    ;#           $hspeed = [optional] The animation speed (Default = 1).
    ;#  Return Value ..: Success: Returns 1.
    ;#           Failure: Returns 0.
    ;#  Author ........: jennico
    ;#  Date ..........: 19.05.09
    ;#  Example .......: yes
    ;#===========================================================#
#ce

Func GUISetAni($hfile, $hWnd, $hspeed = 1)
    If FileExists($hfile) = 0 Or IsHWnd($hWnd) = 0 Then Return
    Local $id = __Ani_GetInstance($hWnd)
    If __Ani_SplitAni($id, $hfile, 0, $hWnd, $hWnd, $hspeed) = 0 Then Return
    $_ani_Array[6][$id] = '__Ani_SetGUIAni'
    Return GUISetIcon($_ani_TempDir & $id & '_' & $_ani_Data[$id][$_ani_Array[3][$id]][0], 0, $hWnd)
EndFunc   ;==>GUISetAni

#cs
    ;#=#Function#================================================#
    ;#  Name ..........: GUISetFrame( $hfile, $iframe, $hWnd )
    ;#  Description ...: Sets the specified frame Icon of an ani file to the GUI caption.
    ;#  Parameters ....: $hfile = The animated Icon to be split (.ani).
    ;#           $iframe = The frame number to be displayed (1 is first).
    ;#           $hWnd = [optional] The GUI handle as returned by GuiCreate(). Default is the current GUI.
    ;#  Return Value ..: Success: Returns 1.
    ;#           Failure: Returns 0.
    ;#  Author ........: jennico
    ;#  Date ..........: 21.05.09
    ;#  Example .......: yes
    ;#===========================================================#
#ce

Func GUISetFrame($hfile, $iframe, $hWnd)
    If IsHWnd($hWnd) And FileExists($hfile) And __Ani_SplitAni(-1, $hfile, 0, 0, $iframe) Then Return GUISetIcon($_ani_TempDir & '-1_' & $iframe - 1, 0, $hWnd)
EndFunc   ;==>GUISetFrame

#cs
    ;#=#Function#================================================#
    ;#  Name ..........: TraySetAni( $hfile, $hWnd [, $hspeed ] )
    ;#  Description ...: Sets an animated Tray Icon.
    ;#  Parameters ....: $hfile = The .ani file to be set.
    ;#           $hWnd = One of the GUI handles as returned by GuiCreate().
    ;#           $hspeed = [optional] The animation speed (Default = 1).
    ;#  Return Value ..: Success: Returns 1.
    ;#           Failure: Returns 0.
    ;#  Author ........: jennico
    ;#  Date ..........: 19.05.09
    ;#  Example .......: yes
    ;#===========================================================#
#ce

Func TraySetAni($hfile, $hWnd, $hspeed = 1)
    If FileExists($hfile) = 0 Or IsHWnd($hWnd) = 0 Then Return
    Local $id = __Ani_GetInstance('Tray')
    If __Ani_SplitAni($id, $hfile, 0, $hWnd, 'Tray', $hspeed) = 0 Then Return
    $_ani_Array[6][$id] = '__Ani_SetTrayAni'
    Return TraySetIcon($_ani_TempDir & $id & '_' & $_ani_Data[$id][$_ani_Array[3][$id]][0], 0)
EndFunc   ;==>TraySetAni

#cs
    ;#=#Function#================================================#
    ;#  Name ..........: TraySetFrame( $hfile, $iframe )
    ;#  Description ...: Sets the specified frame Icon of an ani file to the Tray.
    ;#  Parameters ....: $hfile = The animated file to be split (.ani or .gif supported).
    ;#           $iframe = The frame number to be displayed (1 is first).
    ;#  Return Value ..: Success: Returns 1.
    ;#           Failure: Returns 0.
    ;#  Author ........: jennico
    ;#  Date ..........: 21.05.09
    ;#  Example .......: yes
    ;#===========================================================#
#ce

Func TraySetFrame($hfile, $iframe)
    If FileExists($hfile) And __Ani_SplitAni(-1, $hfile, 0, 0, $iframe) Then Return TraySetIcon($_ani_TempDir & '-1_' & $iframe - 1, 0)
EndFunc   ;==>TraySetFrame

#cs
    ;#=#Function#================================================#
    ;#  Name ..........: GUICtrlCreateGif( $hWnd, $hfile, $x, $y [, $w [, $h [, $istyle [, $iexstyle [, $hspeed [, $hslow ]]]]]] )
    ;#  Description ...: Creates an animated .gif based GUI Control.
    ;#  Parameters ....: $hWnd = The GUI handle as returned by GuiCreate().
    ;#           $hfile = The .gif file to be set.
    ;#           $x = The left side of the control. If -1 is used then left will be computed according to GUICoordMode.
    ;#           $y = The top of the control. If -1 is used then top will be computed according to GUICoordMode.
    ;#           $w = [optional] The width of the control (default is the previously used width).
    ;#           $h = [optional] The height of the control (default is the previously used height).
    ;#           $istyle = [optional] Defines the style of the control. See GUI Control Styles Appendix. Default (-1) : $SS_NOTIFY. Forced style : $SS_BITMAP.
    ;#           $iexstyle = [optional] Defines the extended style of the control. See Extended Style Table. Default = -1
    ;#           $hspeed = [optional] The animation speed (Default = 1).
    ;#           $hslow = [optional] If flag is set to 1, a slower but more secure gif decoding will be processed. See remarks. Default = 0
    ;#  Return Value ..: Success: Returns the identifier (controlID) of the new control.
    ;#           Failure: Returns 0.
    ;#  Author ........: jennico
    ;#  Date ..........: 20.05.09
    ;#  Remarks .......: The Gifcontrol is a native Pic control. Please refer to GUICtrlCreatePic() in helpfile
    ;#           Alternatively you may use GUICtrlCreatePic() with GUICtrlSetAni()
    ;#           Due to the countless options and variations of a gif file, not every file can be displayed correctly (even IE is not able).
    ;#           The following specifications are supported: both, GIF87a and GIF89a format, frames, frame rates (duration), interlacing, transparency, tiling, overlaying, individual frame sizes. No stopping, no user input.
    ;#           The fastest decoding works for "GIF89a" formatted gifs with Graphic Context Extension (GCE) block. This is true for 98% of the animated gif files.
    ;#           "Slow Mode" does NOT mean that the animation is slower, it means that the initialization (splitting) of the gif file is more precise and therefore slower. The animation speed is the same !
    ;#           If the display of the animation fails, try to use the 'hslow' flag set to 1. This may work with some exotic animated gifs.
    ;#           If the display of the animation still fails, use GUICtrlCreateGifEx. This should work with all kinds of gifs.
    ;#           If a file is not supported, it will be displayed without animation and @error set to 1.
    ;#  Related .......: GUICtrlCreateGifEx(), GUICtrlSetAni()
    ;#  Example .......: yes
    ;#===========================================================#
#ce

Func GUICtrlCreateGif($hWnd, $hfile, $x, $y, $w = -1, $h = -1, $istyle = -1, $iexstyle = -1, $hspeed = 1, $hslow = 0)
    If IsHWnd($hWnd) = 0 Then Return
    Local $oldhWnd = GUISwitch($hWnd)
    Local $hctrl = GUICtrlCreatePic($hfile, $x, $y, $w, $h, $istyle, $iexstyle)
    GUISwitch($oldhWnd)
    If $hctrl And $hfile And GUICtrlSetAni($hWnd, $hctrl, $hfile, $hspeed, $hslow) = 0 Then Return SetError(1, 0, $hctrl)
    Return $hctrl
EndFunc   ;==>GUICtrlCreateGif

#cs
    ;#=#Function#================================================#
    ;#  Name ..........: GUICtrlCreateGifEx( $hWnd, $hfile, $x, $y [, $hspeed ] )
    ;#  Description ...: Creates an animated .gif based graphic GDIplus style.
    ;#  Parameters ....: $hWnd = The GUI handle as returned by GuiCreate().
    ;#           $hfile = The .gif file to be set.
    ;#           $x = The left position of the graphic relative to the client area.
    ;#           $y = The top position of the graphic relative to the client area.
    ;#           $hspeed = [optional] The animation speed (Default = 1).
    ;#  Return Value ..: Success: Returns a Handle to a Graphics object to be used with the other UDF functions.
    ;#           Failure: Returns 0.
    ;#  Author ........: jennico
    ;#  Date ..........: 24.05.09
    ;#  Remarks .......: GUICtrlCreateGifEx() supports ALL modern GIF89a formats with GCE including frames, frame rates (duration), interlacing, screen splitting (tiling), overlaying, individual frame sizes.
    ;#           The GifEx control is not a native AutoIt control, but a com like GDIplus Graphic object.
    ;#           The function does not return a valid controlID, cannot be manipulated or scaled, no control styles.
    ;#           Compared to GUICtrlCreateGif(), GUICtrlCreateGifEx() hardly usess CPU resources.
    ;#  Related .......: GUICtrlCreateGif(), _Ani_SetGifExFrame()
    ;#  Example .......: yes
    ;#===========================================================#
#ce

Func GUICtrlCreateGifEx($hWnd, $hfile, $x, $y, $hspeed = 1)
    If FileExists($hfile) = 0 Or IsHWnd($hWnd) = 0 Then Return
    Local $hctrl = _GDIPlus_GraphicsCreateFromHWND ($hWnd)
    Local $id = __Ani_GetInstance($hctrl)
    If __Ani_SplitAni($id, $hfile, 0, $hWnd, $hctrl, $hspeed) = 0 Then Return 0 * _GDIPlus_GraphicsDispose ($hctrl)
    $_ani_Array[6][$id] = '__Ani_SetObjectAni'
    $_ani_Array[10][$id] = $x
    $_ani_Array[11][$id] = $y
    Call($_ani_Array[6][$id], $id, $_ani_Data[$id][$_ani_Array[3][$id]][0]);0
    Return $hctrl
EndFunc   ;==>GUICtrlCreateGifEx

#cs
    ;#=#Function#================================================#
    ;#  Name ..........: GUICtrlCreateAni( $hWnd, $hfile, $x, $y [, $w [, $h [, $istyle [, $iexstyle [, $hspeed ]]]]] )
    ;#  Description ...: Creates an animated .ani based GUI Control.
    ;#  Parameters ....: $hWnd = The GUI handle as returned by GuiCreate().
    ;#           $hfile = The .ani file to be set.
    ;#           $x = The left side of the control. If -1 is used then left will be computed according to GUICoordMode.
    ;#           $y = The top of the control. If -1 is used then top will be computed according to GUICoordMode.
    ;#           $w = [optional] The width of the control (default is 32).
    ;#           $h = [optional] The height of the control (default is 32).
    ;#           $istyle = [optional] Defines the style of the control. See GUI Control Styles Appendix. default ( -1) : $SS_NOTIFY. forced styles : $WS_TABSTOP, $SS_ICON
    ;#           $iexstyle = [optional] Defines the extended style of the control. See Extended Style Table. Default = -1
    ;#           $hspeed = [optional] The animation speed (Default = 1).
    ;#  Return Value ..: Success: Returns the identifier (controlID) of the new control.
    ;#           Failure: Returns 0.
    ;#  Author ........: jennico
    ;#  Date ..........: 19.05.09
    ;#  Remarks .......: The Anicontrol is a native Icon control. Please refer to GUICtrlCreateIcon() in helpfile
    ;#           Alternatively you may use GUICtrlCreateIcon() with GUICtrlSetAni()
    ;#           If the ani fails to split, it will be displayed without animation and @error set to 1.
    ;#  Related .......: GUICtrlSetAni()
    ;#  Example .......: yes
    ;#===========================================================#
#ce

Func GUICtrlCreateAni($hWnd, $hfile, $x, $y, $w = 32, $h = 32, $istyle = -1, $iexstyle = -1, $hspeed = 1)
    If IsHWnd($hWnd) = 0 Then Return
    Local $oldhWnd = GUISwitch($hWnd)
    Local $hctrl = GUICtrlCreateIcon($hfile, 0, $x, $y, $w, $h, $istyle, $iexstyle)
    GUISwitch($oldhWnd)
    If $hctrl And $hfile And GUICtrlSetAni($hWnd, $hctrl, $hfile, $hspeed) = 0 Then Return SetError(1, 0, $hctrl)
    Return $hctrl
EndFunc   ;==>GUICtrlCreateAni

;createframe

#cs
    ;#=#Function#================================================#
    ;#  Name ..........: GUICtrlSetAni( $hWnd, $hctrl, $hfile [, $hspeed [, $hslow ]] )
    ;#  Description ...: Sets an animated Icon (.ani) to an Ani / Icon control
    ;#           resp. an animated Gif (.gif) to a Gif / Pic control.
    ;#  Parameters ....: $hWnd = The GUI handle as returned by GuiCreate().
    ;#           $hctrl = The control ID as returned by GUICtrlCreateAni() or GUICtrlCreateIcon().
    ;#       $hfile = The animated file to be set (.ani or .gif supported).
    ;#           $hspeed = [optional] The animation speed (Default = 1).
    ;#           $hslow = [optional] If flag is set to 1, a slower but more secure gif (not ani) decoding will be processed. See remarks. Default = 0
    ;#  Return Value ..: Success: Returns 1.
    ;#           Failure: Returns 0. see remarks.
    ;#  Author ........: jennico
    ;#  Date ..........: 19.05.09
    ;#  Remarks .......: If the ani / gif fails to split, it will be displayed without animation.
    ;#           The fastest gif decoding works for "GIF89a" formatted gifs with Graphic Context Extension (GCE) block. This is true for 98% of the animated gif files.
    ;#           "Slow Mode" does NOT mean that the animation is slower, it means that the initialization (splitting) of the gif file is more precise and therefore slower. The animation speed is the same !
    ;#           If the display of the animation fails, try to use the 'hslow' flag set to 1. This may work with some exotic animated gifs.
    ;#           If the display of the animation still fails, use GUICtrlCreateGifEx. This should work with all kinds of gifs.
    ;#  Related .......: GUICtrlCreateGif(), GUICtrlCreateGifEx(), GUICtrlCreateAni()
    ;#  Example .......: yes
    ;#===========================================================#
#ce

Func GUICtrlSetAni($hWnd, $hctrl, $hfile, $hspeed = 1, $hslow = 0)
    If FileExists($hfile) = 0 Or IsHWnd($hWnd) = 0 Or GUICtrlSetImage($hctrl, $hfile, 0) = 0 Then Return
    Local $id = __Ani_GetInstance($hctrl)
    If __Ani_SplitAni($id, $hfile, $hslow, $hWnd, ControlGetHandle($hWnd, '', $hctrl), $hspeed) = 0 Then Return
    $_ani_Array[6][$id] = '__Ani_SetCtrlAni'
    $_ani_Array[2][$id] = $hctrl
    Return GUICtrlSetImage($hctrl, $_ani_TempDir & $id & '_' & $_ani_Data[$id][$_ani_Array[3][$id]][0], 0)
EndFunc   ;==>GUICtrlSetAni

#cs
    ;#=#Function#================================================#
    ;#  Name ..........: GUICtrlSetFrame( $hctrl, $hfile, $iframe [,$hslow ] )
    ;#  Description ...: Sets the specified frame image of an ani file to an Ani / Icon control
    ;#           resp. of an animated .gif file to a Gif / Pic control.
    ;#  Parameters ....: $hctrl = The control ID as returned by GUICtrlCreateAni() or GUICtrlCreateIcon() or GUICtrlCreateAni() or GUICtrlCreateGif().
    ;#       $hfile = The animated file to be split (.ani or .gif supported).
    ;#           $iframe = The frame number to be displayed (1 is first).
    ;#           $hslow = [optional] If flag is set to 1, a slower but more secure gif (not ani) decoding will be processed. See remarks. Default = 0
    ;#  Return Value ..: Success: Returns 1.
    ;#           Failure: Returns 0.
    ;#  Author ........: jennico
    ;#  Date ..........: 21.05.09
    ;#  Remarks .......: The fastest gif decoding works for "GIF89a" formatted gifs with Graphic Context Extension (GCE) block. This is true for 98% of the animated gif files.
    ;#           If the display of the frame fails, try to use the 'hslow' flag set to 1. This may work with some exotic animated gifs.
    ;#           Does not work for graphics generated with GUICtrlCreateGifEx()
    ;#           For graphics rendered by GUICtrlCreateGifEx(), use _Ani_SetGifExFrame() instead.
    ;#  Related .......: _Ani_SetGifExFrame()
    ;#  Example .......: yes
    ;#===========================================================#
#ce

Func GUICtrlSetFrame($hctrl, $hfile, $iframe, $hslow = 0)
    If FileExists($hfile) And __Ani_SplitAni(-1, $hfile, $hslow, 0, $iframe) Then Return GUICtrlSetImage($hctrl, $_ani_TempDir & '-1_' & $iframe - 1, 0)
EndFunc   ;==>GUICtrlSetFrame

#cs
    ;#=#Function#================================================#
    ;#  Name ..........: _Ani_SetGifExFrame( $hctrl, $iframe )
    ;#  Description ...: Displays the specified frame image of an animated .gif file the GDIplus way.
    ;#  Parameters ....: $hctrl = The graphic handle as returned by GUICtrlCreateGifEx().
    ;#           $iframe = The frame number to be displayed (1 is first frame).
    ;#  Return Value ..: Success: Returns the handle to the graphic object.
    ;#           Failure: Returns 0.
    ;#  Author ........: jennico
    ;#  Date ..........: 25.05.09
    ;#  Remarks .......: May not in any case make sense with gifs that require a fixed frame order (tiles, overlays).
    ;#  Related .......: GUICtrlSetFrame()
    ;#  Example .......: yes
    ;#===========================================================#
#ce

Func _Ani_SetGifExFrame($hctrl, $iframe)
    Local $id = __Ani_GetInstance($hctrl)
    If $id > -1 Then Return __Ani_SetObjectAni($id, $iframe - 1) + $_ani_Array[1][$id]
EndFunc   ;==>_Ani_SetGifExFrame

#cs
    ;#=#Function#================================================#
    ;#  Name ..........: _Ani_DeleteAnimation( [$hWnd] )
    ;#  Description ...: Stops an animation.
    ;#  Parameters ....: $hWnd = [optional] The GUI handle as returned by GuiCreate() if you want to pause the caption animation.
    ;#                    The HANDLE (!) of control ID as returned by GUICtrlCreateAni() or GUICtrlCreateIcon() if you want to pause a GUI control.
    ;#                    The graphic handle as returned by GUICtrlCreateGifEx().
    ;#                    The HANDLE (!) of control ID you passed to GUICtrlSetAni().
    ;#                    Default : if omitted, the Tray animation will be paused.
    ;#  Return Value ..: Success: Returns 1.
    ;#           Failure: Returns 0.
    ;#  Author ........: jennico
    ;#  Date ..........: 21.05.09
    ;#  Remarks .......: Important to avoid CPU load. Should be used if an animation is not needed anymore.
    ;#           The timer will be killed and the animation cannot be resumed.
    ;#           The control will not be emptied, it will keep the last image.
    ;#           Please observe that this function requires control handles, not control IDs. Use GUICtrlGetHandle().
    ;#  Example .......: yes
    ;#===========================================================#
#ce

Func _Ani_DeleteAnimation($hWnd = 'Tray')
    Local $id = __Ani_GetInstance($hWnd, 1)
    If $id = -1 Then Return
    Local $ret = 1 * _Timer_KillTimer ($_ani_Array[0][$id], $_ani_Array[5][$id])
    $_ani_Array[5][$id] -= 1000
    Return $ret
EndFunc   ;==>_Ani_DeleteAnimation

#cs
    ;#=#Function#================================================#
    ;#  Name ..........: _Ani_PauseAnimation( $paused [, $hWnd ] )
    ;#  Description ...: Pauses or Resumes an animation.
    ;#  Parameters ....: $paused = 1 = Pauses animation.
    ;#                 0 = Resumes animation.
    ;#           $hWnd = [optional] The GUI handle as returned by GuiCreate() if you want to pause the caption animation.
    ;#                    The HANDLE (!) of control ID as returned by GUICtrlCreateAni() or GUICtrlCreateIcon() if you want to pause a GUI control.
    ;#                    The graphic handle as returned by GUICtrlCreateGifEx().
    ;#                    The HANDLE (!) of controlID you passed to GUICtrlSetAni().
    ;#                    Default : if omitted, the Tray animation will be paused.
    ;#  Return Value ..: Success: Returns 1.
    ;#           Failure: Returns 0.
    ;#  Author ........: jennico
    ;#  Date ..........: 19.05.09
    ;#  Remarks .......: For performance reasons, it is a good idea to pause an animation while control / GUI is hidden.
    ;#           Please observe that this function requires control handles, not control IDs. Use GUICtrlGetHandle().
    ;#  Example .......: yes
    ;#===========================================================#
#ce

Func _Ani_PauseAnimation($paused, $hWnd = 'Tray')
    Local $id = __Ani_GetInstance($hWnd, 1)
    If $id = -1 Then Return
    $_ani_Array[9][$id] = $paused
    Return 1 * __Ani_SetAni($id)
EndFunc   ;==>_Ani_PauseAnimation

#cs
    ;#=#Function#================================================#
    ;#  Name ..........: _Ani_SetAnimationSpeed( $hspeed [, $hWnd ] )
    ;#  Description ...: Sets the animation speed.
    ;#  Parameters ....: $hspeed = The animation speed. Can be any floating number <> 0.
    ;#                 1 means genuine ani speed, 2 double speed, 0.5 half speed.
    ;#                 negative values will reverse the animation (backwards).
    ;#                 0 will be ignored !
    ;#           $hWnd = [optional] The GUI handle as returned by GuiCreate() if you want to adjust the caption animation speed.
    ;#                    The HANDLE (!) of the control ID as returned by GUICtrlCreateAni() or GUICtrlCreateIcon() if you want to adjust a GUI control animation speed.
    ;#                    The graphic handle as returned by GUICtrlCreateGifEx().
    ;#                    The HANDLE (!) of controlID you passed to GUICtrlSetAni().
    ;#                    Default : if omitted, the Tray animation will be adjusted.
    ;#  Return Value ..: Success: Returns 1.
    ;#           Failure: Returns 0.
    ;#  Author ........: jennico
    ;#  Date ..........: 19.05.09
    ;#  Remarks .......: Negative speed may not in any case make sense with GDIplus objects created by GUICtrlCreateGifEx(), because the display order cannot be reversed in overlaying frames.
    ;#           Please observe that this function requires control handles, not control IDs. Use GUICtrlGetHandle().
    ;#  Example .......: yes
    ;#===========================================================#
#ce

Func _Ani_SetAnimationSpeed($hspeed, $hWnd = 'Tray')
    If $hspeed = 0 Then Return
    Local $id = __Ani_GetInstance($hWnd, 1)
    If $id = -1 Then Return
    $_ani_Array[7][$id] = Abs($hspeed)
    $_ani_Array[8][$id] = $hspeed / $_ani_Array[7][$id]
    Return 1 * __Ani_SetAni($id)
EndFunc   ;==>_Ani_SetAnimationSpeed

#cs
    ;#=#Function#================================================#
    ;#  Name ..........: _Ani_GetFrames( $hfile [, $hslow ] )
    ;#  Description ...: Retrieves the number of frames in a gif or ani file.
    ;#  Parameters ....: $hfile = The .gif / .ani file.
    ;#           $hslow = [optional] If flag is set to 1, a slower but more secure gif (not ani) decoding will be processed. See remarks. Default = 0
    ;#  Return Value ..: Success: Returns the number of frames (individual, different images) encoded in the file.
    ;#           Failure: Returns 0.
    ;#  Author ........: jennico
    ;#  Date ..........: 21.05.09
    ;#  Remarks .......: Within its animation cycle, an ANI file may display more steps than it contains frames, due to possible repetition of frames.
    ;#           The fastest GIF decoding works for "GIF89a" formatted gifs with Graphic Context Extension (GCE) block. This is true for 95% of the animated gif files.
    ;#           If the display of the animation still fails, try to use the 'hslow' flag set to 1. This may work with some exotic animated gifs.
    ;#           Function can be used to determine if gif is animated (Frames > 1).
    ;#  Example .......: yes
    ;#===========================================================#
#ce

Func _Ani_GetFrames($hfile, $hslow = 0)
    Return __Ani_SplitAni(0, $hfile, $hslow);wenn 0 autom slow
EndFunc   ;==>_Ani_GetFrames

#cs
    ;#=#Function#================================================#
    ;#  Name ..........: _Ani_GetGifSize( $hfile )
    ;#  Description ...: Retrieves the global size of a gif file.
    ;#  Parameters ....: $hfile = The .gif file.
    ;#  Return Value ..: Success: Returns a 2 element array, array[0] contains width, array[1] contains height of $hfile.
    ;#                @extended denotes the global palette color count (max 256).
    ;#           Failure: Returns 0.
    ;#  Author ........: jennico
    ;#  Date ..........: 22.05.09
    ;#  Remarks .......: The global (or screen) size defines the rectangle for all single images (frames) encoded in the file.
    ;#           The individual frames can be smaller and may not fill the entire rectangle, they have their individual x and y offsets within the rectangle.
    ;#           Though, 98% of the gif files contain only frames that cover the entire rectangle and are positioned at 0, 0.
    ;#  Example .......: yes
    ;#===========================================================#
#ce

Func _Ani_GetGifSize($hfile)
    Local $read = FileRead($hfile)
    If StringLeft($read, 3) <> 'GIF'  Then Return
    Local $ret[2] = [Dec(Hex(BinaryMid($read, 7, 1))) + Dec(Hex(BinaryMid($read, 8, 1))) * 256, Dec(Hex(BinaryMid($read, 9, 1))) + Dec(Hex(BinaryMid($read, 10, 1))) * 256]
    Local $packed = Dec(Hex(BinaryMid($read, 11, 1)))
    Return SetExtended(2 ^ (BitAND($packed, 7) + 1) * ($packed > 127), $ret)
EndFunc   ;==>_Ani_GetGifSize

#cs
    ;#=#Function#================================================#
    ;#  Name ..........: _Ani_GetGifInfo( $hfile [, $idisplay ] )
    ;#  Description ...: Retrieves advanced information of a gif file (only GIF89a format with Graphic Control Extension (GCE) block).
    ;#  Parameters ....: $hfile = The .gif file.
    ;#           $idisplay = [optional] If flag is set to 1, the result will be displayed in a table. Default = 0
    ;#  Return Value ..: Success: Returns a 2 dimensional array ([n+1][10] with n as frame number) containing file information. See remarks.
    ;#           Failure: Returns 0.
    ;#  Author ........: jennico
    ;#  Date ..........: 23.05.09
    ;#  Remarks .......: Elements [0][0-9] contains the following global information: Left | Top | Width | Height | Color count.
    ;#           Elements [n][0-9] contain the following information with n = frame count:
    ;#           [n][0] = Left position relative to global
    ;#           [n][1] = Top position relative to global
    ;#           [n][2] = Width of frame
    ;#           [n][3] = Height of frame
    ;#           [n][4] = Local color count in (bits per pixel)^2
    ;#           [n][5] = Interlace Bit
    ;#           [n][6] = Frame rate (1/100 sec)
    ;#           [n][7] = Transparency bit
    ;#           [n][8] = User Input bit (waits for user input)
    ;#           [n][9] = Disposal method (how frame is treated when time is up).  0 = do nothing  1 = leave as is  2 = restore to background  3 = previous image
    ;#                There should be (4) more disposal methods, but i could not find any references beyond this. Method 2 and 3 do not seem to be realizable in a correct way with GDIplus.
    ;#           For more information, see: http://www.w3.org/Graphics/GIF/spec-gif89a.txt. This source ought to be complete, but it is not at all.
    ;#  Example .......: yes
    ;#===========================================================#
#ce

Func _Ani_GetGifInfo($hfile, $idisplay = 0)
    If FileExists($hfile) = 0 Then Return
    Local $read = FileRead($hfile)
    If StringLeft($read, 6) <> 'GIF89a'  Then Return
    Local $a = StringSplit($read, $_ani_Separator, 1)
    If $a[0] < 3 Then Return
    Local $packed = Dec(Hex(BinaryMid($read, 11, 1)))
    Local $_ani_Info[$a[0]][10], $j
    $_ani_Info[0][0] = 0
    $_ani_Info[0][1] = 0
    $_ani_Info[0][2] = Dec(Hex(BinaryMid($read, 7, 1))) + Dec(Hex(BinaryMid($read, 8, 1))) * 256;bytes
    $_ani_Info[0][3] = Dec(Hex(BinaryMid($read, 9, 1))) + Dec(Hex(BinaryMid($read, 10, 1))) * 256;bytes
    $_ani_Info[0][4] = 2 ^ (BitAND($packed, 7) + 1) * ($packed > 127);bits
    For $i = 2 To $a[0]
        $j = 0;another not described and not expected comment block
        While BinaryMid($a[$i], 5 + $j, 1) <> 0 Or BinaryMid($a[$i], 6 + $j, 1) <> 0x2C
            $j += 2
        WEnd
        $_ani_Info[$i - 1][0] = Dec(Hex(BinaryMid($a[$i], 7 + $j, 1))) + 256 * Dec(Hex(BinaryMid($a[$i], 8 + $j, 1)))
        $_ani_Info[$i - 1][1] = Dec(Hex(BinaryMid($a[$i], 9 + $j, 1))) + 256 * Dec(Hex(BinaryMid($a[$i], 10 + $j, 1)))
        $_ani_Info[$i - 1][2] = Dec(Hex(BinaryMid($a[$i], 11 + $j, 1))) + 256 * Dec(Hex(BinaryMid($a[$i], 12 + $j, 1)))
        $_ani_Info[$i - 1][3] = Dec(Hex(BinaryMid($a[$i], 13 + $j, 1))) + 256 * Dec(Hex(BinaryMid($a[$i], 14 + $j, 1)))
        $packed = Dec(Hex(BinaryMid($a[$i], 15 + $j, 1)))
        $_ani_Info[$i - 1][4] = 2 ^ (BitAND($packed, 7) + 1) * ($packed > 127)
        $_ani_Info[$i - 1][5] = BitAND(BitShift($packed, 6), 1);BitAND($packed, 64)
        $_ani_Info[$i - 1][6] = Dec(Hex(BinaryMid($a[$i], 2, 1))) + 256 * Dec(Hex(BinaryMid($a[$i], 3, 1)))
        $packed = Dec(Hex(BinaryMid($a[$i], 1, 1)))
        $_ani_Info[$i - 1][7] = BitAND($packed, 1)
        $_ani_Info[$i - 1][8] = BitAND(BitShift($packed, 1), 1);BitAND($packed, 2)
        $_ani_Info[$i - 1][9] = BitAND(BitShift($packed, 2), 7)
    Next
    If $idisplay Then
        Local $iOnEventMode = Opt('GUIOnEventMode', 0)
        Local $sDataSeparatorChar = Opt('GUIDataSeparatorChar', '|')
        Local $hGUI = GUICreate($hfile & ' - Type: GIF89a with GCE', 600, 520, Default, Default, 0x70000);BitOR($WS_SIZEBOX, $WS_MINIMIZEBOX, $WS_MAXIMIZEBOX)
        Local $apos = WinGetClientSize($hGUI)
        Local $tmp, $iWidth = 0, $hListView = GUICtrlCreateListView('Frames|Left|Top|Width|Height|Colors|Interlace Bit|Rate [sec/100]|Transparency Bit|User Input Bit|Disposal', 0, 0, $apos[0], $apos[1], 8);$LVS_SHOWSELALWAYS
        GUICtrlSetResizing($hListView, 0x66);$GUI_DOCKBORDERS
        Local Const $_ani_LVM_SETEXTENDEDLISTVIEWSTYLE = 0x1000 + 54
        GUICtrlSendMsg($hListView, $_ani_LVM_SETEXTENDEDLISTVIEWSTYLE, 1, 1);$LVS_EX_GRIDLINES
        GUICtrlSendMsg($hListView, $_ani_LVM_SETEXTENDEDLISTVIEWSTYLE, 0x20, 0x20);$LVS_EX_FULLROWSELECT
        GUICtrlSendMsg($hListView, $_ani_LVM_SETEXTENDEDLISTVIEWSTYLE, 0x0200, 0x0200);$WS_EX_CLIENTEDGE
        For $i = 0 To UBound($_ani_Info, 1) - 1
            $tmp = '[' & $i & ']'
            If $i = 0 Then $tmp = '[Global]'
            For $j = 0 To 9
                $tmp &= '|' & $_ani_Info[$i][$j]
            Next
            GUICtrlCreateListViewItem($tmp, $hListView)
        Next
        For $i = 0 To 10
            $iWidth += GUICtrlSendMsg($hListView, 0x1000 + 29, $i, 0);$LVM_GETCOLUMNWIDTH
        Next
        WinMove($hGUI, '', Default, Default, $iWidth + 26)
        GUISetState(@SW_SHOW, $hGUI)
        Do
        Until GUIGetMsg() = -3
        GUIDelete($hGUI)
        Opt('GUIOnEventMode', $iOnEventMode)
        Opt('GUIDataSeparatorChar', $sDataSeparatorChar)
    EndIf
    Return $_ani_Info
EndFunc   ;==>_Ani_GetGifInfo

#EndRegion;--------------------------Main Functions
#Region;--------------------------Internal

Func __Ani_GetInstance($hctrl, $hmode = 0)
    For $i = 0 To $_ani_Instance - 1
        If $_ani_Array[1][$i] = $hctrl Then Return $i
    Next
    If $hmode Then Return -1
    $_ani_Instance += 1
    ReDim $_ani_Array[12][$_ani_Instance], $_ani_Data[$_ani_Instance][$_ani_Steps][2]
    $_ani_Array[5][$_ani_Instance - 1] = -1
    Return $_ani_Instance - 1
EndFunc   ;==>__Ani_GetInstance

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
        If $seq[0] > 1 Then $_ani_Data[$id][$i][0] = Dec(Hex(BinaryMid($seq[2], ($i + 1) * 4 + 1, 1)))
        $_ani_Data[$id][$i][1] = $JifRate
        If $rate[0] > 1 Then $_ani_Data[$id][$i][1] = Dec(Hex(BinaryMid($rate[2], ($i + 1) * 4 + 1, 1)))
    Next
    Return __Ani_SetArray($id, $hWnd, $hctrl, $cSteps, $hspeed)
EndFunc   ;==>__Ani_SplitAni

Func __Ani_SplitGif($id, $read, $hWnd, $hctrl, $hspeed, $hslow)
    If StringLeft($read, 6) <> 'GIF89a'  Or StringInStr($read, $_ani_Separator) = 0 Or $hslow Then Return __Ani_SplitGifEx($id, $read, $hWnd, $hctrl, $hspeed)
    Local $a = StringSplit($read, $_ani_Separator, 1)
    If $hWnd = -1 Then Return $a[0] - 1
    If $a[0] < 3 Or ($hWnd = 0 And $hctrl > $a[0] - 1) Then Return
    If $hWnd <> 0 And $a[0] - 1 > $_ani_Steps Then __Ani_SetSteps($a[0] - 1)
    For $i = 2 To $a[0]
        If IsHWnd($hWnd) Or $hctrl = $i - 1 Then
            Local $write = FileOpen($_ani_TempDir & $id & '_' & $i - 2, 26)
            If $write = 0 Then Return
            FileWrite($write, StringTrimRight($a[1] & $_ani_Separator & $a[$i] & Chr(0x3B), $i = $a[0]))
            FileClose($write)
            If $hWnd = 0 Then Return 1
            $_ani_Data[$id][$i - 2][0] = $i - 2
            Local $temp = (Dec(Hex(BinaryMid($a[$i], 2, 1))) + Dec(Hex(BinaryMid($a[$i], 3, 1))) * 256) * 3 / 5
            $_ani_Data[$id][$i - 2][1] = $temp + 6 * ($temp = 0);just a guess
        EndIf
    Next
    Return __Ani_SetArray($id, $hWnd, $hctrl, $a[0] - 1, $hspeed)
EndFunc   ;==>__Ani_SplitGif

Func __Ani_SplitGifEx($id, $read, $hWnd, $hctrl, $hspeed)
    If StringLeft($read, 6) <> 'GIF87a'  And StringLeft($read, 6) <> 'GIF89a'  Then Return
    Local $sseparator = '002C'
    If StringLeft($read, 6) = 'GIF89a'  And StringInStr($read, $_ani_Separator) Then $sseparator = '0021F904'
    Local $binary = StringToBinary($read)
    Local $x = StringInStr($binary, $sseparator)
    If $x = 0 Then Return
    Local $gifheader = StringLeft($binary, $x + 1), $count = 0, $i, $write
    $binary = StringMid($binary, $x + 2)
    If $sseparator = '0021F904'  And IsHWnd($hWnd) Then Local $temp[1] = [3 / 5 * (Dec(StringMid($binary, 9, 2)) + 256 * Dec(StringMid($binary, 11, 2))) ]
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
                    $_ani_Data[$id][$i][1] = 6  ;unknown: GIF87a default frame rate, just a guess
                    If $sseparator = '0021F904'  And $temp[$i] > 0 Then $_ani_Data[$id][$i][1] = $temp[$i]
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
        If $sseparator = '0021F904'  And IsHWnd($hWnd) Then
            ReDim $temp[$count + 1]
            $temp[$count] = 3 / 5 * (Dec(StringMid($binary, 9, 2)) + 256 * Dec(StringMid($binary, 11, 2)))
        EndIf
    WEnd
EndFunc   ;==>__Ani_SplitGifEx

Func __Ani_SetArray($id, $hWnd, $hctrl, $hcount, $hspeed)
    $_ani_Array[0][$id] = $hWnd
    $_ani_Array[1][$id] = $hctrl
    $_ani_Array[2][$id] = $hctrl
    $_ani_Array[3][$id] = 0
    $_ani_Array[4][$id] = $hcount
    $_ani_Array[7][$id] = Abs($hspeed)
    $_ani_Array[8][$id] = $hspeed / $_ani_Array[7][$id]
    $_ani_Array[5][$id] = _Timer_SetTimer ($hWnd, $_ani_Data[$id][0][1] / 6 * 100 / $_ani_Array[7][$id], $_ani_Callback, $_ani_Array[5][$id])
    If $_ani_Array[5][$id] Then Return 1
EndFunc   ;==>__Ani_SetArray

Func __Ani_SetSteps($hsteps)
    $_ani_Steps = $hsteps
    ReDim $_ani_Data[$_ani_Instance][$hsteps][2]
EndFunc   ;==>__Ani_SetSteps

Func __Ani_GetTimer($hWnd, $Msg, $iIDTimer, $dwTime)
    For $i = 0 To $_ani_Instance - 1
        If $_ani_Array[5][$i] = $iIDTimer Then Return __Ani_SetAni($i)
    Next
EndFunc   ;==>__Ani_GetTimer

Func __Ani_SetAni($id)
    If $_ani_Array[9][$id] Then Return 1
    $_ani_Array[3][$id] += $_ani_Array[8][$id]
    If $_ani_Array[3][$id] = $_ani_Array[4][$id] Then $_ani_Array[3][$id] = 0
    If $_ani_Array[3][$id] = -1 Then $_ani_Array[3][$id] += $_ani_Array[4][$id]
    Call($_ani_Array[6][$id], $id, $_ani_Data[$id][$_ani_Array[3][$id]][0])
    Return _Timer_SetTimer ($_ani_Array[0][$id], $_ani_Data[$id][$_ani_Array[3][$id]][1] / 6 * 100 / $_ani_Array[7][$id], $_ani_Callback, $_ani_Array[5][$id])
EndFunc   ;==>__Ani_SetAni

Func __Ani_SetObjectAni($id, $hcount)
    Local $hBitmap = _GDIPlus_BitmapCreateFromFile ($_ani_TempDir & $id & '_' & $hcount)
    _GDIPlus_GraphicsDrawImage ($_ani_Array[1][$id], $hBitmap, $_ani_Array[10][$id], $_ani_Array[11][$id])
    _GDIPlus_ImageDispose ($hBitmap)
    _WinAPI_DeleteObject ($hBitmap)
EndFunc   ;==>__Ani_SetObjectAni

Func __Ani_SetCtrlAni($id, $hcount)
    GUICtrlSetImage($_ani_Array[2][$id], $_ani_TempDir & $id & '_' & $hcount, 0)
EndFunc   ;==>__Ani_SetCtrlAni

Func __Ani_SetGUIAni($id, $hcount)
    GUISetIcon($_ani_TempDir & $id & '_' & $hcount, 0, $_ani_Array[1][$id])
EndFunc   ;==>__Ani_SetGUIAni

Func __Ani_SetTrayAni($id, $hcount)
    TraySetIcon($_ani_TempDir & $id & '_' & $hcount, 0)
EndFunc   ;==>__Ani_SetTrayAni

Func __Ani_OnAutoItExit()
    Call($_ani_ExitOpt)
    For $i = 0 To $_ani_Instance - 1
        If IsNumber($_ani_Array[10][$i]) Then _GDIPlus_GraphicsDispose ($_ani_Array[1][$i])
    Next
    FileDelete($_ani_TempDir & '*')
    _GDIPlus_ShutDown ()
EndFunc   ;==>__Ani_OnAutoItExit

#EndRegion;--------------------------Internal
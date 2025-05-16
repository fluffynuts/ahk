; single-instance, auto-reloading boilerplate
; thanks to : https://stackoverflow.com/questions/45468335/automatically-reload-autohotkey-script-when-modified#45488494
; TODO: this really should be something which could be #include'd
;   which exports a single function to do this work.
#SingleInstance force
#NoEnv
FileGetTime ScriptStartModTime, %A_ScriptFullPath%
SetTimer CheckScriptUpdate, 100, 0x7FFFFFFF ; 100 ms, highest priority

CheckScriptUpdate() {
    global ScriptStartModTime
    FileGetTime curModTime, %A_ScriptFullPath%
    If (curModTime <> ScriptStartModTime) {
        Loop
        {
            reload
            Sleep 300 ; ms
            MsgBox 0x2, %A_ScriptName%, Reload failed. ; 0x2 = Abort/Retry/Ignore
            IfMsgBox Abort
                ExitApp
            IfMsgBox Ignore
                break
        } ; loops reload on "Retry"
    }
}

return
; reminder:
; # -> WIN
; ! -> ALT
; ^ -> CTRL
; + -> SHIFT

#IfWinActive ahk_exe PILGRIM-Win64-Shipping.exe
a::Space
Space::e
d::LButton
e::RButton
LButton::a
RButton::d

; if WinActive("ahk_exe PILGRIM-Win64-Shipping.exe")
; 	MouseClick, Left
; else
; 	Send, a
; return

; strafe left
; d::
; if WinActive("ahk_exe PILGRIM-Win64-Shipping.exe")
; 	MouseClick, Right
; else
; 	Send, d
; return
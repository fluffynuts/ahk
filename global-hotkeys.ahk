; single-instance, auto-reloading boilerplate
; thanks to : https://stackoverflow.com/questions/45468335/automatically-reload-autohotkey-script-when-modified#45488494
; TODO: this really should be something which could be #include'd
;   which exports a single function to do this work.
#SingleInstance force
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

; terminal
^+`::
;Run, *RunAs "C:\Program Files\ConEmu\ConEmu64.exe", %USERPROFILE%, Max
;Run, *RunAs "C:\Users\davyd\AppData\Local\Programs\Terminus\Terminus.exe"
;Run, *RunAs "C:\Users\davyd\AppData\Local\hyper\app-3.0.2\Hyper.exe" 
;Run, *RunAs "C:\apps\term\WindowsTerminal.exe"
Run, *RunAs "C:\Users\davyd\scoop\apps\windows-terminal\current\WindowsTerminal.exe", %USERPROFILE%, Max
return

!^+Space::
;Run "C:\Users\davyd\Documents\Mail.lnk"
Run "C:\Program Files\Mailbird\Mailbird.exe"
;Run "C:\Program Files (x86)\Mozilla Thunderbird\thunderbird.exe"
WinActivate ahk_exe Mailbird.exe
return

!^+~::
Run cmd.exe
return

; slack
!+s::
Run "C:\Users\davyd\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Slack Technologies Inc\Slack.lnk"
;Run "C:\Users\davyd\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Scoop Apps\Slack.lnk"
WinActivate ahk_exe Slack.exe
return

!+m::
Run "C:\Program Files\Mailbird\Mailbird.exe"
return

; Windows desktop hotkeys
; Globals
DesktopCount = 2 ; Windows starts with 2 desktops at boot
CurrentDesktop = 1 ; Desktop count is 1-indexed (Microsoft numbers them this way)
;
; This function examines the registry to build an accurate list of the current virtual desktops and which one we're currently on.
; Current desktop UUID appears to be in HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\SessionInfo\1\VirtualDesktops
; List of desktops appears to be in HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VirtualDesktops
;
mapDesktopsFromRegistry() {
    global CurrentDesktop, DesktopCount
        ; Get the current desktop UUID. Length should be 32 always, but there's no guarantee this couldn't change in a later Windows release so we check.
        IdLength := 32
        SessionId := getSessionId()
        if (SessionId) {
            RegRead, CurrentDesktopId, HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\SessionInfo\%SessionId%\VirtualDesktops, CurrentVirtualDesktop
            if (CurrentDesktopId) {
IdLength := StrLen(CurrentDesktopId)
            }
        }
    ; Get a list of the UUIDs for all virtual desktops on the system
        RegRead, DesktopList, HKEY_CURRENT_USER, SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VirtualDesktops, VirtualDesktopIDs
        if (DesktopList) {
DesktopListLength := StrLen(DesktopList)
                       ; Figure out how many virtual desktops there are
                       DesktopCount := DesktopListLength / IdLength
        } else {
DesktopCount := 1
        }
    ; Parse the REG_DATA string that stores the array of UUID's for virtual desktops in the registry.
        i := 0
        while (CurrentDesktopId and i < DesktopCount) {
StartPos := (i * IdLength) + 1
              DesktopIter := SubStr(DesktopList, StartPos, IdLength)
              OutputDebug, The iterator is pointing at %DesktopIter% and count is %i%.
              ; Break out if we find a match in the list. If we didn't find anything, keep the
              ; old guess and pray we're still correct :-D.
              if (DesktopIter = CurrentDesktopId) {
CurrentDesktop := i + 1
                    OutputDebug, Current desktop number is %CurrentDesktop% with an ID of %DesktopIter%.
                    break
              }
          i++
        }
}
;
; This functions finds out ID of current session.
;
getSessionId() {
    ProcessId := DllCall("GetCurrentProcessId", "UInt")
    if ErrorLevel {
        OutputDebug, Error getting current process id: %ErrorLevel%
            return
    }
    OutputDebug, Current Process Id: %ProcessId%
    DllCall("ProcessIdToSessionId", "UInt", ProcessId, "UInt*", SessionId)
    if ErrorLevel {
        OutputDebug, Error getting session id: %ErrorLevel%
            return
    }
    OutputDebug, Current Session Id: %SessionId%
    return SessionId
}
;
; This function switches to the desktop number provided.
;
switchDesktopByNumber(targetDesktop) {
    global CurrentDesktop, DesktopCount
    ; Re-generate the list of desktops and where we fit in that. We do this because
    ; the user may have switched desktops via some other means than the script.
    mapDesktopsFromRegistry()
    ; Don't attempt to switch to an invalid desktop
    if (targetDesktop > DesktopCount || targetDesktop < 1) {
        OutputDebug, [invalid] target: %targetDesktop% current: %CurrentDesktop%
        return
    }
    ; Go right until we reach the desktop we want
    while(CurrentDesktop < targetDesktop) {
        Send ^#{Right}
        CurrentDesktop++
        Sleep, 5<F3><F3><F3>
        OutputDebug, [right] target: %targetDesktop% current: %CurrentDesktop%
    }
    ; Go left until we reach the desktop we want
    while(CurrentDesktop > targetDesktop) {
        Send ^#{Left}
        CurrentDesktop--
        Sleep, 5
        OutputDebug, [left] target: %targetDesktop% current: %CurrentDesktop%
    }
}
;
; This function creates a new virtual desktop and switches to it
;
createVirtualDesktop() {
 global CurrentDesktop, DesktopCount
 Send, #^d
 DesktopCount++
 CurrentDesktop = %DesktopCount%
 OutputDebug, [create] desktops: %DesktopCount% current: %CurrentDesktop%
}
;
; This function deletes the current virtual desktop
;
deleteVirtualDesktop() {
 global CurrentDesktop, DesktopCount
 Send, #^{F4}
 DesktopCount--
 CurrentDesktop--
 OutputDebug, [delete] desktops: %DesktopCount% current: %CurrentDesktop%
}
; create initial desktops, if missing
createInitialDesktops() {
    global CurrentDesktop
    lastCurrent = CurrentDesktop
    madeNow = 0
    while (DesktopCount < 6) {
        createVirtualDesktop()
        madeNow = madeNow + 1
        if (madeNow > 6) {
            OutputDebug, made too many desktops, bailing out!
            break
        }
    }
    switchDesktopByNumber(lastCurrent)
}
; Main
SetKeyDelay, 75
mapDesktopsFromRegistry()
OutputDebug, [loading] desktops: %DesktopCount% current: %CurrentDesktop%
; User config!
; This section binds the key combo to the switch/create/delete actions
!F1::switchDesktopByNumber(1)
!F2::switchDesktopByNumber(2)
!F3::switchDesktopByNumber(3)
#+F1::switchDesktopByNumber(4)
#+F2::switchDesktopByNumber(5)
#+F3::switchDesktopByNumber(6)
^!+F1::createInitialDesktops()
;CapsLock & 1::switchDesktopByNumber(1)
;CapsLock & 2::switchDesktopByNumber(2)
;CapsLock & 3::switchDesktopByNumber(3)
;CapsLock & 4::switchDesktopByNumber(4)
;CapsLock & 5::switchDesktopByNumber(5)
;CapsLock & 6::switchDesktopByNumber(6)
;CapsLock & 7::switchDesktopByNumber(7)
;CapsLock & 8::switchDesktopByNumber(8)
;CapsLock & 9::switchDesktopByNumber(9)
;CapsLock & n::switchDesktopByNumber(CurrentDesktop + 1)
;CapsLock & p::switchDesktopByNumber(CurrentDesktop - 1)
;CapsLock & s::switchDesktopByNumber(CurrentDesktop + 1)
;CapsLock & a::switchDesktopByNumber(CurrentDesktop - 1)
;CapsLock & c::createVirtualDesktop()
;CapsLock & d::deleteVirtualDesktop()
; Alternate keys for this config. Adding these because DragonFly (python) doesn't send CapsLock correctly.
;^!1::switchDesktopByNumber(1)
;^!2::switchDesktopByNumber(2)
;^!3::switchDesktopByNumber(3)
;^!4::switchDesktopByNumber(4)
;^!5::switchDesktopByNumber(5)
;^!6::switchDesktopByNumber(6)
;^!7::switchDesktopByNumber(7)
;^!8::switchDesktopByNumber(8)
;^!9::switchDesktopByNumber(9)
;^!n::switchDesktopByNumber(CurrentDesktop + 1)
;^!p::switchDesktopByNumber(CurrentDesktop - 1)
;^!s::switchDesktopByNumber(CurrentDesktop + 1)
;^!a::switchDesktopByNumber(CurrentDesktop - 1)
;^!c::createVirtualDesktop()
;^!d::deleteVirtualDesktop()

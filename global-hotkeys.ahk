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

; global vars
audacious = "C:\Program Files (x86)\Audacious\bin\audacious.exe"

return

; key-bindings, yo
!+z::
Run, %audacious% --rew
return

!+x::
Run, %audacious% --play-pause
return

!+c::
Run, %audacious% --show-jump-box
return

!+v::
Run, %audacious% --stop
return

!+p::
Run, %audacious% --fwd
return

^+`::
Run, *RunAs "C:\Program Files\ConEmu\ConEmu64.exe", %USERPROFILE%, Max
return

#Space::
Send #~
return
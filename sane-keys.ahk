; When this worked, it was good; but I found that sometimes it would just stop
;   working -- and really, the only thing I want is for win-tab to work like 
;   alt-tab and remap the RHS command / option keys (which I can do with SharpKeys)
;   -> keeping this around for reference more than anything else
RAlt::Ins ; right-Option to Insert
RWin::Del ; right command to forward delete
LWin::LAlt ; left command to alt
LAlt::LWin ; left alt to command (windows key)
CapsLock::Escape
F1::Pause
Ctrl & F1::CtrlBreak

#r::
    Run, powershell.exe -command (new-object -comobject "shell.application").FileRun(), ,Hide
return

#e::
    Run, explorer.exe
return

#a::
    Run, ms-actioncenter://
return

AllMinimized := 0
#d::
    if (AllMinimized = 0) {
        WinMinimizeAll
        AllMinimized = 1
    } else {
        WinMinimizeAllUndo
        AllMinimized = 0
    }
return

#c::
baseFolder = "%LOCALAPPDATA%\Microsoft\Windows\WinX\"
Loop, Files, "%LOCALAPPDATA%\Microsoft\Windows\WinX\Group3\*.*", DFR
{
    MsgBox, %A_LoopFileFullPath%
}
return
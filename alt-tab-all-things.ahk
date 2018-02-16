LWin & Tab::
GetKeyState, state, Shift
isDown := 1
if (state = D) {
    Send {Alt down}{Shift down}{tab} ; this will make Win-Shift-Tab function as Alt-Shift-Tab
} else {
    Send {Alt down}{tab} ; this will make Win-Tab function as Alt-Tab
}
return

LWin up::
if (isDown = 1) {
    isDown := 0
    Send {Enter}
    Send {Alt up}
}
return

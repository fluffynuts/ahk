LWin & Tab::
GetKeyState, state, Shift

if state = D
    Send {Alt down}{Shift}{tab} ; this will make Win-Shift-Tab function as Alt-Shift-Tab
else
    Send {Alt down}{Tab} ; this will make Win-Tab function as Alt-Tab

#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

Gui, Font, s16, Jetbrains Mono

Gui, Add, ListView, r20 w400 gMyListView vMyListView2 Grid, Column1|Column2|Column3

Gui, Show, , My GUI
return

MyListView:
    if (A_GuiEvent = "DoubleClick") {
        GuiControlGet, MyListView
        MsgBox, % "You double-clicked row " . MyListView . "."
    }
return

GuiClose:
ExitApp
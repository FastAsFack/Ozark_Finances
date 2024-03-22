#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%
#Include, eval.ahk

Gui, Font, s16, Jetbrains Mono

Gui, Add, Tab, x10 y10 w500 h400 vMotherControl gOnTabChange, Calculator|Invoices|Payments|Notes

Gui, Tab, Calculator

Gui, Add, Edit, x20 y70 w480 h40 vCalculator -VScroll

Gui, Add, Listview, x300 y137 w200 h250 vHistory

Gui, Add, button, x20 y135 w250 h50 gAnswer, Answer
Gui, Add, Button, x20 y200 w250 h50 vPercentageOf gTest, Percentage Of
Gui, Add, Button, x20 yp+65 w250 h50 vPercentageIncrease, Percent Increase
Gui, Add, button, x20 yp+65 w250 h50 vPercentageDecrease, Percent Decrease

; --- Listview --- ;

; --- End Listview --- ;

Gui, Tab, Invoices

Gui, Add, Text, x20 y150, WIP

Gui, Tab, Payments

Gui, Add, Text, x20 y150, WIP

Gui, Tab, Payments

Gui, Add, Text, x20 y150, WIP

Gui, Tab, Notes

Gui, Add, Text, x20 y150, WIP

Gui, Show, w520 h415 , Ozark Finances

return

Test:
    Eval(2+2)
    msgbox, %Result%
Return
; --- Answer --- ;
Answer:
    Gui, Submit, NoHide
    GuiControlGet, calculator,, calculator
    OutputDebug, Calculation: %calculator%
    try
    {
        Result := Eval(calculator)
        OutputDebug, Result: %Result%
    }
    catch
    {
        Result := "Error"
        OutputDebug, Error: %Result%
    }
    GuiControl,, calculator, %Result%
    msgbox, %Result%
return

; --- End Answer --- ;

; --- Tab Change --- ;

OnTabChange:
    GuiControlGet, CurrentTab, , MotherControl

    if (CurrentTab = "Calculator") {
        Gui, Show, w520 h415
        GuiControl, Move, MotherControl, w500 h400
    } else if (CurrentTab = "Invoices") {
        Gui, Show, w800 h700
        Gui, +LastFound
        WinGetPos, X, Y
        WinMove, , , X, Y - 200
        GuiControl, Move, MotherControl, w780 h680
    } else if (CurrentTab = "Payments") {
        Gui, Show, w800 h700
        Gui, +LastFound
        WinGetPos, X, Y
        WinMove, , , X, Y - 50
        GuiControl, Move, MotherControl, w780 h680
    } else if (CurrentTab = "Notes") {
        Gui, Show, w800 h700
        Gui, +LastFound
        WinGetPos, X, Y
        WinMove, , , X, Y + 50
        GuiControl, Move, MotherControl, w780 h680
    }
return

; --- End Tab Change --- ;

GuiClose:
ExitApp

+tab::
    Reload
Return

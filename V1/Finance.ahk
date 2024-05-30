#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%
; #Include, C:\\Users\\tijnb\\Desktop\\Programming\\Autohotkey\\Personal\\Ozark_Finances\\V1\\Other Stuff\\eval.ahk
#Include, C:\Users\tijnb\Desktop\Programming\Autohotkey\Personal\library\Debuglog\debug.ahk
OnMessage(0x004A, "ReceiveMessage") ; 0x004A is WM_COPYDATA

Gui, main:Show, w1200 h700 , Ozark Finances

Gui, main:Font, s16, Jetbrains Mono

Gui, main:Add, Tab, x10 y10 w1175 h675 vMotherControl gOnTabChange, Invoices|Withdraws|Finances|Settings

Gui, main:Default

; #Region Invoices TAB --- ;

Gui, main:Tab, Invoices

Gui, main:Add, Listview, x30 y65 w765 h605 gDoubleClick vInvoices grid, Invoice Number|Invoice Date|Excl BTW|BTW|Incl BTW
Gui, main:Add, Button, x820 y65 w350 h50 vGenerateInvoice gGenerateInvoiceGui, Generate Invoice
Gui, main:Add, Button, x820 yp+65 w350 h50 vGenerateAndSend gGenerateAndSendGui, Generate and Send Invoice
Gui, main:Add, Button, x820 yp+65 w350 h50 vSendInvoice gSendInvoiceGui, Send Invoice
Gui, main:Add, Button, x820 y+15 w350 h50 vDeleteInvoice gDeleteInvoice, Delete Invoice
Gui, main:Add, Button, x820 yp+65 w350 h50 vStatusInvoice gChangeInvoiceStatus, Change Invoice Status
Gui, main:Add, Button, x820 yp+65 w350 h50 vReloadInvoice gReloadInvoices, Reload Invoices
Gui, main:Add, Button, x820 yp+65 w350 h50 vOpenFolder gOpenFolder, Open Invoice Folder

Gui, main:Add, Text, x820 yp+65, Total Excl BTW:
Gui, main:Add, Text, x+5 w150 vTotalExclBtw, (None)

Gui, main:Add, Text, x820 yp+45, Total BTW:
Gui, main:Add, Text, x+5 w150 vTotalBTW, (None)

Gui, main:Add, Text, x820 yp+45, Total Incl BTW:
Gui, main:Add, Text, x+5 w150 vTotalInclBtw, (None)

LV_ModifyCol(4, 101)
LV_ModifyCol(5, 190)
gosub, ImportInvoices

; #EndRegion Invoices TAB --- ;

; #Region Withdraws TAB --- ;

Gui, main:Tab, Withdraws

Gui, main:Add, Listview, x30 y65 w740 h305 vTransactions grid gDoubleclickWithdraws, Date|Amount|Description

Gui, Listview, transactions

Gui, main:Add, Text, x30 y+25, Total Withdraws:
Gui, main:Add, Text, x+5 w150 vTotalWithdraws, (None)

Gui, main:Add, Text, x30 y+30, Total Deposits:
Gui, main:Add, Text, x+5 w150 vTotalDeposits, (None)

Gui, main:Add, Button, x+40 y390 w350 h50 gDepositGui, Add Deposit
Gui, main:Add, Button, x415 y450 w350 h50 gWithdrawGui, Add Withdraw
; Gui, main:Show, w800 h550, Transactions ;Gui, Show -> is best if done after you create all your controls

gosub, ImportTransactions

LV_ModifyCol(1, "AutoHdr")
LV_ModifyCol(2, 240)
LV_ModifyCol(3, 355)

; #EndRegion Withdraws TAB --- ;

; #Region Goals TAB --- ;

Gui, main:Tab, Finances

Gui, main:Add, Edit, x20 y65 w480 h40 vGoals -VScroll
Gui, main:Add, Button, x20 y+65 w250 h50 vSaveNote, Save Note
Gui, main:Add, Button, x20 y+65 w250 h50 vDeleteNote, Delete Note

; #EndRegion Goals TAB --- ;

; #Region Settings TAB --- ;

Gui, main:Tab, Settings

Gui, main:Add, Text, x30 y60, Invoice Settings

Gui, main:Add, Button, x30 y+10 w300 h50, Reload Invoices
Gui, main:Add, Button, x30 y+10 w300 h50, Reload Total Profits
Gui, main:Add, Button, x30 y+10 w300 h50, Open Invoice Folder

Gui, main:Add, Text, x30 y300, Withdraws Settings

Gui, main:Add, Button, x30 y+10 w300 h50 gReloadWithdraws, Reload Withdraws
Gui, main:Add, Button, x30 y+10 w300 h50, Open Withdraws File
Gui, main:Add, Button, x30 y+10 w300 h50 gClearWithdraws, Clear Withdraws

Gui, main:Add, Text, x+70 y60, General Settings
Gui, main:Add, Button, x400 y+10 w300 h50 gOpenLogs, Open Logs
Gui, main:Add, Button, x400 y+10 w300 h50 gReloadScript, Reload Script
Gui, main:Add, Button, x400 y+10 w300 h50 gOpenScriptFolder, Open Script Folder

; #EndRegion Settings TAB --- ;

; --- Show GUI --- ;

; --- End Show GUI --- ;

return

ReceiveMessage(wParam, lParam)
{
    Data := StrGet(NumGet(lParam + (2 * A_PtrSize)))
    if (Data = "Pause") {
        Pause, Toggle, 1
    }
    else if (Data = "Suspend") {
        Suspend, Toggle
    }
    else if (Data = "Reload") {
        Reload
    }
    else if (Data = "ExitApp") {
        ExitApp
    }
}

; #Region Variables --- ;

; InvoiceDir := "C:\\Users\\tijnb\\Desktop\\Administratie\\Bakker Services\\2024"
; InvoiceDir := "C:\\Users\\tijnb\\Desktop\\Programming\\Automation\\Personal\\moneyreport\\invoices_examples"

; BatchFile := "C:\\Users\\tijnb\\Desktop\\Programming\\Autohotkey\\Personal\\Ozark_Finances\\V1\\Batch\\Generate.bat"

; #EndRegion Variables --- ;

; #Region Labels --- ;

; #Region Invoice Labels --- ;

; --- Import Invoices --- ;

ImportInvoices:
    Gui, Listview, Invoices

    ExtractDataFromExcel(Excel, FilePath, CellInvoice, CellDate, CellExcl, CellBTW, CellIncl) {
        Workbook := Excel.Workbooks.Open(FilePath)
        Sheet := Workbook.Sheets(1)
        Data1 := Format("{:d}",Sheet.Range(CellInvoice).Value)
        Data2 := ConvertDate(Sheet.Range(CellDate).Value)
        Data3 := EnsureTwoDecimalPlaces(Sheet.Range(CellExcl).Value)
        Data4 := EnsureTwoDecimalPlaces(Sheet.Range(CellBTW).Value)
        Data5 := EnsureTwoDecimalPlaces(Sheet.Range(CellIncl).Value)
        Workbook.Close()
        Workbook := ""
        Sheet := ""
        ; OutputDebug, Invoice Number: %Data1%`n Date: %Data2%`n Excl BTW: %Data3%`n BTW: %Data4%`n Incl BTW: %Data5%
        DebugLog("Invoice Number: " . Data1 . "`n Date: " . Data2 . "`n Excl BTW: " . Data3 . "`n BTW: " . Data4 . "`n Incl BTW: " . Data5)
        return [Data1, Data2, Data3, Data4, Data5]
    }

    EnsureTwoDecimalPlaces(number) {
        return Format("{:0.2f}", StrReplace(number, ",", "."))
    }

    ConvertDate(Date) {
        if (InStr(Date, "/")) {
            ; DateArray := StrSplit(Date, "/", "/")
            ; return DateArray[2] "-" DateArray[1] "-" DateArray[3]
            return StrReplace(Date, "/", "-")
        }
        else if (InStr(Date, "-")) {
            return Date
        }
        else {
            MsgBox, "Invalid Format: " %Date%
        }
    }

    ; InvoiceDirectory := "C:\\Users\\tijnb\\Desktop\\Programming\\Automation\\Personal\\moneyreport\\invoices"
    InvoiceDirectory := "G:\\My Drive\\Bakker Services\\Facturen\\2024"

    Excel := ComObjCreate("Excel.Application")

    Loop, Files, %InvoiceDirectory%\\*.xlsx, F
    {
        if (SubStr(A_LoopFileName, 1, 1) == "~")
            continue

        ExtractedData := ExtractDataFromExcel(Excel, A_LoopFileFullPath, "C13", "C14", "F43", "F44", "F45")
        LV_Add(, ExtractedData[1], ExtractedData[2], ExtractedData[3], ExtractedData[4], ExtractedData[5])
    }

    Excel.Quit()
    gosub, totalprofit
Return

; --- End Import Invoices --- ;

DoubleClick:
    Gui, listview, Invoices
    ; LV_GetText(FileName, A_EventInfo, 1)
    Selected := LV_GetNext(, F)

    LV_GetText(InvoiceNumber, Selected, 1)
    LV_GetText(InvoiceDate, Selected, 2)

    ; MsgBox, % "FileName: " FileName "`nInvoiceNumber: " InvoiceNumber "`nInvoiceDate: " InvoiceDate "`nSelected: " Selected

    Filename := "TringTring" . "_" . InvoiceNumber . "_" . InvoiceDate . "_" . "TijnBakker" . ".xlsx"
    ; msgbox, %FileName%
    ; Run, %InvoiceDirectory%\\%FileName% ; Open the Excel file
    if (FileExist(InvoiceDirectory "\\" FileName))
    {
        Try {
            Run, % InvoiceDirectory "\\" FileName
        }
        Catch {
            Path := InvoiceDirectory "\" StrReplace(FileName, "\\", "\")
            Run, % Path
        }
    }
    else {
        MsgBox, % "File Not Found: " InvoiceDirectory "\\" FileName
    }
Return

ReloadInvoices:
    Gui, Listview, Invoices
    LV_Delete()
    gosub, ImportInvoices
Return

TotalProfit:

    ; InvoiceDir := "G:\\My Drive\\Bakker Services\\Facturen\\2024"
    ; InvoiceDir := "C:\\Users\\tijnb\\Desktop\\Programming\\Automation\\Personal\\moneyreport\\invoices_example"
    ; InvoiceDir := "C:\\Users\\tijnb\\Desktop\\Programming\\Automation\\Personal\\MoneyReport\\invoices_example"

    ; CalculateAndDisplayTotal( InvoiceDir, "F18", "TotalExclBtw")

    ; CalculateAndDisplayTotal(Directory, Cell, Control) {
    Gui, Listview, Invoices
    Total1 := 0
    Total2 := 0
    Total3 := 0
    Loop % LV_GetCount()
    {
        LV_GetText(New1, A_Index, 3)
        LV_GetText(New2, A_Index, 4)
        LV_GetText(New3, A_Index, 5)
        Total1 += New1, Total2 += New2, Total3 += New3
    }
    Total1 := Format("{:0.2f}", Total1)
    Total2 := Format("{:0.2f}", Total2)
    Total3 := Format("{:0.2f}", Total3)
    GuiControl,, TotalExclBtw, %Total1%
    GuiControl,, TotalBTW, %Total2%
    GuiControl,, TotalInclBtw, %Total3%

    ; OutputDebug, `nTotal Excl BTW: %Total1%
    DebugLog("`nTotal Excl BTW: " . Total1)

    ; OutputDebug, `nTotal BTW: %Total2%
    DebugLog("`nTotal BTW: " . Total2)

    ; OutputDebug, `nTotal Incl BTW: %Total3%
    DebugLog("`nTotal Incl BTW: " . Total3)
; }
Return

; #Region Gui Labels --- ;

ChangeInvoiceStatus:
    MsgBox, This doesnt work YET!
Return

Generate:
    GuiControlGet, InvoiceSal, , InvoiceSalary

    ; Define the path to the batch file
    BatchFile := "C:\\Users\\tijnb\\Desktop\\Programming\\Autohotkey\\Personal\\Ozark_Finances\\V1\\Batch\\Generate.bat"

    ; Run the batch file with the necessary arguments
    Run, % BatchFile . " """ . InvoiceSal . """ """ . InvoiceImage . """", , Hide

    ; OutputDebug, python C:\\Users\\tijnb\\Desktop\\Programming\\Automation\\Personal\\MoneyReport\\arg-report.py --data "%InvoiceSalary%" --picture "%InvoiceImage%"
    DebugLog("python C:\\Users\\tijnb\\Desktop\\Programming\\Automation\\Personal\\MoneyReport\\arg-report.py --data " . InvoiceSalary . " --picture " . InvoiceImage)
Return

GenerateAndSend:
    GuiControlGet, InvoiceSal, , InvoiceSalary
    Run, python C:\\Users\\tijnb\\Desktop\\Programming\\Automation\\Personal\\MoneyReport\\argument-scripts\\arg-report.py --data "%InvoiceSal%" --picture "%InvoiceImage%"
    ; OutputDebug, python C:\\Users\\tijnb\\Desktop\\Programming\\Automation\\Personal\\MoneyReport\\arg-report.py --data "%InvoiceSalary%" --picture "%InvoiceImage%"
    DebugLog("python C:\\Users\\tijnb\\Desktop\\Programming\\Automation\\Personal\\MoneyReport\\arg-report.py --data " . InvoiceSalary . " --picture " . InvoiceImage)
Return

BrowseInvoiceImage:
    FileSelectFile, InvoiceImage, S1, %A_Desktop%, Select Invoice Image, Images (*.jpg;*.jpeg;*.png)
Return

SendInvoice:
    LV_GetText(Filename, A_EventInfo, 1)
    Selected := LV_GetNext()
    msgbox, %Selected%
Return

GenerateInvoiceGui:
    Gui, GenInvoice:Show, w350 h280, Generate Invoice
    Gui, GenInvoice:Font, s16, Jetbrains Mono
    Gui, GenInvoice:Add, Text, x22 y10, Invoice Salary:
    Gui, GenInvoice:Add, Edit, x20 y40 w300 h40 vInvoiceSalary -VScroll
    Gui, GenInvoice:Add, Text, x22 y100, Invoice Image Path:
    Gui, GenInvoice:Add, Button, x20 y135 w300 h40 gBrowseInvoiceImage, Browse
    Gui, GenInvoice:Add, Button, x20 y190 w300 h40 gGenerate, Generate
Return

GenerateAndSendGui:
    Gui, GenInvoiceAndSend:Show, w350 h280, Generate and Send Invoice
    Gui, GenInvoiceAndSend:Font, s16, Jetbrains Mono
    Gui, GenInvoiceAndSend:Add, Text, x22 y10, Invoice Salary:
    Gui, GenInvoiceAndSend:Add, Edit, x20 y40 w300 h40 vInvoiceSalary -VScroll
    Gui, GenInvoiceAndSend:Add, Text, x22 y100, Invoice Image Path:
    Gui, GenInvoiceAndSend:Add, Button, x20 y135 w300 h40 gBrowseInvoiceImage, Browse
    Gui, GenInvoiceAndSend:Add, Button, x20 y190 w300 h40 gSendInvoiceGui, Generate and Send
Return

SendInvoiceGui:
    Gui, SendInvoice:Font, s16, Jetbrains Mono
    Gui, SendInvoice:Show, w865 h180, Send Invoice
    Gui, SendInvoice:Add, Text, x20 y20, Selected Invoice:
    Gui, SendInvoice:Add, Text, x250 y20 vInvoiceName, (none)
    Gui, SendInvoice:Add, Text, x20 y55, Receiver Email:
    Gui, SendInvoice:Add, Edit, x225 y55 w620 h30 vSenderEmail -VScroll
    Gui, SendInvoice:Add, Button, x20 y110 w825 h50 gSendInvoice, Send Email
Return

OpenFolder:
    Run, %InvoiceDirectory%
Return

DeleteInvoice:
    Gui, Listview, Invoices
    Gui, Submit, NoHide

    Selected := LV_GetNext()

    LV_GetText(InvoiceNumber, Selected, 1) ; Get the invoice number from the selected row
    LV_GetText(InvoiceDate, Selected, 2) ; Get the invoice date from the selected row
    if (InvoiceNumber = "" or InvoiceDate = "") {
        MsgBox, Please select an invoice to delete.
        return
    }
    MsgBox, 4, , Are you sure you want to delete invoice %InvoiceNumber% from date %InvoiceDate%?
    IfMsgBox, No
        return
    ; LV_Delete() ; Delete the selected row from the ListView
    FileName := "TringTring_" . InvoiceNumber . "_" . InvoiceDate . "_TijnBakker.xlsx"
    ; FileDelete, %InvoiceDirectory%\\%FileName% ; Delete the invoice file

    FileMove, %InvoiceDirectory%\\%Filename%, C:\Users\tijnb\Desktop\Programming\Autohotkey\Personal\Ozark_Finances\V1\DeletedInvoices
    if (ErrorLevel) {
        MsgBox, Could not delete invoice %InvoiceNumber% from date %InvoiceDate%.
    } else {
        MsgBox, Invoice %InvoiceNumber% from date %InvoiceDate% deleted successfully.
        ; gosub, reloadinvoices
        LV_Delete(Selected)
        GoSub, TotalProfit
    }
Return

; #EndRegion Gui Labels --- ;

; #Region Withdraw Labels --- ;

ImportTransactions:
    ; TransactionPath := % A_ScriptDir . "Output\transactions.txt"
    Gui, listview, transactions
    Gui, main:Default
    FileRead, transactions, %A_ScriptDir%\Output\transactions.txt
    Loop, Parse, transactions, `n
    {
        if (A_LoopField != "") {
            date := StrSplit(A_LoopField, "|").1
            amount := StrSplit(A_LoopField, "|").2
            description := StrSplit(A_LoopField, "|").3
            LV_Add(, date, amount, description)
        }
    }
    gosub, TotalWithdraws
Return

Withdraw:
    Gui, main:Default
    Gui, ListView, Transactions
    Gui, Withdraw:Submit
    Gui, Withdraw:Destroy
    if (!RegExMatch(WithdrawAmount, "^[0-9\.]*$") || !RegExMatch(WithdrawDescription, "^[a-zA-Z ]*$")) {
        if (!RegExMatch(WithdrawAmount, "^[0-9\.]*$"))
            MsgBox, You can only Enter Numbers and dots into the Amount box
        if (!RegExMatch(WithdrawDescription, "^[a-zA-Z ]*$"))
            MsgBox, You can only Enter Letters into the Description box
    } else if (WithdrawAmount != "") && (WithdrawDescription != "") {
        FileAppend, % A_DD "-" A_MM "-" A_YYYY " | -" WithdrawAmount " | " WithdrawDescription "`n", %A_ScriptDir%\Output\transactions.txt
        LV_Add(, A_DD "-" A_MM "-" A_YYYY, "-" WithdrawAmount, WithdrawDescription)
        LV_ModifyCol(1, "AutoHdr")
        LV_ModifyCol(2, 240)
        LV_ModifyCol(3, 355)
        gosub, ReloadWithdraws
    }
Return

Deposit:
    Gui, main:Default
    Gui, ListView, Transactions
    Gui, Deposit:Submit
    Gui, Deposit:Destroy
    if (!RegExMatch(DepositAmount, "^[0-9\.]*$") || !RegExMatch(DepositDescription, "^[a-zA-Z]*$")) {
        if (!RegExMatch(DepositAmount, "^[0-9\.]*$"))
            MsgBox, You can only Enter Numbers and dots into the Amount box
        if (!RegExMatch(DepositDescription, "^[a-zA-Z]*$"))
            MsgBox, You can only Enter Letters into the Description box
    } else if (DepositAmount != "") && (DepositDescription != "") {
        FileAppend, % A_DD "-" A_MM "-" A_YYYY " | " DepositAmount " | " DepositDescription "`n", %A_ScriptDir%\transactions.txt
        LV_Add(, A_DD "-" A_MM "-" A_YYYY, DepositAmount, DepositDescription)
        LV_ModifyCol(1, "AutoHdr")
        LV_ModifyCol(2, 240)
        LV_ModifyCol(3, 355)
        gosub, ReloadWithdraws
    }
Return

TotalWithdraws:
    FileRead, transactions, transactions.txt
    TotalWithdraws := 0
    TotalDeposits := 0
    Loop, Parse, transactions, `n
    {
        if (A_LoopField != "") {
            amount := StrSplit(A_LoopField, "|").2
            if (amount < 0) {
                TotalWithdraws += amount
                ; OutputDebug, Negative number in transactions.txt, line %A_Index%: %amount%
                DebugLog("Negative number in transactions.txt, line " . A_Index . ": " . amount)
            } else {
                TotalDeposits += amount
                ; OutputDebug, Positive number in transactions.txt, line %A_Index%: %amount%
                DebugLog("Positive number in transactions.txt, line " . A_Index . ": " . amount)
            }
        }
    }
    TotalWithdraws := Format("{:0.2f}", TotalWithdraws)
    TotalDeposits := Format("{:0.2f}", TotalDeposits)
    GuiControl,, TotalWithdraws, %TotalWithdraws%
    GuiControl,, TotalDeposits, %TotalDeposits%

    ; OutputDebug, `nTotal Withdraws: %TotalWithdraws%
    DebugLog("`nTotal Withdraws: " . TotalWithdraws)

    ; OutputDebug, `nTotal Deposits: %TotalDeposits%
    DebugLog("`nTotal Deposits: " . TotalDeposits)
Return

DoubleclickWithdraws:
Return

; #Region Withdraw Guis --- ;

WithdrawGui:
    Gui, Withdraw:Font, s16, Jetbrains Mono
    Gui, Withdraw:Add, Text, x10 y10, Amount:
    Gui, Withdraw:Add, Edit, x+75 y10 w200 h40 vWithdrawAmount -Vscroll
    Gui, Withdraw:Add, Text, x10 y65, Description:
    Gui, Withdraw:Add, Edit, x+10 y65 w200 h40 vWithdrawDescription -Vscroll
    Gui, Withdraw:Add, Button, x10 y120 w430 h50 gWithdraw, Withdraw
    Gui, Withdraw:Show, w450 h190, Withdraw
Return

DepositGui:
    Gui, Deposit:Font, s16, Jetbrains Mono
    Gui, Deposit:Add, Text, x10 y10, Amount:
    Gui, Deposit:Add, Edit, x+75 y10 w200 h40 vDepositAmount -Vscroll
    Gui, Deposit:Add, Text, x10 y65, Description:
    Gui, Deposit:Add, Edit, x+10 y65 w200 h40 vDepositDescription -Vscroll
    Gui, Deposit:Add, Button, x10 y120 w430 h50 gDeposit, Deposit
    Gui, Deposit:Show, w450 h190, Deposit
Return

; #EndRegion Withdraw Guis --- ;

; #EndRegion Withdraw Labels --- ;

; #Region Settings Labels --- ;

OpenInvoiceDir:
    Run, %InvoiceDirectory%
Return

ReloadWithdraws:
    LV_Delete()
    gosub, ImportTransactions
Return

OpenWithdrawsFile:
    Run, %A_ScriptDir%\Output\transactions.txt
Return

ClearWithdraws:
    MsgBox, 4, Clear Withdraws, YOU'RE ABOUT TO CLEAR ALL THE WITHDRAWS, ARE YOU SURE?
    IfMsgBox, Yes
    {
        ; FileDelete, "C:\Path\to\file.txt"
        LV_Delete()
        MsgBox, File deleted successfully.
        gosub, ImportTransactions
    }
    Else
    {
        MsgBox, Withdraw clearing, cancelled.
    }
Return

OpenLogs:
    Run, %LogLocation%\%A_ScriptName%_%A_DD%-%A_MM%-%A_YYYY%.txt
Return

ReloadScript:
    Reload
Return

OpenScriptFolder:
    Run, %A_ScriptDir%
Return

; #EndRegion Settings Labels --- ;

; #EndRegion Labels --- ;

; #Region Tab Change --- ;

OnTabChange:
    GuiControlGet, CurrentTab, , MotherControl
    if (CurrentTab = "Invoices") {
        ScreenWidth := A_ScreenWidth
        ScreenHeight := A_ScreenHeight

        GuiWidth := 1200
        GuiHeight := 700

        MotherControlWidth := GuiWidth - 20
        MotherControlHeight := GuiHeight - 20

        CenterX := (ScreenWidth - GuiWidth * 1.25) // 2
        CenterY := (ScreenHeight - GuiHeight * 1.25) // 2

        Gui, Show, x%CenterX% y%CenterY% w%GuiWidth% h%GuiHeight%
        GuiControl, Move, MotherControl, w%MotherControlWidth% h%MotherControlHeight%
    } else if (CurrentTab = "Withdraws") {
        ScreenWidth := A_ScreenWidth
        ScreenHeight := A_ScreenHeight

        GuiWidth := 800
        GuiHeight := 550

        MotherControlWidth := GuiWidth - 20
        MotherControlHeight := GuiHeight - 20

        CenterX := (ScreenWidth - GuiWidth * 1.25) // 2
        CenterY := (ScreenHeight - GuiHeight * 1.25) // 2

        Gui, Show, x%CenterX% y%CenterY% w%GuiWidth% h%GuiHeight%
        GuiControl, Move, MotherControl, w%MotherControlWidth% h%MotherControlHeight%
    } else if (CurrentTab = "Goals") {
        ScreenWidth := A_ScreenWidth
        ScreenHeight := A_ScreenHeight

        GuiWidth := 800
        GuiHeight := 700

        MotherControlWidth := GuiWidth - 20
        MotherControlHeight := GuiHeight - 20

        CenterX := (ScreenWidth - GuiWidth * 1.25) // 2
        CenterY := (ScreenHeight - GuiHeight * 1.25) // 2

        Gui, Show, x%CenterX% y%CenterY% w%GuiWidth% h%GuiHeight%
        GuiControl, Move, MotherControl, w%MotherControlWidth% h%MotherControlHeight%
    } else if (CurrentTab = "Settings") {
        ScreenWidth := A_ScreenWidth
        ScreenHeight := A_ScreenHeight

        GuiWidth := 800
        GuiHeight := 700

        MotherControlWidth := GuiWidth - 20
        MotherControlHeight := GuiHeight - 20

        CenterX := (ScreenWidth - GuiWidth * 1.25) // 2
        CenterY := (ScreenHeight - GuiHeight * 1.25) // 2

        Gui, Show, x%CenterX% y%CenterY% w%GuiWidth% h%GuiHeight%
        GuiControl, Move, MotherControl, w%MotherControlWidth% h%MotherControlHeight%

    }

; ToolTip, % "GuiWidth: " GuiWidth "`nGuiHeight: " GuiHeight "`nScreenWidth: " ScreenWidth "`nScreenHeight: " ScreenHeight
; WinGetPos, gX, gY, gWidth, gHeight, A
; SysGet, output, 30
; SysGet, output2, 31
; SysGet, output3, 5
; SysGet, output4, 6
; OutputDebug, %output% %output2% %output3% %output4%
; ToolTip, % "xPos: " CenterX "`nyPos: " CenterY "`ngX: " gX "`ngY: " gY "`nGuiWidth: " GuiWidth "`ngWidth: " gWidth "`nGuiHeight: " GuiHeight "`ngHeight: " gHeight
return

; #EndRegion Tab Change --- ;

; DebugLog(text) {
;     LogLocation := "C:\\Users\\tijnb\\Desktop\\Programming\\Autohotkey\\Personal\\Ozark_Finances\\templogs"
;     OutputDebug, %text%
;     date := A_DD "-" A_MM "-" A_YYYY
;     scriptName := A_ScriptName
;     Footer := "--------------------------------------------"
;     FileAppend,%Footer%`n%text%`n%Footer%, % LogLocation . "\\" . scriptName . "_" . date . ".txt"
; }

GuiClose:
ExitApp
Return

+tab::
    Reload
Return


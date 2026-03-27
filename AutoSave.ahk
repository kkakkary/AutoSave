#Requires AutoHotkey v2.0
#SingleInstance Force

; ============================================================
; AutoSave - BestCase Save As Dialog Navigator
;
; Usage:
;   1. Click "Save as PDF" in BestCase
;   2. Type the filename: "LastName, FirstName - Description.pdf"
;   3. Press Ctrl+Shift+S
;   4. Script navigates to the correct client folder on ReadyNAS
;   5. Click Save
; ============================================================

; --- Configuration ---
BasePath := "\\ReadyNAS\Public\Client Folders A-Z"

; --- Hotkey: Ctrl+Shift+S ---
^+s::
{
    ; Verify a Save dialog is active
    saveHwnd := WinActive("Save")
    if !saveHwnd {
        MsgBox("No Save dialog detected.`n`nMake sure the Save As dialog is in the foreground.", "AutoSave", "Iconi")
        return
    }

    ; Read the filename from the File name edit field
    try {
        filename := ControlGetText("Edit1", "A")
    } catch {
        MsgBox("Could not read the filename field.", "AutoSave", "Icon!")
        return
    }

    filename := Trim(filename)
    if (filename = "") {
        MsgBox("The filename field is empty.`n`nType a filename first, then press the hotkey.", "AutoSave", "Iconi")
        return
    }

    ; Extract client name: everything before " - "
    dashPos := InStr(filename, " - ")
    if (dashPos = 0) {
        MsgBox("Could not parse client name.`n`nExpected format:`nLastName, FirstName - Description.pdf", "AutoSave", "Icon!")
        return
    }

    clientName := SubStr(filename, 1, dashPos - 1)
    clientName := Trim(clientName)

    ; Determine range folder from first letter of last name
    firstLetter := StrUpper(SubStr(clientName, 1, 1))

    if (firstLetter >= "A" && firstLetter <= "F")
        rangeFolder := "A-F"
    else if (firstLetter >= "G" && firstLetter <= "L")
        rangeFolder := "G-L"
    else if (firstLetter >= "M" && firstLetter <= "R")
        rangeFolder := "M-R"
    else if (firstLetter >= "S" && firstLetter <= "Z")
        rangeFolder := "S-Z"
    else {
        MsgBox("Unexpected first character: '" firstLetter "'`n`nFilename must start with a letter.", "AutoSave", "Icon!")
        return
    }

    ; Search for a client folder that starts with the client name
    rangePath := BasePath "\" rangeFolder
    destFolder := ""

    ; Look through folders in the range directory for a match
    loop files, rangePath "\*", "D" {
        if (SubStr(A_LoopFileName, 1, StrLen(clientName)) = clientName) {
            destFolder := A_LoopFileFullPath
            break
        }
    }

    ; If no matching folder found, create one with just the client name
    if (destFolder = "") {
        destFolder := rangePath "\" clientName
        DirCreate(destFolder)
    }

    ; Navigate the Save As dialog:
    ;   1. Put the folder path in the filename field
    ;   2. Press Enter to navigate there
    ;   3. Wait for navigation
    ;   4. Restore the original filename
    ControlSetText(destFolder, "Edit1", "A")
    Sleep(100)
    ControlSend("{Enter}", "Edit1", "A")

    ; Wait for the dialog to navigate to the folder
    Sleep(700)

    ; Restore the original filename so the user can click Save
    ControlSetText(filename, "Edit1", "A")
}

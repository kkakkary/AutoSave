#Requires AutoHotkey v2.0
#SingleInstance Force

; ============================================================
; MoveToClientFolder - Right-click context menu file mover
;
; Moves a file to the correct client folder on ReadyNAS
; based on the filename format: "LastName, FirstName - Description.ext"
;
; Called from the Windows right-click context menu with the
; file path passed as a command-line argument.
; ============================================================

; --- Configuration ---
BasePath := "\\ReadyNAS\Public\Client Folders A-Z"

; --- Get file path from command-line argument ---
if (A_Args.Length < 1) {
    MsgBox("No file specified.`n`nThis script is meant to be run from the right-click context menu.", "Move to Client Folder", "Icon!")
    ExitApp
}

filePath := A_Args[1]

; Verify the file exists
if !FileExist(filePath) {
    MsgBox("File not found:`n" filePath, "Move to Client Folder", "Icon!")
    ExitApp
}

; Get just the filename from the full path
SplitPath(filePath, &fileName)

; Extract client name: everything before " - "
dashPos := InStr(fileName, " - ")
if (dashPos = 0) {
    MsgBox("Could not parse client name from:`n" fileName "`n`nExpected format:`nLastName, FirstName - Description.ext", "Move to Client Folder", "Icon!")
    ExitApp
}

clientName := SubStr(fileName, 1, dashPos - 1)
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
    MsgBox("Unexpected first character: '" firstLetter "'`n`nFilename must start with a letter.", "Move to Client Folder", "Icon!")
    ExitApp
}

; Search for a client folder that starts with the client name
rangePath := BasePath "\" rangeFolder
destFolder := ""

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

; Move the file
destFile := destFolder "\" fileName
try {
    FileMove(filePath, destFile)
    MsgBox("Moved to:`n" destFolder, "Move to Client Folder", "Iconi T3")
} catch as err {
    MsgBox("Failed to move file:`n" err.Message, "Move to Client Folder", "Icon!")
}

ExitApp

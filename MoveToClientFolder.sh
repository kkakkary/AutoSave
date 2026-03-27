#!/bin/bash

# ============================================================
# MoveToClientFolder - Mac right-click context menu file mover
#
# Moves a file to the correct client folder on ReadyNAS
# based on the filename format: "LastName, FirstName - Description.ext"
#
# Called from a Finder Quick Action (Automator)
# ============================================================

# --- Configuration ---
# Update this to your ReadyNAS mount point on Mac
BASE_PATH="/Volumes/Public/Client Folders A-Z"

# --- Process each file passed in ---
for filePath in "$@"; do

    # Verify file exists
    if [ ! -f "$filePath" ]; then
        osascript -e "display dialog \"File not found:\\n$filePath\" with title \"Move to Client Folder\" buttons {\"OK\"} default button \"OK\" with icon stop"
        continue
    fi

    # Get just the filename
    fileName=$(basename "$filePath")

    # Extract client name: everything before " - "
    if [[ "$fileName" != *" - "* ]]; then
        osascript -e "display dialog \"Could not parse client name from:\\n$fileName\\n\\nExpected format:\\nLastName, FirstName - Description.ext\" with title \"Move to Client Folder\" buttons {\"OK\"} default button \"OK\" with icon stop"
        continue
    fi

    clientName="${fileName%% - *}"

    # Get first letter of last name (uppercase)
    firstLetter=$(echo "${clientName:0:1}" | tr '[:lower:]' '[:upper:]')

    # Determine range folder
    if [[ "$firstLetter" =~ [A-F] ]]; then
        rangeFolder="A-F"
    elif [[ "$firstLetter" =~ [G-L] ]]; then
        rangeFolder="G-L"
    elif [[ "$firstLetter" =~ [M-R] ]]; then
        rangeFolder="M-R"
    elif [[ "$firstLetter" =~ [S-Z] ]]; then
        rangeFolder="S-Z"
    else
        osascript -e "display dialog \"Unexpected first character: '$firstLetter'\\n\\nFilename must start with a letter.\" with title \"Move to Client Folder\" buttons {\"OK\"} default button \"OK\" with icon stop"
        continue
    fi

    # Search for a client folder that starts with the client name
    rangePath="$BASE_PATH/$rangeFolder"
    destFolder=""

    if [ -d "$rangePath" ]; then
        while IFS= read -r -d '' folder; do
            folderName=$(basename "$folder")
            if [[ "$folderName" == "$clientName"* ]]; then
                destFolder="$folder"
                break
            fi
        done < <(find "$rangePath" -maxdepth 1 -type d -print0)
    fi

    # If no matching folder found, create one with just the client name
    if [ -z "$destFolder" ]; then
        destFolder="$rangePath/$clientName"
        mkdir -p "$destFolder"
    fi

    # Move the file
    if mv "$filePath" "$destFolder/$fileName" 2>/dev/null; then
        osascript -e "display notification \"Moved to: $destFolder\" with title \"Move to Client Folder\""
    else
        osascript -e "display dialog \"Failed to move file to:\\n$destFolder\" with title \"Move to Client Folder\" buttons {\"OK\"} default button \"OK\" with icon stop"
    fi

done

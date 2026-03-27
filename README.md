# AutoSave

Automate filing documents to client folders on a ReadyNAS network drive. Includes tools for both Windows and Mac.

All scripts expect filenames in the format: `LastName, FirstName - Description.ext`

The client name is extracted from the filename and matched to the correct folder under:

```
Client Folders A-Z/
    A-F/
    G-L/
    M-R/
    S-Z/
```

If a client folder doesn't exist, it will be created automatically.

---

## Windows

### AutoSave.ahk — Save As Dialog Navigator

Automatically navigates a Windows Save As dialog to the correct client folder on the ReadyNAS.

**Requirements:** [AutoHotkey v2](https://www.autohotkey.com/)

**Setup:**
1. Install AutoHotkey v2
2. Double-click `AutoSave.ahk` to run (it sits in the system tray)

**Usage:**
1. Click "Save as PDF" (or any Save As) in your application
2. Type the filename, e.g. `Griffin, Andrew - Chapter 7.pdf`
3. Press `Ctrl+Shift+S`
4. The dialog navigates to `\\ReadyNAS\Public\Client Folders A-Z\G-L\Griffin, Andrew\`
5. Click Save

**Configuration:** Edit the `BasePath` variable at the top of the script to match your network path.

---

### MoveToClientFolder.ahk — Right-Click "Move to Client Folder" (Windows)

Adds a right-click context menu option to move any file to the correct client folder.

**Requirements:** [AutoHotkey v2](https://www.autohotkey.com/)

**Setup:**
1. Install AutoHotkey v2
2. Copy `MoveToClientFolder.ahk` to a permanent location (e.g. `C:\Scripts\`)
3. Edit `InstallContextMenu.reg` — update the path to match where you saved the `.ahk` file
4. Double-click `InstallContextMenu.reg` to add the right-click menu entry

**Usage:**
1. Right-click any file named like `Griffin, Andrew - Motion to Dismiss.pdf`
2. Click **"Move to Client Folder"**
3. The file is moved to `\\ReadyNAS\Public\Client Folders A-Z\G-L\Griffin, Andrew\`

**Configuration:** Edit the `BasePath` variable at the top of the script to match your network path.

---

### InstallContextMenu.reg — Registry Installer

Adds the "Move to Client Folder" entry to the Windows right-click context menu. Edit the paths inside before running.

---

## Mac

### MoveToClientFolder.sh — Right-Click "Move to Client Folder" (Mac)

Adds a right-click Quick Action in Finder to move any file to the correct client folder.

**Requirements:** None (uses built-in macOS tools)

**Setup:**
1. Open **Automator** (search in Spotlight)
2. Click **New Document** → choose **Quick Action**
3. At the top, set:
   - "Workflow receives current" → **files or folders**
   - "in" → **Finder**
4. From the left sidebar, drag **Run Shell Script** into the workflow area
5. Set "Pass input" → **as arguments**
6. Replace the script contents with:
   ```
   /path/to/MoveToClientFolder.sh "$@"
   ```
7. Save it as **"Move to Client Folder"**

**Usage:**
1. Right-click any file in Finder
2. Go to **Quick Actions** → **"Move to Client Folder"**
3. The file is moved to the correct client folder on the ReadyNAS

**Configuration:** Edit the `BASE_PATH` variable at the top of the script to match your ReadyNAS mount point (e.g. `/Volumes/Public/Client Folders A-Z`).

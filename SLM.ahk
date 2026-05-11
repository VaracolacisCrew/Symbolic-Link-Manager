; Created by 		Cristófano Varacolaci
; For 			 	ObsessedDesigns Studios™, Inc.
; Version 			1.0.0.0
; Build             1:40 20260511
;
;---- [changes]
;
;	Version 	1.0.0.0
;   Build       1:40 20260511
;

#Requires AutoHotkey v2.0
#SingleInstance Force

; --- 1. Load Settings (INI Logic) ---
DataDir := A_ScriptDir "\data"
IniPath := DataDir "\__slm.ini"

; Default values
AppName := "Symlink Manager"
AppVersion := "1.0.0"
AppLang := "english"

; Create folder if missing
if !DirExist(DataDir)
    DirCreate(DataDir)

; Read or Create INI
if FileExist(IniPath) {
    AppName := IniRead(IniPath, "SYSTEM", "name", AppName)
    AppVersion := IniRead(IniPath, "SYSTEM", "version", AppVersion)
    AppLang := IniRead(IniPath, "SYSTEM", "lang", AppLang)
} else {
    IniWrite(AppName, IniPath, "SYSTEM", "name")
    IniWrite(AppVersion, IniPath, "SYSTEM", "version")
    IniWrite(AppLang, IniPath, "SYSTEM", "lang")
}

; --- 2. Admin Elevation ---
if !A_IsAdmin {
    try {
        if A_IsCompiled
            Run('*RunAs "' A_ScriptFullPath '" /restart')
        else
            Run('*RunAs "' A_AhkPath '" /restart "' A_ScriptFullPath '"')
        ExitApp()
    } catch {
        MsgBox("This script requires Administrator rights to create Symbolic Links.", "Admin Required")
        ExitApp()
    }
}

; --- 3. Interface Setup ---
MainGui := Gui("", AppName " v" AppVersion) ; Removed +AlwaysOnTop
DllCall("dwmapi\DwmSetWindowAttribute", "ptr", MainGui.Hwnd, "uint", 33, "int*", 1, "uint", 4)
MainGui.SetFont("s8", "Segoe UI")

MainGui.Add("Text", "w380", "1. Select Target Folder:")
TargetEdit := MainGui.Add("Edit", "w320 r1", "") 
BtnBrowse := MainGui.Add("Button", "x+5 yp-1 w55 h24", "Browse") ;

MainGui.Add("Text", "xm y+10", "2. Drag files/folders here (Click item to remove from list):")
PendingList := MainGui.Add("ListView", "xm w380 h150 Grid -Multi", ["Name", "Source Path", "Action"])
PendingList.ModifyCol(1, 120)
PendingList.ModifyCol(2, 210)
PendingList.ModifyCol(3, 45) 

; Action Buttons
BtnCreate := MainGui.Add("Button", "Default w90 h26 xm y+20", "Create Links")
BtnDelete := MainGui.Add("Button", "x+10 yp w90 h26", "Delete Links") ; New Button
BtnCancel := MainGui.Add("Button", "x+110 yp w80 h26", "Cancel")

; --- 4. UIPI Bypass (Fixes Drag & Drop for Admin) ---
DllCall("User32.dll\ChangeWindowMessageFilterEx", "Ptr", MainGui.Hwnd, "UInt", 0x233, "UInt", 1, "Ptr", 0)
DllCall("User32.dll\ChangeWindowMessageFilterEx", "Ptr", MainGui.Hwnd, "UInt", 0x0049, "UInt", 1, "Ptr", 0)

; --- 5. Logic & Events ---

TargetFolder := ""

TargetEdit.OnEvent("Change", UpdateTarget)
UpdateTarget(*) {
    global TargetFolder
    TargetFolder := TargetEdit.Value
}

BtnBrowse.OnEvent("Click", SelectTarget)
SelectTarget(*) {
    global TargetFolder
    StartingDir := DirExist(TargetEdit.Value) ? TargetEdit.Value : A_ProgramFiles
    selected := DirSelect("*" . StartingDir, 3, "Select Target Folder")
    
    if selected {
        TargetFolder := selected
        TargetEdit.Value := selected
        
        PendingList.Delete()
        
        Loop Files, selected "\*", "FD"
        {
            if InStr(FileGetAttrib(A_LoopFileFullPath), "L") {
                PendingList.Add(, A_LoopFileName, A_LoopFileFullPath, "-")
            }
        }
    }
}

MainGui.OnEvent("DropFiles", OnDrop)
OnDrop(GuiObj, GuiCtrl, FileArray, *) {
    for path in FileArray {
        SplitPath(path, &name)
        PendingList.Add(, name, path, "-")
    }
}

PendingList.OnEvent("Click", (LV, RowNumber) => RowNumber ? LV.Delete(RowNumber) : "")

BtnCreate.OnEvent("Click", ProcessLinks)
ProcessLinks(*) {
    global TargetFolder
    if !TargetFolder || !DirExist(TargetFolder) {
        MsgBox("Please select a valid target folder first.", "Folder Missing", "Icon!")
        return
    }

    itemCount := PendingList.GetCount()
    if itemCount = 0 {
        MsgBox("The list is empty.", "Empty List")
        return
    }

    Loop itemCount {
        name   := PendingList.GetText(A_Index, 1)
        source := PendingList.GetText(A_Index, 2)
        dest   := TargetFolder "\" name
        
        if FileExist(dest) && InStr(FileGetAttrib(dest), "L")
            continue 

        isDir  := DirExist(source)
        cmd    := A_ComSpec ' /c mklink ' (isDir ? '/D ' : '') '"' dest '" "' source '"'
        try RunWait(cmd, , "Hide")
    }

    MsgBox("Done! " itemCount " items processed.", "Success")
    PendingList.Delete()
}

; New Logic for Delete Links button
BtnDelete.OnEvent("Click", DeleteSymlinks)
DeleteSymlinks(*) {
    itemCount := PendingList.GetCount()
    if itemCount = 0 {
        MsgBox("Nothing to delete.", "Empty List")
        return
    }

    if MsgBox("Are you sure you want to delete these symbolic links from disk?", "Confirm", "YesNo Icon!") = "No"
        return

    deletedCount := 0
    Loop itemCount {
        path := PendingList.GetText(A_Index, 2)
        
        ; Verify it's a symbolic link before deleting
        if InStr(FileGetAttrib(path), "L") {
            if DirExist(path)
                DirDelete(path)
            else
                FileDelete(path)
            deletedCount++
        }
    }
    
    MsgBox("Deleted " deletedCount " symbolic links.", "Success")
    PendingList.Delete()
}

BtnCancel.OnEvent("Click", (*) => ExitApp())
MainGui.OnEvent("Close", (*) => ExitApp())

MainGui.Show()
# Symbolic Link Manager

A lightweight and efficient **AutoHotkey v2** utility designed to manage Windows Symbolic Links through a user-friendly graphical interface.

---

## 📋 Table of Contents
* [Overview](#overview)
* [Key Features](#key-features)
* [Installation](#installation)
* [How to Use](#how-to-use)
* [Technical Details](#technical-details)
* [License](#license)

---

## 🔍 Overview
**Symlink Manager** automates the creation and deletion of symbolic links (Symlinks). Unlike standard shortcuts, symlinks act as virtual folders or files that the Windows file system treats as if they were physically located at the destination. This is ideal for moving game data, redirecting app configurations, or managing cloud-synced folders.

## ✨ Key Features
*   **Drag & Drop Support:** Effortlessly add files and folders to the processing queue.
*   **Smart Admin Elevation:** Automatically restarts with Administrator privileges (required for `mklink`).
*   **Automatic Detection:** Scans target folders to identify existing symlinks.
*   **UAC/UIPI Bypass:** Custom DllCalls ensure Drag & Drop works even when running as Administrator.
*   **Batch Operations:** Create or delete multiple links in a single click.
*   **Safety First:** The "Delete" function targets only the link, protecting your original data.

## ⚙️ Installation
1.  Ensure you have [AutoHotkey v2](https://www.autohotkey.com/) installed.
2.  Download the script and place it in its own folder.
3.  Run `SymlinkManager.ahk`. On first run, it will create a `data` folder and an `.ini` file for settings.

## 🚀 How to Use
1.  **Select Target:** Click the **Browse** button to choose where you want the links to be created.
2.  **Add Items:** Drag files or folders from your File Explorer into the list view.
3.  **Manage List:** Click any item in the list if you wish to remove it before processing.
4.  **Execute:** 
    *   Click **Create Links** to generate the symlinks at the target location.
    *   Click **Delete Links** to safely remove existing symlinks from the target.

## 🛠 Technical Details
*   **Language:** AutoHotkey v2.0
*   **Privileges:** Requires `RunAs` (Admin) for `mklink` execution.
*   **Interface:** Built with native AHK Gui commands and `Segoe UI` fonts.
*   **Configuration:** Uses `IniRead`/`IniWrite` for persistent application state.

> [!IMPORTANT]
> Creating symbolic links requires local administrator rights on Windows. The script handles this request automatically.

---

## 📄 License
This project is open-source. You are free to use, modify, and distribute it as you see fit.

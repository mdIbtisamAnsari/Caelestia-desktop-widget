# Quickshell Desktop Widget 📁

A lightweight, interactive desktop file and folder manager built for Wayland using **Quickshell** and **QML**. Designed specifically to complement custom rice environments like the **Caelestia Shell**.

---

## ✨ Features
* **Dynamic Grid View**: Automatically maps and displays files/folders directly from your `~/Desktop` directory.
* **Built-in Utility Cards**: Instant quick-access cards for launching your terminal (`foot`), opening system trash, and creating auto-incremented new folders.
* **Robust Context Menu**: Right-click support to open items in your terminal or text editor (`zeditor`), rename items inline, or securely move them to trash via `gio`.
* **Catppuccin Theme**: Styled with a sleek, flat aesthetic matching modern dark mode color palettes.

---

## 🛠️ Prerequisites & Dependencies

Make sure you have the following packages installed on your Linux / Wayland environment (tested on Arch Linux):
* **[Quickshell](https://github.com/outfoxxed/quickshell)** (Nightly / Development version)
* **Qt6 / QtQuick**
* **Nerd Fonts** (`JetBrainsMono Nerd Font` recommended for iconography)
* **Terminal Emulator**: `foot`
* **File Manager & Utilities**: `thunar` and `gio`
* **Text Editor**: `zeditor` (optional, for the context menu option)

---

## 🚀 Installation & Usage

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/quickshell-desktop.git
   cd quickshell-desktop
   ```

2. **Test run the widget directly:**
   You can launch the widget standalone using Quickshell's file path flag:
   ```bash
   quickshell -p FolderWidget.qml
   ```

3. **Integrate with Caelestia Shell:**
   To have the desktop widget start automatically alongside your environment, include the execution command inside your configuration file located at:
   `/home/ibtisam/.config/caelestia/hypr-user.lua`

---

## ⌨️ Controls & Interactions

* **Utility Cards (First Row)**:
  * 🗲 **Terminal**: Double-click to open `foot` inside `~/Desktop`.
  * 🗑️ **Trash**: Double-click to open your trash folder.
  * ➕ **New Folder**: Double-click to instantly create a new folder with auto-naming.
* **Files & Folders**:
  * **Double-Click**: Open folders in `thunar` or files with your system default viewer.
  * **Right-Click**: Open the context menu to access terminal, text editor, inline rename, or move to trash.
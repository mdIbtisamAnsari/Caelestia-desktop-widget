import QtQuick
import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Io

Scope {
    id: root

    readonly property color themeBackground: "#1e1e2e"
    readonly property color themeSurface: "#181825"
    readonly property color themeBorder: "#313244"
    readonly property color themeAccent: "#89b4fa"
    readonly property color themeText: "#cdd6f4"
    readonly property color themeSubtext: "#a6adc8"
    readonly property color themeError: "#f38ba8"

    PanelWindow {
        id: floatingWindow
        width: 320
        height: 380

        anchors {
            right: true
            top: true
        }
        margins {
            right: 30
            top: 40
        }

        color: "transparent"
        aboveWindows: false
        exclusionMode: ExclusionMode.Ignore
        focusable: true

        Rectangle {
            anchors.fill: parent
            color: root.themeBackground
            border.color: root.themeBorder
            border.width: 1
            radius: 12
            clip: true

            FolderListModel {
                id: folderModel
                folder: "file:///home/ibtisam/Desktop"
                showDirs: true
                showFiles: true
                nameFilters: ["*"]
                sortField: FolderListModel.Type
            }

            // Grid View for Files + 3 Default Utility Cards at the beginning
            GridView {
                id: gridView
                anchors {
                    top: header.bottom
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                    margins: 12
                }

                model: folderModel.count + 3
                cellWidth: 94
                cellHeight: 96
                clip: true

                delegate: Item {
                    width: 90
                    height: 90

                    readonly property bool isTerminalCard: (index === 0)
                    readonly property bool isTrashCard: (index === 1)
                    readonly property bool isAddFolderCard: (index === 2)
                    readonly property bool isUtilityCard: (isTerminalCard || isTrashCard || isAddFolderCard)
                    readonly property int fileIndex: index - 3

                    MouseArea {
                        id: itemMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        cursorShape: Qt.PointingHandCursor

                        onDoubleClicked: (mouse) => {
                            if (mouse.button === Qt.LeftButton) {
                                if (isTerminalCard) {
                                    actionProc.command = ["foot", "--working-directory", "/home/ibtisam/Desktop"]
                                    actionProc.running = true
                                } else if (isTrashCard) {
                                    actionProc.command = ["thunar", "/home/ibtisam/.local/share/Trash/files"]
                                    actionProc.running = true
                                } else if (isAddFolderCard) {
                                    actionProc.command = ["bash", "-c", "cd /home/ibtisam/Desktop && name='New Folder'; n=1; while [ -d \"$name\" ]; do name=\"New Folder ($n)\"; n=$((n+1)); done; mkdir \"$name\""]
                                    actionProc.running = true
                                } else {
                                    if (folderModel.isFolder(fileIndex)) {
                                        actionProc.command = ["thunar", folderModel.get(fileIndex, "filePath")]
                                        actionProc.running = true
                                    } else {
                                        Qt.openUrlExternally("file://" + folderModel.get(fileIndex, "filePath"))
                                    }
                                }
                            }
                        }

                        onClicked: (mouse) => {
                            contextMenu.visible = false;
                            if (mouse.button === Qt.RightButton && !isUtilityCard) {
                                contextMenu.targetPath = folderModel.get(fileIndex, "filePath")
                                contextMenu.targetName = folderModel.get(fileIndex, "fileName")
                                contextMenu.isDir = folderModel.isFolder(fileIndex)
                                contextMenu.visible = true
                            }
                        }
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: 8
                        color: itemMouseArea.containsMouse ? "#313244" : "transparent"
                        border.color: itemMouseArea.containsMouse ? root.themeBorder : "transparent"
                        border.width: 1

                        Column {
                            anchors.centerIn: parent
                            spacing: 6

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: isTerminalCard ? "" : (isTrashCard ? "" : (isAddFolderCard ? "" : (folderModel.isFolder(fileIndex) ? "" : "")))
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 26
                                color: isUtilityCard ? root.themeAccent : (folderModel.isFolder(fileIndex) ? root.themeAccent : root.themeSubtext)
                            }

                            Text {
                                width: 80
                                text: isTerminalCard ? "Terminal" : (isTrashCard ? "Trash" : (isAddFolderCard ? "New Folder" : folderModel.get(fileIndex, "fileName")))
                                color: itemMouseArea.containsMouse ? root.themeText : root.themeSubtext
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 11
                                horizontalAlignment: Text.AlignHCenter
                                elide: Text.ElideRight
                                maximumLineCount: 2
                                wrapMode: Text.WordWrap
                            }
                        }
                    }
                }
            }

            // Clean Header
            Rectangle {
                id: header
                width: parent.width
                height: 48
                color: root.themeSurface
                z: 10

                Row {
                    anchors {
                        left: parent.left
                        leftMargin: 14
                        verticalCenter: parent.verticalCenter
                    }
                    spacing: 8

                    Text {
                        text: "📁"
                        font.pixelSize: 14
                    }

                    Text {
                        text: "Desktop"
                        color: root.themeText
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 13
                        font.weight: Font.Bold
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    anchors.bottom: parent.bottom
                    color: root.themeBorder
                }
            }

            // Click-Away Area to Dismiss Dialogs/Menus
            MouseArea {
                anchors.fill: parent
                visible: contextMenu.visible || renameDialog.visible || confirmDialog.visible
                z: 99
                onClicked: {
                    contextMenu.visible = false
                    renameDialog.visible = false
                    confirmDialog.visible = false
                }
            }

            // Context Menu Popup
            Rectangle {
                id: contextMenu
                property string targetPath: ""
                property string targetName: ""
                property bool isDir: false
                width: 160
                height: 170
                visible: false
                color: root.themeSurface
                border.color: root.themeBorder
                border.width: 1
                radius: 8
                z: 100
                anchors.centerIn: parent

                MouseArea {
                    anchors.fill: parent
                    onClicked: {}
                }

                Column {
                    anchors.fill: parent
                    anchors.margins: 6
                    spacing: 2

                    // Option 1: Open in Terminal (Foot)
                    Rectangle {
                        width: parent.width
                        height: 30
                        color: menuTermMouse.containsMouse ? "#313244" : "transparent"
                        radius: 5
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 8
                            text: "Open in Terminal"
                            color: root.themeText
                            font.pixelSize: 11
                        }
                        MouseArea {
                            id: menuTermMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                var target = contextMenu.isDir ? contextMenu.targetPath : contextMenu.targetPath.substring(0, contextMenu.targetPath.lastIndexOf("/"))
                                actionProc.command = ["foot", "--working-directory", target]
                                actionProc.running = true
                                contextMenu.visible = false
                            }
                        }
                    }

                    // Option 2: Open in Zed
                    Rectangle {
                        width: parent.width
                        height: 30
                        color: menuZedMouse.containsMouse ? "#313244" : "transparent"
                        radius: 5
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 8
                            text: "Open in Zed"
                            color: root.themeText
                            font.pixelSize: 11
                        }
                        MouseArea {
                            id: menuZedMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                actionProc.command = ["zeditor", contextMenu.targetPath]
                                actionProc.running = true
                                contextMenu.visible = false
                            }
                        }
                    }

                    // Option 3: Rename
                    Rectangle {
                        width: parent.width
                        height: 30
                        color: menuRenameMouse.containsMouse ? "#313244" : "transparent"
                        radius: 5
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 8
                            text: "Rename"
                            color: root.themeText
                            font.pixelSize: 11
                        }
                        MouseArea {
                            id: menuRenameMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                renameDialog.targetPath = contextMenu.targetPath
                                renameInput.text = contextMenu.targetName
                                contextMenu.visible = false
                                renameDialog.visible = true
                            }
                        }
                    }

                    // Option 4: Move to Trash
                    Rectangle {
                        width: parent.width
                        height: 30
                        color: menuDeleteMouse.containsMouse ? "#313244" : "transparent"
                        radius: 5
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 8
                            text: "Move to Trash"
                            color: root.themeError
                            font.pixelSize: 11
                        }
                        MouseArea {
                            id: menuDeleteMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                confirmDialog.targetPath = contextMenu.targetPath
                                confirmDialog.targetName = contextMenu.targetName
                                contextMenu.visible = false
                                confirmDialog.visible = true
                            }
                        }
                    }
                }
            }

            // Delete Confirmation Dialog
            Rectangle {
                id: confirmDialog
                property string targetPath: ""
                property string targetName: ""
                width: 260
                height: 120
                visible: false
                color: root.themeSurface
                border.color: root.themeBorder
                border.width: 1
                radius: 8
                z: 101
                anchors.centerIn: parent

                MouseArea {
                    anchors.fill: parent
                    onClicked: {}
                }

                Column {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 8

                    Text {
                        text: "Move to Trash?"
                        color: root.themeError
                        font.pixelSize: 12
                        font.weight: Font.Bold
                    }

                    Text {
                        width: parent.width
                        text: "Trash '" + confirmDialog.targetName + "'?"
                        color: root.themeText
                        font.pixelSize: 11
                        elide: Text.ElideRight
                    }

                    Row {
                        anchors.right: parent.right
                        spacing: 8

                        Rectangle {
                            width: 60
                            height: 26
                            radius: 4
                            color: "transparent"
                            border.color: root.themeBorder
                            border.width: 1
                            Text {
                                anchors.centerIn: parent
                                text: "Cancel"
                                color: root.themeSubtext
                                font.pixelSize: 10
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: confirmDialog.visible = false
                            }
                        }

                        Rectangle {
                            width: 60
                            height: 26
                            radius: 4
                            color: root.themeError
                            Text {
                                anchors.centerIn: parent
                                text: "Trash"
                                color: "#ffffff"
                                font.pixelSize: 10
                                font.weight: Font.Bold
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    actionProc.command = ["gio", "trash", confirmDialog.targetPath]
                                    actionProc.running = true
                                    confirmDialog.visible = false
                                }
                            }
                        }
                    }
                }
            }

            // Inline Rename Dialog
            Rectangle {
                id: renameDialog
                property string targetPath: ""
                width: 260
                height: 100
                visible: false
                color: root.themeSurface
                border.color: root.themeBorder
                border.width: 1
                radius: 8
                z: 101
                anchors.centerIn: parent

                MouseArea {
                    anchors.fill: parent
                    onClicked: {} // Block clicks from falling through
                }

                Column {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 8

                    Text {
                        text: "Rename Item"
                        color: root.themeText
                        font.pixelSize: 12
                        font.weight: Font.Bold
                    }

                    Rectangle {
                        width: parent.width
                        height: 30
                        color: root.themeBackground
                        border.color: root.themeAccent
                        border.width: 1
                        radius: 4

                        TextInput {
                            id: renameInput
                            anchors.fill: parent
                            anchors.margins: 6
                            color: root.themeText
                            font.pixelSize: 11
                            selectByMouse: true
                            focus: renameDialog.visible
                            activeFocusOnTab: true

                            onAccepted: {
                                if (text.trim().length > 0) {
                                    var parentDir = renameDialog.targetPath.substring(
                                        0, renameDialog.targetPath.lastIndexOf("/")
                                    )
                                    var newPath = parentDir + "/" + text.trim()

                                    if (newPath !== renameDialog.targetPath) {
                                        actionProc.command = ["mv", renameDialog.targetPath, newPath]
                                        actionProc.running = true
                                    }
                                }

                            renameDialog.visible = false
                            }
                        }
                    }
                }

                onVisibleChanged: {
                    if (visible) {
                        renameInput.text = contextMenu.targetName

                        Qt.callLater(() => {
                            floatingWindow.requestActivate()
                            renameInput.forceActiveFocus()
                            renameInput.selectAll()
                        })
                    }
                }
            }

            Process {
                id: actionProc
                onExited: {
                    var currentPath = folderModel.folder
                    folderModel.folder = ""
                    folderModel.folder = currentPath
                }
            }
        }
    }
}

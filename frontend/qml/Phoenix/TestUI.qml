import QtQuick 2.9
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.3
import QtQuick.Window 2.2
import QtGraphicalEffects 1.0

import Phoenix.Backend 1.0
import Phoenix.Launcher 1.0
import Phoenix.Paths 1.0

import Phoenix.Emulator 1.0
import Phoenix.Frontend 1.0
import Phoenix.Settings 1.0
import Phoenix.Theme 1.0
import Phoenix.Util 1.0

// Main window
PhoenixWindow {
    id: window;
    visible: true;

    Component.onCompleted: {
        // Centers the window with a single shot assignment
        // while still allowing for resize.
        x = Screen.width / 2 - width / 2;
        y = Screen.height / 2 - height / 2;
    }

    width: Screen.width * 0.7;
    height: Screen.height * 0.7;
    color: "black";

    // FIXME: For testing
    MouseArea{
        anchors.fill: parent;
        onDoubleClicked: toggleFullscreen();
    }

    // FIXME: For testing
    Shortcut {
        autoRepeat: false;
        sequence: "v";
        onActivated: gameConsole.vsync = gameConsole.vsync ? false : true;
    }

    // Elements of the Phoenix UI

    property alias remapperModel: remapperModel;
    RemapperModel {
        id: remapperModel;
    }

    property alias libretroVariableModel: libretroVariableModel;
    LibretroVariableModel {
        id: libretroVariableModel;
    }

    ColumnLayout {
        spacing: 0;
        anchors.fill: parent;

        Rectangle {
            height: 200;
            anchors {
                top: parent.top;
                left: parent.left;
                right: parent.right;
            }

            TabView {
                anchors.fill: parent;

                Tab {
                    title: "Input";
                    anchors.fill: parent;
                    Rectangle {
                        color: PhxTheme.common.secondaryBackgroundColor;
                        anchors.fill: parent;

                        RowLayout {
                            id: row;
                            anchors { top: parent.top; bottom: parent.bottom; horizontalCenter: parent.horizontalCenter; }
                            spacing: 10;

                            // Make the roles of listView's model available to all of Row's children
                            property PhxListView listView: scrollView.listView;
                            property Item currentItem: listView.currentItem;
                            property string currentGUID: currentItem == null ? "" : currentItem.guidProxy;
                            property var remapData: currentItem == null ? [] : currentItem.remapDataProxy;
                            property bool available: currentItem == null ? false : currentItem.availableProxy;
                            property bool pressed: currentItem == null ? false : currentItem.pressedProxy;

                            // A list of available GUIDs to remap
                            PhxScrollView {
                                id: scrollView;

                                Layout.fillHeight: true;
                                Layout.fillWidth: true;
                                Layout.preferredWidth: 600;

                                // Make listView available from Row
                                property PhxListView listView: listView;
                                PhxListView {
                                    id: listView
                                    anchors.fill: parent;

                                    orientation: ListView.Vertical;

                                    model: remapperModel;

                                    Component.onCompleted: forceActiveFocus();

                                    delegate: Item {
                                        height: PhxTheme.common.menuItemHeight;
                                        anchors { left: parent.left; right: parent.right; }

                                        // Make these roles available outside the delegate Component
                                        property string guidProxy: GUID;
                                        property var remapDataProxy: remapData;
                                        property bool availableProxy: available;
                                        property bool pressedProxy: pressed;

                                        MarqueeText {
                                            id: platformText;
                                            anchors { verticalCenter: parent.verticalCenter; left: parent.left; right: parent.right; leftMargin: PhxTheme.common.menuItemMargin; rightMargin: PhxTheme.common.menuItemMargin; }
                                            horizontalAlignment: Text.AlignLeft;
                                            text: friendlyName + ( GUID !== "" ? ( " (" + GUID + ( available ? ")" : ")(disconnected)" ) ) : "" );
                                            fontSize: PhxTheme.common.baseFontSize + 1;
                                            color: available ? PhxTheme.common.menuSelectedColor : PhxTheme.selectionArea.baseFontColor;
                                            spacing: 40;
                                            running: listView.currentIndex === index || mouseArea.containsMouse;
                                            pixelsPerFrame: 2.0;
                                            bold: index === listView.currentIndex;
                                        }

                                        Rectangle {
                                            anchors.verticalCenter: parent.verticalCenter;
                                            anchors.left: platformText.right;
                                            width: 8;
                                            height: PhxTheme.common.menuItemHeight - 5;
                                            color: pressed ? PhxTheme.common.successColor : PhxTheme.common.errorColor;
                                        }

                                        MouseArea {
                                            id: mouseArea;
                                            anchors.fill: parent;
                                            hoverEnabled: true;
                                            onClicked: if( listView.currentIndex !== index && !remapperModel.remapMode ) listView.currentIndex = index;
                                        }
                                    }
                                }
                            }

                            // Remapping data
                            GridLayout {
                                id: grid;

                                Layout.alignment: Qt.AlignLeft | Qt.AlignTop;
                                Layout.fillWidth: true;
                                Layout.preferredWidth: 600;

                                columns: 4;
                                rowSpacing: 10;
                                columnSpacing: 10;

                                property color textColor: row.available ? "white" : "gray";

                                // Face buttons
                                Text {
                                    color: grid.textColor;
                                    text: "A: " + row.remapData[ "a" ];
                                    Layout.column: 0; Layout.row: 0;
                                    MouseArea { anchors.fill: parent; onClicked: if( row.available ) remapperModel.beginRemapping( row.currentGUID, "a" ); }
                                }
                                Text {
                                    color: grid.textColor;
                                    text: "B: " + row.remapData[ "b" ];
                                    Layout.column: 0; Layout.row: 1;
                                    MouseArea { anchors.fill: parent; onClicked: if( row.available ) remapperModel.beginRemapping( row.currentGUID, "b" ); }
                                }
                                Text {
                                    color: grid.textColor;
                                    text: "X: " + row.remapData[ "x" ];
                                    Layout.column: 0; Layout.row: 2;
                                    MouseArea { anchors.fill: parent; onClicked: if( row.available ) remapperModel.beginRemapping( row.currentGUID, "x" ); }
                                }
                                Text {
                                    color: grid.textColor;
                                    text: "Y: " + row.remapData[ "y" ];
                                    Layout.column: 0; Layout.row: 3;
                                    MouseArea { anchors.fill: parent; onClicked: if( row.available ) remapperModel.beginRemapping( row.currentGUID, "y" ); }
                                }

                                // D-Pad
                                Text {
                                    color: grid.textColor;
                                    text: "Up: " + row.remapData[ "dpup" ];
                                    Layout.column: 1; Layout.row: 0;
                                    MouseArea { anchors.fill: parent; onClicked: if( row.available ) remapperModel.beginRemapping( row.currentGUID, "dpup" ); }
                                }
                                Text {
                                    color: grid.textColor;
                                    text: "Down: " + row.remapData[ "dpdown" ];
                                    Layout.column: 1; Layout.row: 1;
                                    MouseArea { anchors.fill: parent; onClicked: if( row.available ) remapperModel.beginRemapping( row.currentGUID, "dpdown" ); }
                                }
                                Text {
                                    color: grid.textColor;
                                    text: "Left: " + row.remapData[ "dpleft" ];
                                    Layout.column: 1; Layout.row: 2;
                                    MouseArea { anchors.fill: parent; onClicked: if( row.available ) remapperModel.beginRemapping( row.currentGUID, "dpleft" ); }
                                }
                                Text {
                                    color: grid.textColor;
                                    text: "Right: " + row.remapData[ "dpright" ];
                                    Layout.column: 1; Layout.row: 3;
                                    MouseArea { anchors.fill: parent; onClicked: if( row.available ) remapperModel.beginRemapping( row.currentGUID, "dpright" ); }
                                }

                                // Center buttons
                                Text {
                                    color: grid.textColor;
                                    text: "Back: " + row.remapData[ "back" ];
                                    Layout.column: 2; Layout.row: 0;
                                    MouseArea { anchors.fill: parent; onClicked: if( row.available ) remapperModel.beginRemapping( row.currentGUID, "back" ); }
                                }
                                Text {
                                    color: grid.textColor;
                                    text: "Guide: " + row.remapData[ "guide" ];
                                    Layout.column: 2; Layout.row: 1;
                                    MouseArea { anchors.fill: parent; onClicked: if( row.available ) remapperModel.beginRemapping( row.currentGUID, "guide" ); }
                                }
                                Text {
                                    color: grid.textColor;
                                    text: "Start: " + row.remapData[ "start" ];
                                    Layout.column: 2; Layout.row: 2;
                                    MouseArea { anchors.fill: parent; onClicked: if( row.available ) remapperModel.beginRemapping( row.currentGUID, "start" ); }
                                }

                                // Shoulder buttons
                                Text {
                                    color: grid.textColor;
                                    text: "L: " + row.remapData[ "leftshoulder" ];
                                    Layout.column: 3; Layout.row: 0;
                                    MouseArea { anchors.fill: parent; onClicked: if( row.available ) remapperModel.beginRemapping( row.currentGUID, "leftshoulder" ); }
                                }
                                Text {
                                    color: grid.textColor;
                                    text: "R: " + row.remapData[ "rightshoulder" ];
                                    Layout.column: 3; Layout.row: 1;
                                    MouseArea { anchors.fill: parent; onClicked: if( row.available ) remapperModel.beginRemapping( row.currentGUID, "rightshoulder" ); }
                                }
                                Text {
                                    color: grid.textColor;
                                    text: "L2: " + row.remapData[ "lefttrigger" ];
                                    Layout.column: 3; Layout.row: 2;
                                    MouseArea { anchors.fill: parent; onClicked: if( row.available ) remapperModel.beginRemapping( row.currentGUID, "lefttrigger" ); }
                                }
                                Text {
                                    color: grid.textColor;
                                    text: "R2: " + row.remapData[ "righttrigger" ];
                                    Layout.column: 3; Layout.row: 3;
                                    MouseArea { anchors.fill: parent; onClicked: if( row.available ) remapperModel.beginRemapping( row.currentGUID, "righttrigger" ); }
                                }
                                Text {
                                    color: grid.textColor;
                                    text: "L3: " + row.remapData[ "leftstick" ];
                                    Layout.column: 3; Layout.row: 4;
                                    MouseArea { anchors.fill: parent; onClicked: if( row.available ) remapperModel.beginRemapping( row.currentGUID, "leftstick" ); }
                                }
                                Text {
                                    color: grid.textColor;
                                    text: "R3: " + row.remapData[ "rightstick" ];
                                    Layout.column: 3; Layout.row: 5;
                                    MouseArea { anchors.fill: parent; onClicked: if( row.available ) remapperModel.beginRemapping( row.currentGUID, "rightstick" ); }
                                }
                                Text {
                                    color: grid.textColor;
                                    text: "Left analog X: " + row.remapData[ "leftx" ];
                                    Layout.column: 4; Layout.row: 0;
                                    MouseArea { anchors.fill: parent; onClicked: if( row.available ) remapperModel.beginRemapping( row.currentGUID, "leftx" ); }
                                }
                                Text {
                                    color: grid.textColor;
                                    text: "Left analog Y: " + row.remapData[ "lefty" ];
                                    Layout.column: 4; Layout.row: 1;
                                    MouseArea { anchors.fill: parent; onClicked: if( row.available ) remapperModel.beginRemapping( row.currentGUID, "lefty" ); }
                                }
                                Text {
                                    color: grid.textColor;
                                    text: "Right analog X: " + row.remapData[ "rightx" ];
                                    Layout.column: 4; Layout.row: 2;
                                    MouseArea { anchors.fill: parent; onClicked: if( row.available ) remapperModel.beginRemapping( row.currentGUID, "rightx" ); }
                                }
                                Text {
                                    color: grid.textColor;
                                    text: "Right analog Y: " + row.remapData[ "righty" ];
                                    Layout.column: 4; Layout.row: 3;
                                    MouseArea { anchors.fill: parent; onClicked: if( row.available ) remapperModel.beginRemapping( row.currentGUID, "righty" ); }
                                }
                            }
                        }
                    }
                }

                Tab {
                    title: "Settings";

                    Rectangle {
                        color: PhxTheme.common.secondaryBackgroundColor;
                        anchors.fill: parent;

                        ScrollView {
                            anchors.fill: parent;

                            ListView {
                                orientation: ListView.Vertical;
                                model: libretroVariableModel;

                                delegate: Item {
                                    height: 25;
                                    width: 300;

                                    Row {
                                        anchors.fill: parent;

                                        Rectangle {
                                            anchors {
                                                top: parent.top;
                                                bottom: parent.bottom;
                                            }
                                            width: 200;

                                            color: "red";

                                            Text {
                                                anchors.centerIn: parent;
                                                text: key;
                                            }
                                        }

                                        Rectangle {
                                            anchors {
                                                top: parent.top;
                                                bottom: parent.bottom;
                                            }
                                            width: 200;

                                            color: "yellow";

                                            Text {
                                                anchors.centerIn: parent;
                                                text: description;
                                            }
                                        }

                                        Rectangle {
                                            anchors {
                                                top: parent.top;
                                                bottom: parent.bottom;
                                            }
                                            width: 300;
                                            color: "blue";

                                            ComboBox {
                                                anchors.centerIn: parent;
                                                model: choices;
                                                width: 280;

                                                onCurrentTextChanged: {
                                                    libretroVariableModel.updateVariable( key, currentText );
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                Tab {
                    title: "Audio";
                    anchors.fill: parent;
                    Rectangle {
                        anchors.fill: parent;
                        color: PhxTheme.common.secondaryBackgroundColor;
                    }
                }

                Tab {
                    title: "Video";
                    anchors.fill: parent;
                    Rectangle {
                        anchors.fill: parent;
                        color: PhxTheme.common.secondaryBackgroundColor;
                    }
                }
            }
        }

        Emulator {
            id: emulator;
            Layout.fillHeight: true;
            anchors {
                left: parent.left;
                right: parent.right;
            }

            Component.onCompleted: {
                emulator.gameConsole.variableModel = window.libretroVariableModel;
                emulator.gameConsole.remapperModel = remapperModel;
            }
        }
    }

    // Make Emulator and its most important children available globally
    property alias emulator: emulator;
    property alias controlOutput: emulator.controlOutput;
    property alias gameConsole: emulator.gameConsole;
    property alias globalGamepad: emulator.globalGamepad;
    property alias videoOutput: emulator.videoOutput;

//    Library {
//        id: library;
//        anchors.fill: parent;
//    }

//    // Make Library (and (TODO) its most important children) available globally
//    property alias library: library;

    // Misc Window stuff

    // Fullscreen shortcuts
    Shortcut {
        autoRepeat: false;
        sequence: StandardKey.FullScreen;
        onActivated: toggleFullscreen();
    }

    Shortcut {
        autoRepeat: false;
        sequence: "Alt+Return";
        onActivated: toggleFullscreen();
    }

    // FIXME: For testing
    Shortcut {
        autoRepeat: false;
        sequence: "f";
        onActivated: toggleFullscreen();
    }

    function toggleFullscreen() {
        if( window.visibility === Window.FullScreen )
            window.visibility = Window.Windowed;
        else if( window.visibility & ( Window.Windowed | Window.Maximized ) )
            window.visibility = Window.FullScreen;
    }
}

import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Window 2.0
import QtGraphicalEffects 1.0

import Phoenix.Backend 1.0

import Phoenix.Frontend 1.0
import Phoenix.Settings 1.0
import Phoenix.Theme 1.0
import Phoenix.Util 1.0

Item {
    // Background
    Item {
        width: parent.width;
        height: 45;

        // Top accent (thin white bar)
        Rectangle {
            width: parent.width - 2;
            height: 1;
            anchors { top: parent.top; topMargin: 1; horizontalCenter: parent.horizontalCenter; }
            opacity: 0.35;
            color: Qt.rgba( 255, 255, 255, 0.35 );
        }

        // Left side
        Row {
            id: mediaButtonsRow;
            anchors.fill: parent;
            anchors.leftMargin: 10;
            // Play - Pause
            Rectangle {
                anchors { top: parent.top; bottom: parent.bottom; }
                color: "transparent";
                width: 32;

                Image {
                    anchors.centerIn: parent;
                    anchors.margins: 10;
                    width: parent.width;
                    sourceSize { height: height; width: width; }
                    source: phoenix.state === "Playing" ? qsTr( "../Assets/pause.svg" ) : qsTr( "../Assets/play.svg" );
                }

                MouseArea {
                    anchors.fill: parent;
                    // TODO: Check if pausable
                    onClicked: phoenix.state = phoenix.state === "Paused" ? "Playing" : "Paused";
                }
            }

            // Volume
            Item {
                id: volume;
                property real savedVolume: 0.0;
                property bool isMute: false;
                anchors { top: parent.top; bottom: parent.bottom; }
                width: 28 + 55;
                Row {
                    anchors.fill: parent;

                    Rectangle {
                        id: volIcon;
                        anchors { top: parent.top; bottom: parent.bottom; margins: 10; }
                        width: 28;
                        color: "transparent";

                        Image {
                            anchors.centerIn: parent;
                            width: parent.width;
                            source: volumeIcon;

                            // Volume Icon changer
                            property string volumeIcon: {
                                if( gameConsole.volume <= 1.0 && gameConsole.volume > 0.5 ) { volumeIcon: "../Assets/volume.svg"; }
                                if( gameConsole.volume <= 0.5 && gameConsole.volume > 0.0 ) { volumeIcon: "../Assets/volumehalf.svg"; }
                                if( gameConsole.volume == 0 ) { volumeIcon: "../Assets/volumemute.svg"; }
                            }

                            sourceSize { height: height; width: width; }
                        }

                        MouseArea {
                            anchors.fill: parent;
                            onClicked: {
                                // Mute
                                if( volume.isMute ) {
                                    volumeSlider.value = volume.savedVolume;
                                    volume.isMute = false;
                                } else {
                                    volume.savedVolume = volumeSlider.value;
                                    volumeSlider.value = 0.0;
                                    volume.isMute = true;
                                }
                            }
                        }
                    }

                    Slider {
                        id: volumeSlider;
                        anchors { verticalCenter: parent.verticalCenter; }
                        width: 55;
                        height: parent.height;
                        minimumValue: 0;
                        maximumValue: 1;
                        value: gameConsole.volume;
                        onValueChanged: function() {
                            gameConsole.volume = value;
                            if(gameConsole.volume>0.0) {
                                volume.isMute = false;
                            }
                        }
                        stepSize: 0.01;
                        activeFocusOnPress: true;
                        focus: false;
                        tickmarksEnabled: false;

                        style: SliderStyle {
                            handle: Item {
                                height: 12;
                                width: 4;
                                Rectangle { id: handleRectangle; anchors.fill: parent; color: "#FFFFFF"; }
                            }

                            groove: Item {
                                width: control.width;
                                height: 2;
                                Rectangle { anchors.fill: parent; color: "#FFFFFF"; opacity: .35; }
                            }
                        }
                    }
                }
            }

            /*/ Settings
            Rectangle {
                anchors { top: parent.top; bottom: parent.bottom; }
                color: "transparent"
                width: 40;

                Button {
                    anchors.centerIn: parent;
                    width: parent.width;
                    iconName: "Settings";
                    iconSource: "settings.svg";
                    style: ButtonStyle { background: Rectangle { color: "transparent"; } }
                }
            } */
        }

        // Right side
        Row {
            anchors { top: parent.top; bottom: parent.bottom; right: parent.right; }
            anchors.rightMargin: 12;

            // Blur
            Rectangle {
                anchors { top: parent.top; bottom: parent.bottom; }
                color: "transparent";
                width: 40;

                Image {
                    anchors.centerIn: parent;
                    anchors.margins: 10;
                    width: 24;
                    height: 24;
                    sourceSize { height: height; width: width; }
                    source: "../Assets/blur.svg";
                }

                MouseArea {
                    anchors.fill: parent;
                    onClicked: emulator.blurEffect.desiredOpacity = emulator.blurEffect.desiredOpacity === 0.0 ? 1.0 : 0.0;
                }
            }

            // Toggle TV mode
            Item {
                id: tvmodeToggle;
                anchors.verticalCenter: parent.verticalCenter;
                width: 32;
                height: width;

                Image {
                    id: tvLabel;
                    anchors.fill: parent;
                    anchors.margins: 4;
                    source: "../Assets/tv.svg"
                    smooth: false;
                    sourceSize { height: height; width: width; }
                }

                MouseArea {
                    anchors.fill: parent;
                    onClicked: {
                        // off -> 16:9
                        if( !videoOutput.television ) {
                            videoOutput.enableAnimation = true;
                            videoOutput.television = true;
                            videoOutput.widescreen = true;
                            videoOutput.enableAnimation = false;
                            tvLabel.source = "../Assets/tv169.svg";
                            return;
                        }
                        // 16:9 -> off
                        if( videoOutput.television && videoOutput.widescreen ) {
                            videoOutput.enableAnimation = true;
                            videoOutput.television = false;
                            videoOutput.widescreen = false;
                            videoOutput.enableAnimation = false;
                            tvLabel.source = "../Assets/tv.svg"
                            return;
                        }
                    }

                }
            }

            // Suspend/minimize
            Item {
                anchors { top: parent.top; bottom: parent.bottom; }
                width: 32;

                Image {
                    anchors.centerIn: parent;
                    anchors.margins: 10;
                    width: parent.width;
                    source: "../Assets/minimize.svg";
                    sourceSize { height: height; width: width; }
                }

                MouseArea {
                    anchors.fill: parent;
                    onClicked: {
                        // Pause if we're playing
                        if( phoenix.state === "Playing" ) {
                            phoenix.state = "Paused";
                        }

                        // We either just paused or we were already paused
                        if( phoenix.state === "Paused" ) {
                            phoenix.state = "Minimizing";
                        }
                    }
                }
            }

            // Fullscreen
            Item {
                id: fullscreenItem;
                anchors { top: parent.top; bottom: parent.bottom; }
                width: 24;

                Image {
                    anchors.centerIn: parent;
                    height: 18;
                    width: 18;
                    sourceSize { height: height; width: width; }
                    property string screenIcon: {
                        if ( window.visibility === Window.FullScreen ) screenIcon: "../Assets/window.svg";
                        else if ( window.visibility === Window.Windowed | Window.Maximized ) screenIcon: "../Assets/fullscreen.svg";
                    }
                    source: screenIcon;
                    MouseArea {
                        anchors.fill: parent;
                        onClicked: window.toggleFullscreen();
                    }
                }
            }

            // Shutdown/close
            Item {
                anchors { top: parent.top; bottom: parent.bottom; }
                width: 32;

                Image {
                    anchors.centerIn: parent;
                    anchors.margins: 10;
                    width: parent.width;
                    source: "../Assets/shutdown.svg";
                    sourceSize { height: height; width: width; }
                }

                MouseArea {
                    anchors.fill: parent;
                    onClicked: {
                        phoenix.state = "Unloading";
                    }
                }
            }
        }
    }
}

import QtQuick 2.5
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0

import vg.phoenix.models 1.0
import vg.phoenix.themes 1.0

ScrollView {
    id: platformsView;

    ListView {
        id: listView;
        spacing: 0;
        model: PlatformsModel {
            id: platformsModel;

        }

        highlight: Item {
            x: listView.currentItem.x;
            y: listView.currentItem.y;
            //width: listView.currentItem.width;
            //height: listView.currentItem.height;
            anchors.fill: listView.currentItem;

            Rectangle {
                id: highlighterRectangle;
                anchors.fill: parent;
                color: PhxTheme.common.normalButtonColor;
            }
        }

        header: Rectangle {
            color: "transparent";
            height: 36;

            anchors {
                left: parent.left;
                right: parent.right;
            }

            Label {
                text: qsTr( "Systems" );
                font.bold: true;
                anchors {
                    verticalCenter: parent.verticalCenter;
                    left: parent.left;
                    leftMargin: 12;
                }

                font {
                    pixelSize: PhxTheme.selectionArea.headerFontSize;
                }

                color: PhxTheme.selectionArea.highlightFontColor;
            }

            /*
            Button {

                anchors {
                    verticalCenter: parent.verticalCenter;
                    right: parent.right;
                    rightMargin: 24;
                }

                text: qsTr( "All" );
                onClicked: {
                    listView.currentIndex = -1;
                    contentArea.contentLibraryModel.clearFilter( "games", "system" );
                }

            }
            */
        }

        delegate: Item {
            height: 25;

            anchors {
                left: parent.left;
                right: parent.right;
            }

            Label {
                id: platformText;
                text: listView.model.get( index );
                anchors {
                    verticalCenter: parent.verticalCenter;
                    left: parent.left;
                    leftMargin:  24;
                }

                font {
                    pixelSize: PhxTheme.selectionArea.basePixelSize;
                }

                color: index === listView.currentIndex ? PhxTheme.selectionArea.highlightFontColor : PhxTheme.selectionArea.baseFontColor;

            }

            MouseArea {
                anchors.fill: parent;
                onClicked: {
                    if ( contentArea.contentStackView.currentItem.objectName !== "PlatformsView" ) {
                        contentArea.contentStackView.push( { item: contentArea.boxartGrid, replace: true } );
                    }

                    listView.currentIndex = index;
                    if ( index === 0 ) {
                        contentArea.contentLibraryModel.clearFilter( "games", "system" );
                    } else {
                        contentArea.contentLibraryModel.setFilter( "games", "system", platformText.text );
                    }
                }
            }
        }
    }
}

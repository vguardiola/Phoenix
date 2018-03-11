import QtQuick 2.9
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4

import Phoenix.Models 1.0
import Phoenix.Theme 1.0

TextField {
    id: searchBar;
    placeholderText: "";
    textColor: "#333";

    style: TextFieldStyle {
        placeholderTextColor: PhxTheme.common.baseFontColor;
        background: Item {
            width: control.width;
            height: control.height;
        }
    }
}

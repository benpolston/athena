// Login screen styled like hyprlock. Colours/wallpaper come from matugen via theme.conf.user.
import QtQuick
import QtQuick.Controls
import QtQuick.Effects

Rectangle {
    id: root
    width: 1920; height: 1080
    color: c("surface", "#121318")

    function c(key, fallback) { var v = config.stringValue(key); return v && v.length ? v : fallback }
    readonly property string font: "JetBrainsMono Nerd Font"
    readonly property string userName: userModel.lastUser && userModel.lastUser.length ? userModel.lastUser
                                        : (userModel.count > 0 ? (userModel.data(userModel.index(0, 0), Qt.UserRole + 1) || "") : "")
    property int sessionIndex: sessionModel.lastIndex >= 0 ? sessionModel.lastIndex : 0

    // ---------- background: wallpaper, blurred + dimmed ----------
    Image {
        id: wall
        anchors.fill: parent
        source: "file://" + c("background", "")
        fillMode: Image.PreserveAspectCrop
        asynchronous: false
        cache: false
        visible: false
    }
    MultiEffect {
        anchors.fill: parent
        source: wall
        visible: wall.status === Image.Ready
        blurEnabled: true
        blur: 1.0
        blurMax: 64
        brightness: -0.25
        saturation: 0.1
    }

    // ---------- clock ----------
    property date now: new Date()
    Timer { interval: 1000; running: true; repeat: true; onTriggered: root.now = new Date() }

    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        y: parent.height * 0.12
        spacing: 0
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatTime(root.now, "HH:mm")
            color: c("onSurface", "#ffffff")
            font { family: root.font; pixelSize: root.height * 0.13; bold: true }
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDate(root.now, "dddd, d MMMM")
            color: c("primary", "#b8c4ff")
            font { family: root.font; pixelSize: root.height * 0.026 }
        }
    }

    // ---------- avatar + greeting + password ----------
    Column {
        id: loginBox
        anchors.horizontalCenter: parent.horizontalCenter
        y: parent.height * 0.48
        spacing: root.height * 0.022

        Item {
            id: avatar
            anchors.horizontalCenter: parent.horizontalCenter
            width: root.height * 0.13; height: width

            Rectangle {   // ring
                anchors.fill: parent
                radius: width / 2
                color: "transparent"
                border.width: 4
                border.color: c("primary", "#b8c4ff")
            }
            Image {
                id: face
                anchors.fill: parent; anchors.margins: 6
                source: "file://" + c("face", "")
                fillMode: Image.PreserveAspectCrop
                visible: false
                layer.enabled: true
            }
            Rectangle {
                id: faceMask
                anchors.fill: face
                radius: width / 2
                visible: false
                layer.enabled: true
            }
            MultiEffect {
                anchors.fill: face
                source: face
                visible: face.status === Image.Ready
                maskEnabled: true
                maskSource: faceMask
                maskThresholdMin: 0.5
                maskSpreadAtMin: 1.0
            }
            Text {   // fallback initial
                anchors.centerIn: parent
                visible: face.status !== Image.Ready
                text: root.userName.length ? root.userName[0].toUpperCase() : "?"
                color: c("primary", "#b8c4ff")
                font { family: root.font; pixelSize: parent.height * 0.45; bold: true }
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            property int h: root.now.getHours()
            text: (h < 5 ? "Up late" : h < 12 ? "Good morning" : h < 18 ? "Good afternoon" : "Good evening")
                  + (root.userName.length ? ", " + root.userName : "")
            color: c("onSurface", "#ffffff")
            font { family: root.font; pixelSize: root.height * 0.022 }
        }

        TextField {
            id: userField   // only shown if SDDM doesn't know the last user
            visible: root.userName.length === 0
            anchors.horizontalCenter: parent.horizontalCenter
            width: root.height * 0.32; height: root.height * 0.05
            placeholderText: "Username"
            horizontalAlignment: TextInput.AlignHCenter
            color: c("onSurface", "#ffffff")
            placeholderTextColor: c("onSurfaceVariant", "#aaaaaa")
            font { family: root.font; pixelSize: height * 0.36 }
            background: Rectangle { radius: height / 2; color: Qt.alpha(c("surfaceContainer", "#292a2f"), 0.75)
                                    border.width: 2; border.color: c("primary", "#b8c4ff") }
            onAccepted: password.forceActiveFocus()
        }

        TextField {
            id: password
            anchors.horizontalCenter: parent.horizontalCenter
            width: root.height * 0.32; height: root.height * 0.05
            echoMode: TextInput.Password
            passwordCharacter: "●"
            placeholderText: "󰌾  Password"
            horizontalAlignment: TextInput.AlignHCenter
            color: c("onSurface", "#ffffff")
            placeholderTextColor: c("onSurfaceVariant", "#aaaaaa")
            font { family: root.font; pixelSize: height * 0.36 }
            focus: true
            background: Rectangle {
                id: pwBg
                radius: height / 2
                color: Qt.alpha(c("surfaceContainer", "#292a2f"), 0.75)
                border.width: 2
                border.color: errorText.visible ? c("error", "#ffb4ab") : c("primary", "#b8c4ff")
                Behavior on border.color { ColorAnimation { duration: 200 } }
            }
            onAccepted: login()
            onTextChanged: errorText.visible = false
            // shake on failure
            SequentialAnimation on anchors.horizontalCenterOffset {
                id: shake; running: false
                NumberAnimation { to: -14; duration: 50 }
                NumberAnimation { to: 14;  duration: 70 }
                NumberAnimation { to: -8;  duration: 60 }
                NumberAnimation { to: 0;   duration: 50 }
            }
        }

        Text {
            id: errorText
            visible: false
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Wrong password. Try again"
            color: c("error", "#ffb4ab")
            font { family: root.font; pixelSize: root.height * 0.016 }
        }
    }

    function login() {
        var u = root.userName.length ? root.userName : userField.text
        sddm.login(u, password.text, root.sessionIndex)
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            password.text = ""
            errorText.visible = true
            shake.start()
            password.forceActiveFocus()
        }
    }

    // ---------- bottom bar: session + power ----------
    Text {
        anchors { left: parent.left; bottom: parent.bottom; margins: root.height * 0.03 }
        text: "  " + (sessionModel.data(sessionModel.index(root.sessionIndex, 0), Qt.UserRole + 4) || "Hyprland")
        color: c("onSurfaceVariant", "#cccccc")
        font { family: root.font; pixelSize: root.height * 0.017 }
        MouseArea {   // click to cycle sessions
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.sessionIndex = (root.sessionIndex + 1) % sessionModel.rowCount()
        }
    }

    Row {
        anchors { right: parent.right; bottom: parent.bottom; margins: root.height * 0.03 }
        spacing: root.height * 0.03
        Repeater {
            model: [
                { icon: "󰤄", label: "Suspend",   can: sddm.canSuspend,  act: function() { sddm.suspend() } },
                { icon: "󰜉", label: "Reboot",    can: sddm.canReboot,   act: function() { sddm.reboot() } },
                { icon: "󰐥", label: "Shut down", can: sddm.canPowerOff, act: function() { sddm.powerOff() } }
            ]
            delegate: Text {
                visible: modelData.can
                text: modelData.icon
                color: ma.containsMouse ? c("primary", "#b8c4ff") : c("onSurface", "#ffffff")
                font { family: root.font; pixelSize: root.height * 0.03 }
                Behavior on color { ColorAnimation { duration: 150 } }
                MouseArea { id: ma; anchors.fill: parent; hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor; onClicked: modelData.act() }
                ToolTip.visible: ma.containsMouse
                ToolTip.text: modelData.label
            }
        }
    }

    Component.onCompleted: (root.userName.length ? password : userField).forceActiveFocus()
}

import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

ShellRoot {
  id: root

  property string timeText: ""
  property string networkText: ""
  property string loadText: ""
  property string memoryText: ""
  property string batteryText: ""
  property string bluetoothText: ""
  property string mediaText: ""
  property string mediaArtUrl: ""
  property real mediaProgress: 0
  property bool mediaHasProgress: false
  readonly property bool showBattery: @showBattery@
  readonly property color foreground: "@foreground@"
  readonly property color background: "@background@"
  readonly property color accent: "@accent@"

  component BarText: Text {
    color: root.foreground
    font.family: "Cousine Nerd Font"
    font.pixelSize: 15
    verticalAlignment: Text.AlignVCenter
  }

  component Pill: Rectangle {
    property alias text: label.text
    property color pillColor: root.background
    property int maxWidth: 0
    implicitWidth: maxWidth > 0 ? Math.min(label.implicitWidth + 20, maxWidth) : label.implicitWidth + 20
    implicitHeight: 24
    radius: 8
    color: pillColor

    BarText {
      id: label
      anchors.centerIn: parent
      width: parent.width - 20
      elide: Text.ElideRight
    }
  }

  component MediaPill: Rectangle {
    id: mediaPill
    property string text: ""
    property string artUrl: ""
    property real progress: 0
    property bool hasProgress: false
    property int maxWidth: 360
    implicitWidth: Math.min(mediaLabel.implicitWidth + 42, maxWidth)
    implicitHeight: 24
    radius: 8
    color: root.background
    clip: true

    Rectangle {
      id: progressFill
      readonly property real progressRadius: Math.min(mediaPill.radius, height)
      anchors {
        top: parent.top
        left: parent.left
      }
      width: parent.width * Math.max(0, Math.min(mediaPill.progress, 1))
      color: root.accent
      height: 5
      radius: progressRadius
      opacity: 0.25
      visible: mediaPill.hasProgress

      Rectangle {
        anchors {
          left: parent.left
          right: parent.right
          bottom: parent.bottom
        }
        height: Math.min(parent.height / 2, parent.width)
        color: parent.color
      }

      Rectangle {
        anchors {
          top: parent.top
          right: parent.right
          bottom: parent.bottom
        }
        width: Math.min(parent.width, progressFill.progressRadius)
        color: parent.color
      }
    }

    Row {
      id: mediaRow
      anchors {
        left: parent.left
        right: parent.right
        verticalCenter: parent.verticalCenter
        leftMargin: 8
        rightMargin: 8
      }
      spacing: 6

      Item {
        width: 16
        height: 16
        anchors.verticalCenter: parent.verticalCenter

        Rectangle {
          anchors.fill: parent
          radius: 4
          color: "transparent"
          clip: true
          visible: mediaPill.artUrl.length > 0 && coverImage.status !== Image.Error

          Image {
            id: coverImage
            anchors.fill: parent
            source: mediaPill.artUrl
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: false
            smooth: true
            visible: parent.visible
          }
        }

        BarText {
          anchors.centerIn: parent
          text: ""
          visible: mediaPill.artUrl.length === 0 || coverImage.status === Image.Error
        }
      }

      BarText {
        id: mediaLabel
        width: Math.max(parent.width - 26, 0)
        text: mediaPill.text
        elide: Text.ElideRight
      }
    }

    MouseArea {
      anchors.fill: parent
      onClicked: playPauseProc.running = true
    }
  }

  Variants {
    model: Quickshell.screens

    PanelWindow {
      required property var modelData

      screen: modelData
      implicitHeight: 30
      exclusiveZone: 30
      color: "transparent"

      anchors {
        top: true
        left: true
        right: true
      }

      Rectangle {
        anchors.fill: parent
        color: "transparent"

        RowLayout {
          anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
            leftMargin: 8
            rightMargin: 8
          }

          spacing: 8

          Rectangle {
            Layout.alignment: Qt.AlignVCenter
            implicitWidth: workspaceRow.implicitWidth + 10
            implicitHeight: 24
            radius: 8
            color: root.background
            border.color: root.background
            border.width: 1

            Row {
              id: workspaceRow
              anchors.centerIn: parent
              spacing: 4

              Repeater {
                model: Hyprland.workspaces

                Rectangle {
                  id: workspaceButton

                  required property HyprlandWorkspace modelData

                  width: Math.max(workspaceLabel.implicitWidth + 16, 28)
                  height: 20
                  radius: 6
                  color: modelData.focused ? root.accent : "transparent"
                  opacity: modelData.id > 0 ? 1 : 0
                  visible: modelData.id > 0

                  BarText {
                    id: workspaceLabel
                    anchors.centerIn: parent
                    text: workspaceButton.modelData.name
                    color: workspaceButton.modelData.focused ? root.background : root.foreground
                  }

                  MouseArea {
                    anchors.fill: parent
                    onClicked: workspaceButton.modelData.activate()
                  }
                }
              }
            }
          }

          Item {
            Layout.fillWidth: true
          }

          Row {
            Layout.alignment: Qt.AlignVCenter
            spacing: 5

            MediaPill {
              visible: root.mediaText.length > 0
              text: root.mediaText
              artUrl: root.mediaArtUrl
              progress: root.mediaProgress
              hasProgress: root.mediaHasProgress
            }
            Pill { text: "  " + root.networkText }
            Pill { text: "  " + root.loadText }
            Pill { text: "  " + root.memoryText }
            Pill {
              visible: root.showBattery
              text: root.batteryText
            }
            Pill {
              visible: root.bluetoothText.length > 0
              text: " " + root.bluetoothText
            }
          }
        }

        Pill {
          anchors.centerIn: parent
          text: root.timeText
        }
      }
    }
  }

  Process {
    id: clockProc
    command: ["date", "+%I:%M %p"]
    running: true
    stdout: StdioCollector { onStreamFinished: root.timeText = this.text.trim() }
  }

  Process {
    id: networkProc
    command: ["sh", "-c", "ssid=$(nmcli -t -f ACTIVE,SSID dev wifi 2>/dev/null | awk -F: '$1 == \"yes\" {print $2; exit}'); if [ -n \"$ssid\" ]; then printf '%s' \"$ssid\"; else ip route get 1.1.1.1 2>/dev/null | awk '{for (i=1; i<=NF; i++) if ($i == \"dev\") {print $(i+1); exit}}'; fi"]
    running: true
    stdout: StdioCollector { onStreamFinished: root.networkText = this.text.trim() || "down" }
  }

  Process {
    id: loadProc
    command: ["sh", "-c", "cut -d ' ' -f1 /proc/loadavg"]
    running: true
    stdout: StdioCollector { onStreamFinished: root.loadText = this.text.trim() }
  }

  Process {
    id: memoryProc
    command: ["sh", "-c", "free | awk '/Mem:/ {printf \"%d%%\", $3 * 100 / $2}'"]
    running: true
    stdout: StdioCollector { onStreamFinished: root.memoryText = this.text.trim() }
  }

  Process {
    id: batteryProc
    command: ["sh", "-c", "@batteryCommand@"]
    running: root.showBattery
    stdout: StdioCollector { onStreamFinished: root.batteryText = this.text.trim() }
  }

  Process {
    id: bluetoothProc
    command: ["sh", "-c", "pactl list sinks 2>/dev/null | awk -v RS= '/bluez/ && /Description:/ { if (match($0, /Description:[ \\t]*([^\\n]*)/, m)) print m[1]; exit }'"]
    running: true
    stdout: StdioCollector { onStreamFinished: root.bluetoothText = this.text.trim() }
  }

  Process {
    id: mediaProc
    command: ["sh", "-c", "fmt='{{status}}|{{position}}|{{mpris:length}}|{{mpris:artUrl}}|{{artist}}|{{title}}'; metadata=$(playerctl -a metadata --format \"$fmt\" 2>/dev/null); if printf '%s\\n' \"$metadata\" | awk -F '|' '$1 == \"Playing\" && ($3 + 0) <= 0 { missing=1 } END { exit missing ? 0 : 1 }'; then playerctl pause 2>/dev/null; playerctl play 2>/dev/null; sleep 0.2; metadata=$(playerctl -a metadata --format \"$fmt\" 2>/dev/null); fi; printf '%s\\n' \"$metadata\" | awk -F '|' '$1 == \"Playing\" || $1 == \"Paused\" { if ($5 != \"\" && $6 != \"\") text=$5 \" - \" $6; else if ($6 != \"\") text=$6; else if ($5 != \"\") text=$5; progress=0; hasProgress=0; if (($2 + 0) >= 0 && ($3 + 0) > 0) { progress=($2 + 0) / ($3 + 0); hasProgress=1 } print $4 \"|\" progress \"|\" hasProgress \"|\" text; exit }'"]
    running: true
    stdout: StdioCollector {
      onStreamFinished: {
        const parts = this.text.trim().split("|");
        root.mediaArtUrl = parts.shift() || "";
        root.mediaProgress = Number(parts.shift() || 0);
        root.mediaHasProgress = (parts.shift() || "0") === "1";
        root.mediaText = parts.join("|");
      }
    }
  }

  Process {
    id: playPauseProc
    command: ["playerctl", "play-pause"]
  }

  Timer {
    interval: 1000
    running: true
    repeat: true
    onTriggered: {
      clockProc.running = true
      loadProc.running = true
      memoryProc.running = true
      if (root.showBattery) batteryProc.running = true
      mediaProc.running = true
    }
  }

  Timer {
    interval: 5000
    running: true
    repeat: true
    onTriggered: {
      networkProc.running = true
      bluetoothProc.running = true
    }
  }
}

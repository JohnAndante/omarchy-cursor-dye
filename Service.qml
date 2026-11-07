import QtQuick
import Quickshell
import Quickshell.Io

Item {
  id: root

  readonly property string installer: Qt.resolvedUrl("install.sh").toString().replace(/^file:\/\//, "")

  Process {
    id: installerProcess
    command: ["bash", root.installer]
  }

  Component.onCompleted: installerProcess.running = true
}

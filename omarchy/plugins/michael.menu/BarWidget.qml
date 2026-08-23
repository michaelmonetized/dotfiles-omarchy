import QtQuick
import Quickshell
import qs.Ui

BarWidget {
  id: root
  moduleName: "omarchy.menu"

  property string hostname: ""

  FileView {
    id: hostnameFile
    path: "/etc/hostname"
    watchChanges: false
    printErrors: false
    onLoaded: root.hostname = String(text() || "").trim()
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.setting("label", "󱁏 " + root.hostname)
    horizontalMargin: 12
    onPressed: function(button) {
      if (!root.bar) return
      if (button === Qt.RightButton) root.bar.run("xdg-terminal-exec")
      else root.bar.run("omarchy-shell shell toggle omarchy.menu '{\"menu\":\"root\"}'")
    }
  }
}

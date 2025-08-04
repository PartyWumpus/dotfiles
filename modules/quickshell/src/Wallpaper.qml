import Quickshell
import QtQuick
import QtQuick.Effects
import Quickshell.Wayland
import Quickshell.Widgets

PanelWindow {
  WlrLayershell.layer: WlrLayer.Bottom
  exclusionMode: ExclusionMode.Ignore
  color: Colors.crust

  anchors {
    left: true
    right: true
    bottom: true
    top:true
  }
  WrapperItem {
    anchors.fill: parent
    margin: 8
    topMargin: 20
    ClippingRectangle {
      id: clip
      radius: 8
      Image {
        source: "./icons/wallpaper.png"
        height: 1080
        width: 1920
        fillMode: Image.PreserveAspectCrop
      }

      MultiEffect {
        source: clip
        anchors.fill: clip 
        shadowBlur: 1.0
        shadowEnabled: true
        shadowColor: "black"
        shadowVerticalOffset: 15
        shadowHorizontalOffset: 11
      }
    }
  }
}

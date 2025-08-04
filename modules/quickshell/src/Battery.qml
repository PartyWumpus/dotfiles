import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower

RowLayout {
  id: root
  spacing: 2
  readonly property bool isCharging: {
    const { state } = UPower.displayDevice
    state === UPowerDeviceState.FullyCharged ||
    state === UPowerDeviceState.Charging
  }
  StyledText {
    id: text
    text: {
      const device = UPower.displayDevice
      const time = root.isCharging ? device.timeToFull : device.timeToEmpty
      const mins = String(Math.round(time / 60 % 60))
      const hours = Math.round(time / 60 / 60)
      return `${hours}:${mins.padStart(2, "0")}`
    }
  }

  ProgressWheel {
    implicitWidth: 18
    implicitHeight: 18

    emptyColor: Colors.surface2 
    fillColor: {
      if (!isCharging && UPower.displayDevice.percentage < 0.2) {
        Colors.red
      } else if (!isCharging && UPower.displayDevice.percentage < 0.4) {
        Colors.yellow
      } else {
        Colors.mauve
      }
    }

    currentValue: UPower.displayDevice.energy
    maximumValue: UPower.displayDevice.energyCapacity
    // TODO: figure out proper filepath stuff
    icon: {
      if (root.isCharging) {
        "icons/battery-charging.svg"
      } else {
        "icons/battery-discharging.svg"
      }
    }

  }
}

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Services.UPower

Item {
    id: root
    implicitHeight: layout.implicitHeight
    implicitWidth: layout.implicitWidth
    readonly property bool isCharging: {
        const {
            state
        } = UPower.displayDevice;
        state === UPowerDeviceState.FullyCharged || state === UPowerDeviceState.Charging;
    }
    readonly property UPowerDevice device: UPower.displayDevice

    MouseArea {
        id: area
        anchors.fill: parent

        hoverEnabled: true
        ToolTip {
            visible: area.containsMouse
            text: `${root.isCharging ? "Gaining" : "Using"}: ${Math.round(root.device.changeRate * 10) / 10}W (${Math.round(root.device.percentage * 100)}%)`
        }
    }

    RowLayout {
        id: layout
        spacing: 2

        StyledText {
            text: {
                const time = root.isCharging ? device.timeToFull : device.timeToEmpty;
                const mins = String(Math.round(time / 60 % 60));
                const hours = Math.round(time / 60 / 60);
                return `${hours}:${mins.padStart(2, "0")}`;
            }
        }

        ProgressWheel {
            implicitWidth: 18
            implicitHeight: 18

            emptyColor: Colors.surface2
            fillColor: {
                if (!isCharging && UPower.displayDevice.percentage < 0.2) {
                    Colors.red;
                } else if (!isCharging && UPower.displayDevice.percentage < 0.4) {
                    Colors.yellow;
                } else {
                    Colors.mauve;
                }
            }

            currentValue: UPower.displayDevice.energy
            maximumValue: UPower.displayDevice.energyCapacity
            // TODO: figure out proper filepath stuff
            icon: {
                if (root.isCharging) {
                    "icons/battery-charging.svg";
                } else {
                    "icons/battery-discharging.svg";
                }
            }
        }
    }
}

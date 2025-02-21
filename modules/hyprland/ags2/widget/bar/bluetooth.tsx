import { bind } from "astal"
import { Gtk } from "astal/gtk3"
import Bluetooth from "gi://AstalBluetooth"

const bluetooth = Bluetooth.get_default()

const transition_duration = 750

function BluetoothDevice(device: Bluetooth.Device) {

  return <revealer
    transitionType={Gtk.RevealerTransitionType.SLIDE_RIGHT}
    transitionDuration={transition_duration}
    revealChild={bind(device, "connected")}
  >
    <box
      tooltipText={bind(device, "batteryPercentage").as(p => `${device.alias}\nBattery: ${Math.floor(p * 100)}%`)}
      css="padding:1px;">
      <circularprogress
        className="progressWheel"
        startAt={0.75}
        endAt={0.75}
        value={bind(device, "batteryPercentage").as(p => p)}
      >
      <icon icon={"bluetooth-symbolic"} />
      </circularprogress>
    </box>
  </revealer>

}

export default function BluetoothInfo() {
  let devices = Object.fromEntries(bluetooth.devices.map(d => [d.address, BluetoothDevice(d)]))

  return <box
    className={"bluetoothInfo"}
    setup={(self => {
      self.children = [...Object.values(devices)]

      self.hook(bluetooth, "device-added", (_, device: Bluetooth.Device) => {
        const widget = BluetoothDevice(device)
        devices[device.address] = widget
        self.pack_end(widget, true, true, 0)
        self.show_all()
      })

      self.hook(bluetooth, "device-removed", (_, device: Bluetooth.Device) => {
        const widget = devices[device.address]
        widget.revealChild = false
        setTimeout(() => {
          widget.destroy()
          delete devices[device.address]
        }, transition_duration * 1.2)
      })
    })}
  />
}

import { App, Astal, Gdk, Gtk, Widget } from "astal/gtk3"

import Time from "./widgets/time"
import Workspaces from "./widgets/workspaces"
import BatteryInfo from "./widgets/battery"
import VolumeInfo from "./widgets/volume"
import BluetoothInfo from "./widgets/bluetooth"
import MediaInfo from "./widgets/mpris"
import CpuInfo from "./widgets/cpu"
import RecordingIndicator from "./widgets/recording"

// <icon icon={GLib.get_os_info("LOGO") ?? "missing-symbolic"}/>

export default function Bar(gdkmonitor: Gdk.Monitor) {
  const { TOP, LEFT, RIGHT } = Astal.WindowAnchor

  const windowheight = 18

  return <window
    namespace={"ags-bar"}
    className="Bar"
    gdkmonitor={gdkmonitor}
    heightRequest={windowheight}
    setup={
      (win) => {
        setInterval(() => {
          const size = win.get_size()
          if (size[1] != windowheight) {
            console.error(`height ${size[1]} is not ${windowheight}px!`)
          }
        }, 2000)
      }
    }
    exclusivity={Astal.Exclusivity.EXCLUSIVE}
    anchor={TOP | LEFT | RIGHT}
    application={App}>
    <centerbox>
      <box halign={Gtk.Align.START}>
        <Workspaces />
      </box>
      <box className={"infoZone"} halign={Gtk.Align.CENTER} hexpand>
        <CpuInfo />
        <Gtk.Separator visible orientation={Gtk.Orientation.VERTICAL} />
        <BluetoothInfo />
        <Gtk.Separator visible orientation={Gtk.Orientation.VERTICAL} />
        <VolumeInfo />
        <MediaInfo />
      </box>
      <box halign={Gtk.Align.END}>
        <RecordingIndicator />
        <BatteryInfo />
        <Gtk.Separator visible orientation={Gtk.Orientation.VERTICAL} />
        <Time />
      </box>
    </centerbox>
  </window>
}


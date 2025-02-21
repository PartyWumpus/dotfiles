import { App, Astal, Gtk, Gdk, Widget } from "astal/gtk3"

import Time from "./bar/time"
import Workspaces from "./bar/workspaces"
import BatteryInfo from "./bar/battery"
import VolumeInfo from "./bar/volume"
import BluetoothInfo from "./bar/bluetooth"
import MediaInfo from "./bar/mpris"
import CpuInfo from "./bar/cpu"

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
        setTimeout(() => {
          const size = win.get_size()
          if (size[1] != windowheight) {
            print(`height ${size[1]} is not ${windowheight}px!`)
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
      <box className={"infoZone"} halign={Gtk.Align.CENTER} hexpand={true}>
        <CpuInfo />
        <label>{"|"}</label>
        <BluetoothInfo />
        <label>{"|"}</label>
        <VolumeInfo />
        <MediaInfo />
      </box>
      <box halign={Gtk.Align.END}>
        <BatteryInfo />
        <label>{" | "}</label>
        <Time />
      </box>
    </centerbox>
  </window>
}


import { Astal, Gdk, App } from "astal/gtk3"
import Brightness from "../lib/brightness"
import Wp from "gi://AstalWp"

export default function Popovers(gdkmonitor: Gdk.Monitor) {
  const { TOP } = Astal.WindowAnchor

  return <window
    namespace={"ags-bar"}
    className="Popovers"
    gdkmonitor={gdkmonitor}
    exclusivity={Astal.Exclusivity.NORMAL}
    anchor={TOP}
    application={App}
  >
  <box>//todo popovers</box>
  </window>
}

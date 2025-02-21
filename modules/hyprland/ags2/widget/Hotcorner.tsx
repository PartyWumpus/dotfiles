import { Astal, Gdk, Gtk, App } from "astal/gtk3"
import Brightness from "../lib/brightness"
import Wp from "gi://AstalWp"
import { bind, execAsync, GLib } from "astal"
import { nix } from "../lib/nix"
import { Icon } from "astal/gtk3/widget"

function Controls() {
  return <box halign={Gtk.Align.CENTER}>
    <button onClick={() => execAsync(nix.wifi_menu)}></button>
    <button onClick={() => execAsync(nix.bluetooth_menu)}></button>
    <button onClick={() => execAsync("wlogout")}></button>
  </box>
}

function AudioInputPicker() {
  const audio = Wp.get_default()?.audio!
  return <box halign={Gtk.Align.CENTER}>
    {bind(audio, "speakers").as(ds => ds.map(d =>
      <button
        tooltipText={`${d.description}`}
        onClick={() => d.set_is_default(true)}
      >
        <icon icon={Icon.lookup_icon(d.icon) ? d.icon : "audio-x-generic"} />
      </button>
    ))}
  </box>
}

// TODO:
function ExtraInfo() {
  return <box halign={Gtk.Align.CENTER}>
    <button></button>
    <button></button>
    <button></button>
  </box>
}

export default function Hotcorner(gdkmonitor: Gdk.Monitor) {
  const { TOP, RIGHT } = Astal.WindowAnchor
  let hover = false
  let hoverTimeout: GLib.Source | undefined = undefined

  return <window
    layer={3}
    className="Hotcorner"
    // TODO: consider IGNORE
    exclusivity={Astal.Exclusivity.IGNORE}
    anchor={TOP | RIGHT}
    application={App}
    name={"hotcorner"}
    namespace={"ags-bar"}
  >
    <eventbox
    onHover={(self) => {
      hover = true
    }}
    onHoverLost={(self) => {
      hover = false
      if (hoverTimeout) {
        clearTimeout(hoverTimeout)
      }

      hoverTimeout = setTimeout(() => {
        if (hover === false) {
          globalThis?.disableHotcorner?.()
        }
      }, 250)
    }}
    >
      <revealer
        revealChild={false}
        transitionType={Gtk.RevealerTransitionType.SLIDE_DOWN}
        transitionDuration={100}
        setup={(self) => {
          globalThis.enableHotcorner = () => {
            self.revealChild = true
            hover = true
          }
          globalThis.disableHotcorner = () => {
            self.revealChild = false
          }
        }}
      >
        <box vertical={true} className={"container"}>
          <Controls />
          <AudioInputPicker />
        </box>
      </revealer>
    </eventbox>
  </window>
}

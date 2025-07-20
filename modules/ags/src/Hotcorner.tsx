import { App, Astal, Gdk, Gtk } from "astal/gtk3"
import Wp from "gi://AstalWp"
import Bluetooth from "gi://AstalBluetooth"
import { bind, execAsync, GLib, Variable } from "astal"
import { audioFormFactor, nix } from "../lib/nix"
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
  return <box halign={Gtk.Align.CENTER} className={"audioPicker"} visible={bind(audio, "speakers").as(ds => ds.length > 1)}>
    {bind(audio, "speakers").as(ds => ds.map(d =>
      <button
        className={bind(d, "isDefault").as(s => s ? "selected" : "")}
        tooltipText={`${d.description}`}
        onClick={() => d.set_is_default(true)}
      >
        <icon icon={bind(d, "icon").as(() => {
          if (d.icon && Icon.lookup_icon(d.icon)) {
            return d.icon
          } else {
            console.warn(`icon '${d.icon}' for audio device '${d.description}' not found`)
            switch (d.device.formFactor as audioFormFactor) {
              case "headphone":
              case "headset":
                return "audio-headphones";
              case "webcam":
              case "handset":
              case "hands-free":
              case "portable":
                return "audio-handsfree";
              default:
                return "audio-speakers";
            }
          }
        })} />
      </button>
    ))}
  </box>
}

// TODO: astal does not contain any way of getting a list of available networks atm
function NetworkPicker() {
}


function BluetoothPicker() {
  const blue = Bluetooth.get_default()
  return <box halign={Gtk.Align.CENTER} className={"bluetoothPicker"}>
    {bind(blue, "devices").as(ds => ds.filter(d => d.trusted).map(d => {
      // note that filter is technically invalid but trusted device list doesn't change often so shrug_emoji
      const d_status: Variable<"connected" | "disconnecting" | "connecting" | ""> = Variable.derive([bind(d, "connected"), bind(d, "connecting")], (connected, connecting) => {
        if (connected) {
          return "connected"
        }
        if (connecting) {
          return "connecting"
        }
        return ""
      })

      return <button
        className={d_status()}
        tooltipText={`${d.name}`}
        onClick={() => {
          if (d.connected) {
            d_status.set("disconnecting")
            // Workaround for https://github.com/Aylur/astal/issues/137
            setTimeout(() => d.disconnect_device(() => { }), 100)
          } else {
            d.connect_device(() => { })
          }
        }}
      >
        <icon icon={bind(d, "icon").as(() => {
          if (d.icon && Icon.lookup_icon(d.icon)) {
            return d.icon
          } else {
            console.warn(`icon '${d.icon}' for audio device '${d.name}' not found`)
            return "bluetooth-active"
          }
        })} />
      </button>
    }
    ))}
  </box>
}


export default function Hotcorner(gdkmonitor: Gdk.Monitor) {
  const { TOP, RIGHT } = Astal.WindowAnchor
  let hover = false
  let hoverTimeout: GLib.Source | undefined = undefined
  const visible = Variable(false)

  return <window
    className="Hotcorner"
    // TODO: consider IGNORE
    exclusivity={Astal.Exclusivity.IGNORE}
    anchor={TOP | RIGHT}
    application={App}
    name={"hotcorner"}
    namespace={"ags-bar"}
  >
    <eventbox
      heightRequest={10}
      onHover={(self, ev) => {
        visible.set(true)
        hover = true
      }}
      onHoverLost={(self) => {
        hover = false
        if (hoverTimeout) {
          clearTimeout(hoverTimeout)
        }

        hoverTimeout = setTimeout(() => {
          if (hover === false) {
            visible.set(false)
          }
        }, 300)
      }}
    >
      <revealer
        revealChild={visible()}
        transitionType={Gtk.RevealerTransitionType.SLIDE_DOWN}
        transitionDuration={100}
      >
        <box vertical className={"container"}>
          <Controls />
          <Gtk.Separator visible orientation={Gtk.Orientation.HORIZONTAL} />
          <AudioInputPicker />
          <Gtk.Separator visible orientation={Gtk.Orientation.HORIZONTAL} />
          <BluetoothPicker />
        </box>
      </revealer>
    </eventbox>
  </window>
}

import { monitorFile, Variable, Gio, GLib } from "astal";


export default function RecordingIndicator() {
  const recording = Variable(false);
  monitorFile(`${GLib.getenv("HOME")}/.recording`, async (f, ev) => {
    if (ev === Gio.FileMonitorEvent.DELETED) {
      recording.set(false)
    } else if (ev === Gio.FileMonitorEvent.CREATED) {
      recording.set(true)
    }
  })

  return <label css="color:red" tooltipText={"recording"}>{recording().as(r => r ? "🔴" : null)}</label>
}

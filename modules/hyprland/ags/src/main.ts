import Gdk from "gi://Gdk";
import type Gtk from "gi://Gtk";

import { AppLauncher } from "applauncher";
import { Bar } from "bar";
import { Clipboard } from "menus/clipboard";
import { Popovers } from "menus/popovers";
import { SinkPicker } from "menus/sink_picker";
import { NotificationPopups } from "notifications";

const range = (length: number, start = 0) =>
  Array.from({ length }, (_, i) => i + start);
function forMonitors(widget: (monitor: number) => Gtk.Window) {
  const n = Gdk.Display.get_default()?.get_n_monitors() || 1;
  return range(n, 0).map(widget).flat(1);
}
function forMonitorsAsync(widget: (monitor: number) => Promise<Gtk.Window>) {
  const n = Gdk.Display.get_default()?.get_n_monitors() || 1;
  return range(n, 0).forEach((n) => widget(n).catch(print));
}

App.config({
  windows: [
    forMonitors(Bar),
    AppLauncher,
    forMonitors(NotificationPopups),
    Popovers,
    Clipboard,
    SinkPicker,
  ].flat(1),
});

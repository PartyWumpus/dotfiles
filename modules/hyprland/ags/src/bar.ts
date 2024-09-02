// TODO:
// use svg icon thingies instead of just nerd font icons
// add bluetooth thingy next to volume if using bluetooth headphones
// make the notifications betterer, have them pop up for a bit
// 	then go into a side menu or similar
// figure out why the media wobbles a bit when sliding in
// make media disappear if its just chrome doing nothing
// deduplicate some code in places: popup menu list, button
// make popovers look better
// add better indication of currently active monitor on the bar maybe?
//
// TODO: agsify:
// power menu
// wifi
// bluetoth
//
// TODO: ADD:
// investigate GSconnect :o
import * as COLOR from "colours.json";
import { nix } from "nix";
import { getMonitorID, sleep } from "utils";

import GLib from "gi://GLib";
import Gdk from "gi://Gdk";
import Gio from "gi://Gio";
import Gtk from "gi://Gtk";

import { InfoBars } from "bar/bars";
import { BatteryWheel } from "bar/battery";
import { BluetoothWheels } from "bar/bluetooth";
import { DateComponent } from "bar/date";
import { Media } from "bar/media";
import { FocusedTitle } from "bar/title";
import { VolumeWheel } from "bar/volume";
import { Workspaces } from "bar/workspaces";
import { newAspectFrame as AspectFrame } from "widgets/AspectFrame";

App.applyCss(`
window {
	font-size: 10px;
	font-family: rubik;
	color: ${COLOR.Text};
}`);

/*
const uptime = Variable(0, {
  poll: [
    5000,
    "cat /proc/uptime",
    (data) => {
      // second number is total core idle time
      const uptime = Number(data.split(" ")[0]);
      return uptime;
    },
  ],
});
*/

/*
const bars = Variable([...Array(128).keys()], {
  listen: [
    ["cava", "-p", "/home/wumpus/cava_raw"],
    (data) => {
      const barsData = data.split(";").map((x) => Number(x));
      barsData.pop(); //last value is always "" => 0
      return barsData;
    },
  ],
});
*/

const Container = (children) =>
  Widget.Box({
    className: "container",
    css: `
	background-color:${COLOR.Surface0};
	background-color:rgba(54, 58, 79,0.8);
	border-radius:15px;
	padding:3px;
	padding-left:5px;
	padding-right:5px;
	margin:1px;`,
    children: children,
  });

App.applyCss(`
.side-button {
	font-size:18px;
	margin:2px;
}
.side-button button {
	background-color:${COLOR.Surface2};
	color:${COLOR.Highlight};
}
`);

App.applyCss(`
.cava-bar * {
	all:unset;
	min-width:0.1px;
}

.cava-bar block.filled {
	min-width:0.1px;
	background-color: ${COLOR.Highlight};
}
`);

const TextView = Widget.subclass(Gtk.TextView);

export const Bar = (monitor: Gdk.Monitor) =>
  Widget.Window({
    gdkmonitor: monitor,
    name: `ags-bar-${getMonitorID(monitor)}`,
    anchor: ["top", "left", "right"],
    exclusivity: "exclusive",
    margins: [1, 7, 3, 7],
    // base
    //css: `background-color: rgba(36, 39, 58, 0.7);border-radius:15px;`,
    css: `background-color: transparent;`,
    child: Widget.CenterBox({
      start_widget: Widget.Box({
        css: "padding-left:9px;padding-top:10px;font-size:12px;",
        child: FocusedTitle(),
      }),

      center_widget: Widget.Box({
        children: [
          Container([Workspaces(monitor)]),
          Container([DateComponent(), InfoBars(), BatteryWheel(), BluetoothWheels()]),
          Container([VolumeWheel()]),
          Media(),
          /*Container([
            Widget.Box({
              children: [...Array(128).keys()].map((x) =>
                Widget.LevelBar({
                  inverted: true,
                  value: x / 64,
                  className: "cava-bar",
                  vertical: true,
                }),
              ),
              setup: (self) => {
                self.hook(bars, (self) => {
                  for (let i = 0; i < self.children.length; i++) {
                    self.children[i].value = bars.value[i] / 1000;
                  }
                });
              },
            }),
          ]),*/
        ],
      }),

      end_widget: Widget.Box({
        hpack: "end",
        children: [
          Container([
            AspectFrame({
              ratio: 1,
              className: "side-button flat",
              child: Widget.Button({
                className: "circular",
                label: "",
                onClicked: () => Utils.execAsync(nix.wifi_menu),
              }),
            }),
            AspectFrame({
              ratio: 1,
              className: "side-button flat",
              child: Widget.Button({
                className: "circular",
                label: "",
                //label: bluetooth.bind("enabled").as((x) => (x ? "" : "󰂲")),
                onClicked: () => Utils.execAsync(nix.bluetooth_menu),
              }),
            }),
            AspectFrame({
              ratio: 1,
              className: "side-button flat",
              child: Widget.Button({
                className: "circular",
                //onClicked: () => Utils.execAsync(nix.show_clipboard),
                onClicked: () => App.openWindow("clipboard"),
                label: "󱉫",
              }),
            }),
            AspectFrame({
              ratio: 1,
              className: "side-button flat",
              child: Widget.Button({
                className: "circular",
                label: "",
                onClicked: () => Utils.execAsync("wlogout"),
              }),
            }),

            /*Widget.Button({
              css: `font-size:20px;margin:2px;background-color:${COLOR.Surface1};color:${COLOR.Highlight};`,
              label: " 󰍜 ",
              setup: (self) => {
                let dropdown = Widget.Menu({
                  sensitive: false,
                  canFocus: false,
                  canDefault: false,
                  children: [
                    Widget.MenuItem({
                      child: dotsMenu(),
                    }),
                  ],
                });

                self.on_primary_click = () => {
                  let popover = Gtk.Popover.new(self);
                  popover.show();
                  popover.child = dotsMenu();
                };

                //self.on_primary_click = (_, event) => dropdown.popup_at_pointer(event);
                //self.on_primary_click = (_, event) => dropdown.popup_at_widget(self,Gdk.Gravity.SOUTH_EAST,Gdk.Gravity.WEST, event);
              },
            }),*/
          ]),
        ],
      }),
    }),
  });

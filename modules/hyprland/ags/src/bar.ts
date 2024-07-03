// TODO:
// use svg icon thingies instead of just nerd font icons
// make clipboard ui with ags
// make audio device selector with ags
// indicate charging or not on battery wheel tooltip
// make volume icon be icon of headphone vs speaker vs bluetooth
// make the notifications betterer
// TO ADD:
// in dropdown menu put bluetooth, wifi, other info

import Gtk from "gi://Gtk";

import * as COLOR from "../colours.json";
import { nix } from "./nix";

import { FocusedTitle } from "./bar/title";
import { Workspaces } from "./bar/workspaces";
import { BatteryWheel } from "./bar/battery";
import { InfoBars } from "./bar/ram";
import { VolumeWheel } from "./bar/volume";
import { Date } from "./bar/date";

App.applyCss(`
window {
	font-size: 10px;
	font-family: rubik;
}
`);

export const dropdownMenu = Widget.Window({
  visible: false,
  name: `dropdown-menu`,
  anchor: ["top", "right"],
  margin: 5,
  css: "border-radius:5px;border: 1px rgba(255,255,255,0.3) solid",
  child: Widget.Box({
    css: "padding:5px;min-height:125px;",
    child: Widget.Label("TODO: make this menu have stuff in"),
  }),
});

const Container = (children) =>
  Widget.Box({
    css: `
	background-color:${COLOR.Surface0};
	background-color:rgba(54, 58, 79,0.85);
	border-radius:15px;
	padding:3px;
	padding-left:5px;
	padding-right:5px;
	margin:1px;`,
    children: children,
  });

export const Bar = (monitor: number) =>
  Widget.Window({
    monitor,
    name: `bar-${monitor}`,
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
          Container([Workspaces()]),
          Container([Date(), InfoBars(), BatteryWheel()]),
          Container([VolumeWheel()]),
        ],
      }),

      end_widget: Widget.Box({
        hpack: "end",
        css: "padding-right:12px;",
        children: [
          Container([
            Widget.Button({
              css: `font-size:20px;margin:2px;background-color:${COLOR.Surface1};color:${COLOR.Highlight};`,
              onPrimaryClick: () => Utils.execAsync(nix.show_clipboard),
              label: " 󱉫 ",
            }),
            Widget.Button({
              css: `font-size:20px;margin:2px;background-color:${COLOR.Surface1};color:${COLOR.Highlight};`,
              onPrimaryClick: () => App.toggleWindow("dropdown-menu"),
              label: " 󰍜 ",
            }),
          ]),
        ],
      }),
    }),
  });

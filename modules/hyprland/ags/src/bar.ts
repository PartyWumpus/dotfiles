// TODO:
// use svg icon thingies instead of just nerd font icons
// make clipboard ui with ags
// make wifi ui with ags? might be too hard.
// make audio device selector with ags
// indicate charging or not on battery wheel tooltip
// add bluetooth thingy next to volume
// make the notifications betterer
// make the changing of songs in the audio player work better, currently it looks jank,
// 	probably just keep the old icon until the new one loads? <- doesn't look possible >:(
//
// TODO: ADD:
// power menu button with hibernate option
// in dropdown menu put other stuff
// investigate GSconnect :o

import * as COLOR from "../colours.json";
import { nix } from "./nix";

import { FocusedTitle } from "./bar/title";
import { Workspaces } from "./bar/workspaces";
import { BatteryWheel } from "./bar/battery";
import { InfoBars } from "./bar/ram";
import { VolumeWheel } from "./bar/volume";
import { Date } from "./bar/date";
import { BluetoothWheels } from "./bar/bluetooth";

//

import { MprisPlayer } from "types/service/mpris";

App.applyCss(`
window {
	font-size: 10px;
	font-family: rubik;
}
`);

App.applyCss(`
.player {
  padding: 10px;
  min-width: 350px;
	background-color: #363a4f;
	border-radius: 15px;
	margin:3px;
}

.player .img {
    min-width: 100px;
    min-height: 100px;
    background-size: cover;
    background-position: center;
    border-radius: 13px;
    margin-right: 1em;
}

.player .title {
    font-size: 1.2em;
}

.player .artist {
    font-size: 1.1em;
    color: @insensitive_fg_color;
}

.player scale {
	background-color: transparent;
}

.player scale trough {
background-color: #5b6078;
border-radius: 15px;
}

.player scale.position {
    padding: 0;
    margin-bottom: .3em;
}

.player scale.position trough {
    min-height: 8px;
}

.player scale.position highlight {
    background-color: @theme_fg_color;
		border-radius: 15px;
}

.player scale.position slider {
    all: unset;
}

.player button {
    min-height: 1em;
    min-width: 1em;
    padding: .3em;
}

.player button.play-pause {
    margin: 0 .3em;
}


.dropdown {

}

popover {
	min-height: 2px;
	min-width: 2px;
}
`);

const mpris = await Service.import("mpris");
const players = mpris.bind("players");

const FALLBACK_ICON = "audio-x-generic-symbolic";
const PLAY_ICON = "media-playback-start-symbolic";
const PAUSE_ICON = "media-playback-pause-symbolic";
const PREV_ICON = "media-skip-backward-symbolic";
const NEXT_ICON = "media-skip-forward-symbolic";
//const SHUFFLE_ENABLE_ICON = "media-playlist-shuffle-symbolic";
//const SHUFFLE_DISABLE_ICON = "media-playlist-no-shuffle-symbolic";

function lengthStr(length: number) {
  if (length <= 0) {
    return `-:--`;
  }
  const min = Math.floor(length / 60);
  const sec = Math.floor(length % 60);
  const sec0 = sec < 10 ? "0" : "";
  return `${min}:${sec0}${sec}`;
}

function Player(player: MprisPlayer) {
  const img = Widget.Box({
    class_name: "img",
    vpack: "start",
    css: player.bind("cover_path").as(
      (p) => `
            background-image: url('${p}');
        `,
    ),
  });

  const title = Widget.Label({
    class_name: "title",
    wrap: true,
    hpack: "start",
    label: player.bind("track_title"),
  });

  const artist = Widget.Label({
    class_name: "artist",
    wrap: true,
    hpack: "start",
    label: player.bind("track_artists").transform((a) => a.join(", ")),
  });

  const positionSlider = Widget.Slider({
    class_name: "position",
    draw_value: false,
    on_change: ({ value }) => (player.position = value * player.length),
    setup: (self) => {
      function update() {
        if (player.length <= 0) {
          self.value = 1;
        } else {
          const value = player.position / player.length;
          self.value = value > 0 ? value : 0;
        }
      }
      self.hook(player, update);
      self.hook(player, update, "position");
      self.poll(1000, update);
    },
  }) as unknown as Gtk.Widget;

  const positionLabel = Widget.Label({
    class_name: "position",
    hpack: "start",
    setup: (self) => {
      const update = (_: any, time: number) => {
        self.label = lengthStr(time || player.position);
      };

      self.hook(player, update, "position");
      self.poll(1000, update);
    },
  });

  const lengthLabel = Widget.Label({
    class_name: "length",
    hpack: "end",
    label: player.bind("length").transform(lengthStr),
  });

  const icon = Widget.Icon({
    class_name: "icon",
    hexpand: true,
    hpack: "end",
    vpack: "start",
    tooltip_text: player.identity || "",
    icon: player.bind("entry").transform((entry) => {
      const name = `${entry}-symbolic`;
      return Utils.lookUpIcon(name) ? name : FALLBACK_ICON;
    }),
  });

  const playPause = Widget.Button({
    class_name: "play-pause",
    on_clicked: () => player.playPause(),
    sensitive: player.bind("can_play"),
    child: Widget.Icon({
      icon: player.bind("play_back_status").transform((s) => {
        switch (s) {
          case "Playing":
            return PAUSE_ICON;
          case "Paused":
          case "Stopped":
            return PLAY_ICON;
        }
      }),
    }),
  });

  const prev = Widget.Button({
    on_clicked: () => player.previous(),
    sensitive: player.bind("can_go_prev"),
    child: Widget.Icon(PREV_ICON),
  });

  const next = Widget.Button({
    on_clicked: () => player.next(),
    sensitive: player.bind("can_go_next"),
    child: Widget.Icon(NEXT_ICON),
  });

  // shuffle button is buggy af, totally unusable
  // not my fault :(
  /*
  const shuffle = Widget.Button({
    on_clicked: () => player.shuffle(),
    //visible: player.bind("shuffle_status").as(x => {console.log(x);return(x != null)}),
    child: Widget.Icon({
			icon: player.bind("shuffle_status").as(shuffle_active => {
				console.log(shuffle_active);
				if (shuffle_active) {
					return SHUFFLE_DISABLE_ICON
				} else {
					return SHUFFLE_ENABLE_ICON
				}
			})
		}),
  });
	*/

  return Widget.Box(
    { class_name: "player" },
    img,
    Widget.Box(
      {
        vertical: true,
        hexpand: true,
      },
      Widget.Box([title, icon]),
      artist,
      Widget.Box({ vexpand: true }),
      positionSlider,
      Widget.CenterBox({
        start_widget: positionLabel,
        center_widget: Widget.Box([prev, playPause, next]),
        end_widget: lengthLabel,
      }),
    ),
  );
}

export function Media() {
  return Widget.Box({
    vertical: true,
    css: "min-height: 2px; min-width: 2px;", // small hack to make it visible
    visible: players.as((p) => p.length > 0),
    children: players.as((p) => p.map(Player)),
  });
}

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

const bluetooth = await Service.import("bluetooth");

const dotsMenu = () =>
  Widget.EventBox({
    sensitive: true,
    child: Widget.Box({
      className: "dropdown",
      css: "padding:5px;min-height:125px;",
      vertical: true,
      children: [
        Widget.Box({
          children: [
            Widget.Label({
              hexpand: true,
              hpack: "start",
              label: uptime.bind().as((uptime) => {
                if (uptime >= 60 * 60 * 24) {
                  return `Uptime: ${Math.floor(uptime / 60 / 60 / 24)}d ${Math.floor((uptime / 60 / 60) % 24)}h ${Math.floor((uptime / 60) % 60)}m`;
                } else {
                  return `Uptime: ${Math.floor((uptime / 60 / 60) % 24)}h ${Math.floor((uptime / 60) % 60)}m`;
                }
              }),
            }),
            Widget.Button({
              child: Widget.Label(""),
              onClicked: () => Utils.execAsync("wlogout"),
              hpack: "end",
              css: "margin-right:6px;",
            }),
          ],
        }),
        Media(),
        Widget.Box({
          children: [
            Widget.Button({
              child: Widget.Label(""),
              onClicked: () => Utils.execAsync(nix.wifi_menu),
            }),
            Widget.Button({
              child: Widget.Label({
                label: bluetooth.bind("enabled").as((x) => (x ? "󰂯" : "󰂲")),
              }),
              onClicked: () => Utils.execAsync(nix.bluetooth_menu),
            }),
            Widget.Button({
              child: Widget.Label("󱉫"),
              onClicked: () => Utils.execAsync(nix.show_clipboard),
            }),
          ],
        }),
      ],
    }),
  });

import Gtk from "gi://Gtk";

const Popover = Widget.subclass(Gtk.Popover);

export const dropdownMenu = Widget.Window({
  visible: false,
  name: `dropdown-menu`,
  anchor: ["top", "right"],
  margin: 5,
  css: "border-radius:15px;border: 1px rgba(255,255,255,0.3) solid",
  child: dotsMenu(),
});

const Container = (children) =>
  Widget.Box({
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
          Container([Date(), InfoBars(), BatteryWheel(), BluetoothWheels()]),
          Container([VolumeWheel()]),
        ],
      }),

      end_widget: Widget.Box({
        hpack: "end",
        css: "padding-right:12px;",
        children: [
          Container([
            /*Widget.Button({
              css: `font-size:20px;margin:2px;background-color:${COLOR.Surface1};color:${COLOR.Highlight};`,
              onPrimaryClick: () => Utils.execAsync(nix.show_clipboard),
              label: " 󱉫 ",
            }),*/
            Widget.Button({
              css: `font-size:20px;margin:2px;background-color:${COLOR.Surface1};color:${COLOR.Highlight};`,
              onClicked: () => App.toggleWindow("dropdown-menu"),
              label: " 󰍜 ",
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

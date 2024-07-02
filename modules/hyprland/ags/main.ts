// TODO:
// make height constant properly
// make the selected window title have a max length before truncation or something
// find a nice rounded font
// use svg icon thingies instead of just nerd font icons
// make clipboard ui with ags
// TO ADD:
// volume indicator
// tooltips EVERYWHERE with info (exact values, wifi name + ip address for networking, calendar, etc)

interface nix {
  bun: string;
  show_clipboard: string;
}
const nixData: nix = JSON.parse(
  Utils.readFile(`/home/${Utils.USER}/.local/share/ags/nix.json`),
);

import * as COLOR from "./colours.json";

const hyprland = await Service.import("hyprland");

const focusedTitle = () =>
  Widget.Box({
    vertical: true,
    children: [
      Widget.Label({
        hpack: "start",
        label: hyprland.active.client.bind("title"),
      }),
      Widget.Label({
        hpack: "start",
        css: "opacity: 0.6",
        label: hyprland.active.client.bind("class"),
        visible: hyprland.active
          .bind("client")
          .as((x) => !(x.title === x.class)),
      }),
    ],
    visible: hyprland.active.client.bind("address").as((addr) => Boolean(addr)),
  });

const dispatch = (ws: number) =>
  hyprland.messageAsync(`dispatch workspace ${ws}`);

App.applyCss(`
.workspace-icon {
	margin-top: 13px;
	margin-bottom: 16px;
}
`);

const Workspaces = () =>
  Widget.EventBox({
    //onScrollUp: () => dispatch("+1"),
    //onScrollDown: () => dispatch("-1"),
    child: Widget.Box({
      children: Array.from({ length: 10 }, (_, i) => i + 1).map((i) =>
        Widget.Button({
          attribute: i,
          label: `${i}`,
          onClicked: () => dispatch(i),
          className: "circular workspace-icon",
        }),
      ),

      setup: (self) =>
        self.hook(hyprland, () =>
          self.children.forEach((btn) => {
            if (btn.attribute === hyprland.active.workspace.id) {
              btn.css = `background-color:${COLOR.Highlight};`;
            } else if (
              hyprland.workspaces.some((ws) => ws.id === btn.attribute)
            ) {
              btn.css = `background-color:${COLOR.Surface2};`;
            } else {
              btn.css = `background-color:${COLOR.Surface0};`;
            }
          }),
        ),
    }),
  });

const battery = await Service.import("battery");

const batteryIcon = () =>
  Widget.Label({
    label: battery.bind("percent").as((p) => {
      if (p >= 90) {
        return ` `;
      } else if (p >= 65) {
        return ` `;
      } else if (p >= 40) {
        return ` `;
      } else if (p >= 10) {
        return ` `;
      } else {
        return ` `;
      }
    }),
    class_name: battery.bind("charging").as((ch) => (ch ? "charging" : "")),
  });

const batteryTimeRemaining = () =>
  Widget.Label({
    css: "font-size: 1.9em;",
    label: battery
      .bind("time_remaining")
      .as(
        (t) =>
          `${Math.floor(t / 60 / 60)}:${String(Math.floor((t / 60) % 60)).padStart(2, "0")}`,
      ),
  });

const batteryProgressBar = () =>
  Widget.Box({
    children: [
      batteryIcon(),
      Widget.LevelBar({
        widthRequest: 100,
        value: battery.bind("percent").as((p) => p / 100),
        css: "border: 1px transparent solid;",
      }),
    ],
  });

App.applyCss(`
levelbar trough {
  background-color: ${COLOR.Surface0};
}

levelbar block.filled {
  background-color: ${COLOR.Highlight};
}
`);

const batteryProgressWheel = () =>
  Widget.CircularProgress({
    tooltipText: Utils.merge(
      [battery.bind("percent"), battery.bind("energy_rate")],
      (percent, watts) => `${percent}%\n${round(watts)}W`,
    ),
    css:
      "min-width: 50px;" + // its size is min(min-height, min-width)
      "min-height: 50px;" +
      "font-size: 6px;" + // to set its thickness set font-size on it
      "margin: 4px;" + // you can set margin on it
      `background-color: ${COLOR.Surface0};` + // set its bg color
      `color: ${COLOR.Highlight};`, // set its fg color
    rounded: false,
    inverted: false,
    startAt: 0.75,
    value: battery.bind("percent").as((p) => p / 100),
    child: batteryTimeRemaining(),
  });

const ram = Variable(
  { total: 0, used: 0 },
  {
    poll: [
      2000,
      ["bash", "-c", `LANG=C free | awk '/^Mem/ {print $2,$3}'`],
      (x) => {
        let split = x.split(" ");
        return { total: Number(split[0]), used: Number(split[1]) };
      },
    ],
  },
);

function round(number: number) {
  return String(Math.round(number * 10) / 10);
}

const ramProgressBar = () =>
  Widget.Box({
    tooltipText: ram
      .bind()
      .as(
        (x) =>
          `${round(x.used / 1024 / 1024)}GiB / ${round(x.total / 1024 / 1024)}GiB (${round((x.used / x.total) * 100)}%)`,
      ),
    children: [
      Widget.Label({ label: " " }),
      Widget.LevelBar({
        widthRequest: 100,
        value: ram.bind().as((x) => x.used / x.total),
        css: "border: 1px transparent solid;",
      }),
    ],
  });

// TODO: this is a terrible measure of cpu usage, find a better one
// best case figure out what waybar does
const cpu = Variable("", {
  poll: [
    500,
    [
      "bash",
      "-c",
      `LANG=C top -bn1 | grep Cpu | sed 's/\\,/\\./g' | awk '{print $2}'`,
    ],
  ],
});

const cpuProgressBar = () =>
  Widget.Box({
    tooltipText: cpu.bind().as((x) => `${x.padStart(4, "0")}%`),
    children: [
      Widget.Label({ label: "󰓅 " }),
      Widget.LevelBar({
        widthRequest: 100,
        value: cpu.bind().as((x) => Number(x) / 100),
        css: "border: 1px transparent solid;",
      }),
    ],
  });

const networking = await Service.import("network");

const networkIcon = () =>
  Widget.Label({
    label: Utils.merge(
      [
        networking.wifi.bind("strength"),
        networking.bind("primary"),
        networking.bind("connectivity"),
      ],
      (p, primary, connectivity) => {
        if (connectivity === "none") {
          return "󰤭 ";
        }
        if (primary === "wired") {
          return "󰈀 ";
        }

        if (p >= 90) {
          return "󰤨 ";
        } else if (p >= 65) {
          return `󰤥 `;
        } else if (p >= 40) {
          return `󰤢 `;
        } else if (p >= 10) {
          return `󰤟 `;
        } else {
          return `󰤯 `;
        }
      },
    ),
  });

function RightClickMenu() {
  const menu = Widget.Menu({
    canFocus: false,
    canDefault: false,
    children: [
      Widget.MenuItem({
        child: Widget.Label("hello"),
      }),
    ],
  });

  return Widget.Button({
    on_hover: (_, event) => {
      menu.popup_at_pointer(event);
    },
    on_hover_lost: (_, event) => {
      //menu.cancel()
      //menu.popup(null, null, null, 0, event.get_time())
    },
  });
}

const ip = Variable("", {
  poll: [
    60000,
    [
      "bash",
      "-c",
      `ip -o -4 addr list wlp1s0 | awk '{print $4}' | cut -d/ -f1`,
    ],
  ],
});

const networkingProgressBar = () =>
  Widget.Box({
    tooltipMarkup: Utils.merge(
      [networking.bind("wifi"), ip.bind()],
      (wifi, ip) => `${wifi.ssid} (${wifi.strength}%)\n${ip}`,
    ),
    children: [
      networkIcon(),
      Widget.LevelBar({
        widthRequest: 100,
        value: networking.wifi.bind("strength").as((x) => x / 100),
        css: "border: 1px transparent solid;",
      }),
    ],
  });

const time = Variable("", {
  poll: [1000, `date "+%H:%M:<span fgalpha='60%'>%S</span>\n%Y/%m/%d"`],
});

function date() {
  return Widget.Label({
    css: "font-size:1.2em",
    hpack: "start",
    useMarkup: true,
    label: time.bind(),
  });
}

const Container = (children) =>
  Widget.Box({
    css: `background-color:${COLOR.Mantle};
	border-radius:15px;
	padding:5px;
	padding-left:9px;
	padding-right:9px;
	margin:5px;`,
    children: children,
  });

const Bar = (monitor: number) =>
  Widget.Window({
    monitor,
    name: `bar-left-${monitor}`,
    anchor: ["top", "left", "right"],
    exclusivity: "exclusive",
    margins: [5, 7, 5, 7],
    css: `background-color: ${COLOR.Surface0}; padding: 1em;border-radius:25px;`,
    child: Widget.CenterBox({
      start_widget: Widget.Box({
        css: "padding-left:9px;padding-top:10px;",
        child: focusedTitle(),
      }),
      center_widget: Widget.Box({
        children: [
          Container([Workspaces()]),
          Container([
            date(),
            Widget.Box({
              vertical: true,
              css: "padding-right:4px;padding-left:7px;",
              children: [
                networkingProgressBar(),
                cpuProgressBar(),
                ramProgressBar(),
              ],
            }),
            batteryProgressWheel(),
          ]),
        ],
      }),
      end_widget: Widget.Box({
        hpack: "end",
        css: "font-size:1.5em;padding-right:12px;",
        children: [
          Container([
            Widget.Button({
              css: "margin: 6px",
              onClicked: () => Utils.execAsync(nixData.show_clipboard),
              label: " 󱉫 ",
            }),
            Widget.Button({
              css: "margin: 6px",
              onClicked: () => Utils.execAsync(nixData.show_clipboard),
              label: " 󱉫 ",
            }),
          ]),
        ],
      }),
    }),
  });

App.config({
  windows: [Bar(0)],
});

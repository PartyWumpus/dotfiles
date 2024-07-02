// TODO:
// make height constant properly
// make the selected window title have a max length before truncation or something
// make the battery bar a networking bar
// find a nice rounded font
// use svg icon thingies instead of just nerd font icons
// TO ADD:
// volume indicator
// tooltips EVERYWHERE with info (exact values, wifi name + ip address for networking, calendar, etc)
//

interface nix {
  bun: string;
}
//const nixData: nix = JSON.parse(
//  Utils.readFile(`/home/${Utils.USER}/.local/share/ags/nix.json`),
//);

import * as COLOR from "./colours.json";

const hyprland = await Service.import("hyprland");

const focusedTitle = () =>
  Widget.Box({
    vertical: true,
    css: "background-color: transparent;",
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

const ram = Variable("", {
  poll: [
    2000,
    [
      "bash",
      "-c",
      `LANG=C free | awk '/^Mem/ {printf("0.%.0f", ($3/$2) * 100)}'`,
    ],
  ],
});

const ramProgressBar = () =>
  Widget.Box({
    children: [
      Widget.Label({ label: " " }),
      Widget.LevelBar({
        widthRequest: 100,
        value: ram.bind().as((x) => Number(x)),
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
    children: [
      Widget.Label({ label: "󰓅 " }),
      Widget.LevelBar({
        widthRequest: 100,
        value: cpu.bind().as((x) => Number(x) / 100),
        css: "border: 1px transparent solid;",
      }),
    ],
  });

const time = Variable({hour:"",min:"",second:"",year:"",month:"",day:""}, {
  poll: [1000, 'date "+%H/%M/%S/%Y/%m/%d"', out => {
		let arr = out.split("/");
		return {
			hour: arr[0],
			min: arr[1],
			second: arr[2],
			year: arr[3],
			month: arr[4],
			day: arr[5]
		}
	}],
});

function date() {
  return Widget.Box({
    vertical: true,
		css: "font-size:1.2em",
    children: [
      Widget.Box({
        children: [
          Widget.Label({ hpack: "start", label: time.bind().as(x => `${x.hour}:${x.min}`) }),
          Widget.Label({
            hpack: "start",
            label: time.bind().as(x => `:${x.second}`),
            css: "opacity:0.6;",
          }),
        ],
      }),
      Widget.Label({ hpack: "start", label: time.bind().as(x => `${x.year}/${x.month}/${x.day}`) }),
    ],
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
    css: "background-color: transparent; padding: 1em;",
    child: Widget.CenterBox({
      start_widget: Widget.Box({
        child: Container([focusedTitle()]),
      }),
      center_widget: Widget.Box({
        //css: "border:black 3px solid;",
        children: [
          Container([Workspaces()]),
          Container([
            date(),
            Widget.Box({
              vertical: true,
              css: "padding-right:4px;padding-left:7px;",
              children: [
                batteryProgressBar(),
                cpuProgressBar(),
                ramProgressBar(),
              ],
            }),
            batteryProgressWheel(),
          ]),
        ],
      }),
      end_widget: Widget.Label({
        hpack: "end",
				label: "X",
        //label: time.bind(),
      }),
    }),
  });

App.config({
  windows: [Bar(0)],
});

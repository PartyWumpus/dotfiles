import { nix } from "nix";
import { round } from "utils";

const ram = Variable(
  { total: 0, used: 0 },
  {
    poll: [
      2000,
      [
        "dash",
        "-c",
        //`LANG=C free | awk '/^Mem/ {print $2,$3}'`
        `cat /proc/meminfo | awk '/MemTotal/ {tot=$2} /MemAvailable/ {avail=$2} END {print tot ":" avail}'`,
      ],
      (x) => {
        let split = x.split(":");
        return {
          total: Number(split[0]),
          used: Number(split[0]) - Number(split[1]),
        };
      },
    ],
  },
);

export const RamBar = () =>
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

const cpu = Variable(0, {
  poll: [
    4000,
    [
      "dash",
      "-c",
      // returns two numbers, the first one is bad
      // the second one is the percentage IDLE time
      String.raw`LANG=C top -bn2 | awk '/Cpu\(s\):/ { print $8 }'`,
    ],
    (idle_percents) => {
      return 100 - Number(idle_percents.split("\n")[1]);
    },
  ],
});

const cpuTemp = Variable(0, {
  poll: [
    5000,
    `cat /sys/class/thermal/thermal_zone0/temp`,
    (x) => Number(x) / 1000,
  ],
});

const CpuBar = () =>
  Widget.Box({
    tooltipText: Utils.merge(
      [cpu.bind(), cpuTemp.bind()],
      (cpu, temp) => `${round(cpu)}% (${temp}°C)`,
    ),
    children: [
      Widget.Label({ label: "󰓅 " }),
      Widget.LevelBar({
        widthRequest: 100,
        value: cpu.bind().as((x) => x / 100),
        css: "border: 1px transparent solid;",
      }),
    ],
  });

const networking = await Service.import("network");

const NetworkIcon = () =>
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

const ip = Variable(null, {
  poll: [
    60000,
    [
      "dash",
      "-c",
      `ip -o -4 addr list wlp1s0 | awk '{print $4}' | cut -d/ -f1`,
    ],
    (ip) => {
      if (ip === '') {
        return null
      } else {
        return ip
      }
    }
  ],
});

const NetworkingBar = () =>
  Widget.EventBox({
    // TODO: onSecondaryClick: () => App.openWindow("network"),
    onSecondaryClick: () => Utils.execAsync(nix.wifi_menu),
    child: Widget.Box({
      tooltipMarkup: Utils.merge(
        [networking.bind("primary"), networking.bind("wired"), networking.bind("wifi"), ip.bind()],
        (primary, wired, wifi, ip) => {
          if (primary === 'wifi') {
            return `${wifi.ssid} (${wifi.strength}%)\n${ip ?? 'ip unknown'}`
          } else if (primary === 'wired') {
            return `${wired.internet}\n${ip ?? 'ip unknown'}`
          } else {
            return `Wired: ${wired.state}\nWireless: ${wifi.state}`
          }
        },
      ),
      children: [
        NetworkIcon(),
        Widget.LevelBar({
          widthRequest: 100,
          value: Utils.merge([
            // strength is not re-sent when the access point (networking._ap) disconnects
            // so we actually *need* to listen to primary here or bugs
            networking.wifi.bind("strength"),
            networking.bind("primary"),
          ], (strength, primary) => {
            switch (primary) {
              case 'wifi':
                return Math.abs(strength) / 100
              case 'wired':
                return 1
              default:
                return 0
            }
          }),
          css: "border: 1px transparent solid;",
        }),
      ],
    }),
  });

export const InfoBars = () =>
  Widget.Box({
    vertical: true,
    css: "padding-right:4px;padding-left:7px;",
    children: [NetworkingBar(), CpuBar(), RamBar()],
  });

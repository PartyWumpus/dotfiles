const bluetooth = await Service.import("bluetooth");

import * as COLOR from "../../colours.json";

import { BluetoothDevice } from "types/service/bluetooth";

const BluetoothWheel = (device: BluetoothDevice) =>
  Widget.Button({
    className: "flat",
    css: "box-shadow: none;text-shadow: none;background: none;padding: 0;margin-right:1px;margin-left:4px;",
    tooltipText: `${device.alias}\nBattery: ${Math.floor(device.battery_percentage)}%`,

    child: Widget.CircularProgress({
      css:
        "min-width: 40px;" + // its size is min(min-height, min-width)
        "min-height: 40px;" +
        "font-size: 6px;" + // to set its thickness set font-size on it
        "margin: 1px;" + // you can set margin on it
        `background-color: ${COLOR.Surface1};` + // set its bg color
        `color: ${COLOR.Highlight};`,
      rounded: false,
      inverted: false,
      startAt: 0.75,
      value: device.battery_percentage / 100,
      child: Widget.Icon({
        icon: device.icon_name + "-symbolic",
        css: "font-size:15px;",
      }),
    }),
  });

export const BluetoothWheels = () =>
  Widget.Box({
    children: bluetooth
      .bind("connected_devices")
      .as((x) => x.map(BluetoothWheel)),
  });

import type service from "@ags/service";

import * as COLOR from "colours.json";

import GLib from "gi://GLib";

import brightness from "services/brightness";

const WINDOW_NAME = "popovers";
const audio = await Service.import("audio");
const popoverCount = Variable(0);

function Popover<Prop extends string, 
Service extends service & { [k in Prop]: number }>(
  icon: string,
  connectable: Service,
  prop: Prop,
) {
  return Widget.EventBox({
    onScrollUp: () => (connectable[prop] += 0.015),
    onScrollDown: () => (connectable[prop] -= 0.015),
    child: Widget.Revealer({
      css: "min-width:1px;min-height:1px;",
      revealChild: false,
      transition: "slide_right",
      transitionDuration: 500,
      attribute: {
        prev: undefined,
        timeout: undefined,
      } as {
        prev?: number;
        timeout?: GLib.Source;
      },
      setup: (self) => {

				Utils.timeout(300, () => self.revealChild = true)

        self.hook(connectable, () => {
          const percent = connectable[prop];
          if (self.attribute.prev === undefined) {
            self.attribute.prev = percent;
            return;
          }

          if (percent === self.attribute.prev) return;

          self.revealChild = true;
          popoverCount.value++;
          if (self.attribute.timeout) {
            clearTimeout(self.attribute.timeout);
          }
          self.attribute.timeout = setTimeout(() => {
            self.revealChild = false;
            popoverCount.value--;
          }, 2000);
        });
      },
      child: Widget.Box({
        css: connectable.bind(prop).as(
          (p) => `padding:5px;margin:5px;border-radius:5px;
			background-color:${COLOR.Surface0};`,
        ),
        child: Widget.Label({
          label: connectable.bind(prop).as((p) => {
            return `${icon} ${Math.round(p * 1000) / 10}%`;
          }),
        }),
      }),
    }),
  });
}

export const Popovers = Widget.Window({
  css: "background-color:transparent;",
  name: WINDOW_NAME,
  visible: false,
	setup: (self) => {
		//Utils.timeout(2000, () => self.visible = true)
		//Utils.timeout(4000, () => self.visible = false)
		Utils.timeout(4000, () => self.visible = true)
		setInterval(() => self.visible = !self.visible, 2500)
	},
  anchor: ["top"],
  child: Widget.Revealer({
    revealChild: true,
    child: Widget.Box({
      css: "padding: 1px;",
      children: [
        Popover("vol", audio.speaker, "volume"),
        Popover("bright", brightness, "screen_value"),
      ],
    }),
  }),
});

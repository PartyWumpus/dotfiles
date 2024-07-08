const { query } = await Service.import("applications");
import type { Application } from "types/service/applications";
const WINDOW_NAME = "applauncher";

import Gdk from "gi://Gdk";
import Gtk from "gi://Gtk";

import * as COLOR from "../colours.json";

const AppItem = (app: Application) =>
  Widget.Button({
    css: "margin:2px;margin-bottom:0px",
    on_clicked: () => {
      App.closeWindow(WINDOW_NAME);
      app.launch();
    },
    attribute: { app },
    child: Widget.Box({
      children: [
        Widget.Icon({
          icon: app.icon_name || "",
          css: "font-size: 35px",
          // size doesn't scale all the icons identically so gotta use this instead
        }),
        Widget.Label({
          css: "font-size: 20px",
          class_name: "title",
          label: ` ${app.name}`,
          xalign: 0,
          vpack: "center",
          truncate: "end",
        }),
      ],
    }),
  });

function applicationsList() {
  let applications = query("").map(AppItem);
  return applications;
}

const Applauncher = ({ width = 500, height = 500, spacing = 12 }) => {
  // list of application buttons
  let applications = applicationsList();

  // container holding the buttons
  const list = Widget.Box({
    vertical: true,
    children: applications,
    spacing,
  });

  // repopulate the box, so the most frequent apps are on top of the list
  function repopulate() {
    applications = applicationsList();

    list.children = applications;
  }

  function filterList(text) {
    let first = true;
    for (const item of applications) {
      item.canFocus = true;
      let visible = item.attribute.app.match(text ?? "");
      item.visible = visible;
      // skip focus over first item, because the entry bar is already the first item
      if (first && visible) {
        item.canFocus = false;
        first = false;
      }
    }
  }

  // wrap the list in a scrollable
  const scrollableList = Widget.Scrollable({
    hscroll: "never",
    css: `min-width: ${width}px;` + `min-height: ${height}px;`,
    child: list,
  });

  // search entry
  const entry = Widget.Entry({
    hexpand: true,
    css: `margin-bottom: ${spacing}px;`,

    // to launch the first item on Enter
    on_accept: () => {
      // make sure we only consider visible (searched for) applications
      const results = applications.filter((item) => item.visible);

      if (results[0]) {
        App.toggleWindow(WINDOW_NAME);
        results[0].attribute.app.launch();
      }
    },

    // filter out the list
    on_change: ({ text }) => filterList(text),
  }).on("focus_in_event", () => scrollableList.get_vadjustment().set_value(0));

  return Widget.Box({
    vertical: true,
    css: `margin: ${spacing * 2}px;`,
    children: [entry, scrollableList],
    setup: (self) =>
      self.hook(App, (_, windowName, visible) => {
        if (windowName !== WINDOW_NAME) return;

        // when the applauncher shows up
        if (visible) {
          repopulate();
          entry.text = "";
          filterList("");
          entry.grab_focus();
        }
      }),
  }).on("key-press-event", (_, event: Gdk.Event) => {
    const keyval = event.get_keyval()[1];
    if (keyval == Gdk.KEY_Return || keyval == Gdk.KEY_Tab) {
      return;
    }
    // check if it is a valid character or something like an arrow key or modifier
    const char = Gdk.keyval_to_unicode(keyval);
    if (char != 0) {
      entry.grab_focus_without_selecting();
      entry.event(event);
    }
  });
};

// there needs to be only one instance
export const AppLauncher = Widget.Window({
  css: `border-radius:25px;background-color:${COLOR.Base}`,
  name: WINDOW_NAME,
  setup: (self) =>
    self.keybind("Escape", () => {
      App.closeWindow(WINDOW_NAME);
    }),
  visible: false,
  keymode: "exclusive",
  child: Applauncher({
    width: 500,
    height: 500,
    spacing: 12,
  }),
});

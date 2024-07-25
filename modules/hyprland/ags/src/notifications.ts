import { type Notification } from "@ags/service/notifications";

import * as COLOR from "colours.json";
import { nix } from "nix";
import { getMonitorID, sleep } from "utils";

import GLib from "gi://GLib";
// TODO: MAKE NOTIF BACKGROUND TRANSPARENT AND BLURRED!!! w/ xray too?
import Gdk from "gi://Gdk";

const notifications = await Service.import("notifications");

notifications.popupTimeout = 4000;
//notifications.forceTimeout = true;

App.applyCss(`
window.notification-popups box.notifications {
    padding: .5em;
}

.icon {
    min-width: 68px;
    min-height: 68px;
    margin-right: 1em;
}

.icon image {
    font-size: 58px;
    /* to center the icon */
    margin: 5px;
    color: @theme_fg_color;
}

.icon box {
    min-width: 68px;
    min-height: 68px;
    border-radius: 7px;
}

.notification {
    min-width: 350px;
    border-radius: 11px;
    padding: 1em;
    margin: .5em;
    background-color: ${COLOR.Surface1};
		background-color: rgba(73, 77, 100,0.7);
}

.notification.critical {
    border: 1px solid lightcoral;
}

.title {
    color: @theme_fg_color;
    font-size: 1.4em;
}

.body {
    color: @theme_unfocused_fg_color;
}

.actions .action-button {
    margin: 0 .4em;
    margin-top: .8em;
}

.actions .action-button:first-child {
    margin-left: 0;
}

.actions .action-button:last-child {
    margin-right: 0;
}
`);

function NotificationIcon({ app_entry, app_icon, image }: Notification) {
  if (image) {
    return Widget.Box({
      css:
        `background-image: url("${image}");` +
        "background-size: contain;" +
        "background-repeat: no-repeat;" +
        "background-position: center;",
    });
  }

  let icon = "dialog-information-symbolic";
  if (Utils.lookUpIcon(app_icon)) icon = app_icon;

  if (app_entry && Utils.lookUpIcon(app_entry)) icon = app_entry;

  return Widget.Box({
    child: Widget.Icon(icon),
  });
}

function NotificationWidget(n: Notification) {
  /*const icon = Widget.Box({
    vpack: "start",
    class_name: "icon",
    child: NotificationIcon(n),
  });*/

  const title = Widget.Label({
    class_name: "title",
    xalign: 0,
    justification: "left",
    hexpand: true,
    max_width_chars: 24,
    truncate: "end",
    wrap: true,
    label: n.summary,
    use_markup: true,
  });

  const body = Widget.Label({
    class_name: "body",
    hexpand: true,
    use_markup: true,
    xalign: 0,
    justification: "left",
    label: n.body,
    wrap: true,
  });

  const actions = Widget.Box({
    class_name: "actions",
    children: n.actions.map(({ id, label }) =>
      Widget.Button({
        class_name: "action-button",
        on_clicked: () => {
          n.invoke(id);
          n.dismiss();
        },
        hexpand: true,
        child: Widget.Label(label),
      }),
    ),
  });

  return Widget.EventBox(
    {
      attribute: { id: n.id },
      on_primary_click: n.dismiss,
    },
    Widget.Box(
      {
        class_name: `notification ${n.urgency}`,
        vertical: true,
      },
      Widget.Box([
        //icon,
        Widget.Box({ vertical: true }, title, body),
      ]),
      actions,
    ),
  );
}

export function NotificationPopups(monitor: Gdk.Monitor) {
  const list = Widget.Box({
    vertical: true,
    children: notifications.popups.map(NotificationWidget),
  });

  let timeout: GLib.Source | null = null;

  async function onNotified(_: any, id: number) {
    clearTimeout(timeout!);
    await Utils.execAsync(`hyprctl keyword debug:damage_tracking 0;`);
    //await Utils.execAsync(`hyprctl keyword decoration:screen_shader ${nix.shader}`)
    await Utils.execAsync(
      `hyprctl keyword decoration:screen_shader /home/wumpus/nixos/modules/hyprland/chromatic_aberration.frag`,
    );
    timeout = setTimeout(() => {
      Utils.execAsync(`hyprctl keyword decoration:screen_shader ""`);
      Utils.execAsync(`hyprctl keyword debug:damage_tracking 2`);
    }, 4000);
    const n = notifications.getNotification(id);
    if (n) list.children = [NotificationWidget(n), ...list.children];
  }

  function onDismissed(_: any, id: number) {
    list.children.find((n) => n.attribute.id === id)?.destroy();
  }

  list
    .hook(notifications, onNotified, "notified")
    .hook(notifications, onDismissed, "dismissed");

  return Widget.Window({
    gdkmonitor: monitor,
    name: `ags-notifications${getMonitorID(monitor)}`,
    class_name: "notification-popups",
    anchor: ["top"],
    child: Widget.Box({
      css: "min-width: 2px; min-height: 2px;",
      class_name: "notifications",
      vertical: true,
      child: list,
    }),
  });
}

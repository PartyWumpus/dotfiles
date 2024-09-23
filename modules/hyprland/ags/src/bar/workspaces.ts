import * as COLOR from "colours.json";
import { getMonitorID } from "utils";

import Gdk from "gi://Gdk";

import { newAspectFrame as AspectFrame } from "widgets/AspectFrame";

const hyprland = await Service.import("hyprland");

App.applyCss(`
.workspace-icon {
	margin-left: 1px;
	margin-right: 1px;
	font-size: 15px;
}`);

const dispatch = (ws: number) =>
  hyprland.messageAsync(`dispatch workspace ${ws}`);

export const Workspaces = (monitor: Gdk.Monitor) =>
  Widget.EventBox({
    child: Widget.Box({
      children: Array.from({ length: 10 }, (_, i) => i + 1).map((i) =>
        AspectFrame({
          className: "flat",
          child: Widget.Button({
            attribute: i,
            label: `${i}`,
            onClicked: () => dispatch(i),
            className: "circular workspace-icon",
          }),
          ratio: 1,
        }),
      ),

      setup: (self) => {
        const funcy = () => {
          const monitorId = getMonitorID(monitor)
          self.children.forEach((frame) => {
            const btn = frame.child;
            const workspace = hyprland.workspaces.find((ws) => ws.id === btn.attribute)

            if (workspace === undefined) {
              // not open
              btn.css = `background-color:${COLOR.Surface1};opacity:0.5;`;
              btn.tooltipText = ''
              return
            }

            btn.tooltipText = workspace.windows === 0 ? '' : String(workspace.windows)

            const activeWorkspace = hyprland.monitors[monitorId]?.activeWorkspace?.id
            if (btn.attribute === activeWorkspace) {
              // currently active on this monitor
              btn.css = `background-color:${COLOR.Highlight};`;
              return
            }

            if (workspace.monitorID === monitorId) {
              // open on this monitor
              btn.css = `background-color:${COLOR.Overlay1};`;
            } else {
              // open on another monitor
              btn.css = `background-color:${COLOR.Overlay0};opacity:0.75;`;
            }
          })
        }
        funcy()
        self.hook(hyprland, funcy)
      },
    }),
  });

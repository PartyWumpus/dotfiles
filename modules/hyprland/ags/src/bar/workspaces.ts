import Gtk from "gi://Gtk";

import * as COLOR from "../../colours.json";

const hyprland = await Service.import("hyprland");

App.applyCss(`
.workspace-icon {
	margin-left: 1px;
	margin-right: 1px;
	font-size: 15px;
}`);

// TODO: fix this jankery
type BaseProps = Parameters<typeof Widget.Box>[0];

const dispatch = (ws: number) =>
  hyprland.messageAsync(`dispatch workspace ${ws}`);

// TODO: sorry.
const NotAspectFrame = Widget.subclass(Gtk.AspectFrame);
type aspectFrameProps = (
  props: BaseProps & { child?: Gtk.Widget; ratio?: number },
) => ReturnType<typeof NotAspectFrame>;
const aspectFrame: aspectFrameProps =
  NotAspectFrame as unknown as aspectFrameProps;

// TODO: my type crimes didnt actually fix all the issues
// figure it out.

export const Workspaces = () =>
  Widget.EventBox({
    //onScrollUp: () => dispatch("+1"),
    //onScrollDown: () => dispatch("-1"),
    child: Widget.Box({
      children: Array.from({ length: 10 }, (_, i) => i + 1).map((i) =>
        aspectFrame({
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

      setup: (self) =>
        self.hook(hyprland, () =>
          self.children.forEach((frame) => {
            const btn = frame.child;
            if (btn.attribute === hyprland.active.workspace.id) {
              btn.css = `background-color:${COLOR.Highlight};`;
            } else if (
              hyprland.workspaces.some((ws) => ws.id === btn.attribute)
            ) {
              btn.css = `background-color:${COLOR.Overlay0};`;
            } else {
              btn.css = `background-color:${COLOR.Surface1};`;
            }
          }),
        ),
    }),
  });

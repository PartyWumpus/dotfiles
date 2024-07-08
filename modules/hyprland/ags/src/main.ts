import { AppLauncher } from "./applauncher";
import { NotificationPopups } from "./notifications";
import { Bar, dropdownMenu } from "./bar";
import { Clipboard } from "./menus/clipboard";
import { SinkPicker } from "./menus/sink_picker";

App.config({
  windows: [
    Bar(0),
    dropdownMenu,
    AppLauncher,
    NotificationPopups(0),
    Clipboard,
    SinkPicker,
  ],
});

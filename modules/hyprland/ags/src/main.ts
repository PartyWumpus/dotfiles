import { AppLauncher } from "./applauncher";
import { NotificationPopups } from "./notifications";
import { Bar, dropdownMenu } from "./bar";

App.config({
  windows: [Bar(0), dropdownMenu, AppLauncher, NotificationPopups(0)],
});

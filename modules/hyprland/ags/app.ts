/*
NOTE: remember to run
ags types -d . -p
to generate types
*/

import { App } from "astal/gtk3"
import style from "./style.scss"
import Bar from "./src/bar/Bar"
import OSD from "./src/OSD"
import Hotcorner from "./src/Hotcorner"
import Notifications from "./src/notifications/Notifications"

App.start({
  icons: `./icons/`,
  css: style,
  main() {
    App.get_monitors().map(Bar)
    App.get_monitors().map(OSD)
    App.get_monitors().map(Hotcorner)
    App.get_monitors().map(Notifications)
  },
  /*
  requestHandler(request, res) {
    // getting Gio.IOErrorEnum "Stream has outstanding operation"
    switch (request) {
      case "hotcorner":
        globalThis?.enableHotcorner?.()
        res("hotcorner success")
      default:
        res(`ERROR: ${request} is an invalid request`)
    }
  },
  */
})

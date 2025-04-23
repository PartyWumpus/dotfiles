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
import MusicPlayer from "./src/musicplayer/musicplayer"

App.start({
  icons: `./icons/`,
  css: style,
  main() {
    App.get_monitors().map(Bar)
    App.get_monitors().map(OSD)
    App.get_monitors().map(Hotcorner)
    App.get_monitors().map(Notifications)
    App.get_monitors().map(MusicPlayer)
  },
  requestHandler(request, res) {
    // getting Gio.IOErrorEnum "Stream has outstanding operation"
    switch (request) {
      case "hello":
        res(`hi :)`)
      default:
        res(`ERROR: ${request} is an invalid request`)
    }
  },
})
